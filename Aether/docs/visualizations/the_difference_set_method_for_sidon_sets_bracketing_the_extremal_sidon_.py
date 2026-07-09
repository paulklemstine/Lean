import math
import matplotlib.pyplot as plt

def greedy_sidon(n):
    chosen, realized = [], set()
    for x in range(1, n + 1):
        new = {x - s for s in chosen}
        if new.isdisjoint(realized):
            chosen.append(x); realized |= new; realized |= {-d for d in new}
    return chosen

Ns = list(range(2, 2001, 20))
upper = [math.sqrt(2 * n) + 1 for n in Ns]
greedy = [len(greedy_sidon(n)) for n in Ns]
loglb = [math.log2(n) + 1 for n in Ns]
truelead = [math.sqrt(n) for n in Ns]

plt.figure(figsize=(9, 6))
plt.plot(Ns, upper, label=r"upper bound $\sqrt{2N}+1$", lw=2)
plt.plot(Ns, truelead, "--", label=r"true order $\sqrt{N}$", lw=2)
plt.plot(Ns, greedy, label="greedy (Mian-Chowla) size", lw=2)
plt.plot(Ns, loglb, ":", label=r"powers-of-two LB $\log_2 N + 1$", lw=2)
plt.xlabel("N"); plt.ylabel("Sidon set size")
plt.title("Bracketing the extremal Sidon function F(N)")
plt.legend(); plt.grid(alpha=0.3); plt.tight_layout()
plt.savefig("sidon_bounds.png", dpi=150)
