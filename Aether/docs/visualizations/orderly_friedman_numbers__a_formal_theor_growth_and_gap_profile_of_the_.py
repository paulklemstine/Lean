"""Visualize the growth and gaps of the orderly Friedman sequence A080035."""
import matplotlib.pyplot as plt

TERMS = [127, 343, 736, 1285, 2187, 2502, 2592, 2737, 3125, 3685, 3864, 3972,
         4096, 6455, 11264, 11664, 12850, 13825, 14641]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

idx = list(range(1, len(TERMS) + 1))
ax1.plot(idx, TERMS, "o-", color="#2a6f97")
ax1.set_xlabel("index n"); ax1.set_ylabel("a(n)")
ax1.set_title("Orderly Friedman numbers (A080035)")
ax1.set_yscale("log"); ax1.grid(True, alpha=0.3)

gaps = [TERMS[i + 1] - TERMS[i] for i in range(len(TERMS) - 1)]
ax2.bar(range(1, len(gaps) + 1), gaps, color="#e09f3e")
ax2.set_xlabel("index n"); ax2.set_ylabel("a(n+1) - a(n)")
ax2.set_title("Consecutive gaps")
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("orderly_friedman_sequence.png", dpi=150)
print("saved orderly_friedman_sequence.png")
