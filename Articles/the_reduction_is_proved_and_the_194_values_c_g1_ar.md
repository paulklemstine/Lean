# Multiplying 194 Infinite Series Without Doing Any Multiplication

## A finite arithmetic shadow of Monstrous Moonshine

### The largest sporadic object, and its 194 fingerprints

In the classification of finite simple groups there is one object that refuses to
belong to any family: the Monster, a group with

$$|\mathbb{M}| = 808{,}017{,}424{,}794{,}512{,}875{,}886{,}459{,}904{,}961{,}710{,}757{,}005{,}754{,}368{,}000{,}000{,}000$$

elements. It has exactly $194$ conjugacy classes, and one of the strangest facts in
mathematics is that each of those classes carries an attached *function of a complex
variable*. Write $q = e^{2\pi i \tau}$ for a point $\tau$ in the upper half-plane. To
each class $[g]$ one attaches a series

$$T_g(\tau) = \frac{1}{q} + c_g(1)\,q + c_g(2)\,q^2 + c_g(3)\,q^3 + \cdots,$$

with integer coefficients $c_g(n)$. These are the McKay–Thompson series. The
normalization is chosen so that the pole $1/q$ is simple and the constant term is
zero — the series starts at $q^{-1}$ and then jumps straight to $q^1$. For the
identity element of the group one recovers the classical modular function
$j(\tau) - 744 = q^{-1} + 196884\,q + 21493760\,q^2 + \cdots$, whose coefficients are
sums of dimensions of Monster representations. That coincidence — number theory's
modular functions knowing the representation theory of an enormous sporadic group —
is Monstrous Moonshine.

This article is about a much more modest, but completely precise, question. What
happens if you *multiply all $194$ of them together*?

$$P(\tau) \;=\; \prod_{[g]} T_g(\tau).$$

Each factor has a simple pole, so the product has a pole of order $194$: it begins
with $q^{-194}$. What comes next? A naive attempt to expand the product is hopeless
by hand: multiplying $194$ infinite series generates, degree by degree, an explosion
of cross terms indexed by all the ways of distributing a total degree among $194$
factors. Even a computer, handed the general problem, must confront that
combinatorics.

The main point of what follows is that near the pole, the explosion never happens.
The first three coefficients after the leading one are not complicated symmetric
functions of the $c_g(n)$; they are *plain sums*:

$$\text{coefficient of } q^{-193} = 0, \qquad
\text{coefficient of } q^{-192} = \sum_{[g]} c_g(1), \qquad
\text{coefficient of } q^{-191} = \sum_{[g]} c_g(2).$$

Nothing else survives. An identity about a product of $194$ transcendental functions
becomes the addition of $194$ integers.

### The reason: a gap in the series creates a gap in the interactions

The mechanism behind that collapse is elementary, and once you see it you cannot
unsee it. Multiply the pole away: set $F_g = q\,T_g$, so

$$F_g = 1 + 0\cdot q + c_g(1)\,q^2 + c_g(2)\,q^3 + \cdots.$$

Now $F_g$ is an ordinary power series with constant term $1$, and — crucially — its
coefficient in degree $1$ *vanishes*. In congruence language, $F_g \equiv 1
\pmod{q^2}$: the series agrees with the constant $1$ up to and including degree $1$.
Call such a series **one-like to depth $d$** when it has constant term $1$ and no
terms at all in degrees $1, \dots, d-1$. Our $F_g$ are one-like to depth $2$.

Suppose $f$ and $g$ are both one-like to depth $d$, and ask for the coefficient of
$q^k$ in $fg$. That coefficient is a sum over ways of writing $k = p + r$ of
(coefficient of $q^p$ in $f$) times (coefficient of $q^r$ in $g$). A term survives
only if neither factor contributes a vanishing coefficient. Either $p = 0$ — and
then $f$ contributes its constant $1$, leaving the coefficient of $g$ — or $r = 0$
symmetrically, or *both* $p$ and $r$ are at least $d$, which forces $k \ge 2d$.

So below degree $2d$, the two series simply cannot interact. Every cross term is
killed by the gap. Iterating over all the factors of a product gives what deserves a
name.

> **Stable-Range Additivity Theorem.** Let $f_1, \dots, f_m$ be power series each of
> which is one-like to depth $d$. Then for every degree $k$ with $1 \le k < 2d$,
> $$[q^k]\bigl(f_1 f_2 \cdots f_m\bigr) \;=\; \sum_{i=1}^m [q^k] f_i.$$
> The elementary symmetric corrections one expects from a product all vanish in this
> range, no matter how many factors there are.

The range $k < 2d$ is not an artifact of the argument. At $k = 2d$ additivity
genuinely breaks, and the smallest counterexample is a one-liner: take $f = g = 1 +
q^2$, both one-like to depth $2$. Their product is $1 + 2q^2 + q^4$, whose degree-$4$
coefficient is $1$ — while the sum of the individual degree-$4$ coefficients is $0$.

Because the McKay–Thompson series have depth $d = 2$, the stable range is $k = 1, 2,
3$, and translating back through $P = q^{-194}\prod_g F_g$ these three degrees are
exactly the three Laurent coefficients quoted above. The vanishing of the
$q^{-193}$ coefficient is the case $k = 1$: it is the sum of the constant terms of
the $T_g$, which is $0$ by normalization.

### One step past the cliff

What happens at the boundary degree $k = 2d = 4$? Not chaos — exactly one new term.
For series one-like to depth $2$,

$$[q^4]\prod_{i} f_i \;=\; \sum_i [q^4]f_i \;+\; \sum_{i < j} \bigl([q^2]f_i\bigr)\bigl([q^2]f_j\bigr),$$

the second sum being the second elementary symmetric function $e_2$ of the
degree-$2$ coefficients. Since $e_2(x) = \tfrac12\bigl((\sum x_i)^2 - \sum
x_i^2\bigr)$, this is still finite arithmetic: it needs the sum of the head
coefficients and the sum of their squares, and nothing else. For the Monster product
it computes the fourth coefficient after the pole:

$$[q^{-190}]P = \sum_g c_g(3) + \sum_{g<h} c_g(1)c_h(1).$$

There is a clear conjectural pattern here: in degrees between $jd$ and $(j+1)d - 1$
the correction should involve exactly the elementary symmetric functions up to
$e_j$, because a factor can only contribute to degree $k$ through its terms of
degree $\ge d$, so at most $k/d$ factors can be simultaneously active. The
combinatorics is that of partitions of $k$ into parts of size at least $d$ — a small,
controlled object, not the full partition lattice.

### From an analytic identity to a decidable one

Here is the punchline in its sharpest form. Fix any integer $N$ and consider the
statement

$$[q^{-192}]\ \prod_{[g]} T_g \;=\; N .$$

On its face this is analysis: an assertion about the Laurent expansion of a product
of $194$ meromorphic functions on the upper half-plane. Stable-range additivity
converts it, with no loss and no approximation, into

$$\sum_{[g]} c_g(1) \;=\; N,$$

an assertion about $194$ integers. Analytic questions are, in general, not
mechanically checkable; the addition of $194$ integers is. Once the table of head
coefficients is written down, the identity is *decided* — either the sum equals $N$
or it does not, and finding out is a finite computation with no error term, no
truncation, no numerics. This is the sense in which a statement about the Monster's
$194$ modular functions has been reduced to arithmetic.

### But where does the table come from?

A reduction to a table is only as good as the table. For a large family of Monster
classes, the McKay–Thompson series is (up to an additive constant) the reciprocal of
a Dedekind eta quotient. Recall $\eta(\tau) = q^{1/24}\prod_{m\ge1}(1 - q^m)$. To a
class $g$ one attaches a *frame shape*: a finitely supported family of integers
$a_k$, recorded as the formal symbol $\prod_k k^{a_k}$ and coming from the
characteristic polynomial of $g$ acting on the $24$-dimensional Leech lattice. It is
*balanced* when $\sum_k k\,a_k = 24$. The associated eta quotient is $\eta_g(\tau) =
\prod_k \eta(k\tau)^{a_k}$, and the moonshine function is $1/\eta_g$ plus a constant.

For these classes the head coefficient is not data at all. Gathering the factors of
$\prod_k \prod_{n \ge 1} (1 - q^{kn})^{-a_k}$ by total degree $m = kn$, one gets

$$q\cdot\frac{1}{\eta_g} \;=\; \prod_{m \ge 1} (1 - q^m)^{-b_m}, \qquad
b_m = \sum_{k \mid m} a_k,$$

and expanding this product to second order gives a closed formula:

> **Frame-Shape Head Formula.** For an eta-quotient class with frame shape $(a_k)$,
> $$c_g(1) = \frac{a_1(a_1+3)}{2} + a_2 .$$

The division is always exact, because $a_1(a_1+3)$ is even for every integer $a_1$.
The next coefficient has a similarly clean shape,
$$c_g(2) = \frac{b_1(b_1+1)(b_1+2) + 6\,b_1b_2 + 6\,b_3}{6},$$
now in terms of the divisor sums $b_m$ rather than the raw exponents.

Computing each successive coefficient this way costs a longer hand expansion, and it
is not obvious the pattern continues. It does, and the reason is a classical trick
worth knowing: take the logarithmic derivative. If $F = \prod_m (1-q^m)^{-b_m}$ then
$q F' = F \cdot L$ where

$$L = \sum_{m\ge1} \frac{m\,b_m\,q^m}{1 - q^m} = \sum_{r \ge 1} \sigma_a(r)\,q^r,
\qquad \sigma_a(r) = \sum_{d \mid r} d\,b_d .$$

Comparing coefficients of $q^r$ on both sides gives, with $c_0 = 1$,

$$r\,c_r \;=\; \sum_{k=0}^{r-1} c_k\,\sigma_a(r-k).$$

That is the whole story: a triangular recursion, one line long, that produces *every*
coefficient of the eta quotient from the finitely many frame-shape exponents. The
divisor sums $\sigma_a$ play the role that power sums play in Newton's identities for
symmetric functions, and the recursion has exactly the shape of Newton's. Re-deriving
the degree-$2$ and degree-$3$ formulas from it, by a route sharing no step with the
original hand expansions, gives the same answers — an honest consistency check.

### The eight balanced shapes, and a table that computes itself

The recursion becomes concrete on the family of frame shapes $1^{-e}n^{e}$, i.e.
$\eta_g = \eta(n\tau)^e/\eta(\tau)^e$. Balance requires $e(n-1) = 24$, so $n - 1$
must divide $24$ and there are exactly eight admissible pairs. For them the head
formula collapses to $c_g(1) = e(e-3)/2$ (with an extra $+e$ when $n = 2$, because
then $a_2 = e$), and the recursion fills in the rest:

| $n$ | $e$ | $c_g(1)$ | $c_g(2)$ | $c_g(3)$ |
|---:|---:|---:|---:|---:|
| $2$ | $24$ | $276$ | $-2048$ | $11202$ |
| $3$ | $12$ | $54$ | $-76$ | $-243$ |
| $4$ | $8$ | $20$ | $0$ | $-62$ |
| $5$ | $6$ | $9$ | $10$ | $-30$ |
| $7$ | $4$ | $2$ | $8$ | $-5$ |
| $9$ | $3$ | $0$ | $5$ | $0$ |
| $13$ | $2$ | $-1$ | $2$ | $1$ |
| $25$ | $1$ | $-1$ | $0$ | $0$ |

The columns sum to $359$, $-2099$ and $10863$. So the eight-fold product
$T_1 \cdots T_8$ of these classes has a pole of order $8$ and Laurent expansion
beginning

$$q^{-8} + 0\cdot q^{-7} + 359\,q^{-6} - 2099\,q^{-5} + 35514\,q^{-4} + \cdots,$$

and the reader can check the fourth entry against the boundary formula: the sum of
the squares of the head column is $79579$, so
$e_2 = \tfrac12(359^2 - 79579) = 24651$, and $10863 + 24651 = 35514$. Every one of
these numbers is a consequence of the eight *frame shapes* alone — eight pairs of
small integers $(n, e)$ — with no analytic input whatsoever.

One more thing falls out of the closed formula. Since $e(e-3)/2 + 1 = (e-1)(e-2)/2
\ge 0$ for every integer $e$, we get a uniform bound with no case analysis:

> For every balanced shape $1^{-e}n^{e}$ with $n > 2$, the head coefficient satisfies
> $c_g(1) \ge -1$, with equality exactly at $e = 1$ and $e = 2$ (that is, $n = 25$
> and $n = 13$); for $n = 2$ one has $c_g(1) \ge 0$.

Monstrous Moonshine is famous for its positivity: the coefficients of $j - 744$ are
dimensions of vector spaces, hence non-negative, and much conjectural structure in
the subject is about non-negativity of similar quantities. The bound above is a
small provable shadow of that phenomenon, obtained not from representation theory but
from the fact that a certain quadratic in $e$ has no room to be very negative.

### What the collapse really says

There is a temptation to read the additivity theorem as a computational trick. It is
better read as a statement about *where information lives*. A product of many series
carries, in high degrees, information about all the interactions between its factors.
Near the top — in the first few coefficients below the leading pole — it carries only
the sum of the individual contributions. The factors are, in that range, invisible to
each other. The depth $d$ of the gap in each factor measures exactly how far this
independence extends: to degree $2d - 1$, and no further.

For the Monster this means the head of the $194$-fold product knows nothing about the
Monster's group structure beyond three integer sums. That is a limitation and an
opportunity at once. It is a limitation because one cannot hope to extract deep
moonshine from the top of the product. It is an opportunity because those three sums
are exactly the kind of statement one can nail down completely: not estimated, not
verified numerically to some precision, but settled, as one settles whether a column
of integers adds up.

And, going the other way, the frame-shape recursion says the table itself is
generated by a handful of small integers per class. Two finite objects — a list of
frame shapes and a one-line recursion — determine the analytic head of a product of
$194$ transcendental functions. Reduction is the whole art: the Monster is vast, the
functions are infinite, and the answer, in the end, fits on a napkin.
