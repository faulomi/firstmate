import os, pathlib, subprocess, hashlib
lab=pathlib.Path.cwd()/'.nm-memory-lab'
env=dict(os.environ,CODEX_HOME=str(lab/'codex'))
config=lab/'codex/config.toml'
before=config.read_bytes()
for label,args,expected in [
 ('memory-on baseline',[], 'true'),
 ('canonical scout flags',['--dangerously-bypass-approvals-and-sandbox','--disable','memories'], 'false'),
 ('canonical ship flags',['--model','gpt-5','-c','model_reasoning_effort="high"','--dangerously-bypass-approvals-and-sandbox','--disable','memories'], 'false'),
 ('secondmate defaults',['--dangerously-bypass-approvals-and-sandbox'], 'true'),
 ('subsequent personal-style invocation',[], 'true')]:
 cmd=['/opt/homebrew/bin/codex',*args,'features','list']
 result=subprocess.run(cmd,env=env,text=True,capture_output=True,check=True)
 row=next(line for line in result.stdout.splitlines() if line.split()[0]=='memories')
 print(label, '\n command:',repr(cmd),'\n output:',row)
 assert row.split()[-1]==expected
assert before==config.read_bytes()
print('Isolated config unchanged:',hashlib.sha256(before).hexdigest())
res=subprocess.run(['/opt/homebrew/bin/codex','login','status'],env=env,text=True,capture_output=True)
print('Isolated authentication:',res.stdout.strip(),res.stderr.strip(),'exit=',res.returncode)
