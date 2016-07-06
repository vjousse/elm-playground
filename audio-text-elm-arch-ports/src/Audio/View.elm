module Audio.View exposing (view)

import Html exposing (a, audio, button, div, h1, h2, i, li, span, text, ul, Attribute, Html)
import Html.Attributes exposing (class, controls, href, id, type', src, style)
import Html.Events exposing (on, onClick)
import String
import Audio.Player exposing (..)
import Audio.Events exposing (onPause, onPlaying, onCanPlay, onTimeUpdate)
import ISO8601


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
