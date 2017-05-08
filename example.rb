require './cluster'

if ARGV.length != 2
    startup_nodes = [
        {:host => "10.0.2.4", :port => 7000},
        {:host => "10.0.2.5", :port => 7000},
        {:host => "10.0.2.6", :port => 7000}
    ]
else
    startup_nodes = [
        {:host => ARGV[0], :port => ARGV[1].to_i}
    ]
end

rc = RedisCluster.new(startup_nodes,32,:timeout => 0.1)

last = false

while not last
    begin
        last = rc.get("__last__")
        last = 0 if !last
    rescue => e
        puts "error #{e.to_s}"
        sleep 1
    end
end

((last.to_i+1)..1000000000).each{|x|
    begin
        rc.set("foo#{x}",x)
        puts rc.get("foo#{x}")
        rc.set("__last__",x)
    rescue => e
        puts "error #{e.to_s}"
    end
    sleep 0.1
}
