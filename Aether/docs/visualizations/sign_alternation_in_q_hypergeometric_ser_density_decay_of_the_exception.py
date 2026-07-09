"""Visualization 2: density of the exceptional set vs the 2/sqrt(N) envelope."""
import math
import matplotlib.pyplot as plt

def is_square(n):
    r = math.isqrt(n); return r * r == n

pred = lambda n: is_square(n) or is_square(n + 1)
Ns = list(range(50, 20001, 50))
dens = []
count = 0
prev = 0
for N in Ns:
    count += sum(1 for n in range(prev, N) if pred(n))
    prev = N
    dens.append(count / N)
env = [2 / math.sqrt(N) for N in Ns]
plt.figure(figsize=(9, 5))
plt.plot(Ns, dens, label="empirical density of exceptions")
plt.plot(Ns, env, "--", label="2 / sqrt(N) envelope")
plt.xlabel("N"); plt.ylabel("density in [0,N)")
plt.title("Sign-alternation exceptions have density zero")
plt.legend(); plt.tight_layout()
plt.savefig("density_decay.png", dpi=130); print("saved density_decay.png")
