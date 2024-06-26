#!/usr/bin/env python3

"""url_handlers.py - Default plugins for URL handling"""
import re
import terminatorlib.plugin as plugin

# Every plugin you want Terminator to load *must* be listed in 'AVAILABLE'
AVAILABLE = ['PhabricatorURLHandler']

class PhabricatorURLHandler(plugin.URLHandler):
    capabilities = ['url_handler']
    handler_name = 'phabricator_bug'
    match = '\\bT[0-9]+\\b'
    nameopen = "Open phrabricator bug"
    namecopy = "Copy bug URL"

    def callback(self, url):
        """Look for the number in the supplied string and return it as a URL"""
        for item in re.findall(r'[0-9]+', url):
            url = 'https://phabricator.wikimedia.org/%s' % item
            return url
