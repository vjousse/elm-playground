port module Main exposing (..)

import Html exposing (div, h1, text, Html)
import Html.App as App
import Audio.Player exposing (Msg(..))
import Debug
import Keyboard
import Char
import Ports


main =
    App.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { audioPlayer : Audio.Player.Model
    , toggleKeyCode : Keyboard.KeyCode
    }



-- MSG


type Msg
    = NoOp
    | MsgAudioPlayer Audio.Player.Msg
    | MsgKeypress Keyboard.KeyCode


type alias Flags =
    { mediaUrl : String
    , mediaType : String
    , toggleKeyCode : Keyboard.KeyCode
    }



-- INIT


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( audioPlayerInit, audioPlayerCmds ) =
            Audio.Player.init
    in
        { audioPlayer = audioPlayerInit
        , toggleKeyCode = flags.toggleKeyCode
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
            if code == model.toggleKeyCode then
                let
                    ( audioPlayerModel, audioPlayerCmds ) =
                        Audio.Player.update Toggle model.audioPlayer
                in
                    ( { model | audioPlayer = audioPlayerModel }
                    , Cmd.map MsgAudioPlayer audioPlayerCmds
                    )
            else
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



-- Convert MSG to Cmd Msg
{-

   send : Msg -> Cmd Msg
   send msg =
         Task.perform identity identity (Task.succeed msg)
-}
