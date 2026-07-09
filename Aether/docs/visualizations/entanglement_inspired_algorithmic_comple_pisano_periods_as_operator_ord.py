"""Visualization: Pisano periods pi(m) = order of M in GL_2(Z/mZ)."""
import matplotlib.pyplot as plt

def mul(x, y, m):
    a,b,c,d=x; e,f,g,h=y
    return ((a*e+b*g)%m,(a*f+b*h)%m,(c*e+d*g)%m,(c*f+d*h)%m)

def period(m):
    if m==1: return 1
    ident=(1%m,0,0,1%m); p=(1,1,1,0); M=(1,1,1,0); s=1
    while p!=ident:
        p=mul(p,M,m); s+=1
    return s

ms=list(range(1,61)); ps=[period(m) for m in ms]
plt.figure(figsize=(10,5))
plt.stem(ms, ps)
plt.xlabel("modulus m"); plt.ylabel("Pisano period pi(m) = order of M")
plt.title("Cyclicity from a finite noncommutative state space")
plt.grid(alpha=0.3); plt.tight_layout(); plt.savefig("pisano_periods.png", dpi=150)
print("wrote pisano_periods.png")
