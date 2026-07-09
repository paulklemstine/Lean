"""Plot the cyclic Davenport threshold D(Z/m) against m, confirming D = m."""
from itertools import product
import matplotlib.pyplot as plt

def has_zero_sum(seq, m):
    reachable = set()
    for value in seq:
        v = value % m
        reachable = reachable | {v} | {(r + v) % m for r in reachable}
        if 0 in reachable:
            return True
    return 0 in reachable

def davenport(m):
    n = 1
    while not all(has_zero_sum(s, m) for s in product(range(m), repeat=n)):
        n += 1
    return n

ms = list(range(1, 8))
ds = [davenport(m) for m in ms]
plt.figure(figsize=(6, 4))
plt.plot(ms, ds, "o-", label="computed D(Z/m)")
plt.plot(ms, ms, "--", color="gray", label="y = m")
plt.xlabel("m"); plt.ylabel("Davenport constant D(Z/m)")
plt.title("Cyclic Davenport constant equals the group order")
plt.legend(); plt.grid(True, alpha=0.3); plt.tight_layout()
plt.savefig("davenport_threshold.png", dpi=150)
print("wrote davenport_threshold.png")
