
module "Cartilage.Views.BarView"

  setup: ->
    @testView = new Cartilage.Views.BarView
      segments: new Cartilage.Collections.Segments([
        new Cartilage.Models.Segment({ maximum: 20  }),
        new Cartilage.Models.Segment({ maximum: 40  }),
        new Cartilage.Models.Segment({ maximum: 60  }),
        new Cartilage.Models.Segment({ maximum: 80  }),
        new Cartilage.Models.Segment({ maximum: 100 })
      ])
      value: 54

    @testView.prepare()

test "should calculate correct widths", 5, ->

  _.each(@testView.subviews, (subview) ->
    # treat 0.19999999999999996 as 0.20
    equal subview.width.toFixed(2), 0.20, "correct width"
  )

test "should calculate correct fillWidths", 5, ->

  equal @testView.subviews[0].fillWidth, 1,  "correct fillWidth"
  equal @testView.subviews[1].fillWidth, 1,  "correct fillWidth"
  equal @testView.subviews[2].fillWidth, 0.7,"correct fillWidth" # 70% (14/20)of 3rd segment
  equal @testView.subviews[3].fillWidth, 0,  "correct fillWidth"
  equal @testView.subviews[4].fillWidth, 0,  "correct fillWidth"
