# Future Directions — The Minimum-Spanning-Tree Law for `H₀` Persistence and Beyond

## Synthesis

The file `Catalog/Speculative/AutoResearch/ProteinFoldingMST.lean` formalizes the
degree-`0` total-persistence law in a fully constructive, computable setting. The
mathematical core turned out to be far cleaner than the homological framing
suggests: once the *death multiset* `D` of the `H₀` persistence diagram is fixed,
the entire connectivity history of a single-linkage filtration is recoverable by
elementary counting. We proved

- `layer_cake` — the discrete Fubini / layer-cake identity
  `∑_{t<T} #{d∈D : t<d} = ∑_{d∈D} min d T`, the engine of everything else;
- `totalPersistence_eq_sum` — **the MST Law**: for a horizon dominating every
  death, total `H₀` persistence equals `∑_{d∈D} d`, i.e. the total weight of a
  minimum spanning tree;
- `beta0_antitone` and `beta0_eventually_one` — the component-count curve is
  monotone non-increasing and reaches a single component above the largest death;
- a constructive Kruskal merge process (`kruskalDeaths`) plus a `decide`-checked
  optimality theorem (`mst_optimal_ex`) and the capstone
  `mst_persistence_law_example`, which on an explicit `4`-vertex graph ties the
  persistence side to the optimization side.

This is a deliberate cross-domain bridge: it links **topological data analysis**
(`H₀` persistence), **combinatorial optimization** (minimum spanning trees /
Kruskal), and **order-theoretic counting** (the layer-cake identity), and it
connects naturally to the catalog's Fibonacci/entry-point work in
`CarmichaelComposite.lean` and `FibPrimitive.lean` only at the meta level of
"extract the decisive discrete invariant, then count."

## Results Summary

Four `sorry`-free theorems of genuine content (`layer_cake`,
`totalPersistence_eq_sum`, `beta0_antitone`, `beta0_eventually_one`), three
`rfl`/`decide`-level verification theorems (`kruskalDeaths_ex`,
`kruskal_weight_ex`, `mst_optimal_ex`), and one capstone conjunction
(`mst_persistence_law_example`). All depend only on `propext`,
`Classical.choice`, `Quot.sound`. Everything is computable: `kruskalDeaths`,
`beta0`, `totalPersistence`, `spans`, and `wsum` all run under `#eval`.

## Research Directions

### 1. Kruskal correctness in general: deaths = MST edge weights for arbitrary graphs

Right now MST optimality is verified only on an explicit graph by `decide`. The
falsifiable claim is that for *every* finite weighted graph whose edge list is
sorted by weight, the multiset `kruskalDeaths es` equals the multiset of edge
weights of some minimum spanning tree, and its sum is `≤ wsum s` for every
spanning subset `s`. **The key insight is** that a merge happens precisely when an
edge joins two distinct components, so the merge-edges form an independent set of
the graphic matroid grown greedily — the matroid exchange property then forces
optimality with no geometry involved. **Why now?** The constructive `kstep`/`kruskalAux`
fold already exposes exactly the "distinct component" test the matroid argument
needs, so the proof reduces to a clean invariant on the labelling function rather
than to homology.

### 2. The `β₀` curve is the right-continuous step function with exactly `card D` jumps

We proved `beta0` is antitone and eventually `1`. The sharper, falsifiable
statement is that `beta0 D` jumps by exactly the multiplicity of each death value
and is otherwise constant, so that `beta0 D 0 - 1 = (D.filter (0 < ·)).card`
counts all finite bars and the total number of jumps equals `D.card`. **The key
insight is** that `#{d∈D : t<d}` decreases by `count v D` exactly as `t` crosses
`v`, making `beta0` a literal survival function of the death distribution. **Why
now?** With `layer_cake` in hand, the jump structure is the differenced version of
an identity we already control, so it is a short step rather than new theory.

### 3. Stability: total persistence is `1`-Lipschitz in the death multiset

A cornerstone of TDA is the stability theorem. Here it specializes to a sharp,
falsifiable bound: if two death multisets `D`, `D'` of equal cardinality are
matched so that the `k`-th smallest deaths differ by at most `ε`, then
`|totalPersistence D T − totalPersistence D' T| ≤ card D · ε`, and in fact the
bottleneck/Wasserstein-1 distance equals `∑_k |sort(D)_k − sort(D')_k|`. **The key
insight is** that under the MST Law total persistence is a sorted-`ℓ¹` functional
of the death vector, so classical rearrangement inequalities give stability
directly. **Why now?** The `min d T` truncation already proven in
`totalPersistence_eq_min_sum` is exactly the clipping that makes the Lipschitz
constant finite and explicit.

### 4. Higher horizons and the integrated lifetime functional

Generalize `totalPersistence` to a weighted area `∑_{t<T} g(t)·(beta0 D t − 1)`
for monotone weights `g`, modelling persistence-weighted descriptors used in
protein contact maps. The falsifiable claim: this equals `∑_{d∈D} G(min d T)`
where `G` is the discrete antiderivative of `g`, a weighted layer-cake identity.
**The key insight is** that the unweighted proof is the `g ≡ 1` case of an Abel
summation that goes through verbatim for any nonnegative weight. **Why now?** The
inductive `layer_cake` proof is structured exactly as the cons-step accumulation
that Abel summation needs, so the generalization reuses the same skeleton.

### 5. From multiset to point cloud: a verified single-linkage dendrogram

Close the modelling gap by defining a metric point cloud on `Fin n`, deriving its
sorted edge list, and proving the produced `kruskalDeaths` multiset is an
*invariant* of the cloud (independent of tie-breaking order among equal weights).
The falsifiable claim: two different sorted edge orders of the same weighted graph
yield equal `kruskalDeaths` multisets. **The key insight is** that ties merge the
same components regardless of order because the union-find state after processing
all edges of a given weight is order-independent — a confluence property of the
fold. **Why now?** `kruskalAux` is already a deterministic fold over an explicit
list, so order-independence is a concrete commutation lemma we can state and test
with `#eval` before proving.
