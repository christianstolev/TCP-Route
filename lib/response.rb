# Class used to build and send HTTP responses
class Response
    TCP_SESSION = nil
    HTTP_VERSION = nil
    RESPONSE_CODE = nil
    RESPONSE_DATA = nil
    CONTENT_TYPE = nil 
  
    # Initializes the Response object with a TCP session.
    # @param session [TCPSocket] The TCP session for communication.
    def initialize(session)
      @TCP_SESSION = session
    end
  
    # Sets the HTTP version for the response.
    # @param version [String] The HTTP version (e.g., "1.1").
    def set_version(version)
      @HTTP_VERSION = "HTTP/" + version.to_s
    end
  
    # Sets the content type for the response.
    # @param type [String] The MIME type of the response (e.g., "text/html").
    def set_content_type(type)
      @CONTENT_TYPE = type
    end
  
    # Sets the HTTP status code for the response.
    # @param code [Integer] The status code (e.g., 200, 404).
    def set_code(code)
      @RESPONSE_CODE = code.to_s
    end
  
    # Sets the response body data.
    # @param response [String] The response data.
    def set_response(response)
      @RESPONSE_DATA = response
    end
  
    # Completes the response by sending it over the TCP session and closing the session.
    def done
      session = @TCP_SESSION
  
      session.print(@HTTP_VERSION + @RESPONSE_CODE + "\r\n")
      session.print("Content-Type: " + @CONTENT_TYPE + "\r\n")
      session.print("\r\n")
      session.print(@RESPONSE_DATA)
      session.close
    end
  end
  