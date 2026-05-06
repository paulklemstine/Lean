# Certified Robustness for Pairwise One-vs-One Voting Classifiers via Tropical Satake Margin Bounds

## Abstract

We prove a formally verified robustness theorem for multiclass classifiers built from pairwise one-vs-one comparisons aggregated by Borda/Copeland tournament voting. The central result establishes that if a class *w* is the strict Borda winner and its pairwise margins over all opponents exceed heterogeneous Lipschitz bounds scaled by the perturbation radius, then *w* remains the unique strict winner under perturbation. The proof factors into three independent layers — an analytic margin preservation inequality, a pure combinatorial tournament lemma, and a robustness bridge — each formally verified in Lean 4 with Mathlib. This architecture extends the tropical Satake robustness program beyond argmax classifiers into genuinely different voting-based aggregation, providing a reusable certified interface for any score system with pairwise Lipschitz control.

---

## 1. Introduction

Certified robustness — the provable guarantee that a classifier's output is invariant under bounded input perturbations — has become a central concern in trustworthy machine learning. The standard framework considers a classifier `f(x) = argmax_i S_i(x)` and certifies robustness by showing that the winning score exceeds all competitors by a margin larger than any possible perturbation effect.

However, many practical multiclass classifiers do not use a single argmax. A widely-used alternative is **one-vs-one (OvO) voting**: train `n(n-1)/2` binary classifiers, one for each pair of classes, and aggregate their outputs by tournament voting. The predicted class is the one with the most pairwise wins — the Borda/Copeland tournament winner.

This paper answers a natural question: **can we certify robustness for OvO voting classifiers using the same kind of margin analysis that works for argmax classifiers?**

We show that the answer is yes, and the resulting theory has a clean factorization:

1. **Analytic layer**: If `|PairMargin(w,j,x') - PairMargin(w,j,x)| ≤ K_{wj} · r` and `K_{wj} · r < PairMargin(w,j,x)`, then `PairMargin(w,j,x') > 0`.

2. **Combinatorial layer**: If class `w` beats every opponent at `x'`, then `w` is the unique strict Borda winner at `x'`. This is a pure tournament graph fact: the vertex with out-degree `n-1` has the maximum possible score, and every other vertex has out-degree at most `n-2`.

3. **Robustness bridge**: The analytical margin preservation for each pair converts quantitative Lipschitz control into preserved tournament edges, which the combinatorial lemma converts into classifier stability.

All results are formalized and verified in Lean 4 using Mathlib, producing machine-checked proofs with only standard axioms (propext, Classical.choice, Quot.sound).

---

## 2. Definitions

### 2.1 Pairwise Margins and Tournament Scores

Let `S : {1,...,n} × ℝ^d → ℝ` be a family of score functions, one per class. We define:

**Pairwise margin:**
$$\text{PairMargin}(i, j, x) = S_i(x) - S_j(x)$$

**Pairwise win:**
$$\text{PairWins}(i, j, x) \iff \text{PairMargin}(i, j, x) > 0$$

**Borda/Copeland score:**
$$\text{BordaScore}(i, x) = |\{j \neq i : \text{PairMargin}(i, j, x) > 0\}|$$

**Strict Borda winner:**
$$\text{IsStrictBordaWinner}(w, x) \iff \forall i \neq w,\; \text{BordaScore}(i, x) < \text{BordaScore}(w, x)$$

### 2.2 Heterogeneous Pairwise Lipschitz Bounds

We parameterize the perturbation sensitivity by a matrix of constants `K : {1,...,n}² → ℝ`:

$$|\text{PairMargin}(i, j, x') - \text{PairMargin}(i, j, x)| \leq K_{ij} \cdot r$$

whenever `‖x' - x‖_∞ ≤ r`. The use of heterogeneous constants `K_{ij}` is critical: different pairs of classes may have very different sensitivity to input perturbations, and the certified radius is determined by the **least robust pair** involving the winner.

### 2.3 Certified Radius

The certified robustness radius is:
$$r^* = \min_{j \neq w} \frac{\text{PairMargin}(w, j, x)}{2 \cdot K_{wj}}$$

The factor of 2 provides a safety margin. The theorem holds with a factor of 1, but the factor of 2 aligns with the standard tropical robustness convention and provides numerical stability.

---

## 3. Main Results

### 3.1 Analytic Margin Preservation

**Lemma (pairMargin_pos_of_lipschitz_bound).** *Let `a, b, δ ∈ ℝ`. If `|b - a| ≤ δ` and `δ < a`, then `0 < b`.*

*Proof.* From `|b - a| ≤ δ` we obtain `a - δ ≤ b`. Since `δ < a`, we have `0 < a - δ ≤ b`. ∎

### 3.2 Combinatorial Tournament Lemma

**Theorem (beats_all_implies_strict_borda_winner).** *If `w` beats every other class at `x`, i.e., `PairMargin(w, j, x) > 0` for all `j ≠ w`, then `w` is the unique strict Borda winner at `x`.*

*Proof.* Class `w` wins all `n-1` pairwise comparisons, so `BordaScore(w, x) = n - 1`. For any `i ≠ w`, since `w` beats `i` (i.e., `PairMargin(w, i, x) > 0`), we have `PairMargin(i, w, x) < 0`, so `i` does not beat `w`. Therefore the set of opponents that `i` beats is a strict subset of `{1,...,n} \ {i}`, giving `BordaScore(i, x) ≤ n - 2 < n - 1 = BordaScore(w, x)`. ∎

This is a purely combinatorial fact about tournament graphs: the unique source vertex (one with maximum out-degree `n-1`) is the strict Copeland winner.

### 3.3 Main Robustness Theorem

**Theorem (stable_borda_winner_of_pairwise_margins).** *Let `S` be score functions, `K` be nonneg pairwise Lipschitz constants, `w` be the strict Borda winner at `x`, and `r ≥ 0`. If:*

1. *`|PairMargin(i, j, x') - PairMargin(i, j, x)| ≤ K_{ij} · r` for all `i, j`,*
2. *`2 · K_{wj} · r < PairMargin(w, j, x)` for all `j ≠ w`,*

*then `w` is the strict Borda winner at `x'`.*

*Proof.* For each `j ≠ w`, hypothesis (2) gives `K_{wj} · r < PairMargin(w, j, x)` (since `K_{wj} · r ≥ 0` implies `K_{wj} · r ≤ 2 · K_{wj} · r`). Combined with hypothesis (1) specialized to `(w, j)`, the analytic lemma yields `PairMargin(w, j, x') > 0`. Thus `w` beats every opponent at `x'`, and the combinatorial tournament lemma gives the conclusion. ∎

### 3.4 Certified Radius Corollary

**Corollary.** *If `r < r^* = \min_{j \neq w} \frac{\text{PairMargin}(w, j, x)}{2 K_{wj}}` and the Lipschitz bounds hold, then `w` remains the strict Borda winner at `x'`.*

---

## 4. Formal Verification

All theorems are formalized in Lean 4 with Mathlib. The development consists of:

- **Defs.lean**: Core definitions (`PairMargin`, `BordaScore`, `IsStrictBordaWinner`, `PairLipschitzBound`)
- **Main.lean**: All proofs, organized in three sections (analytic, combinatorial, robustness)

The formal proofs use only standard axioms:
- `propext` (propositional extensionality)
- `Classical.choice` (classical logic)  
- `Quot.sound` (quotient soundness)

No `sorry` statements remain. The proofs were verified by `lake build` and axiom tracing via `#print axioms`.

### Key Proof Architecture

The Lean formalization mirrors the mathematical structure precisely:

```
pairMargin_pos_of_lipschitz_bound  (pure ℝ inequality)
        ↓
pairMargin_pos_of_bound  (instantiation to PairMargin)
        ↓
bordaScore_eq_of_beats_all + bordaScore_lt_of_loses_to  (Finset combinatorics)
        ↓
beats_all_implies_strict_borda_winner  (tournament lemma)
        ↓
borda_winner_stable_of_pairwise_win_preservation  (bridge)
        ↓
stable_borda_winner_of_pairwise_margins  (main theorem)
```

The modular factorization means that any future score system with pairwise Lipschitz bounds can immediately inherit certified Copeland/Borda robustness by instantiating the abstract theorem.

---

## 5. Applications

### 5.1 Adversarial Robustness of OvO Classifiers

The most immediate application is certifying adversarial robustness of one-vs-one multiclass classifiers. Many practical ML systems (SVMs, boosted trees, neural networks with pairwise outputs) use OvO aggregation. Our theorem provides a **pointwise certified robustness radius**: for each input `x`, compute the pairwise margins and Lipschitz constants, then the certified radius `r*` guarantees invariance of the predicted class under any perturbation within that radius.

### 5.2 Robust Ensemble Methods

The framework extends naturally to ensemble methods where base classifiers vote in a tournament structure. If each base classifier provides a pairwise comparison with a known Lipschitz bound, the ensemble's robustness follows from the minimum margin across all relevant pairs.

### 5.3 Tropical Score Systems

When the score functions `S_i` arise from tropical Satake theory — specifically from GL(3) dominant weight evaluations — the Lipschitz constants `K_{ij}` can be extracted from the finite test families that control the tropical Satake transform. This specialization yields certified robustness for a geometrically-motivated class of classifiers where the score functions have combinatorial structure (piecewise-linear, determined by finitely many test weights).

### 5.4 Voting Theory and Social Choice

Beyond machine learning, the combinatorial core (Theorem 3.2) is a statement about tournament stability in social choice theory: a Condorcet winner (one who beats every alternative in pairwise comparison) is robust to small perturbations of the preference intensities. This connects adversarial robustness in ML to classical results in voting theory.

---

## 6. Discussion: Making It Tangible

### The Chess Tournament Analogy

Imagine a chess tournament where every player plays every other player exactly once. The winner is the player with the most victories. Now suppose the players are slightly "perturbed" — maybe they slept poorly, or the lighting changed, or they're playing on slightly different boards. Will the champion still be the champion?

Our theorem says: **yes**, as long as the champion's margin of victory in each game was large enough relative to how much the perturbation could affect that particular matchup. If Alice beats Bob by 10 points and the perturbation can shift their relative performance by at most 3 points, Alice still beats Bob. If Alice beats *everyone* by margins exceeding the perturbation effects, she remains the undisputed champion.

The key insight is that robustness of the tournament outcome reduces to robustness of *individual matchups*. This is simpler than analyzing the full tournament structure because each pairwise comparison is independent.

### Why This Matters for AI Safety

Modern AI classifiers — those that distinguish cats from dogs, benign from malignant tumors, or legitimate from fraudulent transactions — can be fooled by tiny, imperceptible changes to their inputs. A carefully crafted noise pattern, invisible to humans, can make a classifier confidently misidentify an image.

Certified robustness provides a mathematical guarantee: "no matter what perturbation is applied within this radius, the classification will not change." Our work extends these guarantees from simple "pick the highest score" classifiers to more complex voting-based classifiers that compare classes in pairs — a common and often more robust architecture in practice.

### The Three-Layer Cake

The proof has a satisfying three-layer structure that reflects a general pattern in certified robustness:

1. **Bottom layer (Analysis):** Quantitative control on how much scores can change. This is where the hard analytic work lives — bounding derivatives, Lipschitz constants, or tropical Satake transforms.

2. **Middle layer (Combinatorics):** Pure tournament graph theory. A vertex with maximum out-degree is the Copeland winner. This layer knows nothing about real numbers, perturbations, or scores — only about a finite directed graph.

3. **Top layer (Bridge):** A thin interface connecting the analytic bounds to the combinatorial structure. The analytic layer guarantees that tournament edges are preserved; the combinatorial layer guarantees that preserved edges mean a preserved winner.

This factorization is valuable because each layer can be improved independently. Better analytic bounds (from tropical geometry, Lipschitz analysis, or randomized smoothing) immediately yield better certified radii without touching the combinatorial or bridge layers.

---

## 7. Related Work

**Certified adversarial robustness** has been extensively studied for argmax classifiers via randomized smoothing (Cohen et al., 2019), interval bound propagation, and abstract interpretation. Our work complements these approaches by handling a different decision layer.

**Tournament theory** in social choice provides classical results on Copeland winners and their stability. The connection between adversarial robustness and voting stability appears to be novel.

**Tropical geometry in machine learning** has been explored through connections between tropical algebra and neural network decision boundaries. The tropical Satake framework provides a representation-theoretic lens on score functions, yielding structured Lipschitz bounds.

---

## 8. Future Directions

1. **Tighter constants**: The factor of 2 in the margin condition is conservative. Exploring tighter bounds specific to tropical Satake score families could significantly increase certified radii.

2. **Weighted voting**: Extending from Borda/Copeland (uniform vote counting) to weighted tournament aggregation, where different pairwise comparisons have different importance.

3. **Randomized pairwise smoothing**: Analogous to randomized smoothing for argmax, one could add noise to pairwise comparisons and derive probabilistic robustness guarantees.

4. **GL(n) generalization**: The current framework is presented for general score maps but motivated by GL(3) tropical Satake theory. Extending the Lipschitz analysis to GL(n) would broaden the applicability.

5. **Practical implementation**: Integrating the certified radius computation into ML training pipelines for OvO classifiers, using the heterogeneous Lipschitz structure to optimize robustness during training.

---

## 9. Conclusion

We have established, with full formal verification in Lean 4, that pairwise one-vs-one voting classifiers with Borda/Copeland aggregation admit certified robustness guarantees derived from heterogeneous pairwise margin bounds. The proof's clean factorization into analytic, combinatorial, and bridge layers creates a reusable interface: any score system with pairwise Lipschitz control — including those arising from tropical Satake theory — inherits certified voting robustness for free. This extends the tropical robustness program into a genuinely new decision architecture and establishes a bridge between adversarial robustness in machine learning and tournament stability in social choice theory.

---

## Appendix: Lean 4 Theorem Statements

```lean
-- Core analytic lemma
theorem pairMargin_pos_of_lipschitz_bound {a b δ : ℝ}
    (hδ : |b - a| ≤ δ) (hmargin : δ < a) : 0 < b

-- Pure combinatorial tournament lemma
theorem beats_all_implies_strict_borda_winner
    (S : Fin n → (Fin d → ℝ) → ℝ) (w : Fin n) (x : Fin d → ℝ)
    (h : ∀ j, j ≠ w → PairMargin S w j x > 0) :
    IsStrictBordaWinner S w x

-- Main robustness theorem
theorem stable_borda_winner_of_pairwise_margins
    (S : Fin n → (Fin d → ℝ) → ℝ)
    (K : Fin n → Fin n → ℝ)
    (w : Fin n) (x x' : Fin d → ℝ) (r : ℝ)
    (hr : 0 ≤ r)
    (hpert : ‖x' - x‖ ≤ r)
    (hLip : ∀ i j, |PairMargin S i j x' - PairMargin S i j x| ≤ K i j * r)
    (hKnonneg : ∀ i j, 0 ≤ K i j)
    (hmargin : ∀ j, j ≠ w → 2 * K w j * r < PairMargin S w j x)
    (huniq : IsStrictBordaWinner S w x) :
    IsStrictBordaWinner S w x'
```
