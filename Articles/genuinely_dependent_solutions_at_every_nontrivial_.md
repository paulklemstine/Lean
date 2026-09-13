# The Shape of a Minimum: Why Tropical Solution Families Can Never Stand Still

## A polynomial that has forgotten how to multiply

Take the ordinary rules of arithmetic and break them in exactly one place. Keep addition
of numbers, but rename it: from now on, adding two numbers is called *multiplying* them.
And for *adding*, use the minimum: $a \oplus b = \min(a,b)$.

This sounds like vandalism. It is in fact one of the most productive dialects in modern
mathematics, called **tropical arithmetic** (or *min-plus algebra*, and the name
"tropical" is a nod to the Brazilian computer scientist Imre Simon, one of its pioneers).
In this world the number $+\infty$ plays the role of zero, the number $0$ plays the role
of one, and every polynomial turns into something startlingly concrete.

Write down a polynomial of degree $n$ in the tropical language:

$$p(x) \;=\; c_0 \oplus (c_1 \odot x) \oplus (c_2 \odot x^{2}) \oplus \cdots \oplus (c_n \odot x^{n}).$$

Translate back into ordinary arithmetic. Tropical multiplication is addition, so
$c_i \odot x^i$ means $c_i + i\,x$. Tropical addition is minimum. So

$$p(x) \;=\; \min_{0 \le i \le n}\bigl(c_i + i\,x\bigr).$$

A tropical polynomial is nothing more than the **lower envelope of $n+1$ straight
lines**, the $i$-th line having slope $i$ and intercept $c_i$. It is a piecewise-linear,
concave function: a shape you could cut out of cardboard with a few straight snips.

This simple picture is the reason tropical geometry works. Hard questions about curves
and surfaces become questions about polygons and piecewise-linear graphs — combinatorics
with a geometric soul. And the piecewise-linear world is exactly the world where a
neural network with ReLU activations, a shortest-path algorithm, a scheduling problem,
or a rate–distortion curve in information theory all live. Tropical arithmetic is the
common grammar of "take the best option".

## The question: can the winners stay the same?

Here is the datum this article is about. Fix the coefficients $c_0, \ldots, c_n$ and fix
a point $x$. Among the $n+1$ competing lines, which ones actually achieve the minimum?
Call that set of winning exponents the **fibre at $x$**:

$$F(x) \;=\; \bigl\{\, i \in \{0,1,\ldots,n\} \;\bigm|\; c_i + i\,x = p(x) \,\bigr\}.$$

Almost everywhere exactly one line wins, and $F(x)$ is a single index. But at the
*breakpoints* of the graph — the corners where the envelope changes slope — two or more
lines cross at the same height and tie. There $F(x)$ has two or more elements. The size
$|F(x)|$ is the **local multiplicity** at $x$: it records how sharply the polynomial
bends there.

So as $x$ sweeps along the real line we get a whole *family of finite sets*, $x \mapsto
F(x)$. A family of solution sets indexed by a parameter. And now the question that
drives everything below:

> **Is this family genuinely dependent on $x$, or is it secretly constant?**

We must be careful about what "secretly constant" means. The sets $F(x)$ obviously
change as sets — the winning exponent slides downward as $x$ increases. The sharper
question is whether the family could be *pointwise equivalent* to a family that never
moves at all: is there a single fixed finite set $T$ and, for every $x$, a bijection
between $F(x)$ and $T$? If so, the family would be an illusion of variation: a constant
family wearing different labels at different points. If not, the family carries
irreducible, parameter-dependent information.

Since a bijection preserves cardinality, the family is genuinely dependent as soon as
two fibres have **different sizes**. So the question becomes beautifully concrete:
*must some tropical polynomial have all its fibres the same size?*

## The answer: never, for any polynomial at all

**Theorem (Corners are unavoidable).** *Let $n \ge 1$ and let $c_0,\ldots,c_n$ be
arbitrary rational numbers. Then the fibre family of $p(x) = \min_{i \le n}(c_i + i x)$
is not pointwise equivalent to any constant family.*

The striking thing is the phrase "arbitrary". No genericity, no convexity, no
non-degeneracy assumption. You cannot cook up coefficients that defeat it. And the proof
is not an abstract argument-by-contradiction but an explicit construction: it hands you
the corner.

Here it is. For each $i$ between $1$ and $n$, the line of slope $i$ crosses the flat
line of slope $0$ at the point where $c_0 = c_i + i x$, i.e. at
$$x_i \;=\; \frac{c_0 - c_i}{i}.$$
Now take the **largest** of these crossings,
$$x^{\star} \;=\; \max_{1 \le i \le n} \frac{c_0 - c_i}{i}.$$
At $x^\star$ two things happen at once. First, because $x^\star \ge (c_0-c_i)/i$ for
every $i$, rearranging gives $c_0 \le c_i + i x^\star$ for every $i \ge 1$: the flat line
is at or below all the others, so index $0$ is a winner. Second, for the index $i_0$
attaining the maximum the inequality is an equality, so $i_0$ is *also* a winner. Two
distinct winners: $|F(x^\star)| \ge 2$. Move one unit to the right, to $x^\star+1$. Every
sloped line has gained at least its slope, while the flat line has gained nothing, so
every inequality becomes strict and the flat line wins alone: $F(x^\star+1) = \{0\}$,
a fibre of size exactly $1$.

Two fibres, sizes $\ge 2$ and $1$. No bijection can reconcile them. The family moves.

There is a pleasing way to say this. $x^\star$ is the **last** place the constant term
can still be beaten; just past it, the constant term reigns forever. Every tropical
polynomial of positive degree has such a place, and that place is a genuine geometric
corner in the cardboard cut-out.

## But corners are also rare

The same structure that forces corners to exist also forces there to be very few of
them. The engine is a single monotonicity law, and it is the most useful sentence in
this whole subject:

**The Ordering Law.** *If $x < y$, then every winning exponent at $y$ is $\le$ every
winning exponent at $x$.*

Why? Suppose $i$ wins at $x$, $j$ wins at $y$, and (for contradiction) $j > i$. Then
$c_i + i x \le c_j + j x$ and $c_j + j y \le c_i + i y$. Adding these and cancelling
gives $(j-i)(y-x) \le 0$ — impossible, since both factors are positive. Steeper lines
win on the left, flatter lines on the right; the winning slope only ever decreases as
you move right. Concavity, translated into combinatorics.

Two immediate consequences. First, two distinct points can share at most one winning
exponent — the fibres form an almost-disjoint chain along the line. Second, and
crucially, the fibres occupy **consecutive, non-overlapping windows** of the index range
$\{0,1,\ldots,n\}$, arranged from right to left. Since a fibre of size $k$ needs a window
of lattice length $k-1$, and the total lattice length available is exactly $n$, we get:

**Theorem (Degree bound).** *For any finite set $S$ of points,*
$$\sum_{x \in S} \bigl(|F(x)| - 1\bigr) \;\le\; n.$$

Each corner "spends" its excess multiplicity out of a budget equal to the degree. So a
degree-$n$ tropical polynomial has **at most $n$ corners**, and the set of corners is
finite. This is the counting half of what is usually called the tropical fundamental
theorem of algebra: a tropical polynomial of degree $n$ has exactly $n$ roots, counted
with multiplicity — provided the coefficients are "visible", a caveat we will return to.

Combining the two theorems gives a sharp portrait: the fibre family of *every* tropical
polynomial of degree $n \ge 1$ is non-constant, and its non-constancy is concentrated in
at most $n$ points of the line, where the multiplicity jumps above $1$.

## Every size that could occur, does occur

So far: some fibre is bigger than $1$, no fibre is bigger than $n+1$, and the excesses
add up to at most $n$. Is every intermediate value actually achieved? Yes — and the
witnesses are embarrassingly simple.

For $1 \le k \le n+1$, define the **step polynomial** of width $k$ by giving the first
$k$ coefficients the value $0$ and all the rest the value $1$:
$$c_i = \begin{cases} 0, & i < k,\\ 1, & i \ge k.\end{cases}$$
At $x = 0$ every monomial contributes just its coefficient, so the first $k$ monomials
all tie at the value $0$ while the rest sit at $1$: the fibre is exactly
$\{0,1,\ldots,k-1\}$, of size $k$. At $x = 1$ the monomial values are $c_i + i$, which is
minimised uniquely at $i = 0$; the fibre is $\{0\}$, of size $1$.

**Theorem (Dependent solutions at every admissible cardinality).** *For every $k$ with
$2 \le k \le n+1$ there is a degree-$n$ tropical polynomial with one fibre of size
exactly $k$ and another of size exactly $1$. The range $k \le n+1$ is optimal, since no
fibre can exceed $n+1$ elements.*

In particular, once $n \ge 2$ the multiplicity spectrum is itself non-degenerate: both
the value $2$ and the value $3$ are realised by explicit degree-$n$ polynomials. And the
maximum $n+1$ is realised by the totally degenerate polynomial with all coefficients
equal, whose graph is a single corner where all $n+1$ lines pass through one point.

## The Newton polygon: reading multiplicities off a staircase

The examples above hint at a general mechanism, and there is one. Instead of prescribing
the coefficients directly, prescribe the **slope increments**. Given a sequence
$d_0, d_1, d_2, \ldots$, set
$$c_i \;=\; d_0 + d_1 + \cdots + d_{i-1},$$
so that consecutive coefficients differ by $c_{i+1} - c_i = d_i$. A short telescoping
computation gives the key identity: for $i \le j$,
$$\bigl(c_j + j x\bigr) - \bigl(c_i + i x\bigr) \;=\; \sum_{i \le \ell < j} \bigl(d_\ell + x\bigr).$$
Every comparison between two monomials reduces to comparing the increments $d_\ell$ with
the number $-x$. This is the *Newton polygon* of the polynomial in disguise: plot the
points $(i, c_i)$, take the lower convex hull, and the $d_\ell$ are the slopes of its
edges.

The identity gives an exact answer, not just a bound:

**Theorem (Exact fibres of a convex polynomial).** *Suppose the increments $d_\ell$ are
nondecreasing, and fix a value $v$. Then at the point $x = -v$ the fibre is precisely the
block of indices where the increments equal $v$, closed up at both ends:*
$$|F(-v)| \;=\; \#\{\,\ell < n : d_\ell = v\,\} + 1.$$

In words: **the multiplicity of a corner is one more than the number of Newton-polygon
increments of that slope.** A corner where $m$ unit edges of the polygon are collinear
has multiplicity $m+1$.

Summing over the distinct slope values, and noting that the slopes partition the $n$
increment positions $\{0,1,\ldots,n-1\}$, the degree bound becomes an exact identity:

**Theorem (Fundamental theorem, equality form).** *For a convex tropical polynomial of
degree $n$, summing over the distinct slopes $v$,*
$$\sum_{v} \bigl(|F(-v)| - 1\bigr) \;=\; n.$$

Nothing is lost. Every unit of degree is accounted for by exactly one corner.

## The composition spectrum: prescribing the whole profile

We can now ask the most refined question. The list of multiplicity excesses, read left
to right, is a sequence of positive integers summing to $n$ — what combinatorialists call
a **composition** of $n$ (an ordered partition; $6 = 2+1+3$ and $6 = 3+1+2$ are different
compositions). Which compositions arise?

All of them.

**Theorem (Composition spectrum).** *Let $m_0, m_1, \ldots, m_{r-1}$ be positive integers
with $m_0 + \cdots + m_{r-1} = n$. Then there is an explicit degree-$n$ convex tropical
polynomial whose corners are at $x = 0, -1, \ldots, -(r-1)$ with multiplicities
$m_0+1, m_1+1, \ldots, m_{r-1}+1$. Conversely, the multiplicity profile of any convex
tropical polynomial of degree $n$ is a composition of $n$. So a list of positive integers
is a convex multiplicity profile of degree $n$ if and only if it is a composition of $n$.*

The construction is the **staircase of the composition**: let the increment function
$d_\ell$ be the index of the block containing position $\ell$. Positions
$0,\ldots,m_0-1$ get slope $0$; the next $m_1$ positions get slope $1$; and so on. This
sequence is nondecreasing, so the convex theory applies, and the number of positions of
slope $j$ is $m_j$ by construction — which the exact-fibre theorem converts directly into
a corner of multiplicity $m_j + 1$ at $x = -j$.

Special cases recover everything we have seen. All blocks of size $1$: the *generic*
polynomial with $n$ simple corners. One block of size $n$: the totally degenerate corner
of multiplicity $n+1$. Two blocks: every splitting $n = m + (n-m)$ realised by a
two-cornered polynomial with multiplicities $m+1$ and $n-m+1$.

The generic case deserves a name. Take $c_i = \binom{i}{2} = i(i-1)/2$, so the increments
are $0,1,2,3,\ldots$ — the "ramp" polynomial $\min_i\bigl(i(i-1)/2 + i x\bigr)$. A direct
computation gives, at the integer point $x = -m$,
$$\bigl(c_j + j(-m)\bigr) - \bigl(c_m + m(-m)\bigr) \;=\; \frac{(j-m)(j-m-1)}{2},$$
which is nonnegative for every integer $j$ and vanishes exactly when $j = m$ or
$j = m+1$. So the fibre at $-m$ is $\{m, m+1\}$: a simple corner. The polynomial has
exactly $n$ corners, at $0, -1, \ldots, -(n-1)$, each of multiplicity $2$, and the total
excess is $n$. Both bounds — at most $n$ corners, total excess at most $n$ — are
saturated simultaneously, at the extreme opposite to the degenerate polynomial.

## When the count comes up short

Now the caveat, and it is the most interesting part of the story.

The equality form of the fundamental theorem required **convexity**. Drop it and the
identity can fail. Consider the degree-$3$ polynomial with coefficients
$$c = (0,\, 5,\, 1,\, 7), \qquad p(x) = \min\bigl(0,\; 5+x,\; 1+2x,\; 7+3x\bigr).$$
Plot the four points $(0,0), (1,5), (2,1), (3,7)$. The point $(1,5)$ sits high above the
segment from $(0,0)$ to $(2,1)$ — the monomial $5 + x$ is *never* the strict minimum,
anywhere. It is invisible: dominated for all $x$ by the average of its two neighbours.

Compute the corners. At $x = -1/2$ the monomials $0$ and $1+2x$ both equal $0$ and
everything else is larger: fibre $\{0,2\}$. At $x = -6$ the monomials $1+2x = -11$ and
$7+3x = -11$ tie: fibre $\{2,3\}$. Those are all the corners. Total excess:
$1 + 1 = 2$, strictly less than the degree $3$.

A unit of degree has gone missing. Where? Into the edge of the Newton polygon from
$(0,0)$ to $(2,1)$, which has **lattice length $2$** but supports a corner of
multiplicity only $2$ (excess $1$) because the intermediate lattice point $(1,\cdot)$ is
not occupied by a visible monomial. The defect counts exactly the lattice points of the
lower hull that are not monomials of the polynomial — the failure of the coefficient
vector to be *lattice-convex*.

This is why the general statement must be an inequality, $\sum_x (|F(x)|-1) \le n$, with
equality precisely in the convex regime. It is not a flaw in the theory; it is the theory
telling you something. Degree counts potential roots; a non-convex coefficient vector
hides some of them inside a hull edge.

## Why constancy is not automatic

To see that the non-constancy theorem has real content, it is worth exhibiting a
tropical family that *is* constant.

Fix a strictly increasing weight $w$ on the positive integers and, for each $N$, form
the min-plus aggregate of $w$ over the divisors of $N$ — the tropical sum
$\bigoplus_{d \mid N} w(d)$, which is just $\min_{d \mid N} w(d)$. Which divisors achieve
it? Since $1$ divides every $N$ and $w$ is increasing, the minimum is always at $d = 1$,
and strict monotonicity makes it the unique minimiser. The argmin fibre is $\{1\}$, for
every single $N$. That family is constant, with constant cardinality $1$.

So tropicalisation as such does not force dependence. Constancy is possible; it is a
feature of aggregating over a *lattice with a bottom element*, where one candidate
dominates uniformly. The polynomial fibre family has no such bottom: the competitors are
lines of different slopes, and no line can dominate another everywhere. Non-constancy is
forced by the *geometry of crossing*, not by the algebra of the semiring.

## What this is really about

Strip away the tropical vocabulary and the theorem says something a working engineer
would recognise immediately. You have a family of options indexed by a parameter, each
option's cost varying affinely in that parameter, and you always take the best. Then:

- **Ties are unavoidable.** Somewhere in the parameter range, two options are exactly as
  good as each other. You cannot design the cost structure to avoid it (as long as the
  slopes genuinely differ).
- **Ties are rare.** The set of parameter values where the optimum is ambiguous is
  finite, with size bounded by the number of distinct slopes.
- **Ties are ordered.** As the parameter increases the optimal option's slope only
  decreases, never back-tracks. Optimal policies are monotone.
- **Any pattern of ties can be engineered.** Any prescribed composition of the slope
  budget can be realised by a suitable cost vector, and the realisation is explicit.
- **The budget can be wasted.** If some option is never optimal anywhere — dominated by a
  blend of its neighbours — the tie budget is underspent, and the shortfall counts the
  hidden options exactly.

These are the statements that make piecewise-linear optimisation tick. They govern the
breakpoints of a parametric linear program, the kink locations of a ReLU network's
response curve, the slope changes of a rate–distortion function as the Lagrange
multiplier sweeps, and the structure of a tropical curve's Newton subdivision.

The moral is the one that recurs throughout tropical geometry: the piecewise-linear
shadow of an algebraic object keeps the essential accounting intact. Degree becomes
lattice length; roots become corners; multiplicity becomes the number of collinear
polygon edges. And a family of solution sets over the tropical line, however you arrange
its coefficients, can never quite hold still.
