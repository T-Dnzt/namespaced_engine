<%= wrap_in_modules <<-rb.strip_heredoc
  class Engine < ::Rails::Engine
  #{'  isolate_namespace ' + camelized_modules}
  end
rb
%>
