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

                                 value = treeGet item, field

                                 if Array.isArray value

                                      if typeof projection[field] is "object"

                                          if typeof projection[field].$slice is "number"

                                              if projection[field].$slice >= 0

                                                  value = value.slice 0, projection[field].$slice

                                              else

                                                  value = value.slice projection[field].$slice

                                          if Array.isArray projection[field].$slice

                                              [skip, limit] = projection[field].$slice

                                              value = value.slice skip, skip + limit

                                 treeSet res, field, value if typeof value != "undefined"

                         result.push res

                     return result



