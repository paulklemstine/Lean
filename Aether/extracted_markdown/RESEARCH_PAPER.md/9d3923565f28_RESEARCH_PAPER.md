# Narcissistic Numbers Are Finite: A Verified Growth-Race Bound, with Notes Toward a Bestiary of Digit-Monsters

## Abstract

A natural number $n$ is *narcissistic* (an Armstrong number, or plus-perfect
number) if it equals the sum of its decimal digits each raised to the power of
the number of digits it has. The smallest nontrivial three-digit specimen is
$153 = 1^3 + 5^3 + 3^3$. We give a complete, machine-checked development of the
elementary theory of narcissistic numbers, culminating in a finiteness theorem:
**every narcissistic number is strictly smaller than $10^{60}$**, and hence the
set of narcissistic numbers is finite. The proof is a *growth race*: the
self-assembling digit-power sum of a $d$-digit number is bounded above by
$d\cdot 9^d$, while the number itself is bounded below by $10^{d-1}$, and for all
$d\ge 61$ the former is strictly less than the latter. We also establish
decidability of the narcissistic predicate and certify the canonical specimens
$1, 153, 370, 371, 407$. Along the way we document a subtle definitional pitfall
in self-referential digit definitions (base-of vs. digits-of), and we situate
narcissistic numbers within a broader "bestiary" of digit-combinatorial objects —
Harshad numbers, vampire numbers, and the Kaprekar routine — sketching how the
finiteness/infinitude dichotomy is governed by whether the defining recipe uses
bounded or length-dependent weights. All results are formalized and verified.

**Keywords:** narcissistic numbers, Armstrong numbers, digit functions, decimal
representation, finiteness theorems, recreational number theory, formal
verification, Harshad numbers, vampire numbers, Kaprekar constant.

**MSC 2020:** 11A63 (radix representation, digital problems), 11Y55 (calculation
of integer sequences), 68V20 (formalization of mathematics).

---

## 1. Introduction

Among the oldest recreational objects in number theory are integers that can be
reconstructed from their own digits by a fixed arithmetic recipe. The most
celebrated of these is the **narcissistic number**: an integer with $d$ decimal
digits that equals the sum of those digits each raised to the $d$-th power. The
prototypical example,
$$153 = 1^3 + 5^3 + 3^3,$$
has been a mathematical curiosity since antiquity. Such numbers are also called
*Armstrong numbers* (after Michael F. Armstrong, who used them in programming
courses) and *plus-perfect numbers*.

What lifts narcissistic numbers above mere amusement is a striking structural
fact: **there are only finitely many of them.** Unlike, say, the primes or the
Harshad numbers, the narcissistic species terminates. There is a largest
narcissistic number — the 39-digit
$$115132219018763992565095597973971522401$$
— and no narcissistic number has 40 or more digits. The reason is a clean
growth-rate argument that is entirely elementary yet genuinely non-obvious, and
it is the centerpiece of this paper.

We present a self-contained, formally verified treatment. Our contributions are:

1. A corrected, robust **definition** of the narcissistic predicate that avoids a
   notational trap in self-referential digit definitions (Section 3).
2. A **digit-power upper bound** (Theorem 1): the digit-power sum of a $d$-digit
   number is at most $d\cdot 9^d$.
3. A **crossover inequality** (Theorem 2): $d\cdot 9^d < 10^{d-1}$ for all
   $d\ge 61$.
4. A **finiteness theorem** (Theorem 3): every narcissistic number is below
   $10^{60}$.
5. **Decidability** of the predicate (Theorem 4) and **certified specimens**
   $1,153,370,371,407$.

We close with the wider bestiary (Section 7) and a falsifiable research program
(Section 8), including a conjectured sharpening of the bound from $10^{60}$ to the
exact frontier at $10^{39}$.

---

## 2. Preliminaries: decimal digits

We work in the natural numbers $\mathbb{N} = \{0,1,2,\dots\}$. For a base
$b \ge 2$ and $n \in \mathbb{N}$, let
$$\mathrm{digits}_b(n) = (d_0, d_1, \dots, d_{k-1})$$
denote the list of base-$b$ digits of $n$ in *little-endian* order (least
significant digit first), with the conventions that $\mathrm{digits}_b(0)$ is the
empty list and that for $n>0$ the leading digit $d_{k-1}$ is nonzero. We write
$L(n) = |\mathrm{digits}_{10}(n)|$ for the number of decimal digits of $n$.

We use the following standard facts about decimal digits, all available in the
formal library:

- **(D1) Digit bound.** Every entry of $\mathrm{digits}_{10}(n)$ is at most $9$;
  i.e. each digit $d_i$ satisfies $d_i < 10$, hence $d_i \le 9$.
- **(D2) Length via logarithm.** For $n \ge 1$,
  $L(n) = \lfloor \log_{10} n \rfloor + 1$.
- **(D3) Length–magnitude correspondence.** For $n \ge 1$,
  $$10^{\,L(n)-1} \le n < 10^{\,L(n)}.$$
  Equivalently, $n$ has exactly $d$ digits iff $10^{d-1}\le n < 10^{d}$. The
  lower bound $10^{L(n)-1}\le n$ is the only direction we need; it expresses that
  a $d$-digit number is at least the smallest $d$-digit number.

We model the digit-power sum using a right fold over the digit list. For a list
$\ell = (a_0,\dots,a_{k-1})$ of naturals and an exponent $E$, define
$$S_E(\ell) = \mathrm{foldr}\big(\lambda\, d\ \mathrm{acc}.\ \mathrm{acc} + d^{E}\big)\ 0\ \ell
            = \sum_{i=0}^{k-1} a_i^{\,E}.$$
The fold formulation is convenient for induction and is exactly what the formal
definition uses.

---

## 3. The definition, and a self-referential pitfall

### 3.1 Definition

> **Definition 1 (narcissistic number).** A natural number $n$ is *narcissistic*
> if
> $$n = S_{L(n)}\big(\mathrm{digits}_{10}(n)\big) = \sum_{i=0}^{L(n)-1} d_i^{\,L(n)},$$
> where $\mathrm{digits}_{10}(n) = (d_0,\dots,d_{L(n)-1})$ and $L(n)$ is the number
> of decimal digits of $n$. We write $\mathrm{Narc}(n)$ for this predicate.

In words: raise each decimal digit of $n$ to the power equal to the *count* of
digits, and sum; $n$ is narcissistic iff the result is $n$ again.

Single-digit numbers $0,1,\dots,9$ are all narcissistic, since $L(n)=1$ and
$d^1=d$. The first nontrivial specimens occur at $d=3$.

### 3.2 The pitfall

The narcissistic predicate is *self-referential*: the digit list of $n$ appears
twice, once to supply the summands and once (via its length) to supply the
exponent. This invites a notational hazard. A naive rendering of "the base-10
digits of $n$" using dot/method notation can parse as "the base-$n$ digits of the
number 10," i.e. it swaps the roles of $n$ and the base. Concretely, the
expression `n.digits 10` (read as a method call) denotes $\mathrm{digits}_n(10)$,
the base-$n$ representation of $10$, rather than the intended
$\mathrm{digits}_{10}(n)$.

Under that misreading the predicate degenerates badly. For $n=153$, the base-$153$
digits of $10$ are just $(10)$, of length $1$, and the "narcissistic" condition
becomes $153 = 10^1 = 10$, which is false. Every intended specimen theorem would
likewise be false. The fix is to write the base-10 digit extraction explicitly,
as $\mathrm{digits}_{10}(n)$, fixing the base as the first argument. Our formal
Definition 1 uses precisely this corrected form. This is a small but instructive
reminder that self-referential definitions must be pinned down with care: the
definition of narcissism is itself vulnerable to confusing one reflection for
another.

---

## 4. The digit-power upper bound

We first isolate a purely list-theoretic lemma, then specialize it to digit
lists.

> **Lemma 1 (fold bound for bounded lists).** Let $\ell$ be a finite list of
> natural numbers with every entry $\le 9$, and let $E\in\mathbb{N}$. Then
> $$S_E(\ell) \le |\ell| \cdot 9^{E}.$$

*Proof.* Induct on $\ell$. The empty list gives $0 \le 0$. For a cons
$\ell = a :: \ell'$ with $a\le 9$ and every entry of $\ell'$ also $\le 9$, the
fold satisfies $S_E(a::\ell') = S_E(\ell') + a^{E}$. By the induction hypothesis
$S_E(\ell') \le |\ell'|\cdot 9^E$, and by monotonicity of $x\mapsto x^E$ together
with $a\le 9$ we have $a^E\le 9^E$. Adding,
$$S_E(a::\ell') \le |\ell'|\cdot 9^E + 9^E = (|\ell'|+1)\cdot 9^E = |a::\ell'|\cdot 9^E. \qquad\square$$

Specializing $E = L(n)$ and $\ell = \mathrm{digits}_{10}(n)$, and using the digit
bound (D1) to supply the hypothesis "every entry $\le 9$", we obtain:

> **Theorem 1 (digit-power bound).** For every $n\in\mathbb{N}$,
> $$S_{L(n)}\big(\mathrm{digits}_{10}(n)\big) \le L(n)\cdot 9^{\,L(n)}.$$

That is, the entire self-assembling digit-power sum of a $d$-digit number can
never exceed $d\cdot 9^d$. This is the *ceiling* in the growth race.

---

## 5. The crossover inequality

The *floor* in the race is the trivial lower bound $10^{d-1}\le n$ for a
$d$-digit number (fact D3). The race is decided by comparing the ceiling
$d\cdot 9^d$ against the floor $10^{d-1}$.

> **Theorem 2 (crossover).** For every integer $d\ge 61$,
> $$d\cdot 9^{d} < 10^{\,d-1}.$$

*Proof.* We argue by induction on $d$ starting at the base case $d=61$. The base
case is a finite (if large) numerical verification: $61\cdot 9^{61} < 10^{60}$.
Intuitively, $9^{61}\approx 1.6\times 10^{58}$, so $61\cdot 9^{61}\approx
9.7\times 10^{59} < 10^{60}$.

For the inductive step, suppose $d\cdot 9^d < 10^{d-1}$ for some $d\ge 61$. We
must show $(d+1)\cdot 9^{d+1} < 10^{d}$. Write the step factors:
$$(d+1)\cdot 9^{d+1} = 9\cdot\frac{d+1}{d}\cdot \big(d\cdot 9^{d}\big)
   < 9\cdot\frac{d+1}{d}\cdot 10^{d-1}.$$
It therefore suffices to show $9\cdot\frac{d+1}{d}\cdot 10^{d-1}\le 10^{d}$, i.e.
$9\cdot\frac{d+1}{d}\le 10$, i.e. $9(d+1)\le 10d$, i.e. $9\le d$. Since $d\ge 61$,
this holds with enormous room to spare. (Formally the step is handled by
nonlinear arithmetic over the naturals using positivity of $9^d$ and the
induction hypothesis.) $\square$

The crossover threshold here is $d=61$, chosen because it yields the clean,
easily-certified consequence $10^{60}$ in the next section. The *true* crossover
— the smallest $d$ for which no $d$-digit narcissistic number can exist by this
argument — is lower, and the sharp empirical frontier is at $d=40$ (the largest
narcissistic number has 39 digits). See Conjecture C1 in Section 8.

---

## 6. Finiteness, decidability, and specimens

### 6.1 Finiteness

> **Theorem 3 (finiteness bound).** Every narcissistic number is strictly less
> than $10^{60}$. Consequently, the set of narcissistic numbers is finite.

*Proof.* Suppose, for contradiction, that $n$ is narcissistic with $n\ge 10^{60}$.
Let $d = L(n)$ be its number of digits. From $n\ge 10^{60}$ and the
length–magnitude correspondence (D3), the number of digits satisfies $d\ge 61$:
indeed $d = \lfloor\log_{10} n\rfloor + 1 \ge 60+1 = 61$.

Because $n$ is narcissistic, $n = S_{d}(\mathrm{digits}_{10}(n))$. By Theorem 1,
$$n = S_d(\mathrm{digits}_{10}(n)) \le d\cdot 9^{d}.$$
By Theorem 2 (applicable since $d\ge 61$),
$$d\cdot 9^{d} < 10^{\,d-1}.$$
Combining, $n < 10^{d-1}$. But by the floor bound (D3), $10^{d-1}\le n$. Hence
$n < 10^{d-1}\le n$, a contradiction. Therefore no narcissistic number is
$\ge 10^{60}$; equivalently every narcissistic number is $< 10^{60}$.

Finiteness is immediate: the narcissistic numbers form a subset of the finite set
$\{0,1,\dots,10^{60}-1\}$. $\square$

This is the main theorem. It converts an a priori infinite search ("are there
narcissistic numbers of every size?") into the inspection of a finite — though
astronomically large — range.

### 6.2 Decidability

> **Theorem 4 (decidability).** The predicate $\mathrm{Narc}$ is decidable: there
> is a terminating algorithm that, given $n$, returns whether $n$ is
> narcissistic.

*Proof.* The defining condition equates $n$ with a finite computation on $n$:
extract the (finite) digit list, compute its length, raise each digit to that
power, sum, and test equality of two naturals. Equality of naturals is decidable
and each constituent operation is computable, so the predicate is decidable by
composition. $\square$

Decidability is what allows the specimen results below to be certified by direct
evaluation.

### 6.3 Certified specimens

By Theorem 4 we may verify membership by computation. The following are
narcissistic (each certified by direct evaluation of Definition 1):

| $n$ | $L(n)$ | digit-power sum | narcissistic? |
|----:|:------:|:----------------|:-------------:|
| $1$   | 1 | $1^1 = 1$ | yes |
| $153$ | 3 | $1^3+5^3+3^3 = 1+125+27 = 153$ | yes |
| $370$ | 3 | $3^3+7^3+0^3 = 27+343+0 = 370$ | yes |
| $371$ | 3 | $3^3+7^3+1^3 = 27+343+1 = 371$ | yes |
| $407$ | 3 | $4^3+7^3+7^3 = 64+343+343 = 407$ | yes |

> **Theorem 5 (specimens).** Each of $1, 153, 370, 371, 407$ is narcissistic.

These four three-digit specimens are in fact *all* of the three-digit
narcissistic numbers; together with the trivial single-digit ones they form the
small end of the (finite) catalogue.

---

## 7. The wider bestiary

Narcissistic numbers belong to a larger family of digit-combinatorial objects.
The finiteness phenomenon proved above is best appreciated by contrast with its
neighbours.

### 7.1 Harshad (Niven) numbers — an infinite species

A number is **Harshad** (or **Niven**) if it is divisible by the sum of its
digits; e.g. $18$ is Harshad because $1+8=9 \mid 18$. The Harshad numbers are
*infinite*: every power of ten $10^k$ has digit sum $1$, which divides everything.
The structural reason is decisive: the Harshad recipe uses a **bounded weight**
(a plain digit sum, whose growth is at most $9\cdot L(n)$, only linear in the
length), so the analogue of the growth race never tips. Compare narcissistic
numbers, whose exponent $L(n)$ **grows with the number's length**, forcing the
$d\cdot 9^d$ ceiling to fall below $10^{d-1}$. This bounded-vs-length-dependent
dichotomy is conjectured (C2, Section 8) to govern finiteness across the entire
family of digit-additive species.

### 7.2 Vampire numbers — multiplicative monsters

A **vampire number** is a composite $v$ with an even number $2m$ of digits that
factors as $v = x\cdot y$, where $x$ and $y$ (the *fangs*) each have $m$ digits,
not both ending in zero, and whose concatenated digit multiset equals that of $v$.
The smallest is $1260 = 21\times 60$. Vampires are *multiplicative* digit
monsters, and their fine-grained distribution connects digit combinatorics to the
difficulty of integer factorization. A particularly charismatic subspecies is the
*prime vampire numbers*, whose fangs are both prime; the smallest is
$117067 = 167\times 701$ (see C4, Section 8).

### 7.3 The Kaprekar vortex — a dynamical monster

The **Kaprekar routine** maps a number to (its digits in descending order) minus
(its digits in ascending order). For four-digit inputs with at least two distinct
digits, iterating this map converges, in at most seven steps, to the fixed point
$$6174 = \text{Kaprekar's constant},$$
which is the unique nonzero four-digit fixed point. This is a *dynamical* digit
monster: the interest is in the orbit structure rather than a single algebraic
identity (see C5, Section 8).

The unifying theme: each creature is defined by an easily stated digit condition,
yet the depth ranges from "settled by an elementary growth race" (narcissistic
finiteness) to "as hard as factoring" (vampire density).

---

## 8. Discussion and future directions

This cycle established a verified core: a corrected definition, the digit-power
bound, the crossover inequality, the finiteness theorem, decidability, and
certified specimens. We highlight a falsifiable research program.

**C1 — Sharp narcissistic bound (tighten $10^{60}\to 10^{39}$).** We proved
$\mathrm{Narc}(n)\Rightarrow n<10^{60}$. The true maximal narcissistic number is
the 39-digit $115132219018763992565095597973971522401$. *Conjecture:*
$\mathrm{Narc}(n)\Rightarrow n<10^{39}$, and this is sharp. *Approach:* strengthen
the crossover (Theorem 2) to the sharp index $d_0$ where $d\cdot 9^d$ first drops
below $10^{d-1}$ for all $d\ge d_0$, then certify the 39-digit champion and the
nonexistence of a 40-digit one by the length argument.

**C2 — Infinitude/finiteness dichotomy across families.** Harshad numbers are
infinite; narcissistic numbers are finite. *Conjecture:* a digit-family defined by
$n = \sum_i f(d_i)$ with $f$ **bounded** (independent of the digit count) is
infinite, while one whose weight **depends on the digit count** (like
narcissistic) is finite. *Approach:* formalize "digit-additive family with bounded
weights" and prove an infinitude theorem covering Harshad and digit-sum
fixed-point families in one stroke.

**C3 — Vampire density and the multiplicative/additive bridge.** Vampirism does
not imply the Harshad property. *Conjecture:* infinitely many vampires are Harshad
and infinitely many are not; moreover the proportion of vampires $\le N$ that are
Harshad tends to a constant strictly between $0$ and $1$. *First step:* exhibit an
explicit infinite family of vampires and decide the Harshad property along it.

**C4 — Prime-fang vampires.** Every vampire is composite. *Conjecture:* there are
infinitely many vampire numbers both of whose fangs are prime ("prime vampire
numbers", e.g. $117067 = 167\times 701$), and the smallest is $117067$. *Approach:*
extend the vampire predicate with a `fangsPrime` clause, certify $117067$, and
prove minimality over the relevant range by an executable bridge.

**C5 — Kaprekar fixed points and the 6174 vortex.** *Conjecture:* every four-digit
number with at least two distinct digits reaches $6174$ under iteration of the
Kaprekar map in at most $7$ steps, and $6174$ is the unique nonzero fixed point.
*Approach:* define the Kaprekar map as an executable function, prove $K(6174)=6174$
and uniqueness by exhaustive verification over four-digit inputs, then bound the
convergence time.

---

## 9. Conclusion

We have given a complete, verified account of the elementary theory of
narcissistic numbers. The conceptual core is a growth race: the digit-power sum of
a $d$-digit number cannot exceed $d\cdot 9^d$ (Theorem 1), while the number is at
least $10^{d-1}$, and $d\cdot 9^d<10^{d-1}$ for all $d\ge 61$ (Theorem 2). These
combine to bound every narcissistic number below $10^{60}$ (Theorem 3), proving
the species finite — a sharp contrast with the infinite Harshad numbers, and a
clean illustration of how a self-referential constraint can collapse an infinite
search into a finite one. Decidability (Theorem 4) and the certified specimens
$1,153,370,371,407$ (Theorem 5) round out a small but complete chapter of the
numerical bestiary, with a concrete path (C1) toward the sharp $10^{39}$ frontier.

---

## Appendix A. Summary of formal results

- **Lemma 1 / `foldr_pow_le`.** For a list $\ell$ of naturals each $\le 9$ and any
  exponent $E$: $S_E(\ell)\le |\ell|\cdot 9^E$.
- **Theorem 1 / `digit_pow_sum_le`.** $S_{L(n)}(\mathrm{digits}_{10}(n)) \le
  L(n)\cdot 9^{L(n)}$.
- **Theorem 2 / `key_ineq`.** For all $d\ge 61$: $d\cdot 9^d < 10^{d-1}$.
- **Theorem 3 / `narcissistic_bound`.** $\mathrm{Narc}(n)\Rightarrow n<10^{60}$.
- **Theorem 4 / decidability instance.** $\mathrm{Narc}$ is decidable.
- **Theorem 5 / `narcissistic_{1,153,370,371,407}`.** Each listed number is
  narcissistic.
