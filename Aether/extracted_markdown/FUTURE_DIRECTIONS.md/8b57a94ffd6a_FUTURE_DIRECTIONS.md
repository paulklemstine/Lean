# Future Directions — The Gauss-Sum Bridge between Even Lattices and Binary Codes

## Synthesis

The `SmoothPoincare` family in `Catalog/Applications/SmoothPoincare/` builds the
smooth/topological gallery around one recurring miracle: *self-duality forces
divisibility*. On the lattice side, positive-definite even **unimodular** lattices exist
only in rank divisible by `8` (the `E8` story in `IntersectionForms`). On the code side,
`SelfDualLength.selfDual_doublyEven_length_div_four` proves the mod-`4` shadow — a
self-dual, doubly-even binary code has length divisible by `4` — by evaluating the dual
at the all-ones global section.

This cycle isolated the *structural engine* underneath that argument. The mod-`4` length
theorem silently assumes that doubly-even orthogonal vectors are **closed under addition**
— the coding analogue of "an even lattice stays even under the group law". In
`Homotopy/GaussSumBridge.lean` we made that closure a first-class, `sorry`-free theorem,
derived from a single polarization identity for Hamming weight:

```
wt (x + y) + 2 * overlap x y = wt x + wt y        -- wt_add_overlap
```

the binary mirror of `‖x+y‖² = ‖x‖² + ‖y‖² + 2⟨x,y⟩`. From it we obtained
`overlap_even_of_ip_zero` (orthogonality kills the cross term mod 2),
`doublyEven_add_of_ip_zero` (the linearity bridge), the global `code_doublyEven_closed`,
and an analytic crossing `gaussSum_doublyEven`: the degree-4 Gauss sum
`∑_{c∈C} i^{wt c}` collapses to `|C|` because double-evenness sends every weight into
`4ℤ`, where `i` is trivial.

## Results Summary

- `wt_add_overlap` — polarization identity for Hamming weight (additive form).
- `ip_eq_overlap` — the binary inner product is the parity of the integer overlap.
- `overlap_even_of_ip_zero` — orthogonality forces even overlap.
- `doublyEven_add_of_ip_zero` — **the linearity bridge** (headline).
- `code_doublyEven_closed` — global closure for self-orthogonal doubly-even codes.
- `gaussSum_doublyEven` — degree-4 Gauss-sum collapse `gaussSum C = |C|`.

All six are proved with only `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. The degree-8 Gauss sum and Gleason's `8 ∣ n`

The degree-4 Gauss sum is trivial *precisely because* `i` is constant on `4ℤ`. Replace
`i` by a primitive **8th** root of unity `ζ = exp(πi/4)`: now `ζ^{wt c} = ±1` records
`wt c mod 8`, so `gaussSum₈ C = #{c : 8 ∣ wt c} − #{c : wt c ≡ 4 (mod 8)}` becomes a real
integer. The falsifiable conjecture: for every self-dual doubly-even code,
`gaussSum₈ C = 2^{n/2}` and, separately, `8 ∣ n`. **The key insight is** that the gap
between the degree-4 and degree-8 Gauss sums is *exactly* the cross-term datum
`overlap mod 4`, which `wt_add_overlap` already exposes — so the missing step is purely
a MacWilliams/transform statement about `gaussSum₈` under the duality `C = C⊥`, not new
combinatorics. **Why now?** With `code_doublyEven_closed` proved, `C` is genuinely an
`F₂`-subspace, so `|C| = 2^{dim C}` and self-duality gives `dim C = n/2`; the cardinality
side of Gleason is finally available in this file's vocabulary.

### 2. Linearity ⟹ subspace ⟹ MacWilliams identity

`code_doublyEven_closed` shows a self-orthogonal doubly-even `Finset` code is closed
under `+`; it also contains `0` and is closed under negation (trivial in characteristic
2), hence is an `F₂`-subspace. Conjecture: any `Finset` code satisfying the closure
hypotheses of `code_doublyEven_closed` equals `(C : Submodule (ZMod 2) (Fin n → ZMod 2))`
as a set, and therefore satisfies the MacWilliams transform
`W_{C⊥}(x,y) = |C|^{-1} W_C(x+y, x−y)`. **The key insight is** that closure under addition
is the *only* axiom separating the project's `Finset`-based codes from Mathlib's
`Submodule`/linear-code API — once bridged, the entire weight-enumerator toolkit becomes
importable. **Why now?** This cycle proved exactly that closure, so the bridge is one
`Submodule.mk`-style lemma away rather than a from-scratch reformalization.

### 3. The overlap cocycle and a mod-4 weight homomorphism

Define `q(x) := wt x mod 4` and `b(x,y) := overlap x y mod 2`. The identity
`wt_add_overlap` says `q(x+y) = q(x) + q(y) − 2·overlap`, i.e. `q` is a **quadratic form**
whose associated bilinear form is `ip` (the mod-2 reduction of `overlap`). Conjecture: on
a doubly-even code, `q ≡ 0` and `b ≡ 0`, so `q` descends to the zero quadratic form, and
the obstruction to `q ≡ 0` on a merely *even* (mod-2) code is a well-defined Arf-invariant
class in `Z/2`. **The key insight is** that `overlap` is literally the polarization of the
weight quadratic form, so Arf-invariant theory applies verbatim to binary codes. **Why
now?** `wt_add_overlap` and `ip_eq_overlap` together give the quadratic-form/bilinear-form
pair in closed form, which is exactly the data an Arf-invariant computation consumes.

### 4. Length spectrum: which `n` admit self-dual doubly-even codes?

Combining `selfDual_doublyEven_length_div_four` with Direction 1's `8 ∣ n`, conjecture the
sharp existence statement: a self-dual doubly-even binary code of length `n` exists **iff**
`8 ∣ n`. The `[8,4,4]` extended Hamming code (already proved self-dual in
`SelfDualLength.hamming_selfDual`) is the `n = 8` witness; direct sums give all multiples
of 8. **The key insight is** that `code_doublyEven_closed` makes "direct sum of two codes"
a weight-additive, orthogonality-preserving operation, so existence for `n` and `m` yields
existence for `n+m` mechanically. **Why now?** The closure theorem turns the inductive step
(`8k → 8(k+1)`) into a one-line application rather than a hand verification, and the base
case is already in the catalog.

### 5. Homotopical reading: codes as `π₀` of a chain complex

Frame `(Fin n → ZMod 2, +)` as the 0-chains of a simplicial set with the all-ones vector
as a distinguished 1-cell; a self-orthogonal doubly-even code is then a sub-complex on
which the cup-square `Sq²` (the cohomology operation whose binary avatar is `wt mod 4`)
vanishes. Conjecture: `code_doublyEven_closed` is the statement that this sub-complex is a
*sub-`H`-space*, and the Gauss sum `gaussSum C` is its Euler characteristic twisted by `i`.
**The key insight is** that `wt mod 4` is the binary Pontryagin square, and polarization
(`wt_add_overlap`) is exactly the Cartan formula `Sq²(x+y) = Sq²x + Sq²y + x⌣y`. **Why
now?** With the polarization identity formalized, the Cartan-formula analogy is no longer
a slogan — it is a proved equation that a higher-categorical refinement can be tested
against.
