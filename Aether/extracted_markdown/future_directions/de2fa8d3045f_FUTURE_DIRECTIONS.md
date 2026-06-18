# Future Directions: Substitution Spectra and Aperiodic Tiling Theory

## Synthesis

This research cycle established the **substitution spectrum** as a novel algebraic framework for studying parameterized families of aperiodic tiling systems. The key discovery is that the expansion factor — the fundamental invariant controlling aperiodicity — is locked in by the substitution matrix and is therefore constant across any continuous family of geometric realizations. This spectral invariance, combined with the irrational expansion obstruction theorem, provides a purely algebraic certificate of aperiodicity that applies uniformly to entire families of tiles.

The most promising cross-domain connection is between substitution tiling theory and **dynamical systems on symbolic sequences**. The substitution matrix acts as a transition matrix for a symbolic dynamical system, and the Pisot-like eigenvalue structure (dominant eigenvalue > 1, subdominant in (0,1)) is precisely the condition for exponentially fast mixing — a concept that bridges to the ergodic theory results in `Bridges/ProofStoneCechDynamics.lean`. The periodic orbit varieties in `Bridges/PeriodicOrbitVarieties.lean` (where periodic orbits of cellular automata are studied) provide a natural algebraic-geometric setting for studying the *absence* of periodic orbits in substitution dynamics.

The highest breakthrough potential lies in Direction 1 (Spectral Classification), which could produce a complete invariant for aperiodic substitution systems and connect to the tropical algebra framework already developed in the Catalog's `Tropical/` module.

---

### Direction 1: Spectral Classification of Aperiodic Substitution Systems

**Conjecture**: Two substitution tiling systems with the same characteristic polynomial (same trace and determinant for 2×2, same elementary symmetric functions for n×n) are "spectrally equivalent" in the sense that they admit the same qualitative aperiodicity behavior: either both admit periodic tilings or neither does. More precisely, aperiodicity of a substitution system depends only on the eigenvalues of the substitution matrix, not on the eigenvectors or the specific matrix entries.

**Test**: Construct two distinct 2×2 substitution matrices with the same characteristic polynomial x² - 8x + 4 (trace 8, determinant 4) but different entries (e.g., [[4,6],[2,4]] vs [[5,4],[3,3]]). Verify that both have the same eigenvalues 4 ± 2√3 and that both satisfy the irrational expansion obstruction. Then check whether both can actually be realized as substitution rules for geometric tiles.

**Impact**: If true, this provides a classification of aperiodic substitution systems by characteristic polynomial — a dramatic simplification. If false, the failure reveals what additional algebraic data beyond eigenvalues is needed, potentially leading to a richer invariant theory.

**Catalog References**: `Novelty/AperiodicMonotile/SubstitutionSystem.lean`, `Bridges/PeriodicOrbitVarieties.lean`

**Proof Strategy**: 
1. Formalize the notion of spectral equivalence class.
2. Prove that the irrational expansion obstruction depends only on eigenvalues (this follows from our Theorem 3.3 since the obstruction involves only λ²).
3. Investigate whether the Perron eigenvector direction (which affects geometric realizability) can be varied freely within a spectral class.
4. Key lemma needed: existence of a positive eigenvector for any primitive matrix with Perron root > 1 (Perron-Frobenius theorem).

**Domain Bridges**: Substitution Dynamics ↔ Symbolic Dynamics (`Bridges/PeriodicOrbitVarieties.lean`), Substitution Spectra ↔ Tropical Eigenvalues (`Tropical/PeriodicOrbits.lean`)

**Lineage**: Builds on the spectral invariance theorem (Theorem 3.2) and irrational expansion obstruction (Theorem 3.3) from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Substitution Matrices and Min-Plus Aperiodicity

**Conjecture**: The substitution matrix framework can be lifted to the **tropical semiring** (min-plus algebra), where the substitution matrix M becomes a tropical matrix M_trop with entries in ℝ ∪ {+∞}. The tropical eigenvalue of M_trop (= minimum cycle mean) provides a lower bound on the logarithm of the classical Perron root. When the tropical eigenvalue is irrational, this provides a *purely combinatorial* certificate of aperiodicity that does not require computing classical eigenvalues.

**Test**: Compute the tropical substitution matrix for the hat tile: replace each entry M(i,j) with -log(M(i,j)) (or +∞ for zero entries). Compute its tropical eigenvalue and verify it relates to log(4 + 2√3). Check whether the tropical eigenvalue is irrational, and whether this irrationality is preserved under perturbation of the entries.

**Impact**: Tropical aperiodicity certificates would be computable in polynomial time (tropical eigenvalues are solvable by shortest path algorithms), potentially enabling efficient screening of candidate substitution matrices for aperiodicity. This connects two seemingly unrelated areas: aperiodic tiling theory and tropical geometry.

**Catalog References**: `Tropical/PeriodicOrbits.lean`, `Tropical/CertifiedNormalForm.lean`, `Cryptography/BerggrenDiophantineLattice.lean`

**Proof Strategy**:
1. Define tropical substitution matrix as the entry-wise negative log of the classical matrix.
2. Prove that the tropical eigenvalue ≤ log(Perron root) with equality when the matrix has rank-1 tropical eigenspace.
3. Formalize tropical irrationality as a certificate.
4. Use the min-plus cellular automata framework from `Tropical/PeriodicOrbits.lean` to connect periodic orbits in tropical dynamics to periodic tilings.

**Domain Bridges**: Tropical Algebra ↔ Substitution Tiling Theory, Min-Plus Dynamics (`Tropical/PeriodicOrbits.lean`) ↔ Aperiodicity Certification

**Lineage**: Builds on the substitution spectrum framework and connects to the Catalog's tropical module.

**Ambition**: grand_challenge

---

### Direction 3: Higher-Dimensional Substitution Spectra

**Conjecture**: The substitution spectrum construction generalizes to n×n matrices (n ≥ 3 prototile types). For an n-type substitution system, the expansion factor is determined by the largest real eigenvalue of the n×n matrix, and the irrational expansion obstruction generalizes: if the Perron root is a degree-n algebraic integer with no rational eigenvalue being a root of unity, the system is aperiodic.

**Test**: Construct a 3×3 substitution matrix (e.g., for a hypothetical 3-type tiling system) with characteristic polynomial having no rational roots. Verify that the irrational expansion obstruction applies. Attempt to construct a geometric realization with 3 tile types that admits only aperiodic tilings.

**Impact**: Most known aperiodic tiling systems (Penrose, Ammann-Beenker, etc.) use 2-4 tile types. A systematic theory for n-type systems would unify these examples and potentially discover new aperiodic tiling families.

**Catalog References**: `Novelty/AperiodicMonotile/SubstitutionSystem.lean` (the framework already supports arbitrary n), `EML/AdvancedTheory.lean`

**Proof Strategy**:
1. The SubstitutionSystem and SubstitutionSpectrum structures already support arbitrary n. Key new results needed:
2. Perron-Frobenius theorem for n×n non-negative matrices (exists in Mathlib as `Matrix.PosMulStrictMono`).
3. Generalize the irrational expansion obstruction from "irrational λ²" to "λ² is not in the field generated by the area ratios."
4. Construct explicit 3×3 examples and verify computationally.

**Domain Bridges**: Linear Algebra (Perron-Frobenius) ↔ Tiling Theory, Algebraic Number Theory (Pisot numbers) ↔ Spectral Classification

**Lineage**: Direct extension of the n=2 hat system results from this cycle.

**Ambition**: extension

---

### Direction 4: Substitution Dynamics and Ergodic Theory

**Conjecture**: The substitution tiling system defines a uniquely ergodic symbolic dynamical system. The unique invariant measure assigns to each cylinder set [w] (a local patch of tiles) a probability proportional to the Perron eigenvector entry. The Pisot-like property (subdominant eigenvalue in (0,1)) implies exponential mixing with rate equal to log(λ₁/λ₂).

**Test**: For the hat matrix M = [[4,6],[2,4]], compute the mixing rate log((4+2√3)/(4-2√3)) = log((4+2√3)²/4). Verify numerically that the correlation function of the substitution dynamical system decays at this rate. Compare with the frequency convergence rate computed in this cycle.

**Impact**: Connecting substitution tilings to ergodic theory would bring powerful tools (entropy, mixing, spectral measures) to bear on tiling problems. The exponential mixing rate is a computable invariant that could distinguish between different aperiodic tiling families.

**Catalog References**: `Bridges/ProofStoneCechDynamics.lean` (periodic points in compact dynamics), `Bridges/PeriodicOrbitVarieties.lean` (periodic orbit structure)

**Proof Strategy**:
1. Define the substitution dynamical system as a shift on the space of bi-infinite sequences over the tile alphabet.
2. Prove unique ergodicity using the Perron-Frobenius theorem (the Perron eigenvector defines the unique stationary measure).
3. Prove exponential mixing using the spectral gap |λ₂/λ₁| < 1.
4. Connect to the Stone-Čech dynamics framework in `Bridges/ProofStoneCechDynamics.lean`.

**Domain Bridges**: Substitution Dynamics ↔ Ergodic Theory, Spectral Gap ↔ Mixing Rate, Tiling ↔ Symbolic Dynamics

**Lineage**: Builds on the Pisot-like eigenvalue structure (Theorems 4.4) and the frequency convergence demonstrated computationally.

**Ambition**: extension

---

### Direction 5: Computational Search for Novel Aperiodic Monotile Families

**Conjecture**: There exist 2×2 substitution matrices with determinant 1 (unimodular) and irrational Perron root that correspond to geometrically realizable aperiodic monotile families distinct from the hat spectrum. Specifically, the matrix [[3,5],[1,3]] (trace 6, det 4, eigenvalues 3±√5, expansion factor (1+√5)/√... ) should define a new aperiodic monotile family unrelated to the hat.

**Test**: Enumerate all 2×2 matrices with entries in {1,...,8}, trace ≤ 12, determinant ≤ 10, and irrational Perron root. For each, check whether the Perron eigenvector has entries that could correspond to areas of a 13-gon (or other simple polygon). Attempt to construct geometric tiles matching the algebraic data.

**Impact**: Discovery of new aperiodic monotile families beyond the hat-turtle spectrum would demonstrate that the algebraic framework identifies tiling systems that geometry alone cannot easily find. This would validate the substitution spectrum approach as a discovery tool.

**Catalog References**: `Novelty/AperiodicMonotile/SubstitutionSystem.lean`, `Cryptography/BerggrenDiophantineLattice.lean` (Diophantine conditions on lattice points)

**Proof Strategy**:
1. Computational enumeration of candidate matrices (Python).
2. For each candidate, compute spectral data and check Pisot-like property.
3. For promising candidates, attempt geometric realization using edge-length parameterization.
4. Formalize the algebraic certificate in Lean for any successful candidate.

**Domain Bridges**: Computational Search ↔ Algebraic Certification, Number Theory (Pisot/Salem numbers) ↔ Tiling Geometry

**Lineage**: Extends the hat spectral data analysis to a systematic search.

**Ambition**: extension
