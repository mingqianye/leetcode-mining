require "net/http"
require "uri"
require "json"
require 'csv'
require "nokogiri"
require 'open-uri'
require 'byebug'

class Question
  attr_reader :id, :title, :title_slug, :difficulty, :similar_questions, :topics
  def initialize(stat_status_pair:)
    @id         = stat_status_pair['stat']['question_id']
    @title      = stat_status_pair['stat']['question__title']
    @title_slug = stat_status_pair['stat']['question__title_slug']
    @difficulty = stat_status_pair['difficulty']['level']
    @similar_questions = []
    @topics = []
  end

  def add_similar_question(similar_question)
    @similar_questions << similar_question
  end

  def add_topic(topic)
    @topics << topic
  end

  def url
    '/problems/' + @title_slug + '/description'
  end

  def to_json
    {
      id: @id,
      title: @title,
      difficulty: @difficulty,
      topics: @topics,
      similar_questions: @similar_questions.map(&:title)
    }.to_json
  end

  def to_csv
    [@id, @title, @difficulty, @topics.join('|'), @similar_questions.map(&:title).join('|')].to_csv
  end
end

$stdout.sync = true

response = Net::HTTP.get_response(URI.parse("https://leetcode.com/api/problems/all/"))
json_response = JSON.parse(response.body)

# download questions list
all_questions = {}
json_response['stat_status_pairs'].each do |pair|
  q = Question.new(stat_status_pair: pair)
  all_questions[q.title] = q
end

# process each question
all_questions.each do |k, v|
  doc = Nokogiri::HTML(open('https://leetcode.com' + v.url))

  doc.css('#tags-topics a').map{|x| x.text}.each do |topic|
    v.add_topic(topic)
  end

  doc.css('#tags-question a').map{|x| x.text}.each do |similar_q_title|
    v.add_similar_question(all_questions.fetch(similar_q_title))
  end

  puts v.to_csv
end
