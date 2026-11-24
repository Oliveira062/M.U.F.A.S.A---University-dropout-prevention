import json
from datetime import datetime, timezone

from sqlalchemy.engine import Engine

from app.calculation_service import calculation_queries as sql

COMMAND_BY_TYPE = {"GRADES": sql.APPLY_GRADES, "INDICATORS": sql.APPLY_INDICATORS}


def apply_next_load(engine: Engine) -> int | None:
    with engine.begin() as connection:
        load = connection.execute(sql.CONFIRMED_LOAD).mappings().first()
        if load is None:
            return None
        load_id = load["load_id"]
        try:
            with connection.begin_nested():
                command = COMMAND_BY_TYPE[load["kind"]]
                total = 0
                for row in connection.execute(sql.LOAD_ROWS, {"load_id": load_id}).mappings().all():
                    data = row["data"] if isinstance(row["data"], dict) else json.loads(row["data"])
                    connection.execute(command, data)
                    total += 1
            status, result = "APPLIED", f"{total} row(s) applied."
        except Exception as exc:
            status, result = "FAILED", f"No row applied: {type(exc).__name__}."
        connection.execute(sql.FINISH_LOAD, {"load_id": load_id, "status": status, "result": result,
                                             "now": datetime.now(timezone.utc)})
        connection.execute(sql.CREATE_NOTIFICATION, {"user_id": load["sent_by"], "now": datetime.now(timezone.utc),
                                                     "kind": "LOAD", "title": f"Load {load_id}: {status.lower()}",
                                                     "text": result, "alert_id": None})
        return load_id
