port module Main exposing (..)

import Html exposing (div, h1, text, Html)
import Html.App as App
import Audio.Player exposing (Msg(..))
import Audio.Controls
import Debug


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
    , controls : Audio.Controls.Model
    }



-- MSG


type Msg
    = NoOp
    | MsgAudioPlayer Audio.Player.Msg
    | MsgControls Audio.Controls.Msg



-- INIT


init : ( Model, Cmd Msg )
init =
    let
        ( audioPlayerInit, audioPlayerCmds ) =
            Audio.Player.init

        ( controlsInit, controlsCmds ) =
            Audio.Controls.init
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
        MsgAudioPlayer msg' ->
            updateChild Audio.Player.update msg' model.audioPlayer model (\audioModel parentModel -> { parentModel | audioPlayer = audioModel })

        MsgControls msg' ->
            let
                ( controlsModel, controlsCmds ) =
                    Audio.Controls.update msg' model.controls
            in
                ( { model | controls = controlsModel }
                , Cmd.map MsgControls controlsCmds
                )

        _ ->
            ( model, Cmd.none )


updateChild : (cMsg -> cModel -> ( cModel, Cmd cMsg )) -> cMsg -> cModel -> pModel -> (cModel -> pModel -> pModel) -> ( pModel, Cmd Msg )
updateChild updateChild msg childModel parentModel updateParent =
    let
        ( audioPlayerModel, audioPlayerCmds ) =
            updateChild msg childModel
    in
        ( updateParent audioPlayerModel parentModel
        , Cmd.none
        )



{-
   let
       ( audioPlayerModel, audioPlayerCmds ) =
           Audio.Player.update msg' model.audioPlayer
   in
       ( { model | audioPlayer = audioPlayerModel }
       , Cmd.map MsgAudioPlayer audioPlayerCmds
       )
-}
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Audio player" ]
        , App.map MsgAudioPlayer (Audio.Player.view model.audioPlayer)
        , App.map MsgControls (Audio.Controls.view model.controls)
        ]
