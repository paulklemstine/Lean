"""Bar chart of the weight enumerator 1 + 14x^4 + x^8 of the Hamming [8,4,4]
code, the doubly-even self-dual minimal witness (mod-2 shadow of E8)."""
from __future__ import annotations
import itertools
from typing import List, Tuple
import matplotlib.pyplot as plt

Vector = Tuple[int, ...]
GEN: List[Vector] = [
    (1,1,1,1,1,1,1,1),(0,0,0,0,1,1,1,1),(0,0,1,1,0,0,1,1),(0,1,0,1,0,1,0,1)]

def vadd(x, y): return tuple((a+b) % 2 for a, b in zip(x, y))
def wt(x): return sum(x)

def span(gs):
    out = []
    for cs in itertools.product((0,1), repeat=len(gs)):
        acc = tuple(0 for _ in range(len(gs[0])))
        for c, g in zip(cs, gs):
            if c: acc = vadd(acc, g)
        out.append(acc)
    return list(dict.fromkeys(out))

def main() -> None:
    code = span(GEN)
    counts = {w: 0 for w in range(9)}
    for v in code: counts[wt(v)] += 1
    ws = list(counts.keys()); cs = list(counts.values())
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.bar(ws, cs, color="#3066BE")
    for w, c in counts.items():
        if c: ax.text(w, c + 0.2, str(c), ha="center", fontweight="bold")
    ax.set_xlabel("Hamming weight"); ax.set_ylabel("number of codewords")
    ax.set_title("Weight enumerator of Hamming [8,4,4]:  1 + 14 x^4 + x^8")
    plt.tight_layout(); plt.savefig("enumerator.png", dpi=150)
    print("wrote enumerator.png")

if __name__ == "__main__":
    main()
