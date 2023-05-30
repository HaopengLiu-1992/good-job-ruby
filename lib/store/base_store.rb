require 'singleton'
require_relative '../logging'

module GoodJob
  module Store
    class BaseStore
      include Singleton
      include Logging
      def add_job(_namespace, _k, _v)
        raise NotImplementedError
      end

      def get_job(_namespace, _k)
        raise NotImplementedError
      end

      def remove_job(_namespace, _k)
        raise NotImplementedError
      end

      def include_job?(_namespace, _k)
        raise NotImplementedError
      end

      def get_all_jobs(_namespace)
        raise NotImplementedError
      end

      def get_all_jobs_by_full_name(_worker_full_name)
        raise NotImplementedError
      end

      def register_role_as_live(_role, _namespace)
        raise NotImplementedError
      end

      def check_role_statuses(_role)
        raise NotImplementedError
      end

      def unregister_worker(_role, _worker_full_name)
        raise NotImplementedError
      end

      def get_last_registered_time_by_name(_role, _worker_full_name)
        raise NotImplementedError
      end
    end
  end
end
