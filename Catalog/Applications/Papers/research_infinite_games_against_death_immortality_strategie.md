# Mortality Games: Ordinal Survival Against Transfinite Adversaries

## Abstract

We introduce the **SurvivalArena**, a novel mathematical structure formalizing asymmetric two-player games between a finite player (Mortal) and an adversary with transfinite computational power (Eternity). The central invariant is the **survival ordinal** — the ordinal-valued game rank measuring how many rounds Mortal can guarantee surviving against optimal Eternity play. We establish five main results: (1) the **Omega Survival Theorem**, showing that unbounded finite game values yield transfinite survival ≥ ω; (2) the **Mortality Dichotomy**, proving that survival ordinals are either finite or ≥ ω with no intermediate values; (3) the **Omega-Squared Escalation**, demonstrating that bounded nondeterminism elevates survival to ω²; (4) the **Finite Absorption Principle**, showing that finite head-starts and finite multiplicative factors are absorbed by transfinite survival; and (5) the **Cantor Normal Form decomposition** of game ordinals below ω². All results are formalized and verified in Lean 4 with Mathlib.

## 1. Introduction

### 1.1 Motivation

The study of infinite games has a rich history in set theory (Gale-Stewart, Martin's determinacy), combinatorial game theory (Conway's surreal numbers), and theoretical computer science (Infinite Time Turing Machines). However, the specific question of *how long a finite player can survive against a transfinite adversary* has not been systematically formalized.

This paper introduces a framework — the **SurvivalArena** — that precisely captures this asymmetry. The key insight is that survival duration is naturally measured by ordinal numbers, and the algebraic structure of ordinals (ordinal addition, multiplication, and the Cantor normal form) directly encodes the strategic structure of the game.

### 1.2 Related Work

- **Gale-Stewart games** (1953): Established determinacy for open and closed games on ω.
- **Infinite Time Turing Machines** (Hamkins-Lewis, 2000): Formalized computation that runs for transfinitely many steps.
- **Ordinal game theory**: The use of ordinal rankings in combinatorial game theory, particularly Sprague-Grundy theory.
- **Transfinite computation depth** (Catalog: `Computation/TransfiniteCADepth.lean`): Prior work in our catalog establishing `bounded_implies_finite` for cellular automata depth.
- **Evasion strategies** (Catalog: `Computation/Evasion.lean`): `transfinite_evasion_finite_bound` connecting evasion games to ordinal bounds.

### 1.3 Contributions

1. A novel mathematical structure (`SurvivalArena`, `OrdinalGameTree`) formalizing mortality games.
2. The **Survival Ladder** — a universal construction mapping any ordinal to a canonical game with that survival value.
3. Five major theorems with full PEGB analysis (Proof, Example, Generalization, Boundary).
4. The **Eternity Number** — a novel invariant classifying adversarial difficulty.
5. Complete formal verification in Lean 4.

## 2. Definitions

### 2.1 SurvivalArena

**Definition 2.1** (SurvivalArena). A *SurvivalArena* is a tuple (S, M, E, η) where:
- S is a type of game states
- M : S → Finset S assigns finitely many moves to each state (Mortal's choices)
- E : S → Set S assigns a response set to each state (Eternity's responses)
- η : nonemptiness condition ensuring Eternity always has a response when Mortal has a move

The finiteness constraint on Mortal's moves (M : S → **Finset** S) is the crucial asymmetry — Eternity's responses form an arbitrary set, potentially of any cardinality.

### 2.2 OrdinalGameTree

**Definition 2.2** (OrdinalGameTree). An *OrdinalGameTree* is a tuple (b, E, η) where:
- b : ℕ is the number of Mortal's root choices
- E : Fin b → Set Ordinal assigns to each Mortal choice a set of ordinal-valued Eternity responses
- η : ∀ i, (E i).Nonempty ensures each branch set is nonempty

**Definition 2.3** (Game Value). The *game value* of an OrdinalGameTree T is:
```
T.gameValue = if b = 0 then 0 else sup_{i : Fin b} inf(E(i))
```
This captures the minimax principle: Mortal maximizes over their choices, Eternity minimizes over their responses.

### 2.3 Survival Ladder

**Definition 2.4** (Survival Ladder). The *survival ladder* is a function survivalLadder : Ordinal → OrdinalGameTree defined by:
- survivalLadder(0) = tree with 0 Mortal choices (immediate loss)
- survivalLadder(α) for α ≠ 0 = tree with 1 Mortal choice and Eternity branch set {α}

**Theorem 2.5** (Ladder Correctness). survivalLadder(α).gameValue = α for all α ≠ 0, and survivalLadder(0).gameValue = 0.

This shows the construction is universal: every ordinal is realized as the game value of some OrdinalGameTree.

### 2.4 Computational Structures

**Definition 2.6** (MortalComputation). A *mortal computation* is a partial function step : ℕ → Option α that eventually produces output: ∃ n, (step n).isSome.

**Definition 2.7** (ImmortalComputation). An *immortal computation* is step : Ordinal → Option α that eventually halts: ∃ o, (step o).isSome.

**Definition 2.8** (Eternity Number). The *Eternity number* of an ordinal α is:
```
eternityNumber(α) = if α < ω then α else ω
```

## 3. Main Results

### 3.1 Theorem 1: Omega Survival (PEGB)

**Theorem 3.1** (omega_survival). If F is an UnboundedFiniteFamily (∀ n, F.game(n).gameValue ≥ n), then ⨆ n, F.game(n).gameValue ≥ ω.

**Proof sketch.** For any β < ω, there exists k : ℕ with β ≤ k. Then β ≤ k ≤ F.game(k+1).gameValue ≤ ⨆ n, F.game(n).gameValue. Since this holds for all β < ω, the supremum is ≥ ω. □

**Example.** Consider the family where game(n) has one Mortal choice with Eternity branch {n}. Then gameValue(n) = n, and ⨆ n, n = ω.

**Generalization.** The result generalizes to any directed family: if {α_i}_{i ∈ I} is a directed set of ordinals with no finite upper bound, then sup α_i ≥ ω.

**Boundary.** If we restrict to a *bounded* family (∃ N, ∀ n, gameValue(n) ≤ N), then the supremum is at most N < ω. The unboundedness condition is necessary.

### 3.2 Theorem 2: Mortality Dichotomy (PEGB)

**Theorem 3.2** (mortality_dichotomy). For every ordinal α, either ∃ n : ℕ, α = n, or α ≥ ω.

**Proof sketch.** If α < ω, then by the characterization of ω as the order type of ℕ, α corresponds to some natural number n. Otherwise α ≥ ω. □

**Example.** The ordinal 42 satisfies the first alternative. The ordinal ω + 5 satisfies the second.

**Generalization.** For any limit ordinal λ, every ordinal is either < λ or ≥ λ. The dichotomy at ω is the special case for the first limit ordinal.

**Boundary.** There is no ordinal between all finite ordinals and ω. The ordinal ω is the precise threshold.

### 3.3 Theorem 3: Omega-Squared Escalation (PEGB)

**Theorem 3.3** (omega_squared_escalation). ⨆ k : ℕ, ω · k = ω².

**Proof sketch.** Since ω² = ω · ω and ω = ⨆ n, n, we have ω² = ω · ω = ω · (⨆ n, n). Left multiplication by a positive ordinal preserves suprema (it's a normal function), so this equals ⨆ n, ω · n. □

**Example.** ω · 0 = 0, ω · 1 = ω, ω · 2 = ω + ω, ω · 3 = ω + ω + ω. These are the ordinals ω · k, and their supremum is ω².

**Generalization.** For any limit ordinal λ, ⨆ k : ℕ, λ · k = λ · ω. The theorem is the case λ = ω.

**Boundary.** If we fix k (e.g., k = 5), then ω · 5 < ω². Bounded nondeterminism (fixed k) yields ω · k, which is strictly less than ω². Unbounded nondeterminism is essential.

### 3.4 Theorem 4: Finite Absorption (PEGB)

**Theorem 3.4** (finite_absorption). For k ≥ 1, k · ω = ω.

**Proof sketch.** Since ω is a limit ordinal, k · ω = sup_{n} k · n. But the set {k · n : n ∈ ℕ} = {0, k, 2k, 3k, ...} is cofinal in ℕ (unbounded), so its supremum is ω. □

**Example.** 3 · ω = ω. The sequence 0, 3, 6, 9, 12, ... has supremum ω.

**Generalization.** For any α > 0 with α < ω, we have α · ω = ω. The result extends to: for any ordinal α with 0 < α ≤ ω, α · ω = ω.

**Boundary.** The condition k ≥ 1 is necessary: 0 · ω = 0 ≠ ω. Also, this is specific to *right* multiplication: ω · k ≠ ω for k ≥ 2 (ω · 2 = ω + ω ≠ ω).

### 3.5 Theorem 5: Cantor Normal Form of Games (PEGB)

**Theorem 3.5** (lt_omega_sq_iff). α < ω² if and only if ∃ a b : ℕ, α = ω · a + b.

**Proof sketch.** Forward: use Euclidean division by ω. Since α < ω², α / ω < ω (so α / ω = a for some a : ℕ) and α % ω < ω (so α % ω = b for some b : ℕ). Reverse: if α = ω · a + b, then α ≤ ω · a + ω = ω · (a + 1) ≤ ω · ω = ω². □

**Example.** ω · 3 + 7 < ω². Here a = 3, b = 7.

**Generalization.** For ordinals below ω^n, the Cantor normal form involves n "digits" in base ω.

**Boundary.** The ordinal ω² itself cannot be written as ω · a + b for finite a, b, since ω · a + b < ω · (a + 1) ≤ ω · ω = ω² for all a, b : ℕ, but ω² = ω · ω requires a = ω.

## 4. The Eternity Number

The **Eternity number** provides a novel classification of ordinals based on adversarial difficulty:

- **Finite regime** (α < ω): eternityNumber(α) = α. The adversary needs exactly α moves to win.
- **Transfinite regime** (α ≥ ω): eternityNumber(α) = ω. The adversary needs transfinite computation.

This invariant captures the fundamental dichotomy: once the game crosses the ω threshold, the adversarial cost becomes uniformly ω — the precise amount of transfinite computation needed is always the same "type" of infinity.

## 5. Connection to Infinite Time Turing Machines

Our framework connects to Hamkins and Lewis's Infinite Time Turing Machines (ITTMs) through the MortalComputation/ImmortalComputation hierarchy:

**Theorem 5.1** (mortal_embeds_immortal). Every mortal computation embeds into an immortal computation.

**Theorem 5.2** (mortal_halting_lt_omega). The halting ordinal of a mortal computation is always < ω.

These results formalize the intuition that ordinary computation (mortal) is a strict subset of transfinite computation (immortal), with the halting ordinal providing the precise separation.

## 6. Algorithms

### 6.1 Survival Ordinal Computation

For finite game trees, the survival ordinal can be computed by bottom-up evaluation:
1. Terminal nodes: value = 0
2. Mortal nodes: value = max of children's values
3. Eternity nodes: value = min of children's values

For infinite game trees, the algorithm generalizes to ordinal-indexed fixpoint computation.

### 6.2 Strategy Extraction

Given a game tree with computed ordinal values, Mortal's optimal strategy is: at each turn, choose the child with the highest ordinal value. This greedy strategy is provably optimal for the minimax game.

## 7. Falsifiable Conjecture

**Conjecture 7.1** (Survival Ordinal Gap Conjecture). For any SurvivalArena with countable state space, the survival ordinal is either < ω or in {ω · a + b : a, b ∈ ℕ} ∪ {ω²}. That is, survival ordinals of countable games are bounded by ω².

**Test.** Construct a countable SurvivalArena with survival ordinal ω² + 1. If possible, the conjecture is false. If no such arena exists, investigate whether the state space cardinality bounds the survival ordinal.

## 8. Discussion

### 8.1 The Absorption Principle and Its Implications

The finite absorption results (Theorems 3.4 and `mortal_finite_headstart_absorbed`) reveal a striking asymmetry in ordinal arithmetic: left vs. right multiplication and addition behave fundamentally differently. This asymmetry mirrors the asymmetry in the game: Mortal's finite choices are "absorbed" by Eternity's transfinite power, but Mortal can still achieve transfinite survival through unboundedness.

### 8.2 Non-Commutativity of Strategy Composition

Ordinal multiplication is non-commutative: ω · 2 ≠ 2 · ω. In game terms, "playing two ω-games sequentially" (value ω · 2 = ω + ω) is strictly stronger than "playing an ω-game with doubled rounds" (value 2 · ω = ω). This non-commutativity is not a bug but a feature — it captures the genuine strategic difference between serial and parallel game composition.

### 8.3 Connection to Existing Catalog

Our work connects to several existing catalog results:
- `bounded_implies_finite` (Computation/TransfiniteCADepth.lean): Our Mortality Dichotomy provides the ordinal-theoretic foundation for this result.
- `transfinite_evasion_finite_bound` (Computation/Evasion.lean): Our omega_survival theorem generalizes the evasion bound.
- `finite_lattice_bounded_chain` (Bridges/CondensationSemantics.lean): The finiteness of chains in finite lattices is an instance of our dichotomy.

## 9. Future Work

1. Extend the framework to survival ordinals beyond ω² (requires ω-branching for Mortal).
2. Establish the precise relationship between state space cardinality and maximum survival ordinal.
3. Formalize the connection to ITTMs via simulation theorems.
4. Develop a theory of "survival equivalence" between games.

## References

1. Gale, D. and Stewart, F.M. (1953). "Infinite games with perfect information." Ann. Math. Studies.
2. Hamkins, J.D. and Lewis, A. (2000). "Infinite Time Turing Machines." Journal of Symbolic Logic.
3. Conway, J.H. (2001). "On Numbers and Games." A K Peters.
4. Cantor, G. (1883). "Grundlagen einer allgemeinen Mannigfaltigkeitslehre."
5. Martin, D.A. (1975). "Borel Determinacy." Annals of Mathematics.
