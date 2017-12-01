import warnings
from datetime import datetime, date

from sqlalchemy import Column, DateTime, func
from sqlalchemy import PickleType

# http://stackoverflow.com/questions/4617291/how-do-i-get-a-raw-compiled-sql-query-from-a-sqlalchemy-expression
from sqlalchemy.sql import compiler
from psycopg2.extensions import adapt as sqlescape


def compile_query(query):
    dialect = query.session.bind.dialect
    statement = query.statement
    comp = compiler.SQLCompiler(dialect, statement)
    comp.compile()
    enc = dialect.encoding
    params = {}
    for k, v in comp.params.items():
        if isinstance(v, str):
            v = v.encode(enc)
        params[k] = sqlescape(v)
    return (comp.string.encode(enc) % params).decode(enc)


class SerialBase(object):
    def serialize(self):
        data = dict()
        table = self.__table__
        for column in table.columns:
            name = column.name
            try:
                pytype = column.type.python_type
            except NotImplementedError as error:
                if type(column.type) is PickleType:
                    value = getattr(self, name)
                    if type(value) not in [dict, list]:
                        # ignore column
                        continue
                else:
                    msg = "{}({}) Not Implemented.".format(column, column.type)
                    warnings.warn(msg)
                    continue
            value = getattr(self, name)
            if pytype is datetime or pytype is date:
                if value is not None:
                    value = value.isoformat()
            data[name] = value
        return data



class TimeStampMixin(SerialBase):
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now())
    
    

def getDBSession(request):
    return request.dbsession
