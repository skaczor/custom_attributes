class CustomColumnsController < ApplicationController
  unloadable

  before_filter :load_customizing, :except => [:new_attribute_value]

  before_filter :require_user
  def index
    @custom_columns = @customizing.custom_columns

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @custom_columns }
      format.js { render :json => @custom_columns }
    end
  end

  def new
    session[:return_to] = request.env["HTTP_REFERER"]

    @custom_column = @customizing.custom_columns.build
    if params[:parent_id]
      @custom_column.parent = parent = CustomColumn.find(params[:parent_id])
      @custom_column.name = parent.name
      @custom_column.caption = parent.caption
      @custom_column.position = parent.position
      if @custom_column.save
        respond_to do |format|
          format.html { redirect_to(session[:return_to] || [@customizing, @custom_column]) }
          format.xml  { render :xml => @custom_column, :status => :created, :location => [@customizing, CustomColumn] }
        end
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @custom_column.errors, :status => :unprocessable_entity }
      end
    else
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @custom_column }
      end
    end
  end

  def create
    respond_to do |format|
      if params[:custom_column] && params[:custom_column][:caption]
        params[:custom_column][:name] = params[:custom_column][:caption].underscore.gsub(/[^a-zA-Z0-9_]/, '_') unless params[:custom_column][:name]
      end
      @custom_column = @customizing.custom_columns.create(params[:custom_column])
      if @custom_column && @custom_column.errors.empty?
        flash[:notice] = 'Custom Column was successfully created.'
        format.html { redirect_to(session[:return_to] || [@customizing, CustomColumn.new]) }
        format.xml  { render :xml => @custom_column, :status => :created, :location => [@customizing, CustomColumn] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @custom_column.errors, :status => :unprocessable_entity }
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
      format.html { redirect_to( request.env["HTTP_REFERER"] || @customizing) }
      format.xml  { head :ok }
    end
  end

  # Method invoked through ajax to add a new custom attribute value
  def new_attribute_value
    render :update do |page|
      fields_for("custom_column[values_attributes][#{(1000*DateTime.now.to_f).to_i}]") do |value_fields|
        page.insert_html :bottom, params[:container_id], :partial => 'custom_attribute_value',
          :locals => {:f => value_fields}
      end
    end
  end

private

  def load_customizing
    customizing_type = params[:customizing_type]
    @customizing = customizing_type.constantize.find(params[:customizing_id] || params[customizing_type.foreign_key])
  end
end
