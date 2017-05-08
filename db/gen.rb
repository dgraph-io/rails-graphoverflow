require 'faker'

num_users = 100
num_questions = 20
num_answers = 200

user_xids = Array.new(num_users) { |i| "u#{i+1}" }
question_xids = Array.new(num_questions) { |i| "q#{i+1}" }
answer_xids = Array.new(num_answers) { |i| "a#{i+1}" }

schema = %Q{
  schema {
    question.title: string .
    question.body: string .
    question.written_by: uid @reverse .

    answer: uid @reverse .
    answer.title: string .
    answer.written_by: uid @reverse .
    answer.upvoted_by: uid @reverse .

    viewee: uid @reverse .
    viewer: uid @reverse .
  }
}

set = "set {\n"

question_xids.map { |xid|
  "    <#{xid}> <question.title> \"#{Faker::Lorem.sentence(1)}\" .
    <#{xid}> <question.body> \"#{Faker::Lorem.paragraph(20)}\" .
    <#{xid}> <question.written_by> <#{user_xids.sample()}> .
"}.each do |line|
  set += line
end

answer_xids.map { |xid|
  "    <#{question_xids.sample()}> <answer> <#{xid}> .
    <#{xid}> <answer.body> \"#{Faker::Lorem.paragraph(20)}\" .
    <#{xid}> <answer.written_by> <#{user_xids.sample()}> .
"}.each do |line|
  set += line
end

user_xids.map { |xid|
  "    <#{xid}> <user_name> \"#{Faker::Name.name}\" .
    <#{xid}> <answer.upvoted_by> <#{answer_xids.sample()}> .
    <#{xid}> <answer.upvoted_by> <#{answer_xids.sample()}> .
    <#{xid}> <answer.upvoted_by> <#{answer_xids.sample()}> .
    <#{xid}> <answer.upvoted_by> <#{answer_xids.sample()}> .
    <#{xid}> <answer.upvoted_by> <#{answer_xids.sample()}> .
    <#{xid}> <answer.upvoted_by> <#{answer_xids.sample()}> .
    <#{xid}> <answer.upvoted_by> <#{answer_xids.sample()}> .
"}.each do |line|
  set += line
end

set += '}'

query = %Q(
mutation {
  #{schema}

  #{set}
}
)

puts query
