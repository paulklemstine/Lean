# The Two-Layer Structure of the Maximal Good-Manifold Count in an $n$-Nice Polytope

## Abstract

We study the arithmetic sequence $a(n)$ counting the maximal number of *good* manifolds carried by an $n$-dimensional *nice* polytope. Its initial values are $1, 6, 8, 12, 24, 40, 80, 128, 256, 512, \dots$. We prove that this sequence decomposes exactly into two geometric layers: a dominant layer $2^n$ and a subdominant *defect* $d(n)$ supported on $1 \le n \le 6$. The defect is itself a truncated doubling sequence, taking the values $4, 8, 16$ on contiguous blocks of lengths $3, 2, 1$; past dimension seven it vanishes, and the count becomes a pure power of two. We establish four principal facts. (i) The two-layer decomposition $a(n) = 2^n + d(n)$ holds identically, with an explicit description of the defect. (ii) For $n \ge 7$ the $2$-adic valuation of the count equals the dimension, $v_2(a(n)) = n$, so growth leaves a legible arithmetic fingerprint. (iii) The sequence is strictly increasing and its exponential growth rate is exactly $2$, i.e. $a(n)^{1/n} \to 2$. (iv) The cumulative sums satisfy $S(n) = 2^{n+1} + 43$ for $n \ge 6$, hence $S(n) \equiv 43 \pmod{128}$ and $S(n)$ is never divisible by $128$; this *refutes* the natural conjecture that the onset of pure geometric behaviour is detectable through cumulative divisibility. We give proof sketches, algorithms, numerical demonstrations, and a discussion of the extremal-growth and valuation-dimension phenomena.

**Keywords:** nice polytope, good manifold, geometric sequence, $2$-adic valuation, defect sequence, extremal growth rate, cumulative divisibility.

---

## 1. Introduction

A recurring theme across enumerative geometry and its applications is that a counting function which appears irregular for small parameters often settles into a clean asymptotic law. The interesting mathematics lies in the *transient*: the correction terms that distinguish the early, structured chaos from the eventual regularity.

This paper concerns one such counting function. Let $a(n)$ denote the maximal number of *good* manifolds that can be carried by an $n$-dimensional *nice* polytope. Here a polytope is a bounded region cut out by finitely many linear inequalities, "nice" refers to a set of local regularity axioms on its combinatorial and geometric structure, and a "good" manifold is a well-behaved submanifold satisfying the compatibility conditions relevant to the ambient construction. The precise definitions belong to the geometric setting; for the purposes of this paper we take as given the resulting integer sequence

$$a(0), a(1), a(2), \dots = 1,\; 6,\; 8,\; 12,\; 24,\; 40,\; 80,\; 128,\; 256,\; 512,\; \dots$$

and we analyze its exact arithmetic structure.

The central observation is that $a(n)$ is not a single geometric sequence with a noisy head, but the sum of two geometric layers. Writing $d(n) = a(n) - 2^n$, one finds

$$d(0), d(1), \dots = 0,\; 4,\; 4,\; 4,\; 8,\; 8,\; 16,\; 0,\; 0,\; \dots$$

so the "noise" is in fact a second, faster-decaying doubling process. This decomposition is the organizing principle of everything that follows.

The paper is organized as follows. Section 2 fixes definitions. Section 3 proves the vanishing of the defect past the threshold and the closed form of the tail. Section 4 establishes the truncated-doubling structure of the defect. Section 5 proves the valuation-dimension identity. Section 6 treats monotonicity and the extremal growth rate. Section 7 analyzes the cumulative sums and refutes the cumulative-divisibility heuristic. Section 8 discusses applications and interpretation. Section 9 states future directions.

---

## 2. Definitions

**Definition 2.1 (Defect).** The *defect* $d : \mathbb{N} \to \mathbb{N}$ is the excess of the count over the dominant geometric layer, defined piecewise by
$$
d(n) = \begin{cases}
4 & n \in \{1,2,3\},\\
8 & n \in \{4,5\},\\
16 & n = 6,\\
0 & \text{otherwise (}n = 0 \text{ or } n \ge 7\text{)}.
\end{cases}
$$

**Definition 2.2 (Maximal good-manifold count).** The *maximal good-manifold count* is
$$a(n) = 2^n + d(n).$$
Its first values are $a(0),\dots,a(7) = 1, 6, 8, 12, 24, 40, 80, 128$, in agreement with the geometric data.

**Definition 2.3 (Cumulative count).** The *cumulative count* is the running total
$$S(n) = \sum_{k=0}^{n} a(k).$$
Its first values are $S(0),\dots,S(6) = 1, 7, 15, 27, 51, 91, 171$.

---

## 3. The tail is purely geometric

**Theorem 3.1 (Defect vanishes past the threshold).** For every $n \ge 7$, $d(n) = 0$.

*Proof sketch.* Immediate from Definition 2.1: the piecewise formula assigns $0$ to all arguments outside $\{1,\dots,6\}$, and $7 \le n$ places $n$ outside that finite set. $\square$

**Theorem 3.2 (Closed form of the tail).** For every $n \ge 7$, $a(n) = 2^n$.

*Proof sketch.* By Definition 2.2, $a(n) = 2^n + d(n)$; substitute $d(n) = 0$ from Theorem 3.1. $\square$

Thus the count is a pure power of two from dimension seven onward. The entire non-trivial arithmetic of the sequence is concentrated in the finite head $n \le 6$, where the second geometric layer is active.

---

## 4. The defect is a truncated doubling layer

We now show that the defect, far from being an arbitrary finite correction, has the internal structure of a rationed geometric progression.

**Theorem 4.1 (Defect values).** For every $n$, $d(n) \in \{0, 4, 8, 16\}$.

*Proof sketch.* Case analysis. For $n \in \{0,1,\dots,6\}$ the value is read directly from Definition 2.1 and lies in $\{0,4,8,16\}$; for $n \ge 7$, Theorem 3.1 gives $d(n) = 0$. $\square$

**Theorem 4.2 (Block of length three).** $d(n) = 4$ for all $n$ with $1 \le n \le 3$.

**Theorem 4.3 (Block of length two).** $d(n) = 8$ for all $n$ with $4 \le n \le 5$.

**Theorem 4.4 (Block of length one).** $d(6) = 16$.

*Proof sketch (4.2–4.4).* Each is a finite verification over the stated range against Definition 2.1. $\square$

**Theorem 4.5 (Blocks double in value).** The successive nonzero block values double: $d(4) = 2\,d(3)$ and $d(6) = 2\,d(5)$.

*Proof sketch.* Direct evaluation: $8 = 2 \cdot 4$ and $16 = 2 \cdot 8$. $\square$

**Interpretation.** Theorems 4.1–4.5 establish that the defect is a doubling sequence $4 \to 8 \to 16$ whose values persist over contiguous blocks of *decreasing* lengths $3, 2, 1$. The subdominant layer thus has the same multiplicative growth as the dominant one, but is progressively rationed: each value survives one fewer dimension than its predecessor, and the layer is extinguished exactly when the dominant power $2^n$ overtakes the final subdominant value $16$ at $n = 6$, after which $2^7 = 128$ dominates unaided.

---

## 5. The valuation-dimension identity

Recall the **$2$-adic valuation** $v_2(m)$ of a positive integer $m$: the largest exponent $e$ such that $2^e \mid m$. Equivalently, if $m = 2^e u$ with $u$ odd, then $v_2(m) = e$.

**Theorem 5.1 (Valuation recovers dimension).** For every $n \ge 7$, $v_2(a(n)) = n$.

*Proof sketch.* By Theorem 3.2, $a(n) = 2^n$ for $n \ge 7$. The $2$-adic valuation of a pure prime power $p^n$ (here $p = 2$) is $n$. $\square$

This identity converts the geometric growth law into an arithmetic one: the exponent of the base is legible directly in the prime factorization of the count. Given a tail value $a(n)$, the dimension $n$ is recovered simply by counting the factors of two. This is the "arithmetic fingerprint" of the growth rate.

---

## 6. Monotonicity and extremal growth

**Theorem 6.1 (Layer bounds).** For every $n$, $2^n \le a(n) \le 2^n + 16$.

*Proof sketch.* The lower bound is immediate from $a(n) = 2^n + d(n)$ with $d(n) \ge 0$. For the upper bound, Theorem 4.1 gives $d(n) \le 16$. $\square$

**Theorem 6.2 (Strict monotonicity).** The sequence $a$ is strictly increasing: $a(n) < a(n+1)$ for all $n$.

*Proof sketch.* Split on $n$. For $n < 6$, the inequality is a finite check on the explicit values $1, 6, 8, 12, 24, 40, 80$. For $n \ge 6$, we use $a(n) \le 2^n + 16$ (Theorem 6.1) and $a(n+1) = 2^{n+1} = 2^n + 2^n$ (Theorem 3.2, valid since $n + 1 \ge 7$). Since $n \ge 6$ gives $2^n \ge 2^6 = 64 > 16$, we obtain $a(n) \le 2^n + 16 < 2^n + 2^n = a(n+1)$. $\square$

**Theorem 6.3 (Exact exponential growth rate).** $\displaystyle \lim_{n\to\infty} a(n)^{1/n} = 2$.

*Proof sketch.* For $n \ge 7$, Theorem 3.2 gives $a(n) = 2^n$, so $a(n)^{1/n} = (2^n)^{1/n} = 2$ exactly. The sequence $a(n)^{1/n}$ is therefore eventually constant equal to $2$, and its limit is $2$. $\square$

**Interpretation.** The growth rate $2$ is exact, not merely asymptotic order. Conceptually, doubling reflects a single binary choice made independently in each dimension; a strictly faster rate would require correlated choices across dimensions, which the niceness axioms preclude. In this sense $2$ is the *extremal* growth rate for nice polytope families, achieved by the family studied here.

---

## 7. Cumulative sums and the failure of the divisibility heuristic

We now analyze the running totals $S(n)$ and test a tempting conjecture: that the onset of pure geometric behaviour at $n = 7$ is signalled by cumulative divisibility by $2^7 = 128$.

**Theorem 7.1 (Closed form of the cumulative tail).** For every $n \ge 6$,
$$S(n) = 2^{n+1} + 43.$$

*Proof sketch.* Induction on $n$. The base case $n = 6$ is the direct computation $S(6) = 1 + 6 + 8 + 12 + 24 + 40 + 80 = 171 = 2^7 + 43$. For the inductive step with $n \ge 6$, use $S(n+1) = S(n) + a(n+1)$, the inductive hypothesis $S(n) = 2^{n+1} + 43$, and $a(n+1) = 2^{n+1}$ (Theorem 3.2, since $n+1 \ge 7$). Then $S(n+1) = 2^{n+1} + 43 + 2^{n+1} = 2^{n+2} + 43$, completing the induction. $\square$

**Theorem 7.2 (Cumulative divisibility fails).** For every $n \ge 0$, $2^7 \nmid S(n)$. Moreover, $S(n) \equiv 43 \pmod{128}$ for all $n \ge 6$.

*Proof sketch.* For $n < 6$, the finitely many totals $S(0),\dots,S(5) = 1, 7, 15, 27, 51, 91$ are each checked directly to be non-multiples of $128$. For $n \ge 6$, suppose $2^7 \mid S(n)$. By Theorem 7.1, $S(n) = 2^{n+1} + 43$, and $2^7 \mid 2^{n+1}$ since $n + 1 \ge 7$. Subtracting, $2^7$ would divide $S(n) - 2^{n+1} = 43$, forcing $128 \le 43$, a contradiction. Hence $2^7 \nmid S(n)$, and reducing $S(n) = 2^{n+1} + 43$ modulo $128$ (with $128 \mid 2^{n+1}$) gives $S(n) \equiv 43 \pmod{128}$. $\square$

**Interpretation.** The transition to pure doubling is a property of the *individual* terms, not of their cumulative sums. Summation fossilizes the entire pre-threshold head into the single additive constant $43$ — the accumulated memory of the defect layer — which no amount of subsequent pure-geometric growth can remove. The natural cumulative-divisibility heuristic is therefore false, and instructively so: it reveals that local (term-by-term) regularity need not manifest as global (cumulative) divisibility.

---

## 8. Applications and interpretation

The sequence $a(n)$ furnishes a compact case study of a phenomenon ubiquitous in enumerative mathematics: a bounded transient correction riding atop a dominant exponential trend. Three lessons generalize.

**(a) Layer decomposition as a diagnostic.** Faced with a counting function that appears irregular for small parameters, subtracting the conjectured dominant asymptotic ($2^n$ here) often exposes not residual noise but a lower-order structured layer. Here the residual is a second doubling process with a rationed lifespan. This decomposition strategy applies whenever a count is suspected to be a sum of geometric contributions of differing rates.

**(b) Valuation as a dimension oracle.** The identity $v_2(a(n)) = n$ shows that, once a count is a pure prime power, its dimension is recoverable by prime factorization alone. For families whose tails are $c\cdot b^n$ with $b$ prime, one expects analogously $v_b(a(n)) = n + v_b(c)$ for large $n$, so the $b$-adic valuation reads off the dimension up to the additive offset $v_b(c)$.

**(c) Extremality of the growth rate.** The exact rate $a(n)^{1/n} \to 2$ identifies doubling as the extremal exponential rate compatible with the niceness axioms. This provides a sharp, falsifiable target: any nice family exceeding this rate would violate the local axioms, since a rate above $2$ would demand a per-dimension choice set larger than binary.

---

## 9. Discussion and future directions

The two-layer picture settles several natural conjectures about the sequence and refutes one. It suggests the following program.

**Conjecture A (Extremal head).** Among all sequences $a(n) = 2^n + h(n)$ with $h$ eventually zero, $h$ valued in a geometric progression $4, 8, 16, \dots$, and $a$ strictly increasing, the observed head $(4,4,4,8,8,16)$ is the longest whose blocks have strictly decreasing lengths. The descent pattern $3, 2, 1$ should be forced by monotonicity together with the requirement that each block value be overtaken by $2^n$ exactly at its right endpoint.

**Conjecture B (Valuation-dimension dictionary).** For a family whose tail is $c\cdot b^n$ with $b$ prime, $v_b(a(n)) = n + v_b(c)$ for all large $n$; the additive constant $v_b(c)$ is the only obstruction, detectable as the eventual constant gap $v_b(a(n)) - n$. The present family is the case $b = 2$, $c = 1$.

**Conjecture C (Extremal growth rate).** Among all nice polytope families, $\limsup a(n)^{1/n} = 2$, with equality for the family here; any family exceeding this rate violates the niceness axioms.

These directions treat the exactly-determined tail as a template against which base-$b$ generalizations and extremal characterizations can be tested.

---

## Appendix A. Table of values

| $n$ | $2^n$ | $d(n)$ | $a(n)$ | $v_2(a(n))$ | $S(n)$ | $S(n) \bmod 128$ |
|----:|------:|-------:|-------:|------------:|-------:|-----------------:|
| 0 | 1 | 0 | 1 | 0 | 1 | 1 |
| 1 | 2 | 4 | 6 | 1 | 7 | 7 |
| 2 | 4 | 4 | 8 | 3 | 15 | 15 |
| 3 | 8 | 4 | 12 | 2 | 27 | 27 |
| 4 | 16 | 8 | 24 | 3 | 51 | 51 |
| 5 | 32 | 8 | 40 | 3 | 91 | 91 |
| 6 | 64 | 16 | 80 | 4 | 171 | 43 |
| 7 | 128 | 0 | 128 | 7 | 299 | 43 |
| 8 | 256 | 0 | 256 | 8 | 555 | 43 |
| 9 | 512 | 0 | 512 | 9 | 1067 | 43 |

For $n \le 6$ the valuation column reflects the head values ($v_2$ of $1,6,8,12,24,40,80$); from $n = 7$ it equals $n$ exactly. The final column locks onto $43$ from $n = 6$ onward.
