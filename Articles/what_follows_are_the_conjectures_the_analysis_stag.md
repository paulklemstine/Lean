# The Ruler That Never Repeats

## How to place marks so that no two gaps are ever the same — and what happens when you bend the ruler into a circle

Imagine you are designing a ruler, but a strange one. Instead of engraving a mark at every millimetre, you are allowed only a handful of marks, and you must obey a single rule:

> **No two pairs of marks may be the same distance apart.**

If marks sit at positions $0$, $1$, $4$, $9$ and $11$, then the distances you can read off are
$$1,\; 4,\; 9,\; 11,\; 3,\; 8,\; 10,\; 5,\; 7,\; 2,$$
ten distances, all different. Such a ruler is called **perfect** in the sense that every pair of its marks measures something new; no measurement is wasted on a duplicate. Combinatorialists call the underlying set a **Sidon set**, after the Hungarian analyst Simon Sidon, who ran into these sets in the 1930s while studying Fourier series and asked Paul Erdős whether large ones existed. Erdős was hooked for the rest of his life.

The question is deceptively simple and quantitatively brutal:

> **If your ruler is $N$ units long, how many marks can you fit?**

Not many. That is the whole story, and the story has a beautiful shape.

---

## Why you run out of room so fast

Start with the counting. Suppose your marks are $k$ numbers inside $\{0, 1, \dots, N-1\}$. Order the pairs: there are $k(k-1)$ *ordered* pairs of distinct marks, and each pair produces a difference $a - b$. The no-repeats rule says all of these $k(k-1)$ differences are distinct. But every one of them is a nonzero integer strictly between $-N$ and $N$, and there are only $2N - 2$ such integers. Hence

$$k(k-1) \;\le\; 2N - 2.$$

Solving, the number of marks satisfies
$$k \;\le\; \sqrt{2N} + 1 .$$

That is it — three lines, and the ceiling is $\sqrt{2N}$. It is worth pausing on the mechanism, because it recurs everywhere in this subject. The Sidon condition is not really a statement about sums; it is a statement that a certain map is **injective**. Once a map is injective, its source cannot be bigger than its target, and you have a bound. Every upper bound in this article is that one idea, wearing a different hat.

The genuinely hard direction is the other one: can you actually *achieve* roughly $\sqrt{N}$ marks, or does some hidden obstruction force you down to, say, $N^{1/3}$?

---

## Erdős and Turán's trick: hide a quadratic in the digits

In 1941 Erdős and Turán found a construction so clean it feels like a magic trick. Fix an odd prime $p$. For each $k$ with $0 \le k < p$, place a mark at

$$a_k \;=\; 2pk \;+\; (k^2 \bmod p).$$

That is $p$ marks, all inside $\{0, 1, \dots, 2p^2 - 1\}$. Setting $N = 2p^2$, the number of marks is $p = \sqrt{N/2}$ — the right order of magnitude. The claim is that these marks form a perfect ruler.

Why does it work? Read the numbers in **base $2p$**. Since $k < p$ and $k^2 \bmod p < p$, the number $a_k$ has exactly two base-$2p$ digits: the high digit is $k$, the low digit is $k^2 \bmod p$. So the construction is a filing system. The high digit stores $k$ itself; the low digit stores $k^2$, folded modulo $p$.

Now suppose two pairs of marks have the same sum:
$$a_{k_1} + a_{k_2} \;=\; a_{k_3} + a_{k_4}.$$
Adding two of these numbers, the low digits can sum to at most $2(p-1) < 2p$, so **there is no carry**. The base-$2p$ digits of the two sides must therefore match separately, giving two equations at once:

$$k_1 + k_2 = k_3 + k_4, \qquad (k_1^2 \bmod p) + (k_2^2 \bmod p) = (k_3^2 \bmod p) + (k_4^2 \bmod p).$$

Read the second one modulo $p$ and it becomes $k_1^2 + k_2^2 \equiv k_3^2 + k_4^2$. So in the field $\mathbb{Z}/p\mathbb{Z}$, the two pairs $\{k_1, k_2\}$ and $\{k_3, k_4\}$ have the same sum *and* the same sum of squares.

Here is the punchline, an observation going back to Newton and Viète:

> **Rigidity of power sums.** In any field where $2 \ne 0$, if $x_1 + x_2 = x_3 + x_4$ and $x_1^2 + x_2^2 = x_3^2 + x_4^2$, then $\{x_1, x_2\} = \{x_3, x_4\}$.

The proof is a one-liner: $2x_1x_2 = (x_1+x_2)^2 - (x_1^2 + x_2^2)$, so the two pairs also share the same *product*; hence they are the two roots of the same monic quadratic $t^2 - st + q$, and a quadratic has at most two roots. Concretely, $(x_1 - x_3)(x_1 - x_4) = x_1^2 - (x_3+x_4)x_1 + x_3x_4 = 0$.

So the pairs coincide modulo $p$, and since all the $k$'s lie in $\{0, \dots, p-1\}$, they coincide on the nose. The marks are a perfect ruler.

Two hypotheses are load-bearing and both are visible in the argument. We need $\mathbb{Z}/p\mathbb{Z}$ to be a **field** — for composite moduli a quadratic can have more than two roots, and the construction collapses (at "$p = 4$" the set $\{0, 9, 16, 25\}$ has $0 + 25 = 9 + 16$). And we need $2 \ne 0$, which is why $p$ must be odd.

---

## The sandwich

Combining the construction with the counting bound, and using **Bertrand's postulate** (there is always a prime between $m$ and $2m$) to find a prime of the right size for an arbitrary $N$, one gets a clean two-sided estimate. For every $N \ge 32$, the maximum number of marks on a ruler of length $N$, call it $F(N)$, satisfies

$$\sqrt{N/8} \;<\; F(N) \;\le\; \sqrt{2N} + 1 .$$

Ceiling and floor differ only by an absolute constant factor of $4$: the answer is $\Theta(\sqrt{N})$, and the truth — a much finer result, unattainable by these elementary means — is that $F(N)/\sqrt{N} \to 1$.

There is a second, entirely different route to the ceiling, and it is worth a detour because it links this problem to a famous chapter of graph theory. Build a bipartite graph with two copies of the ambient group, joining $x$ on the left to $y$ on the right whenever $y - x$ belongs to your set of marks. The Sidon condition says exactly: **any two vertices have at most one common neighbour**, i.e. the graph contains no four-cycle. And the maximum number of edges in a $C_4$-free bipartite graph is the subject of the Kővári–Sós–Turán theorem, whose double-counting proof — count "cherries", paths of length two, in two ways — hands back the same bound $k(k-1) \le N - 1$. Even better, the correspondence is an exact dictionary: a four-cycle in the graph *is* a coincidence $a + b = c + d$ in disguise, so

> a set of marks is a perfect ruler **if and only if** its incidence graph contains no four-cycle.

Additive combinatorics and extremal graph theory turn out to be describing the same object in two languages.

---

## Sums, differences, and the perfect case

Two exact counts make the "no waste" slogan precise. If $A$ is any set of $k$ numbers, its sumset $A + A$ can have at most $\binom{k+1}{2}$ elements, because it is the image of the $\binom{k+1}{2}$ unordered pairs. A set is a perfect ruler exactly when that bound is attained:

$$|A + A| \;=\; \binom{|A|+1}{2}.$$

Similarly the difference set is as large as it could be:

$$|A - A| \;=\; |A|^2 - |A| + 1$$

for a nonempty perfect ruler — the $|A|(|A|-1)$ distinct nonzero differences, plus $0$.

Now bend the ruler into a circle: work in $\mathbb{Z}/N\mathbb{Z}$, where distances wrap around. The counting bound becomes $k(k-1) \le N - 1$, and one can ask when it is attained *exactly*. Such an extremal object is a **perfect difference set**: every nonzero residue is a difference of two marks in exactly one way. Rigidity says something pleasant here — for a Sidon set, "the differences exhaust the group" and "the count $|A|^2 - |A| = N - 1$" are literally the same condition, so verifying perfection reduces to arithmetic. And the group order is then forced:

$$N \;=\; k^2 - k + 1 .$$

These objects exist. The set $\{0, 1, 3, 9\}$ inside $\mathbb{Z}/13\mathbb{Z}$ has $4 \cdot 3 = 12$ differences, and $13 = 4^2 - 4 + 1$: every one of the twelve nonzero residues appears exactly once. (Try it: $1-0=1$, $3-1=2$, $3-0=3$, $0-9=4$, $9-3=6$, and so on.) This is the point set of a line in the projective plane of order $3$, spun around by a Singer cycle — a hint of a much larger theory.

---

## The new question: does perfection survive the bend?

Everything so far concerns rulers laid out straight, on an interval of integers. But the Erdős–Turán marks live in $\{0, \dots, 2p^2 - 1\}$, and their natural home is the circle $\mathbb{Z}/2p^2\mathbb{Z}$ of exactly that circumference. On a circle, sums wrap. Two pairs of marks whose sums differ by exactly $2p^2$ — a full turn — become indistinguishable. Nothing in the straight-line argument protects against this.

You might expect the property to break, and there is a general reason to expect it. There is a safe regime: **a perfect ruler of length $n$ stays perfect on any circle of circumference $N \ge 2n$**, because then all pairwise sums are honestly below $N$ and no wrap can occur. That transfer principle is elementary and useful, but it demands twice the room. For the Erdős–Turán set, $n = 2p^2$, so the safe modulus is $4p^2$ — twice what we would like. At modulus exactly $2p^2$ we are in the danger zone.

**The finding of this work is that at modulus exactly $2p^2$, nothing breaks.**

> **Theorem (cyclic Erdős–Turán).** For every odd prime $p$, the marks $\{2pk + (k^2 \bmod p) : 0 \le k < p\}$ form a perfect ruler *on the circle of circumference $2p^2$*: if two pairs of marks have congruent sums modulo $2p^2$, the pairs are equal.

And the reason is not luck; it is the same rigidity, biting one level deeper. Any two pairwise sums lie in $[0, 4p^2)$, so if two of them are congruent modulo $2p^2$, they either coincide (which is the straight-line case, already settled) or differ by *exactly one full turn*, $2p^2$. Look at what a full turn does in base $2p$: since $2p^2 = (2p) \cdot p$, adding $2p^2$ increments the **high digit by exactly $p$** and leaves the low digit alone. So the wrapped case forces

$$k_3 + k_4 = k_1 + k_2 + p, \qquad (k_1^2 \bmod p) + (k_2^2 \bmod p) = (k_3^2 \bmod p) + (k_4^2 \bmod p).$$

But now run the *same* Vieta argument on those two equations. Modulo $p$, the shift by $p$ is invisible: $k_3 + k_4 \equiv k_1 + k_2$, and the squares still match. Rigidity therefore concludes $\{k_1, k_2\} = \{k_3, k_4\}$ **as actual integers** in $\{0,\dots,p-1\}$ — which flatly contradicts $k_3 + k_4 = k_1 + k_2 + p$, since $p > 0$. The wrapped case is impossible. The circle is safe.

The moral is arithmetic, not accidental. The modulus $2p^2$ is exactly $p$ times the base $2p$; a full turn is therefore a *clean digit shift*, and the construction's rigidity pins the high digit down to the nose, so a clean digit shift cannot hide. Change the modulus slightly and the alignment is destroyed: direct computation shows that for $p = 3, 5, 7, 11, 13$ the set is perfect modulo $2p^2$ but **fails** modulo $2p^2 + 1$. Perfection on a circle is genuinely a stronger property than perfection on a line, and $2p^2$ is exactly where it stops holding.

The immediate payoff: the circle of circumference $N = 2p^2$ carries a perfect ruler with $p = \sqrt{N/2}$ marks, while no perfect ruler there can exceed $\sqrt{N} + 1$ marks. The two bounds differ by a factor of only $\sqrt{2}$ — a remarkably tight sandwich for a construction this explicit.

Combining with the transfer principle and Bertrand's postulate again gives the general statement:

> **Theorem (cyclic sandwich).** For every $N \ge 64$, the largest perfect ruler on the circle of circumference $N$ has more than $\sqrt{N/16}$ marks and at most $\sqrt{N} + 1$ marks.

So cyclic groups are no worse than intervals: both realise $\Theta(\sqrt{N})$, and the two theories agree up to an absolute constant.

---

## What perfection is *not*

It is tempting, having got the Erdős–Turán set onto its own circle, to hope it is a perfect difference set there — the extremal object that hits every residue once. It is not, and one can see why in a single line. Its differences number $p^2 - p$, while the circle has $2p^2 - 1$ nonzero residues; for $p \ge 2$ these are never equal. Indeed the order constraint forbids it outright: a circle carrying a perfect difference set must have circumference $k^2 - k + 1$, an odd number, whereas $2p^2$ is even. The extremal objects require a different, deeper construction — Singer's, built from the multiplicative structure of the field $\mathbb{F}_{q^3}$ — and finding them for all prime powers, together with proving that no other orders occur, remains one of the enduring open problems of combinatorial design theory.

Two structural facts round out the picture, and they matter for anyone trying to classify these objects. Perfection is **affine-invariant**: translating a set, or multiplying it by an invertible scalar, changes neither its sums nor its coincidences. So perfect rulers come in orbits, and one may always normalise a mark to sit at the origin.

---

## Why anyone cares

The abstract question — how to space marks so no two gaps repeat — is the mathematical core of a surprising range of engineering problems.

**Radio astronomy.** The Very Large Array and its descendants place antennas so that each pair samples a distinct baseline. A pair of antennas at distance $d$ measures one Fourier coefficient of the sky; duplicated distances measure the same coefficient twice and waste an antenna. Optimal arrays are, near enough, perfect rulers.

**Radar and sonar.** A pulse train whose firing times form a perfect ruler has an autocorrelation function that is flat away from zero: no spurious echo can be mistaken for a real one, because no pair of pulses is spaced like another. The same idea produces Costas arrays for frequency-hopping.

**Error-correcting codes and cryptography.** Perfect difference sets in $\mathbb{Z}/(q^2+q+1)\mathbb{Z}$ generate the classical projective codes and the incidence structures of finite projective planes; the same $\{0,1,3,9\}$ appearing above is the seed of a code and a plane at once.

**X-ray imaging.** Coded-aperture masks — the pinhole-camera trick for hard X-rays, where lenses do not exist — use perfect difference sets so that the shadow cast by the mask can be deconvolved exactly.

In every case, the reason the sets are useful is the reason they are rare: a perfect ruler is a maximally *non-redundant* object, and non-redundancy is precisely what a measuring instrument wants and what a counting argument punishes.

---

## The shape of the argument

Step back and the whole edifice rests on a single tension. A perfect ruler is defined by an injectivity — the map "unordered pair $\mapsto$ its sum" must not collapse. Injectivity is easy to *destroy* and hard to *build*.

Counting destroys it: $k(k-1)$ differences cannot fit into $2N$ slots, so $k \lesssim \sqrt{2N}$.

Algebra builds it: a quadratic has two roots, so power sums determine unordered pairs, so hiding $k$ and $k^2$ in two different digits of the same number manufactures the injectivity for free.

And the new observation is that the algebra builds it more robustly than the counting suggests. The rigidity is strong enough to survive the wrap-around of the circle, because a full turn happens to be a clean digit shift and the rigidity pins the digits exactly. Fold the ruler into a loop at exactly the right circumference and it stays perfect. Fold it at a circumference one unit larger and it does not.

That is the kind of sharpness that makes a construction feel less like an artefact and more like a discovery.
