# Phase-Aware Lemma Synthesis for AI Theorem Provers: A Formal Theory of Reasoning Phase Transitions

## Abstract

We develop a formally verified mathematical theory of *reasoning phase transitions* in automated theorem proving (ATP). We introduce a framework in which theorem instances are classified into tractable, transitional, and intractable phases based on semantic complexity, and a *lemma benefit model* captures how intermediate lemma synthesis reduces effective search complexity. We prove five main theorems: (1) monotone upward closure of the synthesis assignment — once a problem requires lemma synthesis, all harder problems do too; (2) strict complexity reduction above a certified compression threshold; (3) resource allocation dominance — phase-aware provers solve problems within budget that direct-search provers cannot; (4) a cross-domain bridge showing that lemma synthesis lowers "reasoning energy," establishing a formal dictionary to statistical physics; and (5) a partition theorem decomposing theorem space into disjoint phase strata. All results are machine-verified in Lean 4 with Mathlib, and we extract a certified decision procedure for search-action selection. We provide computational experiments demonstrating exponential separation between direct and phase-aware strategies.

**Keywords:** automated theorem proving, proof complexity, phase transitions, adaptive search, lemma synthesis, semantic complexity, formal verification, curriculum learning, statistical physics of reasoning

---

## 1. Introduction

### 1.1 Motivation

Automated theorem provers face a fundamental architectural choice: should they search for proofs directly, or should they first synthesize intermediate lemmas that decompose the problem? In practice, this choice is made heuristically — by fixed timeouts, tactic lists, or learned policies. There is no principled theory of *when* lemma synthesis is beneficial and *why*.

We address this gap by developing a mathematical framework that identifies *phase transitions* in proof search. Inspired by phase transitions in statistical physics — where macroscopic properties of matter change discontinuously as a control parameter crosses a threshold — we show that the effectiveness of proof search strategies undergoes analogous transitions as theorem complexity increases.

### 1.2 Contributions

1. **Formal definitions** of Phase, LemmaBenefit, effectiveComplexity, CompressionThreshold, PhaseAwarePolicy, and reasoningEnergy, providing a mathematical vocabulary for phase-aware ATP.

2. **Five main theorems** (all machine-verified):
   - Upward closure of synthesis assignment (Theorem 1)
   - Strict complexity reduction above threshold (Theorem 2)
   - Resource allocation dominance (Theorem 3)
   - Synthesis lowers reasoning energy (Theorem 4)
   - Phase partition of theorem space (Theorem 5)

3. **A certified decision procedure** (`chooseSearchAction`) with proven correctness guarantees.

4. **Concrete instantiation** via the exponential benefit model (powerset expansion), with a verified compression threshold.

5. **Computational experiments** demonstrating the separation between direct and phase-aware strategies.

### 1.3 Related Work

**Proof complexity.** The study of proof system size bounds (Cook & Reckhow, 1979; Krajíček, 1995) establishes that certain tautologies require exponentially long proofs in restricted systems. Our work is complementary: we study the *compression* achievable by lemma introduction, not the absolute lower bounds on proof size.

**Phase transitions in combinatorial search.** The random 3-SAT phase transition (Cheeseman et al., 1991; Mitchell et al., 1992) shows that satisfiability problems undergo a sharp easy-hard transition at a critical clause-to-variable ratio. We formalize an analogous phenomenon for structured theorem proving.

**Adaptive tactic scheduling.** Machine learning approaches to tactic prediction (Yang et al., 2019; Polu & Sutskever, 2020; Lample et al., 2022) learn to select tactics from data. Our framework provides a *mathematical* basis for strategy selection, complementing learned approaches with formal guarantees.

**Proof compression.** The catalog work on proof compression (ProofCompression/Defs.lean) defines CompressionInstance, HasAsymptoticGap, HasThreshold, and Phase. We build directly on these definitions, lifting them into a control-theoretic framework.

---

## 2. Definitions and Notation

### 2.1 Phase Classification

We define three phases for theorem instances:

```
inductive Phase where
  | tractable : Phase      -- automation suffices
  | transitional : Phase   -- near threshold
  | intractable : Phase    -- lemma invention required
```

Phases are ordered: tractable ≤ transitional ≤ intractable, via an index function (0, 1, 2). This ordering is a preorder, enabling monotonicity statements.

### 2.2 Phase Prediction

Given a threshold parameter t ∈ ℕ:

```
predictedPhase(t, n) =
  if n ≤ t then tractable
  else if n ≤ 2t then transitional
  else intractable
```

**Lemma (predictedPhase_monotone).** For fixed t, the function n ↦ predictedPhase(t, n) is monotone.

### 2.3 Search Actions and Policy

```
SearchAction = direct | synthesizeLemmas

PhaseAwarePolicy(phaseFn, x) =
  match phaseFn(x) with
  | tractable => direct
  | transitional => synthesizeLemmas
  | intractable => synthesizeLemmas
```

### 2.4 Lemma Benefit Model

A `LemmaBenefit α` consists of:
- `baseComplexity : α → ℕ` — complexity under direct search
- `reducedComplexity : α → ℕ` — complexity after lemma synthesis
- `beneficial : ∀ x, reducedComplexity x ≤ baseComplexity x` — synthesis never increases complexity

### 2.5 Effective Complexity and Compression Threshold

```
effectiveComplexity(L, useLemma, x) =
  if useLemma then L.reducedComplexity x else L.baseComplexity x

CompressionThreshold(L, k) :=
  ∀ x, k ≤ L.baseComplexity x → L.reducedComplexity x < L.baseComplexity x
```

### 2.6 Reasoning Energy

The cross-domain bridge to statistical physics:

```
reasoningEnergy(c, x) := c(x) : ℚ
```

This maps complexity to a rational-valued "energy" functional, enabling statements about energy descent.

---

## 3. Main Results

### 3.1 Theorem 1: Upward Closure of Synthesis Assignment

**Statement.** Let α be a preordered type and phaseFn : α → Phase a monotone phase predictor. If PhaseAwarePolicy(phaseFn, x) = synthesizeLemmas and x ≤ y, then PhaseAwarePolicy(phaseFn, y) = synthesizeLemmas.

**Proof sketch.** By the equivalence `PhaseAwarePolicy = synth ↔ phase ≠ tractable`, the hypothesis gives phaseFn(x) ≠ tractable. By monotonicity, phaseFn(x) ≤ phaseFn(y). Case analysis on phaseFn(x): if transitional, then phaseFn(y) ≥ transitional ≠ tractable; if intractable, similarly. ∎

**Significance.** This certifies *robustness* of the phase-aware policy: the synthesis region is upward closed. A prover can safely assume that if synthesis is needed for problem x, it is needed for all harder problems.

### 3.2 Theorem 2: Strict Complexity Reduction Above Threshold

**Statement.** If CompressionThreshold(L, k) holds and k ≤ L.baseComplexity(x), then:

```
effectiveComplexity(L, true, x) < effectiveComplexity(L, false, x)
```

**Proof.** Unfold definitions: the left side is L.reducedComplexity(x), the right is L.baseComplexity(x). The inequality follows directly from the compression threshold hypothesis. ∎

**Significance.** This is the core theorem: above threshold, lemma synthesis *provably* reduces complexity. The advantage is strict, not merely weak.

### 3.3 Theorem 3: Resource Allocation Dominance

**Statement.** Under the compression threshold, if L.reducedComplexity(x) ≤ B but ¬(L.baseComplexity(x) ≤ B), then:

```
SolvesWithinBudget(effectiveComplexity(L, true), B, x) ∧
¬ SolvesWithinBudget(effectiveComplexity(L, false), B, x)
```

**Proof.** The first conjunct unfolds to L.reducedComplexity(x) ≤ B (given). The second to ¬(L.baseComplexity(x) ≤ B) (given). ∎

**Significance.** This bridges the gap from complexity theory to ATP evaluation. For equal budget, phase-aware provers solve problems that direct-search provers cannot — a clean formal surrogate for "same budget, more solved problems."

### 3.4 Theorem 4: Synthesis Lowers Reasoning Energy

**Statement.** Under the compression threshold with k ≤ L.baseComplexity(x):

```
reasoningEnergy(L.reducedComplexity, x) < reasoningEnergy(L.baseComplexity, x)
```

Moreover, the energy gap is at least 1:

```
1 ≤ reasoningEnergy(L.baseComplexity, x) - reasoningEnergy(L.reducedComplexity, x)
```

**Proof.** The compression threshold gives L.reducedComplexity(x) < L.baseComplexity(x) as natural numbers. Casting to ℚ preserves the strict inequality. The gap of at least 1 follows from the discreteness of ℕ. ∎

**Significance.** Establishes a formal dictionary between ATP and energy descent in statistical physics. Future work can define free energy, entropy of tactic distributions, and metastable proof states using this foundation.

### 3.5 Theorem 5: Phase Partition of Theorem Space

**Statement.** For any phase predictor phaseFn : α → Phase:

1. Phase regions for distinct phases are pairwise disjoint.
2. The union of all phase regions is the entire space:
   ```
   ⋃ p : Phase, {x | phaseFn x = p} = Set.univ
   ```

**Proof.** (1) If x ∈ {x | phaseFn x = p} ∩ {x | phaseFn x = q}, then p = phaseFn(x) = q, contradicting p ≠ q. (2) For any x, we have x ∈ {x | phaseFn x = phaseFn(x)}. ∎

**Significance.** Theorem space has genuine *geometry*: it decomposes into disjoint phase strata, each with a certified optimal strategy. The strata tile the space without gaps.

---

## 4. Certified Algorithm

### 4.1 The Decision Procedure

```python
def chooseSearchAction(threshold: int, n: int) -> SearchAction:
    """O(1) certified search-action selector."""
    phase = predictedPhase(threshold, n)
    if phase == TRACTABLE:
        return DIRECT
    return SYNTHESIZE_LEMMAS
```

**Correctness theorems:**
- `chooseSearchAction_tractable`: n ≤ threshold ⟹ action = direct
- `chooseSearchAction_synthesis`: threshold < n ⟹ action = synthesizeLemmas
- `chooseSearchAction_improves_complexity`: under threshold conditions, the chosen action achieves strictly lower complexity

**Complexity:** O(1) time and space for single evaluation; O(n) for batch evaluation of n instances.

### 4.2 Curriculum Partition Algorithm

```python
def partition_curriculum(instances, threshold):
    """O(|instances|) curriculum partitioner."""
    tractable = [x for x in instances if x <= threshold]
    hard = [x for x in instances if x > threshold]
    return tractable, hard
```

**Correctness:** `curriculumBucket_agrees_with_policy` proves that this partition matches the phase-aware policy exactly.

---

## 5. Concrete Instantiation: Exponential Benefit Model

### 5.1 Definition

```
exponentialBenefit : LemmaBenefit ℕ where
  baseComplexity n = 2^n
  reducedComplexity n = n + 1
  beneficial: ∀ n, n + 1 ≤ 2^n  (by induction)
```

This models the powerset expansion family: ∏(1 + fᵢ) = Σ_{S ⊆ [n]} ∏_{i∈S} fᵢ, where the inductive proof costs O(n) but naive expansion produces 2ⁿ terms.

### 5.2 Verified Threshold

**Theorem (exponentialBenefit_threshold).** CompressionThreshold(exponentialBenefit, 3) holds: for all n with 3 ≤ 2ⁿ (i.e., n ≥ 2), we have n + 1 < 2ⁿ.

### 5.3 Computational Results

| n | Base (2ⁿ) | Reduced (n+1) | Ratio | Budget=100 Direct | Budget=100 Synth |
|---|-----------|---------------|-------|-------------------|------------------|
| 3 | 8 | 4 | 2.0× | ✓ | ✓ |
| 5 | 32 | 6 | 5.3× | ✓ | ✓ |
| 7 | 128 | 8 | 16.0× | ✗ | ✓ |
| 10 | 1024 | 11 | 93.1× | ✗ | ✓ |
| 15 | 32768 | 16 | 2048× | ✗ | ✓ |
| 20 | 1048576 | 21 | 49932× | ✗ | ✓ |

With budget B = 100:
- Direct search solves instances n ∈ {0, ..., 6} (7 problems)
- Phase-aware synthesis solves instances n ∈ {0, ..., 99} (100 problems)
- **Advantage: +93 problems solved**

---

## 6. Applications

### 6.1 Adaptive Tactic Scheduling

The phase-aware policy induces a natural tactic scheduler:
- **Tractable phase:** Allocate 80% of budget to fast direct tactics (simp, ring, omega), 20% to synthesis.
- **Transitional phase:** 50/50 split between direct tactics and lemma synthesis.
- **Intractable phase:** 80% to lemma synthesis, 20% to direct tactics as fallback.

### 6.2 Curriculum Design for Neural Theorem Provers

The partition theorem yields a three-stage curriculum:
1. **Foundation (tractable):** Train on problems where direct search succeeds.
2. **Bridge (transitional):** Introduce lightweight lemma synthesis.
3. **Mastery (intractable):** Focus on deep synthesis strategies.

The formal guarantee: this curriculum partition agrees with the optimal policy.

### 6.3 Energy-Based Proof Search

The reasoning energy framework suggests an energy-minimization approach to proof search:
- Define energy as complexity of the current proof state.
- At each step, choose the tactic that most reduces energy.
- Lemma synthesis corresponds to an energy-lowering phase transition.

---

## 7. Discussion

### 7.1 Assumptions and Limitations

The theory rests on several explicit assumptions:
1. Complexity is measured by a single scalar (semantic complexity).
2. The compression threshold is known or estimable.
3. Lemma synthesis always reduces complexity (the beneficial condition).

In practice, (1) is an idealization — real theorems have multi-dimensional complexity. (2) requires either domain knowledge or learned threshold estimation. (3) may fail for poorly chosen lemmas.

### 7.2 Relation to Proof Complexity

Our compression threshold is related to, but distinct from, classical proof complexity results. We study the *relative* advantage of lemma-augmented systems over direct systems, rather than absolute proof size lower bounds. The exponential separation in our model mirrors the tree-vs-DAG proof size gap studied in proof complexity.

### 7.3 Falsifiability

The theory makes precise, testable predictions:
- Above the predicted threshold, lemma synthesis should increase solve rate by a measurable amount.
- The gain should be monotone in complexity.
- Phase-aware scheduling should outperform fixed-strategy scheduling under equal budget.

These predictions can be tested on benchmark theorem families stratified by complexity.

---

## 8. Future Work

1. **Multi-dimensional complexity.** Extend the scalar complexity model to vector-valued complexity, capturing syntactic depth, variable count, and dependency structure simultaneously.

2. **Learned threshold estimation.** Train a classifier to predict the compression threshold from theorem features, replacing the fixed threshold with an adaptive one.

3. **Entropy-regularized tactic policies.** Define entropy of tactic distributions over proof states and prove that phase-aware policies minimize free energy.

4. **Renormalization of proof structures.** Define scale-dependent coarse-graining of proof terms and study fixed points of the resulting renormalization flow.

5. **Experimental validation.** Implement phase-aware scheduling in a production theorem prover and measure solve-rate improvement on Mathlib and competition benchmarks.

---

## 9. References

1. Cheeseman, P., Kanefsky, B., & Taylor, W. M. (1991). Where the really hard problems are. *IJCAI*.
2. Cook, S. A., & Reckhow, R. A. (1979). The relative efficiency of propositional proof systems. *Journal of Symbolic Logic*.
3. Krajíček, J. (1995). *Bounded Arithmetic, Propositional Logic, and Complexity Theory*. Cambridge University Press.
4. Lample, G., et al. (2022). HyperTree proof search for neural theorem proving. *NeurIPS*.
5. Mitchell, D., Selman, B., & Levesque, H. (1992). Hard and easy distributions of SAT problems. *AAAI*.
6. Polu, S., & Sutskever, I. (2020). Generative language modeling for automated theorem proving. *arXiv:2009.03393*.
7. Yang, K., et al. (2019). Learning to prove theorems via interacting with proof assistants. *ICML*.
