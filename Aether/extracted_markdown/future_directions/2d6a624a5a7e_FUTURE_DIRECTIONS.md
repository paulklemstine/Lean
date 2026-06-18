# Future Directions: Formal Epistemics of Automated Mathematics

This document outlines breakthrough research opportunities opened by the formalization of adversarial stress-testing for conjecture families.

---

## 1. Minimax-Optimal Counterexample Generators Under Finite Budget

**Hypothesis:** For any finite hypothesis class $H$ and budget $k$, there exists a test set $T^* \subseteq U$ with $|T^*| \leq k$ that maximizes the number of eliminated false hypotheses. Moreover, a greedy algorithm achieves a $(1 - 1/e)$-approximation.

**Proof Strategy:**
- Model the problem as submodular set function maximization: define $f(T) = |\text{killedBy}(H, T)|$.
- Prove $f$ is monotone and submodular over `Finset α`.
- Formalize the greedy algorithm and prove the $(1 - 1/e)$ bound via Nemhauser's theorem.
- This connects directly to our `killedBy_mono` theorem and extends it to optimization.

**Cross-Domain Connection:** Active learning query synthesis, sensor placement, influence maximization in networks.

**Concrete Lean Target:**
```
theorem greedy_approximation (H : Finset ι) (eval : ι → α → Bool) (k : ℕ) :
  ∃ T : Finset α, T.card ≤ k ∧
    (1 - (1 - 1/k)^k) * optimalKills H eval k ≤ killedByCount eval H T
```

---

## 2. VC-Dimension-Style Sample Complexity for Conjecture Screening

**Hypothesis:** If the hypothesis class $H$ has VC-dimension $d$, then $O(d/\varepsilon \cdot \log(d/\delta))$ random test points suffice to ensure that any surviving hypothesis is $\varepsilon$-approximately true with probability $1 - \delta$.

**Proof Strategy:**
- Define VC-dimension for Boolean hypothesis classes over finite types.
- Formalize the Sauer-Shelah lemma: growth function $\Pi_H(m) \leq \sum_{i=0}^{d} \binom{m}{i}$.
- Prove the uniform convergence bound via double-sampling argument.
- Connect to our `falsePositiveCount_antitone`: random enlargement of $T$ gives probabilistic monotone decrease.

**Cross-Domain Connection:** Statistical learning theory (Vapnik-Chervonenkis theory), PAC learning, empirical process theory.

**Concrete Lean Target:**
```
theorem vc_screening_bound (H : Finset (α → Bool)) (d : ℕ) (hvc : vcDim H = d) 
    (ε δ : ℝ) (hε : 0 < ε) (hδ : 0 < δ) :
  ∃ m : ℕ, ∀ T : Finset α, T.card ≥ m →
    Prob[∀ h surviving T, errorRate h ≤ ε] ≥ 1 - δ
```

---

## 3. Adversarial Stress Testing for Algebraic Identities Over Finite Semirings

**Hypothesis:** For polynomial identities over a finite semiring $R$, the Schwartz-Zippel lemma gives explicit bounds on the probability that a random evaluation point fails to detect a non-identity. This can be formalized as a concrete instantiation of our framework where `eval i a` checks whether polynomial $i$ vanishes at point $a$.

**Proof Strategy:**
- Define hypothesis class as `Finset (MvPolynomial σ R)` for finite $R$.
- Set `eval p a = (MvPolynomial.eval a p == 0)`.
- Prove that for degree-$d$ polynomials over $\mathbb{F}_q$, a random test point detects non-identity with probability $\geq 1 - d/q$.
- Combine with `falsePositiveCount_antitone` to get explicit bounds on residual false identities after $k$ random evaluations.

**Cross-Domain Connection:** Polynomial identity testing (PIT), algebraic circuit complexity, derandomization (Kabanets-Impagliazzo), cryptographic protocol verification.

**Concrete Lean Target:**
```
theorem schwartz_zippel_stress_test (R : Type*) [Field R] [Fintype R]
    (P : Finset (MvPolynomial (Fin n) R)) (k : ℕ) :
  ∀ p ∈ P, p ≠ 0 → degree p ≤ d →
    Prob[survivesBool evalPoly p (randomTestSet k)] ≤ (d / Fintype.card R) ^ k
```

---

## 4. Galois Connection Between Proof Search and Falsification Spaces

**Hypothesis:** There exists a Galois connection between the lattice of test sets (ordered by inclusion) and the lattice of surviving hypothesis sets (ordered by reverse inclusion). The closure operators induced by this connection characterize "proof-irreducible" test sets and "test-irreducible" hypothesis classes.

**Proof Strategy:**
- Define the maps $\sigma : \mathcal{P}(U) \to \mathcal{P}(H)^{op}$ sending $T \mapsto \text{survivors}(T)$ and $\tau : \mathcal{P}(H)^{op} \to \mathcal{P}(U)$ sending a hypothesis subset to its minimal refutation set.
- Prove $T \subseteq \tau(S) \iff \sigma(T) \supseteq S$ (Galois connection).
- Our `falsePositiveCount_antitone` is exactly the monotonicity of $\sigma$.
- The fixed points of $\sigma \circ \tau$ are "complete test suites" — minimal test sets that detect all detectable falsehoods.

**Cross-Domain Connection:** Formal concept analysis, domain theory, abstract interpretation in program analysis, categorical semantics.

**Concrete Lean Target:**
```
theorem stress_test_galois_connection :
  GaloisConnection (survivors eval · : Finset α → (Finset ι)ᵒᵈ) (minRefuters eval ·)
```

---

## 5. Certified Pipeline Composition: Sequential Stress Test Stages

**Hypothesis:** If a conjecture-generation pipeline has $n$ sequential stress-test stages with test sets $T_1, \ldots, T_n$, then the composite false-positive rate is bounded by the product of individual pass-through rates. Formally, if stage $i$ independently has pass-through rate $\leq p_i$, then the composite rate is $\leq \prod_i p_i$.

**Proof Strategy:**
- Model a pipeline as a sequence of filters: `Pipeline := List (Finset α)`.
- Define composite survival: `compositeSurvives eval i P := ∀ T ∈ P, survivesBool eval i T`.
- Prove that `compositeSurvives eval i (T₁ ++ T₂) ↔ compositeSurvives eval i T₁ ∧ compositeSurvives eval i T₂`.
- For independent random stages, prove the multiplicative bound on false-positive rates.
- This extends `falsePositiveCount_antitone` from a single enlargement to pipeline composition.

**Cross-Domain Connection:** Reliability engineering (series systems), cascaded classifiers in ML, defense-in-depth in security, multi-stage hypothesis testing.

**Concrete Lean Target:**
```
theorem pipeline_false_positive_bound (eval : ι → α → Bool) (H : Finset ι)
    (stages : List (Finset α)) (U : Finset α) :
  pipelineFalsePositiveCount eval H U stages ≤ 
    H.card * (stages.map (fun T => passThroughRate eval H T)).prod
```

---

## Meta-Direction: Toward a Theory of Research Pipeline Correctness

The overarching vision is to make the *process* of mathematical discovery itself an object of rigorous study. Each direction above contributes a piece:

1. **Optimization** (Direction 1) tells us how to allocate finite computational resources.
2. **Sample complexity** (Direction 2) tells us how many tests suffice for statistical confidence.
3. **Algebraic instantiation** (Direction 3) grounds the theory in concrete mathematical practice.
4. **Galois theory** (Direction 4) reveals the deep structure connecting tests and hypotheses.
5. **Pipeline composition** (Direction 5) scales from individual tests to industrial workflows.

Together, these form the foundation of **formal epistemics of automated mathematics** — a field where theorem-proving pipelines are not just engineering artifacts but objects of mathematical proof.
