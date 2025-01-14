require 'rails_helper'

RSpec.describe ComponentTemplate, type: :model do
  context 'Create master data' do
    let(:component_template_props) { build(:component_template) }

    it 'should create the component_template' do
      component_template = ComponentTemplate.create(
        name: component_template_props.name,
        bootstrappers: component_template_props.bootstrappers,
        source: component_template_props.source
      )
      
      expect(component_template.persisted?).to eq(true)
    end
  end

  context 'Component template name should be unique' do
    let(:component_template_props) { build(:component_template) }
    before(:each) do
      @component_template = create(:component_template)
    end

    it 'should not create the component_template' do
      component_template = ComponentTemplate.create(
        name: @component_template.name,
        bootstrappers: component_template_props.bootstrappers,
        source: component_template_props.source

      )
      
      expect(component_template.persisted?).to eq(false)
    end
  end
end
