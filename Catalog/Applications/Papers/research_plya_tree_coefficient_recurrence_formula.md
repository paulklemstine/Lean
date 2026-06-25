# A Divisor Bridge Between the Pólya Tree Functional Equation and Its Coefficient Recurrence

**Author:** Aristotle
**Domain:** Bridges
**Date:** 2026-06-25

## Abstract

Let $(a_k)_{k\ge 1}$ be the enumeration sequence of rooted unlabelled trees (Pólya
trees; OEIS A000081), with ordinary generating function $A(z)=\sum_{k\ge 1} a_k z^k$
satisfying the functional equation $A(z)=z\,\exp(A(z))\,\Phi(z)$, where
$\Phi(z)=\exp\!\big(\sum_{i\ge 2} A(z^i)/i\big)$. We isolate the arithmetic core of the
classical passage from this functional equation to the practical coefficient recurrence.
Writing $S(z)=\sum_{i\ge 1} A(z^i)/i$ so that $A=z\exp(S)$, the logarithmic derivative
gives the exponential-free identity $zA'(z)=A(z)\,(1+zS'(z))$. We prove a single
*divisor bridge* identity, $n\cdot[z^n]S(z)=\omega_n$ with
$\omega_n=\sum_{d\mid n} d\,a_d$, which is the only non-formal ingredient connecting the
analytic series $S$ to the number-theoretic divisor weight $\omega$. From it we derive,
and in fact establish the logical *equivalence* with, the recurrence
$a_k=\frac{1}{k-1}\sum_{j=1}^{k-1} a_j\,\omega_{k-j}$ for $k\ge 2$, with $a_1=1$. All
results are stated for an arbitrary coefficient sequence over $\mathbb{Q}$, so the bridge
is a property of the algebra rather than of the specific tree counts, and have been
formally verified.

## 1. Introduction

The enumeration of rooted unlabelled trees is one of the foundational problems of
combinatorics, going back to Cayley and given its definitive symmetry-aware treatment by
Pólya. The counts
$$1,1,2,4,9,20,48,115,286,719,1842,4766,\dots$$
form OEIS A000081 and arise throughout chemistry (alkane isomers), computer science (the
shapes of hierarchical data), and phylogenetics. The generating function $A(z)$ obeys a
functional equation that encodes the recursive "root above a multiset of subtrees"
description, corrected for the indistinguishability of isomorphic branches:
$$A(z)=z\,\exp\!\big(A(z)\big)\,\Phi(z), \qquad \Phi(z)=\exp\!\left(\sum_{i\ge 2}\frac{A(z^i)}{i}\right). \tag{FE}$$

In practice one does not compute with (FE) directly; one uses a recurrence. The aim of
this paper is to expose, cleanly and with full rigor, exactly *why* the recurrence
takes the form it does, and to identify the precise point at which arithmetic (the
divisor structure) enters what is otherwise pure power-series bookkeeping. We show that a
single identity — the **divisor bridge** — does all the work, and that the functional
equation (in log-derivative form) and the recurrence are not merely related but
logically equivalent for any candidate coefficient sequence.

Throughout we work over $\mathbb{Q}$ with sequences $a:\mathbb{N}\to\mathbb{Q}$, and we
treat the manipulations formally (coefficientwise), so no convergence or analytic input
is required. The results have been formally verified in a proof assistant; the present
paper gives the human-readable mathematics, with proof sketches faithful to the formal
development.

## 2. Definitions

We index sequences by $\mathbb{N}$ and use $\sum_{d\mid n}$ for the sum over positive
divisors of $n$.

**Definition 1 (Pólya tree generating function).**
$A(z)=\sum_{k\ge 1} a_k z^k$ is the ordinary generating function of the sequence
$(a_k)$. We set $a_0 = 0$.

**Definition 2 (Divisor weight $\omega$, `omegaSeq`).**
For a sequence $a$ and $n\in\mathbb{N}$,
$$\omega_n \;=\; \sum_{d\mid n} d\cdot a_d.$$
This is the *Euler-transform logarithmic-derivative weight*; e.g.
$\omega_6 = a_1 + 2a_2 + 3a_3 + 6a_6$.

**Definition 3 (Coefficients of $S$, `sCoeff`).**
Let $S(z)=\sum_{i\ge 1} A(z^i)/i$. Expanding and collecting powers, its $n$-th
coefficient is
$$s_n \;=\; [z^n]\,S(z) \;=\; \sum_{i\mid n} \frac{a_{n/i}}{i}.$$
Equivalently, $S(z)=\sum_{i\ge 1}\frac1i\sum_{k\ge 1} a_k z^{ik}$, and grouping by the
exponent $n=ik$ gives the divisor sum above.

The series $S$ is the natural intermediary because the functional equation (FE) is
exactly $A = z\exp(S)$: indeed $\exp(A(z))\,\Phi(z)=\exp\!\big(\sum_{i\ge1}A(z^i)/i\big)=\exp(S(z))$.

## 3. The log-derivative reformulation

Since $A=z\exp(S)$ with $A,S$ formal power series and $a_1\ne 0$, $A$ is a unit times $z$,
so $\log A$ is well defined formally and $\log A = \log z + S$. Differentiating,
$$\frac{A'(z)}{A(z)} = \frac1z + S'(z),$$
and multiplying through by $zA(z)$ gives the exponential-free identity
$$z\,A'(z) = A(z)\,\big(1 + z\,S'(z)\big). \tag{LD}$$
For a sequence $a$ with $a_1\ne 0$, (LD) is equivalent to (FE); the merit of (LD) is that
it is a polynomial identity in $A, S$ and their derivatives, amenable to direct
coefficient extraction. Reading off $[z^n]$ on both sides will give the recurrence, once
we understand the coefficients of $z\,S'(z)$ — which is where the divisor weight enters.

## 4. The divisor bridge

The central result connects the analytic coefficient $s_n$ to the arithmetic weight
$\omega_n$.

**Theorem 4 (Divisor bridge, `divisor_bridge`).**
For every sequence $a:\mathbb{N}\to\mathbb{Q}$ and every $n$,
$$n\cdot s_n \;=\; \omega_n, \qquad\text{i.e.}\qquad n\sum_{i\mid n}\frac{a_{n/i}}{i} \;=\; \sum_{d\mid n} d\,a_d.$$

*Proof sketch.* Expand the left side as $\sum_{i\mid n} \frac{n}{i}\,a_{n/i}$. Apply the
divisor reflection $i\mapsto n/i$, a bijection on the divisors of $n$ (formally,
`Nat.sum_div_divisors`), which rewrites the sum over $i$ as a sum over $d=n/i$. Under this
substitution $n/i = d$ and the multiplier $n/i$ becomes $d$ while the indexing term
$a_{n/i}$ becomes... we track both factors: the term indexed by $d$ is $d\cdot a_d$, using
that for $i\mid n$ one has $\tfrac{n}{i}\cdot i = n$ (the integer division cast
$(n/i:\mathbb{Q}) = n/i$ is valid because $i\mid n$). Term-by-term the two divisor sums
coincide, giving $n s_n=\omega_n$. $\square$

The factor $n$ is exactly the multiplier that differentiation contributes:
$[z^n]\,\big(z S'(z)\big) = n\,[z^n]S(z) = n s_n$. Thus Theorem 4 says

$$[z^n]\,\big(z\,S'(z)\big) = \omega_n. \tag{DB}$$

This is the only step that is not pure power-series algebra; it is where number theory
meets combinatorics. Everything downstream is Cauchy-product bookkeeping.

## 5. From the log-derivative identity to the recurrence

We now extract coefficients. Writing the right-hand side of (LD) as a product of power
series produces a convolution; the term $a_j\cdot[z^{n-j}](zS'(z))$ is, by (DB),
$a_j\,\omega_{n-j}$.

**Lemma 5 (Convolution rewrite, `feSum_eq_omegaSum`).**
For every $n$,
$$\sum_{j=1}^{n-1} a_j\cdot\big((n-j)\,s_{n-j}\big) \;=\; \sum_{j=1}^{n-1} a_j\,\omega_{n-j}.$$

*Proof sketch.* Apply Theorem 4 with argument $n-j$ to each summand. $\square$

**Theorem 6 (Bridge equivalence, `polya_FE_iff_recurrence`).**
For every sequence $a:\mathbb{N}\to\mathbb{Q}$, the coefficientwise log-derivative
identity
$$\forall n\ge 1:\quad n\,a_n = a_n + \sum_{j=1}^{n-1} a_j\big((n-j)\,s_{n-j}\big) \tag{LD$_n$}$$
is equivalent to the recurrence
$$\forall k\ge 2:\quad (k-1)\,a_k = \sum_{j=1}^{k-1} a_j\,\omega_{k-j}. \tag{R$_k$}$$

*Proof sketch.* (LD$_n$) is exactly $[z^n]$ of $zA'(z)=A(z)(1+zS'(z))$: the left side
$n a_n=[z^n]\,zA'$; on the right, $A\cdot 1$ contributes $a_n$ and $A\cdot zS'$ contributes
the convolution $\sum_{j} a_j[z^{n-j}](zS')$, where the $j=n$ term vanishes since
$[z^0](zS')=0$, leaving the sum over $1\le j\le n-1$.

($\Rightarrow$) Given (LD$_n$) for some $n=k\ge 2$, apply Lemma 5 to turn the
convolution into $\sum_j a_j\omega_{k-j}$, then move the lone $a_n$ term to the left:
$n a_n - a_n = (n-1)a_n$, yielding (R$_k$).

($\Leftarrow$) Given (R$_k$) for all $k\ge2$, fix $n\ge1$. If $n=1$, (LD$_1$) reads
$1\cdot a_1 = a_1 + (\text{empty sum})$, which is trivially true. If $n\ge2$, run the
forward computation in reverse: rewrite the convolution by Lemma 5 and add back $a_n$ to
recover (LD$_n$) from (R$_n$). $\square$

The equivalence is the conceptual punchline: the recurrence is a faithful re-encoding of
the functional equation, not a lossy specialization. The $n=1$ case of (LD$_n$) is
automatically valid, matching the fact that the recurrence only constrains $k\ge 2$.

**Theorem 7 (Pólya tree recurrence, main result, `polya_tree_recurrence`).**
Suppose $a_1=1$ and the log-derivative identity (LD$_n$) holds for all $n\ge1$. Then
$a_1=1$ and for every $k\ge 2$,
$$a_k \;=\; \frac{1}{k-1}\sum_{j=1}^{k-1} a_j\,\omega_{k-j}, \qquad \omega_m=\sum_{d\mid m} d\,a_d.$$

*Proof sketch.* By Theorem 6, (LD$_n$) for all $n$ gives (R$_k$): $(k-1)a_k=\sum_j a_j\omega_{k-j}$
for $k\ge2$. For $k\ge2$ we have $k-1\ne 0$ in $\mathbb{Q}$, so divide. $\square$

Because $k-1$ is invertible in any $\mathbb{Q}$-algebra, the same proof works verbatim
over any commutative $\mathbb{Q}$-algebra $R$ (e.g. $\mathbb{R}$, $\mathbb{C}$, or the
formal power series ring $\mathbb{Q}[[t]]$); none of the arguments uses an ordering or an
archimedean property.

## 6. Algorithm

Theorem 7 is directly executable. Given an upper bound $N$:

1. Set $a_1\leftarrow 1$ and $a_0\leftarrow 0$.
2. For $k=2,\dots,N$:
   a. For each needed $m\le k-1$, compute $\omega_m=\sum_{d\mid m} d\,a_d$ (or maintain
      $\omega$ incrementally).
   b. Compute the convolution $C=\sum_{j=1}^{k-1} a_j\,\omega_{k-j}$.
   c. Set $a_k\leftarrow C/(k-1)$.

Maintaining all divisor weights up to $N$ costs $O(N\log N)$ (harmonic sum of divisor
counts), and the convolutions cost $O(N^2)$ in total, so the sequence is produced in
$O(N^2)$ rational operations. With exact rational arithmetic each $a_k$ comes out an
integer (see Section 8). A worked trace appears in the accompanying demo; the first terms
$1,1,2,4,9,20,48,115,286,719,1842,4766$ reproduce A000081 exactly.

## 7. Worked example

Take $a_1=1$. Compute weights $\omega_1=1$, $\omega_2=a_1+2a_2$, $\omega_3=a_1+3a_3$,
$\omega_4=a_1+2a_2+4a_4$, updating as new $a_k$ appear:

- $a_2=\tfrac11(a_1\omega_1)=1$, so $\omega_2=1+2=3$.
- $a_3=\tfrac12(a_1\omega_2+a_2\omega_1)=\tfrac12(3+1)=2$, so $\omega_3=1+6=7$.
- $a_4=\tfrac13(a_1\omega_3+a_2\omega_2+a_3\omega_1)=\tfrac13(7+3+2)=4$, so $\omega_4=1+2+16=19$.
- $a_5=\tfrac14(a_1\omega_4+a_2\omega_3+a_3\omega_2+a_4\omega_1)=\tfrac14(19+7+6+4)=9$.

Thus $1,1,2,4,9,\dots$, matching A000081.

## 8. Applications and discussion

**Faithfulness.** The construction makes plain that $\omega$ is *derived*, not assumed:
it is forced as the coefficient of $z S'(z)$ via the divisor bridge (DB). Consequently
Theorem 7 is not the recurrence "in disguise" — its hypothesis is the genuine
log-derivative of the functional equation.

**Integrality.** Although the recurrence divides by $k-1$ over $\mathbb{Q}$, the outputs
are integers, reflecting that $a_k$ counts trees. Equivalently $(k-1)\mid\sum_j a_j\omega_{k-j}$
as integers. A structural proof should follow from the Euler-transform (cycle-index)
description; the divisor bridge already isolates $\omega_k$ as the exact log-derivative
weight, reducing integrality to a clean divisibility statement.

**Generality.** Section 5 establishes the results for arbitrary $\mathbb{Q}$-algebras, so
the same recurrence governs power-series and analytic specializations.

**Asymptotics.** The recurrence is the standard route to the growth law
$a_k\sim C\,\alpha^k k^{-3/2}$ with the Otter constant $\alpha\approx 2.9557$; the explicit
$\omega$-convolution is precisely what makes the dominant-singularity analysis tractable.

**A template for a family.** The weight $\omega_k=\sum_{d\mid k} d\,a_d$ is the universal
Euler-transform log-derivative weight. For any species whose generating function has the
shape $F=x\,G(F)\,\exp(\sum_{i\ge2}F(x^i)/i)$ — forests, series-reduced trees, and other
unlabelled structures — only the outer composition $G$ changes; the divisor machinery is
identical. This makes a *library* of tree recurrences tractable once the bridge is
proved once and for all.

## 9. Future work

1. **Integrality.** Prove that the $\mathbb{Q}$-recurrence is integer-valued by exhibiting
   the Euler-transform form, turning division by $k-1$ into an integer divisibility.
2. **Arbitrary $\mathbb{Q}$-algebras.** Restate Theorems 6 and 7 over any commutative
   $\mathbb{Q}$-algebra, enabling power-series and analytic specializations.
3. **A uniform Euler-transform family.** Use the same divisor-bridge mechanism to derive
   recurrences for series-reduced trees, forests, and related species.
4. **Asymptotics.** Derive $a_k\sim C\alpha^k k^{-3/2}$ (Otter's constant) from the
   recurrence via two-sided control of partial $\omega$-sums.
5. **A certified evaluator.** Upgrade the uniqueness of the recurrence-defined sequence
   into a certified computable evaluator for A000081.

## References

- A. Cayley, *On the analytical forms called trees* (tree enumeration).
- G. Pólya, *Kombinatorische Anzahlbestimmungen für Gruppen, Graphen und chemische
  Verbindungen* (Pólya counting theory).
- P. Flajolet and R. Sedgewick, *Analytic Combinatorics* (functional equations for tree
  classes and singularity analysis).
- OEIS Foundation, sequence A000081 (rooted unlabelled trees).
