"""Visualization: joint support footprints of a signal and its transform.

Generates a two-panel stem plot showing |f(j)| in the time domain and
|f_hat(k)| in the frequency domain, annotating the support-size product
against the uncertainty bound N. Requires matplotlib and numpy.
"""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt

def dft(f: np.ndarray) -> np.ndarray:
    n = len(f)
    k = np.arange(n).reshape(-1, 1)
    j = np.arange(n).reshape(1, -1)
    W = np.exp(-2j*np.pi*k*j/n)
    return W @ f

def main() -> None:
    n = 12
    # subgroup indicator H_3 = {0,3,6,9}
    f = np.array([1.0 if j % 3 == 0 else 0.0 for j in range(n)], dtype=complex)
    fh = dft(f)
    st = int(np.sum(np.abs(f) > 1e-9))
    sh = int(np.sum(np.abs(fh) > 1e-9))
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4))
    ax1.stem(range(n), np.abs(f)); ax1.set_title(f"|f(j)|  (support {st})")
    ax1.set_xlabel("time j")
    ax2.stem(range(n), np.abs(fh)); ax2.set_title(f"|f_hat(k)|  (support {sh})")
    ax2.set_xlabel("frequency k")
    fig.suptitle(f"Support product {st}x{sh}={st*sh}  vs  N={n}  (equality: {st*sh==n})")
    fig.tight_layout()
    fig.savefig("support_footprints.png", dpi=140)
    print("wrote support_footprints.png")

if __name__ == "__main__":
    main()
