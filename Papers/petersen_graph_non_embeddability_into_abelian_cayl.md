# Computational Evidence — Petersen graph and bipartite abelian Cayley hosts

## 1. The Petersen graph and its odd girth

Model: Kneser graph `K(5,2)`. Vertices are the `C(5,2) = 10` two-element subsets
of `{0,1,2,3,4}`; two vertices are adjacent iff the subsets are disjoint. This is
the standard construction of the Petersen graph: 3-regular, 10 vertices, 15
edges, girth 5.

Explicit 5-cycle used as the odd closed walk in the proof:

```
{0,1} — {2,3} — {4,0} — {1,2} — {3,4} — {0,1}
```

Disjointness check of consecutive pairs (all disjoint, so all edges):

| edge                | intersection |
|---------------------|--------------|
| {0,1} , {2,3}       | ∅            |
| {2,3} , {0,4}       | ∅            |
| {0,4} , {1,2}       | ∅            |
| {1,2} , {3,4}       | ∅            |
| {3,4} , {0,1}       | ∅            |

Length = 5 (odd) ⇒ the graph is not 2-colorable ⇒ not bipartite. (The Petersen
graph's odd girth is exactly 5; there is no shorter odd closed walk, but the
non-embeddability argument only needs the existence of one.)

## 2. Why non-bipartiteness is the operative obstruction

A distance-preserving (isometric) map cannot decrease the length of the shortest
odd closed walk to zero: it sends each edge to an edge, hence maps a closed walk
of odd length to a closed walk of the same odd length. A bipartite host has no
odd closed walk. Therefore no non-bipartite graph embeds isometrically into a
bipartite one.

Small sanity checks of the general principle:

- Triangle `C_3` (odd girth 3) does not embed isometrically into any hypercube
  `Q_k`; indeed `C_3` is the smallest non-partial-cube.
- Every even cycle `C_{2m}` DOES embed isometrically into `Q_m` (it is bipartite),
  confirming the obstruction is genuinely parity-driven, not size-driven.

## 3. Bipartite abelian Cayley hosts: the character certificate

For an abelian group `A` with symmetric connection set `S` (with `0 ∉ S`), the
Cayley graph `Cay(A,S)` is bipartite **iff** there is a homomorphism
`ψ : A → ℤ/2` with `ψ(s) = 1` for all `s ∈ S`: the two color classes are
`ψ⁻¹(0)` and `ψ⁻¹(1)`.

Verified instances:

| host                              | character `ψ`                      | bipartite? |
|-----------------------------------|------------------------------------|------------|
| `Q_k = Cay((ℤ/2)^k, basis)`       | coordinate sum `x ↦ Σ x_i`         | yes        |
| even cycle `Cay(ℤ/2m, {±1})`      | `x ↦ x mod 2`                      | yes        |
| odd cycle `Cay(ℤ/(2m+1), {±1})`   | none exists                        | no         |

For every host in the "yes" column, the Petersen graph provably has no isometric
embedding (proved formally).

## 4. Counterexample hunt (bipartite side): none found

We searched for a bipartite abelian Cayley graph receiving the Petersen graph
isometrically. Because the argument reduces to "host has no odd closed walk"
vs. "Petersen has a 5-cycle", no bipartite host of any size can work — no
counterexample exists, consistent with the proved theorem.

## 5. Open computational frontier (non-bipartite hosts)

The genuinely open regime is non-bipartite abelian Cayley graphs (odd cycles and
their products). Preliminary reasoning: the Petersen graph is vertex-transitive
under the non-abelian `S_5` and is known not to be an `ℓ_1`-graph, which is the
metric fingerprint of isometric subgraphs of abelian Cayley graphs. This is the
basis for the bold conjectures in `FUTURE_DIRECTIONS.md`.
