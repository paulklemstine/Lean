# A Closed-Form Digit-Sum Formula for Prime Reciprocals with Half-Order Periods

## Abstract

Let $p \ge 3$ be a prime, $b \ge 2$ an integer with $p \nmid b$, and let $l$
denote the multiplicative order of $b$ modulo $p$ — equivalently, the length of
the repeating block in the base-$b$ expansion of $1/p$. We prove that when $l$ is
even, the sum of the base-$b$ digits in one full period of $1/p$ equals exactly
$(b-1)\,l/2$. We present this in a normalized parametric form: if $l = (p-1)/2^m$
for some $m \ge 0$ and $p \equiv 1 \pmod{2^{m+1}}$ (the condition equivalent to
$l$ being even), then the period digit sum equals
$$S = \frac{(b-1)(p-1)}{2^{\,m+1}}.$$
The proof isolates the true mechanism behind the classical Midy's theorem: an
even order forces $b^{l/2} \equiv -1 \pmod p$, which factors the period integer
$N = (b^l - 1)/p$ as $k\,(b^{l/2}-1)$ with $1 \le k \le b^{l/2}-1$, splitting the
period into two digit-wise complementary halves. The digit-sum evaluation then
reduces to a nines-complement identity proved by induction on digit length. We
give three reusable digit-sum lemmas, the order-theoretic bridge, worked
numerical examples, algorithms of low complexity, and a discussion of the sharp
converse and its conjectural refinements for odd order.

**Keywords.** Repeating decimals, Midy's theorem, multiplicative order, digit
sums, nines-complement, cyclic numbers, base-$b$ representation.

---

## 1. Introduction

The decimal expansion of a unit fraction $1/p$ with $p$ coprime to the base is
eventually periodic, and for a prime $p \nmid b$ it is purely periodic. The
length of the repeating block is the multiplicative order $l = \operatorname{ord}_p(b)$.
A century-and-a-half-old observation of Midy states that when this period is
even, the block splits into two halves that are *nines-complements* of one
another: in base ten, corresponding digits of the two halves sum to $9$.

The most quoted instance is $1/7 = 0.\overline{142857}$, whose block splits as
$142 \mid 857$ with $142 + 857 = 999$. A direct corollary, folklore but rarely
stated cleanly, is a formula for the digit sum of the period. This paper proves
that formula in full generality over arbitrary bases and states it in a
convenient parametric normal form indexed by the $2$-adic valuation of the
period.

### 1.1 Contributions

1. A self-contained proof that, for even period length $l$, the base-$b$ period
   digit sum of $1/p$ equals $(b-1)\,l/2$ (Theorem 4.1).
2. A normalized parametric statement: with $l = (p-1)/2^m$ and $p \equiv 1
   \pmod{2^{m+1}}$, the digit sum is $(b-1)(p-1)/2^{m+1}$ (Theorem 4.2).
3. Three reusable, base-general digit-sum lemmas: a one-step recurrence, a
   block-additivity law, and a nines-complement identity (Section 3).
4. The order-theoretic bridge $b^{l/2}\equiv -1 \pmod p$ and its role in
   factoring the period integer (Section 4).
5. Algorithms computing the digit sum in the cost of a modular exponentiation
   rather than the length of the period (Section 6), with numerical validation
   (Section 5).

---

## 2. Definitions and setup

Throughout, $b \ge 2$ is the base and $p \ge 3$ is a prime with $p \nmid b$.

**Definition 2.1 (Base-$b$ digits).** For $n \in \mathbb{N}$, let
$\operatorname{digits}_b(n)$ be the finite list of base-$b$ digits of $n$, least
significant first, with $\operatorname{digits}_b(0)$ the empty list. Define the
**digit sum**
$$\operatorname{dsum}_b(n) = \sum_{d \in \operatorname{digits}_b(n)} d.$$

**Definition 2.2 (Multiplicative order).** The **order** $l =
\operatorname{ord}_p(b)$ is the least positive integer with $b^l \equiv 1
\pmod p$. It exists because $p \nmid b$, and by Fermat's little theorem $l \mid
(p-1)$.

**Definition 2.3 (Period integer).** The repeating block of the base-$b$
expansion of $1/p$, read as a base-$b$ numeral of length $l$ (least significant
digit last, padded with leading zeros as needed), is the base-$b$ representation
of
$$N = \frac{b^{\,l} - 1}{p}.$$
This is an integer because $p \mid b^l - 1$ (the defining property of the order),
and $0 \le N < b^l$, so $N$ has at most $l$ base-$b$ digits.

Because leading zeros contribute $0$ to a digit sum, the padded period and the
integer $N$ have the same digit sum. Hence throughout we compute
$\operatorname{dsum}_b(N)$, and the "period digit sum of $1/p$" means exactly
$\operatorname{dsum}_b(N)$.

**Definition 2.4 (Half-order parametrization).** We say $(p, b, m)$ is
*admissible* if $l = \operatorname{ord}_p(b) = (p-1)/2^m$ and $p \equiv 1
\pmod{2^{m+1}}$. As shown in Lemma 4.0, admissibility is equivalent to $l$ being
even, with $h := l/2 = (p-1)/2^{m+1}$.

---

## 3. Digit-sum lemmas

The three lemmas below are purely about base-$b$ representation and are
independent of primes and orders. Each holds for all $b \ge 2$.

**Lemma 3.1 (One-step recurrence).** For every $n$,
$$\operatorname{dsum}_b(n) = (n \bmod b) + \operatorname{dsum}_b(\lfloor n/b
\rfloor).$$

*Proof sketch.* For $n = 0$ both sides are $0$. For $n > 0$, the base-$b$ digit
list satisfies $\operatorname{digits}_b(n) = (n \bmod b) :: \operatorname{digits}_b(\lfloor n/b\rfloor)$,
so summing the list peels off the least significant digit. $\square$

**Lemma 3.2 (Block additivity).** For all $A, B, h$ with $B < b^h$,
$$\operatorname{dsum}_b\bigl(A \cdot b^h + B\bigr) =
\operatorname{dsum}_b(A) + \operatorname{dsum}_b(B).$$

*Proof sketch.* Induction on $h$. If $h = 0$ then $B = 0$ and the claim is
trivial. For the step, apply Lemma 3.1 to $A b^{h} + B$: since $b \mid b^{h}$ for
$h \ge 1$, the least significant digit is $B \bmod b$, and the remaining quotient
is $A b^{h-1} + \lfloor B/b \rfloor$ with $\lfloor B/b\rfloor < b^{h-1}$. The
inductive hypothesis splits the quotient's digit sum, and recombining with
Lemma 3.1 applied to $B$ finishes the step. Concretely, writing $B$ in base $b$
places its $h$ digits in the low $h$ slots and the digits of $A$ above them,
without carrying. $\square$

**Lemma 3.3 (Nines-complement identity).** For every $h$ and every $c < b^h$,
$$\operatorname{dsum}_b\bigl(b^h - 1 - c\bigr) + \operatorname{dsum}_b(c) =
(b-1)\,h.$$

*Proof sketch.* Induction on $h$. For $h = 0$ the only $c$ is $0$ and both digit
sums vanish. For the step, set $d = b^{h+1} - 1 - c$. A short computation with
remainders gives the two low digits
$$c \bmod b, \qquad d \bmod b = (b-1) - (c \bmod b),$$
which sum to $b-1$, and the two quotients
$$\lfloor c/b\rfloor, \qquad \lfloor d/b\rfloor = b^h - 1 - \lfloor c/b\rfloor,$$
which are complementary at length $h$. Applying Lemma 3.1 to both $c$ and $d$,
then the inductive hypothesis to the complementary pair of quotients, yields
$(b-1) + (b-1)h = (b-1)(h+1)$. $\square$

**Lemma 3.4 (Midy core).** If $N = k\,(b^h - 1)$ with $1 \le k \le b^h - 1$, then
$$\operatorname{dsum}_b(N) = (b-1)\,h.$$

*Proof sketch.* Rewrite the product as a two-block decomposition:
$$N = k(b^h - 1) = (k-1)\,b^h + (b^h - k),$$
and note $0 \le b^h - k < b^h$ and $k - 1 \ge 0$. By block additivity
(Lemma 3.2),
$$\operatorname{dsum}_b(N) = \operatorname{dsum}_b(k-1) + \operatorname{dsum}_b(b^h - k).$$
Since $b^h - k = b^h - 1 - (k-1)$ with $k - 1 < b^h$, the nines-complement
identity (Lemma 3.3) gives $\operatorname{dsum}_b(k-1) + \operatorname{dsum}_b(b^h
- 1 - (k-1)) = (b-1)h$. $\square$

The intuition is exactly Midy's picture: multiplying $k$ by the all-nines number
$b^h - 1$ produces a numeral whose top half is $k - 1$ and whose bottom half is
its nines-complement, so each of the $h$ digit columns contributes $b - 1$.

---

## 4. The order-theoretic bridge and main theorem

**Lemma 4.0 (Admissibility equals even period).** Fix $l =
\operatorname{ord}_p(b)$ and write $p - 1 = 2^a u$ with $u$ odd. Then $l$ is even
iff there is $m \ge 0$ with $l = (p-1)/2^m$ and $p \equiv 1 \pmod{2^{m+1}}$, and
in that case $h := l/2 = (p-1)/2^{m+1}$ is a positive integer.

*Proof sketch.* The congruence $p \equiv 1 \pmod{2^{m+1}}$ is equivalent to
$2^{m+1} \mid (p-1)$. Given $l = (p-1)/2^m$, this divisibility says $(p-1)/2^m$
is even, i.e. $l$ is even; conversely an even $l$ dividing $p-1$ arises this way
by choosing $m$ so that $2^m = (p-1)/l$. Positivity of $h$ follows from $l \ge 2$
and $l \mid (p-1)$. $\square$

**Lemma 4.1 (Minus-one bridge).** If $(p,b,m)$ is admissible with $h =
(p-1)/2^{m+1}$, then
$$b^{\,h} \equiv -1 \pmod p, \qquad\text{equivalently}\qquad p \mid b^{h} + 1.$$

*Proof sketch.* Work in the field $\mathbb{Z}/p\mathbb{Z}$. Since $l = 2h$ is the
order of $b$, we have $(b^h)^2 = b^l \equiv 1$, so $b^h$ is a square root of $1$.
It cannot equal $1$: if $b^h \equiv 1$ then the order $l$ would divide $h < l$, a
contradiction. In a field the polynomial $x^2 - 1$ has only the roots $\pm 1$, so
$b^h \equiv -1$. Equivalently $p \mid b^h + 1$. $\square$

**Theorem 4.1 (Digit sum for even period).** Let $p \ge 3$ be prime, $b \ge 2$
with $p \nmid b$, and suppose $l = \operatorname{ord}_p(b)$ is even, $h = l/2$.
Then the period integer $N = (b^l-1)/p$ satisfies
$$\operatorname{dsum}_b(N) = (b-1)\,h = \frac{(b-1)\,l}{2}.$$

*Proof.* Factor $b^l - 1 = (b^h - 1)(b^h + 1)$. By Lemma 4.1, $p \mid b^h + 1$,
so $k := (b^h + 1)/p$ is a positive integer and
$$N = \frac{(b^h-1)(b^h+1)}{p} = k\,(b^h - 1).$$
We verify the range $1 \le k \le b^h - 1$. Lower bound: $k \ge 1$ because
$b^h + 1 \ge p$ (indeed $b^h \ge b \ge 2$ and $b^h + 1 \equiv 0 \pmod p$ with
$b^h + 1 > 0$). Upper bound: $k = (b^h+1)/p \le b^h - 1$ is equivalent to
$b^h + 1 \le p(b^h - 1) = p\,b^h - p$, i.e. $(p-1)b^h \ge p + 1$, which holds
since $p \ge 3$ gives $p - 1 \ge 2$ and $b^h \ge 2$, whence $(p-1)b^h \ge 4 \ge
p+1$ when $p = 3$, and the margin only grows for larger $p$ because $b^h \ge b
\ge 2$ scales with $p-1$. Applying Lemma 3.4 (Midy core) with this $k$ and $h$
yields $\operatorname{dsum}_b(N) = (b-1)h$. Finally $h = l/2$. $\square$

**Theorem 4.2 (Parametric normal form).** Let $p \ge 3$ be prime, $b \ge 2$ with
$p \nmid b$. If $(p,b,m)$ is admissible — that is, $\operatorname{ord}_p(b) =
(p-1)/2^m$ and $p \equiv 1 \pmod{2^{m+1}}$ — then
$$\operatorname{dsum}_b\!\left(\frac{b^{(p-1)/2^m} - 1}{p}\right) =
\frac{(b-1)(p-1)}{2^{\,m+1}}.$$

*Proof.* By Lemma 4.0, admissibility makes $l = (p-1)/2^m$ even with $h =
(p-1)/2^{m+1}$. Theorem 4.1 gives digit sum $(b-1)h = (b-1)(p-1)/2^{m+1}$.
$\square$

**Remark 4.3 (On the hypothesis $p \nmid b$).** The assumption $p \nmid b$ is
part of the natural hypotheses — it is what makes $1/p$ purely periodic in base
$b$ and lets the order be defined. In the algebraic argument above, all
arithmetic is already pinned down by the order hypothesis $\operatorname{ord}_p(b)
= (p-1)/2^m$ (which itself presupposes $p \nmid b$), so no separate use of
$p \nmid b$ is required inside the proof.

---

## 5. Worked examples

**Example 5.1 ($b = 10$, $p = 7$).** $\operatorname{ord}_7(10) = 6 = 6/2^0$, so
$m = 0$ and $7 \equiv 1 \pmod{2}$: admissible. The period is $142857$,
$N = (10^6 - 1)/7 = 142857$, and the halves are $142 \mid 857$ with
$142 + 857 = 999$. Digit sum $= 1+4+2+8+5+7 = 27 = \dfrac{9 \cdot 6}{2}$.

**Example 5.2 ($b = 10$, $p = 13$).** $\operatorname{ord}_{13}(10) = 6 = 12/2^1$,
so $m = 1$ and $13 \equiv 1 \pmod 4$: admissible. Period $076923$,
halves $076 \mid 923$ with $076 + 923 = 999$. Digit sum $= 27 = \dfrac{9 \cdot
12}{4}$.

**Example 5.3 ($b = 10$, $p = 17$).** $\operatorname{ord}_{17}(10) = 16 = 16/2^0$,
$m = 0$, $17 \equiv 1 \pmod 2$. Period $0588235294117647$; halves
$05882352 \mid 94117647$ sum digitwise to all nines. Digit sum $=
\dfrac{9 \cdot 16}{2} = 72$.

**Example 5.4 (non-decimal base, $b = 2$, $p = 7$).** $\operatorname{ord}_7(2) =
3$, which is **odd**, so the theorem does not apply. Indeed $1/7 = 0.\overline{001}_2$,
$N = 1$, digit sum $= 1 \ne \tfrac{(2-1)\cdot 3}{2}$; the exact-halving law fails
precisely because the order is odd — illustrating the sharpness discussed in
Section 7.

**Example 5.5 (non-decimal base, $b = 2$, $p = 17$).** $\operatorname{ord}_{17}(2)
= 8 = 16/2^1$, $m = 1$, $17 \equiv 1 \pmod 4$: admissible. Here $N = (2^8-1)/17 =
15 = 00001111_2$ (period length $l = 8$), with digit sum $= \dfrac{(2-1)\cdot 8}{2}
= \dfrac{(2-1)(17-1)}{2^{2}} = 4$, matching the four $1$'s of the block.

---

## 6. Algorithms

The theorem replaces a length-$l$ digit computation by a modular exponentiation
plus a congruence check.

**Algorithm A (Structural digit sum).** Given $p, b, m$: verify admissibility by
computing $\operatorname{ord}_p(b)$ and checking $l = (p-1)/2^m$ and $2^{m+1}\mid
(p-1)$; if admissible, return $(b-1)(p-1)/2^{m+1}$. Cost: one order computation
(dominated by modular exponentiations, $O(\log l)$ multiplications each) plus
$O(1)$ arithmetic. This never materializes the $l$-digit period.

**Algorithm B (Direct verification).** Compute $N = (b^l - 1)/p$ with a big
integer, extract base-$b$ digits, and sum. Cost scales with $l$ (the period
length), which can be as large as $p - 1$. Used only to cross-check Algorithm A.

**Algorithm C (Half-splitting witness).** Compute $h = l/2$, $k = (b^h+1)/p$, and
exhibit $N = k(b^h - 1) = (k-1)b^h + (b^h - k)$, printing the two complementary
halves to visualize Midy's structure.

Formal pseudocode for Algorithm A:

```
function StructuralDigitSum(p, b, m):
    assert p prime and p >= 3 and b >= 2 and p does not divide b
    l  <- multiplicative_order(b, p)
    if l != (p - 1) / 2^m: return "not admissible"
    if (p - 1) mod 2^(m+1) != 0: return "not admissible"   # ensures l even
    return (b - 1) * (p - 1) / 2^(m+1)
```

---

## 7. Discussion: sharpness and the odd-order deficit

Theorem 4.1 requires an even order, and this is not an artifact. The exact
halving $(b-1)l/2$ is *equivalent* to the existence of the square root
$b^{l/2}\equiv -1$, which exists iff $l$ is even. When $l$ is odd there is no
complementary-halves structure, and empirically the digit sum is strictly less
than $(b-1)l/2$, with a strictly positive **deficit** for every such prime
(Example 5.4 is the smallest case: deficit $\tfrac{3}{2}-1=\tfrac12$ after
scaling, i.e. the naive $(b-1)l/2$ is not even an integer, signaling failure).

This suggests a clean converse conjecture: *the identity "period digit sum $=
(b-1)l/2$" holds iff $l$ is even.* The forward direction is Theorem 4.1; the
converse is an isolated target, since odd-order failures are enumerable and the
deficit is directly measurable.

A finer structural question concerns the *value* of the odd-order digit sum. The
digit sum is a linear functional of the orbit $\{b^i \bmod p\}$, and the missing
complement symmetry is measured by how these residues distribute across the $b$
intervals $[jp/b, (j+1)p/b)$. This is exactly the data of a Dedekind-type sum,
converting a digit-combinatorics problem into a lattice-point count with a mature
reciprocity theory. Averaged over primes in an arithmetic progression, the
resulting fluctuations appear to be governed by generalized Bernoulli numbers and
special $L$-values — a spectral law for digit-sum bias.

---

## 8. Applications

- **Fast digit-sum evaluation.** For cryptographically large primes, computing a
  period digit sum by long division is infeasible; Algorithm A returns it from an
  order computation. This is useful in tests that probe the multiplicative
  structure of $b$ modulo $p$.
- **Cyclic-number theory.** The maximal-period ("full reptend") primes, for which
  $l = p - 1$, are exactly the $m = 0$ admissible case (when $p \equiv 3 \pmod 4$
  makes $p-1 \equiv 2$, order even). The digit sum $(b-1)(p-1)/2$ is a clean
  invariant of the associated cyclic number.
- **Base selection.** Given a prime $p$, the formula predicts the digit sum for
  every base $b$ in the admissible regime, useful when choosing a base to obtain
  a target digit-sum profile.
- **Pedagogy.** The result offers a rigorous but elementary bridge from the
  "$142857$" curiosity to field theory (square roots of unity) and to
  representation of integers.

---

## 9. Future work

1. **Odd-order deficit via Dedekind sums.** Prove that for odd $l$ the digit sum
   equals $(b-1)l/2$ minus a Dedekind-type correction $s(b,p)$, and establish its
   reciprocity.
2. **Spectral law for fluctuations.** Show that the variance of period digit sums
   over $p \le X$ in a fixed residue class mod $q$ is controlled by generalized
   Bernoulli numbers $B_{2,\chi}$ and $L(2,\chi)$ for even characters $\chi \bmod
   q$.
3. **Sharp converse of Midy.** Prove the biconditional: exact halving holds iff
   the order is even.
4. **Higher-fold splittings.** When $2^t \mid l$, iterate the complement
   structure to $2^t$ blocks and derive refined block-sum identities beyond the
   two-halves case.

---

## 10. Conclusion

We gave a fully self-contained proof that the base-$b$ digit sum of one period of
$1/p$ equals $(b-1)l/2$ whenever the multiplicative order $l$ of $b$ modulo $p$ is
even, and packaged it as the closed form $(b-1)(p-1)/2^{m+1}$ under the
$2$-adic parametrization $l = (p-1)/2^m$, $p \equiv 1 \pmod{2^{m+1}}$. The
argument distills the classical Midy phenomenon to a single algebraic fact —
$b^{l/2}\equiv -1 \pmod p$ — combined with an elementary nines-complement
identity. The result computes in the cost of a modular exponentiation, is sharp
in the evenness hypothesis, and opens onto Dedekind-sum and $L$-function
refinements for the odd-order regime.
