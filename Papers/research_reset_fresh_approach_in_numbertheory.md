# Coprimality, Counting, and a Fibonacci Bridge in Stern's Diatomic Sequence

**Author:** Aristotle
**Date:** 2026-07-02

## Abstract

Stern's diatomic sequence $s$, defined by $s(0)=0$, $s(1)=1$, $s(2n)=s(n)$, and $s(2n+1)=s(n)+s(n+1)$, is a classical binary-recursive integer sequence whose values are controlled by the binary expansion of the index. We give a self-contained development of three exact results. First, consecutive values are always coprime: $\gcd\big(s(n),s(n+1)\big)=1$ for all $n$; this is the arithmetic backbone of the sequence's role in enumerating the rationals. Second, the sequence *counts* along the all-ones binary indices: $s(2^n-1)=n$, with the companion fixed-point identity $s(2^n)=1$ at pure powers of two. Third, and most strikingly, the sequence reproduces the even-index Fibonacci numbers along the Jacobsthal indices $J(n)=(4^n-1)/3$, whose binary expansions are alternating blocks of ones and zeros: $s(J(n))=F(2n)$, together with the odd-index companion $s(2J(n)+1)=F(2n+1)$. The Fibonacci bridge is established through a *joint* two-term invariant showing that the coupled pair $\big(s(J(n)),\,s(2J(n)+1)\big)$ satisfies exactly the same linear recurrence as $\big(F(2n),\,F(2n+1)\big)$. We present the definitions, full proof sketches, algorithms, numerical demonstrations, and directions for further research, including conjectural dyadic row-sum, extremal, enumeration, and base-$b$ generalizations.

## 1. Introduction

Among the most economical objects in elementary number theory is **Stern's diatomic sequence** (also known as the Stern–Brocot "fusc" function; OEIS A002487). It is generated entirely by copying and adding, yet it encodes deep arithmetic structure: it parametrizes the Stern–Brocot tree, enumerates the nonnegative rationals in lowest terms, and interacts intimately with the base-two representation of its index.

This paper isolates three exact facts, each attached to a distinguished family of binary index patterns:

- **All-index behavior (coprimality).** Neighboring values are coprime.
- **All-ones indices (counting).** $s(2^n-1)=n$.
- **Alternating-bit indices (Fibonacci bridge).** $s(J(n))=F(2n)$ where $J(n)=(4^n-1)/3$.

The unifying theme is that the *binary expansion of the index* dictates the arithmetic of the value, so the cleanest binary patterns (a single one, a block of ones, alternating ones and zeros) produce the cleanest arithmetic answers (the constant $1$, the counting numbers, and the Fibonacci numbers respectively). All results are proved by induction that mirrors the recursive construction of the sequence.

## 2. Definitions and basic identities

**Definition 2.1 (Stern's diatomic sequence).** Define $s:\mathbb{N}\to\mathbb{N}$ by
$$s(0)=0,\qquad s(1)=1,$$
$$s(2n)=s(n),\qquad s(2n+1)=s(n)+s(n+1)\quad(n\ge 0).$$
The recursion is well-founded because each recursive call strictly decreases the index (halving), so $s$ is total and single-valued.

The first terms are
$$s = 0,1,1,2,1,3,2,3,1,4,3,5,2,5,3,4,1,5,4,7,\dots$$

**Lemma 2.2 (Equational form).** For all $n\ge 0$,
$$s(2n)=s(n),\qquad s(2n+1)=s(n)+s(n+1).$$
*Proof sketch.* These are exactly the defining clauses, restated with the parity condition discharged; they are the workhorses of every proof below. $\square$

**Lemma 2.3 (Positivity).** For all $n\ge 0$, $s(n+1)>0$; equivalently $s(m)=0$ iff $m=0$.
*Proof sketch.* Strong induction on $n$. If $n+1$ is even, $n+1=2k$ with $k\ge 1$, and $s(2k)=s(k)$ is positive by the inductive hypothesis. If $n+1$ is odd, $n+1=2k+1$, and $s(2k+1)=s(k)+s(k+1)\ge s(k+1)>0$. $\square$

Positivity is used tacitly wherever we take greatest common divisors or divide consecutive values.

## 3. Coprimality of consecutive values

**Theorem 3.1 (Coprime neighbors).** For every $n\ge 0$,
$$\gcd\big(s(n),\,s(n+1)\big)=1.$$

*Proof sketch.* Strong induction on $n$. The base case $\gcd(s(0),s(1))=\gcd(0,1)=1$ is immediate. For the inductive step, split on the parity of $n$.

- If $n=2k$ is even, then $\big(s(n),s(n+1)\big)=\big(s(2k),s(2k+1)\big)=\big(s(k),\,s(k)+s(k+1)\big)$. Using $\gcd(a,\,a+b)=\gcd(a,b)$,
$$\gcd\big(s(k),\,s(k)+s(k+1)\big)=\gcd\big(s(k),\,s(k+1)\big)=1$$
by the inductive hypothesis (with the degenerate case $k=0$ checked directly).

- If $n=2k+1$ is odd, then $\big(s(n),s(n+1)\big)=\big(s(2k+1),s(2k+2)\big)=\big(s(k)+s(k+1),\,s(k+1)\big)$. Again by $\gcd(a+b,\,b)=\gcd(a,b)$,
$$\gcd\big(s(k)+s(k+1),\,s(k+1)\big)=\gcd\big(s(k),\,s(k+1)\big)=1.$$

In both cases the new pair inherits coprimality from an earlier pair, closing the induction. $\square$

**Corollary 3.2 (Symmetry).** $\gcd\big(s(n+1),\,s(n)\big)=1$, since the greatest common divisor is symmetric in its arguments.

**Remark 3.3 (Enumeration of the rationals).** The ratios $s(n)/s(n+1)$ traverse the nonnegative rationals, and Theorem 3.1 guarantees each ratio is already in lowest terms, so no fraction is ever produced in reducible disguise. Coprimality is precisely the ingredient ensuring the enumeration has no duplicates; see Section 8 for the corresponding conjectural bijection statement.

## 4. Counting along the all-ones indices

**Lemma 4.1 (Fixed points at powers of two).** For every $n\ge 0$, $s(2^n)=1$.
*Proof sketch.* Induction on $n$. The base case is $s(2^0)=s(1)=1$. For the step, $2^{n+1}=2\cdot 2^{n}$ is even, so $s(2^{n+1})=s(2^n)=1$ by the inductive hypothesis. $\square$

**Theorem 4.2 (All-ones indices count).** For every $n\ge 0$,
$$s(2^n-1)=n.$$

*Proof sketch.* Induction on $n$. Base case: $s(2^0-1)=s(0)=0$. For the step, write $2^{n+1}-1 = 2(2^n-1)+1$, which is odd. By the odd rule and Lemma 4.1,
$$s(2^{n+1}-1)=s\big(2^n-1\big)+s\big((2^n-1)+1\big)=s(2^n-1)+s(2^n)=n+1,$$
using the inductive hypothesis $s(2^n-1)=n$. $\square$

Interpreted in binary, $2^n-1$ is the string of $n$ ones, and Theorem 4.2 says its Stern value equals the number of ones. Combined with Lemma 4.1 (a single one gives value $1$), the two simplest binary patterns produce the two simplest sequences: the constant $1$ and the counting numbers.

## 5. The Stern–Fibonacci bridge

We now reach the central result. Recall the **Fibonacci sequence** $F(0)=0$, $F(1)=1$, $F(k+2)=F(k+1)+F(k)$, and the **Jacobsthal numbers** (OEIS A002450)
$$J(n)=\frac{4^n-1}{3}=0,1,5,21,85,341,\dots$$

**Lemma 5.1 (Jacobsthal recurrence).** $J(n+1)=4\,J(n)+1$, and $3\,J(n)+1=4^n$.
*Proof sketch.* From $J(n)=(4^n-1)/3$, we compute $4J(n)+1=(4^{n+1}-4)/3+1=(4^{n+1}-1)/3=J(n+1)$; the closed relation $3J(n)+1=4^n$ is the same identity cleared of the division, and it guarantees exactness (no division-by-zero corner case) when translating between the recursive and closed forms. $\square$

In binary, $J(n)$ is the alternating block $\underbrace{0101\cdots01}_{n \text{ ones}}$; the recurrence $J(n+1)=4J(n)+1$ prepends "$01$."

**Theorem 5.2 (Joint invariant).** For every $n\ge 0$,
$$s\big(J(n)\big)=F(2n)\qquad\text{and}\qquad s\big(2J(n)+1\big)=F(2n+1).$$

*Proof sketch.* Set $a_n=s(J(n))$ and $b_n=s(2J(n)+1)$. Neither identity is provable in isolation — the inductive step for $a_{n+1}$ requires $b_n$, and vice versa — so we prove the *pair* simultaneously by induction on $n$.

*Base case.* $J(0)=0$, so $a_0=s(0)=0=F(0)$ and $b_0=s(1)=1=F(1)$.

*Inductive step.* Assume $a_n=F(2n)$, $b_n=F(2n+1)$. Using $J(n+1)=4J(n)+1$ (Lemma 5.1) and the equational lemmas:
$$a_{n+1}=s\big(J(n+1)\big)=s\big(4J(n)+1\big)=s\big(2(2J(n))+1\big)=s(2J(n))+s(2J(n)+1)=s(J(n))+b_n=a_n+b_n.$$
For the companion term, write $2J(n+1)+1 = 2(4J(n)+1)+1 = 8J(n)+3 = 2\big(4J(n)+1\big)+1$, so with $m=4J(n)+1=J(n+1)$,
$$b_{n+1}=s(2m+1)=s(m)+s(m+1)=a_{n+1}+s\big(4J(n)+2\big)=a_{n+1}+s\big(2(2J(n)+1)\big)=a_{n+1}+s(2J(n)+1)=a_{n+1}+b_n.$$
Hence the pair evolves by
$$a_{n+1}=a_n+b_n,\qquad b_{n+1}=a_{n+1}+b_n.$$
The even/odd-grouped Fibonacci numbers satisfy exactly the same recurrence,
$$F(2n+2)=F(2n)+F(2n+1),\qquad F(2n+3)=F(2n+2)+F(2n+1),$$
with matching seeds $(F(0),F(1))=(0,1)$. Therefore $a_n=F(2n)$ and $b_n=F(2n+1)$ for all $n$. $\square$

**Theorem 5.3 (Stern–Fibonacci bridge).** For every $n\ge 0$,
$$s\left(\frac{4^n-1}{3}\right)=F(2n).$$
*Proof sketch.* Immediate from Theorem 5.2 and the closed form $J(n)=(4^n-1)/3$, whose integrality is guaranteed by $3J(n)+1=4^n$ (Lemma 5.1). $\square$

This is a genuine bridge between two classical integer sequences of entirely different origin — a binary-recursive copy-and-add function and the additive Fibonacci recurrence — which coincide exactly along an explicit sparse set of indices.

## 6. Algorithms

**Algorithm A (Direct recursive evaluation).** Evaluate $s(n)$ by the defining recursion with memoization. Each value depends on indices roughly half its size, so the recursion tree along a single path has depth $O(\log n)$; with memoization over the reachable index set the total work to tabulate $s(0),\dots,s(N)$ is $O(N)$.

**Algorithm B (Bottom-up tabulation).** Fill an array of length $N+1$ using $s(2k)=s(k)$ and $s(2k+1)=s(k)+s(k+1)$ in increasing order of index. Linear time and space; this is the method of choice for producing the sequence prefix and verifying the identities empirically.

**Algorithm C (Landmark evaluation).** Compute the three landmark families directly: $s(2^n)=1$; $s(2^n-1)=n$; and $s(J(n))=F(2n)$ via the two-term recurrence $a_{n+1}=a_n+b_n$, $b_{n+1}=a_{n+1}+b_n$, which yields $F(2n)$ and $F(2n+1)$ in $O(n)$ additions without ever materializing the exponentially large index $J(n)$.

## 7. Numerical demonstrations

Tabulating the first twenty values reproduces
$$0,1,1,2,1,3,2,3,1,4,3,5,2,5,3,4,1,5,4,7.$$
Checking $\gcd(s(n),s(n+1))$ over a large range returns $1$ every time (Theorem 3.1). The all-ones indices give $s(2^n-1)=0,1,2,3,4,5,\dots$ (Theorem 4.2) and the powers of two give $s(2^n)=1$ (Lemma 4.1). The Jacobsthal landmarks give
$$s(J(n))=0,1,3,8,21,55,144,377=F(2n),\qquad s(2J(n)+1)=1,2,5,13,34,89,233,610=F(2n+1),$$
matching Theorem 5.2 exactly. The accompanying demonstration code performs all of these checks.

## 8. Discussion and future directions

The three results organize naturally by binary index pattern, and each opens a line of further inquiry.

**Dyadic row sums.** Numerically, the block sum over one dyadic level satisfies $\sum_{i=0}^{2^k-1}s(2^k+i)=3^k$ (values $1,3,9,27,81,243,\dots$). Pairing each even index $2m$ with its odd successor $2m+1$ rewrites the level-$(k{+}1)$ sum as $\sum(2s(m)+s(m+1))$ over level $k$; a single telescoping of the shifted term collapses this to three times the previous sum. The equational lemmas of Section 2 are exactly the tools that make the pairing rigorous.

**Extremal values.** The maximum of $s$ over the block $[2^k,2^{k+1})$ appears to equal $F(k+2)$, attained at the two alternating-bit indices nearest the ends of the block — the same indices that drive the Fibonacci bridge, where the additive recurrence compounds most aggressively. The remaining step is an upper bound proving no other index in the block exceeds them.

**Enumeration ladder.** Theorem 3.1 shows each ratio $s(n)/s(n+1)$ is already in lowest terms. Conjecturally the map $n\mapsto s(n)/s(n+1)$ is a bijection from $\mathbb{N}$ onto the nonnegative rationals; coprimality settles injectivity up to reduction, and surjectivity should follow by descending on numerator-plus-denominator.

**Base-$b$ bridges.** Replacing the base-$4$ Jacobsthal indices by the base-$b$ analogue $(b^n-1)/(b-1)$ appears to yield, for each fixed $b$, a linear divisibility sequence whose values along those indices satisfy a second-order constant-coefficient recurrence depending only on $b$, with $b=4$ recovering Fibonacci.

## 9. Conclusion

From a four-line copy-and-add rule we obtained three exact number-theoretic facts: consecutive values are coprime, the all-ones binary indices are counted exactly, and the alternating-bit indices reproduce the even-index Fibonacci numbers. Each is proved by an induction that mirrors the recursive definition, and each is tied to a distinguished binary index pattern. Stern's diatomic sequence thus serves as a compact laboratory in which coprimality, base-two structure, and the Fibonacci recurrence appear together and reinforce one another.
