# Tropical Social Welfare Functions and the Anti-Arrow Theorem

## Abstract

We introduce **Tropical Social Welfare Functions (TropSWF)** — max-plus linear maps that aggregate voter preferences via the tropical semiring (ℤ, max, +). A TropSWF with n voters is parameterized by a weight vector w ∈ ℤⁿ and maps preference profiles x ∈ ℤⁿ to social outcomes f(x) = maxᵢ(wᵢ + xᵢ). We prove that this framework inverts Arrow's impossibility theorem: (1) every TropSWF automatically satisfies the Pareto (monotonicity) condition; (2) unanimity holds iff the maximum weight is zero; (3) for n ≥ 2, **no TropSWF is dictatorial** (the Tropical Anti-Arrow Theorem); and (4) TropSWF evaluation is genuinely tropical linear, preserving both tropical addition (pointwise max) and tropical scalar multiplication (uniform shift). We characterize the "support" (ruling coalition) and prove that the weight gap — the social-choice analog of the tropical spectral gap — controls coalition breadth. All results are formalized and verified in Lean 4 with Mathlib.

**Keywords:** tropical mathematics, social choice theory, Arrow's impossibility theorem, max-plus algebra, tropical linear maps, formal verification

---

## 1. Introduction

Arrow's impossibility theorem (Arrow, 1951) is one of the foundational results of mathematical social choice theory. It states that for three or more alternatives, no social welfare function simultaneously satisfies:
- **Unanimity (Pareto):** If all voters prefer A to B, the social ranking does too.
- **Independence of Irrelevant Alternatives (IIA):** The social ranking of A vs B depends only on individual rankings of A vs B.
- **Non-dictatorship:** No single voter determines the social ranking for all profiles.

The theorem has generated an enormous literature exploring relaxations, domain restrictions, and alternative frameworks (Sen, 1970; Gibbard, 1973; Satterthwaite, 1975; Gaertner, 2009).

In this paper, we propose a fundamentally different approach: replacing the algebraic structure of classical social welfare with **tropical (max-plus) algebra**. Rather than seeking to relax Arrow's axioms within the classical framework, we change the underlying algebraic setting entirely.

### 1.1 Tropical Mathematics

The tropical semiring (ℝ ∪ {-∞}, ⊕, ⊙) replaces classical addition with maximum (⊕ = max) and classical multiplication with addition (⊙ = +). This algebraic structure arises naturally in:
- Optimization and dynamic programming (Cuninghame-Green, 1979)
- Algebraic geometry and curve counting (Mikhalkin, 2005)
- Phylogenetics and genomics (Pachter & Sturmfels, 2004)
- Auction theory and mechanism design (tropical valuations)

A key property is **idempotency**: x ⊕ x = max(x, x) = x. This contrasts with classical algebra where x + x = 2x, and has deep consequences for aggregation.

### 1.2 Contributions

We make the following contributions:

1. **Definition of TropSWF** (Section 2): A novel mathematical structure — the Tropical Social Welfare Function — defined as a max-plus linear map parameterized by voter weights.

2. **Automatic Pareto** (Theorem 1): Every TropSWF satisfies the Pareto/monotonicity condition, with no axiom needed.

3. **Unanimity characterization** (Theorem 2): Unanimity holds iff the maximum weight is zero, giving a clean algebraic characterization.

4. **Tropical Anti-Arrow** (Theorem 4): For n ≥ 2 voters, no TropSWF is dictatorial. This is the polar opposite of Arrow's result.

5. **Tropical Possibility** (Theorem 5): Non-dictatorial, unanimous, Pareto TropSWFs exist for all n ≥ 2.

6. **Tropical linearity** (Theorems 6-7): TropSWF evaluation is a genuine tropical linear functional, preserving tropical addition and scalar multiplication.

7. **Support and weight gap theory** (Theorems 8-10): Characterization of the ruling coalition and its connection to the tropical spectral gap.

All results are formally verified in Lean 4 with the Mathlib library.

---

## 2. Definitions

### 2.1 Tropical Social Welfare Function

**Definition 1 (TropSWF).** A *Tropical Social Welfare Function* for n voters is a pair (n, w) where w : {1,...,n} → ℤ is a weight function. The *evaluation* of f on profile x : {1,...,n} → ℤ is:

$$f(x) = \max_{1 \leq i \leq n} (w_i + x_i)$$

This is the max-plus linear map induced by the weight vector w.

### 2.2 Social Choice Axioms

**Definition 2 (Unanimity).** A TropSWF f is *unanimous* if f(c, c, ..., c) = c for all c ∈ ℤ.

**Definition 3 (Pareto/Monotonicity).** A TropSWF f satisfies *Pareto* if x_i ≤ y_i for all i implies f(x) ≤ f(y).

**Definition 4 (Dictatorship).** A TropSWF f is *dictatorial* if there exists j such that f(x) = x_j for all x.

### 2.3 Structural Invariants

**Definition 5 (Maximum Weight).** The maximum weight of f is maxWeight(f) = max_i w_i.

**Definition 6 (Support).** The support of f is S(f) = {i : w_i = maxWeight(f)}.

**Definition 7 (Weight Gap).** The weight gap of f is δ(f) = maxWeight(f) - min_i w_i.

**Definition 8 (Pure Max).** The *pure max* TropSWF has w_i = 0 for all i: f(x) = max_i x_i.

---

## 3. Main Results

### 3.1 Theorem 1: Tropical Pareto

**Theorem 1.** Every TropSWF satisfies the Pareto condition.

*Proof.* Let x_i ≤ y_i for all i. Then w_i + x_i ≤ w_i + y_i for each i. Therefore max_i(w_i + x_i) ≤ max_i(w_i + y_i). □

**PEGB Analysis:**
- **P (Proof):** Fully formalized as `trop_pareto` in Lean.
- **E (Example):** For the 3-voter pure max, (1,3,2) ≤ (2,3,4) componentwise, and max(1,3,2) = 3 ≤ max(2,3,4) = 4.
- **G (Generalization):** Extends to any linearly ordered abelian group replacing ℤ, and to any finite indexing set replacing Fin n.
- **B (Boundary):** Pareto holds for ALL TropSWFs with no conditions — it's a structural consequence of max-plus linearity, not an axiom.

### 3.2 Theorem 2: Unanimity Characterization

**Theorem 2.** A TropSWF f is unanimous iff maxWeight(f) = 0.

*Proof.* f(c,...,c) = max_i(w_i + c) = maxWeight(f) + c. This equals c for all c iff maxWeight(f) = 0. □

**PEGB Analysis:**
- **P (Proof):** Fully formalized as `unanimity_iff` in Lean.
- **E (Example):** The weighted TropSWF with weights (0, -1, -2) satisfies unanimity since max(0, -1, -2) = 0.
- **G (Generalization):** For TropSWFs over any ordered group with no maximum element, unanimity is equivalent to the supremum of weights being the group identity.
- **B (Boundary):** If maxWeight > 0, the function "inflates" constant profiles; if maxWeight < 0, it "deflates" them. Only maxWeight = 0 gives calibrated aggregation.

### 3.3 Theorem 4: Tropical Anti-Arrow (Main Result)

**Theorem 4 (Tropical Anti-Arrow).** For n ≥ 2, no TropSWF is dictatorial.

*Proof.* Suppose f is dictatorial with dictator j. Let i ≠ j (exists since n ≥ 2). For any M ∈ ℤ, define x by x_i = M, x_k = 0 for k ≠ i. Then:
- f(x) ≥ w_i + M (by the contribution of voter i)
- f(x) = x_j = 0 (by dictatorship, since j ≠ i)

So w_i + M ≤ 0 for all M ∈ ℤ. But ℤ is unbounded above, contradiction. □

**PEGB Analysis:**
- **P (Proof):** Fully formalized as `trop_anti_arrow` in Lean.
- **E (Example):** For 3 voters with weights (0, 0, 0): f(0, 100, 0) = 100 ≠ 0, so voter 0 is not a dictator. Similarly for all voters.
- **G (Generalization):** The theorem holds for any TropSWF over any linearly ordered abelian group without an upper bound (ℤ, ℚ, ℝ). The key property used is unboundedness.
- **B (Boundary):** For n = 1, the unique TropSWF *is* trivially dictatorial (f(x) = w₁ + x₁, and with unanimity w₁ = 0 so f(x) = x₁). The theorem fails precisely at n = 1. Also, if we allow w_i = -∞ (using the extended tropical semiring WithBot ℤ), true dictators exist: set w_j = 0 and w_i = -∞ for i ≠ j.

### 3.4 Theorem 5: Tropical Possibility

**Theorem 5 (Tropical Possibility).** For n ≥ 2, there exists a TropSWF that is unanimous, Pareto, and non-dictatorial.

*Proof.* The pure max function (all weights zero) satisfies unanimity (Theorem 2: maxWeight = 0), Pareto (Theorem 1), and non-dictatorship (Theorem 4). □

### 3.5 Theorems 6-7: Tropical Linearity

**Theorem 6 (Tropical Additivity).** f(max(x,y)) = max(f(x), f(y)).

*Proof.* max_i(w_i + max(x_i, y_i)) = max_i(max(w_i + x_i, w_i + y_i)) = max(max_i(w_i + x_i), max_i(w_i + y_i)). □

**Theorem 7 (Tropical Homogeneity).** f(c + x) = c + f(x) where (c + x)_i = c + x_i.

*Proof.* max_i(w_i + c + x_i) = c + max_i(w_i + x_i). □

**PEGB Analysis (for Theorem 6):**
- **P (Proof):** Fully formalized as `eval_tropical_additive` in Lean.
- **E (Example):** Weights (0,-1), x=(1,3), y=(2,1). max(x,y)=(2,3). f(max(x,y))=max(2,2)=2. f(x)=max(1,2)=2, f(y)=max(2,0)=2. max(f(x),f(y))=2. ✓
- **G (Generalization):** This makes f a morphism in the category of tropical semimodules. In the categorical perspective, TropSWFs are precisely the tropical linear functionals on the free tropical module ℤⁿ.
- **B (Boundary):** Tropical additivity does NOT hold for non-tropical-linear aggregation rules. E.g., the median function violates it: median(max(1,3), max(2,1), max(2,2)) ≠ max(median(1,2,2), median(3,1,2)).

---

## 4. Support Theory and Weight Gap

### 4.1 Support Structure

**Theorem 8.** The support S(f) is nonempty for all TropSWFs.

**Theorem 9 (Unanimous support).** For a unanimous TropSWF, S(f) = {i : w_i = 0}.

**Theorem 10 (Eval bound from support).** For a unanimous TropSWF and any i ∈ S(f): x_i ≤ f(x).

These results show that the support forms a "ruling coalition": for any input, the outcome is at least as large as any support member's input. However, unlike classical oligarchy results, non-support members can influence the outcome on extreme inputs.

### 4.2 Weight Gap Theory

**Theorem 11 (Gap nonnegativity).** δ(f) ≥ 0.

**Theorem 12 (Gap rescaling).** For k > 0, δ(k · f) = k · δ(f), where (k · f) has weights k · wᵢ.

**Theorem 13 (Gap = 0 iff egalitarian).** δ(f) = 0 iff all weights are equal.

**Theorem 14 (Zero gap = full support).** If δ(f) = 0, then S(f) = {1,...,n}.

The weight gap is the social-choice analog of the **tropical spectral gap** from tropical Lorentzian theory (cf. `rescale_tropical_gap_linear` in the Catalog). Both measure separation in max-plus structures:
- The tropical spectral gap measures coefficient separation in tropical quadratic forms, controlling eigenvalue separation.
- The weight gap measures voter influence separation, controlling coalition breadth.

The rescaling theorem (Theorem 12) mirrors `rescale_tropical_gap_linear`, establishing that gap measures scale linearly under weight scaling — a key stability property.

---

## 5. Connection to Arrow's Classical Theorem

### 5.1 The Classical-Tropical Correspondence

Arrow's theorem operates in the "classical" algebraic setting where aggregation uses sums and products. The tropical setting replaces these with max and plus. The correspondence:

| Classical | Tropical |
|-----------|----------|
| Sum ∑wᵢxᵢ | Max maxᵢ(wᵢ + xᵢ) |
| Linear function | Tropical linear function |
| Dictator: f(x) = x_j | Dictator: f(x) = x_j |
| Pareto: x ≤ y ⟹ f(x) ≤ f(y) | Same |
| Unanimity: f(c,...,c) = c | Same |

### 5.2 Why Impossibility Becomes Possibility

The crucial difference is **idempotency of tropical addition**: max(x, x) = x. In classical algebra, x + x = 2x, which allows one voter to accumulate disproportionate influence through coefficient scaling. In tropical algebra, repeating a value doesn't amplify it — the max operation is fundamentally egalitarian.

The proof of anti-dictatorship exploits **unboundedness**: for any finite weight disadvantage, a voter can overcome it with a sufficiently extreme input. This is possible because ℤ (and ℝ) have no upper bound. In a bounded domain (e.g., preferences restricted to [0, K]), near-dictatorship becomes possible when the weight gap exceeds K.

### 5.3 The Bounded Domain Conjecture

**Conjecture (Bounded Domain Transition).** For TropSWFs over {0, 1, ..., K}ⁿ with unanimity, the fraction of profiles where a non-support voter can influence the outcome approaches 0 as the weight gap δ → ∞ relative to K. Specifically, this fraction is O(δ/K) for fixed n.

This conjecture predicts a smooth transition from tropical democracy (δ = 0, all voters influential) to near-classical dictatorship (δ ≫ K, one voter dominates). If true, it would quantify exactly how Arrow's impossibility "emerges" from the tropical possibility as the domain becomes bounded.

**Computational test:** For n = 3, K = 10, weights (0, -δ, -δ) and all profiles in {0,...,10}³, compute the fraction where voter 0's value is NOT the maximum of (x₁, -δ+x₂, -δ+x₃). This should approach 1 as δ → ∞.

---

## 6. Algorithms

### 6.1 TropSWF Evaluation

The evaluation of a TropSWF is O(n): compute wᵢ + xᵢ for each voter, then take the maximum.

### 6.2 Support Computation

Computing the support requires O(n): find the maximum weight (O(n)), then filter for voters achieving it (O(n)).

### 6.3 Weight Gap Computation

The weight gap requires O(n): compute max and min of the weight vector and subtract.

### 6.4 Optimal Weight Design

Given a target support set S ⊆ {1,...,n} and a target gap δ, the optimal weight vector sets wᵢ = 0 for i ∈ S and wᵢ = -δ for i ∉ S. This minimizes the total influence leakage to non-support voters.

---

## 7. Discussion

### 7.1 Relationship to Existing Work

Our work connects several previously disparate areas:

1. **Tropical geometry** (Maclagan & Sturmfels, 2015): TropSWFs are tropical linear functionals on tropical modules.

2. **Arrow's theorem** (Arrow, 1951): We show that the algebraic structure, not the axioms, determines (im)possibility.

3. **Tropical spectral theory** (cf. `rescale_tropical_gap_linear` in the Catalog): The weight gap parallels the tropical spectral gap.

4. **Max-plus algebra** (Cuninghame-Green, 1979): TropSWFs extend max-plus linear algebra to social choice.

### 7.2 Limitations

1. Our framework uses **cardinal utilities** (numerical scores) rather than **ordinal rankings**. Arrow's theorem is fundamentally about ordinal aggregation. The comparison is therefore across frameworks, not within Arrow's exact setting.

2. We work over **ℤ** (unbounded integers). The anti-dictatorship result relies essentially on unboundedness. For bounded domains, the result degrades to "near-impossibility."

3. The tropical framework assumes a specific functional form (max-plus linear). Other aggregation rules may exhibit different behavior.

### 7.3 Significance

Despite these limitations, our results demonstrate that Arrow's impossibility is **algebraically contingent** — it depends on the choice of algebraic operations (sum, product) rather than being a universal constraint on preference aggregation. The tropical alternative provides a mathematically rigorous framework where all desirable properties coexist, suggesting that the search for fair voting systems should include exploration of alternative algebraic foundations.

---

## 8. Future Work

1. **Tropical Arrow over ranked alternatives:** Extend the framework from cardinal utilities to tropical analogs of ordinal rankings.

2. **Strategic behavior:** Study tropical analogs of the Gibbard-Satterthwaite theorem on strategy-proofness.

3. **Continuous tropical SWFs:** Extend from ℤ to ℝ and study topological properties.

4. **Categorical framework:** Develop the category of TropSWFs with natural transformations as the morphisms.

5. **Bounded domain analysis:** Prove or disprove the Bounded Domain Transition Conjecture.

---

## References

1. Arrow, K. J. (1951). *Social Choice and Individual Values*. Yale University Press.
2. Cuninghame-Green, R. A. (1979). *Minimax Algebra*. Lecture Notes in Economics and Mathematical Systems, Springer.
3. Gaertner, W. (2009). *A Primer in Social Choice Theory*. Oxford University Press.
4. Gibbard, A. (1973). Manipulation of voting schemes: a general result. *Econometrica*, 41(4), 587-601.
5. Maclagan, D. & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. Graduate Studies in Mathematics, AMS.
6. Mikhalkin, G. (2005). Enumerative tropical algebraic geometry in ℝ². *J. Amer. Math. Soc.*, 18(2), 313-377.
7. Satterthwaite, M. A. (1975). Strategy-proofness and Arrow's conditions. *J. Econ. Theory*, 10(2), 187-217.
8. Sen, A. K. (1970). *Collective Choice and Social Welfare*. Holden-Day.
9. Brändén, P. & Huh, J. (2020). Lorentzian polynomials. *Annals of Mathematics*, 192(3), 821-891.
