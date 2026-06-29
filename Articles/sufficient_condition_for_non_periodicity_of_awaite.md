# When Tiles Refuse to Repeat: The Hidden Arithmetic of Aperiodic Patterns

## A puzzle that never quite closes

Imagine a bathroom floor you can tile to infinity. You have a finite kit of square tiles, each with four colored edges, and exactly one rule: wherever two tiles meet, their touching edges must share the same color. You cannot rotate or reflect the tiles — they slot in like jigsaw pieces with fixed orientation. The question is deceptively simple: starting from this kit, can you cover the entire infinite plane?

For most tile kits the answer is dull. Either you get stuck (no tiling exists), or you find a tiling that simply repeats — copy a single rectangular block and stamp it across the plane like wallpaper. A pattern that repeats this way is called *periodic*: there is a direction and a distance such that shifting the whole picture by that amount leaves it unchanged.

But in the 1960s, the logician Hao Wang asked a question whose answer shook the foundations of tiling theory. Are there tile kits that *can* cover the plane, but *never* periodically — kits for which every valid infinite tiling is, in a precise sense, irregular forever? Wang conjectured no such kit existed. He was wrong. His student Robert Berger constructed the first *aperiodic* tile set: a finite collection of square tiles that tiles the plane, yet forbids any repeating pattern. The discovery rippled outward, eventually reaching chemistry, where physical "quasicrystals" — materials whose atoms arrange in ordered but non-repeating lattices — earned a Nobel Prize.

These tiles with colored edges are called **Wang tiles**, and the property at the heart of the story is **aperiodicity**: a tiling has *no period vector at all*, no hidden shift that maps it back onto itself.

This article is about a clean, quantitative answer to a natural follow-up question. We know irrationality can force tiles to never repeat. But irrationality is a yes-or-no property. Can we measure *how strongly* a pattern refuses to repeat? It turns out the right measuring stick is one of the oldest ideas in number theory — how badly a number can be approximated by fractions — and the cleanest examples come from the humblest irrational numbers of all: square roots like $\sqrt{2}$ and $\sqrt{3}$.

## From tiles to a number line

To see arithmetic emerge from geometry, strip the Wang tiling down to its skeleton. Consider a single real number $\alpha$ between $0$ and $1$ — think of it as a *density*. Walk along the integers $n = 0, 1, 2, 3, \dots$ and at each step ask: did the running quantity $\lfloor n\alpha \rfloor$ (the integer part of $n\alpha$) just tick up by one? Record a $1$ if it did and a $0$ if it didn't. This produces an infinite binary sequence called the **Beatty step word**:

$$d_\alpha(n) = \lfloor (n+1)\alpha \rfloor - \lfloor n\alpha \rfloor.$$

Each entry is either $0$ or $1$, and the $1$'s appear with long-run frequency exactly $\alpha$. If $\alpha = 1/2$, you get the perfectly periodic word $0,1,0,1,0,1,\dots$. If $\alpha = 1/3$, you get $0,0,1,0,0,1,\dots$ repeating with period $3$. In general, when $\alpha$ is a fraction $a/b$ in lowest terms, the word repeats with period exactly $b$ — clockwork regularity.

Now make a stripe pattern in two dimensions. Use one density $\alpha$ to place *vertical* stripes and another density $\beta$ to place *horizontal* stripes. Overlaying them produces a two-dimensional pattern $W(\alpha,\beta)$ — the "Wang stripe set." It is exactly the kind of skeleton that lives inside genuine aperiodic Wang tilings: the colors of the edges encode where the next stripe must fall, and a valid edge-matching tiling traces out precisely these Beatty words in each direction.

Here is the crucial bridge between the geometry and the arithmetic:

> **The stripe pattern $W(\alpha,\beta)$ has a repeating period if and only if at least one of the step words $d_\alpha$, $d_\beta$ repeats.**

And a Beatty step word repeats *exactly when its density is a fraction*. So:

> **If $\alpha$ and $\beta$ are both irrational, the pattern $W(\alpha,\beta)$ has no period vector whatsoever — it is strongly aperiodic.**

This is the qualitative heart of the matter. Irrationality of the two densities is enough to forbid every possible repetition, in every possible direction, forever. A tiling forced by irrational densities is doomed to wander.

## Irrational is not enough — measure the rebellion

Saying "$\alpha$ is irrational" tells you the word never *exactly* repeats. But it doesn't tell you how close the pattern comes to repeating. Some irrational numbers are "almost rational": they can be approximated by fractions astonishingly well, so the pattern they generate looks nearly periodic over enormous stretches before the illusion breaks. Others hold fractions at arm's length, and the patterns they generate are jagged and unpredictable at every scale.

The classical way to measure this is **Diophantine approximation** — the study of how well real numbers can be hugged by fractions. We say a number $\alpha$ is **Diophantine** (of exponent $2$, the sharpest interesting case) if there is a positive constant $c$ such that *every* fraction $a/b$ stays a guaranteed distance away:

$$\left| \alpha - \frac{a}{b} \right| \;\ge\; \frac{c}{b^2} \qquad \text{for all integers } a \text{ and all } b \ge 1.$$

Read this carefully. It says you can never sneak a fraction with denominator $b$ closer to $\alpha$ than $c/b^2$. The denominator $b$ measures how "expensive" the fraction is; the bound says cheap fractions stay far away and only expensive ones can get close, at a strictly controlled rate. Such a number is **badly approximable**. It is the mathematician's way of saying $\alpha$ stubbornly refuses to be mistaken for any fraction.

The first thing to notice is a free consequence:

> **Every Diophantine number is irrational.**

The reasoning is almost a one-liner. If $\alpha$ were the fraction $p/q$, then plugging $a/b = p/q$ into the inequality would demand $0 = |\alpha - p/q| \ge c/q^2 > 0$, an outright contradiction. A rational number is *hit exactly* by one of the competing fractions, which violates any positive lower bound. So the Diophantine condition is a strict strengthening of irrationality: it not only forbids exact hits, it quantifies the near-misses.

This single observation already slots into the tiling story. Diophantine $\alpha$ implies irrational $\alpha$; two irrational densities imply a strongly aperiodic stripe pattern. So **a Diophantine pair of densities certifies aperiodicity** — with a number you can actually compute attached, telling you the minimum "resolution" at which the pattern can pretend to repeat.

## The square roots win the day

Which numbers are Diophantine? The most beautiful examples are the **quadratic irrationals** — square roots of whole numbers that aren't perfect squares, like $\sqrt{2}, \sqrt{3}, \sqrt{5}, \dots$. They are, in a precise sense, the *most* badly approximable numbers there are. And the proof that they are Diophantine is a small gem of elementary algebra.

Take $\alpha = \sqrt{d}$ where $d$ is not a perfect square, and pit it against any fraction $a/b$. The trick is to multiply by the "conjugate." Watch:

$$\left| \sqrt{d} - \frac{a}{b} \right| \cdot \left| \sqrt{d} + \frac{a}{b} \right| = \left| d - \frac{a^2}{b^2} \right| = \frac{|d\,b^2 - a^2|}{b^2}.$$

Now stare at the numerator $d\,b^2 - a^2$. It is an *integer*. And because $\sqrt{d}$ is irrational, that integer can never be zero — if $d\,b^2 = a^2$ then $\sqrt{d} = a/b$ would be a fraction. A nonzero integer has absolute value at least $1$. Therefore

$$\left| \sqrt{d} - \frac{a}{b} \right| \cdot \left| \sqrt{d} + \frac{a}{b} \right| \;\ge\; \frac{1}{b^2}.$$

The product of two quantities is at least $1/b^2$; to bound the first factor from below, we only need to bound the second from above. When $a/b$ is anywhere near $\sqrt{d}$ — say within distance $1$ — the sum $\sqrt{d} + a/b$ stays below $2\sqrt{d} + 1$. Dividing gives the clean conclusion:

$$\left| \sqrt{d} - \frac{a}{b} \right| \;\ge\; \frac{1}{(2\sqrt{d}+1)}\cdot\frac{1}{b^2}.$$

So $\sqrt{d}$ is Diophantine with the explicit constant $c = \dfrac{1}{2\sqrt{d}+1}$. There is no hand-waving, no appeal to deep theory: a single "nonzero-integer can't be smaller than one" does all the work. This one constraint is the algebraic fingerprint of degree two — the signature of a quadratic irrational.

For $\sqrt{2}$ the bound sharpens to something you can carry in your pocket. The raw constant would be $1/(2\sqrt{2}+1) \approx 0.261$, but a careful look improves it to the round number $1/4$:

$$\left| \sqrt{2} - \frac{a}{b} \right| \;\ge\; \frac{1}{4 b^2} \qquad \text{for every fraction } \frac{a}{b}.$$

Try it. The famous approximation $\sqrt 2 \approx 99/70$ has denominator $70$, and the inequality promises the error is at least $1/(4\cdot 70^2) = 1/19600 \approx 0.000051$. The actual error is about $0.000072$ — comfortably above the floor, just as guaranteed. No fraction, however cleverly chosen, can ever beat the $1/(4b^2)$ barrier.

## The headline result

Chaining the pieces together gives a statement of striking economy:

> **If $\alpha$ and $\beta$ are both Diophantine, then the Wang stripe pattern $W(\alpha,\beta)$ is strongly aperiodic — it admits no period vector in any direction.**

And the simplest possible non-trivial input already triggers it:

> **The pair $(\sqrt{2}, \sqrt{3})$ produces a strongly aperiodic stripe pattern.**

Two of the most familiar irrational numbers in mathematics — the diagonal of a unit square and the diagonal of a $1\times\sqrt 2$ rectangle — are all you need to manufacture a pattern that covers the plane without ever repeating. The proof's spine is honest and transparent: Diophantine forces irrational, irrational forbids any repetition in either Beatty word, and a pattern whose two generating words never repeat can have no period vector at all.

## Why the exponent two is the soul of the story

There is a reason the exponent in $c/b^2$ is exactly $2$ and not, say, $3$. The number $2$ is the algebraic degree of a square root. The whole proof turned on a single nonzero integer $d b^2 - a^2$ being at least $1$ in size — and that quantity is *quadratic* in the denominator $b$. A cubic irrational, or one of the pathological "Liouville numbers" that can be approximated by fractions with superhuman accuracy, would break exactly this step. Liouville numbers are *not* Diophantine of exponent $2$; they can be hugged by fractions far closer than $c/b^2$ for any fixed $c$, and the stripe patterns they generate, while still aperiodic, flirt with periodicity over astronomically long ranges.

This suggests a tantalizing converse, still conjectural: the slopes for which exponent $2$ is *exactly* optimal — badly approximable, but no better — are conjectured to be precisely the quadratic irrationals. The arithmetic degree of the density would then be readable directly off the geometry of how stubbornly the tiling refuses to settle into a rhythm.

## The bigger picture

What makes this story satisfying is the unexpected dialogue between two worlds that look nothing alike. On one side is a concrete, almost childlike question about colored tiles on a floor. On the other is one of the oldest themes in number theory — the ancient Greek struggle to express $\sqrt 2$ as a ratio, which they proved impossible, and the modern refinement that measures *how* impossible.

The bridge is the Beatty step word, a tiny mechanism that translates a real number into an infinite binary rhythm. Rational densities give clockwork; irrational densities give patterns that never close the loop; and *badly approximable* densities give patterns whose refusal to repeat carries a hard, computable guarantee. The constant $c$ is not a vague reassurance — it is a number, $1/4$ in the case of $\sqrt 2$, that tells you the precise scale below which the illusion of repetition cannot survive.

Aperiodic order is everywhere once you learn to see it: in the quasicrystals on a metallurgist's bench, in the Penrose tilings on museum floors, in the spectra of certain quantum systems. Underneath the visual mystery sits a simple arithmetic truth. Some numbers are fractions, and they make things repeat. Some numbers are not fractions, and they make things wander. And the most beautifully wandering patterns of all are governed by the most ancient irrational numbers we know — the square roots that the Greeks could not tame, still untamed, now tiling the plane forever without once repeating themselves.
