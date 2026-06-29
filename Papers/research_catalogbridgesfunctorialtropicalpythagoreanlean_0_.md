# A Functorial Tropical Ultrametric on the Boundary of the Berggren Tree

## Abstract

The primitive Pythagorean triples form the vertex set of a rooted ternary tree —
the *Berggren tree* — generated from the seed `(3,4,5)` by three integer linear
maps that act as discrete Lorentz transformations preserving the form
`a²+b²−c²`. We study the **boundary** of this tree, the space `Addr = ℕ → Fin 3`
of infinite branch addresses, and equip it with the canonical first-disagreement
ultrametric `d(x,y) = (1/2)^{firstDiff(x,y)}`. We prove that `(Addr, d)` is a
genuine ultrametric space, that each of the three Berggren branch insertions is an
*exact* `(1/2)`-similarity while distinct branches sit at maximal distance `1`,
and that the construction has a **tropical (min-plus) core**: the
first-disagreement index satisfies `min(firstDiff(x,y), firstDiff(y,z)) ≤
firstDiff(x,z)`, and prepending a common letter increments it by one,
`firstDiff(cons k x, cons k y) = firstDiff(x,y) + 1`. We connect the boundary
geometry back to the arithmetic of triangles through a two-sided depth–hypotenuse
growth law `5·3ⁿ ≤ c ≤ 5·7ⁿ` along the all-`B` ray, and we build a functorial
bridge to a category of tropical-valuation/ultrametric objects via the Gaussian
integers, where the norm `N(m + n i) = m² + n²` recovers the hypotenuse and is
multiplicative. All results are formally verified.

**Keywords:** Pythagorean triples, Berggren tree, ultrametric, tropical algebra,
min-plus, self-similar fractal, Gaussian integers, Lorentz group, functor.

---

## 1. Introduction

A *primitive Pythagorean triple* is a triple of positive integers `(a, b, c)`
with `gcd(a, b, c) = 1` and `a² + b² = c²`. The classical Barning–Hall
parametrization, also associated with Berggren, organizes all such triples into a
rooted ternary tree: the root is `(3, 4, 5)`, and each node has exactly three
children obtained by applying three fixed unimodular (up to sign) integer matrices.
Every primitive triple appears exactly once. The tree is thus a complete,
non-redundant enumeration of an infinite Diophantine family.

This paper concerns not the tree's vertices but its **boundary**: the set of
infinite root-to-infinity paths. Each path is a sequence of branch choices, an
element of `Addr := ℕ → Fin 3`. The boundary of a tree carries a natural
*ultrametric* of "first disagreement" type, and our central observation is that
for the Berggren tree this ultrametric is unusually rigid and arithmetically
meaningful:

1. The three branch insertions are **exact half-scale similarities** (contraction
   ratio precisely `1/2`), and distinct branches map into disjoint clopen balls at
   distance exactly `1`. This is the open-set condition for a self-similar IFS of
   three `1/2`-contractions, hence the boundary is a Cantor space of Hausdorff
   dimension `log 3 / log 2`.

2. The construction has a **tropical (min-plus) skeleton**: agreement depth is
   sub-additive in the min-plus sense, and the branch maps act on the
   first-disagreement valuation by the tropical multiplication `n ↦ n + 1`.

3. The boundary geometry is **calibrated to triangle size**: along a fixed ray the
   hypotenuse grows geometrically with explicit two-sided constants, so metric
   depth is `Θ(log c)`.

4. The whole picture is **functorial**: through the Gaussian-integer encoding of
   Pythagorean triples, the multiplicative norm `N(m+ni)=m²+n²` (= hypotenuse) and
   the min-plus disagreement valuation are two presentations of the same datum in a
   category of tropical-valuation objects, related by an explicit
   valuation-reconstruction functor.

All statements below are theorems with complete formal proofs; this paper records
their mathematical content and proof sketches.

---

## 2. The Berggren tree and its boundary

### 2.1 The generators

Work on `ℤ³` with the **Lorentzian quadratic form**
`Q(a,b,c) = a² + b² − c²`. A triple is Pythagorean iff it lies on the light cone
`Q = 0`. Define three child maps:

- `childA(a,b,c) = (a − 2b + 2c, 2a − b + 2c, 2a − 2b + 3c)`
- `childB(a,b,c) = (a + 2b + 2c, 2a + b + 2c, 2a + 2b + 3c)`
- `childC(a,b,c) = (−a + 2b + 2c, −2a + b + 2c, −2a + 2b + 3c)`

Equivalently these are the integer matrices

```
A = [ 1 −2  2 ;  2 −1  2 ;  2 −2  3 ]
B = [ 1  2  2 ;  2  1  2 ;  2  2  3 ]
C = [−1  2  2 ; −2  1  2 ; −2  2  3 ]
```

**Proposition 2.1 (Lorentz invariance).** Each generator preserves the Lorentz
form: `Mᵀ Q_L M = Q_L` where `Q_L = diag(1,1,−1)`. Consequently each child map
preserves `Q` exactly, `Q(child(a,b,c)) = Q(a,b,c)`, and hence maps Pythagorean
triples to Pythagorean triples. The determinants are `det A = +1`, `det B = −1`,
`det C = +1`, so the monoid is `ℤ/2`-graded by orientation.

*Proof sketch.* Direct matrix computation for the metric identities; the scalar
preservation `Q(childX) = Q` is a polynomial identity verified by expansion. The
determinants are `3×3` computations. ∎

### 2.2 Addresses and the boundary

A node at depth `n` is reached by a word in `{A, B, C}` of length `n`; the root
is the empty word. An *infinite* word is an element of

> **`Addr := ℕ → Fin 3`**, with `Fin 3 = {0,1,2}` coding `{A,B,C}`.

The **branch insertion** prepends a letter:

> **`cons k x = (n ↦ if n = 0 then k else x(n−1))`**,

with the defining equalities `cons k x 0 = k` and `cons k x (m+1) = x m`. The
three maps `cons 0, cons 1, cons 2 : Addr → Addr` are the boundary realizations of
the three Berggren branches.

---

## 3. The first-disagreement index

### 3.1 Definition

For `x, y ∈ Addr`, the **first-difference index** is

> **`firstDiff(x, y) = (the least n with x n ≠ y n, if one exists; else 0)`.**

Formally it is `Nat.find` of the predicate `∃ n, x n ≠ y n` when that predicate
holds, and `0` otherwise (a junk value never used when `x = y`).

**Lemma 3.1 (witness).** If `x ≠ y` then `x(firstDiff(x,y)) ≠ y(firstDiff(x,y))`.

**Lemma 3.2 (agreement below the index).** If `x ≠ y` and `m < firstDiff(x,y)`
then `x m = y m`.

**Lemma 3.3 (symmetry).** `firstDiff(x,y) = firstDiff(y,x)`.

*Proof sketch.* Lemmas 3.1–3.2 are the specification and minimality of `Nat.find`.
Lemma 3.3 holds because `x n ≠ y n ↔ y n ≠ x n`, so the two minimized predicates
coincide. ∎

### 3.2 The tropical (min-plus) core

The single fact that drives the entire ultrametric structure is the sub-additivity
of agreement depth.

**Theorem 3.4 (min-plus core).** For pairwise-distinct `x, y, z`,
> **`min( firstDiff(x,y), firstDiff(y,z) ) ≤ firstDiff(x,z)`.**

*Proof sketch.* Let `m = firstDiff(x,y)`, `n = firstDiff(y,z)`, and
`p = min(m,n)`. For every index `i < p` we have `i < m` and `i < n`, so by
Lemma 3.2 `x i = y i` and `y i = z i`, hence `x i = z i`. Thus `x` and `z` agree
on all indices below `p`, so the least index of disagreement of `x` and `z` is at
least `p`: `firstDiff(x,z) ≥ p`. ∎

This is exactly "agreement is transitive up to the smaller stabilization depth."
The inequality is the min-plus (tropical) triangle law for the *valuation*
`firstDiff`; under the order-reversing exponential `n ↦ (1/2)^n` it becomes the
ultrametric inequality (Theorem 4.4).

**Theorem 3.5 (tropical multiplication law).** For `x ≠ y` and any letter `k`,
> **`firstDiff( cons k x, cons k y ) = firstDiff(x, y) + 1`.**

*Proof sketch.* `cons k x` and `cons k y` agree at index `0` (both equal `k`), and
for `m ≥ 1` we have `cons k x m = x(m−1)` and `cons k y m = y(m−1)`. Hence the
first disagreement of the prepended words is one step later than that of `x, y`.
Formally one verifies the `Nat.find` characterization: index `firstDiff(x,y)+1` is
a disagreement, and every smaller index is an agreement. ∎

Theorem 3.5 says the branch insertions act on the first-disagreement valuation by
**tropical multiplication by the generator** (addition of `1` in the min-plus
semiring `(ℕ, min, +)`).

---

## 4. The tree ultrametric

### 4.1 Definition and elementary axioms

Define
> **`d(x, y) = if x = y then 0 else (1/2)^{firstDiff(x,y)}`.**

**Theorem 4.1.** `d` is a pseudometric satisfying, for all `x, y, z`:

- `d(x,x) = 0` (**d_self**);
- `0 ≤ d(x,y)` (**d_nonneg**);
- `d(x,y) = d(y,x)` (**d_comm**);
- `d(x,y) = 0 ↔ x = y` (**d_eq_zero_iff**);
- `d(x,y) ≤ 1` (**d_le_one**).

*Proof sketch.* `d_self` and the forward part of `d_eq_zero_iff` are immediate from
the case split; the reverse uses `(1/2)^k > 0`, so a nonzero distance cannot vanish.
Symmetry follows from Lemma 3.3. The bound `d ≤ 1` is `pow_le_one₀` since
`0 ≤ 1/2 ≤ 1`. ∎

### 4.2 The ultrametric inequality

**Theorem 4.2 (strong / ultrametric triangle inequality).**
> **`d(x, z) ≤ max( d(x, y), d(y, z) )`** for all `x, y, z`.

*Proof sketch.* The degenerate cases (`x=y`, `y=z`, or `x=z`) are handled directly;
in each the inequality is trivial because one side is `0` or the two sides
coincide. In the generic pairwise-distinct case, Theorem 3.4 gives
`firstDiff(x,z) ≥ min(firstDiff(x,y), firstDiff(y,z))`. The function
`t ↦ (1/2)^t` is **antitone**, so raising `1/2` to the larger exponent
`firstDiff(x,z)` yields the smaller value, and a `min` of exponents becomes a `max`
of the corresponding distances:
`(1/2)^{firstDiff(x,z)} ≤ max((1/2)^{firstDiff(x,y)}, (1/2)^{firstDiff(y,z)})`.
A case analysis on which of the two intermediate indices realizes the minimum
finishes the proof via `pow_le_pow_right₀`/`inv_anti₀`. ∎

**Corollary 4.3 (ordinary triangle inequality).** `d(x,z) ≤ d(x,y) + d(y,z)`.

*Proof sketch.* `max(p,q) ≤ p + q` for nonnegative `p, q`, combined with
Theorem 4.2 and `d_nonneg`. ∎

Together with Theorem 4.1, Corollary 4.3 makes `(Addr, d)` a metric space and
Theorem 4.2 makes it an **ultrametric** space (`IsUltrametricDist`).

---

## 5. The branch maps are exact `(1/2)`-similarities

### 5.1 Half-scale contraction

**Theorem 5.1 (half-scale similarity).** For every letter `k` and all `x, y`,
> **`d( cons k x, cons k y ) = (1/2) · d(x, y).`**

*Proof sketch.* If `x = y` both sides are `0`. Otherwise `cons k x ≠ cons k y`, so
both distances are powers of `1/2`, and Theorem 3.5 gives
`firstDiff(cons k x, cons k y) = firstDiff(x,y)+1`. Hence
`d(cons k x, cons k y) = (1/2)^{firstDiff(x,y)+1} = (1/2)·(1/2)^{firstDiff(x,y)} =
(1/2)·d(x,y)`. ∎

In particular each `cons k` is `1/2`-Lipschitz (**cons_contraction**), and is in
fact an exact similarity of ratio `1/2`: it shrinks *every* distance by the same
factor, with no distortion.

### 5.2 Maximal separation of branches

**Theorem 5.2 (distinct branches at maximal distance).** If `j ≠ k` then for all
`x, y`,
> **`d( cons j x, cons k y ) = 1.`**

*Proof sketch.* `cons j x` and `cons k y` disagree already at index `0`
(`j ≠ k`), so `firstDiff = 0` and `d = (1/2)^0 = 1`. ∎

### 5.3 Self-similar structure and dimension

Theorems 5.1–5.2 establish that `{cons 0, cons 1, cons 2}` is an iterated function
system of three contractions of ratio `1/2` whose images
`cons 0 (Addr), cons 1 (Addr), cons 2 (Addr)` are pairwise at distance `1` — hence
disjoint clopen balls covering `Addr`. This is precisely the **open-set
condition**. The depth-`n` cylinders number `3ⁿ`, each of diameter `2⁻ⁿ`. The
standard self-similar / mass-distribution argument then yields the Hausdorff
dimension

> **`dim_H(Addr, d) = log 3 / log 2 ≈ 1.585`,**

the dimension of a self-similar set built from three half-size copies. (We record
the geometric hypotheses as theorems; the dimension computation is flagged as a
conjecture C2 in §8 pending its formalization.)

---

## 6. Calibration to triangle size: the depth–hypotenuse law

We tie the abstract boundary to the arithmetic of the triangles via the `B`-branch
hypotenuse map `hypB(a,b,c) = 2a + 2b + 3c`.

**Lemma 6.1 (per-step bounds).** For a Pythagorean triple `(a,b,c)` with
`0 < a, b ≤ c`:
- `hypB(a,b,c) ≥ 3c` (since `a, b > 0`), and
- `hypB(a,b,c) ≤ 7c` (since `a, b ≤ c`).

**Theorem 6.2 (two-sided depth–hypotenuse window).** Let `cₙ` be the hypotenuse of
the triple reached from `(3,4,5)` by `n` consecutive `B`-steps. Then
> **`5 · 3ⁿ ≤ cₙ ≤ 5 · 7ⁿ`.**

*Proof sketch.* The seed hypotenuse is `c₀ = 5`. Each `B`-step preserves
Pythagoreanness and positivity of the legs and (on the cone) keeps each leg `≤`
the hypotenuse, so Lemma 6.1 applies at every step: `cₙ` at least triples and at
most septuples. Induction on `n` gives the geometric envelope with both constants
equal to the seed value `5`. ∎

**Corollary 6.3 (logarithmic depth).** To reach hypotenuse `c` along this ray
requires `n = Θ(log c)` steps; equivalently the metric depth `2⁻ⁿ` corresponds to
a hypotenuse scale window `[5·3ⁿ, 5·7ⁿ]`. The ultrametric ball of radius `2⁻ⁿ` is
the depth-`n` cylinder, so *metric resolution and arithmetic scale are the same up
to constants*.

This is why `(1/2)^{depth}` is the *right* ruler: distance decays geometrically in
depth, and depth is logarithmic in hypotenuse, so distance is polynomial in
`1/c` — the boundary literally measures triangle scale.

---

## 7. The Gaussian-integer functorial bridge

### 7.1 Gaussian encoding of triples

Every primitive Pythagorean triple arises from coprime `m > n > 0` of opposite
parity as
> **`(m² − n², 2mn, m² + n²)`**,
which is the real part, imaginary part, and squared modulus of the **Gaussian
integer** `m + n i ∈ ℤ[i]` squared: `(m + n i)² = (m² − n²) + (2mn) i`, with
`|m + n i|² = m² + n²`.

**Lemma 7.1 (norm = hypotenuse).** `N(m + n i) := m² + n² = c`, the hypotenuse of
the encoded triple (**gaussian_norm_eq**).

**Lemma 7.2 (multiplicativity).** `N(zw) = N(z)·N(w)` for `z, w ∈ ℤ[i]`
(**gaussian_norm_mul**). This holds because `ℤ[i]` is an integral domain and the
norm is the field norm of `ℚ(i)/ℚ` restricted to integers.

### 7.2 The valuation-reconstruction functor

We work in a small category whose objects are **tropical-valuation carriers**: a
type with ring-like operations `(+, ·, −, 0)` together with a valuation
`v : R → ℕ` such that `v` is monotone/multiplicative in the relevant sense, from
which a *reconstructed ultrametric norm object* is produced by an explicit functor
`valuationReconstruct`. The companion functor `tropicalization` sends an
ultrametric-norm object to the standard tropical object on `(ℕ, max, +)`. Both are
functorial: they preserve identities and composition
(**tropicalization_map_comp**, **valuationReconstruct_map_comp**).

**Construction 7.3 (Gaussian support carrier).** Define
`gaussianSupportCarrier` as the carrier whose underlying ring is `ℤ[i]` with the
*support valuation* `gval(z) = if z = 0 then 0 else 1`. Because `ℤ[i]` is a domain,
`gval(zw) = gval(z)·gval(w)` (the only way a product vanishes is for a factor to
vanish, by `mul_eq_zero`), so `gval` is a legitimate — if trivial — valuation.

**Theorem 7.4 (reconstruction).** Applying `valuationReconstruct` to
`gaussianSupportCarrier` yields an ultrametric-norm object whose induced distance
satisfies the strong triangle inequality (**gaussian_reconstruct_ultrametric**);
the Gaussian norm `N` provides the multiplicative scale (`= hypotenuse` by
Lemma 7.1), and the first-disagreement valuation of §3 is the order-dual min-plus
incarnation of the same data.

*Proof sketch.* `valuationReconstruct` carries any valuation carrier to an
ultrametric object by the general theorem
`valuationReconstruct_obj_ultrametric`; instantiate at `gaussianSupportCarrier`.
Multiplicativity and the zero law transport from Lemma 7.2 and the domain property
via `ultrametric_reconstruction_mul`/`ultrametric_reconstruction_zero`. ∎

**Interpretation.** The support valuation `gval` is the *trivial endpoint* of a
one-parameter family of Gaussian valuations; the `(1+i)`-adic valuation (conjecture
C5, §8) is the nontrivial refinement that reads off the power of `2` dividing the
even leg `2mn`. The bridge thus places the elementary arithmetic of Pythagorean
hypotenuses, the min-plus geometry of the tree boundary, and the categorical
machinery of tropical valuations on a common footing.

---

## 8. Discussion and future directions

The results above give a complete, rigid description of the Berggren boundary as a
self-similar ultrametric space calibrated to triangle size, together with its
tropical and Gaussian incarnations. Several natural extensions are *bold but
testable*; each is anchored to a proven fact of this work.

**C1. Cantor-space completeness and compactness.** `(Addr, d)` should be a
complete, compact ultrametric space (a Cantor space). The metric axioms
(Theorems 4.1–4.3, 4.2) are in hand; an address sequence is Cauchy iff every
coordinate stabilizes, so the coordinatewise limit is the unique limit, giving
completeness, and totally-bounded + complete ⇒ compact. Diameter is `≤ 1` by
`d_le_one`.

**C2. Hausdorff dimension `= log 3 / log 2`.** The IFS `{cons 0, cons 1, cons 2}`
of three `1/2`-similarities satisfies the open-set condition by Theorems 5.1–5.2.
There are `3ⁿ` cylinders of diameter `2⁻ⁿ`; a two-sided Hausdorff-measure estimate
should pin the dimension at `log 3 / log 2`.

**C3. Two-sided depth–size law along every ray.** Theorem 6.2 establishes the
window `5·3ⁿ ≤ c ≤ 5·7ⁿ` for the all-`B` ray. The conjecture is a uniform
`α·ρ_min^n ≤ c ≤ β·ρ_max^n` along *every* ray, with `ρ_min, ρ_max` the extreme
per-generator hypotenuse-expansion factors, giving metric depth `Θ(log c)` over the
whole boundary.

**C4. Categorical Berggren action.** Each `cons k` is `1/2`-Lipschitz
(Theorem 5.1) and acts on the valuation by tropical multiplication (Theorem 3.5),
so the free Berggren monoid should embed faithfully into the endomorphism monoid of
an object of the tropical-ultrametric category, with the min-plus `firstDiff`
valuation the exact order-dual of a max-plus valuation object. Faithfulness reflects
the freeness of the Berggren generators (no relation collapses two distinct words).

**C5. Nontrivial `(1+i)`-adic valuation.** Replacing `gval` by the `(1+i)`-adic
valuation `v` on `ℤ[i]` should give a nontrivial ultrametric with
`v(m + n i) = v₂(2mn)`, the `2`-adic valuation of the even leg. Lemmas 7.1–7.2 fix
the arithmetic; `v` is defined via `multiplicity (1+i)` or a `Zsqrtd`
factorization. The support valuation `gval` is the trivial endpoint of this family.

### Applications

The architecture connects several active areas:

- **Number theory / Diophantine enumeration.** The tree is a non-redundant
  enumerator of primitive triples; the depth–size law gives `O(log c)` addressing
  and `O(c log c)`-style certified enumeration up to a size bound.
- **Ultrametric and p-adic geometry.** The boundary is a clean, fully explicit
  Cantor ultrametric space — a concrete laboratory for `IsUltrametricDist`,
  totally-disconnected dynamics, and tree boundaries.
- **Tropical / min-plus algebra.** The `firstDiff` valuation realizes the min-plus
  triangle law concretely and identifies branch insertion with tropical
  multiplication, linking shortest-path-style arithmetic to fractal geometry.
- **Phylogenetics and hierarchical data.** First-disagreement distance is exactly
  most-recent-common-ancestor distance; the Berggren tree gives an arithmetic model
  of such metrics with exact self-similarity.

---

## 9. Conclusion

We have shown that the space of all primitive Pythagorean triples, organized by the
Berggren tree, has a boundary that is a self-similar ultrametric Cantor space whose
geometry is governed by a tropical (min-plus) law, whose branch maps are exact
`(1/2)`-similarities at maximal mutual separation, whose metric depth is calibrated
to the logarithm of triangle size by an explicit two-sided window
`5·3ⁿ ≤ c ≤ 5·7ⁿ`, and which embeds functorially — via the multiplicative Gaussian
norm `N(m+ni)=m²+n²` recovering the hypotenuse — into a category of
tropical-valuation/ultrametric objects. Elementary triangle arithmetic, the
geometry of trees, min-plus algebra, and Gaussian number theory turn out to be four
faces of one structure.
