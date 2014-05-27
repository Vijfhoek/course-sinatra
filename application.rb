require "sinatra"
require "slim"
require "bootstrap-sass"
require "data_mapper"
require "dm-sqlite-adapter"

use Rack::Deflater
set :slim, :pretty => true

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/blog.db")

class Post
	include DataMapper::Resource
	property :id, Serial
	property :title, String
	property :body, Text
	property :created_at, DateTime
	property :author, String
end

DataMapper.finalize
Post.auto_upgrade!

get "/style.css" do
	scss :"/scss/style"
end

get "/" do
	@active = "home"
	slim :home
end

get "/blog" do
	@active = "blog"
	@posts = Post.all
	slim :"blog/index"
end

# Create
get "/blog/create" do
	slim :"blog/create"
end
post "/blog/create" do
	@params = params[:post]
	unless @params[:title] == nil || @params[:author] == nil || @params[:body] == nil
		@post = Post.new(@params)
		@post.save
		redirect "/blog"
	else
		redirect "/blog/create"
	end
end

# Read
get "/blog/:id" do
	@post = Post.get(params[:id])
	slim :"blog/read"
end


# Update
get "/blog/update/:id" do
	@post = Post.get(params[:id])
	slim :"blog/update"
end

# Destroy
get "/blog/destroy/:id" do
	@post = Post.get(params[:id])
	@post.destroy
	redirect "/blog"
end


get "/*" do
	@active = params[:splat][0]
	slim @active.to_sym
end
