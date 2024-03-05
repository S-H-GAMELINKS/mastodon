# frozen_string_literal: true

# D = Steep::Diagnostic
#
# target :lib do
#   signature "sig"
#
#   check "lib"                       # Directory name
#   check "Gemfile"                   # File name
#   check "app/models/**/*.rb"        # Glob
#   # ignore "lib/templates/*.rb"
#
#   # library "pathname", "set"       # Standard libraries
#   # library "strong_json"           # Gems
#
#   # configure_code_diagnostics(D::Ruby.strict)       # `strict` diagnostics setting
#   # configure_code_diagnostics(D::Ruby.lenient)      # `lenient` diagnostics setting
#   # configure_code_diagnostics do |hash|             # You can setup everything yourself
#   #   hash[D::Ruby::NoMethod] = :information
#   # end
# end

# target :test do
#   signature "sig", "sig-private"
#
#   check "test"
#
#   # library "pathname", "set"       # Standard libraries
# end

ignores = [
  Steep::Diagnostic::Ruby::MethodDefinitionMissing,
  Steep::Diagnostic::Ruby::UnknownConstant,
  Steep::Diagnostic::Ruby::NoMethod,
  Steep::Diagnostic::Ruby::UnexpectedBlockGiven,
  Steep::Diagnostic::Ruby::IncompatibleAssignment,
  Steep::Diagnostic::Ruby::UnknownInstanceVariable,
  Steep::Diagnostic::Ruby::UnexpectedPositionalArgument,
  Steep::Diagnostic::Ruby::UnresolvedOverloading,
  Steep::Diagnostic::Ruby::InsufficientPositionalArguments,
  Steep::Diagnostic::Ruby::UnknownGlobalVariable,
  Steep::Diagnostic::Ruby::UnexpectedError,
  Steep::Diagnostic::Ruby::MethodBodyTypeMismatch,
  Steep::Diagnostic::Ruby::ArgumentTypeMismatch,
  Steep::Diagnostic::Ruby::UnexpectedSuper,
  Steep::Diagnostic::Ruby::UnexpectedYield,
  Steep::Diagnostic::Ruby::BreakTypeMismatch,
  Steep::Diagnostic::Ruby::RequiredBlockMissing,
  Steep::Diagnostic::Ruby::ImplicitBreakValueMismatch,
  Steep::Diagnostic::Ruby::UnexpectedKeywordArgument,
  Steep::Diagnostic::Ruby::BlockTypeMismatch,
]

target :app do
  check 'app'

  signature 'sig'

  library 'activesupport'

  configure_code_diagnostics do |hash|
    ignores.each do |ignore|
      hash[ignore] = :information
    end
  end
end
