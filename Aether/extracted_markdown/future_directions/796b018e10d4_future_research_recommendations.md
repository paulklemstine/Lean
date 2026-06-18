# MetaFactoring: Recommended Future Research Directions

## A Prioritized Roadmap Based on Formally Verified Foundations

---

**Date:** April 2026

---

## Executive Summary

Based on our formal investigation of the MetaFactoring open questions — yielding 24 new machine-verified theorems — we identify the most promising research directions, ranked by a composite score of feasibility, impact, and novelty. We provide concrete next steps for each direction and estimate resource requirements.

---

## 1. Immediate Opportunities (0–12 months)

### 1.1 Experimental Correlation Matrix [Priority: ★★★★★]

**Goal:** Measure pairwise correlations between the seven lenses empirically.

**Why now:** Our formalization proves the theoretical framework (generalized_lens_advantage, lens_monotonicity), but the key unknown is the effective base β. A large-scale computational experiment would resolve this.

**Protocol:**
1. Generate 10⁶ random semiprimes at each bit size {32, 48, 64, 80, 96, 128}
2. For each semiprime, run each lens independently and record: (a) step count to factor, (b) constraint set size at each step
3. Compute pairwise Spearman correlations between lens step counts
4. Fit β = 2(1 − ρ_avg) and compare predicted vs. actual combined performance

**Expected outcome:** β ≈ 1.8–1.95 (near-independence), confirming the 128× theoretical advantage is achievable.

**Resources:** 1 researcher, 1 GPU cluster, 3 months.

### 1.2 Pisano-Spectral Computational Survey [Priority: ★★★★☆]

**Goal:** Compute π(p) and Δ(p) for all primes p < 10⁸ and search for algebraic relationships.

**Why now:** Our unified Pisano theorem (p | F(p²−1)) suggests deeper structure. The periodic reduction theorem enables efficient computation.

**Protocol:**
1. Compute π(p) for all p < 10⁸ using matrix exponentiation mod p
2. Compute spectral gap Δ(p) of the Cayley graph of (ℤ/pℤ)* with generators {±1, ±2}
3. Fit regression models: π(p) ~ f(Δ(p), p mod k) for various k
4. Test for correlations within arithmetic progressions p ≡ a (mod q)

**Expected outcome:** Either a conjectural relationship or strong evidence for independence.

**Resources:** 1 researcher, compute time for 10⁸ primes, 4 months.

### 1.3 Norm Channel Optimizer [Priority: ★★★★☆]

**Goal:** Heuristic for selecting optimal norm dimension (2, 4, or 8) based on N.

**Why now:** Our theorems prove the subsumption chain (dim2 ⊆ dim4 ⊆ dim8) and the Hurwitz barrier at dim16.

**Approach:**
1. For each N, compute the number of representations r₂(N), r₄(N), r₈(N)
2. Measure factoring success rates for each dimension
3. Build a classifier: given N mod (small primes), predict which dimension yields factors fastest

**Key insight from our formalization:** The norm-congruence bridge (p ≡ 3 mod 4 implies p | a,b if p | a²+b²) means the dim-2 channel *cannot* work for numbers whose factors are all ≡ 3 (mod 4). In such cases, dim-4 or dim-8 is necessary.

---

## 2. Medium-Term Research (1–3 years)

### 2.1 Quaternionic Factoring Algorithm [Priority: ★★★★☆]

**Goal:** Develop an algorithm exploiting quaternion non-commutativity.

**Rationale:** Our quaternion_two_factorizations theorem shows that q₁·q₂ and q₂·q₁ have different components but identical norms. This gives two factoring equations for the price of one quaternion multiplication.

**Approach:**
1. Represent N as a quaternion norm: N = a²+b²+c²+d² (always possible by Lagrange)
2. Find *two distinct* 4-square representations of N
3. Use the Brahmagupta-like identity to extract factor candidates
4. Exploit non-commutativity to generate additional GCD candidates

**Expected impact:** O(N^(1/4)) speedup over single-representation methods.

### 2.2 MetaDLP: Multi-Lens Discrete Logarithm [Priority: ★★★★☆]

**Goal:** Adapt the MetaFactoring framework to the discrete logarithm problem.

**Rationale:** Our dlp_order_connection and pohlig_hellman_structure theorems show the structural parallel: both factoring and DLP reduce to period-finding.

**Research questions:**
1. What are the natural "lenses" for DLP? (Index calculus, Pohlig-Hellman, baby-step/giant-step, ρ-method, function field methods)
2. Do they provide independent constraints on the discrete log?
3. Can the Fibonacci lens transfer to DLP via the multiplicative group structure?

### 2.3 Tropical MetaFactoring Lens [Priority: ★★★☆☆]

**Goal:** Formalize tropical geometry constraints on factorizations.

**Rationale:** Tropical geometry replaces (×, +) with (+, min), creating a "shadow" of algebraic geometry that is combinatorially tractable. The tropical variety of xy = N encodes factor pair structure.

**First step:** Formalize the tropical semifield in Lean 4 and prove that tropical polynomial evaluation preserves factor structure.

### 2.4 Hybrid Quantum-Classical Protocol [Priority: ★★★☆☆]

**Goal:** Design a concrete protocol where classical MetaFactoring preprocessing minimizes quantum circuit depth.

**Rationale:** Our hybrid_speedup theorem proves √(S/2^k) ≤ √S. For practical quantum computers with limited coherence time, reducing the number of quantum iterations by 11× (7 lenses) could make the difference between feasible and infeasible.

**Protocol design:**
1. Classical phase: run 7 MetaFactoring lenses to reduce search space
2. Quantum phase: use Grover/quantum walk on the reduced space
3. Endgame: classical congruence-of-squares extraction

---

## 3. Long-Term Vision (3–10 years)

### 3.1 MetaFactoring Complexity Class [Priority: ★★★☆☆]

**Goal:** Define a complexity class MFACT(k) capturing problems solvable by k independent constraint lenses, each removing fraction r of candidates.

**Questions:**
- Is MFACT(k) ⊂ MFACT(k+1) strictly?
- How does MFACT(∞) relate to P, BPP, BQP?
- Can we prove separation results?

### 3.2 Sedenion Weak Identities [Priority: ★★☆☆☆]

**Goal:** Investigate whether the flexible algebra structure of 16-dimensional sedenions provides factoring constraints despite the Hurwitz barrier.

**Key observation:** Our no_16_square_naive_identity theorem rules out *bilinear* composition identities, but *trilinear* or higher-order identities may exist and provide weaker but still useful constraints.

### 3.3 p-adic MetaFactoring [Priority: ★★☆☆☆]

**Goal:** Use p-adic analysis to define a new factoring lens.

**Idea:** The p-adic valuation v_p(N) determines how divisible N is by p. Hensel's lemma allows "lifting" modular solutions to higher precision, providing a natural lens for iterative refinement.

### 3.4 Automated Lens Discovery [Priority: ★★☆☆☆]

**Goal:** Use machine learning to discover new factoring lenses automatically.

**Approach:**
1. Train a neural network to predict factor structure from various number-theoretic features
2. Identify which features provide independent information
3. Formalize the resulting constraints in Lean 4

---

## 4. Applications Portfolio

### 4.1 Cryptographic Applications
- **Key validation:** Test RSA keys against all 7 lenses simultaneously
- **Parameter selection:** Choose cryptographic parameters that resist multi-lens attacks
- **Post-quantum preparation:** Quantify the hybrid classical-quantum threat

### 4.2 Pure Mathematics
- **Pisano period theory:** The unified p²−1 theorem opens investigation into higher-order Pisano divisibility (p³−p, p⁴−p², ...)
- **Representation theory:** Connect norm channel dimensions to Lie group representations
- **Algebraic number theory:** Extend the norm-congruence bridge to general number fields

### 4.3 Computer Science
- **Algorithm design:** Multi-lens constraint satisfaction as a general paradigm
- **Formal verification:** The MetaFactoring library as a benchmark for proof assistants
- **Quantum algorithm design:** Hybrid classical-quantum protocols

### 4.4 Educational Applications
- **Interactive exploration:** Python demos + Lean proofs for teaching number theory
- **Verified textbook:** A machine-checked introduction to computational number theory
- **Research training:** Formal verification as a research methodology

---

## 5. Resource Estimates

| Direction | Researchers | Time | Compute | Priority |
|-----------|-------------|------|---------|----------|
| Correlation matrix | 1 | 3 mo | GPU cluster | ★★★★★ |
| Pisano-spectral survey | 1 | 4 mo | Medium | ★★★★☆ |
| Norm channel optimizer | 1 | 3 mo | Low | ★★★★☆ |
| Quaternionic algorithm | 2 | 12 mo | Medium | ★★★★☆ |
| MetaDLP | 2 | 18 mo | High | ★★★★☆ |
| Tropical lens | 1 | 12 mo | Low | ★★★☆☆ |
| Hybrid quantum protocol | 2 | 18 mo | Quantum access | ★★★☆☆ |
| Complexity class | 1 | 24 mo | Low | ★★★☆☆ |
| Sedenion identities | 1 | 12 mo | Low | ★★☆☆☆ |
| p-adic lens | 1 | 12 mo | Low | ★★☆☆☆ |
| Automated discovery | 2 | 24 mo | GPU cluster | ★★☆☆☆ |

---

## 6. Conclusion

The MetaFactoring program has reached a critical juncture: the theoretical foundations are now formally established, and the next phase must be experimental. The correlation matrix experiment (§1.1) is the single highest-priority item — it will definitively validate or refine the framework's central claim. The quaternionic factoring algorithm (§2.1) and MetaDLP (§2.2) represent the most exciting theoretical extensions. And the hybrid quantum-classical protocol (§2.4) may have practical cryptographic significance as quantum hardware matures.

All future theoretical work should continue the formalization-first methodology: state results in Lean 4, prove them mechanically, and build on verified foundations. The 55+ theorems proved so far provide a solid platform for the next decade of research.
