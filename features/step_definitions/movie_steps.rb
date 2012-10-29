# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
    Movie.create!(movie)
  end
end

Given /I check the following ratings: (.*)/ do |rating_list|
  rating_list_array = rating_list.split(", ")
  rating_list_array.each do |rating|
    rating = "ratings_" + rating
    check(rating)
  end

  Movie.all_ratings.each do |rating|
    if !rating_list_array.include?(rating)
      rating = "ratings_" + rating
      uncheck(rating)
    end
  end
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.content  is the entire content of the page as a string.
  assert page.body.index(e1) < page.body.index(e2) , "Not in expected Order"
end

=begin
# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  rating_list.split(", ").each do |rating|
    rating = "ratings_" + rating
    if uncheck 
      uncheck(rating) 
    else 
      check(rating)
    end
  end 
end
=end

When /^submit the search form on the homepage$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should (not )?see movies rated: (.*)$/ do |not_logic, rating_list|
  rating_set = rating_list.split(", ")
  if not_logic
    movie_list = Movie.where("rating not in (?)", rating_set)
  else
    movie_list = Movie.where("rating in (?)", rating_set)
  end
  
  movie_list.each do |mov|
    within("#movies") do
      if not_logic
        assert have_no_content(mov[:title])
      else 
        should have_content(mov[:title])
      end
    end 
  end
end

When /^I (un)?check all the ratings$/ do | uncheck |
  Movie.all_ratings.each do |rating|
    rating = "ratings_" + rating
    if uncheck
      uncheck(rating)
    else
      check(rating)
    end
  end
end

Then /I should see all of the movies/ do 
  row_count = Movie.all.size
  page.find(:xpath, "//table[@id=\"movies\"]/tbody[count(tr) = #{row_count} ]")
end

