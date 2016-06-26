module Controls exposing (..)

import Debug


-- MODEL


type alias Model =
    { play : Bool
    , stop : Bool
    , forward : Bool
    , backward : Bool
    , slower : Float
    , faster : Bool
    }
