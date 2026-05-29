"""
Visualization: Critical Group Structure Heatmap

Shows the distribution of p-primary parts of critical groups for lifts of
K₄ across varying sheet counts and primes, revealing how the group
structure depends on the Betti number.
"""

import numpy as np
import matplotlib.pyplot as plt
import random
from collections import Counter
from functools import reduce


# ============================================================
# Self-contained algorithms
# ============================================================

def laplacian(edges, nv):
    A = np.zeros((nv,nv), dtype=int)
    for u,v in edges: A[u,v]=1; A[v,u]=1
    return np.diag(A.sum(1))-A

def red_lap(edges, nv, b=0):
    L=laplacian(edges,nv); idx=[i for i in range(nv) if i!=b]
    return L[np.ix_(idx,idx)]

def snf(M):
    from math import gcd
    M=M.copy().astype(int); r,c=M.shape; n=min(r,c); d=[]
    for k in range(n):
        s=M[k:,k:]
        if not np.any(s): d.extend([0]*(n-k)); break
        for _ in range(200):
            s=M[k:,k:]; nz=s[s!=0]
            if len(nz)==0: break
            ix=np.argwhere(np.abs(s)==np.min(np.abs(nz)))[0]
            pi,pj=ix[0]+k,ix[1]+k
            if pi!=k: M[[k,pi]]=M[[pi,k]]
            if pj!=k: M[:,[k,pj]]=M[:,[pj,k]]
            if M[k,k]<0: M[k]=-M[k]
            ch=False
            for i in range(k+1,r):
                if M[i,k]!=0: M[i]-=(M[i,k]//M[k,k])*M[k]
                if M[i,k]!=0: ch=True
            for j in range(k+1,c):
                if M[k,j]!=0: M[:,j]-=(M[k,j]//M[k,k])*M[:,k]
                if M[k,j]!=0: ch=True
            if not ch:
                s2=M[k+1:,k+1:]
                if M[k,k] and s2.size>0 and np.all(s2%M[k,k]==0): break
                elif M[k,k] and s2.size>0:
                    done=False
                    for i in range(k+1,r):
                        for j in range(k+1,c):
                            if M[i,j]%M[k,k]!=0: M[k]+=M[i]; done=True; break
                        if done: break
                else: break
        d.append(abs(M[k,k]))
    for i in range(len(d)-1):
        if d[i] and d[i+1]:
            g=gcd(d[i],d[i+1]); d[i],d[i+1]=g,d[i]*d[i+1]//g
    return d

def crit_group(edges, nv, b=0):
    return [x for x in snf(red_lap(edges,nv,b)) if x>1]

def p_part(factors, p):
    r=[]
    for d in factors:
        pk=1
        while d%p==0: pk*=p; d//=p
        if pk>1: r.append(pk)
    return tuple(sorted(r))

def rand_lift(edges, nv, ns):
    volt={}
    for u,v in edges:
        p=list(range(ns)); random.shuffle(p); volt[(u,v)]=p
        inv=[0]*ns
        for i,j in enumerate(p): inv[j]=i
        volt[(v,u)]=inv
    le=set(); ln=nv*ns
    for u,v in edges:
        for i in range(ns):
            j=volt[(u,v)][i]
            e=(min(u*ns+i,v*ns+j),max(u*ns+i,v*ns+j))
            le.add(e)
    return list(le), ln

def connected(edges, nv):
    if nv==0: return True
    adj={i:[] for i in range(nv)}
    for u,v in edges: adj[u].append(v); adj[v].append(u)
    vis=set([0]); q=[0]
    while q:
        nd=q.pop(0)
        for nb in adj[nd]:
            if nb not in vis: vis.add(nb); q.append(nb)
    return len(vis)==nv


# ============================================================
# Experiment: Probability of trivial p-primary part
# ============================================================

random.seed(42)
np.random.seed(42)

base_edges = [(i,j) for i in range(4) for j in range(i+1,4)]  # K_4
base_nv = 4

primes = [2, 3, 5, 7]
sheets = [2, 3, 4, 5]
n_samples = 800

# Compute probability that p-primary part is trivial
prob_trivial = np.zeros((len(primes), len(sheets)))
prob_rank1 = np.zeros((len(primes), len(sheets)))

for pi, p in enumerate(primes):
    for si, ns in enumerate(sheets):
        trivial_count = 0
        rank1_count = 0
        total = 0
        for _ in range(n_samples):
            le, ln = rand_lift(base_edges, base_nv, ns)
            if connected(le, ln):
                cg = crit_group(le, ln)
                pp = p_part(cg, p)
                total += 1
                if len(pp) == 0:
                    trivial_count += 1
                elif len(pp) == 1:
                    rank1_count += 1
        if total > 0:
            prob_trivial[pi, si] = trivial_count / total
            prob_rank1[pi, si] = rank1_count / total

# ============================================================
# Plot
# ============================================================

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Heatmap 1: P[trivial p-primary part]
im1 = ax1.imshow(prob_trivial, cmap='YlOrRd_r', aspect='auto', vmin=0, vmax=1)
ax1.set_xticks(range(len(sheets)))
ax1.set_xticklabels([f'n={ns}' for ns in sheets], fontsize=11)
ax1.set_yticks(range(len(primes)))
ax1.set_yticklabels([f'p={p}' for p in primes], fontsize=11)
ax1.set_title('Pr[Jac(G̃)[p∞] = 0]', fontsize=14, fontweight='bold')
ax1.set_xlabel('Number of sheets', fontsize=12)
ax1.set_ylabel('Prime p', fontsize=12)

for i in range(len(primes)):
    for j in range(len(sheets)):
        ax1.text(j, i, f'{prob_trivial[i,j]:.3f}',
                ha='center', va='center', fontsize=11,
                color='white' if prob_trivial[i,j] < 0.5 else 'black')

plt.colorbar(im1, ax=ax1, shrink=0.8)

# Heatmap 2: P[rank-1 p-primary part]
im2 = ax2.imshow(prob_rank1, cmap='YlGnBu', aspect='auto', vmin=0, vmax=0.5)
ax2.set_xticks(range(len(sheets)))
ax2.set_xticklabels([f'n={ns}' for ns in sheets], fontsize=11)
ax2.set_yticks(range(len(primes)))
ax2.set_yticklabels([f'p={p}' for p in primes], fontsize=11)
ax2.set_title('Pr[rank(Jac(G̃)[p∞]) = 1]', fontsize=14, fontweight='bold')
ax2.set_xlabel('Number of sheets', fontsize=12)
ax2.set_ylabel('Prime p', fontsize=12)

for i in range(len(primes)):
    for j in range(len(sheets)):
        ax2.text(j, i, f'{prob_rank1[i,j]:.3f}',
                ha='center', va='center', fontsize=11,
                color='white' if prob_rank1[i,j] > 0.25 else 'black')

plt.colorbar(im2, ax=ax2, shrink=0.8)

fig.suptitle('Critical Group p-Primary Structure for Lifts of K₄ (b₁ = 3)\n'
             'Larger primes → more likely trivial p-part; '
             'More sheets → distribution stabilizes',
             fontsize=13, fontweight='bold', y=1.05)

plt.tight_layout()
plt.savefig('viz_critical_groups.png', dpi=150, bbox_inches='tight')
print("Saved viz_critical_groups.png")
