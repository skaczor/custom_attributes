class CustomColumnsController < ApplicationController
  before_filter :load_customizing
  def index
    @custom_columns = @customizing.custom_columns
#    @customizing = params[:customizing_type].constantize.find(params[:customizing_id])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @custom_columns }
    end
  end

  def new
    @custom_column = @customizing.custom_columns.build
    session[:return_to] = request.env["HTTP_REFERER"]

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @custom_column }
    end
  end

  def create
    respond_to do |format|
      if @custom_column = @customizing.custom_columns.create(params[:custom_column])
        flash[:notice] = 'Custom Column was successfully created.'
        format.html { redirect_to(session[:return_to] || [@customizing, CustomColumn.new]) }
        format.xml  { render :xml => @custom_column, :status => :created, :location => [@customizing, CustomColumn] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @customizing.errors, :status => :unprocessable_entity }
      end
    end

  end

  def edit
    @custom_column = CustomColumn.find(params[:id])
    session[:return_to] = request.env["HTTP_REFERER"]
  end

  def update
    @custom_column = CustomColumn.find(params[:id])

    respond_to do |format|
      if @custom_column.update_attributes(params[:custom_column])
        flash[:notice] = 'CustomColumn was successfully updated.'
        format.html { redirect_to(session[:return_to] || [@customizing, CustomColumn.new]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @custom_column.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @custom_column = CustomColumn.find(params[:id])
    @custom_column.destroy

    respond_to do |format|
      format.html { redirect_to( request.env["HTTP_REFERER"] || [@customizing, CustomColumn.new]) }
      format.xml  { head :ok }
    end
  end

private

  def load_customizing
    customizing_type = params[:customizing_type]
    @customizing = customizing_type.constantize.find(params[customizing_type.foreign_key])
  end
end
