from configparser import ConfigParser
from io import StringIO

from sqlalchemy import (
    Column,
    Index,
    Integer,
    BigInteger,
    Float,
    Text,
    Unicode,
    UnicodeText,
    Date,
    DateTime,
    PickleType,
    Boolean,
    Enum,
    func,
    ForeignKey,
)
from sqlalchemy.orm import relationship
from hornstone.alchemy import SerialBase, TimeStampMixin

from .meta import Base

from .usergroup import User

EBMODELS = {}

class EbcsvConfig(Base, TimeStampMixin):
    __tablename__ = 'ebcsv_configs'
    id = Column(Integer, primary_key=True)
    name = Column(Unicode(100), unique=True)
    content = Column(PickleType)
EBMODELS['ebcsvcfg'] = EbcsvConfig

class EbcsvDescription(Base, TimeStampMixin):
    __tablename__ = 'ebcsv_descriptions'
    id = Column(Integer, primary_key=True)
    name = Column(Unicode(100), unique=True)
    title = Column(Unicode(500))
    content = Column(UnicodeText)
EBMODELS['ebcsvdsc'] = EbcsvDescription

class EbcsvClzComicPage(Base, SerialBase):
    __tablename__ = 'ebcsv_clz_comic_pages'
    id = Column(Integer, primary_key=True)
    url = Column(Unicode(500), unique=True)
    image_src = Column(Unicode(500))
EBMODELS['ebclzpage'] = EbcsvClzComicPage

class ClzCollectionStatus(Base, SerialBase):
    __tablename__ = 'clz_collection_status'
    id = Column(Integer, primary_key=True)
    name = Column(Unicode(100), unique=True)
EBMODELS['clzcollectionstatus'] = ClzCollectionStatus

class EbcsvClzComic(Base, TimeStampMixin):
    __tablename__ = 'ebcsv_clz_comics'
    id = Column(Integer, primary_key=True)
    comic_id = Column(Integer, unique=True)
    index = Column(Integer)
    list_id = Column(Integer, ForeignKey('clz_collection_status.id'))
    bpcomicid = Column(Integer)
    bpseriesid = Column(Integer)
    # https://bitbucket.org/zzzeek/sqlalchemy/issues/3067/naming-convention-exception-for-boolean
    rare = Column(Boolean(name='rare_comic'), default=func.false())
    publisher = Column(Unicode(100))
    releasedate = Column(Date)
    seriesgroup = Column(Unicode(100), default='UNGROUPED')
    series = Column(UnicodeText)
    issue = Column(Integer)
    issueext = Column(UnicodeText)
    quantity = Column(Integer)
    currentprice = Column(Float)
    url = Column(UnicodeText, default='UNAVAILABLE')
    image_src = Column(Unicode(500), default='UNSET')
    # parsed xml object
    content = Column(UnicodeText)
EBMODELS['ebclzcomic'] = EbcsvClzComic

class EbComicWorkspace(Base, TimeStampMixin):
    __tablename__ = 'ebcomics_workspace'
    id = Column(Integer, primary_key=True)
    comic_id = Column(Integer,
                      ForeignKey('ebcsv_clz_comics.comic_id'),
                      unique=True)
    name = Column(UnicodeText)
EBMODELS['ebcomicworkspace'] = EbComicWorkspace

class GeneralUpload(Base, TimeStampMixin):
    __tablename__ = 'general_uploads'
    id = Column(Integer, primary_key=True)
    fieldname = Column(UnicodeText)
    originalname = Column(UnicodeText)
    encoding = Column(UnicodeText)
    mimetype = Column(UnicodeText)
    destination = Column(UnicodeText)
    filename = Column(UnicodeText)
    path = Column(UnicodeText)
    size = Column(BigInteger)

class ComicPhoto(Base, TimeStampMixin):
    __tablename__ = 'comic_photos'
    id = Column(Integer, primary_key=True)
    comic_id = Column(Integer,
                      ForeignKey('ebcsv_clz_comics.comic_id'),
                      unique=True)
    name = Column(UnicodeText)
    filename = Column(UnicodeText)
    encoding = Column(UnicodeText)
    mimetype = Column(UnicodeText)


class ComicPhotoName(Base, SerialBase):
    __tablename__ = 'comic_photo_names'
    id = Column(Integer, primary_key=True)
    name = Column(Unicode(100), unique=True)
    

class ComicMainPhoto(Base, TimeStampMixin):
    __tablename__ = 'comic_main_photos'
    id = Column(Integer, primary_key=True)
    comic_id = Column(Integer,
                      ForeignKey('ebcsv_clz_comics.comic_id'),
                      unique=True)
    name = Column(UnicodeText)
    filename = Column(UnicodeText)
    encoding = Column(UnicodeText)
    mimetype = Column(UnicodeText)

class ComicExtraPhoto(Base, TimeStampMixin):
    __tablename__ = 'comic_extra_photos'
    id = Column(Integer, primary_key=True)
    comic_id = Column(Integer,
                      ForeignKey('ebcsv_clz_comics.comic_id'),
                      unique=True)
    name = Column(UnicodeText)
    filename = Column(UnicodeText)
    encoding = Column(UnicodeText)
    mimetype = Column(UnicodeText)

class ListedComic(Base, TimeStampMixin):
    __tablename__ = 'listed_comics'
    id = Column(Integer, primary_key=True)
    comic_id = Column(Integer,
                      ForeignKey('ebcsv_clz_comics.comic_id'),
                      unique=True)
    workspace = Column(UnicodeText)
    


