# Future Directions: Asymmetric Duration Games

## What We Proved

This cycle formalized the foundational theory of Asymmetric Duration Games (ADGs) — evasion games where Mortal produces an injective sequence of positions while Eternity presents finite sets of banned positions at each round. We established four core results:

1. **ω-Survival on Infinite Types** (`omega_survival_infinite`): On any infinite type α, for any number of rounds n and any adversary schedule, Mortal has an injective evasion sequence. The proof proceeds by induction, extending partial solutions using the infinite complement of used positions ∪ banned positions.

2. **Ascending Strategy Correctness** (`ascending_strict_mono`, `ascending_avoids`): The canonical ascending strategy on ℕ — which at each round picks a value strictly above both its previous position and the maximum of the current banned set — produces a strictly increasing sequence that avoids all bans.

3. **Diagonal Lemma** (`diagonal_lemma`): No finite family of k deterministic sequences can cover all possible adversaries. The adversary that at round t bans the prediction of strategy (t mod k) catches every strategy.

4. **Finite Type Tight Bound** (`finite_type_tight_bound`): On Fin(n+1) with n+1 rounds, the adversary can force evasion failure by banning the same element every round, exploiting the pigeonhole principle (any injection Fin(n+1) → Fin(n+1) is a bijection).

---

## Direction 1: ω²-Survival via Epoch Composition on Finite Types

The ω-survival theorem shows infinite types always permit evasion. But on finite types, survival is bounded. The key insight is that by partitioning available positions into k disjoint regions and running independent ascending strategies in each epoch, we can achieve multiplicative survival amplification. Concretely, on a type of size N with 1 ban per round, Mortal survives N−1 rounds. With k independent "lanes" (copies of the state space), Mortal should survive k·(N−1) rounds by switching lanes when one is exhausted.

**Conjecture**: Define `LaneGame (k N : ℕ)` where Mortal has k independent copies of `Fin N` and Eternity bans one position globally per round. Then Mortal survives exactly `k * (N - 1)` rounds, and the optimal strategy is to exhaust lanes sequentially.

**Test**: Formalize `LaneGame` and prove survival for k = 2, N = 3 (should give 4 rounds). Verify the tight bound by constructing an adversary that forces failure at round k·(N−1) + 1.

**Why now?** The `omega_survival_infinite` and `finite_type_tight_bound` results provide the two endpoints. The lane composition bridges them and establishes the ordinal multiplication structure (ω · k on finite types mirrors ω² on ℕ).

---

## Direction 2: Adaptive vs. Oblivious Adversaries — Quantifier Reversal

Our current model has the adversary's banned sets fixed independently of Mortal's choices (oblivious adversary). An adaptive adversary would choose bans based on Mortal's history, fundamentally changing the game.

**Conjecture**: Against an adaptive adversary on ℕ (who sees Mortal's full history before choosing each ban), Mortal still achieves ω-survival, but the ascending strategy no longer suffices — a randomized or non-constructive strategy is required. Specifically, the ascending strategy fails against the "copy" adversary (who bans Mortal's predicted next position), but the choice-based strategy from `omega_survival_infinite` still works because it uses Classical.choice to avoid the adversary's prediction.

The key insight is that the proof of `omega_survival_infinite` uses `Set.Infinite.nonempty`, which invokes `Classical.choice` — this is not a computability artifact but a genuine logical necessity. An adaptive adversary can defeat any *computable* strategy via diagonalization, so ω-survival against adaptive adversaries requires non-constructive existence.

**Test**: Define `AdaptiveEvasionProblem` where `banned : (Fin t → α) → Finset α` (the ban at round t depends on Mortal's history). Prove ω-survival still holds non-constructively. Then show that no computable (primitive recursive) strategy achieves ω-survival against adaptive adversaries.

**Why now?** The diagonal lemma already shows finite families fail. The adaptive setting extends this to individual strategies, creating a computability/logic separation that connects to proof-theoretic ordinals.

---

## Direction 3: Multivariate Ban Structures and Ramsey-Type Thresholds

The current framework bans arbitrary finite sets. A natural refinement is to constrain the *structure* of bans — e.g., Eternity must ban arithmetic progressions, intervals, or sets with bounded diameter.

**Conjecture**: If Eternity is restricted to banning arithmetic progressions of length ≤ r, then on ℕ, Mortal achieves ω-survival with the ascending strategy regardless of r. But on ℤ/pℤ for prime p, there exists a critical threshold r₀(p) such that Mortal survives p − r₀(p) rounds with r-AP bans and this is tight.

The key insight is that structured bans are strictly weaker than arbitrary bans, so the infinite-type result follows immediately. But on finite fields, the density of arithmetic progressions (connected to Szemerédi-type bounds) creates a non-trivial threshold.

**Test**: Prove that `omega_survival_infinite` holds when each `prob i` is constrained to be an arithmetic progression (this should be a trivial corollary). Then formalize the finite-field game and compute r₀(p) for small primes (p = 5, 7, 11).

**Why now?** This connects ADGs to additive combinatorics and Ramsey theory. The finite_type_tight_bound provides the foundation; adding structural constraints to bans creates a rich hierarchy of game values.

---

## Direction 4: Continuous Evasion and Measure-Theoretic Survival

Extending from discrete types to ℝ with measure-theoretic bans creates a new dimension of the theory.

**Conjecture**: In the continuous evasion game on ℝ where Eternity bans measurable sets of Lebesgue measure ≤ ε per round, Mortal achieves ω-survival for any ε > 0. The survival value is independent of ε — only finiteness matters. This mirrors the discrete evasion duality: the number of bans per round doesn't affect solvability on infinite types.

The key insight is that ℝ minus a measure-ε set still has infinite measure (hence is nonempty and in fact uncountable), so the inductive extension argument from `omega_survival_infinite` carries over unchanged. The measure constraint is irrelevant as long as the complement remains nonempty.

**Test**: Define `MeasureEvasionProblem` using Mathlib's `MeasureTheory.Measure`. Prove ω-survival by showing the complement of any finite-measure set in ℝ is nonempty. Verify the duality: the result is the same for ε = 0.001 and ε = 10⁶.

**Why now?** Mathlib's measure theory library is mature enough to support this formalization. The `omega_survival_infinite` proof strategy generalizes directly — the only new ingredient is showing that measurable complements are nonempty.

---

## Direction 5: The Strategy Lattice and Ordinal Classification

The evasion strategies on a fixed type form a natural partial order: strategy m₁ ≤ m₂ if every adversary defeated by m₁ is also defeated by m₂. This creates a lattice of strategies whose ordinal height should classify the "evasion power" of the type.

**Conjecture**: On ℕ, the lattice of deterministic causal strategies (where the strategy at round t depends only on bans at rounds 0, ..., t−1) has ordinal height exactly ω^ω. The ascending strategy sits at level ω, and level-n strategies (n-fold compositions) sit at level ωⁿ.

The key insight is that the diagonal lemma shows this lattice has no finite cofinal chain, and the ascending strategy provides the first transfinite level. The ordinal classification should mirror the fast-growing hierarchy from proof theory: level-n strategies correspond to Fₙ in the Wainer hierarchy, and the limit at ω^ω corresponds to the proof-theoretic ordinal of a natural subsystem of arithmetic.

**Test**: Define `StrategyOrder` on causal strategies. Prove that the ascending strategy is not maximal (there exist strategies that defeat strictly more adversaries). Prove the diagonal lemma lifts to show no countable chain is cofinal.

**Why now?** The four results from this cycle — ω-survival, ascending strategy, diagonal lemma, and finite bound — are exactly the ingredients needed to begin ordinal classification. The diagonal lemma provides the key tool for proving non-cofinality, and the ascending strategy provides the base case for the transfinite induction.
