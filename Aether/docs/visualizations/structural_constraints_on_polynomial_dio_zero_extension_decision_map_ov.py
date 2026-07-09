import numpy as np
import matplotlib.pyplot as plt

# Sample constant shifts n = 1..40; over the rationals mark perfect squares.
ns = np.arange(1, 41)
is_square = np.array([int(round(n ** 0.5) ** 2 == n) for n in ns])

fig, ax = plt.subplots(figsize=(9, 3))
ax.scatter(ns[is_square == 1], np.zeros(is_square.sum()),
           c="green", s=80, label="perfect square: 0 may join")
ax.scatter(ns[is_square == 0], np.zeros((is_square == 0).sum()),
           c="red", s=40, marker="x", label="not a square: 0 forbidden")
ax.set_yticks([])
ax.set_xlabel("shift n (rational constant, k = 2)")
ax.set_title("Zero-extension gate: adjoining 0 is possible iff n is a k-th power")
ax.legend(loc="upper center", ncol=2)
plt.tight_layout()
plt.savefig("zero_extension_map.png", dpi=150)
print("wrote zero_extension_map.png")
