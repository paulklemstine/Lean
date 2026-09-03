# One Formula for Every Symmetry

### A guided tour of the $O(N)$ critical exponents

Water at $374^\circ\mathrm{C}$ and iron at $770^\circ\mathrm{C}$ have nothing in common — different atoms, different forces, different states of matter. Yet if you measure how sharply their properties blow up at the critical point, you get *the same numbers*. That is **universality**, and it is one of the strangest facts in physics.

Almost nothing about the microscopic system survives to the critical point. Two things do: the dimension $d$ of space, and the number $N$ of components of the *order parameter* — the quantity that becomes non-zero in the ordered phase.

| $N$ | Class | Where you find it |
|---|---|---|
| $0$ | Self-avoiding walk | A long polymer that cannot cross itself |
| $1$ | Ising | Uniaxial magnets, simple fluids, binary alloys |
| $2$ | XY | Superfluid helium-4, planar magnets |
| $3$ | Heisenberg | Isotropic ferromagnets |
| $\infty$ | Spherical | Exactly solvable |

Universality is therefore not one statement but a *family* of statements indexed by $N$. This page is about writing the critical exponents down as explicit functions of $N$, valid for the whole family at once — and about the structure that only becomes visible when you do.

---

## 1. The one polynomial everything comes from

At a critical point every length scale matters, so the usual approximations all fail. Kenneth Wilson's escape was to change what you expand in. In four spatial dimensions fluctuations are just barely too weak to shift the exponents from their naive "mean-field" values. So set
$$d = 4 - \varepsilon$$
and treat $\varepsilon$, the *distance below four dimensions*, as the small parameter. Compute in powers of $\varepsilon$, then set $\varepsilon = 1$ at the end for our three-dimensional world. It sounds outrageous. It works.

The machine that generates the series is the **renormalisation group**: one tracks a dimensionless coupling $g$ measuring the strength of the interaction at a given scale, and asks how $g$ drifts as you coarse-grain — zoom out. The drift rate is the *beta function*. For $N$ interacting components with $O(N)$ symmetry, the leading contribution is

$$\boxed{\;\beta_N(\varepsilon, g) \;=\; -\varepsilon\, g \;+\; \frac{N+8}{3}\, g^2\;}$$

The linear term is pure dimensional analysis. The quadratic term counts the ways two interaction vertices join through a pair of internal lines; the coefficient $N+8$ is the fingerprint of the symmetry — $N$ from an internal index loop, $8$ from the remaining pairings.

<details>
<summary><strong>Prerequisite refresher:</strong> what the critical exponents actually mean</summary>

Write $t = (T-T_c)/T_c$ for the reduced temperature. Then, near the transition,

- **Correlation length** $\xi \sim |t|^{-\nu}$ — the typical size of the largest coherent patch. Diverges at $T_c$.
- **Susceptibility** $\chi \sim |t|^{-\gamma}$ — how strongly the system responds to a small external field.
- **Specific heat** $C \sim |t|^{-\alpha}$ — the energy needed to raise the temperature. If $\alpha < 0$ there is no divergence, only a cusp.
- **Order parameter** $M \sim (-t)^{\beta}$ for $t<0$ — how the magnetisation (or density difference) switches on below $T_c$.
- **Critical isotherm** $M \sim H^{1/\delta}$ exactly at $T_c$.
- **Anomalous dimension** $\eta$: at $T_c$ the two-point correlation decays as $|x|^{-(d-2+\eta)}$. Naive scaling would give $\eta = 0$; fluctuations make it positive.
- **Correction to scaling** $\omega$: the exponent controlling how fast an experiment converges to the asymptotic critical form. It is the one exponent that is not about a divergence but about the *approach* to one.

Mean-field theory predicts $\nu = 1/2$, $\gamma = 1$, $\alpha = 0$, $\beta = 1/2$, $\delta = 3$, $\eta = 0$. Everything below measures the departure from that.
</details>

---

## 2. Play with it

Before any algebra, turn the knobs yourself. The widget below computes everything live from that single quadratic. Watch three things in particular:

1. The beta function always crosses zero in exactly two places, and the right-hand crossing moves *left* as you increase $N$.
2. The slope at that right-hand crossing is always exactly $\varepsilon$ — no trace of $N$.
3. In the third table, one row never leaves zero no matter what you do.

{{interactive_demo:0}}

---

## 3. Two fixed points, and no others

Factor the beta function:
$$\beta_N(\varepsilon, g) = g\left(-\varepsilon + \frac{N+8}{3}g\right).$$

A product vanishes exactly when a factor does, so for every $N \neq -8$ the complete zero set is

$$g = 0 \qquad\text{(Gaussian)} \qquad\text{and}\qquad g^* = \frac{3\varepsilon}{N+8} \qquad\text{(Wilson–Fisher)}.$$

There is no third fixed point. The Gaussian point is the free theory; the Wilson–Fisher point exists as a positive coupling exactly when $\varepsilon > 0$, that is, below four dimensions.

Which one wins? Differentiate. At $g=0$ the slope is $-\varepsilon < 0$; at $g^*$ it is
$$-\varepsilon + 2\cdot\frac{N+8}{3}\cdot\frac{3\varepsilon}{N+8} = \varepsilon > 0.$$
Under the infrared flow (the direction of coarse-graining) positive slope means attraction. So below four dimensions the two fixed points have exchanged stability, and everything is dragged to Wilson–Fisher. That slope is the correction-to-scaling exponent, so
$$\omega = \varepsilon \quad\text{for every } N \text{ simultaneously}.$$

Notice also that $g^*$ shrinks like $3\varepsilon/N$: **more symmetry means weaker coupling at criticality**. Keep that in mind; it comes back at the very end.

<details>
<summary><strong>Beyond the linearisation:</strong> Wilson–Fisher really is the attractor</summary>

A slope calculation only tells you what happens infinitesimally close to the fixed point. The stronger statement is about the actual iteration. Write $a_N = (N+8)/3$ and run the discrete infrared flow
$$g_{k+1} = g_k - h\,\beta_N(\varepsilon, g_k) = g_k\left(1 + h\varepsilon - h a_N g_k\right)$$
with any step size $0 < h \le 1/\varepsilon$ and any start $0 < g_0 < g^*$.

*Invariance.* The exact identity
$$\frac{\varepsilon}{a_N} - g_k\left(1 + h a_N\!\left(\tfrac{\varepsilon}{a_N} - g_k\right)\right) = \left(\frac{\varepsilon}{a_N} - g_k\right)\left(1 - h a_N g_k\right)$$
shows the step cannot overshoot: the first factor is positive because $g_k < g^*$, and the second because $h a_N g_k < h\varepsilon \le 1$.

*Monotonicity.* $g_{k+1} - g_k = h\, g_k(\varepsilon - a_N g_k) > 0$ on the whole interval.

*Convergence.* An increasing sequence bounded above converges. Passing to the limit in the recursion gives $L\,h(\varepsilon - a_N L) = 0$, and since $L \ge g_0 > 0$, necessarily $L = \varepsilon/a_N = g^*$.

The basin $(0, g^*)$ and the admissible step range are the **same for every $N \ge 0$**. Panel (b) of the widget above is exactly this iteration.
</details>

---

## 4. The exponent table

Feed $g^*$ into the standard scaling formulas and the whole table drops out as rational functions of $N$:

$$\eta = \frac{(N+2)\varepsilon^2}{2(N+8)^2}, \qquad \nu = \frac12 + \frac{(N+2)\varepsilon}{4(N+8)}, \qquad \gamma = 1 + \frac{(N+2)\varepsilon}{2(N+8)},$$

$$\alpha = \frac{(4-N)\varepsilon}{2(N+8)}, \qquad \beta = \frac12 - \frac{3\varepsilon}{2(N+8)}, \qquad \delta = 3+\varepsilon, \qquad \omega = \varepsilon.$$

Setting $N=1$ recovers the classical one-component answers: $\eta = \varepsilon^2/54$, $\nu = \tfrac12 + \tfrac{\varepsilon}{12}$, $\gamma = 1 + \tfrac{\varepsilon}{6}$. At $\varepsilon = 1$ that gives $\nu \approx 0.583$ against the measured $0.630$ — crude, but unmistakably in the right place for a first-order truncation evaluated at a value of $\varepsilon$ that is not small.

Here is the routine that evaluates the table, together with the closed-form deficits we will meet in §6.

{{algorithm:0}}

And here is the full numerical demonstration, checking every claim on this page to machine precision:

{{demo:0}}

---

## 5. $N = 4$: a hidden extremum

Look at the coefficient of $\varepsilon^2$ in the anomalous dimension,
$$\eta_2(N) = \frac{N+2}{2(N+8)^2}.$$
Numerator linear, denominator quadratic, so $\eta_2 \to 0$ at large $N$. But it does not fall monotonically. The derivative of $(N+2)/(N+8)^2$ has numerator
$$(N+8)^2 - 2(N+2)(N+8) = (N+8)\big[(N+8) - 2(N+2)\big] = (N+8)(4-N),$$
so $\eta_2$ **rises up to $N = 4$ and falls thereafter**. Cleanly:

> For every real $N > -8$, $\;\eta_2(N) \le \dfrac{1}{48}$, with equality if and only if $N = 4$.

The proof is a single line: clearing denominators turns the claim into $0 \le 2(N-4)^2$. As a corollary $0 < \eta \le \varepsilon^2/48$ for every $N \ge 0$, a bound with no $N$ in it at all.

And now the curious part. The specific-heat exponent is
$$\alpha = \frac{(4-N)\varepsilon}{2(N+8)},$$
whose sign is that of $4-N$. So $N=4$ is *also* exactly where the specific heat stops diverging: positive $\alpha$ for $N < 4$, zero at $N=4$, negative above. Two apparently unrelated features of the theory sit at the same value of $N$, both traceable to the factor $(4-N)$ — once from a derivative, once from the cancellation $(N+8) - 2(N+2)$.

Panel (a) of the figure below shows both features at once. Panels (b)–(d) show the exponents themselves, the affine line they live on, and the scaling deficits of §6.

{{visualization:0}}

---

## 6. Which laws of thermodynamics survive truncation?

Classical scaling theory predicts four relations:
$$\alpha + 2\beta + \gamma = 2 \;\;\text{(Rushbrooke)}, \qquad \gamma = \nu(2-\eta) \;\;\text{(Fisher)},$$
$$2-\alpha = d\nu \;\;\text{(Josephson)}, \qquad \delta = 1 + \gamma/\beta \;\;\text{(Widom)}.$$

Truncated exponents have no obligation to satisfy any of them. **Exactly one does.**

**Rushbrooke is an exact identity in $(N,\varepsilon)$.** The constant terms give $0 + 1 + 1 = 2$; the $\varepsilon$-terms have common denominator $2(N+8)$ and numerator
$$(4-N) - 6 + (N+2) = 0,$$
identically in $N$. Not "to leading order" — identically.

The other three fail, and the failures can be computed in closed form:

| Relation | Deficit |
|---|---|
| Widom: $1 + \gamma/\beta - \delta$ | $\dfrac{3\varepsilon^2}{N+8-3\varepsilon}$ |
| Josephson: $(2-\alpha) - (4-\varepsilon)\nu$ | $\dfrac{(N+2)\varepsilon^2}{4(N+8)}$ |
| Fisher: $\gamma - \nu(2-\eta)$ | $\nu\,\eta$ |

The Widom numerator $3\varepsilon^2$ carries no $N$ whatsoever, and its $O(\varepsilon)$ part cancels for every $N$ simultaneously.

<details>
<summary><strong>The structural reason — and a trap worth knowing about</strong></summary>

At this order the exponents satisfy, identically in $N$,
$$\gamma = 2\nu, \qquad \alpha = 2 - 4\nu + \frac{\varepsilon}{2}, \qquad 2\beta = 2 - \alpha - \gamma.$$
In other words, as $N$ ranges over its admissible values the whole exponent vector $(\alpha,\beta,\gamma,\delta,\nu,\eta,\omega)$ traces out a **single straight line** in exponent space, parameterised by $\nu$ alone. Panel (c) of the figure above is a picture of exactly that line.

From this everything follows at once:

- A relation that is **affine** in the exponents either holds along the whole line or nowhere on it. Rushbrooke holds. That is why it is exact.
- A relation that is **nonlinear** — Fisher and Josephson involve products, Widom a quotient — picks up a deficit equal to its second-order Taylor term along the line. That deficit is $O(\varepsilon^2)$: invisible at the order to which we worked, and computable exactly.

**The trap.** Since $\gamma/\nu = 2$ identically, the naive reading of Fisher's relation, $\eta = 2 - \gamma/\nu$, returns $\eta = 0$ — flatly contradicting $\eta = (N+2)\varepsilon^2/(2(N+8)^2) > 0$. The relation is not "approximately satisfied"; it is uninformative at this order. The honest statement is the exact identity
$$\gamma - \nu(2-\eta) = \nu\eta.$$
The lesson generalises: a first-order truncation cannot test any relation that probes the *curvature* of the exponent manifold, because at first order the manifold is flat.

One more exact identity worth recording ties the two-loop datum $\eta$ back to purely one-loop information:
$$3\eta = (2\nu - 1)\,g^*.$$
The anomalous dimension is not independent input; it is fixed by the enhancement of $\nu$ and the strength of the fixed-point coupling.
</details>

---

## 7. A check from the opposite extreme

As $N \to \infty$ the $O(N)$ model degenerates into the [spherical model](https://en.wikipedia.org/wiki/Spherical_model), which is exactly solvable in every dimension:
$$\nu_{\text{sph}} = \frac{1}{d-2}, \qquad \alpha_{\text{sph}} = \frac{d-4}{d-2}, \qquad \eta_{\text{sph}} = 0.$$

Our formulas have limits $\eta \to 0$, $\nu \to \tfrac12 + \tfrac{\varepsilon}{4}$, $\alpha \to -\tfrac{\varepsilon}{2}$. Setting $d = 4-\varepsilon$ in the exact answers and subtracting:
$$\frac{1}{2-\varepsilon} - \left(\frac12 + \frac{\varepsilon}{4}\right) = \frac{\varepsilon^2}{4(2-\varepsilon)}, \qquad \frac{-\varepsilon}{2-\varepsilon} + \frac{\varepsilon}{2} = \frac{-\varepsilon^2}{2(2-\varepsilon)}.$$
Both are second order, bounded by $\varepsilon^2/4$ and $\varepsilon^2/2$ for $|\varepsilon| \le 1$. A perturbative construction valid a priori only near $d=4$ agrees, quantitatively, with a non-perturbative exact solution at the far end of the symmetry parameter. The fourth table in the widget above tracks this live.

There is also a distinguished *negative* value. At $N = -2$ every leading coefficient vanishes simultaneously — $\eta_2$, the correction to $\nu$, the correction to $\gamma$ — because each has $(N+2)$ in its numerator. The exponents collapse to mean field, and $N = -2$ is the only value where this happens.

---

## 8. Going one loop deeper, without power series

At the next order the beta function acquires a cubic term,
$$\beta_N(\varepsilon,g) = -\varepsilon g + a g^2 - c g^3, \qquad a = \frac{N+8}{3},$$
and the non-Gaussian zero is no longer a polynomial in $\varepsilon$. You can still pin it down exactly.

Divide out the factor $g$ to leave the quadratic $f(x) = cx^2 - ax + \varepsilon$. Then $f(\varepsilon/a) = c\varepsilon^2/a^2 \ge 0$ and $f(2\varepsilon/a) = (4c\varepsilon - a^2)\varepsilon/a^2 \le 0$ whenever $4c\varepsilon \le a^2$. A sign change on a bracket means a root, and squeezing the algebra gives the certified two-sided estimate
$$0 \;\le\; g^* - \left(\frac{\varepsilon}{a} + \frac{c\varepsilon^2}{a^3}\right) \;\le\; \frac{12\,c^2\varepsilon^3}{a^5}.$$

There is also an exact algebraic bonus: along the zero locus, $\partial_g\beta = \varepsilon - c g^2$ identically, so $\omega$ inherits the same kind of certificate, $|\omega - (\varepsilon - c\varepsilon^2/a^2)| \le 12c^2\varepsilon^3/a^4$.

{{algorithm:1}}

With the standard two-loop coefficient $c = (3N+14)/9$, the fixed point is
$$g^* = \frac{3\varepsilon}{N+8} + \frac{27\,c\,\varepsilon^2}{(N+8)^3} + O(\varepsilon^3),$$
and the remainder constant can be taken to be $1$ **independently of $N$**, for all $N \ge 0$ and $0 < \varepsilon \le 4/7$.

<details>
<summary><strong>Why that uniformity is not free</strong></summary>

The certificate constant is $12c^2/a^5$, and $c = (3N+14)/9$ grows linearly in $N$, so $c^2$ grows quadratically. Uniformity survives only because $a = (N+8)/3$ appears to the *fifth* power: the net behaviour is $O(N^2/N^5) = O(N^{-3})$.

Concretely: $c \le a$, and $a \ge 8/3$ gives $a^3 \ge (8/3)^3 = 512/27 > 12$, hence $12c^2/a^5 \le 12a^2/a^5 = 12/a^3 \le 1$.

The physical reading is the one we flagged in §3. The two-loop remainder is uniformly small **because the fixed-point coupling shrinks like $1/N$**. Highly symmetric models are weakly coupled at their critical point, and perturbation theory rewards them — which is precisely why the $N=\infty$ limit is exactly solvable in the first place.
</details>

The visualization below shows the flow itself: the beta function and its two zeros for several $N$, the discrete iteration converging from inside the basin, and the two-loop cubic pushing the fixed point outward.

{{visualization:1}}

---

## 9. What parameterising bought us

Every individual formula in §4 could have been computed one $N$ at a time — Ising, then XY, then Heisenberg — and nothing on this page after §4 would have been noticed. Treating $N$ as a variable turns a list of numbers into an object with a shape, and the shape has features:

- a **maximum** of the anomalous dimension at exactly $N=4$, with the $N$-free bound $\eta \le \varepsilon^2/48$;
- a **sign change** of the specific-heat exponent at the same $N=4$, for an algebraically distinct reason;
- a **ceiling** of $1/4$ on the $\nu$-coefficient, approached but never attained, and confirmed by an independent exact solution;
- a **Gaussian point** at $N=-2$, unique in the whole continued family;
- a **straight line** in exponent space that explains, in one stroke, which thermodynamic identities survive truncation and which acquire computable deficits;
- **$N$-uniform** dynamical and two-loop statements, with explicit constants and explicit ranges of validity.

Universality says the microscopic details do not matter. Parameterising by $N$ says: here is precisely, quantitatively, what *does*.

---

### Where to read further

- [Renormalization group](https://en.wikipedia.org/wiki/Renormalization_group) — the general framework.
- [Critical exponent](https://en.wikipedia.org/wiki/Critical_exponent) — definitions and measured values.
- [Universality class](https://en.wikipedia.org/wiki/Universality_class) — the classification this page is a slice of.
- [Ising model](https://en.wikipedia.org/wiki/Ising_model) — the $N=1$ member, and the most studied model in statistical physics.
- [Spherical model](https://en.wikipedia.org/wiki/Spherical_model) — the exactly solvable $N=\infty$ limit used as a cross-check in §7.
