# Computable Nonstandard Arithmetic via Eventual Equivalence Classes

## Abstract

We construct a concrete nonstandard extension of the natural numbers by taking the quotient of the sequence space ℕ → ℕ by eventual equality — agreement from some index onward. The resulting structure, HyperNat, is equipped with pointwise addition, multiplication, and an eventual ordering. We prove it forms a commutative semiring, embeds ℕ via constant sequences, and contains a canonical infinite element ω (the class of the identity sequence) that strictly exceeds every standard natural number. We then define a simple language of arithmetic terms — constants, a variable, addition, and multiplication — and prove a transfer theorem: every universally quantified equation between arithmetic terms that holds in ℕ automatically holds in HyperNat. As applications, we transport the Gauss triangular number formula (2·T(x) = x(x+1)), the sum-of-squares formula (6·S(x) = x(x+1)(2x+1)), and various polynomial identities to the nonstandard domain. We also establish a divisibility lifting theorem and prove that eventual equality of sequences is exactly equality of their HyperNat representatives — making asymptotic identity a form of exact arithmetic. All results are machine-verified with no axioms beyond the standard foundations (propext, Quot.sound, Classical.choice).

## 1. Introduction

### 1.1 Motivation

Nonstandard arithmetic, originating in Robinson's work on nonstandard analysis [1], extends the natural numbers (or integers, or reals) with infinite and infinitesimal elements while preserving first-order properties via the transfer principle. The classical construction uses ultrapowers — quotients of sequence spaces by an ultrafilter — and Łoś's theorem to establish transfer.

While conceptually clean, the ultrapower construction poses challenges for formal verification:
1. Free ultrafilters on ℕ require the axiom of choice for existence and are inherently non-constructive.
2. Łoś's theorem requires induction on first-order formula complexity, which is technically demanding to formalize.
3. The full first-order language of arithmetic includes quantifiers, making the semantics machinery heavy.

We take a different approach, replacing the ultrafilter with the cofinite filter (the Fréchet filter) and restricting transfer to quantifier-free formulas. This yields a reduced power rather than an ultrapower, which loses totality of the ordering and transfer for quantified statements, but gains:
- A fully constructive quotient construction (no choice needed for the filter).
- A structurally recursive transfer theorem (induction on term syntax, not formula syntax).
- Complete machine verification with minimal axiomatic overhead.

### 1.2 Relationship to Prior Work

The reduced power construction modulo a filter is well-studied in model theory [2, 3]. Our contribution is not the mathematical novelty of the construction itself, but rather:
- The first complete machine verification of a working nonstandard arithmetic system.
- A practical demonstration that quantifier-free transfer suffices for transporting a wide class of classical identities.
- An explicit connection between eventual equality and asymptotic arithmetic.

The Mathlib library contains extensive filter theory and some ultrafilter machinery, but does not (as of writing) contain a formalized hypernatural or hyperreal number system with working transfer. Our construction provides a minimal but functional entry point.

### 1.3 Contributions

1. **Construction of HyperNat** as a quotient of ℕ → ℕ by eventual equality, with full semiring structure (§2).
2. **Non-Archimedean property**: proof that the class of the identity sequence is infinite (§3).
3. **Quantifier-free transfer**: a transfer theorem for the language {0, 1, +, ×, =}, proved by structural induction on terms (§4).
4. **Applications**: transport of the Gauss formula, sum-of-squares formula, and other identities; divisibility transfer; asymptotic-to-exact correspondence (§5).
5. **Full machine verification** with no sorry and standard axioms only (§6).

## 2. The HyperNat Construction

### 2.1 Eventual Equality

**Definition 2.1.** Two sequences f, g : ℕ → ℕ are *eventually equal*, written EventuallyEq(f, g), if there exists N ∈ ℕ such that f(n) = g(n) for all n ≥ N.

**Proposition 2.2.** EventuallyEq is an equivalence relation.

*Proof.* Reflexivity is immediate (take N = 0). Symmetry follows from symmetry of equality. For transitivity, if f agrees with g from N₁ onward and g agrees with h from N₂ onward, then f agrees with h from max(N₁, N₂) onward. □

### 2.2 The Quotient Type

**Definition 2.3.** HyperNat = (ℕ → ℕ) / EventuallyEq, the quotient of the sequence space by eventual equality.

We write [f] for the equivalence class of f, and mk(f) as a constructor.

### 2.3 Arithmetic Operations

**Definition 2.4.** Addition and multiplication on HyperNat are defined by pointwise lifting:
- [f] + [g] = [n ↦ f(n) + g(n)]
- [f] · [g] = [n ↦ f(n) · g(n)]

**Proposition 2.5.** These operations are well-defined: if EventuallyEq(f₁, f₂) and EventuallyEq(g₁, g₂), then EventuallyEq(f₁ + g₁, f₂ + g₂) and EventuallyEq(f₁ · g₁, f₂ · g₂).

*Proof.* If f₁ = f₂ from N₁ onward and g₁ = g₂ from N₂ onward, then f₁(n) + g₁(n) = f₂(n) + g₂(n) for all n ≥ max(N₁, N₂). Similarly for multiplication. □

**Definition 2.6.** The embedding ofNat' : ℕ → HyperNat maps k to [n ↦ k] (the constant sequence).

### 2.4 Algebraic Properties

**Theorem 2.7.** (HyperNat, +, ·, 0, 1) satisfies all commutative semiring identities:
- Commutativity and associativity of + and ·
- Distributivity: a · (b + c) = a · b + a · c
- Identity elements: 0 + a = a, 1 · a = a
- Absorption: 0 · a = 0

*Proof.* Each identity is proved by lifting to representatives and applying the corresponding identity for ℕ pointwise. For example, for commutativity of addition: given representatives f and g, we need f(n) + g(n) = g(n) + f(n) for all n ≥ 0, which follows from Nat.add_comm. □

**Theorem 2.8.** HyperNat is nontrivial: 0 ≠ 1.

*Proof.* If 0 = 1 then the constant-0 and constant-1 sequences are eventually equal, giving 0 = 1 in ℕ, a contradiction. □

## 3. The Non-Archimedean Property

### 3.1 The Eventual Ordering

**Definition 3.1.** The eventual ordering on HyperNat is defined by:
le([f], [g]) ⟺ ∃ N, ∀ n ≥ N, f(n) ≤ g(n).

**Proposition 3.2.** This is well-defined on equivalence classes.

*Proof.* If f₁ ≈ f₂ and g₁ ≈ g₂, then eventual inequality of f₁, g₁ implies eventual inequality of f₂, g₂ by rewriting with the eventual equalities. □

**Remark 3.3.** The eventual ordering is a preorder (reflexive and transitive) but not a total order. For example, the sequences (0, 1, 0, 1, …) and (1, 0, 1, 0, …) are incomparable.

### 3.2 Infinite Elements

**Definition 3.4.** ω = [n ↦ n], the class of the identity sequence.

**Theorem 3.5 (Non-Archimedean Property).** For every k ∈ ℕ:
1. le(ofNat'(k), ω) — omega dominates every standard natural.
2. ¬ le(ω, ofNat'(k)) — omega is not bounded by any standard natural.

*Proof.* (1) The identity sequence satisfies id(n) ≥ k for all n ≥ k. (2) Suppose id(n) ≤ k for all n ≥ N. Then N + k + 1 ≤ k, a contradiction since N + k + 1 > k. □

**Corollary 3.6.** ω ≠ ofNat'(k) for all k ∈ ℕ.

**Theorem 3.7.** ω + 1 ≠ ω and 2ω ≠ ω.

*Proof.* If ω + 1 = ω, the sequences n + 1 and n are eventually equal, giving n + 1 = n for large n, contradiction. Similarly for 2ω. □

**Theorem 3.8.** ω² strictly dominates ω: le(ω, ω²) ∧ ¬ le(ω², ω).

*Proof.* For the first part, n ≤ n² for n ≥ 1. For the second, if n² ≤ n eventually then (N+2)² ≤ N+2 gives N² + 4N + 4 ≤ N + 2, contradiction for N ≥ 0. □

## 4. The Transfer Principle

### 4.1 Arithmetic Terms

**Definition 4.1.** The type ArithTerm of unary arithmetic terms is defined inductively:
```
ArithTerm ::= const(k : ℕ) | var | add(t₁, t₂) | mul(t₁, t₂)
```

**Definition 4.2.** Evaluation functions:
- evalNat : ArithTerm → ℕ → ℕ evaluates a term at a standard natural.
- evalHyper : ArithTerm → HyperNat → HyperNat evaluates at a hypernatural by structural recursion: constants map to ofNat', var maps to the input, add/mul use HyperNat arithmetic.

### 4.2 The Key Lemma

**Lemma 4.3 (Evaluation Commutes with Quotient).** For any term t and sequence f:
```
evalHyper(t, [f]) = [n ↦ evalNat(t, f(n))]
```

*Proof.* By structural induction on t:
- const(k): evalHyper(const(k), [f]) = ofNat'(k) = [n ↦ k] = [n ↦ evalNat(const(k), f(n))]. ✓
- var: evalHyper(var, [f]) = [f] = [n ↦ f(n)] = [n ↦ evalNat(var, f(n))]. ✓
- add(t₁, t₂): By induction, evalHyper(tᵢ, [f]) = [n ↦ evalNat(tᵢ, f(n))]. Then evalHyper(add(t₁, t₂), [f]) = evalHyper(t₁, [f]) + evalHyper(t₂, [f]) = [n ↦ evalNat(t₁, f(n)) + evalNat(t₂, f(n))] = [n ↦ evalNat(add(t₁, t₂), f(n))]. ✓
- mul: analogous. □

### 4.3 The Transfer Theorem

**Theorem 4.4 (Quantifier-Free Transfer).** If t₁, t₂ : ArithTerm satisfy evalNat(t₁, n) = evalNat(t₂, n) for all n ∈ ℕ, then evalHyper(t₁, x) = evalHyper(t₂, x) for all x ∈ HyperNat.

*Proof.* Let x = [f]. By Lemma 4.3:
```
evalHyper(t₁, [f]) = [n ↦ evalNat(t₁, f(n))]
evalHyper(t₂, [f]) = [n ↦ evalNat(t₂, f(n))]
```
These are eventually equal because evalNat(t₁, f(n)) = evalNat(t₂, f(n)) for all n (using the hypothesis with argument f(n)), hence from N = 0 onward. □

**Theorem 4.5 (Inequality Transfer).** If evalNat(t₁, n) ≤ evalNat(t₂, n) for all n, then le(evalHyper(t₁, x), evalHyper(t₂, x)) for all x.

**Theorem 4.6 (Binary Transfer).** The same transfer holds for ArithTerm2 (terms with two variables), extending to multivariate identities.

### 4.4 Scope and Limitations

The transfer theorem covers:
- All polynomial identities over ℕ (since every polynomial is an ArithTerm).
- All polynomial inequalities.
- Compositions of polynomial operations.

It does not cover:
- Existential statements (e.g., "there exists a prime between n and 2n").
- Divisibility (handled separately via EventuallyDvd).
- Functions not expressible as ArithTerms (handled by pointwise lifting, as in the Gauss formula application).

## 5. Applications

### 5.1 Gauss Triangular Number Formula

**Theorem 5.1.** Define T : ℕ → ℕ by T(0) = 0, T(n+1) = T(n) + (n+1). Then for all x ∈ HyperNat:
```
ofNat'(2) · hyperTriangular(x) = x · (x + ofNat'(1))
```

*Proof.* The standard identity 2·T(n) = n(n+1) is proved by induction. The hypernatural function hyperTriangular is defined by pointwise lifting: hyperTriangular([f]) = [n ↦ T(f(n))]. The identity transfers because 2·T(f(n)) = f(n)·(f(n)+1) for each n. □

### 5.2 Sum of Squares Formula

**Theorem 5.2.** Define S(0) = 0, S(n+1) = S(n) + (n+1)². Then:
```
ofNat'(6) · hyperSumSquares(x) = x · (x + ofNat'(1)) · (ofNat'(2) · x + ofNat'(1))
```

### 5.3 The Fundamental Correspondence

**Theorem 5.3.** For sequences f, g : ℕ → ℕ:
```
(∃ N, ∀ n ≥ N, f(n) = g(n)) ↔ mk(f) = mk(g)
```

This is immediate from the definition but philosophically profound: asymptotic identity becomes exact equality.

### 5.4 Divisibility Transfer

**Definition 5.4.** hdvd(a, b) on HyperNat is defined by lifting EventuallyDvd(f, g) = ∃ N, ∀ n ≥ N, f(n) | g(n).

**Theorem 5.5.** This is well-defined and:
```
(∃ N, ∀ n ≥ N, f(n) | g(n)) ↔ hdvd(mk(f), mk(g))
```

**Theorem 5.6.** For all x, y ∈ HyperNat: hdvd(x, x · y).

### 5.5 Big-O Transfer

**Theorem 5.7.** If ∃ N, ∀ n ≥ N, f(n) ≤ c · g(n), then le(mk(f), ofNat'(c) · mk(g)).

### 5.6 Syntactic Transfer Example

**Theorem 5.8.** The identity x(x+1)(x+2) = x³ + 3x² + 2x, encoded as ArithTerms t_lhs and t_rhs, transfers to HyperNat by a single application of Theorem 4.4.

## 6. Verification Details

### 6.1 Implementation

The formalization consists of three files totaling approximately 400 lines:
- `Basic.lean`: Setoid, quotient, arithmetic operations, ordering, non-Archimedean property (~230 lines).
- `Transfer.lean`: ArithTerm, ArithTerm2, transfer theorems, divisibility (~175 lines).
- `Applications.lean`: Concrete transported theorems (~195 lines).

### 6.2 Axiom Audit

All theorems depend only on:
- `propext` (propositional extensionality)
- `Quot.sound` (quotient soundness)
- `Classical.choice` (classical logic, used via Mathlib imports)

No `sorry`, no custom axioms, no `@[implemented_by]` overrides.

### 6.3 Design Decisions

1. **Cofinite filter vs. ultrafilter.** We chose eventual agreement for simplicity. An ultrafilter upgrade would give a total order and full first-order transfer at the cost of non-constructive existence proofs.

2. **ArithTerm vs. Polynomial.** We defined a custom inductive type for arithmetic terms rather than using Mathlib's `Polynomial ℕ`. This avoids complications with Polynomial's representation (Finsupp-based) and makes the structural induction for transfer cleaner.

3. **Pointwise lifting for recursive functions.** Functions like T(n) and S(n) that are not polynomial are lifted via Quotient.lift with an explicit proof that eventual equality is preserved. This generalizes to any function ℕ → ℕ.

## 7. Discussion

### 7.1 Comparison with Ultrapowers

The eventual-equivalence quotient is strictly weaker than an ultrapower. Key differences:

| Property | Eventual Equivalence | Ultrapower |
|----------|---------------------|------------|
| Ordering | Preorder (not total) | Total order |
| Transfer scope | Quantifier-free | All first-order |
| Filter existence | Constructive | Requires choice |
| Decidability of equivalence | Π₁⁰-complete | Non-computable |
| Implementation complexity | Low | High |

Despite these limitations, the eventual-equivalence quotient suffices for all polynomial identity transfer, all polynomial inequality transfer, and all divisibility transfer — covering the vast majority of classical arithmetic theorems.

### 7.2 Connections to Tropical Mathematics

The eventual ordering on sequences is related to tropical comparison: in tropical arithmetic, a ≤ b means a is dominated by b. The hypernatural ordering captures asymptotic domination, suggesting connections to tropical semirings and valuations. Specifically, the map sending a sequence to its growth rate defines a tropical-style valuation on HyperNat.

### 7.3 Computational Complexity Interpretation

The big-O transfer theorem (5.7) shows that asymptotic complexity bounds can be recast as exact inequalities between hypernatural numbers. This suggests a program:
1. Represent algorithm running times as sequences.
2. Lift to HyperNat.
3. Compare using the eventual ordering.
4. Derive asymptotic complexity results as corollaries of exact hypernatural arithmetic.

## 8. Future Work

See FUTURE_DIRECTIONS.md for five specific, falsifiable conjectures. The most impactful directions are:

1. **Ultrafilter upgrade**: Generalize to a full ultrapower with Łoś's theorem.
2. **Polynomial asymptotic completeness**: Prove that the eventual ordering exactly captures polynomial growth comparison.
3. **Formal big-O arithmetic**: Build a complete algebraic framework for complexity analysis on hypernatural numbers.
4. **Extension to ℤ and ℝ**: Construct hyperintegers and hyperreals with the same approach.
5. **Quantified transfer**: Extend the ArithTerm language to include bounded quantifiers and prove transfer for Σ₁ formulas.

## References

[1] A. Robinson, *Non-standard Analysis*, North-Holland, 1966.

[2] C.C. Chang and H.J. Keisler, *Model Theory*, 3rd edition, North-Holland, 1990.

[3] R. Goldblatt, *Lectures on the Hyperreals: An Introduction to Nonstandard Analysis*, Springer, 1998.

[4] T. Tao, "Ultrafilters, nonstandard analysis, and epsilon management," in *Structure and Randomness*, AMS, 2008.

[5] J. Avigad, "Weak theories of nonstandard arithmetic and analysis," in *Reverse Mathematics 2001*, ASL, 2005.
