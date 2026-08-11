# Listening to the $3n+1$ Map

### A guided tour of the one-step spectrum: what it tells you, and what it can never tell you

---

## 1. The map, and the temptation

Pick a whole number. Halve it if it is even; triple it and add one if it is odd. Repeat. Every number ever tried eventually reaches $1$; nobody can prove it always does. This is the [Collatz conjecture](https://en.wikipedia.org/wiki/Collatz_conjecture), and it is famous precisely because it is so easy to state and so impossible to attack.

When a counting problem resists, analytic number theory reaches for a *Fourier transform*. Turn each step of the map into a point on the unit circle, add up those points, and hope they cancel. Massive cancellation in such an [exponential sum](https://en.wikipedia.org/wiki/Exponential_sum) is the analytic signature of pseudorandomness — and pseudorandomness is exactly what would force every orbit down to $1$.

This page carries that idea out to the end. The good news: the sum can be computed *exactly*. The bad news, which is really the interesting news: what it computes to has nothing to do with the dynamics.

Fix an integer multiplier $a \ge 1$ (the classical case is $a = 3$) and set

$$T_a(n) = \begin{cases} n/2, & n \text{ even},\\ an+1, & n \text{ odd}.\end{cases}$$

The right thing to feed into a character is not $T_a(n)$, which grows, but the **phase ratio** $r_a(n) = T_a(n)/n$ — the factor by which one step multiplies your number. With $e(x) = e^{2\pi i x}$, define the **cutoff transform**

$$F_a(\omega, N) = \sum_{n=1}^{N} e\bigl(\omega\, r_a(n)\bigr).$$

Each term is a unit vector, so $|F_a(\omega,N)| \le N$ trivially. Beating that bound is the whole game.

<details>
<summary><b>Why the ratio, and not the map itself?</b> (click to expand)</summary>

Three reasons. First, $T_a(n)$ is unbounded, so $e(\omega T_a(n))$ oscillates for silly reasons that have nothing to do with the map. Second, $r_a(n)$ is scale-invariant — it is the quantity whose logarithm decides whether an orbit is drifting up or down, and the heuristic "an orbit shrinks on average because $\tfrac12 \log 2 > \tfrac12\log(3/2)$" is a statement about exactly this ratio. Third, $r_a$ is bounded, so the sum is a genuine character sum over a bounded phase, which is the setting in which equidistribution statements have teeth.
</details>

---

## 2. The observation that decides everything

Here is the entire content of the subject in two lines. If $n$ is **even**, then $T_a(n) = n/2$, so

$$r_a(n) = \tfrac12 \quad \text{exactly, for every even } n, \text{ for every } a.$$

If $n$ is **odd**, then $T_a(n) = an+1$, so

$$r_a(n) = a + \frac1n.$$

The "random-looking" sequence of ratios is nothing of the sort. It has exactly **two** accumulation points, $1/2$ and $a$, visited in strict alternation, with a vanishing correction $1/n$ on the odd branch. Everything below follows from this.

Averaging the two branches gives the quantity that governs the whole story:

$$A_a(\omega) \;=\; \frac{e(\omega/2) + e(a\omega)}{2}.$$

---

## 3. Play with it

Before any proofs, get your hands on the object. In the laboratory below, the left panel draws the **phasor walk**: the partial sums $F_a(\omega,N)$ plotted in the complex plane, one unit step per integer $n$. The right panel draws the amplitude spectrum. Then drag the frequency slider slowly.

Two things to look for. Generically the walk is a **straight drift** — the sum grows linearly, no cancellation at all. But at a handful of magic frequencies the walk suddenly folds up into a **bounded curl** and stops growing. Those are the resonances, and finding them by hand is the fastest way to believe the theorem in the next section.

{{interactive_demo:0}}

*Try the presets:* $\omega = 1/5$ collapses the $3n+1$ map but not the $5n+1$ or $7n+1$ maps. $\omega = 1/9$ collapses $5n+1$ only, $\omega = 1/13$ collapses $7n+1$ only. And $\omega = 0.02$ shows the *peak*: near zero frequency there is no cancellation whatsoever, for anybody.

---

## 4. The limit law

Split the sum by parity. The even terms all contribute the identical phase $e(\omega/2)$ and there are $\lfloor N/2 \rfloor$ of them; the odd terms contribute $e(a\omega)\,e(\omega/n)$ with a correction factor marching towards $1$. In fact one has the exact finite identity

$$F_a(\omega, N) \;=\; \left\lfloor \frac{N}{2}\right\rfloor e(\omega/2) \;+\; e(a\omega) \!\!\sum_{\substack{n \le N \\ n \text{ odd}}}\!\! e\!\left(\frac{\omega}{n}\right).$$

> **Limit Law.** For every $a \ge 1$ and every real $\omega$,
> $$\frac{F_a(\omega,N)}{N} \longrightarrow A_a(\omega) = \frac{e(\omega/2)+e(a\omega)}{2}.$$
> Moreover, for every $N \ge 1$,
> $$\left|\frac{F_a(\omega,N)}{N} - A_a(\omega)\right| \;\le\; \frac{1 + 2\pi|\omega|\,(1+\log N)}{N},$$
> with absolute constants: the bound is the same for every multiplier $a$, and depends on $\omega$ only through $|\omega|$. Hence the convergence is uniform on every compact set of frequencies, simultaneously for all $a$.

<details>
<summary><b>The proof in full</b> (click to reveal)</summary>

Index by $k = n-1$, so $k$ even means $n$ odd. Compare each summand with the two-periodic model $A_a(\omega) + (-1)^k G_a(\omega)$, where $G_a(\omega) = \bigl(e(a\omega)-e(\omega/2)\bigr)/2$ is half the branch difference. The model equals $e(a\omega)$ for even $k$ and $e(\omega/2)$ for odd $k$, so the **deviation**

$$d_a(\omega,k) = e\bigl(\omega r_a(k+1)\bigr) - A_a(\omega) - (-1)^k G_a(\omega)$$

is exactly $0$ for odd $k$ and exactly $e(a\omega)\bigl(e(\omega/(k+1))-1\bigr)$ for even $k$. Summing the definition over $k < N$:

$$F_a(\omega,N) = N A_a(\omega) + G_a(\omega)\sum_{k<N}(-1)^k + \sum_{k<N} d_a(\omega,k).$$

The alternating sum is $0$ or $1$, and $|G_a| \le 1$, so the middle term contributes at most $1$. For the last term use the chord estimate $|e(x)-1| = 2|\sin(\pi x)| \le 2\pi|x|$, giving $|d_a(\omega,k)| \le 2\pi|\omega|/(k+1)$; summing the harmonic series, $\sum_{k<N} 1/(k+1) \le 1 + \log N$. Divide by $N$. $\blacksquare$
</details>

So the transform does **not** decay. It grows linearly, at an explicit rate: the average of the two branch phases.

---

## 5. One cosine, and its zeros

Factor out the common phase: with $t = (a-\tfrac12)\omega$ one has $\omega/2 + t = a\omega$, so $e(\omega/2)+e(a\omega) = e(\omega/2)\bigl(1+e(t)\bigr)$. Since $|1+e(t)| = 2|\cos(\pi t)|$:

> **Modulus Formula.** $\;|A_a(\omega)| = \bigl|\cos\bigl(\pi(a-\tfrac12)\omega\bigr)\bigr|.$
>
> **Resonance Classification.** $A_a(\omega) = 0$ if and only if $(2a-1)\,\omega$ is an odd integer, i.e.
> $$R_a = \left\{\frac{2m+1}{2a-1} : m \in \mathbb{Z}\right\},$$
> a comb of spacing $2/(2a-1)$. On $R_a$ one has genuine cancellation, $F_a(\omega,N) = o(N)$; off $R_a$ one has $|F_a(\omega,N)| \ge \tfrac12|A_a(\omega)|\,N$ for all large $N$.

The entire spectral content of the map — all its mystery, all its unpredictable trajectories — has been flattened by this measurement into a single cosine.

This picture shows the three classical maps side by side, each with its own comb:

{{visualization:0}}

And this one shows the geometry underneath: what the partial sums actually do in the plane, on and off resonance.

{{visualization:1}}

<details>
<summary><b>Why the peak at $\omega=0$ kills the original dream</b></summary>

Since $A_a(0) = 1$ and everything in sight is continuous, small frequencies cannot cancel. Precisely: if $|(2a-1)\omega| \le 2/3$ then $|t| \le 1/3$, so $\cos(\pi t) \ge \cos(\pi/3) = 1/2$, so $|A_a(\omega)| \ge 1/2$, and therefore eventually

$$|F_a(\omega,N)| \;\ge\; \frac{N}{4}.$$

Every interval around $0$ contains irrational frequencies. So there is **no** theorem of the form "the transform is $o(N)$ for all irrational $\omega$" — not because it is hard, but because it is false, and false for a completely transparent reason: the phase ratio has only two accumulation points, so $\{\omega r_a(n)\}$ is nowhere near equidistributed mod $1$. Any honest hypothesis must exclude a neighbourhood of the integer resonances explicitly.
</details>

---

## 6. What the spectrum *can* tell you: an arithmetic fingerprint

The comb depends on $a$, and different multipliers have different combs. Here is the algorithm that turns that observation into a certificate, using exact rational arithmetic so that no floating-point fuzz can invent or destroy a resonance:

{{algorithm:2}}

Running it on $\{3,5,7\}$ returns $1/5$, $1/9$, $1/13$:

> **Discriminator.** At $\omega = 1/5$ the $3n+1$ map cancels completely, while $|A_5(1/5)| = \cos(\pi/10) \approx 0.951$ and $|A_7(1/5)| = |\cos(3\pi/10)| \approx 0.588$: the other two maps keep full linear size. Symmetrically $\omega = 1/9$ isolates $5n+1$ and $\omega = 1/13$ isolates $7n+1$.

But there is a catch, and it is instructive.

<details>
<summary><b>Two ways the fingerprint can be washed out</b></summary>

**Integer frequencies are useless.** Every multiplier resonates at every odd integer $\omega$ (since $(2a-1)(2t+1)$ is always odd), and every multiplier has amplitude exactly $1$ at every even integer. So $|A_a(t)| = |A_b(t)|$ for all $a,b$ and all integers $t$: no discriminator can live at an integer frequency, nor near $\omega = 0$ where the sum is largest and most conspicuous. In fact, for the classical multipliers one can show that any *two* of them resonate at a common frequency **only** at the odd integers — a small Diophantine computation: if $9(2m+1) = 5(2k+1)$ then $5 \mid 2m+1$, forcing $\omega$ to be an odd integer.

**Averaging is useless.** Faced with the failure of pointwise decay, one instinctively retreats to an $L^2$ statement. Compute it: $|A_a(\omega)|^2 = \tfrac12 + \tfrac12\cos\bigl(\pi(2a-1)\omega\bigr)$, and the cosine integrates to zero over a full period because $2(2a-1)$ is an even integer. Hence

$$\int_0^2 |A_a(\omega)|^2\,d\omega = 1 \qquad \text{for every } a.$$

Every map carries identical total spectral energy. Only the *location* of the comb distinguishes them; any statistic that averages $|A_a|^2$ against a multiplier-independent weight is blind by construction.
</details>

---

## 7. The wall: the spectrum cannot see dynamics at all

Now the punchline. Modify the map however you like on a sparse set of inputs — along one finite orbit, at the powers of two, anywhere with density zero. Each modified term changes the sum by at most $2$, so:

> **Blindness Theorem.** If two phase-ratio functions differ only on a set of indices of density zero, their normalized transforms have the same limit. In particular, if $r$ agrees with $r_a$ outside a *finite* set, then $F[r](\omega,N)/N \to A_a(\omega)$ all the same.

Whether the Collatz map has a nontrivial cycle, and what the stopping time of any given integer is, are assertions about finite sets of integers — exactly the data this statistic cannot detect. So no implication

$$\text{"spectral cancellation"} \;\Longrightarrow\; \text{"no divergent orbits / no exotic cycles"}$$

can hold for the one-step sum: the hypothesis is invariant under surgeries that change the conclusion.

You can watch this happen in the third panel of the laboratory above: sabotage the map at the powers of two or the perfect squares and the curve does not move; sabotage a third of all inputs and it jumps. That is the boundary between density zero and positive density, drawn in real time.

---

## 8. Verify everything yourself

The full numerical audit — branch splitting, the certified error bound, the resonance comb, the zero-frequency peak, the discriminator, the mean-square identity, the blindness experiment, and a probe of the conjectural second-order term — runs in a few seconds with no dependencies:

{{demo:0}}

The evaluation routine it relies on exploits the even/odd split to halve the work, and returns the *proved* bound alongside the measured error so you can check the inequality yourself:

{{algorithm:0}}

And the resonance machinery, in exact rational arithmetic:

{{algorithm:1}}

---

## 9. Where the information is hiding

The one-step spectrum is a closed book: leading term a cosine, zeros an arithmetic progression, dynamics invisible. Two refinements escape the obstruction, and both are sharp enough to state as conjectures.

<details>
<summary><b>Conjecture 1: the $\log N$ term is a genuine invariant</b></summary>

Expand the odd branch: $e(\omega/n) = 1 + 2\pi i \omega/n + O(\omega^2/n^2)$, and $\sum_{n \le N,\, n \text{ odd}} 1/n = \tfrac12\log N + O(1)$. This predicts

$$F_a(\omega,N) - N A_a(\omega) - c(a,\omega)\log N \quad \text{converges}, \qquad c(a,\omega) = \pi i\,\omega\,e(a\omega).$$

The point: the leading term crushes the multiplier into a modulus that is a single cosine, whereas $c(a,\omega)$ carries the branch phase $e(a\omega)$ *undamped* and is linear in $\omega$. The subleading spectrum strictly sees more than the leading one. Numerically the convergence is slow (an $O(1/\log N)$ correction), which is exactly what the last section of the demo shows.
</details>

<details>
<summary><b>Conjecture 2: iterated transforms are not blind</b></summary>

For $m$ steps, define $F^{(m)}_a(\omega,N) = \sum_{n \le N} e\bigl(\omega\, T_a^m(n)/n\bigr)$. One expects convergence of $F^{(m)}_a(\omega,N)/N$ to a finite combination $\sum_j 2^{-m}\mu_j\,e(\omega r_j)$, where the $r_j$ are the limiting $m$-step ratios $a^k/2^{\,m-k}$ ($k$ = number of odd steps) and $\mu_j$ counts the residue classes mod $2^m$ following that parity pattern.

One step gives two branches, hence a cosine, hence a lattice-coset zero set encoding only the integer $2a-1$. Two steps give four branches with unequal weights, and a weighted sum of four unit vectors has a zero set that is a genuine algebraic condition in $\omega$ — not a lattice coset. That is precisely the regime in which the blindness obstruction no longer applies, because higher iterates depend on residues to higher powers of $2$, and their statistics are no longer invariant under sparse surgery in the same trivial way.
</details>

---

## 10. The moral

There is a genre of result that consists of drawing an exact boundary around what a method can do, and this is one. Before spending years proving cancellation bounds for a proposed pseudorandomness statistic, do two cheap things: **compute its normalized limit** (if the phase has finitely many accumulation points, the limit is an explicit finite trigonometric sum and there is nothing to prove), and **test it for invariance under density-zero surgery** (if it is invariant, it cannot imply anything about finite orbit data).

The song of $3n+1$, at this frequency, is a pure tone. To hear the dynamics you have to listen to the overtones.
