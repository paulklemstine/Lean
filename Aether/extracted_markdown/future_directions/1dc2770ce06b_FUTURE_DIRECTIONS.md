# Future Directions — Self-dual codes ↔ smooth 4-manifold intersection forms

This cycle added `SelfDualCardinality.lean`, isolating the *evenness-free* structural
invariant of a binary self-dual code:

* `selfDual_card_sq`   : `|C|² = 2ⁿ`   (master cardinality identity, any self-dual code)
* `selfDual_length_even`: `2 ∣ n`       (every self-dual code has even length)
* `selfDual_card`      : `|C| = 2^(n/2)` (the dimension is exactly `n/2`)

These sit *below* the doubly-even refinements (`4 ∣ n` in `SelfDualLength`, `8 ∣ n` in
`GleasonLength`), giving the layered tower
`self-dual ⟹ 2 ∣ n`  ⊂  `doubly-even self-dual ⟹ 8 ∣ n`,
the code-side mirror of `unimodular` ⊂ `even unimodular ⟹ rank divisible by 8`.

Below are bold, testable conjectures for follow-up cycles.

## Conjecture 1 — Concatenation is the connected sum of codes (mirror of `DirectSum.lean`)

For codes `C ⊆ (ZMod 2)ᵐ`, `D ⊆ (ZMod 2)ⁿ`, define the direct sum
`C ⊕ D ⊆ (ZMod 2)^(m+n)` by coordinate concatenation. Then:

* `C ⊕ D` is self-dual iff both `C` and `D` are;
* `|C ⊕ D| = |C| · |D|`, so `selfDual_card` gives `2^((m+n)/2) = 2^(m/2)·2^(n/2)`;
* double-evenness is preserved (`wt` is additive across the split);
* minimum distance: `d(C ⊕ D) = min (d C) (d D)`.

This is the exact coding-theory shadow of `IntersectionForm.directSum_unimodular` /
`directSum_isEven` and of the connected sum `M # N`. **Testable:** formalize `⊕` on
`Finset (Fin (m+n) → ZMod 2)` via `finSumFinEquiv` and prove the four closure facts;
instantiate on `hamming ⊕ hamming` (length 16) as the code shadow of `E8 ⊕ E8`.

## Conjecture 2 — MacWilliams invariance: a self-dual code's weight enumerator is a fixed point

Let `W_C(X,Y) = ∑_{c∈C} X^{n - wt c} Y^{wt c}`. The MacWilliams identity says
`W_{C^⊥}(X,Y) = |C|⁻¹ · W_C(X+Y, X−Y)`. **Conjecture:** for a self-dual `C` (so
`C = C^⊥`), `W_C` is invariant under `(X,Y) ↦ ((X+Y)/√2, (X−Y)/√2)`; for a *doubly-even*
self-dual `C` it is additionally invariant under `Y ↦ iY`, hence (Gleason) a polynomial
in `W_{[8,4,4]}(X,Y) = X⁸ + 14X⁴Y⁴ + Y⁸` and `(X⁴Y⁴(X⁴−Y⁴)⁴)`.
**Testable:** prove the two-variable MacWilliams identity from the already-established
`char_orthogonality` + `fourier_iwt` machinery (the Fourier transform of `bchar` is
exactly the substitution `X±Y`), then verify the `1 + 14x⁴ + x⁸` enumerator of `hamming`
is a fixed point of the order-8 substitution by `native_decide`.

## Conjecture 3 — Gleason's distance bound `d ≤ 4⌊n/24⌋ + 4`

A doubly-even self-dual code of length `n` has minimum distance
`d ≤ 4⌊n/24⌋ + 4`. For `n = 8` this gives `d ≤ 4`, attained by `hamming`
(`MinimumDistance.hamming_minDist_attained`); the first "extremal" case is `n = 24`
(the binary Golay code, the code shadow of the Leech lattice).
**Testable:** the `n ≤ 22` window of the bound (`d ≤ 4`) follows from the supported
weights `{0,4,8,…}` and the cardinality `2^(n/2)` of this cycle; formalize
`d ≤ 4 → ` weight-distribution constraints and check the Golay parameters `[24,12,8]`
by `native_decide` on an explicit generator matrix.

## Conjecture 4 — Counting self-dual codes (Gauss-binomial mass)

The number `N(n)` of binary self-dual codes of (even) length `n` equals
`∏_{i=1}^{n/2 − 1} (2^i + 1)`. E.g. `N(2)=1, N(4)=2, N(6)=4, N(8)=2·4·8+? ` (the
product `(2+1)(4+1)(8+1) = 135` for `n=8`).
**Testable:** the upper structural input is `selfDual_card` (`|C| = 2^(n/2)`), so each
self-dual code is a maximal isotropic subspace of the standard symmetric `ZMod 2`-form;
enumerate maximal isotropics for `n = 2,4,6` by `decide`/`native_decide` and match the
product formula, then conjecture the general recursion `N(n+2) = (2^{(n)/2}+1)·N(n)`.

## Conjecture 5 — Lattice ↔ code refinement: shadow theta vs. weight enumerator

Construction A maps a doubly-even self-dual code `C` of length `n` to an even unimodular
lattice `Λ_C` of rank `n`, whose theta series' leading coefficients are governed by the
weight enumerator `W_C`. **Conjecture:** the `8 ∣ n` of `GleasonLength` and the rank
divisibility `8 ∣ rank` of `IntersectionForms.E8form` are *the same theorem* under
Construction A — i.e. there is a weight-preserving bijection between minimal vectors of
`Λ_C` and minimum-weight codewords of `C`. **Testable:** formalize Construction A on
`ZMod 2`-codes valued in the lattice `ℤⁿ`, prove `Λ_hamming ≅ E8` by matching Gram
matrices (both rank 8, even, unimodular, det 1), giving a *bridge theorem* tying
`hamming_doublyEven`/`hamming_card` directly to `E8_even`/`E8_unimodular`.
