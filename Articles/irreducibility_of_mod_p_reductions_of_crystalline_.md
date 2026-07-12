# When a Fraction Refuses to Break: The Hidden Rigidity of Crystalline Numbers

## A tale of two prime worlds

Most of us learn arithmetic in a single world: the familiar number line, where
$1$ is close to $2$, and $1{,}000{,}000$ is far away from everything small. But
mathematicians have discovered that hiding beneath the ordinary integers is an
entirely different way of measuring size — one for each prime number $p$. In this
alternative universe, called the **$p$-adic world**, a number is *small* when it
is divisible by a high power of $p$. For $p = 5$, the number $125 = 5^3$ is tiny,
while $2$ is a perfectly ordinary "unit" of size one.

This $p$-adic measuring stick is called a **valuation**, written $v$. It records
*how many times* the prime $p$ divides a number. We normalise it so that
$v(p) = 1$. Then $v(p^3) = 3$, $v(p^{k-1}) = k-1$, and a unit like $2$ (when
$p \neq 2$) has valuation $0$. The valuation can even take fractional values once
we allow $p$-th roots and their cousins: $v(\sqrt{p}) = \tfrac{1}{2}$. That single
possibility — a *fractional* valuation — is the seed of the whole story told here.

## The objects: crystalline representations

Number theorists study how the deep symmetries of arithmetic — collected in an
object called the **Galois group** $G_{\mathbb{Q}_p}$ — act on small vector spaces.
A particularly well-behaved family of two-dimensional such actions is indexed by
two pieces of data:

- an **even weight** $k \ge 2$ (an integer, think of it as a "temperature"), and
- a **Frobenius trace** $a_p$, a $p$-adic number recording the action of a
  distinguished symmetry.

The resulting object $V_{k,a_p}$ is a *crystalline representation*. It is the local
fingerprint, at the prime $p$, of the arithmetic of modular forms — the same
modular forms that appear in the proof of Fermat's Last Theorem. Understanding
these fingerprints is one of the central industries of modern number theory.

There is a natural way to simplify $V_{k,a_p}$: reduce everything **modulo $p$**,
squashing the rich $p$-adic structure down to a finite field. The result, written
$\bar V_{k,a_p}$, is the **mod $p$ reduction**. A basic dichotomy governs it. Either

- $\bar V_{k,a_p}$ is **reducible** — it contains a smaller piece stable under all
  the symmetries, a "line" that the group never moves off of; or
- it is **irreducible** — it has no such invariant line, and is genuinely
  two-dimensional and inseparable.

Deciding which case occurs, for which $k$ and $a_p$, is a notoriously delicate
problem. The article you are reading concerns a clean and surprising sufficient
condition for irreducibility.

## The two slopes

Here is the arithmetic engine. The distinguished Frobenius symmetry acts, on the
crystalline representation, essentially as a $2 \times 2$ matrix whose two
eigenvalues $\alpha, \beta$ are the roots of a single quadratic:
$$X^2 - a_p X + p^{k-1}.$$
The trace of the matrix is $a_p$; its determinant is $p^{k-1}$. Everything we need
is encoded in this polynomial.

To read off the $p$-adic sizes of the two eigenvalues we draw the polynomial's
**Newton polygon** — the lower convex hull of the points
$$(0,\, k-1), \qquad (1,\, v(a_p)), \qquad (2,\, 0),$$
where the height of each point is the valuation of the corresponding coefficient.
When $v(a_p)$ is small enough — precisely when $v(a_p) < \tfrac{k-1}{2}$ — the
polygon *breaks* at the middle vertex into two segments of different steepness.
The slopes of those two segments are the valuations of the two eigenvalues, and we
call them the **Frobenius slopes**:
$$\text{low slope} = v(a_p), \qquad \text{high slope} = (k-1) - v(a_p).$$

Two facts leap out immediately. First, they **add up to the weight minus one**:
$$\text{low slope} + \text{high slope} = (k-1),$$
which is nothing but the statement that $v(\alpha) + v(\beta) = v(\alpha\beta) =
v(p^{k-1}) = k-1$. Second, below the balanced point the low slope is *strictly
smaller* than the high slope, so the two are **distinct**.

## The punchline: a fraction cannot split into integers

Now suppose $v(a_p)$ is **fractional** — not a whole number. This is the
*fractional-slope* regime, and it happens for a rich supply of $a_p$ (for instance
whenever $a_p$ behaves like $\sqrt{p}$, giving slope $\tfrac{1}{2}$).

Why does this force irreducibility? The answer is a beautiful piece of
bookkeeping. **If the reduction were reducible**, it would decompose as a sum of
two one-dimensional crystalline pieces — two *characters* — and each such
character carries a Frobenius slope that is necessarily a whole **integer**. So a
reducible reduction demands two integer slopes.

But our two slopes are $v(a_p)$ and $(k-1) - v(a_p)$. If $v(a_p)$ is a fraction,
then — because $k-1$ is an integer — the difference $(k-1) - v(a_p)$ is *also* a
fraction. Non-integrality **propagates**: a single fractional slope drags its
partner into fractionality too. Neither slope is an integer, so neither can be the
slope of a crystalline character. The required integer-slope decomposition is
impossible. The representation cannot split. It is irreducible.

This is the heart of the matter, and it is entirely a statement about
*valuations*: an arithmetic obstruction, living one layer beneath the linear
algebra.

## Even weight and the perfect half-integer

The setting singles out **even** weights $k$. There is a pleasant reason. At the
balanced point, where a fractional obstruction would be hardest to guarantee, the
common value of both slopes would be $\tfrac{k-1}{2}$. When $k$ is even, $k-1$ is
odd, and $\tfrac{k-1}{2}$ is a genuine **half-integer** — never a whole number. So
for even weight the balanced slope is *automatically* fractional. Even weight
builds the obstruction into the very geometry of the Newton polygon.

## A second, independent layer: discriminants and squares

The valuation story explains *why* a fractional slope blocks the crystalline
splitting. But irreducibility of any two-dimensional representation has a second,
purely algebraic characterisation, and it is worth stating on its own because it
runs on a completely different track.

Consider any two-dimensional representation with Frobenius trace $a$ and
determinant $d$, over a field where $2 \neq 0$. It acquires an invariant line
exactly when its characteristic polynomial
$$X^2 - aX + d$$
has a root in the field — because a root is an eigenvalue, and an eigenvalue
supplies an eigenvector spanning an invariant line. By *completing the square*, one
proves a crisp equivalence:
$$X^2 - aX + d \text{ has a root} \iff a^2 - 4d \text{ is a perfect square.}$$
The quantity $a^2 - 4d$ is the **discriminant**. So the representation is
irreducible — has *no* invariant line — precisely when the discriminant is a
**non-square**. This is the schoolroom quadratic formula, promoted to a criterion
for irreducibility.

The proof is a one-line piece of algebra: if $x$ is a root, then $r = 2x - a$
satisfies $r^2 = a^2 - 4d$; conversely if $r^2 = a^2 - 4d$, then $x = (a+r)/2$ is a
root. Nothing more than middle-school factoring, wielded with precision.

## The bridge

What makes the whole picture satisfying is that these two layers speak to each
other across a **cross-domain bridge**:

- the **arithmetic layer** — $p$-adic valuations, Newton polygons, slope sums —
  tells us that a fractional slope cannot come from integer-slope characters;
- the **linear-algebra layer** — discriminants and squares — tells us, on the
  residual side, exactly when a two-dimensional space hides an invariant line.

Put together, they form a compact **irreducibility certificate**: for an even
weight $k$ and a fractional slope below the balanced point, the two Frobenius
slopes are distinct, non-integral, and sum to $k-1$. That bundle of four facts —
ordering, two non-integralities, and the slope sum — is a self-contained arithmetic
witness that the Frobenius data cannot possibly split into integer-slope
crystalline characters.

## Why anyone should care

Reductions of crystalline representations are the atoms from which the arithmetic
of modular forms is assembled. Knowing when they stay irreducible tells us how the
symmetries of numbers behave under the harsh light of reduction modulo $p$, and it
feeds directly into the study of $p$-adic families of modular forms, the geometry
of *eigenvarieties*, and questions about which representations arise from geometry
at all. The precise pattern — fractional slopes forcing irreducibility — has long
circulated as *folklore*, believed by experts, verified in scattered cases, but
never fully pinned down. The result described here establishes it for fractional
slopes below $p-2$ and sufficiently large even weights, under a mild slope
condition on the exceptional congruence classes of $k$ modulo $p$.

The lesson is almost poetic. In the ordinary world, a fraction is just a number
between the integers. In the $p$-adic world, a fraction is a *fortress*: it refuses
to be broken into integer pieces, and that refusal is exactly what keeps a
representation whole. A single stubborn denominator, hidden in the valuation of one
number, is enough to guarantee that an entire symmetry pattern can never come apart.
