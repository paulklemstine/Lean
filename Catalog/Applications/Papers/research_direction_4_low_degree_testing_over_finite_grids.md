# Formalized Low-Degree Testing over Finite Grids: A Grid Schwartz–Zippel Theorem with Applications to Coding Theory and Computational Complexity

## Abstract

We present a complete machine-verified formalization of the Grid Schwartz–Zippel theorem and its principal corollaries in the Lean 4 proof assistant. The central result establishes that a nonzero multivariate polynomial of total degree *d* over a field *K*, evaluated on a Cartesian product grid *S^n* where *S ⊆ K* is a finite set with |*S*| > *d*, has at most *d* · |*S*|^(*n*−1) zeros on the grid. We derive three corollaries: (A) a uniqueness theorem for polynomial agreement on grids, (B) a corrected uniqueness-of-explanation theorem for noisy functions with a combined-agreement hypothesis, and (C) a minimum distance bound for Reed–Muller-type evaluation codes. The formalization uncovered that the natural individual-agreement hypothesis for Theorem B is insufficient; we provide a counterexample and the correct combined-agreement formulation. All proofs are complete (no `sorry`) and use only standard axioms.

## 1. Introduction

### 1.1 Background and Motivation

The Schwartz–Zippel lemma (Schwartz 1980, Zippel 1979, DeMillo–Lipton 1978) is a foundational result in algebraic complexity theory. In its classical form, it states that a nonzero polynomial of total degree *d* over a field *K*, evaluated at a uniformly random point from *S^n* where *S ⊆ K* is finite, evaluates to zero with probability at most *d*/|*S*|.

While the probabilistic formulation is best known, the underlying combinatorial statement — the zero-count bound — is the true structural theorem. It asserts:

**Grid Schwartz–Zippel Bound.** If *p* ∈ *K*[*x*₁, …, *x*ₙ] is nonzero with total degree *d* < |*S*|, then
|{*x* ∈ *S^n* : *p*(*x*) = 0}| ≤ *d* · |*S*|^(*n*−1).

This bound is the algebraic nucleus from which multiple important results in theoretical computer science emerge:

1. **Reed–Muller codes**: Evaluation codes over grids inherit explicit minimum distance from this bound.
2. **Polynomial identity testing**: Random evaluation tests are sound because disagreement is pervasive.
3. **Low-degree testing**: The soundness of local-to-global consistency tests relies on polynomial rigidity.
4. **PCPs and interactive proofs**: The sum-check protocol's soundness reduces to the Schwartz–Zippel bound.
5. **Self-correction**: Uniqueness of the underlying polynomial enables correction from noisy oracles.

### 1.2 Contributions

We formalize the following results in Lean 4:

1. **Grid Schwartz–Zippel Theorem** (`grid_schwartz_zippel`): The zero-count bound for polynomials on arbitrary finite grids over arbitrary fields.

2. **Uniqueness from Large Agreement** (`mvpoly_eq_on_grid_of_agree_many`): Two bounded-degree polynomials agreeing on more than *d* · |*S*|^(*n*−1) grid points must agree on all grid points.

3. **Uniqueness of Low-Degree Explanation** (`low_degree_explanation_unique`): The corrected version with combined-agreement hypothesis, along with a counterexample showing the individual-agreement version is false.

4. **Reed–Muller Distance Bound** (`low_degree_code_distance`): Distinct bounded-degree polynomials disagree on at least |*S*|^*n* − *d* · |*S*|^(*n*−1) grid points.

### 1.3 Related Work

Previous formalizations of the Schwartz–Zippel lemma exist for the case where *S* = *K* is a finite field (requiring `[Fintype K]`). Our formalization generalizes to arbitrary finite subsets of arbitrary fields, which is essential for applications where the evaluation domain is a strict subset of the field.

The project builds on Mathlib's extensive library of multivariate polynomial algebra, particularly `MvPolynomial`, `MvPolynomial.finSuccEquiv`, and the `Polynomial` library for univariate root bounds.

## 2. Definitions and Notation

### 2.1 The Finite Grid

**Definition** (Grid). For a field *K*, a finite set *S* : Finset *K*, and *n* : ℕ, the grid is:

Grid(*S*, *n*) := { *x* : Fin *n* → *K* | ∀ *i*, *x*(*i*) ∈ *S* }

In Lean, this is implemented as `Fintype.piFinset (fun _ : Fin n => S)`.

**Lemma** (Grid Cardinality). |Grid(*S*, *n*)| = |*S*|^*n*.

### 2.2 Multivariate Polynomials

We use Mathlib's `MvPolynomial (Fin n) K` for polynomials in *n* variables over *K*. The total degree is `MvPolynomial.totalDegree`, defined as the supremum of the sum of exponents over all monomials in the support.

### 2.3 The Fiber Polynomial

**Definition** (Fiber Polynomial). For *p* ∈ *K*[*x*₀, …, *x*ₙ] and *a* : Fin *n* → *K*, the fiber polynomial is the univariate polynomial obtained by evaluating all coefficient polynomials at *a*:

fiberPoly(*p*, *a*) := Polynomial.map (MvPolynomial.eval *a*) (finSuccEquiv *K* *n* *p*)

**Lemma** (Fiber Evaluation). Polynomial.eval *t* (fiberPoly(*p*, *a*)) = MvPolynomial.eval (Fin.cons *t* *a*) *p*.

## 3. Main Results

### 3.1 Grid Schwartz–Zippel Theorem

**Theorem 3.1** (Grid Schwartz–Zippel). *Let K be a field, S : Finset K, and p ∈ K[x₁, …, xₙ] be nonzero with totalDegree(p) < |S|. Then:*

|{*x* ∈ Grid(*S*, *n*) : eval *x* *p* = 0}| ≤ totalDegree(*p*) · |*S*|^(*n*−1)

**Proof sketch.** By induction on *n*.

**Base case** (*n* = 0): A polynomial in zero variables is a constant. If nonzero, it has no zeros. The grid has one element, so the zero count is 0 ≤ 0 · |*S*|^0 = 0.

**Inductive step** (*n* → *n*+1): Let *g* = finSuccEquiv(*K*, *n*, *p*), a univariate polynomial over the ring of *n*-variable polynomials. Let *d'* = natDegree(*g*) = degreeOf(0, *p*) and *lc* = leadingCoeff(*g*), a nonzero polynomial in *n* variables.

Decompose the zero count via fibers:

|zeros| = Σ_{*a* ∈ Grid(*S*, *n*)} |{*t* ∈ *S* : eval(Fin.cons *t* *a*) *p* = 0}|

For each *a*:
- **Good fiber** (eval *a* *lc* ≠ 0): The fiber polynomial has natDegree = *d'* and is nonzero, so it has at most *d'* zeros in *S* by the univariate root bound.
- **Bad fiber** (eval *a* *lc* = 0): At most |*S*| zeros (trivial).

The number of bad fibers is at most totalDegree(*lc*) · |*S*|^(*n*−1) by the induction hypothesis, since *lc* is a nonzero polynomial with totalDegree(*lc*) ≤ totalDegree(*p*) − *d'* < |*S*|.

Combining:

|zeros| ≤ bad_count · |*S*| + |*S*|^*n* · *d'*
        ≤ (totalDegree(*p*) − *d'*) · |*S*|^(*n*−1) · |*S*| + *d'* · |*S*|^*n*
        = totalDegree(*p*) · |*S*|^*n*  ∎

### 3.2 Theorem A: Uniqueness from Large Agreement

**Theorem 3.2.** *Let p, q ∈ K[x₁, …, xₙ] with totalDegree(p), totalDegree(q) ≤ d < |S|. If:*

|{*x* ∈ Grid(*S*, *n*) : eval *x* *p* = eval *x* *q*}| > *d* · |*S*|^(*n*−1)

*then eval x p = eval x q for all x ∈ Grid(S, n).*

**Proof.** Let *r* = *p* − *q*. Then totalDegree(*r*) ≤ max(totalDegree(*p*), totalDegree(*q*)) ≤ *d*. The agreement set of *p* and *q* equals the zero set of *r* on the grid (since eval *x* *p* = eval *x* *q* iff eval *x* *r* = 0). If *r* ≠ 0, then by Theorem 3.1, |zeros of *r*| ≤ *d* · |*S*|^(*n*−1), contradicting the hypothesis. Hence *r* = 0, and *p* = *q* everywhere. ∎

### 3.3 Theorem B: Uniqueness of Low-Degree Explanation (Corrected)

The natural conjecture is that if two degree-≤*d* polynomials each individually agree with a function *f* on more than *d* · |*S*|^(*n*−1) grid points, they must agree on the entire grid.

**Counterexample.** Over ℚ with *S* = {0, 1, 2}, *n* = 1, *d* = 1:
- *p*(*x*) = *x*, *q*(*x*) = 2 − *x*
- *f*(0) = 2, *f*(1) = 1, *f*(2) = 2
- *p* agrees with *f* at {1, 2}: 2 points > 1 = *d* · |*S*|^0
- *q* agrees with *f* at {0, 1}: 2 points > 1
- But *p*(0) = 0 ≠ 2 = *q*(0)

The issue is that individual agreement of *d* · |*S*|^(*n*−1) does not force sufficient *overlap* between the two agreement sets.

**Theorem 3.3** (Corrected). *Let p, q have totalDegree ≤ d < |S|. If the combined agreement with f exceeds the grid size plus the zero bound:*

|{*x* : eval *x* *p* = *f*(*x*)}| + |{*x* : eval *x* *q* = *f*(*x*)}| > |*S*|^*n* + *d* · |*S*|^(*n*−1)

*then eval x p = eval x q for all x ∈ Grid(S, n).*

**Proof.** By inclusion-exclusion, the overlap *A* ∩ *B* (where *A* is the *p*-agreement set and *B* is the *q*-agreement set) satisfies |*A* ∩ *B*| ≥ |*A*| + |*B*| − |Grid|. The hypothesis gives |*A* ∩ *B*| > *d* · |*S*|^(*n*−1). Since *A* ∩ *B* ⊆ {*x* : eval *x* *p* = eval *x* *q*}, the result follows from Theorem 3.2. ∎

### 3.4 Theorem C: Reed–Muller Distance Bound

**Theorem 3.4.** *Let p, q have totalDegree ≤ d < |S| and suppose p ≠ q on Grid(S, n). Then:*

|{*x* ∈ Grid(*S*, *n*) : eval *x* *p* ≠ eval *x* *q*}| ≥ |*S*|^*n* − *d* · |*S*|^(*n*−1)

**Proof.** The agreement set is contained in the zero set of *r* = *p* − *q*, which has at most *d* · |*S*|^(*n*−1) elements by Theorem 3.1. The disagreement set is the complement, with cardinality ≥ |*S*|^*n* − *d* · |*S*|^(*n*−1). ∎

**Corollary** (Reed–Muller Minimum Distance). The evaluation code RM(*d*, *n*, *S*) has minimum distance |*S*|^(*n*−1) · (|*S*| − *d*).

## 4. Proof Architecture and Lean Formalization

### 4.1 Module Structure

The formalization consists of a single file `Bridges/LowDegreeTesting.lean` with six sections:

1. **Grid infrastructure**: Definition of `Grid`, membership, and cardinality.
2. **Univariate root bound**: A nonzero polynomial has at most natDegree roots in any finite set.
3. **Fiber decomposition**: The `fiberPoly` construction and the zero-count decomposition into a sum over fibers.
4. **Coefficient degree bounds**: Total degree of leading coefficient, nonzero leading coefficient.
5. **Main theorem**: Induction on *n* with explicit base case and inductive step.
6. **Corollaries**: Theorems A, B (corrected), and C.

### 4.2 Key Lemmas

| Lemma | Statement | Role |
|-------|-----------|------|
| `Grid_card` | |Grid(*S*, *n*)| = |*S*|^*n* | Cardinality bookkeeping |
| `univariate_roots_in_finset` | Nonzero poly has ≤ natDegree roots in *S* | Base case engine |
| `eval_fiberPoly` | Fiber eval = cons eval | Fiber-grid correspondence |
| `grid_zero_card_eq_sum_fibers` | Zero count decomposes into fiber sum | Inductive decomposition |
| `coeff_totalDegree_le` | Degree of *j*-th coeff ≤ totalDegree − *j* | Inductive hypothesis applicability |
| `finSuccEquiv_leadingCoeff_ne_zero` | Leading coeff nonzero if poly nonzero | Fiber nonvanishing |
| `natDegree_fiberPoly_le` | Fiber degree = finSuccEquiv degree (good fibers) | Univariate bound applicability |

### 4.3 Axiom Usage

All theorems depend only on `propext`, `Classical.choice`, and `Quot.sound` — the standard axioms of Lean 4's type theory.

## 5. Applications

### 5.1 Polynomial Identity Testing

Given two polynomial expressions, test equality by evaluating at random points from *S^n*. By Theorem 3.1, if the polynomials differ, the probability of detection is ≥ 1 − *d*/|*S*| per evaluation.

### 5.2 Reed–Muller Codes

The evaluation map *p* ↦ (eval *x* *p*)_{*x* ∈ Grid(*S*,*n*)} defines a linear code. Theorem 3.4 shows:
- **Block length**: |*S*|^*n*
- **Minimum distance**: |*S*|^(*n*−1)(|*S*| − *d*)
- **Relative distance**: 1 − *d*/|*S*|
- **Unique decoding radius**: ⌊(|*S*|^(*n*−1)(|*S*| − *d*) − 1)/2⌋

### 5.3 Sum-Check Protocol

The Schwartz–Zippel bound provides soundness for each round of the sum-check protocol. A cheating prover must match an honest polynomial at a random point, which happens with probability ≤ *d*/|*S*| by the univariate case of our theorem.

### 5.4 Self-Correction

Given a noisy oracle *ω* agreeing with a degree-≤*d* polynomial *p* on ≥ (1−δ)|*S*|^*n* grid points (δ < 1−*d*/|*S*|), Theorem 3.2 guarantees *p* is unique. The self-correction algorithm evaluates *ω* at *d*+1 points on a random line through the target point and interpolates.

## 6. Computational Experiments

We implemented all algorithms in Python and verified them numerically:

| Polynomial | n | d | Grid | Zeros | SZ Bound | Distance |
|-----------|---|---|------|-------|----------|----------|
| *x*² (Z/7Z) | 1 | 2 | 7 | 1 | 2 | 6 |
| *xy* (Z/7Z) | 2 | 2 | 49 | 13 | 14 | 36 |
| *x*²+*y*²−1 (Z/7Z) | 2 | 2 | 49 | 8 | 14 | — |
| *x*+*y*+*z* (Z/7Z) | 3 | 1 | 343 | 49 | 49 | 294 |

All zero counts satisfy the Schwartz–Zippel bound. Distances between distinct polynomials exceed the minimum distance in all tested cases.

The self-correction algorithm correctly recovered polynomial values from 10% noise corruption in all tested instances with 30 random line samples.

## 7. Discussion

### 7.1 The Counterexample for Theorem B

The discovery that the individual-agreement version of the uniqueness-of-explanation theorem is false highlights the value of machine-verified mathematics. The statement "if *p* and *q* each agree with *f* on > *d*·|*S*|^(*n*−1) points, they agree everywhere" is plausible and appears in informal treatments, but is false. The corrected version requires combined agreement exceeding |*S*|^*n* + *d*·|*S*|^(*n*−1), which corresponds to the standard unique decoding condition: the sum of Hamming distances from *f* to the two codewords must be less than the minimum distance.

### 7.2 Generality of the Formalization

Our formalization works over arbitrary fields with a `[DecidableEq K]` instance. It does not require the field to be finite, nor does it require *S* to be the entire field. This generality is important for applications where the evaluation domain is a strict subset (e.g., {0, 1} ⊂ *F*_*p* in Boolean circuit verification).

### 7.3 Limitations

The current formalization does not include:
- Probability-theoretic statements (the lemma is combinatorial, not probabilistic)
- Explicit decoding algorithms with verified complexity bounds
- The line-test soundness theorem (a future target)
- List decoding bounds

## 8. Future Work

See FUTURE_DIRECTIONS.md for a detailed roadmap. The five principal next targets are:

1. **Affine-line low-degree test soundness**: Aggregating local line consistency into global polynomial agreement.
2. **Reed–Muller unique decoding**: Constructive decoding within half the minimum distance.
3. **Self-corrector with formal guarantees**: Verified correction from noisy oracles.
4. **Sum-check protocol soundness**: Machine-verified interactive proof soundness.
5. **List decoding bounds**: Bounding the number of close codewords beyond the unique radius.

## 9. References

1. J.T. Schwartz, "Fast probabilistic algorithms for verification of polynomial identities," *J. ACM*, 27(4):701–717, 1980.
2. R. Zippel, "Probabilistic algorithms for sparse polynomials," *EUROSAM '79*, LNCS 72, pp. 216–226, 1979.
3. R.A. DeMillo and R.J. Lipton, "A probabilistic remark on algebraic program testing," *Information Processing Letters*, 7(4):193–195, 1978.
4. S. Arora and B. Barak, *Computational Complexity: A Modern Approach*, Cambridge University Press, 2009.
5. S. Arora and S. Safra, "Probabilistic checking of proofs: A new characterization of NP," *J. ACM*, 45(1):70–122, 1998.
6. C. Lund, L. Fortnow, H. Karloff, and N. Nisan, "Algebraic methods for interactive proof systems," *J. ACM*, 39(4):859–868, 1992.
7. I.S. Reed, "A class of multiple-error-correcting codes and the decoding scheme," *IEEE Trans. Info. Theory*, 4(4):38–49, 1954.
8. The Mathlib Community, *Mathlib4*, https://github.com/leanprover-community/mathlib4, 2024.
