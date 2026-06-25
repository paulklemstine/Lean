# Structural Laws of the Abundancy Index: Multiplicativity and Divisibility Monotonicity

**Author:** Aristotle
**Date:** 2026-06-25
**Domain:** Applications (Number Theory)

## Abstract

The *abundancy index* of a positive integer $n$ is the rational number
$A(n) = \sigma(n)/n$, where $\sigma(n) = \sum_{d \mid n} d$ is the sum-of-divisors
function. It encodes the classical hierarchy of deficient, perfect, and abundant
numbers in a single quantity: $n$ is perfect precisely when $A(n) = 2$. We develop
the two foundational structural laws of this index and prove them as independent
results, deliberately avoiding the common circular development in which
multiplicativity and monotonicity are derived from one another.

The first law is **divisibility monotonicity**: if $d \mid n$ with $n > 0$ then
$A(d) \le A(n)$, and the inequality is strict when $d < n$. We prove it directly
from a *scaled embedding* of divisor sets — the map $e \mapsto e\cdot(n/d)$ injects
the divisors of $d$ into the divisors of $n$ — with no recourse to multiplicativity.
The second law is **multiplicativity over coprime factors**: if $\gcd(m,n)=1$ then
$A(mn) = A(m)\,A(n)$, which we obtain solely from the multiplicativity of $\sigma$
and a field identity. As corollaries we record that proper divisors of a perfect
number are strictly deficient and that no perfect number divides another
(incompressibility). We connect these laws to the classical theory: the
Euclid–Euler classification of even perfect numbers and the chain of lower bounds
(Sylvester, Nielsen) on the number of distinct prime factors of a hypothetical odd
perfect number.

---

## 1. Introduction

A perfect number is a positive integer equal to the sum of its proper divisors;
$6 = 1+2+3$ and $28 = 1+2+4+7+14$ are the first two. Equivalently, folding $n$ into
the divisor sum, $n$ is perfect iff $\sigma(n) = 2n$, where $\sigma$ is the sum of
*all* positive divisors. Normalizing by $n$ produces the **abundancy index**
$A(n) = \sigma(n)/n$, and the perfection condition becomes the strikingly simple
$A(n) = 2$.

The abundancy index organizes elementary number theory: $A(n)<2$, $=2$, $>2$
classify $n$ as deficient, perfect, abundant respectively. Its two governing
behaviors are monotonicity along the divisibility order and multiplicativity over
coprime factors. These two laws underpin essentially every quantitative statement
about perfect and abundant numbers, from Euclid's construction of even perfect
numbers to modern lower bounds on the prime factor count of odd perfect numbers.

A subtle methodological point motivates this paper. It is tempting to prove
multiplicativity using a monotonicity/embedding argument and monotonicity using
multiplicativity (via a coprime factorization $n = d \cdot (n/d)$ when convenient),
producing a circular development whose logical foundation is unsound. We avoid this
entirely: monotonicity is proved from a direct divisor-set embedding, and
multiplicativity from the multiplicativity of $\sigma$ together with a single field
identity. Each rests on disjoint inputs.

**Contributions.**
1. A direct, embedding-based proof of the scaled divisor-sum inequality
   $\sigma(d)\cdot(n/d)\le\sigma(n)$ (Lemma 3.1) and its strict form (Lemma 3.2),
   using no multiplicativity.
2. The cross-multiplied corollaries $\sigma(d)\,n \le \sigma(n)\,d$ (Cor. 3.3) and
   its strict version (Cor. 3.4).
3. Divisibility monotonicity of $A$ (Thm. 4.1) and its strict form (Thm. 4.2).
4. Multiplicativity of $A$ over coprime factors (Thm. 5.1), proved independently.
5. Structural corollaries for perfect numbers and a survey of the classical
   landscape (Euclid–Euler, Sylvester, Nielsen) these laws support.

---

## 2. Definitions

Throughout, $\sigma$ denotes the sum-of-divisors arithmetic function. We write it
as $\sigma_1$ when emphasizing it is the order-$1$ divisor-power sum; for a positive
integer $n$,
$$\sigma(n) \;=\; \sum_{d \mid n} d,$$
the sum ranging over the positive divisors of $n$ (including $1$ and $n$). It is a
standard fact that $\sigma$ is *multiplicative*: $\sigma(mn) = \sigma(m)\sigma(n)$
whenever $\gcd(m,n)=1$.

**Definition 2.1 (Abundancy index).** For $n \in \mathbb{N}$, the abundancy index is
$$A(n) \;=\; \frac{\sigma(n)}{n} \;\in\; \mathbb{Q}.$$
For $n = 0$ this evaluates to $0$ by the junk-value convention for division; all
substantive statements assume $n > 0$.

**Definition 2.2 (Perfect number).** A number $n$ is *perfect* when
$A(n) = 2$, equivalently $\sigma(n) = 2n$.

We call $n$ *deficient* if $A(n) < 2$ and *abundant* if $A(n) > 2$.

**Examples.** $A(6) = 12/6 = 2$ (perfect); $A(p) = (p+1)/p$ for any prime $p$
(deficient); $A(12) = 28/12 = 7/3 > 2$ (abundant, the smallest abundant number).

---

## 3. The core divisor-sum comparison

The technical heart of the monotonicity law is a comparison between $\sigma(d)$ and
$\sigma(n)$ obtained by embedding the divisor set of $d$ into that of $n$. No
multiplicativity is used.

**Lemma 3.1 (Scaled embedding of divisor sums).** *If $d \mid n$, then*
$$\sigma(d)\cdot\frac{n}{d} \;\le\; \sigma(n).$$

*Proof sketch.* If $n = 0$ both sides are $0$. Otherwise $d > 0$; set $q = n/d$, so
$dq = n$ and $q \ge 1$. Consider the map $\varphi : e \mapsto e\cdot q$ on the
divisors of $d$. It is injective (cancel $q \ne 0$), and it lands in the divisors of
$n$: if $e \mid d$ then $eq \mid dq = n$. Therefore the image $\varphi(\mathrm{div}(d))$
is a subset of $\mathrm{div}(n)$. Summing nonnegative terms over a subset is bounded
by the full sum:
$$\sigma(d)\cdot q = \sum_{e \mid d} e\cdot q = \sum_{x \in \varphi(\mathrm{div}(d))} x
\;\le\; \sum_{x \mid n} x = \sigma(n).$$
The first equality factors $q$ out of the sum; the second is the injective
reindexing along $\varphi$; the inequality is monotonicity of sums of nonnegative
terms under set inclusion. $\qquad\blacksquare$

**Lemma 3.2 (Strict scaled embedding).** *If $d \mid n$ and $d < n$, then*
$$\sigma(d)\cdot\frac{n}{d} \;<\; \sigma(n).$$

*Proof sketch.* With $q = n/d$, the hypothesis $d < n$ forces $q \ge 2$. The
divisor $1 \in \mathrm{div}(n)$ is *not* in the image $\varphi(\mathrm{div}(d))$:
any preimage $e$ would satisfy $e\cdot q = 1$ with $e \ge 1$ and $q \ge 2$, which is
impossible. Thus the image is a *proper* subset of $\mathrm{div}(n)$ that omits a
strictly positive term ($1 > 0$), while all remaining terms of $\sigma(n)$ are
nonnegative. The strict-subset sum inequality then gives
$\sigma(d)\cdot q < \sigma(n)$. $\qquad\blacksquare$

Cross-multiplying clears the division and yields the forms used downstream.

**Corollary 3.3 (Cross-multiplied comparison).** *If $d \mid n$ then*
$\sigma(d)\,n \le \sigma(n)\,d.$

*Proof.* Multiply Lemma 3.1 by $d$ and use $(n/d)\cdot d = n$:
$\sigma(d)\,n = \sigma(d)\cdot(n/d)\cdot d \le \sigma(n)\cdot d.$ $\qquad\blacksquare$

**Corollary 3.4 (Strict cross-multiplied comparison).** *If $d \mid n$ and $d < n$
then* $\sigma(d)\,n < \sigma(n)\,d.$

*Proof.* As in Cor. 3.3, multiplying the strict Lemma 3.2 by $d > 0$. $\qquad\blacksquare$

---

## 4. Divisibility monotonicity of the abundancy index

**Theorem 4.1 (Divisibility monotonicity).** *If $d \mid n$ and $n > 0$, then*
$$A(d) \le A(n).$$

*Proof sketch.* Both $d, n > 0$. By definition the claim $\sigma(d)/d \le \sigma(n)/n$
is, after clearing the positive denominators $d$ and $n$, exactly
$\sigma(d)\,n \le \sigma(n)\,d$, which is Corollary 3.3. $\qquad\blacksquare$

**Theorem 4.2 (Strict divisibility monotonicity).** *If $d \mid n$ and $d < n$, then*
$$A(d) < A(n).$$

*Proof sketch.* From $d < n$ we get $n > 0$ and $d > 0$; clearing denominators
reduces the claim to $\sigma(d)\,n < \sigma(n)\,d$, which is Corollary 3.4.
$\qquad\blacksquare$

**Corollary 4.3 (Proper divisors of a perfect number are deficient).** *If $n$ is
perfect and $d$ is a proper divisor of $n$ (so $d \mid n$, $d < n$), then
$A(d) < 2$; i.e. $d$ is strictly deficient.*

*Proof.* Theorem 4.2 gives $A(d) < A(n) = 2$. $\qquad\blacksquare$

**Corollary 4.4 (Incompressibility of perfect numbers).** *No perfect number is a
proper divisor of another perfect number. More generally, if $n$ is perfect and
$n \mid m$ with $n < m$, then $m$ is abundant ($A(m) > 2$), so in particular $m$ is
not perfect.*

*Proof.* Theorem 4.2 gives $A(m) > A(n) = 2$. $\qquad\blacksquare$

---

## 5. Multiplicativity of the abundancy index

**Theorem 5.1 (Multiplicativity over coprime factors).** *If $\gcd(m, n) = 1$, then*
$$A(mn) = A(m)\,A(n).$$

*Proof sketch.* The sum-of-divisors function $\sigma$ is multiplicative, so
$\sigma(mn) = \sigma(m)\,\sigma(n)$ for coprime $m, n$. Then
$$A(mn) = \frac{\sigma(mn)}{mn} = \frac{\sigma(m)\,\sigma(n)}{m\,n}
       = \frac{\sigma(m)}{m}\cdot\frac{\sigma(n)}{n} = A(m)\,A(n),$$
the middle equality being the field identity
$\frac{ac}{bd} = \frac ab\cdot\frac cd$. This argument uses *only* the
multiplicativity of $\sigma$ and the algebra of fractions — never the embedding or
monotonicity results of §3–§4, keeping the two pillars independent. $\qquad\blacksquare$

**Remark 5.2 (Breaking the circular dependency).** A frequent but unsound
development proves multiplicativity by a monotone-embedding argument and proves
monotonicity by appealing to multiplicativity through the factorization
$n = d\cdot(n/d)$ (which need not be coprime). The construction above is acyclic:
Lemma 3.1/3.2 use injective reindexing of divisor sets; Theorem 5.1 uses
$\sigma$'s multiplicativity. Neither result invokes the other.

---

## 5b. Worked examples

It is instructive to trace the laws on concrete numbers.

**Monotonicity on a perfect number.** Take $n = 28 = 2^2\cdot 7$, which is perfect:
$\sigma(28) = 1+2+4+7+14+28 = 56 = 2\cdot 28$, so $A(28) = 2$. Its proper divisors
are $1, 2, 4, 7, 14$, with abundancy indices
$$A(1)=1,\quad A(2)=\tfrac32,\quad A(4)=\tfrac74,\quad A(7)=\tfrac87,\quad A(14)=\tfrac{12}{7}.$$
Every one is strictly below $2$, exactly as Theorem 4.2 (and its Corollary 4.3)
predicts: each proper divisor of a perfect number is strictly deficient. The
underlying integer certificate of Corollary 3.3 also holds throughout; e.g. for
$d=14$, $\sigma(14)\cdot 28 = 24\cdot 28 = 672$ and $\sigma(28)\cdot 14 = 56\cdot 14
= 784$, and indeed $672 < 784$.

**Multiplicativity, success and failure.** For the coprime pair $m = 4 = 2^2$,
$n = 3$ we have $A(4) = \tfrac74$, $A(3) = \tfrac43$, and
$A(12) = \tfrac{28}{12} = \tfrac73 = \tfrac74\cdot\tfrac43$, confirming Theorem 5.1.
The hypothesis $\gcd(m,n)=1$ is essential: for the *non*-coprime pair $m=4$,
$n=6$ (sharing the factor $2$), $A(24) = \tfrac{60}{24} = \tfrac52$, whereas
$A(4)\cdot A(6) = \tfrac74\cdot 2 = \tfrac72 \ne \tfrac52$. Multiplicativity genuinely
requires coprimality.

**A near miss: the smallest odd abundant number.** Consider $n = 945 = 3^3\cdot 5
\cdot 7$, the smallest odd abundant number. The product law gives
$$A(945) = A(3^3)\,A(5)\,A(7) = \tfrac{40}{27}\cdot\tfrac65\cdot\tfrac87 = \tfrac{128}{63}
\approx 2.032 > 2,$$
so $945$ is abundant but not perfect; and indeed $A(945) < \tfrac{3}{2}\cdot
\tfrac{5}{4}\cdot\tfrac{7}{6} = \tfrac{35}{16} \approx 2.19$, the Euler-product bound of
\S6. This illustrates how the small odd primes $3, 5, 7$ can *exceed* $2$ only when
backed by a sufficiently high power (here $3^3$), foreshadowing why odd perfect
numbers — if any — must marshal many primes with carefully tuned exponents.

---

## 6. The prime-power calculus and its consequences

Multiplicativity over coprime factors reduces every abundancy computation to prime
powers, because the prime-power blocks $p_i^{a_i}$ of a factorization
$n = \prod_i p_i^{a_i}$ are pairwise coprime. Iterating Theorem 5.1 gives
$$A(n) = \prod_{i} A\!\left(p_i^{a_i}\right).$$

For a single prime power, summing the geometric divisor series $1,p,\dots,p^a$ yields
the closed form
$$A(p^a) = \frac{1 + p + \cdots + p^a}{p^a} = \frac{p^{a+1}-1}{p^a(p-1)}
        = \frac{p}{p-1}\left(1 - p^{-(a+1)}\right) < \frac{p}{p-1}.$$

Thus each prime $p$ contributes a *bounded* multiplicative factor strictly less than
$p/(p-1)$, and combining over the prime support gives the Euler-product bound
$$A(n) < \prod_{p \mid n} \frac{p}{p-1}.$$

This single estimate explains the qualitative behavior of perfect numbers:

- The leverage of a prime $p$ decays as $p/(p-1)\to 1$; large primes barely raise
  the index. Reaching $A(n)=2$ requires the *participation of small primes*.
- For an **even** perfect number the prime $2$ supplies most of the abundancy, and
  the cancellation against a single Mersenne factor lands the index exactly on $2$
  (see §7).
- For a hypothetical **odd** perfect number, $2$ is unavailable. Since
  $\frac32\cdot\frac54 = \frac{15}{8} < 2$, two odd primes can never reach $2$;
  this is the seed of Sylvester's three-prime lower bound and, after a great deal
  of refinement, of the modern hundred-plus-prime bounds.

While the closed form $A(p^a)$ and the product bound are immediate consequences of
Theorem 5.1, they are stated here as the natural calculus the two laws unlock,
rather than as separately formalized theorems.

---

## 7. The classical landscape

### 7.1 Euclid–Euler classification of even perfect numbers

A **Mersenne prime** is a prime of the form $2^p - 1$. Euclid (Elements, Book IX)
showed that if $2^p - 1$ is prime then $N = 2^{p-1}(2^p - 1)$ is perfect. Through
the abundancy index this is transparent: $2^{p-1}$ and the odd prime $2^p-1$ are
coprime, so by Theorem 5.1,
$$A(N) = A(2^{p-1})\,A(2^p-1)
      = \frac{2^p - 1}{2^{p-1}}\cdot\frac{2^p}{2^p - 1} = 2.$$
Euler proved the converse: every even perfect number has this form. Hence the even
perfect numbers correspond bijectively to the Mersenne primes (the **Euclid–Euler
theorem**). The known cases begin $p=2 \mapsto 6$, $p=3 \mapsto 28$,
$p=5 \mapsto 496$, $p=7 \mapsto 8128$.

### 7.2 Odd perfect numbers and prime-factor lower bounds

No odd perfect number is known, and none is known not to exist. The abundancy
calculus drives the partial results bounding their structure. Counting distinct
prime factors:

- **Sylvester (1888):** an odd perfect number has at least $3$ distinct prime
  factors — a direct consequence of $\prod_{p}\frac{p}{p-1} < 2$ for fewer primes.
- **Nielsen (2015):** an odd perfect number has at least $101$ distinct prime
  factors.

Each bound is an accounting of how much abundancy a fixed prime support can
manufacture under the product law of §6. These results are stated here as context;
they are not among the formalized theorems of this work.

---

## 8. Algorithms

The structural laws are directly computational. We summarize the core routines
(full Python with type hints accompanies this paper).

**Algorithm A — Abundancy via prime-power product.** Factor $n$, compute each
$A(p^a) = (p^{a+1}-1)/(p^a(p-1))$ exactly in $\mathbb{Q}$, and multiply (Theorem 5.1
and §6). Complexity is dominated by factorization; the product step is $O(\omega(n))$
rational multiplications where $\omega(n)$ is the number of distinct primes.

**Algorithm B — Abundancy via direct divisor sum.** Compute $\sigma(n)$ by summing
divisors found in $O(\sqrt n)$ trial divisions, then form $\sigma(n)/n$ exactly. Used
as an independent cross-check of Algorithm A.

**Algorithm C — Monotonicity / incompressibility certifier.** Given $d \mid n$,
verify $A(d) \le A(n)$ (strict if $d<n$) by checking the integer inequality
$\sigma(d)\,n \le \sigma(n)\,d$ (Corollaries 3.3–3.4), avoiding rationals entirely.

**Algorithm D — Even perfect number generator.** For each prime $p$ with $2^p-1$
prime, emit $2^{p-1}(2^p-1)$ and confirm $A = 2$ (§7.1).

---

## 9. Applications

- **Classification of numbers.** $A(n)$ vs $2$ is the canonical deficient/perfect/
  abundant test, foundational in elementary number theory.
- **Search heuristics.** Monotonicity (Thm. 4.1) prunes divisor lattices in perfect-
  and abundant-number searches: once a divisor crosses an abundancy threshold, all
  its multiples inherit at least that abundancy.
- **Structural constraints on odd perfect numbers.** The product law of §6 is the
  workhorse behind every prime-factor lower bound (§7.2).
- **Exact rational arithmetic.** The cross-multiplied integer forms (Cor. 3.3–3.4)
  let monotonicity be certified with integer comparisons only — useful for verified
  computation.

---

## 9b. Related notions and historical remarks

The abundancy index sits at the head of a family of arithmetic measures. The
*deficiency* $2n - \sigma(n)$ and *abundance* $\sigma(n) - 2n$ are the additive
analogues of $A(n) - 2$; the *ratio* formulation $A(n) = \sigma(n)/n$ is the
multiplicatively natural one because of Theorem 5.1. Numbers sharing a common
abundancy index are called *friendly* (and a number sharing its index with no other
is *solitary*); the index $A(n) = 2$ singles out the perfect numbers, while indices
of the form $A(n) = k$ for integer $k > 2$ define the *multiperfect* numbers, whose
study is governed by the same product law of \S6.

Historically, the four perfect numbers $6, 28, 496, 8128$ were known to the Greeks;
Nicomachus (c. 100 CE) recorded conjectures — later seen to be false in their strong
forms — about their regularity. Euclid's construction (Elements IX.36) is the
forward direction of \S7.1; Euler's converse, proved nearly two millennia later,
completed the even case. The odd case remains open: extensive computation has shown
that any odd perfect number must exceed $10^{1500}$, must have a prime factor
exceeding $10^8$, and — by Nielsen's bound — must have at least $101$ distinct
prime factors. Every one of these constraints is, at root, an inequality about how
much the product $\prod_{p \mid n} p/(p-1)$ can accumulate, which is precisely the
quantity the multiplicativity law of this paper makes computable.

---

## 10. Discussion

The deliberate independence of the two laws is the methodological point. By proving
monotonicity through a concrete injective embedding of divisor sets and
multiplicativity through $\sigma$'s own multiplicativity, we obtain a foundation in
which neither result silently depends on the other. The embedding proof is also
notably elementary: it reasons about *finite sets of divisors and sums of
nonnegative terms*, never invoking analytic estimates or generating functions, and
the strictness criterion ("the divisor $1$ is missing from the image when the
stretch factor exceeds $1$") is a vivid combinatorial witness.

---

## 11. Future Directions

1. **Strengthen the prime-factor fragment from 2 to 3 distinct primes (Sylvester).**
   Using multiplicativity and the per-prime bound $A(p^k) < p/(p-1)$, a two-odd-prime
   number has abundancy $\le \frac32\cdot\frac54 = \frac{15}{8} < 2$, so it cannot be
   perfect; only the geometric per-prime bound and a small product inequality remain.

2. **A general "abundancy product bound" engine.** Formalize
   $A(n) = \prod_i \frac{p_i}{p_i-1}\bigl(1 - p_i^{-(a_i+1)}\bigr) < \prod_i \frac{p_i}{p_i-1}$
   by telescoping each prime-power geometric series into an Euler product, reducing
   every abundancy question to $\prod_{p}\frac{p}{p-1}$ over the prime support.

3. **Mersenne-prime exponents are prime.** If $2^m-1$ is prime and $m>1$ then $m$ is
   prime, via $2^{ab}-1 = (2^a-1)(1+2^a+\cdots+2^{a(b-1)})$; this sharpens the
   indexing of even perfect numbers.

4. **Euler's form for odd perfect numbers.** Every odd perfect number is
   $q^e m^2$ with $q$ prime and $q \equiv e \equiv 1 \pmod 4$, $\gcd(q,m)=1$, via a
   parity analysis of $\sigma$.

5. **Incompressibility as a chain theorem.** Strict monotonicity extends to chains
   $a \mid b \mid c$ with strict abundancy increases, formalizing "perfect numbers
   are incompressible."

---

## 12. Conclusion

The abundancy index $A(n) = \sigma(n)/n$ recasts the millennia-old notion of a
perfect number as the level set $A(n) = 2$. Its two governing laws — divisibility
monotonicity (Theorems 4.1, 4.2) and coprime multiplicativity (Theorem 5.1),
underpinned by the scaled divisor-set embedding (Lemmas 3.1, 3.2) — are proved here
on independent foundations. Together they yield the prime-power calculus that
explains the Euclid–Euler classification of even perfect numbers and constrains the
elusive odd ones.
