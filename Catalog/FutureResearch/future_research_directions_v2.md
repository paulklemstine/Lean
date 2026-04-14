# Gravitational Factoring: Future Research Directions v2

## Recommended Priorities, Organized by Feasibility and Impact

---

## Executive Summary

We classify 50 research directions into four tiers based on feasibility (can we do it with current tools?) and impact (how transformative would success be?). The top priorities combine high feasibility with high impact.

---

## Tier A: High Feasibility, High Impact — Do These First

### A1. Large-Scale Peel Smoothness Experiments (Direction 1/44)
**Goal**: Measure smoothness rates of peel products vs. random integers for N up to 10²⁰.

**Method**: 
- Use ECM (Elliptic Curve Method) for efficient smoothness testing
- Generate peel products from Berggren tree navigation
- Compare with QS polynomial evaluation
- Measure the "smoothness advantage ratio" as a function of d and B

**Expected outcome**: Quantify the constant-factor advantage of gravitational sieving.

**Resources**: 1 researcher, 1-2 months, access to a cluster.

**Formally verified prerequisites**: `peel_is_diff_of_squares`, `peel_factor_size_bound`, `peel_smooth_of_factors_smooth` ✓

---

### A2. High-Dimensional LLL on Factoring Lattices (Direction 2)
**Goal**: Implement LLL on explicit factoring lattices for N up to 10²⁰, measure runtimes and success rates.

**Method**:
- Construct lattice L = {v ∈ ℤⁿ : v · t ≡ 0 (mod N)} for various target vectors t
- Run fpLLL (fast production LLL) in dimensions n = 10, 20, 50, 100, ⌈log₂ N⌉
- For each short vector, compute gcd(vᵢ, N) for all coordinates
- Track success probability and runtime as functions of n and N

**Expected outcome**: Either validate or refute the polynomial-time conjecture for this specific lattice family.

**Resources**: 1-2 researchers, 3-6 months, fpLLL library access.

**Formally verified prerequisites**: `lattice_factor_extraction`, `lattice_gcd_invariant`, `lattice_mod_factor` ✓

**Risk assessment**: HIGH RISK, HIGH REWARD. If LLL succeeds, this is polynomial-time factoring. If it fails, we learn fundamental limitations of lattice approaches.

---

### A3. Cross-Collision Independence Proof (Direction 3)
**Goal**: Prove rigorously that cross-collision legs are sufficiently independent for the Ω(k²/√N) bound.

**Method**:
- Analyze the correlation structure of Pythagorean tuple legs
- The constraint Σxᵢ² = d² induces correlations
- Show that these correlations are negligible compared to the independence assumption
- Alternatively, prove a slightly weaker bound that accounts for correlations

**Expected outcome**: A formal Lean 4 proof of the collision probability bound.

**Resources**: 1 researcher (number theorist), 2-4 months.

**Formally verified prerequisites**: `cross_collision_pair_count`, `pair_channels_concrete`, `lattice_mod_factor` ✓

---

### A4. Jacobi r₄ Formula Formalization (Direction 9)
**Goal**: Formalize r₄(n) = 8σ₁(n) for odd n in Lean 4.

**Method**:
- Build on the verified σ₁ multiplicativity
- Use theta functions and modular forms if Mathlib support exists
- Alternatively, use Hurwitz's quaternion-theoretic proof
- May require developing new Mathlib infrastructure for modular forms of weight 2

**Expected outcome**: A formally verified proof of Jacobi's 1829 result.

**Resources**: 1 researcher (formal methods + number theory), 3-6 months.

**Formally verified prerequisites**: `sigma1_prime`, `sigma1_multiplicative`, `sigma1_lower_bound`, `r4_lower_bound` ✓

---

## Tier B: Medium Feasibility, High Impact — Invest Strategically

### B1. Hurwitz Quaternion Euclidean Algorithm (Direction 5)
**Goal**: Formalize Hurwitz integers as a Euclidean domain and implement the factoring algorithm.

**Steps**:
1. Define Hurwitz integers H = ℤ[i, j, k, ½(1+i+j+k)]
2. Prove H is a principal ideal domain
3. Prove H has a Euclidean function (the norm)
4. Implement and verify the Euclidean algorithm
5. Prove: if N(Q) = N and Q = Q₁ · Q₂ in H, then N(Q₁) | N

**Resources**: 1-2 researchers, 4-8 months.

---

### B2. GF(2) Code Parameter Analysis (Direction 47)
**Goal**: Determine the minimum distance, rate, and dual distance of the binary code formed by smooth peel product exponent vectors.

**Method**:
- Generate large samples of smooth peel products
- Compute GF(2) exponent vectors over various factor bases
- Analyze the code's weight distribution using MacWilliams identity
- Compare with codes from QS/GNFS

**Resources**: 1 researcher (coding theory), 2-3 months.

**Formally verified prerequisites**: `smooth_relations_needed`, `null_vector_exists` ✓

---

### B3. Berggren Tree Modular Period Formula (Direction 8)
**Goal**: Derive an exact formula for the number of Berggren-reachable triples mod p.

**Method**:
- Enumerate computationally for primes p ≤ 1000
- Look for patterns relating the count to p, p², p²−1, |SL₂(𝔽_p)|
- Prove the formula using representation theory of SL₂(𝔽_p)

**Resources**: 1 researcher, 2-3 months.

**Formally verified prerequisites**: `berggren_mod_preserves` ✓

---

### B4. Multi-Scale Factoring (Direction 50)
**Goal**: Implement and test a hierarchical factoring algorithm using k = 2, 4, 8 simultaneously.

**Method**:
- k = 2 layer: rapid screening, generates candidate modular residues
- k = 4 layer: uses k = 2 information to focus quaternion search
- k = 8 layer: deep search guided by k = 4 near-misses
- Information flows upward via shared modular constraints

**Resources**: 1-2 researchers, 3-4 months.

---

## Tier C: Exploratory — High Risk, Potentially Transformative

### C1. Quantum Walk on Berggren Tree (Direction 43)
**Goal**: Design and analyze a quantum walk on the Berggren tree, comparing hitting time to classical random walk.

**Open question**: Does the tree structure provide better-than-quadratic speedup?

### C2. Persistent Homology of Energy Landscape (Direction 42)
**Goal**: Compute persistence diagrams for the factoring energy sublevel sets.

**Open question**: Are barrier heights O(polylog N)?

### C3. Adelic Unification (Direction 41)
**Goal**: Formalize the adelic perspective on factoring, showing how p-adic projections unify cross-collision information.

### C4. Galois-Theoretic Obstructions (Direction 46)
**Goal**: Determine whether étale cohomological obstructions explain the computational hardness of factoring.

### C5. Tropical Factoring Geometry (Direction 11)
**Goal**: Study the tropical Pythagorean variety and determine whether tropical methods yield efficient factoring algorithms.

---

## Tier D: Long-Term Vision — Foundation for Future Breakthroughs

### D1. Proof Complexity of Factoring (Direction 49)
### D2. Neuromorphic Factoring Hardware (Application 29)
### D3. Octonion-Based Cryptography (Application from Division Algebras)
### D4. Category-Theoretic Framework for Factoring Channels
### D5. Machine Learning for Berggren Tree Navigation (Direction 14)

---

## Recommended Team Structure

### Phase 1: Foundation (Months 1-6)
| Role | Person | Primary Directions |
|------|--------|--------------------|
| Lead / Number Theorist | 1 | A1, A3, B3 |
| Formal Methods (Lean) | 1 | A4, B1, A3 |
| Algorithm Designer | 1 | A2, B4 |
| Computational Scientist | 1 | A1, A2, B2 |

### Phase 2: Expansion (Months 7-12)
Add:
| Quantum Computing | 1 | C1 |
| Topologist/Geometer | 1 | C2, C3 |

### Phase 3: Scale (Months 13-24)
Add:
| ML Researcher | 1 | D5, B4 |
| Systems Engineer | 1 | GPU/cluster scaling |

---

## Key Metrics for Success

1. **Smoothness ratio**: Does the peel advantage exceed 10× at scale?
2. **LLL success rate**: What fraction of factoring lattices yield short factor-revealing vectors?
3. **Formal theorem count**: Target 50+ verified theorems by month 6, 100+ by month 12.
4. **Number size**: Factor numbers up to 10²⁰ (67 bits) by month 6, 10⁴⁰ (133 bits) by month 12.
5. **Publication**: Submit to Journal of the ACM (algorithms), Annals of Mathematics (formal proofs), or Nature (if polynomial-time result achieved).

---

## Risk Analysis

| Direction | Probability of Success | Impact if Successful |
|-----------|:---------------------:|:-------------------:|
| A1: Peel smoothness | 90% | Medium |
| A2: Lattice-GCD | 10-20% | Revolutionary |
| A3: Independence proof | 60% | High |
| A4: Jacobi formalization | 70% | Medium-High |
| B1: Hurwitz formalization | 50% | Medium |
| B2: Code parameters | 80% | Medium |
| C1: Quantum walk | 30% | High |
| C2: Persistent homology | 40% | Medium-High |

---

## Budget Estimate (Academic Setting)

| Item | Annual Cost |
|------|------------|
| 4 PhD students / postdocs | $280K |
| Computing resources (cluster time) | $50K |
| Travel (conferences) | $20K |
| Software licenses | $5K |
| **Total** | **$355K** |

This is modest compared to the potential impact. A single positive result on Direction A2 would justify orders-of-magnitude more investment.

---

## Conclusion

The gravitational factoring program has reached a critical juncture. The foundational theory is established (35+ verified theorems), the computational infrastructure is operational, and the key open questions are precisely identified. The next 12 months will determine whether the framework achieves its most ambitious goals — or reveals fundamental limits that are themselves deeply interesting.

The research community should:
1. **Prioritize A2 (Lattice-GCD)** — the polynomial-time possibility is too important to ignore
2. **Validate A1 (Smoothness)** — the easiest win with immediate practical applications
3. **Formalize A4 (Jacobi)** — builds mathematical infrastructure with lasting value
4. **Explore C1-C5 cautiously** — high risk but potentially transformative

Whether gravitational factoring breaks RSA or not, the geometric perspective on factoring will enrich our understanding of one of mathematics' oldest and most important problems.

---

*This document will be updated as results are obtained. Last updated: April 2026.*
