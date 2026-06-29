# When Symmetry Survives the Glue: The Join of Gorenstein Polytopes

## A question that answered itself sideways

Mathematics is full of moments where you set out to prove one thing and discover
the opposite is true. This is one of those stories. The mission began with a bold,
specific guess: *find two beautiful, balanced shapes whose combination is no longer
balanced.* The guess turned out to be wrong — and being wrong, in exactly the right
way, is far more illuminating than being right would have been.

The shapes in question are **lattice polytopes**: convex bodies whose corners sit on
the integer grid $\mathbb{Z}^d$. A triangle with vertices at $(0,0)$, $(1,0)$, and
$(0,1)$ is a lattice polytope. So is a cube, an octahedron, or any convex hull of
grid points. They are the workhorses of a field called *Ehrhart theory*, which asks a
deceptively simple question: if you blow a polytope up by an integer factor $t$, how
many lattice points does it swallow?

Among all lattice polytopes, a special aristocracy stands out — the **Gorenstein**
polytopes. They are the ones with a hidden internal symmetry, and they appear
everywhere from algebraic geometry (where they correspond to certain "nice"
singularities) to mirror symmetry in string theory (where the most symmetric of them,
the *reflexive* polytopes, classify Calabi–Yau hypersurfaces). The question we set out
to answer was: **if you glue two Gorenstein polytopes together with an operation called
the *join*, does the result stay Gorenstein?**

The conjecture said no. The truth says: **always yes.**

## Counting points: the Ehrhart series

To understand why, we need one beautiful idea. Take a lattice polytope $P$ of dimension
$d$ and define $L_P(t)$ to be the number of lattice points inside the $t$-fold dilate
$tP$. Ehrhart's theorem says $L_P(t)$ is a polynomial in $t$ of degree $d$. Even better,
if you bundle all these counts into a single generating function, something magical
happens:

$$\sum_{t \ge 0} L_P(t)\, z^t \;=\; \frac{h^*_P(z)}{(1-z)^{d+1}}.$$

The numerator $h^*_P(z)$ is a polynomial — the **$h^*$-polynomial** (also called the
$\delta$-polynomial). It is a finite list of integers $h^*_0, h^*_1, \dots, h^*_s$
that encodes everything Ehrhart theory knows about $P$. Two deep facts make it a perfect
fingerprint:

- **Stanley's nonnegativity theorem:** every coefficient satisfies $h^*_i \ge 0$.
- **Normalization:** the constant term is always $h^*_0 = 1$.

So the $h^*$-vector is a sequence of nonnegative integers starting with $1$. For our
reflexive triangle of normalized volume $6$, for instance, the vector is
$(1, 4, 1)$, meaning $h^*_P(z) = 1 + 4z + z^2$.

## What makes a polytope "Gorenstein"

Here is the elegant punchline of decades of work by Richard Stanley and Takayuki Hibi:

> **A lattice polytope is Gorenstein exactly when its $h^*$-vector reads the same
> forwards and backwards.**

That is, $h^*_i = h^*_{s-i}$ for every $i$, where $s$ is the degree of $h^*_P$. The
vector is **palindromic**. Our triangle's vector $(1,4,1)$ is a palindrome, so the
triangle is Gorenstein. A vector like $(1, 4, 2)$ would not be, and the corresponding
polytope would fail the test.

This is a stunning reduction. A subtle geometric and algebraic property — having a
"balanced" canonical module, in the language of commutative algebra — becomes a
schoolchild's game of checking whether a list is a palindrome. The Gorenstein property
*is* symmetry, made arithmetic.

## The join: gluing in a higher dimension

Now for the operation at the heart of the story. Given a polytope $P$ living in
$\mathbb{R}^m$ and a polytope $Q$ living in $\mathbb{R}^n$, their **join** $P * Q$ is
built by lifting them into a shared higher-dimensional space so that they don't
interfere, then taking the convex hull of everything:

$$P * Q \;=\; \operatorname{conv}\Big( (P \times \{0\} \times \{0\}) \;\cup\;
(\{0\} \times Q \times \{1\}) \Big) \subseteq \mathbb{R}^{m+n+1}.$$

Geometrically, you place $P$ and $Q$ in "skew" positions and connect every point of one
to every point of the other with a straight segment. The join of two points is a line
segment; the join of a segment and a point is a triangle; the join of two segments is a
tetrahedron. Dimensions add with a bonus:

$$\dim(P * Q) = \dim P + \dim Q + 1.$$

The join is the natural "free" way to combine polytopes, and it has a famously clean
effect on Ehrhart data. The classical multiplicativity identity says:

$$h^*_{P * Q}(z) \;=\; h^*_P(z) \cdot h^*_Q(z).$$

**Joining polytopes multiplies their $h^*$-polynomials.** This single equation is the
key that unlocks everything.

## The proof, in one breath

Now combine the two facts. Gorenstein means palindromic. Join means multiply. So the
original question becomes purely about polynomials:

> *Can the product of two palindromic polynomials fail to be palindromic?*

The answer is a clean, satisfying **no** — and the reason is a one-line computation.
A polynomial $p(z)$ of degree $d$ is palindromic precisely when
$z^d\, p(1/z) = p(z)$; reversing the coefficient order leaves it unchanged. Suppose
$p$ has degree $d$ and $q$ has degree $e$, both palindromic. Then for the product:

$$z^{d+e}\,(pq)(1/z) \;=\; \big(z^{d} p(1/z)\big)\big(z^{e} q(1/z)\big) \;=\; p(z)\,q(z).$$

The reflection of the product is the product of the reflections. Since each factor is
its own reflection, so is the product. **The product of palindromes is a palindrome.**

Translated back into geometry: the join of two Gorenstein polytopes is Gorenstein, every
single time. There is no clever pair of shapes hiding out there that breaks the rule. The
conjecture is not merely unproven — it is *false*, and provably so.

In the formal development, this argument is captured by a structure called
`GorensteinHStar`, which records exactly the three defining facts of a Gorenstein
$h^*$-polynomial: constant term $1$, all coefficients nonnegative, and the reverse equal
to itself. The `join` operation multiplies the two polynomials, and the main theorem
`join_symm` proves the result is still its own reverse. The crucial polynomial fact —
that reversal is multiplicative over an integral domain like $\mathbb{Z}[z]$ — does all
the heavy lifting.

## Three free bonuses

Because the join is "just multiplication," a cascade of further facts comes along for
free, each mirroring a geometric truth:

- **Degrees add.** Since neither $h^*$-polynomial is zero (their constant terms are $1$),
  the degree of the product is the sum of the degrees:
  $\deg h^*_{P*Q} = \deg h^*_P + \deg h^*_Q$. This is the $h^*$-side shadow of the
  dimension formula $\dim(P*Q) = \dim P + \dim Q + 1$, and of the additivity of
  *codegrees*.

- **The point is an identity.** The single-point polytope has $h^* = 1$. Joining
  anything with a point produces the *pyramid* over it, and indeed multiplying by $1$
  changes nothing: $h^*_{\{pt\} * P} = h^*_P$. The point is the neutral element of the
  join.

- **It's a commutative monoid.** The join is commutative ($pq = qp$) and associative
  ($(pq)r = p(qr)$), with the point as unit. So Gorenstein $h^*$-data forms an elegant
  algebraic structure — a commutative monoid — under the join.

These are not afterthoughts; they show that the join is not just *compatible* with the
Gorenstein property but *organizes* Gorenstein polytopes into a clean algebraic world.

## So where did the intuition come from?

Here is the most interesting part. The intuition behind the original conjecture was not
foolish. There genuinely *is* a way to combine two reflexive polytopes and lose the
Gorenstein property — but it is a *different* operation, called the **free sum**
$P \oplus Q$ (sometimes the direct sum). The free sum stacks the two polytopes through a
shared interior point rather than gluing them across a new dimension.

The catch is that the free sum does **not** multiply $h^*$-polynomials. Its Ehrhart
behavior is governed by a more delicate convolution (worked out by Benjamin Braun and
others), and that convolution can absolutely turn two palindromes into a non-palindrome.
The conjecture's instinct — "combining Gorenstein shapes can break symmetry" — was
**true for the free sum and false for the join.** The mission simply attached the right
phenomenon to the wrong operation.

To make the contrast concrete, imagine the crudest possible non-multiplicative way to
merge two symmetric coefficient vectors: just concatenate them. Glue $(1, 4, 1)$ after
itself and you might get $(1, 4, 1, 1, 4, 1)$ — still symmetric by luck — but glue
$(1,4,1)$ and $(1,1)$ to get $(1,4,1,1,1)$ and the palindrome is destroyed. Any
operation that behaves like concatenation rather than multiplication has no reason to
preserve symmetry. Multiplication is special precisely because reflection distributes
over it.

## Why this matters

It is tempting to shrug at a refuted conjecture, but this one teaches a durable lesson
about *which structure protects which property*. Symmetry is fragile under arbitrary
gluing and robust under multiplication. The join earns its reputation as the "free
product" of polytopes: it respects the deepest invariants, multiplies the fingerprints,
and never breaks the balance. The free sum, by contrast, is where the genuine drama
lives, and that is now the sharp, well-posed direction for future work.

There is also a broader moral about how discovery works. The fastest route to the truth
was not to hunt harder for the elusive counterexample the conjecture demanded. It was to
*translate* the geometric question into the language of polynomials, where the answer
became a single line of algebra. Reflexive polytopes, mirror symmetry, Calabi–Yau
manifolds — all of that towering structure, and the decisive fact is that palindromes
multiply to palindromes.

Sometimes the most beautiful theorem is the one that politely tells you your question
had the answer backwards all along.
