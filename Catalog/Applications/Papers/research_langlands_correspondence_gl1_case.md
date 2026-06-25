# The GL(1) Langlands Correspondence over $\mathbb{Q}$: Cyclotomic Class Field Theory, Self-Duality, and the Quadratic Stratum

**Author:** Aristotle
**Domain:** Number Theory / Langlands Program (Novelty)
**Date:** 2026-06-25

---

## Abstract

We present a complete and self-contained development of the abelian — i.e. $\mathrm{GL}(1)$ — case of the Langlands correspondence over the rational numbers $\mathbb{Q}$, in its sharpest classical incarnation: the cyclotomic case of global class field theory. For each modulus $n$ and each field $L$ that is an $n$-th cyclotomic extension of $\mathbb{Q}$ (so $L \cong \mathbb{Q}(\zeta_n)$), we identify two character groups. On the *automorphic* side stand the Dirichlet characters mod $n$, the finite-order Hecke characters of conductor dividing $n$. On the *Galois* side stand the one-dimensional complex representations of the Galois group $G = \mathrm{Gal}(L/\mathbb{Q})$. The bridge is the Artin reciprocity isomorphism $G \cong (\mathbb{Z}/n\mathbb{Z})^\times$, which holds unconditionally over $\mathbb{Q}$ because the cyclotomic polynomial $\Phi_n$ is irreducible over $\mathbb{Q}$.

Our main contributions are: (1) the GL(1) correspondence as an explicit group isomorphism between Dirichlet characters and one-dimensional Galois representations; (2) a **self-duality theorem** exhibiting a (non-canonical) group isomorphism $\widehat{G} \cong G$ between the Galois group and its own character group, which structurally explains the numerical identity $\#\widehat{G} = \#G = \varphi(n)$; (3) **cyclicity** of the prime-conductor Galois group $\mathrm{Gal}(\mathbb{Q}(\zeta_p)/\mathbb{Q})$, equivalent to the existence of primitive roots modulo $p$; and (4) a complete analysis of the **quadratic stratum**, showing there are exactly two quadratic Dirichlet characters and exactly two order-$\le 2$ Galois representations at an odd prime, both equal to the number of square roots of unity in $(\mathbb{Z}/p\mathbb{Z})^\times$. Throughout, cardinality identities are obtained *structurally*, by transport across genuine group isomorphisms, rather than by independent recomputation. We discuss algorithms realizing every construction, numerical demonstrations, and a research program extending these results to order-stratified counts, tower functoriality, and Frobenius reciprocity.

---

## 1. Introduction

### 1.1 The Langlands program and its ground floor

The Langlands program is a vast web of conjectures and theorems relating two superficially unrelated kinds of mathematical object: *Galois representations*, which encode the symmetries of solutions to polynomial equations, and *automorphic forms*, which are highly symmetric analytic objects living on arithmetic quotients of Lie groups. The connecting tissue is a family of *reciprocity laws*, each asserting that a representation-theoretic invariant on one side (an $L$-function, a local factor, a conductor) matches the corresponding invariant on the other.

The program is organized by the rank of an algebraic group $\mathrm{GL}(d)$. The case $\mathrm{GL}(2)$ — relating modular forms to two-dimensional Galois representations — already contains the Taniyama–Shimura–Weil modularity theorem and, through it, Fermat's Last Theorem. The general case is largely conjectural.

The case $d = 1$, the $\mathrm{GL}(1)$ correspondence, is different: it is *completely proved*, and it coincides with **class field theory**, the crowning achievement of early twentieth-century number theory. In the abelian world, "Galois representations" are one-dimensional (homomorphisms into $\mathbb{C}^\times$), and "automorphic forms" are Hecke characters of the idèle class group. Global class field theory provides the reciprocity isomorphism. This paper develops the $\mathrm{GL}(1)$ correspondence over $\mathbb{Q}$ in the cyclotomic family, where every object is finite and explicitly computable, and where the abstract idèlic machinery specializes to elementary, verifiable statements about Dirichlet characters and cyclotomic Galois groups.

### 1.2 Why the cyclotomic case

For the field $\mathbb{Q}$, the Kronecker–Weber theorem asserts that *every* finite abelian extension is contained in a cyclotomic field $\mathbb{Q}(\zeta_n)$. Thus the cyclotomic fields are not a special case; they are the universal carriers of abelian class field theory over $\mathbb{Q}$. In this family:

- the idèle class group's finite-order character theory becomes the theory of **Dirichlet characters**;
- the Artin reciprocity map becomes the canonical isomorphism $\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) \cong (\mathbb{Z}/n\mathbb{Z})^\times$;
- the conductor-conductor compatibility becomes multiplicativity in the modulus and divisibility of conductors.

Crucially, over $\mathbb{Q}$ the entire correspondence holds *unconditionally for every $n$*, because the $n$-th cyclotomic polynomial $\Phi_n$ is irreducible over $\mathbb{Q}$ (a theorem going back to Gauss for prime $n$ and to Kronecker/Dedekind in general). This removes any side conditions and makes the correspondence a clean, total construction.

### 1.3 Summary of results

Fix $n \ge 1$ and a field $L$ with $L \cong \mathbb{Q}(\zeta_n)$, and write $G = \mathrm{Gal}(L/\mathbb{Q})$. We establish:

1. **Artin reciprocity (cyclotomic).** A canonical group isomorphism
$$\mathrm{artinIso} \colon G \;\xrightarrow{\;\cong\;}\; (\mathbb{Z}/n\mathbb{Z})^\times.$$
2. **GL(1) correspondence.** A group isomorphism
$$\mathrm{langlandsGL1} \colon \widehat{(\mathbb{Z}/n\mathbb{Z})^\times} \;\xrightarrow{\;\cong\;}\; \mathrm{Hom}(G, \mathbb{C}^\times),$$
between Dirichlet characters mod $n$ and one-dimensional representations of $G$.
3. **Self-duality.** A (non-canonical) group isomorphism
$$\mathrm{galoisRepsEquivGalois} \colon \mathrm{Hom}(G, \mathbb{C}^\times) \;\xrightarrow{\;\cong\;}\; G.$$
4. **Counts.** $\#G = \varphi(n)$; $\#\mathrm{Hom}(G,\mathbb{C}^\times) = \#G$; and for prime $p$, $\#G = p-1$.
5. **Cyclicity.** For prime $p$, $G = \mathrm{Gal}(\mathbb{Q}(\zeta_p)/\mathbb{Q})$ is cyclic.
6. **Quadratic stratum.** For odd prime $p$, there are exactly two square roots of $1$ in $(\mathbb{Z}/p\mathbb{Z})^\times$, hence exactly two quadratic Dirichlet characters and exactly two order-$\le 2$ Galois representations.
7. **Local–global factorization.** For coprime $m, k$, a group isomorphism of Dirichlet character groups $\widehat{(\mathbb{Z}/mk)^\times} \cong \widehat{(\mathbb{Z}/m)^\times} \times \widehat{(\mathbb{Z}/k)^\times}$, the cyclotomic shadow of the idèlic restricted product.

---

## 2. Definitions and setting

Throughout, $n$ denotes a positive integer (we assume $n \neq 0$, written $\mathrm{NeZero}\ n$, so that a primitive $n$-th root of unity exists), $L$ a field with an $n$-th cyclotomic extension structure over $\mathbb{Q}$, and $G = \mathrm{Gal}(L/\mathbb{Q}) = (L \simeq_{\mathbb{Q}}^{\mathrm{alg}} L)$ the group of $\mathbb{Q}$-algebra automorphisms of $L$.

**Definition 2.1 (Cyclotomic extension).** A field $L$ is an *$n$-th cyclotomic extension of $\mathbb{Q}$* if $L$ is generated over $\mathbb{Q}$ by the roots of $X^n - 1$, equivalently by a primitive $n$-th root of unity $\zeta_n$. The canonical example is $L = \mathbb{Q}(\zeta_n) = \mathbb{Q}[X]/(\Phi_n)$, where $\Phi_n$ is the $n$-th cyclotomic polynomial.

**Definition 2.2 (Units mod $n$).** The group $(\mathbb{Z}/n\mathbb{Z})^\times$ consists of residue classes $a \bmod n$ with $\gcd(a, n) = 1$, under multiplication. Its order is *Euler's totient* $\varphi(n) = \#\{1 \le a \le n : \gcd(a,n) = 1\}$.

**Definition 2.3 (Dirichlet character).** A *Dirichlet character mod $n$* valued in $\mathbb{C}$ is a multiplicative homomorphism $\chi \colon \mathbb{Z}/n\mathbb{Z} \to \mathbb{C}$ supported on the units (a `MulChar (ZMod n) ℂ`). Equivalently, after restriction it is a group homomorphism $(\mathbb{Z}/n\mathbb{Z})^\times \to \mathbb{C}^\times$. These are the finite-order Hecke characters of conductor dividing $n$ for the base field $\mathbb{Q}$. We write $\mathrm{DirichletCharacter}\ \mathbb{C}\ n$ for the group of all of them under pointwise multiplication.

**Definition 2.4 (One-dimensional Galois representation).** A *one-dimensional complex representation* of $G$ is a group homomorphism $\rho \colon G \to \mathbb{C}^\times$. The set $\mathrm{Hom}(G, \mathbb{C}^\times)$ of all such, under pointwise multiplication, is the *Galois side* of the GL(1) correspondence; it is the Pontryagin dual $\widehat{G}$ of $G$ valued in $\mathbb{C}^\times$.

**Definition 2.5 (Character group / Pontryagin dual).** For a finite commutative group $A$, the *character group* (Pontryagin dual) is $\widehat{A} = \mathrm{Hom}(A, \mathbb{C}^\times)$. For finite $A$, $\widehat{A}$ is again a finite commutative group with $\#\widehat{A} = \#A$.

The "enough roots of unity" hypothesis used throughout is automatic for the target $\mathbb{C}$: the complex numbers contain a primitive $m$-th root of unity for every $m$, which is exactly what is needed for the duality theory of finite abelian groups to be non-degenerate.

---

## 3. Artin reciprocity in the cyclotomic case

The structural foundation of everything is the identification of the cyclotomic Galois group with the units mod $n$.

**Theorem 3.1 (Artin reciprocity, cyclotomic case; `artinIso`).** There is a group isomorphism
$$\mathrm{artinIso} \colon \mathrm{Gal}(L/\mathbb{Q}) \;\xrightarrow{\;\cong\;}\; (\mathbb{Z}/n\mathbb{Z})^\times.$$

*Construction and proof sketch.* Every $\sigma \in G$ permutes the primitive $n$-th roots of unity and is determined by its action on a fixed $\zeta_n$. Since $\sigma$ is a field automorphism fixing $\mathbb{Q}$, we have $\sigma(\zeta_n) = \zeta_n^{a(\sigma)}$ for a unique $a(\sigma) \in (\mathbb{Z}/n\mathbb{Z})^\times$ (the exponent must be a unit because $\sigma$ is invertible and preserves the order of $\zeta_n$). The assignment $\sigma \mapsto a(\sigma)$ is a homomorphism because $(\sigma\tau)(\zeta_n) = \sigma(\zeta_n^{a(\tau)}) = \zeta_n^{a(\sigma)a(\tau)}$. It is injective because $\zeta_n$ generates $L$, and surjective because the degree $[L:\mathbb{Q}] = \deg \Phi_n = \varphi(n)$ equals $\#(\mathbb{Z}/n\mathbb{Z})^\times$, which forces a bijection. The well-definedness and surjectivity hinge on the **irreducibility of $\Phi_n$ over $\mathbb{Q}$**, which guarantees $[L:\mathbb{Q}] = \varphi(n)$ and is unconditional over $\mathbb{Q}$. In the formal development this is `IsCyclotomicExtension.autEquivPow` instantiated with `cyclotomic.irreducible_rat`. $\qquad\blacksquare$

An immediate corollary records abelianness — the structural reason that abelian class field theory governs cyclotomic extensions at all.

**Corollary 3.2 (Abelianness; `galois_abelian`).** $G$ is abelian: for all $\sigma, \tau \in G$, $\sigma\tau = \tau\sigma$.

*Proof sketch.* The target $(\mathbb{Z}/n\mathbb{Z})^\times$ is commutative, and $\mathrm{artinIso}$ is an injective homomorphism. Hence $\mathrm{artinIso}(\sigma\tau) = \mathrm{artinIso}(\sigma)\mathrm{artinIso}(\tau) = \mathrm{artinIso}(\tau)\mathrm{artinIso}(\sigma) = \mathrm{artinIso}(\tau\sigma)$, and injectivity gives $\sigma\tau = \tau\sigma$. $\qquad\blacksquare$

---

## 4. The GL(1) correspondence

We now state the correspondence as an explicit group isomorphism. The construction uses a general functoriality lemma.

**Lemma 4.1 (Functoriality of the dual; `precompMulEquiv`).** Let $e \colon G \xrightarrow{\cong} H$ be an isomorphism of groups and $M$ a commutative group. Then precomposition with $e$ is a group isomorphism of character groups
$$\mathrm{precompMulEquiv}(e) \colon \mathrm{Hom}(H, M) \;\xrightarrow{\;\cong\;}\; \mathrm{Hom}(G, M), \qquad \varphi \mapsto \varphi \circ e.$$

*Proof sketch.* The map $\varphi \mapsto \varphi \circ e$ has inverse $\psi \mapsto \psi \circ e^{-1}$; the two round-trips are identities by the functor laws $e \circ e^{-1} = \mathrm{id}$ and $e^{-1} \circ e = \mathrm{id}$. It respects pointwise multiplication because $(\varphi_1 \varphi_2) \circ e = (\varphi_1 \circ e)(\varphi_2 \circ e)$. Each verification is a one-line extensionality computation. $\qquad\blacksquare$

The other ingredient is the identification of a Dirichlet character with a homomorphism on the unit group, `MulChar.mulEquivToUnitHom`: a multiplicative character $\chi \colon \mathbb{Z}/n\mathbb{Z} \to \mathbb{C}$ supported on units is the same datum as a group homomorphism $(\mathbb{Z}/n\mathbb{Z})^\times \to \mathbb{C}^\times$.

**Theorem 4.2 (GL(1) Langlands correspondence; `langlandsGL1`).** There is a group isomorphism
$$\mathrm{langlandsGL1} \colon \mathrm{DirichletCharacter}\ \mathbb{C}\ n \;\xrightarrow{\;\cong\;}\; \mathrm{Hom}(G, \mathbb{C}^\times),$$
explicitly $\chi \mapsto \chi \circ \mathrm{artinIso}$.

*Proof sketch.* Compose two isomorphisms:
$$\mathrm{DirichletCharacter}\ \mathbb{C}\ n \xrightarrow[\cong]{\mathrm{mulEquivToUnitHom}} \mathrm{Hom}\big((\mathbb{Z}/n\mathbb{Z})^\times, \mathbb{C}^\times\big) \xrightarrow[\cong]{\mathrm{precompMulEquiv}(\mathrm{artinIso})} \mathrm{Hom}(G, \mathbb{C}^\times).$$
The first identifies a Dirichlet character with its unit-group homomorphism; the second pulls back along Artin reciprocity. Both are group isomorphisms, so the composite is. Concretely, $\chi$ on the residue $a$ becomes the representation $\sigma \mapsto \chi(\mathrm{artinIso}(\sigma))$ on the Galois group. $\qquad\blacksquare$

This is the precise meaning of "one-dimensional Galois representations correspond to Hecke characters" in the abelian case. The isomorphism is of *groups*, so the pointwise product of Dirichlet characters matches the pointwise product of Galois representations; the correspondence is structural, not merely a bijection of underlying sets.

**Theorem 4.3 (Counting Dirichlet characters; `card_dirichlet_eq_totient`).** $\#\,\mathrm{DirichletCharacter}\ \mathbb{C}\ n = \varphi(n)$.

*Proof sketch.* The number of $\mathbb{C}$-valued multiplicative characters of $\mathbb{Z}/n\mathbb{Z}$ equals the number of homomorphisms $(\mathbb{Z}/n\mathbb{Z})^\times \to \mathbb{C}^\times$, which for a finite abelian group $A$ equals $\#A$ because $\mathbb{C}$ has enough roots of unity (`MulChar.card_eq_card_units_of_hasEnoughRootsOfUnity`). Finally $\#(\mathbb{Z}/n\mathbb{Z})^\times = \varphi(n)$ (`ZMod.card_units_eq_totient`). $\qquad\blacksquare$

**Theorem 4.4 (Counting Galois representations; `card_galois_reps_eq_totient`).** $\#\,\mathrm{Hom}(G, \mathbb{C}^\times) = \varphi(n)$.

*Proof sketch.* Transport Theorem 4.3 across the isomorphism of Theorem 4.2: a group isomorphism induces a bijection of underlying sets, so $\#\,\mathrm{Hom}(G,\mathbb{C}^\times) = \#\,\mathrm{DirichletCharacter}\ \mathbb{C}\ n = \varphi(n)$. $\qquad\blacksquare$

**Theorem 4.5 (Prime count; `card_galois_reps_prime`).** For prime $p$, $\#\,\mathrm{Hom}(G, \mathbb{C}^\times) = p - 1$.

*Proof sketch.* Specialize Theorem 4.4 to $n = p$ and use $\varphi(p) = p - 1$ (every nonzero residue mod a prime is a unit). $\qquad\blacksquare$

---

## 5. Self-duality of the Galois group

The numerical identity $\#\mathrm{Hom}(G,\mathbb{C}^\times) = \#G$ (both equal $\varphi(n)$) is a clue. The structural reason is self-duality.

**Theorem 5.1 (Pontryagin self-duality of $G$; `galoisRepsEquivGalois`).** There is a (non-canonical) group isomorphism
$$\mathrm{galoisRepsEquivGalois} \colon \mathrm{Hom}(G, \mathbb{C}^\times) \;\xrightarrow{\;\cong\;}\; G.$$

*Proof sketch.* The key input is that a finite abelian group $A$, with values in a field $M$ containing enough roots of unity, satisfies $\mathrm{Hom}(A, M^\times) \cong A$ (`CommGroup.monoidHom_mulEquiv_of_hasEnoughRootsOfUnity`). This isomorphism is non-canonical: it depends on a choice and is the analogue of choosing a basis. The Galois group $G$ is not literally registered as a commutative group with this duality theory attached, so we *transport* through Artin reciprocity. Set $U = (\mathbb{Z}/n\mathbb{Z})^\times$. Then
$$\mathrm{Hom}(G, \mathbb{C}^\times) \xrightarrow[\cong]{\mathrm{precompMulEquiv}(\mathrm{artinIso}^{-1})} \mathrm{Hom}(U, \mathbb{C}^\times) \xrightarrow[\cong]{\text{duality}} U \xrightarrow[\cong]{\mathrm{artinIso}^{-1}} G.$$
The first arrow pulls back representations of $G$ to characters of $U$ along the inverse Artin map; the middle is the finite-abelian-group self-duality applied to $U$; the last returns to $G$. The composite is a group isomorphism. $\qquad\blacksquare$

The non-canonicality deserves emphasis. There is no preferred isomorphism $G \cong \widehat{G}$; only the *double dual* $\widehat{\widehat{G}}$ is canonically $G$. The formalization faithfully records this by routing through a choice (`Classical.choice`) at exactly the point where a non-canonical isomorphism is invoked, rather than pretending a canonical one exists.

**Theorem 5.2 (Galois group order; `card_galois_group_eq_totient`).** $\#G = \varphi(n)$.

*Proof sketch.* Transport across Artin reciprocity: $\#G = \#(\mathbb{Z}/n\mathbb{Z})^\times = \varphi(n)$. $\qquad\blacksquare$

**Theorem 5.3 (Cardinality shadow of self-duality; `card_galois_reps_eq_card_galois`).** $\#\,\mathrm{Hom}(G, \mathbb{C}^\times) = \#G$.

*Proof sketch.* Read directly off the isomorphism of Theorem 5.1, which gives a bijection between the two underlying sets. Note this is *not* obtained by computing both sides as $\varphi(n)$ and comparing; it is the genuine shadow of a single structural isomorphism. $\qquad\blacksquare$

**Theorem 5.4 (Prime order; `card_galois_group_prime`).** For prime $p$, $\#G = p - 1$.

*Proof sketch.* Combine Theorem 5.2 with $\varphi(p) = p - 1$. $\qquad\blacksquare$

---

## 6. Cyclicity at primes

When $n = p$ is prime the Galois group is not merely abelian but cyclic — generated by a single element. This is the GL(1) face of the existence of primitive roots.

**Theorem 6.1 (Cyclicity; `galois_cyclic_prime`).** For prime $p$, the group $G = \mathrm{Gal}(\mathbb{Q}(\zeta_p)/\mathbb{Q})$ is cyclic.

*Proof sketch.* The multiplicative group of a finite field is cyclic; in particular $(\mathbb{Z}/p\mathbb{Z})^\times$ is cyclic of order $p - 1$ (`IsCyclic (ZMod p)ˣ`). A cyclic group's image under any surjective homomorphism is cyclic (`isCyclic_of_surjective`). The inverse Artin isomorphism $\mathrm{artinIso}^{-1} \colon (\mathbb{Z}/p\mathbb{Z})^\times \to G$ is surjective (it is even bijective), so $G$ is cyclic. Equivalently: a generator of $(\mathbb{Z}/p\mathbb{Z})^\times$ is a *primitive root mod $p$*, and its image under $\mathrm{artinIso}^{-1}$ generates $G$. $\qquad\blacksquare$

This is a non-vacuous, honestly transported result: it produces a genuine cyclic-group instance for every prime, not a decidable special case. It connects three classical facts — Gauss's theorem on primitive roots, the cyclicity of $\mathbb{F}_p^\times$, and the cyclic structure of $\mathrm{Gal}(\mathbb{Q}(\zeta_p)/\mathbb{Q})$ — revealing them as a single statement.

---

## 7. The quadratic stratum

The finest classical structure visible at GL(1) is the layer of *quadratic* characters: those squaring to the identity. We analyze it completely at a prime.

**Definition 7.1 (Square roots of unity).** For a group $A$, let $\mathrm{Sq}_1(A) = \{x \in A : x^2 = 1\}$, the set of square roots of the identity. For commutative $A$ this is a subgroup (the 2-torsion).

**Lemma 7.2 (Transport of the quadratic count; `card_sq_eq_one_congr`).** If $e \colon A \xrightarrow{\cong} B$ is a group isomorphism then $\#\mathrm{Sq}_1(A) = \#\mathrm{Sq}_1(B)$.

*Proof sketch.* An isomorphism satisfies $e(x)^2 = e(x^2)$ and $e(1) = 1$, so $x^2 = 1 \iff e(x)^2 = 1$. Hence $e$ restricts to a bijection $\mathrm{Sq}_1(A) \to \mathrm{Sq}_1(B)$, and the cardinalities agree. This is the principle that lets the *same* arithmetic count govern both sides of the correspondence. $\qquad\blacksquare$

**Lemma 7.3 (Square roots of unity mod an odd prime; `card_units_sq_eq_one_prime`).** For an odd prime $p$,
$$\#\{x \in (\mathbb{Z}/p\mathbb{Z})^\times : x^2 = 1\} = 2.$$

*Proof sketch.* Since $p$ is prime, $\mathbb{Z}/p\mathbb{Z}$ is a field. In a field the equation $x^2 = 1$ factors as $(x-1)(x+1) = 0$, whose only solutions are $x = 1$ and $x = -1$. Both are units. They are distinct precisely when $1 \neq -1$, i.e. when $2 \neq 0$ in the field, i.e. when $p \neq 2$. Hence there are exactly two for odd $p$. (For $p = 2$ there is only one, since $1 = -1$.) $\qquad\blacksquare$

**Theorem 7.4 (Quadratic Dirichlet characters; `card_quadratic_dirichlet_prime`).** For an odd prime $p$, there are exactly two Dirichlet characters $\chi$ mod $p$ with $\chi^2 = 1$.

*Proof sketch.* The group of Dirichlet characters mod $p$ is isomorphic to $\widehat{(\mathbb{Z}/p\mathbb{Z})^\times}$, which (being a finite abelian group with values in $\mathbb{C}$) is isomorphic to $(\mathbb{Z}/p\mathbb{Z})^\times$ itself by self-duality. The square roots of unity in the character group thus correspond to those in $(\mathbb{Z}/p\mathbb{Z})^\times$, of which there are $2$ by Lemma 7.3, transported by Lemma 7.2. The two characters are the *trivial character* and the *Legendre symbol* $\left(\tfrac{\cdot}{p}\right)$, the unique nontrivial quadratic character. $\qquad\blacksquare$

**Theorem 7.5 (Quadratic Galois representations; `card_quadratic_galois_reps_prime`).** For an odd prime $p$, there are exactly two one-dimensional representations $\rho$ of $\mathrm{Gal}(\mathbb{Q}(\zeta_p)/\mathbb{Q})$ with $\rho^2 = 1$.

*Proof sketch.* By the GL(1) correspondence (Theorem 4.2) the group of Galois representations is isomorphic to the group of Dirichlet characters; apply Lemma 7.2 to transport the count $2$ of Theorem 7.4. The two representations are the trivial one and the quadratic character cutting out the **unique quadratic subfield** of $\mathbb{Q}(\zeta_p)$, namely $\mathbb{Q}(\sqrt{p^*})$ where $p^* = (-1)^{(p-1)/2} p$. The uniqueness of this subfield is the field-theoretic meaning of "exactly two quadratic characters." $\qquad\blacksquare$

The quadratic stratum is the doorway to **quadratic reciprocity**: the Legendre symbol on the automorphic side and the quadratic subfield $\mathbb{Q}(\sqrt{p^*})$ on the Galois side, meeting through the correspondence, form the GL(1) prototype of the entire Langlands philosophy.

---

## 8. Local–global factorization

The idèle class group is a *restricted product* over the places of $\mathbb{Q}$. In the cyclotomic, finite-order incarnation, this product structure becomes the multiplicativity of Dirichlet characters in the modulus.

**Lemma 8.1 (Universal property of products; `homProdEquiv`).** For commutative groups $A, B, M$,
$$\mathrm{Hom}(A \times B, M) \;\cong\; \mathrm{Hom}(A, M) \times \mathrm{Hom}(B, M),$$
via $f \mapsto (f|_A, f|_B)$ with inverse $(g, h) \mapsto g \cdot h$ (the coproduct map $(a,b) \mapsto g(a)h(b)$).

*Proof sketch.* The two assignments are mutually inverse: restricting the coproduct map to each factor recovers $g$ and $h$; and any $f$ equals the coproduct of its restrictions because $f(a,b) = f(a,1)f(1,b)$ in a commutative target. Both respect multiplication. No finiteness of $M$ is needed, only commutativity. $\qquad\blacksquare$

**Lemma 8.2 (CRT on units; `unitsCRT`).** For coprime $m, k$,
$$(\mathbb{Z}/mk\mathbb{Z})^\times \;\cong\; (\mathbb{Z}/m\mathbb{Z})^\times \times (\mathbb{Z}/k\mathbb{Z})^\times.$$

*Proof sketch.* The Chinese Remainder Theorem gives a ring isomorphism $\mathbb{Z}/mk\mathbb{Z} \cong \mathbb{Z}/m\mathbb{Z} \times \mathbb{Z}/k\mathbb{Z}$ when $\gcd(m,k)=1$. Taking unit groups, and using that units of a product ring are the product of unit groups, yields the claim. $\qquad\blacksquare$

**Theorem 8.3 (Hecke factorization; `heckeFactorization`).** For coprime $m, k$,
$$\mathrm{DirichletCharacter}\ \mathbb{C}\ (mk) \;\cong\; \mathrm{DirichletCharacter}\ \mathbb{C}\ m \times \mathrm{DirichletCharacter}\ \mathbb{C}\ k.$$

*Proof sketch.* Compose four isomorphisms: identify each Dirichlet character with a unit-group homomorphism (`mulEquivToUnitHom`); pull back along $\mathrm{unitsCRT}^{-1}$ (Lemma 8.2 and 4.1); split the product via $\mathrm{homProdEquiv}$ (Lemma 8.1); re-identify each factor with a Dirichlet character group. $\qquad\blacksquare$

**Corollary 8.4 (Multiplicativity of $\varphi$, structurally; `card_dirichlet_mul`).** For coprime nonzero $m, k$, $\varphi(mk) = \varphi(m)\varphi(k)$.

*Proof sketch.* Transport cardinality across Theorem 8.3: $\#\,\mathrm{DirichletCharacter}\ \mathbb{C}\ (mk) = \#\,\mathrm{DirichletCharacter}\ \mathbb{C}\ m \cdot \#\,\mathrm{DirichletCharacter}\ \mathbb{C}\ k$, then apply Theorem 4.3 to each factor. The multiplicativity of the totient is here a *corollary* of the structural decomposition, not an input. $\qquad\blacksquare$

---

## 9. Algorithms

Every construction above is effective for explicit $n$. We highlight three.

**Algorithm A (Artin map evaluation).** Given $n$, a primitive root description of $\zeta_n$, and an automorphism $\sigma$ specified by $\sigma(\zeta_n) = \zeta_n^a$, return the unit $a \bmod n$. Inverse: given $a \in (\mathbb{Z}/n\mathbb{Z})^\times$, return the automorphism $\zeta_n \mapsto \zeta_n^a$. Complexity $O(\log n)$ per evaluation after $O(\varphi(n))$ setup to enumerate units. This realizes Theorem 3.1.

**Algorithm B (Character table of the cyclotomic Galois group).** Compute a generator structure of $(\mathbb{Z}/n\mathbb{Z})^\times$ (cyclic for $n \in \{1,2,4,p^k,2p^k\}$, otherwise a product of cyclic factors), then enumerate all $\varphi(n)$ characters as tuples of roots of unity on the generators. By Theorem 4.2 these are exactly the $\varphi(n)$ Galois representations. Complexity $O(\varphi(n)^2)$ to tabulate the full character table. This realizes Theorems 4.2 and 5.1.

**Algorithm C (Quadratic stratum extractor).** Enumerate the elements $x$ of $(\mathbb{Z}/p\mathbb{Z})^\times$ with $x^2 \equiv 1$; for odd $p$ exactly $\{1, p-1\}$ appear. Map each to a character (trivial; Legendre symbol via the Euler criterion $\left(\tfrac{a}{p}\right) \equiv a^{(p-1)/2}$). Complexity $O(p)$. This realizes Theorems 7.4 and 7.5.

---

## 10. Numerical illustrations

For $n = 12$: units $\{1,5,7,11\}$, so $G$ has order $\varphi(12) = 4$ and is isomorphic to $(\mathbb{Z}/2)^2$ (the Klein four-group) — *not* cyclic, consistent with $12$ not being of the form $p^k$ or $2p^k$. There are $4$ Dirichlet characters and $4$ Galois representations; the self-dual isomorphism matches them. Square roots of unity: all four elements square to $1$, so the quadratic stratum here has size $4$ (the prime hypothesis of Theorem 7.4 genuinely matters).

For $p = 7$: units $\{1,\dots,6\}$, $G$ cyclic of order $6$ generated by the residue $3$ (a primitive root: $3,2,6,4,5,1$). Quadratic stratum: $\{1, 6\}$, exactly two elements; the nontrivial quadratic character is the Legendre symbol, with $\left(\tfrac{a}{7}\right) = +1$ for $a \in \{1,2,4\}$ and $-1$ for $a \in \{3,5,6\}$. Its quadratic subfield is $\mathbb{Q}(\sqrt{-7})$, since $7^* = (-1)^{3}\cdot 7 = -7$.

For coprime $m=3$, $k=5$: $\varphi(15) = 8 = 2 \cdot 4 = \varphi(3)\varphi(5)$, matching Theorem 8.3 and Corollary 8.4; the eight characters mod $15$ are exactly the products of the two mod $3$ and four mod $5$.

---

## 11. Discussion

Three methodological points distinguish this development.

**Cardinalities from structure.** Every count — $\varphi(n)$, $p-1$, $2$, $\varphi(m)\varphi(k)$ — is obtained by transporting along a genuine group isomorphism, never by recomputing both sides and comparing. This is faithful to the Langlands philosophy, where the *correspondence* is the primary object and the numerical agreements (of $L$-functions, conductors, dimensions) are its shadows.

**Non-canonical where the mathematics is non-canonical.** The self-duality $\widehat{G} \cong G$ is honestly non-canonical, recorded as such; only the double dual is canonical. This is the abelian avatar of a phenomenon pervasive in representation theory.

**Unconditional over $\mathbb{Q}$.** Because $\Phi_n$ is irreducible over $\mathbb{Q}$, the entire correspondence holds for every $n$ with no side conditions. The Kronecker–Weber theorem guarantees that the cyclotomic family captures *all* abelian extensions of $\mathbb{Q}$, so this is a complete account of GL(1) over $\mathbb{Q}$ within the abelian world.

The limitations are equally clear. The development is specific to the base field $\mathbb{Q}$ and to the cyclotomic family; general number fields require the full idèlic class field theory, where the reciprocity map is harder to make explicit. The representations are one-dimensional by design — that is what GL(1) means. And the analytic content (Hecke $L$-functions, functional equations) is present only implicitly, through the character groups whose $L$-functions are the Dirichlet $L$-functions.

---

## 12. Future directions

Three concrete, falsifiable programs extend this work, all within the cyclotomic family where everything is computable.

**1. Order-stratified GL(1) correspondence.** *Conjecture:* for a prime $p$ and any $d \mid p-1$, the number of Dirichlet characters mod $p$ of order exactly $d$ equals the number of one-dimensional Galois representations of order exactly $d$, and both equal $\varphi(d)$. For $d = 2$ this recovers the proven count $2 = 1 + \varphi(2)$. The key insight is that both sides are dual to the *same* cyclic group $(\mathbb{Z}/p\mathbb{Z})^\times$, and a finite cyclic group of order $m$ has exactly $\varphi(d)$ elements of order $d$ for each $d \mid m$ — an invariant transported intact across the self-duality and Artin isomorphisms. The cyclicity result of §6 supplies the needed instance; Lemma 7.2 is the $d=2$ template for a general order-transport lemma.

**2. Tower functoriality of Artin reciprocity.** *Conjecture:* for $d \mid n$, the reduction homomorphism $(\mathbb{Z}/n\mathbb{Z})^\times \to (\mathbb{Z}/d\mathbb{Z})^\times$ corresponds, under Artin reciprocity, to the restriction $\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) \to \mathrm{Gal}(\mathbb{Q}(\zeta_d)/\mathbb{Q})$; dually, inclusion of Hecke characters of conductor dividing $d$ into those of conductor dividing $n$ matches inflation of Galois representations. The key insight is that class field theory is *functorial in the conductor*: the coprime factorization of §8 and this nested divisibility are the two faces of the restricted-product structure of the idèle class group. With Artin reciprocity packaged as an isomorphism, the commuting square is a concrete computation.

**3. Frobenius reciprocity is the Artin map.** *Conjecture:* for a prime $\ell \nmid n$, the Artin isomorphism sends the Frobenius automorphism at $\ell$ to the class of $\ell$ in $(\mathbb{Z}/n\mathbb{Z})^\times$. Equivalently, the Hecke character $\chi$ matched to a Galois representation $\rho$ satisfies $\chi(\ell) = \rho(\mathrm{Frob}_\ell)$ at all unramified $\ell$. This is the arithmetic heart of the correspondence: it is the statement that makes the matching of $L$-functions term-by-term, and it is the GL(1) seed of the local–global compatibility conjectured in all higher ranks.

---

## 13. Conclusion

The cyclotomic GL(1) correspondence is the fully understood ground floor of the Langlands program. We have given it a complete, self-contained treatment over $\mathbb{Q}$: Artin reciprocity as an explicit isomorphism $G \cong (\mathbb{Z}/n\mathbb{Z})^\times$; the correspondence between Dirichlet characters and one-dimensional Galois representations as a group isomorphism; the structural self-duality $\widehat{G} \cong G$ explaining the numerical agreements; cyclicity at primes as the avatar of primitive roots; and a complete analysis of the quadratic stratum, the doorway to quadratic reciprocity. Each numerical fact descends from a genuine isomorphism, faithful to the principle that, in the Langlands world, the correspondence comes first and the numbers follow.
