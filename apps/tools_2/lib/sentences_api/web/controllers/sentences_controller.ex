defmodule SentencesAPI.Web.SentencesController do
  use SentencesAPI.Web, :controller

  @sentences [
    %{
      text: "Life is about making an impact, not making an income.",
      author: "Kevin Kruse"
    },

    %{
      text: "Whatever the mind of man can conceive and believe, it can achieve.",
      author: "Napoleon Hill"
    },

    %{
      text: "Strive not to be a success, but rather to be of value.",
      author: "Albert Einstein"
    },

    %{
      text: "Two roads diverged in a wood, and I—I took the one less traveled by, And that has made all the difference. ",
      author: "Robert Frost"
    },

    %{
      text: "I attribute my success to this: I never gave or took any excuse.",
      author: "Florence Nightingale"
    },

    %{
      text: "You miss 100% of the shots you don’t take.",
      author: "Wayne Gretzky"
    },

    %{
      text: "I've missed more than 9000 shots in my career. I've lost almost 300 games. 26 times I've been trusted to take the game winning shot and missed. I've failed over and over and over again in my life. And that is why I succeed.",
      author: "Michael Jordan"
    },

    %{
      text: "The most difficult thing is the decision to act, the rest is merely tenacity.",
      author: "Amelia Earhart"
    },

    %{
      text: "Every strike brings me closer to the next home run.",
      author: "Babe Ruth"
    },

    %{
      text: "Definiteness of purpose is the starting point of all achievement.",
      author: "W. Clement Stone"
    },

    %{
      text: "Life isn't about getting and having, it's about giving and being.",
      author: "Kevin Kruse"
    },

    %{
      text: "Life is what happens to you while you’re busy making other plans.",
      author: "John Lennon"
    },

    %{
      text: "We become what we think about.",
      author: "Earl Nightingale"
    },

    %{
      text: "Twenty years from now you will be more disappointed by the things that you didn’t do than by the ones you did do, so throw off the bowlines, sail away from safe harbor, catch the trade winds in your sails.  Explore, Dream, Discover.",
      author: "Mark Twain"
    },

    %{
      text: "Life is 10% what happens to me and 90% of how I react to it.",
      author: "Charles Swindoll"
    },

    %{
      text: "The most common way people give up their power is by thinking they don’t have any.",
      author: "Alice Walker"
    },

    %{
      text: "The mind is everything. What you think you become. ",
      author: "Buddha"
    },

    %{
      text: "The best time to plant a tree was 20 years ago. The second best time is now.",
      author: "Chinese Proverb"
    },

    %{
      text: "An unexamined life is not worth living.",
      author: "Socrates"
    },

    %{
      text: "Eighty percent of success is showing up.",
      author: "Woody Allen"
    },

    %{
      text: "Your time is limited, so don’t waste it living someone else’s life.",
      author: "Steve Jobs"
    },

    %{
      text: "Winning isn’t everything, but wanting to win is.",
      author: "Vince Lombardi"
    },

    %{
      text: "I am not a product of my circumstances. I am a product of my decisions.",
      author: "Stephen Covey"
    },

    %{
      text: "Every child is an artist.  The problem is how to remain an artist once he grows up.",
      author: "Pablo Picasso"
    },

    %{
      text: "You can never cross the ocean until you have the courage to lose sight of the shore.",
      author: "Christopher Columbus"
    },

    %{
      text: "I’ve learned that people will forget what you said, people will forget what you did, but people will never forget how ou made them feel.",
      author: "Maya Angelou"
    },

    %{
      text: "Either you run the day, or the day runs you.",
      author: "Jim Rohn"
    },

    %{
      text: "Whether you think you can or you think you can’t, you’re right.",
      author: "Henry Ford"
    },

    %{
      text: "The two most important days in your life are the day you are born and the day you find out why.",
      author: "Mark Twain"
    },

    %{
      text: "Whatever you can do, or dream you can, begin it.  Boldness has genius, power and magic in it.",
      author: "Johann Wolfgang von Goethe"
    },

    %{
      text: "The best revenge is massive success.",
      author: "Frank Sinatra"
    },

    %{
      text: "People often say that motivation doesn’t last. Well, neither does bathing.  That’s why we recommend it daily.",
      author: "Zig Ziglar"
    },

    %{
      text: "Life shrinks or expands in proportion to one's courage.",
      author: "Anais Nin"
    }
  ]

  def all(conn, _params) do
    render conn, "index.json", sentences: @sentences
  end

  def random(conn, _params) do
    random_sentence = SentencesAPI.Web.Helpers.get_random_from(@sentences)

    render conn, "index.json", sentences: [ random_sentence ]
  end
end