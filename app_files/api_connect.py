import os
import openai
import wget
from datetime import datetime, timezone
from termcolor import colored

# setup initial api requirements
openai.api_key = os.getenv('api_key')

# optional api parameters
max_response_length = 1024
default_img_size = '512x512'
num_img_generations = 2

# program data
quit_options = ['quit', 'Quit', 'Q', 'q', 'exit', 'Exit', 'ex', 'e', 'E']
engine_options = ['engine', 'Engine', 'eng', 'Eng', 'engines', 'Engines']
completion_options = ['completion', 'Completion', 'comp', 'Comp', 'complete']
image_options = ['image', 'Image', 'img', 'Img', 'i']
img_create_options = ['create new image', 'create', 'new', 'Create new image', 'new image', 'cr']
img_modify_options = ['modify existing image', 'Modify existing image', 'modify image', 'modify img', 'modify', 'mod', 'existing']
prompt_log = []

# user input loop for making continuous requests
api_continue = True
print('API Connector ' + colored('[RUNNING]', 'green'))
while api_continue:
	activity = input('Select an activity [Completion, Moderation, Image, Engines, Quit]: ')
	if activity in quit_options:
		api_continue = False
		continue
	elif activity in engine_options:
		print('\nAVAILABLE ENGINES BY CATEGORY:')
		print('More detailed info: https://beta.openai.com/docs/models')
		print('> text')
		print('\t- Davinci (text-davinci-003): Slowest, Most Expensive, Can Do Everything')
		print('\t- Curie (text-curie-001): Slower, Expensive, Translation/Summarization')
		print('\t- Babbage (text-babbage-001): Fast, Cheap, Semantic Search')
		print('\t- Ada (text-ada-001): Fastest, Cheapest, Parse Text/Address Correction/Keywords')
		print('> image')
		print('\t- DALL-E\n')
	elif activity in completion_options:
		print('\nSelected Completion')
		print('Default engine: GPT-3 (text-davinci-003)\n')
		text_prompt = input('Say something to GPT-3: ')
		prompt_log.append(text_prompt)
		completion = openai.Completion.create(engine='text-davinci-003', prompt=text_prompt, max_tokens=max_response_length)
		print(completion.choices[0].text)
	elif activity in image_options:
		print('\nSelected Image')
		print('Default engine: Dall-E')
		img_operation = input("""Select an image operation:
[Create new image, Modify existing image]: """)
		if img_operation in img_create_options:
			img_prompt = input('Provide a prompt for the image: ')
			prompt_log.append(img_prompt)
			try:
				new_img = openai.Image.create(prompt=img_prompt, n=num_img_generations, size=default_img_size)
			except Exception:
				print("<< Image request failed: prompt contained words that OpenAI doesn't like >>")
				continue
			for i in range(num_img_generations):
				img_url = new_img.data[i].url
				# generate date and time for the output filename
				curr_time_obj = datetime.now(timezone.utc)
				curr_time_str = curr_time_obj.strftime("%Y-%m-%d_%H_%M_%S")
				img_filename = f'img_{curr_time_str}({i}.png)'
				wget.download(img_url, out=img_filename)
			print('\nGenerated images have been saved.')
		elif img_operation in img_modify_options:
			pass
	else:
		print('Activity not recognized. Make sure to choose an option from the list provided.\n')
	print()
# write logs to file
with open('prompts.log', 'a') as writer:
	for item in prompt_log:
		writer.write(f'> {item}\n')
print('API Connector ' + colored('[TERMINATED]', 'red'))
