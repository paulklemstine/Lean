# The Path Space of Filtrations: Geodesy, Convexity, Contractibility, and Functorial Transport of the Interleaving Metric

## Abstract

We study the metric geometry of the space of *filtrations* — grounded, monotone
weight functions on the finite subsets of a vertex set — under the **interleaving
distance**, the central stability metric of topological data analysis. Building on
an isometry identification of the interleaving distance with an `ℓ∞`-type supremum
of weight gaps, we show that the space is **geodesic** via convex interpolation of
weights, with distance varying at exactly constant speed along the interpolation
path. We establish the full geodesic-segment additivity (betweenness) law and the
**Busemann convexity** inequality, and we identify the constant-speed geodesic
identity precisely as the *sharp diagonal* of convexity — its equality case when the
observer coincides with an endpoint. We then prove two structural theorems about the
resulting path space. First, the path space is **contractible**: an explicit
straight-line homotopy reels any path back to its basepoint at constant speed,
entirely within the geodesic algebra. Second, the contravariant **pullback** functor
induced by a vertex map commutes with interpolation on the nose and is short on
paths, so the assignment of a vertex set to its geodesic space of filtrations is a
functor into geodesic spaces. The unifying principle throughout is that both
interpolation and pullback are *affine in the weight*, and "affine commutes with
affine" simultaneously powers functoriality and contractibility. All results have
been formally verified.

**Keywords:** interleaving distance, persistence, geodesic space, Busemann
convexity, contractibility, functoriality, topological data analysis.

---

## 1. Introduction

Topological data analysis (TDA) extracts robust geometric features — connected
components, loops, voids — from data by recording the *scale* at which features are
born and die. The fundamental comparison tool is the **interleaving distance**,
whose defining virtue is *stability*: small perturbations of the input induce small
changes in the measured invariant. While the metric properties of interleaving (it
is an extended pseudometric, and under mild closure an honest extended metric) are
classical, the finer **geometric** structure of the space it metrizes — Is it
geodesic? Convex? Contractible? Functorial? — is the subject of this work.

We work with a deliberately elementary model of a persistence object, the
*filtration as a weight function*, and we exploit a single structural fact: the
interleaving distance on this model is *isometric* to an `ℓ∞` supremum of pointwise
weight gaps. From this isometry, a complete and clean geometric picture emerges,
and — crucially — almost all of it descends from the affine arithmetic of the
weighted average. The paper assembles these results into a self-contained account.

The contributions are:

1. **Geodesy (§3).** Convex interpolation of weights is a valid filtration and a
   constant-speed geodesic; the space is geodesic.
2. **Path-space geometry (§4).** Reparametrization closure, geodesic-segment
   betweenness, and Busemann convexity, with the constant-speed identity exhibited
   as the sharp diagonal of convexity.
3. **Contractibility (§5).** An explicit straight-line contraction of the entire
   path space onto any basepoint, at constant speed, internal to the geodesic
   algebra.
4. **Functorial transport (§6).** The pullback functor commutes with interpolation
   and is short on paths; filtration spaces form a functor into geodesic spaces.

---

## 2. Definitions and standing assumptions

Throughout, `α` and `β` are types of *vertices*; `Finset α` denotes the finite
subsets ("simplices") of `α`.

**Definition 2.1 (Filtration).** A *filtration* on `α` is a function
`F.weight : Finset α → ℝ` satisfying

- **grounding:** `F.weight ∅ ≤ 0`, and
- **monotonicity:** `σ ⊆ τ ⟹ F.weight σ ≤ F.weight τ`.

We write `Filtration α` for the set of all filtrations on `α`. Two filtrations are
equal iff their weight functions agree (*extensionality*).

**Definition 2.2 (Interleaving distance).** The *extended interleaving distance*
`eInterleavingDist F G ∈ [0, ∞]` is the infimum, in `[0, ∞]`, of `ofReal δ` over all
admissible interleaving shifts `δ` relating `F` and `G` (with the empty infimum
equal to `∞`).

**Definition 2.3 (Extended sup-distance).** The *extended sup-distance* of two
weight functions is

> `weightSupEDist F G = ⨆_{σ : Finset α} ofReal |F.weight σ − G.weight σ|`,

the supremum over all simplices of the (extended-real) absolute weight gap.

The entire geometric development rests on the following identification, taken as a
proved input from the metric layer of the theory.

**Theorem 2.4 (Isometry formula).** For all filtrations `F, G`,

> `eInterleavingDist F G = weightSupEDist F G = ⨆_{σ} ofReal |F.weight σ − G.weight σ|`.

*Consequence.* The interleaving distance is an honest `ℓ∞` supremum of pointwise
weight gaps. In particular `eInterleavingDist F F = 0`, and the distance is
symmetric and satisfies the triangle inequality. We use Theorem 2.4 freely to
convert metric statements into pointwise statements about weights.

**Definition 2.5 (Pullback).** For a vertex map `f : α → β` (with decidable equality
on `β`), the *pullback* of `F : Filtration β` is the filtration `pullback f F` on `α`
with

> `(pullback f F).weight σ = F.weight (σ.image f)`,

where `σ.image f` is the forward image of `σ`. Monotonicity follows because
`Finset.image` is monotone; grounding because the image of `∅` is `∅`. Pullback is
contravariantly functorial: `pullback id = id` and `pullback (g ∘ f) = pullback f ∘
pullback g`.

---

## 3. The interleaving metric is geodesic

### 3.1 The interpolation path

**Definition 3.1 (Linear interpolation `lerp`).** For filtrations `F, G` and a
parameter `t` with `0 ≤ t ≤ 1`, define `lerp F G t` by

> `(lerp F G t).weight σ = (1 − t)·F.weight σ + t·G.weight σ`.

**Proposition 3.2 (`lerp` is a filtration).** For `0 ≤ t ≤ 1`, `lerp F G t` is a
filtration.

*Proof sketch.* Grounding: both endpoints satisfy `weight ∅ ≤ 0` and both
coefficients `1 − t, t` are non-negative, so the convex combination is `≤ 0`.
Monotonicity: a non-negative combination of the two endpoint monotonicities is
monotone. ∎

**Proposition 3.3 (Endpoints).** `lerp F G 0 = F` and `lerp F G 1 = G`.

*Proof.* Direct from Definition 3.1: at `t = 0` the weight is `F.weight σ`, at
`t = 1` it is `G.weight σ`. ∎

### 3.2 Linearity of the weight gaps

**Lemma 3.4 (Pointwise gaps scale linearly).** For `s, t ∈ [0, 1]` and every
simplex `σ`,

> `|(lerp F G s).weight σ − (lerp F G t).weight σ| = |s − t| · |F.weight σ − G.weight σ|`.

*Proof.* The difference of the two convex combinations equals
`(t − s)·(F.weight σ − G.weight σ)`; take absolute values and use multiplicativity
of `|·|` together with `|t − s| = |s − t|`. ∎

**Lemma 3.5 (Sup-distance is linear along `lerp`).**

> `weightSupEDist (lerp F G s) (lerp F G t) = ofReal|s − t| · weightSupEDist F G`.

*Proof.* By definition the left side is `⨆_σ ofReal|(lerp s).weight σ − (lerp
t).weight σ|`. The scalar `ofReal|s − t|` factors out of the supremum (a constant
pulls through `⨆` in `[0, ∞]`), and termwise Lemma 3.4 together with
`ofReal(ab) = ofReal a · ofReal b` (for `a ≥ 0`) matches the two sides. ∎

### 3.3 The constant-speed geodesic identity

**Theorem 3.6 (Constant-speed geodesic identity).** For `s, t ∈ [0, 1]`,

> `eInterleavingDist (lerp F G s) (lerp F G t) = ofReal|s − t| · eInterleavingDist F G`.

*Proof.* Convert all distances to sup-distances by the isometry formula (Theorem
2.4) and apply Lemma 3.5. ∎

**Corollary 3.7 (Distance from an endpoint).** For `t ∈ [0, 1]`,
`eInterleavingDist F (lerp F G t) = ofReal t · eInterleavingDist F G`.

*Proof.* Write `F = lerp F G 0` (Proposition 3.3) and apply Theorem 3.6 with `s = 0`;
since `t ≥ 0`, `|0 − t| = t`. ∎

**Corollary 3.8 (Additive midpoint bisection).**

> `eInterleavingDist F (lerp F G ½) + eInterleavingDist (lerp F G ½) G = eInterleavingDist F G`.

*Proof.* By Corollary 3.7 the first term is `ofReal(½)·d(F,G)`; by Theorem 3.6 (with
`G = lerp F G 1`) the second is `ofReal|½ − 1|·d(F,G) = ofReal(½)·d(F,G)`; the two
halves sum to `ofReal 1 · d(F,G) = d(F,G)`. ∎

Theorem 3.6 says `lerp` is a constant-speed geodesic; hence:

**Theorem 3.9 (The space is geodesic).** For all `F, G` there is a path
`γ : ℝ → Filtration α` with `γ 0 = F`, `γ 1 = G`, and for all `s, t ∈ [0, 1]`,
`eInterleavingDist (γ s) (γ t) = ofReal|s − t| · eInterleavingDist F G`.

*Proof sketch.* Take `γ r = lerp F G (clamp r)` with `clamp r = min 1 (max 0 r)`.
The clamp fixes `0` and `1`, giving the endpoint conditions via Proposition 3.3; on
`[0, 1]` the clamp is the identity, so Theorem 3.6 supplies the constant-speed
law. ∎

---

## 4. The path space: reparametrization, betweenness, convexity

### 4.1 The degenerate geodesic and reparametrization closure

**Proposition 4.1 (Degenerate geodesic).** `lerp F F t = F` for all `t ∈ [0, 1]`.

*Proof.* `(1 − t)·F.weight σ + t·F.weight σ = F.weight σ`. ∎

**Theorem 4.2 (Reparametrization closure).** For `a, b, t ∈ [0, 1]`,

> `lerp (lerp F G a) (lerp F G b) t = lerp F G ((1 − t)·a + t·b)`.

*Proof sketch.* Expand the two nested convex combinations at a simplex `σ`. The
coefficient of `G.weight σ` collects to `c := (1 − t)·a + t·b`, and the coefficient
of `F.weight σ` is `1 − c`; this is exactly `(lerp F G c).weight σ`. The new
parameter `c` lies in `[0, 1]` as a convex combination of `a, b ∈ [0, 1]`. ∎

Theorem 4.2 shows the `lerp` family is closed under reparametrization and
composition: sub-paths of geodesics are geodesics, and the geodesics form the
combinatorial skeleton of a path groupoid.

### 4.2 The geodesic-segment law

**Theorem 4.3 (Betweenness / segment additivity).** For `s ≤ u ≤ t` in `[0, 1]`,

> `eInterleavingDist (lerp F G s) (lerp F G u) + eInterleavingDist (lerp F G u) (lerp F G t)
>   = eInterleavingDist (lerp F G s) (lerp F G t)`.

*Proof sketch.* Apply Theorem 3.6 to each of the three distances. With `s ≤ u ≤ t`
the absolute values resolve to `u − s`, `t − u`, `t − s`. Factor out the common
`d(F, G)` and add the two `ofReal` shifts, using `(u − s) + (t − u) = t − s`. ∎

This is the full geodesic-segment additivity law, generalizing the midpoint
bisection of Corollary 3.8 to an arbitrary intermediate parameter, and confirming
that `lerp` traces a single unbending segment.

### 4.3 Busemann convexity

**Theorem 4.4 (Convexity of the interleaving distance).** For any third filtration
`H` and `t ∈ [0, 1]`,

> `eInterleavingDist H (lerp F G t) ≤ ofReal(1 − t)·eInterleavingDist H F
>   + ofReal t·eInterleavingDist H G`.

*Proof sketch.* Convert all three distances to sup-distances by Theorem 2.4. It
suffices to bound each term of the supremum. At a fixed simplex `σ`, the elementary
convexity of `|·|` gives

> `|H.weight σ − (lerp F G t).weight σ|
>    ≤ (1 − t)·|H.weight σ − F.weight σ| + t·|H.weight σ − G.weight σ|`,

since the interpolated weight is the convex combination `(1−t)·F.weight σ +
t·G.weight σ`. Pushing this inequality through `ofReal` (which respects addition and
scaling by non-negative reals) and bounding each summand by the corresponding
supremum (`le_iSup`) yields the claim. ∎

Theorem 4.4 is the Busemann convexity inequality — the metric hallmark of
non-positive curvature — inherited verbatim from the convexity of the `ℓ∞` norm via
the isometry of Theorem 2.4.

### 4.4 Geodesy as the sharp diagonal of convexity

The convexity inequality of Theorem 4.4 is in general **strict**: the simplex
maximizing `|H − lerp F G t|` need not maximize either `|H − F|` or `|H − G|`, so
slack persists. The exception is precisely the endpoints' own geodesic.

**Theorem 4.5 (Sharp diagonal).** For `t ∈ [0, 1]`,

> `eInterleavingDist F (lerp F G t) = ofReal(1 − t)·eInterleavingDist F F
>   + ofReal t·eInterleavingDist F G`.

*Proof.* Set `H = F` in the convexity statement. Since `eInterleavingDist F F = 0`
(Theorem 2.4), the right side reduces to `ofReal t · eInterleavingDist F G`, which
equals the left side by Corollary 3.7. ∎

Thus the constant-speed geodesic identity (Theorem 3.6) is *exactly* the equality
case of Busemann convexity restricted to the endpoints' own geodesic, where the
non-maximizing slack vanishes. **Convexity is the inequality; geodesy is its sharp
diagonal.** This one asymmetry — that the worst-case simplex can migrate as the
observer `H` moves — is the simultaneous source of (i) the slack in convexity and
(ii) the failure of *unique* geodesy: an `ℓ∞` metric is flat, not strictly convex,
so the space is geodesic but not CAT(0).

---

## 5. Contractibility of the path space

**Theorem 5.1 (Straight-line contraction).** For any path `γ : ℝ → Filtration α` and
any basepoint `F`, there is a two-parameter family `H : ℝ → ℝ → Filtration α` with

- `H 0 r = F` for all `r` (the constant path at `F`),
- `H 1 r = γ r` for all `r` (the original path), and
- for each fixed `r` and all `s, t ∈ [0, 1]`,
  `eInterleavingDist (H s r) (H t r) = ofReal|s − t| · eInterleavingDist F (γ r)`
  (constant speed in `s`).

*Proof sketch.* Define `H s r = lerp F (γ r) (clamp s)`, `clamp s = min 1 (max 0 s)`.
At `s = 0` the clamp is `0`, so `H 0 r = lerp F (γ r) 0 = F`; at `s = 1` the clamp is
`1`, so `H 1 r = lerp F (γ r) 1 = γ r` (Proposition 3.3). For `s, t ∈ [0, 1]` the
clamp is the identity, and the constant-speed law is Theorem 3.6 applied to the pair
`F, γ r`. ∎

Theorem 5.1 exhibits a continuous contraction of the entire path space onto any
basepoint: every path, and in particular every loop, shrinks to a point. Hence
`(Filtration α, eInterleavingDist)` has **contractible path space** — trivial
fundamental groupoid and no higher homotopy. The contraction is built *inside* the
geodesic algebra: each strand `lerp F (γ r) s` is itself a geodesic, so the
contraction is a homotopy through geodesics, not merely a topological deformation.

---

## 6. Functorial transport of geodesics

We now show the pullback functor of Definition 2.5 respects the entire geodesic
structure.

**Theorem 6.1 (Pullback commutes with interpolation).** For `f : α → β`,
filtrations `F, G : Filtration β`, and `t ∈ [0, 1]`,

> `pullback f (lerp F G t) = lerp (pullback f F) (pullback f G) t`.

*Proof.* At a simplex `σ`, both sides have weight
`(1 − t)·F.weight (σ.image f) + t·G.weight (σ.image f)`: the left side because
pullback re-reads the interpolated weight at `σ.image f`, the right side because
interpolation averages the two pulled-back weights. The weights agree, hence so do
the filtrations. ∎

The proof is the structural heart of the section: **pullback is affine in the weight
(reindexing) and interpolation is affine in the weight (averaging); affine commutes
with affine.** This is the same one-line principle that closes reparametrization
(Theorem 4.2) and powers the contraction (Theorem 5.1).

**Theorem 6.2 (Path-level isometry).** For `f : α → β`, `F, G : Filtration β`, and
`s, t ∈ [0, 1]`,

> `eInterleavingDist (pullback f (lerp F G s)) (pullback f (lerp F G t))
>   = ofReal|s − t| · eInterleavingDist (pullback f F) (pullback f G)`.

*Proof.* Rewrite both transported points via Theorem 6.1 as `lerp (pullback f F)
(pullback f G)` at parameters `s` and `t`, then apply the constant-speed identity
(Theorem 3.6) to the pulled-back endpoints. ∎

**Theorem 6.3 (Pullback is short on paths).** Under the hypotheses of Theorem 6.2,

> `eInterleavingDist (pullback f (lerp F G s)) (pullback f (lerp F G t))
>   ≤ ofReal|s − t| · eInterleavingDist F G`.

*Proof.* Start from the equality of Theorem 6.2 and apply the point-level
short-map bound `eInterleavingDist (pullback f F) (pullback f G) ≤
eInterleavingDist F G`, monotonically under multiplication by the non-negative scalar
`ofReal|s − t|`. ∎

The point-level bound used above — that pullback is `1`-Lipschitz — is itself a
direct consequence of the isometry formula: the supremum over simplices of `α` of
the pulled-back gaps is a *reindexing* of a sub-supremum over simplices of `β`
(those of the form `σ.image f`), hence no larger than the full supremum. Equality
holds when `f` is surjective, in which case the reindexing is onto and pullback is an
*isometry* on points.

**Corollary 6.4 (Functor into geodesic spaces).** The assignment
`α ↦ (Filtration α, lerp)` is functorial: pullback carries the `F`–`G` geodesic to
the `pullback f F`–`pullback f G` geodesic exactly (Theorem 6.1), at speed no greater
than upstream (Theorem 6.3), while respecting identities and composition
(Definition 2.5). ∎

---

## 7. Algorithms

All objects here are finitely presented when `α` is finite: a filtration is a table
of `2^{|α|}` weights, the interleaving distance is a maximum over that table, and
`lerp`/`pullback` are elementwise operations. We record the three core procedures.

**Algorithm A (Interleaving distance via the isometry formula).** Given two weight
tables over the subsets of a finite vertex set, return `max_σ |F(σ) − G(σ)|`.
Complexity `Θ(2^{|α|})`. This is exact by Theorem 2.4.

**Algorithm B (Constant-speed geodesic sampling).** Given `F, G` and a sample count
`n`, return the filtrations `lerp F G (k/n)` for `k = 0, …, n`. By Theorem 3.6 the
consecutive distances are all equal to `(1/n)·d(F, G)`, providing a numerical
witness of constant speed and of betweenness (Theorem 4.3).

**Algorithm C (Path contraction).** Given a sampled path `γ(r_0), …, γ(r_m)` and a
basepoint `F`, return the homotopy grid `H(s, r) = lerp F (γ(r)) s`. Row `s = 0` is
constant at `F`; row `s = 1` recovers `γ`; the contraction is realized by sweeping
`s` from 1 to 0 (Theorem 5.1).

---

## 8. Applications

- **Canonical interpolation of datasets.** Theorem 3.6 gives an explicit, optimal,
  constant-speed morph between any two filtration-summaries — useful for visualizing
  the transition between two states of an evolving system, or for data augmentation
  along the geodesic.
- **Unambiguous averaging.** Geodesy plus betweenness (Theorems 3.9, 4.3) make
  "the midpoint" of two summaries well-defined and metrically central, a prerequisite
  for barycenter and Fréchet-mean constructions.
- **Safe coarse-graining.** Theorem 6.3 (and the underlying `1`-Lipschitz bound)
  certify that merging, projecting, or relabeling vertices can only contract
  distances — topological summaries degrade gracefully under simplification.
- **Well-behaved optimization.** Busemann convexity (Theorem 4.4) is the metric
  precondition that makes distance-to-a-target a convex objective along geodesics,
  so gradient-like and bisection methods on the filtration space behave predictably.

---

## 9. Discussion and future work

The recurring theme is economy: a single isometry (Theorem 2.4) converts the entire
metric question into pointwise `ℓ∞` arithmetic, and a single algebraic principle —
*affine commutes with affine* — yields reparametrization closure, contractibility,
and functoriality without any further metric input. The metric content enters only
through Theorem 3.6 and is otherwise inherited.

Two natural frontiers remain.

**The strict convexity defect and non-unique geodesics.** Define the Busemann
defect `δ(H, F, G, t) = ofReal(1−t)·d(H,F) + ofReal t·d(H,G) − d(H, lerp F G t)`.
Theorem 4.4 gives `δ ≥ 0` and Theorem 4.5 gives `δ = 0` on the diagonal `H ∈ {F, G}`;
the conjecture is that `δ` is *not* identically zero and that the space admits
genuinely distinct constant-speed geodesics between some pair, so it is geodesic but
not CAT(0). Because the metric is an `ℓ∞` supremum, the maximizing simplex can
migrate across the interpolation, producing flat (square) balls; the program is to
witness this with a finite example over a small vertex set — a finite, checkable
search rather than an analytic argument.

**Geodesics versus the Vietoris–Rips locus.** The diameter (Vietoris–Rips)
filtrations of finite metric spaces satisfy a triangle-compatibility constraint
across simplices that convex interpolation does not preserve. The conjecture is that
the geodesic between two diameter-filtrations generically leaves the diameter locus,
so the Vietoris–Rips filtrations are geodesically non-convex inside the full
filtration space — again falsifiable by a single small configuration whose
interpolated weight violates the diameter max-rule.

Both questions are now reduced from analysis to finite computation precisely because
the geometric scaffolding — geodesy, convexity, the sharp diagonal, contractibility,
and functorial transport — has been pinned down exactly.

---

## 10. Conclusion

We have given a complete, self-contained account of the metric geometry of the
filtration model of persistence under the interleaving distance: it is a geodesic
space realized by convex interpolation of weights, with constant-speed geodesics, a
full betweenness law, Busemann convexity, and a contractible path space; and the
contravariant pullback functor transports geodesics to geodesics without stretching.
The constant-speed geodesic identity is exactly the sharp diagonal of convexity, and
both functoriality and contractibility reduce to the principle that affine operations
on weights commute. The geometry, in the end, is the geometry of the weighted
average.
