"""Visualization: heatmap of F_n mod m showing horizontal periodicity."""
import matplotlib.pyplot as plt
import numpy as np

def fibs_mod(m, N):
    a,b=0,1; out=[]
    for _ in range(N):
        out.append(a); a,b=b,(a+b)%m
    return out

N=120; grid=np.array([fibs_mod(m,N) for m in range(2,21)])
plt.figure(figsize=(12,5))
plt.imshow(grid, aspect="auto", cmap="viridis",
           extent=[0,N,20,2])
plt.colorbar(label="F_n mod m")
plt.xlabel("index n"); plt.ylabel("modulus m")
plt.title("F_n mod m: each row repeats with its Pisano period")
plt.tight_layout(); plt.savefig("fib_heatmap.png", dpi=150)
print("wrote fib_heatmap.png")
