# The Median as a Metric Projection: Firm Nonexpansiveness, a Characterisation, and Iterated Median Filters

**Author:** Aristotle
**Date:** 2026-08-21

---

## Abstract

The median of three numbers is the canonical robust summary of a small ensemble of
measurements, and its robustness is classically expressed by a *qualitative* bracketing
statement: a single corrupted measurement cannot push the median outside the interval spanned
by the two clean ones. We replace this by a complete quantitative theory, obtained by
identifying the object that the median actually is. Holding two "clean" seeds $a, b$ fixed and
letting the third seed $x$ vary, the median $\operatorname{med}(x,a,b)$ coincides with the
metric projection $P_{[\alpha,\beta]}(x)$ of $x$ onto the bracket
$[\alpha,\beta] = [\min(a,b), \max(a,b)]$. Consequently the sharp robustness constant is not
$1$ (nonexpansiveness) but the *firm* inequality
$$(Tx - Ty)^2 + \bigl((x - Tx) - (y - Ty)\bigr)^2 \le (x-y)^2,$$
a Pythagorean budget shared by the displacement of the estimate and the displacement of the
residual — the part of the corruption the median absorbs. We prove this, together with the
variational inequality, the Pythagorean inequality, and the uniqueness of the nearest point,
so that the median is exhibited as the proximal map of the bracket's indicator.

We then close the characterisation problem. On the real line, firm nonexpansiveness is
*exactly* the conjunction of monotonicity and $1$-Lipschitzness, equivalently the
nonexpansiveness of the reflection $2T - I$. It follows that a self-map of the line is the
median-as-projection if and only if it is firmly nonexpansive, fixes the two endpoints of the
bracket, and has range in the bracket; and firmness cannot be weakened to nonexpansiveness, as
the explicit map $x \mapsto \min(|x|,1)$ shows. We locate exactly what is one-dimensional:
closure of firmness under composition holds on the line and fails in $\mathbb{R}^2$ (for the
projections onto the horizontal axis and the diagonal), whereas firmness itself lifts to
$\mathbb{R}^n$, where the coordinatewise median is the Euclidean projection onto a box and is
firmly nonexpansive. Perturbing all seeds simultaneously, the median is $\ell^\infty$-$1$-Lipschitz,
and so is every rung of the associated quota ladder of an arbitrary finite ensemble, showing
that Lipschitz robustness does not separate the order statistics — only breakdown does.
Finally, relaxed median updates contract the residual by exactly $(1-\lambda)$ per step, and
*unrelaxed* iteration of any firmly nonexpansive self-map of the line possessing a fixed point
converges — an order-theoretic strengthening of Krasnoselskii–Mann that yields convergent
alternating median filters over two ensembles, with no spurious compromise limits.

**Keywords:** median, metric projection, firm nonexpansiveness, variational inequality,
proximal operator, Krasnoselskii–Mann iteration, alternating projections, order statistics,
robust estimation, breakdown point.

---

## 1. Introduction

### 1.1 The setting

An experimental pipeline produces an *ensemble* of measurements of a single scalar quantity.
Our motivating instance is the *knee* of a performance curve: the value of a control parameter
at which returns begin to diminish. Because the estimate of the knee is noisy, the experiment
is repeated with several random seeds, producing an ensemble $K = (K_i)_{i \in \iota}$ of
candidate knees, and one number must be reported.

Reporting the mean is unacceptable: a single divergent run destroys it. The standard remedy is
an *order statistic* — most commonly the median — and the standard justification is a
breakdown argument: with three seeds, one arbitrary corruption cannot move the median outside
the interval spanned by the two uncorrupted seeds,
$$\min(a,b) \le \operatorname{med}(x,a,b) \le \max(a,b) \qquad \text{for all } x. \tag{1.1}$$

Statement (1.1) is qualitative. It bounds the damage from an *arbitrarily large* corruption
but says nothing about the response to a *small* one. The practically urgent question is the
modulus of continuity: if a seed drifts by $\delta$, how far does the reported answer drift?

### 1.2 The observation

The answer is governed by an identification that, once made, is obvious and yet changes the
entire analysis. Write
$$\operatorname{med}(x, a, b) = \max\bigl(\min(x,a),\ \min(\max(x,a),\,b)\bigr)$$
for the middle of three reals. Fix $a$ and $b$ and vary $x$. Then $\operatorname{med}(\cdot,a,b)$
is the *clamp* of $x$ into the interval $[\min(a,b),\max(a,b)]$: it returns $x$ if $x$ lies
inside, and the nearer endpoint otherwise. On the line, the clamp is precisely the metric
projection onto the interval.

Thus the median, apparently a combinatorial selection rule, is an instance of the single most
studied operator class in convex analysis. The consequences are immediate and sharp: the
variational inequality, the Pythagorean inequality, uniqueness of the nearest point, firm
nonexpansiveness, the resolvent/reflection calculus, and the whole convergence theory of
projection algorithms all transfer verbatim.

### 1.3 Contributions

1. **Identification (§3).** The three-seed median is the metric projection onto the bracket
   spanned by the two remaining seeds.
2. **Firm nonexpansiveness (§4).** The median satisfies the Pythagorean robustness budget;
   nonexpansiveness is the corollary obtained by discarding the residual term. The median is the
   unique nearest point of the bracket, hence the proximal map of the bracket's indicator.
3. **Characterisation (§5).** On $\mathbb{R}$, firm nonexpansiveness $=$ monotone $+$
   $1$-Lipschitz $=$ nonexpansiveness of the reflection. Hence a self-map of the line is the
   median-as-projection iff it is firmly nonexpansive, fixes the endpoints and has range in the
   bracket. Firmness cannot be weakened to nonexpansiveness. Fixed-point sets of firmly
   nonexpansive maps of the line are order-convex.
4. **What is one-dimensional (§6).** Closure of firmness under composition is a theorem about
   the line: it fails in $\mathbb{R}^2$. Firmness itself is not one-dimensional: the
   coordinatewise median is the Euclidean projection onto a box and is firmly nonexpansive in
   $\mathbb{R}^n$.
5. **Simultaneous perturbation (§7).** The median is $\ell^\infty$-nonexpansive in all three
   arguments, and every rung of the quota ladder of a finite ensemble is $\ell^\infty$-$1$-Lipschitz.
   Lipschitz robustness and breakdown robustness are independent axes.
6. **Iteration (§8).** Relaxed median updates decay the residual by exactly $(1-\lambda)^n$.
   Unrelaxed orbits of firmly nonexpansive maps of the line with a fixed point converge, giving
   convergent alternating median filters that always find a genuine consensus.

---

## 2. Notation and standing definitions

Throughout, $T$ denotes a self-map of $\mathbb{R}$ (or of $\mathbb{R}^n$ where indicated), $I$
the identity, and $I - T$ the *residual* map.

**Definition 2.1 (Median of three).** For $x,a,b\in\mathbb{R}$,
$$\operatorname{med}(x,a,b) := \max\bigl(\min(x,a),\ \min(\max(x,a),\,b)\bigr),$$
the middle value of the multiset $\{x,a,b\}$.

**Definition 2.2 (Clamp / projection onto an interval).** For $a \le b$ and $x\in\mathbb{R}$,
$$P_{[a,b]}(x) := \max\bigl(a, \min(x,b)\bigr).$$

**Definition 2.3 (Firm nonexpansiveness).** A map $T : \mathbb{R}\to\mathbb{R}$ is *firmly
nonexpansive* if for all $x,y$,
$$(Tx - Ty)^2 + \bigl((x - Tx) - (y - Ty)\bigr)^2 \;\le\; (x-y)^2. \tag{2.1}$$

**Definition 2.4 (Nonexpansiveness).** $T$ is *nonexpansive* if $|Tx - Ty| \le |x-y|$ for all
$x,y$.

**Definition 2.5 (Monotone and $1$-Lipschitz, increment form).** $T$ is *monotone
$1$-Lipschitz* if for all $x \le y$,
$$Tx \le Ty \quad\text{and}\quad Ty - Tx \le y - x.$$

**Definition 2.6 (Firm nonexpansiveness in $\mathbb{R}^n$).** With $\lVert v\rVert^2 =
\sum_i v_i^2$, a map $T : \mathbb{R}^n \to \mathbb{R}^n$ is firmly nonexpansive if
$$\lVert Tx - Ty\rVert^2 + \lVert (x - Tx) - (y - Ty)\rVert^2 \le \lVert x - y\rVert^2 \quad \text{for all } x,y.$$

**Definition 2.7 (Box projection / coordinatewise median).** For $a, b, x \in \mathbb{R}^n$
with $a_i \le b_i$ for all $i$, $\bigl(P_{[a,b]}x\bigr)_i := P_{[a_i,b_i]}(x_i)$.

**Definition 2.8 (Quota ladder).** For a finite ensemble $K : \iota \to \mathbb{N}$ and a quota
$m \le |\iota|$, the *quota budget* $Q(K,m)$ is the largest value $b$ such that at least $m$
indices satisfy $K_i \ge b$; equivalently the $m$-th largest entry of the ensemble. The family
$\{Q(K,m)\}_{m}$ is the *quota ladder*; $m = |\iota|$ is the conservative low rung, and the
middle rung is the median.

---

## 3. The median is a metric projection

**Lemma 3.1 (Clamp $=$ median for ordered endpoints).** For $a \le b$ and all $x$,
$$P_{[a,b]}(x) = \operatorname{med}(x,a,b).$$

*Proof sketch.* Both sides are piecewise linear in $x$ with breakpoints at $a$ and $b$. Case
split on the position of $x$ relative to $a$ and $b$: for $x \le a$ both sides equal $a$; for
$a \le x \le b$ both equal $x$; for $x \ge b$ both equal $b$. Each case reduces to a linear
comparison. $\square$

**Theorem 3.2 (The median is a projection).** For all $a,b,x \in \mathbb{R}$,
$$\operatorname{med}(x,a,b) = P_{[\min(a,b),\,\max(a,b)]}(x).$$

*Proof sketch.* By Lemma 3.1 applied to the ordered pair $\min(a,b) \le \max(a,b)$, the right
side is $\operatorname{med}\bigl(x,\min(a,b),\max(a,b)\bigr)$; the median of three is symmetric
in its arguments, so this is $\operatorname{med}(x,a,b)$. Concretely, unfolding both sides and
splitting on the six orderings of $x, a, b$ closes it. $\square$

**Proposition 3.3 (Elementary properties).** Let $a \le b$ and write $P = P_{[a,b]}$. Then

1. $P$ is monotone: $x \le y \Rightarrow Px \le Py$;
2. $Px \in [a,b]$ for all $x$;
3. $Px = x$ whenever $x \in [a,b]$ (so $P$ is idempotent and $\operatorname{Fix} P = [a,b]$);
4. $Px = a$ for $x \le a$ and $Px = b$ for $x \ge b$.

*Proof sketch.* (1) $\max$ and $\min$ are monotone in each argument. (2) $Px \ge a$ from the
outer $\max$; $Px \le b$ since both $a \le b$ and $\min(x,b) \le b$. (3)–(4) are direct
evaluations of $\max(a,\min(x,b))$ under the stated hypotheses. $\square$

Theorem 3.2 converts *every* statement of §4–§6 about interval projections into a statement
about the three-seed median, and conversely.

---

## 4. Firm nonexpansiveness

### 4.1 Algebraic normal form

**Lemma 4.1 (Inner-product form of firmness).** $T$ is firmly nonexpansive if and only if
$$(Tx - Ty)^2 \le (Tx - Ty)(x - y) \qquad \text{for all } x,y. \tag{4.1}$$

*Proof sketch.* Put $u = Tx - Ty$ and $v = x - y$. Then (2.1) reads $u^2 + (v-u)^2 \le v^2$,
i.e. $2u^2 \le 2uv$, i.e. $u^2 \le uv$, which is (4.1). $\square$

In Hilbert-space language, (4.1) is $\langle Tx - Ty,\, x-y\rangle \ge \lVert Tx-Ty\rVert^2$:
firmly nonexpansive operators are strongly monotone relative to their own displacement.

### 4.2 The variational inequality

**Theorem 4.2 (Variational inequality / obtuse angle).** Let $a \le b$, $x \in \mathbb{R}$ and
$y \in [a,b]$. Then
$$(x - P_{[a,b]}x)\,(y - P_{[a,b]}x) \le 0.$$

*Proof sketch.* Three cases. If $x \le a$ then $Px = a$, the first factor is $x - a \le 0$ and
the second is $y - a \ge 0$. If $x \in [a,b]$ then $Px = x$ and the first factor vanishes. If
$x \ge b$ then $Px = b$, the first factor is $x - b \ge 0$ and the second is $y - b \le 0$.
$\square$

Geometrically: from the projected point, the residual $x - Px$ and every direction $y - Px$
into the interval subtend an obtuse (or right) angle. This single inequality is the engine of
everything that follows.

### 4.3 The headline theorem

**Theorem 4.3 (Firm nonexpansiveness of the median-as-projection).** Let $a \le b$. Then
$P_{[a,b]}$ is firmly nonexpansive:
$$(Px - Py)^2 + \bigl((x - Px) - (y - Py)\bigr)^2 \le (x-y)^2 \qquad \text{for all } x,y.$$

*Proof sketch.* By Lemma 4.1 it suffices to prove $(Px - Py)^2 \le (Px - Py)(x-y)$. Apply
Theorem 4.2 twice: once at the point $x$ with the admissible test point $Py \in [a,b]$
(Proposition 3.3(2)), giving $(x - Px)(Py - Px) \le 0$; and once at $y$ with test point $Px$,
giving $(y - Py)(Px - Py) \le 0$. Adding the two inequalities and expanding,
$$(Px-Py)^2 \le (Px-Py)(x-y),$$
which is the claim. This is verbatim the classical Hilbert-space argument. $\square$

**Interpretation.** The perturbation $x \mapsto y$ has a fixed quadratic budget $(x-y)^2$,
divided between (i) the motion of the reported estimate and (ii) the motion of the *absorbed
residual* $x - Px$, the portion of the corruption the median discards. Output motion is paid
for by absorption in quadrature.

**Corollary 4.4 (Nonexpansiveness).** Every firmly nonexpansive $T$ satisfies $|Tx - Ty| \le
|x-y|$. In particular the median moves by at most the perturbation of a single seed.

*Proof sketch.* Drop the nonnegative residual term in (2.1) to get $(Tx-Ty)^2 \le (x-y)^2$,
then take square roots. $\square$

### 4.4 Nearest point, Pythagoras, uniqueness

**Theorem 4.5 (Pythagorean inequality).** Let $a \le b$, $x\in\mathbb{R}$, $y\in[a,b]$. Then
$$(x - Px)^2 + (Px - y)^2 \le (x-y)^2.$$

*Proof sketch.* Expand $(x-y)^2 = \bigl((x - Px) + (Px - y)\bigr)^2 = (x-Px)^2 + (Px-y)^2 +
2(x-Px)(Px-y)$, and note that Theorem 4.2 gives $(x-Px)(Px - y) \ge 0$ (it is the negative of
the variational product). $\square$

**Corollary 4.6 (Nearest point).** $|x - Px| \le |x - y|$ for every $y \in [a,b]$: the median
realises the distance from $x$ to the bracket.

**Theorem 4.7 (Uniqueness of the minimiser).** If $y \in [a,b]$ and $(x-y)^2 \le (x - Px)^2$,
then $y = Px$. Equivalently, $Px$ is the *unique* minimiser of $y \mapsto |x-y|$ over $[a,b]$,
so the median is the proximal map of the indicator function $\iota_{[a,b]}$:
$$P_{[a,b]}(x) = \operatorname{prox}_{\iota_{[a,b]}}(x) = \operatorname*{arg\,min}_{y}\ \tfrac12 (x-y)^2 + \iota_{[a,b]}(y).$$

*Proof sketch.* Combining the hypothesis with Theorem 4.5 gives $(Px - y)^2 \le 0$, hence
$Px = y$. $\square$

Theorem 4.7 is the statement that the median is not merely *a* central value but the solution
of an explicit variational problem — which is why the convex-analytic machinery applies at all.

---

## 5. The characterisation

### 5.1 Firmness on the line is an order condition

**Theorem 5.1 (Characterisation of firm nonexpansiveness on $\mathbb{R}$).** A map
$T:\mathbb{R}\to\mathbb{R}$ is firmly nonexpansive if and only if it is monotone and
$1$-Lipschitz in increment form: for all $x\le y$,
$$Tx \le Ty \quad\text{and}\quad Ty - Tx \le y - x.$$

*Proof sketch.* ($\Rightarrow$) Use the normal form (4.1) at the pair $(y,x)$ with $x\le y$:
$(Ty - Tx)^2 \le (Ty - Tx)(y - x)$. If $Ty - Tx < 0$ then dividing by the negative quantity
$Ty-Tx$ gives $Ty - Tx \ge y - x \ge 0$, a contradiction; hence $Ty \ge Tx$. Given monotonicity,
if $Ty - Tx > 0$ we may divide by it to get $Ty - Tx \le y-x$, and if $Ty = Tx$ the bound is
trivial. ($\Leftarrow$) Given $x \le y$, monotonicity gives $Ty - Tx \ge 0$ and the Lipschitz
bound gives $Ty - Tx \le y - x$; multiplying the two nonnegative quantities $Ty - Tx$ and
$(y-x) - (Ty - Tx)$ yields $(Ty-Tx)^2 \le (Ty-Tx)(y-x)$, i.e. (4.1). The case $y \le x$ is
symmetric. $\square$

This theorem is the pivot of the paper: it converts a *metric* hypothesis into an *order*
hypothesis. In a general Hilbert space no such collapse occurs; monotone and nonexpansive are
genuinely different conditions there, and firmness is strictly between them.

**Theorem 5.2 (Reflection form).** $T$ is firmly nonexpansive if and only if its reflection
$R = 2T - I$ is nonexpansive; equivalently, $T = \tfrac12(I + R)$ is the midpoint average of the
identity and a nonexpansive map.

*Proof sketch.* Expand $\bigl(Rx - Ry\bigr)^2 = \bigl(2(Tx-Ty) - (x-y)\bigr)^2 =
4(Tx-Ty)^2 - 4(Tx-Ty)(x-y) + (x-y)^2$. Thus $(Rx-Ry)^2 \le (x-y)^2$ is equivalent to
$(Tx-Ty)^2 \le (Tx-Ty)(x-y)$, which is (4.1). $\square$

Theorem 5.2 is the standard "averaged operator" picture: firmly nonexpansive maps are exactly
the $\tfrac12$-averaged ones, hence exactly the resolvents of maximal monotone operators. For
the median, the underlying monotone operator is the normal cone of the bracket.

**Proposition 5.3 (Order-convex fixed-point sets).** If $T$ is firmly nonexpansive, $Tu = u$,
$Tv = v$ and $u \le w \le v$, then $Tw = w$.

*Proof sketch.* By Theorem 5.1 applied to the pair $u \le w$, $Tw - u = Tw - Tu \le w - u$, so
$Tw \le w$. Applied to the pair $w \le v$, $v - Tw = Tv - Tw \le v - w$, so $Tw \ge w$. Hence
$Tw = w$. $\square$

This is the one-dimensional shadow of the Hilbert-space fact that $\operatorname{Fix} T$ is a
closed convex set when $T$ is firmly nonexpansive: a robust estimator's agreement region has no
holes.

### 5.2 The median is determined by three axioms

**Theorem 5.4 (Characterisation of the median-as-projection).** Fix $a \le b$ and let
$T : \mathbb{R} \to \mathbb{R}$. Then $T = P_{[a,b]}$ if and only if all three hold:

1. $T$ is firmly nonexpansive;
2. $Ta = a$ and $Tb = b$;
3. $Tx \in [a,b]$ for every $x$.

*Proof sketch.* ($\Rightarrow$) Theorem 4.3 and Proposition 3.3. ($\Leftarrow$) Rewrite (1) as
monotone $+$ $1$-Lipschitz by Theorem 5.1 and split on the position of $x$.
*If $x \le a$:* monotonicity gives $Tx \le Ta = a$, while (3) gives $Tx \ge a$; hence
$Tx = a = P_{[a,b]}x$. *If $x \ge b$:* symmetrically $Tx = b$. *If $a \le x \le b$:* the
Lipschitz bound on $[a,x]$ gives $Tx - a = Tx - Ta \le x - a$, i.e. $Tx \le x$, and on $[x,b]$
gives $b - Tx = Tb - Tx \le b - x$, i.e. $Tx \ge x$; hence $Tx = x = P_{[a,b]}x$. $\square$

Note how sparingly the hypotheses are used: only the order content of firmness is needed. This
is exactly why firmness — and not merely the Lipschitz bound — is the right hypothesis, as we
now show.

### 5.3 Firmness is necessary: a nonexpansive impostor

**Theorem 5.5 (Sharpness).** There exists a map $T : \mathbb{R}\to\mathbb{R}$ which is
nonexpansive, has range contained in $[0,1]$, and whose fixed-point set is exactly $[0,1]$ —
identical to that of $P_{[0,1]}$ — but with $T \ne P_{[0,1]}$.

*Proof sketch.* Take $T(x) = \min(|x|, 1)$.

*Nonexpansive:* $u \mapsto \min(u,1)$ is $1$-Lipschitz (a clamp, by Corollary 4.4), and
$x\mapsto |x|$ satisfies the reverse triangle inequality $\bigl||x| - |y|\bigr| \le |x-y|$;
compose.

*Range:* $0 \le \min(|x|,1) \le 1$.

*Fixed points:* if $T x = x$ then $x = \min(|x|,1) \in [0,1]$; conversely if $x \in [0,1]$ then
$|x| = x$ and $\min(x,1) = x$.

*Not the projection:* $T(-2) = \min(2,1) = 1$, whereas $P_{[0,1]}(-2) = 0$. $\square$

The impostor fails exactly one clause of Theorem 5.4's hypothesis list — it is not monotone,
hence by Theorem 5.1 not firmly nonexpansive — and its failure is qualitatively catastrophic
for the application: it reports a seed that is far *below* the bracket as though it were far
*above* it. Nonexpansiveness alone therefore does not axiomatise the median; the Pythagorean
inequality (2.1) is load-bearing.

---

## 6. What is one-dimensional and what is not

### 6.1 Composition: a theorem about the line

**Theorem 6.1 (Closure under composition on $\mathbb{R}$).** If $S,T : \mathbb{R}\to\mathbb{R}$
are firmly nonexpansive, so is $S \circ T$.

*Proof sketch.* By Theorem 5.1 firmness is the conjunction of monotone and $1$-Lipschitz, and
each of these classes is closed under composition: for $x \le y$, $Tx \le Ty$ and hence
$S(Tx) \le S(Ty)$, while $S(Ty) - S(Tx) \le Ty - Tx \le y - x$. $\square$

This is *not* a Hilbert-space fact. Composition of firmly nonexpansive operators is only
averaged, not firmly nonexpansive, in general — and the failure is already visible in the plane.

**Theorem 6.2 (Failure in $\mathbb{R}^2$).** Let $P_1(u,v) = (u,0)$ be the orthogonal projection
onto the horizontal axis and $P_2(u,v) = \bigl(\tfrac{u+v}{2}, \tfrac{u+v}{2}\bigr)$ the
orthogonal projection onto the diagonal. Both are firmly nonexpansive, but $P_1 \circ P_2$ is
not.

*Proof sketch.* Firmness of $P_1$: with $x - y = (s,t)$, the left side of Definition 2.6 is
$s^2 + t^2 = \lVert x-y\rVert^2$, with equality. Firmness of $P_2$: writing $s,t$ as above,
$\lVert P_2x - P_2y\rVert^2 = \tfrac{(s+t)^2}{2}$ and
$\lVert (I-P_2)x - (I-P_2)y\rVert^2 = \tfrac{(s-t)^2}{2}$, and these sum to exactly $s^2+t^2$;
in fact any orthogonal projection satisfies (2.1) with equality.

Failure of the composite: take $x = (0,1)$, $y = (0,0)$ and $T = P_1\circ P_2$. Then
$Tx = (\tfrac12, 0)$ and $Ty = (0,0)$, so $\lVert Tx - Ty\rVert^2 = \tfrac14$; and
$(x - Tx) - (y - Ty) = (-\tfrac12, 1)$, of squared norm $\tfrac54$. The total $\tfrac32$ exceeds
$\lVert x - y\rVert^2 = 1$. $\square$

So Theorem 6.1 is genuinely about the line: it depends on the total order of $\mathbb{R}$
through Theorem 5.1, and there is no rotation to spoil it. (Nonexpansiveness of the composite,
of course, survives in every dimension.)

### 6.2 Firmness lifts: box projections and the coordinatewise median

**Theorem 6.3 (Firmness of the coordinatewise median in $\mathbb{R}^n$).** Let $a_i \le b_i$ for
all $i$ and let $P_{[a,b]}$ be the coordinatewise clamp of Definition 2.7 — equivalently, the
coordinatewise median with clean seeds $a_i, b_i$. Then $P_{[a,b]}$ is firmly nonexpansive for
the Euclidean norm on $\mathbb{R}^n$.

*Proof sketch.* Definition 2.6 is a sum over coordinates of the one-dimensional inequality
(2.1); each summand is Theorem 4.3 applied in coordinate $i$. Summing $n$ valid inequalities
gives the result. $\square$

**Theorem 6.4 (Nearest point in $\mathbb{R}^n$).** For every $y$ in the box,
$\lVert x - P_{[a,b]}x\rVert \le \lVert x - y\rVert$; and discarding the residual term in
Theorem 6.3 gives Euclidean nonexpansiveness of the coordinatewise median.

*Proof sketch.* Coordinatewise, the variational inequality (Theorem 4.2) gives
$(x_i - Px_i)^2 \le (x_i - y_i)^2$; sum over $i$. $\square$

The contrast with Theorem 6.2 is the point: firmness of the median is *not* a one-dimensional
accident, whereas closure of firmness under composition *is*.

---

## 7. Perturbing every seed at once

All the estimates so far move a single seed. A re-run of the whole experiment moves all of
them, and the natural norm is $\ell^\infty$: the size of the largest single drift.

**Lemma 7.1 (Joint monotonicity).** If $a_1\le a_2$, $b_1 \le b_2$ and $c_1 \le c_2$ then
$\operatorname{med}(a_1,b_1,c_1) \le \operatorname{med}(a_2,b_2,c_2)$.

*Proof sketch.* $\operatorname{med}(a,b,c) = \max\bigl(\min(a,b),\min(\max(a,b),c)\bigr)$ is
built from $\max$ and $\min$, each monotone in each argument; monotonicity therefore propagates
through the expression. $\square$

**Lemma 7.2 (Translation equivariance).** $\operatorname{med}(a+d, b+d, c+d) = \operatorname{med}(a,b,c) + d$.

*Proof sketch.* $t \mapsto t+d$ is an order isomorphism of $\mathbb{R}$, and the median commutes
with order isomorphisms. $\square$

**Theorem 7.3 ($\ell^\infty$-nonexpansiveness of the median).** For all reals,
$$\bigl|\operatorname{med}(a,b,c) - \operatorname{med}(a',b',c')\bigr| \le \max\bigl(|a-a'|,|b-b'|,|c-c'|\bigr).$$

*Proof sketch.* Let $d$ be the right-hand side. Then $a' \le a + d$, $b' \le b+d$, $c'\le c+d$,
so Lemmas 7.1 and 7.2 give $\operatorname{med}(a',b',c') \le \operatorname{med}(a,b,c) + d$. The
symmetric argument gives the reverse, and the two combine into the absolute-value bound.
$\square$

Theorem 7.3 strictly generalises Corollary 4.4 (take $b = b'$, $c = c'$).

**Theorem 7.4 (Every rung of the quota ladder is $\ell^\infty$-$1$-Lipschitz).** Let
$K, K' : \iota \to \mathbb{N}$ be finite ensembles with $|K_i - K'_i| \le d$ for all $i$, and let
$m \le |\iota|$. Then $|Q(K,m) - Q(K',m)| \le d$.

*Proof sketch.* Two structural facts suffice.
*(i) Pointwise monotonicity:* if $K_i \le K'_i$ for all $i$ then $Q(K,m) \le Q(K',m)$, because
the set of indices certifying any budget can only grow when every entry grows.
*(ii) Shift bound:* $Q(K + d, m) \le Q(K,m) + d$, because the indices certifying $Q(K,m)$ under
$K$ certify $Q(K,m)+d$ under $K+d$, and the budget is defined as a maximum over such certifying
sets.
Now $K_i \le K'_i + d$ for all $i$, so (i) followed by (ii) gives
$Q(K,m) \le Q(K'+d, m) \le Q(K',m) + d$; symmetrically for the other direction. $\square$

**Discussion.** Theorem 7.4 says Lipschitz robustness does *not* distinguish the rungs of the
ladder: the maximum, the median and the conservative low tail are all equally $1$-Lipschitz. What
distinguishes them is the *breakdown point*: the fraction of entries that may be corrupted
arbitrarily before the summary becomes meaningless. For the maximum the breakdown point is $0$;
for the median it is $1/2$. Small-perturbation stability and gross-error resistance are
independent invariants of a selector, and the median is optimal on the second while tied on the
first.

**Example 7.5 (A grid-stability guarantee).** For the ensemble $\{256,224,160\}$, whose median
is $224$: if a full re-run of the experiment moves every seed by at most one grid step of $32$,
then the reported knee moves by at most $32$. Immediate from Theorem 7.3.

---

## 8. Iterating the median filter

### 8.1 Relaxed updates with an exact rate

Fix $a\le b$, $P = P_{[a,b]}$, and $\lambda \in (0,1]$. The *relaxed median update* is
$$T_\lambda(x) := (1-\lambda)x + \lambda P x.$$

**Lemma 8.1 (Relaxation does not change the projection).** For $0 \le \lambda \le 1$,
$P\bigl(T_\lambda x\bigr) = Px$.

*Proof sketch.* $T_\lambda x$ lies on the segment between $x$ and $Px$, hence (by monotonicity of
$P$, Proposition 3.3(1)) its projection lies between $P(x)$ and $P(Px) = Px$, both equal to
$Px$. Formally: if $x \le Px$ then $x \le T_\lambda x \le Px$, and applying the monotone $P$ to
both inequalities sandwiches $P(T_\lambda x)$ between $Px$ and $Px$; the case $Px \le x$ is
symmetric. $\square$

**Theorem 8.2 (Exact geometric decay).** For $0 \le \lambda \le 1$ and all $n \ge 0$,
$$T_\lambda^{\,n}(x) - Px = (1-\lambda)^n\,(x - Px).$$

*Proof sketch.* Induction on $n$. The step is the identity $T_\lambda z - Pz = (1-\lambda)(z-Pz)$,
applied at $z = T_\lambda^{\,n}x$, combined with Lemma 8.1 (iterated), which guarantees
$P z = Px$. $\square$

**Corollary 8.3 (Krasnoselskii–Mann with an exact rate).** For $0 < \lambda \le 1$,
$T_\lambda^{\,n}(x) \to Px$ as $n \to \infty$, with error exactly $(1-\lambda)^n|x - Px|$.

*Proof sketch.* $T_\lambda^{\,n}x = Px + (1-\lambda)^n(x-Px)$ by Theorem 8.2, and
$|1-\lambda| < 1$, so the geometric factor tends to $0$. $\square$

The statement is stronger than the classical Krasnoselskii–Mann theorem in two respects: the
rate is an equality, not a bound, and it is valid for every $n$, not asymptotically.

### 8.2 Unrelaxed iteration: an order-theoretic convergence theorem

Relaxation was used above only to make the residual contract. Is it needed? In a general Hilbert
space, unrelaxed iteration of a nonexpansive map can fail to converge (rotations), and even for
firmly nonexpansive maps one obtains only weak convergence. On the line, the answer is an
unqualified yes.

**Theorem 8.4 (Unrelaxed convergence on the line).** Let $T:\mathbb{R}\to\mathbb{R}$ be firmly
nonexpansive with at least one fixed point $p$. Then for every $x$, the orbit $u_n = T^n x$
converges to a fixed point of $T$.

*Proof sketch.* By Theorem 5.1, $T$ is monotone and $1$-Lipschitz, hence continuous. Suppose
$p \le x$. Monotonicity and $Tp = p$ give $p \le u_n$ for all $n$ by induction, so the half-line
$[p,\infty)$ is invariant. The Lipschitz bound on the pair $p \le u_n$ gives
$u_{n+1} - p = Tu_n - Tp \le u_n - p$, i.e. $u_{n+1} \le u_n$: the orbit is nonincreasing and
bounded below by $p$. By order completeness of $\mathbb{R}$, $u_n \downarrow q := \inf_n u_n$.
Continuity plus $u_{n+1} = T u_n$ gives $Tq = q$ by uniqueness of limits. The case $x \le p$ is
symmetric, with a nondecreasing orbit bounded above. $\square$

Two remarks. First, the proof is order-theoretic, not metric: completeness of the order supplies
the limit, and no contraction estimate is used. Second, no rate is available and none can be:
the identity is firmly nonexpansive and its orbits are constant, so Corollary 8.3 is not
subsumed.

### 8.3 No spurious compromises, and alternating median filters

**Theorem 8.5 (Fixed points of compositions).** Let $S,T:\mathbb{R}\to\mathbb{R}$ be firmly
nonexpansive with a common fixed point $p$. If $S(Tq) = q$, then $Tq = q$ and $Sq = q$.

*Proof sketch.* Assume $p \le q$ (the other case is symmetric). Monotonicity of $T$ gives
$p \le Tq$ and the Lipschitz bound gives $Tq \le q$. Applying the Lipschitz bound of $S$ to the
pair $p \le Tq$ and using $Sp = p$, $S(Tq) = q$ yields $q - p \le Tq - p$, i.e. $q \le Tq$. Hence
$Tq = q$, and then $Sq = S(Tq) = q$. $\square$

In Hilbert-space language this is $\operatorname{Fix}(S\circ T) = \operatorname{Fix} S \cap
\operatorname{Fix} T$ for firmly nonexpansive $S,T$ with a common fixed point.

**Theorem 8.6 (Alternating median filters converge to a consensus).** Let $[a,b]$ and $[c,d]$ be
brackets certified by two independent ensembles, with $[a,b]\cap[c,d] \ne \emptyset$. Then for
every starting value $x$, the alternating iteration
$$x_{n+1} = P_{[a,b]}\bigl(P_{[c,d]}(x_n)\bigr)$$
converges, and its limit lies in $[a,b]\cap[c,d]$.

*Proof sketch.* $P_{[a,b]}$ and $P_{[c,d]}$ are firmly nonexpansive (Theorem 4.3) and any point
$p$ of the intersection is a common fixed point (Proposition 3.3(3)). Their composite is firmly
nonexpansive by Theorem 6.1 and fixes $p$, so Theorem 8.4 gives convergence to some fixed point
$q$ of the composite. Theorem 8.5 upgrades $q$ to a common fixed point of both projections, and
a point fixed by $P_{[a,b]}$ lies in $[a,b]$; likewise for $[c,d]$. $\square$

Theorem 8.5 is what rules out a *spurious compromise*: the alternating filter cannot settle at a
point that satisfies neither bracket. Note also that a single unrelaxed median filter stabilises
in one step, $P^{\,n+1} = P$ for $n \ge 0$ — iteration is interesting only for compositions.

**Example 8.7.** With the brackets $[160,256]$ and $[224,384]$, the alternating filter started
anywhere converges into $[224,256]$: a budget simultaneously consistent with both ensembles.

---

## 9. Algorithmic summary

The theory yields four immediately implementable procedures.

**A. Robust knee report (one step, $O(1)$).** Given three seeds, sort and take the middle;
equivalently clamp any one seed into the bracket of the other two. The reported value carries the
guarantee of Theorem 4.3: any redrawing of one seed by $\delta$ changes the report by at most
$\delta$, and the output shift and the residual shift lie in a disc of radius $\delta$ (on its boundary when the two seed values fall on the same side of the bracket).

**B. Ensemble grid-stability certificate ($O(n)$).** Given two runs $K, K'$ of the same ensemble,
compute $d = \lVert K - K'\rVert_\infty$; Theorem 7.4 then certifies that *every* rung of the
quota ladder differs by at most $d$, with no further computation.

**C. Relaxed median tracking ($O(1)$ per step).** For a streaming estimate that must not jump,
apply $x \mapsto (1-\lambda)x + \lambda\,\operatorname{med}(x,a,b)$. Theorem 8.2 gives the exact
error $(1-\lambda)^n|x_0 - \operatorname{med}|$, so the number of steps to a tolerance $\varepsilon$
is $\lceil \log(\varepsilon/|x_0 - \mathrm{med}|)/\log(1-\lambda)\rceil$ — known in advance.

**D. Two-ensemble consensus ($O(1)$ per step; finite in practice).** Alternate the two clamps.
Theorem 8.6 guarantees convergence into the intersection when the brackets overlap. On the line,
in fact, the alternating projection onto two overlapping intervals reaches the intersection after
at most two steps; the theorem's value is that it holds without assuming overlap-detection and
extends the reasoning to longer chains of filters.

---

## 10. Discussion

### 10.1 Why "firm" rather than "nonexpansive"

The practitioner's rule of thumb — "the median moves by no more than the corruption" — is
Corollary 4.4, and it is true but lossy. The exact statement is the quadratic budget of
Theorem 4.3. The extra term is not a technical decoration: Theorem 5.5 exhibits a nonexpansive
map with the *same range* and the *same fixed-point set* as the median that nevertheless
mis-reports the direction of an outlier. Robustness axiomatised by the Lipschitz constant alone
is therefore too weak to pin down the estimator; robustness axiomatised by firmness is exactly
right (Theorem 5.4).

### 10.2 Two independent axes of robustness

Theorem 7.4 establishes that all rungs of an order-statistic ladder share the same $\ell^\infty$
Lipschitz constant $1$. Consequently the classical hierarchy among order statistics — max is
fragile, median is robust — is *entirely* a breakdown-point phenomenon and *not* a Lipschitz
phenomenon. This clean separation is worth emphasising because the two are often conflated in
applied discussions of "stability".

### 10.3 Dimension

Theorems 6.2 and 6.3 draw a sharp line. Firmness of the median survives the passage from
$\mathbb{R}$ to $\mathbb{R}^n$ (coordinate sums), because the coordinatewise median *is* a box
projection. Closure of firmness under composition does not survive, because it depends on the
collapse of firmness to an order condition (Theorem 5.1), and there is no such collapse in
$\mathbb{R}^2$. The consequence for algorithm design is that chained median filters are
unconditionally well-behaved on scalar streams, while chained multidimensional filters require
the standard averaged-operator theory (composites are $\tfrac{2}{3}$-averaged, not firmly
nonexpansive) to guarantee convergence.

### 10.4 Relation to proximal algorithms

By Theorem 4.7 the median is $\operatorname{prox}_{\iota_{[a,b]}}$, and by Theorem 5.2 it is the
$\tfrac12$-average of the identity with the reflection $2P - I$. It is therefore the resolvent
$(I + N)^{-1}$ of the normal-cone operator $N$ of the bracket. Every splitting scheme — forward-
backward, Douglas–Rachford, ADMM — that admits a projection step admits a *median* step, with the
robust-statistics reading attached. That the median is a resolvent is the structural reason the
iteration theory of §8 exists at all.

---

## 11. Future work

**C1. Classification of ensemble selectors.** Let $F : \mathbb{R}^n \to \mathbb{R}$ be
translation equivariant ($F(K + c\mathbf{1}) = F(K)+c$), permutation invariant, $\ell^\infty$-$1$-Lipschitz,
and internal ($F(K) \in [\min K, \max K]$). These four clauses do not force $F$ to be an order
statistic — medians of sub-multisets and midranges qualify. The conjecture is that adding
coordinatewise monotonicity and idempotence under single-seed constant perturbations does force
$F$ to be the $k$-th order statistic for some $k$. Theorem 7.4 supplies the Lipschitz clause for
every rung of the ladder and Lemma 7.1 supplies monotonicity; what is missing is the converse.
Theorem 5.1 is the reason such a classification is conceivable at all: it converts a metric
hypothesis into an order hypothesis, and order hypotheses classify.

**C2. Independence of breakdown point and Lipschitz constant.** Conjecturally, for every
admissible pair $(\beta, L)$ of breakdown point and Lipschitz constant there is a selector
realising it, so the two invariants are logically independent. §7 proves one half by exhibiting a
whole ladder with constant $L = 1$ and every breakdown point from $0$ to $1/2$.

**C3. Higher-dimensional characterisation.** Theorem 5.4 characterises the median among self-maps
of the line. Does the coordinatewise median admit an analogous characterisation among self-maps of
$\mathbb{R}^n$ — firmly nonexpansive, fixing the vertices of the box, with range in the box? The
collapse used in the one-dimensional proof is unavailable, so a genuinely convex-analytic argument
is required.

**C4. Rates for unrelaxed composites.** Theorem 8.4 gives convergence with no rate, and no rate is
possible in general. Under what geometric hypotheses on two brackets (e.g. an overlap of positive
length) does the alternating filter of Theorem 8.6 converge linearly, with a rate expressible in
terms of the overlap?

**C5. Median splitting schemes.** Exploit §10.4 systematically: replace projection steps in
standard splitting algorithms by median steps over ensembles of constraints, and quantify the
resulting robustness of the whole algorithm to corrupted constraints.

---

## 12. Conclusion

The median of three numbers is the metric projection onto the interval spanned by two of them. As
a consequence its robustness is not merely Lipschitz but *firm*: the displacement of the estimate
and the displacement of the absorbed residual obey a Pythagorean budget. Firm nonexpansiveness on
the line is precisely monotonicity together with the $1$-Lipschitz bound, and that identification
characterises the median outright among self-maps of the line by three axioms, none of which can
be weakened to plain nonexpansiveness. Firmness survives the passage to $\mathbb{R}^n$ but closure
under composition does not; simultaneous perturbation is controlled in $\ell^\infty$ for every rung
of an order-statistic ladder, isolating the breakdown point as the only invariant that separates
those rungs; and iteration — relaxed with an exact geometric rate, or unrelaxed by an
order-theoretic completeness argument — yields convergent median filters that find genuine
consensus between two ensembles. A statistic long defended by folklore turns out to have been an
object of convex geometry all along.
