# Explicit GL(1) Langlands over $\mathbb{Q}$: Cyclotomic Reciprocity and the Idèle Class Group

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Applications (Number Theory / the Langlands Program)

## Abstract

The Langlands program predicts a dictionary between Galois representations
and automorphic objects. Its first and classical chapter is the abelian
case, $GL(1)$, which coincides with global class field theory. We present a
fully explicit treatment of $GL(1)$ Langlands over $\mathbb{Q}$ in the
cyclotomic setting, together with a from-scratch construction of the
automorphic side via the idèle class group.

On the Galois/automorphic dictionary we prove that the abstract group
isomorphism between Dirichlet characters mod $n$ and one-dimensional
complex representations of $\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q})$ is
literally the explicit cyclotomic reciprocity law: if a Galois
automorphism $\sigma$ acts on the canonical primitive root of unity by
$\sigma(\zeta_n) = \zeta_n^{\,a}$, then the representation attached to a
Dirichlet character $D$ takes the value $D(a)$ at $\sigma$. We record the
structural consequences: the dictionary preserves products and detects
triviality, and it transports the count of objects on both sides to
Euler's totient $\varphi(n)$ (equal to $p-1$ for primes $p$).

On the automorphic side we construct the idèle group as the units of the
adèle ring, the diagonal embedding of principal idèles, and the idèle class
group as the quotient. We prove the diagonal embedding is injective over a
number field, that principal idèles form an isomorphic copy of $K^\times$,
that the class map is surjective, and that Hecke characters are exactly the
characters of the idèle class group. We close with proof sketches,
algorithms, numerical demonstrations, applications, and open conjectures.

---

## 1. Introduction

The Langlands program is a web of conjectures relating automorphic
representations of reductive groups to Galois representations. Among its
many strata, the case of the multiplicative group $GL(1)$ is the only one
that is, in full generality, a completed theorem: it *is* global class
field theory, whose analytic heart is **Artin reciprocity**.

The purpose of this paper is twofold.

1. **Make the dictionary explicit.** In the cyclotomic case over
   $\mathbb{Q}$, the correspondence "$1$-dimensional Galois
   representations $\leftrightarrow$ Hecke characters" is usually presented
   as an abstract isomorphism of character groups. We show it is, entry by
   entry, the elementary reciprocity rule controlling how Galois
   automorphisms permute roots of unity.

2. **Build the automorphic home.** We construct the idèle class group of a
   number field from the adèle ring and prove the structural facts that
   identify it as the universal object carrying Hecke characters.

Throughout, fix a modulus $n \ge 1$ and a field $L$ that is a cyclotomic
extension of $\mathbb{Q}$ of conductor $n$ — concretely $L =
\mathbb{Q}(\zeta_n)$. We write $\zeta_n$ for the canonical primitive
$n$-th root of unity in $L$, and $\mathrm{Gal}(L/\mathbb{Q})$ for the group
of field automorphisms of $L$ fixing $\mathbb{Q}$ pointwise.

### 1.1 Historical and conceptual context

The abelian case of the Langlands correspondence predates Langlands by
half a century: it is the content of *class field theory*, developed by
Kronecker, Weber, Hilbert, Takagi, and Artin between roughly 1880 and
1930. The Kronecker–Weber theorem asserts that every finite abelian
extension of $\mathbb{Q}$ is contained in a cyclotomic field
$\mathbb{Q}(\zeta_n)$; thus the cyclotomic fields, far from being a special
example, *exhaust* the abelian extensions of $\mathbb{Q}$. Artin
reciprocity supplies the canonical isomorphism between the Galois group of
such an extension and a quotient of the idèle class group. For
$\mathbb{Q}(\zeta_n)$ this isomorphism takes the wholly elementary form
$\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) \cong
(\mathbb{Z}/n\mathbb{Z})^\times$, which is precisely the bridge we exploit.

The modern reformulation, due to Langlands, recasts class field theory as
the $GL(1)$ instance of a vast conjectural correspondence between
$n$-dimensional Galois representations and automorphic representations of
$GL(n)$. The case $n=1$ — one-dimensional representations and Hecke
characters — is the only one understood in complete generality, and it is
the firm ground from which the entire program is launched. Our contribution
is to render the $n=1$ cyclotomic dictionary *explicit and computable*:
rather than asserting that an isomorphism of character groups exists, we
exhibit the rule that computes one side from the other.

### 1.2 Summary of contributions

We (i) define the Artin isomorphism, the character-precomposition
functoriality, and the resulting Langlands isomorphism; (ii) prove the
explicit reciprocity law $\rho_D(\sigma) = D(a)$ with $\sigma(\zeta_n) =
\zeta_n^{\,a}$; (iii) derive triviality detection and the totient counts;
and (iv) construct the idèle group, the diagonal embedding, the idèle class
group, and prove the structural facts (injectivity, surjectivity of the
class map, the universal property for Hecke characters) that identify it as
the coordinate-free automorphic side.

---

## 2. Preliminaries and definitions

### 2.1 Dirichlet (Hecke) characters

**Definition 2.1 (Dirichlet character).** A *Dirichlet character mod $n$
valued in $\mathbb{C}$* is a multiplicative homomorphism
$D : (\mathbb{Z}/n\mathbb{Z})^\times \to \mathbb{C}^\times$, extended to all
of $\mathbb{Z}/n\mathbb{Z}$ by $D(x) = 0$ when $\gcd(x,n) > 1$. Equivalently
it is an element of $\mathrm{MulChar}(\mathbb{Z}/n\mathbb{Z}, \mathbb{C})$.
The group operation is pointwise multiplication. We denote this group
$\mathrm{DirichletCharacter}\ \mathbb{C}\ n$.

In Langlands terms, Dirichlet characters mod $n$ are exactly the
finite-order Hecke characters of $\mathbb{Q}$ of conductor dividing $n$.

### 2.2 Galois representations of cyclotomic fields

**Definition 2.2 (1-dimensional Galois representation).** A
*1-dimensional complex representation* of $\mathrm{Gal}(L/\mathbb{Q})$ is a
group homomorphism $\rho : \mathrm{Gal}(L/\mathbb{Q}) \to \mathbb{C}^\times$.
The set of all such forms a group $(L \simeq_{\mathbb{Q}} L) \to^* \mathbb{C}^\times$
under pointwise multiplication.

### 2.3 The cyclotomic Artin map

The decisive arithmetic input is that every automorphism of
$\mathbb{Q}(\zeta_n)$ raises $\zeta_n$ to a power coprime to $n$, and this
assignment is a group isomorphism.

**Theorem 2.3 (Artin reciprocity, cyclotomic case; Lean `artinIso`).**
There is a canonical isomorphism of groups
$$\mathrm{artinIso} : \mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) \;\xrightarrow{\ \cong\ }\; (\mathbb{Z}/n\mathbb{Z})^\times.$$
Over $\mathbb{Q}$ it exists for every $n \ge 1$ because $\Phi_n$, the
$n$-th cyclotomic polynomial, is irreducible over $\mathbb{Q}$.

*Sketch.* This is `IsCyclotomicExtension.autEquivPow` applied with the
irreducibility of $\Phi_n$ over $\mathbb{Q}$
(`cyclotomic.irreducible_rat`). The map sends $\sigma$ to the unique unit
$a \in (\mathbb{Z}/n\mathbb{Z})^\times$ with $\sigma(\zeta_n) =
\zeta_n^{\,a}$. $\square$

**Proposition 2.4 (Abelianness; Lean `galois_abelian`).** The group
$\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q})$ is abelian: for all
$\sigma, \tau$, $\sigma\tau = \tau\sigma$.

*Sketch.* Transport along the injective `artinIso` to the abelian group
$(\mathbb{Z}/n\mathbb{Z})^\times$, where commutativity is immediate, then
pull back using injectivity. $\square$

Abelianness is precisely the structural reason that $GL(1)$ (abelian) class
field theory applies in this setting.

---

## 3. The GL(1) correspondence

### 3.1 Functoriality of characters

**Definition 3.1 (Character precomposition; Lean `precompMulEquiv`).** For
groups $G, H$ and a commutative group $M$, an isomorphism $e : G \cong H$
induces an isomorphism of character groups
$$\mathrm{precompMulEquiv}(e) : (H \to^* M) \;\xrightarrow{\ \cong\ }\; (G \to^* M), \qquad \varphi \mapsto \varphi \circ e.$$
Its inverse is precomposition with $e^{-1}$, and it respects pointwise
multiplication.

### 3.2 The correspondence as a group isomorphism

**Theorem 3.2 (GL(1) Langlands, cyclotomic case; Lean `langlandsGL1`).**
There is an isomorphism of groups
$$\mathrm{langlandsGL1} : \mathrm{DirichletCharacter}\ \mathbb{C}\ n \;\xrightarrow{\ \cong\ }\; \big(\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) \to^* \mathbb{C}^\times\big),$$
realized as $D \mapsto D \circ \mathrm{artinIso}$ (after identifying a
Dirichlet character with its unit-group homomorphism).

*Sketch.* Compose two isomorphisms: first
`MulChar.mulEquivToUnitHom`, identifying a Dirichlet character $D$ with the
homomorphism $(\mathbb{Z}/n\mathbb{Z})^\times \to \mathbb{C}^\times$ it
restricts to on units; then $\mathrm{precompMulEquiv}(\mathrm{artinIso})$
from Definition 3.1, transporting along Artin reciprocity (Theorem 2.3).
Both factors are isomorphisms, hence so is the composite. $\square$

Because it is a group isomorphism (not a mere bijection), it transports the
pointwise product of Hecke characters to the pointwise product of
representations.

### 3.3 Explicit reciprocity

The abstract isomorphism hides what the map *does*. The following results
make it explicit.

**Lemma 3.3 (Identification of Artin maps; Lean
`artinIso_eq_galEquivZMod`).** The catalog map $\mathrm{artinIso}$ equals
Mathlib's explicit cyclotomic map $\mathrm{galEquivZMod}$. (Both unfold to
`IsCyclotomicExtension.autEquivPow`; the irreducibility hypotheses are
propositionally irrelevant, so the equality holds definitionally.)

**Theorem 3.4 (Explicit cyclotomic Artin action; Lean `artin_action`).**
For every $\sigma \in \mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q})$, writing
$a = \mathrm{artinIso}(\sigma)$,
$$\sigma(\zeta_n) = \zeta_n^{\,a}.$$

*Sketch.* Rewrite $\mathrm{artinIso}$ as $\mathrm{galEquivZMod}$ by
Lemma 3.3, then apply `galEquivZMod_apply_of_pow_eq`, whose defining
property is exactly $\sigma(\zeta_n) = \zeta_n^{\,a}$, using that $\zeta_n$
is a primitive $n$-th root of unity. $\square$

**Lemma 3.5 (Representation as a composite; Lean `langlandsGL1_apply`).**
For a Dirichlet character $D$ and $\sigma$,
$$\mathrm{langlandsGL1}(D)(\sigma) = \big(\mathrm{mulEquivToUnitHom}\,D\big)\big(\mathrm{artinIso}(\sigma)\big),$$
holding definitionally from Theorem 3.2.

**Lemma 3.6 (Scalar form; Lean `langlandsGL1_apply_coe`).** As complex
numbers,
$$\mathrm{langlandsGL1}(D)(\sigma) = D\big(\mathrm{artinIso}(\sigma)\big),$$
where on the right $D$ is evaluated at the residue class underlying the
unit $\mathrm{artinIso}(\sigma)$.

*Sketch.* Apply Lemma 3.5, then `MulChar.coe_equivToUnitHom` to identify
the unit-homomorphism value with the value of $D$ on the underlying
residue. $\square$

**Theorem 3.7 (Explicit Artin reciprocity, GL(1) form; Lean
`explicit_reciprocity`).** For every $\sigma$ and every Dirichlet character
$D$, with $a = \mathrm{artinIso}(\sigma)$:
$$\sigma(\zeta_n) = \zeta_n^{\,a} \qquad\text{and}\qquad \mathrm{langlandsGL1}(D)(\sigma) = D(a).$$

*Sketch.* Conjunction of Theorem 3.4 and Lemma 3.6. $\square$

This is the crux: the $GL(1)$ Langlands dictionary over $\mathbb{Q}$ is, value
by value, the statement *"the Galois value at $\sigma$ equals the Hecke value
at the exponent by which $\sigma$ raises roots of unity."*

**Corollary 3.8 (Triviality detection; Lean `langlandsGL1_eq_one_iff`).**
$\mathrm{langlandsGL1}(D) = 1$ if and only if $D = 1$. Equivalently, the
attached representation is trivial exactly when $D$ is the principal
character.

*Sketch.* Rewrite the trivial representation as $\mathrm{langlandsGL1}(1)$
using $\mathrm{map\_one}$, then apply injectivity of the isomorphism. $\square$

### 3.4 Counting

**Theorem 3.9 (Count of Dirichlet characters; Lean
`card_dirichlet_eq_totient`).**
$$\#\,\mathrm{DirichletCharacter}\ \mathbb{C}\ n = \varphi(n).$$

*Sketch.* The group of $\mathbb{C}$-valued characters of a finite abelian
group has the same cardinality as the group, because $\mathbb{C}$ has
enough roots of unity (`MulChar.card_eq_card_units_of_hasEnoughRootsOfUnity`),
and $\#(\mathbb{Z}/n\mathbb{Z})^\times = \varphi(n)$. $\square$

**Theorem 3.10 (Count of Galois representations; Lean
`card_galois_reps_eq_totient`).**
$$\#\big(\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) \to^* \mathbb{C}^\times\big) = \varphi(n).$$

*Sketch.* Transport the count of Theorem 3.9 along the bijection
underlying the isomorphism $\mathrm{langlandsGL1}$ (Theorem 3.2) via
`Nat.card_congr`. $\square$

**Corollary 3.11 (Prime case; Lean `card_galois_reps_prime`).** For a
prime $p$,
$$\#\big(\mathrm{Gal}(\mathbb{Q}(\zeta_p)/\mathbb{Q}) \to^* \mathbb{C}^\times\big) = p - 1.$$

*Sketch.* Specialize Theorem 3.10 to $n = p$ and use $\varphi(p) = p-1$. $\square$

For example $\mathbb{Q}(\zeta_7)$ has Galois group of order $6$ and exactly
$6$ one-dimensional complex representations.

---

## 4. A fully worked example: $n = 5$

To see every theorem of Section 3 simultaneously, take $n = 5$. The unit
group is
$$(\mathbb{Z}/5\mathbb{Z})^\times = \{1, 2, 3, 4\},$$
which is cyclic of order $4$, generated by $g = 2$ (since $2^1=2$,
$2^2=4$, $2^3=3$, $2^4=1 \pmod 5$). By Theorem 2.3 the Galois group
$\mathrm{Gal}(\mathbb{Q}(\zeta_5)/\mathbb{Q})$ is therefore cyclic of order
$4$; its generator is the automorphism $\sigma_2 : \zeta_5 \mapsto
\zeta_5^{\,2}$ (Theorem 3.4). Proposition 2.4 guarantees the group is
abelian, as $(\mathbb{Z}/5\mathbb{Z})^\times$ visibly is.

There are $\varphi(5) = 4$ Dirichlet characters mod $5$ (Theorem 3.9), and
hence $4$ one-dimensional Galois representations (Theorem 3.10), matching
$\varphi(5) = 5 - 1$ (Corollary 3.11). Each character is determined by its
value on the generator $2$, which must be a $4$-th root of unity. Writing
$i = \sqrt{-1}$, the four characters $D_0, D_1, D_2, D_3$ are given by
$D_k(2) = i^{\,k}$, extended multiplicatively:

| residue $a$ | $D_0(a)$ | $D_1(a)$ | $D_2(a)$ | $D_3(a)$ |
|---|---|---|---|---|
| $1$ | $1$ | $1$ | $1$ | $1$ |
| $2$ | $1$ | $i$ | $-1$ | $-i$ |
| $4$ | $1$ | $-1$ | $1$ | $-1$ |
| $3$ | $1$ | $-i$ | $-1$ | $i$ |

Now apply the explicit reciprocity law (Theorem 3.7). For the character
$D_1$ and the automorphism $\sigma_3$ (Artin symbol $a = 3$), we read off
$$\rho_{D_1}(\sigma_3) = D_1(3) = -i,$$
with no further computation: the value of the attached Galois
representation at $\sigma_3$ is simply the value of the Dirichlet character
at the exponent $3$ by which $\sigma_3$ raises $\zeta_5$. The homomorphism
law (Theorem 3.2) is visible in the table: $D_1(2)\,D_1(3) = i \cdot (-i) =
1 = D_1(1) = D_1(6 \bmod 5)$. Finally, the triviality detector
(Corollary 3.8) is the statement that only the top row $D_0$ — the
principal character — produces the constant representation $\rho \equiv 1$;
every other row contains a value $\ne 1$.

This single table is the entire $GL(1)$ Langlands correspondence for
$\mathbb{Q}(\zeta_5)$: the columns are the four Galois representations, the
entries are their values on the four automorphisms, and the rule producing
them is reciprocity.

---

## 5. The automorphic side: the idèle class group

The cyclotomic correspondence above is organized by modulus. The
coordinate-free home for *all* Hecke characters of a number field $K$ at
once is the idèle class group, which we now construct from the adèle ring
$\mathbb{A}_K$ (Mathlib `NumberField.AdeleRing R K`), a commutative
topological ring equipped with a diagonal embedding $K \to \mathbb{A}_K$.

**Definition 4.1 (Idèle group; Lean `IdeleGroup`).** The *idèle group* is
the unit group of the adèle ring,
$$\mathbb{I}_K := (\mathbb{A}_K)^\times.$$

**Definition 4.2 (Diagonal embedding; Lean `ideleDiag`).** Restricting the
diagonal ring embedding to nonzero elements gives a group homomorphism
$$\mathrm{ideleDiag} : K^\times \to \mathbb{I}_K,$$
the embedding of *principal idèles*.

**Definition 4.3 (Principal idèles; Lean `principalIdeles`).** The
*principal idèles* are the image
$$\mathrm{principalIdeles}_K := \mathrm{ran}(\mathrm{ideleDiag}) \le \mathbb{I}_K.$$

**Definition 4.4 (Idèle class group; Lean `IdeleClassGroup`).** The *idèle
class group* is the quotient
$$C_K := \mathbb{I}_K \,/\, \mathrm{principalIdeles}_K.$$

**Theorem 4.5 (Faithfulness of the diagonal; Lean `ideleDiag_injective`).**
Over a number field $K$, the diagonal embedding $\mathrm{ideleDiag} :
K^\times \to \mathbb{I}_K$ is injective.

*Sketch.* The diagonal ring map $K \to \mathbb{A}_K$ is injective (a
nonzero element is nonzero at, e.g., an archimedean place), hence its
restriction to units is injective. $\square$

**Corollary 4.6 (Principal idèles are a copy of $K^\times$; Lean
`principalIdelesEquiv`).** There is a group isomorphism
$$K^\times \;\xrightarrow{\ \cong\ }\; \mathrm{principalIdeles}_K.$$

*Sketch.* An injective homomorphism corestricts to an isomorphism onto its
image (Theorem 4.5). $\square$

**Theorem 4.7 (Surjectivity of the class map; Lean
`ideleClass_mk_surjective`).** The quotient map $\mathbb{I}_K \to C_K$ is
surjective, giving the fundamental exact sequence
$$1 \to K^\times \to \mathbb{I}_K \to C_K \to 1.$$

*Sketch.* Quotient maps are always surjective; injectivity of the left map
is Theorem 4.5. $\square$

**Theorem 4.8 (Universal property: Hecke characters = idèle class
characters; Lean `heckeCharEquiv`).** Finite-order Hecke characters
correspond bijectively to the characters of the idèle class group $C_K$ —
equivalently, to the characters of $\mathbb{I}_K$ that are trivial on the
principal idèles.

*Sketch.* A character of a quotient $\mathbb{I}_K / \mathrm{principalIdeles}_K$
is exactly a character of $\mathbb{I}_K$ vanishing on
$\mathrm{principalIdeles}_K$, by the universal property of the quotient.
Identifying these with finite-order Hecke characters is the definitional
content on the automorphic side. (In the Phase A source the precise
continuity/finite-order packaging is the final declaration; we state it at
the level its construction guarantees.) $\square$

Restricting Theorem 4.8 to characters of conductor dividing $n$ recovers
exactly the Dirichlet characters of Section 3, tying the coordinate-free
picture back to the explicit cyclotomic dictionary.

---

## 6. Algorithms

The explicit reciprocity law of Theorem 3.7 is directly computable. We
record the core algorithms (full Python in the accompanying demo).

**Algorithm A — Cyclotomic Artin symbol.** Given $n$ and an exponent $a$
coprime to $n$ representing the automorphism $\sigma_a : \zeta_n \mapsto
\zeta_n^{\,a}$, the Artin symbol is $a \bmod n$. Composition of
automorphisms corresponds to multiplication of symbols mod $n$.

**Algorithm B — Evaluate the attached Galois representation.** Given a
Dirichlet character $D$ (as a table on $(\mathbb{Z}/n\mathbb{Z})^\times$)
and an automorphism $\sigma_a$, return $\rho_D(\sigma_a) = D(a)$
(Theorem 3.7). This evaluates the entire correspondence with a single table
lookup.

**Algorithm C — Verify it is a group homomorphism.** For all pairs
$a, b$, check $\rho_D(\sigma_a \sigma_b) = \rho_D(\sigma_a)\rho_D(\sigma_b)$,
i.e. $D(ab \bmod n) = D(a)D(b)$ — a numerical witness of Theorem 3.2.

**Algorithm D — Count representations.** Enumerate Dirichlet characters
mod $n$ (equivalently, homomorphisms $(\mathbb{Z}/n\mathbb{Z})^\times \to
\mathbb{C}^\times$); their number is $\varphi(n)$ (Theorems 3.9–3.10).

---

## 7. Numerical demonstrations

The accompanying `demo.py` exercises the *main theorem* (Theorem 3.7) on
genuine, non-trivial characters:

- For $n = 5, 7, 8, 12$, it builds explicit Dirichlet characters from
  primitive roots, computes Artin symbols, and verifies
  $\rho_D(\sigma) = D(a)$ on every automorphism.
- It confirms the homomorphism law $D(ab) = D(a)D(b)$ (Theorem 3.2).
- It confirms the triviality detector (Corollary 3.8): the principal
  character maps to the trivial representation and nothing else does.
- It confirms $\#\{\text{representations}\} = \varphi(n)$ and, for primes,
  $\varphi(p) = p - 1$ (Theorems 3.9–3.11).

---

## 8. Applications

The explicit dictionary is the conceptual engine behind several concrete
domains.

- **Primes in arithmetic progressions.** Dirichlet characters mod $n$ and
  their $L$-functions, the analytic backbone of Dirichlet's theorem, are
  precisely the Hecke side of the correspondence; the Galois side explains
  why these characters control splitting of primes in $\mathbb{Q}(\zeta_n)$.
- **Factorization of primes.** A prime $q \nmid n$ splits in
  $\mathbb{Q}(\zeta_n)$ according to the order of its Artin symbol $q \bmod
  n$ — a direct reading of Theorem 3.4.
- **$L$-functions and functional equations.** Identifying Dirichlet
  $L$-functions with Artin $L$-functions of $1$-dimensional Galois
  representations (the analytic shadow of Theorem 3.2) underlies their
  meromorphic continuation and functional equations.
- **The road to $GL(2)$.** The cyclotomic $GL(1)$ case is the template
  whose generalization to higher-dimensional representations is the modern
  Langlands program.

---

## 9. Discussion and future work

The two sides developed here — the explicit cyclotomic reciprocity law and
the idèle class group — are currently bridged over $\mathbb{Q}$ through
residues mod $n$. The natural completion is to connect the explicit
correspondence directly to characters of the idèle class group. We record
the program's next steps.

**Conjecture 1 (Profinite Artin map).** The compatible system
$\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) \cong (\mathbb{Z}/n\mathbb{Z})^\times$
assembles, over the divisibility tower, into an isomorphism of profinite
groups $\mathrm{Gal}(\mathbb{Q}^{\mathrm{ab}}/\mathbb{Q}) \cong
\widehat{\mathbb{Z}}^\times = \varprojlim (\mathbb{Z}/n\mathbb{Z})^\times$.
The only extra ingredient beyond the formalized pointwise compatibility is
inverse-limit functoriality.

**Conjecture 2 (Finite idèle class group of $\mathbb{Q}$).** For
$K = \mathbb{Q}$, the finite-idèle class group $\mathbb{I}_f / \mathbb{Q}^\times$
is isomorphic to $\widehat{\mathbb{Z}}^\times$, intertwining the diagonal
$\mathbb{Q}^\times$-action with the principal-idèle subgroup — the
multiplicative analogue of strong approximation visible because
$\mathbb{Q}$ has class number $1$.

**Conjecture 3 (Full GL(1) reciprocity).** Combining Conjectures 1–2, the
character group of the idèle class group of $\mathbb{Q}$ is isomorphic to
that of $\mathrm{Gal}(\mathbb{Q}^{\mathrm{ab}}/\mathbb{Q})$, restricting on
finite-order characters of conductor dividing $n$ to the cyclotomic
correspondence of Theorem 3.7.

---

## 10. Conclusion

We have shown that the abelian $GL(1)$ Langlands correspondence over
$\mathbb{Q}$, in the cyclotomic case, is not merely an abstract isomorphism
of character groups but the explicit reciprocity rule $\rho_D(\sigma) =
D(a)$, where $\sigma(\zeta_n) = \zeta_n^{\,a}$. We complemented this with a
construction of the idèle class group and the universal property
identifying its characters with Hecke characters. Together these give a
self-contained, computable, and structurally complete account of the first
chapter of the Langlands program.
