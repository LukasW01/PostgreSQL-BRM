module Notifications
  class Hooks
    def initialize(hooks)
      @hooks = hooks
    end

    def restore_success
      @hooks.restore_success
    end

    def restore_failure
      @hooks.restore_failure
    end

    def dump_success
      @hooks.dump_success
    end

    def dump_failure
      @hooks.dump_failure
    end
  end
end
