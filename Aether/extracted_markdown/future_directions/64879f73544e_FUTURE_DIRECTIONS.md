# Future Directions: Proof-Theoretic Algebraic Geometry

## Breakthrough Opportunities (ranked by impact)

### 1. Graded Proof Spectra and ML Capacity Theory

**Theorem Statement**: For a ℤ-graded proof semiring R = ⊕ᵢ Rᵢ, define the Hilbert function H(n) = dim Rₙ. Then the VC-dimension of the associated tropical neural network equals the degree of the Hilbert polynomial of Spec(R).

**Proof Strategy**:
1. Define graded semiring congruences using Mathlib's `GradedRing` infrastructure
2. Show that homogeneous prime congruences correspond to irreducible tropical hypersurfaces
3. Connect the Hilbert polynomial degree to the Sauer-Shelah lemma via a counting argument

**Why This Is Revolutionary**: It would give an algebraic theory of neural network capacity — the first rigorous connection between Hilbert polynomials (a classical algebraic geometry invariant) and VC-dimension (the fundamental measure of learning capacity). This could yield model selection criteria based on algebraic geometry rather than heuristic cross-validation.

**Catalog Leverage**: Build on `idempotent_add_natural_preorder` and the Zariski topology properties from Core.lean. Use the Galois connection machinery for the correspondence.

**Research Mode**: prove  
**Estimated Depth**: 4

---

### 2. Sheaf Cohomology of the Proof Spectrum

**Theorem Statement**: For R = tropical polynomial semiring in n variables, H⁰(Spec(R), 𝒪) ≅ R (global sections = proof terms) and H¹(Spec(R), 𝒪) classifies non-trivial extensions of proof congruences.

**Proof Strategy**:
1. Define the structure sheaf 𝒪 on Spec(R) using localization at prime congruences
2. Show Čech cohomology vanishes for affine opens (tropical analogue of Serre's theorem)
3. Compute H¹ explicitly for the tropical line ℝ_{max}[x]

**Why This Is Revolutionary**: Sheaf cohomology of tropical varieties is a major open area in tropical geometry. Doing this in the proof-theoretic setting would simultaneously advance tropical geometry and give new invariants of proof systems (H¹ = obstructions to proof composition).

**Catalog Leverage**: Extends `zariskiClosed_iInter` and `galois_closure_idempotent`. Use the functoriality from `spectrum_contravariant`.

**Research Mode**: prove  
**Estimated Depth**: 5

---

### 3. Prime Congruence Separation for General Semirings

**Theorem Statement**: For any commutative semiring R and semiprime kernel K, if a ∉ K, there exists a prime proof congruence P such that K ⊆ ker(P) and a ∉ ker(P).

**Proof Strategy**:
1. Use the Bourne congruence construction: define rel_I(a,b) ↔ ∃ s,t ∈ I, a+s = b+t
2. Show that for k-closed theories (a+b ∈ T ∧ b ∈ T → a ∈ T), the Bourne congruence is a semiring congruence
3. Apply Zorn's lemma to find a maximal proper Bourne congruence containing K

**Why This Is Revolutionary**: This would close the main gap in the existing catalog file `PrimeCongruenceProofSemiring.lean`, resolving `prime_congruence_separation_conjecture`. It would complete the bridge between theory-based and congruence-based approaches to proof spectra.

**Catalog Leverage**: Directly extends `exists_prime_theory_avoiding` from the catalog. Uses `semiprime_eq_iInter_prime_theories`.

**Research Mode**: prove  
**Estimated Depth**: 3

---

### 4. Tropical Langlands Correspondence

**Theorem Statement**: There is a bijection between prime congruences of the tropical polynomial ring ℝ_{max}[x₁,...,xₙ] and tropical Galois representations ρ: Gal(ℝ_{max}^{alg}/ℝ_{max}) → GL_n(ℝ_{max}).

**Proof Strategy**:
1. Define the tropical absolute Galois group using automorphisms of the tropical algebraic closure
2. Construct the association prime congruence → tropical representation via the residue field action
3. Show bijectivity using the tropical Nullstellensatz

**Why This Is Revolutionary**: This would be the first concrete instance of a "Langlands program" for tropical mathematics, connecting the arithmetic side (Galois representations) to the automorphic side (spectral data). It could yield new insights into the classical Langlands program by providing a simplified tropical model.

**Catalog Leverage**: Uses `radical_fixpoint_iff_inter_primes` for the Nullstellensatz component. Extends `spectrum_contravariant` for the functoriality.

**Research Mode**: discover  
**Estimated Depth**: 5

---

### 5. Quantum Proof Spectra and Entanglement Measures

**Theorem Statement**: For a quantum proof semiring R_ℂ (over ℂ with superposition), define ProofSpectrum(R_ℂ) using prime *-congruences. Then the entanglement entropy of a bipartite quantum proof state equals the mutual information between the two factor spectra.

**Proof Strategy**:
1. Define *-congruences (compatible with complex conjugation) using Mathlib's star algebra
2. Show that the spectrum of a tensor product R ⊗ S maps to Spec(R) × Spec(S)
3. Define entanglement entropy as the von Neumann entropy of the reduced state on one factor
4. Prove the mutual information formula using the chain rule for entropy

**Why This Is Revolutionary**: This would connect proof theory to quantum information theory, providing a geometric interpretation of entanglement. The quantum advantage bound of Ω(2^(n/2)) would follow from the spectrum dimension, giving algebraic proofs of quantum speedup results.

**Catalog Leverage**: Extends `product_spectrum_injection` and `exponential_lower_bound`. Uses the tower function hierarchy for complexity bounds.

**Research Mode**: discover  
**Estimated Depth**: 5

---

## Under-explored Territory

### Congruence Varieties Beyond Ideals

The existing theory focuses on zero classes of congruences (analogues of ideals). But congruences carry strictly more information: the equivalence class of every element, not just zero. Exploring the full variety structure of congruence classes — not just zero classes — could reveal phenomena with no ring-theoretic analogue.

### Computational Aspects of the Spectrum

We proved existence of complexity bounds but did not construct explicit algorithms. Building verified algorithms for:
- Computing the prime congruence decomposition of a finite semiring
- Testing membership in the radical closure
- Enumerating the proof spectrum up to isomorphism

would make the theory computationally actionable.

### Non-commutative Proof Spectra

All our results assume commutativity. In proof theory, the order of proof steps matters (conjunction is non-commutative). Extending to non-commutative semirings would require developing the theory of prime congruences without commutativity — a largely unexplored area.

## Cross-Domain Bridges

### Algebraic Geometry → Proof Complexity

**Conjectured bridge**: The Krull dimension of ProofSpectrum(R) equals the circuit complexity of the proof system R. This would connect algebraic dimension theory to computational complexity.

### Tropical Geometry → Discrete Optimization

**Conjectured bridge**: The prime congruence decomposition of a tropical semiring encodes the LP relaxation hierarchy. Prime congruences correspond to basic feasible solutions, and the radical closure corresponds to the integer hull.

### Spectral Theory → Neural Network Architecture

**Conjectured bridge**: The sheaf cohomology H*(Spec(R), 𝒪) for R = tropical polynomial semiring determines the optimal depth and width of a tropical neural network for a given approximation task.

## Open Problems Encountered

1. **K-closedness in general semirings**: Is every prime theory in a commutative semiring k-closed (a+b ∈ T ∧ b ∈ T → a ∈ T)? This is needed to lift from prime theories to prime congruences.

2. **Spectral space structure**: We proved the Zariski topology properties but did not establish the full spectral space axioms (compactness, sobriety). The compactness argument requires showing that V(∅) = ∅ implies a finite sub-intersection is already empty — this needs careful handling of the axiom of choice.

3. **Noetherian proof semirings**: Which proof semirings are Noetherian (every ascending chain of congruences stabilizes)? This is needed for the full Nullstellensatz.

4. **Tower function optimality**: Is the tower-function bound towerExp(d) tight for cut-elimination blowup, or can it be improved to a simpler exponential? This connects to long-standing open problems in proof complexity.

5. **Certified robustness tightness**: Is the bound r* ≥ δ/(2Kd) tight, or can the dependence on spectrum size K be improved? Examples suggest K might be replaceable by log(K).
