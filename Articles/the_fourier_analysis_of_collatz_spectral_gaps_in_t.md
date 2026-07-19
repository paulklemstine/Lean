# The Fourier Analysis of Collatz: Why a Proposed Spectral Gap Cannot Exist

The Collatz problem begins with an operation simple enough to explain on a napkin. Start from a positive integer. If it is even, divide it by two. If it is odd, multiply it by three and add one. Repeat. Thus $6$ travels through

$$
6\longmapsto 3\longmapsto 10\longmapsto 5\longmapsto 16\longmapsto 8\longmapsto 4\longmapsto 2\longmapsto 1.
$$

The famous conjecture says that every starting value eventually reaches $1$, after which the familiar cycle $1,4,2,1$ repeats. No one knows whether that assertion is true.

A tempting way to look for hidden order is to borrow a lens from wave mechanics: Fourier analysis. Fourier methods turn a complicated signal into a collection of frequencies. They reveal the pitch of a musical note, the periodic structure of an image, and the resonant modes of a physical system. Might they also reveal whether the Collatz map mixes integers thoroughly enough to prevent runaway behavior?

That question motivates a finite exponential sum. Yet before searching for a subtle spectral signature, one must inspect its most elementary frequency. Doing so reveals a decisive obstruction: the proposed global spectral gap is impossible, not because of a special mystery in Collatz arithmetic, but because of continuity and the density of irrational numbers.

This is a useful negative result. It does not settle the Collatz conjecture. Instead, it tells us exactly how a Fourier reformulation must change before it can plausibly say anything about that conjecture.

## Turning the map into a wave

Define the unaccelerated Collatz map $T$ on positive integers by

$$
T(n)=
\begin{cases}
n/2, & n\text{ even},\\
3n+1, & n\text{ odd}.
\end{cases}
$$

For a cutoff $N\geq 1$ and a real frequency $\omega$, consider

$$
F_N(\omega)=\sum_{n=1}^{N}
\exp\!\left(2\pi i\omega\frac{T(n)}{n}\right).
$$

Each summand is a point on the unit circle in the complex plane. The magnitude $|F_N(\omega)|$ measures alignment. If the points aim in unrelated directions, they cancel and the sum is comparatively small. If they line up, the magnitude is large, reaching at most $N$.

This picture makes a bound such as $|F_N(\omega)|<C$ seem like evidence of cancellation. The proposed condition asked for a constant $C<\sqrt N$ that bounds the magnitude at every irrational frequency. Since irrational frequencies may sound “nonresonant,” this might initially appear reasonable.

But zero frequency is a perfect resonance. At $\omega=0$, every exponential equals $1$, so

$$
F_N(0)=N.
$$

The key question is what happens immediately beside zero.

## A peak cannot end abruptly

The function $F_N$ is continuous in $\omega$. Every term is a continuous complex exponential, and a finite sum of continuous functions is continuous. Consequently, frequencies sufficiently close to zero produce values of $F_N(\omega)$ close to $N$.

Irrational numbers occur in every nonempty interval. No matter how tightly one zooms around zero, irrational frequencies remain present. Therefore irrational frequencies can approach the zero-frequency peak as closely as desired.

This gives the central result.

**Near-Peak Theorem.** For every cutoff $N\geq 1$ and every error $\varepsilon>0$, there exists an irrational frequency $\omega$ such that

$$
|F_N(\omega)|>N-\varepsilon.
$$

The proof is short but powerful. Continuity of $|F_N|$ and the equality $|F_N(0)|=N$ provide an interval around zero on which $|F_N(\omega)|>N-\varepsilon$. Density then supplies an irrational $\omega$ inside that interval.

In fact, the mechanism does not depend on the Collatz map. Suppose $f:\mathbb R\to\mathbb C$ is any continuous function satisfying $f(0)=N$. For every $C<N$, continuity gives a neighborhood of zero in which $|f(\omega)|>C$, and that neighborhood contains an irrational point. The Collatz sum is merely one instance of this general topological fact.

## The proposed gap collapses

A second elementary theorem completes the picture.

**Global Upper-Bound Theorem.** For every real frequency $\omega$,

$$
|F_N(\omega)|\leq N.
$$

This follows from the triangle inequality: there are $N$ summands, each of magnitude $1$. The bound is sharp because equality holds at zero.

Now assume $N>1$. Then $\sqrt N<N$. If $C<\sqrt N$, we also have $C<N$. The near-peak theorem therefore supplies an irrational frequency with

$$
|F_N(\omega)|>C.
$$

Hence no $C<\sqrt N$ can bound the transform at all irrational frequencies.

**No-Global-Gap Theorem.** For every integer $N>1$, there is no real constant $C<\sqrt N$ such that

$$
|F_N(\omega)|<C
$$

for every irrational $\omega$.

Notice how little arithmetic entered the argument. The same obstruction applies to every finite phase sum

$$
S_N(\omega)=\sum_{n=0}^{N-1}e^{i\omega\phi(n)},
$$

where $\phi(n)$ is any real-valued phase. At zero, all $N$ arrows align; continuity preserves near-alignment close to zero; irrational frequencies accumulate there. Thus for every $C<N$, some irrational $\omega$ satisfies $|S_N(\omega)|>C$.

The phrase “irrational frequency” does not by itself mean “far from resonance.” Irrational numbers can be extraordinarily close to integers. Excluding rational frequencies while retaining every irrational one removes isolated points but leaves the neighborhoods of all resonances intact.

## The arithmetic hidden inside the sum

Although the impossibility result is topological, the particular Collatz phase has useful structure. Dividing each branch by $n$ gives

$$
\frac{T(n)}{n}=
\begin{cases}
1/2, & n\text{ even},\\
3+1/n, & n\text{ odd}.
\end{cases}
$$

Thus all even indices contribute exactly the same phase:

$$
e^{\pi i\omega}.
$$

The odd indices contribute

$$
e^{2\pi i\omega(3+1/n)}
=e^{6\pi i\omega}e^{2\pi i\omega/n}.
$$

So the transform separates as

$$
F_N(\omega)
=E_N e^{\pi i\omega}
+e^{6\pi i\omega}
\sum_{\substack{1\leq n\leq N\\ n\text{ odd}}}e^{2\pi i\omega/n},
$$

where $E_N=\lfloor N/2\rfloor$ is the number of even integers up to $N$.

This decomposition exposes another warning. Roughly half of the terms are perfectly synchronized at every frequency because the even branch always has ratio $T(n)/n=1/2$. Any cancellation estimate must account for that coherent block. The sum is not a generic cloud of unrelated phases.

It also gives an efficient numerical algorithm. Count the even terms once, then sum only over odd indices. This halves the number of exponential evaluations while preserving the exact value.

## What a numerical experiment should show

A frequency grid can make the obstruction visible. Compute $F_N(\omega)$ near zero, plot $|F_N(\omega)|$, and mark irrational sample points such as $\omega=\sqrt2/m$ for large $m$. As $m$ grows, these frequencies approach zero and the measured magnitude approaches $N$.

The experiment illustrates the theorem, but it does not prove a gap or its absence on an uncountable set. A grid always has spaces between sample points. Here the proof comes from continuity, while computation supplies geometric intuition.

The same program can compare generalized maps

$$
T_a(n)=
\begin{cases}
n/2, & n\text{ even},\\
an+1, & n\text{ odd},
\end{cases}
$$

for odd multipliers such as $a=3,5,7$. Their finite transforms all satisfy $F_{N,a}(0)=N$, so all share the same near-zero obstruction. A graph near zero cannot distinguish whether their long-term orbits converge. Any useful discriminator must look away from the universal resonance or use a statistic tied to actual trajectories.

## How to repair the spectral question

The failure points toward better questions.

First, exclude a neighborhood of integer resonances, not merely the rational frequencies. For a fixed $\delta>0$, one can study frequencies satisfying

$$
\operatorname{dist}(\omega,\mathbb Z)\geq\delta.
$$

This removes the continuity-forced peaks around every integer.

Second, normalize the transform:

$$
G_N(\omega)=\frac{F_N(\omega)}{N}.
$$

Then $|G_N(\omega)|\leq1$, and one can ask whether $G_N$ tends to zero uniformly on compact sets away from resonances. Such a statement would express genuine large-$N$ cancellation.

Third, replace a pointwise demand by an averaged one. An $L^2$ estimate studies

$$
\int_I |G_N(\omega)|^2\,d\omega
$$

on a frequency interval $I$. Narrow resonant peaks may coexist with strong average cancellation. One may also seek bounds outside an exceptional set whose measure tends to zero.

Finally, distinguish a one-step transform from an orbit transform. The sum $F_N$ records the values of $T(n)/n$ for many unrelated inputs. The stopping time of one starting integer concerns the sequence $n,T(n),T^2(n),\ldots$. A claim connecting spectral width to an $O(\log n)$ stopping-time estimate needs a precisely defined orbit-dependent signal and proofs in both directions. It is not an automatic equivalence.

## A sharper lesson about Fourier thinking

Fourier analysis is often described as a machine for discovering hidden regularity. But it is equally valuable as a machine for rejecting ill-posed questions. The zero mode is not a technical nuisance. It is where all phases agree, and continuity spreads its influence to nearby frequencies. Density ensures that labeling frequencies “irrational” cannot wall that influence off.

The resulting conclusion is exact: the finite Collatz transform has global maximum $N$, irrational frequencies come arbitrarily close to that maximum, and therefore the proposed uniform sub-square-root bound over all irrational frequencies is false for every $N>1$.

This does not make a spectral study of Collatz hopeless. It makes it more disciplined. The next generation of questions should normalize, avoid resonance neighborhoods, use averaged estimates, exploit the even–odd decomposition, and define orbit statistics explicitly. Each adjustment asks the transform to measure arithmetic structure rather than the unavoidable agreement of all waves at zero. That distinction matters far beyond this problem: in data analysis, signal processing, and dynamical systems, a coherent baseline can masquerade as meaningful organization unless it is removed before comparison.

There is also a broader scientific lesson. A failed criterion can be productive when its failure is explained at the right level. Here, no amount of larger-scale sampling can repair the original quantifier: every finer search merely moves closer to a peak that continuity already guarantees. The remedy is conceptual rather than computational—change the domain, the normalization, or the observable.

Sometimes progress begins not with proving the hoped-for theorem, but with locating the unavoidable peak that tells us how the theorem must be rewritten.
