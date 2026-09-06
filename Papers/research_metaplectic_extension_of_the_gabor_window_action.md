# The Metaplectic Extension of the Gabor Window Action

**Aristotle**

**Date:** 2026-09-06

---

## Abstract

The Gabor (windowed Fourier) transform is built from two operators, translation and modulation, which generate the Heisenberg group $H$ through the Weyl cocycle $\chi(ba')$, $\chi(x)=e^{2\pi i x}$. We adjoin a third generator, the **chirp** $(C_c f)(t)=e^{2\pi i c t^2}f(t)$, and prove that the Weyl cocycle extends: $C_c$ normalises $H$ via the shear automorphism $\sigma_c(a,b,z)=(a,\,b+2ca,\,z\chi(ca^2))$, so that $H$ sits as a normal subgroup of a semidirect product $H\rtimes\mathbb{R}$ carrying a *faithful* representation on window space. We then identify the geometry. The **chirped Gaussians** $G_{\alpha,\beta}(t)=e^{-\pi(\alpha+i\beta)t^2}$, $\alpha>0$, form a family parametrised by the upper half-plane $\mathbb{H}$ through the **Siegel parameter** $z=i/(\alpha+i\beta)$, and chirp, dilation and Fourier transform act on $z$ by the Möbius transformations of the shear, diagonal and rotation-by-$\pi/2$ subgroups of $\mathrm{SL}_2(\mathbb{R})$ respectively. In particular the Fourier transform of a chirped Gaussian inverts its complex width, $\widehat{G_\tau}=\tau^{-1/2}G_{1/\tau}$ for $\operatorname{Re}\tau>0$. Consequences: the classical width parameter $s$ is the coordinate $z=is^2$ on the imaginary geodesic, so monotonicity of the Gaussian scale space is the diagonal flow rather than a computation; the lower Borel subgroup $B=\{\text{shear}\}\cdot\{\text{diagonal}\}$ acts simply transitively on the family, and lifts to window operators without any sign; and the chirp direction is transverse to the width geodesic, so the unchirped family is not stable under the action.

Finally we isolate the obstruction. The central element $S^2=-I$ of $\mathrm{SL}_2(\mathbb{R})$ acts trivially on $\mathbb{H}$, yet the corresponding window operator $\mathcal F^2$ is the **parity operator**, $\mathcal F^2(g_{s,a,b})=g_{s,-a,-b}$, which differs from the identity on every Gabor atom with $(a,b)\neq(0,0)$; and $\mathcal F^4=\mathrm{id}$, matching $S^4=I$. The obstruction is moreover *projective*: no complex rescaling $\kappa\mathcal F^2$ reproduces the atom. Hence the phase-space action does not lift to an action on windows — only the metaplectic double cover acts, and the discrepancy is a genuine order-two cocycle class supported at the Weyl element. In the discrete setting we show the shear $\sigma_c$ preserves the integer Heisenberg lattice if and only if $2c\in\mathbb{Z}$: the continuous theory has an $\mathbb{R}$ of chirps, the multiset-supported discrete theory only a lattice of them.

**Keywords:** Gabor transform, Heisenberg group, metaplectic group, chirped Gaussian, Siegel upper half-plane, $\mathrm{SL}_2(\mathbb{R})$, Maslov index, time–frequency analysis.

---

## 1. Introduction

Time–frequency analysis is the study of a signal $f:\mathbb{R}\to\mathbb{C}$ through its correlations with a family of *atoms* — translated and modulated copies of a fixed window. The choice of window is essentially canonical: the Gaussian
$$g_s(t)=e^{-\pi t^2/s^2},\qquad s>0,$$
uniquely saturates the uncertainty inequality, and is the fixed point (up to width) of the Fourier transform.

Two operators act on windows:
$$(T_a f)(t)=f(t-a)\quad\text{(translation)},\qquad (M_b f)(t)=\chi(bt)\,f(t)\quad\text{(modulation)},$$
where throughout
$$\chi(x)=e^{2\pi i x},\qquad \chi(x+y)=\chi(x)\chi(y),\qquad \chi(x)=1\iff x\in\mathbb{Z}.$$
They fail to commute by the Weyl phase, $M_bT_a=\chi(ba)T_aM_b$, and consequently generate the **Heisenberg group**
$$H=\{(a,b,z): a,b\in\mathbb{R},\ |z|=1\},\qquad (a,b,z)(a',b',z')=(a+a',\,b+b',\,zz'\chi(ba')).$$
Its action on windows — the Schrödinger representation — is
$$\big(\rho(a,b,z)f\big)(t)=z\,\chi\!\big(b(t-a)\big)\,f(t-a),$$
and the **Gabor atom** at phase-space point $(a,b)$ is
$$g_{s,a,b}(t)=\rho(a,b,1)g_s(t)=\chi\!\big(b(t-a)\big)\,g_s(t-a).$$

The group $H$ implements only the *translations* of phase space $\mathbb{R}^2_{(a,b)}$. Phase space, however, is a symplectic vector space, and its full linear symmetry group is $\mathrm{SL}_2(\mathbb{R})$. The classical theory of the Weil (metaplectic) representation says that these symmetries also act on functions — but only after passing to a double cover. The purpose of this paper is to build that picture concretely and constructively out of the Gabor window, one generator at a time, and to locate precisely where and why the honest lift fails.

The organising principle is that *windows form a hyperbolic plane*. Once the Gaussian family is completed to the chirped Gaussians, the parameter space is $\mathbb{H}$, and each window operation is a familiar isometry: shear, geodesic flow, rotation. Two of the three lift honestly; the third does not, and its failure is measurable on a single explicit pair of atoms.

### 1.1 Summary of results

1. **The chirp normalises the Heisenberg group** (Theorems 3.1–3.3), giving $H\rtimes\mathbb{R}$ with $H$ normal and a faithful representation on window space (Theorem 3.6). The automorphism is outer for $c\neq 0$ (Theorem 3.7).
2. **Chirped Gaussians are an $\mathrm{SL}_2(\mathbb{R})$-equivariant family** (Section 4): chirp $=$ shear, dilation $=$ diagonal, Fourier $=$ rotation by $\pi/2$, all acting by Möbius transformations on the Siegel parameter (Theorem 4.6).
3. **The width axis is the imaginary geodesic** and scale-space monotonicity is the diagonal flow (Theorems 5.1–5.3); the chirp is transverse to it (Theorem 5.5).
4. **The Borel subgroup acts transitively and lifts honestly** (Theorems 6.1–6.3).
5. **The metaplectic anomaly** (Section 7): $\mathcal F^2$ is parity on atoms (Theorem 7.1), $\mathcal F^4=\mathrm{id}$ (Corollary 7.2), $S^2=-I$ acts trivially on $\mathbb{H}$ (Lemma 7.3), whence no lift exists (Theorem 7.5) and none exists projectively either (Theorem 7.6).
6. **The discrete anomaly** (Theorem 8.1): $\sigma_c$ preserves $\mathbb{Z}\times\mathbb{Z}$ iff $2c\in\mathbb{Z}$.

---

## 2. Notation and standing conventions

We write $\chi(x)=e^{2\pi ix}$ and use the Fourier normalisation
$$\widehat f(\xi)=(\mathcal F f)(\xi)=\int_{\mathbb{R}} f(t)\,e^{-2\pi i t\xi}\,dt,$$
for which $\mathcal F g_s = s\, g_{1/s}$ and $\mathcal F^4=\mathrm{id}$ on Schwartz functions.

We record the elementary facts used repeatedly:

* $|g_s(t)|=g_s(t)=e^{-\pi t^2/s^2}$, so $g_s(0)=1$ and $g_s(t)<1$ for $t\neq 0$; $g_s$ is even and strictly positive.
* $|\chi(x)|=1$ for real $x$; $\chi(1/2)=-1\neq 1$; $\operatorname{Im}\chi(1/4)=1$ and $\operatorname{Im}\chi(-1/4)=-1$.
* Conjugation on $H$ never alters the $b$-coordinate: $(a_0,b_0,z_0)(a,b,z)(a_0,b_0,z_0)^{-1}$ has second coordinate $b$.

$\mathrm{SL}_2(\mathbb{R})$ acts on the upper half-plane $\mathbb{H}=\{z:\operatorname{Im}z>0\}$ by
$$\begin{pmatrix}p&q\\r&w\end{pmatrix}\cdot z=\frac{pz+q}{rz+w},$$
an action which factors through $\mathrm{PSL}_2(\mathbb{R})=\mathrm{SL}_2(\mathbb{R})/\{\pm I\}$; the kernel $\{\pm I\}$ is the entire source of what follows.

---

## 3. The chirp generator and the extended cocycle

### 3.1 Definition

**Definition 3.0 (Chirp operator).** For $c\in\mathbb{R}$ the *chirp operator* is
$$(C_c f)(t)=\chi(c t^2)\,f(t)=e^{2\pi i c t^2}f(t).$$
Immediately $C_0=\mathrm{id}$, $C_cC_{c'}=C_{c+c'}$ (so $c\mapsto C_c$ is a one-parameter group of invertible operators, $C_c^{-1}=C_{-c}$), $C_c$ is linear, and $C_c$ commutes with every modulation $M_b$ (both are multiplication operators).

### 3.2 The chirp–translation relation

**Theorem 3.1 (Chirp–translation relation).** For all $a,c\in\mathbb{R}$ and all $f$,
$$C_c\,T_a\,f=\chi(-ca^2)\; M_{2ac}\,T_a\,C_c\,f .$$

*Proof sketch.* Evaluate at $t$. The left side is $\chi(ct^2)f(t-a)$. The right side is $\chi(-ca^2)\chi(2act)\chi(c(t-a)^2)f(t-a)$. Using $\chi(x)\chi(y)=\chi(x+y)$ the phases on the right combine to $\chi\big(-ca^2+2act+c(t-a)^2\big)=\chi(ct^2)$, since $-ca^2+2act+ct^2-2act+ca^2=ct^2$. $\square$

The identity is the operator form of the phase-space shear
$$(a,b)\longmapsto (a,\ b+2ca):$$
a translation by $a$, seen through a chirp, acquires a modulation proportional to $a$.

### 3.3 The shear automorphism of $H$

**Definition 3.2 (Chirp shear).** For $c\in\mathbb{R}$ define $\sigma_c:H\to H$ by
$$\sigma_c(a,b,z)=\big(a,\; b+2ca,\; z\,\chi(ca^2)\big).$$

**Theorem 3.3 (The Weyl cocycle extends).** $\sigma_c$ is a group automorphism of $H$, $\sigma_0=\mathrm{id}$, and $\sigma_c\circ\sigma_{c'}=\sigma_{c+c'}$; thus $c\mapsto\sigma_c$ is a homomorphism $\mathbb{R}\to\operatorname{Aut}(H)$.

*Proof sketch.* Only the central coordinate requires work. Writing $g=(a,b,z)$, $h=(a',b',z')$, the central coordinate of $\sigma_c(gh)$ is $zz'\chi(ba')\chi\big(c(a+a')^2\big)$, while that of $\sigma_c(g)\sigma_c(h)$ is $z\chi(ca^2)\,z'\chi(ca'^2)\,\chi\big((b+2ca)a'\big)$. The identity
$$c(a+a')^2=ca^2+ca'^2+2caa'$$
makes the two agree. The correction phase $\chi(ca^2)$ is therefore not a convention but is *forced*: it is exactly the coboundary needed to keep the Weyl cocycle in its class under the shear. Multiplicativity in $c$ follows from $\chi(ca^2)\chi(c'a^2)=\chi((c+c')a^2)$ together with $b+2c'a+2ca=b+2(c+c')a$. $\square$

**Definition 3.4 (Semidirect product).** Let $H\rtimes_\sigma\mathbb{R}$ be the semidirect product determined by $c\mapsto\sigma_c$: elements $(g,c)$ with $(g,c)(h,d)=(g\,\sigma_c(h),\,c+d)$.

**Theorem 3.5 (Normality and intertwining).** $H$ is a normal subgroup of $H\rtimes_\sigma\mathbb{R}$ (it is the kernel of the projection to $\mathbb{R}$), and the chirp operator *implements* the automorphism on windows:
$$\rho\big(\sigma_c g\big)\,C_c\,f=C_c\,\rho(g)\,f\qquad\text{for all }g\in H,\ f .$$

*Proof sketch.* The intertwining identity, evaluated at $t$, reduces after cancelling $z f(t-a)$ to
$$\chi(ca^2)\,\chi\!\big((b+2ca)(t-a)\big)\,\chi\!\big(c(t-a)^2\big)=\chi(ct^2)\,\chi\!\big(b(t-a)\big),$$
i.e. to the polynomial identity $ca^2+(b+2ca)(t-a)+c(t-a)^2=ct^2+b(t-a)$. Normality of $H$ is formal. $\square$

Consequently the pair (Schrödinger representation, chirp multiplication) assembles into a single representation of $H\rtimes_\sigma\mathbb{R}$ by invertible operators on window space, restricting to $\rho$ on $H$ and to $c\mapsto C_c$ on $\mathbb{R}$.

### 3.4 Faithfulness

**Lemma 3.6a (Rigidity of quadratic characters).** If $b,c\in\mathbb{R}$ and $\chi(bt+ct^2)=1$ for all $t\in\mathbb{R}$, then $b=c=0$.

*Proof sketch.* Put $M=1+|b|+|c|$ and $T=1/(2M)\le 1/2$. For $|t|\le T$ one has $|t|^2\le|t|\le T$, hence
$$|bt+ct^2|\le(|b|+|c|)T\le MT=\tfrac12<1 .$$
But $\chi(x)=1$ forces $x\in\mathbb{Z}$, and the only integer of absolute value $<1$ is $0$. Therefore $bt+ct^2=0$ for all $|t|\le T$. Taking $t=T$ and $t=T/2$ gives two linear equations whose solution is $c=0$ and then $b=0$. $\square$

**Theorem 3.6 (Faithfulness).** The representation of $H\rtimes_\sigma\mathbb{R}$ on window space is faithful: if $\rho(g)C_c=\mathrm{id}$ then $g=1$ and $c=0$.

*Proof sketch.* Apply the operator to the Gaussian $g_1$ and write $g=(a,b,z)$. Taking absolute values kills all phases and leaves $g_1(t-a)=g_1(t)$ for all $t$; at $t=0$ this gives $e^{-\pi a^2}=1$, hence $a=0$. With $a=0$ the identity becomes $z\,\chi(bt+ct^2)\,g_1(t)=g_1(t)$, and $g_1(t)\neq0$, so $z\chi(bt+ct^2)=1$; at $t=0$, $z=1$, and Lemma 3.6a gives $b=c=0$. $\square$

Faithfulness says the chirp is not secretly a Heisenberg element. The next result says more: it is not even conjugate to one.

**Theorem 3.7 (The chirp automorphism is outer).** For $c\neq 0$ there is no $h\in H$ with $\sigma_c(g)=hgh^{-1}$ for all $g\in H$.

*Proof sketch.* Conjugation in $H$ leaves the $b$-coordinate unchanged, whereas $\sigma_c(1,0,1)=(1,2c,\chi(c))$ has $b$-coordinate $2c\neq 0$. $\square$

Hence $H\rtimes_\sigma\mathbb{R}$ is not a direct product: the chirp is a genuinely new generator, transverse to the Heisenberg directions.

---

## 4. Chirped Gaussians and the Siegel parameter

### 4.1 The family

**Definition 4.1 (Chirped Gaussian).** For $\alpha>0$ and $\beta\in\mathbb{R}$ set
$$G_{\alpha,\beta}(t)=e^{-\pi(\alpha+i\beta)t^2},\qquad \tau=\alpha+i\beta \ \ (\operatorname{Re}\tau>0).$$
Then $G_{\alpha,\beta}$ never vanishes, $|G_{\alpha,\beta}(t)|=e^{-\pi\alpha t^2}$ (the chirp is a pure phase, invisible to the envelope), and $\tau\ne0$.

**Proposition 4.2 (The family extends the Gaussian windows).** For $s\neq0$, $G_{1/s^2,\,0}=g_s$.

*Proof sketch.* $e^{-\pi(1/s^2)t^2}=e^{-\pi t^2/s^2}$. $\square$

Two operators move inside the family:

**Proposition 4.3 (Chirp and dilation act on the parameters).** With $(D_u f)(t)=f(e^{-u}t)$,
$$C_c\,G_{\alpha,\beta}=G_{\alpha,\;\beta-2c},\qquad D_u\,G_{\alpha,\beta}=G_{e^{-2u}\alpha,\;e^{-2u}\beta},$$
and on the unchirped subfamily $D_u g_s=g_{e^u s}$. Moreover $D_0=\mathrm{id}$, $D_uD_{u'}=D_{u+u'}$.

*Proof sketch.* For the chirp, $\chi(ct^2)e^{-\pi(\alpha+i\beta)t^2}=e^{2\pi ict^2-\pi(\alpha+i\beta)t^2}=e^{-\pi(\alpha+i(\beta-2c))t^2}$. For the dilation, $(e^{-u}t)^2=e^{-2u}t^2$. $\square$

### 4.2 Fourier transform of a chirped Gaussian

**Theorem 4.4 (Width inversion).** Let $\tau=\alpha+i\beta$ with $\alpha>0$. Then
$$\mathcal F\big(G_{\alpha,\beta}\big)=\tau^{-1/2}\,G_{1/\tau},\qquad\text{i.e.}\qquad \mathcal F\big(G_{\alpha,\beta}\big)(\xi)=\frac{1}{(\alpha+i\beta)^{1/2}}\;G_{\frac{\alpha}{\alpha^2+\beta^2},\;\frac{-\beta}{\alpha^2+\beta^2}}(\xi),$$
where the principal branch of the square root is used, legitimate because $\operatorname{Re}\tau>0$.

*Proof sketch.* This is the Gaussian integral $\int e^{-\pi\tau t^2}e^{-2\pi it\xi}dt=\tau^{-1/2}e^{-\pi\xi^2/\tau}$, valid for $\operatorname{Re}\tau>0$ by analytic continuation from real $\tau>0$. It remains only to write $1/\tau$ in real coordinates: from $(\alpha+i\beta)(\alpha-i\beta)=\alpha^2+\beta^2$,
$$\frac1\tau=\frac{\alpha}{\alpha^2+\beta^2}+i\,\frac{-\beta}{\alpha^2+\beta^2}. \qquad\square$$

**Corollary 4.5 (Consistency).** For $s>0$, $\mathcal F g_s = s\,g_{1/s}$, recovered by setting $\beta=0$, $\alpha=1/s^2$: then $\tau^{-1/2}=s$ and $1/\tau=s^2$.

Note where the hypothesis $\alpha>0$ enters. It is simultaneously (i) the integrability condition making the Gaussian integral converge, and (ii) the condition that the parameter below lies in the upper half-plane. Analysis and geometry impose the same constraint.

### 4.3 The Siegel parameter and equivariance

**Definition 4.6a (Siegel parameter).** For $\alpha>0$ put
$$z(\alpha,\beta)=\frac{i}{\alpha+i\beta}=\frac{\beta}{\alpha^2+\beta^2}+i\,\frac{\alpha}{\alpha^2+\beta^2}.$$
Then $\operatorname{Im}z=\alpha/(\alpha^2+\beta^2)>0$, so $z(\alpha,\beta)\in\mathbb{H}$; and $z$ is injective on $\{\alpha>0\}$, since $z(\alpha,\beta)=z(\alpha',\beta')$ forces $\alpha+i\beta=\alpha'+i\beta'$. Thus the chirped Gaussian family is faithfully coordinatised by the upper half-plane.

Introduce the three standard elements of $\mathrm{SL}_2(\mathbb{R})$:
$$N_c=\begin{pmatrix}1&0\\-2c&1\end{pmatrix},\qquad A_u=\begin{pmatrix}e^{u}&0\\0&e^{-u}\end{pmatrix},\qquad S=\begin{pmatrix}0&-1\\1&0\end{pmatrix}=\begin{pmatrix}\cos\frac\pi2&-\sin\frac\pi2\\ \sin\frac\pi2&\cos\frac\pi2\end{pmatrix}.$$
They satisfy $N_cN_{c'}=N_{c+c'}$, $A_uA_{u'}=A_{u+u'}$, $S^2=-I$, $S^4=I$, and act on $\mathbb{H}$ by
$$N_c\cdot z=\frac{z}{-2cz+1},\qquad A_u\cdot z=e^{2u}z,\qquad S\cdot z=\frac{-1}{z}.$$

**Theorem 4.6 (Equivariance).** For $\alpha>0$:
1. *(Chirp $=$ shear)* $\ z(\alpha,\beta-2c)=N_c\cdot z(\alpha,\beta)$;
2. *(Dilation $=$ diagonal)* $\ z\big(e^{-2u}\alpha,\ e^{-2u}\beta\big)=A_u\cdot z(\alpha,\beta)$;
3. *(Fourier $=$ rotation by $\pi/2$)* $\ z\!\left(\dfrac{\alpha}{\alpha^2+\beta^2},\ \dfrac{-\beta}{\alpha^2+\beta^2}\right)=S\cdot z(\alpha,\beta)$.

*Proof sketch.* Write $\tau=\alpha+i\beta$ so $z=i/\tau$. (1) Chirping replaces $\tau$ by $\tau-2ic$, and
$$-2c\,z+1=\frac{-2ci+\tau}{\tau}=\frac{\tau-2ic}{\tau}\quad\Longrightarrow\quad \frac{z}{-2cz+1}=\frac{i/\tau}{(\tau-2ic)/\tau}=\frac{i}{\tau-2ic},$$
which is the Siegel parameter of $G_{\alpha,\beta-2c}$. (2) Dilating replaces $\tau$ by $e^{-2u}\tau$, hence $z$ by $e^{2u}z$. (3) By Theorem 4.4 the Fourier transform replaces $\tau$ by $1/\tau$, hence $z=i/\tau$ by $i\tau = -1/(i/\tau)=-1/z$. In each case the computation is a single identity between complex fractions. $\square$

Thus:

| window operation | matrix | Möbius action on $z$ |
|---|---|---|
| chirp $C_c$ | $N_c$ (lower unipotent) | $z\mapsto z/(1-2cz)$ |
| dilation $D_u$ | $A_u$ (diagonal) | $z\mapsto e^{2u}z$ |
| Fourier $\mathcal F$ | $S$ (rotation by $\pi/2$) | $z\mapsto -1/z$ |

The chirped Gaussian family is an $\mathrm{SL}_2(\mathbb{R})$-equivariant family, with the caveat — the subject of Section 7 — that the third row holds only up to the scalar $\tau^{-1/2}$ and only *projectively* as an action.

---

## 5. The width geodesic and the scale space

**Theorem 5.1 (Windows on the imaginary axis).** For $s>0$ the Gaussian window $g_s=G_{1/s^2,0}$ has Siegel parameter
$$z=i s^2 ,$$
so $\operatorname{Re}z=0$: the classical one-parameter family of window widths is exactly the imaginary geodesic of $\mathbb{H}$.

**Theorem 5.2 (Widening is the geodesic flow).** For $s>0,u\in\mathbb{R}$, the window $g_{e^u s}$ has Siegel parameter $A_u\cdot(is^2)=e^{2u}is^2$. Changing the width is precisely the diagonal one-parameter subgroup acting, at unit hyperbolic speed along the geodesic.

*Proof sketch.* $z(1/(e^us)^2,0)=i(e^us)^2=e^{2u}\,is^2$. $\square$

This reinterprets a standard monotonicity fact of scale space. Let $S$ be a finite multiset of real ordinates and let
$$\Sigma(S,s)=\sum_{t\in S} e^{-\pi t^2/s^2}$$
be the aggregate response of a width-$s$ Gaussian window to the configuration $S$. It is classical, and elementary, that $\Sigma(S,\cdot)$ is nondecreasing, strictly increasing as soon as $S$ contains a nonzero ordinate.

**Theorem 5.3 (Monotonicity is the diagonal flow).** For every finite multiset $S$ and every $s>0$, the map
$$u\longmapsto \Sigma\big(S,\ e^u s\big)$$
is monotone; and it is *strictly* monotone whenever some $t\in S$ is nonzero.

*Proof sketch.* $u\mapsto e^us$ is (strictly) increasing and takes values in $(0,\infty)$; compose with the monotonicity of $\Sigma(S,\cdot)$. The content is not the inequality but its reading: the parameter $u$ is the time of the diagonal flow, so the assertion is that a one-parameter subgroup moves the Siegel point monotonically along a geodesic, and the response is a monotone function of position along that geodesic. $\square$

**Theorem 5.5 (Transversality of the chirp).** For $s>0$ and $c\neq0$, the chirped window $C_c g_s=G_{1/s^2,\,-2c}$ has Siegel parameter with
$$\operatorname{Re}\,z=\frac{-2c}{(1/s^2)^2+4c^2}\neq 0 .$$
Hence a nonzero chirp always moves the window off the imaginary geodesic, and no change of width imitates a chirp.

**Corollary 5.6 (A chirped window is never a plain window).** For $c\neq0$ and any $s,s'$, $C_c g_s\neq g_{s'}$.

*Proof sketch (direct, without the geometry).* Choose $t=\big(4|c|\big)^{-1/2}$, so $|c|t^2=1/4$. Then $C_cg_s(t)=\chi(\pm1/4)g_s(t)$ has imaginary part $\pm g_s(t)\neq0$, whereas $g_{s'}(t)$ is real. Alternatively: $\operatorname{Re}z\ne0$ for the chirped window but $\operatorname{Re}z=0$ for every plain window, and $z$ is injective. $\square$

So the family $\{g_s\}$ is *not* stable under the metaplectic action; the two-parameter chirped family is the smallest completion that is. This is the structural reason the enlargement of Section 4 is not optional.

---

## 6. The Borel subgroup: transitivity and an honest lift

Let $B=\{N_cA_u\}$ be the lower Borel subgroup of $\mathrm{SL}_2(\mathbb{R})$ generated by the shears and the diagonal torus.

**Theorem 6.1 (Borel commutation relation, twice).** For all $u,c$,
$$D_u\,C_c\,D_u^{-1}=C_{e^{-2u}c}\qquad\text{and}\qquad A_u\,N_c\,A_u^{-1}=N_{e^{-2u}c}.$$
The operator relation and the matrix relation agree exactly: on $B$, the phase-space action lifts to windows with no discrepancy whatsoever.

*Proof sketch.* Operators: $\big(D_uC_cD_{-u}f\big)(t)=\chi\big(c(e^{-u}t)^2\big)f\big(e^{u}e^{-u}t\big)=\chi(e^{-2u}c\,t^2)f(t)$. Matrices: multiply out $\operatorname{diag}(e^u,e^{-u})\,N_c\,\operatorname{diag}(e^{-u},e^u)$, whose off-diagonal entry is $-2ce^{-2u}$. $\square$

**Theorem 6.2 (Transitivity on the family).** For every $\alpha>0$, $\beta\in\mathbb{R}$,
$$G_{\alpha,\beta}=C_{-\beta/2}\;D_{-\frac12\log\alpha}\;G_{1,0}.$$
Equivalently, on Siegel parameters, $z(\alpha,\beta)=N_{-\beta/2}A_{-\frac12\log\alpha}\cdot i$: the Borel orbit of the standard point $i$ is all of $\mathbb{H}$.

*Proof sketch.* First apply the dilation: $D_{-\frac12\log\alpha}G_{1,0}=G_{e^{\log\alpha}\cdot1,\,0}=G_{\alpha,0}$, since $e^{-2u}=\alpha$ for $u=-\frac12\log\alpha$. Then apply the chirp: $C_{-\beta/2}G_{\alpha,0}=G_{\alpha,\,0-2(-\beta/2)}=G_{\alpha,\beta}$. The parameters $u=-\frac12\log\alpha$ and $c=-\beta/2$ are the exponential coordinates of the Borel Lie algebra. $\square$

Two remarks. First, transitivity is of the *lower* Borel: our chirp is the lower unipotent $N_c$, which fixes $0$, not $\infty$. The upper unipotent (a horizontal translation $z\mapsto z+q$ of the Siegel parameter) is *not* implemented by multiplication by a chirp on this family. Second, and crucially for Section 7, $B$ is contractible; simple connectivity is exactly why the lift can be honest here.

**Theorem 6.3 (Dilations also normalise $H$).** The map $\delta_u(a,b,z)=(e^{u}a,\,e^{-u}b,\,z)$ is an automorphism of $H$ — with *no* phase correction — and $\rho(\delta_u g)D_u=D_u\rho(g)$. Consequently $H$ is normal in $H\rtimes_\delta\mathbb{R}$ as well.

*Proof sketch.* The Weyl cocycle is literally invariant: $(e^{-u}b)(e^{u}a')=ba'$. The intertwining identity is the change of variable $t\mapsto e^{-u}t$. $\square$

The contrast with Theorem 3.3 is instructive. The diagonal subgroup preserves the symplectic form *pointwise on the cocycle*, so no correction phase appears; the shear preserves it only up to the coboundary $\chi(ca^2)$. This is the structural reason width monotonicity comes for free while the chirp required a cocycle computation.

---

## 7. The metaplectic anomaly

We now show that the equivariance of Section 4 cannot be upgraded to an honest action.

### 7.1 The square of the Fourier transform on atoms

**Theorem 7.1 ($\mathcal F^2$ is parity).** For $s>0$ and $a,b\in\mathbb{R}$,
$$\mathcal F^2\big(g_{s,a,b}\big)=g_{s,-a,-b}.$$
No extra constant appears: the transform is exactly the parity image of the atom.

*Proof sketch.* The three intertwining rules $\mathcal F T_a=M_{-a}\mathcal F$, $\mathcal F M_b=T_b\mathcal F$ and $\mathcal F g_s=s\,g_{1/s}$ give
$$\mathcal F\big(g_{s,a,b}\big)=s\;M_{-a}\,T_b\,g_{1/s},$$
i.e. the atom of width $1/s$ sitting at the rotated phase-space point $(b,-a)$, scaled by $s$. Applying the same three rules again returns the width $1/s$ to $s$, producing the second scalar $1/s$; the two constants cancel exactly, $s\cdot\frac1s=1$, and the phase-space point rotates once more to $(-a,-b)$. $\square$

**Corollary 7.2 (Order four).** $\mathcal F^4\big(g_{s,a,b}\big)=g_{s,a,b}$, matching $S^4=I$.

### 7.2 Parity is not the identity

**Lemma 7.3 ($-I$ acts trivially downstairs).** For every $z\in\mathbb{H}$, $(-I)\cdot z=\frac{-z+0}{0-1}=z$. In particular $S^2\cdot z=z$ for all $z$.

**Theorem 7.4 (Separation of opposite atoms).** If $s>0$ and $(a,b)\neq(0,0)$ then
$$g_{s,-a,-b}\ \neq\ g_{s,a,b}.$$

*Proof sketch.* Two cases, with two different invariants.

*Case $a\neq0$ (use the modulus).* Evaluate both at $t=a$ and take absolute values. Since $|\chi|=1$, the left side has modulus $g_s(a-(-a))=g_s(2a)$ and the right side $g_s(a-a)=g_s(0)=1$. But $g_s(2a)<1$ for $a\neq 0$: contradiction.

*Case $a=0$, $b\neq 0$ (use the quarter period of $\chi$).* Now both atoms have the same envelope $g_s(t)$, which never vanishes, so equality would force $\chi(-bt)=\chi(bt)$ for all $t$. Take $t=1/(4b)$, so $bt=1/4$; then $\chi(-1/4)=\chi(1/4)$, and multiplying both sides by $\chi(1/4)$ gives $1=\chi(1/2)$, which is false. $\square$

**Theorem 7.5 (The metaplectic anomaly).** Let $s>0$ and $(a,b)\neq(0,0)$. Then simultaneously
$$\forall z\in\mathbb{H}:\ (S^2)\cdot z=z \qquad\text{and}\qquad \mathcal F^2\big(g_{s,a,b}\big)\neq g_{s,a,b}.$$
Hence there is no map $M\mapsto\rho(M)$ from $\mathrm{SL}_2(\mathbb{R})$ to operators on window space which is a homomorphism and which implements the phase-space action: the assignment must be double-valued. The honest symmetry group of the window is the metaplectic double cover.

*Proof sketch.* Combine Lemma 7.3, Theorem 7.1 and Theorem 7.4. If an honest lift existed, $\rho(S)^2=\rho(S^2)=\rho(-I)$ would have to act as $\rho$ of an element fixing every window parameter, hence (being determined by its action on the family) as the identity; but it acts by parity. $\square$

### 7.3 The obstruction is projective

One might hope to repair the lift by scalars — replacing $\rho(M)$ by $\lambda(M)\rho(M)$ for suitable constants. This does not help, and the following statement is the precise reason.

**Theorem 7.6 (Projective anomaly).** Let $s>0$ and $(a,b)\neq(0,0)$. For every $\kappa\in\mathbb{C}$,
$$\kappa\,\mathcal F^2\big(g_{s,a,b}\big)\ \neq\ g_{s,a,b}.$$
Equivalently, the atoms at $(a,b)$ and $(-a,-b)$ are not even proportional.

*Proof sketch.* Again two cases.

*Case $a\neq0$.* Taking moduli, proportionality would give $|\kappa|\,g_s(t+a)=g_s(t-a)$ for all $t$. Setting $t=-a$ gives $|\kappa|=g_s(-2a)=g_s(2a)$; setting $t=a$ gives $|\kappa|\,g_s(2a)=1$. Substituting, $g_s(2a)^2=1$, contradicting $0<g_s(2a)<1$. Geometrically: two Gaussian bells centred at $-a$ and $+a$ can be matched by a constant at one point only at the cost of mismatching at the mirror point.

*Case $a=0$, $b\neq0$.* Evaluate at $t=0$: both atoms equal $1$ there (envelope $g_s(0)=1$, phase $\chi(0)=1$), so $\kappa=1$, and Theorem 7.4 applies. $\square$

Therefore the obstruction is a genuine class in $H^2$ with values in the scalars, of order two, and no normalisation removes it.

### 7.4 Where the anomaly lives, and where it does not

Three boundary remarks sharpen the statement.

* **It is invisible at the origin.** For $a=b=0$ the atom is the Gaussian itself, which is *even*; parity fixes it. The hypothesis $(a,b)\neq(0,0)$ in Theorems 7.5–7.6 is therefore a real boundary of the phenomenon and not an artefact: the anomaly is detected by atoms displaced in phase space, not by the vacuum.
* **It is of order exactly two.** $\mathcal F^2\ne\mathrm{id}$ but $\mathcal F^4=\mathrm{id}$ (Corollary 7.2), mirroring $S^2=-I\neq I$, $S^4=I$. The kernel of $\mathrm{SL}_2(\mathbb{R})\to\mathrm{PSL}_2(\mathbb{R})$ is $\{\pm I\}\cong\mathbb{Z}/2$, and the double cover is exactly what the sign is a shadow of.
* **It is concentrated at the Weyl element.** By Theorem 6.1 the Borel subgroup lifts honestly, with the operator relation matching the matrix relation exactly. The Borel subgroup is simply connected; $\mathrm{SL}_2(\mathbb{R})$ is not (its maximal compact is a circle, and $\pi_1=\mathbb{Z}$). The failure must therefore be supported on the rotation, and by Theorem 7.6 it is nontrivial there. This is the Maslov sign.

Concretely: the scalar $\tau^{-1/2}$ in Theorem 4.4 is where the sign lives. Following the branch of $\tau^{1/2}$ continuously around a loop in $\{\operatorname{Re}\tau>0\}$ composed with the width inversion $\tau\mapsto1/\tau$ returns the *other* square root; the double-valuedness of the metaplectic representation is exactly the double-valuedness of that square root.

---

## 8. The discrete theory: a lattice anomaly

A digital, multiset-supported Gabor transform lives not on all of phase space but on a lattice. Take the integer Heisenberg lattice
$$\Lambda=\{(a,b,z)\in H:\ a\in\mathbb{Z},\ b\in\mathbb{Z}\},$$
the set of phase-space points at which a discrete Gabor transform places atoms.

**Theorem 8.1 (Discrete metaplectic anomaly).** The chirp shear preserves the lattice,
$$\sigma_c(\Lambda)\subseteq\Lambda,$$
**if and only if** $2c\in\mathbb{Z}$.

*Proof sketch.* ($\Rightarrow$) Apply $\sigma_c$ to $(1,0,1)\in\Lambda$: the image has $b$-coordinate $0+2c\cdot1=2c$, which must be an integer. ($\Leftarrow$) If $2c=n\in\mathbb{Z}$ and $a=m$, $b=k$ are integers, then the image has $b$-coordinate $k+2cm=k+nm\in\mathbb{Z}$ and unchanged $a$-coordinate $m\in\mathbb{Z}$. $\square$

The consequence is a genuine difference between the continuous and the discrete theories. Continuously, chirps form a full one-parameter group $\mathbb{R}$; discretely, only the lattice $\tfrac12\mathbb{Z}$ of chirp rates survives. The symmetry group of the discrete transform is therefore arithmetic rather than continuous, and the metaplectic sign of Section 7 has to be tracked over an arithmetic group — where, unlike over the contractible Borel, it cannot be normalised away by a continuous choice of branch.

---

## 9. Algorithms

Three constructions are algorithmically explicit and are what one implements.

**Algorithm A (Borel factorisation of a chirped Gaussian).** *Input* $(\alpha,\beta)$ with $\alpha>0$. *Output* $(u,c)$ with $G_{\alpha,\beta}=C_c D_u G_{1,0}$. *Method* $u=-\tfrac12\log\alpha$, $c=-\beta/2$ (Theorem 6.2). Cost $O(1)$. Correctness is Theorem 6.2; the map $(\alpha,\beta)\mapsto(u,c)$ is a global diffeomorphism onto $\mathbb{R}^2$, which is the analytic form of simple transitivity of $B$ on $\mathbb{H}$.

**Algorithm B (Metaplectic word evaluation).** *Input* a word $W$ in the letters $C_c$, $D_u$, $\mathcal F$. *Output* (i) the matrix $\pi(W)\in\mathrm{SL}_2(\mathbb{R})$ obtained by substituting $N_c$, $A_u$, $S$; (ii) the image of a given chirped Gaussian, tracked as a pair (complex width, accumulated scalar), using $\tau\mapsto\tau-2ic$ for a chirp, $\tau\mapsto e^{-2u}\tau$ for a dilation, and $\tau\mapsto1/\tau$ with scalar $\times\tau^{-1/2}$ for a Fourier transform. Cost $O(|W|)$. The Siegel parameters satisfy $z(\text{output})=\pi(W)\cdot z(\text{input})$ — Theorem 4.6 — while the accumulated scalar is the datum the matrix does not see.

**Algorithm C (Anomaly detector).** *Input* a word $W$ with $\pi(W)=\pm I$, a width $s$, a phase-space point $(a,b)$. *Output* the discrepancy between $W$ applied to the atom $g_{s,a,b}$ and the atom itself, measured by (i) $\sup_t\big||W g_{s,a,b}(t)|-|g_{s,a,b}(t)|\big|$ and (ii) the failure of $t\mapsto Wg_{s,a,b}(t)/g_{s,a,b}(t)$ to be constant. For $W=\mathcal F^2$ and $(a,b)\ne(0,0)$ both are nonzero, certifying Theorems 7.5 and 7.6; for $W=\mathcal F^4$ both vanish, certifying Corollary 7.2. Cost $O(N)$ per quadrature grid of $N$ points.

---

## 10. Applications

**Fractional Fourier transforms and chirp-rate estimation.** Radar, sonar, gravitational-wave templates, MRI gradient encoding and low-power chirp-spread-spectrum radio all produce signals that are locally chirps. The standard analysis tool is a rotation of phase space by an angle $\theta$ — the fractional Fourier transform — chosen so that the chirp aligns with the frequency axis and becomes a narrow line in the transform domain. Theorem 4.6 says that the correct window to use at angle $\theta$ is not a Gaussian but the chirped Gaussian whose Siegel parameter is the image of $i$ under the corresponding rotation. Theorem 6.2 gives its parameters in closed form.

**Branch bookkeeping in software.** Any implementation of the metaplectic/fractional family must choose a branch of a square root; Theorem 7.6 says that the resulting sign ambiguity is intrinsic, not a defect of the convention. Consistency requirements — that composing two transforms give the transform of the composition — can be met only up to $\pm1$, and libraries should expose that sign rather than silently choose it.

**Scale space.** Theorem 5.3 reinterprets the monotonicity used to justify coarse-to-fine analysis: increasing the window width is geodesic flow, and monotonicity of the detected mass is monotonicity along that geodesic. The hyperbolic metric on $\mathbb{H}$ then supplies a canonical, reparametrisation-invariant notion of "how far apart" two windows are — including chirped ones, which the classical scale-space picture cannot compare at all.

**Discrete transforms.** Theorem 8.1 tells the designer of a discrete Gabor scheme exactly which chirps are compatible with a given lattice: the half-integers, and no others. Shearing by a non-half-integer rate necessarily resamples.

---

## 11. Discussion

The results split cleanly along the topology of $\mathrm{SL}_2(\mathbb{R})$.

*Everything contractible lifts.* The Heisenberg group is normalised by both the chirp and the dilation subgroups (Theorems 3.3, 6.3), the resulting semidirect products carry faithful, honest representations by window operators (Theorem 3.6), and the Borel commutation relation holds identically on both sides (Theorem 6.1). No signs appear anywhere in this half of the theory. The one nontrivial phase, $\chi(ca^2)$ in the definition of $\sigma_c$, is a coboundary: it is precisely the correction that keeps the Weyl cocycle in its class, and its presence is forced by $c(a+a')^2=ca^2+2caa'+ca'^2$.

*Nothing about the rotation lifts.* The rotation subgroup is the circle in $\mathrm{SL}_2(\mathbb{R})$, and $\pi_1(\mathrm{SL}_2(\mathbb{R}))=\mathbb{Z}$ is generated by it. The class of the obstruction is detected already at the element $S^2=-I$ of order two, and the detection is completely elementary: two Gabor atoms at opposite phase-space points are not equal (Theorem 7.4) and not proportional (Theorem 7.6), yet the phase-space transformation relating them is the identity.

It is worth emphasising which invariants do the separating, since they are different in the two regimes. For $a\ne0$ the discriminating invariant is the *modulus*: the envelopes are bells centred at $\pm a$, and a Gaussian bell cannot be a constant multiple of its own reflection. For $a=0$, $b\ne0$ the envelopes coincide and the modulus is blind; the discriminating invariant is then the *quarter period* of the character $\chi$, evaluated at $t=1/(4b)$. The union of the two cases is exactly the hypothesis $(a,b)\neq(0,0)$, and at $(0,0)$ the phenomenon genuinely disappears because the Gaussian is even.

A structural reading of the whole development: window space is a homogeneous space for the metaplectic group, the plain Gaussians form one geodesic in it, and classical time–frequency analysis has been working on that geodesic. Completing to the chirped family replaces a line by a plane, replaces "width" by a point of $\mathbb{H}$, replaces "wider/narrower" by hyperbolic distance, and replaces three unrelated operator identities by one equivariance statement. The price of the completion is a sign.

**Limitations.** We work in one dimension; the multi-dimensional case replaces $\mathbb{H}$ by the Siegel upper half-space of symmetric complex matrices with positive-definite imaginary part, and $\mathbb{Z}/2$ by the Maslov index taking values in $\mathbb{Z}/4$ in general. We treat only Gaussian-type windows; the equivariance statements are specific to the chirped Gaussian family, which is the orbit of the Gaussian, though the anomaly statements concern Gabor atoms and are insensitive to that. Finally, the transitivity result is for the *lower* Borel: the upper unipotent, which translates the Siegel parameter horizontally, is not implemented by multiplication by a chirp.

---

## 12. Future directions

The present cycle established: the chirp operator normalises the Heisenberg group through the shear automorphism, giving $H\rtimes\mathbb{R}$ with a faithful window representation; the chirped Gaussians form an $\mathrm{SL}_2(\mathbb{R})$-equivariant family with chirp $=$ shear, dilation $=$ diagonal, Fourier $=$ rotation by $\pi/2$ acting by Möbius transformations on the Siegel parameter; the width parameter is the imaginary geodesic, so scale-space monotonicity is the diagonal flow and the chirp direction is transverse to it; the obstruction is genuine and of order two, with $S^2=-I$ acting trivially on phase space while $\mathcal F^2$ is parity on atoms, and in the discrete setting only the shears with $2c\in\mathbb{Z}$ preserve the integer Heisenberg lattice; and the obstruction is moreover projective, since rescaling $\mathcal F^2$ by an arbitrary complex constant still fails to reproduce the atom.

Three near-term problems and two longer-range ones follow.

### D1. An explicit metaplectic 2-cocycle for the Gabor window action

**Conjecture.** There is a function $m:\mathrm{SL}_2(\mathbb{R})\times\mathrm{SL}_2(\mathbb{R})\to\{\pm1\}$ such that the assignment $M\mapsto\rho(M)$ — the window operator implementing $M$ on the chirped Gaussian family, normalised by the positive square root of the width — satisfies
$$\rho(M)\rho(N)=m(M,N)\,\rho(MN),$$
$m$ is a nontrivial $2$-cocycle, and its restriction to the Borel subgroup is a coboundary.

The key insight is that the results above already separate the two regimes. The Borel subgroup lifts honestly (the operator relation $D_uC_cD_u^{-1}=C_{e^{-2u}c}$ matches the matrix relation exactly), and the failure is concentrated at the rotation, where $S^2=-I$ acts trivially on $\mathbb{H}$ while $\mathcal F^2$ is parity. So the cocycle is supported on the Weyl element and is exactly the Maslov sign. The infrastructure needed — Siegel parameter, three generators, the exact Fourier constant $\tau^{-1/2}$ — is in place; the only new ingredient is bookkeeping of the branch of $\tau^{1/2}$, which is where the sign lives. The first step is already discharged: the projective anomaly rules out the degenerate answer $m\equiv1$ by showing that no scalar rescaling of $\mathcal F^2$ acts as the identity on atoms, so any solution of the cocycle equation is necessarily nontrivial at the Weyl element.

### D2. The metaplectic anomaly of the discrete Gabor transform

**Conjecture.** For a multiset-supported (discrete) Gabor transform on the lattice $\Lambda=\mathbb{Z}\times\mathbb{Z}$, the subgroup of $\mathrm{SL}_2(\mathbb{R})$ acting on the lattice-supported windows is exactly $\mathrm{SL}_2(\mathbb{Z})$, and its lift to window operators is the restriction of the metaplectic cocycle to $\mathrm{SL}_2(\mathbb{Z})$ — a nontrivial class detected by the theta multiplier. The half-integrality found above ($2c\in\mathbb{Z}$) should be the first symptom: the shears in the lattice stabiliser are generated by $c=1/2$, whose square is the standard generator of the unipotent subgroup of $\mathrm{SL}_2(\mathbb{Z})$.

### D3. The fractional family and a continuous interpolation of the sign

Interpolate between the identity and $\mathcal F$ by the rotation subgroup and track the branch of $\tau^{-1/2}$ continuously along the path. The expected outcome is an explicit winding number computing the Maslov index, and a proof that the anomaly of Section 7 is its value at angle $\pi$.

### Longer range

**Higher dimensions.** Replace $\mathbb{H}$ by the Siegel upper half-space $\mathfrak{H}_n$ and $\mathrm{SL}_2(\mathbb{R})$ by $\mathrm{Sp}_{2n}(\mathbb{R})$; the chirp becomes multiplication by $e^{2\pi i\langle Qt,t\rangle}$ for a symmetric matrix $Q$, and the correction phase $\chi(ca^2)$ becomes $\chi(\langle Qa,a\rangle)$. All the algebra of Section 3 should go through verbatim; the anomaly becomes the Maslov index with values in $\mathbb{Z}/4$.

**Theta functions.** Combining D2 with the lattice picture, the discrete windows summed over $\Lambda$ produce theta series in the Siegel parameter, and the metaplectic sign becomes the classical theta multiplier. This would identify the "discrete metaplectic anomaly" with an object of number theory, closing the bridge from time–frequency analysis to modular forms.

---

## 13. Conclusion

Adding one operator — the chirp $e^{2\pi ict^2}$ — to the two classical Gabor generators completes the Heisenberg group to a semidirect product in which it is normal, completes the Gaussian window to a family parametrised by the hyperbolic plane, and turns three unrelated facts about windows (chirping, dilating, Fourier-transforming) into a single statement of $\mathrm{SL}_2(\mathbb{R})$-equivariance. Along the contractible directions the correspondence is exact. At the rotation it fails by exactly a sign: $S^2=-I$ moves no window parameter, yet the corresponding operator $\mathcal F^2$ reflects every Gabor atom through the origin of phase space, and no rescaling repairs it. The symmetry group of the Gabor window is not $\mathrm{SL}_2(\mathbb{R})$ but its double cover; discretely, only the half-integer shears survive, and the anomaly becomes arithmetic.
