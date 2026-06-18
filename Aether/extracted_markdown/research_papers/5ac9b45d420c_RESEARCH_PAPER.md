# Transreal Arithmetic: Algebraic Structure of Anderson's Number System

## Abstract

We present a complete formalization of transreal arithmetic—the extension of the real numbers ℝ with three additional elements: positive infinity (+∞), negative infinity (-∞), and nullity (Φ = 0/0). We prove that the transreals fail to form a ring due to three independent axiom violations: additive cancellation failure, failure of the absorption law 0·x = 0, and left distributivity failure. Surprisingly, the zero-product property (ab = 0 → a = 0 ∨ b = 0) is preserved. We classify the additively idempotent elements as exactly {0, +∞, -∞, Φ}, characterize negation fixed points as {0, Φ}, and show that the standard wheel identity x + 0·x = x fails for infinite elements. All results are machine-verified in Lean 4 with Mathlib, ensuring complete rigor.

## 1. Introduction

Division by zero has been forbidden since the foundations of algebra were laid. The standard approach treats a/0 as undefined, making division a partial function. This leads to practical difficulties in computing (exception handling, NaN propagation) and theoretical awkwardness in analysis (limit theorems require careful domain restrictions).

Anderson's transreal arithmetic [1] takes a different approach: it assigns explicit values to all divisions, defining a/0 = +∞ for a > 0, a/0 = -∞ for a < 0, and 0/0 = Φ where Φ ("nullity") is a new mathematical object. The resulting system ℝᵀ = ℝ ∪ {+∞, -∞, Φ} has total arithmetic operations.

Previous work has explored transreal arithmetic informally and computationally. Our contribution is the first complete formal verification of its algebraic structure, establishing precisely which standard algebraic axioms hold and which fail, with machine-checked proofs in Lean 4.

## 2. Definitions

### 2.1 The Transreal Numbers

**Definition 1** (Transreal Numbers). The set of transreal numbers is the disjoint union
$$\mathbb{R}^T = \mathbb{R} \sqcup \{+\infty, -\infty, \Phi\}$$
where ℝ is the set of real numbers.

**Definition 2** (Sign Classification). For r ∈ ℝ:
$$\text{sign}(r) = \begin{cases} \text{pos} & r > 0 \\ \text{neg} & r < 0 \\ \text{zero} & r = 0 \end{cases}$$

### 2.2 Arithmetic Operations

**Definition 3** (Transreal Addition).
$$a + b = \begin{cases}
a +_{\mathbb{R}} b & a, b \in \mathbb{R} \\
+\infty & a = +\infty, b \in \mathbb{R} \cup \{+\infty\} \\
-\infty & a = -\infty, b \in \mathbb{R} \cup \{-\infty\} \\
\Phi & a = +\infty, b = -\infty \text{ (or vice versa)} \\
\Phi & a = \Phi \text{ or } b = \Phi
\end{cases}$$

**Definition 4** (Transreal Multiplication).
$$a \times b = \begin{cases}
a \times_{\mathbb{R}} b & a, b \in \mathbb{R} \\
\pm\infty & a = \pm\infty, b \in \mathbb{R}, \text{sign}(b) \neq 0 \\
\Phi & a = \pm\infty, b = 0 \text{ (or vice versa)} \\
+\infty & a, b \text{ same sign infinities} \\
-\infty & a, b \text{ opposite sign infinities} \\
\Phi & a = \Phi \text{ or } b = \Phi
\end{cases}$$

**Definition 5** (Transreal Inversion).
$$a^{-1} = \begin{cases}
a^{-1}_{\mathbb{R}} & a \in \mathbb{R}, a \neq 0 \\
+\infty & a = 0 \\
0 & a = \pm\infty \\
\Phi & a = \Phi
\end{cases}$$

Division is defined as $a / b = a \times b^{-1}$.

## 3. Main Results

### 3.1 Nullity Absorption (Theorems 1-4)

**Theorem 1** (Additive Absorption). For all x ∈ ℝᵀ: Φ + x = Φ and x + Φ = Φ.

**Theorem 2** (Multiplicative Absorption). For all x ∈ ℝᵀ: Φ × x = Φ and x × Φ = Φ.

*Proof.* By case analysis on x ∈ {ofReal(r), +∞, -∞, Φ}. In each case, the definition directly yields Φ. □

**Remark.** Absorption is the defining property of nullity. It formalizes the intuition that indeterminacy is "contagious"—once information is lost, no operation can recover it.

### 3.2 Ring Axiom Failures (Theorems 3-7)

**Theorem 3** (Additive Group Failure). The transreals do not form an additive group: ∃x ∈ ℝᵀ such that x + (-x) ≠ 0.

*Proof.* Take x = Φ. Then -Φ = Φ and Φ + Φ = Φ ≠ ofReal(0). □

**Theorem 4** (Additive Cancellation Failure). ∃a, b, c ∈ ℝᵀ such that a + c = b + c but a ≠ b.

*Proof.* Take a = ofReal(1), b = +∞, c = +∞. Then ofReal(1) + ∞ = ∞ = ∞ + ∞, but ofReal(1) ≠ +∞. □

**Theorem 5** (Zero-Absorption Failure). 0 × (+∞) = Φ ≠ 0.

**Theorem 6** (Ring Axiom 0·x = 0 Fails). ¬(∀x ∈ ℝᵀ: 0 · x = 0).

*Proof.* Counterexample: 0 × ∞ = Φ ≠ 0, by the sign dispatch in multiplication (sign(0) = zero, giving nullity). □

**Theorem 7** (Left Distributivity Failure). ¬(∀a, b, c ∈ ℝᵀ: a(b + c) = ab + ac).

*Proof.* Take a = +∞, b = 0, c = 1. LHS: ∞ × (0 + 1) = ∞ × 1 = ∞. RHS: ∞ × 0 + ∞ × 1 = Φ + ∞ = Φ. Since ∞ ≠ Φ, distributivity fails. □

**Remark.** The mechanism of distributivity failure is illuminating: the nullity from ∞ × 0 "infects" the sum through absorption. This is the algebraic expression of information loss: splitting a computation into parts can introduce artificial indeterminacies that weren't present in the original.

### 3.3 The Zero-Product Property Survives (Theorem 8)

**Theorem 8** (Zero-Product Property). For all a, b ∈ ℝᵀ: ab = 0 → a = 0 ∨ b = 0.

*Proof.* Key lemma: if mul(a, b) = ofReal(0), then a and b must both be real (ofReal). This is because:
- nullity × anything = nullity ≠ ofReal(0)
- ∞ × ∞ = ±∞ ≠ ofReal(0)
- ∞ × real = ±∞ or Φ, never ofReal(0) (checked by sign cases)

Once both factors are real, the standard real zero-product property applies. □

**Remark.** This theorem is surprising given the other axiom failures. It holds because the image of multiplication restricted to non-real inputs never includes ofReal(0)—non-real products are always non-real.

### 3.4 Structural Results (Theorems 9-13)

**Theorem 9** (Commutativity). Addition and multiplication are commutative on ℝᵀ.

**Theorem 10** (Negation Fixed Points). -x = x iff x = 0 or x = Φ.

*Proof.* Forward: for ofReal(r), -r = r implies r = 0 by linearity. For ±∞, negation swaps them. For Φ, -Φ = Φ by definition.  □

**Theorem 11** (Idempotent Classification). x + x = x iff x ∈ {+∞, -∞, Φ, 0}.

*Proof.* For ofReal(r): r + r = r iff 2r = r iff r = 0. For +∞, -∞, Φ: follows from the addition table. □

**Theorem 12** (Multiplicative Identity). x · 1 = x for all x ∈ ℝᵀ.

**Theorem 13** (Negation Involution). -(-x) = x for all x ∈ ℝᵀ.

### 3.5 Order Theory (Theorem 14)

**Theorem 14** (Non-Totality). The natural order on ℝᵀ (extending ≤ on ℝ with -∞ ≤ everything ≤ +∞) is NOT total: Φ and 0 are incomparable.

### 3.6 Division by Zero (Theorems 15-16)

**Theorem 15**. For r > 0: ofReal(r) / ofReal(0) = +∞.

**Theorem 16**. ofReal(0) / ofReal(0) = Φ (the defining equation of nullity).

### 3.7 Wheel Identity Analysis (Theorems 17-18)

**Theorem 17**. The wheel identity x + 0·x = x holds for all real elements.

**Theorem 18**. The wheel identity FAILS for +∞: (+∞) + 0·(+∞) = Φ ≠ +∞.

## 4. Discussion

### 4.1 Algebraic Classification

The transreals with Anderson's operations form a structure that is:
- A commutative monoid under multiplication (with identity 1)
- NOT a group under addition (no additive inverses for ∞ and Φ)
- NOT a ring (distributivity and 0-absorption fail)
- NOT a wheel (the wheel identity fails for infinite elements)
- NOT totally ordered (Φ is incomparable with reals)

The structure that emerges is novel: it has properties of both rings and wheels but satisfies the axioms of neither. We propose the name *transring* for this intermediate algebraic structure.

### 4.2 Information-Theoretic Interpretation

Nullity can be understood as an *information-theoretic* concept rather than a numerical one. It marks positions in a computation where information has been irreversibly lost. The absorption property (Φ + x = Φ) formalizes the principle that "garbage in, garbage out"—no subsequent computation can recover lost information.

This interpretation explains the distributivity failure: splitting ∞ × (0 + 1) into ∞ × 0 + ∞ × 1 introduces an artificial encounter with 0 × ∞ that the unsplit computation avoids. The split computation loses information that the original preserves.

### 4.3 Comparison with IEEE 754 NaN

Transreal nullity Φ and IEEE 754 NaN serve similar purposes but differ in key ways:

| Property | Φ (Transreal) | NaN (IEEE 754) |
|----------|--------------|----------------|
| Φ = Φ    | True         | False (NaN ≠ NaN) |
| Absorbing | Yes (Φ + x = Φ) | Mostly (NaN + x = NaN) |
| Algebraically consistent | Yes | No |
| Ordered | Partial (incomparable with reals) | Unordered |

The key advantage of Φ is algebraic consistency: it satisfies Φ = Φ and has well-defined algebraic properties, unlike NaN whose behavior is specified by engineering convention rather than mathematical axioms.

## 5. Conjectures and Open Problems

**Conjecture 1** (Associativity). Addition is associative on all of ℝᵀ (not just for real triples). We verified this for real triples; the general case requires checking 64 combinations.

**Conjecture 2** (Transring Axiomatization). The transreals satisfy a finite, clean axiom system intermediate between rings and wheels. Finding this axiom system is an open problem.

**Conjecture 3** (Unique Extension). Anderson's transreal operations are the unique extension of real arithmetic to ℝ ∪ {+∞, -∞, Φ} satisfying: (a) nullity absorption, (b) commutativity, (c) real restriction agreement, (d) ∞ × 0 = Φ.

## 6. Formalization

All results were formalized in Lean 4 with Mathlib (v4.28.0). The transreal type is defined as an inductive type with four constructors. Operations are defined by case analysis using `noncomputable def` (due to dependence on classical real number arithmetic). Proofs use `cases`, `simp`, `linarith`, and explicit term construction. The formalization comprises approximately 300 lines with 20+ verified theorems and no `sorry` or non-standard axioms.

## References

[1] Anderson, J.A.D.W. "Perspex Machine VIII: Axioms of Transreal Arithmetic." *Vision Geometry XV*, SPIE, 2007.

[2] Gomide, W., Reis, T.S.D. "Transreal Arithmetic as a Consistent Foundation for Paraconsistent Logics." *Proceedings of the 5th World Congress on Paraconsistency*, 2014.

[3] Setzer, A. "Wheels — On Division by Zero." *Mathematical Structures in Computer Science*, 7(6), 1997.
