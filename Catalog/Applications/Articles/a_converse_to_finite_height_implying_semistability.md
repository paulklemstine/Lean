# The Shadow on the Special Divisor: How a Determinant Decides Whether a Symmetry Has Finite Height

## A question hiding inside number theory

Some of the deepest objects in modern number theory are not numbers at all, but *symmetries*. When mathematicians want to understand a solution to an equation — say, the points of an elliptic curve, or the way a prime number factors as you climb a tower of field extensions — they package that information into a **Galois representation**: a recipe that assigns to each symmetry of the number system a matrix, in a way that respects how symmetries compose.

For the local, $p$-adic world (where we zoom in on a single prime $p$ and work with the $p$-adic numbers), these representations come in a bewildering zoo of flavors. Two of the most important species are the **finite-height** representations and the **semistable** ones. The first is an *integral*, lattice-theoretic notion: it says that a certain linearized Frobenius operator — a kind of $p$-power map at the heart of the structure — is "almost invertible," failing to be invertible only in a controlled way. The second, semistability, is an *analytic* notion: it says the representation behaves nicely after a single, well-understood degeneration.

A landmark theorem of Mark Kisin ties these two worlds together. Lattices inside semistable representations, with their Hodge–Tate weights bounded by some integer $h$, correspond *exactly* to finite-height objects of height $\le h$. In a sentence: **finite height is the integral shadow of semistability.** One direction of this correspondence is the "easy half" — finite height forces good generic behavior. The other direction — that good generic behavior actually *manufactures* a finite-height lattice out of thin air — is the part that makes the whole theory usable.

This article is about a clean, completely rigorous core of that converse. We strip away the heavy machinery of $p$-adic Hodge theory and isolate the **exact linear-algebra heart** of the statement. What survives is startlingly simple, and it can be checked by hand on a $2\times 2$ matrix. The punchline: a single number — a determinant's divisibility — decides everything.

## The cast of characters

Let me set the stage with as little jargon as possible.

Fix a commutative ring of coefficients $\mathfrak{S}$. (In the real theory this is a power series ring $W(k)[[u]]$, but nothing below needs that — any commutative ring works, which is part of the beauty.) Inside $\mathfrak{S}$ we single out a special element $E$. In the geometric picture, $E = E(u)$ is an **Eisenstein polynomial** whose vanishing carves out the *special divisor* — the one place where things are allowed to degenerate. Think of $E$ as marking a single forbidden point on a line, and everything in the story is about what happens *at* that point versus *away* from it.

A **Breuil–Kisin module** is then a remarkably economical gadget. After choosing a basis, all of its essential data collapses into one square matrix:

$$A \in M_n(\mathfrak{S}),$$

the matrix of the *linearized Frobenius* $\Phi$. The integer $n$ is the **rank** — the dimension of the underlying space, the number of basis vectors.

That's it. A module is a rank and a matrix. The entire drama plays out in the entries of $A$.

## What "finite height" really means

The Frobenius $\Phi$ does not have to be invertible — if it were, the theory would be trivial. The question is *how badly* it fails to be invertible, and whether that failure is concentrated at the special divisor $E$.

We say the module **has $E$-height $\le h$** if there exists a companion matrix $B$, with entries still in $\mathfrak{S}$ (no fractions allowed!), such that

$$A \cdot B = E^h \cdot I \qquad \text{and} \qquad B \cdot A = E^h \cdot I.$$

Read this carefully. It says: $A$ is invertible *up to a factor of $E^h$*. Its inverse exists, but you have to pay for it in powers of $E$ — and only in powers of $E$. The failure of $A$ to be invertible is entirely a failure "at the special divisor." The module is of **finite height** if this holds for *some* $h$:

$$\text{FiniteHeight}(A) \iff \exists h,\ \exists B,\quad AB = BA = E^h I.$$

This is exactly the integral shadow of "semistable with Hodge–Tate weights bounded by $h$." The number $h$ is the lattice-theoretic avatar of the weights.

There is a special, sharpest case. **Height $0$** means $A B = B A = I$ outright — $A$ is genuinely invertible over $\mathfrak{S}$. This is the **étale** or **unramified** case: the Frobenius is already an isomorphism, nothing degenerates anywhere, and the representation is as tame as possible.

## The bold claim: it's all in the determinant

Here is where the story turns. The definition of finite height *looks* like it quantifies over the entire module — you must conjure up a whole matrix $B$ and verify two matrix equations. That's a lot of data to check. The central insight is that all of this collapses to a single scalar condition.

Define a module to be **Newton-concentrated** if its determinant divides a power of $E$:

$$\text{NewtonConcentrated}(A) \iff \exists N,\quad \det A \mid E^N.$$

In words: the *only* prime factor of $\det A$ that matters is $E$ itself. The determinant's "Newton slopes" all sit on the special divisor. Geometrically, $A$ becomes invertible the instant you move away from the point $V(E)$ — its determinant vanishes nowhere else.

The headline theorem is that these two notions — one about the whole matrix, one about a single number — are the *same*:

$$\boxed{\ \text{FiniteHeight}(A)\ \iff\ \text{NewtonConcentrated}(A)\ }$$

This is the equivalence `finiteHeight_iff_newton`. One implication is the "easy half"; the other is the celebrated converse, and it is *constructive*.

## Why the converse is the surprising half

The forward direction — finite height implies the determinant condition — is a one-line miracle of linear algebra. If $A B = E^h I$, take determinants of both sides. The determinant of a product is a product of determinants, and the determinant of $E^h I$ for an $n \times n$ matrix is $(E^h)^n = E^{hn}$. So

$$\det A \cdot \det B = E^{h \cdot n},$$

which says precisely that $\det A$ divides $E^{h \cdot n}$. The module is Newton-concentrated, with the explicit budget $N = h \cdot n$. This is `finiteHeight_implies_newton`. Intuitively: each of the $n$ basis vectors contributes at most $h$ worth of "weight," so the total weight carried by the determinant is at most $h \cdot n$.

The reverse direction — `newton_implies_finiteHeight` — is the prize, and it is not a formality. We are *given only a number* (the determinant divides $E^N$) and we must *produce an entire matrix* $B$ witnessing finite height. The construction is a gem of classical algebra. The key tool is the **adjugate** (the classical adjoint), the matrix $\operatorname{adj}(A)$ whose defining property is the beautiful identity

$$A \cdot \operatorname{adj}(A) = \operatorname{adj}(A) \cdot A = (\det A) \cdot I.$$

The adjugate always exists, always has entries in $\mathfrak{S}$ (it's built from minors — sums and products of entries, no division), and it turns $A$ into its own determinant. Now suppose $\det A \mid E^N$, meaning $E^N = \det A \cdot c$ for some $c \in \mathfrak{S}$. Set

$$B := c \cdot \operatorname{adj}(A).$$

Then watch the magic:

$$A \cdot B = c \cdot \big(A \cdot \operatorname{adj}(A)\big) = c \cdot (\det A) \cdot I = E^N \cdot I,$$

and symmetrically $B \cdot A = E^N \cdot I$. We have manufactured, from nothing but a divisibility of scalars, an honest two-sided witness to height $\le N$. The lattice appears, fully formed, out of a single number. This is the exact linear-algebra shadow of Kisin's deep theorem that semistability builds a finite-height lattice.

And the height bound is sharp in the natural sense: the module has height **at most $N$** whenever $\det A \mid E^N$, the precise avatar of "Hodge–Tate weights $\le N$."

## A determinant is enough — the rank-one principle

Because everything reduces to $\det A$, finite height is detected by a *rank-one* object: the top exterior power $\wedge^{\mathrm{top}}$, the "determinant line" of the module. In the arithmetic, this line is the cyclotomic-twist datum that carries the *total* Hodge–Tate weight of a semistable representation. The theorem `finiteHeight_iff_det` makes this faithful: a module is of finite height **if and only if** its determinant line is. A high-dimensional integrality condition is decided by a one-dimensional companion.

This has immediate structural consequences. Finite height is closed under direct sums (`finiteHeight_directSum`): if you stack two finite-height modules into a block-diagonal Frobenius, the determinant of the whole is the product of the determinants, so Newton-concentration is inherited. Heights are monotone (`hasHeightLE_mono`): height $\le h$ implies height $\le h'$ for any $h' \ge h$, simply because $E^h \mid E^{h'}$ lets you scale the witness. And the zero-rank module — the empty matrix, with determinant $1$ — is crystalline of height $0$, exactly as the zero representation should be.

## The counterexample that proves it's a theorem

It would all be hollow if every matrix were Newton-concentrated. It is not, and one tiny example shows why the converse has real content. Work over the polynomial ring $\mathfrak{S} = \mathbb{Q}[X]$ with special element $E = X$.

- The $1\times 1$ module $A = [X^2]$ **has finite height**: $\det A = X^2$ divides $X^2 = E^2$, so height $\le 2$. (`example_finiteHeight`)
- The module $A = [1]$ **has height $0$**: it is already invertible, $\det A = 1$ is a unit. This is the étale case. (`example_etale`)
- The module $A = [X+1]$ has **no finite height at all**. (`example_not_finiteHeight`)

That last one is the heart of the matter. The matrix $[X+1]$ is a perfectly respectable integral Frobenius. But its determinant is $X+1$, and $X+1$ *never* divides any power of $X$: plug in $X = -1$ and $X^N$ becomes $(-1)^N \ne 0$, while $X+1$ becomes $0$, so $X+1$ cannot be a factor. Geometrically, the Frobenius $[X+1]$ degenerates at the point $X = -1$ — *away* from the special divisor $X = 0$. Its failure to be invertible is in the wrong place. No amount of cleverness can produce a finite-height lattice, because the degeneration simply isn't concentrated where the theory demands.

This single example is what upgrades the converse from a tautology to a theorem. Newton-concentration is *not automatic*; it is a genuine constraint that some matrices satisfy and others violate, and the theorem says it is *exactly* the constraint that finite height imposes.

## Why this matters

Step back and consider what has happened. A condition from the frontier of arithmetic geometry — finite height, the integral fingerprint of semistability — has been distilled into a statement a student could verify: *does the determinant divide a power of the special element?* The deep theorem of Kisin, that semistable representations possess finite-height lattices, has a transparent, constructive linear-algebra core whose proof fits in a paragraph and whose witness is written down by the adjugate formula.

There is a recurring lesson here that runs through much of modern mathematics: the most imposing structural conditions often have a humble shadow, and finding that shadow is half the battle. The Frobenius on a Breuil–Kisin module looks like an object that must be understood in its full glory. But for the single question "is the height finite?", the entire module can be replaced by one number, and the answer is read off by a high-school divisibility test — *does $\det A$ live on the special divisor, or does it stray?*

The companion theory of $\mathrm{GL}(1)$ and $\mathrm{GL}(2)$ representations describes Frobenius *eigenvalues* on the generic fiber, the analytic face governed by the Weil bounds. The result here supplies the *integral* counterpart: a Frobenius lattice has finite height precisely when its determinant's Newton slopes sit on the special divisor — and when they do, the lattice can be built by hand. Two faces of the same local arithmetic, one analytic and one integral, meeting in a determinant.

The natural next questions write themselves. Does height add under tensor products of modules? Is finite height preserved under duality? Can one read the *exact, minimal* height not from the determinant alone but from the finest invariants of the matrix — its Smith normal form? Each is a precise, falsifiable conjecture, and each begins exactly where this story ends: with a matrix, a special element, and the determinant that decides their fate.
