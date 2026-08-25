# The Ruler and the Rain: How to Tell One Spectrum From Another

## A question you cannot answer by looking

Here are the first few numbers in a list: $0, 1, 4, 9, 16, 25, 36, \dots$

Here is another list: $0.31, 1.02, 1.05, 3.77, 4.10, 8.62, \dots$

And a third, which I will not show you, comes from the eigenvalues of a large random matrix with complex entries.

Physicists have spent seventy years asking a deceptively simple question about lists like these. Given the energy levels of a quantum system — the atomic nucleus of erbium-166, an electron bouncing in a stadium-shaped billiard, a disordered wire, or the zeros of a certain function in number theory — can you tell *what kind of system it came from* just by looking at the pattern of the numbers?

The astonishing answer, discovered by Eugene Wigner, Freeman Dyson and Madan Lal Mehta, is yes. Not from the individual numbers, which depend on every irrelevant detail of the system, but from the *statistics of the gaps between them*. And the gap statistics fall into a small number of universality classes, each with its own fingerprint.

But there is a trap in the question, and it swallows more first attempts than any other error in the subject. This article is about that trap, about the correct way to escape it, and about a family of exact statements that pin down precisely what the escape buys you.

## The trap: spectra do not come with units

Suppose I hand you the list $0, 1, 4, 9, 16, \dots$ — the squares $\lambda_k = k^2$. The gaps are $1, 3, 5, 7, 9, \dots$, all the odd numbers. Are these gaps "random-looking"? Are they "rigid"?

The question is malformed as stated, because the gaps are not comparable to each other. Near the bottom of the list the levels are packed tightly; near the top they are spread far apart. Comparing the gap $1$ with the gap $99$ is like comparing a measurement in millimetres with a measurement in miles.

The standard repair is called **unfolding**. You divide each raw gap by the *local mean gap*, producing dimensionless numbers whose average is $1$ by construction. Concretely, for a level sequence $\lambda_0 < \lambda_1 < \lambda_2 < \dots$ define the raw gaps $g_i = \lambda_{i+1} - \lambda_i$, the mean gap over a window of $n$ levels
$$\bar{g}_n = \frac{\lambda_n - \lambda_0}{n},$$
and the normalized gaps $s_i = g_i / \bar{g}_n$. Two facts make this the right object. First, the normalized gaps of a window always sum to exactly $n$:
$$\sum_{i=0}^{n-1} s_i = n,$$
because the raw gaps telescope to $\lambda_n - \lambda_0$. The mean spacing is exactly one, always, by construction. Second, the normalized gaps are blind to any affine change of scale: if you replace every level $\lambda_k$ by $a\lambda_k + b$ with $a \neq 0$ — recalibrate your spectrometer, shift your zero of energy — every $s_i$ is unchanged. Raw spectra may never be compared. Only unfolded ones may.

## Why this matters: a spectacular false positive

Now watch what happens if you skip the unfolding step and just compute the empirical distribution of the normalized gaps of the *raw* squares $\lambda_k = k^2$ over the window of the first $n$ levels.

The $i$-th raw gap is $2i+1$, and the mean gap over the window is $n^2/n = n$. So the normalized gaps are
$$s_i = \frac{2i+1}{n}, \qquad i = 0, 1, \dots, n-1,$$
which is an arithmetic progression marching from about $0$ to about $2$ in steps of $2/n$. Its empirical distribution function is therefore within $1/(2n)$ of the **uniform law on $[0,2]$**, at every threshold $t \in [0,2]$, for every $n \geq 1$. Precisely: if $F_n(t)$ denotes the fraction of the first $n$ normalized gaps that are at most $t$, then
$$\left| F_n(t) - \frac{t}{2} \right| \leq \frac{1}{2n} \qquad \text{for all } 0 \le t \le 2.$$

A uniform distribution of spacings! It is a clean, beautiful, perfectly reproducible law — and it is completely meaningless as a statement about the spectrum. It says nothing about correlations between levels. It is an artefact of the fact that the density of states of $k^2$ diverges: the spread of gap sizes across the window is not a *fluctuation*, it is a *trend*. Any spectrum whose density of states varies across the window will produce such a spurious law, and different densities produce different spurious laws. This is the trap.

## What is actually there: a picket fence

Unfold properly and the squares reveal their true nature. The counting function of the spectrum $\lambda_k = k^2$ — the number of levels below $x$ — is $N(x) = \sqrt{x}$. Applying $N$ to the levels gives $N(\lambda_k) = \sqrt{k^2} = k$: the integers.

That is a **picket fence**. Every gap equals $1$. Every normalized gap equals $1$. The empirical spacing distribution is not uniform on $[0,2]$; it is a Dirac point mass at $1$: no gap is below $1$, and every gap is at most $1$. The empirical variance of the normalized gaps is exactly $0$.

This is an instance of a general principle. If $g$ is any function that inverts the level sequence, meaning $g(\lambda_k) = k$ for every $k$ — in other words, $g$ is the counting function of the spectrum — then the unfolded spectrum $g(\lambda_0), g(\lambda_1), \dots$ has *all* of its normalized gaps equal to $1$. Unfolding by the exact counting function always yields the picket fence. The content of real spectral statistics lies in unfolding by a *smoothed* counting function, so that the fine-grained fluctuations survive; the exact statement above is the boundary case that shows why unfolding is not optional and what it removes.

## The two universality classes

Against what should the unfolded picture be compared? Two densities on $(0,\infty)$ have become the reference points of the subject, and both are already normalized to mean spacing one.

**Poisson.** Uncorrelated levels — levels dropped independently, like raindrops on a line — have spacing density
$$p_{\text{Poisson}}(s) = e^{-s}.$$
It integrates to $1$, has mean $\int_0^\infty s\, e^{-s}\,ds = 1$ and second moment $\int_0^\infty s^2 e^{-s}\,ds = 2$, hence variance $1$. It is strictly decreasing: the most likely spacing is no spacing at all. Nothing prevents two raindrops from landing on top of each other. This is the statistics of integrable systems, of the harmonic oscillator perturbed generically, of the levels of an ideal gas.

**Unitary random matrices.** The eigenvalues of a large complex Hermitian random matrix repel. The classical approximation to their spacing law — the Wigner surmise for the Gaussian Unitary Ensemble — is
$$p_{\text{GUE}}(s) = \frac{32}{\pi^2}\, s^2 \, e^{-\frac{4}{\pi}s^2}.$$
Establishing that this is a probability density with mean one is a genuine computation, and it reduces to two Gaussian moment integrals which can be evaluated in closed form by exhibiting explicit antiderivatives and taking limits at infinity:
$$\int_0^\infty x^2 e^{-bx^2}\,dx = \frac{\sqrt{\pi/b}}{4b}, \qquad \int_0^\infty x^3 e^{-bx^2}\,dx = \frac{1}{2b^2}, \qquad \int_0^\infty x^4 e^{-bx^2}\,dx = \frac{3\sqrt{\pi/b}}{8b^2}.$$
With $b = 4/\pi$ these give $\int_0^\infty p_{\text{GUE}} = 1$, $\int_0^\infty s\,p_{\text{GUE}}(s)\,ds = 1$, and the second moment $\int_0^\infty s^2 p_{\text{GUE}}(s)\,ds = 3\pi/8 \approx 1.178$, so the variance is $3\pi/8 - 1 \approx 0.178$.

The $s^2$ prefactor is the whole story: it is **quadratic level repulsion**. Two eigenvalues almost never coincide, and the probability of a spacing of size $s$ vanishes like $s^2$ as $s \to 0$. Quantitatively, on the whole interval $0 < s \leq 1/4$ the unitary density lies strictly below the Poisson density: small spacings are suppressed.

The repulsion also creates something the Poisson law does not have: an **interior mode**. The Wigner surmise attains its maximum at
$$s^\star = \frac{\sqrt{\pi}}{2} \approx 0.886, \qquad p_{\text{GUE}}(s^\star) = \frac{8}{\pi e} \approx 0.9366,$$
and is strictly below that value at every other positive spacing. The proof is a one-line reduction: writing $u = (4/\pi)s^2$, the density is $(8/\pi)\, u e^{-u}$, and $u e^{-u} < e^{-1}$ for every $u \neq 1$. So the unitary class has a characteristic spacing — a preferred distance between neighbouring levels — while the Poisson class, strictly decreasing everywhere, has none. This is a scale-free, normalization-free distinction between the two classes.

Are the classes genuinely different, or is one a rescaling of the other in disguise? Genuinely different: for every $c > 0$ the rescaled density $s \mapsto c\, p_{\text{GUE}}(cs)$ differs from $e^{-s}$ at some point. No change of units converts repulsion into independence.

So the variance of the spacing orders the three regimes cleanly:
$$\underbrace{0}_{\text{rigid}} \; < \; \underbrace{\tfrac{3\pi}{8} - 1 \approx 0.178}_{\text{unitary}} \; < \; \underbrace{1}_{\text{Poisson}}.$$

## The squares belong to neither class

With the correct comparison in place, the deterministic quadratic spectrum turns out to sit outside both universality classes — and one can say by how much.

Both reference laws assign positive probability to arbitrarily small spacings; repulsion suppresses small gaps but does not forbid them. The unfolded quadratic spectrum has *no* spacing below $1$. Turning this into a number: at the single threshold $t = 1/2$, the Poisson law assigns probability $1 - e^{-1/2} \geq 1/3$ to a spacing below $1/2$, and the unitary law assigns at least $\frac{4}{3\pi^2}e^{-1/\pi} \geq 1/12$, while the empirical law of the picket fence assigns $0$. Hence, for *every* window size $n$, the Kolmogorov–Smirnov distance from the picket fence to the Poisson law is at least $1/3$, and to the unitary law at least $1/12$. The separation does not wash out as the window grows.

The same message appears in the two-level correlations, and there one can compute everything exactly. Counting ordered pairs of distinct levels among the first $n$ of the picket fence at distance at most $t$ gives
$$R_2(n,t) = 2\sum_{d=1}^{\lfloor t \rfloor} (n - d) = 2\lfloor t\rfloor\, n - \lfloor t\rfloor(\lfloor t\rfloor + 1) \quad \text{whenever } \lfloor t \rfloor \le n,$$
so that after normalizing by the window size,
$$\frac{R_2(n,t)}{n} \longrightarrow 2\lfloor t \rfloor \qquad (n \to \infty).$$
The limit is a **staircase**: flat between consecutive integers, jumping by $2$ at each integer. Poisson has the continuous density $2t$; the unitary class has a continuous density too. Nothing continuous can approximate a staircase uniformly. The deterministic spectrum is not described by either class at any scale.

Finally, rigidity. Count the picket-fence levels inside a window $[a, a+L)$. The count is $\lceil a + L\rceil - \lceil a \rceil$, and it differs from the expected value $L$ by strictly less than $1$, uniformly in the position $a$ of the window. The number variance is bounded by $1$ forever. For a Poisson process the number variance in a window of length $L$ equals $L$ and diverges; for unitary statistics it grows like $\frac{1}{\pi^2}\log L$. Bounded, logarithmic, linear: three regimes, three growth rates. The same bound holds verbatim for any arithmetic spectrum $\lambda_k = d\,k$ with $d > 0$: the count in $[a, a+L)$ differs from $L/d$ by less than $1$. And no window of length at least $1$ is ever empty — whereas a Poisson process leaves a window of length $L$ empty with probability $e^{-L}$, which is never zero.

## Escaping the trap without unfolding at all

Unfolding is delicate. You must choose a window and a smoothing of the counting function, and different choices give different answers; a great deal of published disagreement in the physics literature has come from exactly this ambiguity. Is there a statistic that skips the choice entirely?

There is, and it is beautifully simple. Define the **consecutive gap ratio**
$$r_i = \frac{\min(g_i, g_{i+1})}{\max(g_i, g_{i+1})},$$
built from *raw* gaps only. Because both numerator and denominator scale the same way, $r_i$ is invariant under every affine change of scale $\lambda_k \mapsto a\lambda_k + b$ with $a > 0$ — with no window, no mean spacing, no unfolding of any kind. It lies in $[0,1]$ whenever the gaps are positive, and it equals $1$ exactly when two consecutive gaps agree, the signature of local rigidity.

Apply it to the *raw* squares, where the normalized-gap distribution told us the lie about uniformity. The gaps are $2i+1$ and $2i+3$, so
$$r_i = \frac{2i+1}{2i+3}, \qquad 1 - r_i = \frac{2}{2i+3}, \qquad r_i \to 1.$$
Every value is strictly below $1$ — rigidity is approached but never attained in the raw spectrum — and the deviation from the rigid value decays like $1/i$ at an exactly known rate. After unfolding, $r_i = 1$ on the nose.

So the gap ratio sees, in the raw data, precisely what the raw normalized-gap distribution hid: the squares are a rigid spectrum wearing a diverging density of states as a disguise. This is why the ratio statistic, introduced by Oganesyan and Huse in the study of many-body localization, has become a workhorse of numerical condensed-matter physics. Its universality constants — approximately $2\ln 2 - 1 \approx 0.386$ for Poisson and about $0.60$ for unitary statistics — are honest, unfolding-free numbers you can compute from a spectrum straight out of a diagonalization routine.

## What the story teaches

Three lessons, in ascending order of generality.

The first is technical: never compare raw spectra. A spacing law computed without unfolding is a measurement of the density of states, not of the correlations, and it can be arbitrarily beautiful and entirely spurious. The uniform law on $[0,2]$ found in the squares is the cleanest possible illustration.

The second is structural: rigid, unitary and Poisson statistics differ in *every* observable, and the differences can be quantified. Spacing variance $0 < 3\pi/8 - 1 < 1$. Number variance bounded, logarithmic, linear. Two-level density staircase, sine-kernel, linear. Presence or absence of an interior mode at $\sqrt\pi/2$. These are not different pictures of the same thing; they are separated by explicit constants that survive taking the window to infinity.

The third is methodological, and the most useful in practice: when a statistic depends on a normalization convention, look for one that does not. The gap ratio is the model. It is a quotient of two quantities that transform identically, so the transformation cancels — the same trick that makes cross-ratios useful in projective geometry and dimensionless groups useful in fluid dynamics. Where you can build your observable to be blind to the arbitrary choices, you will never have to argue about them.

And the squares? A perfect picket fence, hiding in plain sight behind a divergent density of states, and giving itself away the moment you take a ratio.
