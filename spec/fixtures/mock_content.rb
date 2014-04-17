class MockContent < Sinicum::Jcr::Content
  def initialize(workspace_name = "website", content = {})
    content[:uuid] = Sinicum::Jcr::Content.new_uuid unless content.key?(:uuid)
    initialize_original_content(workspace_name, content)
  end
end
