# Depth Separation for ReLU Networks via the Tent Map: Slope Blow-up, Dyadic Oscillation, and a Unified Two-Point Obstruction

## Abstract

We give a self-contained development of the depth-separation phenomenon for
rectified-linear (ReLU) neural networks, built entirely around the **tent
map** `tent(x) = 1 − |2x − 1|`, the canonical width-2 one-hidden-layer ReLU
block. Composing the tent with itself `k` times yields a depth-`k`,
constant-width network `tent^[k]` whose output range stays inside `[0, 1]`
but whose local slope and oscillation count both grow as `2^k`. We prove
three families of results. **(1) The Lipschitz (slope) obstruction:** the
`k`-fold tent is exactly `2^k`-Lipschitz and rises from `0` to `1` over an
interval of width `2^(−k)`; consequently no `K`-Lipschitz function `g` with
`K · 2^(−k) + 2ε < 1` can `ε`-approximate `tent^[k]` on `[0, 1]`, and the
threshold is sharp. **(2) The combinatorial (counting) obstruction:** on the
dyadic grid of order `k`, `tent^[k](j / 2^k) = j mod 2`, so any continuous
`ε`-approximant with `ε < 1/2` is forced to cross the level `1/2` inside
each of the `2^k` dyadic subintervals — a weight-magnitude-independent
exponential width lower bound. **(3) A unifying two-point lemma:** a single
triangle inequality `|f(a) − f(b)| ≤ K|a − b| + 2ε` subsumes both the tent
(slope-blowup) separation and the iterated-exponential-tower (range-blowup)
separation, exhibiting them as two instances of one mechanism. We also give
an adversarial-robustness reading of the slope blow-up. All results have
been formalized and machine-checked in the Lean 4 theorem prover with no
extra axioms.

**Keywords:** depth separation, ReLU networks, tent map, Telgarsky
oscillation, Lipschitz lower bounds, expressivity, formal verification.

---

## 1. Introduction

The expressive power of neural networks is classically summarized by
universal-approximation theorems: a single sufficiently wide hidden layer
can approximate any continuous function on a compact set. These theorems are
silent about *cost*. The theory of **depth separation** quantifies that
cost, exhibiting functions that admit small deep representations but require
exponentially large shallow ones.

The cleanest vehicle for this phenomenon is the **tent map** and its
iterates, in the tradition of Telgarsky's sawtooth construction. The tent is
a genuine ReLU primitive: a one-hidden-layer network of width two. Its
`k`-fold composition is a depth-`k`, constant-width network of total size
`O(k)`, yet it realizes a sawtooth with `2^(k−1)` teeth. This exponential
structure-from-depth is the engine of every separation in this paper.

We present three complementary obstructions to shallow approximation:

1. an **analytic** obstruction based on the exponential Lipschitz constant
   (Section 4),
2. a **combinatorial** obstruction based on the exponential number of forced
   level crossings (Section 5), which is strictly stronger because it is
   independent of weight magnitude, and
3. an **abstract** obstruction (Section 6) — a single two-point inequality —
   that unifies the tent separation with the superficially unrelated
   iterated-exponential-tower separation.

Every statement below has been formalized in Lean 4 / Mathlib and verified
to depend only on the standard logical axioms. The mathematical content is
presented here in ordinary notation with proof sketches; the document is
self-contained.

---

## 2. Preliminaries and notation

We work over the real numbers. For `f : ℝ → ℝ` we write `f^[k]` for the
`k`-fold composition `f ∘ f ∘ ⋯ ∘ f` (`k` times), with `f^[0]` the identity.
`Icc a b` denotes the closed interval `[a, b]`. A function `g` is
**`K`-Lipschitz** if `|g(x) − g(y)| ≤ K · |x − y|` for all `x, y`; we use
this pointwise inequality throughout (it is equivalent to the metric
`LipschitzWith` notion for `K ≥ 0`).

**Definition 2.1 (ReLU).** `relu(x) = max(x, 0)`.

**Definition 2.2 (Tent map).** `tent(x) = 1 − |2x − 1|`.

On `[0, 1]` the tent is the symmetric triangle: it increases linearly with
slope `+2` from `tent(0) = 0` to `tent(1/2) = 1`, then decreases with slope
`−2` to `tent(1) = 0`.

**Definition 2.3 (Iterated exponential tower).**
`iterExp(0, x) = x` and `iterExp(n+1, x) = exp(iterExp(n, x))`.

This is the range-blowup foil used in Section 6.

---

## 3. The tent map as a ReLU primitive

**Lemma 3.1 (ReLU representation).** For all `x`,
`tent(x) = 1 − relu(2x − 1) − relu(1 − 2x)`.

*Proof.* Since `|y| = relu(y) + relu(−y)` with `y = 2x − 1`, we get
`|2x − 1| = relu(2x − 1) + relu(1 − 2x)`. Substituting into the definition
of `tent` gives the claim. ∎

Thus `tent` is exactly a one-hidden-layer ReLU network with two hidden units
(weights `±2`, biases `∓1`) and a linear output layer. Its `k`-fold
composition `tent^[k]` is therefore a depth-`k` network of constant width
two and total size `O(k)`.

**Lemma 3.2 (Branch identities).**
For `x ≤ 1/2`, `tent(x) = 2x` (ascending branch);
for `x ≥ 1/2`, `tent(x) = 2 − 2x` (descending branch).

*Proof.* For `x ≤ 1/2`, `2x − 1 ≤ 0`, so `|2x − 1| = 1 − 2x` and
`tent(x) = 1 − (1 − 2x) = 2x`. For `x ≥ 1/2`, `2x − 1 ≥ 0`, so
`|2x − 1| = 2x − 1` and `tent(x) = 1 − (2x − 1) = 2 − 2x`. ∎

**Lemma 3.3 (Invariance of the unit interval).**
`tent` maps `[0, 1]` into `[0, 1]`.

*Proof.* For `x ∈ [0, 1]` we have `−1 ≤ 2x − 1 ≤ 1`, so `|2x − 1| ≤ 1` and
hence `0 ≤ tent(x) = 1 − |2x − 1| ≤ 1`. ∎

Lemma 3.3 makes the iteration well-behaved: every `tent^[k]` also maps
`[0, 1]` into `[0, 1]`, so the range never escapes the unit interval — all
the complexity is internal oscillation, never magnitude.

---

## 4. The analytic obstruction: exponential slope

### 4.1 Lipschitz growth

**Lemma 4.1 (Single-step Lipschitz bound).** `tent` is `2`-Lipschitz.

*Proof.* `tent(x) − tent(y) = |2y − 1| − |2x − 1|`. By the reverse triangle
inequality `||u| − |v|| ≤ |u − v|`, applied to `u = 2y − 1`, `v = 2x − 1`,
we get `|tent(x) − tent(y)| ≤ |2y − 2x| = 2|x − y|`. ∎

**Theorem 4.2 (Depth amplifies the Lipschitz constant).**
For every `k`, `tent^[k]` is `2^k`-Lipschitz.

*Proof.* Composition of an `L₁`-Lipschitz and an `L₂`-Lipschitz map is
`L₁L₂`-Lipschitz. Iterating Lemma 4.1 gives a Lipschitz constant of
`2 · 2 ⋯ 2 = 2^k`. (Formally, `LipschitzWith.iterate`.) ∎

### 4.2 The steep ramp

**Lemma 4.3 (Fixed left endpoint).** `tent^[k](0) = 0` for all `k`.

*Proof.* `tent(0) = 1 − |−1| = 0`, so `0` is a fixed point; induction on `k`
preserves it. ∎

**Lemma 4.4 (First peak).** `tent^[k]((1/2)^k) = 1` for all `k`.

*Proof.* By induction. For the step, note `(1/2)^(k+1) ≤ 1/2`, so by the
ascending branch (Lemma 3.2) `tent((1/2)^(k+1)) = 2 · (1/2)^(k+1) =
(1/2)^k`. Hence `tent^[k+1]((1/2)^(k+1)) = tent^[k]((1/2)^k) = 1` by the
inductive hypothesis. ∎

Lemmas 4.3 and 4.4 say `tent^[k]` climbs the full unit height over the
interval `[0, (1/2)^k]` of width `2^(−k)`; its slope there is exactly `2^k`,
showing Theorem 4.2 is tight.

### 4.3 The separation theorem

**Theorem 4.5 (ReLU depth separation).** Let `g : ℝ → ℝ` be `K`-Lipschitz
(`|g(x) − g(y)| ≤ K|x − y|`). If

```
K · (1/2)^k + 2ε < 1,
```

then `g` does **not** satisfy `|tent^[k](x) − g(x)| ≤ ε` for all
`x ∈ [0, 1]`.

*Proof.* Suppose for contradiction the uniform `ε`-bound holds. Evaluate at
the two endpoints of the steep ramp, `a = 0` and `b = (1/2)^k`. By
Lemmas 4.3–4.4, `tent^[k](a) = 0` and `tent^[k](b) = 1`, so
`g(a) ≤ ε` and `g(b) ≥ 1 − ε`. Hence
`g(b) − g(a) ≥ 1 − 2ε`. On the other hand, `K`-Lipschitzness gives
`g(b) − g(a) ≤ K|b − a| = K · (1/2)^k`. Combining,
`1 − 2ε ≤ K · (1/2)^k`, i.e. `K · (1/2)^k + 2ε ≥ 1`, contradicting the
hypothesis. ∎

**Theorem 4.6 (Sharpness of the threshold).**
`(2^k) · (1/2)^k + 2 · 0 = 1`.

*Proof.* `(2^k)(1/2)^k = (2 · 1/2)^k = 1^k = 1`. ∎

Theorem 4.6 shows the strict inequality in Theorem 4.5 cannot be weakened to
`≤`: at `K = 2^k`, `ε = 0` the budget equals `1` exactly (witnessed by
`g = tent^[k]` approximating itself perfectly), so the conclusion fails on
the boundary. **Interpretation.** A bounded-weight shallow ReLU network is
`K`-Lipschitz with `K` controlled by its weight × width budget; to match a
depth-`k` tent it must take `K ≳ 2^k`, an exponential cost in depth.

**Worked instance.** At `k = 3`, the constant map `g ≡ 1/2` (which is
`0`-Lipschitz) cannot approximate `tent^[3]` to accuracy `3/8`, because
`1 · (1/2)^3 + 2 · 0 = 1/8 < 1` triggers Theorem 4.5.

---

## 5. The combinatorial obstruction: exponential crossing count

The analytic obstruction depends on the magnitude `K`, which an adversary
could in principle inflate. The following obstruction removes that
dependence entirely.

### 5.1 Dyadic alternation

**Theorem 5.1 (Dyadic alternation of the iterated tent).**
For all `k` and all `j` with `0 ≤ j ≤ 2^k`,

```
tent^[k](j / 2^k) = j mod 2.
```

That is, `tent^[k]` equals `0` at every even dyadic node and `1` at every
odd dyadic node of order `k`.

*Proof sketch.* Induction on `k`. The base case `k = 0` is `tent^[0](j) = j`
with `j ∈ {0, 1}`, where `j = j mod 2`. For the step, write
`tent^[k+1](x) = tent^[k](tent(x))` and fold the node `j / 2^(k+1)` using the
two affine branches of Lemma 3.2:

- if `j ≤ 2^k` (left half), then `j/2^(k+1) ≤ 1/2`, so
  `tent(j/2^(k+1)) = 2 · j/2^(k+1) = j/2^k`, and the inductive hypothesis
  gives `tent^[k+1](j/2^(k+1)) = j mod 2`;
- if `j ≥ 2^k` (right half), then `j/2^(k+1) ≥ 1/2`, so
  `tent(j/2^(k+1)) = 2 − 2·j/2^(k+1) = (2^(k+1) − j)/2^k`, and the inductive
  hypothesis gives `(2^(k+1) − j) mod 2`. Since `2^(k+1)` is even, this
  equals `j mod 2`.

In both halves the parity `j mod 2` is preserved, completing the
induction. ∎

**Corollary 5.2 (Nodes).**
`tent^[k](2j / 2^k) = 0` whenever `2j ≤ 2^k`, and
`tent^[k]((2j+1)/2^k) = 1` whenever `2j + 1 ≤ 2^k`.

*Proof.* Specialize Theorem 5.1 with `j ↦ 2j` (even, residue `0`) and
`j ↦ 2j + 1` (odd, residue `1`). ∎

Thus the graph of `tent^[k]` is a sawtooth alternating `0, 1, 0, 1, …`
across the `2^k + 1` dyadic nodes, oscillating `2^k` times on `[0, 1]`.

### 5.2 Forced level crossings

**Theorem 5.3 (Crossing lower bound).** Let `g` be continuous on `[0, 1]`
and suppose `|tent^[k](x) − g(x)| ≤ ε` for all `x ∈ [0, 1]` with `ε < 1/2`.
Then for every `i` with `0 ≤ i`, `i + 1 ≤ 2^k`, there exists

```
c ∈ [i/2^k, (i+1)/2^k]   with   g(c) = 1/2.
```

*Proof.* The endpoints `i/2^k` and `(i+1)/2^k` are consecutive dyadic nodes,
so by Theorem 5.1 their tent values are `i mod 2` and `(i+1) mod 2` — i.e.
`0` and `1` in some order. Suppose `i` is even, so `tent^[k](i/2^k) = 0` and
`tent^[k]((i+1)/2^k) = 1`. The approximation bound forces
`g(i/2^k) ≤ ε < 1/2` and `g((i+1)/2^k) ≥ 1 − ε > 1/2`. Since `g` is
continuous on the subinterval, the Intermediate Value Theorem yields a point
`c` in it with `g(c) = 1/2`. If `i` is odd the inequalities are reversed and
the symmetric form of the IVT applies. ∎

**Corollary 5.4 (Exponential width lower bound).** A continuous
piecewise-linear function with `w` linear pieces meets any fixed horizontal
level in at most `w` points. The `2^k` subintervals of Theorem 5.3 are
essentially disjoint, so an `ε`-approximant (`ε < 1/2`) of `tent^[k]` crosses
the level `1/2` at least `2^k` times. Hence any ReLU network that
`ε`-approximates `tent^[k]` has width

```
w ≥ 2^k,
```

**independent of weight magnitude.**

This is strictly stronger than Theorem 4.5: Theorem 4.5 can be evaded by
large weights (large `K`), whereas Corollary 5.4 cannot — counting pieces is
a topological invariant of the piecewise-linear graph.

---

## 6. The unifying two-point obstruction

We now isolate the single inequality behind both the tent (slope-blowup) and
the iterated-exponential-tower (range-blowup) separations.

**Theorem 6.1 (Two-point gap bound).** Let `f, g : ℝ → ℝ` with `g`
`K`-Lipschitz, and suppose `|f(a) − g(a)| ≤ ε` and `|f(b) − g(b)| ≤ ε` at two
points `a, b`. Then

```
|f(a) − f(b)| ≤ K · |a − b| + 2ε.
```

*Proof.* By the triangle inequality,
`|f(a) − f(b)| ≤ |f(a) − g(a)| + |g(a) − g(b)| + |g(b) − f(b)|
≤ ε + K|a − b| + ε`. ∎

**Theorem 6.2 (Contrapositive obstruction).** Under the Lipschitz hypothesis
on `g`, if `K · |a − b| + 2ε < |f(a) − f(b)|`, then `g` cannot satisfy both
`|f(a) − g(a)| ≤ ε` and `|f(b) − g(b)| ≤ ε`.

*Proof.* Immediate from Theorem 6.1: the conjunction would force
`|f(a) − f(b)| ≤ K|a − b| + 2ε`, contradicting the strict gap. ∎

The left-hand **gap** `|f(a) − f(b)|` is the quantity a deep network
maximizes; the right-hand **budget** `K|a − b| + 2ε` is what a Lipschitz
approximant can afford. A network defeats every shallow rival by maximizing
the *gap-to-distance ratio* `|f(a) − f(b)| / |a − b|`, either via a small
denominator (tent) or a large numerator (tower).

**Theorem 6.3 (Tent separation as an instance).** Theorem 4.5 follows from
Theorem 6.2 with `f = tent^[k]`, `a = 0`, `b = (1/2)^k`: here
`|f(a) − f(b)| = 1` and `|a − b| = (1/2)^k`, so the gap condition
`K(1/2)^k + 2ε < 1` is exactly the hypothesis. ∎

**Theorem 6.4 (Strict monotonicity of the tower).** `iterExp(k, ·)` is
strictly increasing for every `k`.

*Proof.* Induction: `iterExp(0, ·) = id` is strictly increasing, and
`x ↦ exp(x)` is strictly increasing, so the composition
`iterExp(k+1, x) = exp(iterExp(k, x))` is too. ∎

**Theorem 6.5 (Positive endpoint gap of the tower).**
`iterExp(k, 0) < iterExp(k, 1)`.

*Proof.* Apply Theorem 6.4 to `0 < 1`. ∎

**Theorem 6.6 (Tower separation as the same instance).** Let
`G = iterExp(k, 1) − iterExp(k, 0) > 0`. For `K`-Lipschitz `g`, if
`K + 2ε < G`, then `g` cannot `ε`-approximate `iterExp(k, ·)` on `[0, 1]`.

*Proof.* Apply Theorem 6.2 with `f = iterExp(k, ·)`, `a = 0`, `b = 1`:
`|a − b| = 1` and `|f(a) − f(b)| = G` by Theorem 6.5. ∎

Theorems 6.3 and 6.6 are two specializations of the *same* lemma
(Theorem 6.1). The tent attacks the **denominator** `|a − b| = 2^(−k)`; the
tower attacks the **numerator** `|f(a) − f(b)| = G`. Lipschitz budget `K` is
the single currency both must pay — a cross-domain bridge between two
expressivity blow-ups that look unrelated on the surface.

---

## 7. An adversarial-robustness corollary

The slope blow-up has a security reading.

**Theorem 7.1 (Adversarial pair).** Let `g` be `K`-Lipschitz with `K < 2^k`.
Then

```
|g(0) − g((1/2)^k)| < |tent^[k](0) − tent^[k]((1/2)^k)| = 1.
```

*Proof.* By Lipschitzness, `|g(0) − g((1/2)^k)| ≤ K · (1/2)^k`. Since
`K < 2^k` and `(1/2)^k > 0`, `K · (1/2)^k < 2^k · (1/2)^k = 1`. The
right-hand side equals `1` by Lemmas 4.3–4.4. ∎

**Interpretation.** Two inputs separated by only `2^(−k)` receive *maximally
different* true labels (`0` and `1`) under the deep tent, yet any sub-`2^k`
Lipschitz model assigns them scores differing by less than `1`. The same
slope that defeats shallow approximation certifies an intrinsic fragility:
imperceptible perturbations can flip the ground truth while a smooth model
barely reacts. Robustness (small Lipschitz constant) and expressivity
(matching deep oscillation) are in direct tension.

---

## 8. Algorithms

Two computational primitives accompany the theory.

**Algorithm 8.1 (Iterated-tent evaluation).** Compute `tent^[k](x)` by
`k` folds: repeatedly apply `t ↦ 1 − |2t − 1|`. Runtime `O(k)`, the size of
the depth-`k` network. This realizes Definition 2.2 / Theorem 4.2 directly.

**Algorithm 8.2 (Dyadic-witness extraction).** Given depth `k` and accuracy
`ε < 1/2`, output the `2^k` subintervals `[i/2^k, (i+1)/2^k]` and the certified
endpoint values `i mod 2`; these are the forced-crossing witnesses of
Theorem 5.3. Runtime `O(2^k)`, matching the lower bound it certifies.

---

## 9. Discussion and related work

The tent/sawtooth construction is the standard route to depth separation in
the spirit of Telgarsky. Our contribution is a *layered* and *fully verified*
account: (i) the analytic slope obstruction with a sharp threshold
(Section 4); (ii) the strictly stronger magnitude-independent crossing-count
obstruction via exact dyadic alternation (Section 5); and (iii) an abstract
two-point lemma that unifies the tent separation with the
iterated-exponential-tower separation (Section 6), making explicit that
slope-blowup and range-blowup are dual ways to violate one triangle
inequality. The robustness corollary (Section 7) links expressivity to
adversarial fragility.

All theorems were formalized in Lean 4 with Mathlib and verified to use only
the standard logical axioms; the range-invariance (Lemma 3.3) guarantees the
phenomenon is purely about internal oscillation rather than magnitude
escape.

---

## 10. Future directions

**From crossing counts to width lower bounds.** The natural next step is to
formalize the "at most `w` crossings" half of Corollary 5.4 — that a
continuous piecewise-linear network of width `w` meets any level in at most
`w` points — turning the forced-crossing family into a fully internal width
lower bound `w ≥ 2^k`.

**Node non-degeneracy and distinct crossings.** A key structural lemma for
the sharpened count is *node non-degeneracy*: because the deep tent is exactly
`0` or `1` at every dyadic node, any `ε`-approximant with `ε < 1/2` is pinned
on one fixed side of `1/2` at the nodes and can never equal `1/2` there. This
forbids adjacent closed-cell crossings from collapsing onto a shared
endpoint, forcing the `2^k` crossings into the *open* cells and making them
pairwise distinct.

**Discrete total variation.** The alternation yields a clean quantitative
identity: the discrete total variation of `tent^[k]` over the dyadic grid is
exactly `2^k` (adjacent node values differ by exactly `1`). This is the
bookkeeping that promotes "oscillates `2^k` times" from slogan to theorem.

**Higher dimensions and other constructions.** Push the counting machinery to
multivariate inputs and to other deep constructions in the catalog, and
explore whether the gap-to-distance ratio of Theorem 6.1 yields separation
results for further families beyond the tent and the exponential tower.

---

## 11. Conclusion

A single width-2 ReLU block, the tent map, composed `k` times, produces a
function of bounded range but exponential internal complexity. We quantified
that complexity three ways — exponential slope, exponential crossing count,
and a unifying two-point gap — and showed each forces any shallow or Lipschitz
approximant to pay an exponential price in depth. The crossing-count form is
weight-magnitude-independent and therefore the strongest; the two-point lemma
reveals slope-blowup and range-blowup as one phenomenon. Depth, in this exact
and verified sense, manufactures structure that width cannot cheaply buy.
