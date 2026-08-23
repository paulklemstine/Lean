# Sharp Curvature of the Lagrange Exponent: Concavity Above the Critical Mass $1/27$

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

We study the *Lagrange exponent* $\sigma : \mathbb{R} \to \mathbb{R}$, the global inverse of the
critical cubic $h(y) = y^{3} - y^{2} + \tfrac{1}{3} y$. This cubic is distinguished among all
monic cubics normalised by $h(0)=0$ by the fact that its derivative is a perfect square,
$h'(y) = 3\bigl(y - \tfrac13\bigr)^{2}$; its two critical points have coalesced into a single
degenerate one at $y = 1/3$. Consequently $h$ is a strictly increasing bijection of $\mathbb{R}$,
Lagrange's resolvent degenerates to a single real radical, and the inverse admits the closed form
$$\sigma(t) = \frac{1 + \sqrt[3]{27t - 1}}{3},$$
with the sign-aware real cube root.

Our main theorem is that $\sigma$ is *strictly concave* on the ray $[1/27, \infty)$, so that
averaging masses never decreases the associated growth rate; in midpoint form,
$\tfrac12\bigl(\sigma(s) + \sigma(t)\bigr) \le \sigma\bigl(\tfrac{s+t}{2}\bigr)$, with strict
inequality for $s \ne t$, and in Jensen form for arbitrary finite convex combinations. We prove
the exact complementary statement: $\sigma$ is strictly *convex* on $(-\infty, 1/27]$, and hence
the threshold is sharp — $\sigma$ is concave on $[c, \infty)$ if and only if $c \ge 1/27$, and
convex on $(-\infty, c]$ if and only if $c \le 1/27$. The inflection at $t = 1/27$ is exactly the
image under $h$ of the degenerate critical point $y = 1/3$.

We then derive the structural consequences that concavity is for: the *cube-root sandwich*
$\sqrt[3]{t} \le \sigma(t) \le \sqrt[3]{t} + \tfrac13$ on the physical range with both constants
optimal; a *merging law* $\sigma(s + t - \tfrac1{27}) + \tfrac13 \le \sigma(s) + \sigma(t)$ and
its $n$-fold iterate, in which the critical overhead is paid exactly once; the differentiability
statement $\sigma'(t) = 3(27t-1)^{-2/3}$ on $(1/27,\infty)$ with antitone derivative; and the
order-isomorphism structure of $\sigma$. Finally we exhibit the arithmetic origin of the constant:
by the three-variable AM–GM inequality, any probability vector $(p,q,r)$ has $pqr \le 1/27$ with
equality only at the uniform vector, so the critical mass is precisely the extremal product mass
of a three-point distribution and $\sigma(pqr) \le 1/3$, with equality iff $p=q=r=1/3$.

**Keywords:** Lagrange exponent, degenerate cubic, real cube root, concavity threshold, sharp
inflection, Jensen's inequality, AM–GM, subadditivity, order isomorphism.

---

## 1. Introduction

### 1.1 The mixing question

Let $\sigma$ be a real-valued function of a scalar *mass* parameter $t$, interpreted as the growth
rate, yield, or exponent produced by some mechanism supplied with mass $t$. The most basic
structural question one can ask about such a mechanism is whether it rewards *homogenisation*:
given two masses $s$ and $t$, is
$$\frac{\sigma(s) + \sigma(t)}{2} \;\le\; \sigma\!\left(\frac{s+t}{2}\right)\;?$$
If so, pooling two batches into one of average mass is never worse than running them separately
and averaging the outputs; the mechanism rewards compromise. The inequality above is exactly
midpoint concavity, and for a continuous function it is equivalent to concavity.

This paper answers the mixing question, sharply and in both directions, for a specific and
canonically-arising $\sigma$: the inverse of a cubic whose derivative is a perfect square.

### 1.2 The critical cubic

Define
$$h(y) \;=\; y^{3} - y^{2} + \frac{y}{3}, \qquad y \in \mathbb{R}.$$

**Degeneracy.** Differentiating,
$$h'(y) = 3y^{2} - 2y + \frac13 = 3\left(y - \frac13\right)^{2} \;\ge\; 0 ,$$
with equality only at $y = 1/3$. Thus $h$ is a monic cubic, normalised by $h(0)=0$, whose
derivative is a perfect square: the two critical points of a generic cubic have collided into one
degenerate critical point. Up to affine normalisation, $h$ is the unique such cubic. In particular
$h$ is strictly increasing on $\mathbb{R}$ (it is nondecreasing, and its derivative vanishes at a
single point), hence a bijection of $\mathbb{R}$ onto itself.

**Collapse to a pure cube.** The degeneracy is equivalent to the identity
$$h(y) \;=\; \frac{(3y-1)^{3} + 1}{27},$$
verified by expansion. So $h$ is an increasing affine reparametrisation of the pure cube
$u \mapsto u^{3}$; the general theory of cubic resolvents, applied here, produces a single real
radical rather than the usual triple of Cardano expressions.

### 1.3 The Lagrange exponent

Because $h$ is a bijection, it has a global inverse.

**Definition 1.1 (real cube root).** For $x \in \mathbb{R}$ set
$$\sqrt[3]{x} \;=\; \begin{cases} x^{1/3}, & x \ge 0,\\ -\,(-x)^{1/3}, & x < 0.\end{cases}$$
This is the unique real solution of $u^{3} = x$; it is odd, $\sqrt[3]{-x} = -\sqrt[3]{x}$,
strictly increasing, and satisfies $\bigl(\sqrt[3]{x}\bigr)^{3} = x$ for every real $x$.

**Definition 1.2 (Lagrange exponent).** The *Lagrange exponent* is
$$\sigma(t) \;=\; \frac{1 + \sqrt[3]{27t-1}}{3}, \qquad t \in \mathbb{R}.$$

**Proposition 1.3 (inversion).** For all $y, t \in \mathbb{R}$,
$$h(\sigma(t)) = t \quad\text{and}\quad \sigma(h(y)) = y .$$
Moreover $\sigma$ is strictly increasing and injective, and it is the *unique* solution of
$h(y)=t$: if $h(y) = t$ then $y = \sigma(t)$.

*Proof.* Since $3\sigma(t) - 1 = \sqrt[3]{27t-1}$, the shift identity gives
$h(\sigma(t)) = \bigl((3\sigma(t)-1)^{3} + 1\bigr)/27 = \bigl((27t-1)+1\bigr)/27 = t$. The other
composite follows by injectivity of the strictly monotone $h$. Strict monotonicity of $\sigma$ is
inherited from that of $t \mapsto 27t-1$ and of the cube root. $\square$

**Sample values.** $\sigma(0)=0$; $\sigma(1/27) = 1/3$ (since $h(1/3) = 1/27$);
$\sigma(1/3) = 1$ (since $h(1)=1/3$); $\sigma(28/27) = 4/3$ (since $h(4/3)=28/27$).

**Definition 1.4 (critical mass).** The *critical mass* is $t_{c} = h(1/3) = 1/27$, the image of
the degenerate critical point. The *physical range* is the ray $[1/27, \infty)$.

**Proposition 1.5 (threshold characterisation).** $\sigma(t) \ge 1/3$ if and only if
$t \ge 1/27$.

*Proof.* Immediate from strict monotonicity of $\sigma$ and $\sigma(1/27)=1/3$. $\square$

### 1.4 Summary of results

* **§2** — Strict concavity of $\sigma$ on $[1/27,\infty)$; midpoint and Jensen forms.
* **§3** — Strict convexity on $(-\infty, 1/27]$ and sharpness of the threshold in both
  directions, giving the exact iff-characterisations of the concavity and convexity rays.
* **§4** — Differentiability above the critical mass, $\sigma'(t) = 3(27t-1)^{-2/3}$, with
  antitone derivative.
* **§5** — Cube-root growth: the sandwich $\sqrt[3]{t} \le \sigma(t) \le \sqrt[3]{t} + \tfrac13$,
  with both constants optimal.
* **§6** — Merging: the anchored subadditivity law and its $n$-fold iterate; the
  order-isomorphism structure.
* **§7** — The AM–GM bridge explaining why $1/27$ is the canonical constant, with the exact
  equality case.
* **§8–§10** — Algorithms, discussion, and future directions.

---

## 2. Concavity above the critical mass

The whole of §2 rests on a single transport principle.

**Lemma 2.1 (concavity of the radical).** The map $x \mapsto x^{1/3}$ is concave, indeed strictly
concave, on $[0, \infty)$.

This is the standard concavity of $x \mapsto x^{p}$ for $0 < p \le 1$ on the nonnegative reals,
here with $p = 1/3$.

**Lemma 2.2 (affine transport).** Let $I \subseteq \mathbb{R}$ be an interval, $g$ concave on
$J$, and $L(t) = \alpha t + \beta$ an affine map with $L(I) \subseteq J$. Then $g \circ L$ is
concave on $I$; if moreover $\lambda > 0$ and $\mu \in \mathbb{R}$, then
$\lambda \,(g\circ L) + \mu$ is concave on $I$. The same holds with "concave" replaced throughout
by "strictly concave" provided $\alpha \neq 0$.

*Proof.* Affine maps commute with convex combinations: $L(ax + by) = a L(x) + b L(y)$ whenever
$a + b = 1$. Substituting into the concavity inequality for $g$ gives the inequality for
$g \circ L$; positive scaling and additive shift preserve inequalities. For strictness note that
$x \ne y$ and $\alpha \neq 0$ imply $L(x) \ne L(y)$. $\square$

**Theorem 2.3 (Main Theorem: concavity on the physical range).** The Lagrange exponent $\sigma$
is concave on $[1/27, \infty)$: for all $x, y \ge 1/27$ and all $a, b \ge 0$ with $a + b = 1$,
$$a\,\sigma(x) + b\,\sigma(y) \;\le\; \sigma(ax + by).$$

*Proof.* Put $u = 27x - 1 \ge 0$ and $v = 27y - 1 \ge 0$. Since $a+b=1$, the affine identity
$$27(ax+by) - 1 \;=\; a\,(27x-1) + b\,(27y-1) \;=\; a u + b v$$
holds, and $au + bv \ge 0$. All three arguments $u$, $v$, $au+bv$ are nonnegative, so the
sign-aware cube root agrees with the real power $x \mapsto x^{1/3}$ at each of them, and Lemma 2.1
gives
$$a\,u^{1/3} + b\,v^{1/3} \;\le\; (au + bv)^{1/3}.$$
Multiplying by $\tfrac13 > 0$, adding $\tfrac13 = \tfrac{a+b}{3}$, and using the definition of
$\sigma$ term by term yields
$$a\,\sigma(x) + b\,\sigma(y) = \frac{a + b + a u^{1/3} + b v^{1/3}}{3}
 \le \frac{1 + (au+bv)^{1/3}}{3} = \sigma(ax+by). \qquad \square$$

**Theorem 2.4 (strict concavity).** $\sigma$ is *strictly* concave on $[1/27, \infty)$: for
$x \neq y$ in $[1/27,\infty)$ and $a, b > 0$ with $a+b=1$,
$$a\,\sigma(x) + b\,\sigma(y) \;<\; \sigma(ax+by).$$

*Proof.* Identical to Theorem 2.3, invoking the *strict* concavity of $x \mapsto x^{1/3}$ on
$[0,\infty)$; the hypothesis $x \ne y$ transports to $27x-1 \ne 27y-1$ because $t \mapsto 27t-1$
is injective. $\square$

**Corollary 2.5 (midpoint form — averaging never hurts).** For $s, t \ge 1/27$,
$$\frac{\sigma(s) + \sigma(t)}{2} \;\le\; \sigma\!\left(\frac{s+t}{2}\right),$$
with strict inequality whenever $s \neq t$.

*Proof.* Take $a = b = 1/2$ in Theorems 2.3 and 2.4. $\square$

**Corollary 2.6 (Jensen form).** Let $T$ be a finite index set, let $w_{i} \ge 0$ for $i \in T$
with $\sum_{i \in T} w_{i} = 1$, and let $m_{i} \ge 1/27$ for each $i$. Then
$$\sum_{i \in T} w_{i}\,\sigma(m_{i}) \;\le\; \sigma\!\left(\sum_{i \in T} w_{i} m_{i}\right).$$

*Proof.* This is the finite Jensen inequality for a concave function on a convex set; the convex
combination $\sum_i w_i m_i$ lies in $[1/27,\infty)$ because that ray is convex and contains every
$m_i$. Formally, induct on $|T|$, splitting off one index and renormalising the remaining
weights. $\square$

Corollary 2.6 is the operational content: *any* weighted blend of admissible masses produces at
least the corresponding blend of growth rates. The physical reading is that mixing mass
distributions is a monotone improvement on the level of exponents, and by Theorem 2.4 a strict
improvement whenever the masses are not all equal.

---

## 3. The mirror regime and sharpness of $1/27$

Below the critical mass everything reverses, and this reversal is what makes the threshold sharp
rather than merely sufficient.

**Theorem 3.1 (strict convexity below the critical mass).** $\sigma$ is strictly convex on
$(-\infty, 1/27]$: for $x \ne y$ in $(-\infty,1/27]$ and $a,b>0$ with $a+b=1$,
$$\sigma(ax + by) \;<\; a\,\sigma(x) + b\,\sigma(y).$$

*Proof.* Now put $u = 1 - 27x \ge 0$ and $v = 1 - 27y \ge 0$, and note $u \ne v$. The affine
identity becomes
$$27(ax+by) - 1 \;=\; -\bigl(a u + b v\bigr), \qquad au+bv \ge 0 .$$
By oddness of the real cube root, for $w \ge 0$ we have $\sqrt[3]{-w} = -w^{1/3}$, hence
$$\sqrt[3]{27x - 1} = -u^{1/3},\qquad \sqrt[3]{27y-1} = -v^{1/3},\qquad
\sqrt[3]{27(ax+by)-1} = -(au+bv)^{1/3}.$$
Strict concavity of $x \mapsto x^{1/3}$ on $[0,\infty)$ gives
$a u^{1/3} + b v^{1/3} < (au+bv)^{1/3}$; negating flips the inequality,
$$-(au+bv)^{1/3} \;<\; -a u^{1/3} - b v^{1/3},$$
and dividing by $3$ after adding $1 = a + b$ yields
$\sigma(ax+by) < a\sigma(x) + b\sigma(y)$. $\square$

The proofs of Theorems 2.4 and 3.1 are the *same* proof run through two different affine
substitutions: $t \mapsto 27t-1$ (increasing, preserves the inequality) and $t \mapsto 1-27t$
(decreasing, whose composition with negation flips it). This is why the two regimes are exact
mirror images and why the changeover is a single point.

**Theorem 3.2 (sharpness on the right).** For every $a < 1/27$, $\sigma$ is *not* concave on
$[a, \infty)$.

*Proof.* Suppose it were. Both $a$ and $1/27$ lie in $[a,\infty)$, so midpoint concavity gives
$$\tfrac12 \sigma(a) + \tfrac12 \sigma\!\left(\tfrac{1}{27}\right) \;\le\;
 \sigma\!\left(\tfrac{a + 1/27}{2}\right).$$
But $a$ and $1/27$ also both lie in $(-\infty,1/27]$ and are distinct, so Theorem 3.1 applied to
the same pair with weights $\tfrac12,\tfrac12$ gives the strict reverse
$$\sigma\!\left(\tfrac{a + 1/27}{2}\right) \;<\; \tfrac12 \sigma(a) + \tfrac12
 \sigma\!\left(\tfrac{1}{27}\right).$$
The two are contradictory. $\square$

**Theorem 3.3 (sharpness on the left).** For every $b > 1/27$, $\sigma$ is *not* convex on
$(-\infty, b]$.

*Proof.* Mirror argument: $1/27$ and $b$ lie in $(-\infty,b]$ and also in $[1/27,\infty)$ and are
distinct, so a convexity hypothesis on $(-\infty,b]$ collides with the strict concavity of
Theorem 2.4 applied to the midpoint of the same pair. $\square$

**Corollary 3.4 (exact characterisation of the curvature rays).** For every $c \in \mathbb{R}$:
$$\sigma \text{ is concave on } [c,\infty) \iff c \ge \tfrac{1}{27},
\qquad\qquad
\sigma \text{ is convex on } (-\infty, c] \iff c \le \tfrac{1}{27}.$$

*Proof.* ($\Rightarrow$) Theorems 3.2 and 3.3. ($\Leftarrow$) Concavity and convexity are
inherited by convex subsets: $[c,\infty) \subseteq [1/27,\infty)$ when $c \ge 1/27$, and
$(-\infty,c] \subseteq (-\infty,1/27]$ when $c \le 1/27$. $\square$

Corollary 3.4 is an *adversarial* check on the main theorem: it rules out the possibility that the
hypothesis $t \ge 1/27$ is a slack convenience hiding a globally concave function. The curvature
of $\sigma$ genuinely changes sign, once, exactly at $t = 1/27$, which is the image under $h$ of
the degenerate critical point $y = 1/3$.

---

## 4. The analytic shadow: derivative and its monotonicity

Concavity was proved without calculus, which matters because the derivative does not exist at the
endpoint. On the open ray it does.

**Theorem 4.1 (differentiability above the critical mass).** For $t > 1/27$, $\sigma$ is
differentiable at $t$ with
$$\sigma'(t) \;=\; 3\,(27t - 1)^{-2/3}.$$

*Proof.* On the open set $\{u : 27u - 1 > 0\}$, which is a neighbourhood of $t$, the sign-aware
cube root coincides with $u \mapsto (27u-1)^{1/3}$, so $\sigma$ coincides there with
$u \mapsto \bigl(1 + (27u-1)^{1/3}\bigr)/3$. The chain rule for real powers applied to the
inner affine map $u \mapsto 27u - 1$ (with nonvanishing argument) gives derivative
$\tfrac13 \cdot 27 \cdot (27t-1)^{1/3 - 1}$, and dividing by $3$ and simplifying the exponent
$\tfrac13 - 1 = -\tfrac23$ yields $3(27t-1)^{-2/3}$. Since a function agreeing with $\sigma$ on a
neighbourhood of $t$ has the same derivative there, the claim follows. $\square$

**Theorem 4.2 (antitone derivative).** The map $t \mapsto 3(27t-1)^{-2/3}$ is antitone
(nonincreasing) on $(1/27, \infty)$.

*Proof.* For $1/27 < x \le y$ we have $0 < 27x - 1 \le 27y - 1$, and $w \mapsto w^{-2/3}$ is
nonincreasing on $(0,\infty)$ because the exponent is negative. $\square$

Theorems 4.1 and 4.2 recover concavity on the open ray in its classical differential form and
locate the singular behaviour precisely: $\sigma'(t) \to \infty$ as $t \downarrow 1/27$ (a vertical
tangent, the reciprocal of the vanishing $h'(1/3) = 0$) and $\sigma'(t) \to 0$ as $t \to \infty$.
The inverse function theorem is unavailable at the critical point, which is exactly why the
substitution-based proof of §2 — valid on the closed ray including the endpoint — is the correct
argument.

---

## 5. Cube-root growth: the sandwich

**Lemma 5.1 (scaling of the radical).** $\sqrt[3]{27t} = 3\sqrt[3]{t}$ for all real $t$.

*Proof.* Both sides cube to $27t$, and the real cube root is unique. $\square$

**Theorem 5.2 (upper bound, valid on all of $\mathbb{R}$).** For every $t \in \mathbb{R}$,
$$\sigma(t) \;\le\; \sqrt[3]{t} + \tfrac13 .$$

*Proof.* Monotonicity of the cube root gives $\sqrt[3]{27t-1} \le \sqrt[3]{27t} = 3\sqrt[3]{t}$,
so $\sigma(t) = \bigl(1 + \sqrt[3]{27t-1}\bigr)/3 \le \tfrac13 + \sqrt[3]{t}$. $\square$

**Theorem 5.3 (lower bound on the physical range).** For $t \ge 1/27$,
$$\sqrt[3]{t} \;\le\; \sigma(t).$$

*Proof.* Let $A = \sqrt[3]{27t-1} \ge 0$, so $A^{3} = 27t-1$ and
$(A+1)^{3} = 27t + 3A^{2} + 3A \ge 27t = \bigl(3\sqrt[3]{t}\bigr)^{3}$, using $A \ge 0$. Since
cubing is strictly increasing, $3\sqrt[3]{t} \le A + 1$, i.e. $\sqrt[3]{t} \le (1+A)/3 =
\sigma(t)$. $\square$

**Corollary 5.4 (the cube-root sandwich).** For $t \ge 1/27$,
$$\sqrt[3]{t} \;\le\; \sigma(t) \;\le\; \sqrt[3]{t} + \tfrac13 .$$
The growth rate is a cube root up to an additive correction confined to $[0, 1/3]$.

**Optimality of both constants.** At $t = 1/27$ the correction vanishes exactly:
$\sigma(1/27) = 1/3 = \sqrt[3]{1/27}$, so the lower bound is attained. As $t \to \infty$,
$$\sigma(t) - \sqrt[3]{t} = \frac{1 + \sqrt[3]{27t-1} - 3\sqrt[3]{t}}{3} \longrightarrow \frac13,$$
because $\sqrt[3]{27t-1} - \sqrt[3]{27t} \to 0$ (the increments of the cube root vanish at
infinity). Hence the correction sweeps the full interval $[0,1/3)$ and the constant $1/3$ in
Theorem 5.2 cannot be lowered.

---

## 6. Merging masses, and the order structure

### 6.1 Anchored subadditivity

**Theorem 6.1 (merging law).** For $s, t \ge 1/27$,
$$\sigma\!\left(s + t - \tfrac{1}{27}\right) + \tfrac13 \;\le\; \sigma(s) + \sigma(t).$$

*Proof.* Write $M = s + t - \tfrac1{27}$ (which is $\ge 1/27$) and $C = \tfrac1{27}$, and set
$D = s + t - \tfrac{2}{27} \ge 0$.

If $D = 0$ then $s = t = 1/27$, both sides equal $2/3$ (using $\sigma(1/27)=1/3$), and the claim
holds with equality.

If $D > 0$, put
$$\alpha = \frac{s - 1/27}{D}, \qquad \beta = \frac{t - 1/27}{D},$$
so $\alpha, \beta \ge 0$ and $\alpha + \beta = 1$. A direct computation gives the two convex
representations
$$\alpha M + \beta C = s, \qquad \beta M + \alpha C = t .$$
Applying Theorem 2.3 to each (both $M$ and $C$ lie in $[1/27,\infty)$) yields
$$\alpha\,\sigma(M) + \beta\,\tfrac13 \le \sigma(s), \qquad
  \beta\,\sigma(M) + \alpha\,\tfrac13 \le \sigma(t).$$
Adding and using $\alpha + \beta = 1$ collapses the left side to $\sigma(M) + \tfrac13$. $\square$

The interpretation is an accounting one. Running two systems separately costs
$\sigma(s) + \sigma(t)$; merging them into one of combined mass, and paying the critical overhead
$1/27$ exactly once instead of twice, costs at most as much. The anchor point $(1/27, 1/3)$ is the
inflection, so the inequality is the tightest anchored form available.

### 6.2 The $n$-fold law

**Lemma 6.2 (mass floor).** If $m_{i} \ge 1/27$ for all $i$ in a finite set $T$, then
$\sum_{i \in T} m_{i} \ge |T|/27$.

**Theorem 6.3 ($n$-fold merging law).** Let $T$ be a finite nonempty index set and
$m_{i} \ge 1/27$ for $i \in T$, with $n = |T|$. Then
$$\sigma\!\left(\sum_{i \in T} m_{i} - \frac{n-1}{27}\right) + \frac{n-1}{3}
 \;\le\; \sum_{i \in T} \sigma(m_{i}).$$

*Proof.* Induction on $n$. For $n=1$ both sides are $\sigma(m_{i})$. For the step, adjoin a new
index $a$ to a nonempty set $S$ with $|S| = k$. By Lemma 6.2 the merged residual mass
$R = \sum_{i \in S} m_{i} - \tfrac{k-1}{27}$ satisfies $R \ge 1/27$, so Theorem 6.1 applies to the
pair $(m_{a}, R)$:
$$\sigma\!\left(m_{a} + R - \tfrac1{27}\right) + \tfrac13 \le \sigma(m_{a}) + \sigma(R).$$
The argument on the left equals $\sum_{i \in S \cup \{a\}} m_{i} - \tfrac{k}{27}$, which is the
required merged mass for $k+1$ indices. Combining with the induction hypothesis
$\sigma(R) + \tfrac{k-1}{3} \le \sum_{i \in S}\sigma(m_{i})$ and adding gives the claim. $\square$

The critical overhead is paid exactly once regardless of how many components are merged; the
"savings" term $\tfrac{n-1}{3}$ grows linearly in the number of components.

### 6.3 Order isomorphism

**Theorem 6.4.** $\sigma$ is an order isomorphism of $\mathbb{R}$ onto itself, with inverse $h$.
Consequently $\sigma$ is continuous and surjective: every growth rate is realised by exactly one
mass.

*Proof.* Proposition 1.3 makes $\sigma$ and $h$ mutually inverse, and $\sigma$ is strictly
increasing, so $\sigma(x) \le \sigma(y) \iff x \le y$. An order isomorphism of a linear order
carrying the order topology is a homeomorphism, hence $\sigma$ is continuous; bijectivity gives
surjectivity. $\square$

The global single-valuedness is the payoff of the degeneracy: a generic cubic has a three-valued
real inverse on an interval of heights, whereas the coalescence of the critical points shrinks
that interval to the single point $y = 1/3$ and leaves a genuine function behind.

---

## 7. Why $1/27$? The AM–GM bridge

The constant $1/27$ has so far been algebraic: $1/27 = h(1/3)$. It has a second, independent
arithmetic identity.

**Theorem 7.1 (three-variable AM–GM).** If $p, q, r \ge 0$ and $p + q + r = 1$, then
$$pqr \;\le\; \frac{1}{27}.$$

*Proof.* This is AM–GM: $\sqrt[3]{pqr} \le (p+q+r)/3 = 1/3$. Equivalently, it follows from the
nonnegativity of the symmetric squares $(p-q)^2, (q-r)^2, (p-r)^2$ together with the nonnegativity
of the pairwise products, which is precisely the form used in the derivation below. $\square$

**Theorem 7.2 (equality case).** Under the hypotheses of Theorem 7.1, $pqr = 1/27$ if and only if
$p = q = r = 1/3$.

*Proof sketch.* Sufficiency is a computation. For necessity, homogenising and using the
constraint, equality in AM–GM for nonnegative reals forces all three to be equal, hence each is
$1/3$ by the sum constraint. Quantitatively, equality forces
$(3p-1)^2 = (3q-1)^2 = (3r-1)^2 = 0$, which one obtains by combining the squared-difference
certificates with the constraint. $\square$

**Corollary 7.3 (mass bridge).** For a three-point probability distribution $(p,q,r)$,
$$\sigma(pqr) \;\le\; \sigma\!\left(\tfrac{1}{27}\right) \;=\; \tfrac13 ,$$
with equality if and only if $p = q = r = 1/3$; every non-uniform distribution satisfies the
strict inequality $\sigma(pqr) < 1/3$.

*Proof.* Monotonicity of $\sigma$ applied to Theorem 7.1, together with the injectivity of
$\sigma$ and Theorem 7.2 for the equality case. $\square$

Thus $1/27 = (1/3)^{3}$ is simultaneously:

1. the value $h(1/3)$ at the degenerate critical point of the cubic;
2. the exact sharp threshold separating the convex and concave regimes of $\sigma$
   (Corollary 3.4);
3. the maximal product mass of a three-point probability distribution, attained only at the
   uniform distribution (Theorems 7.1–7.2).

The coincidence of (1) and (3) is not accidental: both are $(1/3)^3$, one as the image of the
critical point of a cubic normalised so that the critical point sits at $1/3$, the other as the
AM–GM extremum for three summands each equal to $1/3$. The coincidence with (2) is the content of
this paper. It shows that the guard $t \ge 1/27$ in the main theorem is not an arbitrary
restriction but the statement that the mechanism is fed at least as much mass as the most balanced
three-slot distribution can supply — and by Corollary 7.3 the boundary is attained by exactly one
distribution, so the guard is tight rather than slack.

---

## 8. Algorithms

We record the three computational primitives implicit in the development. Throughout, arithmetic
is on real (floating-point) numbers; all three run in $O(1)$ time and space per evaluation, up to
the cost of one cube-root extraction.

### 8.1 Sign-aware cube root and exponent evaluation

Evaluating $\sigma$ naively as `(1 + (27*t-1)**(1/3))/3` fails for $t < 1/27$, where the
floating-point power of a negative base is not a real number. The correct primitive is the odd
extension.

```
function CBRT(x):
    if x >= 0: return exp(log(x)/3)      # or x**(1/3), with CBRT(0)=0
    else:      return -CBRT(-x)

function SIGMA(t):
    return (1 + CBRT(27*t - 1)) / 3
```

Correctness: the returned value $u$ satisfies $u^{3} = x$ in exact arithmetic, and by
Proposition 1.3 the returned $\sigma(t)$ is the unique real root of $h(y) = t$.

### 8.2 Curvature-regime classifier

Given a finite set of masses, decide whether concavity (mixing helps), convexity (mixing hurts),
or neither applies, and certify the verdict with an explicit midpoint gap
$$G(s,t) = \sigma\!\left(\tfrac{s+t}{2}\right) - \tfrac{\sigma(s)+\sigma(t)}{2}.$$
Theorem 2.4 says $G > 0$ for distinct $s,t \ge 1/27$; Theorem 3.1 says $G < 0$ for distinct
$s,t \le 1/27$; and for a straddling pair the sign is genuinely indeterminate, which is the
computational face of the sharpness result.

```
function CLASSIFY(masses):
    if min(masses) >= 1/27: regime := "concave  (mixing helps)"
    elif max(masses) <= 1/27: regime := "convex   (mixing hurts)"
    else: regime := "straddles the critical mass 1/27"
    return regime, [ (s,t, SIGMA((s+t)/2) - (SIGMA(s)+SIGMA(t))/2)
                     for all pairs s<t in masses ]
```

### 8.3 Greedy merge accountant

Theorem 6.3 bounds the total cost $\sum_i \sigma(m_i)$ of running $n$ systems separately by the
cost of the single merged system plus the overhead credit $\tfrac{n-1}{3}$. The algorithm below
evaluates both sides and reports the slack, and also verifies the pairwise law en route by
performing the merge one component at a time.

```
function MERGE_ACCOUNT(m[1..n]):            # requires m[i] >= 1/27
    separate := sum_i SIGMA(m[i])
    merged   := sum_i m[i] - (n-1)/27
    bound    := SIGMA(merged) + (n-1)/3
    assert bound <= separate + tolerance     # Theorem 6.3
    return separate, merged, bound, separate - bound
```

Complexity: $O(n)$ evaluations of $\sigma$, i.e. $O(n)$ cube roots.

---

## 9. Discussion

**What the degeneracy buys.** Nearly every statement above is downstream of one identity,
$h'(y) = 3(y-\tfrac13)^{2}$. It forces $h$ to be an affine copy of $u \mapsto u^{3}$, hence
$\sigma$ an affine copy of $x \mapsto x^{1/3}$; the curvature question then reduces to the
curvature of the radical, and the location of the inflection reduces to the location of the
critical point. In particular the number $1/27$ is not tuned: it is $h$ evaluated at the unique
point where $h'$ vanishes.

**Why not just differentiate twice?** On $(1/27,\infty)$ one can: $\sigma''(t) = -54(27t-1)^{-5/3}
< 0$, matching Theorems 4.1–4.2. But the interesting statement is concavity on the *closed* ray
$[1/27,\infty)$, and at the endpoint $\sigma$ is not differentiable — the tangent is vertical,
because $h'(1/3) = 0$. The substitution proof of §2 handles the endpoint uniformly, and the same
substitution with a sign flip delivers the convex mirror, which is what makes the threshold
provably sharp rather than merely sufficient.

**Sharpness as an adversarial test.** A theorem of the form "concave on $[c,\infty)$" is only as
informative as its converse. Corollary 3.4 supplies the converse in both directions, so the result
cannot be a vacuous consequence of global concavity, and $1/27$ cannot be weakened by any amount.

**Concavity as a tool.** Sections 5 and 6 are the payoff: the cube-root sandwich locates $\sigma$
within an additive $1/3$ of a pure radical uniformly on the physical range, and the merging laws
convert curvature into an economic statement about combining systems. Both are the sort of
consequence that concavity exists to produce; neither is visible from the closed formula without
the curvature input.

---

## 10. Future directions

**Direction 1 — Degenerate-critical-point rigidity in arbitrary degree.** For $n \ge 2$ let
$h_{n}$ be the monic degree-$n$ polynomial with $h_{n}'(y) = n\,(y - 1/n)^{n-1}$ and
$h_{n}(0) = 0$, and let $\sigma_{n} = h_{n}^{-1}$. We conjecture that $\sigma_{n}$ is concave on
$[c,\infty)$ if and only if $c \ge h_{n}(1/n)$; that it is convex on $(-\infty, h_{n}(1/n)]$ when
$n$ is odd; and that the gap $\sigma_{n}(t) - t^{1/n}$ increases from $0$ to $1/n$. The mechanism
is that a perfect-power derivative forces the inverse to be a pure radical after an affine change
of variables, so all curvature information collapses to the single number $h_{n}(1/n)$; the case
$n = 3$ is precisely the present paper. The natural falsifier is even $n$, where $h_{n}$ is not
injective on $\mathbb{R}$ and the convex mirror must fail; if the concave half also fails for some
even $n$, the conjecture must be guarded to odd degrees.

**Direction 2 — The curvature threshold as a coefficient locus.** For a general real cubic
$p(y) = y^{3} + ay^{2} + by + c$ possessing an increasing inverse branch, we conjecture that the
branch is concave exactly on $[\,p(y^{*}), \infty)$, where $y^{*} = -a/3$ is the inflection of
$p$, and that the endpoint equals $c - ab/3 + 2a^{3}/27$ — the constant term of the depressed
cubic. The curvature threshold would then be a polynomial function of the coefficients, vanishing
on the locus $4(b - a^{2}/3)^{3} + 27\,p(y^{*})^{2} = 0$ where $p$ acquires a triple root. The
insight is that concavity of an inverse is governed entirely by the sign of the second derivative
of the original map, so the threshold is the *image of the inflection*, converting an analytic
question into an algebraic one about coefficient loci. Mechanically, one replaces the single
identity $h(y) = ((3y-1)^{3}+1)/27$ with the general Tschirnhaus shift.

**Direction 3 — Simplex transport of the mass bridge.** Let $\Delta_{k}$ be the $k$-simplex and
$\Pi(p) = \prod_{i} p_{i}$. We conjecture that $\sigma_{k}(\Pi(p)) \le 1/k$ for every
$p \in \Delta_{k}$, with equality iff $p$ is uniform, and that $p \mapsto \sigma_{k}(\Pi(p))$ is a
strictly Schur-concave functional whose level sets are the majorisation classes on $\Delta_{k}$.
The insight is that $1/27 = (1/3)^{3}$ is not a constant but the AM–GM extremum of the product
functional on the simplex, so the critical mass should deform with $k$ exactly as the extremum
does.

**Further questions.** (i) Quantitative concavity: is there a modulus $\kappa(t) > 0$ with
$\sigma(\tfrac{s+t}{2}) - \tfrac{\sigma(s)+\sigma(t)}{2} \ge \kappa\,(s-t)^{2}$ locally uniformly
on compacta of $(1/27,\infty)$? The exact second derivative $-54(27t-1)^{-5/3}$ suggests
$\kappa(t) \asymp (27t-1)^{-5/3}$. (ii) Is the merging law of Theorem 6.1 extremal, i.e. is the
constant $1/3$ on the left the largest possible? (iii) Does the order isomorphism $\sigma$ conjugate
any natural dynamical system on the mass line to a tractable one on the exponent line?

---

## 11. Conclusion

The Lagrange exponent $\sigma(t) = \bigl(1 + \sqrt[3]{27t-1}\bigr)/3$, the global inverse of the
degenerate cubic $h(y) = y^{3} - y^{2} + y/3$, is strictly concave exactly on the ray
$[1/27, \infty)$ and strictly convex exactly on $(-\infty, 1/27]$, with the single inflection at
the critical mass $1/27 = h(1/3)$ sitting over the coalesced critical point of the cubic. Above
that mass, averaging distributions never decreases the growth rate, strictly so whenever the
masses differ, and the same holds for arbitrary weighted averages. The threshold is sharp in both
directions. Downstream, concavity delivers a cube-root sandwich with optimal constants and a
family of merging laws in which the critical overhead is paid exactly once. Finally, $1/27$ is
canonical rather than chosen: it is the AM–GM extremal product mass of a three-point probability
distribution, attained only by the uniform one.
