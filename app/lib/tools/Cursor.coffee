BaseTool = require 'lib/tools/BaseTool'

class Cursor extends BaseTool
  actions: [
      key: 'delete'
      display: 'Delete'
      callback: 'deleteBox'
    ,
      key: 'same'
      display: 'Same as Above'
      callback: 'sameBox'
    ,
      key: 'next'
      display: 'Next'
      callback: 'nextBox'
    ,
      key: 'previous'
      display: 'Previous'
      callback: 'previousBox'
  ]

  constructor: (opts) ->
    super(opts)

  clickBox: (box) =>
    unless box.hasClass 'selected'
      if $('.box').hasClass 'selected'
        @clickImage()
        @clickBox box
      else
        box.addClass('selected').resizable('enable').draggable()
        $('body').scrollTop box.position().top - ($(window).height() / 2) + (box.height() / 2)
        $('body').scrollLeft box.position().left - ($(window).width() / 2) + (box.width() / 2)
        @interface.startDataEntry box
        @resizing = true
        @currentBox = box

  clickImage: (e) =>
    if $('.box').hasClass 'selected'
      $('.box').removeClass('selected').resizable('disable')
      delete @currentBox
      @interface.entry.empty().removeClass('active')
      @resizing = false
    else
      box = document.createElement 'div'
      $(box).addClass('box').data('id', @counter).css({
        top: e.offsetY
        left: e.offsetX
        })
      @counter += 1
      @creating = true

      @interface.boxes.append box
      $(document).on 'mouseup', {box: box}, @onDoneCreateBox
      $(document).on 'mousemove', (de) =>
        if @creating
          $(box).width de.offsetX - e.offsetX
          $(box).height de.offsetY - e.offsetY

  onDoneCreateBox: (e) =>
    @creating = false

    $(e.data.box).resizable({
      handles: 'all'
      disabled: true
    })

    $(document).off 'mousemove mouseup'

  deleteBox: (e) =>
    boxToDelete = @currentBox
    if @interface.preferences.auto_move
      if boxToDelete.next().length
        @clickBox boxToDelete.next()
      else
        @clickBox $('.box').first()

    $(boxToDelete).remove()

  nextBox: =>
    if @currentBox.data('value')?
      @currentBox.addClass 'green'

    if @interface.preferences?.auto_move
      if @currentBox.next().length
        @clickBox @currentBox.next()
      else
        @clickBox $('.box').first()

  previousBox: (e) =>
    @clickBox $(@currentBox).prev()

  sameBox: (e) =>
    $(@currentBox).data 'value', 'same'
    @nextBox() if @interface.autoMove

module.exports = Cursor