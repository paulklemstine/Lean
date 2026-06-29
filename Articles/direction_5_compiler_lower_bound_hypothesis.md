# The Computations No Optimizer Can Speed Up

*Why some programs are provably immune to compiler optimization — and what that tells us about the deep structure of computation*

---

There is something unsettling about a mathematical proof that says "you can't." Not just "nobody has figured out how," but "nobody ever will." That a certain operation is fundamentally impossible, no matter how clever the approach, how powerful the tools, or how much time you have.

For over half a century, computer scientists have built increasingly sophisticated optimizing compilers — programs that take other programs and make them faster. Modern compilers perform hundreds of transformations: they eliminate redundant calculations, fold constants, rewrite algebraic expressions, share common subexpressions, and reorganize data flow. These optimizations are so effective that hand-tuning code is rarely worth the effort anymore.

But there has always been a nagging question at the theoretical foundations: **Are there computations that no optimizer, no matter how powerful, can fundamentally speed up?**

A new mathematical result provides a definitive answer — and the answer is yes, in a surprisingly strong sense.

## The Tower of Exponentials

To understand what's going on, consider a family of mathematical functions that grows unfathomably fast. Start with a number *x*. Apply the exponential function once: *e^x*. Apply it again: *e^(e^x)*. And again: *e^(e^(e^x))*. Each application of *exp* launches the value into an entirely new stratosphere of magnitude.

Mathematicians call this the *iterated exponential*, and they write it as *E_n(x)* — meaning "apply the exponential function *n* times to *x*." At *x* = 1:

- *E_0(1)* = 1
- *E_1(1)* = *e* ≈ 2.718
- *E_2(1)* = *e^e* ≈ 15.15
- *E_3(1)* = *e^(e^e)* ≈ 3,814,279
- *E_4(1)* = a number with over 1.6 million digits
- *E_5(1)* = ... beyond comprehension

Each level doesn't just get bigger — it gets bigger by an incomprehensibly larger factor than the previous level. *E_3* is astronomically larger than *E_2*, but *E_4* makes *E_3* look like a rounding error. This isn't just fast growth; it's a *hierarchy* of growth, where each level dwarfs everything below it.

## The Language of Computation

Now imagine you have a programming language — call it EML — designed for computing with exponentials. In this language, you can write numbers, add them, multiply them, negate them, and perform one special operation: `eml(a, b) = a × exp(b)`. This single operation is the gateway to exponential growth. Everything transcendental in the language flows through this one gate.

The key measure of complexity in EML is the *depth*: how many nested `eml` operations appear on the longest chain from input to output. If you write `eml(1, eml(1, eml(1, x)))`, that's depth 3 — three nested exponentials computing *e^(e^(e^x))*.

The natural question is: can you compute *E_n(x)* with fewer than *n* nested `eml` operations? Can some clever algebraic rearrangement — multiplying instead of exponentiating, sharing intermediate results, factoring expressions — reduce the depth?

The answer, proved mathematically, is no. Computing *E_n(x)* requires at least *n* nested `eml` operations. Each layer of the exponential tower demands its own dedicated `eml` operation. There are no shortcuts.

## From Lower Bounds to Compiler Impossibility

This much has been suspected by complexity theorists for years. What's new — and what transforms this from a technical observation into something genuinely startling — is the next step.

Imagine a compiler that takes EML programs and optimizes them. It can perform any transformation it wants, subject to just two rules:

1. **Correctness**: The optimized program must compute the same function as the original on all positive inputs.
2. **Structure preservation**: If the original program avoids using division (what mathematicians call "inverse-freeness"), the optimized program must also avoid division.

These are not unreasonable constraints. Correctness is the absolute minimum requirement for any compiler — an optimization that changes what a program computes is a bug, not an optimization. And preserving the avoidance of division is a natural structural constraint that many real optimizers satisfy.

The theorem says: **Under these two constraints, no optimization — not constant folding, not common subexpression elimination, not algebraic simplification, not any sequence of these operations in any order — can reduce the depth of an iterated exponential program below n.**

This isn't about one specific optimization being weak. It's about *all possible* optimizations satisfying these constraints being provably incapable of beating the lower bound. You could invent an entirely new optimization technique, one that nobody has ever thought of, and as long as it's correct and structure-preserving, it still cannot break the barrier.

## The Asymmetry

What makes this result especially striking is the asymmetry it reveals. Optimization can help — just not in the way you might hope.

A good optimizer applied to an *E_n* program can:
- **Reduce size** by eliminating redundant computations
- **Fold constants** by evaluating arithmetic at compile time
- **Eliminate dead code** and simplify algebraic structure
- **Increase sharing** by identifying common subexpressions

But it cannot:
- **Reduce depth** below *n*

The computation can be made smaller, simpler, and more elegant. But it cannot be made shallower. The depth — the length of the longest chain of dependent exponential operations — is an immovable barrier.

Think of it like a mountain range. You can build roads around the peaks, blast tunnels through the rock, and engineer the most efficient path possible. But you cannot lower the mountains themselves. The elevation is an intrinsic feature of the terrain, not an artifact of your route planning.

## Why Depth Matters

Why should anyone care about depth? Because in the modern world of parallel computing, depth is everything.

When you have thousands of processors available — as in a modern GPU or a cloud computing cluster — the *total amount of work* matters less than the *longest chain of sequential dependencies*. If you have a thousand independent tasks, a thousand processors can finish them all at once. But if task 500 depends on the result of task 499, which depends on task 498, and so on in a chain of length 1000, then no amount of parallelism helps. You're stuck waiting for the chain to complete.

The depth of an EML program is exactly this sequential dependency chain for exponential operations. The theorem says that for iterated exponentials, this chain has an irreducible minimum length. No matter how cleverly you schedule the computation, no matter how many processors you have, you cannot execute *E_n* in fewer than *n* sequential exponential steps.

## The Pipeline Theorem

The result extends beyond individual optimizations to entire compilation pipelines. Modern compilers don't apply a single optimization — they apply dozens, often repeatedly, in carefully tuned sequences. A typical compilation might run constant folding, then common subexpression elimination, then algebraic simplification, then constant folding again, then...

The *pipeline theorem* says: it doesn't matter. You can compose any number of valid optimization passes in any order, repeat them as many times as you like, and the depth barrier remains unbreached. The impossibility is *stable under composition*.

This is not obvious. In other settings, combining individually weak transformations can produce surprisingly powerful results. But here, the lower bound is a genuine obstruction — a mathematical wall that no sequence of correct transformations can penetrate.

## A Window Into Deep Structure

What does this tell us about computation in general? The result sits at a remarkable crossroads of several fields:

**Circuit complexity**: EML expressions are algebraic circuits, and the depth lower bound is a circuit depth lower bound. The theorem joins a select family of unconditional lower bounds in computational complexity — a field where proving anything is provably difficult is notoriously hard.

**Parallel computing**: The depth barrier is a scheduling lower bound. It says that certain computations have an irreducible sequential component that no parallelism can eliminate. This connects to the classical theory of work-depth tradeoffs in parallel algorithms.

**Compiler theory**: This appears to be the first *impossibility theorem* for compiler optimization in an algebraic language. Previous work in verified compilation (exemplified by projects like CompCert) focused on proving that optimizations are *correct*. This result adds a new dimension: even correct optimizations have *limits*.

**Abstract interpretation**: Compiler optimizations often work by building approximate models of program behavior. The theorem implies that no such approximation, no matter how sophisticated, can discover a way to reduce exponential depth that doesn't exist.

## What We Don't Know

Every breakthrough opens more questions than it answers. Can the result be extended beyond the EML language to richer programming languages with loops and recursion? Are there other families of functions, beyond iterated exponentials, that exhibit similar optimization barriers? Is there a general theory of "optimization-resistant" computations?

Perhaps most tantalizing: the result shows that depth is a *resource monotone* — a quantity that can only decrease through certain types of transformations but never below a fixed minimum. Are there other such monotones? Could we develop a full "periodic table" of optimization barriers, each corresponding to a different resource that different optimizations cannot reduce?

## The Bigger Picture

At its core, this result says something profound about the relationship between syntax and semantics in computation. You can rearrange, simplify, and optimize the *syntax* of a program — its textual representation — in many ways. But the *semantics* — what the program actually computes — imposes hard constraints that no syntactic manipulation can overcome.

The iterated exponential is a computation whose semantic complexity is *intrinsic*. It's not an accident of how you write the program. It's a feature of the mathematical function itself. And that feature is visible as a depth barrier that no correct compiler can breach.

In a world where computation grows ever more powerful, it's worth remembering that some things are provably, mathematically, forever beyond optimization's reach. Not because we haven't been clever enough, but because the mathematics won't allow it. That's not a limitation to lament — it's a deep truth to celebrate.

---

*The formal proof of these results has been verified by machine, ensuring mathematical certainty beyond what any human review could provide. The verification covers the full chain: from the definition of the EML language, through the semantics of optimization passes, to the final impossibility theorem and its instantiation on concrete optimizations.*
