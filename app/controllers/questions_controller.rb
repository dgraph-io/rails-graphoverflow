require 'dgraph_client'

class QuestionsController < ApplicationController
  def index
    query = %q(
{
  questions(func: gt(count(question_body), 0)) {
    question_body
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
    question_body
  }
}
)

    client = ::DgraphClient.new()
    json = client.do(query)

    puts json

    @question = json[:question][0]
  end

  def new
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
    respond_to do |format|
      if @question.update(question_params)
        format.html { redirect_to @question, notice: 'Question was successfully updated.' }
        format.json { render :show, status: :ok, location: @question }
      else
        format.html { render :edit }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to questions_url, notice: 'Question was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      params.fetch(:question, {})
    end
end
