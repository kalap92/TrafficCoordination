require_relative '../helpers/data_helper'
require_relative '../src/road'
require 'csv'
require 'pry'

unless ARGV[0] && ARGV[1] && ARGV[2]
  puts 'USAGE: ruby start_states_generator roads_file, cars_count, states_count'
  exit
end

cars_count = ARGV[1].to_i
states_count = ARGV[2].to_i

roads = roads_from_file(ARGV[0])
roads_attributes = roads[:attributes]
$roads_data = roads[:data]
$roads_data.map! { |ele| Road.new(roads_attributes, ele) }
$roads_size = $roads_data.size

def random_car_pos(car_nr, pos_taken)
  while true
    road_nr = rand(1..$roads_size)
    road_size = $roads_data[road_nr-1].state[:size]
    pos_taken[road_nr] = [] unless pos_taken[road_nr]
    break unless pos_taken[road_nr].size == road_size
  end

  while true
    pos = rand(1..road_size)
    if pos_taken[road_nr][pos].nil?
      pos_taken[road_nr][pos] = car_nr
      break
    end
  end
end

def save_cars_pos(pos_taken, file_nr)
  pos_hash = []
  pos_taken.each_with_index do |road, road_nr|
    next if road.nil? 

    road.each_with_index do |car_nr, pos|
      next if car_nr.nil?
      hash = {
        :car_nr => car_nr,
        :current_road_nr => road_nr,
        :postion => pos,
        :velocity => 0,
        :final_position => $roads_data[road_nr-1].state[:cuts].map { |ele| ele[:crossroad] }.max,
        :direction => 1
      } 
      pos_hash.push(hash)
    end
  end

  pos_hash.sort_by! { |ele| ele[:car_nr] }

  csv_string = CSV.generate do |csv|
    pos_hash.each do |hash|
      csv << hash.values
    end
  end

  csv_string = "car_nr,current_road_nr,position,velocity,final_position,direction\n" + csv_string

  file_name = 'generated/generated_cars_states_file' + file_nr.to_s

  File.open(file_name, 'w') { |file| file.write(csv_string) }
end

def randomate_and_save_cars_pos(cars_count, file_nr)
  pos_taken = []
  i = 0
  cars_count.times do
    i += 1
    random_car_pos(i, pos_taken)
  end

  save_cars_pos(pos_taken, file_nr)
end

def randomate_x_states(cars_count, states_count)
  file_nr = 0
  states_count.times do
    file_nr += 1
    randomate_and_save_cars_pos(cars_count, file_nr)
  end
end

randomate_x_states(cars_count, states_count)