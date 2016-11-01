CREATE DATABASE stories;

CREATE TABLE users(
  id SERIAL4 PRIMARY KEY,
  username VARCHAR(30),
  email VARCHAR(100),
  password_digest VARCHAR(400)
);

CREATE TABLE edits(
  id SERIAL4 PRIMARY KEY,
  story_id INTEGER,
  user_id INTEGER
);

CREATE TABLE stories(
  id SERIAL4 PRIMARY KEY,
  user_id INTEGER
);

CREATE TABLE votes(
  id SERIAL4 PRIMARY KEY,
  story_id INTEGER,
  edit_id INTEGER,
  user_id INTEGER
);
