"""Visualization: recurrence of a primitive prime p=233 (born at n=13)."""
import matplotlib.pyplot as plt

def fibs_mod(p, N):
    a,b=0,1; out=[]
    for _ in range(N):
        out.append(a); a,b=b,(a+b)%p
    return out

p=233; N=220; res=fibs_mod(p,N)
hits=[n for n,v in enumerate(res) if v==0 and n>0]
plt.figure(figsize=(11,3.5))
plt.plot(range(N), res, lw=0.7, color="gray")
plt.scatter(hits, [0]*len(hits), color="crimson", zorder=3,
            label=f"F_n = 0 (mod {p}) at n = {hits}")
plt.xlabel("index n"); plt.ylabel(f"F_n mod {p}")
plt.title(f"Prime {p}: born at n=13, recurs every {hits[1]-hits[0]} steps")
plt.legend(); plt.tight_layout(); plt.savefig("primitive_recurrence.png", dpi=150)
print("wrote primitive_recurrence.png")
