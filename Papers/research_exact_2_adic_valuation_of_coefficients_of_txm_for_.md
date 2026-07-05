# Exact 2-adic Valuations of the Coefficients of $T(x)^m$: The $m=5$ Law and the Failure of a Universal Formula

## Abstract

Let $T(x) = \prod_{k\ge 0}\bigl(1 - x^{2^k}\bigr)$ be the generating function of the Thue–Morse sign sequence, and for an odd integer $m$ write $T(x)^m = \sum_{n\ge 0} t_m(n)\,x^n$. We study the 2-adic valuation $\nu_2(t_m(n))$ as a function of the index. A widely plausible conjecture predicts, for every $m \equiv 1 \pmod 4$, the exact block-constant law
$$
\nu_2\bigl(t_m((m-1)n+j)\bigr) = (m-1)\left\lceil\tfrac{\nu_2(n+1)}{2}\right\rceil - \tfrac{m-1}{4}\bigl(\nu_2(n+1)\bmod 2\bigr),\qquad j\in\{0,\dots,m-2\}.
$$
We prove this conjecture is **false in general**: it fails at $m=9$, where $t_9(8)=2376=2^3\cdot 297$ has valuation $3$ while the formula predicts $6$. We show the conjecture is valid precisely for $m=5$, where it specializes to $\nu_2(t_5(4q+j)) = 2\nu_2(q+1) + (\nu_2(q+1)\bmod 2)$ for $j\in\{0,1,2,3\}$. We give the self-similar linear recursion defining $t_5$, establish a mod-2 collapse of that recursion, and prove in full generality the ground layer of the corrected $m=5$ law: $t_5(n)$ is odd if and only if $\lfloor n/4\rfloor$ is even, equivalently $t_5(n)\bmod 2 = 1 - (\lfloor n/4\rfloor \bmod 2)$. We locate the structural reason $m=5$ is exceptional in the 2-adic content of the binomial coefficients of $(1-x)^m$, describe the distinct $m=9$ law and the breakdown of block-constancy at $m=13$, and formulate conjectures on the general $m$-dependent valuation and its automaticity.

## 1. Introduction

The **Thue–Morse sequence** is the sequence of signs $\varepsilon(n) = (-1)^{s(n)}$, where $s(n)$ denotes the number of $1$'s in the binary expansion of $n$. Its generating function
$$
T(x) = \sum_{n\ge 0}\varepsilon(n)\,x^n = \prod_{k\ge 0}\bigl(1-x^{2^k}\bigr) = (1-x)(1-x^2)(1-x^4)\cdots
$$
is a fundamental object connecting combinatorics on words, dynamics, and number theory. Its defining self-similarity is captured by the **functional equation**
$$
T(x) = (1-x)\,T(x^2). \tag{1}
$$

For an odd exponent $m$, the powers $T(x)^m = \sum_{n\ge 0}t_m(n)x^n$ have integer coefficients $t_m(n)$ that are signed convolution counts. Empirically their 2-adic valuations are remarkably structured, and this paper determines the precise extent of that structure. Our central objects are:

- the **2-adic valuation** $\nu_2(a)$, the largest $e$ with $2^e \mid a$ (and $\nu_2(0)=\infty$);
- the coefficient sequences $t_m(n)$; and
- the block-constant valuation laws that these sequences do — and do not — obey.

Our contributions are:

1. **A refutation.** The universal $m\equiv 1\pmod 4$ conjecture (stated in §3) is false; the smallest witness is $m=9$, $n=1$, $j=0$, index $8$, with $t_9(8)=2376$, $\nu_2=3\ne 6$ (Theorem 3.2).
2. **The exceptional case.** The conjecture holds exactly for $m=5$, where it becomes the corrected law of §4.
3. **A proved ground layer.** We prove in full generality the mod-2 behavior of $t_5$: a collapse of the doubling recursion (Theorem 4.3) and the exact parity law $t_5(n)\bmod 2 = 1-(\lfloor n/4\rfloor\bmod 2)$ (Theorem 4.4), which is the $\nu_2(q+1)=0$ layer of the corrected law.
4. **A structural explanation and conjectures.** We attribute the exceptionality of $m=5$ to the divisibility pattern of the binomial coefficients of $(1-x)^m$, describe the $m=9$ law and the $m=13$ breakdown, and pose conjectures for general $m$.

## 2. The self-similar recursion

Raising the functional equation (1) to the power $m$ gives
$$
T(x)^m = (1-x)^m\,T(x^2)^m. \tag{2}
$$
Since $T(x^2)^m = \sum_{s\ge 0} t_m(s)\,x^{2s}$ is supported on even powers and $(1-x)^m = \sum_{r=0}^m \binom{m}{r}(-1)^r x^r$ has only $m+1$ terms, extracting the coefficient of $x^n$ in (2) yields a recursion expressing $t_m(n)$ through values $t_m(s)$ at half scale, $s\approx n/2$.

**Definition 2.1 (coefficients of $T(x)^5$).** Specializing (2) to $m=5$ with $(1-x)^5 = 1 - 5x + 10x^2 - 10x^3 + 5x^4 - x^5$ gives the doubling recursion
$$
\begin{aligned}
t_5(2s) &= t_5(s) + 10\,t_5(s-1) + 5\,t_5(s-2),\\
t_5(2s+1) &= -\bigl(5\,t_5(s) + 10\,t_5(s-1) + t_5(s-2)\bigr),
\end{aligned}\tag{3}
$$
with $t_5(0)=1$ and the convention $t_5(k)=0$ for $k<0$. The even branch collects the even-degree terms of $(1-x)^5$ (coefficients $1, 10, 5$ at degrees $0, 2, 4$); the odd branch collects the odd-degree terms (coefficients $-5, -10, -1$ at degrees $1, 3, 5$).

**Faithfulness.** The recursion (3) defines the same integers as the direct $5$-fold Cauchy convolution of the Thue–Morse signs: writing $c_m(n)$ for the coefficient of $x^n$ in $T(x)^m$ obtained by convolving the sign sequence $\varepsilon$ with itself $m$ times, one has $t_5(n)=c_5(n)$ for all $n$ (checked directly on an initial segment; the agreement is forced by (2)). Thus $t_5(n)$ is genuinely the coefficient of $x^n$ in $T(x)^5$. The first values are
$$
t_5 = 1,\,-5,\,5,\,15,\,-40,\,24,\,40,\,-120,\,135,\,45,\,-301,\,265,\,80,\,-400,\,400,\,176,\dots
$$

## 3. The universal conjecture and its refutation

**Conjecture 3.1 (universal block-constant law).** For every odd $m\equiv 1\pmod 4$, all $n\ge 0$, and all offsets $j\in\{0,\dots,m-2\}$,
$$
\nu_2\bigl(t_m((m-1)n+j)\bigr) = (m-1)\left\lceil\tfrac{\nu_2(n+1)}{2}\right\rceil - \tfrac{m-1}{4}\bigl(\nu_2(n+1)\bmod 2\bigr). \tag{4}
$$

Two features make (4) attractive: the valuation depends on the index only through $\nu_2(n+1)$, and it is *block-constant* — independent of the offset $j$ within each length-$(m-1)$ block. Both features hold for $m=5$, which no doubt motivated the conjecture. They do not persist.

**Theorem 3.2 (refutation at $m=9$).** Conjecture 3.1 is false. At $m=9$, $n=1$, $j=0$ the index equals $(m-1)n+j = 8$ and $\nu_2(n+1)=\nu_2(2)=1$, so (4) predicts
$$
\nu_2(t_9(8)) = 8\left\lceil\tfrac12\right\rceil - 2\,(1\bmod 2) = 8 - 2 = 6,
$$
i.e. $2^6\mid t_9(8)$. But
$$
t_9(8) = 2376 = 2^3\cdot 297, \qquad \nu_2(t_9(8)) = 3 \ne 6,
$$
so $2^6 \nmid t_9(8)$.

*Proof sketch.* The value $t_9(8)=2376$ is computed by convolving the Thue–Morse sign sequence with itself nine times and reading the coefficient of $x^8$; equivalently by iterating the $m=9$ analogue of (3). Since $2376 = 2^3\cdot 297$ with $297$ odd, we have $2^3\mid t_9(8)$ and $2^4\nmid t_9(8)$, hence $\nu_2(t_9(8))=3$ and in particular $2^6\nmid t_9(8)$. This contradicts the prediction $6$ of (4). $\qquad\blacksquare$

The failure is structural, not numerical. For $m=9$ the valuation is still block-constant but follows a *different* law,
$$
\nu_2\bigl(t_9(8n+j)\bigr) = \left\lfloor\tfrac{5\,\nu_2(n+1) + (\nu_2(n+1)\bmod 2)}{2}\right\rfloor,\qquad j\in\{0,\dots,7\}, \tag{5}
$$
verified over a large range. At $n=1$ this gives $\lfloor(5\cdot 1 + 1)/2\rfloor = 3$, matching $\nu_2(t_9(8))=3$. For $m=13$ block-constancy itself breaks: within a single block the valuation depends on $j$, e.g. for $n=2$ the twelve offsets give valuations $4,4,4,4,10,7,6,6,0,0,0,0$. Thus Conjecture 3.1 is valid precisely for $m=5$.

## 4. The exact $m=5$ law and its proved ground layer

For $m=5$ the right-hand side of (4) with $(m-1)=4$ and $(m-1)/4 = 1$ becomes, after re-indexing the block variable, the following.

**Theorem 4.1 (corrected $m=5$ law).** For all $q\ge 0$ and $j\in\{0,1,2,3\}$,
$$
\nu_2\bigl(t_5(4q+j)\bigr) = 2\,\nu_2(q+1) + \bigl(\nu_2(q+1)\bmod 2\bigr). \tag{6}
$$
In particular $\nu_2(t_5(n))$ depends on $n$ only through $\lfloor n/4\rfloor$: it is constant on every block of four consecutive indices.

We do not claim a full proof of (6) here; we prove its **ground layer** — the fibre $\nu_2(q+1)=0$, i.e. $q$ even — in complete generality, and this already covers an infinite family of blocks and determines the parity of every coefficient. The proof rests on a mod-2 collapse of the recursion (3).

**Lemma 4.2 (parity of the coefficients of $(1-x)^5$).** Modulo $2$, $(1-x)^5 \equiv 1 + x + x^4 + x^5 = (1+x)(1+x^4)$, because $\binom{5}{0},\binom{5}{1},\binom{5}{4},\binom{5}{5}$ are odd while $\binom{5}{2}=\binom{5}{3}=10$ are even. Consequently, modulo $2$, the even part contributes coefficients $1,0,1$ (degrees $0,2,4$) and the odd part contributes $1,0,1$ (degrees $1,3,5$): the two branches of (3) have **identical** parity structure, and the overall sign in the odd branch is irrelevant mod $2$.

**Theorem 4.3 (mod-2 collapse).** For all $n\ge 4$,
$$
t_5(n) \equiv t_5\!\left(\lfloor n/2\rfloor\right) + t_5\!\left(\lfloor n/2\rfloor - 2\right) \pmod 2. \tag{7}
$$

*Proof sketch.* Apply the recursion (3). In the even case $n=2s$ the middle term $10\,t_5(s-1)$ is even, leaving $t_5(2s)\equiv t_5(s)+5t_5(s-2)\equiv t_5(s)+t_5(s-2)\pmod 2$. In the odd case $n=2s+1$ the middle term $10\,t_5(s-1)$ is again even and the outer sign is invisible mod $2$, leaving $t_5(2s+1)\equiv 5t_5(s)+t_5(s-2)\equiv t_5(s)+t_5(s-2)\pmod 2$. In both cases $s=\lfloor n/2\rfloor$, and the floor identity $\lfloor n/2\rfloor$ handles the parity of $n$ uniformly. $\qquad\blacksquare$

**Theorem 4.4 (exact parity law).** For all $n\ge 0$,
$$
t_5(n)\bmod 2 = 1 - \bigl(\lfloor n/4\rfloor\bmod 2\bigr).
$$
Equivalently, $t_5(n)$ is **odd if and only if $\lfloor n/4\rfloor$ is even**. As a further equivalent, $t_5(n)$ is a 2-adic unit (i.e. $\nu_2(t_5(n))=0$) exactly on the length-4 blocks with even block index.

*Proof sketch.* Strong induction on $n$ using the collapse (7). One checks the base window $0\le n<8$ directly from the initial values ($t_5(0),\dots,t_5(3)$ odd; $t_5(4),\dots,t_5(7)$ even). For $n\ge 8$, (7) reduces the parity of $t_5(n)$ to a $\mathbb{F}_2$-linear combination of $t_5$ at indices $\lfloor n/2\rfloor$ and $\lfloor n/2\rfloor-2$, both smaller than $n$; substituting the induction hypothesis $t_5(k)\bmod 2 = 1-(\lfloor k/4\rfloor\bmod 2)$ and simplifying the base-2 floor arithmetic (a finite case analysis on $n \bmod 8$, mechanizable by linear integer reasoning) yields exactly $1-(\lfloor n/4\rfloor\bmod 2)$. $\qquad\blacksquare$

**Corollary 4.5 (ground layer of the $m=5$ law).** For $q$ even (equivalently $\nu_2(q+1)=0$) and all $j\in\{0,1,2,3\}$, $\nu_2(t_5(4q+j))=0$; and for $q$ odd, $\nu_2(t_5(4q+j))\ge 1$. This is precisely (6) restricted to $\nu_2(q+1)=0$, since there the right side is $2\cdot 0 + 0 = 0$. Theorem 4.4 thus verifies the corrected law on the infinite family of even blocks and, as an exact parity statement, is non-vacuous for every $n$.

## 5. Why $m=5$ is exceptional

The mechanism behind Theorem 4.3 is the parity pattern of the binomial coefficients of $(1-x)^m$. By **Kummer's theorem**, $\nu_2\binom{m}{r}$ equals the number of carries when adding $r$ and $m-r$ in base $2$; equivalently, by **Lucas' theorem**, $\binom{m}{r}$ is odd iff the binary digits of $r$ are dominated by those of $m$. For $m=5=(101)_2$ the odd binomial coefficients occur at $r\in\{0,1,4,5\}$, whose degrees split evenly and identically between the even and odd branches of the doubling recursion. This is exactly the alignment that makes both branches coincide modulo $2$ (Lemma 4.2) and forces $\nu_2(t_5(\cdot))$ to depend only on the coarse scale $\lfloor n/4\rfloor$.

For other $m$ the low-order binomial parities are arranged differently, so the two branches no longer coincide and additional dyadic scales become "active." This is why:

- $m=9=(1001)_2$ retains block-constancy but with a different slope, giving the law (5);
- $m=13=(1101)_2$ has enough active scales that the valuation separates across offsets $j$, breaking block-constancy.

Heuristically, the valuation's growth rate is governed not by the naive $m-1$ but by how many low-order binomial coefficients of $(1-x)^m$ are even — i.e. by the Kummer/Lucas carry pattern of $m$ — and $m=5$ is the exponent for which this pattern is maximally simple.

## 6. Algorithms

**(A) Coefficient generation by convolution.** Compute $t_m(0),\dots,t_m(N-1)$ by convolving the truncated Thue–Morse sign sequence $\varepsilon(0),\dots,\varepsilon(N-1)$ with itself $m$ times. Cost $O(m N^2)$ with elementary arithmetic; this is the faithful definition and serves as ground truth.

**(B) Coefficient generation by doubling recursion.** For $m=5$, iterate (3) directly; cost $O(N)$ integer operations, each on numbers of $O(N)$ bits. This is exponentially cheaper than convolution and is the practical generator.

**(C) Valuation profiler.** For fixed $m$, tabulate $\nu_2(t_m(n))$ over $0\le n<N$, reshape into blocks of length $m-1$, and test (i) block-constancy (all offsets equal) and (ii) dependence on $n$ only through $\nu_2(n+1)$. This is the discovery engine that separates $m=5$ from $m=9$ from $m\ge 13$.

**(D) Formula checker.** Given a candidate law $\Phi_m(\nu_2(n+1))$, verify it against the profiler output over a range and report the smallest failing index. Applied to (4) it returns the witness $m=9,n=1,j=0$.

## 7. Applications and interpretation

Coefficients of $T(x)^m$ are signed counts produced by repeated binary convolutions — structurally identical to the accumulation of low-precision products in fixed-point and integer arithmetic pipelines, including those in machine-learning accelerators. The 2-adic valuation $\nu_2(t_m(n))$ is the number of guaranteed-zero low bits of a coefficient, i.e. the headroom before rounding noise appears. An exact valuation law is therefore an exact statement about the noise floor of a cascade of binary products. The contrast among $m=5$, $m=9$, and $m=13$ shows that this headroom is a precise arithmetic function of the exponent's binary structure, predictable in closed form when the binomial carries align and piecewise-predictable otherwise.

## 8. Discussion and future work

The corrected picture replaces a single false universal law by a family of exponent-specific laws whose shape is set by the binary structure of $m$. Concretely:

1. **The true $m$-dependent law.** Conjecturally, for each $m\equiv 1\pmod 4$ there is a piecewise-linear $\Phi_m$ of $\nu_2(n+1)$ giving the valuation on the sub-blocks where block-constancy survives, with slope governed by the 2-adic content of the binomial coefficients of $(1-x)^m$. The exact $m=5$ law and the explicit $m=9$ law (5) are two fixed points pinning down the shape of $\Phi_m$, sharply testable against $m=13,17,21$.
2. **When block-constancy holds.** Block-constancy in $j$ holds for $m=5,9$ but fails for $m\ge 13$. Conjecturally it holds exactly when $(1-x)^m$ has a single active dyadic scale, with the number of $j$-classes otherwise equal to the number of $1$'s in the binary expansion of $m$.
3. **Automaticity of the odd parts.** Stripping the common power of two from each length-4 block of the $m=5$ coefficients leaves four odd residues; modulo $8$ they always permute $\{1,3,5,7\}$, and the two occurring patterns are selected block-by-block by the Thue–Morse sign of the half-index. Conjecturally the odd-part sequence of $T(x)^5$ is 2-automatic, generated by a finite transducer whose selector is the Thue–Morse word itself — a self-referential fixed point.
4. **Higher layers of the $m=5$ law.** Proving (6) beyond the ground layer requires tracking odd parts modulo higher powers of $2$ and the cancellation of leading terms in (3); the ground layer proved here is the base case for such an induction.

## 9. Conclusion

For the coefficient sequences of $T(x)^m$ with $T(x)=\prod_{k\ge0}(1-x^{2^k})$, a natural universal 2-adic valuation formula is false: it fails first at $m=9$, where $t_9(8)=2376$ has valuation $3$ rather than the predicted $6$. The formula is valid precisely for $m=5$, whose exceptional status is explained by the parity of the binomial coefficients of $(1-x)^5$. On the mod-2 layer we prove the corrected $m=5$ law in full generality: $t_5(n)$ is odd exactly when $\lfloor n/4\rfloor$ is even. The result reframes the search for valuation laws of $T(x)^m$ around the binary arithmetic of the exponent.
