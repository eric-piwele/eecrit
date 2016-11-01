module IV.Scenario.View exposing
  ( viewScenarioChoices
  , viewCaseBackgroundEditor
  , viewTreatmentEditor
  )

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import IV.Scenario.Model exposing (EditableModel, scenario, cowBackground, calfBackground, editableBackground)
import IV.Scenario.DataExport as DataExport
import IV.Scenario.Msg exposing (Msg(..))
import IV.Msg as MainMsg
import Html.Events as Events
import IV.Pile.HtmlShorthand exposing (..)
import String


-- Top row of buttons

viewScenarioChoices : EditableModel -> Html MainMsg.Msg    
viewScenarioChoices model =
  nav []
    [ ul [ class "nav nav-pills pull-right" ]
        [ scenarioChoice (scenario cowBackground) model
        , scenarioChoice (scenario calfBackground) model
        , editChoice (scenario editableBackground) model
        ]
    ]

scenarioChoice possible current =
  navChoice
    possible.background.tag
    (MainMsg.PickedScenario possible)
    (possible.background.tag == current.background.tag)
         
editChoice possible current =
  navChoice
    possible.background.tag
    MainMsg.OpenCaseBackgroundEditor
    (possible.background.tag == current.background.tag)
         

-- Case background editor
  
viewCaseBackgroundEditor model =
  div
  [ class "row"
  , style
      [ ("border", "2px solid #AAA")
      , ("padding", "2em")
      , ("margin-bottom", "2em")
      , ("margin-left", "3em")
      , ("margin-right", "3em")
      , displayStyle model.caseBackgroundEditorOpen
      ]
    ]
  [ row [] [text "Set: "]
  , row []
    [ text "... the container's "
    , b [] [text "capacity"]
    , text " in liters "
    , textInput [] model.background.bagCapacityInLiters (changedText ChangedBagCapacity)
    ]
  , row []
    [ text "... the container's "
    , b [] [text "starting contents"]
    , text " in liters "
    , textInput [] model.background.bagContentsInLiters (changedText ChangedBagContents)
    , contentWarning model
    ]
    , row []
      [ text "... the number of drops per ml "
      , textInput [] model.background.dropsPerMil (changedText ChangedDropsPerMil)
      ]
  , p [] [text " "]
  , row [ class "col-sm-12" ]
    [ launchWhenDoneButton 
        MainMsg.CloseCaseBackgroundEditor
        (backgroundNeedsMoreWork model)
        "Work With This"
    ]
  ]
  
contentWarning model =
  let 
    warning = if contentsTooBig model then
                " Content exceeds the capacity!"
              else
                ""
  in
    span [style [("color", "red")]] [text warning]
            

contentsTooBig model =
  let
    val field = Result.withDefault 0 (String.toFloat field)
    contentsText = model.background.bagContentsInLiters
    capacityText = model.background.bagCapacityInLiters
  in
    not (unfinishedField capacityText)
    && (val contentsText) > (val capacityText)
    
backgroundNeedsMoreWork model =
  unfinishedField model.background.bagCapacityInLiters
  || unfinishedField model.background.bagContentsInLiters
  || unfinishedField model.background.dropsPerMil
  || contentsTooBig model

-- Treatment editor
    
description model =
  "You are presented with " ++
  model.background.animalDescription ++ ". You have " ++
  model.background.bagContentsInLiters ++
  " liters of fluid in a " ++ 
  model.background.bagType ++ " that holds " ++
  model.background.bagCapacityInLiters ++ " liters."



treatmentTextColor model =
  let
    color = case model.caseBackgroundEditorOpen of
              True -> "grey"
              False -> "black"
  in
    style [ ("color", color)
          , ("background-color", "white")
          ]
    

viewTreatmentEditor : EditableModel -> Html MainMsg.Msg
viewTreatmentEditor model =
  row [ treatmentTextColor model ]
    [ p [] [text <| description model ] 
    , p
        []
        [ text "Using your calculations, set the drip rate to "
        , textInput
            [ Events.onBlur <| (MainMsg.ChoseDripRate (DataExport.dripRate model))
            , disabled model.caseBackgroundEditorOpen
            ]
            model.decisions.dripRate
            (changedText ChangedDripText)
        , text "drops/sec, set the hours "
        , textInput
            [ disabled model.caseBackgroundEditorOpen ]
            model.decisions.simulationHours (changedText ChangedHoursText)
        , text " and minutes "
        , textInput
            [ disabled model.caseBackgroundEditorOpen ]
            model.decisions.simulationMinutes (changedText ChangedMinutesText)
        , text " until you plan to next look at the fluid level, then " 
        , launchWhenDoneButton
            (MainMsg.StartSimulation <| DataExport.runnableModel model)
            (treatmentNeedsMoreUserWork model)
            "Start the Clock"
        ]
    , p []
      [ text "To start over, click one of the buttons at the top." ]
    ]

unfinishedField string =
  case String.toFloat string of
    Err _ -> True
    Ok x -> x == 0.0
            
treatmentNeedsMoreUserWork model =
  model.caseBackgroundEditorOpen
  || unfinishedField model.decisions.dripRate
  || (   unfinishedField model.decisions.simulationHours
      && unfinishedField model.decisions.simulationMinutes)

-- Private

changedText : (String -> Msg) -> String -> MainMsg.Msg
changedText msg string =
  local (msg string)

local : Msg -> MainMsg.Msg
local msg =
  MainMsg.ToScenario msg


