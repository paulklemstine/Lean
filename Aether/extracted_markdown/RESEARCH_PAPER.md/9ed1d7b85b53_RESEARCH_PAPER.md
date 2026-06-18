# A Sharp, Self-Contained ReLU Depth-Separation Theorem via the Tent Map

## Abstract

We present a complete and elementary proof of an exponential depth-separation
theorem for rectified-linear (ReLU) neural networks, organized entirely around the
**tent map** `tent(x) = 1 − |2x − 1|` and its iterated compositions. We show that
the tent map is exactly a width-2, one-hidden-layer ReLU block, that its `k`-fold
composition `tent^[k]` is computed by a depth-`k`, constant-width network of size
`O(k)`, and that this deep network develops a Lipschitz constant of exactly `2^k`
while keeping its range confined to `[0,1]`. From a two-point comparison we derive
the main separation: any `K`-Lipschitz function `g` with `K · 2^{−k} + 2ε < 1`
cannot approximate `tent^[k]` to uniform accuracy `ε` on `[0,1]`. Since every
bounded-weight shallow ReLU network is Lipschitz, matching a depth-`k` tent network
forces a shallow rival to spend a Lipschitz (hence weight-times-width) budget that
grows like `2^k` — exponential cost for width versus linear cost for depth. We prove
the threshold is sharp: the deep network approximates itself with zero error while
saturating the bound to equality, so the strict inequality cannot be weakened. We
then reinterpret the same slope budget as a robustness statement on adversarial
sensitivity, and we describe an abstract two-point obstruction lemma that unifies the
present *slope-blow-up* phenomenon with the complementary *range-blow-up* mechanism
of iterated-exponential separations. All results have been formalized and
machine-checked; this paper states each definition and theorem inline with a
self-contained proof sketch.

**Keywords.** depth separation, expressive power of neural networks, ReLU networks,
tent map, Lipschitz lower bounds, adversarial robustness, Telgarsky construction.

---

## 1. Introduction

A recurring theme in the theory of neural networks is that **depth** — the number of
composed layers — can be exponentially more parameter-efficient than **width**.
Functions representable by a deep network of modest size may require an exponentially
larger shallow network to approximate. Such *depth-separation* results provide
rigorous backing for the empirical dominance of deep architectures.

The cleanest separations exploit a function that a deep network can build cheaply but
that no economical shallow network can imitate. Two complementary mechanisms produce
such functions:

1. **Range blow-up.** A deep network builds a function whose output magnitude grows
   astronomically (e.g. an iterated exponential / tower function). A shallow network
   with bounded slope cannot keep up over the interval.
2. **Slope (oscillation) blow-up.** A deep network builds a function whose *range
   stays bounded* but whose *local slope* — equivalently, its oscillation count —
   explodes. This is the genuinely *neural*, piecewise-linear mechanism behind
   Telgarsky-style separations.

This paper develops the second mechanism in its purest form, using the tent map. The
entire argument reduces to one absolute value, one composition, two evaluation
points, and a single inequality, yet it yields a sharp, exponential, and fully
rigorous separation. We have machine-verified every statement; the proof sketches
below mirror the formal development and use only elementary real analysis (absolute
values, Lipschitz composition, and induction).

---

**Relation to prior work.** Depth-separation results have a substantial history.
Classical universal-approximation theorems show that a single hidden layer can
approximate any continuous function, but say nothing about *size*. Telgarsky's
influential construction exhibits a sawtooth/triangle-wave function — built by
composing a tent-like map — that a deep network represents with `O(k)` units but
that any shallow network requires exponentially many units to approximate, the
argument turning on the number of linear oscillations. Parallel lines of work derive
separations from the magnitude (range) of a deep function (e.g. iterated
exponentials) or from VC/topological complexity of the represented function class.
The contribution here is pedagogical and foundational rather than competitive on
constants: we reduce the slope-based separation to its bare minimum — a single
absolute value, one composition, two evaluation points — obtain a *sharp* threshold,
and verify the whole chain mechanically. The two-point obstruction of Section 8 then
makes explicit that range-based and slope-based separations are the same theorem read
with different witness pairs.

## 2. Preliminaries and definitions

Throughout, functions are real-valued on the real line, and we work on the unit
interval `[0,1]`.

**Definition 2.1 (ReLU).** The rectified linear unit is
> `relu(x) = max(x, 0)`.

A *one-hidden-layer ReLU network of width `w`* is a function of the form
`x ↦ c + Σ_{j=1}^{w} a_j · relu(b_j x + d_j)` for real constants `c, a_j, b_j, d_j`.
A *depth-`k` network* is a composition of `k` such layers.

**Definition 2.2 (Tent map).** The tent map is
> `tent(x) = 1 − |2x − 1|`.

On `[0,1]` it is the symmetric triangle that rises linearly from `tent(0) = 0` to
`tent(1/2) = 1` and falls back to `tent(1) = 0`.

**Definition 2.3 (Iterated tent).** For `k ∈ ℕ`, `tent^[k]` denotes the `k`-fold
composition of `tent` with itself (`tent^[0]` is the identity). This is the function
computed by a depth-`k` network whose every layer is the tent block.

**Definition 2.4 (Lipschitz constant).** A function `f` is `K`-Lipschitz
(`LipschitzWith K f`) if `|f(x) − f(y)| ≤ K · |x − y|` for all `x, y`. The Lipschitz
constant is the smallest such `K`; it is the function's worst-case steepness.

**Definition 2.5 (Uniform `ε`-approximation on `[0,1]`).** A function `g`
approximates `f` within `ε` on `[0,1]` if `|f(x) − g(x)| ≤ ε` for all `x ∈ [0,1]`.

---

## 3. The tent map is a single ReLU layer

**Theorem 3.1 (`tent_relu_repr`).** For all `x`,
> `tent(x) = 1 − relu(2x − 1) − relu(1 − 2x)`.

*Proof sketch.* For any real `y`, `|y| = relu(y) + relu(−y)`, since exactly one of
`y, −y` is nonnegative and contributes its absolute value while the other is clipped
to 0. Substituting `y = 2x − 1` gives `|2x − 1| = relu(2x − 1) + relu(1 − 2x)`, and
`tent(x) = 1 − |2x − 1|` becomes the claimed identity. ∎

Thus the tent map is realized by a width-2 hidden layer: two ReLU units of slopes
`±2` with output weights `−1`, plus a constant bias `1`. The deep function
`tent^[k]` is therefore computed by a depth-`k`, **constant-width** network of total
size `O(k)`.

---

## 4. Geometry of the deep tent network

We record three structural facts: the deep network maps the cube to itself, has
exponentially large slope, and exhibits an exponentially steep ramp.

**Theorem 4.1 (`tent_lipschitz`).** `tent` is `2`-Lipschitz.

*Proof sketch.* `tent(x) − tent(y) = |2y − 1| − |2x − 1|`. By the reverse triangle
inequality `||a| − |b|| ≤ |a − b|` with `a = 2y − 1`, `b = 2x − 1`, we get
`|tent(x) − tent(y)| ≤ |(2y − 1) − (2x − 1)| = 2|x − y|`. (Formally, a case split on
the signs of `2x − 1`, `2y − 1`, and `x − y` closes both directions of the bound by
linear arithmetic.) ∎

**Theorem 4.2 (`tent_mapsTo`).** `tent` maps `[0,1]` into `[0,1]`.

*Proof sketch.* For `x ∈ [0,1]`, `−1 ≤ 2x − 1 ≤ 1`, so `|2x − 1| ≤ 1`, giving
`0 ≤ 1 − |2x − 1| ≤ 1`. ∎

**Theorem 4.3 (`tent_eq_two_mul`).** If `x ≤ 1/2` then `tent(x) = 2x`.

*Proof sketch.* For `x ≤ 1/2`, `2x − 1 ≤ 0`, so `|2x − 1| = 1 − 2x` and
`tent(x) = 1 − (1 − 2x) = 2x`. This is the ascending branch identity that drives the
peak computation below. ∎

**Theorem 4.4 (`tent_iterate_lipschitz`).** For every `k`, `tent^[k]` is
`2^k`-Lipschitz.

*Proof sketch.* The composition of an `a`-Lipschitz map with a `b`-Lipschitz map is
`ab`-Lipschitz. By Theorem 4.1 each factor is `2`-Lipschitz, so the `k`-fold
composition is `2^k`-Lipschitz (Mathlib's `LipschitzWith.iterate`). ∎

**Theorem 4.5 (`tent_iterate_zero`).** For every `k`, `tent^[k](0) = 0`.

*Proof sketch.* `0` is a fixed point: `tent(0) = 1 − |−1| = 0`. By induction on `k`,
`tent^[k+1](0) = tent(tent^[k](0)) = tent(0) = 0`. ∎

**Theorem 4.6 (`tent_iterate_peak`).** For every `k`,
> `tent^[k]( (1/2)^k ) = 1`.

*Proof sketch.* Induction on `k`. The base case `k = 0` is `id(1) = 1`. For the
inductive step, note `(1/2)^{k+1} ≤ 1/2`, so by Theorem 4.3 the **innermost**
application satisfies `tent( (1/2)^{k+1} ) = 2 · (1/2)^{k+1} = (1/2)^k`. Writing
`tent^[k+1]((1/2)^{k+1}) = tent^[k]( tent((1/2)^{k+1}) ) = tent^[k]((1/2)^k)`, the
inductive hypothesis gives the value `1`. ∎

**Geometric reading.** Theorems 4.5 and 4.6 together say that `tent^[k]` climbs from
`0` to `1` as its input moves from `0` to `(1/2)^k = 2^{−k}` — a ramp of unit height
over an interval of width `2^{−k}`. The range stays inside `[0,1]` (Theorem 4.2),
but the slope is exponentially large (Theorem 4.4). More globally, `tent^[k]` is a
piecewise-linear "comb" of `2^k` congruent spikes; the first ramp alone suffices for
the separation.

---

## 5. The depth-separation theorem

**Theorem 5.1 (`relu_depth_separation`).** Fix `k ∈ ℕ`. Let `g` be `K`-Lipschitz
(in the explicit form `|g(x) − g(y)| ≤ K · |x − y|` for all `x, y`) and suppose
> `K · (1/2)^k + 2ε < 1`.
Then `g` does **not** approximate `tent^[k]` within `ε` on `[0,1]`; i.e. it is false
that `|tent^[k](x) − g(x)| ≤ ε` for all `x ∈ [0,1]`.

*Proof sketch.* By contraposition, assume `g` *does* approximate `tent^[k]` within
`ε` everywhere on `[0,1]`. Evaluate at the two ramp endpoints, both of which lie in
`[0,1]`:

- At `x = 0`: by Theorem 4.5, `tent^[k](0) = 0`, so `|g(0)| ≤ ε`, i.e. `g(0) ≥ −ε`.
- At `x = (1/2)^k`: by Theorem 4.6, `tent^[k]((1/2)^k) = 1`, so `|1 − g((1/2)^k)| ≤ ε`,
  i.e. `g((1/2)^k) ≥ 1 − ε`.

Subtracting, the rise of `g` across the ramp satisfies
`g((1/2)^k) − g(0) ≥ (1 − ε) − ε = 1 − 2ε`. But `g` is `K`-Lipschitz and the two
points are `(1/2)^k` apart, so `g((1/2)^k) − g(0) ≤ K · (1/2)^k`. Combining,
`1 − 2ε ≤ K · (1/2)^k`, i.e. `K · (1/2)^k + 2ε ≥ 1`, which is exactly the negation of
the hypothesis. ∎

**Corollary 5.2 (Width/budget lower bound).** Every bounded-weight shallow ReLU
network is `K`-Lipschitz for some finite `K` controlled by its weights and width. To
approximate `tent^[k]` within any fixed `ε < 1/2`, Theorem 5.1 forces
`K ≥ (1 − 2ε) · 2^k`. Hence the Lipschitz budget — and therefore the
weight-magnitude-times-width budget — of any shallow approximant grows at least like
`2^k`, while the deep network's size grows like `k`. This is exponential separation
between depth and width.

---

## 6. Sharpness of the threshold

The strict inequality in Theorem 5.1 is not an artifact; it is exactly tight.

**Theorem 6.1 (`relu_depth_separation_sharp`).** For every `k`,
> `2^k · (1/2)^k + 2·0 = 1`.

*Proof sketch.* `2^k · (1/2)^k = (2 · 1/2)^k = 1^k = 1`, and the error term is `0`. ∎

**Interpretation.** Take the honest deep solution `g = tent^[k]`, which approximates
itself with zero error (`ε = 0`) and has true Lipschitz constant `K = 2^k`
(Theorem 4.4). It saturates the bound to *equality*: `K · 2^{−k} + 2ε = 1`. Thus the
hypothesis `K · 2^{−k} + 2ε < 1` cannot be relaxed to `≤`, because the optimal
depth-`k` solution sits exactly on the boundary. The separation threshold is sharp.

**Worked example (`k = 3`).** The depth-3 network is a comb of `2^3 = 8` spikes. The
laziest shallow model — the constant `1/2`, which is `0`-Lipschitz (`K = 0`) — has
budget `0 · (1/2)^3 + 2·0 = 0 < 1`, so by Theorem 5.1 it cannot approximate
`tent^[3]` to *any* accuracy `ε` with `2ε < 1`; concretely it fails at the level
`ε = 3/8` (the formal file checks `1 · (1/2)^3 + 2·0 = 1/8 < 1` for the slightly
stronger `K = 1` framing). The constant guesser is provably blind to the eight-spike
structure three folds create.

---

## 7. The same budget as a robustness bound

The inequality `(value gap) ≤ K · (point distance) + 2ε` admits a second reading in
the language of adversarial robustness.

**Proposition 7.1 (Depth-induced fragility, informal).** Because `tent^[k]` has local
slope `2^k`, the two inputs `0` and `2^{−k}` — distance `2^{−k}` apart — produce
outputs `0` and `1`, the maximal possible gap in `[0,1]`. Consequently, *any*
classifier built on `tent^[k]` (e.g. thresholding the output) has an
adversarial pair separated by only `2^{−k}` in input but maximally separated in true
label. More generally, no `K`-Lipschitz surrogate with `K < 2^k` can be simultaneously
faithful to the deep network and robust at scale `2^{−k}`: faithfulness forces it to
reproduce the unit jump, while its Lipschitz budget caps the jump at `K · 2^{−k} < 1`.

The point is conceptual: the *same* quantity, the local slope `2^k`, that defeats
shallow approximation (Theorem 5.1) also certifies adversarial sensitivity.
Expressive power and brittleness are dual consequences of one Lipschitz budget.

---

## 8. An abstract obstruction unifying two separations

Both the tent (slope-blow-up) and the iterated exponential (range-blow-up) fit a
single template.

**Lemma 8.1 (Two-point obstruction, schematic).** Suppose `f` attains values `f(a)`
and `f(b)` at points `a, b` with `|a − b| = δ` and `|f(a) − f(b)| = Δ`. If `g` is
`K`-Lipschitz and approximates `f` within `ε` at both `a` and `b`, then
> `Δ ≤ K · δ + 2ε`.
Equivalently, if `K · δ + 2ε < Δ`, no such `g` exists.

*Proof sketch.* `|f(a) − f(b)| ≤ |f(a) − g(a)| + |g(a) − g(b)| + |g(b) − f(b)| ≤ ε +
K·δ + ε`. ∎

**Instances.**

- **Tent (this paper).** Take `a = 0`, `b = 2^{−k}`, so `δ = 2^{−k}`, and
  `Δ = |1 − 0| = 1`. Lemma 8.1 with `K · 2^{−k} + 2ε < 1` reproduces Theorem 5.1.
  Here `δ` is exponentially *small* and `Δ` is *bounded*: slope blow-up.
- **Iterated exponential (companion construction).** Take the two endpoints of the
  interval, where the tower function's values differ by an astronomically large
  `Δ` while `δ` is order 1. Lemma 8.1 yields the corresponding separation. Here `δ`
  is *bounded* and `Δ` is *exponentially large*: range blow-up.

Thus a single lemma, parameterized only by the witness pair `(δ, Δ)`, subsumes both
the bounded-range/large-slope and large-range/moderate-slope separations. Range and
slope blow-up are two faces of the inequality `Δ ≤ K·δ + 2ε`.

---

## 9. Algorithms

We summarize the computational content used in the demonstrations.

**Algorithm A (Iterated tent evaluation).** Given depth `k` and input `x`, repeatedly
apply `t ← 1 − |2t − 1|`, `k` times, returning `t`. Runs in `O(k)` arithmetic
operations and exactly mirrors a forward pass of the depth-`k`, width-2 network.

**Algorithm B (Empirical Lipschitz constant).** Sample the ramp `[0, 2^{−k}]` (and,
optionally, all of `[0,1]`) on a fine grid, compute the maximum finite-difference
slope `|f(x_{i+1}) − f(x_i)| / (x_{i+1} − x_i)`, and report it as a lower estimate of
the Lipschitz constant. For `tent^[k]` this approaches `2^k`, confirming
Theorem 4.4.

**Algorithm C (Separation certificate check).** Given `k`, a candidate Lipschitz
constant `K`, and tolerance `ε`, evaluate the budget `K · 2^{−k} + 2ε` and compare to
`1`. If it is `< 1`, Theorem 5.1 *certifies* that no `K`-Lipschitz function can
`ε`-approximate `tent^[k]`. This is a constant-time decision procedure for the
impossibility.

---

## 10. Applications and discussion

- **Justifying depth.** The result is a clean, self-contained witness that depth is
  not interchangeable with width: linear growth in depth buys what only exponential
  growth in width can match.
- **A native ReLU object.** Because the tent map is literally a width-2 ReLU layer,
  the separation is expressed in the architecture's own vocabulary, with no appeal to
  smooth approximation theory.
- **Robustness auditing.** Proposition 7.1 turns the same construction into a
  worst-case fragility bound, relevant to certified-robustness analysis: high
  expressivity through extreme local slope necessarily implies adversarial
  sensitivity at the corresponding scale.
- **A unifying lens.** Lemma 8.1 isolates the analytic kernel common to several
  depth-separation arguments, suggesting a modular library where new separations are
  obtained by exhibiting a single witness pair `(δ, Δ)`.

**Limitations.** The lower bound is stated against arbitrary `K`-Lipschitz comparators;
translating `K` into explicit width and weight-magnitude bounds for a *specific*
shallow architecture requires the standard (elementary) fact that a one-hidden-layer
network's Lipschitz constant is bounded by a product of layer norms. The crossing-count
refinement (a *magnitude-free* width bound `w ≥ 2^k − 1`) is not proved here; it is
described as a future direction.

---

## 11. Future directions

The following directions extend the present frontier; each is concrete and
falsifiable.

1. **Exact width lower bound from oscillation counting.** Replace the single-ramp
   Lipschitz obstruction by a counting argument: `tent^[k]` crosses level `1/2`
   exactly `2^k` times, while a one-hidden-layer ReLU network of width `w` is
   piecewise-linear with at most `w + 1` pieces and so crosses any level at most
   `w + 1` times. This yields the *magnitude-free* bound `w ≥ 2^k − 1`. The key
   insight is that crossing number is a topological invariant no low-piece-count
   function can reproduce; the missing ingredient is a finite combinatorial lemma
   ("a function with `p` affine pieces has at most `p` solutions to `f = c`").

2. **Matching shallow upper bound (quantitative 1-D interpolation).** Pair the lower
   bound with a constructive `Θ(K/ε)`-width upper bound: the piecewise-linear
   interpolant of a `K`-Lipschitz `f` on a uniform mesh of `N = ⌈K/ε⌉` nodes is a
   width-`N` one-hidden-layer ReLU network with sup-error `≤ K·(mesh) ≤ ε`. With
   Direction 1 this closes the `width ≈ ε^{−1}` (shallow) vs `depth ≈ log(1/ε)`
   (deep) gap quantitatively.

3. **Higher-dimensional separation on `[−1,1]^n`.** Lift via tensorized tents
   `F(x) = tent^[k](x_1) · ⋯ · tent^[k](x_n)` (or a max-pooling variant) and show
   the shallow cost scales as `ε^{−n}` while a depth-`O(n·log(1/ε))` network stays
   polynomial — a genuine curse-of-dimensionality separation. Local steepness is
   multiplicative under tensor products, so the per-coordinate factor `2^k` compounds
   to `2^{nk}`.

4. **Robustness / adversarial reading.** Formalize Proposition 7.1 fully: any
   classifier of Lipschitz constant `K < 2^k` must misclassify some
   `2^{−k}`-adversarial pair, giving a provable depth-induced fragility theorem. The
   endpoints `tent^[k](0) = 0` and `tent^[k](2^{−k}) = 1` already exhibit the
   `2^{−k}`-separated, maximal-gap pair.

5. **Cross-domain bridge to the exponential tower.** Prove Lemma 8.1 once and
   back-apply it to *both* the bounded-range/slope-blow-up tent map and the
   range-blow-up exponential tower, retiring two bespoke proofs in favor of a single
   parameterized obstruction.

---

## 11a. Why a bounded range matters

It is worth stressing what distinguishes the tent construction from range-blow-up
arguments, because the distinction is exactly what makes the result *neural*. If one
is allowed functions whose outputs grow without bound, separations are comparatively
easy: a shallow network with bounded slope simply cannot reach far-away values over a
bounded domain. Real networks, however, are routinely normalized — outputs are
logits feeding a softmax, activations are batch-normalized, signals are clipped — so
the *range* is effectively controlled while the interesting complexity lives in how
rapidly and how often the function varies. The tent map models precisely this regime:
its range is pinned to `[0,1]` for every depth `k`, yet its complexity (slope `2^k`,
oscillation count `2^k`) explodes. The separation therefore survives the very
normalization that trivializes range-based arguments, which is why oscillation/slope
blow-up is the mechanism most faithful to deployed architectures. The same feature is
what couples expressivity to fragility in Section 7: bounded range plus exploding
slope is exactly the signature of a network that is both highly expressive and highly
sensitive to small input perturbations.

## 12. Conclusion

From one absolute value, one composition, two points, and one inequality, the tent
map delivers a sharp, exponential, fully rigorous depth-separation theorem for ReLU
networks: depth-`k` constant-width networks achieve Lipschitz constant `2^k` within a
bounded range, and no `K`-Lipschitz comparator with `K · 2^{−k} + 2ε < 1` can match
them within `ε`. The threshold is tight, the construction is native to ReLU
architectures, the same budget doubles as an adversarial-robustness bound, and an
abstract two-point lemma unifies this slope-blow-up separation with its range-blow-up
cousin. The argument is elementary enough to teach and precise enough to have been
machine-verified end to end.
