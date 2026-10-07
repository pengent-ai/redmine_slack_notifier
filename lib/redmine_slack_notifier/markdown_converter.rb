# frozen_string_literal: true

module RedmineSlackNotifier
  # RedmineのMarkdown(CommonMark相当)の記法をSlackのmrkdwn記法へ変換する。
  # 見出し・リストはSlackのmrkdwnに対応する記法が無いため、代替表現へ変換する。
  module MarkdownConverter
    module_function

    def to_slack_mrkdwn(text)
      return "" if text.nil?

      convert_outside_code_blocks(escape_slack(text.to_s)) do |line|
        line = convert_headers(line)
        line = convert_links(line)
        line = convert_emphasis(line)
        line = convert_strikethrough(line)
        convert_list_items(line)
      end
    end

    def escape_slack(text)
      text.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
    end

    def convert_headers(line)
      line.gsub(/^\#{1,6}\s+(.+)$/) { "*#{$1}*" }
    end

    def convert_links(line)
      line.gsub(/\[([^\]]+)\]\((https?:\/\/[^\s)]+)\)/) { "<#{$2}|#{$1}>" }
    end

    def convert_emphasis(line)
      line = line.gsub(/\*\*([^*\n]+?)\*\*/) { "\u0001#{$1}\u0001" }
      line = line.gsub(/__([^_\n]+?)__/) { "\u0001#{$1}\u0001" }
      line = line.gsub(/\*([^*\n]+?)\*/) { "_#{$1}_" }
      line.gsub(/\u0001([^\u0001]+?)\u0001/) { "*#{$1}*" }
    end

    def convert_strikethrough(line)
      line.gsub(/~~([^~\n]+?)~~/) { "~#{$1}~" }
    end

    def convert_list_items(line)
      line.gsub(/^(\s*)[-*+]\s+/) { "#{$1}• " }
    end

    def convert_outside_code_blocks(text)
      text.split(/(```.*?```)/m).each_with_index.map do |segment, index|
        next segment if index.odd?

        segment.lines.map { |line| yield(line) }.join
      end.join
    end
  end
end
