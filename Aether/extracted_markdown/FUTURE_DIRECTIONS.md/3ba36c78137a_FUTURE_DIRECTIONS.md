# Future Directions

## Synthesis

The formal verification of the quantum Runge-Lenz algebra opens five interconnected research directions that together form a coherent program: extending the SO(4) symmetry story from the hydrogen atom to broader mathematical and physical contexts. The verified Casimir eigenvalue C_n = ℏ²(n²-1), the branching rule n² = Σ(2l+1), and the energy quantization E_n = -mk²/(2ℏ²n²) are the foundation. Directions 1-2 deepen the representation-theoretic underpinnings. Direction 3 extends to relativistic physics. Directions 4-5 connect to geometry and number theory. All five are falsifiable and build on verified catalog theorems.

---

## Direction 1: Full so(4) Bracket Computation and Ladder Operator Formalism

**Conjecture:** The complete so(4) fission — [J⁺_i, J⁺_j] = iℏε_{ijk}J⁺_k, [J⁻_i, J⁻_j] = iℏε_{ijk}J⁻_k, [J⁺_i, J⁻_j] = 0 — can be proven purely algebraically from the five commutation axioms (hLL, hAL, hAA, hHL, hHA) and the bilinearity/antisymmetry of the bracket, using at most 4 intermediate lemmas.

**Test:** Formalize the bracket expansion [J⁺_i, J⁺_j] = ¼([L_i,L_j] + [L_i,A_j]/α + [A_i,L_j]/α + [A_i,A_j]/α²) in Lean 4, substitute the axioms, and verify the resulting expression equals iℏε_{ijk}J⁺_k. If any intermediate step fails to elaborate, the approach needs refinement.

**Impact:** Completes the formal verification of Pauli's 1926 calculation. Would be the first end-to-end machine proof of the so(4) structure of hydrogen.

**Catalog References:** `Pythagorean/QuantumRungeLenz.lean` (Jplus_add_Jminus, Jplus_sub_Jminus), `FINAL/Bridges/KeplerLaws.lean` (RungeLenzVector)

**Proof Strategy:** Define a helper lemma `bracket_Jplus_expand` that expands [J⁺_i, J⁺_j] using hadd_left, hadd_right, hlin_left, hlin_right. Then apply hLL, hAL, and hAA to each of the four terms. The key cancellation is that [A_i,A_j]/α² contributes a term proportional to H that must cancel with... actually it contributes to the L component. Carefully track the α² = -2mE substitution.

**Domain Bridges:** Lie algebra theory ↔ Quantum mechanics ↔ Representation theory

**Lineage:** Extends `Jplus_add_Jminus` and `Jplus_sub_Jminus` from QuantumRungeLenz.lean

**Ambition:** Medium — algebraically mechanical but requires careful bookkeeping

---

## Direction 2: Formal su(2) Representation Theory and Dimension Formula

**Conjecture:** The complete classification of finite-dimensional irreducible representations of su(2) — including the dimension formula dim(V_j) = 2j+1 for half-integer j — can be formalized in Lean 4 using Mathlib's existing Lie algebra infrastructure, requiring approximately 200-400 lines of new code.

**Test:** Define the standard su(2) generators (J₊, J₋, J₃) with [J₃, J±] = ±J± and [J₊, J₋] = 2J₃. Prove that every finite-dimensional irreducible representation has a highest weight vector, and that the weight space decomposition gives dim = 2j+1. Verify computationally for j = 0, ½, 1, 3/2, 2 using explicit matrix representations.

**Impact:** Would provide the representation-theoretic foundation for the hydrogen degeneracy, replacing the currently implicit use of the dimension formula. Major infrastructure contribution to Mathlib.

**Catalog References:** `Pythagorean/QuantumRungeLenz.lean` (hydrogen_degeneracy_formula, so4QuantumNumber)

**Proof Strategy:** Use the theory of highest weight modules. Key steps: (1) Prove J₃ is diagonalizable with integer/half-integer eigenvalues. (2) Prove J₊ raises eigenvalue by 1, J₋ lowers by 1. (3) Prove finite-dimensionality forces a highest weight. (4) Count the weight spaces.

**Domain Bridges:** Lie algebra representation theory ↔ Linear algebra ↔ Quantum mechanics

**Lineage:** Would formalize the mathematical justification for `hydrogen_degeneracy_formula`

**Ambition:** High — significant infrastructure building required

---

## Direction 3: Relativistic Extension — Dirac Hydrogen and so(4) → so(3,1) Deformation

**Conjecture (Grand Challenge):** The Dirac equation for hydrogen has a deformed symmetry algebra where the Runge-Lenz commutation relation [A_i, A_j] = -(2iℏ/m)H ε_{ijk}L_k is modified by relativistic corrections. The leading correction breaks the degeneracy as E_{n,j} = E_n(1 + α²(n/(j+½) - 3/4)/n) where α ≈ 1/137 is the fine structure constant. This fine structure splitting should be derivable algebraically from a deformation of the `RungeLenzBracketAlgebra` structure.

**Test:** Define a `RelativisticRungeLenzAlgebra` with a deformation parameter α. Compute the Casimir eigenvalue of the deformed algebra. Compare with the known Dirac fine structure formula. If the algebraic Casimir does not reproduce E_{n,j} to order α², the conjecture fails.

**Impact:** Would connect non-relativistic and relativistic quantum mechanics through Lie algebra deformation theory. Paradigm-shifting if the fine structure can be derived purely algebraically.

**Catalog References:** `Pythagorean/QuantumRungeLenz.lean` (RungeLenzBracketAlgebra, energy_from_casimir), `FINAL/Bridges/KeplerLaws.lean` (virial_theorem_algebraic)

**Proof Strategy:** The Dirac symmetry algebra is generated by the Johnson-Lippmann operator (relativistic analogue of the Runge-Lenz vector). The algebra is a deformation of so(4) parameterized by α²/n². Expanding the Casimir to order α² should give the fine structure.

**Domain Bridges:** Classical mechanics ↔ Quantum mechanics ↔ Special relativity ↔ Lie algebra deformation

**Lineage:** Extends `energy_from_casimir` to the relativistic regime

**Ambition:** Grand Challenge — requires building relativistic quantum mechanics infrastructure

---

## Direction 4: Spectral Geometry — Moser Regularization and Laplacian on S³

**Conjecture:** There exists a formally verifiable diffeomorphism between the phase space of the Kepler problem (restricted to the negative-energy surface) and the cotangent bundle T*S³, such that the Kepler Hamiltonian flow maps to geodesic flow on S³. Under this correspondence, the Casimir eigenvalue n²-1 maps exactly to the Laplacian eigenvalue k(k+2) with k = n-1.

**Test:** Formalize the Moser map: (q, p) ↦ (u, v) ∈ T*S³ where u = (2E·q + p²·q - 2(p·q)p) / (p² - 2E) and verify that the map preserves the symplectic form. Then verify that the pullback of the Laplacian Δ_{S³} gives the Kepler Hamiltonian on the constraint surface. If the eigenvalue correspondence k(k+2) ↔ n²-1 fails, the conjecture is wrong.

**Impact:** Would establish a formally verified bridge between spectral geometry and atomic physics. First machine proof of the Fock-Bargmann correspondence.

**Catalog References:** `Pythagorean/QuantumRungeLenz.lean` (hydrogen_S3_correspondence, casimir_quadratic), `FINAL/Bridges/KeplerLaws.lean` (Kepler orbit definitions)

**Proof Strategy:** Step 1: Define S³ as a Riemannian manifold in Lean. Step 2: Define the Moser regularization map. Step 3: Prove it's a symplectomorphism. Step 4: Verify the eigenvalue correspondence. Key difficulty: Lean/Mathlib's differential geometry may not yet support all needed constructions.

**Domain Bridges:** Spectral geometry ↔ Symplectic geometry ↔ Classical mechanics ↔ Quantum mechanics

**Lineage:** Extends `hydrogen_S3_correspondence` from a dimension identity to a geometric statement

**Ambition:** Grand Challenge — requires differential geometry infrastructure

---

## Direction 5: Tropical Hydrogen Spectrum and Arithmetic Geometry

**Conjecture:** The tropical spectral gap identity log((n+1)²) - log(n²) = 2(log(n+1) - log(n)) (proven in `tropical_spectral_gap`) extends to a tropical analogue of the Rydberg formula: the tropical transition energies Trop(ΔE_{n₁,n₂}) = log(1/n₁² - 1/n₂²) satisfy a tropical Casimir relation Trop(C) = max(Trop(L²), Trop(A²) - Trop(-2mE)) with tropical eigenvalue 2·log(n).

**Test:** Implement the tropical Rydberg formula computationally. Verify that for all pairs (n₁, n₂) with 1 ≤ n₁ < n₂ ≤ 50, the tropical transition energies satisfy the tropical Casimir relation to within numerical precision. If any pair fails, the conjecture is falsified.

**Impact:** Would establish a new connection between tropical geometry and quantum mechanics, potentially relating the hydrogen spectrum to valuations in non-Archimedean number theory.

**Catalog References:** `Pythagorean/QuantumRungeLenz.lean` (tropical_spectral_gap, casimir_action_variable), `Catalog/Pythagorean/TropicalKeplerOrbits.lean` (if it exists)

**Proof Strategy:** The tropicalization maps products to sums and sums to max. The energy E_n = -mk²/(2ℏ²n²) tropicalizes to Trop(E_n) = const - 2·log(n). The Casimir C_n = ℏ²(n²-1) ≈ ℏ²n² for large n, so Trop(C_n) ≈ 2·log(n). Verify the exact tropical relation by case analysis.

**Domain Bridges:** Tropical geometry ↔ Quantum mechanics ↔ Number theory ↔ Spectral theory

**Lineage:** Extends `tropical_spectral_gap` to the full Rydberg formula

**Ambition:** Medium — computationally testable, algebraically tractable
