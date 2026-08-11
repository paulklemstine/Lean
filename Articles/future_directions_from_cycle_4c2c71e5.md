# The Song of $3n+1$: Listening to a Famous Map, and Hearing Almost Nothing

## A conjecture that refuses to die

Pick a whole number. If it is even, halve it. If it is odd, triple it and add one. Repeat. Starting from $7$ you get

$$7 \to 22 \to 11 \to 34 \to 17 \to 52 \to 26 \to 13 \to 40 \to 20 \to 10 \to 5 \to 16 \to 8 \to 4 \to 2 \to 1.$$

Every number anyone has ever tried eventually crashes into $1$. Nobody can prove it always does. This is the Collatz conjecture, and it has the peculiar status of being simultaneously the most accessible unsolved problem in mathematics and one of the least tractable. Paul Erdős is supposed to have said that mathematics is not yet ready for such problems.

When a problem resists direct attack, mathematicians reach for translation. If you cannot count something, measure it. If you cannot measure it, take its Fourier transform — turn the object into a wave and look at its spectrum. This is the strategy that cracked prime-counting problems (Hardy–Littlewood, Vinogradov), and it is a natural thing to attempt for Collatz: encode each step of the map as a phase, add up the phases, and hope for *cancellation*. Massive cancellation in an exponential sum is the analytic signature of pseudorandomness, and pseudorandomness is exactly what would force every orbit down to $1$.

This article is about carrying out that program honestly for the simplest such sum — and discovering, with complete precision, that it cannot possibly work. The failure turns out to be more interesting than a vague "it didn't work". The sum converges to an explicit, beautiful formula; the formula is a single cosine; and the cosine tells you, in exact arithmetic terms, what the sum knows and what it can never know.

## Setting the sum up

Fix an odd multiplier $a$ — the classical case is $a = 3$, but $5n+1$ and $7n+1$ are just as natural to study, and they behave very differently as dynamical systems. Define the accelerated one-step map

$$T_a(n) = \begin{cases} n/2, & n \text{ even},\\ a n + 1, & n \text{ odd}.\end{cases}$$

The natural quantity to make into a phase is not $T_a(n)$ itself — that grows — but the *phase ratio*, the multiplicative factor by which one step changes the number:

$$r_a(n) = \frac{T_a(n)}{n}.$$

This is exactly the quantity whose logarithm governs whether orbits drift up or down. Now write $e(x) = e^{2\pi i x}$ for the standard character, a point on the unit circle in the complex plane, and form the **cutoff transform**

$$F_a(\omega, N) = \sum_{n=1}^{N} e\!\left(\omega\, r_a(n)\right).$$

Here $\omega$ is a real frequency, the dial we get to turn. Each term is a unit vector; there are $N$ of them; so trivially $|F_a(\omega, N)| \le N$. The whole game of analytic number theory is to prove that some sum of this shape is *much smaller* than the trivial bound — that the unit vectors point in enough different directions to cancel. If $|F_a(\omega, N)|$ were small for every irrational $\omega$, the sequence $r_a(1), r_a(2), r_a(3), \dots$ would be equidistributed, and one would have a genuine pseudorandomness statement about the map.

## The first surprise: the phases only take two shapes

Here is the observation that decides everything. Look at what $r_a(n)$ actually is.

If $n$ is even, $T_a(n) = n/2$, so $r_a(n) = 1/2$ exactly. Not approximately — exactly, for every even $n$, for every multiplier $a$.

If $n$ is odd, $T_a(n) = an + 1$, so

$$r_a(n) = a + \frac{1}{n}.$$

So the "random-looking" sequence of ratios is nothing of the sort. Half the time it is the constant $1/2$. The other half it is $a$ plus a vanishing correction $1/n$. The sequence has exactly two accumulation points, $1/2$ and $a$, and it visits them in strict alternation.

That kills the dream immediately, but it does much more: it lets us compute the sum exactly.

## The limit law

Split the sum into its even and odd parts. The even terms all contribute the identical phase $e(\omega/2)$, and there are $\lfloor N/2 \rfloor$ of them. The odd terms contribute $e(a\omega) \cdot e(\omega/n)$, and the correction factors $e(\omega/n)$ march steadily toward $1$. Averaging, the corrections wash out, and one obtains the exact statement:

> **Limit Law.** For every multiplier $a$ and every real frequency $\omega$,
> $$\frac{F_a(\omega, N)}{N} \longrightarrow A_a(\omega) := \frac{e(\omega/2) + e(a\omega)}{2} \qquad (N \to \infty).$$

The transform does not decay at all in general. It grows linearly, with an explicit proportionality constant: the average of two unit vectors, one for each branch of the map.

The rate is explicit too. Because $|e(x) - 1| \le 2\pi |x|$ and the odd reciprocals sum to at most $1 + \log N$, one gets the clean bound

$$\left| \frac{F_a(\omega, N)}{N} - A_a(\omega) \right| \le \frac{1 + 2\pi|\omega|(1 + \log N)}{N},$$

valid for every $N \ge 1$, with absolute constants: the same bound works for *all* multipliers $a$ simultaneously, and it is uniform for $\omega$ in any bounded set. So the convergence is uniform on compact frequency sets. That uniformity is precisely the corrected replacement for the impossible pointwise statement one might have hoped for.

## A single cosine

The amplitude $A_a(\omega)$ is the mean of two unit vectors, so its size is governed by the angle between them. Factoring out the common phase $e(\omega/2)$ leaves $\bigl(1 + e((a - \tfrac12)\omega)\bigr)/2$, and the modulus of $1 + e(t)$ is $2|\cos(\pi t)|$. Hence:

> **Modulus Formula.** $\;\;\bigl|A_a(\omega)\bigr| = \bigl|\cos\bigl(\pi (a - \tfrac{1}{2})\,\omega\bigr)\bigr|.$

The whole spectral content of the one-step Collatz phase is one cosine. Whatever complexity the map possesses — its unpredictable trajectories, its mysterious stopping times — has been flattened, by this particular measurement, into a trigonometric function that a first-year student could graph.

## Where the sum does cancel: resonances

A cosine has zeros, and those zeros are the only places where the sum genuinely cancels. Since $\cos(\pi t) = 0$ exactly when $t$ is a half-integer:

> **Resonance Classification.** $A_a(\omega) = 0$ if and only if $(2a - 1)\,\omega$ is an odd integer.

At such a frequency, and only there, we get $F_a(\omega, N) = o(N)$ — the unit vectors really do annihilate one another. The reason is transparent: at these frequencies the two branch phases $e(\omega/2)$ and $e(a\omega)$ are exactly antipodal, so the even contribution and the odd contribution cancel term by term. The numerics show the residual sum staying under $8$ even as $N$ reaches $100{,}000$.

Away from those frequencies, no cancellation of any kind occurs: $|F_a(\omega, N)| \ge c\,N$ eventually, with $c = |A_a(\omega)|/2 > 0$.

And near $\omega = 0$ the sum is as large as it can be. If $|(2a-1)\omega| \le 2/3$ then $|\cos(\pi(a - \frac12)\omega)| \ge 1/2$, so eventually

$$|F_a(\omega, N)| \ge \frac{N}{4}.$$

This is the decisive obstruction. Any hypothetical theorem asserting "the transform is small for every irrational frequency" is refuted by the irrational frequencies near zero, where continuity pins the sum against the trivial bound. There is no clever argument to be found; the statement is simply false, and its falsity is visible from the fact that the phase ratio has only two accumulation points.

## An arithmetic fingerprint

Here is where the story turns constructive. The resonance set of the multiplier $a$ is the arithmetic progression of frequencies

$$R_a = \left\{ \frac{2m+1}{2a-1} : m \in \mathbb{Z} \right\},$$

an evenly spaced comb with spacing $2/(2a-1)$. Different multipliers give different combs. At $\omega = 1/5$, for instance, $(2a-1)\omega$ equals $1$ for $a = 3$, equals $1.8$ for $a = 5$, and equals $2.6$ for $a = 7$. So:

> **Discriminator.** At the frequency $\omega = 1/5$ the $3n+1$ map has a complete spectral gap, while the $5n+1$ and $7n+1$ maps retain full linear size, with amplitudes $|A_5(1/5)| = \cos(\pi/10) \approx 0.951$ and $|A_7(1/5)| = |\cos(3\pi/10)| \approx 0.588$.

Symmetrically, $\omega = 1/9$ isolates $5n+1$ and $\omega = 1/13$ isolates $7n+1$. The three classical maps are pairwise separated by their spectra.

But the separation is subtle, and the subtlety is the moral of the story. At every *integer* frequency, all multipliers behave identically: every $a$ resonates at every odd integer $\omega$, and every $a$ has amplitude exactly $1$ at every even integer $\omega$. Indeed, one can show that two of the three classical maps resonate at a common frequency only at the odd integers — the trivial resonances shared by everyone. Any real discriminator must therefore live at non-integer frequencies. The behaviour near $\omega = 0$, where the sum is largest and most conspicuous, carries no information about $a$ whatsoever.

There is a second warning. A natural instinct, when a pointwise statement fails, is to average — to prove an $L^2$ bound over a period instead. That instinct fails here too, and for a reason one can compute exactly:

> **Mean-Square Identity.** For every multiplier $a \ge 1$, the mean of $|A_a(\omega)|^2$ over a full period equals $\tfrac{1}{2}$: precisely, $\int_0^2 |A_a(\omega)|^2 \, d\omega = 1$.

Every map, no matter its multiplier, carries the same total spectral energy. Averaging washes out the one piece of information the spectrum did contain — the *location* of the resonance comb — and leaves a universal constant. If you want to tell $3n+1$ from $7n+1$ spectrally, you must look at where the zeros are, not at how much energy there is.

## The deepest limitation: the spectrum cannot see the dynamics

The most important theorem in this circle of ideas is a negative one, and it is disarmingly simple to prove. Suppose you take the map $T_a$ and modify it however you like at a set of inputs of density zero — say, along one finite orbit, or on the powers of two. Then the two phase-ratio sequences disagree on a vanishing fraction of indices, each disagreement changes the sum by at most $2$, and so:

> **Blindness Theorem.** If two phase-ratio functions differ only on a set of density zero, their normalized cutoff transforms have the same limit. In particular, altering a map at finitely many points — inserting a cycle, destroying a cycle, changing a stopping time — leaves the normalized spectrum completely unchanged.

This is fatal for the original strategy. Whether or not the Collatz map has a nontrivial cycle is a question about a finite set of integers. The one-step spectrum is provably unable to distinguish a map with such a cycle from one without. No theorem of the form "spectral cancellation implies no divergent orbits" can hold for this statistic, not because the proof is hard, but because the statistic does not contain the information.

## Why this is worth knowing

There is a genre of mathematical result that consists of drawing an exact boundary around what a method can do. That is what we have here. A one-step exponential sum over the Collatz phase is not a hard object: it is a two-branch character sum, its normalized limit is $\bigl(e(\omega/2) + e(a\omega)\bigr)/2$, its modulus is a cosine, and its zero set is an arithmetic progression that identifies the multiplier and nothing else. Every question one can ask about "cancellation for the $an+1$ map at a fixed frequency" is now completely answered — and the answer, provably, contains no dynamical content.

The natural next moves are visible from here. The *second-order* term is not blind. Expanding the odd-branch correction as $e(\omega/n) = 1 + 2\pi i \omega/n + O(\omega^2/n^2)$ and summing against the odd harmonic series suggests that

$$F_a(\omega, N) - N\,A_a(\omega) - \pi i \omega\, e(a\omega)\log N$$

converges — so the subleading spectrum carries the branch phase undamped, where the leading term had crushed it into a single cosine. And *iterated* transforms, built from $T_a^m(n)/n$ for $m \ge 2$, should converge to a sum of $2^m$ branch phases weighted by residue-class densities mod $2^m$; for $m \ge 2$ the resulting zero set is no longer a lattice coset, and it should determine $a$ uniquely.

Those are the honest sequels. The lesson of the one-step case is that in this business, the first thing to do with a proposed pseudorandomness statistic is to compute what it converges to. If the limit is a cosine, no amount of ingenuity will extract a dynamical theorem from it — and knowing that saves everyone a great deal of time. The song of $3n+1$, at this frequency, turns out to be a pure tone.
