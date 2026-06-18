# Fibonacci Entry Points and Primitive Prime Divisors: A Self-Contained Divisibility Theory

## Abstract

The *entry point* (or *rank of apparition*) of a positive integer $p$ is the least index $k > 0$ such that $p$ divides the Fibonacci number $F_k$. We develop the divisibility theory of entry points from first principles, taking as our sole structural input the gcd–Fibonacci identity $\gcd(F_m, F_n) = F_{\gcd(m,n)}$ and the index-divisibility property $a \mid b \Rightarrow F_a \mid F_b$. From these we derive: (1) a **gcd bridge for divisors**, stating that any common divisor of $F_m$ and $F_n$ divides $F_{\gcd(m,n)}$; (2) the **entry-point divisibility law**, $p \mid F_n \iff \alpha(p) \mid n$, valid for every $p$ that divides some Fibonacci number; (3) a characterization of **primitive prime divisors** — a prime $p$ divides $F_n$ but no earlier Fibonacci number iff $\alpha(p) = n$; and (4) the classical exception, that $F_{12} = 144$ has no primitive prime divisor. These four results constitute the analytic backbone of Carmichael's primitive-divisor theorem for Fibonacci numbers, recast self-containedly. We give complete proof sketches, an explicit algorithm for computing entry points, worked numerical examples, and a discussion of connections to the Pisano period and the law of apparition, with a roadmap of falsifiable next steps.

**Keywords:** Fibonacci numbers, entry point, rank of apparition, primitive prime divisor, Carmichael's theorem, gcd identity, Pisano period, law of apparition.

**MSC 2020:** 11B39 (Fibonacci and Lucas numbers), 11A05 (multiplicative structure), 11B50 (sequences and sets).

---

## 1. Introduction

The Fibonacci sequence $(F_k)_{k \ge 1}$ is defined by

$$F_1 = 1, \qquad F_2 = 1, \qquad F_{k+2} = F_{k+1} + F_k \quad (k \ge 1),$$

giving $1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, \dots$. While the sequence is most often studied for its growth (governed by the golden ratio $\varphi = \tfrac{1+\sqrt5}{2}$, via Binet's formula $F_k = (\varphi^k - \psi^k)/\sqrt5$ with $\psi = \tfrac{1-\sqrt5}{2}$), its *multiplicative* and *divisibility* structure is equally rich and, in some respects, even more rigid.

The organizing concept is the **entry point**. For an integer $p$, the entry point $\alpha(p)$ is the least positive index $k$ at which $p \mid F_k$. Empirically, $\alpha(2)=3$, $\alpha(3)=4$, $\alpha(5)=5$, $\alpha(7)=8$, $\alpha(11)=10$, $\alpha(13)=7$. The remarkable fact, dating to Lucas and made precise here, is that the entry point fully controls *all* indices at which $p$ appears: $p \mid F_n$ exactly when $\alpha(p) \mid n$. Consequently, the set of Fibonacci indices divisible by a fixed prime is an arithmetic progression $\alpha(p)\mathbb{Z}_{>0}$.

Building on this, a prime $p$ is a **primitive prime divisor** of $F_n$ if $p \mid F_n$ but $p \nmid F_k$ for all $1 \le k < n$. Carmichael (1913) proved that every $F_n$ has a primitive prime divisor except for a small explicit set of indices; the unique nontrivial exception is $n = 12$, where $F_{12} = 144 = 2^4 \cdot 3^2$ recycles only the primes 2 and 3, both of which entered far earlier.

The contribution of this paper is a *self-contained* development of the divisibility backbone of this theory. Earlier formal treatments routed these facts through auxiliary helper lemmas; here every result is proved directly from two standard Fibonacci facts:

- **(GCD)** $\gcd(F_m, F_n) = F_{\gcd(m,n)}$;
- **(DVD)** $a \mid b \implies F_a \mid F_b$.

We present the theory abstractly (over the natural numbers), state each result with its full mathematical content, and give proof sketches faithful to a complete formal development.

---

## 2. Preliminaries and definitions

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$, indices are positive natural numbers, and divisibility $a \mid b$ has its usual meaning. We use the two standard structural facts (GCD) and (DVD) stated above; both are classical and provable by induction from the recurrence (GCD follows from the addition formula $F_{m+n} = F_{m+1}F_n + F_m F_{n-1}$ together with the Euclidean algorithm; DVD is the special case $m \mid n$).

**Definition 2.1 (Entry point / rank of apparition).** For $p \in \mathbb{N}$, set

$$\alpha(p) \;=\; \begin{cases} \min\{\, k > 0 : p \mid F_k \,\} & \text{if such a } k \text{ exists,}\\[2pt] 0 & \text{otherwise.} \end{cases}$$

We say $p$ *occurs in the Fibonacci sequence* if the set $\{k > 0 : p \mid F_k\}$ is nonempty; equivalently, $\exists k,\ 0 < k \wedge p \mid F_k$. (Every prime $p$ occurs: this follows from the Pisano periodicity of $F \bmod p$, but we treat occurrence as a hypothesis where needed, to keep the divisibility theory independent of that fact.)

The convention $\alpha(p) = 0$ for non-occurring $p$ is a sentinel; all substantive statements below are guarded by an occurrence hypothesis, under which $\alpha(p) > 0$.

**Definition 2.2 (Primitive prime divisor).** For a prime $p$ and index $n > 0$, $p$ is a *primitive prime divisor* of $F_n$ if

$$p \mid F_n \qquad\text{and}\qquad \forall k,\ (0 < k < n) \Rightarrow p \nmid F_k.$$

We abbreviate this predicate $\mathrm{Prim}(p, n)$.

---

## 3. The gcd bridge

**Lemma 3.1 (gcd bridge for divisors).** *For all $p, m, n \in \mathbb{N}$, if $p \mid F_m$ and $p \mid F_n$, then $p \mid F_{\gcd(m,n)}$.*

*Proof sketch.* By (GCD), $F_{\gcd(m,n)} = \gcd(F_m, F_n)$. Since $p$ divides both $F_m$ and $F_n$, it divides their greatest common divisor; hence $p \mid F_{\gcd(m,n)}$. $\qquad\blacksquare$

This single implication is the engine of the entire theory. It says that the set $D_p = \{k : p \mid F_k\}$ is closed under taking gcds of its members. Together with the fact that $D_p$ is closed under multiples (a consequence of (DVD)), this forces $D_p$ to be exactly the set of multiples of its smallest positive element — the entry point. We now make this precise.

---

## 4. Existence, positivity, and minimality of the entry point

The following three facts package the defining properties of $\alpha(p)$ as a least element; each is read off directly from Definition 2.1 under the occurrence hypothesis $\exists k,\ 0 < k \wedge p \mid F_k$.

**Lemma 4.1 (positivity).** *If $p$ occurs in the Fibonacci sequence, then $\alpha(p) > 0$.*

*Proof sketch.* The defining set $\{k > 0 : p \mid F_k\}$ is nonempty and consists of positive integers; its minimum is therefore positive. $\qquad\blacksquare$

**Lemma 4.2 (membership).** *If $p$ occurs, then $p \mid F_{\alpha(p)}$.*

*Proof sketch.* $\alpha(p)$ is an element of the set it minimizes; that set's defining condition includes $p \mid F_{\alpha(p)}$. $\qquad\blacksquare$

**Lemma 4.3 (minimality).** *For all $m$ with $0 < m < \alpha(p)$, we have $p \nmid F_m$.*

*Proof sketch.* If $p \mid F_m$ with $m > 0$, then $m$ belongs to the minimized set, so $\alpha(p) \le m$, contradicting $m < \alpha(p)$. $\qquad\blacksquare$

---

## 5. The entry-point divisibility law

**Theorem 5.1 (divisibility law).** *Let $p$ occur in the Fibonacci sequence. Then for every $n \in \mathbb{N}$,*

$$p \mid F_n \iff \alpha(p) \mid n.$$

*Proof sketch.* Write $e = \alpha(p)$; by Lemma 4.1, $e > 0$, and by Lemma 4.2, $p \mid F_e$.

($\Rightarrow$) Suppose $p \mid F_n$; we show $e \mid n$ by contraposition. Assume $e \nmid n$. Then $g := \gcd(e, n)$ is a proper divisor of $e$, so $0 < g < e$ (positivity of $g$ follows from $e > 0$; strictness from $e \nmid n$, since $g = e$ would force $e \mid n$). By the gcd bridge (Lemma 3.1) applied to $p \mid F_e$ and $p \mid F_n$, we get $p \mid F_g$. But $0 < g < e = \alpha(p)$, contradicting minimality (Lemma 4.3). Hence $e \mid n$.

($\Leftarrow$) Suppose $e \mid n$. By (DVD), $F_e \mid F_n$. Since $p \mid F_e$, transitivity gives $p \mid F_n$. $\qquad\blacksquare$

**Corollary 5.2 (periodic appearance).** *For $p$ occurring, $\{n > 0 : p \mid F_n\} = \{\alpha(p), 2\alpha(p), 3\alpha(p), \dots\}$.*

This is the structural payoff: divisibility by $p$ is exactly periodic in the index, with period $\alpha(p)$.

---

## 6. Primitive prime divisors

**Theorem 6.1 (primitivity ⇔ timely entry).** *Let $n > 0$ and let $p$ occur in the Fibonacci sequence. Then*

$$\mathrm{Prim}(p, n) \iff \alpha(p) = n.$$

*Proof sketch.*

($\Rightarrow$) Suppose $\mathrm{Prim}(p,n)$ holds: $p \mid F_n$ and $p \nmid F_k$ for all $0 < k < n$. We show $\alpha(p) = n$ by antisymmetry.
- $\alpha(p) \le n$: since $p \mid F_n$ with $n > 0$, $n$ lies in the minimized set, so $\alpha(p) \le n$ (minimality of the least element, i.e., $\mathrm{find\_min'}$).
- $\alpha(p) \ge n$: if $\alpha(p) < n$, then $\alpha(p)$ is a positive index below $n$ with $p \mid F_{\alpha(p)}$ (Lemmas 4.1, 4.2), contradicting primitivity. Hence $\alpha(p) \ge n$.

($\Leftarrow$) Suppose $\alpha(p) = n$. Then $p \mid F_n = F_{\alpha(p)}$ by Lemma 4.2, and for $0 < k < n = \alpha(p)$, minimality (Lemma 4.3) gives $p \nmid F_k$. Hence $\mathrm{Prim}(p, n)$. $\qquad\blacksquare$

Theorem 6.1 reduces every question about primitive divisors to a question about entry points. In particular, $F_n$ has *a* primitive prime divisor iff there exists a prime whose entry point equals $n$. Carmichael's theorem is precisely the statement that this holds for all $n$ outside a small exceptional set.

---

## 7. The exceptional index $n = 12$

**Theorem 7.1 ($144$ has no primitive divisor).** *There is no prime $p$ with $\mathrm{Prim}(p, 12)$; that is, $F_{12} = 144$ has no primitive prime divisor.*

*Proof sketch.* Suppose, for contradiction, that some prime $p$ satisfies $\mathrm{Prim}(p, 12)$. Then $p \mid F_{12} = 144 = 2^4 \cdot 3^2$, so $p \in \{2, 3\}$ (the only primes dividing 144, bounded by $p \le 144$ and resolved by finite case analysis).
- If $p = 2$: then $2 \mid F_3 = 2$ with $0 < 3 < 12$, contradicting the primitivity clause $\forall k,\ (0<k<12)\Rightarrow p \nmid F_k$.
- If $p = 3$: then $3 \mid F_4 = 3$ with $0 < 4 < 12$, again contradicting primitivity.

In both cases the prime entered before position 12 ($\alpha(2) = 3$, $\alpha(3) = 4$), so no primitive divisor exists. $\qquad\blacksquare$

**Remark 7.2.** Via Theorem 6.1, the failure is exactly that neither $\alpha(2) = 3$ nor $\alpha(3) = 4$ equals 12, and these are the only candidate primes. The index 12 is the unique *nontrivial* Fibonacci index lacking a primitive divisor; the degenerate cases are $n = 1, 2$ (where $F_1 = F_2 = 1$ has no prime factors) and $n = 6$ (where $F_6 = 8 = 2^3$ recycles the prime 2, with $\alpha(2)=3 \mid 6$).

**Verification example.** Contrast this with $n = 7$: $F_7 = 13$ is prime, $13 \nmid F_k$ for $1 \le k \le 6$ (the values $1,1,2,3,5,8$ are coprime to 13), so $\mathrm{Prim}(13, 7)$ holds and, by Theorem 6.1, $\alpha(13) = 7$.

---

## 8. Algorithms

### 8.1 Computing the entry point

The divisibility law (Theorem 5.1) shows that to find $\alpha(p)$ it suffices to scan $F_1, F_2, \dots$ modulo $p$ until the first zero. The Fibonacci values themselves need never be computed in full — only their residues mod $p$ — keeping arithmetic bounded.

```
function ENTRY_POINT(p):
    if p == 1: return 1            # 1 divides F_1
    a, b <- 0, 1                   # a = F_0 mod p, b = F_1 mod p
    k <- 1
    repeat:
        if b == 0: return k        # first index with p | F_k
        a, b <- b, (a + b) mod p
        k <- k + 1
    # terminates by Pisano periodicity of F mod p
```

The loop terminates within the Pisano period $\pi(p) \le 6p$ (Wall's bound), so the entry point is found in $O(p)$ modular additions, each on $O(\log p)$-bit numbers.

### 8.2 Listing divisibility indices

By Corollary 5.2, once $\alpha(p)$ is known, *all* indices $n \le N$ with $p \mid F_n$ are simply $\alpha(p), 2\alpha(p), \dots \le N$ — obtained in $O(N/\alpha(p))$ time without further Fibonacci computation.

### 8.3 Deciding primitivity

By Theorem 6.1, $\mathrm{Prim}(p,n)$ holds iff $\alpha(p) = n$. So primitivity is decided by one entry-point computation and one equality test.

---

## 9. Applications

**Lucas-sequence primality testing.** Entry points are the Fibonacci instance of the general theory of Lucas sequences underlying the Lucas–Lehmer test (for Mersenne primes) and the Baillie–PSW probable-prime test. The law of apparition (Section 10) makes the entry point a discriminating signal: a prime $p \equiv \pm1 \pmod 5$ has $\alpha(p) \mid p-1$, while $p \equiv \pm2 \pmod 5$ has $\alpha(p) \mid p+1$; deviations flag compositeness.

**Periodic structure for sieving.** Corollary 5.2 turns "which Fibonacci numbers does $p$ divide?" into an arithmetic progression, enabling fast sieving of Fibonacci factorizations: each small prime contributes hits at a fixed stride.

**Primitive-divisor existence and Zsygmondy-type theorems.** Theorem 6.1 is the local criterion behind Carmichael's global existence theorem and its Lucas/Lehmer generalizations (Bilu–Hanrot–Voutier), which classify all terms of Lucas sequences lacking primitive divisors.

---

## 10. Discussion: where the entry point sits in number theory

The entry point is the bridge between the *additive* world of the Fibonacci recurrence and the *multiplicative* world of primes.

**Pisano period.** The period $\pi(p)$ of $F \bmod p$ is the order of the companion matrix $M = \begin{psmallmatrix}1&1\\1&0\end{psmallmatrix}$ in $\mathrm{GL}_2(\mathbb{Z}/p)$; the entry point $\alpha(p)$ is the least $k$ with $(M^k)_{12} \equiv 0$. One always has $\alpha(p) \mid \pi(p)$, with quotient in $\{1, 2, 4\}$. The divisibility law (Theorem 5.1) is the exact lever that transfers statements between $\alpha$ and $\pi$.

**Law of apparition.** Via Binet's formula over $\mathbb{Z}/p$, the value $F_{p - (5/p)}$ vanishes mod $p$, where $(5/p)$ is the Legendre symbol. By Theorem 5.1 this says $\alpha(p) \mid p - (5/p)$: the entry point divides $p-1$ or $p+1$ according to whether 5 is a quadratic residue mod $p$. This is the Fibonacci avatar of Fermat's little theorem, with $\sqrt5$ — the same surd that drives Fibonacci growth — controlling prime entry.

**Methodological remark.** The development above illustrates a recurring phenomenon: a single well-chosen identity (here the gcd bridge) renders an entire family of theorems near-immediate. The proofs of Theorems 5.1, 6.1, and 7.1 are each only a few logical steps once Lemma 3.1 and the least-element packaging (Lemmas 4.1–4.3) are in place.

---

## 10b. Historical context

The study of when primes divide Fibonacci numbers reaches back to Édouard Lucas in the 1870s, whose investigations of $(F_k)$ and the companion sequence of Lucas numbers $(L_k)$ ($L_1=1, L_2=3, L_{k+2}=L_{k+1}+L_k$) launched the modern theory of *Lucas sequences* $U_k(P,Q)$, of which the Fibonacci sequence is the case $(P,Q)=(1,-1)$. Lucas already understood the rank of apparition and used it to design primality tests; his ideas matured into the Lucas–Lehmer test that, to this day, certifies the largest known Mersenne primes.

The primitive-divisor question — does every term introduce a genuinely new prime? — was settled for Fibonacci and Lucas numbers by R. D. Carmichael in 1913. Carmichael's theorem states that $F_n$ has a primitive prime divisor for all $n$ outside the finite set $\{1, 2, 6, 12\}$ (and analogously for Lucas numbers outside $\{1, 6\}$). The case $n=12$, the subject of Theorem 7.1, is the lone *nontrivial* failure: $F_{12}=144$ is built entirely from primes that arrived earlier. The general phenomenon — that terms of integer linear recurrences eventually always carry primitive divisors, with only finitely many exceptions — culminates in the celebrated Bilu–Hanrot–Voutier theorem (2001), which gives the complete, effective list of Lucas and Lehmer numbers without primitive divisors. The Fibonacci case treated here is the historical and conceptual seed of that vast generalization.

It is worth emphasizing how little machinery our development requires. Lucas's original arguments, and many modern textbook treatments, invoke Binet's formula and algebraic number theory in $\mathbb{Z}[\varphi]$. The route taken here is deliberately elementary: the gcd identity (GCD) and index-divisibility (DVD) are both provable by elementary induction on the recurrence, and from them the entire divisibility law and primitivity characterization follow by pure order-theoretic reasoning about least elements. This makes the theory unusually robust and portable — it transfers, with cosmetic changes, to any *divisibility sequence* (a sequence with $\gcd(a_m, a_n) = a_{\gcd(m,n)}$), of which Fibonacci is the archetype.

## 10c. The role of the occurrence hypothesis

Every substantive theorem above carries the hypothesis that $p$ *occurs* in the Fibonacci sequence: $\exists k > 0,\ p \mid F_k$. This guard is what makes the sentinel convention $\alpha(p) = 0$ harmless — under occurrence, $\alpha(p) > 0$ and behaves as a genuine least element. For *primes* the hypothesis is automatically satisfied: reducing $(F_k)$ modulo $p$ yields a sequence over the finite set $\mathbb{Z}/p$, so by pigeonhole the pair $(F_k, F_{k+1}) \bmod p$ eventually repeats; running the recurrence backward shows the sequence is purely periodic and contains the pair $(0,1)$, forcing some $F_k \equiv 0$. We chose to *state* occurrence as an explicit hypothesis rather than discharge it, so that the divisibility theory (Sections 3–7) is logically independent of Pisano periodicity and applies verbatim to composite moduli and to abstract divisibility sequences. Direction 1 below closes the loop by quantifying the period itself.

## 11. Future directions

This work formalized the divisibility theory of the Fibonacci entry point $\alpha(p)$ and the characterization of primitive prime divisors, recast self-containedly from the gcd–Fibonacci bridge. Concrete, falsifiable next steps:

**Direction 1 — Entry point and the Pisano period.** Formalize $\alpha(p) \mid \pi(p)$ and the bound $\pi(p)/\alpha(p) \in \{1,2,4\}$, building on Theorem 5.1. The key insight: the multiplicative order of $M = \begin{psmallmatrix}1&1\\1&0\end{psmallmatrix}$ mod $p$ is exactly $\pi(p)$, while $\alpha(p)$ is the additive index at which the off-diagonal entry first vanishes; the quotient measures the order of the eigenvalue ratio, a unit of order dividing 4. This is tractable now because Theorem 5.1 supplies the precise "$\alpha(p) \mid n \iff p \mid F_n$" transfer, and the companion-matrix order theory is standard.

**Direction 2 — Law of apparition for $p \equiv \pm 1 \pmod 5$.** Prove that for an odd prime $p \neq 5$, $\alpha(p) \mid p-1$ when $p \equiv \pm1 \pmod5$ and $\alpha(p) \mid p+1$ when $p \equiv \pm2 \pmod5$, as a corollary of Theorem 5.1 together with the congruence $p \mid F_{p - (5/p)}$. The Binet identity over $\mathbb{Z}/p$ turns $F_{p-(5/p)} \equiv 0$ into a quadratic-residue statement about 5 — the Frobenius action on $\sqrt5$. Theorem 5.1 reduces the law of apparition to the single congruence $p \mid F_{p\pm1}$, with quadratic reciprocity supplying the residue dichotomy.

**Direction 3 — Complete the list of Fibonacci exceptions.** Theorem 7.1 ($n=12$) is one of exactly two nontrivial indices (within $n \in \{1,2,6,12\}$, with $1,2$ degenerate) where $F_n$ lacks a primitive prime divisor (Carmichael 1913). Prove the converse in full: for every $n \notin \{1,2,6,12\}$, $F_n$ *does* have a primitive prime divisor — establishing the complete Carmichael classification for Fibonacci numbers.

---

## 12. Conclusion

Starting from a single gcd identity, we have given a complete, self-contained derivation of the divisibility theory of Fibonacci entry points: a gcd bridge for common divisors, the entry-point divisibility law $p \mid F_n \iff \alpha(p) \mid n$, the characterization of primitive prime divisors as those whose entry point hits $n$ exactly, and the classical exceptional index $n = 12$ where $F_{12} = 144$ admits no primitive divisor. These results form the analytic backbone of Carmichael's primitive-divisor theorem and connect, through the Pisano period and the law of apparition, to the broader arithmetic of Lucas sequences.

---

## Appendix A. Table of entry points

| $p$ | 2 | 3 | 5 | 7 | 11 | 13 | 17 | 19 | 23 | 29 | 31 | 37 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| $\alpha(p)$ | 3 | 4 | 5 | 8 | 10 | 7 | 9 | 18 | 24 | 14 | 30 | 19 |

Each value is the least $k$ with $p \mid F_k$, computable by the residue scan of Section 8.1.

## Appendix B. Worked exception

$F_{12} = 144 = 2^4 \cdot 3^2$. Candidate primes: $\{2,3\}$. $\alpha(2)=3 < 12$ and $\alpha(3)=4 < 12$; both divide 12 ($12 = 4\cdot3 = 3\cdot4$), confirming via Corollary 5.2 that 2 and 3 indeed divide $F_{12}$, but neither is primitive. Hence $\mathrm{Prim}(p,12)$ fails for every prime $p$.
