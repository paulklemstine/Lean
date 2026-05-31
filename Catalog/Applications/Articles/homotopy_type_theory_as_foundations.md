# The Shape of Truth: How Geometry Is Rewriting the Foundations of Mathematics

*A new mathematical framework treats logical proofs as paths through space — and it may change everything we think we know about mathematical truth.*

---

In 1931, Kurt Gödel shattered the dream of a single, all-encompassing foundation for mathematics. His incompleteness theorems showed that any sufficiently powerful logical system must contain truths it cannot prove. Mathematicians have lived with this uncomfortable reality ever since, building their work on a foundation — Zermelo-Fraenkel set theory with the Axiom of Choice, or ZFC — that they knew was, in some deep sense, incomplete.

But what if there were another way? What if, instead of building mathematics on the rigid scaffold of sets and membership, we built it on something more fluid, more geometric? What if the very concept of "equality" were not a simple yes-or-no question, but a rich landscape of paths and deformations?

This is the vision of **Homotopy Type Theory** — HoTT, for short — a revolutionary approach to the foundations of mathematics that has been quietly reshaping how researchers think about truth, equivalence, and the nature of mathematical objects themselves.

## The Problem With Equality

To most people, equality seems straightforward. Two plus two equals four. The morning star equals the evening star (both are Venus). Case closed.

But mathematicians have long known that equality is surprisingly subtle. Consider two different ways to organize a deck of 52 playing cards. Both decks contain the same cards, but in different orders. Are they "the same"? In one sense, yes — they have the same elements. In another sense, no — the ordering matters. And the *way* you reorganize one into the other — the specific shuffle — carries important information.

Classical mathematics, built on ZFC set theory, treats equality as a flat, binary relation. Two things are equal or they aren't. End of story. But this rigidity creates problems. When mathematicians say two groups are "isomorphic" (structurally identical), they mean something stronger than mere equality but subtler than identity. There might be *multiple* isomorphisms between them, and which one you choose can matter enormously.

HoTT resolves this tension with a breathtaking idea: **equality itself has structure**. Two objects aren't just equal or unequal — they can be equal *in different ways*, and those different ways form a space that you can study geometrically.

## Paths Through Space

The key insight comes from topology, the branch of mathematics that studies shapes and their deformations. In topology, a "path" is a continuous curve connecting two points. If you can continuously deform one path into another (without breaking it), the paths are considered "homotopic" — essentially the same.

HoTT takes this geometric idea and applies it to logic itself. A proof that two objects are equal becomes a *path* between them. Two different proofs of the same equality become two paths connecting the same endpoints — and whether those paths can be deformed into each other is a meaningful mathematical question.

This creates a hierarchy of mathematical complexity that HoTT calls the **truncation levels**:

- **Level -2: Contractible types.** These are like a single point in space — completely trivial, with only one element and one path between any two elements. These are the "true" propositions of mathematics.

- **Level -1: Mere propositions.** These types have at most one element up to paths. They represent mathematical statements that are either true or false, with no additional structure. This is where classical logic lives.

- **Level 0: Sets.** These types can have multiple distinct elements, but equality between elements is a mere proposition. This is where ordinary mathematics — arithmetic, algebra, analysis — takes place.

- **Level 1: Groupoids.** Here, equality between elements can itself have non-trivial paths. This is where the rich structure of symmetry groups lives.

And the hierarchy continues upward, with each level capturing increasingly complex mathematical phenomena.

## The Univalence Axiom: Identity Is Equivalence

The crown jewel of HoTT is the **Univalence Axiom**, proposed by the late Vladimir Voevodsky, a Fields Medal-winning mathematician who spent the last decade of his career developing this theory.

The axiom states, in essence: **equivalent structures are identical.**

This sounds almost tautological, but its implications are profound. In traditional mathematics, you might prove that two groups are isomorphic, but you can't simply substitute one for the other in all contexts — you need to track the isomorphism carefully. With univalence, this tracking happens automatically. The mathematical universe "knows" that equivalent structures are the same, and it lets you treat them as such.

A concrete illustration: consider the natural numbers as a set. You can represent them as {0, 1, 2, 3, ...} or as {∅, {∅}, {∅, {∅}}, ...} (the von Neumann encoding). These are different sets in ZFC, but they encode the same mathematical structure. Univalence says they are, in the strongest possible sense, *the same*.

## Winding Around the Circle

One of the most celebrated computations in HoTT is the calculation of the **fundamental group of the circle** — a result that beautifully illustrates how geometric thinking works in this setting.

The circle, in HoTT, is defined as a type with a single point (called "base") and a single non-trivial loop (called "loop"). A loop is a path from base back to itself. You can traverse the loop forward, backward, or multiple times, and the *winding number* — how many net times you go around — completely characterizes the loop.

The theorem states: **the fundamental group of the circle is isomorphic to the integers.** Every loop is characterized by an integer (its winding number), loop composition corresponds to addition, and the reverse loop corresponds to negation.

This result, first proved within HoTT by Daniel Licata and Michael Shulman, demonstrates something remarkable: HoTT can not only match the results of classical algebraic topology but can often prove them more naturally, because the proofs are embedded in the very structure of the type theory.

## Two Foundations, One Mathematics

A natural question arises: does HoTT give different mathematics than ZFC? The answer, reassuringly, is **no** — at least not in the sense that matters.

The two foundations have been shown to be **equiconsistent**: if one is consistent (free of contradictions), so is the other. They have the same "consistency strength," meaning neither can prove the other inconsistent unless both are.

Moreover, if you add the Law of Excluded Middle (every statement is either true or false) and the Axiom of Choice to HoTT, you recover the full power of ZFC. Every theorem provable in ZFC can be proved in this enriched HoTT. But pure HoTT, without these classical additions, is *constructive*: it requires you to explicitly construct mathematical objects rather than merely proving they exist.

This constructive nature is not a limitation — it's a feature. Constructive proofs carry computational content. When you prove that a solution to an equation exists constructively, you've actually built an algorithm to find it. This makes HoTT particularly attractive for computer science and formal verification.

## The Structure Identity Principle

Perhaps the most practically important consequence of univalence is the **Structure Identity Principle**: for any "reasonable" notion of mathematical structure (groups, rings, topological spaces, etc.), the concept of equivalence between structures coincides with the concept of identity.

This principle has been verified for a wide range of mathematical structures. Two finite groups, for example, are identical (in the HoTT sense) if and only if there exists a bijection preserving the group operation. Two topological spaces are identical if and only if they are homeomorphic.

This is not just a philosophical nicety — it has practical consequences. When mathematicians build large theories, they constantly need to transfer results from one structure to an equivalent one. In ZFC, each such transfer requires explicit bookkeeping. In HoTT, it's automatic, courtesy of univalence.

## The Road Ahead

HoTT is still young. The foundational text — simply titled *Homotopy Type Theory* — was published only in 2013, the product of a special year at the Institute for Advanced Study in Princeton. Since then, the theory has grown rapidly, attracting researchers from topology, category theory, logic, and computer science.

Open questions abound. Can the full homotopy theory of spaces be developed within HoTT? Can the theory handle the infinite-dimensional structures of modern geometry and physics? And perhaps most tantalizingly: are there theorems that are *easier* to prove in HoTT than in ZFC?

Early evidence suggests yes. The winding number computation, the Structure Identity Principle, and various results in higher category theory all seem to find more natural homes in HoTT. The theory's geometric intuition aligns with how mathematicians actually think, even if it differs from how they've traditionally written proofs.

There's also a bold conjecture emerging from recent work: that the truncation level required to express the fundamental group πₙ(Sⁿ) increases linearly with n. If true, this would reveal a deep connection between the algebraic complexity of homotopy groups and the type-theoretic complexity of their proofs — a connection invisible from the classical perspective.

## A New Way of Seeing

Mathematics has reinvented its foundations before. The ancient Greeks had geometry. The 19th century brought set theory. The 20th century formalized it all with ZFC and first-order logic.

Each new foundation didn't just reorganize existing knowledge — it revealed new territories to explore. Set theory made infinite cardinals visible. Category theory illuminated the deep structures connecting different branches of mathematics. Homotopy Type Theory may do the same, showing us that the paths between mathematical objects are as important as the objects themselves.

As Voevodsky wrote shortly before his death in 2017: "The only option which will work is to create a new foundation for mathematics based on the type-theoretic ideas." Whether or not HoTT ultimately replaces ZFC as the default foundation, it has already achieved something remarkable: it has shown us that mathematical truth has a shape, and that shape is worth exploring.

*The paths between ideas, it turns out, are ideas too.*
