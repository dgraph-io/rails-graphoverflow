require 'faker'
require 'date'

num_users = 100
num_questions = 20
num_answers = 200

user_xids = Array.new(num_users) { |i| "u#{i+1}" }
question_xids = Array.new(num_questions) { |i| "q#{i+1}" }
answer_xids = Array.new(num_answers) { |i| "a#{i+1}" }

question_tree = {}

schema = %Q{
  schema {
    question.title: string .
    question.body: string .
    question.written_by: uid @reverse .
    question.created_at: date .

    answer: uid @reverse .
    answer.title: string .
    answer.written_by: uid @reverse .
    answer.upvoted_by: uid @reverse .
    answer.created_at: date .

    user.view: uid @reverse .
    view.count: int .
    view.question: uid @reverse .
  }
}

view_counter = 0
set = "set {\n"

question_xids.map { |xid|
  created_at = (Date.today - rand(1..30)).to_datetime.rfc3339

  question_tree[xid] = []

  "    <#{xid}> <question.title> \"#{Faker::Lorem.sentence(1)}\" .
    <#{xid}> <question.body> \"#{Faker::Lorem.paragraph(20)}\" .
    <#{xid}> <question.written_by> <#{user_xids.sample()}> .
    <#{xid}> <question.created_at> \"#{created_at}\"^^<xs:dateTime> .
"}.each do |line|
  set += line
end


answer_xids.map { |xid|
  author_id = user_xids.sample()
  created_at = (Date.today - rand(1..90)).to_datetime.rfc3339
  question_id = question_xids.sample()
  vc = view_counter + 1
  view_counter = view_counter + 1

  question_tree[question_id].push(xid)

  "    <#{question_id}> <answer> <#{xid}> .
    <#{xid}> <answer.body> \"#{Faker::Lorem.paragraph(20)}\" .
    <#{xid}> <answer.written_by> <#{author_id}> .
    <#{xid}> <answer.created_at> \"#{created_at}\"^^<xs:dateTime> .
    <#{author_id}> <user.view> <v#{vc}> .
    <v#{vc}> <view.question> <#{question_id}> .
    <v#{vc}> <view.count> \"#{rand(1..3)}\" .
"}.each do |line|
  set += line
end

user_xids.map { |xid|
  question_ids = question_tree.keys.sample(3)
  vc1 = view_counter + 1
  vc2 = view_counter + 2
  vc3 = view_counter + 3
  view_counter = view_counter + 3


  "    <#{xid}> <user_name> \"#{Faker::Name.name}\" .
    <#{question_tree[question_ids[0]].sample()}> <answer.upvoted_by> <#{xid}> .
    <#{question_tree[question_ids[0]].sample()}> <answer.upvoted_by> <#{xid}> .
    <#{question_tree[question_ids[1]].sample()}> <answer.upvoted_by> <#{xid}> .
    <#{question_tree[question_ids[1]].sample()}> <answer.upvoted_by> <#{xid}> .
    <#{question_tree[question_ids[2]].sample()}> <answer.upvoted_by> <#{xid}> .
    <#{question_tree[question_ids[2]].sample()}> <answer.upvoted_by> <#{xid}> .

    <#{xid}> <user.view> <v#{vc1}> .
    <v#{vc1}> <view.question> <#{question_ids[0]}> .
    <v#{vc1}> <view.count> \"#{rand(1..3)}\" .
    <#{xid}> <user.view> <v#{vc2}> .
    <v#{vc2}> <view.question> <#{question_ids[1]}> .
    <v#{vc2}> <view.count> \"#{rand(1..3)}\" .
    <#{xid}> <user.view> <v#{vc3}> .
    <v#{vc3}> <view.question> <#{question_ids[2]}> .
    <v#{vc3}> <view.count> \"#{rand(1..3)}\" .
"}.each do |line|
  set += line
end

set += '  }'

query = %Q(
mutation {
  #{schema}

  #{set}
}
)

puts query
