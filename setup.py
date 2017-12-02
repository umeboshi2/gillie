import os

from setuptools import setup, find_packages

here = os.path.abspath(os.path.dirname(__file__))
with open(os.path.join(here, 'README.txt')) as f:
    README = f.read()
with open(os.path.join(here, 'CHANGES.txt')) as f:
    CHANGES = f.read()

requires = [
    'chert',
    'trumpet',
    'gunicorn',
    'plaster_pastedeploy',
    'pyramid >= 1.9a',
    'SQLAlchemy',
    'alembic',
    'transaction',
    'zope.sqlalchemy',
    'paginate_sqlalchemy',
    'pyramid_retry',
    'pyramid_debugtoolbar',
    'pyramid_mako',
    'pyramid_jinja2',
    'pyramid_tm',
    'pyramid_webpack',
    'cornice',
    'rest_toolkit',
    'psycopg2',
    'pyramid_jwt',
    'bcrypt',
    'wsgiprox',
    'robobrowser',
    'beautifulsoup4',
    'lxml',
    'pyramid_jsonapi',
]

tests_require = [
    'WebTest >= 1.3.1',  # py3 compat
    'pytest',
    'pytest-cov',
]

setup(
    name='gillie',
    version='0.0',
    description='gillie',
    long_description=README + '\n\n' + CHANGES,
    classifiers=[
        'Programming Language :: Python',
        'Framework :: Pyramid',
        'Topic :: Internet :: WWW/HTTP',
        'Topic :: Internet :: WWW/HTTP :: WSGI :: Application',
    ],
    author='',
    author_email='',
    url='',
    keywords='web pyramid pylons',
    packages=find_packages(),
    include_package_data=True,
    zip_safe=False,
    extras_require={
        'testing': tests_require,
    },
    install_requires=requires,
    dependency_links=[
        'git+https://github.com/umeboshi2/chert.git#egg=chert'
        'git+https://github.com/umeboshi2/trumpet.git#egg=trumpet'
    ],
    entry_points={
        'paste.app_factory': [
            'main = gillie:main',
        ],
        'console_scripts': [
            'initialize_gillie_db = gillie.scripts.initializedb:main',
        ],
    },
)
