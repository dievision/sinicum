def read_default_node_json(workspace = "website",
  jcr_primary_type = "mgnl:contentNode", mgnl_template = nil, mgnl_version = :mgnl4)
  if mgnl_version == :mgnl4
    template_file = File.dirname(__FILE__) + "/../fixtures/api/default_json.json.erb"
  elsif mgnl_version == :mgnl5
    template_file = File.dirname(__FILE__) + "/../fixtures/api/default_json_mgnl5.json.erb"
  else
    fail "Please specify a valid Magnolia version"
  end
  read_node_file(workspace, jcr_primary_type, mgnl_template, template_file)
end

def read_default_mgnl5_node_json(workspace = "website",
  jcr_primary_type = "mgnl:contentNode", mgnl_template = nil)
  read_default_node_json(workspace, jcr_primary_type, mgnl_template, 5)
end

class TemplateNodeProperties
  def initialize(workspace, jcr_primary_type, mgnl_template)
    @workspace = workspace
    @jcr_primary_type = jcr_primary_type
    @mgnl_template = mgnl_template
  end

  def grab_binding
    binding
  end
end

private

def read_node_file(workspace, jcr_primary_type, mgnl_template, template_file)
  result = nil
  File.open(template_file) do |file|
    result = file.read
  end
  template = ERB.new(result)
  properties = TemplateNodeProperties.new(workspace, jcr_primary_type, mgnl_template)
  MultiJson.load(template.result(properties.grab_binding))
end
