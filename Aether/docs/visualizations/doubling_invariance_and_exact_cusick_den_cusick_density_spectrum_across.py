import matplotlib.pyplot as plt

def s2(n: int) -> int:
    return bin(n).count('1')

def density(t: int, N_bits: int = 13) -> float:
    N = 2 ** N_bits
    return sum(1 for n in range(N) if s2(n) <= s2(n + t)) / N

ts = list(range(1, 65))
ds = [density(t) for t in ts]
colors = [s2(t) for t in ts]
plt.figure(figsize=(12, 5))
sc = plt.bar(ts, ds, color=plt.cm.viridis([c / max(colors) for c in colors]))
plt.axhline(0.75, color='red', ls='--', lw=1, label='3/4 (powers of two)')
plt.axhline(0.5, color='black', ls=':', lw=1, label='1/2 (unbiased)')
plt.xlabel('shift t')
plt.ylabel('density c_t')
plt.title('Cusick density c_t (color = s2(t))')
plt.legend()
plt.tight_layout()
plt.savefig('cusick_density_spectrum.png', dpi=150)
print('saved cusick_density_spectrum.png')
