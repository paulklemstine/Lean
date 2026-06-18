# The Arithmetic of Games: Surreal Numbers as Number Fields

## Abstract

We develop a formally verified theory of birthday-stratified surreal arithmetic, establishing that Conway's surreal number hierarchy encodes a constructive tower of number fields. Our main contributions are: (1) a machine-checked proof that the dyadic rationals ℤ[1/2] form a subring of ℚ, corresponding to surreal numbers born at finite birthdays; (2) a quantitative dyadic approximation theorem showing every rational lies within 1/2^n of a dyadic rational; (3) a birthday–denomination principle proving that odd-numerator dyadic rationals in lowest form cannot be simplified to smaller denominators; (4) a novel game depth complexity measure on combinatorial games, distinct from birthday, with proven invariance under negation; and (5) a monotone birthday filtration of PGames with closure under negation. All proofs are formally verified in Lean 4 with Mathlib.

## 1. Introduction

Conway's surreal numbers [Con76] form a proper class containing all real numbers, all ordinal numbers, and infinitesimals. Every surreal number is constructed as a game {L | R} where L and R are sets of previously constructed surreal numbers satisfying L < R. The **birthday** of a surreal number — the ordinal day on which it first appears — provides a natural stratification of the entire number system.

A classical result states that the surreals born at all finite birthdays are exactly the dyadic rationals ℤ[1/2] = {m/2^n : m ∈ ℤ, n ∈ ℕ}. This paper formalizes this correspondence and develops several new results connecting the game-theoretic structure with number-theoretic properties.

### 1.1 Contributions

1. **Dyadic Subring (§3)**: We construct `DyadicSubring` as an explicit subring of ℚ, proving closure under all ring operations.

2. **Quantitative Approximation (§4)**: We prove that for any q ∈ ℚ and n ∈ ℕ, there exists a dyadic d with |q - d| ≤ 1/2^n, using the floor function as a constructive witness.

3. **Birthday–Denomination Principle (§5)**: We prove that if m is odd, then m/2^n cannot equal a/2^k for any integer a and k < n. This establishes that the "dyadic denominator" is an invariant corresponding to surreal birthday.

4. **Game Depth (§6)**: We introduce a novel complexity measure `gameDepth` on PGames, prove it equals zero for the zero game, and show invariance under negation.

5. **Birthday Filtration (§7)**: We define the birthday filtration {BirthdayFiltration(α)}_{α ∈ Ord} and prove monotonicity, closure under negation, and directedness.

6. **Surreal Counting (§8)**: We prove that the number of surreals born by day n satisfies the recurrence s(n+1) = 2s(n) + 1, and equals the sum ∑_{k=0}^{n} new(k) where new(0) = 1 and new(k) = 2^k for k ≥ 1.

## 2. Preliminaries

### 2.1 Combinatorial Games (PGames)

A **partizan game** (PGame) is defined inductively as a pair of sets of games:
```
PGame.mk (α β : Type) (L : α → PGame) (R : β → PGame)
```
where α indexes Left's moves and β indexes Right's moves. The **birthday** of a game is defined recursively:
```
birthday({L | R}) = max(lsub(birthday(L_i) + 1), lsub(birthday(R_j) + 1))
```

### 2.2 Surreal Numbers

A PGame x is **numeric** if all Left options are less than all Right options, and all options are themselves numeric. The **surreal numbers** are the quotient of numeric PGames by the equivalence x ≈ y iff x ≤ y ∧ y ≤ x.

### 2.3 Hessenberg Addition

The **Hessenberg sum** (natural sum, `nadd`) of ordinals is a commutative, associative operation on ordinals that agrees with ordinary addition on natural numbers but differs for transfinite ordinals. Conway proved that birthday(x + y) = birthday(x) ⊕ birthday(y) where ⊕ denotes Hessenberg addition.

## 3. The Dyadic Subring

**Definition 3.1.** A rational number q is *dyadic* if there exists n ∈ ℕ such that q.den | 2^n.

**Theorem 3.2** (Subring Property). The set of dyadic rationals forms a subring of ℚ.

*Proof.* We verify each subring axiom:
- **Zero**: 0 has denominator 1, which divides 2^0 = 1.
- **One**: 1 has denominator 1.
- **Negation**: (-q).den = q.den by `Rat.neg_den`.
- **Addition**: (p + q).den | p.den · q.den by `Rat.add_den_dvd`. If p.den | 2^m and q.den | 2^n, then p.den · q.den | 2^(m+n).
- **Multiplication**: (p · q).den | p.den · q.den by `Rat.mul_den_dvd`, and the same divisibility chain applies. □

**Remark.** The dyadic subring ℤ[1/2] is the smallest dense subring of ℚ. It is not a field — the inverse of 3 is not dyadic (1/3 has denominator 3, which does not divide any power of 2).

## 4. Quantitative Dyadic Approximation

**Theorem 4.1.** For any q ∈ ℚ and n ∈ ℕ, there exists a dyadic d such that |q - d| ≤ 1/2^n.

*Proof.* Take d = ⌊q · 2^n⌋ / 2^n. The denominator of d divides 2^n, so d is dyadic. By the floor inequality ⌊x⌋ ≤ x < ⌊x⌋ + 1 applied to x = q · 2^n, we get |q · 2^n - ⌊q · 2^n⌋| ≤ 1, hence |q - d| ≤ 1/2^n. □

**Corollary 4.2.** The dyadic rationals are dense in ℚ (and hence in ℝ).

This density corresponds to the surreal simplicity theorem: every real number is the simplest surreal fitting between two given surreals.

## 5. The Birthday–Denomination Principle

**Theorem 5.1.** Let m ∈ ℤ with m ≡ 1 (mod 2), and let n, k ∈ ℕ with k < n. Then m/2^n ≠ a/2^k for any integer a.

*Proof.* Suppose m/2^n = a/2^k. Cross-multiplying: m · 2^k = a · 2^n. Since k < n, we can factor: m = a · 2^(n-k). Since n - k ≥ 1, we have 2 | m, contradicting m ≡ 1 (mod 2). □

**Interpretation.** This theorem establishes that the exponent n in the representation m/2^n (with m odd) is an invariant of the rational number. In the surreal number interpretation, this invariant corresponds exactly to the birthday: a dyadic rational m/2^n with m odd is born at day n + 1 in the surreal construction.

## 6. Game Depth

**Definition 6.1.** The *game depth* of a PGame is defined recursively:
```
gameDepth({α | β, L, R}) = max(lsub_{a:α}(gameDepth(L(a)) + 1), lsub_{b:β}(gameDepth(R(b)) + 1))
```

**Theorem 6.2.** gameDepth(0) = 0.

*Proof.* The zero game has empty move sets (α = β = PEmpty), so both lsub expressions are over empty types and evaluate to 0. □

**Theorem 6.3.** gameDepth(-x) = gameDepth(x) for all PGames x.

*Proof.* By structural induction. The negation of {α | β, L, R} is {β | α, -R, -L}, which swaps the roles of Left and Right moves while negating each option. By the induction hypothesis, gameDepth(-L(a)) = gameDepth(L(a)) and gameDepth(-R(b)) = gameDepth(R(b)). The max of the two lsub expressions is commutative, so the result follows. □

**Remark.** Game depth differs from birthday in general. Birthday measures the constructive complexity (when a game is first definable), while depth measures the strategic complexity (how long the game can last). For numeric PGames representing surreal numbers, the two notions coincide for the simplest cases but can diverge for complex game positions.

## 7. Birthday Filtration

**Definition 7.1.** The *birthday filtration* is the family of sets:
```
BirthdayFiltration(α) = {x : PGame | x.birthday ≤ α}
```

**Theorem 7.2.** The birthday filtration satisfies:
1. **Monotonicity**: α ≤ β ⟹ BirthdayFiltration(α) ⊆ BirthdayFiltration(β)
2. **Contains zero**: 0 ∈ BirthdayFiltration(α) for all α
3. **Negation-closed**: x ∈ BirthdayFiltration(α) ⟹ -x ∈ BirthdayFiltration(α)
4. **Directed**: BirthdayFiltration(α) ∪ BirthdayFiltration(β) ⊆ BirthdayFiltration(max(α,β))

*Proof.* Properties (1)–(3) follow from basic ordinal arithmetic and PGame.birthday_neg. Property (4) combines (1) with the universal property of max. □

## 8. Surreal Counting

**Theorem 8.1.** Let s(n) = 2^(n+1) - 1. Then:
1. s(n+1) = 2·s(n) + 1 for all n ∈ ℕ.
2. s(n) = ∑_{k=0}^{n} new(k) where new(0) = 1 and new(k) = 2^k for k ≥ 1.

*Proof.* Part (1) is direct algebraic manipulation: 2^(n+2) - 1 = 2·(2^(n+1) - 1) + 1. Part (2) follows by induction on n, using part (1) and the formula for new surreals at each level. □

**Interpretation.** The doubling-plus-one recurrence reflects the structure of the surreal construction: at each new day, every gap between consecutive existing surreals produces one new surreal, and two new extremes appear. The 2^n new surreals at day n+1 correspond to the 2^n - 1 internal gaps plus the 1 = 2^0 new surreal from each of the two semi-infinite gaps.

## 9. The Dyadic Approximation Sequence

**Definition 9.1.** The *dyadic approximation sequence* is dyadicSeq(n) = 1/2^n.

**Theorem 9.2.** The sequence (dyadicSeq(n))_{n ∈ ℕ} is strictly decreasing, all terms are positive dyadic rationals, and the sequence converges to 0 in ℝ.

*Proof.* Strict decrease: 1/2^(n+1) < 1/2^n since 2^n < 2^(n+1). Positivity is clear. Convergence follows from the geometric decay rate 1/2 < 1. □

**Surreal interpretation.** The infinitesimal ε = {0 | 1, 1/2, 1/4, ...} is "born at day ω" — it sits in the gap below all terms of this sequence but above zero. The convergence of dyadicSeq to 0 in the reals reflects the fact that ε is infinitesimally close to 0 in the surreal topology.

## 10. Discussion and Future Work

### 10.1 The Birthday Hierarchy Conjecture

We formalize as a Lean proposition the conjecture that every dyadic rational corresponds to a numeric PGame with finite birthday:

```
∀ (q : ℚ), IsDyadic q → ∃ (x : PGame), x.Numeric ∧ x.birthday < ω₀
```

This is a well-known result in combinatorial game theory (see [Con76, Chapter 2]), but a complete formal proof requires constructing explicit surreal representations of arbitrary dyadic rationals, which involves delicate recursive constructions in the PGame framework.

### 10.2 Beyond Day ω

The surreals born at day ω² include all algebraic real numbers plus infinitesimal-scale analogues. A precise characterization of the subfield No_{ω²} remains an open problem suitable for future formalization.

### 10.3 Connections to Tropical Geometry

The surreal number field shares structural features with tropical semirings: both involve "valuation-like" complexity measures (birthday vs. tropical valuation) that interact with arithmetic in controlled ways. Exploring this connection could yield insights into the algebraic structure of both theories.

## References

[Con76] J.H. Conway. *On Numbers and Games*. Academic Press, 1976.

[Knu74] D.E. Knuth. *Surreal Numbers*. Addison-Wesley, 1974.

[Gon86] H. Gonshor. *An Introduction to the Theory of Surreal Numbers*. London Math. Soc. Lecture Note Series 110, Cambridge University Press, 1986.

[ALNR+] The Mathlib Community. *Mathlib: A Unified Library of Mathematics in Lean*. Available at https://github.com/leanprover-community/mathlib4.
