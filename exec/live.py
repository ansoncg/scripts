#!/bin/python

# moonmoon user_id
# 121059319

# my user_id
# 52363379

import requests, os

auth = str(os.popen('head -1 $HOME/etc/my_apps_data/twitch.keys').read().strip())
client_id = str(os.popen('tail -1 $HOME/etc/my_apps_data/twitch.keys').read().strip())

headers = {
    'Client-ID': client_id,
    'Authorization': 'Bearer ' + auth,
}

response = requests.get('https://api.twitch.tv/helix/streams/followed?user_id=52363379', headers=headers).json()
moon = requests.get('https://api.twitch.tv/helix/channels?broadcaster_id=121059319', headers=headers).json()
data = response['data']
cols = int(os.popen('tput cols').read())

print("-"*cols)
for stream in data:
    channel_name = stream["user_name"];
    channel_game = stream["game_name"];
    channel_viewers = str(stream["viewer_count"]);
    channel_title = str(stream["title"]);
    if(len(channel_name) > 25):
        channel_name = channel_name[:25] + ".."
    if(len(channel_game) > 28):
        channel_game = channel_game[:28] + ".."
    if(len(channel_title) > cols - 68):
        channel_title = channel_title[:(cols - 68)] + ".."
    print ("{} {} {} {}".format(
        channel_name.ljust(20),
        channel_game.ljust(30), 
        channel_viewers.ljust(7), 
        channel_title.removesuffix("\n"),
        ))

print("\nMoonmoon title:", moon['data'][0]['title']) 
print('-'*cols)
