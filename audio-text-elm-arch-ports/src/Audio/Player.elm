module Audio.Player exposing (Model, Milliseconds, Msg(..), init, update, subscriptions)

-- Elm modules

import Debug
import List


-- Project modules

import Ports


-- MODEL


type alias Milliseconds =
    Int


type alias ControlsDisplay =
    { play : Bool
    , pause : Bool
    , slower : Bool
    , faster : Bool
    , resetPlayback : Bool
    , toggle : Bool
    }


type alias Model =
    { mediaUrl : String
    , mediaType : String
    , playing : Bool
    , currentTime : Milliseconds
    , playbackRate : Float
    , playbackStep : Float
    , defaultControls : Bool
    , duration : Maybe Milliseconds
    , controls : ControlsDisplay
    }



-- MSG


type Msg
    = NoOp
    | TimeUpdate Float
    | MoveToCurrentTime Float
    | SetDuration Float
    | SetPlaying
    | SetPaused
    | Slower
    | Faster
    | Play
    | Pause
    | Toggle
    | ResetPlayback


type alias Flags =
    { mediaUrl : String
    , mediaType : String
    }



-- INIT


init : Flags -> ( Model, Cmd Msg )
init flags =
    { mediaUrl = flags.mediaUrl
    , mediaType = flags.mediaType
    , playing = False
    , currentTime = 0
    , playbackRate = 1
    , playbackStep = 0.1
    , defaultControls = False
    , duration = Nothing
    , controls =
        { play = True
        , pause = True
        , slower = True
        , faster = True
        , resetPlayback = True
        , toggle = True
        }
    }
        ! []



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log ("[Audio.Player] " ++ toString msg) msg of
        TimeUpdate time ->
            -- we get the time in seconds, and we want it as
            -- milliseconds (Time.Time)
            ( { model | currentTime = ((time * 1000) |> round) }, Cmd.none )

        SetDuration time ->
            ( { model | duration = Just ((time * 1000) |> round) }, Cmd.none )

        SetPlaying ->
            ( { model | playing = True }, Cmd.none )

        SetPaused ->
            ( { model | playing = False }, Cmd.none )

        Toggle ->
            if model.playing then
                ( model, Ports.pauseIt )
            else
                ( model, Ports.playIt )

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

        MoveToCurrentTime time ->
            ( model, Ports.setCurrentTime time )

        ResetPlayback ->
            ( model, Ports.setPlaybackRate 1 )

        _ ->
            Debug.log "Debug Player Component " ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
