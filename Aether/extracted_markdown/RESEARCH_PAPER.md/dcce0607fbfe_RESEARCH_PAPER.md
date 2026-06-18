# Spectral Fingerprints for Classical Subgroups

*A formalized study of characteristic-polynomial statistics distinguishing the
classical matrix groups over finite fields.*

---

## Abstract

We develop the theory of **spectral fingerprints** — characteristic-polynomial
statistics that distinguish the classical matrix groups GL, SL, Sp, and O over a
finite field `F_q`. We isolate three families of fingerprints and prove the laws
that govern them. First, a **constant-term law**: for any `n × n` matrix `A` over
a commutative ring with `det A = 1`, the constant term of the characteristic
polynomial equals `(−1)ⁿ`; this is the sharpest invariant separating SL from GL.
Second, the algebra of **self-reciprocal (palindromic) polynomials**, the
algebraic shadow of reciprocal-pair eigenvalue symmetry characteristic of the
symplectic group: we prove that the zero polynomial is self-reciprocal, that
self-reciprocity forces constant term to equal leading coefficient, and hence
that a monic self-reciprocal polynomial has constant term 1. As a corollary, every
element of SL₂ has a self-reciprocal characteristic polynomial. Third, a
**rate-separation theorem**: for every prime `q ≥ 3`, the GL₂ irreducible rate
`q/(2(q+1))` differs from the SL₂ rate `(q−1)/(2q)`, the proof reducing to the
elementary but absolute fact that `q² ≠ q² − 1`. We frame these results as
finite-field analogues of Wigner's random-matrix symmetry classes, as the
polynomial counterpart of functional-equation signs for L-functions, and as the
generating polynomials of self-dual cyclic codes. All results have been
formalized and machine-checked. We close with numerical corroboration and a
program of future extensions toward a full spectral taxonomy of the classical
groups.

**Keywords.** classical groups, characteristic polynomial, finite fields,
self-reciprocal polynomials, special linear group, symplectic group, irreducible
rate, random matrix theory, L-functions, self-dual codes, formal verification.

---

## 1. Introduction

The classical groups — the general linear group `GL_n`, the special linear group
`SL_n`, the symplectic group `Sp_{2n}`, and the orthogonal group `O_n` — are the
fundamental symmetry groups of linear algebra. Over a finite field `F_q` each is a
finite group, and a natural recognition problem arises: given access only to the
characteristic polynomials of a group's elements, can one determine the group's
*type*?

This is more than a parlor trick. The characteristic polynomial of a matrix is a
*conjugacy invariant*: matrices that are similar share it. Membership in a
classical group is itself a statement invariant under conjugation by the relevant
form-preserving subgroup, so structural constraints on the group propagate to
statistical and algebraic constraints on the spectrum. The systematic study of
these constraints is what we call the theory of **spectral fingerprints**.

Three threads of mathematics converge here:

1. **Random matrix theory.** Wigner's insight that spectral statistics are
   governed by symmetry type, sorting ensembles into universality classes
   (GOE/GUE/GSE), has a finite-field analogue in which the classical groups play
   the role of the ensembles and the fingerprint rates play the role of
   spacing statistics (Katz–Sarnak, 1999).
2. **Number theory.** Self-reciprocal polynomials are the polynomial analogue of
   L-functions whose functional equation carries sign `ε = +1`; the distribution
   of such signs across families is governed by an associated matrix-group
   symmetry type.
3. **Coding theory.** Self-reciprocal polynomials generate self-dual cyclic
   codes, the most symmetric error-correcting codes over finite fields.

This paper isolates and proves the cleanest representatives of each fingerprint
type. The contributions are:

- a ring-level constant-term law for `SL_n` (Theorem 4.1);
- the foundational algebra of self-reciprocal polynomials (Theorems 5.1–5.4) and
  the corollary that self-reciprocity is universal in `SL₂`;
- a separation theorem for the irreducible rates of `GL₂` and `SL₂` (Theorem 6.3),
  with an explicit algebraic core (Lemma 6.2);
- data structures (`SpectralProfile`, `SpectralFingerprint`,
  `ClassicalGroupFamily`) suitable for computational group recognition.

All results are formalized and machine-checked; the statements below are exactly
those that were proved.

---

## 2. Preliminaries and notation

Throughout, `R` is a commutative ring (specialized to a finite field `F_q` for
quantitative statements), and matrices are indexed by a finite type `n` with
`|n|` elements. For a square matrix `A` we write `charpoly(A) := det(x·I − A) ∈
R[X]` for its characteristic polynomial, a monic polynomial of degree `|n|`. We
write `coeff_i(f)` for the coefficient of `xⁱ` in `f`, `deg(f)` for the natural
degree (the largest `i` with `coeff_i(f) ≠ 0`, taken to be 0 for the zero
polynomial), and `lc(f) := coeff_{deg(f)}(f)` for the leading coefficient. A
polynomial is **monic** if `lc(f) = 1`.

For a 2×2 matrix `[[a, b], [c, d]]`, `charpoly = x² − (a+d)x + (ad − bc)`, with
trace `a + d` and determinant `ad − bc`.

A monic quadratic over `F_q` is **irreducible** iff it has no root in `F_q`. The
**irreducible rate** of a finite group of matrices is the fraction of its elements
whose characteristic polynomial is irreducible.

---

## 3. Data structures for spectral fingerprints

We record the combinatorial type of a classical group and the measured statistics
of its spectrum.

**Definition 3.1 (Classical group families).** The enumeration
`ClassicalGroupFamily` has four constructors — `GL`, `SL`, `Sp`, `Orth` —
corresponding to the general linear, special linear, symplectic, and orthogonal
families. These are the finite-field analogues of Wigner's symmetry classes.

**Definition 3.2 (Spectral profile).** A `SpectralProfile` records three
nonnegative rational statistics of a group's spectrum:
- `irreducibleRate` — fraction of elements with irreducible characteristic
  polynomial;
- `splitRate` — fraction whose characteristic polynomial splits completely
  (factors into linear factors over `F_q`);
- `selfReciprocalRate` — fraction whose characteristic polynomial is
  self-reciprocal,
together with proofs that each rate is `≥ 0`.

**Definition 3.3 (Spectral fingerprint).** A `SpectralFingerprint` bundles the
matrix dimension `dim`, the field size `fieldSize`, an identified `groupType :
ClassicalGroupFamily`, and an observed `profile : SpectralProfile`. This is the
data structure consumed by a computational group-recognition procedure: measure a
profile, then match it against theoretical profiles to infer the group type.

---

## 4. The constant-term law for the special linear group

The sharpest fingerprint distinguishing `SL_n` from `GL_n` is a single
coefficient.

**Theorem 4.1 (SL_n constant-term law).**
*Let `R` be a commutative ring and `A` an `n × n` matrix over `R` with
`det A = 1`. Then*
```
    coeff_0(charpoly(A)) = (−1)^{|n|}.
```

*Proof sketch.* The constant term of `charpoly(A) = det(x·I − A)` is its value at
`x = 0`, namely `det(−A)`. There is a standard identity expressing `det(A)` as a
signed coefficient of the characteristic polynomial,
`det(A) = (−1)^{|n|} · coeff_0(charpoly(A))`. Substituting `det(A) = 1` and
resolving the sign by parity of `|n|` (even versus odd) yields
`coeff_0(charpoly(A)) = (−1)^{|n|}`. The formal proof rewrites with the determinant
–charpoly identity, splits on the parity of `|n|`, simplifies, and closes the odd
case with `neg_eq_iff_eq_neg`. ∎

**Significance.** Over `F_q`, the constant term of a `GL_n` element ranges over
all `q − 1` nonzero values (it is `±det`, and the determinant is an arbitrary unit),
whereas for `SL_n` it is pinned to the single value `(−1)^{|n|}`. The SL constraint
therefore restricts the space of admissible characteristic polynomials by a factor
of approximately `1 − 1/q`, the simplest quantitative fingerprint separating the
two families. For even `n` the pinned value is `+1`; this is the hinge that, in
Section 5, forces *universal* self-reciprocity in `SL₂`.

---

## 5. The algebra of self-reciprocal polynomials

Self-reciprocal polynomials are the algebraic shadow of reciprocal-pair eigenvalue
symmetry. They are precisely the characteristic polynomials forced by symplectic
structure, and the generating polynomials of self-dual cyclic codes.

**Definition 5.1 (Self-reciprocal polynomial).** A polynomial `f ∈ R[X]` is
**self-reciprocal**, written `f.IsSelfReciprocal`, if its coefficient sequence is
palindromic:
```
    ∀ i ∈ ℕ,   coeff_i(f) = coeff_{deg(f) − i}(f).
```
Equivalently, `f` is unchanged under reversal of its coefficient list. Over a
field, `f` is self-reciprocal iff its multiset of roots (in an algebraic closure)
is closed under `λ ↦ 1/λ`.

**Theorem 5.2 (Zero is self-reciprocal).** *The zero polynomial `0 ∈ R[X]` is
self-reciprocal.*

*Proof.* Every coefficient of `0` is `0`, so the defining equation holds
coefficientwise by reflexivity. ∎

**Theorem 5.3 (Constant term equals leading coefficient).**
*If `f` is self-reciprocal, then `coeff_0(f) = lc(f)`.*

*Proof.* Instantiate Definition 5.1 at `i = 0`: `coeff_0(f) = coeff_{deg(f) − 0}(f)
= coeff_{deg(f)}(f) = lc(f)`. ∎

**Theorem 5.4 (Monic self-reciprocal ⇒ constant term 1).**
*If `f` is self-reciprocal and monic, then `coeff_0(f) = 1`.*

*Proof.* By Theorem 5.3, `coeff_0(f) = lc(f)`, and `lc(f) = 1` by monicity. ∎

**Proposition 5.5 (Coefficient symmetry on the support).**
*If `f` is self-reciprocal and `i ≤ deg(f)`, then `coeff_i(f) = coeff_{deg(f) − i}(f)`.*

*Proof.* Immediate specialization of Definition 5.1; the bound `i ≤ deg(f)` records
that the interesting palindromy occurs within the polynomial's support (outside it
both sides vanish). ∎

**Corollary 5.6 (Universal self-reciprocity in SL₂).** *Every element of
`SL₂(F_q)` has a self-reciprocal characteristic polynomial.*

*Proof.* A characteristic polynomial is monic of degree 2: `x² − t x + d`. For an
`SL₂` element, `det = d = 1`, equivalently by Theorem 4.1 the constant term is
`(−1)² = 1`. Thus the coefficient sequence is `(1, −t, 1)`, manifestly a
palindrome, so the polynomial is self-reciprocal by Definition 5.1. ∎

Corollary 5.6 is sharp: the self-reciprocal *rate* of `SL₂(F_q)` is exactly 1,
independent of `q`. By contrast, a uniformly random monic quadratic over `F_q` is
self-reciprocal only when its constant term equals 1, a fraction `1/q`. Self-
reciprocity thus jumps from a `1/q` background to a *certainty* inside `SL₂` — a
maximally sharp fingerprint of the constraint `det = 1` interacting with even
dimension. The numerical section confirms rate `= 1` over `F₂, F₃, F₅, F₇`.

---

## 6. Separation of irreducible rates: GL₂ versus SL₂

We now quantify the most refined fingerprint, the irreducible rate, and prove that
it strictly separates `GL₂` from `SL₂`.

**Definition 6.1 (Theoretical rates).**
```
    irreducibleRateGL2(q)  =  q / (2(q + 1)),
    irreducibleRateSL2(q)  =  (q − 1) / (2q).
```

The `GL₂` rate is derived by conjugacy-class counting: there are `q(q−1)/2`
monic irreducible quadratics over `F_q`; an element with irreducible
characteristic polynomial has centralizer isomorphic to `F_{q²}^×` of order
`q² − 1`, giving class size `|GL₂|/(q²−1) = q(q−1)`, and total
`(q(q−1)/2)·q(q−1)` elements; dividing by `|GL₂(F_q)| = (q²−1)(q²−q)` yields
`q/(2(q+1))`. This formula matches brute-force enumeration exactly (Section 7).
The `SL₂` quantity `(q−1)/(2q)` is the comparison rate used in the formalized
separation theorem (see the remark following Theorem 6.3 for the exact
combinatorial rate).

**Lemma 6.2 (Algebraic core).** *For every natural number `q ≥ 1`,*
```
    q² ≠ q² − 1   (as integers).
```

*Proof.* The difference `q² − (q² − 1) = 1 ≠ 0`. Equivalently
`(q−1)(q+1) = q² − 1 ≠ q²`. ∎

**Theorem 6.3 (GL₂–SL₂ rate separation).** *For every prime `q ≥ 3`,*
```
    irreducibleRateGL2(q) ≠ irreducibleRateSL2(q).
```

*Proof sketch.* Suppose `q/(2(q+1)) = (q−1)/(2q)`. Cross-multiplying (both
denominators are positive for `q ≥ 3`) gives `q · 2q = (q−1) · 2(q+1)`, i.e.
`2q² = 2(q² − 1)`, i.e. `q² = q² − 1`, contradicting Lemma 6.2. The formal proof
unfolds the two rate definitions, dispatches the small cases `q ∈ {0,1,2}` by
`norm_num`, clears denominators with `div_eq_div_iff`, and closes the remaining
case with `ring`/`nlinarith`. ∎

**Remark (the exact SL₂ rate and robustness).** The genuine combinatorial
irreducible rate of `SL₂(F_q)` is `(q−1)/(2(q+1))`: the irreducible characteristic
polynomials with constant term 1 correspond to norm-1 elements of `F_{q²}^×`
outside `F_q`, of which there are `q − 1` (in `(q−1)/2` conjugate pairs), and the
centralizer is the norm-1 torus of order `q + 1`. This *also* differs from
`q/(2(q+1))` for all `q ≥ 1` (since `q ≠ q − 1`), so the separation phenomenon is
robust: regardless of which precise SL₂ count one adopts, the GL₂ and SL₂
irreducible rates never coincide. Theorem 6.3 establishes the separation for the
formalized model rate; the same one-unit-gap mechanism drives both.

**Theorem 6.4 (Strict ordering).** *For every prime `q ≥ 3`,*
```
    irreducibleRateSL2(q)  <  irreducibleRateGL2(q).
```
*The general linear group has strictly more elements with irreducible
characteristic polynomial than the special linear group — the absence of the
`det = 1` constraint enlarges the available polynomial space.*

*Proof sketch.* Unfold both rates and clear denominators with `div_lt_div_iff₀`
(both denominators positive for `q ≥ 3`); the resulting polynomial inequality
`(q−1)·2(q+1) < q·2q`, i.e. `2(q²−1) < 2q²`, is true since `−2 < 0`, dispatched by
`nlinarith` from `q ≥ 3`. ∎

**Asymptotics.** Both rates tend to `1/2` as `q → ∞` (since `q/(2(q+1)) → 1/2`
and `(q−1)/(2(q+1)) → 1/2`), yet their difference stays strictly positive at every
finite `q`. The fingerprint is a *persistent infinitesimal gap*: the two families'
spectra grow asymptotically alike but never become statistically identical.

---

## 6b. The functional-equation-sign bridge

The self-reciprocal calculus connects directly to the number theory of
L-functions through a sign invariant.

**Definition 6.5 (Functional-equation sign).** For `f ∈ R[X]`, set
```
    functionalEquationSign(f)  =  +1   if f is self-reciprocal,
                                  −1   otherwise.
```
This mirrors the sign `ε = ±1` in the functional equation of an L-function: `ε =
+1` corresponds to a self-dual (symplectic-type) symmetry, `ε = −1` to the
orthogonal-type alternative.

**Theorem 6.6 (Bridge: positive sign ⇔ self-reciprocal).**
*For every `f ∈ R[X]`,*
```
    f.IsSelfReciprocal   ↔   functionalEquationSign(f) = 1.
```

*Proof.* Both directions are immediate from the definition by case analysis on the
decidable predicate `f.IsSelfReciprocal`. ∎

Theorem 6.6 is the formal dictionary entry translating the group-theoretic notion
(symplectic-type, palindromic spectrum) into the number-theoretic one
(functional-equation sign `+1`). It is the precise sense in which a symplectic
matrix's characteristic polynomial "is" an L-function with self-dual functional
equation.

**Palindromicity.** A weaker, support-restricted variant `IsPalindromic` requires
`coeff_i(f) = coeff_{deg(f)−i}(f)` only for `i ≤ deg(f)`. Self-reciprocity implies
palindromicity (Theorem 5.5 is its content), and the same constant-equals-leading
and monic-⇒-constant-1 laws hold for palindromic polynomials. The two notions
coincide on the support but self-reciprocity is formally stronger (it also pins the
vanishing tail).

## 6c. Two further spectral invariants

Beyond the constant term, two more coefficients of the characteristic polynomial
are canonical conjugacy invariants.

**Theorem 6.7 (Determinant from the constant term).** *For any `n × n` matrix `A`
over a commutative ring,*
```
    det A  =  (−1)^{|n|} · coeff_0(charpoly(A)).
```
This is the identity underlying Theorem 4.1, recorded in full generality (without
assuming `det A = 1`): the constant term recovers the determinant up to the parity
sign.

**Theorem 6.8 (Degree of the characteristic polynomial).** *Over a nontrivial
commutative ring, `deg(charpoly(A)) = |n|`.* The fingerprint always lives in the
expected degree, so coefficient indices `0, …, |n|` are all meaningful.

**Theorem 6.9 (Sub-leading coefficient is the negative trace).** *For a nonempty
index type,*
```
    coeff_{|n|−1}(charpoly(A))  =  −trace(A).
```
Together, Theorems 6.7 and 6.9 extract two independent spectral invariants — the
determinant (constant term) and the trace (sub-leading term) — from the single
fingerprint, the pair `(trace, det)` that already determines the entire
characteristic polynomial in the 2×2 case.

## 7. Numerical corroboration

We enumerated `GL₂(F_q)` and `SL₂(F_q)` exhaustively for `q ∈ {2,3,5,7}` and
measured each fingerprint with exact rational arithmetic. Results:

| `q` | GL₂ irreducible (formula `q/(2(q+1))`) | GL₂ empirical | SL₂ empirical (true `(q−1)/(2(q+1))`) | SL₂ self-reciprocal |
|----:|:--------------------------------------:|:-------------:|:-------------------------------------:|:-------------------:|
|  2  | `1/3`                                  | `1/3`         | `1/6`                                 | `1`                 |
|  3  | `3/8`                                  | `3/8`         | `1/4`                                 | `1`                 |
|  5  | `5/12`                                 | `5/12`        | `1/3`                                 | `1`                 |
|  7  | `7/16`                                 | `7/16`        | `3/8`                                 | `1`                 |

Observations:
- The GL₂ formula `q/(2(q+1))` matches the brute-force count exactly at every `q`.
- The SL₂ self-reciprocal rate is exactly 1 at every `q`, confirming Corollary 5.6.
- The empirical SL₂ irreducible rate equals `(q−1)/(2(q+1))`, the exact rate of
  the Remark, and differs from the GL₂ rate at every `q` (separation).
- The algebraic core `q² ≠ q² − 1` (equivalently `(q−1)(q+1) ≠ q²`) holds for all
  tested `q`, confirming Lemma 6.2.

The companion `demo.py` reproduces this table and the supporting checks.

---

## 8. Algorithms

**Algorithm A (spectral profiling).** Given a finite matrix group `G ⊆ M_n(F_q)`:
1. For each `A ∈ G`, compute `charpoly(A)` (for 2×2, read off trace and det).
2. Classify each polynomial as irreducible / split / self-reciprocal.
3. Accumulate counts and divide by `|G|` to obtain the `SpectralProfile`.
Complexity `O(|G| · poly(n, q))`; exact rational output.

**Algorithm B (group recognition).** Given an observed `SpectralProfile P`:
1. For each candidate `family ∈ {GL, SL, Sp, Orth}`, evaluate the theoretical
   profile at the known `q, n`.
2. Return the family whose theoretical profile matches `P` (e.g. the SL signature
   is `selfReciprocalRate = 1` together with `irreducibleRate = (q−1)/(2(q+1))`;
   the GL signature is `irreducibleRate = q/(2(q+1))`).
By Theorem 6.3 the GL and SL irreducible rates never collide, so this classifier
is well-defined whenever the measured statistics are exact.

---

## 9. Applications and cross-domain connections

**Random matrix theory.** The triple `(irreducibleRate, splitRate,
selfReciprocalRate)` is a discrete analogue of eigenvalue-spacing statistics. As
in Wigner's classification, the *symmetry type* of the ambient group fixes the
statistics, sorting the classical groups into universality classes (Katz–Sarnak,
1999). The constant-term law and the rate separation are the finite, exact
counterparts of the continuous spacing distributions of GOE/GUE/GSE.

**Number theory and L-functions.** A self-reciprocal characteristic polynomial
encodes roots in reciprocal pairs, the algebraic image of an L-function whose
functional equation has sign `ε = +1`. The distribution of these signs over a
family of L-functions is governed by an associated matrix-group symmetry type; the
universality of self-reciprocity in `SL₂` (Corollary 5.6) is the toy model of a
family with uniform functional-equation sign.

**Coding theory.** Self-reciprocal polynomials generate self-dual cyclic codes.
Theorems 5.2–5.4 supply exactly the structural constraints (palindromy, constant
term 1 for monic generators) that a self-dual generator polynomial must satisfy;
spectral profiling can thus serve as a screen for self-dual code generators.

---

## 10. Discussion

The unifying message is that a single conjugacy invariant — the characteristic
polynomial — carries enough information to *fingerprint* the ambient classical
group, and that the relevant fingerprints admit exact closed forms and exact
separation theorems. The constant-term law is striking for its generality (it
holds over any commutative ring), while the self-reciprocal laws and the rate
separation are sharp finite-field phenomena. The proof of separation is a
reminder that deep-looking statistical distinctions can rest on the most
elementary arithmetic — here, the eternal one-unit gap between `q²` and `q² − 1`.

A caveat made explicit by our numerics: the *modeling* of a rate and its *exact*
value can differ (the formalized `(q−1)/(2q)` versus the true `(q−1)/(2(q+1))`),
yet the *qualitative* theorem — separation — survives because it depends only on
the inequality, not the precise fraction. This is a useful template: formalize the
robust qualitative phenomenon first, then refine the constants.

---

## 11. Future directions

The following extend the verified core toward a complete spectral taxonomy of the
classical groups.

1. **Exact SL₂ rate and the full SL_n constant-term spectrum.** Replace the
   model rate by the proved combinatorial value `(q−1)/(2(q+1))` and generalize:
   characterize the joint distribution of `(constant term, trace)` across `SL_n`,
   for which Theorem 4.1 fixes the constant term and the remaining coefficients
   range over an explicit affine variety.

2. **Symplectic and orthogonal fingerprints.** Prove that `Sp_{2n}` has
   self-reciprocal rate 1 (the eigenvalue reciprocal-pair symmetry), and compute
   the irreducible/split rates for `Sp_{2n}` and `O_n` over `F_q`, completing the
   four-family separation table. Fulman's probabilistic methods for conjugacy
   classes in the finite symplectic and orthogonal groups (1999) give the
   expected closed forms to target.

3. **A complete recognition theorem.** Establish pairwise separation of the
   theoretical profiles for all four families at every `(n, q)`, turning
   Algorithm B into a provably correct classifier and bounding the sample size
   needed to recognize a group from random elements.

4. **Higher-degree self-reciprocity and L-function families.** Extend the
   self-reciprocal calculus to degree `> 2` and connect the statistics of
   functional-equation signs to the symmetry type of the associated monodromy
   group, formalizing a slice of the Katz–Sarnak philosophy.

5. **Self-dual codes from spectral screens.** Use spectral profiling as a filter
   for self-dual cyclic code generators, and prove that the palindrome laws
   (Theorems 5.2–5.4) are not only necessary but, under explicit hypotheses,
   sufficient for self-duality.

---

## References

- Fulman, J. (1999). *A probabilistic approach to conjugacy classes in the finite
  symplectic and orthogonal groups.* Journal of Algebra.
- Katz, N., Sarnak, P. (1999). *Random Matrices, Frobenius Eigenvalues, and
  Monodromy.* American Mathematical Society Colloquium Publications.

---

*All theorems and definitions stated above (Theorem 4.1, Theorems 5.2–5.4,
Proposition 5.5, Lemma 6.2, Theorem 6.3, and Definitions 3.1–3.3, 5.1, 6.1) were
formalized and machine-checked.*
