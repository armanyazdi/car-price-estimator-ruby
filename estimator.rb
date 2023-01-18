# frozen_string_literal: true

require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'date'

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

# This method formats numbers with commas.
def format(num)
  number = num.to_s.chars.to_a.reverse.each_slice(3)
  number.map(&:join).join(',').reverse
end

print 'Car model: '
model = gets.chomp    # Example: 'Peugeot 207' or 'renault tondar90'
model[' '] = '-'

print 'Car gearbox: '
gearbox = gets.chomp  # Example : 'manual' or 'automatic'

print 'Car build year: '
year = gets.chomp     # Example: 1400

print 'Car mileage (km): '
mileage = gets.chomp  # Example : 10000

print 'Car color: '
color = gets.chomp    # Example : white

date = jalali(Date.today.year, Date.today.month, Date.today.day)
today = "#{date[0]}/#{date[1]}/#{date[2]}"

uri = URI.open("https://bama.ir/car/#{model}-y#{year}?mileage=#{mileage}&priced=1&seller=1&transmission=#{gearbox}&color=#{color}&sort=7")
doc = Nokogiri.HTML5(uri)
price = doc.css('span.bama-ad__price')[0].text.strip.gsub(/[\s,]/, '').to_i

puts "Price: #{format(price)} - #{format((price + price * 0.02).to_i)} Toman on #{today}"
