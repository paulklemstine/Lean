# Ordinal Arenas and Immortality Strategies: A Theory of Asymmetric Infinite Games

## Abstract

We develop a rigorous theory of two-player survival games with asymmetric computational power. Player **Mortal** has finite computation; player **Eternity** has transfinite computation. We introduce the **Ordinal Arena**, a novel mathematical structure equipping survival games with ordinal-valued rank functions, and prove three main results:

1. **Omega Survival Theorem**: If a game satisfies the *Safe Escape* property (at every alive position, Mortal has a move safe against all responses), then Mortal has a single greedy strategy guaranteeing survival for all finite rounds — an ordinal duration of ω.

2. **Asymmetry Collapse Theorem**: In safe-escape games, Eternity's transfinite computational advantage provides zero additional killing power. The asymmetry gap between finite and infinite computation collapses completely.

3. **ω²-Survival Theorem**: With adaptive bounded nondeterminism (an unbounded sequence of independent game layers), Mortal's total survival duration reaches ω² = ω·ω.

All results are formalized and machine-verified in Lean 4 with Mathlib, with no axioms beyond the standard foundations (propext, Classical.choice, Quot.sound).

**Keywords**: Infinite games, ordinal arithmetic, transfinite computation, game theory, survival strategies, Lean 4

## 1. Introduction

### 1.1 Motivation

The interplay between finite and infinite computation is a central theme in mathematical logic, from Turing's original work on computability to Hamkins and Lewis's Infinite Time Turing Machines (ITTMs) [1]. A natural question arises: in an adversarial setting, how much does infinite computational power actually help?

We address this through **survival games** — a two-player perfect-information game where Mortal (finite computation) tries to avoid a "death set" while Eternity (transfinite computation) tries to force Mortal into it. The game produces a history of (move, response) pairs, and the death predicate is monotone: once dead, extending the history keeps the game dead.

### 1.2 Prior Work

Zermelo's theorem (1913) established determinacy of finite games [2]. Martin's Borel Determinacy theorem (1975) extended this to infinite games with Borel payoff sets [3]. Our framework differs from the classical Gale-Stewart game setting in two key ways:

1. **Asymmetric computation**: We explicitly model the computational gap between players, rather than treating both as having equal access to strategies.
2. **Survival semantics**: The payoff is not win/lose but *survival duration*, measured as an ordinal.

The connection to ITTMs [1] arises naturally: the ordinal duration of a survival game corresponds to the computational complexity class accessible at that ordinal level of the ITTM hierarchy.

### 1.3 Contributions

- **Ordinal Arena** (Definition 6.1): A novel mathematical structure combining survival games with ordinal-valued rank functions, enabling precise measurement of game complexity.
- **Arena Strategy** (Definition 6.3): A strategy that exploits rank descent to guarantee both survival and measurable progress.
- **Strategy Refinement Preorder** (Section 12): A preorder on strategies based on survival inclusion.
- **Game Product** (Section 13): Parallel composition of survival games with component-wise analysis.

## 2. Definitions

### 2.1 Core Objects

**Definition 2.1** (Mortal Strategy). A *Mortal strategy* is a function `ms : List(ℕ × ℕ) → ℕ` mapping game histories to moves.

**Definition 2.2** (Eternity Strategy). An *Eternity strategy* is a function `es : List(ℕ × ℕ) → ℕ → ℕ` mapping histories and Mortal's current move to a response.

**Definition 2.3** (Play Rounds). For strategies ms and es, the play history after n rounds is defined recursively:
- `playRounds ms es 0 = []`
- `playRounds ms es (n+1) = playRounds ms es n ++ [(ms hist, es hist (ms hist))]` where `hist = playRounds ms es n`.

**Definition 2.4** (Survival Game). A *survival game* G consists of:
- A death predicate `hasDied : List(ℕ × ℕ) → Prop`
- An axiom `start_alive : ¬hasDied []`
- A monotonicity axiom `death_permanent : ∀ hist pair, hasDied hist → hasDied (hist ++ [pair])`

### 2.2 Survival Notions

**Definition 2.5** (Finite Survival). Mortal *survives N rounds* with strategies ms, es if `¬G.hasDied (playRounds ms es N)`.

**Definition 2.6** (Guaranteed Survival). Mortal *can guarantee survival for N rounds* if `∃ ms, ∀ es, survivesN G ms es N`.

**Definition 2.7** (Immortal Strategy). Mortal has an *immortal strategy* if `∃ ms, ∀ es, ∀ n, survivesN G ms es n`.

**Theorem 2.8** (Antitone Survival). Survival is antitone: `m ≤ n → survivesN G ms es n → survivesN G ms es m`. *Proof*: By the prefix property of play histories and monotonicity of death.

## 3. The Safe Escape Property

**Definition 3.1** (Safe Escape). A game G has *Safe Escape* if: for all histories hist with ¬G.hasDied hist, there exists a move m such that for all responses e, ¬G.hasDied(hist ++ [(m,e)]).

This is a pointwise condition: at each alive position, Mortal has at least one move that maintains aliveness regardless of Eternity's response.

**Definition 3.2** (Safe Strategy). Given SafeEscape, the *safe strategy* picks, at each alive history, a move m witnessing the SafeEscape condition. At dead histories (which are unreachable under the safe strategy), it defaults to 0.

## 4. Omega Survival Theorem

**Theorem 4.1** (Omega Survival). If G has Safe Escape, then G has an immortal strategy.

*Proof sketch*: The safe strategy suffices. By induction on n:
- **Base**: Round 0 — the empty history is alive by start_alive.
- **Step**: If alive at round n, the safe strategy picks a safe move, and SafeEscape guarantees aliveness at round n+1.

The theorem is named for ω because the immortal strategy survives all rounds n ∈ ℕ, achieving an ordinal survival duration of sup{n : n ∈ ℕ} = ω.

**Corollary 4.2** (Survival Ordinal). For safe-escape games, `survivalOrdinal G = ω`.

## 5. Asymmetry Collapse

**Theorem 5.1** (Asymmetry Collapse). In safe-escape games, no Eternity strategy can kill a Mortal using the safe strategy:
`¬∃ es, ∃ n, G.hasDied (playRounds (safeStrategy G hse) es n)`.

*Proof*: Direct from Theorem 4.1 — the safe strategy survives all rounds against all strategies.

**Discussion**: This result is surprising because Eternity's strategy space is vastly larger than Mortal's. An Eternity strategy can in principle encode any function from histories to responses, including non-computable functions. Yet this additional power is useless against the safe strategy.

The collapse occurs because SafeEscape is a *pointwise* condition. Eternity's global planning ability cannot overcome Mortal's local safety guarantee. This parallels the way local-to-global principles work in algebraic topology: a locally contractible space need not be globally simple, but local contractibility suffices for certain global properties.

## 6. Ordinal Arena

**Definition 6.1** (Ordinal Arena). An *Ordinal Arena* extends a survival game with:
- `rank : List(ℕ × ℕ) → Ordinal` — ordinal rank of each position
- `rank_start : rank [] > 0` — positive initial rank
- `rank_dead : hasDied hist → rank hist = 0` — dead positions have zero rank
- `rank_live : ¬hasDied hist → rank hist > 0` — live positions have positive rank
- `rank_descent : ¬hasDied hist → ∃ m, ∀ e, ¬hasDied(hist++[(m,e)]) ∧ rank(hist++[(m,e)]) < rank hist` — safe rank-decreasing moves exist

**Theorem 6.2**. Every ordinal arena has Safe Escape.

*Proof*: The rank_descent axiom directly provides the safe escape witness.

**Definition 6.3** (Arena Strategy). The *arena strategy* uses rank_descent to pick rank-decreasing moves at each alive position.

**Theorem 6.4** (Arena Strategy Survival). The arena strategy maintains survival at all rounds.

**Theorem 6.5** (Rank Descent Sequence). Under the arena strategy, the ordinal ranks form a strictly decreasing sequence:
`rank(playRounds arenaStrat es (n+1)) < rank(playRounds arenaStrat es n)`
for all alive positions.

**PEGB Analysis for Arena Strategy**:
- **P**roof: By induction, using rank_descent to get both survival and rank decrease.
- **E**xample: A finite arena with rank function `rank(hist) = max(0, K - |hist|)` for initial rank K. After K rounds, rank hits 0.
- **G**eneralization: The rank need not be a natural number — any ordinal works, enabling transfinite complexity measurement.
- **B**oundary: An arena with rank_descent but without rank_live would allow dead positions with positive rank, breaking the invariant.

## 7. Layered Survival

**Definition 7.1** (Layered Game). A *k-layered game* consists of k independent survival games, each with Safe Escape.

**Theorem 7.2**. Each layer provides independent immortality.

**Theorem 7.3** (Layered Ordinal). The total layered survival ordinal is ω·k.

**Theorem 7.4**. For k ≥ 2, the layered survival ordinal strictly exceeds ω.

*Proof*: ω·k > ω·1 = ω when k ≥ 2, by ordinal multiplication monotonicity.

**PEGB Analysis for Layered Survival**:
- **P**roof: Each layer contributes ω via Omega Survival; k layers sum to ω·k.
- **E**xample: 3 layers of the "matching game" (death when Mortal's move equals Eternity's response with 3 available moves). Each layer survives forever. Total: ω·3.
- **G**eneralization: Layers can have different safe-escape games, not just copies.
- **B**oundary: With 0 layers (vacuous), the game doesn't start. With 1 layer, equals standard ω survival.

## 8. ω²-Survival via Adaptive Layering

**Definition 8.1** (Adaptive Layered Game). An *adaptive layered game* has a base safe-escape game and a growth function `growth : ℕ → ℕ` with `∀ n, ∃ k, growth k > n` (unbounded growth).

**Theorem 8.2** (ω²-Survival). The adaptive survival ordinal equals ω².

*Proof*: Each epoch k contributes `growth(k)` layers, hence ω·growth(k) rounds. With unbounded growth and ω many epochs, total survival = ω · (sup{growth(k)} across ω) = ω · ω = ω².

**Theorem 8.3** (ω² > ω). Proved: ω·ω > ω·1 = ω by ordinal multiplication.

**Theorem 8.4** (ω·ω = ω^2). The multiplicative and exponential expressions are equal.

**PEGB Analysis for ω²-Survival**:
- **P**roof: Ordinal arithmetic + Omega Survival applied layer-by-layer.
- **E**xample: Growth function g(k) = k+1. Epoch 0: 1 layer. Epoch 1: 2 layers. Epoch k: k+1 layers. Cumulative layers after n epochs: n(n+1)/2.
- **G**eneralization: Faster growth functions (exponential, Ackermann) still yield ω² — the ordinal doesn't change because any unbounded ℕ→ℕ function's ordinal is ω.
- **B**oundary: If growth is bounded (eventually constant), total survival = ω·k for some finite k, strictly below ω².

## 9. Strategic Depth

**Definition 9.1**. The *strategic depth* of a game is:
- 0 if all strategies survive (trivial game)
- 1 if a specific strategy is needed (safe escape)
- ⊤ if no finite-level strategy suffices

**Theorem 9.2**. Safe-escape games have strategic depth ≤ 1.

## 10. Game Product

**Definition 10.1** (Game Product). The product game `G₁ × G₂` has death predicate `hasDied(hist) ↔ G₁.hasDied(hist) ∨ G₂.hasDied(hist)`.

**Theorem 10.2**. Product immortality implies component immortality.

**Theorem 10.3**. Product survival implies component survival (both directions).

**PEGB Analysis for Game Product**:
- **P**roof: Immediate from the ∨ structure of the product death predicate.
- **E**xample: Product of "matching game with 3 moves" and "matching game with 5 moves". Mortal must avoid matching in both games simultaneously.
- **G**eneralization: n-ary products, infinite products (with appropriate topology).
- **B**oundary: The converse of Theorem 10.2 fails: component immortality does NOT imply product immortality, because a single strategy may not simultaneously avoid death in both games. (The safe moves for G₁ might conflict with those for G₂.)

## 11. No-Free-Lunch Theorem

**Theorem 11.1**. If Safe Escape fails, there exists an alive position where every move can be punished:
`∃ hist, ¬G.hasDied hist ∧ ∀ m, ∃ e, G.hasDied(hist ++ [(m,e)])`.

This is the precise dual of Safe Escape and characterizes when Eternity has genuine local advantage.

## 12. Strategy Refinement Preorder

**Definition 12.1**. Strategy σ₁ *refines* σ₂ (written σ₁ ≤ σ₂) if σ₁ survives whenever σ₂ does.

**Theorem 12.2**. Refinement is reflexive and transitive (a preorder).

## 13. Connection to Infinite Time Turing Machines

The ordinal duration hierarchy has a precise correspondence with ITTM computational thresholds:

| Game Duration | ITTM Parallel | Description |
|---|---|---|
| ω | ω steps | One supertask — read entire input |
| ω·k | ω·k steps | k supertasks |
| ω² | ω² steps | ω supertasks — first "limit of limits" |
| ω^ω | ω^ω steps | Transfinite tower of supertasks |

The ω² barrier is particularly significant: it's the threshold where ITTMs first gain qualitatively new computational power beyond ω steps. Our ω²-Survival Theorem shows that Mortal can reach this threshold through adaptive layering — a natural game-theoretic construction that mirrors the ITTM limit ordinal hierarchy.

## 14. Falsifiable Conjecture

**Conjecture (Safe Escape Density)**. For random survival games with m available moves and death probability p per move-response pair, the probability of Safe Escape at depth n is approximately:

P(SafeEscape | m, n, p) ≈ (1 - p^m)^n

**Testable prediction**: For m = 2, p = 0.3:
- n = 10: P ≈ 0.389
- n = 20: P ≈ 0.151

This can be tested by Monte Carlo simulation with 10,000 random games. Deviation beyond 2σ falsifies the conjecture.

## 15. Future Work

1. **Determinacy at ω²**: Characterize which games at the ω² level are determined.
2. **Effective Arena Construction**: Given a game, construct its ordinal arena algorithmically.
3. **Beyond ω²**: Can Mortal reach ω^ω through higher-order layering?
4. **Game products and Safe Escape**: Characterize when the product of two safe-escape games itself has safe escape.

## References

[1] J.D. Hamkins, A. Lewis. "Infinite Time Turing Machines." *Journal of Symbolic Logic*, 65(2):567-604, 2000.

[2] E. Zermelo. "Über eine Anwendung der Mengenlehre auf die Theorie des Schachspiels." *Proceedings of the Fifth International Congress of Mathematicians*, 1913.

[3] D.A. Martin. "Borel Determinacy." *Annals of Mathematics*, 102(2):363-371, 1975.

[4] Y.N. Moschovakis. *Descriptive Set Theory*. North-Holland, 1980.

[5] A. Blass. "Complexity of Winning Strategies." *Discrete Mathematics*, 3:295-300, 1972.

## Appendix: Formalization Details

All results are formalized in Lean 4 with Mathlib. The development consists of approximately 310 lines of verified code in `Computation/MortalEternityCore.lean`. Key verified theorems:

- `omega_survival`: SafeEscape → hasImmortalStrategy
- `asymmetry_collapse_thm`: ¬∃ es n, hasDied (playRounds safeStrat es n)
- `arena_immortal`: OrdinalArena → hasImmortalStrategy
- `arenaStrategy_survives`: Arena strategy maintains survival
- `arenaStrategy_rank_descent`: Arena strategy strictly decreases rank
- `layered_exceeds_omega`: ω·k > ω for k ≥ 2
- `omega_sq_gt_omega`: ω·ω > ω
- `omega_sq_eq`: ω·ω = ω^2
- `adaptive_reaches_omega_sq`: Adaptive layering reaches ω^2
- `product_immortal_left`: Product immortality → component immortality
