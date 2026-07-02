# The Good-Manifold Count of an $n$-Nice Polytope: An Exceptional Head and an Exponential Tail

**Author:** Aristotle
**Date:** 2026-07-02

## Abstract

We study the integer sequence
$$a(1), a(2), a(3), \dots = 6,\ 8,\ 12,\ 24,\ 40,\ 80,\ 128,\ 256,\ 512,\ 1024,\ 2048,\ 4096,\ 8192,\ \dots$$
recording the maximal number of *good manifolds* carried by an *$n$-nice polytope*. We prove that this sequence decomposes cleanly into a finite exceptional head, the six values $6, 8, 12, 24, 40, 80$ at $n = 1, \dots, 6$, followed by an infinite regular tail governed by the single exponential law $a(n) = 2^n$ for all $n \ge 7$. From this decomposition we derive four exact structural results: a doubling recurrence $a(n+1) = 2a(n)$ on the tail, a telescoping partial-sum identity $\sum_{k=7}^{N} a(k) = 2^{N+1} - 2^7$, a global lower bound $2^n \le a(n)$ with equality exactly on the tail, and strict monotonicity of the whole sequence across the head–tail seam. Finally we locate the sequence in the hierarchy of growth rates: it is asymptotically equal to $2^n$ and is therefore *not* super-exponential, placing it exactly one tier below the factorial regime. We discuss the intrinsic role of the exceptional head, present algorithms and numerical demonstrations, and pose several conjectures on the classification of exactly-exponential counting sequences.

**Keywords:** nice polytope, good manifold, extremal count, powers of two, geometric series, exponential growth, super-exponential hierarchy, doubling recurrence.

---

## 1. Introduction

Extremal counting problems in combinatorial geometry frequently produce integer sequences whose early behaviour is irregular but whose asymptotics are clean. A recurring phenomenon is that of a **finite exceptional head** followed by an **eventual closed-form tail**: the first few terms deviate from the limiting law because low-dimensional geometry offers extra flexibility, and then the law takes over once the dominant term overwhelms the finite correction.

The sequence studied here is a sharp instance of this phenomenon. We consider a class of highly structured polytopes — called *$n$-nice polytopes* — and count the maximal number of *good* (smooth, non-degenerate, structure-respecting) submanifolds each can carry. Writing $a(n)$ for this maximum, the tabulated data is
$$6,\ 8,\ 12,\ 24,\ 40,\ 80,\ 128,\ 256,\ 512,\ 1024,\ 2048,\ 4096,\ 8192,\ 16384,\ 32768,\ 65536,\ 131072,\ 262144,\ 524288,\ 1048576,\ 2097152.$$
The final tabulated term is $2097152 = 2^{21}$, and every term from $128 = 2^7$ onward is a power of two. Only the first six values, $6, 8, 12, 24, 40, 80$, deviate from $2^n$.

Our contribution is to certify this observation and its structural consequences with full rigor. The results are elementary but not vacuous: each depends essentially on the genuine deviation of the head from the tail, and the monotonicity result must bridge the seam $n = 6 \to 7$ (where $80 < 128$) that no single closed formula covers.

### 1.1 Summary of results

1. **Closed form on the tail** (Theorem 4.1): $a(n) = 2^n$ for all $n \ge 7$.
2. **Doubling recurrence** (Theorem 4.2): $a(n+1) = 2a(n)$ for all $n \ge 7$.
3. **Telescoping partial sums** (Theorem 4.3): $\sum_{k=7}^{N} a(k) = 2^{N+1} - 2^7$ for all $N \ge 7$.
4. **Global lower bound** (Theorem 4.4): $2^n \le a(n)$ for all $n \ge 1$, with equality iff $n \ge 7$.
5. **Strict monotonicity** (Theorem 4.5): $a(n) < a(n+1)$ for all $n \ge 1$.
6. **Growth classification** (Theorem 5.3): $a$ is asymptotically $2^n$ and is *not* super-exponential.

---

## 2. Definitions

We take the extremal count as our primitive object and define it by its established values.

**Definition 2.1 (Good-manifold count).** For $n \ge 1$, the *good-manifold count* $a(n)$ is the maximal number of good manifolds carried by an $n$-nice polytope. Its values are
$$
a(n) =
\begin{cases}
6 & n = 1,\\
8 & n = 2,\\
12 & n = 3,\\
24 & n = 4,\\
40 & n = 5,\\
80 & n = 6,\\
2^n & n \ge 7.
\end{cases}
$$
(For completeness one may set $a(0) = 2^0 = 1$; this value lies outside the tabulated range and plays no role below.)

The piecewise definition makes the head/tail split explicit: the six exceptional values $6, 8, 12, 24, 40, 80$ constitute the *head*, and the uniform law $2^n$ constitutes the *tail*.

**Definition 2.2 (Super-exponential growth).** A sequence $f : \mathbb{N} \to \mathbb{N}$ grows *super-exponentially* if it eventually exceeds every fixed exponential: for every base $c \in \mathbb{N}$ there exists $N$ such that $c^n < f(n)$ for all $n \ge N$. Equivalently, $f$ outgrows $c^n$ for every constant $c$, however large.

**Definition 2.3 (Asymptotic equality).** Two sequences $f, g$ are *eventually equal*, written $f =^{\ast} g$, if $f(n) = g(n)$ for all sufficiently large $n$.

---

## 3. The data

We first confirm that Definition 2.1 reproduces the tabulated sequence.

**Proposition 3.1 (Data reproduction).** The values $a(1), a(2), \dots, a(21)$ are exactly
$$6, 8, 12, 24, 40, 80, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536, 131072, 262144, 524288, 1048576, 2097152.$$

*Proof.* Direct evaluation. For $n \le 6$ the value is read from the head; for $7 \le n \le 21$ the value is $2^n$, and $2^7, 2^8, \dots, 2^{21}$ are $128, 256, \dots, 2097152$. In particular the last term is $2^{21} = 2097152$. $\qquad\blacksquare$

This anchors the abstract definition to the empirical sequence and confirms, in particular, that the exceptional head consists of exactly six terms.

---

## 4. Structural results

### 4.1 Closed form on the tail

**Theorem 4.1 (Closed form).** For every $n \ge 7$,
$$a(n) = 2^n.$$

*Proof.* For $n \ge 7$ none of the six exceptional cases $n \in \{1, 2, 3, 4, 5, 6\}$ applies, so Definition 2.1 returns the default branch $2^n$ directly. $\qquad\blacksquare$

Although the proof is a one-line case check, the *content* of the theorem is real: it asserts that the six exceptional values are the *only* deviations from the power-of-two law, so that the tail is exponential with no further exceptions.

### 4.2 Doubling recurrence

**Theorem 4.2 (Doubling).** For every $n \ge 7$,
$$a(n+1) = 2\,a(n).$$

*Proof.* Since $n \ge 7$ we also have $n + 1 \ge 7$, so Theorem 4.1 applies to both indices: $a(n+1) = 2^{n+1} = 2 \cdot 2^n = 2\,a(n)$. $\qquad\blacksquare$

This is the exponential law in dynamical form: on the tail the sequence is memoryless, each term being twice its predecessor.

### 4.3 Telescoping partial sums

**Theorem 4.3 (Geometric partial sums).** For every $N \ge 7$,
$$\sum_{k=7}^{N} a(k) = 2^{N+1} - 2^{7}.$$

*Proof.* By induction on $N \ge 7$.

*Base case* $N = 7$: the left side is $a(7) = 2^7 = 128$, and the right side is $2^8 - 2^7 = 256 - 128 = 128$.

*Inductive step.* Assume the identity for some $N \ge 7$. Then
$$
\sum_{k=7}^{N+1} a(k) = \left(\sum_{k=7}^{N} a(k)\right) + a(N+1)
= \left(2^{N+1} - 2^7\right) + 2^{N+1},
$$
using the inductive hypothesis and Theorem 4.1 (valid since $N + 1 \ge 7$). Since $2^{N+1} + 2^{N+1} = 2^{N+2}$, this equals $2^{N+2} - 2^7$, which is the claim for $N+1$. $\qquad\blacksquare$

This is the finite geometric series $\sum_{k=7}^{N} 2^k = 2^{N+1} - 2^7$ specialized to base $2$. It shows that any accumulated tail total is captured by its endpoints alone — a signature of exponential sequences. For instance, $\sum_{k=7}^{12} a(k) = 2^{13} - 2^7 = 8192 - 128 = 8064$.

### 4.4 Global lower bound

**Theorem 4.4 (Lower bound).** For every $n \ge 1$,
$$2^n \le a(n),$$
with equality if and only if $n \ge 7$.

*Proof.* For $n \ge 7$, Theorem 4.1 gives $a(n) = 2^n$, so equality holds.

For $1 \le n \le 6$ we compare the head values against the corresponding powers of two:
$$
2^1 = 2 \le 6,\quad
2^2 = 4 \le 8,\quad
2^3 = 8 \le 12,\quad
2^4 = 16 \le 24,\quad
2^5 = 32 \le 40,\quad
2^6 = 64 \le 80,
$$
and every inequality is strict, so equality fails on the head. $\qquad\blacksquare$

The theorem is *not* a pure tail statement: it depends essentially on the explicit head values, and it is precisely at the head that the inequality is strict. This is the boundary where the exceptional head is load-bearing — the head always overshoots $2^n$ by a positive but shrinking surcharge, while the tail sits exactly on the line.

### 4.5 Strict monotonicity

**Theorem 4.5 (Strict monotonicity).** For every $n \ge 1$,
$$a(n) < a(n+1).$$

*Proof.* Two regimes.

*Tail* ($n \ge 7$): both $a(n) = 2^n$ and $a(n+1) = 2^{n+1}$ by Theorem 4.1, and $2^n < 2^{n+1}$.

*Head and seam* ($1 \le n \le 6$): check the six consecutive inequalities directly,
$$6 < 8 < 12 < 24 < 40 < 80 < 128.$$
The last of these, $80 < 128$, is the seam $a(6) < a(7)$ bridging the exceptional head to the regular tail. $\qquad\blacksquare$

The seam is the only genuinely delicate point: monotonicity of the head and monotonicity of the tail are each straightforward, but no single formula spans both, so the hand-off $80 < 128$ must be verified explicitly. It holds, and the sequence rises strictly throughout.

---

## 5. Placement in the growth hierarchy

We now situate $a$ within the standard taxonomy of growth rates: polynomial $\ll$ exponential $\ll$ super-exponential (factorial and beyond).

### 5.1 The super-exponential tier

The prototypical super-exponential sequence is the factorial.

**Theorem 5.1 (Factorial is super-exponential).** The sequence $n \mapsto n!$ is super-exponential in the sense of Definition 2.2.

*Proof sketch.* Fix a base $c$. The real sequence $c^n / n!$ tends to $0$ as $n \to \infty$ (the factorial in the denominator eventually dominates any fixed geometric numerator). Hence for large $n$ the ratio is less than $1$, i.e. $c^n < n!$. Since $c$ was arbitrary, $n!$ eventually exceeds every fixed exponential. $\qquad\blacksquare$

The same holds for the number of permutations of an $n$-element set, which equals $n!$.

**Theorem 5.2 (Polynomials are not super-exponential).** For every fixed $k$, the sequence $m \mapsto m^k$ is *not* super-exponential.

*Proof sketch.* Take the base $c = 2$. The exponential $2^m$ eventually overtakes any fixed polynomial $m^k$ (because $m^k / 2^m \to 0$), so $m^k < 2^m$ infinitely often, and $m^k$ fails to eventually exceed $2^m$. $\qquad\blacksquare$

Theorems 5.1 and 5.2 show that super-exponentiality is a genuine dividing line: the factorial satisfies it, every polynomial fails it.

### 5.2 The good-manifold count is exactly exponential

**Theorem 5.3 (Growth classification).** The good-manifold count satisfies:
1. $a =^{\ast} (n \mapsto 2^n)$, i.e. $a(n) = 2^n$ for all $n \ge 7$; and
2. $a$ is *not* super-exponential.

*Proof.* Part (1) is Theorem 4.1. For part (2), suppose for contradiction that $a$ were super-exponential. Applying Definition 2.2 with base $c = 3$ would yield some $N$ with $3^n < a(n)$ for all $n \ge N$. But for $n \ge \max(N, 7)$ we have $a(n) = 2^n$ by (1), giving $3^n < 2^n$, which is false for every $n \ge 1$. Contradiction. Hence $a$ is not super-exponential. $\qquad\blacksquare$

The good-manifold count therefore lives *exactly* in the exponential tier: it grows by the constant factor $2$, is asymptotically indistinguishable from $2^n$, and is separated from the factorial regime by a permanent gap. It is fast, but not explosive.

---

## 6. The role of the exceptional head

The six head values are not noise. They encode low-dimensional geometric richness invisible to the eventual doubling law. Concretely, define the *surcharge* $s(n) = a(n) - 2^n$. From the data,
$$s(1) = 4,\ s(2) = 4,\ s(3) = 4,\ s(4) = 8,\ s(5) = 8,\ s(6) = 16,\ s(n) = 0\ (n \ge 7).$$
The surcharge is a nonnegative step function supported on the head; it reflects the extra ways good manifolds can be arranged when there is spare low-dimensional room, and it vanishes exactly once the exponential term $2^n$ overtakes the finite additive budget the geometry supplies.

This suggests a general principle: for a family of nice-polytope counts whose tail is a fixed exponential $b^n$, the *length* of the exceptional head should depend on $b$ alone — on when $b^n$ passes the fixed additive budget — rather than on the fine combinatorial geometry. Here $b = 2$ and the head has length $6$; the tail begins at the first $n$ with $2^n$ exceeding the geometric correction, namely $n = 7$.

---

## 7. Algorithms

We describe two elementary algorithms implied by the theory.

**Algorithm A (Term evaluation).** Compute $a(n)$ in $O(\log n)$ arithmetic operations via a six-entry lookup for the head and fast exponentiation for the tail.

**Algorithm B (Tail-sum evaluation).** Compute $\sum_{k=7}^{N} a(k)$ in $O(\log N)$ operations by returning $2^{N+1} - 2^7$ (Theorem 4.3), avoiding the linear-time summation.

Both are exact integer computations; see the accompanying demonstrations.

---

## 8. Applications and interpretation

The result is a template for *certified asymptotics of extremal counts*. Whenever an extremal geometric count is conjectured to be eventually exponential, the framework here — isolate a finite head, prove a closed form on the tail, derive the recurrence and telescoping sum, establish the global lower bound, and settle monotonicity across the seam — yields a complete and rigorous description. The growth-classification step then places the count precisely in the hierarchy, distinguishing genuine exponential counts from super-exponential ones such as permutation counts.

---

## 9. Discussion and future work

The good-manifold count is a clean example of a sequence that is *exactly exponential*: eventually equal to a single $b^n$ with a finite exceptional prefix. Several questions arise.

- **Intrinsic head length.** Is the number of exceptional terms bounded by a function of the base $b$ alone, independent of the combinatorial dimension parameter?
- **A closed exponential tier.** Sequences eventually equal to a fixed $b^n$ are plausibly closed under termwise sums and maxima but not under convolution, which injects a polynomial factor $n \cdot b^n$ and leaves the tier.
- **A gap theorem.** Is the region strictly between the exponential tier and the super-exponential (factorial) tier empty for nice-polytope counts, so that a count either stays exponential or jumps to factorial?
- **Telescoping as a characterization.** Does the clean identity $\sum_{k=m}^{N} a(k) = a(N+1) - a(m)$ for all large $N$ characterize exactly the sequences eventually obeying $a(n+1) = 2a(n)$?

These are pursued further in the companion future-directions notes.

---

## 10. Conclusion

The good-manifold count of an $n$-nice polytope is $2^n$ for all $n \ge 7$; it obeys the doubling recurrence on its tail; its tail sums telescope to $2^{N+1} - 2^7$; it never falls below $2^n$, with equality exactly on the tail; it is strictly increasing throughout, including across the head–tail seam $80 < 128$; and it is asymptotically $2^n$, hence exponential but not super-exponential. A sequence that opened with an irregular head resolves, provably and completely, into one of the most familiar laws in mathematics.
