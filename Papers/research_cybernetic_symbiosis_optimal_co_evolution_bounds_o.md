# Cybernetic Symbiosis: Sharp Convergence Bounds for Mutual Adaptive Feedback in Human–Machine Interfaces

**Author:** Aristotle
**Date:** 2026-07-24

## Abstract

We develop, from first principles, a complete and sharp convergence theory for
the *co-adaptation* of a biological signal and a synthetic decoder in a
brain–computer interface (BCI). Modeling the human motor-cortex signal and the
decoder output as two scalar sequences that mutually adapt toward one another
with constant gains $a$ (human) and $b$ (decoder), we prove that the
disagreement between the two channels obeys the exact linear recursion
$e_{n+1} = (1 - a - b)\,e_n$, and hence follows the closed geometric envelope
$|e_n| = |1 - a - b|^n\,|h_0 - d_0|$. This single identity yields a complete
classification of the loop's asymptotic behavior in terms of the **total gain**
$s = a + b$: the loop converges to consensus if and only if $0 < s < 2$; it
converges *instantly* (in a single step) at the critical value $s = 1$; and it
diverges when $s$ leaves the interval $[0,2]$. We further exhibit a conserved
quantity $b\,h_n + a\,d_n$, from which we derive that both channels converge to
the gain-weighted average $(b\,h_0 + a\,d_0)/(a+b)$ of their initial states. We
close with an explicit counterexample refuting the naive conjecture that mutual
adaptation always yields agreement: at maximal gains $a = b = 1$ the loop
oscillates with constant amplitude forever. All results are stated with full
proofs or proof sketches and require nothing beyond elementary real analysis.

**Keywords:** co-adaptation, brain–computer interface, mutual feedback,
contraction factor, geometric convergence, consensus, critical damping,
stability window.

---

## 1. Introduction

A brain–computer interface couples a living nervous system to a decoding
algorithm. In practice both ends of the coupling are *plastic*: the user learns
to modulate their neural activity to achieve a desired effect, while the decoder
is retrained or continuously adjusted to better interpret the user's signals.
This creates a two-sided adaptive feedback loop — a *co-adaptation* — whose
stability is not obvious a priori. If both parties chase a moving target that is
itself the other party, does the interaction settle into agreement, or can it
destabilize?

This paper answers the question completely for the canonical scalar model of
mutual linear adaptation. Our contributions are:

1. **An exact error law** (Section 3): the disagreement between human and decoder
   contracts by a fixed factor $q = 1 - a - b$ each round, giving a closed-form
   geometric envelope.
2. **A sharp convergence criterion** (Section 4): the loop reaches agreement if
   and only if $|q| < 1$, i.e. the total gain satisfies $0 < a + b < 2$.
3. **A conservation law and consensus value** (Section 5): the quantity
   $b\,h_n + a\,d_n$ is invariant, and both channels converge to the gain-weighted
   average $(b\,h_0 + a\,d_0)/(a+b)$.
4. **Critical damping** (Section 6): at total gain $a + b = 1$ the loop reaches
   exact agreement in a single step — the fastest achievable rate.
5. **Instability and an explicit counterexample** (Section 7): for $|q| > 1$ the
   loop diverges, and at $a = b = 1$ it oscillates forever, refuting the naive
   "mutual adaptation implies convergence" conjecture.

The mathematics is elementary but the resulting design principle is concrete and
sharp: effective co-adaptation depends only on the *total* adaptation effort, is
optimized at a specific critical value, and is destabilized by overcorrection.

---

## 2. The model

We work over the real numbers throughout.

**Definition 2.1 (Co-adaptation dynamics).**
Fix human gain $a \in \mathbb{R}$, decoder gain $b \in \mathbb{R}$, and an
initial joint state $p_0 = (h_0, d_0) \in \mathbb{R} \times \mathbb{R}$. The
*joint state* after $n$ rounds is the pair
$\mathrm{state}(n) = (h_n, d_n) \in \mathbb{R}\times\mathbb{R}$ defined by
$$\mathrm{state}(0) = (h_0, d_0), \qquad
  \mathrm{state}(n+1) = \bigl((1-a)h_n + a\,d_n,\ (1-b)d_n + b\,h_n\bigr).$$
We write $h_n$ (the *human channel*) and $d_n$ (the *decoder channel*) for the
two coordinates, and define the *disagreement* (or *tracking error*)
$$e_n = h_n - d_n.$$

Interpretation: at each round the human moves a fraction $a$ of the way from its
current signal toward the decoder's output, while the decoder moves a fraction
$b$ of the way toward the human's signal. The gains $a, b$ measure how
aggressively each party adapts. The disagreement $e_n$ measures how far the
interface is from a consensus.

We introduce two derived quantities that will organize the entire analysis:

- the **contraction factor** $q = 1 - a - b$;
- the **total gain** $s = a + b$, so that $q = 1 - s$.

---

## 3. The exact error law

Everything follows from a single computation.

**Theorem 3.1 (Error recursion).**
For all $n$,
$$e_{n+1} = (1 - a - b)\,e_n.$$

*Proof.* By definition,
$$
e_{n+1} = h_{n+1} - d_{n+1}
= \bigl[(1-a)h_n + a\,d_n\bigr] - \bigl[(1-b)d_n + b\,h_n\bigr].
$$
Expanding and collecting terms,
$$
e_{n+1} = (1 - a - b)h_n - (1 - a - b)d_n = (1 - a - b)(h_n - d_n)
= (1 - a - b)e_n. \qquad\square
$$

**Theorem 3.2 (Closed form of the error).**
For all $n$,
$$e_n = (1 - a - b)^n\,e_0.$$

*Proof.* Induction on $n$. The base case $e_0 = q^0 e_0$ is immediate. For the
inductive step, $e_{n+1} = q\,e_n = q\cdot q^n e_0 = q^{n+1}e_0$ by Theorem 3.1
and the inductive hypothesis. $\square$

Since $e_0 = h_0 - d_0$, taking absolute values and using multiplicativity gives
the exact envelope.

**Corollary 3.3 (Geometric envelope).**
For all $n$,
$$|e_n| = |1 - a - b|^n\,|h_0 - d_0|.$$

**Corollary 3.4 (One-step contraction identity).**
For all $n$, $\;|e_{n+1}| = |1 - a - b|\cdot|e_n|.$

The disagreement therefore rides an *exact* geometric trajectory: it is
multiplied by the fixed factor $|q|$ every round, with no approximation. The
long-term behavior of the loop is entirely encoded in the magnitude of the single
number $q = 1 - a - b$, which in turn depends only on the total gain $s = a + b$.
The individual split of adaptation effort between human and decoder is irrelevant
to convergence.

---

## 4. Convergence

**Theorem 4.1 (Convergence to agreement).**
If $|1 - a - b| < 1$, then $e_n \to 0$ as $n \to \infty$; that is, the human and
decoder channels reach agreement.

*Proof.* By Theorem 3.2, $e_n = q^n e_0$ with $|q| < 1$. Since $q^n \to 0$
whenever $|q| < 1$, we have $e_n = q^n e_0 \to 0 \cdot e_0 = 0$. $\square$

The condition $|1 - a - b| < 1$ is equivalent to $0 < a + b < 2$: the total gain
must lie in the open *stability window* $(0, 2)$. This is the exact necessary and
sufficient condition for the loop to converge from an arbitrary initial gap
(necessity follows from Section 7).

---

## 5. Conservation law and consensus

Convergence of the disagreement tells us the two channels *meet*; a conservation
law tells us precisely *where*.

**Theorem 5.1 (Conservation law).**
The gain-weighted combination $b\,h_n + a\,d_n$ is invariant:
$$b\,h_n + a\,d_n = b\,h_0 + a\,d_0 \quad\text{for all } n.$$

*Proof.* Induction on $n$; the base case is trivial. For the step,
$$
b\,h_{n+1} + a\,d_{n+1}
= b\bigl[(1-a)h_n + a d_n\bigr] + a\bigl[(1-b)d_n + b h_n\bigr].
$$
Expanding, the cross terms are $b(1-a)h_n + a b\,h_n = b\,h_n$ and
$b a\,d_n + a(1-b)d_n = a\,d_n$, so the sum equals $b\,h_n + a\,d_n$, which by the
inductive hypothesis equals $b\,h_0 + a\,d_0$. $\square$

Combining the invariant with the definition $e_n = h_n - d_n$ lets us solve for
each channel individually. Writing $I = b\,h_0 + a\,d_0$ for the conserved value,
the linear system $b\,h_n + a\,d_n = I$, $h_n - d_n = e_n$ has (for $a + b \neq 0$)
the solution below.

**Proposition 5.2 (Closed forms of the channels).**
If $a + b \neq 0$, then for all $n$,
$$
h_n = \frac{b\,h_0 + a\,d_0 + a\,e_n}{a + b}, \qquad
d_n = \frac{b\,h_0 + a\,d_0 - b\,e_n}{a + b}.
$$

*Proof.* Both identities follow by clearing denominators and substituting
$e_n = h_n - d_n$ into the conservation law of Theorem 5.1; the resulting
equations are linear identities. $\square$

**Theorem 5.3 (Consensus).**
If $a + b \neq 0$ and $|1 - a - b| < 1$, then both channels converge to the same
limit,
$$
\lim_{n\to\infty} h_n = \lim_{n\to\infty} d_n
= \frac{b\,h_0 + a\,d_0}{a + b}.
$$

*Proof.* By Theorem 4.1, $e_n \to 0$. Passing to the limit in the closed forms of
Proposition 5.2 (using continuity of the arithmetic operations) sends the
$e_n$-terms to zero, leaving $(b\,h_0 + a\,d_0)/(a+b)$ in both cases. $\square$

The consensus point is the *gain-weighted average* of the initial states. The
weights are cross-coupled: the human's contribution is weighted by the decoder's
gain $b$ and vice versa. Consequently the party that adapts *less* aggressively
exerts *more* influence on the final compromise — a quantitative "whoever bends
least wins" principle.

---

## 6. Critical damping: the optimal rate

The convergence rate is governed by $|q| = |1 - a - b|$, which is minimized —
indeed zero — exactly when $a + b = 1$.

**Theorem 6.1 (Critical damping).**
If $a + b = 1$, then $e_{n+1} = 0$ for every $n$; in particular $e_1 = 0$.

*Proof.* When $a + b = 1$ the contraction factor is $q = 1 - a - b = 0$. By
Theorem 3.1, $e_{n+1} = q\,e_n = 0$. $\square$

**Corollary 6.2 (Immediate agreement).**
If $a + b = 1$, then $h_{n+1} = d_{n+1}$ for every $n$: the channels agree
exactly from round one onward, regardless of the initial gap.

At the critical total gain the disagreement is annihilated in a single step. This
is the fastest possible behavior of the loop and is the natural design target for
a co-adaptive interface: not maximal individual aggressiveness, but a *total*
adaptation effort summing to exactly one.

---

## 7. Instability and the failure of naive convergence

Outside the stability window the loop does not merely fail to converge quickly —
it diverges.

**Theorem 7.1 (Contrarian instability).**
If $|1 - a - b| > 1$ and $h_0 \neq d_0$, then $|e_n| \to \infty$ as
$n \to \infty$.

*Proof.* By Corollary 3.3, $|e_n| = |q|^n\,|h_0 - d_0|$ with $|q| > 1$ and
$|h_0 - d_0| > 0$. Since $|q|^n \to \infty$ when $|q| > 1$, the product tends to
infinity. $\square$

Thus any nonzero initial disagreement is amplified without bound once the total
gain leaves $[0,2]$ (either $a + b > 2$, over-aggressive adaptation, or
$a + b < 0$, contrarian adaptation that moves away from the partner). This
establishes the necessity half of the convergence criterion: convergence for all
initial gaps holds **if and only if** $0 < a + b < 2$.

Finally, the boundary case exposes a subtle trap. One might conjecture that any
loop in which both parties genuinely adapt toward each other must converge. This
is false.

**Theorem 7.2 (Perpetual oscillation).**
With maximal gains $a = b = 1$ and initial state $(h_0, d_0) = (1, 0)$, one has
$|e_n| = 1$ for all $n$.

*Proof.* Here $q = 1 - 1 - 1 = -1$ and $e_0 = 1$, so by Theorem 3.2
$e_n = (-1)^n$, whence $|e_n| = 1$. $\square$

**Corollary 7.3 (Refutation of naive convergence).**
The statement "every mutual adaptive feedback loop reaches agreement" is false.
At $a = b = 1$ the sequence $e_n = (-1)^n$ does not converge to $0$.

*Proof.* If $e_n \to 0$ then $|e_n| \to 0$; but $|e_n| = 1 \to 1$ by
Theorem 7.2, and limits are unique, a contradiction. $\square$

At maximal gains each party leaps entirely to the other's previous position, so
the two values simply swap each round and the gap never closes. Enthusiasm is not
progress: a feedback loop can be fully mutual and still oscillate forever.

---

## 8. The stability trichotomy

Collecting Sections 4, 6, and 7 yields a complete classification in the single
parameter $s = a + b$ (equivalently $q = 1 - s$), valid for any initial gap.

| Regime | Total gain $s = a+b$ | Contraction $|q|$ | Behavior |
|---|---|---|---|
| Convergent | $0 < s < 2$ | $<1$ | $e_n \to 0$ geometrically; consensus at $(b h_0 + a d_0)/(a+b)$ |
| Critically damped | $s = 1$ | $0$ | $e_n = 0$ for $n \ge 1$ (instant agreement) |
| Marginal | $s = 0$ or $s = 2$ | $=1$ | $|e_n|$ constant; perpetual oscillation |
| Divergent | $s < 0$ or $s > 2$ | $>1$ | $|e_n| \to \infty$ |

This is a genuine phase diagram: the "phases" are harmony, stalemate, and chaos,
separated by the sharp thresholds $s = 0, 1, 2$.

---

## 9. Algorithms

The theory is directly executable. We summarize the two core routines.

**Algorithm A (Co-adaptation simulator).** Given $a, b, h_0, d_0$ and a horizon
$N$, iterate Definition 2.1 to produce the trajectories $(h_n, d_n)$ and the
disagreement $e_n$. Complexity $O(N)$ time, $O(1)$ additional space per step.

**Algorithm B (Regime classifier and rate predictor).** Given $a, b$, compute
$q = 1 - a - b$ and $|q|$, then classify the loop as convergent / critical /
marginal / divergent per Section 8, and — when convergent and $a + b \neq 0$ —
report the predicted consensus $(b h_0 + a d_0)/(a+b)$ and the number of rounds
$n$ needed for $|e_n| \le \varepsilon$, namely
$n = \lceil \log(\varepsilon/|h_0-d_0|)/\log|q|\rceil$ (with $n=1$ in the critical
case). Complexity $O(1)$.

---

## 10. Applications and discussion

Although framed around brain–computer interfaces, the model applies to any pair
of adaptive agents locked in mutual linear feedback:

- **Adaptive BCIs.** The design prescription is explicit: keep the total gain
  inside $(0,2)$, and tune toward the critical value $1$ for near-instant lock-on.
  Splitting effort between user training and decoder retraining is a free choice;
  only the sum matters for stability.
- **Multi-agent consensus and control.** Two coupled controllers, or two agents
  averaging toward each other, follow the same law; the consensus value formula
  predicts the equilibrium bias introduced by asymmetric gains.
- **Algorithmic markets and negotiation.** Two agents making proportional
  concessions converge to a gain-weighted compromise, or destabilize if either
  overreacts — a cautionary quantitative model of overcorrection.

A key conceptual takeaway is that *symmetry of intent does not guarantee
convergence*. The oscillation counterexample shows a perfectly mutual,
well-intentioned loop that never settles. Stability is a property of the total
gain, not of good faith.

---

## 11. Future directions

The present theory is a complete, sharp account of the scalar two-party loop.
Natural extensions include:

1. **Vector / multichannel interfaces.** Lift the scalar signal to a
   $d$-dimensional space (multi-electrode cortex). The disagreement recursion is
   componentwise identical, so $\|e_n\| = |1 - a - b|^n\|e_0\|$. The richer
   generalization uses matrix gains $A, B$, where the contraction factor becomes
   the spectral radius $\rho(I - A - B)$ and the convergence criterion is
   $\rho < 1$.
2. **Time-varying and stochastic gains.** Replace constants by schedules
   $a_n, b_n$ and prove convergence under $\prod_n |1 - a_n - b_n| \to 0$, or
   almost-sure convergence with observation noise (a stochastic-approximation /
   Robbins–Monro regime).
3. **Nonlinear decoders.** Model the decoder update as a general contraction on a
   complete metric space and relate the exact linear rate to a Banach
   fixed-point/Lipschitz-constant analysis.
4. **Optimal-gain / regret formulation.** Cast critical damping ($a + b = 1$,
   rate $0$) as the solution of $\arg\min_{a,b} |1 - a - b|$ and study an
   energy/regret trade-off penalizing large gains, since realistic interfaces
   cannot use arbitrarily aggressive updates.
5. **Stability window as a phase diagram.** Package the trichotomy into a single
   classification theorem and connect it to control-theoretic stability margins.

---

## 12. Conclusion

From a two-line update rule we obtained a complete convergence theory for
human–machine co-adaptation. The disagreement contracts by the exact factor
$q = 1 - a - b$ each round; the loop converges if and only if the total gain lies
in $(0,2)$; it converges instantly at the critical value $a + b = 1$; both
channels meet at the gain-weighted average of their starting points; and it
diverges — or oscillates forever at the boundary — outside the stable window. The
result is a small but sharp law with an immediate engineering reading: for
reliable, fast symbiosis, control the *total* adaptation effort, and aim for the
critical value one.
