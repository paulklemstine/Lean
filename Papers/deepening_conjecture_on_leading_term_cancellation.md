# Computational Evidence — Leading-term cancellation: moments and dimension

This note records the small-case exploration that guided the two deepenings of
the leading `1/N` heat-kernel cancellation theory:

* the **moment spectrum** characterisation, and
* the **dimension formula** for the cancellation space.

Throughout, `L(t) = ∑ᵢ dᵢ · e^{-t Eᵢ}` is the leading correction, `Eᵢ` the
unperturbed energy levels, `dᵢ` the first-order diagonal shifts, and
`sᵥ = ∑_{i : Eᵢ = v} dᵢ` the aggregate shift of the level with energy `v`.

## 1. Small-case calculations

### Two levels, degenerate `E = (a, a)`
- Distinct levels: 1 (only value `a`).
- Cancellation condition: single equation `d₀ + d₁ = 0`.
- Solution space: the line `{(c, -c)}` — dimension `2 − 1 = 1`.
- Moments: `mₖ = d₀ aᵏ + d₁ aᵏ = (d₀ + d₁) aᵏ`, so *all* moments vanish iff
  `d₀ + d₁ = 0`, exactly matching `L ≡ 0`.

### Two levels, distinct `E = (0, 1)`
- Distinct levels: 2.
- `m₀ = d₀ + d₁`, `m₁ = d₁`. Both vanish ⇒ `d = 0`.
- Solution space: `{0}` — dimension `2 − 2 = 0`.
- Consistency check: with `d = (1, -1)`, `L(t) = 1 − e^{-t}`, nonzero at `t = 1`.

### Three levels, one repeat `E = (a, a, b)` with `a ≠ b`
- Distinct levels: 2.
- Constraints: `s_a = d₀ + d₁ = 0` and `s_b = d₂ = 0`.
- Solution space: `{(c, -c, 0)}` — dimension `3 − 2 = 1`.

### Three levels, all equal `E = (a, a, a)`
- Distinct levels: 1.
- Constraint: `d₀ + d₁ + d₂ = 0` — a plane, dimension `3 − 1 = 2`.

In every case the observed dimension equals `n − (number of distinct levels)`,
and the vanishing of *all* power-sum moments coincides exactly with `L ≡ 0`.

## 2. Pattern extraction

Two invariants emerge and were subsequently proved:

1. **Moment spectrum.** `L ≡ 0 ⟺ mₖ = ∑ᵢ dᵢ Eᵢᵏ = 0` for every `k`. Both sides
   pivot on `all level sums sᵥ = 0`, since `mₖ = ∑ᵥ vᵏ sᵥ` and the exponential
   samples `L(k) = ∑ᵥ (e^{-v})ᵏ sᵥ`; distinct `v` make each Vandermonde system
   invertible, so both conditions collapse to the same one.

2. **Dimension.** The cancellation set is the kernel of the linear
   *level-aggregation map* `d ↦ (sᵥ)ᵥ`. That map is surjective (spread any
   target across a nonempty fibre), so rank–nullity gives
   `dim ker = n − #{distinct levels}`.

## 3. Counterexample hunt

- **Is `L ≡ 0` equivalent to term-by-term vanishing `dᵢ = 0`?** No: the
  degenerate doublet `E = (a,a)`, `d = (c,-c)` is a standing counterexample
  (already recorded in the base theory). This is why the sharp statements are
  phrased through level sums / moments, not individual coefficients.
- **Could the dimension exceed `n − #levels`?** Tested on all cases above; never.
  The bound is tight because the level-aggregation map is surjective.
- **Does the moment equivalence need infinitely many `k`?** Finitely many
  (`k < #levels`) already suffice by Vandermonde; the theorem is stated for all
  `k` for cleanliness, and the reverse direction genuinely uses Vandermonde
  nonsingularity, so it is not a triviality.

## 4. Conclusion

The computational landscape is fully consistent with — and motivated — both
formal results. No counterexamples were found; the degenerate doublet marks the
precise boundary of naive term-by-term intuition, and the dimension count is
governed entirely by the pattern of spectral degeneracies.
