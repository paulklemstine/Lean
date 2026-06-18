# An Information-Geometric Bridge: The Fisher Metric and a Two-Sided KL Sandwich on the Finite Simplex

## Abstract

We develop, and machine-verify, the elementary differential geometry of the
finite categorical statistical model and connect it to the
Kullback–Leibler (KL) divergence through an exact, non-infinitesimal,
two-sided estimate. Working on the open probability simplex over a finite
index set `ι`, we define the **Fisher information form**
`g_p(v, w) = Σᵢ vᵢ wᵢ / pᵢ` on tangent vectors and prove that it is a bona
fide Riemannian metric: symmetric, bilinear, positive-semidefinite, and
positive-definite. We identify the Pearson χ² divergence with the Fisher
quadratic form at the displacement vector,
`χ²(p ‖ q) = g_q(p − q, p − q)`, and establish the **KL sandwich**
`0 ≤ KL(p ‖ q) ≤ χ²(p ‖ q) = g_q(p − q, p − q)` for all strictly positive
normalized distributions. The lower bound is Gibbs' inequality; the upper
bound realizes the classical folklore "the Fisher metric is the Hessian of
KL" as a genuinely global inequality. Both directions descend from a single
elementary lemma, `log y ≤ y − 1`. We isolate the precise role of the
normalization constraint (the upper bound is false without it) and document
why no termwise comparison yields the result. Finally, we state the missing
lower half of an idealized sandwich — Pinsker's inequality
`½(Σᵢ|pᵢ − qᵢ|)² ≤ KL(p ‖ q)` — as a precise open conjecture, and describe
a factored-derivative proof strategy for its Bernoulli base case together
with a coarse-graining reduction for the general case. All proved statements
have been formally verified in the Lean 4 proof assistant.

**Keywords.** Information geometry, Fisher information metric, Kullback–Leibler
divergence, χ² divergence, Gibbs' inequality, Pinsker's inequality,
statistical manifold, formal verification.

---

## 1. Introduction

Information geometry studies families of probability distributions as
differentiable manifolds equipped with a canonical Riemannian structure, the
**Fisher information metric**. Two foundational facts are usually quoted as
folklore: (i) the Fisher metric is the unique (up to scale) Riemannian metric
invariant under sufficient statistics (Čencov's theorem), and (ii) the Fisher
metric is the Hessian of the KL divergence at coincidence, so that
infinitesimally `KL(p ‖ p + dv) ≈ ½ g_p(dv, dv)`.

Statement (ii) is invariably presented as a *local* (second-order Taylor)
fact. The contribution of this work is to upgrade it, in the finite
categorical setting, to a *global*, exact inequality that requires no
infinitesimal approximation, and to do so with a fully machine-checked proof
that depends on nothing beyond the scalar inequality `log y ≤ y − 1`.

We work entirely over the **finite categorical model**: distributions are
functions `p : ι → ℝ` for a finite index type `ι`, with `pᵢ > 0` and
`Σᵢ pᵢ = 1`. Tangent vectors `v : ι → ℝ` are unconstrained directions of
variation (informally, those summing to zero, though our metric lemmas do not
require this). This is the simplest nontrivial statistical manifold — the
interior of the standard simplex `Δ^{|ι|−1}` — and it already exhibits the
full interplay among three classical divergences: KL, Pearson χ², and total
variation.

### Contributions

1. A complete, verified proof that the Fisher form `g_p` is a Riemannian
   metric (Section 3): symmetry, bilinearity, positive-semidefiniteness, and
   positive-definiteness.
2. The exact identity `χ²(p ‖ q) = g_q(p − q, p − q)` (Section 4),
   identifying the statistician's chi-squared divergence with the geometer's
   quadratic form.
3. The **KL sandwich** `0 ≤ KL(p ‖ q) ≤ χ²(p ‖ q)` (Section 5), with both
   directions reduced to `log y ≤ y − 1`, and a precise account of the role
   of normalization.
4. A formal statement of the Pinsker lower bound as an open conjecture
   (Section 6), with a detailed factored-derivative strategy for the
   Bernoulli base case and a coarse-graining reduction to it.

---

## 2. Definitions

Let `ι` be a finite type and let `p, q, v, w : ι → ℝ`. Sums `Σᵢ` range over
all of `ι`.

**Definition 2.1 (Fisher information form).**
For a base point `p` with positive entries, the Fisher information form
evaluated on tangent vectors `v, w` is
> `fisherForm p v w := Σᵢ (vᵢ · wᵢ) / pᵢ`.

This is the Gram form of the score vectors of the categorical family
`p(x; θ) = θ_x`: the score with respect to coordinate `i` is `∂ᵢ log p = δ/p`,
so `Σₓ p(x) ∂ᵥ log p(x) ∂_w log p(x) = Σᵢ vᵢ wᵢ / pᵢ`.

**Definition 2.2 (Kullback–Leibler divergence).**
> `klDiv p q := Σᵢ pᵢ · log(pᵢ / qᵢ)`.

**Definition 2.3 (Pearson χ² divergence).**
> `chiSquared p q := Σᵢ (pᵢ − qᵢ)² / qᵢ`.

**Standing hypotheses.** Unless stated otherwise, `pᵢ > 0` and `qᵢ > 0` for
all `i`, and `Σᵢ pᵢ = Σᵢ qᵢ = 1`. The metric results of Section 3 use only
positivity of the base point; the KL sandwich of Section 5 uses positivity
and normalization of both `p` and `q`.

---

## 3. The Fisher form is a Riemannian metric

A Riemannian metric on each tangent space is a symmetric, bilinear,
positive-definite form. We verify each axiom.

**Theorem 3.1 (Symmetry).** For all `p, v, w`,
> `fisherForm p v w = fisherForm p w v`.

*Proof.* Termwise, `vᵢ wᵢ / pᵢ = wᵢ vᵢ / pᵢ` by commutativity of
multiplication; sum over `i`. ∎

**Theorem 3.2 (Additivity in the first argument).** For all `p, u, v, w`,
> `fisherForm p (u + v) w = fisherForm p u w + fisherForm p v w`.

*Proof.* `((uᵢ + vᵢ) wᵢ)/pᵢ = uᵢ wᵢ/pᵢ + vᵢ wᵢ/pᵢ` by distributivity, then
split the sum. ∎

**Theorem 3.3 (Homogeneity in the first argument).** For all scalars `c` and
all `p, v, w`,
> `fisherForm p (c • v) w = c · fisherForm p v w`.

*Proof.* `((c vᵢ) wᵢ)/pᵢ = c · (vᵢ wᵢ/pᵢ)`; factor `c` out of the sum. ∎

Theorems 3.1–3.3 (together with symmetry, which transfers linearity to the
second slot) establish that `fisherForm p` is a symmetric bilinear form.

**Theorem 3.4 (Positive-semidefiniteness).** If `pᵢ > 0` for all `i`, then
> `0 ≤ fisherForm p v v`.

*Proof.* Each summand `vᵢ²/pᵢ` is a nonnegative number (square) divided by a
positive number, hence nonnegative; a sum of nonnegative terms is
nonnegative. ∎

**Theorem 3.5 (Positive-definiteness).** If `pᵢ > 0` for all `i`, then
> `fisherForm p v v = 0` ⟺ `v = 0`.

*Proof.* By Theorem 3.4 the sum is a sum of nonnegative terms, so it vanishes
iff every term `vᵢ²/pᵢ` vanishes. Since `pᵢ > 0`, this forces `vᵢ² = 0`,
i.e. `vᵢ = 0` for every `i`, i.e. `v = 0`. The converse is immediate. ∎

**Corollary 3.6.** For each base point `p` in the open simplex, `fisherForm p`
is an inner product on the tangent space `ℝ^ι`. Consequently the open
probability simplex is a Riemannian manifold with metric `g_p = fisherForm p`.

Note that only `pᵢ > 0` is needed for the geometric axioms; the normalization
`Σ pᵢ = 1` plays no role here. The geometry is defined on the whole positive
orthant and restricts to the simplex.

---

## 4. The χ² divergence is the Fisher quadratic form

**Theorem 4.1 (χ²–Fisher identity).** For all `p, q`,
> `chiSquared p q = fisherForm q (p − q) (p − q)`.

*Proof.* Expanding the right-hand side termwise,
`fisherForm q (p − q)(p − q) = Σᵢ (pᵢ − qᵢ)(pᵢ − qᵢ)/qᵢ
= Σᵢ (pᵢ − qᵢ)²/qᵢ = chiSquared p q`,
using `(pᵢ − qᵢ)(pᵢ − qᵢ) = (pᵢ − qᵢ)²`. ∎

Theorem 4.1 is the conceptual hinge of the paper: the Pearson statistic and
the Fisher metric are literally the same object, the former being the squared
Fisher length of the displacement arrow `p − q` measured at the base point
`q`.

---

## 5. The KL sandwich

The engine of this section is the following elementary scalar inequality,
the only nontrivial analytic input to the entire development.

**Lemma 5.1 (Tangent-line bound for `log`).** For every `y > 0`,
> `log y ≤ y − 1`,
with equality iff `y = 1`.

*Proof.* The function `y ↦ y − 1 − log y` has derivative `1 − 1/y`, which is
negative on `(0, 1)` and positive on `(1, ∞)`, so the function attains its
global minimum `0` at `y = 1`. (In the formal development this is
`Real.log_le_sub_one_of_pos`.) ∎

**Theorem 5.2 (Gibbs' inequality — lower bound).** If `pᵢ, qᵢ > 0` and
`Σᵢ pᵢ = Σᵢ qᵢ = 1`, then
> `0 ≤ klDiv p q`.

*Proof.* Apply Lemma 5.1 with `y = qᵢ/pᵢ` to obtain
`log(qᵢ/pᵢ) ≤ qᵢ/pᵢ − 1`, i.e. `−log(pᵢ/qᵢ) ≤ qᵢ/pᵢ − 1`, hence
`pᵢ(1 − qᵢ/pᵢ) ≤ pᵢ log(pᵢ/qᵢ)`. Summing over `i`,
`Σᵢ pᵢ(1 − qᵢ/pᵢ) = Σᵢ (pᵢ − qᵢ) = 1 − 1 = 0`, so
`0 ≤ Σᵢ pᵢ log(pᵢ/qᵢ) = klDiv p q`. ∎

**Theorem 5.3 (Bridge — upper bound).** If `pᵢ, qᵢ > 0` and
`Σᵢ pᵢ = Σᵢ qᵢ = 1`, then
> `klDiv p q ≤ fisherForm q (p − q) (p − q)  (= chiSquared p q)`.

*Proof.* Apply Lemma 5.1 with `y = pᵢ/qᵢ`:
`log(pᵢ/qᵢ) ≤ pᵢ/qᵢ − 1`. Multiply by `pᵢ > 0` and sum:
`klDiv p q = Σᵢ pᵢ log(pᵢ/qᵢ) ≤ Σᵢ pᵢ(pᵢ/qᵢ − 1)`.
Now expand the right-hand side termwise using the algebraic identity
`pᵢ(pᵢ/qᵢ − 1) = (pᵢ − qᵢ)²/qᵢ + (pᵢ − qᵢ)`, valid for `qᵢ > 0`:
`Σᵢ pᵢ(pᵢ/qᵢ − 1) = Σᵢ (pᵢ − qᵢ)²/qᵢ + Σᵢ (pᵢ − qᵢ)
= chiSquared p q + (1 − 1) = chiSquared p q`,
and by Theorem 4.1 this equals `fisherForm q (p − q)(p − q)`. ∎

**Corollary 5.4 (KL sandwich).** Under the standing hypotheses,
> `0 ≤ klDiv p q ≤ chiSquared p q = fisherForm q (p − q)(p − q)`.

### 5.1 The role of normalization

The normalization `Σ pᵢ = Σ qᵢ = 1` is *essential* to Theorem 5.3 and is the
precise point where a naive termwise comparison fails. There is **no**
termwise inequality `pᵢ log(pᵢ/qᵢ) ≤ (pᵢ − qᵢ)²/qᵢ`; the cross term
`(pᵢ − qᵢ)` produced by the algebraic identity is individually nonzero and
only the *aggregate* `Σᵢ(pᵢ − qᵢ)` vanishes, thanks to normalization. Drop
the constraint `Σ pᵢ = Σ qᵢ` and the `−1` terms no longer cancel, so the
bound `KL ≤ χ²` becomes false. By contrast, the metric axioms of Section 3
are purely pointwise and need only `pᵢ > 0`. This dichotomy — geometry is
local, the KL bridge is global — is the central structural lesson of the
development.

---

## 6. The missing floor: Pinsker's inequality (open conjecture)

The sandwich of Corollary 5.4 bounds KL above by the χ²/Fisher quadratic form
and below by zero. A sharper floor would bound KL below by a true symmetric
distance, the **total-variation distance**. Recall `TV(p, q) = ½ Σᵢ|pᵢ − qᵢ|`.

**Conjecture 6.1 (Pinsker).** Under the standing hypotheses,
> `½ · (Σᵢ |pᵢ − qᵢ|)² ≤ klDiv p q`,
equivalently `2 · TV(p, q)² ≤ klDiv p q`.

This statement is recorded in our formal development with its proof deferred
(a `sorry` marking the open frontier). Combined with Theorem 5.3 it would
yield the idealized two-sided clamp
> `½ (Σᵢ|pᵢ − qᵢ|)² ≤ klDiv p q ≤ chiSquared p q`,
squeezing KL between the L¹ (total-variation) world below and the χ²/Fisher
world above. We outline the standard route to a proof.

### 6.1 The Bernoulli base case via a factored derivative

The irreducible core of Pinsker is the two-outcome case. Write
`klBer p q = p log(p/q) + (1 − p) log((1 − p)/(1 − q))` for the KL divergence
between Bernoulli laws `Ber(p)` and `Ber(q)` with `p, q ∈ (0, 1)`.

**Lemma 6.2 (Bernoulli Pinsker, target).** For `p, q ∈ (0, 1)`,
> `2 (p − q)² ≤ klBer p q`.

*Strategy.* Fix `p` and define the gap `g(q) = klBer p q − 2(p − q)²`. Then
`g(p) = 0`, and a direct computation gives the **factored derivative**
> `g′(q) = (q − p) · (1 − 2q)² / (q(1 − q))`.

The denominator `q(1 − q) > 0` on `(0, 1)`, and the factor `(1 − 2q)²` is a
perfect square, hence `≥ 0`. Therefore `sign g′(q) = sign(q − p)`: `g` is
decreasing for `q < p` and increasing for `q > p`, so `q = p` is the unique
global minimizer with value `g(p) = 0`. Hence `g(q) ≥ 0` for all `q`, which
is the claim. This route avoids convex duality entirely; the single
observation that the quadratic factor is a perfect square does all the work.

A cautionary note recorded in the development: the gap `g` is **not convex**
in `q` (its second derivative is not sign-definite), so monotonicity of `g′`
— not convexity — is the correct tool.

### 6.2 Reduction of the general case by coarse-graining

The general Conjecture 6.1 reduces to Lemma 6.2 by the data-processing
(log-sum) inequality applied to an optimally chosen binary partition.

**Lemma 6.3 (Log-sum / data-processing inequality).** For nonnegative reals
`a₁,…,aₙ` and positive `b₁,…,bₙ`,
> `(Σ aᵢ) · log((Σ aᵢ)/(Σ bᵢ)) ≤ Σᵢ aᵢ log(aᵢ/bᵢ)`,
which follows from Jensen's inequality applied to the convex function
`x ↦ x log x`.

*Reduction.* Let `A = { i : qᵢ ≤ pᵢ }` and `Aᶜ` its complement. Set
`P_A = Σ_{i ∈ A} pᵢ`, `Q_A = Σ_{i ∈ A} qᵢ`, and similarly on `Aᶜ`. Two
applications of Lemma 6.3 (one on `A`, one on `Aᶜ`) give
`klBer(P_A ‖ Q_A) ≤ klDiv p q` — the projection onto the single binary event
`A` cannot increase divergence. The choice of `A` as the set where `q`
underestimates `p` makes the projection *tight* for total variation: one
checks `P_A − Q_A = TV(p, q) = ½ Σᵢ|pᵢ − qᵢ|`. Applying Lemma 6.2 to the
Bernoulli pair `(P_A, Q_A)` then yields
`2 TV(p, q)² = 2 (P_A − Q_A)² ≤ klBer(P_A ‖ Q_A) ≤ klDiv p q`,
which is Conjecture 6.1. The deep point is that *optimal coarse-graining
makes data-processing tight*: a generically lossy projection becomes lossless
when the partition is chosen to align with the sign of `p − q`. ∎

---

## 7. Applications

**7.1 Natural-gradient optimization.** Training a probabilistic model
minimizes `θ ↦ KL(p_data ‖ p_θ)`. Natural-gradient descent preconditions the
Euclidean gradient by the inverse Fisher metric `g_p⁻¹`, performing steepest
descent in the geometry of Section 3 rather than in coordinates. Corollary
5.4 certifies that the local quadratic model `½ g_q(p − q, p − q)` used to
motivate the method is a genuine global *upper* bound on the objective, not
merely a Taylor approximation.

**7.2 Hypothesis testing and confidence regions.** The identity
`χ² = g_q(p − q, p − q)` (Theorem 4.1) places Pearson's classical test inside
the Riemannian picture: χ² confidence ellipsoids are Fisher-metric balls.
The bound `KL ≤ χ²` shows likelihood-ratio (KL-based) regions are contained
in the corresponding χ² regions.

**7.3 Cryptographic and learning guarantees.** A proved Pinsker inequality
(Conjecture 6.1) is the standard conversion from an information bound
`KL ≤ ε` to an indistinguishability bound `TV ≤ √(ε/2)`, used in
chosen-plaintext-attack security reductions and in PAC-Bayes generalization
bounds. The sandwich `½TV² ≤ KL ≤ χ²` would let practitioners certify TV
distance both from above (via the easily computed χ²) and from below (via
KL), bracketing the operationally meaningful distance.

---

## 8. Discussion

The development demonstrates that a substantial slice of information geometry
— enough to ground natural-gradient methods and to relate the three workhorse
divergences — rests on remarkably shallow analytic foundations: commutativity
and distributivity for the metric axioms, and a single tangent-line bound
`log y ≤ y − 1` for the entire KL sandwich. The deliberate finiteness of the
index set keeps every step constructive and machine-checkable while losing
none of the conceptual content; the categorical model is the universal local
chart for any smooth statistical family.

The sharpest methodological takeaway concerns *where* the difficulty lives.
The geometric axioms are termwise and local. The KL bridge, by contrast, is
irreducibly global: it is false termwise and becomes true only after
summation under normalization. The same theme governs the Pinsker frontier,
where the general inequality is not termwise either, and the proof must pass
through an *aggregation* — the coarse-graining of Section 6.2 — that turns a
binary base case into a statement about arbitrarily many outcomes. Optimal
coarse-graining making data-processing tight is a reusable design pattern,
applicable well beyond Pinsker.

---

## 9. Future work

1. **Discharge Conjecture 6.1** by formalizing Lemmas 6.2 and 6.3 along the
   factored-derivative and log-sum routes described above, completing the
   two-sided clamp `½TV² ≤ KL ≤ χ²`.
2. **Beyond the categorical model.** Extend the metric construction to
   exponential families, where the Fisher form is the Hessian of the
   log-partition function, and seek analogous global sandwiches.
3. **Affine connections and dual flatness.** Add the exponential and mixture
   connections to upgrade the Riemannian manifold to a dually flat structure
   (Amari–Nagaoka), enabling the generalized Pythagorean theorem for KL
   projections.
4. **Quantitative coarse-graining.** Formalize the tightness criterion of
   Section 6.2 as a standalone result on when data-processing is lossless.
5. **Downstream certificates.** Use a verified Pinsker inequality to
   machine-check end-to-end CPA-security and PAC-Bayes generalization bounds.

---

## Appendix: Summary of formally verified statements

| Result | Statement | Status |
|---|---|---|
| `fisherForm_symm` | `g_p(v,w) = g_p(w,v)` | proved |
| `fisherForm_add_left` | `g_p(u+v,w) = g_p(u,w)+g_p(v,w)` | proved |
| `fisherForm_smul_left` | `g_p(c•v,w) = c·g_p(v,w)` | proved |
| `fisherForm_nonneg` | `0 ≤ g_p(v,v)` for `p>0` | proved |
| `fisherForm_eq_zero_iff` | `g_p(v,v)=0 ↔ v=0` for `p>0` | proved |
| `chiSquared_eq_fisher` | `χ²(p‖q) = g_q(p−q,p−q)` | proved |
| `klDiv_nonneg` | `0 ≤ KL(p‖q)` (Gibbs) | proved |
| `klDiv_le_fisher` | `KL(p‖q) ≤ g_q(p−q,p−q)` (bridge) | proved |
| `klDiv_ge_half_tv_sq` | `½(Σ|pᵢ−qᵢ|)² ≤ KL(p‖q)` (Pinsker) | conjecture |

All "proved" rows are checked in Lean 4 / Mathlib. The single nontrivial
analytic dependency is `Real.log_le_sub_one_of_pos` (Lemma 5.1).
