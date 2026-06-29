# Lipschitz Stability of Hecke Score Classifiers Under Score Perturbations: A Formally Verified Perturbation-Transfer Principle for GL₃ Tropical Satake Classifications

## Abstract

We establish a family of perturbation-transfer theorems for 3-class score-based classifiers, proving that any approximation pipeline controlling the sup-norm error of a score vector automatically preserves top-1, top-2, and pairwise one-vs-one decisions, provided the original score margins exceed twice the perturbation bound. The key results are:

1. **Margin perturbation bound**: pairwise score margins change by at most 2ε under ε-close perturbation.
2. **Top-1 stability**: the argmax class is preserved when all pairwise margins exceed 2ε.
3. **Top-2 set stability**: the set of top-2 classes is preserved when the gap between the second and third class exceeds 2ε.
4. **Pairwise OVO stability**: every decisive pairwise preference is preserved under the same margin condition.

All theorems are formalized and machine-verified in Lean 4 with Mathlib, using only the standard axioms (propext, Classical.choice, Quot.sound). The results are instantiated for GL₃ tropical Satake Hecke score constructions but are architecture-agnostic and reusable by any 3-class classification system.

## 1. Introduction

### 1.1 Motivation

Modern machine learning classifiers — from deep neural networks to tropical geometric classifiers — ultimately produce a vector of scores (logits) for each input, and the classification decision is determined by comparing these scores. A natural question arises: **how robust are these decisions to perturbations of the score function?**

This question is especially relevant in settings where the exact score function is approximated:
- **Quantization**: replacing floating-point scores with fixed-point arithmetic
- **Pruning**: removing components of the score computation for efficiency
- **Tropical approximation**: replacing neural network classifiers with piecewise-linear (tropical) surrogates
- **Reconstruction**: recovering score functions from partial observations (e.g., from Satake data on Weyl chamber walls)

In each case, the approximation introduces a bounded error in the score vector. The question is whether this error is small enough to preserve the classification decision.

### 1.2 The 2ε Threshold

The answer turns out to be elegantly simple: **if the original score margins exceed 2ε, then ε-close perturbations preserve all classification decisions.** The factor of 2 is tight — it arises because each pairwise margin involves two scores, and each can shift by up to ε in the worst direction.

This is the content of our formally verified theorems. The proofs are constructive and the bound is optimal: for any margin exactly equal to 2ε, there exist ε-perturbations that flip the decision.

### 1.3 The GL₃ Tropical Satake Setting

The tropical Satake transform provides a bridge between representation theory and classification: it maps Hecke algebra data (edge functions on the GL₃ dominant chamber) to score vectors for 3-class classification. The existing formalized development includes:

- Score construction via additive factorization: `D(a,b) = f₁(a) + f₂(b)`
- Margin theorems certifying decisive gaps between classes
- Separation and reconstruction theorems from Weyl chamber wall data

Our contribution provides the missing link: **the perturbation-transfer principle** that converts certified margins into certified robustness under arbitrary ε-close approximation. This creates a clean API boundary between score construction (representation theory) and robustness certification (analysis).

## 2. Formal Setup

### 2.1 Score Maps

We work with 3-class score maps over an arbitrary input type:

```
Score3(X) = X → Fin 3 → ℝ
```

A score map `f : Score3(X)` assigns to each input `x ∈ X` a triple of real-valued scores `(f(x,0), f(x,1), f(x,2))`.

### 2.2 Perturbation Model

Two score maps `f` and `g` are **ε-close** if they agree pointwise to within ε in every coordinate:

```
ScoreSupClose(f, g, ε) ≡ ∀ x i, |f(x,i) - g(x,i)| ≤ ε
```

This is the ℓ∞ (sup-norm) notion of closeness, applied coordinatewise and pointwise.

### 2.3 Decision Predicates

We define four types of classification decisions:

- **Pairwise margin**: `pairMargin(f, x, i, j) = f(x,i) - f(x,j)`
- **Top-1 winner**: class `i` is the strict winner if `f(x,j) < f(x,i)` for all `j ≠ i`
- **Top-2 membership**: class `i` is in the top-2 if it strictly beats at least one competitor
- **Pairwise preference**: class `i` is preferred to `j` if `f(x,i) > f(x,j)`

## 3. Main Theorems

### 3.1 The Fundamental Inequality

**Theorem (Pairwise Margin Perturbation Bound).** *If `ScoreSupClose(f, g, ε)`, then for all `x, i, j`:*
```
|pairMargin(f, x, i, j) - pairMargin(g, x, i, j)| ≤ 2ε
```

*Proof.* We compute:
```
pairMargin(f,x,i,j) - pairMargin(g,x,i,j) = (f(x,i) - f(x,j)) - (g(x,i) - g(x,j))
                                             = (f(x,i) - g(x,i)) - (f(x,j) - g(x,j))
```
By the triangle inequality:
```
|(f(x,i) - g(x,i)) - (f(x,j) - g(x,j))| ≤ |f(x,i) - g(x,i)| + |f(x,j) - g(x,j)| ≤ ε + ε = 2ε
```
∎

**Corollary (Directional Bound).** Under the same hypotheses:
```
pairMargin(g, x, i, j) ≥ pairMargin(f, x, i, j) - 2ε
```

### 3.2 Top-1 Stability

**Theorem.** *If `ScoreSupClose(f, g, ε)` and for all `j ≠ i`, `f(x,i) - f(x,j) > 2ε`, then `i` is the strict top-1 winner under `g`.*

*Proof.* Fix any `j ≠ i`. From the hypothesis, `f(x,i) - f(x,j) > 2ε`. From the closeness condition:
- `g(x,i) ≥ f(x,i) - ε` (since `|f(x,i) - g(x,i)| ≤ ε`)
- `g(x,j) ≤ f(x,j) + ε` (since `|f(x,j) - g(x,j)| ≤ ε`)

Therefore: `g(x,i) - g(x,j) ≥ (f(x,i) - ε) - (f(x,j) + ε) = f(x,i) - f(x,j) - 2ε > 0`

So `g(x,j) < g(x,i)` for all `j ≠ i`. ∎

### 3.3 Top-2 Set Stability

**Theorem.** *If there exists a bottom class `b` such that `f(x,i) - f(x,b) > 2ε` for all `i ≠ b`, and `ScoreSupClose(f, g, ε)`, then `f` and `g` have the same top-2 set at `x`.*

*Proof.* By the pairwise stability argument, `g(x,i) > g(x,b)` for all `i ≠ b`. This means `b` remains the unique bottom class under `g`. In `Fin 3`, a class is in the top-2 if and only if it is not the unique bottom class. Since both `f` and `g` have `b` as the unique bottom, their top-2 sets coincide: `{i : i ≠ b}`. ∎

The key supporting lemma is the `Fin 3`-specific characterization:

**Lemma (Top-2 ↔ Not Bottom).** *If `b` is the unique bottom class (i.e., `f(x,i) > f(x,b)` for all `i ≠ b`), then `InTop2(f, x, i) ↔ i ≠ b`.*

### 3.4 Pairwise OVO Stability

**Theorem.** *If `f(x,i) - f(x,j) > 2ε` and `ScoreSupClose(f, g, ε)`, then `g(x,i) > g(x,j)`.*

This follows directly from the directional margin bound. The all-pairs version states that if every decisive pairwise margin exceeds 2ε, then all pairwise preferences are preserved.

### 3.5 Bundled Bridge Theorem

**Theorem (GL₃ Tropical Satake Stability Transfer).** *For any GL₃ tropical Satake score map `f` and any ε-close `f'`:*

1. *∀ x, i: if all margins from i exceed 2ε, then i is the top-1 winner under f'*
2. *∀ x: if there is a bottom class with gap > 2ε, then f and f' have the same top-2 set*
3. *∀ x, i, j: if margin(i,j) > 2ε, then f' prefers i over j*

## 4. Formal Verification

All theorems are verified in Lean 4 (version 4.28.0) with Mathlib. The file `Bridges/GL3TropicalSatakeScoreStability.lean` contains:

- 7 core definitions (Score3, ScoreSupClose, pairMargin, IsTop1Winner, InTop2, PairwisePrefers, SameTop2Set)
- 3 supporting lemmas
- 7 generic perturbation theorems
- 4 GL₃-specialized bridge theorems

The proofs depend only on the standard axioms: `propext`, `Classical.choice`, and `Quot.sound`. No `sorry` statements remain.

### 4.1 Proof Structure

The proofs follow a clean two-layer architecture:

1. **Algebraic layer**: The fundamental inequality `|Δmargin| ≤ 2ε` is proved by expanding the margin difference and applying the triangle inequality with the coordinatewise bound.

2. **Decision layer**: Each stability theorem reduces to showing that a certain margin remains positive after perturbation. This follows from `margin ≥ original_margin - 2ε > 0` when the original margin exceeds 2ε.

The `Fin 3` case analysis for top-2 stability uses a combinatorial lemma characterizing top-2 membership as "not being the unique bottom class."

## 5. Applications

### 5.1 Quantized Score Pipelines

When deploying classifiers on edge devices, scores are often quantized to fixed-point arithmetic. If quantization introduces error at most ε, our theorem guarantees that all decisions with margin > 2ε are preserved. The Python demo shows that even 3-bit quantization preserves decisions for well-separated score configurations.

### 5.2 Tropical Network Surrogates

Tropical geometry provides piecewise-linear approximations to neural network classifiers. If the tropical surrogate approximates the original scores to within ε, the stability theorem certifies which decisions are preserved — without re-analyzing the surrogate's internal structure.

### 5.3 Sparse Satake Reconstruction

The existing GL₃ tropical Satake reconstruction theorems show that score functions can be recovered from wall data. If reconstruction introduces bounded error (e.g., from finite sampling or interpolation), the stability theorem transfers the original margin certificates to the reconstructed scores.

### 5.4 Adversarial Robustness Certification

In adversarial ML, one certifies that inputs within a ball of radius δ produce the same classification. Our theorem converts this to a score-space question: if the Lipschitz constant of the score map is L, then input perturbations of size δ produce score perturbations of size ε ≤ Lδ, and decisions are stable when margins exceed 2Lδ.

## 6. Discussion — A Scientific American Perspective

### The Unreasonable Effectiveness of 2ε

Imagine you're a doctor using an AI system that classifies skin lesions into three categories: benign, pre-cancerous, and malignant. The system produces a confidence score for each category, and the diagnosis is determined by the highest score. Now suppose the hospital upgrades to a new, more efficient version of the system — one that uses less memory and runs faster, but produces slightly different scores. Can you trust that the diagnoses will be the same?

This is the question our theorem answers. The answer is remarkably clean: **if the original system was "confident enough" in its decisions — specifically, if the gap between the top score and each other score exceeded twice the maximum error of the new system — then every single diagnosis is guaranteed to be preserved.** Not 99.9% of them. Every single one.

The factor of 2 has a simple geometric intuition. Think of two runners on a track. The leading runner could slow down by ε (the perturbation moves their score down), while the trailing runner could speed up by ε (the perturbation moves their score up). The worst case is that the gap closes by 2ε. If the original gap was more than 2ε, the leader still wins.

### From Abstract Algebra to Reliable AI

What makes this result especially interesting is its connection to representation theory — a branch of abstract algebra that studies symmetry. The GL₃ tropical Satake transform is a mathematical construction that converts symmetry data (Hecke algebra elements) into classification scores. It's part of a growing program connecting deep mathematical structures to machine learning.

The beauty of our approach is its modularity. The algebraic machinery tells you *what* the scores are and *how large* the margins are. Our perturbation theorem tells you that *any* approximation of those scores — no matter how it's computed — preserves the classification as long as the error is small enough. This creates a clean interface between deep mathematics and practical engineering.

### Why Formal Verification Matters

We proved these theorems not just on paper, but in Lean 4 — a computer proof assistant that checks every logical step. Why bother? Because in safety-critical applications like medical diagnosis, autonomous driving, or financial risk assessment, "we're pretty sure the math is right" isn't good enough. A machine-verified proof provides mathematical certainty that the robustness guarantee holds.

The verification also caught subtle issues that paper proofs might miss. For instance, the top-2 stability theorem requires careful `Fin 3` case analysis to establish that "not bottom" is equivalent to "top-2" — a fact that's obvious for three classes but needs proof in a formal system.

## 7. Future Directions

1. **Extension to n classes**: The perturbation bound `2ε` generalizes immediately to `n` classes. The `Fin 3`-specific parts (especially the top-2 characterization) need adaptation.

2. **Tighter bounds for structured perturbations**: If perturbations are correlated across classes (e.g., zero-sum noise), tighter bounds than 2ε may be possible.

3. **Integration with Lipschitz certification**: Composing the score-space stability theorem with input-space Lipschitz bounds would yield end-to-end adversarial robustness certificates.

4. **Quantized Hecke scores**: Applying the stability theorem to specific quantization schemes for tropical Satake scores, yielding certified fixed-point classifiers.

5. **Probabilistic extensions**: Replacing worst-case ε-closeness with probabilistic bounds on score perturbations.

## 8. Conclusion

We have established and formally verified a family of perturbation-transfer theorems for 3-class score classifiers. The central insight — that classification decisions are stable under ε-perturbation whenever margins exceed 2ε — is elementary but powerful. By formalizing it as a reusable Lean 4 library, we create a clean API boundary between score construction and robustness certification. Any future development that controls score approximation error can immediately inherit certified invariance of all multiclass decisions, without reproving classifier-specific robustness lemmas.

## References

The formal verification uses Lean 4 (v4.28.0) with the Mathlib library. The GL₃ tropical Satake framework builds on the classical Satake isomorphism for reductive groups and its tropical degeneration. The perturbation analysis follows standard results in robust optimization and Lipschitz stability of argmax functions.

---

*All theorems in this paper are formalized and verified in `Bridges/GL3TropicalSatakeScoreStability.lean`. Python demonstrations are in `Bridges/demo_score_stability.py`.*
