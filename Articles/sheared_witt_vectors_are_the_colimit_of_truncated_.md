# The Vector Made of All the Variables: How "Shearing" Repairs a Broken Limit

## A tale of two infinities

Mathematics is full of machines that take a ring — a number system where you can
add, subtract, and multiply — and build a bigger, richer ring out of it. One of
the most beautiful of these machines is the **Witt vector** construction. Given a
prime number $p$ and a ring $R$, it produces a new ring $W(R)$ whose elements are
infinite sequences $(x_0, x_1, x_2, \dots)$ of elements of $R$. What makes Witt
vectors magical — and notoriously subtle — is that you do **not** add these
sequences coordinate by coordinate. Instead, addition and multiplication are
governed by a specific, universal family of polynomials, engineered so that
$W(R)$ secretly remembers arithmetic "one prime at a time." When $R$ is a field
of characteristic $p$, the Witt vectors miraculously reassemble it into a ring of
characteristic zero. Witt vectors are the backbone of modern $p$-adic geometry,
crystalline cohomology, and the theory of perfectoid spaces.

This article is about a small, sharp phenomenon hiding inside this machine — a
place where the construction breaks, and an elegant fix, called **shearing**,
that puts it back together. The whole drama plays out around a single question:

> When you build a ring as a limit of smaller pieces, does the Witt vector
> construction respect that limit?

The answer turns out to be a crisp *"it depends,"* and understanding exactly what
it depends on reveals something clean about the difference between the finite and
the infinite.

## Building rings out of pieces

Rings are often assembled from an increasing tower of smaller rings. Imagine a
sequence of subrings
$$S_1 \subseteq S_2 \subseteq S_3 \subseteq \cdots$$
sitting inside one big ambient ring $R$, each contained in the next. Their union
$$S_\infty = \bigcup_{i} S_i$$
is again a ring — every element of $S_\infty$ lives in *some* finite stage $S_i$,
and any two elements can be found together in a common (large enough) stage where
you can add and multiply them. This kind of increasing union is the concrete face
of what category theorists call a **filtered colimit**: a limit built by merging
a *directed* family of pieces, where any finite collection of pieces fits inside a
single later one.

A guiding slogan of algebra is that *finite constructions commute with filtered
colimits.* If you build something out of finitely many ingredients, then building
it over the union $S_\infty$ is the same as building it over some single stage
$S_i$ and then passing to the union. The reason is disarmingly simple: finitely
many elements, each living in some stage, can all be rounded up into one common
stage, because "directed" means any finite set of stages has an upper bound.

The interesting mathematics begins the moment "finitely many" becomes
"infinitely many."

## Truncated Witt vectors: the finite case works

Witt vectors come in a finite flavor. The **truncated Witt vectors** of length
$n$, written $W_n(R)$, keep only the first $n$ coordinates: as a set,
$W_n(R) = R^n$, a tuple $(x_0, x_1, \dots, x_{n-1})$. The Witt ring operations
respect this truncation because the $k$-th coordinate of a sum or product depends
only on the first $k$ coordinates — nothing from further out ever leaks back. So
$W_n$ is genuinely a *finite-arity* construction: each of its outputs is
assembled from finitely many inputs.

Because of that, the slogan applies without a fight. Here is the precise
statement.

> **Truncated Witt vectors preserve filtered colimits (the finite case).**
> Let $S_1 \subseteq S_2 \subseteq \cdots$ be an increasing (directed) family of
> subrings of a ring $R$, with union $S_\infty = \bigcup_i S_i$. Then every
> truncated Witt vector $x \in W_n(S_\infty)$ lifts to a single stage: there is
> an index $i$ and a truncated Witt vector $y \in W_n(S_i)$ whose coordinates map
> back to those of $x$ under the inclusion $S_i \hookrightarrow S_\infty$.

The proof is exactly the slogan in action. The vector $x$ has only $n$
coordinates $x_0, \dots, x_{n-1}$, each an element of the union $S_\infty$, hence
each living in some stage. Finitely many stages have a common upper bound $S_i$,
so all $n$ coordinates live in $S_i$ at once. Repackage them as a truncated Witt
vector $y$ over $S_i$, and you are done. Finiteness did all the work.

## The full Witt vectors: the infinite case breaks

Now remove the truncation. The full Witt vectors $W(R) = R^{\mathbb{N}}$ use
*infinitely many* coordinates $(x_0, x_1, x_2, \dots)$. The naive hope is that the
same lifting theorem still holds. It does not — and the failure is not some
pathological edge case. It is witnessed by the single most natural infinite Witt
vector you could write down.

Take a field $K$ and form the polynomial ring $R = K[X_0, X_1, X_2, \dots]$ in
countably many variables. Filter it by how many variables you are allowed to use:
let
$$S_i = \{\, \text{polynomials using only the variables } X_0, \dots, X_i \,\}.$$
Each $S_i$ is a subring, the family is increasing, and its union is all of $R$,
because any single polynomial mentions only finitely many variables.

Now consider the **vector of all the variables**:
$$x = (X_0, X_1, X_2, X_3, \dots) \in W(R),$$
whose $k$-th coordinate is simply the variable $X_k$. Look closely at what
happens.

- **Every coordinate lifts.** The coordinate $X_k$ lives in the stage $S_k$ (it
  uses only the variable $X_k$), which is inside the union $S_\infty = R$. So
  *pointwise*, this vector is entirely built from elements of the colimit. There
  is no obstruction visible one coordinate at a time.
- **The whole vector lifts nowhere.** Suppose the entire vector lived in a single
  stage $S_i$. Then in particular the coordinate $X_{i+1}$ would have to be a
  polynomial in $X_0, \dots, X_i$ only — but $X_{i+1}$ is a brand-new variable
  that no such polynomial can equal. Contradiction. No stage is large enough to
  hold all the variables at once.

> **The naive lift fails (the obstruction).** Over the polynomial ring
> $K[X_0, X_1, \dots]$ with the variable-count filtration above, the Witt vector
> $x = (X_0, X_1, X_2, \dots)$ has every coordinate in the colimit $S_\infty$, yet
> lies in no single stage $S_i$. Hence the full Witt vector construction does
> **not** preserve this filtered colimit.

This is the heart of the story, and it is worth savoring. Each individual
coordinate is perfectly well-behaved; the pathology is purely collective. The
vector escapes every finite stage not because any one of its entries is bad, but
because its entries *drift outward forever*, coordinate $k$ demanding stage $k$.
Directedness can merge any *finite* set of demands into one stage — but here the
demands never stop.

## Shearing: the minimal repair

If the problem is that the coordinates drift out to infinity, the fix is to
forbid that drift — but as gently as possible. Enter **shearing**.

A Witt vector is called **finitely supported** (or *sheared*) if all but finitely
many of its coordinates are zero: there is some cutoff $N$ beyond which every
$x_k = 0$. This is a mild restriction — you keep the full infinite tower of
coordinates, you just insist that eventually they settle down to the basepoint
$0$ (which, conveniently, lives in every subring). The sheared Witt vectors form
exactly the "essentially finite" part of the full Witt vectors.

And with that single restriction, preservation snaps back into place.

> **Sheared Witt vectors preserve filtered colimits (the repair).** Let
> $S_1 \subseteq S_2 \subseteq \cdots$ be an increasing family of subrings with
> union $S_\infty$. If a Witt vector $x \in W(S_\infty)$ is finitely supported —
> so $x_k = 0$ for all $k \ge N$ — and every coordinate lies in $S_\infty$, then
> $x$ lifts to a single stage: there is an index $i$ such that $x$ is the image
> of a Witt vector over $S_i$ under the map $W(S_i) \to W(S_\infty)$ induced by
> the inclusion.

The proof is once again the finite slogan in disguise. Only the coordinates
$x_0, \dots, x_{N-1}$ can be nonzero; that is *finitely many* elements of the
union, so they all fit into a common stage $S_i$. Every remaining coordinate is
$0$, which already lives in $S_i$. So the entire (essentially finite) vector lives
in $S_i$. Finiteness is restored, and with it, preservation.

Shearing is not merely *a* fix; it is the *minimal* one. Recall the vector of all
the variables: its $k$-th coordinate is supported at stage $k$, one step further
out each time, with no cutoff. This is precisely the behavior that finite support
forbids and nothing weaker does. Any relaxation that still allowed infinitely
many nonzero coordinates to drift outward would readmit the counterexample. So
"finite essential support" is not an arbitrary convenience — it is exactly the
boundary between preservation and failure.

## Why this is the right picture

Step back and the three results line up into a single, satisfying statement about
the difference between finite and infinite.

- **Finite arity preserves colimits.** Truncated Witt vectors $W_n$, built from
  $n$ coordinates, always descend to a single stage. ($W_n(S_\infty)$ lifts.)
- **Infinite arity does not.** The full Witt vectors $W$, built from infinitely
  many coordinates, can escape every stage — and the escape is realized by the
  most natural example imaginable, the vector of all the variables.
- **Finite support restores it.** Shearing to finitely supported coordinates
  makes the infinite construction behave like a finite one again, and this is the
  sharpest possible repair.

Read as a slogan: **the sheared Witt vectors over a union of rings are exactly
the union of the Witt vectors over the stages.** Each finite layer of the sheared
object behaves like a truncated Witt functor, and stacking those layers rebuilds
the whole. In the language of limits, *the sheared Witt vector construction is the
filtered colimit of the truncated Witt vector constructions.* The object that
naively broke the colimit is, after shearing, assembled from the very finite
pieces that respect it.

## The moral

There is a lesson here that reaches well beyond Witt vectors. Whenever we build a
structure out of infinitely many coordinates and then try to assemble it from
finite approximations, the danger is never any single coordinate — it is the
*collective drift* of infinitely many of them refusing to be pinned down at once.
The cure is to insist on finite essential support: keep the infinite scaffolding,
but require that it eventually rests on solid ground. That is shearing, and the
vector of all the variables is the perfect cautionary tale showing why it is
needed — and why nothing less will do.

Finiteness commutes with taking unions. Infinity, left unchecked, does not. And
between them sits the delicate, beautiful compromise of the finitely supported —
enough infinity to be interesting, enough finiteness to be tractable.
