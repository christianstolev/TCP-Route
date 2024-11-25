class Response 
    TCP_SESSION = nil
    HTTP_VERSION = nil
    RESPONSE_CODE = nil
    RESPONSE_DATA = nil
    CONTENT_TYPE = nil 
    def initialize(session)
        @TCP_SESSION = session
    end

    def set_version(version)
        @HTTP_VERSION = "HTTP/" + version.to_s
    end
    def set_content_type(type)
        @CONTENT_TYPE = type
    end
    def set_code(code)
        @RESPONSE_CODE = code.to_s
    end

    def set_response(response)
        @RESPONSE_DATA = response
    end
    def done()
        session = @TCP_SESSION

        session.print(@HTTP_VERSION + @RESPONSE_CODE + "\r\n")
        session.print("Content-Type: " + @CONTENT_TYPE + "\r\n")
        session.print("\r\n")
        session.print(@RESPONSE_DATA)
        session.close
    end
end