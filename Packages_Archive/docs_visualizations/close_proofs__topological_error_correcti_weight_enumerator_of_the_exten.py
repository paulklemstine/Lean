"""Weight enumerator of the extended Hamming [8,4,4] code (mod-2 shadow of E8)."""
import itertools
import matplotlib.pyplot as plt

GEN = [(1,1,1,1,1,1,1,1),(0,0,0,0,1,1,1,1),(0,0,1,1,0,0,1,1),(0,1,0,1,0,1,0,1)]

def encode(a):
    return tuple(sum(a[i]*GEN[i][j] for i in range(4)) % 2 for j in range(8))

code = {encode(a) for a in itertools.product((0,1), repeat=4)}
weights = [sum(c) for c in code]
counts = [weights.count(w) for w in range(9)]

plt.figure(figsize=(8,5))
bars = plt.bar(range(9), counts, color=["#c0392b" if w%4==0 else "#bdc3c7" for w in range(9)])
plt.xlabel("Hamming weight"); plt.ylabel("number of codewords")
plt.title("Weight enumerator of Hamming [8,4,4]: 1 + 14 z^4 + z^8\n(red = divisible by 4: ALL of them => doubly even)")
for w,c in enumerate(counts):
    if c: plt.text(w, c+0.2, str(c), ha="center")
plt.xticks(range(9)); plt.tight_layout()
plt.savefig("hamming_weight_enumerator.png", dpi=140)
print("saved hamming_weight_enumerator.png")
