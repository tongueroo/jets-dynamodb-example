describe Post do
  before(:each) do
    sts = double(:sts).as_null_object
    Aws::STS::Client.any_instance.stub(:get_caller_identity).and_return(sts)
  end

  it "loads attributes" do
    sts = double(:sts).as_null_object
    Aws::STS::Client.any_instance.stub(:get_caller_identity).and_return(sts)

    post = Post.new(title: "my title", desc: "my desc")
    expect(post.attrs).to eq("title" => "my title", "desc" => "my desc")

    post.attrs(title: "my title2")
    expect(post.attrs).to eq("title" => "my title2", "desc" => "my desc")

    post.replace
  end
end
