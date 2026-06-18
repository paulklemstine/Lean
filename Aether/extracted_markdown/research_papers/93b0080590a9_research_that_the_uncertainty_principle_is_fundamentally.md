# MDS Matrices and the Algebraic Uncertainty Principle: A Machine-Verified Characterization

## Abstract

We prove that the Maximum Distance Separable (MDS) property of a matrix over a field is equivalent to the strongest form of the discrete additive uncertainty principle: for every nonzero vector *f* in *F*ⁿ, |supp(*f*)| + |supp(*Mf*)| ≥ *n* + 1. This characterization unifies the Fourier uncertainty principle from harmonic analysis, the Singleton bound from coding theory, and the submatrix invertibility condition from linear algebra under a single algebraic framework. All main results have been formally verified in Lean 4 with the Mathlib library, yielding machine-checked proofs of both directions of the equivalence and several structural consequences.

**Keywords:** MDS matrices, uncertainty principle, Singleton bound, Reed-Solomon codes, formal verification, polynomial root bound

---

## 1. Introduction

The uncertainty principle, in its various incarnations, asserts that a function cannot be simultaneously concentrated in two dual representations. In harmonic analysis, this takes the form |supp(*f*)| · |supp(*f̂*)| ≥ |*G*| for a nonzero function *f* on a finite abelian group *G* with Fourier transform *f̂* (Donoho–Stark [1]). The stronger additive form |supp(*f*)| + |supp(*f̂*)| ≥ |*G*| + 1, proved by Tao [2] for cyclic groups of prime order, reveals a deeper algebraic structure.

In coding theory, the Singleton bound states that a linear code of length *n* and dimension *k* over a finite field has minimum distance at most *n* − *k* + 1. Codes achieving this bound are called Maximum Distance Separable (MDS). Reed-Solomon codes are the canonical examples, and their MDS property follows from the polynomial root bound.

This paper establishes the precise algebraic equivalence between these two phenomena:

**Main Theorem.** *A matrix M ∈ F^{n×n} satisfies |supp(f)| + |supp(Mf)| ≥ n + 1 for every nonzero f ∈ Fⁿ if and only if every square submatrix of M has nonzero determinant (the MDS property).*

### 1.1 Contributions

1. **Formal definition** of MDS matrices via submatrix determinants, suitable for mechanized reasoning.
2. **Machine-verified proof** of both directions of the MDS-uncertainty equivalence in Lean 4.
3. **Structural theorems**: MDS implies invertibility, MDS is preserved under transposition, and the Singleton bound is tight.
4. **Novel definition**: The *uncertainty profile* of a matrix, a certified lower bound on support sums.
5. **Cross-domain bridge**: Explicit connections between harmonic analysis, coding theory, and linear algebra.

---

## 2. Definitions

### 2.1 Vector Support

**Definition 2.1** (Support). For a vector *v* : Fin *n* → *F*, the *support* of *v* is

  supp(*v*) = { *i* ∈ Fin *n* : *v*(*i*) ≠ 0 }

and the *zero set* is its complement:

  zeros(*v*) = { *i* ∈ Fin *n* : *v*(*i*) = 0 }

**Lemma 2.2.** |supp(*v*)| + |zeros(*v*)| = *n* for all *v* : Fin *n* → *F*.

### 2.2 MDS Matrices

**Definition 2.3** (MDS Matrix). A matrix *M* ∈ *F*^{*n*×*n*} is *Maximum Distance Separable* (MDS) if for every *k* ≥ 0 and every pair of injections *r*, *c* : Fin *k* ↪ Fin *n*, the submatrix *M*[*r*, *c*] has nonzero determinant:

  det(*M*.submatrix *r* *c*) ≠ 0

This definition encompasses all sizes *k* from 0 to *n*. For *k* = 0, the condition is trivially satisfied (the determinant of the empty matrix is 1). For *k* = *n*, it implies that *M* itself is invertible.

### 2.3 Uncertainty Bound

**Definition 2.4** (Additive Uncertainty). A matrix *M* ∈ *F*^{*n*×*n*} *satisfies the uncertainty bound* *b* if for every nonzero *f* ∈ *F*ⁿ:

  |supp(*f*)| + |supp(*Mf*)| ≥ *b*

### 2.4 Uncertainty Profile (Novel)

**Definition 2.5** (Uncertainty Profile). An *uncertainty profile* for a matrix *M* ∈ *F*^{*n*×*n*} consists of:
- The matrix *M*
- A certified lower bound *b* ∈ ℕ
- A proof that the uncertainty bound *b* holds for *M*

This structure packages the matrix with its verified uncertainty guarantee, enabling compositional reasoning about transforms.

---

## 3. Main Results

### 3.1 Forward Direction: MDS Implies Uncertainty

**Theorem 3.1** (mds_implies_uncertainty). *If M is MDS and f ≠ 0, then |supp(f)| + |supp(Mf)| ≥ n + 1.*

*Proof sketch.* Suppose for contradiction that |supp(*f*)| + |supp(*Mf*)| ≤ *n*. Let *s* = |supp(*f*)|. Then |zeros(*Mf*)| = *n* − |supp(*Mf*)| ≥ *s*.

Select *s* indices from zeros(*Mf*) to form an injection *r* : Fin *s* ↪ Fin *n*, and let *c* : Fin *s* ↪ Fin *n* parametrize supp(*f*).

**Key lemma** (submatrix_mulVec_of_support): Since *f* vanishes outside range(*c*), we have:

  (*M*.submatrix *r* *c*).mulVec (*f* ∘ *c*)(*i*) = (*Mf*)(*r*(*i*)) = 0

for all *i*, where the last equality holds because *r*(*i*) ∈ zeros(*Mf*).

By the MDS property, det(*M*.submatrix *r* *c*) ≠ 0, so by the kernel characterization of invertible matrices, *f* ∘ *c* = 0. But *c* parametrizes supp(*f*), so *f* ∘ *c* ≠ 0 — contradiction. ∎

### 3.2 Converse Direction: Non-MDS Implies a Violator

**Theorem 3.2** (not_mds_implies_violator). *If M is not MDS, there exists f ≠ 0 with |supp(f)| + |supp(Mf)| ≤ n.*

*Proof sketch.* Since *M* is not MDS, there exist *k*, *r*, *c* with det(*M*.submatrix *r* *c*) = 0. By the existence of kernel vectors for singular matrices, there exists nonzero *v* with (*M*.submatrix *r* *c*).mulVec *v* = 0.

Define *f* : Fin *n* → *F* by extending *v* to be zero outside range(*c*): *f*(*j*) = *v*(*c*⁻¹(*j*)) if *j* ∈ range(*c*), else 0.

Then:
- *f* ≠ 0 (since *v* ≠ 0 and *c* is injective)
- |supp(*f*)| ≤ *k* (supported on range(*c*))
- (*Mf*) vanishes on range(*r*) (by the key lemma), so |zeros(*Mf*)| ≥ *k*
- Therefore |supp(*Mf*)| ≤ *n* − *k*, giving |supp(*f*)| + |supp(*Mf*)| ≤ *n*. ∎

### 3.3 The Full Characterization

**Theorem 3.3** (mds_iff_uncertainty). *M is MDS ⟺ M satisfies the uncertainty bound n + 1.*

*Proof.* Combine Theorems 3.1 and 3.2. The forward direction is Theorem 3.1. For the reverse, suppose *M* satisfies the bound but is not MDS. By Theorem 3.2, there exists a violating vector, contradicting the bound. ∎

### 3.4 Structural Consequences

**Theorem 3.4** (mds_invertible). *If M is MDS, then det(M) ≠ 0.*

*Proof.* Take *k* = *n* and the identity embeddings in the MDS definition. ∎

**Theorem 3.5** (mds_transpose). *If M is MDS, then Mᵀ is MDS.*

*Proof.* Use the identity (*Mᵀ*).submatrix *r* *c* = (*M*.submatrix *c* *r*)ᵀ and det(*A*ᵀ) = det(*A*). ∎

**Theorem 3.6** (singleton_bound). *For any invertible M with n ≥ 1, there exists f ≠ 0 with |supp(f)| + |supp(Mf)| ≤ n + 1.*

*Proof.* Take *f* = *e*₀ (the first standard basis vector). Then |supp(*f*)| = 1 and |supp(*Mf*)| ≤ *n*. ∎

---

## 4. The Polynomial Root Bound Connection

The root bound for polynomials — a nonzero polynomial of degree *d* over a field has at most *d* roots — is the algebraic engine that makes specific transforms MDS. The existing catalog includes:

- `card_roots_le_natDegree_filter`: Root count bound in filter form
- `reed_solomon_min_distance`: Reed-Solomon minimum distance from the root bound
- `uncertainty_principle_finite_abelian`: The multiplicative uncertainty principle for finite abelian groups via Parseval's identity

Our MDS-uncertainty characterization provides a common algebraic framework that subsumes the root-bound approach (which shows specific matrices are MDS) and the Fourier-analytic approach (which proves uncertainty via inner products).

### 4.1 Chain of Implications

The full logical chain is:

1. **Root bound** (algebraic): deg(*p*) ≤ *d* ⟹ at most *d* roots
2. **Vandermonde invertibility**: Square Vandermonde matrices with distinct points are invertible
3. **MDS property**: Vandermonde matrices with distinct nonzero points are MDS (over sufficiently large fields)
4. **Uncertainty**: MDS ⟺ |supp(*f*)| + |supp(*Mf*)| ≥ *n* + 1
5. **Fourier uncertainty**: The DFT matrix over ℤ/pℤ is MDS ⟹ uncertainty for cyclic groups of prime order

Each step is a clean algebraic fact, and together they form a complete explanation of discrete uncertainty.

---

## 5. Algorithms

### 5.1 MDS Verification

**Algorithm.** To verify that an *n* × *n* matrix *M* over a finite field *F*_*q* is MDS:

```
Input: M ∈ F_q^{n×n}
For each k from 1 to n:
  For each k-element subset R ⊆ {0,...,n-1}:
    For each k-element subset C ⊆ {0,...,n-1}:
      Compute det(M[R,C])
      If det = 0: return "NOT MDS"
Return "MDS"
```

**Complexity:** O(Σ_k C(n,k)² · k³) = O(4ⁿ · n³) field operations.

### 5.2 Uncertainty Violation Search

**Algorithm.** Given a non-MDS matrix, find a violating vector:

```
Input: M ∈ F_q^{n×n} (not MDS)
Find k, R, C with det(M[R,C]) = 0
Compute v ∈ ker(M[R,C]), v ≠ 0
Extend v by zeros: f(j) = v(c⁻¹(j)) if j ∈ C, else 0
Return f
```

---

## 6. Discussion

### 6.1 The MDS Conjecture

Over a finite field *F*_*q*, the MDS conjecture predicts that an MDS matrix of size *n* × *n* can exist only if *n* ≤ *q* + 1 (with an exception for *q* even, where *n* ≤ *q* + 2 is allowed for certain constructions). This remains one of the central open problems in combinatorial coding theory.

Our characterization translates this conjecture into a statement about uncertainty: *over F_q, the strongest uncertainty bound |supp(f)| + |supp(Mf)| ≥ n + 1 can be achieved only for n ≤ q + 1.* This connects a coding-theoretic conjecture to a signal-processing question.

### 6.2 Connections to Existing Work

Our formal proof of the MDS-uncertainty equivalence complements the existing catalog:

- **Fourier analysis** (`Algebra/FourierAnalysis/Theorems.lean`): The multiplicative uncertainty |supp(*f*)| · |supp(*f̂*)| ≥ |*G*| was proved via Parseval's identity. Our additive bound is stronger and uses a different technique (submatrix determinants rather than inner products).

- **Root bound** (`Algebra/RootBound.lean`): The polynomial root bound and Reed-Solomon distance were proved. Our MDS framework provides the natural algebraic context for these results.

### 6.3 Limitations

The formal proof handles the finite-dimensional case over arbitrary fields. Extensions to infinite-dimensional settings (continuous Fourier transform, Hilbert space uncertainty) require different techniques and are not addressed here.

---

## 7. Future Work

1. **MDS Conjecture Formalization**: Formalize the statement and known partial results of the MDS conjecture over finite fields.
2. **Vandermonde MDS**: Prove that Vandermonde matrices with distinct nonzero evaluation points are MDS over fields of characteristic 0.
3. **Entropic Uncertainty**: Extend the support-based uncertainty to entropy-based measures, connecting to quantum information theory.
4. **Product Constructions**: Characterize which tensor products and Kronecker products of MDS matrices remain MDS.

---

## References

[1] Donoho, D.L. and Stark, P.B., "Uncertainty principles and signal recovery," SIAM J. Appl. Math. 49(3), 906-931, 1989.

[2] Tao, T., "An uncertainty principle for cyclic groups of prime order," Math. Res. Lett. 12(1), 121-127, 2005.

[3] MacWilliams, F.J. and Sloane, N.J.A., *The Theory of Error-Correcting Codes*, North-Holland, 1977.

[4] Segre, B., "Curve razionali normali e k-archi negli spazi finiti," Ann. Mat. Pura Appl. 39, 357-379, 1955.

[5] Ball, S., "On sets of vectors of a finite vector space in which every subset of basis size is a basis," J. Eur. Math. Soc. 14(3), 733-748, 2012.
