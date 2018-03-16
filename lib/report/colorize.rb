require 'colorize'

# Monkeypatches colorize to handle ANSI colors correctly
module Text
  # Patched Table class
  class Table
    STRIP_COLORS = /\e\[(\d+;){0,2}\d+m/

    def column_widths #:nodoc:
      @column_widths ||= \
        all_text_table_rows.reject { |row| row.cells == :separator }.map do |row|
          row.cells.map do |cell|
            [(cell.value.gsub(STRIP_COLORS, '').length / cell.colspan.to_f).ceil] * cell.colspan
          end.flatten
        end.transpose.map(&:max)
    end

    # Patched Cell class
    class Cell
      def to_s #:nodoc:
        uncolorized = value.gsub(STRIP_COLORS, '')
        cell_content = case align
                       when :left
                         (uncolorized.ljust cell_width).sub(uncolorized, value)
                       when :right
                         (uncolorized.rjust cell_width).sub(uncolorized, value)
                       when :center
                         (uncolorized.center cell_width).sub(uncolorized, value)
                       end
        ([' ' * table.horizontal_padding] * 2).join cell_content
      end
    end
  end
end
