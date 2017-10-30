require "./spec_helper"

class Custom
end

Raze.add_state_property custom : Custom = Custom.new

describe "Raze::State" do
  it "acts like a hash" do
    state = Raze::State.new
    state["foo"] = "bar"
    state["baz"] = 1

    state["foo"].should eq("bar")
    state["baz"].should eq(1)
  end

  it "has basic defined properties" do
    state = Raze::State.new

    state.responds_to?(:"int=").should be_true
    state.responds_to?(:"uint=").should be_true
    state.responds_to?(:"string=").should be_true
    state.responds_to?(:"float=").should be_true
    state.responds_to?(:"bool=").should be_true
  end

  it "has a defined custom property" do
    state = Raze::State.new
    state.custom.should be_a(Custom)
  end
end
