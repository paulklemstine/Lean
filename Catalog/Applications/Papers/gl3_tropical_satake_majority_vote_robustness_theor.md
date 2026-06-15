# Certified Robustness for Pairwise Tournament Classifiers via Tropical Lipschitz Bounds

**Abstract.**
We establish formally verified robustness theorems for a pairwise-comparison (Condorcet/tournament) classifier built from GL3 tropical Satake score maps. The main result shows that if a designated class wins every pairwise comparison by a margin exceeding twice the tropical Lipschitz perturbation budget, then it remains the Condorcet winner — and retains maximal Copeland score — under arbitrary L∞ perturbations. All proofs are machine-checked in Lean 4 using Mathlib, providing the first formally verified certified robustness guarantee for tournament-based multiclass decision rules.

---

## 1. Introduction

Adversarial robustness certification for neural classifiers has become a central concern in trustworthy machine learning. The standard approach certifies that the *top-1* prediction is stable: if the highest-scoring class has a margin exceeding the perturbation budget, the prediction cannot change. However, multiclass decision rules in practice are often more complex than simple argmax — ensemble methods, committee classifiers, and social-choice-theoretic aggregation schemes all make decisions based on *pairwise comparisons* between classes rather than a single global ranking.

This paper addresses the robustness certification problem for **pairwise tournament classifiers** on three labels. Given a score map $S : \alpha \to \mathbb{R}^3$ from a GL3 tropical Satake (Hecke) classifier, we orient the edges of a tournament on three vertices by the sign of the pairwise score gaps $\operatorname{gap}(S, x, i, j) = S(x)_i - S(x)_j$. The Condorcet winner — the vertex beating both rivals — then serves as the classifier's prediction.

Our main contribution is a chain of formally verified theorems establishing:

1. **Gap perturbation bound:** Coordinatewise score perturbation of magnitude $K \cdot d \cdot r$ induces gap perturbation of at most $2K \cdot d \cdot r$.
2. **Sign preservation:** If a real number's absolute value exceeds the perturbation magnitude, its sign is invariant.
3. **Condorcet winner stability:** If class $c$ beats every rival by margin $> 2K \cdot d \cdot r$, then $c$ remains the Condorcet winner after perturbation.
4. **Copeland score stability:** The winner's Copeland score remains exactly 2.
5. **Full orientation stability:** If *all* pairwise margins exceed the budget, the entire tournament orientation is preserved.
6. **Cycle characterization:** A Condorcet winner exists on $\operatorname{Fin}\,3$ iff the tournament has no 3-cycle.

---

## 2. Mathematical Setup

### 2.1 Score Maps and Pairwise Gaps

Let $\alpha$ be an arbitrary input type and $S : \alpha \to \operatorname{Fin}\,3 \to \mathbb{R}$ a score function assigning a real-valued score to each of three classes. The **pairwise gap** is:

$$\operatorname{gap}(S, x, i, j) = S(x)_i - S(x)_j$$

### 2.2 Tournament Structure

The scores induce a tournament on $\{0, 1, 2\}$: edge $i \to j$ is present iff $\operatorname{gap}(S, x, i, j) > 0$. Class $c$ is a **Condorcet winner** if it beats every other class:

$$\operatorname{isCondorcetWinner}(S, x, c) \iff \forall j \neq c,\; \operatorname{gap}(S, x, c, j) > 0$$

The **Copeland score** (pairwise wins) of class $i$ is:

$$\operatorname{pairwiseWins}(S, x, i) = |\{j \neq i : \operatorname{gap}(S, x, i, j) > 0\}|$$

### 2.3 Perturbation Model

We model perturbation through a coordinatewise bound: given constants $K, d, r \geq 0$, for perturbed input $x'$:

$$\forall i \in \operatorname{Fin}\,3,\; |S(x')_i - S(x)_i| \leq K \cdot d \cdot r$$

This naturally arises from tropical Lipschitz estimates, where $K$ is the Lipschitz constant of the score map, $d$ is a dimension factor, and $r$ is the $L^\infty$ perturbation radius.

---

## 3. Main Results

### 3.1 Gap Perturbation Bound (Theorem `gap_perturbation_bound`)

**Theorem.** *If $|S(x')_i - S(x)_i| \leq K \cdot d \cdot r$ for all $i$, then*

$$|\operatorname{gap}(S, x', i, j) - \operatorname{gap}(S, x, i, j)| \leq 2K \cdot d \cdot r$$

*Proof.* We compute:
$$\operatorname{gap}(S, x', i, j) - \operatorname{gap}(S, x, i, j) = (S(x')_i - S(x)_i) - (S(x')_j - S(x)_j)$$

By the triangle inequality: $|a - b| \leq |a| + |b| \leq K d r + K d r = 2K d r$.

This is where the factor of 2 enters — it is tight, as the worst case occurs when the two score perturbations have opposite signs.

### 3.2 Sign Preservation (Theorem `sign_preserved_of_abs_diff_lt_abs`)

**Theorem.** *If $|b - a| \leq \varepsilon$ and $\varepsilon < |a|$, then $(0 < a \iff 0 < b)$.*

This elementary but crucial lemma captures the geometric fact that a number cannot cross zero if it is perturbed by less than its distance from zero.

### 3.3 Condorcet Winner Stability (Theorem `condorcet_stable_of_pairwise_margins`)

**Theorem.** *If $|\operatorname{gap}(S, x', i, j) - \operatorname{gap}(S, x, i, j)| \leq 2K d r$ for all $i, j$, and $2K d r < \operatorname{gap}(S, x, c, j)$ for all $j \neq c$, then $c$ is a Condorcet winner at $x'$.*

This is the central robustness theorem. The margin condition ensures that $c$'s advantage over each rival exceeds the perturbation budget, guaranteeing that the winning gaps remain positive.

### 3.4 End-to-End GL3 Robustness (Theorem `robust_tournament_winner_of_GL3_margin`)

**Theorem.** *Starting from coordinatewise score bounds $|S(x')_i - S(x)_i| \leq K d r$ and margin condition $2K d r < S(x)_c - S(x)_j$ for all $j \neq c$, the class $c$ is a Condorcet winner at $x'$.*

This packages the gap perturbation bound and Condorcet stability into a single, directly applicable certification theorem.

### 3.5 Copeland Score Stability (Theorems `pairwiseWins_eq_two_of_condorcet`, `copeland_stable_of_pairwise_margins`)

**Theorem.** *A Condorcet winner on $\operatorname{Fin}\,3$ has Copeland score exactly 2. Consequently, the certified winner retains Copeland score 2 after perturbation.*

### 3.6 Full Tournament Orientation Stability (Theorem `strict_tournament_orientation_stable`)

**Theorem.** *If all pairwise margins exceed $2K d r$ in absolute value, then every edge orientation is preserved: $0 < \operatorname{gap}(S, x, i, j) \iff 0 < \operatorname{gap}(S, x', i, j)$.*

This stronger result certifies not just the winner, but the entire tournament structure — useful for applications that depend on the full ranking or any edge-based functional.

### 3.7 Condorcet Winner Existence (Theorem `exists_condorcet_winner_iff_no_cycle_Fin3`)

**Theorem.** *For a strict tournament on $\operatorname{Fin}\,3$, a Condorcet winner exists if and only if the tournament has no 3-cycle.*

This characterizes exactly when the pairwise decision rule is well-defined. A notable corollary: when scores arise from a real-valued function $S$, the telescoping identity $\operatorname{gap}(0,1) + \operatorname{gap}(1,2) + \operatorname{gap}(2,0) = 0$ implies that 3-cycles are impossible, so a Condorcet winner always exists for strict score-based tournaments.

---

## 4. Formal Verification

All theorems are proved in Lean 4 using the Mathlib library. The proofs use:
- `linarith` for linear arithmetic after absolute value elimination
- `abs_cases` and `abs_le` for case analysis on absolute values
- `fin_cases` for exhaustive enumeration over `Fin 3`
- `Finset.ext` and cardinality lemmas for Copeland score computation

The complete formalization is approximately 200 lines of Lean code. All proofs depend only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

---

## 5. Discussion: Making Robustness Tangible

### For the General Reader

Imagine you're a judge at a cooking competition with three contestants. You taste each dish and assign scores. The winner isn't just the one with the highest score — instead, you compare every pair of contestants head-to-head: "Is dish A better than dish B? Is A better than C? Is B better than C?" The contestant who wins both their head-to-head matchups is the **Condorcet winner** — the one who would beat everyone in a round-robin tournament.

Now suppose your taste perception is slightly "noisy" — maybe you have a cold, or the lighting in the room affects your judgment. How much noise can your scores tolerate before a different contestant takes the crown?

Our theorem gives a precise answer: **if the winner's advantage in every head-to-head matchup exceeds twice the maximum possible noise, the winner is guaranteed to survive.** The factor of two is tight — it accounts for the worst case where noise pushes the winner's score down while simultaneously pushing a rival's score up.

This principle extends naturally to machine learning classifiers. A "tropical Satake score map" is a particular kind of mathematical scoring function with nice Lipschitz properties — the scores don't change too fast when inputs are perturbed. Our theorem converts these Lipschitz bounds on individual scores into a certified robustness guarantee for the entire pairwise tournament decision.

### Historical Context

The Condorcet winner concept dates to the Marquis de Condorcet (1785), who studied voting paradoxes. The connection to adversarial robustness in machine learning is more recent, emerging from the certified robustness literature (Cohen et al., 2019; Lecuyer et al., 2019). Our work bridges these traditions by showing that social-choice-theoretic aggregation rules inherit robustness from Lipschitz score bounds — a connection that, to our knowledge, has not been formally established before.

The tropical geometry angle connects to the Satake compactification of locally symmetric spaces and the theory of Hecke operators in the Langlands program. While these connections are primarily conceptual at this stage, they suggest that deeper algebraic structures underlying the score maps could yield tighter robustness bounds.

---

## 6. Applications

### 6.1 Certified Adversarial Robustness for Multiclass Classifiers

The most direct application is certifying robustness of 3-class neural network classifiers. Given a trained model with tropical Lipschitz constant $K$, the certified perturbation radius for an input $x$ with winner $c$ is:

$$r_{\text{cert}} = \frac{\min_{j \neq c} (S(x)_c - S(x)_j)}{2Kd}$$

Any $L^\infty$ perturbation with $\|x' - x\|_\infty \leq r_{\text{cert}}$ is guaranteed not to change the tournament winner.

### 6.2 Robust Ensemble Decision Rules

When combining multiple weak classifiers, pairwise tournament aggregation provides a more nuanced decision rule than simple vote counting. Our theorem certifies that if each pairwise comparison has sufficient margin, the ensemble decision is robust — even against adversarial perturbation of the input to all ensemble members simultaneously.

### 6.3 Quality Assurance in Automated Systems

In safety-critical applications (medical diagnosis, autonomous driving), a 3-way classification (e.g., "benign / suspicious / malignant") can be certified robust by computing pairwise margins. The certified radius provides a quantitative confidence measure beyond simple probability estimates.

### 6.4 Game-Theoretic Mechanism Design

In mechanism design with three alternatives, our theorem guarantees that a Condorcet-based decision rule is manipulation-resistant: if the true preferences have sufficient margin, no bounded perturbation of reported scores can change the outcome.

---

## 7. Future Directions

1. **Extension to Fin n:** The sign preservation and gap perturbation results generalize immediately to $n$ classes. The Condorcet winner existence characterization becomes more complex for $n > 3$ (involving Condorcet cycles of various lengths).

2. **Tighter bounds from tropical structure:** The factor of 2 in the gap perturbation bound is tight for arbitrary perturbations but may be improvable when the perturbation structure is constrained by tropical geometry.

3. **Weighted tournaments:** Replacing the binary win/loss with weighted pairwise comparisons (e.g., using the gap magnitude) could yield different robustness-accuracy tradeoffs.

4. **Connection to randomized smoothing:** Our deterministic certification could be combined with probabilistic methods to certify larger perturbation radii with high probability.

5. **Higher-rank tropical Satake classifiers:** The GL3 case studied here is the simplest nontrivial instance. Extension to GLn would require understanding the combinatorics of tournaments on $n$ vertices and their stability under perturbation.

---

## 8. Conclusion

We have established a formally verified chain of theorems certifying the robustness of pairwise tournament classifiers under score perturbation. The key insight is that robustness of the tournament winner reduces to sign preservation of pairwise gaps, which in turn reduces to a simple margin-vs-perturbation comparison. This decomposition is clean, general, and mechanically verified — providing a trustworthy foundation for robust multiclass decision-making in safety-critical applications.

The formal verification in Lean 4 ensures that every step of the argument is logically valid, eliminating the possibility of subtle errors in the interplay between combinatorial (tournament structure) and analytic (sign preservation) arguments. All proofs compile against Mathlib v4.28.0 using only standard axioms.

---

## References

- Condorcet, M. de (1785). *Essai sur l'application de l'analyse à la probabilité des décisions rendues à la pluralité des voix.*
- Cohen, J., Rosenfeld, E., & Kolter, J.Z. (2019). Certified adversarial robustness via randomized smoothing. *ICML*.
- Copeland, A.H. (1951). A "reasonable" social welfare function. *Seminar on Mathematics in Social Sciences, University of Michigan*.
- Lecuyer, M., Atlidakis, V., Geambasu, R., Hsu, D., & Jana, S. (2019). Certified robustness to adversarial examples with differential privacy. *IEEE S&P*.
