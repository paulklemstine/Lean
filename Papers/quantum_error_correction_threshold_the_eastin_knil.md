# Computational Evidence

## 1. Eastin–Knill obstruction (finiteness vs. density)

The structural core of Eastin–Knill: the group of *transversal* logical gates of a
quantum code is **finite** (it is built from a finite set of single-qubit operators
acting block-wise), whereas a **universal** gate set generates a **dense** subgroup
of the (infinite, connected) logical unitary group. A finite subset of an infinite
T1 topological space is closed, so if it were dense it would equal the whole space —
contradiction. Hence finite ⇒ not universal.

Concrete sanity checks:

* Roots of unity in the circle group `Circle`. The `m`-th roots of unity form a
  finite cyclic subgroup of order `m`. For every finite `m` the set of `m`-th roots
  is *not* dense in the circle (its closure is itself, a finite set ≠ circle).
* Pauli operators on `n` qubits: `|Pauli^n| = 4^n` (catalog `pauli_total_count`).
  Finite for every `n`, hence its image in any infinite unitary group is never dense.

## 2. Threshold recursion (concatenated fault tolerance)

One level of code concatenation maps logical error rate `p ↦ c·p²` (two faults must
combine to cause a logical fault). Iterate `f₀ = p₀`, `f_{k+1} = c·f_k²`.

Set `g_k = c·f_k`. Then `g_{k+1} = (g_k)²`, so `g_k = (c·p₀)^{2^k}` exactly, i.e.

```
f_k = (1/c) · (c·p₀)^{2^k}.
```

Numerical iteration with `c = 100` (threshold `p_th = 1/c = 0.01 = 1%`):

| level k | p₀ = 0.005 (below) | p₀ = 0.01 (at)  | p₀ = 0.02 (above) |
|--------:|-------------------:|----------------:|------------------:|
| 0       | 5.0e-3             | 1.0e-2          | 2.0e-2            |
| 1       | 2.5e-3             | 1.0e-2          | 4.0e-2            |
| 2       | 6.25e-4            | 1.0e-2          | 1.6e-1            |
| 3       | 3.9e-5             | 1.0e-2          | 2.56e0            |
| 4       | 1.5e-7             | 1.0e-2          | diverges          |

* Below `p_th`: doubly-exponential decay to 0.
* At `p_th = 1/c`: exact fixed point (constant `1/c`).
* Above `p_th`: divergence.

This pins the model threshold at exactly `1/c`; choosing the phenomenological surface-code
constant `c = 100` reproduces the well-known "≈ 1%" surface-code threshold.
