# Computational Evidence — Meme Sheaf Cohomology

We model a social network as a finite directed graph `(V, E, src, tgt)` and a meme as the
**constant sheaf** valued in a field `K`. The coboundary is `(δ f) e = f(tgt e) − f(src e)`.

* `H⁰ = ker δ` — globally consistent interpretations (its dimension = number of distinct
  interpretations).
* `H¹ = coker δ` — consistency obstructions (its dimension = first Betti number).

All formulas below are the specializations of the machine-checked theorems in
`MemeSheafCohomology.lean`. For any finite graph:

```
dim H⁰ = number of connected components          (= distinct interpretations)
dim H¹ = |E| − |V| + (number of components)      (= first Betti number, "independent cycles")
dim H⁰ − dim H¹ = |V| − |E|                       (Euler characteristic; euler_characteristic)
```

## 1. Small-case table

| Graph                         | \|V\| | \|E\| | components | dim H⁰ | dim H¹ | H⁰−H¹ = V−E |
|-------------------------------|------:|------:|-----------:|-------:|-------:|:-----------:|
| single vertex                 |   1   |   0   |     1      |   1    |   0    |   1 = 1     |
| edgeless (n vertices)         |   n   |   0   |     n      |   n    |   0    |   n = n     |
| path P₂ (2 nodes, 1 edge)     |   2   |   1   |     1      |   1    |   0    |   1 = 1     |
| tree on n nodes (n−1 edges)   |   n   |  n−1  |     1      |   1    |   0    |   1 = 1     |
| triangle C₃                   |   3   |   3   |     1      |   1    |   1    |   0 = 0     |
| cycle Cₙ                      |   n   |   n   |     1      |   1    |   1    |   0 = 0     |
| two disjoint edges            |   4   |   2   |     2      |   2    |   0    |   2 = 2     |
| triangle ⊔ isolated vertex    |   4   |   3   |     2      |   2    |   1    |   1 = 1     |

Every row satisfies the Euler identity `dim H⁰ − dim H¹ = |V| − |E|`, which is the
capstone theorem `euler_characteristic`. The connected rows (components = 1) satisfy
`dim H⁰ = 1` (`finrank_H0_of_connected`) and `dim H¹ = |E| − |V| + 1`
(`betti_one_of_connected`). The edgeless row realises the maximal `dim H⁰ = |V|`
(`finrank_H0_of_edgeless`).

## 2. Where the sequence lives

`dim H¹ = |E| − |V| + c` is the **circuit rank / cyclomatic number** of a graph. For the
cycle graphs `Cₙ` it is constantly `1`; for the complete graphs `Kₙ` it is
`n(n−1)/2 − n + 1 = (n−1)(n−2)/2` (OEIS A000217 shifted: 0, 0, 1, 3, 6, 10, … for
n = 1,2,3,4,5,6). These match direct hand computation.

## 3. Counterexample hunt on the informal conjecture

The mission's informal conjecture states the "most viral" meme has **`H¹ = 0` and `H⁰`
of maximal dimension**. Testing this against the formulas exposes a genuine tension, which
our theorems make precise:

* `dim H⁰` is *maximal* (`= |V|`) **iff the graph is edgeless** (`finrank_H0_of_edgeless`).
  But an edgeless network has no channels, so a meme cannot spread at all. Thus
  "maximal `H⁰`" is incompatible with "spreads everywhere".
* `dim H¹ = 0` holds **iff `|E| = |V| − c`, i.e. the graph is a forest** (every connected
  component is a tree — no redundant channels).

So the honest refinement supported by the proofs is: a meme with `H¹ = 0` and *large*
`dim H⁰` corresponds to a **fragmented forest** — it spreads freely and unambiguously
*within* each tree-shaped community but carries a *different* interpretation in each of the
many components, and cannot cross between them. No counterexample to the *theorems* was
found (they are proved); rather, the computation clarifies that the literal "maximal `H⁰`"
phrasing of the conjecture describes total fragmentation, not universal virality.

## 4. Method

These are closed-form evaluations of the proved theorems, so the evidence is exact rather
than sampled. The theorems themselves (not just the table) are machine-checked in
`MemeSheafCohomology.lean` with only the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).
