module Controls exposing (Model, Msg(..), init, view, update)

import Html.Events exposing (onClick)
import Html exposing (button, div, h1, text, Html)
import Debug
import Ports


-- MODEL


type alias Model =
    { play : Bool
    , stop : Bool
    , slower : Bool
    , faster : Bool
    , resetPlayback : Bool
    , playbackRate : Float
    , playbackStep : Float
    }



-- MSG


type Msg
    = NoOp
    | Slower
    | Faster
    | Play
    | Pause
    | ResetPlayback



-- INIT


init : ( Model, Cmd Msg )
init =
    { play = True
    , stop = True
    , slower = True
    , faster = True
    , resetPlayback = True
    , playbackRate = 1
    , playbackStep = 0.1
    }
        ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log (toString model) msg of
        Play ->
            ( model, Ports.playIt )

        Pause ->
            ( model, Ports.pauseIt )

        Slower ->
            let
                newPlaybackRate =
                    model.playbackRate - model.playbackStep
            in
                ( { model | playbackRate = newPlaybackRate }, Ports.setPlaybackRate newPlaybackRate )

        Faster ->
            let
                newPlaybackRate =
                    model.playbackRate + model.playbackStep
            in
                ( { model | playbackRate = newPlaybackRate }, Ports.setPlaybackRate newPlaybackRate )

        ResetPlayback ->
            ( model, Ports.setPlaybackRate 1 )

        _ ->
            Debug.log "test " ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Controls" ]
        , button [ onClick Play ] [ text "Play" ]
        , button [ onClick Pause ] [ text "Pause" ]
        , button [ onClick Slower ] [ text "Slower" ]
        , button [ onClick Faster ] [ text "Faster" ]
        , button [ onClick ResetPlayback ] [ text "Reset playback" ]
        ]
