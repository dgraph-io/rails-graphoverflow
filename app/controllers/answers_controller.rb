require 'dgraph_client'

class AnswersController < ApplicationController
#   def edit
#     query = %Q(
# {
#   answer(id:#{params[:id]}) {
#     _uid_
#     question_body
#     question_title
#   }
# }
# )
#
#     client = ::DgraphClient.new()
#     json = client.do(query)
#
#     @answer = json[:answer][0]
#   end

  def create
    question_id = params[:answer][:question_id]
    answer_body = params[:answer][:answer_body]
    query = %Q(
mutation {
  set {
    <#{question_id}> <answer> <_:answer> .
    <_:answer> <answer_body> "#{answer_body}" .
  }
}
)
    client = ::DgraphClient.new()
    json = client.do(query)
    answer_id = json[:uids][:answer]

    @answer = { answer_body: answer_body, _uid_: answer_id }

    respond_to do |format|
      format.js { }
    end
  end

#   def update
#     answer_id = params[:id]
#     query = %Q(
# mutation {
#   set {
#     <#{answer_id}> <answer_body> "#{params[:answer][:answer_body]}" .
#   }
# }
# )
#
#     client = ::DgraphClient.new()
#     client.do(query)
#
#     respond_to do |format|
#       format.js { }
#     end
#   end

  def destroy
    query = %Q(
mutation {
  delete {
    <#{params[:id]}> * * .
  }
}
)

    client = ::DgraphClient.new()
    json = client.do(query)

    respond_to do |format|
      format.html { redirect_to controller: 'questions', action: 'index' }
    end
  end
end
