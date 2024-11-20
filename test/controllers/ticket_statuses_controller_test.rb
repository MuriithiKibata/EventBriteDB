require "test_helper"

class TicketStatusesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ticket_status = ticket_statuses(:one)
  end

  test "should get index" do
    get ticket_statuses_url, as: :json
    assert_response :success
  end

  test "should create ticket_status" do
    assert_difference("TicketStatus.count") do
      post ticket_statuses_url, params: { ticket_status: { VIP: @ticket_status.VIP, early_bird: @ticket_status.early_bird, regular: @ticket_status.regular } }, as: :json
    end

    assert_response :created
  end

  test "should show ticket_status" do
    get ticket_status_url(@ticket_status), as: :json
    assert_response :success
  end

  test "should update ticket_status" do
    patch ticket_status_url(@ticket_status), params: { ticket_status: { VIP: @ticket_status.VIP, early_bird: @ticket_status.early_bird, regular: @ticket_status.regular } }, as: :json
    assert_response :success
  end

  test "should destroy ticket_status" do
    assert_difference("TicketStatus.count", -1) do
      delete ticket_status_url(@ticket_status), as: :json
    end

    assert_response :no_content
  end
end
