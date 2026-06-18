# Accuracy-Parameterized Elimination Games: Information Monotonicity and the Parity Paradox in Werewolf

## Abstract

We introduce the **Accuracy-Parameterized Elimination Game** (APEG), a novel mathematical framework for analyzing social deduction games. In an APEG, a group of *v* villagers and *w* werewolves engage in sequential elimination rounds, where the day-vote accuracy *p* ∈ [0,1] parameterizes the probability of correctly identifying a werewolf. We prove three main results: (1) the **Information Monotonicity Theorem**, establishing that win probability is monotonically non-decreasing in accuracy; (2) the **Parity Paradox**, showing that in the single-werewolf game, adding one villager to an even-count village strictly decreases the win probability; and (3) the **Adaptive Advantage Theorem**, proving that the random game with dynamic accuracy strictly outperforms fixed-accuracy play. All results are formalized in Lean 4 with machine-verified proofs. We compute exact rational win probabilities for all game configurations up to 20 players and identify a product formula for the loss probability in the single-werewolf case.

## 1. Introduction

The Werewolf game (also known as Mafia) is a social deduction game introduced by Davidoff (1986) and independently formalized by Plotkin and others. Despite its popularity as a party game, the mathematical theory of optimal play remains surprisingly underdeveloped. While the game has been studied in mechanism design and voting theory contexts, exact win probabilities under various strategy models have not been systematically computed or proven.

We address this gap by introducing the APEG framework, which decouples the *information quality* of villager decision-making from the *structural dynamics* of the elimination process. This separation reveals that the game's behavior depends on two fundamentally independent factors: the accuracy of werewolf identification (an information-theoretic quantity) and the parity structure of the player counts (a combinatorial quantity).

### 1.1 Game Rules

The game proceeds in rounds, each consisting of a **day phase** and a **night phase**:

- **Day Phase**: All surviving players vote to eliminate one player. In the random model, each player is equally likely to be eliminated. In the APEG model, the eliminated player is a werewolf with probability *p* and a villager with probability 1-*p*.
- **Night Phase**: The werewolves (if any remain) eliminate one villager.
- **Termination**: Villagers win when all werewolves are eliminated. Werewolves win when they equal or outnumber the remaining villagers.

### 1.2 Contributions

1. **Novel mathematical structure** (APEG): A parameterized game model that captures the effect of information quality on survival probability.
2. **Exact win probabilities**: Closed-form rational expressions for arbitrary game sizes under random play.
3. **The Parity Paradox**: A rigorously proven counterintuitive result about the non-monotonicity of win probability in the number of villagers.
4. **Information Monotonicity**: A formal proof that better information always helps, justifying Bayesian play.
5. **Machine verification**: All results formalized in Lean 4 with complete proofs.

## 2. Definitions

### 2.1 Random-Play Win Probability

**Definition 1** (Random-play win probability). The function `wolfProb : ℕ → ℕ → ℚ` is defined recursively:

```
wolfProb(v, 0) = 1
wolfProb(v, w) = 0                                    if v ≤ w
wolfProb(v, w) = (w/(v+w)) · afterWolf(v,w)
              + (v/(v+w)) · afterVill(v,w)           otherwise
```

where `afterWolf(v, w)` is the win probability after eliminating a werewolf followed by a night phase, and `afterVill(v, w)` is the win probability after eliminating a villager followed by a night phase.

### 2.2 Loss Probability

**Definition 2** (Loss probability). For the single-werewolf game, define:

```
Q(v) = 1 - wolfProb(v, 1)
```

**Proposition 1** (Loss recurrence). For v ≥ 4:

```
Q(v) = (v/(v+1)) · Q(v-2)
```

with base cases Q(2) = 2/3 and Q(3) = 3/4.

### 2.3 The APEG Structure

**Definition 3** (Accuracy-Parameterized Elimination Game). An APEG is a triple (v, w, p) where:
- v ∈ ℕ: number of villagers
- w ∈ ℕ: number of werewolves
- p ∈ [0, 1] ∩ ℚ: day-vote accuracy

**Definition 4** (APEG win probability). The function `apegWinProb : ℕ → ℕ → ℚ → ℚ` replaces the dynamic accuracy w/(v+w) with a fixed parameter p:

```
apegWinProb(v, 0, p) = 1
apegWinProb(v, w, p) = 0                              if v ≤ w
apegWinProb(v, w, p) = p · afterWolf(v,w,p)
                     + (1-p) · afterVill(v,w,p)       otherwise
```

## 3. Main Results

### 3.1 The Parity Paradox

**Theorem 1** (Parity Paradox). *For all m ≥ 1:*

```
wolfProb(2m, 1) > wolfProb(2m+1, 1)
```

*That is, adding one villager to a village with an even number of villagers strictly decreases the win probability in the single-werewolf game.*

**Proof sketch.** By induction on m, using the loss recurrence Q(v) = (v/(v+1)) · Q(v-2). The key insight is that Q(2m) < Q(2m+1), which follows from:

1. By induction: Q(2m-2) < Q(2m-1)
2. Q(2m) = (2m)/(2m+1) · Q(2m-2) < (2m)/(2m+1) · Q(2m-1)
3. Q(2m+1) = (2m+1)/(2m+2) · Q(2m-1)
4. Since (2m)/(2m+1) ≤ (2m+1)/(2m+2) (verified by cross-multiplication), we get Q(2m) < Q(2m+1). ∎

**Table 1**: Win probabilities illustrating the parity paradox

| v (villagers) | P(v, 1) | Decimal |
|:---:|:---:|:---:|
| 2 | 1/3 | 0.333 |
| 3 | 1/4 | 0.250 ↓ |
| 4 | 7/15 | 0.467 ↑ |
| 5 | 3/8 | 0.375 ↓ |
| 6 | 19/35 | 0.543 ↑ |
| 7 | 29/64 | 0.453 ↓ |
| 8 | 187/315 | 0.594 ↑ |

### 3.2 Information Monotonicity

**Theorem 2** (Information Monotonicity). *For all v, w ∈ ℕ and p₁ ≤ p₂ with 0 ≤ p₁ and p₂ ≤ 1:*

```
apegWinProb(v, w, p₁) ≤ apegWinProb(v, w, p₂)
```

**Proof sketch.** By strong induction on v + w. The key decomposition is:

```
f(p₂) - f(p₁) = p₂·(A₂ - A₁) + (1-p₂)·(B₂ - B₁) + (p₂-p₁)·(A₁ - B₁)
```

where Aᵢ = afterWolf(pᵢ) and Bᵢ = afterVill(pᵢ). Each term is non-negative:
- A₂ ≥ A₁ and B₂ ≥ B₁ by the induction hypothesis
- A₁ ≥ B₁ by the Game State Comparison Lemma (Theorem 3) ∎

**Theorem 3** (Game State Comparison). *For v ≥ w + 3 and w ≥ 2:*

```
apegWinProb(v-2, w, p) ≤ apegWinProb(v-1, w-1, p)
```

*Eliminating a werewolf always produces a state at least as favorable as eliminating a villager.*

### 3.3 Extreme Cases

**Theorem 4** (Perfect Information). *For w < v:*

```
apegWinProb(v, w, 1) = 1
```

*With perfect accuracy, villagers always win when they outnumber werewolves.*

**Theorem 5** (Zero Information). *For w ≥ 1 and v ≥ 1:*

```
apegWinProb(v, w, 0) = 0
```

*With zero accuracy, villagers never win.*

### 3.4 Adaptive Advantage

**Theorem 6** (Adaptive Advantage). *For v ≥ 4 and w = 1:*

```
apegWinProb(v, 1, 1/(v+1)) < wolfProb(v, 1)
```

*The random game, with its dynamically updating accuracy, strictly outperforms fixed-accuracy play at the initial base rate.*

**Proof sketch.** By strong induction on v. The random game uses accuracy 1/(v+1) in the first round but higher accuracies 1/(v-1), 1/(v-3), ... in subsequent rounds as the player pool shrinks. The APEG with fixed p = 1/(v+1) uses this suboptimal accuracy throughout. By information monotonicity, the later rounds' higher accuracy in the random game provides strict improvement. ∎

### 3.5 Win Probability Bounds

**Theorem 7** (Probability bounds). *For all v, w ∈ ℕ and p ∈ [0,1]:*

```
0 ≤ wolfProb(v, w) ≤ 1
0 ≤ apegWinProb(v, w, p) ≤ 1
```

## 4. Computational Results

### 4.1 Exact Win Probabilities

| Game (v, w) | P(win) | Decimal | Base rate |
|:---:|:---:|:---:|:---:|
| (2, 1) | 1/3 | 0.333 | 0.333 |
| (3, 2) | 2/15 | 0.133 | 0.400 |
| (5, 2) | 8/35 | 0.229 | 0.286 |
| (7, 2) | 94/315 | 0.298 | 0.222 |
| (8, 3) | 38/231 | 0.165 | 0.273 |
| (10, 3) | 16/77 | 0.208 | 0.231 |

### 4.2 Threshold Accuracy

For each game configuration, we compute the minimum accuracy p* such that apegWinProb(v, w, p*) ≥ 1/2:

| Game (v, w) | Base rate | Threshold p* | Ratio p*/base |
|:---:|:---:|:---:|:---:|
| (5, 1) | 0.167 | 0.293 | 1.76 |
| (5, 2) | 0.286 | 0.500 | 1.75 |
| (7, 2) | 0.222 | 0.386 | 1.74 |
| (10, 3) | 0.231 | 0.421 | 1.82 |

**Observation.** The ratio p*/base hovers remarkably close to √3 ≈ 1.73 across different game sizes. This suggests a possible universal scaling law.

### 4.3 Product Formula for Loss Probability

For even v = 2m: Q(2m) = ∏ᵢ₌₁ᵐ 2i/(2i+1)
For odd v = 2m+1: Q(2m+1) = ∏ᵢ₌₁ᵐ (2i+1)/(2i+2)

These are related to the Wallis-type products and have known asymptotic behavior: Q(v) ~ C/√v as v → ∞, where C depends on the parity class.

## 5. The APEG as a Mathematical Structure

The APEG is more than a game model — it defines a family of Markov chains parameterized by accuracy. Key structural properties:

1. **Linearity at fixed state**: For fixed game state (v, w), the map p ↦ apegWinProb(v, w, p) is a polynomial in p, not merely affine (despite appearances), because the recursive calls also depend on p.

2. **Interpolation**: The APEG interpolates between the totally uninformed game (p = 0, villagers always lose) and the perfectly informed game (p = 1, villagers always win), with the random game as an interior point whose exact position depends on the game size.

3. **Universality**: The monotonicity theorem holds for ALL game configurations, suggesting that the APEG captures a universal feature of sequential elimination under uncertainty.

## 6. Connections to Existing Work

### 6.1 Voting Theory
The APEG connects to Condorcet's jury theorem: a group making binary decisions with individual accuracy p > 1/2 converges to correct decisions as the group grows. The APEG extends this to sequential elimination settings where the group shrinks over time.

### 6.2 Combinatorial Game Theory
The loss recurrence Q(v) = (v/(v+1)) · Q(v-2) relates to ballot problems and Catalan numbers. The product formula has connections to the Wallis product for π/2.

### 6.3 Catalog Connections
The recursive structure of wolfProb resembles the recursive majority functions studied in `RecursiveMajorityDepthRigidity.lean`, where variable usage patterns emerge from recursive composition. Both involve analyzing how local decision quality propagates through a recursive structure.

## 7. Falsifiable Conjecture

**Conjecture** (Universal Threshold Scaling). *For all v, w with v > w ≥ 1, the threshold accuracy p* satisfying apegWinProb(v, w, p*) = 1/2 satisfies:*

```
p* / (w/(v+w)) → √3  as v → ∞ with w/v fixed
```

**Test**: Compute p* for v = 100, 200, 500, 1000 with w/v = 0.3 and check convergence.

## 8. Future Work

1. **Multi-round Bayesian updates**: Extend the APEG to allow accuracy that changes based on accumulated evidence.
2. **Strategic werewolf play**: Allow werewolves to choose night kill targets strategically.
3. **General elimination games**: Abstract beyond the two-type (villager/werewolf) model.
4. **Asymptotic analysis**: Prove the conjectured √3 scaling law.
5. **Network effects**: Study how communication graph topology affects information propagation.

## References

1. Braverman, M., Etesami, O., Mossel, E. "Mafia: A theoretical study of players and coalitions in a partial information environment." *Annals of Applied Probability*, 2008.
2. Migdal, P. "A mathematical model of the Mafia game." *arXiv:1009.1031*, 2010.
3. Yao, E. "Optimal strategies in the Mafia game." *MIT Undergraduate Thesis*, 2008.
