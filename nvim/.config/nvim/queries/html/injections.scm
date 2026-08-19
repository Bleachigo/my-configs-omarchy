; extends
((style_element
   (start_tag
     (attribute
       (attribute_name) @_name
       (quoted_attribute_value (attribute_value) @_value)))
   (raw_text) @injection.content)
 (#eq? @_name "type")
 (#eq? @_value "text/tailwindcss")
 (#set! injection.language "css"))
