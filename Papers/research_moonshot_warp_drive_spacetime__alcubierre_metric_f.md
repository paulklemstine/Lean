# The Alcubierre Warp Drive: Exact Energetics, Sharp Variational Bounds, and a Causality Dichotomy

**Author:** Aristotle
**Date:** 2026-08-17

---

## Abstract

We give a complete and rigorous analysis of the Alcubierre warp-drive geometry
$$ds^2 = -dt^2 + \bigl(dx - v_s f(r_s)\,dt\bigr)^2 + dy^2 + dz^2,$$
covering its causal structure, the exact stress-energy it demands, the sharp variational lower bound on that stress-energy, and its chronology properties.

Five groups of results are established. **(i) Structure.** At every event the metric is the pullback of the Minkowski metric along a unimodular shear; hence $\det g = -1$, the signature is $(-,+,+,+)$ everywhere, and the Einstein equations determine a stress-energy tensor globally. **(ii) Kinematics.** The ship's four-velocity is unit timelike for every warp speed, its coordinate velocity is unbounded, and its speed relative to the local Eulerian observers is exactly zero; every timelike direction obeys the strict local bound $|u^x/u^t - w| < 1$, where $w = v_sf$. The Eulerian expansion is $\theta = v_s\partial_x f$, strictly positive behind the ship and strictly negative ahead of it, and odd about the transverse plane through the ship. **(iii) Energetics.** The Hamiltonian constraint on flat slices yields the closed form $\rho = -\frac{v_s^2}{32\pi}\bigl((\partial_yf)^2 + (\partial_zf)^2\bigr) \le 0$, negative for every profile and every speed, with support a torus about the axis of motion; the momentum constraint yields $8\pi j^x = -\frac{v_s}{2}(\partial_y^2f + \partial_z^2 f)$ and $8\pi j^{y,z} = \frac{v_s}{2}\partial_x\partial_{y,z} f$, so the exotic matter cannot be at rest in the bubble frame. The total energy of a spherically symmetric bubble is $E = -\frac{v_s^2}{12}\int_0^\infty f'(r)^2r^2dr$; for a linear wall of thickness $\Delta$ at radius $R$ this is exactly $-\frac{v_s^2}{12}\bigl(R^2/\Delta + \Delta/12\bigr)$. **(iv) Scaling.** $E$ is exactly homogeneous of degree two in $v_s$ (while the momentum density is homogeneous of degree one), which formally refutes the conjecture $E \sim M v_s c$: no constant $C$ satisfies $E = Cv_s$ identically, and $|E|$ eventually exceeds every linear law. Over all admissible profiles supported in a shell $0 < a \le r \le b$ we prove the sharp bound $\int_a^b g^2r^2dr \ge ab/(b-a)$, attained uniquely by $g^*(r) = -\frac{ab}{(b-a)r^2}$; hence the $1/\Delta$ thin-wall divergence is universal, and the piecewise-linear wall exceeds the optimum by exactly $v_s^2\Delta/36$. **(v) Chronology.** A single bubble admits **no** closed causal curve, for any profile — coordinate time is a global time function and Rolle's theorem applies. But two corridors in relative motion do close a loop: for every $V > 1$ and $T > 0$, taking $\beta = 2V/(V^2+1) \in (0,1)$ produces a strictly positive second-leg duration returning the traveller to their exact departure event. Closed timelike curves are therefore a property not of the metric but of the *existence of two independently oriented warp corridors*.

**Keywords:** Alcubierre metric, warp drive, exotic matter, weak energy condition, ADM constraints, Raychaudhuri equation, closed timelike curves, variational lower bound.

---

## 1. Introduction

The Alcubierre warp drive is the standard example of a spacetime that transports a payload between distant events faster than a light signal confined to the ambient flat region, without any local violation of the light-speed bound. Its logical structure is inverted relative to most of general relativity: instead of positing matter and solving for geometry, one posits geometry and *reads off* the matter required. This makes almost every question about the drive a computation rather than a search, and it makes the interesting questions sharp:

1. Is the posited geometry a genuine Lorentzian metric everywhere, so that the "read off" stress-energy exists?
2. In what precise sense does the drive achieve superluminal transport without local superluminal motion?
3. What is the sign, magnitude, and spatial distribution of the required stress-energy?
4. How does the total exotic energy scale with the warp speed and the bubble geometry, and is there a floor below which no profile can go?
5. Does the drive generate closed timelike curves?

This paper answers all five, with exact statements and complete arguments. The results are organised so that each depends only on those before it. Throughout we use geometric units $c = G = 1$, signature $(-,+,+,+)$, Greek indices for spacetime and Latin for space.

### 1.1 Summary of contributions

- An exact algebraic characterisation of the metric as a unimodular shear of Minkowski space, giving nondegeneracy and signature uniformly in the warp factor (§2).
- A precise formulation and proof of "effective superluminal travel without local superluminal travel", including the strict local speed bound and the contrast with the ambient flat region (§3).
- The exact expansion structure of the Eulerian congruence: expansion behind, contraction ahead, exact oddness about the ship's transverse plane (§4).
- Closed-form energy density and momentum density from the ADM constraints, with an exact characterisation of the toroidal support of the exotic matter and a proof that the exotic matter must flow (§5, §6).
- An exact closed-form total energy for the piecewise-linear thin-wall bubble, exact quadratic homogeneity in the warp speed, and a formal refutation of the linear scaling conjecture $E \sim Mv_sc$ (§7).
- A sharp variational lower bound on the exotic energy over all admissible profiles confined to a shell, with the unique extremiser identified and the excess of the linear wall computed exactly (§8).
- A quantitative bridge to the focusing theory: the warp field as a Raychaudhuri energy defect, with the critical convergence threshold at which focusing guarantees fail (§9).
- A causality dichotomy: no closed causal curve for a single bubble; an explicit closed loop for two corridors in relative motion (§10).

---

## 2. The metric and its pointwise structure

### 2.1 Definition

**Definition 2.1 (Alcubierre ansatz).** Let $x_s : \mathbb{R} \to \mathbb{R}$ be the ship's trajectory with $v_s = \dot x_s$, let
$$r_s(t,x,y,z) = \sqrt{(x - x_s(t))^2 + y^2 + z^2},$$
and let $f : [0,\infty) \to [0,1]$ be a *shape function*, i.e. $f(0) = 1$ and $f(r) = 0$ for $r$ large. The Alcubierre line element is
$$ds^2 = -dt^2 + \bigl(dx - v_s f(r_s)\,dt\bigr)^2 + dy^2 + dz^2 .$$
Equivalently, in ADM (3+1) form, the lapse is $\alpha = 1$, the spatial metric is $\gamma_{ij} = \delta_{ij}$ (flat slices), and the shift is $\beta^i = (-v_sf(r_s), 0, 0)$.

Everything about the *pointwise* causal structure depends only on the scalar
$$w := v_s\,f(r_s) \qquad \text{(the local warp factor)},$$
so we study the one-parameter family of quadratic forms
$$Q_w(u) = -(u^0)^2 + (u^1 - w u^0)^2 + (u^2)^2 + (u^3)^2, \qquad u \in \mathbb{R}^4 .$$

**Definition 2.2 (Metric matrix).** In coordinates $(t,x,y,z)$,
$$g_{\mu\nu}(w) = \begin{pmatrix} w^2 - 1 & -w & 0 & 0 \\ -w & 1 & 0 & 0 \\ 0 & 0 & 1 & 0 \\ 0 & 0 & 0 & 1\end{pmatrix}, \qquad Q_w(u) = u^\mu g_{\mu\nu}(w) u^\nu .$$

**Definition 2.3 (Trivialising shear).** $S_w : (t,x,y,z) \mapsto (t,\,x - wt,\,y,\,z)$, with matrix having $1$ on the diagonal and $-w$ in the $(x,t)$ slot.

### 2.2 Nondegeneracy and signature

**Theorem 2.4 (Minkowski in disguise).** For every $w \in \mathbb{R}$,
$$S_w^{\mathsf T}\,\eta\,S_w = g(w), \qquad \eta = \mathrm{diag}(-1,1,1,1), \qquad \det S_w = 1 .$$
Consequently $Q_w(u) = \eta(S_wu, S_wu)$ for all $u$.

*Proof.* Direct expansion of the $4\times 4$ product; only the upper-left $2\times 2$ block is nontrivial, where $(-1)\cdot 1 + (-w)^2 = w^2 - 1$ and $(-w)\cdot 1 \cdot 1$ gives the off-diagonal $-w$. The shear is lower triangular with unit diagonal, so its determinant is $1$. $\square$

**Corollary 2.5 (Global nondegeneracy).** $\det g(w) = -1$ for every warp factor. Hence the metric never degenerates, its inverse exists everywhere, and the Einstein tensor $G_{\mu\nu}$ — and therefore the stress-energy $T_{\mu\nu} = G_{\mu\nu}/8\pi$ that sources it — is defined at every event.

**Corollary 2.6 (Lorentzian signature).** For every $w$ there is a unimodular $S$ with $S^{\mathsf T}\eta S = g(w)$; by Sylvester's law of inertia the signature is $(-,+,+,+)$ everywhere.

**Remark 2.7.** Corollary 2.5 is why the frequently posed question "is the Alcubierre metric a solution of Einstein's equations?" is, strictly, trivial: it is, by construction, for the stress-energy defined by its own Einstein tensor. The nontrivial content — the subject of §5–§8 — is the *sign and size* of that stress-energy.

---

## 3. Causal structure: superluminal transport without local superluminal motion

**Definition 3.1.** A tangent vector $u$ is *causal* at an event with warp factor $w$ if $Q_w(u) \le 0$, and *timelike* if $Q_w(u) < 0$.

**Lemma 3.2 (Coordinate time is a time function).** If $u$ is causal and nonzero then $u^0 \neq 0$. If $u$ is timelike then $u^0 \neq 0$.

*Proof.* Suppose $u^0 = 0$. Then $Q_w(u) = (u^1)^2 + (u^2)^2 + (u^3)^2 \ge 0$, with equality iff $u$ vanishes. So $Q_w(u) \le 0$ forces $u = 0$, and $Q_w(u) < 0$ is impossible. $\square$

Equivalently, $g^{tt} = -1 < 0$: the level sets of $t$ are spacelike Cauchy slices. This single fact drives the chronology-protection result of §10.

**Definition 3.3 (Eulerian observers).** The observers orthogonal to the slices $t = \mathrm{const}$ have four-velocity $n = (1, w, 0, 0)$.

**Lemma 3.4.** $Q_w(n) = -1$: the Eulerian observers are unit timelike, for every $w$.

*Proof.* $Q_w(1,w,0,0) = -1 + (w - w)^2 = -1$. $\square$

**Theorem 3.5 (Strict local speed bound).** If $u$ is timelike at an event with warp factor $w$, then
$$\left| \frac{u^1}{u^0} - w \right| < 1 .$$
That is, the coordinate $x$-velocity is confined to the open interval $(w-1, w+1)$: relative to the local Eulerian observer, every timelike direction moves strictly slower than light.

*Proof.* By Lemma 3.2, $u^0 \neq 0$. Timelikeness gives $(u^1 - wu^0)^2 + (u^2)^2 + (u^3)^2 < (u^0)^2$, hence $(u^1 - wu^0)^2 < (u^0)^2$. Dividing by $(u^0)^2 > 0$ yields $(u^1/u^0 - w)^2 < 1$. $\square$

**Theorem 3.6 (Effective FTL without local FTL).** For every $v_s \in \mathbb{R}$, the vector $u = (1, v_s, 0, 0)$ satisfies:
1. $Q_{v_s}(u) = -1$, so it is unit timelike;
2. its coordinate velocity is $u^1/u^0 = v_s$, which is unbounded;
3. its velocity relative to the local Eulerian observer is $|u^1/u^0 - v_s| = 0$.

Moreover its proper time equals coordinate time: $\sqrt{-Q_{v_s}(u)} = 1$.

*Proof.* Immediate from Lemma 3.4 with $w = v_s$, which is the warp factor at the ship, where $f = 1$. $\square$

**Theorem 3.7 (Contrast with the ambient region).** In the asymptotic region where $f = 0$ (hence $w = 0$), the vector $(1, v, 0, 0)$ with $v > 1$ is *not* causal: $Q_0 = v^2 - 1 > 0$.

*Proof.* Direct evaluation. $\square$

Theorems 3.6 and 3.7 together are the precise content of the warp drive: an identical coordinate motion is spacelike (forbidden) outside the bubble and unit timelike (utterly ordinary) inside it. The bubble carries its light cones with it.

**Theorem 3.8 (Causal-control horizon).** Fix $\delta > 0$ and consider the outer region where $w = v_sf \le v_s - 1 - \delta$ — a region that necessarily exists whenever $v_s > 1$, since $f \to 0$ at infinity. Along every future-directed causal curve confined to that region, the separation $x - v_st$ from the bubble centre is strictly decreasing.

*Proof.* For a future-directed causal $u$ (i.e. $u^0 > 0$), the bound $Q_w(u) \le 0$ gives $u^1 \le (w+1)u^0$. Hence $\frac{d}{ds}(x - v_st) = u^1 - v_su^0 \le (w + 1 - v_s)u^0 \le -\delta u^0 < 0$. Strict antitonicity follows from the mean value theorem. $\square$

Physically: no causal influence originating in the outer region can keep up with the bubble. Signals from the ship cannot reach the leading wall, so a superluminal bubble is uncontrollable from inside — the familiar horizon obstruction, here in elementary form.

---

## 4. Expansion of space: behind and ahead

**Definition 4.1 (Expansion tensor).** Since the lapse is unity and the slices are flat, the expansion tensor of the Eulerian congruence is the symmetrised spatial gradient of the shift field $n^i = (v_sf,0,0)$:
$$\theta_{ij} = \tfrac12(\partial_i n_j + \partial_j n_i) .$$
Writing $g_k = \partial_k f$ for the spatial gradient of the shape function ($k \in \{x,y,z\}$), we have
$$\theta = v_s\begin{pmatrix} g_x & g_y/2 & g_z/2 \\ g_y/2 & 0 & 0 \\ g_z/2 & 0 & 0\end{pmatrix}, \qquad \theta := \mathrm{tr}\,\theta_{ij} = v_s\, g_x .$$
(The extrinsic curvature is $K_{ij} = -\theta_{ij}$; the constraints below are quadratic in $K$, hence insensitive to this sign.)

**Lemma 4.2 (Quadratic invariants).**
$$\theta_{ij}\theta^{ij} = v_s^2 g_x^2 + \tfrac{v_s^2}{2}\bigl(g_y^2 + g_z^2\bigr), \qquad\text{hence}\qquad \theta^2 - \theta_{ij}\theta^{ij} = -\frac{v_s^2}{2}\bigl(g_y^2 + g_z^2\bigr) .$$

*Proof.* The tensor has one diagonal entry $v_sg_x$ and four off-diagonal entries $v_sg_y/2$, $v_sg_z/2$ (each appearing twice); summing squares gives the first identity, and subtracting from $\theta^2 = v_s^2g_x^2$ gives the second. $\square$

Lemma 4.2 is the algebraic heart of the negativity of the energy: the trace-squared cancels exactly, leaving minus a sum of squares of the **transverse** gradient.

**Definition 4.3 (Radial shape functions).** For spherically symmetric $f = f(r_s)$ with $r_s = \sqrt{(x-a)^2 + y^2 + z^2}$ (the ship at $x = a$) and $f'(r_s) = df$, the chain rule gives
$$\nabla f = df\cdot\frac{(x-a,\,y,\,z)}{r_s}, \qquad \theta = v_s\,df\,\frac{x-a}{r_s} .$$

**Theorem 4.4 (Expansion behind, contraction ahead).** Let $v_s > 0$ and $df < 0$ (a decreasing shape function). Then off the ship's own position:
1. $\theta > 0$ for every point behind the ship, $x < a$;
2. $\theta < 0$ for every point ahead of the ship, $x > a$;
3. $\theta = 0$ if and only if $x = a$, i.e. exactly on the transverse plane through the ship;
4. the expansion is odd about that plane: $\theta(a + s, y, z) = -\theta(a - s, y, z)$.

*Proof.* Parts 1–3 are the sign of the factor $(x-a)$ in Definition 4.3, since $v_s\,df < 0$ and $r_s > 0$. Part 4 follows because $r_s$ is even in $x - a$ while $x - a$ is odd. $\square$

This is the mechanism of transport: volume is created astern and destroyed ahead in exactly balanced amounts, and the ship is carried without ever being accelerated relative to its neighbours.

---

## 5. Energy density: unconditional exotic matter

Because the slices are flat, their intrinsic Ricci scalar vanishes, and the Hamiltonian (energy) constraint of the ADM decomposition reduces to
$$16\pi\rho = R^{(3)} + K^2 - K_{ij}K^{ij} = \theta^2 - \theta_{ij}\theta^{ij}, \qquad \rho := T_{\mu\nu}n^\mu n^\nu .$$

**Definition 5.1.** $\displaystyle \rho(v_s, \nabla f) := \frac{\theta^2 - \theta_{ij}\theta^{ij}}{16\pi}$.

**Theorem 5.2 (Closed form).**
$$\rho = -\frac{v_s^2\bigl((\partial_yf)^2 + (\partial_zf)^2\bigr)}{32\pi} .$$

*Proof.* Substitute Lemma 4.2 into Definition 5.1. $\square$

**Theorem 5.3 (Unconditional negativity).** $\rho \le 0$ for every shape function and every warp speed. Moreover $\rho < 0$ if and only if $v_s \neq 0$ and the transverse gradient $(\partial_yf, \partial_zf)$ is nonzero.

*Proof.* The numerator in Theorem 5.2 is minus a nonnegative quantity; it is strictly negative exactly when both factors are nonzero. $\square$

**Theorem 5.4 (Alcubierre's formula).** For a spherically symmetric shape function with radial derivative $df$ at a point where $r_s > 0$,
$$\rho = -\frac{1}{8\pi}\cdot\frac{v_s^2\,(y^2+z^2)}{4\,r_s^2}\cdot\left(\frac{df}{dr_s}\right)^{\!2} .$$

*Proof.* Insert $\partial_yf = df\,y/r_s$, $\partial_zf = df\,z/r_s$ into Theorem 5.2 and simplify. $\square$

**Theorem 5.5 (Toroidal support of the exotic matter).** For $v_s \neq 0$ and $r_s > 0$,
$$\rho = 0 \iff \bigl(df = 0 \ \text{ or } \ (y,z) = (0,0)\bigr).$$
Hence the negative energy vanishes identically on the axis of travel and wherever the shape function is locally constant, and is strictly negative everywhere else: it forms a torus encircling the direction of motion, with empty space directly ahead of and behind the ship.

*Proof.* Immediate from Theorem 5.4, whose right-hand side is a product of $(y^2+z^2)$ and $df^2$ with a strictly positive coefficient. $\square$

**Theorem 5.6 (Weak energy condition violation).** The Eulerian observer $n = (1,w,0,0)$ is unit timelike (Lemma 3.4) and measures $\rho < 0$ at every off-axis point of a nonconstant bubble wall. Hence no classical matter satisfying the weak energy condition can source an Alcubierre bubble.

*Proof.* Combine Lemma 3.4 with Theorem 5.5. $\square$

---

## 6. Momentum density: the exotic matter must flow

The second half of the Einstein equations is the momentum constraint
$$8\pi j^i = D_j\bigl(K^{ij} - \gamma^{ij}K\bigr), \qquad j^i := -T^{\mu\nu}n_\mu\,\gamma^i_{\ \nu} .$$
On flat slices this is purely algebraic in the Hessian $H_{ij} = \partial_i\partial_j f$, because $\theta_{ij} = \frac{v_s}{2}(\delta_{ix}\partial_jf + \delta_{jx}\partial_if)$.

**Theorem 6.1 (Longitudinal flux).** $\displaystyle 8\pi\,j^x = -\frac{v_s}{2}\bigl(\partial_y^2 f + \partial_z^2 f\bigr)$: minus the *transverse Laplacian* of the shape function.

**Theorem 6.2 (Transverse flux).** For a symmetric Hessian, $\displaystyle 8\pi\,j^y = \frac{v_s}{2}\,\partial_x\partial_y f$ and $\displaystyle 8\pi\,j^z = \frac{v_s}{2}\,\partial_x\partial_z f$.

*Proof of 6.1–6.2.* Expand $\sum_j \partial_j\theta_{ij} - \partial_i\theta$ using the explicit $\theta_{ij}$. For $i = x$: $\sum_j\partial_j\theta_{xj} = v_s\partial_x^2f + \frac{v_s}{2}(\partial_y^2f + \partial_z^2f)$ while $\partial_x\theta = v_s\partial_x^2f$, leaving $\frac{v_s}{2}(\partial_y^2f + \partial_z^2f)$; the sign flip comes from $K_{ij} = -\theta_{ij}$. For $i = y$: $\sum_j\partial_j\theta_{yj} = \frac{v_s}{2}\partial_x\partial_yf$ and $\partial_y\theta = v_s\partial_x\partial_yf$, leaving $-\frac{v_s}{2}\partial_x\partial_yf$; similarly for $z$. $\square$

**Theorem 6.3 (No momentum-free bubble).** For $v_s \neq 0$ and symmetric Hessian, the source is momentum-free ($j^i = 0$ for all $i$) if and only if
$$\partial_y^2f + \partial_z^2f = 0, \qquad \partial_x\partial_yf = 0, \qquad \partial_x\partial_zf = 0,$$
i.e. the shape function is transversally harmonic with no mixed second derivatives. A bubble with a genuinely varying wall satisfies none of these; hence its exotic matter necessarily carries energy flux and cannot be dust at rest in the bubble frame.

**Theorem 6.4 (Degree-one homogeneity).** $j^i(\lambda v_s) = \lambda\, j^i(v_s)$ for every $i$.

*Proof.* Each expression in Theorems 6.1–6.2 is linear in $v_s$. $\square$

The contrast between the degree-two homogeneity of $\rho$ (Theorem 5.2) and the degree-one homogeneity of $j^i$ is not a curiosity: it is the structural fact that decides the scaling question of §7. The Hamiltonian constraint is *quadratic* in the extrinsic curvature, the momentum constraint *linear*, while $K$ itself is exactly linear in the shift.

---

## 7. Total energy: exact formula and the failure of the linear conjecture

### 7.1 Reduction to a radial functional

Integrating $\rho$ over a slice for a spherically symmetric $f$, the angular integral is elementary: $\langle (y^2+z^2)/r^2\rangle_{S^2} = 2/3$, i.e. $\int_{S^2}\frac{y^2+z^2}{r^2}d\Omega = \frac{8\pi}{3}$. Hence
$$E = \int \rho\, d^3x = -\frac{v_s^2}{32\pi}\int (f')^2\frac{y^2+z^2}{r^2}\,d^3x = -\frac{v_s^2}{32\pi}\cdot\frac{8\pi}{3}\int_0^\infty (f'(r))^2 r^2\,dr .$$

**Definition 7.1 (Radial warp energy).** For a radial derivative profile $g = f'$,
$$E(v_s, g) := -\frac{v_s^2}{12}\int_0^\infty g(r)^2\,r^2\,dr .$$

**Theorem 7.2 (Nonpositivity).** $E(v_s,g) \le 0$ for every profile.

*Proof.* The integrand is nonnegative and the prefactor nonpositive. $\square$

**Theorem 7.3 (Exact quadratic homogeneity).** $E(\lambda v_s, g) = \lambda^2 E(v_s, g)$ for every $\lambda$, $v_s$ and every profile $g$, integrable or not.

*Proof.* The warp speed enters only through the overall factor $v_s^2$. $\square$

### 7.2 The thin-wall bubble

**Definition 7.4 (Piecewise-linear wall).** For $R > 0$ and $0 < \Delta < 2R$,
$$f_{R,\Delta}(r) = \begin{cases} 1, & r \le R - \Delta/2,\\[2pt] \dfrac{R + \Delta/2 - r}{\Delta}, & R - \Delta/2 < r < R + \Delta/2,\\[6pt] 0, & r \ge R + \Delta/2,\end{cases} \qquad f'_{R,\Delta}(r) = \begin{cases} -1/\Delta, & |r - R| < \Delta/2,\\ 0, & \text{else.}\end{cases}$$

**Lemma 7.5.** $f_{R,\Delta}$ takes values in $[0,1]$, is differentiable except at the two wall edges, and has the stated derivative.

**Theorem 7.6 (Exact thin-wall energy).** For $0 < \Delta < 2R$,
$$E\bigl(v_s, f'_{R,\Delta}\bigr) \;=\; -\frac{v_s^2R^2}{12\Delta} - \frac{v_s^2\Delta}{144} \;=\; -\frac{v_s^2}{12}\left(\frac{R^2}{\Delta} + \frac{\Delta}{12}\right).$$

*Proof.* The integrand $g^2r^2$ is the indicator of the wall times $r^2/\Delta^2$, so
$$\int_0^\infty g^2r^2dr = \frac{1}{\Delta^2}\int_{R - \Delta/2}^{R + \Delta/2} r^2\,dr = \frac{(R+\Delta/2)^3 - (R-\Delta/2)^3}{3\Delta^2} = \frac{R^2}{\Delta} + \frac{\Delta}{12}.$$
Multiplying by $-v_s^2/12$ gives the claim. $\square$

**Corollary 7.7 (Strict negativity).** $E < 0$ for every $v_s \neq 0$.

**Theorem 7.8 (Thin-wall blow-up).** For fixed $R > 0$, $v_s \neq 0$, and any bound $B > 0$, there is $\Delta_0 > 0$ such that $E < -B$ for all $0 < \Delta < \Delta_0$. Explicitly, $\Delta_0 = \min\bigl(R,\ v_s^2R^2/(12B)\bigr)$ suffices.

*Proof.* $|E| \ge v_s^2R^2/(12\Delta) > B$ whenever $\Delta < v_s^2R^2/(12B)$. $\square$

**Numerical instances.** $E(2, f'_{100,1}) = -120001/36 \approx -3333.361$, and $E(4, f'_{100,1}) = 4\,E(2,f'_{100,1})$ exactly — the numerical fingerprint of quadratic scaling.

### 7.3 Refutation of $E \sim M v_s c$

A frequently proposed heuristic is that the exotic energy budget should be proportional to the ship mass times the warp speed, $E \sim M v_s c$. In geometric units this asserts $E = C v_s$ for a constant $C$ (a multiple of the ship mass). It is false.

**Theorem 7.9 (No linear law).** Fix a bubble geometry $(R,\Delta)$ with $0 < \Delta < 2R$. There is **no** constant $C \in \mathbb{R}$ with $E(v_s, f'_{R,\Delta}) = C v_s$ for all $v_s$.

*Proof.* Suppose such $C$ exists. Setting $v_s = 1$ gives $C = E(1)$, and $v_s = 2$ gives $E(2) = 2C = 2E(1)$. But Theorem 7.3 gives $E(2) = 4E(1)$, so $2E(1) = 4E(1)$, i.e. $E(1) = 0$, contradicting Corollary 7.7. $\square$

**Theorem 7.10 (The energy outruns every linear law).** For every $M > 0$ there is $v_0 = M/K > 0$, with $K = R^2/(12\Delta) + \Delta/144 > 0$, such that $|E(v_s)| > M v_s$ for all $v_s > v_0$.

*Proof.* $E(v_s) = -v_s^2K$, so $|E(v_s)| = v_s^2K = v_s\,(v_sK) > v_s M$ whenever $v_sK > M$, i.e. $v_s > M/K$. $\square$

**Remark 7.11 (Why the heuristic fails).** The correct scaling degree is dictated by structure, not by the profile: the Hamiltonian constraint is exactly quadratic in the extrinsic curvature $K$, and $K$ is exactly linear in the shift, hence in $v_s$. Degree $2\times 1 = 2$. The linear guess is the correct scaling for the *momentum* density (Theorem 6.4), not for the energy.

---

## 8. The sharp variational floor: no profile is cheap

Theorem 7.6 is one design. Could a smarter wall be dramatically cheaper? The question is a constrained variational problem with an exact answer.

**Setup.** Let the wall be confined to a shell $0 < a \le r \le b$. Admissibility of a shape function means it falls from $1$ at the inner edge to $0$ at the outer, i.e. its derivative $g = f'$ satisfies the single normalisation
$$\int_a^b g(r)\,dr = -1 .$$
The cost to minimise is $I[g] = \int_a^b g(r)^2 r^2\,dr$, since $E = -\frac{v_s^2}{12}I[g]$.

**Definition 8.1 (Geometric floor).** $\displaystyle \lambda(a,b) := \frac{ab}{b - a} > 0$ for $0 < a < b$.

**Lemma 8.2.** $\displaystyle \int_a^b \frac{dr}{r^2} = \frac1a - \frac1b = \frac{1}{\lambda(a,b)}$.

**Theorem 8.3 (Sharp lower bound).** For every $g$ integrable on $[a,b]$ with $g^2r^2$ integrable and $\int_a^b g = -1$,
$$I[g] = \int_a^b g(r)^2r^2\,dr \;\ge\; \lambda(a,b) = \frac{ab}{b-a} .$$
Equivalently the exotic energy obeys $E \le -\frac{v_s^2}{12}\cdot\frac{ab}{b-a} < 0$.

*Proof (completed square).* Write $\lambda = \lambda(a,b)$. For every $r \in [a,b]$,
$$g(r)^2r^2 + 2\lambda g(r) + \frac{\lambda^2}{r^2} = \left(g(r)r + \frac{\lambda}{r}\right)^{\!2} \ \ge\ 0 .$$
All three terms are integrable on $[a,b]$, so integrating and using $\int g = -1$ and Lemma 8.2,
$$0 \le I[g] + 2\lambda(-1) + \lambda^2\cdot\frac1\lambda = I[g] - \lambda ,$$
which is the claim. $\square$

**Definition 8.4 (Optimal profile).** $\displaystyle g^*(r) := -\frac{\lambda(a,b)}{r^2}$, corresponding to the shape function
$$f^*(r) = \frac{a}{r}\cdot\frac{b-r}{b-a},$$
which indeed satisfies $f^*(a) = 1$, $f^*(b) = 0$.

**Theorem 8.5 (Attainment and sharpness).** $g^*$ is admissible, $\int_a^b g^* = -1$, and $I[g^*] = \lambda(a,b)$. Hence $\lambda(a,b)$ is the *minimum* — not merely a lower bound — of $I$ over admissible profiles supported in the shell.

*Proof.* $\int_a^b g^* = -\lambda\int_a^b r^{-2}dr = -\lambda\cdot\frac1\lambda = -1$ by Lemma 8.2, and $I[g^*] = \lambda^2\int_a^b r^{-2}dr = \lambda$. Combined with Theorem 8.3 this exhibits $\lambda$ as the least element of the set of achievable costs. $\square$

The extremiser is exactly the Euler–Lagrange solution: stationarity of $\int g^2r^2 - 2\mu\int g$ gives $g \propto 1/r^2$, and the normalisation fixes the constant. The floor is *geometric* — it depends only on the shell, not on any freedom in the profile.

**Theorem 8.6 (Floor of a wall of thickness $\Delta$).** For $a = R - \Delta/2$, $b = R + \Delta/2$,
$$\lambda = \frac{R^2}{\Delta} - \frac{\Delta}{4} .$$

**Theorem 8.7 (The linear wall is nearly optimal).** For $0 < \Delta < 2R$,
$$\underbrace{\left(-\frac{v_s^2}{12}\lambda\right)}_{\text{optimal energy}} - \underbrace{E\bigl(v_s, f'_{R,\Delta}\bigr)}_{\text{linear wall}} = \frac{v_s^2\Delta}{36} .$$
That is, the naive piecewise-linear design exceeds the optimum by exactly $v_s^2\Delta/36$ — an $O(\Delta)$ correction against an $O(1/\Delta)$ main term.

*Proof.* Subtract $-\frac{v_s^2}{12}(R^2/\Delta + \Delta/12)$ from $-\frac{v_s^2}{12}(R^2/\Delta - \Delta/4)$: the difference is $-\frac{v_s^2}{12}(-\Delta/4 - \Delta/12) = \frac{v_s^2}{12}\cdot\frac{\Delta}{3} = \frac{v_s^2\Delta}{36}$. $\square$

**Theorem 8.8 (Universality of the thin-wall divergence).** For every admissible profile whose wall is confined to the shell of thickness $\Delta$ at radius $R$,
$$|E| \ \ge\ \frac{v_s^2}{12}\left(\frac{R^2}{\Delta} - \frac{\Delta}{4}\right).$$
No engineering of the profile can avoid the $1/\Delta$ blow-up as the wall is thinned.

*Proof.* Theorem 8.3 with $a = R - \Delta/2$, $b = R + \Delta/2$, then Theorem 8.6, multiplied by $v_s^2/12 \ge 0$. $\square$

---

## 9. The warp field as a Raychaudhuri defect

The negativity of $\rho$ acquires operational meaning through the focusing theory. Raychaudhuri's equation, in the degraded form used when an energy condition is violated by at most $c \ge 0$, reads
$$\frac{d\theta}{d\lambda} \ \le\ -\frac{\theta^2}{m} + c ,$$
where $m$ is the dimension of the congruence's transverse space and $\theta$ its convergence.

**Definition 9.1 (Warp defect).** $\displaystyle c_{\mathrm{warp}}(v_s,\nabla f) := -16\pi\rho = \frac{v_s^2}{2}\bigl((\partial_yf)^2 + (\partial_zf)^2\bigr) \ \ge\ 0$.

**Theorem 9.2.** $c_{\mathrm{warp}} \ge 0$ always, and $c_{\mathrm{warp}} > 0$ exactly when $v_s \neq 0$ and the transverse gradient is nonzero — i.e. exactly on the toroidal exotic region of Theorem 5.5.

**Theorem 9.3 (Focusing survives above threshold).** If a congruence enters the wall with convergence
$$\theta_0 \ <\ -\,v_s\sqrt{\tfrac{m}{2}\bigl((\partial_yf)^2 + (\partial_zf)^2\bigr)} \qquad \bigl(\text{equivalently } \theta_0^2 > m\,c_{\mathrm{warp}}\bigr),$$
then it still focuses, within affine parameter
$$\Lambda \ \le\ \frac{m\,|\theta_0|}{\theta_0^2 - m\,c_{\mathrm{warp}}} .$$

**Theorem 9.4 (Failure at the critical convergence).** At the critical value $\theta_0^2 = m\,c_{\mathrm{warp}}$ the focusing guarantee fails: there exists an eternal solution of the degraded Raychaudhuri inequality that never focuses.

*Proof sketch.* At criticality the right-hand side $-\theta^2/m + c_{\mathrm{warp}}$ vanishes at $\theta = \theta_0$, so the constant function $\theta \equiv \theta_0$ solves the inequality for all affine parameter. Above criticality the differential inequality forces $\theta$ through $-\infty$ within the stated parameter interval by comparison with the separable equation $\theta' = -\theta^2/m + c$. $\square$

**Theorem 9.5 (Quadratic defect scaling).** $c_{\mathrm{warp}}(\lambda v_s) = \lambda^2 c_{\mathrm{warp}}(v_s)$: doubling the warp speed quadruples the amount of focusing the drive can defeat.

The interpretation is sharp: the exotic matter of a warp bubble is of *precisely* the strength required to defeat geodesic focusing, and its anti-focusing power scales exactly like its energy cost.

---

## 10. Chronology: a dichotomy

### 10.1 One bubble: no closed causal curve

**Theorem 10.1 (Chronology protection for a single bubble).** Let $\gamma : [0,1] \to \mathbb{R}^4$ be differentiable with tangent $u$, let $w : [0,1] \to \mathbb{R}$ be an arbitrary (possibly wildly varying) warp factor along the curve, and suppose:
1. $u(s)$ is causal for $Q_{w(s)}$ at every $s$;
2. $u(s) \neq 0$ at every $s$;
3. $\gamma(0) = \gamma(1)$.

Then a contradiction follows: **no such curve exists**. Hence the Alcubierre ansatz — for any shape function, warp speed, or ship trajectory — contains no closed causal curve.

*Proof.* The time component $t(s) = \gamma^0(s)$ is continuous on $[0,1]$, differentiable on $(0,1)$, and satisfies $t(0) = t(1)$. By Rolle's theorem there is $c \in (0,1)$ with $\dot t(c) = u^0(c) = 0$. But $u(c)$ is causal and nonzero, so Lemma 3.2 gives $u^0(c) \neq 0$. Contradiction. $\square$

The mechanism is that $g^{tt} = -1 < 0$ uniformly, so $t$ is a global time function and the spacetime is foliated by flat Cauchy slices. A single warp bubble is causally harmless.

### 10.2 The frame-dependence of a corridor

A warp corridor is not a covariant object: it is *built*, at rest in some inertial frame, by some agent. Different agents can choose different frames — and that is where causality fails.

**Definition 10.2 (Boost).** For $|\beta| < 1$ let $\kappa = \sqrt{1-\beta^2} > 0$ and
$$T'(\beta;t,x) = \frac{t - \beta x}{\kappa}, \qquad X'(\beta;t,x) = \frac{x - \beta t}{\kappa} .$$

**Lemma 10.3.** Boosts fix the origin and preserve the interval: $-T'^2 + X'^2 = -t^2 + x^2$.

*Proof.* $(t-\beta x)^2 - (x - \beta t)^2 = (1-\beta^2)(t^2 - x^2)$, and dividing by $\kappa^2 = 1-\beta^2$ gives the claim. $\square$

**Theorem 10.4 (A warp leg is spacelike in the background frame).** For $V > 1$ and $T > 0$, the displacement of a warp leg from the origin to $(T, VT)$ has
$$-T^2 + (VT)^2 = T^2(V^2 - 1) \ >\ 0 :$$
it is **spacelike**. No ordinary causal curve of the ambient flat region joins departure to arrival.

Yet inside the corridor the same leg is unit timelike (Theorem 3.6, with local warp factor $V$). This juxtaposition is the definition of the drive; it is also the mechanism of the paradox.

### 10.3 Two corridors close a loop

**Lemma 10.5 (Return-leg alignment).** If $\beta(V^2 + 1) = 2V$, then
$$X'\bigl(\beta;\,T,\,VT\bigr) \;=\; V\cdot\bigl(-\,T'(\beta;\,T,\,VT)\bigr).$$

*Proof.* $X' = T(V - \beta)/\kappa$ and $-T' = T(\beta V - 1)/\kappa$, so the claim is $V - \beta = V(\beta V - 1)$, i.e. $2V = \beta(V^2+1)$. $\square$

**Theorem 10.6 (Two corridors in relative motion close a loop).** For every effective warp speed $V > 1$ and every duration $T > 0$ there exist a boost velocity $\beta$ with $0 < \beta < 1$ and a **strictly positive** duration $s$ such that, writing $(T', X')$ for the boosted coordinates of the arrival event $(T, VT)$,
$$T' + s = 0 \qquad\text{and}\qquad X' - Vs = 0 .$$
Explicitly, one may take
$$\beta = \frac{2V}{V^2+1} \in (0,1), \qquad s = -T'(\beta;T,VT) = \frac{T(V^2-1)}{(V^2+1)\sqrt{1-\beta^2}} > 0 .$$
Interpretation: the traveller takes a corridor at rest in the background frame $S$ from the origin to $(T, VT)$, then a corridor of the same effective speed $V$ built at rest in the boosted frame $S'$ and pointed backwards. After $S'$-duration $s > 0$ they arrive at the origin of $S'$ — the very event from which they departed.

*Proof.* For $V > 1$ set $\beta = 2V/(V^2+1)$. Then $\beta > 0$, and $\beta < 1$ because $V^2 + 1 - 2V = (V-1)^2 > 0$. Also $\beta V = 2V^2/(V^2+1) > 1$ because $2V^2 - V^2 - 1 = (V-1)(V+1) > 0$. Therefore
$$T' = \frac{T - \beta VT}{\kappa} = \frac{T(1 - \beta V)}{\kappa} < 0,$$
so $s := -T' > 0$ and $T' + s = 0$ by construction. Lemma 10.5 gives $X' = V(-T') = Vs$, hence $X' - Vs = 0$. $\square$

**Remark 10.6a (A symmetric loop).** For this choice of boost the numbers are strikingly clean. Since $\kappa = \sqrt{1-\beta^2} = (V^2-1)/(V^2+1)$ and $1 - \beta V = -(V^2-1)/(V^2+1)$, one gets exactly $T' = -T$ and $X' = VT$. The second leg therefore has the *same* duration $T$ and the *same* effective speed $V$ as the first, viewed in its own construction frame: the loop is perfectly symmetric under exchange of the two corridors.

**Corollary 10.7 (Return to one's own past).** For every $V > 1$, $T > 0$ there is $\beta \in (0,1)$ with $T'(\beta;T,VT) < 0$: the first leg has already carried the traveller into the past of the frame in which the second corridor is built. With a slightly smaller boost the second leg deposits them at their spatial starting point strictly before departure.

**Theorem 10.8 (The dichotomy).** For every $V > 1$, $T > 0$:
1. *(Chronology protection.)* No closed causal curve exists in any Alcubierre spacetime, for any shape function, warp speed, or trajectory (Theorem 10.1).
2. *(Chronology violation.)* There exist $\beta \in (0,1)$ and $s > 0$ closing the two-leg loop of Theorem 10.6.

Hence closed timelike curves are **not** a property of the Alcubierre metric itself, but of the *existence of two independently oriented warp corridors*.

**Remark 10.9.** This is exactly the tachyonic antitelephone, realised by geometry rather than by hypothetical superluminal particles — and here every ingredient (the boost velocity, the return-leg duration, the closure of the loop) is given in closed form. The moral is not that any one warp spacetime is inconsistent; each one is a perfectly well-behaved globally hyperbolic geometry. The moral is that *superluminal transport plus Lorentz invariance* is the inconsistent combination. If a theory permits warp corridors to be constructed at rest in arbitrary inertial frames, it permits time travel. Any consistent theory of warp drives must therefore break the arbitrariness — for instance by a preferred frame, or by an obstruction to constructing the second corridor.

---

## 11. Algorithms

The results above translate directly into finite computational procedures.

**Algorithm A (Exact thin-wall energy).** Given $(v_s, R, \Delta)$ with $0 < \Delta < 2R$, return
$$E = -\frac{v_s^2}{12}\left(\frac{R^2}{\Delta} + \frac{\Delta}{12}\right).$$
Constant time; exact in rational arithmetic.

**Algorithm B (Variational floor and optimality gap).** Given $(v_s, R, \Delta)$, compute the shell $[a,b] = [R-\Delta/2, R+\Delta/2]$, the floor $\lambda = ab/(b-a) = R^2/\Delta - \Delta/4$, the optimal energy $E^* = -\frac{v_s^2}{12}\lambda$, and the gap $E^* - E = v_s^2\Delta/36$. Constant time; certifies that no admissible profile in the shell can be cheaper than $E^*$.

**Algorithm C (Antitelephone loop closure).** Given $V > 1$ and $T > 0$, output the boost velocity $\beta = 2V/(V^2+1)$, the factor $\kappa = \sqrt{1-\beta^2}$, the boosted arrival event $(T', X')$ of $(T, VT)$, and the return-leg duration $s = -T'$. Verify $T' < 0$, $s > 0$, and $X' - Vs = 0$. Constant time; each identity is exact.

**Algorithm D (Energy-density field sampler).** Given $v_s$, a radial shape function $f$ with derivative $f'$, and a grid of points, evaluate
$$\rho(x,y,z) = -\frac{1}{8\pi}\frac{v_s^2(y^2+z^2)}{4r_s^2}f'(r_s)^2, \qquad \theta(x,y,z) = v_sf'(r_s)\frac{x - x_s}{r_s},$$
returning the toroidal negative-energy region and the fore/aft expansion dipole. Linear in the number of grid points.

---

## 12. Applications and discussion

**Energy accounting for hypothetical drives.** Theorem 8.8 is the practically decisive statement. It converts the vague "the warp drive needs a lot of exotic matter" into a hard inequality: for a bubble of radius $R$ whose wall is confined to a shell of thickness $\Delta$, and at any warp speed $v_s$,
$$|E| \ \ge\ \frac{v_s^2}{12}\left(\frac{R^2}{\Delta} - \frac{\Delta}{4}\right),$$
independent of every design choice. Proposals that thin the wall to localise the exotic matter necessarily raise, not lower, the total requirement, and they do so as $1/\Delta$.

**Scaling as a diagnostic.** Theorems 7.3 and 6.4 give a clean fingerprint: the energy is degree two in $v_s$ and the momentum degree one. Any claim of a design with linear energy scaling must therefore either leave the class of unit-lapse flat-slice ansätze or contain an error. Theorem 7.9 executes the specific conjecture $E \sim Mv_sc$; Theorem 7.10 shows the failure is not asymptotically repairable.

**Geometry of the exotic region.** The toroidal support (Theorem 5.5) matters for any attempt to source the bubble with a physical field configuration: no negative energy is required directly ahead of or behind the ship, and all of it lies in a ring around the axis. The concomitant flux (Theorem 6.3) rules out the simplest models: the exotic matter cannot be static dust in the bubble frame.

**Controllability.** Theorem 3.8 is a strong practical obstruction independent of the energy problem: once $v_s > 1$, an outer region exists from which no causal signal can keep up with the bubble. The leading wall cannot be steered from inside; a superluminal bubble must be pre-programmed in its entirety.

**Causality.** The dichotomy of §10 is the most conceptually significant result. It cleanly separates two claims that are often conflated. A warp spacetime, considered alone, is globally hyperbolic and chronologically well behaved. The pathology arises from *composition*: the boost freedom of special relativity turns two corridors into a closed loop, with the explicit closure data of Theorem 10.6. Any physically consistent framework permitting warp corridors must supply an obstruction to the second corridor — a preferred frame, a semiclassical instability of the bubble wall, or a chronology-protection mechanism.

**Limitations.** The energy results assume spherical symmetry of the shape function and the standard Eulerian energy density; the variational floor assumes the wall is confined to a shell and is proved in the radial (post-angular-integration) formulation. The Raychaudhuri statements are about the degraded differential inequality rather than the full tensorial focusing theorem. The causality construction treats the corridors as exact segments in the ambient flat region, which is the physically relevant idealisation but not a global gluing theorem.

---

## 13. Future directions

**C1. Universal exotic-energy floor beyond spherical symmetry.** *Conjecture.* Let the bubble be any (not necessarily spherical) region whose shape function equals $1$ on a body of inradius $R$ and $0$ outside a shell of thickness $\Delta$. Then the total Eulerian energy satisfies $E \le -\frac{v_s^2}{12}\frac{R^2}{\Delta}(1 + o(1))$ as $\Delta \to 0$, with the constant $1/12$ unimprovable. *Status.* Proved for spherically symmetric walls, and sharply: the minimum of the radial energy integral over all admissible profiles is exactly $ab/(b-a)$, attained by $f' \propto -1/r^2$, and the piecewise-linear wall exceeds it by exactly $v_s^2\Delta/36$. The open part is the removal of spherical symmetry. *Key insight.* The energy functional is a weighted $L^2$ norm of $\nabla f$ subject to a single linear normalisation, so the floor is a Cauchy–Schwarz dual norm — and the dual norm of a *shape* constraint is a purely geometric, capacity-like quantity, which should identify the true minimum with the electrostatic capacity of the shell.

**C2. Quadratic-not-linear universality.** *Conjecture.* For *any* shift field $\beta^i = -v_sF^i(x)$ on flat slices with unit lapse, the Eulerian energy density is exactly homogeneous of degree two in $v_s$ pointwise, while the momentum density is homogeneous of degree one; hence no warp ansatz of this class can have energy scaling $E \sim Mv_sc$. *Status.* Proved for the Alcubierre shape; the general shift field is open, but the Hamiltonian constraint is quadratic in $K$ while $K$ is linear in the shift, so the proof should be a short homogeneity argument once the general $K_{ij}(\beta)$ is defined. *Key insight.* The degree of homogeneity is a structural invariant of the ADM formalism, not a feature of any particular profile.

**C3. Chronology dichotomy in full generality.** *Conjecture.* Every spacetime of ADM form with unit lapse and flat slices is globally hyperbolic, with the level sets of coordinate time as Cauchy surfaces; but the composition of two such spacetimes glued along boosted regions admits closed timelike curves whenever both effective speeds exceed unity. *Status.* The single-bubble half is proved in full generality (no closed causal curve, any profile); the two-corridor half is proved as an explicit loop-closure identity in the flat ambient region. What remains is a genuine gluing construction realising the composed spacetime as a single Lorentzian manifold.

Further natural targets: (i) an explicit quantum-inequality confrontation, bounding the duration for which the required negative energy density can be sustained; (ii) the semiclassical stability of the wall, where the horizon of Theorem 3.8 is expected to produce a Hawking-like flux; (iii) extension of the variational floor to walls with prescribed *anisotropic* thickness, where the capacity heuristic of C1 predicts a strictly smaller floor for oblate bubbles.

---

## 14. Conclusion

The Alcubierre geometry is a completely explicit Lorentzian metric that achieves unbounded coordinate speed with exactly zero local speed, by expanding space behind the ship and contracting it ahead in perfectly antisymmetric fashion. Its price, computed exactly, is negative energy density everywhere off the axis — unconditionally, for every profile — arranged in a torus around the direction of travel and necessarily flowing rather than static. The total cost is exactly quadratic in the warp speed, refuting the popular linear estimate, and diverges as $1/\Delta$ as the wall thins, with a sharp geometric floor $\frac{v_s^2}{12}\frac{ab}{b-a}$ that no profile engineering can beat. Finally, the causal verdict is a dichotomy: one bubble is chronologically safe, and two bubbles in relative motion demonstrably are not, by an explicit two-leg loop with closed-form boost velocity $\beta = 2V/(V^2+1)$. The obstruction to warp travel is therefore twofold and quantitative — an energy requirement that grows faster than hoped and cannot be optimised away, and a causal inconsistency that appears the moment a second corridor is built.
