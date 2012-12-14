module TheSortableTreeController
  # include TheSortableTreeController::ReversedRebuild
  # include TheSortableTreeController::Rebuild
  
  module DefineVariablesMethod
    public
    def enable
      id        = params[:id].to_s
      variable, collection, klass = the_define_common_variables
      variable = self.instance_variable_set(variable, the_find(klass, id))
      if variable.respond_to? :enabled
        variable.enabled = true
      elsif variable.respond_to? :status
        variable.status = true
      end
      variable.save
      if request.xhr?
        render text: "true|#{I18n.t("disable_this")}"
      else 
        redirect_to :back, notice: t('the_sortable_tree.enabled')
      end
    end
    
    def disable
      id        = params[:id].to_s
      variable, collection, klass = the_define_common_variables
      variable = self.instance_variable_set(variable, the_find(klass, id))
      if variable.respond_to? :enabled
        variable.enabled = false
      elsif variable.respond_to? :status
        variable.status = false
      end
      variable.save
      if request.xhr?
        render text: "false|#{I18n.t("enable_this")}"
      else 
        redirect_to :back, notice: t('the_sortable_tree.disabled')
      end
    end
    
    def the_define_common_variables
      collection =  self.class.to_s.split(':').last.sub(/Controller/,"").underscore.downcase # recipes
      variable =    collection.singularize                      # recipe
      klass =       variable.classify.constantize               # Recipe
      ["@#{variable}", collection, klass]
    end
    
    def the_find(klass, id)
      begin
        klass.find(id)
      rescue
        klass.find_by_slug(id)
      end
    end
    
  end#DefineVariablesMethod
  
  module Rebuild
    include DefineVariablesMethod
    public
    def rebuild
      id        = params[:id].to_s
      parent_id = params[:parent_id].to_s
      prev_id   = params[:prev_id].to_s
      next_id   = params[:next_id].to_s

      if id.empty?
        render text: 'err 1', status: 500
        return
      end
      if parent_id.empty? && prev_id.empty? && next_id.empty?
        render text: 'err 2'
        return
      end
      
      variable, collection, klass = self.the_define_common_variables
      variable = self.instance_variable_set(variable, the_find(klass, id))
      if prev_id.empty? && next_id.empty?
        variable.move_to_child_of the_find(klass, parent_id)
      elsif !prev_id.empty?
        variable.move_to_right_of the_find(klass, prev_id)
      elsif !next_id.empty?
        variable.move_to_left_of the_find(klass, next_id)
      end

      render text: 'ok'
    end
  end#Rebuild
  
  module ReversedRebuild
    include DefineVariablesMethod
    public
    def rebuild
      id        = params[:id].to_i
      parent_id = params[:parent_id].to_i
      prev_id   = params[:prev_id].to_i
      next_id   = params[:next_id].to_i

      if id.empty?
        render text: 'err', status: 500
        return
      end
      if parent_id.empty? && prev_id.empty? && next_id.empty?
        render text: 'err'
        return
      end
      
      variable, collection, klass = self.the_define_common_variables
      variable = self.instance_variable_set(variable, the_find(klass, id))

      if prev_id.zero? && next_id.zero?
        variable.move_to_child_of the_find(klass, parent_id)
      elsif !prev_id.zero?
        variable.move_to_left_of the_find(klass, prev_id)
      elsif !next_id.zero?
        variable.move_to_right_of the_find(klass, next_id)
      end

      render text: 'ok'
    end
  end#ReversedRebuild

end
