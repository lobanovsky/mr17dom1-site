#!/usr/bin/env python3
"""Check local assets referenced by exported HTML and CSS without dependencies."""
from html.parser import HTMLParser
from pathlib import Path
import re
import sys
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parent.parent / 'mr17dom1-from-tilda'
errors = set()


def check(value, source):
    url = urlsplit(value)
    if url.scheme or url.netloc or not url.path:
        return
    path = unquote(url.path)
    target = ROOT / path.lstrip('/') if path.startswith('/') else source.parent / path
    if not target.resolve().is_relative_to(ROOT.resolve()) or not target.is_file():
        errors.add(f'{source.relative_to(ROOT)}: missing asset {value}')


class Assets(HTMLParser):
    def __init__(self, source):
        super().__init__()
        self.source = source

    def handle_starttag(self, tag, attrs):
        for key, value in attrs:
            if value and (key in ('src', 'data-original', 'data-content-cover-bg')
                          or (tag == 'link' and key == 'href')):
                check(value, self.source)
            if value and key == 'style':
                for url in re.findall(r'url\([\'\"]?([^\'\")]+)', value):
                    check(url, self.source)


for required in ('page56734223.html', '404.html', 'robots.txt', 'sitemap.xml'):
    if not (ROOT / required).is_file():
        errors.add(f'Missing required file: {required}')
for source in ROOT.glob('*.html'):
    Assets(source).feed(source.read_text())
for source in ROOT.rglob('*.css'):
    for value in re.findall(r'url\([\'\"]?([^\'\")]+)', source.read_text()):
        check(value.strip(), source)
if errors:
    print('\n'.join(sorted(errors)), file=sys.stderr)
    sys.exit(1)
print('OK: required pages and local HTML/CSS assets exist.')

