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
    answer_count: count(answer)
  }
}
)
    client = ::DgraphClient.new()
    json = client.do(query)

    puts json

    @questions = json.fetch(:questions, [])
  end

  def show
    question_id = params[:id]
    record_view(user_id: "u1", question_id: question_id)
    query = %Q(
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
      upvote_count: count(answer.upvoted_by)
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

  # get_current_viewcount gets the current view count of the user for the question
  def get_current_viewcount(params)
    user_id = params[:user_id]
    question_id = params[:question_id]

    query = %Q(
{
  vid as var(id: #{question_id})

  me(id: #{user_id}) @cascade {
    user.view  {
      _uid_
      view.count
      view.question @filter(var (vid))
    }
  }
}
)

    client = ::DgraphClient.new()
    json = client.do(query)

    if json[:me]
      return {
        :_uid_ => json[:me][0][:'user.view'][0][:_uid_],
        :'view.count' => json[:me][0][:'user.view'][0][:'view.count']
      }
    else
      return 0
    end
  end

  def create_view(params)
    user_id = params[:user_id]
    question_id = params[:question_id]

    query = %Q(
mutation {
  set {
    <_:v> <view.count> "0" .
    <_:v> <view.question> <#{question_id}> .
    <#{user_id}> <user.view> <_:v> .
  }
}
)

    client = ::DgraphClient.new()
    client.do(query)
  end

  def increment_view(params, current_viewcount)
    user_id = params[:user_id]
    question_id = params[:question_id]

    query = %Q(
mutation {
  set {
    <#{current_viewcount[:_uid_]}> <view.count> "#{current_viewcount[:'view.count'] + 1}" .
  }
}
)

    client = ::DgraphClient.new()
    client.do(query)
  end

  # record_view either creates a view or increments the  view.count of an existing
  # view
  def record_view(params)
    user_id = params[:user_id]
    question_id = params[:question_id]

    current_viewcount = get_current_viewcount(params)
    puts current_viewcount

    if current_viewcount == 0
      create_view(params)
    else
      increment_view(params, current_viewcount)
    end
  end
end
