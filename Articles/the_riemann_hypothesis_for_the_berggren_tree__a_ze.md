# The Silver Tree: Hunting a Riemann Hypothesis Among the Pythagorean Triples

## A tree that grows every right triangle

Everyone meets $3^2 + 4^2 = 5^2$ in school. Fewer people meet the astonishing fact that
*every* right triangle with whole-number sides can be grown from that one, like a plant
from a single seed, by a completely mechanical rule.

Call a triple $(a,b,c)$ of positive integers with $a^2 + b^2 = c^2$ *primitive* if $a$, $b$
and $c$ share no common factor — so $(3,4,5)$ counts, but $(6,8,10)$ does not. In 1934 the
Swedish mathematician B. Berggren discovered that the primitive triples form a perfect
ternary tree. Start at $(3,4,5)$ and apply the three matrices

$$
A_1=\begin{pmatrix}1&-2&2\\ 2&-1&2\\ 2&-2&3\end{pmatrix},\qquad
A_2=\begin{pmatrix}1&2&2\\ 2&1&2\\ 2&2&3\end{pmatrix},\qquad
A_3=\begin{pmatrix}-1&2&2\\ -2&1&2\\ -2&2&3\end{pmatrix}
$$

to the column vector $(a,b,c)^{\mathsf T}$. Each matrix sends a primitive triple to another
primitive triple; every primitive triple appears exactly once; and the path from the root
to a given triple is unique. The triples are not a scattered dust of arithmetic accidents.
They are the vertices of an infinite, perfectly regular, three-branched tree.

From $(3,4,5)$ the first generation is $(5,12,13)$, $(21,20,29)$, $(15,8,17)$. The second
generation has nine members, the third twenty-seven, and so on: $3^d$ triples at depth $d$,
forever.

The question this article is about is what happens when you try to do *analysis* on this
tree — when you take the number-theorist's favourite instrument, a zeta function, and point
it at the Pythagorean triples.

## Why a zeta function?

The Riemann zeta function
$$\zeta(s)=\sum_{n=1}^{\infty} n^{-s}$$
is the master key of analytic number theory. Its behaviour as a function of a complex
variable $s$ encodes, with uncanny precision, how the prime numbers are spread out among
the integers. The Riemann Hypothesis — the assertion that all its non-trivial zeros lie on
the single vertical line $\operatorname{Re} s = 1/2$ — is the most famous unsolved problem
in mathematics, precisely because that one line controls the error term in the Prime Number
Theorem.

The recipe generalises. Given any interesting infinite family of objects with a notion of
size, form the Dirichlet series $\sum (\text{size})^{-s}$ and study where it converges,
where it can be continued, and where it has poles and zeros. For graphs and trees this
produces the Ihara zeta functions; for dynamical systems, the Ruelle zeta; for geometry,
the Selberg zeta. In every case, one number is decisive: the *abscissa of convergence*, the
real number $\sigma_c$ such that the series converges for $\operatorname{Re} s > \sigma_c$
and diverges to its left.

So: build the zeta function of the Berggren tree, using the hypotenuse as the size,
$$Z_{\mathrm{tree}}(s) \;=\; \sum_{w} c(w)^{-s},$$
where $w$ runs over all finite words in the three letters $L$, $M$, $R$ — that is, over all
nodes of the tree — and $c(w)$ is the hypotenuse of the triple sitting at that node. Where
does it converge? Can it be continued? Where are its poles? Is there a critical line?

## The silver ratio enters

There is a compelling reason to expect an exotic answer. The Berggren matrices are not
arbitrary; their arithmetic is governed by the ring $\mathbb{Z}[\sqrt 2]$. The middle
matrix $A_2$ is hyperbolic with eigenvalues
$$3 \pm 2\sqrt 2 = (1\pm\sqrt 2)^2 ,$$
the squares of the *silver ratio* $\varepsilon = 1 + \sqrt 2$, the fundamental unit of
$\mathbb{Z}[\sqrt 2]$. The silver ratio is to the Pell equation $x^2-2y^2=\pm 1$ what the
golden ratio is to the Fibonacci numbers. Repeatedly applying the middle move multiplies
the hypotenuse by roughly $3+2\sqrt 2 \approx 5.828$ each time: $5, 29, 169, 985, 5741,
\dots$, the Pell numbers' close relatives.

Here is the heuristic that makes the whole subject tempting. If the tree branches by a
factor of $3$ at every step, and the size grows by a factor of $\varepsilon^2$ at every
step, then the number of nodes of size $\le H$ should be about $H^{\sigma_0}$ with
$$\sigma_0 \;=\; \frac{\log 3}{2\log(1+\sqrt 2)} \;=\; 0.6232\ldots,$$
and the zeta function should have abscissa exactly $\sigma_0$. This is the standard
"entropy over Lyapunov exponent" formula. Call $\sigma_0$ the **silver abscissa**. The
moonshot conjecture is that $\sigma_0$ is the critical line of a Pythagorean Riemann
Hypothesis.

The story that follows is what happens when you check.

## Coordinates that make everything computable

The first move is to stop thinking about triples and start thinking about their *Euclid
parameters*. Every primitive triple is $(m^2-n^2,\, 2mn,\, m^2+n^2)$ for a unique pair
$(m,n)$ with $m > n \ge 1$, $\gcd(m,n)=1$ and $m+n$ odd. Call such a pair an *admissible
seed*. In these coordinates the three Berggren matrices become breathtakingly simple:

$$L(m,n) = (2m-n,\ m),\qquad M(m,n) = (2m+n,\ m),\qquad R(m,n) = (m+2n,\ n),$$

and the hypotenuse is just $c = m^2+n^2$. The root is $(m,n) = (2,1)$.

The first structural theorem says these coordinates lose nothing:

> **Theorem (Seed bijection).** The map sending a word $w$ in $\{L,M,R\}^*$ to the seed
> reached by applying its letters to $(2,1)$ is a bijection from the set of all finite
> words onto the set of admissible seeds $\{(m,n) : n<m,\ n\ge 1,\ \gcd(m,n)=1,\ m+n \text{
> odd}\}$.

Surjectivity is Berggren's completeness theorem: given any admissible seed other than the
root, exactly one of the three moves can be undone within the admissible set, and the
undoing strictly shrinks $m$, so descending must terminate at $(2,1)$. Injectivity is the
uniqueness half: the three moves have disjoint images, which one can see from a simple
"window" criterion — $L$ produces seeds with $m > 2n$ *and* a further inequality, $M$
produces $m>2n$ of a different flavour, $R$ produces $m<2n$ — and each move is individually
invertible.

The consequence is that the tree zeta function is *literally* a Dirichlet series over
admissible seeds:
$$Z_{\mathrm{tree}}(s)=\sum_{\substack{n<m,\ \gcd(m,n)=1\\ m+n \text{ odd}}} (m^2+n^2)^{-s}.$$

## The conjecture is false — and the reason is beautiful

Once the series is written in seed coordinates, its abscissa is decided by a two-line
comparison rather than by dynamics.

> **Theorem (Abscissa).** $\sum_w c(w)^{-s}$ converges if and only if $s > 1$.

Upper bound: the admissible seeds live inside the quarter-plane lattice, so the series is
dominated by $\sum_{m>n\ge 1}(m^2+n^2)^{-s}$, which is a two-dimensional lattice sum in a
plane and converges precisely when $2s > 2$, i.e. $s>1$. Lower bound: for divergence at
$s \le 1$, one exhibits an explicit fat family of seeds. For every prime $q$ and every odd
$n<q$, the pair $(2q, n)$ is admissible, and its hypotenuse is at most $5q^2$; summing over
the roughly $q/2$ allowed $n$'s gives a contribution of order $1/q$ to the series, and
$\sum_q 1/q$ over primes diverges. So the series blows up at $s=1$, and a fortiori below.

**The abscissa is $1$, not $\sigma_0 = 0.6232$.** At $s=\sigma_0$, and even at the other
natural silver candidate $\log(1+\sqrt2)=0.8814$, the series diverges. The moonshot is
refuted.

But refutations in mathematics are only as good as the mechanism they expose, and here the
mechanism is sharp. The silver speed limit is genuinely true:

> **Theorem (Silver speed limit).** For every word $w$ of length $k$,
> $$c(w) \le 5\,(3+2\sqrt 2)^{k}.$$
> Moreover the pure-middle spine $MM\cdots M$ attains it: at depth $k$ its hypotenuse lies
> between $4(3+2\sqrt2)^k$ and $5(3+2\sqrt2)^k$.

No node can outrun the silver ratio. The proof is a one-step quadratic inequality — for
instance, applying $M$ replaces $m^2+n^2$ by $(2m+n)^2+m^2$, and one checks
$(2m+n)^2+m^2 \le (3+2\sqrt2)(m^2+n^2)$ for all real $m,n$, because the difference is a
positive multiple of $(\sqrt2\,m - (1+\sqrt2)n)^2$ — followed by induction on the length of
the word.

The catch is the other two branches. Compute the outer spines explicitly:

$$c(\underbrace{L\cdots L}_{k}) = 2k^2+6k+5, \qquad c(\underbrace{R\cdots R}_{k}) = 4k^2+8k+5 .$$

The left spine runs through $5, 13, 25, 41, 61,\dots$ and the right spine through
$5, 17, 37, 65, 101,\dots$ — the triples $(2k+3, 2k^2+6k+4, 2k^2+6k+5)$ and
$(4k+3, 4k^2+8k+4, 4k^2+8k+5)$. These grow **quadratically**, not exponentially. The
matrices $A_1$ and $A_3$ are hyperbolic as linear maps, but the spines they generate are
*parabolic in effect*: along them, the tree crawls.

That is the whole story of the failure. The heuristic "size $\approx \varepsilon^{2\,\text{depth}}$"
is true along the middle, and wildly false along the edges. A tree that is exponentially
deep but only polynomially tall in most directions has far too many small nodes, and small
nodes are exactly what makes a Dirichlet series diverge.

The counting function makes the gap quantitative. Let $N(H)$ be the number of nodes with
hypotenuse at most $H$.

> **Theorem (Counting).** $N(H) \le (\lfloor\sqrt H\rfloor + 1)^2$, so $N(H) = O(H)$; and
> for $H\ge 5$, $$N(H)\ \ge\ \tfrac13\Big(\tfrac{H}{5}\Big)^{\sigma_0}.$$

The upper bound is immediate from the seed bijection: a node with $m^2+n^2\le H$ has both
parameters in $[0,\sqrt H]$, so the nodes inject into a square box of side
$\lfloor\sqrt H\rfloor+1$. The lower bound is the silver speed limit read backwards: if
$5(3+2\sqrt2)^d \le H$ then *all* $3^d$ nodes of depth $d$ are below $H$, and optimising $d$
gives the stated power of $H$. Actual counts:

| $H$ | $N(H)$ | upper bound $(\lfloor\sqrt H\rfloor+1)^2$ | silver lower bound $3^d$ |
|---|---|---|---|
| $5$ | $1$ | $9$ | $1$ |
| $50$ | $7$ | $64$ | $3$ |
| $200$ | $32$ | $225$ | $9$ |
| $1000$ | $158$ | $1024$ | $27$ |

The truth grows essentially linearly, sandwiched strictly between $H^{0.6232}$ and $H$. The
silver exponent is a real lower growth exponent — but not the true one.

## Where the critical line does live

Here is where the story turns from refutation to construction. The silver heuristic failed
because it confused two gradings of the tree: the *depth* $|w|$ and the *height* $c(w)$.
Everything silver is a statement about depth. So grade the tree by depth and see what
analytic object appears.

Give every node of depth $k$ the same idealised size $\varepsilon^{2k}$ — the exact silver
speed limit, stripped of constants — and form
$$Z_{\varepsilon}(s) \;=\; \sum_{k\ge 0} 3^{k}\,\varepsilon^{-2ks} \;=\; \frac{1}{1 - 3\,\varepsilon^{-2s}},
\qquad \varepsilon = 1+\sqrt 2 .$$
This is an Ihara-type zeta function: $3$ for the branching, $\varepsilon^{2}$ for the
silver growth per step. The geometric series converges exactly when
$|3\varepsilon^{-2s}|<1$, that is when $\operatorname{Re} s > \sigma_0$ — the silver
abscissa reappears, now in its correct home. And the closed form
$(1-3\varepsilon^{-2s})^{-1}$ is defined on *all* of $\mathbb C$: the continuation is free.

Now the punchline.

> **Critical Line Theorem.** $Z_\varepsilon$ is meromorphic on the whole complex plane, and
> its set of poles is *exactly*
> $$\Big\{\,s : \operatorname{Re} s = \sigma_0 = \frac{\log 3}{2\log(1+\sqrt2)},\quad
> \operatorname{Im} s \in \frac{\pi}{\log(1+\sqrt2)}\,\mathbb{Z} \,\Big\}.$$

Every singularity lies on one vertical line, at equally spaced heights $3.5644\ldots$ apart.
The proof is a single exponential computation: writing
$\varepsilon^{-2s}=\exp(-2s\log\varepsilon)$, the denominator vanishes iff
$\exp(-2s\log\varepsilon) = \exp(-\log 3)$, and two exponentials agree iff their arguments
differ by an integer multiple of $2\pi i$. Splitting into real and imaginary parts gives
$-2\sigma\log\varepsilon = -\log 3$ — that is, $\sigma = \sigma_0$, with *no freedom at
all* — and $-2t\log\varepsilon = 2\pi k$, giving the arithmetic progression of heights.

This is a genuine, provable analogue of the Riemann Hypothesis: a naturally-arising
Dirichlet series attached to a number-theoretic object, all of whose singularities sit on a
single critical line whose position, $\sigma_0$, is dictated by the units $3\pm 2\sqrt2$ of
$\mathbb Z[\sqrt 2]$. It is exactly solvable, and that is the point: it exhibits the
*mechanism* — branching entropy over expansion rate — in a case where you can see all the
way to the bottom.

Three further facts complete the picture, and each has a recognisable Riemann-zeta
counterpart:

- **No zeros.** $Z_\varepsilon$ never vanishes away from its poles: it is the reciprocal of
  an entire function, so a zero would force $1/0$. The polar divisor is the entire divisor.
- **A functional equation.** $Z_\varepsilon\!\left(s + \tfrac{i\pi}{\log \varepsilon}\right) = Z_\varepsilon(s)$
  for all $s$. Riemann's zeta has a reflection $s\mapsto 1-s$; the silver zeta has an exact
  vertical periodicity, with period equal to the pole spacing.
- **Uniform simple residues.** Every pole is simple, and at *every* pole $s_0$,
  $$\lim_{s\to s_0}(s-s_0)\,Z_\varepsilon(s) \;=\; \frac{1}{2\log(1+\sqrt2)} \;=\; 0.56728\ldots$$
  The same constant, at every one of the infinitely many poles. In the Riemann setting the
  residue at $s=1$ controls the leading term of the Prime Number Theorem; here the constant
  $1/(2\log\varepsilon)$ is precisely the density of the depth grading, $1$ node-generation
  per $2\log\varepsilon$ of logarithmic size.

## The primes on the tree

What about the prime side of the analogy — the "prime hypotenuses" the moonshot asked
about? Here the answer is complete and surprisingly clean.

> **Theorem.** Every hypotenuse in the Berggren tree satisfies $c \equiv 1 \pmod 4$. A prime
> $p$ occurs as a hypotenuse of some node if and only if $p \equiv 1 \pmod 4$; and
> infinitely many nodes carry a prime hypotenuse.

The congruence is elementary: in a seed $(m,n)$ exactly one of $m,n$ is even, so
$m^2+n^2 \equiv 1 \pmod 4$ always. The converse is Fermat's two-square theorem: a prime
$p \equiv 1 \pmod 4$ is $m^2+n^2$ for some $m>n\ge1$, and such an $m,n$ are automatically
coprime and of opposite parity — hence an admissible seed, hence (by the bijection) a node.
Infinitude then follows from Dirichlet's theorem on the progression $1 \bmod 4$.

So the "prime nodes" of the Berggren tree are a perfect copy of the primes
$p \equiv 1 \pmod 4$ — the split primes of the Gaussian integers $\mathbb{Z}[i]$. Their
Dirichlet series $\sum_{c(w)\text{ prime}} c(w)^{-s}$ converges for $s>1$ (dominated by the
full tree zeta) and dominates $\sum_{p\equiv 1(4)} p^{-s}$, which diverges as $s\to 1^+$
like $\tfrac12\log\frac{1}{s-1}$. The prime hypotenuses are exactly as dense as
Gaussian-split primes, no more and no less: the tree does not distort prime distribution,
it faithfully transports it.

## Restoring the silver law by removing the parabolic directions

If the outer spines are the villains, what happens if we simply refuse to travel along
them?

Consider the free binary subtree generated by the two *blocks* $MM$ and $MR$ — two-letter
words, each containing the expanding Pell move $M$. Distinct bit strings give distinct
nodes, so this is a genuine binary tree sitting inside the ternary one. Every block
multiplies the hypotenuse by at least $5/2$, and the silver speed limit caps it at
$(3+2\sqrt2)^2$ per block. Hence for a bit string of length $d$,
$$5\left(\tfrac52\right)^{d} \;\le\; c \;\le\; 5\,(3+2\sqrt2)^{2d}.$$

> **Theorem (Hyperbolic subtree).** The subtree zeta $\sum_{\text{bit strings}} c^{-s}$
> converges for $s > \dfrac{\log 2}{\log(5/2)} = 0.7565\ldots$ and diverges for
> $0 < s < \dfrac{\log 2}{\log((3+2\sqrt2)^2)} = 0.1966\ldots$. In particular it converges
> at $s=1$, where the full tree zeta diverges.

The abscissa of this subtree is trapped in $[0.197,\,0.757] \subset (0,1)$: strictly less
than $1$, in the silver regime, exactly as the "entropy over expansion" heuristic predicts
once every generator is genuinely expanding. The heuristic was never wrong about
hyperbolicity; it was wrong about the tree, because two thirds of the tree is parabolic in
practice.

## What the tree teaches

The moral is compact, and it generalises far beyond Pythagoras:

**The silver unit governs the depth grading of the Berggren tree, not its height grading.**

Every statement about $|w|$ that involves $1+\sqrt2$ survives: the speed limit, the Pell
spine's exact rate, the depth-graded zeta and its critical line, the counting lower bound.
Every statement that tried to transport a depth fact to the variable $c(w)$ failed: the
abscissa, the counting exponent, the location of the true singularity. The reason is a
dichotomy inside the tree itself — one exponential direction and two polynomial ones — and
once you excise the polynomial directions, the silver law returns.

There is something instructive here about the Riemann Hypothesis itself. The reason
$Z_\varepsilon$ has a provable critical line is that its "primes" all have exactly the same
length: every step of the depth grading costs precisely $2\log\varepsilon$. A zeta function
built from equal-length primes is a geometric series, and a geometric series has its poles
lined up in a perfect vertical row. Riemann's zeta, by contrast, is built from primes whose
logarithms are hopelessly irregular, and it is precisely that irregularity — the failure of
the lengths to be commensurable — that makes the alignment of its zeros a mystery rather
than a computation.

The Berggren tree gives us both halves of that lesson in one object. Grade it by depth and
you get an exactly solvable Riemann Hypothesis, critical line at $\log 3 / (2\log(1+\sqrt
2))$, poles simple and evenly spaced, residues all equal. Grade it by hypotenuse and you
get the real thing: a Dirichlet series with abscissa $1$ whose prime nodes are exactly the
primes $p\equiv 1\pmod 4$, and whose fine structure is as hard as anything in analytic
number theory. The distance between those two zeta functions — the distance between
$0.6232$ and $1$ — is the distance between a model of the Riemann Hypothesis and the
Riemann Hypothesis.

Which, for a tree that starts at a $3$-$4$-$5$ triangle, is a remarkable amount of
mathematics to be carrying.
