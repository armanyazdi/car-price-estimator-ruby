# frozen_string_literal: true

require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'date'

# This method formats prices with commas.
def format(num)
  number = num.to_s.chars.to_a.reverse.each_slice(3)
  number.map(&:join).join(',').reverse
end

# This method converts Gregorian to Jalali date.
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

# Example: 'Peugeot 207' or 'renault tondar90'
print 'Car model: '
model = gets.chomp.downcase
model[' '] = '-' if model.include? ' '
puts '-------------------------'

# Example : 'manual' or 'automatic'
puts "1) Manual\n2) Automatic"
print 'Car gearbox: '
gearbox = gets.chomp.downcase
gearbox = 'manual' if (gearbox == 1) || (gearbox == 'manual')
gearbox = 'automatic' if (gearbox == 2) || (gearbox == 'automatic')
puts '-------------------------'

# Example: 1400
print 'Car build year: '
year = gets.chomp
puts '-------------------------'

# Example : 10000
print 'Car mileage (km): '
mileage = gets.chomp
puts '-------------------------'

# Example : 'white' or 'black'
print 'Car color: '
color = gets.chomp.downcase
puts '-------------------------'

puts "0) No Paint\n1) One Paint\n2) Two Paint\n3) Multi Paint\n4) Refinement"
print 'Paint status: '
paint = gets.chomp
paint = 'no_paint' if paint == 0
paint = 'one_paint' if paint == 1
paint = 'two_paint' if paint == 2
paint = 'multi_paint' if paint == 3
paint = 'refinement' if paint == 4
puts '-------------------------'

puts 'Estimating Price ...'

date = jalali(Date.today.year, Date.today.month, Date.today.day)
today = "#{date[0]}/#{date[1]}/#{date[2]}"
uri = URI.open("https://bama.ir/car/#{model}-y#{year}?mileage=#{mileage}&priced=1&seller=1&transmission=#{gearbox}&color=#{color}&status=#{paint}&sort=7")
doc = Nokogiri.HTML5(uri)
price = doc.css('span.bama-ad__price')[0].text.strip.gsub(/[\s,]/, '').to_i

puts "\nPrice: #{format(price)} - #{format(Integer(price + price * 0.02))} Toman on #{today}"
