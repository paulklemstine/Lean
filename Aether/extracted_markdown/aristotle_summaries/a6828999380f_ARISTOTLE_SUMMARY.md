# Summary of changes for run dcef6eb1-38ea-4b8a-8505-b91cf8791ed9
Researched the direction **"Integrated Information via Tensor Networks"** and delivered two new, fully verified Lean 4 files under `Catalog/Physics/`, plus a future-directions document. All main theorems are proved with no sorries and depend only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

**Key idea / bridge.** The catalog already formalizes IIT's integrated information Φ as a min-cut functional on weighted causal graphs (`Shared/CausalIntegration`). I established the dictionary `weight = log(bond dimension)`, under which **IIT's min-cut Φ and a tensor network's min-cut entanglement capacity are the same functional**, and then proved new structural laws.

**`Physics/TensorNetworkIntegratedInfo.lean` (cycle 1).**
- `TensorNetwork` (bond dimensions ≥ 1), `cutRank` (Schmidt-rank bound = product of cut bonds), `logCut` (additive cut), and `toCausal` linking to `CausalSystem`.
- `logCut_eq_log_cutRank`, `toCausal_crossInfo` — the log/product and IIT correspondences.
- `entanglementCapacity` (= Φ) with `entanglementCapacity_le_logCut` / `entanglementCapacity_le_log_cutRank` — the **min-cut area-law bound**; `entanglementCapacity_mono` — refinement monotonicity.
- `entanglementCapacity_eq_zero_iff` — Φ = 0 iff the network is a **product state** across some bipartition.
- Headline: `crossInfo_submodular` — the directed cut functional (hence `logCut`) is **submodular**, the engine behind strong-subadditivity-type entanglement inequalities.
- `directSum` / `entanglementCapacity_directSum_eq_zero` — disjoint networks form a product state (IIT exclusion postulate).

**`Physics/IntegratedInfoSuperadditive.lean` (cycles 2–3).**
- `addSystem`, `crossInfo_add` — weight superposition makes the cut functional add.
- `phi_superadditive` — **Φ is superadditive under superposition**: Φ(C₁⊕C₂) ≥ Φ(C₁)+Φ(C₂); `phi_add_self` (doubling), and the tensor-network form `entanglementCapacity_tensorProduct_superadditive` (bond-dimension multiplication).
- `phi_add_eq_of_common_minimizer` — additivity holds exactly when the two systems share a minimizing bipartition (sufficiency direction of a stated conjecture).

**Lab notes** are embedded as `-- !-- Lab Notes -- !--` blocks (hypotheses H1–H5, confirmed/rejected outcomes, and failure analysis, including the rejection of naive additivity as an equality).

**`Physics/FUTURE_DIRECTIONS.md`** states five bold, falsifiable conjectures for follow-up cycles: holographic strong subadditivity (min lifts submodularity), max-flow/min-cut tightness of the area law, coarse-graining (RG) monotonicity of Φ, a spectral/Cheeger lower bound, and the exact superadditivity-gap characterization.

The new files reuse the existing `Shared.CausalIntegration` API rather than redefining it. (Build note: the Lean sources live under `Catalog/` while the package store is at the project root; I added the small symlinks needed for the toolchain to resolve the `Physics`/`Shared` libraries consistently.)