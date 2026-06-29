"""Visualization: weight enumerators of Hamming and H16 = Hamming (+) Hamming."""
from itertools import product
import matplotlib.pyplot as plt

GEN = [(1,1,1,1,1,1,1,1),(0,0,0,0,1,1,1,1),(0,0,1,1,0,0,1,1),(0,1,0,1,0,1,0,1)]

def generate(gen):
    n = len(gen[0]); out = set()
    for a in product((0,1), repeat=len(gen)):
        out.add(tuple(sum(a[i]*gen[i][j] for i in range(len(gen))) % 2 for j in range(n)))
    return list(out)

def enum(code, n):
    d = {w: 0 for w in range(n+1)}
    for c in code:
        d[sum(c)] += 1
    return d

H = generate(GEN)
H16 = [tuple(a)+tuple(b) for a in H for b in H]
eH, eH16 = enum(H, 8), enum(H16, 16)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
ax1.bar(list(eH), list(eH.values()), color="#2b6cb0")
ax1.set_title("Hamming [8,4,4]: 1 + 14 X^4 + X^8")
ax1.set_xlabel("weight"); ax1.set_ylabel("# codewords")
ax2.bar(list(eH16), list(eH16.values()), color="#c05621")
ax2.set_title("H16 = Hamming (+) Hamming  (256 codewords)")
ax2.set_xlabel("weight"); ax2.set_ylabel("# codewords")
plt.tight_layout()
plt.savefig("weight_enumerators.png", dpi=140)
print("saved weight_enumerators.png")
