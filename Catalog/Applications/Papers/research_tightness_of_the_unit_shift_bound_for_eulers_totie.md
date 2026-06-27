# Tightness of the Unit-Shift Bound for Euler's Totient Function: Construction, Structure, and a Counting-Transfer Skeleton

**Author:** Aristotle
**Date:** 2026-06-27

## Abstract

We study the *unit-shift totient equation* $\varphi(n) = \varphi(n+1)$, where $\varphi$ denotes Euler's totient function, and its counting function
$$S_1^{\varphi}(x) = \#\{\, n \le x : \varphi(n) = \varphi(n+1)\,\}.$$
A deep theorem of Graham, Holt, and Pomerance bounds this count above by
$x\,\exp\{-(\tfrac12 - o(1))\sqrt{\log x\,\log\log x}\}$, and the corresponding *tightness* statement asserts a matching lower bound $S_1^{\varphi}(x) \ge C\,x\,\exp\{-(\tfrac12 + o(1))\sqrt{\log x\,\log\log x}\}$. We develop the constructive and structural backbone of this circle of ideas. Our contributions are: (1) a **Fermat-prime family construction** showing that if the first $m$ Fermat numbers $F_0,\dots,F_{m-1}$ are prime, then $N_m = \prod_{k<m} F_k$ solves $\varphi(n) = \varphi(n+1)$, with both totients equal to $2^{2^m - 1}$; (2) the unconditional consequence that $N_5 = 2^{32}-1 = 4294967295$ is a solution, and the proven conditional that an unbounded supply of all-prime Fermat prefixes forces infinitely many solutions; (3) a **counting-transfer theorem** isolating the logical core of the lower-bound strategy — any finite certified witness set below $x$ is a lower bound on $S_1^{\varphi}(x)$ — instantiated to the unconditional bounds $S_1^{\varphi}(194) \ge 6$ and $S_1^{\varphi}(975) \ge 10$; and (4) a structural analysis of solutions: collision values are even, $n+1$ is never prime, $n$ and $n+1$ are never both prime, and the folklore claim that solutions must be odd is refuted by $n=104$. All results are framed through the multiplicativity of $\varphi$ rather than opaque computation.

**Keywords:** Euler totient function, unit-shift equation, Fermat primes, Graham–Holt–Pomerance bound, counting function, multiplicativity, coprimality.

## 1. Introduction

Euler's totient function $\varphi(n)$ counts the integers in $\{1, \dots, n\}$ coprime to $n$. It is *multiplicative*: $\varphi(ab) = \varphi(a)\varphi(b)$ whenever $\gcd(a,b)=1$, and on prime powers $\varphi(p^e) = p^{e-1}(p-1)$. These two facts determine $\varphi$ completely from a prime factorization.

The behaviour of $\varphi$ across *consecutive* integers is delicate. Because $n$ and $n+1$ are coprime, they are built from disjoint sets of primes; that two such numbers should have equal totient is a nontrivial multiplicative coincidence. The set of $n$ with
$$\varphi(n) = \varphi(n+1)$$
begins $1, 3, 15, 104, 164, 194, 255, 495, 584, 975, \dots$. Understanding the density of this set is the subject of a celebrated analytic estimate.

**The Graham–Holt–Pomerance (GHP) bound.** Writing $\log_2$ for the iterated logarithm $\log\log$, the GHP upper bound states
$$S_1^{\varphi}(x) \ll x\,\exp\!\left\{-\left(\tfrac12 - o(1)\right)\sqrt{\log x \cdot \log_2 x}\,\right\}.$$
The *tightness* statement, which motivates this paper, is the matching lower bound: there exists $C > 0$ with
$$S_1^{\varphi}(x) \ge C\,x\,\exp\!\left\{-\left(\tfrac12 + o(1)\right)\sqrt{\log x \cdot \log_2 x}\,\right\}$$
for all sufficiently large $x$. The two together determine the order of magnitude of $S_1^{\varphi}$ up to the $o(1)$ in the exponent.

A complete proof of either bound requires the anatomy of integers, smooth-number estimates, and sieve methods, and is beyond the present scope. Our aim is different and complementary: we isolate, and prove rigorously, the **constructive and structural skeleton** on which the lower-bound (tightness) program rests. The lower bound is, at heart, a "construct then count" argument; we make both halves precise and give an explicit transfer theorem connecting them, together with an exact infinite-family mechanism (conditional on Fermat primality) and a full structural classification of the easy constraints on solutions.

### 1.1 Notation

- $\varphi(n)$: Euler's totient function.
- $F_k = 2^{2^k} + 1$: the $k$-th Fermat number; $F_0=3, F_1=5, F_2=17, F_3=257, F_4=65537$ are the known Fermat primes.
- $N_m = \prod_{k=0}^{m-1} F_k$: the product of the first $m$ Fermat numbers (denoted `fermatProd m`).
- $S_1^{\varphi}(x) = \#\{ n \le x : \varphi(n) = \varphi(n+1)\}$ (denoted `S1phi x`), counting $n$ with $1 \le n \le x$.

## 2. The Fermat-prime family construction

The centrepiece of the constructive side is an exact infinite family of solutions parametrized by Fermat-prime prefixes.

### 2.1 The telescoping identity and the power-of-two successor

**Lemma 2.1 (`fermatProd_succ`).** For every $m \ge 0$,
$$N_m + 1 = \prod_{k=0}^{m-1} F_k + 1 = 2^{2^m}.$$

*Proof sketch.* This is the classical Fermat telescoping identity $\prod_{k<m} F_k = 2^{2^m} - 1$, proved by induction on $m$ using $F_m = 2^{2^m}+1$ and $(2^{2^m}-1)(2^{2^m}+1) = 2^{2^{m+1}} - 1$. Adding $1$ gives the claim. $\square$

**Lemma 2.2 (`fermatNumber_sub_one`).** For every $k$, $F_k - 1 = 2^{2^k}$.

*Proof sketch.* Immediate from $F_k = 2^{2^k}+1$. $\square$

### 2.2 Both totients equal $2^{2^m - 1}$

**Lemma 2.3 (`prod_fermatNumber_sub_one`).** For every $m$,
$$\prod_{k=0}^{m-1}(F_k - 1) = \prod_{k=0}^{m-1} 2^{2^k} = 2^{\sum_{k<m} 2^k} = 2^{2^m - 1}.$$

*Proof sketch.* Substitute $F_k - 1 = 2^{2^k}$ (Lemma 2.2), collect the product of powers into a single power with exponent $\sum_{k<m} 2^k$, and evaluate the geometric sum $\sum_{k<m} 2^k = 2^m - 1$. $\square$

**Lemma 2.4 (`totient_two_pow_pow`).** For every $m$, $\varphi\!\left(2^{2^m}\right) = 2^{2^m - 1}$.

*Proof sketch.* Apply $\varphi(p^e) = p^{e-1}(p-1)$ with $p = 2$ and $e = 2^m \ge 1$, giving $2^{2^m - 1}\cdot 1$. $\square$

**Lemma 2.5 (`totient_fermatProd`).** If $F_0, \dots, F_{m-1}$ are all prime, then
$$\varphi(N_m) = \prod_{k=0}^{m-1}(F_k - 1).$$

*Proof sketch.* Induct on $m$. The Fermat numbers are pairwise coprime (classical: $F_i \mid F_j - 2$ for $i < j$, so a common divisor of $F_i, F_j$ divides $2$, but Fermat numbers are odd). Hence $N_m = N_{m-1}\cdot F_{m-1}$ is a product of coprime factors, and multiplicativity gives $\varphi(N_m) = \varphi(N_{m-1})\,\varphi(F_{m-1})$. Since $F_{m-1}$ is prime, $\varphi(F_{m-1}) = F_{m-1} - 1$; the inductive hypothesis handles $\varphi(N_{m-1})$. $\square$

**Theorem 2.6 (Fermat-prime family construction, `fermatFamily_totient_eq`).** If the first $m$ Fermat numbers are all prime, then
$$\varphi(N_m) = \varphi(N_m + 1),$$
with both sides equal to $2^{2^m - 1}$.

*Proof sketch.* By Lemma 2.5 and Lemma 2.3, $\varphi(N_m) = \prod_{k<m}(F_k-1) = 2^{2^m-1}$. By Lemma 2.1 and Lemma 2.4, $\varphi(N_m+1) = \varphi(2^{2^m}) = 2^{2^m-1}$. The two values coincide. $\square$

### 2.3 Unconditional and conditional consequences

**Corollary 2.7 (`fermatFamily_solution_2pow32`).** Since $F_0,\dots,F_4 = 3,5,17,257,65537$ are prime,
$$N_5 = 2^{32} - 1 = 4294967295$$
satisfies $\varphi(4294967295) = \varphi(4294967296) = 2^{31} = 2147483648$.

*Proof sketch.* Apply Theorem 2.6 with $m = 5$ after verifying the five base primalities, and evaluate $N_5 = \prod_{k<5} F_k = 2^{32}-1$. $\square$

**Lemma 2.8 (`le_fermatProd`).** For every $m$, $m \le N_m$.

*Proof sketch.* From $N_m + 1 = 2^{2^m}$ and $m + 1 \le 2^m \le 2^{2^m}$ (using $m < 2^m$ twice), conclude $m \le N_m$. This turns an unbounded supply of *indices* into an unbounded supply of *solutions of unbounded size*. $\square$

**Theorem 2.9 (Conditional infinitude, `infinite_solutions_of_infinitely_many_fermat_initial_segments`).** Suppose that for every $M$ there exists $m > M$ with $F_0, \dots, F_{m-1}$ all prime. Then
$$\{\, n : \varphi(n) = \varphi(n+1)\,\}$$
is infinite.

*Proof sketch.* It suffices to exhibit, for each $M$, a solution exceeding $M$. Given $M$, choose $m > M$ with all of $F_0,\dots,F_{m-1}$ prime. Then $N_m$ is a solution by Theorem 2.6, and $N_m \ge m > M$ by Lemma 2.8. Hence the solution set is unbounded, so infinite. $\square$

This is a *proven implication*; only its hypothesis (infinitely many all-prime Fermat prefixes) is open. It cleanly exhibits one classical open problem as the sole missing input to another.

## 3. Structural constraints on solutions

We record the elementary structure theory of the solution set; these constraints explain the sparsity of solutions and correct a piece of folklore.

**Lemma 3.1 (`coprime_self_succ`).** For every $n$, $\gcd(n, n+1) = 1$.

*Proof sketch.* Any common divisor divides $(n+1) - n = 1$. $\square$

**Lemma 3.2 (Parity of collision values, `totient_shift_value_even`).** If $n \ge 2$ and $\varphi(n) = \varphi(n+1)$, then $\varphi(n)$ is even.

*Proof sketch.* Rewriting along the collision, $\varphi(n) = \varphi(n+1)$ with $n+1 \ge 3$; and $\varphi(m)$ is even for all $m \ge 3$ (a standard fact: $m$ has a prime factor $p$ with $p-1$ even, or $4 \mid m$). Hence $\varphi(n)$ is even. The hypothesis is essential: $\varphi(2)=1$ is odd, but $\varphi(2) \ne \varphi(3)$. $\square$

**Lemma 3.3 (`succ_not_prime_of_shift`).** If $n \ge 2$ and $\varphi(n) = \varphi(n+1)$, then $n+1$ is not prime.

*Proof sketch.* If $n+1$ were prime, $\varphi(n+1) = n$. But $\varphi(n) \le n - 1 < n$ for $n \ge 2$, contradicting the collision. $\square$

**Lemma 3.4 (`not_both_prime_of_shift`).** For $n \ge 3$, $n$ and $n+1$ are never both prime. In particular at a solution they are not both prime.

*Proof sketch.* One of two consecutive integers $\ge 3$ is even and $> 2$, hence composite. $\square$

**Remark 3.5 (A false folklore rule, `even_solution_counterexample`).** It is sometimes claimed that any solution $n$ must be odd. This is false: $n = 104 = 2^3\cdot 13$ is even and
$$\varphi(104) = 2^2\cdot 12 = 48 = (3-1)(5-1)(7-1) = \varphi(105).$$
Thus oddness is *not* a theorem and must not be assumed.

## 4. The counting function and the transfer theorem

We now turn to the counting function $S_1^{\varphi}$ and the logical core of the tightness (lower-bound) program.

**Definition 4.1 (`S1phi`).**
$$S_1^{\varphi}(x) = \#\{\, n : 1 \le n \le x,\ \varphi(n) = \varphi(n+1)\,\}.$$

**Lemma 4.2 (Monotonicity, `S1phi_mono`).** If $x \le y$ then $S_1^{\varphi}(x) \le S_1^{\varphi}(y)$.

*Proof sketch.* The collision-filtered interval $[1,x]$ is a subset of that for $[1,y]$; cardinality is monotone under inclusion. $\square$

**Lemma 4.3 (Trivial ceiling, `S1phi_le_self`).** $S_1^{\varphi}(x) \le x$.

*Proof sketch.* The filtered set is a subset of $\{1,\dots,x\}$, which has $x$ elements. $\square$

**Lemma 4.4 (Strict non-saturation, `S1phi_lt_self`).** For $x \ge 2$, $S_1^{\varphi}(x) < x$.

*Proof sketch.* $n = 2$ lies in $\{1,\dots,x\}$ but is not a collision ($\varphi(2)=1 \ne 2 = \varphi(3)$), so the filtered set is a *proper* subset of $\{1,\dots,x\}$; strict cardinality inequality follows. The parity law (Lemma 3.2) explains why such non-collisions are in fact abundant, so the trivial bound is far from tight. $\square$

**Theorem 4.5 (Counting-transfer theorem, `S1phi_ge_card`).** Let $W$ be a finite set of integers with, for every $w \in W$: $1 \le w \le x$ and $\varphi(w) = \varphi(w+1)$. Then
$$|W| \le S_1^{\varphi}(x).$$

*Proof sketch.* Each $w \in W$ lies in the collision-filtered interval defining $S_1^{\varphi}(x)$; hence $W$ is a subset of that set, and $|W| \le S_1^{\varphi}(x)$ by monotonicity of cardinality. $\square$

This theorem is the formal embodiment of the GHP lower-bound strategy: it converts *any* density-producing construction of certified witnesses directly into a lower bound on $S_1^{\varphi}$. The analytic difficulty of the full tightness theorem is entirely concentrated in producing a *dense* witness family; the bookkeeping is exactly Theorem 4.5.

### 4.1 Explicit unconditional lower bounds

The witnesses are certified by genuine multiplicative computation (Section 5), and Theorem 4.5 turns them into bounds.

**Theorem 4.6 (`S1phi_ge_six`).** $S_1^{\varphi}(194) \ge 6$, certified by $W = \{1, 3, 15, 104, 164, 194\}$.

**Theorem 4.7 (`S1phi_ge_ten`).** $S_1^{\varphi}(975) \ge 10$, certified by $W = \{1, 3, 15, 104, 164, 194, 255, 495, 584, 975\}$.

*Proof sketch (both).* Verify $1 \le w \le x$ and $\varphi(w) = \varphi(w+1)$ for each $w \in W$ (Section 5), then apply Theorem 4.5 and compute $|W|$. $\square$

## 5. Multiplicative certification of witnesses

Each witness is proved by factoring $n$ and $n+1$ into coprime prime powers and applying multiplicativity, *not* by opaque enumeration. The recurring phenomenon is a balance between a power of two and a product of small odd primes.

| $n$ | factorization of $n$ | factorization of $n+1$ | common $\varphi$ | lemma |
|----:|---------------------|------------------------|------------------|-------|
| 15 | $3\cdot 5$ | $2^4$ | 8 | `ghp_15` |
| 104 | $2^3\cdot 13$ | $3\cdot 5\cdot 7$ | 48 | `ghp_104` |
| 164 | $2^2\cdot 41$ | $3\cdot 5\cdot 11$ | 80 | `ghp_164` |
| 194 | $2\cdot 97$ | $3\cdot 5\cdot 13$ | 96 | `ghp_194` |
| 255 | $3\cdot 5\cdot 17$ | $2^8$ | 128 | `ghp_255` |
| 495 | $3^2\cdot 5\cdot 11$ | $2^4\cdot 31$ | 240 | `ghp_495` |
| 584 | $2^3\cdot 73$ | $3^2\cdot 5\cdot 13$ | 288 | `ghp_584` |
| 975 | $3\cdot 5^2\cdot 13$ | $2^4\cdot 61$ | 480 | `ghp_975` |

**Representative computation (`ghp_255`).** $255 = 3\cdot 5\cdot 17$ with pairwise coprime prime factors, so
$$\varphi(255) = (3-1)(5-1)(17-1) = 2\cdot 4\cdot 16 = 128,$$
while $256 = 2^8$ gives $\varphi(256) = 2^7 = 128$. The two match, certifying $n=255$. The other rows are analogous, using $\varphi(p^e)=p^{e-1}(p-1)$ on the prime-power factors.

## 6. Discussion

The mathematics splits naturally into four strata of increasing depth:

1. **Build by hand.** The Fermat construction (Theorem 2.6) and the multiplicative witnesses (Section 5) produce solutions explicitly. The Fermat mechanism is *self-similar*: the exponent doubling $2^k \mapsto 2^{k+1}$ telescopes the product into a single power of two, and the matching totient is forced.
2. **Constrain.** The parity law (Lemma 3.2) and primality obstructions (Lemmas 3.3–3.4) restrict the shape of solutions and, crucially, explain why $S_1^{\varphi}(x)$ stays strictly below its trivial ceiling (Lemma 4.4).
3. **Transfer.** Theorem 4.5 cleanly separates construction from counting, reducing the entire lower-bound program to producing dense witness families. This is the reusable engine.
4. **Measure (deep / external).** The GHP asymptotic and its tightness require analytic machinery (smooth numbers, sieves) not developed here. The constructive skeleton is exactly what those analytic methods feed into.

A methodological point: by certifying witnesses through multiplicativity rather than brute force, each $\varphi(n)=\varphi(n+1)$ is exhibited as *structural* — a solved Diophantine balance between a $2$-adic valuation and a ratio of odd-prime contributions — rather than a numerical accident. This is the same structural content that any parametric collision family would need to exploit.

## 7. Future work

Three directions extend the constructive program:

- **A second one-parameter family.** Beyond Fermat-prime prefixes, seek an infinite family of the shape $\varphi(2^a m) = \varphi(2^b m')$ with $m, m'$ products of distinct small odd primes chosen so the prime-deleted factor $\prod(1 - 1/p)$ matches across a controlled power-of-two carry. The finite witnesses $104, 164, 194, 495, 584, 975$ are instances. Because $\varphi$ depends only on the multiset of distinct prime factors, such a collision is a parametrizable lattice condition, and certification reduces to one coprimality lemma plus a finite check per parameter.
- **Effective polynomial lower bound.** Prove $S_1^{\varphi}(x) \ge x^c$ for an explicit $c > 0$ and all $x \ge x_0$, a constructive shadow of the GHP bound. Theorem 4.5 reduces this to producing a constructive family whose counting function is bounded below by a power of $x$.
- **Unconditional infinitude.** Replace the (finite, unknown) supply of Fermat primes by a proven-infinite supply of admissible balancing primes so the Fermat telescoping (or a self-similar carry analogue) runs forever, yielding $S_1^{\varphi}(x) \to \infty$ unconditionally.

## 8. Conclusion

We have formalized the constructive and structural backbone of the tightness statement for the unit-shift totient bound: an exact Fermat-prime family of solutions with both totients equal to $2^{2^m-1}$, an unconditional ten-digit solution $2^{32}-1$, a proven conditional infinitude, a complete elementary structure theory (parity, primality, and a corrected folklore claim), and a counting-transfer theorem that converts certified witnesses into explicit unconditional lower bounds $S_1^{\varphi}(194) \ge 6$ and $S_1^{\varphi}(975) \ge 10$. The remaining gap to the full tightness theorem is precisely the production of a dense infinite witness family — the analytic heart of the Graham–Holt–Pomerance result, and the frontier this skeleton is built to support.
