"""Visualization: population vs. catalog counts (log-log-scale bars)."""
import numpy as np
import matplotlib.pyplot as plt

# log10 of population A^L and of catalog count 2^(A^L) for small A,L.
As, Ls = [2, 3, 4], [4, 6, 8]
labels, log_pop, log_cat = [], [], []
for A in As:
    for L in Ls:
        pop = A ** L
        labels.append(f"A={A},L={L}")
        log_pop.append(np.log10(pop))
        log_cat.append(pop * np.log10(2))  # log10(2^pop)
x = np.arange(len(labels))
plt.bar(x - 0.2, log_pop, 0.4, label="log10(volumes A^L)")
plt.bar(x + 0.2, np.log10(log_cat), 0.4, label="log10(log10(catalogs))")
plt.xticks(x, labels, rotation=45, ha="right")
plt.ylabel("log-scale magnitude")
plt.title("Catalogs (2^(A^L)) dwarf volumes (A^L): A^L < 2^(A^L)")
plt.legend(); plt.tight_layout(); plt.savefig("viz_catalog.png", dpi=150)
print("saved viz_catalog.png")
