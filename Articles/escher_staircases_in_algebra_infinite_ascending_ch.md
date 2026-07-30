# The Staircase That Goes the Other Way

## An algebraic illusion, a corrected picture, and the meaning of infinite descent

A staircase in an M. C. Escher print can rise forever and still return to its beginning. The eye accepts each local step, yet the whole structure is impossible. Algebra has its own architectural temptations. Ideals—special subsets of a ring that absorb addition and multiplication—can be nested like rooms inside rooms. It is natural to ask whether an infinite sequence of ideals might climb strictly upward while somehow “looping back” through their common intersection.

A particularly seductive candidate comes from divisibility by powers of two. Consider all functions from the integers to the integers. For each nonnegative integer $n$, place a function $f$ on level $D_n$ when every value $f(z)$ is divisible by $2^n$:

$$
D_n=\{f:\mathbb Z\to\mathbb Z: 2^n\mid f(z)\text{ for every }z\in\mathbb Z\}.
$$

The proposed staircase looks infinite, and its common core really is only the zero function. But it does not ascend. It descends:

$$
D_0\supsetneq D_1\supsetneq D_2\supsetneq\cdots,
\qquad
\bigcap_{n\ge 0}D_n=\{0\}.
$$

That reversal is not a technicality. It changes an impossible loop into a familiar and useful mathematical object: a separated divisibility filtration.

## Why stronger divisibility means a smaller room

The containment direction can be settled without sophisticated machinery. If an integer is divisible by $2^{n+1}$, then it is certainly divisible by $2^n$. Therefore every function in $D_{n+1}$ belongs to $D_n$. The converse fails. The constant function

$$
f_n(z)=2^n
$$

belongs to $D_n$, because all of its values equal $2^n$, but it does not belong to $D_{n+1}$, because $2^{n+1}$ does not divide $2^n$. Thus each step is genuinely smaller than the one before it.

This is the first lesson of the staircase: a stricter condition produces fewer objects. Requiring divisibility by $2$, then by $4$, then by $8$, is like passing through successively narrower sieves. The labels increase, but the sets decrease.

The second lesson concerns the intersection. Suppose one integer $x$ is divisible by $2^n$ for every $n$. If $x\ne 0$, choose $n$ so large that $2^n>|x|$. A nonzero integer divisible by $2^n$ must have absolute value at least $2^n$, a contradiction. Hence $x=0$. Applying this argument at every input $z$ shows that a function belonging to every $D_n$ vanishes everywhere.

So the filtration is *separated*: infinitely fine divisibility detects zero exactly. This resembles many limiting constructions across mathematics and science. A signal surviving every threshold must be null; a quantity divisible by arbitrarily large scales must vanish; an object invisible at every resolution is forced into the common core.

## From arbitrary functions to integer-valued polynomials

The same phenomenon occurs in a subtler ring. Define

$$
\operatorname{Int}(\mathbb Z)
=
\{p\in\mathbb Q[X]:p(z)\in\mathbb Z\text{ for every }z\in\mathbb Z\}.
$$

These are rational-coefficient polynomials that nevertheless take integer values at every integer. They include ordinary integer-coefficient polynomials, but they also include expressions such as

$$
\binom{X}{2}=\frac{X(X-1)}{2},
$$

whose coefficients are not all integers. For each $n\ge 0$, define the ideal

$$
J_n=
\{p\in\operatorname{Int}(\mathbb Z):2^n\mid p(z)\text{ for every }z\in\mathbb Z\}.
$$

Here divisibility refers to the integer value $p(z)$. These sets are ideals: sums preserve divisibility, and multiplying a divisible-valued polynomial by any integer-valued polynomial preserves divisibility point by point.

The **Divisibility Filtration Theorem** states that for every $n$,

$$
J_{n+1}\subsetneq J_n.
$$

The proof uses the same crisp witness as before. The constant polynomial $2^n$ belongs to $J_n$ but not to $J_{n+1}$. Therefore the filtration never stabilizes.

The **Zero-Intersection Theorem** states that

$$
\bigcap_{n\ge 0}J_n=\{0\}.
$$

Indeed, if $p$ lies in every $J_n$, then for each integer $z$, the value $p(z)$ is divisible by every power of two, hence equals zero. Thus $p$ vanishes at every integer. A nonzero polynomial over a field has only finitely many roots, whereas the integers form an infinite set. Consequently $p$ is the zero polynomial.

This last step reveals why the polynomial case is richer than the function case. For functions, pointwise vanishing already is equality to zero. For polynomials, one invokes rigidity: infinitely many roots determine a polynomial completely.

## Where the alleged loop disappears

The original Escher-like intuition focused on the fact that the zero polynomial belongs to the infinite intersection and also belongs to the first ideal. But every ideal contains zero. That shared point is not a return path; it is the universal basement of ideal theory.

There is also a type mismatch hidden in the phrase “the first ideal is an element of the intersection.” The intersection is itself an ideal whose elements are ring elements, such as polynomials—not other ideals. What can be true is that a particular polynomial, especially zero, lies in every ideal. That does not make a chain loop.

Once this confusion is removed, two honest structures remain. A descending filtration can shrink forever and have zero intersection. An ascending chain can grow forever in some rings, but not in rings satisfying the ascending-chain condition. Neither phenomenon loops back.

## The ascending-chain barrier

A commutative ring is called **Noetherian** when every ascending chain of ideals stabilizes. In other words, whenever

$$
I_0\subseteq I_1\subseteq I_2\subseteq\cdots,
$$

there is an index $N$ after which no ideal changes:

$$
I_n=I_N\qquad\text{for all }n\ge N.
$$

The **Noetherian Obstruction Theorem** follows immediately: no Noetherian ring admits an infinite chain satisfying $I_n\subsetneq I_{n+1}$ for every $n$. If it did, stabilization at $N$ would force $I_N=I_{N+1}$, contradicting strict containment.

This theorem corrects two tempting comparisons. First, a polynomial ring $k[x_1,\ldots,x_m]$ in finitely many variables over a field $k$ is Noetherian. It therefore has no infinite strictly ascending chain of ideals. Its Krull dimension is $m$, but Krull dimension measures chains of *prime* ideals, not the length of an arbitrary infinite ascending chain. These are different notions.

Second, a discrete valuation ring is Noetherian, so it too forbids infinite strict ascent. Its powers of a uniformizing element form a descending chain, much like the powers-of-two filtration, not an ascending Escher staircase.

## What survives the impossible architecture

The corrected picture is more useful than the illusion. The ideals $J_n$ provide an infinite, strict, separated filtration of $\operatorname{Int}(\mathbb Z)$. It has three precise features:

1. **Antitonicity:** increasing the required exponent decreases the ideal.
2. **Strictness:** the constant polynomial $2^n$ separates consecutive levels.
3. **Separation:** membership at every level characterizes the zero polynomial.

These properties make the filtration a measuring instrument. It records how deeply a polynomial’s values are divisible by two. For a nonzero integer-valued polynomial $p$, there must be some finite level it fails to enter; otherwise it would vanish. In computational terms, sampling values can suggest a divisibility depth, while the theorem explains why no nonzero polynomial can have infinite depth.

The same architecture appears throughout mathematics. In number theory, powers of a prime define increasingly fine congruence conditions. In algebraic geometry, powers of an ideal describe infinitesimal neighborhoods. In analysis, nested scales separate visible structure from a limiting core. In digital computation, divisibility by powers of two is measured by the number of trailing binary zeros. All are staircases of resolution, descending toward what cannot be detected any further.

## A small experiment in binary depth

The filtration can be explored numerically. Given finitely many integer values, compute for each nonzero value the largest exponent $r$ for which $2^r$ divides it; this is its $2$-adic valuation. The entire list is divisible by $2^n$ exactly when its smallest valuation is at least $n$. For example, the values $12$, $20$, and $28$ have valuations $2$, $2$, and $2$, so they survive through $D_2$ but not $D_3$. By contrast, $16$, $48$, and $80$ survive through $D_4$.

Zero needs special care because it is divisible by every positive power of two. In a finite computation it may be represented by infinite valuation. This convention mirrors the theorem: only a function or polynomial whose *every* value is zero belongs to all levels. A finite sample cannot certify polynomial identity, but it can display the nesting and quickly find failures of membership. Exact symbolic reasoning supplies the global conclusion that sampling alone cannot.

The constant witnesses make strictness especially visible. At level $n$, inspect the constant value $2^n$. It passes every divisibility test up to exponent $n$ and fails the very next one. This produces a certificate for every strict inclusion, not merely evidence from a large experiment. The distinction matters: examples reveal the geometry, while a parametrized witness proves that the geometry continues without end.

## Beyond powers of two

The natural generalization replaces $2$ by an element $a$ of a domain and studies the ideals generated by $a^n$. When does

$$
\bigcap_{n\ge 0}(a^n)=\{0\}?
$$

The answer depends on the ring and leads toward classical intersection theorems. Another direction is genuine non-Noetherian ascent. In a polynomial ring with countably many variables, the ideals

$$
(x_1)\subsetneq(x_1,x_2)\subsetneq(x_1,x_2,x_3)\subsetneq\cdots
$$

really do rise forever. Each new variable witnesses strictness. Yet even this chain does not loop: it simply demonstrates failure of the ascending-chain condition.

The ring of all algebraic integers is also non-Noetherian and offers a serious setting for studying ascending chains. But before assigning a numerical “height,” one must define an invariant that does not conflate arbitrary ideal chains, prime-ideal chains, and descending filtrations.

Escher’s art works because every local step looks plausible while the global geometry refuses to exist. The algebraic version teaches the same discipline. Check the arrows. Check the types. Ask what the intersection actually contains. The impossible staircase then resolves into two coherent landscapes: strict descent toward zero, and strict ascent obstructed by Noetherianity. The illusion vanishes, but the mathematics becomes sharper.
