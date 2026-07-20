# Algebraic DNA in a Nine-Point Geometry

## How addition, triples, and broken associativity encode a geometric world

Mathematics often advances by changing what counts as a picture. A geometer may begin with points and lines, then replace the drawing by coordinates. An algebraist may go further and ask which equations those coordinates obey. In the nine-point world considered here, that last move reveals something like mathematical DNA: a tiny collection of algebraic rules controls which triples of points belong together, which transformations preserve them, and how far the geometry departs from the familiar projective plane.

The setting is the grid

$$
H=(\mathbb Z/3\mathbb Z)^2.
$$

Its nine points are ordered pairs $(a,b)$ whose coordinates are $0$, $1$, or $2$, with arithmetic performed modulo $3$. Thus $2+2=1$, and every point $x$ satisfies

$$
x+x+x=0.
$$

This exponent-three law is the first strand of the geometry’s DNA. It allows any two points $x$ and $y$ to determine a canonical third point

$$
T(x,y)=-(x+y).
$$

Because $x+y+T(x,y)=0$, the three points balance perfectly. One can think of them as a zero-sum triple. For example,

$$
T((1,0),(0,1))=-(1,1)=(2,2).
$$

The equation is elementary, but its consequences are remarkably geometric.

## A line without drawing a line

The operation $T$ has the basic behavior expected of “the third point on the line through two points.” First, it is symmetric:

$$
T(x,y)=T(y,x).
$$

The order of the first two points does not matter. Second, completion is reversible. If $z=T(x,y)$, then completing $x$ with $z$ recovers $y$:

$$
T(x,T(x,y))=y.
$$

Indeed,

$$
T(x,T(x,y))=-\bigl(x-(x+y)\bigr)=y.
$$

This identity actually holds in every abelian group, not merely in the nine-point grid.

Exponent three supplies the next crucial fact. If $x\ne y$, then $T(x,y)$ is different from both $x$ and $y$. To see why, suppose $T(x,y)=x$. Then $-(x+y)=x$, so $2x+y=0$. Since $3x=0$, subtracting the two relations gives $y=x$, contrary to the assumption. Symmetry gives the same conclusion for $y$. Therefore every distinct pair in $H$ has a unique third point, and the resulting triple consists of three distinct points.

This is a Steiner triple geometry: every pair of distinct points lies in exactly one three-point block. Here the block through $x$ and $y$ is

$$
\{x,y,-(x+y)\}.
$$

The nine points form twelve such blocks. Each block contains three pairs, and the $\binom 92=36$ pairs are partitioned among the twelve blocks. No diagram is needed; the incidence structure is already written into addition.

## The geometry moves with you

A convincing geometry should look the same after a translation. Choose any $t\in H$ and shift every point by $t$. The completion rule obeys

$$
T(x+t,y+t)=T(x,y)+t.
$$

The exponent-three law makes this work:

$$
T(x+t,y+t)=-(x+y+2t)=-(x+y)+t,
$$

because $-2t=t$ whenever $3t=0$. Thus translation carries every zero-sum triple to another triple. The twelve blocks are not isolated accidents; they form a homogeneous affine pattern.

There is a broader preservation principle. Suppose $A$ and $B$ are abelian groups and $f:A\to B$ preserves zero and addition. Then it also preserves negatives, and hence

$$
f(T(x,y))=T(f(x),f(y)).
$$

This is the Additive Preservation Theorem: every zero-preserving additive map transports third-point completion. Its proof is a one-line chain,

$$
f(-(x+y))=-f(x+y)=-(f(x)+f(y)).
$$

This theorem explains why the triple geometry survives many changes of coordinates. The visible relation “these three points belong together” is controlled by an invisible algebraic condition: additivity.

## A second operation, and a controlled failure

The same nine-point set can carry another operation, a Hall-type coordinate multiplication. Its role is not to replace addition but to enrich it. The essential distributive law says that for each fixed right-hand factor $c$, the map

$$
R_c(x)=x\circ c
$$

is additive and sends $0$ to $0$. The Additive Preservation Theorem immediately gives

$$
T(x,y)\circ c=T(x\circ c,y\circ c).
$$

In words: every right multiplication preserves the three-point completion law. This is the bridge between coordinate algebra and incidence geometry. A family of algebraic maps automatically becomes a family of triple-preserving transformations.

Yet the multiplication is deliberately unlike ordinary field multiplication. Associativity need not hold. There exist $a,b,c\in H$ for which

$$
a\circ(b\circ c)\ne(a\circ b)\circ c.
$$

To measure this defect, define the left nucleus to be the set

$$
N_{\ell}=\{a\in H: a\circ(b\circ c)=(a\circ b)\circ c\text{ for every }b,c\in H\}.
$$

The Left-Nucleus Theorem says that $N_{\ell}$ is a proper subset of $H$. At least one element fails to associate on the left with some pair of factors. The multiplication therefore carries a genuine structural defect, not merely an inconvenient presentation.

The central combined result can now be stated cleanly: in the order-nine Hall coordinate algebra, every right multiplication preserves all additive Steiner triples, while the left nucleus is proper. Preservation and failure coexist on the same carrier. The triple geometry depends only on additivity of right multiplication; nonassociativity is detected separately by the nucleus.

That separation matters. It prevents an easy but misleading slogan such as “nonassociativity destroys geometry.” Here nonassociativity does not destroy the triple pattern at all. Instead, it distinguishes this coordinate world from a classical field-coordinatized one while leaving a robust combinatorial skeleton intact.

## A widening symmetry gap

The distinction is also quantitative. Let $q\ge 3$ index the relevant Hall family, let $C(q)$ denote its collineation-order count, and let $P(q^2)$ denote the corresponding projective-linear benchmark over a field of size $q^2$. The Symmetry-Gap Theorem states two inequalities:

$$
C(q)<P(q^2)
$$

and

$$
q^4\le \left\lfloor\frac{P(q^2)}{C(q)+1}\right\rfloor.
$$

The first says that the Hall-family geometry has strictly fewer symmetries than the classical projective-linear comparison. The second says much more: the ratio is bounded below by a fourth-degree polynomial. As $q$ grows, this is not a tiny finite anomaly. The relative shortage of symmetry becomes parametrically large.

This theorem should be read with care. A smaller symmetry count does not by itself classify a geometry, and a nonassociative coordinate law is not, by itself, a complete incidence proof of every geometric property one might desire. What the result establishes is precise: a strict and polynomially amplified gap from the projective-linear benchmark.

## Why call this algebraic DNA?

DNA is not an organism; it is a compact set of instructions whose expression appears at many scales. The analogy is useful here because a few laws repeatedly reappear in different guises.

The relation $3x=0$ produces genuine three-point blocks. The formula $T(x,y)=-(x+y)$ gives unique completion. Additivity explains invariance under maps and right multiplication. Nonassociativity carves out a proper nucleus. Family-level order estimates reveal a growing symmetry deficit. Each layer expresses a different consequence of the same coordinate design.

There is also a lesson for logic. A mathematical theory is not only a list of sentences. It is a landscape of models and structure-preserving maps. Changing an axiom can preserve some constructions, destroy others, and create new comparison maps between the old and new model worlds. The nine-point example makes that philosophy concrete without requiring grand abstractions: one may alter associativity while retaining an additive triple geometry. The “mutation” changes one structural layer but leaves another inherited pattern intact.

This suggests a disciplined way to compare theories. Instead of asking only whether two axiom lists look alike, ask which objects they admit, which transformations survive, which closure operations appear, and which invariants measure the difference. In this small geometry, the answers are explicit: twelve triples survive every additive right action, the associativity nucleus does not fill the space, and the symmetry count falls polynomially behind its classical counterpart.

## A finite laboratory with infinite lessons

Because the universe has only nine points, every claim has a tangible combinatorial shadow. There are $\binom{9}{2}=36$ unordered pairs. Each three-point block contains exactly three pairs, so unique completion forces the number of blocks to be

$$
\frac{36}{3}=12.
$$

One can list all twelve, follow how a translation permutes them, and test any proposed additive transformation on the entire grid. This makes the geometry an unusually clear laboratory for a distinction that becomes harder to see in large or infinite systems: preserving an incidence relation is not the same as preserving every operation available on the coordinates.

Imagine that the twelve blocks are communication channels joining triples of stations. A translation relabels all stations without changing the network. An additive map may merge or rearrange stations, but it always sends a completed channel to a completed channel. Right multiplication supplies another systematic family of channel-preserving maps. Yet an engineer composing three multiplicative operations must still care about parentheses, because the two orders of composition can disagree. The same device is reliable with respect to one protocol and nonclassical with respect to another.

That viewpoint has practical resonance in coding theory and experimental design, where Steiner systems organize pairs into unique blocks. It also echoes software interfaces: a transformation can honor a specified contract without preserving every feature of the implementation beneath it. Here the contract is the zero-sum relation, and additivity is the exact condition that enforces it.

A nine-point universe is small enough to fit on a page, but rich enough to demonstrate a broad principle. Geometry can be encoded in operations; operations can preserve structure even while violating familiar laws; and the most revealing invariant may be neither a picture nor a formula alone, but the pattern of transformations connecting them. That pattern is the algebraic genome of the world.