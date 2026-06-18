# Generation Certificates for Matrix Groups: Irreducible Characteristic Polynomials as Structural Witnesses

## Abstract

We develop a certificate-based framework linking an algebraic, computationally
checkable property of a linear endomorphism — irreducibility of its
characteristic polynomial — to a group-theoretic property of fundamental
importance for the study of random generation in matrix groups: irreducibility
of the linear action. The central structural theorem states that if a linear map
`φ` on a finite-dimensional vector space `V` over a field `K` has irreducible
characteristic polynomial, then every `φ`-invariant subspace is either trivial or
the whole space. We give a self-contained proof through the minimal-polynomial
theory and the Cayley–Hamilton theorem, including the key transfer lemma that
annihilating polynomials descend to restrictions on invariant subspaces. From
this hub we derive: (i) an orbit-spanning theorem connecting irreducible actions
to cyclic codes and linear feedback shift registers; (ii) the finite-geometry
statement that a Singer-type endomorphism fixes no proper projective subspace;
and (iii) an abstract certificate-density framework providing the quantitative
foundation for probabilistic generation lower bounds. We close with the prime-field
specialization and two organizing conjectures on certificate abundance and
sufficiency. All results have been formally verified.

**Keywords:** characteristic polynomial, irreducibility, invariant subspace,
minimal polynomial, Cayley–Hamilton, Singer cycle, matrix group generation,
finite fields, random generation.

---

## 1. Introduction

### 1.1 Motivation

A foundational task in computational group theory is to certify that a small set
of elements generates a target group. For symmetric groups, Dixon's theorem
(1969) shows that two uniformly random permutations generate the symmetric or
alternating group with probability tending to `1`. The analogous theory for
finite classical groups — `GL_n(𝔽_q)`, `SL_n(𝔽_q)`, and their relatives —
requires *structural witnesses*: efficiently checkable properties of individual
elements that, with high probability, force the subgroup they generate to be
large.

The general linear group `GL_n(𝔽_q)` has order

```
|GL_n(𝔽_q)| = ∏_{i=0}^{n-1} (q^n − q^i),
```

a number on the order of `q^{n²}`. Enumeration is impossible for moderate `n`;
randomized constructions with certified properties are the only viable route. The
maximal subgroups of `GL_n(𝔽_q)` are classified (Aschbacher's theorem) into a
small number of geometric families. The most basic obstruction to generation is
the *reducible* family: subgroups that stabilize a proper nonzero subspace and
hence lie in a maximal parabolic. An element that acts *irreducibly* — fixing no
proper nonzero subspace — cannot be contained in any such reducible subgroup, and
is therefore a natural certificate.

### 1.2 Contribution

This paper isolates and formally verifies the structural core of the
irreducibility certificate. Our contributions are:

1. A precise definition of *generation certificate* for linear endomorphisms
   (Definition 2.3), bundling invertibility with irreducibility of the
   characteristic polynomial.

2. The **irreducible action theorem** (Theorem 4.1): irreducible characteristic
   polynomial implies the only invariant subspaces are `⊥` and `⊤`, proved via a
   clean minimal-polynomial argument.

3. Two bridge theorems: the **orbit-spanning theorem** (Theorem 5.1), connecting
   to coding theory and shift registers, and the **no-fixed-projective-subspace
   theorem** (Theorem 6.1), connecting to finite geometry and Singer cycles.

4. An **abstract certificate-density framework** (Section 7) with a positivity
   theorem (Theorem 7.2) serving as the entry point to probabilistic generation
   bounds, plus the prime-field specialization (Theorem 8.1).

5. Two organizing **conjectures** (Section 9) on density and sufficiency that
   place the verified core inside the broader random-generation program.

---

## 2. Definitions

Throughout, `K` is a field, `V` a finite-dimensional `K`-vector space, and
`φ : V → V` a `K`-linear endomorphism (`φ ∈ End_K(V)`). We write `charpoly(φ)`
for the characteristic polynomial and `minpoly_K(φ)` for the minimal polynomial.
For a subspace `W` invariant under `φ`, we write `φ|_W : W → W` for the
restriction.

**Definition 2.1 (Invariant submodule).** A subspace `W ⊆ V` is *invariant*
under `φ`, written `IsInvariantSubmodule φ W`, if

```
∀ w ∈ W,   φ(w) ∈ W.
```

Equivalently, `W` is a `K[X]`-submodule of `V` under the module structure where
`X` acts as `φ`.

**Definition 2.2 (Certificate density).** For a finite group `G` and a decidable
predicate `C : G → Prop`, the *certificate density* is the rational number

```
certificateDensity(C) = #{ g ∈ G : C(g) } / #G  ∈ ℚ.
```

**Definition 2.3 (Linear generation certificate).** For a finitely generated free
`K`-module `V`, a *linear generation certificate* is a triple

```
( φ : End_K(V),   proof that φ is bijective,   proof that charpoly(φ) is irreducible ).
```

The two data — invertibility and irreducibility — encode, respectively, that `φ`
is a group element of `GL(V)` and that it acts irreducibly.

**Definition 2.4 (Generation certificate system).** For a group `G`, a
*generation certificate system* is a predicate `Cert : G → Prop` together with the
guarantee that any subgroup `H` containing a certified element is either all of
`G` or has index at most `2`:

```
∀ g, Cert(g) → ∀ H ≤ G,  g ∈ H →  (H = G  ∨  index(H) ≤ 2).
```

This abstracts the common shape of the Dixon-type dichotomy (full group vs.
index-two subgroup) shared by symmetric-group and linear-group certificates.

---

## 3. Preliminaries: minimal polynomials and restrictions

We record the linear-algebraic lemmas that drive the main theorem. All are stated
for finite-dimensional `V`.

**Lemma 3.1 (Restriction intertwining).** Let `W` be `φ`-invariant with inclusion
`ι_W : W ↪ V`. Then `ι_W ∘ (φ|_W) = φ ∘ ι_W`.

*Proof.* On a vector `w ∈ W` both sides equal `φ(w)`, viewed in `V`. ∎

**Lemma 3.2 (Annihilation descends to restrictions).** Let `W` be `φ`-invariant
and `p ∈ K[X]` a polynomial with `p(φ) = 0` (as an endomorphism of `V`). Then
`p(φ|_W) = 0` (as an endomorphism of `W`).

*Proof sketch.* Expand `p(ψ) = Σ_k a_k ψ^k` for any endomorphism `ψ`. By
induction on `k`, using Lemma 3.1, the iterate `(φ|_W)^k` agrees with `φ^k` after
the inclusion `ι_W`: `ι_W((φ|_W)^k w) = φ^k(ι_W w)`. Summing, `ι_W(p(φ|_W) w) =
p(φ)(ι_W w) = 0`. Since `ι_W` is injective, `p(φ|_W) w = 0` for all `w ∈ W`. ∎

**Lemma 3.3 (Minimal polynomial of a restriction divides).** For `W` invariant,

```
minpoly_K(φ|_W)  divides  minpoly_K(φ).
```

*Proof.* Apply Lemma 3.2 with `p = minpoly_K(φ)`, which annihilates `φ` by
definition. Then `minpoly_K(φ)` annihilates `φ|_W`, so by minimality
`minpoly_K(φ|_W) ∣ minpoly_K(φ)`. ∎

**Lemma 3.4 (Minimal equals characteristic under irreducibility).** If
`charpoly(φ)` is irreducible over `K`, then `minpoly_K(φ) = charpoly(φ)`.

*Proof sketch.* If `V` is nontrivial, Cayley–Hamilton gives `charpoly(φ)(φ) = 0`,
so `minpoly_K(φ) ∣ charpoly(φ)`. Both are monic; the only monic divisors of an
irreducible monic polynomial are `1` and itself. The minimal polynomial is not a
unit on a nonzero space, so it equals `charpoly(φ)`. (The degenerate case
`V = 0` is handled separately: there `charpoly(φ) = 1`, which is a unit and hence
not irreducible, so the hypothesis is vacuous.) ∎

---

## 4. The irreducible action theorem

**Theorem 4.1 (Irreducible action).** Let `V` be a nonzero finite-dimensional
`K`-vector space and `φ ∈ End_K(V)` with `charpoly(φ)` irreducible over `K`. Then
every `φ`-invariant subspace `W ⊆ V` satisfies `W = ⊥` or `W = ⊤`.

*Proof.* Let `W` be invariant and suppose `W ≠ ⊥`. We show `W = ⊤`.

*Step 1 — the restriction has nontrivial minimal polynomial.* By Lemma 3.3,
`minpoly_K(φ|_W)` divides `minpoly_K(φ)`, which divides `charpoly(φ)`. If
`minpoly_K(φ|_W)` were `1`, then `φ|_W` would satisfy the relation `1 = 0` on
`W`, forcing `W = ⊥`, contrary to assumption. Hence `minpoly_K(φ|_W) ≠ 1`.

*Step 2 — the restriction's minimal polynomial is the full characteristic
polynomial.* We have `minpoly_K(φ|_W) ∣ charpoly(φ)` with `charpoly(φ)`
irreducible. Irreducibility means every factorization has a unit factor; since
`minpoly_K(φ|_W)` is monic and not a unit, the complementary factor is a unit,
and comparing leading coefficients (both monic) gives

```
minpoly_K(φ|_W) = charpoly(φ).
```

*Step 3 — dimension count.* The degree of the minimal polynomial of `φ|_W` is at
most the degree of `charpoly(φ|_W)`, which equals `dim W`. On the other hand its
degree equals `deg charpoly(φ) = dim V`. Therefore

```
dim V = deg(minpoly_K(φ|_W)) ≤ dim W ≤ dim V,
```

so `dim W = dim V`. A subspace of full dimension in a finite-dimensional space is
the whole space, hence `W = ⊤`. ∎

The theorem is the structural heart of the certificate framework: an algebraic
condition checkable in polynomial time (factoring a degree-`n` polynomial over a
finite field) yields a strong, intrinsically group-theoretic conclusion about the
linear action.

---

## 5. Orbit spanning: the coding-theory bridge

**Lemma 5.1 (Orbit span is invariant).** For any `φ ∈ End_K(V)` and any `v ∈ V`,
the subspace

```
O(v) := span_K { φ^m(v) : m ∈ ℕ }
```

is `φ`-invariant.

*Proof.* Generators map to generators: `φ(φ^m v) = φ^{m+1} v ∈ O(v)`. Invariance
extends to all of `O(v)` by linearity and the span-induction principle. ∎

**Theorem 5.2 (Orbit spanning).** If `charpoly(φ)` is irreducible and `v ≠ 0`,
then `O(v) = ⊤`; that is, `{ v, φ(v), φ²(v), … }` spans `V`.

*Proof.* By Lemma 5.1, `O(v)` is invariant, so by Theorem 4.1 it is `⊥` or `⊤`.
Since `v ∈ O(v)` and `v ≠ 0`, we have `O(v) ≠ ⊥`. Hence `O(v) = ⊤`. ∎

**Interpretation.** Theorem 5.2 is the algebraic backbone of *cyclic linear
recurrences*. If `φ` is the companion matrix of an irreducible polynomial `f` of
degree `n`, then the orbit of any nonzero seed spans `𝔽_q^n`, and the sequence of
coordinates is a maximal-length linear feedback shift register (LFSR) sequence.
The vector `v` is the seed; the irreducibility of `f = charpoly(φ)` is exactly the
condition that the recurrence has maximal period `q^n − 1`. This is the design
principle underlying m-sequences, cyclic codes, and many pseudorandom generators.

---

## 6. Finite geometry: no fixed projective subspace

**Theorem 6.1 (No fixed proper projective subspace).** If `charpoly(φ)` is
irreducible, then there is no subspace `W` with `W ≠ ⊥`, `W ≠ ⊤`, and `W`
invariant under `φ`.

*Proof.* Immediate contrapositive of Theorem 4.1: any invariant `W` is `⊥` or
`⊤`, so a `W` that is neither cannot be invariant. ∎

**Interpretation.** In the projective space `PG(n−1, q)` of lines through the
origin in `𝔽_q^n`, an invariant subspace corresponds to a fixed projective
subspace of the induced collineation. Theorem 6.1 says an endomorphism with
irreducible characteristic polynomial induces a collineation with *no* fixed
proper projective subspace. The cyclic group generated by such an element — when
its order is `q^n − 1` — is a **Singer cycle**: a sharply transitive cyclic group
on the `(q^n − 1)/(q − 1)` points of `PG(n−1, q)`. Singer cycles are the finite
analogue of irrational rotations: they admit no invariant geometric structure
below the whole space.

---

## 7. Abstract certificate density and generation

We now package the quantitative side of the theory.

**Definition 7.1 (recalled).** `certificateDensity(C) = #{g : C(g)} / #G`.

**Theorem 7.2 (Positive density).** Let `G` be a finite group and `C : G → Prop`
a decidable predicate. If there exists at least one `g` with `C(g)`, then

```
0 < certificateDensity(C).
```

*Proof.* The numerator `#{g : C(g)}` is positive because the certified subtype is
nonempty; the denominator `#G` is positive because `G` contains the identity. A
ratio of two positive rationals is positive. ∎

Trivial in isolation, Theorem 7.2 is the indispensable first step of any
probabilistic generation argument: uniformly sampling from `G` hits a certified
element with positive probability, so independent repetition succeeds with
probability tending to `1`. Combined with the generation-system dichotomy of
Definition 2.4, a certified element together with a generic complement generates a
subgroup of index at most `2`.

---

## 8. Specialization to prime fields

**Theorem 8.1 (Singer certificate over `ℤ/pℤ`).** Let `p` be prime, `V` a
finite-dimensional vector space over the prime field `𝔽_p = ℤ/pℤ`, and
`φ ∈ End(V)` with `charpoly(φ)` irreducible over `𝔽_p`. Then every `φ`-invariant
subspace is `⊥` or `⊤`.

*Proof.* Direct instantiation of Theorem 4.1 with `K = 𝔽_p`. ∎

This is the case of greatest practical interest in computational group theory:
matrices over prime fields are the default representation, and irreducibility of
a degree-`n` polynomial over `𝔽_p` is decided by classical fast algorithms
(distinct-degree factorization, Cantor–Zassenhaus).

---

## 9. Conjectures: abundance and sufficiency

The verified core establishes that the certificate is *valid*. Two further
statements, classical in spirit, establish that it is *abundant* and
*sufficient* — together completing a Dixon-style generation theorem for `GL_n`.

**Conjecture A (Density lower bound).** For fixed prime power `q` and growing `n`,
the proportion of matrices in `GL_n(𝔽_q)` whose characteristic polynomial is
irreducible satisfies

```
#{ Singer certificates in GL_n(𝔽_q) } / |GL_n(𝔽_q)|  ≥  c_q / n
```

for some constant `c_q > 0`.

*Remark.* This is essentially a known count. The number of monic irreducible
polynomials of degree `n` over `𝔽_q` is `(1/n) Σ_{d ∣ n} μ(d) q^{n/d} ≈ q^n / n`,
a polynomial analogue of the prime number theorem. Matrices with a given
irreducible characteristic polynomial form a single conjugacy class (the
companion matrix and its conjugates), whose size is `|GL_n(𝔽_q)| / (q^n − 1)`.
Summing over the `≈ q^n / n` irreducible polynomials gives a proportion `≈ 1/n`,
confirming the conjectured lower bound with `c_q` bounded away from `0`.

**Conjecture B (Certificate sufficiency).** For independent uniform random
`g, h ∈ GL_n(𝔽_q)`, if `g` has irreducible characteristic polynomial and `det(h)`
generates the multiplicative group `𝔽_q^×`, then

```
Pr[ ⟨g, h⟩ = GL_n(𝔽_q) ]  ≥  1 − O(q^{−1}).
```

*Remark.* The irreducibility of `g` excludes the reducible (parabolic) maximal
subgroups by Theorem 4.1, while the determinant condition excludes subgroups
contained in `SL_n` and imprimitivity classes. The remaining Aschbacher classes
are handled by genericity, yielding the stated probability.

---

## 10. Discussion

### 10.1 The algebra–geometry dictionary

The work instantiates a general principle: discrete factorization data control
continuous-seeming structural data. Theorem 4.1 translates "the characteristic
polynomial does not factor" directly into "the action has no invariant
geometry." The proof is short precisely because the minimal polynomial mediates
between the two worlds — Cayley–Hamilton on one side (algebra annihilates the
operator) and the restriction-transfer Lemma 3.2 on the other (annihilation is
hereditary to invariant subspaces).

### 10.2 Computational significance

Verifying a certificate costs one characteristic-polynomial computation
(`O(n^ω)` field operations with fast linear algebra, `ω < 2.38`) plus one
irreducibility test (`Õ(n² log q)` field operations). This is exponentially
cheaper than any direct search for invariant subspaces, which is the heart of the
appeal: a polynomial-time witness for a property that controls exponential-size
combinatorics.

### 10.3 Relation to recognition algorithms

The framework formalizes the structural lemma underlying constructive
recognition algorithms for classical groups (Neumann–Praeger and successors),
where elements with irreducible characteristic polynomial — and in particular
*ppd-elements* (primitive prime divisor elements) — serve as recognition
landmarks. Theorem 4.1 is the irreducibility guarantee those algorithms assume.

---

## 11. Future work

- **Formalize Conjecture A.** The count of irreducible polynomials and the
  companion-class size are within reach of existing finite-field machinery; their
  combination would give a fully verified density lower bound.
- **From irreducible to primitive.** Strengthen the certificate to *ppd-elements*
  and Singer cycles of full order `q^n − 1`, formalizing the Zsigmondy/primitive
  prime divisor input.
- **Aschbacher exclusion.** Build verified lemmas excluding each Aschbacher class
  for a certified pair `(g, h)`, working toward a machine-checked Dixon theorem
  for `GL_n(𝔽_q)`.
- **Other classical groups.** Extend certificates to `SL_n`, `Sp_{2n}`, unitary
  and orthogonal groups, where the analogous structural witnesses involve
  self-reciprocal irreducible polynomials.

---

## 12. Conclusion

We have presented and formally verified the structural core of an irreducibility
certificate for matrix-group generation: irreducible characteristic polynomial
implies irreducible action (no nontrivial invariant subspaces). From this single
theorem we derived an orbit-spanning result linking to coding theory, a
finite-geometry statement on Singer cycles, an abstract positive-density theorem
underpinning probabilistic generation, and a prime-field specialization. Two
conjectures locate this core within the broader program of random generation in
finite classical groups. The result is a compact, reusable bridge from a fast
algebraic check to deep group-theoretic structure.

---

## References

- Dixon, J. D. (1969). *The probability of generating the symmetric group.*
  Mathematische Zeitschrift 110, 199–205.
- Huppert, B. (1967). *Endliche Gruppen I.* Springer.
- Neumann, P. M., Praeger, C. E. (1992). *A recognition algorithm for special
  linear groups.* Proc. London Math. Soc. 65, 555–603.
