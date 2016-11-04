# WDI Project 2
## Edit My Story by Catherine Gracey

### Technical Requirements

**1** **Have at _least_ 2 models** (more if they make sense) – one representing someone using your application, and one that represents the main functional idea for your app

This project uses the following models:

1. users: this table tracks usernames, email addresses and passwords
2. stories: this is the main resource for the app. It tracks stories submitted by authors for review and versions within projects.
3. suggestions: this is the secondary resource for the app. It tracks suggestions made by users to authors on ways they can improve their stories.

**2** **Include sign up/log in functionality**, with encrypted passwords & an authorization flow

Sign up and log in/out is handled via Active Record. Passwords are hashed with bcrypt and stored in a password_digest field within the user model. Most sections of the website are restricted to users who are logged in, but minimal functionality is also provided to guests.

**3** **Have complete RESTful routes** for at least one of your resources with GET, POST, PUT, PATCH, and DELETE

Users can get stories (edits are automatically included where appropriate), post stories, and update stories via the put method. Users are currently unable to delete their stories by design, but they can set privacy to private, meaning they are the only ones who can access their stories. This is because authors are a tempermental bunch, who have a tendency to rage delete and then experience deep remorse the following day.

**4** **Utilize an ORM to create a database table structure** and interact with your relationally-stored data

The database used for this project is Postgres, and it is managed and accessed via Active Record.

**5** **Include wireframes** that you designed during the planning process

User stories, wireframes and other project notes are availabe on Trello at https://trello.com/b/LuBupmgJ/edit-my-story.

**6** Have **semantically clean HTML and CSS**

**7** **Be deployed online** and accessible to the public

This project, Edit My Story, is hosted online by Heroku at https://editmystory.herokuapp.com/.

### Necessary Deliverables

**1** A **working full-stack application, built by you**, hosted somewhere on the internet

This project is written with Embedded Ruby and CSS for the front end, served by a Ruby server, and supported by a SQL database. It is hosted online at Heroku.

**2** A **link to your hosted working app** in the URL section of your GitHub repo

The relevant section directs users to the Heroku page.

**3** A **git repository hosted on GitHub**, with a link to your hosted project,  and frequent commits dating back to the **very beginning** of the project. Commit early, commit often.

The repository for this project is available on GitHub at https://github.com/CatherineGracey/editmystory.

**4** **A ``readme.md`` file** with explanations of the technologies used, the approach taken, installation instructions, unsolved problems, etc.

**5** **Wireframes of your app**, hosted somewhere & linked in your readme
**6** A link in your ``readme.md`` to the publically-accessible **user stories you created**

User stories, wireframes and other project notes are availabe on Trello at https://trello.com/b/LuBupmgJ/edit-my-story.
