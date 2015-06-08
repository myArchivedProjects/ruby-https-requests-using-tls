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

uri = URI('https://www.howsmyssl.com/a/check')

ssl_options = OpenSSL::SSL::OP_NO_COMPRESSION +
              OpenSSL::SSL::OP_NO_SSLv2 +
              OpenSSL::SSL::OP_NO_SSLv3
ssl_ciphers = "TLSv1.2:!aNULL:!eNULL:!LOW:!MEDIUM:+HIGH:!EXPORT:!ADH"
ssl_version = "TLSv1_2"

OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:options] = ssl_options
OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ciphers] = ssl_ciphers
OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ssl_version] = ssl_version

Net::HTTP.start(uri.host, uri.port,
  :use_ssl => uri.scheme == 'https') do |http|

    resp = JSON.parse(http.request(Net::HTTP::Get.new(uri.request_uri)).body)
    puts JSON.pretty_generate(resp)
  end
