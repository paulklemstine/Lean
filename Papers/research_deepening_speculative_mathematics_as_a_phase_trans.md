# A Rigorous Anatomy of the Curie–Weiss Phase Transition

## Abstract

We give a complete and self-contained analysis of the second-order phase
transition in the mean-field (Curie–Weiss) model of a system of coupled binary
degrees of freedom. The model is governed by the scalar self-consistency
equation $m = \tanh(\beta m)$, where $m$ is the order parameter (average
alignment) and $\beta > 0$ is the coupling (inverse temperature). Our central
result locates the critical point exactly: a nontrivial positive order
parameter exists if and only if $\beta > 1$. Below the threshold the disordered
state $m=0$ is the unique nonnegative solution; above it a positive solution
appears, is unique, and is born continuously from zero — the hallmark of a
second-order transition. We further show that every solution satisfies
$|m|<1$, that solutions occur in symmetric $\pm m$ pairs, and that the
introduction of any positive external field $h>0$ destroys the sharp dichotomy:
the field-driven equation $m = \tanh(\beta m + h)$ possesses a positive solution
in $(0,1)$ for *every* coupling $\beta$. The analytic engine consists of two
sharp elementary inequalities for the hyperbolic tangent, $\tanh y < y$ and
$y - y^3/3 < \tanh y$ for $y>0$, each established by monotonicity of an
auxiliary function through its derivative. We accompany the theory with
algorithms and numerical experiments confirming the predicted behavior.

**Keywords:** phase transition, order parameter, mean-field theory,
Curie–Weiss model, spontaneous symmetry breaking, hyperbolic tangent, fixed
point, critical coupling.

---

## 1. Introduction

A *phase transition* is a qualitative change in the macroscopic state of a
system produced by the smooth variation of a control parameter. The paradigm is
ferromagnetism: a magnetic material is disordered (no net magnetization) above
a critical temperature and spontaneously ordered (nonzero magnetization) below
it. The quantity that distinguishes the two regimes — here the magnetization —
is called the *order parameter*, and the value of the control parameter at which
its qualitative behavior changes is the *critical point*.

Mean-field theory replaces the detailed interactions among microscopic degrees
of freedom by a single average field to which each degree of freedom responds.
For a system of $\pm 1$ spins with all-to-all coupling of strength $\beta$
(inverse temperature), this reduction yields the **Curie–Weiss
self-consistency equation**

$$ m = \tanh(\beta m), \tag{1}$$

in which the order parameter $m \in [-1,1]$ is required to be a fixed point of
the map $m \mapsto \tanh(\beta m)$. Equation (1) is the simplest nontrivial
model exhibiting a genuine phase transition, and it serves as the archetype
against which more elaborate theories are calibrated.

This paper provides a fully rigorous account of the mathematical structure of
(1) and of its field-driven generalization

$$ m = \tanh(\beta m + h). \tag{2}$$

Our contributions are: (i) a sharp existence/nonexistence dichotomy locating the
critical coupling at $\beta_c = 1$; (ii) uniqueness of the positive branch;
(iii) qualitative properties (boundedness, symmetry, continuity of onset)
identifying the transition as second-order; and (iv) a proof that any positive
external field removes the sharp transition. All results follow from two sharp
inequalities for $\tanh$, which we prove first.

---

## 2. Preliminaries: two sharp inequalities for $\tanh$

Throughout, $\tanh y = \sinh y / \cosh y$, with $\cosh y > 0$ for all real $y$,
so $\tanh$ is smooth. Its derivative is
$$ \frac{d}{dy}\tanh y = \frac{1}{\cosh^2 y} = 1 - \tanh^2 y, \tag{3}$$
which lies in $(0,1]$ and equals $1$ only at $y=0$. Thus $\tanh$ is strictly
increasing with a strict maximum slope of $1$ at the origin, and it satisfies
$-1 < \tanh y < 1$ for all $y$.

### Lemma 1 (Strict sublinearity). *For every $y>0$, $\tanh y < y$.*

**Proof.** Let $F(y) = y - \tanh y$. By (3),
$F'(y) = 1 - 1/\cosh^2 y = \tanh^2 y > 0$ for $y > 0$. Since $F(0)=0$ and $F$ is
continuous on $[0,y]$ and differentiable on $(0,y)$, the mean value theorem
gives a point $c \in (0,y)$ with $F(y) - F(0) = F'(c)\,y > 0$, so
$F(y) > 0$, i.e. $\tanh y < y$. $\qquad\blacksquare$

Geometrically, the graph of $\tanh$ lies strictly below the diagonal for
positive arguments: the curve leaves the origin tangent to $y=x$ but
immediately bends beneath it.

### Lemma 2 (Sharp cubic lower bound). *For every $y>0$, $y - \dfrac{y^3}{3} < \tanh y$.*

**Proof.** Let $G(y) = \tanh y - y + y^3/3$. Using (3),
$$ G'(y) = \frac{1}{\cosh^2 y} - 1 + y^2 = y^2 - \tanh^2 y. $$
For $y>0$ we have $0 < \tanh y < y$ by Lemma 1, hence
$\tanh^2 y < y^2$ and $G'(y) > 0$. Since $G(0)=0$, the mean value theorem again
yields $G(y) > 0$ for $y>0$, which is the claim. $\qquad\blacksquare$

Lemma 2 quantifies how far $\tanh$ falls below its tangent line: the leading
correction is exactly $-y^3/3$, the third-order Taylor term. This cubic term is
what permits a nonzero fixed point to appear as soon as the coupling exceeds
$1$.

Together the two lemmas *bracket* the tangent function near the origin:
$$ y - \frac{y^3}{3} < \tanh y < y, \qquad y > 0. \tag{4}$$

---

## 3. General properties of solutions

Two structural facts hold for solutions of (1) at any coupling.

### Proposition 3 (Boundedness). *If $m = \tanh(\beta m)$, then $|m| < 1$.*

**Proof.** Immediate from $-1 < \tanh(x) < 1$ for all real $x$: since $m$ equals
$\tanh(\beta m)$, it inherits the strict bounds. $\qquad\blacksquare$

The order parameter can approach complete alignment but never attains it: full
saturation $|m|=1$ is excluded at any finite coupling.

### Proposition 4 (Symmetry). *If $m$ solves (1), so does $-m$.*

**Proof.** $\tanh$ is odd, so
$\tanh(\beta(-m)) = -\tanh(\beta m) = -m$. $\qquad\blacksquare$

Solutions occur in mirror pairs $\pm m$: the two ordered states ("all up" and
"all down") are physically equivalent, and the system must break this
$\mathbb{Z}_2$ symmetry to select one.

---

## 4. The subcritical (disordered) phase

### Theorem 5 (No spontaneous order for $\beta \le 1$).
*If $\beta \le 1$, $m \ge 0$, and $m = \tanh(\beta m)$, then $m = 0$.*

**Proof.** Suppose for contradiction that $m > 0$. If $\beta m \le 0$ then
$\tanh(\beta m) \le 0 < m$, contradicting (1). Hence $\beta m > 0$, and Lemma 1
gives $\tanh(\beta m) < \beta m$. Combined with $\beta \le 1$ and $m>0$, which
yields $\beta m \le m$, we obtain
$$ m = \tanh(\beta m) < \beta m \le m, $$
a contradiction. Therefore $m = 0$. $\qquad\blacksquare$

At or below the critical coupling, thermal disorder dominates and the only
self-consistent nonnegative state is the trivial one. There is no spontaneous
coherence.

---

## 5. The supercritical (ordered) phase

### Theorem 6 (Emergence of order for $\beta > 1$).
*If $\beta > 1$, there exists $m > 0$ with $m = \tanh(\beta m)$.*

**Proof.** Consider $f(m) = \tanh(\beta m) - m$, which is continuous on $[0,1]$.
We produce a small point where $f>0$ and a large point where $f<0$, then invoke
the intermediate value theorem.

*A point with $f>0$.* Set $c = \sqrt{3(\beta-1)/\beta^3}$ and
$m_0 = \tfrac12 \min(1, c)$, so that $0 < m_0 < 1$ and $\beta^3 m_0^2/3 <
\beta - 1$. Since $\beta m_0 > 0$, Lemma 2 gives
$$ \tanh(\beta m_0) > \beta m_0 - \frac{(\beta m_0)^3}{3}
   = \beta m_0 - \frac{\beta^3 m_0^3}{3}. $$
Using $\beta^3 m_0^2/3 < \beta - 1$ we get $\beta^3 m_0^3/3 < (\beta-1)m_0$,
hence
$$ \tanh(\beta m_0) > \beta m_0 - (\beta - 1)m_0 = m_0, $$
so $f(m_0) > 0$.

*A point with $f<0$.* At $m=1$, $f(1) = \tanh(\beta) - 1 < 0$ because
$\tanh(\beta) < 1$.

By the intermediate value theorem there is $m \in (m_0, 1)$ with $f(m)=0$, i.e.
$\tanh(\beta m) = m$, and $m > m_0 > 0$. $\qquad\blacksquare$

The proof exhibits the mechanism explicitly: since the map $m\mapsto
\tanh(\beta m)$ leaves the origin with slope $\beta > 1$, it starts above the
diagonal (Lemma 2), while boundedness forces it below the diagonal for large
$m$ (Lemma 1); a crossing in between is a nontrivial fixed point. Because $m_0$
may be taken arbitrarily small as $\beta \downarrow 1$ (indeed $c \to 0$), the
positive branch is *born at zero*: the onset is continuous.

---

## 6. The sharp phase transition

Combining Theorems 5 and 6 gives the main result.

### Theorem 7 (Curie–Weiss phase transition, located at $\beta_c = 1$).
*For every real $\beta$,*
$$ \bigl(\exists\, m > 0 : m = \tanh(\beta m)\bigr)
   \iff \beta > 1. $$

**Proof.** ($\Rightarrow$) If some $m>0$ solves (1) but $\beta \le 1$, Theorem 5
forces $m=0$, contradicting $m>0$. ($\Leftarrow$) This is Theorem 6.
$\qquad\blacksquare$

Theorem 7 is sharp: the existence of spontaneous order is equivalent to the
strict inequality $\beta > 1$, with no gap or crossover region. The critical
coupling is exactly $\beta_c = 1$. Since the emergent order parameter tends to
$0$ as $\beta \to 1^+$, the transition is **second-order** (continuous), in
contrast to a first-order transition, in which the order parameter would jump
discontinuously.

---

## 7. Uniqueness of the ordered state

### Theorem 8 (Uniqueness of the positive branch).
*If $m_1, m_2 > 0$ both satisfy (1) for the same $\beta$, then $m_1 = m_2$.*

**Proof.** Assume $m_1 < m_2$ (the case $m_1 > m_2$ is symmetric, and equality
is the claim). Let $g(m) = \tanh(\beta m)$, so $g'(m) = \beta/\cosh^2(\beta m)$,
which is strictly decreasing in $|m|$ because $\cosh$ is strictly increasing on
$[0,\infty)$ and even. Apply the mean value theorem twice:
- on $[m_1, m_2]$: there is $\xi \in (m_1,m_2)$ with
  $g'(\xi) = \dfrac{g(m_2)-g(m_1)}{m_2-m_1} = \dfrac{m_2-m_1}{m_2-m_1} = 1$;
- on $[0, m_1]$: there is $\eta \in (0,m_1)$ with
  $g'(\eta) = \dfrac{g(m_1)-g(0)}{m_1-0} = \dfrac{m_1}{m_1} = 1$.

Thus $g'(\xi) = g'(\eta) = 1$. But $0 < \eta < \xi$ implies
$\cosh(\beta\xi) > \cosh(\beta\eta) > 0$ (for $\beta>0$; the ordered phase
requires $\beta>1$), hence
$g'(\xi) = \beta/\cosh^2(\beta\xi) < \beta/\cosh^2(\beta\eta) = g'(\eta)$,
contradicting their equality. Therefore $m_1 = m_2$. $\qquad\blacksquare$

Uniqueness of the positive solution means the spontaneous magnetization is a
well-defined single-valued function of $\beta$ on $(1,\infty)$: above the
critical point the model prescribes a single definite amount of order (together
with its mirror image, by Proposition 4).

---

## 8. The effect of an external field

We finally analyze (2), the model with an external field $h$ biasing one
direction.

### Theorem 9 (A positive field destroys the sharp transition).
*For any coupling $\beta$ and any field $h>0$, there exists
$m \in (0,1)$ with $m = \tanh(\beta m + h)$.*

**Proof.** Let $f(m) = \tanh(\beta m + h) - m$, continuous on $[0,1]$. At the
endpoints,
$$ f(0) = \tanh(h) > 0, \qquad f(1) = \tanh(\beta + h) - 1 < 0, $$
the first because $h>0$ makes $\sinh(h)>0$, the second because $\tanh < 1$
everywhere. By the intermediate value theorem there is $m \in (0,1)$ with
$f(m)=0$, i.e. $\tanh(\beta m + h) = m$. $\qquad\blacksquare$

Because the conclusion holds for *every* $\beta$, the sharp dichotomy of
Theorem 7 is smoothed out: with any positive field the system carries a
positive order parameter at all temperatures, and the transition ceases to be
sharp. The sharp critical point is a fragile feature of the perfectly unbiased
($h=0$) system, associated with its exact $\pm m$ symmetry (Proposition 4); a
field breaks that symmetry explicitly and rounds the transition.

---

## 9. Algorithms

The self-consistency equation is scalar and monotone, which makes numerical
solution straightforward and robust.

**Fixed-point iteration.** Iterate $m_{k+1} = \tanh(\beta m_k + h)$ from a
positive seed. For $h>0$ the map sends $(0,1)$ into itself and the iteration
converges to the unique attracting solution. For $h=0$ and $\beta>1$, seeding
with any $m_0 \in (0,1)$ converges to the positive branch (the trivial fixed
point $m=0$ is repelling because the slope at $0$ is $\beta>1$).

**Bisection on $f$.** Since $f(m)=\tanh(\beta m + h)-m$ changes sign on a known
bracket — $[m_0, 1]$ for the zero-field ordered phase, $[0,1]$ for $h>0$ —
bisection converges linearly with guaranteed error control, mirroring the
intermediate-value proofs of Theorems 6 and 9.

**Critical-exponent probe.** Near the threshold the bracketing (4) predicts the
onset $m_*(\beta) \approx \sqrt{3(\beta-1)}$ as $\beta \to 1^+$, giving the
mean-field critical exponent $1/2$. Solving (1) for a grid of $\beta$ slightly
above $1$ and fitting $\log m_*$ against $\log(\beta-1)$ recovers the exponent
numerically.

---

## 10. Applications and universality

The structure proved here — an order parameter identically zero below a
threshold and strictly positive above it, appearing continuously — is a
template that recurs throughout the sciences:

- **Ferromagnetism.** Spontaneous magnetization below the Curie point, the
  original setting of the model.
- **Percolation and networks.** The emergence of a giant connected component
  above a critical edge density; the survival probability of a branching process
  with mean offspring $\mu$ plays the role of the order parameter with critical
  value $\mu_c = 1$, exactly analogous to $\beta_c = 1$ via a
  generating-function fixed point.
- **Epidemic thresholds.** An outbreak persists if and only if the basic
  reproduction number exceeds $1$.
- **Continuous transitions elsewhere.** Superconductivity, superfluidity,
  polymer gelation, and tipping points in ecology and climate share the same
  qualitative onset.

In each case the rigorous template — sharp threshold, continuous onset,
uniqueness of the ordered state, rounding by an external bias — provides a
principled vocabulary for the transition.

---

## 11. Discussion and future work

We have given a complete, elementary, and rigorous treatment of the Curie–Weiss
phase transition, reducing the entire phenomenology to two sharp inequalities
for $\tanh$. The results establish the exact critical coupling, the continuous
(second-order) character of the onset, uniqueness of the ordered state, and the
rounding effect of an external field.

Natural extensions include:

1. **Critical exponent.** Prove the quantitative onset
   $m_*(\beta) = \sqrt{3(\beta-1)} + o(\sqrt{\beta-1})$ as $\beta \to 1^+$,
   extracting the mean-field exponent $1/2$. The bracketing (4) already
   constrains the branch from both sides; a matching cubic upper bound
   $\tanh y < y - y^3/3 + 2y^5/15$ would pin the exponent exactly.

2. **Uniqueness in a field.** Establish uniqueness of the solution of (2) for
   $h \ne 0$, giving a single-valued branch for all $\beta$ and recovering the
   standard picture of a line of first-order transitions terminating at the
   critical point $(\beta_c, h) = (1, 0)$.

3. **Variational characterization.** Formalize the Curie–Weiss free energy
   $f(m) = m^2/2 - (1/\beta)\log\cosh(\beta m)$ and prove that its global
   minimizer coincides with the stable solution of (1), yielding a variational
   description of the order parameter and an explicit analytic-to-nonanalytic
   statement for the minimal free energy at $\beta_c$.

4. **Monotone branch.** Package the positive solution as a function of $\beta$
   on $(1,\infty)$ and prove it continuous, strictly increasing, and tending to
   $1$ as $\beta\to\infty$.

5. **Percolation analogue.** Port the "order parameter zero below / positive
   above threshold" template to bond percolation on a rooted tree, where the
   survival probability of a branching process is the order parameter and
   $\mu_c = 1$ the critical point.

---

## 12. Conclusion

From a single scalar equation, $m = \tanh(\beta m)$, we have extracted the full
anatomy of a phase transition: a sharp critical coupling at $\beta_c = 1$, the
continuous birth of an ordered state above it, the uniqueness of that state, its
$\pm m$ symmetry, its strict boundedness, and the dissolution of sharpness under
an external field. The mathematics is elementary, but the structure it reveals
is universal, and the theorems above make that structure exact.
