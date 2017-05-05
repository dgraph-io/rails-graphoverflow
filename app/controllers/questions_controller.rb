require 'dgraph_client'

class QuestionsController < ApplicationController
  before_action :set_question, only: [:edit]

  def index
    query = %q(
{
  questions(func: gt(count(question_body), 0), first: 20) {
    _uid_
    question_body
    question_title
  }
}
)
    client = ::DgraphClient.new()
    json = client.do(query)

    @questions = json.fetch(:questions, [])
  end

  def show
    query = %Q(
{
  question(id:#{params[:id]}) {
    _uid_
    question_body
    question_title
    answer(first: 10) @filter(gt(count(answer_body), 0)) {
      _uid_
      answer_body
    }
  }
}
)

    client = ::DgraphClient.new()
    json = client.do(query)

    puts json

    @question = json[:question][0]
    @answers = @question.fetch(:answer, [])
  end

  def new
    @question = {}
  end

  def edit
  end

  def create
    query = %Q(
mutation {
  set {
    <_:question> <question_body> "#{params[:question][:question_body]}" .
    <_:question> <question_title> "#{params[:question][:question_title]}" .
  }
}
)
    client = ::DgraphClient.new()
    json = client.do(query)

    question_id = json[:uids][:question]
    respond_to do |format|
      format.html { redirect_to action: 'show', id: question_id }
    end
  end

  def update
    question_id = params[:id]
    query = %Q(
mutation {
  set {
    <#{question_id}> <question_body> "#{params[:question][:question_body]}" .
    <#{question_id}> <question_title> "#{params[:question][:question_title]}" .
  }
}
)

    client = ::DgraphClient.new()
    client.do(query)

    respond_to do |format|
      format.html { redirect_to action: 'show', id: question_id }
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
      format.html { redirect_to action: 'index' }
    end
  end

  private

  def set_question
    query = %Q(
{
  question(id:#{params[:id]}) {
    _uid_
    question_body
    question_title
  }
}
)

    client = ::DgraphClient.new()
    json = client.do(query)

    @question = json[:question][0]
  end
end
