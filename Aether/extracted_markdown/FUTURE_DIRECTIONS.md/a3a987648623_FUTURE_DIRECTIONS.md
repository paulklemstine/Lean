# Future Research Directions

## Synthesis

This research cycle established the theory of asymptotically identity (AsympId) permutations as a rigorous framework for studying prime rearrangements. The central discovery is that AsympId permutations form a subgroup of the symmetric group S_ℕ, and that this subgroup is dense in the pointwise convergence topology. The log ratio lemma provides the bridge between the abstract permutation theory and concrete prime number asymptotics: via the Prime Number Theorem, AsympId permutations are exactly those that preserve the growth rate p_{σ(n)} ~ p_n.

The most promising cross-domain connections emerge from the interplay between the topological density of AsympId (it's a dense subgroup) and its measure-theoretic rarity (the density conjecture predicts measure zero among finite permutations). This mirrors phenomena in analysis (e.g., continuous nowhere-differentiable functions are generic in C[0,1] but seem "rare" intuitively) and could connect to descriptive set theory results about Polish groups. The subgroup structure also resonates with coarse geometry, where quasi-isometries preserve large-scale structure — AsympId permutations are precisely the "quasi-isometries of ℕ with multiplicative distortion 1."

The highest breakthrough potential lies in Direction 1 (normality of the AsympId subgroup), which would reveal the deeper algebraic structure of prime rearrangements, and Direction 2 (formalizing PNT in sufficient strength to close the prime corollary), which would complete the bridge from abstract permutation theory to concrete number theory.

---

### Direction 1: Normality and Conjugation Structure of the AsympId Subgroup

**Conjecture**: The AsympId subgroup G = {σ ∈ S_ℕ : σ(n)/n → 1} is NOT a normal subgroup of S_ℕ. Specifically, there exists an AsympId permutation σ and a non-AsympId permutation τ such that τ⁻¹στ is not AsympId.

**Test**: Construct explicit σ ∈ G and τ ∉ G with τ⁻¹στ ∉ G. A candidate: let σ be the adjacent swap (which is AsympId) and τ(n) = 2n (which is not even a bijection of ℕ, so we need τ to be a bijection that "stretches" — e.g., interleaving evens and odds: τ(2k) = k, τ(2k+1) = k + N for appropriate N). Compute (τ⁻¹στ)(n)/n for the first 10^5 values and check whether it converges to 1.

**Impact**: If G is not normal, its coset structure G\S_ℕ carries nontrivial information about "how far" a permutation is from preserving prime asymptotics. If G IS normal (surprising), the quotient S_ℕ/G would be a meaningful group measuring "asymptotic distortion types."

**Catalog References**: `Speculative/AutoResearch/HilbertHotelPrimes.lean` (asympId_comp, asympId_inv, asympId_subgroup_properties)

**Proof Strategy**: For the negative direction, construct τ that maps n to roughly n² (or some superlinear function) while remaining bijective. Then τ⁻¹στ(n) ≈ τ⁻¹(σ(n²)) ≈ τ⁻¹(n² + 1) ≈ √(n² + 1) which is not asymptotic to n. The key lemma is: if τ(n)/n → ∞, then for any non-identity σ, τ⁻¹στ cannot be AsympId. Formalize using Filter.Tendsto composition.

**Domain Bridges**: Permutation group theory <-> Coarse geometry (quasi-isometry classification) <-> Descriptive set theory (complexity of AsympId as a subset of S_ℕ)

**Lineage**: Builds on asympId_subgroup_properties and perm_tendsto_atTop from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Formal Prime Number Theorem Bridge

**Conjecture**: Given a formal statement of the Prime Number Theorem in the form π(x)/Li(x) → 1 (or equivalently p_n/(n log n) → 1), the prime rearrangement corollary p_{σ(n)}/p_n → 1 for AsympId σ follows in ≤ 50 lines of Lean 4.

**Test**: Assuming PNT as an axiom (or using any available formalization), prove the full prime corollary. Measure the proof length and identify which additional Mathlib lemmas are needed beyond what's in the current formalization.

**Impact**: Completes the full pipeline from the abstract AsympId theory to concrete prime number results. Would be one of the first formal proofs connecting permutation group structure to analytic number theory.

**Catalog References**: `Speculative/AutoResearch/HilbertHotelPrimes.lean` (log_ratio_tendsto_one, AsympId definition)

**Proof Strategy**: 
1. State PNT as: ∃ f : ℕ → ℝ with f(n) → 1 and p_n = n · log(n) · f(n). 
2. Then p_{σ(n)}/p_n = (σ(n)/n) · (log(σ(n))/log(n)) · (f(σ(n))/f(n)).
3. The first factor → 1 by AsympId. The second → 1 by log_ratio_tendsto_one. The third → 1 because f(m) → 1 and σ(n) → ∞.
4. All three limits are established; multiply.

**Domain Bridges**: Analytic number theory (PNT) <-> Topological group theory (AsympId subgroup) <-> Formal methods (Lean 4)

**Lineage**: Direct continuation of log_ratio_tendsto_one from this cycle.

**Ambition**: extension

---

### Direction 3: Density Conjecture and Combinatorial Asymptotics

**Conjecture**: Let D_N(ε) be the number of permutations σ of {1,...,N} with max_{1≤i≤N} |σ(i)/i - 1| < ε. Then for any fixed ε ∈ (0,1), log(D_N(ε))/log(N!) → 0 as N → ∞.

**Test**: Compute D_N(ε) exactly for small N (up to 12-15 using exhaustive enumeration) and estimate for larger N via Monte Carlo. Fit the growth rate of D_N(ε) — is it polynomial in N? Subexponential? Compare to permanent computations of restricted 0-1 matrices.

**Impact**: A precise growth rate for D_N(ε) would quantify the measure-theoretic rarity of AsympId permutations and connect to the theory of permanents and Latin squares. If D_N(ε) grows polynomially, it would show that AsympId permutations are "super-exponentially rare."

**Catalog References**: `Speculative/AutoResearch/HilbertHotelPrimes.lean` (density_conjecture_statement for informal context)

**Proof Strategy**: 
1. Show D_N(ε) ≤ ∏_{i=1}^{N} |{j : |j/i - 1| < ε}| = ∏_{i=1}^{N} (2εi + O(1)) by a crude union bound (ignoring bijectivity constraint).
2. This gives log D_N(ε) ≤ Σ log(2εi + O(1)) ~ N log(2εN), while log(N!) ~ N log N.
3. So log D_N(ε)/log(N!) ≤ (N log(2εN))/(N log N) = 1 + log(2ε)/log N → 1. This bound is too weak.
4. Better approach: use the bijectivity constraint. Model as counting permutation matrices inside a band. Use results from the permanent of band matrices.

**Domain Bridges**: Combinatorics (permutation enumeration) <-> Linear algebra (permanents) <-> Probability (random permutation theory)

**Lineage**: Builds on density_conjecture_statement and computational experiments from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Regularly Varying Sequences and General AsympId Theory

**Conjecture**: For any regularly varying sequence a_n = n^α · L(n) where L is slowly varying and α > 0, we have a_{σ(n)}/a_n → 1 for all AsympId permutations σ if and only if α > 0. When α = 0 (i.e., a_n = L(n) is slowly varying), there exist AsympId permutations σ with a_{σ(n)}/a_n ↛ 1.

**Test**: For a_n = n (α = 1): verify a_{σ(n)}/a_n = σ(n)/n → 1 (trivially true). For a_n = log(n) (α = 0, slowly varying): find an AsympId σ with log(σ(n))/log(n) ↛ 1. Candidate: σ that maps n to n + √n (approximately — need to make bijective), giving log(n + √n)/log(n) → 1. So perhaps slowly varying sequences ARE preserved. Test with a_n = log(log(n)).

**Impact**: Would generalize the prime rearrangement theory to a complete characterization of which sequences are "AsympId-stable," creating a classification theory analogous to Karamata's theory of regular variation.

**Catalog References**: `Speculative/AutoResearch/HilbertHotelPrimes.lean` (log_ratio_tendsto_one as the α = 0 case)

**Proof Strategy**: For regularly varying a_n = n^α · L(n) with α > 0: a_{σ(n)}/a_n = (σ(n)/n)^α · L(σ(n))/L(n). The first factor → 1^α = 1 by AsympId. For the second, use the uniform convergence theorem for slowly varying functions: L(λx)/L(x) → 1 uniformly in λ on compact subsets of (0,∞), and since σ(n)/n → 1, L(σ(n))/L(n) = L(n · σ(n)/n)/L(n) → 1.

**Domain Bridges**: Regular variation theory (Karamata) <-> Permutation group theory <-> Analytic number theory

**Lineage**: Generalizes log_ratio_tendsto_one from this cycle.

**Ambition**: extension

---

### Direction 5: Computational Complexity of AsympId Membership

**Conjecture**: The problem "Given a Turing machine M computing a bijection σ : ℕ → ℕ, does AsympId(σ) hold?" is Π₂⁰-complete (i.e., equivalent to a ∀∃ statement over ℕ in the arithmetical hierarchy).

**Test**: Show AsympId(σ) can be expressed as: ∀ε > 0, ∃N, ∀n ≥ N, |σ(n)/n - 1| < ε. This is manifestly Π₃⁰ (or Π₂⁰ if ε ranges over rationals). To show completeness, reduce a known Π₂⁰-complete problem to AsympId membership. Candidate: totality of a partial recursive function.

**Impact**: Would establish fundamental limits on what can be algorithmically determined about permutation asymptotics, connecting the algebraic theory of AsympId to computability theory.

**Catalog References**: `Computation/InfoEfficientAlgorithms.lean` for computability framework, `Speculative/AutoResearch/HilbertHotelPrimes.lean` for AsympId definition

**Proof Strategy**: 
1. Express AsympId as ∀q ∈ ℚ₊, ∃N ∈ ℕ, ∀n ≥ N, |σ(n) - n| < q·n. This is Π₂⁰ (the ∀q can be absorbed since ℚ₊ is countable).
2. For hardness, given a Π₂⁰ predicate P ≡ ∀m ∃k R(m,k), construct σ_P such that AsympId(σ_P) ↔ P. The construction: let σ_P(n) = n except at "signaling" positions determined by the enumeration of R.
3. Formalize in Lean 4 using Mathlib's computability library.

**Domain Bridges**: Computability theory (arithmetical hierarchy) <-> Permutation group theory <-> Descriptive set theory (Borel complexity)

**Lineage**: New direction inspired by the AsympId definition from this cycle, connecting to `Computation/` catalog entries.

**Ambition**: grand_challenge
