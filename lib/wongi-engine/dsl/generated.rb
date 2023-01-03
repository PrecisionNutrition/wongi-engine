module Wongi::Engine::DSL
  module Generated

    module ClassMethods
      def create_dsl_method extension

        clause = extension[:clause]
        action = extension[:action]
        body = extension[:body]
        acceptor = extension[:accept]

        define_method clause.first do |*args, **opts, &block|

          if body

            instance_exec *args, **opts, &body

          elsif acceptor

            rule.accept acceptor.new( *args, **opts, &block )

          elsif action

            c = Clause::Generic.new *args, **opts, &block
            c.name = clause.first
            c.action = action
            c.rule = self.rule
            rule.accept c

          end

        end

        clause[1..-1].each do |al|
          alias_method al, clause.first
        end

      end
    end

    attr_accessor :rule

    def self.included(base)
      base.extend ClassMethods
    end

  end
end
