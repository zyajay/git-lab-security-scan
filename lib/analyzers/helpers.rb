# frozen_string_literal: true

module Analyzers
  # Shared methods between Analyzers classes
  module Helpers
    def cmd(cmd, env = {})
      puts 'EXECUTE: ' + cmd.lstrip
      system(env, cmd)
    end
  end
end
