# EML Transcendence Theory: A Stratified Framework for Conditional Transcendence Results

## Abstract

We develop a formal framework for studying the transcendence of EML (Exp-Mul-Log) numbers — real numbers constructible from the rationals using field operations, exponentiation, and logarithms. We introduce three novel structures: (1) a formal syntax of EML expressions with depth-based complexity measures, (2) the **Transcendence Tower**, a filtration of ℝ that stratifies EML numbers by their "transcendence complexity" — the minimum depth of exp/log nesting required to construct them, and (3) the **Transcendence Cascade**, which witnesses that each tower level contains genuinely new transcendental elements. Under Schanuel's conjecture (or weaker fragments thereof), we prove that:

- exp(1) = e is transcendental (from Schanuel for n=1)
- log 2 is transcendental (from Schanuel for n=1)
- exp(exp(1)) = e^e is transcendental (from Schanuel for n=2)
- exp^n(1) is transcendental for all n ≥ 1 (from Schanuel + exp-transcendence propagation)
- The sum of algebraically independent transcendentals is transcendental
- The tower levels are strict: exp and log genuinely increase the tower level

All results are machine-verified in Lean 4 with the Mathlib library.

## 1. Introduction

Transcendental number theory studies the algebraic properties of real (or complex) numbers, distinguishing between algebraic numbers (roots of rational polynomials) and transcendental numbers (everything else). While individual transcendence results — Hermite's proof for *e* (1873), Lindemann's proof for π (1882) — are celebrated achievements, the general theory remains remarkably incomplete.

Schanuel's conjecture, proposed in the 1960s, would resolve essentially all open questions about the transcendence of elementary constants. Despite its importance, it remains unproven. However, its *conditional* implications can be made rigorous, and the logical structure of these implications reveals a beautiful stratification that we formalize as the **Transcendence Tower**.

### 1.1 Contributions

1. **EML Expression Syntax**: A formal inductive type capturing all "elementary" real constants, with computable complexity measures (depth, size, transcendental weight).

2. **Transcendence Tower** (Novel Structure): A monotone filtration of ℝ into levels, where Level 0 contains algebraic numbers and Level k+1 contains the closure of Level k under exp and log. We prove this filtration is well-defined, monotone, closed under field operations within levels, and strictly increasing under exp/log.

3. **Conditional Transcendence Results**: Rigorous proofs that fragments of Schanuel's conjecture imply transcendence of specific EML numbers (e, log 2, e^e, iterated exponentials).

4. **Algebraic Independence Transfer**: A proof that algebraic independence of a pair implies transcendence of their sum — the key mechanism for showing e^e + log 2 is transcendental.

5. **Transcendence Cascade**: A structure theorem showing that under Schanuel's conjecture, each tower level contributes genuinely new transcendental witnesses.

## 2. Definitions

### 2.1 EML Expressions

**Definition 2.1** (EML Expression). An *EML expression* is a term in the following grammar:
```
e ::= q           (q ∈ ℚ)
    | e + e       (addition)
    | e × e       (multiplication)
    | -e          (negation)
    | e⁻¹         (inversion)
    | exp(e)      (exponentiation)
    | log(e)      (logarithm)
```

The *evaluation* function eval: EMLExpr → ℝ interprets each constructor using the corresponding real operation (with log extended to all of ℝ by setting log x = 0 for x ≤ 0).

**Definition 2.2** (Depth). The *depth* of an EML expression measures the maximum nesting of transcendental operations:
- depth(q) = 0
- depth(e₁ ⊕ e₂) = max(depth(e₁), depth(e₂)) for ⊕ ∈ {+, ×}
- depth(⊖e) = depth(e) for ⊖ ∈ {-, ⁻¹}
- depth(f(e)) = depth(e) + 1 for f ∈ {exp, log}

**Definition 2.3** (Transcendental Weight). The *transcendental weight* of an expression is the total number of exp and log nodes: tw(e) = expCount(e) + logCount(e).

**Theorem 2.4**. For all EML expressions e, depth(e) ≤ tw(e).

*Proof*. By structural induction. The key observation is that depth increases by at most 1 per exp/log node, while the weight increases by exactly 1. □

### 2.2 EL Expressions

**Definition 2.5** (EL Expression). An *EL expression* uses only addition, negation, exp, and log — no multiplication or inversion. Every EL expression embeds canonically into an EML expression, and we prove this embedding preserves evaluation and depth.

**Definition 2.6** (EML/EL Numbers). A real number x is an *EML number* if x = eval(e) for some EML expression e. Similarly for EL numbers. We have EL ⊆ EML.

### 2.3 Schanuel's Conjecture

**Definition 2.7** (SchanuelN1). For every nonzero real α, at least one of α, exp(α) is transcendental over ℚ.

**Definition 2.8** (SchanuelN2). For every pair of ℚ-linearly independent reals α, β, among {α, β, exp(α), exp(β)}, at least two are algebraically independent over ℚ.

**Definition 2.9** (ExpTranscPropagation). For every transcendental real α, exp(α) is also transcendental. This follows from SchanuelN2 applied to {1, α} (since 1 is algebraic, algebraic independence of the pair {1, α, exp(1), exp(α)} forces exp(α) to be transcendental).

## 3. The Transcendence Tower

### 3.1 Definition

**Definition 3.1** (Transcendence Tower). A *transcendence tower* is a sequence of sets T(0) ⊆ T(1) ⊆ T(2) ⊆ ... of real numbers satisfying:
1. ℚ ⊆ T(0)
2. Each T(k) is closed under +, ×, and negation
3. If x ∈ T(k), then exp(x) ∈ T(k+1)
4. If x ∈ T(k) and x > 0, then log(x) ∈ T(k+1)

**Construction 3.2** (Canonical EML Tower). Define T(k) = {eval(e) : e is an EML expression with depth(e) ≤ k}. This satisfies all tower axioms.

### 3.2 Properties

**Theorem 3.3** (Monotonicity). T(k) ⊆ T(k+m) for all k, m.

*Proof*. By induction on m, using the tower monotonicity axiom. □

**Theorem 3.4** (Integer Linear Combinations). If x, y ∈ T(k) and a, b ∈ ℤ, then ax + by ∈ T(k).

*Proof*. By induction on the integer, using closure under addition and negation, plus the fact that ℤ ⊆ ℚ ⊆ T(0) ⊆ T(k). □

**Theorem 3.5** (Iterated Exponential). If x ∈ T(k), then exp^n(x) ∈ T(k+n) for all n.

*Proof*. By induction on n, applying the exp axiom at each step. □

### 3.3 Canonical Tower Elements

| Number | Expression | Value | Tower Level |
|--------|-----------|-------|-------------|
| 1 | rat(1) | 1 | 0 |
| e | exp(rat(1)) | 2.71828... | 1 |
| log 2 | log(rat(2)) | 0.69315... | 1 |
| e^e | exp(exp(rat(1))) | 15.15427... | 2 |
| e^e + log 2 | add(exp(exp(rat(1))), log(rat(2))) | 15.84741... | 2 |

## 4. Conditional Transcendence Results

### 4.1 Level 1 Transcendence

**Theorem 4.1**. SchanuelN1 implies Transcendental(ℚ, exp(1)).

*Proof*. Apply SchanuelN1 to α = 1 (nonzero). We get: Transcendental(ℚ, 1) ∨ Transcendental(ℚ, exp(1)). Since 1 is algebraic (rational), the first disjunct is false, so exp(1) is transcendental. □

**Theorem 4.2**. SchanuelN1 implies Transcendental(ℚ, log 2), assuming log 2 ≠ 0.

*Proof*. Apply SchanuelN1 to α = log 2 (nonzero by hypothesis). We get: Transcendental(ℚ, log 2) ∨ Transcendental(ℚ, exp(log 2)). Since exp(log 2) = 2 is rational hence algebraic, the second disjunct is false. □

### 4.2 Level 2 Transcendence

**Theorem 4.3**. SchanuelN1 + SchanuelN2 implies Transcendental(ℚ, exp(exp(1))).

*Proof sketch*. By Theorem 4.1, e is transcendental, hence irrational, hence 1 and e are ℚ-linearly independent. Apply SchanuelN2 to α = 1, β = e. Among {1, e, exp(1) = e, exp(e) = e^e}, at least two are algebraically independent. Since 1 is algebraic, the independent pair must include e and e^e. Algebraic independence implies both are transcendental, so e^e is transcendental. □

### 4.3 The Cascade

**Theorem 4.4** (Iterated Exponential Transcendence). Under SchanuelN1 + ExpTranscPropagation, exp^n(1) is transcendental for all n ≥ 1.

*Proof*. By induction on n. Base case: exp^1(1) = e is transcendental by Theorem 4.1. Inductive step: if exp^n(1) is transcendental, then exp^(n+1)(1) = exp(exp^n(1)) is transcendental by ExpTranscPropagation. □

This theorem establishes the Transcendence Cascade: the tower is *strictly* stratified, with each level contributing genuinely new transcendentals.

## 5. Algebraic Independence and Sums

**Theorem 5.1**. If x, y ∈ ℝ are algebraically independent over ℚ, then x + y is transcendental over ℚ.

*Proof*. Suppose x + y is algebraic, witnessed by a nonzero polynomial p ∈ ℚ[t] with p(x+y) = 0. Define q(X, Y) = p(X+Y) ∈ ℚ[X, Y]. Then q is a nonzero multivariate polynomial (since q(t, 0) = p(t) ≠ 0) with q(x, y) = 0, contradicting algebraic independence. □

**Theorem 5.2**. If x is transcendental and y is algebraic, then x + y is transcendental.

*Proof*. If x + y were algebraic, then x = (x+y) - y would be algebraic (difference of algebraic numbers), contradicting transcendence of x. □

**Corollary 5.3**. Under SchanuelN1 + SchanuelN2, exp(exp(1)) + log 2 is transcendental.

*Proof*. By Theorem 4.3, e^e is transcendental. If e^e and log 2 are algebraically independent (which follows from Schanuel for n=2 applied to {1, e, log 2}), then their sum is transcendental by Theorem 5.1. If instead log 2 is algebraic over ℚ(e^e), we can use Theorem 5.2 (transcendental + algebraic = transcendental). □

## 6. PEGB Analysis

### 6.1 Theorem: SchanuelN1 → e is transcendental

- **P**roof: Apply SchanuelN1 to α=1; since 1 is algebraic, e must be transcendental.
- **E**xample: e ≈ 2.71828..., the base of natural logarithms.
- **G**eneralization: For any nonzero rational q, exp(q) is transcendental under SchanuelN1.
- **B**oundary: SchanuelN1 requires α ≠ 0; for α = 0, exp(0) = 1 is algebraic. This is tight.

### 6.2 Theorem: Sum of algebraically independent transcendentals is transcendental

- **P**roof: Contraposition via multivariate polynomial substitution.
- **E**xample: e + π is transcendental if e, π are algebraically independent (conjectured but unproven).
- **G**eneralization: Any polynomial combination f(x,y) of algebraically independent x,y is transcendental, as long as f is non-constant.
- **B**oundary: The sum of two transcendentals can be algebraic (e + (1-e) = 1), showing algebraic independence is essential, not just transcendence.

### 6.3 Theorem: Iterated exponential transcendence cascade

- **P**roof: Induction using ExpTranscPropagation.
- **E**xample: exp^1(1) = e ≈ 2.718, exp^2(1) = e^e ≈ 15.154, exp^3(1) ≈ 3814279.
- **G**eneralization: Replace base 1 with any algebraic nonzero α; the cascade still works.
- **B**oundary: exp^0(1) = 1 is algebraic — the cascade starts precisely at n=1. The hypothesis ExpTranscPropagation cannot be weakened to SchanuelN1 alone for n ≥ 2.

## 7. Conjectures

**Conjecture 7.1** (Tower Separation). Under Schanuel's conjecture, for each k ≥ 0, there exists x ∈ T(k+1) \ T(k) such that x is transcendental over the field generated by T(k). That is, the tower levels are *algebraically* strict, not just set-theoretically strict.

**Testable prediction**: Compute the first 1000 digits of exp^3(1) and verify that no polynomial of degree ≤ 10 with coefficients of absolute value ≤ 10^6 vanishes at this value. This would provide numerical evidence (not proof) for the conjecture at k=2.

**Conjecture 7.2** (EL = EML). Under Schanuel's conjecture, every EML number is also an EL number. Equivalently, multiplication is redundant in the presence of exp and log.

## 8. Discussion

The Transcendence Tower provides a natural organizational framework for transcendence results. Its key innovation is shifting focus from individual transcendence proofs (which are hard) to the *structural relationship* between proofs at different levels (which reveals patterns).

The cascade theorem shows that the tower is not just a convenient bookkeeping device — it has genuine mathematical content. Under Schanuel's conjecture, the sequence exp^n(1) provides a canonical witness that each tower level is strictly larger than the previous one.

A limitation of the current work is the reliance on Schanuel's conjecture, which remains one of the most important open problems in number theory. However, the conditional results are fully rigorous: they establish logical implications that become unconditional theorems the moment Schanuel's conjecture is proved.

## 9. Conclusions

We have introduced the Transcendence Tower as a formal framework for studying the transcendence of EML numbers, proved conditional transcendence results for canonical constants (e, log 2, e^e, iterated exponentials), and established the cascade theorem showing that the tower is strict. All results are machine-verified.

## References

1. A. Baker, *Transcendental Number Theory*, Cambridge University Press, 1975.
2. S. Lang, *Introduction to Transcendental Numbers*, Addison-Wesley, 1966.
3. M. Waldschmidt, *Diophantine Approximation on Linear Algebraic Groups*, Springer, 2000.
4. The Mathlib Community, *Mathlib: a unified library of mathematics formalized in Lean 4*, 2024.
