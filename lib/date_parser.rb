require "date_parser/version"
require 'date'
require 'time'

module DateParser
  	def test_date_engine_for 
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
		date = "October 31 & November 1, 2014:"
		p date
		p parse_date_from(date)
	end

	def self.check_year_for datetime
		year = datetime.match(/\/(?=[^\/]*$)[0-9][0-9]/).to_s.gsub("/","")
		if year.length <= 2
			year = Time.now.strftime("%C") + year 
			datetime = datetime.sub(/\/(?=[^\/]*$)[0-9][0-9]/, "/#{year}")
		end
		datetime
	end

	def self.parse_date_from date, timezone = "America/New_York"
		start_date  = nil
		end_date    = nil
		starting_at = nil
		ending_at   = nil
		
		Time.zone = timezone
		time_parser = Time.zone

		begin 

			datetime = date
			start_date_text = datetime if datetime.present?
			datetime = datetime.gsub(/\n.*|Date:|Dates Unconfirmed/,"") if datetime.present?
			time = nil

			time_array = false
			time_array = true if time.class == Array
			
			time = time.gsub(/\n.*/,"") if !time_array && time.present?
			if datetime.present?
				undesired_text = datetime.match(/(.*)(AM|am|pm|PM)(.*)?/).to_a.last
				datetime = datetime.gsub(undesired_text,"").strip if undesired_text.present?
				if datetime.match(/[a-zA-Z].*?(\s|)([0-9]|[0-9]{2})(\s|)&(\s|)([0-9]|[0-9]{2}),(\s|)[0-9]{4}/).present?
					start_date = time_parser.parse(datetime.gsub(/&.*?,/,",").gsub(":",""))
					end_date   = time_parser.parse(datetime.gsub(/([0-9]|[0-9]{2}).*?&/,"").gsub(":",""))
				elsif datetime.match(/[a-zA-Z].*?(\s|)([0-9]|[0-9]{2})(\s|)\p{Pd}(\s|)([0-9]|[0-9]{2}),(\s|)[0-9]{4}/).present?
					start_date = time_parser.parse(datetime.gsub(/\p{Pd}.*?,/,",").gsub(":",""))
					end_date   = time_parser.parse(datetime.gsub(/([0-9]|[0-9]{2}).*?\p{Pd}/,"").gsub(":",""))
				elsif datetime.match(/[a-zA-Z].*?(\s|)([0-9]|[0-9]{2})\/([0-9]|[0-9]{2})\/([0-9]{2})(\s|)\p{Pd}(\s|)[a-zA-Z].*?(\s|)([0-9]|[0-9]{2})\/([0-9]|[0-9]{2})\/[0-9]{2}/)
					starting_at = self.check_year_for(datetime.gsub(/\p{Pd}.*/,"").gsub(":","").strip)
					start_date = time_parser.parse(starting_at)
					ending_at  = self.check_year_for(datetime.gsub(/.*?\p{Pd}/,"").gsub(":","").strip)
					end_date   = time_parser.parse(ending_at)
				elsif datetime.match(/[a-zA-Z].*?(\s|)([0-9]|[0-9]{2})(\s|)(\p{Pd}|&)(\s|)[a-zA-z].*?(\s|)([0-9]|[0-9]{2}),(\s|)[0-9]{4}/)
					starting_at = datetime.gsub(/(\p{Pd}|&).*?,/,",").gsub(/\(.*\)|:/,"").strip
					start_date = time_parser.parse(starting_at)
					ending_at  = datetime.gsub(/.*?(\p{Pd}|&)|\(.*\)|:/,"").strip
					end_date   = time_parser.parse(ending_at)
				elsif datetime.match(/[a-zA-Z].*?(\s|)([0-9]|[0-9]{2})(\s|)-(\s|)[a-zA-Z].*?([0-9]|[0-9]{2}),(\s|)[0-9]{4}/)
					start_date = time_parser.parse(datetime.gsub(/-.*?,/,",").gsub(":",""))
					end_date   = time_parser.parse(datetime.gsub(/.*?-/,"").gsub(":",""))
				elsif datetime.match(/[a-zA-z].*([0-9]|[0-9]{2})\/[0-9]{2}\/[0-9]{2}(\s|)-(\s|)[a-zA-z].*([0-9]|[0-9]{2})\/[0-9]{2}\/[0-9]{2}/)
					dates = datetime.match(/[a-zA-z].*([0-9]|[0-9]{2})\/[0-9]{2}\/[0-9]{2}(\s|)-(\s|)[a-zA-z].*([0-9]|[0-9]{2})\/[0-9]{2}\/[0-9]{2}/).to_s
					invalid_dates = dates.split("-")
					valid_dates = []
					invalid_dates.each do |date_text|	
						year = date_text.match(/\/(?=[^\/]*$)[0-9][0-9]/).to_s.gsub("/","")
						if year.length <= 2
							year = Time.now.strftime("%C") + year 
							valid_dates.push(date_text.sub(/\/(?=[^\/]*$)[0-9][0-9]/, "/#{year}"))
						end
					end
					start_date = time_parser.parse(valid_dates.first)
					end_date   = time_parser.parse(valid_dates.last)
					time = datetime.split("at").last if datetime.match(/at/)
				elsif datetime.match(/all-day/).present?
					datetime = datetime.gsub(/all-day/,"")
					if datetime.match(/\s\p{Pd}\s/)
						dates = datetime.split(/\s\p{Pd}\s/)
						start_date = time_parser.parse(dates.first)
						end_date = time_parser.parse(dates.last)
					else
						start_date = time_parser.parse(datetime)
					end
				elsif datetime.match(/(\s|)through.*?\s/).present?
					dates = datetime.split(/(\s|)through.*?\s/)
					start_date = time_parser.parse(dates.first)
					end_date = time_parser.parse(dates.last)
				elsif datetime.match("from").present? && datetime.match("to").present?
					dates = datetime.split(/\sfrom\s/)
					start_date = time_parser.parse(dates.first)
					time = dates.last
				elsif datetime.match(/\//).present?
					if datetime.match(/\s-\s/)
						dates = datetime.split(" ", 2)
						datetime = dates.first
						if dates.last.match(/\//)
							last_text = dates.last.sub(/-/,"").strip
							if last_text.present?
								last_text = last_text.split(" ", 2)
								end_date_text = last_text.first
								time = last_text.last
							end
						else
							time = dates.last
						end
					elsif datetime.match(/\sto\s/)
						dates = datetime.split(/\sto\s/)
						datetime = dates.first
						end_date_text = dates.last
					end
					datetime = self.check_year_for(datetime)
					start_date = time_parser.parse(datetime)
					if end_date_text.present?
						year = end_date_text.match(/\/(?=[^\/]*$)[0-9][0-9]/).to_s.gsub("/","")
						if year.length <= 2
							year = Time.now.strftime("%C") + year 
							end_date_text = end_date_text.sub(/\/(?=[^\/]*$)[0-9][0-9]/, "/#{year}")
						end
						end_date = time_parser.parse(end_date_text)
					end
				elsif datetime.match(/\s-\s/)
					dates = datetime.split(/\s-\s/)
					start_date = time_parser.parse(dates.first)
					end_date = time_parser.parse(dates.last)
				elsif datetime.match(/[0-9]/)
					datetime = datetime.gsub('Dates Unconfirmed',"")
					begin
						start_date = time_parser.parse(datetime)
					rescue => e
						p "#####################################################################################################"
						p "Unable to parse Date(Time) Format. Please check and fix the issue."
						p "#####################################################################################################"
					end
				end

				begin
					if !time_array && time.present? && time.match(/am|pm/i) && !time.match(",")
						if time.match(/\s-\s/) || time.match(/\sto\s/)
							times = time.split(/\s-\s/) if time.match(/\s-\s/).present?
							times = time.split(/\sto\s/) if time.match(/\sto\s/).present?
							starting_at = (start_date + time_parser.parse(times.first).seconds_since_midnight.seconds)
							if end_date.present?
								ending_at   = (end_date + time_parser.parse(times.last).seconds_since_midnight.seconds)
							else
								ending_at   = (start_date + time_parser.parse(times.last).seconds_since_midnight.seconds)	
							end
						elsif time.match(/.*-.*pm/) || time.match(/.*-.*am/) || time.match(/-/)
							times = time.split(/-/)
							starting_at = times.first
							ending_at = times.last 
							starting_at = times.first + ending_at.gsub(/[0-9]|:/,'') unless starting_at.match(/am|pm/i)
							starting_at = (start_date + time_parser.parse(starting_at).seconds_since_midnight.seconds)
							if end_date.present?
								end_date  = (end_date + time_parser.parse(ending_at).seconds_since_midnight.seconds)
								ending_at = nil
							else
								ending_at = (start_date + time_parser.parse(ending_at).seconds_since_midnight.seconds)
							end	
						else
							starting_at = (start_date + time_parser.parse(time).seconds_since_midnight.seconds)
						end
						start_date = starting_at if starting_at
						end_date = ending_at if ending_at
					end
				rescue => e
					p "#####################################################################################################"
					p e
					# exception_msg["date_engine"] = "Unable to parse Date(Time) Format. i.e. #{time}"
					p "Unable to parse Date(Time) Format. Please check and fix the issue."
					p "#####################################################################################################"
				end
			end

			start_date = start_date.utc if start_date.present?
			end_date   = end_date.utc if end_date.present?
		rescue => e
			p "#####################################################################################################"
			p "Unable to parse Date(Time) Format. Please check and fix the issue. #{e}"
			p "#####################################################################################################"
		end
		
		{
			time: time,
			start_date: start_date, 
			end_date: end_date, 
		}
	end
end
