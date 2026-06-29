# When "Eventually" Gets a Number

## How mathematicians learned to compute the exact moment a formula's behavior becomes predictable

---

There is a peculiar word that mathematicians use constantly and that most people have never thought twice about: *eventually*. When a mathematician says that a function "eventually" exceeds a billion, they mean there exists some threshold — some number out there on the number line — beyond which the function permanently surpasses that mark. The word sounds innocuous. But hidden inside it is one of the oldest tensions in mathematics: the gap between knowing something *must* happen and knowing *when* it happens.

For centuries, this gap was considered a philosophical nuisance, not a practical problem. If you know that exponential growth eventually outpaces polynomial growth, do you really need to know the exact crossover point? In many situations, no. But in the age of algorithms, certified computation, and AI systems that must provide guarantees about their behavior, the answer is increasingly: yes, absolutely.

A new mathematical framework now offers a way to bridge this gap — not just for one formula at a time, but systematically, for an entire language of mathematical expressions. The idea is striking in its ambition: build a machine that takes in a symbolic formula and produces, as output, the precise threshold beyond which the formula's growth is forever bounded by a known quantity.

## The Hierarchy of Growth

To understand why this matters, you need to appreciate just how wild mathematical growth can get.

Start simple: the function *f(x) = x* grows linearly. Double the input, double the output. The function *f(x) = x²* grows quadratically — faster, but still civilized. These are "level 0" functions in the growth hierarchy.

Now consider *f(x) = eˣ*, the exponential function. It starts modestly but soon rockets past any polynomial. By *x = 100*, it has left *x²* in the dust by a factor with 40 digits. This is "level 1."

But there's a level 2: *f(x) = e^{eˣ}*, the double exponential. And level 3: *e^{e^{eˣ}}*. Each level grows so overwhelmingly faster than the one below it that no constant multiplier, no matter how large, can close the gap. This is the *iterated exponential hierarchy*, a growth ladder that stretches to vertiginous heights.

In the early twentieth century, the English mathematician G.H. Hardy studied fields of functions ordered by growth rate — what we now call Hardy fields. His work, and that of successors, revealed that the iterated exponential hierarchy is not just a curiosity but a fundamental organizing principle for the zoo of rapidly growing functions that arise across mathematics, computer science, and logic.

## The Problem of Eventuality

Here's the trouble. Suppose someone hands you a complicated formula — say, the sum of two exponential expressions multiplied by a polynomial — and asks: "How fast does this grow?" You might be able to classify it: it's level 2, or level 3. You can prove, using the theory of Hardy hierarchies, that there exists a constant *C* and a threshold *N* such that the formula is bounded by *e^{C · E_n(x)}* for all *x ≥ N*, where *E_n* is the *n*-th iterated exponential.

But what are *C* and *N*? The classical proofs give you no clue. They invoke the axiom of choice, the well-ordering principle, compactness arguments — powerful tools that guarantee existence while providing no construction. You know the threshold is out there. You cannot point to it.

This is not merely an aesthetic failing. In computational applications — verifying that an algorithm's resource consumption stays within bounds, checking that a numerical approximation is accurate past a certain point, certifying that a control system remains stable — you need the actual numbers, not their ghosts.

## The Asymptotic Compiler

The new framework attacks this problem head-on. It defines a precise language of symbolic expressions — variables, constants, addition, multiplication, and exponentiation — and for each expression in this language, it *computes* three things:

1. **A level** *n*: how high in the iterated exponential hierarchy the expression sits.
2. **A constant** *C > 0*: the multiplicative factor in the exponential bound.
3. **A threshold** *N*: the exact point beyond which the bound holds.

The computation works by structural recursion — that is, it builds the answer for a complex expression from the answers for its parts, mirroring the way the expression itself is built from simpler pieces.

For a variable *x*, the bound is immediate: *|x| ≤ eˣ* for *x ≥ 1*. For a constant, it's almost as easy. The interesting cases are the operations:

- **Addition**: If *|f(x)|* and *|g(x)|* are each bounded by *e^{C · E_n(x)}*, then *|f(x) + g(x)| ≤ 2 · e^{C · E_n(x)} ≤ e^{(C+1) · E_n(x)}*, provided *E_n(x) ≥ 1* (which happens quickly).

- **Multiplication**: The constants add. If *f* has constant *C₁* and *g* has constant *C₂*, then *f · g* has constant *C₁ + C₂*. The thresholds combine by taking the maximum.

- **Exponentiation**: This is the critical step. When you exponentiate a bounded function, the bound lifts to a higher level in the hierarchy. The key mathematical insight is that *C · t ≤ eᵗ* for *t ≥ 2C* — a "level promotion" that absorbs the constant into the next exponential layer.

The result is a recursive algorithm that transforms any expression in the language into a certified growth bound, complete with explicit constants and thresholds.

## The Tower Theorem

How large can the computed thresholds get? This is a natural and important question. If the thresholds grew so fast that they were practically infinite, the framework would be theoretically interesting but computationally useless.

The answer is reassuring, if dizzying. The thresholds are bounded by a *tower of exponentials* applied to a polynomial of the expression's complexity:

*N ≤ tower(n, p(s))*

where *tower(0, m) = m*, *tower(n+1, m) = 2^{tower(n,m)}*, *n* is the expression's level, *s* is its syntactic size, and *p* is a fixed polynomial (*p(m) = m² + 3m + 7*).

For level 0 (polynomials), the thresholds are polynomial in the expression size — very manageable. For level 1 (single exponentials), they're at most exponential. For level 2 (double exponentials), they're at most double-exponential. The pattern continues: the threshold's own growth rate matches the hierarchy level of the expression being bounded. In a precise sense, the certification procedure is *optimally efficient* — it doesn't introduce unnecessary complexity.

## Why This Matters

The philosophical import is clear: "eventually" now has a computable witness. But the practical implications extend further.

**Symbolic computation.** Computer algebra systems routinely make asymptotic claims — "this integral converges," "this series is eventually positive," "this algorithm runs in O(n log n) time." These claims rest on implicit eventuality arguments. A constructive asymptotic compiler could make those implicit arguments explicit, providing certified threshold certificates alongside every asymptotic claim.

**Algorithm verification.** When a software system must guarantee that resource consumption stays within bounds, the guarantee is only as strong as the underlying mathematical proof. An explicit threshold turns a qualitative guarantee ("memory usage grows at most quadratically") into a quantitative one ("memory usage stays below this formula for all inputs of size at least 1,000").

**Complexity theory.** The tower theorem reveals a deep correspondence between the syntactic complexity of an expression and the computational complexity of certifying its growth. This invites a new question: for what classes of expressions can eventual domination be decided in polynomial time? In exponential time? The framework provides the first concrete upper bounds.

**Education and understanding.** Perhaps most importantly, the framework demystifies a concept that every mathematics student encounters but few truly internalize. "Sufficiently large" is no longer a hand-wave; it's a computation.

## The Broader Vision

This work sits at the intersection of several mathematical traditions — Hardy's growth-rate theory from the early 1900s, proof theory's ordinal hierarchies from mid-century logic, and the algorithmic turn in modern mathematics. Each tradition contributed a piece:

- **Hardy fields** gave the hierarchical classification of growth rates.
- **Proof theory** showed that growth hierarchies are connected to the strength of formal systems — faster growth corresponds to stronger axioms.
- **Constructive mathematics** demanded that existence proofs be replaced by algorithms.

The new framework synthesizes these threads. It doesn't just know that a function grows at a certain rate; it computes the exact stage at which that growth rate becomes numerically visible.

The next frontier is clear: extend the expression language, sharpen the bounds, and connect the framework to real-world software verification tools. The gap between "eventually" and "right now" has been narrowed. The work of closing it continues.

---

*This research develops a constructive asymptotic certification framework that transforms qualitative growth bounds into explicit, hierarchically bounded threshold computations for symbolic expressions, bridging Hardy hierarchy theory with algorithmic inequality proving.*
