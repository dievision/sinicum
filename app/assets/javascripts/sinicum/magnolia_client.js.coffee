sinicum = sinicum ? { }

sinicum.renderDocumentReady = true


class sinicum.MagnoliaClient
  setMainBar: (elements) ->
    jQuery.each(elements, (index, value) ->
      element = jQuery(value)
      config = {}
      config['dialog'] = element.data("dialog")
      config['label'] = element.data("label")
      config['adminButtonVisible'] = element.data("admin-button-visible")
      config['repository'] = element.data("repository")
      config['nodePath'] = element.data("node-path")
      element.wrapInner(new sinicum.MainBar(config).render())
    )

  setMainBarPreview: (elements) ->
    jQuery.each(elements, (index, value) ->
      element = jQuery(value)
      element.wrapInner(new sinicum.MainBarPreview().render())
    )

  setNewBar: (elements) ->
    jQuery.each(elements, (index, value) ->
      element = jQuery(value)
      config = {}
      config['contentNodeCollectionName'] = element.data("content-node-collection-name")
      config['contentNodeName'] = element.data("content-node-name")
      config['label'] = element.data("label")
      config['paragraph'] = element.data("paragraph")
      config['repository'] = element.data("repository")
      config['nodePath'] = element.data("node-path")
      element.wrapInner(new sinicum.NewBar(config).render())
    )

  setEditBar: (elements) ->
    jQuery.each(elements, (index, value) ->
      element = jQuery(value)
      config = {}
      config['repository'] = element.data("repository")
      config['nodePath'] = element.data("node-path")
      config['paragraph'] = element.data("paragraph")
      config['contentNodeCollectionName'] = element.data("content-node-collection-name")
      config['contentNodeIteratorIndex'] = element.attr("data-content-node-iterator-index")
      config['contentNodeIteratorPath'] = element.data("content-node-iterator-path")
      config['deleteLabel'] = element.data("delete-label")
      config['editLabel'] = element.data("edit-label")
      config['moveLabel'] = element.data("move-label")
      element.wrapInner(new sinicum.EditBar(config).render())
    )


class sinicum.MainBar
  constructor: (options) ->
    @label = "Properties"
    @adminButtonVisible = true
    if options
      @dialog = options['dialog']
      @repository = options['repository']
      @nodePath = options['nodePath']
      if options['label']
        @label = options['label']
      if options['adminButtonVisible'] == false || options['adminButtonVisible'] == 'false'
        @adminButtonVisible = false

  render: ->
    wrapper = jQuery("<div class\"mgnlMainBar\" style=\"top:0px;left:0px;width:100%;\"></div>")
    wrapper.append(this.renderControlBarTable())

  renderControlBarTable: ->
    # left
    leftColumn = jQuery("<td class=\"mgnlBtnsLeft\"></td>")
    leftColumn.append(btn.render()) for btn in this.leftButtons()
    # right
    rightColumn = jQuery("<td class=\"mgnlBtnsRight\"></td>")
    rightColumn.append(btn.render()) for btn in this.rightButtons()
    # table structure
    row = jQuery("<tr></tr>").append(leftColumn).append(rightColumn)
    body = jQuery("<tbody></tbody>").append(row)
    table = jQuery("<table class=\"mgnlControlBar\"></table>").append(body)
    table

  leftButtons: ->
    buttons = []
    buttons.push(new sinicum.MgnlButton("« Preview", "mgnlPreview(true)"))
    if @adminButtonVisible
      buttons.push(new sinicum.MgnlButton("AdminCentral",
        "MgnlAdminCentral.showTree(\'#{this.escJs(@repository)}\'," +
        "\'#{this.escJs(@nodePath)}\')"))
    buttons

  rightButtons: ->
    [
      new sinicum.MgnlButton(@label,
        "mgnlOpenDialog(\'#{this.escJs(@nodePath)}\',\'\',\'\',\'#{this.escJs(@dialog)}\'," +
        "\'#{this.escJs(@repository)}\',null, null, null)")
    ]

  escJs: (string) ->
    if string
      string.replace(/\'/g, "\\'")

class sinicum.MainBarPreview
  render: ->
    html = "<div class=\"mgnlMainbarPreview\" style=\"top:4px;left:4px;\">" +
      "<span onmousedown=\"mgnlShiftPushButtonDown(this);\" " +
      "onmouseout=\"mgnlShiftPushButtonOut(this);\" " +
      "onclick=\"mgnlShiftPushButtonClick(this);mgnlPreview(false);\" " +
      "class=\"mgnlControlButton\" style=\"\">»</span>" +
      "</div>"
    jQuery(html)


class sinicum.NewBar
  constructor: (options) ->
    @contentNodeCollectionName = options['contentNodeCollectionName']
    @contentNodeName = options['contentNodeName']
    @label = "New" || options['label']
    @paragraph = options['paragraph']
    @repository = options['repository']
    @nodePath = options['nodePath']

  render: ->
    html = "<table onmousedown=\"mgnlMoveNodeEnd(this,'#{@nodePath}');\" " +
      "onmouseout=\"mgnlMoveNodeReset(this);\" onmouseover=\"mgnlMoveNodeHigh(this);\" " +
      "class=\"mgnlControlBarSmall\" id=\"#{@contentNodeCollectionName}__mgnlNew\" cellspacing=\"0\">" +
      "<tbody><tr><td class=\"mgnlBtnsLeft\">" +
      "<span onmousedown=\"mgnlShiftPushButtonDown(this);\" " +
      "onmouseout=\"mgnlShiftPushButtonOut(this);\" " +
      "onclick=\"mgnlShiftPushButtonClick(this);" +
      "mgnlOpenDialog('#{@nodePath}',"
    if @contentNodeCollectionName
      html += "'#{@contentNodeCollectionName}','mgnlNew',"
    else if @contentNodeName
      html += "'','#{@contentNodeName}',"
    html += "'#{@paragraph}','#{@repository}'," +
      "'.magnolia/dialogs/#{this.editPageName()}', null, null);\" " +
      "class=\"mgnlControlButtonSmall\" style=\"background-color: transparent; " +
      "background-position: initial initial; background-repeat: initial initial; \">" +
      "New</span></td></tr></tbody></table>"
    wrapper = jQuery(html)
    wrapper

  editPageName: ->
    pageName = "editParagraph.html"
    if @paragraph && @paragraph.indexOf(",") > 0
      pageName = "selectParagraph.html"
    pageName


class sinicum.EditBar
  constructor: (options) ->
    @repository = options['repository']
    @nodePath = options['nodePath']
    @paragraph = options['paragraph']
    @deleteLabel = options['deleteLabel'] || "Delete"
    @editLabel = options['editLabel'] || "Edit"
    @moveLabel = options['moveLabel'] || "Move"
    @contentNodeCollectionName = options['contentNodeCollectionName']
    @contentNodeIteratorIndex = options['contentNodeIteratorIndex']
    @contentNodeIteratorPath = options['contentNodeIteratorPath']

  render: ->
    html = "<table onmousedown=\"mgnlMoveNodeEnd(this,'#{@nodePath}');\" " +
      "onmouseout=\"mgnlMoveNodeReset(this);\" onmouseover=\"mgnlMoveNodeHigh(this);\" " +
      "class=\"mgnlControlBarSmall\" id=\"__#{@contentNodeIteratorIndex || 0}\" cellspacing=\"0\">" +
      "<tbody><tr><td class=\"mgnlBtnsLeft\">" +

      "<span onmousedown=\"mgnlShiftPushButtonDown(this);\" " +
      "onmouseout=\"mgnlShiftPushButtonOut(this);\" " +
      "onclick=\"mgnlShiftPushButtonClick(this);mgnlOpenDialog("
    if @contentNodeCollectionName
      html += "'#{@nodePath}','','#{@contentNodeIteratorIndex}',"
    else
      html += "'#{@nodePath}','','',"
    html += "'#{@paragraph}','#{@repository}'," +
      "'.magnolia/dialogs/#{this.editPageName()}', null, null);\" " +
      "class=\"mgnlControlButtonSmall\" style=\"background:transparent;\">#{@editLabel}</span>"

    if @contentNodeCollectionName
      html += "<span onmousedown=\"mgnlShiftPushButtonDown(this);\" " +
      "onmouseout=\"mgnlShiftPushButtonOut(this);\" " +
      "onclick=\"mgnlShiftPushButtonClick(this);mgnlMoveNodeStart('','#{@contentNodeIteratorIndex}','__#{@contentNodeIteratorIndex}');\" " +
      "class=\"mgnlControlButtonSmall\" style=\"background:transparent;\">#{@moveLabel}</span></td>"

    html += "<td class=\"mgnlBtnsRight\"><span onmousedown=\"mgnlShiftPushButtonDown(this);\" " +
      "onmouseout=\"mgnlShiftPushButtonOut(this);\" onclick=\"mgnlShiftPushButtonClick(this);"
    if @contentNodeCollectionName
      html += "mgnlDeleteNode('#{@nodePath}','','#{@contentNodeIteratorIndex}');\" "
    else
      html += "mgnlDeleteNode('#{@nodePath}');\" "
    html += "class=\"mgnlControlButtonSmall\" style=\"background:transparent;\">#{@deleteLabel}" +
      "</span></td></tr></tbody></table>"
    wrapper = jQuery(html)
    wrapper

  editPageName: ->
    pageName = "editParagraph.html"
    if @paragraph && @paragraph.indexOf(",") > 0
      pageName = "selectParagraph.html"
    pageName


class sinicum.MgnlButton
  constructor: (@text, @onclickAction) ->

  render: ->
    button = jQuery("<span></span>")
    button.addClass("mgnlControlButton")
    button = button.attr("onmousedown", "mgnlShiftPushButtonDown(this);")
    button = button.attr("onmouseout", "mgnlShiftPushButtonOut(this);")
    button = button.attr("onclick", "mgnlShiftPushButtonClick(this);#{@onclickAction};")
    button = button.css("background", "transparent")
    button = button.text(@text)
    button

sinicum.renderBars = ->
  client = new sinicum.MagnoliaClient()
  client.setMainBar(jQuery(".sinicum-mgnl-main-bar"))
  client.setMainBarPreview(jQuery(".sinicum-mgnl-main-bar-preview"))
  client.setEditBar(jQuery(".sinicum-mgnl-edit-bar"))
  client.setNewBar(jQuery(".sinicum-mgnl-new-bar"))

sinicum.preventDefaultRender = ->
  sinicum.renderDocumentReady = false

window.sinicum = sinicum

jQuery ->
  if sinicum.renderDocumentReady
    sinicum.renderBars()
