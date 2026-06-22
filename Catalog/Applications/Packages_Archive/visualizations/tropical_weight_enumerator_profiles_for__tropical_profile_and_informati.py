"""Plot the tropical weight enumerator profile of the extended Hamming code
and of Hamming (+) Hamming, illustrating tropical additivity and information loss."""
from itertools import product
from typing import List, Tuple
import numpy as np
import matplotlib.pyplot as plt

Codeword = Tuple[int, ...]

HAMMING_GEN = [
    (1, 1, 1, 1, 1, 1, 1, 1),
    (0, 0, 0, 0, 1, 1, 1, 1),
    (0, 0, 1, 1, 0, 0, 1, 1),
    (0, 1, 0, 1, 0, 1, 0, 1),
]


def weight(c: Codeword) -> int:
    return sum(1 for x in c if x % 2 == 1)


def hamming_code() -> List[Codeword]:
    out = []
    for a in product((0, 1), repeat=4):
        out.append(tuple(sum(a[i] * HAMMING_GEN[i][j] for i in range(4)) % 2
                         for j in range(8)))
    return out


def twe(C, t):
    return min(weight(c) * t for c in C)


H = hamming_code()
HH = [tuple(a) + tuple(b) for a in H for b in H]
ts = np.linspace(-1.0, 1.0, 400)

fig, ax = plt.subplots(figsize=(8, 5))
# faint lines for every weight slope (including the erased weight-4 line)
for w in sorted({weight(c) for c in H}):
    ax.plot(ts, w * ts, "--", alpha=0.4,
            label=f"slope w={w}" + (" (ERASED)" if w == 4 else ""))
ax.plot(ts, [twe(H, t) for t in ts], lw=3, color="crimson",
        label="twe_Hamming = min(0, 8t)")
ax.plot(ts, [twe(HH, t) for t in ts], lw=2, color="navy",
        label="twe_(H+H) = min(0, 16t)")
ax.axhline(0, color="k", lw=0.5); ax.axvline(0, color="k", lw=0.5)
ax.set_xlabel("tropical slope t"); ax.set_ylabel("twe(t)")
ax.set_title("Tropical weight enumerator: information loss & additivity")
ax.legend(fontsize=8)
plt.tight_layout()
plt.savefig("twe_profile.png", dpi=150)
print("wrote twe_profile.png")
