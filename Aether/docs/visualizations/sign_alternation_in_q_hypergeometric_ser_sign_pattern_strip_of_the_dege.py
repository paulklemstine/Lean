"""Visualization 1: sign-pattern strip for the degenerate-amplitude model."""
import math
import matplotlib.pyplot as plt

def is_square(n): 
    r = math.isqrt(n); return r * r == n

N = 120
signs = [0 if is_square(n) else (1 if n % 2 == 0 else -1) for n in range(N)]
colors = ["#cccccc" if s == 0 else ("#2b6cb0" if s > 0 else "#e53e3e") for s in signs]
fig, ax = plt.subplots(figsize=(12, 1.6))
ax.bar(range(N), [1] * N, color=colors, width=1.0)
ax.set_yticks([]); ax.set_xlabel("index n")
ax.set_title("Sign of a_n = (-1)^n A_n  (grey = amplitude vanishes on a square)")
plt.tight_layout(); plt.savefig("sign_strip.png", dpi=130); print("saved sign_strip.png")
