#!/usr/bin/env python3

import discord

text_channel_list = []
for server in Client.servers:
    for channel in server.channels:
        if str(channel.type) == 'text':
            text_channel_list.append(channel)