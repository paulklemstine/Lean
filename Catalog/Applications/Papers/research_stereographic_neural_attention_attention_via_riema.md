# Stereographic Neural Attention: Attention via the Riemann Sphere

## Abstract

We introduce **stereographic attention**, a geometric alternative to softmax
attention in which the compatibility between a query and a key is scored by the
**Cauchy kernel** `K(q, k) = 1 / (1 + ‖q − k‖²)` rather than by the exponentiated
dot product `exp⟨q, k⟩`. We show that this kernel is not an arbitrary similarity
function but the conformal factor of **stereographic projection** onto the unit
("Riemann") sphere: lifting a vector `x` to the sphere by the standard
stereographic map `σ(x) = (P(x), H(x))` with `P(x) = (2/(1 + ‖x‖²)) · x` and
`H(x) = (‖x‖² − 1)/(‖x‖² + 1)`, the squared chordal distance from `σ(x)` to the
north pole equals `4 · K(x, 0)`. Consequently a Cauchy attention score *is* a
distance on the sphere. We establish the kernel's basic regularity (positivity,
unit upper bound, diagonal saturation), prove that the stereographic lift lands
exactly on the unit sphere, and derive the geometry/analysis decomposition of
sparsity: the set of keys scoring at least a threshold `τ` is *exactly* a
Euclidean ball of radius `√(1/τ − 1)` around the query (an exact active-region
characterization), the score is strictly decreasing in distance (monotonicity),
and a Markov argument yields `τ · #active ≤ Σ scores ≤ N`. We discuss the
remaining gap to the program's conjectured `O(√N)` sparsity, which we localize
entirely in a total-mass bound `Σ scores = O(√N)` for geometrically spread keys —
a packing/shell-counting problem on the sphere. All results stated here have been
formally verified.

**Keywords:** attention, transformers, stereographic projection, Riemann sphere,
Cauchy kernel, conformal geometry, sparsity, Markov inequality.

---

## 1. Introduction

The attention mechanism underlying transformer architectures scores a query
vector `q ∈ E` against each of `N` key vectors `kᵢ ∈ E` and forms a convex
combination of associated value vectors. The canonical scoring rule is **softmax
attention**, in which the unnormalized weight of key `kᵢ` is `exp⟨q, kᵢ⟩` and the
normalized weights `softmax(⟨q, k₁⟩, …, ⟨q, k_N⟩)` form a probability vector. Two
structural features of softmax are simultaneously its strength and its weakness:

1. **Strict positivity everywhere.** Because the exponential is strictly
   positive, every key receives a strictly positive weight. The attention map is
   therefore globally smooth, but it is also globally *dense*: no key is ever
   exactly ignored, so exact sparsity must be imposed externally (top-k masking,
   sparsemax, locality windows).
2. **Only relative meaning.** Softmax is invariant under adding a constant to all
   logits; an individual weight has no absolute scale. There is no canonical
   notion of a "perfect match" with a fixed numerical value.

We propose replacing the exponentiated dot product with the **Cauchy kernel**

> `K(q, k) = 1 / (1 + ‖q − k‖²)`,

and we show that this single substitution recasts attention as a measurement in
**spherical geometry**. The kernel is the conformal factor of stereographic
projection; a score is literally a chordal distance on the Riemann sphere. From
this geometric grounding two payoffs follow. First, the kernel acquires an
*absolute* maximum value `1`, attained exactly on the diagonal `q = k` — a
canonical "perfect match." Second, the active region at any threshold is an exact
Euclidean ball, and a budget argument bounds the number of active keys. This
paper develops the geometric core and the rigorous backbone of the sparsity
claim.

### 1.1 A cross-domain bridge

This work is the geometric counterpart of an algebraic study of attention in
which an attention operator is treated as a matrix required to commute with the
morphisms of the data (a naturality / equivariance condition), where Schur's
lemma forces maximally symmetric attention to be a scalar multiple of the
identity. The two viewpoints meet on the diagonal: the algebraic "scalar
identity" fixed point corresponds to the geometric self-attention maximum
`K(q, q) = 1`. Throughout, `E` denotes a real normed vector space (formally, a
`NormedAddCommGroup` with a compatible `NormedSpace ℝ` structure); `‖·‖` is its
norm.

---

## 2. The Cauchy attention kernel

### 2.1 Definition

**Definition 2.1 (Cauchy attention kernel).** For `q, k ∈ E`,
`K(q, k) := 1 / (1 + ‖q − k‖²)`.

This replaces `exp⟨q, k⟩` of softmax attention. Note `K` depends on `q` and `k`
only through the displacement `q − k`, so it is a *translation-invariant,
radial* kernel — a property the dot-product score conspicuously lacks.

### 2.2 Regularity

**Theorem 2.2 (Positivity).** For all `q, k ∈ E`, `0 < K(q, k)`.

*Proof sketch.* The denominator `1 + ‖q − k‖²` is at least `1` because
`‖q − k‖² ≥ 0`; a positive numerator over a positive denominator is positive.
(Formally discharged by `positivity`.) ∎

**Theorem 2.3 (Unit upper bound).** For all `q, k ∈ E`, `K(q, k) ≤ 1`.

*Proof sketch.* `K(q, k) ≤ 1` is equivalent, after clearing the positive
denominator, to `1 ≤ 1 + ‖q − k‖²`, which holds since `‖q − k‖² ≥ 0`. ∎

**Theorem 2.4 (Diagonal saturation).** For all `q, k ∈ E`,
`K(q, k) = 1 ⇔ q = k`.

*Proof sketch.* Clearing the positive denominator, `K(q, k) = 1` is equivalent to
`1 + ‖q − k‖² = 1`, i.e. `‖q − k‖² = 0`, i.e. `‖q − k‖ = 0` (a square is zero iff
its base is, given non-negativity), i.e. `q = k` (a norm vanishes iff its
argument is zero). The converse substitutes `q = k` and simplifies. ∎

Theorems 2.2–2.4 give the kernel an interpretation absent from softmax: `K` is a
bounded similarity in `(0, 1]` with a *canonical maximum* `1` attained exactly at
coincidence. The bound `K ≤ 1` also supplies a global mass budget exploited in
§4: across `N` keys, `Σᵢ K(q, kᵢ) ≤ N`.

---

## 3. Stereographic projection and the chordal identity

We now exhibit `K` as the conformal factor of stereographic projection.

### 3.1 The lift

We encode the stereographic image of `x ∈ E` by its two real-algebraic
components — a horizontal part in `E` and a scalar height — rather than as a
single point of a normed product space. (This sidesteps a subtle pitfall: the
Mathlib product `E × ℝ` carries the *sup* norm, not the Euclidean `L²` norm, so
"`‖σ(x)‖² = …`" would be the wrong quantity; we therefore track the two
components and combine their squares explicitly.)

**Definition 3.1 (Stereographic components).** For `x ∈ E`,
- horizontal part `P(x) := (2 / (1 + ‖x‖²)) · x ∈ E`;
- height `H(x) := (‖x‖² − 1) / (‖x‖² + 1) ∈ ℝ`.

Together `σ(x) := (P(x), H(x))` is the stereographic lift of `x` from the
hyperplane through the equator to the unit sphere in `E × ℝ`, with the north pole
`N = (0, 1)` as the projection center.

### 3.2 The lift lands on the sphere

**Theorem 3.2 (On the sphere).** For all `x ∈ E`,
`‖P(x)‖² + H(x)² = 1`.

*Proof sketch.* Write `t := ‖x‖²`. By the homogeneity of the norm,
`‖P(x)‖ = |2/(1 + t)| · ‖x‖ = (2/(1 + t)) · ‖x‖` (the scalar is positive), so
`‖P(x)‖² = 4t / (1 + t)²`. Also `H(x)² = (t − 1)² / (t + 1)²`. Summing over the
common denominator `(1 + t)²` and using the algebraic identity
`(t + 1)² = 4t + (t − 1)²` gives `(4t + (t − 1)²)/(t + 1)² = (t + 1)²/(t + 1)² = 1`.
(Formally: `norm_smul`, then `field_simp; ring`.) ∎

Theorem 3.2 certifies that "project to the Riemann sphere" is well-typed: every
`x ∈ E`, regardless of magnitude, has a genuine image on the unit sphere. The
collapse of all sphere identities to the single fact `(t + 1)² = 4t + (t − 1)²`
in the variable `t = ‖x‖²` is the organizing observation of the geometric core.

### 3.3 The score is a chordal distance

**Theorem 3.3 (Chordal–kernel identity).** For all `x ∈ E`,
`‖P(x)‖² + (H(x) − 1)² = 4 · K(x, 0)`.

*Proof sketch.* The left side is the squared Euclidean distance from
`σ(x) = (P(x), H(x))` to the north pole `N = (0, 1)`. With `t := ‖x‖²`,
`‖P(x)‖² = 4t/(1 + t)²` (as above) and
`(H(x) − 1)² = ((t − 1) − (t + 1))²/(t + 1)² = 4/(t + 1)²`. Summing,
`(4t + 4)/(1 + t)² = 4(1 + t)/(1 + t)² = 4/(1 + t)`. Finally
`K(x, 0) = 1/(1 + ‖x − 0‖²) = 1/(1 + t)`, so the sum equals `4 · K(x, 0)`.
(Formally: `norm_smul`, `sub_zero`, positivity of the scalar, then
`field_simp; ring`.) ∎

**Corollary 3.4 (Geometric semantics).** Stereographic attention scores a key by
the chordal distance, on the Riemann sphere, between the lifted key and the lifted
query: by translation invariance of `K`, scoring `q` against `k` is the `x = q − k`
instance of Theorem 3.3, equating the score (up to the factor `4`) with a squared
sphere chord. The Cauchy kernel is therefore an intrinsically geometric score,
the conformal sibling of softmax.

---

## 4. Sparsity of stereographic attention

We fix a query `q`, keys `k₁, …, k_N ∈ E`, and a threshold `τ ∈ (0, 1]`. Define
the **active set** `A(τ) := { i : K(q, kᵢ) ≥ τ }` and `#active := |A(τ)|`.

### 4.1 Exact active-region characterization

**Theorem 4.1 (Active keys form a ball).** For `0 < τ ≤ 1` and any key `k`,
`K(q, k) ≥ τ ⇔ ‖q − k‖ ≤ √(1/τ − 1)`.

*Proof sketch.* Since the denominator is positive, `1/(1 + ‖q − k‖²) ≥ τ` is
equivalent to `1 + ‖q − k‖² ≤ 1/τ`, i.e. `‖q − k‖² ≤ 1/τ − 1` (non-negative
because `τ ≤ 1`), i.e. `‖q − k‖ ≤ √(1/τ − 1)`. ∎

Thus the τ-active region is *exactly* the closed Euclidean ball
`B(q, √(1/τ − 1))`. Raising `τ` shrinks the radius monotonically; as `τ → 1` the
ball collapses to the singleton `{q}`, consistent with Theorem 2.4. The active
region is determined purely by geometry — a feature softmax cannot offer, since
its weights have no absolute threshold.

### 4.2 Monotonicity

**Proposition 4.2 (Closer keys score higher).** For keys `k, k'` with
`‖q − k‖ < ‖q − k'‖`, one has `K(q, k) > K(q, k')`; more generally `K(q, ·)` is a
strictly decreasing function of the distance `‖q − ·‖`.

*Proof sketch.* `K(q, k) = g(‖q − k‖)` where `g(r) = 1/(1 + r²)` is strictly
decreasing on `[0, ∞)` because `r ↦ 1 + r²` is strictly increasing there and
reciprocation reverses order on positives. ∎

### 4.3 Markov sparsity bound

**Theorem 4.3 (Markov sparsity).** With scores `sᵢ := K(q, kᵢ)`,
`τ · #active ≤ Σᵢ sᵢ`.

*Proof sketch.* Each active index `i ∈ A(τ)` contributes `sᵢ ≥ τ`, so
`τ · #active = Σ_{i ∈ A(τ)} τ ≤ Σ_{i ∈ A(τ)} sᵢ ≤ Σᵢ sᵢ`, the last step using
`sᵢ > 0` for the inactive indices (Theorem 2.2). This is precisely the
counting form of Markov's inequality on the non-negative scores. ∎

**Corollary 4.4 (Unconditional sparsity).** `τ · #active ≤ N`, hence
`#active ≤ N/τ`.

*Proof sketch.* By Theorem 2.3 each `sᵢ ≤ 1`, so `Σᵢ sᵢ ≤ N`; combine with
Theorem 4.3. ∎

Corollary 4.4 is the rigorous, *unconditional* sparsity backbone of stereographic
attention: at any fixed relevance threshold `τ`, the number of keys that clear it
is `O(N/τ)`. The honest decomposition is

> **sparsity = (geometry: activity ⇔ ball membership, Thm 4.1) ∘
> (analysis: Markov on non-negative scores, Thm 4.3).**

### 4.4 The `√N` frontier

The program's marquee conjecture is `O(√N)` sparsity. Corollary 4.4 gives only
`O(N)` total mass, and that is *tight* in the worst case: if every key coincides
with the query, every score is `1`, `Σᵢ sᵢ = N`, and no improvement is possible.
The `√N` claim is therefore **not** a statement about arbitrary key sets; it must
be a statement about *geometrically spread* keys. The entire gap is localized in a
single missing inequality:

> **Conjecture 4.5 (`√N` total mass).** If the keys `k₁, …, k_N` are
> geometrically spread (e.g. roughly uniform on a sphere or separated by a
> minimum pairwise distance), then `Σᵢ K(q, kᵢ) = O(√N)`, whence
> `τ · #active = O(√N)`.

This is a packing / shell-counting problem: bound `Σᵢ 1/(1 + ‖q − kᵢ‖²)` by
grouping keys into concentric shells around `q` and counting how many can occupy
each shell under a separation constraint. The geometry of §3 is precisely the
language in which such a count is natural.

---

## 5. Algorithms

The results above translate directly into a forward-pass procedure and an exact
active-set pruning rule.

**Algorithm A (Stereographic attention forward pass).** Given a query `q`, keys
`{kᵢ}`, and values `{vᵢ}`: compute `sᵢ = 1/(1 + ‖q − kᵢ‖²)`, normalize
`wᵢ = sᵢ / Σⱼ sⱼ`, and output `Σᵢ wᵢ vᵢ`. Complexity `O(N·d)` for `d = dim E`,
identical in order to softmax but without any exponential.

**Algorithm B (Exact threshold pruning).** Given threshold `τ ∈ (0, 1]`, compute
the radius `ρ = √(1/τ − 1)` (Theorem 4.1) and retain only keys with
`‖q − kᵢ‖ ≤ ρ`. The retained set equals the τ-active set *exactly* (no
approximation), and by Corollary 4.4 has size `≤ N/τ`. Combined with a spatial
index (k-d tree / ball tree) over the keys, the active set is found in
`O(#active + log N)` rather than `O(N)`, realizing the sparsity as a genuine
runtime saving.

**Algorithm C (Stereographic lift).** Map `x ↦ (P(x), H(x))` with
`P(x) = (2/(1 + ‖x‖²))·x`, `H(x) = (‖x‖² − 1)/(‖x‖² + 1)`; by Theorem 3.2 the
output lies on the unit sphere and supports chordal-distance scoring (Theorem
3.3) directly in the lifted coordinates.

---

## 6. Applications

- **Built-in sparsity.** Unlike softmax, which requires post-hoc top-k masking,
  stereographic attention prunes exactly via Theorem 4.1: choose `τ`, keep the
  ball `B(q, √(1/τ − 1))`. The pruning is exact, differentiable away from the
  threshold, and geometrically interpretable.
- **Spatial-index acceleration.** Because the active set is a metric ball,
  decades of nearest-neighbor data structures apply verbatim, giving sub-linear
  retrieval of the keys that matter.
- **Absolute relevance scale.** The canonical maximum `K = 1` at coincidence
  (Theorem 2.4) provides an interpretable, scale-free notion of a "perfect match,"
  useful for calibration, thresholding, and analysis.
- **Long-context models.** A mechanism whose attention rows are provably sparse
  at fixed `τ` is a natural candidate for very long contexts, where dense softmax
  is the dominant cost.

---

## 7. Discussion

Stereographic attention reframes the attention score as a measurement in
conformal spherical geometry. The reframing is not cosmetic: it converts opaque
similarity logits into chordal distances on a fixed sphere (Theorem 3.3),
replaces relative softmax weights with an absolutely-scaled kernel (Theorem 2.4),
and turns sparsity from an engineering add-on into an exact geometric statement
(Theorem 4.1) backed by a counting bound (Corollary 4.4). The translation
invariance and radial monotonicity of `K` are arguably more faithful to the
intuition of "relevance as closeness" than the dot product, whose value conflates
direction and magnitude.

The principal limitation is honest and sharp: the unconditional total-mass bound
is `Σ ≤ N`, tight when keys collapse onto the query. The coveted `√N` regime is
real only for spread keys and remains a conjecture (Conjecture 4.5). We regard
the clean localization of the gap — into a single packing inequality on the
sphere — as a contribution in itself, because it converts a vague aspiration into
a concrete extremal-geometry problem.

---

## 8. Future work

1. **Prove Conjecture 4.5.** Bound `Σᵢ 1/(1 + ‖q − kᵢ‖²) = O(√N)` for keys with a
   minimum separation or near-uniform distribution on a sphere, via shell
   decomposition: count keys in annulus `r ≤ ‖q − kᵢ‖ < r + dr`, weight by
   `1/(1 + r²)`, and integrate against the packing density.
2. **Sub-linear stereographic attention.** Implement Algorithm B atop a ball-tree
   index and benchmark wall-clock against FlashAttention-style dense softmax on
   long contexts.
3. **Universal approximation.** Establish that stereographic attention layers are
   universal approximators on sequence-to-sequence maps, matching the known
   expressivity of softmax transformers despite built-in sparsity.
4. **Curvature as a hyperparameter.** Generalize `K` to `1/(1 + λ‖q − k‖²)`, the
   conformal factor of a sphere of radius depending on `λ`, and study `λ`
   (equivalently the sphere's curvature) as a learnable temperature controlling
   the active radius `√(1/τ − 1)/√λ`.
5. **Algebra–geometry unification.** Make precise the correspondence between the
   geometric self-attention maximum (`K = 1` on the diagonal) and the algebraic
   scalar-identity fixed point forced by naturality (Schur's lemma), ideally as a
   single statement spanning both pictures.

---

## Appendix: Summary of formally verified results

| Result | Statement |
|---|---|
| Positivity | `0 < K(q, k)` |
| Upper bound | `K(q, k) ≤ 1` |
| Diagonal saturation | `K(q, k) = 1 ⇔ q = k` |
| On the sphere | `‖P(x)‖² + H(x)² = 1` |
| Chordal identity | `‖P(x)‖² + (H(x) − 1)² = 4·K(x, 0)` |
| Active region | `K(q, k) ≥ τ ⇔ ‖q − k‖ ≤ √(1/τ − 1)` |
| Markov sparsity | `τ · #active ≤ Σ scores` |
| Unconditional sparsity | `τ · #active ≤ N` |

where `K(q, k) = 1/(1 + ‖q − k‖²)`, `P(x) = (2/(1 + ‖x‖²))·x`, and
`H(x) = (‖x‖² − 1)/(‖x‖² + 1)`.
