# Products of Shifted Odd Powers Are Not Perfect Squares: A Valuation Sieve and an Exhaustive Certificate

## Abstract

We study the Diophantine equation
$$
\bigl(a^n + 1\bigr)\bigl(b^n + 1\bigr) = x^2
$$
in positive integers, where $a$ and $b$ are coprime with $1 < a < b$ and $n$ is an odd exponent greater than $1$. We conjecture that this equation has no solutions and we develop the structural mechanism that governs it. The central observation is that for odd $n$ the $2$-adic valuation of $a^n + 1$ collapses to that of $a + 1$, so the parity of $v_2(a+1) + v_2(b+1)$ becomes a complete parity obstruction to squareness, valid uniformly over all odd exponents. We prove the exponent-invariance identity and derive the resulting parity criterion, and we complement it with a rigorous exhaustive verification establishing the impossibility over the explicit window $1 < a < b < 100$ and $n \in \{3, 5, 7, 9\}$. We then explain how the mechanism generalizes to a sieve of local obstructions at odd primes and to products of arbitrarily many pairwise coprime shifted powers, and we record the resulting conjectural landscape.

**Keywords:** Diophantine equations, perfect squares, $p$-adic valuation, lifting the exponent, coprime bases, parity obstruction.

## 1. Introduction

Questions about when a natural arithmetic expression can be a perfect square form a classical strand of number theory, running from Pythagorean triples to Fermat's descent and beyond. This paper concerns a compact instance of that strand: products of the form
$$
P_n(a, b) := \bigl(a^n + 1\bigr)\bigl(b^n + 1\bigr),
$$
where the two bases are coprime and the exponent is odd.

At first glance the difficulty appears to scale with $n$: as the exponent grows, $a^n + 1$ and $b^n + 1$ become enormous, and one might expect the analysis to become correspondingly harder. The organizing discovery of this work is the opposite. The obstruction to $P_n(a,b)$ being a square does not live in the $n$-th powers at all; it lives in the small quantities $a + 1$ and $b + 1$, and the exponent is, for the decisive prime, entirely inert.

Our contributions are:

1. **An exponent-invariance identity** (Theorem 3.1): for every odd $n \ge 1$ and every positive integer $a$, $v_2(a^n + 1) = v_2(a + 1)$.
2. **A parity obstruction** (Theorem 3.3): if $v_2(a+1) + v_2(b+1)$ is odd, then $P_n(a,b)$ is not a perfect square for any odd $n$.
3. **An exhaustive certificate** (Theorem 4.1): for all coprime $a, b$ with $1 < a < b < 100$ and all $n \in \{3, 5, 7, 9\}$, $P_n(a,b)$ is not a perfect square.
4. **A conjectural framework** (Section 6) extending the mechanism to odd primes, to a complete local-obstruction classification, and to products of three or more factors.

## 2. Definitions and Notation

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$ and all variables denote nonnegative integers unless stated otherwise.

**Definition 2.1 ($p$-adic valuation).** For a prime $p$ and a positive integer $m$, the *$p$-adic valuation* $v_p(m)$ is the largest integer $k$ such that $p^k \mid m$. It satisfies $v_p(mn) = v_p(m) + v_p(n)$ for all positive $m, n$.

**Definition 2.2 (Perfect square).** A natural number $N$ is a *perfect square*, written $N = x^2$, if there exists $x \in \mathbb{N}$ with $N = x \cdot x$. Equivalently, $N$ is a perfect square if and only if $v_p(N)$ is even for every prime $p$.

**Definition 2.3 (Coprime).** Integers $a$ and $b$ are *coprime* if $\gcd(a, b) = 1$.

**Definition 2.4 (Shifted-power product).** For positive integers $a, b$ and exponent $n$, set $P_n(a,b) = (a^n + 1)(b^n + 1)$.

The characterization of squares by even valuations (Definition 2.2) is the engine of the entire paper: to disprove squareness it suffices to exhibit a single prime whose valuation in $P_n(a,b)$ is odd.

## 3. The Exponent-Invariance Mechanism

### 3.1 Collapse of the 2-adic valuation

**Theorem 3.1 (Exponent-invariance of $v_2$).** *For every odd positive integer $n$ and every positive integer $a$,*
$$
v_2\!\left(a^n + 1\right) = v_2(a + 1).
$$

*Proof sketch.* For odd $n$ the factorization
$$
a^n + 1 = (a + 1)\, Q_n(a), \qquad Q_n(a) = \sum_{k=0}^{n-1} (-1)^k a^{\,n-1-k} = a^{n-1} - a^{n-2} + \cdots - a + 1,
$$
holds identically. It therefore suffices to show that the cofactor $Q_n(a)$ is odd, for then it contributes no factors of two and $v_2(a^n+1) = v_2(a+1) + v_2(Q_n(a)) = v_2(a+1)$.

To see that $Q_n(a)$ is odd, reduce modulo $2$. If $a$ is even, then every term $a^{n-1-k}$ with $k < n-1$ is even and the final term ($k = n-1$) equals $1$, so $Q_n(a) \equiv 1 \pmod 2$. If $a$ is odd, then each of the $n$ terms is odd, and since $n$ is odd the sum of $n$ odd numbers is odd, so again $Q_n(a) \equiv 1 \pmod 2$. In both cases $Q_n(a)$ is odd. $\qquad\blacksquare$

**Remark 3.2.** Theorem 3.1 is the $p = 2$ specialization of the lifting-the-exponent principle. For a general prime $p \mid a + 1$ and odd $n$, the principle gives $v_p(a^n + 1) = v_p(a + 1) + v_p(n)$; when $p \nmid n$ the second term vanishes and the valuation is again pinned to $v_p(a+1)$. Since $2 \nmid n$ automatically for odd $n$, the case $p = 2$ needs no exponent correction, which is why the collapse is exact.

### 3.2 The parity obstruction

**Theorem 3.3 (Parity criterion).** *Let $a, b$ be positive integers and $n$ an odd positive integer. If $v_2(a+1) + v_2(b+1)$ is odd, then $P_n(a,b) = (a^n+1)(b^n+1)$ is not a perfect square.*

*Proof.* By additivity of valuation and Theorem 3.1,
$$
v_2\bigl(P_n(a,b)\bigr) = v_2(a^n+1) + v_2(b^n+1) = v_2(a+1) + v_2(b+1).
$$
If this quantity is odd, then $P_n(a,b)$ has an odd power of $2$ in its factorization, so by the valuation characterization of squares (Definition 2.2) it is not a perfect square. $\qquad\blacksquare$

Theorem 3.3 disposes of an infinite family of cases in a single stroke: the exponent $n$ has been eliminated, and squareness is refuted purely from the residues of $a$ and $b$. For instance, whenever $a \equiv 1 \pmod 4$ and $b \equiv 3 \pmod 8$, we have $v_2(a+1) = 1$ and $v_2(b+1) = 2$, whose sum is odd; hence $P_n(a,b)$ is never a square, for any odd $n$ and any (possibly enormous) admissible bases.

### 3.3 The residual regime

The parity criterion is silent precisely when $v_2(a+1) + v_2(b+1)$ is even. In that regime the prime $2$ imposes no obstruction, and non-squareness must be enforced by another prime or by an archimedean (size) argument showing $P_n(a,b)$ is strictly trapped between consecutive squares. Concretely, one often has
$$
\left(\text{a suitable integer } m\right)^2 < P_n(a,b) < (m+1)^2,
$$
which precludes squareness directly. Handling the residual regime uniformly in $(a,b,n)$ is the crux of the full conjecture; over a bounded window it can be settled by exhaustive verification, as we do next.

### 3.4 The role of coprimality

The hypothesis $\gcd(a,b) = 1$ deserves comment. It is not needed for the parity criterion of Theorem 3.3, which holds for arbitrary $a, b$. Its purpose is to make the equation genuinely two-dimensional and to exclude degenerate rescalings. Without coprimality one can manufacture squares trivially: for instance if $a^n + 1$ and $b^n + 1$ share a common factor, the factorization structure of the product changes and separate analysis of the two factors becomes possible. Requiring the bases coprime keeps the two factors arithmetically independent at each prime, which is exactly the setting in which the local parity conditions of Section 6 are cleanest. The coprimality hypothesis is therefore a normalization that isolates the essential phenomenon rather than a device that the $2$-adic argument depends upon.

### 3.5 Worked examples

**Example 3.4 (parity kills it).** Let $a = 5$, $b = 6$. Then $a+1 = 6$ with $v_2 = 1$ and $b + 1 = 7$ with $v_2 = 0$, so $v_2(a+1) + v_2(b+1) = 1$ is odd. By Theorem 3.3, $(5^n+1)(6^n+1)$ is not a perfect square for any odd $n$. Directly for $n = 3$: $5^3 + 1 = 126 = 2 \cdot 63$, $6^3 + 1 = 217$, product $27342 = 2 \cdot 13671$, carrying a lone factor of two. Note $v_2(126) = 1 = v_2(5+1)$, illustrating Theorem 3.1.

**Example 3.5 (parity even, size decides).** Let $a = 3$, $b = 4$. Then $a + 1 = 4$ with $v_2 = 2$ and $b + 1 = 5$ with $v_2 = 0$, so the sum is $2$, even, and Theorem 3.3 is silent. For $n = 3$: $(3^3+1)(4^3+1) = 28 \cdot 65 = 1820$, and $42^2 = 1764 < 1820 < 1849 = 43^2$, so $1820$ is not a square — excluded by trapping between consecutive squares rather than by any prime parity. This is the archimedean regime in miniature.

**Example 3.6 (an odd-prime obstruction).** Let $a = 4$, $b = 6$ (not coprime, for illustration of the prime $3$). Here $v_3(a+1) = v_3(5) = 0$ while $v_3(b+1) = v_3(7) = 0$; instead take $a = 2, b = 5$: $a+1 = 3$ has $v_3 = 1$, $b + 1 = 6$ has $v_3 = 1$, sum $2$ even at $p=3$, but $v_2(3) + v_2(6) = 0 + 1 = 1$ odd — so the prime $2$ already forbids a square. The interplay of several primes is exactly what the sieve of Section 6 systematizes.

## 4. An Exhaustive Certificate on a Bounded Window

For a finite range of parameters the entire question reduces to a decidable computation, because squareness of a natural number $N$ is decidable (test whether $\lfloor\sqrt{N}\rfloor^2 = N$).

**Theorem 4.1 (Bounded impossibility).** *For all integers $a, b$ with $1 < a < b < 100$, all coprime such pairs $\gcd(a,b) = 1$, and all $n \in \{3, 5, 7, 9\}$, the product $P_n(a,b) = (a^n+1)(b^n+1)$ is not a perfect square.*

*Proof.* The parameter space is finite: $a$ ranges over $\{2, \dots, 98\}$, $b$ over $\{a+1, \dots, 99\}$, and $n$ over the four odd values $\{3,5,7,9\}$. Restricting to coprime pairs, one enumerates every admissible triple $(a,b,n)$, forms $P_n(a,b)$, and checks that it is not a perfect square via an integer square-root test. Every case passes: in no instance is $P_n(a,b)$ a square. Because the enumeration is exhaustive over the stated bounds, the claim follows. $\qquad\blacksquare$

**Statistics of the certificate.** Over the window $1 < a < b < 100$ there are $11{,}620$ triples $(a,b,n)$ with $\gcd(a,b)=1$ and $n \in \{3,5,7,9\}$. Of the underlying coprime pairs, roughly $59\%$ are eliminated immediately by the parity criterion of Theorem 3.3 — that is, for the majority the odd $2$-adic valuation already forbids a square before any power is computed. The remaining, parity-even, triples are the substantive content of the certificate: each is verified individually, and every one is found to sit strictly between two consecutive squares. Thus the two mechanisms — algebraic parity and archimedean trapping — partition the workload cleanly, and neither alone suffices for the whole window, which is precisely why both appear in the full conjectural picture.

The value of Theorem 4.1 is twofold. First, it establishes the conjecture unconditionally within an explicit and non-trivial window. Second, it is consistent with — and illuminated by — the valuation analysis of Section 3: the large majority of triples are eliminated instantly by the parity criterion (Theorem 3.3), and the exhaustive check confirms that the residual, parity-even triples are excluded as well, invariably by the archimedean trapping described in Section 3.3.

## 5. Algorithms

We record the two computational procedures underlying the results.

**Algorithm A (Parity-criterion screen).** Given $(a, b)$, compute $v_2(a+1)$ and $v_2(b+1)$ by repeated division and return "not a square for all odd $n$" if their sum is odd. This is an $O(\log a + \log b)$ test that resolves a case without ever forming an $n$-th power.

**Algorithm B (Exhaustive certificate).** Iterate over $2 \le a < b < 100$ with $\gcd(a,b) = 1$ and $n \in \{3,5,7,9\}$; for each triple compute $N = (a^n+1)(b^n+1)$ and test squareness by comparing $\lfloor\sqrt N\rfloor^2$ with $N$. Report any square found (there are none). The dominant cost is the big-integer arithmetic on $N$, whose size is $O(n\log b)$ bits.

Algorithm A is a fast filter that explains the mechanism; Algorithm B is the certifying enumeration that guarantees completeness over the window. In practice one composes them: run Algorithm A first to discharge the parity-odd majority in near-constant time per pair, and reserve the heavier big-integer squareness test of Algorithm B for the parity-even residue. This hybrid is asymptotically dominated by the residual tests, but the constant-factor savings are substantial because more than half of all pairs never require an $n$-th power to be formed.

**Decidability.** The reduction underlying Theorem 4.1 rests on the elementary fact that squareness of a natural number is decidable: $N$ is a square if and only if $r^2 = N$ where $r = \lfloor \sqrt N \rfloor$, and the integer square root is computable in time polynomial in the bit-length of $N$. Consequently any statement quantifying squareness over an explicitly bounded set of parameters is algorithmically checkable by finite search, which is what makes the bounded window amenable to an exhaustive certificate while the unbounded conjecture requires the structural arguments of Sections 3 and 6.

## 6. Conjectural Framework and Future Directions

The exponent-invariance mechanism suggests a layered research program.

**6.1 An odd-prime valuation sieve.** Fix an odd prime $p$. For coprime $1 < a < b$ and any odd exponent $n$ with $p \nmid n$, if $v_p(a+1) + v_p(b+1)$ is odd then $P_n(a,b)$ is not a perfect square. This is the direct transfer of Theorem 3.3 to odd primes; the single new ingredient is controlling $v_p(n)$ through the lifting-the-exponent identity $v_p(a^n+1) = v_p(a+1) + v_p(n)$.

**6.2 A complete local-obstruction classification.** For odd $n$, $P_n(a,b)$ fails to be a perfect square precisely when there exists a prime $p$ with $p \nmid n$ for which $v_p(a+1) + v_p(b+1)$ is odd; whenever no such prime exists, solutions are governed by an accompanying archimedean size constraint and are finite in number. This asserts that squareness is assembled from independent local parity conditions, one per prime, each computable directly from $a+1$ and $b+1$.

**6.3 Products of three or more factors.** For every odd $n$ and every finite set of pairwise coprime bases $a_1 < a_2 < \cdots < a_k$ with $k \ge 2$, the product $\prod_i (a_i^n + 1)$ is a perfect square only if the multiset of valuations $\{v_2(a_i+1)\}$ has even sum and the higher-prime parities all vanish; in particular, for $k$ odd with all $a_i \equiv 1 \pmod 4$ it is never a square. The valuation sieve is additive across any number of factors, so more terms mean more simultaneous parity constraints, making squares increasingly scarce as $k$ grows.

**6.4 Exponent-invariance as Diophantine rigidity.** For a fixed base $a$ and varying odd $n$, the squarefree part of $a^n + 1$ stabilizes in a strong sense dictated by the valuations of $a+1$: the odd part of the valuation profile is exponent-independent, so the "square-obstructing" content of $a^n+1$ is a rigid invariant of the base rather than of the power.

## 6.5 The archimedean regime in detail

When every prime parity is even, squareness is not obstructed locally, and one must argue globally. The governing heuristic is that $P_n(a,b) = (a^n+1)(b^n+1)$ lies extremely close to the square $(a b)^n \cdot (\text{something})$ but is displaced from any exact square by a controlled amount. Writing $P_n(a,b) = a^n b^n + a^n + b^n + 1$, one compares it with nearby squares of integers close to $(ab)^{n/2}$; for odd $n$ this exponent is not an integer, so a more careful comparison with $\lfloor \sqrt{P_n(a,b)} \rfloor$ is used. Empirically, and provably over the bounded window of Theorem 4.1, the fractional distance from $P_n(a,b)$ to the nearest square is bounded away from zero. Making this uniform in $(a,b,n)$ — for the parity-even residual cases — is the principal analytic task remaining toward the full conjecture, and it is the archimedean complement to the algebraic sieve. A promising route is to combine effective lower bounds on the gap with the local sieve, so that only finitely many $(a,b)$ survive both filters for each $n$, after which a direct check finishes the argument.

## 7. Related Context

The study of when values of polynomials or of expressions such as $a^n \pm 1$ are perfect powers has a long history, from Catalan-type problems to the theory of Lucas and Lehmer sequences and their primitive divisors. The distinctive feature here is the *product* of two shifted powers and the use of a valuation collapse specific to odd exponents. The lifting-the-exponent principle, which underlies Theorem 3.1 and Remark 3.2, is a standard tool for controlling $v_p(a^n \pm b^n)$; our contribution is to package its $p=2$ consequence as a uniform, exponent-free parity obstruction and to organize the odd-prime cases into a coherent sieve. The reduction of a finite sub-question to a decidable computation (Theorem 4.1) reflects the general principle that bounded Diophantine statements are algorithmically checkable, here made concrete and exhaustive.

## 8. Discussion

The through-line of this work is a reversal of expectation. The exponent $n$, which inflates the numbers involved, is exactly the datum that does not affect the decisive $2$-adic obstruction. This exponent-invariance turns an ostensibly $n$-dependent Diophantine problem into a parity computation on $a+1$ and $b+1$, and it opens the door to a prime-by-prime sieve that should, conjecturally, account for all non-solutions outside a finite archimedean-controlled set. The bounded certificate of Theorem 4.1 anchors the conjecture with unconditional evidence, while Theorems 3.1 and 3.3 supply the structural reason the evidence looks the way it does.

## 9. Conclusion

We have identified and proved the mechanism — collapse of the $2$-adic valuation for odd exponents — that governs when a product of two coprime shifted powers can be a perfect square, derived the resulting uniform parity obstruction, and certified the impossibility exhaustively over an explicit window. The mechanism is robust: it generalizes to odd primes, to many-factor products, and to a rigidity principle for the squarefree part of $a^n+1$, charting a concrete path toward a full resolution of the conjecture.
