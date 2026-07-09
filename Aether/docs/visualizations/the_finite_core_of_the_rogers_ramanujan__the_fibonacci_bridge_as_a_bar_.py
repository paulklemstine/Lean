"""Bar chart showing D_n(1) climbing along the Fibonacci sequence.
Requires matplotlib."""
import matplotlib.pyplot as plt
from typing import List

def add(a,b):
    out=[0]*max(len(a),len(b))
    for i,c in enumerate(a): out[i]+=c
    for i,c in enumerate(b): out[i]+=c
    while out and out[-1]==0: out.pop()
    return out

def schur(n):
    a,b=[1],[1]
    if n==0: return a
    for i in range(n-1):
        a,b=b,add(b,[0]*(i+1)+a)
    return b

def ev(p,x):
    acc=0
    for c in reversed(p): acc=acc*x+c
    return acc

N=15
ns=list(range(N))
vals=[ev(schur(n),1) for n in ns]
plt.figure(figsize=(9,5))
plt.bar(ns, vals, color="#4C72B0")
for n,v in zip(ns,vals):
    plt.text(n, v, str(v), ha="center", va="bottom", fontsize=8)
plt.xlabel("n")
plt.ylabel("D_n(1)")
plt.title("D_n(1) = F_{n+1}: the Fibonacci bridge")
plt.tight_layout()
plt.savefig("fibonacci_bridge.png", dpi=150)
print("wrote fibonacci_bridge.png")
