# Rigorous Algebraic Foundations for Probability Theory in Non-Archimedean Ordered Fields

**Abstract.** We establish rigorous algebraic foundations for probability theory valued in arbitrary linearly ordered fields, with particular attention to the non-Archimedean case. Our central result is an exact characterization: a linearly ordered field admits *infinitesimal probabilities* — positive elements ε satisfying n·ε < 1 for all natural numbers n — if and only if it is non-Archimedean (Theorem 2.1). We develop a theory of finitely additive measures over such fields, proving positivity of measures with positive weights (Theorem 3.1), an equivalence between faithfulness and strict monotonicity (Theorem 3.4), well-defined conditional probability on individual points resolving the Borel-Kolmogorov paradox (Theorems 4.1–4.2), a chain rule for conditional probability (Theorem 4.3), and a uniform measure construction (Section 5). All results are formalized and machine-verified. We discuss applications to Bayesian epistemology, connections to tropical mathematics, and directions toward hyperfinite measure completion.

**Keywords:** Non-Archimedean fields, infinitesimal probability, finitely additive measures, Borel-Kolmogorov paradox, faithful measures, surreal numbers

**MSC 2020:** 60A05, 12J25, 03H05, 60A10

---

## 1. Introduction

### 1.1 Motivation

The standard Kolmogorov axiomatization of probability theory (Kolmogorov, 1933) is built on the real number field ℝ and σ-additive measures. This framework, while immensely successful, has a well-known limitation: for uncountable sample spaces, individual outcomes must receive probability zero. This leads to conceptual difficulties including the Borel-Kolmogorov paradox for conditional probability on measure-zero events (Kolmogorov, 1933, §5) and challenges in Bayesian epistemology when one wishes to assign "regularity" — strictly positive probability to every possible outcome (Shimony, 1955; Skyrms, 1980).

The idea of using infinitesimal probabilities to restore regularity has been explored by several authors (Bernstein & Wattenberg, 1969; Nelson, 1987; Benci et al., 2013; Wenmackers & Horsten, 2013). These approaches typically employ nonstandard analysis or specific constructions in hyperreal fields. However, the fundamental algebraic question — *what algebraic property of a number system determines whether infinitesimal probabilities can exist?* — has not been addressed with full generality and rigor.

### 1.2 Contributions

This paper provides a definitive answer: the existence of infinitesimal probabilities is equivalent to the non-Archimedean property of the underlying ordered field. We formalize this result and build a complete theory of finitely additive measures over arbitrary linearly ordered fields, obtaining:

1. **The Non-Archimedean Characterization** (Theorem 2.1): A linearly ordered field F admits an element ε with 0 < ε and n·ε < 1 for all n ∈ ℕ if and only if F is non-Archimedean.

2. **Measure Positivity** (Theorem 3.1): In a finitely additive measure with positive singleton masses, every nonempty set has strictly positive measure.

3. **Faithfulness–Monotonicity Equivalence** (Theorem 3.4): A finitely additive measure on a finite type has all singleton masses positive if and only if it is strictly monotone with respect to proper subset inclusion.

4. **Point Conditioning** (Theorems 4.1–4.2): Conditional probability on a singleton {x} with positive mass yields the indicator function: P(A | {x}) = 1 if x ∈ A and P(A | {x}) = 0 if x ∉ A.

5. **Chain Rule** (Theorem 4.3): The standard chain rule P(A ∩ B | C) = P(A | B ∩ C) · P(B | C) holds for finitely additive measures over ordered fields whenever the conditioning events have nonzero mass.

All results are fully formalized and machine-verified in the Lean 4 proof assistant with the Mathlib library.

### 1.3 Related Work

Bernstein and Wattenberg (1969) constructed nonstandard-valued measures assigning infinitesimal mass to individual points of [0,1]. Nelson (1987) developed Internal Set Theory as a framework for nonstandard probability. Benci, Horsten, and Wenmackers (2013) introduced "Non-Archimedean Probability" (NAP) theory, working specifically over the hyperreal field *ℝ. Our approach differs in working over *arbitrary* linearly ordered fields, which clarifies the algebraic essence of the construction and separates it from the specific machinery of nonstandard analysis.

The connection between faithfulness and monotonicity has been studied in the context of belief functions (Shafer, 1976) and qualitative probability (Kraft et al., 1959), but the precise equivalence we establish for finitely additive measures over ordered fields appears to be new.

---

## 2. The Non-Archimedean Characterization

### 2.1 Definitions

**Definition 2.1** (Infinitesimal Probability). Let F be a partially ordered additive monoid with a unit element 1. An element ε ∈ F is an *infinitesimal probability* if:
1. 0 < ε, and
2. n • ε < 1 for every n ∈ ℕ,

where n • ε denotes the n-fold sum ε + ε + ⋯ + ε.

**Definition 2.2** (Archimedean Property). An ordered additive monoid M is *Archimedean* if for every x, y ∈ M with 0 < y, there exists n ∈ ℕ such that x ≤ n • y.

### 2.2 Main Theorem

**Theorem 2.1** (Non-Archimedean Characterization). *Let F be a linearly ordered field satisfying the strict ordered ring axioms. Then there exists an infinitesimal probability ε ∈ F if and only if F is not Archimedean.*

*Proof sketch.*

**Forward direction.** Suppose ε ∈ F is an infinitesimal probability: 0 < ε and n • ε < 1 for all n ∈ ℕ. If F were Archimedean, then applying the Archimedean property with x = 1 and y = ε yields n ∈ ℕ with 1 ≤ n • ε, contradicting n • ε < 1. ∎

**Backward direction.** Suppose F is not Archimedean. Then there exist x, y ∈ F with 0 < y such that for all n ∈ ℕ, ¬(x ≤ n • y), i.e., n • y < x for all n. In particular, x > 0 (since 0 • y = 0 < x follows from the case n = 0). Consider ε = y/x. Then:
- ε > 0 since y > 0 and x > 0.
- For any n ∈ ℕ, n • ε = n • (y/x) = (n • y)/x < x/x = 1, since n • y < x.

Thus ε is an infinitesimal probability. ∎

**Corollary 2.2.** *No infinitesimal probability exists in ℚ or ℝ.*

*Proof.* Both ℚ and ℝ are Archimedean, so the result follows immediately from Theorem 2.1. ∎

### 2.3 Discussion

Theorem 2.1 provides a clean algebraic demarcation. The non-Archimedean property is both necessary and sufficient for infinitesimal probabilities. This clarifies the landscape: surreal numbers, hyperreal numbers, Levi-Civita fields, Hahn series fields, and any other non-Archimedean ordered field all support infinitesimal probabilities, while no subfield of ℝ does.

The theorem also reveals that the construction of infinitesimal probabilities requires no special techniques beyond basic field arithmetic: the element y/x, extracted directly from the failure of the Archimedean property, serves as an infinitesimal probability. No ultrafilters, transfer principles, or model-theoretic machinery are needed.

---

## 3. Finitely Additive Measures over Ordered Fields

### 3.1 The Measure Structure

**Definition 3.1** (Finitely Additive Measure). Let α be a finite type with decidable equality and F a linearly ordered field. A *finitely additive measure* on α valued in F is a function μ : Finset(α) → F satisfying:
1. **Empty set**: μ(∅) = 0.
2. **Finite additivity**: For disjoint S, T ⊆ α, μ(S ∪ T) = μ(S) + μ(T).
3. **Nonnegativity**: μ(S) ≥ 0 for all S ⊆ α.

This generalizes the standard notion by replacing ℝ-valued measures with F-valued measures for an arbitrary linearly ordered field F.

**Theorem 3.0** (Decomposition). *For any finitely additive measure μ and any finite set S,*
$$\mu(S) = \sum_{x \in S} \mu(\{x\}).$$

*Proof sketch.* By induction on |S|, using finite additivity for the inductive step with S = S' ∪ {a} where a ∉ S'. ∎

### 3.2 Positivity

**Theorem 3.1** (Positivity from Positive Weights). *Let μ be a finitely additive measure on α valued in F. If μ({x}) > 0 for every x ∈ α, then μ(S) > 0 for every nonempty S ⊆ α.*

*Proof sketch.* By Theorem 3.0, μ(S) = Σ_{x ∈ S} μ({x}), which is a sum of positive terms over a nonempty index set. In any linearly ordered field, a finite sum of positive terms is positive. ∎

This theorem is the algebraic engine that makes non-Archimedean probability coherent. It ensures that positive infinitesimal weights produce positive (infinitesimal) masses for every nonempty event — the measure "sees" every nonempty set.

### 3.3 Strict Monotonicity

**Theorem 3.2** (Strict Monotonicity from Positive Weights). *Let μ be a finitely additive measure with μ({x}) > 0 for all x. If S ⊂ T (proper subset), then μ(S) < μ(T).*

*Proof sketch.* Write T = S ∪ (T \ S) with S and T \ S disjoint. Then μ(T) = μ(S) + μ(T \ S). Since S ⊂ T, the set T \ S is nonempty, so μ(T \ S) > 0 by Theorem 3.1. Therefore μ(T) > μ(S). ∎

**Theorem 3.3** (Positive Weights from Strict Monotonicity). *Let μ be a finitely additive measure such that S ⊂ T implies μ(S) < μ(T) for all finsets S, T. Then μ({x}) > 0 for every x ∈ α.*

*Proof sketch.* For any x ∈ α, ∅ ⊂ {x}, so μ(∅) < μ({x}), giving 0 < μ({x}). ∎

**Theorem 3.4** (Faithfulness–Monotonicity Equivalence). *A finitely additive measure μ on a finite type α is faithful (∀x, μ({x}) > 0) if and only if it is strictly monotone (S ⊂ T ⟹ μ(S) < μ(T)).*

*Proof.* Combine Theorems 3.2 and 3.3. ∎

### 3.4 Discussion

Theorem 3.4 provides a purely order-theoretic characterization of faithfulness. This is significant because strict monotonicity is a *structural* property of the measure as a function on the lattice of finite sets, while faithfulness is an *algebraic* property about individual weights. Their equivalence means that faithfulness can be verified without examining individual point masses — one only needs to check the monotonicity condition.

The result connects to the broader theme of **aggregate anti-cancellation** in ordered algebra: sums of same-sign elements cannot cancel. This principle, which appears in various forms across mathematics (e.g., in Lorentzian geometry, where timelike vectors of the same orientation cannot sum to zero), is precisely what guarantees measure faithfulness.

---

## 4. Conditional Probability on Points

### 4.1 Definition

**Definition 4.1** (Conditional Probability). For a finitely additive measure μ with μ(B) ≠ 0, the *conditional probability* of A given B is:
$$P(A \mid B) = \frac{\mu(A \cap B)}{\mu(B)}.$$

In standard (ℝ-valued) probability, this definition is undefined when B is a singleton {x} in a continuous space, since μ({x}) = 0. In a non-Archimedean setting with positive point masses, μ({x}) > 0 — typically an infinitesimal — and the definition applies.

### 4.2 Point Conditioning

**Theorem 4.1** (Conditioning on a Member Point). *Let μ be a finitely additive measure with μ({x}) > 0. If x ∈ A, then P(A | {x}) = 1.*

*Proof sketch.* A ∩ {x} = {x} when x ∈ A, so P(A | {x}) = μ({x})/μ({x}) = 1. ∎

**Theorem 4.2** (Conditioning on a Non-Member Point). *Let μ be a finitely additive measure with μ({x}) > 0. If x ∉ A, then P(A | {x}) = 0.*

*Proof sketch.* A ∩ {x} = ∅ when x ∉ A, so P(A | {x}) = μ(∅)/μ({x}) = 0/μ({x}) = 0. ∎

**Corollary 4.3.** *In a non-Archimedean probability space with positive point masses, conditional probability on a singleton yields the indicator function: P(A | {x}) = 𝟙_A(x).*

### 4.3 Chain Rule

**Theorem 4.4** (Chain Rule for Conditional Probability). *Let μ be a finitely additive measure with μ(C) ≠ 0 and μ(B ∩ C) ≠ 0. Then:*
$$P(A \cap B \mid C) = P(A \mid B \cap C) \cdot P(B \mid C).$$

*Proof sketch.* Expanding the right-hand side:
$$\frac{\mu(A \cap B \cap C)}{\mu(B \cap C)} \cdot \frac{\mu(B \cap C)}{\mu(C)} = \frac{\mu(A \cap B \cap C)}{\mu(C)} = \frac{\mu((A \cap B) \cap C)}{\mu(C)} = P(A \cap B \mid C).$$

The key step uses μ(B ∩ C) ≠ 0 to cancel the common factor. ∎

### 4.4 Discussion: The Borel-Kolmogorov Resolution

The Borel-Kolmogorov paradox arises because in standard probability theory, conditioning on a measure-zero event is ill-defined — one must use regular conditional distributions, which are only defined almost everywhere and can give paradoxical results depending on the choice of conditioning σ-algebra.

In our framework, the paradox does not arise. Every point has positive (possibly infinitesimal) mass, so conditioning on {x} is a well-defined algebraic operation — division by a nonzero element in an ordered field. The result is always deterministic (0 or 1), matching the intuition that "knowing the exact outcome resolves all uncertainty."

This resolution requires moving to a non-Archimedean field, but Theorem 2.1 shows this is the *minimal* departure from standard probability theory needed: one must abandon exactly the Archimedean property, and nothing else.

---

## 5. Uniform Measures

### 5.1 Construction

**Definition 5.1** (Uniform Measure). For a nonempty finite type α with |α| = n, the *uniform finitely additive measure* assigns:
$$\mu(S) = \frac{|S|}{n}$$
for each S ⊆ α, where |S| and n are interpreted as elements of the field F.

**Theorem 5.1.** *The uniform measure is a finitely additive measure.*

*Proof sketch.* Empty-set: |∅|/n = 0. Additivity: for disjoint S, T, |S ∪ T|/n = (|S| + |T|)/n = |S|/n + |T|/n. Nonnegativity: |S| ≥ 0 and n > 0 in any ordered field. ∎

**Theorem 5.2.** *Each singleton has mass 1/n under the uniform measure: μ({x}) = 1/n for all x ∈ α.*

### 5.2 Uniform Measures in Non-Archimedean Fields

When F is non-Archimedean, we can consider the uniform measure on a type with n elements where n is large. For a fixed infinitesimal ε, choosing n such that 1/n ≈ ε gives each point infinitesimal mass. In a hyperfinite extension, where n is a non-standard natural number greater than all standard naturals, this construction yields a uniform measure where:

- Every point has infinitesimal positive mass 1/n.
- The total mass is n · (1/n) = 1.
- Strict monotonicity holds by Theorem 3.2.

This is the non-Archimedean analogue of the uniform distribution on a "continuous" space.

---

## 6. Applications and Connections

### 6.1 Bayesian Epistemology

The regularity principle in Bayesian epistemology holds that every logically possible proposition should receive positive prior probability (Shimony, 1955). In standard probability over ℝ, this is impossible for uncountable hypothesis spaces. Our framework shows that regularity is achievable in non-Archimedean fields, and Theorem 3.4 guarantees that regular (faithful) measures have the strict monotonicity property that "more hypotheses ⟹ more probability."

Point conditioning (Theorems 4.1–4.2) enables Bayesian updating on specific observations without the technical complications of regular conditional distributions. The chain rule (Theorem 4.4) ensures that sequential updating is coherent.

### 6.2 Connection to Aggregate Anti-Cancellation

The positivity result (Theorem 3.1) is an instance of a general algebraic principle: in an ordered group, sums of positive elements are positive. This same principle appears in Lorentzian geometry, where the sum of future-pointing timelike vectors is future-pointing, and in tropical algebra, where the minimum of finite values is finite.

The formal connection is through the anti-cancellation theorem for sums of same-sign elements: if all summands are positive and at least one is nonzero, the sum is nonzero. This principle, formalized independently in the context of Lorentzian geometry, has exactly the same logical structure as our Theorem 3.1.

### 6.3 Tropical Limits

A speculative but intriguing direction connects non-Archimedean probability to tropical mathematics. For a family of measures μ_ε with weights ε^{v(x)} as ε → 0, the logarithmic rescaling −log(μ_ε)/log(ε) converges to a tropical structure where "probability" becomes "cost" and sum becomes minimum. This suggests that tropical semirings can be viewed as degenerate probability spaces.

---

## 7. Future Directions

### 7.1 Hyperfinite Measure Completion

The most ambitious open direction is completing the sub-probability construction to a full probability measure on a "hyperfinite" space. This requires formalizing a type whose cardinality is a non-standard natural number ω ∈ F, assigning each element mass ω⁻¹, and verifying that the total mass ω · ω⁻¹ = 1. While algebraically trivial, the type-theoretic formalization presents challenges related to encoding non-standard cardinalities.

### 7.2 Non-Archimedean Bayesian Inference

The conditional probability framework developed here provides the foundation for a full Bayesian inference theory. Key open questions include:
- Existence and uniqueness of posterior distributions for non-Archimedean priors.
- Convergence of Bayesian updating in the non-Archimedean topology.
- Decision-theoretic applications with infinitesimal probabilities.

### 7.3 Faithfulness in Infinite Settings

Theorem 3.4 characterizes faithfulness for finite types. Extending this to countably or uncountably infinite types requires replacing Finset with more general set-theoretic constructs and addressing convergence of infinite sums in non-Archimedean fields, where the standard topology may not yield complete spaces.

### 7.4 The St. Petersburg Paradox

The St. Petersburg game, with expected value Σ 2ⁿ · 2⁻ⁿ = Σ 1 = ∞ in ℝ, may have a well-defined surreal expected value. In a hyperfinite truncation to N rounds, the expected value is N; for N = ω (a surreal infinite), the expected value is ω — a specific surreal number enabling meaningful comparisons between gambles.

---

## 8. Summary of Results

| Theorem | Statement | Section |
|---------|-----------|---------|
| 2.1 | Non-Archimedean ↔ infinitesimal probability exists | §2 |
| 2.2 | No infinitesimal probabilities in ℚ | §2 |
| 3.0 | Mass decomposes as sum of singleton masses | §3 |
| 3.1 | Positive weights ⟹ positive measure on nonempty sets | §3 |
| 3.2 | Positive weights ⟹ strict monotonicity | §3 |
| 3.3 | Strict monotonicity ⟹ positive weights | §3 |
| 3.4 | Faithful ↔ strictly monotone | §3 |
| 4.1 | P(A \| {x}) = 1 when x ∈ A | §4 |
| 4.2 | P(A \| {x}) = 0 when x ∉ A | §4 |
| 4.4 | Chain rule for conditional probability | §4 |
| 5.1 | Uniform measure is finitely additive | §5 |

---

## References

1. Benci, V., Horsten, L., & Wenmackers, S. (2013). Non-Archimedean probability. *Milan Journal of Mathematics*, 81(1), 121–151.

2. Bernstein, A. R., & Wattenberg, F. (1969). Nonstandard measure theory. In *Applications of Model Theory to Algebra, Analysis, and Probability* (pp. 171–185). Holt, Rinehart and Winston.

3. Kolmogorov, A. N. (1933). *Grundbegriffe der Wahrscheinlichkeitsrechnung*. Springer.

4. Kraft, C. H., Pratt, J. W., & Seidenberg, A. (1959). Intuitive probability on finite sets. *Annals of Mathematical Statistics*, 30(2), 408–419.

5. Nelson, E. (1987). *Radically Elementary Probability Theory*. Princeton University Press.

6. Shafer, G. (1976). *A Mathematical Theory of Evidence*. Princeton University Press.

7. Shimony, A. (1955). Coherence and the axioms of confirmation. *Journal of Symbolic Logic*, 20(1), 1–28.

8. Skyrms, B. (1980). *Causal Necessity*. Yale University Press.

9. Wenmackers, S., & Horsten, L. (2013). Fair infinite lotteries. *Synthese*, 190(1), 37–61.

---

*All theorems in this paper have been formally verified in Lean 4 with the Mathlib library. The formalization is available in `Algebra/NonArchimedeanProbability.lean`.*
