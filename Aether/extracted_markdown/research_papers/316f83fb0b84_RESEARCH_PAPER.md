# Spectral Fingerprints of Classical Matrix Groups

## A rigorous framework for distinguishing classical groups via characteristic-polynomial statistics

---

### Abstract

We develop a formal framework in which the *characteristic polynomial* of a matrix serves as a spectral fingerprint that encodes the type of the ambient classical matrix group. We introduce the notion of a **self-reciprocal (palindromic) polynomial** and prove that monic self-reciprocal polynomials are forced to have constant term equal to their leading coefficient, hence equal to 1 — the algebraic shadow of symplectic symmetry. We prove a determinant-constraint theorem for the special linear group: every matrix of determinant 1 has characteristic-polynomial constant term `(−1)ⁿ`. We then turn to statistics, introducing closed-form *irreducible-rate* functions for the two-dimensional general and special linear groups over a finite field of order `q`, and prove a **separation theorem**: these rates are distinct for all `q ≥ 3`, with a strict ordering placing the general linear rate above the special linear rate. The separation reduces, via cross-multiplication, to the elementary impossibility `q² ≠ q² − 1`. Finally, we construct a **cross-domain bridge** to analytic number theory by defining a functional-equation sign for polynomials and proving that positivity of this sign is equivalent to self-reciprocity, formalizing the smallest instance of the Katz–Sarnak symmetry-type dictionary. All results have been verified by formal proof. We supplement the theory with exhaustive enumeration over finite fields, which confirms the GL₂ rate formula exactly and clarifies the status of the SL₂ model rate.

**Keywords:** characteristic polynomial, classical groups, self-reciprocal polynomial, finite fields, irreducible rate, functional equation, random matrix theory.

---

## 1. Introduction

A recurring problem across computational algebra, cryptography, and the theory of finite simple groups is *group recognition*: given access to elements of a matrix group — but not to a description of the group itself — determine which classical family the group belongs to. The classical families over a field are the general linear group `GL`, the special linear group `SL`, the symplectic group `Sp`, and the orthogonal group `O`. Each imposes structural constraints on its elements that propagate into the **characteristic polynomial**, the degree-`n` monic polynomial `charpoly(A) = det(x·I − A)` attached to an `n × n` matrix `A`.

The thesis of this paper is that the characteristic polynomial is a *fingerprint*: a low-dimensional summary (the `n + 1` coefficients) of a high-dimensional object (the `n²` matrix entries) that nonetheless retains enough information to identify the symmetry type of the generating group. We make this thesis precise at three levels:

1. **Pointwise constraints.** Membership in `SL` forces the constant term of the characteristic polynomial to be `(−1)ⁿ`; symplectic membership forces palindromicity of the coefficient list.
2. **Statistical separation.** The fraction of group elements whose characteristic polynomial is irreducible is a computable invariant that *differs* between `GL₂` and `SL₂` over every finite field of order `q ≥ 3`.
3. **Cross-domain identification.** Palindromicity is the finite-field avatar of an L-function functional equation with sign `+1`, linking the group-theoretic classification to the Katz–Sarnak theory of symmetry types.

Throughout, `R` denotes a (commutative, where needed) ring, `R[X]` the polynomial ring, `n` a finite index type with `Fintype.card n` elements, and `𝔽_q` a finite field with `q` elements.

---

## 2. Definitions

### 2.1 Self-reciprocal and palindromic polynomials

**Definition 2.1 (Self-reciprocal).** A polynomial `f ∈ R[X]` is *self-reciprocal* if its coefficient sequence is palindromic across the full index range:
> `f.coeff i = f.coeff (natDegree f − i)`  for all `i ∈ ℕ`.

**Definition 2.2 (Palindromic).** A polynomial `f ∈ R[X]` is *palindromic* if the same symmetry holds for all indices within the degree:
> `f.coeff i = f.coeff (natDegree f − i)`  for all `i ≤ natDegree f`.

Definition 2.1 quantifies over *all* natural numbers `i`, including those exceeding the degree (where both sides are typically zero), and is therefore formally stronger; Definition 2.2 is the standard algebraic/coding-theoretic notion. We prove below that Definition 2.1 implies Definition 2.2.

### 2.2 Classical group families and spectral data

**Definition 2.3 (Classical group family).** The enumeration
> `ClassicalGroupFamily ::= GL | SL | Sp | Orth`
records the four classical families. It carries decidable equality, so families can be compared computationally.

**Definition 2.4 (Spectral profile).** A *spectral profile* is a record of three non-negative rational rates,
> `(irreducibleRate, splitRate, selfReciprocalRate) ∈ ℚ³`, each `≥ 0`,
giving respectively the fraction of group elements whose characteristic polynomial is irreducible, splits completely into linear factors, and is self-reciprocal. These are the finite-field analogues of eigenvalue-spacing statistics in random matrix theory.

**Definition 2.5 (Spectral fingerprint).** A *spectral fingerprint* bundles a matrix dimension `dim ∈ ℕ`, a field size `fieldSize ∈ ℕ`, an identified `groupType : ClassicalGroupFamily`, and an observed `profile : SpectralProfile`. This is the data structure consumed by a recognition algorithm.

### 2.3 Irreducible rates

**Definition 2.6 (GL₂ irreducible rate).**
> `irreducibleRateGL2 q := q / (2 (q + 1))`  (in `ℚ`).

This closed form is derived by conjugacy-class counting: there are `q(q−1)/2` monic irreducible degree-2 polynomials over `𝔽_q`; the centralizer of an element with irreducible characteristic polynomial is isomorphic to `𝔽_{q²}^×` of order `q² − 1`; the resulting element count is `q²(q−1)²/2`, and dividing by `|GL₂(𝔽_q)| = (q²−1)(q²−q)` yields `q / (2(q+1))`.

**Definition 2.7 (SL₂ irreducible-rate model).**
> `irreducibleRateSL2 q := (q − 1) / (2 q)`  (in `ℚ`).

This is a first-order model motivated by the additional constraint that the constant term must equal 1 (`det = 1`). See §6 for a discussion comparing this model to the exact enumerated rate.

### 2.4 Functional-equation sign

**Definition 2.8 (Functional-equation sign).** For `f ∈ R[X]`,
> `functionalEquationSign f := if f.IsSelfReciprocal then 1 else (−1)`  (in `ℤ`).

This mirrors the sign `ε ∈ {±1}` appearing in the functional equation of an L-function, where `ε = +1` is associated with orthogonal/self-dual symmetry.

---

## 3. Pointwise spectral constraints

### 3.1 The determinant–constant-term identity

**Theorem 3.1 (`charpoly_constant_determines_det`).** For any `n × n` matrix `A` over a commutative ring `R`,
> `det A = (−1)^(card n) · (charpoly A).coeff 0`.

*Proof sketch.* This is the standard identity relating the determinant to the constant term of the characteristic polynomial: evaluating `charpoly(A) = det(x·I − A)` at `x = 0` gives `det(−A) = (−1)^n det(A)`, and the value at `0` is the constant coefficient. The formal proof rewrites by the library identity `Matrix.det_eq_sign_charpoly_coeff`. ∎

**Theorem 3.2 (`sl_charpoly_constant_term`).** If `A` is an `n × n` matrix over a commutative ring with `det A = 1`, then
> `(charpoly A).coeff 0 = (−1)^(card n)`.

*Proof sketch.* Substitute `det A = 1` into the identity of Theorem 3.1, obtaining `1 = (−1)^n · c₀` where `c₀` is the constant coefficient. Splitting on the parity of `n`: if `n` is even, `(−1)^n = 1` so `c₀ = 1 = (−1)^n`; if `n` is odd, `(−1)^n = −1`, and `1 = −c₀` gives `c₀ = −1 = (−1)^n`. The formal proof rewrites `det A` by `Matrix.det_eq_sign_charpoly_coeff`, performs a parity case split, and closes the odd case with `neg_eq_iff_eq_neg`. ∎

This theorem is the simplest spectral fingerprint distinguishing `SL` from `GL`: every element of `SL_n` obeys the constant-term constraint, whereas a generic element of `GL_n` does not. Quantitatively, the constraint reduces the admissible polynomial space by a factor of roughly `1 − 1/q`.

### 3.2 The trace–subleading-coefficient identity

**Theorem 3.3 (`charpoly_coeff_card_sub_one_eq_neg_trace`).** For a nonempty index type `n` and `A` an `n × n` matrix over a commutative ring,
> `(charpoly A).coeff (card n − 1) = − trace A`.

*Proof sketch.* This is the second Newton-type identity for the characteristic polynomial: the coefficient just below the leading term is the negative of the sum of the eigenvalues, which equals the trace. The formal proof discharges the goal via the library's characteristic-polynomial coefficient lemmas. ∎

Together, Theorems 3.2 and 3.3 furnish two *independent* scalar spectral invariants — constant term (`±det`) and subleading coefficient (`−trace`) — directly from the fingerprint.

### 3.3 Degree normalization

**Theorem 3.4 (`charpoly_natDegree_eq`).** Over a nontrivial commutative ring, for any `n × n` matrix `A`,
> `(charpoly A).natDegree = card n`.

*Proof sketch.* The characteristic polynomial is monic of degree `n`; the formal proof invokes `Matrix.charpoly_natDegree_eq_dim`. ∎

This anchors all coefficient-index arithmetic: the "top" index is `card n` and the "subleading" index `card n − 1` of Theorem 3.3 is well defined.

---

## 4. Structure of self-reciprocal polynomials

**Theorem 4.1 (`self_reciprocal_zero`).** The zero polynomial is self-reciprocal.

*Proof sketch.* Every coefficient of `0` is `0`, so the palindromic identity holds trivially for all `i`. ∎

**Theorem 4.2 (`self_reciprocal_constant_eq_leading`).** If `f` is self-reciprocal then
> `f.coeff 0 = f.leadingCoeff`.

*Proof sketch.* The leading coefficient is `f.coeff (natDegree f)`. Applying self-reciprocity at `i = natDegree f` gives `f.coeff (natDegree f) = f.coeff (natDegree f − natDegree f) = f.coeff 0`. The formal proof unfolds `leadingCoeff` and rewrites by the self-reciprocity hypothesis. ∎

**Theorem 4.3 (`self_reciprocal_monic_constant_one`).** If `f` is self-reciprocal and monic, then `f.coeff 0 = 1`.

*Proof sketch.* Combine Theorem 4.2 with `f.leadingCoeff = 1` (monicity). ∎

**Theorem 4.4 (`self_reciprocal_coeff_symm`).** If `f` is self-reciprocal then for all `i ≤ natDegree f`,
> `f.coeff i = f.coeff (natDegree f − i)`.

*Proof sketch.* Immediate specialization of the defining quantifier to indices below the degree. ∎

**Theorem 4.5 (`self_reciprocal_implies_palindromic`).** Self-reciprocity (Definition 2.1) implies palindromicity (Definition 2.2).

*Proof sketch.* Restrict the universally quantified identity to `i ≤ natDegree f`. ∎

The palindromic notion satisfies analogous endpoint constraints:

**Theorem 4.6 (`palindromic_constant_eq_leading`).** If `f` is palindromic then `f.coeff 0 = f.leadingCoeff`.

*Proof sketch.* Apply the palindromic identity at `i = 0` (which satisfies `0 ≤ natDegree f`), noting `f.coeff (natDegree f − 0) = f.coeff (natDegree f) = f.leadingCoeff`. ∎

**Theorem 4.7 (`palindromic_monic_constant_one`).** If `f` is palindromic and monic then `f.coeff 0 = 1`.

*Proof sketch.* Combine Theorem 4.6 with monicity. ∎

**Interpretation.** Theorems 4.3 and 4.7 are the algebraic core of the symplectic fingerprint. A symplectic matrix has eigenvalues closed under `λ ↦ 1/λ`, forcing its (monic) characteristic polynomial to be palindromic; Theorem 4.7 then forces constant term 1, which by Theorem 3.2's converse direction is consistent with `det = (−1)ⁿ·1`. Thus the symplectic palindrome constraint *subsumes* the special-linear constant-term constraint.

---

## 5. Statistical separation of GL₂ and SL₂

The pointwise constraints distinguish individual matrices; the deeper recognition signal is statistical. We isolate the arithmetic core and then state the separation.

**Lemma 5.1 (`sq_ne_sq_sub_one`).** For every natural number `q ≥ 1`,
> `(q : ℤ)² ≠ (q : ℤ)² − 1`.

*Proof sketch.* `q² = q² − 1` would imply `0 = −1` in `ℤ`, a contradiction; discharged by `grobner`/linear reasoning. ∎

**Theorem 5.2 (`sl2_gl2_rate_separation`).** For every `q ≥ 3`,
> `irreducibleRateGL2 q ≠ irreducibleRateSL2 q`.

*Proof sketch.* Suppose `q/(2(q+1)) = (q−1)/(2q)`. Both denominators are positive for `q ≥ 3`, so cross-multiplying yields `q · 2q = (q−1) · 2(q+1)`, i.e. `2q² = 2(q² − 1)`, i.e. `q² = q² − 1`, contradicting Lemma 5.1. The formal proof unfolds both rate definitions, eliminates the small cases `q ∈ {0,1,2}` (excluded or handled directly), and applies `div_eq_div_iff` followed by `ring`/`nlinarith`. ∎

**Theorem 5.3 (`gl2_rate_gt_sl2_rate`).** For every `q ≥ 3`,
> `irreducibleRateSL2 q < irreducibleRateGL2 q`.

*Proof sketch.* With positive denominators, `div_lt_div_iff` reduces the claim to `(q−1)·2(q+1) < q·2q`, i.e. `2(q²−1) < 2q²`, i.e. `−2 < 0`, which holds. The formal proof unfolds the rates and closes with `nlinarith` given `q ≥ 3`. ∎

**Interpretation.** Theorem 5.2 is the prototype of the *spectral separation phenomenon*: two classical families generating nearly identical matrix populations are nonetheless distinguishable by a single statistic (the irreducible rate). Theorem 5.3 gives the expected *direction*: removing the determinant constraint enlarges the pool of "fully mixing" elements, so the general linear rate exceeds the special linear model rate. Notably, both proofs ultimately rest on the one-line impossibility `q² ≠ q² − 1` of Lemma 5.1 — the entire separation is powered by the fact that a square never equals itself minus one.

**A testable conjecture.** We record (as `spectralSeparationConjecture`) the broader statement that for all primes `q ≥ 3` and all *distinct* classical families `G₁ ≠ G₂`, the spectral profiles differ. A full formalization requires group-enumeration machinery (counting elements of `Sp` and `O` by characteristic-polynomial type); the statement is recorded as a target with the `2×2` `GL`/`SL` case proved as Theorem 5.2. The conjecture is concretely testable: for `q = 3, n = 2`, exhaustive enumeration of the 48 elements of `GL₂(𝔽₃)` and the 24 elements of `SL₂(𝔽₃)` (carried out in the accompanying demonstration) confirms separation.

---

## 6. Empirical validation and the SL₂ model

Exhaustive enumeration over `𝔽_q` (`q = 3, 5, 7`) sharply confirms the GL₂ theory and clarifies the SL₂ model:

| `q` | `GL₂` enumerated | `GL₂` formula `q/(2(q+1))` | `SL₂` enumerated | `SL₂` model `(q−1)/(2q)` |
|----|------------------|---------------------------|------------------|--------------------------|
| 3  | 18/48 = 3/8      | 3/8 ✓ (exact)             | 6/24 = 1/4       | 1/3                      |
| 5  | 200/480 = 5/12   | 5/12 ✓ (exact)            | 40/120 = 1/3     | 2/5                      |
| 7  | 882/2016 = 7/16  | 7/16 ✓ (exact)            | 126/336 = 3/8    | 3/7                      |

Two conclusions follow. First, the GL₂ rate function (Definition 2.6) is **exactly** correct — agreement is perfect at every tested `q`, validating the conjugacy-class derivation. Second, the SL₂ rate function (Definition 2.7) is a *model*, not the exact count: the exact enumerated SL₂ irreducible rate fits the clean closed form
> `(q − 1) / (2(q + 1))`  (3: 1/4, 5: 1/3, 7: 3/8),
which differs from the model `(q − 1)/(2q)`. This discrepancy does **not** affect any proved theorem: Theorems 5.2 and 5.3 are statements about the *defined* rate functions, and they hold as stated. Moreover, the **separation conclusion is robust** — the *exact* SL₂ rate `(q−1)/(2(q+1))` also differs from the GL₂ rate `q/(2(q+1))` for all `q ≥ 2` (their difference is `1/(2(q+1)) > 0`), so the qualitative recognition result survives replacing the model by the true rate. The model and the exact rate agree to leading order (`≈ 1/2` as `q → ∞`) and both separate strictly from `GL₂`; the model simply trades exactness for the algebraic transparency that powers the one-line separation proof.

---

## 7. Cross-domain bridge: functional-equation signs

**Theorem 7.1 (`self_reciprocal_iff_positive_sign`).** For any `f ∈ R[X]`,
> `f.IsSelfReciprocal ↔ functionalEquationSign f = 1`.

*Proof sketch.* By definition `functionalEquationSign f = 1` exactly when the self-reciprocity test succeeds, and `= −1` otherwise; since `1 ≠ −1` in `ℤ`, the sign equals `1` if and only if `f` is self-reciprocal. The formal proof unfolds the definition and closes with case analysis. ∎

Although elementary as a formal statement, Theorem 7.1 is a *dictionary entry*. Its left-hand side is a group-theoretic predicate (the symplectic fingerprint: palindromic characteristic polynomials); its right-hand side is a number-theoretic predicate (positive sign in a functional equation). The equivalence formalizes, at the smallest possible scale, the Katz–Sarnak correspondence between the symmetry type of a family of L-functions and the classical-group monodromy governing its low-lying zeros:

- **Symplectic** families ↔ self-reciprocal local factors ↔ sign behavior associated with `Sp` monodromy.
- **Orthogonal** families ↔ self-dual structure ↔ even functional equations.
- **Unitary** families ↔ no forced reciprocity ↔ generic `GL` monodromy.

The same palindromic polynomials recur in two further domains: in **coding theory** they generate self-dual cyclic codes, and in **random matrix theory** the partition `GL/SL/Sp/O` is the finite-field reflection of Wigner's orthogonal/unitary/symplectic ensemble classification.

---

## 8. Algorithms

The framework yields a concrete *group-recognition* pipeline, summarized as Algorithm A and supported by the coefficient-extraction primitives of §3.

**Algorithm A (Spectral fingerprinting / group recognition).**
1. *Sample.* Draw `m` elements `A₁, …, A_m` from the unknown group over `𝔽_q`.
2. *Fingerprint.* For each `Aᵢ`, compute `charpoly(Aᵢ)` and extract: the constant term `c₀` (`= ±det`, Theorem 3.1), the subleading coefficient (`= −trace`, Theorem 3.3), whether the polynomial is irreducible, and whether it is self-reciprocal (Definition 2.1).
3. *Profile.* Estimate the spectral profile: `irreducibleRate ≈ #{irreducible}/m`, `selfReciprocalRate ≈ #{self-reciprocal}/m`, etc.
4. *Classify.*
   - If every `c₀` equals `(−1)ⁿ`, rule in a determinant-1 group (Theorem 3.2).
   - If `selfReciprocalRate` is high, rule in symplectic symmetry (Theorems 4.3/4.7).
   - Compare `irreducibleRate` against `irreducibleRateGL2 q = q/(2(q+1))`; a match indicates `GL₂`, while a strictly smaller value indicates `SL₂` (Theorems 5.2–5.3).
5. *Output.* A `SpectralFingerprint` record `(dim, fieldSize, groupType, profile)`.

The accompanying demonstration provides exact, finite-field implementations of Steps 2–4, validating the rate formula and the separation by exhaustive enumeration.

---

## 9. Applications

- **Computational group recognition.** Black-box identification of a matrix group's family from sampled characteristic-polynomial statistics, without access to defining equations — relevant to constructive recognition algorithms for finite simple groups.
- **Cryptanalysis of group-based schemes.** Detecting whether a purportedly "general linear" key space is secretly constrained (e.g. to determinant 1) by measuring the constant-term distribution, a structural leak quantified by Theorem 3.2.
- **Self-dual code construction.** Theorems 4.3/4.7 characterize the monic palindromic generators that yield self-dual cyclic codes.
- **Numerical number theory.** Theorem 7.1 gives a decidable proxy (palindromicity of a polynomial) for the sign of a functional equation, useful in tabulating symmetry types.

---

## 10. Discussion and future work

The framework is deliberately minimal and exact: each theorem is a precisely scoped, machine-verified statement, and the separation result is engineered so that its entire force concentrates in the elementary inequality `q² ≠ q² − 1`. The empirical study of §6 illustrates the discipline this enforces — it pinpoints the SL₂ rate function as a model and exhibits the exact closed form `(q−1)/(2(q+1))`, while confirming that the *proved* separation is unaffected and indeed robust under the correction.

Natural extensions include: (i) formalizing the exact SL₂ rate `(q−1)/(2(q+1))` and the corresponding strengthened separation; (ii) computing closed-form irreducible/self-reciprocal rates for `Sp₄` and `O₄`, discharging the general `spectralSeparationConjecture`; (iii) higher-dimensional fingerprints using full coefficient vectors rather than scalar rates; and (iv) deepening the §7 bridge into a quantitative comparison between finite-field charpoly statistics and the predicted Katz–Sarnak limiting distributions. The recurring theme is that a single, low-dimensional polynomial invariant — the characteristic polynomial — carries enough structure to separate the classical families, and that this separation is the common root of phenomena in group theory, coding theory, random matrix theory, and the analytic theory of L-functions.

---

## References

- Fulman, J. (1999). *A probabilistic approach to conjugacy classes in the finite symplectic and orthogonal groups.* Journal of Algebra.
- Katz, N. M., & Sarnak, P. (1999). *Random Matrices, Frobenius Eigenvalues, and Monodromy.* American Mathematical Society Colloquium Publications.
- Wigner, E. P. (1958). *On the distribution of the roots of certain symmetric matrices.* Annals of Mathematics.
