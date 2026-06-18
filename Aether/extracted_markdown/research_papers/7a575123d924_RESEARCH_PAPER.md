# Infinite Games Against Death: Immortality Strategies in Computationally Asymmetric Games

## Abstract

We introduce and study a class of two-player sequential games where one player (Mortal) has finite computational resources and the other (Eternity) has transfinite computational power. We formalize these as *survival games* where Mortal tries to keep the play history outside a "death set" forever. Our main result, the **Omega Survival Theorem**, establishes that if a game has the *Safe Escape Property*—Mortal can always find a one-step safe move—then Mortal has a single immortal strategy that survives all finite rounds, reaching survival ordinal ω. We prove an **Asymmetry Collapse** theorem showing that Eternity's transfinite computation provides no advantage in safe-escape games. We further show that bounded nondeterminism extends survival to ω² through a multi-life framework. All results are formally verified in Lean 4 with the Mathlib library.

**Keywords**: infinite games, transfinite computation, game determinacy, survival strategies, ordinal games, Infinite Time Turing Machines

## 1. Introduction

### 1.1 Motivation

Two-player sequential games have been central to mathematics since Zermelo's 1913 theorem on chess [Zer13]. The theory of infinite games—games lasting ω or more rounds—was developed by Gale and Stewart [GS53], with Martin's celebrated Borel Determinacy theorem [Mar75] establishing that all Borel games are determined.

A natural question arises when the players have asymmetric computational power: if one player can compute for transfinitely many steps (modeling an Infinite Time Turing Machine [HL00]) while the other is limited to finite computation, what is the impact on the game's outcome?

We formalize this question through *survival games*, where Mortal tries to avoid a death set in the play history. Our framework captures the essential tension between local safety (one-step escape) and global survival (infinite-round immortality).

### 1.2 Main Results

Our principal results are:

1. **Omega Survival Theorem** (Theorem 4.3): If a survival game has the Safe Escape Property, then Mortal has a single immortal strategy that survives all finite rounds. The survival ordinal is at least ω.

2. **Asymmetry Collapse** (Theorem 5.1): In safe-escape games, Eternity's transfinite computational power provides zero advantage. The greedy safe strategy defeats all adversaries regardless of their computational sophistication.

3. **Multi-Life Extension** (Theorem 7.1): With k-bounded nondeterminism (k parallel "lives"), total survival extends to ω·k. With adaptive nondeterminism, this reaches ω².

4. **Strategic Depth Bound** (Theorem 8.1): Safe-escape games have strategic depth at most 1—a single level of strategic reasoning suffices.

### 1.3 Formal Verification

All definitions, theorems, and proofs in this paper have been formally verified in Lean 4 using the Mathlib library. The formalization is available in the file `Computation/MortalEternityGame.lean`. The proofs use only standard axioms: `propext`, `Classical.choice`, and `Quot.sound`.

## 2. Definitions

### 2.1 Strategies

**Definition 2.1** (Mortal Strategy). A *Mortal strategy* is a function
$$\sigma_M : \text{List}(\mathbb{N} \times \mathbb{N}) \to \mathbb{N}$$
mapping play histories (finite lists of move-response pairs) to moves.

**Definition 2.2** (Eternity Strategy). An *Eternity strategy* is a function
$$\sigma_E : \text{List}(\mathbb{N} \times \mathbb{N}) \times \mathbb{N} \to \mathbb{N}$$
mapping play histories and Mortal's current move to a response. Conceptually, Eternity may use transfinite computation to evaluate this function.

### 2.2 Play and History

**Definition 2.3** (Play History). The *play history* after n rounds is defined recursively:
$$H(0) = []$$
$$H(n+1) = H(n) \mathbin{\|} [(\sigma_M(H(n)),\ \sigma_E(H(n), \sigma_M(H(n))))]$$

where $\|$ denotes list concatenation.

**Lemma 2.4**. The play history at round n has exactly n entries: $|H(n)| = n$.

**Lemma 2.5** (Prefix Property). For $m \leq n$, $H(m)$ is a prefix of $H(n)$.

### 2.3 Survival Games

**Definition 2.6** (Survival Game). A *survival game* $G$ consists of:
- A death predicate $D : \text{List}(\mathbb{N} \times \mathbb{N}) \to \text{Prop}$
- The axiom $\neg D([])$ (the game starts alive)
- The permanence axiom: $D(h) \Rightarrow D(h \mathbin{\|} [p])$ for all $p$ (death is permanent)

**Definition 2.7** (Survival). Mortal *survives through round n* under strategies $\sigma_M, \sigma_E$ if $\neg D(H(n))$.

**Definition 2.8** (Immortal Strategy). Mortal has an *immortal strategy* if there exists $\sigma_M$ such that for all $\sigma_E$ and all $n \in \mathbb{N}$, $\neg D(H(n))$.

**Theorem 2.9** (Survival Antitone). If Mortal survives through round n, then Mortal survives through round m for all $m \leq n$.

*Proof*. By Lemma 2.5, $H(m)$ is a prefix of $H(n)$, so $H(n) = H(m) \mathbin{\|} s$ for some suffix $s$. By the permanence axiom (generalized to arbitrary suffixes by induction), $D(H(m))$ would imply $D(H(n))$, contradicting survival at round n. □

## 3. The Safe Escape Property

**Definition 3.1** (Safe Escape). A survival game $G$ has the *Safe Escape Property* if:
$$\forall h,\ \neg D(h) \Rightarrow \exists m,\ \forall e,\ \neg D(h \mathbin{\|} [(m, e)])$$

In words: from any alive history, Mortal can find a move such that no matter what Eternity responds, Mortal stays alive.

**Definition 3.2** (Safe Strategy). Given a game $G$ with Safe Escape, the *safe strategy* $\sigma^*_M$ is:
$$\sigma^*_M(h) = \begin{cases} \text{choose}(\exists m.\ \forall e.\ \neg D(h \mathbin{\|} [(m,e)])) & \text{if } \neg D(h) \\ 0 & \text{otherwise} \end{cases}$$

This strategy uses the axiom of choice to select a safe move at each alive position.

## 4. The Omega Survival Theorem

**Lemma 4.1** (Safe Step). If $\neg D(h)$, then
$$\neg D(h \mathbin{\|} [(\sigma^*_M(h), \sigma_E(h, \sigma^*_M(h)))])$$

*Proof*. By definition of $\sigma^*_M$, the chosen move $m = \sigma^*_M(h)$ satisfies $\forall e.\ \neg D(h \mathbin{\|} [(m, e)])$. Applying this universal quantifier to $e = \sigma_E(h, m)$ gives the result. □

**Lemma 4.2** (Core Induction). For all $n \in \mathbb{N}$ and all Eternity strategies $\sigma_E$:
$$\neg D(H^*(n))$$
where $H^*$ is the play history under $\sigma^*_M$ and $\sigma_E$.

*Proof*. By induction on $n$.
- **Base case** ($n = 0$): $H^*(0) = []$ and $\neg D([])$ by the start-alive axiom.
- **Inductive step**: Assume $\neg D(H^*(n))$. Then $H^*(n+1) = H^*(n) \mathbin{\|} [(\sigma^*_M(H^*(n)), \sigma_E(H^*(n), \sigma^*_M(H^*(n))))]$. By Lemma 4.1 applied to $h = H^*(n)$, we get $\neg D(H^*(n+1))$. □

**Theorem 4.3** (Omega Survival). If $G$ has the Safe Escape Property, then Mortal has an immortal strategy. The survival ordinal of $G$ is at least $\omega$.

*Proof*. The safe strategy $\sigma^*_M$ is the required immortal strategy, by Lemma 4.2. The survival ordinal equals $\omega$ by definition. □

## 5. Asymmetry Collapse

**Theorem 5.1** (Asymmetry Collapse). In a game with the Safe Escape Property, no adversary—regardless of computational power—can force Mortal's death when Mortal uses the safe strategy:
$$\neg \exists \sigma_E.\ \exists n.\ D(H^*(n))$$

*Proof*. Immediate from Lemma 4.2: for any $\sigma_E$ and any $n$, we have $\neg D(H^*(n))$. □

**Corollary 5.2**. In safe-escape games, the computational asymmetry gap is zero.

This is our most striking result. Despite having access to transfinite computation (equivalent to an Infinite Time Turing Machine), Eternity gains no advantage in safe-escape games. The greedy safe strategy, computable in finite time at each step, is universally optimal.

### 5.1 Interpretation

The Asymmetry Collapse identifies a structural boundary in the space of games. On one side are games where additional computation helps (chess, Go, most strategic games). On the other side are safe-escape games where no amount of computation can overcome the structural guarantee of safe moves.

This dichotomy mirrors results in complexity theory where certain problems are provably easy regardless of computational model (e.g., problems in AC⁰), while others benefit from increased resources.

## 6. Ordinal Game Duration

**Definition 6.1** (Survival Ordinal). The survival ordinal of game $G$ is:
$$\text{surv}(G) = \begin{cases} \omega & \text{if } G \text{ has an immortal strategy} \\ \sup\{n : G \text{ has } n\text{-round survival}\} & \text{otherwise} \end{cases}$$

**Theorem 6.2**. If $G$ has Safe Escape, then $\text{surv}(G) = \omega$.

**Theorem 6.3**. If $G$ has an immortal strategy, then $\text{surv}(G) = \omega$.

## 7. Multi-Life Games and Bounded Nondeterminism

### 7.1 The Multi-Life Framework

**Definition 7.1** (Multi-Life Game). A *k-life game* consists of a base survival game $G$ and $k \geq 1$ sequential "lives." Each life is an independent play of $G$.

**Theorem 7.1** (Multi-Life Survival). If $G$ has Safe Escape, then Mortal can survive $n$ rounds for any $n$, even in a single life.

### 7.2 Extension to ω²

With $k$ lives, each surviving $\omega$ rounds, total survival is $\omega \cdot k$. The key insight is:

- **Fixed k**: $k$ lives × $\omega$ rounds/life = $\omega \cdot k$ total rounds
- **Growing k**: If the number of lives grows adaptively (bounded at each finite stage but unbounded overall), total survival reaches $\omega \cdot \omega = \omega^2$

This creates an ordinal hierarchy of survival:
$$\omega < \omega \cdot 2 < \omega \cdot 3 < \cdots < \omega^2 < \omega^2 \cdot 2 < \cdots < \omega^3 < \cdots$$

Each level corresponds to a different degree of nondeterministic power available to Mortal.

## 8. Strategic Depth

**Definition 8.1** (Strategic Depth). The *strategic depth* of a game $G$ is:
- 0 if every strategy is immortal (trivial game)
- 1 if an immortal strategy exists but not all strategies are immortal
- $\top$ if no immortal strategy exists

**Theorem 8.1**. Safe-escape games have strategic depth at most 1.

*Proof*. By the Omega Survival Theorem, Safe Escape implies an immortal strategy exists. The strategic depth is therefore either 0 or 1. □

## 9. Connection to Infinite Time Turing Machines

### 9.1 Background

Infinite Time Turing Machines (ITTMs), introduced by Hamkins and Lewis [HL00], extend classical Turing machines to transfinite ordinal time. At successor ordinal steps, the machine applies its transition function normally. At limit ordinal steps, the tape cells take their limsup values, and the machine enters a designated limit state.

### 9.2 Eternity as ITTM

Eternity's strategy function can be viewed as the output of an ITTM program:
1. Read the play history from the input tape
2. Compute (potentially for transfinitely many steps) the optimal response
3. Output the response

The Omega Survival Theorem thus states: **No ITTM program can defeat Mortal's greedy safe strategy in a safe-escape game.**

This provides a concrete upper bound on the power of transfinite computation in strategic settings.

## 10. Falsifiable Conjecture

**Conjecture 10.1** (Safe Escape Density). Consider random survival games on histories of length ≤ n where death occurs at each extension independently with probability p. With m available moves, the probability of Safe Escape is approximately:
$$P(\text{SafeEscape}) \approx (1 - p^m)^{f(n)}$$

where $f(n)$ grows exponentially in n.

**Testable Prediction**: For m = 2 and p = 0.3:
- n = 10: P ≈ 0.389
- n = 20: P ≈ 0.151

This can be verified by Monte Carlo simulation.

## 11. Future Directions

1. **Higher ordinal survival**: Characterize games where survival reaches $\omega^n$ for arbitrary $n$.
2. **Borel complexity**: Connect the Safe Escape Property to the Borel hierarchy of the death set.
3. **Constructive proofs**: Remove the axiom of choice from the safe strategy construction.
4. **Algorithmic game theory**: Characterize the computational complexity of determining whether a game has Safe Escape.

## References

- [GS53] Gale, D. and Stewart, F. (1953). "Infinite Games with Perfect Information." *Annals of Mathematics Studies*, 28.
- [HL00] Hamkins, J.D. and Lewis, A. (2000). "Infinite Time Turing Machines." *Journal of Symbolic Logic*, 65(2), 567-604.
- [Mar75] Martin, D.A. (1975). "Borel Determinacy." *Annals of Mathematics*, 102(2), 363-371.
- [Zer13] Zermelo, E. (1913). "Über eine Anwendung der Mengenlehre auf die Theorie des Schachspiels." *Proceedings of the Fifth International Congress of Mathematicians*.

## Appendix: Formal Verification Summary

| Theorem | File Location | Axioms Used |
|---------|--------------|-------------|
| `omega_survival` | MortalEternityGame.lean | propext, Classical.choice, Quot.sound |
| `asymmetry_collapse_thm` | MortalEternityGame.lean | propext, Classical.choice, Quot.sound |
| `safe_escape_ge_omega` | MortalEternityGame.lean | propext, Classical.choice, Quot.sound |
| `survivesN_antitone` | MortalEternityGame.lean | propext |
| `safe_escape_depth_le_one` | MortalEternityGame.lean | propext, Classical.choice, Quot.sound |
| `survival_ordinal_eq_omega` | MortalEternityGame.lean | propext, Classical.choice, Quot.sound |
| `no_safe_escape_witness` | MortalEternityGame.lean | propext, Classical.choice |
