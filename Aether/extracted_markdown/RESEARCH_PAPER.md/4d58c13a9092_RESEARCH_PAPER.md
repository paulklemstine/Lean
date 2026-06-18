# Arithmetic-Height-Induced Ultrametrics: A Nonarchimedean Bridge from p-adic Depth to Categorical Ultrametric Objects

## Abstract

We develop a self-contained bridge connecting three domains: the arithmetic of p-adic valuation and divisibility depth, the metric geometry of ultrametric (strong-triangle) distances, and a categorical interface for ultrametric seminorm objects. We exhibit two complementary faces of a single nonarchimedean principle. **Face I** is a quantitative, real-valued metric on the rationals: the *arithmetic-height depth distance* `d(x, y) = |x − y|_p`, the p-adic norm of the difference. We prove it is a genuine ultrametric — it separates points, is symmetric, and satisfies the strong triangle inequality `d(x, z) ≤ max(d(x, y), d(y, z))`, with the ordinary triangle inequality as a corollary. **Face II** is a qualitative, discrete carrier on the integers: the prime-divisibility indicator `v(n) = [p ∤ n]`, which we prove is a multiplicative, ℕ-valued, ultrametric seminorm and therefore assembles into a valuation carrier and, through a reconstruction functor, into an ultrametric seminorm object whose norm is genuinely nonarchimedean. We give the indicator a residue-field representation: `v(n) = 1` iff the image of `n` in the finite field `ℤ/pℤ` is nonzero. Finally, we prove a **rigidity theorem** that unifies the two faces and explains the structural fork between them: on any field, a multiplicative ℕ-valued norm sending `1 ↦ 1` is identically `1` on nonzero elements. Quantitative depth therefore cannot be carried by a multiplicative integer norm over a field; it must reside either in a real-valued absolute value (Face I) or over a non-field carrier such as ℤ (Face II). All results are constructive and have been formally verified.

**Keywords.** p-adic valuation, ultrametric, strong triangle inequality, nonarchimedean norm, residue field, valuation carrier, categorical reconstruction, arithmetic height.

---

## 1. Introduction

The ordinary absolute value on the rational numbers is *archimedean*: repeatedly adding `1` to itself eventually exceeds any bound. For each prime `p`, however, there is a radically different size function — the **p-adic norm** — under which highly divisible numbers are small and the integer `1` is never exceeded by its own multiples. The p-adic norms, together with the ordinary absolute value, exhaust all nontrivial absolute values on ℚ up to equivalence (Ostrowski's theorem), and the completions they generate (the fields `ℚ_p`) are foundational objects of modern number theory.

This paper isolates and formalizes a compact, complete slice of this theory and threads it through a categorical interface for ultrametric objects. Our goals are threefold:

1. **Quantitative geometry.** Show that the difference-norm `d(x, y) = |x − y|_p` is a bona fide ultrametric on ℚ, with all metric axioms and the strong triangle inequality proved from the valuation's nonarchimedean property.

2. **Categorical packaging.** Identify a *discrete* incarnation of the same idea — the divisibility indicator on ℤ — that satisfies the algebraic axioms of a multiplicative ℕ-valued ultrametric seminorm, package it as a valuation carrier, and reconstruct it as an ultrametric seminorm object via a functorial construction.

3. **A unifying obstruction.** Prove a rigidity theorem on fields explaining *why* the quantitative face must be real-valued while the categorical face must live over a non-field.

We state every definition, theorem, lemma, and proof sketch inline so that the development is fully self-contained.

---

## 2. Background and Definitions

### 2.1 p-adic valuation, depth, and norm

Fix a prime `p`.

**Definition 2.1 (Valuation / depth).** For a nonzero integer `n`, the *p-adic valuation* (or *depth*) `v_p(n)` is the exponent of the highest power of `p` dividing `n`; equivalently the multiplicity of `p` in the prime factorization of `n`. It extends to nonzero rationals `x = a/b` by `v_p(a/b) = v_p(a) − v_p(b)`, and one sets `v_p(0) = +∞`. The valuation is well-defined (independent of the representation of the fraction) and satisfies, for all nonzero `x, y`:

- `v_p(xy) = v_p(x) + v_p(y)`  (additivity over products);
- `v_p(x + y) ≥ min(v_p(x), v_p(y))`  (the nonarchimedean inequality).

**Definition 2.2 (p-adic norm).** The *p-adic norm* is

> `|x|_p = p^(−v_p(x))` for `x ≠ 0`,  and  `|0|_p = 0`.

It is an absolute value: `|x|_p ≥ 0`, `|x|_p = 0 ⇔ x = 0`, `|xy|_p = |x|_p · |y|_p`, and crucially the **strong (ultrametric)** inequality

> `|x + y|_p ≤ max(|x|_p, |y|_p)`,

which is the multiplicative translation of `v_p(x + y) ≥ min(v_p(x), v_p(y))` (a larger valuation means a smaller norm, and `min` of exponents becomes `max` of norms). We freely use these standard facts about `|·|_p` as our analytic input.

### 2.2 The categorical interface

We target an abstract interface for ultrametric objects with the following data.

**Definition 2.3 (Ultrametric seminorm object).** An *ultrametric seminorm object* consists of a carrier type `α` with binary operations `add_op`, `mul_op`, a negation `neg_op`, a distinguished `zero_val`, a subtraction satisfying `sub_op x y = add_op x (neg_op y)`, and a *norm* `‖·‖ : α → ℕ` subject to:

- `‖zero_val‖ = 0`;
- `‖neg_op x‖ = ‖x‖`;
- `‖mul_op x y‖ = ‖x‖ · ‖y‖`  (multiplicativity);
- `‖add_op x y‖ ≤ max(‖x‖, ‖y‖)`  (strong triangle).

**Definition 2.4 (Tropical valuation carrier).** A *tropical valuation carrier* is the same package of operations together with `one_val` and a *valuation* `val : K → ℕ` satisfying `val_zero`, `val_neg`, `val_mul` (multiplicative), and `val_add` (`val(add_op x y) ≤ max(val x, val y)`). The codomain ℕ is chosen for clean arithmetic and direct computational constants.

**Definition 2.5 (Reconstruction functor).** The *valuation reconstruction* sends a tropical valuation carrier to the ultrametric seminorm object with the same operations and with norm literally equal to the carrier's valuation: `‖·‖ := val`. The four object axioms are exactly the four carrier axioms, so the construction is immediate. This is the functorial bridge from valuation data to ultrametric geometry.

---

## 3. Face I — The Arithmetic-Height Depth Distance on ℚ

We measure distance by the p-adic norm of the difference.

**Definition 3.1 (Depth distance).** For `x, y ∈ ℚ`,

> `d(x, y) := |x − y|_p`.

Numerically `d(x, y) = p^(−v_p(x − y))`, the reciprocal prime-power of the arithmetic depth of the difference: the more deeply `p` divides `x − y`, the closer `x` and `y` are.

**Theorem 3.2 (Nonnegativity).** `0 ≤ d(x, y)` for all `x, y`.
*Proof sketch.* Immediate from `|·|_p ≥ 0` applied to `x − y`. ∎

**Theorem 3.3 (Reflexivity).** `d(x, x) = 0`.
*Proof sketch.* `x − x = 0` and `|0|_p = 0`. ∎

**Theorem 3.4 (Identity of indiscernibles).** `d(x, y) = 0 ⇔ x = y`.
*Proof sketch.* The p-adic norm vanishes exactly at `0`, so `|x − y|_p = 0 ⇔ x − y = 0 ⇔ x = y`. The forward and backward directions chain `abv_eq_zero` for `|·|_p` with `sub_eq_zero`. ∎

**Theorem 3.5 (Symmetry).** `d(x, y) = d(y, x)`.
*Proof sketch.* `x − y = −(y − x)`, and the p-adic norm is invariant under negation (`|−t|_p = |t|_p`, since negation does not change valuation). Hence the two distances agree. ∎

**Theorem 3.6 (Strong / ultrametric triangle inequality).**

> `d(x, z) ≤ max(d(x, y), d(y, z))`.

*Proof sketch.* Write the telescoping identity `x − z = (x − y) + (y − z)`. Apply the nonarchimedean inequality for the p-adic norm to the two summands:

> `|x − z|_p = |(x − y) + (y − z)|_p ≤ max(|x − y|_p, |y − z|_p)`,

which is exactly the claim. The entire content is the single algebraic rewrite plus the valuation's nonarchimedean property. ∎

**Theorem 3.7 (Ordinary triangle inequality).** `d(x, z) ≤ d(x, y) + d(y, z)`.
*Proof sketch.* From Theorem 3.6, `d(x, z) ≤ max(d(x, y), d(y, z))`. Since both arguments are nonnegative (Theorem 3.2), the maximum is at most the sum: `max(a, b) ≤ a + b` whenever `a, b ≥ 0`. Chain the two inequalities. ∎

**Corollary 3.8.** `(ℚ, d)` is an ultrametric space; in particular it is a metric space. Its metric completion is the field of p-adic numbers `ℚ_p`.

Two features deserve emphasis. First, the strong triangle inequality is *strictly stronger* than the usual one and forces the characteristic ultrametric phenomena: all triangles are isosceles (the two largest sides are equal), every point of a ball is a center, and any two balls are nested or disjoint. Second, the quantitative information — *how* close two numbers are — is faithfully recorded because `|·|_p` is real-valued (in fact ℚ-valued through prime powers); Section 5 shows why this real-valuedness is unavoidable.

---

## 4. Face II — The Discrete Divisibility Depth on ℤ

The categorical carrier requires a *multiplicative* ℕ-valued norm. On a field this is impossible to make nontrivial (Section 5), so we descend to the integers, where p-adic valuations are nonnegative and Euclid's lemma is available.

**Definition 4.1 (Divisibility indicator).** For `n ∈ ℤ`,

> `v(n) := [ p ∤ n ] = (if p | n then 0 else 1)`.

The "deep" integers (multiples of `p`) receive `0`; the p-adic units (integers coprime to `p`) receive `1`. This is the Boolean coarsening of the full valuation: it records *whether* `p` divides `n`, discarding *how many times*.

**Lemma 4.2 (Grounding).** `v(0) = 0`.
*Proof sketch.* `p | 0`, so the indicator returns `0`. ∎

**Lemma 4.3 (Sign invariance).** `v(−n) = v(n)`.
*Proof sketch.* `p | (−n) ⇔ p | n`, so the conditional yields the same value. ∎

**Lemma 4.4 (Multiplicativity).** `v(m · n) = v(m) · v(n)`.
*Proof sketch.* Case on divisibility of `m` and `n`. If `p | m` or `p | n`, then `p | mn`, so `v(mn) = 0` and the product `v(m)·v(n)` also contains a `0` factor; both sides are `0`. If `p ∤ m` and `p ∤ n`, then by **Euclid's lemma** (prime `p` divides a product only if it divides a factor) `p ∤ mn`, so `v(mn) = 1 = 1 · 1`. Casting divisibility to nonvanishing in `ℤ/pℤ` discharges every branch uniformly. Primality is essential here: for composite moduli multiplicativity fails. ∎

**Lemma 4.5 (Strong triangle).** `v(m + n) ≤ max(v(m), v(n))`.
*Proof sketch.* Case on divisibility of `m` and `n`. The only way the inequality could fail is `v(m + n) = 1` with `max(v(m), v(n)) = 0`, i.e. `p ∤ (m + n)` while `p | m` and `p | n`. But `p | m` and `p | n` force `p | (m + n)` (closure of the ideal `(p)` under addition), contradicting `p ∤ (m + n)`. In all other branches the right-hand side is `1`, which dominates any `{0,1}` value. ∎

**Theorem 4.6 (Residue-field representation).** `v(n) = 1 ⇔ (n mod p) ≠ 0` in the residue field `ℤ/pℤ`.
*Proof sketch.* Unfolding, `v(n) = 1 ⇔ p ∤ n`, and the standard equivalence `(n : ℤ/pℤ) = 0 ⇔ p | n` converts this to `(n mod p) ≠ 0`. ∎

Theorem 4.6 is the "Gelfand-style" reading: the divisibility depth is the indicator of *nonvanishing at the prime `p`*, i.e. evaluation of the integer in the residue field followed by the nonzero test. It is the arithmetic analogue of probing a function by its value at a point and asking whether it vanishes there.

**Construction 4.7 (Arithmetic depth carrier).** Assemble a tropical valuation carrier `arithDepthCarrier(p)` with:

- carrier `K = ℤ`;
- `add_op = (+)`, `neg_op = (−)`, `mul_op = (·)`, `zero_val = 0`, `one_val = 1`, `sub_op = (−)`, with `sub_def x y = (x − y = x + (−y))` by ring arithmetic;
- valuation `val = v`.

The carrier axioms are exactly Lemmas 4.2–4.5: `val_zero = `Lemma 4.2, `val_neg = `Lemma 4.3, `val_mul = `Lemma 4.4, `val_add = `Lemma 4.5.

**Theorem 4.8 (Bridge / object instantiation).** Applying the reconstruction functor (Definition 2.5) to `arithDepthCarrier(p)` yields an ultrametric seminorm object on ℤ whose norm is `v` and which satisfies the strong triangle inequality `‖m + n‖ ≤ max(‖m‖, ‖n‖)`.
*Proof sketch.* After unfolding the reconstruction and the carrier, the object's norm is definitionally `v` and the strong-triangle obligation is exactly `val_add`, i.e. Lemma 4.5. The remaining axioms transfer verbatim from the carrier. Thus the arithmetic-height data genuinely instantiates the categorical ultrametric-object interface with a nonarchimedean norm. ∎

---

## 5. The Unifying Rigidity Obstruction

The two faces look like they should merge: why not place a quantitative, multiplicative, ℕ-valued norm directly on ℚ? The following theorem shows this is impossible, and thereby explains the fork.

**Theorem 5.1 (Field rigidity).** Let `F` be a field and let `N : F → ℕ` be multiplicative (`N(xy) = N(x) · N(y)`) with `N(1) = 1`. Then `N(x) = 1` for every nonzero `x ∈ F`.
*Proof sketch.* Fix `x ≠ 0`. In a field `x` is invertible, with `x · x⁻¹ = 1`. Apply `N`: `N(x) · N(x⁻¹) = N(1) = 1`. This is an equation of natural numbers, and the only factorization of `1` in ℕ is `1 · 1`; hence `N(x) = N(x⁻¹) = 1`. ∎

**Interpretation.** On a field, multiplicativity plus normalization collapses any ℕ-valued norm to the indicator of nonzero-ness: it cannot record varying depth, because invertibility forces every nonzero norm to divide `1`. Consequently:

- *Quantitative* p-adic depth cannot be carried by a multiplicative **integer**-valued norm over a field. It must be **real-valued**, where `N(x) · N(x⁻¹) = 1` is solved by `p^(−v) · p^(v) = 1` with `v` arbitrary — this is precisely Face I's `|·|_p` (Section 3).

- A multiplicative **ℕ-valued** ultrametric norm that is nontrivial must live over a **non-field**. The integers ℤ are the natural choice: p-adic valuations are nonnegative there, Euclid's lemma makes the divisibility indicator multiplicative, and there is no inverse to force triviality — this is precisely Face II's `arithDepthCarrier` (Section 4).

Theorem 5.1 is therefore not an obstacle but the explanatory keystone: the categorical interface's choice of an ℕ-valued multiplicative norm *forces* the bifurcation between a real-valued metric on a field and a discrete carrier on a ring. The two faces are the two — and the only two — honest realizations of nonarchimedean depth compatible with the interface.

---

## 6. Algorithms

The development is constructive and the discrete face is fully computable. We record the core procedures.

**Algorithm A — p-adic valuation by trial division.** Given a prime `p` and a nonzero integer `n`, repeatedly divide by `p`, counting factors, to obtain `v_p(n)`; extend to fractions by subtracting numerator and denominator valuations. Complexity `O(v_p(n) · M)` where `M` is the cost of one division, i.e. logarithmic in `n` for fixed `p`.

**Algorithm B — depth distance.** Compute `d(x, y) = p^(−v_p(x − y))` by forming the reduced difference and applying Algorithm A. Returns an exact rational prime power; `0` when `x = y`.

**Algorithm C — divisibility indicator and carrier norm.** Compute `v(n) = 0` if `p | n` else `1` by a single modulus test, `O(M)`. This is the norm of the reconstructed ultrametric object on ℤ and the residue-field nonvanishing indicator of Theorem 4.6.

**Algorithm D — ultrametric verification.** Given finitely many sample points, verify the strong triangle inequality `d(x, z) ≤ max(d(x, y), d(y, z))` (Face I) and `v(m + n) ≤ max(v(m), v(n))`, `v(mn) = v(m)v(n)` (Face II) exhaustively over the samples, certifying the theorems numerically.

---

## 7. Applications

- **The p-adic numbers.** Face I is the metric whose completion is `ℚ_p`. The bridge places the construction of `ℚ_p` on an explicit ultrametric footing and connects it to a reusable categorical object.

- **Hierarchical and ultrametric data.** The strong triangle inequality is the defining feature of tree metrics and nested-cluster structures arising in phylogenetics, taxonomy, hierarchical clustering, and the energy landscapes of spin glasses. The depth distance is a clean, exactly computable exemplar.

- **Residue-field evaluation.** Theorem 4.6 models the number-theoretic analogue of "evaluation at a point and vanishing test," a recurring motif linking arithmetic to algebraic geometry (reduction mod `p`) and to coding-theoretic syndrome tests.

- **Categorical reuse.** Through Construction 4.7 and Theorem 4.8 the arithmetic carrier becomes a first-class object in an ultrametric-object category, available to any downstream construction (morphisms, products, reconstruction) defined on that interface.

---

## 8. Discussion

The principal conceptual contribution is the explicit identification of the **rigidity fork** (Theorem 5.1) as the organizing principle behind two superficially different constructions. The categorical interface demands an ℕ-valued multiplicative norm; rigidity then proves that nontrivial depth cannot satisfy this over a field, mandating either a real-valued descent (keep the field, change the codomain) or a ring-theoretic descent (keep the codomain, change the carrier). Both descents are realized and verified here. This turns a would-be limitation into a precise classification of where nonarchimedean depth can live.

A second point of interest is the *coarsening* relationship between the faces. The integer indicator `v` is the Boolean image of the full valuation `v_p` (it records the sign of `v_p` via the divides/does-not-divide test). The quantitative metric retains the full valuation; the categorical carrier retains only its support. Theorem 4.6 shows the retained bit is exactly residue-field nonvanishing — the smallest invariant that is still multiplicative.

---

## 9. Future Directions

(See the dedicated future-directions material accompanying this package for the full program.) The principal threads are:

1. **Completion functor.** `d(x, y)` is the restriction to ℚ of the metric whose completion is `ℚ_p`. We conjecture a completion functor sending the abstract ultrametric object to a complete ultrametric object isometric to Mathlib's `ℚ_p`, realizing `ℚ_p` as a categorical limit of the depth metric.

2. **Multi-prime and adelic carriers.** Combine the per-prime carriers into a product/adelic carrier and study the resulting ultrametric object, aiming at a product-formula-style relation among the depths.

3. **Morphisms and rigidity of maps.** Characterize the morphisms of the reconstructed objects and extend the field-rigidity theorem to a classification of norm-nonexpansive maps between arithmetic carriers.

4. **Higher residue depth.** Replace the Boolean indicator by truncated valuations `min(v_p(n), k)` and seek the largest `k` for which a multiplicative ℕ-valued ultrametric structure survives over a suitable ring.

---

## 10. Conclusion

We have formalized a complete nonarchimedean bridge: a quantitative ultrametric `d(x, y) = |x − y|_p` on ℚ with full metric and strong-triangle properties; a discrete multiplicative ℕ-valued ultrametric seminorm `v(n) = [p ∤ n]` on ℤ with a residue-field representation, packaged as a valuation carrier and reconstructed as a categorical ultrametric object; and a rigidity theorem on fields that unifies and explains the two faces by proving exactly where each is permitted to exist. The arithmetic of divisibility, the geometry of ultrametrics, and a categorical object interface are thereby threaded into a single, constructively verified whole.
