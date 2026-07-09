"""Visualize +/-1 rank walks colored by their (rigid) terminal parity."""
import matplotlib.pyplot as plt
import random

random.seed(0)
n = 40
start = 0
plt.figure(figsize=(9, 5))
for _ in range(30):
    w = [start]
    for _ in range(n):
        w.append(w[-1] + random.choice((1, -1)))
    color = "tab:blue" if w[-1] % 2 == 0 else "tab:red"
    plt.plot(range(n + 1), w, color=color, alpha=0.4)
plt.title(f"Rank walks from {start}: terminal parity fixed at (start+n) mod 2 = {(start+n)%2}")
plt.xlabel("step n")
plt.ylabel("rank w(n)")
plt.tight_layout()
plt.savefig("rank_walks.png", dpi=150)
print("wrote rank_walks.png")
