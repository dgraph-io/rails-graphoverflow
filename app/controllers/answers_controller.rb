require 'dgraph_client'

class AnswersController < ApplicationController
  def create
    today = Date.today.to_datetime.rfc3339

    question_id = params[:answer][:question_id]
    answer_body = params[:answer][:"answer.body"]
    query = %Q(
mutation {
  set {
    <#{question_id}> <answer> <_:answer> .
    <_:answer> <answer.body> "#{answer_body}" .
    <_:answer> <answer.written_by> <u1> .
    <_:answer> <answer.created_at> "#{today}"^^<xs:dateTime> .
  }
}
)
    client = ::DgraphClient.new()
    json = client.do(query)

    respond_to do |format|
      format.html { redirect_to controller: 'questions', action: 'show', id: question_id }
    end
  end

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
      format.html { redirect_to controller: 'questions', action: 'show', id: params[:question_id] }
    end
  end
end
