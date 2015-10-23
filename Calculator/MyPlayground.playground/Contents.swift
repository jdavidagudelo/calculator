//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"
var value = 0.0
var x = "\(value)"
var stack = [1, 2, 3, 5]
var mapped = stack.map{"x = \($0)"}
mapped
var reduced = stack.reduce("", combine: {"\($0)\($1),"})
var range = Range<String.Index>(start: reduced.startIndex, end: reduced.startIndex.advancedBy(reduced.characters.count-1))
reduced.substringWithRange(range)

