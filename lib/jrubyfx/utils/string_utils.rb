class String

  # steal handy methods from activesupport
  # Tries to find a constant with the name specified in the argument string.
  #
  # 'Module'.constantize # => Module
  # 'Test::Unit'.constantize # => Test::Unit
  #
  # The name is assumed to be the one of a top-level constant, no matter
  # whether it starts with "::" or not. No lexical context is taken into
  # account:
  #
  # C = 'outside'
  # module M
  # C = 'inside'
  # C # => 'inside'
  # 'C'.constantize # => 'outside', same as ::C
  # end
  #
  # NameError is raised when the name is not in CamelCase or the constant is
  # unknown.
  def constantize(splitter="::")
    camel_cased_word = self
    names = camel_cased_word.split(splitter)
    names.shift if names.empty? || names.first.empty?

    names.inject(Object) do |constant, name|
      if constant == Object
        constant.const_get(name)
      else
        candidate = constant.const_get(name)
        next candidate if constant.const_defined?(name, false)
        next candidate unless Object.const_defined?(name)

        # Go down the ancestors to check it it's owned
        # directly before we reach Object or the end of ancestors.
        constant = constant.ancestors.inject do |const, ancestor|
          break const if ancestor == Object
          break ancestor if ancestor.const_defined?(name, false)
          const
        end

        # owner is in Object, so raise
        constant.const_get(name, false)
      end
    end
  end

  # Tries to find a constant with the name specified in the argument string.
  #
  # 'Module'.safe_constantize # => Module
  # 'Test::Unit'.safe_constantize # => Test::Unit
  #
  # The name is assumed to be the one of a top-level constant, no matter
  # whether it starts with "::" or not. No lexical context is taken into
  # account:
  #
  # C = 'outside'
  # module M
  # C = 'inside'
  # C # => 'inside'
  # 'C'.safe_constantize # => 'outside', same as ::C
  # end
  #
  # +nil+ is returned when the name is not in CamelCase or the constant (or
  # part of it) is unknown.
  #
  # 'blargle'.safe_constantize # => nil
  # 'UnknownModule'.safe_constantize # => nil
  # 'UnknownModule::Foo::Bar'.safe_constantize # => nil
  def safe_constantize()
    constantize(self)
  rescue NameError => e
    raise unless e.message =~ /(uninitialized constant|wrong constant name) #{const_regexp(self)}$/ ||
      e.name.to_s == self.to_s
  rescue ArgumentError => e
    raise unless e.message =~ /not missing constant #{const_regexp(self)}\!$/
  end
end
