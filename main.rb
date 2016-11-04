require 'sinatra'
require 'sinatra/reloader'
require_relative 'db_config'
require_relative 'models/story'
require_relative 'models/suggestion'
require_relative 'models/user'
require_relative 'models/vote'
require 'pry'

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
    keys = Story.where.not(privacy: "private").group(:project_id).count
  else
    keys = Story.where(privacy: "public").group(:project_id).count
  end
  @stories = []
  keys.each_key do |key|
    story = Story.where(project_id: key).last
    @stories << story
  end
  erb :index
end

get '/user' do
  erb :user_signup
end

post '/user' do
  if !params[:username] || params[:username] == ""
    @username_error = "Please enter a username to register with this site."
  elsif User.find_by(username: params[:username])
    @username_error = "That username is already taken. Please choose another one and try again."
  else
    @username = params[:username]
  end
  if !params[:email] || params[:email] == ""
    @email_error = "Please enter an email address to register with this site."
  elsif User.find_by(email: params[:email])
    @email_error = "That email address is already registered with the site. Please log in to your existing account or choose another email address and try again."
  else
    @email = params[:email]
  end
  if !params[:password] || params[:password] == ""
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

get '/user/:id' do
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
    keys = Story.where(user_id: session[:user_id]).group("project_id").count
    @stories = []
    keys.each_key do |key|
      story = Story.where(project_id: key).last
      @stories << story
    end
    erb :dashboard
  else
    redirect to '/'
  end
end

get '/story' do
  if logged_in?
    @story = Story.new
    erb :submit_story
  else
    redirect to '/'
  end
end

post '/story' do
  if logged_in?
    @story = Story.new
    if !params[:title] || params[:title] == ""
      @story_title_error = "Every story needs a title. Please add one and try again."
    end
    @story.title = params[:title]
    if !params[:by_line] || params[:by_line] == ""
      @by_line_error = "Please enter your name or your pen name, so that your loyal fans know who to buy this book from when it is finished."
    end
    @story.by_line = params[:by_line]
    if !params[:story_text] || params[:story_text] == ""
      @story_text_error = "Every story begins with a single word. Yours should try doing this too."
    end
    @story.story_text = params[:story_text]
    if !params[:privacy] || (params[:privacy] != "public" && params[:privacy] != "restricted" && params[:privacy] != "private")
      @story.privacy = "private"
    else
      @story.privacy = params[:privacy]
    end
    if !params[:editor_instructions] || params[:editor_instructions] == ""
      @story.editor_instructions = "Please tell me what you think of my story."
    else
      @story.editor_instructions = params[:editor_instructions]
    end
    if !@story_title_error && !@by_line_error && !@story_text_error
      @story.user_id = session[:user_id]
      if @story.save
        @story.reload
        redirect to "/story/#{@story.project_id}"
      else
        erb :submit_story
      end
    else
      erb :submit_story
    end
  else
    redirect to '/'
  end
end

get '/story/:id' do
  @story = Story.where(project_id: params[:id]).last
  @edits = Suggestion.where(story_id: @story.id)
  @story.story_text.gsub!("&", "&amp;")
  @story.story_text.gsub!("<", "&lt;")
  @story.story_text.gsub!(">", "&gt;")
  @story.story_text.gsub!("\r\n\r\n", '</p><p>')
  @story.story_text.gsub!("\r\n", '<br>')
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
      if @story.story_text.rindex('.')
        @story.story_text = @story.story_text[0, @story.story_text.rindex('.') + 1]
      else
        @story.story_text = @story.story_text[0, @story.story_text.rindex(' ') + 1]
      end
      @story.story_text += " ...</p><p>Log in to keep reading."
      erb :display_story
    end
  end
end

get '/story/:id/edit' do
  @stories = Story.where(project_id: params[:id])
  @story = @stories.last
  @versions = {:previous => false, :next => false}
  if @stories.length > 1
    @versions[:previous] = true
  end
  if logged_in? && @story.user == current_user
    @edits = @story.suggestions
    erb :edit_story
  else
    redirect to "/story/#{params[:id]}"
  end
end

put '/story/:id' do
  @story = Story.find(params[:id])
  if logged_in? && @story.user = current_user
    if !params[:title] || params[:title] == ""
      @story_title_error = "Every story needs a title. Please add one and try again."
    else
      @story.title = params[:title]
    end
    if !params[:by_line] || params[:by_line] ==""
      @by_line_error = "Please enter your name or your pen name, so that your loyal fans know who to buy this book from when it is finished."
    else
      @story.by_line = params[:by_line]
    end
    if !params[:story_text] || params[:story_text] == ""
      @story_text_error = "Every story begins with a single word. Yours should try doing this too."
    else
      @story.story_text = params[:story_text]
    end
    if !params[:privacy] || (params[:privacy] != "public" && params[:privacy] != "restricted" && params[:privacy] != "private")
      @story.privacy = "private"
    else
      @story.privacy = params[:privacy]
    end
    if !params[:editor_instructions] || params[:editor_instructions] == ""
      @story.editor_instructions = "Please tell me what you think of my story."
    else
      @story.editor_instructions = params[:editor_instructions]
    end
    if !@story_title_error && !@by_line_error && !@story_text_error
      # @story.user_id = session[:user_id]
      if params[:version] == "true"
        @newStory = Story.new
        @newStory.project_id = @story.project_id
        @newStory.user_id = @story.user_id
        @newStory.title = @story.title
        @newStory.story_text = @story.story_text
        @newStory.by_line = @story.by_line
        @newStory.privacy = @story.privacy
        @newStory.editor_instructions = @story.editor_instructions
        if @newStory.save
          @story.privacy = "private"
          @story.save
          redirect to "/story/#{@newStory.project_id}"
        end
      else
        if @story.save
          redirect to "/story/#{@story.project_id}"
        end
      end
    end
    @edits = @story.suggestions
    erb :edit_story
  else
    redirect to "/story/#{params[:id]}"
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
