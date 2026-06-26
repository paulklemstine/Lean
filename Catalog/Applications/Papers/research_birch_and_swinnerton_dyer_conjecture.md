# Local and Analytic Structures Underlying the Birch and Swinnerton-Dyer Conjecture

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Novelty (Arithmetic of elliptic curves)

## Abstract

The Birch and Swinnerton-Dyer (BSD) conjecture predicts that the algebraic rank of an elliptic curve $E/\mathbb{Q}$ — the free rank of its Mordell–Weil group $E(\mathbb{Q})$ — equals the analytic rank, the order of vanishing of its Hasse–Weil $L$-function $L(E,s)$ at the central point $s=1$. We develop and rigorously verify a collection of the local and analytic structures that underpin this conjecture, organized in five self-contained modules. On the local side we establish the algebraic equivalence between the Riemann Hypothesis over finite fields (Frobenius eigenvalues on the circle $|z|=\sqrt p$) and the Hasse bound $a_p^2\le 4p$; the Vieta relations $\alpha+\beta=a_p$, $\alpha\beta=p$; the local functional equation $L_p(T)=pT^2L_p(1/(pT))$; Newton's linear recurrence $s_{n+2}=a_p s_{n+1}-p\,s_n$ for the Frobenius power sums $s_n=\alpha^n+\beta^n$ with the calibrated initial data $s_0=2,\ s_1=a_p$; the trace-sequence computation of the point-count tower $\#E(\mathbb{F}_{p^n})=p^n+1-s_n$; the Sato–Tate angle $a_p=2\sqrt p\cos\theta$; and the archimedean bound $\lVert\alpha^n+\beta^n\rVert\le 2(\sqrt p)^n$. On the analytic side we formalize the analytic rank via the order of vanishing, prove rank-zero/positive detection, leading-term factorization, additivity under products, and the unconditional **parity theorem** $(-1)^{\operatorname{ord}_{s=1}\Lambda}=w$ for any function obeying the functional-equation symmetry $\Lambda(2-s)=w\,\Lambda(s)$. Finally we assemble a **rank bridge**: under the BSD rank equality, the central value $L(E,1)$ vanishes if and only if $E(\mathbb{Q})$ is infinite. All results are machine-verified; this paper states each inline with a proof sketch.

---

## 1. Introduction

Let $E/\mathbb{Q}$ be an elliptic curve. Two integers are attached to it by entirely different routes. The **algebraic rank** $r_{\mathrm{alg}}$ is the rank of the finitely generated abelian group $E(\mathbb{Q})\cong\mathbb{Z}^{r_{\mathrm{alg}}}\times T$, where $T$ is finite torsion. The **analytic rank** $r_{\mathrm{an}}=\operatorname{ord}_{s=1}L(E,s)$ is the order of vanishing of the Hasse–Weil $L$-function at the center of its functional equation. The BSD conjecture asserts $r_{\mathrm{alg}}=r_{\mathrm{an}}$, and in its refined form predicts the leading Taylor coefficient of $L(E,s)$ at $s=1$ in terms of the regulator, the order of the Tate–Shafarevich group $\Sha$, the real period, and the Tamagawa numbers.

This work isolates and verifies the structural scaffolding on which both sides of BSD rest. We do not claim a proof of BSD; rather, we make precise and machine-check the analytic mechanisms (functional-equation parity, order-of-vanishing calculus) and the local mechanisms (Frobenius eigenvalues, the Hasse/RH equivalence, the point-count recurrence, the Sato–Tate angle) that any treatment of BSD must invoke, and we assemble them into a clean qualitative consequence of the rank equality.

The exposition follows the five formalized modules: §2 the local $L$-factor and the RH/Hasse equivalence; §3 the Frobenius trace recurrence, the point-count tower, the Sato–Tate angle and the norm bound; §4 the analytic rank and order-of-vanishing calculus; §5 the functional equation and the parity theorem; §6 the rank bridge. §7 discusses applications and §8 future work.

---

## 2. The local $L$-factor and the Riemann Hypothesis over finite fields

**Definition 1 (Local $L$-factor).** At a prime $p$ of good reduction, the local factor is the degree-two polynomial
$$L_p(T) = 1 - a_p T + p\,T^2,$$
where $a_p = p+1-\#E(\mathbb{F}_p)$ is the trace of Frobenius. The global $L$-function is the Euler product $L(E,s)=\prod_p L_p(p^{-s})^{-1}$.

**Definition 2 (Frobenius characteristic polynomial).** The reciprocal roots of $L_p$ are the roots of
$$f(X) = X^2 - a_p X + p,$$
the **Frobenius eigenvalues** $\alpha,\beta$.

**Theorem 3 (RH over $\mathbb{F}_p$ ⇔ Hasse bound).** Let $a,p\in\mathbb{R}$ with $0<p$, and let $z\in\mathbb{C}$ be any root of $X^2-aX+p$. Then
$$|z|^2 = p \iff a^2 \le 4p.$$
*Proof sketch.* Write the condition $f(z)=0$ in real/imaginary coordinates. For the forward direction, split on the sign of the discriminant: if $z$ is non-real then $z,\bar z$ are conjugate roots, so $|z|^2 = z\bar z = \alpha\beta = p$ by Vieta and the discriminant is negative, i.e. $a^2\le 4p$; if $z$ is real then $|z|^2=z^2$ equals $p$ only at the double root $z=a/2$, forcing $a^2=4p$. For the converse, $a^2\le 4p$ yields either complex-conjugate roots (handled by Vieta) or a real double root, and in each case $|z|^2=p$ follows by a nonnegativity argument ($\operatorname{nlinarith}$ on the squared coordinates). $\square$

**Lemma 4 (Vieta product).** Distinct roots $z\neq w$ of $f$ satisfy $z\cdot w = p$.
**Lemma 5 (Vieta sum).** Distinct roots $z\neq w$ of $f$ satisfy $z+w=a$.
*Proof sketch.* Subtract the two equations $f(z)=f(w)=0$; $z^2-w^2-a(z-w)=0$ factors as $(z-w)(z+w-a)=0$, and cancelling $z-w\neq 0$ gives the sum. Substituting back gives the product. $\square$

**Theorem 6 (Hasse bound).** If $0\le p$ and $a^2\le 4p$, then $|a|\le 2\sqrt p$.
*Proof sketch.* Square the target: $(2\sqrt p)^2 = 4p \ge a^2$, and take square roots using $a^2\le b^2,\ b\ge 0 \Rightarrow |a|\le b$. $\square$

**Theorem 7 (Local functional equation).** For $T\neq 0$, $p\neq 0$,
$$L_p(T) = p\,T^2\, L_p\!\left(\tfrac{1}{pT}\right).$$
*Proof sketch.* Substitute $1/(pT)$ into $L_p$, clear denominators, and simplify; the identity is a rational-function tautology ($\operatorname{field\_simp}$ then $\operatorname{ring}$). It is the local incarnation of the global symmetry $s\leftrightarrow 2-s$. $\square$

**Definition 8 (Point count via eigenvalues).** $N_n := \#E(\mathbb{F}_{p^n}) = p^n + 1 - (\alpha^n+\beta^n)$.

The normalizations $N_0=0$ in the eigenvalue convention and $N_1 = p+1-a_p$ are verified, and the Hasse deviation bound $\lVert N_1-(p+1)\rVert\le 2\sqrt p$ follows from Theorem 6.

---

## 3. The Frobenius trace recurrence, the point-count tower, and the Sato–Tate angle

Let $s_n := \alpha^n+\beta^n$ be the $n$-th power sum of the Frobenius eigenvalues — the trace of the $n$-th power of Frobenius.

**Theorem 9 (Newton's recurrence for power sums).** For $\alpha,\beta\in\mathbb{C}$ with $\alpha+\beta=a$ and $\alpha\beta=p$, and all $n\in\mathbb{N}$,
$$\alpha^{n+2}+\beta^{n+2} = a(\alpha^{n+1}+\beta^{n+1}) - p(\alpha^n+\beta^n).$$
*Proof sketch.* After substituting $a=\alpha+\beta$, $p=\alpha\beta$, both sides are equal polynomials in $\alpha,\beta$; the identity reduces to $\operatorname{ring}$. $\square$

**Definition 10 (Frobenius trace sequence).** Define $\operatorname{traceSeq}_{a,p}:\mathbb{N}\to\mathbb{C}$ by
$$s_0 = 2,\quad s_1 = a,\quad s_{n+2} = a\,s_{n+1} - p\,s_n.$$
The calibration $s_0=2$ (not $1$) is forced by $\alpha^0+\beta^0=2$ and is the classic off-by-one in Newton's identities.

**Theorem 11 (Trace sequence computes power sums).** If $\alpha+\beta=a$ and $\alpha\beta=p$, then for all $n$,
$$\operatorname{traceSeq}_{a,p}(n) = \alpha^n + \beta^n.$$
*Proof sketch.* Two-step induction. Base cases: $s_0=2=\alpha^0+\beta^0$ and $s_1=a=\alpha+\beta$. Inductive step: by definition $s_{n+2}=a\,s_{n+1}-p\,s_n$, and applying the inductive hypotheses to $s_{n+1},s_n$ and then Theorem 9 yields $\alpha^{n+2}+\beta^{n+2}$. $\square$

**Definition 12 (Trace-sequence point count).** $N_n := p^n + 1 - \operatorname{traceSeq}_{a,p}(n)$. By Theorem 11 this agrees with Definition 8, so the *entire tower* $\{N_n\}$ is determined by the single datum $a_p$ together with $p$, via a second-order linear recurrence with constant coefficients. The boundary values $N_0=0$ and $N_1=p+1-a$ are verified.

This rigidity is the computational engine of the local zeta function: the generating series $\exp\!\big(\sum_{n\ge 1} N_n T^n/n\big)$ is the rational zeta function $\dfrac{1-a_pT+pT^2}{(1-T)(1-pT)}$, whose numerator is precisely $L_p(T)$.

**Theorem 13 (Sato–Tate angle).** If $0<p$ and $a^2\le 4p$, there exists $\theta\in[0,\pi]$ with
$$a = 2\sqrt p\,\cos\theta.$$
*Proof sketch.* Take $\theta = \arccos\!\big(a/(2\sqrt p)\big)$; the Hasse bound places $a/(2\sqrt p)\in[-1,1]$, the domain of $\arccos$, so $\theta\in[0,\pi]$ and $\cos\theta = a/(2\sqrt p)$, giving the claim after clearing $2\sqrt p>0$. $\square$

The angle $\theta$ is the coordinate of the Sato–Tate conjecture: as $p$ varies, the angles $\theta_p$ equidistribute with respect to $\frac{2}{\pi}\sin^2\theta\,d\theta$.

**Theorem 14 (Archimedean / RH bound on power sums).** If $\lVert\alpha\rVert = \lVert\beta\rVert = \sqrt p$, then for all $n$,
$$\lVert\alpha^n+\beta^n\rVert \le 2(\sqrt p)^n.$$
*Proof sketch.* Triangle inequality then multiplicativity of the norm under powers: $\lVert\alpha^n+\beta^n\rVert\le\lVert\alpha\rVert^n+\lVert\beta\rVert^n = 2(\sqrt p)^n$. This uses only the RH input $\lVert\alpha\rVert=\lVert\beta\rVert=\sqrt p$, not the algebraic Vieta relations, so it is the genuinely analytic half; it holds for all $n$ including $n=0$ ($2\le 2$). $\square$

---

## 4. Analytic rank and the calculus of orders of vanishing

**Definition 17 (Analytic rank).** For $L:\mathbb{C}\to\mathbb{C}$ analytic at $s_0$, the analytic rank is the order of vanishing
$$\operatorname{analyticRank}(L,s_0) := \operatorname{ord}_{s_0}L \in \mathbb{N},$$
formalized as the natural-number order of vanishing at $s_0$. For BSD, $s_0=1$.

**Theorem 18 (Rank-zero detection).** If $L$ is analytic at $s_0$ and does not vanish identically near $s_0$ (the order is finite), then
$$\operatorname{analyticRank}(L,s_0)=0 \iff L(s_0)\neq 0.$$
**Theorem 19 (Positive-rank detection).** Under the same hypotheses,
$$0 < \operatorname{analyticRank}(L,s_0) \iff L(s_0)=0.$$
*Proof sketch.* The order of vanishing is $0$ exactly when $L(s_0)\ne0$, given finiteness (which rules out the degenerate $\operatorname{ord}=\infty$, whose truncation to $\mathbb{N}$ would also be $0$). Theorem 19 is the contrapositive. $\square$

**Theorem 20 (Leading-term factorization).** If $L$ is analytic at $s_0$ with finite order $r=\operatorname{analyticRank}(L,s_0)$, there is $g$ analytic at $s_0$ with $g(s_0)\neq 0$ and, in a neighborhood of $s_0$,
$$L(z) = (z-s_0)^r\, g(z).$$
*Proof sketch.* This is the defining property of the natural-number order of vanishing: $\operatorname{ord}_{s_0}L=r$ iff such a factorization with nonvanishing $g(s_0)$ exists. The nonzero value $g(s_0)$ is the leading Taylor coefficient predicted by the refined BSD formula. $\square$

**Theorem 21 (Additivity under products).** For $f,g$ analytic at $s_0$ of finite order,
$$\operatorname{analyticRank}(fg,s_0) = \operatorname{analyticRank}(f,s_0) + \operatorname{analyticRank}(g,s_0).$$
*Proof sketch.* Orders of vanishing add under multiplication of analytic germs. This is the analytic shadow of the Artin/Rankin–Selberg factorization of $L$-functions under products of abelian varieties or isogeny splittings. $\square$

**Non-vacuity (model $L$-function).** Define $\operatorname{modelL}_{r,c}(s) = (s-1)^r\, c$. It is analytic everywhere, and for $c\neq 0$ its analytic rank at $s=1$ is exactly $r$, with central value vanishing iff $r\ge 1$. Hence the analytic-rank invariant is surjective onto $\mathbb{N}$ and not secretly constant.

---

## 5. The functional equation, the sign, and the parity theorem

The completed $L$-function $\Lambda(E,s)=N^{s/2}(2\pi)^{-s}\Gamma(s)L(E,s)$ satisfies
$$\Lambda(E,2-s) = w(E)\,\Lambda(E,s), \qquad w(E)\in\{+1,-1\},$$
with $w(E)$ the global root number. We abstract the analytic mechanism.

**Theorem 15 (Parity theorem).** Let $\Lambda$ be analytic at the central point $s=1$ with finite order of vanishing, and suppose $\Lambda(2-s)=w\,\Lambda(s)$ with $w\in\{+1,-1\}$. Then
$$(-1)^{\operatorname{ord}_{s=1}\Lambda} = w.$$
*Proof sketch.* Use the leading-term factorization (Theorem 20): near $1$, $\Lambda(z)=(z-1)^r g(z)$ with $g(1)\ne0$, where $r=\operatorname{ord}_{s=1}\Lambda$. The reflection $z\mapsto 2-z$ sends $z-1\mapsto -(z-1)$, so on a punctured neighborhood of $1$,
$$\Lambda(2-z) = (-(z-1))^r g(2-z) = (-1)^r (z-1)^r g(2-z).$$
The functional equation equates this with $w\,(z-1)^r g(z)$. Cancelling $(z-1)^r$ and letting $z\to 1$ gives $(-1)^r g(1) = w\,g(1)$; since $g(1)\ne0$, $(-1)^r = w$. Equivalently, in Taylor coefficients $c_k$ of $\Lambda$ at $1$, the symmetry forces $(-1)^k c_k = w\,c_k$; on the lowest nonvanishing $c_r$ this is exactly $(-1)^r=w$. $\square$

**Corollary 16 (Sign dichotomy).** Under the hypotheses of Theorem 15:
- if $w=-1$ then $\operatorname{ord}_{s=1}\Lambda$ is odd, hence $\ge 1$, so $\Lambda(1)=0$ (central vanishing);
- the order of vanishing is even if and only if $w=+1$.

**Non-vacuity.** The model $\Lambda(s)=(s-1)^r c$ satisfies the functional equation with sign $(-1)^r$, exhibiting both parities and confirming the framework is not empty.

Through BSD's rank equality, Theorem 15 becomes the **Parity Conjecture**: $(-1)^{r_{\mathrm{alg}}}=w(E)$; and root number $-1$ predicts $r_{\mathrm{alg}}\ge1$, i.e. infinitely many rational points.

---

## 6. The rank bridge: analytic ⇔ algebraic

Model the Mordell–Weil group as $E(\mathbb{Q})\cong\mathbb{Z}^r\times T$ with $T$ finite (and nonempty, since the point at infinity $O$ always lies in it).

**Theorem 22 (Mordell–Weil infinitude criterion).** For $r\in\mathbb{N}$ and $T$ a finite nonempty type,
$$\big(\mathbb{Z}^r\times T\big)\ \text{is infinite} \iff r>0.$$
*Proof sketch.* If $r=0$ the group is $\{*\}\times T$, finite. If $r\ge1$, pick a coordinate $i$ and inject $\mathbb{Z}\hookrightarrow\mathbb{Z}^r\times T$ by $n\mapsto(n e_i, t_0)$; injectivity follows by reading off coordinate $i$, so the group is infinite. $\square$

**Theorem 23 (Local positivity, from Hasse).** For $p>1$ of good reduction with $a^2\le 4p$,
$$0 < p+1-a = \#E(\mathbb{F}_p).$$
*Proof sketch.* By Theorem 6, $a\le|a|\le 2\sqrt p$. Since $p>1$ gives $\sqrt p>1$, we have $2\sqrt p < p+1$ (as $(\sqrt p-1)^2>0$), hence $a<p+1$. So the local Euler factor never trivializes the global $L$-function. $\square$

**Theorem 24 (Qualitative BSD bridge).** Let $L$ be analytic at $1$ with finite order, and assume the BSD rank equality $\operatorname{analyticRank}(L,1)=r$ where $r$ is the free rank of $E(\mathbb{Q})\cong\mathbb{Z}^r\times T$. Then
$$L(1)=0 \iff E(\mathbb{Q})\ \text{is infinite}.$$
*Proof sketch.* By Theorem 19, $L(1)=0 \iff \operatorname{analyticRank}(L,1)>0$; substitute the rank equality to get $r>0$; by Theorem 22 this is equivalent to $E(\mathbb{Q})$ being infinite. $\square$

**Corollary 25 (Rank-zero form).** Under the same hypotheses, $L(1)\neq 0 \iff E(\mathbb{Q})$ is finite.

**Non-vacuity.** For each target rank $r$ and $c\neq0$, the model $\operatorname{modelL}_{r,c}$ satisfies the rank-equality hypothesis with algebraic rank $r$, so the bridge applies across genuinely distinct ranks, not a single degenerate case.

---

## 7. Applications

1. **Computing point-count towers from one datum.** Theorems 9–12 reduce the infinite family $\{\#E(\mathbb{F}_{p^n})\}_n$ to a two-term recurrence seeded by $(a_p,p)$. This is the practical route to local zeta functions and to the partial Euler products that approximate $L(E,s)$.
2. **Detecting positive rank from the sign.** Corollary 16 plus Theorem 24 means a root number computation $w(E)=-1$ already forces (under BSD) infinitely many rational points — without any point search. This is the engine behind heuristics for rank in large databases of curves.
3. **Sato–Tate statistics.** Theorem 13 furnishes the angle coordinate $\theta_p=\arccos(a_p/2\sqrt p)$ in which the distribution of traces is studied; the norm bound (Theorem 14) is the uniform control that makes the limiting measure well defined.
4. **Stability of $L$-data under products/isogeny.** Theorem 21 (additivity) is the analytic counterpart of how ranks behave under isogeny and Weil restriction; combined with multiplicativity of root numbers it controls parity across products.

---

## 8. Discussion and future work

The modules verified here are deliberately the *load-bearing* and *unconditional* parts of the BSD circle of ideas: the RH/Hasse equivalence, the Vieta and recurrence structure, the Sato–Tate angle, the order-of-vanishing calculus, and the parity theorem are all proved outright; only the bridge theorems are stated *conditionally* on the BSD rank equality, exactly as the mathematics demands. Four concrete directions extend the work.

**Conjecture 1 — Full Taylor reflection.** Strengthen the parity theorem: if $\Lambda$ is analytic at $1$, of finite order, and $\Lambda(2-s)=w\,\Lambda(s)$, then *every* Taylor coefficient obeys $c_k=(-1)^k w\,c_k$, so the expansion at the center is supported on a single parity $k\equiv\operatorname{ord}\ (\mathrm{mod}\ 2)$. Test: formalize $\frac{d^k}{ds^k}\Lambda(1)=(-1)^k w\,\frac{d^k}{ds^k}\Lambda(1)$ and deduce leading-coefficient sign/reality constraints.

**Conjecture 2 — Multiplicativity of root numbers.** If $\Lambda_1(2-s)=w_1\Lambda_1(s)$ and $\Lambda_2(2-s)=w_2\Lambda_2(s)$ then $(\Lambda_1\Lambda_2)(2-s)=(w_1w_2)(\Lambda_1\Lambda_2)(s)$; combined with additivity of orders (Theorem 21) this gives $(-1)^{\operatorname{ord}(\Lambda_1\Lambda_2)}=w_1w_2$, the analytic shadow of BSD data under isogeny and Weil restriction.

**Conjecture 3 — The Hasse interval is exactly attained.** The angle map $a\mapsto\arccos(a/2\sqrt p)$ is injective and order-reversing on $[-2\sqrt p,2\sqrt p]$, and $\#\{a:a^2\le4p\}$ grows like $4\sqrt p$; the measure-theoretic limit (Sato–Tate equidistribution for $\frac2\pi\sin^2\theta\,d\theta$) is the long-range target.

**Conjecture 4 — Positivity and integrality of the point counts.** Formalize that $\operatorname{traceSeq}_{a,p}(n)\in\mathbb{Z}$ and $N_n=p^n+1-s_n>0$ for all $n$ when $(a,p)$ comes from a genuine curve, completing the bridge between the recurrence and the geometric point counts.

---

## Appendix: Index of formalized results

| # | Name | Statement |
|---|------|-----------|
| 1 | `localFactor` | $L_p(T)=1-a_pT+pT^2$ |
| 2 | `frobeniusPoly` | $X^2-a_pX+p$ |
| 3 | `frobenius_normSq_eq_iff` | $\|z\|^2=p \iff a^2\le4p$ |
| 4 | `frobenius_root_prod` | $z w=p$ |
| 5 | `frobenius_root_sum` | $z+w=a$ |
| 6 | `hasse_bound` | $a^2\le4p\Rightarrow|a|\le2\sqrt p$ |
| 7 | `localFactor_functional_equation` | $L_p(T)=pT^2L_p(1/(pT))$ |
| 8 | `pointCount` (local) | $p^n+1-(\alpha^n+\beta^n)$ |
| 9 | `power_sum_recurrence` | $s_{n+2}=a s_{n+1}-p s_n$ |
| 10 | `traceSeq` | $s_0=2,s_1=a$, recurrence |
| 11 | `traceSeq_eq_power_sum` | $\operatorname{traceSeq}=\alpha^n+\beta^n$ |
| 12 | `pointCount` (trace) | $p^n+1-\operatorname{traceSeq}$ |
| 13 | `exists_satoTate_angle` | $a=2\sqrt p\cos\theta,\ \theta\in[0,\pi]$ |
| 14 | `traceSeq_norm_le` | $\|\alpha^n+\beta^n\|\le2(\sqrt p)^n$ |
| 15 | parity theorem | $(-1)^{\operatorname{ord}}=w$ |
| 16 | sign dichotomy | $w=-1\Rightarrow\Lambda(1)=0$ |
| 17 | `analyticRank` | $\operatorname{ord}_{s_0}L$ |
| 18 | `analyticRank_eq_zero_iff` | rank $0\iff L(s_0)\ne0$ |
| 19 | `analyticRank_pos_iff` | rank $>0\iff L(s_0)=0$ |
| 20 | `analyticRank_factorization` | $L=(z-s_0)^r g$, $g(s_0)\ne0$ |
| 21 | `analyticRank_mul` | rank adds under products |
| 22 | `mordellWeil_infinite_iff` | $\mathbb{Z}^r\times T$ infinite $\iff r>0$ |
| 23 | `hasse_point_count_pos` | $0<p+1-a$ |
| 24 | `bsd_central_vanishing_iff_infinite` | $L(1)=0\iff E(\mathbb{Q})$ infinite |
| 25 | `bsd_nonvanishing_iff_finite` | $L(1)\ne0\iff E(\mathbb{Q})$ finite |
