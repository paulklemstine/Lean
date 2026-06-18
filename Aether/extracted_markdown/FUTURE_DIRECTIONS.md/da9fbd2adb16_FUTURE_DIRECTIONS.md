# Future Directions: Submodularity and Valuated Matroid Structure for Tropical Witnesses

## Synthesis

The results in this cycle establish that the log-determinant of a PSD kernel is submodular (equivalently, principal minors are multiplicatively submodular via the Hadamard–Fischer inequality), but the valuated matroid exchange axiom fails systematically. This creates a precise scientific boundary: determinantal diversity lives in the world of submodular optimization but does not enter the more structured world of valuated matroids. The five directions below explore both sides of this boundary — strengthening the submodular results toward algorithmic applications, investigating modified weight functions that might satisfy exchange, and connecting to neighboring fields (information theory, statistical physics, Hodge theory) where the same structural questions arise.

---

## Direction 1: Schur Complement Infrastructure and Formal Hadamard–Fischer

**Conjecture:** The Hadamard–Fischer inequality (det K[A] · det K[B] ≥ det K[A∩B] · det K[A∪B] for PSD K) can be formally proved in Lean 4 using a Schur complement determinant formula and projection monotonicity.

**Test:** 
1. Formalize the Schur complement determinant formula: det K[S∪{e}] = det K[S] · (K_{ee} - K_{e,S} K[S]⁻¹ K_{S,e}) when det K[S] > 0.
2. Prove that the Schur complement decreases as S grows: A ⊆ B implies K_{e,A} K[A]⁻¹ K_{A,e} ≤ K_{e,B} K[B]⁻¹ K_{B,e} (projection monotonicity).
3. Handle the degenerate case det K[S] = 0 via a rank argument: det K[B] = 0 implies det K[B∪{e}] = 0 for PSD K.
4. Combine to prove the full inequality by reduction to diminishing returns.

**Impact:** Completes the formal proof chain from PSD matrices to submodular optimization. This would be the first machine-verified proof of the Hadamard–Fischer inequality and would establish reusable Schur complement infrastructure in Lean/Mathlib.

**Catalog References:** 
- `Pythagorean/TropicalLeafWitnesses/SubmodularValuated.lean` — `principalMinor_mul_submodular` (currently `sorry`)
- `Speculative/AutoResearch/DPPLorentzian.lean` — `DPPKernel`, `psd_principal_minor_nonneg`

**Proof Strategy:** Decompose into 3 helper lemmas: (1) Schur complement det formula, (2) projection monotonicity via K = M^T M factorization, (3) rank-zero propagation. Each is independently testable.

**Domain Bridges:** Linear algebra ↔ Discrete optimization, Numerical analysis ↔ Formal verification

**Lineage:** Builds directly on `principalMinor_nonneg`, `log_submodular_of_mul_submodular`

**Ambition:** Solid extension — foundational infrastructure

---

## Direction 2: Modified Weights for Valuated Matroid Exchange

**Conjecture:** While log-det fails the valuated exchange axiom, the *rank function* of the column space of a Gram factor (i.e., rank(M_S) for K = M^T M) IS a valuated matroid weight (specifically, it defines the ordinary matroid of M, and the constant weight function trivially satisfies exchange).

More ambitiously: there exists a modification of log-det that satisfies exchange. **Candidate: log-det restricted to bases of the linear matroid of K**, or a "regularized" version W(S) = log det K[S] + c·|S| for appropriate c.

**Test:** 
1. For random PSD kernels K of rank r on [n], compute W(S) = log det K[S] restricted to all r-element subsets (the bases of the matroid).
2. Check the valuated matroid exchange axiom on these bases.
3. If violations persist, try W(S) = log det K[S] + c·|S| and scan over c ∈ {0, 0.1, ..., 5}.

**Impact:** If a natural modification satisfies exchange, it would establish a genuine valuated matroid structure for determinantal diversity, enabling exchange-based algorithms (augmenting paths, basis exchange walks) for DPP optimization.

**Catalog References:**
- `Pythagorean/TropicalLeafWitnesses/SubmodularValuated.lean` — `IsValuatedWitness`
- `Pythagorean/TropicalLeafWitnesses/Defs.lean` — `dppTropicalLeafWitness`

**Proof Strategy:** Computational search first, then formalize any positive findings.

**Domain Bridges:** Matroid theory ↔ DPP sampling, Tropical geometry ↔ Combinatorial optimization

**Lineage:** Builds on the exchange axiom failure discovered in this cycle

**Ambition:** Grand challenge — potentially paradigm-shifting if successful

---

## Direction 3: Lorentzian Polynomial Submodularity via Hodge Theory

**Conjecture:** The submodularity of log-det is a special case of a more general phenomenon: for any *Lorentzian polynomial* p (in the sense of Brändén–Huh), the coefficient support function val(p, S) = log(coefficient of x^S in p) is submodular.

**The key insight is** that Lorentzian polynomials are characterized by the property that all iterated second derivatives have at most one positive eigenvalue in their Hessian. This "one-positive-eigenvalue" condition is a Hodge-theoretic signature of negative dependence, and submodularity should follow from the same spectral constraint that governs the Hessian.

**Why now?** The Brändén–Huh theory of Lorentzian polynomials (2020) provides the algebraic framework. Our formalization of submodularity definitions and the diminishing returns equivalence provides the optimization framework. Connecting them requires proving that the Hessian condition implies submodularity of coefficients.

**Test:** 
1. Generate random Lorentzian polynomials (products of linear forms with nonneg coefficients).
2. Compute the coefficient map and check submodularity.
3. Test non-Lorentzian polynomials with nonneg coefficients to see if submodularity fails.

**Impact:** Would establish a universal principle: "Lorentzian ⟹ submodular coefficients." This would unify the Hadamard–Fischer inequality (for DPP polynomials) with the Mason conjecture (for matroid basis generating polynomials) under a single framework.

**Catalog References:**
- `Speculative/AutoResearch/DPPLorentzian.lean` — `IsDPPLorentzian`, `dpp_partition_function_lorentzian`
- `Pythagorean/TropicalLeafWitnesses/SubmodularValuated.lean` — `IsWitnessSubmodular`

**Proof Strategy:** Reduce to the Hessian characterization of Lorentzian polynomials. Use the one-positive-eigenvalue condition to show that mixed partial derivatives satisfy the Cauchy-Schwarz-like inequalities needed for submodularity.

**Domain Bridges:** Algebraic geometry (Hodge theory) ↔ Discrete optimization (submodularity), Combinatorics (matroids) ↔ Analysis (spectral theory)

**Lineage:** Extends `dpp_partition_function_lorentzian` (currently conjectural) into the submodular world

**Ambition:** Grand challenge — would unify major threads in algebraic combinatorics

---

## Direction 4: Entropy and Free Energy Analogues

**Conjecture:** The submodularity of log-det has an information-theoretic interpretation: for a Gaussian random vector X with covariance K, the differential entropy h(X_S) = (|S|/2)log(2πe) + (1/2)log det K[S] is submodular. This is exactly the *strong subadditivity of entropy* applied to Gaussian distributions.

**The key insight is** that our Hadamard–Fischer inequality, when specialized to the Gaussian case, is equivalent to strong subadditivity of entropy — one of the deepest inequalities in quantum information theory (proved by Lieb & Ruskai, 1973). The connection is: submodularity of log-det = strong subadditivity of Gaussian entropy.

**Why now?** The formal infrastructure for submodularity (definitions, equivalences, checker) is in place. Connecting to information theory requires only the translation between log-det and Gaussian entropy, which is a straightforward affine transformation.

**Test:**
1. Formalize Gaussian entropy as h(X_S) = (|S|/2)log(2πe) + (1/2)log det K[S].
2. Show that submodularity of log-det implies submodularity of h (by affine invariance of submodularity).
3. State the connection to strong subadditivity explicitly.

**Impact:** Bridges DPP theory to quantum information theory and statistical mechanics. Would provide formal proofs of entropy inequalities relevant to channel capacity bounds and quantum error correction.

**Catalog References:**
- `Pythagorean/TropicalLeafWitnesses/SubmodularValuated.lean` — `log_principalMinor_submodular`

**Proof Strategy:** Define Gaussian entropy, prove affine invariance of submodularity (f submodular implies c·f + g(|·|) submodular for any function g of cardinality), instantiate.

**Domain Bridges:** Discrete optimization ↔ Information theory ↔ Quantum physics

**Lineage:** Builds on `log_submodular_of_mul_submodular`

**Ambition:** Solid extension with high interdisciplinary impact

---

## Direction 5: Algorithmic Consequences for DPP Sampling

**Conjecture:** The submodularity of log-det enables a provably efficient DPP MAP (Maximum A Posteriori) inference algorithm: finding the mode of a k-DPP (the k-element subset maximizing det K[S]) can be (1-1/e)-approximated by the greedy algorithm in O(nk³) time.

**The key insight is** that log-det is monotone and submodular for kernels with positive diagonal (which includes all strictly PD kernels and all DPP kernels arising from quality-diversity decompositions). The classical Nemhauser-Wolsey-Fisher theorem then immediately yields the approximation guarantee.

**Why now?** Our formal proof of the greedy two-step bound (`greedy_two_step_bound`) is the exact mathematical content needed for the NWF theorem. Formalizing the full approximation bound requires only a counting argument and the greedy bound applied k times.

**Test:**
1. Formalize the (1-1/e) approximation theorem for monotone submodular maximization under a cardinality constraint.
2. Instantiate with log-det and a DPP kernel.
3. Run computational experiments comparing greedy vs brute-force optimal for n = 5, 6, 7 and k = 2, 3.

**Impact:** Provides the first machine-verified approximation guarantee for DPP MAP inference. This has direct applications in machine learning (diverse subset selection, summarization, recommendation systems).

**Catalog References:**
- `Pythagorean/TropicalLeafWitnesses/SubmodularValuated.lean` — `greedy_two_step_bound`, `submodular_iff_diminishing_returns`
- `Speculative/AutoResearch/DPPLorentzian.lean` — `DPPKernel`

**Proof Strategy:** Prove by induction on k: at step i, the greedy gain is at least (OPT - current)/k (by diminishing returns). Summing gives the (1-1/e) bound.

**Domain Bridges:** Discrete optimization ↔ Machine learning ↔ Algorithm design

**Lineage:** Builds on `greedy_two_step_bound` and `submodular_iff_diminishing_returns`

**Ambition:** Solid extension — directly applicable to DPP-based ML systems
