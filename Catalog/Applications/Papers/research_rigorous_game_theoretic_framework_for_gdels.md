# Gödel's Casino: Epistemic Game Theory for Incompleteness

## Abstract

We develop a rigorous game-theoretic framework for Gödel's incompleteness theorems, formalizing the interplay between decidability, strategy, and information as a casino game. In this framework, a player bets on the truth values of mathematical statements using an oracle (formal system) that can resolve some but not all statements. We establish six main results: (1) an *Oracle Complement Conservation* law showing that selective profits on complementary oracles partition the game size; (2) a *Regret Decomposition Theorem* separating strategy regret into avoidable decidable mistakes and irreducible undecidable exposure; (3) an *Oracle Inclusion-Exclusion* identity revealing profit as a modular valuation on the Boolean lattice of oracles; (4) *Cascade Profit Monotonicity* formalizing the arithmetic hierarchy as a monotone profit sequence; (5) a *Calibration-Profit Theorem* showing that oracle reliability, not mere information, determines profit; and (6) *Parallel Profit Additivity* establishing that incompleteness is additive across independent logical systems. All results are formalized and verified in Lean 4 with Mathlib. We introduce the novel concept of a *Calibrated Casino* and connect the framework to PAC-Bayesian learning theory, Shannon entropy, and lattice-theoretic combinatorics.

**Keywords**: Gödel's incompleteness theorems, game theory, oracle computation, formal verification, information theory, lattice theory

## 1. Introduction

Gödel's incompleteness theorems (1931) establish fundamental limits on formal mathematical systems. The first theorem states that any consistent, recursively enumerable system capable of expressing basic arithmetic contains true but unprovable statements. The second shows that such a system cannot prove its own consistency. While these results are pillars of mathematical logic, their quantitative structure — *how much* is decidable, *how* decidability composes, and *what* the cost of undecidability is — has received less formal attention.

We propose a game-theoretic framework, *Gödel's Casino*, that transforms these meta-logical questions into concrete, quantitative problems about strategy, profit, and information. The framework assigns numerical payoffs to the interaction between a player, an oracle (formal system), and mathematical reality, enabling us to:

- Quantify the *value* of decidability information
- Decompose the *cost* of incompleteness into distinct failure modes
- Characterize *oracle composition* via lattice-theoretic principles
- Connect to information theory, learning theory, and economics

### 1.1 Related Work

The game-theoretic interpretation of logic has a rich history, from Hintikka's game-theoretic semantics [1] to the extensive literature on evaluation games and verification games [2]. Our approach differs in treating decidability itself as a strategic resource rather than modeling logical connectives as game moves.

The oracle hierarchy in our framework draws on Post's theorem and the arithmetic hierarchy [3], while the submodularity results connect to the theory of monotone submodular functions in combinatorial optimization [4].

## 2. Definitions

### 2.1 The Casino Game

**Definition 2.1** (Bet). A *bet* is an element of `{betTrue, betFalse, abstain}`.

**Definition 2.2** (Payoff). The payoff of a bet b on a statement with truth value t is:
- `ePayoff(t, betTrue) = if t then +1 else -1`
- `ePayoff(t, betFalse) = if t then -1 else +1`
- `ePayoff(t, abstain) = 0`

**Definition 2.3** (Oracle Casino). An *Oracle Casino* over a finite index type ι consists of:
- A truth assignment `truth : ι → Bool`
- An oracle `oracle : ι → Bool`

**Definition 2.4** (Selective Strategy). The *selective strategy* bets correctly on oracle-decidable rounds and abstains otherwise:
```
eSelective(G)(i) = if G.oracle(i) then
    if G.truth(i) then betTrue else betFalse
  else abstain
```

**Definition 2.5** (Profit, Decidable Count). The total profit of a strategy s is `eProfit(G, s) = Σᵢ ePayoff(G.truth(i), s(i))`. The decidable count is `eDecCount(G) = |{i : G.oracle(i) = true}|`.

### 2.2 Novel Definitions

**Definition 2.6** (Calibrated Casino). A *Calibrated Casino* extends the Oracle Casino with a prediction function `prediction : ι → Bool` satisfying the *calibration condition*: for all i, if `oracle(i) = true` then `prediction(i) = truth(i)`.

This abstracts the essential property of oracle reliability: predictions need not cover all statements, but they must be correct on the statements they claim to resolve.

**Definition 2.7** (Strategy Regret). The *regret* of a strategy s is `strategyRegret(G, s) = eProfit(G, omniscient) - eProfit(G, s)`, where the omniscient strategy always bets correctly.

**Definition 2.8** (Decidable Mistakes and Undecidable Exposure).
- *Decidable mistakes*: `Σ_{i: oracle(i)=true} (1 - ePayoff(truth(i), s(i)))`
- *Undecidable exposure*: `Σ_{i: oracle(i)=false} (1 - ePayoff(truth(i), s(i)))`

**Definition 2.9** (Cascade Oracle). A *Cascade Oracle* of depth d is a sequence of oracles `level₀, level₁, ..., levelₐ` with the monotone refinement property: for all k < d and all i, if `levelₖ(i) = true` then `levelₖ₊₁(i) = true`.

**Definition 2.10** (Epistemic Advantage). The *epistemic advantage* of strategy s₁ over s₂ is `epistemicAdvantage(G, s₁, s₂) = eProfit(G, s₁) - eProfit(G, s₂)`.

## 3. Main Results

### 3.1 Foundational Properties

**Theorem 3.1** (Selective Profit). `eProfit(G, eSelective(G)) = eDecCount(G)`.

*Proof sketch.* Each decidable round contributes payoff 1 (correct bet); each undecidable round contributes 0 (abstention). The sum telescopes to the decidable count. □

**Theorem 3.2** (Decidable-Undecidable Partition). `eDecCount(G) + eUndecCount(G) = |ι|`.

### 3.2 Oracle Complement Conservation (Theorem 1)

**Theorem 3.3** (Oracle Complement Conservation).
For any Oracle Casino G:
```
eProfit(G, eSelective(G)) + eProfit(¬G, eSelective(¬G)) = |ι|
```
where ¬G is the casino with complemented oracle.

*Proof sketch.* By Theorem 3.1, the LHS equals `eDecCount(G) + eDecCount(¬G)`. The complement oracle decides exactly the undecidable rounds, so `eDecCount(¬G) = eUndecCount(G)`. By Theorem 3.2, the sum is |ι|. □

**Significance.** This is a conservation law: decidability is a zero-sum resource. The total information content of a game is exactly partitioned between any oracle and its complement, mirroring Shannon's entropy-redundancy partition.

### 3.3 Regret Decomposition (Theorem 2)

**Theorem 3.4** (Regret Decomposition).
For any strategy s:
```
strategyRegret(G, s) = decidableMistakes(G, s) + undecidableExposure(G, s)
```

*Proof sketch.* Express regret as a sum of per-round regret contributions, then partition the sum over decidable and undecidable rounds. □

**Corollary 3.5.** The selective strategy has zero decidable mistakes and undecidable exposure equal to `eUndecCount(G)`.

**Corollary 3.6** (Selective Regret). `strategyRegret(G, eSelective(G)) = eUndecCount(G)`.

**Significance.** This theorem reveals two fundamentally different failure modes. Decidable mistakes are *avoidable* (better information use), while undecidable exposure is *intrinsic* (Gödelian incompleteness cost). The selective strategy eliminates all avoidable failures.

### 3.4 Oracle Inclusion-Exclusion (Theorem 3)

**Theorem 3.7** (Oracle Inclusion-Exclusion).
```
eDecCount(O₁ ∪ O₂) + eDecCount(O₁ ∩ O₂) = eDecCount(O₁) + eDecCount(O₂)
```

*Proof sketch.* Apply Finset.card_union_add_card_inter to the filter sets, observing that oracle union corresponds to set union and oracle intersection to set intersection of decidability sets. □

**Corollary 3.8** (Oracle Submodularity). The marginal value of O₂ given O₁ satisfies:
```
eDecCount(O₁ ∪ O₂) - eDecCount(O₁) ≤ eDecCount(O₂)
```

**Significance.** Profit is a *modular valuation* on the Boolean lattice of oracles. This connects game theory to lattice-theoretic combinatorics and reveals diminishing returns in oracle combination.

### 3.5 Cascade Profit Monotonicity (Theorem 4)

**Theorem 3.9** (Cascade Monotonicity).
For a Cascade Oracle C of depth d, the profit sequence is non-decreasing:
```
∀ k < d, cascadeDecCount(C, k) ≤ cascadeDecCount(C, k+1)
```

*Proof sketch.* The refinement property ensures that the set of decidable rounds at level k is a subset of that at level k+1. Apply Finset.card_le_card. □

**Significance.** This is the game-theoretic shadow of Post's theorem: the arithmetic hierarchy Σ₁ ⊂ Σ₂ ⊂ ... maps to a monotonically increasing profit sequence.

### 3.6 Calibration-Profit Theorem (Theorem 5)

**Theorem 3.10** (Calibration-Profit).
For a Calibrated Casino G:
```
eProfit(G.toECasino, calibratedStrategy(G)) = calibDecCount(G)
```

*Proof sketch.* On decidable rounds, the calibration condition ensures predictions match truth, so the calibrated strategy bets correctly (payoff +1). On undecidable rounds, it abstains (payoff 0). The sum equals the decidable count. □

**Significance.** The key to profit is not *information* but *calibration* — the reliability of confident predictions. This connects to PAC-Bayesian learning theory where calibration bounds prediction error.

### 3.7 Parallel Profit Additivity (Theorem 6)

**Theorem 3.11** (Parallel Additivity).
```
eProfit(G₁ ∥ G₂, eSelective(G₁ ∥ G₂)) = eProfit(G₁, eSelective(G₁)) + eProfit(G₂, eSelective(G₂))
```

*Proof sketch.* Decompose the sum over ι₁ ⊕ ι₂ into sums over ι₁ and ι₂ using Fintype.sum_sum_type. □

**Significance.** Incompleteness is additive across independent logical systems, mirroring Shannon's entropy additivity for independent random variables.

### 3.8 Regret-Complement Duality

**Theorem 3.12** (Regret-Complement Duality).
```
strategyRegret(G, eSelective(G)) = eProfit(¬G, eSelective(¬G))
```

*Proof.* Both sides equal `eUndecCount(G)`. □

**Significance.** Your regret (what you miss) equals what the complement oracle would capture. Incompleteness cost is not destroyed — it is the profit potential of a complementary oracle.

## 4. Falsifiable Conjecture

**Conjecture 4.1** (Decidability Density). For natural arithmetic sentences of quantifier depth ≤ k in the arithmetic hierarchy, the fraction decidable in Peano Arithmetic is at least 1/(k+1).

**Testable prediction.** Enumerate Σ₁ sentences of length ≤ 100 over PA. By Σ₁-completeness (all true Σ₁ sentences are PA-provable) and the heuristic that roughly half of random Σ₁ sentences are true, at least 50% should be decidable.

**Framework test.** Our formal framework provides the infrastructure to state and test this conjecture: the decidable fraction characterization theorem shows that selective profit ratio exactly tracks the decidable fraction.

## 5. Applications and Connections

### 5.1 Information Theory

The complement conservation theorem is the casino-theoretic analogue of Shannon's source coding theorem. In Shannon's framework, the entropy of a source and its redundancy partition the total channel capacity. In our framework, the undecidable count (entropy) and decidable count (profit potential) partition the total game size. The regret-complement duality sharpens this: incompleteness entropy is exactly convertible to profit under the complement oracle.

### 5.2 Learning Theory

The Calibrated Casino connects to PAC-Bayesian learning theory. A perfectly calibrated predictor — one whose confidence matches its accuracy — achieves optimal profit, just as a perfectly calibrated oracle achieves maximum profit per decidable round. The calibration-profit theorem can be seen as a zero-temperature limit of PAC-Bayesian generalization bounds.

### 5.3 Economics of Knowledge

The oracle submodularity result has direct implications for the economics of mathematical research. When choosing which axioms to study or which oracles to develop, the marginal value of a new oracle is bounded by its standalone value and decreasing in the existing oracle strength. This formalizes the intuition that "easy discoveries come first" in a precise, quantitative way.

### 5.4 Lattice Theory

The oracle inclusion-exclusion theorem establishes profit as a modular valuation on the Boolean lattice of oracles. This connects the framework to the rich theory of submodular/modular functions on lattices, potentially enabling applications of lattice-theoretic results (e.g., Birkhoff's representation theorem) to the study of oracle combinations.

## 6. Discussion

### Limitations

Our framework models decidability as binary (decidable/undecidable), while real mathematical theories have graded notions of provability (e.g., provably true, provably false, independent, unprovably consistent). Extending the framework to graded oracles with uncertainty is a natural next step (see Future Directions).

The framework also assumes a fixed oracle for all rounds, while in practice, mathematicians can adaptively choose which tools to apply. A sequential version with adaptive oracle selection would capture this dynamics.

### Comparison with Existing Work

Unlike Hintikka's game-theoretic semantics, which models logical connectives as game moves, our framework operates at the meta-level, treating decidability itself as a resource. The closest precedent is the algorithmic game theory literature on prediction with expert advice, where our selective strategy corresponds to the "follow the best expert" strategy with the oracle playing the role of the expert.

## 7. Conclusion

We have established a rigorous game-theoretic framework for Gödel's incompleteness theorems, proving six main theorems that reveal the quantitative structure of incompleteness. The key insight is that decidability is a structured, conserved resource with clean lattice-theoretic properties. The framework connects mathematical logic to information theory (entropy-profit duality), learning theory (calibration), economics (submodularity), and combinatorics (modular valuations). All results are machine-verified in Lean 4 with Mathlib.

## References

[1] J. Hintikka, "Logic, Language-Games and Information," Oxford University Press, 1973.

[2] J. van Benthem, "Logic in Games," MIT Press, 2014.

[3] R.I. Soare, "Recursively Enumerable Sets and Degrees," Springer, 1987.

[4] S. Fujishige, "Submodular Functions and Optimization," Elsevier, 2005.

[5] K. Gödel, "Über formal unentscheidbare Sätze der Principia Mathematica und verwandter Systeme I," Monatshefte für Mathematik und Physik, 1931.

[6] C.E. Shannon, "A Mathematical Theory of Communication," Bell System Technical Journal, 1948.

[7] J. Langford, "Tutorial on Practical Prediction Theory for Classification," JMLR, 2005.
