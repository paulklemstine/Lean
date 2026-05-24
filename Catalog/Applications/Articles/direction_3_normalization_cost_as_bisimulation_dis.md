# How Far Apart Are Two Computations?

## A surprising connection between simplification steps and behavioral distance

Imagine you have two recipes for making the same cake. One calls for creaming butter and sugar before adding eggs; the other starts by whisking eggs and flour, then folding in softened butter. The final cakes taste identical, but the paths to get there differ. How would you measure how "far apart" these two recipes really are?

This is essentially the question that a new line of mathematical research answers—not for cakes, but for computations. And the answer turns out to be surprisingly elegant: the distance between two computations is simply the number of simplification steps needed to show they produce the same result.

## The Language of Computation

At the foundation of computer science lies a deceptively simple language called the lambda calculus, invented by Alonzo Church in the 1930s. It has just three ingredients: variables (like *x*), functions (like "take *x*, return *x* + 1"), and function application (plugging a value into a function). From these three building blocks, you can express any computation that any computer could ever perform.

The fundamental operation in lambda calculus is *simplification*: when you apply a function to an argument, you can substitute the argument into the function's body. For instance, applying "double *x*" to the number 3 gives you "double 3," which simplifies to 6. Each such simplification is called a *beta-reduction step*.

Here's where things get interesting. A single expression might allow several simplification steps in different orders. Think of the expression "double (1 + 2)." You could first simplify "1 + 2" to get "double 3," then simplify to 6. Or you could first expand "double" to get "(1 + 2) + (1 + 2)," then simplify each addition. Different paths, same destination.

The Church-Rosser theorem, proved in 1936, guarantees that no matter which path you take, you always arrive at the same final answer. It's as if the mathematical universe has a built-in GPS that ensures all routes lead to the same destination.

But the Church-Rosser theorem says nothing about how *long* each route is. And that, it turns out, is where a whole new geometry of computation lies hidden.

## Counting Steps as Measuring Distance

The breakthrough begins with a simple question: what if we treat each simplification step as a unit of distance?

Consider two expressions that compute the same thing. To prove they're equivalent, you need to transform one into the other through a chain of simplification steps—some going forward (simplifying) and some going backward (un-simplifying). The minimum number of steps in such a chain is a natural notion of distance between the two expressions.

This isn't just a metaphor. Researchers have now proved, with mathematical rigor verified by computer, that this step-counting distance satisfies the three axioms that define a proper distance function:

**Zero self-distance**: The distance from any expression to itself is zero. (You need zero steps to transform something into itself.)

**Symmetry**: The distance from *A* to *B* equals the distance from *B* to *A*. (If you can transform *A* into *B* in *k* steps, you can reverse the chain to go from *B* to *A* in *k* steps.)

**Triangle inequality**: The distance from *A* to *C* is at most the distance from *A* to *B* plus the distance from *B* to *C*. (You can always go through an intermediate point, even if there's a shortcut.)

These three properties make the step-counting distance a *pseudometric*—the mathematical structure that underlies notions of distance in geometry, physics, and data science.

## Why This Matters: Programs as Points in Space

Once you have a distance function on computations, something remarkable happens: computations become points in a geometric space, and you can start asking geometric questions about them.

How close are two programs? Is a compiler optimization making programs "closer" to their simplified forms? Does plugging in different inputs stretch the distance between programs, or compress it?

The researchers proved a striking result about that last question: all the basic operations of programming—applying functions, passing arguments, wrapping code in new functions—are *nonexpansive*. This means they never increase distances. If two subprograms are close together, combining them with the same surrounding code keeps them close together.

This is like discovering that the map of a city has a special property: no matter which building you walk into, the distances between addresses inside the building are never greater than the distances between the corresponding addresses outside. The structure of the space is remarkably well-behaved.

## The Bridge: Complexity Meets Behavior

The deepest result connects two different ways of thinking about computation.

On one side is *proof complexity*: how many steps does it take to simplify an expression to its final form? This is a measure of computational effort.

On the other side is *behavioral equivalence*: when do two programs behave identically from the outside? This is about what you can observe.

The bridge theorem says: **the number of simplification steps controls behavioral indistinguishability.** If you can join two expressions at a common simplified form using a total of *k* steps, then those expressions are behaviorally indistinguishable up to observation depth *k*.

In concrete terms, suppose you have two programs and you want to know if they behave the same. The theorem gives you a budget: normalize both programs, count the total steps, and that's an upper bound on how deeply you need to observe before their behaviors converge.

This is a new kind of theorem, sitting at the intersection of complexity theory and semantics. It says that computational effort—a concrete, countable quantity—bounds an abstract behavioral property. The hard work of simplification is not just producing an answer; it's producing a *certificate of similarity*.

## A New Geometry

The implications extend far beyond lambda calculus.

In software engineering, the distance function could measure how different two program versions really are—not in terms of lines of code changed, but in terms of behavioral impact. A refactoring that changes every line but preserves all behavior would have distance zero.

In compiler optimization, the framework provides a way to certify that optimizations don't change program behavior by more than a bounded amount. The normalization cost of the original program literally bounds how much behavioral change any optimization can introduce.

In theoretical computer science, the pseudometric structure opens connections to metric geometry, topological data analysis, and even physics. The evolution of a computation under simplification looks remarkably like the evolution of a physical system toward equilibrium—each step dissipating computational "energy" until a stable state (the normal form) is reached.

## The Precision of Machine Verification

What makes these results particularly compelling is their certainty. Every theorem described here has been verified by a computer proof checker, line by line, with no gaps or assumptions. The proofs are not just peer-reviewed by humans; they are certified by a program that mechanically verifies every logical step.

This matters because the mathematics involved is subtle. The triangle inequality, for instance, requires careful handling of edge cases—what happens when two expressions are in completely different equivalence classes? The symmetry of the distance function requires showing that every chain of forward and backward steps can be perfectly reversed. These are the kinds of details where human proofs sometimes harbor invisible errors. Machine verification eliminates that risk entirely.

## Looking Forward

The most exciting aspect of this work may be what it opens up. Once you have a well-behaved distance function on programs, you can ask whether evaluation is a *contraction*—does running a program always bring equivalent programs closer together? If so, iterative optimization strategies would have guaranteed convergence, with known convergence rates.

You can ask whether the distance function is *fully abstract*—does it capture exactly the observational differences between programs? If so, the geometric and behavioral views of computation would be provably identical.

And you can ask about the *shape* of the space of all programs. What does it look like? Does it have interesting topology? Are there "mountains" of computationally expensive programs and "valleys" of efficient ones?

These questions sit at the frontier of mathematics and computer science. The distance function described here is a first step—a coordinate system for the space of all computations. Where that space leads is a story still being written.

## The Bottom Line

Mathematics has revealed that the simplification steps in symbolic computation are not just a path to an answer—they are a *ruler* that measures behavioral similarity. Two programs that simplify to the same result in few steps are behaviorally close; those requiring many steps are behaviorally distant. This simple insight, once made rigorous, creates an entirely new geometric perspective on computation—one where the familiar tools of distance, continuity, and convergence apply to the most abstract objects in computer science.
