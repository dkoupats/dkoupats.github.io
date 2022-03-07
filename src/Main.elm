
module Main exposing (main)


import Browser exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http


-- MAIN


main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }


-- MODEL
type Model
  = Failure
  | Loading
  | Success String


init : () -> (Model, Cmd Msg)
init _ =
  ( Loading
  , Http.get
      { url = "https://elm-lang.org/assets/public-opinion.txt"
      , expect = Http.expectString GotText
      }
  )


-- UPDATE
type Msg
  = GotText (Result Http.Error String)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GotText result ->
      case result of
        Ok fullText ->
          (Success fullText, Cmd.none)

        Err _ ->
          (Failure, Cmd.none)


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW
view : Model -> Html Msg
view model =
  case model of
    Failure ->
      text "I was unable to load your book."

    Loading ->
      text "Loading..."

    Success fullText ->
      pre [] [ text fullText ]



-- viewBlog =
--     div []
--         [ h1
--           [ id "hdg"] [ text "Dimitris Koupatsiaris" ]
--         , p []
--             [ text "This is a blog that was created using the delightful "
--             , a ["https://elm-lang.org/"] [ text "Elm language" ]
--             ]
--         ]






-- Documents
-- document :
--     { init : flags -> ( model, Cmd msg )
--     , view : model -> Document msg
--     , update : msg -> model -> ( model, Cmd msg )
--     , subscriptions : model -> Sub msg
--     }
--     -> Program flags model msg
-- Create an HTML document managed by Elm. This expands upon what element can do in that view now gives you control over the <title> and <body>.
--
-- type alias Document msg =
--     { title : String
--     , body : List (Html msg)
--     }
