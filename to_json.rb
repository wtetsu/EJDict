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





all_data = load_files()
all_keys = all_data.keys().sort {|w1, w2| w1.casecmp(w2)}

SPLIT.times {|i|
   new_data = generate_data(all_data, all_keys, i, SPLIT)
   new_json = JSON.pretty_generate(new_data)

   out_file_content = []
   out_file_content.push("// Base on ejdict-hand")
   new_json.each_line {|line|
    out_file_content.push(line.strip)
   }
   out_file_content.push("")

   File.write("json/initial_dict#{i+1}.json", out_file_content.join("\n"))
}


