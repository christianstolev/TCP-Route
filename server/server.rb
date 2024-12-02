require 'socket'
require_relative '../lib/request'
require_relative '../lib/router'
require_relative '../lib/response'

types = {
    '3dmf'   => 'x-world/x-3dmf',
    '3dm'    => 'x-world/x-3dmf',
    'avi'    => 'video/x-msvideo',
    'ai'     => 'application/postscript',
    'bin'    => 'application/octet-stream',
    'bmp'    => 'image/bmp',
    'cab'    => 'application/x-shockwave-flash',
    'c'      => 'text/plain',
    'c++'    => 'text/plain',
    'class'  => 'application/java',
    'css'    => 'text/css',
    'csv'    => 'text/comma-separated-values',
    'cdr'    => 'application/cdr',
    'doc'    => 'application/msword',
    'dot'    => 'application/msword',
    'docx'   => 'application/msword',
    'dwg'    => 'application/acad',
    'eps'    => 'application/postscript',
    'exe'    => 'application/octet-stream',
    'gif'    => 'image/gif',
    'gz'     => 'application/gzip',
    'gtar'   => 'application/x-gtar',
    'flv'    => 'video/x-flv',
    'fh4'    => 'image/x-freehand',
    'fh5'    => 'image/x-freehand',
    'fhc'    => 'image/x-freehand',
    'help'   => 'application/x-helpfile',
    'hlp'    => 'application/x-helpfile',
    'html'   => 'text/html',
    'htm'    => 'text/html',
    'ico'    => 'image/x-icon',
    'imap'   => 'application/x-httpd-imap',
    'inf'    => 'application/inf',
    'jpe'    => 'image/jpeg',
    'jpeg'   => 'image/jpeg',
    'jpg'    => 'image/jpeg',
    'js'     => 'application/x-javascript',
    'java'   => 'text/x-java-source',
    'latex'  => 'application/x-latex',
    'log'    => 'text/plain',
    'm3u'    => 'audio/x-mpequrl',
    'midi'   => 'audio/midi',
    'mid'    => 'audio/midi',
    'mov'    => 'video/quicktime',
    'mp3'    => 'audio/mpeg',
    'mpeg'   => 'video/mpeg',
    'mpg'    => 'video/mpeg',
    'mp2'    => 'video/mpeg',
    'ogg'    => 'application/ogg',
    'phtml'  => 'application/x-httpd-php',
    'php'    => 'application/x-httpd-php',
    'pdf'    => 'application/pdf',
    'pgp'    => 'application/pgp',
    'png'    => 'image/png',
    'pps'    => 'application/mspowerpoint',
    'ppt'    => 'application/mspowerpoint',
    'ppz'    => 'application/mspowerpoint',
    'pot'    => 'application/mspowerpoint',
    'ps'     => 'application/postscript',
    'qt'     => 'video/quicktime',
    'qd3d'   => 'x-world/x-3dmf',
    'qd3'    => 'x-world/x-3dmf',
    'qxd'    => 'application/x-quark-express',
    'rar'    => 'application/x-rar-compressed',
    'ra'     => 'audio/x-realaudio',
    'ram'    => 'audio/x-pn-realaudio',
    'rm'     => 'audio/x-pn-realaudio',
    'rtf'    => 'text/rtf',
    'spr'    => 'application/x-sprite',
    'sprite' => 'application/x-sprite',
    'stream' => 'audio/x-qt-stream',
    'swf'    => 'application/x-shockwave-flash',
    'svg'    => 'text/xml-svg',
    'sgml'   => 'text/x-sgml',
    'sgm'    => 'text/x-sgml',
    'tar'    => 'application/x-tar',
    'tiff'   => 'image/tiff',
    'tif'    => 'image/tiff',
    'tgz'    => 'application/x-compressed',
    'tex'    => 'application/x-tex',
    'txt'    => 'text/plain',
    'vob'    => 'video/x-mpg',
    'wav'    => 'audio/x-wav',
    'wrl'    => 'x-world/x-vrml',
    'xla'    => 'application/msexcel',
    'xls'    => 'application/vnd.ms-excel',
    'xlc'    => 'application/vnd.ms-excel',
    'xml'    => 'text/xml',
    'zip'    => 'application/zip'
}

class HTTPServer

    def initialize(port)
        @port = port
    end

    def start
        server = TCPServer.new(@port)
        puts "Listening on #{@port}"
        router = Router.new

        router.add_route('/add/:id/:id2', :GET) do | num1, num2 |
            "Sum: #{num1.to_i + num2.to_i}" 
        end
        router.add_route('/sub/:id/:id2', :GET) do | num1, num2 |
            "#{num1} - #{num2} = #{num1.to_i - num2.to_i}" 
        end
        router.add_route('/div/:id/:id2', :GET) do | num1, num2 |
            "Sum: #{num1.to_i / num2.to_i}" 
        end
        router.add_route('/mul/:id/:id2', :GET) do | num1, num2 |
            "Sum: #{num1.to_i * num2.to_i}" 
        end

        while session = server.accept
            data = ""
            while line = session.gets and line !~ /^\s*$/
                data += line
            end

            request = Request.new(data)
            
            code, data = router.match_route(request)
            print("Code: #{code} Data: #{data}\n")
            res = Response.new(session)
            res.set_version(1.1)
            res.set_code(code)
            res.set_content_type("text/html")
            res.set_response(data)

            res.done()
        end
    end
end

server = HTTPServer.new(4567)
server.start