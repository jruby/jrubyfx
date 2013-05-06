=begin
/*
 * Copyright (c) 2012, 2013 Oracle and/or its affiliates.
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
=end

#package fxmltableview;
#
#import java.text.Format;
#import javafx.geometry.Pos;
#import javafx.scene.Node;
#import javafx.scene.control.TableCell;
#import javafx.scene.control.TableColumn;
#import javafx.scene.text.TextAlignment;
#import javafx.util.Callback;

class FormattedTableCellFactory
  include Java::javafx.util.Callback
  include JRubyFX
  
  fxml_raw_accessor :alignment, Java::javafx.scene.text.TextAlignment
  fxml_raw_accessor :format, java.text.Format
  
  # workaround for https://github.com/jruby/jruby/issues/709
  def java_kind_of?(*args)
    false
  end
  # workaround for above bug
  def java_class
    Java::javafx.util.Callback.java_class
  end

  def call(param)
    cell = FormattedTableCellFactory_TableCell.new(@format)
    cell.setTextAlignment(@alignment);
    case (@alignment)
    when Java::javafx.scene.text.TextAlignment::CENTER
      cell.setAlignment(Java::javafx.geometry.Pos::CENTER);
    when Java::javafx.scene.text.TextAlignment::RIGHT
      cell.setAlignment(Java::javafx.geometry.Pos::CENTER_RIGHT);
    else
      cell.setAlignment(Java::javafx.geometry.Pos::CENTER_LEFT);
    end
    return cell;
  end
end


class FormattedTableCellFactory_TableCell < Java::javafx.scene.control.TableCell
  def initialize(format)
    super()
    @format = format
  end
  
  def updateItem(item, empty) 
    if (item == getItem()) 
      return;
    end
    super(item, empty);
    if (item == nil)
      setText(nil);
      setGraphic(nil);
    elsif (@format != nil)
      setText(@format.format(item));
    elsif (item.is_a? Node)
      setText(nil);
      setGraphic( item);
    else
      setText(item.to_s);
      setGraphic(nil);
    end
  end
end