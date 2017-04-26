# Bootstrap the runtime. This is where we assemble all the classes and objects together
# to form the runtime.
                                            # What's happening in the runtime:
Liza_class = Liza.new            #  Class
Liza_class.runtime_class = Liza_class #  Class.class = Class
object_class = Liza.new             #  Object = Class.new
object_class.runtime_class = Liza_class  #  Object.class = Class

# Create the Runtime object (the root context) on which all code will start its
# evaluation.
Runtime = Context.new(object_class.new)

Runtime["Class"] = Liza_class
Runtime["Object"] = object_class
Runtime["Number"] = Liza.new
Runtime["String"] = Liza.new

# Everything is an object in our language, even true, false and nil. So they need
# to have a class too.
Runtime["TrueClass"] = Liza.new
Runtime["FalseClass"] = Liza.new
Runtime["NilClass"] = Liza.new

Runtime["true"] = Runtime["TrueClass"].new_with_value(true)
Runtime["false"] = Runtime["FalseClass"].new_with_value(false)
Runtime["nil"] = Runtime["NilClass"].new_with_value(nil)

# Add a few core methods to the runtime.

# Add the `new` method to classes, used to instantiate a class:
#  eg.: Object.new, Number.new, String.new, etc.
Runtime["Class"].runtime_methods["new"] = proc do |receiver, arguments|
  receiver.new
end

# Print an object to the console.
# eg.: print("hi there!")
Runtime["Object"].runtime_methods["print"] = proc do |receiver, arguments|
  puts arguments.first.ruby_value
  Runtime["nil"]
end
