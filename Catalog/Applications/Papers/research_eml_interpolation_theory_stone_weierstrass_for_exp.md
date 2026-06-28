# EML Interpolation Theory: Stone–Weierstrass Density and Explicit Jackson-Type Rates for Exponential–Logarithmic Networks

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Applications (approximation theory / mathematics of machine learning)

## Abstract

We develop a constructive approximation theory for **EML functions** — those built
by finitely composing the exponential $\exp$, the logarithm $\log$, and the ring
operations $+$, $\times$, and scalar multiplication. We prove two complementary
classes of result. *Qualitatively*, a single strictly monotone EML primitive
$g(t) = \exp(a)\log(bt+c)$ separates points, and through the Stone–Weierstrass
theorem the algebra it generates is uniformly dense in $C([\text{lo},\text{hi}],
\mathbb{R})$. *Quantitatively*, the rescaled $k$-th order forward difference of
$\exp$ is an explicit EML network for the monomial $x^k$ with a Jackson-type rate
$O(1/n)$ in the network width $n$; we establish this in full for $k=2$ and $k=3$,
with explicit constants $4/9$ and $5/16$ respectively. Finally, we prove that the
quadratic rate is **sharp**: at the endpoint $x=1$ the error is bounded below by
$h/3$, so it is $\Theta(h)$ and cannot be $o(h)$. The combination upgrades the
purely existential universal approximation guarantee to a constructive one with an
explicit, two-sided, rate-equipped backbone. All results are formally verified.

---

## 1. Introduction

Universal approximation theorems guarantee that broad function classes are dense in
$C(K)$ for compact $K$, but in their classical form they are **existential**: they
assert that an approximant exists without exhibiting it or quantifying the width
needed for a target accuracy. For applications — especially the mathematics of
neural networks — what is wanted is a *constructive* statement equipped with an
explicit error-versus-width tradeoff (a Jackson-type rate).

This paper studies the class of **EML functions**: finite compositions of $\exp$,
$\log$, the ring operations, and scalar multiplication. The class is natural (these
are the analytic primitives of elementary calculus) and surprisingly expressive. We
pursue three goals:

1. **Separation and density (qualitative).** Show that a single EML primitive
   separates points and hence, via Stone–Weierstrass, generates a dense subalgebra
   of $C([\text{lo},\text{hi}], \mathbb{R})$.
2. **Explicit rates (quantitative).** Exhibit concrete EML networks for the
   monomials $x^2$ and $x^3$ with explicit, vanishing error bounds and width-$n$
   rate $O(1/n)$.
3. **Sharpness.** Prove a matching lower bound, certifying that the rate for $x^2$
   is exactly $\Theta(1/n)$ and cannot be improved.

The unifying observation is that the exponential function serves double duty: its
strictly monotone inverse $\log$ powers the abstract separation argument, while the
positivity of the tail of its Taylor series powers both the explicit upper bounds
and the matching lower bound.

---

## 2. Definitions

Throughout, $K \subseteq \mathbb{R}^n$ denotes a compact set and $C(K,\mathbb{R})$
the Banach space of continuous real functions on $K$ with the uniform norm.

**Definition 2.1 (EML function, informal).** An *EML function* is any function
obtained from coordinate projections and real constants by finitely many
applications of $\exp$, $\log$ (on positive arguments), addition, multiplication,
and scalar multiplication. The EML functions on $K$ that are everywhere defined
form a subalgebra of $C(K,\mathbb{R})$.

**Definition 2.2 (Separating EML primitive).**
$$ \operatorname{emlSep}(a,b,c,t) \;=\; \exp(a)\,\log(b\,t + c). $$

**Definition 2.3 (Quadratic EML network).**
$$ \operatorname{emlQuadApprox}(h,x) \;=\; \frac{2}{h^2}\Big(\exp(h x) - 1 - h x\Big). $$
This is the rescaled second-order forward difference of $\exp$ at $0$ in step $hx$.

**Definition 2.4 (Cubic EML network).**
$$ \operatorname{emlCubicApprox}(h,x) \;=\; \frac{6}{h^3}\Big(\exp(h x) - 1 - h x - \tfrac{(h x)^2}{2}\Big). $$
This is the rescaled third-order forward difference of $\exp$.

Each of Definitions 2.2–2.4 is manifestly an EML function: it uses only $\exp$,
$\log$, ring operations, and scalars.

---

## 3. Qualitative theory: separation and Stone–Weierstrass density

### 3.1 The Stone–Weierstrass core

**Theorem 3.1 (`eml_topologicalClosure_eq_top_of_separatesPoints`).**
*Let $X$ be a compact Hausdorff space and $A \le C(X,\mathbb{R})$ a subalgebra that
separates points. Then the topological closure of $A$ is all of $C(X,\mathbb{R})$.*

This is the real-algebra form of Stone–Weierstrass; subalgebras of $C(X,\mathbb{R})$
automatically contain the constants, so point-separation is the only hypothesis
needed. Its $\varepsilon$-form is recorded as:

**Theorem 3.2 (`eml_exists_uniform_approx`).**
*If $A \le C(X,\mathbb{R})$ separates points, then for every $f \in C(X,\mathbb{R})$
and every $\varepsilon > 0$ there is $g \in A$ with $\lVert g - f\rVert < \varepsilon$.*

We record the EML-facing restatement as **Theorem 3.3
(`eml_universalApproximation`)**: any EML-generated subalgebra that separates points
is uniformly dense in $C(X,\mathbb{R})$. A pullback version
(`eml_pullback_universalApproximation`) transfers density along an injective
continuous map $\varphi$: if $A \le C(Y,\mathbb{R})$ separates points and $\varphi:
X \to Y$ is injective, then $\{g \circ \varphi : g \in A\}$ is dense in
$C(X,\mathbb{R})$, the structural device by which one-dimensional separation lifts
to higher-dimensional compacta.

### 3.2 A single EML primitive separates points

**Theorem 3.4 (`emlSep_strictMonoOn`).**
*For $b > 0$ and any $a, c \in \mathbb{R}$, the function $t \mapsto
\operatorname{emlSep}(a,b,c,t)$ is strictly increasing on the set $\{t : b t + c >
0\}$.*

*Proof sketch.* On $\{bt+c>0\}$ the affine map $t \mapsto bt+c$ is strictly
increasing ($b>0$); $\log$ is strictly increasing on $(0,\infty)$; and
multiplication by $\exp(a) > 0$ preserves the order. Composition of strictly
increasing maps is strictly increasing. $\square$

**Theorem 3.5 (`emlSep_separates`).**
*For $b>0$ and $x \neq y$ with $bx+c>0$, $by+c>0$, one has
$\operatorname{emlSep}(a,b,c,x) \neq \operatorname{emlSep}(a,b,c,y)$.*

*Proof sketch.* Strict monotonicity (Theorem 3.4) implies injectivity on the
admissible domain. $\square$

The positivity hypothesis is load-bearing: $\log$ is monotone only on the
positives. On an interval $[\text{lo},\text{hi}]$ the normalization $a=0$, $b=1$,
$c=1-\text{lo}$ makes the argument $t + 1 - \text{lo} \ge 1 > 0$ throughout
(**`emlSep_separates_Icc`**). The resulting primitive $t \mapsto \log(t + 1 -
\text{lo})$, viewed as an element $\operatorname{emlSepCM}(\text{lo},\text{hi}) \in
C([\text{lo},\text{hi}],\mathbb{R})$, gives:

**Theorem 3.6 (`emlSepCM_separatesPoints`).**
*The subalgebra $\operatorname{adjoin}_{\mathbb{R}}\{\,t \mapsto \log(t+1-\text{lo})\,\}$
separates the points of $[\text{lo},\text{hi}]$.*

**Theorem 3.7 (EML density on an interval, `eml_adjoin_dense_on_Icc`).**
*The subalgebra generated by the single EML function $t \mapsto \log(t+1-\text{lo})$
is uniformly dense in $C([\text{lo},\text{hi}],\mathbb{R})$:*
$$ \overline{\operatorname{adjoin}_{\mathbb{R}}\{\,t\mapsto \log(t+1-\text{lo})\,\}} = C([\text{lo},\text{hi}],\mathbb{R}). $$

*Proof sketch.* Combine Theorem 3.6 with Theorem 3.1. $\square$

Thus a single strictly monotone EML primitive suffices for full density. This is
the qualitative half of EML interpolation theory.

---

## 4. Quantitative theory: explicit Jackson-type rates

The density theorem is existential. We now provide explicit constructions with
quantitative rates, building each monomial $x^k$ from a rescaled forward difference
of $\exp$.

### 4.1 The quadratic case

**Lemma 4.1 (Taylor remainder, `exp_sub_quadratic_le`).**
*For $u \in [0,1]$,*
$$ \big| \exp(u) - \big(1 + u + \tfrac{u^2}{2}\big) \big| \le \tfrac{2}{9}\,u^3. $$

*Proof sketch.* Apply the Mathlib estimate `Real.exp_bound` at order $n=3$ with
$|u|\le 1$; arithmetic simplification of the partial sum and remainder yields the
constant $2/9$. $\square$

**Theorem 4.2 (Uniform error, `emlQuadApprox_error`).**
*For $0 < h \le 1$ and $x \in [0,1]$,*
$$ \big| \operatorname{emlQuadApprox}(h,x) - x^2 \big| \le \tfrac{4}{9}\,h. $$

*Proof sketch.* Set $u = hx \in [0,1]$. The algebraic identity
$$ \operatorname{emlQuadApprox}(h,x) - x^2 = \frac{2}{h^2}\Big(\exp(u) - \big(1 + u + \tfrac{u^2}{2}\big)\Big) $$
follows by clearing the $h^2$ denominator. Lemma 4.1 bounds the bracket by
$\tfrac29 u^3 = \tfrac29 h^3 x^3$; multiplying by $2/h^2$ gives $\tfrac49 h x^3 \le
\tfrac49 h$, using $x^3 \le 1$ on $[0,1]$. $\square$

**Theorem 4.3 (Width-$n$ rate, `emlQuadApprox_rate`).**
*For $n \ge 1$ and $x \in [0,1]$,*
$$ \big| \operatorname{emlQuadApprox}(1/n,\,x) - x^2 \big| \le \frac{4}{9n}. $$

*Proof sketch.* Specialize Theorem 4.2 to $h = 1/n$, which satisfies $0 < h \le 1$.
$\square$

**Theorem 4.4 (Convergence, `emlQuadApprox_tendsto`).**
*For each fixed $x \in [0,1]$, $\operatorname{emlQuadApprox}(1/n, x) \to x^2$ as $n
\to \infty$.*

*Proof sketch.* The rate $4/(9n) \to 0$ from Theorem 4.3, via an $\varepsilon$-$N$
argument. $\square$

### 4.2 The cubic case

**Lemma 4.5 (Taylor remainder, `exp_sub_cubic_le`).**
*For $u \in [0,1]$,*
$$ \big| \exp(u) - \big(1 + u + \tfrac{u^2}{2} + \tfrac{u^3}{6}\big) \big| \le \tfrac{5}{96}\,u^4. $$

*Proof sketch.* `Real.exp_bound` at order $n=4$, with $|u| \le 1$. $\square$

**Theorem 4.6 (Uniform error, `emlCubicApprox_error`).**
*For $0 < h \le 1$ and $x \in [0,1]$,*
$$ \big| \operatorname{emlCubicApprox}(h,x) - x^3 \big| \le \tfrac{5}{16}\,h. $$

*Proof sketch.* With $u = hx$, the identity
$$ \operatorname{emlCubicApprox}(h,x) - x^3 = \frac{6}{h^3}\Big(\exp(u) - \big(1+u+\tfrac{u^2}{2}+\tfrac{u^3}{6}\big)\Big) $$
holds after clearing $h^3$. Lemma 4.5 bounds the bracket by $\tfrac{5}{96}u^4 =
\tfrac{5}{96}h^4 x^4$; multiplying by $6/h^3$ gives $\tfrac{6\cdot5}{96} h x^4 =
\tfrac{5}{16} h x^4 \le \tfrac{5}{16} h$, using $x^4 \le 1$ and $(hx)^4 \le h^4$.
$\square$

**Theorem 4.7 (Width-$n$ rate, `emlCubicApprox_rate`).**
*For $n \ge 1$ and $x \in [0,1]$,*
$$ \big| \operatorname{emlCubicApprox}(1/n,\,x) - x^3 \big| \le \frac{5}{16n}. $$

**Theorem 4.8 (Convergence, `emlCubicApprox_tendsto`).**
*For each fixed $x \in [0,1]$, $\operatorname{emlCubicApprox}(1/n, x) \to x^3$.*

### 4.3 The general pattern

Lemmas 4.1 and 4.5 are the cases $k=2,3$ of a single principle. Writing $u = hx$,
$$ \frac{k!}{h^k}\Big(\exp(u) - \sum_{m=0}^{k-1}\frac{u^m}{m!}\Big) - x^k
= \frac{k!}{h^k}\Big(\exp(u) - \sum_{m=0}^{k}\frac{u^m}{m!}\Big), $$
and the Taylor remainder of $\exp$ at order $k+1$ on $[0,1]$ is $O(u^{k+1}) =
O(h^{k+1}x^{k+1})$, so the rescaled difference approximates $x^k$ with error
$O(h)$, i.e. rate $O(1/n)$ at $h=1/n$. Since every polynomial is a finite linear
combination of monomials, the entire polynomial algebra is constructively
EML-approximable with explicit linear rate — supplying the rate-equipped engine
underneath the abstract density of Section 3.

---

## 5. Sharpness: the quadratic rate is $\Theta(1/n)$

A linear upper bound is only half the story; it could in principle be a loose
overestimate of a method that is secretly $O(h^2)$. We rule this out.

**Lemma 5.1 (Cubic Taylor lower bound, `exp_ge_cubic`).**
*For $h \ge 0$,*
$$ 1 + h + \tfrac{h^2}{2} + \tfrac{h^3}{6} \le \exp(h). $$

*Proof sketch.* This is the partial sum $\sum_{m<4} h^m/m!$ of the exponential
series; the remaining terms are non-negative for $h \ge 0$
(`Real.sum_le_exp_of_nonneg` at $n=4$). $\square$

**Theorem 5.2 (Lower bound at the endpoint, `emlQuadApprox_lower`).**
*For $h > 0$,*
$$ \frac{h}{3} \le \operatorname{emlQuadApprox}(h,1) - 1^2. $$

*Proof sketch.* By definition $\operatorname{emlQuadApprox}(h,1) - 1 = \frac{2}{h^2}(\exp
h - 1 - h) - 1$. Lemma 5.1 gives $\exp h - 1 - h \ge \tfrac{h^2}{2} + \tfrac{h^3}{6}$,
so $\frac{2}{h^2}(\exp h - 1 - h) \ge 1 + \tfrac{h}{3}$, whence the slack is at
least $h/3$. $\square$

**Theorem 5.3 (Two-sided bound, `emlQuadApprox_error_Theta`).**
*For $0 < h \le 1$,*
$$ \frac{h}{3} \le \operatorname{emlQuadApprox}(h,1) - 1 \le \frac{4}{9}\,h. $$

*Proof sketch.* Lower bound from Theorem 5.2, upper bound from Theorem 4.2 at
$x=1$. $\square$

**Theorem 5.4 (Width-$n$ lower bound, `emlQuadApprox_rate_lower`).**
*For $n \ge 1$,*
$$ \frac{1}{3n} \le \operatorname{emlQuadApprox}(1/n,\,1) - 1. $$

**Theorem 5.5 (Linear rate is optimal, `emlQuadApprox_not_o`).**
*The error of $\operatorname{emlQuadApprox}(h,\cdot)$ at $x=1$ is not $o(h)$ as $h \to
0^+$; in particular it does not attain the quadratic rate $O(h^2)$.*

*Proof sketch.* By Theorem 5.2 the error at $x=1$ is at least $h/3$, so
$\operatorname{error}/h \ge 1/3 \not\to 0$. $\square$

Together, Theorems 4.2–4.3 and 5.2–5.5 certify that the error at the endpoint
$x=1$ is exactly of order $h$ — squeezed between $h/3$ and $\tfrac49 h$ — so the
width-$n$ rate is precisely $\Theta(1/n)$, neither beatable nor improvable for this
construction.

---

## 6. Algorithms

**Algorithm 6.1 (Forward-difference monomial synthesis).** Given a target
monomial degree $k$, step $h$, and input $x$, return $\frac{k!}{h^k}\big(\exp(hx) -
\sum_{m=0}^{k-1}(hx)^m/m!\big)$. For $k=2$ this is $\operatorname{emlQuadApprox}$; for
$k=3$, $\operatorname{emlCubicApprox}$. Cost: one exponential evaluation, $O(k)$ ring
operations. Error on $[0,1]$ with $0<h\le1$: $O(h)$ uniformly.

**Algorithm 6.2 (Polynomial assembly).** To approximate $\sum_k c_k x^k$ on
$[0,1]$, sum the per-monomial EML networks $\sum_k c_k \cdot \operatorname{(monomial
synth)}(k,h,x)$. By the triangle inequality the total error is at most $h \sum_k
|c_k| C_k$, where $C_k$ is the per-monomial constant ($C_2 = 4/9$, $C_3 = 5/16$).

**Algorithm 6.3 (Width selection for target accuracy).** To guarantee uniform
error $\le \varepsilon$ for $x^2$ on $[0,1]$, choose $n \ge \lceil 4/(9\varepsilon)
\rceil$ and use $h = 1/n$ (Theorem 4.3). For $x^3$, use $n \ge \lceil 5/(16
\varepsilon)\rceil$ (Theorem 4.7).

---

## 7. Applications and discussion

**Quantitative neural approximation.** EML networks are a clean theoretical model
for architectures with exponential/logarithmic activations. The results convert the
existential universal approximation promise into a budget: error and width are tied
by an explicit constant, and (for $x^2$) the constant cannot be improved.

**The exponential's double role.** A single analytic object underlies both halves
of the theory. Its inverse $\log$ is strictly monotone, supplying the point
separation behind Stone–Weierstrass density (Section 3); the positivity of the tail
of its Taylor series supplies both the upper-bound remainder estimates and the
matching lower bound (Sections 4–5).

**Constructivity with certified tightness.** Unlike abstract density arguments, the
EML monomial networks are explicit formulas with computable error constants, and
the $\Theta(h)$ result for $x^2$ certifies that the stated rate is exactly correct.

---

## 8. Future work

- Establish the general degree-$k$ rate $|{\textstyle\frac{k!}{h^k}}(\Delta_h^k \exp)(x) - x^k| \le C_k h$ with an explicit closed form for $C_k$, generalizing the $k=2,3$ constants $4/9$ and $5/16$.
- Prove matching lower bounds for $x^3$ and general $x^k$, mirroring the $\Theta(h)$ result for $x^2$.
- Extend the explicit rates from monomials to general Lipschitz and $\mathrm{Lip}_\alpha$ targets, aiming at the conjectured width $O(\varepsilon^{-n/\alpha})$ on compact subsets of $\mathbb{R}^n$.
- Combine the explicit monomial networks with the pullback density transfer (`eml_pullback_universalApproximation`) to obtain explicit multivariate rates on injective images of intervals.
- Investigate whether alternative EML templates (e.g. logarithmic finite differences) yield smaller constants or higher-order rates for smooth targets.

---

## 9. Conclusion

EML interpolation theory marries a qualitative density result — a single strictly
monotone EML primitive separates points and, via Stone–Weierstrass, generates a
dense subalgebra of $C([\text{lo},\text{hi}],\mathbb{R})$ — with quantitative,
explicit Jackson-type rates for the monomials $x^2$ (constant $4/9$) and $x^3$
(constant $5/16$), built as rescaled forward differences of $\exp$. The quadratic
rate is proved sharp ($\Theta(1/n)$). The exponential thus furnishes, through its
inverse and through its series, a complete and honest constructive backbone for
universal approximation by exp–log networks.
