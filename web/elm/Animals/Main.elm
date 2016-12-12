module Animals.Main exposing (..)

import Animals.Msg exposing (..)
import Animals.OutsideWorld as OutsideWorld
import Animals.Navigation as MyNav
import Animals.Animal.Types as Animal
import Animals.Animal.Aggregates as Aggregate

import String
import List
import Date exposing (Date)
import Pile.Calendar exposing (EffectiveDate(..))
import Pile.UpdatingLens exposing (lens)
import Return


-- Model and Init
type alias Flags =
  { csrfToken : String
  }

type alias Model = 
  { page : MyNav.PageChoice
  , csrfToken : String
  , animals : Aggregate.VisibleAggregate
  , nameFilter : String
  , tagFilter : String
  , speciesFilter : String
  , effectiveDate : EffectiveDate
  , today : Maybe Date
  , datePickerOpen : Bool
  }

model_page = lens .page (\ p w -> { w | page = p })
model_today = lens .today (\ p w -> { w | today = p })
model_animals = lens .animals (\ p w -> { w | animals = p })
model_tagFilter = lens .tagFilter (\ p w -> { w | tagFilter = p })
model_speciesFilter = lens .speciesFilter (\ p w -> { w | speciesFilter = p })
model_nameFilter = lens .nameFilter (\ p w -> { w | nameFilter = p })
model_effectiveDate = lens .effectiveDate (\ p w -> { w | effectiveDate = p })
model_datePickerOpen = lens .datePickerOpen (\ p w -> { w | datePickerOpen = p })



init : Flags -> MyNav.PageChoice -> ( Model, Cmd Msg )
init flags startingPage =
  let
    model =
      { page = startingPage
      , csrfToken = flags.csrfToken
      , animals = Aggregate.emptyAggregate
      , nameFilter = ""
      , tagFilter = ""
      , speciesFilter = ""
      , effectiveDate = Today
      , today = Nothing
      , datePickerOpen = False
      }
  in
    model ! [OutsideWorld.askTodaysDate, OutsideWorld.fetchAnimals]

-- Update

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NavigateToAllPage ->
      MyNav.toAllPagePath model
    NavigateToAddPage ->
      MyNav.toAddPagePath model
    NavigateToHelpPage ->
      MyNav.toHelpPagePath model

    SetToday value ->
      model_today.set value model ! []
    SetAnimals animals ->
      model_animals.set (Aggregate.asAggregate animals) model ! []

    ToggleDatePicker ->
      model_datePickerOpen.update not model ! []
    SelectDate date ->
      model_effectiveDate.set (At date) model ! []
      
    SetNameFilter s ->
      model_nameFilter.set s model ! []
    SetTagFilter s ->
      model_tagFilter.set s model ! []
    SetSpeciesFilter s ->
      model_speciesFilter.set s model ! []

    MoreLikeThisAnimal id ->
      ( model 
      , Cmd.none
      )

    UpsertCompactAnimal animal flash ->
      (Animal.DisplayedAnimal animal Animal.Compact flash |> upsert model) ! []
          
    UpsertExpandedAnimal animal flash ->
      (Animal.DisplayedAnimal animal Animal.Expanded flash |> upsert model) ! []

    UpsertEditableAnimal animal form flash -> 
      (withCheckedChanges animal form flash model |> upsert model) ! []
        
    ReviseDisplayedAnimal displayed ->
      (displayed |> upsert model) ! []
      
    NoOp ->
      model ! []

withCheckedChanges animal form flash model =
  Animal.DisplayedAnimal animal (Animal.Editable form) flash

upsert model displayed =
  model_animals.update (Aggregate.upsert displayed) model
  

-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
