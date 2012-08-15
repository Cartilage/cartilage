
class window.Cartilage.Views.ListViewItem extends Cartilage.View

  tagName: "li"

  render: ->
    ($ @el).attr "tabindex", 0
    ($ @el).data "model", @model
    ($ @el).data "view", @
    super()
