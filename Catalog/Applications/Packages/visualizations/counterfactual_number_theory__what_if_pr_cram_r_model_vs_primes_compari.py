#!/usr/bin/env python3
import math, random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def sieve(n):
    is_p = [True]*(n+1); is_p[0]=is_p[1]=False
    for i in range(2,int(n**0.5)+1):
        if is_p[i]:
            for j in range(i*i,n+1,i): is_p[j]=False
    return {i for i in range(2,n+1) if is_p[i]}

def cramer(N,seed=42):
    rng=random.Random(seed)
    return {n for n in range(2,N+1) if rng.random()<1.0/math.log(n)}

N=2000; primes=sieve(N)
fig,axes=plt.subplots(1,2,figsize=(14,5))
xs=list(range(2,N+1))
axes[0].plot(xs,np.cumsum([1 if x in primes else 0 for x in xs]),'b-',lw=2,label='primes')
for s in range(3):
    S=cramer(N,s)
    axes[0].plot(xs,np.cumsum([1 if x in S else 0 for x in xs]),'--',alpha=0.6,label=f'random {s}')
axes[0].plot(xs,[x/math.log(x) for x in xs],'k:',lw=1.5,label='x/ln(x)')
axes[0].legend(); axes[0].set_title('Counting Functions')
Ns=[20,30,50,75,100,150,200,300]
def is_pf(S):
    e=sorted(s for s in S if s>=2)
    for i,a in enumerate(e):
        for b in e[i:]:
            if a*b in S: return False
    return True
probs=[sum(1 for s in range(200) if is_pf(cramer(n,s)))/200 for n in Ns]
axes[1].semilogy(Ns,[max(p,0.001) for p in probs],'ro-',lw=2)
axes[1].set_title('P(product-free)'); axes[1].set_xlabel('N')
plt.tight_layout(); plt.savefig('cramer_comparison.png',dpi=150)
