# Future Directions: Pairwise Intersection Energy and Dimension Bounds

## Conjecture 1: Energy-Dimension Bootstrap for Perron Trees

**Precise Statement.** For discretized planar Perron-tree configurations at scale δ, the pair energy satisfies P_δ ≍ δ^{-(2+α)} with α ∈ (0, 1), forcing the lower Minkowski dimension of the associated Besicovitch set to be at least 2 - α > 1.

**Test.** Generate increasingly fine discretizations (δ = 2^{-k}, k = 5,...,15) of a classical Perron-tree construction. Fit the exponent α from log-log regression of P_δ vs 1/δ. If α < 1 is observed consistently, the bound dim ≥ 2 - α > 1 follows from our Theorem B. Refute by exhibiting a Perron tree with α ≥ 1 (i.e., pair energy growing as fast as δ^{-3}).

**Impact.** If true, this would give a new, purely combinatorial proof that Besicovitch sets in ℝ² have Hausdorff dimension 2 — recovering Davies's classical theorem via incidence energy rather than projection arguments.

---

## Conjecture 2: Rényi Entropy Strengthening

**Precise Statement.** For random directional tube models (uniformly random tube centers, uniformly spaced directions), the Rényi-2 entropy lower bound H₂ ≥ log₂(I²/P) is asymptotically tight up to O(1) additive constants, while the support-size bound |Q| ≥ I²/P is loose by a polynomial factor.

**Test.** For each δ ∈ {0.1, 0.05, 0.025, 0.0125}, sample 100 random configurations. Compare the empirical Rényi-2 entropy to log₂(I²/P) and the empirical |Q| to I²/P. Compute the ratio (observed entropy)/(predicted entropy) and (observed |Q|)/(predicted |Q|). If the entropy ratio converges to 1 while the support ratio diverges, the conjecture holds. Refute by showing both ratios converge.

**Impact.** This would establish that information-theoretic (entropic) bounds are fundamentally stronger than counting bounds for directional incidence systems, opening a new direction in combinatorial geometry.

---

## Conjecture 3: Finite-Field Transfer

**Precise Statement.** Over F_q^n, let E be a Kakeya set (containing a line in every direction). Define the incidence relation I between points of E and lines, with pair energy P = Σ_{ℓ,ℓ'} |{x ∈ E : x ∈ ℓ ∧ x ∈ ℓ'}|. Then the graph-theoretic incidence lower bound yields |E| ≥ (|directions| · q)² / P, and for the Kakeya set one obtains |E| ≥ cq^n for an explicit constant c depending only on n.

**Test.** For q = 5, 7, 11, 13, 17, 19 and n = 2, 3, construct explicit Kakeya sets in F_q^n (e.g., via polynomial method). Compute the pair energy P and verify |E| ≥ (M·L)²/P. Check whether the predicted |E| ≥ cq^n matches the known Dvir bound |E| ≥ q^n / n!. Refute by showing the incidence bound gives |E| ≥ cq^{n-ε} for some ε > 0 that does not vanish as q → ∞.

**Impact.** If the combinatorial energy bound recovers (or improves upon) the Dvir bound, it would provide a unified formal framework for both Euclidean and finite-field Kakeya problems.

---

## Conjecture 4: Discretization Robustness

**Precise Statement.** If a tube configuration T_δ has pair energy P_δ, then any δ-perturbation of tube centers (shifting each tube center by at most Cδ) changes the pair energy by at most a multiplicative factor of (1 + C')^{n+1} for an absolute constant C' depending only on C and the ambient dimension n.

**Test.** For δ ∈ {0.1, 0.05, 0.025}, generate a fixed tube configuration, then create 50 random perturbations with perturbation magnitude Cδ for C ∈ {0.1, 0.5, 1.0, 2.0}. Measure the ratio P_perturbed/P_original. If the ratio is bounded by a function of C alone (independent of δ), the conjecture holds. Refute by exhibiting configurations where the ratio grows with 1/δ.

**Impact.** Robustness would guarantee that the dimension lower bounds are intrinsic to the geometric configuration, not artifacts of the discretization grid — essential for any application to real-world directional data.

---

## Conjecture 5: Tomographic Threshold

**Precise Statement.** In a sparse directional sensing model with M beams and N grid cells, the pair energy threshold P* = M²/N marks a phase transition: for P < P*, compressed sensing algorithms achieve exact support recovery with high probability; for P > P*, recovery fails for a positive fraction of sparse signals.

**Test.** Fix N = 400 grid cells, vary M from 10 to 100, and for each M construct beam configurations with pair energy P ranging from 0.1M²/N to 10M²/N. For each configuration, run ℓ₁-minimization on 200 random k-sparse signals (k = 5). Measure the recovery rate as a function of P/P*. If a sharp transition occurs near P/P* = 1, the conjecture holds. Refute by showing recovery rates vary smoothly without a threshold.

**Impact.** This would directly connect Kakeya-type combinatorial geometry to compressed sensing practice, providing a geometric criterion for optimal probe design in tomography, radar, and medical imaging.
