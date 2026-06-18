# Future Directions: Higher-Dimensional Tropical Morse Theory

## Synthesis

The tropical Morse theory for simplicial filtrations established here provides a new language — tropical event data — that is provably equivalent to classical persistent homology but opens connections to tropical geometry, combinatorial Hodge theory, statistical mechanics, and algorithm design. The key bridge is the simplex insertion dichotomy (proved in `Catalog/Pythagorean/TropicalMorse/SimplicialMorse.lean`), which decomposes persistent homology into atomic birth/death events. Each future direction below extends this bridge to a new domain or sharpens it into a new tool.

---

## Direction 1: Torsion-Aware Tropical Morse Theory

**Conjecture**: Over ℤ coefficients, the simplex insertion dichotomy generalizes to a *trichotomy*: each d-simplex insertion either (a) births a free d-cycle, (b) kills a free (d−1)-cycle, or (c) changes the torsion subgroup of H_{d−1} — specifically, either creating a new torsion element or annihilating one. The tropical event type should encode the Smith normal form diagonal entry, giving a "tropical torsion spectrum."

**The key insight is** that over ℤ, the boundary of an inserted simplex can be a non-trivial multiple of an existing cycle rather than zero or linearly independent, leading to torsion phenomena invisible over fields.

**Why now?** The field-coefficient dichotomy is formally verified. The ℤ case is the natural next step, and the Smith normal form machinery exists in Mathlib. The Linial-Meshulam model over ℤ is known to exhibit torsion phase transitions.

**Test**: Compute H_1(K; ℤ) for random 2-complexes on ℤ₃-projective-plane-like structures. Track torsion changes at each triangle insertion. Classify into the three event types.

**Impact**: Opens tropical Morse theory to torsion-sensitive applications (manifold recognition, crystallographic defects, quantum error correction codes where torsion encodes logical qubits).

**Catalog References**: `Catalog/Pythagorean/TropicalMorse/SimplicialMorse.lean` — simplex_insertion_dichotomy (the field case to generalize).

**Proof Strategy**: Define torsion rank and torsion-type for Smith normal form entries. Prove the ℤ-coefficient insertion produces exactly one change in the combined (free rank, torsion profile) invariant.

**Domain Bridges**: Algebraic topology (torsion in homology), quantum error correction (homological codes), number theory (class groups as torsion).

**Lineage**: Extends the birth/death dichotomy from free rank to full homological type.

**Ambition**: Grand challenge — would unify persistent homology with arithmetic invariant theory.

---

## Direction 2: Tropical Stability Theorem for Event Profiles

**Conjecture**: If two weight functions w, w' on the same simplicial complex satisfy ||w − w'||_∞ ≤ ε, then the bottleneck distance between the induced tropical barcode profiles is at most ε. Moreover, the number of events whose type (birth/death) changes is bounded by the number of "critical crossings" — pairs of simplices whose weight ordering is reversed.

**The key insight is** that the tropical event type at each insertion depends on the boundary rank, which is a discrete invariant. Small weight perturbations can only change event types at insertions whose weight is within ε of another insertion's weight — the "critical crossings."

**Why now?** Classical stability (Cohen-Steiner–Edelsbrunner–Harer 2007) is established for barcodes but not for tropical event profiles. Our verified correspondence theorem (`tropical_persistent_rank_eq_classical`) provides the algebraic bridge. The stability statement is falsifiable and algorithmically testable.

**Test**: Generate 1000 pairs of random weight functions differing by at most ε = 0.1 on 2-complexes with 20 vertices. Compute both tropical event profiles. Measure bottleneck distance and compare to ε.

**Impact**: Would establish tropical event profiles as a robust descriptor for applications (materials science, sensor networks) where weights are measured with noise.

**Catalog References**: `Catalog/Pythagorean/TropicalMorse/Theorems.lean` — sublevel_perturbation_containment (graph-level stability). `Catalog/Pythagorean/TropicalMorse/SimplicialMorse.lean` — tropical_persistent_rank_eq_classical.

**Proof Strategy**: Use the interleaving distance between filtrations. Show that weight perturbation ε creates at most an ε-interleaving, which bounds the bottleneck distance on barcodes, which bounds the event profile divergence.

**Domain Bridges**: Topological data analysis (stability theory), signal processing (robustness), metric geometry (Gromov-Hausdorff stability).

**Lineage**: Direct extension of existing stability results to the tropical event language.

**Ambition**: Solid extension — essential infrastructure for applications.

---

## Direction 3: Spectral Dynamics of the Combinatorial Hodge Laplacian

**Conjecture**: At a tropical birth event in degree d, the smallest positive eigenvalue of the combinatorial Hodge Laplacian Δ_d decreases (the spectral gap narrows), while at a tropical death event, the smallest positive eigenvalue of Δ_{d−1} increases (a near-zero eigenvalue is pushed away from zero).

**The key insight is** that a birth creates a new zero-eigenvalue mode of Δ_d (a new harmonic chain, proved in `tropical_birth_implies_harmonic_rank_increase`), which should also perturb nearby eigenvalues. The spectral gap dynamics encode the "energy cost" of a tropical event.

**Why now?** Combinatorial Hodge theory has seen rapid development (Lim 2020, Schaub et al. 2020). The Hodge bridge in our formalization connects tropical events to eigenvalue changes. Spectral gap estimates are computable and empirically testable.

**Test**: For random 2-complexes with 15 vertices, compute the spectrum of Δ_1 at each filtration step. Plot the spectral gap as a function of filtration step, marking tropical events. Test whether births correlate with gap decrease and deaths with gap increase.

**Impact**: Would connect tropical Morse theory to graph neural network expressiveness (spectral filters), quantum walks on simplicial complexes, and the mixing time of higher-order random walks.

**Catalog References**: `Catalog/Pythagorean/TropicalMorse/SimplicialMorse.lean` — tropical_birth_implies_harmonic_rank_increase, tropical_death_implies_harmonic_rank_decrease.

**Proof Strategy**: Use eigenvalue perturbation theory for finite matrices. When adding a column to the boundary matrix, the Laplacian Δ = ∂∂* + ∂*∂ gains a rank-1 perturbation. Apply the interlacing inequalities for Hermitian matrices.

**Domain Bridges**: Spectral graph theory, quantum computing (quantum walks), machine learning (graph neural networks), statistical physics (relaxation dynamics).

**Lineage**: Extends the qualitative Hodge bridge to quantitative spectral estimates.

**Ambition**: Grand challenge — would create a unified tropical-spectral theory of simplicial dynamics.

---

## Direction 4: Tropical Energy Landscapes and Statistical Mechanics

**Conjecture**: Define the tropical partition function Z_trop(β) = min-plus sum over all d-chains of exp(−β · weight). Then the tropical free energy F_trop = −(1/β) · Z_trop satisfies an exact tropical Euler identity:
```
∑_d (−1)^d F_trop^(d) = tropical Euler characteristic
```
Moreover, tropical birth/death events correspond to discontinuities in the derivative dF_trop/dβ — phase transitions in the tropical statistical mechanics model.

**The key insight is** that filtration weight can be interpreted as energy, and the min-plus structure of tropical algebra is the zero-temperature limit of classical statistical mechanics. Tropical events are thus zero-temperature phase transitions.

**Why now?** The tropical persistent rank theorem establishes the accounting system. The connection to statistical mechanics is natural: in the min-plus limit (β → ∞), the Boltzmann distribution concentrates on the minimum-energy configuration, which is exactly the tropical critical value.

**Test**: For random weighted 2-complexes, compute the classical and tropical partition functions at several temperatures β. Verify that as β → ∞, the classical free energy converges to the tropical one, with discontinuities at tropical critical weights.

**Impact**: Would connect persistent homology to exactly solvable models in statistical physics, providing a new tool for analyzing energy landscapes of proteins, glasses, and spin systems.

**Catalog References**: `Catalog/Pythagorean/TropicalMorse/Theorems.lean` — percolation_transition_count, euler_char_from_filtration. `Catalog/Pythagorean/TropicalMorse/SimplicialMorse.lean` — euler_birth_contribution, euler_death_contribution.

**Proof Strategy**: Define the tropical partition function via the min-plus semiring. Show that the derivative of the free energy has jumps at tropical critical values by computing the tropical analog of the susceptibility.

**Domain Bridges**: Statistical mechanics (phase transitions), protein folding (energy landscapes), glass physics (jamming transitions), optimization (simulated annealing).

**Lineage**: Extends the Euler characteristic results to a full thermodynamic framework.

**Ambition**: Grand challenge — would establish "tropical statistical topology" as a new interdisciplinary field.

---

## Direction 5: Sheaf-Theoretic Tropical Persistence

**Conjecture**: The simplex insertion dichotomy generalizes to cellular sheaves on simplicial complexes. When a d-simplex σ is inserted into a sheaf-equipped complex, the sheaf cohomology change is controlled by the connecting map in the Mayer-Vietoris sequence of the sheaf restriction to σ and its boundary. The tropical event type encodes whether this connecting map is zero (birth) or injective (death).

**The key insight is** that sheaves generalize coefficients: instead of a fixed field 𝕜 at every simplex, each simplex carries its own vector space with restriction maps. The dichotomy should generalize because the long exact sequence machinery is universal.

**Why now?** Sheaf-theoretic persistence (Curry 2014, Ghrist 2014) is an active area with applications to sensor fusion, opinion dynamics, and distributed computing. The tropical event language could simplify sheaf persistence computations dramatically.

**Test**: Implement sheaf Betti numbers for a simple cellular sheaf on a 2-complex (e.g., constant sheaf on a triangulated torus). Verify the insertion dichotomy for sheaf cohomology at each step.

**Impact**: Would provide a tropical event language for sheaf persistence, opening applications in distributed systems (where sheaves model local-to-global consistency), quantum error correction (where sheaves model code spaces), and signal processing on simplicial complexes.

**Catalog References**: `Catalog/Pythagorean/TropicalMorse/SimplicialMorse.lean` — simplex_insertion_dichotomy (the simplicial case to generalize).

**Proof Strategy**: Replace the chain complex with the sheaf cochain complex. The relative complex of the pair (K', K) for a sheaf should still have a single generator in degree d, with values in the stalk of σ. Apply the long exact sequence of sheaf cohomology.

**Domain Bridges**: Algebraic geometry (sheaf cohomology), distributed computing (Čech cohomology of covers), quantum information (quantum sheaves), applied topology (multi-parameter persistence).

**Lineage**: Maximum generalization of the insertion dichotomy from constant coefficients to sheaf coefficients.

**Ambition**: Grand challenge — would unify tropical persistence with the sheaf-theoretic program in TDA.
