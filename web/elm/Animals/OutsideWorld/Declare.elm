module Animals.OutsideWorld.Declare exposing (..)

import Animals.Animal.Types exposing (..)

import Dict exposing (Dict)

type AnimalSaveResults
  = AnimalUpdated Id Int

type alias SuccessfulAnimalCreation = 
  { temporaryId : Id
  , permanentId : Id
  }

type alias IncomingAnimal =
    { id : Int
    , version : Int
    , name : String
    , species : String
    , tags : List String
    , int_properties : Dict String ( Int, String )
    , bool_properties : Dict String ( Bool, String )
    , string_properties : Dict String ( String, String )
    }

