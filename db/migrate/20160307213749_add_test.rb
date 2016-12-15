class AddTest < ActiveRecord::Migration
  def up
    user = User.new
    user.username = "test"
    user.password_digest = "abcdef"
    user.save(validate: false)

    user2 = User.new
    user2.username = "test2"
    user2.password_digest = "abcdef"
    user2.save(validate: false)

    p = Project.new
    p.title = "Neighborhood Parties for Targeted Outreach"
    p.description = "Let’s have parties in communities to get out the vote. There can be several small parties, or one large party, depending on amount allocated. 
Costs include DJ, food, & supplies."
    p.cost = 200
    p.user_id = user.id
    p.save(validate: false)

    pr = ProjectRevision.new
    pr.project = p
    pr.revision = 1
    pr.title = "Neighborhood Parties"
    pr.description = "Let’s have parties communities get out the vote. There can be many small parties, or one large party, depending on amount allocated. 
Costs include DJ, food, & supplies. "
    pr.cost = 200
    pr.user_id = user.id
    pr.save(validate: false)

    pr = ProjectRevision.new
    pr.project = p
    pr.revision = 2
    pr.title = "Neighborhood Parties for Targeted Outreach"
    pr.description = "Let’s have parties in communities to get out the vote. There can be several small parties, or one large party, depending on amount allocated. 
Costs include DJ, food, & supplies."
    pr.cost = 200
    pr.user_id = user.id
    pr.save(validate: false)

    comment = Comment.new
    comment.body = ""
    comment.project = p
    comment.user_id = user.id
    comment.project_revision_id = pr.id
    comment.save(validate: false)


    p = Project.new
    p.title = "Printing for MTBA Advertising"
    p.description = "Let’s advertise in the MTBA!  We expect we will get an in-kind donation of free space given by the MTBA. This proposal is to pay the printing costs for the campaign. "
    p.cost = 1000
    p.user_id = user2.id
    p.save(validate: false)

    pr = ProjectRevision.new
    pr.project = p
    pr.revision = 1
    pr.title = "Printing for MTBA Advertising"
    pr.description = "Let’s advertise in the MTBA!  We expect we will get an in-kind donation of free space given by the MTBA. This proposal is to pay the printing costs for the campaign. "
    pr.cost = 1000
    pr.user_id = user2.id
    pr.save(validate: false)







    p = Project.new
    p.title = "YLC Door Hangers"
    p.description = "Door hangers to place on people’s homes and get out the vote."
    p.cost = 1000
    p.user_id = user.id
    p.save(validate: false)

    pr = ProjectRevision.new
    pr.project = p
    pr.revision = 1
    pr.title = "YLC Door Hangers"
    pr.description = "Door hangers to place on people’s homes and get out the vote."
    pr.cost = 1000
    pr.user_id = user.id
    pr.save(validate: false)




  end

  def down
  end
end
