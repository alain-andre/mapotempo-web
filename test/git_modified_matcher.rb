class GitModifiedMatcher
  class MyMatchData
    def initialize(result)
      @result = result
    end

    def to_a
      @result.values
    end

    def [](name)
      @result[name]
    end
  end

  def match(file)
    diff = `git diff --no-ext-diff --unified=0 --exit-code -a --no-prefix #{file}`
    modified_lines = diff.to_enum(:scan, /^@@ -\d+,?.* [+](\d+),?.* @@.*/).map { Regexp.last_match(1) }

    MyMatchData.new(file: file, lines: modified_lines.first)
  end
end
