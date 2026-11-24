import os
import sys

from sqlalchemy import create_engine, text

from app.api.cipher import encrypt

COLUMNS_EXIST = text("""
    SELECT COUNT(*) FROM information_schema.columns
     WHERE table_name = 'students'
       AND column_name IN ('requested_psychosocial_support', 'accessibility_need')
""")
READ_SUPPORT = text("""
    SELECT student_id, requested_psychosocial_support, accessibility_need FROM students ORDER BY student_id
""")
SAVE = text("""
    INSERT INTO student_support (student_id, encrypted_data) VALUES (:student_id, :data)
    ON CONFLICT (student_id) DO UPDATE SET encrypted_data = EXCLUDED.encrypted_data, updated_at = now()
""")
REMOVE_COLUMNS = text("""
    ALTER TABLE students DROP COLUMN requested_psychosocial_support, DROP COLUMN accessibility_need
""")


def _yes_no(value) -> bool | None:
    if value is None:
        return None
    return str(value).strip().lower() in ("yes", "s", "true", "1")


def main() -> int:
    url = os.environ.get("DATABASE_URL")
    key = os.environ.get("SUPPORT_KEY")
    if not url or not key:
        print("Set DATABASE_URL (database owner) and SUPPORT_KEY.", file=sys.stderr)
        return 2
    with create_engine(url, hide_parameters=True).begin() as connection:
        if connection.execute(COLUMNS_EXIST).scalar() != 2:
            print("Nothing to do: the support columns have already been migrated.")
            return 0
        total = 0
        for row in connection.execute(READ_SUPPORT).mappings().all():
            connection.execute(SAVE, {"student_id": row["student_id"], "data": encrypt(key=key, data={
                "requested_psychosocial_support": _yes_no(row["requested_psychosocial_support"]),
                "accessibility_need": _yes_no(row["accessibility_need"]),
            })})
            total += 1
        connection.execute(REMOVE_COLUMNS)
    print(f"{total} support records encrypted; columns removed from students.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
