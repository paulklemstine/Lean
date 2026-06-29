# Quantitative Reduction Theory for the Jacobian Conjecture: Nilpotence Detection, Degree Bounds, and Complexity Measures

## Abstract

We establish a suite of formally verified theorems that convert qualitative results in the Jacobian Conjecture ecosystem into quantitative, algorithmically useful statements. Our main contributions are:

1. **Nilpotence from determinant constraints (general dimension):** Over a characteristic-zero field, if det(I + tA) = 1 for all scalars t, then A is nilpotent, with nilpotence index at most n (the matrix size). We prove this via Cayley-Hamilton after showing the characteristic polynomial equals X^n.

2. **Trace vanishing theorem:** Under the same hypothesis, tr(A^k) = 0 for all k ≥ 1, providing a computationally efficient sufficient condition for nilpotence verification.

3. **Composition degree bound:** For polynomial maps, deg(F ∘ G) ≤ deg(F) · deg(G), formalized via the substitution operation bind₁ on multivariate polynomials.

4. **Cayley-Hamilton sharpening for nilpotent matrices:** Over an integral domain, every nilpotent n×n matrix satisfies A^n = 0, providing a sharp index bound.

All results are machine-verified in Lean 4 using the Mathlib library, with no axioms beyond the standard foundations (propext, Classical.choice, Quot.sound).

**Keywords:** Jacobian Conjecture, nilpotent Jacobian, polynomial automorphism, degree bound, Cayley-Hamilton, formal verification, characteristic polynomial, tame automorphism

---

## 1. Introduction

### 1.1 Background

The Jacobian Conjecture, posed by Keller in 1939, asserts that any polynomial map F : k^n → k^n over a field of characteristic zero with det(JF) ∈ k^× is a polynomial automorphism. Despite extensive work, the conjecture remains open for n ≥ 2.

The Bass-Connell-Wright and Yagzhev reductions (1982) showed that it suffices to consider maps of the form F = I + H where H is cubic homogeneous. Under the Keller condition det(I + JH) = 1, the key algebraic question becomes: is the Jacobian matrix JH nilpotent?

### 1.2 Motivation

Prior formal work in this area has focused on existential statements: polynomial automorphisms exist, stable equivalence preserves invertibility, triangular maps are automorphisms. This paper initiates a **quantitative** formal theory, establishing:

- **Numerical bounds** on nilpotence indices and inverse degrees;
- **Algorithmic criteria** for verifying the Keller condition;
- **Complexity measures** for polynomial inversion.

### 1.3 Contributions

Our contributions fall into three categories:

**A. Nilpotence Theory (Section 3).** We formalize the classical result that det(I + tA) = 1 for all t implies A is nilpotent, together with the trace vanishing corollary. The proof proceeds via the characteristic polynomial, showing charpoly(A) = X^n, and then applying Cayley-Hamilton.

**B. Degree Theory (Section 4).** We formalize the composition degree bound for multivariate polynomial substitution, and establish degree properties of elementary and identity maps.

**C. Index Theory (Section 5).** We prove the Cayley-Hamilton sharpening: nilpotent n×n matrices over integral domains satisfy A^n = 0. This provides a computable upper bound on nilpotence indices.

---

## 2. Definitions and Notation

### 2.1 Polynomial Maps

Let K be a commutative ring and n ∈ ℕ. A **polynomial map** in n variables over K is a function F : Fin n → MvPolynomial (Fin n) K, where MvPolynomial σ K denotes the ring of multivariate polynomials over K with variables indexed by σ.

**Composition** of polynomial maps F, G is defined by substitution:
```
polyMapComp F G := fun i => MvPolynomial.bind₁ G (F i)
```

The **total degree** of a polynomial map is:
```
polyMapDegree F := Finset.sup Finset.univ (fun i => (F i).totalDegree)
```

### 2.2 Jacobian Matrix

The **Jacobian matrix** of F is the n×n matrix of polynomial entries:
```
jacobianMatrix F := Matrix.of (fun i j => MvPolynomial.pderiv j (F i))
```

The **Jacobian determinant** is det(jacobianMatrix F).

### 2.3 Nilpotence

A matrix A is **nilpotent** if there exists m ∈ ℕ with A^m = 0. The **nilpotence index** is the minimal such m.

---

## 3. Nilpotence from Determinant Constraints

### 3.1 Main Theorem

**Theorem 3.1** (isNilpotent_of_det_one_add_smul). *Let K be a field of characteristic zero, and let A be an n×n matrix over K. If det(I + tA) = 1 for all t ∈ K, then A is nilpotent.*

**Proof sketch.** The proof proceeds in three steps:

1. **Characteristic polynomial identification.** For nonzero t, we compute:
   ```
   det(tI - A) = t^n · det(I - t⁻¹A) = t^n · det(I + (-t⁻¹)A) = t^n · 1 = t^n
   ```
   Since charpoly(A) and X^n agree on all nonzero elements of K (an infinite set, as K has characteristic zero), they are equal as polynomials by `Polynomial.funext` (or more precisely, by the fact that a nonzero polynomial over an infinite field has only finitely many roots).

2. **Cayley-Hamilton application.** By the Cayley-Hamilton theorem (`Matrix.aeval_self_charpoly`), aeval A (charpoly A) = 0. Substituting charpoly(A) = X^n gives A^n = 0.

3. **Nilpotence witness.** The pair ⟨n, A^n = 0⟩ witnesses IsNilpotent A.

**Complexity:** The determinant test requires O(n³) operations per sample point, and n+1 sample points suffice to determine the polynomial. Total: O(n⁴).

### 3.2 Characteristic Polynomial

**Theorem 3.2** (charpoly_eq_X_pow_of_det_one_add_smul). *Under the hypotheses of Theorem 3.1, charpoly(A) = X^n.*

This is proved as an intermediate step in Theorem 3.1 but stated independently for reusability.

### 3.3 Trace Vanishing

**Theorem 3.3** (trace_pow_eq_zero_of_det_one_add_smul). *Under the hypotheses of Theorem 3.1, tr(A^k) = 0 for all k ≥ 1.*

**Proof sketch.** From Theorem 3.1, A^n = 0. For k ≥ n, A^k = 0 trivially. For 1 ≤ k < n, note that (A^k)^n = A^{kn} = 0 (since kn ≥ n), so A^k is nilpotent. A nilpotent matrix over a field has characteristic polynomial X^n (proved by passing to the algebraic closure and showing all eigenvalues are zero), whence tr(A^k) = -(coefficient of X^{n-1} in charpoly(A^k)) = 0.

### 3.4 2×2 Specialization

**Theorem 3.4** (sq_eq_zero_of_det_one_add_smul_2x2). *For a 2×2 matrix M over a characteristic-zero field, if det(I + tM) = 1 for all t, then M² = 0.*

**Proof.** Direct computation: det(I + tM) = 1 + t·tr(M) + t²·det(M). Setting t = 1 and t = -1 yields tr(M) = 0 and det(M) = 0. By Cayley-Hamilton for 2×2 matrices, M² - tr(M)·M + det(M)·I = 0, giving M² = 0. □

**Theorem 3.5** (Matrix.isNilpotent_of_trace_zero_det_zero). *A 2×2 matrix over a field with trace zero and determinant zero is nilpotent (with index ≤ 2).*

---

## 4. Degree Theory for Polynomial Maps

### 4.1 Composition Degree Bound

**Theorem 4.1** (totalDegree_bind₁_le). *Let p ∈ K[x₁,...,xₙ] and let G : Fin n → K[x₁,...,xₙ] with totalDegree(Gᵢ) ≤ d for all i. Then:*
```
totalDegree(bind₁ G p) ≤ totalDegree(p) · d
```

**Proof sketch.** Write p = Σ_{m ∈ supp(p)} c_m · x^m. After substitution, each monomial term x^m becomes ∏ᵢ Gᵢ^{mᵢ}, which has total degree at most Σᵢ mᵢ · d(Gᵢ) ≤ (Σᵢ mᵢ) · d ≤ totalDegree(p) · d. The total degree of a sum is bounded by the maximum of the summand degrees.

**Corollary 4.2.** *For polynomial maps F, G : K^n → K^n, deg(F ∘ G) ≤ deg(F) · deg(G).*

### 4.2 Identity Map Degree

**Theorem 4.3** (polyMapDegree_id). *Over a nontrivial ring, the identity map in n ≥ 1 variables has degree 1.*

### 4.3 Elementary Map Degree

**Theorem 4.4** (totalDegree_elementaryMap_coord). *An elementary map that adds a polynomial p to coordinate idx has coordinate degree at most max(1, totalDegree(p)).*

### 4.4 Inverse Degree Bound for Tame Automorphisms

As a direct consequence of Theorem 4.1 and the fact that elementary map inverses have the same degree as forward maps:

**Corollary 4.5** (informal). *For a composition F = E₁ ∘ ... ∘ Eₖ of elementary automorphisms:*
```
deg(F⁻¹) ≤ ∏ᵢ deg(Eᵢ)
```

*For a tame automorphism of degree d in n variables, this gives:*
```
deg(F⁻¹) ≤ d^(n-1)
```
*under the assumption that a tame decomposition has at most n-1 nontrivial factors.*

---

## 5. Cayley-Hamilton Sharpening

### 5.1 Nilpotence Index Bound

**Theorem 5.1** (nilpotent_pow_card_eq_zero). *Let R be an integral domain and A an n×n nilpotent matrix over R. Then A^n = 0.*

**Proof sketch.** The key step is showing that charpoly(A) = X^n. We convert A to a linear map via `Matrix.toLin'` and apply `IsNilpotent.charpoly_eq_X_pow_finrank` from Mathlib, which proves this for nilpotent endomorphisms of finite free modules over integral domains. Then Cayley-Hamilton gives A^n = 0.

**Theorem 5.2** (nilpotent_pow_eq_zero_of_le). *Under the same hypotheses, A^k = 0 for all k ≥ n.*

---

## 6. Algorithms

### 6.1 Nilpotence Detection Algorithm

```
Algorithm: NilpotenceDetection(A, n)
Input: n×n matrix A over a field K of char 0
Output: (is_nilpotent, nilpotence_index)

1. For t ∈ {0, 1, 2, ..., n+1}:
     Compute d_t := det(I + tA)
     If |d_t - 1| > ε: return (False, -1)
2. P := A
3. For k = 1 to n:
     If P = 0: return (True, k)
     P := P · A
4. Return (True, n)

Time: O(n⁴)   Space: O(n²)
```

### 6.2 Trace-Based Verification

```
Algorithm: TraceVerification(A, n)
Input: n×n matrix A
Output: True if A passes nilpotence trace test

1. For k = 1 to n:
     Compute A^k (by repeated multiplication)
     If tr(A^k) ≠ 0: return False
2. Return True

Time: O(n⁴)   Space: O(n²)
```

### 6.3 Inverse Degree Estimation

```
Algorithm: InverseDegreeBound(factors)
Input: List of (index, degree) pairs for elementary factors
Output: Upper bound on inverse degree

1. bound := 1
2. For each (idx, deg) in factors:
     bound := bound * deg
3. Return bound

Time: O(k) where k = number of factors   Space: O(1)
```

---

## 7. Computational Experiments

### 7.1 Nilpotence Detection

We tested the nilpotence criterion on matrices of sizes 2 through 5:

| Size | Matrix Type | det(I+tA)=1? | Nilpotent? | Index |
|------|------------|---------------|------------|-------|
| 2×2  | Upper triangular | ✓ | ✓ | 2 |
| 3×3  | Upper triangular | ✓ | ✓ | 3 |
| 4×4  | Block nilpotent | ✓ | ✓ | 2 |
| 5×5  | Shift matrix | ✓ | ✓ | 5 |
| 2×2  | Identity | ✗ | ✗ | — |

All nilpotent matrices correctly passed the determinant criterion, and all non-nilpotent matrices correctly failed.

### 7.2 Trace Vanishing

For a 3×3 strictly upper triangular matrix A:
- tr(A) = 0, tr(A²) = 0, tr(A³) = 0, tr(A⁴) = 0, ...
confirming the trace vanishing theorem.

### 7.3 Degree Bounds

| Composition | dim | Actual deg | Product bound | d^(n-1) bound |
|-------------|-----|-----------|--------------|---------------|
| F(x,y) = (x+y², y) | 2 | 2 | 2 | 2 |
| G(x,y) = (x, y+x³) | 2 | 3 | 3 | 3 |
| F∘G | 2 | 6 | 6 | — |

The composition F∘G achieves the degree bound deg(F)·deg(G) = 2·3 = 6 exactly.

---

## 8. Discussion

### 8.1 Significance

Our results formalize three key aspects of the Jacobian Conjecture ecosystem in a quantitative, algorithmically useful form:

1. **Detection:** The nilpotence theorem converts the Keller condition into a finite linear-algebraic test.
2. **Complexity:** The degree bound provides certified upper bounds on inverse map complexity.
3. **Sharpness:** The Cayley-Hamilton result gives optimal nilpotence index bounds.

### 8.2 Limitations

- The tame inverse degree bound d^(n-1) is currently a conjecture based on structural arguments; its formal proof requires additional infrastructure for tame decompositions and normalization.
- The nilpotence theorem requires characteristic zero; extensions to positive characteristic require different techniques.
- The composition degree bound is sharp for worst-case inputs but may be improvable for specific classes (e.g., triangular maps).

### 8.3 Comparison with Prior Work

The nilpotence result for cubic homogeneous Keller maps is classical (attributed to various authors including Bass-Connell-Wright, 1982). Our contribution is the formal verification in a proof assistant and the formulation as a general parametric determinant criterion independent of the polynomial map context.

---

## 9. Future Work

1. **Full tame inverse degree bound:** Formalize the d^(n-1) bound by proving that tame decompositions have at most n-1 degree-contributing factors.

2. **Quantitative Drużkowski reduction:** Formalize the Bass-Connell-Wright reduction with explicit dimension accounting, proving that cubic Keller maps stably reduce to Drużkowski form in dimension ≤ 2n.

3. **Newton identity formalization:** Relate the trace vanishing criterion to the full Newton identity apparatus, enabling purely trace-based nilpotence proofs.

4. **Wild automorphism detection:** Use the degree bounds as wildness certificates — maps whose inverse degree exceeds the tame bound must be wild.

5. **Executable verification:** Convert the nilpotence and trace criteria into certified computational procedures in Lean's `#eval` system.

---

## 10. References

1. H. Bass, E. Connell, D. Wright, "The Jacobian Conjecture: Reduction of Degree and Formal Expansion of the Inverse," *Bull. AMS* 7 (1982), 287–330.

2. L. Drużkowski, "An Effective Approach to Keller's Jacobian Conjecture," *Math. Ann.* 264 (1983), 303–313.

3. A. van den Essen, *Polynomial Automorphisms and the Jacobian Conjecture*, Progress in Mathematics 190, Birkhäuser (2000).

4. O.-H. Keller, "Ganze Cremona-Transformationen," *Monatshefte für Mathematik und Physik* 47 (1939), 299–306.

5. The Mathlib Community, "Mathlib: A Unified Library of Mathematics Formalized," *Journal of Automated Reasoning* 68 (2024).

---

## Appendix: Formal Verification Details

All theorems were verified in Lean 4 (version 4.28.0) with Mathlib. The axiom dependency for all results is limited to:
- `propext` (propositional extensionality)
- `Classical.choice` (axiom of choice)
- `Quot.sound` (quotient soundness)

No `sorry` statements remain in the final proofs. The full source code is available in `Algebra/Jacobian/NilpotenceTheory.lean` and `Algebra/Jacobian/DegreeTheory.lean`.
