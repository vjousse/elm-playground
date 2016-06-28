port module Main exposing (..)

import Html exposing (div, h1, text, Html)
import Html.App as App
import AudioPlayer
import Controls
import Debug


main =
    App.program
        { init =
            init
                { mediaUrl = "http://developer.mozilla.org/@api/deki/files/2926/=AudioTest_(1).ogg"
                , mediaType = "audio/ogg"
                , playing = False
                , currentTime = 0
                , controls = True
                }
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { audioPlayer : AudioPlayer.Model
    , controls : Controls.Model
    }



-- MSG


type Msg
    = NoOp
    | MsgAudioPlayer AudioPlayer.Msg
    | MsgControls Controls.Msg



-- INIT


init : AudioPlayer.Model -> Controls.Model -> ( Model, Cmd Msg )
init audioPlayerModel controlsModel =
    let
        ( audioPlayerInit, audioPlayerCmds ) =
            AudioPlayer.init audioPlayerModel

        ( controlsInit, controlsCmds ) =
            Controls.init controlsModel
    in
        { audioPlayer = audioPlayerInit
        , controls = controlsInit
        }
            ! [ Cmd.batch
                    [ Cmd.map MsgAudioPlayer audioPlayerCmds
                    , Cmd.map MsgControls controlsCmds
                    ]
              ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgAudioPlayer msg ->
            let
                ( audioPlayerModel, audioPlayerCmds ) =
                    AudioPlayer.update msg model.audioPlayer
            in
                ( { model | audioPlayer = audioPlayerModel }
                , Cmd.map MsgAudioPlayer audioPlayerCmds
                )

        _ ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Audio player" ]
        , div [] [ text ("Current time outside audio component: " ++ toString model.audioPlayer.currentTime) ]
        , App.map MsgAudioPlayer (AudioPlayer.view model.audioPlayer)
        , App.map MsgControls (Controls.view model.controls)
        ]



-- PORT


port setCurrentTime : Float -> Cmd msg
