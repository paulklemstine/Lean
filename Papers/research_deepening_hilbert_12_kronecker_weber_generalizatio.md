# Atomicity of Prime-Class-Number Hilbert Class Fields

## Abstract

The Hilbert class field $H$ of a number field $K$ is the maximal unramified
abelian extension of $K$; its defining arithmetic property is the Artin
reciprocity isomorphism $\mathrm{Gal}(H/K) \cong \mathrm{Cl}(\mathcal{O}_K)$
between its Galois group and the ideal class group of the ring of integers
$\mathcal{O}_K$. In particular the degree $[H:K]$ equals the class number
$h_K$. We prove that when $h_K$ is a **prime** $p$, the extension $H/K$ is
*atomic*: it possesses no proper intermediate fields, so every field $L$ with
$K \subseteq L \subseteq H$ equals either $K$ or $H$. The argument is a clean
two-step reduction. First, Artin reciprocity forces $\mathrm{Gal}(H/K)$ to be a
group of prime order $p$. Second, an elementary consequence of Lagrange's
theorem — that a group of prime order has no subgroups other than the trivial
one and the whole group — is transported across the Galois correspondence,
which is an order-reversing bijection between intermediate fields of $H/K$ and
subgroups of $\mathrm{Gal}(H/K)$. We isolate the prime-order subgroup fact as a
standalone lemma proved directly from divisibility, discuss the structural
significance of the result as a rigidity statement about class-field towers,
give explicit worked examples over imaginary quadratic fields, and formulate
conjectures extending the phenomenon to squarefree and higher-rank class
numbers.

**Keywords:** Hilbert class field, class number, ideal class group, Artin
reciprocity, Galois correspondence, Lagrange's theorem, prime order,
intermediate fields, class field theory.

---

## 1. Introduction

### 1.1 Background and motivation

Unique factorization of integers into primes is the bedrock of elementary
number theory, but it is a fragile property. In the ring of integers
$\mathcal{O}_K$ of a general number field $K$, factorization into irreducible
elements need not be unique. The canonical example is
$K = \mathbb{Q}(\sqrt{-5})$, where
$$6 = 2 \cdot 3 = (1+\sqrt{-5})(1-\sqrt{-5})$$
exhibits two essentially distinct factorizations. Dedekind's theory of ideals
restores order: while elements may factor non-uniquely, *ideals* of
$\mathcal{O}_K$ factor uniquely into prime ideals. The obstruction to unique
factorization of elements is then measured by a finite abelian group, the
**ideal class group** $\mathrm{Cl}(\mathcal{O}_K)$, whose order is the **class
number** $h_K$. One has $h_K = 1$ precisely when $\mathcal{O}_K$ is a principal
ideal domain, i.e. when unique factorization holds.

Class field theory attaches to $K$ a distinguished extension that "resolves"
this failure: the **Hilbert class field** $H$, defined as the maximal
unramified abelian extension of $K$. Its central property is the **Artin
reciprocity isomorphism**
$$\mathrm{Gal}(H/K) \;\xrightarrow{\;\sim\;}\; \mathrm{Cl}(\mathcal{O}_K),$$
a canonical isomorphism of finite abelian groups induced by the Artin symbol
(sending an unramified prime to its Frobenius). Two immediate consequences are:

- the degree identity $[H:K] = |\mathrm{Gal}(H/K)| = |\mathrm{Cl}(\mathcal{O}_K)| = h_K$;
- the principal ideal theorem: every ideal of $\mathcal{O}_K$ becomes principal
  in $\mathcal{O}_H$.

This paper studies the **subfield structure** of the extension $H/K$ in the
simplest nontrivial arithmetic case, where the class number is prime.

### 1.2 Main result

> **Theorem (Atomicity of prime-class-number class fields).**
> Let $K$ be a number field with Hilbert class field $H$, and suppose the class
> number satisfies $h_K = p$ for a prime $p$. Then $H/K$ has no proper
> intermediate fields: for every field $L$ with $K \subseteq L \subseteq H$,
> either $L = K$ or $L = H$.

Equivalently, $H/K$ is a *minimal* nontrivial extension in the lattice sense —
an "atom" of the tower of abelian extensions above $K$. The result is sharp: if
$h_K$ is composite, intermediate fields generally exist (see Section 5).

### 1.3 Strategy

The proof factors through two clean, independent facts and the bridge between
them:

1. **Arithmetic input (reciprocity).** Artin reciprocity converts the
   arithmetic invariant $h_K$ into the group-theoretic invariant
   $|\mathrm{Gal}(H/K)|$, giving a Galois group of prime order.
2. **Group-theoretic core (Lagrange).** A group of prime order has only two
   subgroups. This is proved from scratch below.
3. **Bridge (Galois correspondence).** The fundamental theorem of Galois
   theory transports the subgroup dichotomy into the desired dichotomy of
   intermediate fields.

The philosophy — translate a hard arithmetic question into an easy
group-theoretic one — is a microcosm of the reciprocity philosophy that
animates modern class field theory and the Langlands program.

---

## 2. Definitions and preliminaries

Throughout, $K$ is a number field, i.e. a finite extension of $\mathbb{Q}$,
with ring of integers $\mathcal{O}_K$.

**Definition 2.1 (Ideal class group and class number).**
The *ideal class group* $\mathrm{Cl}(\mathcal{O}_K)$ is the quotient of the
group of nonzero fractional ideals of $\mathcal{O}_K$ by the subgroup of
nonzero principal fractional ideals. It is a finite abelian group; its order
$h_K = |\mathrm{Cl}(\mathcal{O}_K)|$ is the *class number* of $K$.

**Definition 2.2 (Hilbert class field).**
The *Hilbert class field* $H$ of $K$ is the maximal unramified abelian
extension of $K$ (unramified at all finite and infinite places, abelian Galois
group). It is a finite Galois extension of $K$.

**Definition 2.3 (Intermediate field).**
Given a field extension $H/K$, an *intermediate field* is a field $L$ with
$K \subseteq L \subseteq H$. The intermediate fields form a lattice under
inclusion, with least element $K$ (written $\bot$) and greatest element $H$
(written $\top$).

**Theorem 2.4 (Artin reciprocity — used as the structural interface).**
There is a canonical isomorphism of finite groups
$$e : \mathrm{Gal}(H/K) \xrightarrow{\ \sim\ } \mathrm{Cl}(\mathcal{O}_K).$$
Consequently $\;|\mathrm{Gal}(H/K)| = h_K$.

We treat Theorem 2.4 as the load-bearing arithmetic hypothesis: it is the sole
place where the specific nature of the Hilbert class field enters. Everything
else is group theory and Galois theory.

**Theorem 2.5 (Fundamental theorem of Galois theory).**
Let $H/K$ be a finite Galois extension with Galois group
$G = \mathrm{Gal}(H/K)$. Then the map
$$L \;\longmapsto\; \mathrm{Gal}(H/L) = \{\sigma \in G : \sigma|_L = \mathrm{id}\}$$
is an *order-reversing bijection* from the lattice of intermediate fields of
$H/K$ onto the lattice of subgroups of $G$. Its inverse sends a subgroup
$S \le G$ to its fixed field $H^S$. Under this correspondence,
$K \leftrightarrow G$ (i.e. $\bot \leftrightarrow \top$) and
$H \leftrightarrow \{1\}$ (i.e. $\top \leftrightarrow \bot$).

Because it is order-reversing, we may package it as an order isomorphism
$$\varphi : \{\text{intermediate fields}\} \;\xrightarrow{\ \sim\ }\; \{\text{subgroups of } G\}^{\mathrm{op}},$$
onto the *order dual* of the subgroup lattice, with $\varphi(\bot) = \top$ and
$\varphi(\top) = \bot$.

---

## 3. The group-theoretic core

The engine of the whole argument is the following elementary lemma, which we
prove directly from Lagrange's theorem rather than importing it as a black box.

**Lemma 3.1 (Subgroups of a group of prime order).**
Let $G$ be a group with $|G| = p$ where $p$ is prime. Then every subgroup
$S \le G$ satisfies $S = \{1\}$ or $S = G$.

*Proof.* Since $|G| = p$ is finite and nonzero, $G$ is finite. By **Lagrange's
theorem**, the order $|S|$ of any subgroup divides $|G| = p$. Because $p$ is
prime, its only positive divisors are $1$ and $p$, so $|S| \in \{1, p\}$.

- If $|S| = 1$, then $S$ contains only the identity, hence $S = \{1\}$. (A
  subgroup of order $\le 1$ is trivial.)
- If $|S| = p = |G|$, then $S$ is a subgroup of $G$ of the same finite
  cardinality as $G$, hence $S = G$. (A subgroup whose order equals the order
  of the ambient finite group is the whole group.)

Either way, $S \in \{\{1\}, G\}$. $\qquad\blacksquare$

**Remark 3.2.** Lemma 3.1 is exactly the statement that a group of prime order
has a *two-element subgroup lattice*, $\{1\} < G$, with no intermediate nodes.
It is equivalent to the familiar fact that every group of prime order is
cyclic and generated by any non-identity element, but the divisibility proof
above is self-contained and requires no generator.

---

## 4. Proof of the main theorem

> **Theorem 4.1 (Atomicity of prime-class-number class fields).**
> Let $K$ be a number field, and let $H/K$ be a finite Galois extension
> equipped with the Artin reciprocity isomorphism
> $e : \mathrm{Gal}(H/K) \cong \mathrm{Cl}(\mathcal{O}_K)$ characterizing $H$ as
> the Hilbert class field of $K$. If the class number of $K$ equals a prime $p$,
> then every intermediate field $L$ with $K \subseteq L \subseteq H$ satisfies
> $L = K$ or $L = H$.

*Proof.* Write $G = \mathrm{Gal}(H/K)$.

**Step 1 — the Galois group has prime order.**
The reciprocity isomorphism $e$ is a bijection, so
$$|G| = |\mathrm{Gal}(H/K)| = |\mathrm{Cl}(\mathcal{O}_K)| = h_K = p.$$
Thus $G$ is a group of prime order $p$.

**Step 2 — transport across the Galois correspondence.**
Let $\varphi$ be the order-reversing isomorphism of Theorem 2.5 from the
lattice of intermediate fields of $H/K$ onto (the order dual of) the subgroup
lattice of $G$, with $\varphi(\bot) = \top$ and $\varphi(\top) = \bot$, where
$\bot = K$, $\top = H$ on the field side and $\bot = \{1\}$, $\top = G$ on the
subgroup side.

Fix an intermediate field $L$. Its image $\varphi(L)$ is a subgroup of $G$. By
Lemma 3.1 applied to $G$ (which has prime order $p$ by Step 1), either
$\varphi(L) = \{1\}$ or $\varphi(L) = G$.

- If $\varphi(L) = \{1\} = \bot$ in the subgroup lattice, then since
  $\varphi(\top) = \bot$ and $\varphi$ is injective, we get $L = \top = H$.
- If $\varphi(L) = G = \top$ in the subgroup lattice, then since
  $\varphi(\bot) = \top$ and $\varphi$ is injective, we get $L = \bot = K$.

In both cases $L \in \{K, H\}$, completing the proof. $\qquad\blacksquare$

**Remark 4.3 (No circularity).** The conclusion is obtained directly from the
*subgroup* dichotomy of Lemma 3.1 transported across the Galois
correspondence; it does *not* invoke any prepackaged "an extension of prime
degree has no intermediate fields" statement. The arithmetic enters only
through the group isomorphism $e$ of Theorem 2.4.

**Corollary 4.4 (Cyclic simplicity).** Under the hypotheses of Theorem 4.1,
$\mathrm{Gal}(H/K)$ is cyclic of order $p$, and $H$ is the unique nontrivial
field in the tower over $K$ inside $H$. In particular $H/K$ is a *minimal*
abelian extension: it cannot be written as a nontrivial compositum or tower of
smaller extensions of $K$ inside $H$.

---

## 5. Sharpness and the composite case

Theorem 4.1 is sharp: primality of $h_K$ is essential.

Suppose $h_K = mn$ with $m, n > 1$ coprime, or more generally that
$\mathrm{Cl}(\mathcal{O}_K)$ has a proper nontrivial subgroup $S$ — which
happens exactly when $h_K$ is composite, since a finite abelian group has a
subgroup of every order dividing its cardinality (indeed a group whose order is
composite is not simple). Then, via reciprocity, $\mathrm{Gal}(H/K)$ has the
corresponding proper nontrivial subgroup $e^{-1}(S)$, and the Galois
correspondence produces a genuine intermediate field
$$L = H^{\,e^{-1}(S)}, \qquad K \subsetneq L \subsetneq H,$$
the fixed field of that subgroup. In fact the entire lattice of intermediate
fields of $H/K$ is anti-isomorphic to the subgroup lattice of
$\mathrm{Cl}(\mathcal{O}_K)$:
$$\{\text{intermediate fields of } H/K\}
\;\cong\;
\{\text{subgroups of } \mathrm{Cl}(\mathcal{O}_K)\}^{\mathrm{op}}.$$

Two structural consequences follow.

- **Squarefree class number ⇒ Boolean layering.** If
  $h_K = p_1 p_2 \cdots p_r$ is a product of *distinct* primes, then by the
  structure theorem $\mathrm{Cl}(\mathcal{O}_K) \cong
  \mathbb{Z}/p_1 \times \cdots \times \mathbb{Z}/p_r$ is a product of distinct
  cyclic prime factors, and its subgroup lattice is the Boolean lattice of
  subsets of $\{p_1,\dots,p_r\}$. Correspondingly, $H/K$ decomposes into $r$
  independent prime-degree layers, one per prime factor. Prime class number
  ($r = 1$) is the atomic base case.
- **Square factor ⇒ genuine richness.** The first non-distributive behavior of
  the subfield lattice appears precisely when $h_K$ is divisible by a square,
  which permits a non-cyclic $p$-part $(\mathbb{Z}/p)^2 \le
  \mathrm{Cl}(\mathcal{O}_K)$ and hence multiple independent degree-$p$
  intermediate layers.

---

## 6. Worked examples

We illustrate with imaginary quadratic fields $K = \mathbb{Q}(\sqrt{d})$,
$d < 0$ squarefree, where class numbers are classical and readily computed.

**Example 6.1 ($h_K = 1$: no extension).** For
$K = \mathbb{Q}(\sqrt{-1}), \mathbb{Q}(\sqrt{-2}), \mathbb{Q}(\sqrt{-3})$ and
the other nine imaginary quadratic fields of class number one, $h_K = 1$, so
$H = K$. There is nothing to extend; the "tower" is a single point.

**Example 6.2 ($h_K = 2$: atomic).** For $K = \mathbb{Q}(\sqrt{-5})$ the class
number is $h_K = 2$, prime. Theorem 4.1 applies: $H/K$ is a degree-$2$
extension with $\mathrm{Gal}(H/K) \cong \mathbb{Z}/2$ and **no** intermediate
fields. Concretely, $H = K(\sqrt{-1}) = \mathbb{Q}(\sqrt{-5}, i)$, and there is
no field strictly between $K$ and $H$. The same holds for every $K$ with
$h_K = 2$, e.g. $\mathbb{Q}(\sqrt{-6}), \mathbb{Q}(\sqrt{-10}),
\mathbb{Q}(\sqrt{-13})$.

**Example 6.3 ($h_K = 3$: atomic, cyclic cubic).** For
$K = \mathbb{Q}(\sqrt{-23})$ the class number is $h_K = 3$, prime. Theorem 4.1
gives a cyclic cubic class field $H/K$ with $\mathrm{Gal}(H/K) \cong
\mathbb{Z}/3$ and no intermediate fields. The same holds for
$\mathbb{Q}(\sqrt{-31})$ (also $h = 3$).

**Example 6.4 ($h_K = 4$: not atomic).** For $K = \mathbb{Q}(\sqrt{-14})$ the
class number is $h_K = 4$ with cyclic class group $\mathbb{Z}/4$. Since $4$ is
composite, Theorem 4.1 does *not* apply, and indeed there is a unique
intermediate field $L$ with $K \subsetneq L \subsetneq H$, corresponding to the
unique index-$2$ subgroup $2\mathbb{Z}/4 \le \mathbb{Z}/4$; here $[L:K] = 2$
and $[H:L] = 2$.

**Example 6.5 ($h_K = 4$, non-cyclic: genus layering).** For
$K = \mathbb{Q}(\sqrt{-21})$ the class group is
$\mathbb{Z}/2 \times \mathbb{Z}/2$ of order $4$. Its subgroup lattice has three
subgroups of order $2$, producing **three** distinct intermediate fields
$L_1, L_2, L_3$, each quadratic over $K$ — the classical *genus fields*. This
is the smallest example of non-distributive richness, driven by the square
factor $4 = 2^2$ and the resulting $2$-rank $2$ of the class group.

---

## 7. Algorithmic perspective

The theorem is inherently algorithmic: given a number field, deciding atomicity
of its class field reduces to a primality test on the class number.

**Algorithm A (Atomicity decision).** *Input:* a number field $K$ (e.g. its
defining polynomial or, for quadratics, the discriminant). *Output:* whether
$H/K$ is atomic.
1. Compute the class number $h_K$ (via analytic class number formula, or by
   ideal reduction for quadratics).
2. Test whether $h_K$ is prime.
3. Return "atomic (no intermediate fields)" iff the test succeeds.

**Algorithm B (Intermediate-field lattice).** *Input:* the class group
$\mathrm{Cl}(\mathcal{O}_K)$ as a finite abelian group (its invariant factors).
*Output:* the lattice of intermediate fields of $H/K$.
1. Enumerate all subgroups of $\mathrm{Cl}(\mathcal{O}_K)$.
2. Reverse the inclusion order (order dual).
3. The resulting poset is isomorphic to the intermediate-field lattice of
   $H/K$; the number of intermediate fields (including $K$ and $H$) equals the
   number of subgroups.

Algorithm B makes the counting concrete: the number of intermediate fields of
$H/K$ equals the total number of subgroups of $\mathrm{Cl}(\mathcal{O}_K)$. For
$\mathbb{Z}/p$ this is $2$ (recovering atomicity); for
$\mathbb{Z}/p \times \mathbb{Z}/p$ it is $p + 3$; for $\mathbb{Z}/p^2$ it is
$3$; and in general it is a computable function of the invariant factors.

---

## 8. Discussion

Theorem 4.1 is a rigidity statement: prime class number forces the class field
to be an indecomposable atom. Its interest is less in the difficulty of the
proof — which is short — than in the *clarity* of the translation it exhibits.
An arithmetic question about sub-extensions of a class field is converted, by
Artin reciprocity, into a group-theoretic question about subgroups, and the
latter is settled by Lagrange's theorem. This is the reciprocity philosophy in
its purest, most transparent form.

Structurally, the result identifies the extremes of a spectrum governed by the
*shape* of the class group. Cyclic-of-prime-order class groups give atomic
class fields (this paper); squarefree class numbers give Boolean layerings of
independent prime slabs; square factors and higher $p$-rank give the genuinely
intricate, non-distributive subfield lattices classically studied via genus
theory. In every case the subfield lattice of $H/K$ is an exact mirror image
(order dual) of the subgroup lattice of $\mathrm{Cl}(\mathcal{O}_K)$, so the
arithmetic of towers over $K$ is completely encoded in finite group theory.

The result also situates a concrete, fully explicit instance within the broader
class-field-theoretic program that generalizes the Kronecker–Weber theorem
(every abelian extension of $\mathbb{Q}$ lies in a cyclotomic field) to
arbitrary base fields via Hilbert class fields and, ultimately, the Langlands
correspondence. Prime-degree layers are exactly the setting in which the still
partially-open general reciprocity laws simplify to a *single* character, making
them the natural next case to pin down explicitly.

---

## 9. Future directions

*(These extend the atomicity phenomenon proved above.)*

**Conjecture 1 — Lattice rigidity is exactly the "squarefree class number"
phenomenon.** For a number field $K$, the Hilbert class field $H/K$ has a
*distributive* subfield lattice that is a Boolean-type product of prime layers
precisely when the class number is squarefree; the first non-distributive
behaviour appears at the smallest square factor. The subfield lattice of the
class field mirrors the subgroup lattice of the class group, so the arithmetic
question "when is the tower of abelian layers lattice-simple?" becomes the
group-theoretic question "when is the class group a product of distinct cyclic
prime factors?" — squarefreeness of the class number. Because class numbers and
class-group structures are tabulated for enormous ranges of discriminants, the
squarefree/non-squarefree split can be tested against millions of fields.

**Conjecture 2 — Prime-degree minimality forces a reciprocity fingerprint on
splitting primes.** If $H/K$ is an abelian extension of prime degree $p$, then
the prime ideals of $K$ split completely in $H$ exactly along a single
congruence / ray-class condition of index $p$, and no coarser condition
suffices. A prime-degree layer has no room for intermediate splitting: the
absence of intermediate fields means a prime is either inert-type or fully
split, so the splitting law is governed by one primitive character of order $p$
rather than a composite of several. This is the hypothesis under which the
general reciprocity law simplifies to a single character, making it the most
tractable next case to check against known splitting tables for cubic and
quintic fields.

**Conjecture 3 — Genus layers are the unique obstruction to prime-degree
rigidity.** The failure of subfield-lattice rigidity for a class field is
controlled entirely by the $p$-part of the class group: the number of
independent degree-$p$ intermediate layers equals the $p$-rank of the class
group, and these are precisely the "genus" subfields. Non-trivial intermediate
fields can only come from non-cyclic factors of the class group, and the count
of independent minimal layers is a rank, not a size — so the entire deviation
from rigidity is measured by a single rank invariant. The $2$-rank of class
groups is especially accessible via genus theory.

---

## 10. Conclusion

We proved that a number field with prime class number has an atomic Hilbert
class field — one with no proper intermediate fields — by combining Artin
reciprocity (which makes the Galois group have prime order), Lagrange's theorem
(which forbids proper nontrivial subgroups of a prime-order group), and the
fundamental theorem of Galois theory (which transports the subgroup dichotomy
back to fields). The proof is a clean, self-contained instance of the
reciprocity philosophy, and it anchors a spectrum of rigidity phenomena — from
atomic prime layers, through Boolean squarefree layerings, to the higher-rank
genus richness — all governed by the subgroup lattice of the ideal class group.
