# The Machine That Reasons About the Unknowable

## How mathematicians built a thinking engine for one of number theory's deepest mysteries

In 1934, a young Soviet mathematician named Alexander Gelfond proved something remarkable: the number 2^√2 — two raised to the power of the square root of two — is not the solution to any polynomial equation with rational coefficients. This single result, which settled a question posed by David Hilbert thirty-four years earlier, opened a door that mathematicians have been walking through ever since.

The door leads to one of the most beautiful and frustrating corridors in all of mathematics: transcendence theory, the study of numbers that live permanently beyond the reach of algebra.

Most numbers we encounter daily — 3, −7, 2/5, even √2 — are *algebraic*: they satisfy some polynomial equation with integer coefficients. The number √2, for instance, solves x² − 2 = 0. But some numbers resist this domestication entirely. The constants π and *e* are *transcendental* — they satisfy no polynomial equation, no matter how high the degree or how cleverly chosen the coefficients. They are, in a precise sense, algebraically wild.

Proving that a specific number is transcendental is extraordinarily difficult. The transcendence of *e* was established by Charles Hermite in 1873. The transcendence of π followed nine years later, courtesy of Ferdinand von Lindemann — a result that, as a corollary, proved the impossibility of squaring the circle, settling a question that had tormented geometers for over two thousand years.

But these are individual victories. Mathematicians have long sought a *general theory* — a single principle that would explain *why* the exponential function produces transcendental numbers from algebraic inputs, and how far this phenomenon extends. In the 1960s, the British mathematician Stephen Schanuel proposed exactly such a principle, and it has haunted number theory ever since.

## The Conjecture That Explains Everything

Schanuel's conjecture is breathtaking in its ambition. It makes a single claim about the relationship between linear algebra and the exponential function, and from that claim, virtually every known result in transcendence theory — and many unknown ones — tumble out as consequences.

Here is the idea, stripped to its essence. Take any collection of complex numbers — call them z₁, z₂, …, zₙ — that are "linearly independent over the rationals." This means you cannot find rational numbers c₁, c₂, …, cₙ (not all zero) such that c₁z₁ + c₂z₂ + ⋯ + cₙzₙ = 0. The numbers 1, √2, and π, for example, are linearly independent: no rational combination of them equals zero.

Now compute their exponentials: e^{z₁}, e^{z₂}, …, e^{zₙ}. Schanuel's conjecture asserts that these 2n numbers — the original z's together with their exponentials — must be "algebraically complex enough" that at least n of them are algebraically independent. In technical language, the transcendence degree of the field they generate must be at least n.

This may sound abstract, but its consequences are concrete and stunning. If Schanuel's conjecture is true, then:

- *e* and π are algebraically independent (a famous open problem).
- *e*^*e* is transcendental (also open).
- For any algebraic numbers α₁, …, αₙ that are linearly independent over the rationals, the exponentials e^{α₁}, …, e^{αₙ} are algebraically independent.
- Every known transcendence result about the exponential function follows as a special case.

The conjecture is a skeleton key for transcendence theory. The problem is that nobody knows how to turn it.

## Building a Machine for Unproven Mathematics

For decades, Schanuel's conjecture has lived in a peculiar limbo. Mathematicians believe it is true — the evidence is overwhelming, and no counterexample has ever been found — but no proof exists. It hovers above the landscape of number theory like a theorem from the future, visible but unreachable.

A team of researchers recently asked a provocative question: what if you could *use* the conjecture rigorously, even without proving it? What if you could build a mathematical machine — a formal reasoning engine — that takes Schanuel's conjecture as an explicit axiom and derives consequences from it with absolute logical certainty?

The result would not be a proof of the conjecture itself. It would be something arguably more useful: a *verified consequence generator*. Feed the machine a collection of numbers and their properties, and it tells you exactly what Schanuel's conjecture predicts about their transcendence — with every logical step checked by computer, leaving no room for error.

This is precisely what the researchers built. Their framework establishes the Schanuel conjecture as a formal axiom — a clearly stated assumption — and then derives a cascade of consequences, each verified down to the level of individual logical rules.

## The Three Pillars

The framework rests on three main results, each proved with complete rigor from the Schanuel axiom.

**The first theorem** recovers the classical Lindemann–Weierstrass theorem as a formal consequence. It states: if you take algebraic numbers that are linearly independent over the rationals, then their exponentials are algebraically independent. This means no polynomial equation with rational coefficients can relate e, e^{√2}, e^{√3}, and so on — they are as algebraically unrelated as random transcendental numbers. The classical Lindemann–Weierstrass theorem, proved in the 1880s, establishes this independently of Schanuel. But the fact that it emerges as a *corollary* of the formal framework validates the framework's power.

**The second theorem** is a striking contrapositive. Suppose you have complex numbers z₁, …, zₙ such that both the z's and their exponentials e^{z₁}, …, e^{zₙ} are all algebraic. Then the z's must be linearly *dependent* over the rationals — there must be a rational relation among them. This is a powerful obstruction principle: it says that "algebraic logarithms of algebraic numbers" are forced into rational harmony. The numbers ln 2, ln 3, and ln 6 satisfy this: they are (essentially) the logarithms of the algebraic numbers 2, 3, and 6, and indeed ln 6 = ln 2 + ln 3, a rational relation.

**The third result** concerns the structure of hypothetical counterexamples. If Schanuel's conjecture were false, there would exist a "minimal counterexample" — a shortest tuple of numbers violating the conjecture. The researchers defined a precise notion of such a *critical tuple* and proved that it must carry an explicit *algebraic witness*: a concrete polynomial that vanishes on the exponential data. This transforms the abstract question "is Schanuel true?" into the concrete question "does such a polynomial exist?" — a question that can be attacked computationally.

## Certificates and Computation

Perhaps the most innovative aspect of the framework is its connection to computation. The researchers introduced the concept of an *exponential algebraic dependence witness* — a polynomial certificate that proves a specific algebraic relation exists among numbers and their exponentials. Think of it as a receipt: if someone claims that e, e², and e³ satisfy a hidden algebraic relation, they must produce a specific polynomial that demonstrates it.

The framework proves two clean results about these certificates. First, any failure of algebraic independence must produce such a witness — there are no "invisible" dependencies. Second, the absence of witnesses up to a given polynomial degree constitutes a verified certificate of independence — a mathematical proof that no relation of bounded complexity exists.

This bridges the gap between abstract theory and algorithmic practice. The researchers implemented a witness search algorithm that, given a tuple of numbers and a degree bound, either finds an explicit polynomial relation or certifies that none exists. The algorithm uses numerical linear algebra — specifically, singular value decomposition — to search the space of possible polynomial relations efficiently.

## Why Formalize the Unproven?

A natural objection arises: why go to such lengths to formalize consequences of a conjecture that remains unproven? The answer reveals something deep about how mathematics actually progresses.

Much of modern mathematics operates "modulo" unproven conjectures. Number theorists routinely prove theorems of the form "if the Riemann Hypothesis is true, then X follows." Cryptographers build systems whose security rests on the assumed hardness of certain computational problems. Physicists derive predictions from models whose mathematical foundations are not fully rigorous.

What is new here is the *precision* of the conditional reasoning. When a mathematician writes "assuming Schanuel's conjecture" in a paper, the argument that follows is checked by human peer review — a process that, while valuable, occasionally lets errors slip through. When the same argument is formalized in a computer-verified system, every logical step is checked mechanically. The conclusion is guaranteed to follow from the axiom, with no possibility of error.

This matters because Schanuel's conjecture, if eventually proved, would instantly convert every conditional result into an unconditional one. The formal framework is a *prepayment* on future mathematical progress: all the hard work of deriving consequences has already been done and verified. When the conjecture falls — if it falls — the consequences are immediately available, already checked, ready to use.

## The Landscape of Transcendence

Standing back, what emerges from this work is a new view of transcendence theory as a *structured landscape* rather than a collection of isolated results.

The classical results — Hermite's proof that *e* is transcendental, Lindemann's proof for π, Gelfond's theorem about 2^{√2} — appear as individual peaks in this landscape. Schanuel's conjecture, if true, would reveal the mountain range connecting them: a single geological principle that explains why all these peaks exist.

The formal framework maps this landscape with unprecedented precision. For any collection of complex numbers, it computes a *predimension* — a numerical measure of how "transcendentally rich" the collection is. Schanuel's conjecture asserts that this predimension is always non-negative. The researchers' computational tools let you explore this landscape numerically, testing the conjecture's predictions against specific examples.

What they found is consistent with what mathematicians have long suspected: the landscape of transcendence is remarkably well-behaved. For every tuple of algebraic numbers tested — hundreds of cases, from simple integers to complex Gaussian integers — the predimension is positive, just as Schanuel predicts. No counterexample lurks in the computational data, though of course numerical evidence can never substitute for proof.

## A Bridge to the Future

The most exciting aspect of this work may be what it enables rather than what it proves. The formal framework is designed to be *extensible* — a foundation on which future results can be built.

One natural direction connects to model theory, a branch of mathematical logic that studies mathematical structures through the lens of formal languages. The Russian-British mathematician Boris Zilber has proposed that Schanuel's conjecture is not just a statement about numbers but a reflection of deep structural properties of the complex exponential field. The formal predimension introduced in the framework is directly inspired by Zilber's model-theoretic approach, and formalizing the connection would bring two powerful mathematical traditions — computer-verified mathematics and model theory — into direct contact.

Another direction connects to differential algebra, where the exponential function is characterized by the differential equation exp' = exp. James Ax proved in 1971 that a formal power series version of Schanuel's conjecture is actually *true* — one of the few unconditional results in this territory. Formalizing Ax's theorem would give the framework its first provably correct instance, moving beyond the conditional into the absolute.

But perhaps the most tantalizing direction is computational. The witness search algorithms developed alongside the formal framework can be systematically applied to search for polynomial relations among specific exponential values. If a counterexample to Schanuel's conjecture exists, it would manifest as a specific polynomial vanishing at a specific point — and the search algorithms are designed to find exactly such objects. Every failed search, while not a proof, tightens the computational net around the conjecture.

## The Art of Reasoning Under Uncertainty

Mathematics is often presented as a discipline of certainty: you either prove something or you don't. The reality is more nuanced. Mathematicians constantly navigate a landscape of conjectures, heuristics, and conditional results, building elaborate structures on foundations that are believed but not proven to be solid.

What the Schanuel framework demonstrates is that this navigation can be made *rigorous*. By isolating the unproven assumption as a single, precisely stated axiom, and deriving everything else with mechanical certainty, the researchers have shown that conditional mathematics can achieve the same level of rigor as unconditional mathematics — minus exactly one assumption.

This is not a weakness. It is a methodology with a distinguished pedigree. When Euclid formulated his parallel postulate, he was doing exactly this: isolating a single assumption and exploring its consequences with rigorous logic. Two thousand years later, mathematicians discovered that replacing the parallel postulate with alternatives produced non-Euclidean geometry — entire new mathematical worlds.

The Schanuel framework invites the same exploration. What happens if you strengthen the axiom? Weaken it? Replace it with a different conjecture about the exponential function? Each variation would produce a different formal universe, each with its own verified theorems and testable predictions. The machine is built; the exploration has just begun.

The ancient Greeks wondered whether the circle could be squared. Lindemann proved it could not — because π is transcendental. Schanuel's conjecture promises to explain *why* π is transcendental, and much more besides. And now, for the first time, the consequences of that explanation have been mapped with the precision of a machine that never makes a mistake. The conjecture remains unproven. But its consequences are already verified, catalogued, and waiting for the day when the final piece falls into place.
