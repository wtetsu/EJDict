require "json"



SPLIT = 2

def load_files()
  dict = {}
  Dir["src/*.txt"].each {|file_path|
    IO.foreach(file_path, encoding:"utf-8") {|raw_line|
      line = raw_line.strip
  
      heads, desk = line.split("\t")
  
      heads.split(",").each {|raw_head|
        head = raw_head.strip
        if dict[head].nil?
          dict[head] = []
        end
  
        dict[head].push(desk)
      }
      
    }
  }
  result = {}
  dict.each {|k, v|
    result[k] = v.join("\n")
  }
  return result
end

def generate_data(dict, keys,  seq, total)
  result = {}


  from =( (keys.length * 1.0 / total) * seq).floor
  to =( (keys.length * 1.0/ total) * (seq+1) - 1).floor

  # puts "#{from}, #{to} (#{keys.length})"

  from.upto(to) {|i|
    key = keys[i]
    result[key] = dict[key]
  }

  return result
end

def is_upper(s)
  return s >= "A" && s <= "Z"
end

def is_lower(s)
  return s >= "a" && s <= "z"
end

def compare(a, b)
  if is_lower(a) && is_lower(b)|| is_upper(a) && is_upper(b)
    return a <=> b
  end
  if is_lower(a) && is_upper(b)
    return -1
  end
  if is_upper(a) && is_lower(b)
    return 1
  end
  return a <=> b
end


all_data = load_files()
# all_keys = all_data.keys().sort {|w1, w2| w1.casecmp(w2)}
all_keys = all_data.keys().sort {|w1, w2| compare(w1, w2) }

out_data = {}

all_keys.each{|key|
  first_char = key[0].downcase
  if !(first_char >= "a" && first_char <= "z")
    first_char = "_"
  end

  if out_data[first_char].nil?
    out_data[first_char] = {}
  end

  out_data[first_char][key] = all_data[key]
}


header = <<EOS
/**
 * Mouse Dictionary (https://github.com/wtetsu/mouse-dictionary/)
 * Copyright 2018-present wtetsu
 * Licensed under MIT
 *
 * This data is based on ejdict-hand
 * https://github.com/kujirahand/EJDict
 */
EOS



out_data.each{|k, v|
  out_file = "out/#{k}.json5"
  puts out_file
  new_json = JSON.pretty_generate(v)

  File.open(out_file, "wb") {|file|
    file.puts(header.gsub("\r\n", "\n"))
    file.puts(new_json.gsub("\r\n", "\n").sub("\"\n", "\",\n"))
  }
}


# SPLIT.times {|i|
#    new_data = generate_data(all_data, all_keys, i, SPLIT)
#    new_json = JSON.pretty_generate(new_data)

#    out_file_content = []
#    out_file_content.push("// Base on ejdict-hand")
#    new_json.each_line {|line|
#     out_file_content.push(line.strip)
#    }
#    out_file_content.push("")

#    File.write("json/initial_dict#{i+1}.json", out_file_content.join("\n"))
# }


