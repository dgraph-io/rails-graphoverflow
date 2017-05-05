class UpvotesController < ApplicationController
  def create
    answer_id = params[:answer_id]
    query = %Q(
mutation {
  set {
    <u1> <upvoted> <#{answer_id}> .
  }
}

{
  answer(id: #{answer_id}) {
    question: ~answer {
      _uid_
    }
  }
}
)
    client = ::DgraphClient.new()
    json = client.do(query)

    question_id = json[:answer][0][:question][0][:_uid_]

    respond_to do |format|
      format.html { redirect_to controller: 'questions', action: 'show', id: question_id }
    end
  end

  def destroy
    @upvote.destroy
    respond_to do |format|
      format.html { redirect_to upvotes_url, notice: 'Upvote was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
end
