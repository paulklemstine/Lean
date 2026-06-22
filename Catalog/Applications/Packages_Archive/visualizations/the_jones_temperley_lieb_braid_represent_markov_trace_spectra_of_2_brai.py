"""
Visualization: the Markov-trace spectrum of powers of a Jones operator.

For the parameter A = e^{i*theta}, the loop value is delta = -2*cos(2*theta),
and the trace of jonesOp(A, e)^k (the closure of the 2-braid sigma_0^k) traces
out a curve in the complex plane as k varies. This plot draws those trace values
for several theta, illustrating how the Markov trace encodes the braid.
"""

from __future__ import annotations

import cmath
from typing import List

import matplotlib.pyplot as plt

Matrix = List[List[complex]]


def loop_value(A: complex) -> complex:
    return -(A ** 2 + A ** (-2))


def jones_op_e(A: complex) -> Matrix:
    d = loop_value(A)
    e: Matrix = [[d, 0j], [1.0 + 0j, 0j]]
    return [[A + A ** -1 * e[0][0], A ** -1 * e[0][1]],
            [A ** -1 * e[1][0], A + A ** -1 * e[1][1]]]


def matmul(P: Matrix, Q: Matrix) -> Matrix:
    return [[sum(P[i][t] * Q[t][j] for t in range(2)) for j in range(2)]
            for i in range(2)]


def trace(P: Matrix) -> complex:
    return P[0][0] + P[1][1]


def main() -> None:
    fig, ax = plt.subplots(figsize=(7, 7))
    for m in range(2, 8):
        A = cmath.exp(1j * cmath.pi / m)
        S = jones_op_e(A)
        pow_k = [[1.0 + 0j, 0j], [0j, 1.0 + 0j]]
        xs, ys = [], []
        for _ in range(1, 16):
            pow_k = matmul(pow_k, S)
            t = trace(pow_k)
            xs.append(t.real)
            ys.append(t.imag)
        ax.plot(xs, ys, "o-", markersize=3, label=f"A = exp(i*pi/{m})")
    ax.axhline(0, color="gray", lw=0.5)
    ax.axvline(0, color="gray", lw=0.5)
    ax.set_xlabel("Re tr(sigma^k)")
    ax.set_ylabel("Im tr(sigma^k)")
    ax.set_title("Markov-trace spectra of 2-braid powers")
    ax.legend(fontsize=8)
    ax.set_aspect("equal")
    plt.tight_layout()
    plt.savefig("markov_trace_spectrum.png", dpi=150)
    print("Saved markov_trace_spectrum.png")


if __name__ == "__main__":
    main()
