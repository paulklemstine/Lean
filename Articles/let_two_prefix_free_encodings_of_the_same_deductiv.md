# The Shape of What Can Be Proved

## Counting theorems, and what survives when you change the alphabet

Imagine every mathematical statement written out as a finite string of symbols. Fix an alphabet of $k$ letters — say $k = 2$ for the bits of a computer, or $k = 128$ for the printable characters of a keyboard — and sort all statements by length. Statements of length at most $n$ form a finite "ball" around the origin of a strange metric space whose points are sentences and whose distance is measured in characters. The ball has

$$S_k(n) \;=\; \sum_{i=0}^{n} k^i \;=\; \frac{k^{n+1}-1}{k-1}$$

points in it, growing like $k^n$. Inside that ball, some statements are theorems of your favourite deductive system — provable from its axioms — and most are not. Write $N(n)$ for the number of derivable statements of length at most $n$. The **derivability density**

$$d(n) \;=\; \frac{N(n)}{S_k(n)}$$

is the fraction of the ball occupied by theorems.

Almost every deductive system anyone cares about is *sparse*: $d(n) \to 0$. Provable sentences are a vanishing minority. That single number, the limiting density, is the crudest possible summary of a proof system's size, and it is the starting point for a much richer geometry. This article is about that geometry: what happens to it when you change the way statements are written down, what a "phase transition" between provable and unprovable looks like, why zero density hides a whole continuum of finer invariants, and where the power laws that people keep reporting in empirical proof data could possibly come from.

## The recoding problem

Here is the awkward fact that starts everything. The density $d(n)$ is not a property of the deductive system. It is a property of the system *plus the encoding*. Rename your symbols, switch from ASCII to a compressed binary format, add a two-byte header, and every length changes. Does anything survive?

The right notion of "the same up to encoding" is a **bounded recoding**. Two prefix-free encodings of the same deductive system translate into one another with an additive length overhead of at most $b$: every statement written with cost $\ell$ in the first encoding can be rewritten with cost at most $\ell + b$ in the second, and vice versa. Injectivity of the translation immediately gives the ball comparison

$$N_1(n) \le N_2(n+b), \qquad N_2(n) \le N_1(n+b) \qquad \text{for all } n .$$

That is: *a bounded recoding shifts balls radially by at most $b$*. Geometrically it is a quasi-isometry of the sentence space with additive constant $b$ and multiplicative constant $1$ — the tamest possible distortion.

The obvious conjecture writes itself. Define the **level-$\varepsilon$ critical index** $c(\varepsilon)$ to be the last cutoff at which the density is still at least $\varepsilon$ — the radius at which the proof space "thins out" below the level $\varepsilon$. If recoding only shifts balls by $b$, surely the two critical indices differ by at most $b$? The threshold should *move*, not *disappear*.

**That conjecture is false**, and understanding exactly why is the heart of the matter.

## Radii are stable; levels are not

Two observables *do* survive, and they survive cleanly.

The first is the **count radius**. Instead of asking "how dense is the ball of radius $n$?", ask the dual question: "how big must the radius be before I have counted $m$ theorems?" Formally $r(m) = \min\{n : N(n) \ge m\}$. This is a radius, and radii are exactly what a radial shift controls:

> **Radial Quasi-Invariance Theorem.** If two counting functions satisfy $N_1(n) \le N_2(n+b)$ and $N_2(n) \le N_1(n+b)$ for all $n$, then their count radii satisfy $|r_1(m) - r_2(m)| \le b$ for every $m$.

The proof is three lines: $N_1$ reaches $m$ at radius $r_1(m)$, hence $N_2$ reaches $m$ by radius $r_1(m) + b$, hence $r_2(m) \le r_1(m) + b$; symmetrise.

The second survivor is the **growth rate**, or entropy dimension,

$$h \;=\; \lim_{n \to \infty} \frac{\log N(n)}{n},$$

the exponential rate at which theorems accumulate. Here the invariance is not approximate but exact:

> **Invariance of the Entropy Dimension.** If two counts with $N_i(n) \ge 1$ are related by a bounded recoding and both growth rates exist, they are equal.

Again the reason is transparent: shifting the argument by a constant $b$ divides by $n$ into oblivion, since $\log N(n+b)/n = \big(\log N(n+b)/(n+b)\big)\cdot\big((n+b)/n\big)$ and the second factor tends to $1$.

So why does the density level fail? Because *the ambient volume moves too*. A radial shift of $b$ multiplies the denominator: the exact identity

$$S_k(n+b) \;=\; (1 + k + \cdots + k^{b-1}) + k^{b}\, S_k(n)$$

gives the clean bound $S_k(n+b) \le 2k^{b} S_k(n)$, and therefore the **density distortion law**

$$d_1(n) \;\le\; 2k^{b}\, d_2(n+b).$$

A recoding acts *additively on radii* but *multiplicatively on levels*, with a factor $2k^b$ that is exponential in the overhead. That is the whole story in one sentence. The correct statement about critical indices is not an inequality between indices at the same level, but a **sandwich across levels**: the level-$\varepsilon$ critical index of the first system is trapped between the level-$2k^b\varepsilon$ and level-$\varepsilon/(2k^b)$ critical indices of the second, each shifted by $b$.

And the level rescaling cannot be dropped. Consider the two decay profiles

$$p(n) = \frac{1}{n+1}, \qquad q(n) = \frac{1}{2n+2} = \tfrac12 p(n).$$

Both are decreasing, both tend to zero, and they satisfy exactly the distortion inequalities that an overhead-$1$ recoding of a binary language produces: $p(n) \le 4q(n+1)$ and $q(n) \le 4p(n+1)$. Yet at the level $\varepsilon = 1/(2D+2)$, the first profile is still above $\varepsilon$ out to radius $2D+1$ while the second has already dropped below it after radius $D$. The same-level critical indices differ by $D+1$, and $D$ is arbitrary.

> **Unbounded Critical-Index Gap.** For every $D$ there is a pair of decreasing null profiles satisfying the overhead-$1$ binary distortion inequalities whose level-$\varepsilon$ critical indices differ by at least $D$.

The moral is sharp: when the density decays slowly — polynomially, say — a *bounded* multiplicative distortion drags a *fixed* level arbitrarily far along the radial axis. Slowly decaying thresholds are infinitely fragile.

## Restoring the threshold: exponential order

If slow decay is the enemy, fast decay should be the cure. Suppose the theorem counts have **exact exponential order** $a$: constants $0 < c \le C$ with

$$c\,a^{n} \;\le\; N(n) \;\le\; C\,a^{n}, \qquad a < k .$$

The condition $a < k$ says the theorems are exponentially sparse in the ambient language; this is the interesting regime for any real calculus. Then the density is squeezed between two multiples of $(a/k)^n$, which decays geometrically, and a fixed multiplicative distortion of the level costs only a *bounded* number of radial steps: exactly $\log(\text{factor})/\log(k/a)$ steps.

> **Uniform Transition-Window Theorem.** Under exact exponential order with $a < k$, for every level $\varepsilon > 0$, if the density at radius $n_+$ is still at least $\varepsilon$ and the density at radius $n_-$ has already fallen below $\varepsilon$, then
> $$n_+ - n_- \;\le\; \frac{\log(2C/c)}{\log(k/a)} .$$
> The bound does not depend on $\varepsilon$.

This is a genuine phase-transition statement. The window in which the proof space passes from "$\varepsilon$-thick" to "$\varepsilon$-thin" has a width bounded by a constant determined only by the *shape* of the counting law, not by where you set the bar. Push $\varepsilon$ down by a factor of a million and the transition just slides outward; it does not smear.

The cross-system version of the same estimate — apply the upper bound to one encoding and the lower bound to the other — gives the corrected form of the conjecture we started with:

> **Corrected Quasi-Invariance.** If two encodings of a system have counts of the same exact exponential order $c a^n \le N_i(n) \le C a^n$ with $a < k$, then their level-$\varepsilon$ critical indices satisfy
> $$|c_1(\varepsilon) - c_2(\varepsilon)| \;\le\; \frac{\log(2C/c)}{\log(k/a)} + 1,$$
> uniformly in $\varepsilon$.

And a bounded recoding is harmless for this hypothesis: an overhead-$b$ recoding turns constants $(c, C)$ into $(c/a^b,\, Ca^b)$, so exponential order is a property of the *system*, not of the writing. Threshold stability was never about the overhead $b$; it was about whether the counting law has an honest exponential rate.

There remains one gap: a growth rate $\log N(n)/n \to \log a$ does **not** by itself give the two-sided bound $c a^n \le N(n) \le C a^n$. Growth rates are blind to subexponential oscillation, and oscillation is precisely what destroys a sharp finite crossing. The missing ingredient is a structural one, and it is the natural one for a deductive calculus: **submultiplicativity**. If theorems can be concatenated — if a derivation of length $m+n$ decomposes, up to a bounded bookkeeping factor $P$, into a derivation of length $m$ and one of length $n$ — then $N(m+n) \le P\,N(m)N(n)$. Fekete's subadditive lemma then does more than produce the limit; it produces the *matching lower bound*:

> **Fekete Bound for Derivability Counts.** If $N(n) \ge 1$ and $N(m+n) \le P\,N(m)\,N(n)$ with $P \ge 1$, then $\log N(n)/n$ converges to a limit $L$, and moreover $e^{Ln} \le P\,N(n)$ for every $n$.

Combined with any matching exponential upper bound $N(n) \le C (e^{L})^{n}$, this yields an unconditional, level-independent window of width $\log(2CP)/\log(k/e^{L})$. Submultiplicativity is exactly the hypothesis that suppresses the invisible oscillations.

## Beyond a single number: a spectrum of dimensions

Sparsity is a blunt instrument. Every interesting theorem family has density zero, so "density zero" tells you nothing about which family you are looking at. But the growth rate does.

Call $h$ the **entropy dimension** of a family of derivable statements if its cumulative count satisfies $\log N(n)/n \to h$. The ambient language has dimension $\log k$. The claim is that everything in between is genuinely occupied.

Take $N_h(n) = \lceil e^{hn} \rceil$. Since $e^{hn} \le N_h(n) < e^{hn} + 1 \le 2e^{hn}$, dividing logarithms by $n$ squeezes the rate between $h$ and $h + \log 2 / n$, so:

> **Realization of the Spectrum.** For every $h \in [0, \log k]$ there is a subfamily of the $k$-letter language with entropy dimension exactly $h$; and whenever $e^{h} < k$ its ambient density tends to $0$.

A continuum of distinct dimensions, all invisible to the provable/unprovable ratio. The spectrum also has algebra. For unions, the logarithm of a sum is the maximum of the logarithms up to $\log 2$, and $\log 2/n \to 0$:

> **Union Law.** If two strata have dimensions $h_1$ and $h_2$, their union has dimension $\max(h_1, h_2)$.

Intersections are more interesting. Say two strata meet **independently** in the counting sense if
$$|A \cap B|_{\le n}\cdot S_k(n) \;=\; |A|_{\le n}\cdot|B|_{\le n},$$
the exact discrete analogue of $\mathbb{P}(A\cap B) = \mathbb{P}(A)\mathbb{P}(B)$. Taking logarithms and dividing by $n$ turns this identity into an additive one:

> **Strict Dimension Drop.** Independent strata of dimensions $h_1, h_2$ intersect in a stratum of dimension $h_1 + h_2 - \log k$. If both are proper ($h_i < \log k$), this is strictly smaller than $\min(h_1, h_2)$.

That is codimension additivity, exactly as for transversal subvarieties or for independent fractals: the codimensions $\log k - h_i$ add. Theorem families behave like geometric objects of a definite dimension, and independence behaves like transversality.

## Where power laws come from

Empirical studies of theorem databases, proof lengths, and formula sizes routinely report heavy-tailed, power-law-like distributions. Can a single proof regime produce one? No — and the reason is a one-line computation.

Model a proof regime of entropy parameter $s > 0$ by the geometric length tail $T_s(x) = e^{-sx}$: the probability that a random theorem is longer than $x$. Then the successive ratio is *constant*:

$$\frac{T_s(x+1)}{T_s(x)} = e^{-s} \quad \text{for all } x.$$

Constant ratio means geometric decay, which is not a power law, ever. So if power laws are real, they cannot come from one homogeneous proof space. The natural alternative is **heterogeneity**: real mathematics is not one regime but a mixture of regimes — easy corollaries, routine lemmas, deep theorems — each with its own entropy parameter. Mix uniformly over $s \in [0,1]$:

$$T(x) \;=\; \int_0^1 e^{-xs}\,ds .$$

The integral is elementary and exact:

> **Closed Form of the Mixed Tail.** For $x > 0$, $\;T(x) = \dfrac{1 - e^{-x}}{x}$.

Everything follows from this formula. Since $1 - e^{-1} \le 1 - e^{-x} \le 1$ for $x \ge 1$,

> **Exact Power-Law Bounds.** $\dfrac{1 - e^{-1}}{x} \le T(x) \le \dfrac{1}{x}$ for all $x \ge 1$,

and more precisely $x\,T(x) \to 1$: the tail is *regularly varying of index $-1$*, an exact power law with exponent one. The successive ratio, the diagnostic that pinned down the single-regime case, now behaves completely differently:

> **The Mixture Is Not Geometric.** $T(x+1)/T(x) \to 1$, and no bound of the form $T(n) \le C a^n$ with $a < 1$ can hold for all large $n$.

The ratio climbing to $1$ instead of sitting at a constant $e^{-s} < 1$ is the observable signature that separates a mixture from a single regime — and it is measurable from data. The exponent, meanwhile, is dictated entirely by the mixing law near zero entropy: the near-zero regimes have almost-flat tails and dominate at large lengths. A uniform mixing density gives exponent $1$; a mixing density behaving like $s^{\alpha - 1}$ near zero should give exponent $\alpha$. Heterogeneity in difficulty, not any single notion of hardness, is the mechanism.

## What it adds up to

Three lessons, each with a precise statement behind it.

**First, choose invariant observables.** Count radii and entropy dimensions are stable under any bounded change of encoding; density levels are not, and their failure is not a technicality but a structural mismatch between additive radial distortion and multiplicative volume distortion.

**Second, sharp thresholds need exponential order, and exponential order needs structure.** A proof space whose theorem counts have a genuine two-sided exponential law has transition windows of a width fixed once and for all, independent of the level. Submultiplicativity — the ability to concatenate proofs at bounded cost — is precisely the structural hypothesis that upgrades a growth rate into that two-sided law.

**Third, a single ratio is not enough.** Behind the uninformative statement "the theorems have density zero" sits a full spectrum of dimensions, closed under unions by a maximum law and dropping strictly at independent intersections; and behind reported power laws in proof-length data sits not one regime but a scale mixture of them, whose signature — successive ratios tending to $1$ — is checkable.

There is something pleasing about the picture. A deductive system, stripped to its counting data, behaves like a fractal subset of a Cantor-like space of strings: it has a dimension, dimensions add in codimension when independent families meet, and it has a boundary layer of bounded thickness where it thins out. The theorems you can prove occupy a shape, and the shape — unlike the alphabet you happen to write it in — is real.
