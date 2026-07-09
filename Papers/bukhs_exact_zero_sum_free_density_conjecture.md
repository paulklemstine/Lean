# Computational Evidence

Context: Bukh's zero-sum-free density problem. Let `m_d` be the supremum of the
normalized surface measure `σ_{d-1}(A)` over measurable **zero-sum-free** sets
`A ⊆ S^{d-1}` (no nonempty finite family of points of `A` sums to `0`). The
conjecture is `m_d = 1/2` for all `d ≥ 3`. The formalized results here establish the
*lower bound* `m_d ≥ 1/2` (an open hemisphere is zero-sum-free and has measure exactly
`1/2`); the matching upper bound `m_d ≤ 1/2` is open.

## 1. The extremal construction: the open hemisphere

Fix a unit vector `v` and take `H_v = {x ∈ S^{d-1} : ⟨x, v⟩ > 0}`.

* **Zero-sum-free.** For any points `x_1, …, x_n ∈ H_v` (`n ≥ 1`),
  `⟨x_1 + … + x_n, v⟩ = Σ ⟨x_i, v⟩ > 0`, so the sum is nonzero. Hence `H_v` is
  zero-sum-free. (This is `isZeroSumFree_of_inner_pos` / `exists_zeroSumFree_half_measure`.)
* **Measure exactly 1/2.** The antipodal map `x ↦ -x` is measure preserving, maps `H_v`
  onto `H_{-v}`, and `S^{d-1}` is the disjoint union `H_v ⊔ H_{-v} ⊔ E` where the equator
  `E = {⟨x,v⟩ = 0}` is null. Hence `σ(H_v) = σ(H_{-v})` and `2 σ(H_v) = 1`, i.e.
  `σ(H_v) = 1/2`. (This is `hemisphere_toSphere_eq_half`.)

So `m_d ≥ 1/2` for every `d ≥ 1`, with equality achieved by hemispheres. Numerically the
hemisphere measure is `1/2` in **every** dimension — there is no dependence on `d`, which
is exactly what makes `1/2` the natural conjectured value.

## 2. Small cases / sanity checks (`S^1`, `d = 2`)

Represent points of the circle by angles `θ ∈ [0, 2π)`, `x_θ = (cos θ, sin θ)`.

* Open semicircle `{θ ∈ (0, π)}` (i.e. `H_v` for `v = (0,1)`): length `π`, normalized
  measure `π / (2π) = 1/2`. Any finite sum of such points has strictly positive
  `y`-coordinate, hence is nonzero — zero-sum-free, as predicted.
* **Counterexample hunt for going past 1/2.** Three unit vectors at angles
  `0, 2π/3, 4π/3` sum to `0`. Any arc of length `> π` contains three points mutually
  `≥ 2π/3` apart, producing a zero sum. So no *arc* longer than a semicircle is
  zero-sum-free — consistent with `m_2 = 1/2` and with hemispheres being extremal.
  (More elaborate non-arc sets are what make the exact upper bound genuinely hard.)

## 3. Sequence / OEIS

The conjectured value is the constant `m_d = 1/2` for all `d ≥ 3`; there is no
integer sequence to look up. The paper's upper bound `m_d ≤ 1/2 + O(1/d)` shows the
constant sequence `1/2, 1/2, …` is approached from above but is not (yet) known to be
attained as an upper bound.

## Conclusion

The computational picture supports the formalized theorems: the open hemisphere is a
zero-sum-free set of normalized measure exactly `1/2` in every dimension, giving
`m_d ≥ 1/2`, and small-case experiments on `S^1` show hemispheres are extremal among
arcs. The exact upper bound `m_d ≤ 1/2` remains open and is not claimed here.
