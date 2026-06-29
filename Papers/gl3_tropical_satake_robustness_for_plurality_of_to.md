# Committee Plurality Robustness via Tropical Satake Certificates: A Formally Verified Bridge

## Abstract

We formalize and prove a **committee-level plurality robustness theorem** that composes memberwise certified robustness certificates into an ensemble-level winner-invariance guarantee. The result bridges two distinct stability layers: (1) an analytic/tropical layer ensuring individual members' votes are unchanged under sufficiently small score perturbation, and (2) a discrete committee layer showing that a large enough plurality margin forces the committee winner to remain fixed when only finitely many members can change their vote. All results are machine-verified in Lean 4 with Mathlib, producing the first formally verified certified robustness theorem for ensemble classifiers.

**Key result.** If a committee of *n* classifiers elects winner *w* by plurality, and *w*'s margin over every competitor exceeds twice the number of analytically unstable members, then *w* remains the unique winner under any perturbation — regardless of how unstable members change their votes.

---

## 1. Introduction

Certified robustness for machine learning classifiers has become a major research direction, with tropical geometry providing particularly clean certificates for piecewise-linear networks. The GL₃ tropical Satake framework yields certified radii within which individual classifier outputs (top-k rankings) are provably invariant.

However, modern ML systems increasingly rely on **ensembles** — committees of classifiers whose outputs are aggregated by majority vote. A natural question arises:

> *How do individual certified robustness guarantees compose at the ensemble level?*

This paper answers this question with a formally verified theorem establishing that **the composition is governed by a clean discrete plurality margin principle**. The result identifies two orthogonal layers of stability:

1. **The analytic layer**: each member's vote is certified stable within a radius determined by its score-gap margin and Lipschitz constant (provided by the tropical Satake framework).

2. **The discrete layer**: given a bound *C* on the number of vote changes, the plurality winner is preserved whenever its margin exceeds 2*C*.

The passage between layers is mediated by a single set-inclusion lemma: changed members ⊆ unstable members, yielding |changedMembers| ≤ |unstableMembers|.

### 1.1 Contributions

- **Vote-gap perturbation bound** (Theorem A): We prove that the pairwise vote gap between any two labels can increase by at most 2*C* under *C* vote changes, and show this bound is tight.

- **Discrete plurality stability** (Theorem B): If the winner's margin exceeds 2*C*, the winner is preserved.

- **Analytic-to-combinatorial bridge** (Theorem C): Only members whose perturbation exceeds their certified radius can change their vote.

- **Main composition theorem** (Theorem D): The abstract committee robustness theorem composing all layers.

- **GL₃ tropical Satake specialization** (Theorem E): Direct connection to the existing single-model certification framework.

- **Formal verification**: All results machine-checked in Lean 4/Mathlib with no axioms beyond `propext`, `Classical.choice`, and `Quot.sound`.

---

## 2. Setup and Definitions

### 2.1 Committee Structure

We consider a committee of *n* members indexed by Fin *n*, voting among *m* labels indexed by Fin *m*. Each member *i* casts a deterministic vote v(i) ∈ Fin *m*.

**Definition (Vote Count).**
```
voteCount(v, y) = |{i ∈ Fin n : v(i) = y}|
```

**Definition (Changed Members).**
```
changedMembers(v, v') = {i ∈ Fin n : v(i) ≠ v'(i)}
```

**Definition (Unstable Members).**
```
unstableMembers(ε, cert) = {i ∈ Fin n : ε(i) ≥ cert(i)}
```

where ε(i) is the perturbation magnitude and cert(i) is the certified radius for member *i*.

### 2.2 Plurality Winner

We define *w* to be the unique plurality winner if for all *y* ≠ *w*:
```
voteCount(v, y) < voteCount(v, w)
```

This avoids the need for global argmax infrastructure; the winner property is captured by pointwise strict inequalities.

---

## 3. Main Results

### 3.1 Theorem A: Vote Count Perturbation Bounds

**Theorem (Single-label bound).** For any label *y*:
```
|voteCount(v, y) - voteCount(v', y)| ≤ |changedMembers(v, v')|
```

*Proof sketch.* Voters for *y* under *v'* are either (a) voters for *y* under *v* who didn't change, contributing at most voteCount(v, y) to the count, or (b) voters who changed TO *y*, who are a subset of changedMembers. The bound follows by cardinality. □

### 3.2 Theorem A': Vote-Gap Perturbation Bound

**Theorem.** For any labels *y*, *w*:
```
voteCount(v', y) - voteCount(v', w) ≤ (voteCount(v, y) - voteCount(v, w)) + 2|changedMembers|
```

*Proof.* Combine the upper bound voteCount(v', y) ≤ voteCount(v, y) + C with the lower bound voteCount(v', w) ≥ voteCount(v, w) - C (where C = |changedMembers|). □

**Tightness.** The factor of 2 is tight. Consider a member switching from *w* to *y*: this simultaneously increases voteCount(y) by 1 and decreases voteCount(w) by 1, for a gap change of 2 per member. With *C* members all switching from *w* to *y*, the gap changes by exactly 2*C*.

### 3.3 Theorem B: Discrete Plurality Stability

**Theorem.** If for all *y* ≠ *w*:
```
voteCount(v, y) + 2 × |changedMembers(v, v')| < voteCount(v, w)
```
then for all *y* ≠ *w*:
```
voteCount(v', y) < voteCount(v', w)
```

*Proof.* For any competitor *y* ≠ *w*, by the vote-gap bound:

  voteCount(v', y) - voteCount(v', w)
    ≤ (voteCount(v, y) - voteCount(v, w)) + 2C
    < 0

where the last step uses the margin hypothesis. □

### 3.4 Theorem C: Analytic-to-Combinatorial Bridge

**Theorem.** If for all *i*: ε(i) < cert(i) → v'(i) = v(i), then:
```
changedMembers(v, v') ⊆ unstableMembers(ε, cert)
```

*Proof.* If *i* ∈ changedMembers, then v(i) ≠ v'(i). By contrapositive of the stability hypothesis, ¬(ε(i) < cert(i)), so *i* ∈ unstableMembers. □

**Corollary.** |changedMembers(v, v')| ≤ |unstableMembers(ε, cert)|.

### 3.5 Theorem D: Main Composition

**Theorem (committee_plurality_robust_of_member_certificates).** Given:
1. ∀ i, ε(i) < cert(i) → v'(i) = v(i) *(memberwise stability)*
2. ∀ y ≠ w, voteCount(v, y) + 2|unstableMembers(ε, cert)| < voteCount(v, w) *(margin)*

Then: ∀ y ≠ w, voteCount(v', y) < voteCount(v', w).

*Proof.* By Theorem C, |changedMembers| ≤ |unstableMembers|. Apply Theorem B with M = |unstableMembers|. □

### 3.6 Theorem E: GL₃ Tropical Satake Specialization

**Theorem.** The abstract committee robustness theorem directly specializes to the GL₃ tropical Satake setting by using the certified radius from `topKSet_eq_of_uniform_score_close` composed with a deterministic top-k label selector.

The key factoring:
1. GL₃ tropical Satake → top-k set invariance (existing catalog theorem)
2. Top-k set invariance → vote invariance (selector stability)
3. Vote invariance → committee stability (our main theorem)

---

## 4. On the Tightness of the Factor 2

A natural question is whether the factor of 2 in the margin condition (margin > 2C) can be improved. We show it cannot.

**Proposition.** For any C ≥ 1, there exist votes v, v' with |changedMembers| = C and a winner *w* with margin(v, w) = 2C such that *w* is NOT the winner under v'.

*Construction.* Let *n* = 2C + 1, with *C* + 1 votes for label 0 (winner) and *C* votes for label 1 (runner-up). Margin = 1... Actually, more precisely: let *n* members vote, with voteCount(v, 0) = k + C and voteCount(v, 1) = k for some *k*, so margin = C. But our theorem requires margin > 2C, which would mean C > 2C, impossible for C ≥ 1.

The correct tightness example: with margin exactly 2C (not strictly greater), all C members switch from the winner to the runner-up, yielding a tie. The margin condition margin > 2C (strict inequality) is therefore the exact threshold.

---

## 5. Applications

### 5.1 Certified Robust Ensemble Classifiers

The most direct application is to **certified adversarial robustness for ensemble methods**. Given an ensemble of *n* classifiers, each with its own certified robustness radius from the tropical Satake framework:

1. Compute each member's certified radius cert(i).
2. For a given perturbation budget ε, identify the unstable members: those with cert(i) ≤ ε.
3. Check the margin condition: winner's margin > 2 × |unstableMembers|.
4. If satisfied, the ensemble prediction is **provably** invariant under ε-perturbation.

### 5.2 Random Forest Robustness

Random forests are a natural fit: each tree is a member, and the final prediction is majority vote. If each tree's decision boundary has a computable margin (as in piecewise-linear trees), our theorem provides ensemble-level certificates.

### 5.3 Selective Classification and Abstention

When the margin condition is NOT satisfied, this provides a principled **abstention criterion**: the ensemble should decline to make a prediction when margin ≤ 2 × |unstableMembers|. This is a formally verified uncertainty quantification signal.

### 5.4 Hierarchical Decision Systems

The abstraction generalizes beyond single-level voting:
- **ECOC (Error-Correcting Output Codes)**: each codeword comparison is a committee vote.
- **Cascaded ensembles**: hierarchical committees where each level's stability feeds into the next.
- **Mixture of experts**: gating networks aggregate expert outputs by weighted voting.

---

## 6. Discussion: A Scientific American Perspective

### Making Machines That Can't Be Fooled

Imagine you're on a jury of 15 experts deciding a case. Each expert independently examines the evidence and casts a vote. If 8 experts vote "guilty" and only 4 vote "not guilty" (with 3 abstaining), the verdict seems clear.

But what if someone could tamper with the evidence — just enough to flip one or two experts? Would the verdict change?

This is exactly the question that arises in artificial intelligence when we use **ensembles** — committees of AI classifiers that vote on a prediction. Each classifier examines the input (say, a medical image) and votes for a diagnosis. The final prediction is the majority vote.

The threat is **adversarial perturbation**: tiny, often imperceptible changes to the input that can fool individual classifiers. A pixel here, a shade there — and a classifier that confidently said "benign" now says "malignant."

Our theorem provides a mathematical guarantee: **if the jury's majority is large enough, no amount of evidence tampering (within certified bounds) can change the verdict.**

The key insight is surprisingly simple. Each expert has a **certified immunity radius** — a threshold below which evidence tampering cannot change their vote. Experts whose tampering exceeds this threshold are "vulnerable." Our theorem says:

> *If the number of vulnerable jury members is less than half the majority's lead, the verdict is locked in.*

The factor of "half" is because the worst-case tampering is a double whammy: flipping a guilty-voter to not-guilty simultaneously *reduces* the guilty count *and increases* the not-guilty count, a swing of 2 per flipped voter.

This result bridges two very different kinds of mathematics:
- **Tropical geometry**, which provides the individual immunity radii through the elegant structure of piecewise-linear score functions, and
- **Combinatorics**, which converts these individual guarantees into a collective stability theorem.

The beauty is in the composition: neither layer alone is sufficient, but together they provide end-to-end guarantees for practical AI systems.

### Historical Context

The problem of ensemble robustness connects to a long tradition in **social choice theory** — the mathematical study of voting systems, pioneered by Condorcet in the 18th century. Condorcet's jury theorem showed that majority voting among independent experts converges to the correct answer as the jury grows. Our theorem adds a new dimension: not just accuracy, but **stability under adversarial perturbation**.

In machine learning, ensemble methods have been empirically successful since Breiman's Random Forests (2001) and Freund & Schapire's AdaBoost (1997). But formal robustness guarantees for ensembles have been scarce. Our work provides a clean mathematical framework for certified ensemble robustness, grounded in the tropical geometric structure of modern neural networks.

---

## 7. Formal Verification Details

All theorems are verified in Lean 4 (v4.28.0) with Mathlib. The formalization consists of approximately 300 lines of Lean code in a single file `Bridges/TropicalSatakeCommitteePlurality.lean`.

Key design choices:
- **No global argmax**: plurality winner is defined through pointwise strict inequalities, avoiding the need for well-ordering arguments.
- **Natural number arithmetic with integer lifts**: vote counts live in ℕ, with ℤ-valued casts used only for the vote-gap bound where subtraction is needed.
- **Modular structure**: the analytic and discrete layers are cleanly separated, with the bridge mediated by a single set-inclusion lemma.

The verified axiom basis consists only of `propext`, `Classical.choice`, and `Quot.sound` — the standard foundations of constructive mathematics with classical reasoning.

---

## 8. Future Directions

1. **Weighted plurality**: Extend to committees where members have different voting weights, corresponding to boosted ensembles.

2. **Top-ℓ committee outputs**: Instead of a single winner, certify stability of the top-ℓ ranked labels across the committee.

3. **Tropical Hecke voting schemes**: Develop the connection between Hecke algebra structure and committee aggregation rules.

4. **Tight margin computation**: Given certified radii for all members, compute the exact perturbation budget under which the ensemble prediction is certified robust.

5. **Probabilistic extensions**: Combine with randomized smoothing to get probabilistic ensemble certificates where deterministic ones are too conservative.

---

## References

- The GL₃ tropical Satake top-k robustness framework is developed in `Catalog/Bridges/TropicalTopKRobustnessGL3.lean`.
- The tropical network Lipschitz closure lemmas are in `Catalog/MachineLearning/Tropical.lean`.
- All formal proofs are in `Bridges/TropicalSatakeCommitteePlurality.lean`.
