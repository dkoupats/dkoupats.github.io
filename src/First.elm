
module First exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (href, pubdate )
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (required)


-- MODEL




-- VIEW




-- UPDATE




type alias Post =
    { id : Int
    , title : String
    , relation : String
    , author : String
    , body : String
    , date : String
    }


type alias Comment =
    { id : Int
    , body : String
    , postId : Int
    }


type alias Model =
    { posts : List Post
    , errorMessage : Maybe String
    }


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick SendHttpRequest ]
            [ text "Get data from server" ]
        , viewPostsOrError model
        ]


viewPostsOrError : Model -> Html Msg
viewPostsOrError model =
    case model.errorMessage of
        Just message ->
            viewError message

        Nothing ->
            viewPosts model.posts


viewError : String -> Html Msg
viewError errorMessage =
    let
        errorHeading =
            "Couldn't fetch data at this time."
    in
    div []
        [ h3 [] [ text errorHeading ]
        , text ("Error: " ++ errorMessage)
        ]


viewPosts : List Post -> Html Msg
viewPosts posts =
    article [] [ viewPost post ]


    -- div []
    --     [ h3 [] [ text "Posts" ]
    --     , table []
    --         ([ viewTableHeader ] ++ List.map viewPost posts)
    --     ]


-- viewTableHeader : Html Msg
-- viewTableHeader =
--     tr []
--         [ th []
--             [ text "ID" ]
--         , th []
--             [ text "Title" ]
--         , th []
--             [ text "Sector" ]
--         , th []
--             [ text "Author" ]
--         , th []
--           [ text "Body" ]
--         , th []
--           [ text "Date" ]
--         ]


viewPost : Post -> Html Msg
viewPost post =
    article []
      [ h2 [] [ text post.title ]
      , p [ text post.relation ] [ text post.relation ]
      , p []
          [ pubdate post.date
          , text post.author
          ]
      , p [] [ text post.body ]
      ]


type Msg
    = SendHttpRequest
    | DataReceived (Result Http.Error (List Post))


postDecoder : Decoder Post
postDecoder =
    Decode.succeed Post
        |> required "id" int
        |> required "title" string
        |> required "relation" string
        |> required "author" string
        |> required "body" string
        |> required "date" string


httpCommand : Cmd Msg
httpCommand =
    Http.get
        { url = "https://my-json-server.typicode.com/dkoupats/jsondata/posts"
        , expect = Http.expectJson DataReceived (list postDecoder)
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendHttpRequest ->
            ( model, httpCommand )

        DataReceived (Ok posts) ->
            ( { model
                | posts = posts
                , errorMessage = Nothing
              }
            , Cmd.none
            )

        DataReceived (Err httpError) ->
            ( { model
                | errorMessage = Just (buildErrorMessage httpError)
              }
            , Cmd.none
            )


buildErrorMessage : Http.Error -> String
buildErrorMessage httpError =
    case httpError of
        Http.BadUrl message ->
            message

        Http.Timeout ->
            "Server is taking too long to respond. Please try again later."

        Http.NetworkError ->
            "Unable to reach server."

        Http.BadStatus statusCode ->
            "Request failed with status code: " ++ String.fromInt statusCode

        Http.BadBody message ->
            message


init : () -> ( Model, Cmd Msg )
init _ =
    ( { posts = []
      , errorMessage = Nothing
      }
    , Cmd.none
    )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
