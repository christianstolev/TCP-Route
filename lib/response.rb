# Class used to build and send HTTP responses
class Response
  TCP_SESSION = nil
  HTTP_VERSION = nil
  RESPONSE_CODE = nil
  RESPONSE_DATA = nil
  CONTENT_TYPE = nil

  #   res.set_version(1.1)
  #   res.set_code(rs.status_code)
  #   res.set_content_type(rs.mime_type)
  #   res.set_response(rs.response)
  #
  # Initializes the Response object with a TCP session.
  # @param session [TCPSocket] The TCP session for communication.
  def initialize(rs, session)
    @TCP_SESSION = session
    @HTTP_VERSION = 'HTTP/1.1 '
    @CONTENT_TYPE = rs.mime_type || 'text/plain'
    @RESPONSE_CODE = rs.status_code.to_s
    @RESPONSE_DATA = rs.response
  end

  # Completes the response by sending it over the TCP session and closing the session.
  def done
    session = @TCP_SESSION

    session.print(@HTTP_VERSION + @RESPONSE_CODE + "\r\n")
    session.print('Content-Type: ' + @CONTENT_TYPE + "\r\n")
    session.print("\r\n")
    session.print(@RESPONSE_DATA)
    session.close
  end
end
