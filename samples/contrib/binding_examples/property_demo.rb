#!/usr/bin/env jruby
=begin
Original Java source from: http://docs.oracle.com/javafx/2/binding/jfxpub-binding.htm
/*
 * Copyright (c) 2011, 2012 Oracle and/or its affiliates.
 * All rights reserved. Use is subject to license terms.
 *
 * This file is available and licensed under the following license:
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *  - Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  - Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the distribution.
 *  - Neither the name of Oracle nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
=end

require 'jrubyfx'

class Bill
  import javafx.beans.property.SimpleDoubleProperty

  attr_accessor :amount_due
  
  def initialize
    @amount_due = SimpleDoubleProperty.new
  end

  def amount_due
    @amount_due.get
  end

  def amount_due=(value)
    @amount_due.set(value)
  end

  def amount_due_prop
    @amount_due
  end
end

def main
  electric_bill = Bill.new
  electric_bill.amount_due_prop.add_change_listener do |obj, old_val, new_val|
    puts "Electric bill has changed!"
  end
  electric_bill.amount_due = 100.0

  bill1, bill2, bill3 = Bill.new, Bill.new, Bill.new
  total = Java::javafx.beans.binding.Bindings.add(bill1.amount_due_prop.add(
    bill2.amount_due_prop), bill3.amount_due_prop)

  total.add_change_listener do |observable|
    puts "The binding is now invalid"
  end

  # First call makes the binding invalid
  bill1.amount_due = 200.0

  # The binding is now invalid
  bill2.amount_due = 100.0
  bill3.amount_due = 75.0

  # Make the binding valid
  puts total.value

  # Make invalid...
  bill3.amount_due = 150.0

  # Make valid
  puts total.value
end

main
