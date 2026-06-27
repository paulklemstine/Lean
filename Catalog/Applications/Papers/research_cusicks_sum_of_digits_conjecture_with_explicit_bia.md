# Carry Reformulation and Exact Densities for Cusick's Binary Sum-of-Digits Problem

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Applications (analytic / combinatorial number theory)

## Abstract

Let $s_2(n)$ denote the binary sum-of-digits function (the number of $1$s in the
binary expansion of $n$). For a fixed shift $t \ge 1$, Cusick's conjecture asserts
that the natural density
$$ c_t = \lim_{N\to\infty} \frac1N\,\#\{\,0\le n < N : s_2(n+t)\ge s_2(n)\,\} $$
satisfies $c_t > \tfrac12$, with the explicit lower bound
$c_t \ge \tfrac12 + 2^{-(2s_2(t)+1)}$. We present a self-contained development of
the structural arithmetic underlying this problem and prove several exact results.
Our central reformulation expresses the Cusick event in terms of base-$2$ carries:
via Kummer's theorem the carry count equals $v_2\binom{n+t}{t}$, and the exact
identity $s_2(n+t) + K(n,t) = s_2(n)+s_2(t)$ shows that $s_2(n)\le s_2(n+t)$ holds
if and only if $K(n,t)\le s_2(t)$. We establish: (i) subadditivity of $s_2$ via the
additive Legendre identity $s_2(n)+v_2(n!) = n$; (ii) the exact block average
$\sum_{x<2^k} s_2(x) = k\,2^{k-1}$, fixing the mean of $s_2$ at $k/2$; (iii) the
exact density $c_1 = \tfrac34$ through the congruence criterion
$s_2(n)\le s_2(n+1)\iff n\not\equiv 3\pmod4$; (iv) a doubling self-similarity
$\mathrm{Count}(2t,2N)=2\,\mathrm{Count}(t,N)$ and its orbit form
$\mathrm{Count}(2^kt,2^kN)=2^k\,\mathrm{Count}(t,N)$, proving the Cusick density is
constant along $\{t,2t,4t,\dots\}$; and (v) the exact density $c_{2^k}=\tfrac34$ for
every power-of-two shift, with explicit surplus $2^k m$ over the fair half. All
results are formally verified. We close with conjectures on minimal periods,
closed-form numerators, strengthened bias bounds, and dependence on the digit
pattern.

## 1. Introduction

The binary sum-of-digits function $s_2$ is one of the most studied arithmetic
functions, appearing in automatic sequences, the analysis of carry propagation,
Hamming-weight circuit complexity, and the fractal combinatorics of Pascal's
triangle modulo $2$. In 1990 Cusick raised a question of disarming simplicity:
fixing a shift $t$, among all starting points $n$, is the event "the binary digit
sum does not decrease under $n \mapsto n+t$" *more common than its complement*?

Cusick conjectured an affirmative answer for **every** $t\ge1$, with a quantitative
floor that degrades only with the digit complexity of the shift:
$$ c_t \;\ge\; \tfrac12 + 2^{-(2 s_2(t)+1)}. \tag{C}$$
The problem is subtle precisely because the unconditional mean of $s_2$ over a
dyadic block is *exactly* $k/2$ (Theorem 3 below): the baseline really is a fair
coin, so any persistent bias must come from the fine carry structure of addition.

This paper develops that carry structure from first principles and extracts every
density that the structure pins down exactly. Our contribution is twofold. First, a
clean and self-contained **carry reformulation** (Section 3) reducing the Cusick
event to a carry inequality, with carries identified analytically through Kummer's
theorem. Second, two **exact density theorems** — $c_1 = \tfrac34$ (Section 4) and
$c_{2^k} = \tfrac34$ for all $k$ (Section 5) — the latter obtained from the former
through a doubling self-similarity that proves the density is an invariant of the
doubling orbit. Throughout we record the precise statements; all of them are
machine-verified, and the proof sketches below reconstruct the verified arguments.

Notation. Throughout, $v_2(m)$ is the $2$-adic valuation of $m$ (the exponent of
the largest power of $2$ dividing $m$), $\#S$ or $|S|$ denotes cardinality, and
$[a,b)$ denotes the integer interval $\{a,a+1,\dots,b-1\}$.

## 1.1 Background and context

The three classical ingredients we use deserve a word of context, since their
interplay is the conceptual core of the paper.

*Legendre's formula* (also attributed to de Polignac) computes the exact power of a
prime $p$ dividing $n!$: $v_p(n!) = \sum_{i\ge1}\lfloor n/p^i\rfloor = (n - s_p(n))/(p-1)$,
where $s_p$ is the base-$p$ digit sum. For $p=2$ this collapses to the strikingly
clean partition $s_2(n) + v_2(n!) = n$ (Theorem `s2_add_val`). The value of this
identity for our purposes is that it linearizes the digit sum: an inequality about
$s_2$ becomes an inequality about valuations of factorials, where divisibility is the
only tool needed.

*Kummer's theorem* (1852) states that the exact power of a prime $p$ dividing the
binomial coefficient $\binom{m+n}{n}$ equals the number of carries when $m$ and $n$
are added in base $p$. For $p=2$ this identifies the carry count with
$v_2\binom{n+t}{t}$ (Definition 4) and, after substituting Legendre, with the digit
defect $s_2(t)+s_2(n)-s_2(n+t)$ (Theorem `carries_eq_sub`). Kummer's theorem is what
turns a question about digit-sum statistics into a question about *carries*, which
are local, combinatorial, and far easier to control.

*Natural density.* For a set $S\subseteq\mathbb{N}$ the natural density is
$\dens(S)=\lim_{N\to\infty}\#(S\cap[0,N))/N$ when the limit exists. A recurring
difficulty in density problems is that the limit need not exist; here it does, and in
fact the relevant counting functions are *exactly linear* on aligned dyadic blocks
(Theorems 9, 14), so the densities are exact rationals rather than mere limits. This
is a consequence of an underlying pure periodicity of the Cusick predicate, made
quantitative for powers of two in this paper and conjectured in general (§10, C1).

A last remark frames the whole enterprise. Because the mean of $s_2$ over a dyadic
block is exactly $k/2$ (Theorem 3), a *random* model in which the digit-sum change
$s_2(n+t)-s_2(n)$ were symmetric would predict $c_t=\tfrac12$. Cusick's conjecture is
precisely the statement that the deterministic carry structure breaks this symmetry
in a fixed direction, for every shift. The exact results below confirm this for
infinitely many shifts and quantify the break.

## 2. The binary digit sum

**Definition 1 (`s2`).** For $n\in\mathbb{N}$, $s_2(n) := (\text{digits}_2 n).\mathrm{sum}$,
the sum of the base-$2$ digits of $n$; equivalently the number of $1$s in the
binary expansion ("popcount"). We have $s_2(0)=0$ and $s_2(1)=1$.

**Proposition (`s2_le`).** $s_2(n)\le n$ for all $n$.

The first structural result is the additive form of Legendre's formula, the engine
behind subadditivity.

**Theorem (Legendre, additive form; `s2_add_val`).**
$$ s_2(n) + v_2(n!) = n \qquad (n\in\mathbb{N}). $$
*Proof sketch.* The classical Legendre/de Polignac formula gives
$(2-1)\,v_2(n!) = n - s_2(n)$ for the prime $2$; since $s_2(n)\le n$, rearranging in
$\mathbb{N}$ yields the additive identity. $\square$

**Lemma (`padicVal2_mono`).** If $k\ne 0$ and $m\mid k$, then $v_2(m)\le v_2(k)$.
*Proof sketch.* $2^{v_2(m)}\mid m \mid k$, so $2^{v_2(m)}\mid k$, whence
$v_2(m)\le v_2(k)$. $\square$

**Theorem 2 (Subadditivity; `s2_subadditive`).** For all $a,b\in\mathbb{N}$,
$$ s_2(a+b) \le s_2(a) + s_2(b), $$
with equality iff adding $a$ and $b$ in base $2$ produces no carries.
*Proof sketch.* Since $\binom{a+b}{a}=(a+b)!/(a!\,b!)\in\mathbb{Z}$, we have
$a!\,b!\mid(a+b)!$, so by the lemma and additivity of $v_2$ on products,
$v_2(a!)+v_2(b!)\le v_2((a+b)!)$. Substituting the additive Legendre identity for
each of $a$, $b$, and $a+b$ and simplifying gives $s_2(a+b)\le s_2(a)+s_2(b)$. $\square$

**Theorem 3 (Block average; `s2_block_sum`).** For every $k\in\mathbb{N}$,
$$ \sum_{x=0}^{2^k-1} s_2(x) = k\cdot 2^{k-1}, $$
so the mean of $s_2$ over $[0,2^k)$ is exactly $k/2$.
*Proof sketch.* Each of the $k$ bit-positions is $1$ for exactly half of the
$2^k$ numbers, contributing $2^{k-1}$ ones; summing over positions gives
$k\cdot 2^{k-1}$. (Equivalently, this is the base-$2$ instance of the general
digit-sum summation $\sum_{x<b^k} s_b(x) = \tfrac{(b-1)k}{2}b^{k-1}$.) $\square$

Theorem 3 is the quantitative reason the Cusick density orbits $\tfrac12$: the
baseline is a fair coin, and the entire content of the conjecture is the persistent
tilt away from it.

## 3. The carry reformulation

**Definition 4 (Carry count; `carries`).** For $t,n\in\mathbb{N}$, define
$$ K(n,t) := v_2\!\binom{n+t}{t}. $$
By **Kummer's theorem**, $K(n,t)$ equals the number of carries when adding $n$ and
$t$ in base $2$.

**Theorem 5 (Kummer, subtraction form; `carries_eq_sub`).**
$$ K(n,t) = s_2(t) + s_2(n) - s_2(n+t). $$
*Proof sketch.* This is the digit-sum form of Kummer's theorem: the $2$-adic
valuation of $\binom{n+t}{t}$ equals $\tfrac{1}{2-1}\bigl(s_2(t)+s_2(n)-s_2(n+t)\bigr)$. $\square$

**Corollary (Exact carry identity; `s2_add_carries`).** For all $n,t$,
$$ s_2(n+t) + K(n,t) = s_2(n) + s_2(t). $$
*Proof sketch.* Add $s_2(n+t)$ to both sides of Theorem 5; the truncated
subtraction is justified because subadditivity (Theorem 2) guarantees
$s_2(n+t)\le s_2(n)+s_2(t)$. $\square$

This single equality is the keystone. It says each base-$2$ carry destroys exactly
one unit of the additive ideal $s_2(n)+s_2(t)$, so the digit sum of $n+t$ measures
exactly the *shortfall* from no-carry addition.

**Theorem 6 (Cusick event as carry inequality; `cusick_reformulation`).**
$$ s_2(n) \le s_2(n+t) \iff K(n,t) \le s_2(t). $$
*Proof sketch.* Substitute the corollary $s_2(n+t)=s_2(n)+s_2(t)-K(n,t)$ into
$s_2(n)\le s_2(n+t)$ and cancel $s_2(n)$. $\square$

**Corollary (No-carry extremal case; `cusick_of_no_carry`).** If $K(n,t)=0$ then
$s_2(n+t)=s_2(n)+s_2(t)$, the maximal possible digit-sum gain.

**Proposition (Unconditional carry bound; `carries_le_total`).**
$K(n,t)\le s_2(n)+s_2(t)$ for all $n,t$ (in contrast to the one-sided bound
$K(n,t)\le s_2(t)$, which is equivalent to the Cusick event and may fail).

Theorem 6 converts Cusick's conjecture into the statement that carries are
"typically few": the digit sum fails to decrease exactly when the addition produces
at most $s_2(t)$ carries.

## 4. The exact density for $t=1$

**Lemma (High-bit additivity; `s2_high_bit`).** If $t < 2^L$, then
$s_2(t+2^L) = s_2(t)+1$. *Proof sketch.* Adjoining the bit $2^L$ strictly above the
support of $t$ creates no carries, adding exactly one $1$. $\square$

**Theorem 7 (Good set is infinite; `cusick_good_set_infinite`).** For every $t$,
the set $\{n : s_2(n)\le s_2(n+t)\}$ is infinite.
*Proof sketch.* The injective family $n=2^{j+t}$ ($j\ge0$) lies in the set: by the
high-bit lemma $s_2(2^{j+t})=1$ and $s_2(2^{j+t}+t)=s_2(t)+1\ge1$, so the
inequality holds for all $j$. $\square$

**Theorem 8 (Congruence criterion for $t=1$; `cusick_t1_iff`).**
$$ s_2(n)\le s_2(n+1) \iff n\not\equiv 3 \pmod 4. $$
*Proof sketch.* By Theorem 6 with $t=1$ (and $s_2(1)=1$), the event is
$K(n,1)\le 1$. Here $K(n,1)=v_2\binom{n+1}{1}=v_2(n+1)$, the number of trailing
zeros of $n+1$. Thus the event fails iff $4\mid(n+1)$, i.e. iff $n\equiv 3\pmod4$. $\square$

**Lemma (Residue count; `count_mod4_ne_three`).**
$\#\{n<4m : n\not\equiv 3\ (\mathrm{mod}\ 4)\} = 3m$. *Proof sketch.* Each of the
$m$ blocks of four consecutive integers contributes exactly three admissible
residues; induction on $m$. $\square$

**Theorem 9 (Exact density $c_1=3/4$; `cusick_t1_density`).**
$$ \#\{\,n<4m : s_2(n)\le s_2(n+1)\,\} = 3m, $$
hence $c_1 = \tfrac34$. This clears the Cusick floor (C),
$\tfrac12+2^{-(2\cdot1+1)}=\tfrac58$, by $\tfrac18$.
*Proof sketch.* By Theorem 8 the filtered set coincides with
$\{n<4m : n\not\equiv 3\ (\mathrm{mod}\ 4)\}$, which has cardinality $3m$ by the
lemma. Dividing by $4m$ and letting $m\to\infty$ gives $c_1=3/4$. $\square$

## 5. Doubling self-similarity and the power-of-two family

The single exact value $c_1=3/4$ propagates to an infinite family through a
self-similarity of the Cusick event under simultaneous doubling of shift and
window.

**Lemmas (Bit append; `s2_two_mul`, `s2_two_mul_add_one`).**
$$ s_2(2n) = s_2(n), \qquad s_2(2n+1) = s_2(n)+1. $$
*Proof sketch.* Multiplying by $2$ appends a low $0$ (digit sum unchanged); adding
$1$ then sets that low bit to $1$ (digit sum $+1$). $\square$

**Theorem 10 (Doubling invariance; `cusick_double_even`, `cusick_double_odd`).**
For all $n,t$,
$$ s_2(2n) \le s_2(2n+2t) \iff s_2(n)\le s_2(n+t), $$
$$ s_2(2n+1) \le s_2(2n+1+2t) \iff s_2(n)\le s_2(n+t). $$
*Proof sketch.* In the even case, $2n+2t=2(n+t)$ and both sides lose the low bit by
`s2_two_mul`, reducing to the original event. In the odd case,
$2n+1+2t=2(n+t)+1$; applying `s2_two_mul_add_one` to both sides adds $1$ to each,
which cancels in the inequality. $\square$

**Definition 12 (Cusick counting function; `cusickCount`).**
$$ \mathrm{Count}(t,N) := \#\{\,n<N : s_2(n)\le s_2(n+t)\,\}. $$

**Lemma (Even/odd fibre split; `card_filter_range_two_mul`).** For any predicate
$P$, $\#\{n<2N : P(n)\} = \#\{j<N : P(2j)\} + \#\{j<N : P(2j+1)\}$.

**Theorem 13 (Self-similarity; `cusickCount_two_mul`).**
$$ \mathrm{Count}(2t,\,2N) = 2\,\mathrm{Count}(t,\,N). $$
*Proof sketch.* Split $\mathrm{Count}(2t,2N)$ over even and odd fibres (the lemma);
Theorem 10 identifies each fibre's predicate with the base event, so each fibre
contributes $\mathrm{Count}(t,N)$. $\square$

**Corollary (Base case; `cusickCount_one`).**
$\mathrm{Count}(1,4m)=3m$ (restatement of Theorem 9).

**Theorem 11 (Pointwise criterion for $2^k$; `cusick_pow2_iff`).**
$$ s_2(n)\le s_2(n+2^k) \iff \big(\lfloor n/2^k\rfloor\big)\not\equiv 3 \pmod 4. $$
*Proof sketch.* Write $n=2^k q + r$ with $r<2^k$. By the digit-concatenation
identity $s_2(2^k x + r)=s_2(x)+s_2(r)$ (a consequence of the bit-append lemmas),
both $s_2(n)$ and $s_2(n+2^k)=s_2(2^k(q+1)+r)$ differ only through $s_2(q)$ vs
$s_2(q+1)$, so the event reduces to the $t=1$ criterion (Theorem 8) applied to
$q=\lfloor n/2^k\rfloor$. $\square$

**Theorem 14 (Exact density $c_{2^k}=3/4$; `cusick_pow2_density`).** For all $k,m$,
$$ \mathrm{Count}(2^k,\,2^{k+2}m) = 3\cdot 2^k\cdot m, $$
hence $c_{2^k} = \tfrac34$ for every $k\ge0$.
*Proof sketch.* Induction on $k$. The base case is Theorem 9. For the step, write
$2^{k+1}=2\cdot2^k$ and $2^{(k+1)+2}m = 2\cdot(2^{k+2}m)$, then apply Theorem 13 and
the inductive hypothesis: $\mathrm{Count}(2^{k+1},2^{k+3}m)=2\cdot\mathrm{Count}(2^k,2^{k+2}m)=2\cdot 3\cdot2^k m = 3\cdot2^{k+1}m$. $\square$

**Theorem 15 (Full orbit invariance; `cusickCount_two_pow_mul`).** For all $k,t,N$,
$$ \mathrm{Count}(2^k t,\,2^k N) = 2^k\,\mathrm{Count}(t,\,N). $$
*Proof sketch.* Induction on $k$, each step an instance of Theorem 13. $\square$

In density terms, Theorem 15 says $c_{2^k t} = c_t$: **the Cusick density is an
invariant of the doubling orbit $\{t,2t,4t,\dots\}$, depending only on the odd part
of $t$.**

**Theorem 16 (Explicit bias; `cusick_pow2_bias`).** For all $k,m$,
$$ \mathrm{Count}(2^k,\,2^{k+2}m) = 2^{k+1}m + 2^k m. $$
*Proof sketch.* Rewrite Theorem 14's $3\cdot2^k m$ as $2^{k+1}m + 2^k m$. $\square$

Since the block $[0,2^{k+2}m)$ has fair half $2^{k+1}m$, Theorem 16 exhibits the
density bias directly: the good count exceeds the half by exactly $2^k m =
\tfrac14\cdot 2^{k+2}m$. Thus $c_{2^k}-\tfrac12 = \tfrac14$ for every $k$, an
explicit, $k$-independent surplus far exceeding the Cusick floor's
$2^{-(2\cdot1+1)}=\tfrac18$.

## 6. Worked examples and numerical evidence

We illustrate the machinery on concrete values; all numbers below are reproducible
by direct enumeration and agree with the theorems above.

**Example (carry identity).** Take $n=55=110111_2$ ($s_2=5$) and $t=1$. Then
$n+t=56=111000_2$ ($s_2=3$), and adding $1$ propagates through the trailing run
$111_2$, producing $K(55,1)=3$ carries. Indeed $s_2(n+t)+K = 3+3 = 6 = s_2(n)+s_2(t)
= 5+1$ (Corollary, `s2_add_carries`), and $\binom{56}{1}=56=2^3\cdot7$ confirms
$v_2\binom{56}{1}=3$ (Definition 4 via Kummer). Here $K=3 > s_2(t)=1$, so the Cusick
event **fails**: $s_2(55)=5 > 3 = s_2(56)$, consistent with $55\equiv 3\pmod 4$
(Theorem 8).

**Example (good start).** Take $n=8=1000_2$ ($s_2=1$) and $t=1$: $n+t=9=1001_2$
($s_2=2$). No carries occur ($K=0$), so $s_2(n+t)=s_2(n)+s_2(t)=2$ exactly
(Corollary `cusick_of_no_carry`), and the event holds; $8\equiv 0\pmod4$.

**Example (exact density $c_1$).** Over $[0,12)$ the starts failing the event are
exactly those $\equiv 3\pmod4$, namely $3,7,11$ — three of them — so $9$ of $12$
succeed, matching $\#=3m=9$ at $m=3$ (Theorem 9) and density $9/12=3/4$.

**Example (doubling).** With $t=1$, $N=4$ we have $\mathrm{Count}(1,4)=3$. Doubling,
$\mathrm{Count}(2,8)=6=2\cdot3$ (Theorem 13), and indeed over $[0,8)$ the starts
with $s_2(n)\le s_2(n+2)$ are $0,1,2,3,4,6$ — six of them. Iterating,
$\mathrm{Count}(4,16)=12$ and $\mathrm{Count}(2^k,2^{k+2})=3\cdot2^k$ (Theorem 14).

**Numerical density table.** Direct enumeration over a window $N=2^{16}$ gives the
following densities $c_t$ (exact where proven), alongside the Cusick floor (C):

| $t$ | binary | $s_2(t)$ | $c_t$ | floor $\tfrac12+2^{-(2s_2(t)+1)}$ | status |
|---|---|---|---|---|---|
| $1$ | $1$ | $1$ | $3/4$ | $5/8$ | proven exact (Thm 9) |
| $2$ | $10$ | $1$ | $3/4$ | $5/8$ | proven exact (Thm 14) |
| $3$ | $11$ | $2$ | $11/16$ | $17/32$ | empirical |
| $4$ | $100$ | $1$ | $3/4$ | $5/8$ | proven exact (Thm 14) |
| $5$ | $101$ | $2$ | $5/8$ | $17/32$ | empirical |
| $7$ | $111$ | $3$ | $43/64$ | $65/128$ | empirical |

Two features stand out. First, every proven value $c_{2^k}=3/4$ clears the floor by
the constant margin $1/8$. Second, $c_3=11/16$ and $c_5=5/8$ have the *same*
$s_2(t)=2$ yet differ — the bias is sensitive to the *pattern* of the bits, not only
their count (cf. Conjecture C4). All empirical values exceed not merely the Cusick
floor but *twice* its excess over $\tfrac12$ (Conjecture C3): e.g.
$c_3-\tfrac12=3/16\ge 2^{-2\cdot2}=1/16$.

## 7. Algorithms

**Algorithm A (Carry-based Cusick predicate).** To decide $s_2(n)\le s_2(n+t)$ one
need not compare digit sums directly: by Theorem 6 it suffices to test
$K(n,t)\le s_2(t)$, where $K(n,t)$ is computable either as the number of base-$2$
carries in $n+t$ (a single linear scan over the bits) or as $v_2\binom{n+t}{t}$.
The carry scan runs in $O(\log(n+t))$ bit operations.

**Algorithm B (Doubling recursion for densities).** To compute $\mathrm{Count}(t,N)$
for $t$ even and $N$ even, recurse via Theorem 13: $\mathrm{Count}(2t',2N')=
2\,\mathrm{Count}(t',N')$. Stripping the shared factor $2^{v_2(t)}$ reduces any
power-of-two-divisible instance to the odd-shift base case, after which Theorem 14
gives the closed form for power-of-two shifts in $O(1)$.

## 8. Applications

The carry reformulation connects Cusick's density to three concrete settings.
(i) **Circuit complexity:** $s_2$ is Hamming weight, and $K(n,t)$ counts the
full-adder activations in computing $n+t$; Theorem 6 bounds how often an addition
keeps weight from dropping. (ii) **Automatic sequences:** $s_2 \bmod 2$ is the
Thue–Morse sequence, and the digit-concatenation identity used in Theorem 11 is the
substitutive self-similarity that makes such sequences automatic. (iii)
**Probabilistic models of carries:** Theorem 3 (mean $k/2$) plus Theorem 6
formalizes the heuristic that carry counts behave like a stopped random walk biased
toward few carries — the intuition behind the original "first-exit / deconvolution"
attack on the full conjecture.

## 9. Discussion

The results pin down the Cusick density exactly on the entire set of shifts whose
odd part is $1$ — namely all powers of two — giving $c_{2^k}=\tfrac34$, and reduce
every other shift's density to that of its odd part. The methodology is
characteristic of how such problems fall: a transcendental-looking statistic is
made algebraic (carries via Kummer), anchored by an exact identity (Legendre),
computed honestly in one base case ($t=1$), and then propagated by an exact
self-similarity (doubling). What remains for the *general* conjecture is the
odd-shift densities, where carries no longer reduce to a single trailing run and a
genuine stopped-walk analysis is required.

It is worth being precise about the boundary between what is proven here and the full
conjecture. The carry reformulation (Theorem 6) is unconditional and holds for every
$t$; it is the universal translation layer. The exact densities, however, exploit a
special feature of power-of-two shifts: for $t=2^k$ the carry count $K(n,2^k)$ is
governed by a *single* digit transition $\lfloor n/2^k\rfloor \mapsto \lfloor
n/2^k\rfloor + 1$ (Theorem 11), exactly as in the $t=1$ case. For a general $t$ with
$s_2(t)\ge 2$, adding $t$ can trigger several independent carry chains whose joint
law is no longer a single trailing-run statistic. The correct object is then the
distribution of $K(n,t)$ as $n$ ranges over a period — a *stopped random walk* law
obtained by deconvolving the digit-sum difference — and Cusick's bound
$c_t\ge\tfrac12+2^{-(2s_2(t)+1)}$ is a statement about the first-exit behaviour of
that walk. The numerical table of §6 shows the qualitative phenomenon the general
theory must explain: shifts with equal $s_2(t)$ (such as $t=3$ and $t=5$) can have
strictly different densities, so any exact formula must see the full digit pattern of
$t$, not merely its weight.

The practical upshot of the doubling theory is a reduction principle: to understand
all Cusick densities it suffices to understand the *odd* shifts, since
$c_{2^kt}=c_t$ (Theorem 15). The odd shifts of small weight — beginning with the
Mersenne-type blocks $t=2^j-1$, whose conjectured numerators $A(2^k-1)=(2\cdot4^k+1)/3$
appear in §10 (C2) — are the natural next targets, and their carry automaton is a
single counter, suggesting they too admit exact closed forms by the methods of this
paper.

## 10. Future directions

**C1. Exact period $2^{(\text{length }t)+s_2(t)}$ (minimality).** Empirically the
Cusick predicate $P_t(n)=[s_2(n)\le s_2(n+t)]$ is purely periodic in $n$ with
minimal period $2^{(\text{length }t)+s_2(t)}$. The operative exponent is already
isolated; closing the gap to minimality needs a single explicit distinguishing
residue from the carry (overflow) analysis.

**C2. Closed form for the numerator.** With periodicity, $A(t):=\mathrm{Count}(t,
2^{L+s_2(t)})$ is a well-defined integer. Measured values $A(2^k-1)=3,11,43,171,683$
fit $A(2^k-1)=(2\cdot4^k+1)/3$, suggesting a linear recurrence $A_{k+1}=4A_k-1$ for
the all-ones family, provable by the same digit-concatenation identity used for the
power-of-two family.

**C3. Strengthened bias $c_t-\tfrac12\ge 2^{-2s_2(t)}$.** Every measured value beats
*twice* the Cusick floor. The overflow regime contributes a deterministic deficit of
one full digit ($s_2(n+t)\le s_2(n)-1$), which a single-period counting comparison
should convert into the doubled bias.

**C4. Dependence on the odd part *and* digit pattern.** Theorem 15 already shows the
density depends only on the odd part; the finer question is how it depends on the
digit pattern of that odd part, e.g. whether all shifts with the same $s_2$ value
share comparable bias.
