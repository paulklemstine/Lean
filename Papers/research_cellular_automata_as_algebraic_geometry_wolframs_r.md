# Cellular Automata as Algebraic Varieties over the Binary Field

**Author:** Aristotle
**Date:** 2026-07-09

## Abstract

Every elementary cellular automaton (ECA) can be presented as a polynomial map of
degree at most three over the binary field $\mathrm{GF}(2)$. Under this
presentation the configurations left invariant by a rule — its *fixed points*, or
still lifes — form the $\mathrm{GF}(2)$-points of an affine variety $V(g)$ cut out
by $n$ cubic equations on a cyclic lattice of length $n$. We develop this
dictionary rigorously and use it to test a natural conjecture: that the dimension
of $V(g)$ measures the dynamical complexity of the rule in the sense of Wolfram's
classification. We prove the conjecture *false*, and in the strongest possible way.
The computationally universal Rule 110 has a zero-dimensional fixed-point variety
(a single point), while the dynamically trivial identity Rule 204 has the maximal
dimension $n$; on every cyclic lattice of length at least two the identity's
variety has exponentially more points than Rule 110's. We accompany the refutation
with an exact classification of the additive rules, whose varieties are linear
subspaces with dimensions governed by elementary arithmetic — for Rule 90 by the
Pisano period $\pi(2) = 3$ realized as the multiplicative order of the Fibonacci
companion matrix over $\mathrm{GF}(2)$, and for Rule 150 by parity. The corrected
principle that emerges is that the honest algebraic invariant separating tame from
universal rules is the *degree* of the defining polynomial — equivalently, the
*linearity* of the variety — and not its dimension.

## 1. Introduction

Elementary cellular automata are among the simplest dynamical systems capable of
complex behavior. A one-dimensional bi-infinite (or, here, cyclic) array of binary
cells evolves in discrete time; each cell's next value depends only on its own
current value and those of its two nearest neighbors. There are $2^{2^3} = 256$
such local rules, catalogued by Wolfram as Rules $0$ through $255$ and grouped
empirically into four complexity classes: (1) evolution to a homogeneous state,
(2) evolution to periodic or nested structures, (3) chaotic/aperiodic behavior,
and (4) localized structures with long-range interactions. Rule 110 belongs to
Class 4 and is Turing-complete.

We study these systems through the lens of algebraic geometry over the field of two
elements. The starting point is elementary but consequential: because every
Boolean function of three variables coincides with a unique multilinear polynomial
over $\mathrm{GF}(2)$, each ECA rule is a polynomial map of degree at most three,
and its set of fixed configurations is an affine variety. This paper makes that
correspondence precise, computes the fixed-point varieties of the landmark rules
exactly, and evaluates the conjecture that variety dimension tracks complexity
class.

Our contributions are:

1. A rigorous formulation of the automaton–variety dictionary (Section 3).
2. Exact determination of the fixed-point varieties of Rules 0, 51, 170, 204, 240,
   90, 150, and 110 (Sections 4–6).
3. A transfer-matrix bridge relating Rule 90 to the Fibonacci companion matrix over
   $\mathrm{GF}(2)$ and to the Pisano period (Section 6).
4. The refutation of the complexity–dimension conjecture and the corrected
   principle that degree/linearity, not dimension, is the relevant invariant
   (Section 7).

## 2. Preliminaries: the binary field

Throughout, the alphabet is the binary field $\mathrm{GF}(2) = \{0, 1\}$ with
addition modulo $2$ (so $1 + 1 = 0$) and ordinary multiplication. Two identities
are used repeatedly: $2x = 0$ for all $x$, and $x^2 = x$ for $x \in \{0,1\}$. The
latter implies that any polynomial function $\{0,1\}^k \to \{0,1\}$ equals a unique
*multilinear* polynomial (each variable appearing to at most the first power); its
degree is at most $k$.

## 3. The automaton–variety dictionary

**Definition 3.1 (Configuration).** Fix a cycle length $n \ge 1$. A *configuration*
is a function $s : \mathbb{Z}/n\mathbb{Z} \to \mathrm{GF}(2)$; equivalently a vector
$s = (s_0, \dots, s_{n-1}) \in \mathrm{GF}(2)^n$ with indices read modulo $n$. The
set of configurations is $\mathrm{Config}(n) = \mathrm{GF}(2)^n$.

**Definition 3.2 (Local rule and global step).** A *local rule* is a function
$g : \mathrm{GF}(2)^3 \to \mathrm{GF}(2)$, presented as its multilinear polynomial.
The induced *global step* is the map
$$\mathrm{step}_g : \mathrm{Config}(n) \to \mathrm{Config}(n), \qquad
(\mathrm{step}_g\, s)_i = g(s_{i-1},\, s_i,\, s_{i+1}),$$
with all indices modulo $n$, so that the lattice is a cycle.

**Definition 3.3 (Fixed-point variety).** A configuration $s$ is *fixed* by $g$ if
$\mathrm{step}_g\, s = s$. The *fixed-point variety* is
$$V(g) = \{\, s \in \mathrm{Config}(n) : \mathrm{step}_g\, s = s \,\},$$
the $\mathrm{GF}(2)$-solution set of the $n$ polynomial equations
$s_i = g(s_{i-1}, s_i, s_{i+1})$. Since each $g$ has degree $\le 3$, $V(g)$ is an
affine variety cut out by equations of degree $\le 3$.

For a variety that happens to be a linear (or affine) subspace of dimension $d$, we
have $|V(g)| = 2^d$, so counting $\mathrm{GF}(2)$-points determines the dimension.

**The landmark rules as polynomials.** We record the multilinear representatives
studied below:

| Rule | Behavior | Polynomial $g(a,b,c)$ | Degree |
|------|----------|-----------------------|--------|
| 0 | null | $0$ | $0$ |
| 204 | identity | $b$ | $1$ |
| 51 | complement | $b + 1$ | $1$ (affine) |
| 170 | left shift | $c$ | $1$ |
| 240 | right shift | $a$ | $1$ |
| 90 | additive | $a + c$ | $1$ |
| 150 | additive | $a + b + c$ | $1$ |
| 110 | universal | $b + c + bc + abc$ | $3$ |

**A propagation lemma.** The following elementary fact drives several proofs. Since
$1$ generates the cyclic group $\mathbb{Z}/n\mathbb{Z}$, a property that transfers
from each site to its right neighbor and holds at one site holds everywhere.

> **Lemma 3.4 (Cyclic propagation).** Let $P$ be a predicate on
> $\mathbb{Z}/n\mathbb{Z}$ (with $n \ge 1$). If $P(i) \Rightarrow P(i+1)$ for all
> $i$, and $P(i_0)$ holds for some $i_0$, then $P(j)$ holds for all $j$.

*Proof sketch.* By induction, $P(i_0 + k)$ holds for every natural number $k$.
Every $j$ can be written $j = i_0 + m$ for a suitable representative $m$, so $P(j)$
holds. $\square$

## 4. The extreme rules: null, identity, complement

**Theorem 4.1 (Rule 0, single point).** For every $n$, $V(\mathrm{rule}_0) = \{0\}$;
the variety is a single point of dimension $0$.

*Proof sketch.* The fixed-point equation is $s_i = 0$ for every $i$, so $s = 0$ is
the only solution. $\square$

**Theorem 4.2 (Rule 204, whole space).** For every $n$, every configuration is
fixed: $V(\mathrm{rule}_{204}) = \mathrm{GF}(2)^n$, of dimension $n$.

*Proof sketch.* The equation is $s_i = s_i$, satisfied identically. $\square$

**Theorem 4.3 (Rule 51, empty variety).** For $n \ge 1$ the complement rule has no
fixed configuration: $V(\mathrm{rule}_{51}) = \varnothing$.

*Proof sketch.* The equation at site $0$ reads $s_0 = s_0 + 1$, i.e. $0 = 1$ in
$\mathrm{GF}(2)$, a contradiction. $\square$

## 5. The shift rules: the constant line

**Theorem 5.1 (Rules 170 and 240, dimension 1).** For $n \ge 1$, each shift rule
fixes exactly the constant configurations:
$$V(\mathrm{rule}_{170}) = V(\mathrm{rule}_{240}) = \{\, s : s \equiv c \text{ for some } c \in \mathrm{GF}(2)\,\},$$
a line of dimension $1$ (two points).

*Proof sketch.* For Rule 170 the fixed-point equation is $s_i = s_{i+1}$ for all
$i$; by Lemma 3.4 applied to $P(i): s_i = s_0$, every cell equals $s_0$, so $s$ is
constant. Conversely every constant configuration is fixed. Rule 240 ($s_i =
s_{i-1}$) is identical after reindexing. $\square$

## 6. The additive rules: linearity and arithmetic

The defining feature of Rules 90 and 150 is that their global steps are
$\mathrm{GF}(2)$-**linear** maps, so their fixed-point sets are kernels of linear
operators — genuine linear subspaces.

**Theorem 6.1 (Rule 90 is a linear variety, Fibonacci form).** The step of Rule 90
is the linear map $s \mapsto (i \mapsto s_{i-1} + s_{i+1})$, and
$$V(\mathrm{rule}_{90}) = \ker(\mathrm{step}_{90} - \mathrm{id})$$
is a linear subspace. A configuration is fixed if and only if it satisfies the
Fibonacci recurrence over $\mathrm{GF}(2)$,
$$s_{i+1} = s_i + s_{i-1} \qquad (i \in \mathbb{Z}/n\mathbb{Z}).$$

*Proof sketch.* Linearity of $s \mapsto s_{i-1} + s_{i+1}$ is immediate. The
fixed-point equation $s_i = s_{i-1} + s_{i+1}$ rearranges, using $2 = 0$, to
$s_{i+1} = s_i + s_{i-1}$. $\square$

**Theorem 6.2 (Rule 150 is a linear variety, two-periodic form).** The step of
Rule 150 is the linear map $s \mapsto (i \mapsto s_{i-1} + s_i + s_{i+1})$, and its
fixed points are exactly the two-periodic configurations
$$s_{i+2} = s_i \qquad (i \in \mathbb{Z}/n\mathbb{Z}).$$

*Proof sketch.* The fixed-point equation $s_i = s_{i-1} + s_i + s_{i+1}$ gives
$s_{i-1} + s_{i+1} = 0$, i.e. $s_{i+1} = s_{i-1}$; reindexing yields $s_{i+2} = s_i$.
$\square$

These characterizations translate directly into dimensions. Two-periodicity on a
cycle decouples the even and odd sublattices when $n$ is even (dimension $2$) and
forces global constancy when $n$ is odd (dimension $1$). The Fibonacci case is
governed by number theory, as we now explain.

### 6.1 The Fibonacci companion matrix and the Pisano period

Rule 90's recurrence $s_{i+1} = s_i + s_{i-1}$ is advanced by the **Fibonacci
companion matrix** over $\mathrm{GF}(2)$,
$$T = \begin{pmatrix} 0 & 1 \\ 1 & 1 \end{pmatrix} \in M_2(\mathrm{GF}(2)).$$

**Theorem 6.3 (Order of $T$).** $T^3 = I$ and $T \ne I$, so the multiplicative
order of $T$ is $3$. Consequently, for every $n$,
$$T^n = I \iff 3 \mid n.$$

*Proof sketch.* Direct computation gives $T^3 = I$; since $T \ne I$ and $3$ is
prime, the order is exactly $3$ (a group element whose $p$-th power is the identity
for prime $p$ has order $1$ or $p$). The divisibility statement is the standard
fact that $T^n = I$ iff $\mathrm{ord}(T) \mid n$. $\square$

**Theorem 6.4 (Transfer-matrix bridge).** If $s$ is a Rule 90 fixed configuration,
then for every $i$,
$$\begin{pmatrix} s_{i+1} \\ s_{i+2} \end{pmatrix}
= T \begin{pmatrix} s_i \\ s_{i+1} \end{pmatrix}.$$
Thus the fixed points of Rule 90 are exactly the closed orbits of $T$, and a
solution closes up consistently on a cycle of length $n$ iff $T^n = I$, i.e. iff
$3 \mid n$.

*Proof sketch.* The bottom row is the recurrence $s_{i+2} = s_{i+1} + s_i$ from
Theorem 6.1; the top row is the identity $s_{i+1} = s_{i+1}$. Iterating $n$ times
around the cycle returns the initial state pair iff $T^n$ fixes it for all initial
pairs, i.e. iff $T^n = I$. $\square$

**Theorem 6.5 (Pisano period, sequence form).** The Fibonacci numbers are periodic
modulo $2$ with period $3$: $F_{n+3} \equiv F_n \pmod 2$, giving the pattern
$0,1,1,0,1,1,\dots$

*Proof sketch.* From $F_{n+3} = F_n + 2F_{n+1}$ and $2 \equiv 0 \pmod 2$. $\square$

**Corollary 6.6 (Rule 90 dimension).** The fixed-point variety of Rule 90 has
dimension $2$ (four points) when $3 \mid n$ and dimension $0$ (the single point $0$)
otherwise. Small-cycle counts confirm the pattern: $|V| = 4$ for $n = 3, 6$ and
$|V| = 1$ for $n = 4, 5$.

## 7. The universal rule and the refutation of the conjecture

Rule 110 is the genuinely nonlinear case: its polynomial
$g(a,b,c) = b + c + bc + abc$ is an irreducible cubic (in the sense of carrying a
degree-$3$ monomial), and its step is not a linear map.

**Lemma 7.1 (Zero propagation).** If $s$ is fixed by Rule 110 and $s_i = 0$, then
$s_{i+1} = 0$.

*Proof sketch.* Substituting $b = s_i = 0$ into the fixed-point equation
$s_i = s_i + s_{i+1} + s_i s_{i+1} + s_{i-1} s_i s_{i+1}$ kills every term with a
factor of $s_i$, leaving $0 = s_{i+1}$. $\square$

**Lemma 7.2 (All-ones is not fixed).** The all-ones configuration is not fixed by
Rule 110.

*Proof sketch.* Evaluating the rule on the all-ones neighborhood $(1,1,1)$ gives
$1 + 1 + 1 + 1 = 0 \ne 1$, so site $0$ already fails to be fixed. $\square$

**Theorem 7.3 (Rule 110 collapse).** For every $n \ge 1$,
$V(\mathrm{rule}_{110}) = \{0\}$: the Turing-complete rule fixes only the zero
configuration, a zero-dimensional variety.

*Proof sketch.* Let $s$ be fixed. If some cell is $0$, Lemma 7.1 and cyclic
propagation (Lemma 3.4) force every cell to be $0$. Otherwise every cell is $1$,
i.e. $s$ is all-ones — impossible by Lemma 7.2. Hence $s = 0$; and $s = 0$ is
manifestly fixed. $\square$

**Theorem 7.4 (Complexity–dimension conjecture, refuted).** On every cyclic lattice
of length $n \ge 1$, the identity Rule 204 (Wolfram Class 2) fixes the entire space
$\mathrm{GF}(2)^n$, whereas the computationally universal Rule 110 (Wolfram
Class 4) fixes only the zero configuration. Therefore fixed-point dimension does
not increase with dynamical complexity; the conjectured correspondence is false.

**Theorem 7.5 (Quantitative inversion).** For every $n \ge 2$,
$$|V(\mathrm{rule}_{110})| = 1 < 2^n = |V(\mathrm{rule}_{204})|,$$
and the gap grows exponentially in $n$.

*Proof sketch.* $|V(\mathrm{rule}_{204})| = 2^n$ because every configuration is
fixed (Theorem 4.2); $|V(\mathrm{rule}_{110})| = 1$ by Theorem 7.3; and
$2^n \ge 2^2 > 1$ for $n \ge 2$. $\square$

## 8. Discussion: degree, not dimension

The refutation is sharp and its direction is instructive. Not only does dimension
fail to increase with complexity — the ordering is *inverted*: the most complex rule
attains the minimal dimension and the most trivial the maximal. Any monotone
"complexity = dimension" law is therefore untenable.

The pattern that does hold organizes the rules by the **degree** of their defining
polynomials. The rules with large, structured varieties — Rules 90, 150, 170, 240,
204 — are exactly the affine ones (degree $\le 1$). Their fixed-point sets are
linear subspaces; their dimensions are computed by finite-field linear algebra and
elementary number theory (Pisano periods, parities, orders of companion matrices);
and they populate Wolfram's tame Classes 1–2. Rule 110 is a genuine cubic, and it is
precisely its nonlinearity — the $abc$ term — that both collapses its fixed-point
variety and underlies its universal computational power.

We therefore propose the corrected principle: the algebraic invariant that
distinguishes tame from universal ECAs is the **degree** of the local polynomial —
equivalently, whether the fixed-point variety is *linear* — and not the dimension of
that variety. Complexity is encoded in the curvature of the geometry, not its size.

The dictionary remains valuable independently of this correction. It imports exact,
simulation-free counting of still lifes for all additive rules via the orders of
small matrices over $\mathrm{GF}(2)$, and it situates classical facts (the Pisano
period, the parity of two-periodic patterns) as statements about cellular-automaton
geometry.

## 9. Future work

Three directions extend these findings.

**(1) Linearity as the true separator.** We conjecture that among the $256$ rules,
exactly the sixteen affine rules have fixed-point sets that are affine subspaces for
*every* cycle length, and that every rule of genuine degree $\ge 2$ admits some
cycle length on which its fixed-point set is not closed under addition of solutions.
This would establish degree/linearity — not dimension — as the invariant of record.

**(2) Fixed-point dimension as a Pisano-type function.** For each additive rule the
map $n \mapsto \dim V_n$ should be eventually periodic, with period equal to the
multiplicative order over $\mathrm{GF}(2)$ of the companion matrix of the rule's
recurrence: order $3$ (the Pisano period $\pi(2)$) for Rule 90, and in general the
order of $x$ in $\mathrm{GF}(2)[x]/(p)$ for recurrence characteristic polynomial
$p$. The dimension jump at $n$ is the orbit-closure condition $T^n = I$.

**(3) A period spectrum for the additive rules.** The sixteen affine rules should
split into families indexed by the $\mathrm{GF}(2)$-factorization type of their
recurrence polynomials, with two additive rules conjugate under lattice symmetries
(reflection, complementation) iff their recurrence polynomials share order and
degree pattern.

## 10. Conclusion

Elementary cellular automata are affine varieties over the binary field, and their
still lifes are the $\mathrm{GF}(2)$-points of those varieties. The natural
conjecture that variety dimension measures dynamical complexity is false and in fact
inverted: the universal Rule 110 collapses to a single point while the trivial
identity fills the whole space. The additive rules admit exact linear descriptions
with arithmetically controlled dimensions. The invariant that genuinely separates
the tame from the universal is the degree of the defining polynomial — the linearity
or nonlinearity of the fixed-point variety — a qualitative feature invisible to any
head-count of solutions.
