require "test_helper"

class HotwireCombobox::HelperTest < ApplicationViewTestCase
  test "passing an input type" do
    tag = combobox_tag :foo, type: :search

    assert_attrs tag, type: "search"
  end

  test "passing an id" do
    tag = combobox_tag :foo, id: :foobar

    assert_attrs tag, id: "foobar"
  end

  test "passing a name" do
    tag = combobox_tag :foo

    assert_attrs tag, name: "foo"
  end

  test "passing a value" do
    tag = combobox_tag :foo, :bar

    assert_attrs tag, value: "bar"
  end

  test "passing a form builder object" do
    form = ActionView::Helpers::FormBuilder.new :foo, nil, self, {}
    tag = combobox_tag :bar, form: form

    assert_attrs tag, name: "foo[bar]", id: "foo_bar" # name is not "bar"
  end

  test "passing a form builder object overrides value" do
    form = ActionView::Helpers::FormBuilder.new :foo, OpenStruct.new(bar: "foobar"), self, {}
    tag = combobox_tag :bar, :baz, form: form

    assert_attrs tag, value: "foobar" # not "baz"
  end

  test "passing an id overrides form builder" do
    form = ActionView::Helpers::FormBuilder.new :foo, nil, self, {}
    tag = combobox_tag :bar, form: form, id: :foobar

    assert_attrs tag, id: "foobar" # not "foo_bar"
  end

  test "passing open" do
    tag = combobox_tag :foo, open: true

    assert_attrs tag, tag_name: :fieldset, "data-hw-combobox-expanded-value": "true"
  end

  test "a11y attributes" do
    tag = combobox_tag :foo, id: :foobar

    assert_attrs tag, role: "combobox",
      "aria-controls": "foobar-hw-listbox", "aria-owns": "foobar-hw-listbox",
      "aria-haspopup": "listbox", "aria-autocomplete": "both"
  end

  test "passing option value, falls back to id" do
    option = OpenStruct.new id: 1, value: "foo"
    assert_equal "foo", hw_listbox_option_value(option)

    option = OpenStruct.new id: 1
    assert_equal 1, hw_listbox_option_value(option)
  end

  test "content falls back to display" do
    option = OpenStruct.new content: "foo"
    assert_equal "foo", hw_listbox_option_content(option)

    option = OpenStruct.new display: "bar"
    assert_equal "bar", hw_listbox_option_content(option)
  end

  test "filterable_as falls back to display" do
    option = OpenStruct.new filterable_as: "foo"
    assert_equal "foo", hw_listbox_option_filterable_as(option)

    option = OpenStruct.new display: "bar"
    assert_equal "bar", hw_listbox_option_filterable_as(option)
  end

  test "autocompletable_as falls back to display" do
    option = OpenStruct.new autocompletable_as: "foo"
    assert_equal "foo", hw_listbox_option_autocompletable_as(option)

    option = OpenStruct.new display: "bar"
    assert_equal "bar", hw_listbox_option_autocompletable_as(option)
  end

  test "hw_combobox_options instantiates an array of `HotwireCombobox::Option`s" do
    options = hw_combobox_options [
      { value: :foo, display: :bar },
      { value: :foobar, display: :barfoo }
    ]

    assert options.all? { |option| HotwireCombobox::Option === option }
  end

  test "combobox_options is an alias for hw_combobox_options" do
    assert_equal \
      HotwireCombobox::Helper.instance_method(:hw_combobox_options),
      HotwireCombobox::Helper.instance_method(:combobox_options)
  end

  test "combobox_options is not defined when bypassing convenience methods" do
    swap_config bypass_convenience_methods: true do
      assert_not HotwireCombobox::Helper.instance_methods.include?(:combobox_options)
    end
  end

  test "combobox_tag is an alias for hw_combobox_tag" do
    assert_equal \
      HotwireCombobox::Helper.instance_method(:hw_combobox_tag),
      HotwireCombobox::Helper.instance_method(:combobox_tag)
  end

  test "combobox_tag is not defined when bypassing convenience methods" do
    swap_config bypass_convenience_methods: true do
      assert_not HotwireCombobox::Helper.instance_methods.include?(:combobox_tag)
    end
  end

  private
    # `#assert_attrs` expects attrs to appear in the order they are passed.
    def assert_attrs(tag, tag_name: :input, **attrs)
      attrs = attrs.map do |k, v|
        %Q(#{escape(k)}="#{escape(v)}".*)
      end.join(" ")

      assert_match /<#{tag_name}.* #{attrs}/, tag
    end

    def escape(value)
      special_characters = Regexp.union "[]".chars
      value.to_s.gsub(special_characters) { |char| "\\#{char}" }
    end
end
