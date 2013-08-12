util = require 'util'
siftprojection = require '../src/sift-projection'

module.exports =

    setUp: (callback) ->

               @data = [
                   a: 1
                   b: 1
                   c: 1
                   d: [1, 2, 3]
                   e:
                       f1: 1
                       f2: 2
               ,
                   a: 2
                   b: 2
                   c: 2
                   d: [3, 4, 5]
                   e:
                       f1: 3
                       f2: 4
               ,
                   a: 3
                   b: 3
                   c: 3
                   d: [6, 7, 8]
                   e:
                       f1: 5
                       f2: 6
               ]

               callback null

    hashFilter: (test) ->

                    projection =
                        a: 1
                        c: 1

                    results = siftprojection projection, @data

                    test.equals results.length, 3, "All items should be presented"

                    for result in results

                        test.equals typeof result.a, 'number', 'a should be presented'
                        test.equals typeof result.c, 'number', 'c should be presented'
                        test.equals typeof result.b, 'undefined', 'b should be absent'

                    test.done()

    hashWithZeroes: (test) ->

                        projection =
                            a: 0
                            c: 1

                        results = siftprojection projection, @data

                        test.equals results.length, 3, "All items should be presented"

                        for result in results

                            test.equals typeof result.a, 'number', 'a should be presented'
                            test.equals typeof result.c, 'number', 'c should be presented'

                        test.done()

    allButExcluded: (test) ->

                        projection =
                            a: 0
                            c: 0

                        results = siftprojection projection, @data

                        test.equals results.length, 3, "All items should be presented"

                        for result in results

                            test.equals typeof result.a, 'undefined', 'a should be absent'
                            test.equals typeof result.c, 'undefined', 'c should be absent'

                        test.done()

    slice: (test) ->

               projection =
                   b: 1
                   d: $slice: 2

               results = siftprojection projection, @data

               test.equals results.length, 3, "All items should be presented"

               for result in results

                   test.equals typeof result.a, 'undefined', 'a should be absent'
                   test.equals typeof result.c, 'undefined', 'c should be absent'
                   test.equals typeof result.b, 'number', 'b should be presented'
                   test.ok Array.isArray, result.d, 'd should be an array'
                   test.equals result.d.length, 2, 'array should have only two values'

               test.done()

    negativeSlice: (test) ->

                       projection =
                           b: 1
                           d: $slice: -2

                       results = siftprojection projection, @data

                       test.equals results.length, 3, "All items should be presented"

                       console.log results

                       for result in results

                           test.equals typeof result.a, 'undefined', 'a should be absent'
                           test.equals typeof result.c, 'undefined', 'c should be absent'
                           test.equals typeof result.b, 'number', 'b should be presented'
                           test.ok Array.isArray, result.d, 'd should be an array'
                           test.equals result.d.length, 2, 'array should have only two values'

                       test.done()


    sliceArray: (test) ->

                    projection =
                        b: 1
                        d: $slice: [1, 2]

                    results = siftprojection projection, @data

                    test.equals results.length, 3, "All items should be presented"

                    console.log 'results', results

                    for result, position in results

                        test.equals typeof result.a, 'undefined', 'a should be absent'
                        test.equals typeof result.c, 'undefined', 'c should be absent'
                        test.equals typeof result.b, 'number', 'b should be presented'
                        test.ok Array.isArray, result.d, 'd should be an array'
                        test.equals result.d.length, 2, 'array should have only two values'
                        test.equals result.d[0], @data[position].d[1]
                        test.equals result.d[1], @data[position].d[2]

                    test.done()


    subDocuments: (test) ->

                      projection =
                          b: 1
                          "e.f2": 1

                      results = siftprojection projection, @data

                      test.equals results.length, 3, "All items should be presented"

                      for result in results

                          test.equals typeof result.a, 'undefined', 'a should be absent'
                          test.equals typeof result.c, 'undefined', 'c should be absent'
                          test.equals typeof result.b, 'number', 'b should be presented'
                          test.equals typeof result.e, 'object', 'e should be subdocument'
                          test.equals typeof result.e.f2, 'number', 'e.f2 should be subdocument field'

                      test.done()

    nonExistentSubDocument: (test) ->

                                projection =
                                    b: 1
                                    "e.f3": 1

                                results = siftprojection projection, @data

                                test.equals results.length, 3, "All items should be presented"

                                for result in results

                                    test.equals typeof result.a, 'undefined', 'a should be absent'
                                    test.equals typeof result.c, 'undefined', 'c should be absent'
                                    test.equals typeof result.b, 'number', 'b should be presented'
                                    test.equals typeof result.e, 'undefined', 'e should be absent'

                                test.done()

    nestedArray: (test) ->

                     data = [
                         c: 1
                         a:
                             b: [1, 2, 3, 4, 5]
                     ]

                     projection =
                         'a.b':
                             $slice: 2

                     results = siftprojection projection, data

                     console.log 'results', util.inspect results, true, 18

                     test.equals results.length, 1
                     test.equals 'object', typeof results[0].a
                     test.ok Array.isArray results[0].a.b
                     test.equals results[0].a.b.length, 2

                     test.done()



    nestedNegativeArraySlice: (test) ->

                                  data = [
                                      c: 1
                                      a:
                                          b: [1, 2, 3, 4, 5]
                                  ]

                                  projection =
                                      'a.b':
                                          $slice: [-3, 2]

                                  results = siftprojection projection, data

                                  console.log 'results', util.inspect results, true, 18

                                  test.equals results.length, 1
                                  test.equals 'object', typeof results[0].a
                                  test.ok Array.isArray results[0].a.b
                                  test.equals results[0].a.b.length, 2
                                  test.equals results[0].a.b[0], 3
                                  test.equals results[0].a.b[1], 4

                                  test.done()