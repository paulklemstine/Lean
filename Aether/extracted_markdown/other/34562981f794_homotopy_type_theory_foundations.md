# When Sameness Becomes Geometry

## The shape of equality

Here is something that should bother you: when you say two things are "the same," what exactly do you mean?

In everyday life, this seems obvious. Two copies of a book are "the same" book. A melody transposed to a different key is "the same" melody. Your bank account balance is "the same" whether you view it on your phone or at an ATM. But a mathematician will tell you that these are all different kinds of sameness — and until recently, mathematics itself didn't have a good way to keep track of the difference.

Then, about fifteen years ago, a startling idea emerged from the intersection of abstract algebra, topology, and computer science. What if equality itself has *shape*? What if the statement "A equals B" is not just a yes-or-no proposition, but a space of *ways* in which A and B are the same — a space that can be explored, measured, and navigated?

This idea, known as Homotopy Type Theory, has been called the most significant new foundation for mathematics since set theory was formalized over a century ago. And a new body of work has now demonstrated that its core principles can be made computationally real — not as abstract philosophy, but as working mathematics that proves theorems and transports algorithms.

## The trouble with identity

To understand why this matters, consider a puzzle that has haunted mathematics since antiquity.

Euclid wrote about triangles and circles, and he proved theorems about them. But he never worried about what a triangle *is*, exactly. Is it the set of its three vertices? The three line segments connecting them? The region they enclose? A modern mathematician would say these are all "the same" triangle in a precise sense — but making that precision rigorous took two thousand years and several revolutions in mathematical thinking.

The problem crystallized in the twentieth century when mathematicians began using set theory as a universal foundation. In set theory, everything is a set — numbers, functions, geometrical shapes, even logical propositions. This is elegant, but it creates an annoying artifact: two mathematical objects can be "the same" in every meaningful way, yet technically different as sets.

Consider the number 2. In one standard construction, 2 is the set {∅, {∅}}. In another, it's the set {{∅}}. Both constructions work perfectly well. Every theorem about the number 2 holds in both versions. But they are different sets, so they are not "equal" in the strict sense.

This isn't just pedantry. It creates real headaches when you try to mechanize mathematics — when you ask a computer to verify that a proof is correct. The computer cares very much about which version of 2 you're using, even when the mathematics doesn't.

## Paths between mathematical objects

The breakthrough came from an unexpected direction: topology, the study of shapes.

In topology, two points in a space can be connected by a path — a continuous curve from one to the other. Two paths between the same endpoints can themselves be connected by a "path between paths" (a continuous deformation of one path into another). And there can be paths between paths between paths, and so on, creating an infinite tower of higher-dimensional connections.

The key insight of Homotopy Type Theory was this: *equality behaves like a path*.

When you prove that A = B, you are constructing a path from A to B — a specific *way* of identifying them. When you prove that two proofs of A = B are themselves equal, you are constructing a path between paths. The entire tower of higher-dimensional topology is already implicit in the ordinary notion of mathematical equality.

This sounds abstract, but it has immediate concrete consequences. If equality is path-like, then the ways of identifying two mathematical structures form a *space* — and the shape of that space tells you something fundamental about the structures themselves.

For instance, the symmetries of a square form a group with eight elements (four rotations and four reflections). In the path-theoretic view, these eight symmetries are the eight "self-identifications" of the square — the eight loops in the space of equalities from the square to itself. The group structure isn't imposed from outside; it emerges naturally from the geometry of identity.

## Making it real

For years, Homotopy Type Theory remained largely theoretical. Its most powerful ideas — the univalence axiom (which says that equivalent structures are equal), higher inductive types (which let you build new spaces by specifying their paths), and the transport principle (which lets you move information along paths of equality) — were stated as axioms or implemented in specialized proof assistants with custom logical kernels.

The new work takes a different approach. Instead of modifying the logical foundations, it asks: *how much of HoTT can you recover as provable theorems in standard mathematics?*

The answer turns out to be: surprisingly much.

The central achievement is a formal proof of the **Fundamental Theorem of Identity Types**. This theorem says: if you have a family of types R(a) indexed by elements a of some type A, with a distinguished point a₀ and a witness that R(a₀) holds, and if the total collection of pairs (a, r) where r witnesses R(a) is contractible (has essentially one element), then R(a) is equivalent to the identity type "a₀ = a" for every a.

In plain language: *any family that behaves like equality actually is equality, up to a precise equivalence*. This is the engine behind the encode-decode method, the workhorse technique for computing with identity types. It says you can replace the abstract notion of equality with any concrete family that satisfies the right contractibility condition.

## The universe of propositions

One of HoTT's most celebrated principles is *univalence*: the idea that equivalent mathematical structures should be considered equal. In full generality, this requires modifying the foundations of mathematics. But the new work identifies a natural "universe" where univalence is a provable theorem, no axioms required.

The universe in question is the world of *propositions* — mathematical statements that are either true or false, with no interesting internal structure. For propositions, logical equivalence (P implies Q and Q implies P) turns out to be exactly the same as equality. This is not obvious! It depends on a deep principle called propositional extensionality, and the formal proof requires carefully coordinating the structure theory of propositions with the mechanics of equality.

The significance is methodological. Rather than postulating that "equivalent things are equal" as a blanket axiom, you identify the precise contexts where this principle is provable — and in those contexts, you get the full power of univalence for free.

## Gluing spaces together

The most geometrically vivid part of Homotopy Type Theory involves *higher inductive types*: new mathematical spaces defined by specifying not just their elements but also their paths and higher paths.

The simplest example is a circle. Normally, you'd define a circle as the set of points at distance 1 from the origin. But in HoTT, you can define it directly: a circle is a space with one point and one non-trivial loop (a path from the point to itself that isn't just "stay where you are").

Encoding such constructions in standard mathematics requires ingenuity. The new work uses *pushouts* — a construction from category theory that glues two sets together along a shared interface. Given sets B and C with a shared subset A (mapped into both by functions f and g), the pushout identifies f(a) with g(a) for every element a of A.

What makes this more than a simple quotient is the *universal property*: the formally verified theorem that any function out of the pushout that respects both sub-sets is unique. This universal property is the mathematical content of the higher inductive type — it's what makes the pushout behave like a genuine topological gluing operation rather than just an equivalence relation.

The practical payoff is immediate. Pushouts model data merging (combining two databases with shared records), network gluing (connecting two networks through a shared gateway), and schema integration (unifying different representations of the same data). In each case, the universal property guarantees consistency: there is exactly one correct way to extend any operation to the merged structure.

## Algorithms that travel

Perhaps the most surprising result is that these abstract-sounding principles have concrete computational content.

Consider decidable equality — the ability to determine, algorithmically, whether two elements are the same. This is a computational capability, not just a mathematical one: it means you can write a program that takes two inputs and outputs "yes, they're equal" or "no, they're not."

The new work proves that *equivalences transport decidable equality*. If type A has decidable equality and type B is equivalent to A (there's a bijection with well-behaved inverse), then B automatically inherits decidable equality. The decision procedure is constructed explicitly: to decide whether two elements of B are equal, map them back to A, decide there, and map the answer forward.

This extends to richer structure. Finiteness transports: if A is finite, so is any type equivalent to A. Decidable predicates transport: if you can decide "is this element of A red?" then you can decide "is this element of B red?" for any equivalent B. Contractibility transports: if A has essentially one element, so does any equivalent B.

The slogan is: *mathematical structure is portable, not tied to representation*. This is the computational face of univalence. It means you can develop an algorithm for one data representation and automatically obtain correct algorithms for all equivalent representations — no manual rewriting, no subtle bugs from translating between formats.

## A bridge between worlds

What makes this work distinctive is that it bridges two worlds that are usually kept separate.

On one side is the world of foundational mathematics: type theory, homotopy theory, the study of identity and equivalence at the most abstract level. On the other side is the world of practical computation: algorithms, data structures, decision procedures, the concrete machinery of verified software.

The bridge is the observation that the abstract principles of HoTT — contractibility, transport, universal properties — are not just logical niceties. They are *constructive*: they produce witnesses, they build functions, they create decision procedures. A contractible type doesn't just "have one element in some vague sense" — it comes equipped with a specific center element and a specific function mapping every other element to that center.

This constructivity is what makes the framework usable. When you prove that the pushout of two sets has a unique extension property, you're not just asserting existence; you're exhibiting the extension. When you prove that decidable equality transports across an equivalence, you're building the decision procedure, not just saying it exists.

## The road ahead

The framework established here is deliberately a fragment — a carefully chosen subset of Homotopy Type Theory that is provable in standard mathematics. It doesn't include the full univalence axiom for all types, or arbitrary higher inductive types, or the complete hierarchy of truncation levels.

But it includes enough to be useful. The fundamental theorem of identity types gives a general-purpose engine for computing with equalities. The pushout construction gives a practical toolkit for building spaces by gluing. The transport theorems give a systematic method for moving algorithmic structure across equivalent representations.

Several natural extensions suggest themselves. Can the truncation level hierarchy be formalized completely in this setting? Can the pushout construction be iterated to build higher-dimensional cell complexes? Can the transport principles be extended to preserve algebraic laws — not just decidability, but associativity, commutativity, the full structure of a group or ring?

These are not idle questions. Each one connects to practical problems in computer science: the truncation hierarchy relates to data abstraction and information hiding; cell complexes model database schemas and program configurations; algebraic transport relates to generic programming and representation independence.

The deepest lesson of Homotopy Type Theory may be this: the most abstract mathematics — the study of identity itself — turns out to be the most practical. When you understand what it means for two things to be "the same," you understand how to build systems that don't care about inessential differences. And in a world drowning in data formats, API versions, schema migrations, and representation choices, that understanding is worth more than you might expect.
