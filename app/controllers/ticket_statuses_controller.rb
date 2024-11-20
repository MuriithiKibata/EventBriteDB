class TicketStatusesController < ApplicationController
  before_action :set_ticket_status, only: %i[ show update destroy ]

  # GET /ticket_statuses
  def index
    @ticket_statuses = TicketStatus.all

    render json: @ticket_statuses
  end

  # GET /ticket_statuses/1
  def show
    render json: @ticket_status
  end

  # POST /ticket_statuses
  def create
    @ticket_status = TicketStatus.new(ticket_status_params)

    if @ticket_status.save
      render json: @ticket_status, status: :created, location: @ticket_status
    else
      render json: @ticket_status.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /ticket_statuses/1
  def update
    if @ticket_status.update(ticket_status_params)
      render json: @ticket_status
    else
      render json: @ticket_status.errors, status: :unprocessable_entity
    end
  end

  # DELETE /ticket_statuses/1
  def destroy
    @ticket_status.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ticket_status
      @ticket_status = TicketStatus.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def ticket_status_params
      params.require(:ticket_status).permit(:VIP, :regular, :early_bird)
    end
end
