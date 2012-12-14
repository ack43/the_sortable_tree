# So, ERB and SLIM fans want to make gem became independent of HAML
# Ok, let it be. But you will convert view partials youself
# require "haml"

require "the_sortable_tree/engine"
require "the_sortable_tree/version"

module TheSortableTree
  # include TheSortableTree::Scopes
  module Scopes
    extend ActiveSupport::Concern
    included do
      if defined?(Mongoid)
        if ::Mongoid::VERSION < '3'
          scope :nested_set,          order_by([lft: :asc])
          scope :reversed_nested_set, order_by([lft: :desc])
        else
          scope :nested_set,          order_by([:lft, :asc])
          scope :reversed_nested_set, order_by([:lft, :desc])
        end
      else
        scope :nested_set, order('lft ASC')
        scope :reversed_nested_set, order('lft DESC')
      end
    end
  end
  
  module Helper
    def the_sortable_tree_actions
      controller do
        include TheSortableTreeController::Rebuild
      end
      config.member_actions << ActiveAdmin::ControllerAction.new(:enable, method: :post)
      config.member_actions << ActiveAdmin::ControllerAction.new(:disable, method: :post)
      config.collection_actions << ActiveAdmin::ControllerAction.new(:rebuild, method: :post)
    end
  end
end

if defined? ActiveAdmin
  ActiveAdmin::ResourceDSL.send :include, TheSortableTree::Helper
end