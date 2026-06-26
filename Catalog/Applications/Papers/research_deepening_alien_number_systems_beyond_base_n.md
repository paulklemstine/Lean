# Mixed-Radix Positional Systems: Existence, Uniqueness, and a Bijection Beyond Base-N

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Applications

## Abstract

The familiar base-$b$ positional numeral system is the *uniform* special case of a
strictly more general structure in which each position is permitted to carry its own,
independently chosen base. We develop this **mixed-radix** (variable-base, or "alien")
positional system in full. A system is specified by a finite list of bases
$bs = [b_0, \dots, b_{k-1}]$; a digit list $ds = [d_0, \dots, d_{k-1}]$ denotes the value
$\mathrm{mval}(bs, ds) = d_0 + b_0(d_1 + b_1(d_2 + \cdots))$ (a Horner evaluation), and a
greedy extraction map $\mathrm{mdigits}(bs, n)$ recovers digits by successive Euclidean
division. Our central result is the **master reconstruction law**
$\mathrm{mval}(bs, \mathrm{mdigits}(bs, n)) = n \bmod \prod_i b_i$, from which we derive:
exact round-tripping of numbers below the *capacity* $\prod_i b_i$; validity of extracted
digits ($d_i < b_i$) under positivity of bases; the bound $\mathrm{mval}(bs, ds) < \prod_i b_i$
for valid digit lists; and the uniqueness theorem
$\mathrm{mdigits}(bs, \mathrm{mval}(bs, ds)) = ds$. Together these assemble into an explicit
bijection $\{0, \dots, \prod_i b_i - 1\} \cong \{\text{valid digit lists}\}$. We show the
construction is a *conservative extension* of the classical theory: on a uniform base list it
restricts exactly to standard base-$b$ evaluation, recovering the classical positional-system
theorem as a corollary. Two specializations are highlighted: the uniform base-$b$ system and the
factorial number system $[2, 3, \dots, k+1]$ of capacity $(k+1)!$. Every result has been formally
verified.

## 1. Introduction

A positional numeral system makes two promises about every number $n$ in its range: that $n$ can
be written as a string of digits (*existence*), and that it can be so written in exactly one way
using legal digits (*uniqueness*). The base-$b$ system fulfils both, and its ubiquity has made the
uniformity of its base — every position counts to the same $b$ — feel essential. It is not.

We isolate the genuinely necessary ingredient. What makes a positional system work is not that the
bases are equal but that **each digit is bounded by its own position's base**. Once stated this way,
existence and uniqueness extend verbatim to systems in which every position carries a different base.
We call these *mixed-radix* or *alien* systems. They include, as instances, ordinary base-$b$
arithmetic, the factorial number system, the primorial system, and the mixed bases of clocks and
calendars.

The contribution of this paper is a complete and self-contained development of the theory built on a
single identity — the master reconstruction law — together with a formal verification of every
statement. The argument deliberately avoids well-founded recursion (which the standard treatment of
base-$b$ digit extraction requires) in favour of structural recursion on the list of bases, making
the entire theory a clean induction.

## 2. Definitions

Throughout, numbers are nonnegative integers ($\mathbb{N}$), and lists are written least significant
first. We write $\prod bs$ for the product of the entries of a list $bs$ (with the empty product equal
to $1$), and $|ds|$ for the length of a list.

**Definition 2.1 (Value / Horner evaluation `mval`).**
The value of a digit list $ds$ under bases $bs$ is defined by structural recursion:
$$
\mathrm{mval}(bs, [\,]) = 0, \qquad
\mathrm{mval}([\,], d :: ds') = d, \qquad
\mathrm{mval}(b :: bs',\ d :: ds') = d + b \cdot \mathrm{mval}(bs', ds').
$$
Equivalently, on lists of equal length,
$\mathrm{mval}(bs, ds) = d_0 + b_0(d_1 + b_1(d_2 + \cdots + b_{k-2} d_{k-1})).$

**Definition 2.2 (Digit extraction `mdigits`).**
The digit list of $n$ under bases $bs$ is defined by structural recursion on $bs$:
$$
\mathrm{mdigits}([\,], n) = [\,], \qquad
\mathrm{mdigits}(b :: bs',\ n) = (n \bmod b) :: \mathrm{mdigits}\big(bs',\ \lfloor n / b\rfloor\big).
$$

**Definition 2.3 (Capacity).**
The *capacity* of a base list $bs$ is $\prod bs = \prod_i b_i$. (For the empty list this is $1$.)

**Definition 2.4 (Valid digit list).**
A digit list $ds$ is *valid* for bases $bs$ when $ds$ and $bs$ are related entrywise by strict
inequality: formally $\mathrm{Forall}_2\,(<)\,ds\,bs$, i.e. $|ds| = |bs|$ and $d_i < b_i$ for all $i$.
This phrasing — a pairwise relation between two lists, rather than indexed inequalities — is what makes
the inductions below close cleanly.

## 3. Elementary structural facts

**Lemma 3.1 (`mval_nil_right`).** $\mathrm{mval}(bs, [\,]) = 0$ for every base list $bs$.
*Proof.* Case split on $bs$; both cases reduce to the defining equation. $\square$

**Lemma 3.2 (`mdigits_length`).** $|\mathrm{mdigits}(bs, n)| = |bs|$ for all $n$.
*Proof.* Induction on $bs$ (generalizing $n$): the empty case is immediate, and the cons case adds one
entry on each side and recurses on $\lfloor n/b\rfloor$. $\square$

Thus extracted digit lists always have exactly one digit per base.

## 4. The master reconstruction law and existence

**Theorem 4.1 (Master reconstruction law, `mval_mdigits`).**
For every base list $bs$ and every $n \in \mathbb{N}$,
$$
\mathrm{mval}\big(bs,\ \mathrm{mdigits}(bs, n)\big) = n \bmod \textstyle\prod bs.
$$

*Proof sketch.* Induction on $bs$, generalizing $n$.

- **Base case** $bs = [\,]$: the left side is $\mathrm{mval}([\,], [\,]) = 0$, and the right side is
  $n \bmod 1 = 0$.
- **Inductive step** $bs = b :: bs'$: by definition,
  $\mathrm{mval}(b :: bs', \mathrm{mdigits}(b :: bs', n)) = (n \bmod b) + b \cdot \mathrm{mval}(bs', \mathrm{mdigits}(bs', \lfloor n/b\rfloor))$.
  By the induction hypothesis the second summand is $b \cdot \big(\lfloor n/b\rfloor \bmod \prod bs'\big)$.
  The goal therefore reduces to the elementary identity
  $$
  n \bmod (b \cdot m) = (n \bmod b) + b\big(\lfloor n/b\rfloor \bmod m\big), \qquad m = \textstyle\prod bs',
  $$
  which is exactly the decomposition of a remainder modulo a product into its low and high parts
  (`Nat.mod_mul`). This closes the induction. $\square$

The entire theory now follows from Theorem 4.1.

**Corollary 4.2 (Exact round trip below capacity, `mval_mdigits_of_lt`).**
If $n < \prod bs$ then $\mathrm{mval}(bs, \mathrm{mdigits}(bs, n)) = n$.
*Proof.* Apply Theorem 4.1 and $n \bmod \prod bs = n$ when $n < \prod bs$. $\square$

This is *existence*: every number below the capacity is faithfully represented, and the greedy map
$\mathrm{mdigits}$ produces the representation.

**Lemma 4.3 (Extracted digits are valid, `mdigits_forall₂_lt`).**
If every base is positive ($b > 0$ for all $b \in bs$), then $\mathrm{mdigits}(bs, n)$ is valid:
$\mathrm{Forall}_2\,(<)\,(\mathrm{mdigits}(bs, n))\,bs$.
*Proof.* Induction on $bs$. The empty case is the empty relation. For $b :: bs'$, the head digit is
$n \bmod b < b$ by $\mathrm{Nat.mod\_lt}$ (using $b > 0$), and the tail is valid by the induction
hypothesis applied to $\lfloor n/b\rfloor$. $\square$

## 5. The bound and uniqueness

**Lemma 5.1 (Value bound for valid lists, `mval_lt_prod`).**
If $ds$ is valid for $bs$ (so $\mathrm{Forall}_2\,(<)\,ds\,bs$), then
$\mathrm{mval}(bs, ds) < \prod bs$.
*Proof.* Induction on the $\mathrm{Forall}_2$ witness. Empty case: $0 < 1$. Cons case with $d < b$ and
$\mathrm{mval}(bs', ds') < \prod bs'$: then
$$
\mathrm{mval}(b :: bs', d :: ds') = d + b \cdot \mathrm{mval}(bs', ds') \le (b - 1) + b(\textstyle\prod bs' - 1) + \cdots
$$
more directly, $d + b\cdot v < b + b\cdot(\prod bs') - b = b\cdot \prod bs'$ whenever $d < b$ and
$v < \prod bs'$; nonlinear arithmetic over $\mathbb{N}$ closes this ($d + b v \le (b-1) + b(\prod bs' - 1) = b\prod bs' - 1 < \prod(b::bs')$). $\square$

The extremal case is instructive: the maximal valid digit list $d_i = b_i - 1$ attains the value
$\prod bs - 1$, exactly one below capacity — the odometer reading immediately before rollover.

**Theorem 5.2 (Uniqueness, `mdigits_mval`).**
If $ds$ is valid for $bs$, then $\mathrm{mdigits}(bs, \mathrm{mval}(bs, ds)) = ds$.

*Proof sketch.* Induction on $ds$ (generalizing $bs$). The empty case is immediate. For
$ds = d :: ds'$ with $bs = b :: bs'$, write $v = \mathrm{mval}(bs', ds')$, so
$\mathrm{mval}(bs, ds) = d + b v$ with $d < b$. Then:

- **Head digit.** $(d + b v) \bmod b = d$ since $d < b$ (using $\mathrm{Nat.add\_mul\_div\_left}$ and
  $\mathrm{Nat.mod\_eq\_of\_lt}$).
- **Quotient.** $\lfloor (d + b v)/b\rfloor = v$ since $\lfloor d/b\rfloor = 0$ (as $d < b$), so the
  recursion continues on $v$.
- **Tail.** By the induction hypothesis applied to the valid tail $ds'$,
  $\mathrm{mdigits}(bs', v) = ds'$.

Reassembling, $\mathrm{mdigits}(b :: bs', d + b v) = d :: ds' = ds$. $\square$

Existence (Corollary 4.2) and uniqueness (Theorem 5.2) are the two inverse round trips.

## 6. The crowning bijection

**Theorem 6.1 (Mixed-radix bijection, `mixedRadixEquiv`).**
For a base list $bs$ with all bases positive, the map
$$
\Phi : \{0, 1, \dots, \textstyle\prod bs - 1\} \;\longrightarrow\; \{\,ds : \mathrm{Forall}_2\,(<)\,ds\,bs\,\}, \qquad
\Phi(n) = \mathrm{mdigits}(bs, n)
$$
is a bijection, with inverse $\Psi(ds) = \mathrm{mval}(bs, ds)$.

*Proof.* Well-definedness of $\Phi$ is Lemma 4.3; well-definedness of $\Psi$ (landing below capacity) is
Lemma 5.1. The composite $\Psi \circ \Phi = \mathrm{id}$ is Corollary 4.2, and $\Phi \circ \Psi = \mathrm{id}$
is Theorem 5.2. $\square$

Here the source $\{0, \dots, \prod bs - 1\}$ is realized as $\mathrm{Fin}(\prod bs)$. The bijection is the
single statement subsuming the whole theory: existence is its surjectivity, uniqueness its injectivity, and
the capacity $\prod bs$ the common cardinality.

## 7. Conservative extension: recovering classical base-N

A generalization should contain its predecessor. Let $\mathrm{replicate}(k, b)$ be the list of $k$ copies of
$b$.

**Lemma 7.1 (Uniform capacity, `prod_replicate`).** $\prod \mathrm{replicate}(k, b) = b^k$.

**Theorem 7.2 (Restriction to classical evaluation, `mval_replicate_eq_ofDigits`).**
For all $b$, all digit lists $ds$, and all $k \ge |ds|$,
$$
\mathrm{mval}\big(\mathrm{replicate}(k, b),\ ds\big) = \mathrm{ofDigits}(b, ds),
$$
where $\mathrm{ofDigits}(b, ds) = d_0 + b\,d_1 + b^2 d_2 + \cdots$ is the standard base-$b$ evaluation.
*Proof sketch.* Induction on $ds$; the length side-condition $k \ge |ds|$ guarantees a base remains for each
digit, and the cons step matches $\mathrm{ofDigits}$'s defining recurrence $d + b \cdot \mathrm{ofDigits}(b, ds')$. $\square$

Thus the alien evaluation does not reimplement base-$b$ arithmetic in parallel; it literally *restricts* to it
on uniform base lists.

**Corollary 7.3 (Classical positional theorem, `uniform_roundtrip`).**
If $n < b^k$ then $\mathrm{mval}(\mathrm{replicate}(k, b), \mathrm{mdigits}(\mathrm{replicate}(k, b), n)) = n$.
*Proof.* Corollary 4.2 with capacity $\prod \mathrm{replicate}(k, b) = b^k$ (Lemma 7.1). $\square$

This is the textbook statement — every $n < b^k$ is reconstructed exactly from its $k$ base-$b$ digits —
obtained as the uniform instance of the master law.

## 8. The factorial number system

**Definition 8.1 (Factorial bases).** The factorial system uses
$bs = [2, 3, 4, \dots, k+1]$, i.e. $b_i = i + 2$.

**Proposition 8.2 (Factorial capacity).** $\prod [2, 3, \dots, k+1] = (k+1)!$.
*Proof.* The product telescopes: $2 \cdot 3 \cdots (k+1) = (k+1)!$. $\square$

Specializing Theorem 6.1 gives a bijection $\{0, \dots, (k+1)! - 1\} \cong \{\text{valid factoradic lists}\}$,
where a valid factoradic list has $d_i \le i + 1$ (equivalently $d_i < i + 2$). The factorial system is the
canonical genuinely non-uniform alien base, and its digit strings are the **Lehmer codes** of permutations:
counting $0, 1, \dots, (k+1)! - 1$ enumerates $\mathrm{Perm}(\{0, \dots, k\})$ in lexicographic order. This makes
the factorial bijection a ranking/unranking device for permutations — see §10.

## 9. Worked examples

The abstractions above are best understood through concrete computation. We work three
examples by hand, in each case exhibiting both round trips.

**Example 9.1 (Base ten).** Take $bs = [10, 10, 10]$, so $\prod bs = 1000$. To encode
$n = 723$: $723 \bmod 10 = 3$ and $\lfloor 723/10\rfloor = 72$; then $72 \bmod 10 = 2$,
$\lfloor 72/10\rfloor = 7$; then $7 \bmod 10 = 7$, $\lfloor 7/10\rfloor = 0$. Thus
$\mathrm{mdigits}(bs, 723) = [3, 2, 7]$ (units, tens, hundreds). Decoding via Horner:
$\mathrm{mval}(bs, [3,2,7]) = 3 + 10(2 + 10\cdot 7) = 3 + 10\cdot 72 = 723$. The digit list
is valid ($3, 2, 7 < 10$) and lies below capacity, illustrating Corollary 4.2 and Theorem 5.2.

**Example 9.2 (Factorial base).** Take $bs = [2, 3, 4, 5]$, the factorial system with
$k = 4$ and $\prod bs = 5! = 120$. Encode $n = 100$:
$100 \bmod 2 = 0$, $\lfloor 100/2\rfloor = 50$;
$50 \bmod 3 = 2$, $\lfloor 50/3\rfloor = 16$;
$16 \bmod 4 = 0$, $\lfloor 16/4\rfloor = 4$;
$4 \bmod 5 = 4$, $\lfloor 4/5\rfloor = 0$.
So $\mathrm{mdigits}(bs, 100) = [0, 2, 0, 4]$. The place values are the factorials
$1!, 2!, 3!, 4! = 1, 2, 6, 24$, and indeed $0\cdot 1 + 2\cdot 2 + 0\cdot 6 + 4\cdot 24 = 4 + 96 = 100$,
matching $\mathrm{mval}$. The maximal numeral $[1, 2, 3, 4]$ encodes $1 + 2\cdot 2 + 3\cdot 6 + 4\cdot 24 = 119 = 120 - 1$,
the extremal case of Lemma 5.1.

**Example 9.3 (Primorial base).** Take $bs = [2, 3, 5, 7]$, the primorial system of
capacity $2\cdot 3\cdot 5\cdot 7 = 210$. Encode $n = 209$:
$209 \bmod 2 = 1$, $\lfloor 209/2\rfloor = 104$;
$104 \bmod 3 = 2$, $\lfloor 104/3\rfloor = 34$;
$34 \bmod 5 = 4$, $\lfloor 34/5\rfloor = 6$;
$6 \bmod 7 = 6$. So $\mathrm{mdigits}(bs, 209) = [1, 2, 4, 6]$, the maximal numeral, whose value
is $210 - 1 = 209$ as expected. Note that the *successive-division* digits differ in general
from the bare residues $(n \bmod p_i)$; the agreement at $n = 209$ is a feature of the extremal
value, and the precise relationship between the two — positional versus residue representation —
is the content of Future-Directions Conjecture 5.

## 10. Algorithms

The definitions are already algorithms. We record their complexity.

- **Encoding** ($\mathrm{mdigits}$): one Euclidean division per base. For $k$ bases this is $k$ divisions,
  $O(k)$ big-integer divisions; on machine words, $O(k)$ time.
- **Decoding** ($\mathrm{mval}$): one multiply–add per base via Horner's rule, $O(k)$ operations, optimal in the
  number of multiplications.
- **Validity check**: a single linear scan comparing $d_i$ with $b_i$, $O(k)$.

The round trip $\mathrm{mdigits} \circ \mathrm{mval}$ and $\mathrm{mval} \circ \mathrm{mdigits}$ are therefore both
linear in the number of positions.

## 11. Applications

- **Combinatorial ranking/unranking.** The factorial system (§8) converts between an index $n$ and a permutation
  via its Lehmer code, enabling direct access to the $n$-th permutation without enumerating predecessors.
- **Time and calendar arithmetic.** Seconds, minutes, hours, days carry the natural mixed base $[60, 60, 24, \dots]$;
  the master law is exactly the carry rule of clock arithmetic.
- **Residue and primorial systems.** The primorial base $[2, 3, 5, 7, \dots]$ (first $k$ primes) has capacity equal
  to the primorial $p_k\#$ and connects, via the Chinese Remainder Theorem, positional and residue representations.
- **Hardware/coding.** Mixed-radix counters and factorial-base encodings appear in addressing, Gray-code-like
  enumeration, and combinatorial generation libraries.

## 12. Discussion

The methodological point is that the *entire* theory reduces to Theorem 4.1, whose only non-formal ingredient is
the remainder-of-a-product identity $\mathrm{Nat.mod\_mul}$. Choosing to index validity by the pairwise relation
$\mathrm{Forall}_2\,(<)$ rather than by position-indexed inequalities is what allows both round trips, the bound,
and the bijection to fall out of plain list induction. By recursing on the *list of bases* rather than on the value
$n$, we avoid the well-founded recursion that the standard base-$b$ digit function needs, trading a subtle
termination argument for an elementary structural one. The conservative-extension theorems (§7) confirm the framework
is a true generalization rather than a parallel reimplementation.

It is worth situating the result in the broader landscape of positional notation. Uniform base-$b$
representation, balanced and signed-digit systems, the factorial number system, and residue number
systems are usually presented as separate constructions, each with its own existence/uniqueness proof.
The mixed-radix viewpoint unifies the *non-redundant, positive-base* members of this family under one
roof: each is the instance of a particular base list, and each one's representation theorem is a single
corollary of the master law (Theorem 4.1). The choice of capacity as the *product* $\prod_i b_i$ — rather
than a power — is the precise structural invariant that makes this unification possible, and it is the
feature that distinguishes the present development from a base-by-base treatment. Redundant systems
(such as signed-digit or non-adjacent forms) and greedy-but-non-positional systems (such as Zeckendorf's
Fibonacci representation) fall outside the strict $d_i < b_i$ validity condition used here; capturing them
requires the weaker *super-increasing place-value* hypothesis discussed in Future-Directions Conjecture 4,
which we leave to subsequent work. Finally, because every statement here is formally machine-checked, the
framework can serve as a verified foundation on which those extensions, and the downstream applications of
§11, can be built with confidence.

## 13. Future directions

This cycle built `MixedRadix`, a general variable-base positional system with a proved existence/uniqueness bijection
$\mathrm{Fin}(\prod bs) \cong \{\text{valid digit lists}\}$, the factorial-base instance, and a conservative bridge to
the classical base-$b$ evaluation. The following conjectures are bold, precise, and testable in follow-up work.

**Conjecture 1 — Order isomorphism (the alien system *sorts* numbers).** The bijection is an order isomorphism from
$\mathrm{Fin}(\prod bs)$ to valid digit lists ordered by reverse-lexicographic (most-significant-first) comparison:
for $m, n < \prod bs$, $m < n \iff \mathrm{reverse}(\mathrm{mdigits}(bs, m)) <_{\mathrm{lex}} \mathrm{reverse}(\mathrm{mdigits}(bs, n))$.

**Conjecture 2 — Lehmer code / factoradic ↔ permutations.** There is an explicit bijection between $\mathrm{Fin}((k+1)!)$
and $\mathrm{Perm}(\mathrm{Fin}(k+1))$ factoring through the factoradic digits: the factoradic digit string of $n$ is the
Lehmer code (inversion table) of the $n$-th permutation in lexicographic order, with the value-to-permutation map monotone
for the lexicographic order on permutations (linking Conjecture 1).

**Conjecture 3 — Carry-free addition characterization.** Define digitwise addition of two valid digit lists. Then $a + b$
has no carries in base $bs$ (i.e. $\mathrm{mdigits}(bs, a+b)$ is the digitwise sum) iff $d_i(a) + d_i(b) < b_i$ for every
position $i$. Moreover the digit-sum subadditivity $s(a+b) \le s(a) + s(b)$ generalizes to any base list, with equality
exactly in the carry-free case, via the generalized digit-sum $s_{bs}(n) = \sum \mathrm{mdigits}(bs, n)$.

**Conjecture 4 — Greedy = canonical for super-increasing alien bases.** For a base list whose place values
$P_i = \prod_{j<i} b_j$ are super-increasing ($P_i > \sum_{j<i} (b_j - 1) P_j$, automatic here), the greedy
$\mathrm{mdigits}$ algorithm gives the unique representation — the abstract feature shared with Zeckendorf representation.
There should be a common generalization `GreedyRepresentation` of both `MixedRadix.mdigits` and `Nat.zeckendorf` whose
uniqueness theorem subsumes both `mdigits_mval` and the Zeckendorf bijection.

**Conjecture 5 — Primorial and mixed analytic bases.** For the primorial base $bs = [p_0, p_1, \dots, p_{k-1}]$ (first $k$
primes), the capacity is the primorial $p_k\#$ and the digit at position $i$ is $n \bmod p_i$ after successive division — a
CRT-flavored alien base. The primorial-base digit map should be compatible with the CRT isomorphism
$\mathbb{Z}/p_k\# \cong \prod \mathbb{Z}/p_i$ up to the triangular (Horner) change of basis, giving a positional/residue
duality analogous to the Pisano-period representation result.

## 14. Conclusion

Stripping the uniformity assumption from positional notation costs nothing: existence, uniqueness, and an explicit
bijection between numbers and valid numerals all survive when each position carries its own base. The single master
reconstruction law $\mathrm{mval}(bs, \mathrm{mdigits}(bs, n)) = n \bmod \prod bs$ is the engine; the bijection
$\mathrm{Fin}(\prod bs) \cong \{\text{valid digit lists}\}$ is what it builds; and ordinary base-$b$ arithmetic, the
factorial system, and the primorial system are all instances. Base ten is one point in a continent.
