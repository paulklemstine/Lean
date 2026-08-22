# Smooth Windows: The Weyl Relation, Sidelobe Suppression, and Gaussian Regularisation of Spectral Statistics

**Author:** Aristotle

**Date:** 2026-08-22

---

## Abstract

Spectral statistics built from a family of ordinates are traditionally computed through a *sharp
cutoff*: keep every ordinate with $|t| \le T$, discard the rest. We develop the systematic
replacement of this rectangular window by a smooth Gaussian (Schwartz-class) window, and we show
that the replacement preserves all of the relevant algebra while repairing four distinct defects
of the sharp cutoff.

Algebraically, we establish the modulation/translation identity — the Weyl commutation relation
$M_b T_a = \chi(ab) T_a M_b$ with $\chi(x) = e^{2\pi i x}$ — in three registers: as an operator
identity on functions $\mathbb{R}\to\mathbb{C}$; as the defining relation of a circle-valued
Heisenberg group $\mathbb{H}$ admitting a *faithful* Schrödinger representation
$(a,b,z)\mapsto z\,T_aM_b$, with the Gaussian as a separating test vector; and as an identity for
discrete spectral data under joint translation of ordinates and modulation of amplitudes.

Analytically, we quantify why the Gaussian is preferable. The rectangular transfer function
$\sin(2\pi T\xi)/(\pi\xi)$ has sidelobe peaks of exact height $4T/(\pi(2n+1))$ at
$\xi_n = (2n+1)/(4T)$, hence a *scale-invariant* normalised amplitude $\xi_n|\widehat{w}(\xi_n)| =
1/\pi$ and non-summable spurious energy. The Gaussian Gabor atom has transfer modulus
$s\,g_{1/s}(\xi-b)$: strictly unimodal, strictly monotone in $|\xi-b|$, decaying faster than every
power, and summable along the very frequencies at which the rectangular window leaks.

Consequences for spectral statistics: the Gaussian-windowed harmonic statistic of a nonempty
conjugate-paired family is strictly positive at every width (no false nulls), is continuous and
strictly monotone in the width (a genuine scale space) with the unwindowed statistic as its
wide-window limit, admits a closed-form two-ordinate Rayleigh resolution criterion arising from
the factorisation $(1-u)\bigl(w_1 - u(1+u+u^2)w_2\bigr)$, and — via the explicit Schwartz bound
$(t^2)^n g_s(t)\le (s^2/\pi)^n n!$ — converges on infinite ordinate families for which the
unwindowed statistic diverges.

**Keywords:** Gaussian window, Gabor atom, Weyl commutation relation, Heisenberg group,
Schrödinger representation, sidelobes, Dirichlet kernel, scale space, Rayleigh criterion,
Schwartz decay.

---

## 1. Introduction

### 1.1 The problem with sharp cutoffs

Let a *spectral family* be a multiset of real ordinates $t$, each carrying an amplitude. In the
motivating setting the ordinates are heights of zeros $\rho = \tfrac12 \pm it$ on a critical line
and the amplitudes are the reciprocals $1/\rho$; the quantity of interest is the
multiplicity-sensitive harmonic sum $H(Z) = \sum_{\rho\in Z}1/\rho$, and the computable
approximation is the finite-cutoff sum
$$\mathcal{S}_T(Z) \;=\; \sum_{\substack{\rho\in Z\\ |\operatorname{Im}\rho|\le T}} \frac{1}{\rho}.$$

The cutoff is an act of windowing whether one acknowledges it or not: it is the windowed sum
$\sum_\rho w(\operatorname{Im}\rho)/\rho$ with $w = \mathbf{1}_{[-T,T]}$. Once this is
acknowledged, $w$ becomes a free parameter, and the question is which $w$ is best.

The engineering literature has long known that sharp windows are bad windows, because of
*spectral leakage*: the transfer function $\widehat{w}$ of a discontinuous window has heavy
oscillatory tails that inject energy from distant frequencies into any local measurement. This
paper makes that folklore into a precise chain of theorems in the present setting, and — more
importantly — shows that nothing algebraic is lost in the replacement.

### 1.2 What must be preserved

A window is not a static object; it is slid along the axis and tuned to a frequency. The two
motions are translation and modulation, and their commutation relation is the algebraic backbone
of all time–frequency analysis. Any proposed window must interact with these operations exactly,
not approximately, or else no exact bookkeeping is possible. Section 2 establishes that the
relation in question is a group law: the Heisenberg group, acting faithfully, with the Gaussian as
a test vector strong enough to prove faithfulness single-handedly.

### 1.3 Organisation

Section 2 develops the operator algebra and the Heisenberg group. Section 3 introduces the
Gaussian window and its Fourier self-duality, and derives the sidelobe-free transfer function of
a Gabor atom. Section 4 gives the exact quantitative comparison with the Dirichlet kernel.
Section 5 transplants the machinery onto spectral statistics and proves the absence of false
nulls together with the discrete Weyl identity. Section 6 studies the width dependence (scale
space). Section 7 gives the Rayleigh criterion. Section 8 gives explicit Schwartz bounds and the
regularisation theorem. Section 9 discusses algorithms and applications, Section 10 the
limitations, and Section 11 open directions.

---

## 2. Translation, modulation, and the Heisenberg group

### 2.1 The character

**Definition 2.1.** For $x \in \mathbb{R}$ set $\chi(x) = e^{2\pi i x}$.

**Lemma 2.2.** $\chi(0)=1$, $\chi(x+y)=\chi(x)\chi(y)$, $|\chi(x)|=1$, $\chi(-x)=\chi(x)^{-1}$,
and
$$\chi(x) = 1 \iff x \in \mathbb{Z}.$$
In particular $\chi(1/4) = i \ne 1$.

*Proof sketch.* Additivity is the exponential law. The kernel computation is the standard
characterisation $e^{z}=1 \iff z \in 2\pi i \mathbb{Z}$, applied after cancelling the factor $i$
and dividing by $2\pi$. The last claim follows because $4n = 1$ has no integer solution. $\square$

The quarter-period fact $\chi(1/4)\ne 1$ is small but load-bearing: it is the separating input in
both Theorem 2.8 (the phase is unremovable) and Theorem 2.12 (faithfulness).

### 2.2 The two motions

**Definition 2.3.** For $a,b \in \mathbb{R}$ and $f:\mathbb{R}\to\mathbb{C}$ define the
**translation** and **modulation** operators
$$(T_a f)(t) = f(t-a), \qquad (M_b f)(t) = \chi(bt)\,f(t) = e^{2\pi i bt} f(t).$$

**Lemma 2.4 (separate group laws).** $T_0 = M_0 = \mathrm{id}$, and
$$T_a T_{a'} = T_{a+a'}, \qquad M_b M_{b'} = M_{b+b'} .$$
Both families are $\mathbb{C}$-linear in the window: $T_a(f+g)=T_af+T_ag$ and
$M_b(f+g)=M_bf+M_bg$.

*Proof sketch.* Pointwise: $f((t-a)-a') = f(t-(a+a'))$ and $\chi(bt)\chi(b't)=\chi((b+b')t)$.
$\square$

Separately, each family is a copy of $(\mathbb{R},+)$. Jointly, they are not.

### 2.3 The Weyl commutation relation

**Theorem 2.5 (modulation/translation identity).** For all $a,b\in\mathbb{R}$ and all
$f:\mathbb{R}\to\mathbb{C}$,
$$M_b T_a f \;=\; \chi(ab)\; T_a M_b f .$$

*Proof sketch.* Evaluate both sides at $t$. The left side is $\chi(bt) f(t-a)$; the right side is
$\chi(ba)\chi(b(t-a))f(t-a)$. Additivity of $\chi$ gives $\chi(ba)\chi(bt-ba)=\chi(bt)$. $\square$

**Corollary 2.6 (reversed form).** $T_a M_b f = \chi(-ab)\, M_b T_a f$.

**Remark 2.7.** The identity says the two motions commute *projectively*: as operators on
one-dimensional subspaces they commute, but as operators on functions they do not. The
obstruction is a $\mathrm{U}(1)$-valued cocycle.

**Theorem 2.8 (the phase is not removable).** Let $f$ satisfy $f(0)\ne 0$. Then
$$M_{1/2} T_{1/2} f \;\ne\; T_{1/2} M_{1/2} f .$$

*Proof sketch.* Evaluate at $t = 1/2$. The left side is $\chi(1/4) f(0)$, the right side is
$\chi(0) f(0) = f(0)$. Equality would force $\chi(1/4)=1$, contradicting Lemma 2.2. $\square$

Theorem 2.8 is included precisely because it shows Theorem 2.5 is not a triviality: no
renormalisation of $T$ and $M$ by scalars can make the composites agree, since the discrepancy is
visible on a single fixed window at a single point.

### 2.4 The Heisenberg group

**Definition 2.9.** Let $\mathbb{H}$ be the set of triples $(a,b,z)$ with $a,b\in\mathbb{R}$ and
$z$ in the unit circle $\mathbb{T}\subset\mathbb{C}^\times$, with multiplication
$$(a,b,z)\cdot(a',b',z') = \bigl(a+a',\; b+b',\; z z'\,\chi(b a')\bigr),$$
unit $(0,0,1)$, and inverse
$$(a,b,z)^{-1} = \bigl(-a,\,-b,\; z^{-1}\chi(ba)\bigr).$$

**Theorem 2.10.** $\mathbb{H}$ is a group.

*Proof sketch.* All axioms reduce to statements about the phase coordinate. Associativity is
equivalent to the 2-cocycle identity
$$b a' + (b+b')a'' \;=\; b' a'' + b(a'+a''),$$
which is a polynomial identity in $b,b',a',a''$; the identity and inverse axioms reduce to
$\chi(ba)\chi(-ba)=1$. $\square$

The middle coordinate of the product picks up the phase generated by commuting the modulation of
the *left* factor past the translation of the *right* factor — the Weyl phase of Theorem 2.5,
promoted to a group law.

### 2.5 The Schrödinger (Gabor) representation

**Definition 2.11.** For $g = (a,b,z) \in \mathbb{H}$ define the operator
$$\pi(g) f \;=\; z\; T_a M_b f, \qquad \text{i.e.}\qquad (\pi(g)f)(t) = z\,\chi\bigl(b(t-a)\bigr)\,f(t-a).$$

**Theorem 2.12 (representation property).** $\pi(1) = \mathrm{id}$ and
$$\pi(g h) = \pi(g)\,\pi(h) \qquad \text{for all } g,h\in\mathbb{H},$$
so $\pi$ is a monoid homomorphism into the endomorphisms of the space of windows; each $\pi(g)$
is invertible with $\pi(g)^{-1} = \pi(g^{-1})$.

*Proof sketch.* Expand both sides at $t$. Writing $g=(a,b,z)$, $h=(a',b',z')$, the left side
carries the phase $zz'\chi(ba')\chi\bigl((b+b')(t-a-a')\bigr)$ and the right side
$z\chi(b(t-a))\,z'\chi\bigl(b'((t-a)-a')\bigr)$. The identity
$$\chi\bigl((b+b')(t-a-a')\bigr) = \chi\bigl(b(t-a)\bigr)\,\chi\bigl(b'((t-a)-a')\bigr)\,\chi(ba')^{-1}$$
follows from additivity of $\chi$ after expanding the arguments; the leftover $\chi(ba')$ is
exactly the cocycle inserted by Definition 2.9. $\square$

**Theorem 2.13 (faithfulness).** $\pi$ is injective. Indeed, if $\pi(g)$ fixes the single Gaussian
window $\gamma(t)=e^{-t^2}$, then $g = 1$.

*Proof sketch.* Suppose $\pi(g)\gamma = \gamma$ with $g = (a,b,z)$.

1. **Position.** Taking absolute values kills $z$ and $\chi$, leaving $e^{-(t-a)^2} = e^{-t^2}$
   for all $t$. Evaluating at $t=0$ and $t=a$ and comparing exponents gives $a^2 = 0$, so $a=0$.
   (This uses that the Gaussian is nowhere zero and has a unique maximum.)
2. **Phase.** With $a=0$ the identity reads $z\,\chi(bt)\gamma(t) = \gamma(t)$; since
   $\gamma(t)\ne0$ we may cancel, obtaining $z\,\chi(bt)=1$ for all $t$. At $t=0$ this gives
   $z=1$.
3. **Frequency.** Hence $\chi(bt)=1$ for all $t$. If $b\ne0$, take $t = 1/(4b)$ to get
   $\chi(1/4)=1$, contradicting Lemma 2.2. So $b=0$. $\square$

Theorem 2.13 has a structural consequence: the central circle factor of $\mathbb{H}$ is not
redundant, i.e. the Weyl cocycle $\chi(ba')$ is not a coboundary. There is no way to rescale the
operators $T_a M_b$ so as to obtain an honest representation of $\mathbb{R}^2$. Note also that a
*single* Gaussian suffices as a test vector — a first indication that the Gaussian is the natural
window in this representation-theoretic sense, before any analysis is done.

---

## 3. The Gaussian window and Fourier self-duality

### 3.1 Definition and elementary properties

**Definition 3.1.** For $s>0$ the **Gaussian window** of width $s$ is
$$g_s(t) = e^{-\pi t^2/s^2}.$$

**Lemma 3.2.** $g_s > 0$ everywhere, $g_s(0)=1$, $g_s$ is even, $g_s \le 1$, and $g_s(t)<1$
whenever $t \ne 0$.

**Lemma 3.3 (closure under products of translates).** For $s\ne0$ and all $a,b,t$,
$$g_s(t-a)\,g_s(t-b) \;=\; e^{-\pi (a-b)^2/(2s^2)}\; g_{s/\sqrt2}\!\left(t - \frac{a+b}{2}\right).$$

*Proof sketch.* The polarisation identity
$(t-a)^2+(t-b)^2 = 2\bigl(t-\tfrac{a+b}{2}\bigr)^2 + \tfrac{(a-b)^2}{2}$, exponentiated. $\square$

Two Gaussian probes at different positions multiply to a *single* Gaussian probe at the midpoint,
with an exponentially small overlap constant. Nothing of the kind holds for rectangular windows,
whose products are again rectangular but with abruptly varying support.

**Lemma 3.4 (rapid decay).** For $s>0$ and every $n \in \mathbb{N}$,
$t^n g_s(t) \to 0$ as $t\to+\infty$.

*Proof sketch.* Substitute $u = \pi t^2/s^2$ and compare with $u^{n}e^{-u}\to0$. $\square$

### 3.2 Fourier intertwining

We use the normalisation $\widehat{f}(\xi) = \int_{\mathbb{R}} e^{-2\pi i \xi t} f(t)\,dt$.

**Theorem 3.5 (translation becomes modulation).** For all $a$, $f$, $\xi$,
$$\widehat{T_a f}(\xi) = \chi(-a\xi)\,\widehat{f}(\xi).$$

**Theorem 3.6 (modulation becomes translation).** For all $b$, $f$, $\xi$,
$$\widehat{M_b f}(\xi) = \widehat{f}(\xi - b) = \bigl(T_b \widehat{f}\bigr)(\xi).$$

*Proof sketch.* Both are changes of variable inside the defining integral: in the first case the
translation invariance of Lebesgue measure produces the phase $\chi(-a\xi)$ as a constant factor;
in the second the extra factor $\chi(bt)$ merges with $e^{-2\pi i \xi t}$ into
$e^{-2\pi i(\xi-b)t}$. Notably, both identities hold with no integrability hypotheses beyond those
implicit in the definition of the integral, since they are equalities between integrals of
pointwise-equal integrands. $\square$

Together with Theorem 2.5 these are the modulation/translation identity on the frequency side:
the Fourier transform intertwines the Schrödinger representation with the representation obtained
by exchanging the roles of $a$ and $b$, which is the metaplectic reflection of the phase plane.

### 3.3 Self-duality with width inversion

**Theorem 3.7.** For $s>0$,
$$\widehat{g_s} = s\, g_{1/s}, \qquad\text{i.e.}\qquad \widehat{g_s}(\xi) = s\,e^{-\pi s^2\xi^2}.$$

*Proof sketch.* Write $g_s(t) = e^{-\pi b t^2}$ with $b = 1/s^2 > 0$ and apply the classical
Gaussian Fourier formula $\widehat{e^{-\pi b t^2}} = b^{-1/2} e^{-\pi \xi^2/b}$, identifying the
complex power $b^{-1/2}$ with the positive real square root $s$. $\square$

The Gaussian family is a *fixed family* of the Fourier transform, with the width inverted. This
is the uncertainty trade-off written as an identity: no member of the family can be narrow in both
variables, and the product of the two widths is pinned at $1$.

### 3.4 Gabor atoms and the absence of sidelobes

**Definition 3.8.** The **Gabor atom** at phase-space point $(a,b)$ with width $s$ is
$$\gamma_{s,a,b} = T_a M_b g_s, \qquad \gamma_{s,a,b}(t) = \chi\bigl(b(t-a)\bigr)\,g_s(t-a).$$

**Theorem 3.9 (Heisenberg covariance).** For $g=(a_0,b_0,z_0)\in\mathbb{H}$,
$$\pi(g)\,\gamma_{s,a,b} \;=\; z_0\,\chi(b_0 a)\;\gamma_{s,\,a_0+a,\;b_0+b}.$$

*Proof sketch.* $\gamma_{s,a,b} = \pi\bigl((a,b,1)\bigr)g_s$, so the claim is the representation
property of Theorem 2.12 together with the explicit product of Definition 2.9. $\square$

Thus the Heisenberg group permutes the Gaussian Gabor atoms, changing only a phase: the family of
smooth windows is a single group orbit.

**Theorem 3.10 (transfer function of a Gabor atom).** For $s>0$,
$$\widehat{\gamma_{s,a,b}}(\xi) \;=\; \chi(-a\xi)\; s\, g_{1/s}(\xi-b),
\qquad \bigl|\widehat{\gamma_{s,a,b}}(\xi)\bigr| \;=\; s\, g_{1/s}(\xi-b).$$

*Proof sketch.* Apply Theorem 3.5 to peel off $T_a$, Theorem 3.6 to convert $M_b$ into a
frequency shift, and Theorem 3.7 to evaluate $\widehat{g_s}$. Taking moduli kills the unimodular
factors. $\square$

**Corollary 3.11 (strict unimodality; no sidelobes).** For $s>0$ and $\xi\ne b$,
$$\bigl|\widehat{\gamma_{s,a,b}}(\xi)\bigr| < \bigl|\widehat{\gamma_{s,a,b}}(b)\bigr| = s,$$
and more strongly, if $|\xi - b| < |\eta - b|$ then
$$\bigl|\widehat{\gamma_{s,a,b}}(\eta)\bigr| < \bigl|\widehat{\gamma_{s,a,b}}(\xi)\bigr| .$$

*Proof sketch.* Both follow from $g_{1/s}$ being a strictly decreasing function of the square of
its argument, by Lemma 3.2 and monotonicity of $\exp$. $\square$

The response of a Gaussian probe is a single monotone lobe: there is no frequency at which the
window itself creates a local maximum.

---

## 4. The Dirichlet kernel: exact sidelobes of the sharp cutoff

### 4.1 The transfer function

**Definition 4.1.** The **rectangular window** of half-width $T \ge 0$ is
$\mathbf{1}_{[-T,T]}$.

**Theorem 4.2 (Dirichlet transfer function).** For $T\ge0$ and $\xi \ne 0$,
$$\widehat{\mathbf{1}_{[-T,T]}}(\xi) \;=\; \frac{\sin(2\pi T\xi)}{\pi \xi},
\qquad\text{hence}\qquad
\bigl|\widehat{\mathbf{1}_{[-T,T]}}(\xi)\bigr| = \frac{|\sin(2\pi T\xi)|}{\pi|\xi|}.$$

*Proof sketch.* The indicator integral is the interval integral
$\int_{-T}^{T} e^{-2\pi i \xi t}\,dt$, which evaluates to
$\bigl(e^{-2\pi i \xi T} - e^{2\pi i \xi T}\bigr)/(-2\pi i \xi)$; Euler's formula converts this to
$\sin(2\pi T\xi)/(\pi\xi)$. The hypothesis $\xi\ne0$ is essential: at $\xi=0$ the value is $2T$.
$\square$

### 4.2 Exact sidelobe amplitudes

**Definition 4.3.** The $n$-th **sidelobe frequency** of the window of half-width $T>0$ is
$$\xi_n = \frac{2n+1}{4T}, \qquad n=0,1,2,\dots$$
At these frequencies $\sin(2\pi T\xi_n) = \sin\bigl((2n+1)\pi/2\bigr) = \pm1$, so
$|\sin(2\pi T\xi_n)| = 1$.

**Theorem 4.4 (exact peak heights).** For $T>0$ and all $n$,
$$\bigl|\widehat{\mathbf{1}_{[-T,T]}}(\xi_n)\bigr| \;=\; \frac{4T}{\pi(2n+1)} .$$

**Theorem 4.5 (scale-invariant leakage).** For $T>0$ and all $n$,
$$\xi_n \cdot \bigl|\widehat{\mathbf{1}_{[-T,T]}}(\xi_n)\bigr| \;=\; \frac{1}{\pi}.$$

*Proof sketch.* Substitute Theorem 4.4 and Definition 4.3 and simplify: the factors $4T$ and
$2n+1$ cancel identically. $\square$

The constant $1/\pi$ depends on neither $n$ nor $T$. This single equation is the quantitative
core of the case against sharp cutoffs.

**Theorem 4.6 (leakage is not negligible).** For $T>0$, the function
$\xi \mapsto \xi\,\bigl|\widehat{\mathbf{1}_{[-T,T]}}(\xi)\bigr|$ does **not** tend to $0$ as
$\xi\to+\infty$. Consequently no bound of the form
$\bigl|\widehat{\mathbf{1}_{[-T,T]}}(\xi)\bigr| = o(1/\xi)$ holds.

*Proof sketch.* $\xi_n \to \infty$, and along that sequence the function is constantly $1/\pi \ne
0$ by Theorem 4.5. $\square$

**Theorem 4.7 (infinite spurious energy).** For $T>0$, the sequence of sidelobe amplitudes
$\bigl|\widehat{\mathbf{1}_{[-T,T]}}(\xi_n)\bigr|_{n\ge0}$ is **not summable**.

*Proof sketch.* By Theorem 4.4 the terms are $\tfrac{4T}{\pi}\cdot\tfrac{1}{2n+1}$, a constant
multiple of the odd harmonic series; comparison with $\sum 1/(n+1)$ gives divergence. $\square$

### 4.3 Comparison

**Theorem 4.8 (rapid decay of the Gaussian transfer function).** For $s>0$, any $a$, and every
$n \in \mathbb{N}$,
$$\xi^n\,\bigl|\widehat{\gamma_{s,a,0}}(\xi)\bigr| \longrightarrow 0 \qquad (\xi \to +\infty).$$

*Proof sketch.* By Theorem 3.10 the modulus is $s\,g_{1/s}(\xi)$; apply Lemma 3.4. $\square$

**Theorem 4.9 (sidelobe suppression).** For all $T>0$, $s>0$ and any $a$, for all sufficiently
large $n$,
$$\bigl|\widehat{\gamma_{s,a,0}}(\xi_n)\bigr| \;<\; \bigl|\widehat{\mathbf{1}_{[-T,T]}}(\xi_n)\bigr| .$$

*Proof sketch.* By Theorem 4.8 with $n=1$, $\xi\,|\widehat{\gamma_{s,a,0}}(\xi)| \to 0$, so
eventually along $\xi_n \to \infty$ it is $< 1/\pi$. But by Theorem 4.5 the corresponding
rectangular quantity is *exactly* $1/\pi$. Dividing by $\xi_n>0$ gives the claim. $\square$

Note that the conclusion is an eventual **strict inequality** along an explicit sequence of
frequencies, valid for *every* pair of widths, rather than an asymptotic order relation. There is
no choice of $T$ that rescues the sharp window.

**Theorem 4.10 (finite spurious energy of the Gaussian).** For all $T,s>0$ and any $a$, the
sequence $\bigl|\widehat{\gamma_{s,a,0}}(\xi_n)\bigr|_{n\ge0}$ is summable.

*Proof sketch.* By Theorem 4.8 with $n=2$, eventually $\xi_n^2|\widehat{\gamma_{s,a,0}}(\xi_n)| <
1$, i.e. the terms are eventually at most $\xi_n^{-2} = 16T^2/(2n+1)^2$, which is summable.
$\square$

Thus the two windows are separated by three inequivalent criteria — strict unimodality
(Corollary 3.11), rapid decay (Theorem 4.8), and summability of peak amplitudes
(Theorems 4.7, 4.10). The rectangular window fails all three; the Gaussian satisfies all three.

---

## 5. Windowed spectral statistics and the discrete Weyl identity

### 5.1 Windowed sums

**Definition 5.1.** For a window $w:\mathbb{R}\to\mathbb{C}$ and a multiset $Z$ of nonzero complex
numbers, the **windowed harmonic sum** is
$$S_w(Z) \;=\; \sum_{\rho\in Z} \frac{w(\operatorname{Im}\rho)}{\rho},$$
counted with multiplicity.

**Lemma 5.2.** $S_w$ is additive in $Z$ and linear in $w$: $S_w(Y \uplus Z)=S_w(Y)+S_w(Z)$ and
$S_{w+v}(Z)=S_w(Z)+S_v(Z)$.

**Proposition 5.3 (the sharp cutoff is the rectangular case).** For every $T$ and $Z$,
$$S_{\mathbf{1}_{[-T,T]}}(Z) \;=\; \sum_{\substack{\rho \in Z \\ |\operatorname{Im}\rho|\le T}} \frac1\rho .$$

*Proof sketch.* Induction on $Z$: each term contributes $1\cdot\rho^{-1}$ or $0$ according to the
membership test $|\operatorname{Im}\rho|\le T$, which is exactly the filter defining the cutoff.
$\square$

Everything that follows is therefore a strict generalisation of the classical statistic, not a
different object.

### 5.2 Conjugate-paired families

**Definition 5.4.** For a multiset $S$ of real ordinates let $P(S)$ be the conjugate-paired family
consisting of $\tfrac12+it$ and $\tfrac12-it$ for each $t\in S$.

**Theorem 5.5 (paired collapse under a smooth window).** For every $s$,
$$S_{g_s}\bigl(P(S)\bigr) \;=\; \sum_{t\in S} \frac{g_s(t)}{\tfrac14+t^2} \;\in\;\mathbb{R}.$$

*Proof sketch.* $\left(\tfrac12+it\right)^{-1} + \left(\tfrac12-it\right)^{-1} =
\frac{1}{\tfrac14+t^2}$, and $g_s$ is even and real, so the window factor is common to the pair.
Reality also follows abstractly: conjugating the multiset conjugates the sum, and a
conjugation-symmetric family is fixed. $\square$

**Theorem 5.6 (strict positivity).** If $S \ne \varnothing$ then for every width $s$,
$$\operatorname{Re} S_{g_s}\bigl(P(S)\bigr) \;>\; 0 .$$

*Proof sketch.* Every term $g_s(t)/(\tfrac14+t^2)$ is strictly positive, since $g_s>0$ and
$\tfrac14+t^2>0$; a sum of positive terms over a nonempty multiset dominates any one of them.
$\square$

**Theorem 5.7 (no false nulls).** $S_{g_s}\bigl(P(S)\bigr) = 0$ if and only if $S = \varnothing$,
for every width $s \ne 0$.

*Proof sketch.* Immediate from Theorem 5.6 in one direction and from the empty sum in the other.
$\square$

**Theorem 5.8 (the sharp contrast).** Let $t$ be an ordinate with $|t| > T$. Then the sharp cutoff
of half-width $T$ returns $0$ on the pair $P(\{t\})$, while the Gaussian statistic of *any* width
returns a nonzero (indeed strictly positive) value.

*Proof sketch.* The pair fails the membership test, so the filtered sum is empty; Theorem 5.7
supplies the other half. $\square$

The mechanism deserves emphasis. What removes false nulls is not smoothness but **strict
positivity of the window on the whole line**; what removes sidelobes is smoothness. These are two
independent defects of the sharp cutoff, and the Gaussian repairs both.

### 5.3 The discrete Gabor transform and the Weyl identity for data

**Definition 5.9.** *Spectral data* is a multiset $D$ of pairs $(t_j, c_j) \in \mathbb{R}\times
\mathbb{C}$. The **discrete Gabor transform** of $D$ with window $w$ at the phase-space point
$(a,b)$ is
$$G_w(D)(a,b) \;=\; \sum_j \chi(-b t_j)\, w(t_j - a)\, c_j .$$
A zero multiset $Z$ yields the data $\bigl(\operatorname{Im}\rho,\;\rho^{-1}\bigr)_{\rho\in Z}$.

**Proposition 5.10.** At the origin of phase space, $G_w(D)(0,0) = S_w(Z)$ for the data of $Z$:
the transform extends the windowed sum.

**Theorem 5.11 (translation of ordinates).** Let $D + c$ denote the data with every ordinate
shifted, $(t_j+c, c_j)$. Then
$$G_w(D+c)(a,b) \;=\; \chi(-bc)\; G_w(D)(a-c,\;b).$$

*Proof sketch.* $t_j + c - a = t_j - (a-c)$ handles the window argument; the character splits as
$\chi(-b(t_j+c)) = \chi(-bc)\chi(-bt_j)$, and the constant factors out of the sum. $\square$

**Theorem 5.12 (modulation of amplitudes).** Let $D^{(\eta)}$ denote the data with amplitudes
multiplied by $\chi(\eta t_j)$. Then
$$G_w\bigl(D^{(\eta)}\bigr)(a,b) \;=\; G_w(D)(a,\;b-\eta).$$

*Proof sketch.* $\chi(-bt_j)\chi(\eta t_j) = \chi(-(b-\eta)t_j)$. $\square$

**Theorem 5.13 (the Weyl identity for spectral data).** For all $a,b,c,\eta$,
$$G_w\bigl(D^{(\eta)} + c\bigr)(a,b) \;=\; \chi(-\eta c)\; G_w\bigl((D+c)^{(\eta)}\bigr)(a,b).$$

*Proof sketch.* Apply Theorems 5.11 and 5.12 in the two orders. One order produces the phase
$\chi(-bc)$ and the analysis point $(a-c, b-\eta)$; the other produces $\chi(-(b-\eta)c)$ at the
same point. The ratio of the phases is $\chi(-\eta c)$, by additivity of $\chi$ applied to
$-bc = -\eta c + \bigl(-(b-\eta)c\bigr)$. $\square$

This is the operator-level Weyl relation of Theorem 2.5, transported verbatim to discrete data:
translating the ordinates and modulating the amplitudes are *the same two motions*, and they fail
to commute by *the same phase*. Any implementation that shifts data and re-tunes the analysis
frequency must carry this factor or it will accumulate a systematic phase error.

---

## 6. Scale space: the width as a continuous parameter

**Definition 6.1.** The **Gaussian spectral profile** of a family $S$ of ordinates is
$$\Sigma(S,s) \;=\; \sum_{t\in S} \frac{g_s(t)}{\tfrac14+t^2} \;=\; \operatorname{Re} S_{g_s}\bigl(P(S)\bigr).$$

**Theorem 6.2 (monotonicity).** If $0 < s_1 \le s_2$ then $\Sigma(S,s_1) \le \Sigma(S,s_2)$.
If moreover $s_1 < s_2$ and $S$ contains some $t\ne0$, the inequality is strict.

*Proof sketch.* Termwise: $s_1 \le s_2$ implies $-\pi t^2/s_1^2 \le -\pi t^2/s_2^2$, so
$g_{s_1}(t) \le g_{s_2}(t)$, with strict inequality when $t\ne0$. Divide by the positive
denominators and sum; isolate the strict term. $\square$

**Theorem 6.3 (continuity).** $s \mapsto \Sigma(S,s)$ is continuous on $\{s \ne 0\}$.

*Proof sketch.* Each term is the composition of $s\mapsto -\pi t^2/s^2$ (continuous off $0$) with
$\exp$, divided by a nonzero constant; a finite sum of continuous functions is continuous.
$\square$

**Theorem 6.4 (the sharp cutoff is discontinuous).** For a single conjugate pair with ordinate
$t$, the map $T \mapsto \operatorname{Re}\mathcal{S}_T\bigl(P(\{t\})\bigr)$ is
**not** continuous at $T = |t|$: it equals $0$ for $T<|t|$ and $1/(\tfrac14+t^2)$ at $T=|t|$.

*Proof sketch.* Compute both one-sided values directly and observe that the left limit $0$
disagrees with the value $1/(\tfrac14+t^2) > 0$. $\square$

The jump has size exactly $1/(\tfrac14+t^2)$ — the same quantity that serves as detection
threshold in cutoff-based analyses. So the two windows do not differ in what they can *eventually*
see; they differ in the *regularity* with which they see it, and regularity is precisely what a
numerical peak finder needs.

**Theorem 6.5 (wide-window limit).** For every finite family $S$,
$$\lim_{s\to\infty} \Sigma(S,s) \;=\; \sum_{t\in S}\frac{1}{\tfrac14+t^2},$$
the unwindowed harmonic statistic of the paired family.

*Proof sketch.* $g_s(t) = e^{-\pi t^2/s^2} \to e^0 = 1$ as $s\to\infty$ for each fixed $t$; a
finite sum of convergent terms converges to the sum of the limits. $\square$

Hence the Gaussian statistic is a *deformation* of the classical one: a continuous, strictly
monotone one-parameter family running from "see nothing" as $s \to 0$ to "see everything" as
$s \to \infty$.

---

## 7. Peak localisation and a Rayleigh criterion

### 7.1 The position profile

**Definition 7.1.** The **position profile** of a family $S$ at width $s$ is
$$P_S(a) \;=\; \sum_{t\in S} \frac{g_s(t-a)}{\tfrac14+t^2},$$
the result of sliding the Gaussian window to position $a$.

**Proposition 7.2.** $P_S(a) = \operatorname{Re} G_{g_s}\bigl(\text{paired data of } S\bigr)(a,0)$
and $P_S(0) = \Sigma(S,s)$. The profile is a slice of the discrete Gabor transform of Section 5 at
frequency $0$, not a new object.

**Theorem 7.3 (unbiased localisation).** For a single ordinate $t$ and $s\ne0$, the profile
$P_{\{t\}}$ attains a strict global maximum exactly at $a = t$:
$$P_{\{t\}}(a) < P_{\{t\}}(t) \qquad\text{for all } a \ne t.$$

*Proof sketch.* $P_{\{t\}}(a) = g_s(t-a)/(\tfrac14+t^2)$, and $g_s(d) < 1 = g_s(0)$ for $d\ne0$.
$\square$

A Gaussian window never displaces a peak — a property that fails for asymmetric windows and is
only vacuously true for the rectangular window, whose profile is piecewise constant.

### 7.2 Scale doubling

**Lemma 7.4.** For all $s, d$:
$$g_s(d/2) = g_{2s}(d), \qquad g_s(d) = g_{2s}(d)^4 .$$

*Proof sketch.* $-\pi (d/2)^2/s^2 = -\pi d^2/(2s)^2$ and $-\pi d^2/s^2 = 4\cdot\bigl(-\pi
d^2/(2s)^2\bigr)$. $\square$

These two identities are what make the two-ordinate analysis a *polynomial* problem in a single
variable: for the Gaussian, the value at the midpoint and the value at the far ordinate are powers
of one common quantity. No other window family has this property.

### 7.3 The two-ordinate criterion

Fix distinct ordinates $t_1 \ne t_2$ and set
$$u = g_{2s}(t_1-t_2) \in (0,1), \qquad w_i = \frac{1}{\tfrac14+t_i^2} > 0 .$$

**Lemma 7.5 (exact profile values).** For $S=\{t_1,t_2\}$,
$$P_S(t_1) = w_1 + u^4 w_2, \qquad P_S\!\left(\frac{t_1+t_2}{2}\right) = u\,(w_1 + w_2).$$

*Proof sketch.* At $a=t_1$ the first term has offset $0$ and the second has offset $t_2-t_1$, whose
window value is $g_s(t_1-t_2) = u^4$ by Lemma 7.4 and evenness. At the midpoint both offsets are
$\pm(t_1-t_2)/2$, whose window value is $u$ by the half-argument identity. $\square$

**Theorem 7.6 (sharp resolution criterion).** With the notation above,
$$P_S(t_1) - P_S\!\left(\frac{t_1+t_2}{2}\right) \;=\; (1-u)\bigl(w_1 - u(1+u+u^2)\,w_2\bigr),$$
and hence the midpoint is strictly below the peak at $t_1$ **iff**
$$u\,(1+u+u^2)\,w_2 \;<\; w_1 .$$

*Proof sketch.* Subtract the two expressions of Lemma 7.5 and factor
$w_1 - uw_1 + u^4w_2 - uw_2 = (1-u)w_1 - u(1-u^3)w_2$, using $1-u^3=(1-u)(1+u+u^2)$. Since
$t_1\ne t_2$ we have $u<1$, so the first factor is strictly positive and the sign is governed by
the second. $\square$

The factorisation separates the two failure modes cleanly. The factor $1-u$ vanishes exactly when
$t_1 = t_2$ ("the same ordinate"); the second factor is the genuine resolution threshold ("too
wide a window"). A purely numerical criterion cannot distinguish these.

**Theorem 7.7 (Rayleigh criterion).** Let $s>0$ and $t_1\ne t_2$. If
$$3\,g_{2s}(t_1-t_2)\,\Bigl(\tfrac14+t_1^2\Bigr) \;\le\; \tfrac14+t_2^2,$$
then $P_S\bigl(\tfrac{t_1+t_2}{2}\bigr) < P_S(t_1)$: the two ordinates are resolved and the
midpoint is a valley, not a spurious peak.

*Proof sketch.* The hypothesis is $3u\,w_2 \le w_1$ after clearing denominators, and
$u(1+u+u^2) < 3u$ because $u<1$. Apply Theorem 7.6. $\square$

The constant $3$ costs at most a factor $3$ against the sharp criterion and makes the condition a
directly checkable inequality in the raw data.

**Theorem 7.8 (the criterion is never vacuous).** For any two distinct ordinates $t_1\ne t_2$,
the conclusion of Theorem 7.7 holds for all sufficiently small $s > 0$.

*Proof sketch.* For fixed $d = t_1 - t_2 \ne 0$, $g_{2s}(d) = e^{-\pi d^2/(4s^2)} \to 0$ as
$s \downarrow 0$, because $s^{-2}\to\infty$. So the left-hand side of the criterion tends to $0$
while the right-hand side is a fixed positive constant. $\square$

**Worked numerical probe.** Take $t_1 = 14.13$, $t_2 = 21.02$, $s = 4$. Then
$u = g_8(-6.89) = e^{-\pi\cdot47.5/64} \approx 0.0974$, $w_1 \approx 0.00500$,
$w_2 \approx 0.00226$, and the criterion $3u\,w_2 \le w_1$ reads $0.00066 \le 0.00500$ —
comfortably resolved.

Contrast this with the rectangular window, whose relative sidelobe amplitude is the
width-independent constant $1/\pi$ of Theorem 4.5. Narrowing a Gaussian always eventually
separates two distinct ordinates; narrowing a rectangle never removes its leakage floor.

---

## 8. Schwartz decay and Gaussian regularisation

### 8.1 Explicit seminorm bounds

**Theorem 8.1 (explicit Schwartz bound).** For $s \ne 0$, every $n\in\mathbb{N}$ and every $t$,
$$(t^2)^n\, g_s(t) \;\le\; \left(\frac{s^2}{\pi}\right)^{\!n} n! .$$

*Proof sketch.* Put $y = \pi t^2/s^2 \ge 0$, so $g_s(t) = e^{-y}$ and $t^2 = (s^2/\pi)y$. The
elementary inequality $y^n/n! \le e^y$ gives $y^n e^{-y} \le n!$, and multiplying by
$(s^2/\pi)^n$ yields the claim. $\square$

**Corollary 8.2.** For $t\ne0$, $g_s(t) \le (s^2/\pi)^n n! \,/\, (t^2)^n$ for every $n$: the
Gaussian is dominated by every inverse power of $t^2$.

**Theorem 8.3 (arbitrary powers).** For $s\ne0$, every $m\in\mathbb{N}$ and every $t$,
$$|t|^m\, g_s(t) \;\le\; 1 + \left(\frac{s^2}{\pi}\right)^{\!m} m! .$$

*Proof sketch.* Split on $|t| \le 1$ and $|t| > 1$ to obtain $|t|^m \le 1 + (t^2)^m$, then apply
Theorem 8.1 and $g_s\le1$. $\square$

**Remark 8.4 (the additive $1$ cannot be dropped).** The function $|t|^m g_s(t)$ is maximised at
$|t| = s\sqrt{m/2\pi}$. For $m=1$, $s=1/2$ its maximum is $\approx 0.12099$, while the pure power
bound would assert $\le (s^2/\pi)^1 \cdot 1! \approx 0.07958$. The pure bound therefore fails for
every $s < 0.76$ at $m=1$, and the additive $1$ is the cheapest uniform repair.

**Theorem 8.5 (uniform decay over the Heisenberg orbit).** For $s\ne0$, every $m$, and every
phase-space point $(a,b)$,
$$|t-a|^m\,\bigl|\gamma_{s,a,b}(t)\bigr| \;\le\; 1 + \left(\frac{s^2}{\pi}\right)^{\!m} m!
\qquad \text{for all } t .$$

*Proof sketch.* $|\gamma_{s,a,b}(t)| = |\chi(b(t-a))|\,g_s(t-a) = g_s(t-a)$, so the claim is
Theorem 8.3 applied at $t-a$. $\square$

The constant does not depend on $(a,b)$. The Heisenberg orbit of the Gaussian is a *bounded*
family of Schwartz-type windows — a property the Weyl relation alone does not deliver, since the
relation is compatible with wildly varying seminorms.

### 8.2 Regularisation of infinite families

**Theorem 8.6 (Gaussian regularisation).** Let $s\ne0$ and let $(t_k)_{k\ge0}$ be ordinates
satisfying only the square-root growth condition
$$k+1 \;\le\; t_k^2 \qquad\text{for all } k .$$
Then the Gaussian-windowed harmonic series converges absolutely:
$$\sum_{k\ge0} \frac{g_s(t_k)}{\tfrac14+t_k^2} \;<\; \infty .$$

*Proof sketch.* Terms are positive. Using $\tfrac14 + t_k^2 \ge \tfrac14$ and Corollary 8.2 with
$n=2$,
$$\frac{g_s(t_k)}{\tfrac14+t_k^2} \le 4\,g_s(t_k) \le \frac{4M}{(t_k^2)^2} \le \frac{4M}{(k+1)^2},
\qquad M = \left(\frac{s^2}{\pi}\right)^{\!2} 2!,$$
and $\sum_k (k+1)^{-2} < \infty$. $\square$

**Theorem 8.7 (sharpness: the unwindowed statistic diverges at the threshold).** For the family
$t_k = \sqrt{k+1}$, which satisfies the hypothesis of Theorem 8.6 with equality, the unwindowed
series diverges:
$$\sum_{k\ge0} \frac{1}{\tfrac14+t_k^2} \;=\; \sum_{k\ge0}\frac{1}{k+\tfrac54} \;=\; \infty .$$

*Proof sketch.* $t_k^2 = k+1$, so the terms are $1/(k+\tfrac54) \ge \tfrac{1}{2(k+1)}$, and the
harmonic series diverges. $\square$

On this family the Gaussian window converts a divergent statistic into a convergent one. No window
bounded below by a positive constant can do this, and in particular no rectangular window of
arbitrarily large width — the limit of those is the unwindowed sum itself.

The mechanism is a quantifier order. The constant $C_n = (s^2/\pi)^n n!$ in Theorem 8.1 grows with
$n$ but is *independent of $t$*, so for fixed width one may choose the order $n$ **after** seeing
the growth exponent of the family. The rectangular window has a fixed polynomial decay rate
$1/\xi$ (Theorem 4.4) and cannot reproduce this.

**Numerical illustration.** With $s=1$ and $t_k=\sqrt{k+1}$:
$$\sum_{k<10^4}\frac{1}{k+\tfrac54} \approx 9.4379 \quad(\text{still growing like }\log k),
\qquad
\sum_{k<10^4}\frac{g_1(t_k)}{k+\tfrac54} \approx 0.035427,$$
the latter constant to five digits already past $k=3$.

---

## 9. Algorithms and applications

### 9.1 The Gaussian peak-finding pipeline

The results above assemble into a concrete procedure for locating ordinates in spectral data
$D = \{(t_j,c_j)\}$.

1. **Choose a width.** Compute the scale space $s \mapsto \Sigma(S,s)$ (Definition 6.1). By
   Theorems 6.2 and 6.3 this is a continuous, strictly increasing curve; its knee identifies the
   scale at which the family's mass is captured.
2. **Slide.** Evaluate the position profile $P_S(a)$ (Definition 7.1) on a grid, equivalently the
   discrete Gabor transform at frequency $0$ (Proposition 7.2). Cost: $O(|D|\cdot|\text{grid}|)$,
   or $O(N\log N)$ per frequency slice with a fast transform when the data are gridded.
3. **Detect.** Report local maxima. By Theorem 7.3 the reported positions are unbiased for
   isolated ordinates; by Corollary 3.11 no reported maximum can be an artefact of the window's
   transfer function, since that function is strictly unimodal.
4. **Certify resolution.** For each adjacent pair of detected peaks, check
   $3g_{2s}(t_1-t_2)(\tfrac14+t_1^2)\le \tfrac14+t_2^2$ (Theorem 7.7). If the check fails, narrow
   $s$; Theorem 7.8 guarantees the check eventually succeeds for genuinely distinct ordinates.
5. **Move in phase space if needed.** To analyse at nonzero frequency $b$, use the Gabor atom
   $\gamma_{s,a,b}$; the bookkeeping is exact by Theorem 3.9, and if ordinates are shifted or
   amplitudes modulated, the phase factor $\chi(-\eta c)$ of Theorem 5.13 must be carried.

Step 4 is what a rectangular pipeline cannot supply: its leakage floor of $1/\pi$
(Theorem 4.5) is width-independent, so no re-tuning removes it.

### 9.2 Regularised statistics on infinite data

For an infinite ordinate family whose classical statistic diverges, Theorem 8.6 supplies a
convergent surrogate $\Sigma(S,s)$ at each width, and Theorem 6.5 says that on finite families the
surrogate recovers the classical value as $s\to\infty$. This gives a principled regularisation:
compute at finite $s$, extrapolate in $s$, and use the monotonicity of Theorem 6.2 to bracket the
answer from below.

### 9.3 Beyond the motivating setting

Nothing in Sections 2–4 and 8 refers to the specific amplitudes $1/\rho$. The operator algebra,
the transfer-function comparison, and the Schwartz bounds apply verbatim to any windowed analysis
of point data: spectral line fitting, radio astronomy, vibration analysis, and the analysis of
sampled time series. The specialisation to $1/(\tfrac14+t^2)$ enters only in Sections 5–7, where
it supplies the positivity that makes the "no false nulls" and Rayleigh statements sharp.

---

## 10. Discussion and limitations

**Degenerate width.** All statements about strict monotonicity or strict inequalities carry the
hypothesis $s \ne 0$ (or $s > 0$). At $s=0$ the formula $e^{-\pi t^2/s^2}$ degenerates; the
hypothesis is kept explicit rather than derived.

**The constant $3$ in the Rayleigh criterion.** Theorem 7.7 is a convenient weakening of the sharp
Theorem 7.6. The loss is at most a factor $3$ in the overlap variable $u$, negligible on the
exponential scale of $u = e^{-\pi d^2/(4s^2)}$ but real.

**Two ordinates only.** The resolution analysis is complete for pairs. For three or more nearby
ordinates the profile difference is no longer a product of two factors in one variable, and no
closed-form threshold is claimed here.

**Finite families.** Sections 5–7 concern finite multisets. Section 8 extends the *statistic* to
infinite families under a growth condition, but the peak-localisation results are not asserted in
that generality.

**Divergence claim is family-specific.** Theorem 8.7 is about the specific threshold family
$t_k = \sqrt{k+1}$; families growing strictly faster have convergent unwindowed sums as well. The
point is the existence of a threshold at which the two windows disagree about whether the
statistic exists, not a blanket claim.

**Choice of normalisation.** The convention $\widehat f(\xi) = \int e^{-2\pi i\xi t}f(t)\,dt$ puts
the Gaussian self-duality in the clean form $\widehat{g_s} = s\,g_{1/s}$ and makes the character
$\chi(x)=e^{2\pi i x}$ have integer kernel. Other conventions rescale the constants in Theorems
4.4, 4.5 and 8.1 but change nothing structural.

---

## 11. Future directions

### 11.1 Gaussian extremality of the discrete uncertainty product

**Conjecture.** For the discrete Gabor transform $G_w(D)(a,b)$, define the position spread
$\Delta a(w)^2$ and the frequency spread $\Delta\xi(w)^2$ of a normalised window $w$. Then
$$\Delta a(w)\cdot\Delta\xi(w) \;\ge\; \frac{1}{4\pi},$$
with equality **iff** $w$ is a Gaussian $g_s$ up to the Heisenberg action — i.e. the orbit of the
Gaussian under $\mathbb{H}$ is exactly the equality locus.

The self-duality $\widehat{g_s} = s\,g_{1/s}$ already exhibits the Gaussian as the unique fixed ray
of the Fourier transform inside the window family, and the covariance of Theorem 3.9 shows that
the equality locus must be a full orbit; so the extremality statement is forced to be an orbit
statement, not a pointwise one. The operator half is complete: the intertwining relations of
Theorems 3.5 and 3.6 hold with no integrability hypotheses, so the group action is available
unconditionally. The missing ingredient is a single analytic fact — the second moment
$\int x^2 e^{-bx^2}dx = \tfrac{1}{2b}\sqrt{\pi/b}$ — which unlocks the whole chain.

### 11.2 Non-summability of spurious energy as a window invariant

**Conjecture.** Define the *spurious energy* of a window $w$ as the sum of its transfer function's
local-maximum amplitudes outside the main lobe. Theorems 4.7 and 4.10 show this invariant is
infinite for the rectangular window and finite for every Gaussian atom, uniformly over the
Heisenberg orbit. Conjecturally the invariant is finite exactly for windows of bounded variation
with an integrable derivative, and the dichotomy "finite/infinite spurious energy" is a
genuine classification of admissible analysing windows — with the scale-invariance
$\xi_n|\widehat w(\xi_n)| = 1/\pi$ of Theorem 4.5 as the model obstruction.

### 11.3 Multi-ordinate resolution

Extend Theorem 7.6 to $m \ge 3$ ordinates. The Gaussian's scale-doubling identities suggest the
profile differences remain polynomial in the pairwise overlaps $u_{ij} = g_{2s}(t_i-t_j)$; the
question is whether a factorisation separating "coincident ordinates" from "too wide a window"
survives.

### 11.4 Sharp constants in the regularisation threshold

Theorem 8.6 assumes $t_k^2 \ge k+1$ and Theorem 8.7 shows the threshold is attained. What is the
exact boundary — for which growth rates $t_k^2 \sim \varphi(k)$ does the Gaussian-windowed series
converge while the unwindowed one diverges, as a function of the width $s$?

### 11.5 Other Schwartz windows

The Gaussian is distinguished by Fourier self-duality and by the scale-doubling identities of
Lemma 7.4. Which of the results above survive for a general Schwartz window? Sections 5 and 8
need only positivity and rapid decay; Sections 3, 4 and 7 use the Gaussian structure essentially.
Isolating the minimal hypotheses for each theorem would delimit the class of "good" analysing
windows precisely.

---

## 12. Conclusion

Replacing a sharp cutoff by a Gaussian window costs nothing algebraically and gains a great deal
analytically. The modulation/translation identity $M_bT_a = \chi(ab)T_aM_b$ holds exactly, is the
group law of a Heisenberg group, and is realised by a faithful representation for which the
Gaussian alone is a separating test vector. On the analytic side, the rectangular window's
transfer function leaks a scale-invariant $1/\pi$ of normalised amplitude at arbitrarily high
frequency with non-summable total energy, while the Gaussian atom's transfer function is a single
strictly monotone lobe with faster-than-polynomial decay and summable spurious response.

Downstream, this converts a discontinuous, sometimes-blind statistic into a continuous, strictly
monotone scale space with the classical statistic as its wide-window limit; it makes peak
localisation unbiased and equips it with a closed-form resolution criterion that has no floor; and
it regularises statistics on infinite families for which the classical sum does not exist. The
unifying reason is that the Gaussian is not merely a smooth function but a distinguished vector in
a representation of the Heisenberg group — and every property above is inherited uniformly across
its orbit.
