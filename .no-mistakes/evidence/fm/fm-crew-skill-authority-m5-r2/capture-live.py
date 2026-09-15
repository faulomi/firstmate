import subprocess, pathlib, json
root=pathlib.Path.cwd(); ev=pathlib.Path('/Users/jerome/.no-mistakes/evidence/01M2J9X548SFSEAN9F0M3N4AT7'); tmux=str(root/'.nm-memory-lab/tools/tmux')
raw=subprocess.check_output([tmux,'list-panes','-a','-F','#{window_name}|#{pane_pid}'],text=True)
processes={}
for row in subprocess.check_output(['ps','-axo','pid=,ppid=,comm='],text=True).splitlines():
 parts=row.strip().split(None,2)
 if len(parts)==3:processes[int(parts[0])]=(int(parts[1]),parts[2])
results=[]
for line in raw.splitlines():
 name,pid=line.split('|'); pid=int(pid)
 if name=='bash':continue
 pane=subprocess.check_output([tmux,'capture-pane','-p','-t','firstmate:'+name,'-S','-300'],text=True)
 (ev/(name+'.txt')).write_text(pane)
 if name in ('fm-raw-codex','fm-raw-env'):
  row=next(x for x in pane.splitlines() if x.split() and x.split()[0]=='memories')
  assert row.split()[-1]=='true',row
  results.append({'window':name,'effective_memory':row.strip()});continue
 if name=='fm-raw-other':
  assert '\nRAW_NON_CODEX_PRESERVED\n' in pane
  results.append({'window':name,'output':'RAW_NON_CODEX_PRESERVED'});continue
 children={pid}
 for _ in range(12):
  children.update(p for p,(parent,_) in processes.items() if parent in children)
 found=[]
 for child in children:
  if pathlib.Path(processes.get(child,(0,''))[1]).name!='codex':continue
  cmd=subprocess.check_output(['ps','-ww','-p',str(child),'-o','command='],text=True)
  has_disable='--disable memories' in cmd
  expected=name in ('fm-live-ship','fm-live-scout')
  assert has_disable==expected,(name,cmd)
  if name=='fm-live-ship':assert '--model gpt-5' in cmd and 'model_reasoning_effort="high"' in cmd
  found.append({'pid':child,'argv_before_brief':cmd.split('FIRSTMATE_OP:')[0].strip(),'memory_disable_present':has_disable})
 assert found,('native Codex process missing',name)
 results.append({'window':name,'native_processes':found,'authentication_screen':'Sign in with ChatGPT' in pane})
(ev/'live-results.json').write_text(json.dumps(results,indent=2)+'\n')
print(json.dumps(results,indent=2))
