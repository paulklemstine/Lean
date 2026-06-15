# Future Directions: Topological Quantum Error Correction from Mathematical Structures

This cycle established the **homological core of CSS quantum codes** in
`Catalog/Speculative/TopologicalQEC.lean`: a length-three chain complex
`C₂ —∂Z→ C₁ —∂X→ C₀` over a field `𝕜`, the equivalence between the CSS
stabilizer-commutation condition and `∂X ∘ ∂Z = 0`, and the master logical-qubit
count `k = dim H₁ = n − r_X − r_Z`, with the CSS rate bound `k ≥ n − m_X − m_Z`.

The following conjectures are precise, falsifiable, and build directly on these results.

## Conjecture 1 (CSS–homology duality / Poincaré symmetry)
For the transposed (dual) complex obtained by swapping the roles of `∂X` and `∂Z`
(i.e. replacing the maps by their `LinearMap.dualMap`s in reversed order), the number
of logical qubits is invariant:
`logicalQubits ∂Z ∂X = logicalQubits (∂X.dualMap) (∂Z.dualMap)`.
This formalizes `dim H₁ = dim H¹` for finite-dimensional complexes and would show the
X/Z labelling of a CSS code is a gauge choice that never changes the encoded dimension.

## Conjecture 2 (Künneth / hypergraph-product code dimension)
Given two complexes with logical-qubit counts `k₁` and `k₂`, the **hypergraph product**
(tensor) complex encodes exactly `k₁ · k₂ + (transverse cycle/boundary terms)` logical
qubits. Concretely, prove a Künneth-type formula
`logicalQubits (C ⊗ D) = Σ dim Hᵢ(C) · dim H_{1−i}(D)`
for the two-term tensor complex. This is the algebraic engine behind quantum LDPC codes
and should follow from `Module.finrank_tensorProduct` plus the dimension count proved here.

## Conjecture 3 (Distance lower bound from injectivity radius)
Define the code distance `d` as the minimum Hamming weight (number of nonzero
`ZMod 2` coordinates) over nontrivial homology representatives. Conjecture: if every
nonzero element of `ker ∂X` has weight `≥ w` or lies in `im ∂Z`, then `d ≥ w`, and the
parameters satisfy a Singleton-type inequality `k + 2d ≤ n + 2`. The first half is a
clean order-theoretic statement; the second tests whether topological codes can be
"good" (constant rate and relative distance).

## Conjecture 4 (Euler characteristic obstruction)
For the three-term complex, `χ := dim C₀ − dim C₁ + dim C₂` satisfies
`k = logicalQubits ∂Z ∂X = (dim C₁ − r_X − r_Z)` and hence
`k = −χ + (dim C₀ − r_X) + (dim C₂ − r_Z) = −χ + dim(coker ∂X) + dim(ker ∂Z)`.
Conjecture: when the complex is "balanced" (`∂X` surjective and `∂Z` injective), `k = −χ`
exactly, giving a purely combinatorial/topological count of logical qubits directly from
the Euler characteristic of the underlying cell structure (e.g. `k = 2g` for a genus-`g`
surface code).

## Conjecture 5 (Stability under local deformation)
Adding a single "free" physical qubit decoupled from all stabilizers increases `k` by
exactly 1 (`logicalQubits` of `∂Z ⊕ 0`, `∂X ⊕ 0` equals `logicalQubits ∂Z ∂X + 1`),
while a "gauge" qubit appearing in exactly one X- and one Z-check leaves `k` unchanged.
Proving these two local moves generate all dimension-preserving deformations would give a
calculus of code surgery entirely inside finite-dimensional linear algebra.
