import platform
def application(environ,start_response):
  status = '200 OK'
  response_headers = [('Content-type', 'text/plain')]
  message = 'Version: ' + platform.python_version() + \
  '\nCompiler: ' + platform.python_compiler() + \
  '\nBuild: ' + '.'.join(platform.python_build()) + \
  '\nImplementation: ' + platform.python_implementation() + \
  '\nPlatform: ' + platform.platform() + '\n'
  start_response(status, response_headers)
  return message