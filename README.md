# Example DynamoDB Project with Dynomite

Example project to help answer this question: [Running rspec over dynomite model with local dynamodb instance results in MissingCredentialsError](https://community.rubyonjets.com/t/running-rspec-over-dynomite-model-with-local-dynamodb-instance-results-in-missingcredentialserror/31/2)

## Some Tips

Recommend creating a `dynamodb-local` IAM user. The tools like https://github.com/aaronshaf/dynamodb-admin assume you have `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` setup. Looks like Jets is calling out to get the AWS account id in some cases too. Know it's a little silly to create an IAM user for this, but dynamodb-local creates a DB on your filesystem that includes the AWS_ACCESS_KEY_ID in the DB name. It looks something like this.

    $ ls /usr/local/Caskroom/dynamodb-local/latest/*.db
    /usr/local/Caskroom/dynamodb-local/latest/your-aws-secret-access-key_us-west-2.db
    $

Make sure as you are creating the dynamodb tables both in `JETS_ENV=development` and `JETS_ENV=test` that it's writing to the same `your-aws-secret-access-key_us-west-2.db` file.

I created an example repo to help answer this: https://github.com/tongueroo/jets-dynamodb-example

Here's how I tested:

* Checked that config/dynamodb.yml is pointed to `http://localhost:8000` for both dev and test

Test development with `jets console`.

    $ jets c
    Jets booting up in development mode!
    >> post = Post.new(title: "test title")
    => #<Post:0x000056129f5859f0 @attrs={:title=>"test title"}>
    >> post.replace
    => {"id"=>"f564b8f82192556e13357bc226bd97238288bebf", :title=>"test title", "created_at"=>"2019-01-06T18:53:13Z", "updated_at"=>"2019-01-06T18:53:13Z"}
    >> Post.scan.count
    I, [2019-01-06T18:53:18.727636 #17317]  INFO -- : It's recommended to not use scan for production. It can be slow and expensive. You can a LSI or GSI and query the index instead.
    I, [2019-01-06T18:53:18.727694 #17317]  INFO -- : Scanning table: demo-dev-posts
    => 3
    >>

Then I checked that the `.db` file was created in the right space on the filesystem: `/usr/local/Caskroom/dynamodb-local/latest/your-aws-secret-access-key_us-west-2.db`  Also used dynamodb-admin to check if the table exists:

![dynamodb-admin-check-dev|690x253](upload://pXGJtVHXbPG0BTXnMIzhqwTMfKt.png)

Then did the same thing for testing. First migrate the test DB.

      $ JETS_ENV=test jets dynamodb:migrate ./dynamodb/migrate/20190106175741-create_posts_migration.rb
      Running database migrations
      DynamoDB Table: posts Status: ACTIVE
      $

Remember to check the `/usr/local/Caskroom/dynamodb-local/latest/` folder the `*.db` file again. And dynamodb-admin again

![dynamodb-admin-check-test|690x304](upload://jb8io6YPepv66EApxoEqt9b7EK4.png)

Then I was able to run the test, but not without a workaround. It looks like need to set the `AWS_REGION`. Will dig into fixing this in time. 👌

      $ AWS_REGION=us-west-2 rspec
      Post
        loads attributes

      Finished in 0.06104 seconds (files took 4.69 seconds to load)
      1 example, 0 failures

      $

The spec is here: [models/post_spec.rb](https://github.com/tongueroo/jets-dynamodb-example/blob/master/spec/models/post_spec.rb)

Hope that helps!

PS. Would love for someone to help maintain dynomite. Also, as a part of this released a new version of dynomite and jets. Currently, jets is vendorizing dynomite but would like to remove the vendoring of it in time.