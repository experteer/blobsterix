notification :tmux,
             :display_message => true,
             :timeout         => 3 # in seconds

# ignore /doc/

group :red_green_refactor, :halt_on_fail => true do
  guard 'rspec', :cmd => 'bundle exec rspec --color --format p', :all_after_pass => true do
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$})               { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch('spec/spec_helper.rb')            { 'spec' }
    watch(%r{^spec/support/(.+)\.rb})       { 'spec' }
    watch(%r{^spec/fixtures/(.+)})          { 'spec' }
  end

  guard :rubocop, :cli => %w(--display-cop-names --auto-correct) do
    watch(%r{.+\.rb$})
    watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
  end
end
