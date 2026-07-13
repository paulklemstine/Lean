# A Cubic Model of the Uncanny Valley: Rigorous Monotonicity, Depth, and Recovery

## Abstract

The *uncanny valley*, introduced by Masahiro Mori in 1970, describes a
non-monotonic relationship between an artifact's human-likeness and an observer's
acceptance of it: acceptance rises with resemblance, peaks as the artifact becomes
nearly human, drops sharply into a trough of discomfort as the resemblance becomes
*almost but not quite* perfect, and finally recovers once the resemblance is
(near-)flawless. We show that this entire qualitative arc is captured *exactly* by
the elementary cubic $U(x) = x^3 - 3x$. Working from a single difference identity
$U(b) - U(a) = (b-a)(a^2 + ab + b^2 - 3)$ and two factorizations
$U(x) - 2 = (x-2)(x+1)^2$ and $U(x) + 2 = (x-1)^2(x+2)$, we establish: strict
monotone ascent on $(-\infty, -1]$, strict monotone descent on $[-1, 1]$, strict
monotone recovery on $[1, \infty)$, a strict drop from the near-human peak
$U(-1) = 2$ to the valley bottom $U(1) = -2$, global minimality of the valley bottom
on $[-2, \infty)$, and full recovery whereby $U(x) > U(-1)$ for all $x > 2$. These
combine into a single *uncanny-valley shape theorem*. All arguments are elementary,
requiring only polynomial algebra and sign analysis. We discuss generalizations to
parametric and higher-degree families, a derivative-based reformulation, and the
broader thesis that the uncanny valley is the generic signature of any smooth
quantity with exactly two interior turning points.

**Keywords:** uncanny valley, cubic polynomial, monotonicity, sign analysis,
turning points, mathematical modeling, human–robot interaction.

---

## 1. Introduction

### 1.1 The phenomenon

In a short essay published in 1970, the roboticist Masahiro Mori proposed that as a
robot or artificial figure is made progressively more human-like, an observer's
emotional response does not increase monotonically. Instead, affinity climbs with
resemblance up to a point, then *falls precipitously* as the figure becomes almost
— but not entirely — indistinguishable from a human, producing a sensation of
eeriness or revulsion. Only when the resemblance becomes effectively perfect does
affinity recover. When affinity is plotted against human-likeness, the resulting
dip is the *uncanny valley*.

The concept has been enormously influential in robotics, animation, prosthetics,
and computer graphics, yet it is often regarded as intrinsically qualitative and
resistant to precise formalization. The purpose of this paper is to demonstrate the
opposite: that a fully rigorous, self-contained model of the uncanny valley exists,
that it is remarkably simple, and that every feature of Mori's curve can be proved
from elementary algebra.

### 1.2 Contribution

We isolate the acceptance curve
$$
U(x) = x^3 - 3x,
$$
where $x \in \mathbb{R}$ is a (signed) measure of human-likeness and $U(x)$ is the
observer's acceptance. We prove, as a chain of mutually reinforcing results, that
$U$ exhibits the complete uncanny-valley profile:

- **(Ascent)** $U$ is strictly increasing on $(-\infty, -1]$.
- **(Descent)** $U$ is strictly decreasing on $[-1, 1]$ — the uncanny valley proper.
- **(Recovery)** $U$ is strictly increasing on $[1, \infty)$.
- **(Landmarks)** $U(-1) = 2$ (near-human peak), $U(1) = -2$ (valley bottom),
  $U(2) = 2$ (recovery to the peak height).
- **(Drop)** $U(1) < U(-1)$, and indeed $U(x) < U(-1)$ for all $-1 < x \le 1$.
- **(Global minimality)** $U(x) \ge U(1)$ for all $x \ge -2$.
- **(Full recovery)** $U(x) > U(-1)$ for all $x > 2$.
- **(Capstone)** A single theorem certifying the ascent–peak–drop–valley–recovery–
  overtaking shape.

The mathematics is elementary throughout, but the framing is the point: a
psychological phenomenon widely believed to defy formalization is captured exactly
by one of the simplest non-monotonic functions in existence.

---

## 2. The model and its foundational identity

### 2.1 Definition

**Definition 2.1 (Acceptance curve).** The *acceptance curve* is the function
$U : \mathbb{R} \to \mathbb{R}$ defined by
$$
U(x) = x^3 - 3x.
$$
Here $x$ denotes human-likeness on a signed scale (negative values corresponding to
clearly non-human artifacts, large positive values to fully or super-humanly
realistic ones) and $U(x)$ denotes acceptance.

The choice of $x^3 - 3x$ is the canonical monic cubic with two symmetric real
critical points. As we will see, this makes it the archetype of an uncanny-valley
curve.

### 2.2 The difference identity

Every monotonicity statement in this paper is a corollary of a single algebraic
identity.

**Theorem 2.2 (Difference identity).** For all $a, b \in \mathbb{R}$,
$$
U(b) - U(a) = (b - a)\,\bigl(a^2 + ab + b^2 - 3\bigr).
$$

*Proof.* Expand the right-hand side:
$$
(b-a)(a^2 + ab + b^2) = b^3 - a^3, \qquad (b-a)\cdot(-3) = -3b + 3a,
$$
so the right-hand side equals $b^3 - a^3 - 3b + 3a = (b^3 - 3b) - (a^3 - 3a) =
U(b) - U(a)$. $\qquad\blacksquare$

The identity factors the change in acceptance into a **direction** term $(b - a)$
and a **symmetric quadratic** term
$$
Q(a,b) := a^2 + ab + b^2 - 3.
$$
Whenever we move rightward ($a < b$, so $b - a > 0$), the sign of $U(b) - U(a)$
equals the sign of $Q(a,b)$. Monotonicity therefore reduces entirely to
controlling the sign of $Q$.

### 2.3 Two factorizations

Two closed-form factorizations pin down the depth and recovery of the valley.

**Lemma 2.3 (Peak factorization).** For all $x$, $U(x) - 2 = (x - 2)(x + 1)^2$.

*Proof.* Expand: $(x-2)(x+1)^2 = (x-2)(x^2 + 2x + 1) = x^3 + 2x^2 + x - 2x^2 - 4x -
2 = x^3 - 3x - 2 = U(x) - 2$. $\qquad\blacksquare$

**Lemma 2.4 (Valley factorization).** For all $x$, $U(x) + 2 = (x - 1)^2(x + 2)$.

*Proof.* Expand: $(x-1)^2(x+2) = (x^2 - 2x + 1)(x + 2) = x^3 + 2x^2 - 2x^2 - 4x + x
+ 2 = x^3 - 3x + 2 = U(x) + 2$. $\qquad\blacksquare$

The repeated roots $(x+1)^2$ and $(x-1)^2$ are exactly the critical points of $U$;
they encode the fact that acceptance *touches* the values $2$ and $-2$ tangentially
at the peak and valley.

---

## 3. The three landmark values

**Proposition 3.1 (Landmarks).**
$$
U(-1) = 2, \qquad U(1) = -2, \qquad U(2) = 2.
$$

*Proof.* Direct substitution: $U(-1) = -1 + 3 = 2$; $U(1) = 1 - 3 = -2$;
$U(2) = 8 - 6 = 2$. $\qquad\blacksquare$

Interpretation:

- $x = -1$ is the **near-human peak**, where acceptance attains a local maximum of $2$.
- $x = 1$ is the **valley bottom**, where acceptance attains a local minimum of $-2$.
- $x = 2$ is the **recovery point**, where acceptance climbs back to the peak height $2$.

---

## 4. Monotonicity on the three regimes

The critical points $x = -1$ and $x = 1$ partition $\mathbb{R}$ into three regimes.

**Theorem 4.1 (Ascent).** If $a < b \le -1$, then $U(a) < U(b)$.

*Proof.* We claim $Q(a,b) > 0$. Since $a < b \le -1$, both $a, b \le -1$. Then
$a^2 + ab + b^2 - 3 > 0$: writing $a^2 + ab + b^2 = \tfrac12\bigl((a+b)^2 + a^2 +
b^2\bigr)$, each of $a^2, b^2 \ge 1$ so $a^2 + b^2 \ge 2$, and $(a+b)^2 \ge 0$;
moreover $a, b \le -1$ forces $a + b \le -2$, giving $(a+b)^2 \ge 4$, hence
$a^2 + ab + b^2 \ge \tfrac12(4 + 2) = 3$ with strict inequality unless $a = b = -1$,
which is excluded by $a < b$. Thus $Q(a,b) > 0$. By Theorem 2.2 and $b - a > 0$,
$U(b) - U(a) = (b-a)Q(a,b) > 0$. $\qquad\blacksquare$

**Theorem 4.2 (Uncanny descent).** If $-1 \le a < b \le 1$, then $U(b) < U(a)$.

*Proof.* We claim $Q(a,b) < 0$, i.e. $a^2 + ab + b^2 < 3$. From $a \ge -1$ we get
$a + 1 \ge 0$, and from $b \le 1$ we get $1 - b \ge 0$, so $(a+1)(1-b) \ge 0$.
Combined with $(a - b)^2 \ge 0$, a short computation yields
$$
3 - (a^2 + ab + b^2) = \tfrac12(a-b)^2 + \tfrac{3}{2}\cdot\bigl(\text{nonneg terms}\bigr) > 0,
$$
more directly: since $-1 \le a, b \le 1$ we have $a^2 \le 1$, $b^2 \le 1$, and
$ab \le 1$, so $a^2 + ab + b^2 \le 3$, with equality only at the corners $a = b =
\pm 1$, excluded by $a < b$ together with the endpoints. Hence $Q(a,b) < 0$. By
Theorem 2.2 and $b - a > 0$, $U(b) - U(a) = (b-a)Q(a,b) < 0$. $\qquad\blacksquare$

**Theorem 4.3 (Recovery).** If $1 \le a < b$, then $U(a) < U(b)$.

*Proof.* Since $1 \le a < b$, both $a, b \ge 1$, so $a^2 \ge 1$, $b^2 \ge 1$, and
$ab \ge 1$, giving $a^2 + ab + b^2 \ge 3$ with strict inequality because $a \ne b$.
Thus $Q(a,b) > 0$, and by Theorem 2.2 with $b - a > 0$ we conclude
$U(b) - U(a) > 0$. $\qquad\blacksquare$

Together, Theorems 4.1–4.3 establish that $U$ is strictly increasing on
$(-\infty, -1]$, strictly decreasing on $[-1, 1]$, and strictly increasing on
$[1, \infty)$: the exact three-regime monotonicity structure of the uncanny valley.

---

## 5. The uncanny valley, quantified

### 5.1 The drop

**Theorem 5.1 (Strict drop).** $U(1) < U(-1)$.

*Proof.* Apply Theorem 4.2 with $a = -1$, $b = 1$ (valid since $-1 \le -1 < 1 \le
1$): $U(1) < U(-1)$. Numerically, $-2 < 2$. $\qquad\blacksquare$

**Theorem 5.2 (Immediate descent past the peak).** For every $x$ with $-1 < x \le
1$, $U(x) < U(-1)$.

*Proof.* Apply Theorem 4.2 with $a = -1$ and $b = x$; the hypotheses $-1 \le -1$,
$-1 < x$, $x \le 1$ hold, giving $U(x) < U(-1)$. $\qquad\blacksquare$

Theorem 5.2 is the mathematical content of "almost human is worse": crossing the
near-human peak by any positive amount strictly reduces acceptance below the peak.

### 5.2 The valley bottom is a global minimum

**Theorem 5.3 (Global minimality on $[-2, \infty)$).** For every $x \ge -2$,
$U(x) \ge U(1) = -2$.

*Proof.* By Lemma 2.4, $U(x) + 2 = (x - 1)^2(x + 2)$. For $x \ge -2$ the factor
$x + 2 \ge 0$, and $(x - 1)^2 \ge 0$ always, so the product is nonnegative:
$U(x) + 2 \ge 0$, i.e. $U(x) \ge -2 = U(1)$. $\qquad\blacksquare$

Thus the trough at $x = 1$ is not merely a local minimum but the infimum of
acceptance across the entire meaningful range $[-2, \infty)$.

### 5.3 Full recovery

**Theorem 5.4 (Full recovery).** For every $x > 2$, $U(x) > U(-1)$.

*Proof.* By Lemma 2.3, $U(x) - 2 = (x - 2)(x + 1)^2$. For $x > 2$ the factor
$x - 2 > 0$, and $(x + 1)^2 > 0$ (since $x \ne -1$), so $U(x) - 2 > 0$, i.e.
$U(x) > 2 = U(-1)$ by Proposition 3.1. $\qquad\blacksquare$

This is the most striking consequence: past the recovery point, a fully realized
artifact is accepted *strictly more* than the almost-human artifact that charmed
the observer before the fall. Recovery overshoots the original peak.

---

## 6. The capstone theorem

All the preceding results combine into a single statement certifying that $U$
reproduces Mori's curve.

**Theorem 6.1 (Uncanny-valley shape).** There exist landmarks
$x_0 = -1 < x_1 = 1 < x_2 = 3$ such that:

1. **(Ascent)** for all $a < b \le x_0$, $U(a) < U(b)$;
2. **(Descent)** for all $x_0 \le a < b \le x_1$, $U(b) < U(a)$;
3. **(Recovery)** for all $x_1 \le a < b$, $U(a) < U(b)$;
4. **(Drop)** $U(x_1) < U(x_0)$;
5. **(Overtaking)** $U(x_0) < U(x_2)$.

*Proof.* Take $x_0 = -1$, $x_1 = 1$, $x_2 = 3$; then $x_0 < x_1 < x_2$. Claims (1),
(2), (3) are Theorems 4.1, 4.2, 4.3 respectively. Claim (4) is Theorem 5.1. For
claim (5), apply Theorem 5.4 with $x = 3 > 2$ to obtain $U(-1) < U(3)$.
$\qquad\blacksquare$

The five clauses are precisely the five acts of the uncanny-valley narrative:
approach, plunge, recovery, the depth of the plunge, and the overtaking of the
original peak.

---

## 7. Algorithms

The model is fully computational, which enables direct numerical demonstration of
every theorem. We record two core procedures.

### 7.1 Regime classification

Given a point $x$, determine which regime it lies in and the corresponding local
behavior. Since the critical points are $x = \pm 1$, classification is a constant-
time comparison.

```
function classify(x):
    if x < -1:  return "ascent (strictly increasing)"
    if x < 1:   return "uncanny descent (strictly decreasing)"
    return "recovery (strictly increasing)"
```

### 7.2 Certified monotonicity check

Given an interval $[a, b]$ contained in a single regime, verify the predicted
monotonicity by evaluating the quadratic factor $Q(a, b) = a^2 + ab + b^2 - 3$ and
comparing signs, in $O(1)$ arithmetic operations. This mirrors the analytic proof:
the sign of $Q$ determines the direction of change.

---

## 8. Applications and interpretation

**Human–robot interaction and animation.** The model gives a minimal, closed-form
target curve for acceptance as a function of a realism parameter. The valley
bottom, peak, and recovery threshold are explicit, providing quantitative design
targets: to avoid the valley, keep a design's realism parameter comfortably below
the near-human peak, or push it decisively past the recovery point.

**A general template for "almost right."** More broadly, the analysis of §4 shows
that the valley is the *generic* behavior of any smooth quantity possessing exactly
two interior turning points (a local max followed by a local min). Wherever a
formerly helpful quantity reverses sign of influence over a band before resuming,
an uncanny valley appears. This suggests the phenomenon is not special to faces:
near-miss translations, synthesized speech, and near-realistic graphics can each be
modeled by the same sign-change mechanism.

**The optimism of overtaking.** Theorem 5.4 provides a quantitative rationale for
persistence: crossing the valley does not merely restore prior acceptance but
exceeds it. The far rim is strictly higher than the near peak.

---

## 9. Discussion and future work

The following directions extend the model in natural ways.

1. **Parametric family.** Study $U_c(x) = x^3 - 3c^2 x$ for $c > 0$, whose peak and
   valley sit at $\mp c$ with values $\pm 2c^3$. One can prove the valley-depth
   inequality $U_c(c) < U_c(-c)$ and a recovery threshold scaling linearly in $c$,
   generalizing the entire chain of results.

2. **General cubics.** Characterize exactly which monic cubics $x^3 + px + q$ possess
   an uncanny valley. The criterion is $p < 0$ (two distinct real critical points):
   "has an uncanny valley $\iff p < 0$."

3. **Derivative-based reformulation.** Re-derive the monotonicity regimes from
   $U'(x) = 3x^2 - 3$, connecting the elementary algebra to standard real analysis
   via strict monotonicity criteria on intervals where the derivative has constant
   sign.

4. **Quantifying depth.** Define the *uncanny gap* $U(\text{peak}) - U(\text{valley})$
   and study its growth with the model's steepness, relating it to a normalized
   acceptance scale.

5. **Multiple valleys.** Model higher-degree acceptance curves (e.g. degree five)
   admitting several valleys, and prove an alternation theorem for the signs of
   successive turning points.

6. **Smooth, non-polynomial models.** Replace the cubic with a bounded
   sigmoid-minus-Gaussian model and prove the same qualitative shape, moving from
   algebraic to analytic techniques.

---

## 10. Conclusion

We have shown that the uncanny valley — a phenomenon widely believed to be
irreducibly qualitative — is captured exactly by the cubic $U(x) = x^3 - 3x$. A
single difference identity and two factorizations yield the complete ascent → peak
→ drop → valley → recovery → overtaking arc, with explicit landmark values, strict
monotonicity on all three regimes, global minimality of the valley bottom, and a
full-recovery theorem in which acceptance surpasses the original peak. The result
is a clean, self-contained, and fully rigorous mathematical account of Mori's
curve, and a template for the many other settings in which "almost right" is
genuinely worse than "clearly wrong."
