class Organizer::ParticipantsController < Organizer::ApplicationController
  respond_to :html, :json

  def create
    person = Person.where(email: params[:email]).first
    if person.nil?
      participant_invitation =
        @event.participant_invitations.build(participant_params.merge(email: params[:email]))

      if participant_invitation.save
        ParticipantInvitationMailer.create(participant_invitation).deliver
        flash[:info] = 'Participant invitation successfully sent.'
      else
        flash[:danger] = 'There was a problem creating your invitation.'
      end
    else
      participant = @event.participants.build(participant_params.merge(person: person))

      if participant.save
        flash[:info] = 'Your participant was added.'
      else
        flash[:danger] = "There was a problem saving your participant. Please try again"
      end
    end
    redirect_to organizer_event_path(@event)
  end

  def update
    participant = Participant.find(params[:id])
    participant.update(participant_params)

    flash[:info] = "You have successfully changed the role for your participant."
    redirect_to organizer_event_path(@event)
  end

  def destroy
    @event.participants.find(params[:id]).destroy

    flash[:info] = "Your participant has been deleted."
    redirect_to organizer_event_path(@event)
  end

  def emails
    emails = Person.where("email like ?",
                          "%#{params[:term]}%").order(:email).pluck(:email)
    respond_with emails.to_json, format: :json
  end

  private

  def participant_params
    params.require(:participant).permit(:role)
  end
end
