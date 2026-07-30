# Epsilon-Regularity Reductions and Conservative Modal Energy Transfer for Three-Dimensional Fluid Flow

**Aristotle**  
**July 30, 2026**

## Abstract

The three-dimensional incompressible Navier–Stokes existence-and-smoothness problem remains open. This paper develops two rigorous, self-contained reductions relevant to partial regularity and turbulence without claiming a resolution of that problem. First, an abstract epsilon-regularity criterion is introduced on a measurable spacetime. If excess below a positive threshold at one scale implies regularity at a point, then every singular point has excess at least the threshold at every positive scale. Consequently, the singular set is contained in the persistent-concentration set. Nullity of the concentration set for any chosen measure therefore implies nullity of the singular set, both globally and after localization to an arbitrary region; equivalently, regularity holds almost everywhere. This isolates the final logical and measure-theoretic step in a Caffarelli–Kohn–Nirenberg-type argument. Second, for a finite family of modes in a real inner-product space, modal nonlinear transfer is defined by the inner product of the nonlinear interaction with the state. If total nonlinear transfer vanishes, then transfer into any mode band is exactly the negative of transfer into its complement. Positive transfer into a band forces negative transfer outside it, with equal magnitude. The identity provides the algebraic core of conservative spectral redistribution but does not determine a direction of cascade. Numerical algorithms and examples demonstrate both mechanisms and clarify the additional analytic ingredients required for applications to suitable weak solutions.

## 1. Introduction

The incompressible Navier–Stokes equations in three spatial dimensions are

$$
\partial_t u+(u\cdot\nabla)u+\nabla p=\nu\Delta u+f,
\qquad \nabla\cdot u=0,
$$

where $u:\Omega\times[0,T)\to\mathbb{R}^3$ is velocity, $p$ is pressure, $\nu>0$ is kinematic viscosity, and $f$ is external forcing. The central global question asks whether smooth divergence-free initial data always produce solutions that remain smooth for all time, or whether a finite-time singularity can occur. No answer is presently known in full generality.

Two major viewpoints organize much of the surrounding theory. Partial regularity studies the possible singular set of weak solutions. It seeks local criteria under which a solution becomes regular and geometric estimates showing that points failing those criteria form a small set. Turbulence theory studies transfer across scales, often by decomposing a flow into Fourier or other modes and measuring how the quadratic nonlinearity redistributes energy.

This paper isolates one exact mechanism from each viewpoint.

1. **Epsilon-regularity reduction.** An abstract excess $E(z,r)$ probes a point $z$ at scale $r$. If small excess at one positive scale implies regularity, then a singular point must exhibit threshold-sized excess at every positive scale. The singular set is therefore contained in a concentration set. Any null estimate for that concentration set transfers immediately to the singular set.

2. **Finite-mode transfer balance.** For finitely many modes, define nonlinear energy transfer mode by mode. If the total transfer is zero, then every chosen band exchanges energy exactly with its complement. This determines balance and magnitude, but not the sign or direction of transfer.

The first mechanism is independent of the detailed formula for excess and of the selected measure. This abstraction is useful because it separates the logical endpoint of a partial-regularity proof from its difficult analytic input. In the classical setting, that input consists of local energy inequalities, scale-invariant estimates, compactness, pressure control, and a covering argument in parabolic geometry.

The second mechanism is finite-dimensional and algebraic. It applies to any real inner-product state space and any finite mode family. It expresses the cancellation expected from an energy-conserving nonlinear term. It is therefore useful both conceptually and as a consistency diagnostic for spectral computations.

Throughout, no theorem asserts global smoothness, nonexistence of singularities, the full Caffarelli–Kohn–Nirenberg theorem, or a universal turbulent cascade direction.

## 2. Abstract epsilon-regularity framework

### 2.1. Scaling and the role of excess

The Navier–Stokes equations possess a natural rescaling: if $(u,p)$ is a solution, then, where defined,

$$
u_\lambda(x,t)=\lambda u(\lambda x,\lambda^2t),
\qquad
p_\lambda(x,t)=\lambda^2p(\lambda x,\lambda^2t)
$$

has the same formal structure. Quantities unchanged by this transformation are called scale invariant or critical. They are natural candidates for an excess because a possible singularity cannot be ruled out merely by changing observational units. Parabolic cylinders use spatial radius $r$ and temporal depth $r^2$, matching the same scaling.

The abstract argument below does not assume this particular PDE scaling, but its distinction between a point $z$ and a positive scale $r$ is designed for it. The threshold $\varepsilon$ is fixed independently of $z$ and $r$. Uniformity is important: if every point or scale had an unrelated threshold, the resulting concentration set would not provide a common geometric object suitable for covering estimates.

The word “excess” should not be taken to imply one unique formula. Depending on the regularity theorem, it may measure velocity oscillation, normalized integral size, pressure fluctuation, or a sum of several dimensionless terms. The reduction needs only the implication from one-scale smallness to regularity. All PDE-specific inequalities are concentrated in the task of proving that implication and estimating points where its premise always fails.

### 2.2. Points, scales, and regularity

Let $Z$ be a set of points. In a fluid application, $Z$ may be a spacetime domain. Let

$$
\operatorname{Reg}(z)
$$

be a predicate meaning that the solution is regular at $z$. “Regular” may mean local boundedness, Hölder continuity, or another condition sufficient to bootstrap to smoothness, depending on the analytic context.

Let

$$
E:Z\times\mathbb{R}\to\mathbb{R}
$$

be an excess function. Only positive radii $r>0$ are used. In a Navier–Stokes application, $E(z,r)$ is intended to be scale invariant and may combine normalized velocity and pressure integrals over a parabolic cylinder centered at $z$. The abstract results do not require nonnegativity or measurability of $E$; such properties become relevant when proving a concrete concentration estimate.

Fix a threshold $\varepsilon>0$.

**Definition 2.1 (epsilon-regularity criterion).** The triple $(\operatorname{Reg},E,\varepsilon)$ satisfies an epsilon-regularity criterion if, for every $z\in Z$,

$$
\left(\exists r>0\text{ such that }E(z,r)<\varepsilon\right)
\Longrightarrow \operatorname{Reg}(z).
$$

The criterion is deliberately one-scale: a single radius with sufficiently small excess implies regularity at the center.

**Definition 2.2 (singular set).** The singular set is

$$
S=\{z\in Z:\neg\operatorname{Reg}(z)\}.
$$

**Definition 2.3 (persistent-concentration set).** The concentration set associated with $E$ and $\varepsilon$ is

$$
C=\{z\in Z:\text{for every }r>0,\ E(z,r)\ge\varepsilon\}.
$$

Thus $C$ contains the points where no positive observational scale falls below the regularity threshold.

### 2.3. Singular points force concentration

**Theorem 2.4 (singular excess lower bound).** Assume the epsilon-regularity criterion. If $z\in S$, then for every $r>0$,

$$
E(z,r)\ge\varepsilon.
$$

**Proof sketch.** Fix a singular point $z$ and a positive radius $r$. If $E(z,r)<\varepsilon$, then the chosen radius witnesses the premise of the epsilon-regularity criterion, so $\operatorname{Reg}(z)$ holds. This contradicts $z\in S$. Hence $E(z,r)\ge\varepsilon$. Since $r>0$ was arbitrary, the inequality holds at every positive scale. $\square$

The theorem is a contrapositive, but it has a useful geometric interpretation: singularity requires persistent concentration under indefinite magnification.

**Theorem 2.5 (singular-set containment).** Under the same assumptions,

$$
S\subseteq C.
$$

**Proof sketch.** If $z\in S$, Theorem 2.4 gives $E(z,r)\ge\varepsilon$ for every $r>0$. This is exactly the defining condition for $z\in C$. $\square$

The containment is the bridge between a local analytic regularity test and a geometric estimate for exceptional points.

## 3. Measure-theoretic partial regularity

Equip $Z$ with a sigma-algebra and let $\mu$ be any measure. The results below require no special geometry of $\mu$. In an application, one may choose Lebesgue measure, a parabolic Hausdorff measure, or a measure localized by restriction.

**Theorem 3.1 (global null-set transfer).** Assume the epsilon-regularity criterion and suppose

$$
\mu(C)=0.
$$

Then

$$
\mu(S)=0.
$$

**Proof sketch.** Theorem 2.5 gives $S\subseteq C$. By monotonicity of measures,

$$
0\le\mu(S)\le\mu(C)=0.
$$

Therefore $\mu(S)=0$. $\square$

This theorem isolates the final measure-theoretic reduction in a partial-regularity argument. Establishing $\mu(C)=0$ may be very difficult; transferring that estimate to $S$ is immediate once epsilon regularity is known.

**Theorem 3.2 (localized null-set transfer).** Let $R\subseteq Z$ be any region. If

$$
\mu(C\cap R)=0,
$$

then

$$
\mu(S\cap R)=0.
$$

**Proof sketch.** Intersecting the containment $S\subseteq C$ with $R$ gives

$$
S\cap R\subseteq C\cap R.
$$

Measure monotonicity then yields the conclusion. $\square$

No measurability assumption on $R$, $S$, or $C$ beyond that implicit in the ambient measure formalism is needed when nullity is interpreted through the complete monotone null-set principle: every subset of a null measurable set is null in the completed sense. In standard applications the relevant sets are measurable or are handled via outer measure.

**Corollary 3.3 (almost-everywhere regularity).** If $\mu(C)=0$, then

$$
\operatorname{Reg}(z)
$$

holds for $\mu$-almost every $z\in Z$.

**Proof sketch.** The points where regularity fails form exactly $S$. By Theorem 3.1, $S$ is null, which is the definition of almost-everywhere regularity. $\square$

### 3.1. Relation to parabolic partial regularity

For Navier–Stokes flow, spacetime scales anisotropically: under the natural scaling, spatial radius $r$ is paired with temporal depth proportional to $r^2$. A concrete excess may therefore be built on parabolic cylinders

$$
Q_r(z_0)=B_r(x_0)\times(t_0-r^2,t_0)
$$

for $z_0=(x_0,t_0)$. A typical program has three stages:

1. formulate a scale-invariant excess from velocity and pressure;
2. prove that excess below a universal $\varepsilon$ at one scale implies regularity on a smaller concentric cylinder;
3. prove by energy estimates and a covering argument that persistent-concentration points have zero one-dimensional parabolic Hausdorff measure.

Theorems 2.4–3.3 supply the exact final implication from stages 2 and 3: every singular point is persistently concentrated, and the singular set inherits the concentration set’s nullity. The current framework does not prove stages 1–3 for suitable weak solutions; it identifies their logical interface.

## 4. Conservative transfer among finitely many modes

### 4.1. Modal transfer

Let $I$ be a finite index set and $V$ a real inner-product space with inner product $\langle\cdot,\cdot\rangle$. A state is a family

$$
u=(u_i)_{i\in I},\qquad u_i\in V,
$$

and a nonlinear interaction is a family

$$
N=(N_i)_{i\in I},\qquad N_i\in V.
$$

The symbol $N_i$ may represent the nonlinear term evaluated at the current state and projected onto mode $i$. No linearity of $N$ is assumed.

**Definition 4.1 (modal energy-transfer rate).** The instantaneous nonlinear transfer into mode $i$ is

$$
\tau_i=\langle N_i,u_i\rangle.
$$

This is the nonlinear contribution to the derivative of quadratic modal energy, up to whichever factor is chosen in defining that energy.

**Definition 4.2 (transfer into a mode set).** For $A\subseteq I$, define

$$
T(A)=\sum_{i\in A}\tau_i
=\sum_{i\in A}\langle N_i,u_i\rangle.
$$

**Definition 4.3 (global nonlinear energy conservation).** The interaction conserves total quadratic energy at the state $u$ when

$$
T(I)=0.
$$

This is an instantaneous statewise condition. In Galerkin models of incompressible flow, it reflects skew-symmetry or cancellation of the convective term under suitable boundary conditions and exact evaluation.

### 4.2. Exact complementary exchange

**Theorem 4.4 (complementary transfer identity).** Let $A\subseteq I$. If $T(I)=0$, then

$$
T(I\setminus A)=-T(A).
$$

**Proof sketch.** Because $A$ and $I\setminus A$ are disjoint and have union $I$, finite-sum additivity gives

$$
T(I)=T(A)+T(I\setminus A).
$$

Substituting $T(I)=0$ and rearranging proves the identity. $\square$

The theorem applies to every selected collection: low modes, high modes, a shell, a disconnected band, or a data-dependent subset, provided it lies within the finite truncation.

**Corollary 4.5 (sign reversal).** Under the hypotheses of Theorem 4.4, if

$$
T(A)>0,
$$

then

$$
T(I\setminus A)<0.
$$

**Proof sketch.** The complement transfer equals the negative of a positive number. $\square$

**Corollary 4.6 (equal transfer magnitude).** Under the same hypotheses,

$$
|T(I\setminus A)|=|T(A)|.
$$

**Proof sketch.** Apply absolute values to $T(I\setminus A)=-T(A)$ and use $|-x|=|x|$. $\square$

### 4.3. Conservation versus cascade direction

The identity is exact but sign-neutral. If $A$ denotes low wavenumbers, then $T(A)<0$ is consistent with low modes losing energy and high modes gaining it; $T(A)>0$ represents the reverse exchange. Both obey global conservation. Thus conservation alone cannot establish a forward or inverse cascade.

An additional distinction concerns instantaneous and time-integrated transfer. The quantity $T(A)$ here is evaluated at one state. Integrating it over time gives a cumulative exchange only when a time-dependent trajectory and adequate integrability are supplied. Similarly, an ensemble-mean flux requires a probability law. The finite identity remains valid pointwise and therefore survives time integration or averaging whenever those operations are legitimate, but no statistical conclusion follows without that extra structure.

This limitation can be demonstrated by a scalar example. Let $V=\mathbb{R}$, let $I=\{0,1,2,3\}$, and set

$$
u=(1,1,1,1),\qquad N=(1,2,-1,-2).
$$

Then $\tau=(1,2,-1,-2)$ and $T(I)=0$. For $A=\{0,1\}$,

$$
T(A)=3,
\qquad
T(I\setminus A)=-3.
$$

Replacing $N$ by $-N$ gives $T(A)=-3$ and $T(I\setminus A)=3$. Both interactions satisfy the same conservation law. A preferred cascade direction therefore requires additional hypotheses concerning dynamics, triadic geometry, forcing and dissipation, ensembles, flux locality, or statistical stationarity.

## 5. Algorithms

### 5.1. Epsilon-regularity screening on sampled scales

Given finitely many sampled points and scales, one may classify a point as **certified regular** if at least one sampled positive scale has excess below $\varepsilon$. If none does, the point is labeled **unresolved concentration candidate**, not singular. Finite sampling can confirm the premise of epsilon regularity, but it cannot establish a universal statement over every positive radius.

For $n$ points and $m$ scales per point, the procedure takes $O(nm)$ excess comparisons and $O(n)$ output storage. Its sound conclusion is one-sided: a detected small scale certifies regularity under the criterion; failure to detect one is not proof of singularity.

### 5.2. Modal transfer audit

Given vectors $u_i,N_i\in\mathbb{R}^d$, compute

$$
\tau_i=N_i\cdot u_i,
$$

sum over all modes and over a selected band, and compare the complement sum with the negative band sum. The cost is $O(|I|d)$ arithmetic operations and $O(|I|)$ storage if all modal transfers are retained, or $O(1)$ extra storage if accumulated online.

A numerical tolerance is required in floating-point arithmetic. The residuals

$$
R_{\mathrm{total}}=T(I),
\qquad
R_{\mathrm{balance}}=T(I\setminus A)+T(A)
$$

separate two checks. The second residual is an arithmetic partition identity and should be near zero regardless of conservation if all modes are partitioned consistently. The first tests the physical or model assumption of global conservative transfer.

### 5.3. Constructing a conservative completion

Given arbitrary proposed transfers $\tau_1,\ldots,\tau_{n-1}$, define

$$
\tau_n=-\sum_{i=1}^{n-1}\tau_i.
$$

Then $\sum_{i=1}^n\tau_i=0$. This $O(n)$ construction generates examples for testing transfer diagnostics. It constructs transfer rates, not necessarily a physically realizable Navier–Stokes triadic interaction; realizability imposes additional structure.

## 6. Numerical examples

### 6.1. Sampled excess profiles

Take $\varepsilon=0.1$ and scales

$$
r\in\left\{1,\frac12,\frac14,\frac18\right\}.
$$

At point $a$, let

$$
E(a,r)=(0.42,0.18,0.08,0.04).
$$

Since $E(a,1/4)=0.08<0.1$, the epsilon-regularity criterion certifies regularity at $a$.

At point $b$, let

$$
E(b,r)=(0.31,0.21,0.14,0.11).
$$

Every sampled value exceeds the threshold. Point $b$ is therefore a concentration candidate on the sampled scales, but one cannot conclude $b\in C$: a smaller unsampled radius might have excess below $0.1$.

This illustrates the logical asymmetry of numerical screening. One successful scale is decisive; finitely many unsuccessful scales cannot settle an all-scale condition.

### 6.2. Vector-valued modal exchange

Let four modes have two-dimensional states

$$
u_0=(1,0),\quad u_1=(0,1),\quad u_2=(1,1),\quad u_3=(2,-1),
$$

and interactions

$$
N_0=(2,0),\quad N_1=(0,1),\quad N_2=(-1,0),\quad N_3=(-1,0).
$$

Their transfers are

$$
\tau_0=2,\quad \tau_1=1,\quad \tau_2=-1,\quad \tau_3=-2,
$$

so total transfer vanishes. For $A=\{0,1\}$,

$$
T(A)=3,
\qquad
T(I\setminus A)=-3.
$$

The complement has opposite sign and equal magnitude, exactly as Theorem 4.4 requires.

## 7. Applications and interpretation

### 7.1. Architecture of a partial-regularity proof

The abstract framework encourages a modular proof strategy. Analysts may focus on deriving a criterion of the form

$$
E(z,r)<\varepsilon\Longrightarrow\operatorname{Reg}(z)
$$

and on estimating the set where this never occurs. Once those two ingredients are established for a selected measure, almost-everywhere regularity follows without further PDE manipulation. This separation also clarifies which changes in the excess leave the final argument intact: any replacement excess and threshold work if they satisfy the same implication and concentration estimate.

### 7.2. Local certification

The localized theorem is suited to interior estimates, boundary-free subdomains, or regions where auxiliary assumptions hold. If concentration is null only in $R$, regularity is still obtained almost everywhere in $R$. No global estimate is required.

### 7.3. Spectral simulation diagnostics

In a conservative finite-mode model, total nonlinear transfer should be zero up to numerical error. A transfer audit can detect violations caused by aliasing, inconsistent quadrature, omitted modes, or coding errors. Band-complement comparison can then show where the computed interaction redistributes energy. The theorem guarantees exact balance in the ideal algebraic model; observed discrepancies quantify numerical defects or nonconservative terms.

### 7.4. What the results do not imply

Three boundaries are essential.

First, almost-everywhere regularity is weaker than everywhere regularity. A null singular set may still be nonempty.

Second, singular-set containment does not itself prove that the concentration set is null. That conclusion requires analytic estimates adapted to actual solutions.

Third, complementary transfer balance does not select a cascade direction. Equal and opposite exchange is compatible with either sign.

These limitations are not defects. They identify precisely which conclusions follow from logic and conservation and which require deeper PDE or turbulence input.

## 8. Future work

A complete analytic development would first define suitable weak solutions and prove the local energy inequality. It would then introduce a concrete parabolic scale-invariant excess involving velocity and pressure, establish a universal epsilon-regularity theorem, and prove a covering estimate for persistent concentration. The abstract results of Sections 2 and 3 would convert those ingredients into a partial-regularity conclusion.

A second direction is a critical continuation criterion. One seeks to show that a smooth solution on $[0,T)$ whose velocity remains bounded in the scale-critical space $L^\infty(0,T;L^3(\mathbb{R}^3))$ extends smoothly beyond $T$. This would connect concentration control to prevention of finite-time breakdown.

A third direction builds a bridge from finite-dimensional Galerkin approximations to suitable weak solutions. Uniform energy bounds must be combined with compactness strong enough to pass to the nonlinear term and preserve both global and local energy inequalities.

For turbulence, one should characterize additional assumptions that induce a statistically preferred sign of transfer. Triadic interaction structure, locality, forcing and dissipation ranges, ensemble averaging, and flux laws are natural candidates. A useful complementary objective is to exhibit explicitly energy-conserving interactions and states with either sign of transfer into the same prescribed band, demonstrating sharply that conservation fixes balance rather than direction.

## 9. Conclusion

Two exact principles have been established. Under any one-scale epsilon-regularity criterion with positive threshold, singular points must remain above threshold at every positive scale. Hence the singular set lies inside the persistent-concentration set, and every global or localized null estimate for concentration transfers to singularity; regularity follows almost everywhere. Separately, in any finite real inner-product modal system with zero total nonlinear energy transfer, transfer into a selected band is the negative of transfer into its complement, with opposite sign and equal magnitude.

These results do not resolve three-dimensional Navier–Stokes existence and smoothness. They provide clean interfaces for the unresolved work. Partial regularity reduces to proving a concrete small-excess theorem and a geometric concentration estimate. Cascade theory must supplement conservation with mechanisms that choose a direction. In both settings, the reductions distinguish exact accounting laws from the deeper analysis needed to understand fluid singularities and turbulence.
