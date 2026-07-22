# Saucer Wisdom: Would Other Minds Discover Our Mathematics?

Imagine a radio telescope receiving not a greeting, but a sequence:

$$
2,3,5,7,11,13,17,19,\ldots
$$

We would probably interpret it as deliberate. These are the prime numbers, the indivisible atoms of ordinary multiplication. Yet that familiar thought experiment hides a difficult question. Would another intelligence—alien, artificial, or descended along an evolutionary path unlike ours—organize mathematics as we do? Or would its mathematics be so different that even our most basic concepts would fail to translate?

A useful answer begins by separating three ideas that are often blended together: logical inheritance, geometric choice, and structural invariance. Logical inheritance explains why old conclusions survive when assumptions are added. Geometric choice shows why some famous principles are not forced by logic alone. Structural invariance explains why primes survive faithful changes of notation, while also revealing how radically arithmetic changes when the operation itself changes.

## What “universal” can mean

Let a *statement space* be any collection of possible mathematical assertions. A theory is a set $\Gamma$ of such statements. Associate to each theory its *closure* $C(\Gamma)$, the set of all consequences of $\Gamma$. We ask only that closure behave rationally:

1. Every assumption is among its own consequences: $\Gamma\subseteq C(\Gamma)$.
2. Adding assumptions cannot remove consequences: if $\Gamma\subseteq\Delta$, then $C(\Gamma)\subseteq C(\Delta)$.
3. Taking consequences twice adds nothing new: $C(C(\Gamma))=C(\Gamma)$.

A theory is called *consistent* here when it does not entail every possible statement, so $C(\Gamma)$ is not the whole statement space. Given a base theory $B$, define its *universal core* to consist of every statement that follows from every consistent extension of $B$.

This definition yields a clean theorem.

**Universal Core Theorem.** If $B$ is consistent, then the universal core over $B$ is exactly $C(B)$, the ordinary consequence set of $B$.

The reason is almost disarmingly simple. By monotonicity, everything provable from $B$ remains provable after extra assumptions are added. Conversely, $B$ itself is one of its consistent extensions. Therefore anything shared by *all* consistent extensions must already hold in $B$.

This clarifies the slogan that Peano arithmetic is “universal.” Its theorems do survive in every consistent extension that retains its axioms. But the theorem does not say that every intelligent species must begin with Peano arithmetic, encode it in the same language, or regard it as foundational. Universality is relative to a base and to a notion of consequence. Once the base is fixed, its consequences are unavoidable in its extensions. Choosing the base remains a mathematical and conceptual decision.

There is another useful fact: consistency descends. If $B\subseteq D$ and the stronger theory $D$ is consistent, then $B$ is consistent. If the weaker theory proved everything, monotonicity would force the stronger one to prove everything as well.

## Two worlds are enough to break inevitability

Logic can also tell us when a sentence is not universal. Think of a mathematical “world” as a structure in which sentences can be true or false. A world is a model of a theory when it satisfies every sentence in that theory. A sentence $\varphi$ is a semantic consequence of $T$ if every model of $T$ satisfies $\varphi$.

Now define $\varphi$ to be *extension-universal over $T$* when every consistent extension of $T$ entails $\varphi$. A consistent theory is one with at least one model.

**Countermodel Principle.** If $T$ has a model in which $\varphi$ is false, then $\varphi$ is not extension-universal over $T$.

Indeed, add the negation of $\varphi$ to $T$. The same countermodel shows that this enlarged theory remains consistent, while the enlargement certainly cannot entail $\varphi$ in every model.

An even sharper statement follows.

**Two-Model Independence Principle.** If one model of $T$ satisfies $\varphi$ and another model of $T$ refutes $\varphi$, then neither $\varphi$ nor its negation is extension-universal over $T$.

This is the core logic behind independence: two legitimate worlds point in opposite directions.

Geometry supplies a vivid miniature. Consider two incidence worlds, each with three points and three lines, numbered $0,1,2$. In the *affine world*, point $p$ lies on line $\ell$ exactly when $p=\ell$. Thus each line contains one correspondingly numbered point. In the *intersecting world*, point $p$ lies on line $\ell$ when either $p=0$ or $p=\ell$. Every line therefore passes through the common point $0$.

Call two lines parallel if they share no incident point. Playfair’s postulate says that for every line $\ell$ and every point $p$ not on $\ell$, there is exactly one line through $p$ parallel to $\ell$.

In the affine world, a point $p$ outside line $\ell$ has exactly one line through it—line $p$—and that line shares no point with line $\ell$. So Playfair’s postulate holds. In the intersecting world, every pair of lines shares point $0$, so there are no parallel lines at all; Playfair’s postulate fails whenever an external point is chosen.

**Finite Parallel Independence Theorem.** With no background geometric axioms, neither Playfair’s postulate nor its negation is extension-universal.

The qualification matters. These tiny incidence systems isolate the logic of the sentence, but they are not full Euclidean and hyperbolic planes satisfying a common neutral geometry. They demonstrate nonuniversality over an empty base, not the historical independence theorem in its richest geometric setting. Still, they reveal the mechanism with perfect clarity: the same vocabulary can support incompatible geometrical worlds.

## The Riemann Hypothesis and the price of a universal answer

The same semantic framework disciplines speculation about the Riemann Hypothesis. Suppose $T$ is a consistent base theory and $\varphi$ is the sentence expressing the hypothesis. Then:

**Decision Equivalence Theorem.** The assertion that either $\varphi$ or its negation is extension-universal over $T$ is equivalent to the assertion that $T$ semantically entails $\varphi$ or semantically entails its negation.

Why? Over a consistent base, extension-universality is exactly semantic consequence: if every consistent extension entails $\varphi$, choose $T$ itself; in the other direction, every model of an extension is already a model of $T$. Applying this observation to both $\varphi$ and $\neg\varphi$ gives the result.

So the claim that every sufficiently rich arithmetic system must settle the Riemann Hypothesis is not a free gift of consistency. It is a substantive decision or completeness claim. This does not resolve the hypothesis, nor does it predict which side is true. It tells us precisely what an “inevitability” conjecture would have to establish.

## Would aliens discover primes?

Here structure matters more than notation. A commutative multiplicative system with zero has a multiplication, a unit $1$, a zero $0$, and commutative multiplication. An element is prime when it is nonzero, not a unit, and whenever it divides a product, it divides at least one factor.

Suppose an alien civilization represents our multiplicative world through a perfect recoding $e$: it matches multiplication, units, and zero in both directions. Such a map is a multiplicative equivalence, not merely a relabeling table.

**Prime Invariance Theorem.** For every element $x$, the encoded element $e(x)$ is prime if and only if $x$ is prime.

A faithful multiplicative translation cannot erase primality because primality is defined entirely through the multiplication-and-divisibility structure that the translation preserves.

For natural numbers, this combines with the infinitude of primes.

**Unbounded Alien Primes Theorem.** For every multiplicative recoding $e$ of the natural numbers and every bound $B$, there is a prime $p>B$ whose image $e(p)$ is prime in the alien presentation.

Aliens may write primes with colors, knots, pulses, or multidimensional shapes. If their representation preserves ordinary multiplication, they inherit primes without end.

But now alter the operation rather than the symbols. In min-plus tropical arithmetic, tropical multiplication is ordinary addition:

$$
a\odot b=a+b.
$$

The multiplicative identity is therefore ordinary $0$. A tropical natural number $n$ is irreducible when $n\neq0$ and every decomposition $n=a+b$ forces $a=0$ or $b=0$.

**Tropical Irreducibility Theorem.** A natural number is tropical-irreducible if and only if it equals $1$.

The proof is elementary. The number $1$ cannot be split into two positive natural numbers. Every $n\ge2$ splits as

$$
n=1+(n-1),
$$

with both parts nonzero. Thus tropical arithmetic has exactly one irreducible natural number, not infinitely many. Consequently, any two tropical irreducibles are equal.

## A map of mathematical inevitability

The lesson is neither that mathematics is wholly universal nor that it is arbitrary. It has layers.

At the logical layer, consequences survive extensions, and a consistent base is exactly its own universal core. At the semantic layer, competing models defeat claims of inevitability. At the structural layer, faithful equivalences preserve concepts such as primality. At the operational layer, changing multiplication itself can transform an infinite landscape of primes into the single irreducible $1$.

An alien mind might not recognize our notation, our diagrams, or our preferred axioms. Yet if it builds a structure equivalent to natural-number multiplication, primes will be waiting there. If it instead organizes arithmetic tropically, its factorization instincts will be genuinely different. The right question is not simply, “Would they discover our mathematics?” It is: “Which structures would they preserve, which assumptions would they choose, and which operations would they call fundamental?”

That question turns science fiction into a precise research program. Universality does not float above all possible thought. It travels along carefully specified bridges—and mathematics can tell us exactly which truths cross them.
