require 'sinatra'
require_relative 'db_config'
require_relative 'models/edit'
require_relative 'models/story'
require_relative 'models/user'
require_relative 'models/vote'

enable :sessions

helpers do

  def logged_in?
    !!current_user
  end

  def current_user
    User.find_by(id: session[:user_id])
  end

end

get '/' do
  erb :index
end

get '/user' do
  erb :user_signup
end

post '/user' do
  if !params[:username]
    @username_error = "Please enter a username to register with this site."
  elsif User.find_by(username: params[:username])
    @username_error = "That username is already taken. Please choose another one and try again."
  else
    @username = params[:username]
  end
  if !params[:email]
    @email_error = "Please enter an email address to register with this site."
  elsif User.find_by(email: params[:email])
    @email_error = "That email address is already registered with the site. Please log in to your existing account or choose another email address and try again."
  else
    @email = params[:email]
  end
  if !params[:password]
    @password_error = "Please enter a password to register with this site."
  end
  if !@username_error && !@email_error && !@password_error
    user = User.new
    user.username = params[:username]
    user.email = params[:email]
    user.password = params[:password]
    user.save
    redirect to '/dashboard'
  else
    erb :user_signup
  end
end

get 'user/:id' do
  erb :display_user
end

post '/session' do
  user = User.find_by(username: params[:username])
  if user && user.authenticate(params[:password])
    session[:user_id] = user.id
    redirect to '/dashboard'
  else
    if !user
      @user_not_found = "Could not find username #{params[:username]}."
    else
      @username = params[:username]
      @password_incorrect = "The password you have entered was incorrect. Please try again."
    end
    erb :session_new
  end
end

delete '/session' do
  session[:user_id] = nil
  redirect to '/'
end

get '/dashboard' do
  erb :dashboard
end

get '/stories' do
  erb :story_list
end

get 'story/:id' do
  erb :display_story
end

post '/vote' do
  erb :display_story
end

get '/story' do
  erb :submit_story
end

post '/story' do
  erb :display_story
end

# Not logged in:
# Users can register with the website
# Users can log in
# Users can see x words of public stories
# Users can see other users with public profiles
#
# Logged in:
# Users can log out
# Users can see the entire text of a public or restricted story
# Users can up/down vote stories
# Users can submit stories if they have enough points
# Users can submit edits
# Users can set the visibility of their stories
# Users can see edits on their stories
# Users can up/down vote edits on their stories
# Users can specify the type of edit that they want to receive
