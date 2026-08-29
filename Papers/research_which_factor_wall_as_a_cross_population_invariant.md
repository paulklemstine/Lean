# The Which-Factor Wall as a Cross-Population Invariant: Sharp Two-Sided Moduli for Binary Capacity

**Author:** Aristotle
**Date:** 2026-08-29

---

## Abstract

A *binary capacity*, or **wall**, is the empirical Shannon entropy of a
two-valued statistic on a finite population. Because the binary entropy
function $h(p) = p\log\frac1p + (1-p)\log\frac1{1-p}$ is strictly increasing on
$[0,\tfrac12]$, a wall value determines the class imbalance of the underlying
split uniquely, and this makes the wall a candidate *cross-population
invariant*: a quantity that two independent laboratories can compare directly.
Uniqueness, however, is qualitative. This paper determines the exact
quantitative content of a wall reading.

We first refute the natural conjecture that
$|h(p)-h(q)| \ge c(\delta)|p-q|$ on $[\delta,\tfrac12]$ with
$c(\delta) = \log\frac{1-\delta}{\delta}$: the exact counterexample
$\delta = q = \tfrac14$, $p = \tfrac12$ reduces the claim to $4 \le 3$. The
error is structural — $c(\delta)$ is the supremum of $|h'|$ on the interval,
hence a Lipschitz constant, and we prove the corresponding true inequality
$|h(p)-h(q)| \le c(\delta)|p-q|$ on $[\delta,1-\delta]$.

We then prove the correct results. A sharp mean-value bound
$(q-p)\log\frac{1-q}{q} \le h(q)-h(p)$ for $0 \le p \le q \le \tfrac12$ yields a
guarded linear inversion with constant $\log\frac{1/2+\eta}{1/2-\eta}$, the
slope at the guard point; the guard is necessary, since the two-sided quadratic
law $2t^2 \le \log 2 - h(\tfrac12 - t) \le 4t^2$ shows no uniform linear
constant exists at balance. Nevertheless the wall is never uninformative: a
Pinsker-type inequality $2(q-p)^2 \le h(q)-h(p)$ gives unconditional
$\sqrt{\varepsilon}$ stability, $|p-q| \le \sqrt{\varepsilon/2}$, and the
exponent $\tfrac12$ is optimal. In the converse direction, the sharp
Fannes-type bound $|h(p)-h(q)| \le h(|p-q|)$ holds on $[0,\tfrac12]$ and is
attained, giving the complete two-sided modulus
$2|p-q|^2 \le |h(p)-h(q)| \le h(|p-q|)$ with both sides sharp. Removing the
balanced-side convention, we characterise the ambiguity exactly:
$h(p) = h(q)$ on $[0,1]$ iff $q = p$ or $q = 1-p$, with quantitative form
$\min(|p-q|,|p+q-1|) \le \sqrt{\varepsilon/2}$.

Finally, we show that a reported wall is a falsifiable numerical claim: a
reading of $0.4677$ bits is realised by a unique minority fraction in
$[0,\tfrac12]$, and that fraction lies strictly in $\left(\tfrac1{12},
\tfrac19\right)$, i.e. between $8.34\%$ and $11.11\%$. For splits below
$\tfrac19$, agreement of walls to $0.01$ bits pins the split to $\pm\tfrac1{300}$.
The practical recommendation is the reverse of the one suggested by the failure
of linear inversion: the wall should be reported *with its resolution*, which is
$\Theta(\varepsilon)$ away from balance and $\Theta(\sqrt\varepsilon)$ at
balance.

**Keywords:** binary entropy, Pinsker inequality, modulus of continuity,
strong concavity, class imbalance, sufficient statistic, cross-population
invariant.

---

## 1. Introduction

### 1.1 The setting

Diagnostic pipelines frequently reduce a rich dataset to a small battery of
scalar readings. One such reading is the **binary capacity**, or **wall**: the
average information content, in bits, of a single two-valued observation made on
each member of a population. If a fraction $p$ of the population falls in one
class and $1-p$ in the other, the wall is the binary entropy of $p$.

The wall's appeal as a summary is that it does not depend on labels, on
population size, or on what the two classes mean. Two laboratories studying
disjoint populations with entirely different instruments can compare wall
values directly. This is what we mean by calling the wall a **cross-population
invariant**.

The wall's known theoretical justification is a uniqueness statement: on the
balanced side $[0,\tfrac12]$, binary entropy is strictly increasing, so the wall
determines the imbalance. Uniqueness at exact equality, however, is not what
replication requires. Two laboratories never report identical walls. The
operative question is:

> **(Q)** If two independent populations report walls agreeing within
> $\varepsilon$, how close must their class imbalances be?

### 1.2 The conjecture, and what actually happens

The natural attack on (Q) is the mean value theorem. Since
$h'(x) = \log\frac{1-x}{x}$, on the interval $[\delta,\tfrac12]$ the derivative
is bounded by $c(\delta) = \log\frac{1-\delta}{\delta}$, suggesting

$$
|h(p)-h(q)| \;\ge\; c(\delta)\,|p-q|,
\qquad\text{hence}\qquad
|p-q| \;\le\; \frac{|h(p)-h(q)|}{c(\delta)} .
\tag{C}
$$

Conjecture (C) is false (Theorem 3.1). The reason is that $c(\delta)$ is the
*maximum* of $h'$ on $[\delta,\tfrac12]$, attained at the endpoint furthest from
balance; a maximum of the derivative bounds chord slopes from *above*. Indeed
the inequality (C) with its direction reversed is a theorem (Theorem 3.2).

Correcting the constant to the slope at the endpoint nearest balance gives a
valid *guarded* inversion (Theorem 4.2), but with a constant that degenerates as
the guard shrinks. Section 5 shows the degeneration is real: no uniform linear
constant exists (Theorem 5.2), because the entropy deficit at balance vanishes
quadratically (Theorem 5.1).

At this point one might conclude the wall is uninformative near balance and
should be dropped from the report. Section 6 shows the opposite. A Pinsker-type
inequality (Theorem 6.2) delivers unconditional square-root stability (Theorem
6.3), the exponent $\tfrac12$ is optimal (Theorem 6.5), and the resolution of a
wall reading is therefore always finite and computable.

Section 7 supplies the converse modulus — how far walls may move when splits
move — yielding the complete two-sided law. Section 8 removes the
balanced-side convention. Section 9 works out the numerics of the reported
value $0.4677$ bits. Section 10 discusses consequences and open directions.

### 1.3 Units

We work in **nats** throughout: $\log$ denotes the natural logarithm and
$h(\tfrac12) = \log 2$. A reading of $B$ bits corresponds to $B\log 2$ nats.
Where a numerical value is quoted in bits, the conversion is stated explicitly.

---

## 2. Definitions

**Definition 2.1 (Binary entropy).** For $p \in [0,1]$,
$$
h(p) \;=\; p\log\frac1p \;+\; (1-p)\log\frac1{1-p},
$$
with the conventions $h(0) = h(1) = 0$. The function $h$ is continuous on
$[0,1]$, symmetric ($h(p) = h(1-p)$), concave, strictly increasing on
$[0,\tfrac12]$, and differentiable on $(0,1)$ with
$$
h'(x) \;=\; \log(1-x) - \log x \;=\; \log\frac{1-x}{x}.
$$
In particular $h' > 0$ on $(0,\tfrac12)$, $h'(\tfrac12) = 0$, and $h'$ is
strictly decreasing (so $h$ is strictly concave).

**Definition 2.2 (Population statistic and its readings).** Let $\Omega$ be a
finite nonempty set (the *population*) with $N = |\Omega|$, and let
$f : \Omega \to A$ be any map into a set of *readings*. Write
$\operatorname{img} f = \{f(\omega) : \omega \in \Omega\}$ for the set of
attained readings and, for $a \in A$,
$$
n_f(a) \;=\; \#\{\omega \in \Omega : f(\omega) = a\}.
$$
Necessarily $\sum_{a \in \operatorname{img} f} n_f(a) = N$ and $n_f(a) > 0$ for
each attained $a$.

**Definition 2.3 (Empirical entropy; the wall).** The **empirical entropy** of
$f$ is
$$
H(f) \;=\; \sum_{a \in \operatorname{img} f} \frac{n_f(a)}{N}\,
\log\frac{N}{n_f(a)} \qquad \text{(nats)} .
$$
When $f$ attains exactly two readings we call $H(f)$ the **wall** of $f$.

**Lemma 2.4 (Two-valued statistics measure imbalance).** If
$a \ne b$ and $\operatorname{img} f = \{a,b\}$, then
$$
H(f) \;=\; h\!\left(\frac{n_f(a)}{N}\right).
$$

*Proof.* With $p = n_f(a)/N$ we have $n_f(a) + n_f(b) = N$, so
$n_f(b)/N = 1-p$, and both counts are positive. The two-term sum defining
$H(f)$ is then $p\log(1/p) + (1-p)\log(1/(1-p)) = h(p)$. $\square$

Lemma 2.4 is the bridge between the population layer and the analytic layer:
every analytic theorem about $h$ below transfers to a statement about binary
statistics on arbitrary finite populations, and we record the transferred forms
explicitly.

**Definition 2.5 (Class imbalance).** For a two-valued statistic $f$ with
readings $\{a,b\}$, the *class fraction of $a$* is $n_f(a)/N$. The
**imbalance** is the minority fraction $\min(n_f(a), n_f(b))/N \in [0,\tfrac12]$.
Unless stated otherwise, "the split" refers to a number in $[0,\tfrac12]$.

---

## 3. Mean-value machinery, and the refutation

Our basic technique converts one-sided derivative bounds into chord bounds via
monotonicity of an auxiliary function. Since $h$ is differentiable on $(0,1)$
and continuous on $[0,1]$, for constants $c$ we have:

**Lemma 3.0 (Slope comparison).** Let $0 < a \le b < 1$.

1. If $c \le h'(x)$ for all $x \in (a,b)$, then $x \mapsto h(x) - cx$ is
   nondecreasing on $[a,b]$; hence $c\,(b-a) \le h(b) - h(a)$.
2. If $h'(x) \le c$ for all $x \in (a,b)$, then $x \mapsto cx - h(x)$ is
   nondecreasing on $[a,b]$; hence $h(b) - h(a) \le c\,(b-a)$.

*Proof.* Each auxiliary function is continuous on $[a,b]$, differentiable on
$(a,b)$ with derivative of the stated sign; a function with nonnegative
derivative on the interior of an interval and continuous on it is monotone
there. Evaluating the monotone inequality at the endpoints gives the chord
bound. $\square$

**Theorem 3.1 (The conjectured inverse-Lipschitz bound is false).**
It is *not* true that for all $\delta \in (0,\tfrac12]$ and all
$p,q \in [\delta,\tfrac12]$,
$$
\log\frac{1-\delta}{\delta}\,|p-q| \;\le\; |h(p)-h(q)| .
$$

*Proof.* Take $\delta = q = \tfrac14$ and $p = \tfrac12$. Then
$\log\frac{1-\delta}{\delta} = \log 3$ and $|p-q| = \tfrac14$. Also
$h(\tfrac12) = \log 2$, and
$$
h(\tfrac14) = \tfrac14\log 4 + \tfrac34\log\tfrac43 = 2\log 2 - \tfrac34\log 3 ,
$$
so $|h(p) - h(q)| = \tfrac34\log 3 - \log 2$ (positive, since
$3^3 = 27 > 16 = 2^4$). The claimed inequality reads
$\tfrac14\log 3 \le \tfrac34\log 3 - \log 2$, i.e. $2\log 2 \le \log 3$, i.e.
$4 \le 3$ — false. Numerically it asserts $0.27465 \le 0.13082$. $\square$

**Remark.** The failure is not an edge case. It is structural:
$c(\delta) = \log\frac{1-\delta}{\delta} = \sup_{[\delta,\,1/2]} h'$, and a
supremum of a derivative controls chords from above, never from below. The
correct object for an inverse bound is the *infimum* of $h'$, which on
$[p,q] \subseteq [0,\tfrac12]$ equals $h'(q) = \log\frac{1-q}{q}$.

**Theorem 3.2 (The true inequality with constant $c(\delta)$: Lipschitz).**
Let $0 < \delta \le \tfrac12$ and $p,q \in [\delta, 1-\delta]$. Then
$$
|h(p) - h(q)| \;\le\; \Big(\log(1-\delta) - \log\delta\Big)\,|p-q| .
$$

*Proof.* By symmetry assume $p \le q$; set $c = \log(1-\delta)-\log\delta \ge 0$.
For $x \in (p,q) \subseteq (\delta, 1-\delta)$ we have
$\log(1-x) \le \log(1-\delta)$ and $\log\delta \le \log x$, so $h'(x) \le c$;
Lemma 3.0(2) gives $h(q)-h(p) \le c(q-p)$. Likewise
$\log\delta \le \log(1-x)$ and $\log x \le \log(1-\delta)$ give
$h'(x) \ge -c$, and Lemma 3.0(1) with constant $-c$ gives
$-c(q-p) \le h(q)-h(p)$. Combining yields $|h(q)-h(p)| \le c\,|q-p|$. $\square$

So $c(\delta)$ is a genuine and, at the endpoints, sharp Lipschitz constant for
$h$ on $[\delta,1-\delta]$; the conjecture was this theorem read backwards.

---

## 4. The sharp mean-value lower bound and guarded inversion

**Theorem 4.1 (Endpoint slope bound).** For $0 \le p \le q \le \tfrac12$,
$$
(q-p)\Big(\log(1-q) - \log q\Big) \;\le\; h(q) - h(p) .
$$

*Proof.* If $p > 0$: for $x \in (p,q)$ we have $x \le q \le \tfrac12$, so
$\log x \le \log q$ and $\log(1-q) \le \log(1-x)$, whence
$h'(x) \ge \log(1-q)-\log q =: c$. Lemma 3.0(1) gives the claim.

If $p = 0$: the claim is $q(\log(1-q)-\log q) \le h(q)$. Expanding
$h(q) = -q\log q - (1-q)\log(1-q)$, the difference is
$$
h(q) - q\big(\log(1-q)-\log q\big)
= -q\log q - (1-q)\log(1-q) - q\log(1-q) + q\log q
= -\log(1-q),
$$
which is nonnegative because $0 < 1-q \le 1$. $\square$

The constant $\log\frac{1-q}{q} = h'(q)$ is exactly $\inf_{[p,q]} h'$, so
Theorem 4.1 is the best possible linear lower bound on the chord; it is attained
in the limit $p \uparrow q$, and it degenerates to $0$ as $q \uparrow \tfrac12$.

**Theorem 4.2 (Guarded cross-population stability).** Let
$0 < \eta < \tfrac12$ and $p, q \in [0, \tfrac12 - \eta]$. Then
$$
\Big(\log(\tfrac12+\eta) - \log(\tfrac12-\eta)\Big)\,|p - q|
\;\le\; |h(p) - h(q)| .
$$
Consequently, if $|h(p)-h(q)| \le \varepsilon$ then
$$
|p - q| \;\le\; \frac{\varepsilon}{\log\dfrac{\tfrac12+\eta}{\tfrac12-\eta}} .
$$

*Proof.* Assume $p \le q$ (the statement is symmetric). If $q = 0$ then $p = q$
and the claim is trivial. Otherwise $0 < q \le \tfrac12 - \eta$, so
$1 - q \ge \tfrac12 + \eta$ and $q \le \tfrac12 - \eta$, giving
$$
\log(1-q) - \log q \;\ge\; \log(\tfrac12+\eta) - \log(\tfrac12-\eta) =: c_\eta \;\ge\; 0 .
$$
Theorem 4.1 gives $c_\eta (q-p) \le (q-p)(\log(1-q)-\log q) \le h(q)-h(p)$. As
$c_\eta \ge 0$ and $q - p \ge 0$, the right side is nonnegative, so both sides
may be replaced by absolute values. The division form follows because
$c_\eta = \log\frac{1/2+\eta}{1/2-\eta} > 0$. $\square$

**Corollary 4.3 (Population form).** Let $f : \Omega_1 \to A_1$ and
$g : \Omega_2 \to A_2$ be statistics on two finite nonempty populations, with
$\operatorname{img} f = \{a,b\}$, $a \ne b$, and
$\operatorname{img} g = \{c,e\}$, $c \ne e$. Put $p = n_f(a)/|\Omega_1|$ and
$q = n_g(c)/|\Omega_2|$, and suppose $p, q \in [0,\tfrac12-\eta]$ for some
$0 < \eta < \tfrac12$. If $|H(f) - H(g)| \le \varepsilon$, then
$$
|p - q| \;\le\; \frac{\varepsilon}{\log\frac{1/2+\eta}{1/2-\eta}} .
$$

*Proof.* Lemma 2.4 converts $H(f) = h(p)$, $H(g) = h(q)$; apply Theorem 4.2.
$\square$

Corollary 4.3 is the quantitative strengthening of the qualitative inversion
statement (the case $\varepsilon = 0$, which recovers $p = q$).

---

## 5. The guard is necessary: quadratic flatness at balance

**Theorem 5.1 (Quadratic upper bound on the deficit).** For
$0 \le t < \tfrac12$,
$$
\log 2 - h\!\left(\tfrac12 - t\right) \;\le\; 4t^2 .
$$

*Proof.* Write $p = \tfrac12 - t$, so $1-p = \tfrac12 + t$. Then
$$
h(p) = (\tfrac12 - t)\big(\log 2 - \log(1-2t)\big)
     + (\tfrac12 + t)\big(\log 2 - \log(1+2t)\big),
$$
using $p = (1-2t)/2$ and $1-p = (1+2t)/2$. Hence
$$
\log 2 - h(p) = (\tfrac12-t)\log(1-2t) + (\tfrac12+t)\log(1+2t).
$$
Apply $\log u \le u - 1$ to both logarithms: $\log(1-2t) \le -2t$ and
$\log(1+2t) \le 2t$. Since the weights $\tfrac12 - t$ and $\tfrac12 + t$ are
positive,
$$
\log 2 - h(p) \;\le\; (\tfrac12-t)(-2t) + (\tfrac12+t)(2t)
\;=\; -t + 2t^2 + t + 2t^2 \;=\; 4t^2 . \qquad\square
$$

**Theorem 5.2 (No uniform linear inversion constant).** For every real $C$ and
every $\eta > 0$ there exist $p \ne q$ in $[\tfrac12-\eta, \tfrac12]$ with
$$
C\,|h(p) - h(q)| \;<\; |p-q| .
$$

*Proof.* Choose
$t = \min\!\left(\eta,\ \tfrac14,\ \frac{1}{8(|C|+1)}\right) > 0$ and set
$p = \tfrac12 - t$, $q = \tfrac12$. Then $|p-q| = t$ and, by Theorem 5.1,
$|h(p)-h(q)| = \log 2 - h(\tfrac12-t) \le 4t^2$. Hence
$$
C|h(p)-h(q)| \le |C|\,4t^2 = 4|C|\,t\cdot t
\le 4|C|\,t\cdot \frac{1}{8(|C|+1)} \le \frac{t}{2} < t = |p-q| . \qquad\square
$$

Thus the shape of Theorem 4.2 — a constant depending on a guard $\eta$ and
tending to $0$ as $\eta \to 0$ — is not an artefact of the proof. Any inversion
valid up to balance must be nonlinear.

---

## 6. The wall is never uninformative: a square-root law

Theorem 5.1 bounds the entropy deficit from above by $4t^2$. The same quadratic
scale bounds it from *below*, and that is what rescues the wall.

**Lemma 6.1 (Tangent-line comparison / strong concavity at balance).** For
$0 < x \le \tfrac12$,
$$
4\left(\tfrac12 - x\right) \;\le\; \log(1-x) - \log x .
$$

*Proof.* Let $\psi(z) = \log(1-z) - \log z + 4z - 2$ on $(0,\tfrac12]$. Then
$$
\psi'(z) = -\frac{1}{1-z} - \frac1z + 4 = \frac{4z(1-z) - 1}{z(1-z)}
= \frac{-(1-2z)^2}{z(1-z)} \;\le\; 0 ,
$$
so $\psi$ is nonincreasing on $(0,\tfrac12]$. Since
$\psi(\tfrac12) = \log\tfrac12 - \log\tfrac12 + 2 - 2 = 0$, we get
$\psi(x) \ge 0$ for $x \le \tfrac12$, which is the claim. $\square$

**Theorem 6.2 (Pinsker-type inverse bound).** For $0 \le p \le q \le \tfrac12$,
$$
2(q-p)^2 \;\le\; h(q) - h(p) .
$$

*Proof.* Consider $\Phi(x) = h(x) + 2\left(\tfrac12 - x\right)^2$ on
$[0,\tfrac12]$. On the interior,
$$
\Phi'(x) = \log(1-x) - \log x - 4\left(\tfrac12 - x\right) \;\ge\; 0
$$
by Lemma 6.1, and $\Phi$ is continuous on $[0,\tfrac12]$, so $\Phi$ is
nondecreasing. Hence $\Phi(p) \le \Phi(q)$, i.e.
$$
h(q) - h(p) \;\ge\; 2\left(\tfrac12-p\right)^2 - 2\left(\tfrac12-q\right)^2
= 2(q-p)\big(1 - p - q\big) \;\ge\; 2(q-p)^2 ,
$$
the last step because $1 - p - q \ge 1 - 2q \ge 0$ and, more sharply,
$1-p-q \ge q-p$ is equivalent to $2q \le 1$. $\square$

**Theorem 6.3 (Unconditional cross-population stability).** If
$p, q \in [0,\tfrac12]$ and $|h(p) - h(q)| \le \varepsilon$, then
$$
|p - q| \;\le\; \sqrt{\varepsilon/2} .
$$

*Proof.* By Theorem 6.2 applied to the smaller and larger of $p,q$,
$2(p-q)^2 \le |h(p)-h(q)| \le \varepsilon$, so $(p-q)^2 \le \varepsilon/2$ and
$|p-q| \le \sqrt{\varepsilon/2}$. $\square$

**Corollary 6.4 (Population form).** With notation as in Corollary 4.3 and
$p, q \in [0,\tfrac12]$, if $|H(f) - H(g)| \le \varepsilon$ then
$|p - q| \le \sqrt{\varepsilon/2}$ — with no guard and no hypothesis beyond
being on the balanced side.

**Theorem 6.5 (Two-sided quadratic law at balance).** For
$0 \le t < \tfrac12$,
$$
2t^2 \;\le\; \log 2 - h\!\left(\tfrac12 - t\right) \;\le\; 4t^2 .
$$

*Proof.* The upper bound is Theorem 5.1; the lower bound is Theorem 6.2 with
$p = \tfrac12 - t$, $q = \tfrac12$, using $h(\tfrac12) = \log 2$. $\square$

**Theorem 6.6 (Optimality of the exponent $\tfrac12$).** For every
$0 < \varepsilon \le \tfrac14$ there exist $p, q \in [0,\tfrac12]$ with
$$
|h(p) - h(q)| \le \varepsilon \qquad\text{and}\qquad
|p - q| \;\ge\; \frac{\sqrt\varepsilon}{2} .
$$
Consequently no bound of the form $|p-q| \le C\varepsilon^{\alpha}$ with
$\alpha > \tfrac12$ can hold for all small $\varepsilon$.

*Proof.* Set $t = \sqrt\varepsilon/2$, $p = \tfrac12 - t$, $q = \tfrac12$. Since
$\varepsilon \le \tfrac14$ we have $\sqrt\varepsilon \le \tfrac12$, so
$t \le \tfrac14$ and $p \in [0,\tfrac12]$. Theorem 5.1 gives
$|h(p)-h(q)| = \log 2 - h(\tfrac12-t) \le 4t^2 = \varepsilon$, while
$|p-q| = t = \sqrt\varepsilon/2$. If $|p-q| \le C\varepsilon^\alpha$ held with
$\alpha > \tfrac12$, then $\sqrt{\varepsilon}/2 \le C\varepsilon^\alpha$ for all
small $\varepsilon$, i.e. $\varepsilon^{1/2-\alpha} \le 2C$, contradicting
$\varepsilon^{1/2-\alpha} \to \infty$. $\square$

Theorem 6.3 and Theorem 6.6 bracket the truth within a factor of $\sqrt2$:
the guaranteed resolution is $\sqrt{\varepsilon/2} \approx 0.7071\sqrt\varepsilon$,
and the worst case is at least $0.5\sqrt{\varepsilon}$.

**Interpretation.** The recommendation "the wall is insensitive to imbalance
near $\tfrac12$, so drop it from the report" is refuted. The wall's resolution
is
$$
\Theta(\varepsilon) \ \text{away from balance}, \qquad
\Theta(\sqrt{\varepsilon}) \ \text{at balance},
$$
and is finite and explicit in both regimes. The correct action is to publish the
wall together with the resolution its error bar implies.

---

## 7. The converse modulus, and the complete two-sided law

Sections 4–6 bound the split by the wall gap. Replication protocols also need
the opposite direction: if two splits differ by at most $\delta$, how far apart
can their walls be?

**Lemma 7.1 (Subadditivity of binary entropy).** For $q, d \ge 0$ with
$q + d \le 1$,
$$
h(q + d) \;\le\; h(q) + h(d) .
$$

*Proof.* We may assume $q, d > 0$. Fix $d$ and consider
$D(x) = h(x+d) - h(x)$ on $[0, q]$, which is continuous there and
differentiable on the interior with
$$
D'(x) = h'(x+d) - h'(x) = \log\frac{1-x-d}{x+d} - \log\frac{1-x}{x} \;\le\; 0
$$
since $h'$ is strictly decreasing and $x + d > x$. Hence $D$ is nonincreasing,
so $D(q) \le D(0)$, i.e. $h(q+d) - h(q) \le h(d) - h(0) = h(d)$. $\square$

**Theorem 7.2 (Sharp Fannes-type continuity bound).** For
$p, q \in [0,\tfrac12]$,
$$
|h(p) - h(q)| \;\le\; h\big(|p - q|\big) .
$$

*Proof.* Assume $p \le q$ and set $d = q - p \in [0,\tfrac12]$. Then
$h(q) = h(p + d) \le h(p) + h(d)$ by Lemma 7.1, so
$h(q) - h(p) \le h(d)$. Since $h$ is increasing on $[0,\tfrac12]$ and $p \le q$,
the left side is nonnegative, and $|h(p)-h(q)| = h(q)-h(p) \le h(|p-q|)$.
$\square$

**Proposition 7.3 (The modulus is attained).** For $p \in [0,\tfrac12]$,
$$
|h(p) - h(0)| = h(|p - 0|).
$$
Hence no function of $|p-q|$ smaller than $h$ can serve as a modulus of
continuity for the wall on $[0,\tfrac12]$.

*Proof.* $h(0) = 0$ and $h(p) \ge 0$, so both sides equal $h(p)$. $\square$

**Theorem 7.4 (Complete two-sided wall law).** For $p, q \in [0,\tfrac12]$,
$$
2\,|p - q|^2 \;\le\; \big|h(p) - h(q)\big| \;\le\; h\big(|p - q|\big),
$$
and both inequalities are sharp — the left by Theorem 6.6, the right by
Proposition 7.3.

Equivalently, the wall map $p \mapsto h(p)$ is a homeomorphism of
$[0,\tfrac12]$ onto $[0,\log 2]$ which is bi-Hölder: its inverse is
$\tfrac12$-Hölder (exponent $2$ on the forward side), and its own modulus is
$t \mapsto h(t) \sim t\log(1/t)$. The split and the wall determine each other
quantitatively in both directions.

**Corollary 7.5 (Replication robustness).** With notation as in Corollary 4.3
and $p, q \in [0,\tfrac12]$, if $|p - q| \le \delta \le \tfrac12$ then
$$
|H(f) - H(g)| \;\le\; h(\delta) .
$$

*Proof.* Theorem 7.2 gives $|H(f)-H(g)| = |h(p)-h(q)| \le h(|p-q|)$, and $h$ is
nondecreasing on $[0,\tfrac12]$ with $|p-q| \le \delta \le \tfrac12$. $\square$

---

## 8. Removing the balanced-side convention

All inversion statements so far assume the reported fractions lie in
$[0,\tfrac12]$. That hypothesis carries real content — it is the tie-break that
says which class is the majority. We make its content exact.

**Theorem 8.1 (Exactly what a wall determines).** For $p, q \in [0,1]$,
$$
h(p) = h(q) \iff \big(q = p \ \text{ or } \ q = 1 - p\big).
$$

*Proof.* ($\Leftarrow$) Immediate from $h(p) = h(1-p)$.

($\Rightarrow$) Folding to the balanced side, put $\bar p = \min(p, 1-p)$ and
$\bar q = \min(q,1-q)$; both lie in $[0,\tfrac12]$, and $h(\bar p) = h(p)$,
$h(\bar q) = h(q)$ by symmetry. Since $h$ is strictly increasing on
$[0,\tfrac12]$, it is injective there, so $h(p) = h(q)$ forces
$\bar p = \bar q$. Unfolding the four cases according to whether
$p \le 1-p$ and $q \le 1-q$ yields $q = p$ or $q = 1-p$ in each case. $\square$

**Theorem 8.2 (Unconditional quantitative inversion, no balanced-side
hypothesis).** For $p, q \in [0,1]$ with $|h(p) - h(q)| \le \varepsilon$,
$$
\min\big(|p-q|,\ |p+q-1|\big) \;\le\; \sqrt{\varepsilon/2} .
$$

*Proof.* With $\bar p, \bar q$ as above, Theorem 6.3 gives
$|\bar p - \bar q| \le \sqrt{\varepsilon/2}$. In the four folding cases,
$\bar p - \bar q$ equals $p - q$, $p - (1-q) = p+q-1$, $(1-p) - q = -(p+q-1)$,
or $(1-p)-(1-q) = -(p-q)$; in each case its absolute value equals $|p-q|$ or
$|p+q-1|$, so the minimum of the two is bounded by $\sqrt{\varepsilon/2}$.
$\square$

**Corollary 8.3 (Wall inversion up to label swap).** With notation as in
Corollary 4.3 but with $p, q \in [0,1]$ arbitrary, $H(f) = H(g)$ implies
$q = p$ or $q = 1-p$.

So the balanced-side hypothesis in the qualitative inversion statement is
precisely a convention for resolving one bit — which class is the majority —
and nothing beyond that is lost.

---

## 9. A reported wall as a falsifiable numerical claim

We now apply the theory to a concrete reading: a wall of $0.4677$ bits, i.e.
$0.4677\log 2 \approx 0.324184$ nats.

**Lemma 9.1 (Two closed-form entropy values).**
$$
h(\tfrac1{9}) = 2\log 3 - \tfrac83\log 2 \approx 0.348832 \ \text{nats},
\qquad
h(\tfrac1{12}) = 2\log 2 + \log 3 - \tfrac{11}{12}\log 11 \approx 0.286836 \ \text{nats}.
$$

*Proof.* $h(p) = p\log(1/p) + (1-p)\log(1/(1-p))$. For $p = \tfrac19$:
$\log 9 = 2\log 3$ and $\log\tfrac98 = 2\log 3 - 3\log 2$, so
$h = \tfrac19(2\log3) + \tfrac89(2\log3 - 3\log2) = 2\log 3 - \tfrac83\log 2$.
For $p = \tfrac1{12}$: $\log 12 = 2\log 2 + \log 3$ and
$\log\tfrac{12}{11} = 2\log2+\log3-\log 11$, so
$h = \tfrac1{12}\log 12 + \tfrac{11}{12}(\log 12 - \log 11)
= 2\log2+\log3-\tfrac{11}{12}\log 11$. $\square$

**Theorem 9.2 (The $0.4677$-bit bracket).** There exists a unique
$p^\star \in [0,\tfrac12]$ with $h(p^\star) = 0.4677\log 2$, and
$$
\tfrac1{12} \;<\; p^\star \;<\; \tfrac19,
$$
i.e. the minority fraction lies strictly between $8.34\%$ and $11.11\%$.

*Proof.* By Lemma 9.1 and $\log 2 \approx 0.693147$, $\log 3 \approx 1.098612$,
$\log 11 \approx 2.397895$,
$$
h(\tfrac1{12}) \approx 0.286836 \;<\; 0.324184 \;<\; 0.348832 \approx h(\tfrac19),
$$
with the strict inequalities certified by rational bounds on $\log 2$, $\log 3$
and $\log 11$. Since $h$ is continuous, the intermediate value theorem produces
$p^\star \in \left(\tfrac1{12},\tfrac19\right)$ with $h(p^\star)=0.4677\log 2$.
Since $h$ is strictly increasing on $[0,\tfrac12]$, it is injective there, so
$p^\star$ is the only solution in $[0,\tfrac12]$. $\square$

Numerically $p^\star \approx 0.09960$, matching an independently reported split
of $9.96\%$. A reported split of $5\%$ or $15\%$ is *inconsistent* with a wall
of $0.4677$ bits: the wall is a falsifiable claim, not a mood indicator.

**Theorem 9.3 (Replication tolerance at this wall).** Let
$p, q \in [0, \tfrac19]$ satisfy $|h(p)-h(q)| \le 0.01\log 2$ (walls agreeing to
$0.01$ bits). Then
$$
|p - q| \;\le\; \frac{1}{300} \approx 0.33\ \text{percentage points}.
$$

*Proof.* Apply Theorem 4.2 with guard $\eta = \tfrac7{18}$, so that
$\tfrac12 - \eta = \tfrac19$ and $[0,\tfrac19] = [0,\tfrac12-\eta]$. The
constant is
$$
\log\left(\tfrac12+\tfrac7{18}\right) - \log\left(\tfrac12-\tfrac7{18}\right)
= \log\tfrac89 - \log\tfrac19 = \log 8 = 3\log 2 .
$$
Hence $3\log 2\,|p-q| \le |h(p)-h(q)| \le 0.01\log 2$, and dividing by
$3\log 2 > 0$ gives $|p-q| \le 0.01/3 = 1/300$. $\square$

Contrast this with the unconditional square-root bound, which at
$\varepsilon = 0.01\log 2 \approx 0.006931$ nats gives only
$|p-q| \le \sqrt{\varepsilon/2} \approx 0.0589$. The guard is worth a factor of
about $18$ in resolution here: knowing that the split is below $\tfrac19$
converts a $5.9$-point bound into a $0.33$-point bound.

---

## 10. Algorithms

Three computational tasks arise naturally.

### 10.1 Wall inversion by bisection

Given a wall $W \in [0, \log 2]$, compute the unique $p^\star \in [0,\tfrac12]$
with $h(p^\star) = W$. Since $h$ is continuous and strictly increasing on
$[0,\tfrac12]$, bisection converges: starting from $[0,\tfrac12]$, each step
halves the bracket, so $\lceil \log_2(1/\texttt{tol}) \rceil + 1$ iterations
suffice for absolute accuracy $\texttt{tol}$; each iteration costs $O(1)$
evaluations of $h$. Newton's method converges faster away from balance but its
derivative $h'$ vanishes at $\tfrac12$, so bisection is the robust default.

### 10.2 Certified interval for a reported wall

Given a wall $W$ and a measurement error bar $\varepsilon$, produce a rigorous
interval containing the true split. Invert $W-\varepsilon$ and $W+\varepsilon$
(clamped to $[0,\log 2]$) by 10.1; the resulting bracket
$[p^-, p^+]$ is exactly the set of splits consistent with the reading, and its
width is governed by the theory: at most
$2\varepsilon/\log\frac{1/2+\eta}{1/2-\eta}$ when the split is guarded by
$\eta$, and at most $2\sqrt{\varepsilon/2}$ unconditionally.

### 10.3 Resolution report

Given a guard $\eta$ (or none) and an error bar $\varepsilon$, output both the
guarded linear bound and the unconditional square-root bound, and return the
smaller. This is the "wall plus resolution" report that the theory recommends
in place of a bare wall value.

---

## 11. Discussion

**What was settled.**

1. *The conjectured inverse-Lipschitz bound with constant
   $\log\frac{1-\delta}{\delta}$ is false*, refuted by an exact rational
   counterexample; the constant is a Lipschitz constant, and the true inequality
   runs the other way.
2. *The correct linear inversion constant is the slope at the endpoint nearest
   balance*, $\log\frac{1/2+\eta}{1/2-\eta}$, and it degenerates quadratically;
   no uniform linear constant exists.
3. *The wall is nevertheless never uninformative*: unconditional
   $\sqrt{\varepsilon}$ stability holds, with optimal exponent. The proposal to
   drop the wall from the battery report is refuted.
4. *The wall is a two-sidedly controlled coordinate*:
   $2|p-q|^2 \le |\Delta h| \le h(|p-q|)$, both sides sharp.
5. *The balanced-side hypothesis is exactly a label-swap convention*, and the
   quantitative version drops it: $\min(|p-q|, |p+q-1|) \le \sqrt{\varepsilon/2}$.
6. *A reported wall is a falsifiable numerical claim*: $0.4677$ bits brackets
   the split in $\left(\tfrac1{12},\tfrac19\right)$, and a replication agreeing
   to $0.01$ bits pins it to $\pm\tfrac1{300}$.

**Methodological point.** The failed conjecture and its correct replacement
differ by a single word — supremum versus infimum — but the difference
propagates all the way to the practical recommendation. Reading a Lipschitz
bound as an inverse bound suggests the wall is unusable near balance; noticing
that the same quadratic law that kills linear inversion *supplies* square-root
inversion reverses the conclusion. Sharpness statements are what distinguish a
genuine obstruction from a lossy estimate, and here both sharpness statements
(Theorem 6.6 and Proposition 7.3) were needed.

**Scope and limitations.** All results are for two-valued statistics. The
$\Theta(\sqrt\varepsilon)$ regime is a real limitation: near balance, wall
values are simply not a high-resolution probe, and reporting a wall without its
resolution invites overinterpretation. Finally, the numerical bracket in
Section 9 is a statement about the *reported* wall value; sampling error in
estimating $H$ from a finite population is a separate (and standard) matter that
composes with the deterministic error bars given here.

---

## 12. Future directions

**Exact inverse-function expansion of the wall.** The wall map
$p \mapsto h(p)$ is a real-analytic diffeomorphism of $(0,\tfrac12)$ whose
inverse admits a computable Puiseux expansion at the balanced endpoint,
$$
p \;=\; \tfrac12 - \sqrt{\frac{\log 2 - W}{2}}\,\big(1 + O(\log 2 - W)\big),
$$
so a reported wall can be inverted with certified error bars rather than merely
bracketed. The two-sided quadratic law $2t^2 \le \log 2 - h(\tfrac12-t) \le 4t^2$
is exactly the remainder control needed to make this rigorous.

**Multi-class walls and the simplex modulus.** The Pinsker-type bound should
survive on the $k$-class simplex with Shannon entropy in place of $h$ and total
variation in place of $|p-q|$, turning the two-valued invariant into a genuine
multi-class one; the modulus $h(|p-q|)$ should be replaced by a Fannes–Audenaert
type bound $|\Delta H| \le \tau\log(k-1) + h(\tau)$ with $\tau$ the total
variation.

**Composite batteries.** If a battery reports several walls from several binary
statistics on the same population, the joint inversion problem — what region of
split-space is consistent with all readings and their error bars — is a
convex-geometry question with the single-wall brackets as its facets.

**Statistical layer.** Combining the deterministic moduli above with
concentration bounds for the plug-in entropy estimator would give end-to-end
confidence intervals for the split from a finite sample, with the
$\Theta(\sqrt\varepsilon)$ regime at balance interacting with the known
$O(1/N)$ bias of plug-in entropy.
