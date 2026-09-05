# The Sound of Primes, and the Silence That Followed

## How Gauss sums explain why a beautiful feature idea had to fail

There is a particular kind of disappointment familiar to anyone who has tried to
predict something hard. You have a model. It works, sort of — it explains, say,
sixty percent of the variation in the thing you care about. The remaining forty
percent nags at you. Then one night an idea arrives with the unmistakable glow of
rightness: *the leftover structure must be arithmetic*. The objects you are
studying sit at positions $r$ that are integers; integers have residues modulo
small primes; residues have **phases**. Write down, for each small prime $p$ and
each position $r$, the pair

$$\cos\!\left(\frac{2\pi k r}{p}\right), \qquad \sin\!\left(\frac{2\pi k r}{p}\right),$$

throw in the classical indicator of whether $r$ is a perfect square modulo $p$ —
the Legendre symbol $\left(\tfrac{r}{p}\right)$, equal to $+1$ for squares, $-1$
for non-squares, $0$ for $r \equiv 0$ — and let a linear model loose on the
result. Do it for $p = 3, 5, 7, 11, 13$, then push all the way to $29$. Twenty-seven
new numbers describing each object, every one of them a genuine arithmetic
invariant.

The experiment was run. The answer was: **nothing**.

Adding the phase block to a baseline that scored $R^2 = 0.600$ moved the
out-of-sample score to $0.608$. Extending to the larger prime range moved it to
$0.604$. Both confidence intervals comfortably straddle zero. A model built from
the phases *alone* scored $-0.077$ — worse than a constant predictor, which is
what a negative $R^2$ means. The pre-registered bar for the hypothesis being
tested was $R^2 \geq 0.70$. It was not close.

This article is about what happened next, which is more interesting than the
failure itself. Instead of shrugging and trying the next feature family, we asked
a sharper question: **was that outcome forced?** Not "did it happen to fail" but
"could it possibly have succeeded, for any data whatsoever with the measured
correlation structure?" The answer turns out to be no — and the proof is not
statistics. It is Gauss sums.

---

## Part I: A ceiling you can compute before you fit

Start with the simplest possible piece of linear algebra, the one every
regression rests on. You have a residual vector $e$ — what your baseline failed
to explain — living in $\mathbb{R}^n$, one coordinate per sample point. You have
a candidate feature $f$, also a vector in $\mathbb{R}^n$. Fitting $f$ to $e$ by
least squares removes exactly

$$\mathrm{gain}(e, f) \;=\; \frac{\langle e, f\rangle^2}{\|f\|^2}$$

units of residual energy, where $\langle x, y\rangle = \sum_i x_i y_i$ and
$\|x\|^2 = \langle x, x\rangle$. That is an identity, not an estimate: subtracting
the optimal multiple $\hat\beta f$ with $\hat\beta = \langle e,f\rangle/\|f\|^2$
leaves residual energy exactly $\|e\|^2 - \mathrm{gain}(e,f)$.

Now the crucial move. Suppose you have $K$ features, not one, and suppose you
have measured two things about them.

**First**, how well each one *individually* correlates with the residual. Call the
worst case $\varepsilon$: for each feature $f_k$,

$$\langle e, f_k\rangle^2 \;\leq\; \varepsilon^2 \, \|e\|^2 \, \|f_k\|^2 .$$

In the experiment, $\varepsilon$ was about one percent.

**Second**, how much the features overlap each other. Write $\delta$ for the
largest correlation between two distinct features:
$|\langle f_k, f_l\rangle| \leq \delta \|f_k\| \|f_l\|$ for $k \neq l$.

The temptation, when individual features are weak, is to hope that *combinations*
of them are strong. Twenty-seven weak signals, pointed in cleverly chosen
directions, surely add up to something? The following theorem says: only if they
overlap heavily. And they do not.

> **The Sub-Threshold Lift Ceiling.** Let $f_1, \dots, f_K$ be features whose
> pairwise correlations are at most $\delta$, with $\delta(K-1) < 1$, and whose
> individual correlations with the residual $e$ are at most $\varepsilon$. Then
> *every* linear combination $g = \sum_k a_k f_k$, with any coefficients
> whatsoever, satisfies
> $$\mathrm{gain}(e, g) \;\leq\; \frac{K \varepsilon^2}{1 - \delta(K-1)} \, \|e\|^2 .$$

The proof is two applications of Cauchy–Schwarz stacked in opposite directions.
Upstairs, $\langle e, \sum_k a_k f_k\rangle^2 \leq \left(\sum_k a_k^2\|f_k\|^2\right)\cdot K\varepsilon^2\|e\|^2$:
the combination's alignment with the residual cannot exceed the sum of the parts.
Downstairs, near-diagonality of the overlap matrix forces
$\|\sum_k a_k f_k\|^2 \geq (1 - \delta(K-1)) \sum_k a_k^2 \|f_k\|^2$ — the
combination cannot be *short*, cannot cancel itself into a tiny vector that then
gets amplified by division. Divide, and the coefficients disappear entirely. What
remains is a bound depending only on $K$, $\varepsilon$, and $\delta$.

This is a bound you can compute *before* fitting anything. It says: with $K$
features at one percent correlation each and modest overlap, the very best
achievable improvement is around $K \varepsilon^2$ of the residual energy — a
few parts in a thousand. There is no clever fit hiding in the corner of parameter
space. The corner is empty, provably.

There is one more structural gift. When the feature set splits into groups that
are *mutually orthogonal* — and the phase features for distinct primes $p$ and
$q$ are exactly orthogonal, by the Chinese Remainder Theorem: a $p$-periodic
function and a $q$-periodic function of mean zero are uncorrelated over a full
period modulo $pq$ — the total lift is at most the **sum** of the per-group
lifts. Nine primes, nine independent budgets, added.

So everything hinges on one number per prime: how much do the three features
$\cos_k$, $\sin_k$, and the Legendre symbol overlap *each other*, inside a single
prime block?

---

## Part II: Where Gauss walks in

Here the statistics ends and the number theory begins.

Two of the three overlaps are zero, and beautifully so. Over a full period
modulo $N$, the trigonometric features are an exactly orthogonal system:

$$\langle \cos_k, \cos_l \rangle = \begin{cases} N/2 & k = \pm l \neq 0\\ 0 & \text{otherwise},\end{cases} \qquad \langle \cos_k, \sin_l\rangle = 0 \ \ \text{for all } k, l.$$

This is the discrete orthogonality of characters, the finite Fourier transform in
its most classical dress: writing $\psi(x) = e^{2\pi i x/N}$, the whole family of
identities follows from the single fact that $\sum_{r} \psi(tr)$ equals $N$ when
$t = 0$ and $0$ otherwise. Cosines and sines never see each other; different
frequencies never see each other. The Fourier half of the design has
$\delta = 0$ exactly.

That leaves the coupling between the Legendre symbol and the phases. And that
coupling is a **Gauss sum** — arguably the most famous object in elementary
analytic number theory, the sum

$$g_k \;=\; \sum_{r \bmod p} \left(\frac{r}{p}\right) e^{2\pi i k r/p} .$$

Its real part is precisely $\langle \mathrm{QR}, \cos_k\rangle$; its imaginary
part is precisely $\langle \mathrm{QR}, \sin_k\rangle$. And Gauss proved, in one
of the results he returned to obsessively across his life, that
$|g_k|^2 = p$ for every $k \not\equiv 0$.

That single classical fact does all the work. Since the Legendre symbol has
energy $\|\mathrm{QR}\|^2 = p - 1$ (it is $\pm 1$ everywhere except at $0$) and
each phase has energy $p/2$, the *normalised* correlation between the Legendre
symbol and any nonzero-frequency phase is at most

$$\delta_p \;=\; \sqrt{\frac{2}{p-1}} .$$

Read that formula slowly, because it is the heart of the matter. It says the
arithmetic features are near-orthogonal **for arithmetic reasons**, and that they
become *more* orthogonal as the prime grows: $\delta_{13} = 0.408$,
$\delta_{29} = 0.267$, and $\delta_p \to 0$. The design cannot conspire with
itself. Bigger primes do not help; they help less.

### The Gauss-sign dichotomy

Then comes a refinement that first showed up as a suspicious pattern in the
numbers and turned out to be a theorem. Gauss's deeper result about $g_k$ is not
just its modulus but its *direction*: the Gauss sum is real when $p \equiv 1
\pmod 4$ and purely imaginary when $p \equiv 3 \pmod 4$. Translated into feature
language:

> **The Gauss-Sign Dichotomy.** If $p \equiv 3 \pmod 4$, then
> $\langle \mathrm{QR}, \cos_k\rangle = 0$ exactly, and all the coupling lives in
> the sine channel. If $p \equiv 1 \pmod 4$, then
> $\langle \mathrm{QR}, \sin_k\rangle = 0$ exactly, and all the coupling lives in
> the cosine channel. In the active channel the bound is *attained*:
> the coupling equals $\sqrt{p}$ on the nose.

So each three-feature prime block has not two coupled pairs but exactly **one**.
Half of the phase design is exactly perpendicular to the Legendre symbol, and
which half is decided by a residue class modulo $4$. This is not a cosmetic
improvement. A single coupled pair means the near-diagonality constant is
$1 - \delta_p$ rather than the pessimistic $1 - 2\delta_p$ — the difference
between $0.59$ and $0.18$ at $p = 13$, a factor of more than three in the
ceiling. And because the bound is attained, $1 - \delta_p$ is not merely
sufficient: it is the *exact* smallest stretch factor of the block. No sharper
constant exists. The argument has been pushed to its floor.

### The verdict

Assemble the pieces. Nine prime blocks, mutually orthogonal by the Chinese
Remainder Theorem. Three features each. Per-feature residual correlation
$\varepsilon = 0.01$, as measured. Worst-case block constant $1 - \delta_5 =
0.292$. The ceiling on the total lift is

$$9 \times \frac{3 \times (0.01)^2}{0.292} \;\approx\; 0.0093 ,$$

barely one percent of the residual energy. Since the residual energy is
$1 - 0.600 = 0.400$ of the total, the best conceivable phase-augmented score is

$$0.600 + 0.01 \times 0.400 \;=\; 0.604 \;<\; 0.70 .$$

The registered hypothesis was **unreachable before the first coefficient was
fitted**. The measured $+0.008$ was not a disappointing draw from a distribution
that might have gone better; it was, within noise, the whole of what the
arithmetic permits. Restricting to primes $p \geq 13$, where the block constant
is $0.59$ or better, tightens the ceiling to $0.005$ and the best score to
$0.602$.

---

## Part III: The degeneracy at the end of the road

One might still hope to rescue the idea by throwing in *more* frequencies. Use
not one phase per prime but all of them. Here the mathematics delivers a final,
elegant refusal.

Over a half-period of frequencies $k = 1, \dots, (p-1)/2$ — a maximal set on
which the phase features are pairwise orthogonal — each frequency's cosine and
sine channels *together* explain exactly $2$ units of the Legendre symbol's
energy. This is immediate from $|g_k|^2 = p$ and $\|\cos_k\|^2 = \|\sin_k\|^2 =
p/2$: the two projections contribute $(\mathrm{Re}\,g_k)^2/(p/2) +
(\mathrm{Im}\,g_k)^2/(p/2) = 2|g_k|^2/p = 2$. Multiply by the $(p-1)/2$
frequencies and you get exactly $p - 1$, which is exactly $\|\mathrm{QR}\|^2$.
Zero residual. A Bessel *equality*.

> **The Full-Frequency Degeneracy.** Over a full half-period of frequencies, the
> Legendre symbol is *exactly* a linear combination of the phase features.
> Consequently, appending it to a full-frequency phase design cannot change any
> fitted value, any residual, or any $R^2$: it contributes no capacity at all.

The quadratic-residue indicator, that emblem of deep arithmetic, dissolves into
sines and cosines the moment you give the design enough frequencies. Its apparent
independence — the entire discussion of the coupling constant $\delta_p$ — is an
artefact of using one frequency per prime. Richer is not better here; richer is
*degenerate*.

---

## Part IV: The thing that did go wrong, and where to look now

The phase experiment also produced one strongly positive finding, and it points
somewhere else entirely.

Recall the phase-only model's score of $-0.077$. A least-squares fit *cannot*
score negative on the data it was fitted to; a negative score is only possible
when a coefficient learned in one window is transported to another. Write $\beta$
for the transported coefficient and $\beta^\star$ for the test window's own
optimum. Then the out-of-sample gain is an exact downward parabola:

$$\mathrm{gain}_{\text{oos}}(\beta) \;=\; \|f\|^2\left((\beta^\star)^2 - (\beta - \beta^\star)^2\right).$$

Every conclusion follows from staring at this. The gain is negative precisely
when $|\beta - \beta^\star| > |\beta^\star|$: the transported coefficient misses
the target window's optimum *by more than the optimum's own size*. Rescaling
cannot help; the in-window fit is the maximum of the parabola. And a measured
relative gain of $-\rho$ certifies a standardized coefficient miss of at least
$\sqrt{\rho}$. So $-0.077$ certifies a miss of at least $0.277$; the baseline
model's own degradation from $0.600$ in-window to $0.400$ across windows
certifies a miss of at least $0.447$. **The baseline is more window-local than
the phases are.** Whatever these models are learning, a good part of it does not
survive the trip to a different window.

That reframes the original puzzle — an unexplained excess in an earlier
ceiling-splitting analysis — and leaves exactly two suspects, which the theory
separates cleanly.

**Suspect 1: still-higher primes.** Each new prime is an orthogonal block with
its own capped budget. Covering an excess of $\Delta$ requires at least
$0.06\,\Delta/\varepsilon^2$ blocks; at $\Delta = 0.2$ and $\varepsilon = 0.01$,
that is **at least $120$ primes**. The design had nine. This suspect predicts a
slow additive crawl, never a step, and is expensive beyond plausibility.

**Suspect 2: same-window leakage** — a feature computed, in part, from the very
outcomes it is asked to predict. Model it as $f = \alpha e + g$ with
$g \perp e$. Then the in-window gain is exactly

$$\mathrm{gain}(e, f) \;=\; \frac{\alpha^2\|e\|^4}{\alpha^2\|e\|^2 + \|g\|^2},$$

so the in-window $R^2$ equals the leaked fraction of the feature's energy, and it
can be made *anything at all* — including $0.99$ — with an arbitrarily small
genuine signal. Meanwhile, if the leaked component is resampled on a fresh
window, the transported coefficient produces a strictly negative gain. Cheap,
matches the observed shape exactly, and — best of all — **falsifiable without
fitting anything**: any feature achieving in-window $R^2 \geq 0.6$ must correlate
with the *realized* target at level at least $\sqrt{0.6} > 0.774$. Go measure that
one correlation. It decides the case.

---

## Coda

There is a story mathematicians tell about negative results: that they close
doors. This one opened a corridor. A feature family failed, and rather than
leaving it as an anecdote about one dataset, the failure became a theorem with
Gauss's name inside it — a ceiling of $K\varepsilon^2/(1-\delta)$, an arithmetic
$\delta = \sqrt{2/(p-1)}$ that shrinks with the prime, a dichotomy modulo $4$
that halves the coupling, a Bessel equality that dissolves the Legendre symbol
into sines and cosines. The next person who reaches for phase features to explain
residual arithmetic structure now knows, in advance and to three decimal places,
exactly how much they can hope for.

Usually that is worth more than the hope.
