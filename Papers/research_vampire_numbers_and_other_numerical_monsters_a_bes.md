# A Verified Finiteness Theorem for Narcissistic Numbers

### A case study in the digit-combinatorial bestiary (Bridges domain)

## Abstract

A natural number is *narcissistic* (or an *Armstrong number*) if it equals the
sum of its own base-ten digits, each raised to the power equal to the total
number of digits. The smallest nontrivial examples are the four three-digit
specimens $153, 370, 371, 407$. We present a self-contained development of the
theory of narcissistic numbers culminating in a fully rigorous **finiteness
theorem**: every narcissistic number is strictly less than $10^{60}$, so the
species is finite. The proof rests on an explicit exponential separation between
two quantities attached to a $d$-digit number — the structural lower bound
$10^{d-1}$ on its magnitude, and the combinatorial upper bound $d \cdot 9^d$ on
its digit-power sum — together with the elementary inequality $d \cdot 9^d <
10^{d-1}$ valid for all $d \ge 61$. We give the definitions, the chain of lemmas,
proof sketches faithful to a machine-checked formalization, an executable
decision procedure, named verified specimens, and a discussion situating
narcissistic numbers within the broader bestiary of digit-combinatorial
"monsters" (vampire, ghost, and zombie numbers). We close with sharpenings and
conjectures, including the tightening of the bound from $10^{60}$ to the sharp
$10^{39}$.

**Keywords:** narcissistic numbers, Armstrong numbers, digit functions, base-ten
representation, finiteness, recreational number theory, digit combinatorics.

---

## 1. Introduction

Recreational number theory is populated by a menagerie of objects defined not by
the multiplicative or additive structure of integers but by the *symbols* used to
write them. We call these objects **digit-combinatorial**, and informally,
**numerical monsters**. Examples include:

- **Vampire numbers**: an even-digit number $v$ factoring as $v = xy$ where the
  digits of $x$ and $y$ together are a permutation of the digits of $v$ (smallest:
  $1260 = 21 \times 60$).
- **Ghost numbers**: products $v = xy$ where $v$ shares no digit with $x$ or $y$.
- **Zombie numbers**: numbers admitting multiple factorizations of conflicting
  character (e.g. mixing prime and composite fangs).
- **Narcissistic (Armstrong) numbers**: the subject of this paper.

These objects share a hallmark: they are trivial to *state* and frequently
difficult to *analyze*, because they couple the additive world (digit sums and
digit permutations) to the multiplicative world (factorizations). Several, such as
the vampire numbers, appear to be as computationally hard as integer
factorization itself.

Against this backdrop the narcissistic numbers are exceptional: they admit a
*complete* qualitative analysis. We prove that, unlike the primes, the squares, or
the Harshad numbers — all infinite — the narcissistic numbers form a **finite**
set. This paper presents that result with all definitions and proof sketches
self-contained, mirroring a formal, machine-verified development.

### 1.1 Summary of contributions

1. A precise definition of narcissism via a `foldr` over the base-ten digit list
   (Section 2), with a discussion of a subtle pitfall in dot-notation that would
   silently corrupt the definition.
2. A combinatorial upper bound: the digit-power sum of a $d$-digit number is at
   most $d \cdot 9^d$ (Theorem 3.2), via a list-level lemma (Lemma 3.1).
3. An arithmetic separation: $d \cdot 9^d < 10^{d-1}$ for all $d \ge 61$
   (Theorem 3.3).
4. The main finiteness theorem: every narcissistic number is $< 10^{60}$
   (Theorem 3.4).
5. Decidability of narcissism (Theorem 3.5) and five verified specimens
   (Section 4).
6. Contextualization within the monster bestiary and a slate of conjectures
   (Sections 5–6).

---

## 2. Definitions

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$, and all digits are taken in base
ten.

**Definition 2.1 (Digit list).** For $n \in \mathbb{N}$ let $\mathrm{digits}(n)$
denote the list of base-ten digits of $n$, least-significant first. Thus
$\mathrm{digits}(407) = [7, 0, 4]$, $\mathrm{digits}(0) = [\,]$, and the length
$|\mathrm{digits}(n)|$ is the usual number of decimal digits of $n$ (with
$|\mathrm{digits}(0)| = 0$). Two standard facts are used: every entry $a$ of
$\mathrm{digits}(n)$ satisfies $a \le 9$ (each base-ten digit is at most nine),
and for $n \ge 1$, $|\mathrm{digits}(n)| = \lfloor \log_{10} n \rfloor + 1$.

**Definition 2.2 (Narcissistic number).** Let $d = |\mathrm{digits}(n)|$. The
number $n$ is **narcissistic** if

$$
n \;=\; \sum_{a \in \mathrm{digits}(n)} a^{\,d}.
$$

Concretely, writing the digits as $a_1, \dots, a_d$, this is
$n = a_1^d + a_2^d + \cdots + a_d^d$. Operationally we realize the right-hand
side as a right fold:

$$
S(n) \;:=\; \mathrm{foldr}\,\bigl(\lambda\, a\; \mathrm{acc}.\; \mathrm{acc} + a^{\,d}\bigr)\; 0 \;\;\mathrm{digits}(n), \qquad d = |\mathrm{digits}(n)|,
$$

and define $n$ narcissistic $\iff n = S(n)$.

**Remark 2.3 (A definitional pitfall).** In a dependently-typed setting using
dot-notation, the expression `n.digits 10` is parsed as `digits n 10` — the
base-$n$ digits of the *constant* $10$ — rather than the base-$10$ digits of $n$.
Under that misreading, the proposition "$153$ is narcissistic" degenerates to
$153 = 10$, which is false; every intended specimen would fail. The mathematically
correct object is `digits 10 n`, the base-ten digits of $n$, and we use that
throughout. We flag this because such silent argument-order errors are a recurring
hazard in formalizing digit-based definitions.

---

## 3. Main results

We work toward the finiteness theorem through a chain of three lemmas. The
strategy is a *separation of growth rates*: a $d$-digit narcissistic number must
be both large (because it has $d$ digits) and small (because its digit-power sum
is capped), and these two constraints become contradictory once $d$ is large.

### 3.1 The combinatorial ceiling

**Lemma 3.1 (List power-sum bound).** Let $\ell$ be a finite list of natural
numbers with every entry $\le 9$, and let $E \in \mathbb{N}$. Then

$$
\mathrm{foldr}\,\bigl(\lambda\, a\; \mathrm{acc}.\; \mathrm{acc} + a^{E}\bigr)\; 0\; \ell \;\le\; |\ell| \cdot 9^{E}.
$$

*Proof sketch.* Induct on $\ell$. The empty list gives $0 \le 0$. For a cons
$a :: \ell'$ with hypothesis that all entries are $\le 9$, the fold value is
$a^E + (\text{fold of } \ell')$. By monotonicity of $x \mapsto x^E$, we have
$a^E \le 9^E$; by the inductive hypothesis the fold of $\ell'$ is at most
$|\ell'| \cdot 9^E$. Adding, the total is at most $9^E + |\ell'| \cdot 9^E =
(|\ell'|+1)\cdot 9^E = |\ell| \cdot 9^E$, using $(\,k+1\,)\cdot 9^E = 9^E + k \cdot
9^E$. $\qquad\blacksquare$

**Theorem 3.2 (Digit-power ceiling).** For every $n \in \mathbb{N}$ with $d =
|\mathrm{digits}(n)|$,

$$
S(n) \;=\; \sum_{a \in \mathrm{digits}(n)} a^{\,d} \;\le\; d \cdot 9^{\,d}.
$$

*Proof sketch.* Apply Lemma 3.1 to $\ell = \mathrm{digits}(n)$ with exponent
$E = d = |\mathrm{digits}(n)|$. The hypothesis "every entry $\le 9$" is exactly the
standard fact that each base-ten digit is at most nine. The list length is $d$ by
definition, so the bound $|\ell|\cdot 9^E$ reads $d \cdot 9^d$. $\qquad\blacksquare$

### 3.2 The arithmetic separation

**Theorem 3.3 (Exponential crossover).** For every integer $d \ge 61$,

$$
d \cdot 9^{\,d} \;<\; 10^{\,d-1}.
$$

*Proof sketch.* Induct on $d$ starting at the base case $d = 61$. At $d = 61$ the
inequality $61 \cdot 9^{61} < 10^{60}$ holds by direct numeric comparison (taking
logarithms, $\log_{10}(61 \cdot 9^{61}) = \log_{10} 61 + 61\log_{10} 9 \approx
1.785 + 58.20 = 59.99 < 60$). For the inductive step, assume $d \cdot 9^d <
10^{d-1}$ and prove $(d+1)\cdot 9^{d+1} < 10^{d}$. Write $9^{d+1} = 9 \cdot 9^d$
and $10^d = 10 \cdot 10^{d-1}$. Then
$$
(d+1)\cdot 9^{d+1} = 9(d+1)\cdot 9^d \le 9 \cdot \tfrac{d+1}{d}\, \bigl(d \cdot 9^d\bigr) < 9 \cdot \tfrac{d+1}{d}\, 10^{d-1}.
$$
Since $d \ge 61$ we have $\tfrac{d+1}{d} \le \tfrac{62}{61} < \tfrac{10}{9}$, hence
$9 \cdot \tfrac{d+1}{d} < 10$, giving $(d+1)\cdot 9^{d+1} < 10 \cdot 10^{d-1} =
10^{d}$. (The formal proof discharges the base case and the multiplicative step by
normalization and a single nonlinear arithmetic call, using positivity of $9^d$.)
$\qquad\blacksquare$

**Remark 3.4.** The threshold $61$ is convenient, not optimal. The true crossover
where $10^{d-1}$ first dominates $d \cdot 9^d$ occurs at a smaller $d$; the sharp
analysis underlies the conjecture that the bound can be improved to $10^{39}$
(Section 6, C1).

### 3.3 The finiteness theorem

**Theorem 3.5 (Finiteness of narcissistic numbers).** Every narcissistic number
is strictly less than $10^{60}$. Consequently the set of narcissistic numbers is
finite.

*Proof sketch.* Suppose, for contradiction, that $n$ is narcissistic and
$n \ge 10^{60}$. Let $d = |\mathrm{digits}(n)|$.

*Lower bound on $d$.* From $n \ge 10^{60}$ and the identity $d = \lfloor \log_{10}
n \rfloor + 1$ we obtain $\log_{10} n \ge 60$, hence $\lfloor \log_{10} n \rfloor
\ge 60$ and $d \ge 61$.

*The squeeze.* Because $n$ has $d$ digits, $n \ge 10^{d-1}$ (the smallest
$d$-digit number). On the other hand, narcissism gives $n = S(n)$, and Theorem 3.2
gives $S(n) \le d \cdot 9^d$; Theorem 3.3 (applicable since $d \ge 61$) gives
$d \cdot 9^d < 10^{d-1}$. Chaining,
$$
n = S(n) \le d \cdot 9^d < 10^{d-1} \le n,
$$
i.e. $n < n$, a contradiction. Hence no narcissistic $n \ge 10^{60}$ exists, so
every narcissistic number is $< 10^{60}$. Since there are only finitely many
naturals below $10^{60}$, the set of narcissistic numbers is finite.
$\qquad\blacksquare$

### 3.4 Decidability and computation

**Theorem 3.6 (Decidability).** The predicate "$n$ is narcissistic" is decidable.

*Proof sketch.* Unfolding the definition, narcissism is the equality of two
explicitly computable natural numbers, $n$ and $S(n)$. Equality of naturals is
decidable, so the predicate inherits a decision procedure by structural
unfolding. $\qquad\blacksquare$

Theorems 3.5 and 3.6 together yield, in principle, an *algorithm that enumerates
the complete list of narcissistic numbers*: the finiteness bound restricts the
search to $n < 10^{60}$, and decidability tests each candidate. In practice one
prunes the search by digit length (Section 5).

---

## 4. Verified specimens

The decision procedure of Theorem 3.6 lets us certify individual specimens by
direct evaluation. The following are established by computation:

| $n$ | $d$ | digit-power sum | narcissistic? |
|----:|:---:|:---------------:|:-------------:|
| $1$ | $1$ | $1^1 = 1$ | yes |
| $153$ | $3$ | $1^3+5^3+3^3 = 1+125+27 = 153$ | yes |
| $370$ | $3$ | $3^3+7^3+0^3 = 27+343+0 = 370$ | yes |
| $371$ | $3$ | $3^3+7^3+1^3 = 27+343+1 = 371$ | yes |
| $407$ | $3$ | $4^3+0^3+7^3 = 64+0+343 = 407$ | yes |

These five — the unit $1$ and the complete roster of three-digit narcissistic
numbers — serve as the named, verified specimens of the species. (The four
three-digit values $153, 370, 371, 407$ are exhaustive: no other three-digit
number satisfies the cube-sum identity.)

---

## 5. Algorithms

### 5.1 Length-stratified enumeration

The naive approach — test every $n < 10^{60}$ — is astronomically infeasible
($10^{60}$ candidates). The decisive observation is that the *exponent* in the
narcissistic identity is fixed once the digit-length $d$ is fixed. Within a fixed
length, narcissism depends only on the *multiset* of digits, not their order,
because the digit-power sum $\sum a_i^d$ is symmetric. Hence:

> For each length $d$ from $1$ up to $60$, enumerate **multisets** of $d$ digits
> (combinations with repetition from $\{0,\dots,9\}$), compute the digit-power sum
> $T$, and accept $T$ iff $T$ has exactly $d$ digits *and* the multiset of digits
> of $T$ equals the chosen multiset.

The number of $d$-digit multisets is $\binom{d+9}{9}$, vastly smaller than $10^d$.
This is the standard route by which the full list of 88 base-ten narcissistic
numbers (largest: the 39-digit $115132219018763992565095597973971522401$) is
obtained.

### 5.2 Direct membership test

For a single candidate, Theorem 3.6's procedure is immediate: extract digits,
raise each to the power equal to the digit count, sum, and compare to $n$. This
runs in time polynomial in the number of digits (a handful of big-integer
exponentiations).

---

## 6. Discussion and future directions

### 6.1 Place in the bestiary

The narcissistic numbers are the *tamed* monster: a digit-combinatorial species
whose qualitative theory is settled. The key enabling feature is that narcissism
is **purely additive in the digits** with a length-dependent exponent, which makes
the growth-rate race of Section 3 decisive. By contrast, vampire numbers entangle
digit permutations with *factorization* ($v = xy$ with combined digits matching),
placing them near the difficulty of integer factoring; ghost and zombie numbers
inherit similar multiplicative entanglement. The narcissistic finiteness theorem
is thus a proof of concept: it shows that at least one member of the bestiary can
be captured completely and rigorously, and it isolates *why* (additivity + a
beating of $9^d$ by $10^{d}$).

### 6.2 Conjectures and next steps

**C1 (Sharp finiteness bound, $60 \to 39$).** We proved narcissistic $\Rightarrow
n < 10^{60}$. The true maximal narcissistic number is the 39-digit
$115132219018763992565095597973971522401$. *Conjecture:* narcissistic $\Rightarrow
n < 10^{39}$, and this is sharp. *Path:* strengthen the crossover (Theorem 3.3) to
its true threshold and certify both that the 39-digit champion is narcissistic and
that the length argument rules out 40+ digits.

**C2 (Infinitude/finiteness dichotomy).** Harshad numbers (those divisible by
their digit sum) are infinite — every power of ten qualifies — whereas
narcissistic numbers are finite. *Conjecture:* a digit-family defined by
$n = \sum f(a_i)$ with $f$ *bounded independently of digit count* is infinite,
while one whose weighting depends on the digit count (as narcissism does, via the
exponent $d$) is finite. A single theorem should cover Harshad and digit-sum
fixed-point families.

**C3 (Multiplicative/additive bridge).** Vampirism does not imply the Harshad
property. *Conjecture:* infinitely many vampire numbers are Harshad and infinitely
many are not, with the proportion of Harshad vampires below $N$ tending to a
constant strictly between $0$ and $1$. *First step:* exhibit an explicit infinite
family of vampires and decide Harshad along it.

**C4 (Prime-fang vampires).** Every vampire is composite. *Conjecture:* there are
infinitely many vampire numbers both of whose fangs are prime ("prime vampires",
e.g. $117067 = 167 \times 701$), with smallest member $117067$.

**C5 (Kaprekar routine and the 6174 vortex).** Beyond Kaprekar *numbers* lies the
Kaprekar *routine* $K(n) = (\text{digits descending}) - (\text{digits ascending})$.
*Conjecture:* every 4-digit number with at least two distinct digits reaches the
fixed point $6174$ within $7$ iterations of $K$, and $6174$ is its unique nonzero
fixed point.

### 6.3 Conclusion

We have given a self-contained, rigorously sketched proof that the narcissistic
numbers form a finite set bounded by $10^{60}$, together with decidability and a
roster of verified specimens. The argument is elementary but not trivial: it turns
on an exponential separation, $d \cdot 9^d < 10^{d-1}$ for $d \ge 61$, between the
combinatorial ceiling on digit-power sums and the structural floor on $d$-digit
magnitudes. Beyond the specific result, the development models a methodology for
the entire bestiary of numerical monsters: state the digit-combinatorial rule
precisely, isolate the additive versus multiplicative content, and let growth
rates decide. For the narcissists, growth rates decide finiteness — the vainest of
numbers turn out to be a mortal species.

---

## Appendix A. Notation

- $\mathrm{digits}(n)$ — base-ten digit list of $n$, least-significant first.
- $d = |\mathrm{digits}(n)|$ — number of decimal digits of $n$.
- $S(n) = \sum_{a \in \mathrm{digits}(n)} a^{\,d}$ — digit-power sum.
- $\lfloor x \rfloor$ — floor; $\log_{10}$ — base-ten logarithm.

## Appendix B. The logical skeleton

$$
\underbrace{n \ge 10^{60}}_{\text{assume}} \;\Rightarrow\; d \ge 61
\;\Rightarrow\;
\underbrace{n = S(n) \le d\cdot 9^d}_{\text{Thm 3.2}} \;<\; \underbrace{10^{d-1}}_{\text{Thm 3.3}} \;\le\; \underbrace{n}_{d\text{-digit floor}}
\;\Rightarrow\; n < n \;\Rightarrow\; \bot.
$$
