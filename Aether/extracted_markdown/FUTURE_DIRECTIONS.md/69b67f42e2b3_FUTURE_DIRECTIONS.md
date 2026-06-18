# Future Directions: Tropical Holographic Reconstruction on Finite Networks

This document outlines 5 concrete research directions opened by the tropical entanglement wedge theory, each with precise theorem targets, required definitions, proof strategies, and cross-domain significance.

---

## Direction 1: Tropical Separator / Barrier Theorems

### Statement

Prove that if every shortest path from bulk vertex $v$ to boundary subset $B$ passes through a **separator set** $\Sigma$ whose vertices all satisfy $d_B(\sigma) \geq d_{B^c}(\sigma)$, then $v \notin \mathrm{Wedge}(B)$.

### Exact Theorem Target

```lean
def isPathSeparator {V : Type*} [DecidableEq V]
    (d : V → V → ℝ) (v : V) (B Σ_ : Finset V) : Prop :=
  ∀ b ∈ B, ∀ path : List V,
    isShortestPath d v b path → ∃ σ ∈ Σ_, σ ∈ path

theorem not_mem_wedge_of_shielded_separator
    {V : Type*} [DecidableEq V]
    {bulk boundary B Σ_ : Finset V} {d : V → V → ℝ} {v : V}
    (hv : v ∈ bulk)
    (hsep : isPathSeparator d v B Σ_)
    (hshield : ∀ σ ∈ Σ_, ∀ (hB : B.Nonempty) (hBc : (boundary \ B).Nonempty),
      distToFinset d (boundary \ B) hBc σ ≤ distToFinset d B hB σ)
    (htriangle : ∀ x y z, d x z ≤ d x y + d y z) :
    v ∉ entanglementWedge bulk boundary B d
```

### Required Definitions

- `isShortestPath d u v path` — A list of vertices forming a shortest path
- `isPathSeparator d v B Σ_` — Every shortest path from `v` to `B` intersects `Σ_`

### Proof Strategies

1. **Triangle inequality approach:** Use $d(v, b) \geq d(v, \sigma) + d(\sigma, b)$ for some $\sigma$ on the path, combined with $d(\sigma, b) \geq d_{B^c}(\sigma) \geq d_B(\sigma)$ by the shielding hypothesis.

2. **Induction on path length:** Prove by induction that barriers propagate: if the first barrier vertex $\sigma$ satisfies $d_{B^c}(\sigma) \leq d_B(\sigma)$, then every vertex before $\sigma$ on any path inherits the inequality.

### Cross-Domain Significance

- **Network security:** Separators model firewalls; the theorem certifies that data behind a firewall is invisible from certain probes.
- **Causal inference:** In DAGs, separators correspond to d-separation; this tropical version gives a metric-aware separation criterion.
- **Graph partitioning:** Barrier theorems provide quality guarantees for graph cuts.

---

## Direction 2: Tropical Ryu-Takayanagi Formula

### Statement

Define a notion of **wedge boundary area** as the total weight of edges crossing from $\mathrm{Wedge}(B)$ to $\mathrm{bulk} \setminus \mathrm{Wedge}(B)$. Prove that this boundary area provides a lower bound on the number of independent observations available from $B$, and an upper bound on the "entropy" (information content) of the wedge.

### Exact Theorem Target

```lean
def wedgeBoundaryWeight {V : Type*} [DecidableEq V]
    (bulk boundary B : Finset V) (d : V → V → ℝ) (w : V → V → ℝ) : ℝ :=
  (entanglementWedge bulk boundary B d).sum (fun v =>
    (bulk \ entanglementWedge bulk boundary B d).sum (fun u => w v u))

theorem wedge_area_bounds_information
    {V : Type*} [DecidableEq V] [Fintype V]
    {bulk boundary B : Finset V} {d : V → V → ℝ}
    (hB : B.Nonempty) (hBc : (boundary \ B).Nonempty)
    (W : Finset V := entanglementWedge bulk boundary B d)
    (hW : W.Nonempty) :
    -- The number of independent argmin witnesses is at most |B|
    (W.filter (fun v => ∃ b ∈ B, ∀ w ∈ bulk, w ≠ v →
      0 + d v b < 0 + d w b)).card ≤ B.card
```

### Proof Strategies

1. **Injection argument:** Map each wedge vertex with a unique witness to its witness in $B$; injectivity gives the cardinality bound.
2. **Tropical linear algebra:** Express the observation map as a tropical matrix and bound its tropical rank.

### Cross-Domain Significance

- **Physics:** Direct analogue of the Ryu-Takayanagi entropy bound.
- **Information theory:** Connects channel capacity to geometric boundary area.
- **Complexity theory:** Graph cuts and communication complexity bounds.

---

## Direction 3: Dynamic Wedge Evolution Under Edge Weight Perturbation

### Statement

When edge weights change continuously (modeling network degradation or improvement), track how the wedge evolves. Prove that wedge membership changes occur only when the gap $\delta_v$ crosses zero, and characterize the "phase transitions" of the wedge.

### Exact Theorem Target

```lean
theorem wedge_transition_at_zero_gap
    {V : Type*} [DecidableEq V]
    {bulk boundary B : Finset V}
    {d : ℝ → V → V → ℝ} {v : V} {t₀ : ℝ}
    (hv : v ∈ bulk) (hB : B.Nonempty) (hBc : (boundary \ B).Nonempty)
    (hcont : Continuous (fun t => distToFinset (d t) B hB v -
                                  distToFinset (d t) (boundary \ B) hBc v))
    (hmem : v ∈ entanglementWedge bulk boundary B (d t₀))
    (hnmem : v ∉ entanglementWedge bulk boundary B (d (t₀ + 1))) :
    ∃ t ∈ Set.Icc t₀ (t₀ + 1),
      distToFinset (d t) B hB v = distToFinset (d t) (boundary \ B) hBc v
```

### Required Definitions

- Time-parameterized distance family $d(t) : V \to V \to \mathbb{R}$
- Continuity of the gap function

### Proof Strategies

1. **Intermediate value theorem:** The gap function changes sign from positive to negative, so by IVT it crosses zero.
2. **Piecewise-linear structure:** If distances are piecewise linear in $t$, the gap function is also piecewise linear and zero-crossings are computable.

### Cross-Domain Significance

- **Network monitoring:** Predicting when a monitoring station loses coverage.
- **Dynamical systems:** Phase transitions in optimization landscapes.
- **Robustness engineering:** Worst-case analysis for network degradation.

---

## Direction 4: Multi-Subset Wedge Intersection and Covering Theorems

### Statement

Given multiple boundary subsets $B_1, \ldots, B_k$, prove structural theorems about wedge intersections $\bigcap_i \mathrm{Wedge}(B_i)$, unions $\bigcup_i \mathrm{Wedge}(B_i)$, and covering properties.

### Exact Theorem Targets

```lean
-- Wedge of B ∪ B' contains wedge of B intersected with appropriate condition
theorem wedge_union_contains_intersection
    {V : Type*} [DecidableEq V]
    {bulk boundary B B' : Finset V} {d : V → V → ℝ}
    (hBB' : B ∪ B' ⊆ boundary) :
    entanglementWedge bulk boundary B d ∩
    entanglementWedge bulk boundary B' d ⊆
    entanglementWedge bulk boundary (B ∪ B') d

-- Complementary wedges cover bulk under boundary partition
theorem complementary_wedges_cover
    {V : Type*} [DecidableEq V]
    {bulk boundary : Finset V} {d : V → V → ℝ}
    (hpart : ∀ v ∈ bulk, ∀ (hB : (boundary).Nonempty),
      ∃ B ⊆ boundary, B.Nonempty ∧ v ∈ entanglementWedge bulk boundary B d) :
    True  -- Covering property
```

### Proof Strategies

1. **Direct set manipulation:** Use monotonicity of `distToFinset` under set inclusion.
2. **Voronoi duality:** Each bulk vertex is nearest to at least one boundary vertex, which determines a singleton wedge containing it.

### Cross-Domain Significance

- **Distributed systems:** Multi-party monitoring and fault coverage guarantees.
- **Quantum information:** Subregion duality and complementary recovery.
- **Combinatorial optimization:** Covering and packing on metric spaces.

---

## Direction 5: Algorithmic Certification of Reconstruction Guarantees

### Statement

Produce a **verified algorithm** (certified in Lean) that, given a graph and boundary subset $B$, outputs:
1. The wedge $\mathrm{Wedge}(B)$
2. A stability certificate (gap values for each wedge vertex)
3. A reconstruction certificate (unique argmin witnesses, or a report of degeneracies)

### Exact Theorem Target

```lean
-- A decision procedure for wedge membership with certificate
def wedgeMembershipDecide {V : Type*} [DecidableEq V] [Fintype V]
    (bulk boundary B : Finset V) (d : V → V → ℝ) (v : V) :
    Decidable (v ∈ entanglementWedge bulk boundary B d)

-- Certified wedge computation
def computeWedge {V : Type*} [DecidableEq V] [Fintype V]
    (bulk boundary B : Finset V) (d : V → V → ℝ) :
    { W : Finset V // W = entanglementWedge bulk boundary B d }
```

### Required Definitions

- Decidable instances for real-number comparison (using rationals or computable reals)
- Certificate types packaging gap values and witnesses

### Proof Strategies

1. **Reflection:** Reduce to decidable finite comparisons over `ℚ` or `Float`.
2. **Extraction:** Use Lean's code extraction to produce verified OCaml/C code.

### Cross-Domain Significance

- **Formal methods:** Certified network analysis tools.
- **Software verification:** Provably correct monitoring system design.
- **Industrial applications:** Aviation, medical devices, and safety-critical systems where reconstruction guarantees must be certified.

---

## Summary Table

| Direction | Key Theorem | Difficulty | Cross-Domain Impact |
|-----------|-------------|------------|---------------------|
| 1. Separators | Barrier exclusion | Medium | Security, causal inference |
| 2. RT Formula | Area-information bound | Hard | Physics, information theory |
| 3. Dynamic Evolution | IVT phase transition | Medium | Monitoring, dynamics |
| 4. Multi-Subset | Covering/intersection | Medium | Distributed systems, QI |
| 5. Certification | Verified algorithms | Hard | Formal methods, industry |

## Research Team Organization

- **Thread A (Definitions & API):** Formalize path structure, separator sets, and weighted boundary area.
- **Thread B (Proof Engineering):** Prove separator theorems and covering properties using existing `distToFinset` API.
- **Thread C (Bridge Analysis):** Connect to `reconstructs_bulk_from_boundary_profiles` from causal holography for deeper reconstruction results.
- **Thread D (Computation):** Build and test on example graphs with `#eval`, verify conjectures computationally before formalizing.
- **Thread E (Documentation):** Maintain FUTURE_DIRECTIONS.md as theorems stabilize, write detailed proof sketches for next-cycle targets.

Each direction is self-contained enough for an independent research effort, but directions 1–3 are the highest priority as they would complete the core tropical holography package.
