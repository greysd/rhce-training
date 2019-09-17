import platform
def wsgiinfo():
  status = '200 OK'
  response_headers = [('Content-type', 'text/plain')]
  message = 'Version: ' + platform.python_version() + 
  '\nVersion tuple: ' + python.python_version_tuple() +
  '\nCompiler: ' + python.python_compiler() +
  '\nBuild: ' + python.python_build() + '\n'
  start_response(status, response_headers)
  return message