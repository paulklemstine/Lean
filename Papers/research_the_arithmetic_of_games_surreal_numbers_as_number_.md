# Dyadic Surreal Numbers and Finite Birthdays: The Arithmetic Backbone of Conway's Hierarchy

## Abstract

Conway's surreal numbers $\mathbf{No}$ form a proper-class, real-closed
ordered field that simultaneously contains the real numbers, the ordinal
numbers, and a rich hierarchy of infinite and infinitesimal quantities.
Each surreal number carries a *birthday*, an ordinal recording the stage at
which it is created in Conway's inductive construction. A guiding theme is
that the surreals *born on finite days* are exactly the **dyadic rationals**
$\mathbb{Z}[\tfrac12] = \{ m/2^n : m \in \mathbb{Z},\ n \in \mathbb{N}\}$.
This paper develops the arithmetic core of that picture. We compute the
exact birthday of every power of one half, $\operatorname{birth}(2^{-n}) =
n+1$, and deduce that all such powers are born strictly before the first
infinite day $\omega$. We establish that the powers of one half form a
strictly decreasing sequence of distinct positive elements satisfying the
rescaling law $2^n \cdot 2^{-n} = 1$ and the exponent law $2^{-m}\cdot
2^{-n} = 2^{-(m+n)}$. Building on these, we prove that the canonical map
$\mathbb{Z}[\tfrac12] \to \mathbf{No}$ is an **injective ring
homomorphism**, so that the dyadic rationals embed faithfully into the
surreals both additively and multiplicatively; consequently
$\mathbb{Z}[\tfrac12]$ is ring-isomorphic to the subring of dyadic
surreals. We close by explaining how this finite-birthday layer anchors the
broader program of describing $\mathbf{No}$ as a field of Hahn series, and
we record the precise (and initially surprising) fact that not every
rational—$\tfrac13$ in particular—has a finite birthday.

**Keywords.** surreal numbers, dyadic rationals, birthday, combinatorial
game theory, ordered fields, ring embedding, infinitesimals.

## 1. Introduction

### 1.1 Numbers with birthdays

The surreal numbers arose from John Conway's analysis of two-player
combinatorial games and were popularized in Donald Knuth's novella *Surreal
Numbers* and in Conway's *On Numbers and Games*. Their defining feature is a
recursive construction in which every number is assembled from
*previously constructed* numbers.

**Definition 1.1 (Surreal number, informal).** A surreal number is an
ordered pair $x = \{\, L \mid R \,\}$ of sets $L, R$ of previously
constructed surreal numbers such that no element of $L$ is $\geq$ any element
of $R$. The set $L$ is the *left set* and $R$ the *right set*. Order,
equality, addition, and multiplication are all defined by simultaneous
recursion on this construction.

The recursion is anchored at the empty stage, which produces
$$0 = \{\ \mid\ \}.$$
Each surreal number $x$ is assigned an ordinal **birthday**
$\operatorname{birth}(x)$, the least stage at which a representative of $x$
appears. Equivalently, $\operatorname{birth}(x)$ is one more than the
supremum of the birthdays of the options used to build the simplest
representative of $x$.

**Definition 1.2 (Finite-birthday surreals).** Write $\mathbf{No}_\omega$
for the collection of surreal numbers $x$ with $\operatorname{birth}(x) <
\omega$, i.e. with finite birthday. These are the numbers created on the
finite days $0, 1, 2, \ldots$

The organizing conjecture of this subject, essentially due to Conway, is:

> **Guiding statement.** $\mathbf{No}_\omega = \mathbb{Z}[\tfrac12]$, the
> ring of dyadic rationals.

### 1.2 What this paper proves

We do not settle the full identity $\mathbf{No}_\omega =
\mathbb{Z}[\tfrac12]$ here (the converse containment requires the
*simplicity theorem*; see §7). Instead we establish the arithmetic backbone
that makes the identity meaningful: that $\mathbb{Z}[\tfrac12]$ *does* live
faithfully inside $\mathbf{No}$ with the expected finite birthdays. The main
contributions are:

1. **Exact birthdays** (Theorem 3.1): $\operatorname{birth}(2^{-n}) = n+1$,
   and hence $\operatorname{birth}(2^{-n}) < \omega$ (Corollary 3.2).
2. **Order and scaling of half-powers** (Theorems 4.1–4.5): the powers of
   one half are positive, strictly decreasing, pairwise distinct, and
   satisfy $2^n \cdot 2^{-n} = 1$.
3. **Faithful additive embedding** (Theorem 5.1): the canonical additive map
   $\mathbb{Z}[\tfrac12] \to \mathbf{No}$ is injective, and its image is an
   additive subgroup group-isomorphic to $\mathbb{Z}[\tfrac12]$
   (Theorem 5.4).
4. **Multiplicativity and the ring embedding** (Theorems 6.1–6.4): the
   exponent law $2^{-m}\cdot 2^{-n} = 2^{-(m+n)}$ holds, the embedding is
   unital and multiplicative, and therefore $\mathbb{Z}[\tfrac12]$ embeds as
   a subring of $\mathbf{No}$ and is ring-isomorphic to the subring of
   dyadic surreals.

These results resolve two long-standing loose ends in the standard
development of surreal arithmetic: that the map from dyadic rationals into
the surreals is injective, and that it is multiplicative.

## 2. Preliminaries

### 2.1 The ordered field of surreals

We take as given the standard facts that $\mathbf{No}$, modulo the
equivalence "$x = y$ iff $x \le y$ and $y \le x$," is a totally ordered
field: addition, negation, and multiplication are well defined, associative,
commutative, and distributive; $0$ and $1$ are the additive and
multiplicative identities; every nonzero element has a multiplicative
inverse; and the order is compatible with the field operations. In
particular $\mathbf{No}$ is an **integral domain**: if $ab = 0$ then $a = 0$
or $b = 0$.

We work throughout with the *value* (equivalence class) of a surreal number
when discussing the field structure, and with a specific representative
(a *game*) when discussing birthdays, which are invariant under the
identification of a numeric game with its simplest form.

### 2.2 The powers of one half

**Definition 2.1 (Powers of one half).** Define the surreal numbers
$2^{-n}$ for $n \in \mathbb{N}$ recursively by
$$2^{-0} = 1, \qquad 2^{-(n+1)} = \Bigl\{\, 0 \ \Big|\ 2^{-n} \,\Bigr\}.$$
Thus $2^{-1} = \{0 \mid 1\} = \tfrac12$, $2^{-2} = \{0 \mid \tfrac12\} =
\tfrac14$, and so on. We also write $\operatorname{ph}(n) := 2^{-n}$ when
convenient.

**Definition 2.2 (The dyadic rationals as a localization).** The ring of
dyadic rationals is
$$\mathbb{Z}\!\left[\tfrac12\right] = \{ m/2^n : m \in \mathbb{Z},\ n \in
\mathbb{N} \},$$
canonically the localization of $\mathbb{Z}$ at the multiplicative set of
powers of $2$. A general element is an equivalence class of pairs $(m, s)$
with $m \in \mathbb{Z}$ and $s$ a power of $2$, written $m/s$; when $s =
2^n$ we identify the exponent $n$ as the "height" of the denominator.

**Definition 2.3 (The canonical dyadic map).** Let
$$\Phi : \mathbb{Z}\!\left[\tfrac12\right] \longrightarrow \mathbf{No}$$
be the map determined by $\Phi(m/2^n) = m \cdot 2^{-n}$, where $m \cdot (\ )$
denotes the $m$-fold additive multiple (integer scaling). By construction
$\Phi$ is an additive homomorphism; the content of §5–§6 is that it is
injective and multiplicative.

## 3. The birthdays of the powers of one half

**Theorem 3.1 (Exact birthday).** For every $n \in \mathbb{N}$,
$$\operatorname{birth}(2^{-n}) = n + 1.$$

*Proof sketch.* Induct on $n$. For $n = 0$, $2^{-0} = 1 = \{0 \mid\ \}$ is
built from the single option $0$ (born on day $0$), so its birthday is
$0 + 1 = 1$. For the step, $2^{-(n+1)} = \{0 \mid 2^{-n}\}$ has left option
$0$ (birthday $0$) and right option $2^{-n}$ (birthday $n+1$ by the
inductive hypothesis). The birthday of a numeric game is the successor of
the supremum of the birthdays of the options of its simplest form; here that
supremum is $\max(0, n+1) = n+1$, giving birthday $(n+1) + 1$, as required.
The case $n=1$ recovers the classical fact $\operatorname{birth}(\tfrac12) =
2$. $\qquad\blacksquare$

**Corollary 3.2 (Finite birthday).** For every $n$, $\operatorname{birth}
(2^{-n}) < \omega$. Hence every power of one half lies in
$\mathbf{No}_\omega$.

*Proof.* $\operatorname{birth}(2^{-n}) = n+1$ is a finite ordinal, and every
finite ordinal is $< \omega$. $\qquad\blacksquare$

This already produces an *infinite* family of finite-birthday surreals
realizing the values $2^{-n}$, with a transparent correspondence between the
denominator height $n$ and the birthday $n+1$.

## 4. Order structure of the half-powers

**Theorem 4.1 (Positivity).** For every $n$, $\ 0 < 2^{-n}$.

*Proof sketch.* Induct using the recursion of Definition 2.1. The number
$2^{-(n+1)} = \{0 \mid 2^{-n}\}$ has $0$ as a left option, so it is $\ge 0$;
strictness follows because its unique right option $2^{-n}$ is itself
positive by the inductive hypothesis, so $0$ is strictly dominated. $\qquad
\blacksquare$

**Corollary 4.2 (Nonvanishing).** $2^{-n} \ne 0$ for all $n$.

**Theorem 4.3 (Strict decrease).** For every $n$, $\ 2^{-(n+1)} < 2^{-n}$.

*Proof sketch.* The number $2^{-(n+1)} = \{0 \mid 2^{-n}\}$ has $2^{-n}$ as
its right option, and a numeric game is strictly less than each of its right
options. $\qquad\blacksquare$

**Theorem 4.4 (Strict antitonicity and distinctness).** The map
$n \mapsto 2^{-n}$ is strictly decreasing, hence injective. Thus the values
$1 > \tfrac12 > \tfrac14 > \cdots$ are pairwise distinct.

*Proof.* Strict decrease at each successor (Theorem 4.3) upgrades to strict
antitonicity on all of $\mathbb{N}$ by the standard principle that a
sequence decreasing at every successor step is strictly antitone; a strictly
monotone map is injective. $\qquad\blacksquare$

**Theorem 4.5 (Rescaling law).** For every $n$,
$$2^{n} \cdot 2^{-n} = 1,$$
where $2^n$ denotes the $n$-th power of the surreal number $2$ and the
product is surreal multiplication.

*Proof sketch.* This is the surreal reflection of the identity defining
$2^{-n}$ as the multiplicative reciprocal of $2^n$; it follows from the
recursive computation of $2 \cdot 2^{-(n+1)} = 2^{-n}$ and induction, or
directly from the scaled-doubling identity for half-powers. $\qquad
\blacksquare$

Theorem 4.5 is the crucial bridge from *order* to *arithmetic*: it certifies
that $2^{-n}$ is not merely a small positive number but the genuine
multiplicative inverse of $2^n$ in the field $\mathbf{No}$.

## 5. The dyadic rationals embed additively

**Theorem 5.1 (Injectivity of the dyadic map).** The additive homomorphism
$\Phi : \mathbb{Z}[\tfrac12] \to \mathbf{No}$ of Definition 2.3 is
injective.

*Proof.* Since $\Phi$ is a homomorphism of additive groups, injectivity is
equivalent to triviality of the kernel: it suffices to show $\Phi(q) = 0
\implies q = 0$. Write a general element as $q = m/2^n$, so that $\Phi(q) =
m \cdot 2^{-n} = (m : \mathbf{No}) \cdot 2^{-n}$, the product of the surreal
integer $m$ with the half-power $2^{-n}$. Suppose this product is $0$.
Because $\mathbf{No}$ is an integral domain, either $(m : \mathbf{No}) = 0$
or $2^{-n} = 0$. The latter is impossible by Corollary 4.2, so
$(m : \mathbf{No}) = 0$, whence $m = 0$ (the integers embed in $\mathbf{No}$
without collapse). Therefore $q = 0/2^n = 0$. $\qquad\blacksquare$

**Definition 5.2 (The dyadic subgroup).** Let $D := \operatorname{im}\Phi
\subseteq \mathbf{No}$, the image of $\Phi$, an additive subgroup of
$\mathbf{No}$. Its elements are the **dyadic surreals**.

**Proposition 5.3 (Membership and half-powers).**
(i) $x \in D$ iff $x = \Phi(q)$ for some dyadic rational $q$.
(ii) The set $D$ coincides with the range of $\Phi$ as a subset of
$\mathbf{No}$.
(iii) Every half-power lies in $D$: $2^{-n} \in D$ for all $n$, since
$2^{-n} = \Phi(1/2^n)$.

*Proof.* Immediate from the definitions; for (iii) note $\Phi(1/2^n) = 1
\cdot 2^{-n} = 2^{-n}$. $\qquad\blacksquare$

**Theorem 5.4 (Additive isomorphism).** The map $\Phi$ induces an
isomorphism of additive groups
$$\mathbb{Z}\!\left[\tfrac12\right] \ \xrightarrow{\ \cong\ }\ D.$$

*Proof.* $\Phi$ is a surjection onto its image $D$ by definition, and an
injection by Theorem 5.1; an injective, surjective group homomorphism is an
isomorphism onto its image. $\qquad\blacksquare$

## 6. Multiplicativity and the ring embedding

The results of §5 show that $\mathbb{Z}[\tfrac12]$ embeds *additively*. We
now upgrade to a *ring* embedding. The heart of the matter is a single
identity.

**Theorem 6.1 (Exponent law for half-powers).** For all $m, n \in
\mathbb{N}$,
$$2^{-m} \cdot 2^{-n} = 2^{-(m+n)}.$$

*Proof.* Multiply both sides by the nonzero surreal scalar $2^{m+n}$. On the
left,
$$2^{m+n}\cdot(2^{-m}\cdot 2^{-n}) = (2^m \cdot 2^{-m})(2^n \cdot 2^{-n}) =
1 \cdot 1 = 1$$
using commutativity, associativity, and the rescaling law (Theorem 4.5)
twice. On the right, $2^{m+n} \cdot 2^{-(m+n)} = 1$ by the same law. Thus
both sides become $1$ after multiplication by $2^{m+n}$. Since $2^{m+n} \ne
0$ and $\mathbf{No}$ is a field, multiplication by $2^{m+n}$ is injective, so
the original two sides are equal. $\qquad\blacksquare$

**Theorem 6.2 (Unitality).** $\Phi(1) = 1$, i.e. $\Phi$ sends the
multiplicative unit of $\mathbb{Z}[\tfrac12]$ to the surreal $1$.

*Proof sketch.* The unit $1 \in \mathbb{Z}[\tfrac12]$ is represented by the
fraction $1/2^0$, and $\Phi(1/2^0) = 1\cdot 2^{-0} = 1\cdot 1 = 1$; the
computation is a special case of the exponent law with $m=n=0$. $\qquad
\blacksquare$

**Theorem 6.3 (Multiplicativity).** For all $x, y \in \mathbb{Z}[\tfrac12]$,
$$\Phi(x \cdot y) = \Phi(x)\cdot\Phi(y).$$

*Proof sketch.* Reduce to representatives $x = a/2^m$ and $y = b/2^n$. Then
$xy = ab/2^{m+n}$, so $\Phi(xy) = (ab)\cdot 2^{-(m+n)}$. On the other side,
$$\Phi(x)\Phi(y) = (a\cdot 2^{-m})(b\cdot 2^{-n}) = (ab)\cdot(2^{-m}\cdot
2^{-n}) = (ab)\cdot 2^{-(m+n)}$$
using bilinearity of surreal multiplication over integer scaling together
with the exponent law (Theorem 6.1). The two expressions agree, and one
checks the computation is independent of the chosen representatives because
$\Phi$ is already well defined. $\qquad\blacksquare$

**Theorem 6.4 (The dyadic ring embedding).** The map $\Phi$ is an injective
ring homomorphism
$$\Phi : \mathbb{Z}\!\left[\tfrac12\right] \hookrightarrow \mathbf{No}.$$
Its image is a subring $D \subseteq \mathbf{No}$ (the dyadic surreals), and
$\Phi$ induces a ring isomorphism
$$\mathbb{Z}\!\left[\tfrac12\right] \ \xrightarrow{\ \cong\ }\ D.$$

*Proof.* By construction $\Phi$ is additive (Definition 2.3), unital
(Theorem 6.2), and multiplicative (Theorem 6.3), hence a ring homomorphism;
it is injective by Theorem 5.1. A ring homomorphism is a ring isomorphism
onto its image precisely when it is injective, and the image of a ring
homomorphism is a subring. $\qquad\blacksquare$

Theorem 6.4 is the paper's culminating statement: the countable ring
$\mathbb{Z}[\tfrac12]$ sits inside the proper-class field $\mathbf{No}$ as a
genuine subring, an exact algebraic replica, and every one of its elements
has finite birthday.

## 7. Discussion: the finite-birthday layer

### 7.1 Not every rational is dyadic

It is tempting to conjecture that $\mathbf{No}_\omega$ contains all rational
numbers, or all algebraic numbers of bounded complexity. This is false in an
instructive way. The number $\tfrac13$ has *no finite birthday*: it is the
value $\{ \tfrac14, \tfrac{5}{16}, \ldots \mid \tfrac12, \tfrac38, \ldots\}$
obtained as the common limit of the binary approximations to $\tfrac13$ from
below and above, and this limit is not reached until day $\omega$. The
reason is structural: the surreal construction inserts *simplest midpoints*,
and midpoints of dyadic endpoints are again dyadic. Only binary
subdivision—never division by an odd number—occurs at finite stages, so the
finite-birthday field is exactly $\mathbb{Z}[\tfrac12]$ and nothing larger.
This corrects a natural but mistaken guess that the finite-birthday numbers
might be $\mathbb{Q}$ or $\mathbb{Q}$ together with the dyadics.

### 7.2 The road to the reals and beyond

The results here are the base of a tower. The natural next results, discussed
in §8, extend $\Phi$ to an ordered-field embedding of $\mathbb{R}$ (whose
image is realized by day $\omega$ via dyadic Dedekind cuts), introduce the
smallest positive infinitesimal $\varepsilon = \{0 \mid 1, \tfrac12,
\tfrac14, \ldots\}$ at day $\omega$, and eventually reach the Conway–Gonshor
normal form describing $\mathbf{No}$ as a field of Hahn series
$\mathbb{R}((t^{\mathbf{No}}))$. In this larger picture the finite-birthday
dyadics are the seed crystal: the entire real line is their metric
completion, and the entire surreal field is their transfinite
elaboration.

### 7.3 An ordinal-strength remark

Injectivity of $\Phi$ and the induced isomorphism $\mathbb{Z}[\tfrac12]
\cong D$ show that a *countable* field sits faithfully inside the
*proper-class* field $\mathbf{No}$, and does so entirely within the
finite-birthday fragment. In other words, the whole of dyadic arithmetic is
already visible in the first $\omega$ days of creation—no infinite
birthdays are needed to see the ring $\mathbb{Z}[\tfrac12]$ in full.

## 8. Future directions

1. **$\mathbf{No}_\omega$ is exactly $\mathbb{Z}[\tfrac12]$.** Prove the
   converse containment: every surreal with finite birthday is dyadic. The
   simplicity theorem—that a numeric game equals the simplest number
   strictly between its options—combined with the birthday bounds proved
   here pins $\mathbf{No}_\omega$ down to $\mathbb{Z}[\tfrac12]$. Note the
   informal conjecture that $\mathbf{No}_\omega = \mathbb{Q} +
   \text{dyadics}$ is *false*: $\tfrac13 \notin \mathbf{No}_\omega$.

2. **Reals into surreals.** Extend $\Phi$ along dyadic Dedekind cuts /
   Cauchy sequences to an ordered-field embedding $\mathbb{R}
   \hookrightarrow \mathbf{No}$. The image is exactly the day-$\omega$
   completion of the dyadic surreals.

3. **Birthdays of sums and products.** Characterize the birthday of a
   general dyadic surreal $m\cdot 2^{-n}$, matching the denominator height
   $n+1$ together with a term counting the binary length of $m$.

4. **Day $\omega$ and infinitesimals.** Formalize the smallest positive
   infinitesimal $\varepsilon = \{0 \mid 1, \tfrac12, \tfrac14, \ldots\}$,
   prove $0 < \varepsilon < 2^{-n}$ for all $n$, and begin the structure
   theory of $\mathbf{No}_{\omega\cdot 2}$ and $\mathbf{No}_{\omega^2}$
   toward the Hahn-series description $\mathbf{No} \cong
   \mathbb{R}((t^{\mathbf{No}}))$ of Conway and Gonshor.

## 9. Conclusion

We have established the arithmetic backbone of the "finite-birthday surreals
are dyadic" program: exact birthdays $\operatorname{birth}(2^{-n}) = n+1$;
the order-theoretic and scaling properties of the half-powers; the
injectivity of the canonical dyadic map; and its multiplicativity, yielding
a faithful ring embedding $\mathbb{Z}[\tfrac12] \hookrightarrow \mathbf{No}$
with image an isomorphic subring. Together these results certify that the
dyadic rationals live inside Conway's number-universe exactly as expected,
with the birthdays their construction predicts—and they set the stage for
embedding the reals and charting the infinitesimal layers beyond day
$\omega$.

## References

- J. H. Conway, *On Numbers and Games*, 2nd ed., A K Peters, 2001.
- H. Gonshor, *An Introduction to the Theory of Surreal Numbers*, London
  Mathematical Society Lecture Note Series 110, Cambridge University Press,
  1986.
- D. E. Knuth, *Surreal Numbers*, Addison-Wesley, 1974.
- E. Berlekamp, J. H. Conway, R. Guy, *Winning Ways for Your Mathematical
  Plays*, 2nd ed., A K Peters, 2001.
