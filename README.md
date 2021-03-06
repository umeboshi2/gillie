# Flask Sample Application

This repository provides a sample Python web application implemented using the Flask web framework and hosted using ``gunicorn``. It is intended to be used to demonstrate deployment of Python web applications to OpenShift 3.

## Quick Deploy 

```
oc new-app python:3.5~https://github.com/umeboshi2/gillie.git
```


## Things to do.....

### Configuration

* Use more environment variables.

* Parse config for client, remove ~/config.coffee

* client config


### Database 

* setup users and groups

* learn and setup alembic

### Auth 

* use jsonwebtokens for auth, get it to match client code

* setup groups and permissions


### Pyramid

* serve static .gz files

* Consider CDN for some files.

	- https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css
	
	

### Client

* Don't perform initial /auth/refresh if no token exists.

* pagination

### Working with Alembic and ziggarut_foundations

**handle ziggarut_foundations much later......**

removed these files:

	- gillie/models/uzig.py
 
	- gillie/root_factory.py
 
also look at https://github.com/ergo/testscaffold/blob/master/testscaffold/scripts/migratedb.py

and also remember these steps:

```
# create the initial database
createdb gillie
# upgrade db to zigg skeleton
alembic -c zig-init-dev.ini upgrade head
# generate new migration from app code
alembic -c development.ini revision --autogenerate -m "Added initial stuff"
# perform new migration for app
alembic -c development.ini upgrade head
# populate db
initialize_gillie_db development.ini 
```




## Old Information

### Implementation Notes

This sample Python application relies on the support provided by the default S2I builder for deploying a WSGI application using the ``gunicorn`` WSGI server. The requirements which need to be satisfied for this to work are:

* The WSGI application code file needs to be named ``wsgi.py``.
* The WSGI application entry point within the code file needs to be named ``application``.
* The ``gunicorn`` package must be listed in the ``requirements.txt`` file for ``pip``.

In addition, the ``.s2i/environment`` file has been created to allow environment variables to be set to override the behaviour of the default S2I builder for Python.

* The environment variable ``APP_CONFIG`` has been set to declare the name of the config file for ``gunicorn``.

### Deployment Steps

To deploy this sample Python web application from the OpenShift web console, you should select ``python:2.7``, ``python:3.3``, ``python:3.4`` or ``python:latest``, when using _Add to project_. Use of ``python:latest`` is the same as having selected the most up to date Python version available, which at this time is ``python:3.4``.

The HTTPS URL of this code repository which should be supplied to the _Git Repository URL_ field when using _Add to project_ is:

* https://github.com/umeboshi2/os-sample-python.git

If using the ``oc`` command line tool instead of the OpenShift web console, to deploy this sample Python web application, you can run:

```
oc new-app https://github.com/umeboshi2/os-sample-python.git
```

In this case, because no language type was specified, OpenShift will determine the language by inspecting the code repository. Because the code repository contains a ``requirements.txt``, it will subsequently be interpreted as including a Python application. When such automatic detection is used, ``python:latest`` will be used.

If needing to select a specific Python version when using ``oc new-app``, you should instead use the form:

```
oc new-app python:2.7~https://github.com/umeboshi2/os-sample-python.git
```
