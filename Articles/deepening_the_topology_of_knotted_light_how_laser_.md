# The Arithmetic of Knotted Light

## When darkness becomes a thread

A laser beam looks, at first glance, like the simplest possible object: a bright line traveling through space. Yet inside a carefully shaped beam there can be a hidden skeleton made not of light, but of darkness. Along this skeleton the optical amplitude is exactly zero, so the wave’s phase cannot be assigned. These phase singularities can bend into loops, link with one another, and trace knots. A trefoil-shaped dark filament inside a luminous field is one of the most striking examples of “knotted light.”

The geometry is spectacular, but it is sustained by a quieter piece of mathematics. Around a dark filament, the optical phase winds. Walk once around the filament and the phase may complete one turn, several turns, or the same number of turns in the opposite direction. This signed count is the local topological charge. It is closely related to orbital angular momentum, and it governs how optical vortices combine.

The central message of this article is an arithmetic law for such winding: multiplication of nonvanishing optical modes adds their charges; taking a positive power multiplies charge; inversion reverses it; and an arbitrary integer-powered product produces the corresponding integer linear combination of charges. The rules resemble ordinary algebra because they arise from one of calculus’s most useful identities—the logarithmic derivative turns multiplication into addition.

## A loop around the singularity

To isolate the essential mechanism, imagine sampling a complex optical field along a closed circular path surrounding a suspected vortex. Parameterize one turn by an angle $\theta$ from $0$ to $2\pi$, and denote the sampled complex amplitude by $\gamma(\theta)$. We require three regularity conditions: $\gamma$ is differentiable, its chosen derivative $\gamma'$ is continuous, and $\gamma(\theta)\neq 0$ everywhere on the sampling loop. The last condition is crucial. The contour may enclose darkness, but it must not pass through darkness.

The contour-integral winding is

$$
W(\gamma)=\frac{1}{2\pi i}\int_0^{2\pi}\frac{\gamma'(\theta)}{\gamma(\theta)}\,d\theta.
$$

For a genuinely closed loop, this familiar integral measures the net number of turns made by the image of $\gamma$ around the origin of the complex plane. The present results concern the analytic laws obeyed by this integral under multiplication, powers, and inversion. Those laws require smoothness and nonvanishing, but not the separate quantization theorem asserting that every closed-loop winding is an integer.

The simplest model is the pure helical mode

$$
\gamma_m(\theta)=e^{im\theta},
$$

where $m$ is an integer. Since $\gamma_m'/\gamma_m=im$, direct integration gives $W(\gamma_m)=m$. A positive value means one orientation of phase circulation, while a negative value means the reverse.

## Why products add

Suppose $\gamma$ and $\delta$ are two smooth complex fields that never vanish along the contour. Their coherent product is the pointwise field

$$
(\gamma\delta)(\theta)=\gamma(\theta)\delta(\theta).
$$

The product is again smooth and nowhere zero. More importantly, the product rule gives

$$
\frac{(\gamma\delta)'(\theta)}{\gamma(\theta)\delta(\theta)}
=
\frac{\gamma'(\theta)}{\gamma(\theta)}+
\frac{\delta'(\theta)}{\delta(\theta)}.
$$

Integrating both sides yields the **Winding Product Theorem**:

> If $\gamma$ and $\delta$ are differentiable complex fields with continuous derivatives and neither vanishes on the contour, then their product is also smooth and nonvanishing there, and
> $$
> W(\gamma\delta)=W(\gamma)+W(\delta).
> $$

This is charge conservation in its cleanest analytic form. The two modes may have complicated amplitude and phase variations; they need not be pure helices. As long as neither crosses zero on the chosen contour, multiplication makes their winding contributions add exactly.

There is a useful physical picture. Multiplying complex amplitudes adds their phases. If one mode advances by three turns while another retreats by one, their product advances by two turns. The integral does not have to inspect the full spatial knot to record this local balance. It sees the phase circulation on the boundary.

## Repetition amplifies charge

Now multiply a mode by itself $n$ times. The resulting field is $\gamma^n$. Repeated use of the product theorem suggests that its charge should be $n$ times the original charge. The smoothness statement and the winding statement can be established together by induction.

The **Natural Power Theorem** says:

> If $\gamma$ is smooth and nowhere zero on the contour, then for every natural number $n$, the field $\gamma^n$ is smooth and nowhere zero, with derivative
> $$
> (\gamma^n)'=n\gamma^{n-1}\gamma',
> $$
> and its winding satisfies
> $$
> W(\gamma^n)=nW(\gamma).
> $$

The case $n=0$ is not an awkward exception. The zeroth power is the constant field $1$, whose derivative and winding are both zero. The induction step multiplies $\gamma^n$ by one additional copy of $\gamma$, so the product theorem adds one more $W(\gamma)$.

This law explains how high-charge vortices can be assembled algebraically. Starting from a unit-charge mode and raising it to the fifth power creates a field with charge five along the same contour, provided no zero lies on that contour.

## Mirrors made by inversion

Negative powers require inversion. For a nonzero complex field, define the inverse field pointwise by $\gamma^{-1}(\theta)=1/\gamma(\theta)$. It remains smooth and nonvanishing, and calculus gives

$$
(\gamma^{-1})'(\theta)=-\frac{\gamma'(\theta)}{\gamma(\theta)^2}.
$$

Its winding could be computed directly, but there is a more revealing argument. The product $\gamma^{-1}\gamma$ is the constant field $1$. By the product theorem,

$$
W(\gamma^{-1})+W(\gamma)=W(1)=0.
$$

Hence the **Inversion Theorem** states

$$
W(\gamma^{-1})=-W(\gamma).
$$

In optical language, inversion reverses the phase circulation. It turns every advancing phase twist into a retreating one while preserving the absence of zeros along the contour.

Combining natural powers with inversion gives the **Integer Power Theorem**:

> For every integer $k$ and every smooth field $\gamma$ that is nonzero along the contour, the field $\gamma^k$ is smooth and nonzero there, and
> $$
> W(\gamma^k)=kW(\gamma).
> $$

Positive $k$ repeats the mode, $k=0$ erases its winding by producing the constant field, and negative $k$ repeats the inverse mode.

## A two-mode charge synthesizer

The strongest result combines two arbitrary modes with independent integer weights. Let $k$ and $\ell$ be integers, and form

$$
F(\theta)=\gamma(\theta)^k\delta(\theta)^\ell.
$$

Both powered modes remain smooth and nonvanishing. Applying the product theorem once and the integer power theorem twice gives the **Two-Mode Integer Superposition Theorem**:

> If $\gamma$ and $\delta$ are smooth complex fields that never vanish on the contour, then for any integers $k$ and $\ell$,
> $$
> W\!\left(\gamma^k\delta^\ell\right)
> =kW(\gamma)+\ell W(\delta).
> $$

Despite the traditional word “superposition,” the operation here is coherent multiplication, not additive interference. That distinction matters: a sum of two nonzero fields can cancel and create new zeros on the contour, whereas a product of nonzero fields cannot. Multiplication therefore provides a particularly stable algebra for charge design.

For pure helices $\gamma_p(\theta)=e^{ip\theta}$ and $\delta_q(\theta)=e^{iq\theta}$, the combined field is

$$
\gamma_p(\theta)^k\delta_q(\theta)^\ell
=e^{i(kp+\ell q)\theta},
$$

so the output charge is $kp+\ell q$. For example, taking $p=2$, $q=-3$, $k=4$, and $\ell=-1$ produces charge $11$. The formula remains valid far beyond ideal helical waves: smooth amplitude modulation can be added, and the phase may accelerate or slow around the contour, provided the field stays nonzero.

## What this does—and does not—say about knots

A winding number around a contour is local information. It records how phase circulates around a singular filament, but it does not by itself identify whether that filament forms a trefoil, a figure-eight knot, or an unknot in three-dimensional space. Knot type concerns the global embedding of the zero set; winding charge concerns the behavior of the field around that set. The two structures interact, but they are not interchangeable.

This separation is useful. Local charge laws can be applied at many cross-sections of a three-dimensional beam. If singular filaments move and braid while avoiding the boundary contour, the winding provides a conserved ledger of phase circulation. To turn that intuition into a full deformation theory, one would next prove homotopy invariance and analyze how local charges redistribute when zeros merge or split.

Nor do the results above alone prove quantization for every closed smooth loop. They establish exact algebraic identities for the contour integral. A complementary classification theorem would show that closed nonvanishing loops always have integer winding and that zero winding is equivalent to the existence of a periodic complex logarithm. Together, those facts would connect the calculus directly to the topology of the punctured plane.

## An algebra beneath the spectacle

Knotted light is often introduced through dramatic images: luminous volumes pierced by dark trefoils, phase sheets spiraling around invisible cores, and optical vortices behaving like threads. Beneath that imagery lies a compact algebra.

Nonvanishing smooth modes are closed under multiplication, inversion, and integer powers. The winding map turns multiplication into addition, inversion into negation, and exponentiation into integer scaling. In symbols,

$$
W(\gamma\delta)=W(\gamma)+W(\delta),\qquad
W(\gamma^{-1})=-W(\gamma),\qquad
W(\gamma^k)=kW(\gamma).
$$

These equations are more than shortcuts for calculation. They show that optical phase charge can be composed predictably. A complicated field may be built from simpler factors, and its winding can be read from an integer-weighted sum rather than recomputed from scratch.

The dark thread inside a beam may twist into an elaborate knot, but around any safe contour its phase obeys a remarkably orderly arithmetic. Multiplication adds twists. Inversion flips them. Powers amplify them. The topology of light begins with this simple ledger of turns.