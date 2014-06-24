
############################################################################################################
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = 'STEP'
log                       = TRM.get_logger 'plain',     badge
info                      = TRM.get_logger 'info',      badge
whisper                   = TRM.get_logger 'whisper',   badge
alert                     = TRM.get_logger 'alert',     badge
debug                     = TRM.get_logger 'debug',     badge
warn                      = TRM.get_logger 'warn',      badge
help                      = TRM.get_logger 'help',      badge
urge                      = TRM.get_logger 'urge',      badge
echo                      = TRM.echo.bind TRM



#---------------------------------------------------------------------------------------------------------
@__chain = ( stepper_1, stepper_2, handler ) ->
  stepper_1 stepper_2, ( error, P... ) =>
    return handler error if error?
    handler null, P...

#---------------------------------------------------------------------------------------------------------
@_chain = ( stepper_1, stepper_2, handler ) ->
  return ->
    stepper_1 stepper_2, ( error, P... ) =>
      return handler error if error?
      handler null, P...

#---------------------------------------------------------------------------------------------------------
@chain = ( steppers..., handler ) ->
  return handler new Error "expected at least one stepper, got none" unless steppers.length > 0
  return steppers[ 0 ] if steppers.length is 1
  next = ( P... ) => handler P...
  for stepper in steppers
    next = @_chain stepper, next



  # #-------------------------------------------------------------------------------------------------------
  # interleave = ( handler ) ->
  #   STEP.interleaved source_stepper, ' | ', ( error, value ) ->
  #     return handler error if error?
  #     whisper 'interleave', value
  #     handler null, value

  # STEP.collected interleave ( error, values ) ->
  #   throw error if error?
  #   urge values
#---------------------------------------------------------------------------------------------------------
consumer = ->
  STEP = @

  #-------------------------------------------------------------------------------------------------------
  f = ( handler ) ->
    STEP.triplets source_stepper, ( error, last_value, this_value, next_value ) =>
      # whisper [ last_value, this_value, next_value, ]
      handler null, last_value, this_value, next_value
  #-------------------------------------------------------------------------------------------------------
  g = ( handler ) ->
    STEP.indexed f, ( error, P... ) ->
      handler null, P...
  #-------------------------------------------------------------------------------------------------------
  h = ( handler ) ->
    STEP.reversed g, ( error, P... ) ->
      handler null, P...
  #-------------------------------------------------------------------------------------------------------
  i = ( handler ) ->
    STEP.tabled h, ( error, table_rpr ) ->
      urge table_rpr
  #-------------------------------------------------------------------------------------------------------
  i()

  f = ( handler ) -> STEP.fenced source_stepper, '(', ')', ( error, P... ) ->
    throw error if error?
    # whisper P
    handler null, P...

  STEP.__chain STEP.indexed, f, ( error, idx, value ) ->
    throw error if error?
    log ( TRM.grey idx ), ( TRM.lime value )


#---------------------------------------------------------------------------------------------------------
# consumer()


# #-----------------------------------------------------------------------------------------------------------
# test_buffered_walker = ->
# #---------------------------------------------------------------------------------------------------------
# source_stepper = ( handler ) ->
#   x = 0
#   loop
#     handler null, x
#     x += 2
#     if x > 10
#       handler null, null
#       return
