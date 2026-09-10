import os, pathlib, re, subprocess, json, shutil
root = pathlib.Path.cwd()
work = root / '.pr-layout-live'
evidence = pathlib.Path('/Users/jerome/.no-mistakes/evidence/01M24RHXJBZYVXGCB0XAB5GHKV')
expected = ['## Intent', '## What Changed', '## Choices made where the spec was silent', '## Risk Assessment', '## Testing']
transcript = []
results = []
def run(source, home, command):
    env = {k:v for k,v in os.environ.items() if not k.startswith('FM_')}
    env.update(FM_HOME=str(home), FM_STATE_OVERRIDE=str(home/'state'), FM_DATA_OVERRIDE=str(home/'data'), FM_CONFIG_OVERRIDE=str(home/'config'), FM_GUARD_READ_ONLY='1')
    p = subprocess.run(['/bin/bash', str(source/'bin'/command[0]), *command[1:]], env=env, text=True, capture_output=True, cwd=root)
    transcript.append('$ FM_HOME='+str(home)+' /bin/bash '+str(source/'bin'/command[0])+' '+' '.join(command[1:])+'\n'+p.stdout+p.stderr+'exit='+str(p.returncode)+'\n')
    assert p.returncode == 0, transcript[-1]
def check(file, present, mode):
    text = file.read_text()
    headings = re.findall(r'^- `(## [^`]+)` -', text, re.M)
    assert headings == (expected if present else []), (file, headings)
    assert text.count('# PR body\n') == int(present), file
    if present:
        for required in ["captain's ask and why it matters", 'scope (in and out)', 'acceptance criteria', 'one bullet per changed file', 'every choice the spec did not settle, least-confident first', 'severity line with blast-radius reasoning', 'what was verified unchanged', 'base commit and after the fix, then lint and test evidence', 'never hand-write or edit them']:
            assert required in text, (file, required)
        assert ('After the pipeline opens the PR' in text) == (mode == 'no-mistakes'), file
        if mode == 'no-mistakes':
            assert 'preserving the existing Pipeline section and attestation comment byte-identically' in text
    assert not re.search(r'^## (?:Pipeline|Shape of the change)', text, re.M)
    return text
for version, source in [('base',work/'base'),('target',root)]:
    home = work/(version+'-home')
    for folder in ['data','state','config']:
        (home/folder).mkdir(parents=True,exist_ok=True)
    (home/'data/projects.md').write_text('- alpha [local-only] - local project\n- beta [direct-PR] - direct project\n')
    for mode in ['no-mistakes','direct-PR','local-only']:
        for project in ['alpha','beta']:
            task = 'layout-'+project+'-'+mode.lower()
            run(source, home, ['fm-brief.sh', task, project, '--mode', mode])
            file = home/'data'/task/'brief.md'
            check(file, version=='target' and mode!='local-only',mode)
            shutil.copyfile(file,evidence/(version+'-'+task+'.md'))
        task = 'promote-'+mode.lower()
        run(source,home,['fm-brief.sh',task,'alpha','--scout'])
        file = home/'data'/task/'brief.md'
        check(file,False,mode)
        file.write_text(file.read_text().replace('{TASK}','Make worker PRs explain the ask in plain language.').replace('{FIRSTMATE_SPEC}','Inspect the PR layout and preserve scope.'))
        (home/'state'/(task+'.meta')).write_text('kind=scout\nworktree='+str(work)+'\n')
        run(source,home,['fm-promote.sh',task,'--mode',mode,'--yolo','off'])
        promoted = home/'data'/task/'ship-instructions.md'
        check(promoted,version=='target' and mode!='local-only',mode)
        assert 'Make worker PRs explain the ask in plain language.' in promoted.read_text()
        assert 'kind=ship\nmode='+mode+'\nyolo=off' in (home/'state'/(task+'.meta')).read_text()
        ordinary=(home/'data'/('layout-alpha-'+mode.lower())/'brief.md').read_text()
        if version=='target' and mode!='local-only':
            def block(t): return t.split('# PR body\n',1)[1].split('\n# ',1)[0].strip()
            assert block(ordinary)==block(promoted.read_text()), mode
        shutil.copyfile(promoted,evidence/(version+'-'+task+'.md'))
    for task,args in [('scout',['alpha','--scout']),('secondmate',['--secondmate','alpha']),('secondmate-empty',['--secondmate','--no-projects'])]:
        run(source,home,['fm-brief.sh','layout-'+task,*args])
        file = home/'data'/('layout-'+task)/'brief.md'
        check(file,False,None)
        shutil.copyfile(file,evidence/(version+'-'+task+'.md'))
    results.append({'version':version,'result':'pass','observed': 'PR layout absent on base; baseline reproduction confirmed' if version=='base' else 'PR layout emitted identically for ordinary and promoted PR modes; exclusions and metadata instructions correct'})
(evidence/'cli-transcript.log').write_text('\n'.join(transcript))
(evidence/'results.json').write_text(json.dumps(results,indent=2)+'\n')
print(json.dumps(results,indent=2))
