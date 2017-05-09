require 'dgraph_client'

class QuestionsController < ApplicationController
  before_action :set_question, only: [:edit]

  def index
    query = %q(
{
  questions(func: gt(count(question.body), 0), first: 20) {
    _uid_
    question.body
    question.title
    question.created_at
    question.written_by {
      user_name
    }
  }
}
)
    client = ::DgraphClient.new()
    json = client.do(query)

    @questions = json.fetch(:questions, [])
  end

  def show
    question_id = params[:id]
    increment_view(user_id: "u1", question_id: question_id)
    query = %Q(
mutation {
  set {
    <_:view> <viewer> <u1> .
    <_:view> <viewee> <#{question_id}> .
  }
}

{
  user as var(id: u1)

  question(id: #{question_id}) {
    _uid_
    question.body
    question.title
    answer(first: 10) @filter(gt(count(answer.body), 0)) {
      _uid_
      answer.body
      answer.upvoted_by @filter(var(user)) {
        user_name
      }
      count(answer.upvoted_by)
    }
  }
}
)

    client = ::DgraphClient.new()
    json = client.do(query)

    @question = json[:question][0]
    @answers = @question.fetch(:answer, [])
  end

  def new
    @question = {}
  end

  def edit
  end

  def create
    today = Date.today.to_datetime.rfc3339
    query = %Q(
mutation {
  set {
    <_:question> <question.body> "#{params[:question][:"question.body"]}" .
    <_:question> <question.title> "#{params[:question][:"question.title"]}" .
    <_:question> <question.created_at> "#{today}"^^<xs:dateTime> .
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
    <#{question_id}> <question.body> "#{params[:question][:"question.body"]}" .
    <#{question_id}> <question.title> "#{params[:question][:"question.title"]}" .
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
    question.body
    question.title
  }
}
)

    client = ::DgraphClient.new()
    json = client.do(query)

    @question = json[:question][0]
  end

  def increment_view(params)
    user_id = params[:user_id]
    question_id = params[:question_id]

    query = %Q(
{
  me(id: #{user_id}) {
    user.view {
      view_count: view_count
    }
  }
}
    )
  end
end
