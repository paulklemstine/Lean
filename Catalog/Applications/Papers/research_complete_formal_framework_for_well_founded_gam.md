# Transfinite Game Values: A Formal Framework for Well-Founded Games with Ordinal Measures

## Abstract

We present a complete formal framework for well-founded combinatorial games equipped with ordinal-valued game measures. We define the game value of a position as the ordinal rank in the well-founded game tree and prove the Universal Realization Theorem: every ordinal arises as the game value of some position in a well-founded game. We establish the Bridge Theorem showing that game values and well-order ranks are coextensive, prove that game embeddings preserve values, and introduce the novel concept of depth spectrum to capture the internal structure of game trees. We connect our framework to Gentzen's proof theory by formalizing ε₀ as the least fixed point of ordinal exponentiation and proving the ω^ω supremum theorem. All results are machine-verified in Lean 4 with Mathlib.

**Keywords**: well-founded games, ordinal game values, transfinite induction, ε₀, Gentzen's theorem, formal verification

---

## 1. Introduction

The theory of combinatorial games, initiated by Sprague and Grundy in the 1930s and developed extensively by Conway, Berlekamp, and others, provides a rich framework for analyzing strategic interactions. A fundamental question in this theory is: *how deep can a game be?*

For finite games, the answer is straightforward — game depth is a natural number. But for well-founded games on infinite state spaces, game depth extends into the transfinite ordinals. This paper develops the formal theory of these transfinite game values, establishing the fundamental structural results connecting game theory and ordinal arithmetic.

### 1.1 Main Contributions

1. **WFGame Framework** (§2): A formal definition of well-founded games with ordinal game values, including the Descent Lemma and terminal value theorem.

2. **Universal Realization** (§3): Every ordinal is a game value. The canonical game construction provides a uniform witness.

3. **Bridge Theorem** (§3): Game values and well-order ranks are definitionally equal — game theory and order theory are two languages for the same structure.

4. **Depth Spectrum** (§4): A novel invariant capturing the internal structure of the game tree below a position.

5. **Embedding Preservation** (§5): Structure-preserving maps between games preserve game values.

6. **ε₀ Fixed Point** (§6): ε₀ is the least fixed point of ω^(·), connecting game hierarchies to Gentzen's proof theory.

7. **ω^ω Supremum** (§6): The supremum of {ω^n | n ∈ ℕ} equals ω^ω, establishing the limit of the finite exponential hierarchy.

---

## 2. Well-Founded Games and Game Values

### 2.1 Definition

A **well-founded game** G = (Pos, moves, wf) consists of:
- A type Pos of game positions
- A relation moves : Pos → Pos → Prop, where moves(q, p) means "from p, a player can move to q"
- A proof wf that the moves relation is well-founded

The convention moves(q, p) (child before parent) aligns with the standard formalization of well-founded relations, where smaller elements come first.

### 2.2 Game Value

The **game value** of a position p is defined by well-founded recursion:

```
gameValue(p) = lsub { gameValue(q) | moves(q, p) }
```

where lsub denotes the least strict upper bound (the supremum of all values + 1). This assigns to each position the smallest ordinal not among the game values of its successors.

**Theorem 2.1 (Descent Lemma).** *If moves(q, p), then gameValue(q) < gameValue(p).*

*Proof.* By the definition of lsub, gameValue(q) is among the values being bounded, so gameValue(q) < lsub(...) = gameValue(p). □

**Theorem 2.2 (Terminal Value).** *If p has no available moves (∀ q, ¬moves(q, p)), then gameValue(p) = 0.*

*Proof.* The lsub over an empty family is 0. □

---

## 3. Canonical Games and Universal Realization

### 3.1 Construction

For each ordinal α, we define the **canonical game** on α:
- Positions: Ordinal.ToType α (a type with order type α)
- Moves: the natural well-order (q < p means "move from p to q")

The key advantage of using Ordinal.ToType is that it produces a type in the same universe as the ordinal, avoiding universe mismatch issues.

### 3.2 Canonical Value Theorem

**Theorem 3.1 (Canonical Value).** *For any ordinal α and position a in the canonical game on α, gameValue(a) = typein(a)*, where typein gives the ordinal index of a in the well-order.

*Proof.* By well-founded induction. The game value of a is lsub { gameValue(b) | b < a }. By the induction hypothesis, gameValue(b) = typein(b) for all b < a. The lsub of typein over the initial segment below a equals typein(a) by the definition of ordinal rank. □

**Theorem 3.2 (Canonical Supremum).** *lsub { gameValue(a) | a : ToType(α) } = α.*

*Proof.* By Theorem 3.1 and the identity lsub(typein) = type, combined with type_toType(α) = α. □

### 3.3 Universal Realization

**Theorem 3.3 (Universal Realization).** *For every ordinal β, there exist a well-founded game G and a position p in G such that gameValue(p) = β.*

*Proof.* Take G = CanonicalGame(β + 1). Since β < β + 1 = type(ToType(β+1)), there exists an element p with typein(p) = β (by surjectivity of typein). By Theorem 3.1, gameValue(p) = typein(p) = β. □

### 3.4 Bridge Theorem

**Theorem 3.4 (Bridge Theorem).** *The canonical game on α achieves every ordinal below α exactly once as a game value. Game values and well-order ranks are coextensive concepts.*

*Proof.* Immediate from Theorem 3.2: the lsub of all game values equals α, and by Theorem 3.1, the game value function is exactly the typein embedding, which is injective. □

---

## 4. Strategic Complexity and Depth Spectrum

### 4.1 Forced Positions

A position p is **forced** if at most one move is available:
```
isForced(p) ⟺ ∀ q₁ q₂, moves(q₁, p) → moves(q₂, p) → q₁ = q₂
```

A game is **strategically trivial** if every position is forced. Such games have well-defined depth (any ordinal) but zero strategic content — the game plays itself.

**Theorem 4.1.** *Terminal positions are forced.*

### 4.2 Depth Spectrum

The **depth spectrum** of a position p is the set of game values of all positions reachable from p:
```
depthSpectrum(p) = { α | ∃ q, TransGen(moves)(q, p) ∧ gameValue(q) = α }
```

**Theorem 4.2 (Spectrum Boundedness).** *Every element of depthSpectrum(p) is strictly less than gameValue(p).*

*Proof.* If α ∈ depthSpectrum(p), there exists q with TransGen(moves)(q, p) and gameValue(q) = α. By induction on the transitive closure: each step of moves strictly decreases the game value (Descent Lemma), so the overall decrease is strict by transitivity. □

**Theorem 4.3.** *Terminal positions have empty depth spectrum.*

The depth spectrum provides a finer invariant than the game value alone. Two positions with the same game value may have very different depth spectra, reflecting different internal structures.

---

## 5. Game Embeddings

### 5.1 Definition

A **game embedding** f : G₁ → G₂ is a function f.toFun : G₁.Pos → G₂.Pos that:
1. **Preserves moves**: if moves₁(q, p), then moves₂(f(q), f(p))
2. **Reflects moves**: if moves₂(r, f(p)), then there exists q with moves₁(q, p) and f(q) = r

This is stronger than a mere homomorphism — the reflection condition ensures f captures the full local structure.

### 5.2 Preservation Theorem

**Theorem 5.1 (Embedding Preservation).** *If f : G₁ → G₂ is a game embedding, then gameValue₁(p) = gameValue₂(f(p)) for all positions p.*

*Proof.* By well-founded induction on p using G₁.wf. The game value of p is lsub { gameValue₁(q) | moves₁(q, p) }, and the game value of f(p) is lsub { gameValue₂(r) | moves₂(r, f(p)) }. By the preservation and reflection conditions, these two families are in bijection (via f), and by the induction hypothesis, corresponding values are equal. Hence the two lsubs are equal. □

---

## 6. ε₀ and Ordinal Hierarchies

### 6.1 Definition

We define ε₀ as the least fixed point of the function f(x) = ω^x, starting from 0:
```
ε₀ = nfp(ω^(·), 0) = sup { 0, ω^0, ω^(ω^0), ω^(ω^(ω^0)), ... }
```

### 6.2 Fixed Point Theorem

**Theorem 6.1 (ε₀ Fixed Point).** *ω^ε₀ = ε₀.*

*Proof.* The function x ↦ ω^x is order-normal (strictly monotone and continuous at limits), so by the normal function fixed point theorem, nfp(ω^(·), 0) is a fixed point. □

### 6.3 Positivity

**Theorem 6.2.** *ε₀ > 0.*

*Proof.* We have 1 = ω^0 ≤ nfp(ω^(·), 0) = ε₀ by the le_nfp property. □

### 6.4 Minimality

**Theorem 6.3 (ε₀ Minimality).** *ε₀ is the least ordinal α satisfying ω^α = α.*

*Proof.* If ω^α = α, then α is a fixed point of the monotone function ω^(·), and since ε₀ = nfp(ω^(·), 0) with initial value 0 ≤ α, the nfp_le_fp lemma gives ε₀ ≤ α. □

### 6.5 ω^ω Supremum Theorem

**Theorem 6.4.** *lsub { ω^n | n ∈ ℕ } = ω^ω.*

*Proof.* The function x ↦ ω^x is normal, and ω = sup { n | n ∈ ℕ }. For normal functions f, f(sup S) = sup { f(s) | s ∈ S } when S is a limit set. Therefore ω^ω = sup { ω^n | n ∈ ℕ }, and converting between sup and lsub gives the result. □

### 6.6 Connection to Proof Theory

Gentzen's 1936 consistency proof for Peano Arithmetic (PA) showed that PA's consistency is equivalent to the well-foundedness of the ordinal ε₀. Our framework gives this result a game-theoretic interpretation:

- PA can prove the termination of any game whose game value is below ε₀.
- PA cannot prove the termination of a specific game with game value ε₀.
- The game hierarchy provides a concrete, constructive witness for the ordinals that PA can and cannot handle.

This connection is not merely analogical — the ordinal analysis of PA literally uses game-like constructions (ordinal notation systems) that our framework formalizes.

---

## 7. Algorithms

### 7.1 Game Value Computation

For finite games, game values can be computed by bottom-up traversal of the game tree:

```
Algorithm ComputeGameValue(G, p):
  if no moves from p: return 0
  values = { ComputeGameValue(G, q) | moves(q, p) }
  return mex(values)  // minimum excludant
```

For the canonical game (where positions are ordinals), this simplifies to the identity function.

### 7.2 Depth Spectrum Computation

```
Algorithm ComputeSpectrum(G, p, depth_limit):
  if depth_limit = 0: return {}
  spectrum = {}
  for each q with moves(q, p):
    spectrum.add(ComputeGameValue(G, q))
    spectrum = spectrum ∪ ComputeSpectrum(G, q, depth_limit - 1)
  return spectrum
```

---

## 8. Discussion

### 8.1 Novelty

The primary novel contributions are:

1. **Depth Spectrum**: This invariant has not been systematically studied in the combinatorial game theory literature. It provides a finer measure of game complexity than game value alone.

2. **Forced Positions / Strategic Triviality**: While the concept of forced moves exists informally, our formalization cleanly separates strategic depth from game depth, showing these are independent measures.

3. **Complete Formalization**: While the mathematical results are individually known (the connection between game values and ordinals dates to Sprague-Grundy theory), our complete formalization in a modern proof assistant, including the embedding preservation theorem, appears to be new.

### 8.2 Limitations

Our framework treats games as purely combinatorial objects without payoff functions or strategic reasoning about optimal play. The game value measures depth, not strategic value in the Nash equilibrium sense.

### 8.3 Future Work

- **Sprague-Grundy Theory**: Extend the framework to include nimbers and the Sprague-Grundy theorem for impartial games.
- **Game Sums**: Formalize disjunctive sum of games and prove additivity of game values.
- **Infinite Chess**: Apply the framework to verify game values of specific infinite chess positions.
- **Program Termination**: Connect game values to termination measures in program verification.

---

## References

1. Berlekamp, E.R., Conway, J.H., and Guy, R.K. *Winning Ways for your Mathematical Plays*. Academic Press, 1982.

2. Conway, J.H. *On Numbers and Games*. Academic Press, 1976.

3. Gentzen, G. "Die Widerspruchsfreiheit der reinen Zahlentheorie." *Mathematische Annalen* 112 (1936): 493–565.

4. Evans, C.D.A., and Hamkins, J.D. "Transfinite game values in infinite chess." *Integers* 14 (2014).

5. Sprague, R. "Über mathematische Kampfspiele." *Tôhoku Mathematical Journal* 41 (1935): 438–444.

6. Grundy, P.M. "Mathematics and games." *Eureka* 2 (1939): 6–8.
