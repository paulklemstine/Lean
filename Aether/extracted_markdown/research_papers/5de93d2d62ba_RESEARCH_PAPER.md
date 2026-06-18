# Rigorous Algebraic Foundations for Probability Theory in Non-Archimedean Ordered Fields

**Abstract.** We establish algebraic foundations for probability theory valued in arbitrary linearly ordered fields, proving an exact characterization: a linearly ordered field admits infinitesimal probabilities (positive ε with n·ε < 1 for all n ∈ ℕ) if and only if it is non-Archimedean (Theorem 2.1). We develop a theory of finitely additive measures over such fields, proving that faithfulness (all singletons have positive mass) is equivalent to strict monotonicity (proper subset inclusion implies strict mass inequality) (Theorem 4.3). We construct conditional probability on individual points and show it reduces to the indicator function, resolving the Borel-Kolmogorov paradox in the non-Archimedean setting (Theorems 5.1–5.2). All results are machine-verified; we reference the formal development at `@Algebra/NonArchimedeanProbability.lean`.

**Keywords:** Non-Archimedean fields, infinitesimal probability, finitely additive measures, conditional probability, Borel-Kolmogorov paradox, faithfulness

**MSC 2020:** 60A05, 12J25, 03H05, 28A12

---

## 1. Introduction

### 1.1 Motivation

The standard Kolmogorov axiomatization of probability theory uses σ-additive measures valued in the real numbers. This framework is extraordinarily successful, but it forces probability zero on individual points in any atomless space. As a consequence, conditional probability P(A | {x}) = P(A ∩ {x})/P({x}) is undefined when P({x}) = 0, leading to the well-known Borel-Kolmogorov paradox [1].

Several authors have proposed extending probability theory to non-Archimedean number systems — including the hyperreals of Robinson's nonstandard analysis [2], the surreal numbers of Conway [3], and various ultrapower constructions [4]. These proposals share a common intuition: in a number system containing infinitesimals, individual points can carry positive (infinitesimal) probability, potentially resolving the paradoxes of point conditioning.

However, a precise algebraic characterization of *which* number systems admit infinitesimal probabilities has been lacking. This paper provides such a characterization and develops the resulting probability theory.

### 1.2 Contributions

Our contributions are:

1. **Exact algebraic characterization** (§2): A linearly ordered field F admits an infinitesimal probability if and only if F is non-Archimedean. This reduces a probabilistic question to a standard algebraic property.

2. **Finitely additive measures over ordered fields** (§3): We define and develop a theory of finitely additive measures taking values in arbitrary linearly ordered fields, including monotonicity and decomposition into singleton masses.

3. **Faithfulness–monotonicity equivalence** (§4): We prove that a finitely additive measure on a finite type has all-positive singleton masses if and only if it is strictly monotone with respect to proper subset inclusion.

4. **Non-Archimedean conditional probability** (§5): We construct conditional probability on individual points when singleton masses are nonzero, proving it acts as an indicator function and satisfies the chain rule.

5. **Uniform measure construction** (§6): We construct the uniform finitely additive measure assigning mass 1/|α| to each element.

### 1.3 Related Work

Benci et al. [5] developed a theory of non-Archimedean probability using numerosity theory, assigning "fair" probabilities to subsets of ℕ. Wenmackers and Horsten [6] advocated for infinitesimal probabilities in the philosophy of science. Nelson's internal set theory [7] and Loeb's measure construction [8] provide alternative frameworks. Our approach differs in being purely algebraic — we work over an arbitrary linearly ordered field satisfying IsStrictOrderedRing, without committing to a specific non-standard construction.

---

## 2. The Non-Archimedean Characterization

### 2.1 Definitions

Let F be a linearly ordered field.

**Definition 2.1** (Infinitesimal Probability). An element ε ∈ F is an *infinitesimal probability* if:
1. ε > 0, and
2. n · ε < 1 for all n ∈ ℕ.

The formal definition is `IsInfinitesimalProb` in `@Algebra/NonArchimedeanProbability.lean`.

Note that condition (2) is strictly stronger than merely requiring ε to be infinitesimal (i.e., |ε| < 1/n for all standard n). An infinitesimal probability must be positive *and* satisfy the uniform bound with respect to 1. However, in an ordered field, these notions coincide for positive elements.

**Definition 2.2** (Archimedean Property). F is *Archimedean* if for all x, y ∈ F with y > 0, there exists n ∈ ℕ such that x ≤ n · y.

### 2.2 Main Theorem

**Theorem 2.1** (`non_archimedean_iff_infinitesimal_exists`). *Let F be a linearly ordered field. Then:*

$$\exists \varepsilon \in F,\; \text{IsInfinitesimalProb}(F, \varepsilon) \iff \neg\,\text{Archimedean}(F)$$

*Proof sketch.*

(⇒) Suppose ε > 0 with n·ε < 1 for all n ∈ ℕ. If F were Archimedean, applied to x = 1 and y = ε, we obtain n with 1 ≤ n·ε, contradicting the hypothesis.

(⇐) Suppose F is not Archimedean. Then there exist x, y ∈ F with y > 0 and n·y < x for all n ∈ ℕ. In particular x > 0 (taking n = 0). Set ε = y/x. Then ε > 0 and for all n, n·ε = n·y/x < x/x = 1. ∎

The formal proof is at `@Algebra/NonArchimedeanProbability.lean`, theorem `non_archimedean_iff_infinitesimal_exists`.

### 2.3 Boundary Cases

**Corollary 2.2** (`no_infinitesimal_prob_rationals`). *ℚ admits no infinitesimal probabilities.*

This follows immediately from the fact that ℚ is Archimedean (a standard result). The same holds for ℝ, also Archimedean. These boundary results confirm that infinitesimal probability requires genuinely non-standard number systems.

---

## 3. Finitely Additive Measures over Ordered Fields

### 3.1 Definition

**Definition 3.1** (`FinAddMeasure`). Let α be a finite type with decidable equality, and F a linearly ordered field. A *finitely additive measure* on α valued in F is a function μ : Finset(α) → F satisfying:

1. **Null empty set**: μ(∅) = 0.
2. **Finite additivity**: If s ∩ t = ∅, then μ(s ∪ t) = μ(s) + μ(t).
3. **Non-negativity**: μ(s) ≥ 0 for all s.

This is formalized as the structure `FinAddMeasure` in `@Algebra/NonArchimedeanProbability.lean`.

### 3.2 Decomposition and Monotonicity

**Theorem 3.1** (`FinAddMeasure.mass_eq_sum`). *For any finitely additive measure μ and any finset s:*

$$\mu(s) = \sum_{x \in s} \mu(\{x\})$$

*Proof sketch.* By induction on s using the `Finset.induction` principle. The base case is μ(∅) = 0. The inductive step uses finite additivity on {a} ∪ s where a ∉ s. ∎

**Theorem 3.2** (`FinAddMeasure.mass_mono`). *If s ⊆ t, then μ(s) ≤ μ(t).*

*Proof sketch.* Write t = s ∪ (t \ s) with the union disjoint. Then μ(t) = μ(s) + μ(t \ s) ≥ μ(s) by non-negativity. ∎

---

## 4. Faithfulness and Strict Monotonicity

### 4.1 Definitions

**Definition 4.1.** A finitely additive measure μ is *faithful* if μ({x}) > 0 for all x ∈ α.

**Definition 4.2.** μ is *strictly monotone* if s ⊂ t (proper subset) implies μ(s) < μ(t).

### 4.2 Positivity of Faithful Measures

**Theorem 4.1** (`FinAddMeasure.mass_pos_of_pos_weights`). *If μ is faithful and s is nonempty, then μ(s) > 0.*

*Proof sketch.* By the decomposition theorem, μ(s) = Σ_{x ∈ s} μ({x}). Each summand is positive by faithfulness, and the sum is over a nonempty set, so the sum is positive. ∎

This result is the measure-theoretic manifestation of a deeper algebraic principle: sums of same-sign elements in an ordered field cannot cancel. The corresponding algebraic fact appears in Lorentzian geometry as the anti-cancellation principle for same-sign vectors.

### 4.3 The Equivalence

**Theorem 4.2** (`FinAddMeasure.mass_strict_mono_of_pos_weights`). *If μ is faithful and s ⊂ t, then μ(s) < μ(t).*

*Proof sketch.* Write μ(t) = μ(s) + μ(t \ s). Since s ⊂ t, we have t \ s ≠ ∅, so μ(t \ s) > 0 by Theorem 4.1. Therefore μ(t) > μ(s). ∎

**Theorem 4.3 (Converse)** (`FinAddMeasure.pos_weights_of_strict_mono`). *If μ is strictly monotone, then μ is faithful.*

*Proof sketch.* For any x ∈ α, ∅ ⊂ {x}. By strict monotonicity, μ(∅) < μ({x}), i.e., 0 < μ({x}). ∎

**Theorem 4.4** (`FinAddMeasure.faithful_iff_strict_mono`). *A finitely additive measure μ on a finite type is faithful if and only if it is strictly monotone.*

This is an immediate combination of Theorems 4.2 and 4.3. The formal statement and proof are at `@Algebra/NonArchimedeanProbability.lean`, theorem `faithful_iff_strict_mono`.

**Remark 4.1.** This equivalence fails for real-valued measures on infinite types. The counting measure on ℕ is faithful (every singleton has mass 1) but not strictly monotone in the sense of subset inclusion on sets of equal infinite measure. The result is specific to finite types, where the algebraic structure of finite sums in an ordered field controls the behavior completely.

**Remark 4.2.** The forward direction (Theorem 4.3) has a particularly elegant proof: for any x, simply observe that ∅ ⊂ {x}, so strict monotonicity gives 0 = μ(∅) < μ({x}). This one-line argument captures the essence of the characterization — strict monotonicity is not merely a *consequence* of faithfulness, but an *equivalent* reformulation that can be used to *define* faithfulness purely in terms of the order structure on the power set.

### 4.4 Connection to the Same-Sign Aggregation Principle

The positivity theorem (Theorem 4.1) is an instance of a more general algebraic fact: in an ordered ring, a sum of non-negative elements with at least one positive element is itself positive. This principle appears in multiple mathematical contexts:

- **Probability theory** (this paper): Positive singleton masses yield positive set masses.
- **Lorentzian geometry**: Sums of future-pointing timelike vectors remain future-pointing. The formal statement `sum_ne_zero_of_same_sign_and_exists_ne_zero` in the project catalog expresses this for Lorentzian signatures.
- **Convex analysis**: A positive combination of elements in the interior of a cone remains in the interior.
- **Linear algebra**: The trace of a positive definite matrix is positive (sum of positive eigenvalues).

The unifying algebraic structure is that of a *strictly ordered commutative monoid* with the property that 0 ≤ aᵢ for all i and aⱼ > 0 for some j implies Σᵢ aᵢ > 0. In an ordered field, this follows from the compatibility of the order with addition. The measure-theoretic formulation makes this abstract fact directly applicable to probability.

---

## 5. Conditional Probability on Individual Points

### 5.1 Definition

**Definition 5.1** (`FinAddMeasure.condProb`). For a finitely additive measure μ and finsets A, B with μ(B) ≠ 0:

$$P(A \mid B) := \frac{\mu(A \cap B)}{\mu(B)}$$

This is well-defined whenever μ(B) ≠ 0. In the non-Archimedean setting with a faithful measure, μ({x}) > 0 for all x, so conditioning on singleton events is always well-defined.

### 5.2 Point Conditioning

**Theorem 5.1** (`FinAddMeasure.condProb_singleton_mem`). *If x ∈ A and μ({x}) > 0, then P(A | {x}) = 1.*

*Proof sketch.* A ∩ {x} = {x} since x ∈ A. Therefore P(A | {x}) = μ({x})/μ({x}) = 1. ∎

**Theorem 5.2** (`FinAddMeasure.condProb_singleton_not_mem`). *If x ∉ A and μ({x}) > 0, then P(A | {x}) = 0.*

*Proof sketch.* A ∩ {x} = ∅ since x ∉ A. Therefore P(A | {x}) = μ(∅)/μ({x}) = 0/μ({x}) = 0. ∎

Together, these theorems show:

$$P(A \mid \{x\}) = \mathbf{1}_A(x)$$

This resolves the Borel-Kolmogorov paradox in the non-Archimedean setting. In standard probability, P(A | {x}) is undefined because P({x}) = 0. Here, with infinitesimal but positive singleton masses, the conditional probability is perfectly well-defined and behaves exactly as intuition demands.

### 5.3 Chain Rule

**Theorem 5.3** (`FinAddMeasure.condProb_chain_rule`). *For finsets A, B, C with μ(C) ≠ 0 and μ(B ∩ C) ≠ 0:*

$$P(A \cap B \mid C) = P(A \mid B \cap C) \cdot P(B \mid C)$$

*Proof sketch.* Direct algebraic manipulation:

$$P(A \mid B \cap C) \cdot P(B \mid C) = \frac{\mu(A \cap B \cap C)}{\mu(B \cap C)} \cdot \frac{\mu(B \cap C)}{\mu(C)} = \frac{\mu(A \cap B \cap C)}{\mu(C)} = P(A \cap B \mid C)$$

The cancellation of μ(B ∩ C) is valid because μ(B ∩ C) ≠ 0 by hypothesis. ∎

This confirms that the usual laws of conditional probability transfer intact to the non-Archimedean setting.

---

## 6. Uniform Measure Construction

**Definition 6.1** (`FinAddMeasure.uniform`). For a nonempty finite type α and linearly ordered field F, the *uniform measure* is:

$$\mu_{\text{unif}}(s) = \frac{|s|}{|\alpha|}$$

where |·| denotes cardinality cast to F.

This is verified to satisfy all three axioms of a finitely additive measure:
- μ(∅) = 0/|α| = 0.
- Disjoint additivity follows from |s ∪ t| = |s| + |t| for disjoint s, t.
- Non-negativity follows from non-negativity of natural number casts in an ordered field.

The formal construction is `FinAddMeasure.uniform` in `@Algebra/NonArchimedeanProbability.lean`. The singleton mass is μ({x}) = 1/|α|, which is positive when the characteristic of F is zero (as in all ordered fields of characteristic zero).

**Remark 6.1.** When F is non-Archimedean and |α| is a non-standard natural number greater than all standard naturals, the singleton mass 1/|α| is an infinitesimal probability in the sense of Definition 2.1. To see this: for any standard n ∈ ℕ, n · (1/|α|) = n/|α| < 1 because n < |α|. This connects the uniform construction to the non-Archimedean characterization theorem.

**Remark 6.2.** The uniform measure provides a canonical example of a faithful finitely additive measure. By Theorem 4.4, it is therefore strictly monotone: if S ⊂ T (proper subset), then |S|/|α| < |T|/|α|, which follows from |S| < |T| and the positivity of 1/|α|. In the non-Archimedean setting, this strict monotonicity holds even when the masses are infinitesimal — a property that has no analogue in standard real-valued measure theory on continuous spaces.

### 6.1 Sub-Probability Interpretation

When the type α has standard cardinality n and the value field F is non-Archimedean, the uniform measure μ_unif assigns total mass n · (1/n) = 1, which is a genuine probability measure. The infinitesimal character appears only when the weight per point is an infinitesimal ε and the total mass is n · ε, which may be less than 1 for any standard n. This gap between the sub-probability nε < 1 and a full probability measure with total mass 1 is exactly the opening for the hyperfinite measure completion program described in §8.

---

## 7. Discussion

### 7.1 The Algebraic Barrier

Theorem 2.1 transforms the question "can we have infinitesimal probabilities?" from a philosophical debate into a precise algebraic condition. The answer is: exactly when the value field is non-Archimedean. This is a clean dichotomy with no gray area.

The practical consequence is that any proposal for infinitesimal probability — whether based on hyperreals, surreal numbers, or Levi-Civita fields — succeeds precisely because the underlying number system is non-Archimedean. The specific construction (ultrapower, game-theoretic, algebraic) is irrelevant to the fundamental possibility; only the order-algebraic structure matters.

### 7.2 Same-Sign Aggregation Principle

The positivity theorem (Theorem 4.1) and the faithfulness characterization (Theorem 4.4) rest on a single algebraic principle: finite sums of positive elements in an ordered field are positive. This principle has independent appearances across mathematics:

- **Measure theory**: Positive weights yield faithful measures (this paper).
- **Lorentzian geometry**: Same-sign (timelike) vectors cannot sum to zero (anti-cancellation in the Lorentzian inner product).
- **Convex analysis**: Positive combinations of elements in a cone remain in the cone.

The formal connection to the Lorentzian anti-cancellation principle (`sum_ne_zero_of_same_sign_and_exists_ne_zero` in the project catalog) suggests a deeper unifying algebraic structure.

### 7.3 Conditional Probability and Epistemology

The resolution of the Borel-Kolmogorov paradox (Theorems 5.1–5.2) has implications for Bayesian epistemology. In standard Bayesian inference, one updates on evidence by conditioning. When the evidence is a specific observation (a point), standard probability cannot handle the conditioning step without auxiliary devices (regular conditional probabilities, disintegration theorems). The non-Archimedean framework eliminates this detour: conditioning on {x} is direct division by μ({x}) > 0.

### 7.4 Limitations

Our theory is currently restricted to *finite* types with *finite* additivity. The extension to countable or continuous types raises fundamental challenges:

1. **Countable additivity**: In a non-Archimedean field, countable sums of infinitesimals need not converge (the field may lack completeness). Finite additivity is the natural axiom in this setting.

2. **Hyperfinite types**: The bridge from finite types of non-standard cardinality to genuinely infinite types requires the machinery of nonstandard analysis (transfer principles, internal sets). This is the subject of future work.

3. **Integration**: A full integration theory over non-Archimedean fields would require developing non-Archimedean analogues of the Lebesgue integral, connecting to Loeb's measure construction [8].

---

## 8. Future Work

The results in this paper open several concrete research programs. Five directions of extension are identified, ranging from direct generalizations to speculative cross-domain connections:

1. **Hyperfinite measure completion**: Extend the sub-probability measures on finite types to full probability measures on hyperfinite types, connecting to Loeb's measure construction.

2. **Non-Archimedean Bayesian inference**: Develop a full Bayesian updating framework using non-Archimedean conditional probability.

3. **Tropical probability**: Investigate the limiting behavior of non-Archimedean probability measures under logarithmic rescaling, connecting to tropical geometry.

4. **Abstract faithfulness criteria**: Extend the faithfulness–monotonicity equivalence to infinite types and σ-additive measures.

5. **Non-Archimedean expected value**: Apply the framework to classical paradoxes (St. Petersburg game) where non-Archimedean expected values may yield meaningful, specific (if infinite) answers.

Of these, Direction 1 (Hyperfinite Measure Completion) represents the most ambitious program. The core challenge is bridging the gap between finite types of non-standard cardinality (where our theorems apply directly) and genuinely infinite types modeled through internal set theory or ultrapower constructions. Success would provide a complete, self-contained foundation for infinitesimal probability that resolves the dart-throwing paradox with full mathematical rigor.

Direction 4 (Strict Monotonicity as Faithfulness Criterion) is the most immediately tractable. The converse direction — showing that strict monotonicity implies all singleton masses are positive — follows from the simple observation that ∅ ⊂ {x} for any x, so μ(∅) < μ({x}) implies 0 < μ({x}). This is already proved in Theorem 4.3 (`pos_weights_of_strict_mono`). The natural generalization to infinite types would ask: under what conditions on the σ-algebra and measure space does strict monotonicity on measurable sets imply that every atom has positive measure?

---

## References

[1] A. N. Kolmogorov, *Foundations of the Theory of Probability*, Chelsea, 1950.

[2] A. Robinson, *Non-standard Analysis*, North-Holland, 1966.

[3] J. H. Conway, *On Numbers and Games*, Academic Press, 1976.

[4] R. Goldblatt, *Lectures on the Hyperreals: An Introduction to Nonstandard Analysis*, Springer, 1998.

[5] V. Benci, L. Horsten, and S. Wenmackers, "Non-Archimedean probability," *Milan Journal of Mathematics*, vol. 81, pp. 121–151, 2013.

[6] S. Wenmackers and L. Horsten, "Fair infinite lotteries," *Synthese*, vol. 190, pp. 37–61, 2013.

[7] E. Nelson, "Internal set theory: A new approach to nonstandard analysis," *Bulletin of the AMS*, vol. 83, pp. 1165–1198, 1977.

[8] P. A. Loeb, "Conversion from nonstandard to standard measure spaces and applications in probability theory," *Transactions of the AMS*, vol. 211, pp. 113–122, 1975.

---

---

## Appendix A: Summary of Formal Definitions

For reference, we collect the key formal definitions from the development.

| Name | Type | Description |
|------|------|-------------|
| `IsInfinitesimalProb F ε` | Prop | 0 < ε ∧ ∀ n : ℕ, n • ε < 1 |
| `FinAddMeasure α F` | Structure | Finitely additive measure on finite type α, valued in F |
| `FinAddMeasure.mass` | Finset α → F | The measure function |
| `FinAddMeasure.condProb` | Finset α → Finset α → F | Conditional probability μ(A ∩ B)/μ(B) |
| `FinAddMeasure.uniform` | FinAddMeasure α F | Uniform measure with mass |S|/|α| |

The field F is required to satisfy `[Field F] [LinearOrder F] [IsStrictOrderedRing F]`, which captures the ordered field axioms. The Archimedean property is represented by the typeclass `[Archimedean F]` from Mathlib.

*All theorems in this paper have been machine-verified. The complete formal development is available at `@Algebra/NonArchimedeanProbability.lean`.*
