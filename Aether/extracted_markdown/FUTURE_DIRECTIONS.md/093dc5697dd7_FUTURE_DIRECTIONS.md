# Future Research Directions

## Synthesis

This cycle introduced **Tropical Social Welfare Functions (TropSWF)** — max-plus linear maps parameterized by voter weight vectors — and proved the **Tropical Anti-Arrow Theorem**: for n ≥ 2 voters, no TropSWF is dictatorial, directly inverting Arrow's classical impossibility. The proof exploits the unboundedness of ℤ: any finite weight disadvantage can be overcome by sufficiently extreme input, preventing any voter from permanently dominating.

The most promising cross-domain connection is between the **weight gap** of a TropSWF and the **tropical spectral gap** from `TropicalLorentzianShadows`. Both are max-plus separation measures that scale linearly under weight rescaling (proved as `weightGap_scale`, mirroring `rescale_tropical_gap_linear`). This suggests a deeper structural correspondence between tropical optimization theory and tropical social choice, where spectral properties of tropical quadratic forms translate to influence properties of tropical welfare functions.

The highest breakthrough potential lies in **Direction 1 (Bounded Domain Transition)**: quantifying how Arrow's impossibility "emerges" from tropical possibility as the preference domain becomes bounded. This would unify the classical and tropical results into a single parameterized framework, with unboundedness as the control parameter. A proof would establish tropical mathematics as the natural algebraic language for social choice, with classical Arrow as a limiting case.

---

### Direction 1: Bounded Domain Transition — Emergence of Arrow from Tropical Possibility

**Conjecture**: For a unanimous TropSWF over the bounded domain {0, 1, ..., K}ⁿ with weight gap δ, the fraction of profiles where a non-support voter influences the outcome is Θ(min(1, K/δ)) as δ → ∞ with K fixed, and approaches 0 as δ/K → ∞. In the limit δ/K → ∞, the TropSWF becomes a near-dictator, recovering Arrow-like behavior.

**Test**: For n = 3, compute the fraction of profiles in {0,...,K}³ where voter 2 (with weight -δ) achieves the max of (x₁, x₂ - δ, x₃ - δ), for K ∈ {10, 100, 1000} and δ ∈ {1, 5, 10, 50, 100}. Plot the fraction vs δ/K and verify the predicted Θ(K/δ) scaling.

**Impact**: If true, this unifies Arrow's impossibility and tropical possibility into a single parameterized framework. The parameter δ/K controls the transition between democratic (tropical) and dictatorial (classical) regimes. This would be the first result showing Arrow's theorem as a limiting case of a more general algebraic theory.

**Catalog References**: `Speculative/TropicalSocialChoice.lean` (TropSWF structure, trop_anti_arrow), `Catalog/Pythagorean/TropicalLorentzianShadows.lean` (rescale_tropical_gap_linear)

**Proof Strategy**: Define a counting function over bounded profiles. Use combinatorial bounds on the fraction of profiles where a term w_i + x_i exceeds all others. The key step is bounding the volume of the region {x ∈ [0,K]ⁿ : w_i + x_i ≥ max_{j≠i}(w_j + x_j)} as a fraction of K^n. For the non-support voter i with w_i = -δ, this region has volume ≈ K^{n-1} · max(0, K - δ), giving fraction ≈ max(0, 1 - δ/K).

**Domain Bridges**: Tropical geometry ↔ Social choice theory ↔ Optimization

**Lineage**: Builds on `trop_anti_arrow` and `weightGap_scale` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Gibbard-Satterthwaite — Strategy-Proofness in Tropical Voting

**Conjecture**: A TropSWF f is *strategy-proof* (no voter can benefit by misreporting) iff all weights in the support are equal. The pure max function (all weights zero) is strategy-proof, but any TropSWF with unequal support weights admits manipulation.

More precisely: define manipulation as the existence of voter i, true preference x_i, and reported preference x_i' such that |f(x_i', x_{-i}) - x_i| < |f(x_i, x_{-i}) - x_i|. Conjecture: f is manipulation-free iff for all i, j in support(f), w_i = w_j.

**Test**: For n = 3, K = 10, enumerate all profiles and all possible misreports for TropSWFs with weights (0, 0, -1), (0, -1, -2), and (0, 0, 0). Count manipulation instances. The conjecture predicts manipulation exists for the first two but not the third.

**Impact**: This would be the tropical analog of the Gibbard-Satterthwaite theorem. If the conjecture holds, it identifies the egalitarian TropSWF as the unique strategy-proof tropical voting rule, paralleling the classical result that only dictatorial rules are strategy-proof.

**Catalog References**: `Speculative/TropicalSocialChoice.lean` (TropSWF.support, pureMax_unanimous)

**Proof Strategy**: For the "if" direction: when all support weights are equal (say 0) and all non-support weights are equal (say -δ), the function is f(x) = max(max_{i∈S} x_i, max_{j∉S}(x_j - δ)). Show that increasing x_i always weakly increases f(x), so reporting higher is never strictly beneficial. For the "only if" direction: find a concrete manipulation when support weights differ.

**Domain Bridges**: Game theory ↔ Tropical algebra ↔ Mechanism design

**Lineage**: Builds on `trop_pareto`, `support_of_unanimous` from this cycle.

**Ambition**: extension

---

### Direction 3: Tropical Social Choice over Ranked Alternatives — Ordinal Tropical Arrow

**Conjecture**: Define a *tropical preference aggregation rule* (TPAR) on m alternatives as a map F: (Sₘ)ⁿ → Sₘ (where Sₘ is the symmetric group, representing rankings) that can be "tropicalized" — i.e., factored through a max-plus linear map on the Borda scores. Conjecture: for m ≥ 3 and n ≥ 2, there exist non-dictatorial TPARs satisfying Pareto and a tropical analog of IIA, but only for specific structures of the factoring map.

**Test**: For m = 3, n = 3, enumerate all (3!)³ = 216 profile combinations. For each candidate weight vector, compute the TPAR outcome via max-plus aggregation of Borda scores. Check Pareto, IIA, and non-dictatorship. Find the weight vectors that satisfy all three.

**Impact**: This would extend tropical social choice from cardinal to ordinal settings, directly engaging with Arrow's original framework. A positive result would show that tropicalization resolves Arrow's impossibility even in the ordinal setting. A negative result would precisely identify which aspect of ordinal preferences reinstates impossibility.

**Catalog References**: `Speculative/TropicalSocialChoice.lean` (TropSWF, trop_anti_arrow), `Catalog/Algebra/ArrowCurvatureBridge/Arrow.lean`

**Proof Strategy**: Define Borda scores as a map from rankings to ℤ^m. Apply a TropSWF to each alternative's score vector independently. The key challenge is recovering a ranking from the max-plus aggregated scores while maintaining IIA. This likely requires a tropical analog of the "pairwise majority" construction.

**Domain Bridges**: Combinatorics (permutations) ↔ Tropical geometry ↔ Social choice theory

**Lineage**: Builds on `trop_anti_arrow` and `tropical_possibility` from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Category of TropSWFs and Tropical Representative Democracy

**Conjecture**: TropSWFs form a category where morphisms are "delegation maps" — assignments of voters to representatives that commute with evaluation. The composition of two TropSWFs (first aggregating within districts, then across districts) yields a TropSWF whose weight vector is the tropical matrix product of the two weight matrices.

More precisely: if F: ℤⁿ → ℤᵐ applies m district-level TropSWFs, and G: ℤᵐ → ℤ applies one national TropSWF, then G ∘ F is a TropSWF with weights w_i = max_j(g_j + f_{j,i}).

**Test**: For n = 6 voters, m = 2 districts (3 voters each), compute the composed TropSWF for various district weights and national weights. Verify the weight formula. Check whether the composed function preserves unanimity when both levels satisfy it.

**Impact**: This would provide an algebraic theory of representative democracy in the tropical setting. The tropical matrix product composition suggests that tropical representative democracy has a natural algebraic structure (a monad or a Kleisli category) that could be studied using categorical methods.

**Catalog References**: `Speculative/TropicalSocialChoice.lean` (TropSWF.eval, unanimity_iff), `Catalog/Bridges/AlgebraEMLClosureComputation.lean` (categorical structures)

**Proof Strategy**: Define the 2-level TropSWF composition explicitly. Show the weight formula by expanding the double max: max_j(g_j + max_i∈D_j(f_{j,i} + x_i)) = max_i(max_j(g_j + f_{j,i}) + x_i). The key step is exchanging the order of max operations (which is valid for finite sets). For unanimity preservation, use the unanimity characterization: max(composed weights) = max_i max_j(g_j + f_{j,i}) = 0 when both levels satisfy unanimity.

**Domain Bridges**: Category theory ↔ Tropical linear algebra ↔ Political science

**Lineage**: Builds on `eval_tropical_additive`, `eval_tropical_homogeneous` from this cycle.

**Ambition**: extension

---

### Direction 5: Tropical Spectral Gap as Democratic Deficit — Unifying Optimization and Social Choice

**Conjecture**: For a TropSWF with weight gap δ, the *effective number of voters* (defined as the exponential entropy of the "influence distribution") satisfies N_eff ≈ |S| · (1 + O(K/δ)) where |S| is the support size and K is the input range. As δ → 0, N_eff → n (full democracy); as δ → ∞, N_eff → |S| (oligarchy of the support).

Furthermore, this quantity is related to the tropical spectral gap of the associated tropical quadratic form Q(x) = max_{i,j}(w_i + w_j + x_i + x_j) by the formula: tropical spectral gap of Q = 2δ.

**Test**: For n = 5, compute N_eff for various weight vectors and input ranges K. Verify the scaling prediction. Also compute the tropical spectral gap of the associated quadratic form and verify the 2δ relationship.

**Impact**: This would establish a quantitative bridge between tropical optimization (spectral gaps, Lorentzian polynomials) and social choice (voter influence, democratic deficit). The factor of 2 in "gap = 2δ" would be a precise signature of this correspondence.

**Catalog References**: `Speculative/TropicalSocialChoice.lean` (weightGap, weightGap_scale), `Catalog/Pythagorean/TropicalLorentzianShadows.lean` (tropical_exchange_controls_det, rescale_tropical_gap_linear)

**Proof Strategy**: Define the tropical quadratic form Q associated to a TropSWF by Q(x) = max_{i,j}(w_i + w_j + x_i + x_j). The tropical spectral gap of Q is max_{i,j}(w_i + w_j) - max diagonal (2w_i) = max(w_i + w_j for i≠j) vs max(2w_i). For a weight vector with max w_k = 0 and min w_k = -δ, the gap = max(0+0, ...) - max(0, ...) computation gives the desired result. Use the exchange slack framework from TropicalLorentzianShadows.

**Domain Bridges**: Tropical spectral theory ↔ Social choice ↔ Information theory

**Lineage**: Builds on `weightGap_scale`, `weightGap_zero_iff` from this cycle and `rescale_tropical_gap_linear` from the Catalog.

**Ambition**: extension
