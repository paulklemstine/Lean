# The Valuation–Tropicalization Bridge: Kapranov's Easy Direction, Corner Loci, and Min-Plus Multiplicativity

## Abstract

We develop the foundational bridge between classical algebraic geometry over a
non-Archimedean valued field and tropical geometry, organized around a single
ultrametric principle: *in a finite sum, a strictly minimal valuation term
dominates the total*. From this principle we derive, with fully formal proofs,
(i) the **winner-takes-all lemma** for additive valuations, the additive
analogue of `Valuation.map_sum_eq_of_lt`; (ii) the **easy direction of the
Fundamental Theorem of Tropical Geometry (Kapranov)**, namely that the
tropicalization of any point on a classical hypersurface lies on the corner
locus of the tropical polynomial; (iii) a concrete instantiation for classical
lines; and (iv) **min-plus multiplicativity** of tropical evaluation together
with the **min-plus distributive law**, the arithmetic engine behind tropical
Bézout's degree law. We isolate the boundary case (a single monomial has empty
corner locus, so the theorem genuinely needs at least two monomials), and we
explain how the corner-locus characterization is the scale-invariant limit of
the rescaled valuation family `vₜ = t·v` as `t → ∞`. All results are machine-
checked in Lean 4 with Mathlib.

**Keywords:** tropical geometry, non-Archimedean valuation, Kapranov's theorem,
fundamental theorem of tropical geometry, corner locus, ultrametric inequality,
tropical Bézout, min-plus semiring, formal verification.

---

## 1. Introduction

Tropical geometry replaces algebraic varieties by piecewise-linear polyhedral
complexes obtained via a degeneration. The replacement is governed by a
**valuation**: a measurement of "order of vanishing" that converts
multiplication into addition and obeys an ultrametric inequality for sums. Under
this lens, the zero locus of a polynomial degenerates to the *corner locus* (the
non-smooth locus) of an associated piecewise-linear *tropical polynomial*, the
minimum of finitely many affine functions.

The cornerstone result legitimizing this passage is the **Fundamental Theorem of
Tropical Geometry**, often attributed to Kapranov in the hypersurface case and to
Einsiedler–Kapranov–Lind in general. It asserts that the tropicalization of a
classical variety `V` equals the corner locus of the tropicalized defining
polynomial. The theorem has two directions:

- **Easy direction (containment):** the tropicalization of a point of `V` lies
  on the corner locus. This is a direct consequence of the ultrametric
  inequality.
- **Hard direction (surjectivity):** every point of the corner locus is the
  tropicalization of an actual point of `V`. This requires a lifting argument
  (Newton polygons / Hensel's lemma) and algebraic closedness.

This paper formalizes the easy direction in full, distills its single load-
bearing lemma, packages the min-plus arithmetic that yields tropical Bézout, and
articulates the limiting picture `vₜ = t·v, t → ∞`. The hard direction is left
as a precisely stated conjecture (Section 8).

---

## 2. The valuation as tropicalization map

We work with an **additive valuation** `v : AddValuation K Γ` on a field `K`
with values in a linearly ordered additive commutative monoid with top,
`Γ` (the symbol `⊤ = ∞` is the value `v(0)`).

**Definition 2.1 (Additive valuation).** A function `v : K → Γ` is an additive
valuation if:
1. `v(0) = ⊤` and `v(1) = 0`;
2. `v(a·b) = v(a) + v(b)` (multiplicativity becomes additivity);
3. `v(a + b) ≥ min(v(a), v(b))` (the **ultrametric inequality**).

Property (2) is the homomorphism property; property (3) is the non-Archimedean
heart of the theory. We read `v` as the **tropicalization map**: it sends a
field element to a point of the tropical (min-plus) semiring.

A standard consequence of (3) that we use repeatedly:

**Lemma 2.2 (Ultrametric equality away from ties).** If `v(a) < v(b)` then
`v(a + b) = v(a)`. (In Mathlib: `AddValuation.map_add_eq_of_lt_left`.)

This is the two-term form of "winner takes all," promoted below to finite sums.

---

## 3. The corner locus

**Definition 3.1 (Attained at least twice / corner locus).** For a weight
function `w : ι → α` valued in a linear order `α`, say `w` **attains its minimum
at least twice**, written `AttainedAtLeastTwice w`, if

> there exist `i ≠ j` such that `∀ k, w(i) ≤ w(k)` and `∀ k, w(j) ≤ w(k)`.

Geometrically, given a tropical polynomial `P(x) = minᵢ (aᵢ + ⟨mᵢ, x⟩)` whose
linear pieces are indexed by `ι`, the weights `w(i) = aᵢ + ⟨mᵢ, x⟩` at a point
`x` attain their minimum at least twice exactly when `x` lies on the **corner
locus** (tropical hypersurface): the locus where `P` is non-differentiable
because two distinct monomials tie for the minimum.

**Theorem 3.2 (Boundary case: a single monomial has no corners).** If the index
type `ι` is a subsingleton (at most one element), then `¬ AttainedAtLeastTwice w`
for every `w`.

*Proof sketch.* A witness requires distinct indices `i ≠ j`, but in a
subsingleton any two indices are equal, contradicting `i ≠ j`. ∎

Theorem 3.2 records why the main theorem genuinely requires at least two
monomials: a single affine function is globally smooth and defines an empty
tropical hypersurface.

---

## 4. The winner-takes-all lemma

The technical core of the bridge is the finite-sum form of Lemma 2.2.

**Theorem 4.1 (Winner-takes-all).** Let `v : AddValuation K Γ`, let `s` be a
finite index set, `f : ι → K`, and `j ∈ s`. If

> `∀ i ∈ s, i ≠ j ⟹ v(f j) < v(f i)`,

i.e. `f j` is the *strict* minimizer of the valuation over `s`, then

> `v(∑_{i ∈ s} f i) = v(f j).`

*Proof sketch.* Two cases on whether `v(f j) = ⊤`.

- If `v(f j) = ⊤`: since `f j` is the strict minimizer, every other term has
  valuation `> ⊤`, which is impossible; hence `s = {j}` is a singleton and the
  sum is `f j` itself, giving the result trivially.
- If `v(f j) ≠ ⊤`: split the sum as `f j + ∑_{i ∈ s \ {j}} f i`. Every term in
  the remainder has valuation strictly greater than `v(f j)`, so by the finite
  ultrametric strict inequality (`Valuation.map_lt_sum`, the additive
  `v.map_lt_sum`) the remainder also has valuation strictly greater than
  `v(f j)`. Applying the two-term equality `AddValuation.map_add_eq_of_lt_left`
  to `f j` plus the remainder yields `v(∑) = v(f j)`. ∎

Theorem 4.1 is the additive analogue of `Valuation.map_sum_eq_of_lt`, and it is
the only nontrivial ingredient needed for Kapranov's easy direction.

---

## 5. Kapranov's easy direction

**Theorem 5.1 (Tropicalization ⊆ corner locus; Kapranov, easy direction).** Let
`K` be a field with additive valuation `v : AddValuation K Γ`, where `Γ` is
nontrivial. Let `ι` be a finite nonempty index type and `T : ι → K` the family of
monomials of a polynomial evaluated at a point. Suppose

1. `∑ᵢ T i = 0` (the point lies on the hypersurface), and
2. `∃ i, T i ≠ 0` (the polynomial does not vanish identically there).

Then the tropicalized weight function `i ↦ v(T i)` satisfies
`AttainedAtLeastTwice`.

*Proof sketch.* Let `m` be an index achieving the minimum of `i ↦ v(T i)` over
the (finite, nonempty) index set; such an `m` exists by `Finset.exists_min_image`,
using that the family is nonempty. Suppose, for contradiction, that the minimum
is *not* attained twice. Then `m` is the *unique* minimizer, so for all `i ≠ m`
we have `v(T m) < v(T i)` (combine `m`'s minimality `v(T m) ≤ v(T i)` with the
failure of a second minimizer to upgrade `≤` to `<`). By Theorem 4.1,
`v(∑ᵢ T i) = v(T m)`. But hypothesis (1) gives `∑ᵢ T i = 0`, and `v(0) = ⊤`, so
`v(T m) = ⊤`, i.e. `T m = 0` and indeed every term would have valuation `≥ ⊤`,
forcing all `T i = 0` — contradicting hypothesis (2). Therefore the minimum is
attained at least twice. ∎

This is the precise sense in which **the tropicalization of a variety is
contained in the corner locus of the tropical polynomial**. The proof uses
nothing beyond the winner-takes-all lemma and `v(0) = ⊤`.

**Theorem 5.2 (Classical line ↦ tropical corner).** Let `v` be an additive
valuation on `K` (`Γ` nontrivial), and let `a, b, c, x, y ∈ K` with

1. `a·x + b·y + c = 0` (a point `(x, y)` on the classical line `aX + bY + c = 0`),
   and
2. `a·x ≠ 0 ∨ b·y ≠ 0 ∨ c ≠ 0` (nondegeneracy).

Then the weight function on three indices,
`i ↦ v(![a·x, b·y, c] i)`, attains its minimum at least twice: the tropical line
`min(v(a)+X, v(b)+Y, v(c))` has a corner at the tropicalized point.

*Proof sketch.* Apply Theorem 5.1 with `ι = Fin 3` and `T = ![a·x, b·y, c]`. The
sum hypothesis `T 0 + T 1 + T 2 = a·x + b·y + c = 0` follows from (1) by
`Fin.sum_univ_three`; the nonvanishing hypothesis follows from (2) by selecting
the nonzero coordinate. ∎

---

## 6. Min-plus multiplicativity and tropical Bézout

The second pillar of the bridge concerns *products* and explains why tropical
intersection/degree counts match classical ones.

**Definition 6.1 (Tropical polynomial, min-plus convention).** A tropical
polynomial in `n` variables is a finite family of monomials, each an affine
function `x ↦ aᵢ + ⟨mᵢ, x⟩`, and its evaluation is `eval P (x) = minᵢ (aᵢ +
⟨mᵢ, x⟩)`. Tropical multiplication `⊙` of polynomials corresponds to ordinary
addition of their evaluations (the min-plus product distributes the index sets).

**Theorem 6.2 (Min-plus multiplicativity).** For tropical polynomials `P`, `Q`,

> `eval (P ⊙ Q) = eval P + eval Q.`

That is, tropical evaluation is a homomorphism from the min-plus polynomial
product to ordinary pointwise addition. This is the tropical shadow of the
valuation axiom `v(a·b) = v(a) + v(b)`: degrees add, and the hypersurface of a
product decomposes as the union of the hypersurfaces of the factors. It is the
engine of **tropical Bézout**, which states that two tropical plane curves of
degrees `d` and `e` meet in `d·e` points (counted with multiplicity / stable
intersection).

The combinatorial heart of Theorem 6.2 is a distributive law for infima over a
product index set:

**Theorem 6.3 (Min-plus distributivity).** Let `s ⊆ ι` and `t ⊆ κ` be nonempty
finite sets, `f : ι → ℝ`, `g : κ → ℝ`. Then

> `inf_{(i,k) ∈ s × t} (f(i) + g(k)) = (inf_{i ∈ s} f(i)) + (inf_{k ∈ t} g(k)).`

*Proof sketch.* Antisymmetry. (≤) Choose minimizers `a ∈ s` of `f` and `b ∈ t`
of `g` (`Finset.exists_mem_eq_inf'`); the pair `(a, b)` realizes the right-hand
side as a value of the left-hand objective, so the left infimum is `≤` it.
(≥) For every `(i, k) ∈ s × t`, `f(i) + g(k) ≥ inf f + inf g` by adding the two
per-axis bounds `Finset.inf'_le`; taking the infimum preserves the inequality. ∎

Theorem 6.3 is exactly why tropical multiplication adds degrees: the cheapest
corner of a product of polynomials is the sum of the cheapest corners of the
factors. Iterating it across the monomial supports of `P` and `Q` yields
Theorem 6.2, hence tropical Bézout's degree law.

---

## 7. The limit `vₜ = t·v` as `t → ∞`

Classically one views tropicalization as a degeneration: for the rescaled family
`vₜ := t·v` (`t : ℝ≥0`), letting `t → ∞` sharpens the valuation until the amoeba
of a complex variety converges to its tropical skeleton. The corner-locus
characterization of Sections 3–5 is the invariant limiting shape.

The key structural observation is **scale-equivariance**. Rescaling a valuation
by a positive constant preserves both valuation axioms, so `t·v` is again an
additive valuation. Moreover the corner-locus predicate is invariant under
positive scaling of weights:

> For `t > 0`, `AttainedAtLeastTwice (t · w) ⟺ AttainedAtLeastTwice w`,

since multiplication by a positive constant preserves the order and the set of
minimizers. Consequently the tropical variety produced by every member `vₜ` of
the family is the *same shape* up to homothety. The "limit" `t → ∞` is therefore
not a delicate Hausdorff limit of moving sets but the fixed normalized silhouette
all members already share. This is the formal content of the slogan
"tropicalization is the `t → ∞` limit of classical geometry."

---

## 8. Discussion and future work

### 8.1 The hard direction (surjectivity)

The natural converse to Theorem 5.1 is Kapranov's hard direction:

> **Conjecture.** If `K` is algebraically closed with a non-trivial valuation `v`
> whose value group is divisible (so `v` is surjective onto `Γ`), then for every
> weight vector `w` on the corner locus of `trop(f)` there is a point `p` with
> `f(p) = 0` and `v(p) = w`.

The easy direction is a pure consequence of the ultrametric inequality being an
equality away from ties; the hard direction needs a genuine *lifting* step — a
Newton-polygon / Hensel argument promoting a leading-term cancellation (two
monomials tied for the minimum) into an actual root. The univariate case
(`Fin 1` variable, where the Newton polygon is literally the lower convex hull of
`{(i, v(cᵢ))}`) reduces the theorem to Hensel's lemma plus convexity, and is the
recommended first formalization target.

### 8.2 Genuine limit statement

A precise convergence theorem for `vₜ = t·v` would assert that the corner locus
of `trop_{vₜ}(f)` converges, in the Hausdorff metric on compact windows, to the
`t`-scaled corner locus of `trop_v(f)`; equivalently `(1/t)·Log_t(V(f))`
converges to the tropical variety. The scale-equivariance lemma of Section 7
turns this hard analytic statement into an algebraic invariance.

### 8.3 Applications

The min-plus multiplicativity of Section 6 underlies tropical enumerative
geometry (Mikhalkin's correspondence theorem reduces curve counts to lattice-path
counts), and the corner-locus formalism is the natural language for ReLU neural
networks (whose activation regions are tropical hypersurfaces), phylogenetics
(tropical convexity of tree space), and combinatorial optimization (shortest
paths as min-plus matrix powers).

---

## 9. Summary of formal results

| Result | Statement |
|---|---|
| `AttainedAtLeastTwice` | corner-locus predicate: minimum attained at ≥ 2 distinct indices |
| `attainedTwice_subsingleton` | one-monomial tropical polynomial has empty corner locus |
| `addValuation_sum_eq_of_unique_min` | winner-takes-all: strict min term controls `v(∑)` |
| `kapranov_easy_direction` | tropicalization of a hypersurface point lies on the corner locus |
| `tropical_line_corner` | concrete classical-line instance |
| `inf'_product_add` | min-plus distributivity over a product index set |
| `TropPoly.eval_mul` | min-plus multiplicativity: `eval(P ⊙ Q) = eval P + eval Q` |

All statements are formalized and proved in Lean 4 with Mathlib, using only the
standard axioms `propext`, `Classical.choice`, and `Quot.sound`.

---

## References (background, not required for self-containment)

The results above are self-contained. For broader context, readers may consult
the standard literature on tropical geometry and non-Archimedean amoebas;
Kapranov's theorem and the Einsiedler–Kapranov–Lind structure theorem are the
classical antecedents of Theorem 5.1.
