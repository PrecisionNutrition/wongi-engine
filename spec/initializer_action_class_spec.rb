require 'spec_helper'

describe 'action classes' do
  include Wongi::Engine::DSL

  let :engine do
    Wongi::Engine.create
  end

  let :action_class do
    Class.new do
      class << self
        attr_accessor :execute_body
        attr_accessor :deexecute_body
      end

      def initialize(kwarg:)
        @kwarg = kwarg
        super()
      end

      def execute(_token)
        self.class.execute_body.call(@kwarg)
      end

      def deexecute(_token)
        self.class.deexecute_body.call(@kwarg)
      end
    end
  end

  it 'should have appropriate callbacks executed' do
    executed = []
    deexecuted = []

    klass = action_class

    klass.execute_body = lambda do |kwarg|
      executed << kwarg
    end
    klass.deexecute_body = lambda do |kwarg|
      deexecuted << kwarg
    end

    engine << rule {
      forall {
        has :A, :x, :B
      }
      make {
        action klass, kwarg: :kwarg
      }
    }

    engine << [1, :x, 2]
    expect(executed).to be == [:kwarg]
    expect(deexecuted).to be == []

    engine.retract [1, :x, 2]
    expect(executed).to be == [:kwarg]
    expect(deexecuted).to be == [:kwarg]
  end
end
