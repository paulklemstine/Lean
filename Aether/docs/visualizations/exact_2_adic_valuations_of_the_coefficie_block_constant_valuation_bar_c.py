"""Bar chart of nu_2(t_5(n)) showing block-constancy on length-4 blocks."""
import matplotlib.pyplot as plt

def v2(a):
    if a == 0:
        return 0
    a, e = abs(a), 0
    while a % 2 == 0:
        a //= 2; e += 1
    return e

def t5(length):
    t = [0]*length
    t[0] = 1
    g = lambda k: t[k] if 0 <= k < length else 0
    for n in range(1, length):
        s = n//2
        t[n] = (g(s)+10*g(s-1)+5*g(s-2)) if n%2==0 else -(5*g(s)+10*g(s-1)+g(s-2))
    return t

N = 128
vals = [v2(x) for x in t5(N)]
colors = ["#2b8cbe" if (n//4)%2==0 else "#e34a33" for n in range(N)]
plt.figure(figsize=(14,4))
plt.bar(range(N), vals, color=colors, width=0.9)
plt.title(r"$\nu_2(t_5(n))$ is constant on blocks of 4 (blue: even block, red: odd block)")
plt.xlabel("n"); plt.ylabel(r"$\nu_2(t_5(n))$")
plt.tight_layout(); plt.savefig("valuation_blocks.png", dpi=130)
print("wrote valuation_blocks.png")
