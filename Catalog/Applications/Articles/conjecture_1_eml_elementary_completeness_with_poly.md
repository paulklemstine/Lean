# One Gate to Rule Them All: The Quest to Simplify Every Formula in Mathematics

## The Formula Explosion

Pick up any physics textbook and flip to the back. You will find page after page of formulas involving exponentials, logarithms, sines, cosines, square roots, and more — the standard toolkit of science and engineering. Each of these functions feels like a separate invention, a distinct mechanism with its own rules, its own behavior, its own surprises.

But what if most of that complexity is an illusion?

What if there were a single mathematical operation — a single gate, in the language of computer science — that could replace every exponential, every logarithm, and every combination of the two? And what if this replacement could be done without the formulas exploding in size?

This is the audacious idea behind what researchers are calling the **EML conjecture**, and recent work has produced the first rigorous evidence that it might be true.

## The NAND of Analysis

To understand why this matters, consider an analogy from digital electronics. Every computer chip, every smartphone, every server running the internet — all of them are built from logic gates: tiny switches that compute simple operations like AND, OR, and NOT. In the 1930s, mathematicians proved something remarkable: you don't actually need all those different gates. A single gate called NAND (short for "not-and") can do everything. Every logical operation, no matter how complex, can be built from NAND gates alone.

This insight didn't just simplify theory. It revolutionized chip design. If you only need one kind of gate, manufacturing becomes simpler, optimization becomes systematic, and verification becomes tractable.

Now imagine doing the same thing, not for logic, but for the continuous mathematics of the physical world — the calculus of exponentials and logarithms that governs everything from radioactive decay to compound interest, from the spread of epidemics to the behavior of black holes.

The candidate for this role is a function that looks deceptively simple:

**eml(x, y) = eˣ − log y**

That's it. Take the exponential of one number, subtract the logarithm of another. This single operation, combined with ordinary arithmetic (addition, subtraction, multiplication, division), turns out to be enough to express *every* elementary function of one variable.

## Why exp and log?

The exponential function eˣ and the natural logarithm log x are the twin pillars of continuous mathematics. The exponential describes growth: populations, investments, nuclear chain reactions. The logarithm measures scale: the Richter scale for earthquakes, the decibel scale for sound, the pH scale for acidity. Together, they form the backbone of calculus, differential equations, and mathematical physics.

But they also come with baggage. The exponential can blow up to infinity. The logarithm is undefined for negative numbers and zero. Composing them creates subtle traps: is log(eˣ) always equal to x? (Yes, in the reals.) Is e^(log x) always equal to x? (Only when x is positive.) These domain restrictions make formulas involving exp and log notoriously tricky to manipulate by computer.

The EML function packages both operations into one, in a way that makes their interaction explicit. When you write eml(x, 1), you get eˣ, because log 1 = 0. When you write 1 − eml(0, y), you get log y, because e⁰ = 1. Every combination of exponentials and logarithms can be built from these patterns using only arithmetic and the eml operation.

## The Compilation Theorem

Saying that something *can* be expressed is one thing. Saying that it can be expressed *efficiently* is quite another.

Consider an analogy from language. You can express any idea in English using only the 850 words of Basic English. But try translating Shakespeare into Basic English and you'll find your sentences becoming absurdly long and convoluted. The compression comes at a cost in expansion.

The central surprise of the EML research is that this kind of explosion does *not* happen. When you translate any elementary formula into EML form, the result is at most four times larger than the original. Not four times larger per operation, compounding exponentially — four times larger, period. A formula with 100 nodes becomes a formula with at most 400 nodes. A formula with a million nodes becomes a formula with at most four million.

This is not a hand-wavy estimate. It is a *theorem*, proved with mathematical certainty:

> For every elementary expression e, the EML-compiled form has size at most 4 × size(e).

The proof proceeds by structural induction on the expression tree. The worst case occurs when the formula consists entirely of nested logarithms, each of which requires four extra nodes in EML form (a subtraction, a constant 1, a constant 0, and the eml node itself). But even this worst case is merely a constant-factor expansion.

## What Gets Preserved

Size is not the only thing that matters. The translation also preserves several deeper structural properties.

**Semantic correctness.** The compiled formula computes exactly the same function as the original, on exactly the same domain. If the original is undefined at some point (because of a logarithm of a negative number, or a division by zero), the compiled version is undefined at exactly the same point.

**Transcendence rank.** Every exponential or logarithm in the original becomes exactly one eml node in the compiled form. The number of transcendental operations is preserved exactly — not approximately, not up to a constant factor, but on the nose.

**Domain geometry.** The set of inputs where the formula is well-defined — what mathematicians call the natural domain — is identical before and after compilation.

These preservation properties mean that EML compilation is not a lossy compression. It is a faithful translation that carries all the mathematical content of the original formula into a simpler language without any distortion.

## The Polynomial Conjecture

The linear size bound for compilation is the launchpad, not the destination. The deeper question is about *normalization*: can you simplify EML expressions — canceling redundancies, collapsing nested exp-log pairs, eliminating dead branches — without the formula blowing up in size?

Anyone who has used a computer algebra system knows that simplification can be treacherous. Sometimes simplifying a formula makes it larger. Sometimes much larger. The question is whether EML normal forms can avoid this trap.

The **EML polynomial conjecture** states: every elementary expression admits an EML normal form whose size is bounded by a polynomial in the original size. Not exponential. Not doubly exponential. Polynomial.

Early experimental evidence is encouraging. Across thousands of systematically generated test expressions, the ratio of normalized size to original size fits a power law with exponent approximately 1 — suggesting that the growth may actually be *linear*, not merely polynomial.

But experiments are not proofs. The conjecture remains open, and there are reasons to suspect that the full story is more subtle.

## Where the Difficulties Hide

The exp and log functions have a personality trait that makes them dangerous for formula manipulation: their domains don't compose cleanly. The logarithm requires a positive argument. Nested logarithms require arguments that are not just positive but greater than 1 (for the outer log to receive a positive input). Divisions can create zeros. Exponentials can create overflows.

These domain restrictions are not mere technicalities. They are the primary source of complexity in formula manipulation. When you simplify a formula, you may need to verify that every intermediate value satisfies a positivity condition, and proving positivity can itself be an arbitrarily hard problem.

This suggests a refined version of the conjecture: on the subclass of expressions where positivity conditions are syntactically guaranteed (what the formal development calls "EML-safe" expressions), polynomial normalization should always be achievable. The hard cases are precisely those where domain analysis is computationally expensive.

## Connections to Computer Science

The EML framework is not just pure mathematics. It connects to several active areas of computer science and engineering.

**Symbolic computation.** Computer algebra systems like Mathematica and Maple spend enormous effort simplifying expressions involving exp and log. If EML normal forms provide a canonical representation with guaranteed size bounds, simplification algorithms could become faster and more predictable.

**Verified computing.** In safety-critical applications — aerospace, medical devices, nuclear engineering — formulas must be verified to produce correct results. A compact normal form with machine-checked correctness guarantees could serve as a certificate of formula validity, replacing expensive runtime checks with compile-time proofs.

**Machine learning.** Neural networks increasingly use symbolic regression to discover scientific formulas from data. The EML framework suggests that the search space of elementary functions has more structure than previously recognized: every candidate formula has a canonical EML form, and the complexity of that form provides a natural regularization criterion.

**Thermodynamics and information theory.** The exponential and logarithm are the core operations of statistical mechanics. The partition function is a sum of exponentials; entropy is an expectation of logarithms; free energy is a logarithm of the partition function. EML provides a uniform language for all these quantities, potentially simplifying theoretical calculations and numerical implementations.

## The Bigger Picture

The history of mathematics is, in part, a history of finding the right primitives. Euclid built geometry from five postulates. Boole reduced logic to AND, OR, and NOT — and then others reduced it further to NAND alone. Turing showed that a single, simple machine could compute anything computable.

Each of these reductions seemed, at first, like a mere curiosity. But each turned out to unlock a new field. Boolean algebra became digital electronics. Turing machines became computer science. Normal forms in logic became automated theorem proving.

The EML conjecture proposes a similar reduction for continuous mathematics. If every elementary formula can be expressed through a single analytic gate with controlled complexity, then the space of elementary functions has a canonical structure that we are only beginning to explore.

The linear compilation bound is proved. The polynomial normalization conjecture is open. The experiments are promising. The formal verification infrastructure is in place. What remains is the deep mathematical work of understanding when and why normalization stays polynomial — and what happens when it doesn't.

This is not just a theorem about formula size. It is the opening chapter of a new complexity theory: the complexity theory of elementary analysis.

## What Comes Next

The immediate next steps are both theoretical and experimental. On the theoretical side, researchers need to characterize the exact boundary between expressions that normalize polynomially and those that might not. The leading candidate for this boundary is the complexity of domain analysis — proving that logarithm arguments are positive.

On the experimental side, systematic enumeration of expressions up to depth 10 and beyond will test whether the linear growth pattern persists or whether counterexamples emerge at larger scales. The comparison between tree-based and DAG-based (shared subexpression) representations is particularly important: if sharing is necessary for polynomial bounds, this would mirror a well-known phenomenon in circuit complexity.

And there is a wild card: the connection to open questions in transcendental number theory. The Schanuel conjecture, one of the great unsolved problems in mathematics, concerns the algebraic independence of exponentials and logarithms of algebraic numbers. EML normal forms provide a new language in which to state and study such questions, potentially connecting formula complexity to deep number-theoretic structure.

The gate is open. The question is how far it leads.
