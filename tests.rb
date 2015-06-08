#!/usr/bin/env ruby
#
# http://docs.ruby-lang.org/en/2.0.0/Net/HTTP.html
# https://gist.github.com/tam7t/86eb4793e8ecf3f55037
# https://www.howsmyssl.com/
# http://apidock.com/ruby/OpenSSL/SSL/SSLContext

# gem install bundle
#
# cat > Gemfile <<EOF
# source "https://rubygems.org"
# gem 'net'
# gem 'json'
# EOF
#
# bundle install
# buundle exec ruby thisfile.rb

require 'rubygems'
require 'uri'
require 'net/http'
require 'openssl'
require 'json'



def test_ssl_connection(url, json=false)
  uri = URI(url)
  ssl_options = OpenSSL::SSL::OP_NO_COMPRESSION +
                OpenSSL::SSL::OP_NO_SSLv2 +
                OpenSSL::SSL::OP_NO_SSLv3
  ssl_ciphers = "TLSv1.2:!aNULL:!eNULL:!LOW:!MEDIUM:+HIGH:!EXPORT:!ADH"
  ssl_version = "TLSv1_2"
  verify_mode = OpenSSL::SSL::VERIFY_PEER
  ca_file = File.join(File.dirname(__FILE__), "cacert.pem")

  OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:options] = ssl_options
  OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ciphers] = ssl_ciphers
  OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ssl_version] = ssl_version
  OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:verify_mode] = verify_mode
  OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ca_file] = ca_file

  begin
    Net::HTTP.start(uri.host, uri.port,
      :use_ssl => uri.scheme == 'https') do |http|

      if json
        resp = JSON.parse(http.request(Net::HTTP::Get.new(uri.request_uri)).body)
        puts JSON.pretty_generate(resp)
      else
        resp = http.request(Net::HTTP::Get.new(uri.request_uri)).body
        puts resp
      end
    end
  rescue
    puts "Failed to connect to #{url}"
  end
end


# https://revoked.grc.com is a website with a revoked SSL certificate
# unfortunately our test_ssl_connection will pass with a revoked certificate
# full blown details of how to deal with revocations in ruby are listed here:
# http://stackoverflow.com/questions/16244084/how-to-programmatically-check-if-a-certificate-has-been-revoked

# All these URLs should fail with different SSL connection errors
# https://tv.eurosport.com has an invalid common name
# www.mjvmobile.com.br is a Self signed certificate
# www.mtsindia.in is missing an intermediate certifcate

should_fail_urls = ['https://tv.eurosport.com/',
                    'https://www.mjvmobile.com.br/',
                    'https://www.mtsindia.in/']


should_fail_urls.each do |should_fail_url|
  test_ssl_connection(should_fail_url)
end

# https://howsmyssl.com website gives back a JSON with the quality of the client SSL
#
should_pass_url = 'https://www.howsmyssl.com/a/check'
test_ssl_connection(should_pass_url, true )
