# The GL(1) Langlands Correspondence over $\mathbb{Q}$: An Explicit Cyclotomic Isomorphism and Its Arithmetic Shadow

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Algebra / Number Theory (Class Field Theory)

---

## Abstract

We give a complete, unconditional treatment of the abelian — i.e. $\mathrm{GL}(1)$ — case of the Langlands correspondence over the rational numbers, in its sharpest classical incarnation: the cyclotomic case of global class field theory. For each modulus $n \ge 1$ and each field $L$ realizing the cyclotomic extension $\mathbb{Q}(\zeta_n)$, we identify the two sides of the correspondence concretely. The *automorphic* (Hecke) side is the group of Dirichlet characters modulo $n$ valued in $\mathbb{C}$, which are exactly the finite-order Hecke characters of $\mathbb{Q}$ of conductor dividing $n$. The *Galois* side is the group of one-dimensional complex representations of $\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q})$. The bridge is the Artin reciprocity isomorphism $\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) \cong (\mathbb{Z}/n\mathbb{Z})^\times$. Our central result establishes the correspondence as an explicit **isomorphism of groups**
$$\widehat{(\mathbb{Z}/n\mathbb{Z})^\times} \;\cong\; \big(\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) \to \mathbb{C}^\times\big),$$
given by $\chi \mapsto \chi \circ (\text{Artin map})$, and not merely as a bijection of sets. We prove that the Galois group is abelian (the structural prerequisite for abelian class field theory), and we extract the arithmetic shadow of the correspondence: the number of one-dimensional complex Galois representations equals $\varphi(n)$, Euler's totient, specializing to $p - 1$ for a prime $p$. Finally we record the local–global factorization of the Hecke side: for coprime $m, k$, the character group of $(\mathbb{Z}/mk)^\times$ factors as a product, driven by the Chinese Remainder Theorem — the finite shadow of the adelic restricted-product structure. Over $\mathbb{Q}$ all statements are unconditional, because the cyclotomic polynomials are irreducible over $\mathbb{Q}$.

---

## 1. Introduction

The Langlands program predicts a profound web of correspondences between two kinds of mathematical objects: $n$-dimensional representations of Galois groups (the *arithmetic* side) and automorphic representations of reductive groups such as $\mathrm{GL}_n$ (the *analytic* side). In its full generality the program is largely conjectural and forms one of the central research efforts of contemporary mathematics. Its first nontrivial case, $n = 1$ — the $\mathrm{GL}(1)$ case — is, however, completely understood: it *is* class field theory, the crowning achievement of early twentieth-century number theory.

This paper formalizes the $\mathrm{GL}(1)$ correspondence over $\mathbb{Q}$ in the case where the relevant abelian extensions are cyclotomic. This case has three virtues that make it ideal as a foundational, fully provable instance:

1. **It is unconditional.** Over $\mathbb{Q}$, the cyclotomic polynomial $\Phi_n(x)$ is irreducible, so $[\mathbb{Q}(\zeta_n):\mathbb{Q}] = \varphi(n)$ and the Galois group is *exactly* $(\mathbb{Z}/n\mathbb{Z})^\times$ for every $n$. No further hypotheses are required.
2. **It is explicit.** The correspondence is realized by a single formula — composition with the Artin reciprocity map — and is a genuine isomorphism of abelian groups, transporting the pointwise product of Dirichlet characters to the pointwise product of Galois characters.
3. **It is computable.** The correspondence has an arithmetic shadow: both sides are counted by Euler's totient $\varphi(n)$, a fact one can verify numerically for any modulus.

The remainder of the paper is organized as follows. Section 2 fixes notation and recalls the two sides of the correspondence. Section 3 develops the structural ingredients — Artin reciprocity for cyclotomic fields and the functoriality of character groups under group isomorphisms. Section 4 states and sketches the proofs of the main results. Section 5 presents algorithms and numerical demonstrations. Section 6 discusses the place of these results within the broader Langlands philosophy. Section 7 lists future directions.

---

## 2. Setting and definitions

Throughout, $n \ge 1$ is a natural number with $n \ne 0$ (so that a primitive $n$-th root of unity exists), and $L$ denotes a field equipped with a $\mathbb{Q}$-algebra structure that makes it a cyclotomic extension of $\mathbb{Q}$ of order $n$; concretely $L \cong \mathbb{Q}(\zeta_n)$ where $\zeta_n = e^{2\pi i/n}$.

### 2.1 The Galois side

**Definition 2.1 (Cyclotomic field and its Galois group).** Let $\zeta_n$ be a primitive $n$-th root of unity. The *cyclotomic field* is $\mathbb{Q}(\zeta_n)$. Its *Galois group* $\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q})$ is the group of field automorphisms of $\mathbb{Q}(\zeta_n)$ fixing $\mathbb{Q}$ pointwise, under composition. Each such automorphism $\sigma$ is determined by an exponent: $\sigma(\zeta_n) = \zeta_n^{k}$ for a unique $k \in (\mathbb{Z}/n\mathbb{Z})^\times$.

**Definition 2.2 (One-dimensional Galois representations).** A *one-dimensional complex representation* of $\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q})$ is a group homomorphism
$$\rho : \mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) \longrightarrow \mathbb{C}^\times.$$
Equivalently, since the target $\mathbb{C}^\times$ is abelian, it is a character of the Galois group. These homomorphisms form an abelian group under pointwise multiplication, denoted $\big(\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) \to \mathbb{C}^\times\big)$.

### 2.2 The automorphic / Hecke side

**Definition 2.3 (Dirichlet character).** A *Dirichlet character modulo $n$ valued in $\mathbb{C}$* is a multiplicative character of the unit group $(\mathbb{Z}/n\mathbb{Z})^\times$ extended by $0$ off the units; formally it is an element of $\mathrm{MulChar}(\mathbb{Z}/n\mathbb{Z}, \mathbb{C})$. The set of all such characters, denoted $\mathrm{DirichletCharacter}(\mathbb{C}, n)$, forms an abelian group under pointwise multiplication. These are precisely the finite-order Hecke characters of $\mathbb{Q}$ of conductor dividing $n$.

The Galois side and the Hecke side are, a priori, defined in completely different mathematical languages: one in terms of field automorphisms of an extension of $\mathbb{Q}$, the other in terms of multiplicative functions on residue classes. The content of the correspondence is that they are canonically the same.

---

## 3. Structural ingredients

### 3.1 Artin reciprocity for cyclotomic fields

**Definition 3.1 / Theorem 4.1 (`artinIso`).** There is a canonical group isomorphism
$$\mathrm{artinIso}_n \;:\; \mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) \;\xrightarrow{\ \sim\ }\; (\mathbb{Z}/n\mathbb{Z})^\times.$$

*Construction.* The map sends an automorphism $\sigma$ to the unique class $k \in (\mathbb{Z}/n\mathbb{Z})^\times$ with $\sigma(\zeta_n) = \zeta_n^k$. This is a homomorphism because $(\sigma \circ \tau)(\zeta_n) = \sigma(\zeta_n^{\ell}) = \zeta_n^{k\ell}$ when $\tau$ has exponent $\ell$ and $\sigma$ has exponent $k$; thus composition of automorphisms corresponds to multiplication of exponents. It is injective because an automorphism fixing $\mathbb{Q}$ is determined by its value on the generator $\zeta_n$, and it is surjective because every $k$ coprime to $n$ yields a valid automorphism. The surjectivity (equivalently, that the Galois group has order $\varphi(n)$, the full size of $(\mathbb{Z}/n\mathbb{Z})^\times$) is exactly the statement that $[\mathbb{Q}(\zeta_n):\mathbb{Q}] = \varphi(n)$, which over $\mathbb{Q}$ follows from the irreducibility of the cyclotomic polynomial $\Phi_n$ over $\mathbb{Q}$. $\square$

This map is the cyclotomic incarnation of the global Artin reciprocity law: it identifies the abstract Galois group with an explicit, computable arithmetic group of residues.

### 3.2 Abelianness

**Theorem 4.2 (`galois_abelian`).** For all $a, b \in \mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q})$, we have $ab = ba$.

*Proof sketch.* Apply the injective homomorphism $\mathrm{artinIso}_n$. Then $\mathrm{artinIso}_n(ab) = \mathrm{artinIso}_n(a)\,\mathrm{artinIso}_n(b)$, and since the target $(\mathbb{Z}/n\mathbb{Z})^\times$ is a commutative group, the right side equals $\mathrm{artinIso}_n(b)\,\mathrm{artinIso}_n(a) = \mathrm{artinIso}_n(ba)$. Injectivity of $\mathrm{artinIso}_n$ then forces $ab = ba$. $\square$

This is the structural reason that *abelian* class field theory — the $\mathrm{GL}(1)$ corner of the Langlands program — governs these extensions. Without commutativity, the dual (character) group would not capture the full group, and the correspondence would fail.

### 3.3 Functoriality of character groups

**Lemma 3.3 (`precompMulEquiv`).** Let $G, H$ be groups, $M$ a commutative group, and $e : G \xrightarrow{\sim} H$ a group isomorphism. Then precomposition with $e$ induces a group isomorphism of character groups
$$e^* : (H \to M) \;\xrightarrow{\ \sim\ }\; (G \to M), \qquad \varphi \mapsto \varphi \circ e,$$
with inverse $\psi \mapsto \psi \circ e^{-1}$.

*Proof sketch.* The two assignments are mutually inverse because $e \circ e^{-1} = \mathrm{id}_H$ and $e^{-1} \circ e = \mathrm{id}_G$, so $(\varphi \circ e) \circ e^{-1} = \varphi$ and likewise on the other side. It is a homomorphism of character groups because precomposition is linear in the character: $(\varphi_1 \varphi_2) \circ e = (\varphi_1 \circ e)(\varphi_2 \circ e)$, the products being pointwise in the commutative target $M$. $\square$

This lemma is the categorical statement that "taking one-dimensional representations" (the Pontryagin/character dual) is a contravariant functor that turns isomorphisms into isomorphisms. It is the formal device that lets us transport the Artin isomorphism to the level of character groups.

---

## 4. Main results

### 4.1 The correspondence

We combine two isomorphisms. First, Mathlib's identification (here `MulChar.mulEquivToUnitHom`) of Dirichlet characters with homomorphisms out of the unit group:
$$\mathrm{DirichletCharacter}(\mathbb{C}, n) \;\cong\; \big((\mathbb{Z}/n\mathbb{Z})^\times \to \mathbb{C}^\times\big).$$
Second, the dual of Artin reciprocity from Lemma 3.3 applied to $e = \mathrm{artinIso}_n$:
$$\big((\mathbb{Z}/n\mathbb{Z})^\times \to \mathbb{C}^\times\big) \;\cong\; \big(\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) \to \mathbb{C}^\times\big).$$
Composing yields the main theorem.

**Theorem 4.3 (Main; `langlandsGL1`).** There is an explicit isomorphism of abelian groups
$$\mathrm{langlandsGL1}_n \;:\; \mathrm{DirichletCharacter}(\mathbb{C}, n) \;\xrightarrow{\ \sim\ }\; \big(\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) \to \mathbb{C}^\times\big),$$
given by sending a Dirichlet character $\chi$ to the Galois representation $\chi \circ (\text{Artin map})$, i.e. $\sigma \mapsto \chi\big(\mathrm{artinIso}_n(\sigma)\big)$.

*Proof sketch.* The map is the composition of the isomorphism $\mathrm{MulChar.mulEquivToUnitHom}$ with $\mathrm{precompMulEquiv}(\mathrm{artinIso}_n)$. Being a composition of group isomorphisms, it is a group isomorphism. The explicit formula follows by unwinding the two component maps on a character $\chi$: first $\chi$ is identified with a homomorphism on $(\mathbb{Z}/n\mathbb{Z})^\times$, then that homomorphism is precomposed with $\mathrm{artinIso}_n$. $\square$

This is the precise meaning of the slogan "1-dimensional Galois representations correspond to Hecke characters." The correspondence is structure-preserving: the pointwise product $\chi_1 \chi_2$ of Dirichlet characters maps to the pointwise product of the corresponding Galois representations.

### 4.2 Counting: the arithmetic shadow

**Theorem 4.4 (`card_dirichlet_eq_totient`).** The number of Dirichlet characters modulo $n$ valued in $\mathbb{C}$ is
$$\#\,\mathrm{DirichletCharacter}(\mathbb{C}, n) = \varphi(n),$$
where $\varphi$ is Euler's totient.

*Proof sketch.* Dirichlet characters mod $n$ over $\mathbb{C}$ are identified with homomorphisms $(\mathbb{Z}/n\mathbb{Z})^\times \to \mathbb{C}^\times$. Because $\mathbb{C}$ contains enough roots of unity (every finite cyclic group embeds into $\mathbb{C}^\times$), the character group of the finite abelian group $(\mathbb{Z}/n\mathbb{Z})^\times$ has the same order as the group itself. Finally $\#(\mathbb{Z}/n\mathbb{Z})^\times = \varphi(n)$ by definition of the totient. $\square$

**Theorem 4.5 (`card_galois_reps_eq_totient`).** The number of one-dimensional complex representations of $\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q})$ is
$$\#\big(\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) \to \mathbb{C}^\times\big) = \varphi(n).$$

*Proof sketch.* Transport the cardinality across the main isomorphism of Theorem 4.3: an isomorphism of groups is in particular a bijection of underlying sets, so the two finite sets have equal cardinality. Then apply Theorem 4.4. (Finiteness on the Galois side is inherited from finiteness of the Dirichlet side via the bijection.) $\square$

**Corollary 4.6 (`card_galois_reps_prime`).** For a prime $p$,
$$\#\big(\mathrm{Gal}(\mathbb{Q}(\zeta_p)/\mathbb{Q}) \to \mathbb{C}^\times\big) = p - 1.$$

*Proof sketch.* Specialize Theorem 4.5 to $n = p$ and use $\varphi(p) = p - 1$, which holds because every integer in $\{1, \dots, p-1\}$ is coprime to the prime $p$. $\square$

These counting theorems are the concrete arithmetic content of the correspondence: a question about the representation theory of an abstract Galois group is answered by an elementary counting function.

### 4.3 Local–global factorization on the Hecke side

**Theorem 4.7 (`heckeFactorization`).** For coprime natural numbers $m$ and $k$, there is a canonical isomorphism of character groups
$$\widehat{(\mathbb{Z}/mk\mathbb{Z})^\times} \;\cong\; \widehat{(\mathbb{Z}/m\mathbb{Z})^\times} \times \widehat{(\mathbb{Z}/k\mathbb{Z})^\times},$$
i.e. a Dirichlet character of conductor dividing $mk$ splits canonically into its $m$-part and its $k$-part.

*Proof sketch.* The Chinese Remainder Theorem gives a ring isomorphism $\mathbb{Z}/mk\mathbb{Z} \cong \mathbb{Z}/m\mathbb{Z} \times \mathbb{Z}/k\mathbb{Z}$ for coprime $m, k$, which restricts to a group isomorphism of units $(\mathbb{Z}/mk\mathbb{Z})^\times \cong (\mathbb{Z}/m\mathbb{Z})^\times \times (\mathbb{Z}/k\mathbb{Z})^\times$. Dualizing (taking characters into $\mathbb{C}^\times$) and using that the character group of a product is the product of character groups yields the stated factorization. $\square$

At the level of cardinalities this recovers the multiplicativity of the totient, $\varphi(mk) = \varphi(m)\varphi(k)$ for coprime $m, k$, consistent with Theorems 4.4–4.5. Conceptually it is the GL(1) shadow of the adelic restricted-product structure: a global character is assembled from independent local data, one factor per prime.

---

## 5. Algorithms and numerical demonstrations

The arithmetic shadow of the correspondence is fully computable. We describe the core algorithms; full implementations appear in the accompanying `demo.py`.

### 5.1 Enumerating Dirichlet characters modulo $n$

Because $(\mathbb{Z}/n\mathbb{Z})^\times$ is a finite abelian group, it decomposes as a product of cyclic groups, and its characters are products of characters of the cyclic factors. The algorithm:

1. Compute the unit group $U = \{a \in \{1, \dots, n\} : \gcd(a, n) = 1\}$; its size is $\varphi(n)$.
2. Find a generating set / cyclic decomposition $U \cong \prod_i \mathbb{Z}/d_i\mathbb{Z}$.
3. A character is specified by assigning to each cyclic generator $g_i$ a $d_i$-th root of unity $e^{2\pi i a_i / d_i}$; there are $\prod_i d_i = \varphi(n)$ choices.
4. Evaluate a character on an arbitrary unit by writing it in terms of generators.

This both lists all $\varphi(n)$ characters and verifies Theorem 4.4.

### 5.2 The correspondence as a relabeling

Given a Dirichlet character $\chi$ and the Artin map $\sigma \mapsto k_\sigma$ (the exponent with $\sigma(\zeta_n) = \zeta_n^{k_\sigma}$), the Galois representation $\rho = \mathrm{langlandsGL1}_n(\chi)$ is computed by $\rho(\sigma) = \chi(k_\sigma)$. Since the Galois group is concretely $(\mathbb{Z}/n\mathbb{Z})^\times$ under Artin reciprocity, this is a pure relabeling: the demo verifies that the multiplication tables of the two character groups coincide under the correspondence, confirming it is a group isomorphism (Theorem 4.3) and not merely a bijection.

### 5.3 Verifying the totient count and CRT factorization

For a range of $n$, compute $\varphi(n)$ directly by counting, enumerate the characters, and check the two counts agree (Theorems 4.4–4.5; Corollary 4.6 for primes). For coprime $m, k$, verify the bijection $\widehat{(\mathbb{Z}/mk)^\times} \cong \widehat{(\mathbb{Z}/m)^\times} \times \widehat{(\mathbb{Z}/k)^\times}$ at the level of both cardinalities and explicit character values (Theorem 4.7).

---

## 6. Discussion

The cyclotomic GL(1) correspondence is the smallest example in which every promise of the Langlands program is simultaneously visible and provable. Four features deserve emphasis.

**A dictionary between two languages.** The Galois side and the Hecke side are defined in incompatible vocabularies — automorphisms of a field versus multiplicative functions on residues. Artin reciprocity (Theorem 4.1) is the dictionary, and Theorem 4.3 promotes it to an isomorphism of the *dual* (character) groups, which is where the automorphic objects live.

**An isomorphism, not a bijection.** It would be a strictly weaker statement to assert merely that the two sides have equally many elements. Theorem 4.3 asserts that they are isomorphic *as groups*: the pointwise product of Dirichlet characters is carried to the pointwise product of Galois representations. This is the GL(1) form of the compatibility of the correspondence with tensor products of representations.

**A computable arithmetic invariant.** Theorems 4.4–4.5 and Corollary 4.6 distill the correspondence into a number, $\varphi(n)$ (and $p - 1$ for primes), that one can compute by hand. That a representation-theoretic count of an abstract Galois group equals an elementary number-theoretic function is the kind of "unreasonable effectiveness" the Langlands program systematizes.

**Local–global structure.** Theorem 4.7 exhibits, in finite form, the principle that global automorphic objects factor into local pieces indexed by primes. In the full theory this is the restricted-product decomposition of idèle class characters over the places of $\mathbb{Q}$; here it is the Chinese Remainder Theorem, but the architecture is identical.

The restriction to cyclotomic extensions is what makes everything unconditional and explicit: over $\mathbb{Q}$ the cyclotomic polynomials are irreducible, so the Galois group is the full $(\mathbb{Z}/n\mathbb{Z})^\times$ and no case analysis is needed. The Kronecker–Weber theorem guarantees that *every* finite abelian extension of $\mathbb{Q}$ is contained in a cyclotomic field, so the cyclotomic case is not a special corner but a cofinal, essentially complete account of abelian class field theory over $\mathbb{Q}$.

---

## 7. Worked examples

To make the abstract statements concrete, we trace the correspondence through three moduli of increasing structural richness. Throughout, we use that under Artin reciprocity (Theorem 4.1) a Galois automorphism is recorded by its exponent $k$ with $\sigma(\zeta_n) = \zeta_n^k$, so the Galois side may be computed directly on $(\mathbb{Z}/n\mathbb{Z})^\times$.

### 7.1 The prime modulus $n = 5$

Here $(\mathbb{Z}/5\mathbb{Z})^\times = \{1, 2, 3, 4\}$ is cyclic of order $\varphi(5) = 4$, generated by $g = 2$ (since $2^1 = 2$, $2^2 = 4$, $2^3 = 3$, $2^4 = 1$ modulo $5$). A character is determined by where it sends the generator, which must go to a fourth root of unity $i^a$ for $a \in \{0, 1, 2, 3\}$. The four Dirichlet characters are therefore $\chi_a(2^j) = i^{aj}$. By Corollary 4.6 there are exactly $5 - 1 = 4$ of them, matching the four one-dimensional representations of $\mathrm{Gal}(\mathbb{Q}(\zeta_5)/\mathbb{Q})$. The trivial character $\chi_0$ corresponds to the trivial representation; $\chi_2$ is the unique real nontrivial character (the quadratic, or Legendre, character mod $5$), taking values $\pm 1$; and $\chi_1, \chi_3$ are complex conjugate characters of order $4$. The Galois representation attached to $\chi_a$ sends the automorphism $\sigma : \zeta_5 \mapsto \zeta_5^k$ to $\chi_a(k)$.

### 7.2 A non-cyclic unit group: $n = 8$

The modulus $n = 8$ is the smallest where the unit group is not cyclic: $(\mathbb{Z}/8\mathbb{Z})^\times = \{1, 3, 5, 7\} \cong \mathbb{Z}/2\mathbb{Z} \times \mathbb{Z}/2\mathbb{Z}$, with $\varphi(8) = 4$. Every nonidentity element has order $2$ ($3^2 = 5^2 = 7^2 = 1 \bmod 8$), so no single generator exists. Choosing the basis $\{3, 5\}$, a character is specified by two independent signs $\chi(3), \chi(5) \in \{\pm 1\}$, giving $2 \times 2 = 4$ characters — again $\varphi(8) = 4$, consistent with Theorem 4.4. The corresponding Galois group $\mathrm{Gal}(\mathbb{Q}(\zeta_8)/\mathbb{Q})$ is the Klein four-group, the symmetry group fixing $\mathbb{Q}$ inside $\mathbb{Q}(\zeta_8) = \mathbb{Q}(i, \sqrt{2})$. This example shows that the correspondence handles non-cyclic Galois groups with no modification: it is the full character group, not merely a cyclic dual, that is transported.

### 7.3 The Chinese Remainder split: $n = 15 = 3 \cdot 5$

Since $\gcd(3, 5) = 1$, Theorem 4.7 gives
$$\widehat{(\mathbb{Z}/15\mathbb{Z})^\times} \cong \widehat{(\mathbb{Z}/3\mathbb{Z})^\times} \times \widehat{(\mathbb{Z}/5\mathbb{Z})^\times}.$$
Numerically, $\varphi(15) = 8 = 2 \times 4 = \varphi(3)\varphi(5)$, confirming the multiplicativity of the totient as the cardinality shadow of the factorization. Every character mod $15$ arises uniquely as a product $\chi^{(3)} \cdot \chi^{(5)}$ of a character mod $3$ and a character mod $5$, read through the ring isomorphism $\mathbb{Z}/15\mathbb{Z} \cong \mathbb{Z}/3\mathbb{Z} \times \mathbb{Z}/5\mathbb{Z}$. This is the finite, fully explicit prototype of the place-by-place factorization of idèle class characters that organizes the entire automorphic side of the Langlands program.

The accompanying computational artifacts verify all three examples — and the general identities $\#\{\text{characters}\} = \varphi(n)$ and the multiplicativity of the correspondence — exactly (using integer exponent vectors, so without floating-point error) for all moduli in a substantial range.

## 8. Future directions

**Conjecture 1 — Conductor-graded refinement.** Under the correspondence, a Dirichlet character of conductor exactly $d \mid n$ should map to a Galois representation factoring through $\mathrm{Gal}(\mathbb{Q}(\zeta_d)/\mathbb{Q})$ (trivial on $\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}(\zeta_d))$), giving a graded isomorphism indexed by conductor. The correspondence is then compatible with the conductor filtration, and the inclusion $\mathbb{Q}(\zeta_d) \subseteq \mathbb{Q}(\zeta_n)$ becomes inflation of representations.

**Conjecture 2 — Matching of L-functions.** For a Dirichlet character $\chi$ and its Galois counterpart $\rho$, the Dirichlet L-function $L(s, \chi)$ should equal the Artin L-function $L(s, \rho)$ term by term as Euler products. The local CRT factorization (Theorem 4.7) is exactly the place-by-place decomposition that makes the two Euler products agree factor by factor, reducing global equality to a per-prime statement.

**Conjecture 3 — Functoriality of the count under the cyclotomic tower.** The totient counts should assemble into an exact statement: the natural restriction map $\big(\mathrm{Gal}(\mathbb{Q}(\zeta_{mn})/\mathbb{Q}) \to \mathbb{C}^\times\big) \to \big(\mathrm{Gal}(\mathbb{Q}(\zeta_m)/\mathbb{Q}) \to \mathbb{C}^\times\big)$ is surjective with kernel of order $\varphi(mn)/\varphi(m)$, mirroring the surjection $(\mathbb{Z}/mn\mathbb{Z})^\times \twoheadrightarrow (\mathbb{Z}/m\mathbb{Z})^\times$.

**Conjecture 4 — Real-place / sign data at GL(1) over $\mathbb{Q}$.** Every finite-order Hecke character of $\mathbb{Q}$ should be determined by its restriction to $(\mathbb{Z}/n\mathbb{Z})^\times$ together with a single sign at the archimedean place, and the correspondence is a bijection onto Galois characters once that sign (the parity $\chi(-1) = \pm 1$) is recorded.

---

## Appendix: Summary of formal results

| Name | Statement |
|---|---|
| `artinIso` | $\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) \cong (\mathbb{Z}/n\mathbb{Z})^\times$ |
| `galois_abelian` | $ab = ba$ for all $a, b$ in the Galois group |
| `precompMulEquiv` | $e : G \cong H \Rightarrow (H \to M) \cong (G \to M)$ for commutative $M$ |
| `langlandsGL1` | $\mathrm{DirichletCharacter}(\mathbb{C}, n) \cong \big(\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) \to \mathbb{C}^\times\big)$ |
| `card_dirichlet_eq_totient` | $\#\,\mathrm{DirichletCharacter}(\mathbb{C}, n) = \varphi(n)$ |
| `card_galois_reps_eq_totient` | $\#\big(\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) \to \mathbb{C}^\times\big) = \varphi(n)$ |
| `card_galois_reps_prime` | for prime $p$, the count is $p - 1$ |
| `heckeFactorization` | $\widehat{(\mathbb{Z}/mk)^\times} \cong \widehat{(\mathbb{Z}/m)^\times} \times \widehat{(\mathbb{Z}/k)^\times}$, $\gcd(m,k)=1$ |
