require 'sinatra'
require 'sinatra/json'
require 'json'
require 'sequel'

set :protection, except: :json_csrf



### Model
DB = Sequel.sqlite 'db/data.db'
memos = DB[:memos]

unless DB.table_exists? :memos
  DB.create_table :memos do
    primary_key :id
    String :content
  end

  [<<-A, <<-B].each { |content| memos.insert content: content }
Hello, World!\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Cras in bibendum lorem. In viverra erat ipsum, id pretium urna vehicula ut. Proin vel quam ultricies, placerat urna ut, accumsan leo. Vivamus laoreet vestibulum nulla non dictum. Vestibulum non nisl quis risus dictum vestibulum hendrerit ut diam. Sed eget laoreet augue. Integer pulvinar massa scelerisque rhoncus consequat. Vivamus velit mi, suscipit bibendum tincidunt quis, pulvinar a ante.
  A
"Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit..."
  B
end



### Controller
get '/memos' do
  json memos.all.reverse
end

post '/memos' do
  request.body.rewind
  content = JSON.parse(request.body.read)['content']

  # No empty memo
  return 400 if !content || content.empty?

  json memos.insert content: content
end

put '/memos/:id' do |id|
  request.body.rewind
  content = JSON.parse(request.body.read)['content']

  memos.where(id: id).update content: content
  200
end

delete '/memos/:id' do |id|
  memos.where(id: id).delete
  200
end



# (development mode only)
get '/' do
  File.read('public/index.html')
end
