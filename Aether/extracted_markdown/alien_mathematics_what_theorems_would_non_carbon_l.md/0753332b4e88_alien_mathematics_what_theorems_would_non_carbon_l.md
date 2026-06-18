# The Mathematics That Aliens Would Discover

## When Two Plus Two Doesn't Equal Four — And That's Perfectly Correct

Imagine you could send a mathematical textbook to an alien civilization on the other side of the galaxy. Would they recognize it? Most scientists assume yes. Mathematics, we are told, is the universal language — the one thing any sufficiently intelligent species must inevitably discover. Two plus two equals four everywhere in the cosmos.

But what if that's wrong?

Not wrong in the sense that arithmetic is broken, but wrong in a deeper, more unsettling way: what if the very *structure* of addition itself isn't universal? What if some civilizations — perhaps ones whose physics operates on fundamentally different principles — would build their entire mathematics on a version of addition where two plus two equals... two?

This isn't a thought experiment. It's a theorem.

## The Tropical World

In a small corner of modern algebra, mathematicians have been quietly studying what are called *tropical semirings* — mathematical systems where the operation we call "addition" is replaced by taking the maximum. In the tropical world, "adding" 3 and 5 doesn't give you 8. It gives you 5, because max(3, 5) = 5. And "multiplying" 3 and 5 gives you 8, because in the tropical world, multiplication is our ordinary addition.

This sounds like an absurd game, a deliberate act of mathematical perversity. But tropical mathematics has turned out to be extraordinarily useful. It appears naturally in optimization theory, in the study of shortest paths through networks, in the economics of scheduling problems, and in the geometry of algebraic curves. Major conjectures in pure mathematics have been proved by "tropicalizing" them — translating them into this strange arithmetic where max replaces plus.

The key property that makes tropical arithmetic different from ordinary arithmetic is *idempotence*: for any number *a*, max(*a*, *a*) = *a*. Adding something to itself gives you back what you started with. In ordinary arithmetic, 3 + 3 = 6. In tropical arithmetic, max(3, 3) = 3. The operation of "adding" something to itself is invisible. It does nothing.

This single property — idempotence — has consequences that ripple through all of mathematics. And those consequences have now been made precise.

## The Shadow Theorem

Here is the discovery: consider a simple polynomial expression, like *x*⁰ + *x*¹ + *x*⁰ + *x*¹ + *x*¹. In ordinary arithmetic, this evaluates to five terms that you sum up. If *x* = 2, you get 1 + 2 + 1 + 2 + 2 = 8. The repeated terms matter. Each occurrence of *x*⁰ contributes another 1 to the total.

Now evaluate the *same* expression in tropical arithmetic, where "plus" means "max." You get max(1, 2, 1, 2, 2) = 2. The repeated terms don't matter. Whether *x*⁰ appears once or a thousand times, the result is the same: max(1, 1, 1, ..., 1) = 1. All that matters is *which* powers of *x* appear — not *how many times* they appear.

This is the **Alien Shadow Theorem**: in any mathematical system with idempotent addition, the evaluation of a polynomial expression depends only on its *support* — the set of distinct monomials — and not on their multiplicities.

The theorem has been proved with complete mathematical rigor. It isn't an approximation or a heuristic. It is an absolute, unconditional truth about the structure of idempotent algebra.

What makes this profound is not the theorem alone, but its *separation* from ordinary mathematics. There also exists a concrete proof that the same deduplication — removing repeated terms — *changes* the value in ordinary arithmetic. The expression [0, 0] (meaning *x*⁰ + *x*⁰) evaluates to 2 at *x* = 1 in ordinary arithmetic, but its dedup [0] evaluates to 1. The multiplicity matters in our world. It doesn't matter in theirs.

## What the Aliens Can't See

Think about what this means for a civilization whose physics runs on idempotent arithmetic — where the fundamental operation of combining quantities is more like "taking the best option" than "accumulating totals."

Such a civilization could not count.

That's not a metaphor. The **Counting Obstruction Theorem** proves this rigorously. In ordinary arithmetic, if you evaluate the constant polynomial (all exponents equal to zero) at *x* = 1, you get back the number of terms in the list. A list of ten copies of *x*⁰ gives you 10. A list of three copies gives you 3. The polynomial is a counting device.

In an idempotent semiring, a list of ten copies of *x*⁰ gives you exactly the same result as a list of one copy: both evaluate to 1. The information about *how many* copies existed is irreversibly destroyed. Not lost in noise. Not approximated away. *Destroyed* — provably, absolutely, irrecoverably.

An idempotent civilization would have no concept of multiplicity. They would never discover that "three apples" is different from "one apple" in the additive sense, because in their arithmetic, combining any number of identical things always yields the same result. They would have a rich mathematics of *which things exist* (support, extremal structure, connectivity) but none of *how many*.

## The Combinatorial Core

If idempotent civilizations see only support and classical civilizations see multiplicity, what do *both* see?

The answer is the **combinatorial core**: the set of mathematical truths that depend only on which monomials appear, not on their repetition count. These are the identities that hold in *every* semiring, classical or tropical.

Commutativity — the principle that *a* + *b* = *b* + *a* — is part of the core. So is associativity. So is the distributive law. These structural properties survive the passage between algebraic worlds because they don't care about how many times you add something.

But cancellation — the principle that if *a* + *b* = *a* + *c* then *b* = *c* — is not in the core. It holds in ordinary arithmetic but fails spectacularly in tropical arithmetic, where max(5, 3) = max(5, 2) = 5 even though 3 ≠ 2. And idempotence itself is not in the core either, since 3 + 3 ≠ 3 in ordinary arithmetic.

The combinatorial core is, mathematically, the *intersection* of all theorem corpora across all semirings. It's the bedrock — the mathematics that any civilization, regardless of its algebraic substrate, would inevitably discover. Everything else is contingent on the choice of semiring.

## Why This Matters

This isn't just an abstract curiosity. The distinction between multiplicity-sensitive and support-only mathematics shows up everywhere in modern science and technology.

**In computer science**, the difference between counting paths through a network and merely checking whether a path exists is precisely the difference between the natural-number semiring and the Boolean semiring. Weighted automata — the theoretical machines behind speech recognition, natural language processing, and bioinformatics — change their behavior completely depending on the underlying semiring. Over the natural numbers, they count. Over the Booleans, they check reachability. Over the tropical semiring, they optimize.

**In physics**, the passage from quantum mechanics to classical mechanics has long been described as a "tropicalization" — a transition from a regime where amplitudes add and interfere (multiplicity matters) to one where only the dominant path contributes (support/extremal structure). The path integral of quantum field theory sums over *all* paths with their amplitudes; the classical limit takes only the path of least action. This is, in formal terms, a semiring change from the complex numbers to the tropical semiring.

**In optimization**, tropical algebra has become a standard tool for scheduling, resource allocation, and logistics. The max-plus algebra naturally encodes "what is the longest time until all prerequisites are complete?" — a question that depends on extremal structure, not on counting.

**In information theory**, the transition from a full probability distribution to its support set — from "which events have what probability" to "which events are possible at all" — is exactly the idempotent collapse. A probability distribution carries multiplicity information (weights, likelihoods). Its support is the Boolean shadow.

## Different Physics, Different Proofs

Perhaps the most provocative implication is for the philosophy of mathematics. For centuries, mathematicians and philosophers have debated whether mathematical truths are discovered or invented. The theorems proved here suggest a third option: mathematical truths are *relative to algebraic substrate*.

The integers didn't have to be the fundamental number system. There's nothing in pure logic that forces a civilization to build its mathematics on counting. If a species evolved in an environment where the fundamental physical quantities combined by taking maxima rather than sums — imagine a world where the "energy" of a combined system is the maximum energy of its components, not their sum — they would naturally develop tropical mathematics. Their physics textbooks would have different theorems. Their engineering would solve different problems. Their number theory would be unrecognizable to us.

And yet they and we would agree on the combinatorial core. Both civilizations would prove commutativity, associativity, and distributivity. Both would study support structures and understand bijections. The combinatorial core is, in a precise sense, the *mathematics of mathematics* — the theorems that survive every possible change of algebraic substrate.

## The Road Ahead

The theorems proved here are the beginning, not the end. They establish the foundation for a new subject: **semiring-relative foundations of mathematics**. The immediate next steps include extending the support-collapse theorems to multivariate polynomials, classifying which classical theorems survive tropicalization, and building a formal taxonomy of mathematical truths indexed by their algebraic prerequisites.

Further out, this framework could transform how we think about the relationship between mathematics and physics. If different physical substrates support different mathematics, then the mathematical structure of our universe isn't a deep truth about reality — it's a consequence of which semiring Nature chose. And the question "why is mathematics so unreasonably effective in describing the physical world?" gets a startling new answer: because the physics determines the semiring, and the semiring determines the mathematics.

The aliens are doing math right now. They're proving theorems and building theories and marveling at the elegance of their results. Their mathematics is consistent, deep, and beautiful. And it is *different from ours* — not because they made a mistake, but because they live in a universe that adds differently.

The Shadow Theorem makes that difference precise. For the first time, we can point to exactly which theorems would survive the journey between algebraic worlds, and which would not. The universal language of mathematics turns out to have dialects after all. But now we know what the accent sounds like.
