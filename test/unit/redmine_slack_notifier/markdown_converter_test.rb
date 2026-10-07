# frozen_string_literal: true

require File.expand_path("../../test_helper", __dir__)

class RedmineSlackNotifier::MarkdownConverterTest < ActiveSupport::TestCase
  def test_converts_bold
    assert_equal "*text*", RedmineSlackNotifier::MarkdownConverter.to_slack_mrkdwn("**text**")
    assert_equal "*text*", RedmineSlackNotifier::MarkdownConverter.to_slack_mrkdwn("__text__")
  end

  def test_converts_italic
    assert_equal "_text_", RedmineSlackNotifier::MarkdownConverter.to_slack_mrkdwn("*text*")
  end

  def test_converts_strikethrough
    assert_equal "~text~", RedmineSlackNotifier::MarkdownConverter.to_slack_mrkdwn("~~text~~")
  end

  def test_converts_headers_to_bold
    assert_equal "*見出し*\n", RedmineSlackNotifier::MarkdownConverter.to_slack_mrkdwn("## 見出し\n")
  end

  def test_converts_links
    assert_equal "<https://example.com|リンク>",
                 RedmineSlackNotifier::MarkdownConverter.to_slack_mrkdwn("[リンク](https://example.com)")
  end

  def test_converts_list_items
    assert_equal "• item\n", RedmineSlackNotifier::MarkdownConverter.to_slack_mrkdwn("- item\n")
  end

  def test_escapes_html_special_chars_outside_syntax
    assert_equal "a &lt; b &amp; b &gt; c", RedmineSlackNotifier::MarkdownConverter.to_slack_mrkdwn("a < b & b > c")
  end

  def test_keeps_code_blocks_untouched_by_markdown_conversion
    input = "```\n**not bold**\n```"
    assert_equal input, RedmineSlackNotifier::MarkdownConverter.to_slack_mrkdwn(input)
  end

  def test_returns_empty_string_for_nil
    assert_equal "", RedmineSlackNotifier::MarkdownConverter.to_slack_mrkdwn(nil)
  end
end
