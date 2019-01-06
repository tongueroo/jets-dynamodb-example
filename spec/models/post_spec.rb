describe Post do
  it "loads attributes" do
    post = Post.new(title: "my title", desc: "my desc")
    expect(post.attrs).to eq("title" => "my title", "desc" => "my desc")

    post.attrs(title: "my title2")
    expect(post.attrs).to eq("title" => "my title2", "desc" => "my desc")

    post.replace
  end
end
