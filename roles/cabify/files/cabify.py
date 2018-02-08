#!/usr/bin/env python

from bottle import route, run

@route('/status')
def status():
    return 'OK\n'

run(host='0.0.0.0', port=8181, debug=False)
