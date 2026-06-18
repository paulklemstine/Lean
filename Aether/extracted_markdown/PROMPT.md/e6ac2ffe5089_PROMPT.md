You are formalizing the Vietoris–Rips completion threshold theorem in Lean 4. A previous attempt identified the correct theorem statements but the proofs were incomplete (only signatures, no proof bodies). Your task is to produce a complete, self-contained Lean 4 file with FULL PROOFS and ZERO `sorry`s.

## Mathematical Background

For a finite type α with decidable equality and a metric `dist : α → α → ℝ`, the Vietoris–Rips complex `vietorisRips dist ε` is the clique complex of the Rips graph `ripsGraph dist ε`, where two distinct vertices are adjacent iff their distance is ≤ ε. The *full simplex* (or *full complex*) on α is the simplicial complex whose faces are all finite subsets of α. The *tropical birth sum* `tropBirthSum α dist` is the maximum pairwise distance between distinct points.

## Required Definitions and Theorems

1. **`fullComplex (α : Type*) [Fintype α] [DecidableEq α] : SimplicialComplex α`** — the simplicial complex whose faces are all finite subsets.

2. **`cliqueComplex_eq_full_iff`**: For a graph G on α, `cliqueComplex G = fullComplex ↔ G = ⊤`. This requires proving that every finite subset is a clique iff the graph is complete.

3. **`tropBirthSum`**: Define as the supremum of all pairwise distances. For `Fintype α` with `[Nonempty α]`, this is a well-defined real number.

4. **`ripsGraph_eq_top_iff`**: The Rips graph at scale ε is the complete graph iff every pair of distinct points has distance ≤ ε.

5. **`tropBirthSum_le_iff`**: `tropBirthSum α dist ≤ ε ↔ ∀ x y, x ≠ y → dist x y ≤ ε`. This is the key computational lemma connecting the tropical birth sum to pairwise distances.

6. **`vietorisRips_eq_full_iff_tropBirthSum`**: The headline theorem: `vietorisRips dist ε = fullComplex ↔ tropBirthSum α dist ≤ ε`.

## Implementation Requirements

- Use `Mathlib.Combinatorics.SimpleGraph.Clique` and `Mathlib.Topology.Simplicial` if available, or build a minimal `SimplicialComplex` structure.
- If `SimplicialComplex` is not in Mathlib, define it minimally as a structure with a set of finsets satisfying the downward-closure and empty-set conditions.
- The `cliqueComplex` of a graph G maps each clique of G to a face.
- All proofs must be complete tactic proofs. No `sorry` anywhere.
- Use `exact?`, `omega`, `linarith`, `simp`, and `aesop` liberally.
- For the `tropBirthSum`, use `Finset.sup'` on the finset of all pairwise distances.
- The file should compile without errors in a standard Lean 4 + Mathlib environment.

## Proof Strategy

The proof is a three-step bridge:
(1) Show `cliqueComplex G = fullComplex ↔ G = ⊤` by showing that every finite set is a clique iff the graph is complete.
(2) Show `ripsGraph dist ε = ⊤ ↔ ∀ x y, x ≠ y → dist x y ≤ ε` by unfolding the definition of the Rips graph.
(3) Show `tropBirthSum α dist ≤ ε ↔ ∀ x y, x ≠ y → dist x y ≤ ε` by the definition of sup'.
(4) Chain these: `vietorisRips dist ε = fullComplex ↔ ripsGraph dist ε = ⊤ ↔ tropBirthSum α dist ≤ ε`.