# Future Directions: DPP-Lorentzian Entanglement Theory

## Synthesis

The formalized connection between Lorentzian polynomial geometry and free-fermion entanglement entropy opens a bidirectional bridge: algebraic-combinatorial tools (Newton inequalities, ultra-log-concavity, matroid theory) can now be deployed to study quantum entanglement, while quantum information constraints may feed back into new results in combinatorial Hodge theory. The directions below exploit this bridge from both sides, ranging from concrete extensions of proven results to paradigm-shifting conjectures linking quantum gravity to polynomial geometry.

---

## Direction 1: Higher-Order Entropy Bounds from the Full Newton Hierarchy

**Conjecture:** For free-fermion subsystems of size m with correlation spectrum λ ∈ [0,1]ᵐ, the Rényi entropies S_α = (1/(1-α)) log(Σ λᵢ^α + (1-λᵢ)^α) are controlled by the full sequence of Newton ratios ρₖ = eₖ²/(eₖ₋₁·eₖ₊₁). Specifically, there exists a universal function Ψ_α(ρ₁,...,ρₘ₋₁) such that |S_α - Ψ_α(ρ)| → 0 as m → ∞ for spectra satisfying an area-law scaling.

**Test:** Compute S_α for α ∈ {0.5, 1, 2, ∞} and the Newton ratio profiles for 1D free-fermion chains of length L = 50,...,500. Fit Ψ_α as a low-degree polynomial in the log-ratios. Test extrapolation accuracy on 2D models.

**Impact:** Would establish Lorentzian polynomial data as a complete surrogate for the entanglement spectrum, eliminating the need for diagonalization in entanglement studies.

**Catalog References:** `Pythagorean/EntanglementEntropy.lean` (entropy bounds, Newton inequality), `Bridges/LorentzianNewton.lean` (Newton inequality machinery).

**Proof Strategy:** Extend the variance lower bound S ≥ 2·Var to higher moments using power-mean inequalities. The k-th moment Σ λᵢᵏ is expressible via Newton-Girard identities in terms of e₁,...,eₖ. Lorentzian constraints on the eₖ then constrain all moments simultaneously.

**Domain Bridges:** Quantum information ↔ algebraic combinatorics ↔ approximation theory.

**Lineage:** Direct extension of `entropy_ge_esymm_bound` and `esymm_newton_inequality`.

**Ambition:** Solid extension — builds directly on proven results with clear path to formalization.

---

## Direction 2: Interacting Fermions and Approximate Gaussianity

**Conjecture:** For weakly interacting fermion systems with interaction strength ε, the entanglement entropy satisfies S ≤ S_free + C·ε·m·log(m), where S_free is the free-fermion entropy bounded by our coefficient method, and C is a universal constant independent of the system details.

**The key insight is** that weak interactions perturb the correlation kernel K_A by an amount proportional to ε, which changes the elementary symmetric polynomials by controlled amounts. The Lorentzian structure is stable under small perturbations (a property of the Lorentzian cone being open), so the coefficient-based bounds deform continuously.

**Why now?** The Brändén-Huh theory provides stability results for the Lorentzian cone, and our formalization gives the free-fermion baseline. The gap between interacting and non-interacting entropy is the central open question in quantum many-body physics.

**Test:** Simulate Hubbard chains at U/t = 0.1, 0.5, 1.0 via DMRG. Compare exact entropy to free-fermion coefficient bounds. Measure the correction term's dependence on U/t and subsystem size.

**Impact:** Would extend the DPP-Lorentzian framework beyond exactly solvable models to the physically relevant regime of interacting electrons.

**Catalog References:** `Pythagorean/EntanglementEntropy.lean`, `Speculative/AutoResearch/DPPLorentzian.lean`.

**Proof Strategy:** Use the Lieb-Robinson bound to control the perturbation of K_A under weak interactions, then apply Weyl's perturbation theorem for eigenvalues to bound the change in each eₖ.

**Domain Bridges:** Quantum many-body physics ↔ DPP theory ↔ perturbation theory.

**Lineage:** Extends all entropy bounds to approximately Gaussian states.

**Ambition:** Grand challenge — would bridge formal methods to the frontier of condensed matter physics.

---

## Direction 3: Tropical Entropy and Information Geometry

**Conjecture:** The tropical limit of the DPP generating polynomial (replacing + with max and × with +) yields a piecewise-linear function whose slopes encode a tropical entropy surrogate that approximates the von Neumann entropy to within O(1/m) for spectra satisfying an area law.

**The key insight is** that tropical geometry captures the leading-order behavior of log-coefficients. Since the entropy involves logarithms of eigenvalues, the tropical limit naturally approximates the entropy calculation. The Newton inequalities become tropical concavity conditions, which are equivalent to the matroid polytope being a generalized permutohedron.

**Why now?** Tropical methods have been applied to Lorentzian polynomials by Brändén-Huh and to information geometry by Ay-Jost-Lê-Schwachhöfer. Our formalization provides the first rigorous link between these two applications.

**Test:** For random spectra of size m = 10,...,100, compute the tropical generating polynomial and the tropical entropy surrogate. Compare to exact entropy. Characterize the error as a function of spectral flatness.

**Impact:** Would create a combinatorial (no analysis required) method for entropy estimation, potentially leading to polynomial-time algorithms for entanglement bounds in tensor network states.

**Catalog References:** `Pythagorean/EntanglementEntropy.lean`, `Catalog/Tropical/LorentzForce.lean`.

**Proof Strategy:** Use the Viro patchworking technique to relate the real and tropical generating polynomials, then bound the entropy approximation error using the discriminant of the tropical polynomial.

**Domain Bridges:** Tropical geometry ↔ quantum information ↔ computational complexity.

**Lineage:** Extends `esymmCoeff` and Newton inequality to the tropical setting.

**Ambition:** Grand challenge — paradigm-shifting if successful.

---

## Direction 4: Holographic Entanglement and Polynomial Bulk-Boundary Correspondence

**Conjecture:** For holographic quantum error-correcting codes (HaPPY codes and generalizations), the boundary entanglement entropy is controlled by a "bulk" Lorentzian polynomial whose coefficients are the areas of minimal surfaces in the tensor network. Newton's inequality for this polynomial implies the strong subadditivity of holographic entropy.

**The key insight is** that the Ryu-Takayanagi formula relates entanglement entropy to minimal surface areas, and these areas appear as coefficients in a generating polynomial associated with the bulk geometry. The Lorentzian property of this polynomial is equivalent to a discrete form of the null energy condition.

**Why now?** Tensor network models of holography (MERA, HaPPY) produce explicit coefficient sequences that can be checked for Lorentzianity. Our formalization provides the entropy-coefficient bridge needed to close the loop.

**Test:** Construct HaPPY codes on hyperbolic tilings with 3,...,7 layers. Compute the boundary entanglement entropy and the bulk coefficient sequence. Check Lorentzianity and compare entropy to coefficient-based bounds.

**Impact:** Would provide a new proof of strong subadditivity from geometric principles, potentially illuminating the AdS/CFT correspondence.

**Catalog References:** `Pythagorean/EntanglementEntropy.lean`, `Pythagorean/LorentzianRecognitionComplete.lean`.

**Proof Strategy:** Identify the generating polynomial of the holographic code with a DPP on the bulk graph, then apply the spectral bridge theorem to connect boundary entropy to bulk coefficients.

**Domain Bridges:** Holography ↔ DPP theory ↔ Lorentzian geometry ↔ quantum error correction.

**Lineage:** Extends the DPP-Lorentzian bridge to the holographic setting.

**Ambition:** Grand challenge — potentially paradigm-shifting for quantum gravity.

---

## Direction 5: Bosonic Analogues and Stability Obstructions

**Conjecture:** For free-boson systems, the generating polynomial of the subsystem is a *permanent* rather than a determinant, and is NOT Lorentzian in general. The failure of Lorentzianity is precisely what allows bosonic entanglement to violate the area law, and the degree of non-Lorentzianity (measured by the violation of Newton's inequality) quantifies the excess entropy above the free-fermion bound.

**The key insight is** that the DPP repulsion (which makes fermion entropy area-law) is encoded in the Lorentzian structure, while bosonic bunching (which allows volume-law entropy) corresponds to the anti-Lorentzian regime. The transition between the two regimes is controlled by a phase boundary in coefficient space.

**Why now?** Permanental point processes (PPPs) have been studied in probability but never connected to entanglement. Our formalization of the DPP/Lorentzian side provides the contrast needed to identify what fails for bosons.

**Test:** Compute the generating polynomials for free-boson subsystems of size m = 4,...,10 at various temperatures. Check Newton's inequality. Map the region in coefficient space where it fails. Correlate with entropy scaling (area vs volume law).

**Impact:** Would explain the area-law/volume-law dichotomy between fermions and bosons as a geometric phase transition in polynomial coefficient space.

**Catalog References:** `Pythagorean/EntanglementEntropy.lean`, `Speculative/AutoResearch/DPPLorentzian.lean`.

**Proof Strategy:** Formalize the permanent generating polynomial, show Newton's inequality fails for bosonic thermal states, and connect the failure to entropy scaling via the spectral moment identities already formalized.

**Domain Bridges:** Quantum optics ↔ permanental processes ↔ Lorentzian geometry ↔ area-law physics.

**Lineage:** Extends `esymm_newton_inequality` by characterizing its failure mode.

**Ambition:** Solid extension with grand-challenge implications — directly testable and formalizable.
