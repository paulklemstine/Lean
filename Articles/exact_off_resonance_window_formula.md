# The Shape of a Note: How Long You Listen Decides What You Can Hear

## A question with a surprisingly exact answer

Suppose you want to know whether a signal contains a pure tone at some particular frequency. The natural thing to do is to listen for a while — say, from time $-T$ to time $+T$ — and correlate what you hear against your candidate frequency. In mathematical dress, you compute the integral

$$W(T,\omega) \;=\; \int_{-T}^{T} e^{i\omega t}\,dt ,$$

where $\omega$ is the **detuning**: the gap between the frequency you are testing and the frequency actually present. If $\omega = 0$ you are exactly on the note; if $\omega \neq 0$ you are slightly off.

Everyone's first instinct is right. When $\omega = 0$ the integrand is the constant $1$, everything adds up in phase, and you get the full window length,

$$W(T,0) = 2T .$$

When $\omega \neq 0$, the phase $e^{i\omega t}$ spins as $t$ advances, contributions cancel, and the answer is smaller. That much is folklore. The interesting question — the one that decides whether a real instrument can do a real job — is *how much smaller, exactly*.

The answer is not an estimate. It is an identity:

$$\boxed{\;W(T,\omega) \;=\; \frac{2\sin(\omega T)}{\omega}\quad(\omega\neq 0),\qquad W(T,0)=2T.\;}$$

These two lines are really one line. Introduce the *cardinal sine*

$$\operatorname{sinc}(x) \;=\; \frac{\sin x}{x}\ \ (x\neq 0),\qquad \operatorname{sinc}(0)=1,$$

and the whole story collapses into

$$W(T,\omega) \;=\; 2T\,\operatorname{sinc}(\omega T).$$

The resonance case is not a special case at all; it is the value of a continuous function at a point where the naive formula happens to be $0/0$. Everything else in this article is squeezed out of that single identity.

## Reading the curve

Picture $\operatorname{sinc}$: a tall central hump of height $1$ at the origin, flanked by ripples that alternate in sign and shrink slowly. Multiply the horizontal axis by $1/T$ and the vertical axis by $2T$, and you have the response of a listener who listens for time $2T$.

Four features of that picture turn out to be theorems, and each of them is quantitative.

**The peak really is the peak.** For every detuning $\omega$,
$$|W(T,\omega)| \;\le\; 2T .$$
So no off-resonance frequency ever beats the resonant one. Doubling your listening time doubles the peak. This follows immediately from the sinc law together with the elementary fact that $|\sin x| \le |x|$, which says exactly that $|\operatorname{sinc}| \le 1$.

**The ripples die like $1/\omega$, and not one bit faster.** For $\omega \neq 0$,
$$|W(T,\omega)| \;\le\; \frac{2}{|\omega|}.$$
Notice what is *not* in that bound: the window length $T$. However long you listen, a distant frequency still leaks in at strength $2/|\omega|$. This is the mathematical origin of *spectral leakage*, the bane of every spectrum analyser, and the reason engineers taper their windows instead of chopping them square.

And this envelope is not a lazy overestimate. At the half-integer detunings
$$\omega \;=\; \frac{(2k+1)\pi}{2T}, \qquad k \in \mathbb{Z},$$
— exactly midway between consecutive zeros, that is, at the crest of each ripple — the bound is met with *equality*:
$$\bigl|W(T,\omega)\bigr| \;=\; \frac{2}{|\omega|}.$$
The curve $2/|\omega|$ is not a ceiling the sidelobes approach; it is a curve they touch, once inside every single lobe, forever.

**The zeros are known exactly.** For $\omega \neq 0$ and $T>0$,
$$W(T,\omega) = 0 \iff \omega = \frac{k\pi}{T} \ \text{ for some nonzero integer } k .$$
Moreover, throughout the whole open range $0 < \omega T < \pi$ the response is strictly positive. So $\pi/T$ is genuinely the *first* zero, with nothing hiding in between — a claim that a bound alone can never make, and which requires the exact formula.

**The main lobe has a measurable width.** Two complementary statements pin it down. Downwards, for $|\omega T| \le 1$,
$$|W(T,\omega)| \;\ge\; 2T\Bigl(1 - \tfrac{(\omega T)^2}{4}\Bigr),$$
so the response is still within a few percent of its peak while $\omega T$ is small; this comes from the elementary refinement $\sin x > x - x^3/4$ for $0 < x \le 1$. Upwards, if the response retains at least half of its peak amplitude, $|W(T,\omega)| \ge T$, then necessarily
$$|\omega| \;\le\; \frac{2}{T}.$$

That last inequality is the uncertainty principle in its most pedestrian and most usable form. **Frequency resolution is inversely proportional to observation time.** If you want to distinguish two frequencies a hertz apart, you must listen for on the order of a second. There is no cleverness that escapes it, because it is a consequence of an identity, not of a technique.

## The same shape, in arithmetic

Now change subject entirely. Instead of listening continuously, sample once per unit of time and add up what you get. That is the **exponential sum**

$$S_N(\alpha) \;=\; \sum_{n=0}^{N-1} e^{2\pi i n \alpha},$$

the object at the heart of analytic number theory — the tool with which one shows that $\sqrt{2}, \sqrt{3}, \sqrt{5}, \dots$ have uniformly distributed fractional parts, that primes are equidistributed in arithmetic progressions, and much else. It is a geometric series, so it can be summed, and the modulus is

$$|S_N(\alpha)| \;=\; \frac{|\sin(\pi N \alpha)|}{|\sin(\pi \alpha)|} \qquad (\alpha \notin \mathbb{Z}),$$

with $S_N(\alpha) = N$ whenever $\alpha$ is an integer. This is the *Dirichlet kernel*, and it is the discrete twin of the sinc law: the numerator $\sin(\pi N \alpha)$ plays the role of $\sin(\omega T)$, and the denominator $\sin(\pi\alpha)$ plays the role of $\omega$ — the same thing, wrapped around a circle.

Everything from the continuous story reappears, subtly deformed by the wrapping.

*Sidelobes.* Since $|\sin(\pi N\alpha)| \le 1$, we get $|S_N(\alpha)| \le 1/|\sin(\pi\alpha)|$, and using Jordan's inequality $|\sin(\pi\alpha)| \ge 2\|\alpha\|$ (where $\|\alpha\|$ denotes the distance from $\alpha$ to the nearest integer) this sharpens to the classical bound of analytic number theory,
$$|S_N(\alpha)| \;\le\; \frac{1}{2\|\alpha\|}.$$
The window length has vanished from the right-hand side, exactly as in the continuous case.

*Cancellation.* For a fixed non-integer $\alpha$, the numerator is bounded while the denominator is a fixed nonzero constant, so $|S_N(\alpha)|/N \to 0$. Applied to every nonzero harmonic $h\alpha$ of an irrational $\alpha$, this is precisely the input Weyl's criterion needs to conclude that the sequence $n\alpha$ is equidistributed modulo $1$. A statement about how sound behaves in a finite window becomes a statement about how irrational rotations fill a circle.

*Main lobe.* Throughout $|\alpha| \le 1/(2N)$ — the discrete main lobe — the sum retains a definite fraction of its peak:
$$|S_N(\alpha)| \;\ge\; \frac{2}{\pi}\,N \;\approx\; 0.6366\,N .$$
And $2/\pi$ is not a convenient round-down. At the very edge $\alpha = 1/(2N)$ the sum equals $1/\sin\bigl(\pi/(2N)\bigr)$ exactly, and dividing by $N$ and letting $N \to \infty$ gives
$$\frac{|S_N(1/(2N))|}{N} \;\longrightarrow\; \frac{2}{\pi}.$$
The constant is attained in the limit, so no larger one is available.

## The bridge

Continuous and discrete are not merely analogous. They are related by an exact factorization. Write the continuous window over $[0,b]$ at frequency $\alpha$ (measured in cycles per unit time) as $C_b(\alpha) = \int_0^b e^{2\pi i \alpha s}\,ds$. Then for every whole number of samples $N$,

$$C_N(\alpha) \;=\; S_N(\alpha)\cdot C_1(\alpha).$$

The continuous integral over $[0,N]$ is *exactly* the exponential sum multiplied by the integral over one single sampling cell. Nothing is approximated. The proof is a one-line telescoping: the integral over the cell $[c, c+1]$ equals $e^{2\pi i\alpha c}$ times the integral over $[0,1]$, and summing over $c = 0, 1, \dots, N-1$ pulls the phases out into the exponential sum.

This is the classical statement that a sampled measurement is a Dirichlet kernel times a sinc: the sum supplies the sharp comb of resonances, and the single cell supplies the slowly decaying envelope that modulates them. And because a rectangular window's *modulus* does not care where you put the origin, the $[0,b]$ window and the symmetric $[-b/2, b/2]$ window agree:
$$|C_b(\alpha)| \;=\; \bigl|W(b/2,\ 2\pi\alpha)\bigr| .$$
One theorem, two coordinate systems.

## When are two notes two notes?

Here is where the exact formula earns its keep. Put two equal tones into the signal, separated by $\Delta$, and sweep the analyser across them. The response is the sum of two shifted sinc curves,

$$R(\omega) \;=\; 2T\Bigl[\operatorname{sinc}\bigl((\omega - \tfrac{\Delta}{2})T\bigr) + \operatorname{sinc}\bigl((\omega + \tfrac{\Delta}{2})T\bigr)\Bigr].$$

If $\Delta$ is tiny, the two humps merge into one broad blob and you see a single note. If $\Delta$ is large, you see two peaks with a valley between them. Somewhere in between is a threshold — this is the classical **Rayleigh criterion**, familiar from optics, where it decides whether a telescope shows one star or two.

Optics textbooks usually quote the Rayleigh criterion as a rule of thumb. Here it can be computed exactly. Evaluate the response at a tone centre, $\omega = \Delta/2$, and at the midpoint, $\omega = 0$:

$$R(\Delta/2) = \frac{2\Delta T + 2\sin(\Delta T)}{\Delta},\qquad R(0) = \frac{8\sin(\Delta T/2)}{\Delta}.$$

The tones are *resolved* — a genuine dip between them — precisely when $R(0) < R(\Delta/2)$. Writing $x = \Delta T/2$ and cancelling, this is the transcendental inequality

$$\sin x\,(2 - \cos x) \;<\; x .$$

Define the gap function $G(x) = \sin x\,(2-\cos x) - x$. Its derivative is remarkably clean:

$$G'(x) \;=\; 2\cos x\,(1 - \cos x).$$

Since $1 - \cos x \ge 0$ always, the sign of $G'$ is simply the sign of $\cos x$. So $G$ increases strictly on $[0, \pi/2]$ and decreases strictly on $[\pi/2, \pi]$: it rises from $G(0)=0$ to a positive maximum at $\pi/2$, then falls to $G(\pi) = -\pi$. By the intermediate value theorem it crosses zero exactly once, at some $x_c$, and numerical bracketing pins that crossing into $2.1 \le x_c < 2.2$.

Beyond $\pi$ the reversal persists, and combining the pieces yields a clean dichotomy: **there is a single critical scale $x_c$ with $G > 0$ strictly below it, $G(x_c)=0$, and $G < 0$ strictly above.** Translated back into the language of the experiment, there is an exact critical time–bandwidth product

$$c = 2x_c \in [4.2,\ 4.4), \qquad c \approx 4.27836\ldots,$$

such that: if $\Delta T < c$, the midpoint between the two tones is **strictly brighter** than either tone centre — the pair is genuinely unresolved, a single blob; and if $\Delta T > c$, the midpoint is **strictly darker** — two distinguishable peaks. Not "roughly", not "by convention": strictly, for every window length and every separation.

Two familiar landmarks sit on the resolved side of this threshold. At $\Delta = 2\pi/T$, that is $\Delta T = 2\pi \approx 6.283$, each tone falls exactly on the other's first zero: the response at the midpoint is *exactly zero*, and at each tone centre it is exactly $2T$, the full unattenuated peak. Perfect resolution, with a perfect null between. The critical threshold $4.278$ sits comfortably below it — the tones become resolvable well before they become perfectly separated.

## The energy picture

There is one more identity worth recording, because it re-expresses everything in terms of *energy* rather than amplitude. Expanding $|S_N(\alpha)|^2$ by multiplying the sum by its conjugate and collecting terms by index difference $d = |m - n|$ gives Fejér's triangular identity:

$$|S_N(\alpha)|^2 \;=\; 2\sum_{d=0}^{N-1} (N-d)\cos(2\pi d\alpha) \;-\; N .$$

The right-hand side is a cosine polynomial with *triangular* weights $N-d$ — high weight for nearby samples, tapering to zero at lag $N$. Because it is a squared modulus it is automatically nonnegative, which is a non-obvious fact about that polynomial taken on its own. It has total mass exactly $N$ over one period, and away from the integers it is uniformly small: whenever $\|\alpha\| \ge \delta$,

$$|S_N(\alpha)|^2 \;\le\; \frac{1}{4\delta^2},$$

*independently of $N$*. Mass $N$, concentrated in a neighbourhood of the integers of width about $1/N$, and bounded by a constant everywhere else: this is the definition of an approximate identity, the analytic engine behind Fejér's theorem on the convergence of Cesàro means of Fourier series. And through the sampling bridge, the same triangular identity transports verbatim to the continuous window:
$$|C_N(\alpha)|^2 \;=\; \Bigl(2\sum_{d<N}(N-d)\cos(2\pi d\alpha) - N\Bigr)\,|C_1(\alpha)|^2 .$$

## Why an exact formula matters

It is tempting to think that "the response peaks at zero detuning" is the content, and the exact formula is bookkeeping. The opposite is true. The peak statement alone cannot tell you:

- how wide the peak is (half-amplitude within $|\omega| \le 2/T$);
- where the first zero is (at $\omega = \pi/T$, with nothing before it);
- how badly a distant tone contaminates your measurement ($2/|\omega|$, sharply, touched in every lobe);
- whether two nearby tones can be told apart (exactly when $\Delta T > 4.278\ldots$);
- how the whole picture survives sampling (exactly, via the Dirichlet-times-sinc factorization).

Every one of these is an engineering decision, a telescope specification, or a number-theoretic lemma. All of them are corollaries of one identity that anyone can verify in an afternoon:

$$\int_{-T}^{T} e^{i\omega t}\,dt \;=\; 2T\operatorname{sinc}(\omega T).$$

The remarkable thing is not that the formula is true. It is that the same function — that tall hump with the slowly dying ripples — governs the resolution of a radio telescope, the leakage in a digital spectrum analyser, the distribution of $\{n\sqrt{2}\}$ around the circle, and the convergence of Fourier series. Finite observation has a shape, and it is always the same shape.
