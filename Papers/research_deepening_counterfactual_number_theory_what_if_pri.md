# Counterfactual Number Theory: A Borel–Cantelli Dictionary for Random Primes

## Abstract

We study a *counterfactual number theory* in which the primes of ordinary
arithmetic are replaced by a random subset of the natural numbers. Following
Cramér's classical heuristic, each integer $n$ is declared "prime" independently
with probability equal to the local prime density $1/\log n$ predicted by the
Prime Number Theorem. Within this probabilistic model we determine exactly which
theorem of elementary number theory survives the transition to randomness and
which collapses. Our central result is a *dictionary* translating the qualitative
behavior of the random model into a single analytic condition: the random prime
set is infinite almost surely if and only if the associated *prime-density
series* $\sum_n p_n$ diverges. Instantiating $p_n = 1/\log(n+2)$, a one-line
comparison $\log x \le x$ shows the density series diverges, so — by the second
Borel–Cantelli lemma — infinitely many integers are random primes almost surely.
Conversely, for any density decaying at least as fast as $1/(n+2)^2$, the density
series converges and — by the first Borel–Cantelli lemma — only finitely many
integers are prime almost surely. Thus the survival of *Euclid's theorem on the
infinitude of primes* is located exactly at the convergence/divergence boundary
of the density series, a sharp phase transition. We contrast this with the
*collapse of unique factorization*, which has no probabilistic analogue, and we
outline the model's role as a heuristic engine in analytic number theory.

**Keywords:** Cramér random model, prime density, Borel–Cantelli lemmas,
zero–one law, harmonic series, Prime Number Theorem, unique factorization,
counterfactual number theory.

---

## 1. Introduction

The distribution of the prime numbers exhibits a striking duality. On one hand,
primes are rigidly deterministic: they are defined by an exact multiplicative
condition, and every integer factors into them uniquely (the Fundamental Theorem
of Arithmetic). On the other hand, empirically the primes behave in many respects
like a *random* set of integers of the appropriate density. This observation was
crystallized by Harald Cramér in the 1930s into a *probabilistic model of the
primes*: replace the primes by a random set $S \subseteq \mathbb{N}$ in which each
integer $n$ is included independently with probability $1/\log n$. The choice of
density is dictated by the **Prime Number Theorem** (PNT), $\pi(n) \sim n/\log n$,
which makes $1/\log n$ the natural "probability that $n$ is prime."

The Cramér model has been extraordinarily successful as a *heuristic*: it predicts
the correct order of magnitude for prime gaps, motivates the Hardy–Littlewood
conjectures on prime constellations, and reproduces the Prime Number Theorem
itself. But the model also invites a foundational question, which we pursue here
in a self-contained and rigorous form:

> **Counterfactual question.** In the random universe where primes are replaced by
> a random set of prescribed density, which theorems of ordinary number theory
> survive, and which collapse?

We give a complete answer for the most fundamental prime fact of all — Euclid's
theorem that there are infinitely many primes — and show that its fate is governed
by a clean zero–one law. The mathematical core is a *bridge* between two
disciplines:

- **Probability / measure theory:** the two Borel–Cantelli lemmas and the zero–one
  behavior of $\mu(\limsup)$; and
- **Analytic number theory:** the *prime-density series* $\sum_n 1/\log n$, whose
  divergence is the PNT-flavored input.

The bridge reads: *the random model has infinitely many primes almost surely if
and only if the density series diverges.* Cramér's density $1/\log n$ lands on the
divergent side, so infinitude survives; densities decaying faster than $1/n$ land
on the convergent side, so infinitude collapses. The threshold is a genuine
phase transition.

### 1.1. Contributions

1. A precise formulation of the Cramér random prime model as a probability space
   with independent measurable events of prescribed probabilities (Section 3).
2. A rigorous proof that the prime-density series $\sum_n 1/\log(n+2)$ diverges,
   via comparison with the harmonic series (Section 4).
3. The survival theorem: divergent density implies infinitely many random primes
   almost surely, via the second Borel–Cantelli lemma (Section 5).
4. The collapse theorem: a summable density (e.g. $1/(n+2)^2$) implies finitely
   many random primes almost surely, via the first Borel–Cantelli lemma
   (Section 5).
5. A discussion of the phase transition, of the non-survival of unique
   factorization, and of the model's role as a heuristic (Sections 6–7).

---

## 2. Preliminaries and notation

We work over the natural numbers $\mathbb{N} = \{0, 1, 2, \dots\}$. All measures
are on a fixed probability space $(\Omega, \mathcal{F}, \mu)$ with $\mu(\Omega) =
1$. For a sequence of events (measurable sets) $A_n \subseteq \Omega$, the event
"infinitely many $A_n$ occur" is the *limit superior*
$$\limsup_{n} A_n \;=\; \bigcap_{N=0}^{\infty} \bigcup_{n \ge N} A_n
\;=\; \{\omega : \omega \in A_n \text{ for infinitely many } n\}.$$

We recall the two classical lemmas that drive everything.

**Lemma 2.1 (First Borel–Cantelli).** *For any sequence of events $A_n$,*
$$\sum_{n} \mu(A_n) < \infty \;\Longrightarrow\; \mu\!\left(\limsup_n A_n\right) = 0.$$
*No independence hypothesis is required.*

*Proof sketch.* For each $N$, $\limsup_n A_n \subseteq \bigcup_{n \ge N} A_n$, so
$\mu(\limsup_n A_n) \le \sum_{n \ge N}\mu(A_n)$. The right side is the tail of a
convergent series, hence $\to 0$ as $N \to \infty$. $\square$

**Lemma 2.2 (Second Borel–Cantelli).** *If the events $A_n$ are mutually
independent and $\sum_n \mu(A_n) = \infty$, then*
$$\mu\!\left(\limsup_n A_n\right) = 1.$$

*Proof sketch.* It suffices to show $\mu\big(\bigcup_{n\ge N} A_n\big) = 1$ for
each $N$, i.e. $\mu\big(\bigcap_{n \ge N} A_n^c\big) = 0$. By independence and the
inequality $1 - x \le e^{-x}$,
$$\mu\Big(\bigcap_{n=N}^{M} A_n^c\Big) = \prod_{n=N}^{M}\big(1 - \mu(A_n)\big)
\le \exp\!\Big(-\sum_{n=N}^{M}\mu(A_n)\Big) \xrightarrow[M\to\infty]{} 0,$$
since the exponent diverges. $\square$

Together these lemmas give a **zero–one law**: for independent events, $\mu(\limsup
A_n)$ is $1$ if $\sum \mu(A_n) = \infty$ and $0$ if $\sum \mu(A_n) < \infty$.

---

## 3. The Cramér random prime model

**Definition 3.1 (Random prime set).** A *random prime model* consists of a
probability space $(\Omega, \mathcal{F}, \mu)$ together with a sequence of
measurable events $s_n \subseteq \Omega$, $n \in \mathbb{N}$, where $s_n$ is
interpreted as the event "$n$ is a random prime." The random prime set is
$S(\omega) = \{n : \omega \in s_n\}$.

**Definition 3.2 (Cramér density).** The *Cramér prime density* at $n$ is
$$p_n \;=\; \frac{1}{\log(n+2)}.$$
The shift by $2$ ensures $\log(n+2) \ge \log 2 > 0$ for all $n \in \mathbb{N}$,
avoiding the singularities $\log 1 = 0$ and $\log 0$ while leaving the asymptotic
$p_n \sim 1/\log n$ unchanged. The **prime-density series** is $\sum_n p_n$.

**Definition 3.3 (Cramér model).** A random prime model *realizes the Cramér
density* if the events $s_n$ are mutually independent and $\mu(s_n) \ge p_n$ for
all $n$. (We use a lower bound on the probabilities, which is all the survival
theorem requires; the canonical model has equality.)

**Remark 3.4 (Genuineness).** These hypotheses are satisfiable and hence
non-vacuous: take $\Omega = \prod_n \{0,1\}$ with the product of Bernoulli
measures $\mathrm{Ber}(p_n)$ and $s_n = \{\omega : \omega_n = 1\}$. Then the
$s_n$ are independent with $\mu(s_n) = p_n$ exactly. We keep the results at the
level of hypotheses to isolate the mathematical content of the bridge; Section 8
discusses making the construction explicit.

---

## 4. The prime-density series diverges

The analytic-number-theory half of the bridge is the divergence of the
prime-density series. It rests on a single soft comparison.

We record the reasoning in $\overline{\mathbb{R}}_{\ge 0} = [0,\infty]$ (the
extended nonnegative reals), where infinite sums are always defined and monotone
comparison of series is automatic.

**Lemma 4.1 (Comparison step).** *For every $n \in \mathbb{N}$,*
$$\frac{1}{n+2} \;\le\; \frac{1}{\log(n+2)}.$$

*Proof.* Set $x = n + 2 \ge 2$. The inequality $\log x \le x$ holds for all
$x > 0$ (it is the standard bound $\log x \le x - 1 \le x$, or the tangent-line
estimate for the concave function $\log$). Moreover $\log x > 0$ since $x \ge 2 >
1$. Both $\log x$ and $x$ are positive, so taking reciprocals reverses the
inequality: $1/x \le 1/\log x$. $\square$

**Lemma 4.2 (Divergence of the shifted harmonic series).** *The series
$\sum_{n} 1/(n+2)$ diverges.*

*Proof.* The harmonic series $\sum_n 1/n$ diverges. Deleting or shifting finitely
many terms does not affect convergence, so $\sum_n 1/(n+2)$ diverges as well.
$\square$

**Theorem 4.3 (Prime-density series diverges).**
$$\sum_{n} \frac{1}{\log(n+2)} \;=\; \infty.$$

*Proof.* By Lemma 4.1 the terms of the prime-density series dominate those of the
shifted harmonic series term by term, so by monotone comparison
$$\sum_n \frac{1}{n+2} \;\le\; \sum_n \frac{1}{\log(n+2)}.$$
The left side is $\infty$ by Lemma 4.2, hence so is the right side. $\square$

This is the PNT-flavored input to the bridge: the local prime density $1/\log n$
decays *just slowly enough* that its running total is unbounded. It is precisely
this failure to converge that will keep the primes infinite.

---

## 5. The dictionary: survival and collapse of infinitude

We now combine the analytic input of Section 4 with the probabilistic machinery
of Section 2 to obtain the main theorems. Throughout, $s : \mathbb{N} \to
\mathcal{F}$ is a sequence of events in a probability space.

### 5.1. Survival of infinitude

**Theorem 5.1 (Survival of infinitude in the Cramér model).** *Let $(s_n)$ be
mutually independent measurable events with $\mu(s_n) \ge 1/\log(n+2)$ for all
$n$. Then*
$$\mu\!\left(\limsup_n s_n\right) = 1;$$
*that is, almost surely infinitely many integers are random primes.*

*Proof.* By monotonicity of the sum and the density hypothesis,
$$\sum_n \frac{1}{\log(n+2)} \;\le\; \sum_n \mu(s_n).$$
The left side is $\infty$ by Theorem 4.3, so $\sum_n \mu(s_n) = \infty$. The
events are independent, so the second Borel–Cantelli lemma (Lemma 2.2) gives
$\mu(\limsup_n s_n) = 1$. $\square$

Theorem 5.1 is the probabilistic reincarnation of Euclid's theorem. It says that
*Euclid's theorem survives the passage to randomness*, and survives with
certainty (probability $1$): in almost every Cramér universe, the primes are
infinite.

### 5.2. Collapse of infinitude

The reverse phenomenon requires no independence at all.

**Theorem 5.2 (Collapse under a summable density).** *Let $(s_n)$ be any
measurable events with $\sum_n \mu(s_n) < \infty$. Then*
$$\mu\!\left(\limsup_n s_n\right) = 0;$$
*that is, almost surely only finitely many integers are random primes.*

*Proof.* Immediate from the first Borel–Cantelli lemma (Lemma 2.1). $\square$

To exhibit a concrete counterfactual universe on the collapsing side, we use the
*subcritical density* $1/(n+2)^2$.

**Lemma 5.3 (Subcritical density is summable).**
$$\sum_n \frac{1}{(n+2)^2} < \infty.$$

*Proof.* The $p$-series $\sum_n 1/n^2$ converges (indeed to $\pi^2/6$). Shifting
the index by $2$ preserves convergence, so $\sum_n 1/(n+2)^2 < \infty$. $\square$

**Theorem 5.4 (Subcritical collapse, instantiated).** *If $\mu(s_n) \le
1/(n+2)^2$ for all $n$, then $\mu(\limsup_n s_n) = 0$: almost surely only
finitely many integers are random primes.*

*Proof.* By monotone comparison and Lemma 5.3, $\sum_n \mu(s_n) \le \sum_n
1/(n+2)^2 < \infty$. Apply Theorem 5.2. $\square$

### 5.3. The bridge, stated once

Combining Theorems 5.1 and 5.2 yields the dictionary that organizes the whole
theory.

**Theorem 5.5 (Zero–one dictionary for random primes).** *For independent events
$(s_n)$:*
$$\mu\!\left(\limsup_n s_n\right) =
\begin{cases}
1 & \text{if } \sum_n \mu(s_n) = \infty,\\[2pt]
0 & \text{if } \sum_n \mu(s_n) < \infty.
\end{cases}$$
*Consequently, the random prime set is infinite almost surely if and only if the
density series diverges. Cramér's density $1/\log(n+2)$ satisfies $\sum_n
\mu(s_n) = \infty$ (Theorem 4.3) and hence lands on the "infinite" side; any
density bounded above by $1/(n+2)^2$ lands on the "finite" side (Lemma 5.3).*

The content of Theorem 5.5 is that *the entire qualitative fate of the primes —
infinitely many or finitely many — is a single bit of information, computed by
summing a number-theoretic series.*

---

## 6. The phase transition

Theorem 5.5 exposes a sharp *phase transition* in the space of densities. Consider
a family of models indexed by an exponent $\alpha > 0$, with density $p_n \asymp
1/n^\alpha$:

- For $\alpha \le 1$, the series $\sum_n 1/n^\alpha$ diverges, so
  $\mu(\limsup s_n) = 1$: infinitely many primes almost surely.
- For $\alpha > 1$, the series converges, so $\mu(\limsup s_n) = 0$: finitely
  many primes almost surely.

The transition sits at the critical exponent $\alpha = 1$ — the boundary of the
harmonic series. Cramér's density $1/\log n$ is *slower* than every $1/n^\alpha$
with $\alpha > 0$ near $1$; more precisely it decays slower than $1/n$ and is thus
firmly on the divergent (infinitely-many-primes) side, but only *just* — it lives
in the delicate logarithmic zone squeezed between $1/n$ (diverges) and
$1/n^{1+\varepsilon}$ (converges). This is a quantitative sense in which the
infinitude of the true primes is *robust but not extravagant*: the density is as
small as it can be while still guaranteeing infinitely many primes.

The location of the transition is therefore an arithmetic statement dressed in
probabilistic clothing. Divergence of $\sum 1/\log n$ — a fact about how slowly
$\log$ grows — is *exactly* what makes the primes survive.

---

## 7. What collapses: unique factorization

Not every theorem survives. The most conspicuous casualty is the **Fundamental
Theorem of Arithmetic** — unique factorization into primes. In ordinary
arithmetic, primes are not merely a set of the right density; they are the
*multiplicative building blocks*, and every integer decomposes into them in
exactly one way. The Cramér model retains only the *density* of the primes, not
their multiplicative role. A random prime set $S$ has no reason to generate the
integers multiplicatively, still less uniquely: generic integers will have zero,
one, or many factorizations into elements of $S$, with no canonical form.

This dichotomy is the heart of counterfactual number theory:

- **Counting facts survive.** Statements governed purely by *density* — how many
  primes there are, how they thin out, the typical size of gaps — transfer to the
  random model, because randomness reproduces density faithfully. The infinitude
  of primes (Theorem 5.1) is the archetype.
- **Structural facts collapse.** Statements that depend on the *multiplicative
  architecture* of the primes — unique factorization, the multiplicativity of
  arithmetic functions, the Euler product — have no analogue, because the random
  model discards that architecture.

A complementary, *deterministic* deformation makes the same point from the other
side: if one keeps a multiplicative monoid but changes the generators — for
instance the *Hilbert monoid* of integers $\equiv 1 \pmod 4$, whose "primes" are
the numbers in it with no nontrivial factorization within the monoid — then
infinitude of primes again survives, while unique factorization again fails (the
standard example being $441 = 21 \cdot 21 = 9 \cdot 49$, two genuinely different
factorizations into Hilbert primes). Whether the deformation is random or
deterministic, the verdict is the same: *infinitude is cheap, unique
factorization is precious.*

---

## 8. Discussion and future work

The results above form a small but complete *dictionary entry* translating a
measure-theoretic zero–one law into the summability of an arithmetic density
series. Several directions extend it.

1. **Construct the model, not just its hypotheses.** Build the product Bernoulli
   measure on $\prod_n \{0,1\}$ and instantiate the independence and density
   hypotheses with $\mu(s_n) = 1/\log(n+2)$ exactly, turning the
   hypothesis-level survival theorem into an unconditional existence statement.

2. **An almost-sure Prime Number Theorem.** Prove a strong law for the random
   model: almost surely $|S \cap [2, N]| \big/ (N/\log N) \to 1$ as $N \to
   \infty$. This is the random analogue of the PNT and follows from a strong law
   of large numbers for independent, non-identically distributed indicators
   together with Kolmogorov's convergence criterion.

3. **Gaps and a twin-prime analogue.** Analyze the distribution of gaps between
   consecutive random primes. In the Cramér model the largest gap up to $N$ is
   conjecturally of order $(\log N)^2$, and the count of "twin" random primes
   $n, n+2 \in S$ has an explicit almost-sure density; both are natural targets.

4. **A counterfactual Riemann Hypothesis.** Formulate the random analogue of the
   error term in the PNT and ask whether the counterfactual RH — square-root
   cancellation in $|S \cap [2,N]| - \int_2^N dt/\log t$ — holds almost surely.
   The law of the iterated logarithm suggests the random model exhibits
   fluctuations of order $\sqrt{N \log\log N / \log N}$, matching RH-scale
   cancellation up to the iterated-logarithm factor.

5. **Which other theorems survive?** Systematically classify classical results —
   Dirichlet's theorem on primes in arithmetic progressions, Mertens' theorems,
   Chebyshev-type bounds — by whether they are density-driven (expected to
   survive) or structure-driven (expected to collapse).

---

## 9. Conclusion

We have shown that the infinitude of primes survives the passage to Cramér's
random model with probability one, for a reason as elementary as $\log n \le n$:
the prime-density series $\sum_n 1/\log n$ diverges, and the second Borel–Cantelli
lemma converts that divergence into almost-sure infinitude. Below the critical
density — anything summable, such as $1/n^2$ — the first Borel–Cantelli lemma
sends the primes almost surely extinct. The boundary between the two regimes is a
sharp phase transition sitting exactly at the convergence line of the density
series, with Cramér's logarithmic density perched on its resilient edge.
Unique factorization, by contrast, finds no foothold in the random world. The
lesson of counterfactual number theory is that the infinitude of primes was never
a fact about factorization; it was, all along, a fact about a divergent series.
