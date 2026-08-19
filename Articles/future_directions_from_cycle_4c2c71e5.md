# The Hidden Diffraction Pattern of the $3n+1$ Problem

## Listening to a famous unsolved problem

Take a whole number. If it is even, halve it. If it is odd, triple it and add one. Repeat. This is the Collatz map, the $3n+1$ problem, and the conjecture that every starting number eventually reaches $1$ has resisted proof for almost a century. Paul Erdős famously said that mathematics is not yet ready for such problems.

When a problem resists direct attack, physicists have a favourite move: stop looking at the object and start looking at its *spectrum*. Do not stare at the crystal — shine X-rays through it and read the diffraction pattern. Do not describe the sound wave — take its Fourier transform and read the overtones. A spectrum turns a complicated, irregular object into a landscape of peaks and valleys, and the peaks and valleys are often much easier to interpret than the object itself.

This article is about what happens when you do exactly that to the $3n+1$ map — and about a surprisingly sharp structural principle that emerges. The punchline: the Collatz map *does* have a diffraction pattern with "systematic absences", frequencies at which the signal cancels perfectly. But those absences are fragile. They come not from the arithmetic of the number $3$, nor from anything deep about the dynamics. They come from a single accident of bookkeeping: **exactly half of all integers are even.**

## Building the spectrum

Here is the construction. Write $T(n)$ for one step of the map: $T(n) = n/2$ when $n$ is even, and $T(n) = an+1$ when $n$ is odd, where $a$ is an odd multiplier ($a = 3$ gives Collatz; $a=5$ and $a=7$ give the cousins that are also widely studied).

The map itself grows and shrinks unpredictably, so we look instead at the *ratio* it produces, $T(n)/n$, which measures the multiplicative effect of one step. Attach to each integer $n$ a unit complex number — a point on the unit circle — that spins at a rate set by that ratio:

$$e\big(\omega \cdot T(n)/n\big), \qquad e(x) := e^{2\pi i x},$$

where $\omega$ is a frequency dial we are free to turn. Then add up the first $N$ of these arrows:

$$F(\omega, N) \;=\; \sum_{n=1}^{N} e\!\left(\omega\,\frac{T(n)}{n}\right).$$

This is a diffraction pattern in the most literal sense: each integer contributes a wave, and we ask how the waves interfere. If they all point roughly the same way, $|F(\omega,N)|$ grows like $N$ — a bright spot. If they cancel, $|F(\omega,N)|$ is much smaller than $N$ — a dark spot, an *extinction*.

What does the pattern look like? The answer is remarkably clean, because the ratio $T(n)/n$ takes only two shapes. If $n$ is even, $T(n)/n = 1/2$ exactly. If $n$ is odd, $T(n)/n = a + 1/n$, which converges to $a$ as $n$ grows. So asymptotically there are just **two arrow directions**, $e(\omega/2)$ and $e(a\omega)$, each carried by exactly half the integers. Dividing by $N$ to normalise, the pattern converges:

$$\frac{F(\omega,N)}{N} \;\longrightarrow\; A(\omega) \;=\; \frac{e(\omega/2) + e(a\omega)}{2},$$

and the brightness is
$$|A(\omega)| \;=\; \Big|\cos\!\big(\tfrac{\pi(2a-1)\omega}{2}\big)\Big|.$$

Two arrows of equal length, half and half. And two equal arrows can cancel *completely*: whenever $(2a-1)\omega$ is an odd integer, the two point in exactly opposite directions and annihilate. For the genuine Collatz map, $a=3$, the first such frequency is $\omega = 1/5$. There the sum of $N$ unit arrows is not of size $N$; it is of size $o(N)$. Perfect destructive interference.

It is tempting to see something profound here — a hidden resonance in the $3n+1$ problem, a spectral fingerprint of the multiplier $3$. The main results below say, unambiguously, that this reading is wrong, and they say exactly why.

## The dominant-branch principle

Everything hinges on one number: the *density* of each branch.

Suppose we have any sequence of "phases" $r(1), r(2), r(3), \dots$ and we form the same kind of sum, $\sum_{n\le N} e(\omega r(n))$. Suppose some set $D$ of indices has asymptotic density $d$ — meaning a fraction $d$ of the first $N$ indices lie in $D$, in the limit — and that along $D$ the phases settle down to a single value $\theta$. Then here is the principle:

> **Dominant-Branch Principle.** If $d > 1/2$, then for *every* real frequency $\omega$ and every constant $c < 2d-1$, the sum has size at least $cN$ for all large $N$. In particular it never cancels, at any frequency whatsoever.

The proof is a two-line accounting argument once stated correctly. The indices in $D$ contribute a block of roughly $dN$ nearly identical arrows, which add up to length nearly $dN$. Everything else — the other $(1-d)N$ arrows — can at worst point the opposite way, subtracting at most $(1-d)N$. The net length is at least $dN - (1-d)N = (2d-1)N$. The only technical work is showing that the arrows within $D$ really do align: the deviations $r(n) - \theta$ tend to zero, and an averaging argument (a Cesàro mean) turns "eventually small" into "small on average", which is what a sum of $N$ terms needs.

The threshold $d > 1/2$ is not a convenience of the proof. It is exactly right, and the Collatz map itself proves the sharpness: at $a=3$ and $\omega = 1/5$, the odd integers form a branch of density *exactly* $1/2$ whose phases converge to $3$ — every hypothesis holds but the density is not strictly above one half — and the conclusion fails for every positive constant $c$, since the sum is $o(N)$. One half is the knife edge. Above it, no cancellation is possible; at it, total cancellation can occur.

Once you see the principle, the Collatz resonance stops looking mysterious. It exists *because the two branch densities are both $1/2$*. Balance is the whole story.

## Test one: iterate the map

If the resonance were a genuine feature of the dynamics, it should survive when we look at the dynamics more carefully. So take two steps instead of one, and build the same kind of spectrum from $T(T(n))/n$.

Here the answer depends on $n$ modulo $4$, in the style of Terras's parity analysis:

- $n \equiv 0 \pmod 4$: two halvings, so the ratio is exactly $1/4$ — density $1/4$;
- $n \equiv 2 \pmod 4$: halve, then multiply, giving $a/2 + 1/n$ — density $1/4$;
- $n$ odd: multiply (which yields an even number, since $a$ and $n$ are odd), then halve, giving $a/2 + 1/(2n)$ — density $1/2$.

The last two branches converge to the *same* limiting phase $a/2$. They coalesce. So instead of two balanced arrows we get two arrows of **unequal** length: weight $1/4$ at phase $1/4$, and weight $3/4$ at phase $a/2$. The normalised depth-two pattern converges to

$$A_2(\omega) \;=\; \frac{e(\omega/4) + 3\,e(a\omega/2)}{4},$$

with exact brightness
$$|A_2(\omega)|^2 \;=\; \frac{10 + 6\cos\!\big(\pi(2a-1)\omega/2\big)}{16}.$$

Since the cosine never drops below $-1$, we get $|A_2(\omega)| \ge 1/2$ for **every** frequency and **every** multiplier — and the bound is exactly attained, at $\omega = 2/(2a-1)$. A three-to-one imbalance simply cannot be cancelled by a one-to-three minority. Concretely: the depth-two sum satisfies $|F_2(\omega,N)| \ge N/4$ for all large $N$, at every frequency, rational or irrational.

The contrast is stark and can be stated at a single point. For $a = 3$ at $\omega = 1/5$: the one-step transform is $o(N)$ — total extinction — while the two-step transform built from the *same map* at the *same frequency* stays above $N/4$. **The resonance does not survive iteration.** It is not a dynamical invariant. It is an artefact of the $1/2$–$1/2$ split of parities at depth one.

## Test two: change the base

The second test is even more decisive. Keep the multiplicative branch exactly as it is, but change what "divide" means: for a base $b$, let the map send $n \mapsto n/b$ when $b \mid n$, and $n \mapsto an+1$ otherwise. Base $b=2$ is Collatz.

Now the dividing branch has density $1/b$ and the multiplicative branch has density $1 - 1/b$, with limiting phase $a$. For $b \ge 3$ the multiplicative branch has density strictly above $1/2$, so the Dominant-Branch Principle applies immediately and gives, at *every* real frequency,

$$|G_b(\omega,N)| \;\ge\; \frac{b-2}{2b}\,N \quad\text{for all large } N,$$

and in fact the sharp constant $1 - 2/b$ up to any $\varepsilon > 0$. No spectral gap. None. For any multiplier $a$, at any frequency.

So among all bases, **halving is the unique resonant base**. The spectral extinctions of the $3n+1$ problem are a property of the number $2$ in the denominator, not of the number $3$ in the numerator. The arithmetic of the multiplier controls only *where* the dark frequencies sit — at $(2a-1)\omega$ odd — never *whether* they exist.

## What survives: averages

If the pointwise dark spots are fragile, is there anything robust in the spectrum? Yes, but you have to average.

The natural robust statistic is the mean-square power over a full period of the pattern, which for these maps is the interval $\omega \in [0,4]$. Averaging the brightness across the whole period washes out the oscillating cosine and leaves behind exactly the sum of the squared branch weights:

$$\frac{1}{4}\int_0^4 |A(\omega)|^2\,d\omega = \left(\tfrac12\right)^2 + \left(\tfrac12\right)^2 = \frac12, \qquad
\frac{1}{4}\int_0^4 |A_2(\omega)|^2\,d\omega = \left(\tfrac14\right)^2 + \left(\tfrac34\right)^2 = \frac58.$$

Two things are worth pausing on. First, the answer does **not** depend on $a$ at all: the mean-square power at depth one is $1/2$ for the $3n+1$, $5n+1$ and $7n+1$ maps alike, and $5/8$ at depth two for all of them. This averaged statistic detects *dynamical depth* and is completely blind to the multiplier. Second, at finite $N$ the same identities hold with a controlled error: the finite-$N$ power over a period differs from its limit by at most $8(1 + 8\pi(1+\log N))/N$, which decays to zero. Consequently, for every odd multiplier, the depth-two power eventually exceeds the depth-one power by at least $1/4$ — a robust, verifiable discriminator that survives averaging even though the individual dark frequencies do not.

There is a second averaged statement, and it is the one that repairs a naive hope. One might want to claim that the Collatz transform is *small* at all irrational frequencies. That claim is impossible: the transform is continuous in $\omega$, and near $\omega=0$ every arrow points the same way, so $|F(\omega,N)|$ is close to its maximum $N$ — including at irrational $\omega$ near zero. Continuity forbids any pointwise smallness statement. What one can say instead is a Chebyshev-type bound: for any threshold $\lambda>0$, the set of frequencies in the period $[0,4]$ where $|F(\omega,N)| \ge \lambda N$ has Lebesgue measure at most $(2 + 8\varepsilon_N)/\lambda^2$, where $\varepsilon_N = (1+8\pi(1+\log N))/N \to 0$. Taking $\lambda = 1$: for large $N$, the frequencies at which the transform attains its trivial maximal size occupy at most half of the period. The bright peaks are real, but they are confined to a set of controlled measure — a statement fully compatible with isolated resonant peaks, unlike a pointwise bound.

## The moral

Spectral methods are seductive because they turn arithmetic into optics. You get to say things like "resonance" and "spectral gap" and draw pictures with dark bands. The temptation is to read every dark band as a message from the dynamics.

The results here draw a clean line. Cancellation in this kind of transform is decided by one thing and one thing only: the **density profile of the branches**. Above density $1/2$, no cancellation ever, at any frequency, with a quantitative constant. At exactly $1/2$, cancellation is possible and does occur. Everything else — the multiplier, the arithmetic of $3$ versus $5$ versus $7$, the deep unsolved dynamics — moves the dark bands around but cannot create or destroy them.

Three concrete consequences follow, and they act as a set of guardrails for anyone hoping to attack the $3n+1$ problem this way. Resonances vanish when you iterate the map, so they are not dynamical invariants. Resonances vanish for every base other than $2$, so they are not about the multiplier. And averaged statistics — the ones that *do* survive — see only depth, not arithmetic.

None of this makes the Collatz conjecture easier. But it tells you precisely which spectral roads are dead ends, and it does so with an exact constant on every claim. In a field where the graveyard is full of plausible approaches, knowing the shape of the graveyard is worth something. And the underlying principle — a branch of density above one half forces linear growth of an exponential sum at every frequency, with the explicit constant $2d-1$ — is a general tool. It applies far beyond Collatz, to any dynamical system whose one-step behaviour splits into branches with computable densities and convergent phases. Wherever the branches are unbalanced, the diffraction pattern can never go dark.
