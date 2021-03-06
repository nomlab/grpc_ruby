this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(File.dirname(this_dir), 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'msg_broker_services_pb'

class MakeSendData
  def initialize(count, datasize)
    @count = count
    @senddata = []
    (0 ... @count).each do |num|
      message = makepaket(datasize)

      length = message.length
      command = 1
      dest = num
      
      @senddata.push Msg::SendData.new(length: length,
                                       command: command,
                                       dest: dest,
                                       message: message,
                                       T_1: 1,
                                       T_2: 2,
                                       T_3: 3,
                                       T_4: 4)
    end
  end

  def makepaket(size)
    count = size * 1024
    data = "#{size}kBdata".ljust(count, "*")
    return data
  end
  
  def each
    return enum_for(:each) unless block_given?
    @senddata.each do |data|
      data.T_1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      yield  data
    end
  end
end


def main()
  count = ARGV.size > 0 ?  ARGV[0].to_i : 10
  datasize = ARGV.size > 1 ?  ARGV[1].to_i : 1
  hostname = 'localhost:50051'
  stub = Msg::Frame::Stub.new(hostname, :this_channel_is_insecure)

  senddata = MakeSendData.new(count,datasize)

  response = stub.send_msg(senddata.each)
end

main
