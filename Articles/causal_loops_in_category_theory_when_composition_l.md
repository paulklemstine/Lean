# When Composition Loops Back

## A concrete world where order matters, yet coherence survives

Mathematics often teaches us to ignore parentheses. When adding three numbers, it does not matter whether we calculate $(a+b)+c$ or $a+(b+c)$. The same is true for multiplication. This familiar rule, associativity, is so deeply embedded in ordinary calculation that its absence can feel like a defect.

Category theory offers a subtler possibility. Two ways of composing may fail to be literally equal while remaining connected by a reversible transformation. Parentheses then carry information, but changing them does not destroy meaning. This is the central idea behind a bicategory: associativity is not imposed as equality; it is witnessed by a specified invertible two-dimensional arrow called an associator.

A small numerical construction makes that distinction visible. It gives a one-object mathematical world in which the two bracketings of three identical arrows evaluate to $5$ and $7$. They are unmistakably unequal. Nevertheless, a unique reversible higher arrow connects them, and every possible rebracketing is coherent. The example is not merely an associative system written in elaborate notation: no strict bicategory structure can preserve its chosen composition.

## The twisted arithmetic of arrows

Take the natural numbers as arrows from a single object back to itself. Designate $0$ as the identity arrow, and define a composition operation $igstar$ by

$$
a\mathbin{\bigstar}b=
\begin{cases}
b, & a=0,\\
a, & b=0,\\
a+2b, & a\ne 0\text{ and }b\ne 0.
\end{cases}
$$

The exceptional clauses ensure that $0$ behaves as a genuine two-sided identity:

$$
0\mathbin{\bigstar}a=a,
\qquad
a\mathbin{\bigstar}0=a.
$$

Away from the identity, composition is deliberately asymmetric. The second input receives twice the weight of the first. This makes the placement of parentheses matter.

Let $u=1$ be a distinguished nonidentity arrow. First compute

$$
u\mathbin{\bigstar}u=1+2\cdot 1=3.
$$

If the left pair is composed first, the result is

$$
(u\mathbin{\bigstar}u)\mathbin{\bigstar}u
=3\mathbin{\bigstar}1
=3+2\cdot 1
=5.
$$

If the right pair is composed first, the result is

$$
u\mathbin{\bigstar}(u\mathbin{\bigstar}u)
=1\mathbin{\bigstar}3
=1+2\cdot 3
=7.
$$

Thus

$$
(u\mathbin{\bigstar}u)\mathbin{\bigstar}u
\ne
u\mathbin{\bigstar}(u\mathbin{\bigstar}u).
$$

This is the construction’s first theorem: the chosen arrow composition is genuinely nonassociative. The values $5$ and $7$ are not symbols for equivalent calculations; they are different natural numbers.

## Adding a second dimension

How can a category-like theory survive this failure? The answer is to add arrows between arrows.

Ordinary categories contain objects and arrows. Bicategories add another layer: objects, one-dimensional arrows between objects, and two-dimensional arrows between one-dimensional arrows. In the present example there is only one object, the natural numbers are its one-dimensional endomorphisms, and between every ordered pair of natural numbers $m$ and $n$ there is exactly one two-dimensional arrow.

This last condition is called codiscreteness. It is the opposite of forbidding communication between distinct arrows: every arrow can be compared with every other arrow, and there is only one possible comparison. Because there is exactly one two-dimensional arrow from $m$ to $n$ and exactly one from $n$ to $m$, the two are automatically inverse to each other. Composing either way produces the unique two-dimensional identity available at the endpoint.

Consequently, the unequal composites $5$ and $7$ are joined by an invertible two-dimensional arrow:

$$
5\;\Longrightarrow\;7.
$$

The symbol does not assert $5=7$. Instead, it says that the two distinct one-dimensional composites are coherently interchangeable at the higher level. This distinction—equality below, equivalence above—is the heart of weak higher-dimensional algebra.

The same argument works for every triple $f,g,h$ of natural-number arrows. Whether or not their two bracketings agree numerically, there is an invertible associator

$$
\alpha_{f,g,h}:
(f\mathbin{\bigstar}g)\mathbin{\bigstar}h
\Longrightarrow
f\mathbin{\bigstar}(g\mathbin{\bigstar}h).
$$

The identity laws are treated similarly. Since $0$ is already a strict two-sided identity for $igstar$, the source and target of each unitor agree numerically, but the bicategorical structure still supplies the required reversible two-dimensional arrows.

## Why coherence is the real challenge

Supplying an associator for each triple is not enough. With four arrows, there are several ways to move parentheses. Starting from $((f\bigstar g)\bigstar h)\bigstar i$ and ending at $f\bigstar(g\bigstar(h\bigstar i))$, one may apply associators in different orders. A credible theory must ensure that all prescribed routes agree.

The principal condition is the pentagon law. Its name comes from the five bracketings of four composable arrows, arranged as vertices of a pentagon. The two standard paths around this diagram must yield the same two-dimensional arrow. There is also a triangle law ensuring that associators and the left and right identity transformations cooperate.

In the codiscrete setting, these laws become inevitable. Any two parallel two-dimensional arrows have the same source and target. But there is exactly one such arrow, so the two composites must coincide. Therefore the pentagon commutes, the triangle commutes, and every larger diagram assembled from the same structural transformations commutes for the same reason.

This yields the Hinge-and-Coherence Theorem: the natural numbers with identity $0$, twisted composition $igstar$, and one unique two-dimensional arrow between every pair form a bicategory. For every triple, the associator reversibly connects the two bracketings; for every quadruple, the pentagon law holds; and the unitors satisfy the triangle law.

The proof has two ingredients. First, the arithmetic clauses verify the strict left and right identity rules. Second, codiscreteness supplies every required higher arrow and makes every coherence equation automatic. The construction separates the algebraic defect from its coherent repair with unusual clarity.

## Why this is not strictness in disguise

One might suspect that the abundance of two-dimensional arrows merely decorates an ordinary strict system. The obstruction theorem rules this out.

A strict bicategory on these fixed objects, arrows, identities, and composition would require literal associativity of one-dimensional composition. Applied to the distinguished arrow $u=1$, strict associativity would force

$$
(u\mathbin{\bigstar}u)\mathbin{\bigstar}u
=
u\mathbin{\bigstar}(u\mathbin{\bigstar}u).
$$

Yet the left side is $5$ and the right side is $7$. Since $5\ne 7$, no strict bicategory structure can exist on the fixed composition. The associator is therefore essential rather than cosmetic.

This statement must be read carefully. It rules out strictness while retaining exactly the given one-dimensional data. It does not rule out replacing the whole system by a suitably equivalent strict model. In higher category theory, equivalence and equality are deliberately different standards. A future strictification theorem would concern replacement up to biequivalence, not conversion of $5$ into $7$ within the present arithmetic.

## From scheduling to geometry

Why care about such a tiny example? Because nonassociative-looking composition appears whenever composition carries choices of timing, grouping, or interface.

Imagine three processes. Executing the first two as a module and then attaching the third need not produce the same internal schedule as attaching the last two first. In distributed systems, message timing can preserve the difference. In programming languages, parenthesized composition may change evaluation plans. In geometry, gluing three regions in different stages can produce constructions that are not literally identical, even when a canonical reversible comparison exists. In physics, composing transformations with gauge choices can similarly yield objects related by structured equivalence rather than equality.

The bicategorical viewpoint says that these differences need not be erased. Instead, one records a translation between bracketings and imposes laws on translations. Coherence then guarantees that large calculations do not depend ambiguously on the route chosen through a maze of local regroupings.

Four arrows already reveal why that guarantee matters. There are five complete ways to parenthesize them, from $((f\bigstar g)\bigstar h)\bigstar i$ to $f\bigstar(g\bigstar(h\bigstar i))$. These five arrangements form the vertices of the associator pentagon. In the numerical example, four copies of $1$ produce vertex values $7$, $9$, $9$, $11$, and $15$. The repeated value $9$ is an accident of arithmetic; most vertices remain unequal. Yet the two standard routes from the fully left-associated expression to the fully right-associated one determine the same higher arrow. The pentagon law is therefore a consistency rule for changing perspective, not a claim that all intermediate calculations have the same numerical value.

This distinction resembles converting between coordinate systems. Two coordinate descriptions need not be identical strings of numbers, but translations between them must compose consistently. If one chain of legitimate conversions gave a different answer from another chain with the same endpoints, the language of description would be unreliable. Bicategorical coherence prevents precisely that kind of path dependence.

The numerical example is intentionally extreme: it installs exactly one comparison between any pair. That makes coherence transparent but also collapses all interesting higher symmetries. If there were several two-dimensional automorphisms, the pentagon would become a genuine equation with content, closely related in one-object settings to a three-cocycle condition. Here, uniqueness is a microscope: it removes distractions so that the distinction between strict equality and coherent equivalence can be seen directly.

## The lesson of $5$ and $7$

The construction establishes four concrete facts. The twisted operation has a two-sided identity. It is nonassociative, witnessed by the values $5$ and $7$. Unique invertible higher arrows control every reassociation and satisfy the pentagon and triangle laws. Finally, no strict structure can retain the same composition.

Together these facts overturn a common intuition. Consistency does not require every compositional loop to close by equality. It can close one dimension higher.

That principle is one of the organizing ideas of modern mathematics. Equations remain important, but they are no longer the only way to express sameness. Sometimes the correct record of a calculation is not that two outcomes coincide, but that a canonical reversible bridge connects them—and that every network of such bridges fits together. In this small world, $5$ stays $5$, $7$ stays $7$, and mathematics remains coherent precisely because it refuses to pretend otherwise.
