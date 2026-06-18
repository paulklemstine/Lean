# Tropical Weight Enumerator Profiles for Binary Linear Codes via Smooth Poincaré Primitives

## Abstract

The Hamming weight enumerator `W_C(x, y) = Σ_{c ∈ C} x^{n − wt(c)} y^{wt(c)}` of a
binary linear code is multiplicative under the direct sum (coordinate concatenation)
of codes: `W_{C ⊕ D} = W_C · W_D`. We study the *min-plus tropicalization* of this
invariant, in which the generating sum becomes a minimum and the product becomes a
sum. The resulting object, the **tropical weight enumerator**
`twe_C(t) = min_{c ∈ C} (wt(c) · t)`, is a concave, piecewise-linear function of a
single real parameter whose slopes are the codeword weights. Our main theorem is the
**tropical additivity law** `twe_{C ⊕ D} = twe_C + twe_D`, the exact min-plus mirror of
classical multiplicativity, proved for arbitrary block lengths and all real slopes with
no sign hypothesis. We further show that the **minimum distance** is itself a tropical
quantity, obeying the tropical-addition (`min`) law `d_{C ⊕ D} = min(d_C, d_D)` under
direct sum, yielding a complete "tropical dictionary" for the concatenation operation.
Finally, instantiating on the extended Hamming `[8, 4, 4]` code — the mod-2 shadow of
the `E₈` lattice — we exhibit a precise *information-loss* phenomenon:
`twe_Hamming(t) = min(0, 8t)`, so the minimum-distance stratum at weight `4` is
invisible to the tropical enumerator because `4` is not a vertex of the lower convex
hull of the weight spectrum `{0, 4, 8}`. This gives a concrete, geometric reason why the
minimum distance must be recorded as a separate invariant.

**Keywords.** binary linear code, weight enumerator, tropical semiring, min-plus
algebra, direct sum, minimum distance, convex hull, extended Hamming code, self-dual
code.

---

## 1. Introduction

The weight enumerator is the central generating function of coding theory. For a binary
linear code `C ⊆ 𝔽₂ⁿ`, it packages the entire weight distribution into a single
two-variable polynomial and governs duality (MacWilliams identity), error probability,
and the deep invariant theory of self-dual codes (Gleason's theorem). Its single most
load-bearing structural property — used implicitly whenever codes are built by
concatenation — is *multiplicativity under direct sum*:
`W_{C ⊕ D} = W_C · W_D`.

Tropical (min-plus) mathematics replaces the field operations `(+, ×)` of the reals by
`(min, +)`. This deformation turns generating-function sums into minima and products
into sums, and converts polynomial identities into piecewise-linear ones. It is the
algebraic engine behind shortest-path dynamic programming, scheduling, and a large
swath of modern tropical geometry. Applying it to the weight enumerator produces a
one-parameter, piecewise-linear *profile* of a code whose breakpoints and slopes encode
weight data in convex-geometric form.

This paper develops that tropical shadow on top of the catalog's `SmoothPoincare` code
primitives — the binary self-dual codes that arise as mod-2 reductions of even
unimodular lattices under Construction A — and proves three results:

1. **Tropical additivity** (Theorem 4.2): `twe_{C ⊕ D} = twe_C + twe_D`.
2. **Minimum distance as a tropical-min invariant** (Theorem 5.3):
   `d_{C ⊕ D} = min(d_C, d_D)`.
3. **Information loss on Hamming** (Theorem 6.2): `twe_Hamming(t) = min(0, 8t)`, with
   the weight-`4` stratum erased because it is not a hull vertex.

All results are stated for arbitrary block lengths; the proofs rest only on the
additivity of Hamming weight under concatenation, `wt(a ++ b) = wt(a) + wt(b)`.

---

## 2. Preliminaries and notation

Throughout, `n, m ∈ ℕ`, and a *binary vector of length `n`* is a function
`v : Fin n → ℤ/2ℤ`. A **code** is a finite set `C` of binary vectors (we work with
arbitrary nonempty finite sets; linearity is used only where stated).

**Definition 2.1 (Hamming weight).** The weight of a binary vector `v : Fin n → ℤ/2ℤ`
is the number of nonzero coordinates,
`wt(v) = |{ i : v(i) = 1 }|`.

**Definition 2.2 (Binary inner product).** For `x, y : Fin n → ℤ/2ℤ`,
`⟨x, y⟩ = Σ_i x(i) · y(i) ∈ ℤ/2ℤ`.

**Definition 2.3 (Self-dual code).** A code `C` is *self-dual* if
`x ∈ C ⟺ (∀ y ∈ C, ⟨x, y⟩ = 0)`. A vector `v` is *doubly even* if `4 ∣ wt(v)`.

**Definition 2.4 (Direct sum / concatenation).** For codes `C ⊆ (Fin m → ℤ/2ℤ)` and
`D ⊆ (Fin n → ℤ/2ℤ)`, their direct sum is
`C ⊕ D = { a ++ b : a ∈ C, b ∈ D } ⊆ (Fin (m + n) → ℤ/2ℤ)`,
where `a ++ b` denotes the concatenation `Fin.append a b` whose first `m` coordinates
are `a` and last `n` are `b`.

**Definition 2.5 (Classical weight enumerator).** For a code `C` of length `n`,
`W_C(x, y) = Σ_{c ∈ C} x^{n − wt(c)} y^{wt(c)} ∈ ℤ[x, y]`.

We recall the foundational facts established on the `SmoothPoincare` code primitives,
which our development takes as input.

**Lemma 2.6 (Weight additivity).** For all `a : Fin m → ℤ/2ℤ` and `b : Fin n → ℤ/2ℤ`,
`wt(a ++ b) = wt(a) + wt(b)`.

*Proof.* The support of `a ++ b` is the disjoint union of the support of `a`
(coordinates `0, …, m − 1`) and the support of `b` (coordinates `m, …, m + n − 1`);
counting via `Fin.sum_univ_add` gives additivity. ∎

**Lemma 2.7 (Block-diagonal inner product).** For `a, c : Fin m → ℤ/2ℤ` and
`b, d : Fin n → ℤ/2ℤ`,
`⟨a ++ b, c ++ d⟩ = ⟨a, c⟩ + ⟨b, d⟩`.

**Lemma 2.8 (Cardinality / membership).** The concatenation map
`(a, b) ↦ a ++ b` is injective on `C × D`, so `|C ⊕ D| = |C| · |D|`; and
`z ∈ C ⊕ D ⟺ ∃ a ∈ C, ∃ b ∈ D, z = a ++ b`.

**Corollary 2.9 (Classical multiplicativity).** `W_{C ⊕ D} = W_C · W_D`.

*Proof.* Expand the product: every term `x^{m − wt(a)} y^{wt(a)} · x^{n − wt(b)} y^{wt(b)}`
equals `x^{(m+n) − wt(a++b)} y^{wt(a++b)}` by Lemmas 2.6 and 2.8, and the bijection
`C × D ≅ C ⊕ D` matches the terms. ∎

Corollary 2.9 is the classical statement that we will tropicalize.

---

## 3. The tropical semiring and tropicalization

**Definition 3.1 (Min-plus semiring).** The *tropical semiring* is
`(ℝ ∪ {+∞}, ⊕, ⊗)` with `a ⊕ b = min(a, b)` (additive operation, identity `+∞`) and
`a ⊗ b = a + b` (multiplicative operation, identity `0`). It is an idempotent,
commutative semiring.

Tropicalization replaces, in a generating function, each sum `Σ` by a tropical sum
`min` and each product/exponent by a tropical product `+`. Concretely, a monomial
`x^{n − wt(c)} y^{wt(c)}` is tropicalized by the substitution recording only the weight
through a single scalar slope: the monomial of (tropical) weight `wt(c)` evaluated at a
slope `t` contributes `wt(c) · t`. Summation over codewords becomes minimization.

**Definition 3.2 (Tropical weight enumerator).** For a nonempty code `C` of length `n`
and `t ∈ ℝ`,
`twe_C(t) = min_{c ∈ C} (wt(c) · t)`.

As a function of `t`, `twe_C` is the lower envelope of the finite family of lines
`{ t ↦ w · t : w ∈ spec(C) }`, where `spec(C) = { wt(c) : c ∈ C }` is the **weight
spectrum**. It is therefore concave and piecewise linear, with slopes drawn from
`spec(C)`. (Formally `twe_C(t) = C.inf'(c ↦ wt(c) · t)` over the nonempty finite set
`C`.)

We record three immediate structural facts.

**Lemma 3.3 (Lower bound).** For every `c ∈ C`, `twe_C(t) ≤ wt(c) · t`.

**Lemma 3.4 (Attainment).** There exists `c ∈ C` with `twe_C(t) = wt(c) · t`.

**Lemma 3.5 (Certificate).** If `b ≤ wt(c) · t` for all `c ∈ C`, then `b ≤ twe_C(t)`.

These are exactly the defining properties of an infimum over a nonempty finite set:
3.3 is `inf' ≤`, 3.4 is attainment of the infimum, and 3.5 is the universal property
`le_inf'`. They are the only tools needed for the additivity theorem.

---

## 4. Main theorem: tropical additivity under direct sum

**Lemma 4.1 (Nonemptiness).** If `C` and `D` are nonempty, so is `C ⊕ D`.

*Proof.* The image of the nonempty product `C × D` under concatenation is nonempty. ∎

**Theorem 4.2 (Tropical additivity).** For nonempty codes `C ⊆ (Fin m → ℤ/2ℤ)`,
`D ⊆ (Fin n → ℤ/2ℤ)`, and *every* `t ∈ ℝ`,
`twe_{C ⊕ D}(t) = twe_C(t) + twe_D(t)`.

*Proof.* We prove the two inequalities.

(`≤`) By attainment (Lemma 3.4) choose `a ∈ C` with `twe_C(t) = wt(a) · t` and `b ∈ D`
with `twe_D(t) = wt(b) · t`. Then `a ++ b ∈ C ⊕ D`, and by weight additivity
(Lemma 2.6),
`twe_{C⊕D}(t) ≤ wt(a ++ b) · t = (wt(a) + wt(b)) · t = wt(a)·t + wt(b)·t
= twe_C(t) + twe_D(t)`,
using the lower-bound property (Lemma 3.3) for the first step.

(`≥`) Apply the certificate (Lemma 3.5): it suffices to show
`twe_C(t) + twe_D(t) ≤ wt(z) · t` for every `z ∈ C ⊕ D`. Write `z = a ++ b` with
`a ∈ C`, `b ∈ D` (Lemma 2.8). Then
`wt(z) · t = (wt(a) + wt(b)) · t = wt(a)·t + wt(b)·t ≥ twe_C(t) + twe_D(t)`,
where each summand is bounded below by Lemma 3.3.

Combining the two inequalities by antisymmetry gives equality. ∎

**Remark 4.3 (No sign hypothesis).** The identity holds for all real `t`, positive,
negative, or zero. The reason is independence of the two blocks: the minimization over
the left block and the minimization over the right block decouple completely, so
`min_{a, b}(f(a) + g(b)) = (min_a f(a)) + (min_b g(b))`
holds unconditionally. This decoupling is the tropical fingerprint of the classical
factorization `W_{C ⊕ D} = W_C · W_D` (Corollary 2.9): multiplicativity of independent
generating functions becomes additivity of independent lower envelopes.

**The tropical dictionary.** Theorem 4.2 completes a uniform translation of the
direct-sum laws:

| Classical invariant     | Direct-sum law      | Tropical reading        |
|-------------------------|---------------------|-------------------------|
| length `n`              | `n_C + n_D`         | additive                |
| cardinality `|C|`       | `|C| · |D|`         | log-additive            |
| weight enumerator `W_C` | `W_C · W_D`         | `twe` additive (Thm 4.2)|
| minimum distance `d`    | `min(d_C, d_D)`     | tropical `min` (Thm 5.3)|

---

## 5. The minimum distance as a tropical-min invariant

**Definition 5.1 (Minimum distance).** For a code `C` whose set of nonzero codewords
`C ∖ {0}` is nonempty,
`d(C) = min_{c ∈ C, c ≠ 0} wt(c)`.
Formally `d(C) = (C.erase 0).inf'(wt)`.

We record its universal properties, the integer analogues of Lemmas 3.3 and 3.5.

**Lemma 5.2.** (i) For every nonzero `c ∈ C`, `d(C) ≤ wt(c)`. (ii) If `b ≤ wt(c)` for
every nonzero `c ∈ C`, then `b ≤ d(C)`.

**Theorem 5.3 (Distance is tropical-additive).** Let `C, D` be codes each containing
the zero vector, with at least one nonzero codeword between them. Then
`d(C ⊕ D) = min(d(C), d(D))`.

*Proof sketch.* (`≤`) A minimal nonzero codeword of `C` concatenated with the zero
vector of `D` (or vice versa) is a nonzero codeword of `C ⊕ D` of weight `d(C)`
(resp. `d(D)`); by Lemma 5.2(i) and weight additivity (Lemma 2.6),
`d(C ⊕ D) ≤ wt(a ++ 0) = wt(a) = d(C)`, and symmetrically `≤ d(D)`, hence
`d(C ⊕ D) ≤ min(d(C), d(D))`. (`≥`) Any nonzero `z = a ++ b ∈ C ⊕ D` has at least one
nonzero block; say `a ≠ 0`. Then `wt(z) = wt(a) + wt(b) ≥ wt(a) ≥ d(C) ≥ min(d(C), d(D))`
(and symmetrically if `b ≠ 0`). By Lemma 5.2(ii), `min(d(C), d(D)) ≤ d(C ⊕ D)`. ∎

**Interpretation.** Minimum distance is *intrinsically* tropical: it is defined as a
minimum of weights, and under direct sum it obeys the tropical-addition law `min`.
This is exactly the bottom row of the dictionary. The engineering moral — that the
shortest nonzero codeword of a concatenation lives entirely in one block, so the weaker
factor determines the distance — is the combinatorial content of the proof.

---

## 6. The Hamming code and the information-loss phenomenon

The catalog's extended Hamming code is the image of the encoder of the Reed–Muller code
`RM(1, 3)`.

**Definition 6.1.** With generator rows
`g₀ = 11111111`, `g₁ = 00001111`, `g₂ = 00110011`, `g₃ = 01010101`,
the **extended Hamming code** is `Hamming = { Σᵢ aᵢ gᵢ : a ∈ (ℤ/2ℤ)⁴ } ⊆ (ℤ/2ℤ)⁸`.

It is a `[8, 4, 4]` self-dual doubly-even code. Its classical weight enumerator is
`W_Hamming(x, y) = x⁸ + 14 x⁴ y⁴ + y⁸`, established by direct enumeration of the `16`
codewords: there are `1`, `14`, `1` codewords of weights `0`, `4`, `8` respectively
(`1 + 14 + 1 = 16`). Its weight spectrum is therefore `spec(Hamming) = {0, 4, 8}`, and
its minimum distance is `d(Hamming) = 4`.

**Theorem 6.2 (Tropical enumerator of Hamming).** For all `t ∈ ℝ`,
`twe_Hamming(t) = min(0, 8t)`.

*Proof sketch.* `twe_Hamming(t) = min_{c} wt(c) · t = min(0·t, 4·t, 8·t)
= min(0, 4t, 8t)`, the minimum over the three slopes that occur. For `t ≥ 0` the smallest
is `0`; for `t ≤ 0` the smallest is `8t` (since `8t ≤ 4t ≤ 0`). In both regimes `4t` is
sandwiched, `min(0, 4t, 8t) = min(0, 8t)`. Hence the weight-`4` line never wins. ∎

**Theorem 6.3 (Hull characterization of surviving slopes).** A weight `w ∈ spec(C)`
appears as a slope of `twe_C` on a set of `t` of positive measure if and only if `w` is
a vertex of the lower convex hull of the spectrum `spec(C)` (viewed as points on the
real line, with the two extreme weights `min` and `max` always vertices). Equivalently,
the line `t ↦ w · t` is the strict minimum of `{ t ↦ w' · t : w' ∈ spec(C) }` for some
`t` iff `w ∈ {min spec(C), max spec(C)}`.

*Proof sketch.* The family `{w' · t}` is a set of lines through the origin. For `t > 0`
the minimum is achieved by the smallest weight; for `t < 0` by the largest; at `t = 0`
all coincide at `0`. No intermediate weight is ever the unique minimizer. Thus only the
extreme weights of the spectrum survive — and for a one-dimensional point set those are
exactly the hull vertices. ∎

**Corollary 6.4 (Information loss).** `twe` records only the convex hull of the weight
spectrum; for codes whose minimum distance is strictly between `0` and the maximal
weight, the minimum distance is *invisible* to `twe`. For `Hamming`, the interior point
`4` of the segment `[0, 8]` is erased, even though it is the code's minimum distance.

**Interpretation.** Corollary 6.4 is the precise statement of how much tropicalization
forgets, and a concrete justification that the minimum-distance invariant `d(C)` is
*not* redundant with the tropical enumerator. The classical enumerator distinguishes
codes by their full spectrum (with multiplicities); the tropical enumerator collapses to
the hull; the minimum distance recovers the single most important *interior* feature the
hull misses. Three invariants, three complementary resolutions of the same weight data.

**Stability under gluing.** Since `d(Hamming) = 4` and, by Theorem 5.3,
`d(Hamming ⊕ Hamming) = min(4, 4) = 4`, the length-`16` code `Hamming ⊕ Hamming` (the
mod-2 shadow of `E₈ ⊕ E₈`, with `256 = 16·16` codewords) keeps minimum distance `4`,
while by Theorem 4.2 its tropical enumerator is
`twe_{Hamming ⊕ Hamming}(t) = 2·min(0, 8t) = min(0, 16t)`.

---

## 7. Algorithms

We summarize the constructive content as three algorithms.

**Algorithm A (Tropical enumerator evaluation).** Given a code `C` (as a list of
codewords) and a slope `t`, compute `twe_C(t)` by evaluating `wt(c) · t` for each `c`
and returning the minimum. Complexity `O(|C| · n)` (weight computation dominates). With
precomputed weights it is `O(|C|)` per query.

**Algorithm B (Spectrum-to-hull profile).** Given the weight spectrum
`spec(C) = {w₁ < … < w_k}`, the function `twe_C` equals `t ↦ min_i w_i · t`, whose
graph is the lower envelope; by Theorem 6.3 only `w₁` (for `t ≥ 0`) and `w_k`
(for `t ≤ 0`) matter, so the profile is `t ↦ min(w₁ · t, w_k · t)`, computable in
`O(k)` time after sorting, `O(k log k)` from scratch.

**Algorithm C (Direct-sum profile composition).** Given the tropical profiles of `C`
and `D`, the profile of `C ⊕ D` is their pointwise sum (Theorem 4.2), and the distance
is `min(d(C), d(D))` (Theorem 5.3). This composes profiles of building-block codes into
the profile of a concatenated code in `O(1)` per evaluation point, without recomputing
over the exponentially large product code.

---

## 8. Applications

1. **Compositional code design.** When concatenating codes to hit a target length and
   rate, the tropical profile of the result is the sum of the building blocks' profiles
   and its distance is the min — a constant-time bookkeeping rule that avoids handling
   the exponentially large product code.

2. **Diagnostic for enumerator-equivalence.** Two codes with equal classical weight
   enumerators have equal tropical profiles, but the converse fails badly: any two codes
   with the same extreme weights share a tropical profile. The tropical profile is thus
   a fast, coarse invariant; a mismatch is a certificate of inequivalence computable
   without expanding the full spectrum.

3. **Convex-geometric reading of self-dual codes.** Gleason's theorem constrains the
   weight enumerators of self-dual codes; the tropical profile exposes the convex
   skeleton of the spectrum directly. Combined with the tropical-min law for distance
   (Theorem 5.3), this frames the Mallows–Sloane bound `d ≤ 4⌊n/24⌋ + 4` as a *global*
   (non-additive) obstruction — stacking `[8,4,4]` codes keeps `d = 4` while `n` grows.

---

## 9. Discussion

The contribution is conceptual economy: a single change of arithmetic (`+ ↦ min`,
`× ↦ +`) unifies two superficially unrelated direct-sum laws — multiplicativity of the
weight enumerator and the `min` law of minimum distance — as two faces of min-plus
additivity. Theorem 4.2 holds for all real slopes precisely because the blocks of a
concatenated code are independent, which is also why classical multiplicativity holds;
the tropical proof exposes this independence as the sole ingredient. The information-loss
result (Corollary 6.4) is the sharp counterweight: tropicalization is a lossy
projection onto the convex hull of the spectrum, and the minimum distance is exactly the
interior datum it discards. This makes precise, in convex-geometric language, why
distance and enumerator are independent invariants.

The development rests on a minimal foundation — only weight additivity under
concatenation and the universal properties of finite infima — so it transfers verbatim
to any setting with an additive weight under a product operation (e.g. non-binary linear
codes over `𝔽_q` with the obvious Hamming weight, or product codes).

---

## 10. Future directions

**Conjecture 1 (Tropical hull recovery).** For any nonempty binary code `C ⊆ 𝔽₂ⁿ`, the
slopes realized by `twe_C` are exactly the weights of `C` that are vertices of the lower
convex hull of the weight-multiplicity set `{(wt(c), 1) : c ∈ C}`. Equivalently, a
weight `w` present in `C` is realized as the minimizer of `twe_C(t)` for some `t` iff `w`
is a hull vertex. This makes precise exactly how much tropicalization forgets, with the
Hamming computation `twe_Hamming = min(0, 8t)` (spectrum `{0,4,8}`) a special case.
*First test:* the `[6, 3, ?]` shortened code and the repetition code `{0…0, 1…1}` (whose
hull is the full spectrum), checked against `Hamming`.

**Conjecture 2 (Tropical Gleason / Mallows–Sloane bound).** Every binary doubly-even
self-dual code of length `n` satisfies `d(C) ≤ 4⌊n/24⌋ + 4`. The tropical-min law
(Theorem 5.3) shows the right-hand side is not additive under direct sum — stacking two
`[8,4,4]` codes keeps `d = 4` — so the bound is a genuinely global obstruction, the
distance-side analogue of Gleason's length divisibility (length divisible by `8`).
*First test:* `n = 8` (Hamming, bound `= 4`, tight) and `n = 24` (extended Golay code,
bound `= 8`), checking tightness on the Golay spectrum.

**Further questions.** (a) A min-plus analogue of the MacWilliams identity relating
`twe_C` and `twe_{C^⊥}`; (b) tropical profiles over `𝔽_q` and their behaviour under the
`q`-ary product; (c) multiplicities: a refined "tropical enumerator with multiplicity"
recording how many codewords sit on each surviving hull facet, restoring some of the
information that Corollary 6.4 shows the plain profile discards.

---

## References

- F. J. MacWilliams and N. J. A. Sloane, *The Theory of Error-Correcting Codes*,
  North-Holland, 1977.
- J. H. Conway and N. J. A. Sloane, *Sphere Packings, Lattices and Groups*, Springer,
  3rd ed., 1999.
- D. Maclagan and B. Sturmfels, *Introduction to Tropical Geometry*, AMS, 2015.
- C. L. Mallows and N. J. A. Sloane, "An upper bound for self-dual codes,"
  *Information and Control*, 22 (1973), 188–200.
