require 'test_helper'
require 'support/crud_test_model'

class FormatHelperTest < ActionView::TestCase

  include UtilityHelper
  include I18nHelper
  include CrudTestHelper

  setup :reset_db, :setup_db, :create_test_data
  teardown :reset_db

  def format_size(obj)
    "#{f(obj.size)} items"
  end

  def format_string_size(obj)
    "#{f(obj.size)} chars"
  end

  test "labeled text as block" do
    result = labeled("label") { "value" }

    assert result.html_safe?
    assert_dom_equal "<div class='labeled'> <label>label</label> <div class='value'>value</div> </div>", result.squish
  end

  test "labeled text empty" do
    result = labeled("label", "")

    assert result.html_safe?
    assert_dom_equal "<div class='labeled'> <label>label</label> <div class='value'>#{EMPTY_STRING}</div> </div>", result.squish
  end

  test "labeled text as content" do
    result = labeled("label", "value <unsafe>")

    assert result.html_safe?
    assert_dom_equal "<div class='labeled'> <label>label</label> <div class='value'>value &lt;unsafe&gt;</div> </div>", result.squish
  end

  test "labeled attr" do
    result = labeled_attr('foo', :size)
    assert result.html_safe?
    assert_dom_equal "<div class='labeled'> <label>Size</label> <div class='value'>3 chars</div> </div>", result.squish
  end

  test "format Fixnums" do
    assert_equal "0", f(0)
    assert_equal "10", f(10)
    assert_equal "10,000,000", f(10000000)
  end

  test "format Floats" do
    assert_equal "1.000", f(1.0)
    assert_equal "1.200", f(1.2)
    assert_equal "3.142", f(3.14159)
  end

  test "format Booleans" do
    assert_equal "yes", f(true)
    assert_equal "no", f(false)
  end

  test "format nil" do
    assert EMPTY_STRING.html_safe?
    assert_equal EMPTY_STRING, f(nil)
  end

  test "format Strings" do
    assert_equal "blah blah", f("blah blah")
    assert_equal "<injection>", f("<injection>")
    assert !f("<injection>").html_safe?
  end

  test "format attr with fallthrough to f" do
    assert_equal "12.234", format_attr("12.23424", :to_f)
  end

  test "format attr with custom format_string_size method" do
    assert_equal "4 chars", format_attr("abcd", :size)
  end

  test "format attr with custom format_size method" do
    assert_equal "2 items", format_attr([1,2], :size)
  end

  test "format integer column" do
    m = crud_test_models(:AAAAA)
    assert_equal '9', format_type(m, :children)

    m.children = 10000
    assert_equal '10,000', format_type(m, :children)
  end

  test "format float column" do
    m = crud_test_models(:AAAAA)
    assert_equal '1.100', format_type(m, :rating)

    m.rating = 3.145001   # you never know with these floats..
    assert_equal '3.145', format_type(m, :rating)
  end

  test "format decimal column" do
    m = crud_test_models(:AAAAA)
    assert_equal '10,000,000.100', format_type(m, :income)
  end

  test "format date column" do
    m = crud_test_models(:AAAAA)
    assert_equal '1910-01-01', format_type(m, :birthdate)
  end

  test "format time column" do
    m = crud_test_models(:AAAAA)
    assert_equal '01:01', format_type(m, :gets_up_at)
  end

  test "format datetime column" do
    m = crud_test_models(:AAAAA)
    assert_equal "2010-01-01 11:21", format_type(m, :last_seen)
  end

  test "format text column" do
    m = crud_test_models(:AAAAA)
    assert_equal "<p>AAAAA BBBBB CCCCC\n<br />AAAAA BBBBB CCCCC\n</p>", format_type(m, :remarks)
    assert format_type(m, :remarks).html_safe?
  end

  test "format belongs to column without content" do
    m = crud_test_models(:AAAAA)
    assert_equal t(:'global.associations.no_entry'), format_attr(m, :companion)
  end

  test "format belongs to column with content" do
    m = crud_test_models(:BBBBB)
    assert_equal "AAAAA", format_attr(m, :companion)
  end

  test "format has_many column with content" do
    m = crud_test_models(:CCCCC)
    assert_equal "<ul><li>AAAAA</li><li>BBBBB</li></ul>", format_attr(m, :others)
  end

  test "captionize" do
    assert_equal "Camel Case", captionize(:camel_case)
    assert_equal "All Upper Case", captionize("all upper case")
    assert_equal "With Object", captionize("With object", Object.new)
    assert !captionize('bad <title>').html_safe?
  end

end
