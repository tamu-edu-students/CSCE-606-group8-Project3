# Skip @dev_only scenarios unless running in development environment
Before("@dev_only") do
  unless Rails.env.development?
    skip_this_scenario
  end
end
