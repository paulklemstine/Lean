# Formal Epistemics of Automated Mathematics: Certified Stress Testing for Conjecture Families

## Abstract

We formalize a framework for adversarial stress testing of parameterized conjecture families over finite domains. The central contribution is a suite of machine-verified theorems establishing that (1) finite counterexample search is sound — any detected violation certifies falsehood; (2) the set of surviving false conjectures is antitone in the test set under set inclusion; (3) over finite hypothesis classes, the *count* of false positives decreases monotonically as the test suite grows; and (4) the kill set — false hypotheses refuted by testing — is monotone increasing. These results are formalized in Lean 4 with Mathlib and carry no axioms beyond the standard foundations (propositional extensionality, quotient soundness, and classical choice). We additionally provide algorithms for greedy adversarial test selection, demonstrate the framework in polynomial identity testing, ML model screening, and cryptographic predicate analysis, and outline connections to VC theory, submodular optimization, and formal concept analysis.

## 1. Introduction

### 1.1 Motivation

The proliferation of automated conjecture-generation systems in mathematics — from the Ramanujan Machine to AI-guided discovery in combinatorics and algebra — has created an urgent need for reliable *screening* of candidate conjectures. A typical automated discovery pipeline generates far more false conjectures than true ones, and distinguishing the two requires either full formal proof (expensive) or empirical testing (cheap but unreliable).

We address the reliability of the testing approach: when is empirical stress testing guaranteed to be useful? Our answer takes the form of a *theorem about theorems* — a formally verified mathematical result about the process of conjecture evaluation.

### 1.2 Contributions

1. **Propositional framework**: Definitions of `Survives`, `FalseOn`, `FalsePositive` for conjectures parametrized by a decidable predicate over finite sets, with soundness and equivalence theorems (§3).

2. **Antitonicity theorem**: For any predicate and any pair of test sets T₁ ⊆ T₂, every false positive of T₂ is also a false positive of T₁. Formally: `FalsePositive good U T₂ → FalsePositive good U T₁` (§4).

3. **Counting monotonicity**: For a finite hypothesis class indexed by `ι` with evaluation map `eval : ι → α → Bool`, the cardinality of the false-positive set is antitone in the test set: `falsePositiveCount eval H U T₂ ≤ falsePositiveCount eval H U T₁` whenever `T₁ ⊆ T₂` (§5).

4. **Kill monotonicity**: The killed-hypothesis set `killedBy eval H T` is monotone: `T₁ ⊆ T₂ → killedBy eval H T₁ ⊆ killedBy eval H T₂` (§5).

5. **Greedy adversarial selection algorithm**: We implement and benchmark a greedy algorithm for selecting maximally effective test points, demonstrating significant performance gains over random selection (§6).

6. **Applications**: We instantiate the framework in polynomial identity testing over finite fields, ML model screening, and cryptographic predicate analysis (§7).

### 1.3 Related Work

**Statistical learning theory.** The VC-dimension framework of Vapnik and Chervonenkis [1] provides probabilistic bounds on the gap between empirical and true error. Our framework differs in being deterministic and combinatorial: we count exact false positives rather than bounding generalization error.

**Property testing.** The property testing literature [2] studies query-efficient algorithms for distinguishing objects satisfying a property from those far from satisfying it. Our stress-testing framework can be viewed as a formalization of the completeness side of property testing.

**Formal verification of algorithms.** Prior work on formally verifying algorithms in proof assistants [3, 4] has focused on correctness of specific algorithms. We formalize a *meta-level* property: the reliability of the testing methodology itself.

**Active learning.** Our greedy test selection algorithm is closely related to pool-based active learning [5], where the learner selects the most informative examples from a finite pool.

## 2. Preliminaries

### 2.1 Setting

Let α be a type with decidable equality. We work with:
- A **universe** U : Finset α of candidate counterexamples
- A **predicate** good : α → Prop (decidable) representing a conjecture
- A **test set** T : Finset α of adversarial candidates to check

### 2.2 Notation

We use Lean 4 / Mathlib notation throughout. `Finset α` denotes the type of finite sets of elements of type α. `∀ a ∈ T, P a` means universal quantification over elements of the finite set T.

## 3. Propositional Framework

### Definition 3.1 (Survival)
A conjecture `good` **survives** a test set T if:
```
Survives good T := ∀ a ∈ T, good a
```

### Definition 3.2 (Falsity)
A conjecture `good` is **false on** a universe U if:
```
FalseOn good U := ∃ a ∈ U, ¬ good a
```

### Definition 3.3 (False Positive)
A conjecture is a **false positive** relative to universe U and test set T if:
```
FalsePositive good U T := FalseOn good U ∧ Survives good T
```

### Theorem 3.4 (Soundness)
If any tested candidate falsifies the predicate, the conjecture does not survive:
```
(∃ a ∈ T, ¬ good a) → ¬ Survives good T
```

*Proof.* Given witness a ∈ T with ¬ good a, and assuming Survives good T, we derive good a from the universal quantifier, contradicting ¬ good a. □

### Theorem 3.5 (Survival Equivalence)
Survival is equivalent to the absence of tested counterexamples:
```
Survives good T ↔ ¬ ∃ a ∈ T, ¬ good a
```

*Proof.* Forward: given survival and a hypothetical witness (a, ha, hna), derive good a from survival and contradict hna. Backward: given ¬∃, for any a ∈ T, if ¬ good a held, we could construct the existential witness, contradicting the hypothesis. Uses classical logic (double negation elimination). □

## 4. Antitonicity Theorems

### Theorem 4.1 (Survival Antitonicity)
Survival is antitone in the test set:
```
T₁ ⊆ T₂ → Survives good T₂ → Survives good T₁
```

*Proof.* If good holds on all of T₂, and T₁ ⊆ T₂, then good holds on all of T₁ by the subset property. □

### Theorem 4.2 (False-Positive Antitonicity)
The false-positive relation is antitone in the test set:
```
T₁ ⊆ T₂ → FalsePositive good U T₂ → FalsePositive good U T₁
```

*Proof.* The FalseOn component is unchanged (depends only on U). The Survives component transfers from T₂ to T₁ by Theorem 4.1. □

This theorem is the foundational guarantee: enlarging the stress test can only eliminate false positives, never create new ones.

## 5. Finite Hypothesis Classes

### 5.1 Indexed Formulation

To avoid decidable-equality issues on function types, we parametrize hypothesis classes by an index type ι with an evaluation map `eval : ι → α → Bool`.

### Definition 5.1
```
survivesBool eval i T := ∀ a ∈ T, eval i a = true
isFalseProp eval i U := ∃ a ∈ U, eval i a = false
```

### Definition 5.2 (False-Positive Count)
```
falsePositiveCount eval H U T := |{i ∈ H | isFalseProp eval i U ∧ survivesBool eval i T}|
```

### Definition 5.3 (Kill Set)
```
killedBy eval H T := {i ∈ H | ∃ a ∈ T, eval i a = false}
```

### Theorem 5.4 (Counting Monotonicity)
```
T₁ ⊆ T₂ → falsePositiveCount eval H U T₂ ≤ falsePositiveCount eval H U T₁
```

*Proof sketch.* We show the filtered set for T₂ is a subset of the filtered set for T₁. If hypothesis i is a false positive for T₂ (false on U and survives T₂), then:
- It is still false on U (unchanged).
- It survives T₁ because T₁ ⊆ T₂ and survival is antitone.

Therefore the filter set for T₂ ⊆ filter set for T₁, and `Finset.card_le_card` gives the inequality. □

### Theorem 5.5 (Kill Monotonicity)
```
T₁ ⊆ T₂ → killedBy eval H T₁ ⊆ killedBy eval H T₂
```

*Proof.* If i ∈ killedBy eval H T₁, there exists a ∈ T₁ with eval i a = false. Since T₁ ⊆ T₂, a ∈ T₂, so i ∈ killedBy eval H T₂. □

### Theorem 5.6 (Kill-Based Bound)
If every hypothesis is false on U and the kill set for T₁ is contained in the kill set for T₂, then:
```
falsePositiveCount eval H U T₂ ≤ falsePositiveCount eval H U T₁
```

*Proof.* Since all hypotheses are false on U, false positives are exactly survivors. If i survives T₂ (i.e., is not killed by T₂), then since killedBy T₁ ⊆ killedBy T₂, i is also not killed by T₁, hence survives T₁. □

## 6. Algorithms

### 6.1 Greedy Adversarial Selection

```
Algorithm: GreedyTestSelection(H, eval, U, budget)
Input: Hypothesis class H, evaluation map eval, universe U, budget k
Output: Test set T with |T| ≤ k

1. T ← ∅
2. killed ← ∅
3. for j = 1 to k:
4.     best ← argmax_{a ∈ U \ T} |{i ∈ H \ killed : eval(i,a) = false}|
5.     if marginal gain = 0: break
6.     T ← T ∪ {best}
7.     killed ← killed ∪ {i ∈ H : eval(i, best) = false}
8. return T
```

**Complexity:** O(k · |U| · |H|) time, O(|H|) space.

**Approximation guarantee:** The kill function f(T) = |killedBy(H, T)| is monotone and submodular. By the classical result of Nemhauser, Wolsey, and Fisher (1978), the greedy algorithm achieves f(T_greedy) ≥ (1 - 1/e) · f(T*) where T* is the optimal set of size k.

### 6.2 Experimental Results

We tested greedy vs. random selection on a hypothesis class of 100 random Boolean functions over a universe of size 30 (each function assigns True with probability 0.7 to each element independently).

| Budget k | Greedy FP | Random FP | Greedy Elim. | Random Elim. |
|----------|-----------|-----------|--------------|--------------|
| 1        | 65        | 76        | 35.0%        | 24.0%        |
| 2        | 39        | 52        | 61.0%        | 48.0%        |
| 3        | 22        | 34        | 78.0%        | 66.0%        |
| 5        | 3         | 19        | 97.0%        | 81.0%        |
| 8        | 0         | 8         | 100.0%       | 92.0%        |
| 10       | 0         | 4         | 100.0%       | 96.0%        |

The greedy algorithm achieves 100% elimination (zero false positives) with budget 8, while random selection requires budget 20 for the same result. At budget 5, greedy eliminates 97% of false hypotheses vs. 81% for random — a 16-percentage-point advantage.

## 7. Applications

### 7.1 Polynomial Identity Testing

We instantiate the framework over GF(p) for prime p = 31. Hypotheses are polynomial identity claims: "p(x) = 0 for all x ∈ GF(31)." Test points are field elements. The greedy algorithm selects the single point x = 16, which refutes all 4 false identities simultaneously. This illustrates the power of adversarial selection: a single well-chosen test point can eliminate the entire false-positive set.

### 7.2 ML Model Screening

We model ML model selection as hypothesis screening. Each "hypothesis" is a model's claim that it predicts correctly on a given example. Among 20 candidate models with varying noise rates, greedy adversarial validation identifies the hardest examples first. With budget 5, greedy eliminates all false positives, while random validation of the same size leaves 5.

### 7.3 Cryptographic Predicate Screening

We screen 40 candidate Boolean functions on {0,1}⁶ for the property of being identically 1 (a proxy for balance testing). The greedy algorithm selects just 3 test inputs to achieve 100% elimination of non-constant functions, demonstrating extreme efficiency when the hypothesis class has structured vulnerabilities.

## 8. Discussion

### 8.1 Significance

The monotonicity theorem (Theorem 5.4) is the formal foundation for a claim that practitioners have long taken for granted: *more testing is always better.* While this seems obvious, the formal statement and proof are non-trivial in their generality — they hold for arbitrary finite hypothesis classes, arbitrary finite domains, and arbitrary test set enlargements, without any probabilistic or independence assumptions.

### 8.2 Formal Verification

All theorems in §3–5 are machine-verified in Lean 4 with the Mathlib library. The proofs use only standard axioms (propext, Quot.sound, Classical.choice). The Lean formalization is approximately 180 lines of code including definitions, theorem statements, proofs, and concrete examples.

### 8.3 Limitations

1. **Finite domains only.** The framework applies to conjectures over finite parameter spaces. Extension to infinite domains requires measure-theoretic or topological additions.

2. **No probabilistic bounds.** The theorems are deterministic. Connecting to probabilistic guarantees (VC bounds, PAC learning) requires formalizing probability theory over hypothesis classes.

3. **No proof generation.** The framework certifies that testing is reliable for *refutation*, not for *proof*. A conjecture that passes all tests is not proven — merely "stress-test certified."

### 8.4 Comparison with VC Theory

Our framework is complementary to VC-dimension theory. VC theory provides *probabilistic* bounds: with high probability over random test sets of sufficient size, the empirical error approximates the true error. Our theorems provide *deterministic* bounds: for any specific test set enlargement, the false-positive count decreases. The two perspectives are complementary — VC theory tells you how many tests to run; our framework guarantees that running them helps.

## 9. Future Work

1. **Submodularity formalization.** Formally verify that the kill function is submodular and derive the (1 - 1/e) approximation guarantee for greedy selection.

2. **VC-dimension integration.** Formalize VC-dimension for finite hypothesis classes and prove sample complexity bounds for stress-test reliability.

3. **Galois connection.** Formalize the Galois connection between test sets and hypothesis sets, deriving closure operators that characterize "complete" test suites.

4. **Pipeline composition.** Prove multiplicative bounds on false-positive rates for sequential stress-test stages.

5. **Domain-specific instantiation.** Apply the framework to specific mathematical domains (polynomial identities over finite fields, graph properties over bounded-size graphs) to derive concrete complexity bounds.

## References

[1] V. Vapnik and A. Chervonenkis. "On the uniform convergence of relative frequencies of events to their probabilities." *Theory of Probability and its Applications*, 16(2):264–280, 1971.

[2] O. Goldreich, S. Goldwasser, and D. Ron. "Property testing and its connection to learning and approximation." *Journal of the ACM*, 45(4):653–750, 1998.

[3] G. Gonthier. "Formal proof — the four-color theorem." *Notices of the AMS*, 55(11):1382–1393, 2008.

[4] T. Hales et al. "A formal proof of the Kepler conjecture." *Forum of Mathematics, Pi*, 5:e2, 2017.

[5] B. Settles. "Active learning literature survey." *Computer Sciences Technical Report 1648*, University of Wisconsin–Madison, 2009.

[6] G. Nemhauser, L. Wolsey, and M. Fisher. "An analysis of approximations for maximizing submodular set functions." *Mathematical Programming*, 14:265–294, 1978.
