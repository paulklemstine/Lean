# Future Directions: Topological Quantum Codes from Homology

The file `TopologicalQuantumCodes.lean` builds the homological skeleton of CSS quantum
error-correcting codes entirely inside Lean's linear algebra: a length-three chain
complex `C₂ → C₁ → C₀` over a field, with the CSS commutation condition recognized as
`d₁ ∘ d₂ = 0`, the logical qubits as `H₁ = ker d₁ / im d₂`, and the two cornerstone
theorems

* `css_logical_dimension`: `k = n − rank(d₁) − rank(d₂)`, and
* `css_euler_characteristic`: the Euler characteristic of the complex equals that of its
  homology,

together with `surface_code_logical_count` (`dim H₁ = 2g` for the minimal genus-`g`
cellulation) and the cautionary boundary case `minimal_cellulation_weight_one` (that
same minimal cellulation has a distance-`1` logical operator). These results turn the
qualitative slogan "topological codes come from homology" into proved arithmetic. The
directions below push from *counting* logical qubits to *protecting* them, which is where
the genuine open mathematics lives.

## 1. A `sysdistance` invariant and the distance lower bound

Define, over `ZMod 2`, the code distance as the minimum Hamming weight of a nontrivial
homology class, `d = min { hammingWeight v | v ∈ ker d₁ \ im d₂ }`, reusing the
`hammingWeight` already defined in the file, and prove the basic sanity facts: `d ≥ 1`
whenever `k > 0`, and `d` is invariant under change of basis of the chain groups.

The key insight is that distance is *not* a homotopy invariant — unlike `k`, which the
Euler-characteristic theorem shows is purely homological, distance depends on the chosen
cellulation, exactly as the boundary case `minimal_cellulation_weight_one` already
demonstrates by exhibiting a weight-one logical operator on the optimal-`k` complex.

Why now? The combinatorial minimum is definable directly from the already-proved
`logical_operator_exists_iff` (which guarantees the minimand is over a nonempty set when
`k > 0`), so the missing piece is a clean `IsLeast`/`Finset.min'` packaging rather than
new theory — a realistic next increment.

## 2. The systolic identity: distance = combinatorial systole of the 1-skeleton

For the cycle-graph complex `C_n` (edges → vertices incidence over `ZMod 2`) prove
`dim H₁ = 1` and `d = n`, identifying the code distance with the systole (shortest
non-contractible cycle) of the graph. Then generalize: for any cellulated surface the
distance of the `H₁` code equals the combinatorial systole of the underlying complex.

The key insight is that a nonzero class in `H₁` is exactly a `ZMod 2` cycle that is not a
boundary, i.e. a non-contractible loop, so minimizing Hamming weight literally minimizes
loop length — distance and systole are the same extremal problem viewed algebraically vs.
geometrically.

Why now? The `n`-cycle is small enough to compute its incidence matrix's rank explicitly
(`rank = n − 1`), so `css_logical_dimension` already delivers `dim H₁ = 1`; the only new
work is the weight minimization, making this the smallest fully rigorous instance of
"distance = systole".

## 3. The √g scaling law for higher-genus surface codes

Conjecture and prove the asymptotic `d = Θ(√n)` for a *fine* cellulation of the genus-`g`
surface on `n` physical qubits, and consequently `d = O(√g)` at fixed lattice density,
contrasting with the distance-`1` minimal cellulation. Concretely, formalize the
`L × L` toric lattice (`n = 2L²`, `k = 2`, `d = L`) and prove `d = √(n/2)`, then stack
`g` handles.

The key insight is that good distance is a *metric* refinement orthogonal to the
*topological* qubit count: `k = 2g` is forced by homology, but distance is bought by
subdividing cells, so the two scale independently — `k` linearly in `g`, `d` like the
square root of the qubit budget per handle.

Why now? With `surface_code_logical_count` fixing `k = 2g` for free, the entire remaining
content is the metric estimate on an explicit lattice, which is a self-contained graph
combinatorics problem (counting minimal homologically nontrivial cycles) rather than a
homological one.

## 4. Hypergraph-product codes: breaking the √n barrier

Formalize the hypergraph (tensor) product of two chain complexes and prove the Künneth-
style dimension formula `k = k_A · k_B` for the product code, recovering quantum LDPC
codes with `k = Θ(n)` logical qubits at constant rate. The base case is the product of
two repetition-code complexes, yielding the toric code as a special instance.

The key insight is that the tensor product of chain complexes multiplies homologies
(`H₁(A ⊗ B) ⊇ H₁(A) ⊗ H₀(B) ⊕ H₀(A) ⊗ H₁(B)`), so the homological code dimension is
*multiplicative*, which is precisely the algebraic engine behind constant-rate qLDPC
codes.

Why now? The Euler-characteristic and dimension theorems already isolate `dim H₁` as the
sole quantity of interest; tensoring complexes is standard Mathlib `TensorProduct`
machinery, so the product construction is reachable without leaving linear algebra, and it
connects this file directly to the 2020s breakthrough on good quantum LDPC codes.

## 5. Functoriality: chain maps as encoders and the code-morphism category

Prove that a chain map between two CSS complexes induces a linear map on homology, hence a
logical-operator-preserving map between the codes, and that this assignment is functorial
(`id ↦ id`, composition preserved). Identify code equivalences (distance-preserving
isomorphisms) with chain homotopy equivalences that additionally preserve Hamming weight.

The key insight is that the whole zoo of code transformations — concatenation, gauge
fixing, lattice surgery — are instances of *morphisms of chain complexes*, so organizing
codes into a category exposes which operations are "free" (homological) versus which cost
distance (metric), mirroring the `k` vs. `d` dichotomy of Directions 1–3.

Why now? `HomologyH1` is already a quotient functor of the data `(d₂, d₁)`; Mathlib's
`LinearMap.quotKerEquivRange` and quotient-map API make the induced map on `H₁`
constructible immediately, turning a conceptual reorganization into a concrete next proof.
