# When Adding Becomes Multiplying: Helly's Theorem in the Tropics

## A geometry with only two operations

Imagine an arithmetic in which you are forbidden to multiply. All you may do is
take maxima and add. Call the maximum "$\oplus$" and ordinary addition
"$\odot$":

$$a \oplus b = \max(a,b), \qquad a \odot b = a + b.$$

This is the **max-plus**, or **tropical**, semiring. It looks impoverished — no
subtraction, no inverses for $\oplus$ — but it is the arithmetic that governs a
surprising amount of the world. The completion time of a job in a scheduling
network is a max of sums. The shortest path in a graph is a min of sums (the
mirror image of the same algebra). The cost-to-go in dynamic programming, the
departure times of trains in a synchronised timetable, the amplitude of a
tropical curve in algebraic geometry: all of them are max-plus linear.

Once you have an arithmetic, you get a geometry. Replace the ordinary convex
combination $\lambda x + (1-\lambda) y$ by its tropical shadow

$$(s \odot x) \oplus (t \odot y) \;=\; \bigl(i \mapsto \max(s + x_i,\; t + y_i)\bigr),$$

and you obtain **tropical convexity**. A set $S \subseteq \mathbb{R}^d$ is a
*tropical cone* if it contains every such combination of any two of its points,
for arbitrary real weights $s,t$. Tropical cones look nothing like ordinary
convex bodies — they are polyhedral complexes assembled out of pieces parallel
to the coordinate directions, staircase-shaped objects that a topologist would
call *contractible* and a combinatorialist would call *lattice-like*. And yet,
astonishingly, they obey the same structural laws that make ordinary convexity
so powerful: Helly's theorem, Carathéodory's theorem, Cramer's rule. The purpose
of this article is to tell you exactly what those laws say in the tropics — and
to reveal a small shock: **the tropical world is one dimension better behaved
than the classical one.**

## Helly's theorem, classically

In 1913 Eduard Helly proved a theorem so simple to state that it sounds like a
puzzle. Take finitely many convex sets in the plane. If *every three* of them
have a point in common, then *all* of them do. In $\mathbb{R}^d$ the magic
number is $d+1$: if every $d+1$ members of a finite family of convex sets
intersect, the whole family intersects.

The number $d+1$ is not negotiable classically: the $d+1$ facets of a simplex,
suitably enlarged, give $d+1$ convex sets with empty total intersection any $d$
of which meet. Helly's theorem is the reason linear programming has small
infeasibility certificates, the reason certain approximation algorithms exist,
and the ancestor of an entire industry of "Helly-type" results in combinatorial
geometry.

So: what is the Helly number of tropical convexity?

## The answer: $d$ for cones, $d+1$ for convex sets

Here are the two central results, stated precisely.

> **Tropical Helly Theorem.** Let $d \ge 1$ and let $C_1,\dots,C_n$ be finitely
> many tropical cones in $\mathbb{R}^d$. If every subfamily of **at most $d$**
> of them has a common point, then $C_1 \cap \dots \cap C_n \neq \varnothing$.

> **Sharpness.** For every $d \ge 1$ there exist $d$ tropical cones in
> $\mathbb{R}^d$, any $d-1$ of which meet, whose total intersection is empty.
> Hence the tropical Helly number of $\mathbb{R}^d$ is *exactly* $d$.

One better than the classical $d+1$. The reason is that a tropical cone is
invariant under the "tropical scaling" $x \mapsto (s + x_1, \dots, s+x_d)$, so
it really lives in the $(d-1)$-dimensional tropical projective torus
$\mathbb{R}^d / \mathbb{R}\mathbf{1}$; the missing dimension is exactly the one
that Helly's classical bound would have charged us for.

If we drop scaling invariance and ask only for the weaker *tropical convexity*
— closure under $i \mapsto \max(x_i, t + y_i)$ for $t \le 0$, the honest analogue
of "convex combination with weights summing to the tropical unit" — the number
goes back up by one, and again it is sharp:

> **Helly Theorem for Tropically Convex Sets.** Let $S_1,\dots,S_n \subseteq
> \mathbb{R}^d$ be tropically convex. If every $d+1$ of them intersect, all of
> them do. There are $d+1$ tropically convex subsets of $\mathbb{R}^d$, any $d$
> of which meet, with empty total intersection.

This settles a question that had been left open: it had been conjectured that a
Helly number of at most $2d$ holds for tropically convex sets. It does — for
every $d \ge 1$ — but with a great deal of room to spare, since the true value
is $d+1$. And the conjecture as literally stated is *false* for $d = 0$: in
$\mathbb{R}^0$, the unique point space, the empty set is (vacuously) tropically
convex, and the condition "every $0$ of them intersect" is empty, so a single
empty set is a counterexample. Degenerate, but true, and worth recording: the
statement needs $d \ge 1$.

## The engine room: a tropical Cramer rule

Where does the number $d$ come from? From a theorem of pure linear algebra —
tropical linear algebra.

Classically, any $d+1$ vectors in $\mathbb{R}^d$ are linearly dependent: some
nontrivial combination of them vanishes. In max-plus there is no subtraction, so
"vanishing" must be replaced by something else. The right replacement, standard
in tropical geometry, is:

> **Definition (tropical dependence).** Vectors $A_0,\dots,A_d \in \mathbb{R}^d$
> are *tropically dependent* if there are weights $\lambda_0,\dots,\lambda_d \in
> \mathbb{R}$ such that in **every** coordinate $i$ the maximum
> $\max_k (\lambda_k + A_{k i})$ is attained at least twice.

"Attained twice" is the tropical way of saying "cancels". And the theorem:

> **Tropical Cramer Dependence Theorem.** Any $d+1$ vectors of $\mathbb{R}^d$
> are tropically dependent. Explicit witnessing weights are the *tropical
> determinants of the row-deleted minors*: $\lambda_k = \operatorname{tropdet}
> A^{(\hat k)}$, where $\operatorname{tropdet} M = \max_{\pi} \sum_r M_{r,\pi(r)}$
> ranges over all permutations $\pi$, and $A^{(\hat k)}$ is $A$ with row $k$
> deleted.

That the weights are given by minors is precisely Cramer's rule, transplanted.
The proof is the max-plus incarnation of the classical fact that *a matrix with
two equal columns is singular*. Prepend to the $(d+1) \times d$ matrix $A$ a copy
of its own $i$-th column, producing a square $(d+1)\times(d+1)$ matrix with two
identical columns. Take an optimal permutation $\pi$ for its tropical
determinant — an optimal assignment, in the language of combinatorial
optimisation. Two distinct rows $a \ne b$ carry the two copies of the repeated
column. Swapping the assignment of those two rows produces another permutation
of exactly the same weight. Expanding both along the duplicated column, à la
Laplace, converts the equality of the two assignment weights into the statement
that the maximum $\max_k(\lambda_k + A_{ki})$ in coordinate $i$ is achieved at
both $a$ and $b$. Two maximisers: dependence.

From dependence to Helly is a short and beautiful step. Suppose $C_1,\dots,C_n$
are tropical cones and every $d$ of them meet; we want a point in all of them.
Induct on $n$. Take, for each of $d+1$ chosen indices $k$, a point $p_k$ lying in
all the cones *except possibly* $C_k$ (available by induction). Now form the
single point

$$z_i \;=\; \max_{k} \bigl(\lambda_k + p_{k i}\bigr)$$

using the Cramer weights $\lambda$ for the family $\{p_k\}$. Since each cone is
closed under max-plus combinations, $z$ lies in $C_j$ as soon as *all* the $p_k$
used with a nonnegligible weight lie in $C_j$. Because the maximum in every
coordinate is attained *twice*, at least one of the two maximisers avoids the one
index that could cause trouble — so $z$ lies in every $C_j$ simultaneously. The
"attained twice" is the whole point: it is redundancy, and redundancy is what
lets you dodge the missing set.

## The loop closes: Helly *is* Cramer

One of the pleasing structural facts here is that this is not a one-way street.
Assume the tropical Helly property as a black box — assume that in dimension $d$,
$d+1$ tropical cones whose $d$-element subfamilies meet always have a common
point. Then you can *derive* the dependence theorem from it. Given $d+1$ points
$p_0,\dots,p_d \in \mathbb{R}^d$, apply Helly to the $d+1$ cone hulls
$H_k = \operatorname{tconv}\{p_j : j \neq k\}$. Any $d$ of these hulls contain a
common point (some index $k_0$ is missed by the subfamily, and $p_{k_0}$ lies in
all of them). Helly hands you a point $z$ lying in *every* $H_k$. Then residuate:
set $\lambda_j = \min_i (z_i - p_{ji})$, the largest weight that keeps
$\lambda_j + p_j \le z$. One checks that $z$ is reconstructed as
$z_i = \max_{j \ne k} (\lambda_j + p_{ji})$ for every $k$, and that is exactly
the "maximum attained twice" condition. So:

> **Tropical Helly and tropical Cramer dependence are equivalent statements.**

Two theorems that look like they belong to different subjects — one geometric,
one algebraic — are two faces of one phenomenon.

## Carathéodory: one generator per coordinate

Helly has a twin. Carathéodory's theorem says that a point in the convex hull of
a set in $\mathbb{R}^d$ already lies in the hull of at most $d+1$ of its points.
Tropically, for cones, the number drops again — and the proof is a one-liner once
you see it.

The **tropical cone hull** of points $p_k$ is the set of all
$z_i = \max_{k \in F} (\lambda_k + p_{ki})$. Suppose $z$ is such a combination.
For each of the $d$ coordinates $i$, record *one* index $k(i)$ attaining the
maximum in that coordinate. Throw away every generator not of the form $k(i)$.
Nothing changes: each coordinate is still realised, and no coordinate can
increase. Hence:

> **Tropical Carathéodory Theorem for Cones.** Every point of the tropical cone
> hull of a finite family in $\mathbb{R}^d$ lies in the cone hull of at most $d$
> of the generators. The bound $d$ is sharp: the $d$ "tropical unit vectors"
> $e^{(k)}$, with $e^{(k)}_k = 0$ and $e^{(k)}_i = -1$ for $i \ne k$, generate the
> origin $\mathbf{0}$, which lies in the hull of no proper subfamily.

Sharpness is a nice little argument. If a subfamily $G$ with $|G| < d$ generated
$\mathbf{0}$, some coordinate $i_0$ would be missing from $G$; realising
coordinate $i_0$ (whose value is $0$) with generators that all read $-1$ there
forces the maximising weight to be $1$; but that same generator then over-shoots
in its own coordinate, where it reads $0$, giving value $1 > 0$. Contradiction.

The same "one generator per coordinate" idea gives a *colourful* version, the
tropical analogue of Bárány's colourful Carathéodory theorem:

> **Colourful Tropical Carathéodory.** Let $d$ "colour classes" of points of
> $\mathbb{R}^d$ be given, and suppose a point $z$ lies in the tropical cone hull
> of every class. Then $z$ lies in the cone hull of a *rainbow* selection: one
> generator taken from each class. Explicitly, from class $c$ take a generator
> attaining the maximum in coordinate $c$.

The proof is the same bookkeeping, done with the colours as an extra index — and
the selection is *constructive*, which is more than can be said for most
colourful theorems.

## The optimisation side: solving $A \otimes x = b$

Convexity theory would be idle if it did not connect to optimisation, and the
max-plus connection is immediate. A max-plus matrix–vector product is

$$(A \otimes x)_i \;=\; \max_j \,(A_{ij} + x_j),$$

the same expression that computes the earliest start time of task $i$ given
completion times $x_j$ of its predecessors and delays $A_{ij}$. Solving
$A \otimes x = b$ means: schedule the predecessors so that every task starts
exactly on time.

Because max-plus has no subtraction, there is no Gaussian elimination. What there
*is* is a Galois connection, and it is beautiful:

> **Residuation.** Define the residuated vector by
> $(A \,\sharp\, b)_j = \min_i \,(b_i - A_{ij})$. Then for every $x$,
> $$A \otimes x \le b \iff x \le A \,\sharp\, b .$$
> In particular $A\,\sharp\,b$ is the **greatest subsolution** of
> $A \otimes x \le b$.

And the payoff:

> **Principal Solution Criterion.** The system $A \otimes x = b$ is solvable if
> and only if the single canonical candidate $A \,\sharp\, b$ solves it.

So the tropical analogue of "compute the rank and compare" is: compute one
explicit vector by $mn$ subtractions and $mn$ comparisons, plug it in, look. A
complete decision procedure in $O(mn)$ arithmetic operations, with a proof
consisting of exactly the Galois connection plus monotonicity of $\otimes$. If
any $x$ solves the system, then $x \le A\,\sharp\,b$, so
$b = A \otimes x \le A \otimes (A\,\sharp\,b) \le b$; the outer terms coincide, so
$A\,\sharp\,b$ is a solution too.

## What Helly buys you: locality of feasibility

Helly theorems are, in disguise, statements about *certificates*. If a system is
infeasible, Helly guarantees a small infeasible subsystem — an explanation of the
failure that a sceptic can check quickly.

Two concrete instances:

> **Locality of tropical linear feasibility.** A finite system of two-sided
> tropical linear inequalities $\max_j (a_{kj}+x_j) \le \max_j (b_{kj}+x_j)$ in
> $d+1$ unknowns is solvable if and only if every $d+1$ of the inequalities are
> simultaneously solvable.

> **Helly criterion for difference constraints.** A finite system of constraints
> $x_{t_k} - x_{s_k} \le w_k$ in $d$ variables is feasible if and only if every
> $d$ of the constraints are simultaneously feasible.

The second deserves a moment. Difference-constraint systems are exactly shortest
path problems: feasibility holds iff the associated weighted digraph has no
negative cycle. And a negative cycle in a graph on $d$ vertices is a *simple*
cycle with at most $d$ edges — that is, a violated subsystem of at most $d$
constraints. So the Helly bound $d$, obtained here from tropical Cramer, is
precisely the negative-cycle criterion of Bellman and Ford, seen from a completely
different angle. The classical algorithm and the tropical geometry agree on the
number, and the agreement is not a coincidence: both are the statement that
max-plus dependence in $\mathbb{R}^d$ needs $d$ things, not $d+1$.

## The edge of the theorem

Every good theorem has a boundary, and it is worth knowing where the tropical
Helly theorem stops. It stops at infinity:

> **Failure for infinite families.** The nested half-cones
> $C_k = \{x \in \mathbb{R}^2 : x_1 + k \le x_2\}$, $k = 0,1,2,\dots$, are tropical
> cones; every finite subfamily has a common point (take $x_1 = 0$ and $x_2$
> large); yet no point lies in all of them, since $x_2 - x_1$ would have to exceed
> every natural number.

In the classical theory one repairs this with compactness: Helly's theorem holds
for infinite families of *compact* convex sets. Max-plus geometry has no such
tool — tropical cones are unbounded by construction, being scaling invariant — so
finiteness is genuinely essential rather than technically convenient.

## Why it matters

The tropical semiring is where discrete optimisation and algebraic geometry
shake hands. Scheduling, shortest paths, dynamic programming, Viterbi decoding,
the tropicalisation of algebraic varieties, and the geometry of ReLU neural
networks are all max-plus phenomena. Every structural theorem transplanted into
that setting is a new tool for all of them at once. A Helly number tells you how
small an infeasibility certificate can be; a Carathéodory number tells you how
much of a generating set you actually need to keep; a Cramer rule tells you what
"dependence" means when you cannot subtract; a residuation theorem turns an
existence question into an evaluation.

And there is a slogan hiding in all of this. Classical convexity counts
dimensions: $d+1$ everywhere, because a simplex in $\mathbb{R}^d$ has $d+1$
vertices. Tropical convexity counts *coordinates*: $d$ everywhere, because a
vector in $\mathbb{R}^d$ has $d$ coordinates and each coordinate can be handled
by one generator, one maximiser, one constraint. Change the arithmetic, and the
geometry recounts.

## What is still open

Two questions sit immediately beyond the horizon. The first is the **tropical
Radon number**: can any $d+1$ points of $\mathbb{R}^d$ be split into two nonempty
groups whose tropical cone hulls intersect? The Cramer witness above says that in
each coordinate at least two rows tie for the maximum; a Radon partition is
exactly a proper two-colouring of the hypergraph whose edges are these argmax
sets. Every edge has size at least two — but a hypergraph with $d$ edges of size
$\ge 2$ on $d+1$ vertices can still fail to be two-colourable (a triangle plus
isolated vertices). So one must optimise over the whole *dependence polytope* of
admissible weight vectors, not merely one point of it. The polytope is nonempty
by the Cramer theorem, which turns the conjecture into a concrete finite
optimisation.

The second is a **colourful tropical Helly theorem**: given $d$ families
("colours") of tropical cones in $\mathbb{R}^d$, if every rainbow selection has a
common point, must some single colour class have a common point? The colourful
Carathéodory theorem above is exactly the kind of ingredient such a proof needs.

The tropics, it seems, keep their own accounts — and the ledger balances one
column earlier than we expected.
