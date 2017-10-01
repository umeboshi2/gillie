#!/bin/bash
initialize_gillie_db production.ini || true
gunicorn --paste production.ini
