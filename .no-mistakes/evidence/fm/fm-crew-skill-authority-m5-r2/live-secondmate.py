import os, pathlib, subprocess, time, json
root=pathlib.Path.cwd(); d=root/'.test-memory-phase/live-secondmate-2'; d.mkdir(parents=True,exist_ok=True)
ev=pathlib.Path('/Users/jerome/.no-mistakes/evidence/01M2J6TSFNM3YDNSDWZ1D478D3')
env=os.environ.copy()
for k in ['TMUX','TMUX_PANE','FM_TASK_ID','CLAUDECODE','CLAUDE_CONFIG_DIR','FM_STATE_OVERRIDE','FM_DATA_OVERRIDE','FM_CONFIG_OVERRIDE','FM_PROJECTS_OVERRIDE','FM_ROOT_OVERRIDE','OPENAI_API_KEY','CODEX_API_KEY']:
 env.pop(k,None)
for name in ['user','codex','home/data','home/config','home/state','home/projects','pool','tmp']:(d/name).mkdir(parents=True,exist_ok=True)
(d/'codex/config.toml').write_text('[features]\nmemories = true\n')
env.update(HOME=str(d/'user'),CODEX_HOME=str(d/'codex'),FM_HOME=str(d/'home'),FM_GATE_REFUSE_BYPASS='1',FM_SPAWN_NO_GUARD='1',FM_BACKEND='tmux',TREEHOUSE_ROOT=str(d/'pool'),TMPDIR=str(d/'tmp'),SHELL='/bin/bash',GIT_CONFIG_GLOBAL='/dev/null',GIT_CONFIG_NOSYSTEM='1')
def run(args,**kwargs):
 p=subprocess.run(args,env=env,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,**kwargs)
 print('$ '+' '.join(map(str,args))+'\n'+p.stdout,flush=True)
 return p
proj=d/'project'; proj.mkdir(exist_ok=True)
run(['git','init','-q','-b','main',str(proj)])
(proj/'README.md').write_text('Local memory launch verification\n')
run(['git','-C',str(proj),'add','README.md'])
run(['git','-C',str(proj),'-c','user.name=Test','-c','user.email=test@example.invalid','commit','-qm','fixture'])
run(['git','clone','--bare','--quiet',str(proj),str(d/'origin.git')])
run(['git','-C',str(proj),'remote','add','origin',str(d/'origin.git')])
sock=root/'.mt'; tmux=['tmux','-S',str(sock)]
try:
 p=run(tmux+['-f','/dev/null','new-session','-d','-s','firstmate','-c',str(d)])
 if p.returncode:raise RuntimeError('isolated tmux startup failed')
 run(tmux+['set-option','-g','default-shell','/bin/bash'])
 run(tmux+['set-option','-g','default-command','/bin/bash --noprofile --norc'])
 pid=run(tmux+['display-message','-p','#{pid}']).stdout.strip()
 env['TMUX']=str(sock)+','+pid+',0'
 for kind in ['secondmate']:
  task='memory-live-'+kind; bd=d/'home/data'/task; bd.mkdir()
  (bd/'brief.md').write_text('# Task\n## Captain\'s intent\nVerify a local test launch.\n\n## Firstmate spec\nReply only MEMORY_LAUNCH_OK. Do not use tools or change files.\n')
  args=[str(root/'bin/fm-spawn.sh'),task,str(proj),'--harness','codex']
  sm=d/'secondmate'; (sm/'data').mkdir(parents=True)
  (sm/'bin').symlink_to(root/'bin',target_is_directory=True)
  (sm/'AGENTS.md').write_text('# Local verification home\n')
  (sm/'.fm-secondmate-home').write_text(task+'\n')
  (sm/'data/charter.md').write_text('Reply MEMORY_LAUNCH_OK. Do not use tools.\n')
  (d/'home/bin').symlink_to(root/'bin',target_is_directory=True)
  env['FM_ROOT_OVERRIDE']=str(d/'home')
  args=[str(root/'bin/fm-spawn.sh'),task,str(sm),'--harness','codex','--secondmate']
  p=run(args,timeout=85)
  (ev/(kind+'-spawn.txt')).write_text(p.stdout)
  time.sleep(2)
  pane=run(tmux+['capture-pane','-p','-t','firstmate:fm-'+task,'-S','-100'])
  (ev/(kind+'-pane.txt')).write_text(pane.stdout)
  procs=subprocess.run(['ps','-axo','pid,ppid,command'],text=True,stdout=subprocess.PIPE)
  pane_pid=run(tmux+['display-message','-p','-t','firstmate:fm-'+task,'#{pane_pid}']).stdout.strip()
  descendants={pane_pid}; lines=procs.stdout.splitlines()
  for _ in range(8):
   for x in lines:
    bits=x.split(None,2)
    if len(bits)==3 and bits[1] in descendants:descendants.add(bits[0])
  rows=[x for x in lines if x.split(None,1)[0] in descendants]
  (ev/(kind+'-process.txt')).write_text('\n'.join(rows)+'\n')
finally:
 run(tmux+['kill-server'])
