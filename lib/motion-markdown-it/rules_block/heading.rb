# heading (#, ##, ...)
#------------------------------------------------------------------------------
module MarkdownIt
  module RulesBlock
    class Heading
      extend Common::Utils

      #------------------------------------------------------------------------------
      def self.heading(state, startLine, endLine, silent)
        pos = state.bMarks[startLine] + state.tShift[startLine]
        max = state.eMarks[startLine]
        ch  = state.src.charCodeAt(pos)

        return false if (ch != 0x23 || pos >= max)

        # count heading level
        level = 1
        pos  += 1
        ch = state.src.charCodeAt(pos)
        while (ch == 0x23 && pos < max && level <= 6)  # '#'
          level += 1
          pos   += 1
          ch = state.src.charCodeAt(pos)
        end

        return false if (level > 6 || (pos < max && ch != 0x20))  # space

        return true if (silent)

        # Let's cut tails like '    ###  ' from the end of string

        max = state.skipSpacesBack(max, pos)
        tmp = state.skipCharsBack(max, 0x23, pos) # '#'
        if (tmp > pos && isSpace(state.src.charCodeAt(tmp - 1)))
          max = tmp
        end

        state.line = startLine + 1

        token          = state.push('heading_open', "h#{level.to_s}", 1)
        token.markup   = '########'.slice(0...level)
        token.map      = [ startLine, state.line ]

        token          = state.push('inline', '', 0)
        token.content  = state.src.slice(pos...max).strip
        token.map      = [ startLine, state.line ]
        token.children = []

        token        = state.push('heading_close', "h#{level.to_s}", -1)
        token.markup = '########'.slice(0...level)

        return true
      end

    end
  end
end
