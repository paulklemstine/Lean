# One Formula for Every Symmetry: Reading the Critical Exponents of the $O(N)$ Model

## Water, magnets, and the strange fact that nature repeats itself

Heat a sealed tube of water to $374^\circ\mathrm{C}$ and squeeze it to $218$ atmospheres, and something eerie happens. The boundary between liquid and vapour — that sharp, obvious surface you have seen a thousand times — dissolves. The fluid becomes milky, then opalescent, scattering light in every direction. Physicists call this the *critical opalescence*, and its cause is that the fluid is no longer choosing between two phases at any particular scale. Droplets of vapour contain droplets of liquid that contain droplets of vapour, all the way down, at every size at once.

Now take a bar of iron and warm it to $770^\circ\mathrm{C}$. Its magnetism dies. Just below that temperature the atomic spins agree with each other over huge distances; just above they don't. At the transition point itself, the same nested-at-all-scales structure appears — patches of aligned spins inside patches inside patches.

These two systems could hardly be less alike. One is a soup of small molecules bouncing off each other; the other is a rigid crystal of iron atoms with quantum-mechanical spins. And yet, if you measure how their observable quantities blow up at the critical point, you get *the same numbers*. The correlation length — the typical size of the largest coherent patch — diverges as
$$\xi \sim |T - T_c|^{-\nu},$$
and the measured value of $\nu$ is about $0.63$ for both. The magnetic susceptibility (or, for the fluid, the compressibility) diverges as $|T-T_c|^{-\gamma}$ with $\gamma \approx 1.24$ in both. This is **universality**, and it is one of the most surprising facts in physics: at a critical point, almost every microscopic detail is forgotten.

Almost every detail — but not quite all. Two things survive: the dimension $d$ of space, and the number $N$ of components of the "order parameter", the quantity that becomes non-zero in the ordered phase. For a fluid, the order parameter is a single number (the density difference), so $N=1$. For a magnet whose spins prefer one axis, again $N=1$; this is the **Ising** class, and it is why iron and water share exponents. For a magnet whose spins are free to rotate in a plane, $N=2$: the **XY** class, which governs the superfluid transition in liquid helium. For fully three-dimensional spins, $N=3$: the **Heisenberg** class. And, in a beautiful limiting trick, $N \to 0$ describes the statistics of a long polymer chain that cannot cross itself.

So universality is really a *family* of universality classes indexed by $N$. The question this article is about is: can we write down the critical exponents as explicit functions of $N$, valid for the whole family at once, and prove things about them?

## Wilson's trick: make the dimension a knob

The obstruction to computing critical exponents is that at the critical point every length scale matters, so the usual approximations — expand in a small coupling, or in a small fluctuation — all fail. Kenneth Wilson's Nobel-winning insight was to change what you expand in.

In four spatial dimensions, it turns out, fluctuations are just barely too weak to change anything: the exponents take their naive "mean-field" values $\nu = 1/2$, $\gamma = 1$, $\eta = 0$. In three dimensions they are wrong. So set
$$d = 4 - \varepsilon$$
and treat $\varepsilon$, the *distance below four dimensions*, as a small parameter. Compute everything as a power series in $\varepsilon$, then boldly set $\varepsilon = 1$ at the end to get answers for our world. It sounds outrageous. It works remarkably well.

The machine that produces the series is the **renormalisation group**. One introduces a dimensionless coupling $g$ measuring the strength of the interaction between fluctuations at a given scale, and asks how $g$ changes as one coarse-grains the system, zooming out. The answer is encoded in the *beta function* $\beta(g)$, which gives the rate of change of $g$ with the logarithm of the scale. For the $O(N)$-symmetric theory of $N$ interacting fields, the leading contribution is

$$\beta_N(\varepsilon, g) \;=\; -\varepsilon\, g \;+\; \frac{N+8}{3}\, g^2 .$$

Everything in this article flows from that one expression. The linear term $-\varepsilon g$ is pure dimensional analysis: below four dimensions the coupling grows as you zoom out. The quadratic term comes from counting the ways two interaction vertices can be joined by a pair of internal lines; the combinatorial factor $N+8$ is the fingerprint of the $O(N)$ symmetry — $N$ ways for the internal loop to run over the field components, plus $8$ from the two distinct pairings of external legs.

## The Wilson–Fisher fixed point

A scale-invariant system is one that looks the same after zooming out, which means the coupling must stop flowing: $\beta_N(\varepsilon, g) = 0$. Factor the beta function as $g\left(-\varepsilon + \tfrac{N+8}{3}g\right)$ and you see immediately that there are exactly two solutions, and no others:

> **Classification of fixed points.** For every $N \neq -8$ and every $\varepsilon$, the equation $\beta_N(\varepsilon, g) = 0$ holds if and only if $g = 0$ or
> $$g^*(N,\varepsilon) \;=\; \frac{3\varepsilon}{N+8}.$$

The first is the **Gaussian** fixed point, the free theory, which describes criticality in high dimensions. The second is the **Wilson–Fisher** fixed point, and it is the one that governs real phase transitions below four dimensions. Note that it exists as a positive coupling precisely when $\varepsilon > 0$: the whole non-trivial theory is born at $d = 4$ and grows linearly as you descend.

Which one does a real system flow to? Differentiate. The slope of $\beta_N$ at $g=0$ is $-\varepsilon$, negative; the Gaussian point is *repulsive* in the infrared. The slope at $g^*$ is
$$\frac{\partial \beta_N}{\partial g}\Big|_{g = g^*} \;=\; -\varepsilon + 2\cdot\frac{N+8}{3}\cdot\frac{3\varepsilon}{N+8} \;=\; \varepsilon,$$
positive, so the Wilson–Fisher point is *attractive*. Below four dimensions the two fixed points have exchanged stability, and every system with a weak-enough coupling is dragged to Wilson–Fisher. Remarkably, that slope is exactly $\varepsilon$ — with no trace of $N$ at all. Since the slope is precisely the *correction-to-scaling exponent* $\omega$, which controls how fast a real experiment converges to its asymptotic critical behaviour, we get: at leading order, $\omega = \varepsilon$ for every $N$ simultaneously.

The attraction is not merely a statement about slopes. Following the coarse-graining flow explicitly — as a step-by-step iteration $g_{n+1} = g_n - h\,\beta_N(\varepsilon,g_n)$ with any step size $h$ satisfying $0 < h \le 1/\varepsilon$ — one can prove that any starting coupling strictly between $0$ and $g^*$ produces a sequence that stays in that interval, increases at every step, and converges to $g^*$. The basin of attraction $(0, g^*)$ and the admissible step sizes are the same for all $N \ge 0$: the picture is genuinely uniform in the symmetry index.

## The exponents, as rational functions of $N$

Feeding the fixed-point coupling into the standard formulas for the scaling dimensions gives the whole table of critical exponents as explicit rational functions of $N$:

$$\eta = \frac{(N+2)\,\varepsilon^2}{2(N+8)^2}, \qquad \frac{1}{\nu} = 2 - \frac{(N+2)\,\varepsilon}{N+8}, \qquad \nu = \frac12 + \frac{(N+2)\,\varepsilon}{4(N+8)},$$

$$\gamma = 1 + \frac{(N+2)\,\varepsilon}{2(N+8)}, \qquad \alpha = \frac{(4-N)\,\varepsilon}{2(N+8)}, \qquad \beta = \frac12 - \frac{3\varepsilon}{2(N+8)}, \qquad \delta = 3 + \varepsilon, \qquad \omega = \varepsilon.$$

Here $\eta$ measures how the correlation between two distant points decays at criticality, $\nu$ governs the correlation length, $\gamma$ the susceptibility, $\alpha$ the specific heat, $\beta$ the growth of the order parameter below $T_c$, and $\delta$ the response to an external field exactly at $T_c$.

Set $N=1$ and everything collapses onto Wilson's original one-component answers: $\eta = \varepsilon^2/54$, $\nu = \tfrac12 + \tfrac{\varepsilon}{12}$, $\gamma = 1 + \tfrac{\varepsilon}{6}$, $\alpha = \varepsilon/6$, $\beta = \tfrac12 - \tfrac{\varepsilon}{6}$. Set $\varepsilon = 1$ for three dimensions and you get $\nu \approx 0.583$ against the measured $0.630$ — a first-order estimate, crude but unmistakably in the right place.

These are not just formulas; they are formulas one can *reason about* uniformly in $N$, and doing so turns up structure that no single value of $N$ could reveal.

## $N = 4$: a hidden extremum

Look at the coefficient of $\varepsilon^2$ in $\eta$, namely $\eta_2(N) = (N+2)/\big(2(N+8)^2\big)$. As $N$ grows, the numerator grows linearly and the denominator quadratically, so $\eta_2 \to 0$: highly symmetric systems have vanishing anomalous dimension. But it does not decrease monotonically. Differentiating, the numerator of $\eta_2'$ is proportional to $(N+8)(4-N)$, so $\eta_2$ *increases* up to $N=4$ and *decreases* thereafter. Hence:

> **Maximality at four components.** For every real $N > -8$, $\eta_2(N) \le 1/48$, with equality if and only if $N = 4$.

So the anomalous dimension is largest — and thus the deviation from naive scaling most pronounced — exactly for four-component order parameters. As a corollary, $0 < \eta \le \varepsilon^2/48$ for every $N \ge 0$, with a bound completely independent of $N$.

And then something curious: $N=4$ is *also* where the specific-heat exponent $\alpha = (4-N)\varepsilon/\big(2(N+8)\big)$ changes sign. For $N < 4$ the specific heat diverges at the critical point; at $N=4$ it stops diverging; for $N > 4$ the exponent is negative and the specific heat merely has a kink. Two apparently unrelated features of the theory — the peak of the anomalous dimension and the death of the specific-heat divergence — sit at the same place, both traceable to the factor $(4-N)$ that emerges from $\tfrac{d}{dN}\tfrac{N+2}{(N+8)^2}$ and from the combination $(N+8) - 2(N+2)$ respectively.

The correlation-length exponent behaves more simply: its coefficient $\nu_1(N) = (N+2)/\big(4(N+8)\big)$ increases strictly with $N$ and lies in the window $1/16 \le \nu_1 < 1/4$ for all $N \ge 0$. More symmetry always means more fluctuation-driven enhancement of $\nu$ — but never more than the ceiling $1/4$.

## A sanity check from infinity

The upper endpoint $1/4$ is not arbitrary. As $N \to \infty$ the $O(N)$ model becomes exactly solvable — it degenerates into the *spherical model*, whose exponents are known in closed form for every dimension:
$$\nu_{\text{sph}} = \frac{1}{d-2}, \qquad \alpha_{\text{sph}} = \frac{d-4}{d-2}, \qquad \eta_{\text{sph}} = 0.$$
In $d = 4-\varepsilon$ these become $1/(2-\varepsilon)$ and $-\varepsilon/(2-\varepsilon)$. Expanding, $1/(2-\varepsilon) = \tfrac12 + \tfrac{\varepsilon}{4} + O(\varepsilon^2)$ — precisely the $N\to\infty$ limit of our $\nu$. The discrepancy is exactly
$$\frac{1}{2-\varepsilon} - \left(\frac12 + \frac{\varepsilon}{4}\right) = \frac{\varepsilon^2}{4(2-\varepsilon)},$$
which is at most $\varepsilon^2/4$ for $|\varepsilon|\le 1$. Similarly the $\alpha$ limits agree with an error at most $\varepsilon^2/2$. And $\eta_2 \to 0$, matching $\eta_{\text{sph}} = 0$. An expansion derived from Feynman diagrams in the perturbative regime is checked, quantitatively, against an independent exact solution at the opposite extreme.

There is one more distinguished value, and it is negative. At $N = -2$ every leading coefficient vanishes simultaneously — $\eta$, the correction to $\nu$, the correction to $\gamma$ all become zero, so the exponents are exactly Gaussian. And $N=-2$ is the *only* value where this happens. The "$O(-2)$ model" sounds like nonsense, but it is a genuine and well-known curiosity of the theory: the formal continuation in $N$ has a point where all fluctuation corrections switch off.

## Scaling relations: which ones survive, and by how much

Thermodynamics imposes relations among the exponents. Four classical ones are:
$$\alpha + 2\beta + \gamma = 2 \quad (\text{Rushbrooke}), \qquad \gamma = \nu(2-\eta) \quad (\text{Fisher}),$$
$$2 - \alpha = d\nu \quad (\text{Josephson}), \qquad \delta = 1 + \gamma/\beta \quad (\text{Widom}).$$

Do our truncated formulas obey them? Rushbrooke does — *exactly*, identically in both $N$ and $\varepsilon$. Substituting, the $\varepsilon$-terms are $\big[(4-N) - 6 + (N+2)\big]\varepsilon/\big(2(N+8)\big)$, and the bracket vanishes identically. Not approximately: the residues at $N=-8$ cancel for every $N$ at once.

The other three do not hold exactly, and the failures are informative because they can be computed in closed form.

- **Widom.** $1 + \gamma/\beta - \delta = \dfrac{3\varepsilon^2}{N+8-3\varepsilon}$. The $O(\varepsilon)$ part cancels for every $N$ simultaneously, and the numerator of the leading defect, $3\varepsilon^2$, carries no $N$ at all.
- **Josephson**, in $d = 4-\varepsilon$: $\;(2-\alpha) - (4-\varepsilon)\nu = \dfrac{(N+2)\varepsilon^2}{4(N+8)}$.
- **Fisher.** Here something more interesting happens: at this order $\gamma = 2\nu$ holds *exactly*, so $\gamma/\nu = 2$ and the naive reading of Fisher's relation would force $\eta = 0$, which is false. The honest statement is the exact deficit identity $\gamma - \nu(2-\eta) = \nu\eta$.

There is a structural principle behind this pattern, and it explains the whole table at a glance. Every first-order exponent above is an affine function of $\nu$: indeed $\gamma = 2\nu$ and $\alpha = 2 - 4\nu + \varepsilon/2$, and similarly for $\beta$. So as $N$ ranges over its admissible values, the exponent vector $(\alpha,\beta,\gamma,\delta,\nu,\eta,\omega)$ traces out a *straight line* in exponent space, parameterised by $\nu$ alone. Consequently every scaling relation that is *linear* in the exponents — Rushbrooke — must hold identically along that line. Every relation that is *nonlinear* — Fisher, Widom, Josephson, each involving a product or quotient of exponents — picks up a deficit which is exactly its second-order Taylor term along the line, hence $O(\varepsilon^2)$: invisible at the order to which we worked, and computable in closed form.

One especially clean consequence ties the two-loop datum $\eta$ back to purely one-loop information:
$$3\eta = (2\nu - 1)\, g^*,$$
an exact identity in $N$ and $\varepsilon$. Both sides are $O(\varepsilon^2)$; the relation says the anomalous dimension is not independent data but is fixed by the enhancement of $\nu$ and the strength of the fixed-point coupling.

## Going one loop deeper — without series

At the next order the beta function acquires a cubic term,
$$\beta_N(\varepsilon,g) = -\varepsilon g + a\,g^2 - c\,g^3, \qquad a = \frac{N+8}{3},$$
and the non-Gaussian zero is no longer a polynomial in $\varepsilon$. One can still control it exactly. Removing the factor $g$ leaves a quadratic, $c g^2 - a g + \varepsilon$, which is positive at $g = \varepsilon/a$ (value $c\varepsilon^2/a^2$) and non-positive at $g = 2\varepsilon/a$ whenever $4c\varepsilon \le a^2$. The intermediate value theorem then supplies a root in $[\varepsilon/a,\,2\varepsilon/a]$, and squeezing the algebra gives the sharp two-sided estimate
$$0 \;\le\; g^* - \left(\frac{\varepsilon}{a} + \frac{c\,\varepsilon^2}{a^3}\right) \;\le\; \frac{12\,c^2 \varepsilon^3}{a^5}.$$
No formal power series is involved, and the correction to $\omega$ is controlled the same way: $|\omega - (\varepsilon - c\varepsilon^2/a^2)| \le 12c^2\varepsilon^3/a^4$.

Specialising to the standard two-loop coefficient $c = (3N+14)/9$, the fixed point is
$$g^*(N,\varepsilon) = \frac{3\varepsilon}{N+8} + \frac{27\,c\,\varepsilon^2}{(N+8)^3} + O(\varepsilon^3),$$
and — this is the point — the constant in the remainder can be taken to be $1$, *independently of $N$*, for all $N \ge 0$ and $0 < \varepsilon \le 4/7$. Uniformity here is not free. The naive constant $12c^2/a^5$ looks like it might blow up, since $c$ grows linearly in $N$; it does not, because $a = (N+8)/3$ grows too and appears to the fifth power. In physical terms: the two-loop remainder is uniformly small *because* the fixed-point coupling shrinks like $1/N$. Highly symmetric models are weakly coupled at criticality, and perturbation theory rewards them.

## Why the parameter matters

It would have been possible to compute all of this one $N$ at a time — Ising, then XY, then Heisenberg — and never notice anything. Treating $N$ as a variable turns a list of numbers into an object with a shape, and the shape has features: a maximum at $N=4$, a sign change at $N=4$, a Gaussian point at $N=-2$, a ceiling of $1/4$ at infinity that an independent exact solution confirms, a straight line in exponent space that explains exactly which thermodynamic identities survive truncation and which acquire computable deficits.

That is the recurring lesson of the renormalisation group, and perhaps of mathematics generally. Universality says the microscopic details do not matter. Parameterising by $N$ says: here is precisely, quantitatively, what *does*.
