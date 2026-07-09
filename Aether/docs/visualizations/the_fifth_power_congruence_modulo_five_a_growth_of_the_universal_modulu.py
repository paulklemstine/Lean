import matplotlib.pyplot as plt

def is_prime(n):
    return n > 1 and all(n % d for d in range(2, int(n**0.5) + 1))

def universal_modulus(k):
    m = 1
    for p in range(2, k + 1):
        if is_prime(p) and (k - 1) % (p - 1) == 0:
            m *= p
    return m

ks = list(range(2, 26))
ms = [universal_modulus(k) for k in ks]
fig, ax = plt.subplots(figsize=(9, 5))
ax.bar(ks, ms, color="#2c7fb8")
for k, m in zip(ks, ms):
    ax.text(k, m, str(m), ha='center', va='bottom', fontsize=7)
ax.set_yscale('log')
ax.set_xlabel("exponent k")
ax.set_ylabel("universal modulus of a^k - a (log scale)")
ax.set_title("Sharp universal divisor of a^k - a; k=5 gives 30")
plt.tight_layout()
plt.savefig("universal_modulus.png", dpi=150)
print("saved universal_modulus.png")
