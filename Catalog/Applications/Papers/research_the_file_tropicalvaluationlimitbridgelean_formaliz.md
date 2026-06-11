# Functoriality of the Tropical Corner Locus: Scale Invariance, the Union Law, and the Easy Half of Kapranov's Theorem

## Abstract

We develop a self-contained, machine-checked account of the *easy direction* of the
Fundamental Theorem of Tropical Geometry together with the structural functoriality
of the tropical corner locus. The bridge between classical algebraic geometry over a
non-Archimedean valued field and tropical geometry is built from a single primitive,
an additive valuation `v : K → Γ ∪ {∞}`, read as a tropicalization map. The
technical core is an *ultrametric winner-takes-all lemma*: a finite sum whose minimal
term valuation is attained uniquely has the valuation of that term. Its immediate
corollary is Kapranov's easy direction — tropicalizing a point of a classical
hypersurface lands it on the corner locus — and a strengthening replacing "the sum
vanishes" by "the sum's valuation jumps." We then prove three functoriality results
about the corner-locus predicate `AttainedAtLeastTwice`. First, **scale equivariance**:
the corner locus is invariant under positive rescaling of all weights, so the rescaled
valuation family `v_t = t·v` shares one fixed tropical shape, making the "`t → ∞`
limit" an algebraic homothety rather than an analytic set-limit. Second, the
**corner-of-a-separated-sum law**: the minimum of `(i,k) ↦ f(i)+g(k)` is attained at
least twice iff one of `f`, `g` has its minimum attained at least twice, because the
joint minimizer set is the product of the two minimizer sets. Third, the **union law**
`V(P ⊙ Q) = V(P) ∪ V(Q)` for tropical hypersurfaces, the analytic engine of tropical
Bézout, obtained by combining the separated-sum law with min-plus multiplicativity
`eval(P ⊙ Q) = eval(P) + eval(Q)`. All results are formalized; the prose below states
each theorem with its full mathematical content and a proof sketch.

**Keywords.** tropical geometry, non-Archimedean valuation, Kapranov's theorem,
corner locus, tropical hypersurface, min-plus algebra, tropical Bézout, ultrametric.

## 1. Introduction

Tropical geometry replaces the field operations `(+, ×)` by the min-plus semiring
operations `(min, +)`. Under this dictionary, polynomials become piecewise-linear
convex functions, and algebraic varieties become polyhedral complexes. The
foundational link between the classical and tropical worlds is the *tropicalization*
of a variety via a non-Archimedean valuation, and the foundational theorem — the
Fundamental Theorem of Tropical Geometry — asserts that this tropicalization coincides
with the corner locus of the tropicalized defining polynomial. The theorem has two
directions of very different character:

- the **easy direction** (Kapranov): the tropicalization is *contained* in the corner
  locus; and
- the **hard direction**: the corner locus is *contained* in the tropicalization,
  which requires lifting tropical points to classical ones (Newton polygon + Hensel).

This paper formalizes the easy direction and, more importantly, isolates the
*functorial* structure that governs how the corner locus interacts with the algebraic
operations of rescaling and multiplication. The central conceptual claim is that a
single combinatorial predicate — "the minimum is attained at least twice" — is
preserved by positive scaling and transforms predictably under separated sums, and
that these two facts are the pointwise reasons behind the geometric slogans
"tropicalization is the `t → ∞` limit" and "the tropical hypersurface of a product is
the union of hypersurfaces."

### 1.1 Contributions

1. A clean, order-theoretic formulation of the corner locus via the predicate
   `AttainedAtLeastTwice` (Definition 2.1), with the degenerate boundary case
   (Proposition 2.2).
2. The ultrametric winner-takes-all lemma for additive valuations (Theorem 3.1) and
   Kapranov's easy direction (Theorem 3.2), with a concrete instance for lines
   (Corollary 3.3) and a strengthening to leading-term cancellation (Theorem 3.4).
3. Min-plus multiplicativity of tropical evaluation (Theorem 4.3) via min-plus
   distributivity (Lemma 4.2).
4. **New functoriality results:** scale equivariance (Theorem 5.1), the
   corner-of-a-separated-sum law (Theorem 5.2), the monomial split for products
   (Lemma 5.3), and the union law `V(P ⊙ Q) = V(P) ∪ V(Q)` (Theorem 5.4).

## 2. The corner locus predicate

We work with an arbitrary index type `ι` and a linearly ordered codomain.

**Definition 2.1 (Corner locus / attained at least twice).**
Let `α` be a linear order and `w : ι → α`. We say `w` *attains its minimum at least
twice*, written `AttainedAtLeastTwice w`, if
> there exist `i, j` with `i ≠ j`, `∀ k, w(i) ≤ w(k)`, and `∀ k, w(j) ≤ w(k)`.

That is, two distinct indices are simultaneously global minima. Geometrically, when
`w(i) = c_i + ⟨a_i, x⟩` ranges over the affine pieces of a tropical polynomial, this
is exactly the condition that the piecewise-linear function `x ↦ min_i w(i)` is
non-smooth (has a corner) — the defining minimum is realized by two distinct
monomials.

**Proposition 2.2 (Boundary case).** If `ι` is a subsingleton (has at most one
element), then `¬ AttainedAtLeastTwice w` for every `w`.

*Proof sketch.* A witness requires `i ≠ j`, but any two elements of a subsingleton
are equal, contradicting `i ≠ j`. ∎

Thus a single-monomial tropical polynomial defines a globally smooth (affine-linear)
function with empty corner locus; the bridge theorem genuinely requires at least two
monomials.

## 3. The ultrametric bridge

Fix a field `K` and a linearly ordered additive commutative monoid-with-top `Γ`
(the value group augmented by `⊤ = ∞`). An *additive valuation* `v : AddValuation K Γ`
satisfies `v(0) = ⊤`, `v(1) = 0`, `v(xy) = v(x) + v(y)`, and the ultrametric
inequality `v(x + y) ≥ min(v(x), v(y))`.

**Theorem 3.1 (Winner-takes-all).**
Let `s` be a finite index set, `f : ι → K`, and `j ∈ s` a distinguished index with
> `v(f(j)) < v(f(i))` for every `i ∈ s` with `i ≠ j`.

Then `v(∑_{i ∈ s} f(i)) = v(f(j))`.

*Proof sketch.* If `v(f(j)) = ⊤`, then strict minimality forces every other term to
have valuation `> ⊤`, impossible, so `s = {j}` and the sum is `f(j)`. Otherwise split
the sum as `f(j) + ∑_{i ∈ s \ {j}} f(i)`. Every remaining term has valuation strictly
larger than `v(f(j))`, so the ultrametric "many-term" strict inequality gives
`v(∑_{i ≠ j} f(i)) > v(f(j))`. The two-term addition rule
`v(a + b) = v(a)` when `v(a) < v(b)` then yields `v(f(j) + ∑_{i≠j} f(i)) = v(f(j))`.
∎

This is the additive analogue of the classical multiplicative statement
`Valuation.map_sum_eq_of_lt`. Its essential consequence is the contrapositive: the
valuation of a sum can exceed the minimal term valuation *only when the minimum is
attained at least twice* — cancellation requires a tie.

**Theorem 3.2 (Kapranov, easy direction).**
Let `ι` be finite and nonempty, `Γ` nontrivial, and `T : ι → K`. If
> `∑_i T(i) = 0` and `∃ i, T(i) ≠ 0`,

then `AttainedAtLeastTwice (fun i ↦ v(T(i)))`.

*Proof sketch.* Let `m` minimize `i ↦ v(T(i))`. Suppose for contradiction the minimum
is attained only at `m`; then `v(T(m)) < v(T(i))` for all `i ≠ m`. By Theorem 3.1,
`v(∑_i T(i)) = v(T(m))`. But `∑_i T(i) = 0`, so `v(∑_i T(i)) = v(0) = ⊤`, forcing
`v(T(m)) = ⊤`. Since `T` is not identically zero, some `T(i) ≠ 0`; combined with
`v(T(m)) = ⊤` being the *minimum*, every term then has valuation `⊤`, i.e. every term
is `0` — contradicting `∃ i, T(i) ≠ 0`. Hence the minimum is attained at least twice.
∎

Interpreted geometrically: a point on the classical hypersurface `{∑_i T_i = 0}` (the
`T_i` being the monomials of a polynomial evaluated at the point) tropicalizes to a
point of the tropical hypersurface (corner locus). This is exactly the inclusion
`trop(V(f)) ⊆ corner-locus(trop f)`.

**Corollary 3.3 (Tropical line).**
For `a, b, c, x, y ∈ K` with `a·x + b·y + c = 0` and `(a·x, b·y, c)` not all zero, the
weight vector `(v(a·x), v(b·y), v(c))` attains its minimum at least twice; i.e. the
tropical line `min(v(a)+X, v(b)+Y, v(c))` has a corner at the tropicalized point.

*Proof sketch.* Apply Theorem 3.2 to the three-term family `T = (a·x, b·y, c)` over
`ι = Fin 3`. The sum is the line equation; nonvanishing of one term is the
nondegeneracy hypothesis. ∎

**Theorem 3.4 (Leading-term cancellation strengthening).**
Let `ι` be finite nonempty, `T : ι → K`, and `m` an index with `∀ k, v(T(m)) ≤ v(T(k))`.
If
> `v(T(m)) < v(∑_i T(i))`,

then `AttainedAtLeastTwice (fun i ↦ v(T(i)))`.

*Proof sketch.* Contrapositively, suppose the minimum is attained uniquely. Then
`m` is the strict minimizer, and Theorem 3.1 gives `v(∑_i T(i)) = v(T(m))`,
contradicting the strict jump `v(T(m)) < v(∑_i T(i))`. Concretely one produces a
second minimizer `j ≠ m` with `v(T(j)) ≤ v(T(m))` whenever the strict-jump hypothesis
holds. ∎

Theorem 3.2 is the special case where the sum is `0`, so its valuation is `⊤`, the
maximal possible jump. The strengthening shows that *only* the jump above the minimum
matters, not literal vanishing.

## 4. Min-plus multiplicativity

We now formalize tropical polynomials and their product.

**Definition 4.1 (Tropical polynomial).**
A *tropical polynomial* in `n` variables indexed by `ι` is a pair
`P = (coeff : ι → ℝ, exp : ι → (Fin n → ℝ))`. Its `i`-th *term value* at `x : Fin n → ℝ`
is
> `termVal_P(x, i) = coeff_P(i) + ∑_{k} exp_P(i, k) · x_k`,

an affine-linear function of `x`. The *tropical evaluation* (for `ι` finite nonempty)
is `eval_P(x) = min_{i} termVal_P(x, i)`. The *tropical product* of `P` (indexed by
`ι`) and `Q` (indexed by `κ`) is the polynomial `P ⊙ Q` indexed by `ι × κ` with
> `coeff_{P⊙Q}(i,k) = coeff_P(i) + coeff_Q(k)`,
> `exp_{P⊙Q}(i,k) = exp_P(i) + exp_Q(k)`.

This is exactly classical monomial multiplication read through the min-plus
dictionary: exponents add, coefficients add.

**Lemma 4.2 (Min-plus distributivity).**
For finite nonempty `s ⊆ ι`, `t ⊆ κ`, and `f : ι → ℝ`, `g : κ → ℝ`,
> `min_{(i,k) ∈ s × t} (f(i) + g(k)) = (min_{i ∈ s} f(i)) + (min_{k ∈ t} g(k))`.

*Proof sketch.* `≤`: pick coordinatewise minimizers `a ∈ s`, `b ∈ t`; then
`(a,b) ∈ s × t` realizes the right side as a member of the left. `≥`: every pair
`(i,k)` satisfies `f(i) ≥ min f` and `g(k) ≥ min g`, so their sum is bounded below by
the right side. Antisymmetry concludes. ∎

**Theorem 4.3 (Min-plus multiplicativity).**
For finite nonempty `ι, κ` and any `x`,
> `eval_{P ⊙ Q}(x) = eval_P(x) + eval_Q(x)`.

*Proof sketch.* Expanding `termVal_{P⊙Q}(x, (i,k))` via Definition 4.1 distributes
the inner product to give exactly `termVal_P(x,i) + termVal_Q(x,k)`. Minimizing over
the product index set and applying Lemma 4.2 separates the minimum into the sum of the
two evaluations. ∎

This is the analytic engine of tropical Bézout: tropical multiplication corresponds to
adding evaluations, hence adding Newton polytopes, hence adding degrees.

## 5. Functoriality of the corner locus (new results)

We now establish the structural properties that make the corner-locus predicate a
*functorial* object: invariant under rescaling and compatible with products.

**Theorem 5.1 (Scale equivariance).**
For any `t ∈ ℝ` with `t > 0` and any `w : ι → ℝ`,
> `AttainedAtLeastTwice (fun i ↦ t · w(i)) ↔ AttainedAtLeastTwice w`.

*Proof sketch.* Both directions transport the minimality clauses across the order
equivalence `t · a ≤ t · b ↔ a ≤ b`, valid since `t > 0` (multiplication by a positive
scalar is strictly monotone). The witnessing pair `(i, j)` and the inequality `i ≠ j`
are unchanged; only the comparisons are rescaled. Forward: from `t·w(i) ≤ t·w(k)`
divide by `t`. Backward: from `w(i) ≤ w(k)` multiply by `t ≥ 0`. ∎

*Significance.* Rescaling a valuation `v ↦ t·v` rescales all weights by `t`, so the
entire family `v_t = t·v` (`t > 0`) has *identical* corner loci up to overall zoom. The
classical slogan "tropicalization is the limit of `v_t` as `t → ∞`" is therefore not an
analytic limit of moving sets but an algebraic homothety invariance: every member of
the family already exhibits the same tropical silhouette.

**Theorem 5.2 (Corner of a separated sum).**
Let `ι`, `κ` be finite and nonempty, `f : ι → ℝ`, `g : κ → ℝ`. Then
> `AttainedAtLeastTwice (fun (i,k) ↦ f(i) + g(k)) ↔ AttainedAtLeastTwice f ∨ AttainedAtLeastTwice g`.

*Proof sketch.*
(⇐) If `f` has distinct minimizers `i ≠ j`, fix any minimizer `k₀` of `g` (exists by
finiteness/nonemptiness). Then `(i, k₀)` and `(j, k₀)` are distinct joint minimizers of
`f + g`, since `f(i)+g(k₀) ≤ f(i')+g(k')` for all `(i',k')` by adding the two
coordinate inequalities. Symmetrically if `g` is the one with a repeated minimizer.

(⇒) Let `p ≠ q` be distinct joint minimizers of `(i,k) ↦ f(i)+g(k)`. Holding one
coordinate fixed shows each projection is a coordinate minimizer: `p.1, q.1` minimize
`f` and `p.2, q.2` minimize `g`. Since `p ≠ q`, the two points differ in at least one
coordinate. If they differ in the first coordinate, `p.1 ≠ q.1` are distinct minimizers
of `f`, giving `AttainedAtLeastTwice f`; if they differ in the second, we get
`AttainedAtLeastTwice g`. ∎

This is the precise combinatorial statement that *the joint minimizer set is the
Cartesian product of the coordinate minimizer sets*, and a product set is non-trivial
(has two distinct elements) iff one factor is.

**Lemma 5.3 (Monomial split for products).**
For tropical polynomials `P` (indexed by `ι`) and `Q` (indexed by `κ`), every `x` and
every pair `p = (i,k)`,
> `termVal_{P ⊙ Q}(x, p) = termVal_P(x, p.1) + termVal_Q(x, p.2)`.

*Proof sketch.* Substitute the product coefficients and exponents from Definition 4.1
and distribute the inner product over the sum of exponent vectors; rearranging gives
the sum of the two term values. ∎

**Definition 5.4 (Tropical hypersurface).**
For a tropical polynomial `P` in `n` variables, the *tropical hypersurface*
(corner locus) is
> `V(P) = { x ∈ ℝⁿ : AttainedAtLeastTwice (fun i ↦ termVal_P(x, i)) }`,

the set of points where the defining minimum is attained by at least two monomials.

**Theorem 5.5 (Union law).**
For finite nonempty `ι, κ`,
> `V(P ⊙ Q) = V(P) ∪ V(Q)`.

*Proof sketch.* Fix `x`. By Lemma 5.3 the term-value function of `P ⊙ Q` at `x` is the
separated sum `(i,k) ↦ termVal_P(x,i) + termVal_Q(x,k)`. By Theorem 5.2 its minimum is
attained at least twice iff the minimum of `termVal_P(x, ·)` is, or that of
`termVal_Q(x, ·)` is — i.e. iff `x ∈ V(P)` or `x ∈ V(Q)`. ∎

*Significance.* The corner set of a tropical product is the *overlay* of the corner
sets of the factors. Together with min-plus multiplicativity (Theorem 4.3) this is the
analytic half of tropical Bézout: degrees add under multiplication, and the
intersection of two tropical curves is realized inside the union of their corner loci.
Pairing this union law with the combinatorial lattice count of crossing multiplicities
yields a complete degree statement; this paper supplies the analytic half cleanly.

## 6. Algorithms

The constructive content of the corner-locus theory yields three direct algorithms;
full pseudocode and code appear in the accompanying package.

**6.1 Corner detection.** Given weights `w : ι → ℝ`, compute `m = min_i w(i)` and the
set `A = { i : w(i) = m }` (with a tolerance for floating point). Then
`AttainedAtLeastTwice w ↔ |A| ≥ 2`. Complexity `O(|ι|)` time, `O(1)` extra space (two
passes or one pass with running count of ties).

**6.2 Tropical evaluation and product.** Tropical evaluation is a single min over `|ι|`
affine forms, `O(n · |ι|)`. The tropical product expands to `|ι| · |κ|` monomials whose
coefficients and exponents are the pairwise sums; evaluating the product directly versus
summing the factor evaluations gives a runtime witness of Theorem 4.3.

**6.3 Hypersurface membership and the union law.** To test `x ∈ V(P ⊙ Q)`, one may
either expand the product (cost `O(n · |ι| · |κ|)`) and run corner detection, or invoke
the union law and test `x ∈ V(P)` *or* `x ∈ V(Q)` separately (cost `O(n(|ι| + |κ|))`).
The union law is therefore not only structurally clarifying but computationally cheaper.

## 7. Applications

- **Tropical Bézout.** The union law plus min-plus multiplicativity reduce the
  intersection of plane tropical curves to the overlay of their corner loci; combined
  with a lattice-index count of crossings, the number of stable intersection points of
  curves of degrees `d₁, d₂` is `d₁ · d₂`.
- **Amoeba degeneration.** Scale equivariance formalizes the limiting shape of amoebas
  under `v_t = t·v`: the normalized tropical skeleton is the fixed point of the
  rescaling family, not a moving target.
- **Solving systems over valued fields.** Kapranov's easy direction constrains the
  possible valuations of solutions of polynomial systems to the corner loci, a
  combinatorial pre-filter for root location (the lifting converse refines this to
  exactness).

## 8. Discussion

The unifying observation is that one predicate, "the minimum is attained at least
twice," is the carrier of all structure here. Winner-takes-all says cancellation in a
valued sum requires a tie; Kapranov's easy direction reads that off geometrically;
scale equivariance says ties are invariant under positive rescaling; and the union law
says a tie in a separated sum is a tie in one summand. The corner locus is, literally,
the *tie set*, and every operation on tropical hypersurfaces is an operation on tie
sets. The valuation map is consequently a tropical semiring "morphism up to ties": it
is exactly multiplicative (`v(xy) = v(x)+v(y)`) and exactly additive
(`v(x+y) = min(v(x), v(y))`) except on the diagonal tie locus `{v(x) = v(y)}`, where the
ultrametric inequality may be strict — and that defect locus is precisely the corner
phenomenon driving Kapranov's theorem.

## 9. Future work

- **Kapranov's hard direction.** Lift a corner-locus point to a classical root via a
  Newton-polygon / Hensel argument; formalize the univariate case first, where the
  Newton polygon is the lower convex hull of `{(i, v(c_i))}`.
- **The limit as a genuine limit.** Upgrade scale equivariance to Hausdorff
  convergence of normalized amoebas to the tropical variety on compact windows.
- **Stable intersection / full Bézout.** Glue the union law to a lattice mixed-index
  count to obtain an end-to-end tropical Bézout theorem connecting the analytic
  (min-plus) and combinatorial (Newton polytope) descriptions.
- **Balancing as conservation.** Show the primitive edge directions at a corner,
  weighted by lattice length, sum to zero, exhibiting the tie set as the vertex set of
  a balanced fan.
- **Bundled tropical morphism.** Package `x ↦ v(x)` as a `Tropical`-valued semiring
  homomorphism-up-to-defect, with defect locus equal to the diagonal tie set, so that
  classical algebraic identities transport automatically to tropical inequalities.

## 10. Conclusion

We have given a fully verified treatment of the easy direction of the Fundamental
Theorem of Tropical Geometry and of the functoriality of the corner locus: it is
invariant under positive rescaling and behaves as a "support of a sum of corners"
under tropical multiplication, yielding the union law `V(P ⊙ Q) = V(P) ∪ V(Q)`. The
recurring engine is the ultrametric principle that cancellation forces a tie, and the
recurring object is the tie set itself, organized into tropical geometry. These results
clear the analytic obstacles on both the Bézout and limit sides, leaving the lifting
converse of Kapranov as the principal open frontier.
