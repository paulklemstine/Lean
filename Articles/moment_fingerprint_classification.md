# The Fingerprint of a Spectrum

## How a single number tells you what kind of universe your energy levels came from

Take a list of numbers. Not just any list — a list of *levels*: the resonance
energies of a heavy nucleus, the eigenvalues of a random matrix, the imaginary
parts of the zeros of the Riemann zeta function, the frequencies at which a
metal plate rings, the arrival times of buses on an unloved city route.

Sort them. Look at the gaps.

That's it. That's the whole experiment. And yet from the statistics of those
gaps you can read off something startlingly deep about the system that produced
them: whether it is rigid and crystalline, whether it is chaotic but subject to
a hidden repulsion between its levels, or whether it is pure structureless
randomness. Physicists have known this since the 1950s. What has been missing
is a clean, complete, *provable* answer to the practical question that
immediately follows:

> Given a finite list of gaps, how do you decide which regime you're in — and
> how many gaps do you need before the answer is guaranteed correct?

This article is about a surprisingly tidy resolution. The short version: **one
number suffices**. Compute the average of the *squares* of your normalized
gaps. Compare it against a fixed ladder of five constants. There is a proved
minimum separation between adjacent rungs of that ladder — the number
$3\pi/128 \approx 0.0736$ — and once your sample is large enough that your
statistical error falls below half of that gap, the classification is not a
heuristic. It is a theorem.

---

## Three worlds, three gap laws

Normalize first: rescale your gaps so that the *average* gap is exactly $1$.
This kills all information about units and density and leaves only shape. Now
three canonical shapes present themselves.

**The rigid world.** A perfect crystal of levels: $\lambda_n = a + n$. Every
gap is exactly $1$. The gap distribution is a spike — a point mass at $s = 1$.
Nothing fluctuates. This is what a one-dimensional harmonic oscillator gives
you, and it is the picket fence against which all disorder is measured.

**The chaotic-quantum world.** Wigner's great insight was that the levels of a
complicated quantum system behave like the eigenvalues of a large random
matrix, and that random matrix eigenvalues *repel*. Two levels almost never sit
on top of each other. The celebrated **Wigner surmise** captures this with a
one-line formula. For a system with unitary symmetry (broken time reversal —
say, an electron in a magnetic field) the surmise reads

$$p_2(s) \;=\; \frac{32}{\pi^2}\, s^2\, e^{-4s^2/\pi}.$$

Notice the factor $s^2$: as $s \to 0$ the density vanishes *quadratically*.
Small gaps are strongly suppressed. That is level repulsion made visible.

**The random world.** If your levels are thrown down independently — a Poisson
process — the gaps are exponentially distributed:

$$p_\infty(s) = e^{-s}.$$

Here $p_\infty(0) = 1$: tiny gaps are the *most* likely thing of all. No
repulsion whatsoever. This is the signature of an integrable, non-chaotic
system.

The classical way to tell these apart is the variance of the gap. The three
variances are

$$0 \quad<\quad \tfrac{3\pi}{8} - 1 \approx 0.178 \quad<\quad 1,$$

rigid, chaotic, random. Strictly ordered — but the ordering by itself is a
weak statement. Can we say more? Can we say *everything*?

---

## The whole fingerprint, not just the variance

A probability distribution is not one number; it is an infinite sequence of
them. The $k$-th moment $M_k = \int_0^\infty s^k p(s)\,ds$ records the average
of $s^k$. Together, the sequence $M_0, M_1, M_2, \dots$ is the distribution's
**fingerprint**.

For the rigid spike the fingerprint is the dullest imaginable: $M_k = 1$ for
every $k$. For the exponential law it is the most famous sequence in
combinatorics: $P_k = k!$. And for the Wigner surmise?

Here the story becomes genuinely pretty. Integrate by parts against the
Gaussian factor $e^{-4s^2/\pi}$ and a single relation drops out, valid for
every $k$ at once:

> **The antiderivative recursion.** The moments of the unitary-class Wigner
> surmise satisfy
> $$M_{k+2} \;=\; \frac{(k+3)\pi}{8}\,M_k, \qquad k = 0, 1, 2, \dots$$

Two seed values, $M_0 = 1$ (it's a probability density) and $M_1 = 1$ (we
normalized the mean), and the recursion writes down the rest. The even and odd
branches unwind into closed form:

$$M_{2m} = (2m+1)!!\left(\frac{\pi}{8}\right)^m,
\qquad
M_{2m+1} = (m+1)!\left(\frac{\pi}{4}\right)^m,$$

where $(2m+1)!! = 1\cdot 3\cdot 5\cdots(2m+1)$. So
$M_2 = 3\pi/8 \approx 1.178$, $M_3 = \pi/2 \approx 1.571$,
$M_4 = 15\pi^2/64 \approx 2.313$, and so on. And more than that: the recursion
*is* the fingerprint. Any sequence at all that starts $1, 1$ and obeys
$M_{k+2} = \frac{(k+3)\pi}{8}M_k$ must be the Wigner moment sequence. There is
no other.

With closed forms in hand the comparison becomes a matter of arithmetic, and
the answer is total:

> **Moment fingerprint ordering.** For every $k \geq 2$,
> $$1 \;<\; M_k \;<\; k!.$$
> The rigid, chaotic and random fingerprints are strictly ordered at *every*
> moment order beyond the mean.

The first two moments are shared by all three laws — of course they are, we
forced them to be by normalizing — and from the third entry onward they never
touch again.

---

## A conjecture that turned out to be false, and the truth behind it

Here is where the investigation took a turn. Look at the tables of $M_k$ and
$k!$ and you cannot help suspecting a coincidence somewhere: surely at some
large $k$ the two curves cross, or graze, or share a value. The factor
$(2m+1)!!$ is so close in spirit to a factorial, and $\pi$ is such a
well-behaved number.

They never meet.

> **No higher coincidence.** $M_k = k!$ if and only if $k \leq 1$.

The $\pi$-powers in the closed forms damp the surmise moments below factorial
growth permanently. In fact the ratio collapses geometrically:
$M_k / k! \le 2 \cdot 2^{-\lfloor k/2\rfloor}$, so $M_k/k! \to 0$. Beyond a
handful of terms the two fingerprints are not merely different, they are
different by orders of magnitude ($M_{10}/10! \approx 2.7 \times 10^{-5}$).

But the *intuition* that something ties the two sequences together was not
wrong. It was looking in the wrong place. The relation is not an equality of
moments at the same index; it is an **index-halving duality**:

$$\frac{M_{2m+1}}{P_{m+1}} = \left(\frac{\pi}{4}\right)^{m},
\qquad
M_{2m}\cdot m! = P_{2m+1}\left(\frac{\pi}{16}\right)^{m}.$$

Read the first one aloud: *the odd Wigner moments are exactly the exponential
moments at half the index, damped by a pure geometric factor.* The second says
the even Wigner moments are the odd exponential moments divided by a factorial
and damped by another pure geometric factor. Two clean ratios, $\pi/4$ and
$\pi/16$, and both are less than $1$ — which is precisely, and only, why the
Wigner fingerprint sits below the exponential one everywhere. The suspected
coincidence was a real structure wearing the wrong index.

The two laws separate analytically too. Form the exponential generating
functions $\sum_k M_k t^k/k!$ and $\sum_k P_k t^k/k!$. The second is just the
geometric series $\sum t^k$, which blows up the instant $t \geq 1$. The first
converges on the whole disc $t^2 < 2$. So the entire band
$1 \le t < \sqrt{2}$ is a window in which one series lives and the other dies:
an analytic litmus test, not just a numerical one.

---

## Climbing the ladder: five regimes, not three

Wigner's surmise is not one formula but a family. The symmetry class of the
physical system fixes an exponent $\beta$ — the power of $s$ that controls how
hard levels repel. Time-reversal-invariant systems with rotational symmetry
give $\beta = 1$ (orthogonal class); broken time reversal gives $\beta = 2$
(unitary); time reversal with half-integer spin gives $\beta = 4$
(symplectic). Each has its own surmise, normalized to mean one:

$$p_1(s) = \frac{\pi}{2}\,s\,e^{-\pi s^2/4}, \qquad
p_2(s) = \frac{32}{\pi^2}\,s^2\,e^{-4s^2/\pi}, \qquad
p_4(s) = \frac{2^{18}}{3^6\pi^3}\,s^4\,e^{-64 s^2/(9\pi)}.$$

All three are instances of one shape, $a\,s^\beta e^{-b s^2}$, and one
calculation covers them all. Its moments are

$$M_k = \frac{a}{2}\; b^{-\frac{k+\beta+1}{2}}\;
\Gamma\!\left(\frac{k+\beta+1}{2}\right),$$

and — using nothing more than the functional equation
$\Gamma(t+1) = t\,\Gamma(t)$ — the universal recursion is

$$M_{k+2} = \frac{k+\beta+1}{2b}\,M_k.$$

Feed the recursion the normalization $M_0 = 1$ and it hands you the second
moment for free, with no integration at all. Specialize:

| Regime | $\beta$ | recursion coefficient | second moment | value |
|---|---|---|---|---|
| rigid | — | $1$ | $1$ | $1.0000$ |
| symplectic | $4$ | $9\pi(k+5)/128$ | $45\pi/128$ | $1.1045$ |
| unitary | $2$ | $\pi(k+3)/8$ | $3\pi/8$ | $1.1781$ |
| orthogonal | $1$ | $2(k+2)/\pi$ | $4/\pi$ | $1.2732$ |
| Poisson | — | $(k+1)(k+2)$ | $2$ | $2.0000$ |

> **The $\beta$-ladder.**
> $$1 \;<\; \frac{45\pi}{128} \;<\; \frac{3\pi}{8} \;<\; \frac{4}{\pi} \;<\; 2.$$

Five regimes, strictly ordered by a single statistic. Stronger repulsion (a
larger $\beta$) means a stiffer, more crystal-like spectrum and a second moment
closer to the rigid value $1$; weaker repulsion means a floppier spectrum
closer to Poisson. The whole physical hierarchy is a chain of four
inequalities.

And it is not just the second moment. Because each regime's moments obey a
two-term recursion, and because the recursion *coefficients* are ordered at
every index —

$$\frac{9\pi(k+5)}{128} \;<\; \frac{\pi(k+3)}{8} \;<\; \frac{2(k+2)}{\pi}
\;<\; (k+1)(k+2)$$

— a simple comparison argument propagates the order to the moments themselves:

> **Full moment ladder.** For every $k \ge 2$,
> $$1 \;<\; M_k^{(4)} \;<\; M_k^{(2)} \;<\; M_k^{(1)} \;<\; k!.$$

The five-fold ordering is not an accident of the variance. It holds at every
order, forever.

---

## From a theorem to a test you can actually run

A ladder of constants is only useful if you can land on the right rung with
finite data. Here is the operational content.

Compute $\widehat{M_2} = \frac{1}{n}\sum_{i=1}^n s_i^2$ from your $n$
normalized gaps. Classify by nearest ladder value. The rungs are separated by
gaps of size $0.1045$, $0.0736$, $0.0951$, and $0.7268$; the *smallest* of
these — the bottleneck of the whole scheme — is the symplectic/unitary gap,
and it is exactly

$$\text{gap}_{\min} = \frac{3\pi}{8} - \frac{45\pi}{128} = \frac{3\pi}{128}
\approx 0.07363.$$

> **Separation theorem.** If $\widehat{M_2}$ lies within $3\pi/256$ of a ladder
> value, the nearest-rung classifier returns that regime — correctly, always.

Statistical fluctuations of an empirical second moment are of order
$n^{-1/2}$. Suppose your fluctuation obeys $|\widehat{M_2} - M_2| \le C/\sqrt n$.
Then the classification is provably correct as soon as
$n > (2C/\text{gap}_{\min})^2$. With $C = 1$ that reads:

- **$n \ge 738$** gaps to separate all five regimes;
- **$n \ge 127$** gaps for the coarser three-way test (rigid / unitary /
  Poisson), whose bottleneck is the larger constant $3\pi/8 - 1 \approx 0.178$.

Seven hundred and thirty-eight spacings. That is a small nuclear data table, a
modest numerical diagonalization, an afternoon of zeta zeros. The separation
constant is sharp, too: at exactly the half-gap distance the classifier already
flips, so the threshold cannot be relaxed.

---

## What the rigid rung really means

One might worry that the "rigid" bucket is a mere labelling convention — that
$\widehat{M_2}$ near $1$ is suggestive but not conclusive. It is conclusive.

For any mean-one collection of gaps, a two-line algebraic identity says

$$\sum_{i=1}^n (s_i - 1)^2 = n\left(\widehat{M_2} - 1\right).$$

The empirical second moment *is* the empirical variance. So $\widehat{M_2} = 1$
does not merely suggest rigidity; it forces every single gap to equal $1$
exactly. The picket fence is characterized, not approximated. And the
quantitative version is just as clean: a Cauchy–Schwarz step turns
$\widehat{M_2} = 1 + \varepsilon$ into

$$\frac{1}{n}\sum_{i=1}^n |s_i - 1| \;\le\; \sqrt{\varepsilon},$$

so a second moment close to $1$ certifies that the spectrum is uniformly close
to a perfect crystal, in average absolute deviation.

Conversely, every value in $[1,2]$ is genuinely attainable: the two-gap
configuration $(1+t, 1-t)$ has mean one, nonnegative entries for $t \le 1$, and
second moment exactly $1 + t^2$. So the classifier's range is not a
mathematical fiction — every rung is realized by an honest finite spectrum.

---

## The deeper structure: positivity

One last piece, and it is the one that explains why the fingerprint behaves so
well. Build the Hankel matrix of the Wigner moments, $H_{ij} = M_{i+j}$. Then
for any coefficients $c_0, \dots, c_{n-1}$,

$$\sum_{i,j} c_i c_j M_{i+j}
= \int_0^\infty \Big(\sum_i c_i s^i\Big)^2 p_2(s)\,ds \;\ge\; 0,$$

because you are integrating a square against a nonnegative density. Every
Hankel form of the fingerprint is positive semidefinite — the classical
side-condition certifying that a sequence of numbers really is the moment
sequence of an honest measure. The order-two instance is
$M_0M_2 - M_1^2 = 3\pi/8 - 1$: the variance gap reappears as a determinant.
The order-three determinant is

$$\frac{\pi^2(9\pi - 28)}{256},$$

whose positivity is *equivalent* to the elementary inequality $\pi > 28/9 =
3.111\ldots$ — an amusing reduction of a structural fact about random matrix
statistics to a decimal expansion. Ordered against the other regimes, the third
Hankel determinants read $0$ (rigid, degenerate because a point mass lives on a
single point), $\pi^2(9\pi-28)/256 \approx 0.01058$ (unitary), and $4$
(Poisson). The same three-fold ordering as the variance, now visible in a
determinant.

---

## Why any of this matters

Level-spacing statistics are one of physics' great unifying observations. The
same gap distribution shows up in the resonance spectra of heavy nuclei, in
microwave cavities shaped like chaotic billiards, in the conductance
fluctuations of disordered metals, in the vibrational modes of quartz blocks,
and — via the Montgomery–Odlyzko phenomenon — in the zeros of the Riemann zeta
function, which follow the unitary law to breathtaking numerical precision.
Distinguishing "chaotic" from "integrable" by looking at gaps is a standard
diagnostic across all of these fields.

What was previously a diagnostic is now a theorem with a constant attached. The
statistic is one line of code. The ladder is five explicit numbers. The
minimum separation is $3\pi/128$. The sample size that guarantees correctness
is $738$. There is no tuning, no threshold to choose, no distributional
assumption beyond a bound on the fluctuation of your own estimator.

And along the way the investigation refuted its own starting suspicion — there
is no higher moment coincidence between the Wigner surmise and the exponential
law — while turning up the genuine relation hiding underneath it, the
index-halving duality $M_{2m+1} = (m+1)!\,(\pi/4)^m$. That is usually how it
goes. You go looking for a coincidence, you prove it cannot exist, and the
proof shows you what was actually there.

Sort your levels. Look at the gaps. Square them and take the average. The
number you get knows which universe you are in.
