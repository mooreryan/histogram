# Copyright 2017 Ryan Moore
# Contact: moorer@udel.edu
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see
# <http://www.gnu.org/licenses/>.

# VERSION 0.1.0

BAR_HEIGHT = ENV["HEIGHT"] ? ENV["HEIGHT"].to_f : 70.0
BAR_CHAR   = ENV["CHAR"] ? ENV["CHAR"] : "*"
STEP = ENV["STEP"] ? ENV["STEP"].to_i : 1

# scales [old_min, old_max] to [new_min, new_max]
def scale x, new_min=0.0, new_max=50.0, old_min=0.0, old_max=1.0
  ((((new_max - new_min) * (x - old_min.to_f)) / (old_max - old_min)) + new_min).floor
end


def count_to_bar min_count, max_count, count
  if max_count <= BAR_HEIGHT
    BAR_CHAR * count
  else
    height = scale(count, 0.0, BAR_HEIGHT, 0.0, max_count)

    if height < 0
      height = 0
      # exit
    end

    # always have at least one mark even if scaled height is zero

    # TODO for some wonky reason, height can be less than zero when
    # you scale from min_count to max_count. Changeing it to go from
    # 0.0 to max_count fixes this. maybe floating point arithmatic
    # problems?

    if height <= 0 && count > 0
      height = 1
    elsif height <= 0
      height = 0
    end

    BAR_CHAR * height
  end
end

counts = Hash.new 0
ARGF.each_with_index do |line, idx|
  STDERR.printf("READING -- %d\r", idx) if (idx % 100000).zero?
  counts[line.strip.chomp.to_i] += 1
end
STDERR.puts

max_item_len =
  counts.keys.map(&:to_s).
  sort_by { |item| item.length }.
  reverse.take(1).first.length

min_key = counts.keys.min
max_key = counts.keys.max

if STEP == 1
  max = counts.values.max
  min = counts.values.min
else
  cons_sums = counts.values.sort.each_cons(STEP).map do |ary|
    ary.reduce(:+)
  end

  min = cons_sums.min
  max = cons_sums.max
end

if (max - min).zero?
  abort "max - min == zero : #{max} - #{min} = 0"
end

running_count = 0
thing = 0
(min_key..max_key).each_with_index do |item, idx|
  thing = item
  running_count += counts[item]

  # in each bucket contains the number of items for this bucket down
  # to last printed bucket
  if (idx % STEP) == (STEP - 1) # need to print
    printf "%#{max_item_len}s %s\n", item, count_to_bar(min, max, running_count)
    running_count = 0
  end
end
printf "%#{max_item_len}s %s\n", thing, count_to_bar(min, max, running_count)
