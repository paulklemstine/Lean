# Deformation-Stable Arithmetic Coherence Thresholds

## Abstract

We study a family of mean-field "coherence" models built on an arithmetic
counting statistic, and we prove that two features usually conflated in the
analysis of critical phenomena are in fact logically independent. The *location*
of the activation boundary is an order-theoretic invariant of the underlying
statistic, determined solely by a threshold inequality; it is preserved by every
response law that vanishes exactly at zero (a *zero-reflecting* deformation). The
*critical exponent*, by contrast, is a purely analytic feature of the response
law, realizable at any positive value through a power response, and governed by an
exact homogeneity identity. Specializing to the cyclotomic $\mathrm{GL}(1)$
character count — which equals Euler's totient $\varphi(n)$, and hence $p - 1$ at
prime conductor $p$ — we obtain an exact arithmetic phase diagram: modeled
coherence is inactive precisely for primes $p \le 10001$ and active precisely for
$p > 10001$, and this boundary is invariant under all zero-reflecting deformations
while every positive exponent is independently attainable. The development
isolates three reusable layers: positive-part threshold geometry, abstract
response-law invariance, and cyclotomic arithmetic specialization.

## 1. Introduction

A phase transition couples an arithmetic or combinatorial *statistic* (which
determines whether a system is active) to a phenomenological *response law* (which
determines how the active phase is expressed). In empirical practice these two
ingredients are routinely entangled: one measures an observable, notes where it
leaves zero, and reports both a threshold and a scaling exponent, as if both were
intrinsic. The purpose of this paper is to separate them cleanly and prove that
the separation is exact.

Our vehicle is a canonical arithmetic count arising from class field theory. For a
cyclotomic extension $\mathbb{Q}(\zeta_n)/\mathbb{Q}$, the number of
one-dimensional complex representations of the Galois group is Euler's totient
$\varphi(n)$; at prime conductor $p$ it is $p - 1$. Interpreting this count as a
number of cross-domain "connections" and feeding it into a mean-field order
parameter produces a model phase transition. We then ask: which of its features
survive when we deform the response law?

**Contributions.**

1. We identify the *excess above threshold* $e_c(x) = \max(x - c, 0)$ as the sole
   carrier of the activation boundary and record its exact zero set, monotonicity,
   and continuity (Section 3).
2. We prove that every *zero-reflecting* response law preserves the activation
   boundary exactly, and that monotone (resp. continuous) response laws preserve
   monotonicity (resp. continuity) of the resulting order parameter (Section 4).
3. We isolate the power-law subfamily, prove that positive exponents preserve the
   boundary, and establish an exact homogeneity identity that pins the critical
   exponent to the chosen power (Section 5).
4. We specialize to the cyclotomic count and obtain an exact prime-conductor phase
   diagram, deformation-invariant in its boundary and exponent-flexible in its
   scaling (Section 6).

All results are exact statements within the stated model. The constant $c = 10000$
is a modeling parameter, not an empirically estimated quantity; the arithmetic
count and every consequence drawn from it are unconditional.

## 2. Preliminaries: the arithmetic statistic

Let $L = \mathbb{Q}(\zeta_n)$ be a cyclotomic extension of the rationals with
conductor $n$. The abelian ($\mathrm{GL}(1)$) case of the Langlands
correspondence — classical global class field theory — provides a canonical
isomorphism between two character groups: the Dirichlet (finite-order Hecke)
characters modulo $n$, and the one-dimensional complex representations of the
Galois group $\mathrm{Gal}(L/\mathbb{Q})$. The bridge is Artin reciprocity,
$$\mathrm{Gal}\big(\mathbb{Q}(\zeta_n)/\mathbb{Q}\big) \;\cong\; (\mathbb{Z}/n\mathbb{Z})^{\times},$$
which holds unconditionally over $\mathbb{Q}$ because the cyclotomic polynomial
$\Phi_n$ is irreducible there.

**Definition 2.1 (Connection count).** The *connection count* of conductor $n$ is
$$C(n) \;=\; \#\big\{\text{one-dimensional complex representations of } \mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q})\big\}.$$

**Proposition 2.2 (Arithmetic value of the count).** For every $n \ge 1$,
$C(n) = \varphi(n)$. In particular, for a prime conductor $p$,
$$C(p) = \varphi(p) = p - 1.$$

*Proof sketch.* Transport the group isomorphism between Dirichlet characters and
Galois representations to a bijection of finite sets and count cardinalities. The
number of Dirichlet characters modulo $n$ valued in $\mathbb{C}$ equals
$\#(\mathbb{Z}/n\mathbb{Z})^{\times} = \varphi(n)$ (using that $\mathbb{C}$
contains enough roots of unity). The prime case is $\varphi(p) = p - 1$. $\square$

**Definition 2.3 (Mean-field coherence).** Fix a coupling $\kappa \ge 0$ and a
critical connection budget $c \ge 0$. The *coherence* order parameter of a
statistic $x \ge 0$ is
$$\Phi_{\mathrm{sqrt}}(x) \;=\; \sqrt{\kappa}\,\sqrt{\max(x - c,\, 0)}.$$
It is zero for $x \le c$ and grows like the square root of the excess above it.

Throughout we take the specific budget $c = 10000$ for the arithmetic
specialization; we call it the *critical edge count*.

## 3. Positive-part threshold geometry

The activation boundary of every model below is carried by a single elementary
object.

**Definition 3.1 (Excess).** For a threshold $c \in \mathbb{R}$, the *excess*
above $c$ is
$$e_c(x) \;=\; \max(x - c,\, 0), \qquad x \in \mathbb{R}.$$

**Lemma 3.2 (Exact zero set).** $e_c(x) = 0$ if and only if $x \le c$.

*Proof.* $\max(x - c, 0) = 0$ iff $x - c \le 0$ iff $x \le c$. $\square$

**Lemma 3.3 (Monotonicity).** $e_c$ is monotone nondecreasing.

*Proof.* If $x \le y$ then $x - c \le y - c$, so
$\max(x - c, 0) \le \max(y - c, 0)$ by monotonicity of $\max$ in each argument.
$\square$

**Lemma 3.4 (Continuity).** $e_c$ is continuous.

*Proof.* $x \mapsto x - c$ is continuous and the pointwise maximum of two
continuous functions is continuous. $\square$

These three facts are the entire structural content that propagates through the
rest of the paper: Lemma 3.2 controls the boundary, Lemmas 3.3–3.4 control
regularity.

## 4. Response-law invariance

We now compose the excess with an arbitrary response law.

**Definition 4.1 (Deformed order parameter).** Given a response law
$F : \mathbb{R} \to \mathbb{R}$, threshold $c$, and statistic $x$, set
$$\Phi_F(x) \;=\; F\big(e_c(x)\big) \;=\; F\big(\max(x - c, 0)\big).$$

**Definition 4.2 (Zero-reflecting).** A response law $F$ is *zero-reflecting* on
$[0, \infty)$ if for all $y \ge 0$, $F(y) = 0 \iff y = 0$.

**Theorem 4.3 (Deformation invariance of the boundary).** If $F$ is
zero-reflecting, then for all $x$,
$$\Phi_F(x) = 0 \iff x \le c.$$

*Proof sketch.* Write $y = e_c(x) \ge 0$. If $\Phi_F(x) = F(y) = 0$, zero
reflection gives $y = 0$, i.e. $\max(x - c, 0) = 0$; since this maximum is $\ge 0$
and equals $0$, we get $x - c \le 0$, so $x \le c$. Conversely, if $x \le c$ then
$y = 0$ by Lemma 3.2, and $F(0) = 0$ by zero reflection, so $\Phi_F(x) = 0$.
$\square$

Theorem 4.3 is the paper's conceptual core: the activation boundary depends only
on the *zero set* of $F$, not on its shape. In particular the choice among
square-root, linear, or any other zero-reflecting response cannot move the
transition.

**Theorem 4.4 (Monotonicity transfer).** If $F$ is monotone nondecreasing, then
$\Phi_F$ is monotone nondecreasing.

*Proof.* For $x \le y$, Lemma 3.3 gives $e_c(x) \le e_c(y)$, and applying the
monotone $F$ preserves the inequality. $\square$

**Theorem 4.5 (Continuity transfer).** If $F$ is continuous, then $\Phi_F$ is
continuous.

*Proof.* $\Phi_F = F \circ e_c$ is a composition of continuous functions
(Lemma 3.4). $\square$

Thus continuity and monotonicity are governed by $F$ *away from and across* the
boundary, entirely separately from the boundary's location, which is governed by
the zero set of $F$ alone.

## 5. Power responses and the critical exponent

The zoo of zero-reflecting responses that also fixes an exponent is the power
family.

**Definition 5.1 (Power response).** For an exponent $\alpha \in \mathbb{R}$,
$$\Phi_\alpha(x) \;=\; \big(e_c(x)\big)^{\alpha} \;=\; \big(\max(x - c, 0)\big)^{\alpha},$$
using the real power $y \mapsto y^{\alpha}$ on $y \ge 0$.

**Theorem 5.2 (Positive powers preserve the boundary).** For $\alpha > 0$,
$$\Phi_\alpha(x) = 0 \iff x \le c.$$

*Proof sketch.* With $y = e_c(x) \ge 0$, the real power satisfies $y^{\alpha} = 0
\iff y = 0$ when $\alpha \ne 0$; combined with Lemma 3.2 this gives the claim.
Equivalently, $F(y) = y^{\alpha}$ is zero-reflecting, so Theorem 4.3 applies.
$\square$

**Theorem 5.3 (Exact critical scaling).** For any exponent $\alpha$, any distance
$t > 0$ past the threshold, and any magnification $a > 0$,
$$\Phi_\alpha\big(c + a\,t\big) \;=\; a^{\alpha}\,\Phi_\alpha\big(c + t\big).$$

*Proof sketch.* At $x = c + a t$ the excess is $\max(a t, 0) = a t$ (since
$a, t > 0$), and at $x = c + t$ it is $t$. Hence
$\Phi_\alpha(c + a t) = (a t)^{\alpha}$ and $\Phi_\alpha(c + t) = t^{\alpha}$. The
multiplicativity of the real power on nonnegative arguments,
$(a t)^{\alpha} = a^{\alpha} t^{\alpha}$, yields
$(a t)^{\alpha} = a^{\alpha}\,t^{\alpha} = a^{\alpha}\,\Phi_\alpha(c + t)$.
$\square$

Theorem 5.3 identifies $\alpha$ as the critical exponent: rescaling the distance
from criticality by $a$ rescales the order parameter by $a^{\alpha}$. Because
Theorem 5.2 holds for *every* positive $\alpha$ with the same boundary, the
exponent varies freely and independently of the transition location. The classical
mean-field value is $\alpha = \tfrac12$; a tree-like (linear-onset) model is
$\alpha = 1$.

## 6. Arithmetic specialization: the cyclotomic phase diagram

We now instantiate the statistic with the connection count of Section 2 and the
budget $c = 10000$.

**Theorem 6.1 (Deformation-invariant prime cutoff).** Let $F$ be zero-reflecting
and let $p$ be a prime conductor. Then
$$\Phi_F\big(C(p)\big) = 0 \iff p \le 10001.$$

*Proof sketch.* By Theorem 4.3, $\Phi_F(C(p)) = 0 \iff C(p) \le 10000$. By
Proposition 2.2, $C(p) = p - 1$, so the condition reads $p - 1 \le 10000$, i.e.
$p \le 10001$. $\square$

**Theorem 6.2 (Universal power activation).** For every exponent $\alpha > 0$ and
prime conductor $p$,
$$\Phi_\alpha\big(C(p)\big) > 0 \iff p > 10001.$$

*Proof sketch.* The power order parameter is nonnegative, so
$\Phi_\alpha(C(p)) > 0$ is the negation of $\Phi_\alpha(C(p)) = 0$. By
Theorem 5.2 the latter is $C(p) \le 10000$, whose negation is $C(p) > 10000$, i.e.
$p - 1 > 10000$, i.e. $p > 10001$. $\square$

Combining Theorem 6.2 with Theorem 5.3 gives the full picture at prime conductors:
the activation boundary sits at $p = 10001$ for *all* positive exponents
simultaneously, while the exponent $\alpha$ — chosen freely and detected by the
scaling identity — governs how sharply coherence grows beyond it. For the specific
square-root law of Definition 2.3, this recovers the exact critical scaling
$$\Phi_{\mathrm{sqrt}}\big(C(p)\big) = \sqrt{\kappa}\,\sqrt{(p - 1) - 10000}, \qquad p > 10001.$$

## 7. Algorithms

The results are constructive and yield simple, exact algorithms.

**Algorithm A (Prime activation classifier).** Given a prime $p$, decide the phase
by comparing $p$ with $10001$; the answer is independent of the response law. This
runs in the cost of one primality check plus one comparison.

**Algorithm B (Order-parameter evaluator).** Given $\kappa$, a threshold $c$, an
exponent $\alpha$, and a statistic $x$, compute the excess $e_c(x) = \max(x-c,0)$
and return $\kappa^{1/2} e_c(x)^{\alpha}$ (or a general $F(e_c(x))$). The zero set
is exactly $\{x \le c\}$ by construction.

**Algorithm C (Exponent estimator).** Given two sampled distances $t_1, t_2 > 0$
past threshold with observed values $v_1, v_2$ of a power order parameter,
recover the exponent by the scaling identity of Theorem 5.3:
$\alpha = \log(v_2/v_1)\,/\,\log(t_2/t_1)$. This demonstrates that the exponent is
an inference about the response law, not about the boundary.

## 8. Applications and discussion

The separation theorem is a cautionary and clarifying principle for any empirical
search for a critical threshold. Two consequences stand out.

- **Observable-independence of the boundary.** Any two zero-reflecting observables
  agree on where the transition occurs (Theorem 4.3). An observed shift in a
  threshold therefore cannot be attributed to the choice of observable; it must be
  traced to the construction or weighting of the underlying connection data.
- **Observable-dependence of the exponent.** The exponent is set by the response
  law (Theorem 5.3). A claimed *universality* of critical exponents across a family
  of systems is meaningful only if it survives holding the response law fixed;
  otherwise it may be an artifact of measurement.

These points recommend a methodology: fix a single zero-reflecting response,
locate the boundary via susceptibility, and only then compare exponents across
families to test for genuine geometric universality.

## 9. Future work

- **Higher-rank compatibility percolation.** Build a bipartite graph of rank-two
  automorphic and Galois representations linked by established local–global
  compatibilities; conjecture a universal giant-component threshold in the
  normalized mean degree, with a boundary invariant under every zero-reflecting
  observable applied to the component density.
- **Arithmetic universality from local homogeneity.** Order number fields by
  discriminant and conjecture finitely many exponent classes — $1$ for tree-like
  networks, $\tfrac12$ for symmetry-breaking character models, with a discrete
  ladder of higher rational exponents for multicritical families — inferred from
  rescaling rather than from the names of the objects.
- **Susceptibility-derived thresholds.** Define susceptibility as the expected
  increase in the largest coherent component per additional verified
  compatibility, and conjecture a canonical normalization with a unique
  susceptibility maximum, stable under zero-reflecting deformations of the density
  observable.
- **Totient intermittency.** Beyond primes, replace $p - 1$ by $\varphi(n)$ and
  conjecture an exponent $\theta < 1$ such that every window
  $[T, T + T^{\theta}]$ contains conductors $m, n$ with
  $\varphi(m) \le T < \varphi(n)$ — an arithmetic intermittency modeling
  punctuated activation.

## 10. Conclusion

Within a canonical arithmetic model of coherence, the location of a phase
transition and the exponent governing its onset are logically independent: the
former is an order-theoretic invariant carried by the positive-part map and
preserved by every zero-reflecting deformation, while the latter is an analytic
feature of the response law, realizable at any positive value and pinned by an
exact homogeneity identity. Specialized to the cyclotomic $\mathrm{GL}(1)$ count,
this yields an exact, deformation-stable prime-conductor phase diagram with a sharp
cutoff at $p = 10001$. The framework provides a rigorous null model against which
bolder conjectures about arithmetic coherence transitions can be tested.
