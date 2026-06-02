#!/usr/bin/env python3
import matplotlib.pyplot as plt
import numpy as np

def anti_fib(n): return n*(n-1)//2+1
def fib_seq(m):
    s=[0,1]
    for _ in range(m): s.append(s[-1]+s[-2])
    return s

N=50; fibs=fib_seq(N+2)
ns=list(range(1,N+1))
af_r=[anti_fib(n+1)/anti_fib(n) for n in ns]
fb_r=[fibs[n+1]/fibs[n] if fibs[n]>0 else 0 for n in ns]
phi=(1+np.sqrt(5))/2
fig,ax=plt.subplots(figsize=(12,7))
ax.plot(ns,af_r,'b-o',ms=4,lw=2,alpha=0.8,label='Anti-Fib → 1')
ax.plot(ns,fb_r,'r-s',ms=4,lw=2,alpha=0.8,label=f'Fib → φ≈{phi:.3f}')
ax.axhline(1,color='blue',ls='--',alpha=0.5,lw=1.5)
ax.axhline(phi,color='red',ls='--',alpha=0.5,lw=1.5)
ax.fill_between(ns,[1]*len(ns),[phi]*len(ns),alpha=0.08,color='purple')
ax.set_xlabel('n'); ax.set_ylabel('a(n+1)/a(n)'); ax.set_ylim(0.8,2.2)
ax.set_title('Ratio Convergence: 1 vs φ',fontsize=15,fontweight='bold')
ax.legend(fontsize=11); ax.grid(alpha=0.3)
plt.tight_layout(); plt.savefig('ratio_conv.png',dpi=150); plt.close()