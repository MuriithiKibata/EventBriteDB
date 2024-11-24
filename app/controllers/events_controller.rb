class EventsController < ApplicationController
  before_action :set_event, only: %i[ show update destroy ]

  # GET /events
  def index
    @events = Event.all

    render json: @events
  end

  # GET /events/1
  def show
    render json: @event.as_json(include: :tickets)
  end

  # POST /events
  def create
    @event = Event.new(event_params)

    if @event.save
      render json: @event, status: :created, location: @event
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /events/1
  def update
    if @event.update(event_params)
      render json: @event
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy!
  end

  # Handle ticket purchase
  def purchase_ticket
    @event = Event.find(params[:id])

    if @event.available_tickets && @event.available_tickets > 0
      ticket = @event.tickets.new(ticket_params)

      if ticket.save
        @event.update(available_tickets: @event.available_tickets - tickets.quantity)
        render json: ticket, status: :created
      else
        render json: ticket.errors, status: :unprocessable_entity
      end
    else
      render json: { error: "No tickets available" }, status: :unprocessable_entity
    end
  end

  def payment_confirmation
    Rails.logger.info "Received payment confirmation for CheckoutRequestID: #{params[:checkoutRequestID]}"
    
    # Find the ticket using the CheckoutRequestID
    ticket = Ticket.find_by(checkout_request_id: params[:checkoutRequestID])

    if ticket.nil?
      Rails.logger.warn "No ticket found for CheckoutRequestID: #{params[:checkoutRequestID]}"
      render json: { error: "No ticket found for the provided CheckoutRequestID" }, status: :not_found
      return
    end

    # Update the payment status of the ticket
    ticket.update(payment_status: true)
    Rails.logger.info "Payment confirmed for ticket with CheckoutRequestID: #{params[:checkoutRequestID]}"

    render json: { success: "Payment confirmed successfully" }, status: :ok
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def event_params
      params.require(:event).permit(
        :name,
        :event_date,
        :venue,
        :description,
        :ticket_price,
        :available_tickets
      )
    end

    # ticket params coming from event
    def ticket_params
      params.require(:ticket).permit(
        :first_name,
        :last_name,
        :email,
        :quantity,
        :price,
        :ticket_type,
        :payment_type,
        :phone_number
      )
    end
end
