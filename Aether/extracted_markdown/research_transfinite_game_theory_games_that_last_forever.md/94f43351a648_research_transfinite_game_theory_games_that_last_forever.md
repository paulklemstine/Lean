# Transfinite Game Theory: Determinacy, Ordinal Ranks, and the Large Cardinal Hierarchy

## Abstract

We develop a rigorous theory of infinite two-player sequential games (Gale-Stewart games) and their transfinite extensions. Our formalization encompasses: (1) the canonical play construction from paired strategies, (2) the exclusivity theorem showing at most one player can possess a winning strategy, (3) Zermelo's theorem extended to stage-0 clopen games, (4) the topological classification of games into open, closed, and clopen classes, (5) the Axiom of Determinacy (AD) with its dichotomy theorem, (6) the Wadge hierarchy as a preorder on games via continuous reductions, (7) ordinal-indexed game positions enabling transfinite game analysis, and (8) ordinal rank theory for game nodes with monotonicity and well-foundedness results. All results are machine-verified in Lean 4 with Mathlib, yielding 15+ sorry-free theorems. We conjecture a linear relationship between transfinite game length and the number of Woodin cardinals required for determinacy.

## 1. Introduction

### 1.1 Background

Infinite game theory, initiated by Gale and Stewart [1953], studies two-player games of perfect information where both players make infinitely many moves. The central question — whether every such game is *determined* (one player must have a winning strategy) — has deep connections to descriptive set theory, large cardinal axioms, and the foundations of mathematics.

The Axiom of Determinacy (AD), proposed by Mycielski and Steinhaus [1962], asserts that every Gale-Stewart game is determined. While inconsistent with the full Axiom of Choice, AD is consistent with ZF + DC and has remarkable consequences: every set of reals is Lebesgue measurable, has the Baire property, and the perfect set property.

### 1.2 Contributions

Our contributions are:

1. **Formal framework**: A complete formalization of Gale-Stewart games, strategies, and canonical plays in Lean 4 with Mathlib.

2. **Exclusivity theorem**: A machine-verified proof that winning strategies are exclusive — at most one player can have one (Theorem 3.1).

3. **AD dichotomy**: Under AD, exactly one player wins every game — a perfect partition of games into Player I victories and Player II victories (Theorem 5.1).

4. **Topological game theory**: Proofs that clopen games are simultaneously open and closed, and that the intersection of open games is open (Theorems 4.1–4.3).

5. **Wadge hierarchy**: Formalization of Wadge reducibility as a preorder with complement preservation (Theorems 6.1–6.3).

6. **Ordinal rank theory**: Strict monotonicity of ordinal ranks along the child relation, with a monotonicity theorem for rank comparison (Theorems 7.1–7.2).

7. **Transfinite positions**: A framework for ordinal-indexed game positions with extension and preservation properties.

8. **Conjecture**: A falsifiable conjecture relating game length to Woodin cardinal requirements.

## 2. Definitions

### 2.1 Gale-Stewart Games

**Definition 2.1** (Play). A *play* is a function p : ℕ → ℕ, representing an infinite sequence of natural number moves.

**Definition 2.2** (Game). A *game* is a set A ⊆ ℕ^ω. Player I wins if the play lands in A; Player II wins otherwise.

**Definition 2.3** (Strategy). A *strategy* is a function σ : List ℕ → ℕ, mapping finite histories to moves.

**Definition 2.4** (Build History). Given strategies σ (Player I) and τ (Player II), the *built history* of length n is defined inductively:
- buildHistory(σ, τ, 0) = []
- buildHistory(σ, τ, n+1) = h ++ [σ(h)] if n is even, h ++ [τ(h)] if n is odd, where h = buildHistory(σ, τ, n)

**Definition 2.5** (Canonical Play). The *canonical play* from strategies σ and τ is:
  canonicalPlay(σ, τ)(n) = buildHistory(σ, τ, n+1)[n]

**Definition 2.6** (Winning Strategy). Player I has a *winning strategy* for A if ∃σ, ∀τ, canonicalPlay(σ,τ) ∈ A. Player II has a winning strategy if ∃τ, ∀σ, canonicalPlay(σ,τ) ∉ A.

**Definition 2.7** (Determined). A game A is *determined* if one player has a winning strategy.

### 2.2 Topological Classification

**Definition 2.8** (Determined at Stage n). A game A is *determined at stage n* if ∀p,q: (∀i<n, p(i)=q(i)) → (p∈A ↔ q∈A).

**Definition 2.9** (Clopen Game). A game is *clopen* if it is determined at some finite stage.

**Definition 2.10** (Open Game). A game A is *open* if ∀p∈A, ∃n, ∀q: (∀i<n, q(i)=p(i)) → q∈A.

**Definition 2.11** (Closed Game). A game A is *closed* if Aᶜ is open.

### 2.3 Wadge Reducibility

**Definition 2.12** (Wadge Reducibility). A ≤_W B if there exists a continuous f : ℕ^ω → ℕ^ω with A = f⁻¹(B).

### 2.4 Ordinal Game Structures

**Definition 2.13** (Transfinite Position). A transfinite position has ordinal length α and a function assigning moves to each ordinal β < α.

**Definition 2.14** (Game Node). A game node has n children, each with a natural number rank. Its ordinal rank is sup{childRank(i) + 1 : i < n}.

### 2.5 Quasistrategy

**Definition 2.15** (Quasistrategy). A quasistrategy Q is a set of positions such that:
1. [] ∈ Q (contains the root)
2. If pos ∈ Q and |pos| is odd (opponent's turn), then pos++[m] ∈ Q for all m
3. If pos ∈ Q and |pos| is even (mover's turn), then pos++[m] ∈ Q for some m

## 3. Fundamental Results

### Theorem 3.1 (Exclusivity)
*At most one player can have a winning strategy.*

**Proof sketch.** If Player I has winning strategy σ and Player II has winning strategy τ, consider the canonical play from (σ, τ). By σ's winning property, the play is in A. By τ's winning property, the play is not in A. Contradiction. □

### Theorem 3.2 (Determined Dichotomy)
*If a game is determined, exactly one player wins.*

**Proof sketch.** Determined ⟹ at least one wins (by definition). At most one wins (by Theorem 3.1). Hence exactly one wins. □

## 4. Topological Game Theory

### Theorem 4.1 (Clopen ⊂ Open)
*Every clopen game is open.*

**Proof sketch.** If A is determined at stage n, then for any p ∈ A, the first n moves of p witness membership: any q agreeing with p on these moves satisfies q ∈ A by the stage-n property. □

### Theorem 4.2 (Clopen ⊂ Closed)
*Every clopen game is closed.*

**Proof sketch.** Dual argument: for p ∉ A, the stage-n property ensures any q agreeing with p on the first n moves also satisfies q ∉ A. □

### Theorem 4.3 (Open Intersection)
*The intersection of two open games is open.*

**Proof sketch.** If A has witness prefix nA and B has witness prefix nB for a play p, then max(nA, nB) witnesses membership in A ∩ B. □

### Theorem 4.4 (Zermelo Stage-0)
*Every game determined at stage 0 is determined.*

**Proof sketch.** At stage 0, all plays are equivalent: they are either all in A or all not in A. If all in A, Player I wins with any strategy. If none in A, Player II wins with any strategy. □

## 5. The Axiom of Determinacy

### Theorem 5.1 (AD Dichotomy)
*Under AD, for every game A, exactly one player has a winning strategy.*

**Proof sketch.** AD provides at least one winner. Exclusivity (Theorem 3.1) provides at most one. The combination gives a perfect dichotomy: (Player I wins ∧ Player II doesn't) ∨ (Player I doesn't ∧ Player II wins). □

### Theorem 5.2 (AD Player I Characterization)
*Under AD, Player I wins A iff Player II does not win A.*

### Theorem 5.3 (AD Player II Characterization)
*Under AD, Player II wins A iff Player I does not win A.*

## 6. The Wadge Hierarchy

### Theorem 6.1 (Reflexivity)
*WadgeReducible is reflexive: A ≤_W A via the identity function.*

### Theorem 6.2 (Transitivity)
*WadgeReducible is transitive: if A ≤_W B and B ≤_W C, then A ≤_W C.*

**Proof sketch.** Compose the continuous functions: if f witnesses A ≤_W B and g witnesses B ≤_W C, then g∘f witnesses A ≤_W C. Continuity is preserved under composition. □

### Theorem 6.3 (Complement Preservation)
*If A ≤_W B, then Aᶜ ≤_W Bᶜ via the same continuous function.*

**Proof sketch.** If A = f⁻¹(B), then Aᶜ = f⁻¹(Bᶜ), since preimage commutes with complement. □

## 7. Ordinal Rank Theory

### Theorem 7.1 (Rank Monotonicity)
*For a game node with children, each child's rank is strictly less than the node's ordinal rank.*

**Proof sketch.** The node's ordinal rank is ⨆ᵢ(childRank(i) + 1). For any child i, childRank(i) < childRank(i) + 1 ≤ ⨆ᵢ(childRank(i) + 1). □

### Theorem 7.2 (Rank Monotonicity for Expansion)
*If node n₂ has at least as many children as n₁, and each corresponding child has at least as high a rank, then n₁.ordRank ≤ n₂.ordRank.*

## 8. Transfinite Positions

### Theorem 8.1 (Extension Increases Length)
*Extending a position strictly increases its ordinal length.*

### Theorem 8.2 (Extension Preserves History)
*Extending a position preserves all earlier moves.*

### Theorem 8.3 (Extension New Move)
*The move at the new position equals the extension argument.*

## 9. The Determinacy Hierarchy

The relationship between determinacy at different Borel levels and the consistency strength of the underlying set theory forms a remarkable hierarchy:

| Borel Level | Determinacy | Required Axioms |
|-------------|-------------|-----------------|
| Clopen (Σ⁰₀) | ZF | None beyond ZF |
| Open (Σ⁰₁) | ZF | Gale-Stewart |
| Σ⁰ₙ | ZFC + n levels | Martin's theorem |
| Borel | ZFC | Martin 1975 |
| Analytic (Σ¹₁) | ZFC + sharps | Harrington-Martin |
| Projective | ZFC + Woodin | Martin-Steel |
| All sets (AD) | ZF + DC | Large cardinals |

## 10. Conjecture: Transfinite Determinacy Threshold

**Conjecture 10.1.** For games of ordinal length ω·n, determinacy requires at least (n-1) Woodin cardinals in consistency strength.

**Testable Prediction.** The minimum consistency strength for Σ⁰ₙ determinacy equals n in the Martin hierarchy. Specifically:
- Σ⁰₁ (open) determinacy: strength 0
- Σ⁰₂ determinacy: strength 1 (sharps)
- Σ⁰₃ determinacy: strength 2 (measurable cardinal)

**Test.** Verify that Martin's proof for Σ⁰ₙ determinacy uses exactly n levels of set-theoretic reflection. A non-linear jump would refute the conjecture.

## 11. Algorithms

### 11.1 Minimax for Finite Approximations

For games determined at stage n, the minimax algorithm computes the winner in O(k^n) time, where k is the branching factor (or infinite for ℕ-valued games, requiring pruning).

### 11.2 Quasistrategy Computation

Given an open game with computable winning condition, a quasistrategy can be computed by iteratively pruning losing branches from the game tree.

### 11.3 Ordinal Rank Computation

For finite game trees, the ordinal rank can be computed in O(|T|) time by a single bottom-up traversal.

## 12. Discussion

### 12.1 Relationship to Prior Work

Our formalization builds on the classical results of Gale-Stewart [1953], Martin [1975], and the descriptive set theory program of Moschovakis [1980]. The ordinal rank theory connects to Conway's surreal numbers and Berlekamp-Conway-Guy's combinatorial game theory.

### 12.2 The Quasistrategy Innovation

The quasistrategy framework, while classical in descriptive set theory, provides a natural bridge between game-theoretic reasoning and topological structure. Our formalization of quasistrategies as sets of positions closed under opponent moves captures the essential game-theoretic intuition while enabling topological analysis.

### 12.3 Cross-Domain Connections

The Wadge hierarchy connects game theory to topology and computability theory. Wadge reducibility via continuous functions is the game-theoretic analogue of many-one reducibility in computability theory. Under AD, the Wadge hierarchy is well-founded and well-ordered, providing a canonical complexity measure for sets of reals.

## 13. Future Work

1. **Borel determinacy**: Formalize Martin's 1975 proof of Borel determinacy in ZFC.
2. **Analytic determinacy**: Connect to the existence of sharps and inner model theory.
3. **Woodin cardinal hierarchy**: Formalize the precise relationship between Woodin cardinals and projective determinacy.
4. **Computational games**: Apply determinacy theory to verification of reactive systems.
5. **Tropical game values**: Connect game ranks to tropical algebraic structures via the existing TransfiniteGameValues formalization.

## References

1. Gale, D. and Stewart, F.M. (1953). "Infinite games with perfect information." *Annals of Mathematics Studies* 28, 245–266.
2. Martin, D.A. (1975). "Borel determinacy." *Annals of Mathematics* 102, 363–371.
3. Martin, D.A. and Steel, J. (1989). "A proof of projective determinacy." *Journal of the American Mathematical Society* 2, 71–125.
4. Mycielski, J. and Steinhaus, H. (1962). "A mathematical axiom contradicting the axiom of choice." *Bulletin de l'Académie Polonaise des Sciences* 10, 1–3.
5. Moschovakis, Y.N. (1980). *Descriptive Set Theory*. North-Holland.
6. Wadge, W.W. (1983). "Reducibility and determinateness on the Baire space." PhD thesis, UC Berkeley.
7. Harrington, L. (1978). "Analytic determinacy and 0#." *Journal of Symbolic Logic* 43, 685–693.
