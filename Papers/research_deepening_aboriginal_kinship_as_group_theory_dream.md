# Dreamtime Algebra, Deepened: Kinship Systems as $(\mathbb{Z}/2)^n$ and Their Symmetry Group $GL(n, \mathbb{F}_2)$

## Abstract

Australian Aboriginal section and subsection systems partition a society into a
small number of named categories that govern marriage, descent, and ceremonial
obligation. The four-section (Kariera) system is classically identified with the
Klein four-group $\mathbb{Z}/2 \times \mathbb{Z}/2$ and the eight-subsection
(Aranda / Warlpiri) system with $(\mathbb{Z}/2)^3$. We develop this
group-theoretic model uniformly over the general $n$-generation kinship space
$\mathrm{Kin}(n) := (\mathbb{Z}/2)^n$, the elementary abelian $2$-group of rank
$n$, and prove the structural theorems at this general level. We show that the
Cayley representation realizes $\mathrm{Kin}(n)$ as a simply transitive
permutation group of order $2^n$ on its own sections; that the system is genuinely
$(\mathbb{Z}/2)^n$ and never cyclic for $n \ge 2$; that there are exactly $2^n - 1$
admissible marriage generators; that marriage is a coset restriction with respect
to an index-two moiety subgroup; and that each rank increment is a
$\mathbb{Z}/2$-extension (double cover). Our central new result is the **symmetry
theorem**: because $\mathbb{F}_2$ is prime, every additive automorphism of
$\mathrm{Kin}(n)$ is $\mathbb{F}_2$-linear, so the automorphism group of the
kinship system is the general linear group $GL(n, \mathbb{F}_2)$, of order
$\prod_{i=0}^{n-1}(2^n - 2^i)$. For the four-section system this order is $6$, and
$GL(2, \mathbb{F}_2) \cong S_3$ acts by freely permuting the three marriage rules.

**Keywords.** kinship systems, elementary abelian 2-group, Klein four-group,
general linear group, $\mathbb{F}_2$, Cayley representation, coset, group
extension, moiety.

---

## 1. Introduction

The mathematical study of Australian Aboriginal kinship is one of the oldest
recorded encounters between anthropology and abstract algebra. Early twentieth
century fieldwork on the Kariera and Aranda peoples recorded systems that sort an
entire population into four, or eight, named categories, with deterministic rules
for how a person's category relates to those of their mother, father, and spouse.
It was later recognized that these rules are precisely the structure of a finite
abelian group acting on a set: the four-section system is the Klein four-group, the
eight-subsection system is $(\mathbb{Z}/2)^3$.

This paper deepens that identification in two ways. First, we treat all such
systems uniformly by working with the $n$-generation kinship space
$$\mathrm{Kin}(n) := \{\, f : \{0, 1, \dots, n-1\} \to \mathbb{Z}/2 \,\},$$
the elementary abelian $2$-group of rank $n$, so that the four- and eight-category
systems are the special cases $n = 2$ and $n = 3$. Second, and most importantly, we
determine the full symmetry group of the classification. We prove that the group of
structure-preserving relabellings — the automorphism group of $\mathrm{Kin}(n)$ as
an abelian group — is exactly the general linear group $GL(n, \mathbb{F}_2)$. The
decisive point is that the scalar field is $\mathbb{F}_2 = \mathbb{Z}/2$, which is
prime, so additive maps are automatically linear and no additional structure need
be imposed.

Throughout, "section" refers to an element of $\mathrm{Kin}(n)$ (a category in the
kinship classification), and "kinship step" to a translation of the section set by
a fixed section. All results are stated for general $n$ and specialized to the
ethnographically relevant cases $n = 2$ (four sections) and $n = 3$ (eight
subsections).

---

## 2. The $n$-generation kinship space

### 2.1 Definition

**Definition 2.1 (Kinship space).** For $n \in \mathbb{N}$, the *$n$-generation
kinship space* is
$$\mathrm{Kin}(n) := \{\, f : \{0, \dots, n-1\} \to \mathbb{Z}/2 \,\},$$
the set of functions from an $n$-element index set to the two-element ring
$\mathbb{Z}/2$, equipped with pointwise addition. Equivalently, $\mathrm{Kin}(n) =
(\mathbb{Z}/2)^n$, the elementary abelian $2$-group of rank $n$. We call an element
of $\mathrm{Kin}(n)$ a **section**.

The case $n = 2$ is the four-section (Kariera) system; the case $n = 3$ is the
eight-subsection (Aranda / Warlpiri) system.

### 2.2 Basic structure

**Theorem 2.2 (Cardinality).** $|\mathrm{Kin}(n)| = 2^n$.

*Proof sketch.* $\mathrm{Kin}(n)$ is the set of functions from an $n$-element set to
a $2$-element set, of which there are $2^n$. $\square$

**Theorem 2.3 (Exponent two).** For every section $g \in \mathrm{Kin}(n)$,
$g + g = 0$; equivalently $2 \cdot g = 0$.

*Proof sketch.* Addition is pointwise, and in $\mathbb{Z}/2$ every element $x$
satisfies $x + x = 0$ (characteristic two). Hence each coordinate of $g + g$
vanishes. $\square$

Theorem 2.3 is the algebraic form of the ethnographic fact that every kinship step
is reversible in one repetition: applying any step twice returns to the starting
category.

---

## 3. Kinship steps as permutations: the Cayley representation

### 3.1 Translations

**Definition 3.1 (Translation).** For a section $v \in \mathrm{Kin}(n)$, the
*translation by $v$* is the map $T_v : \mathrm{Kin}(n) \to \mathrm{Kin}(n)$ given by
$T_v(x) = x + v$. Because $\mathrm{Kin}(n)$ has exponent two, $T_v$ is an involution
($T_v \circ T_v = \mathrm{id}$) and hence a permutation of the section set.

**Proposition 3.2 (Composition law).** Translations satisfy
$$T_{v + w} = T_v \circ T_w, \qquad T_0 = \mathrm{id}, \qquad T_v \circ T_v = \mathrm{id}.$$

*Proof sketch.* $T_{v+w}(x) = x + v + w = T_v(T_w(x))$ by associativity and
commutativity of addition; $T_0$ is the identity; the last relation is exponent
two applied to $v$. $\square$

### 3.2 The regular representation

**Definition 3.3 (Kinship transformation homomorphism).** Let
$\mathrm{Sym}(\mathrm{Kin}(n))$ be the symmetric group on the set of sections. The
*kinship transformation homomorphism* is
$$\Phi : \mathrm{Kin}(n) \to \mathrm{Sym}(\mathrm{Kin}(n)), \qquad \Phi(v) = T_v.$$
By Proposition 3.2, $\Phi$ is a group homomorphism (from the additive group of
sections to the symmetric group).

**Theorem 3.4 (Faithfulness).** $\Phi$ is injective.

*Proof sketch.* If $T_v = T_w$ then evaluating at $0$ gives $v = 0 + v = 0 + w = w$.
$\square$

**Theorem 3.5 (Kinship transformation group).** The image of $\Phi$ — the subgroup
of $\mathrm{Sym}(\mathrm{Kin}(n))$ generated by the kinship steps — is isomorphic to
$\mathrm{Kin}(n)$, and hence has exactly $2^n$ elements.

*Proof sketch.* By Theorem 3.4, $\Phi$ is an injective homomorphism, so it induces
an isomorphism from $\mathrm{Kin}(n)$ onto its image; combine with Theorem 2.2.
$\square$

**Theorem 3.6 (Simple transitivity).** For any two sections $x, y \in
\mathrm{Kin}(n)$ there is a unique section $v$ with $x + v = y$.

*Proof sketch.* Existence: take $v = y - x$. Uniqueness: if $x + v = x + w$ then $v
= w$ by cancellation. $\square$

Theorem 3.6 is the algebraic counterpart of the statement that every ordered pair
of individuals stands in a well-defined kin relationship: there is exactly one
"relationship word" carrying one category to another.

### 3.3 Not cyclic

**Theorem 3.7 (Non-cyclicity).** For $n \ge 2$, $\mathrm{Kin}(n)$ is not cyclic;
in particular it is $(\mathbb{Z}/2)^n$ and not $\mathbb{Z}/2^n$.

*Proof sketch.* If $\mathrm{Kin}(n)$ were cyclic it would contain an element of
order $|\mathrm{Kin}(n)| = 2^n$. But by Theorem 2.3 every element has order dividing
$2$, so the largest possible order is $2$. For $n \ge 2$ we have $2^n \ge 4 > 2$, a
contradiction. $\square$

---

## 4. The kinship spectrum: admissible marriage rules

**Definition 4.1 (Kinship spectrum).** The *kinship spectrum* of $\mathrm{Kin}(n)$
is the set of nonzero sections,
$$\Sigma(n) := \{\, g \in \mathrm{Kin}(n) : g \ne 0 \,\}.$$
Each $g \in \Sigma(n)$ is a nonzero involution ($g + g = 0$, $g \ne 0$) and
generates a candidate marriage rule (translation by $g$) on the section set.

**Theorem 4.2 (Count of marriage rules).** $|\Sigma(n)| = 2^n - 1$.

*Proof sketch.* $\Sigma(n)$ is the section set with the zero element removed, so
its size is $2^n - 1$ by Theorem 2.2. $\square$

For the four-section system this gives $2^2 - 1 = 3$ marriage rules; for the
eight-subsection system, $2^3 - 1 = 7$.

---

## 5. Marriage as a coset restriction

### 5.1 The moiety functional

**Definition 5.1 (Moiety functional).** On $\mathrm{Kin}(n+1)$ define the *moiety
functional* $\lambda : \mathrm{Kin}(n+1) \to \mathbb{Z}/2$ by $\lambda(f) = f(n)$,
the value of the last coordinate. This is a surjective group homomorphism.

*Surjectivity.* For $c \in \mathbb{Z}/2$, the constant function with value $c$ maps
to $c$.

**Definition 5.2 (Moiety subgroup).** The *moiety subgroup* is $M := \ker \lambda$,
the sections whose last coordinate is $0$. Its two cosets are the two **moieties**.

**Theorem 5.3 (Index two).** $M$ has index $2$ in $\mathrm{Kin}(n+1)$; equivalently
$\mathrm{Kin}(n+1)/M \cong \mathbb{Z}/2$.

*Proof sketch.* By the first isomorphism theorem, $\mathrm{Kin}(n+1)/\ker\lambda
\cong \mathrm{im}\,\lambda = \mathbb{Z}/2$ since $\lambda$ is surjective; hence
$[\mathrm{Kin}(n+1) : M] = |\mathbb{Z}/2| = 2$. $\square$

### 5.2 Marriage preserves cosets

**Theorem 5.4 (Marriage as coset restriction).** Let the marriage step be
translation by a fixed section $m$. Then for every person $x$, the sections $x$ and
its spouse $x + m$ lie in the same coset of $M$ precisely when $\lambda(m) = 0$, and
in opposite cosets precisely when $\lambda(m) = 1$. In either case the marriage step
maps each coset of $M$ onto a single coset of $M$; it never scatters a coset.

*Proof sketch.* $\lambda(x + m) = \lambda(x) + \lambda(m)$ because $\lambda$ is a
homomorphism. Thus the moiety of the spouse is determined by the moiety of $x$ and
the constant $\lambda(m)$; translation by $m$ therefore sends the coset containing
$x$ to a single coset determined by adding $\lambda(m)$. $\square$

Theorem 5.4 formalizes the ethnographic rule that marriage is exogamous with
respect to the moiety division exactly when $\lambda(m) = 1$: spouses come from
opposite moieties, and offspring's moiety is determined by a fixed shift.

---

## 6. Rank increments as $\mathbb{Z}/2$-extensions

**Definition 6.1 (Forgetful map).** The *forgetful map* $\pi :
\mathrm{Kin}(n+1) \to \mathrm{Kin}(n)$ drops the last coordinate: $\pi(f) = f|_{\{0,
\dots, n-1\}}$. It is a surjective group homomorphism.

**Theorem 6.2 (Double cover).** The kernel of $\pi$ has exactly two elements, so
$$1 \to \mathbb{Z}/2 \to \mathrm{Kin}(n+1) \xrightarrow{\pi} \mathrm{Kin}(n) \to 1$$
is a short exact sequence: $\mathrm{Kin}(n+1)$ is a $\mathbb{Z}/2$-extension (double
cover) of $\mathrm{Kin}(n)$, and $\mathrm{Kin}(n+1)/\ker\pi \cong \mathrm{Kin}(n)$.

*Proof sketch.* $\ker \pi$ consists of the functions supported on the last
coordinate alone, of which there are exactly two (last coordinate $0$ or $1$), so
$\ker\pi \cong \mathbb{Z}/2$. Surjectivity of $\pi$ (extend any $g$ by $0$) with the
first isomorphism theorem gives $\mathrm{Kin}(n+1)/\ker\pi \cong \mathrm{Kin}(n)$.
$\square$

Iterating Theorem 6.2 exhibits the tower
$$\mathrm{Kin}(0) \subset \mathrm{Kin}(1) \subset \mathrm{Kin}(2) \subset \cdots,$$
in which each quotient is $\mathbb{Z}/2$: the eight-subsection system is a double
cover of the four-section system, which is itself a double cover of the two-moiety
system.

---

## 7. The symmetry theorem

We now determine the full group of structure-preserving relabellings of a kinship
system. A relabelling that preserves the additive structure is an automorphism of
$\mathrm{Kin}(n)$ as an abelian group.

**Lemma 7.1 (Additive equals linear).** Every additive group endomorphism of
$\mathrm{Kin}(n) = (\mathbb{Z}/2)^n$ is $\mathbb{F}_2$-linear.

*Proof sketch.* Linearity requires additivity (given) and compatibility with scalar
multiplication. The scalars are $\mathbb{F}_2 = \{0, 1\}$; multiplication by $0$
sends everything to $0$ and multiplication by $1$ is the identity, both of which any
additive map respects automatically. Hence additive maps and $\mathbb{F}_2$-linear
maps coincide. $\square$

**Theorem 7.2 (Symmetry theorem).** The automorphism group of the kinship system,
$\mathrm{Aut}(\mathrm{Kin}(n))$, is isomorphic to the general linear group
$GL(n, \mathbb{F}_2)$:
$$\mathrm{Aut}\big((\mathbb{Z}/2)^n\big) \;\cong\; GL(n, \mathbb{F}_2).$$

*Proof sketch.* By Lemma 7.1 the additive automorphisms of $\mathrm{Kin}(n)$ are
exactly the invertible $\mathbb{F}_2$-linear maps of the $n$-dimensional
$\mathbb{F}_2$-vector space $(\mathbb{F}_2)^n$. Choosing the standard basis
identifies these with invertible $n \times n$ matrices over $\mathbb{F}_2$, i.e.
$GL(n, \mathbb{F}_2)$; the identification is a group isomorphism because composition
of linear maps corresponds to matrix multiplication. $\square$

**Theorem 7.3 (Order of the symmetry group).**
$$\big|\mathrm{Aut}(\mathrm{Kin}(n))\big| = |GL(n, \mathbb{F}_2)| = \prod_{i=0}^{n-1} \left(2^n - 2^i\right).$$

*Proof sketch.* An invertible matrix over $\mathbb{F}_2$ is built column by column:
the first column is any nonzero vector ($2^n - 1$ choices $= 2^n - 2^0$); the
$(i+1)$-st column is any vector outside the span of the previous $i$ independent
columns, and that span has $2^i$ elements, leaving $2^n - 2^i$ choices. Multiplying
gives the stated product. $\square$

**Corollary 7.4 (Four-section symmetry).** For the four-section system,
$$|\mathrm{Aut}(\mathrm{Kin}(2))| = (2^2 - 2^0)(2^2 - 2^1) = 3 \cdot 2 = 6 = 3!,$$
and $GL(2, \mathbb{F}_2) \cong S_3$. The symmetry group acts by permuting the three
nonzero sections — equivalently the three marriage rules of Theorem 4.2 — and
realizes all $3! = 6$ permutations.

*Proof sketch.* $GL(2, \mathbb{F}_2)$ acts faithfully on the three nonzero vectors
of $(\mathbb{F}_2)^2$; this gives an injective homomorphism into $S_3$, and since
both groups have order $6$ it is an isomorphism. $\square$

For the eight-subsection system the symmetry group has order
$$|GL(3, \mathbb{F}_2)| = (2^3 - 1)(2^3 - 2)(2^3 - 4) = 7 \cdot 6 \cdot 4 = 168.$$

---

## 8. The concrete Kariera permutations

To connect the abstract group with the ethnographic vocabulary, fix the standard
$n = 2$ generators. Write a section as $(a, b) \in (\mathbb{Z}/2)^2$.

- **Mother:** translation by $(1, 1)$, sending $(a, b) \mapsto (a + 1, b + 1)$.
- **Spouse:** translation by $(0, 1)$, sending $(a, b) \mapsto (a, b + 1)$.
- **Father:** translation by $(1, 0)$, sending $(a, b) \mapsto (a + 1, b)$.

**Proposition 8.1 (Descent consistency).** Father $=$ Spouse $\circ$ Mother, i.e.
translation by $(1,0)$ equals translation by $(0,1)$ followed by translation by
$(1,1)$.

*Proof sketch.* $(1,1) + (0,1) = (1, 0)$ in $(\mathbb{Z}/2)^2$, and translations add
(Proposition 3.2). $\square$

Proposition 8.1 records the internal consistency of descent and marriage:
a person's father's category is obtained by composing the marriage and maternal
descent rules, reflecting that patrilineal and matrilineal bookkeeping agree.

---

## 9. Discussion

The results assemble into a single coherent picture. A section/subsection system of
"depth" $n$ is the elementary abelian $2$-group $(\mathbb{Z}/2)^n$ (Section 2). Its
kinship steps act simply transitively on the categories (Section 3), so every pair
of categories has a unique connecting relationship. Marriage rules are exactly the
nonzero elements, of which there are $2^n - 1$ (Section 4), and each is governed by
a moiety subgroup of index two, making marriage a coset restriction (Section 5).
Finer systems arise as double covers of coarser ones (Section 6). Finally, the
symmetries of the whole scheme — the relabellings that preserve its structure — form
$GL(n, \mathbb{F}_2)$ (Section 7), which for the four-section system is $S_3$ acting
on the three marriage rules.

The conceptual payoff of working over $\mathbb{F}_2$ is Lemma 7.1: additivity forces
linearity, so there is no gap between "preserves the group law" and "preserves the
linear structure." This is why kinship symmetries are matrices, and why the count is
the classical $GL$ order formula.

---

## 10. Future directions

1. **$GL(2, \mathbb{F}_2) \cong S_3$ as an explicit isomorphism.** We have proved
   the orders agree; constructing the explicit action on the three nonzero
   sections / marriage rules upgrades this to a full group isomorphism.

2. **The affine symmetry group.** The full symmetry group of the *labelled* kinship
   diagram — relabellings not required to fix a distinguished section — is the affine
   group $AGL(n, \mathbb{F}_2) = \mathbb{F}_2^n \rtimes GL(n, \mathbb{F}_2)$, of
   order $2^n \cdot \prod_i (2^n - 2^i)$.

3. **Marriage rules as linear functionals.** Each moiety corresponds to a nonzero
   linear functional $\mathrm{Kin}(n) \to \mathbb{F}_2$; there are $2^n - 1$ of
   them, matching the spectrum count by self-duality of $\mathbb{F}_2^n$. Making
   this duality explicit connects the spectrum count to the hyperplane (moiety)
   count.

4. **General extensions / towers.** The double-cover results exhibit $\mathrm{Kin}(n+1)$
   as a $\mathbb{Z}/2$-extension of $\mathrm{Kin}(n)$. Iterating gives the full
   tower $\mathrm{Kin}(0) \subset \mathrm{Kin}(1) \subset \cdots$; one could
   formalize the composition series and show every quotient is $\mathbb{Z}/2$,
   recovering that $\mathrm{Kin}(n)$ is elementary abelian of length $n$.

5. **Beyond $\mathbb{F}_2$.** Some kinship systems use more than two moiety values.
   Working over $\mathbb{Z}/m$ (or functions into $\mathbb{Z}/m$) and identifying the
   symmetry group as $GL(n, \mathbb{Z}/m)$ would generalize the whole development.

---

## 11. Conclusion

Australian Aboriginal section and subsection systems are not merely *analogous* to
finite groups; up to isomorphism they *are* the elementary abelian $2$-groups
$(\mathbb{Z}/2)^n$, with marriage encoded as coset restriction and refinement
encoded as group extension. The symmetry theorem identifies their relabelling
symmetries with $GL(n, \mathbb{F}_2)$ and, for the four-section case, with $S_3$
acting on the three marriage rules. That a social institution sustained over
millennia should realize so exactly the structure of a binary vector space and its
linear group is a striking instance of mathematical structure discovered in human
practice.
