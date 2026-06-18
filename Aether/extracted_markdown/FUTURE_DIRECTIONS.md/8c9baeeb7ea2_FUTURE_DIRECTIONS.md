# Future Directions: Spectral Moonshine Beyond Orthogonality

## Synthesis

The five theorems established in this cycle — exact reconstruction, Parseval energy conservation, uniqueness of spectral coordinates, projector idempotence, and informational completeness — create a self-contained spectral calculus for class functions on finite groups. Together, they prove that moonshine packets equipped with complete orthonormal bases behave as exact finite-dimensional spectral transforms. This opens five distinct research trajectories: two grand challenges that could reshape how we think about symmetry decomposition and moonshine connections, and three concrete extensions that build directly on the proved theorems. The common thread is the insight that the *operator-theoretic* perspective (projectors, energy conservation, informational completeness) unlocks phenomena invisible to the purely algebraic character-theory viewpoint.

---

## Direction 1: Spectral Sparsity Rigidity — From Conjecture to Theorem

**Conjecture:** For any finite group *G* with complete orthonormal irreducible character basis {χᵢ}, any class function *f* with nonnegative integer spectral multiplicities and total spectral energy E(*f*) = 1 is equal to a single irreducible character.

The key insight is that unit spectral energy combined with integrality and nonnegativity forces atomicity — the spectral measure must be a single Dirac mass. This is a discrete analogue of the fact that probability measures on ℤ with total mass 1 and support at a single point are delta functions.

**Test:** Enumerate all integer-valued class functions on groups of order ≤ 60 (using GAP or SageMath character tables). For each, compute spectral multiplicities and check whether E(*f*) = 1 with nonneg integer coefficients implies *f* = χᵢ for some *i*. A single counterexample refutes the conjecture.

**Impact:** If true, this establishes a *spectral characterization of irreducible characters* — they are exactly the class functions with unit energy and integral nonnegative decomposition. This would give a new, operator-theoretic definition of irreducibility.

**Catalog References:** `Speculative/Moonshine/SpectralEngine.lean` (spectralEnergy, spectralEnergy_eq_zero_iff), `Speculative/Moonshine/Defs.lean` (IsOrthonormal, IsCompleteOrthonormal).

**Proof Strategy:** The key step is showing that if ∑ᵢ mᵢ = 1 where mᵢ ∈ ℤ≥0, then exactly one mᵢ = 1 and all others = 0. This is trivial arithmetically; the difficulty is connecting the energy condition ∑ mᵢ² = 1 with the multiplicities mᵢ = ⟨f, χᵢ⟩. The gap is proving that the mᵢ are exactly the spectral coefficients when f has integer values.

**Domain Bridges:** Connects to convex optimization (extreme points of spectral polytopes), quantum information (pure states as rank-1 projectors), and number theory (integral lattice points on spheres).

**Lineage:** Builds directly on Theorem 5 (informational completeness) and the spectral energy definition.

**Ambition:** Grand challenge — could establish a new characterization of irreducible representations.

**Why now?** The formal spectral energy framework provides the precise language to state and test this conjecture. Previous approaches lacked the operator-theoretic infrastructure to connect energy conditions to irreducibility.

---

## Direction 2: Automorphic Spectral Dynamics — Moonshine Packets as Modular Objects

**Conjecture:** For a moonshine packet {aₙ} associated to a finite group *G* (where each aₙ is a class function), the spectral energy sequence E(aₙ) satisfies an asymptotic growth law governed by the modular properties of the associated McKay–Thompson series.

The key insight is that spectral energy — defined as ∑ᵢ |⟨aₙ, χᵢ⟩|² — lifts the coefficient-level moonshine connection to an *energy-level* connection. If the McKay–Thompson series is a modular form of weight k, the energy sequence should grow as n^{2k-2} with explicit constants related to the Petersson norm.

**Test:** For the Monster group (using existing character tables and McKay–Thompson coefficients from the ATLAS), compute E(aₙ) for n ≤ 100 and fit the growth rate. Compare with the predicted exponent from modularity.

**Impact:** This would establish a *quantitative* moonshine connection at the spectral level, going beyond the qualitative statement that coefficients are characters.

**Catalog References:** `Speculative/Moonshine/Defs.lean` (MoonshinePacket, spectralWeight), `Speculative/Moonshine/SpectralEngine.lean` (spectralEnergy_eq_inner_self).

**Proof Strategy:** Use the Parseval identity (Theorem 2) to relate E(aₙ) to ⟨aₙ, aₙ⟩. If the McKay–Thompson series T_g(q) = ∑ aₙ(g) qⁿ is a modular form, then ⟨aₙ, aₙ⟩ can be analyzed using the Rankin–Selberg method.

**Domain Bridges:** Number theory (modular forms, Rankin–Selberg convolutions), analytic number theory (asymptotic analysis), physics (partition function asymptotics in conformal field theory).

**Lineage:** Extends the existing MoonshinePacket definition and Parseval theorem to the graded setting.

**Ambition:** Grand challenge — paradigm-shifting if the energy growth law has a clean modular interpretation.

**Why now?** The Parseval identity (Theorem 2) provides the formal bridge between energy and inner products that makes this analysis possible. Previous moonshine studies focused on individual coefficients, not energy.

---

## Direction 3: Spectral Entropy and Concentration Inequalities

**Conjecture:** For a class function *f* with ‖f‖ = 1 (normalized) and spectral coefficients cᵢ = ⟨f, χᵢ⟩, the spectral entropy H(*f*) = −∑ᵢ |cᵢ|² log |cᵢ|² satisfies H(*f*) ≤ log(k) where k is the number of conjugacy classes, with equality iff f is "spectrally flat" (all |cᵢ|² equal).

The key insight is that spectral entropy measures the "complexity" or "delocalization" of a class function across the irreducible representations. Low entropy means the function is concentrated on a few representations; high entropy means it is spread uniformly.

**Test:** Compute spectral entropy for random class functions on S₃, S₄, S₅ and verify the upper bound. Check that characters of regular representations achieve maximum entropy.

**Impact:** Establishes a rigorous information-theoretic measure of representation-theoretic complexity, enabling quantitative comparisons across families of class functions and groups.

**Catalog References:** `Speculative/Moonshine/SpectralEngine.lean` (spectralEnergy, spectralEnergy_eq_inner_self, spectralEnergy_eq_zero_iff).

**Proof Strategy:** This follows from the standard entropy inequality for probability distributions, applied to the distribution pᵢ = |cᵢ|²/∑|cᵢ|² = |cᵢ|² (after normalization using Parseval). The maximum entropy of a k-point distribution is log(k), achieved at the uniform distribution.

**Domain Bridges:** Information theory (Shannon entropy), quantum information (von Neumann entropy of spectral states), statistical mechanics (Boltzmann entropy of spectral distributions).

**Lineage:** Direct extension of Theorem 2 (Parseval) and Theorem 5 (informational completeness).

**Ambition:** Solid extension — the upper bound is essentially classical, but the characterization of equality and applications to specific families are nontrivial.

**Why now?** The Parseval identity provides the normalization that makes the spectral distribution well-defined. Without energy conservation, spectral entropy is not meaningful.

---

## Direction 4: Partial Reconstruction and Compressed Sensing on Groups

**Conjecture:** For a class function *f* that is *s*-sparse in the character basis (at most *s* nonzero Fourier coefficients), *f* can be exactly reconstructed from O(*s* log *k*) random evaluations at group elements, where *k* is the number of conjugacy classes.

The key insight is that the packet projector framework provides the reconstruction mechanism, and sparsity provides the information-theoretic redundancy. The character basis satisfies the restricted isometry property (RIP) required for compressed sensing, because orthonormality implies exact isometry.

**Test:** For Z/pZ with p prime (so k = p), generate s-sparse class functions and attempt reconstruction from random samples using ℓ₁ minimization. Measure the success rate as a function of the number of samples.

**Impact:** Enables efficient computation of spectral decompositions without evaluating the class function at every group element — crucial for large groups where |G| is exponentially larger than k.

**Catalog References:** `Speculative/Moonshine/SpectralEngine.lean` (packetProjector, packetProjector_idempotent, packetProjector_eq_self_of_complete_orthonormal).

**Proof Strategy:** Adapt the Candès–Tao RIP framework to the finite group setting. The orthonormality of characters provides the incoherence condition. The key technical step is bounding the coherence between random evaluation functionals and the character basis.

**Domain Bridges:** Signal processing (compressed sensing), optimization (ℓ₁ minimization, basis pursuit), computational algebra (efficient character evaluation).

**Lineage:** Builds on Theorem 1 (reconstruction), Theorem 3 (uniqueness), and the linearity lemmas (packetProjector_add, packetProjector_smul).

**Ambition:** Solid extension with high practical impact.

**Why now?** The formal reconstruction and uniqueness theorems provide the mathematical foundation that compressed sensing requires. The projector linearity lemmas ensure that the reconstruction operator is well-behaved.

---

## Direction 5: Quantum Spectral Tomography on Finite Groups

**Conjecture:** The spectral moonshine framework, when interpreted as a quantum measurement scheme, achieves the Gill–Massar bound for quantum state tomography efficiency on the space of class functions.

The key insight is that Theorem 5 (informational completeness) establishes that the character basis acts as an informationally complete measurement in the quantum sense. The efficiency of this measurement — how many copies of the "state" are needed to reconstruct it to a given precision — should match known bounds from quantum information theory.

**Test:** Simulate quantum tomography on the space of class functions for S₃ and S₄. Generate random "states" (normalized class functions), perform simulated measurements (compute noisy inner products with characters), and reconstruct using the packet projector. Compare the reconstruction error to the Gill–Massar lower bound.

**Impact:** Establishes a concrete, testable bridge between finite group representation theory and quantum information. Could lead to new quantum algorithms for group-theoretic problems.

**Catalog References:** `Speculative/Moonshine/SpectralEngine.lean` (spectralEnergy_eq_zero_iff, cfInner_packetProjector_basis, eq_of_inner_eq_on_complete_orthonormal).

**Proof Strategy:** The informational completeness theorem guarantees unique state identification. Efficiency analysis requires bounding the condition number of the reconstruction map, which in the orthonormal case is exactly 1 (perfect conditioning). The Gill–Massar bound then gives the sample complexity.

**Domain Bridges:** Quantum information (state tomography, SIC-POVMs), quantum computing (group-theoretic algorithms, hidden subgroup problem), experimental physics (quantum state estimation).

**Lineage:** Direct application of Theorem 5 (informational completeness) and Theorem 2 (Parseval/energy conservation).

**Ambition:** Grand challenge at the intersection of representation theory and quantum information.

**Why now?** The formal proof of informational completeness (Theorem 5) provides the rigorous mathematical guarantee that quantum tomography protocols require. Previous work on quantum tomography with group-theoretic structure lacked this formal foundation.
