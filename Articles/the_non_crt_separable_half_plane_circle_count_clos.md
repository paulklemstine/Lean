# A Circle That Refuses to Talk

## What a modular circle knows about the number it lives on, and what it will never say

### The circle that isn't round

Draw the unit circle. You get the familiar smooth curve, the set of all points $(x,y)$ in the plane with $x^2 + y^2 = 1$.

Now do the same thing inside clock arithmetic. Fix a modulus $N$, let $x$ and $y$ range over the integers $0, 1, \dots, N-1$, and keep only the pairs for which

$$x^2 + y^2 \equiv 1 \pmod N.$$

What you get is not a curve at all. It is a scatter of dots — a **modular circle** — and it is one of the most quietly informative objects in elementary number theory. For $N = 15$ there are exactly $16$ such points. For $N = 35$ there are $32$. For $N = 105$ there are $128$. Call this count $C(N)$.

The first surprise is how rigid $C(N)$ is. It does not wobble. It obeys a formula so clean that you can write it down from the prime factorisation of $N$ and never touch a single point of the circle:

$$C(N) \;=\; \prod_{p \mid N} p^{\,v_p(N)-1}\bigl(p - \chi_p(-1)\bigr), \qquad N \text{ odd},$$

where $v_p(N)$ is the exponent of $p$ in $N$, and $\chi_p(-1)$ is $+1$ when $p \equiv 1 \pmod 4$ and $-1$ when $p \equiv 3 \pmod 4$. So the local factor is $p-1$ for primes one more than a multiple of four, and $p+1$ for primes three more. Check it: $15 = 3 \cdot 5$ gives $(3+1)(5-1) = 16$. And $105 = 3 \cdot 5 \cdot 7$ gives $(3+1)(5-1)(7+1) = 128$. Exactly right, every time.

This is the property number theorists call **separability**: the global count is the product of independent local counts, one per prime. The circle modulo $15$ is, for counting purposes, just the circle modulo $3$ crossed with the circle modulo $5$. The Chinese Remainder Theorem glues them together and the count multiplies.

Separability is the great simplifier — and, from a certain point of view, the great disappointment. If you already know how $N$ factors, $C(N)$ tells you nothing new. And if you *don't* know how $N$ factors, then $C(N)$ would be spectacularly useful, but you cannot get at it: the only way to compute it without the factorisation is to walk the circle point by point, which takes about $N$ steps — astronomically many when $N$ has hundreds of digits.

This article is about what happens when you deliberately break the separability, and about the strange, disciplined way the circle refuses to reward you for it.

### Cutting the circle where it doesn't want to be cut

The reason $C(N)$ factors so cleanly is that the defining condition $x^2 + y^2 \equiv 1$ is *congruence-only*: it can be checked one prime at a time. So the obvious way to escape is to impose a condition that cannot be checked one prime at a time.

Here is the simplest such condition imaginable. Take the representatives $x, y \in \{0, 1, \dots, N-1\}$ as honest *integers*, add them as integers, and ask whether the sum lands in the lower half:

$$x + y < \tfrac{N}{2}.$$

That inequality is a genuinely global constraint. There is no way to test it by looking at $x$ and $y$ modulo $3$ and modulo $5$ separately: the Chinese Remainder Theorem is a ring isomorphism, and it emphatically does not preserve the ordering of representatives. Define

$$H(N) \;=\; \#\bigl\{(x,y) : x^2 + y^2 \equiv 1 \!\!\pmod N,\; 2(x+y) < N \bigr\}.$$

Does $H$ separate? No — and one small example settles it. At $N = 35 = 5 \cdot 7$ we have $H(35) = 6$, while $H(5) \cdot H(7) = 2 \cdot 2 = 4$. At $N = 33 = 3 \cdot 11$ the mismatch is worse: $H(33) = 8$ against $H(3) \cdot H(11) = 4$. The half-plane count is not a product of local factors, full stop.

So we have escaped the classification. We have an arithmetic quantity attached to $N$ that is provably *not* determined by any collection of independent per-prime computations. If a quantity has to see all the primes of $N$ at once, maybe — the hope goes — it carries information about how those primes fit together. Maybe it is a *hint*.

This article is the story of chasing that hint down and watching it evaporate, in a way precise enough to prove.

### The circle's hidden symmetries

Before we can measure what $H(N)$ knows, we need to understand what it is. And $H$ turns out to be governed with almost military discipline by the symmetries of the modular circle.

The circle is invariant under sign flips: if $x^2 + y^2 \equiv 1$, then replacing $x$ by $N - x$ or $y$ by $N - y$ leaves the congruence intact, since $(N-x)^2 \equiv x^2$. Together these two flips and their composite generate a group of four symmetries — and if you also allow the swap $(x,y) \mapsto (y,x)$, eight. Every structural fact below is one of these symmetries, cashed in.

**The reflection identity.** Look at the corner *opposite* the low half-plane: the points with $x + y > \tfrac{3N}{2}$, meaning both coordinates are large. Call that count $\mathrm{high}(N)$. The antipodal map $(x,y) \mapsto (N-x, N-y)$ carries the low corner exactly onto the high corner — except that it cannot handle points sitting on a coordinate axis, where a coordinate is $0$ and $N - 0 = N$ falls out of range. Those axis points are precisely the pairs $(0, u)$ and $(u, 0)$ with $u^2 \equiv 1 \pmod N$ and $u < N/2$. Writing $R(N)$ for the number of such small square roots of unity, we get the exact identity, valid for every $N \ge 2$:

$$H(N) \;=\; \mathrm{high}(N) \;+\; 2R(N).$$

**The correction term is separable after all.** How big is $R(N)$? Pair each square root of $1$ with its negative, $u \leftrightarrow N - u$. This pairing has no fixed point once $N \ge 3$: a root with $2u = N$ would have to divide $u^2 - 1$ and $u^2$ simultaneously, forcing $u = 1$ and $N = 2$. So exactly half the square roots of unity lie below $N/2$, and $2R(N) = S(N)$, where $S(N)$ counts *all* square roots of $1$ modulo $N$. And $S$ *is* separable — it is a product of local factors, essentially $2^{\omega(N)}$ for odd $N$.

Combine these: all of the non-separability of $H$ has been squeezed into the single quantity $\mathrm{high}(N)$. The messy part of the problem now has a name and a home.

**The quadrant bound.** How large can that corner be? Apply the four sign-flip symmetries to it. Each image lands in a different quadrant of the box $[0,N)^2$ — the original has both coordinates above $N/2$, the antipodal image has both below, and the two mixed flips have one of each — so the four copies are pairwise disjoint and all sit inside the circle. Therefore

$$4\,\mathrm{high}(N) \;\le\; C(N),$$

and hence $4H(N) \le C(N) + 4S(N)$: the half-plane count is at most about a quarter of the circle count. The constant $4$ cannot be improved to $8$; at $N = 9$ one has $\mathrm{high}(9) = 2$ and $C(9) = 12 < 16$.

**Parity is local.** Finally, use the swap $(x,y) \mapsto (y,x)$, which preserves the half-plane condition since $x+y$ is symmetric. It pairs off every low point with its mirror image, except the ones on the diagonal $x = y$. On the diagonal, $x^2 + y^2 \equiv 1$ becomes $2x^2 \equiv 1$. So

$$H(N) \;\equiv\; \#\{x : 2x^2 \equiv 1 \!\!\pmod N,\; 4x < N\} \pmod 2.$$

The parity of the non-separable count is decided entirely by the square roots of $1/2$ — a perfectly local, per-prime question. The last bit of $H(N)$, the one bit an adversary would grab first, has already surrendered. For $N < 80$ the only moduli with $H(N)$ odd are $17, 31, 49, 71, 73$ — and in each case there is exactly one small diagonal witness, e.g. $x = 3$ for $N = 17$, since $2 \cdot 9 = 18 \equiv 1 \pmod{17}$.

### Weighing the hint

Now the measurement. The half-plane occupies one-eighth of the square $[0,N)^2$ — it is the triangle below the anti-diagonal $x + y = N/2$, area $N^2/8$. If the circle's points were spread uniformly, we would expect

$$H(N) \;\approx\; \frac{C(N)}{8}.$$

Empirically, they are. Across a full enumeration of every modulus from $15$ up past $60{,}000$, the ratio $8H(N)/C(N)$ hugs $1$: averaged over odd squarefree $N$ in $[1000, 3000)$ it is $1.0078$, and it keeps drifting down towards $1$ as $N$ grows.

But $C(N)/8$ is *separable*. It is built from the local factors $p - \chi_p(-1)$ and nothing else. So the entire hope for a hint rests on the deviation

$$\varepsilon(N) \;=\; H(N) - \frac{C(N)}{8}.$$

And here comes the honest part of the story, in two beats.

**Beat one: the deviation is real, and it does depend on the factorisation.** This is not a rounding artefact. Take a narrow band of moduli near $N \approx 57{,}000$, all with essentially the same size, and vary only how they factor:

| $N$ | factorisation | $C(N)$ | $C(N)/8$ | $H(N)$ | $\varepsilon(N)$ |
|---|---|---|---|---|---|
| $56801$ | $79 \cdot 719$ | $57600$ | $7200$ | $7118$ | $-82$ |
| $56803$ | $43 \cdot 1321$ | $58080$ | $7260$ | $7262$ | $+2$ |
| $56819$ | $7 \cdot 8117$ | $64928$ | $8116$ | $8218$ | $+102$ |
| $56839$ | $113 \cdot 503$ | $56448$ | $7056$ | $7148$ | $+92$ |
| $56851$ | $139 \cdot 409$ | $57120$ | $7140$ | $7026$ | $-114$ |

Same neighbourhood, wildly different $\varepsilon$. Whatever $\varepsilon$ is, it is not a function of $N$ alone; it feels the primes. Formally, the half-plane cut has produced a quantity outside the separable classification, exactly as designed.

**Beat two: the deviation is the size of noise.** Across that band the total spread of $\varepsilon$ is $292$, which is about $1.2\sqrt{N}$, while the dominant term $C(N)/8$ is around $7{,}200$. The signal is around $4\%$ of the quantity being measured at $N \approx 57{,}000$, and — because it scales like $\sqrt{N}$ against a main term of size $N$ — that percentage shrinks like $1/\sqrt{N}$. At cryptographic sizes it is not $4\%$; it is $10^{-150}$ of the total.

Worse, the fluctuation looks structureless. Test $\varepsilon$ against every natural coordinate of the factorisation — the smaller prime $p$, the larger prime $q$, the sum $p+q$, the gap $|p-q|$ — and the correlations come out indistinguishable from what you get by randomly reshuffling the labels. Every permutation test passes: the observed association statistics top out around $0.19$, against a $95$th-percentile null threshold near $0.36$. The deviation knows about the factorisation, in the sense that it changes when the factorisation changes; but it does not *encode* the factorisation in any coordinate you would think to read.

There is a good theoretical reason to expect exactly this. The corner count $\mathrm{high}(N)$ is a lattice-point count in a triangle cut out of a conic — and counts of that shape are controlled by incomplete exponential sums attached to the conic, of Kloosterman/Salié type. Weil's bound gives such sums square-root cancellation. The prediction is that $|8H(N) - C(N)|$ is $O(N^{1/2+\epsilon})$ for odd squarefree $N$, and that is precisely what the data shows.

### Why this matters

Here is the shape of the disappointment, stated positively, because it is a theorem-shaped disappointment and those are the useful kind.

Suppose you want to learn something about the factorisation of a large $N$ by computing some natural arithmetic statistic of a modular object attached to it. There is a classification of the well-behaved statistics — the separable ones, the ones that split as products over the primes. Those are useless in the intended sense: computing them *requires* the factorisation you were trying to find, or else an enumeration costing $\Theta(N)$ steps.

The natural move is to step outside the classification, and the half-plane cut is about as clean a way to do it as exists. What we now know, in this case completely, is:

1. **The bulk is separable anyway.** The dominant term of $H(N)$ is $C(N)/8$, and $C$ is a product of local factors. Crossing the boundary did not move the main term across it.
2. **The parity is separable too.** The mod-$2$ information in $H(N)$ is exactly the count of square roots of $1/2$ below $N/4$ — again purely local.
3. **The genuinely new information lives at the square-root floor.** It is real, it is provably non-separable, and it is of size $O(\sqrt{N})$ against a main term of size $N$, with no correlation to any of the obvious factorisation coordinates.
4. **You cannot get it cheaply.** Computing $H(N)$ still requires walking the circle: $\Theta(N)$ operations.

That last point deserves its own remark, because the separable side *does* have teeth when you can afford it. For a **Blum-type semiprime** $N = pq$ with $p \equiv q \equiv 3 \pmod 4$, the circle count is exactly

$$C(N) = N + p + q + 1,$$

so a single evaluation of $C(N)$ hands you $p + q = C(N) - N - 1$, and then $p$ and $q$ are the two roots of the quadratic $X^2 - (C(N)-N-1)X + N$. The factorisation is *there*, in one number, completely and unambiguously. And it is unreachable, because the only route to $C(N)$ without the factorisation is an $N$-step enumeration — exponential in the number of digits. It is a bank vault with a glass door.

The half-plane cut was an attempt to find a side entrance. It did produce a genuinely new, non-classified quantity. And the quantity turned out to be aggregation-sealed: the sum over all $C(N)$ points of the circle washes out everything the individual points knew, leaving a main term that depends only on $N$'s local data and a residue at the noise floor.

The moral generalises past this one example. The seal here does not come from separability — we broke separability on purpose. It comes from *aggregation*: any statistic defined as a count over an object of size $N$, computed by summing indicator functions, inherits square-root cancellation and hides its structure underneath the main term. Escaping the classification of nice functions is easy. Escaping the noise floor is the actual problem, and it is a different problem, and nothing in this construction touches it.

### What's left

Three concrete things.

First, the square-root bound above is currently a conjecture supported by full enumeration up to $62{,}879$; the natural proof runs through an explicit evaluation of Salié sums attached to the conic, and every ingredient on the separable side is now nailed down.

Second, the congruence structure. The parity result is a Burnside count for the swap symmetry; the full dihedral group of order eight is available, and one expects a refinement modulo $4$ in which the fixed-point strata — the axis points, of which there are $S(N)$, and the diagonal points — appear as explicit correction terms. Both strata are already understood as separable objects.

Third, the prime $2$. Everything above is clean for odd moduli, where the conic $x^2 + y^2 = 1$ is smooth and Hensel's lemma lifts solutions one prime power at a time, giving $C(p^k) = p^{k-1}(p - \chi_p(-1))$. At $p = 2$ the conic degenerates, the count jumps to $C(2^k) = 2^{k+1}$ for $k \ge 3$, and how the half-plane cut interacts with that degeneracy is genuinely open.

But the main verdict is in, and it is the kind of clean negative result that saves other people time. The modular circle knows how $N$ factors. It will tell you, if you can afford to count all of its points. Slicing it at an angle it doesn't like will not make it talk any faster.
