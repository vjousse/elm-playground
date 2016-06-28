module Controls exposing (..)

import Html exposing (div, h1, text, Html)
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


type Msg
    = NoOp



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Audio player" ]
        ]
