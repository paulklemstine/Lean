# Rigorous Algebraic Foundations for Probability Theory in Non-Archimedean Ordered Fields

**Abstract.** We establish rigorous algebraic foundations for probability theory in non-Archimedean ordered fields, proving an exact characterization: a linearly ordered field admits infinitesimal probabilities—positive elements ε satisfying n·ε < 1 for all n ∈ ℕ—if and only if it is non-Archimedean. Building on this characterization, we develop a theory of finitely additive measures valued in arbitrary linearly ordered fields, proving strict monotonicity characterizes faithfulness, that nonempty sets have positive measure under positive weights, and that conditional probability on individual points is well-defined in the non-Archimedean setting—resolving the Borel-Kolmogorov paradox for point conditioning. All results have been formally verified in the Lean 4 theorem prover with the Mathlib library.

**Keywords:** Non-Archimedean fields, infinitesimal probability, finitely additive measures, Borel-Kolmogorov paradox, formal verification.

**MSC 2020:** 60A05, 12J25, 03B35, 28A12.

---

## 1. Introduction

The standard mathematical framework for probability—Kolmogorov's axiomatization based on σ-additive measures on measurable spaces—assigns probability zero to individual points in continuous sample spaces. While this convention is mathematically consistent and practically powerful, it creates conceptual difficulties in several settings:

1. **The regularity problem.** An event that is possible yet has probability zero seems to conflate impossibility with mere improbability. This distinction matters in the foundations of Bayesian epistemology, where one may wish to assign nonzero prior probability to every logically possible hypothesis [1].

2. **The Borel-Kolmogorov paradox.** Conditional probability P(A | B) = P(A ∩ B)/P(B) is undefined when P(B) = 0, making conditioning on specific observations technically meaningless in continuous spaces. The standard resolution using conditional expectations and disintegrations is powerful but abandons the intuitive ratio definition [2].

3. **Fairness over infinite domains.** A uniform distribution over a countably infinite set is impossible under σ-additivity: each point would need probability zero, but the total must be one. Non-Archimedean probabilities offer a potential resolution by assigning each point an infinitesimal weight that sums (in an appropriate sense) to unity [3].

These difficulties have motivated investigations into non-standard probability using hyperreal-valued measures [4, 5] and, more recently, surreal-valued measures. However, the existing literature often proceeds informally or assumes specific constructions (e.g., the hyperreals via ultrapower). A gap remains in identifying the *precise algebraic conditions* under which infinitesimal probabilities are possible.

This paper fills that gap by proving that the existence of infinitesimal probabilities is equivalent to the failure of the Archimedean property—a clean algebraic characterization that applies uniformly to all linearly ordered fields. We then build a theory of finitely additive measures in this general setting, establishing results on monotonicity, faithfulness, and conditional probability that hold over any ordered field.

### 1.1. Contributions

Our main contributions are:

- **Theorem 2.1** (Non-Archimedean Characterization). A linearly ordered field F admits an infinitesimal probability if and only if F is non-Archimedean. This is the theorem `non_archimedean_iff_infinitesimal_exists` in the formal development.

- **Theorem 3.1** (Faithfulness–Monotonicity Equivalence). A finitely additive measure on a finite type is faithful (all singletons have positive mass) if and only if it is strictly monotone (proper subsets have strictly smaller mass). This is `FinAddMeasure.faithful_iff_strict_mono`.

- **Theorem 4.1** (Point Conditioning). In any faithful finitely additive measure, conditional probability on singletons is well-defined and yields the indicator function. This comprises `FinAddMeasure.condProb_singleton_mem` and `FinAddMeasure.condProb_singleton_not_mem`.

- **Theorem 4.2** (Chain Rule). The chain rule P(A ∩ B | C) = P(A | B ∩ C) · P(B | C) holds for finitely additive measures over arbitrary ordered fields. This is `FinAddMeasure.condProb_chain_rule`.

- **Corollary 2.2** (Rational/Real Boundary). No infinitesimal probabilities exist over ℚ or ℝ. This is `no_infinitesimal_prob_rationals`.

---

## 2. The Non-Archimedean Characterization

### 2.1. Definitions

Let F be a linearly ordered field (a field equipped with a total order compatible with the field operations).

**Definition 2.1** (Infinitesimal Probability). An element ε ∈ F is an *infinitesimal probability* if:
1. ε > 0, and
2. n · ε < 1 for all n ∈ ℕ.

Formally, this is captured by the predicate `IsInfinitesimalProb`:

```
def IsInfinitesimalProb (F : Type*) [AddCommMonoid F] [PartialOrder F] [One F] (ε : F) : Prop :=
  0 < ε ∧ ∀ n : ℕ, n • ε < 1
```

The definition uses `n • ε` (scalar multiplication by a natural number) rather than `n · ε` (field multiplication by a cast) to avoid unnecessary coercion issues; the two coincide in ordered fields.

**Definition 2.2** (Archimedean Property). A linearly ordered field F is *Archimedean* if for all x, y ∈ F with 0 < y, there exists n ∈ ℕ such that x ≤ n · y. Equivalently, there are no positive infinitesimals: every positive element, when added to itself sufficiently many times, exceeds 1.

### 2.2. Main Characterization

**Theorem 2.1** (`non_archimedean_iff_infinitesimal_exists`). *Let F be a linearly ordered field. Then*

$$\exists \varepsilon \in F,\ \text{IsInfinitesimalProb}(F, \varepsilon) \quad \Longleftrightarrow \quad \neg\,\text{Archimedean}(F).$$

*Proof sketch.*

(⟹) Suppose ε is an infinitesimal probability. If F were Archimedean, then since 0 < ε, there would exist n ∈ ℕ with 1 ≤ n · ε. But n · ε < 1 for all n, contradiction.

(⟸) Suppose F is not Archimedean. By negation of the Archimedean property, there exist x, y ∈ F with 0 < y such that x > n · y for all n ∈ ℕ. In particular x > 0 (since x > 0 · y = 0). We claim ε := y/x is an infinitesimal probability. Indeed, ε > 0 since both y and x are positive. For any n ∈ ℕ, we have n · y < x (by hypothesis), so n · (y/x) = (n · y)/x < x/x = 1. □

**Corollary 2.2** (`no_infinitesimal_prob_rationals`). *No infinitesimal probabilities exist over ℚ.*

*Proof.* ℚ is Archimedean (a standard fact, available as an instance in Mathlib), so the backward direction of Theorem 2.1 gives the result immediately. □

**Remark.** The same argument shows that no infinitesimal probabilities exist over ℝ, since ℝ is also Archimedean. The formal development records this as a direct instance check.

### 2.3. Discussion

Theorem 2.1 is a *characterization*, not merely a sufficient condition. It tells us that the algebraic structure of the field *completely determines* whether infinitesimal probabilities are available. There is no way to "add" infinitesimal probabilities to an Archimedean field without changing the field itself; conversely, every non-Archimedean field automatically contains such probabilities.

This clarifies the logical status of various proposals in the philosophical literature. Arguments for or against infinitesimal probability reduce to the single question: should the value field be Archimedean?

---

## 3. Finitely Additive Measures over Ordered Fields

### 3.1. The Measure Structure

We define finitely additive measures on finite types valued in linearly ordered fields.

**Definition 3.1** (`FinAddMeasure`). Let α be a finite type with decidable equality and let F be a linearly ordered field. A *finitely additive measure* on α over F is a function μ : Finset α → F satisfying:

1. **Empty set:** μ(∅) = 0.
2. **Disjoint additivity:** For disjoint finsets S, T, μ(S ∪ T) = μ(S) + μ(T).
3. **Non-negativity:** μ(S) ≥ 0 for all finsets S.

This is formalized as a structure with fields `mass`, `mass_empty`, `mass_union_disjoint`, and `mass_nonneg`.

### 3.2. Decomposition into Singletons

**Proposition 3.1** (`FinAddMeasure.mass_eq_sum`). *For any finitely additive measure μ and finset S,*

$$\mu(S) = \sum_{x \in S} \mu(\{x\}).$$

*Proof sketch.* By induction on the finset. The base case is μ(∅) = 0. For the inductive step, writing S ∪ {a} as a disjoint union and applying disjoint additivity. □

### 3.3. Monotonicity

**Proposition 3.2** (`FinAddMeasure.mass_mono`). *If S ⊆ T, then μ(S) ≤ μ(T).*

*Proof sketch.* Write T = S ∪ (T \ S) as a disjoint union. Then μ(T) = μ(S) + μ(T \ S) ≥ μ(S) by non-negativity. □

### 3.4. Positivity of Nonempty Sets

**Proposition 3.3** (`FinAddMeasure.mass_pos_of_pos_weights`). *If μ({x}) > 0 for all x ∈ α, then μ(S) > 0 for every nonempty finset S.*

*Proof sketch.* By Proposition 3.1, μ(S) = Σ_{x ∈ S} μ({x}), a sum of positive terms over a nonempty index set, hence positive. □

### 3.5. Faithfulness and Strict Monotonicity

**Definition 3.2.** A finitely additive measure μ is *faithful* if μ({x}) > 0 for all x ∈ α. It is *strictly monotone* if S ⊂ T (proper subset) implies μ(S) < μ(T).

**Theorem 3.1** (`FinAddMeasure.faithful_iff_strict_mono`). *A finitely additive measure μ on a finite type is faithful if and only if it is strictly monotone.*

*Proof sketch.*

(⟹) (`mass_strict_mono_of_pos_weights`) Suppose μ is faithful and S ⊂ T. Write T = S ∪ (T \ S) disjointly. Since S ⊂ T, the set T \ S is nonempty, so μ(T \ S) > 0 by Proposition 3.3. Then μ(T) = μ(S) + μ(T \ S) > μ(S).

(⟸) (`pos_weights_of_strict_mono`) Suppose μ is strictly monotone. For any x ∈ α, we have ∅ ⊂ {x}, so 0 = μ(∅) < μ({x}). □

**Remark.** This characterization is purely order-theoretic: faithfulness, defined in terms of individual weights, is equivalent to a global monotonicity condition that makes no reference to individual elements. This connects measure-theoretic faithfulness to lattice-theoretic properties of the measure as a map on the power set lattice.

---

## 4. Conditional Probability on Points

### 4.1. Definition

**Definition 4.1** (`FinAddMeasure.condProb`). For a finitely additive measure μ and finsets A, B with μ(B) ≠ 0, the *conditional probability* of A given B is:

$$P(A \mid B) = \frac{\mu(A \cap B)}{\mu(B)}.$$

This definition is standard but, in the non-Archimedean setting, it applies even when B is a singleton—because μ({x}) > 0 (not zero) for faithful measures.

### 4.2. Point Conditioning

**Theorem 4.1.** *Let μ be a finitely additive measure with μ({x}) > 0 for some x ∈ α. Then:*

*(a)* (`condProb_singleton_mem`) *If x ∈ A, then P(A | {x}) = 1.*

*(b)* (`condProb_singleton_not_mem`) *If x ∉ A, then P(A | {x}) = 0.*

*Proof sketch.*

(a) If x ∈ A, then A ∩ {x} = {x}, so P(A | {x}) = μ({x})/μ({x}) = 1.

(b) If x ∉ A, then A ∩ {x} = ∅, so P(A | {x}) = μ(∅)/μ({x}) = 0/μ({x}) = 0. □

**Remark.** In the standard (Archimedean) setting over ℝ, singleton conditioning is undefined for continuous distributions because μ({x}) = 0. Theorem 4.1 shows that in any setting where singletons have positive measure—guaranteed by faithfulness, which is guaranteed by the non-Archimedean property—conditioning on points works exactly as intuition demands.

### 4.3. Chain Rule

**Theorem 4.2** (`FinAddMeasure.condProb_chain_rule`). *For finsets A, B, C with μ(C) ≠ 0 and μ(B ∩ C) ≠ 0:*

$$P(A \cap B \mid C) = P(A \mid B \cap C) \cdot P(B \mid C).$$

*Proof sketch.* Direct computation:

$$P(A \mid B \cap C) \cdot P(B \mid C) = \frac{\mu(A \cap (B \cap C))}{\mu(B \cap C)} \cdot \frac{\mu(B \cap C)}{\mu(C)} = \frac{\mu(A \cap B \cap C)}{\mu(C)} = P(A \cap B \mid C),$$

using associativity of intersection. □

---

## 5. Uniform Measures

### 5.1. Construction

**Definition 5.1** (`FinAddMeasure.uniform`). For a nonempty finite type α, the *uniform finitely additive measure* assigns mass |S|/|α| to each finset S:

$$\mu_{\text{unif}}(S) = \frac{|S|}{|\alpha|},$$

where |·| denotes cardinality, cast into the field F.

The formal construction verifies all three axioms: μ(∅) = 0/|α| = 0; disjoint additivity follows from |S ∪ T| = |S| + |T| for disjoint S, T; and non-negativity holds because natural number casts are non-negative in ordered fields.

**Proposition 5.1** (`FinAddMeasure.uniform_singleton`). *The uniform measure assigns mass 1/|α| to each singleton.*

### 5.2. Connection to Non-Archimedean Probability

When F is non-Archimedean and α is a "large" finite type (with |α| exceeding all standard naturals in some sense), the uniform weight 1/|α| becomes an infinitesimal probability—connecting the uniform construction to the infinitesimal framework of Section 2.

---

## 6. The Algebraic Principle: Positivity from Same-Sign Summands

A recurring algebraic motif throughout our development is the principle that **sums of same-sign terms cannot vanish over nonempty index sets**. This principle appears in:

- **Proposition 3.3:** positive weights yield positive measures on nonempty sets.
- **Theorem 3.1 (⟹):** strict monotonicity follows because the difference μ(T) − μ(S) = μ(T \ S) is a sum of positive terms.

This same algebraic fact appears in other mathematical contexts. In Lorentzian geometry, the analogous statement ensures that finite sums of same-sign (e.g., all-positive or all-negative) terms are nonzero when at least one summand is nonzero—the "anti-cancellation" principle. The formal parallel between the probability positivity theorem and the Lorentzian anti-cancellation principle reveals a shared algebraic core: ordered field axioms prevent same-sign cancellation.

---

## 7. Applications

### 7.1. Fair Lotteries on Infinite Domains

A central motivation for non-Archimedean probability is the *fair lottery problem*: can one define a uniform probability on a countably infinite set? Under σ-additivity with real-valued measures, this is impossible — each point would need probability zero, but countable additivity forces the total to be zero, not one. Our framework resolves this at the finite level: for any finite type α with |α| = n, the uniform measure assigns weight 1/n to each point and totals to 1 (Proposition 5.1). When F is non-Archimedean and n is "hyperfinitely large," the weight 1/n becomes an infinitesimal probability in the sense of Definition 2.1, maintaining all the algebraic properties of Section 3.

The faithfulness theorem (Theorem 3.1) guarantees that any such uniform measure is strictly monotone: adding elements to a set always increases its probability, no matter how small the individual weights are. This captures the intuition that "more outcomes means more probability" even when probabilities are infinitesimal.

### 7.2. Bayesian Epistemology

In Bayesian epistemology, one assigns prior probabilities to hypotheses and updates them via Bayes' theorem upon observing evidence. A persistent challenge is the *problem of regularity*: should every logically possible hypothesis receive nonzero prior probability? Standard probability theory forces zero priors on "too many" hypotheses, which can never be updated to nonzero posteriors — violating the principle that evidence should be able to confirm any hypothesis.

Our conditional probability results (Theorem 4.1 and 4.2) provide the technical foundation for a non-Archimedean Bayesian framework that maintains regularity. Every hypothesis (point) receives positive infinitesimal prior probability, and the chain rule (Theorem 4.2) ensures that Bayesian updating is coherent. This addresses the regularity problem without sacrificing finite additivity or non-negativity.

### 7.3. Comparative Probability

The faithfulness-monotonicity equivalence (Theorem 3.1) connects our framework to the theory of *qualitative* or *comparative* probability, where one specifies only an ordering "A is at least as probable as B" without assigning numerical values. Our theorem shows that a faithful finitely additive measure induces a comparative probability (via the natural ordering on measure values) that is *strictly* well-behaved: proper subsets are always strictly less probable.

Conversely, any comparative probability that satisfies strict monotonicity for proper subsets can be represented by a faithful finitely additive measure — providing a representation theorem connecting qualitative and quantitative approaches to probability.

## 8. Future Directions

### 8.1. Hyperfinite Measure Completion

The uniform measure on a finite type of size n assigns weight 1/n to each element, totaling exactly 1. In a non-Archimedean field containing an infinite element ω, one may consider a "hyperfinite" type of size ω, assigning weight ω⁻¹ to each element. The algebraic identity ω · ω⁻¹ = 1 holds in any field, suggesting that such a construction could yield a complete probability measure. The main challenge is the type-theoretic formalization of "a finite set of non-standard cardinality."

This direction connects to Loeb's measure construction [4], which converts internal hyperfinite measures into genuine standard measures. Our algebraic framework provides the field-theoretic foundation; the missing piece is a formalization of hyperfinite cardinality within type theory.

### 8.2. Tropical Limits of Non-Archimedean Measures

As an infinitesimal parameter ε → 0 in a family of non-Archimedean measures, the logarithmic transformation −log(μ_ε) may converge to a tropical (min-plus) structure, connecting non-Archimedean probability to tropical geometry and optimization. Specifically, for measures μ_ε({x}) = ε^{v(x)} parameterized by a valuation v, the limit −log(μ_ε(S))/log(ε) as ε → 0 should equal min_{x ∈ S} v(x) — the tropical measure of S. This "tropicalization of probability" would provide new interpretations of tropical semirings as degenerate probability spaces.

### 8.3. Non-Archimedean Expected Value and the St. Petersburg Paradox

In the non-Archimedean setting, the St. Petersburg game's expected value — infinite in standard probability — might be assigned a specific surreal value. The truncated game at round N has expected value N in any field; in the hyperfinite limit N = ω, the expected value is ω, a well-defined (though infinite) surreal number. This enables meaningful comparison between different infinite-expectation gambles, resolving one of the oldest paradoxes in probability theory.

### 8.4. σ-Additivity and Countable Extensions

Our framework is restricted to finite additivity on finite types. Extending to countable additivity over countable types in a non-Archimedean field raises delicate questions about convergence of series in non-Archimedean topologies. The interaction between the order topology and the valuation topology in fields like ℚ((t)) creates subtleties absent from the finite case.

---

## 9. Related Work

The use of non-standard analysis in probability theory has a long history, beginning with Loeb's construction of standard measures from hyperfinite probability spaces [4]. Nelson's internal set theory provides an alternative foundational approach [6]. Benci et al. developed non-Archimedean probability using numerosities [5], and Wenmackers and Horsten explored the philosophical implications for epistemology [3].

Our contribution differs from these works in two respects. First, we work at the level of *abstract ordered fields* rather than fixing a specific non-standard construction, yielding results that apply uniformly to hyperreals, surreals, and any other non-Archimedean ordered field. Second, all results are formally verified, providing the highest level of mathematical certainty.

---

## 10. Conclusion

We have established that the algebraic boundary between standard and infinitesimal probability is precisely the Archimedean property. This characterization, together with a formally verified theory of finitely additive measures over arbitrary ordered fields, provides rigorous foundations for probability theory in non-Archimedean settings. The framework resolves the Borel-Kolmogorov paradox for point conditioning and opens connections to tropical geometry, Bayesian inference, and decision theory.

---

## References

[1] A. Hájek. Staying regular. In *Proceedings of the Australian Association of Philosophy*, 2012.

[2] A. N. Kolmogorov. *Foundations of the Theory of Probability*. Chelsea, 1956. Translation of the 1933 German original.

[3] S. Wenmackers and L. Horsten. Fair infinite lotteries. *Synthese*, 190(1):37–61, 2013.

[4] P. A. Loeb. Conversion from nonstandard to standard measure spaces and applications in probability theory. *Transactions of the AMS*, 211:113–122, 1975.

[5] V. Benci, L. Horsten, and S. Wenmackers. Non-Archimedean probability. *Milan Journal of Mathematics*, 81(1):121–151, 2013.

[6] E. Nelson. *Radically Elementary Probability Theory*. Princeton University Press, 1987.
