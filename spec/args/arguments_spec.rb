require 'spec_helper'
require 'squib/args/arguments'
require 'squib/args/draw2'

describe Squib::Args::Arguments do

  let(:deck) { double(:deck) }

  before(:each) do
    allow(deck).to receive(:size).and_return(3)
    allow(deck).to receive(:defaults).and_return({})
    allow(deck).to receive(:layout).and_return({
      'fun' => { 'fill_color' => :red },
      'silly' => { 'fill_color' => :pink }
      })
    allow(deck).to receive(:custom_colors).and_return({
      'foo' => 'white'
      })
  end

  context '#only' do
    it 'allows some options' do
      args = Squib::Args::Arguments.new({a: 1, b: 2}, deck)
      args.only(:a, :b) # no error
    end

    it 'raises error on unexpected' do
      args = Squib::Args::Arguments.new({a: 1, b: 2}, deck)
      expect { args.only(:a) }.to raise_error(start_with('Unexpected parameter'))
    end
  end

  context '#build' do

    let(:deck) { double(:deck) }

    it 'builds Draw with singleton expansion' do
      opts = { color: :blue }
      args = Squib::Args::Arguments.new opts, deck
      draws = args.build Squib::Args::Draw2, {}
      expect(draws[0]).to be_a(Squib::Args::Draw2)
      expect(draws[1]).to be_a(Squib::Args::Draw2)
      expect(draws[2]).to be_a(Squib::Args::Draw2)
      expect( draws.map {|d| d.color} ).to eq([:blue, :blue, :blue])
    end

    it 'builds Draw with no singleton expansion' do
      opts = { color: [:red, :white, :blue] }
      args = Squib::Args::Arguments.new opts, deck
      draws = args.build Squib::Args::Draw2, {}
      expect(draws[0]).to be_a(Squib::Args::Draw2)
      expect(draws[1]).to be_a(Squib::Args::Draw2)
      expect(draws[2]).to be_a(Squib::Args::Draw2)
      expect(draws.map {|d| d.color}).to eq([:red, :white, :blue])
    end

  end

end
