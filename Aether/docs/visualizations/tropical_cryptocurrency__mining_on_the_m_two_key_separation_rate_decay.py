import random
import matplotlib.pyplot as plt

def tsha(h, m):
    return min(mi + hi for mi, hi in zip(m, h))

def argmin_index(h, m):
    bi, bv = 0, m[0] + h[0]
    for i in range(1, len(m)):
        v = m[i] + h[i]
        if v < bv:
            bi, bv = i, v
    return bi

rng = random.Random(2)
ks = [4, 8, 16, 32, 64, 128, 256]
rates = []
for k in ks:
    sep = 0
    for _ in range(20000):
        h = [rng.uniform(-10, 10) for _ in range(k)]
        m = [rng.uniform(-10, 10) for _ in range(k)]
        i_star = argmin_index(h, m)
        j = rng.choice([i for i in range(k) if i != i_star])
        mp = list(m); mp[j] += rng.uniform(0.1, 5.0)
        hp = [rng.uniform(-10, 10) for _ in range(k)]
        if tsha(hp, mp) != tsha(hp, m):
            sep += 1
    rates.append(sep / 20000)

plt.figure(figsize=(6, 5))
plt.loglog(ks, rates, "o-", label="measured separation rate")
plt.loglog(ks, [1.0 / k for k in ks], "r--", label="1/k reference")
plt.xlabel("message length k")
plt.ylabel("separation rate")
plt.title("Two-key separation decays like 1/k")
plt.legend()
plt.tight_layout()
plt.savefig("separation_decay.png", dpi=150)
print("saved separation_decay.png")
