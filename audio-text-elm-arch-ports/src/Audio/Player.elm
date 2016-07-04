module Audio.Player exposing (Model, Msg(..), init, update, view, subscriptions)

import Html exposing (a, audio, button, div, h1, h2, i, li, span, text, ul, Attribute, Html)
import Html.Attributes exposing (class, controls, href, id, type', src, style)
import Html.Events exposing (on, onClick)
import Json.Decode as Json exposing ((:=))
import List
import Debug
import Ports


-- MODEL


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
    , currentTime : Float
    , playbackRate : Float
    , playbackStep : Float
    , defaultControls : Bool
    , duration : Maybe Float
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
            ( { model | currentTime = time }, Cmd.none )

        SetDuration time ->
            ( { model | duration = Just time }, Cmd.none )

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



-- JSON decoders


onPause : msg -> Attribute msg
onPause msg =
    on "pause" (Json.succeed msg)


onPlaying : msg -> Attribute msg
onPlaying msg =
    on "playing" (Json.succeed msg)


onCanPlay : (Float -> msg) -> Attribute msg
onCanPlay msg =
    on "canplay" (Json.map msg (targetFloatProperty "duration"))


onTimeUpdate : (Float -> msg) -> Attribute msg
onTimeUpdate msg =
    on "timeupdate" (Json.map msg (targetFloatProperty "currentTime"))


{-| A `Json.Decoder` for grabbing `event.target.currentTime`. We use this to define
`onInput` as follows:

    import Json.Decoder as Json

    onInput : (String -> msg) -> Attribute msg
    onInput tagger =
      on "input" (Json.map tagger targetValue)

You probably will never need this, but hopefully it gives some insights into
how to make custom event handlers.
-}
targetFloatProperty : String -> Json.Decoder Float
targetFloatProperty property =
    Json.at [ "target", property ] Json.float



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div [ class "elm-audio-player" ]
            [ audio
                [ src model.mediaUrl
                , type' model.mediaType
                , controls model.defaultControls
                , onTimeUpdate TimeUpdate
                , onPause SetPaused
                , onPlaying SetPlaying
                , onCanPlay SetDuration
                , id "audio-player"
                ]
                []
            , div [ class "app-header white box-shadow" ]
                [ div [ class "navbar" ]
                    [ ul [ class "nav navbar-nav navbar-nav-inline text-center pull-right m-r text-blue-hover" ]
                        (List.append
                            [ progressBar
                            ]
                            (audioControls model)
                        )
                    ]
                ]
            ]
        ]


audioControls : Model -> List (Html Msg)
audioControls model =
    [ controlButton model.controls.toggle
        Toggle
        "⎵"
        (if model.playing then
            "\xE036"
         else
            "\xE039"
        )
    , controlButton model.controls.faster Faster "F2" "\xE020"
    , controlButton model.controls.slower Slower "F1" "\xE01F"
    ]


progressBar : Html Msg
progressBar =
    li [ class "nav-item" ]
        [ a [ class "nav-link" ]
            [ span [ class "nav-text" ]
                [ div
                    [ class "progress nav-text"
                    , style [ ( "width", "200px" ), ( "margin-bottom", "0" ) ]
                    ]
                    [ div
                        [ class "progress-bar success nav-text"
                        , style [ ( "width", "25%" ), ( "padding-top", "2px" ) ]
                        ]
                        [ text "25%" ]
                    ]
                , span [ class "text-xs" ] [ text "0:01:23/1:02:30" ]
                ]
            ]
        ]


controlButton : Bool -> Msg -> String -> String -> Html Msg
controlButton display msg label iconUtf8 =
    if display then
        li [ class "nav-item" ]
            [ a
                [ class "nav-link"
                , onClick msg
                ]
                [ span [ class "nav-text" ]
                    [ i [ class "material-icons" ]
                        [ text iconUtf8
                        ]
                    , span [ class "text-xs" ] [ text label ]
                    ]
                ]
            ]
    else
        text ""
