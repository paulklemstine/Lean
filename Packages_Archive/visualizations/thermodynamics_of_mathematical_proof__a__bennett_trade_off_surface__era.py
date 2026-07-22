import math
import matplotlib.pyplot as plt

# Steps f: alpha -> beta collapsing alpha states onto |beta| outputs.
configs = [(8, 2), (16, 4), (32, 4), (64, 8), (128, 16)]
labels = [f"{a}->{b}" for a, b in configs]
naive_erased = [math.log2(a) - math.log2(b) for a, b in configs]
bennett_created = [math.log2(b) for a, b in configs]
bennett_erased = [0.0 for _ in configs]

x = range(len(configs))
w = 0.35
fig, ax = plt.subplots(figsize=(8, 5))
ax.bar([i - w/2 for i in x], naive_erased, w, label="naive step: erased bits", color="#e67e22")
ax.bar([i + w/2 for i in x], bennett_created, w, label="Bennett dilation: created bits", color="#2980b9")
ax.plot(list(x), bennett_erased, "kD", label="Bennett dilation: erased bits (=0)")
ax.set_xticks(list(x)); ax.set_xticklabels(labels)
ax.set_xlabel("register sizes |alpha|->|beta|")
ax.set_ylabel("bits")
ax.set_title("Bennett trade-off: erasure exchanged for allocation")
ax.legend()
ax.grid(True, axis="y", alpha=0.3)
plt.tight_layout()
plt.savefig("bennett_tradeoff.png", dpi=150)
print("saved bennett_tradeoff.png")
