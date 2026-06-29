"""Visualization: the Merkle-Damgard chain and a collision merge.
Generates merkle_damgard_chain.png."""
import matplotlib.pyplot as plt

def merkle_damgard(f, iv, msg):
    states = [iv]
    s = iv
    for b in msg:
        s = f(s, b); states.append(s)
    return states

f = lambda s, b: (s + b) % 257
m1, m2 = [1, 256], [256, 1]
c1 = merkle_damgard(f, 0, m1)
c2 = merkle_damgard(f, 0, m2)

fig, ax = plt.subplots(figsize=(8, 4))
for chain, y, color, lbl in [(c1, 1, "tab:blue", "message m1"),
                             (c2, 0, "tab:red", "message m2")]:
    xs = list(range(len(chain)))
    ax.plot(xs, [y]*len(chain), "-o", color=color, label=lbl)
    for x, v in zip(xs, chain):
        ax.annotate(str(v), (x, y), textcoords="offset points", xytext=(0, 10))
ax.annotate("collision: both reach digest 0",
            (len(c1)-1, 0.5), ha="center",
            arrowprops=dict(arrowstyle="->"), xytext=(len(c1)-1, 0.5))
ax.set_title("Two distinct messages, same Merkle-Damgard digest")
ax.set_xlabel("compression step"); ax.set_yticks([])
ax.legend(); fig.tight_layout()
fig.savefig("merkle_damgard_chain.png", dpi=150)
print("wrote merkle_damgard_chain.png")
