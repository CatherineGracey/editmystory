require 'sinatra'
require 'sinatra/reloader'
require_relative 'db_config'
require_relative 'models/story'
require_relative 'models/suggestion'
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
  if logged_in?
    @stories = Story.where.not(privacy: "private")
  else
    @stories = Story.where(privacy: "public")
  end
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
    if user.save
      session[:user_id] = user.id
      redirect to '/dashboard'
    else
      erb :user_signup
    end
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
  if logged_in?
    @stories = Story.where(user_id: session[:user_id])
    p @stories
    erb :dashboard
  else
    redirect to '/'
  end
end

get '/story' do
  if logged_in?
    erb :submit_story
  else
    redirect to '/'
  end
end

post '/story' do
  if logged_in?
    if !params[:title]
      @story_title_error = "Every story needs a title. Please add one and try again."
    end
    if !params[:by_line]
      @by_line_error = "Please enter your name or your pen name, so that your loyal fans know who to buy this book from when it is finished."
    end
    if !params[:story_text]
      @story_text_error = "Every story begins with a single word. Yours should try doing this too."
    end
    if !@story_title_error && !@by_line_error && !@story_text_error
      story = Story.new
      story.user_id = session[:user_id]
      story.title = params[:title]
      story.story_text = params[:story_text]
      story.by_line = params[:by_line]
      if !params[:privacy]
        story.privacy = "private"
      else
        story.privacy = params[:privacy]
      end
      if !params[:editor_instructions]
        story.editor_instructions = "Please tell me what you think of my story."
      else
        story.editor_instructions = params[:editor_instructions]
      end
      if story.save
        redirect to "/story/#{story.id}"
      end
    else
      puts @story_title_error
      puts @by_line_error
      puts @story_text_error
      erb :submit_story
    end
  else
    redirect to '/'
  end
end

get '/story/:id' do
  @story = Story.find(params[:id])
  @edits = Suggestion.where(story_id: @story.id)
  @story.story_text.gsub!("\r\n\r\n", '</p><p>')
  # Story is visible publically:
  #   Users can read the entire story
  #   Visitors can read an excerpt of the story
  # Story is visible restricted:
  #   Users can read the entire story
  #   Visitors cannot access the story
  # Story is visible private
  #   Authors can read the entire story
  #   Users cannot access the story
  #   Visitors cannot access the story
  if @story.privacy == "private"
    if @story.user == current_user
      erb :display_story
    else
      redirect to '/'
    end
  elsif @story.privacy == "restricted"
    if logged_in?
      erb :display_story
    else
      redirect to '/'
    end
  else # public story
    if logged_in?
      erb :display_story
    else
      # prevent user from reading the entire story.
      num = @story.story_text.length / 3
      if num > 1000
        num = 1000
      end
      @story.story_text = @story.story_text.slice!(0..num)
      @story.story_text = @story.story_text[0, @story.story_text.rindex('.') + 1]
      @story.story_text += " ...</p><p>Log in to keep reading."
      erb :display_story
    end
  end
end

post '/edit/:id' do
  if logged_in?
    edit = Suggestion.new
    edit.story_id = params[:id]
    edit.user_id = current_user.id
    edit.edit_text = params[:edit_text]
    edit.read = false
    edit.save
  end
  redirect to "/story/#{params[:id]}"
end

post '/vote' do
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
# Users can see the edits that they have written
# Users can up/down vote edits on their stories
# Users can specify the type of edit that they want to receive
