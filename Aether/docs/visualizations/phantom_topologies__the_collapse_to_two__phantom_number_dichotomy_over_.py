"""Visualize the two-valued phantom-number dichotomy over small finite spaces."""
import matplotlib.pyplot as plt
from itertools import combinations

def powerset(u):
    xs=list(u); return [frozenset(c) for r in range(len(xs)+1) for c in combinations(xs,r)]
def is_top(O,u):
    O=set(O)
    if frozenset() not in O or u not in O: return False
    return all((a|b) in O and (a&b) in O for a in O for b in O)
def all_tops(u):
    P=powerset(u); must={frozenset(),u}; opt=[s for s in P if s not in must]; out=[]
    for r in range(len(opt)+1):
        for e in combinations(opt,r):
            c=set(must)|set(e)
            if is_top(c,u): out.append(frozenset(c))
    return out
def cons(obs):
    r=set(obs[0])
    for t in obs[1:]: r&=set(t)
    return frozenset(r)
def reducible(real,u):
    finer=[t for t in all_tops(u) if set(real)<set(t)]
    return any(cons([b,c])==real for b,c in combinations(finer,2))

u=frozenset({0,1,2})
tops=all_tops(u)
labels=["2" if reducible(t,u) else "∞" for t in tops]
n2=labels.count("2"); ninf=labels.count("∞")
fig,ax=plt.subplots(figsize=(6,4))
ax.bar(["phantom number = 2\n(reducible)","unattainable\n(join-irreducible)"],[n2,ninf],
       color=["tab:green","tab:red"])
ax.set_title(f"Phantom number over all {len(tops)} topologies on 3 points")
ax.set_ylabel("number of topologies")
for i,v in enumerate([n2,ninf]): ax.text(i,v+0.3,str(v),ha="center")
plt.tight_layout(); plt.savefig("dichotomy.png",dpi=150); print("wrote dichotomy.png")
