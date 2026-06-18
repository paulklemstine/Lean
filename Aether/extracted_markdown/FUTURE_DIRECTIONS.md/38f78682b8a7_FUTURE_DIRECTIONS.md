# Future Directions — Reading the Two Invariants of the Gauss-Sum Master Identity

## Synthesis

The previous cycle distilled the entire arithmetic of doubly-even self-dual binary
codes into a single complex equation, the **master identity**
(`GleasonLength.card_eq_onePlusI_pow`):

> `(|C| : ℂ) = (1 + I)ⁿ`.

That identity is a complex number, and a complex number carries *two* independent
invariants: its **argument** and its **modulus**. The length theorem
`doublyEven_selfDual_length_div_eight` (`8 ∣ n`) was nothing but the *argument* —
the period-8 phase of `1 + I` landing on the positive real axis.

This cycle harvests the **modulus**. Because `|1 + I| = √2`, the same identity forces
`|C| = (√2)ⁿ`, and once `8 ∣ n` is known this collapses to an exact natural-number
equation. The new file `GleasonCardinality.lean` proves, fully `sorry`-free and for
arbitrary length `n`:

> **`doublyEven_selfDual_card`** — a binary doubly-even self-dual code of length `n`
> has exactly `2^(n/2)` codewords.

This is the code-side avatar of "an even unimodular lattice has covolume 1": the
cardinality is pinned to the canonical self-dual value, leaving no room for a code of
the wrong size. The two endpoints of the master identity are now both theorems:
the phase gives the length obstruction `8 ∣ n`, the modulus gives the dimension
`|C| = 2^(n/2)`. The `[8,4,4]` parameters are recovered *from the general theorems*:
`n = 8` (Gleason length), and `k = log₂|C| = log₂ 16 = 4` (the dimension theorem at
length 8, `doublyEven_selfDual_card_length_eight`).

## Results Summary

* `doublyEven_selfDual_card` — main result: `|C| = 2^(n/2)` for every doubly-even
  self-dual binary code, arbitrary `n`; axioms `propext / Classical.choice / Quot.sound`.
* `card_eq_sixteen_pow_complex` — the modulus-collapse `(|C| : ℂ) = 16^(n/8)`, the
  intermediate "real form" of the master identity once `8 ∣ n` is in hand; reusable
  whenever the complex Gauss sum must be brought back to ℕ.
* `doublyEven_selfDual_card_length_eight` — at length `8`, `|C| = 16`; pins the
  dimension `k = 4` of the `[8,4,4]` parameters from the general theorem.
* `hamming_card_via_gleason` — recovers `hamming.card = 16` from the general dimension
  theorem rather than by enumeration, the cardinality twin of `hamming_length_div_eight`.
* `gleasonLengthClass_eq_zero` — exposes the `ℤ/8`-valued Gauss-sum phase as a named
  invariant (Research Direction 5 of the prior cycle) and proves it vanishes.

Together with the prior cycle, the catalog now knows, for any doubly-even self-dual
binary code: its **length** is `≡ 0 (mod 8)` and its **size** is exactly `2^(n/2)` — the
two coordinates (argument, modulus) of one Gauss sum.

## Research Directions

### 1. MacWilliams self-duality of dimension: `|C| · |C⊥| = 2ⁿ` as a bridge, not a coincidence

`doublyEven_selfDual_card` gives `|C| = 2^(n/2)` *only* through the Gauss sum, which
secretly used double-evenness. The structural reason a self-dual code has size `2^(n/2)`
is the dimension formula `|C| · |C⊥| = 2ⁿ` together with `C = C⊥`. Promote this to a Lean
theorem for *arbitrary* linear binary codes and recover `doublyEven_selfDual_card` as the
self-dual special case, *dropping the double-even hypothesis*.
**The key insight is** that `|C| = 2^(n/2)` is a statement about the *argument-free* part
of the master identity, so it must survive when `I^{wt}` is replaced by the trivial
character — i.e. it is a theorem of linear algebra over `ZMod 2`, and the Gauss-sum proof
is an unnecessarily strong route to a purely dimensional fact.
**Why now?** The modulus computation `(|C| : ℂ) = 16^(n/8)` is already isolated in
`card_eq_sixteen_pow_complex`; comparing it against the elementary `Module.finrank` /
orthogonal-complement dimension count in Mathlib turns the analytic proof into a clean
duality theorem and quantifies exactly how much of the result needs double-evenness.

### 2. Sharpness at length 8 via the now-forced cardinality

`doublyEven_selfDual_card_length_eight` proves any length-8 doubly-even self-dual code has
*exactly* 16 codewords. Combined with `MinimumDistance.lean`'s weight enumerator
`1 + 14x⁴ + x⁸`, conjecture that the code is *unique* up to coordinate permutation, i.e.
monomially equivalent to the extended Hamming code.
**The key insight is** that the cardinality is no longer an assumption but a *theorem*:
the search space of candidate length-8 codes is now a finite set of 16-element subspaces
of `(ZMod 2)⁸` whose weight spectrum is forced to `{0⁽¹⁾, 4⁽¹⁴⁾, 8⁽¹⁾}`, which should
collapse to a single orbit under `decide`/`native_decide` over generator matrices.
**Why now?** Both constraints that cut the search down — exact size 16 and the fixed
spectrum — are formalized in this cycle and in `MinimumDistance.lean`; the classification
is now a bounded finite check rather than an open-ended construction.

### 3. The `ℤ/8` phase and the `ℤ/2` modulus as a complete invariant pair

`gleasonLengthClass_eq_zero` names the phase; `doublyEven_selfDual_card` names the
modulus. Conjecture that the *ordered pair* (phase class in `ℤ/8`, `log₂|C| − n/2 ∈ ℤ`)
is a complete obstruction: a finite binary code is doubly-even self-dual **iff** both
invariants vanish *and* it is linear and self-orthogonal.
**The key insight is** that the master identity is an *equivalence* of complex numbers,
so its two coordinates should jointly characterize membership in the class, not merely be
necessary conditions — the Gauss sum is invertible by Fourier inversion
(`fourier_iwt` is already the forward transform).
**Why now?** The forward MacWilliams transform `fourier_iwt` and character orthogonality
`char_orthogonality` are formalized; Fourier inversion over `(ZMod 2)ⁿ` is the missing
half, and proving it would convert the two named invariants from necessary to sufficient.

### 4. Construction A transporting `2^(n/2)` to the lattice covolume

`doublyEven_selfDual_card` is the discrete shadow of "even unimodular ⟹ covolume 1".
Define Construction A `L(C) = {v ∈ ℤⁿ : v mod 2 ∈ C}/√2` and prove that the *index*
`[ℤⁿ : preimage] = 2^(n − dim C)` together with the `1/√2` scaling makes `det L(C) = 1`
exactly when `|C| = 2^(n/2)`.
**The key insight is** that the lattice covolume is `2^(n/2 − dim C) · (√2)^{...}`, a
single exponential whose vanishing exponent is *literally* the equation
`dim C = n/2` proved here — so the covolume-1 miracle on the lattice side *is*
`doublyEven_selfDual_card` after taking determinants.
**Why now?** The code-side cardinality is now an exact theorem and `IntersectionForms`
already supplies `E8form` unimodularity on the lattice side; only the determinant
bookkeeping of Construction A stands between the two as a genuine functor.

### 5. Length 16: a cardinality-blind separation of `E8⊕E8` from `D16⁺`

Both `E8 ⊕ E8` and `D16⁺` reduce mod 2 to length-16 doubly-even self-dual codes, so
`doublyEven_selfDual_card` forces *both* to have exactly `2⁸ = 256` codewords, and
Gleason's structure theorem forces *both* weight enumerators to the same polynomial.
Conjecture the two codes are nonetheless inequivalent, witnessed by their automorphism
group orders.
**The key insight is** that cardinality and weight enumerator — the two invariants this
cycle and the last made exact — are provably *equal* for the two codes, so any separation
must come from a strictly finer invariant; this makes length 16 the minimal catalog
example where "same size, same spectrum, different code" is a theorem rather than a hope.
**Why now?** `DirectSum.lean` already proves `E8E8form` is not standard-diagonalizable
(a concrete second example distinct from the orthogonal lattice), and the size/spectrum
invariants are now pinned, so the inequivalence is the first sharp test that the coarse
invariants are genuinely insufficient.
