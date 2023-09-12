require 'openai'

def generate_text(prompt)
  response = OpenAI::Completion.create(
    engine: "text-davinci-002",
    prompt: prompt,
    max_tokens: 100,
    n: 1,
    stop: "",
    temperature: 0.5,
    api_key: "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"
  )

  response["choices"][0]["text"]
end


puts "Enter a prompt for ChatGPT to complete: "
prompt = gets.chomp

puts "Generated text: \n\n"
puts generate_text(prompt)