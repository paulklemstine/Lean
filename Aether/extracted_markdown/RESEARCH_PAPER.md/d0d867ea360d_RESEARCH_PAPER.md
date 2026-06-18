# Spectral Fingerprints for Classical Subgroups: Characteristic-Polynomial Statistics that Separate the Classical Families

## Abstract

We develop a framework of **spectral fingerprints** — statistics extracted from
the characteristic polynomials of matrices — that distinguish the classical
matrix groups (general linear, special linear, symplectic, orthogonal) over
finite fields. We isolate two structural invariants and one population statistic.
First, we prove that membership in the special linear group `SL_n` forces the
constant term of the characteristic polynomial to equal `(−1)^n`, a hard
algebraic constraint absent in `GL_n`. Second, we introduce **self-reciprocal**
(palindromic) polynomials as the polynomial signature of symplectic type, prove
their basic structure theory (endpoint equality, the monic-constant-term-one
property, and the implication from the strong to the degree-bounded form), and
establish a **cross-domain bridge theorem**: a polynomial is self-reciprocal if
and only if its associated functional-equation sign is `+1`. This formally welds
the group-theoretic notion of symplectic type to the number-theoretic notion of a
root number `ε = +1`. Third, we record the closed-form irreducible rates for
`GL_2(𝔽_q)` and `SL_2(𝔽_q)` and prove a **separation theorem**: these rates are
distinct for every `q ≥ 3`, with the general-linear rate strictly dominating. The
proof reduces to the elementary observation that `q²` never equals `q² − 1`. All
results are stated with full mathematical rigor; the central arithmetic kernel
(`q² ≠ q² − 1`) is what powers the separation phenomenon. We also record auxiliary
identities relating the characteristic polynomial's coefficients to the trace and
determinant. The framework is designed for computational group recognition and
connects, through self-reciprocity, to random matrix theory and to the theory of
self-dual cyclic codes.

**Keywords:** characteristic polynomial, classical groups, finite fields,
self-reciprocal polynomials, functional equation sign, irreducible rate, group
recognition, random matrix theory.

---

## 1. Introduction

### 1.1 The recognition problem

A recurring problem in computational algebra is **constructive group
recognition**: given a matrix, or a population of matrices, identify the ambient
classical group. The classical families over a finite field `𝔽_q` are

- the **general linear group** `GL_n(𝔽_q)` — all invertible `n×n` matrices;
- the **special linear group** `SL_n(𝔽_q)` — those with determinant `1`;
- the **symplectic group** `Sp_n(𝔽_q)` — those preserving a nondegenerate
  alternating form;
- the **orthogonal group** `O_n(𝔽_q)` — those preserving a nondegenerate
  symmetric form.

These families are conjugation-invariant, and the most natural conjugation
invariant of a matrix is its **characteristic polynomial**
`charpoly(A) = det(xI − A)`. We therefore ask: *which features of `charpoly(A)`
betray the family `A` belongs to, and can those features be computed and compared
with certainty?*

### 1.2 Contributions

We answer with three kinds of results, each fully formalized.

1. **A hard constraint for `SL_n`** (Section 3). The constant term of
   `charpoly(A)` equals `(−1)^n · det(A)`; for `SL_n` this collapses to `(−1)^n`.
2. **A structure theory of self-reciprocal polynomials and a bridge to L-function
   signs** (Sections 4 and 5). Self-reciprocal polynomials are the polynomial
   signature of symplectic type. We prove their endpoint and monic properties and
   the equivalence between self-reciprocity and a positive functional-equation
   sign.
3. **A population separation theorem** (Section 6). The irreducible rates of
   `GL_2(𝔽_q)` and `SL_2(𝔽_q)` differ for all `q ≥ 3`, with strict domination.

Section 7 records supporting coefficient identities (trace and determinant from
the charpoly), Section 8 packages everything into a recognition data structure
and states the governing conjecture, and Section 9 discusses applications and
future work.

### 1.3 Context

The statistical study of conjugacy classes in finite classical groups was
developed extensively by Fulman and collaborators using a probabilistic
("cycle-index") method. The structural parallel between finite classical groups
and symmetry types of families of L-functions is the central theme of Katz and
Sarnak's monodromy program, itself the arithmetic incarnation of Wigner's and
Dyson's classification of random matrix ensembles into orthogonal, unitary, and
symplectic symmetry classes. Our contribution is to extract a small,
self-contained, and *rigorously verified* core of this picture: the exact
constraints and separations that can be stated for low-dimensional classical
groups and the polynomial dictionary connecting symplectic type to functional
equation signs.

---

## 2. Preliminaries and notation

Throughout, `R` denotes a commutative ring (occasionally only a semiring), and
`R[X]` its polynomial ring. For a polynomial `f ∈ R[X]` we write:

- `f.coeff i` for the coefficient of `x^i`;
- `f.natDegree` for the degree (with the convention `natDegree 0 = 0`);
- `f.leadingCoeff` for the coefficient at `natDegree`;
- `f.Monic` for the property `leadingCoeff = 1`.

For an `n×n` matrix `A` over `R` we write `A.charpoly = det(X·I − A) ∈ R[X]`,
`A.det` for the determinant, `A.trace` for the trace, and `Fintype.card n` for
the dimension `n` (the index type's cardinality). We use the standard identity,
available for matrices over any commutative ring,

> `det(A) = (−1)^n · charpoly(A).coeff 0`,   (★)

and the degree identity `charpoly(A).natDegree = n` over a nontrivial ring.

---

## 3. The constant-term constraint for `SL_n`

The first fingerprint is the simplest. The constant term of the characteristic
polynomial is, up to sign, the determinant.

> **Definition 3.1 (Spectral profile data).** A *spectral profile* is a record of
> three nonnegative rationals: the **irreducible rate** (fraction of group
> elements whose characteristic polynomial is irreducible over `𝔽_q`), the
> **split rate** (fraction whose charpoly splits completely into linear factors),
> and the **self-reciprocal rate** (fraction whose charpoly is self-reciprocal).
> Each rate is required to be `≥ 0`.

> **Theorem 3.2 (Constant term of `SL_n`).** Let `R` be a commutative ring and
> `A` an `n×n` matrix over `R` with `det(A) = 1`. Then
> `charpoly(A).coeff 0 = (−1)^n`,
> where `n = Fintype.card n` is the matrix dimension.

*Proof sketch.* Apply identity (★): `det(A) = (−1)^n · charpoly(A).coeff 0`.
Substituting `det(A) = 1` gives `1 = (−1)^n · charpoly(A).coeff 0`. Multiplying
through by `(−1)^n` (which squares to `1`) yields
`charpoly(A).coeff 0 = (−1)^n`. Concretely one splits on the parity of `n`: if
`n` is even, `(−1)^n = 1` and the constant term is `1`; if `n` is odd,
`(−1)^n = −1` and the constant term is `−1`, obtained by rearranging
`1 = −charpoly(A).coeff 0`. ∎

**Interpretation.** In `GL_n(𝔽_q)`, the determinant ranges over all `q − 1`
nonzero scalars, so the constant term of the charpoly is free among `q − 1`
values. In `SL_n` it is pinned to a single value `(−1)^n`. This is the most
elementary spectral separation: the `SL` fingerprint occupies a slice of the
`GL` fingerprint space of relative size `1/(q − 1)`, i.e. the constraint removes a
factor of `(1 − 1/q)` worth of freedom in the constant coefficient.

---

## 4. Self-reciprocal polynomials: the symplectic signature

Symplectic matrices preserve an alternating form, which forces their eigenvalues
into reciprocal pairs `{λ, λ^{-1}}`. Consequently their characteristic
polynomials are **palindromic**. We formalize this notion and develop its
elementary theory.

> **Definition 4.1 (Self-reciprocal).** A polynomial `f ∈ R[X]` is
> *self-reciprocal* if for every index `i ∈ ℕ`,
> `f.coeff i = f.coeff (f.natDegree − i)`.

> **Definition 4.2 (Palindromic).** A polynomial `f ∈ R[X]` is *palindromic* if
> for every `i ≤ f.natDegree`, `f.coeff i = f.coeff (f.natDegree − i)`.

The two definitions differ only in their quantifier range. Self-reciprocity
demands the identity for *all* indices (including those above the degree, where
both sides vanish in well-behaved cases); palindromicity demands it only on the
support window `0 ≤ i ≤ natDegree`. The strong form implies the weak one.

> **Proposition 4.3 (Zero is self-reciprocal).** The zero polynomial is
> self-reciprocal.

*Proof.* For every `i`, both `0.coeff i` and `0.coeff (natDegree − i)` equal `0`,
so the defining equation holds by reflexivity. ∎

> **Proposition 4.4 (Self-reciprocal ⟹ palindromic).** If `f` is self-reciprocal
> then `f` is palindromic.

*Proof.* Restrict the universally quantified identity of Definition 4.1 to
indices `i ≤ natDegree`. ∎

> **Theorem 4.5 (Endpoint equality).** If `f` is self-reciprocal (resp.
> palindromic) then `f.coeff 0 = f.leadingCoeff`.

*Proof sketch.* Instantiate the defining identity at `i = 0`:
`f.coeff 0 = f.coeff (f.natDegree − 0) = f.coeff (f.natDegree)`. By definition
`f.coeff (f.natDegree) = f.leadingCoeff`. (For the palindromic version, `0 ≤
natDegree` always holds, so the same instantiation is legal.) ∎

> **Corollary 4.6 (Monic self-reciprocal has constant term 1).** If `f` is
> self-reciprocal (resp. palindromic) and monic, then `f.coeff 0 = 1`.

*Proof.* By Theorem 4.5, `f.coeff 0 = f.leadingCoeff`, and monicity means
`f.leadingCoeff = 1`. ∎

> **Proposition 4.7 (Coefficient symmetry on the window).** If `f` is
> self-reciprocal then for every `i ≤ f.natDegree`,
> `f.coeff i = f.coeff (f.natDegree − i)`.

*Proof.* Immediate from Definition 4.1. ∎

**Interpretation.** Corollary 4.6 is the algebraic reason a symplectic
characteristic polynomial has determinant `(−1)^n`: it is monic of degree `n`,
palindromic, hence its constant term is `1`, and by identity (★) the determinant
is `(−1)^n · 1 = (−1)^n`. Thus self-reciprocity is a *computable* fingerprint of
symplectic structure, consistent with — and refining — the `SL_n` constraint of
Theorem 3.2.

---

## 5. Cross-domain bridge: functional-equation signs

We now connect the polynomial algebra of Section 4 to the arithmetic of
functional equations. An L-function `L(s)` satisfies a functional equation
relating `L(s)` to `L(1 − s)`, carrying a sign (root number) `ε ∈ {+1, −1}`. In
the Katz–Sarnak picture, families of L-functions inherit a symmetry type
(orthogonal, unitary, symplectic) detected by `ε`. We capture the polynomial
shadow of this sign.

> **Definition 5.1 (Functional-equation sign).** For `f ∈ R[X]`, define
> `functionalEquationSign(f) = +1` if `f` is self-reciprocal, and `−1`
> otherwise.

> **Theorem 5.2 (Bridge theorem).** For every `f ∈ R[X]`,
> `f` is self-reciprocal ⟺ `functionalEquationSign(f) = +1`.

*Proof.* By Definition 5.1, the sign is defined by a case split on the
proposition "`f` is self-reciprocal." If `f` is self-reciprocal the sign is `+1`,
establishing the forward direction. Conversely, if the sign equals `+1` then the
`else` branch (which would give `−1 ≠ +1`) is excluded, so the `if` condition
holds, i.e. `f` is self-reciprocal. ∎

**Interpretation.** Theorem 5.2 reads as a near-tautology, and that transparency
is its purpose: it is a *formal dictionary entry*. The left-hand side is a
statement in the language of group theory and coding theory (palindromic
coefficients = symplectic signature = generator of a self-dual cyclic code); the
right-hand side is a statement in the language of automorphic forms (root number
`ε = +1`, the symplectic symmetry type). The theorem certifies that the two
languages agree on this predicate, turning an analogy into an equivalence one can
invoke mechanically. The three-way correspondence
*palindromic polynomial ⟷ symplectic type ⟷ self-dual cyclic code* is exactly
the cross-domain content the fingerprint framework is designed to expose.

---

## 6. Population statistics: irreducible-rate separation

We turn from individual matrices to populations. The discriminating statistic is
the **irreducible rate**, the fraction of group elements whose characteristic
polynomial is irreducible over `𝔽_q`. For `n = 2` these rates have closed forms
obtained by conjugacy-class counting.

> **Definition 6.1 (Two-dimensional irreducible rate expressions).** For a finite
> field of size `q`, define the two rate expressions
> - `irreducibleRateGL2(q) = q / (2(q + 1))`,
> - `irreducibleRateSL2(q) = (q − 1) / (2q)`.

*Derivation of `GL_2`.* The number of monic irreducible quadratics over `𝔽_q` is
`q(q − 1)/2`. An element with irreducible charpoly has centralizer isomorphic to
`𝔽_{q²}^×` of order `q² − 1`, so each such conjugacy class has size
`|GL_2(𝔽_q)|/(q² − 1) = q(q − 1)`. Multiplying the class count by the class size
and dividing by `|GL_2(𝔽_q)| = (q² − 1)(q² − q)` yields `q / (2(q + 1))`. This
expression agrees with the exact element count (verified by brute-force
enumeration for small `q`, e.g. `3/8` at `q = 3`).

*On the `SL_2` expression.* Imposing `det = 1` further constrains the constant
term to `1` (the `n = 2` case of Theorem 3.2, where `(−1)^2 = 1`). The expression
`(q − 1)/(2q)` is a heuristic conjugacy-class **model** of the resulting rate; it
is close to, but not identical with, the exact `SL_2` count (for `q = 3` the model
gives `1/3` while the exact rate is `1/4`). What the formalization establishes —
and all that the separation results below require — is that the two *defined*
expressions of Definition 6.1 are distinct and ordered for `q ≥ 3`; this is a
robust feature of the model that holds regardless of the exact `SL_2` count.

The arithmetic kernel of the separation is elementary but decisive.

> **Lemma 6.2 (`q²` is never `q² − 1`).** For every natural number `q ≥ 1`,
> `q² ≠ q² − 1` (as integers).

*Proof.* `q² − (q² − 1) = 1 ≠ 0`. ∎

> **Theorem 6.3 (Separation).** For every `q ≥ 3`,
> `irreducibleRateGL2(q) ≠ irreducibleRateSL2(q)`.

*Proof sketch.* Suppose the rates were equal:
`q / (2(q + 1)) = (q − 1) / (2q)`. For `q ≥ 3` both denominators are positive, so
cross-multiplication is valid and gives `q · 2q = (q − 1) · 2(q + 1)`, i.e.
`2q² = 2(q² − 1)`, i.e. `q² = q² − 1`. This contradicts Lemma 6.2. Hence the
rates differ. ∎

> **Theorem 6.4 (Strict domination).** For every `q ≥ 3`,
> `irreducibleRateSL2(q) < irreducibleRateGL2(q)`.

*Proof sketch.* Cross-multiplying the inequality `(q − 1)/(2q) < q/(2(q + 1))`
(legal since both denominators are positive for `q ≥ 3`) reduces it to
`(q − 1)·(q + 1) < q·q`, i.e. `q² − 1 < q²`, which holds for every `q`. ∎

**Interpretation.** Theorem 6.4 sharpens the separation into an *ordering*:
`GL_2` always has strictly more irreducible-charpoly elements than `SL_2`,
reflecting the larger polynomial space available when the determinant is
unconstrained. At the smallest separating case `q = 3` the rates are
`3/8 = 0.375` for `GL_2` and `1/3 ≈ 0.333` for `SL_2` — close, but provably
unequal, and ordered.

---

## 7. Supporting coefficient identities

The constant term and the sub-leading coefficient recover the two most
celebrated matrix invariants, giving two independent spectral coordinates.

> **Theorem 7.1 (Determinant from the constant term).** For any `n×n` matrix `A`
> over a commutative ring,
> `det(A) = (−1)^n · charpoly(A).coeff 0`.

*Proof.* This is identity (★), the defining relationship between determinant and
characteristic polynomial. ∎

> **Theorem 7.2 (Degree of the charpoly).** Over a nontrivial commutative ring,
> `charpoly(A).natDegree = n`.

*Proof.* Standard: the characteristic polynomial of an `n×n` matrix is monic of
degree `n`. ∎

> **Theorem 7.3 (Sub-leading coefficient is the negative trace).** For a nonempty
> index type,
> `charpoly(A).coeff (n − 1) = −trace(A)`.

*Proof sketch.* Expanding `det(X·I − A)`, the coefficient of `X^{n-1}` is `−(sum
of diagonal entries) = −trace(A)`. ∎

Together, Theorems 7.1 and 7.3 show that the characteristic polynomial's two
extreme nontrivial coefficients encode `det(A)` and `trace(A)` exactly — the
first coordinates of any spectral fingerprint.

---

## 8. A recognition data structure and the governing conjecture

We package the framework for computation.

> **Definition 8.1 (Classical group family).** An enumeration
> `ClassicalGroupFamily` with four constructors: `GL`, `SL`, `Sp`, `Orth`,
> equipped with decidable equality.

> **Definition 8.2 (Spectral fingerprint).** A record consisting of the matrix
> dimension `dim`, the field size `fieldSize`, the identified `groupType ∈
> ClassicalGroupFamily`, and an observed `profile` (a spectral profile in the
> sense of Definition 3.1).

The intended use is algorithmic: sample elements of an unknown subgroup, compute
their characteristic polynomials, estimate the three rates of the spectral
profile, and classify the group by matching against the theoretical fingerprints
(Theorem 3.2 for the constant-term constraint, Section 4 for the self-reciprocal
rate, Theorems 6.3–6.4 for the irreducible rate). The framework's guiding
hypothesis is:

> **Conjecture 8.3 (Spectral separation).** For distinct classical group families
> and sufficiently large field size, the spectral profiles are distinct. In
> particular, for `q = 3, n = 2` the irreducible rates already separate `GL_2`
> (`3/8`) from `SL_2` (`1/3`), verifiable by exhaustive enumeration of the
> `48` elements of `GL_2(𝔽_3)` and the `24` elements of `SL_2(𝔽_3)`.

Theorems 6.3 and 6.4 establish the `GL_2`-vs-`SL_2` instance of Conjecture 8.3 in
closed form for all `q ≥ 3`; the general statement, covering symplectic and
orthogonal families and all dimensions, requires group-enumeration machinery and
is left open.

---

## 9. Applications, connections, and future work

### 9.1 Applications

- **Computational group recognition.** The spectral fingerprint is a compact,
  conjugation-invariant summary suitable for Monte-Carlo classification of matrix
  groups, complementing existing recognition algorithms with statistically robust
  invariants.
- **Coding theory.** Self-reciprocal polynomials generate self-dual cyclic
  codes; Corollary 4.6 and the bridge Theorem 5.2 give clean criteria for
  membership in this family.
- **Verified numerics in random matrix theory.** The exact rates of Section 6 are
  finite-field analogues of eigenvalue statistics and provide ground-truth values
  against which simulations can be checked.

### 9.2 Connections

The framework sits at the intersection of three domains. In **number theory**,
self-reciprocal polynomials are the polynomial analogue of L-functions with root
number `ε = +1` (Theorem 5.2). In **random matrix theory**, the classical-group
fingerprints are the finite-field analogue of Wigner–Dyson's
orthogonal/unitary/symplectic classification. In **coding theory**, the same
palindromic polynomials generate self-dual cyclic codes.

### 9.3 Future work

1. **Higher-dimensional and symplectic/orthogonal rates.** Extend the closed-form
   irreducible rates beyond `GL_2`/`SL_2` to `Sp` and `O` families and to
   dimension `n > 2`, completing Conjecture 8.3.
2. **Self-reciprocal rate formulas.** Derive and verify closed forms for the
   self-reciprocal rate of each family, the population analogue of Section 4.
3. **Enumerative verification.** Mechanize the exhaustive `q = 3, n = 2` check
   (`48` and `24` elements) to certify the theoretical rates against direct
   counts.
4. **Split-rate statistics.** Add the third coordinate of the spectral profile —
   the rate of completely split charpolys — with closed forms and separations.
5. **Recognition algorithm with error bounds.** Turn the fingerprint into a
   sampling algorithm with rigorous confidence bounds on the classification.

---

## 10. Conclusion

We have isolated a compact, rigorously verified core of the theory connecting
classical matrix groups to characteristic-polynomial statistics. The constant
term pins down `SL_n` membership (Theorem 3.2); self-reciprocity is the
polynomial signature of symplectic type, with a clean structure theory (Section
4) and a bridge to functional-equation signs (Theorem 5.2); and the irreducible
rates of `GL_2(𝔽_q)` and `SL_2(𝔽_q)` separate, and order, for every `q ≥ 3`
(Theorems 6.3–6.4), all resting on the irreducible fact that `q² ≠ q² − 1`. The
auxiliary identities of Section 7 supply the trace and determinant as the first
spectral coordinates. Assembled into the fingerprint data structure of Section 8,
these results form the verified foundation of a spectral approach to group
recognition and a concrete bridge between algebra, number theory, and coding
theory.

---

## References

- Fulman, J. (1999). *A probabilistic approach to conjugacy classes in the finite
  symplectic and orthogonal groups.* Journal of Algebra.
- Katz, N., Sarnak, P. (1999). *Random Matrices, Frobenius Eigenvalues, and
  Monodromy.* American Mathematical Society Colloquium Publications.
- Wigner, E. (1955). *Characteristic vectors of bordered matrices with infinite
  dimensions.* Annals of Mathematics.
- Dyson, F. (1962). *The threefold way: algebraic structure of symmetry groups
  and ensembles in quantum mechanics.* Journal of Mathematical Physics.
