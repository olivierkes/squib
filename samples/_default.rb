require 'squib'

Squib::Deck.new do
  use_layout file: '_default_layout.yml'
  default color: :blue
  background layout: :foo
  save_png prefix: "default_"
end
