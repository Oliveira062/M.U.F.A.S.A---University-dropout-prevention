from sqlalchemy import text
from sqlalchemy.engine import Connection
from sqlalchemy.exc import ProgrammingError

from app.calculation.parameters import DEFAULT, Parameters

_VALUES = text("SELECT key, value FROM parameters")
_VERSION = text("SELECT max(version) FROM parameter_versions")


def current_parameters(connection: Connection) -> Parameters:
    try:
        with connection.begin_nested():
            values = {l["key"]: float(l["value"]) for l in connection.execute(_VALUES).mappings()}
            version = connection.execute(_VERSION).scalar() or 0
    except ProgrammingError:
        return DEFAULT
    return Parameters({**DEFAULT.values, **values}, version=int(version))
