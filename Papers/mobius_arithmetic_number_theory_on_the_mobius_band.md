# Computational evidence — Möbius arithmetic

All numbers below were produced with `#eval` inside the project's Lean
toolchain (Lean 4.28.0 / Mathlib).  They are *evidence*, not proof; every claim
that survived was subsequently proved in `Catalog/NumberTheory/MobiusIntegers/`
with zero `sorry`s.  Where a computation contradicted the mission's conjecture,
the corresponding Lean file records the refutation instead.

## Lab notes

### Experiment 1 — factorisations of `6` into two oriented primes

Enumerating all pairs `(a,b)` of prime integers with `-7 ≤ a,b ≤ 7` and
`a·b = 6` (recall `Z̃ ≅ ℤ` as a ring, `Mobius.MInt.equivZ`):

```
[(-3, -2), (-2, -3), (2, 3), (3, 2)]
```

Exactly four ordered factorisations, i.e. two unordered ones, `2⁺·3⁺` and
`2⁻·3⁻`.  They are *distinct as oriented data* but *associate*
(`2⁻ = (-1)·2⁺`).  Proved: `Mobius.MInt.six_factorizations`,
`Mobius.MInt.six_factorizations_distinct`,
`Mobius.MInt.six_factorizations_associated`.

**Verdict.** The mission's "two distinct factorisations" test passes only in the
oriented-tuple sense; it is *not* a failure of unique factorisation.

### Experiment 2 — the lattice count on the band

`#{x ∈ Z̃ : |x| ≤ N}` for `N = 0,…,5`:

```
[1, 3, 5, 7, 9, 11]      i.e.  2N + 1
```

Two oriented points per positive radius, one ramification point at the centre.
Proved: `Mobius.MInt.card_norm_le`, `Mobius.MInt.norm_fiber_card`,
`Mobius.MInt.norm_fiber_zero`.

### Experiment 3 — the oriented divisor function

`(#{d ∈ Z̃ : d ∣ n}, 2·τ(n))` for `n = 1,…,12`:

```
[(2,2), (4,4), (4,4), (6,6), (4,4), (8,8), (4,4), (8,8), (6,6), (8,8), (4,4), (12,12)]
```

Perfect agreement: `τ̃ = 2τ`.  Proved: `Mobius.MInt.divisors_ncard`.
(The sequence `2τ(n)` is A062011 in the OEIS; `τ(n)` itself is A000005.)

### Experiment 4 — the Möbius zeta function at `s = 2`

Partial sum `∑_{1 ≤ n ≤ 2000} 2/n²` against `π²/3 = 2·ζ(2)`:

```
(3.288868, 3.289868)
```

Agreement to `10⁻³`, consistent with the tail `2/N ≈ 10⁻³`.  Proved:
`Mobius.MInt.zetaTilde_eq_tsum` (`ζ̃(s) = 2ζ(s)` on `Re s > 1`).

**Counterexample hunt.** The same computation kills the conjecture that a double
cover should *square* the zeta function: `ζ(2)² = π⁴/36 ≈ 2.7058 ≠ 3.2899`.
Proved: `Mobius.MInt.zetaTilde_ne_zeta_sq`.

### Experiment 5 — is the orientation visible to the ring structure?

Every class `{(n,+1), (−n,−1)}` is determined by the single integer `ε·n`, and
the arithmetic prescribed by the mission ("addition wraps through the
identification") is exactly integer arithmetic on that invariant.  A direct
`#eval` check on `6 = 2⁺·3⁺ = 2⁻·3⁻` returns `(6, 6, 6)`.  This is the origin of
the structure theorem `Mobius.MInt.equivZ : Z̃ ≃+* ℤ`, which in turn forces
class number one and refutes both the "non-Ore" and the "spectral double cover"
conjectures.

---

## Lab notes, cycles 2–5 (the oriented double `O = ℤ[τ]/(τ²−1)`)

Cycle 1 showed that a *set-level* identification cannot twist anything, so the
next cycles moved the twist into the multiplication and worked with

```
O = ℤ[τ]/(τ² − 1) ≅ {(u,v) ∈ ℤ × ℤ : u ≡ v (mod 2)},   τ = (1,−1).
```

All figures below are `#eval` outputs on this model.

### Experiment 6 — the oriented unit group

Units of `O` inside the box `|u|,|v| ≤ 6`:

```
[(-1, -1), (-1, 1), (1, -1), (1, 1)]        4 elements
```

so `O^× = {±1, ±τ} ≅ (ℤ/2)²`, strictly larger than `Z̃^× = {±1}`.  Proved:
`Mobius.OInt.isUnit_iff`, `Mobius.OInt.units_ncard`.

### Experiment 7 — residue rings: splitting versus ramification

Size of the image of `O ∩ {|u|,|v| ≤ 14}` under `x ↦ (u mod p, v mod p)`,
compared with `p²`:

```
p = 3, 5, 7   →   (9, 9), (25, 25), (49, 49)
```

The pair-reduction is onto for odd `p`, i.e. `O/pO ≅ 𝔽_p × 𝔽_p` and `p` splits
into two points.  Proved: `Mobius.OInt.redPair_surjective`,
`Mobius.OInt.quotientEquivProd`, `Mobius.OInt.fiberOver_ncard_odd`.

At `p = 2` the two reductions agree on all of `O`:

```
∀ x ∈ O ∩ {|u|,|v| ≤ 12},  (2 ∣ u) ↔ (2 ∣ v)   →   true
```

and the element `τ − 1 = (0,−2)` satisfies

```
(0,−2) ∈ 2·O  →  false          (0,4) = (τ−1)² ∈ 2·O  →  true
```

so the residue ring at `2` contains a nonzero nilpotent: the cover is branched
exactly at `2`.  Proved: `Mobius.OInt.primeAt_eq_two`,
`Mobius.OInt.tau_sub_one_nilpotent_mod_two`, `Mobius.OInt.fiberOver_ncard_two`.

### Experiment 8 — the lattice count of the oriented double

`#(O ∩ {|u|,|v| ≤ N})` for `N = 1,…,5` against `2N² + 2N + 1`:

```
[5, 13, 25, 41, 61]   vs   [5, 13, 25, 41, 61]
```

Perfect agreement — the density of `O` in `ℤ × ℤ` is `1/2`, matching the
conductor computation `(ℤ × ℤ)/O ≅ ℤ/2` (`Mobius.OInt.conductorQuotientEquiv`).
This is the two-dimensional analogue of the `2N + 1` count of Experiment 2.  It
*suggests* (this part is not proved) that the Dirichlet series of `O` grows like
`ζ(s)²` rather than `2ζ(s)`; what is proved is the local statement that every
odd prime has two points above it (Experiment 7).

### Experiment 9 — multiplicities in oriented zeta functions

For a norm whose nonzero fibres all have `k` elements the Dirichlet series is
`k·ζ`.  Checked numerically for `k = 2` in Experiment 4 (`3.288868` vs
`3.289868`); the general statement is now a theorem for all `k ≥ 1`
(`Mobius.tsum_kFoldNorm`), together with the sharpness example
`N : ℕ × Fin k → ℕ` (`Mobius.exists_kFoldNorm`).  Consequence: no such cover
can move a zero (`Mobius.kFoldRiemannHypothesis_iff`).

### Experiment 10 — the Dirichlet coefficients of the oriented double

Conjecture 6 predicted `ζ_O(s) = ζ(s)²·(1 − 2^{-s})`.  Expanding the right-hand
side gives coefficients `c(n) = d(n) − d(n/2)` (with `d(n/2) = 0` for odd `n`):

```
n     1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24
c(n)  1  1  2  1  2  2  2  1  3  2  2  2  2  2  4  1  2  3  2  2  4  2  2  2
```

Two features are visible and both are now theorems: `c(p) = 2` for odd primes
(`Mobius.OInt.idealCoeff_odd_prime`) and `c(2^k) = 1` at the branch prime
(`Mobius.OInt.idealCoeff_two_pow`).  The first twelve values are checked by the
kernel in `Mobius.OInt.idealCoeff_table`, the non-negativity of all of them in
`Mobius.OInt.idealCoeff_nonneg`, and the Dirichlet expansion itself in
`Mobius.OInt.spectralZeta_eq_tsum`.  The counting interpretation is proved at
prime index: the number of ideals of `O` of index `p` is exactly `c(p)`
(`Mobius.OInt.card_idealsOfIndex_eq_idealCoeff`).

### Experiment 11 — numerical test of Conjecture 6

Partial sums `∑_{n≤5000} c(n)·n^{-s}` against the predicted closed forms:

```
s = 2:   2.028220   vs   π⁴/48        = 2.029356
s = 3:   1.264323   vs   ζ(3)²·(7/8)  = 1.264323
```

Both agree to the accuracy of the truncation, and the value at `s = 2` is
sharply different from the Möbius value `ζ̃(2) = π²/3 = 3.289868` of
Experiment 4.  Proved: `Mobius.OInt.spectralZeta_eq`,
`Mobius.OInt.spectralZeta_two`, `Mobius.OInt.spectralZeta_two_ne_zetaTilde_two`.

### Experiment 12 — where the new zeros are

The ramified factor `1 − 2^{-s}` vanishes exactly on the imaginary axis, at the
points `s = 2πik/log 2`; the first is

```
s₀ = (2π/log 2)·i ≈ 9.064720·i
```

so `ζ_O` acquires a whole periodic family of zeros with `re s = 0` that `ζ` does
not have.  Proved: `Mobius.OInt.one_sub_two_cpow_periodPoint` (the zero),
`Mobius.OInt.riemannZeta_periodPoint_ne_zero` (it is not a zero of `ζ`),
`Mobius.OInt.not_orientedRiemannHypothesis` (so the naive oriented Riemann
hypothesis fails), and `Mobius.OInt.orientedRH_strip_iff` (inside the critical
strip nothing changes).
