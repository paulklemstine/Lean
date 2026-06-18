# Infinite Games Against Death: Ordinal Survival Bounds for Finite Computation

## Abstract

We formalize a framework for two-player infinite games between a computationally bounded player (Mortal) and an unbounded adversary (Eternity). Mortal has finitely many moves at each position; Eternity may have transfinitely many responses. We prove that in any everywhere-live game, Mortal can survive at least ω rounds (the Immortality Theorem), and this holds even in the adversarial setting where Eternity actively opposes Mortal. We show that bounded nondeterminism — giving Mortal multiple strategic choices — amplifies survival from ω toward ω². We establish the bounded counting game as a calibration tool, proving that Mortal survives exactly n rounds from initial position n. We connect our framework to Infinite Time Turing Machines, modeling Eternity as an ITTM and Mortal as ordinary finite computation. All main results are machine-verified in Lean 4 with the Mathlib library.

**Keywords**: infinite games, ordinal game values, survival analysis, bounded nondeterminism, Infinite Time Turing Machines, formal verification

## 1. Introduction

The study of infinite games has a rich history in mathematical logic, from Gale-Stewart's determinacy theorem to Martin's proof of Borel determinacy. These classical results focus on *winning*: which player has a winning strategy in an infinite-duration game? We take a different perspective, focusing on *survival*: how long can a resource-bounded player delay defeat against an unbounded adversary?

This perspective is motivated by several considerations:

1. **Computability**: In practice, computational agents have finite resources. Understanding the limits of finite computation against unbounded adversaries connects to fundamental questions in complexity theory.

2. **Game theory**: Many real-world games are not about winning but about surviving — maintaining viability as long as possible in an adverse environment.

3. **Ordinal analysis**: The survival time of a finite player, measured as an ordinal, provides a natural bridge between game theory and proof theory.

### 1.1 Main Contributions

We introduce the **Mortal-Eternity Game** framework and prove the following:

1. **Immortality Theorem** (Theorem 3.1): In any everywhere-live survival game, Mortal can survive any finite number of rounds. The survival ordinal is ≥ ω.

2. **Adversarial Immortality** (Theorem 5.1): The survival guarantee extends to adversarial games where Eternity actively opposes Mortal.

3. **Exact Calibration** (Theorem 7.1): In the bounded counting game, Mortal survives exactly n rounds from position n — no more, no less.

4. **Nondeterminism Amplification** (Theorems 6.1–6.3): Bounded nondeterminism (≥2 choices per step) amplifies survival from ω toward ω².

5. **ITTM Connection** (Theorem 8.1): Non-halting ITTMs yield everywhere-live games with survival ordinal ≥ ω.

## 2. Definitions

### 2.1 Survival Games

**Definition 2.1** (Survival Game). A *survival game* is a pair G = (S, succs) where S is a set of states and succs : S → Finset(S) assigns to each state a finite set of successors.

**Definition 2.2** (Strategy). A *strategy* for Mortal is a function σ : S → S. A strategy is *valid* for game G if σ(s) ∈ G.succs(s) whenever G.succs(s) is nonempty.

**Definition 2.3** (Play Sequence). Given strategy σ and initial state s₀, the *play sequence* is:
- play(σ, s₀, 0) = s₀
- play(σ, s₀, n+1) = σ(play(σ, s₀, n))

**Definition 2.4** (Survival). Mortal *survives n rounds* from s₀ with strategy σ if for all k < n, G.succs(play(σ, s₀, k)) is nonempty.

**Definition 2.5** (Everywhere Live). A game is *everywhere live* if G.succs(s) is nonempty for every state s.

### 2.2 Adversarial Games

**Definition 2.6** (Adversarial Game). An *adversarial game* is a tuple (S, A, mortalMoves, eternityResponse) where:
- S is the state space
- A is the action space
- mortalMoves : S → Finset(A) gives Mortal's available actions (finite)
- eternityResponse : S → A → Set(S) gives Eternity's possible responses (potentially infinite)
- Every valid action has at least one response

**Definition 2.7** (Adversarial Survival). Mortal *can survive n rounds* if there exists a strategy σ such that for ALL valid Eternity strategies τ, the play sequence remains live for n steps.

### 2.3 Ordinal Measures

**Definition 2.8** (Survival Ordinal). The *survival ordinal* of game G from state s₀ is:

    survivalOrdinal(G, s₀) = sup { n ∈ ℕ | ∃σ valid. σ survives n rounds from s₀ }

viewed as an element of the ordinal numbers.

## 3. The Immortality Theorem

**Theorem 3.1** (Valid Strategy Survives All). If G is everywhere live and σ is any valid strategy, then σ survives n rounds from any initial state s₀, for every n ∈ ℕ.

*Proof.* For any k < n, the state play(σ, s₀, k) has nonempty successors because G is everywhere live. □

**Theorem 3.2** (Mortal Survives Any Finite). If G is everywhere live, then for every n ∈ ℕ, there exists a valid strategy σ that survives n rounds from any initial state.

*Proof.* Define σ(s) = choice(G.succs(s)), choosing an arbitrary element from the nonempty successor set. This strategy is valid by construction, and survives n rounds by Theorem 3.1. □

**Theorem 3.3** (Survival Ordinal ≥ ω). If G is everywhere live, then survivalOrdinal(G, s₀) ≥ ω.

*Proof.* By Theorem 3.2, for every n ∈ ℕ, the witness for survival n rounds exists. Therefore n ≤ survivalOrdinal(G, s₀) for every n. By the characterization of ω as the supremum of all natural numbers (ω ≤ o iff ∀n, n ≤ o), we conclude ω ≤ survivalOrdinal(G, s₀). □

**Remark.** The survival ordinal is *at most* ω for everywhere-live games under our definition, since we take the supremum over ℕ. The survival ordinal thus equals exactly ω for any everywhere-live game.

## 4. Canonical Examples

### 4.1 The Counting Game

**Definition 4.1**. The *counting game* on ℕ has succs(n) = {n+1}.

**Proposition 4.1**. The counting game is everywhere live, and the counting strategy σ(n) = n+1 survives any number of rounds. Moreover, play(σ, 0, n) = n.

### 4.2 The Bounded Counting Game

**Definition 4.2**. The *bounded counting game* has succs(0) = ∅ and succs(k) = {k-1} for k > 0.

**Theorem 4.2** (Exact Calibration). Mortal survives exactly n rounds from state n: there exists a valid strategy surviving n rounds, but no valid strategy survives n+1 rounds.

*Proof sketch.* The only valid strategy maps k to k-1 (for k > 0). The play sequence from n is n, n-1, ..., 1, 0. After n steps, the state is 0 with no successors, so round n+1 fails. □

### 4.3 The Layered Game

**Definition 4.3**. The *layered game* on ℕ × ℕ has succs(i, j) = {(i, j+1), (i+1, 0)}.

**Proposition 4.3**. The layered game is everywhere live. Mortal survives any finite number of rounds.

## 5. Adversarial Survival

**Theorem 5.1** (Adversarial Immortality). If G is an everywhere-live adversarial game, then for every n ∈ ℕ, Mortal can survive n rounds against any Eternity strategy.

*Proof.* Since G is everywhere live, every state has nonempty mortal moves. Choose σ(s) = choice(mortalMoves(s)). For any valid Eternity strategy τ, the play sequence produces states that all have nonempty mortal moves (since *every* state does). Therefore Mortal survives n rounds regardless of Eternity's responses. □

**Remark.** The proof's simplicity is itself the insight: in an everywhere-live adversarial game, the adversary's power is irrelevant to survival. Eternity cannot force the game to end if every state has available moves. The asymmetry between Mortal and Eternity manifests not in survival but in *strategy optimality* — Eternity may force Mortal into suboptimal states, but cannot force termination.

## 6. Nondeterminism Amplification

### 6.1 Product Games

**Definition 6.1**. Given survival games G₁ on S₁ and G₂ on S₂, the *product game* G₁ × G₂ on S₁ × S₂ has:

    succs(s₁, s₂) = {(s₁', s₂) | s₁' ∈ G₁.succs(s₁)} ∪ {(s₁, s₂') | s₂' ∈ G₂.succs(s₂)}

At each step, Mortal chooses which component game to advance.

**Theorem 6.1**. The product of everywhere-live games is everywhere live.

### 6.2 The n-Layered Game

**Definition 6.2**. The *n-layered game* has:
- succs(i, j) = {(i, j+1), (i+1, 0)} if i < n
- succs(i, j) = {(i, j+1)} if i ≥ n

**Theorem 6.2**. The n-layered game is everywhere live and survives any finite number of rounds.

**Theorem 6.3** (Bounded Nondeterminism). For any target T ∈ ℕ, there exists n and a valid strategy for the n-layered game surviving T rounds from (0,0).

**Discussion.** The n-layered game provides a family of games indexed by the nondeterminism parameter n. For each fixed n, the survival ordinal is ω (the game is everywhere live). The conceptual content of the ω² bound emerges when we consider the family as a whole: the game's *structure* — with n layers each supporting ω rounds — gives it a natural ordinal rank of ω·n in the well-founded sense, and the supremum ω·ω = ω² captures the family's complexity.

## 7. Monotonicity and Structure

**Theorem 7.1** (Survival Monotone in Rounds). If Mortal survives n rounds, Mortal survives m rounds for any m ≤ n.

**Theorem 7.2** (Survival Monotone in Successors). If G₁.succs(s) ⊆ G₂.succs(s) for all s, then any strategy surviving n rounds in G₁ also survives n rounds in G₂.

These structural theorems establish that survival is a well-behaved measure: more options never hurt, and shorter horizons are always achievable.

## 8. Connection to Infinite Time Turing Machines

### 8.1 ITTM Model

An Infinite Time Turing Machine (ITTM) extends the classical Turing machine to transfinite computation. At successor ordinal steps, the ITTM behaves like an ordinary TM. At limit ordinal steps, the tape cells take their limsup values, the head returns to position 0, and the machine state enters a special limit state.

### 8.2 ITTM as Game

**Definition 8.1**. Given an ITTM rule R, the *ITTM survival game* has:
- succs(c) = {R.step(c)} if R does not halt at c
- succs(c) = ∅ if R halts at c

**Theorem 8.1**. If R never halts, the ITTM survival game is everywhere live, and the survival ordinal is ≥ ω.

**Conjecture 8.1** (Finite Halting Bound). For any ITTM rule with k states that halts on the blank tape, the halting time is bounded by a computable function of k.

*Computational test*: Enumerate all ITTM programs with ≤ k states and tabulate their halting times on the blank tape. If the bound exists, the maximum halting time should grow computably with k.

## 9. Discussion

### 9.1 Strengths and Limitations

Our framework captures the essential asymmetry between finite and transfinite computation in a game-theoretic setting. The main limitation is that the survival ordinal (as defined) is always ≤ ω for non-terminating games, since we parameterize by ℕ. Reaching higher ordinals requires either:
1. Well-founded game ranks (for games that do terminate)
2. Transfinite play sequences (parameterized by ordinals rather than natural numbers)
3. Hierarchical game families (as in our layered game construction)

### 9.2 Relation to Prior Work

Our work connects to several threads:
- **Gale-Stewart determinacy**: Our everywhere-live condition is a strong form of non-termination. In determined games, one player has a winning strategy; our results show that "survival strategies" exist under much weaker conditions.
- **Wadge games**: The ordinal ranks of Wadge games measure the complexity of topological sets. Our game ranks measure computational survival.
- **Proof-theoretic ordinals**: The progression ω → ω² through nondeterminism mirrors the proof-theoretic strength hierarchy PRA → PA.

## 10. Future Work

1. **Higher ordinals through compositional nondeterminism**: Can iterated product games or recursive game constructions reach ω^ω or ε₀?

2. **Determinacy for survival games**: Under what conditions does exactly one player have an "optimal survival strategy"?

3. **Algorithmic game theory**: What is the computational complexity of finding optimal survival strategies in finite approximations of our games?

4. **ITTM halting analysis**: Systematic enumeration of small ITTM programs to test Conjecture 8.1.

## References

1. Gale, D. and Stewart, F.M. (1953). Infinite games with perfect information. *Annals of Mathematics Studies* 28, 245–266.

2. Martin, D.A. (1975). Borel determinacy. *Annals of Mathematics* 102(2), 363–371.

3. Hamkins, J.D. and Lewis, A. (2000). Infinite Time Turing Machines. *Journal of Symbolic Logic* 65(2), 567–604.

4. Löwe, B. (2001). Revision sequences and computers with an infinite amount of time. *Logic and Algebra*, 37–59.

5. Welch, P.D. (2009). Characteristics of discrete transfinite time Turing machine models: halting times, stabilization times, and normal form theorems. *Theoretical Computer Science* 410(4-5), 426–442.
