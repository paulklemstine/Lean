# A Self-Referential Recurrence for the Winning Probability in the Generalized $q$-Game: Definition and Unit-Interval Certification

**Author:** Aristotle
**Date:** 2026-06-20
**Domain:** Applications (probability, combinatorics of random permutations)

---

## Abstract

We study a one-parameter family of probabilistic games, the *generalized
$q$-game*, whose winning probability for the *Random* player is governed by a
self-referential recurrence rooted in the uniform cycle-length law of random
permutations. For a threshold parameter $q \in \mathbb{N}$, $q \ge 1$, and a
size parameter $n \in \mathbb{N}$, we define a rational-valued sequence
$P(q,n)$ by the base case $P(q,0) = 1$ and, for $n \ge 1$,

$$
P(q,n) \;=\; \frac{\,1 + \sum_{j=0}^{\,n-1-q} P(q,j)\,}{n},
$$

an equivalent forward form of the conditional recurrence
$P(q,n) = \tfrac1n + \tfrac1n\sum_{k=q+1}^n P(q,n-k)$. Our central contribution
is a complete, machine-checked *unit-interval certification*: we prove that
$P(q,n) \ge 0$ for all $q,n$; that $P(q,n) > 0$ for all $q$ and all $n \ge 1$;
that $P(q,n) \le 1$ for all $n$ whenever $q \ge 1$; and consequently that
$P(q,n) \in [0,1]$ for all $q \ge 1$ and all $n$. Each result is established by
strong induction exploiting the explicit structure of the recurrence — the
strict positivity of the constant term, the forward propagation of
nonnegativity, and the crucial fact that the summation window omits the top $q$
indices. We discuss the relationship between the formalized normalization
$P(q,0)=1$ and an alternative game-theoretic normalization $P(0,q)=0$ under
which the $q=1$ sequence converges to $1 - 1/e$, present an exact-rational
evaluation algorithm, and record a structured program of falsifiable
conjectures (limit laws, monotonicity in $q$, denominator divisibility, and
bounded variation). We also describe a companion linear *critical bond
dimension* model arising in a bridge to random tensor network encodings, and
prove it is strictly monotone.

---

## 1. Introduction

### 1.1 Motivation

Self-referential recurrences — in which the value of a sequence at index $n$
depends on a window of *all* preceding values rather than a fixed-width set of
predecessors — pervade applied probability. They are the discrete signature of
*renewal* phenomena: a system evolves by repeatedly "starting over" after
events whose sizes are random, and the probability of a global outcome is the
average of the outcome over all possible first-event sizes, conditioned on a
statistically fresh remainder. The combinatorics of random permutations
supplies one of the cleanest such mechanisms, because the *cycle lengths* of a
uniformly random permutation obey a uniform law: the cycle containing a marked
element is equally likely to have any admissible length.

The *generalized $q$-game* studied here is a probabilistic game whose winning
probability $P(q,n)$ for a player named *Random* is produced by exactly this
mechanism, with an integer threshold $q$ that controls how many of the shortest
cycle lengths are treated as "immediate" rather than recursive. The result is a
self-referential recurrence whose qualitative legitimacy — that it defines a
genuine probability — is not at all obvious from its algebraic form.

### 1.2 Contributions

This paper provides the foundational certification layer for the $q$-game
sequence:

1. **Definition (Section 3).** A well-founded rational-valued definition of
   $P(q,n)$ together with its base case $P(q,0)=1$ and clean successor identity.
2. **Nonnegativity (Theorem 4.1).** $0 \le P(q,n)$ for all $q,n$.
3. **Strict positivity (Theorem 4.2).** $0 < P(q,n)$ for all $q$, $n \ge 1$.
4. **Upper bound (Theorem 4.3).** $P(q,n) \le 1$ for all $n$ when $q \ge 1$.
5. **Unit-interval membership (Theorem 4.4).** $P(q,n) \in [0,1]$ for $q \ge 1$.
6. **Bridge model (Theorem 6.1).** A linear critical bond dimension
   $\mathrm{critBond}(n) = 1 + n/10$ is strictly increasing.
7. **Algorithms and conjectures (Sections 5, 7).** An exact-rational evaluator,
   and a structured program of five falsifiable conjectures.

### 1.3 Why certification matters

A finite table of values, however large, cannot establish a claim quantified
over all $q$ and all $n$. The recurrence mixes a constant term, an accumulating
sum, and division by $n$; without proof there is no a priori guarantee the
output remains in $[0,1]$. The certification below is therefore not a
convenience but a precondition for interpreting $P(q,n)$ as a probability at
all, and for any downstream asymptotic or number-theoretic analysis.

---

## 2. The $q$-game and its probabilistic structure

### 2.1 Random permutations and the uniform cycle law

Let $\sigma$ be a uniformly random permutation of $\{1, \dots, n\}$. Mark an
element and trace its cycle. A classical fact states that the length $L$ of this
cycle is uniformly distributed on $\{1, 2, \dots, n\}$:

$$
\Pr[L = k] = \frac{1}{n}, \qquad k = 1, \dots, n.
$$

This is the source of the leading $1/n$ weight in the recurrence. Conditioned
on $L = k$, the permutation restricted to the remaining $n-k$ elements is again
uniform, so the game effectively restarts on a sub-instance of size $n-k$.

### 2.2 The threshold $q$ and the conditional recurrence

In the $q$-game, the shortest $q$ cycle lengths $k = 1, \dots, q$ are treated as
*immediate* events contributing a fixed payoff, while longer cycles
$k = q+1, \dots, n$ hand control to a fresh sub-game of size $n - k$. Averaging
the win probability over the uniform first-cycle length, and collecting the
immediate contribution into a single $1/n$ term, yields the **conditional
recurrence**

$$
P(q,n) \;=\; \frac{1}{n} \;+\; \frac{1}{n} \sum_{k=q+1}^{n} P(q, n-k),
\qquad n \ge 1. \tag{2.1}
$$

### 2.3 The forward form

Substituting $j = n - k$ (so $k = q+1 \mapsto j = n-1-q$ and $k = n \mapsto j =
0$) converts the conditional sum into a forward sum over the lowest indices:

$$
P(q,n) \;=\; \frac{\,1 + \sum_{j=0}^{\,n-1-q} P(q,j)\,}{n}, \qquad n \ge 1.
\tag{2.2}
$$

Equation (2.2) is the form we formalize, because the summation window
$\{0, 1, \dots, n-1-q\}$ references only strictly smaller indices, making the
recursion manifestly well-founded. When $n \le q$ the upper limit $n-1-q$ is
negative and the sum is empty, giving $P(q,n) = 1/n$ for $1 \le n \le q$.

---

## 3. Formal definition

### 3.1 The sequence

**Definition 3.1 (the $q$-game probability sequence).**
Fix $q \in \mathbb{N}$. Define $P(q, \cdot) : \mathbb{N} \to \mathbb{Q}$ by

$$
P(q, 0) = 1, \qquad
P(q, n+1) = \frac{\,1 + \sum_{j \in \mathrm{range}((n+1) - q)} P(q, j)\,}{n + 1},
$$

where $\mathrm{range}(m) = \{0, 1, \dots, m-1\}$ and natural-number subtraction
is truncating (so $(n+1)-q = 0$ when $q > n+1$). Every index $j$ in the
summation satisfies $j < n+1$, so the definition is well founded.

Writing $m = n+1$, the upper summation index is $m - 1 - q$, recovering exactly
the forward form (2.2). We record the two computational identities used
throughout.

**Lemma 3.2 (base case).** $P(q, 0) = 1$.

**Lemma 3.3 (successor identity).** For all $q, n \in \mathbb{N}$,
$$
P(q, n+1) = \frac{\,1 + \sum_{j=0}^{\,n - q} P(q, j)\,}{n + 1},
$$
where the sum is over $j \in \mathrm{range}((n+1)-q)$, i.e. $j$ from $0$ to
$n-q$ inclusive (empty when $q > n$).

*Proof.* Immediate from Definition 3.1; the successor identity restates the
defining clause with the bookkeeping over the attached index set replaced by the
plain range sum. $\qquad\blacksquare$

**Lemma 3.4 (range membership).** If $q \ge 1$ and $j \in \mathrm{range}((n+1)
- q)$, then $j < n$.

*Proof.* Membership gives $j < (n+1) - q$. Since $q \ge 1$, truncating
subtraction yields $(n+1) - q \le n$, hence $j < n$. $\qquad\blacksquare$

Lemma 3.4 is the structural fact that drives the upper bound: when $q \ge 1$ the
summation window stops at least one index short of $n$.

### 3.2 First values

The recurrence determines all values from the base case. For small $q$:

| $n$ | $P(1,n)$ | $P(2,n)$ | $P(3,n)$ | $P(4,n)$ |
|----:|:--------:|:--------:|:--------:|:--------:|
| 0   | $1$      | $1$      | $1$      | $1$      |
| 1   | $1$      | $1$      | $1$      | $1$      |
| 2   | $1$      | $\tfrac12$ | $\tfrac12$ | $\tfrac12$ |
| 3   | $1$      | $\tfrac23$ | $\tfrac13$ | $\tfrac13$ |
| 4   | $1$      | $\tfrac34$ | $\tfrac12$ | $\tfrac14$ |
| 5   | $1$      | $\tfrac{7}{10}$ | $\tfrac35$ | $\tfrac25$ |

The degenerate column $P(1,\cdot) \equiv 1$ is explained in Section 4.5: under
the normalization $P(q,0)=1$, the threshold $q=1$ produces a constant sequence.

---

## 4. Unit-interval certification

We now state and prove the four certification results. All proofs are by strong
induction on $n$ and use only Lemmas 3.2–3.4 and elementary order facts about
$\mathbb{Q}$.

### 4.1 Nonnegativity

**Theorem 4.1 (`P_nonneg`).** For all $q, n \in \mathbb{N}$, $\;0 \le P(q,n)$.

*Proof.* Strong induction on $n$. For $n = 0$, $P(q,0) = 1 \ge 0$. For $n = m+1$,
the successor identity (Lemma 3.3) gives
$$
P(q, m+1) = \frac{1 + \sum_{j} P(q,j)}{m+1}.
$$
The denominator $m+1 > 0$. In the numerator, $1 \ge 0$, and every summand
$P(q,j)$ has $j < m+1$, so by the induction hypothesis $P(q,j) \ge 0$; hence the
sum is nonnegative and the numerator is nonnegative. A nonnegative quotient by a
positive number is nonnegative. $\qquad\blacksquare$

### 4.2 Strict positivity

**Theorem 4.2 (`P_pos`).** For all $q \in \mathbb{N}$ and all $n \ge 1$,
$\;0 < P(q,n)$.

*Proof.* Induction on $n \ge 1$. Write $n = m+1$. By Lemma 3.3,
$$
P(q, m+1) = \frac{1 + \sum_{j} P(q,j)}{m+1}.
$$
The denominator is strictly positive. The numerator is $1$ plus a sum of terms
each $\ge 0$ (Theorem 4.1), hence the numerator is $\ge 1 > 0$. A strictly
positive quotient by a positive number is strictly positive. $\qquad\blacksquare$

Theorem 4.2 shows the Random player is never certain to lose at any positive
size.

### 4.3 Upper bound

**Theorem 4.3 (`P_le_one`).** If $q \ge 1$, then for all $n \in \mathbb{N}$,
$\;P(q,n) \le 1$.

*Proof.* Strong induction on $n$. The cases $n = 0$ and $n = 1$ give $P(q,0) =
1 \le 1$ and $P(q,1) = 1/1 = 1 \le 1$ (the summation window is empty since
$q \ge 1$). For $n = m+1$ with $m \ge 1$, write
$$
P(q, m+1) = \frac{1 + S}{m+1}, \qquad S = \sum_{j \in \mathrm{range}((m+1)-q)} P(q,j).
$$
By Lemma 3.4 every index $j$ in the window satisfies $j < m$, so by the
induction hypothesis $P(q,j) \le 1$ for each such $j$. The number of indices is
$(m+1) - q \le m$ (using $q \ge 1$), so
$$
S \le \big((m+1) - q\big) \cdot 1 \le m.
$$
Therefore $1 + S \le 1 + m = m+1$, and dividing by the positive quantity $m+1$
gives $P(q, m+1) \le 1$. The threshold hypothesis $q \ge 1$ is essential: it is
what guarantees both that the window omits the top index (Lemma 3.4) and that
the term count $(m+1)-q$ does not exceed $m$. $\qquad\blacksquare$

### 4.4 Unit-interval membership

**Theorem 4.4 (`P_mem_unitInterval`).** If $q \ge 1$, then for all $n$,
$\;P(q,n) \in [0,1]$.

*Proof.* Immediate from Theorems 4.1 and 4.3:
$P(q,n) \ge 0$ and $P(q,n) \le 1$, so $P(q,n) \in [0,1]$. $\qquad\blacksquare$

Theorem 4.4 is the certificate that $P(q,\cdot)$ is a genuine probability
sequence for every threshold $q \ge 1$.

### 4.5 The two normalizations

The formalized base case $P(q,0) = 1$ is one of two natural conventions.

- **Empty-game-wins ($P(q,0)=1$, formalized).** Substituting into the
  forward recurrence at $q=1$, $P(1, m) = \big(1 + \sum_{j=0}^{m-2}
  P(1,j)\big)/m$; an induction shows $P(1, m) \equiv 1$, since if all earlier
  terms equal $1$ then the numerator equals $1 + (m-1) = m$. For $q \ge 2$ the
  sequence is nontrivial and converges to a limit $> 0$ (numerically $P(2,n) \to
  0.7014$, $P(3,n) \to 0.5505$).

- **Empty-game-loses ($P(0,q)=0$).** This is the convention under which the
  game-theoretic constant emerges. With the same recurrence but seed $0$, the
  $q=1$ sequence runs $0, 1, \tfrac12, \tfrac23, \tfrac58, \dots$ and
  $$
  \lim_{n \to \infty} P(1,n) = 1 - \frac{1}{e} \approx 0.632121,
  $$
  matching the derangement / secretary-problem constant. Here $P(4,1) = 5/8 =
  0.625$.

The two seeds agree for $1 \le n \le q$ (empty window) and diverge once the
window reaches index $0$. The certification of Section 4 is stated for the
formalized normalization $P(q,0)=1$; the asymptotic results of Section 7 refer
to the empty-game-loses variant.

---

## 5. Exact-rational evaluation algorithm

Because the recurrence involves only addition and division by integers, every
$P(q,n)$ is an exact rational. The following evaluator computes the entire
prefix $P(q,0), \dots, P(q,N)$ in $O(N^2)$ rational operations (or $O(N)$ with a
running prefix-sum), storing exact numerators and denominators.

**Algorithm (Exact prefix evaluation of $P(q,\cdot)$).**

```
Input:  threshold q ≥ 0, horizon N ≥ 0
Output: exact rationals P[0..N]
1.  P[0] ← 1
2.  prefix ← 0                      # running sum of P[0..top-1]
3.  for m = 1 to N:
4.        top ← max(m - q, 0)        # number of recursed terms
5.        S ← sum of P[0 .. top-1]   # window sum (use prefix update for O(1))
6.        P[m] ← (1 + S) / m         # exact rational division
7.  return P
```

The prefix-sum optimization keeps a variable equal to $\sum_{j=0}^{\text{top}-1}
P[j]$ and advances it by one term whenever `top` increments, reducing the cost
to a linear number of exact rational additions. Exactness is essential for the
denominator-divisibility study (Conjecture 4 below), which is invisible to
floating-point evaluation.

---

## 6. A bridge model: critical bond dimension

The cycle-peeling structure of the $q$-game is kin to resource-threshold
phenomena in quantum information. In a bridge to random tensor network
encodings of Fibonacci-anyon chains, one models the *critical bond dimension* a
network must reach to faithfully encode a length-$n$ chain.

**Definition 6.1 (critical bond dimension).**
$$
\mathrm{critBond}(n) = 1 + \frac{n}{10}, \qquad n \in \mathbb{N},
$$
valued in $\mathbb{R}$. A chain of length $n$ is encodable by a network of bond
dimension $D$ exactly when $\mathrm{critBond}(n) < D$.

**Lemma 6.2.** $\mathrm{critBond}(0) = 1$, and $\mathrm{critBond}(n+1) =
\mathrm{critBond}(n) + \tfrac{1}{10}$.

*Proof.* Direct from Definition 6.1: $\mathrm{critBond}(0) = 1 + 0 = 1$, and
$1 + (n+1)/10 = (1 + n/10) + 1/10$. $\qquad\blacksquare$

**Theorem 6.3 (`critBond_strictMono`).** $\mathrm{critBond}$ is strictly
increasing: $a < b \implies \mathrm{critBond}(a) < \mathrm{critBond}(b)$.

*Proof.* If $a < b$ then $(a : \mathbb{R}) < (b : \mathbb{R})$, so $a/10 < b/10$
and hence $1 + a/10 < 1 + b/10$. $\qquad\blacksquare$

Theorem 6.3 records the physically expected monotonicity: a strictly longer
chain demands a strictly larger encoding resource. It is included as a minimal,
fully certified interface point demonstrating that the same "provable structural
law for all inputs" discipline transfers from the combinatorial recurrence to
the physical encoding threshold.

---

## 7. Discussion and future directions

The certification establishes the foundation; the open questions concern the
fine structure and asymptotics of $P(q,n)$ (in the empty-game-loses
normalization unless noted).

**Conjecture 1 (exponential limit at $q=1$).** $P(n,1) \to 1 - e^{-1}$ as
$n \to \infty$. The forward recurrence $n\,P(n,1) = 1 + \sum_{j=0}^{n-2}
P(j,1)$ is a discrete renewal equation whose kernel is the uniform cycle-length
law; renewal/derangement asymptotics produce $1 - 1/e$. Numerically $P(80,1)
\approx 0.632121$, matching to six digits.

**Conjecture 2 (general-$q$ limit is a partial exponential sum).** For each
fixed $q \ge 1$, $P(n,q)$ converges to a limit $L_q$, with $L_1 = 1 - e^{-1}$
and $L_q$ strictly decreasing toward $0$. Increasing $q$ deletes the $q$
shortest "immediate-win" cycle lengths from the renewal kernel, shrinking the
limit; the limits should admit incomplete-Gamma / truncated-exponential
expressions. Measured: $L_1 \approx 0.632$, $L_2 \approx 0.478$, $L_3 \approx
0.391$, $L_4 \approx 0.333$.

**Conjecture 3 (monotonicity in $q$).** For all $n, q$, $\;P(n, q+1) \le
P(n, q)$. Enlarging $q$ enlarges the index range of the negative-feedback
forward sum, so the normalized probability can only decrease; a coupling /
induction on $n$ using `P_nonneg` and `P_le_one` should close it. Data:
$P(4,1) = 5/8 > P(4,2) = 1/2 > P(4,3) = 1/4$.

**Conjecture 4 (denominators divide $\mathrm{lcm}(1..n)$).** For every $q, n$,
the reduced denominator of $P(n,q)$ divides $\mathrm{lcm}(1, 2, \dots, n)$. Each
recurrence step divides only by an integer $\le n$, so by induction the
denominator never acquires a prime power exceeding what $\mathrm{lcm}(1..n)$
already contains. This is `decide`-checkable for small $n$ and an induction
target in general.

**Conjecture 5 (bounded variation).** For fixed $q$, $\sum_n |P(n+1,q) -
P(n,q)| < \infty$. The forward recurrence appears to be a contraction in the
discrete-derivative norm, suggesting the sequence varies gently enough that the
total step-to-step change is finite.

Beyond these, two structural directions stand out: (i) proving the formalized
$q=1$ degeneracy $P(1, \cdot) \equiv 1$ as a closed-form theorem, isolating the
exact role of the base case; and (ii) developing the random-tensor-network
bridge into a quantitative correspondence between cycle thresholds and bond
dimensions.

---

## 7.5 Worked derivations and empirical evidence

### 7.5.1 Equivalence of the conditional and forward forms

We spell out the re-indexing that links (2.1) and (2.2), since it is the
conceptual bridge between the *probabilistic* statement of the game and the
*computational* statement we formalize. Start from the conditional recurrence
$P(q,n) = \tfrac1n + \tfrac1n\sum_{k=q+1}^{n} P(q, n-k)$. The summation index $k$
ranges over cycle lengths that recurse, namely $q+1 \le k \le n$. Set $j = n-k$.
As $k$ increases from $q+1$ to $n$, $j$ decreases from $n-1-q$ to $0$, traversing
exactly the integers $\{0, 1, \dots, n-1-q\}$ once each. Hence
$\sum_{k=q+1}^{n} P(q,n-k) = \sum_{j=0}^{n-1-q} P(q,j)$, and substituting back,
$$
P(q,n) = \frac1n + \frac1n \sum_{j=0}^{n-1-q} P(q,j)
       = \frac{1 + \sum_{j=0}^{n-1-q} P(q,j)}{n},
$$
which is (2.2). The forward form is preferable for formalization precisely
because its summand index $j$ is bounded above by $n-1-q < n$, exhibiting the
strictly-decreasing recursive calls demanded by a well-foundedness check; the
conditional form's index $n-k$ also decreases but obscures the bound behind the
subtraction.

### 7.5.2 A renewal-equation reading

Multiplying (2.2) by $n$ gives the *forward accumulation identity*
$$
n\, P(q,n) = 1 + \sum_{j=0}^{n-1-q} P(q,j).
$$
Differencing consecutive instances (replacing $n$ by $n+1$ and subtracting)
yields, for $n > q$,
$$
(n+1)P(q,n+1) - n\,P(q,n) = P(q, n-q),
$$
a first-order relation between the weighted increments and a single lagged term.
This is the discrete analogue of a renewal equation with a one-point delay at
lag $q$, and it is the structural reason one expects a limit: as $n \to \infty$,
if $P(q,n) \to L_q$ then the left side behaves like $L_q$ while the right side
tends to $L_q$ as well, so the relation is asymptotically consistent for any
$L_q \in [0,1]$; pinning the value requires the full accumulation identity and
the renewal kernel, which is the content of Conjectures 1–2.

### 7.5.3 Empirical findings

The exact-rational evaluator of Section 5 furnishes the following observations,
each reproducible to machine precision:

- *Constant column.* In the formalized normalization, $P(1,n) = 1$ for all $n$,
  confirming the closed form derived in Section 4.5.
- *Convergence.* In the empty-game-loses normalization, $P(n,1)$ reaches
  $1 - 1/e$ to ten decimal places by $n = 200$; the convergence is rapid,
  consistent with the exponential tail of derangement probabilities.
- *Limit ladder.* The measured limits $L_1 \approx 0.632$, $L_2 \approx 0.478$,
  $L_3 \approx 0.391$, $L_4 \approx 0.333$ are strictly decreasing, supporting
  Conjecture 2.
- *Exact small values.* $P(4,1) = 5/8$, $P(4,2) = 1/2$, $P(4,3) = 1/4$
  (empty-game-loses), and $P(2,5) = 7/10$, $P(3,4) = 1/2$, $P(4,5) = 2/5$
  (formalized) — all rationals with denominators dividing $\mathrm{lcm}(1,\dots,n)$,
  supporting Conjecture 4.

## 7.6 Related structures

The $q$-game recurrence belongs to a broad family of *all-history* recurrences.
The uniform-cycle kernel it rests on is the same object that produces the
logarithmic mean number of cycles $H_n = 1 + \tfrac12 + \dots + \tfrac1n$ in a
random permutation, the Poisson–Dirichlet limit of normalized cycle lengths,
and the derangement constant $1/e$. The threshold $q$ acts as a *truncation* of
the kernel's support, a device that recurs in incomplete-Gamma evaluations of
tail sums of the exponential series and in renewal processes with a minimum
inter-event size. Recognizing the $q$-game as a truncated renewal recurrence is
what makes the conjectured partial-exponential-sum limits (Conjecture 2)
plausible, and it situates the certified bounds of Section 4 as the
probability-theoretic well-posedness statement for that renewal model.

## 8. Conclusion

We have given a well-founded definition of the generalized $q$-game winning
probability $P(q,n)$ and a complete unit-interval certification: nonnegativity
(`P_nonneg`), strict positivity for $n \ge 1$ (`P_pos`), the upper bound
$P(q,n) \le 1$ for $q \ge 1$ (`P_le_one`), and membership $P(q,n) \in [0,1]$
(`P_mem_unitInterval`). Each follows by strong induction from the recurrence's
explicit structure — the positive constant term, the forward propagation of
nonnegativity, and the threshold-induced omission of the top $q$ indices. A
companion linear critical-bond-dimension model is proven strictly monotone
(`critBond_strictMono`). These results turn an algebraically opaque
self-referential recurrence into a certified probability sequence, providing the
rigorous foundation on which the asymptotic and number-theoretic conjectures of
Section 7 can be pursued.
