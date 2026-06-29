# Mixed-Radix Positional Systems: A Unified, Non-Circular Theory of Beyond-Base-$N$ Numeration

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Novelty / Computation

## Abstract

We develop a self-contained theory of **mixed-radix** (variable-base, or
"alien") positional number systems, in which each digit position $i$ carries its
own base $b_i$ rather than a single global base. A system is specified by a finite
list of bases $bs = [b_0, \dots, b_{k-1}]$; a digit list $ds$ denotes the value
$\mathrm{mval}(bs, ds) = d_0 + b_0(d_1 + b_1(d_2 + \cdots))$ (Horner form), and the
greedy extractor $\mathrm{mdigits}(bs, n)$ recovers digits by iterated Euclidean
division. We prove a **master reconstruction law** $\mathrm{mval}(bs,
\mathrm{mdigits}(bs, n)) = n \bmod \prod bs$ from which the entire theory follows:
exact round-trips below the capacity $\prod bs$, validity of extracted digits, a
telescoping value bound, uniqueness of digit representations, and a crowning
bijection $\mathrm{Fin}(\prod bs) \simeq \{\text{valid digit lists}\}$. We then show
the framework strictly contains two classical systems as instances: the **uniform
base-$b$** system (all bases equal to $b$, capacity $b^k$), where $\mathrm{mval}$
literally restricts to the standard digit evaluation $\mathrm{ofDigits}$; and the
**factorial number system** (bases $[2, 3, \dots, k+1]$, capacity $(k+1)!$). We
additionally give a parallel, fully independent development of the factorial
system in which uniqueness is proved **non-circularly** — directly from a
digit-bound estimate and Euclidean division by $k!$, never via cardinality,
surjectivity, or a bijection theorem. All results stated below correspond to
machine-checked theorems.

---

## 1. Introduction

Positional numeral systems are usually presented with a single fixed base: base
$10$ for everyday arithmetic, base $2$ for computers, base $16$ for low-level
programming. The defining theorem of such a system is that every natural number
$n < b^k$ has a *unique* length-$k$ representation $n = \sum_{i<k} d_i b^i$ with
$0 \le d_i < b$. Yet the uniform base is an inessential restriction. Allowing each
position to carry its own base yields the **mixed-radix** systems, which subsume
the uniform systems and additionally capture the factorial number system,
calendar/time arithmetic, and the combinatorial number system used to enumerate
permutations.

This paper presents a compact, complete, and deliberately **non-circular**
theory. Two methodological commitments shape it:

1. **One keystone.** Every structural result descends from a single *master
   reconstruction law* relating extraction and evaluation modulo the system's
   capacity. The inductive step of that law reduces to one classical identity
   about remainders under multiplication.

2. **Honest uniqueness.** We never prove uniqueness by counting. A naive route
   argues that there are exactly $\prod bs$ valid digit lists and exactly
   $\prod bs$ residues, hence the map is bijective — but this presupposes the
   counting structure. Instead, uniqueness is obtained directly from a value bound
   and Euclidean division.

We give the development twice: once abstractly for arbitrary base lists, and once
concretely for the factorial system, so that the same three pillars (a value
bound, a division/remainder splitting, and a direct induction) can be seen in both
list-based and sum-based form.

---

## 2. Definitions

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$, and lists are written
least-significant-digit-first.

**Definition 2.1 (Mixed-radix value).** For base list $bs$ and digit list $ds$,
$$\mathrm{mval}(bs, ds) =
\begin{cases}
0 & ds = [\,] \\
d & bs = [\,],\ ds = d :: ds' \\
d + b \cdot \mathrm{mval}(bs', ds') & bs = b :: bs',\ ds = d :: ds'.
\end{cases}$$
Equivalently, when $|ds| \le |bs|$, $\mathrm{mval}(bs, ds) = \sum_{i} d_i
\prod_{j<i} b_j$.

**Definition 2.2 (Digit extraction).** For base list $bs$ and $n \in \mathbb{N}$,
$$\mathrm{mdigits}([\,], n) = [\,], \qquad
\mathrm{mdigits}(b :: bs', n) = (n \bmod b) :: \mathrm{mdigits}(bs', n / b).$$

**Definition 2.3 (Capacity).** The capacity of a base list is the product
$\mathrm{cap}(bs) = \prod_{b \in bs} b = b_0 b_1 \cdots b_{k-1}$.

**Definition 2.4 (Validity).** A digit list $ds$ is *valid* for $bs$ if it is
positionwise below the bases, written $\mathrm{Forall}_2(<)(ds, bs)$: the lists
have equal length and $d_i < b_i$ for every $i$.

For the standalone factorial development we use the sum-based forms.

**Definition 2.5 (Factoradic value).** $\displaystyle \mathrm{value}(c, k) =
\sum_{i<k} c_i \cdot i!$ for a digit function $c : \mathbb{N} \to \mathbb{N}$.

**Definition 2.6 (Factoradic validity).** $c$ is *valid up to* $k$ if $c_i \le i$
for all $i < k$.

---

## 3. The master reconstruction law and its corollaries

The following lemma is the structural keystone; everything in §3–§4 follows from
it together with elementary list induction.

**Lemma 3.1 (Length).** $|\mathrm{mdigits}(bs, n)| = |bs|$ for all $n$.

*Proof sketch.* Induction on $bs$. The cons case adds one digit and recurses on
$bs'$. $\square$

**Theorem 3.2 (Master reconstruction law).** For all $bs$ and $n$,
$$\mathrm{mval}\bigl(bs, \mathrm{mdigits}(bs, n)\bigr) = n \bmod \mathrm{cap}(bs).$$

*Proof sketch.* Induction on $bs$. For $bs = [\,]$, $\mathrm{cap}([\,]) = 1$ and
$n \bmod 1 = 0 = \mathrm{mval}([\,], [\,])$. For $bs = b :: bs'$, unfold:
$$\mathrm{mval}(b::bs', (n \bmod b) :: \mathrm{mdigits}(bs', n/b)) = (n \bmod b) + b
\cdot \mathrm{mval}(bs', \mathrm{mdigits}(bs', n/b)).$$
By the induction hypothesis the second summand is $b \cdot ((n/b) \bmod
\mathrm{cap}(bs'))$, so the right-hand side is $(n \bmod b) + b\,((n/b) \bmod
\mathrm{cap}(bs'))$. The classical identity $n \bmod (b \cdot m) = (n \bmod b) +
b\,((n/b) \bmod m)$ (with $m = \mathrm{cap}(bs')$, and the case $b = 0$ handled
separately) rewrites this to $n \bmod (b \cdot \mathrm{cap}(bs')) = n \bmod
\mathrm{cap}(b::bs')$. $\square$

**Corollary 3.3 (Exact round-trip).** If $n < \mathrm{cap}(bs)$ then
$\mathrm{mval}(bs, \mathrm{mdigits}(bs, n)) = n$.

*Proof sketch.* Immediate from Theorem 3.2 and $n \bmod \mathrm{cap}(bs) = n$ when
$n < \mathrm{cap}(bs)$. $\square$

**Lemma 3.4 (Extracted digits are valid).** If every base is positive
($\forall b \in bs,\ 0 < b$), then $\mathrm{Forall}_2(<)(\mathrm{mdigits}(bs, n),
bs)$.

*Proof sketch.* Induction on $bs$. The head digit is $n \bmod b < b$ by positivity
of $b$; the tail is valid by the induction hypothesis applied to $n / b$. $\square$

**Lemma 3.5 (Telescoping value bound).** If $\mathrm{Forall}_2(<)(ds, bs)$ then
$\mathrm{mval}(bs, ds) < \mathrm{cap}(bs)$.

*Proof sketch.* Induction on the $\mathrm{Forall}_2$ witness. In the cons step with
$d < b$ and (inductively) $\mathrm{mval}(bs', ds') < \mathrm{cap}(bs')$, we bound
$$d + b\cdot \mathrm{mval}(bs', ds') \le (b-1) + b(\mathrm{cap}(bs') - 1) + 1 = b
\cdot \mathrm{cap}(bs') = \mathrm{cap}(b::bs'),$$
strictly, by combining $d \le b-1$ and $\mathrm{mval}(bs',ds') \le \mathrm{cap}(bs')
- 1$. $\square$

**Theorem 3.6 (Uniqueness of digits).** If $\mathrm{Forall}_2(<)(ds, bs)$ then
$$\mathrm{mdigits}\bigl(bs, \mathrm{mval}(bs, ds)\bigr) = ds.$$

*Proof sketch.* Induction on $ds$ (with $bs$ a cons by validity). Write $v = d + b
\cdot \mathrm{mval}(bs', ds')$. Since $d < b$, Euclidean division gives $v \bmod b =
d$ and $v / b = \mathrm{mval}(bs', ds')$ (here Lemma 3.5 guarantees the lower part
is genuinely below $b$ at the head, so the remainder is exactly $d$). Hence the head
digit recovered is $d$, and the induction hypothesis recovers the tail $ds'$.
$\square$

Theorem 3.6 is the substantive uniqueness statement: distinct valid digit lists
denote distinct values, because feeding the common value back through
$\mathrm{mdigits}$ would have to return both lists.

**Theorem 3.7 (Crowning bijection).** For a base list $bs$ with all bases
positive, the map $n \mapsto \mathrm{mdigits}(bs, n)$ is a bijection
$$\mathrm{Fin}(\mathrm{cap}(bs)) \;\xrightarrow{\ \sim\ }\; \{ds :
\mathrm{Forall}_2(<)(ds, bs)\},$$
with inverse $ds \mapsto \mathrm{mval}(bs, ds)$.

*Proof sketch.* Well-definedness of the forward map is Lemma 3.4; of the inverse,
Lemma 3.5. The two round-trip identities are Corollary 3.3 (for $n <
\mathrm{cap}(bs)$, supplied by $\mathrm{Fin}$) and Theorem 3.6. $\square$

---

## 4. Specializations: recovering classical systems

### 4.1 Uniform base-$b$

Let $\mathrm{replicate}(k, b) = [b, b, \dots, b]$ ($k$ copies).

**Lemma 4.1 (Uniform capacity).** $\mathrm{cap}(\mathrm{replicate}(k, b)) = b^k$.

*Proof sketch.* Product of a constant list. $\square$

**Theorem 4.2 (Restriction to standard evaluation).** For $|ds| \le k$,
$$\mathrm{mval}(\mathrm{replicate}(k, b), ds) = \mathrm{ofDigits}(b, ds) =
\sum_i d_i b^i.$$

*Proof sketch.* Induction on $ds$ (and on the supply $k$ of bases). The Horner
unfolding of $\mathrm{mval}$ matches the Horner definition of $\mathrm{ofDigits}$
exactly; the length side-condition ensures a base is available for each digit.
$\square$

**Theorem 4.3 (Uniform round-trip).** If $n < b^k$ then
$\mathrm{mval}(\mathrm{replicate}(k, b), \mathrm{mdigits}(\mathrm{replicate}(k, b),
n)) = n$.

*Proof sketch.* Corollary 3.3 with capacity rewritten by Lemma 4.1. $\square$

Theorem 4.2 shows the alien framework is a *conservative extension* of the standard
base-$N$ library: it does not reimplement positional notation, it restricts to it.

### 4.2 The factorial number system

Let $\mathrm{bases}(k) = [2, 3, \dots, k+1]$, i.e. the map $i \mapsto i+2$ over
$\{0, \dots, k-1\}$.

**Lemma 4.4 (Factorial capacity telescopes).** $\mathrm{cap}(\mathrm{bases}(k)) =
(k+1)!$.

*Proof sketch.* Induction: $\mathrm{cap}(\mathrm{bases}(k+1)) = (k+2) \cdot
\mathrm{cap}(\mathrm{bases}(k)) = (k+2)\cdot(k+1)! = (k+2)!$. $\square$

**Lemma 4.5 (Bases positive).** Every $b \in \mathrm{bases}(k)$ satisfies $b \ge 2 >
0$.

**Theorem 4.6 (Factoradic round-trip).** If $n < (k+1)!$ then
$\mathrm{mval}(\mathrm{bases}(k), \mathrm{mdigits}(\mathrm{bases}(k), n)) = n$.

*Proof sketch.* Corollary 3.3 with capacity rewritten by Lemma 4.4. $\square$

**Lemma 4.7 (Factoradic digit validity).** $\mathrm{Forall}_2(<)(\mathrm{mdigits}
(\mathrm{bases}(k), n), \mathrm{bases}(k))$; equivalently the $i$-th digit is
$< i+2$, i.e. $\le i+1$.

*Proof sketch.* Lemma 3.4 with Lemma 4.5. $\square$

Thus the factorial system is the instance $b_i = i+2$ of the general theory, with
capacity telescoping to $(k+1)!$ and the classical factoradic digit bound.

---

## 5. A standalone, non-circular factorial development

For completeness and to exhibit the same machinery in sum form, we give an
independent treatment of the factorial system over digit *functions* $c :
\mathbb{N} \to \mathbb{N}$, with value $\mathrm{value}(c, k) = \sum_{i<k} c_i\,i!$
and validity $c_i \le i$. This development depends on **none** of §3–§4 and proves
uniqueness without cardinality.

**Lemma 5.1 (Recurrence).** $\mathrm{value}(c, k+1) = \mathrm{value}(c, k) + c_k
\cdot k!$.

**Lemma 5.2 (Monotone validity).** If $c$ is valid up to $k+1$ then it is valid up
to $k$.

**Theorem 5.3 (Digit bound).** If $c$ is valid up to $k$ then $\mathrm{value}(c, k)
< k!$.

*Proof sketch.* Induction on $k$. Using $\mathrm{value}(c, k+1) = \mathrm{value}(c,
k) + c_k\,k!$, the bound $c_k \le k$, $(k+1)! = (k+1)\,k!$, and the inductive
$\mathrm{value}(c, k) < k!$:
$$\mathrm{value}(c, k+1) < k! + k\cdot k! = (k+1)\,k! = (k+1)!. \qquad \square$$

**Theorem 5.4 (Splitting by division).** If $c$ is valid up to $k+1$ then
$$\mathrm{value}(c, k+1) \,/\, k! = c_k, \qquad \mathrm{value}(c, k+1) \bmod k! =
\mathrm{value}(c, k).$$

*Proof sketch.* Write $\mathrm{value}(c, k+1) = \mathrm{value}(c, k) + c_k\,k!$ with
$\mathrm{value}(c, k) < k!$ by Theorem 5.3. Euclidean division by $k!$ then reads
off quotient $c_k$ and remainder $\mathrm{value}(c, k)$. $\square$

**Theorem 5.5 (Uniqueness, non-circular).** If $c, d$ are valid up to $k$ and
$\mathrm{value}(c, k) = \mathrm{value}(d, k)$, then $c_i = d_i$ for all $i < k$.

*Proof sketch.* Induction on $k$. In the step, the top digits agree by Theorem 5.4
(division): $c_k = \mathrm{value}(c, k+1)/k! = \mathrm{value}(d, k+1)/k! = d_k$.
The lower values agree by Theorem 5.4 (remainder): $\mathrm{value}(c, k) =
\mathrm{value}(c, k+1) \bmod k! = \mathrm{value}(d, k+1) \bmod k! = \mathrm{value}
(d, k)$, so the induction hypothesis gives $c_i = d_i$ for $i < k$, and $c_k = d_k$
closes the remaining case. No cardinality, surjectivity, or bijection theorem is
used. $\square$

**Definition 5.6 (Explicit digits).** $\mathrm{digit}(n, i) = (n / i!) \bmod
(i+1)$.

**Theorem 5.7 (Digit validity).** $\mathrm{digit}(n, \cdot)$ is valid up to any
$k$: $(n/i!) \bmod (i+1) \le i$.

**Theorem 5.8 (Existence).** If $n < k!$ then $\mathrm{value}(\mathrm{digit}(n,
\cdot), k) = n$.

*Proof sketch.* Prove by induction the identity $n = \sum_{i<k} ((n/i!) \bmod
(i+1))\,i! + (n/k!)\,k!$ (the inductive step uses $n/((k+1)\,k!) = (n/k!)/(k+1)$ and
$\mathrm{mod}$–$\mathrm{div}$ reassembly). For $n < k!$ the trailing term vanishes
($n/k! = 0$), leaving $n = \mathrm{value}(\mathrm{digit}(n, \cdot), k)$. $\square$

Together, Theorems 5.5 and 5.8 establish the factoradic bijection between $\{0,
\dots, k!-1\}$ and valid length-$k$ digit functions — by direct construction, with
uniqueness and existence each proved on its own terms.

---

## 6. Algorithms

**Algorithm A (Mixed-radix encode).** Input $n$, bases $bs$. Repeatedly emit $n
\bmod b_i$ and update $n \leftarrow n / b_i$. Runs in $O(k)$ big-integer
divisions for $k = |bs|$. Correct by Lemma 3.4 (validity) and Corollary 3.3
(round-trip).

**Algorithm B (Mixed-radix decode).** Input digit list $ds$, bases $bs$. Evaluate
the Horner form $d_0 + b_0(d_1 + \cdots)$ from most significant downward, or
accumulate $\sum_i d_i \prod_{j<i} b_j$ from least significant upward. $O(k)$
multiply-adds. Correct by Theorem 3.6.

**Algorithm C (Factoradic of a permutation rank).** The Lehmer code / factoradic
of a rank $n < k!$ is $\mathrm{mdigits}(\mathrm{bases}(k), n)$, which by Lemma 4.7
yields digits $c_i \le i+1$ encoding the $n$-th permutation in lexicographic order.
This is Algorithm A specialized to $\mathrm{bases}(k)$.

---

## 7. Applications

- **Permutation indexing.** The factorial system is the natural address space for
  permutations; ranking/unranking is exactly encode/decode in $\mathrm{bases}(k)$.
- **Calendar and time arithmetic.** Seconds→minutes→hours→days carry at
  $60, 60, 24, \dots$: a mixed-radix system whose capacity is the product of those
  moduli.
- **Compact combinatorial codes.** Any product set $\prod_i \{0, \dots, b_i - 1\}$
  is linearly addressed by Theorem 3.7, giving a contiguous integer encoding with
  guaranteed no collisions and no gaps.
- **Conservative library design.** Theorem 4.2 shows mixed-radix evaluation
  restricts to standard base-$b$ evaluation, so the framework can sit beneath an
  existing positional-numeral library without conflict.

---

## 8. Discussion

The architecture is intentionally lean: a single master law (Theorem 3.2) plus
list induction yields validity, the value bound, uniqueness, and the bijection. The
boundary case $b_i = 0$ is handled honestly — a zero base makes validity
unsatisfiable at that position, so universally quantified statements about valid
representations hold (non-vacuously, as statements about *all* valid lists) without
requiring a global positivity hypothesis except where a genuine bijection over
$\mathrm{Fin}(\mathrm{cap})$ is asserted (Theorem 3.7), which needs positivity to
ensure each digit class is nonempty.

The standalone factorial development (§5) is included precisely to make the
non-circularity visible: uniqueness there flows from the digit bound (Theorem 5.3)
and Euclidean division by $k!$ (Theorem 5.4), never from counting the
representations. The two developments agree on the same object: the list-based
$\mathrm{bases}(k)$ instance and the sum-based $\mathrm{value}/i!$ formulation are
two faces of the factoradic system.

---

## 9. Future work

- Extend to **infinite** base sequences and the resulting profinite / odometer
  dynamics, treating $\mathrm{mval}$ as a map into a projective limit.
- Develop **signed** and **balanced** mixed-radix digit sets and their unique
  representations.
- Formalize **arithmetic algorithms** (addition with mixed-radix carry,
  comparison) and their complexity directly on digit lists.
- Connect the crowning bijection to the **combinatorial number system** and to
  Gray-code style orderings of $\prod_i \{0, \dots, b_i - 1\}$.

---

## Appendix: index of formal results

- `mval`, `mdigits`, `radixProd` / capacity, `Valid` / `Forall₂ (· < ·)` —
  Definitions 2.1–2.4.
- `mdigits_length` — Lemma 3.1.
- `mval_mdigits` — Theorem 3.2 (master law).
- `mval_mdigits_of_lt` — Corollary 3.3.
- `mdigits_forall₂_lt` — Lemma 3.4.
- `mval_lt_prod` — Lemma 3.5.
- `mdigits_mval` — Theorem 3.6 (uniqueness).
- `mixedRadixEquiv` — Theorem 3.7 (bijection).
- `uniformBase.prod_replicate`, `mval_replicate_eq_ofDigits`,
  `uniform_roundtrip` — Lemma 4.1, Theorems 4.2–4.3.
- `Factorial.prod_bases`, `bases_pos`, `factoradic_roundtrip`,
  `factoradic_digits_valid` — Lemmas 4.4–4.5, Theorems 4.6–4.7.
- `FactorialNumberSystem.value_lt`, `splitting_div`, `splitting_mod`,
  `value_unique`, `digit_valid`, `value_digit` — Theorems 5.3–5.8.
