require 'sinatra/base'
require 'sinatra/url_for'
require 'slim'
require 'coderay'
require 'linguist'

class Pasteit < Sinatra::Base
  helpers Sinatra::UrlForHelper

  set :public_folder, File.dirname(__FILE__) + '/public'

  get '/' do
    slim :index
  end

  post '/' do
    call(env.merge('PATH_INFO' => '/pastes'))
  end

  get '/pastes/:name' do
    @paste = Paste.new(params[:name])
    if raw?
      content_type("text/plain")

      urls = @paste.files.map do |file|
        url_for("/pastes/#{@paste.name}/#{file.name}", :full)
      end
      urls.join("\n") << "\n"
    else
      @title = @paste.files.first.name
      slim :paste
    end
  end

  get '/pastes/:name/:filename' do
    if raw?
      return call(env.merge('PATH_INFO' => env['PATH_INFO'] + "/raw"))
    end
    paste = Paste.new(params[:name])
    @file = paste.file(params[:filename])
    @title = @file.name
    slim :paste_file
  end

  get '/pastes/:name/:filename/raw' do
    content_type("text/plain")

    paste = Paste.new(params[:name])
    file = paste.file(params[:filename])
    file.content
  end

  post '/pastes' do
    paste = Paste.create
    params.each_pair do |filename, param|
      tempfile = param[:tempfile]
      paste.add_file(filename, tempfile)
    end
    url_for("/pastes/#{paste.name}", :full) + "\n"
  end

  private
  def raw?
    !(env['HTTP_ACCEPT'].split(',').include?('text/html'))
  end

  class Paste
    NAME_LENGTH = 16

    attr_reader :name

    def self.create(name=nil)
      name ||= SecureRandom.hex(NAME_LENGTH)
      paste = new(name)
      FileUtils.mkdir(paste.dir)
      paste
    end
    def initialize(name)
      @name = name
    end
    def dir
      File.expand_path("../data/#{@name}", __FILE__)
    end
    def add_file(filename, tempfile)
      PasteFile.create_from_tempfile(self, filename, tempfile)
    end
    def file(name)
      files.find do |f|
        f.name == name
      end
    end
    def files
      @files ||= Dir[File.join(dir, '*')].map do |path|
        PasteFile.new(self, File.basename(path))
      end
    end
  end

  class PasteFile
    attr_reader :paste
    attr_reader :name

    def self.create_from_tempfile(paste, name, tempfile)
      file = new(paste, name)
      FileUtils.cp(tempfile.path, file.path)
      file
    end
    def initialize(paste, name)
      @paste = paste
      @name = name
    end
    def path
      filename = @name.gsub('/', '-')
      File.expand_path(filename, @paste.dir)
    end
    def code_div
      CodeRay.scan_file(path).div(line_numbers: :table, line_number_anchors: @name.gsub('.', '_'))
    end
    def content
      File.read(path)
    end
  end
end
