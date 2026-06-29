# The Mathematics of Comparing Translations

## When one translation is strictly better than another — and how to prove it

---

Imagine you're a diplomat at the United Nations, listening to a speech delivered in Mandarin. Two interpreters are working simultaneously, translating into English. Both capture the essential meaning. But one of them consistently preserves more nuance — more of the speaker's rhetorical structure, more of the cultural context, more of the precise technical terminology. You sense this intuitively, but could you *prove* it?

This question — how to formally compare translations between complex systems — turns out to be one of the deepest in modern mathematics. And a new body of work has cracked it open in a surprising way, by discovering that translations between mathematical theories form a rich geometric structure called a *locally preordered 2-category*. The name is a mouthful, but the idea is elegant: it's a mathematical universe where you can not only translate between systems, but rigorously compare which translations are better, and guarantee that composing better translations always gives better results.

## The Problem of Comparing Interpretations

Scientists and engineers constantly translate between formal systems. A physicist describes the same phenomenon using quantum mechanics or classical mechanics. A computer scientist compiles a high-level program into machine code. A biologist maps genetic sequences to protein structures. In each case, the translation preserves some structure and loses some.

But here's the puzzle: when you have two different translations between the same systems, how do you know which one is better? And when you chain translations together — say, translating from physics to mathematics to computer code — how do you know the composed translation preserves as much as possible?

For decades, mathematicians have had excellent tools for studying individual translations (called *morphisms* in category theory, the branch of mathematics that studies structure-preserving maps). But comparing translations to each other — saying "this morphism is better than that one" — required stepping up to a higher dimension. You needed what mathematicians call *2-cells*: arrows between arrows.

## Climbing the Categorical Ladder

Category theory, born in the 1940s from the work of Samuel Eilenberg and Saunders Mac Lane, gave mathematics a universal language for talking about structure. In a category, you have objects (the things) and morphisms (the structure-preserving maps between things). The genius of the framework is its generality: groups, topological spaces, vector spaces, databases, programming languages — they all form categories.

But categories have a limitation. They tell you that a morphism exists, but they can't compare two morphisms going between the same objects. It's like having a map of all the roads between cities, but no way to say which road is faster.

In the 1960s, Jean Bénabou introduced *bicategories* — categories with an extra layer. In a bicategory, you have objects, morphisms between objects, and *2-morphisms* between morphisms. It's like adding elevation to a flat map: suddenly you can see which roads go uphill and which go down, which are smooth and which are rough.

The new work constructs a bicategory where the objects are *research theories* — mathematical systems equipped with a numerical invariant that measures their complexity or depth. The morphisms are translations that preserve this complexity measure. And the 2-cells capture the intuitive notion of "better translation": one translation dominates another if it consistently maps to higher-complexity images.

## The Key Discovery: When Composition Works

The most striking result is about *horizontal composition*. Suppose you have two translations from theory A to theory B, and two more from theory B to theory C. If the first pair is ordered (one dominates the other) and the second pair is also ordered, does the ordering survive when you compose them end-to-end?

The answer, it turns out, is *not automatic*. A translation that increases invariant values (sending simple objects to complex ones) doesn't necessarily respect the ordering between invariant values. If you map "apple" to "fruit" and "bicycle" to "vehicle," the fact that you always increase abstraction doesn't mean you preserve the *relative ordering* of how abstract things are.

This is a genuine mathematical discovery. The researchers identified the precise extra condition needed: the translation must not only increase invariants, but preserve their relative ordering. Maps with this stronger property — called *ordered theory morphisms* — form a well-behaved bicategory where everything composes correctly.

The result is captured in what mathematicians call the *interchange law*: if you have a grid of translations and orderings, you can compose them in any order — first horizontally then vertically, or first vertically then horizontally — and get the same result. This seemingly technical property has profound implications: it means that optimizing translations is *modular*. You can improve each piece of a pipeline independently, and the improvements compose.

## What This Means for the Real World

The applications span an remarkable range of fields.

**In computer science**, compilers translate high-level programs into machine code. Different optimization strategies produce different translations. The 2-cell ordering provides a mathematical certificate that one optimizer is uniformly better than another — not just on benchmarks, but provably, for every possible input. The interchange law guarantees that composing better optimization passes always gives a better compiler.

**In artificial intelligence**, neural networks can be viewed as translations between representation spaces. Each layer maps inputs to a new representation, and the quality of that representation determines how well the network performs. The theory bicategory provides a framework for comparing architectures: if network A produces uniformly better representations than network B at each layer, then the composed network A is provably better overall.

**In knowledge representation**, different ontologies classify the same domain at different levels of granularity. A medical ontology might classify diseases by organ system or by molecular mechanism. The 2-cell ordering captures "this classification is more informative than that one," and the bicategory structure ensures that combining more informative classifications always gives more informative results.

**In abstract interpretation**, the technique at the heart of modern program analysis, different abstractions approximate program behavior with different precision. The connection is so direct that Galois connections — the mathematical tool used in abstract interpretation — are adjunctions in the theory bicategory.

## The Geometry of Scientific Understanding

Perhaps the most profound implication is philosophical. The theory bicategory provides a precise language for talking about *scientific reduction*. When physicists say that thermodynamics "reduces to" statistical mechanics, or that chemistry "reduces to" quantum mechanics, they mean that there exists a translation between the theories that preserves essential structure. The 2-cell ordering makes this precise: one reduction is better than another if it preserves more invariant content.

This opens the door to a formal *metatheory of science*: a mathematical framework for comparing, composing, and optimizing the translations between scientific domains. Instead of arguing informally about whether one model is "better" than another, scientists could prove it — with the same rigor used to prove theorems about the models themselves.

The structure also reveals a beautiful geometric pattern. The hom-sets (collections of all translations between two theories) form preorders — partially ordered sets where some pairs are comparable and others are not. These preorders are the "local geometry" of the bicategory. The composition of translations is monotone — it respects the local ordering — which means the global structure and local structure are harmoniously intertwined.

## From Theories to Practice

The construction was verified with complete mathematical rigor, leaving no logical gaps. Every step — from the reflexivity and transitivity of 2-cells, through the horizontal composition theorem, to the full interchange law — was machine-checked. The proof revealed subtleties that informal reasoning might miss: for instance, the crucial role of the ordered morphism condition, without which the bicategory fails to close under horizontal composition.

Concrete examples demonstrate that the 2-cells are not vacuous. There exist pairs of distinct translations where one strictly dominates the other — showing that the ordering has genuine mathematical content. And the initial object (a theory with no content at all) serves as a universal source: there is exactly one translation from nothing to anything, reflecting the logical principle that from the empty theory, any conclusion follows vacuously.

## Looking Ahead

This work is a beginning, not an end. The immediate next steps include generalizing from yes-or-no comparisons to quantitative ones (measuring *how much* better one translation is), constructing limits and colimits (systematic ways to combine theories), and establishing fixed-point theorems (finding stable points where iterative refinement converges).

The deeper vision is a mathematical infrastructure for *formal higher metamathematics* — a rigorous framework in which theories about theories can be stated, compared, composed, and optimized, all with machine-checked guarantees. In a world increasingly dependent on the reliability of formal systems — from AI safety to cryptographic protocols to autonomous vehicles — the ability to certify that one interpretation of a system is provably better than another is not just elegant mathematics. It may be essential.

The two interpreters at the United Nations can now be compared. Not just by intuition, but by theorem.
