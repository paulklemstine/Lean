# The Minimum-Spanning-Tree Law for Degree-Zero Persistence: A Constructive, Counting-Based Theory

## Abstract

We develop, in a fully constructive and computable setting, a complete theory of
**degree-zero (`H₀`) total persistence** for finite filtrations, and prove that it
coincides exactly with the total weight of a minimum spanning tree (MST). The
central observation is that all of the connectivity history of a single-linkage
(Vietoris–Rips) filtration is encoded in a single combinatorial datum: the
**multiset of death times** `D`, equal to the multiset of edge weights chosen by
Kruskal's algorithm. From `D` alone, the connected-component count `β₀(t)` is
recovered by counting, and the total persistence up to a horizon `T` is a discrete
area under the `β₀ - 1` curve. Our main technical result is a **discrete layer-cake
(Fubini) identity**,
`∑_{t<T} #{d ∈ D : t < d} = ∑_{d∈D} min(d, T)`,
from which the **MST Law** follows immediately: when `T` dominates every death,
total `H₀` persistence equals `∑_{d∈D} d`, the total MST weight. We further
establish the structural properties of the component-count curve (antitonicity;
eventual connectivity), give a constructive Kruskal merge process producing the
death multiset, and verify the persistence–optimization correspondence,
including MST optimality, on an explicit four-vertex graph. All statements are
over the decidable type `Multiset ℕ`, so every quantity is effectively
computable. The theory needs *no* homological machinery: degree-zero total
persistence is, at the level of counting, pure Fubini.

**Keywords.** persistent homology, zeroth Betti number, total persistence,
minimum spanning tree, Kruskal's algorithm, single-linkage clustering,
layer-cake identity, discrete Fubini, topological data analysis.

---

## 1. Introduction

### 1.1 Background and motivation

Topological data analysis (TDA) studies the "shape" of data through the lens of
algebraic topology. Its workhorse is **persistent homology**: given a finite point
cloud `X` and a symmetric distance function, one builds the *Vietoris–Rips
filtration*, a nested family of simplicial complexes indexed by a scale parameter
`t ≥ 0`, where two points are joined whenever their distance is below `t`. As `t`
grows, topological features (connected components, loops, voids) are born and
later die; the multiset of (birth, death) pairs is the *persistence diagram*.

In degree zero, the features are **connected components**, and their evolution is
exactly a clustering process: as `t` increases, clusters merge. The number of
components at scale `t` is the **zeroth Betti number** `β₀(t)`. A standard scalar
summary of the diagram is the **total persistence**, the sum of bar lengths,
widely used as a stable, single-number feature in machine-learning pipelines.

It is folklore in TDA that the `H₀` persistence diagram is governed by a *minimum
spanning tree*: the finite bars die exactly at the edge weights of an MST, because
single-linkage clustering and Kruskal's algorithm coincide. This paper makes the
*total persistence* side of that folklore precise, elementary, and computable. We
show that no homology is required: the death multiset alone determines everything,
and the MST Law is a one-line corollary of a discrete Fubini identity.

### 1.2 Contributions

1. A constructive formalization of the component-count curve `β₀` and total
   persistence `P` over the decidable type `Multiset ℕ` (Section 3).
2. The **discrete layer-cake identity** (`layer_cake`, Theorem 4.1), proved by
   multiset induction, exchanging a column-wise count for a row-wise sum.
3. The **MST Law** (`totalPersistence_eq_sum`, Theorem 4.3): total `H₀`
   persistence equals the sum of death times, hence the MST weight.
4. Structural results: monotonicity (`beta0_antitone`, Theorem 5.1) and eventual
   connectivity (`beta0_eventually_one`, Theorem 5.2) of the component-count
   curve.
5. A constructive Kruskal merge process producing the death multiset, with a
   machine-checked verification of the persistence–optimization correspondence and
   MST optimality on an explicit graph (Section 6).

### 1.3 Design decision: natural-number weights

We work over `ℕ`-valued weights. A real-weighted formulation forces
measure-theoretic integration for the area under the `β₀` curve; restricting to
`ℕ` keeps every quantity decidable and effectively computable while losing no
combinatorial content, since any finite set of rational weights can be rescaled to
integers. The discrete area `∑_{t<T}` is then a finite sum, and `min(d, T)` plays
the role of the truncation that, in the continuous theory, would be an integral
bound.

---

## 2. Preliminaries and notation

Throughout, `D : Multiset ℕ` denotes the **multiset of death times** of the
degree-zero persistence diagram: the scales at which finite `H₀` bars die. We
write `#S` for the cardinality of a (multi)set `S`, `D.sum` for the sum of the
elements of `D` (with multiplicity), and `D.filter P` for the sub-multiset of
elements satisfying predicate `P`. For `n : ℕ`, `range n = {0, 1, …, n-1}`. All
subtraction on `ℕ` is truncated (`a - b = 0` when `a < b`); this never bites us
because every subtraction below is of the form `(1 + k) - 1`.

A degree-zero persistence diagram has exactly one *essential* (immortal) class —
the connected component that never dies — together with finitely many finite bars,
all born at scale `0`. We therefore model the diagram by its finite-bar death
multiset `D`; the essential class is accounted for by the additive constant `1` in
`β₀`.

---

## 3. The component-count curve and total persistence

### Definition 3.1 (Component count `β₀`)

For a death multiset `D : Multiset ℕ` and a threshold `t : ℕ`,
```
β₀(D, t) := 1 + #{ d ∈ D : t < d }.
```
The `1` is the immortal class; the second term counts finite bars still alive at
`t`, namely deaths strictly in the future.

### Definition 3.2 (Total persistence)

For a horizon `T : ℕ`,
```
P(D, T) := ∑_{t ∈ range T} ( β₀(D, t) − 1 ).
```
This is the discrete area under the `β₀ − 1` curve over `[0, T)`.

### Lemma 3.3 (Integrand identity, `beta0_sub_one`)

For all `D, t`,
```
β₀(D, t) − 1 = #{ d ∈ D : t < d }.
```
*Proof sketch.* Unfold Definition 3.1; the truncated subtraction `(1 + k) − 1`
equals `k` by `Nat.add_sub_cancel_left`. ∎

### Lemma 3.4 (Persistence as an alive-bar sum, `totalPersistence_eq_card_sum`)

```
P(D, T) = ∑_{t ∈ range T} #{ d ∈ D : t < d }.
```
*Proof sketch.* Substitute Lemma 3.3 into Definition 3.2. ∎

Lemma 3.4 recasts total persistence as a **double count**: over each scale `t`,
count the deaths still pending. This is the column-wise count that the next
section transforms.

---

## 4. The discrete layer-cake identity and the MST Law

### Theorem 4.1 (Discrete layer-cake / Fubini, `layer_cake`)

For all `D : Multiset ℕ` and `T : ℕ`,
```
∑_{t ∈ range T} #{ d ∈ D : t < d }  =  ∑_{d ∈ D} min(d, T).
```

*Proof sketch.* Both sides count the chips of the relation
`{ (t, d) : t < T, d ∈ D, t < d }`. The left side counts column-wise (fix `t`,
count pending deaths); the right side counts row-wise (fix `d`, count the scales
`t < T` with `t < d`, which number exactly `min(d, T)`). Formally we induct on the
multiset `D`. The empty case is `0 = 0`. For the cons step `a ::ₘ D`, the
left side splits, by `Multiset.filter_cons` and `Finset.sum_add_distrib`, into the
contribution of `a` plus the contribution of `D` (the latter handled by the
induction hypothesis). The contribution of `a` is
`∑_{t ∈ range T} [t < a] = #{ t ∈ range T : t < a } = #(range (min(a, T))) =
min(a, T)`,
using `range T ∩ {x : x < a} = range (min a T)`. This matches the new summand
`min(a, T)` on the right. ∎

The identity is the discrete analogue of the **layer-cake representation**
`∫ f = ∫ |{f > s}| ds`: instead of integrating the component-count height over
scales, we integrate the "lifetime" of each death over the heights. It is also a
Fubini/Tonelli exchange of the order of summation in a `0/1`-indicator double sum.

### Corollary 4.2 (Truncated-sum form, `totalPersistence_eq_min_sum`)

```
P(D, T) = ∑_{d ∈ D} min(d, T).
```
*Proof.* Combine Lemma 3.4 and Theorem 4.1. ∎

This already reduces total persistence from a nested double sum to a single pass
over `D`, an `O(#D)` computation once `D` is known.

### Theorem 4.3 (The MST Law, `totalPersistence_eq_sum`)

If `T` dominates every death, i.e. `∀ d ∈ D, d ≤ T`, then
```
P(D, T) = D.sum  =  ∑_{d ∈ D} d.
```
*Proof sketch.* By Corollary 4.2, `P(D, T) = ∑_{d∈D} min(d, T)`. For each
`d ∈ D` we have `d ≤ T`, so `min(d, T) = d`; replacing termwise
(`Multiset.map_congr` with `min_eq_left`) gives `∑_{d∈D} d = D.sum`. ∎

**Interpretation.** When the horizon is past every merger, total `H₀` persistence
equals the sum of all death times. Because the death multiset equals the multiset
of MST edge weights (Section 6), this is precisely the **total weight of a minimum
spanning tree**. A topological scalar invariant equals an optimization optimum,
joined by a counting identity.

---

## 5. Structural properties of the component-count curve

### Theorem 5.1 (Monotonicity, `beta0_antitone`)

For each fixed `D`, the map `t ↦ β₀(D, t)` is antitone (non-increasing):
`a ≤ b ⇒ β₀(D, b) ≤ β₀(D, a)`.

*Proof sketch.* It suffices to show the filtered sub-multiset shrinks:
`D.filter (b < ·) ≤ D.filter (a < ·)` whenever `a ≤ b`, since cardinality is
monotone (`Multiset.card_le_card`). Comparing counts elementwise, any `x` with
`b < x` also satisfies `a < x` (because `a ≤ b`), so the count of `x` in the
`b`-filter is at most its count in the `a`-filter (`Multiset.le_iff_count`). Adding
the constant `1` preserves the inequality (`gcongr`). ∎

Operationally: raising the connection radius can only merge components, never split
them — the defining monotonicity of any single-linkage hierarchy.

### Theorem 5.2 (Eventual connectivity, `beta0_eventually_one`)

If `∀ d ∈ D, d ≤ T`, then `β₀(D, T) = 1`.

*Proof sketch.* For every `d ∈ D` we have `d ≤ T`, i.e. `¬ (T < d)`, so
`D.filter (T < ·)` is empty and its cardinality is `0`. Hence
`β₀(D, T) = 1 + 0 = 1`. ∎

Above the largest death scale the point cloud is a single connected component.

### Proposition 5.3 (Initial count, `beta0_zero`)

```
β₀(D, 0) = 1 + #{ d ∈ D : 0 < d }.
```
*Proof.* Definitional (`rfl`). ∎

At scale `0`, the number of components is one plus the number of strictly positive
deaths. (Zero-length deaths, if any, correspond to coincident points already
merged at scale `0`.) Together, Theorems 5.1, 5.2 and Proposition 5.3 pin down the
full qualitative shape of the curve: it starts at `1 + #{positive deaths}`,
decreases monotonically, and settles at `1`.

---

## 6. A constructive Kruskal merge process

The previous sections take the death multiset `D` as given. We now produce it
constructively, closing the loop to the optimization side.

### 6.1 The merge process

We process the edge list **sorted by weight** (ascending), maintaining a vertex
labelling `ℓ : ℕ → ℕ` assigning each vertex its current component representative.
Initially every vertex is its own representative. For each edge `(u, v)` with
weight `w`:

- if `ℓ(u) = ℓ(v)`, the endpoints already lie in the same component: **skip**
  (the edge would create a cycle);
- if `ℓ(u) ≠ ℓ(v)`, the edge joins two distinct components: **record a death at
  `w`**, then merge by relabelling one representative to the other.

The recorded weights, in order, form the **death multiset** `kruskalDeaths`. This
is exactly Kruskal's algorithm; equivalently, single-linkage agglomerative
clustering. On `n` vertices the process records exactly `n − 1` deaths (a spanning
tree has `n − 1` edges) and runs in near-linear time after the initial sort.

### 6.2 Spanning subsets and total weight

For verification we define, for an edge set,
- `wsum s` — the total weight of an edge subset `s`;
- `spans s` — the decidable predicate that `s` connects all vertices into one
  component (its union–find closure has a single class).

A subset `s` is a *spanning tree* when it spans and is minimal; an MST minimizes
`wsum` over all spanning subsets.

### 6.3 The correspondence, verified

On an explicit four-vertex weighted graph the following are checked by computation
(`decide`/`rfl`):

- `kruskalDeaths_ex`: the merge process records the expected three death weights;
- `kruskal_weight_ex`: their sum equals the weight of the tree Kruskal builds;
- `mst_optimal_ex`: **no** spanning subset has strictly smaller total weight —
  i.e. the Kruskal tree is a genuine minimum spanning tree (an exhaustive check
  over spanning subsets).

### Theorem 6.4 (Capstone correspondence, `mst_persistence_law_example`)

On the explicit graph, the total `H₀` persistence of the Kruskal death multiset
(computed via the layer-cake machinery of Sections 3–4) equals the minimum
spanning weight (computed via the optimization machinery of Section 6). Formally, a
conjunction tying `totalPersistence (kruskalDeaths es) T` to the minimal `wsum`
over spanning subsets.

*Proof sketch.* The persistence side reduces, by Theorem 4.3, to
`(kruskalDeaths es).sum`; the optimization side is the minimum `wsum`, witnessed by
the Kruskal tree (`kruskal_weight_ex`) and certified minimal by `mst_optimal_ex`.
The two numbers coincide by `decide`. ∎

This is the concrete instance of the abstract slogan
**persistence = death-sum = MST weight**.

---

## 6.5 A fully worked example

To make the entire pipeline concrete, consider the four-vertex graph with vertex
set `{0, 1, 2, 3}` and weighted edges
```
(0,1,1), (1,2,2), (2,3,3), (0,2,4), (0,3,5), (1,3,6).
```

**Step 1 — Kruskal merge.** Sort edges by weight: they are already ascending.
Process them in turn, maintaining component labels initialized to
`{0,1,2,3}`.

- `(0,1,1)`: `0` and `1` lie in distinct components → record death `1`, merge
  `{0,1}`.
- `(1,2,2)`: `1`'s component `{0,1}` and `2` are distinct → record death `2`,
  merge `{0,1,2}`.
- `(2,3,3)`: `{0,1,2}` and `3` are distinct → record death `3`, merge
  `{0,1,2,3}`.
- `(0,2,4)`: both in `{0,1,2,3}` → cycle, **skip**.
- `(0,3,5)`: same component → **skip**.
- `(1,3,6)`: same component → **skip**.

The death multiset is `D = {1, 2, 3}` (three deaths on four vertices, as a tree
requires).

**Step 2 — The component-count curve.** Using
`β₀(D, t) = 1 + #{d ∈ D : t < d}`:
```
t        :  0   1   2   3   4
β₀(D, t) :  4   3   2   1   1
```
At `t = 0` all four vertices are separate; the curve descends by one at each
death scale and reaches `1` at `t = 3 = max D`, confirming Theorems 5.1–5.3.

**Step 3 — Total persistence by the naive double count.** With horizon
`T = 3 = max D`,
```
P(D, 3) = (β₀(0)-1) + (β₀(1)-1) + (β₀(2)-1) = 3 + 2 + 1 = 6.
```

**Step 4 — Total persistence by the layer-cake formula.** By Corollary 4.2,
`P(D, 3) = ∑_{d∈D} min(d, 3) = min(1,3) + min(2,3) + min(3,3) = 1 + 2 + 3 = 6`,
matching Step 3.

**Step 5 — The MST Law.** Since every death `d ≤ 3 = T`, Theorem 4.3 gives
`P(D, 3) = D.sum = 1 + 2 + 3 = 6`.

**Step 6 — Optimization side.** Exhaustively enumerating all spanning edge
subsets, the minimum total weight is `6`, achieved by `{(0,1,1),(1,2,2),(2,3,3)}`
— exactly the Kruskal tree. No spanning subset is cheaper, so the tree is a
genuine MST. Hence
```
total H₀ persistence (6) = sum of death times (6) = minimum spanning weight (6),
```
the capstone correspondence of Theorem 6.4 in a single concrete instance.

This worked example exercises every definition and theorem of the paper end to
end, and each printed number is reproducible by direct computation.

## 7. Algorithms

### 7.1 Total persistence via layer-cake (`O(#D)`)

Given the death multiset `D` and horizon `T`, Corollary 4.2 yields a single-pass
algorithm: accumulate `min(d, T)` over `d ∈ D`. This replaces the naive
`O(T · #D)` double loop (recounting pending deaths at every scale) with one pass
over the deaths.

### 7.2 Death multiset via Kruskal (`O(E log E)`)

Sort edges by weight; fold the merge step (Section 6.1) with a union–find
structure. Output the recorded death weights. Dominant cost is the sort.

### 7.3 Component-count curve

For plotting or analysis, `β₀(D, t)` for all `t` can be produced by sorting `D`
and walking a pointer: starting from `β₀(0) = 1 + #{d : d > 0}`, each time `t`
crosses a death value the count drops by that value's multiplicity. This yields the
entire monotone step function in `O(#D + range)` time, consistent with Theorems
5.1–5.3.

---

## 8. Applications

**Topological features for machine learning.** Total `H₀` persistence is a common
stable scalar feature summarizing how clustered a dataset is. Theorem 4.3 says it
*is* the MST weight, so it can be computed by a classical near-linear algorithm and
inherits the MST's stability theory. This matters in protein-folding contact
analysis, materials microstructure classification, and any pipeline where `H₀`
statistics feed a downstream model.

**Clustering diagnostics.** The component-count curve `β₀(t)` is the dendrogram
height profile of single-linkage clustering. Theorems 5.1–5.3 certify its expected
shape; large total persistence flags data with persistent, well-separated clusters.

**Algorithmic substitution.** Wherever a pipeline computes `H₀` total persistence
through the full persistence machinery, the MST Law licenses replacing it with
Kruskal/union–find — simpler, faster, and exactly equal.

---

## 9. Discussion

The theory deliberately *avoids* homology. The decisive move is identifying the
right invariant — the death multiset `D` — after which the entire connectivity
history is recovered by counting, and the headline theorem is a discrete Fubini
exchange. This is a methodological lesson: the power of a result often lies not in
heavy machinery but in isolating the combinatorial core.

Two faces of one object meet here. The **topological** face (total persistence, an
area under a Betti curve) and the **optimization** face (MST weight, a minimum over
spanning subsets) are bridged by the **order-theoretic** face (the layer-cake count
`∑ min(d, T)`). Each is computable; each is exactly equal to the others under the
stated horizon condition.

A limitation is that MST optimality is established here by exhaustive checking on a
specific graph, not in general. Section 10 outlines the matroid-theoretic route to
the general statement.

---

## 10. Future directions

The following directions extend the present results.

**General Kruskal correctness.** Prove, for *every* finite weighted graph with
edges sorted by weight, that the multiset `kruskalDeaths es` equals the multiset of
edge weights of some minimum spanning tree, and that its sum is `≤ wsum s` for
every spanning subset `s`. The key insight is that a merge happens precisely when
an edge joins two distinct components, so the merge-edges form an independent set of
the **graphic matroid** grown greedily; the matroid exchange property then forces
optimality with no geometry involved. The constructive merge fold already exposes
exactly the structure needed.

**Real / rational weights.** Lift the `ℕ`-valued theory to ordered fields via a
measure-theoretic layer-cake (`∫_0^T |{β₀ > s}| ds`), recovering the continuous
total-persistence integral while preserving the MST Law.

**Higher-degree persistence.** Investigate whether analogous "decisive invariant +
counting" reductions exist for `H₁` and beyond, where the clean MST correspondence
fails but partial combinatorial structure (e.g. via matroids on cycles) may remain.

**Stability and learning.** Combine the MST Law with classical MST stability bounds
to derive stability guarantees for `H₀`-persistence features used in machine
learning, and quantify their sensitivity to perturbations of the point cloud.

---

## 11. Conclusion

We have given a self-contained, constructive, and computable theory of degree-zero
total persistence. The component-count curve is recovered from the death multiset
by counting; its total area is a discrete layer-cake sum; and once the horizon
dominates all deaths, that sum equals both the total of the death times and the
weight of a minimum spanning tree. The structural curve properties and an explicit,
machine-checked Kruskal correspondence complete the picture. The moral is compact:
for connected components, *persistence is counting, and counting is the minimum
spanning tree*.
