module Controls exposing (Model, Msg(..), init, view)

import Html exposing (div, h1, text, Html)
import Debug


-- MODEL


type alias Model =
    { play : Bool
    , stop : Bool
    , forward : Bool
    , backward : Bool
    , slower : Bool
    , faster : Bool
    }



-- MSG


type Msg
    = NoOp



-- INIT


init : ( Model, Cmd Msg )
init =
    { play = True
    , stop = True
    , forward = True
    , backward = True
    , slower = True
    , faster = True
    }
        ! []



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Audio player" ]
        ]
