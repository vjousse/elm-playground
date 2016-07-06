module Audio.Events exposing (onPause, onPlaying, onCanPlay, onTimeUpdate)

import Html exposing (Attribute)
import Html.Events exposing (on)
import Json.Decode as Json exposing ((:=))


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
