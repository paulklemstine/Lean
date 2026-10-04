import re,io,sys
p="/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/Round48_SUMMARY.md"
L=open(p,encoding="utf-8").read().split("\n")
# census table = lines 195..222 (1-indexed) starting '| axis | status |'
rows=[(i+1,l) for i,l in enumerate(L) if l.startswith("| ") and l.count("|")>=3]
# isolate the main census table
start=None
for i,l in enumerate(L):
    if l.startswith("| axis | status |"): start=i;break
end=None
for j in range(start+1,len(L)):
    if not L[j].startswith("|"): end=j;break
print("CENSUS TABLE lines %d..%d"%(start+1,end))
crows=[(k+1,L[k]) for k in range(start+1,end)]
print("row count =",len(crows))
# duplicates on axis name
from collections import Counter
axes=[]
for n,l in crows:
    cells=[c.strip() for c in l.strip().strip("|").split("|")]
    axes.append((n,cells[0],cells[1][:60]))
cnt=Counter(a for _,a,_ in axes)
print("\nDUPLICATE AXES:")
for n,a,s in axes:
    if cnt[a]>1: print("  line %d  %s  [%s]"%(n,a[:60],s))
print("\nALL AXES:")
for n,a,s in axes: print("  %d  %-58s %s"%(n,a[:58],s))
# papers table
pstart=None
for i,l in enumerate(L):
    if l.startswith("| # | Paper | Issue |"): pstart=i;break
pend=None
for j in range(pstart+1,len(L)):
    if not L[j].startswith("|"): pend=j;break
print("\nPAPERS TABLE lines %d..%d"%(pstart+1,pend))
prows=[[c.strip() for c in L[k].strip().strip("|").split("|")] for k in range(pstart+1,pend)]
print("row count =",len(prows))
pc=Counter(r[0] for r in prows)
print("DUP paper numbers:",{k:v for k,v in pc.items() if v>1})
print("paper numbers present:",sorted(pc.keys(),key=lambda x:(0,int(x)) if x.isdigit() else (1,0)))
for r in prows: print("   #%s %s"%(r[0],r[1][:70]))
