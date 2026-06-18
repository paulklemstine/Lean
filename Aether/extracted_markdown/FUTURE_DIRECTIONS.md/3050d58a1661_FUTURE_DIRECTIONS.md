# Future Directions: Emergent Spacetime from Quantum Entanglement (ER = EPR)

## Synthesis

This cycle delivered `Catalog/Physics/EmergentSpacetimeEREPR.lean`, a self-contained,
fully verified (`sorry`-free, only `propext`/`Classical.choice`/`Quot.sound`) toy model
of the Maldacena–Susskind **ER = EPR** conjecture. A two-qubit pure state is its `2 × 2`
complex amplitude matrix `M`; its **concurrence** `C(M) = 2‖det M‖` is promoted to an
*emergent geometric quantity*, the **Einstein–Rosen bridge length** `bridgeLength M = -log C(M)`.

The single scalar invariant `det M` turns out to govern the entire dictionary, and the
file proves the four entries that a genuine geometry/entanglement correspondence must have:

1. **Connectivity dictionary** (`isProduct_iff_concurrence_zero`): a bridge exists
   (`C > 0`) **iff** the pair is genuinely entangled; product states are geometrically
   disconnected. The hard direction is an explicit, constructive rank-1 factorization of a
   determinant-zero `2 × 2` matrix over `ℂ`.
2. **Background independence** (`concurrence_localUnitary_invariant`): under local
   `SL(2,ℂ)` operations (`det U = det V = 1`) the geometry is unchanged — it depends only
   on entanglement, not on the boundary CFT basis. Reduces to `det_mul` + `det_transpose`.
3. **No negative-length bridges** (`concurrence_le_one_of_normalized`,
   `bridgeLength_nonneg_of_normalized`): normalization forces `C ≤ 1`, hence
   `bridgeLength ≥ 0`, via an AM–GM bound on the four amplitude norms.
4. **Monotonicity + Bell throat** (`bridgeLength_antitone`,
   `bridgeLength_eq_zero_iff_maximally_entangled`): more entanglement = strictly shorter
   wormhole, with a zero-length throat exactly for maximally entangled (Bell) states.

This is a deliberate cross-domain fusion of three previously isolated catalog threads:
the Hopf-fibration `concurrence` (`Catalog/Shared/HopfEntanglement/Theorems.lean`), the
tropical entanglement-wedge reconstruction (`Catalog/Tropical/EntanglementWedge.lean`),
and tropical mutual information (`Catalog/Tropical/MutualInformation.lean`). The novelty is
the upgrade of an entanglement *number* to a *metric* object with proved geometric axioms.

## Results Summary

| Theorem | Dictionary entry | Status |
|---|---|---|
| `isProduct_iff_concurrence_zero` | bridge ⇔ entanglement | proved |
| `concurrence_pos_iff_not_product` | positive-length bridge ⇔ entangled | proved |
| `concurrence_localUnitary_invariant` | basis/background independence | proved |
| `bridgeLength_localUnitary_invariant` | length is an invariant | proved |
| `concurrence_le_one_of_normalized` | `C ≤ 1` | proved |
| `bridgeLength_nonneg_of_normalized` | no negative lengths | proved |
| `bridgeLength_antitone` | more entanglement = shorter bridge | proved |
| `bridgeLength_eq_zero_iff_maximally_entangled` | Bell = zero throat | proved |

## Bold, Falsifiable Research Directions

### 1. A triangle inequality for the emergent metric (entanglement monogamy ⇒ geometry)

Extend from a single pair to three qubits `A, B, C` and define pairwise bridge lengths
`L_AB, L_AC, L_BC` from the reduced two-qubit concurrences. **Conjecture:** these satisfy a
(possibly reversed/ultrametric) triangle inequality whose failure is exactly quantified by
the Coffman–Kundu–Wootters 3-tangle, i.e. genuine tripartite entanglement is the
"curvature" obstructing a flat metric. *The key insight is* that monogamy of entanglement
(`C²_AB + C²_AC ≤ C²_A`) is dimensionally a metric constraint once `C` is read as
`exp(-length)`, so the CKW inequality should translate verbatim into a comparison of
bridge lengths. *Why now?* Concurrence, monogamy-style bounds, and the `bridgeLength`
functor are all now formalized in this catalog, so the only missing piece is the 3-tangle
definition — a single `det`-style polynomial — making this immediately attackable in Lean.

### 2. Subadditivity of bridge length under tensoring = additivity of wormholes

For two independent two-qubit systems `M, N`, study `bridgeLength (M ⊗ N)` versus
`bridgeLength M + bridgeLength N`. **Conjecture:** because `det (M ⊗ N) = (det M)^2 (det N)^2`
for the Kronecker product on `Fin 2 × Fin 2`, the bridge length is *exactly additive up to
a universal factor*, mirroring the extensivity of horizon area / wormhole throat under
disjoint union. *The key insight is* that the multiplicativity of the determinant under
`Matrix.kroneckerMap` turns a `-log` length into an additive invariant, exactly the
behaviour a holographic "area = entropy" law predicts. *Why now?* Mathlib already has
`Matrix.kroneckerMap` and its determinant lemmas, and `concurrence`/`bridgeLength` are in
place, so this is a short, high-yield formalization that directly tests the extensivity
axiom of emergent geometry.

### 3. Ryu–Takayanagi as a tropical min-cut on the entanglement-wedge graph

Bridge this file with `Catalog/Tropical/EntanglementWedge.lean`: model a boundary region's
entropy as a **tropical (min-plus) min-cut** in the wedge distance graph, and prove that
the cut value equals `bridgeLength` of an effective two-qubit reduction. **Conjecture:** the
entanglement-wedge `distToFinset` min-cut is a faithful discretization of the RT formula,
i.e. `min-cut = -log(effective concurrence)` along the wedge boundary. *The key insight is*
that tropical min-plus convolution is precisely the semiring in which geodesic/min-cut
lengths add, so the existing `distToFinset` and `boundaryObs` machinery is already the right
RT calculator — only the identification with `bridgeLength` is missing. *Why now?* Both the
wedge combinatorics and the metric functor exist in this catalog; connecting them yields the
first end-to-end formal RT statement assembled entirely from already-proved components.

### 4. Spectral reconstruction: recovering the metric from a single correlation matrix

**Conjecture:** the entire `bridgeLength` geometry of an `n`-qubit pure state is
reconstructible from the spectrum of its two-point correlation (Gram) matrix, and the map
"correlation spectrum ↦ pairwise bridge lengths" is injective on a generic open set. *The
key insight is* that for two qubits `C(M)` is `2|det M|`, a degree-2 invariant of `M`, so the
full pairwise geometry is a polynomial function of correlators — meaning the metric is an
*algebraic shadow* of the state and reconstruction is a Positivstellensatz problem, not an
analytic one. *Why now?* Mathlib's linear-algebra and determinant API make degree-2
invariants tractable, and the catalog's reconstruction results
(`wedge_reconstruction_from_boundary_profiles`) provide a template for the injectivity proof.

### 5. A discrete Einstein equation: curvature defect = entanglement defect

Define a discrete Regge-style curvature on the triangle-network of bridge lengths from
Direction 1, and a "stress" from deviations of local concurrences from their maximal values.
**Conjecture:** the curvature defect at each vertex is proportional to the local entanglement
defect — a finite, falsifiable analogue of the linearized Einstein equation
`δG = δ⟨T⟩` (Faulkner–Guica–Hartman–Myers–Van Raamsdonk). *The key insight is* that once
`bridgeLength` obeys a triangle inequality (Direction 1), angle defects become well-defined
combinatorial quantities, and the maximal-entanglement (`C = 1`, zero-length) configuration
is exactly the flat reference geometry, so curvature must measure departure from maximal
entanglement. *Why now?* This is the natural capstone: it requires Directions 1–2 as lemmas
and would be the first machine-checked statement that "entanglement sources curvature" in any
model, however toy — a genuine grand-challenge target with a concrete, incremental proof path.
