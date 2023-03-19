#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"

echo "Enter your username:"
read USERNAME

# look for username
USERNAME_RESULT=$($PSQL "SELECT * FROM users WHERE username='$USERNAME';")
# if username does not exist
if [[ -z $USERNAME_RESULT ]]
then
  # welcome users
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # insert username into database
  INSERT_USERNAME=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")
# if username exists
else
  # print player information pulled from database
  echo $USERNAME_RESULT | while IFS="|" read USER_ID USERNAME GAMES BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST_GAME guesses."
  done
fi

# generate secret number
SECRET_NUMBER=$((1 + RANDOM%(1000)))
# track number of guesses
GUESSES=0
# ask users to guess secret number
echo "Guess the secret number between 1 and 1000:"
function GUESS_NUMBER {
  read GUESS
  GUESSES=$(( GUESSES + 1 ))
  # if guess is an integer
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    # if guess is correct
    if [[ $GUESS -eq $SECRET_NUMBER ]]
    then
      echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    # if guess is lower
    elif [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      GUESS_NUMBER
    # if guess is higher
    elif [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      GUESS_NUMBER
    fi
  else
    echo "That is not an integer, guess again:"
    GUESS_NUMBER
  fi
}
GUESS_NUMBER

# update player information
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
if [[ $GUESSES -lt $BEST_GAME ]] || [[ -z $BEST_GAME ]]
then
  BEST_GAME=$GUESSES
fi
UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games = games + 1, best_game = $BEST_GAME WHERE username='$USERNAME'")
