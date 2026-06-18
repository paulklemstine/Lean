# Future Directions — Integrated Information via Tensor Networks

## Synthesis

This cycle built a rigorous bridge from Tononi's Integrated Information Theory
(IIT) to quantum tensor-network states, extending the existing IIT min-cut
algebra in `Shared.CausalIntegration.Core`. The core modeling decision was to
read the IIT integrated-information quantity Φ — defined in `Core` as the
minimum *cross-information* over all nontrivial bipartitions of a weighted
graph — as the minimum *entanglement cut* of a tensor network, where each bond
carries an entanglement *capacity* `w = log D` set by its bond dimension `D`.
Under this dictionary, an MPS (matrix product state) becomes a one-dimensional
chain graph, and the conjecture "Φ equals the minimal quantum mutual
information across any bipartition" becomes the concrete, provable claim that
the min cut of a path equals one bond's capacity. We proved exactly this:
`phi_mpsChain : Φ(mpsChain n w) = w`, and specialized it to bond dimension
`D = 2` (`phi_mpsChain_bondDim_two : Φ = log 2`), matching the Schmidt rank of
a maximally entangled bond.

The decisive structural insight is that the whole result factors through
*graph connectivity*, not through any analytic property of entropy. The upper
bound is a single explicit witness cut (peel off site 0, severing one bond).
The lower bound — that every nontrivial bipartition of a chain severs at least
one bond — is precisely the statement that a path has edge-connectivity 1, and
its proof is a clean min-element argument on the complement (`min'` of the
complement is adjacent to a site in `S`). This is `mpsChain_cut_lower_bound`,
the load-bearing lemma.

What failed and taught us something: an initial directed (forward-only) bond
model is *wrong*, because the last site of the chain has no outgoing forward
bond, producing a spurious zero cut and collapsing Φ to 0. Symmetric
(undirected) nearest-neighbour bonds are required for the cut to detect
connectivity in both directions. This failure pinpoints the exact hypothesis
that higher-dimensional networks will stress: connectivity, and hence the
area law, is what makes Φ nontrivial — and what makes the 1D answer special.

## Results Summary

- `crossInfo_mpsChain_singleton_zero`: proved — peeling off the first site of a
  length-`≥2` chain severs exactly one bond, so its cut is `w` (the explicit
  upper-bound witness).
- `mpsChain_cut_lower_bound`: proved — every nontrivial bipartition of a chain
  severs at least one bond (edge-connectivity 1), so every cut is `≥ w`.
- `phi_mpsChain`: proved — **main theorem**: the integrated information Φ of a
  uniform MPS chain equals the capacity `w` of a single bond (min cut of a path).
- `phi_mpsChain_bondDim`: proved — restates Φ in terms of bond dimension:
  `Φ = log D`.
- `phi_mpsChain_bondDim_two`: proved — bond dimension `D = 2` (Schmidt rank 2)
  gives `Φ = log 2`, confirming the IIT/tensor-network conjecture's test case.

## Research Directions

### Direction 1: Area law for 2D PEPS — Φ scales with the boundary
**Hypothesis**: For a projected entangled pair state (PEPS) on an `L × L` grid
with uniform bond capacity `w`, the integrated information satisfies
`Φ = L · w` (the min cut is a straight column of `L` bonds), in contrast to the
`Φ = w` of the 1D chain.
**Test**: Define `pegsGrid L w` as a `CausalSystem (L*L)` with nearest-neighbour
grid bonds; prove the upper bound with the explicit half-grid cut and the lower
bound via a max-flow / Menger argument that any `S`-cut crosses ≥ `L` bonds.
**Why now**: The chain proof already isolates the only nontrivial ingredient —
counting severed bonds of a min cut — and shows the directed-model failure mode
to avoid. The grid simply replaces "edge-connectivity 1" with "boundary-size
`L`."
**If true**: It is the first machine-checked entanglement *area law* in this
framework, turning a physics heuristic into a theorem and explaining why higher
dimensions are qualitatively harder for IIT.
**If false**: The min cut would be sub-linear, revealing a counterexample to the
area law in the discretized capacity model and forcing a correction to the
bond-capacity dictionary.

### Direction 2: Non-uniform bonds and the weakest-link characterization
**Hypothesis**: For a chain with per-bond capacities `w₀, …, w_{n-2}`, the
integrated information equals the *minimum* bond capacity:
`Φ = min_i w_i` (the weakest bond is the bottleneck).
**Test**: Generalize `mpsChain` to take a capacity function `Fin (n-1) → ℝ≥0`;
the upper bound cuts at the argmin bond, the lower bound reuses
`mpsChain_cut_lower_bound`'s structure with the minimum capacity in place of `w`.
**Why now**: The current proof never used uniformity in the lower bound except
to name a single `w`; replacing `w` by `min_i w_i` is a localized edit.
**If true**: It formalizes the intuition that integrated information is governed
by the system's weakest causal link — a sharp, testable IIT statement.
**If false**: The min cut would mix several bonds, indicating that capacities do
not compose additively and that `log D` is the wrong currency.

### Direction 3: Tree tensor networks still have single-bond Φ
**Hypothesis**: For any *tree* tensor network with uniform bond capacity `w`
(e.g. an MERA-like binary tree without loops), `Φ = w`: removing any single
edge disconnects the tree, so the min cut is still one bond.
**Test**: Model a `SimpleGraph` that is a tree, transport it to a `CausalSystem`,
and prove the min cut is one bond using acyclicity (every edge is a bridge).
**Why now**: The chain is the simplest tree; the lower-bound argument
("some boundary edge is severed") generalizes to any connected acyclic graph,
where additionally *every* edge is a min cut.
**If true**: It cleanly separates the loop-free regime (Φ = single bond) from
the looped/2D regime (Direction 1), giving a graph-theoretic dichotomy for IIT.
**If false**: Some tree would admit a zero or multi-bond min cut, exposing a
hidden assumption (e.g. leaf weighting) in the capacity model.

### Direction 4: Φ as an entanglement monotone under coarse-graining
**Hypothesis**: Merging two adjacent sites of an MPS into one (a deterministic
coarse-graining / blocking map) does not increase Φ:
`Φ(blocked chain) ≤ Φ(original chain)`.
**Test**: Define a site-blocking operation on `CausalSystem` and prove
monotonicity, ideally connecting to the deterministic data-processing
inequality `tropMutualInfo_data_processing_det` in `Shared.MutualInformation`.
**Why now**: `Core` already provides `phi_mono_of_weight_le` and `phi_scale`;
combining them with the data-processing monotone in `MutualInformation` is a
natural cross-domain synthesis that this cycle's dictionary makes meaningful.
**If true**: It promotes Φ from a static number to a genuine *monotone* under
renormalization, the property IIT most needs for multi-scale consciousness
claims.
**If false**: Coarse-graining could create integrated information from
unintegrated parts — a striking anti-IIT phenomenon worth isolating explicitly.

### Direction 5: Exact Φ–Schmidt-rank identity for the canonical MPS state
**Hypothesis**: For the concrete bond-dimension-`D` translationally invariant
MPS *state* (not just its graph), the von Neumann entanglement entropy across
any contiguous bipartition equals `Φ = log D`, with equality exactly when the
bond is maximally entangled (Schmidt rank `= D`).
**Test**: Build the bond density matrix as a `D × D` Hermitian PSD trace-1
matrix, define its von Neumann entropy, and prove it is `≤ log D` with equality
at the maximally mixed bond — linking to `Shared.HopfEntanglement`'s
two-qubit concurrence machinery for the `D = 2` case.
**Why now**: This cycle proved the *capacity-graph* side (`Φ = log D`); closing
the loop to the *quantum-state* side (entropy `= log D`) is what makes the
original IIT conjecture literally true rather than true-by-definition.
**If true**: It would be a fully formalized instance of "Φ = minimal quantum
mutual information across any bipartition," the headline conjecture, for a real
family of quantum states.
**If false**: The capacity `log D` would only upper-bound the true entropy,
revealing that bond dimension overcounts integrated information and that
Schmidt *rank* must be replaced by Schmidt *entropy*.
