import matplotlib.pyplot as plt

fig, ax = plt.subplots(figsize=(12, 5))
bases = [-3, -1, 0, 2, 5]
levels = list(range(16))
for base_chi in bases:
    chi_seq = [base_chi]
    for _ in range(15):
        chi_seq.append(2 - chi_seq[-1])
    ax.plot(levels, chi_seq, 'o-', label=f'χ₀ = {base_chi}', markersize=5)
ax.axhline(y=1, color='gray', linestyle=':', alpha=0.5)
ax.set_xlabel('Spectrum Level n')
ax.set_ylabel('χ(Xₙ)')
ax.set_title('Pro-Spectrum Euler Characteristic Periodicity')
ax.legend()
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('pro_spectrum.png', dpi=150)
plt.close()