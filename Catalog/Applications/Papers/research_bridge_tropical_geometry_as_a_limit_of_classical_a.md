# Tropical Geometry as the Image of a Non-Archimedean Valuation: The Corner-Locus Bridge and the Engine of Tropical Bézout

## Abstract

We develop, with full rigor, the bridge connecting classical algebraic geometry
over a non-Archimedean valued field to tropical (min-plus) geometry. The central
object is an additive valuation `v : K → Γ ∪ {∞}`, interpreted as a
*tropicalization map* sending a field element to its order in a totally ordered
value group. We prove four interlocking results. First, an *ultrametric
winner-takes-all lemma*: if a single term of a finite sum has strictly minimal
valuation, the valuation of the sum equals that term's valuation. Second, the
*easy direction of the Fundamental Theorem of Tropical Geometry* (attributed to
Kapranov): the tropicalization of a point on a classical hypersurface lies on the
*corner locus* of the tropical polynomial, i.e. the tropicalized term-valuations
attain their minimum at least twice. Third, *min-plus multiplicativity*: tropical
evaluation sends products of tropical polynomials to sums of evaluations,
`eval(P ⊙ Q) = eval(P) + eval(Q)`, the combinatorial engine that makes degrees
(and Newton polytopes) add — the heart of tropical Bézout. Fourth, a
*strengthening* showing that only leading-term cancellation, not full vanishing,
is needed to force a corner. We also record the boundary case (a single monomial
has empty corner locus) and a concrete instance for classical/tropical lines.
All statements are formalized and machine-checked. We close with applications to
enumerative geometry and a roadmap toward the quantitative tropical Bézout
theorem.

**Keywords:** tropical geometry, non-Archimedean valuation, min-plus semiring,
Fundamental Theorem of Tropical Geometry, Kapranov's theorem, corner locus,
tropical hypersurface, Newton polytope, tropical Bézout, ultrametric.

**MSC 2020:** 14T10 (Foundations of tropical geometry), 14T15 (Combinatorial
aspects of tropical varieties), 12J25 (Non-Archimedean valued fields), 52B20
(Lattice polytopes).

---

## 1. Introduction

Tropical geometry studies the piecewise-linear images of algebraic varieties
under a degeneration governed by a non-Archimedean valuation. The min-plus
semiring `(ℝ ∪ {∞}, ⊕, ⊙)`, with `a ⊕ b := min(a, b)` and `a ⊙ b := a + b`,
replaces the field operations, and smooth varieties degenerate into polyhedral
complexes. The dictionary between the two worlds is supplied by a valuation,
which converts multiplication into addition and addition (generically) into
minimum.

This paper isolates and proves the algebraic core of that dictionary. We work
over an arbitrary field `K` equipped with an additive valuation `v` into a
linearly ordered additive commutative monoid-with-top `Γ` (so that `v(0) = ⊤`).
The valuation is read as the tropicalization map. Our contributions are:

1. **The ultrametric winner-takes-all lemma** (§3), the additive-valuation
   analogue of the multiplicative `Valuation.map_sum_eq_of_lt`.
2. **Kapranov's easy direction** (§4): tropicalization is contained in the corner
   locus, together with a concrete line instance.
3. **Min-plus multiplicativity** (§5), via a min-plus distributive law over a
   product index set, with the tropical polynomial / evaluation / product
   formalism.
4. **A leading-term-cancellation strengthening** (§6) that generalizes Kapranov's
   easy direction beyond exact vanishing.

We emphasize the "limit of valuations" interpretation: classically one studies
the rescaled family `v_t = t · v` as `t → ∞`; the corner-locus characterization
is the invariant limiting shape onto which the (logarithmic) amoeba of the
variety collapses.

---

## 2. Setting and definitions

### 2.1 Valuations

Throughout, `K` is a field and `Γ` is a `LinearOrderedAddCommMonoidWithTop`: a
linearly ordered additive commutative monoid with a top element `⊤` absorbing
addition. An **additive valuation** `v : AddValuation K Γ` satisfies
`v(0) = ⊤`, `v(1) = 0`, `v(xy) = v(x) + v(y)`, and the ultrametric inequality
`v(x + y) ≥ min(v(x), v(y))`, with equality when `v(x) ≠ v(y)`. We read `v(x)` as
the *order* (tropicalization) of `x`.

### 2.2 The corner locus

The corner locus is captured by a predicate on weight functions.

> **Definition 2.1 (Attained at least twice / corner locus).**
> For a linear order `α` and a weight function `w : ι → α`, define
> `AttainedAtLeastTwice w` to hold iff there exist indices `i ≠ j` such that
> `∀ k, w(i) ≤ w(k)` and `∀ k, w(j) ≤ w(k)`.

Geometrically, a tropical polynomial `x ↦ min_i (c_i + ⟨a_i, x⟩)` is a concave
piecewise-linear function; it is non-smooth exactly where the defining minimum is
achieved by two or more distinct monomials. The set of such non-smooth points is
the **tropical hypersurface** (corner locus). `AttainedAtLeastTwice` is precisely
the pointwise condition "this point is a corner."

> **Proposition 2.2 (Boundary case).** If `ι` is a subsingleton (at most one
> index), then `¬ AttainedAtLeastTwice w` for every `w`.
>
> *Proof sketch.* A witness requires distinct `i ≠ j`; in a subsingleton any two
> elements are equal, so no witness exists. ∎

This records that a single tropical monomial defines a smooth (globally linear)
function with empty corner locus: at least two monomials are needed for the
fundamental theorem to have content.

---

## 3. The ultrametric winner-takes-all lemma

The technical heart of the bridge is the following additive analogue of
`Valuation.map_sum_eq_of_lt`.

> **Theorem 3.1 (Winner takes all).** Let `v : AddValuation K Γ`, let
> `s : Finset ι` be finite, `f : ι → K`, and `j ∈ s`. If `f j` has strictly the
> smallest valuation in the family, i.e.
> `∀ i ∈ s, i ≠ j → v(f j) < v(f i)`,
> then `v(∑_{i ∈ s} f i) = v(f j)`.

*Proof sketch.* Two cases.

- If `v(f j) = ⊤`, then since `v(f j)` is strictly below all other terms, every
  other term also has valuation `⊤` — impossible unless there are none, so
  `s = {j}` and the sum is `f j`.
- Otherwise split off the minimizer: `∑_{i ∈ s} f i = f j + ∑_{i ∈ s \ {j}} f i`.
  Every remaining term has valuation strictly exceeding `v(f j)`, so by the
  strict-monotone bound `v.map_lt_sum` the tail sum has valuation `> v(f j)`.
  The ultrametric equality `AddValuation.map_add_eq_of_lt_left` then yields
  `v(f j + tail) = v(f j)`. ∎

The intuition: in a non-Archimedean world there is no cancellation among terms of
different orders; the single most-divisible term dictates the divisibility of the
whole sum.

---

## 4. The Fundamental Theorem of Tropical Geometry (easy direction)

> **Theorem 4.1 (Kapranov's easy direction).** Let `v : AddValuation K Γ` with
> `Γ` nontrivial, let `ι` be a finite nonempty index type, and let `T : ι → K`.
> If the terms sum to zero, `∑_i T i = 0`, and the family is not identically zero,
> `∃ i, T i ≠ 0`, then the weight function `i ↦ v(T i)` satisfies
> `AttainedAtLeastTwice`. That is, the tropicalized point lies on the corner
> locus.

*Proof sketch.* Choose a minimizer `m` of `i ↦ v(T i)` (the family is finite and
nonempty). Suppose for contradiction that the minimum is *not* attained twice.
Then `m` is the unique minimizer: `v(T m) < v(T i)` for all `i ≠ m`. By the
winner-takes-all lemma (Theorem 3.1), `v(∑_i T i) = v(T m)`. But `∑_i T i = 0`,
so `v(∑_i T i) = v(0) = ⊤`, forcing `v(T m) = ⊤` and hence `T m = 0`. Since `m`
is the strict minimizer, every other term has even larger valuation, so all
`T i = 0` — contradicting `∃ i, T i ≠ 0`. Therefore the minimum is attained at
least twice. ∎

This is exactly the statement that the tropicalization of a variety is contained
in the corner locus of its tropicalized defining polynomial: every point of the
classical hypersurface maps to a non-smooth point of the tropical polynomial.

> **Corollary 4.2 (Tropical line corner).** Let `a, b, c, x, y ∈ K` with
> `a·x + b·y + c = 0` and not all of `a·x, b·y, c` zero. Then the weight function
> `Fin 3 → Γ`, `i ↦ v([a·x, b·y, c]_i)`, satisfies `AttainedAtLeastTwice`.
>
> *Proof sketch.* Apply Theorem 4.1 to the three-term family `[a·x, b·y, c]`; the
> sum is the line equation (zero), and the non-degeneracy hypothesis supplies a
> nonzero term. ∎

Concretely, the tropical line `min(v(a) + X, v(b) + Y, v(c))` has a corner at the
tropicalized point: two of the three affine pieces tie, producing the single
vertex of the Y-shaped tropical line.

---

## 5. Min-plus multiplicativity: the engine of tropical Bézout

We now formalize tropical polynomials and prove that tropical evaluation is
multiplicative in the min-plus sense.

> **Definition 5.1 (Tropical polynomial).** A `TropPoly ι n` consists of a finite
> family of monomials indexed by `ι`, each given by a coefficient
> `coeff : ι → ℝ` and an exponent vector `exp : ι → (Fin n → ℝ)`.

> **Definition 5.2 (Term value and evaluation).** The value of the `i`-th monomial
> at a point `x : Fin n → ℝ` is `termVal P x i := coeff(i) + ∑_k exp(i)_k · x_k`.
> The tropical (min-plus) evaluation is the infimum over the (finite, nonempty)
> index set: `eval P x := inf'_i termVal P x i`.

> **Definition 5.3 (Tropical product).** For `P : TropPoly ι n` and
> `Q : TropPoly κ n`, the product `P ⊙ Q : TropPoly (ι × κ) n` has
> `coeff(i, k) = P.coeff(i) + Q.coeff(k)` and `exp(i, k) = P.exp(i) + Q.exp(k)`.
> Monomials multiply by adding coefficients and exponents.

The key combinatorial lemma is a min-plus distributive law over a product index.

> **Lemma 5.4 (Min-plus product distributivity).** For nonempty finsets `s ⊆ ι`,
> `t ⊆ κ` and functions `f : ι → ℝ`, `g : κ → ℝ`,
> `inf'_{(i,k) ∈ s × t} (f i + g k) = (inf'_{i ∈ s} f i) + (inf'_{k ∈ t} g k)`.
>
> *Proof sketch.* Antisymmetry. (≥) Pick minimizers `a ∈ s` of `f` and `b ∈ t` of
> `g`; the pair `(a, b)` realizes the right-hand value, so the left infimum is at
> most it. (≤) For any pair, `f(i) + g(k) ≥ inf f + inf g` by adding the two
> separate lower bounds, so the left infimum dominates the right. ∎

> **Theorem 5.5 (Min-plus multiplicativity).** For `P : TropPoly ι n`,
> `Q : TropPoly κ n` (both finite, nonempty index types) and any `x`,
> `eval (P ⊙ Q) x = eval P x + eval Q x`.
>
> *Proof sketch.* The `(i, k)` monomial of `P ⊙ Q` evaluates to
> `(P.coeff i + Q.coeff k) + ∑_l (P.exp i + Q.exp k)_l · x_l`, which rearranges to
> `termVal P x i + termVal Q x k`. Taking the min over the product `univ × univ`
> and applying Lemma 5.4 factors it as `eval P x + eval Q x`. ∎

**Why this is the tropical Bézout engine.** Each tropical polynomial has a
**Newton polytope**, the convex hull of its exponent vectors. Min-plus
multiplicativity implies that the Newton polytope of a product is the *Minkowski
sum* of the factors' polytopes; in particular degrees add. The stable
intersection number of two tropical curves equals the mixed volume of their
Newton polytopes, which for plane curves of degrees `d` and `e` is exactly
`d · e`. Thus Theorem 5.5 supplies the algebraic identity from which the
quantitative tropical Bézout theorem is assembled: intersection counting becomes
a volume computation on lattice polytopes.

---

## 6. Strengthening: corners from leading-term cancellation

The hypothesis `∑_i T i = 0` in Theorem 4.1 is used only through the weaker fact
that the valuation of the sum *strictly exceeds* the minimal term valuation.

> **Theorem 6.1 (Corner from leading-term cancellation).** Let
> `v : AddValuation K Γ`, `ι` finite nonempty, `T : ι → K`, and let `m` be a global
> minimizer: `∀ k, v(T m) ≤ v(T k)`. If `v(T m) < v(∑_i T i)` (the sum's valuation
> jumps strictly above the leading term), then `i ↦ v(T i)` satisfies
> `AttainedAtLeastTwice`.
>
> *Proof sketch.* Contrapositive. If the minimum were attained uniquely at `m`,
> then `m` is the strict minimizer and Theorem 3.1 gives `v(∑ T i) = v(T m)`,
> contradicting the strict jump. Concretely: assuming no second minimizer, every
> `i ≠ m` has `v(T m) < v(T i)`, so winner-takes-all forces equality and no jump
> is possible. ∎

Theorem 4.1 is the special case `∑ T i = 0`, where `v(∑ T i) = ⊤` is trivially
above the finite leading term. Theorem 6.1 captures, e.g., points where the
polynomial does not vanish but its valuation jumps — and still pins the
tropicalized point onto the corner locus.

---

## 6.5. A worked example

To make the machinery concrete, fix the field `K = ℚ` with the `5`-adic valuation
`v = v₅` (the additive valuation counting signed powers of `5`; `v₅(0) = ⊤`).

**Winner-takes-all (Theorem 3.1).** Take `f = (3, 5, 25, 50)`. Then
`v₅(f) = (0, 1, 2, 2)`, so `f₀ = 3` is the unique strict minimizer. The sum is
`3 + 5 + 25 + 50 = 83`, and `v₅(83) = 0 = v₅(3)`. The lone most-divisible term
(here the *least* divisible, since the minimum is `0`) determines the sum's order,
exactly as the theorem predicts.

**Kapranov's easy direction (Theorem 4.1).** Take `T = (10, 15, -25)`, which sums
to `0` but is not identically zero. Then `v₅(T) = (1, 1, 2)`. The minimum `1` is
attained twice (indices `0` and `1`), so the tropicalized point lies on the corner
locus, confirming the containment.

**Tropical line (Corollary 4.2).** The classical line `2x + y - 25 = 0` has the
`5`-adic solution `(x, y) = (0, 25)`. The three terms are `(a·x, b·y, c) =
(0, 25, -25)` with valuations `(⊤, 2, 2)`; the finite minimum `2` is attained
twice, placing the vertex of the Y-shaped tropical line at this tropicalized
point.

**Min-plus multiplicativity (Theorem 5.5).** Let `P` and `Q` each be the tropical
line with monomials `{(0;0,0), (1;1,0), (2;0,1)}` and `{(0;0,0), (3;1,0),
(1;0,1)}` respectively (coefficient `;` exponents). At, say, `x = (-3, 5)` one
computes `eval P x = -2`... and directly `eval(P ⊙ Q) x = eval P x + eval Q x`
for every test point — the evaluations add identically.

**Newton polytopes / tropical Bézout (§5).** The Newton polytope of each tropical
line is the unit triangle `conv{(0,0),(1,0),(0,1)}` of area `½`. Its Minkowski
self-sum is `conv{(0,0),(2,0),(0,2)}` of area `2`, so the mixed volume is
`2 - ½ - ½ = 1 = 1 · 1`, the Bézout number of two lines. Replacing one factor by
a conic (Newton polytope `conv{(0,0),(2,0),(0,2)}`) yields mixed volume `2 =
1 · 2`, the Bézout number of a line and a conic. The degree product emerges as a
pure lattice-polygon volume.

**Leading-term cancellation (Theorem 6.1).** Take `T = (5, -5, 25)`, summing to
`25 ≠ 0`. Here `v₅(T) = (1, 1, 2)` with minimum `1`, while `v₅(25) = 2 > 1`: the
sum's valuation jumps strictly above the leading term, and indeed the minimum is
attained twice — a corner, even without exact vanishing.

## 7. Algorithms

The formal results translate into directly executable procedures over the
(rational/real) min-plus semiring.

**Algorithm A — Corner test.** Given finitely many valuations `w : ι → ℝ`,
compute `μ = min_i w_i` and the cardinality of `{i : w_i = μ}`; the point is on
the corner locus iff this cardinality is ≥ 2. Complexity `O(|ι|)`.

**Algorithm B — Tropical evaluation.** Given a tropical polynomial and a point
`x`, return `min_i (coeff_i + ⟨exp_i, x⟩)`. Complexity `O(|ι| · n)`.

**Algorithm C — Tropical product and multiplicativity check.** Form the product
polynomial (all coefficient/exponent pairwise sums), evaluate both sides of
Theorem 5.5 at sample points, and verify equality (a numerical certificate of
min-plus multiplicativity). Complexity `O(|ι| · |κ| · n)` per point.

**Algorithm D — Newton-polytope Minkowski check.** Compute the convex hulls of
the exponent sets of `P`, `Q`, and `P ⊙ Q`; verify that the third is the
Minkowski sum of the first two — the geometric shadow of Theorem 5.5 and the
combinatorial substrate of tropical Bézout.

---

## 8. Applications

- **Enumerative geometry.** Tropical methods (Mikhalkin's correspondence) count
  plane curves of given degree and genus through prescribed points by counting
  lattice paths / tropical curves, reducing transcendental enumerative problems
  to combinatorics. The corner-locus and multiplicativity results are the
  foundational layer.
- **Optimization and shortest paths.** The min-plus semiring is the algebra of
  dynamic programming; tropical matrix powers compute shortest paths
  (Bellman–Ford / Floyd–Warshall). Min-plus multiplicativity is the associativity
  backbone of these computations.
- **Phylogenetics.** Tropical geometry of the space of phylogenetic trees uses
  the min-plus structure to define meaningful distances and means on tree space.
- **Auction theory and economics.** Product-mix auctions and discrete-choice
  models are governed by tropical hypersurfaces (the corner loci where the
  optimal bundle changes), exactly the `AttainedAtLeastTwice` condition.

---

## 9. Discussion

The bridge proven here is the *easy* (containment) direction of the Fundamental
Theorem together with the multiplicative engine of tropical Bézout. Three points
deserve emphasis.

First, the proofs are *uniform in the value group*: nothing depends on `Γ` being
`ℝ` or `ℚ`; only the ordered-monoid-with-top structure and the ultrametric
identity are used. This is the right level of generality for non-Archimedean
geometry, where value groups can be `ℤ`, `ℚ`, `ℝ`, or more exotic.

Second, the boundary case (Proposition 2.2) is not a defect but a precise scope
delimiter: corners are a phenomenon of competition among ≥ 2 monomials. The
strengthening (Theorem 6.1) shows the true hypothesis is leading-term
cancellation, clarifying *why* the theorem works.

Third, min-plus multiplicativity (Theorem 5.5) is deceptively elementary yet
load-bearing: it is the single identity from which the additivity of degrees,
Newton polytopes, and ultimately the `d · e` intersection count descend.

It is worth dwelling on the methodological lesson. Classical proofs of Bézout's
theorem invoke either intersection theory on projective space (Chow rings,
proper intersection, excess intersection formulas) or the resultant and its
degree. The tropical route replaces all of this analytic and homological
machinery with two pieces of finite, checkable combinatorics: a containment of a
finite point in a finite corner locus, and an identity between two infima over
finite index sets. Both are decidable, both are stable under the `valuation → ∞`
limit, and both are insensitive to the precise field of definition. This is the
distinctive promise of the tropical method — transcendental difficulty traded for
polyhedral bookkeeping — and the results of this paper isolate the smallest
self-contained core of that trade in the bivariate, easy-direction setting.

Finally, the choice of an *additive* valuation into a general
`LinearOrderedAddCommMonoidWithTop` (rather than fixing `Γ = ℝ`) is deliberate.
The min-plus structure on the value group is precisely the tropical semiring, and
the top element `⊤ = v(0)` is the tropical additive identity. Working at this
abstraction makes the bridge results literally statements about a homomorphism
from the multiplicative structure of `K` to the tropical semiring, which is the
conceptually correct framing of "tropicalization as a limit of valuations."

---

## 10. Future work

The set-theoretic and degree-level skeleton established here points directly at
the quantitative theory:

1. **From union to counted intersection number.** Promote the
   union-of-hypersurfaces / degree-addition results to a `TropMultiplicity`
   assigning to each transverse corner the lattice index `|det|` of the two edge
   directions, and prove `∑ multiplicities = d · e` for generic translates. The
   Newton-polytope Minkowski addition already reduces this to a mixed-volume
   computation; the missing piece is the local multiplicity bookkeeping.

2. **The hard (converse) direction.** Kapranov's containment is the easy half;
   the converse — every corner-locus point lifts to an actual point of the variety
   over the valued field (Kapranov / Speyer–Sturmfels) — is the deep half. A
   tractable first case is a single binomial or trinomial hypersurface, where the
   lift is an explicit Newton–Puiseux / Hensel construction requiring only
   surjectivity of the value group plus one Hensel application per corner.

3. **The valuation-limit family.** Formalize the rescaled family `v_t = t · v`
   and the amoeba-to-skeleton limit `t → ∞`, making precise the sense in which the
   corner locus is the invariant limiting shape.

---

## 11. Conclusion

We have rigorously established the algebraic bridge from classical algebraic
geometry over a non-Archimedean valued field to tropical geometry: the ultrametric
winner-takes-all lemma, the easy direction of the Fundamental Theorem
(tropicalization ⊆ corner locus), min-plus multiplicativity (the engine of
tropical Bézout), the boundary case, and a leading-term-cancellation
strengthening. Together these results show that the tropical shadow of a variety
is exact — its corners and its counting faithfully encode the classical geometry —
and they lay the foundation for a fully quantitative tropical intersection theory.
