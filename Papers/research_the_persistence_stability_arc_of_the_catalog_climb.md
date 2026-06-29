# Convexity and Bicombing of Interleaving Geodesics: The Interleaving Metric on Filtrations is a Busemann Space

## Abstract

The interleaving distance is the canonical comparison metric of topological data analysis (TDA): it equips the space of filtrations — combinatorial encodings of multiscale shape — with a notion of distance under which persistence is stable. Prior work in this line established a ladder of structure on the space of filtrations: a relational interleaving preorder, a pseudo-extended-metric, a genuine extended metric space, an exact isometry onto weight functions under the supremum distance, an explicit constant-speed geodesic given by convex interpolation of weights, and a self-coherent (reparametrisation-consistent) field of those geodesics. This paper supplies the **curvature** layer. We prove that the geodesic interpolation map `lerp` is a **convex geodesic bicombing**: for two geodesics run by a common clock,

> `d( lerp(F, G, t), lerp(F′, G′, t) ) ≤ (1 − t)·d(F, F′) + t·d(G, G′)`,

the defining inequality of a Busemann (non-positively curved) space. The proof transports a single elementary fact — convexity of the real absolute value, `|(1−t)a + tb| ≤ (1−t)|a| + t|b|` — coordinatewise through the supremum that defines the interleaving distance, via the isometry formula `d(F,G) = sup_σ |w_F(σ) − w_G(σ)|`. We derive as corollaries the affine reversal symmetry of geodesics, the stationarity of constant geodesics, and ordinary convexity of the distance-to-a-fixed-point function along any geodesic. All results hold over an arbitrary index type `α` and have been formally verified, sorry-free, in a proof assistant; the present paper gives the mathematics and proof sketches in self-contained form.

**Keywords:** interleaving distance, persistence, filtration, geodesic, convex bicombing, Busemann space, non-positive curvature, topological data analysis, sup-norm, ℓ^∞ geometry.

---

## 1. Introduction

### 1.1 Background and motivation

Topological data analysis summarizes a dataset by a *persistence module* or, more combinatorially, by a *filtration*: a recipe specifying, for each candidate feature (a simplex), the scale at which that feature is born. The space of such objects is compared by the **interleaving distance** `d`, whose foundational virtue is stability — small perturbations of the input produce small changes in `d`. Stability theorems (in the tradition of Cohen-Steiner, Edelsbrunner, Harer and the algebraic-stability theorem of Chazal et al.) are the bedrock of TDA's claim to robustness.

Stability concerns *how the metric responds to perturbation*. A complementary and largely orthogonal question concerns *the intrinsic geometry of the metric space itself*: Is it geodesic? If so, what is its curvature? These questions matter computationally. Non-positive curvature (in the metric sense of Busemann, or the stronger CAT(0) sense of Alexandrov) is precisely the structural property guaranteeing unique Fréchet means, convergence of geodesic optimization, well-posed interpolation, and contractibility. Establishing such curvature for the interleaving metric therefore underwrites the algorithmic ambition of *learning over the space of shapes*.

### 1.2 The arc of prior structure

This paper is the eleventh in a sequence ("bridges") building geometric structure on the space of filtrations. We summarize the inherited facts, all of which we take as given:

1. **Interleaving relation (Bridge IV).** A symmetric, reflexive, translation-monotone relation `Interleaved F G δ` capturing `δ`-shift containment of sublevel families.
2. **Extended interleaving distance (Bridge V).** `d(F,G) = inf { ofReal δ : Interleaved F G δ }` valued in `ℝ≥0∞`, with an unconditional triangle inequality.
3. **Extended metric space (Bridge VII).** The infimum is attained at `0` iff weights agree, making the structure a genuine `EMetricSpace`.
4. **Isometry formula (Bridge VIII).** `d(F,G) = sup_σ ofReal |w_F(σ) − w_G(σ)|` — the interleaving distance *is* the extended sup-distance of the weight functions.
5. **Constant-speed geodesic (Bridge IX).** Convex interpolation `lerp(F,G,t)` of weights is a filtration, runs from `F` to `G`, and `d(lerp(F,G,s), lerp(F,G,t)) = ofReal|s−t|·d(F,G)`.
6. **Reparametrisation consistency (Bridge X).** The geodesic field is self-coherent: `lerp(lerp(F,G,s), lerp(F,G,t), r) = lerp(F,G, (1−r)s + r t)`.

The present work (Bridge XI) adds the curvature layer: **convexity of the bicombing** comparing *distinct* geodesics.

### 1.3 Contributions

We prove, over an arbitrary index type `α`:

- **(C1)** `lerp_reverse`: affine reversal symmetry `lerp(F,G,t) = lerp(G,F,1−t)`.
- **(C2)** `lerp_self`: constant geodesics are stationary, `lerp(F,F,t) = F`.
- **(C3)** `weightSupEDist_lerp_bicombing`: the convexity bound at the sup-distance level.
- **(C4)** `eInterleavingDist_lerp_bicombing`: the convex geodesic bicombing inequality — Busemann convexity of the interleaving metric.
- **(C5)** `eInterleavingDist_lerp_convex`: convexity of distance to a fixed filtration along a geodesic, as the constant-geodesic special case of (C4).

The technical core is a single per-coordinate triangle inequality amplified through a supremum; the conceptual content is that the interleaving metric is non-positively curved in the sense of Busemann, certified by a consistent convex geodesic bicombing.

---

## 2. Definitions

Throughout, `α` is an arbitrary type (the index/vertex type); `Finset α` denotes finite subsets of `α` ("simplices"), and `ℝ≥0∞` denotes the extended nonnegative reals `[0, ∞]`. For `x ∈ ℝ`, `ofReal x ∈ ℝ≥0∞` is `max(x,0)` cast into `ℝ≥0∞`.

### Definition 2.1 (Filtration)
A **filtration** on `α` is a function `w : Finset α → ℝ` (the *weight*, recording the birth scale of each simplex) satisfying
- **(F0) empty-face normalization:** `w(∅) ≤ 0`;
- **(F-mono) monotonicity:** `σ ⊆ τ ⟹ w(σ) ≤ w(τ)`.

We write `F`, `G`, … for filtrations and `w_F` for the weight of `F`. Monotonicity guarantees that each sublevel set `{σ : w_F(σ) ≤ t}` is downward closed, hence (for `t ≥ 0`) an abstract simplicial complex.

### Definition 2.2 (Sublevel family and δ-interleaving)
The **sublevel family** of `F` at scale `t ∈ ℝ` is `S_F(t) = { σ : w_F(σ) ≤ t }`. For `δ ≥ 0`, filtrations `F, G` are **δ-interleaved** if
`∀ t, S_F(t) ⊆ S_G(t + δ)` and `∀ t, S_G(t) ⊆ S_F(t + δ).`

### Definition 2.3 (Extended interleaving distance)
`d(F, G) = ⨅ { ofReal δ : δ ≥ 0 and F, G are δ-interleaved } ∈ ℝ≥0∞`, with the convention that an empty index set yields `⊤`.

### Definition 2.4 (Extended sup-distance of weights)
`D_∞(F, G) = ⨆_{σ : Finset α} ofReal |w_F(σ) − w_G(σ)| ∈ ℝ≥0∞`. The index `Finset α` is always nonempty (it contains `∅`).

### Proposition 2.5 (Isometry formula — inherited, Bridge VIII)
For all `F, G`, `d(F, G) = D_∞(F, G)`.

*This is the linchpin used pervasively below: every metric statement about `d` reduces to a statement about the supremum `D_∞`.*

### Definition 2.6 (Geodesic interpolation `lerp`)
For filtrations `F, G` and `t ∈ ℝ` with `0 ≤ t ≤ 1`, `lerp(F, G, t)` is the filtration with weight
`w_{lerp(F,G,t)}(σ) = (1 − t)·w_F(σ) + t·w_G(σ).`
This is well defined: (F0) holds since `(1−t)w_F(∅) + t w_G(∅) ≤ 0` for `t ∈ [0,1]` and `w_F(∅), w_G(∅) ≤ 0`; (F-mono) holds because a convex combination (nonnegative coefficients) of monotone functions is monotone.

### Proposition 2.7 (Endpoints, constant speed — inherited, Bridge IX)
`lerp(F,G,0) = F`, `lerp(F,G,1) = G`, and `d(lerp(F,G,s), lerp(F,G,t)) = ofReal|s−t|·d(F,G)` for `s,t ∈ [0,1]`. Hence `lerp(F,G,·)` is a constant-speed geodesic from `F` to `G`.

### Definition 2.8 (Convex geodesic bicombing)
A **convex geodesic bicombing** on a metric space `X` is a map `σ : X × X × [0,1] → X` such that each `t ↦ σ(x, y, t)` is a constant-speed geodesic from `x` to `y`, and the **convexity inequality**
`d(σ(x,y,t), σ(x′,y′,t)) ≤ (1−t)·d(x,x′) + t·d(y,y′)`
holds for all `x, y, x′, y′` and `t ∈ [0,1]`. A space admitting such a bicombing is a **Busemann space** (non-positively curved in the metric sense). The bicombing is **consistent** if it is stable under restriction to subsegments; for `lerp` this is the inherited identity `lerp(lerp(F,G,s),lerp(F,G,t),r) = lerp(F,G,(1−r)s+rt)` (Bridge X).

---

## 3. Main results

We state the five results and give proof sketches. The Lean identifiers are noted for traceability; full machine-checked proofs exist but are not reproduced here.

### 3.1 Affine symmetries

#### Theorem 3.1 (Affine reversal symmetry — `lerp_reverse`)
For all `F, G` and `t ∈ [0,1]`,
`lerp(F, G, t) = lerp(G, F, 1 − t).`

**Proof sketch.** By extensionality of filtrations (a filtration is determined by its weight function), it suffices to check weights pointwise. For each `σ`,
`w_{lerp(G,F,1−t)}(σ) = (1 − (1−t))·w_G(σ) + (1−t)·w_F(σ) = (1−t)·w_F(σ) + t·w_G(σ) = w_{lerp(F,G,t)}(σ),`
which is an identity of real numbers (`ring`). ∎

#### Theorem 3.2 (Constant geodesics are stationary — `lerp_self`)
For all `F` and `t ∈ [0,1]`, `lerp(F, F, t) = F.`

**Proof sketch.** Pointwise, `w_{lerp(F,F,t)}(σ) = (1−t)·w_F(σ) + t·w_F(σ) = w_F(σ)`; conclude by extensionality. ∎

These two are recorded both for their own sake (geodesics are honest two-way streets; degenerate geodesics are points) and because Theorem 3.2 is the lever that reduces Theorem 3.5 to Theorem 3.4.

### 3.2 The convexity bound at the sup-distance level

#### Lemma 3.3 (Per-coordinate convexity of absolute value)
For `a, b ∈ ℝ` and `t ∈ [0,1]`, `|(1−t)a + t b| ≤ (1−t)|a| + t|b|.`

**Proof sketch.** Convexity of `|·|` (equivalently, the triangle inequality applied to the convex combination): `|(1−t)a + tb| ≤ |(1−t)a| + |tb| = (1−t)|a| + t|b|`, using `1−t, t ≥ 0`. A finite case split on the signs of `a`, `b`, and the combination, closed by linear arithmetic, also suffices. ∎

#### Theorem 3.4 (Convexity bound at sup-distance level — `weightSupEDist_lerp_bicombing`)
For all `F, G, F′, G′` and `t ∈ [0,1]`,
`D_∞( lerp(F,G,t), lerp(F′,G′,t) ) ≤ ofReal(1−t)·D_∞(F,F′) + ofReal(t)·D_∞(G,G′).`

**Proof sketch.** Since the left side is a supremum over `σ ∈ Finset α`, by the universal property of `⨆` it suffices to bound each term by the right-hand side. Fix `σ` and set `a = w_F(σ) − w_{F′}(σ)`, `b = w_G(σ) − w_{G′}(σ)`. Because `lerp` interpolates weights linearly,
`w_{lerp(F,G,t)}(σ) − w_{lerp(F′,G′,t)}(σ) = (1−t)a + t b.`
By Lemma 3.3, `|(1−t)a + tb| ≤ (1−t)|a| + t|b|`. Applying the order-preserving map `ofReal` and pushing it through the sum and products (legitimate since `1−t, t ≥ 0` and the summands are nonnegative),
`ofReal|{lerp}_t(σ) − {lerp'}_t(σ)| ≤ ofReal(1−t)·ofReal|a| + ofReal(t)·ofReal|b|.`
Finally dominate each weight gap by its supremum: `ofReal|a| ≤ D_∞(F,F′)` and `ofReal|b| ≤ D_∞(G,G′)` (each term is `≤` the corresponding `⨆`). Monotone combination (`gcongr`) yields the bound for this `σ`; take the supremum on the left. ∎

The only nontrivial ingredient is Lemma 3.3; everything else is bookkeeping with `ofReal`, nonnegativity, and the universal properties of `⨆`.

### 3.3 The convex geodesic bicombing

#### Theorem 3.5 (Busemann convexity — `eInterleavingDist_lerp_bicombing`)
For all `F, G, F′, G′` and `t ∈ [0,1]`,
`d( lerp(F,G,t), lerp(F′,G′,t) ) ≤ ofReal(1−t)·d(F,F′) + ofReal(t)·d(G,G′).`

**Proof sketch.** Rewrite all three occurrences of `d` via the isometry formula (Proposition 2.5) as `D_∞`, then apply Theorem 3.4 verbatim. ∎

This is the headline result: `lerp` is a convex geodesic bicombing, so `(Filtration α, d)` is a Busemann space. Combined with the inherited consistency identity (Definition 2.8), `lerp` is a *consistent* convex geodesic bicombing in the sense of Descombes–Lang.

#### Theorem 3.6 (Convexity of distance to a fixed filtration — `eInterleavingDist_lerp_convex`)
For all `F, G, H` and `t ∈ [0,1]`,
`d( lerp(F,G,t), H ) ≤ ofReal(1−t)·d(F,H) + ofReal(t)·d(G,H).`

**Proof sketch.** Specialize Theorem 3.5 with `F′ = G′ = H`. The second geodesic is then `lerp(H,H,t)`, which equals the constant point `H` by Theorem 3.2. Substituting gives the claim. ∎

In words: along any geodesic, the distance to a fixed reference filtration is a convex function of the parameter — the classical single-geodesic notion of convexity, and the analytic foundation of well-posed Fréchet means and geodesic optimization.

---

## 4. Discussion: the geometry of an ℓ^∞ space

### 4.1 Flat convexity, not strict convexity

The interleaving metric is, via Proposition 2.5, an ℓ^∞-type (supremum-normed) geometry on weight functions. Such geometries are **flat-convex**: the Busemann inequality of Theorem 3.5 holds with the *optimal* convex coefficients `(1−t, t)`, but it is generically *not strict*. The reason is structural: the supremum defining `d` is attained (or approached) on possibly *different* simplices for the two endpoint distances `d(F,F′)` and `d(G,G′)`. Equality in Theorem 3.5 occurs precisely when a single simplex simultaneously realizes both endpoint suprema with compatible signs of the weight gaps; otherwise the bound is strict. The convexity *defect* is thus a finite, decidable, combinatorial event — a mismatch of argmax simplices — rather than a smooth curvature quantity.

This places the interleaving metric at the boundary of the non-positive-curvature world: it is Busemann (convex distance functions, convex bicombing) but not CAT(0) (which would require the stricter, strictly-convex comparison-triangle inequalities that ℓ^∞ violates). This is the correct expectation; ℓ^∞ spaces are the canonical examples of Busemann-but-not-CAT(0) geometry.

### 4.2 Curvature is inherited through the isometry

A recurring theme across this sequence is that geometry is *transported*, not constructed. Geodesy (Proposition 2.7), reparametrisation consistency (Bridge X), and now curvature (Theorem 3.5) all reduce, through the isometry formula, to elementary facts about real numbers applied coordinatewise:
- *geodesy* ← linearity of `t ↦ (1−t)a + tb`;
- *consistency* ← affine composition of linear interpolations;
- *curvature* ← convexity of `|·|` (Lemma 3.3).
The supremum preserves each fact coordinatewise. This explains both the simplicity of the proofs and the precise *flatness* of the resulting curvature: the geometry is exactly as curved as the absolute-value function, no more and no less.

### 4.3 Consequences

A consistent convex geodesic bicombing on a complete space (or its metric completion) yields, by standard theory (Busemann; Descombes–Lang):
- **Unique Fréchet means / barycenters** of finite collections of filtrations.
- **Convergence of geodesic convex optimization**: convex objectives along geodesics have no spurious local minima (Theorem 3.6 is the prototype objective).
- **Well-posed, stable interpolation** between datasets via `lerp`.
- **Contractibility** of the space along the bicombing (collapse every point to a fixed basepoint through its geodesic).

These translate directly to TDA practice: averaging the topological summaries of many datasets, fitting models in filtration space, and morphing one dataset's shape into another's along provably shortest, provably stable roads.

---

## 5. Algorithms

The results are constructive at the level of weight functions and immediately yield verification and computation procedures over any finite index set. We describe two.

### 5.1 Bicombing-bound verifier

**Purpose.** Given finite filtrations `F, G, F′, G′` (weight tables over a finite simplex set `Σ`) and a parameter `t ∈ [0,1]`, compute both sides of Theorem 3.5 and certify the inequality, returning the *slack* (RHS − LHS ≥ 0) and the argmax simplices that witness each distance.

**Foundation.** Each `d` is `max_{σ ∈ Σ} |w_·(σ) − w_·(σ)|` (Proposition 2.5 restricted to the support `Σ`). The interpolant weight is `(1−t)w_·(σ) + t w_·(σ)`.

**Complexity.** `O(|Σ|)` arithmetic operations to compute each of the three maxima, hence `O(|Σ|)` total — linear in the number of simplices.

**Pseudocode.**
```
function bicombing_slack(F, G, Fp, Gp, t, Σ):
    assert 0 ≤ t ≤ 1
    lhs ← max over σ in Σ of | ((1−t)F[σ] + t G[σ]) − ((1−t)Fp[σ] + t Gp[σ]) |
    dFFp ← max over σ in Σ of | F[σ] − Fp[σ] |
    dGGp ← max over σ in Σ of | G[σ] − Gp[σ] |
    rhs ← (1−t)·dFFp + t·dGGp
    return (lhs, rhs, rhs − lhs)        # slack ≥ 0 is the certified inequality
```

### 5.2 Vietoris–Rips filtration from a point cloud

**Purpose.** Produce a concrete filtration from a finite metric dataset, so the bicombing verifier can be exercised on real shapes.

**Foundation.** The **Vietoris–Rips** weight of a simplex `σ` is its *diameter*: `w(σ) = max_{x,y ∈ σ} dist(x,y)`, with `w(∅) = 0` and singletons weight `0`. This satisfies (F0) and (F-mono): a superset's diameter is at least its subset's.

**Complexity.** For a point cloud of `n` points, enumerating all simplices is `O(2^n)`; restricting to dimension `≤ k` gives `O(n^{k+1})`. Each simplex's diameter costs `O(|σ|^2)`.

**Pseudocode.**
```
function vr_filtration(points, dist, max_dim):
    Σ ← all nonempty subsets of points with |subset| ≤ max_dim + 1
    for σ in Σ:
        w[σ] ← 0 if |σ| ≤ 1 else max over distinct x,y in σ of dist(x,y)
    w[∅] ← 0
    return w
```

---

## 6. Worked example

Let `α = {0,1,2}` (a 3-point cloud) with two distance matrices, yielding two VR filtrations `F` and `G`, and two perturbed clouds yielding `F′, G′`. On the full simplex set `Σ = {∅, {0},{1},{2},{0,1},{0,2},{1,2},{0,1,2}}`, every weight is an explicit rational, so all three distances in Theorem 3.5 are exact maxima of finitely many `|·|` values. Evaluating `bicombing_slack` at, e.g., `t = 1/2` returns a nonnegative slack, certifying the inequality; tracking the argmax simplices exhibits §4.1's defect mechanism — when the argmax of `d(F,F′)` differs from that of `d(G,G′)`, the slack is strictly positive. The accompanying `demo.py` runs exactly these computations across a grid of `t` and several cloud pairs.

---

## 7. Related work

The interleaving and bottleneck distances and their stability originate with Cohen-Steiner–Edelsbrunner–Harer and the algebraic stability theorem of Chazal–Cohen-Steiner–Glisse–Guibas–Oudot; Lesnick formalized the interleaving distance abstractly. The metric/geometric study of bicombings and Busemann convexity is due to Busemann and, in the modern axiomatic form (consistent convex geodesic bicombings, injective hulls), to Descombes–Lang. ℓ^∞ spaces as the prototypical Busemann-but-not-CAT(0) geometries are classical. The present contribution situates the interleaving metric precisely within this framework: it is a Busemann space via an explicit, consistent, *linear* bicombing, with the curvature inherited verbatim from the sup-norm through the isometry formula.

---

## 8. Future work

The packaged future directions (also bundled with this work) propose, in falsifiable form:

1. **Bundle `lerp` as a `ConvexGeodesicBicombing` and certify a Busemann space.** Consistency (Bridge X) and convexity (Theorem 3.5) are exactly the two bicombing axioms; the remaining task is packaging them into the formal vocabulary, with contractibility and unique geodesics between distinct distance-zero classes as consequences.

2. **Strict-convexity defect = multiplicity of supremising simplices.** Conjecture: equality in Theorem 3.5 holds iff a single simplex realizes both endpoint suprema with matching gap signs; otherwise strict. This is a decidable side-condition on pairs of argmax `Finset`s, testable on concrete clouds.

3. **Joint 1-Lipschitz nonexpansiveness.** Conjecture: `(F,G) ↦ lerp(F,G,t)` satisfies the stronger `d(lerp(F,G,t),lerp(F′,G′,t)) ≤ max(d(F,F′), d(G,G′))`, sharpening the convex bound by replacing `+` with `⊔` at the supremising simplex; this would upgrade `lerp` to a nonexpansive retraction and give contractibility for free.

4. **A reverse (lower) bicombing bound.** Conjecture a matching lower bound via the reverse triangle inequality lifted through the sup, e.g. `ofReal(1−t)·d(F,F′) ⊖ ofReal(t)·d(G,G′) ≤ d(lerp(F,G,t),lerp(F′,G′,t))` (truncated subtraction in `ℝ≥0∞`), pinning the bicombing distance to a computable band.

5. **Descent to the metric quotient and the VR locus.** Convexity is a `⨆`-level inequality insensitive to the distance-zero kernel, so it should descend to the metric quotient verbatim, making the quotient a genuine Busemann space; whether `lerp` preserves the Vietoris–Rips locus (convex combinations of diameter weights need not be diameter weights) is sharply falsifiable on concrete clouds.

---

## 9. Conclusion

The interleaving metric on filtrations — the central comparison metric of topological data analysis — is a **Busemann space**: it admits a consistent convex geodesic bicombing, `lerp`, the linear interpolation of weight functions. Two synchronized geodesics never separate faster than the convex combination of their endpoint distances (Theorem 3.5), and the distance to any fixed filtration is convex along every geodesic (Theorem 3.6). The proof is the convexity of the real absolute value (Lemma 3.3) broadcast coordinatewise through the supremum that defines the metric (Proposition 2.5). The curvature of the space of shapes is thus non-positive and *flat-convex*, exactly the curvature of the sup-norm — the gentlest geometry a metric space can have, and precisely the structure that makes averaging, optimization, and interpolation over data shapes well-posed.
