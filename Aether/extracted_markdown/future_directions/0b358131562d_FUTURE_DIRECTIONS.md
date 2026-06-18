# Future Directions: Non-Group Markov Chain Comparison

## Synthesis

The comparison theorem for non-group reversible chains, now formally verified, opens a new axis of formal mathematical development. The core insight — that spectral gap certification can be liberated from group symmetry through controlled comparison — creates a bridge from the well-developed algebraic theory of Cayley expanders to the vast landscape of combinatorial Markov chains. The five directions below form a coherent research program: Direction 1 completes the canonical-path pipeline; Direction 2 creates quantitative tools for practitioners; Direction 3 bridges to information theory; Direction 4 connects to statistical physics phase transitions; and Direction 5 pursues the grand challenge of automated mixing certification.

---

## Direction 1: Path Congestion to Dirichlet Form Comparison — Completing the Pipeline

**Conjecture**: If Γ is a path system routing P-edges through Q-edges with congestion ρ (as defined by `PathCongestion`), then E_P(f) ≤ ρ · E_Q(f) for all f. Combined with the formally verified `poincare_comparison`, this would yield λ(Q) ≥ λ(P)/ρ — the full canonical-path theorem for non-group chains.

**Test**: Verify on all reversible chains on ≤ 6 states that the congestion bound correctly predicts the Dirichlet form comparison constant within a factor of 2. A counterexample with ratio > 2 would indicate the congestion definition needs refinement.

**Impact**: Completes the formal pipeline from combinatorial path data to certified spectral gaps, making the comparison theorem immediately applicable to any chain where explicit paths can be constructed.

**Catalog References**:
- `Pythagorean/CayleyExpander/CanonicalPaths.lean` — `variance_le_congestion_mul_energy`
- `Pythagorean/MarkovComparison/NonGroupComparison.lean` — `poincare_comparison`

**Proof Strategy**: The proof requires a telescoping argument along paths (generalizing `telescope_word` from the Cayley catalog) combined with Cauchy–Schwarz. The key step is: (f(x) - f(y))² ≤ |γ| · Σ_{e ∈ γ} (∇_e f)². Sum over x,y weighted by π(x)P(x,y), swap the order of summation, and use the congestion bound.

**Domain Bridges**: Probability theory ↔ Combinatorial optimization (congestion as a graph property)

**Lineage**: Direct descendant of `sqDiff_le_len_mul_sum_sqDiffs` from `CanonicalPaths.lean`

**Ambition**: 🔴 Paradigm shift — removes the last group-theoretic dependency from the canonical-path method

**The key insight is** that the telescoping + Cauchy–Schwarz argument uses only path structure, not group multiplication, so it transfers directly to non-group chains with the same formal structure.

**Why now?** The comparison theorem is verified, the definitions of `PathCongestion` and `dirichletForm` are in place, and the proof template from `CanonicalPaths.lean` provides a clear roadmap.

---

## Direction 2: Quantitative Mixing Time Bounds via Comparison Transport

**Conjecture**: For any chain P compared to reference Q via `ReversibleChainComparison` with parameters (b, C), the mixing time satisfies t_mix(P, ε) ≤ (b·C/λ(Q)) · (log|α| + log(1/ε)). Moreover, the prefactor b·C is tight up to constants for the class of "lazy path walks compared to jump walks."

**Test**: Compute exact mixing times (defined as first time TV distance < 1/4) for all reversible chains on 5 states, and verify the predicted bound is within a factor of n of the truth.

**Impact**: Creates the first formally certified mixing time bounds for non-group chains, with practical implications for MCMC stopping rules.

**Catalog References**:
- `Pythagorean/CayleyExpander/MixingTime.lean` — `tv_le_half_sqrt_card_mul_l2`
- `Pythagorean/MarkovComparison/NonGroupComparison.lean` — `spectralGap_lower_bound_of_dirichlet_comparison`

**Proof Strategy**: Combine the comparison theorem's spectral gap bound with the TV-L² comparison from `MixingTime.lean`. The L² distance at time t satisfies ||P^t - π||²_{L²(π)} ≤ (1-λ)^{2t} · (|α|-1), and TV ≤ (1/2)√(|α|) · ||·||_{L²}.

**Domain Bridges**: Probability theory ↔ Algorithms (MCMC stopping rules) ↔ Statistics (sampling guarantees)

**Lineage**: Combines two catalog lineages: comparison (this work) and mixing time (CayleyExpander)

**Ambition**: 🟡 Solid extension — connects existing verified results into a practical tool

**The key insight is** that the comparison theorem produces a spectral gap bound in exactly the form needed by the mixing time machinery already formalized in the catalog.

**Why now?** Both the comparison theorem and the mixing time infrastructure are verified; the connection is a straightforward composition.

---

## Direction 3: Information-Theoretic Comparison via Modified Log-Sobolev Inequalities

**Conjecture**: The comparison method extends to modified log-Sobolev inequalities (MLSI): if chain Q satisfies MLSI with constant α_Q, and the "entropy comparison constant" C_ent satisfies Ent_Q(f²) ≤ C_ent · Ent_P(f²), then P satisfies MLSI with constant α_Q/C_ent. This would give O(log log n) mixing time improvements over the Poincaré route.

**Test**: For the Glauber dynamics on the Ising model at β < β_c (high temperature), verify computationally that the MLSI constant scales polynomially in n, while the Poincaré constant scales polynomially with a worse exponent.

**Impact**: Bridges probability theory to information theory through entropy methods, and provides exponentially better mixing bounds for chains with hypercontractive properties.

**Catalog References**:
- `Pythagorean/CayleyExpander/LogSobolev.lean` — log-Sobolev infrastructure
- `Pythagorean/MarkovComparison/NonGroupComparison.lean` — comparison framework

**Proof Strategy**: Replace variance with entropy, Dirichlet form with entropy dissipation, and adapt the comparison argument. The key difficulty is that entropy is not a quadratic functional, so the "choose optimal c" trick from variance comparison needs modification.

**Domain Bridges**: Probability theory ↔ Information theory (entropy, KL divergence) ↔ Quantum information (hypercontractivity)

**Lineage**: Extension of comparison framework + log-Sobolev catalog

**Ambition**: 🔴 Grand challenge — would create the first formally verified MLSI comparison theorem

**The key insight is** that the comparison principle is fundamentally about transferring functional inequalities, and the Poincaré inequality is just one instance of a general pattern that includes log-Sobolev, Nash, and Beckner inequalities.

**Why now?** The log-Sobolev infrastructure exists in the catalog, and the comparison framework provides the template for the proof structure.

---

## Direction 4: Phase Transition Detection via Comparison Breakdown

**Conjecture**: For the Ising model on Z²_n at inverse temperature β, the comparison constant C(β) between Glauber dynamics and a reference block dynamics satisfies C(β) = O(poly(n)) for β < β_c and C(β) = exp(Ω(n)) for β > β_c. The comparison theorem thus formally detects the phase transition: the bound is useful above the critical temperature and provably useless below.

**Test**: Compute C(β) for Ising model on 4×4, 6×6, 8×8 grids as β crosses the critical value β_c ≈ 0.4407. Observe the transition from polynomial to exponential growth.

**Impact**: Creates a formal mathematical framework for detecting and certifying phase transitions through comparison-theoretic lens, connecting mixing theory to statistical physics.

**Catalog References**:
- `Pythagorean/MarkovComparison/NonGroupComparison.lean` — `ReversibleChainComparison`
- `Pythagorean/CayleyExpander/MixingTime.lean` — relaxation time

**Proof Strategy**: For β < β_c, use Dobrushin's condition to bound the comparison constant polynomially. For β > β_c, construct explicit "bottleneck" functions where E_P/E_Q is exponentially large, using the phase boundary as a witness.

**Domain Bridges**: Probability theory ↔ Statistical physics (phase transitions) ↔ Complexity theory (computational hardness of sampling)

**Lineage**: Application of comparison framework to physics

**Ambition**: 🔴 Grand challenge — formal verification of a phase transition phenomenon

**The key insight is** that the comparison constant C is not just a technical parameter: its growth rate as a function of system size encodes fundamental physical information about the presence or absence of long-range order.

**Why now?** The comparison framework is verified, and the Ising model is one of the most-studied systems in mathematical physics, with extensive rigorous theory to guide the formalization.

---

## Direction 5: Automated Comparison Chain Discovery

**Conjecture**: For any reversible chain P on n states with spectral gap λ(P), there exists a reference chain Q and comparison constants (b, C) with b·C ≤ poly(n)/λ(P) that can be found in polynomial time. In other words, the comparison method is computationally universal: it can always achieve a polynomially tight bound.

**Test**: Implement a heuristic search over reference chains for random reversible chains on 10-20 states. Measure the ratio (best achievable b·C)/(1/λ(P)) and check if it grows polynomially in n.

**Impact**: Would transform the comparison theorem from a proof technique into an algorithm, enabling automatic certified mixing time bounds for arbitrary MCMC methods.

**Catalog References**:
- `Pythagorean/MarkovComparison/NonGroupComparison.lean` — all definitions and theorems
- `Pythagorean/CayleyExpander/CanonicalPaths.lean` — path construction examples

**Proof Strategy**: Use semidefinite programming (SDP) to optimize over the space of reference chains Q. The constraint E_Q ≤ C·E_P is a linear matrix inequality, and minimizing b·C subject to reversibility constraints on Q is an SDP.

**Domain Bridges**: Probability theory ↔ Optimization (SDP) ↔ Computer science (algorithm design) ↔ Machine learning (automated hyperparameter tuning)

**Lineage**: Algorithmic extension of the verified comparison framework

**Ambition**: 🟡 Solid extension with potential for paradigm shift

**The key insight is** that the comparison theorem converts the spectral gap computation problem into a *certification* problem: instead of computing λ(P) directly, we search for a certificate (Q, b, C) that proves a lower bound.

**Why now?** SDP solvers are mature, the comparison theorem provides the mathematical foundation, and the growing importance of MCMC in machine learning creates practical demand for automated mixing certificates.
