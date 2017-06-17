Date parser

Date parser is a natural language date/time parser written in pure Ruby. See below for the wide variety of formats Date parser will parse.

Installation

$ gem install date_parser
Usage

require 'date_parser'

date= "05/01/15 - 12/31/16 8:00pm to 12:00am"

parse_date_from(date)

#=> {:time=>"8:00pm to 12:00am", :start_date=>2015-05-02 00:00:00 UTC, :end_date=>2016-12-31 05:00:00 UTC}


Examples

Date Parser can parse a huge variety of date and time formats. Following is a small sample of strings that will be properly parsed. Parsing is case insensitive and will handle common abbreviations and misspellings.

Simple

# date = "October 9, 2016 – October 22, 2016"
# date = "date"=>"October 25, 2016 @ 7:30 pm"
# date = "date"=>"Saturday, October 22, 2016 @ 9:00 AM (EDT)"
# date = "date"=>"October 9, 2016 – October 22, 2016"
# date = "date"=>"Wed 10/19/16 - Thu 4/20/17 at 9am-5pm"
# date = "date"=>"Mar 2017 Dates Unconfirmed"
# date = "date"=>"Friday, September 9, 2016 @ 9:30 AM (EDT) - Friday, December 9, 2016 @ 10:45 AM (EST)"
# date = "Thu 10/20/16 - Fri 10/21/16 at 7pm\nSat 10/22/16 at 4pm and 8pm\nSun 10/23/16 at 2pm and 5pm"
# date = "date"=>"05/01/15 - 12/31/16 8:00pm to 12:00am"
# date = "date"=>"Fri 11/4/16 - Sat 1/7/17"
#date = "October 31 & November 1, 2014:"