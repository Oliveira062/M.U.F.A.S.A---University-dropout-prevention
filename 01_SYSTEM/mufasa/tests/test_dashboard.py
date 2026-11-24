import os
import sys
from pathlib import Path

import pytest

DASHBOARD = Path(__file__).resolve().parents[1] / "dashboard"
sys.path.insert(0, str(DASHBOARD))

AppTest = pytest.importorskip("streamlit.testing.v1").AppTest


@pytest.fixture
def app_without_api(monkeypatch):
    monkeypatch.setenv("MUFASA_API_URL", "http://127.0.0.1:9")
    monkeypatch.chdir(DASHBOARD)
    return AppTest.from_file(str(DASHBOARD / "app.py"), default_timeout=30)


def test_login_shows_profile_selector(app_without_api):
    at = app_without_api.run()
    assert not at.exception
    labels = [s.label for s in at.selectbox]
    assert "Access profile" in labels
    options = at.selectbox[0].options
    assert len(options) == 8


def test_login_with_api_down_shows_notice_without_breaking(app_without_api):
    at = app_without_api.run()
    at.text_input[0].input("coordination.demo")
    at.text_input[1].input("any-password")
    at.button[0].click().run()
    assert not at.exception
    texts = " ".join(e.value for e in at.error)
    assert "Could not" in texts


def test_exported_csv_has_footer_and_neutralizes_formula():
    import ui
    data = ui.export_csv([{"a": "+cmd", "b": "-1"}], ["a", "b"], "Test", "BOARD").decode("utf-8-sig")
    assert "'+cmd" in data


def test_chat_answer_becomes_safe_and_organized_html():
    from screens.common import format_answer
    output = format_answer("Hi <script>x</script>\n\n• Calculus I: final grade 7\n  EXAM1 7 · EXAM2 0\n\n"
                              "The risk level shows that this student's pattern of test.")
    assert "<script>" not in output and "&lt;script&gt;" in output
    assert "<ul><li><b>Calculus I</b>: final grade 7<small>EXAM1 7 · EXAM2 0</small></li></ul>" in output
    assert 'class="mf-grade-msg"' in output


def test_accessibility_button_only_loads_vlibras_after_confirming():
    import re
    import ui

    js = (DASHBOARD / "accessibility.js").read_text(encoding="utf-8")
    assert re.search(r"libras:\s*false", js)
    body = js.split("function loadVLibras()", 1)[1].split("function turnOffVLibras()", 1)[0]
    assert "VLIBRAS + \"/vlibras-plugin.js\"" in body
    assert js.count("vlibras-plugin.js") == 1
    assert js.count("loadVLibras();") == 1 and "if (pref.libras) loadVLibras();" in js
    assert 'action === "libras-yes") { notice.hidden = true; pref.libras = true; }' in js
    loader = ui._accessibility_loader()
    assert loader.count("</") == 1 and loader.endswith("</script>")


def test_data_table_escapes_text_and_highlights_below_minimum():
    import ui

    assert "<script>" not in ui.txt("<script>x</script>")
    assert 'class="mf-grade-pill low"' in ui.grade_cell(5.9, 6.0) and "5.9" in ui.grade_cell(5.9, 6.0)
    assert 'class="mf-grade-pill"' in ui.grade_cell(7.0, 6.0)
    assert "low" in ui.attendance_cell(60, 75) and "60%" in ui.attendance_cell(60, 75)
    assert "Failed" in ui.status_cell("FAILED_GRADE") or "Failed grade" in ui.status_cell("FAILED_GRADE")
    assert "Up to date" in ui.alerts_cell([])


def test_configure_copies_only_groq_keys_to_env(tmp_path):
    sys.path.insert(0, str(DASHBOARD.parent))
    from scripts.configure import apply_keys, read_keys

    (tmp_path / "groq.env").write_text("﻿# key\r\nGROQ_API_KEY=abc\r\nDATABASE_URL=invasion\r\n", encoding="utf-8")
    env = tmp_path / ".env"
    env.write_text("DATABASE_URL=right\nGROQ_API_KEY=\n", encoding="utf-8")
    assert apply_keys(env, read_keys(tmp_path / "groq.env")) == ["GROQ_API_KEY"]
    assert env.read_text(encoding="utf-8") == "DATABASE_URL=right\nGROQ_API_KEY=abc\n"
    assert apply_keys(env, read_keys(tmp_path / "groq.env")) == []
