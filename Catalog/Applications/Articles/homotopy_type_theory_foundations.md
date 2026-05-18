# The Shape of Equality: How Mathematicians Discovered That Sameness Has Structure

## A question that shouldn't need asking

What does it mean for two things to be "the same"?

It sounds like a philosophical question — the kind that leads nowhere useful. But in the last two decades, a revolution in mathematics has shown that this question is not only precise but explosively productive. The answer has reshaped our understanding of geometry, logic, and the foundations of mathematics itself.

The breakthrough begins with a simple observation: equality is not a yes-or-no affair. There are *ways* of being equal, and those ways themselves have structure.

## The parable of the coffee cup

Here is a famous joke in mathematics: a topologist cannot tell the difference between a coffee cup and a doughnut. Both have one hole — the handle of the cup corresponds to the hole through the doughnut — and since topology only cares about properties preserved under continuous deformation, they are "the same."

But *how* are they the same? There are infinitely many ways to continuously deform a coffee cup into a doughnut. You could start by flattening the cup's bowl. You could start by inflating the handle. Each deformation is a different *proof* of their equivalence, a different *witness* to their sameness.

Traditional mathematics says: two things are equal or they aren't. End of story. The new mathematics says: the collection of all proofs of equality is itself a mathematical object, with its own geometry, its own structure, its own surprises.

This is Homotopy Type Theory — HoTT for short — and it has turned the foundations of mathematics inside out.

## The fiber of a function

To understand HoTT, start with a simple idea: the *fiber* of a function.

Imagine a function that assigns each person their birthday. The fiber over "March 15" is the set of all people born on March 15. The fiber over "July 4" is the set of all people born on July 4.

Now, when does a function represent a perfect matching — a genuine equivalence? Classical mathematics says: when it's a bijection, when each output comes from exactly one input. HoTT gives a more geometric answer: when every fiber is *contractible*.

A contractible space is one that can be continuously shrunk to a single point. A single person standing alone in a room is contractible — there's only one place to be. A crowd is not — there are choices, ambiguities, non-trivial structure.

So a function is an equivalence precisely when, over every point in the target, the collection of things that map to it can be collapsed to a single point. No ambiguity, no choices, no leftover structure.

This characterization — equivalences are functions with contractible fibers — is one of the theorems recently formalized with complete machine verification. It is not merely a restatement of bijectivity; it is a fundamentally different perspective that generalizes to spaces, types, and higher-dimensional structures where the classical notion breaks down.

## The fundamental theorem

The deepest result in this new formalization is what practitioners call the *fundamental theorem of identity types*. Despite its austere name, it is an extraordinarily powerful tool.

Here is the idea. Suppose you have a type — think of it as a collection of mathematical objects — and you pick a basepoint. Now consider a family of types indexed over your original type: for each element, you get a new collection. If the total space of this family (all the elements bundled together) is contractible, then the family is *equivalent to the identity*.

What does this mean? It means that the family captures exactly the same information as the collection of all equality proofs emanating from your basepoint. Nothing more, nothing less.

This sounds abstract, but its consequences are breathtaking. It means you can characterize equality in any mathematical structure by finding a contractible total space. Want to know when two natural numbers are equal? Find a family with a contractible total space. Want to know when two groups are isomorphic? Same method. Want to know when two proofs are the same? Same method again.

The fundamental theorem is a *theorem factory*: feed it a contractible total space, and it produces an explicit equivalence between your family and identity. It automates the deepest part of mathematical reasoning about sameness.

## Paths in space

To appreciate why this matters, we need to understand what equality looks like in HoTT.

In classical mathematics, the statement "2 + 2 = 4" is either true or false. It's a single bit of information. But in HoTT, the equality type "a = b" is itself a space — potentially with complex topology.

When the objects live in a simple, "discrete" world — like the natural numbers — this space is boring: either empty (if a ≠ b) or a single point (if a = b). But when the objects have internal symmetry, the equality space becomes rich.

Consider the circle. In what ways is a point on the circle "equal to itself"? You could go around once, or twice, or seventeen times, clockwise or counterclockwise. Each loop is a different self-equality — a different *path* from the point back to itself. The space of self-equalities of a point on the circle is equivalent to the integers, counting winding numbers.

This is not metaphor. In HoTT, these different paths are genuine mathematical objects with precise algebraic properties. They can be composed (concatenating paths), inverted (reversing direction), and they satisfy laws reminiscent of group theory. The "loop space" of a point — all paths from that point to itself — is the first genuinely homotopical object available within the foundations of mathematics.

## The univalence principle

The most revolutionary idea in HoTT is the *univalence axiom*, proposed by the Fields Medalist Vladimir Voevodsky in 2006.

Univalence says: if two mathematical structures are equivalent, then they are equal.

This might sound obvious — isn't that what mathematicians already believe? — but it is actually a radical departure from standard foundations. In traditional set theory, you can have two completely isomorphic groups that are "different" because their underlying sets happen to be different. The integers-as-a-group built from von Neumann ordinals is technically "not equal to" the integers-as-a-group built from Zermelo ordinals, even though no mathematical theorem could ever distinguish them.

Univalence eliminates this absurdity. If two structures have the same behavior, they are the same structure. Period.

The practical consequence is enormous: any property that applies to one equivalent structure automatically applies to the other. You never need to verify invariance under isomorphism — it is guaranteed by the foundations.

In the recent formalization, univalence is introduced as an explicit interface — a contract that can be assumed or instantiated — rather than a modification of the underlying logical system. This architectural decision is itself significant: it means that reasoning *about* univalence can be done within the standard framework, and transport theorems (moving properties along equivalences) can be proved once and reused everywhere.

## Transport: moving mathematics along equivalences

One of the most practical tools that emerges from this framework is *transport*.

Imagine you've proved that a certain algorithm works correctly on lists. Now you want to switch to arrays for performance. Are you sure the algorithm still works?

In traditional software verification, you'd need to re-prove correctness for the new data structure. But with transport along equivalences, if lists and arrays are provably equivalent representations, then the correctness proof *automatically transfers*. You don't re-prove; you transport.

This isn't limited to programming. Transport works for any mathematical property: if you've proved a theorem about one representation of the real numbers and switch to another, the theorem comes along for free. If you've characterized the symmetries of a crystal in one coordinate system and rotate to another, the characterization transports.

The formalization proves several transport theorems: contractibility, subsingletonhood (being a proposition), and algebraic structure all transfer faithfully across equivalences. These are not trivial facts — they require careful handling of dependent types and path induction — but once proved, they become permanent infrastructure.

## Sets as truncated types

HoTT introduces a hierarchy of complexity for mathematical objects, measured by the richness of their equality types.

At the bottom are the *contractible types*: those with exactly one element (up to paths). Above them are the *propositions*: types where any two elements are equal (so the only information is whether the type is inhabited or not). Above those are the *sets*: types where any two equality proofs are equal (so equality is a yes-or-no question, even though the type itself may have many elements).

The natural numbers, the real numbers, and most of classical mathematics live at the level of sets. But groups, categories, and mathematical structures with nontrivial symmetries naturally live one level higher, and spaces with higher homotopy (like spheres of dimension 2 and above) live higher still.

This hierarchy is not just philosophical taxonomy. It has computational content. The formalization proves that contractible types are automatically sets — a theorem that constrains the entire tower and provides a concrete tool for reasoning about truncation levels.

## What this means for the future

The formalization described here is not an endpoint. It is a foundation — a working kernel of HoTT inside a modern proof assistant that can be extended, applied, and built upon.

The immediate implications are for mathematics itself: the encode-decode method, powered by the fundamental theorem, can now be deployed mechanically to characterize equality in any structure with a contractible total space. This is a genuine labor-saving device for working mathematicians.

The longer-term implications reach into computer science, physics, and philosophy. In computer science, transport along equivalences is a rigorous framework for verified refactoring — changing implementations while preserving behavior, with machine-checked guarantees. In physics, the idea that equivalent mathematical descriptions should be literally interchangeable resonates with gauge invariance and the principle that physics should not depend on the choice of coordinates.

And in philosophy, HoTT represents a new answer to an ancient question: what is mathematical equality? Not a primitive, irreducible notion, but a rich geometric structure that can be studied, characterized, and computed with.

The shape of equality turns out to be far more interesting than a simple equals sign. It is a landscape with mountains of symmetry, valleys of contractibility, and bridges of equivalence connecting every corner of mathematics. We are only beginning to explore its terrain.
