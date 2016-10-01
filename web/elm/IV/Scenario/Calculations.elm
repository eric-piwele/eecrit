module IV.Scenario.Calculations exposing (..)

import IV.Types exposing (..)
import IV.Scenario.Main exposing (Model)
import IV.Pile.ManagedStrings exposing (floatString)

startingFractionBagFilled : Model -> Float
startingFractionBagFilled model =
  (model.bagContentsInLiters / model.bagCapacityInLiters)

  
endingFractionBagFilled : Model -> Float
endingFractionBagFilled model =
  0.5

  
dropsPerSecond : Model -> DropsPerSecond
dropsPerSecond model =
  model.dripText |> floatString |> DropsPerSecond


fractionalHours model =
  let
    hours = model.simulationHoursText |> floatString
    minutes = model.simulationMinutesText |> floatString
  in
    hours + (minutes / 60.0)

