# Exact Minimum Distance of Reed–Muller Evaluation Codes and PIT Soundness: A Machine-Verified Development

## Abstract

We present a complete, machine-verified formalization of the exact minimum distance theorem for generalized Reed–Muller evaluation codes over finite fields, together with a derived PIT (Polynomial Identity Testing) soundness theorem. For a finite field 𝔽_q and integers n ≥ 1, 0 ≤ d < q, we prove that the minimum Hamming weight among nonzero evaluation codewords of total degree ≤ d polynomials in n variables is exactly (q − d) · q^(n−1). We construct an explicit extremal codeword — the product of d distinct linear factors in a single variable — that achieves this bound. As a corollary, we derive the Schwartz–Zippel probability bound in its sharp form: random evaluation detects polynomial nonzeroness with probability at least 1 − d/q.

The development is built in Lean 4 with Mathlib and consists of approximately 220 lines of formalized mathematics with zero unproven obligations (`sorry`-free). All theorems depend only on the standard axioms (propext, Classical.choice, Quot.sound).

## 1. Introduction

### 1.1 Motivation

Reed–Muller codes, introduced independently by Reed [1] and Muller [2] in 1954, are among the most fundamental families of error-correcting codes. Their generalization to arbitrary finite fields — the *generalized Reed–Muller codes* — connects coding theory to algebraic geometry, complexity theory, and cryptography through the Schwartz–Zippel lemma [3, 4].

The minimum distance of a code is its most basic structural parameter, determining error-detection and error-correction capability. For generalized Reed–Muller codes RM_q(n, d) with 0 ≤ d < q, the minimum distance is known to be (q − d) · q^(n−1). This result was established by Kasami, Lin, and Peterson [5] and independently by Delsarte, Goethals, and Mac Williams [6].

Despite its fundamental importance, this theorem had not previously been fully machine-verified. Our contribution closes this gap by providing a complete Lean 4 formalization, building on the Schwartz–Zippel lemma formalization in Mathlib.

### 1.2 Contributions

1. **Exact minimum distance theorem** (Theorem 5.1): A two-part result establishing both the lower bound and its tightness for RM_q(n, d).

2. **Explicit extremal codeword** (Theorem 4.5): Construction and full analysis of the witness polynomial ∏_{a ∈ s} (X₀ − a).

3. **PIT soundness theorems** (Theorems 6.1–6.2): The zero-fraction bound d/q and the detection probability bound 1 − d/q for polynomial identity testing.

4. **Reusable infrastructure**: Clean definitions of evaluation codewords, zero counts, and Hamming weights for multivariate polynomials over finite fields.

### 1.3 Related Work

The Schwartz–Zippel lemma has been formalized in various proof assistants. Our development builds on an existing Lean 4 formalization of the multivariate Schwartz–Zippel bound (the `SchwartzZippel.schwartz_zippel_succ` theorem), which provides the zero-count upper bound by induction on the number of variables.

The exact minimum distance of Reed–Muller codes is a classical result in coding theory. Our contribution is the first complete machine verification that we are aware of, connecting the abstract bound to an explicit witness construction and deriving the PIT soundness corollaries.

## 2. Definitions and Notation

### 2.1 Setting

Let 𝔽 = 𝔽_q be a finite field of cardinality q. Let n ≥ 1 be a positive integer and d a non-negative integer with d < q.

The *evaluation domain* is 𝔽^n = {x : Fin n → 𝔽}, which has cardinality q^n.

### 2.2 Multivariate Polynomials

We work with `MvPolynomial (Fin n) 𝔽`, the ring of multivariate polynomials in n variables over 𝔽. The *total degree* of a polynomial f is `f.totalDegree`.

### 2.3 Evaluation Codewords

**Definition 2.1** (Zero Count). For f ∈ 𝔽[X₁, …, Xₙ], define:
```
zeroCount(f) = |{x ∈ 𝔽^n : f(x) = 0}|
```
Formally: `(Finset.univ.filter (fun x => MvPolynomial.eval x f = 0)).card`.

**Definition 2.2** (Hamming Weight). For f ∈ 𝔽[X₁, …, Xₙ], define:
```
hammingWeight(f) = |{x ∈ 𝔽^n : f(x) ≠ 0}|
```
Formally: `(Finset.univ.filter (fun x => MvPolynomial.eval x f ≠ 0)).card`.

**Definition 2.3** (Witness Polynomial). For a finite subset s ⊆ 𝔽, define:
```
witnessPoly(s) = ∏_{a ∈ s} (X₀ − a) ∈ 𝔽[X₀, X₁, …, Xₙ]
```

### 2.4 Reed–Muller Code

The code RM_q(n, d) consists of evaluation vectors:
```
RM_q(n, d) = {(f(x))_{x ∈ 𝔽^n} : f ∈ 𝔽[X₁, …, Xₙ], deg(f) ≤ d}
```

The *minimum distance* of RM_q(n, d) is:
```
min{hammingWeight(f) : f ∈ 𝔽[X₁, …, Xₙ], f ≠ 0, deg(f) ≤ d}
```

## 3. Weight–Zero Count Duality

**Theorem 3.1** (Weight–Zero Count Partition).
For any f ∈ 𝔽[X₁, …, Xₙ]:
```
hammingWeight(f) + zeroCount(f) = q^n
```

*Proof sketch.* The evaluation domain 𝔽^n partitions into {x : f(x) ≠ 0} and {x : f(x) = 0}. These are complementary subsets of Finset.univ, so their cardinalities sum to |𝔽^n| = q^n. □

**Corollary 3.2.** hammingWeight(f) = q^n − zeroCount(f).

## 4. Witness Polynomial Analysis

### 4.1 Degree Control

**Theorem 4.1** (Degree of Witness).
For any s ⊆ 𝔽:
```
totalDegree(witnessPoly(s)) ≤ |s|
```

*Proof sketch.* Each factor X₀ − C(a) has total degree 1. By the submultiplicativity of total degree under products (MvPolynomial.totalDegree_finset_prod), the product of |s| factors has degree ≤ |s|. □

### 4.2 Nonzeroness

**Theorem 4.2** (Witness is Nonzero).
For any s ⊆ 𝔽:
```
witnessPoly(s) ≠ 0
```

*Proof sketch.* MvPolynomial over a field is an integral domain. Each factor X₀ − C(a) is nonzero (it evaluates to 1 at the constant function x ↦ a + 1). A product of nonzero elements in a domain is nonzero. □

### 4.3 Evaluation Characterization

**Theorem 4.3** (Evaluation Criterion).
For any s ⊆ 𝔽 and x ∈ 𝔽^n:
```
eval(x, witnessPoly(s)) = 0 ↔ x₀ ∈ s
```

*Proof sketch.* Evaluation distributes over products:
```
eval(x, witnessPoly(s)) = ∏_{a ∈ s} (x₀ − a)
```
This product is zero iff some factor is zero (since 𝔽 is a field, hence an integral domain), iff x₀ = a for some a ∈ s, iff x₀ ∈ s. □

### 4.4 Zero Count Computation

**Theorem 4.4** (Zero Count of Witness).
For any s ⊆ 𝔽:
```
zeroCount(witnessPoly(s)) = |s| · q^(n−1)
```

*Proof sketch.* By Theorem 4.3, the zero set is {x ∈ 𝔽^n : x₀ ∈ s}. This set fibers over the first coordinate: for each a ∈ s, the fiber {x : x₀ = a} has cardinality q^(n−1) (free choice of the remaining n − 1 coordinates). The fibers are disjoint (distinct values of x₀), so the total count is |s| · q^(n−1). □

### 4.5 Hamming Weight Computation

**Theorem 4.5** (Hamming Weight of Witness).
For s ⊆ 𝔽 with |s| ≤ q:
```
hammingWeight(witnessPoly(s)) = (q − |s|) · q^(n−1)
```

*Proof.* Immediate from Theorem 3.1, Theorem 4.4, and the identity q^n = q · q^(n−1). □

## 5. Main Results

### 5.1 Schwartz–Zippel Lower Bound

**Theorem 5.1** (Zero Count Bound).
For any nonzero f ∈ 𝔽[X₁, …, Xₙ]:
```
zeroCount(f) ≤ deg(f) · q^(n−1)
```

*Proof.* This is the Schwartz–Zippel lemma, proved by induction on n. The base case (n = 1) reduces to the univariate root bound. The inductive step decomposes f via the fiber polynomial construction, splitting the zero set into "good" fibers (where the fiber polynomial is nonzero, contributing ≤ deg₀(f) zeros) and "bad" fibers (where the fiber polynomial vanishes, bounded inductively by the leading coefficient's zero count). □

**Corollary 5.2** (Hamming Weight Lower Bound).
For any nonzero f with deg(f) ≤ d < q:
```
hammingWeight(f) ≥ (q − d) · q^(n−1)
```

### 5.2 Exact Minimum Distance

**Theorem 5.3** (Exact Minimum Distance of RM_q(n, d)).
For 0 ≤ d < q and n ≥ 1:

1. **Lower bound:** Every nonzero polynomial of total degree ≤ d has Hamming weight ≥ (q − d) · q^(n−1).

2. **Attainment:** There exists a nonzero polynomial of total degree ≤ d with Hamming weight exactly (q − d) · q^(n−1).

Therefore:
```
d_min(RM_q(n, d)) = (q − d) · q^(n−1)
```

*Proof.* Part 1 is Corollary 5.2. For Part 2, choose any d-element subset s ⊆ 𝔽 (which exists since d < q = |𝔽|). The witness polynomial witnessPoly(s) has degree ≤ d (Theorem 4.1), is nonzero (Theorem 4.2), and has Hamming weight (q − d) · q^(n−1) (Theorem 4.5). □

## 6. PIT Soundness

### 6.1 Zero-Fraction Bound

**Theorem 6.1** (PIT Soundness).
For any nonzero f with deg(f) ≤ d < q:
```
zeroCount(f) / q^n ≤ d / q
```

*Proof.* By Theorem 5.1, zeroCount(f) ≤ d · q^(n−1). Dividing both sides by q^n = q · q^(n−1) gives the result. □

### 6.2 Detection Probability

**Theorem 6.2** (PIT Detection Probability).
For any nonzero f with deg(f) ≤ d < q:
```
hammingWeight(f) / q^n ≥ 1 − d/q
```

*Proof.* By the weight–zero count duality (Theorem 3.1):
```
hammingWeight(f) / q^n = 1 − zeroCount(f) / q^n ≥ 1 − d/q
```
using Theorem 6.1. □

**Interpretation.** If a polynomial f of degree ≤ d is nonzero, then evaluating it at a uniformly random point of 𝔽_q^n yields a nonzero value with probability at least 1 − d/q. This is the fundamental soundness guarantee for randomized polynomial identity testing.

## 7. Applications

### 7.1 Error-Correcting Codes

The exact minimum distance directly determines:
- **Error detection capability:** RM_q(n, d) can detect up to (q − d) · q^(n−1) − 1 errors.
- **Error correction capability:** RM_q(n, d) can correct up to ⌊((q − d) · q^(n−1) − 1) / 2⌋ errors.
- **List decoding radius:** Informs capacity bounds for list-decoding algorithms.

### 7.2 Secret Sharing

Shamir's secret sharing scheme and its multivariate generalizations rely on polynomial evaluation over finite fields. The minimum distance determines the exact threshold:
- Any d points are insufficient to reconstruct the secret (privacy threshold).
- Any d + 1 points uniquely determine the polynomial (reconstruction threshold).

### 7.3 Polynomial Identity Testing

The PIT soundness theorem provides exact error bounds for the Schwartz–Zippel PIT algorithm:
- **Input:** An algebraic circuit C computing a polynomial of degree ≤ d.
- **Algorithm:** Evaluate C at a random point of 𝔽_q^n.
- **Soundness:** If C ≢ 0, the algorithm detects this with probability ≥ 1 − d/q.

### 7.4 Numerical Examples

For 𝔽₇ (q = 7), n = 3, d = 2:
- Total points: 7³ = 343
- Minimum distance: (7 − 2) · 7² = 5 · 49 = 245
- Maximum zeros: 2 · 49 = 98
- PIT error probability: ≤ 2/7 ≈ 0.286
- Detection probability: ≥ 5/7 ≈ 0.714

## 8. Formalization Architecture

### 8.1 File Structure

```
Cryptography/ReedMuller/
├── Defs.lean          -- Core definitions (zeroCount, hammingWeight, witnessPoly)
└── MinDistance.lean    -- All theorems (lower bound, witness, exact distance, PIT)
```

### 8.2 Dependencies

The development imports:
- `Mathlib`: Full Mathlib library for multivariate polynomials, finite fields, etc.
- `Algebra.CircuitComplexity.SchwartzZippel`: Pre-existing Schwartz–Zippel formalization.

### 8.3 Proof Statistics

| Theorem | Lines | Key tactics |
|---------|-------|-------------|
| hammingWeight_add_zeroCount | 4 | card_filter, sum_add_distrib |
| zeroCount_le | 3 | convert, SchwartzZippel |
| hammingWeight_ge | 5 | tsub_mul, linarith |
| totalDegree_witnessPoly | 8 | totalDegree_finset_prod |
| witnessPoly_ne_zero | 2 | prod_ne_zero_iff |
| eval_witnessPoly_eq_zero_iff | 3 | prod_eq_zero_iff, sub_eq_zero |
| zeroCount_witnessPoly | 12 | fiber counting, card_bij |
| hammingWeight_witnessPoly | 5 | tsub_mul, zeroCount_witnessPoly |
| pit_soundness | 4 | div_le_div_iff, norm_cast |
| pit_detection_probability | 4 | sub_le_sub_left, one_sub_div |

### 8.4 Axioms

All theorems depend only on:
- `propext` (propositional extensionality)
- `Classical.choice` (axiom of choice)
- `Quot.sound` (quotient soundness)

These are the standard Lean 4 axioms present in virtually all Mathlib developments.

## 9. Discussion

### 9.1 Design Choices

We chose to index the evaluation domain by `Fin (n + 1) → 𝔽` rather than `Fin n → 𝔽` in the main theorems. This avoids edge cases with n = 0 and makes the Schwartz–Zippel induction interface cleaner (the base case has 1 variable, which is `Fin (0 + 1)`).

The witness polynomial is defined as a product over a `Finset 𝔽` rather than being fixed to a specific choice of d elements. This gives maximum generality: the extremal property holds for *any* d-element subset, not just a canonical one.

### 9.2 Limitations

Our formalization covers the case 0 ≤ d < q. The general case d = a(q − 1) + b with 0 ≤ b < q − 1, where the minimum distance is (q − b) · q^(n−1−a), requires a more sophisticated argument involving products of coordinate blocks. This is a natural target for future work.

### 9.3 Connection to Algebraic Circuits

The prompt suggested connecting to algebraic circuits via `bounded_circuit_degree_bound`. Our PIT soundness theorems are stated directly for polynomials rather than circuits. The bridge from circuits to polynomials (via `AlgCircuit.toMvPolynomial`) is available in the existing `AlgebraicCircuitComplexity` module, and composing with our PIT theorems yields circuit-level PIT soundness.

## 10. Future Work

See FUTURE_DIRECTIONS.md for detailed research targets. Key directions include:

1. Generalized Reed–Muller codes for arbitrary degree d ≥ q.
2. Formal low-degree testing soundness.
3. Sum-check protocol verification.
4. Dual code structure and MacWilliams identities.
5. Decoding algorithms with correctness proofs.

## References

[1] I. S. Reed, "A class of multiple-error-correcting codes and the decoding scheme," IRE Trans. Inform. Theory, vol. 4, pp. 38–49, 1954.

[2] D. E. Muller, "Application of Boolean algebra to switching circuit design and to error detection," IRE Trans. Electron. Comput., vol. 3, pp. 6–12, 1954.

[3] J. T. Schwartz, "Fast probabilistic algorithms for verification of polynomial identities," J. ACM, vol. 27, pp. 701–717, 1980.

[4] R. Zippel, "Probabilistic algorithms for sparse polynomials," in Proc. EUROSAM, LNCS vol. 72, pp. 216–226, 1979.

[5] T. Kasami, S. Lin, and W. W. Peterson, "New generalizations of the Reed–Muller codes," IEEE Trans. Inform. Theory, vol. 14, pp. 189–199, 1968.

[6] P. Delsarte, J. M. Goethals, and F. J. Mac Williams, "On generalized Reed–Muller codes and their relatives," Inform. Control, vol. 16, pp. 403–442, 1970.

[7] S. Arora and B. Barak, *Computational Complexity: A Modern Approach*, Cambridge University Press, 2009.

[8] R. Lidl and H. Niederreiter, *Finite Fields*, Cambridge University Press, 1997.
