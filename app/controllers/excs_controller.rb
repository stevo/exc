class ExcsController < ApplicationController

  def create
    params[:exc][:klass].constantize.new(params[:exc][:message])
    respond_to do |format|
      format.xml  { head :ok }
    end
  end

end
