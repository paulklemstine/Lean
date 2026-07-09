# The Mathematics of Memes: Sheaf Cohomology of Meme Propagation on Social Networks

## Abstract

We model the propagation of a meme across a social network as the **constant cellular
sheaf** on a finite undirected graph, and compute the dimensions of its zeroth and first
cohomology groups. For a finite graph `G = (V, E)` with the constant sheaf `M` of meme
interpretations valued in a field `K`, we prove

1. `dim H⁰(G, M) = #components(G)`, and
2. `dim H¹(G, M) = |E| − |V| + #components(G)`.

All results are formalized and machine-checked in Lean 4 / Mathlib, in the files
`Catalog/MachineLearning/MemeGraphCohomology.lean` (base theory) and
`Catalog/MachineLearning/MemeDisconnectedCohomology.lean` (the disconnected computation).

## 1. The model

A **social network** is presented as a finite vertex type `V` (the people), a finite edge
type `E` (the communication channels), and two endpoint maps `src tgt : E → V`. A **meme**
is the constant sheaf `K` placed at every vertex, with identity restriction along every
edge.

* A **0-cochain** `f : V → K` assigns an interpretation of the meme to each person.
* A **1-cochain** `g : E → K` records a discrepancy along each channel.
* The **coboundary** operator `δ : (V → K) → (E → K)` is
  `(δ f) e = f (tgt e) − f (src e)`,
  measuring the failure of `f` to be consistent across a channel.

The cohomology of the two-term cochain complex `0 → (V → K) →ᵟ (E → K) → 0` is:

* `H⁰ = ker δ` — the **globally consistent interpretations** (global sections of the
  sheaf);
* `H¹ = coker δ = (E → K) / range δ` — the **consistency obstructions**.

In Lean: `MemeGraph.coboundary`, `MemeGraph.H0`, `MemeGraph.H1`.

## 2. Base theory

`MemeGraphCohomology.lean` establishes the elementary structure:

* `coboundary_const`, `const_mem_H0` — a meme that means the same thing to everyone is
  globally consistent.
* `mem_H0_iff` — `f ∈ H⁰ ↔ ∀ e, f (src e) = f (tgt e)`: consistency across every channel.
* `finrank_range_add_finrank_H0` — rank–nullity: `dim (range δ) + dim H⁰ = |V|`.
* `finrank_H1` — `dim H¹ + dim (range δ) = |E|`.
* `euler_characteristic` — combining the two, `dim H⁰ − dim H¹ = |V| − |E|`. This is a
  topological invariant of the network, independent of the interpretation field.

### Connected components

* `Adj src tgt u v` — two people are adjacent when a channel joins them (in either
  direction); `adj_symmetric` records that this relation is symmetric.
* `Reach = Relation.ReflTransGen Adj` — reachability by a chain of channels.
* `compSetoid` — the equivalence relation "same connected component", built from `Reach`
  (reflexive and transitive by construction, symmetric because `Adj` is).
* `components src tgt = Nat.card (Quotient (compSetoid src tgt))` — the number of
  connected components.
* `H0_eq_of_adj`, `H0_eq_of_reachable` — a globally consistent interpretation takes equal
  values on adjacent, hence on reachable (same-component), people.

## 3. The disconnected computation

`MemeDisconnectedCohomology.lean` computes both dimensions with **no connectivity
hypothesis**. Let `q : V → Quotient (compSetoid src tgt)` be the map sending each person
to their component, and let `compPullback = LinearMap.funLeft K K q` be precomposition
with `q`.

### 3.1 `range_funLeft_eq_ker`

**Theorem.** `range (compPullback) = H⁰`.

*Proof.* An interpretation of the form `g ∘ q` is constant on each component, and the two
endpoints of any edge lie in the same component, so `δ (g ∘ q) = 0`; hence
`range ⊆ H⁰`. Conversely, if `f ∈ H⁰` then `f` is constant on components
(`H0_eq_of_reachable`), so it factors as `f = (Quotient.lift f) ∘ q`, giving
`H⁰ ⊆ range`. ∎

This is the mathematical heart: **global sections = functions constant on components.**

### 3.2 `graph_dimH0_components`

**Theorem.** `dim H⁰ = #components(G)`.

*Proof.* By `range_funLeft_eq_ker`, `H⁰ = range (compPullback)`. Because `q` is surjective
(`Quotient.mk_surjective`), `compPullback` is injective
(`LinearMap.funLeft_injective_of_surjective`), so
`dim H⁰ = dim (Quotient → K) = #components(G)` (via `finrank_fintype_fun_eq_card`). ∎

### 3.3 `graph_euler_components`

**Theorem.** `dim H¹ = |E| − |V| + #components(G)`.

*Proof.* Substitute `dim H⁰ = #components(G)` into the Euler characteristic
`dim H⁰ − dim H¹ = |V| − |E|` and solve for `dim H¹`. ∎

This is the **first Betti number** of the graph: the number of independent communication
cycles across the entire (possibly disconnected) network.

## 4. Dependency structure (no circularity)

The three headline lemmas form a strict dependency chain, each using only previously
established results and never referencing itself:

```
mem_H0_iff, H0_eq_of_reachable, compSetoid       (base file)
        │
        ▼
range_funLeft_eq_ker
        │
        ▼
graph_dimH0_components   (uses range_funLeft_eq_ker + funLeft injectivity)
        │
        ▼
graph_euler_components   (uses graph_dimH0_components + euler_characteristic)
```

## 5. Formal verification

Both Lean files build against Mathlib (Lean 4, toolchain `v4.28.0`) with no `sorry` and no
custom axioms. Each of `range_funLeft_eq_ker`, `graph_dimH0_components`, and
`graph_euler_components` depends only on `propext`, `Classical.choice`, and `Quot.sound`.

## 6. Interpretation

* `H⁰` counts the number of *distinct coherent meanings* a meme can hold across the
  network: exactly one per connected community.
* `H¹` counts *irreducible obstructions to consistency* — the independent cycles of
  communication along which the meme can drift and create ambiguity.
* The Euler identity `dim H⁰ − dim H¹ = |V| − |E|` ties these together into a single
  topological invariant of the social graph.
