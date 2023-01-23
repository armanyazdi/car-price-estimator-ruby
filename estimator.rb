# frozen_string_literal: true

require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'date'

# This method formats prices with commas.
def fmt(num)
  number = num.to_s.chars.to_a.reverse.each_slice(3)
  number.map(&:join).join(',').reverse
end

# This method converts Gregorian date to Jalali.
def jalali(gy, gm, gd)
  g_d_m = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
  gy2 = gm > 2 ? gy + 1 : gy
  days = 355_666 + (365 * gy) + Integer((gy2 + 3) / 4) - Integer((gy2 + 99) / 100) + Integer((gy2 + 399) / 400) + gd + g_d_m[gm - 1]
  jy = -1595 + (33 * Integer(days / 12_053))
  days %= 12_053
  jy += 4 * Integer(days / 1461)
  days %= 1461
  if days > 365
    jy += Integer((days - 1) / 365)
    days = (days - 1) % 365
  end
  if days < 186
    jm = 1 + Integer(days / 31)
    jd = 1 + (days % 31)
  else
    jm = 7 + Integer((days - 186) / 30)
    jd = 1 + ((days - 186) % 30)
  end
  [jy, jm, jd]
end

# This method generates divider lines.
def line(num)
  puts '-' * num
end

# Example: 'Peugeot 207' or 'renault tondar90'
print 'Car Model: '
model = gets.chomp.strip.downcase
model.gsub!(/\s/, '-') if model.include? ' '
line(25)

# Example : 'manual' or 'automatic'
puts "1) Manual\n2) Automatic"
print 'Car Gearbox: '
gearbox = gets.chomp.strip.downcase
gearbox = 'manual' if (gearbox == 1) || (gearbox == 'manual')
gearbox = 'automatic' if (gearbox == 2) || (gearbox == 'automatic')
line(25)

# Example: 1400
print 'Car Build Year: '
year = gets.chomp
line(25)

# Example : 10000
print 'Car Mileage (km): '
mileage = gets.chomp
line(25)

# Example : 'white' or 'black'
print 'Car Color: '
color = gets.chomp.strip.downcase
line(25)

puts '0) No Paint'
puts '1) One Paint'
puts '2) Two Paint'
puts '3) Multi Paint'
puts '4) Around Paint'
puts '5) Full Paint'
puts '6) Refinement'
print 'Car Body Status: '
status = gets.chomp
status = 'no_paint' if status == 0
status = 'one_paint' if status == 1
status = 'two_paint' if status == 2
status = 'multi_paint' if status == 3
status = 'around_paint' if status == 4
status = 'full_paint' if status == 5
status = 'refinement' if status == 6
line(25)

puts '0) No Replacements'
puts '1) Fender Replaced'
puts '2) Hood Replaced'
puts '3) Door Replaced'
print 'Car Body Replacements: '
replace = gets.chomp
replace = '' if status == 0
replace = ',fender_replace' if replace == 1
replace = ',hood_replace' if replace == 2
replace = ',door_replace' if replace == 3
line(25)

puts 'Estimating Price ...'

date = jalali(Date.today.year, Date.today.month, Date.today.day)
today = "#{date[0]}/#{date[1]}/#{date[2]}"
uri = URI.open("https://bama.ir/car/#{model}-y#{year}?mileage=#{mileage}&priced=1&seller=1&transmission=#{gearbox}&color=#{color}&status=#{status}#{replace}&sort=7")
doc = Nokogiri.HTML5(uri)
price = doc.css('span.bama-ad__price')[0].text.strip.gsub!(/[\s,]/, '').to_i

puts "\nPrice: #{fmt(price)} - #{fmt(Integer(price + price * 0.02))} Toman on #{today}"
