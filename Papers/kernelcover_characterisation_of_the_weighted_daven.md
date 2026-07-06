# Computational Evidence — Kernel-cover characterisation of the weighted Davenport constant

## Setup

For abelian groups `F`, `G` and a weight set `Ψ` of homomorphisms `F →+ G`, a
length-`n` choice `φ : {1,…,n} → Ψ ∪ {0}` induces the *universal homomorphism*
`Φ_φ : F^n → G`, `Φ_φ(x) = Σ φ_i(x_i)`. The weighted Davenport bound `D_Ψ(G) ≤ n`
is modelled as: the kernels of the *valid* induced homomorphisms (those with at
least one nonzero coordinate) cover `F^n`.

## 1. Small-case calculations: `F = G = ℤ/m`, `Ψ = {id}`

Here the kernel-cover condition at level `n` unfolds to the classical Davenport
condition: *every length-`n` sequence has a nonempty zero-sum subsequence.*

| m | sequences that fail at length m−1 | zero-sum guaranteed at length | D(ℤ/m) |
|---|-----------------------------------|-------------------------------|--------|
| 2 | (1)                               | 2                             | 2      |
| 3 | (1,1)                             | 3                             | 3      |
| 4 | (1,1,1)                           | 4                             | 4      |
| 5 | (1,1,1,1)                         | 5                             | 5      |

* Length `m−1` witness of failure: the constant sequence `(1,…,1)`. Every
  nonempty subset `S` sums to `|S|` with `0 < |S| ≤ m−1 < m`, hence `≠ 0` in
  `ℤ/m`.
* Length `m` always succeeds: the `m+1` partial sums `s_0,…,s_m ∈ ℤ/m` cannot be
  distinct (pigeonhole), and an equal pair `s_i = s_j` yields a zero-sum block.

Pattern: `D(ℤ/m) = m`. This matches OEIS A000027 (the natural numbers) as the
Davenport constant of the cyclic group `C_m`.

## 2. Monotonicity check

With the `0`-weight allowed as a "skip", the cover property is monotone in `n`:
if `(ℤ/m)^{m}` is covered, so is `(ℤ/m)^{m+1}` (pad the witnessing choice with a
`0`). Verified abstractly (`kernelCover_succ`). **Counter-observation:** without
the `0`-weight/skip mechanism (forcing *every* coordinate to be a genuine
weight) monotonicity FAILS — e.g. `(x, 0, …, 0)` with `x` a unit of `ℤ/p`
admits no full-tuple weighted zero-sum. This is why the subsequence model
(`insert 0 Ψ` with a genuine-nonzero clause) is the mathematically correct
encoding of the Davenport constant.

## 3. Counterexample hunt for the main characterisation

The characterisation `KernelCover Ψ n ↔ (⋃_φ ker Φ_φ = F^n)` was stress-tested
by trying to separate the two sides: the only subtlety is the "valid" clause
(some coordinate nonzero). Dropping it makes both sides *vacuously true* (the
all-`0` choice has kernel `F^n`), so it must be retained. No counterexample to
the guarded statement was found; it is proved in `Core.lean`
(`kernelCover_iff_iUnion_ker`).

## Conclusion

The kernel-cover reformulation is faithful, monotone (with the skip model), and
recovers the classical `D(ℤ/m) = m` on the cyclic base case. These facts are
formalised with 0 sorries in `Core.lean` and `CyclicDavenport.lean`.
