# Future Directions: Lorentzian Anti-Cancellation in Statistical Physics

## Synthesis

The results established in this work reveal a deep structural connection between ferromagnetic partition polynomials and Lorentzian polynomial theory: positive Boltzmann weights ensure non-negative coefficients, which combined with positive aggregation weights guarantee anti-cancellation of susceptibility signals. The multiaffine Hessian of the partition polynomial carries a Lorentzian signature encoding the physics of ferromagnetic alignment, while the Newton inequality threshold provides a sharp algebraic marker for the onset of bimodal magnetization — a precursor to phase transitions. These findings open a systematic program connecting equilibrium statistical mechanics to combinatorial Hodge structures, with immediate implications for correlation screening algorithms, phase transition detection, and extensions to richer statistical mechanical models.

---

## Direction 1: Lorentzian Closure Under Edge Multiplication

**Conjecture:** For every finite graph G with non-negative couplings J ≥ 0 and β ≥ 0, the multiaffine sector of the partition polynomial — viewed as a function of the field variables — satisfies the Lorentzian condition: all iterated directional derivatives down to degree 2 yield quadratic forms with at most one positive eigenvalue, provided the directional derivatives use vectors in the positive orthant.

**Test:** Compute the Hessian eigenvalues after specializing n-2 variables to positive values for complete graphs K_3 through K_7, triangle-free graphs, and random graphs, at multiple coupling strengths. A single configuration yielding two positive eigenvalues at a positive specialization point disproves the conjecture.

**Impact:** If true, this would establish the full Lorentzian structure of ferromagnetic partition polynomials, completing the bridge between Lee-Yang stability theory and Brändén-Huh Lorentzian geometry. It would give structural proofs of log-concavity results for specialized coefficient sequences.

**Catalog References:**
- `Catalog/Pythagorean/LorentzianAggregateAntiCancel.lean` — anti-cancellation engine
- `Catalog/Speculative/AutoResearch/LorentzianGlauberMixing.lean` — Lorentzian gap certificates

**Proof Strategy:** Strategy B from the current work: decompose the partition polynomial as a product of edge factors, prove each edge factor is Lorentzian (using the multiaffine Hessian signature result for two variables), then apply Lorentzian closure under products / polarized compositions. The key missing ingredient is a formalized Lorentzian closure theorem for multiaffine products.

**Domain Bridges:** Statistical physics ↔ Combinatorial Hodge theory ↔ Algebraic geometry

**Lineage:** Extends Theorems 2 and 3 of the current work from two spins to general graphs.

**Ambition:** grand_challenge — Would establish a complete Lorentzian theory of partition functions.

---

## Direction 2: Anti-Cancellation for Potts and Random Cluster Models

**Conjecture:** The q-state Potts model partition polynomial (summing over q-colorings with Boltzmann weights for monochromatic edges) has non-negative coefficients in the Fortuin-Kasteleyn representation for integer q ≥ 1, and anti-cancellation holds for the associated susceptibility operators under positive weight aggregation.

**Test:** Implement the Fortuin-Kasteleyn polynomial for small graphs (K_3, K_4, cycle C_5) at q = 2, 3, 4 and verify: (a) coefficient positivity in the FK representation, (b) aggregate shadow = weighted Hessian support, (c) susceptibility numerator sign patterns.

**Impact:** Would extend the anti-cancellation framework from 2-state to q-state systems, encompassing a major class of statistical mechanical models including percolation (q=1) and chromatic polynomials (q→0).

**Catalog References:**
- `Catalog/Pythagorean/LorentzianAggregateAntiCancel.lean` — directly applicable via NonnegCoeffs

**Proof Strategy:** Show that the FK representation coefficients are products of terms (e^{βJ} - 1)^{|A|} · q^{k(A)} where A is a subset of edges and k(A) is the number of connected components. For ferromagnetic couplings, e^{βJ} - 1 ≥ 0 and q ≥ 1, making all coefficients non-negative. Then apply the existing anti-cancellation theorem.

**Domain Bridges:** Statistical physics ↔ Graph theory ↔ Matroid theory (Potts model ↔ Tutte polynomial ↔ matroid invariants)

**Lineage:** Direct extension of Theorem 5 (ising_aggregate_anticancel) to broader coefficient structures.

**Ambition:** solid_extension — Builds directly on existing catalog infrastructure.

---

## Direction 3: Phase Transition Detection via Hessian Rank Degeneration

**Conjecture:** The critical temperature β_c of the ferromagnetic Ising model on a sequence of growing graphs (e.g., boxes in Z^d) can be detected as the value of β where the multiaffine Hessian of the partition polynomial undergoes a rank transition: the number of eigenvalues exceeding a threshold changes discontinuously (in the infinite-volume limit).

**Test:** For the Ising model on L × L square lattices (L = 3, 4, 5, 6), compute the Hessian eigenvalue distribution at β values bracketing the known critical point β_c = ln(1+√2)/2. Track the fraction of eigenvalues above various thresholds and test for finite-size scaling consistent with a rank transition.

**Impact:** Would provide a novel algebraic criterion for phase transitions, distinct from the standard thermodynamic (free energy singularity) and probabilistic (correlation length divergence) criteria. Could lead to algorithms for detecting phase transitions from finite-size polynomial data.

**Catalog References:**
- `Catalog/Pythagorean/LorentzianAggregateAntiCancel.lean` — Hessian structure
- `Catalog/Speculative/AutoResearch/LorentzianGlauberMixing.lean` — spectral gap degradation near criticality

**Proof Strategy:** Use the Newton inequality threshold (Theorem 7) as a prototype: for two spins, the threshold β_c = ln 2 / J is exact. For general graphs, establish that the threshold for the first Newton inequality failure converges to the true critical temperature as graph size grows.

**Domain Bridges:** Statistical physics ↔ Random matrix theory ↔ Spectral graph theory

**Lineage:** Extends Theorem 7 (levelWeight₂_newton_iff) from two spins to general graphs.

**Ambition:** grand_challenge — Would create a new algebraic approach to critical phenomena.

---

## Direction 4: Information-Geometric Meaning of Susceptibility Shadows

**Conjecture:** The aggregate shadow of the susceptibility operator, viewed as a subset of the exponent lattice, is isomorphic (as a simplicial complex) to the Fisher information metric's support structure on the natural parameter space of the exponential family defined by the Gibbs measure.

**The key insight is** that the aggregate shadow encodes precisely which parameter directions have nonzero Fisher information, and anti-cancellation guarantees that this geometric structure cannot collapse accidentally.

**Why now?** The formalization of anti-cancellation provides, for the first time, a machine-verified guarantee that the shadow structure is exact. This makes it meaningful to ask what the shadow "means" in information-geometric terms.

**Test:** For the Ising model on small graphs, compute both: (a) the aggregate shadow as a subset of the exponent lattice, and (b) the support of the Fisher information matrix in natural coordinates. Verify isomorphism for K_3, K_4, and several random graphs.

**Impact:** Would connect Lorentzian anti-cancellation to information geometry, potentially providing new tools for optimal experimental design in statistical physics (which parameters to measure?) and for understanding the geometry of parameter estimation in exponential families.

**Catalog References:**
- `Catalog/Pythagorean/LorentzianAggregateAntiCancel.lean` — aggregate shadow definition

**Proof Strategy:** Express the Fisher information matrix as a Hessian of the log-partition function, relate its support to the susceptibility numerator's support, then use anti-cancellation to establish the isomorphism.

**Domain Bridges:** Statistical physics ↔ Information theory ↔ Differential geometry

**Lineage:** New direction inspired by the susceptibility numerator identity (Theorem 1).

**Ambition:** solid_extension — Builds on existing definitions with a novel interpretation.

---

## Direction 5: Quantum Many-Body Lorentzian Structure

**Conjecture:** The partition function of the quantum transverse-field Ising model, after Suzuki-Trotter decomposition into a (d+1)-dimensional classical system, retains Lorentzian structure in the spatial field variables. Specifically, the "imaginary time slice" partition polynomial has non-negative coefficients and satisfies anti-cancellation for the spatial susceptibility operator.

**The key insight is** that the Suzuki-Trotter decomposition maps a d-dimensional quantum system to a (d+1)-dimensional classical ferromagnet, preserving the positivity structure that enables anti-cancellation.

**Why now?** Classical Lorentzian anti-cancellation is now established. The Suzuki-Trotter connection to classical ferromagnets provides a natural pathway to quantum systems.

**Test:** Implement the Suzuki-Trotter decomposition for the transverse-field Ising model on small chains (L = 3, 4, 5) with M = 4, 8, 16 Trotter slices. Verify coefficient positivity and anti-cancellation in the spatial variables for each Trotter slice.

**Impact:** Would extend the Lorentzian anti-cancellation framework to quantum many-body physics, potentially providing new tools for understanding entanglement structure and quantum phase transitions through algebraic polynomial properties.

**Catalog References:**
- `Catalog/Pythagorean/LorentzianAggregateAntiCancel.lean` — anti-cancellation engine
- `Catalog/Speculative/AutoResearch/LorentzianGlauberMixing.lean` — spectral gap for dynamics

**Proof Strategy:** Show that the Suzuki-Trotter weights are products of ferromagnetic classical weights (hence positive), then apply the existing anti-cancellation theorem slice by slice. The challenge is managing the limit M → ∞.

**Domain Bridges:** Statistical physics ↔ Quantum many-body theory ↔ Tensor network theory

**Lineage:** Extension of all current theorems to the quantum domain.

**Ambition:** grand_challenge — Would open a Lorentzian theory for quantum partition functions.
