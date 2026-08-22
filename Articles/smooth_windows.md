# The Shape of a Window

## Why the sharpest lens is the blurriest one

Suppose you want to know how much light a star emits. You cut a square hole in a piece of
cardboard, point it at the sky, and measure everything that comes through. The hole is a
*window*: it decides what you see and what you ignore.

Every measurement of a spectrum works this way. A physicist studying a vibrating molecule, an
engineer sampling a radio channel, a number theorist counting the zeros of a function — each of
them looks at an infinite object through a finite aperture. And each of them has to choose the
shape of the hole.

The most natural choice, and the one almost everyone makes first, is the sharp one: keep
everything inside a range, throw away everything outside. In the setting we will follow through
this article, spectral data arrive as a family of *ordinates* $t$ — heights along a critical line
— each carrying a numerical weight, and the classical recipe is to keep every ordinate with
$|t| \le T$ and discard the rest. Formally, one multiplies the data by the *rectangular window*
$$\mathbf{1}_{[-T,T]}(t) = \begin{cases} 1 & |t| \le T,\\ 0 & |t| > T.\end{cases}$$

This is the honest, obvious, and — as we shall see — surprisingly treacherous thing to do. The
sharp window has a hidden cost, and the cost is paid in a currency the naive user never sees:
it manufactures peaks that are not there, it goes blind to signals that are, and it makes the
answer jump discontinuously as you turn the knob. Replacing it with a smooth window, and
specifically with a **Gaussian**
$$g_s(t) = e^{-\pi t^2/s^2}, \qquad s > 0,$$
fixes all three defects at once — and, unexpectedly, does so while *preserving exactly* the
algebra that made the sharp window convenient in the first place. That algebra turns out to be
the Heisenberg group, and the story of smooth windows is the story of how a group acts on your
choice of lens.

---

## The ringing you can hear

To see the sharp window's defect, ask what it does in the frequency domain. Multiplying data by
a window in one variable is the same as *smearing* the spectrum by the window's Fourier transform
in the other. That Fourier transform — the "transfer function" of the window — is the honest
description of what your lens does to the world.

For the rectangular window, the transfer function is a classic:
$$\widehat{\mathbf{1}_{[-T,T]}}(\xi) = \frac{\sin(2\pi T\xi)}{\pi\xi}, \qquad \xi \ne 0 .$$

It has a tall central lobe, which is the part you wanted, and then it does something you did not
want: it oscillates forever, with a decaying but *slowly* decaying envelope. Those oscillations
are the **sidelobes**. Their peaks sit at the frequencies
$$\xi_n = \frac{2n+1}{4T}, \qquad n = 0,1,2,\dots$$
and there the transfer function has the exact modulus
$$\bigl|\widehat{\mathbf{1}_{[-T,T]}}(\xi_n)\bigr| = \frac{4T}{\pi(2n+1)} .$$

Now multiply by the frequency, which is the natural way to ask "how big is this sidelobe compared
with where it sits?" The answer is startling in its rigidity:
$$\xi_n \cdot \bigl|\widehat{\mathbf{1}_{[-T,T]}}(\xi_n)\bigr| = \frac{1}{\pi}
\quad \text{for every } n \text{ and every } T .$$

Exactly $1/\pi$. Always. The normalised leakage of a sharp cutoff is a universal constant: it does
not shrink as you go to higher frequencies, and it does not shrink as you widen the window. In
particular there is no estimate of the form $|\widehat{\mathbf{1}_{[-T,T]}}(\xi)| = o(1/\xi)$;
the normalised amplitude hits $1/\pi$ infinitely often, so it certainly does not tend to zero.
Worse, the amplitudes $4T/(\pi(2n+1))$ form a divergent series: **the total spurious energy of a
sharp cutoff is infinite.**

This is not an abstract complaint. It is exactly why a peak-finding algorithm fed rectangularly
windowed data will report structure that does not exist. The sidelobes of the window masquerade
as features of the signal, at every scale, with a fixed relative height that no amount of
widening will suppress.

---

## The Gaussian has no sidelobes at all

Now do the same computation for the Gaussian window. The Gaussian is famously a fixed point of
the Fourier transform, and in the normalisation above the statement is beautifully clean:
$$\widehat{g_s} = s\, g_{1/s} .$$

The Fourier transform of a Gaussian window of width $s$ is a Gaussian window of width $1/s$,
rescaled. The family is closed; the only thing that happens is that the width inverts. That
inversion *is* the time–frequency uncertainty principle for this family, written as an identity
rather than an inequality: narrow in one variable means wide in the other, with no slack.

The consequence for peak-finding is immediate. Probing the phase-space point $(a,b)$ — position
$a$, frequency $b$ — one uses the **Gabor atom**
$$\gamma_{s,a,b}(t) = e^{2\pi i b (t-a)}\, g_s(t-a),$$
a Gaussian bump at $a$ vibrating at frequency $b$. Its transfer function has modulus
$$\bigl|\widehat{\gamma_{s,a,b}}(\xi)\bigr| = s\, g_{1/s}(\xi - b) .$$

A single Gaussian bump. No oscillation, no zeros, no sidelobes — the modulus is strictly less
than its peak value at every $\xi \ne b$, and it is *strictly decreasing* in the distance
$|\xi - b|$. And it decays faster than any power: $\xi^n \cdot |\widehat{\gamma_{s,a,b}}(\xi)| \to 0$
as $\xi \to \infty$, for every exponent $n$.

Put the two windows side by side and the comparison is not asymptotic hand-waving but a strict
inequality: along the rectangular window's own sidelobe frequencies $\xi_n$, for *any* pair of
widths $T$ and $s$, the Gaussian response is eventually strictly smaller than the rectangular
one. And where the rectangular sidelobe amplitudes are not summable, the Gaussian responses at
the very same frequencies are. A high-frequency peak seen through a Gaussian window is a feature
of the data, not a ghost of the lens.

---

## What you must not break: the Weyl relation

If smoothing were free, this article would end here. It is not free, and the reason is that a
window is useful only if you can *move* it. Any analysis slides the window along the axis and
tunes it to a frequency, and the bookkeeping of those two motions had better be exact.

The two motions are the **translation** and **modulation** operators,
$$(T_a f)(t) = f(t-a), \qquad (M_b f)(t) = e^{2\pi i b t} f(t).$$

Do they commute? Almost. Writing $\chi(x) = e^{2\pi i x}$ for the basic character, the exact
statement is the **Weyl commutation relation**
$$M_b T_a = \chi(ab)\, T_a M_b .$$

Sliding then modulating differs from modulating then sliding by a pure phase $e^{2\pi i ab}$. The
phase is not an artefact of bad bookkeeping, and it cannot be renormalised away. Take
$a = b = 1/2$ and evaluate both sides at $t = 1/2$: the two results differ by the factor
$\chi(1/4) = i$, for *any* window that does not vanish at the origin. The failure to commute is
real.

And it is the good kind of failure — the kind with a group behind it. Bundle a translation, a
modulation, and a phase into a triple $(a,b,z)$ with $|z|=1$, and multiply them by
$$(a,b,z)\cdot(a',b',z') = \bigl(a+a',\, b+b',\, z z' \chi(b a')\bigr).$$
This is the **Heisenberg group**. Its associativity is precisely the cocycle identity
$b a' + (b+b')a'' = b' a'' + b(a'+a'')$ satisfied by the Weyl phase — the group law works because
the Weyl relation holds, and for no other reason. The assignment
$$(a,b,z) \longmapsto z\, T_a M_b$$
is then a genuine homomorphism from the Heisenberg group into the operators on windows: the
composite of two Gabor shifts is a third Gabor shift, exactly. This is the **Schrödinger, or
Gabor, representation**.

Is any of this redundant? Could one quotient out the phase and keep a simpler group? No — the
representation is **faithful**, and the Gaussian alone proves it. Suppose $z\, T_a M_b$ acts as
the identity on the Gaussian. The Gaussian is nowhere zero and has a unique maximum, so comparing
moduli pins $a = 0$; evaluating at the origin pins $z = 1$; and then $\chi(bt) = 1$ for all $t$
forces $b = 0$, because $\chi(1/4) = i \ne 1$. Every Heisenberg element is detected by a single
Gaussian test vector. The central phase is not decoration; it is the group.

The Gaussian window respects this structure perfectly. The Heisenberg group simply permutes the
Gabor atoms: acting by $(a_0,b_0,z_0)$ carries the atom at phase-space point $(a,b)$ to the atom
at $(a_0+a,\, b_0+b)$, changing nothing but a phase. The smooth window can be moved anywhere in
phase space with all of its algebra intact. Nothing has been lost by smoothing.

---

## Three defects, three repairs

Return to the concrete setting: a family of ordinates $t$ on a critical line, contributing to a
windowed harmonic statistic
$$\sum_{\rho} \frac{w(\operatorname{Im}\rho)}{\rho},$$
which, on a conjugate-symmetric family with ordinates $t$, collapses to the real quantity
$\sum_t w(t)/(\tfrac14 + t^2)$. Taking $w = \mathbf{1}_{[-T,T]}$ recovers the classical sharp
cutoff exactly, so everything below is a strict generalisation, not a change of subject.

**First defect: false nulls.** The sharp cutoff returns $0$ for every $T$ below the first
ordinate. Zero is also what it returns for an empty family — the statistic cannot tell "nothing
is there" from "nothing is here yet". The Gaussian window, being strictly positive everywhere,
returns a strictly positive number for *every* nonempty family at *every* width, and returns $0$
only for the empty family. A conjugate pair of zeros with ordinate $t$ outside the cutoff is
completely invisible to the sharp window and detected by every Gaussian.

**Second defect: discontinuity.** As you widen a sharp cutoff, the statistic sits still and then
jumps, by exactly $1/(\tfrac14+t^2)$, each time $T$ crosses an ordinate $|t|$; it is not
continuous at those points. The Gaussian statistic $s \mapsto \sum_t g_s(t)/(\tfrac14+t^2)$ is
continuous in the width, non-decreasing, and strictly increasing as soon as one nonzero ordinate
is present. It is a genuine **scale space**: a smooth one-parameter family running from "see
nothing" at $s \to 0$ to "see everything" at $s \to \infty$, where it converges to the full
unwindowed harmonic sum $\sum_t 1/(\tfrac14+t^2)$. The smooth statistic is a deformation of the
classical one, not a competitor.

**Third defect: resolution.** When are two nearby ordinates $t_1 \ne t_2$ seen as two peaks
rather than one? Slide the Gaussian to position $a$ and record the profile
$P(a) = \sum_t g_s(t-a)/(\tfrac14+t^2)$. For a single ordinate this profile has a strict global
maximum exactly at that ordinate — a Gaussian window never displaces a peak. For two, the
Gaussian's scale-doubling identities $g_s(d/2) = g_{2s}(d)$ and $g_s(d) = g_{2s}(d)^4$ turn the
whole question into one variable. Setting $u = g_{2s}(t_1-t_2)$ and $w_i = 1/(\tfrac14+t_i^2)$,
$$P(t_1) = w_1 + u^4 w_2, \qquad P\!\left(\tfrac{t_1+t_2}{2}\right) = u\,(w_1+w_2),$$
so that
$$P(t_1) - P\!\left(\tfrac{t_1+t_2}{2}\right) = (1-u)\bigl(w_1 - u(1+u+u^2)\,w_2\bigr).$$

The factorisation is the whole answer. The first factor vanishes only when $u = 1$, i.e. only
when the two ordinates coincide. The second is the true threshold: the peaks are resolved — the
midpoint is a valley, not a spurious peak — exactly when $u(1+u+u^2)\,w_2 < w_1$. Bounding
$1+u+u^2 < 3$ gives the usable **Rayleigh criterion**
$$3\, g_{2s}(t_1-t_2)\,\bigl(\tfrac14+t_1^2\bigr) \;\le\; \tfrac14+t_2^2 .$$
And it is never vacuous: since $g_{2s}(d) \to 0$ as $s \to 0$ for fixed $d \ne 0$, *any* two
distinct ordinates are resolved by all sufficiently narrow Gaussian windows. There is no
resolution floor — in stark contrast with the rectangular window, whose relative sidelobe height
is the width-independent constant $1/\pi$.

---

## A window that creates convergence

The final surprise is that a smooth window is not merely a better version of a sharp one. It can
make sense of data the sharp window cannot even parse.

The Gaussian's decay is quantitative and explicit: for every order $n$ and every $t$,
$$(t^2)^n\, g_s(t) \;\le\; \left(\frac{s^2}{\pi}\right)^{\!n} n! ,$$
which is the elementary inequality $y^n/n! \le e^y$ in disguise. Two features matter. The
constant is independent of $t$, so one may choose the order $n$ *after* seeing how fast the data
grow. And the same bound holds uniformly across the entire Heisenberg orbit: every Gabor atom
$\gamma_{s,a,b}$ satisfies $|t-a|^m\,|\gamma_{s,a,b}(t)| \le 1 + (s^2/\pi)^m m!$, with a constant
that does not depend on the phase-space point.

Now take an infinite family of ordinates growing only as fast as $t_k^2 \ge k+1$. The Gaussian
statistic $\sum_k g_s(t_k)/(\tfrac14+t_k^2)$ converges absolutely — the $n=2$ case of the bound
already makes the terms $O(1/k^2)$. But the *unwindowed* statistic on the threshold family
$t_k = \sqrt{k+1}$ is $\sum_k 1/(k+\tfrac54)$: the harmonic series, divergent. Numerically, with
$s=1$, the unwindowed partial sums crawl past $9.4$ by $k = 10^4$ and keep climbing like
$\log k$, while the Gaussian-windowed sum settles at about $0.0354$ and is constant to five
digits after $k = 3$.

No bounded-below window can do this. A rectangular window of infinite width certainly cannot: it
is the unwindowed sum. The Gaussian window is a *regulariser*, extending a statistic from finite
data to infinite families where the raw statistic does not exist at all.

---

## The moral

The rectangular window looks like the neutral choice — take everything, weight it equally, decide
nothing. But there is no neutral window. The sharp cutoff is a very particular choice with three
signatures: infinite spurious energy at a fixed relative amplitude $1/\pi$, a statistic that jumps
and can vanish while data are present, and a resolution floor that never improves.

The Gaussian is a different particular choice, and it is the right one, for a reason that is
ultimately algebraic rather than analytic. It is the fixed family of the Fourier transform, so
its transfer function is a single unimodal bump. It is nowhere zero, so it invents no false
nulls. It decays faster than any polynomial with explicit constants, so it regularises. And —
the point that makes all the rest usable — it sits inside a representation of the Heisenberg
group that permutes its translates and modulates exactly, so every one of these properties holds
uniformly as the window is slid and tuned across phase space.

The lesson generalises past this one setting. When you choose a window, you are choosing a vector
in a representation space, and the group acting on it does not care whether you noticed. The only
question is whether your vector is a good one. The Gaussian is.
