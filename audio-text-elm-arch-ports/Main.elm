port module Main exposing (..)

import Html exposing (div, h1, text, Html)
import Html.App as App
import Audio.Player exposing (Msg(..))
import Debug
import Keyboard
import Char
import Ports


main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { audioPlayer : Audio.Player.Model
    }



-- MSG


type Msg
    = NoOp
    | MsgAudioPlayer Audio.Player.Msg
    | MsgKeypress Keyboard.KeyCode



-- INIT


init : ( Model, Cmd Msg )
init =
    let
        ( audioPlayerInit, audioPlayerCmds ) =
            Audio.Player.init
    in
        { audioPlayer = audioPlayerInit
        }
            ! [ Cmd.batch
                    [ Cmd.map MsgAudioPlayer audioPlayerCmds
                    ]
              ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgAudioPlayer msg' ->
            let
                ( audioPlayerModel, audioPlayerCmds ) =
                    Audio.Player.update msg' model.audioPlayer
            in
                ( { model | audioPlayer = audioPlayerModel }
                , Cmd.map MsgAudioPlayer audioPlayerCmds
                )

        MsgKeypress code ->
            case code of
                -- a letter
                65 ->
                    let
                        test =
                            Debug.log "a letter" "a"
                    in
                        ( model, Cmd.none )

                80 ->
                    let
                        test =
                            Debug.log "p letter" "p"
                    in
                        ( model, Ports.playIt )

                _ ->
                    let
                        test =
                            Debug.log (toString code) "other"
                    in
                        ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Keyboard.downs MsgKeypress



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Audio player" ]
        , App.map MsgAudioPlayer (Audio.Player.view model.audioPlayer)
        ]
