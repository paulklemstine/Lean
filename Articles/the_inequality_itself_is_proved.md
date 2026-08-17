# The Energy Hidden in a Sum

## How a Fourier-analytic inequality about adding sets turns out to be one line of counting in disguise

Take a handful of numbers — say $A = \{0, 1, 3, 7\}$ — and add every element to every other,
yourself included. You get a *sumset*,
$$A + A = \{0,1,2,3,4,6,7,8,10,14\}.$$
Four numbers went in; ten came out. Could it have been fewer? Certainly: if you had started
with $\{0,1,2,3\}$ you would have got $\{0,1,2,3,4,5,6\}$, seven elements. Could it have been
just four? Only in one very rigid situation — if $A$ had been a shifted copy of a group,
closed under addition up to translation. Otherwise adding a set to itself always spreads it out.

*How much* it spreads out is the central question of additive combinatorics, and it is a
question with a physical flavour. Think of $A$ as a set of allowed states of a system —
momenta of particles, energies of levels, configurations of $n$ classical bits — and of
addition as the rule that combines two states into one. The sumset $A+A$ is then the set of
reachable outcomes, and its size measures how much *new* the interaction creates. A small
sumset means the system is trapped in a rigid arithmetic structure. A large sumset means it
explores.

This article is about a single inequality that estimates the size of $A+B$ from below, about
where its strength comes from, and about a small surprise: the sophisticated Fourier-analytic
machine that produces it and a two-line elementary count produce *exactly the same number* —
not roughly the same, not up to constants, but identically, always.

---

## Counting representations

The right object to look at is not the sumset itself but the *representation function*. Fix a
finite abelian group $G$ — for concreteness, the integers modulo $n$, or the space
$\mathbb{F}_2^n$ of binary strings under bitwise XOR — and two subsets $A, B \subseteq G$. For
each element $c$ of $G$, let
$$r_{A,B}(c) = \#\{(a,b) \in A \times B : a + b = c\}$$
be the number of ways of writing $c$ as a sum of something from $A$ and something from $B$.

Two facts about this function are immediate. First, its total mass is fixed: every pair
$(a,b)$ contributes to exactly one $c$, so
$$\sum_{c \in G} r_{A,B}(c) = |A|\,|B|.$$
Second, the set of $c$ where $r_{A,B}(c) > 0$ is precisely the sumset $A+B$. So estimating
$|A+B|$ means estimating the size of the *support* of a nonnegative function whose total mass
we know exactly.

Here is the tension. A fixed amount of mass $|A||B|$ has to be distributed somewhere. If the
function is spread thinly — every $c$ in the sumset represented in only one or two ways — the
support must be huge. If it is concentrated — a few elements represented in enormously many
ways — the support can be small. The quantity that measures concentration is the second moment,
$$\tilde{E}(A,B) = \sum_{c \in G} r_{A,B}(c)^2,$$
known as the **additive energy** of the pair $(A,B)$. Expanding the square gives it a purely
combinatorial meaning: it counts *additive quadruples*,
$$\tilde{E}(A,B) = \#\{(a,b,a',b') \in A \times B \times A \times B : a + b = a' + b'\},$$
the number of coincidences among sums. Few coincidences, low energy, big sumset. That is the
whole intuition, and the rest is bookkeeping.

The bookkeeping is Cauchy–Schwarz. For any nonnegative function, mass squared is at most
support times second moment, so
$$|A+B| \;\ge\; \frac{\bigl(\sum_c r_{A,B}(c)\bigr)^2}{\sum_c r_{A,B}(c)^2}
\;=\; \frac{(|A|\,|B|)^2}{\tilde{E}(A,B)}.$$
Call this the **second-moment bound**. It is the kind of thing one proves on a napkin.

---

## The Fourier route, and where it lands

There is a much grander way to attack the same problem, and it is the standard one. Every
function on a finite abelian group decomposes into characters — the group's own natural
oscillations, the analogue of pure tones. Writing $\widehat{1_A}(\psi) = \sum_{a \in A}
\overline{\psi(a)}$ for the transform of the indicator function of $A$, the representation
function is a convolution, and convolution becomes multiplication on the Fourier side:
$$\widehat{r_{A,B}}(\psi) = \widehat{1_A}(\psi)\,\widehat{1_B}(\psi).$$

The trivial character $\psi = 0$ contributes the *principal term* $|A|\,|B|$: the smooth,
featureless part of $r_{A,B}$, the part that would be there if the mass were spread perfectly
evenly across all of $G$. Everything else — all structure, all clumping, all arithmetic
conspiracy — is carried by the remaining characters, and its total size is what one calls the
**nonprincipal Fourier energy**
$$E \;=\; \sum_{\psi \neq 0} \bigl|\widehat{1_A}(\psi)\bigr|^2\,\bigl|\widehat{1_B}(\psi)\bigr|^2 .$$

A standard Cauchy–Schwarz argument on the Fourier side then yields a covering bound: the
support of $r_{A,B}$ — that is, the sumset — satisfies
$$|A + B| \;\ge\; \frac{|G|\,(|A|\,|B|)^2}{(|A|\,|B|)^2 + E}. \tag{$\star$}$$
Read it as a statement about competition. The numerator is the ideal case: if $E$ were zero,
the mass would be perfectly equidistributed and the sumset would be all of $G$. Each unit of
nonprincipal energy in the denominator degrades that ideal, and the inequality quantifies the
degradation. It looks like exactly the sort of estimate that only harmonic analysis can give
you.

Now apply Parseval's identity, the statement that the total energy of a function equals the
total energy of its spectrum. Applied to $r_{A,B}$ it says
$$\sum_{\psi \in \widehat{G}} \bigl|\widehat{1_A}(\psi)\bigr|^2\bigl|\widehat{1_B}(\psi)\bigr|^2
\;=\; |G| \sum_{c \in G} r_{A,B}(c)^2 \;=\; |G|\,\tilde{E}(A,B).$$
Peel off the principal character, whose contribution is $(|A||B|)^2$, and the mystery evaporates:
$$\boxed{\,E \;=\; |G|\,\tilde{E}(A,B) \;-\; (|A|\,|B|)^2\,.}$$

The nonprincipal Fourier energy is not an independent analytic quantity at all. It is the
combinatorial additive energy, rescaled and shifted. And when you substitute it back into
$(\star)$, the group order cancels and the denominators collapse:
$$\frac{|G|(|A||B|)^2}{(|A||B|)^2 + E} \;=\; \frac{|G|(|A||B|)^2}{|G|\,\tilde{E}(A,B)}
\;=\; \frac{(|A||B|)^2}{\tilde{E}(A,B)}.$$

The Fourier covering bound **is** the napkin bound. Not comparable to it — equal to it, term
for term, for every pair of nonempty sets in every finite abelian group. All the characters,
all the oscillation, all the spectral machinery: it recovers the second-moment inequality with
no loss and no gain.

This is not a criticism of Fourier analysis; it is a clarification of what the inequality is
worth and, more usefully, of how to *compute* with it. The Fourier energy $E$ of a set is, on
its face, a sum over $|G|$ characters of a quantity with no closed form. The additive energy
is a count of quadruples. Anyone who can count quadruples now knows $E$ exactly.

---

## Who wins, who ties

With the bound in combinatorial form, one can ask exactly when it is worth anything. The
benchmark to beat is the pigeonhole bound: since translating $B$ by a fixed element of $A$
embeds it in $A+B$, we always have trivially $|A+B| \ge \max(|A|,|B|)$.

For a set added to itself, the answer is a clean dichotomy. The bound $(|A|^2)^2/\tilde{E}(A,A)$
exceeds $|A|$ **exactly when $|A+A| > |A|$** — that is, for every set of strictly positive
doubling. And the sets with $|A+A| = |A|$ are, by a classical rigidity fact, precisely the
cosets of subgroups: shifted copies of a set closed under addition. So:

> **The dichotomy.** For every finite nonempty $A$, either the second-moment bound strictly
> improves on pigeonhole, or $A$ is a coset of a subgroup.

And in the exceptional case the bound is not weak — it is *exactly sharp*. If $H$ is a subgroup
of order $h$, then $r_{H,H}$ is constant equal to $h$ on $H$ and zero elsewhere, so
$\tilde{E} = h^3$, the Fourier energy is $E = |G|h^3 - h^4$, and the bound returns
$h^4/h^3 = h = |H+H|$, on the nose. Subgroups are simultaneously the equality case of the
inequality and the only obstruction to beating pigeonhole. The failure mode and the success
mode are the same configuration.

---

## Three families, three regimes

The formula $E = |G|\tilde{E} - (|A||B|)^2$ turns a spectral computation into a counting
exercise, so let us actually do it, at both ends of the spectrum of possible behaviour.

### Maximal spread: the parabola

Fix an odd prime $p$ and work in the plane $G = (\mathbb{Z}/p)^2$, which has $p^2$ elements.
Let
$$P = \{(x, x^2) : x \in \mathbb{Z}/p\}$$
be the parabola — $p$ points, one above each abscissa. The parabola is a **Sidon set**: a sum
$a+b$ of two of its points determines the unordered pair $\{a,b\}$. Geometrically, a chord's
midpoint determines its endpoints, because a line meets a conic in at most two points; the
algebra is the identity $2xy = (x+y)^2 - (x^2+y^2)$, which recovers the product of the two
abscissas from the sum, and hence recovers the pair as the roots of a known quadratic. (This is
where oddness of $p$ enters: in characteristic two the "parabola" is a line.)

For any Sidon set of size $k$, the representation function is completely determined: it equals
$1$ on the $k$ diagonal sums $a+a$, equals $2$ on the $\binom{k}{2}$ genuine chords, and
vanishes elsewhere. Therefore
$$\tilde{E}(A,A) = k \cdot 1^2 + \binom{k}{2}\cdot 2^2 = k + 2k(k-1) = 2k^2 - k .$$
For the parabola, $k = p$ and $|G| = p^2$, so the nonprincipal Fourier energy is exactly
$$E = p^2(2p^2 - p) - p^4 = p^4 - p^3,$$
and the covering bound is
$$\frac{p^3}{2p-1} \;\ge\; \frac{p^2}{2}.$$
Pigeonhole offers $p$. The bound offers about $p^2/2$: a gain of a whole power. And it is
almost exactly right, because the true sumset has $|P+P| = p(p+1)/2$ elements — the bound
underestimates by a factor of at most $1 + \tfrac{1}{2p}$.

### The cost of characteristic two: the Hamming ball

Now let $G = \mathbb{F}_2^n$, the configurations of $n$ bits under XOR, and let
$$B = \{0, e_1, \ldots, e_n\}$$
be the ball of radius one around the origin in Hamming distance: the all-zero string together
with the $n$ strings of weight one. This is the state space of a system of $n$ bits restricted
to "at most one flip".

Here something structural changes. No set in a group of exponent two can be Sidon, because
$x + x = 0$ for every $x$: the entire diagonal collapses onto a single point. The correct
notion is *Sidon off the diagonal* — distinct sums of distinct pairs — and the Hamming ball has
it: $e_i + e_j$ is the weight-two string with ones in positions $i$ and $j$, which remembers
$\{i,j\}$.

For such a set of size $k$ in exponent two, the representation function is $k$ at the origin
(the whole diagonal piled up there) and $2$ on each of the $\binom{k}{2}$ off-diagonal sums,
giving
$$\tilde{E} = k^2 + 4\binom{k}{2} = 3k^2 - 2k.$$
With $k = n+1$ and $|G| = 2^n$ the Fourier energy is
$$E = 2^n(3n^2 + 4n + 1) - (n+1)^4,$$
and the bound reads
$$\frac{(n+1)^3}{3n+1} \;\ge\; \frac{(n+1)^2}{3}.$$
Still quadratic in the size of the set — $n+1$ single-flip states already generate a sumset of
size at least about $n^2/3$, quadratically more than pigeonhole detects — but the constant has
degraded from $1/2$ to $1/3$. The reason is visible and entirely non-analytic: the collapsed
diagonal deposits $k^2$ of energy at the origin before any genuine collision occurs. Since the
true sumset is $|B+B| = 1 + \tfrac{n(n+1)}{2} \approx n^2/2$, the bound is off by a factor
tending to exactly $3/2$ — and that $3/2$ is precisely the price of characteristic two.

### Minimal spread: the interval

Both families above are as spread out as possible. What about the opposite extreme, where the
bound has no room to gain a power at all?

Take $I_k = \{0, 1, \ldots, k-1\}$ inside $\mathbb{Z}/n$ with $2k \le n$, so that nothing wraps
around. This is the canonical set of *minimal* doubling: $|I_k + I_k| = 2k - 1$, the smallest
possible for a set of size $k$ that is not a coset. One might guess a second-moment bound is
worthless here — there is only a constant factor available to win.

It is not. The representation function of an interval with itself is the familiar discrete tent,
$$r(c) = 1, 2, 3, \ldots, k-1, k, k-1, \ldots, 2, 1$$
as $c$ runs over $0, 1, \ldots, 2k-2$: exactly $\min(k, c+1) - \max(0, c+1-k)$ ways to split $c$.
Summing its squares gives the square-pyramidal number twice over, minus the apex:
$$\tilde{E}(I_k, I_k) = \frac{k(2k^2+1)}{3},$$
so $E = \tfrac{n\,k(2k^2+1)}{3} - k^4$ and the bound is
$$\frac{3k^3}{2k^2+1} \;\longrightarrow\; \frac{3k}{2}.$$
That is strictly greater than $k$ for every $k \ge 2$, so the bound beats pigeonhole even in
the regime where beating it by a power is impossible. Against the truth $2k-1$, the bound is
never tight but never worse than a factor $4/3$: its accuracy is pinned into the window
$[3/4, 1)$ for all $k$, uniformly.

Three families, three accuracies, all computed in closed form from a single formula:

| family | $\tilde{E}$ | bound | truth | accuracy |
|---|---|---|---|---|
| Sidon (parabola in $(\mathbb{Z}/p)^2$) | $2k^2-k$ | $k^3/(2k-1)$ | $k(k+1)/2$ | $\to 1$, error $\le 1+\tfrac{1}{2k}$ |
| Hamming ball in $\mathbb{F}_2^n$ | $3k^2-2k$ | $k^3/(3k-2)$ | $1+\tfrac{k(k-1)}{2}$ | $\to 2/3$ |
| interval in $\mathbb{Z}/n$ | $k(2k^2+1)/3$ | $3k^3/(2k^2+1)$ | $2k-1$ | in $[3/4, 1)$ |

(Here $k$ is the size of the set: $k=p$, $k=n+1$, $k=k$.)

---

## What to take away

Three things, in increasing order of generality.

**The identity.** Nonprincipal Fourier energy and additive energy are the same quantity in
different clothing: $E = |G|\tilde{E} - (|A||B|)^2$. This is Parseval and nothing more, but it
is the sentence that makes the Fourier bound computable, because nobody can sum $|G|$ character
sums by hand and everybody can count quadruples.

**The collapse.** Consequently the Fourier covering bound is *identically* the second-moment
bound $(\sum r)^2/(\sum r^2)$. Whenever an argument's only use of the spectrum is a single
Cauchy–Schwarz over characters, the spectrum was never doing any work: the same inequality is
available from the moments alone. This is a useful diagnostic. Genuine Fourier gains come from
using the *structure* of the spectrum — a large single coefficient, a bound on the largest
nonprincipal one, an $L^p$ estimate — not from its total mass, which is combinatorial.

**The dichotomy.** Weak as it is, the bound is not vacuous: it strictly improves on pigeonhole
for every set of positive doubling, and its only failures are cosets of subgroups, where it is
exactly correct. A bound that ties only where it is sharp is a bound with an honest boundary.

There is a physical way to say all of this. The nonprincipal energy $E$ measures how far a set
is from being spectrally featureless — how much of its mass sits in nontrivial modes. Total
modal energy, it turns out, is a coarse invariant: it sees only the number of additive
coincidences, and it cannot distinguish a set that hides all its structure in one enormous
Fourier coefficient from one that spreads the same energy over all of them. To tell those
apart, you need the shape of the spectrum, not its norm. What the collapse identity shows,
sharply and once and for all, is exactly how much you get for free from the norm alone —
and precisely which sets, the cosets, sit at the boundary where free is all there is.
