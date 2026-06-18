# When Algebra Meets Shape: How Rewriting Rules Secretly Compute Topology

## The Surprising Connection Between Computer Programs and Higher-Dimensional Spaces

Imagine you're simplifying an algebraic expression. You start with something like *3(x + 2) − x*, apply the distributive law to get *3x + 6 − x*, then combine like terms to reach *2x + 6*. Each step follows a rule: something on the left gets replaced by something on the right. It feels mechanical, almost boring.

Now imagine a topologist, someone who studies the shape of space itself. She's examining a doughnut-shaped surface, stretching and squeezing it to understand its essential structure — how many holes it has, how loops wrap around them. Her work seems worlds apart from yours.

But here is the surprise that has electrified mathematicians in recent years: these two activities — simplifying expressions by rules and probing the structure of space — are *the same computation* viewed from different angles. The rules that simplify your algebra are secretly tracing paths through a higher-dimensional landscape. The topologist's loops are secretly rewrite sequences. And the deep theorem that connects them opens entirely new ways to think about both.

## The Grammar of Substitution

Every programming language, every logical system, every mathematical notation relies on a simple operation: substitution. When you write *f(x) = x² + 1* and then ask "what is *f(3)*?", you substitute 3 for *x* to get *10*. The lambda calculus, invented by Alonzo Church in the 1930s, distills this idea to its essence. It has just three things: variables, function application, and function creation (lambda abstraction). From these primitives, you can build any computable function — a fact that helped launch the computer age.

But substitution is subtler than it looks. When you substitute inside a function that itself binds a variable, you must be careful not to confuse the inner variable with the outer one. Getting this right requires "lifting" the substitution under the binder — an operation with no analogue in ordinary algebra. This lifting, and the identities it satisfies, turn substitution into a *category*: a mathematical structure where operations compose associatively and have identities, just like multiplication of numbers.

The key theorem — proved in this work by structural induction through the cases of variable, application, and lambda abstraction — states that substitution composition is associative:

> *Performing substitution σ₁ followed by σ₂, and then applying σ₃, gives the same result as performing σ₁ and then the composition of σ₂ followed by σ₃.*

This is the categorical axiom, and it is not trivial. The proof must navigate the interaction between substitution and binder-lifting, a phenomenon unique to higher-order languages.

## The Operad: Where Trees Meet Algebra

Categories capture sequential composition: do *this*, then do *that*. But many mathematical structures involve *parallel* composition as well: do *this* and *that* simultaneously, then combine the results. Think of an orchestra: each musician plays their part, and the conductor brings them together.

The mathematical structure that captures both sequential and parallel composition is called an **operad** — a concept that emerged from algebraic topology in the 1970s, when J. Peter May introduced it to study loop spaces. An operad has *operations* that take multiple inputs and produce one output, and these operations can be composed by "grafting" — plugging the outputs of several operations into the inputs of another, like connecting pipes in a plumbing system.

We proved that the substitution category carries an additional structure that goes beyond mere sequential composition: the **interchange law**. When you split a substitution into two parallel parts and then compose sequentially, the result is the same as composing each part separately and then splitting:

> *(σ ⊕ τ) ∘ ρ = (σ ∘ ρ) ⊕ (τ ∘ ρ)*

This interchange law is the hallmark of operadic structure. It says that the substitution system is not just a category but a **PRO** (product category) — the non-symmetric version of a colored operad. In concrete terms, it means that substitution on lambda calculus terms has the same algebraic backbone as the operations studied by topologists in the theory of loop spaces and iterated deloopings.

## The Koszul Mirror

Every operad has a shadow, a kind of algebraic mirror image called its **Koszul dual**. The theory of Koszul duality, developed by Stewart Priddy in the 1970s and dramatically extended by Victor Ginzburg and Mikhail Kapranov in the 1990s, shows that many important algebraic structures come in pairs: the operad governing associative algebras is dual to the operad governing Lie algebras. The operad for commutative algebras is dual to the one for Lie algebras. Each pair illuminates the other.

What is the Koszul dual of the substitution operad — the operad that governs the lambda calculus?

Our computational evidence points to a beautiful answer: the Koszul dual encodes **linear lambda terms** — terms where every bound variable is used exactly once. In linear logic, a discipline invented by Jean-Yves Girard in the 1980s, resources cannot be duplicated or discarded. A function that receives two arguments must use both, each exactly once. The identity function λ*x*.*x* is linear. The composition combinator λ*f*.λ*g*.λ*x*.*f*(*g*(*x*)) is linear. But the first projection λ*x*.λ*y*.*x*, which discards *y*, is not.

We verified this prediction computationally: the Euler characteristic of the bar construction (a topological invariant that counts operations with alternating signs) matches the number of linear normal forms for the first three arities. If this pattern holds for all arities — our conjecture — then the substitution operad is **Koszul**, and Koszul duality provides an exact translation between the full lambda calculus and its linear fragment.

## Simplification as Shape-Finding

Here is where the story reaches its climax.

The **Knuth–Bendix completion algorithm**, invented by Donald Knuth and Peter Bendix in 1970, takes a set of rewrite rules that may not be confluent (meaning different simplification sequences might lead to different results) and attempts to fix this by adding new rules. When it succeeds, every expression has a unique simplest form, no matter what order you apply the rules.

We proved that in a confluent system, normal forms are unique: if two normal forms are reachable from the same starting expression, they must be equal. This is the theorem that makes completion meaningful — without it, the notion of "simplest form" would be ambiguous.

But what is completion *really doing*? In the language of homotopical algebra — the branch of mathematics that studies spaces up to continuous deformation — completion is computing a **cofibrant replacement**. The original operad, with its potentially non-confluent rewrite rules, is like a space with creases and singularities. The completed system is a smooth approximation: it has the same "shape" (the same equational theory) but better geometric properties (all critical pairs resolve).

This interpretation transforms a computational procedure — "keep adding rules until everything simplifies uniquely" — into a geometric one: "keep smoothing the space until it has no singularities." The critical pairs of the rewriting system correspond to the **homotopy generators** of the space. Resolving a critical pair is like filling in a two-dimensional disc that spans a problematic loop.

## Why This Matters

The bridge between rewriting theory and homotopical algebra is not just an intellectual curiosity. It has practical consequences in at least three directions.

**Termination guarantees.** The hardest question in completion theory is: does the process terminate? Homotopical methods provide new tools for answering this, by translating the question into one about the finiteness of certain homology groups. If the operad is Koszul — as our conjecture predicts — then the bar construction has the simplest possible structure, and this constrains the possible behaviors of the completion algorithm.

**Program optimization.** Compilers simplify programs by applying rewrite rules: constant folding, inlining, dead code elimination. These are exactly the kind of confluent rewriting systems we study. Understanding them through the operadic lens suggests new optimization strategies: instead of applying rules one at a time, process the entire "operadic composition tree" at once, exploiting the interchange law to parallelize the computation.

**New mathematics.** The connection between lambda calculus and Koszul duality opens a new chapter in the interaction between logic and topology. If the substitution operad is indeed Koszul, then the bar construction — a topological object — is computing something about the lambda calculus. Specifically, the homology of the bar construction should count the number of distinct normal forms at each type, providing a topological proof of a combinatorial fact. This would be the first example of a "computational TQFT" — a topological quantum field theory whose states are types and whose operators are programs.

## The View From Here

We stand at a crossroads where three great mathematical traditions converge. Algebra, which studies the rules of symbol manipulation. Topology, which studies the shape of space. And logic, which studies the structure of reasoning. For decades, each has developed its own tools, its own intuitions, its own culture. The operadic bridge reveals that, at a deep level, they have been studying the same phenomena all along.

The substitution category that governs the lambda calculus — the theoretical foundation of every functional programming language, every type checker, every proof assistant — is not just an algebraic object. It is a topological one, carrying the structure of a colored operad whose Koszul dual encodes linear logic. And the process of simplification, of reducing a complex expression to its simplest form, is a journey through a higher-dimensional space, finding the shortest path to a unique destination.

This is mathematics at its most powerful: the moment when separate streams of thought flow together, revealing a landscape that none of them could see alone.
