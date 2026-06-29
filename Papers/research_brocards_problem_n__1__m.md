# Brocard's Problem through a Borel–Cantelli Lens: A Rigorous Probabilistic Finiteness Theorem with Elementary and Computational Constraints

**Author:** Aristotle

**Date:** 2026-06-24

**Domain:** Probability / Number Theory (Bridges)

---

## Abstract

Brocard's problem asks for all pairs of natural numbers $(n, m)$ satisfying $n! + 1 = m^2$. The only known solutions are $n \in \{4, 5, 7\}$ — the *Brown numbers* — and it is a long-standing open conjecture that no others exist. We present a self-contained probabilistic treatment of the finiteness phenomenon, together with the elementary number theory and an exhaustive finite verification.

Our central contribution is a rigorous reformulation of the classical density heuristic as an unconditional measure-theoretic theorem. The heuristic estimates the "probability" that a number of size $n!$ is a perfect square as $\sim 1/\sqrt{n!}$; since $\sum_n 1/\sqrt{n!} < \infty$, the first Borel–Cantelli lemma predicts that almost surely only finitely many such events occur. We prove (i) that the density series $\sum_n 1/\sqrt{n!}$ converges, via a geometric comparison through $n! \ge 2^{\,n-1}$; (ii) that for any family of events $E_n$ in an arbitrary outer-measure space with $\mu(E_n) \le C/\sqrt{n!}$, the set of points lying in infinitely many $E_n$ is null, i.e. almost every point lies in only finitely many $E_n$. The single non-rigorous step of the classical heuristic — the modelling bound $\mu(E_n) \lesssim 1/\sqrt{n!}$ — is isolated as an explicit hypothesis.

We complement this with three exact structural constraints on genuine solutions: oddness of $m$, the factorization $(m-1)(m+1) = n!$, and a Wilson-theorem obstruction forcing $m \ge p$ whenever $n = p - 1$ is one less than a prime $p$. Finally, an exhaustive computational census confirms that $\{4, 5, 7\}$ are the only Brown numbers below $1000$.

---

## 1. Introduction

### 1.1 The problem and its history

Let $n! = \prod_{k=1}^{n} k$ denote the factorial, with $0! = 1! = 1$. **Brocard's problem** asks:

> For which natural numbers $n$ does there exist a natural number $m$ with $n! + 1 = m^2$?

The known solutions are
$$4! + 1 = 25 = 5^2, \qquad 5! + 1 = 121 = 11^2, \qquad 7! + 1 = 5041 = 71^2,$$
so that $n \in \{4, 5, 7\}$. These values of $n$ are the **Brown numbers**. The problem was posed by Henri Brocard in 1876 and again, independently, by Srinivasa Ramanujan in 1913. Whether the three known solutions are the only ones remains open.

The problem connects to the deepest currents in modern number theory. A consequence of the **ABC conjecture** is that the equation $n! + 1 = m^2$ has only finitely many solutions; more generally, polynomial–factorial Diophantine equations of this type are governed by $abc$-type bounds. Unconditionally, however, even finiteness is not known.

### 1.2 Why a probabilistic treatment

The expectation that $\{4,5,7\}$ is the complete list rests on a *density heuristic*. The perfect squares near a magnitude $N$ are spaced approximately $2\sqrt{N}$ apart; hence a "random" integer of size $N = n!$ is a perfect square with probability of order $1/\sqrt{N} = 1/\sqrt{n!}$. Treating the events
$$E_n = \{\, n! + 1 \text{ is a perfect square} \,\}$$
as independent trials with $\Pr[E_n] \asymp 1/\sqrt{n!}$, the *expected* number of solutions across all $n$ is
$$\sum_{n} \Pr[E_n] \;\asymp\; \sum_n \frac{1}{\sqrt{n!}} < \infty.$$
By the first Borel–Cantelli lemma, a convergent sum of event-probabilities forces almost-sure finiteness of the number of events that occur. This is the standard explanation for why Brocard's equation "should" have only finitely many solutions.

Our purpose is to make precise exactly *which part of this story is a theorem*. The convergence of the series and the Borel–Cantelli deduction are unconditional mathematics. The only fiction is the modelling bound $\mu(E_n) \lesssim 1/\sqrt{n!}$, which we expose as an explicit hypothesis. The result is a clean conditional theorem whose hypotheses are transparent.

### 1.3 Contributions

1. **Convergence of the density series** (Theorem 4.1): $\sum_n 1/\sqrt{n!}$ is summable, by geometric comparison through $n! \ge 2^{\,n-1}$.
2. **The Brocard–Borel–Cantelli theorem** (Theorem 5.1): in any outer-measure space, if $\mu(E_n) \le C/\sqrt{n!}$ for all $n$, then $\mu(\limsup_n E_n) = 0$; equivalently almost every point lies in only finitely many $E_n$ (Theorem 5.2).
3. **Exact structural constraints** (Section 3): $m$ is odd for $n \ge 2$; the factorization $(m-1)(m+1) = n!$; and the Wilson obstruction $p \mid m$, hence $m \ge p$, when $n = p-1$ with $p$ prime.
4. **Exhaustive verification** (Theorem 2.2): the only Brown numbers below $1000$ are $4, 5, 7$.

All statements are formalized and machine-checked.

---

## 2. The known solutions and a finite census

### 2.1 A decidable perfect-square test

To verify candidates computationally we use a Boolean perfect-square predicate built from the integer square root $\lfloor \sqrt{\cdot} \rfloor$ (denoted $\mathrm{isqrt}$):
$$\mathrm{isPerfectSquareB}(N) = \bigl[\, \mathrm{isqrt}(N)^2 = N \,\bigr].$$
This is correct because $\mathrm{isqrt}(N)$ returns the largest integer whose square does not exceed $N$, so $\mathrm{isqrt}(N)^2 = N$ holds precisely when $N$ is a perfect square. Critically, $\mathrm{isqrt}$ is computable in a number of big-integer operations that is logarithmic in the size of $N$, which makes the test feasible even for factorials with thousands of digits.

### 2.2 The three Brown numbers

By direct arithmetic:
$$4! + 1 = 25 = 5^2, \qquad 5! + 1 = 121 = 11^2, \qquad 7! + 1 = 5041 = 71^2.$$
These are the statements `brown_four`, `brown_five`, `brown_seven`.

**Theorem 2.2 (exhaustive census, `brocard_no_others_below_1000`).** *Among all $n$ with $0 \le n < 1000$, the only values for which $n! + 1$ is a perfect square are $4, 5, 7$. Formally,*
$$\{\, n \in [0, 1000) : \mathrm{isPerfectSquareB}(n! + 1) \,\} = \{4, 5, 7\}.$$

*Proof sketch.* The claim is a finite conjunction of decidable propositions. One enumerates $n = 0, 1, \dots, 999$, computes $n! + 1$ exactly with big-integer arithmetic, applies $\mathrm{isPerfectSquareB}$, and collects the survivors. Although $999!$ has roughly $2{,}568$ decimal digits, each square-root test costs only $O(\log N)$ big-number multiplications, so the entire sweep is fast. The computation returns exactly the list $[4, 5, 7]$. $\qquad\blacksquare$

This census makes the conjecture concrete: any fourth Brown number, should it exist, must exceed $1000$, and hence its factorial exceeds a number with thousands of digits.

---

## 3. Exact structural constraints

A genuine solution of $n! + 1 = m^2$ is rigid in several exact ways. These are unconditional theorems, independent of the probabilistic model.

### 3.1 Parity of the root

**Theorem 3.1 (`brocard_m_odd`).** *If $n \ge 2$ and $n! + 1 = m^2$, then $m$ is odd.*

*Proof sketch.* For $n \ge 2$, the factorial $n!$ contains the factor $2$, so $n!$ is even and $n! + 1$ is odd. A perfect square is odd only if its root is odd; hence $m$ is odd. (The mechanized proof refines this by reducing modulo $4$: for $n \ge 4$, $n!$ is divisible by $4$, so $m^2 \equiv 1 \pmod 4$, which is incompatible with $m$ even; the small cases $n = 2, 3$ are checked directly.) The known roots $5, 11, 71$ are all odd. $\qquad\blacksquare$

### 3.2 The difference-of-squares factorization

**Theorem 3.2 (`brocard_factor`).** *If $m \ge 1$ and $n! + 1 = m^2$, then*
$$(m-1)(m+1) = n!.$$

*Proof sketch.* From $n! + 1 = m^2$ we get $n! = m^2 - 1$. Since $m \ge 1$, the natural-number subtraction is genuine and the difference-of-squares identity $m^2 - 1 = (m-1)(m+1)$ applies, giving $(m-1)(m+1) = n!$. $\qquad\blacksquare$

This identity is the principal tool in classical attacks: it converts the problem into the question of when $n!$ admits a factorization into two factors differing by exactly $2$. For $n = 7$, this reads $70 \cdot 72 = 5040 = 7!$.

### 3.3 The Wilson obstruction

Recall **Wilson's theorem**: for any prime $p$, $(p-1)! \equiv -1 \pmod p$, equivalently $p \mid (p-1)! + 1$.

**Theorem 3.3 (`brocard_wilson_dvd`).** *Let $p$ be prime and suppose $(p-1)! + 1 = m^2$. Then $p \mid m$.*

*Proof sketch.* By Wilson's theorem $p \mid (p-1)! + 1 = m^2$. Since $p$ is prime and divides $m^2$, Euclid's lemma (a prime dividing a power divides the base) gives $p \mid m$. $\qquad\blacksquare$

**Theorem 3.4 (`brocard_wilson_ge`).** *Under the hypotheses of Theorem 3.3, $p \le m$.*

*Proof sketch.* We have $p \mid m$ by Theorem 3.3, and $m > 0$ (since $m^2 = (p-1)! + 1 \ge 2 > 0$). A positive multiple of $p$ is at least $p$, so $m \ge p$. $\qquad\blacksquare$

Interpreted in the original variables: if $n + 1 = p$ is prime, then any solution forces $m \ge p = n + 1$, so the square root of $n! + 1$ cannot be small — it is bounded below by the next integer when that integer is prime. This is a genuine exact constraint and is the seed of conjectural unconditional progress (see Section 8, C5).

---

## 4. The analytic heart: convergence of the density series

The probabilistic argument rests on a single analytic fact.

**Theorem 4.1 (`summable_inv_sqrt_factorial`).** *The series*
$$\sum_{n=0}^{\infty} \frac{1}{\sqrt{n!}}$$
*converges.*

*Proof sketch.* Two equivalent routes establish summability.

*Geometric comparison.* For all $n \ge 1$, $n! \ge 2^{\,n-1}$ (each of the $n-1$ factors $2, 3, \dots, n$ is at least $2$). Taking square roots and reciprocals,
$$\frac{1}{\sqrt{n!}} \;\le\; \frac{1}{\sqrt{2^{\,n-1}}} \;=\; \sqrt{2}\cdot\Bigl(\tfrac{1}{\sqrt{2}}\Bigr)^{\!n}.$$
The dominating series $\sum_n \sqrt{2}\,(1/\sqrt 2)^n$ is geometric with ratio $1/\sqrt 2 < 1$, hence convergent; by comparison the original series converges.

*Ratio test (the formalized route).* Writing $a_n = 1/\sqrt{n!}$,
$$\frac{a_{n+1}}{a_n} = \sqrt{\frac{n!}{(n+1)!}} = \frac{1}{\sqrt{n+1}} \xrightarrow[n\to\infty]{} 0.$$
In particular the ratio is eventually $\le 2/3$ (indeed for $n \ge 8$, $1/\sqrt{n+1} \le 1/3 < 2/3$), so the ratio test gives convergence. $\qquad\blacksquare$

**Corollary 4.2 (`summable_const_div_sqrt_factorial`).** *For every real constant $C$, the series $\sum_n C/\sqrt{n!}$ converges,* being a scalar multiple of a convergent series.

**Corollary 4.3 (`tsum_ofReal_heuristic_ne_top`).** *For $C \ge 0$, the extended-nonnegative-real sum*
$$\sum_{n=0}^{\infty} \mathrm{ofReal}\!\left(\frac{C}{\sqrt{n!}}\right) \in [0, \infty]$$
*is finite (not $+\infty$).*

*Proof sketch.* Each term is nonnegative, so the $[0,\infty]$-valued sum equals the real-valued sum of Corollary 4.2 cast into the extended reals; a finite real value casts to a finite extended value. $\qquad\blacksquare$

The numerical value of the sum is $\sum_n 1/\sqrt{n!} \approx 3.4695$.

---

## 5. The probabilistic finiteness theorem

We now state the central result. It applies in any space carrying an outer measure $\mu$ — in particular any probability space. We write $\limsup_n E_n = \{x : x \in E_n \text{ for infinitely many } n\}$ for the set of points hit infinitely often.

**Theorem 5.1 (Brocard–Borel–Cantelli, `brocard_heuristic_finite`).** *Let $\mu$ be an outer measure on a space $\alpha$, let $(E_n)_{n\in\mathbb N}$ be any sequence of subsets of $\alpha$, let $C \ge 0$, and suppose the* **Brocard density bound**
$$\mu(E_n) \le \mathrm{ofReal}\!\left(\frac{C}{\sqrt{n!}}\right) \qquad (\forall n)$$
*holds. Then*
$$\mu\bigl(\{\, x : x \in E_n \text{ infinitely often} \,\}\bigr) = 0.$$

*Proof sketch.* This is the first Borel–Cantelli lemma. Summing the hypothesis,
$$\sum_n \mu(E_n) \le \sum_n \mathrm{ofReal}\!\left(\frac{C}{\sqrt{n!}}\right) < \infty$$
by Corollary 4.3. The measure-theoretic Borel–Cantelli lemma states that whenever $\sum_n \mu(E_n) < \infty$, the limsup set is null. Applying it yields $\mu(\limsup_n E_n) = 0$. $\qquad\blacksquare$

**Theorem 5.2 (a.e. finiteness, `brocard_heuristic_ae_finite`).** *Under the hypotheses of Theorem 5.1, for $\mu$-almost every $x$ the index set $\{ n : x \in E_n \}$ is finite.*

*Proof sketch.* The complement of "lies in finitely many $E_n$" is exactly "lies in infinitely many $E_n$," i.e. membership in $\limsup_n E_n$. Theorem 5.1 makes that set null, so its complement is a full-measure (almost-everywhere) set. $\qquad\blacksquare$

### 5.1 Application to Brocard's problem

Instantiate $E_n$ as the event modelling "$n! + 1$ is a perfect square," in whatever probabilistic model one adopts for the integers near $n!$. The density heuristic asserts precisely that $\mu(E_n) \lesssim 1/\sqrt{n!}$, i.e. the Brocard density bound with some constant $C$. Theorem 5.2 then yields: *almost surely, only finitely many of the events $E_n$ occur* — the precise sense in which Brocard's equation "should" have only finitely many solutions.

The logical structure is worth emphasizing. The deduction "density bound $\Rightarrow$ a.s. finiteness" is an **unconditional theorem**. The only assumption injected from outside mathematics is the density bound itself, which is a statement about how square-like the values $n! + 1$ are. By isolating it as the hypothesis `hbound`, we draw a sharp line between rigorous probability and number-theoretic modelling.

---

## 6. Algorithms

### 6.1 Brown-number census

The exhaustive verification (Theorem 2.2) is the following procedure.

```
Input: bound N
Output: list of n in [0, N) with n! + 1 a perfect square
fact <- 1                      # maintain n! incrementally
result <- []
for n in 0 .. N-1:
    if n > 0: fact <- fact * n
    cand <- fact + 1
    r <- isqrt(cand)           # integer square root, O(log cand) big-mults
    if r * r == cand:
        result.append(n)
return result
```

Maintaining $n!$ incrementally avoids recomputation; the dominant cost per step is the integer-square-root test, which uses Newton iteration (or Lean's `Nat.sqrt`) in $O(\log \text{cand})$ big-integer multiplications. Over the range $[0, 1000)$ the procedure returns $[4, 5, 7]$.

### 6.2 Partial-sum estimation of the density series

To certify convergence numerically one computes partial sums $S_N = \sum_{n=0}^{N} 1/\sqrt{n!}$ together with the geometric tail bound. Since $1/\sqrt{n!} \le \sqrt 2 (1/\sqrt2)^n$, the tail beyond $N$ is at most $\sqrt2\,(1/\sqrt2)^{N+1}/(1 - 1/\sqrt2)$, giving a rigorous enclosure of the limit $\approx 3.4695$.

---

## 7. Discussion

### 7.1 What is and is not proved

We have *not* resolved Brocard's problem. What we have established is a faithful, fully rigorous account of the probabilistic finiteness heuristic, with its sole modelling assumption laid bare. The convergence of $\sum 1/\sqrt{n!}$ and the Borel–Cantelli passage to a.s. finiteness are theorems; the density bound is a hypothesis. In addition, the exact constraints (oddness, factorization, Wilson obstruction) and the finite census are unconditional facts about genuine solutions.

### 7.2 Robustness of the heuristic

The argument is remarkably robust. The convergence of the density series is so strong (faster than any geometric series, since $1/\sqrt{n!}$ decays super-exponentially) that the conclusion survives large perturbations of the model: replacing the bound $C/\sqrt{n!}$ by $C \cdot n^k / \sqrt{n!}$ for any fixed $k$, or by the sharper bound relevant to higher powers $n! + 1 = m^j$, still leaves a convergent series and hence the same a.s.-finiteness conclusion. This explains why the same heuristic predicts finiteness for many variants simultaneously (Section 8).

### 7.3 The interplay of exact and probabilistic structure

The exact constraints and the probabilistic prediction reinforce one another. The Wilson obstruction shows that solution roots are pinned from below by primes; the factorization shows solutions correspond to near-equal splittings of $n!$; and the density heuristic explains why such splittings should be exhausted after finitely many $n$. A complete proof of Brocard's conjecture would presumably weld the exact structure (Section 3) to a genuine, non-heuristic upper bound on $\mu(E_n)$ — precisely the gap that the ABC conjecture would, conditionally, fill.

### 7.4 Relation to the ABC conjecture

The ABC conjecture asserts that for coprime positive integers $a + b = c$ and any $\varepsilon > 0$, one has $c \le K_\varepsilon \cdot \mathrm{rad}(abc)^{1+\varepsilon}$, where $\mathrm{rad}(N)$ is the product of the distinct primes dividing $N$. Applied to the triple $a = n!$, $b = 1$, $c = m^2$ arising from a Brocard solution, this becomes a statement comparing the size of $m^2 \approx n!$ to the radical of $n! \cdot m^2$. Because $n!$ is extraordinarily "smooth" — it is divisible by every prime up to $n$, but its radical $\mathrm{rad}(n!) = \prod_{p \le n} p$ is, by the prime number theorem, only of size $e^{(1+o(1))n}$, vastly smaller than $n! \approx e^{n \ln n}$ — the ABC inequality forces the perfect power $m^2$ to be far smaller than $n!$ for all large $n$, leaving room for only finitely many solutions. This is the standard route by which ABC implies the finiteness of Brocard solutions, and indeed the finiteness of solutions to $n! + A = m^k$ for fixed $A \ne 0$ and $k \ge 2$. The probabilistic finiteness theorem of this paper (Theorem 5.2) can be read as the *unconditional* shadow of that conditional implication: the smoothness of $n!$ that makes the radical small is the same arithmetic fact that makes squares near $n!$ rare, and rarity — quantified as $\mu(E_n) \lesssim 1/\sqrt{n!}$ — is exactly the density bound that drives Borel–Cantelli.

### 7.5 Related Diophantine context

Equations pitting a factorial against a polynomial value belong to a well-studied family. The closely related Erdős–Obláth and Pollack–Shapiro investigations concern $n! \pm 1 = m^k$ and $n! = m^k \pm 1$, and the general principle — factorials are rarely near perfect powers — recurs throughout. What distinguishes the present treatment is methodological: rather than seeking a direct elementary contradiction (which, for Brocard, remains elusive), we quantify the expected scarcity of solutions and prove that scarcity is, in the precise measure-theoretic sense of Theorem 5.2, almost-sure. The elementary constraints of Section 3 then serve as exact sieves that any putative large solution must survive, narrowing the search space that the probabilistic argument predicts to be ultimately empty.

---

## 8. Future directions

The following concrete, testable conjectures emerged from this cycle.

**C1 — Second Borel–Cantelli sharpness (independence fails).** If the events $E_n$ were independent with $\mu(E_n) \asymp 1/\sqrt{n!}$, the *second* Borel–Cantelli lemma would not trigger (the sum converges). Conjecture: one can construct an explicit probability space and an independent family with $\mu(E_n) = c/\sqrt{n!}$ realizing the bound of Theorem 5.1 with equality in the sum, showing the first-lemma bound is tight. Testable on $(\mathbb N \to \mathrm{Bool})$ with a product measure.

**C2 — Generalized Brocard $n! + A = m^2$.** For fixed nonzero $A$, the same density heuristic gives $\sum 1/\sqrt{n!} < \infty$, so finitely many solutions are expected for every $A$. Conjecture: for each fixed nonzero $A$ the solution set $\{ n : n! + A \text{ is a perfect square}\}$ is finite; the abstract Theorem 5.1 proves the measure-theoretic version verbatim, only the bound hypothesis changing. Testable via exhaustive census tables for $A \in \{-1, 1, 2, 3, 5\}$.

**C3 — Power generalization $n! + 1 = m^k$.** Conjecture: for $k \ge 2$, $n! + 1 = m^k$ has solutions only for $(n,k) \in \{(4,2),(5,2),(7,2)\}$. The density heuristic is even stronger ($\sum n!^{-(k-1)/k}$ converges faster). Testable by census over $n < 1000$, $2 \le k \le 10$, then a sharper-bound instantiation of Theorem 5.1.

**C4 — Quantitative density of near-misses.** Define the deficiency $d(n) = m^2 - (n!+1)$ where $m = \lceil \sqrt{n!+1}\,\rceil$. Conjecture: $d(n)/\sqrt{n!}$ is equidistributed in $[0,1)$ (the fractional-part heuristic behind C1). Testable by computing the empirical distribution of $\{\sqrt{n!+1}\}$ for $n \le 5000$ and comparing to uniform; formalizable as a measure-theoretic equidistribution statement.

**C5 — Wilson-prime obstruction bridge.** This cycle proved the Wilson step ($p \mid m$, hence $m \ge p = n+1$, for $n+1 = p$ prime). Conjecture: combining this with $(m-1)(m+1) = n!$ — writing $m = p t$, so $(pt-1)(pt+1) = (p-1)!$, where the $p$-adic valuation of the right side is small while the left forces $p^2 \mid (p-1)! + 1$ under further congruences — yields an unconditional contradiction for a positive-density set of $n$ with $n+1$ prime. Testable by formalizing the $p$-adic valuation count of $(p-1)!$ and searching for the second congruence that closes the gap.

---

## 9. Conclusion

Brocard's problem — find all $n$ with $n! + 1 = m^2$ — is a deterministic question with, apparently, only three answers: $n = 4, 5, 7$. We have given a rigorous probabilistic explanation of that scarcity by proving the density series $\sum 1/\sqrt{n!}$ convergent and deriving, via the first Borel–Cantelli lemma, an unconditional measure-theoretic finiteness theorem for any family of events satisfying the Brocard density bound. We isolated the heuristic's only non-rigorous ingredient as an explicit hypothesis, supplied three exact constraints on genuine solutions (oddness, the difference-of-squares factorization, and the Wilson obstruction), and confirmed by exhaustive search that no fourth Brown number exists below $1000$. Together these results turn a folklore heuristic into precise mathematics and chart a clear path toward the open conjecture.
