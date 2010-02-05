Given "the list of approved orders contains $total elements" do | total |
  orders = @inventory_pool.orders.approved
  user = Factory.create_user
  total.to_i.times { orders << Factory.create_order(:user_id => user.id, :status_const => Order::APPROVED) }
  orders.size.should == total.to_i
end

# TODO perform real post 
When "'$who' places a new order" do | who |
  user = Factory.create_user(:login => who)
  @order = Factory.create_order({:user_id => user.id})    
  post "/session", :login => who #new#
end

When "he submits the new order" do
  post submit_user_order_path
end

When "$who approves the order" do | who |
  post "/session", :login => @last_manager_login_name #new#
  post approve_backend_inventory_pool_user_acknowledge_path(@inventory_pool, @order.user, @order, :comment => "test comment")
  @order = assigns(:order)
  @order.should_not be_nil
  @contract = @order.user.reload.current_contract(@order.inventory_pool)
  @contract.should_not be_nil
end

# OPTIMIZE 0402
When "$who clicks on 'hand_over'" do | who |
  get send("backend_inventory_pool_hand_over_path", @inventory_pool)
  @visits = assigns(:visits)
  response.should render_template("backend/hand_over/index")
end

Then "he sees $total line$s with a total quantity of $quantity" do | total, s, quantity |
   @visits.size.should == total.to_i
   s = @visits.collect(&:quantity).sum
   s.should == quantity.to_i 
end

###############################################

Then "line $line has a quantity of $quantity for user '$who'" do | line, quantity, who |
  @visits[line.to_i - 1].quantity.should == quantity.to_i
  @visits[line.to_i - 1].user.login.should == who
end

###############################################


When "$who chooses one line" do | who |
  visit = @visits.first
  get backend_inventory_pool_user_hand_over_path(@inventory_pool, visit.user)
  response.should render_template('backend/hand_over/show')
  @contract = assigns(:contract)
end

Then "a new contract is generated" do
  @contract.nil?.should == false
end

Then /^he sees ([0-9]+) contract line(s?) for all approved order lines$/ do | size, s |
  @contract.contract_lines.size.should == size.to_i
end
