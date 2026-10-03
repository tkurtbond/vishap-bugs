#!/usr/bin/env python3
# gen.py VOCCLONE TRANSCRIPTS: write issues/*.md and README.md from
# tools/issues.py, tools/manifest, tools/README.head.md, reproducers/, the
# transcripts that runall.sh wrote under TRANSCRIPTS (labelled master and
# new), and the commit messages of the branch "series" in VOCCLONE, a clone
# of voc with the series applied.  Write patches/ first:
#   git -C VOCCLONE format-patch -o patches master..series
import os, re, subprocess, sys
sys.path.insert(0, os.path.dirname(__file__))
from issues import ISSUES, NEEDS, OVERLAPS, ELSEWHERE

T = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.dirname(T)
REPO = sys.argv[1]
RUNS = os.path.abspath(sys.argv[2])
BASE = '9701249ad244cbdfd1c1df88af852be1484ae8e7'

def git(*a):
    return subprocess.run(['git', '-C', REPO] + list(a), check=True,
                          capture_output=True, text=True).stdout

commits = git('rev-list', '--reverse', 'master..series').split()
N = len(commits)
assert N == len(ISSUES), (N, len(ISSUES))

manifest = {}
for line in open(T + '/manifest'):
    slug, model, files, inp, setup, pre, run = (line.rstrip('\n').split('|', 6) + ['', ''])[:7]
    manifest[int(slug[:2])] = (slug, model, files.split(), inp, setup, pre.split(), run)

slugs = {}
for n in range(1, N + 1):
    slugs[n] = manifest[n][0] if n in manifest else '37-features-set-size'

def subject(n):
    return git('log', '-1', '--format=%s', commits[n - 1]).strip()

def body(n):
    b = git('log', '-1', '--format=%b', commits[n - 1])
    b = re.sub(r'\nCo-Authored-By:.*\n?', '\n', b).strip()
    paras = [p for p in b.split('\n\n') if not p.startswith('Needs ')]
    return '\n\n'.join(paras).strip()

def patchname(n):
    names = sorted(os.listdir(OUT + '/patches'))
    assert names[n - 1].startswith('%04d-' % n), names[n - 1]
    return names[n - 1]

def transcript(label, slug, m, run_only=False):
    t = open('%s/%s/%s/%s/transcript' % (RUNS, label, slug, m), errors='replace').read().rstrip('\n')
    # voc's installation directory in the C compiler's command line
    t = re.sub(r'"[^"]*(/[2C]/include|/lib)"', r'"<voc>\1"', t)
    lines = t.split('\n')
    if run_only:
        # keep from the run command on, or the compiler's messages if it failed
        for i, l in enumerate(lines):
            if l.startswith('$ ./') or l.startswith('$ printf'):
                return '\n'.join(lines[i:])
    return t

def ref(n):
    return 'patch %04d (%s)' % (n, ISSUES[n][0])

AI_NOTE = ('*This report was prepared with the help of AI (Claude, by Anthropic). '
           'The reproducers were run and the output shown is copied from those runs.*')

ENV = ('voc v2.1.0 at `master`, commit %s (2026-09-25), built with `make all` '
       'on Fedora Linux 44, x86_64, gcc 16.2.1.' % BASE[:8])

def issue(n):
    title, summary = ISSUES[n]
    note = AI_NOTE if n in manifest else AI_NOTE.split(' The reproducers')[0] + '*'
    out = ['# ' + title, '', note, '', summary.strip(), '']
    if n in manifest:
        slug, model, files, inp, setup, pre, run = manifest[n]
        out += ['## Reproducer', '']
        if setup:
            out += ['Run in a directory with a subdirectory `sub` (`%s`).' % setup, '']
        for m in pre + files:
            src = open('%s/reproducers/%s/%s.Mod' % (OUT, slug, m)).read().rstrip('\n')
            out += ['`%s.Mod`:' % m, '', '```oberon', src, '```', '']
        out += ['With voc at `master`:', '']
        for m in files:
            out += ['```', transcript('master', slug, m), '```', '']
        if n in ELSEWHERE:
            out += ['On %s:' % ELSEWHERE[n][0], '', '```', ELSEWHERE[n][1], '```', '']
    if n in manifest:
        out += ['## Cause and fix', '', body(n), '']
    else:
        out += ['## Fix', '']
    if n in manifest:
        slug, model, files, inp, setup, pre, run = manifest[n]
        out += ['With the fix:', '']
        for m in files:
            out += ['```', transcript('new', slug, m, run_only=True), '```', '']
        if n in ELSEWHERE:
            out += ['On FreeBSD, with the fix:' if 'FreeBSD' in ELSEWHERE[n][0] else 'There, with the fix:',
                    '', '```', ELSEWHERE[n][2], '```', '']
    if os.path.isdir('%s/notes/%s' % (OUT, slugs[n])):
        out += ['A longer account, with more reproducers, is in `notes/%s/README.md`.' % slugs[n], '']
    out += ['The fix is `patches/%s`, a `git format-patch` of one commit.' % patchname(n)]
    if n in NEEDS or n in OVERLAPS:
        out += ['']
        if n in NEEDS:
            out += ['It needs these applied first: ' +
                    '; '.join(ref(k) for k in NEEDS[n]) + '.']
        if n in OVERLAPS:
            out += ['It changes lines that ' + '; '.join(ref(k) for k in OVERLAPS[n]) +
                    ' also changes, and is made to apply after it.']
    out += ['', '## Environment', '', ENV, '']
    return '\n'.join(out)

def index():
    out = ['| # | Issue | Patch | Needs |', '|---|-------|-------|-------|']
    for n in range(1, N + 1):
        needs = ', '.join('%02d' % k for k in NEEDS.get(n, []))
        if n in OVERLAPS:
            needs += (' ' if needs else '') + '(after %s)' % ', '.join('%02d' % k for k in OVERLAPS[n])
        out.append('| %02d | [%s](issues/%s.md) | [%s](patches/%s) | %s |' %
                   (n, ISSUES[n][0].replace('|', '\\|'), slugs[n], '%04d' % n, patchname(n), needs))
    return '\n'.join(out) + '\n'

os.makedirs(OUT + '/issues', exist_ok=True)
for n in range(1, N + 1):
    open('%s/issues/%s.md' % (OUT, slugs[n]), 'w').write(issue(n))
open(OUT + '/README.md', 'w').write(open(T + '/README.head.md').read() + index())
print('wrote', OUT + '/issues and README.md')
