#!/bin/bash
set -v
if [ "${CIRCLE_BRANCH}" != "master" ]; then
  # Circle-CI
  #

  gem install --no-document rubocop-select rubocop rubocop-checkstyle_formatter \
              checkstyle_filter-git saddler saddler-reporter-github

  # CircleCI stop script ;(
  # git diff -z --name-only origin/master

  git diff -z --name-only origin/master \
   | xargs -0 rubocop-select

  git diff -z --name-only origin/master \
   | xargs -0 rubocop-select \
   | xargs rubocop \
       --require rubocop/formatter/checkstyle_formatter \
       --format RuboCop::Formatter::CheckstyleFormatter

  git diff -z --name-only origin/master \
   | xargs -0 rubocop-select \
   | xargs rubocop \
       --require rubocop/formatter/checkstyle_formatter \
       --format RuboCop::Formatter::CheckstyleFormatter \
   | checkstyle_filter-git diff origin/master

  git diff -z --name-only origin/master \
   | xargs -0 rubocop-select \
   | xargs rubocop \
       --require rubocop/formatter/checkstyle_formatter \
       --format RuboCop::Formatter::CheckstyleFormatter \
   | checkstyle_filter-git diff origin/master \
   | saddler report \
      --require saddler/reporter/github \
      --reporter Saddler::Reporter::Github::PullRequestReviewComment

  noof=$(git diff -z --name-only origin/master \
   | xargs -0 rubocop-select \
   | xargs rubocop \
   | grep "no offenses detected")
  echo $noof
  echo "Rubocop result: ${#noof}"

  if [[ -z $noof ]]; then
    echo "offenses detected"
    exit 1
  fi

fi
exit 0
