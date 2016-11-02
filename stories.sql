CREATE DATABASE stories;

CREATE TABLE users(
  id SERIAL4 PRIMARY KEY,
  username VARCHAR(30),
  email VARCHAR(100),
  password_digest VARCHAR(400)
);

CREATE TABLE suggestions(
  id SERIAL4 PRIMARY KEY,
  story_id INTEGER,
  user_id INTEGER,
  edit_text TEXT,
  read BOOLEAN
);

CREATE TABLE stories(
  id SERIAL4 PRIMARY KEY,
  user_id INTEGER,
  title VARCHAR(400),
  story_text TEXT,
  by_line VARCHAR(400),
  privacy VARCHAR(20),
  editor_instructions VARCHAR(500)
);

CREATE TABLE votes(
  id SERIAL4 PRIMARY KEY,
  story_id INTEGER,
  suggestion_id INTEGER,
  user_id INTEGER,
  direction VARCHAR(4)
);
