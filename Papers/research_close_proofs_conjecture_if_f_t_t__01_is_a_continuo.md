# Tropicalization as the Image of a Non-Archimedean Valuation: A Formal Bridge to the Corner Locus

## Abstract

We develop, from first principles, the bridge connecting classical algebraic geometry
over a non-Archimedean valued field to its piecewise-linear tropical counterpart. The
organizing object is an additive valuation `v : K → Γ ∪ {∞}`, read as a tropicalization
map sending a field element to its order in a linearly ordered value group. From the
ultrametric law alone we derive a *winner-takes-all* lemma — the valuation of a finite
sum equals that of a strictly unique minimal term — and read it backwards to obtain the
**easy direction of the Fundamental Theorem of Tropical Geometry** (Kapranov): every
point of a classical hypersurface tropicalizes onto the corner locus of the associated
tropical polynomial, i.e. the tropicalized minimum is attained at least twice. We
isolate a strictly more general *leading-term cancellation* criterion of which Kapranov's
statement is the `v(∑)=∞` special case, record the boundary degeneracy (a single
monomial has empty corner locus), and instantiate the theorem for the classical line.
On the multiplicative side we define tropical polynomials and their min-plus evaluation,
establish a min-plus distributive law, and prove **min-plus multiplicativity**:
evaluation carries tropical products to ordinary sums of evaluations — the combinatorial
engine behind degree additivity and the tropical Bézout theorem. All results are
established with complete rigor.

**Keywords:** tropical geometry, non-Archimedean valuation, ultrametric inequality,
Kapranov's theorem, corner locus, tropical hypersurface, min-plus algebra, tropical
Bézout, Newton polytope.

---

## 1. Introduction

Tropical geometry studies the piecewise-linear images of algebraic varieties under a
"logarithm at infinite base," replacing multiplication by addition and addition by
minimum. The bridge to classical geometry is supplied by a non-Archimedean valuation,
which is simultaneously (i) a measurement of size obeying an ultrametric inequality and
(ii) a homomorphism from a field to a min-plus semiring. The Fundamental Theorem of
Tropical Geometry (Kapranov; Speyer–Sturmfels) asserts that the tropicalization of a
variety coincides with the corner locus of the tropicalized defining equations. Its
"easy" containment — tropicalized points lie on the corner locus — is purely a
consequence of the ultrametric inequality and is the centerpiece of this work.

This paper assembles a self-contained chain of results, beginning from the abstract
notion of an additive valuation into a linearly ordered commutative monoid with a top
element, and culminating in two complementary structural theorems: the corner-locus
containment (additive/equational side) and min-plus multiplicativity (multiplicative
side). We have taken care to identify the exact hypothesis each result needs, to expose
the boundary degeneracies, and to extract the most general statement the proof supports.

### 1.1 Conventions and the algebraic setting

Throughout, `K` is a field. The value structure `Γ` is a `LinearOrderedAddCommMonoidWithTop`:
a commutative monoid with a compatible linear order and a top element `⊤` that is
absorbing for `+` and maximal for `≤`. An **additive valuation** `v : AddValuation K Γ`
is a map `K → Γ` satisfying
- `v 0 = ⊤`, `v 1 = 0`,
- `v (x · y) = v x + v y` (multiplicativity becomes additivity in `Γ`), and
- `v (x + y) ≥ min(v x, v y)` (the **ultrametric / non-Archimedean inequality**).

The element `⊤` plays the role of "+∞": only `0` attains it (for a genuine valuation),
and it is the maximal value. The intuition `v x =` "order of vanishing / divisibility"
makes `⊤ = v 0` the maximal divisibility. We frequently require `Γ` to be `Nontrivial`
(`⊤ ≠ 0`), which excludes the trivial valuation collapsing all units to a point.

---

## 2. The corner locus predicate

The geometric target of tropicalization is the *corner locus*: the non-smooth locus of
the piecewise-linear function obtained by taking a minimum of affine pieces. A point lies
on it precisely when the minimum is achieved by two distinct pieces.

> **Definition 2.1 (Attained at least twice / corner locus).**
> For a linear order `α` and a weight family `w : ι → α`, we say `w` *attains its
> minimum at least twice*, written `AttainedAtLeastTwice w`, if
> $$ \exists\, i \neq j,\quad (\forall k,\ w_i \le w_k)\ \wedge\ (\forall k,\ w_j \le w_k). $$
> That is, there are two distinct indices, each a global minimum.

Geometrically, where the minimum is attained uniquely the tropical polynomial is locally
affine (smooth); where it is attained twice or more the graph creases — a *corner*. The
corner locus is the tropical hypersurface.

> **Theorem 2.2 (Boundary degeneracy: single monomial has empty corner locus).**
> If `ι` is a subsingleton (`Subsingleton ι`), then `¬ AttainedAtLeastTwice w` for every
> `w`.
>
> *Proof.* A witness requires distinct `i ≠ j`, but in a subsingleton every two elements
> are equal, contradicting `i ≠ j`. ∎

Theorem 2.2 records that the corner phenomenon is intrinsically about competition between
at least two monomials: a one-term tropical polynomial is globally smooth.

---

## 3. The ultrametric winner-takes-all lemma

The technical core is a strengthening of the ultrametric inequality to equality under a
*strict* minimum, generalized from two summands to a finite family. It is the additive
analogue of the multiplicative-valuation lemma `Valuation.map_sum_eq_of_lt`.

> **Theorem 3.1 (Unique strict minimum determines the sum).**
> Let `v : AddValuation K Γ`, let `s` be a finite index set, `f : ι → K`, and `j ∈ s`.
> Suppose `j` is the *strict* minimizer of the valuation:
> $$ \forall i \in s,\ i \neq j \ \Rightarrow\ v(f_j) < v(f_i). $$
> Then
> $$ v\Big( \sum_{i \in s} f_i \Big) = v(f_j). $$

**Proof sketch.** Two cases on whether the champion's value is `⊤`.

1. *If `v(f_j) = ⊤`.* Since `v(f_j)` is strictly below all other terms, those others
   would have to exceed `⊤`, impossible (`⊤` is maximal). Hence there are no other
   indices: `s = {j}`, and the sum is the single term `f_j`, giving the result
   immediately.

2. *If `v(f_j) ≠ ⊤`.* Split off the champion:
   `∑_{i∈s} f_i = f_j + ∑_{i ∈ s∖{j}} f_i`. Every remaining term has valuation strictly
   above `v(f_j)`, so the residual sum has valuation strictly above `v(f_j)` as well
   (an iterated application of the strict ultrametric bound, `v.map_lt_sum`). Adding a
   term of strictly smaller valuation to one of strictly larger valuation leaves the
   smaller value unchanged (`AddValuation.map_add_eq_of_lt_left`): the total valuation
   equals `v(f_j)`. ∎

The lemma converts a *strict order condition* on inputs into an *exact equation* on the
output. Its contrapositive is what powers the geometry: if the output valuation is *not*
equal to the smallest input valuation, the minimum cannot be strict.

---

## 4. Kapranov's theorem: tropicalization lands on the corner locus

We now read Theorem 3.1 backwards. Vanishing of a sum forces a tie in the minimum.

> **Theorem 4.1 (Easy direction of the Fundamental Theorem of Tropical Geometry,
> Kapranov).**
> Let `Γ` be nontrivial, `ι` a finite nonempty index type, `v : AddValuation K Γ`, and
> `T : ι → K`. If
> $$ \sum_{i} T_i = 0 \qquad\text{and}\qquad \exists\, i,\ T_i \neq 0, $$
> then `AttainedAtLeastTwice (fun i ↦ v(T_i))`: the tropicalized weights attain their
> minimum at least twice.

**Proof sketch.** Let `m` be an index achieving the minimal valuation (exists by
finiteness and nonemptiness). Suppose, for contradiction, the minimum is *not* attained
twice. Then `m` is in fact the *unique strict* minimizer: for `i ≠ m`, the inequality
`v(T_m) ≤ v(T_i)` cannot be an equality (else `i` and `m` would both be minima, a
double-attainment), so `v(T_m) < v(T_i)`. By Theorem 3.1,
`v(∑_i T_i) = v(T_m)`. But `∑_i T_i = 0`, and `v(0) = ⊤`, so `v(T_m) = ⊤`. Now take any
nonzero term `T_i` (it exists by hypothesis); a nonzero element has valuation `≠ ⊤`,
yet `v(T_m) = ⊤` is the *minimum*, forcing all values — including the finite one — to be
`⊤`, a contradiction with nontriviality. Hence the minimum is attained at least twice. ∎

The statement is exactly the set-theoretic containment
`trop(V(f)) ⊆ cornerLocus(trop f)` evaluated pointwise: a classical point of the
hypersurface `{∑ Tᵢ = 0}` tropicalizes onto the tropical hypersurface.

### 4.1 The classical line

> **Corollary 4.2 (Tropical line corner).**
> Let `Γ` be nontrivial, `v : AddValuation K Γ`, and `a, b, c, x, y ∈ K`. If
> `a·x + b·y + c = 0` and not all three terms are degenerate
> (`a·x ≠ 0 ∨ b·y ≠ 0 ∨ c ≠ 0`), then the three weights
> `v(a·x), v(b·y), v(c)` attain their minimum at least twice.
>
> *Proof.* Apply Theorem 4.1 to `T = (a·x, b·y, c) : Fin 3 → K`. The hypothesis
> `a·x + b·y + c = 0` is exactly `∑_{i:Fin 3} T_i = 0`, and the disjunction supplies the
> required nonzero term. ∎

This is the prototypical picture: a classical line maps onto the tropical line, the
"Y"-shaped union of three rays, with every classical point landing on a ray or the
trivalent vertex.

### 4.2 Strengthening: leading-term cancellation

The proof of Theorem 4.1 used `∑ Tᵢ = 0` only through the weaker fact `v(∑ Tᵢ) > v(T_m)`.
Isolating this yields a strictly more general criterion, valid without nontriviality and
without the equation being homogeneous.

> **Theorem 4.3 (Corner from leading-term cancellation).**
> Let `v : AddValuation K Γ`, `ι` finite nonempty, `T : ι → K`, and let `m` achieve the
> minimum valuation, `∀ k, v(T_m) ≤ v(T_k)`. If
> $$ v(T_m) < v\Big( \sum_i T_i \Big) $$
> then `AttainedAtLeastTwice (fun i ↦ v(T_i))`.

**Proof sketch.** By contraposition. Assume the minimum is *not* attained twice. We show
`v(∑ Tᵢ) ≤ v(T_m)` (negating the jump). It suffices to exhibit no second minimizer, i.e.
to show `m` is the strict minimizer; then Theorem 3.1 gives `v(∑ Tᵢ) = v(T_m)`. If some
`j ≠ m` satisfied `v(T_j) ≤ v(T_m)`, then combined with minimality `v(T_m) ≤ v(T_j)` we
would get equality, making `j` a second global minimum — a double attainment, excluded.
Hence `m` is the unique strict minimizer and `v(∑ Tᵢ) = v(T_m)`, contradicting the
assumed jump. ∎

Theorem 4.1 is the special case `∑ Tᵢ = 0`, whence `v(∑ Tᵢ) = ⊤ > v(T_m)`. The general
form detects *any* anomalous increase in valuation under summation — any cancellation of
leading terms — as a corner, even at points where the polynomial does not vanish.

---

## 5. Min-plus algebra and the multiplicative bridge

The second pillar concerns the multiplicative structure carried across the bridge. We
work over the min-plus semiring `(ℝ, min, +)`: tropical addition is `min`, tropical
multiplication is ordinary `+`.

### 5.1 Tropical polynomials and evaluation

> **Definition 5.1 (Tropical polynomial).**
> A *tropical polynomial* `P` in `n` variables, indexed by a type `ι`, is a pair
> - `coeff : ι → ℝ` (the tropical coefficients), and
> - `exp : ι → (Fin n → ℝ)` (the exponent vector of each monomial).

> **Definition 5.2 (Monomial value).**
> The value of the `i`-th monomial at a tropical point `x : Fin n → ℝ` is the affine
> functional
> $$ \mathrm{termVal}_P(x, i) = \mathrm{coeff}_i + \sum_{k} \mathrm{exp}_{i,k}\, x_k = \mathrm{coeff}_i + \langle \mathrm{exp}_i, x\rangle. $$

> **Definition 5.3 (Tropical evaluation).**
> For `ι` finite and nonempty, the *tropical evaluation* of `P` at `x` is the minimum
> over monomials:
> $$ \mathrm{eval}_P(x) = \min_{i \in \iota} \ \mathrm{termVal}_P(x, i). $$
> A tropical polynomial is thus the lower envelope of finitely many affine functions: a
> concave (in the min-convention, piecewise-linear) function whose non-smooth locus is
> precisely the corner locus of §2.

> **Definition 5.4 (Tropical product).**
> The *tropical product* `P ⊙ Q` of `P : TropPoly ι n` and `Q : TropPoly κ n` is
> indexed by `ι × κ` with
> $$ \mathrm{coeff}_{(i,k)} = \mathrm{coeff}^P_i + \mathrm{coeff}^Q_k, \qquad \mathrm{exp}_{(i,k)} = \mathrm{exp}^P_i + \mathrm{exp}^Q_k. $$
> Monomials multiply by adding coefficients and exponents — the min-plus reflection of
> classical monomial multiplication.

### 5.2 The min-plus distributive law

> **Lemma 5.5 (Separated minimum factors).**
> Let `s ⊆ ι`, `t ⊆ κ` be nonempty finite sets, `f : ι → ℝ`, `g : κ → ℝ`. Then
> $$ \min_{(i,k) \in s \times t} \big( f_i + g_k \big) = \Big( \min_{i \in s} f_i \Big) + \Big( \min_{k \in t} g_k \Big). $$

**Proof sketch.** Both inequalities. (≤) Choose minimizers `a` of `f` over `s` and `b`
of `g` over `t`; the pair `(a,b)` realizes the right-hand side as a value of the
left-hand objective, so the left-hand minimum is no larger. (≥) For any pair `(i,k)`,
`f_i ≥ min f` and `g_k ≥ min g`, so `f_i + g_k ≥ min f + min g`; taking the minimum over
pairs preserves the bound. ∎

This is the optimization truism that independent choices optimize independently, and it
is exactly the distributivity of `+` over `min` in product form.

### 5.3 Min-plus multiplicativity

> **Theorem 5.6 (Min-plus multiplicativity).**
> For tropical polynomials `P : TropPoly ι n`, `Q : TropPoly κ n` (with `ι, κ` finite
> nonempty) and any `x : Fin n → ℝ`,
> $$ \mathrm{eval}_{P \odot Q}(x) = \mathrm{eval}_P(x) + \mathrm{eval}_Q(x). $$

**Proof sketch.** Unfolding definitions, the `(i,k)` monomial value of `P ⊙ Q` at `x`
is
$$ (\mathrm{coeff}^P_i + \mathrm{coeff}^Q_k) + \langle \mathrm{exp}^P_i + \mathrm{exp}^Q_k, x\rangle = \mathrm{termVal}_P(x,i) + \mathrm{termVal}_Q(x,k), $$
using bilinearity of the inner product (`add_mul`, `Finset.sum_add_distrib`). Hence the
evaluation of the product is the minimum over the product index set `ι × κ` of a
*separated sum*, and Lemma 5.5 factors it as `min_i termVal_P + min_k termVal_Q =
eval_P(x) + eval_Q(x)`. ∎

### 5.4 Consequence: degree additivity and tropical Bézout

Theorem 5.6 says tropical evaluation is a semiring homomorphism in the multiplicative
slot: `eval(P ⊙ Q) = eval(P) + eval(Q)`. Its structural payoff is that **Newton
polytopes add under tropical multiplication** (the support of `P ⊙ Q` is the Minkowski
sum of the supports), hence **degrees add**:
`deg(P ⊙ Q) = deg P + deg Q`. Degree additivity, combined with the corner-locus
containment of §4, is the combinatorial backbone of the **tropical Bézout theorem**: two
tropical curves of degrees `d` and `e` in the plane intersect in exactly `d·e` points
(counted with multiplicity via the balancing/stable-intersection rules). Where classical
Bézout requires projective closure and intersection theory, the tropical version reduces
to counting transversal crossings of piecewise-linear graphs.

---

## 6. Algorithms

The constructive content yields three directly implementable procedures (see the
companion `demo.py` for executable form).

**Algorithm A — Sum valuation via the unique-minimum rule.** Given a valuation oracle
`v` and terms `f₁, …, fₙ`, compute their valuations; if a unique strict minimum exists,
return it as `v(∑ fᵢ)` (Theorem 3.1); otherwise the value is undetermined by the leading
terms alone (potential cancellation). Complexity: `O(n)` valuation queries plus an `O(n)`
scan.

**Algorithm B — Corner-locus / Kapranov test.** Given `T₁, …, Tₙ`, compute `wᵢ = v(Tᵢ)`,
the minimum `μ = min wᵢ`, and the multiplicity `c = #{ i : wᵢ = μ }`. The point lies on
the corner locus iff `c ≥ 2`. For a point asserted to lie on `{∑ Tᵢ = 0}` with some
`Tᵢ ≠ 0`, Theorem 4.1 guarantees `c ≥ 2`. Complexity: `O(n)`.

**Algorithm C — Tropical evaluation and product.** Evaluate `P` at `x` by computing each
`termVal` and taking the minimum (`O(|ι|·n)`). To evaluate a product, either form the
`|ι|·|κ|` product monomials and evaluate (`O(|ι||κ|n)`) or — exploiting Theorem 5.6 —
evaluate the factors separately and add (`O((|ι|+|κ|)n)`), a quadratic-to-linear speedup
that is itself a numerical certificate of multiplicativity.

---

## 7. Applications

- **Enumerative geometry.** Corner-locus containment plus degree additivity let one
  count solutions of polynomial systems by counting intersections of tropical curves;
  this underlies tropical proofs of Bézout and of Mikhalkin's correspondence theorem for
  counting plane curves through points.
- **Computational algebra.** Tropicalization is the foundation of *tropical bases* and
  the analysis of Gröbner complexes / Newton polytopes; the unique-minimum rule is the
  workhorse for computing initial forms.
- **Optimization and scheduling.** Min-plus polynomials model shortest paths, project
  scheduling (critical-path method), and discrete-event systems; multiplicativity is the
  composition law for serial subsystems.
- **Phylogenetics and metric geometry.** Tropical convexity and the tropical Grassmannian
  parameterize phylogenetic trees; corner loci encode the combinatorial tree types.
- **Machine learning.** Networks with ReLU/maxout activations compute exactly min-plus
  (tropical) rational functions; the corner locus is the set of activation-pattern
  boundaries, and multiplicativity governs how depth composes piecewise-linear regions.

---

## 8. Discussion

The architecture exhibits a clean separation of concerns. The *additive* bridge
(Theorems 3.1, 4.1, 4.3) is a pure consequence of the ultrametric inequality and needs
nothing beyond a linearly ordered value monoid with top; the *multiplicative* bridge
(Theorems 5.5, 5.6) is a fact about min-plus envelopes of affine functions over `ℝ`.
Together they realize the valuation as a homomorphism from `(K, +, ·)` to the min-plus
semiring, sending vanishing to corners and products to sums.

Two design points merit emphasis. First, Theorem 4.3 shows the precise logical content
of Kapranov's hypothesis: only the *jump* `v(T_m) < v(∑ Tᵢ)` is used, so the corner
phenomenon is genuinely about leading-term cancellation rather than exact vanishing.
Second, Theorem 2.2 marks the boundary of the theory — the corner locus is empty for a
single monomial — clarifying that all nontrivial content requires at least two competing
terms, exactly the regime where the min-plus minimum can tie.

We proved only the *easy* containment `trop(V(f)) ⊆ cornerLocus(trop f)`. The converse
(surjectivity onto the corner locus) — the hard direction of the Fundamental Theorem,
requiring lifting/Newton-polygon arguments over algebraically closed valued fields — is
not addressed here and is the natural next target.

---

## 9. Future work

- **Hard direction of the Fundamental Theorem.** Establish surjectivity: every point of
  the corner locus is the tropicalization of an actual solution, via Hensel/Newton
  lifting over a complete algebraically closed non-Archimedean field.
- **Multiplicity and balancing.** Upgrade `AttainedAtLeastTwice` to a weighted notion
  recording the number and exponents of competing monomials, enabling a formal tropical
  Bézout count with multiplicities and the balancing condition.
- **Newton polytopes as a functor.** Formalize the support/Newton-polytope assignment and
  prove the Minkowski-sum law `Newt(P ⊙ Q) = Newt P + Newt Q` directly from Theorem 5.6,
  then derive degree additivity as a corollary.
- **The limit-of-valuations picture.** Make precise the rescaled family `v_t = t·v` as
  `t → ∞` and identify the corner-locus characterization as its invariant limiting
  shape (the "amoeba degenerates to its spine").
- **Beyond fields.** Extend the additive lemmas to valued rings and to semifields,
  isolating the minimal algebraic hypotheses for the winner-takes-all phenomenon.

---

## 10. Conclusion

Starting from the ultrametric inequality, we built a complete and rigorous passage from
classical algebra to tropical geometry: a winner-takes-all lemma for valuations, its
backward reading as Kapranov's corner-locus containment (with a sharpened leading-term
cancellation form and the single-monomial boundary case), and a min-plus
multiplicativity theorem driving degree additivity and tropical Bézout. The valuation
emerges as a faithful homomorphism to the min-plus semiring, and the corner locus as the
honest shadow on which every classical solution is guaranteed to land.
