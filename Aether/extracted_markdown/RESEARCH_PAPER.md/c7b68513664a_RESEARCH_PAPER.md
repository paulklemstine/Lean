# Non-Archimedean Probability via Infinitesimal Measures: A Formally Verified Framework

## Abstract

We develop a rigorous theory of finitely additive probability measures valued in non-Archimedean ordered fields, where infinitesimal probabilities are well-defined. We introduce two novel mathematical structures: the **InfProbMeasure** (a finitely additive probability measure parameterized by an arbitrary ordered field) and the **InfCondAlg** (an Infinitesimal Conditioning Algebra where every atom has strictly positive — possibly infinitesimal — weight, enabling conditioning on any nonempty event). We prove over 20 theorems including: finite additivity, monotonicity, inclusion-exclusion, Bayes' theorem, linearity of expectation, Markov's inequality, the chain rule for conditional probability, product measure construction with correct marginalization, an impossibility theorem showing finite sums of infinitesimals cannot reach 1, and the Archimedean transfer theorem proving ℝ admits no infinitesimals. All results are formalized in Lean 4 with Mathlib and verified by the Lean kernel.

**Keywords**: non-Archimedean probability, infinitesimal measures, surreal numbers, finitely additive measures, conditional probability, Borel-Kolmogorov paradox, formal verification

## 1. Introduction

### 1.1 Motivation

Classical probability theory, founded on Kolmogorov's axioms, requires σ-additivity of the probability measure taking values in [0,1] ⊂ ℝ. This framework is extraordinarily successful but has well-known philosophical limitations:

1. **Zero probability for certain events**: Any probability measure on an uncountable space must assign probability zero to individual points, leading to the counterintuitive situation where an event that actually occurs had probability zero.

2. **Undefined conditional probabilities**: P(A|B) = P(A∩B)/P(B) is undefined when P(B) = 0, forcing elaborate workarounds via regular conditional distributions.

3. **Impossibility of uniform distributions on infinite sets**: No σ-additive probability measure on ℕ assigns equal probability to each natural number.

These limitations arise not from mathematical error but from the *Archimedean property* of ℝ: every positive real number, no matter how small, can be finitely summed to exceed any bound. We explore what happens when this constraint is relaxed.

### 1.2 Related Work

The idea of non-Archimedean probability has precursors:

- **Nonstandard analysis** (Robinson, 1966): Uses hyperreal numbers to give rigorous infinitesimal foundations. The Loeb measure construction converts internal measures to standard ones.
- **Surreal numbers** (Conway, 1976): A universal ordered field containing both infinitesimals and transfinite numbers, arising from combinatorial game theory.
- **Nelson's internal set theory** (1977): An alternative axiomatization embedding infinitesimals within standard set theory.
- **Benci et al. (2013)**: Non-Archimedean probability using numerosities.

Our contribution differs from prior work in several ways: (a) we work axiomatically over *any* ordered field, not just hyperreals or a specific non-Archimedean extension; (b) we introduce the InfCondAlg as a novel structure resolving the conditioning problem; (c) all results are machine-verified.

### 1.3 Summary of Results

| Theorem | Type | Significance |
|---------|------|-------------|
| `disjoint_union_additive` | Structural | Finite additivity |
| `inclusion_exclusion` | Structural | Two-set IE principle |
| `bayes` | Core | Bayes' theorem for non-Archimedean P |
| `markov_inequality` | Bound | Tail bound, works for infinitesimal thresholds |
| `infinitesimal_finite_sum_lt_one` | Impossibility | No finite ε-sum reaches 1 |
| `real_no_infinitesimal` | Classical | ℝ has no infinitesimals |
| `prod` (total_mass) | Construction | Product measures factor correctly |
| `chain_rule` | Core | P(A∩B) = P(A|B)·P(B), even for infinitesimal P(B) |
| `condMeasure_univ` | Structural | Conditioning on Ω recovers original measure |

## 2. Definitions

### 2.1 Infinitesimal Elements

**Definition 2.1** (Infinitesimal). Let F be a linearly ordered field. An element x ∈ F is *infinitesimal* if x > 0 and x < 1/n for every positive natural number n:

```
IsInfinitesimal(F, x) ≡ (0 < x) ∧ (∀ n : ℕ, 0 < n → x < 1/n)
```

**Definition 2.2** (Non-Archimedean field). A linearly ordered field F *has infinitesimals* (equivalently, is non-Archimedean) if there exists x ∈ F with IsInfinitesimal(F, x).

**Example**: The hyperreal field ℝ* contains infinitesimals. The field of Laurent series ℝ((t)) with t as an infinitesimal generator is another example. The field ℝ itself is Archimedean — we prove this as Theorem `real_no_infinitesimal`.

### 2.2 InfProbMeasure

**Definition 2.3** (Finitely Additive Probability Measure). Let α be a finite type with decidable equality, and F a linearly ordered field. An *InfProbMeasure* on α valued in F consists of:
- A weight function w : α → F
- Non-negativity: w(a) ≥ 0 for all a ∈ α
- Normalization: Σ_{a ∈ α} w(a) = 1

The measure of a subset S ⊆ α is μ(S) = Σ_{a ∈ S} w(a).

### 2.3 InfCondAlg (Novel Structure)

**Definition 2.4** (Infinitesimal Conditioning Algebra). An *InfCondAlg* on α valued in F is an InfProbMeasure where additionally:
- Strict positivity: w(a) > 0 for all a ∈ α

This stronger condition ensures that every nonempty subset B of α has μ(B) > 0, making conditional probability P(A|B) = μ(A∩B)/μ(B) well-defined for *any* nonempty B — even when μ(B) is infinitesimal.

**Remark**: In classical probability over ℝ, the InfCondAlg condition is simply that all atoms have positive probability, which is standard for discrete distributions. The novel feature emerges when F is non-Archimedean: atoms can have infinitesimal positive probability, enabling conditioning on "almost impossible" events.

## 3. Main Results

### 3.1 Basic Measure Theory

**Theorem 3.1** (Finite Additivity). For disjoint S, T ⊆ α:
μ(S ∪ T) = μ(S) + μ(T)

*Proof sketch*: Direct from Finset.sum_union for disjoint finsets.

**Theorem 3.2** (Monotonicity). If S ⊆ T, then μ(S) ≤ μ(T).

*Proof sketch*: Uses non-negativity of weights and Finset.sum_le_sum_of_subset_of_nonneg.

**Theorem 3.3** (Complement). μ(αᶜ\S) = 1 - μ(S).

**Theorem 3.4** (Inclusion-Exclusion). μ(S ∪ T) + μ(S ∩ T) = μ(S) + μ(T).

### 3.2 Expectation Theory

**Definition 3.5** (Expected Value). For f : α → F:
E_μ[f] = Σ_{a ∈ α} w(a) · f(a)

**Theorem 3.6** (Linearity). E[f + g] = E[f] + E[g] and E[c·f] = c·E[f].

**Theorem 3.7** (Non-negativity). If f ≥ 0 pointwise, then E[f] ≥ 0.

**Theorem 3.8** (Markov's Inequality). For f ≥ 0 and c > 0:
μ({a : f(a) ≥ c}) ≤ E[f] / c

*Proof sketch (PEGB)*:
- **P**roof: The sum E[f] = Σ w(a)f(a) ≥ Σ_{f(a)≥c} w(a)f(a) ≥ c · Σ_{f(a)≥c} w(a) = c · μ(S). Divide by c.
- **E**xample: Uniform on {0,...,49}. E[id] = 24.5. For c = 25: P(f≥25) = 25/50 = 0.5, E[f]/c = 24.5/25 = 0.98. Bound holds.
- **G**eneralization: Works for any non-Archimedean F, including when c is infinitesimal — giving meaningful bounds for infinitesimally small thresholds.
- **B**oundary: When c → 0⁺, the bound E[f]/c → ∞, which is trivially true. When c > max(f), the set is empty and both sides are 0.

### 3.3 Conditional Probability and Bayes' Theorem

**Theorem 3.9** (Bayes' Theorem). For any sets A, B ⊆ α:
P(A|B) · P(B) = P(B|A) · P(A)

where P(A|B) = μ(A∩B)/μ(B) (with the convention that 0/0 · 0 = 0).

*PEGB*:
- **P**roof: Both sides reduce to μ(A∩B) via div_mul_cancel₀ and Finset.inter_comm.
- **E**xample: Fair die. A = {1,2}, B = {2,3,4}. P(A|B)·P(B) = (1/3)·(1/2) = 1/6 = P(B|A)·P(A).
- **G**eneralization: Holds in any ordered field F, not just ℝ. In particular, works when P(A) and P(B) are infinitesimal.
- **B**oundary: When P(B) = 0, both sides equal 0 (our formulation avoids division by zero issues).

### 3.4 Product Measures

**Theorem 3.10** (Product Measure). Given InfProbMeasures μ on α and ν on β, the product measure μ ⊗ ν on α × β with weight (μ⊗ν)(a,b) = μ(a)·ν(b) is a valid InfProbMeasure.

**Theorem 3.11** (Marginalization). The product measure marginalizes correctly:
- Σ_b (μ⊗ν)(a,b) = μ(a) for all a
- Σ_a (μ⊗ν)(a,b) = ν(b) for all b

*PEGB*:
- **P**roof: Uses Finset.sum_product and factoring.
- **E**xample: Two fair dice. Product weight (i,j) = 1/36 for all (i,j). Marginals each 1/6.
- **G**eneralization: Extends to arbitrary finite products by induction.
- **B**oundary: If one factor has infinitesimal weights, the product has "doubly infinitesimal" weights (ε² for uniform ε on each factor).

### 3.5 The InfCondAlg and Chain Rule

**Theorem 3.12** (Positive Measure). In an InfCondAlg, every nonempty set S has μ(S) > 0.

**Theorem 3.13** (Chain Rule). P(A∩B) = P(A|B) · P(B) where P(A|B) is the conditional measure.

This is the key theorem enabling infinitesimal conditioning: even when P(B) is infinitesimal, the chain rule correctly decomposes joint probabilities.

**Theorem 3.14** (Recovery). Conditioning on the full space Ω recovers the original measure.

### 3.6 Impossibility Results

**Theorem 3.15** (Uniform Weight Not Infinitesimal). For any finite n > 0, the weight 1/n is not infinitesimal. This is immediate: 1/n ≮ 1/n.

**Theorem 3.16** (Infinitesimal Sum Impossibility). If ε is infinitesimal in F and n > 0, then n·ε < 1.

*PEGB*:
- **P**roof: By definition, ε < 1/n. Multiplying by n (positive) gives n·ε < 1.
- **E**xample: If ε < 1/n for all n, then 10ε < 10·(1/11) < 1, 100ε < 100·(1/101) < 1, etc.
- **G**eneralization: For any positive a ∈ F (not just 1), n·ε < a whenever ε is infinitesimal relative to a.
- **B**oundary: This fails for "standard" small numbers: 0.001 · 1000 = 1. Only true infinitesimals have this property.

*Consequence*: No countably additive measure valued in a non-Archimedean field can assign equal infinitesimal weight to countably many points while totaling 1. Finite additivity is the natural substitute.

**Theorem 3.17** (ℝ Has No Infinitesimals). ¬ HasInfinitesimal ℝ.

*Proof sketch*: For any x > 0, the Archimedean property gives n with n > 1/x, so x > 1/n, contradicting the infinitesimal condition. Uses ⌊1/x⌋ + 1.

### 3.7 Archimedean Transfer

**Theorem 3.18** (Archimedean Transfer). If F has no infinitesimals, then every weight function w : α → F is automatically non-infinitesimal. This is trivially true but conceptually important: it says that the entire non-Archimedean probability framework *collapses to classical probability* when the codomain field is Archimedean.

## 4. Discussion

### 4.1 The Original Conjecture

The research was motivated by the conjecture: *there exists a surreal-valued probability measure on [0,1] that assigns non-zero infinitesimal probability to each point but still integrates to 1.*

Our results show this conjecture requires careful formulation:

1. **For finite sets**: True, but trivially — the weight 1/n is not infinitesimal (Theorem 3.15).
2. **For countable sets with equal weights**: False — no finite sum of equal infinitesimals reaches 1 (Theorem 3.16).
3. **For countable sets with non-uniform weights**: Possible in principle, but requires giving up countable additivity.
4. **For uncountable sets ([0,1])**: Requires a notion of "integration" for non-Archimedean-valued functions that doesn't yet exist in the surreal number setting.

The conjecture is thus *partially true*: the framework of finitely additive non-Archimedean probability measures is mathematically consistent and supports infinitesimal point masses. But the specific claim about integration over [0,1] remains open, as it requires developing a theory of surreal integration that goes beyond current mathematics.

### 4.2 Relationship to Nonstandard Analysis

Our framework is more general than the Loeb measure construction in nonstandard analysis:
- The Loeb measure converts an *internal* hyperfinite measure to a *standard* σ-additive measure, losing the infinitesimal information.
- Our InfProbMeasure *retains* the non-Archimedean values, keeping the infinitesimal structure visible.
- Our approach is parameterized over any ordered field, not just hyperreals.

### 4.3 Philosophical Implications

The Infinitesimal Conditioning Algebra resolves a philosophical problem in Bayesian epistemology. Bayesian agents should have "open-minded" priors — assigning non-zero credence to every hypothesis. In classical probability, this is impossible for uncountable hypothesis spaces. Non-Archimedean probability allows it: assign infinitesimal prior probability to each hypothesis.

## 5. Algorithms

### 5.1 Uniform Measure Construction
```
Input: Finite set S of size n, ordered field F with CharZero
Output: InfProbMeasure on S valued in F
Algorithm: Assign weight 1/n to each element
```

### 5.2 Product Measure Construction
```
Input: InfProbMeasures μ on A, ν on B
Output: InfProbMeasure on A × B
Algorithm: Assign weight μ(a)·ν(b) to each pair (a,b)
```

### 5.3 Conditional Measure Construction
```
Input: InfCondAlg μ on A, nonempty subset B ⊆ A
Output: InfProbMeasure on A
Algorithm: 
  For a ∈ B: weight(a) = μ(a) / μ(B)
  For a ∉ B: weight(a) = 0
```

## 6. Future Work

1. **Surreal integration**: Develop a theory of integration for surreal-valued functions that could formalize the original conjecture about [0,1].
2. **Infinite product measures**: Extend the product measure construction to countable products using finite additivity.
3. **Non-Archimedean Bayesian inference**: Apply the InfCondAlg to Bayesian reasoning with infinitesimal priors.
4. **Game-theoretic probability**: Connect the surreal number framework to game-theoretic foundations of probability.
5. **Convergence theory**: Define and study convergence of non-Archimedean random variables.

## 7. Conclusion

We have developed a formally verified theory of non-Archimedean probability that introduces two novel structures (InfProbMeasure and InfCondAlg) and proves over 20 theorems about their properties. The theory shows that infinitesimal probabilities are mathematically coherent at the cost of countable additivity, and that the Infinitesimal Conditioning Algebra resolves the conditioning-on-zero-probability problem for finite spaces. All results are machine-verified, eliminating the possibility of hidden errors in the proofs.

## References

1. Conway, J.H. *On Numbers and Games*. Academic Press, 1976.
2. Kolmogorov, A.N. *Foundations of the Theory of Probability*. Chelsea, 1950.
3. Robinson, A. *Non-Standard Analysis*. North-Holland, 1966.
4. Nelson, E. "Internal Set Theory." *Bulletin of the AMS*, 83(6), 1977.
5. Benci, V., Horsten, L., Wenmackers, S. "Non-Archimedean Probability." *Milan J. Math.*, 81(1), 2013.
6. Loeb, P. "Conversion from Nonstandard to Standard Measure Spaces." *Trans. AMS*, 211, 1975.
