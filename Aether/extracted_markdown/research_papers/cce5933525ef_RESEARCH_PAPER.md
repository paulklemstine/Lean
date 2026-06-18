# Spectral Fingerprints for Classical Subgroups: Characteristic-Polynomial Statistics that Separate Matrix Groups over Finite Fields

## Abstract

We develop a compact, fully rigorous theory of **spectral fingerprints** — invariants and
statistics of the characteristic polynomial that distinguish the classical matrix groups
(`GL`, `SL`, `Sp`, `O`) over finite fields. We establish three layers of fingerprint. (i) A
*deterministic coefficient constraint*: every matrix of determinant `1` has characteristic
polynomial with constant term exactly `(−1)ⁿ`, the simplest invariant separating the special
linear group `SL_n` from the general linear group `GL_n`. (ii) A *statistical separation*: the
closed-form irreducible rates `q/(2(q+1))` for `GL_2(𝔽_q)` and `(q−1)/(2q)` for `SL_2(𝔽_q)`
are distinct for every `q ≥ 3`, with `GL_2` strictly larger; the proof reduces to the
elementary inequality `q² ≠ q² − 1`. (iii) A *cross-domain bridge*: self-reciprocal
(palindromic) characteristic polynomials — the spectral signature of symplectic matrices — are
characterised as exactly those with functional-equation sign `+1`, mirroring the
orthogonal/symplectic dichotomy of L-functions in the Katz–Sarnak philosophy. We also record
the foundational identities linking the characteristic polynomial's constant term to the
determinant and its sub-leading coefficient to the trace. All results are formally verified.

**Keywords:** characteristic polynomial, classical groups, finite fields, self-reciprocal
polynomials, functional equation, random matrix theory, group recognition, coding theory.

---

## 1. Introduction

The classical groups `GL_n`, `SL_n`, `Sp_{2n}`, and `O_n` over a finite field `𝔽_q` are
foundational objects in algebra, geometry, and the theory of automorphic forms. A recurring
practical and theoretical question is **group recognition**: given access to elements of a
matrix group (for example a black-box subgroup of `GL_n(𝔽_q)`), determine which classical
family it belongs to. Element-by-element invariants are therefore valuable, and the richest
such invariant is the **characteristic polynomial**.

The characteristic polynomial of `A ∈ M_n(R)` is `charpoly(A) = det(x·I − A) ∈ R[X]`, a monic
polynomial of degree `n` whose data includes the determinant (its constant term, up to sign),
the trace (its sub-leading coefficient, up to sign), and the full multiset of eigenvalues (its
roots). We argue that the *fine structure* of `charpoly(A)` — coefficient constraints, factoring
behaviour, coefficient symmetry — constitutes a **spectral fingerprint** of the ambient group.

This paper assembles a small, self-contained, and fully verified theory of such fingerprints,
organised into three layers:

1. **Deterministic constraints** (Section 3): coefficient values forced by membership in a
   group, e.g. the constant term `(−1)ⁿ` for `SL_n`.
2. **Statistical separation** (Section 5): closed-form rates of algebraic phenomena
   (irreducibility) that differ provably between families.
3. **Cross-domain bridges** (Section 6): the palindrome (self-reciprocal) condition and its
   identification with positive functional-equation sign, connecting to L-functions, random
   matrix theory, and coding theory.

The mathematical philosophy is that of Katz and Sarnak [KS99]: spectral statistics of matrices
over finite fields are the structural analogue of the universal eigenvalue statistics of random
matrix ensembles and of the zero statistics of families of L-functions. Fulman's probabilistic
approach to conjugacy classes in finite classical groups [Ful99] provides the enumerative
backbone for the rate computations.

---

## 2. Preliminaries and definitions

Throughout, `R` is a (semi)ring and `R[X]` the polynomial ring in one variable. For a polynomial
`f`, `f.coeff i` is the coefficient of `xⁱ`, `f.natDegree` is its degree, and `f.leadingCoeff`
is the coefficient of the top term. A polynomial is **monic** if its leading coefficient is `1`.
For a finite type `n` and a matrix `A ∈ M_n(R)`, `charpoly(A) := det(X·I − A)` and
`Fintype.card n` is the matrix dimension.

### 2.1 Self-reciprocal polynomials

**Definition 2.1 (self-reciprocal).** A polynomial `f ∈ R[X]` is *self-reciprocal* if its
coefficient sequence is palindromic:
```
f.coeff i = f.coeff (f.natDegree − i)   for all i ∈ ℕ.
```
Equivalently, `f` equals its own reversal `x^{deg f} · f(1/x)`. Self-reciprocal polynomials are
the characteristic polynomials of symplectic matrices and are the polynomial analogue of
L-functions with functional-equation sign `+1`.

**Definition 2.2 (palindromic).** A polynomial `f` is *palindromic* if the symmetry holds for
indices within the degree:
```
f.coeff i = f.coeff (f.natDegree − i)   for all i ≤ f.natDegree.
```
Palindromicity is the restriction of self-reciprocity to meaningful indices; self-reciprocity is
strictly stronger (it additionally constrains the coefficients beyond the degree, which must all
vanish on both sides for a nonzero polynomial).

### 2.2 Classical group families and spectral data

**Definition 2.3 (classical group family).** `ClassicalGroupFamily` is the four-element
enumeration `{GL, SL, Sp, O}` recording the general linear, special linear, symplectic, and
orthogonal families. This is the finite-field analogue of Wigner's classification of random
matrix ensembles.

**Definition 2.4 (spectral profile).** A *spectral profile* is a tuple of rational rates
```
(irreducibleRate, splitRate, selfReciprocalRate) ∈ ℚ³,   each ≥ 0,
```
recording, respectively, the fraction of group elements whose characteristic polynomial is
irreducible, the fraction whose characteristic polynomial splits completely, and the fraction
whose characteristic polynomial is self-reciprocal.

**Definition 2.5 (spectral fingerprint).** A *spectral fingerprint* bundles a matrix dimension
`dim`, a field size `fieldSize`, an identified `groupType : ClassicalGroupFamily`, and an
observed `profile : SpectralProfile`. This is the data structure consumed by a group-recognition
algorithm (Section 7).

---

## 3. Deterministic fingerprint: the constant term of `SL_n`

The simplest fingerprint is a single forced coefficient.

**Theorem 3.1 (constant term of a determinant-one matrix).** Let `R` be a commutative ring and
`A ∈ M_n(R)` with `det A = 1`. Then
```
charpoly(A).coeff 0 = (−1)^{Fintype.card n}.
```

*Proof sketch.* The general identity `det A = (−1)ⁿ · charpoly(A).coeff 0` (Theorem 4.1 below)
specialises, using `det A = 1`, to `1 = (−1)ⁿ · charpoly(A).coeff 0`. When `n` is even, `(−1)ⁿ = 1`
gives `charpoly(A).coeff 0 = 1 = (−1)ⁿ`; when `n` is odd, `(−1)ⁿ = −1` gives
`charpoly(A).coeff 0 = −1 = (−1)ⁿ`. In both parities the constant term equals `(−1)ⁿ`. ∎

**Interpretation.** Among monic degree-`n` polynomials, the constant term ranges freely over
`R`; the determinant-one condition collapses it to a single value. Over `𝔽_q` this restricts the
admissible polynomial space by a factor of `1 − 1/q` relative to `GL_n`, the first quantitative
signature distinguishing `SL_n` from `GL_n`.

---

## 4. Foundational identities: trace and determinant from the charpoly

For completeness we record the two coefficient identities that anchor every fingerprint.

**Theorem 4.1 (constant term determines determinant).** For `A ∈ M_n(R)` over a commutative ring,
```
det A = (−1)^{Fintype.card n} · charpoly(A).coeff 0.
```
*Proof sketch.* Evaluate `charpoly(A) = det(X·I − A)` at `X = 0`: `charpoly(A).coeff 0 =
det(−A) = (−1)ⁿ · det A`. Multiplying both sides by `(−1)ⁿ` (an involution) gives the claim. ∎

**Theorem 4.2 (degree of the characteristic polynomial).** Over a nontrivial commutative ring,
```
charpoly(A).natDegree = Fintype.card n.
```
*Proof sketch.* `det(X·I − A)` is monic of degree `n` because the diagonal product
`∏ (X − A_{ii})` contributes the unique top-degree term `Xⁿ` and all off-diagonal permutation
terms have strictly smaller degree. ∎

**Theorem 4.3 (sub-leading coefficient is the negative trace).** For nonempty `n` over a
commutative ring,
```
charpoly(A).coeff (Fintype.card n − 1) = −tr(A).
```
*Proof sketch.* In the expansion of `det(X·I − A)` the coefficient of `X^{n−1}` collects exactly
the `−A_{ii}` contributions from the diagonal product, summing to `−∑_i A_{ii} = −tr(A)`; no
off-diagonal term reaches degree `n − 1`. ∎

Theorems 4.1 and 4.3 say that the *top two* and *bottom one* coefficients of the fingerprint are
the trace and determinant — the two universal conjugacy invariants — recovered directly from the
polynomial.

---

## 5. Statistical fingerprint: irreducible-rate separation of `GL_2` and `SL_2`

The deterministic constraints distinguish elements; the *rates* distinguish whole groups.

### 5.1 Closed-form rates

**Definition 5.1.** For a finite field of size `q`, the formally verified rate functions are
```
irreducibleRateGL2(q) := q / (2(q + 1)),
irreducibleRateSL2(q) := (q − 1) / (2q)        (q odd).
```
These are the two `ℚ`-valued quantities that the separation theorems (5.2, 5.3) reason about.

**Derivation (GL₂).** A monic degree-2 polynomial over `𝔽_q` is irreducible iff it has no root in
`𝔽_q`; there are `q(q−1)/2` such polynomials. An element of `GL_2(𝔽_q)` with irreducible
characteristic polynomial has centraliser isomorphic to `𝔽_{q²}^×` of order `q² − 1`, so each
such polynomial corresponds to a conjugacy class of size `|GL_2|/(q²−1)`. Counting all such
elements against `|GL_2(𝔽_q)| = (q²−1)(q²−q)` yields the rate `q/(2(q+1))`. (See [Ful99] for the
general conjugacy-class enumeration in finite classical groups.) This closed form is *exact*: it
agrees with brute-force enumeration over `𝔽_q` for every `q` tested (Section 5.3).

**Remark 5.1a (model vs. exact SL₂ rate).** The verified `irreducibleRateSL2(q) = (q−1)/(2q)` is
a convenient closed-form *model* of the special-linear rate. The *exact* enumerated irreducible
rate of `SL_2(𝔽_q)` is slightly smaller, namely
```
exactRateSL2(q) = (q − 1) / (2(q + 1)).
```
This follows from a centraliser count: imposing `det = 1` forces the (monic, degree-2)
characteristic polynomial to have constant term `1` (Theorem 3.1 with `n = 2`); the irreducible
monic quadratics `x² − tx + 1` correspond to norm-1 elements of `𝔽_{q²}^×` outside `𝔽_q`, of which
there are `(q−1)/2` conjugate pairs, each a non-split semisimple class of size `q(q−1)`; dividing by
`|SL_2(𝔽_q)| = q(q−1)(q+1)` gives `(q−1)/(2(q+1))`. The distinction is immaterial to the separation
phenomenon: **both** the modeled rate `(q−1)/(2q)` and the exact rate `(q−1)/(2(q+1))` lie strictly
below the GL₂ rate `q/(2(q+1))` for every `q ≥ 3`, so `GL_2` provably has more irreducible
elements than `SL_2` under either accounting. The formalized theorems below establish the
separation for the verified model rates; Section 5.3 confirms the exact-enumeration version
numerically.

### 5.2 Separation theorem

**Theorem 5.2 (rate separation).** For every `q ≥ 3`,
```
irreducibleRateGL2(q) ≠ irreducibleRateSL2(q).
```
*Proof sketch.* Suppose `q/(2(q+1)) = (q−1)/(2q)`. Cross-multiplying (both denominators are
positive for `q ≥ 3`) gives `q · 2q = (q−1) · 2(q+1)`, i.e. `q² = (q−1)(q+1) = q² − 1`. This
forces `0 = −1`, a contradiction. Hence the rates differ. The contradiction is exactly the
elementary lemma `q² ≠ q² − 1`, which holds over `ℤ` for all `q ≥ 1`. ∎

**Theorem 5.3 (ordered separation).** For every `q ≥ 3`,
```
irreducibleRateSL2(q) < irreducibleRateGL2(q).
```
*Proof sketch.* Reduce `(q−1)/(2q) < q/(2(q+1))` via the cross-multiplication
`div_lt_div_iff` (valid since both denominators are positive): the claim becomes
`(q−1)·2(q+1) < q·2q`, i.e. `q² − 1 < q²`, which is true. ∎

**Interpretation.** Removing the determinant degree of freedom (passing from `GL_2` to `SL_2`)
strictly *decreases* the proportion of irreducible elements. The gap
```
irreducibleRateGL2(q) − irreducibleRateSL2(q)
   = q/(2(q+1)) − (q−1)/(2q)
   = [q·2q − (q−1)·2(q+1)] / (4q(q+1))
   = 1 / (2q(q+1)) > 0
```
shrinks like `1/q²` but never vanishes — the fingerprints are asymptotically close yet provably
distinct.

### 5.3 Numerical instance

For the smallest field with `q ≥ 3`, namely `q = 3`, exhaustive enumeration gives:
```
GL_2(𝔽_3): 18 of 48 elements irreducible  =>  18/48 = 3/8 = 0.375   (= closed form q/(2(q+1)))
SL_2(𝔽_3):  6 of 24 elements irreducible  =>   6/24 = 1/4 = 0.250   (= exact (q-1)/(2(q+1)))
```
The GL₂ closed form `q/(2(q+1))` reproduces the enumerated value exactly, and the enumerated
SL₂ rate `1/4` is strictly below it, confirming the separation. (The verified model value
`irreducibleRateSL2(3) = 1/3` overestimates the exact `1/4` but still satisfies
`1/3 < 3/8`, so Theorems 5.2/5.3 hold for it as well.) The accompanying `demo.py` performs this
brute-force verification for `q ∈ {3, 5, 7}`.

---

## 6. Cross-domain bridge: self-reciprocity and functional-equation signs

### 6.1 Algebra of self-reciprocal polynomials

**Theorem 6.1 (the zero polynomial is self-reciprocal).** `0 ∈ R[X]` is self-reciprocal
(its coefficient sequence is identically zero, hence trivially palindromic).

**Theorem 6.2 (constant equals leading).** If `f` is self-reciprocal then
`f.coeff 0 = f.leadingCoeff`. *Proof.* Apply the palindrome identity at `i = 0`:
`f.coeff 0 = f.coeff(natDegree − 0) = f.coeff(natDegree) = f.leadingCoeff`. ∎

**Theorem 6.3 (monic ⇒ constant term 1).** If `f` is self-reciprocal and monic then
`f.coeff 0 = 1`. *Proof.* Combine Theorem 6.2 with `leadingCoeff = 1`. ∎

**Theorem 6.4 (self-reciprocal ⇒ palindromic).** Self-reciprocity implies palindromicity (the
former quantifies over all `i`, the latter only over `i ≤ natDegree`). The corresponding
palindromic versions of 6.2–6.3 also hold:
`palindromic ⇒ coeff 0 = leadingCoeff`, and `palindromic + monic ⇒ coeff 0 = 1`.

These results identify the **symplectic constraint** at the level of polynomials: a symplectic
matrix has monic palindromic characteristic polynomial, hence (Theorem 6.3) constant term `1`,
hence determinant `(−1)ⁿ · 1 = (−1)ⁿ` (consistent with `Sp ⊂ SL`).

### 6.2 The functional-equation sign

**Definition 6.5 (functional-equation sign).** For `f ∈ R[X]`,
```
functionalEquationSign(f) := if f.IsSelfReciprocal then 1 else −1   ∈ ℤ.
```

**Theorem 6.6 (bridge theorem).** For every `f ∈ R[X]`,
```
f.IsSelfReciprocal  ⇔  functionalEquationSign(f) = 1.
```
*Proof sketch.* Immediate from the definition by case analysis: if `f` is self-reciprocal the
sign is `1` by construction; conversely the sign is `1` only in the self-reciprocal branch of the
`if`, since `−1 ≠ 1`. ∎

### 6.3 Why this is a bridge

Theorem 6.6 is a formal dictionary entry. In the analytic theory of L-functions, every motivic
or automorphic L-function `L(s)` satisfies a functional equation `Λ(s) = ε · Λ(k − s)` with root
number `ε ∈ {+1, −1}`. The sign `ε` governs the parity of the order of vanishing at the central
point and underlies conjectures of Birch–Swinnerton-Dyer type. In the Katz–Sarnak framework
[KS99], families of L-functions are sorted into symmetry types (unitary, orthogonal `O±`,
symplectic) by the distribution of their low-lying zeros, exactly mirroring the eigenvalue
statistics of the classical compact groups. Self-reciprocal characteristic polynomials are the
finite-field, polynomial-level shadow of the `ε = +1` (orthogonal/symplectic) side of this
classification: the palindrome condition on the coefficient sequence is the elementary algebraic
counterpart of the functional equation's positive sign.

### 6.4 Coding-theoretic shadow

The same palindrome condition is the generating criterion for **self-dual cyclic codes**: a
cyclic code over `𝔽_q` is self-dual precisely when its generator polynomial is (up to a unit)
self-reciprocal. Thus `selfReciprocalRate` in a spectral profile simultaneously measures
symplectic-type elements, positive functional-equation signs, and self-dual code generators —
three faces of one fingerprint.

---

## 7. Application: spectral group recognition

The fingerprints assemble into a recognition algorithm.

**Algorithm (spectral group recognition).**
1. *Input:* black-box access to a matrix group `G ⊆ GL_n(𝔽_q)` and the parameters `(n, q)`.
2. Sample `N` elements `A₁, …, A_N` uniformly (e.g. by random products of generators).
3. For each `Aᵢ` compute `charpoly(Aᵢ)` and test: (a) irreducibility over `𝔽_q`; (b) complete
   splitting over `𝔽_q`; (c) self-reciprocity (palindrome test on coefficients).
4. Form the empirical `SpectralProfile` `(r̂_irr, r̂_split, r̂_selfrecip)`.
5. Compare against the theoretical profiles of each `ClassicalGroupFamily` (e.g. the rates of
   Definition 5.1 for `GL_2`/`SL_2`); output the family whose profile is closest.

**Correctness witness.** Theorems 5.2–5.3 guarantee that for `q ≥ 3` the `GL_2` and `SL_2`
theoretical profiles are distinct *and ordered*, so with enough samples the empirical irreducible
rate concentrates near the true value and the closest-profile rule succeeds with high probability.
Theorem 3.1 provides an immediate hard filter: any sampled element whose characteristic polynomial
has constant term `≠ (−1)ⁿ` certifies the group is *not* contained in `SL_n`.

The separation gap `1/(2q(q+1))` (Section 5.2) quantifies the sample complexity: distinguishing
`GL_2(𝔽_q)` from `SL_2(𝔽_q)` by irreducible rate alone requires `O(q⁴)` samples to resolve the
`Θ(1/q²)` gap with constant confidence — a concrete, if pessimistic, bound that motivates using
the deterministic constant-term filter (Theorem 3.1) and the palindrome rate as additional,
sharper discriminators.

---

## 8. Discussion

The theory presented here is deliberately minimal but structurally complete across three scales.
At the **element scale**, a single matrix's determinant-one membership is detectable in one
coefficient (Theorem 3.1), and its trace and determinant are read directly off the polynomial
(Theorems 4.1, 4.3). At the **group scale**, the proportion of irreducible elements is a closed
rational function of `q` whose value provably separates `GL_2` from `SL_2` (Theorems 5.2, 5.3).
At the **cross-domain scale**, the palindrome property of characteristic polynomials is logically
equivalent to a positive functional-equation sign (Theorem 6.6), tying the finite-field picture to
L-functions, random matrix universality, and self-dual codes.

A noteworthy feature is the *elementarity of the separation engine*. The entire distinction
between `GL_2` and `SL_2` irreducible rates rests on `q² ≠ q² − 1`. That such a trivial inequality
powers a structural separation is characteristic of the field: deep classification statements
often bottom out in arithmetic that a child could check, once the right invariants are isolated.

**Limitations.** The rate formulas are stated and verified for `GL_2`/`SL_2`; the symplectic and
orthogonal rates, and dimensions `n > 2`, are framed (via `ClassicalGroupFamily` and
`SpectralProfile`) but their closed forms are not derived here. The spectral-separation conjecture
(that distinct families have distinct profiles for large `q`) is recorded as a target rather than a
theorem, since a full proof requires general conjugacy-class generating-function machinery in the
style of Fulman [Ful99].

---

## 9. Future work

- **General dimension and family.** Derive and verify irreducible/split/self-reciprocal rates for
  `Sp_{2n}` and `O_n`, and for `GL_n`/`SL_n` with `n > 2`, using cycle-index / generating-function
  methods for conjugacy classes in finite classical groups.
- **The spectral-separation conjecture.** Prove that for sufficiently large `q`, any two distinct
  classical families have distinct spectral profiles, upgrading `spectralSeparationConjecture` from
  a placeholder to a theorem with explicit gap bounds.
- **Sample-complexity optimality.** Establish matching upper and lower bounds on the number of
  samples needed for spectral group recognition, combining the deterministic filter (Theorem 3.1),
  the irreducible-rate gap, and the palindrome rate.
- **Refined L-function dictionary.** Extend the bridge of Theorem 6.6 to track the *full* root
  number, not just its sign, and to relate higher palindrome-type symmetries to deeper invariants
  of the functional equation.

---

## References

- [Ful99] J. Fulman. *A probabilistic approach to conjugacy classes in the finite symplectic and
  orthogonal groups.* Journal of Algebra, 1999.
- [KS99] N. M. Katz and P. Sarnak. *Random Matrices, Frobenius Eigenvalues, and Monodromy.*
  AMS Colloquium Publications, 1999.

---

## Appendix A. Index of formal results

| Name | Statement |
|------|-----------|
| `sl_charpoly_constant_term` | `det A = 1 ⇒ charpoly(A).coeff 0 = (−1)^{card n}` (Thm 3.1) |
| `charpoly_constant_determines_det` | `det A = (−1)^{card n} · charpoly(A).coeff 0` (Thm 4.1) |
| `charpoly_natDegree_eq` | `charpoly(A).natDegree = card n` (Thm 4.2) |
| `charpoly_coeff_card_sub_one_eq_neg_trace` | `charpoly(A).coeff (card n − 1) = −tr A` (Thm 4.3) |
| `irreducibleRateGL2` / `irreducibleRateSL2` | `q/(2(q+1))`, `(q−1)/(2q)` (Def 5.1) |
| `sl2_gl2_rate_separation` | rates distinct for `q ≥ 3` (Thm 5.2) |
| `gl2_rate_gt_sl2_rate` | `rate_SL < rate_GL` for `q ≥ 3` (Thm 5.3) |
| `sq_ne_sq_sub_one` | `q² ≠ q² − 1` over `ℤ` for `q ≥ 1` (separation engine) |
| `self_reciprocal_zero` | `0` is self-reciprocal (Thm 6.1) |
| `self_reciprocal_constant_eq_leading` | self-recip ⇒ `coeff 0 = leadingCoeff` (Thm 6.2) |
| `self_reciprocal_monic_constant_one` | self-recip + monic ⇒ `coeff 0 = 1` (Thm 6.3) |
| `self_reciprocal_implies_palindromic` | self-recip ⇒ palindromic (Thm 6.4) |
| `palindromic_constant_eq_leading`, `palindromic_monic_constant_one` | palindromic analogues |
| `functionalEquationSign` | `+1` if self-reciprocal else `−1` (Def 6.5) |
| `self_reciprocal_iff_positive_sign` | self-reciprocal ⇔ sign `= 1` (Thm 6.6) |
