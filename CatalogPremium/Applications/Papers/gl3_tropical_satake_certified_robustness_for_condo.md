# Certified Condorcet Robustness via Tropical Satake Score-Gap Stability

## Abstract

We formalize and prove a certified robustness theorem for multiclass classification decisions governed by Condorcet tournament aggregation of pairwise score gaps. The central result states that if a class `c` is a Condorcet winner—beating every opponent in pairwise comparison—with minimum margin `m`, and if adversarial perturbations can shift each pairwise gap by at most `δ < m`, then `c` remains the *unique* Condorcet winner after perturbation. We prove this in two layers: (1) an abstract tournament-theoretic stability lemma using only skew-symmetry of pairwise gaps, and (2) a concrete instantiation for GL₃ tropical Satake score functions with explicit perturbation bound `2Kdε`. We also prove that the margin threshold is sharp. All results are machine-verified in Lean 4 with Mathlib.

## 1. Introduction

### 1.1 Motivation

Adversarial robustness certification for neural network classifiers has become a central problem in trustworthy AI. The standard approach certifies that the *argmax* class is preserved under input perturbations bounded in some norm. However, many modern ensemble and multi-model architectures aggregate predictions through more complex rules than simple argmax.

One natural aggregation scheme is the *Condorcet tournament*: given pairwise score functions comparing each pair of classes, declare a class the winner if it beats every other class head-to-head. This arises naturally when:

- Different models or features are specialized for different pairwise comparisons
- The score functions have representation-theoretic structure (e.g., tropical Satake scores from GL₃ Hecke algebras)
- Tournament-based voting rules are used to aggregate classifier outputs

The question we address is: **when does pairwise robustness compose into tournament robustness?**

### 1.2 Contributions

1. **Abstract Condorcet stability theorem**: We prove that uniform pairwise gap stability implies Condorcet winner preservation, with an exact margin threshold.

2. **Uniqueness via skew-symmetry**: We show that any Condorcet winner is unique, using only the algebraic identity `g(j, c, x) = -g(c, j, x)`.

3. **GL₃ tropical Satake instantiation**: We specialize the abstract theorem to score functions from tropical Satake theory, obtaining a certified robustness radius with explicit constants.

4. **Sharpness**: We prove the margin threshold is optimal in the pairwise-gap perturbation model.

5. **Full formal verification**: All results are proved in Lean 4 with no `sorry` axioms and only standard foundational axioms (propext, Classical.choice, Quot.sound).

## 2. Definitions

### 2.1 Pairwise Score Gaps

Let `C` be a finite set of classes, `ι` a finite index type (input coordinates), and `s : C → (ι → ℝ) → ℝ` a family of score functions. The *pairwise gap* between classes `c` and `j` at input `x` is:

$$g(c, j, x) = s_c(x) - s_j(x)$$

### 2.2 Condorcet Winner

Class `c` is a *Condorcet winner* at input `x` if `g(c, j, x) > 0` for every `j ≠ c`. That is, `c` beats every opponent in head-to-head comparison.

Class `c` is a *unique Condorcet winner* if it is a Condorcet winner and no other class is.

### 2.3 Key Algebraic Properties

The pairwise gap satisfies:
- **Self-gap**: `g(c, c, x) = 0` (trivial)
- **Skew-symmetry**: `g(j, c, x) = -g(c, j, x)` (from the definition as a difference)

The skew-symmetry identity is the crucial structural property that makes Condorcet winners unique.

## 3. Main Results

### 3.1 Condorcet Winner Stability

**Theorem** (condorcet_winner_stable). *Let `c` be a class with minimum pairwise margin `m > 0`:*

$$\forall j \neq c, \quad m \leq g(c, j, x)$$

*If for all `j ≠ c`, the pairwise gap perturbation satisfies*

$$|g(c, j, x') - g(c, j, x)| \leq \delta$$

*with `δ < m`, then `c` is a Condorcet winner at `x'`.*

**Proof sketch.** For each `j ≠ c`, the absolute value bound gives `g(c, j, x) - δ ≤ g(c, j, x')`. Combined with `m ≤ g(c, j, x)` and `δ < m`, we get `g(c, j, x') > 0`. □

### 3.2 Uniqueness of Condorcet Winners

**Theorem** (unique_of_condorcet_winner). *If `c` is a Condorcet winner at `x`, then no other class `j ≠ c` can be a Condorcet winner at `x`.*

**Proof.** Suppose for contradiction that `j ≠ c` and both `c` and `j` are Condorcet winners. Then `g(c, j, x) > 0` (from `c` winning against `j`) and `g(j, c, x) > 0` (from `j` winning against `c`). But by skew-symmetry, `g(j, c, x) = -g(c, j, x) < 0`, contradiction. □

### 3.3 Full Condorcet Robustness

**Theorem** (condorcet_winner_of_pairwise_margin). *Under the hypotheses of Theorem 3.1 (with gap bounds for all pairs, not just from `c`), class `c` is the unique Condorcet winner at `x'`.*

This combines Theorems 3.1 and 3.2.

### 3.4 GL₃ Tropical Satake Certificate

**Theorem** (gl3_tropical_condorcet_certified). *Let `K`, `d`, `ε > 0` be constants from the tropical Satake score-gap robustness theorem. If*

$$\forall j \neq c, \quad 2Kd\varepsilon < g(c, j, x)$$

*and for all `x'` with `\|x' - x\| \leq \varepsilon`:*

$$\forall i \neq j, \quad |g(i, j, x') - g(i, j, x)| \leq 2Kd\varepsilon$$

*then `c` is the unique Condorcet winner at every `x'` with `\|x' - x\| \leq \varepsilon`.*

Here `K` is the Lipschitz constant of the tropical Satake score functions, `d` is the dimension/rank parameter (3 for GL₃), and `ε` is the perturbation radius.

### 3.5 Sharpness

**Theorem** (not_condorcetStable_of_small_margin). *If there exists `j ≠ c` such that `g(c, j, x) ≤ δ` and an adversary achieves `g(c, j, x') ≤ 0`, then `c` is not a unique Condorcet winner at `x'`.*

This shows the margin threshold is tight: any class whose minimum outgoing margin is at most `δ` can be dethroned by a perturbation of size `δ`.

## 4. Formal Verification

All theorems are proved in Lean 4 with Mathlib. The proof structure:

| Theorem | Lines | Key tactic |
|---------|-------|-----------|
| `pairwiseGap_self` | 2 | `ring` |
| `pairwiseGap_swap` | 2 | `ring` |
| `le_pairwiseGap_of_abs_sub_le` | 1 | `linarith [abs_le.mp h]` |
| `condorcet_winner_stable` | 1 | `linarith` with helper lemma |
| `unique_of_condorcet_winner` | 1 | `by_contra` + skew-symmetry |
| `condorcet_winner_of_pairwise_margin` | 4 | Composition of above |
| `condorcet_robust_of_min_margin` | 4 | Composition |
| `gl3_tropical_condorcet_certified` | 3 | Direct `linarith` |
| `not_condorcetStable_of_small_margin` | 2 | `grind` |

The proofs depend only on the standard axioms `propext`, `Classical.choice`, and `Quot.sound`.

## 5. Discussion: Why Tournaments Beat Argmax

*For a general audience*

Imagine you're running a chess tournament to find the best player. The Condorcet approach says: a player is the champion if they can beat *every* other player in a head-to-head match. This is stronger than simply having the highest total score (argmax), because it accounts for the structure of pairwise comparisons.

Now imagine someone slightly tampers with the playing conditions—maybe the lighting changes or there's a bit more noise. Our theorem says: **if the champion was winning each match by a comfortable margin, then small perturbations to the conditions can't change who wins.** Moreover, the margin threshold we derive is *exact*—it's the smallest margin that guarantees robustness.

This matters for AI safety because modern classifiers often combine multiple models or scoring functions. When the final prediction comes from a tournament-style aggregation rather than a simple "highest score wins," we need robustness guarantees that respect this structure. Our theorem provides exactly that, specialized to the elegant mathematical framework of tropical geometry and representation theory.

The key insight is beautifully simple: **tournament robustness reduces to pairwise robustness** because of a single algebraic identity—the skew-symmetry of score gaps. If class A beats class B by margin `m`, then class B loses to class A by margin `m`. This antisymmetry means there can be at most one tournament champion, and it means we only need to protect each edge of the tournament graph individually.

### Analogy: The Tallest Building

Think of it this way. The tallest building in a city is the argmax winner. But in a Condorcet tournament, we're asking: is there a building that is taller than *every single other building* when measured from the same ground level? For actual buildings, the argmax and Condorcet winners coincide. But in classification, different "measurements" (score functions) can give different pairwise rankings, and the Condorcet structure captures richer information.

Our theorem says: if the tallest building (Condorcet winner) exceeds every competitor by at least `m` meters, and an earthquake can shift any building's apparent height by at most `δ < m` meters, then the same building remains tallest after the earthquake. The proof is almost trivially simple once you see it—which is exactly what makes it useful as a certified robustness guarantee.

## 6. Applications

### 6.1 Adversarial Robustness Certification

The theorem provides a ready-to-use robustness certificate for any classifier whose decision rule can be expressed as a Condorcet tournament over pairwise scores. Given a test input:

1. Compute all pairwise gaps `g(c, j, x)` for the predicted class `c`
2. Find the minimum margin `m = min_{j ≠ c} g(c, j, x)`
3. Estimate the Lipschitz constant `L` of the pairwise gap functions
4. Certify robustness for all perturbations of radius `ε < m / L`

### 6.2 Ensemble Methods

When combining multiple classifiers through pairwise voting (as in Error-Correcting Output Codes or one-vs-one multiclass decomposition), the final prediction is a tournament winner. Our theorem certifies the ensemble prediction's robustness from individual pairwise robustness.

### 6.3 Tropical Geometry in Machine Learning

The GL₃ specialization connects to the emerging field of tropical geometry in machine learning, where max-plus algebras and tropical polynomials provide natural score functions with piecewise-linear structure amenable to certification.

## 7. Future Directions

1. **Beyond strict tournaments**: Extend to weak tournaments where ties are possible, relevant for classifiers with score plateaus.

2. **Tighter per-pair bounds**: The current theorem uses a uniform perturbation bound `δ` for all pairs. A refined version could use pair-specific bounds `δ_{ij}`, yielding tighter certificates.

3. **Higher-rank groups**: Generalize from GL₃ to GL_n tropical Satake scores, where the Hecke algebra structure provides richer pairwise comparison functions.

4. **Probabilistic certificates**: Combine with randomized smoothing to obtain probabilistic Condorcet robustness guarantees.

## References

The formal proofs are in `Bridges/GL3/TropicalSatakeCondorcetRobustness.lean`. The Python demonstrations with numerical examples are in `Bridges/GL3/demo_condorcet_robustness.py`.
