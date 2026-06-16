# Tropical Extremal-Support Profiles of Finitely Supported Rational Sequences, with a Combinatorial-Species Corollary

## Abstract

We study the two extremal indices of a finitely supported rational sequence
$f \colon \mathbb{N} \to \mathbb{Q}$ — its **order** (the least index in the
support) and its **degree** (the greatest index in the support) — and prove that
they form a faithful pair of valuations into the tropical semiring. Under
pointwise addition the indices satisfy only the nonarchimedean inequalities
$\min(\operatorname{ord} f, \operatorname{ord} g) \le \operatorname{ord}(f+g)$ and
$\deg(f+g) \le \max(\deg f, \deg g)$, reflecting the possibility of leading- and
trailing-term cancellation. Under the Cauchy convolution they add *exactly*:
$\operatorname{ord}(f * g) = \operatorname{ord} f + \operatorname{ord} g$ and
$\deg(f * g) = \deg f + \deg g$. The exactness rests on a single structural
observation — the **unique extremal contributing pair** — combined with the fact
that $\mathbb{Q}$ is an integral domain. Carrying these laws across the
exponential-generating-function (EGF) bridge of Joyal's theory of combinatorial
species, we obtain a corollary on the binomial (exponential) convolution: the
minimal size of a structure built as the product of two species equals the sum of
the minimal sizes of the factors, and such a minimal structure provably exists.
All results are stated over $\mathbb{N} \to_{\!f} \mathbb{Q}$ (finitely supported
sequences), with the empty-support conventions $\operatorname{ord} 0 = \top$ and
$\deg 0 = \bot$ in the completed orders $\overline{\mathbb{N}} = \mathbb{N} \cup \{\top\}$
and $\mathbb{N} \cup \{\bot\}$.

## 1. Introduction

### 1.1 Motivation

The two outermost terms of a polynomial — its lowest- and highest-degree nonzero
monomials — control a remarkable amount of its algebraic behaviour. The degree is
the most basic invariant of a polynomial ring; the order (or valuation) is the most
basic invariant of a power-series ring or of a localization at a prime. Both are
instances of a single notion, the *extremal support index*, and both are governed
by an arithmetic that is not the arithmetic of the coefficients but rather the
**tropical** (min-plus / max-plus) arithmetic of the indices.

This paper isolates that arithmetic in the cleanest possible setting — finitely
supported sequences over a field — proves the four governing laws (two
inequalities for addition, two equalities for convolution), and then transports the
order law across the classical combinatorics-to-analysis dictionary supplied by
exponential generating functions and Joyal's combinatorial species. The result is a
self-contained account of why "minimal structure sizes add under structural
product," a fact that is folklore in enumerative combinatorics but rarely stated as
a theorem about valuations.

### 1.2 Contributions

1. A clean definition of the order and degree of a finitely supported sequence,
   valued in the order-completions $\overline{\mathbb{N}}$ (with top) and
   $\mathbb{N}_\bot$ (with bottom), together with a small but complete API of
   extremal-characterisation lemmas (Section 3).
2. The tropical inequalities for addition (Theorem 4.1, Theorem 4.2).
3. The exact additivity of order and degree under the finitely supported Cauchy
   convolution (Theorem 6.1, Theorem 6.2), via the unique-extremal-pair argument.
4. A downstream corollary for combinatorial species: the extremal profile of a
   binomial convolution, hence the additivity of minimal structure sizes under the
   structural product of species (Section 7).

### 1.3 Related context

The order map is the archetypal *nonarchimedean valuation*; its target, the tropical
semiring $(\overline{\mathbb{N}}, \min, +)$, is the central object of tropical
geometry. The bridge from counting sequences to power series is Joyal's theory of
species, in which the four fundamental operations (sum, product, derivative,
composition) correspond to the four operations on exponential generating functions.
The present work occupies the intersection: it equips the species bridge with the
valuation-theoretic structure of the tropical semiring.

## 2. Setting and notation

Throughout, $f, g \colon \mathbb{N} \to_{\!f} \mathbb{Q}$ denote **finitely
supported** rational sequences; equivalently, elements of the free $\mathbb{Q}$-module
$\mathbb{N} \to_{\!f} \mathbb{Q}$ on $\mathbb{N}$, which one may picture as
polynomials in a formal variable with rational coefficients. We write $f_n$ for the
value of $f$ at $n$ and

$$
\operatorname{supp}(f) = \{ n \in \mathbb{N} : f_n \neq 0 \}
$$

for its (finite) support.

We use two order-completions of $\mathbb{N}$:

- $\overline{\mathbb{N}} = \mathbb{N} \cup \{\top\}$, the naturals with a greatest
  element $\top$ adjoined (a `WithTop`);
- $\mathbb{N}_\bot = \mathbb{N} \cup \{\bot\}$, the naturals with a least element
  $\bot$ adjoined (a `WithBot`).

Both carry the obvious total order extending that of $\mathbb{N}$, the lattice
operations $\min$ and $\max$, and a commutative additive monoid structure with
$\top$ (resp. $\bot$) absorbing: $n + \top = \top$ and $n + \bot = \bot$.

## 3. Extremal-support indices

### 3.1 Definitions

**Definition 3.1 (Order / valuation).**
The *order* of $f$ is the minimum of its support,
$$
\operatorname{ord} f \;=\; \min \operatorname{supp}(f) \;\in\; \overline{\mathbb{N}},
\qquad \operatorname{ord} 0 = \top .
$$

**Definition 3.2 (Degree).**
The *degree* of $f$ is the maximum of its support,
$$
\deg f \;=\; \max \operatorname{supp}(f) \;\in\; \mathbb{N}_\bot,
\qquad \deg 0 = \bot .
$$

The boundary conventions $\operatorname{ord} 0 = \top$ and $\deg 0 = \bot$ are forced
by taking the min/max over the empty set in a bounded lattice and are precisely what
make the convolution laws of Section 6 hold without exceptions.

### 3.2 Basic support API

The following lemmas constitute the working interface. Each is elementary but used
repeatedly.

**Lemma 3.3 (Order is a lower bound).** If $f_n \neq 0$ then
$\operatorname{ord} f \le n$.
*Proof.* $n \in \operatorname{supp}(f)$, and the minimum of a finite set is $\le$ any
of its elements. ∎

**Lemma 3.4 (Degree is an upper bound).** If $f_n \neq 0$ then
$n \le \deg f$. *Proof.* Dual to Lemma 3.3. ∎

**Lemma 3.5 (Vanishing below the order).** If $n < \operatorname{ord} f$ then
$f_n = 0$. *Proof.* Contrapositive of Lemma 3.3. ∎

**Lemma 3.6 (Vanishing above the degree).** If $\deg f < n$ then $f_n = 0$.
*Proof.* Contrapositive of Lemma 3.4. ∎

**Lemma 3.7 (The order index is occupied).** If $\operatorname{ord} f = n$ (with
$n \in \mathbb{N}$) then $f_n \neq 0$. *Proof.* The minimum of a nonempty finite set
is a member of that set, hence lies in $\operatorname{supp}(f)$. ∎

**Lemma 3.8 (The degree index is occupied).** If $\deg f = n$ then $f_n \neq 0$.
*Proof.* Dual to Lemma 3.7. ∎

**Lemma 3.9 (Realisation of the order).** If $f \neq 0$ then there exists
$n \in \mathbb{N}$ with $\operatorname{ord} f = n$ and $f_n \neq 0$. *Proof.* Take the
least $n$ with $f_n \neq 0$ (it exists by well-ordering of $\mathbb{N}$ and $f \neq 0$);
all smaller indices vanish, so by antisymmetry of the bounds this $n$ realises the
minimum. ∎

**Lemma 3.10 (Realisation of the degree).** If $f \neq 0$ then there exists
$n \in \mathbb{N}$ with $\deg f = n$ and $f_n \neq 0$. *Proof.* The support is finite
and nonempty, so it has a maximum; that maximum is a member, hence occupied. ∎

### 3.3 Extremal characterisations (the workhorses)

The next two lemmas are the engines driving every later theorem: they recognise the
order and degree from a single occupied index together with a one-sided vanishing
condition.

**Lemma 3.11 (Characterisation of order).** Suppose $f_n \neq 0$ and $f_m = 0$ for
all $m < n$. Then $\operatorname{ord} f = n$.
*Proof.* $\le$: by Lemma 3.3, $\operatorname{ord} f \le n$. $\ge$: every element of
$\operatorname{supp}(f)$ is $\ge n$, since any index $< n$ has a vanishing coefficient
by hypothesis; the minimum therefore is $\ge n$. Antisymmetry gives equality. ∎

**Lemma 3.12 (Characterisation of degree).** Suppose $f_n \neq 0$ and $f_m = 0$ for
all $m > n$. Then $\deg f = n$. *Proof.* Dual to Lemma 3.11. ∎

## 4. The tropical laws for addition

**Theorem 4.1 (Order is min-superadditive).** For all $f, g$,
$$
\min(\operatorname{ord} f,\ \operatorname{ord} g) \;\le\; \operatorname{ord}(f + g).
$$
*Proof.* If $(f+g)_n \neq 0$ then $f_n \neq 0$ or $g_n \neq 0$, so by Lemma 3.3
$\operatorname{ord} f \le n$ or $\operatorname{ord} g \le n$; in either case
$\min(\operatorname{ord} f, \operatorname{ord} g) \le n$. As this holds for every index
in $\operatorname{supp}(f+g)$, it holds for the minimum of that support, namely
$\operatorname{ord}(f+g)$. (The boundary cases where one summand is $0$ are absorbed
by $\top$.) ∎

**Theorem 4.2 (Degree is max-subadditive).** For all $f, g$,
$$
\deg(f + g) \;\le\; \max(\deg f,\ \deg g).
$$
*Proof.* Dual to Theorem 4.1, using Lemma 3.4 and $\bot$ for the boundary cases. ∎

**Remark 4.3 (Strictness and the ultrametric refinement).** Both inequalities can be
strict: with $f = x^9$ and $g = x^3 - x^9$ one has $\deg(f+g) = 3 < 9 = \max(\deg f, \deg g)$.
The general principle from nonarchimedean theory is that **equality holds whenever
the two extremal indices differ** — if $\operatorname{ord} f \neq \operatorname{ord} g$,
then $\operatorname{ord}(f+g) = \min(\operatorname{ord} f, \operatorname{ord} g)$,
because the lower of the two leading terms has no partner to cancel against. The
inequality form proved here is the robust statement that holds unconditionally; the
sharp equality is recorded as Conjecture C1 in Section 8.

## 5. The finitely supported Cauchy convolution

**Definition 5.1 (Cauchy convolution coefficient).** For $f, g$ and $n \in \mathbb{N}$,
$$
(f * g)_n \;=\; \sum_{i=0}^{n} f_i \cdot g_{n-i}
\;=\; \sum_{i + j = n} f_i\, g_j .
$$

**Lemma 5.2 (Support bound).** $(f * g)_n \neq 0$ implies
$n \le \sup \operatorname{supp}(f) + \sup \operatorname{supp}(g)$.
*Proof.* If $n$ exceeds that bound, then in every split $i + j = n$ either
$i > \sup \operatorname{supp}(f)$ (so $f_i = 0$) or $j > \sup \operatorname{supp}(g)$
(so $g_j = 0$); every summand vanishes and the sum is $0$. ∎

Lemma 5.2 shows the coefficient function $n \mapsto (f*g)_n$ has finite support, so
it defines a genuine finitely supported sequence:

**Definition 5.3 (Convolution).** $f * g$ is the finitely supported sequence with
coefficients $(f * g)_n$ as in Definition 5.1, with support contained in
$\{0, 1, \dots, \sup \operatorname{supp}(f) + \sup \operatorname{supp}(g)\}$.

This is the Cauchy product of the corresponding polynomials/power series. We record
the immediate degenerate identities $0 * g = 0$ and $f * 0 = 0$.

## 6. Exact additivity under convolution

This is the technical heart of the paper.

**Theorem 6.1 (Order is exactly additive).** For all $f, g$,
$$
\operatorname{ord}(f * g) \;=\; \operatorname{ord} f + \operatorname{ord} g
$$
in $\overline{\mathbb{N}}$ (with $n + \top = \top$).

*Proof.* If $f = 0$ or $g = 0$ both sides are $\top$. Otherwise, by Lemma 3.9 write
$a = \operatorname{ord} f$ and $b = \operatorname{ord} g$ with $f_a \neq 0$, $g_b \neq 0$,
$f_i = 0$ for $i < a$, and $g_j = 0$ for $j < b$. We apply the characterisation
Lemma 3.11 to $f * g$ at the index $n = a + b$.

*The coefficient at $a+b$ is nonzero.* Consider the convolution sum
$(f * g)_{a+b} = \sum_{i+j=a+b} f_i g_j$. In any split, if $i < a$ then $f_i = 0$;
if $i > a$ then $j = a + b - i < b$, so $g_j = 0$. Hence **the only surviving split is
the unique extremal pair $(i, j) = (a, b)$**, giving
$$
(f * g)_{a+b} = f_a \, g_b .
$$
Because $\mathbb{Q}$ is an integral domain and $f_a, g_b \neq 0$, this product is
nonzero.

*All lower coefficients vanish.* For $n < a + b$ and any split $i + j = n$, we cannot
have both $i \ge a$ and $j \ge b$ (that would force $n \ge a+b$); so $i < a$ or
$j < b$, whence $f_i = 0$ or $g_j = 0$ and the term vanishes. Thus $(f*g)_n = 0$ for
all $n < a + b$.

By Lemma 3.11, $\operatorname{ord}(f * g) = a + b = \operatorname{ord} f + \operatorname{ord} g$. ∎

**Theorem 6.2 (Degree is exactly additive).** For all $f, g$,
$$
\deg(f * g) \;=\; \deg f + \deg g
$$
in $\mathbb{N}_\bot$ (with $n + \bot = \bot$).

*Proof.* Dual to Theorem 6.1. With $f, g \neq 0$, set $a = \deg f$, $b = \deg g$.
In $(f*g)_{a+b} = \sum_{i+j=a+b} f_i g_j$, any split with $i > a$ kills $f_i$, and any
split with $i < a$ forces $j > b$ and kills $g_j$; the unique surviving pair is
$(a, b)$, so $(f*g)_{a+b} = f_a g_b \neq 0$ by integrality. For $n > a+b$ no split can
have both $i \le a$ and $j \le b$, so $(f*g)_n = 0$. Lemma 3.12 gives the claim. ∎

**Corollary 6.3 (Tropical homomorphism).** The map
$f \mapsto (\operatorname{ord} f,\ \deg f)$ sends convolution to coordinatewise
addition and addition to the pair $(\ge\min,\ \le\max)$. Equivalently,
$\operatorname{ord}$ is a homomorphism from $(\mathbb{N} \to_{\!f} \mathbb{Q}, +, *)$ to the
tropical (min-plus) semiring $(\overline{\mathbb{N}}, \min, +)$ in the lax sense:
exact on the multiplicative structure, super-additive on the additive structure;
and $\deg$ is its order-reversed (max-plus) counterpart.

The phrase "unique extremal contributing pair" names the structural mechanism behind
Theorems 6.1–6.2: among all $\binom{?}{?}$ splits of the extremal index, exactly one
is supported on both factors, and the integral-domain hypothesis converts its
nonvanishing factors into a nonvanishing product. The same mechanism underlies the
classical theorem $\deg(pq) = \deg p + \deg q$ for polynomials over a domain.

## 7. Downstream corollary: combinatorial species and EGFs

### 7.1 The species bridge

To a counting sequence $a \colon \mathbb{N} \to \mathbb{Q}$ — for instance
$a_n = |F[n]|$, the number of $F$-structures on an $n$-element label set for a
combinatorial species $F$ — one associates the **exponential generating function**
$$
\mathrm{EGF}(a) \;=\; \sum_{n \ge 0} \frac{a_n}{n!}\, x^n .
$$
Joyal's product of species corresponds, on counting sequences, to the **binomial
(exponential) convolution**
$$
(a \star b)_n \;=\; \sum_{i=0}^{n} \binom{n}{i}\, a_i\, b_{n-i} ,
$$
and the fundamental bridge theorem is that $\mathrm{EGF}(a \star b) = \mathrm{EGF}(a)\cdot \mathrm{EGF}(b)$,
i.e. the EGF transforms the binomial convolution into the ordinary product of power
series.

### 7.2 The extremal profile of a binomial convolution

The order of a counting sequence has a direct combinatorial reading: it is the
**smallest size at which a structure exists**. Restricting to finitely supported $a, b$
(species with structures only up to a bounded size), the binomial convolution differs
from the Cauchy convolution only by the strictly positive weights $\binom{n}{i}$.
These weights do not change *which* splits contribute at the extremal index, only the
nonzero value carried there. The unique-extremal-pair argument therefore applies
verbatim:

**Corollary 7.1 (Binomial-convolution extremal profile).** For finitely supported
$a, b \colon \mathbb{N} \to_{\!f} \mathbb{Q}$,
$$
\operatorname{ord}(a \star b) = \operatorname{ord} a + \operatorname{ord} b,
\qquad
\deg(a \star b) = \deg a + \deg b .
$$
*Proof.* At $n = \operatorname{ord} a + \operatorname{ord} b$ the only surviving split is
$(\operatorname{ord} a, \operatorname{ord} b)$, contributing
$\binom{n}{\operatorname{ord} a}\, a_{\operatorname{ord} a}\, b_{\operatorname{ord} b}$.
The binomial coefficient is a positive integer, the two factors are nonzero by
definition of the order, and $\mathbb{Q}$ is a domain, so the product is nonzero; all
lower coefficients vanish exactly as in Theorem 6.1. The degree statement is dual. ∎

### 7.3 Combinatorial meaning

Corollary 7.1 says: **the minimal size of a structure for the product species $F \cdot G$
is the sum of the minimal sizes for $F$ and for $G$, and such a minimal structure
genuinely exists.** If the smallest $F$-structure occupies $a$ labels and the smallest
$G$-structure occupies $b$ labels, then the smallest $F \cdot G$-structure occupies
$a + b$ labels — partition $a+b$ labels into the unique compatible blocks, place the
minimal $F$- and $G$-structures, and count with $\binom{a+b}{a} > 0$ ways to do so.
The degree statement says the *largest* size at which the product species has any
structure is likewise the sum of the largest sizes of the factors. This is the
valuation-theoretic skeleton of the species product law.

## 8. Discussion and future work

The four laws — two inequalities, two equalities — exhibit the extremal-support
profile as a lax morphism into the tropical semiring, exact on multiplication and
relaxed on addition. We highlight three directions, in increasing order of ambition.

**C1 — Sharp ultrametric equality at distinct leading orders (likely provable).**
The addition law of Theorem 4.1 is an inequality; nonarchimedean theory predicts
equality whenever the extremal indices differ. Precisely: if
$\operatorname{ord} f \neq \operatorname{ord} g$ then
$\operatorname{ord}(f + g) = \min(\operatorname{ord} f, \operatorname{ord} g)$, with the
dual statement for the degree. This upgrades $\operatorname{ord}$ to an exact tropical
valuation off the diagonal $\operatorname{ord} f = \operatorname{ord} g$, and says
combinatorially that the disjoint union of two species with distinct minimal sizes has
minimal size the smaller of the two.

**C2 — Substitution / composition is tropically multiplicative (bold).** Species
composition $F \circ G$ (with $G$ having no empty structure) corresponds to power-series
substitution. We conjecture that if $g$ has order $\ge 1$ (vanishing constant term),
then $\operatorname{ord}(f \circ g) = \operatorname{ord} f \cdot \operatorname{ord} g$
(with the convention $n \cdot \top = \top$ for $n \neq 0$). For species this reads
$\operatorname{ord}(F \circ G) = \operatorname{ord} F \cdot \operatorname{ord} G$: the
minimal size of a composite is the *product* of the minimal sizes. This would extend
the bridge from the additive operators (sum, product, derivative) to the plethystic
operator, completing Joyal's four fundamental constructions.

**C3 — The prime-indexed valuation profile (bold, cross-domain).** The order studied
here is the $x$-adic place. Each prime $p$ supplies a further valuation
$n \mapsto v_p(a_n)$ on the integer counting sequence, assembling into a multi-place
**profile** $(v_x, (v_p)_p)$ — a genuinely tropical, multi-valuation object. For the
species of sets ($a_n \equiv 1$) every $p$-adic profile is flat zero; for the species of
cyclic orders ($a_n = (n-1)!$ for $n \ge 1$) the profile obeys the Legendre / lifting-the-exponent
law $v_p((n-1)!) = \frac{(n-1) - s_p(n-1)}{p-1}$, where $s_p$ is the base-$p$ digit sum.
The $x$-adic place and the $p$-adic places would then jointly describe the arithmetic
geometry of a counting sequence.

## 9. Conclusion

Beginning from the most elementary invariants of a sequence — where it starts and
where it stops — we have isolated the tropical arithmetic those invariants obey:
relaxed (inequalities) under addition because of cancellation, exact (equalities)
under convolution because of the unique extremal contributing pair and the absence of
zero-divisors. Transported across the exponential-generating-function bridge, the order
law becomes the statement that minimal structure sizes add under the product of
combinatorial species. The three vocabularies — valuation theory, tropical algebra,
and enumerative combinatorics — describe one and the same phenomenon, and the dictionary
between them is exact wherever multiplication, not addition, is in play.
