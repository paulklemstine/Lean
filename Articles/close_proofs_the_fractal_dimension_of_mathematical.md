# Close Proofs: The Fractal Dimension of Mathematical Truth

## A coastline made of theorems

Ask a geographer how long the coast of Britain is and you will get a
question back: *at what scale?* Measure with a hundred-kilometre ruler and
you get one answer; measure with a metre stick and you get a much larger
one. The coastline has no well-defined length, but it does have a
well-defined **dimension** — a number between $1$ and $2$ that says how
fast detail proliferates as you zoom in. It is more than a curve, less
than a region.

This article is about a strange and pleasing thought: the same question can
be asked of *truth*. Not of a coastline, but of the set of all true
mathematical statements. Line up every statement in a formal language,
$\varphi_0, \varphi_1, \varphi_2, \dots$, and record which are true and
which are false as an infinite string of bits. Then "truth" becomes a
single point in a space of infinitely long binary strings — and a *theory*
becomes a subset of that space. Subsets of that space, it turns out, have
dimensions. And the dimension we find is not $0$ and not $1$. It is
exactly $\tfrac12$.

Truth, in this precise sense, is a fractal: sparse enough to be
vanishingly rare among all possible assignments of truth values, rich
enough to be uncountably abundant. This article explains what that
statement means, why it is true, and how the same underlying object — the
Boolean cube — supports a second, entirely different kind of measurement,
one that resolved a famous problem in the theory of computation.

## Step one: a ruler for statements

To do geometry we need a distance. Here is the natural one.

A **truth stream** is an infinite sequence of bits
$x = (x_0, x_1, x_2, \dots)$, where $x_k$ records the truth value assigned
to the $k$-th statement $\varphi_k$. The whole space of truth streams is
written $\mathcal{C} = \{0,1\}^{\mathbb{N}}$ — the Cantor space.

Two streams are *close* if you have to read a long way before they
disagree. Formally, define the **first-disagreement distance**

$$d(x,y) \;=\; \begin{cases} 0, & x = y,\\[2pt] 2^{-m}, & m = \min\{k : x_k \neq y_k\}.\end{cases}$$

Two theories that agree about the first thousand statements are within
$2^{-1000}$ of each other; two that disagree about $\varphi_0$ are at
distance $1$, the maximum. This is exactly how a mathematician judges
proximity in practice: two competing accounts of the world are close when
you must go deep into the consequences before you can tell them apart.
Close proofs are proofs that disagree late.

Two facts make this ruler pleasant to work with, and both are the geometric
backbone of everything that follows.

**Theorem (Balls are prefix classes).** *For all truth streams $x, y$ and
every $n \in \mathbb{N}$,*
$$d(x,y) \le 2^{-n} \quad\Longleftrightarrow\quad x_k = y_k \text{ for all } k < n .$$

In words: the closed ball of radius $2^{-n}$ around a stream is precisely
the set of streams sharing its first $n$ truth values — a *cylinder*. The
proof is a two-line case check. If the streams agree on the first $n$
coordinates, then either they are equal (distance $0$) or their first
disagreement occurs at some index $m \ge n$, giving $d = 2^{-m} \le 2^{-n}$.
Conversely, if they already disagree at some $k < n$, the first
disagreement happens at an index $m \le k$, so $d = 2^{-m} \ge 2^{-k} >
2^{-n}$.

This single equivalence converts *geometry* into *combinatorics*: to cover
the space at resolution $2^{-n}$ is nothing more than to list the
admissible words of length $n$. Counting replaces measuring.

**Theorem (Truth is ultrametric).** *For all truth streams $x, y, z$,*
$$d(x,z) \;\le\; \max\bigl(d(x,y),\, d(y,z)\bigr).$$

This is the *strong* triangle inequality, and it is strictly better than
the usual one. It follows immediately from the previous theorem: if $x$ and
$y$ agree up to depth $n$, and $y$ and $z$ agree up to depth $n$, then $x$
and $z$ agree up to depth $n$ — agreement to a fixed depth is transitive.
Take $2^{-n}$ to be the larger of the two distances and you are done.

Spaces obeying the strong triangle inequality are called **ultrametric**,
and they behave in ways that would look pathological to a Euclidean eye.
Every triangle is isosceles, with the two long sides equal. Every point
inside a ball is a *centre* of that ball: there are no privileged
positions, no edges. Any two balls are either nested or disjoint —
they never partially overlap. The space is a perfect hierarchy of
disjoint clusters within clusters, all the way down.

That is exactly the structure of mathematical knowledge as it feels from
the inside. Theories cluster into families that agree on the basics and
split on refinements; the splittings are clean, and once two research
programmes have diverged on some statement, no amount of further agreement
brings them closer than the point where they parted.

## Step two: counting how much truth there is

Now for dimension. In Euclidean space the box-counting dimension of a set
is obtained by covering it with boxes of side $\varepsilon$, counting how
many you need — call it $N(\varepsilon)$ — and taking

$$\dim_B = \lim_{\varepsilon \to 0} \frac{\log N(\varepsilon)}{\log(1/\varepsilon)} .$$

A line segment needs $N \approx 1/\varepsilon$ boxes and gets dimension $1$;
a filled square needs $N \approx 1/\varepsilon^2$ and gets dimension $2$;
the classical middle-thirds Cantor set needs $N \approx \varepsilon^{-0.63}$
and gets the famous $\log 2/\log 3 \approx 0.6309$.

In our space of truth streams, the balls of radius $\varepsilon = 2^{-n}$
are precisely the length-$n$ prefix classes, so $N(2^{-n})$ is simply the
number of length-$n$ prefixes that a theory *permits*. The formula becomes
startlingly concrete:

$$\dim_B = \lim_{n \to \infty} \frac{\log_2 N(n)}{n}, \qquad N(n) = \#\{\text{admissible truth patterns for } \varphi_0,\dots,\varphi_{n-1}\}.$$

The dimension of a theory is its **entropy rate**: the average number of
bits of genuinely new information per statement. If every pattern were
admissible — total logical anarchy, no statement constraining any other —
then $N(n) = 2^n$ and the dimension would be $1$. If a theory were
categorical, pinning down every truth value uniquely, then $N(n) = 1$ and
the dimension would be $0$. Real mathematics lies between: some statements
are free, others are forced by what came before.

The model studied here makes this precise in the simplest possible way.
Suppose the statements come in *linked pairs*: $\varphi_{2k}$ is an
independent assertion, freely true or false, while $\varphi_{2k+1}$ is
logically equivalent to it — a restatement, a corollary, a consequence
whose truth value carries no new information once $\varphi_{2k}$ has been
decided. Half the statements are axioms of a sort; half are deductions.
Then the admissible prefixes of length $n$ number exactly
$N(n) = 2^{\lceil n/2 \rceil}$, and we obtain the main result.

**Theorem (Truth has a nontrivial fractal dimension).** *The set of
admissible truth streams has box-counting dimension exactly*
$$\dim_B = \tfrac12,$$
*and in particular $0 < \dim_B < 1$.*

The computation is immediate — $\log_2 N(n)/n = \lceil n/2\rceil / n \to
1/2$ — but the two inequalities carry the meaning.

**Dimension less than $1$: truth is sparse.** A set of dimension below the
ambient dimension has measure zero. Flip a fair coin for each statement,
independently, and with probability $1$ you will not produce a consistent
theory: sooner or later you will affirm a statement and deny its own
restatement. Random truth is almost never truth. The set of theories is a
dust, not a solid.

**Dimension greater than $0$: truth is not negligible.** Positive dimension
rules out anything countable or finite. There are continuum-many
consistent, complete extensions — a full Cantor set of them, each with its
own infinite tail of independent decisions. Gödel's incompleteness is
visible here as *geometry*: the reason no single axiomatization pins truth
down is that its dimension is positive, that there is always another
independent bit further out.

So truth is a coastline. Zoom in on any admissible prefix and you find a
smaller, similar copy of the whole structure, forever, at a rate of one new
bit for every two statements. Half of mathematics is discovery; half is
bookkeeping.

## Step three: the same cube, measured spectrally

Prefixes of length $n$ are the vertices of the $n$-dimensional Boolean
cube $Q_n = \{0,1\}^n$. Everything above was a statement about *how many*
vertices a theory keeps as $n$ grows. But there is a second, radically
different way to measure a subset of the cube — through the spectrum of an
operator — and it is the tool that cracked one of the longest-standing open
problems in the analysis of Boolean functions.

The trick is to hang minus signs on the edges of the cube. Let $v : Q_n \to
\mathbb{R}$ be a real function on the vertices. Define an operator $A_n$
recursively: $A_0 = 0$, and for a vertex written as a first bit followed by
a shorter word,

$$(A_{n+1} v)(0x) = (A_n v_0)(x) + v_1(x), \qquad (A_{n+1} v)(1x) = v_0(x) - (A_n v_1)(x),$$

where $v_b(x) := v(bx)$ denotes the restriction of $v$ to the face where
the first bit equals $b$. In block-matrix form this is the elegant
recursion

$$A_{n+1} \;=\; \begin{pmatrix} A_n & I \\ I & -A_n \end{pmatrix}, \qquad A_1 = \begin{pmatrix} 0 & 1 \\ 1 & 0\end{pmatrix}.$$

Ignore the signs and this is just the adjacency operator of the cube: the
value at a vertex becomes the sum over its $n$ neighbours. With the signs,
something remarkable happens. A one-line block computation gives

$$A_{n+1}^2 = \begin{pmatrix} A_n^2 + I & 0 \\ 0 & I + A_n^2\end{pmatrix},$$

and by induction:

**Theorem (Square of the signed operator).** $A_n^2 = n\,I$.

The signed cube operator is, up to scale, a square root of the identity.
That is a very strong constraint: the only possible eigenvalues are
$+\sqrt n$ and $-\sqrt n$. And the constraint is *constructive* — the
splitting can be written down explicitly rather than merely inferred.

**Theorem (Spectral splitting of the signed cube).** *Let $r$ be any
nonzero real with $r^2 = n$, and for $v: Q_n \to \mathbb{R}$ define*
$$P_+ v = \tfrac12\bigl(v + r^{-1} A_n v\bigr), \qquad P_- v = \tfrac12\bigl(v - r^{-1} A_n v\bigr).$$
*Then*
$$P_+ v + P_- v = v, \qquad A_n (P_+ v) = r\, P_+ v, \qquad A_n (P_- v) = -r\, P_- v .$$

*Every* function on the cube decomposes, canonically and explicitly, into a
$+\sqrt n$ part and a $-\sqrt n$ part. The verification uses only
linearity of $A_n$ (proved by induction on the recursion, one case per
first bit) and the square law:

$$A_n(P_\pm v) = \tfrac12\bigl(A_n v \pm r^{-1} A_n^2 v\bigr) = \tfrac12\bigl(A_n v \pm r^{-1} n\, v\bigr) = \tfrac12\bigl(A_n v \pm r\, v\bigr) = \pm r\, P_\pm v,$$

where the third equality is just $r^{-1} n = r^{-1} r^2 = r$. Since the two
eigenvalues are distinct for $n \ge 1$, the operators are genuine
complementary projections: $P_\pm^2 = P_\pm$ and $P_+P_- = P_-P_+ = 0$.
Because $A_n$ has trace zero, the two eigenspaces have equal dimension
$2^{n-1}$ — the cube's function space splits exactly in half.

## Why the halves matter

That last sentence is the whole game. Suppose you select more than half the
vertices of the cube — any $2^{n-1}+1$ of them — and look at the graph they
induce. The $+\sqrt n$ eigenspace has dimension $2^{n-1}$, so it must
intersect the space of functions supported on your chosen set. Cauchy's
interlacing theorem then forces the largest eigenvalue of the induced
signed subgraph to be at least $\sqrt n$; and the largest eigenvalue of any
graph is bounded by its maximum degree, signs or no signs. Conclusion:

> **Any set of more than half the vertices of the $n$-cube contains a vertex
> with at least $\sqrt n$ neighbours inside the set.**

This is Huang's theorem, proved in 2019, and by a translation due to
Gotsman and Linial it immediately settles the *sensitivity conjecture*: the
sensitivity of a Boolean function is polynomially related to its degree,
block sensitivity, certificate complexity, and every other standard
complexity measure. A thirty-year-old question in theoretical computer
science, answered by two well-placed minus signs and the observation that
$A_n^2 = nI$.

The bound $\sqrt n$ is sharp, and the explicit projections above tell you
*which* function witnesses the extremal behaviour — they are not merely an
existence proof but a recipe.

## Two rulers, one cube

Stand back and the two halves of this story rhyme. Both concern subsets of
Boolean cubes, and both ask a version of "how big?"

The first ruler is **metric and asymptotic**. It measures a subset of
$Q_n$ by its cardinality's exponential growth rate as $n \to \infty$,
turning a family of finite counts into a single dimension. It says: a
theory keeping $2^{n/2}$ prefixes has dimension $\tfrac12$; it is a fractal
dust of measure zero and continuum cardinality.

The second is **spectral and finite**. It measures a subset of a fixed
$Q_n$ by the eigenvalues of an operator adapted to it. It says: keep more
than half the vertices and you cannot avoid local density $\sqrt n$.

They meet in the middle. The natural next question in the dimension story
concerns theories defined by *local* constraints — say, the streams in
which no two consecutive statements are both true, a syntactic taboo of the
sort that logical consistency imposes. For such a theory the count $N(n)$
satisfies a linear recurrence — for that example, the Fibonacci recurrence
$N(n) = N(n-1) + N(n-2)$ — and the dimension is
$$\dim_B = \log_2 \varphi = \log_2 \frac{1+\sqrt5}{2} \approx 0.6942,$$
the logarithm of the largest eigenvalue of the $2\times2$ transfer matrix
$\begin{pmatrix}1&1\\1&0\end{pmatrix}$. The dimension of a locally
constrained truth set *is* a spectral radius. Counting and spectra are the
same measurement seen from two sides, and the fractal dimension of truth is
an eigenvalue in disguise.

## What to take away

Three ideas, each simple, that together change how one pictures the
landscape of mathematics.

**Truth has a shape.** Once you agree that theories are infinite bit
streams and that closeness means late disagreement, the space of theories
is a compact, totally disconnected, ultrametric world in which balls are
prefix classes and every triangle is isosceles.

**That shape has a dimension strictly between $0$ and $1$.** For the
model above the dimension is exactly $\tfrac12$: truth is measure-zero
rare among arbitrary assignments, yet uncountably abundant. Sparse, but
not negligible. The number is an entropy rate — bits of genuine novelty per
statement — and its positivity is incompleteness written as geometry.

**The same cubes yield to spectra.** Decorating the edges of the
$n$-cube with signs produces an operator squaring to $n$ times the
identity, whose two eigenspaces are given by explicit complementary
projections and each occupy exactly half the dimensions. That halving is
what forces any majority of cube vertices to contain a $\sqrt n$-dense
point — and with it the resolution of the sensitivity conjecture.

Coastlines, truth, and Boolean complexity are not obviously the same
subject. What unites them is that each is a story about how structure
multiplies as you zoom in — and about how, if you choose your ruler
carefully enough, you can put a number on it.
