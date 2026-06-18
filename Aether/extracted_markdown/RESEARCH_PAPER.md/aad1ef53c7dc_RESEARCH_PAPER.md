# The Minimum-Spanning-Tree Law for `H₀` Persistence: A Constructive, Computable Account

## Abstract

We give a fully constructive and computable treatment of the degree-zero
total-persistence law of topological data analysis (TDA). For the connected-component
invariant `H₀` of a single-linkage (Vietoris–Rips) filtration, every finite
persistence bar is born at filtration value `0`, so the persistence diagram is
determined entirely by its multiset `D` of *death times*. We prove a discrete
layer-cake (Fubini) identity expressing the area under the component-count curve
as a truncated sum of death times, and derive from it the **Minimum-Spanning-Tree
(MST) Law**: once the observation horizon dominates every death, the total `H₀`
persistence equals the plain sum of the death times, which is exactly the total
weight of a minimum spanning tree of the underlying weighted graph. We
characterize the component-count curve `β₀` as a monotone non-increasing
staircase that stabilizes at a single component above the largest death, and we
close the loop on the optimization side with a constructive Kruskal merge process
whose recorded deaths are verified — by exhaustive decidable search on an
explicit graph — to realize the minimum spanning weight. All definitions are
computable (they evaluate under direct reduction), all weights are taken in `ℕ`
to preserve decidability without loss of combinatorial content, and every
theorem is established by elementary order-theoretic counting rather than
homological machinery. We conclude with proof sketches, complexity remarks,
applications to molecular contact analysis, and a program of generalizations.

**Keywords:** persistent homology, `H₀`, total persistence, minimum spanning
tree, Kruskal's algorithm, single-linkage clustering, layer-cake identity,
discrete Fubini, topological data analysis.

---

## 1. Introduction

Topological data analysis summarizes the multiscale "shape" of data through
persistent homology, which tracks topological features (connected components,
loops, voids) across a one-parameter filtration. The degree-zero part, `H₀`,
records connected components and is by far the most widely used in practice: it
underlies single-linkage clustering, dendrograms, and a host of descriptors in
the natural sciences, including the analysis of protein contact maps during
folding.

A pleasant structural fact about `H₀` is that, for a connected ambient space (or
for the limit of a Vietoris–Rips filtration on a finite point cloud), every
finite feature is born at the bottom of the filtration. The persistence diagram
is therefore one-dimensional data: a multiset `D` of *death times*, namely the
filtration values at which two previously distinct components first merge. By the
classical correspondence between single-linkage merges and Kruskal's algorithm,
this multiset is exactly the multiset of edge weights of a minimum spanning tree
(MST) of the complete weighted graph on the point cloud.

This paper isolates the purely combinatorial content of "total `H₀`
persistence." We show that the area under the component-count curve is a
telescoping (layer-cake) quantity equal to a truncated sum of death times, and
hence — past a dominating horizon — to the MST weight. The development is
deliberately elementary: it needs no chain complexes, no functoriality, and no
real analysis. Restricting weights to `ℕ` keeps every object decidable and
directly evaluable, while losing no generality (rational distances rescale to
integers).

### Contributions

1. **A discrete layer-cake identity** (`layer_cake`, §3) equating the
   column-sum of alive-component counts with the row-sum of truncated death
   times.
2. **The MST Law** (`totalPersistence_eq_sum`, §4): total `H₀` persistence past
   a dominating horizon equals the sum of death times, i.e. the MST weight.
3. **Structural characterization of `β₀`** (§5): the component-count curve is
   antitone and eventually equal to `1`, with an explicit value at threshold `0`.
4. **A constructive Kruskal process** (§6) whose recorded death multiset is, on
   an explicit graph, verified by exhaustive decidable search to realize the
   minimum spanning weight (`mst_optimal_ex`), unified with the persistence side
   in a capstone theorem (`mst_persistence_law_example`).

All results are machine-checked and depend only on the standard foundational
axioms (`propext`, `Classical.choice`, `Quot.sound`); the brute-force optimality
check is purely computational.

---

## 2. Definitions

Throughout, `D : Multiset ℕ` is the multiset of `H₀` death times. Multisets allow
repeated values, modeling simultaneous merges (ties in edge weight). We write
`#S` for the cardinality of a (sub)multiset `S` and `∑` for the natural-number
sum.

**Definition 2.1 (Component-count curve `β₀`).** For a death multiset `D` and a
threshold `t ∈ ℕ`,
```
  β₀(D, t)  =  1 + #{ d ∈ D : t < d }.
```
The `+1` is the single essential component (the never-dying class `[0, ∞)`); the
counted term is the number of finite bars still alive at threshold `t`, i.e. those
whose death strictly exceeds `t`.

**Definition 2.2 (Total `H₀` persistence).** For a horizon `T ∈ ℕ`,
```
  P(D, T)  =  ∑_{t ∈ {0,…,T-1}} ( β₀(D, t) − 1 ).
```
This is the discrete area under the curve `t ↦ β₀(D, t) − 1`, i.e. above the
floor of one persistent component.

**Definition 2.3 (Alive-count integrand).** Since `β₀(D, t) − 1 = #{ d ∈ D : t <
d }` (the `+1` cancels exactly; see Lemma 3.1), we equivalently have
```
  P(D, T)  =  ∑_{t < T} #{ d ∈ D : t < d }.
```

**Definition 2.4 (Truncated death sum).** For each death `d` and horizon `T`,
`min(d, T)` is the contribution of that death capped at the horizon. The
*truncated death sum* is `∑_{d ∈ D} min(d, T)` (formally, the sum of the multiset
`D.map (d ↦ min d T)`).

On the optimization side we model a weighted graph as a list of edges.

**Definition 2.5 (Edges and Kruskal step).** An edge is a triple `(u, v, w) ∈ ℕ ×
ℕ × ℕ` (endpoints `u, v`, weight `w`). The component structure is a labelling
function `f : ℕ → ℕ` assigning each vertex its current component representative.
One Kruskal step on edge `(u, v, w)` is
```
  kstep(f, (u,v,w)) =
     if f(u) = f(v)  then  (f, none)                          -- already merged
     else                  (f', some w),  where
        f'(x) = if f(x) = f(v) then f(u) else f(x)            -- relabel v's class to u's
```
emitting the death `w` exactly when the edge joins two distinct components.

**Definition 2.6 (Kruskal death multiset).** Folding `kstep` over a
weight-sorted edge list, starting from the identity labelling `id` (every vertex
its own component), and collecting the emitted weights yields
```
  kruskalDeaths(es)  =  multiset of weights w emitted by the fold.
```

**Definition 2.7 (Spanning and weight).** A subset `s` of edges *spans* the
vertex set `{0, …, n−1}` iff the reachability closure from vertex `0` covers all
vertices (`spans`). Its total weight is `wsum(s) = ∑_{(u,v,w) ∈ s} w`.

---

## 3. The discrete layer-cake identity

The technical heart of the development is a discrete Fubini / layer-cake identity.

**Lemma 3.1 (Integrand simplification).** For all `D, t`,
```
  β₀(D, t) − 1  =  #{ d ∈ D : t < d }.
```
*Proof.* By Definition 2.1, `β₀(D, t) = 1 + #{d ∈ D : t < d}`; subtracting `1`
(natural-number subtraction, here exact because the term is `1 + k`) cancels the
leading `1`. ∎

**Theorem 3.2 (Layer-cake identity, `layer_cake`).** For every death multiset `D`
and horizon `T`,
```
  ∑_{t < T} #{ d ∈ D : t < d }   =   ∑_{d ∈ D} min(d, T).
```

*Proof sketch.* Induct on `D` (multiset induction). The empty case is `0 = 0`.
For the cons step `D = a ::ₘ D'`, split each side additively. On the left, the
predicate `t < (a ::ₘ D')` contributes, column by column, the indicator `[t < a]`
on top of the contribution of `D'`; summed over `t < T` this gives
```
  ∑_{t < T} [t < a]  =  #{ t ∈ {0,…,T−1} : t < a }  =  min(a, T),
```
because the thresholds satisfying `t < a` within `{0, …, T−1}` are exactly
`{0, …, min(a,T) − 1}`. On the right, the new death `a` contributes precisely
`min(a, T)`. Both sides therefore increase by the same amount, and the inductive
hypothesis handles `D'`. The crucial set identity
```
  { t ∈ range T : t < a }  =  range (min(a, T))
```
is what makes the column-count collapse to `min(a, T)`. ∎

The identity is the discrete avatar of Fubini's theorem: summing the survival
counts along *threshold columns* equals summing truncated lifetimes along *death
rows*.

**Corollary 3.3 (`totalPersistence_eq_min_sum`).** `P(D, T) = ∑_{d ∈ D} min(d,
T)`.
*Proof.* Combine Definition 2.3 with Theorem 3.2. ∎

---

## 4. The MST Law

**Theorem 4.1 (MST Law, `totalPersistence_eq_sum`).** If the horizon dominates
every death, i.e. `d ≤ T` for all `d ∈ D`, then
```
  P(D, T)  =  ∑_{d ∈ D} d.
```

*Proof.* By Corollary 3.3, `P(D, T) = ∑_{d ∈ D} min(d, T)`. For each `d ∈ D` the
hypothesis gives `d ≤ T`, hence `min(d, T) = d`. The truncated sum therefore
collapses to the plain sum `∑_{d ∈ D} d`. ∎

**Interpretation.** Because the death multiset `D` of `H₀` coincides with the
multiset of MST edge weights of the single-linkage filtration (Kruskal's
correspondence; verified computationally in §6), Theorem 4.1 states that the total
`H₀` persistence past a dominating horizon equals the **total weight of a minimum
spanning tree**. A purely topological accumulation (area under the component
staircase) equals a purely combinatorial optimum (cheapest connecting skeleton).

---

## 5. Structure of the component-count curve

**Theorem 5.1 (Antitone, `beta0_antitone`).** For fixed `D`, the map `t ↦ β₀(D,
t)` is non-increasing: if `a ≤ b` then `β₀(D, b) ≤ β₀(D, a)`.

*Proof sketch.* It suffices to show the alive-count is monotone non-increasing.
If `a ≤ b`, then `b < x` implies `a < x`, so the predicate `(b < ·)` is pointwise
weaker than `(a < ·)`; hence the filtered submultiset `{x ∈ D : b < x}` is
contained (counted with multiplicity) in `{x ∈ D : a < x}`. Cardinality is
monotone under multiset inclusion, so the alive-count at `b` is `≤` that at `a`,
and adding the constant `1` preserves the inequality. ∎

Topologically: increasing the connectivity radius can only merge components,
never split them.

**Theorem 5.2 (Eventual unity, `beta0_eventually_one`).** If `d ≤ T` for all `d ∈
D`, then `β₀(D, T) = 1`.

*Proof.* Under the hypothesis there is no `d ∈ D` with `T < d`, so the filtered
multiset `{d ∈ D : T < d}` is empty and its cardinality is `0`; thus `β₀(D, T) =
1 + 0 = 1`. ∎

**Proposition 5.3 (Value at zero, `beta0_zero`).** `β₀(D, 0) = 1 + #{ d ∈ D : 0 <
d }`.
*Proof.* Immediate from Definition 2.1 at `t = 0`. ∎

Together, Theorems 5.1–5.2 and Proposition 5.3 say `β₀(D, ·)` is a
right-descending staircase that begins at `1 +` (number of strictly positive
deaths) and decreases monotonically to the terminal value `1` once the threshold
clears the largest death.

---

## 6. The optimization side: a constructive Kruskal process

We now realize the death multiset constructively and certify MST optimality.

**The process.** Starting from the identity labelling `id` (Definition 2.5,
every vertex its own representative), fold `kstep` over the weight-sorted edge
list (Definition 2.6). Each edge whose endpoints carry distinct labels triggers a
relabel (merging the two classes) and emits its weight as a death; edges within an
existing class are skipped. This is single-linkage clustering, and the emitted
multiset is the multiset of MST edge weights.

**Algorithmic complexity.** With the naive function-relabelling representation
used here, each merge relabels in `O(n)` and processing `m` sorted edges costs
`O(m·n)` after an `O(m log m)` sort; a union-find representation reduces the merge
cost to near-constant amortized time, giving the classical `O(m α(n))` Kruskal
bound. The function-based version is chosen for transparency and direct
evaluability rather than asymptotic speed.

**Explicit graph.** Take vertices `{0, 1, 2, 3}` and the weight-sorted edge list
```
  exEdges = [ (0,1,1), (1,2,2), (0,2,3), (2,3,4), (1,3,5), (0,3,6) ].
```

**Theorem 6.1 (Kruskal selection, `kruskalDeaths_ex`).** `kruskalDeaths(exEdges)
= {1, 2, 4}`.
*Proof.* Direct evaluation of the fold. Edge `(0,1,1)` merges `0,1` (death `1`);
`(1,2,2)` merges `2` into `{0,1}` (death `2`); `(0,2,3)` is skipped (already
connected); `(2,3,4)` merges `3` (death `4`); the remaining edges are skipped. ∎

**Theorem 6.2 (Kruskal weight, `kruskal_weight_ex`).**
`(kruskalDeaths(exEdges)).sum = 7`.
*Proof.* `1 + 2 + 4 = 7` by evaluation. ∎

**Theorem 6.3 (MST optimality, `mst_optimal_ex`).** For every sublist `s ⊆
exEdges` that spans `{0,1,2,3}`, `7 ≤ wsum(s)`.
*Proof.* Exhaustive decidable search over all `2⁶ = 64` edge subsets: each
spanning subset is checked to have weight at least `7`. The check is finite and
decidable, hence closed by reduction. ∎

**Theorem 6.4 (Capstone, `mst_persistence_law_example`).** On the example graph,
```
  P( kruskalDeaths(exEdges), 7 )  =  (kruskalDeaths(exEdges)).sum,
```
and every spanning sublist has weight at least that sum. In numbers, the
persistence-side area and the optimization-side minimum coincide at `7`.
*Proof.* The first conjunct is Theorem 4.1 applied to `D = {1,2,4}` with horizon
`T = 7` (each death `≤ 7`); the second is Theorem 6.3. ∎

This capstone unifies the two sides: the topological area `P` (Definition 2.2)
equals the Kruskal death sum (Theorem 4.1), which is the provable minimum
spanning weight (Theorem 6.3).

---

## 7. Worked numerics

For `D = {1, 2, 4}` and horizon `T = 7`, the component-count staircase is
```
  t:      0   1   2   3   4   5   6
  alive:  3   2   1   1   0   0   0     ( = #{d ∈ D : t < d} )
  β₀:     4   3   2   2   1   1   1     ( = 1 + alive )
```
The area under `β₀ − 1` is `3 + 2 + 1 + 1 + 0 + 0 + 0 = 7`, matching the death
sum `1 + 2 + 4 = 7` exactly. The layer-cake identity reads `7 = min(1,7) +
min(2,7) + min(4,7) = 1 + 2 + 4`. Reducing the horizon to, say, `T = 3` truncates
each death: `P(D,3) = min(1,3) + min(2,3) + min(4,3) = 1 + 2 + 3 = 6`, which is
the partial staircase area `3 + 2 + 1 = 6`.

---

## 8. Applications

**Single-linkage clustering and dendrograms.** The death multiset is the set of
merge heights of the single-linkage dendrogram. The MST Law identifies the
"total dendrogram height budget" with the MST weight, giving an exact, integer
descriptor of how clustered a data set is.

**Molecular contact analysis.** In protein folding, the evolving connectivity of
residue/atom contact graphs as a distance threshold relaxes is summarized by
`H₀`. Total persistence provides a single robust scalar — the truncated MST
weight — that compresses the entire merging history, suitable as a feature for
comparing conformations.

**Robust feature extraction.** Because total persistence is now a sum of
truncated death times, it inherits a transparent stability: small perturbations
to the underlying distances perturb the sorted death vector by a controlled
amount, and the truncation `min(·, T)` bounds the Lipschitz constant explicitly
(see §9, Direction 3).

---

## 9. Discussion and future work

The development demonstrates a methodological motif: *extract the decisive
discrete invariant, then count.* For `H₀` total persistence the invariant is the
death multiset, and once it is fixed the topology evaporates into the layer-cake
identity. We list concrete, falsifiable continuations.

**1. General Kruskal correctness.** Prove, for *every* finite weighted graph with
edges sorted by weight, that `kruskalDeaths` equals the multiset of MST edge
weights and that its sum is `≤ wsum(s)` for every spanning subset `s`. The key
mechanism: a merge happens exactly when an edge joins two distinct components, so
the merge-edges form a greedily grown independent set of the graphic matroid; the
matroid exchange property forces optimality with no geometry. The constructive
fold already exposes the "distinct component" test the matroid argument needs.

**2. Exact jump structure of `β₀`.** Sharpen monotonicity to: `β₀(D, ·)` jumps
down by exactly the multiplicity of each death value and is otherwise constant,
so the total number of jumps equals `#D` and `β₀(D, 0) − 1` counts all finite
bars. This is the differenced form of the layer-cake identity.

**3. Stability (1-Lipschitz).** Show total persistence is `1`-Lipschitz in the
death multiset: for equal-cardinality matched multisets whose `k`-th smallest
deaths differ by at most `ε`, `|P(D,T) − P(D',T)| ≤ #D · ε`, with the
Wasserstein-1 distance equal to `∑_k |sort(D)_k − sort(D')_k|`. Under the MST Law
total persistence is a sorted-`ℓ¹` functional, so rearrangement inequalities give
stability directly; the `min(·, T)` truncation makes the constant finite and
explicit.

**4. Weighted lifetime functionals.** Generalize to `∑_{t<T} g(t)·(β₀(D,t) − 1)`
for monotone weights `g`, modeling persistence-weighted descriptors. The claim:
this equals `∑_{d∈D} G(min(d,T))` where `G` is the discrete antiderivative of
`g` — a weighted layer-cake identity obtained by Abel summation, reusing the
inductive skeleton of Theorem 3.2 verbatim (the unweighted case is `g ≡ 1`).

**5. From multiset to point cloud.** Define a metric point cloud on `{0,…,n−1}`,
derive its sorted edge list, and prove `kruskalDeaths` is an *invariant* of the
cloud, independent of tie-breaking among equal weights: two sorted edge orders of
the same weighted graph yield equal death multisets. The mechanism is confluence
of the fold — the union-find state after processing all edges of a given weight is
order-independent.

---

## 10. Conclusion

We have shown that the degree-zero total persistence of a single-linkage
filtration is, at the level of counting, pure discrete Fubini. The layer-cake
identity (Theorem 3.2) drives the MST Law (Theorem 4.1), which equates a
topological area with a combinatorial optimum; the component-count curve is a
monotone staircase settling at a single component (Theorems 5.1–5.2); and a
constructive Kruskal process certifies the optimization side computationally
(Theorems 6.1–6.4). The entire account is elementary, decidable, and directly
evaluable, and it offers a clean template for weighted generalizations and
stability results. The bridge between topological data analysis, combinatorial
optimization, and order-theoretic counting is not a metaphor here — it is the same
sum, viewed three ways.
