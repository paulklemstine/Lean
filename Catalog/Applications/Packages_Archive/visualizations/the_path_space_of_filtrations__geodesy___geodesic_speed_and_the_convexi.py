import matplotlib.pyplot as plt
from itertools import chain, combinations

def powerset(vs):
    vs = list(vs)
    return [frozenset(c) for c in chain.from_iterable(
        combinations(vs, r) for r in range(len(vs)+1))]

def filt(vs, seed):
    F = {}
    for s in powerset(vs):
        F[s] = 0.0 if not s else ((sum((seed*7+3)*(v+1) for v in s)%11)/10.0)+len(s)
    return F

def dist(F,G): return max(abs(F[s]-G[s]) for s in F)
def lerp(F,G,t): return {s:(1-t)*F[s]+t*G[s] for s in F}

V=[0,1,2]; F=filt(V,4); G=filt(V,8); H=filt(V,6)
ts=[k/100 for k in range(101)]
speed=[dist(F,lerp(F,G,t)) for t in ts]
line=[t*dist(F,G) for t in ts]
actual=[dist(H,lerp(F,G,t)) for t in ts]
bound=[(1-t)*dist(H,F)+t*dist(H,G) for t in ts]

fig,(ax1,ax2)=plt.subplots(1,2,figsize=(12,5))
ax1.plot(ts,speed,'b-',lw=2,label='d(F, lerp t)')
ax1.plot(ts,line,'r--',lw=1.5,label='t * d(F,G) (constant speed)')
ax1.set_title('Constant-speed geodesic'); ax1.set_xlabel('t'); ax1.legend()
ax2.plot(ts,actual,'b-',lw=2,label='d(H, lerp t)')
ax2.plot(ts,bound,'g--',lw=1.5,label='(1-t)d(H,F)+t d(H,G)')
ax2.fill_between(ts,actual,bound,alpha=0.2,color='orange',label='Busemann defect')
ax2.set_title('Busemann convexity (defect > 0 => flat)'); ax2.set_xlabel('t'); ax2.legend()
plt.tight_layout(); plt.savefig('geodesic_convexity.png',dpi=140); print('saved')
