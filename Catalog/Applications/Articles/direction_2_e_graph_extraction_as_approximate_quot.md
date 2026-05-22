# Why Your Compiler's Secret Weapon Is a Lattice: How Equality Saturation Harnesses a Century of Abstract Algebra

## The Invisible Optimizer

Every time you run a program — loading a webpage, training an AI model, querying a database — an invisible layer of machinery works to make it faster. Compilers transform the code you write into the code the machine actually runs, and the best modern compilers don't just translate: they *optimize*. They find ways to do the same computation with fewer steps, less memory, less energy.

But here's the thing that keeps compiler engineers up at night: how do you *know* the optimized program does the same thing as the original?

For decades, the answer was: careful engineering, extensive testing, and a lot of hope. Compilers are among the most complex pieces of software ever written, and optimizer bugs — where the compiler silently changes what your program does — are a persistent nightmare. A wrong answer that looks right is far worse than a crash.

In the last few years, a technique called *equality saturation* has emerged as a powerful new approach to this problem. It's already being used in production compilers for WebAssembly, machine learning frameworks, and hardware design tools. But its mathematical foundations have remained murky, understood more through intuition than proof.

Until now. A new mathematical framework reveals that equality saturation is secretly computing with objects that mathematicians have studied for nearly a century — and that its correctness reduces to a single, elegant inequality.

## The Matchmaker's Dilemma

To understand what equality saturation does, imagine you're a matchmaker trying to find the best version of a mathematical expression. Take something simple: `(a + b) × c`. This is the same as `a × c + b × c` (by the distributive law). It's also the same as `c × (a + b)` (by commutativity). And `c × (b + a)`. And `(b + a) × c`. The list goes on.

All these expressions compute the same value for any `a`, `b`, and `c`. But they're not equally efficient. On some hardware, one arrangement might use fewer operations, or avoid expensive memory accesses, or enable further optimizations downstream.

Traditional compilers try to find the best form by applying rewrite rules one at a time: "if you see `X + Y`, try rewriting it to `Y + X`." But this is like navigating a maze by always turning left — you might find *an* exit, but not necessarily the best one. Worse, some rewrites that look helpful in isolation might prevent better rewrites later. This is called the *phase ordering problem*, and it has plagued compiler optimization for fifty years.

Equality saturation takes a radically different approach. Instead of choosing one rewrite at a time, it applies *all* rewrites simultaneously, building a compact data structure that represents *every* equivalent form of the expression at once. This data structure is called an **e-graph** — short for "equivalence graph."

## The E-Graph: A Universe in a Box

An e-graph is an extraordinary data structure. It starts with your original expression and then, step by step, merges together sub-expressions that are provably equivalent. After applying the distributive law, the e-graph "knows" that `(a + b) × c` and `a × c + b × c` are the same thing — not by replacing one with the other, but by recording that they belong to the same *equivalence class*.

As more and more rewrite rules are applied, the e-graph grows, absorbing an exponentially large set of equivalent expressions into a polynomial-sized structure. It's like a zip file for mathematical equality: a compact representation of a vast space of possibilities.

But here's the crucial question: once the e-graph has saturated — once it has discovered all the equivalences it can find — how do you *extract* the best expression from it?

This is the **extraction problem**, and it's where the mathematics gets deep.

## The Section of a Quotient

When the e-graph groups expressions into equivalence classes, it's performing what mathematicians call a *quotient*. You take a set of objects (expressions) and an equivalence relation (which expressions compute the same thing) and you form the *quotient set* — the set of equivalence classes.

The quotient map sends each expression to its equivalence class. Extraction goes the other direction: it picks one representative from each class. In mathematical language, extraction is a *section* of the quotient map — a right inverse that sends each class back to a specific member.

This is a setup that mathematicians have studied extensively. The key question is: when is it safe to replace an expression with its extracted representative? The answer, it turns out, is almost shockingly simple.

**If the equivalence relation used by the e-graph is *sound* — meaning that equivalent expressions truly have the same value in every context that matters — then extraction is automatically correct.**

That's it. One condition. One inequality. The entire correctness of the optimization pipeline reduces to checking that the e-graph's notion of "equivalent" is contained within the true mathematical notion of "equivalent."

## The Century-Old Connection

What makes this result profound is its connection to a theorem proved by the mathematician Garrett Birkhoff in 1935. Birkhoff studied *universal algebra* — the general theory of algebraic structures like groups, rings, and lattices. He proved that there is a deep duality between *equational theories* (sets of equations like `x + y = y + x`) and *varieties of algebras* (classes of structures satisfying those equations).

The modern formalization reveals that this duality takes a very specific mathematical form: a **Galois connection**. Named after the tragic genius Évariste Galois, who died in a duel at age 20, a Galois connection is a pair of maps between two ordered sets that perfectly interlock, like two gears meshing together.

On one side, you have the lattice of *congruences* — equivalence relations that respect the algebraic structure. On the other side, you have the lattice of *model classes* — sets of algebras that satisfy certain equations. The Galois connection says: a congruence is sound for a theory if and only if every model of the theory validates the congruence.

The e-graph computes an element in Birkhoff's congruence lattice. The extraction section picks a representative from each class. And the correctness theorem says that if the computed congruence is below the true semantic congruence in this lattice — a single inequality between lattice elements — then extraction preserves meaning.

## Compression and the Exponential Cliff

The new framework also reveals something unexpected: e-graph extraction is a form of *lossy compression*. Just as a JPEG compressor groups similar pixel values together and picks a representative, the e-graph groups equivalent expressions and picks the cheapest one. The "information" that's lost is the distinction between different but semantically equivalent expressions.

This connection to information theory leads to a striking prediction: while building the e-graph (computing the congruence) is efficient — polynomial time — finding the *optimal* extraction (the cheapest representative from each class) may be fundamentally hard. The number of possible extraction strategies can grow exponentially with the number of equivalence classes.

To see why, imagine an e-graph with 100 equivalence classes, each containing two expressions of equal cost. Then there are 2^100 different ways to choose representatives — more than the number of atoms in the observable universe. No algorithm can examine them all.

This is not just theoretical speculation. The framework yields a concrete proof that even for a simple congruence, there exist at least two distinct optimal extraction strategies. The exponential blowup is real, and it suggests that practical extraction algorithms must be approximate — trading provable optimality for computational tractability.

## The Composition Principle

One of the most practically important results in the new framework concerns what happens when you have *nested* optimizations. Modern compilers don't apply just one set of rewrites — they apply many, in sequence. Each pass computes a finer or coarser congruence on the expression space.

The **composition theorem** shows that this nesting is safe: if you extract from a fine congruence and then extract again from a coarser one, the result is still semantically correct. The proof works by chaining equivalences — the first extraction produces something equivalent (in the fine sense), and the second extraction produces something equivalent (in the coarse sense), and transitivity gives you overall correctness.

This seemingly simple observation has profound practical implications. It means that compiler optimization passes can be composed freely, without worrying about interactions between them — as long as each individual pass is sound.

## The Idempotence Guarantee

Another key property, proved in the new framework, is that extraction is *idempotent*: extracting from an already-extracted expression gives you the same expression back. This is not obvious — the extraction function operates on equivalence classes, not individual expressions, so you need to verify that the extracted element maps back to the same class and gets the same representative.

The proof is elegant: since the extracted element is equivalent to the original (by the section property), they belong to the same equivalence class, and extraction — being a function on classes, not elements — must give the same result.

This idempotence property is exactly what compiler engineers need: it guarantees that running the optimizer twice produces the same result as running it once. No oscillation, no instability, no surprises.

## A Bridge Between Worlds

What's remarkable about this work is how it bridges two worlds that rarely communicate. On one side, you have the practical engineers building tools like `egg` (a state-of-the-art equality saturation library) and integrating them into production compilers for companies like Fastly, Google, and Mozilla. On the other side, you have the pure mathematicians studying universal algebra, lattice theory, and Galois connections — abstract structures that seem to have nothing to do with making programs run faster.

The bridge runs in both directions. For engineers, the mathematical framework provides a *verification target*: instead of reasoning about the entire optimization pipeline, you only need to check one condition — that the e-graph congruence is sound. For mathematicians, the engineering work provides a *computational laboratory*: e-graphs are practical machines for computing with congruence lattices, turning abstract algebra into something you can run on your laptop.

## The Road Ahead

The framework opens several tantalizing directions. Can the information-theoretic connection be pushed further — can we prove fundamental limits on how much optimization is possible for a given term language? Can the Galois connection be extended to handle more complex program transformations, like loop unrolling or function inlining? Can the composition theorem be generalized to handle transformations that change the *type* of a program, not just its form?

Most provocatively: is cost-optimal extraction truly NP-hard for interesting equational theories, or are there polynomial-time algorithms hiding in the structure of specific theories? The answer could reshape how we build compilers.

For now, though, the core message is clear and beautiful: the secret weapon that makes your programs fast is a piece of abstract algebra from 1935, hidden inside a data structure from 2021, proving its correctness through a theorem that Birkhoff himself would have recognized.

Mathematics, it turns out, doesn't just describe the world. It optimizes it.
