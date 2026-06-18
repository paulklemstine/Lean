# Future Directions: Tagged-Card TASEP and KPZ Universality in Permutation Walks

## Synthesis

The tagged-card TASEP framework established in this work reveals that permutation random walks on *S_n* driven by adjacent transpositions contain genuine exclusion-process structure at the observable level. Four rigorous theorems — drift decomposition, variance bound, inversion control, and the increment–inversion bridge — provide the foundational identities for a new interface between finite-group random walks, nonequilibrium statistical mechanics, and algebraic combinatorics. The directions below exploit this interface in five distinct ways, ranging from immediate extensions (exact conditional drift, martingale structure) to paradigm-shifting conjectures (KPZ universality, Bethe ansatz integrability). Each direction is designed to be independently testable and to create permanent bridges between domains that have developed largely in isolation.

---

## Direction 1: Exact Conditional Drift Formula and Hydrodynamic Limit

**Conjecture:** For the adjacent-transposition walk on *S_n*, the expected one-step displacement of tagged card *j* conditioned on state σ is:
```
E[Δ_j | X_t = σ] = (1/(n-1)) · (𝟙{σ⁻¹(j) + 1 < n} − 𝟙{σ⁻¹(j) > 0})
```
and in the hydrodynamic limit (*n* → ∞, *t* = ⌊α·n²⌋), the tagged-card position satisfies a deterministic law of large numbers with an explicitly computable velocity profile.

**Test:** Compute E[Δ_j | σ] exhaustively for *n* = 5, 6, 7. Verify the formula for all *n*! permutations. Then simulate the averaged drift for *n* = 50, 100, 200 at *t* = n² and check convergence of the rescaled position to the predicted deterministic trajectory.

**Impact:** This would provide the first exact hydrodynamic equation for a tagged particle in a permutation walk, directly analogous to the hydrodynamic limit of TASEP (Rost, 1981). It would establish the permutation walk as a legitimate model in the hydrodynamic scaling theory of interacting particle systems.

**Catalog References:** `Pythagorean/CayleyExpander/TaggedCardTASEP.lean` (taggedCard_drift_decomposition), `Pythagorean/CayleyExpander/MixingTime.lean` (variance decay).

**Proof Strategy:** Use taggedCard_drift_decomposition to compute the conditional drift as a function of σ⁻¹(j), then average over the invariant measure (uniform distribution) using symmetry.

**Domain Bridges:** Nonequilibrium statistical mechanics (hydrodynamic limits), probability theory (law of large numbers for Markov chains), spectral theory (mixing time controls equilibration rate).

**Lineage:** Extends Theorem 1 (drift decomposition) to a full conditional moment computation.

**Ambition:** Extension — solidifies the foundation for all subsequent scaling analyses.

---

## Direction 2: Martingale Structure and Central Limit Theorem

**Conjecture:** The compensated tagged current
```
M_j(t) = pos_j(X_t) − pos_j(X_0) − Σ_{s<t} E[Δ_j | X_s]
```
is a martingale with respect to the natural filtration, with predictable quadratic variation
```
⟨M_j⟩_t = Σ_{s<t} Var(Δ_j | X_s) = Σ_{s<t} (2/(n-1)) · 𝟙{σ⁻¹(j) ∉ {0, n-1}}/(n-1)
```
and M_j(t) / √t converges to a Gaussian distribution after appropriate rescaling.

**Test:** Simulate M_j(t) for *n* = 10, 20, 50 and verify: (1) E[M_j(t+1) − M_j(t) | X_t] = 0 empirically; (2) the QQ-plot of M_j(t)/√t against Gaussian is linear for *t* ≫ n².

**Impact:** This would provide the first rigorous martingale decomposition for a tagged observable in a permutation walk, establishing the structural analog of the Kipnis–Varadhan corrector theorem for interacting particle systems.

**Catalog References:** `Pythagorean/CayleyExpander/TaggedCardTASEP.lean` (all four theorems), `Pythagorean/CayleyExpander/MixingTime.lean` (variance decay under averaging).

**Proof Strategy:** Define M_j(t) formally in Lean using Finset sums. Prove the martingale property using taggedCard_drift_decomposition to compute conditional expectations. Use Theorem 2 (bounded increments) to apply the martingale CLT.

**Domain Bridges:** Probability theory (martingale theory, CLT), Markov chain theory (Kipnis–Varadhan theory), functional analysis (Poisson equation).

**Lineage:** Directly extends Direction 1 and Theorems 1–2.

**Ambition:** Extension — the critical structural step enabling all fluctuation analysis.

---

## Direction 3: KPZ Universality for the Tagged Current (Grand Challenge)

**Conjecture:** For the adjacent-transposition-plus-cycle walk on *S_n* (where the cycle provides asymmetric drift), the drift-corrected tagged current satisfies
```
n^{−1/3} · J_j(⌊α·n⌋) → F_{TW}
```
where F_{TW} is the Tracy–Widom GUE distribution, with the 1/3 fluctuation exponent characteristic of KPZ universality.

**Test:** Simulate the hybrid walk for *n* = 20, 50, 100, 200 with *t* = n. Compute the rescaled fluctuations n^{−1/3} · (pos_j(X_t) − v_n·t). Plot the empirical CDF against the Tracy–Widom CDF. Measure skewness (TW prediction: ≈ 0.29) and excess kurtosis (TW prediction: ≈ 0.17).

**Impact:** If true, this would be the first proof of KPZ universality for a walk on a finite group — a paradigm-shifting result that would unify permutation mixing theory with the deepest results in integrable probability and random matrix theory.

**Catalog References:** `Pythagorean/CayleyExpander/TaggedCardTASEP.lean` (all definitions and theorems), `Bridges/Catalog/Pythagorean/CayleyExpander/SymmetricGroup.lean` (generator structure).

**Proof Strategy:** Two possible routes: (A) Establish exact determinantal formulas for the transition probabilities using the representation theory of *S_n*, then take asymptotic limits using steepest descent; (B) Verify the conditions of the Quastel–Sarkar (2023) universality theorem for weakly asymmetric exclusion processes.

**Domain Bridges:** Integrable probability (Tracy–Widom, Airy process), random matrix theory (GUE edge scaling), algebraic combinatorics (RSK, Schur functions), nonequilibrium statistical mechanics (KPZ equation).

**Lineage:** Requires Directions 1 and 2 as prerequisites.

**Ambition:** Grand challenge — would create a new chapter in both permutation theory and KPZ universality.

---

## Direction 4: RSK Correspondence and Growth Model Interpretation

**Conjecture:** The tagged inversion count I_j(X_t), viewed as a function of *t*, is equivalent (in distribution) to the height function of a corner growth model with geometric weights determined by the permutation walk kernel. The RSK correspondence maps the time-evolution of inversions to the growth of Young diagrams, and the longest increasing subsequence of the walk trajectory determines the asymptotic shape.

**Test:** For *n* = 8, 10, 12, record the sequence of permutations (X_0, X_1, ..., X_T). Apply RSK to each permutation and track the shape of the insertion tableau. Compare the evolution of the first row length with the tagged inversion count trajectory. Test whether the correlation exceeds 0.5.

**Impact:** This would establish a direct, constructive connection between the tagged-card dynamics and the Robinson–Schensted–Knuth correspondence, providing a growth-model interpretation of permutation mixing that could yield exact formulas via the Schur function machinery.

**Catalog References:** `Pythagorean/CayleyExpander/TaggedCardTASEP.lean` (taggedInversionCount, taggedInversion_adjSwap_change_le_one, taggedIncrement_zero_preserves_inversions).

**Proof Strategy:** Use Theorem 4 (increment–inversion bridge) to decompose the inversion process into a martingale part and a predictable part. Relate the predictable part to the RSK shape evolution using the classical connection between inversions and the first row of the RSK insertion tableau.

**Domain Bridges:** Algebraic combinatorics (RSK, Young tableaux, Schur functions), random matrix theory (longest increasing subsequences), last-passage percolation (growth models).

**Lineage:** Extends Theorems 3 and 4 into the algebraic-combinatorial domain.

**Ambition:** Grand challenge — would create a new bridge between dynamic permutation theory and RSK combinatorics.

---

## Direction 5: Bethe Ansatz and Exact Solvability

**Conjecture:** The tagged-card transition matrix, restricted to the position of card *j*, can be diagonalized using the Bethe ansatz (nested or coordinate), and the eigenvalues have an explicit product formula involving trigonometric functions of the Bethe roots.

**Test:** For *n* = 4, 5, 6, compute the full transition matrix of the tagged-card Markov chain (marginal on card *j*'s position, averaging over all other cards). Diagonalize numerically and check whether eigenvalues match a Bethe ansatz prediction with k quantum numbers.

**Impact:** If the permutation walk's tagged-card marginal is Bethe-ansatz solvable, it would provide exact formulas for all moments of the tagged current, definitively settling the KPZ conjecture (Direction 3) and opening the door to exact asymptotic analysis.

**Catalog References:** `Pythagorean/CayleyExpander/TaggedCardTASEP.lean` (tagged-card definitions), `Bridges/Catalog/Pythagorean/CayleyExpander/SpectralGap.lean` (spectral infrastructure).

**Proof Strategy:** Embed the tagged-card marginal chain into a higher-dimensional integrable system using the Yang–Baxter equation. The generator set {adjacent transpositions} satisfies the braid relations, which is the algebraic prerequisite for Bethe ansatz solvability.

**Domain Bridges:** Integrable systems (Bethe ansatz, Yang–Baxter equation), representation theory (Hecke algebras, quantum groups), mathematical physics (XXX spin chain).

**Lineage:** Builds on all prior directions; requires spectral infrastructure from the existing Cayley expander catalog.

**Ambition:** Grand challenge — would establish the permutation walk as an exactly solvable model in the integrable systems hierarchy.
