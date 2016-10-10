require 'spec_helper'
require 'squib/args/draw2'
require 'squib/args/builder'

describe Squib::Args::Builder do

  let(:deck) { double('deck') }

  before(:each) do
    allow(deck).to receive(:size).and_return(2)
    allow(deck).to receive(:layout).and_return({
      'fun' => { 'fill_color' => :red },
      'silly' => { 'fill_color' => :pink }
      })
  end

  it 'builds a singleton draw with no opts' do
    opts = {}
    draws = Squib::Args.build(Squib::Args::Draw2, opts, deck)
    expect(draws).to all(have_attributes(color: :black))
  end

  it 'build a singleton draw with some opts' do
    opts = { stroke_color: :blue }
    draws = Squib::Args.build(Squib::Args::Draw2, opts, deck)
    expect(draws).to all(have_attributes(color: :black, stroke_color: :blue))
  end

  it 'build a singleton draw with layout involved' do
    opts = { layout: :fun }
    draws = Squib::Args.build(Squib::Args::Draw2, opts, deck)
    expect(draws).to all(have_attributes(color: :black, fill_color: :red))
  end

  it 'builds a singleton draw with dsl default specified' do
    opts = {}
    method_defaults = { stroke_width: 1.4 }
    draws = Squib::Args.build(Squib::Args::Draw2, opts, deck, method_defaults)
    expect(draws).to all(have_attributes(color: :black, stroke_width: 1.4))
  end

  it 'builds a singleton draw with dsl default and layout specified' do
    opts = { layout: 'fun' }
    method_defaults = { stroke_width: 1.4 }
    draws = Squib::Args.build(Squib::Args::Draw2, opts, deck, method_defaults)
    expect(draws).to all(have_attributes(
      color: :black,
      stroke_width: 1.4,
      fill_color: :red
      ))
  end

  it 'builds a doubleton draw with dsl default and layouts specified' do
    opts = { layout: ['fun', 'silly'] }
    method_defaults = { stroke_width: 1.4 }
    draws = Squib::Args.build(Squib::Args::Draw2, opts, deck, method_defaults)
    expect(draws[0]).to have_attributes(
      color: :black,
      stroke_width: 1.4,
      fill_color: :red
      )
    expect(draws[1]).to have_attributes(
      color: :black,
      stroke_width: 1.4,
      fill_color: :pink
      )
  end

end
