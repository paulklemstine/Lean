# Doubling Invariance and Exact Cusick Densities for Powers of Two

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Applications (Combinatorial Number Theory)

## Abstract

Let $s_2(n)$ denote the binary sum-of-digits function, equal to the number of
`1`s in the binary expansion of $n$. Cusick's conjecture concerns the asymptotic
density

$$c_t = \lim_{N \to \infty} \frac{1}{N}\,\#\{\, 0 \le n < N : s_2(n+t) \ge s_2(n)\,\},$$

and asserts that $c_t > 1/2$ for every shift $t \ge 1$, with a conjectured
explicit lower bound $c_t \ge \tfrac{1}{2} + 2^{-(2 s_2(t)+1)}$. We isolate a
structural mechanism — a **doubling invariance** of the Cusick predicate — and
use it to compute an entire infinite family of densities exactly. Our main
results are: (i) the digit-sum recursions $s_2(2n) = s_2(n)$ and
$s_2(2n+1) = s_2(n)+1$; (ii) the parity-fibred doubling invariance, which states
that the Cusick predicate at $(2n, 2t)$ and $(2n+1, 2t)$ both reduce to the
predicate at $(n,t)$; (iii) the resulting self-similarity of the finite counting
function, $\text{cusickCount}(2t, 2N) = 2\cdot\text{cusickCount}(t, N)$; (iv) a
pointwise criterion $s_2(n) \le s_2(n+2^k) \Leftrightarrow \lfloor n/2^k\rfloor
\bmod 4 \ne 3$; and (v) the exact block identity
$\text{cusickCount}(2^k, 2^{k+2} m) = 3 \cdot 2^k \cdot m$, yielding
$c_{2^k} = 3/4$ for every $k$, a bias of $1/4$ strictly exceeding the conjectured
bound $1/2 + 1/8$. All results are supported by an underlying carry-counting
reformulation (Kummer's theorem) and the additive form of Legendre's formula.
Every result has been formally verified in the Lean 4 proof assistant with
Mathlib; this paper presents the mathematics and proof sketches.

## 1. Introduction

The binary sum-of-digits function $s_2 : \mathbb{N} \to \mathbb{N}$,

$$s_2(n) = \sum_i d_i, \qquad n = \sum_i d_i 2^i,\quad d_i \in \{0,1\},$$

is one of the most studied arithmetic functions in combinatorial number theory.
It is the prototype of an *automatic* sequence, is intimately tied to the
2-adic valuation through Legendre's and Kummer's theorems, and underlies
questions ranging from the distribution of the Thue–Morse sequence to the
efficiency of arithmetic hardware.

In 2011, Thomas Cusick posed the following deceptively simple question. For a
fixed shift $t \ge 1$, what proportion of integers $n$ satisfy
$s_2(n+t) \ge s_2(n)$? Writing this proportion as the density $c_t$, Cusick
conjectured that $c_t > 1/2$ for all $t$ — adding $t$ is biased toward preserving
or increasing the digit count. A sharper, quantitative form of the conjecture
(the "DKS form," after work of Drmota, Kauers, and Spiegelhofer) proposes the
explicit bias bound

$$c_t \ \ge\ \frac{1}{2} + 2^{-(2 s_2(t) + 1)}. \tag{DKS}$$

While the full asymptotic statement is known to be hard and requires transfer
operator / automaton machinery, several sub-families admit *exact* analysis.
The purpose of this paper is to identify and exploit a self-similarity that
resolves the powers-of-two sub-family completely.

The central observation is a **doubling invariance**: the Cusick predicate is
unchanged under the simultaneous doubling $(n, t) \mapsto (2n, 2t)$, on each
parity fibre. This is a direct consequence of the elementary recursions
$s_2(2n) = s_2(n)$ and $s_2(2n+1) = s_2(n)+1$. The invariance propagates to an
exact self-similarity of the finite counting function and, starting from the
exact base case $c_1 = 3/4$, yields $c_{2^k} = 3/4$ for every $k$.

### Organization

Section 2 establishes the digit-sum foundations (Legendre, subadditivity, block
sums). Section 3 develops the carry reformulation via Kummer's theorem. Section 4
solves the base case $t = 1$ exactly. Section 5 proves the doubling invariance
and its consequences, the main contribution. Section 6 records density witnesses
and infinitude. Section 7 discusses the location of the remaining difficulty and
states future directions.

## 2. The binary digit sum and its arithmetic

**Definition 2.1 (Binary digit sum).** For $n \in \mathbb{N}$, define
$s_2(n) = (\text{digits}_2\, n).\text{sum}$, the sum of the base-2 digits of $n$.
Equivalently, $s_2(n)$ counts the `1`s in the binary expansion of $n$. We have
$s_2(0) = 0$ and $s_2(1) = 1$.

**Proposition 2.2 (Digit bound).** $s_2(n) \le n$ for all $n$.

*Proof sketch.* Each digit is $0$ or $1$ and the place values are at least $1$,
so the digit sum is at most the number. (Mathlib: `Nat.digit_sum_le`.) $\square$

**Theorem 2.3 (Legendre's formula, additive form).** For all $n$,

$$s_2(n) + v_2(n!) = n,$$

where $v_2$ is the 2-adic valuation. Equivalently, the classical Legendre
identity $v_2(n!) = n - s_2(n)$.

*Proof sketch.* Mathlib provides the subtraction form
$(2-1)\cdot v_2(n!) = n - s_2(n)$ as `sub_one_mul_padicValNat_factorial`. Combined
with $s_2(n) \le n$, the truncated subtraction is genuine, and `omega` yields the
additive identity. $\square$

**Theorem 2.4 (Subadditivity).** For all $a, b$,

$$s_2(a + b) \le s_2(a) + s_2(b).$$

*Proof sketch.* The binomial coefficient $\binom{a+b}{a} = (a+b)!/(a!\,b!)$ is an
integer, so $a!\,b! \mid (a+b)!$. Monotonicity of $v_2$ under divisibility gives
$v_2((a+b)!) \ge v_2(a!) + v_2(b!)$. Applying the additive Legendre identity
(Theorem 2.3) to each of $a$, $b$, $a+b$ and simplifying with `omega` produces
the inequality. Equality holds, e.g., when $a = b = 1$. $\square$

**Theorem 2.5 (Block sum / mean digit sum).** For every $k$,

$$\sum_{x=0}^{2^k - 1} s_2(x) = k \cdot 2^{k-1}.$$

Hence the mean of $s_2$ over the dyadic block $[0, 2^k)$ is exactly $k/2$.

*Proof sketch.* Each of the $k$ bit positions is `1` for exactly half of the
$2^k$ residues, contributing $2^{k-1}$ ones; summing over positions gives
$k\cdot 2^{k-1}$ (Mathlib: `Nat.sum_sum_digits_eq`). $\square$

Theorem 2.5 explains, heuristically, why the Cusick density sits *near* $1/2$:
the digit sum has mean $k/2$ over each dyadic block, so the comparison
$s_2(n+t)$ versus $s_2(n)$ is, to leading order, a comparison of two quantities
with the same mean. The bias is a lower-order effect, which is precisely why it
is delicate.

## 3. Cusick's inequality as carry counting (Kummer)

The structural heart of the problem is that the digit-sum inequality is
*exactly* a statement about carries.

**Definition 3.1 (Carry count).** For shift $t$ and base point $n$, define

$$\text{carries}(t, n) = v_2\!\left(\binom{n+t}{t}\right).$$

By Kummer's theorem, this equals the number of carries when adding $n$ and $t$
in base 2.

**Theorem 3.2 (Kummer, subtraction form).**

$$\text{carries}(t, n) = s_2(t) + s_2(n) - s_2(n+t).$$

*Proof sketch.* Mathlib's `sub_one_mul_padicValNat_choose_eq_sub_sum_digits'`
gives, for $p = 2$, exactly $v_2(\binom{n+t}{t}) = s_2(t) + s_2(n) - s_2(n+t)$
in $\mathbb{N}$. $\square$

**Theorem 3.3 (Additive carry identity).**

$$s_2(n+t) + \text{carries}(t, n) = s_2(n) + s_2(t).$$

*Proof sketch.* Combine Theorem 3.2 with subadditivity (Theorem 2.4), which
guarantees the subtraction in Theorem 3.2 is non-truncating; `omega` closes it.
$\square$

**Theorem 3.4 (Carry reformulation of Cusick).**

$$s_2(n) \le s_2(n+t) \quad\Longleftrightarrow\quad \text{carries}(t, n) \le s_2(t).$$

*Proof sketch.* Immediate from the additive identity (Theorem 3.3) by `omega`:
$s_2(n+t) - s_2(n) = s_2(t) - \text{carries}(t,n)$. $\square$

**Theorem 3.5 (No-carry extremal case).** If $\text{carries}(t, n) = 0$ then
$s_2(n+t) = s_2(n) + s_2(t)$, the maximal possible gain.

**Theorem 3.6 (Unconditional carry bound).** $\text{carries}(t, n) \le s_2(n) +
s_2(t)$ for all $n, t$. (The one-sided bound $\text{carries}(t,n) \le s_2(t)$ is
*equivalent* to the Cusick inequality by Theorem 3.4 and can fail, e.g.
$n=3, t=1$ gives $\text{carries} = 2 > 1 = s_2(1)$.)

The reformulation (Theorem 3.4) reframes Cusick's conjecture as: *for more than
half of the $n$ in each dyadic block, adding $t$ produces at most $s_2(t)$
carries.*

## 4. The base case: exact density for $t = 1$

**Theorem 4.1 (Criterion for $t=1$).**

$$s_2(n) \le s_2(n+1) \quad\Longleftrightarrow\quad n \bmod 4 \ne 3.$$

*Proof sketch.* By the reformulation (Theorem 3.4) with $t = 1$ and
$s_2(1) = 1$, the inequality is $\text{carries}(1, n) \le 1$. Now
$\text{carries}(1, n) = v_2(\binom{n+1}{1}) = v_2(n+1)$ via
`Nat.choose_one_right`. Thus the condition is $v_2(n+1) \le 1$, i.e.
$4 \nmid (n+1)$, i.e. $n \bmod 4 \ne 3$. The equivalence
$4 \mid (n+1) \Leftrightarrow v_2(n+1) \ge 2$ uses
`padicValNat_dvd_iff_le`. $\square$

**Lemma 4.2 (Residue count).** For all $m$,

$$\#\{\, n < 4m : n \bmod 4 \ne 3\,\} = 3m.$$

*Proof sketch.* Induction on $m$: each block of four consecutive integers
contributes exactly three survivors (residues $0,1,2$) and one failure (residue
$3$). $\square$

**Theorem 4.3 (Exact finite density for $t=1$).** For all $m$,

$$\#\{\, n < 4m : s_2(n) \le s_2(n+1)\,\} = 3m.$$

Consequently $c_1 = 3/4 = \tfrac{1}{2} + \tfrac{1}{4}$, strictly above the DKS
bound $\tfrac{1}{2} + 2^{-(2\cdot 1 + 1)} = 5/8$.

*Proof sketch.* Combine Theorem 4.1 (rewriting the filter predicate) with Lemma
4.2. This is an exact identity for every $m$, not a numerical estimate. $\square$

## 5. Doubling invariance and the powers-of-two family

This section contains the main contribution: a self-similarity that turns the
single computation of Section 4 into an infinite family of exact densities.

**Lemma 5.1 (Digit-sum doubling recursions).** For all $n$,

$$s_2(2n) = s_2(n), \qquad s_2(2n+1) = s_2(n) + 1.$$

*Proof sketch.* Appending a low `0` bit ($n \mapsto 2n$) leaves all other digits
fixed, so the digit sum is unchanged; appending a low `1` bit ($n \mapsto 2n+1$)
adds exactly one `1`. Both follow from the base-2 digit recursion. $\square$

**Theorem 5.2 (Doubling invariance, even fibre).** For all $n, t$,

$$s_2(2n) \le s_2(2n + 2t) \quad\Longleftrightarrow\quad s_2(n) \le s_2(n+t).$$

*Proof sketch.* Write $2n + 2t = 2(n+t)$ and apply $s_2(2x) = s_2(x)$ (Lemma
5.1) to both sides; the inequality is literally unchanged. $\square$

**Theorem 5.3 (Doubling invariance, odd fibre).** For all $n, t$,

$$s_2(2n+1) \le s_2(2n+1 + 2t) \quad\Longleftrightarrow\quad s_2(n) \le s_2(n+t).$$

*Proof sketch.* Write $2n+1+2t = 2(n+t)+1$, then $s_2(2n+1) = s_2(n)+1$ and
$s_2(2(n+t)+1) = s_2(n+t)+1$ (Lemma 5.1). The two $+1$ terms cancel, reducing the
inequality to $s_2(n) \le s_2(n+t)$ by `omega`. $\square$

Theorems 5.2 and 5.3 are honest biconditionals: both parity classes of the
doubled problem at shift $2t$ collapse onto the *same* base predicate at shift
$t$. This is the engine of the self-similarity.

**Lemma 5.4 (Even/odd split of a filtered count).** For any decidable predicate
$P$ on $\mathbb{N}$ and any $N$,

$$\#\{\, n < 2N : P(n)\,\} = \#\{\, j < N : P(2j)\,\} + \#\{\, j < N : P(2j+1)\,\}.$$

*Proof sketch.* The map $\{0,\dots,2N-1\} \to \{0,\dots,N-1\}\times\{0,1\}$,
$n \mapsto (\lfloor n/2\rfloor, n \bmod 2)$, is a bijection that splits the range
into its even and odd images; induction on $N$ formalizes the bookkeeping. $\square$

**Definition 5.5 (Finite Cusick count).**

$$\text{cusickCount}(t, N) = \#\{\, n < N : s_2(n) \le s_2(n+t)\,\}.$$

**Theorem 5.6 (Self-similarity of the Cusick count).** For all $t, N$,

$$\text{cusickCount}(2t,\ 2N) = 2 \cdot \text{cusickCount}(t,\ N).$$

*Proof sketch.* Apply Lemma 5.4 to the predicate $P(n) = [s_2(n) \le s_2(n+2t)]$
over $[0, 2N)$. The even sub-count is, by Theorem 5.2, equal to
$\text{cusickCount}(t, N)$; the odd sub-count is, by Theorem 5.3, also equal to
$\text{cusickCount}(t, N)$. Their sum is $2\cdot\text{cusickCount}(t, N)$.
$\square$

**Corollary 5.7 (Orbit form and dependence on the odd part).** Iterating
Theorem 5.6,

$$\text{cusickCount}(2^k t,\ 2^k N) = 2^k \cdot \text{cusickCount}(t, N),$$

so the density $c_t$ is invariant under $t \mapsto 2t$; equivalently $c_t$ depends
only on the odd part of $t$.

**Theorem 5.8 (Pointwise criterion for power-of-two shifts).** For all $k, n$,

$$s_2(n) \le s_2(n + 2^k) \quad\Longleftrightarrow\quad \left\lfloor n / 2^k \right\rfloor \bmod 4 \ne 3.$$

This is the natural lift of the $t=1$ rule (Theorem 4.1): discard the low $k$
bits of $n$, then apply $n \bmod 4 \ne 3$ to the quotient.

*Proof sketch.* Write $n = 2^k q + r$ with $q = \lfloor n/2^k\rfloor$ and
$r = n \bmod 2^k < 2^k$. A digit-block lemma gives $s_2(2^k q + r) = s_2(q) +
s_2(r)$ and $s_2(2^k(q+1) + r) = s_2(q+1) + s_2(r)$ (proved by induction on $k$
using Lemma 5.1). Since $n + 2^k = 2^k(q+1) + r$, the $s_2(r)$ terms cancel and
the inequality $s_2(n) \le s_2(n+2^k)$ reduces to $s_2(q) \le s_2(q+1)$, which by
Theorem 4.1 is $q \bmod 4 \ne 3$. $\square$

**Theorem 5.9 (Exact density for every power of two).** For all $k, m$,

$$\text{cusickCount}(2^k,\ 2^{k+2}\, m) = 3 \cdot 2^k \cdot m.$$

Since the window has size $2^{k+2}m = 4\cdot(2^k m)$, the density is exactly

$$c_{2^k} = \frac{3 \cdot 2^k m}{4 \cdot 2^k m} = \frac{3}{4} = \frac{1}{2} + \frac{1}{4},$$

for every $k \ge 0$, a bias of $1/4$ strictly exceeding the DKS bound
$\tfrac{1}{2} + 2^{-(2 s_2(2^k)+1)} = \tfrac{1}{2} + \tfrac{1}{8}$.

*Proof sketch.* Induction on $k$. The base case $k = 0$ is Theorem 4.3
($\text{cusickCount}(1, 4m) = 3m$). For the step, apply the self-similarity
(Theorem 5.6) with $t = 2^k$ and $N = 2^{k+2} m$:

$$\text{cusickCount}(2^{k+1},\ 2^{k+3} m) = 2\cdot\text{cusickCount}(2^k,\ 2^{k+2} m) = 2\cdot 3\cdot 2^k m = 3\cdot 2^{k+1} m.$$

$\square$

This is a genuine theorem for all $k$ and $m$, not a finite check: the outer
induction is on $k$ and the base case is itself an induction on $m$ (Theorem
4.3).

## 6. Density witnesses and unconditional infinitude

Beyond the exact powers-of-two family, two unconditional facts hold for *every*
shift.

**Theorem 6.1 (No-carry high bit).** If $t < 2^L$ then
$s_2(t + 2^L) = s_2(t) + 1$.

*Proof sketch.* The bit $2^L$ lies strictly above all bits of $t$, so adjoining
it appends a single `1` to the binary expansion without any carry. Formally, the
digits of $t + 2^L$ are the digits of $t$, padded with zeros, followed by a `1`.
$\square$

**Theorem 6.2 (The Cusick good set is infinite).** For every $t$, the set
$\{n : s_2(n) \le s_2(n+t)\}$ is infinite, witnessed by the sparse family
$n = 2^{j+t}$ for $j \in \mathbb{N}$.

*Proof sketch.* For $n = 2^{j+t}$ we have $t < 2^{j+t}$, so by Theorem 6.1,
$s_2(n) = 1$ and $s_2(n + t) = s_2(t) + 1 \ge 1 = s_2(n)$. The map $j \mapsto
2^{j+t}$ is injective, so infinitely many such $n$ satisfy the inequality.
$\square$

Theorem 6.2 is the weakest *honest* general statement: it confirms the good set
is never sparse to the point of finiteness, providing an unconditional foothold,
without overclaiming the asymptotic density.

## 7. Discussion: where the difficulty lives

The doubling argument resolves the powers of two completely, and it pinpoints
the obstruction in the general conjecture. Three observations:

1. **Reduction to odd shifts.** By Corollary 5.7, $c_t$ depends only on the odd
   part of $t$. The full conjecture is therefore equivalent to its restriction
   to odd $t$.

2. **The role of $s_2(t)$.** When $s_2(t) = 1$ (i.e. $t$ is a power of two),
   doubling invariance alone forces a single rational density $3/4$. When
   $s_2(t) \ge 2$, doubling no longer determines the density; the carry dynamics
   genuinely depend on the relative positions of the set bits of $t$, and a
   transfer-operator / automaton analysis is required.

3. **The DKS bound has room.** The proved cases satisfy (DKS) with a wide
   margin: $c_{2^k} = 3/4 \ge 1/2 + 1/8$. Computational evidence for small odd
   shifts ($c_3 = 11/16$, $c_5 = 5/8$, $c_7 = 43/64$) likewise exceeds (DKS),
   suggesting the dyadic structure persists but with denominator $2^{2 s_2(t)}$.

A natural program is to build, for each fixed odd $t$, the level-$N$ recursion
for $\text{cusickCount}(t, 2^N)$ and to show that the bias term never drops below
$2^{N - 1 - 2 s_2(t)}$ per block, which would establish (DKS) blockwise. The
self-similarity proved here is the $s_2(t) = 1$ instance of exactly this program.

## 8. Future directions

The following conjectures are precise and falsifiable.

- **Dyadic exactness of small shifts.** For $t \in \{3,5,7\}$,
  $\text{cusickCount}(t, 2^N) = a_t\cdot 2^{N - 2 s_2(t)}$ for all
  $N \ge 2 s_2(t)$, with $(a_3, a_5, a_7) = (11, 10, 43)$, giving
  $c_3 = 11/16$, $c_5 = 5/8$, $c_7 = 43/64$.
- **Power-of-two denominator for odd $t$.** For every odd $t$, $c_t = a_t /
  2^{2 s_2(t)}$ with $a_t$ odd, and the finite count stabilizes:
  $\text{cusickCount}(t, 2^{N+1}) = 2\cdot\text{cusickCount}(t, 2^N)$ for
  $N \ge 2 s_2(t)$.
- **Explicit bias bound (DKS).** For every $t$, $c_t \ge \tfrac{1}{2} +
  2^{-(2 s_2(t)+1)}$.
- **Carry-count tail bound.** For each dyadic block $[0, 2^N)$,
  $\#\{n : \text{carries}(t,n) \le s_2(t)\} - \#\{n : \text{carries}(t,n) >
  s_2(t)\} \ge 2^{N - 2 s_2(t)}$.
- **Gap-independent density for two set bits.** For $t = 2^a + 2^b$ with
  $b \ge a+3$, conjecturally $c_t = 11/16$ (gap-independent), while the
  borderline $t = 2^a + 2^{a+2}$ yields $c_t = 5/8$.

## 9. Conclusion

A pair of one-line facts about appending bits — $s_2(2n) = s_2(n)$ and
$s_2(2n+1) = s_2(n)+1$ — yields a doubling invariance of the Cusick predicate on
each parity fibre, an exact self-similarity $\text{cusickCount}(2t, 2N) =
2\,\text{cusickCount}(t, N)$ of the counting function, and, by induction from the
base case $c_1 = 3/4$, the exact density $c_{2^k} = 3/4$ for every power of two,
with explicit bias $1/4 > 1/8$. The carry reformulation (Kummer) and additive
Legendre identity provide the supporting arithmetic, and the analysis locates the
remaining difficulty precisely in odd shifts with $s_2(t) \ge 2$.
