# The Hidden Shape of Adding Sets Together

## When adding makes things bigger — but how much bigger?

Take a handful of whole numbers, say $A = \{0, 3, 7\}$. Now add every element to every element of another set $B = \{0, 1\}$. You get the *sumset*

$$A + B = \{a + b : a \in A,\ b \in B\} = \{0, 1, 3, 4, 7, 8\}.$$

Three numbers plus two numbers gave six. That is the largest a sumset can ever be: at most $|A|\cdot|B|$ elements. But nature rarely lets us have the maximum. If the two sets share arithmetic structure — if they are, say, chunks of the same arithmetic progression — the sums collapse onto each other and the sumset shrinks dramatically. Add $\{0,1,2\}$ to $\{0,1,2\}$ and you get only $\{0,1,2,3,4\}$: five elements, not nine.

This tension — between the freedom that makes sumsets large and the structure that makes them small — is the beating heart of *additive combinatorics*. A century of mathematics, from the Cauchy–Davenport theorem to the modern sum-product phenomenon, has been devoted to pinning down exactly *how small* a sumset is allowed to be.

This article is about one especially clean corner of that story: what happens when your sets live not on the number line, but inside a **diamond**.

## The diamond in every dimension

Picture the set of all integer points $(x_1, \dots, x_d)$ whose coordinates, in absolute value, add up to at most $m$:

$$B_d(m) = \{x \in \mathbb{Z}^d : |x_1| + |x_2| + \cdots + |x_d| \le m\}.$$

In one dimension this is just the interval of integers from $-m$ to $m$. In two dimensions it is a diamond (a square rotated $45^\circ$). In three dimensions it is an octahedron. Mathematicians call this shape the **cross-polytope**, or the $\ell_1$ ball, and it is one of the most natural "balls" in all of geometry — the set of points within a fixed *taxicab distance* of the origin.

Now suppose we take $n$ sets $A_1, \dots, A_n$, each living inside this diamond, and add them all together. How small can the resulting sumset $A_1 + \cdots + A_n$ be, compared to the sizes of the pieces?

The cleanest way to phrase the answer is through a single number, an **exponent** $p$, in the inequality

$$|A_1 + \cdots + A_n| \;\ge\; \bigl(|A_1|\cdot|A_2|\cdots|A_n|\bigr)^{1/p}.$$

A small exponent $p$ means a *strong* lower bound: the sumset is forced to be large. A large exponent means the bound is weak and the sumset is allowed to be small. The whole game is to find the *sharpest* — the smallest possible — exponent $p$ that still makes the inequality true for every choice of sets.

## The magic number

For the integer diamond of radius $m$ with $n$ summands, the sharp exponent turns out to be a strikingly compact formula:

$$p(n,m) = \frac{n \cdot \log(m+1)}{\log(nm+1)}.$$

Where does this come from? The extremal case — the configuration that is hardest to beat, the one that makes the sumset as small as possible relative to its pieces — is the humble one-dimensional interval. Take each $A_j$ to be $\{0, 1, \dots, m\}$, a block of $m+1$ consecutive integers. Adding $n$ such blocks gives $\{0, 1, \dots, nm\}$, a block of $nm+1$ integers. Plug into the inequality: we need $(nm+1) \ge (m+1)^{n/p}$, and solving for the borderline exponent gives *exactly* $p(n,m)$ above. The logarithms are simply counting digits: $\log(m+1)$ measures the "information content" of one block, and $\log(nm+1)$ that of the sum.

The remarkable claim, supported by this work and the conjectures it points toward, is that this same exponent — born from a one-dimensional interval — governs the diamond in *every* dimension. The formula never mentions $d$. The cross-polytope is self-similar as it grows into higher dimensions, and the humble interval already knows the answer.

## Reading the surface

Once you have a formula like $p(n,m)$, a mathematician's instinct is to treat it as a *landscape* — a surface floating above the plane of all $(n, m)$ pairs — and ask how it rises and falls. This is where the present cycle of work makes its contribution. Three features of the landscape are now established with full rigor.

**First: the exponent never reaches $n$.** For any number of summands $n \ge 2$ and any radius $m \ge 1$,

$$p(n,m) < n.$$

Why does this matter? The exponent $n$ corresponds to the crudest possible bound, the one you get from the *geometric–arithmetic mean inequality* alone, without using any special geometry: $|A_1 + \cdots + A_n| \ge (|A_1|\cdots|A_n|)^{1/n}$. This trivial bound is always true but rarely sharp. The strict inequality $p(n,m) < n$ says the diamond *always* does strictly better than the trivial bound — its geometry genuinely constrains the sums. The proof is a one-line comparison of logarithms: since $m + 1 < nm + 1$, we have $\log(m+1) < \log(nm+1)$, so the ratio defining $p(n,m)/n$ is strictly below $1$.

**Second: more summands, larger exponent.** Adding one more set to the sum strictly increases the exponent:

$$p(n,m) < p(n+1, m).$$

Intuitively, each additional summand gives the sets more room to overlap and cancel, weakening the lower bound — so the exponent climbs. Proving this cleanly, however, requires an unexpectedly pretty inequality between whole numbers. After clearing the common positive factor $\log(m+1)$, the entire monotonicity statement boils down to

$$\bigl((n+1)m + 1\bigr)^n \;<\; (nm+1)^{n+1}.$$

Try it with $n = 2$, $m = 1$: the left side is $(2\cdot 1 + 1)^2 = 9$, the right side is $(1\cdot 1 + 1 + \text{…})$ — wait, let us be careful: $\bigl((2+1)\cdot 1 + 1\bigr)^2 = 4^2 = 16$ against $(2\cdot 1 + 1)^3 = 3^3 = 27$. Indeed $16 < 27$. This little inequality has a beautiful proof via **Bernoulli's inequality**. Writing $\rho = \frac{nm+1}{(n+1)m+1}$, a number just below $1$, Bernoulli tells us $\rho^n \ge 1 - n\cdot\frac{m}{(n+1)m+1} = \frac{m+1}{(n+1)m+1}$. Multiplying through, $(nm+1)\cdot\rho^n \ge \frac{(nm+1)(m+1)}{(n+1)m+1} > 1$, because $(nm+1)(m+1) = nm^2 + nm + m + 1$ genuinely exceeds $(n+1)m + 1 = nm + m + 1$. That single surplus term $nm^2$ is the whole reason more summands cost you.

**Third — and most surprising: the radius does *not* shrink the exponent.** Here intuition leads many people astray. A tempting guess is that as the diamond grows larger — as $m \to \infty$ — there is more room, more freedom, so the bound should weaken in one direction or tighten in another in a simple monotone way; a common first guess is that $p$ *decreases* with $m$. This is **false**. In fact the opposite happens: as the radius grows, the exponent *rises* toward its ceiling. Rigorously,

$$p(n, m) \longrightarrow n \quad \text{as } m \to \infty.$$

The sharp exponent degenerates, in the large-radius limit, to the trivial geometric-mean exponent $n$. And since $p(n,m)$ is always strictly *below* $n$ yet *converges* to $n$, the sequence $m \mapsto p(n,m)$ cannot possibly be decreasing — a decreasing sequence trapped below its limit could never climb up to it. This is a clean logical refutation of the natural but wrong conjecture: **the exponent surface is not decreasing in the radius; it rises toward the asymptote $n$.**

The mechanism behind the limit is a gentle squeeze. Because $m + 1 \le nm + 1 \le n(m+1)$, taking logarithms gives

$$1 \le \frac{\log(nm+1)}{\log(m+1)} \le 1 + \frac{\log n}{\log(m+1)}.$$

As $m \to \infty$, the correction term $\frac{\log n}{\log(m+1)}$ melts to zero, so the ratio is pinched to exactly $1$ — and $p(n,m) = n / \frac{\log(nm+1)}{\log(m+1)}$ slides up to $n$.

## Why any of this matters

At first glance this might look like a curiosity about counting lattice points in diamonds. But the pattern it reveals is deep and recurring. The exponent $p(n,m)$ is, at its core, a *volumetric* quantity: it is nothing more than the ratio of the log-sizes of a body and its dilate. This is why the interval predicts the diamond, and why the same phenomenon should extend to *any* symmetric convex lattice body — cubes, hexagons, and beyond. The number $p$ measures a universal "loss of independence" that occurs whenever you superimpose several copies of a structured set: how much the freedom to be large is eroded by the pressure to overlap.

Such exponents are the currency of modern additive combinatorics, with tendrils reaching into coding theory (how densely can error-correcting codewords be packed?), into cryptography (how do structured sets resist being pulled apart?), and into the geometry of numbers that underlies lattice-based encryption. Understanding the *shape* of the exponent — where it rises, where it plateaus, what it approaches — is the kind of qualitative map that turns a formula into understanding.

There is also a quieter lesson here about mathematical humility. The most natural guess about the radius — that a bigger diamond means a smaller exponent — is simply wrong, and only careful analysis of the limit reveals the truth. The surface climbs where we expected it to fall. That is the ordinary magic of the subject: a compact formula, $\dfrac{n\log(m+1)}{\log(nm+1)}$, that hides a landscape full of surprises, waiting to be walked.

## What remains

The results here settle the qualitative shape of the exponent surface, but the summit is still ahead. The central open problem is the **dimension-free sharp inequality**: proving that $|A_1 + \cdots + A_n| \ge (|A_1|\cdots|A_n|)^{1/p}$ holds in *every* dimension $d$, with the exponent $p(n,m)$ borrowed unchanged from one dimension. Beyond it lie a rigidity conjecture — that products of intervals are the *unique* extremal configurations — and a stability conjecture — that any sumset merely *close* to the sharp bound must itself be *close* to an arithmetic progression. Each is a step toward a complete theory of how sets add up inside the diamond, in every dimension at once.
