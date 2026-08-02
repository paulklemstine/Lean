# The Secret Geometry of Every Binary Rule

A binary operation is one of mathematics’ simplest machines. Feed it two elements $a$ and $b$ from a set $X$, and it returns a new element $f(a,b)$. Addition, multiplication, maximum, logical conjunction, and the rule “choose the first input” are familiar examples. Yet if one gathers *all* binary operations on $X$ into a single space, an unexpectedly rich algebra appears.

The key is to define a way of multiplying operations. Given two binary operations $f$ and $g$, set

$$
(f\star g)(a,b)=g\bigl(f(a,b),f(b,a)\bigr).
$$

This is not ordinary function composition. The inner rule $f$ is asked the question twice, once in each order. Its two answers become the inputs to $g$. The construction remembers the asymmetry between $a$ and $b$, but packages that asymmetry in a remarkably manageable way.

At first glance, studying every possible multiplication table at once looks hopeless. If $X$ has $n$ elements, then there are $n^{n^2}$ binary operations. Even for $n=3$, that is $3^9=19{,}683$ tables. The decisive idea is to stop viewing an operation as a table and instead let it move ordered pairs.

## From multiplication tables to motion

To every operation $f$ associate the transformation

$$
P_f(a,b)=\bigl(f(a,b),f(b,a)\bigr)
$$

of the pair space $X\times X$. Call this the **pair transformation** of $f$. It records exactly the two evaluations needed by the product $\star$.

Now comes the bridge on which the whole theory rests:

$$
P_{f\star g}=P_g\circ P_f.
$$

Multiplying operations becomes composing transformations. The order on the right is important: first $P_f$ moves the pair, then $P_g$ moves the result. Associativity of $\star$ is now natural, because composition of transformations is associative. Explicitly,

$$
(f\star g)\star h=f\star(g\star h)
$$

for all binary operations $f,g,h$.

There is also an identity operation. Define $\lambda(a,b)=a$, the rule that always selects the left input. Then

$$
\lambda\star f=f=f\star\lambda.
$$

Thus all binary operations on $X$, equipped with $\star$, form a monoid: an associative system with an identity.

The pair viewpoint loses no information. The first coordinate of $P_f(a,b)$ is precisely $f(a,b)$, so if $P_f=P_g$, then $f=g$. Better still, one can say exactly which transformations of $X\times X$ arise this way.

Let $S(a,b)=(b,a)$ reverse a pair. Every pair transformation respects reversal:

$$
P_f\circ S=S\circ P_f.
$$

Conversely, if a transformation $T:X\times X\to X\times X$ commutes with $S$, define $f(a,b)$ to be the first coordinate of $T(a,b)$. Commutation with reversal forces the second coordinate of $T(a,b)$ to be $f(b,a)$. Therefore $T=P_f$.

This is the **Pair-Transformation Characterization**: a transformation of ordered pairs comes from a unique binary operation exactly when it commutes with pair reversal. The enormous universe of multiplication tables is therefore identical, as an algebraic object, to the transformation system possessing one simple symmetry.

## Stable rules and retractions

An element $f$ of the magma monoid is called **idempotent** when applying it twice under $\star$ changes nothing:

$$
f\star f=f.
$$

Through the pair transformation, this becomes $P_f\circ P_f=P_f$. Such a transformation is a retraction: after points have landed in its image, it fixes them.

This gives the **Idempotence Criterion**:

> A binary operation $f$ satisfies $f\star f=f$ if and only if $P_f(p)=p$ for every point $p$ in the image of $P_f$.

The proof is a one-line dynamical argument. If $p=P_f(q)$, then idempotence gives $P_f(p)=P_f(P_f(q))=P_f(q)=p$. Conversely, if every image point is fixed, then $P_f(P_f(q))=P_f(q)$ for every $q$; faithfulness of the pair representation returns $f\star f=f$.

This criterion turns an algebraic equation between operation tables into a picture: every arrow in the directed graph of $P_f$ must land immediately at a fixed point. There can be no nontrivial cycles and no chains of length two before stabilization.

A broad source of examples follows. Suppose $f$ is commutative and pointwise idempotent, meaning

$$
f(a,b)=f(b,a),\qquad f(a,a)=a.
$$

Then $f$ is idempotent in the magma monoid. Indeed,

$$
(f\star f)(a,b)=f\bigl(f(a,b),f(b,a)\bigr)
=f\bigl(f(a,b),f(a,b)\bigr)=f(a,b).
$$

Thus familiar semilattice operations such as minimum and maximum belong to the stable part of this monoid.

## Why the diagonal matters

Inside $X\times X$ sits the diagonal

$$
\Delta=\{(x,x):x\in X\}.
$$

It is the fixed-point set of reversal. Two diagonal subsets associated with $f$ reveal how symmetric outputs arise.

The **diagonal image** is

$$
D_f=P_f(\Delta)=\{(f(x,x),f(x,x)):x\in X\}.
$$

The **commutative image** is the diagonal portion of the full image,

$$
C_f=\operatorname{im}(P_f)\cap\Delta.
$$

A point $(y,y)$ lies in $C_f$ when some possibly unequal pair $(a,b)$ produces equal forward and reverse values: $f(a,b)=f(b,a)=y$. By contrast, it lies in $D_f$ when $y=f(x,x)$ for some diagonal input.

Always $D_f\subseteq C_f$, because diagonal inputs necessarily have diagonal outputs. Equality is the interesting condition: every symmetric output obtainable anywhere is already obtainable from a symmetric input.

The **Diagonal Equality Theorem for Idempotents** states that if $f\star f=f$, then

$$
C_f=D_f.
$$

To see why, suppose $f(a,b)=f(b,a)=y$. Idempotence evaluated at $(a,b)$ gives

$$
f(y,y)=f\bigl(f(a,b),f(b,a)\bigr)=f(a,b)=y.
$$

Hence $P_f(y,y)=(y,y)$, so the diagonal point already comes from a diagonal input. The reverse inclusion is automatic.

## Reversibility without invertibility

Semigroup theory has a flexible notion of reversibility. An operation $f$ is **regular** if there exists another operation $g$ such that

$$
(f\star g)\star f=f.
$$

The rule $g$ is an inner inverse: it need not undo $f$ everywhere, but it permits every output of $f$ to be reconstructed after a detour.

Regularity also forces diagonal equality:

> **Diagonal Equality Theorem for Regular Operations.** If $(f\star g)\star f=f$ for some $g$, then $C_f=D_f$.

Suppose $(x,x)$ occurs in the image of $P_f$, say $f(a,b)=f(b,a)=x$. Evaluating the regularity identity at $(a,b)$ yields

$$
f\bigl(g(x,x),g(x,x)\bigr)=x.
$$

Thus $(x,x)$ is the image under $P_f$ of the diagonal input $(g(x,x),g(x,x))$. Again, symmetric output can be witnessed symmetrically.

This result is subtle because regularity concerns a three-stage algebraic process, while its consequence is a geometric statement about where the image meets the diagonal. It is precisely the pair-transformation bridge that makes the connection transparent.

## The operation that flips the world

Two especially simple operations illuminate the monoid’s internal symmetry. We have already met the left selector $\lambda(a,b)=a$, the identity. Define the right selector $\rho(a,b)=b$. Multiplying by $\rho$ on either side reverses the arguments of any operation:

$$
f\star\rho=\rho\star f=f^{\mathrm{op}},
\qquad
f^{\mathrm{op}}(a,b)=f(b,a).
$$

Consequently, $\rho$ commutes with every operation. It is also an involution:

$$
\rho\star\rho=\lambda.
$$

So $\rho$ is a unit of order two, and in particular it is regular. In the pair picture, $P_\rho$ is simply the reversal map $S$. The abstract algebraic act of multiplying by the right selector is literally a mirror flip of pair space.

## A small laboratory on three symbols

Take $X=\{0,1,2\}$ and let $f(a,b)=\min(a,b)$. Because minimum is commutative and satisfies $\min(a,a)=a$, it is idempotent in the magma monoid. Its pair transformation collapses every ordered pair onto the diagonal:

$$
P_f(a,b)=\bigl(\min(a,b),\min(a,b)\bigr).
$$

For example, both $(2,1)$ and $(1,2)$ move to $(1,1)$. Once there, another application leaves the point fixed. The nine vertices of $X\times X$ therefore drain in one step into the three diagonal fixed points $(0,0)$, $(1,1)$, and $(2,2)$. This is the retraction picture in its cleanest form.

Contrast this with the right selector $\rho$. Its pair transformation swaps the coordinates. The diagonal points stay fixed, but $(0,1)$ and $(1,0)$ form a two-cycle. Thus $\rho$ is not idempotent when $X$ has more than one element. It is nevertheless regular—and indeed invertible—because a second swap restores every pair. Idempotence and regularity are genuinely different kinds of stability: one means “settle after one step,” while the other means “recover through a suitable return trip.”

There is also a quick way to prove that some rules are not regular. On $X=\{0,1\}$, consider the table

$$
f(0,0)=0,\quad f(0,1)=1,\quad f(1,0)=1,\quad f(1,1)=0.
$$

The off-diagonal input $(0,1)$ maps to $(1,1)$, so $(1,1)$ lies in $C_f$. Yet both diagonal inputs map to $(0,0)$, so $(1,1)$ does not lie in $D_f$. Therefore $C_f\ne D_f$, and the diagonal equality theorem rules out regularity immediately. A potentially difficult search through every candidate inner inverse is replaced by inspection of two small sets.

## A reusable lens

The pair-transformation perspective does more than shorten proofs. It changes what one sees. Binary operations become equivariant dynamics on a square. Idempotents become retractions. Regularity becomes partial recoverability. Commutativity appears as contact with the diagonal. Argument reversal becomes multiplication by a central involution.

These ideas connect semigroup theory with finite-state dynamics, network flow, and computation. On a finite set, one can draw the directed graph of $P_f$, test idempotence by checking whether every image vertex is fixed, and inspect diagonal equality by comparing two finite sets. The apparent complexity of $n^{n^2}$ operation tables is reorganized by symmetry into transformations of $n^2$ states.

The approach also suggests a practical workflow. Given a finite table, build its directed graph on ordered pairs. Color the diagonal, mark the image, and ask which image vertices are fixed. Idempotence is then visible at a glance. Next compare diagonal outputs arising from all inputs with those arising from diagonal inputs alone. A mismatch is not merely suggestive: it is a proof that regularity fails. What began as symbolic manipulation becomes a finite geometric inspection.

This translation matters whenever a rule treats input order asymmetrically. Computer programs, voting procedures, routing policies, and update rules often distinguish “first” from “second.” Recording both orientations at once exposes whether the resulting process respects reversal, settles immediately, or can be recovered after information has been compressed. The abstract setting makes no claim that every application has the same interpretation, but it supplies a common structural vocabulary.

The larger lesson is a classic mathematical one: the right representation can turn a strange multiplication into ordinary composition. Once that happens, algebra, geometry, and dynamics begin speaking the same language.