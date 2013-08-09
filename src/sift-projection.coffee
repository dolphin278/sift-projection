treeGet = (obj, path) ->

              return obj if typeof obj != "object"
              return obj if path == ''

              props = path.split '.'
              nextProp = props.shift()

              return treeGet(obj[nextProp], props.join '.')

treeSet = (obj, path, value) ->

              if '.' not in path

                  obj[path] = value

              else
                  props = path.split '.'
                  nextProp = props.shift()

                  obj[nextProp] ?= {}

                  treeSet obj[nextProp], props.join('.'), value


module.exports = (projection, data) ->

                     return new Error 'data must be array' unless Array.isArray data

                     result = []

                     allButPresented = true

                     for own item of projection

                         if projection[item] > 0 or typeof projection[item] == 'object'

                             allButPresented = false
                             break

                     for item in data

                         res = {}

                         if allButPresented

                             for own field of item
                                 res[field] = item[field] if typeof projection[field] is 'undefined'

                         else
                             for own field of projection

                                 if '.' in field

                                     value = treeGet item, field

                                     value = value.slice 0, projection[field].$slice if Array.isArray(value) and typeof projection[field].$slice is 'number'

                                     treeSet res, field, value if typeof value != "undefined"

                                 else
                                     if typeof projection[field] == 'object'

                                         res[field] = item[field].slice 0, projection[field].$slice if typeof projection[field].$slice is 'number'

                                     else

                                         res[field] ?= item[field]



                         result.push res

                     return result



