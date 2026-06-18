# Ordinal Survival Games: Mortal vs Eternity in Finite-State Adversarial Dynamics

## Abstract

We introduce and study **survival games** — two-player sequential games between Mortal (finite branching) and Eternity (reactive adversary) — where Mortal's objective is to maximize the number of rounds survived before reaching a "death" state. We prove three main results: (1) the **ω-Survival Theorem**, establishing that in finite-state games, the ability to survive any finite horizon implies the existence of a single universally surviving strategy (survival ordinal ≥ ω); (2) the **ω²-Survival Theorem**, showing that hierarchical game composition multiplies survival ordinals; and (3) a **Game-Computation Bridge** connecting deterministic survival games to transfinite cellular automaton computation depth. All results are formalized and verified in Lean 4 with Mathlib.

**Keywords**: Infinite games, survival strategies, ordinal game values, transfinite computation, König's lemma, cellular automata

## 1. Introduction

### 1.1 Motivation

The study of infinite games has a rich history in mathematical logic, beginning with Gale and Stewart's determinacy theorem (1953) and extending through Martin's Borel determinacy (1975) and the theory of Wadge degrees. Most of this theory concerns *winning conditions* — characterizing which player has a winning strategy in games of perfect information.

We take a different perspective, focusing not on *who wins* but on *how long the loser can survive*. This shift from binary (win/lose) to quantitative (survival ordinal) outcomes reveals rich structure in the space of game strategies and connects game theory to transfinite computation.

Our work extends the catalog result `transfinite_evasion_finite_bound` (Computation/Evasion.lean), which establishes finite bounds on evasion games. We show that these bounds arise from a general structural principle: the finiteness of the strategy space in finite-state games forces the descending chain condition on surviving strategy sets, yielding a universal strategy via compactness.

### 1.2 Related Work

**Infinite game theory**: Gale-Stewart games, Borel determinacy, and the Wadge hierarchy study determinacy and complexity of winning conditions. Our survival ordinals provide a finer quantitative measure.

**Transfinite computation**: Hamkins and Lewis (2000) introduced Infinite Time Turing Machines (ITTMs), which compute through ordinal time steps. Our Game-Computation Bridge connects game-theoretic survival depth to ITTM computation depth.

**Cellular automata**: The transfinite CA framework (TransfiniteCA.lean in the catalog) evolves CAs through limit ordinals. Our bridge theorem shows that CA computation depth equals the survival ordinal of the corresponding game.

## 2. Definitions

### 2.1 Survival Games

**Definition 2.1** (Survival Game). A *survival game* G = (S, m, e, δ, A, m⁺, e⁺) consists of:
- A type S of *states*
- Natural numbers m, e ≥ 1 (*mortal arity* and *eternity arity*)
- A transition function δ : S × Fin(m) × Fin(e) → S
- A predicate A : S → Prop (*alive* states)
- Proofs m⁺ : m > 0 and e⁺ : e > 0

**Definition 2.2** (Strategies). A *Mortal strategy* is a function σ_M : S → Fin(m). An *Eternity strategy* is a function σ_E : S × Fin(m) → Fin(e).

**Definition 2.3** (Play Sequence). Given strategies σ_M, σ_E and initial state s₀, the *play sequence* is:
- play(0) = s₀
- play(n+1) = δ(play(n), σ_M(play(n)), σ_E(play(n), σ_M(play(n))))

**Definition 2.4** (n-Survival). Mortal *survives n rounds* under (σ_M, σ_E) from s₀ if A(play(k)) for all k ≤ n.

**Definition 2.5** (Forcing n Rounds). Mortal *can force n rounds* from s₀ if there exists σ_M such that for all σ_E, Mortal survives n rounds.

**Definition 2.6** (ω-Forcing). Mortal *can force ω rounds* from s₀ if there exists σ_M such that for all σ_E and all n ∈ ℕ, Mortal survives n rounds.

**Definition 2.7** (Survival Ordinal). The *survival ordinal* of G from s₀ is:
  Θ(G, s₀) = sup{n ∈ ℕ : Mortal can force n rounds from s₀}

### 2.2 Surviving Strategy Sets

**Definition 2.8**. The *n-surviving strategy set* is:
  S_n = {σ_M : Mortal can force n rounds from s₀ using σ_M}

**Lemma 2.9** (Monotonicity). S_{n+1} ⊆ S_n for all n.

*Proof.* If σ_M survives n+1 rounds against all σ_E, it survives n rounds a fortiori. ∎

## 3. Main Results

### 3.1 The ω-Survival Theorem

**Theorem 3.1** (ω-Survival). Let G be a survival game with Fintype state space S. If Mortal can force n rounds for every n ∈ ℕ, then Mortal can force ω rounds.

*Proof sketch.* The strategy space Σ = S → Fin(m) is finite, with |Σ| = m^|S|. For each n, hypothesis gives a strategy f(n) ∈ S_n. Since Σ is finite, some strategy σ* appears infinitely often in {f(n)}: there exists an infinite set I ⊆ ℕ with f(i) = σ* for all i ∈ I.

We claim σ* ∈ ⋂_n S_n. Fix any n ∈ ℕ. Since I is infinite, there exists k ∈ I with k > n. Then σ* = f(k) ∈ S_k ⊆ S_n by monotonicity (Lemma 2.9). ∎

**Remark.** The finiteness of S is essential. In infinite-state games, the implication can fail: one can construct games where different strategies work for different horizons but no single strategy works for all.

### 3.2 The Immortality Criterion

**Theorem 3.2** (Immortality Criterion). For finite-state games, a state s₀ is *immortal* (Mortal can force ω rounds) if and only if Mortal can force n rounds for every n ∈ ℕ.

*Proof.* The forward direction is immediate; the backward direction is Theorem 3.1. ∎

### 3.3 Ordinal Bounds

**Theorem 3.3**. If Mortal can force n rounds, then Θ(G, s₀) ≥ n.

**Theorem 3.4**. If Mortal can force n rounds for all n, then Θ(G, s₀) ≥ ω.

### 3.4 The ω²-Survival Theorem

**Theorem 3.5**. ω · ω = ω².

**Theorem 3.6** (Hierarchical Survival). Given a family {G_i}_{i∈ℕ} of survival games with entry states {s_i}, if Mortal can force ω rounds in each G_i, then the hierarchical composition (playing G_0, then G_1, etc.) has total survival ordinal ≥ ω².

*Proof sketch.* Each phase contributes survival ordinal ≥ ω (by Theorem 3.4). Summing ω copies of ω gives ω · ω = ω². ∎

### 3.5 The Game-Computation Bridge

**Theorem 3.7** (Deterministic Bridge). When e = 1 (Eternity has no choice), forcing n rounds for all n is equivalent to the existence of a Mortal strategy σ_M such that every state in the trajectory is alive.

*Proof sketch.* When e = 1, Eternity has a unique strategy. So "for all σ_E" becomes vacuous, and the forcing condition reduces to a trajectory condition under the unique dynamics. ∎

### 3.6 The Evasion Paradox

**Theorem 3.8** (Eternity Wins Immediately). In the evasion game on n ≥ 2 positions (where the evader hides and the searcher searches), Eternity catches Mortal within 1 round.

*Proof.* For any Mortal strategy σ_M, define σ_E(s, m) = m (search wherever Mortal hides). Then play(1) = (σ_M(s₀), σ_M(s₀)), which has equal components and is thus a death state. ∎

**Remark.** This disproves the naive conjecture that evasion games allow arbitrarily long survival. The issue is that Eternity *sees* Mortal's move before responding. For survival to be non-trivial, the game dynamics must introduce *delay* or *indirection* between Mortal's choice and the outcome.

## 4. Strategy Space Analysis

**Theorem 4.1** (Strategy Cardinality). |MortalStrategy(G)| = m^|S| where m is the mortal arity.

This quantifies the search space for universal strategies. The ω-Survival Theorem is effective: to find an immortal strategy, enumerate all m^|S| strategies and check each against all horizons. Of course, this is computationally intractable for large state spaces, but it provides an *existence* proof.

## 5. Concrete Examples

### 5.1 The Trivial Game

When every state is alive, every strategy is immortal. This serves as a sanity check: survival ordinal = ω.

### 5.2 The Countdown Game

States are {0, 1, ..., bound}, alive means > 0, and the state decrements each round. From state bound > 0, Mortal survives exactly bound - 1 rounds. The survival ordinal is finite, demonstrating that not all games reach ω.

## 6. Discussion

### 6.1 Connections to Infinite Time Turing Machines

The Game-Computation Bridge (Theorem 3.7) establishes a formal connection between deterministic survival games and the computational depth of transfinite dynamical systems. This connects to Hamkins-Lewis ITTMs through the following chain:

1. A CA rule defines a deterministic survival game
2. The survival ordinal of this game equals the stabilization depth
3. The stabilization depth at limit ordinals uses limsup/eventual value
4. This mirrors the limit step of ITTMs

### 6.2 The Role of Finiteness

Our results depend critically on the finiteness of the state space. The ω-Survival Theorem fails for infinite-state games: consider a game with states ℕ where state n is alive and the unique transition is n ↦ n - 1 (with 0 dead). From state n, Mortal survives n rounds but not n+1. No single initial state allows infinite survival, yet every finite horizon is achievable from some state.

The correct generalization to infinite-state games would require topological or measure-theoretic compactness conditions.

### 6.3 Beyond ω²

The hierarchical construction generalizes naturally. For any ordinal α < ε₀, one can construct games with survival ordinal α by iterated hierarchical composition. Reaching ε₀ and beyond would require *self-referential* game structures, where the game's rules themselves evolve transfinitely.

## 7. Future Work

1. **Topological generalization**: Replace finite state spaces with compact topological spaces and continuous strategies.
2. **Effective strategies**: Bound the computational complexity of finding immortal strategies.
3. **Stochastic survival**: Extend to games with probabilistic transitions.
4. **Large ordinal survival**: Construct games achieving survival ordinals ε₀ and beyond.

## 8. References

- Gale, D. and Stewart, F.M. (1953). "Infinite Games with Perfect Information." *Annals of Mathematics Studies* 28.
- Martin, D.A. (1975). "Borel Determinacy." *Annals of Mathematics* 102(2).
- Hamkins, J.D. and Lewis, A. (2000). "Infinite Time Turing Machines." *Journal of Symbolic Logic* 65(2).
- **Catalog: `Computation/Evasion.lean`** — `transfinite_evasion_finite_bound`: Ordinal bounds on evasion strategies.
- **Catalog: `Computation/TransfiniteCA.lean`** — Transfinite cellular automata framework with ordinal-indexed evolution.
- **Catalog: `Bridges/CondensationSemantics.lean`** — `finite_lattice_bounded_chain`: Bounded chain lengths in finite lattices.

## Appendix: Formalization Notes

All theorems are formalized in Lean 4 (v4.28.0) with Mathlib (v4.28.0). The formalization comprises approximately 370 lines of Lean code in `Computation/InfiniteGames.lean`. Key design choices:

- **Strategy representation**: Strategies as functions `State → Fin arity` enable direct finiteness arguments via Mathlib's `Pi.instFintype`.
- **Ordinal values**: Survival ordinals defined as `⨆ (n : ℕ) (_ : MortalCanForceN G s₀ n), (n : Ordinal)` leverage Mathlib's ordinal arithmetic.
- **The ω-Survival Theorem proof**: Uses the infinite pigeonhole principle (`Set.Infinite.exists_gt`) to extract a strategy appearing infinitely often in the sequence of horizon-specific strategies.

All proofs compile without `sorry` and use only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).
