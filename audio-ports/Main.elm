port module Main exposing (..)

import Html exposing (Attribute, Html, audio, div, text)
import Html.Attributes exposing (class, controls, type', src)
import Html.App as App
import Html.Events exposing (onClick)
import Html.Events exposing (on)
import Debug
import Json.Decode as Json exposing ((:=))


main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { mediaUrl : String
    , mediaType : String
    , playing : Bool
    , currentTime : Float
    , controls : Bool
    }



-- MSG


type Msg
    = NoOp
    | TimeUpdate Float



-- INIT


init : ( Model, Cmd Msg )
init =
    { mediaUrl = "http://developer.mozilla.org/@api/deki/files/2926/=AudioTest_(1).ogg"
    , mediaType = "audio/ogg"
    , playing = False
    , currentTime = 0
    , controls = True
    }
        ! []



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TimeUpdate time ->
            ( { model | currentTime = Debug.log "TimeUpdate MSG" time }, Cmd.none )

        _ ->
            Debug.log "test " ( model, Cmd.none )



-- JSON decoders


onTimeUpdate : (Float -> msg) -> Attribute msg
onTimeUpdate msg =
    on "timeupdate" (Json.map msg targetCurrentTime)



-- A `Json.Decoder` for grabbing `event.target.currentTime`.


targetCurrentTime : Json.Decoder Float
targetCurrentTime =
    Json.at [ "target", "currentTime" ] Json.float



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "elm-audio-player" ]
        [ audio
            [ src model.mediaUrl
            , type' model.mediaType
            , controls model.controls
            , onTimeUpdate TimeUpdate
            ]
            []
        , div [] [ text ("Current time: " ++ toString model.currentTime) ]
        ]



-- PORT


port setCurrentTime : Float -> Cmd msg
