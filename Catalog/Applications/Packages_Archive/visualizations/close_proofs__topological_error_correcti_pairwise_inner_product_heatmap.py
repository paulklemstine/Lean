"""Pairwise binary inner-product matrix of the Hamming code: it is identically zero."""
import itertools
import matplotlib.pyplot as plt

GEN = [(1,1,1,1,1,1,1,1),(0,0,0,0,1,1,1,1),(0,0,1,1,0,0,1,1),(0,1,0,1,0,1,0,1)]
def encode(a): return tuple(sum(a[i]*GEN[i][j] for i in range(4))%2 for j in range(8))
code = sorted({encode(a) for a in itertools.product((0,1), repeat=4)})

M = [[sum(x[i]*y[i] for i in range(8)) % 2 for y in code] for x in code]
plt.figure(figsize=(6,6))
plt.imshow(M, cmap="RdYlGn_r", vmin=0, vmax=1)
plt.title("ip(x,y) over the 16 codewords -- all zero\n(self-orthogonality DERIVED via the bridge theorem)")
plt.xlabel("codeword index"); plt.ylabel("codeword index")
plt.colorbar(label="binary inner product"); plt.tight_layout()
plt.savefig("hamming_orthogonality.png", dpi=140)
print("saved hamming_orthogonality.png")
