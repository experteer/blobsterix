Codeqa.configure do |config|
  config.excludes = ['coverage/*',
                     'templates/*',
                     'pkg/*',
                     'contents/*',
                     'lib/blobsterix/mimemagic/*',
                     'config/lighttpd.conf']

  config.enabled_checker.delete 'CheckRubySyntax'
  config.enabled_checker << 'RubocopLint'
  config.enabled_checker << 'RubocopFormatter'

  config.rubocop_formatter_cops << 'AlignHash'
  config.rubocop_formatter_cops << 'SignalException'
  config.rubocop_formatter_cops << 'DeprecatedClassMethods'
  config.rubocop_formatter_cops << 'RedundantBegin'
  config.rubocop_formatter_cops << 'RedundantSelf'
  config.rubocop_formatter_cops << 'RedundantReturn'
  config.rubocop_formatter_cops << 'CollectionMethods'
end
