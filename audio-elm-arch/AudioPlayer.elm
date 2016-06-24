module AudioPlayer exposing (Model, Msg, init, update, view, subscriptions)

import Html exposing (audio, div, h2, text, Attribute, Html)
import Html.Attributes exposing (class, controls, type', src)
import Html.Events exposing (on)
import Json.Decode as Json exposing ((:=))
import Debug


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


init : Model -> ( Model, Cmd Msg )
init model =
    model ! []



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "Message" msg of
        TimeUpdate time ->
            ( { model | currentTime = Debug.log (toString time) time }, Cmd.none )

        _ ->
            Debug.log "test " ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- JSON decoders


onTimeUpdate : (Float -> msg) -> Attribute msg
onTimeUpdate msg =
    let
        test =
            Debug.log "MSG" msg
    in
        on "timeupdate" (Json.map msg targetCurrentTime)


{-| A `Json.Decoder` for grabbing `event.target.currentTime`. We use this to define
`onInput` as follows:

    import Json.Decoder as Json

    onInput : (String -> msg) -> Attribute msg
    onInput tagger =
      on "input" (Json.map tagger targetValue)

You probably will never need this, but hopefully it gives some insights into
how to make custom event handlers.
-}
targetCurrentTime : Json.Decoder Float
targetCurrentTime =
    Debug.log "in targetCurrentTime" Json.at [ "target", "currentTime" ] Json.float



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
        ]
