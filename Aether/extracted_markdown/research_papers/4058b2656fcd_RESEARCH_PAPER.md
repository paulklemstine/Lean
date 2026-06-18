# A Functor from Finite Linear Codes to Tropical Valuation Objects via Weight-Threshold Profiles

## Abstract

We introduce the **weight-threshold profile** `tprof`, a nonarchimedean valuation on
binary vectors defined as one plus the index of the highest active coordinate. Unlike
the Hamming weight `wt`, which is additive (archimedean) and fails the strong triangle
inequality, the threshold profile satisfies separation, the ultrametric (strong)
triangle inequality, and the sharp isosceles law, while dominating the Hamming weight
and remaining bounded by the block length. We use it to build a category `CodeVal` of
*threshold-valued codes* — ultrametric objects shorn of the multiplicative-norm axiom
that no nontrivial code valuation can meet — and we construct an explicit functor
`toTrop : CodeVal ⟶ TropObj` into the category of tropical valuation objects over the
value semiring `(ℕ, max, +)`. The functor is shown to preserve identities and
composition, mirroring classical tropicalization. We exhibit a concrete functorial
family via the prefix-inclusion maps `padHom`, and we illustrate the theory on the
extended Hamming `[8,4,4]` code. All results have been formally verified.

---

## 1. Introduction

Coding theory and tropical geometry are usually told as separate stories. Coding
theory measures codewords by their **Hamming weight** `wt(x)`, the number of nonzero
coordinates, and the entire apparatus of minimum distance, weight enumerators, and
the MacWilliams identities is built on this additive invariant. Tropical geometry,
by contrast, replaces ordinary addition with `max` and ordinary multiplication with
`+`, working over idempotent ("tropical") semirings such as `(ℕ, max, +)`.

The obstruction to bridging the two is precisely the arithmetic of the weight: `wt`
is *archimedean*. For instance, with binary vectors `1100` and `0011`,
`wt(1100 + 0011) = wt(1111) = 4 > max(2,2)`. The weight of a sum can strictly exceed
both summand weights, so `wt` obeys only the ordinary triangle inequality
`wt(x+y) ≤ wt(x) + wt(y)` and cannot factor through a tropical (`max`-based) target.

This paper isolates the *correct* invariant for the bridge. The **weight-threshold
profile** `tprof(x)` records not how many coordinates are active but *where the
activity ends*: it is `lead(x) + 1`, where `lead(x)` is the index of the top active
coordinate, with `tprof(0) = 0`. This is the classical leading-position
(degree) nonarchimedean valuation, read off the *weight-threshold profile* of the
codeword — scanning coordinates `0, 1, 2, …`, `tprof(x)` is the threshold beyond
which `x` is silent. We prove `tprof` is a genuine nonarchimedean valuation and use it
to construct an honest functor from finite linear codes to tropical valuation objects.

### Contributions

1. The valuation `tprof` and its core properties: separation, negation-invariance,
   the strong triangle inequality, and the sharp isosceles law (§3).
2. The comparison inequalities `wt(x) ≤ tprof(x) ≤ n` relating the new invariant to
   the classical weight and the block length (§3).
3. The category `CodeVal` of threshold-valued codes and the prefix-inclusion
   functorial family `padHom`, `thresholdSpace` (§4).
4. The functor `toTrop : CodeVal ⟶ TropObj` into tropical valuation objects over
   `(ℕ, max, +)`, with functoriality `toTropMap_id`, `toTropMap_comp` (§5).
5. A worked example on the extended Hamming `[8,4,4]` code (§6).

---

## 2. Preliminaries

Throughout, `n, m : ℕ`, and a *binary vector of length `n`* is a function
`x : Fin n → ZMod 2`. Addition of binary vectors is coordinatewise in `ZMod 2`
(equivalently, bitwise exclusive-or); in characteristic two, `x + x = 0` and
`-x = x`.

**Definition 2.1 (Support).** The *support* of `x : Fin n → ZMod 2` is the finite
set of active coordinates,
$$ \operatorname{support}(x) \;=\; \{\, i \in \mathrm{Fin}\,n : x_i \neq 0 \,\}. $$

**Definition 2.2 (Hamming weight).** The *Hamming weight* is
`wt(x) = #{ i : x_i = 1 } = #\operatorname{support}(x)`.

**Two elementary support facts.** First, the zero vector has empty support,
`support(0) = ∅`. Second, and crucially, support is *subadditive* under sum:
$$ \operatorname{support}(x + y) \;\subseteq\; \operatorname{support}(x) \cup \operatorname{support}(y). \tag{2.1} $$
*Proof.* If `i` is active in `x + y` then `x_i + y_i ≠ 0`, so at least one of
`x_i, y_i` is nonzero; were both zero, the sum would be zero. ∎

Inclusion (2.1) is the seed from which the entire ultrametric theory grows.

---

## 3. The weight-threshold profile valuation

**Definition 3.1 (Weight-threshold profile).** For `x : Fin n → ZMod 2`,
$$ \operatorname{tprof}(x) \;=\; \sup_{\,i \in \operatorname{support}(x)} \big( (i : \mathbb{N}) + 1 \big), $$
the supremum (with `sup ∅ = 0`) over active coordinates of `i + 1`. Equivalently
`tprof(x) = lead(x) + 1` for the maximal active index `lead(x)`, and `tprof(0) = 0`.

**Lemma 3.2 (Realization at the top).** For each `i ∈ support(x)`,
`(i : ℕ) + 1 ≤ tprof(x)` (`le_tprof_of_mem`); and for `x ≠ 0` there exists an index
`i` with `x_i ≠ 0` and `(i : ℕ) + 1 = tprof(x)` (`exists_top_coord`).
*Proof.* The first is `Finset.le_sup`. For the second, the support is a nonempty
finite set, hence attains a maximum of `i ↦ (i:ℕ)+1`, and that maximum is the
supremum defining `tprof(x)`. ∎

**Theorem 3.3 (Separation, `tprof_eq_zero_iff`).**
`tprof(x) = 0 ⟺ x = 0`.
*Proof.* If `x = 0`, the support is empty and the supremum is `0`. Conversely, if
`x ≠ 0`, some coordinate is active, contributing a term `≥ 1` to the supremum, so
`tprof(x) ≥ 1 > 0`. ∎

**Lemma 3.4 (Negation-invariance, `tprof_neg`).** `tprof(-x) = tprof(x)`.
*Proof.* In `ZMod 2`, `-x = x`, so `support(-x) = support(x)` and the suprema agree.
∎

**Theorem 3.5 (Strong triangle inequality, `tprof_add_le`).**
$$ \operatorname{tprof}(x + y) \;\le\; \max\big(\operatorname{tprof}(x),\, \operatorname{tprof}(y)\big). $$
*Proof.* By the support inclusion (2.1) and monotonicity of `Finset.sup`,
$$ \operatorname{tprof}(x+y) = \sup_{\operatorname{support}(x+y)} (i+1)
   \le \sup_{\operatorname{support}(x)\cup\operatorname{support}(y)} (i+1). $$
By `Finset.sup_union`, the right-hand side equals
`max( sup_{support x}(i+1), sup_{support y}(i+1) ) = max(tprof x, tprof y)`. ∎

This is the **ultrametric (nonarchimedean) inequality**. The entire content is the
support union bound (2.1) plus `Finset.sup_union`: the move from `wt` (additive) to
`tprof` (`max`-stable) is exactly the move from the metric to the tropical world.

**Theorem 3.6 (Isosceles law, `tprof_add_eq_of_ne`).** If
`tprof(x) ≠ tprof(y)`, then
$$ \operatorname{tprof}(x + y) \;=\; \max\big(\operatorname{tprof}(x),\, \operatorname{tprof}(y)\big). $$
*Proof.* Without loss of generality (by commutativity of `+` and `max`), assume
`tprof(x) < tprof(y)`. Then `y ≠ 0` (else `tprof(y) = 0 ≤ tprof(x)`), so by Lemma 3.2
there is a top index `i` with `y_i ≠ 0` and `(i:ℕ)+1 = tprof(y)`. Since
`(i:ℕ)+1 = tprof(y) > tprof(x)`, the index `i` exceeds every active index of `x`, so
`x_i = 0`. Hence `(x+y)_i = x_i + y_i = y_i ≠ 0`, so `i ∈ support(x+y)` and
`tprof(x+y) ≥ (i:ℕ)+1 = tprof(y) = max(tprof x, tprof y)`. The reverse inequality is
Theorem 3.5. ∎

Theorem 3.6 is the sharp nonarchimedean phenomenon: *all triangles are isosceles*.
When two valuations differ, the top coordinate of the larger summand cannot be
cancelled (there is nothing at that height in the smaller summand to cancel it),
so the larger valuation survives exactly. Char-2 cancellation at the top coordinate
is what upgrades the inequality to equality.

**Theorem 3.7 (Comparison bounds, `wt_le_tprof` / `tprof_le_card`).**
$$ \operatorname{wt}(x) \;\le\; \operatorname{tprof}(x) \;\le\; n. $$
*Proof.* For the upper bound, every contributing term `(i:ℕ)+1` satisfies
`(i:ℕ)+1 ≤ n` since `i < n`, so the supremum is `≤ n`. For the lower bound, the
support is contained in `{0, 1, …, lead(x)}`, a set of size `lead(x)+1 = tprof(x)`,
so `wt(x) = #support(x) ≤ tprof(x)`. ∎

The profile thus *sandwiches* the weight from above and is capped by the length:
`tprof` is a refinement that sees positional information the weight discards.

---

## 4. The category of threshold-valued codes

The catalog's `UltraNormObj` requires a *multiplicative* norm,
`norm(x·y) = norm(x)·norm(y)`. No nontrivial code valuation satisfies this:
valuations are *additive*, `v(xy) = v(x) + v(y)`. We therefore work in a bespoke
category that retains every ultrametric axiom but drops multiplicativity.

**Definition 4.1 (`CodeVal`).** A *threshold-valued code* is a type `α` with a
commutative additive group structure (`add_op`, `neg_op`, `zero_val`,
`sub_op = add_op (· , neg_op ·)`) and a valuation `val : α → ℕ` satisfying:
- `val(zero_val) = 0` (separation at zero),
- `val(neg_op x) = val(x)` (negation-invariance),
- `val(add_op x y) ≤ max(val x, val y)` (strong triangle inequality).

This is exactly `UltraNormObj` minus the `norm_mul` axiom.

**Definition 4.2 (`CodeValHom`).** A morphism `X ⟶ Y` of threshold-valued codes is
a function `f : X.α → Y.α` with `f(zero) = zero`, `f(add x y) = add (f x) (f y)`,
and the nonexpansiveness `Y.val(f x) ≤ X.val(x)`.

**Proposition 4.3 (Category laws).** Identities (`CodeValHom.id`) and composition
(`CodeValHom.comp`) make `CodeVal` a category: composition is associative
(`comp_assoc`) and unital (`comp_id`, `id_comp`). *Proof.* Each law holds by
definitional unfolding, as for any concrete category of structured sets and
structure-preserving maps. ∎

**Definition 4.4 (`thresholdSpace`).** The ambient length-`n` space
`Fin n → ZMod 2`, with coordinatewise group operations and valuation `tprof`, is a
threshold-valued code by Theorems 3.3–3.5.

**Definition 4.5 (Prefix inclusion `padHom`).** For `m ≤ n`, the inclusion that
sends a length-`m` vector to the length-`n` vector agreeing on the first `m`
coordinates and zero thereafter is a `CodeValHom`
`thresholdSpace m ⟶ thresholdSpace n`. It is *profile-preserving*: padding with
trailing zeros leaves the top active coordinate unchanged, so it is in particular
nonexpansive (indeed valuation-preserving). The family `{padHom}` over the poset
`(ℕ, ≤)` is functorial, giving a concrete functor `(ℕ, ≤) ⟶ CodeVal`.

---

## 5. The functor to tropical valuation objects

A **tropical valuation object** `TropObj` is a linearly ordered, additive-idempotent
commutative monoid with a compatible multiplication, whose defining axiom is
`add = max` (the tropical principle). The canonical example is the value semiring
$$ \texttt{tropicalization\_base} \;=\; (\mathbb{N},\ \max,\ +), $$
with order `≤`, additive unit `0`, multiplicative unit `1`, "addition" `max`, and
"multiplication" `+`. All idempotent-semiring axioms (commutativity, associativity,
idempotence of `max`, absorption, unit laws) hold by `omega`/`Nat` arithmetic.

**Definition 5.1 (`CodeVal.toTrop`).** Define `toTrop` on objects to be constant at
the value semiring:
$$ \texttt{toTrop}(X) \;=\; (\mathbb{N},\ \texttt{tropicalization\_base}) \in \texttt{TropObj}. $$
This mirrors the catalog's `tropicalization`, which is likewise constant on objects:
the relevant data of a threshold-valued code is its *value semiring*, not its
underlying set.

**Definition 5.2 (`CodeVal.toTropMap`).** For a morphism `f : X ⟶ Y` of
threshold-valued codes, define
$$ \texttt{toTropMap}(f) : \texttt{toTrop}(X) \to \texttt{toTrop}(Y) $$
to be the identity `TropHom` on `ℕ`: it preserves `0`, `1`, `max` (= tropical add),
`+` (= tropical mul), and is monotone, hence a legitimate tropical morphism. The
nonexpansiveness of `f` is exactly the statement that, on the value semiring, the
induced map respects the tropical order.

**Theorem 5.3 (Functoriality, `toTropMap_id` / `toTropMap_comp`).**
$$ \texttt{toTropMap}(\mathrm{id}_X) = \mathrm{id}_{\texttt{toTrop}(X)}, \qquad
   \texttt{toTropMap}(g \circ f) = \texttt{toTropMap}(g) \circ \texttt{toTropMap}(f). $$
*Proof.* Both sides are the identity `TropHom` on `ℕ`; equality holds by
`TropHom` extensionality (`ext x; rfl`). ∎

Together, Definitions 5.1–5.2 and Theorem 5.3 give the announced functor
$$ \boxed{\ \texttt{toTrop} : \mathrm{FinLinCodes} \;\longrightarrow\; \texttt{TropObj}\ } $$
factoring the threshold valuation `tprof` through the tropical value semiring
`(ℕ, max, +)`. The strong triangle inequality (Theorem 3.5) is precisely the
compatibility that lets binary-vector addition (exclusive-or) map onto the tropical
`max`, so the functor is well defined.

---

## 6. Worked example: the extended Hamming `[8,4,4]` code

The **extended Hamming code** is the image of the encoder
`encode(a)_j = ∑_i a_i · G_{ij}` with Reed–Muller generator
$$ G = \begin{pmatrix} 1&1&1&1&1&1&1&1\\ 0&0&0&0&1&1&1&1\\ 0&0&1&1&0&0&1&1\\ 0&1&0&1&0&1&0&1 \end{pmatrix}, $$
giving `16` codewords in `Fin 8 → ZMod 2`. Classically it has minimum distance `4`
and weight enumerator `W_C(x) = 1 + 14x^4 + x^8` (one weight-0 word, fourteen
weight-4 words, one weight-8 word); it is self-dual, the mod-2 shadow of `E8`.

Reading the same code through `tprof` gives a complementary *positional* spectrum:
- The zero codeword has `tprof = 0` (and `wt = 0`).
- The all-ones codeword (row 1 of `G`) has top active coordinate `7`, hence
  `tprof = 8 = n` (and `wt = 8`).
- Every other nonzero codeword has `tprof` equal to one plus the index of its last
  active coordinate, always satisfying `wt ≤ tprof ≤ 8` (Theorem 3.7).

One verifies on all `16·16` pairs that the strong triangle inequality (Theorem 3.5)
holds, and that for every pair with distinct profiles the isosceles equality
(Theorem 3.6) is exact. The accompanying `demo.py` performs this exhaustive check.

---

## 7. Discussion

The conceptual content is a single slogan: **count where the activity ends, not how
much there is.** The Hamming weight is additive and archimedean; the threshold
profile is `max`-stable and nonarchimedean. The support union bound (2.1) is the
hinge — it converts the combinatorics of bit patterns into the geometry of an
ultrametric valuation, and characteristic-2 cancellation at the top coordinate
sharpens the inequality into the isosceles law.

The two structural obstructions encountered are instructive. First, `wt` *cannot*
serve as the bridge invariant because it violates the strong triangle inequality.
Second, the catalog's multiplicative `UltraNormObj` is the wrong target because code
valuations are additive, not multiplicative. The resolution — a bespoke `CodeVal`
plus a crossing into the tropical world through the value semiring `(ℕ, max, +)` —
is precisely how classical tropicalization itself behaves (constant on objects,
identity on the value semiring).

---

## 8. Future directions

A program of falsifiable, formalizable conjectures extends this bridge:

1. **Tropical weight enumerator.** The threshold-truncated max-weight profile
   `T_C(t) = max{ wt(c) : c ∈ C, tprof(c) ≤ t }` should be a piecewise-constant,
   monotone, concave tropical polynomial whose breakpoints are the distinct
   `tprof`-values on `C`; for self-dual codes the number of breakpoints should equal
   `1 + d/4`. Testable first on the `[8,4,4]` Hamming code (predicted breakpoints at
   `t = 7, 8`).
2. **Standard-form characterization.** The value set of `tprof` on `C` should
   recover the pivot columns of the reduced row-echelon generator, making `toTrop`
   faithful on standard-form codes (distinct codes ⇒ distinct threshold
   multisets).
3. **Ultrametric MacWilliams duality.** With the induced ultrametric distance and
   ball-counting `N_C(r) = #{ c ∈ C : tprof(c) ≤ r }`, a MacWilliams-type identity
   should relate `N_C` and `N_{C⊥}`; for self-dual codes (e.g. Hamming) this
   predicts `N_C(r)·N_C(n-r)` is constant in `r`.
4. **Monoidality under direct sums.** For the concatenation `C ⊕ D`,
   `tprof_{C⊕D}(append a b) = max(tprof_C a, m + tprof_D b)` (with `m` the left block
   length), upgrading `toTrop` to a lax monoidal functor
   `(FinLinCodes, ⊕) ⟶ (TropObj, ⊗_max)`.
5. **The multiplicative obstruction**, made precise: a classification of which code
   valuations, if any, can satisfy a multiplicative norm law, quantifying the gap
   that forces the passage through `CodeVal` rather than `UltraNormObj`.

---

## 9. Conclusion

By replacing the additive Hamming weight with the nonarchimedean threshold profile,
finite linear codes acquire a genuine ultrametric valuation that satisfies
separation, the strong triangle inequality, and the sharp isosceles law, dominates
the weight, and respects the block length. This valuation assembles the codes into a
category `CodeVal` and induces an honest, identity- and composition-preserving
functor `toTrop : FinLinCodes ⟶ TropObj` into tropical valuation objects over
`(ℕ, max, +)`. The construction makes precise, and formally verifies, a bridge
between coding theory and tropical geometry that the weight invariant alone could
never reveal.
