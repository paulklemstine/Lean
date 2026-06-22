"""Visualization: the positional (tprof) spectrum vs the weight (wt) spectrum
of the extended Hamming [8,4,4] code. Requires matplotlib."""
from itertools import product
from typing import List, Tuple
import matplotlib.pyplot as plt

Vec = Tuple[int, ...]
GEN = ((1,1,1,1,1,1,1,1),(0,0,0,0,1,1,1,1),(0,0,1,1,0,0,1,1),(0,1,0,1,0,1,0,1))


def add2(x: Vec, y: Vec) -> Vec:
    return tuple((a + b) % 2 for a, b in zip(x, y))


def encode(a: Vec) -> Vec:
    out = (0,) * 8
    for i, ai in enumerate(a):
        if ai:
            out = add2(out, GEN[i])
    return out


def wt(x: Vec) -> int:
    return sum(x)


def tprof(x: Vec) -> int:
    return max((i + 1 for i, b in enumerate(x) if b), default=0)


code: List[Vec] = [encode(tuple(a)) for a in product((0, 1), repeat=4)]

wt_spec = {w: sum(1 for c in code if wt(c) == w) for w in range(9)}
tp_spec = {t: sum(1 for c in code if tprof(c) == t) for t in range(9)}

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4))
ax1.bar(list(wt_spec), list(wt_spec.values()), color="#c0392b")
ax1.set_title("Hamming weight spectrum  (1 + 14x^4 + x^8)")
ax1.set_xlabel("wt"); ax1.set_ylabel("# codewords")
ax2.bar(list(tp_spec), list(tp_spec.values()), color="#2980b9")
ax2.set_title("Threshold profile spectrum  (positional)")
ax2.set_xlabel("tprof"); ax2.set_ylabel("# codewords")
fig.suptitle("Extended Hamming [8,4,4]: two readings of the same 16 codewords")
fig.tight_layout()
fig.savefig("hamming_spectra.png", dpi=150)
print("wrote hamming_spectra.png")
