module Audio.View exposing (view)

import Html exposing (a, audio, button, div, h1, h2, i, li, span, text, ul, Attribute, Html)
import Html.Attributes exposing (class, controls, href, id, type', src, style)
import Html.Events exposing (on, onClick)
import Json.Decode as Json exposing ((:=))
import String
import Audio.Player exposing (..)
import ISO8601


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
                            [ progressBar model
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


progressBar : Model -> Html Msg
progressBar model =
    let
        progress =
            case model.duration of
                Just duration ->
                    (toFloat (model.currentTime) * 100 / toFloat (duration)) |> round |> toString

                Nothing ->
                    "0"
    in
        li [ class "nav-item" ]
            [ span [ class "nav-text" ]
                [ a [ class "nav-link" ]
                    [ div
                        [ class "progress nav-text"
                        , style [ ( "width", "200px" ), ( "margin-bottom", "0" ) ]
                        ]
                        [ div
                            [ class "progress-bar success nav-text"
                            , style [ ( "width", progress ++ "%" ), ( "padding-top", "2px" ) ]
                            ]
                            [ text (progress ++ "%") ]
                        ]
                    ]
                , span [ class "text-xs" ] [ viewTimeInfo model ]
                ]
            ]


viewTimeInfo : Model -> Html Msg
viewTimeInfo model =
    case model.duration of
        Just duration ->
            text (formatTimeInfo model.currentTime ++ "/" ++ formatTimeInfo duration)

        Nothing ->
            text "-"


formatTimeInfo : Milliseconds -> String
formatTimeInfo timestamp =
    let
        date =
            timestamp |> ISO8601.fromTime
    in
        (date.hour |> toString |> String.padLeft 2 '0') ++ ":" ++ (date.minute |> toString |> String.padLeft 2 '0') ++ ":" ++ (date.second |> toString |> String.padLeft 2 '0')


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
