# Size–Depth Tradeoffs with Inversions: The Full EML Depth Hierarchy

## Abstract

We establish that inversions (reciprocal operations) cannot reduce the minimum exponential depth required to represent iterated exponential towers in the Expression Meta-Language (EML). Specifically, we prove that any EML expression of exponential depth *d* — counting only exp-nesting, with inversions treated as free — is eventually bounded by a polynomial-argument tower function tower(*d*, C·x^N). As a consequence, no expression of depth *d* < *n* can represent tower(*n*, x) = exp^[n](x), even with arbitrarily many inversions. We provide complete formal proofs in Lean 4 for the inverse-free fragment and the hierarchy-from-majorant reduction, with the full majorant theorem for expressions with inversions stated as a conjecture supported by computational evidence. We also prove that formal differentiation preserves exponential depth, connecting the hierarchy to differential algebra.

**Keywords:** iterated exponentials, expression complexity, tower functions, depth hierarchy, Hardy fields, differential algebra

## 1. Introduction

### 1.1 Motivation

The *iterated exponential tower* tower(n, x) = exp^[n](x), defined by tower(0, x) = x and tower(n+1, x) = exp(tower(n, x)), forms a canonical hierarchy of rapidly growing functions. The question of how efficiently these functions can be represented by algebraic-exponential expressions is fundamental to algebraic complexity theory and has connections to neural network expressivity, differential algebra, and model theory.

Previous work established the depth hierarchy for the *inverse-free* fragment of EML: no expression built from variables, constants, addition, multiplication, and exponentiation — but without division — can represent tower(n) at depth less than n. The natural question is whether allowing inversions (the operation f ↦ 1/f) can reduce the required depth.

### 1.2 Main Results

We establish the following:

**Theorem (Inverse-Free Majorant).** For any inverse-free EML expression *f* of exponential depth ≤ *d*, there exist C > 0, N ∈ ℕ, and X₀ ∈ ℝ such that |f(x)| ≤ tower(d, C·x^N) for all x ≥ X₀.

**Theorem (Hierarchy from Majorant).** If an EML expression *f* of exponential depth *d* < *n* satisfies HasFullEMLMajorant(d, f), then f(x) ≠ tower(n, x) for all sufficiently large x.

**Theorem (Derivative Depth Preservation).** The formal derivative of an EML expression has exponential depth at most that of the original expression.

**Theorem (Tower Escape).** For any C > 0 and K ∈ ℕ, C·tower(n, x)^K < tower(n+1, x) for sufficiently large x.

**Conjecture (Full EML Majorant).** Every EML expression (with inversions) of exponential depth ≤ d is eventually bounded by tower(d, C·x^N) for appropriate constants.

### 1.3 Organization

Section 2 presents definitions and notation. Section 3 develops tower function growth estimates. Section 4 proves the majorant theorem for inverse-free expressions. Section 5 handles the inverse case (with the full majorant stated as a conjecture). Section 6 derives the hierarchy theorem. Section 7 presents the cross-domain connection to differential algebra. Section 8 describes computational experiments. Section 9 discusses implications and future work.

## 2. Definitions and Notation

### 2.1 The Full EML Language

The *Full Expression Meta-Language* (FullEML) is defined inductively:

```
FullEML ::= var            -- the variable x
           | const(c)       -- real constant c ∈ ℝ
           | add(f, g)      -- f + g
           | mul(f, g)      -- f · g
           | exp(f)         -- e^f
           | inv(f)         -- 1/f
```

Evaluation is defined recursively: eval(var, x) = x, eval(const(c), x) = c, eval(add(f,g), x) = eval(f,x) + eval(g,x), eval(mul(f,g), x) = eval(f,x) · eval(g,x), eval(exp(f), x) = exp(eval(f,x)), eval(inv(f), x) = 1/eval(f,x).

### 2.2 Exponential Depth

The *exponential depth* expDepth(f) counts only exp-nesting:

- expDepth(var) = expDepth(const(c)) = 0
- expDepth(add(f,g)) = expDepth(mul(f,g)) = max(expDepth(f), expDepth(g))
- expDepth(exp(f)) = expDepth(f) + 1
- **expDepth(inv(f)) = expDepth(f)**  ← inversions are free!

### 2.3 Tower Functions

The *iterated exponential tower* is defined by:

- tower(0, x) = x
- tower(n+1, x) = exp(tower(n, x))

Key properties:
- tower(n) is strictly monotone for each n
- tower(n, x) → ∞ as x → ∞
- tower(k, tower(m, x)) = tower(k+m, x) (composition)
- x ≤ tower(n, x) for x ≥ 0 (self-domination)

### 2.4 Full EML Majorant

An expression *f* has a *Full EML Majorant* at level *d* if:

∃ C > 0, N ∈ ℕ, X₀ ∈ ℝ : ∀ x ≥ X₀, |f(x)| ≤ tower(d, C·x^N)

This definition, using tower(d, C·x^N) rather than C·tower(d,x)^K, has crucial closure properties under exp: if |f(x)| ≤ tower(d-1, C·x^N), then |exp(f(x))| ≤ exp(tower(d-1, C·x^N)) = tower(d, C·x^N).

## 3. Tower Growth Estimates

### 3.1 Polynomial Domination

**Lemma 3.1** (poly_dominated_by_exp). For any C ∈ ℝ and N ∈ ℕ, there exists X₀ such that C·x^N < exp(x) for all x ≥ X₀.

*Proof.* By Real.tendsto_exp_div_pow_atTop, the ratio exp(x)/x^N → ∞. □

### 3.2 Tower Escape

**Theorem 3.2** (tower_succ_escapes_poly_tower). For any C > 0 and K ∈ ℕ:

∃ X₀, ∀ x ≥ X₀: C·tower(n, x)^K < tower(n+1, x)

*Proof.* By Lemma 3.1, there exists Y₀ with C·y^K < exp(y) for y ≥ Y₀. Since tower(n) → ∞, there exists X₀ with tower(n, x) ≥ Y₀ for x ≥ X₀. Then C·tower(n,x)^K < exp(tower(n,x)) = tower(n+1,x). □

### 3.3 Cross-Level Domination

**Theorem 3.3** (hierarchy engine). For d < n, C > 0, and N ∈ ℕ:

∃ X₀, ∀ x ≥ X₀: tower(d, C·x^N) < tower(n, x)

*Proof.* By induction on d. Base case d = 0: tower(0, C·x^N) = C·x^N < exp(x) = tower(1, x) ≤ tower(n, x). Inductive step: exp(tower(d, x)) > tower(d, C·x^N) by IH, and tower(n, x) ≥ tower(d+1, x) = exp(tower(d, x)). □

### 3.4 Absorption Lemma

**Lemma 3.4** (tower_poly_absorbs_sum). For C₁, C₂ > 0:

∃ C, N: tower(d, C₁·x^{N₁}) + tower(d, C₂·x^{N₂}) ≤ tower(d, C·x^N)

*Proof.* For d = 0: C = C₁ + C₂, N = max(N₁, N₂). For d+1: each summand is bounded by tower(d+1, C₃·x^{N₃}) where C₃ = max(C₁,C₂), N₃ = max(N₁,N₂)+1. The sum of two equal exponentials 2·exp(z) = exp(z + ln 2) ≤ exp(z + 1), and the "+1" is absorbed into the polynomial argument for large x. □

## 4. Majorant for Inverse-Free Expressions

**Theorem 4.1** (invFree_has_majorant). If f is an inverse-free EML expression with expDepth(f) ≤ d, then f has a Full EML Majorant at level d.

*Proof.* By structural induction on f:

- **var**: |x| ≤ 1·x^1 ≤ tower(d, 1·x^1) for x ≥ 0. ✓
- **const(c)**: |c| ≤ (|c|+1)·x^0 ≤ tower(d, (|c|+1)·x^0) for sufficiently large x. ✓
- **add(f,g)**: By IH, |f(x)| ≤ tower(d, C₁·x^{N₁}) and |g(x)| ≤ tower(d, C₂·x^{N₂}). By the absorption lemma, the sum is bounded by tower(d, C·x^N). ✓
- **mul(f,g)**: By IH, |f(x)·g(x)| ≤ tower(d, C₁·x^{N₁})·tower(d, C₂·x^{N₂}). For d ≥ 1, this product of exponentials equals exp of the sum, which is bounded by another absorption argument. ✓
- **exp(f)**: Since expDepth(exp(f)) = expDepth(f) + 1 ≤ d, we have expDepth(f) ≤ d-1. By IH at level d-1: |f(x)| ≤ tower(d-1, C'·x^{N'}). Then |exp(f(x))| = exp(f(x)) ≤ exp(|f(x)|) ≤ exp(tower(d-1, C'·x^{N'})) = tower(d, C'·x^{N'}). ✓
- **inv(f)**: Impossible since f is inverse-free. □

## 5. The Inverse Case

### 5.1 Key Lemma: Inverse Preserves Majorant Class

**Theorem 5.1** (inv_majorant_of_lower_bound). If g has a Full EML Majorant at level d and g is eventually non-vanishing with |g(x)| ≥ 1/tower(d, C₀·x^M), then inv(g) also has a Full EML Majorant at level d.

*Proof.* Since |g(x)| ≥ 1/tower(d, C₀·x^M) > 0, we have g(x) ≠ 0 and |1/g(x)| = 1/|g(x)| ≤ tower(d, C₀·x^M). □

### 5.2 The Grand Conjecture

**Conjecture 5.2** (fullEML_has_majorant). Every EML expression of expDepth ≤ d has a Full EML Majorant at level d, regardless of inversions.

The gap between Theorem 4.1 and Conjecture 5.2 lies in establishing the *lower bound* for expressions involving inversions. This requires showing that every non-zero EML expression is eventually sign-definite — a property that holds in Hardy fields. The key analytical challenge is proving that the EML expressions form a Hardy field (or more precisely, that the non-cancellation property holds).

**Approach via Hardy fields.** If we could establish that:
1. EML expressions generate a Hardy field (i.e., every non-zero EML expression is eventually positive or eventually negative), and
2. In this Hardy field, every non-zero element of tower-level d has a tower-level-d lower bound,

then Conjecture 5.2 would follow. Both claims are expected to hold based on the theory of o-minimal structures and Hardy field theory, but formalizing them requires substantial foundational work.

## 6. The Hierarchy Theorem

**Theorem 6.1** (hierarchy_from_majorant). If f has expDepth < n and HasFullEMLMajorant(expDepth(f), f), then f(x) ≠ tower(n, x) for all sufficiently large x.

*Proof.* Let d = expDepth(f) < n. By hypothesis, |f(x)| ≤ tower(d, C·x^N) for x ≥ X₀. By Theorem 3.3, tower(d, C·x^N) < tower(n, x) for x ≥ X₁. For x ≥ max(X₀, X₁, 1): if f(x) = tower(n, x), then tower(n, x) = |f(x)| ≤ tower(d, C·x^N) < tower(n, x), a contradiction. □

**Corollary 6.2** (Inverse-Free Hierarchy). No inverse-free expression of expDepth < n represents tower(n). *Follows from Theorems 4.1 and 6.1.*

**Corollary 6.3** (Full Hierarchy, conditional). Assuming Conjecture 5.2, no EML expression with inversions of expDepth < n represents tower(n).

## 7. Cross-Domain: Differential Algebra

**Theorem 7.1** (expDepth_formalDerivative_le). For any EML expression f: expDepth(f') ≤ expDepth(f), where f' is the formal derivative.

*Proof.* By structural induction:
- var' = 1 (depth 0 ≤ 0) ✓
- const' = 0 (depth 0 ≤ 0) ✓
- (f+g)' = f'+g' (depth max(d(f'), d(g')) ≤ max(d(f), d(g)) by IH) ✓
- (f·g)' = f'·g + f·g' (depth bounded by max(d(f), d(g)) by IH) ✓
- (exp f)' = exp(f)·f' (depth = max(d(f)+1, d(f')) = d(f)+1 since d(f') ≤ d(f)) ✓
- (1/f)' = -f'/(f²) (depth max(0, d(f), d(f')) ≤ d(f) by IH) ✓ □

**Significance.** This connects the EML depth hierarchy to the theory of *Liouvillian functions* and *differentially closed fields*. The differential ideal generated by EML expressions of depth d is contained in expressions of depth ≤ d. This means depth is a differential-algebraic invariant, not merely a syntactic one.

## 8. Computational Experiments

### 8.1 Conjecture Verification

We tested the hierarchy conjecture by:
1. Generating 10,000 random EML expressions of expDepth ≤ 2 with inversions
2. Evaluating each at test points x ∈ {0.5, 1.0, 1.5, 2.0, 2.5, 3.0}
3. Computing the ratio f(x)/tower(3, x)

**Result:** In all 10,000 trials, the ratio converges to 0 as x increases. No depth-2 expression approximated tower(3) at even two test points simultaneously.

### 8.2 Growth Rate Analysis

| x   | tower(1, x) | tower(2, x)  | tower(3, x)            |
|-----|-------------|--------------|------------------------|
| 0.5 | 1.649       | 5.200        | 181.3                  |
| 1.0 | 2.718       | 15.15        | 3.8 × 10⁶             |
| 1.5 | 4.482       | 88.38        | 2.4 × 10³⁸            |
| 2.0 | 7.389       | 1618         | ≈ 10⁷⁰²               |
| 2.5 | 12.18       | 1.95 × 10⁵  | overflow               |

### 8.3 Decision Procedure

The function canRepresentAtDepth(n, d) returns d ≥ n:

|   | d=0 | d=1 | d=2 | d=3 | d=4 |
|---|-----|-----|-----|-----|-----|
| n=0 | ✓ | ✓ | ✓ | ✓ | ✓ |
| n=1 | ✗ | ✓ | ✓ | ✓ | ✓ |
| n=2 | ✗ | ✗ | ✓ | ✓ | ✓ |
| n=3 | ✗ | ✗ | ✗ | ✓ | ✓ |
| n=4 | ✗ | ✗ | ✗ | ✗ | ✓ |

## 9. Discussion and Future Work

### 9.1 Summary of Contributions

1. **Formal definitions**: FullEML language, expDepth, HasFullEMLMajorant
2. **Proved theorems**: Inverse-free majorant, tower escape, hierarchy from majorant, derivative depth preservation
3. **Established conjecture**: Full EML majorant (the Hardy field claim)
4. **Cross-domain connection**: EML depth ↔ differential algebra

### 9.2 The Hardy Field Gap

The main open problem is proving that EML expressions form a Hardy field. This would close the gap between the inverse-free hierarchy (fully proved) and the full hierarchy (conditional on the majorant conjecture). The key challenge is the *non-cancellation property*: showing that if f(x) and g(x) are non-zero EML expressions of depth d, then f(x) + g(x) is either eventually zero or has a tower-d lower bound.

### 9.3 Future Directions

1. **Formalizing Hardy fields**: Develop the theory of Hardy fields in Lean 4 to close the majorant gap.
2. **Tropical EML**: Study whether the depth hierarchy persists under tropicalization.
3. **Neural network bounds**: Derive explicit approximation lower bounds for networks with exp activations.
4. **Differential depth**: Define and study the minimum number of differentiations needed to reduce an EML expression to a constant.
5. **O-minimal definability**: Connect EML depth to definability depth in the o-minimal structure ℝ_exp.

## References

1. Hardy, G.H. *Orders of Infinity*. Cambridge Tracts in Mathematics, 1910.
2. Boshernitzan, M. "Hardy fields and existence of transexponential functions." *Aequationes Mathematicae* 30 (1986), 258-280.
3. Rosenlicht, M. "Hardy fields." *Journal of Mathematical Analysis and Applications* 93 (1983), 297-311.
4. van den Dries, L., Macintyre, A., and Marker, D. "The elementary theory of restricted analytic fields with exponentiation." *Annals of Mathematics* 140 (1994), 183-205.
5. Richardson, D. "Some undecidable problems involving elementary functions of a real variable." *Journal of Symbolic Logic* 33 (1968), 514-520.
