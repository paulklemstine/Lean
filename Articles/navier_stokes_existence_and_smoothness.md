# The Accounting Laws of Turbulence

## What three rigorous ideas can—and cannot—tell us about Navier–Stokes flow

A curl of cream in coffee looks effortless. A storm front rolling across a continent does not. Yet both belong to the same mathematical world: fluids move, fold, stretch, and transport energy from one scale to another. The equations most often used to describe this world are the three-dimensional incompressible Navier–Stokes equations,

$$
\partial_t u+(u\cdot\nabla)u+\nabla p=\nu\Delta u+f,
\qquad \nabla\cdot u=0.
$$

Here $u(x,t)$ is the velocity of the fluid, $p(x,t)$ is its pressure, $\nu>0$ is viscosity, and $f$ is an applied force. The divergence-free condition $\nabla\cdot u=0$ expresses incompressibility. These symbols contain an unresolved question: starting from smooth data, must a three-dimensional solution remain smooth forever, or can it develop a singularity in finite time?

That global existence-and-smoothness problem remains open. The results developed here do not claim otherwise. Instead, they isolate two pieces of reasoning that sit near the heart of modern fluid analysis. The first explains how a local smallness test confines possible singularities to a concentration set. The second explains how energy-conserving nonlinear interactions redistribute energy among finitely many modes. Together they offer a precise lesson: conservation gives a balance sheet, while regularity theory identifies where dangerous concentration would have to hide.

## A microscope for singularities

Imagine inspecting a fluid at a spacetime point $z$. At every positive scale $r$, measure a nonnegative or signed diagnostic $E(z,r)$, called the **excess**. In applications, this quantity is designed to be unchanged by the natural scaling of the equations and may combine local velocity and pressure integrals over a parabolic cylinder. The exact analytic formula is not needed for the logical mechanism; what matters is a threshold principle.

Fix a number $\varepsilon>0$. An **epsilon-regularity criterion** says:

> If there is at least one positive scale $r$ for which $E(z,r)<\varepsilon$, then the solution is regular at $z$.

This is a one-scale test. It does not require the excess to be small at every scale. A single sufficiently good view through the microscope forces regularity at the center.

Turn that statement around and a striking conclusion appears. If $z$ is singular, then no positive scale can pass the test. Thus every singular point obeys

$$
E(z,r)\ge \varepsilon \qquad \text{for every } r>0.
$$

This is the **Singular Excess Lower-Bound Theorem**. Its proof is the cleanest possible contradiction argument. Suppose $z$ were singular but $E(z,r)<\varepsilon$ at some positive radius. The epsilon-regularity criterion would declare $z$ regular, contradicting singularity.

Define the **singular set** $S$ to be the set of points where regularity fails. Define the **concentration set** $C$ by

$$
C=\{z: E(z,r)\ge\varepsilon \text{ for every }r>0\}.
$$

The lower-bound theorem immediately yields the **Concentration Containment Theorem**:

$$
S\subseteq C.
$$

This elementary inclusion is the hinge between analysis and geometry. The hard analytic work in a partial-regularity theorem estimates the size of $C$, often by a covering argument. Once that is done, the singular set inherits the estimate automatically.

## From concentration to almost-everywhere smoothness

To say that an exceptional set is “small,” mathematicians choose a measure $\mu$. It may be ordinary volume, or a finer Hausdorff-type measure adapted to parabolic spacetime scaling. A set $A$ is $\mu$-null when $\mu(A)=0$.

The **Null-Set Transfer Theorem** states:

> For any measure $\mu$, if the concentration set satisfies $\mu(C)=0$, then the singular set satisfies $\mu(S)=0$.

The proof is monotonicity: because $S\subseteq C$, one has $0\le\mu(S)\le\mu(C)=0$. Therefore $\mu(S)=0$.

There is also a localized version. For any region $R$, if

$$
\mu(C\cap R)=0,
$$

then

$$
\mu(S\cap R)=0.
$$

Indeed, intersecting $S\subseteq C$ with $R$ gives $S\cap R\subseteq C\cap R$. This matters because fluid estimates are often local: one may control a cylinder away from a boundary, a neighborhood after a waiting time, or a subregion where forcing behaves well.

Finally, the same conclusion can be spoken in the language of typical points. If $\mu(C)=0$, then the flow is regular at $\mu$-almost every point. “Almost every” permits exceptions, but confines them to a null set. This is a partial-regularity conclusion, not global smoothness. It neither proves that $S$ is empty nor constructs a singularity. Rather, it says that any singular behavior must occupy a geometrically negligible set once the required concentration estimate is available.

This division of labor mirrors the celebrated strategy associated with Caffarelli, Kohn, and Nirenberg. An epsilon-regularity theorem supplies the microscope test; a covering estimate proves that persistent concentration is rare; set inclusion transfers that rarity to singular points. The present results establish the final logical and measure-theoretic link. The deep analytic estimates needed for actual suitable weak solutions remain separate work.

## The spectral balance sheet

Turbulence is also studied by splitting a velocity field into modes—Fourier waves, eigenfunctions, or any finite family of resolved components. Let $I$ be a finite index set of all modes under consideration. For each mode $i$, let $u_i$ denote its state and $N_i$ the nonlinear interaction acting on it. In a real inner-product space, define the **modal energy-transfer rate**

$$
T_i=\langle N_i,u_i\rangle.
$$

For a collection of modes $A\subseteq I$, define the transfer into $A$ by

$$
T(A)=\sum_{i\in A}T_i.
$$

A positive value means that, at that instant and state, the selected collection gains energy from the nonlinear interaction; a negative value means it loses energy. Suppose the nonlinear interaction conserves energy across the entire finite truncation:

$$
T(I)=\sum_{i\in I}\langle N_i,u_i\rangle=0.
$$

Choose any band $A\subseteq I$. Since $I$ is the disjoint union of $A$ and its complement $I\setminus A$,

$$
T(I)=T(A)+T(I\setminus A).
$$

Global conservation therefore gives the **Complementary Transfer Theorem**:

$$
T(I\setminus A)=-T(A).
$$

The proof is just finite-sum accounting, but its interpretation is central to spectral turbulence. Nonlinearity may move energy among modes, yet in an energy-conserving truncation it cannot create or destroy the total. Every gain in one band is paid for by an equal loss outside it.

Two consequences sharpen the picture. First, if $T(A)>0$, then

$$
T(I\setminus A)<0.
$$

Second, the transfer magnitudes agree:

$$
|T(I\setminus A)|=|T(A)|.
$$

The same statements hold if “low modes” are replaced by any chosen band: large scales, small scales, an inertial-range shell, or a collection selected for numerical diagnosis.

## Balance does not choose an arrow

It is tempting to read more into this identity than it says. In three-dimensional turbulence, energy is often described as cascading from large scales to small scales, where viscosity dissipates it. But conservation alone does not select that direction. The equation

$$
T(I\setminus A)=-T(A)
$$

allows $T(A)$ to be positive, negative, or zero. It fixes the counter-transfer, not the sign of the original transfer.

Consider four scalar modes with state $u_i=1$. If their nonlinear contributions are $N=(1,2,-1,-2)$, then total transfer is zero. For the band $A=\{1,2\}$, the transfer is $3$, while the complement transfers $-3$. Reversing the interaction to $-N$ reverses both signs without violating conservation. A directional cascade requires additional structure: dynamics, statistics, geometry of interactions, forcing, dissipation, or assumptions about the state. The balance law is necessary bookkeeping, not a complete theory of turbulent flux.

That distinction matters in simulations. A spectral code can test total nonlinear transfer as a diagnostic: a nonzero total may signal aliasing, truncation error, or an inconsistent discretization. It can also compare a chosen band with its complement. But observing equal and opposite values only confirms conservation; it does not by itself establish a universal forward cascade.

## Two views of the same danger

The concentration theorem and the mode-transfer theorem live at different levels. One looks through a spacetime microscope, asking whether scale-invariant quantities remain large near a point. The other looks through a spectral prism, asking how nonlinear interactions exchange energy among modes. Yet both are forms of accounting across scale.

The partial-regularity framework says that a singular point must retain at least $\varepsilon$ excess at every positive radius. Dangerous behavior cannot disappear under magnification. The modal framework says that a gain in one spectral region must be balanced elsewhere. Energy cannot appear without a compensating loss. In physical space, one tracks persistence; in spectral space, one tracks exchange.

Neither result settles the global Navier–Stokes problem. To prove global smoothness, one would need an estimate strong enough to prevent singular concentration altogether. To prove partial regularity in the classical setting, one must establish an actual epsilon-regularity criterion for suitable weak solutions and show that the corresponding concentration set has zero one-dimensional parabolic Hausdorff measure. To derive a cascade direction, one needs more than conservation.

Still, these reductions clarify exactly where the difficulty lies. The set-theoretic part of partial regularity is not mysterious: singularities are trapped inside persistent concentration, and nullity passes to subsets. The algebraic part of spectral transfer is equally exact: complementary bands exchange equal and opposite amounts. What remains is the analytic and dynamical substance—proving the smallness criterion, estimating concentration, constructing suitable weak limits, and discovering which mechanisms bias energy transfer across scales.

The unsolved problem endures, but its surrounding landscape becomes sharper. Any future singularity must evade every small-scale regularity test. Any proposed turbulent cascade must respect exact global accounting. Those are not the final answers, but they are durable constraints on every answer still to come.
