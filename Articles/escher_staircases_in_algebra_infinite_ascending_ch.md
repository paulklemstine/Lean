# Escher Staircases in Algebra: When Climbing Forever Means Noetherianity Has Failed

Imagine walking up a staircase in an M. C. Escher print. Every step is genuinely higher than the last, yet the architecture seems to fold back toward its beginning. Algebra has a structure with a similar visual flavor: an infinite sequence of ideals

$$
I_0 \subsetneq I_1 \subsetneq I_2 \subsetneq \cdots.
$$

Each inclusion is strict. At every stage, the next ideal contains something new. Such a chain will be called an **Escher staircase**. The name is picturesque, but the mathematics behind it is precise: the existence of this staircase is exactly the failure of one of commutative algebra's central finiteness conditions.

The story also contains a warning. A seductive first example—requiring values to be divisible by larger and larger powers of $2$—points in the wrong direction. Correcting that reversal reveals what the staircase really measures, why some enormous rings contain one, and why the infinite-looking world of $p$-adic integers does not.

## What is an ideal staircase?

A commutative ring is a system in which elements can be added, subtracted, and multiplied. An **ideal** $I$ is a subset closed under addition and under multiplication by arbitrary ring elements. Ideals package divisibility, equations, and quotient constructions. In the integers, every ideal has the form $m\mathbb Z$. In a polynomial ring, ideals may encode simultaneous algebraic equations.

An Escher staircase in a commutative ring $R$ is a sequence of ideals $(I_n)_{n\ge 0}$ satisfying

$$
I_m \subsetneq I_n \qquad \text{whenever }m<n.
$$

Equivalently, every adjacent step is strict: $I_n\subsetneq I_{n+1}$. The crucial word is *infinite*. A finite chain of strict containments is ordinary. An endless chain says that no finite stage captures everything accumulated later.

A ring is **Noetherian** when every ascending chain of ideals eventually stabilizes. Thus, whenever

$$
J_0\subseteq J_1\subseteq J_2\subseteq\cdots,
$$

there is some $N$ such that $J_n=J_N$ for all $n\ge N$. Noetherianity is the algebraic principle that growth cannot continue forever. It underlies finite descriptions of systems of polynomial equations and makes many algebraic procedures terminate.

The central result is therefore both simple and definitive.

**Staircase Characterization Theorem.** *A commutative ring has an Escher staircase if and only if it is not Noetherian.*

The forward implication is immediate from the meaning of Noetherianity: a strictly growing chain never stabilizes. For the reverse implication, if a ring is not Noetherian, then some ascending chain fails to stabilize. From that chain, choose a first rung, then a later strictly larger rung, then a later strictly larger rung again. Repeating this extraction produces an infinite strict chain.

So staircase existence is not a new independent invariant. It is a vivid restatement of failure of the ascending chain condition.

## A staircase made from integer sequences

The cleanest concrete model lives in the ring

$$
R=\prod_{k\in\mathbb N}\mathbb Z,
$$

the set of all integer sequences $a=(a_0,a_1,a_2,\ldots)$, with addition and multiplication performed coordinate by coordinate.

For each $n\ge 0$, define

$$
S_n=\{a\in R: a_k=0\text{ for every }k\ge n\}.
$$

Thus $S_n$ consists of sequences supported only among the first $n$ coordinates. The first few rungs look like

$$
S_0=\{(0,0,0,\ldots)\},
$$

$$
S_1=\{(a_0,0,0,\ldots):a_0\in\mathbb Z\},
$$

$$
S_2=\{(a_0,a_1,0,0,\ldots):a_0,a_1\in\mathbb Z\}.
$$

Each $S_n$ is an ideal. Adding two sequences that vanish from position $n$ onward preserves that property. Multiplying such a sequence coordinatewise by any sequence also leaves every coordinate from $n$ onward equal to zero.

The inclusions $S_n\subseteq S_{n+1}$ are clear: if a sequence vanishes at every coordinate $k\ge n$, it certainly vanishes at every coordinate $k\ge n+1$. They are strict because the sequence with a single $1$ in coordinate $n$ and zeros elsewhere belongs to $S_{n+1}$ but not to $S_n$. Hence

$$
S_0\subsetneq S_1\subsetneq S_2\subsetneq\cdots
$$

is an Escher staircase.

This example explains the architectural metaphor. The intersection of all rungs is

$$
\bigcap_{n\ge 0}S_n=S_0=\{0\}.
$$

There is no paradox here. Because the chain is ascending, its intersection is automatically its smallest member. The staircase “returns to its beginning” only in the sense that the common core of every rung is exactly the starting ideal.

This observation corrects a possible type confusion. The intersection of ideals contains ring elements, not ideals. Saying that $I_0$ is “an element” of $\bigcap_n I_n$ is therefore not meaningful. One may say either that the zero element belongs to every ideal—which is always true—or that $I_0$ equals the intersection—which is automatic for any ascending chain indexed from its least rung. The real mathematical content is strict growth without end.

## The divisibility staircase that descends

Now consider functions $f:\mathbb Z\to\mathbb Z$. For each $n$, let

$$
D_n=\{f:2^n\text{ divides }f(z)\text{ for every }z\in\mathbb Z\}.
$$

At first glance, increasing $n$ may feel like increasing the rung. In fact, it strengthens the requirement. Every multiple of $2^{n+1}$ is a multiple of $2^n$, so

$$
D_{n+1}\subseteq D_n.
$$

The containment is strict. The constant function $f(z)=2^n$ lies in $D_n$, but it does not lie in $D_{n+1}$. Therefore

$$
D_0\supsetneq D_1\supsetneq D_2\supsetneq\cdots.
$$

This is a strictly descending chain, not an Escher staircase. The same inclusion argument applies when the functions are restricted to a suitable subring, such as integer-valued polynomials. Divisibility by a higher prime power produces a smaller ideal.

The distinction matters computationally. Ascending chains model the progressive addition of generators or consequences; descending chains model increasingly stringent congruence or vanishing conditions. Confusing their orientations can reverse the conclusion of an entire construction.

## Infinitely many variables versus finitely many

A second explicit staircase appears in a polynomial ring with countably many indeterminates,

$$
k[x_0,x_1,x_2,\ldots].
$$

Let

$$
J_n=(x_0,x_1,\ldots,x_{n-1}).
$$

Then $J_n\subsetneq J_{n+1}$, because $x_n$ belongs to $J_{n+1}$ but not to $J_n$. The latter fact can be seen by setting $x_0,\ldots,x_{n-1}$ equal to zero while leaving $x_n$ untouched: every element of $J_n$ vanishes under this specialization, but $x_n$ does not. Thus countably many variables provide an endless supply of genuinely new generators.

By contrast, for a field $k$, the finite-variable ring

$$
k[x_1,\ldots,x_d]
$$

is Noetherian. This is Hilbert's basis theorem iterated $d$ times. Consequently it has no Escher staircase, regardless of the number $d$ of variables.

This separates two notions that may look deceptively similar. The ring $k[x_1,\ldots,x_d]$ has Krull dimension $d$, a measure based on chains of prime ideals. But it does not have an infinite ascending chain of arbitrary ideals. Krull dimension and failure of Noetherianity measure different aspects of a ring. Therefore one cannot define an “Escher height” by declaring it equal to the number of variables while also defining a staircase as an infinite ascending ideal chain.

## Why the $p$-adic integers stop the climb

The $p$-adic integers $\mathbb Z_p$ contain infinitely detailed information about divisibility by a prime $p$. Their elements have expansions extending forever,

$$
a_0+a_1p+a_2p^2+\cdots,
$$

with digits $0\le a_i<p$. That infinite expansion might suggest endless ideal complexity. Yet $\mathbb Z_p$ is a discrete valuation ring. Its nonzero ideals are exactly

$$
(p^m),\qquad m\ge 0.
$$

These ideals form a descending tower as $m$ increases:

$$
\mathbb Z_p\supsetneq(p)\supsetneq(p^2)\supsetneq\cdots.
$$

Ascending chains move in the opposite direction and must terminate after finitely many steps. Since a discrete valuation ring is Noetherian, the Staircase Characterization Theorem implies that $\mathbb Z_p$ has no Escher staircase.

This is an instructive contrast. An object may be infinite, topologically subtle, and built from arbitrarily high powers of a prime, yet still satisfy a powerful algebraic finiteness condition.

## What remains of “height”?

If staircase existence is exactly non-Noetherianity, then a numerical height requires a different definition. Counting the length of a chain indexed by the natural numbers gives the same answer—countably infinite—whenever a staircase exists. Taking the intersection adds nothing when the chain begins with its least member. And Krull dimension cannot be substituted without changing the subject.

A useful refined invariant might instead measure ordinal lengths of chains, restrict which ideals are allowed, track numbers of generators, or quantify how quickly finite computations encounter new generators. Each choice would need invariance proofs and examples separating it from established dimensions.

The ring of all algebraic integers presents a compelling test case, but it must first be specified precisely, for example as the integral closure of $\mathbb Z$ in a chosen algebraic closure of $\mathbb Q$. A promising route to non-Noetherianity is to choose compatible roots of a prime and orient the resulting principal ideals carefully. Once non-Noetherianity is established, an Escher staircase follows from the characterization theorem. What does not follow is a canonical numerical height.

## The lesson of the impossible staircase

The metaphor survives, but in a sharpened form. An Escher staircase is not mysterious extra structure hidden inside selected rings. It is the visible footprint of a familiar failure: ideals can keep acquiring new content forever.

The integer-sequence ring displays that failure coordinate by coordinate. The countably generated polynomial ring displays it variable by variable. Finite polynomial rings and $p$-adic integers block it through Noetherianity. The power-divisibility construction teaches a complementary lesson: stronger divisibility conditions descend rather than ascend.

Algebra often advances through such acts of orientation. Which way does inclusion run? What sort of object belongs to an intersection? Is an apparent new invariant genuinely new, or an old condition in new architectural clothing? Once those questions are answered, the impossible staircase becomes possible to understand: not a loop in logic, but an endless ascent whose common foundation remains the point from which it began.
