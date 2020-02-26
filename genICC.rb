require 'Datavyu_API.rb'
require "csv"

def format_icc(directory, outFile, col1, col2, argval = nil, argindex = nil)  # If you want to select certain cells, input argument value and its index

    #chmod 755 outFile

    tot_pri_icc = Array.new
    tot_rel_icc = Array.new

    filenames = Dir.new(directory).entries

    for file in filenames
        if (file.include?(".opf")) and file[0].chr != '.'

            $db,pj = load_db(directory + "/" + file)
            puts "\nLoading " + file.to_s + "...\n"

            pri = getColumn(col1)
            rel = getColumn(col2)
            
            pri_arr = Array.new
            rel_arr = Array.new

            pri_icc = Array.new
            rel_icc = Array.new

            for pri_cell in pri.cells
                if (argval != nil) and (argindex != nil)
                    if (pri_cell.argvals[argindex] == argval)
                        puts pri_cell.argvals[argindex]
                        pri_arr << [pri_cell.onset, pri_cell.offset]
                    end
                else
                    pri_arr << [pri_cell.onset, pri_cell.offset]
                end
            end 

            for rel_cell in rel.cells
                if (argval != nil) and (argindex != nil)
                    if (rel_cell.argvals[argindex] == argval)
                        rel_arr << [rel_cell.onset, rel_cell.offset]
                    end
                else
                    rel_arr << [rel_cell.onset, rel_cell.offset]
                end
            end

            if (pri_arr.length >= rel_arr.length)
                for pri_times in pri_arr
                    i = false
                    pri_icc << ((pri_times[1] - pri_times[0])/1000.0)
                    for rel_times in rel_arr
                        if ((pri_times[0] - rel_times[0]).abs <= 5000) and ((pri_times[1] - rel_times[1]).abs <= 5000)
                            rel_icc << ((rel_times[1] - rel_times[0])/1000.0)
                            rel_arr = rel_arr - [rel_times]
                            i = true
                            break
                        end
                    end
                    if (i == false)
                        rel_icc << 0
                    end
                end
            end
              
            if (pri_arr.length < rel_arr.length)
                for rel_times in rel_arr
                    i = false
                    rel_icc << ((rel_times[1] - rel_times[0])/1000.0)
                    for pri_times in pri_arr
                        if ((rel_times[0] - pri_times[0]).abs <= 5000) and ((rel_times[1] - rel_times[0]).abs <= 5000)
                            pri_icc << ((pri_times[1] - pri_times[0])/1000.0)
                            pri_arr = pri_arr - [pri_times]
                            i = true
                            break
                        end
                    end
                    if (i == false)
                        pri_icc << 0
                    end
                end
            end

            if (pri_icc.length != rel_icc.length)
                raise "Error" 
            end

            for dur in pri_icc
                tot_pri_icc << dur
            end
            
            for dur in rel_icc
                tot_rel_icc << dur
            end

        end


        puts tot_pri_icc
        #puts tot_rel_icc

        CSV.open(outFile, "w") do |csv|
            csv << tot_pri_icc
            csv << tot_rel_icc
        end
    end
end



filedir = File.expand_path("~/Desktop/kappafiles/")
csvString = "~/Desktop/newICC.csv"
csvFile = File.expand_path(csvString)

format_icc(filedir, csvFile, "eye_contact", "eye_contact_2")
#format_icc(filedir, csvFile, "speaker_listener", "speaker_listener_2", "L", 0)