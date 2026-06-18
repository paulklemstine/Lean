# Future Directions — ER = EPR and Emergent Spacetime from Entanglement

The file `Catalog/Physics/EREPREmergentSpacetime.lean` proves the algebraic core
of the ER = EPR correspondence for two-qubit pure states: the emergent
Einstein–Rosen bridge (measured by the concurrence `C = 2‖ad − bc‖`) is open
*iff* the qubits are entangled (`erEpr_correspondence`), the geometry is bounded
(`concurrence_le_one`), it is invariant under local unitaries
(`concurrenceM_local_unitary_invariant`), and it collapses under a rank-deficient
local measurement (`concurrenceM_collapse`). These results turn the SLOCC
invariant of `HopfEntanglement` into a genuine *emergent geometric* order
parameter. Below are five concrete, falsifiable directions that extend it.

## 1. The n-qubit rank criterion for an open bridge

The two-qubit theorem `erEpr_correspondence` should generalize to: for a pure
state on a bipartition `A ⊔ B`, the emergent bridge is open iff the reduced
density operator `ρ_A` has rank `> 1`. The Lean stub
`erEpr_correspondence_general` records exactly this as
`1 < ρA.rank ↔ ∃ i j, i ≠ j ∧ eigenvalues i ≠ 0 ∧ eigenvalues j ≠ 0`.
**The key insight is** that for a Hermitian (hence unitarily diagonalizable)
reduced density matrix the rank equals the number of nonzero Schmidt
coefficients, so "geometric connectivity = rank ≥ 2" is a purely spectral
statement provable from `Matrix.IsHermitian.spectral_theorem` plus
`Matrix.rank_eq_card_nonzero_eigenvalues`-style counting. **Why now?** Mathlib
4.28 already carries the spectral theorem and eigenvalue API for Hermitian
matrices, so the only missing lemma is rank = #(nonzero eigenvalues); this is a
self-contained, high-value piece of linear algebra worth contributing upstream.

## 2. Concurrence as a metric: the triangle inequality on bridge length

Define a bridge *length* `ℓ = −log C ∈ [0, ∞]` (so `ℓ = 0` for a Bell pair and
`ℓ = ∞` for a product state) and ask whether `ℓ` behaves like a distance under
a natural composition of states (e.g. entanglement swapping). The conjecture is
that swapping satisfies `ℓ(A,C) ≤ ℓ(A,B) + ℓ(B,C)`, a triangle inequality making
entanglement an honest *metric* and matching the geodesic interpretation of ER
bridges. **The key insight is** that entanglement swapping multiplies
concurrences submultiplicatively, `C(A,C) ≥ C(A,B)·C(B,C)`, which on taking
`−log` becomes exactly the triangle inequality. **Why now?** The multiplicative
covariance `concurrenceM_local_covariant` is already proven, and submultiplica-
tivity of `2‖det(MN)‖` under matrix products is one `Matrix.det_mul` + `norm_mul`
away — the metric structure is within immediate reach.

## 3. Monogamy of bridges (Coffman–Kundu–Wootters in Lean)

For three qubits the squared concurrences obey the monogamy bound
`C²(A|B) + C²(A|C) ≤ C²(A|BC)`: a qubit cannot build maximal bridges to two
partners at once. **The key insight is** that monogamy is the geometric
statement that one boundary region can support only a bounded total wormhole
throat area, so it should follow from a Cauchy–Schwarz/AM–GM bound on the
3-tangle hyperdeterminant rather than from any deep holography. **Why now?**
The two-qubit determinant invariant is formalized and `concurrence_le_one`
already shows the AM–GM toolkit works for these norms; the 3-qubit hyperdetermi-
nant (Cayley's) is an explicit cubic form that `ring`/`nlinarith` can attack
directly, making a fully verified monogamy inequality realistic.

## 4. Ryu–Takayanagi positivity: entropy = minimal cut on tensor networks

Bridge the present file with `Catalog/Tropical/EntanglementWedge.lean` and
`Catalog/Computation/IIT/TensorNetworkMultiCut.lean`: for a bipartite tensor
network state, the entanglement entropy of a boundary region equals the minimum
cut separating it from its complement (the discrete Ryu–Takayanagi formula), and
this min-cut "area" is subadditive. **The key insight is** that min-cut/max-flow
duality on a finite weighted graph is the combinatorial shadow of RT, so RT
subadditivity reduces to the submodularity of the graph cut function — a finite,
fully formalizable statement. **Why now?** The tropical (min-plus) machinery for
cuts already exists in the catalog's `EntanglementWedge` and tensor-network
files, so the entropy↔geometry dictionary can be assembled from parts that are
already present rather than built from scratch.

## 5. Bridge stability: entanglement is robust to small local perturbations

The map `state ↦ C` is Lipschitz, so a wormhole that is open by margin `ε`
stays open under any perturbation of the amplitudes smaller than `ε/2`; quantify
this and connect it to `wedge_membership_stable_under_uniform_perturbation` from
`Catalog/Tropical/EntanglementWedge.lean`. **The key insight is** that
`C = 2‖ad − bc‖` is a composition of multiplication and the (1-Lipschitz) complex
norm, so its modulus of continuity is explicit and an open bridge has a concrete
"protected" radius in state space. **Why now?** Continuity of `‖·‖` and bilinear
maps is fully developed in Mathlib, so a quantitative robustness theorem
(`|C(ψ) − C(ψ')| ≤ K‖ψ − ψ'‖`) is provable immediately and gives the first
verified statement that emergent geometry is *stable*, not fine-tuned.
