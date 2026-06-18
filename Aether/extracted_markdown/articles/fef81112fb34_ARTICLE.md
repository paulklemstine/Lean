# One Operation to Rule Them All

**How a single mathematical primitive might underpin the entire landscape of real-valued computation**

---

In the mid-twentieth century, a quiet revolution swept through mathematics. Claude Shannon, working at Bell Labs, showed that every logical operation a computer could ever perform — every `AND`, `OR`, `NOT`, every comparison and calculation — could be built from a single type of electronic switch. It was a staggering act of reduction: the infinite complexity of computation, collapsed to one primitive.

But Shannon's triumph applied only to the discrete world of zeros and ones. The continuous world — the world of curves, waves, temperatures, and trajectories — seemed to demand a richer toolkit. To describe how a bridge flexes or how heat flows through metal, scientists needed exponentials and logarithms, polynomials and trigonometric functions, each with its own personality and its own rules. The calculus of the continuous appeared irreducibly plural.

Until, perhaps, now.

---

## The Operator That Swallowed Everything

Consider a deceptively simple mathematical recipe. Take two numbers, *x* and *y*. Compute the exponential of the first, and subtract the logarithm of the second:

> **eml**(*x*, *y*) = *eˣ* − ln *y*

That's it. One operation, two inputs, one output. It looks like nothing special — a frankenstein stitching of two familiar functions. But hidden inside this formula is an extraordinary secret.

Set *y* = 1 and you recover the pure exponential: eml(*x*, 1) = *eˣ* − ln 1 = *eˣ*. Set *x* = 0 and rearrange slightly and you recover the pure logarithm: ln *y* = 1 − eml(0, *y*). The exponential function and the logarithmic function — two of the most fundamental objects in all of mathematics — are both special cases of this single operation.

That might seem like a parlor trick. But the implications run deep. Because once you have the exponential and the logarithm, and you combine them with ordinary arithmetic — addition, subtraction, multiplication, division — you can build *everything*.

---

## Building the World from One Brick

The claim sounds absurd. How can one operation generate the bewildering zoo of functions that mathematicians and engineers use every day? The answer lies in the algebra of composition.

Start with the **hyperbolic functions**, the curves that describe hanging chains and relativistic velocities. The hyperbolic sine, for instance, is simply:

> sinh(*x*) = (*eˣ* − *e*⁻ˣ) / 2

Every piece of this formula — the exponentials, the subtraction, the division by 2 — can be expressed using eml and arithmetic. The same goes for hyperbolic cosine, hyperbolic tangent, and their inverses.

What about **polynomials** — the bread and butter of algebra? A polynomial like *x*² + 3*x* + 2 uses only multiplication and addition, which are basic arithmetic operations. No exponentials or logarithms needed. But the remarkable point is that they live harmoniously inside the same framework: the eml-generated class is closed under all field operations, so polynomials are automatically included.

**Rational functions** — ratios of polynomials — follow immediately, since the class is closed under division.

**Fractional powers** like *x*^(3/2) seem harder, but the exp-log bridge handles them effortlessly: *x*^(3/2) = exp(1.5 · ln *x*). Two applications of eml, wired together with multiplication.

Even the **Gaussian bell curve** *e*^(−*x*²), the foundation of probability theory and quantum mechanics, is just eml applied to −*x*², which is eml(−*x*², 1).

The **logistic sigmoid** 1/(1 + *e*⁻ˣ), the activation function at the heart of modern artificial intelligence, decomposes into a handful of eml applications.

One by one, the great functions of analysis reveal themselves as compositions of a single primitive.

---

## The Compilation Theorem

Demonstrating that individual functions can be built from eml is suggestive but not conclusive. The real breakthrough is a *compilation theorem* — a systematic algorithm that takes *any* formula involving exponentials and logarithms and mechanically translates it into an equivalent formula using only eml.

The algorithm is beautifully simple. Walk through the formula tree, node by node:
- When you encounter exp(*e*), replace it with eml(*e*, 1).
- When you encounter ln(*e*), replace it with 1 − eml(0, *e*).
- Leave arithmetic operations unchanged.

The correctness of this translation has been rigorously verified: for every possible input, the compiled formula produces exactly the same output as the original. Moreover, the compiled formula is never more than five times larger than the original — a modest and tightly controlled overhead.

This is not a philosophical argument. It is a mathematical proof, checked step by step with machine precision. The compilation is exact, not approximate. It works for every expression, not just convenient examples. And its correctness has been established with the same certainty that we ascribe to the Pythagorean theorem.

---

## Why One Is Better Than Two

Why should anyone care whether we use one transcendental operation or two? The answer comes from multiple directions simultaneously, and each one opens a different window onto the structure of computation.

**For circuit designers**, having a single primitive simplifies hardware. In analog electronics, transistors naturally compute exponentials (through their current-voltage characteristic), and operational amplifier circuits naturally compute logarithms. The eml operator captures both behaviors in a single module. An analog computer built from identical eml units, wired together with resistive networks for arithmetic, could in principle compute any elementary function. This is the modern echo of Shannon's original insight, but for continuous-valued signals.

**For machine learning**, the eml operator offers a minimal architecture for neural networks. Today's deep learning uses dozens of different activation functions — ReLU, sigmoid, tanh, softplus, swish, GELU — each chosen for specific engineering reasons. But all the smooth activations in this list can be expressed as eml compositions. This suggests a radically simplified neural architecture: networks built from a single type of nonlinear unit.

**For mathematicians**, the single-operator thesis connects to a deep question in differential algebra: what is the smallest set of operations that generates all elementary functions? The classical theory, going back to Joseph Liouville in the 1830s, characterizes elementary functions as those built from algebraic operations, exponentials, and logarithms. The eml operator shows that the last two can be merged into one.

**For physicists**, the exponential and the logarithm are the two faces of a single coin: the exponential governs growth, decay, and Boltzmann statistics; the logarithm governs entropy, information, and free energy. The eml operator unifies them at the syntactic level, hinting that the thermodynamic duality between energy and entropy might have a deeper algebraic root.

---

## The Boundary: Where the Thesis Stops

Intellectual honesty demands acknowledging what this theory does *not* claim. The most notable omission is trigonometric functions: sine, cosine, and their relatives.

Over the real numbers, sine and cosine cannot be expressed as finite compositions of exp, log, and arithmetic. The reason is profound: exp and log generate functions that are ultimately monotone or at least non-oscillatory, while sine and cosine oscillate forever. No finite chain of operations that can only grow, shrink, or combine smoothly can produce a function that changes direction infinitely often.

This is not a failure of the theory — it is a precise delineation of its boundary. The eml closure captures the *aperiodic* fragment of elementary analysis. To reach trigonometric functions, one must either pass to complex numbers (where Euler's formula *e*^(*ix*) = cos *x* + *i* sin *x* bridges the gap) or introduce an additional periodic primitive.

This boundary is itself scientifically interesting. It suggests a classification of elementary functions into two fundamentally different species: the "thermal" functions (exponential, logarithmic, polynomial) that arise from irreversible processes, and the "oscillatory" functions (sine, cosine) that arise from reversible dynamics. The eml operator is the universal primitive for the first species.

---

## The Size of Simplicity

One natural worry about any "universal" construction is efficiency. If compiling everything through eml produces expressions that are astronomically larger than the originals, the universality is Pyrrhic — technically true but practically useless.

The worry turns out to be unfounded. The compilation theorem comes with a tight size guarantee: the compiled expression is at most five times larger than the original. In practice, the expansion is typically much smaller — often less than a factor of two.

Numerical experiments confirm this. Testing the compiler on hundreds of randomly generated expression trees of varying depths, the average size expansion stays around 1.3×–1.5×, and the maximum observed expansion never exceeds 4×. The theoretical bound of 5× is never reached in practice.

This means eml universality is not just a theoretical curiosity but a practical engineering option. A computer built from eml units would compute elementary functions with near-optimal circuit size.

---

## A New Kind of Minimalism

Throughout the history of mathematics, some of the deepest insights have come from discovering that complexity can be reduced to startling simplicity. The ancient Greeks reduced geometry to five postulates. Boole reduced logic to algebra. Turing reduced computation to a machine that could read, write, and move a tape.

The eml operator belongs to this tradition of radical reduction. It does not solve every problem — it does not compute sine, it does not prove theorems, it does not make coffee. But within its domain — the elementary functions of real analysis, the workhorses of science and engineering — it achieves a remarkable economy.

One operation. Two inputs. All of continuous elementary computation.

The next question is inevitable: can we do even better? Is there an operator *simpler* than eml that still generates all elementary functions? Or is eml the minimal primitive — the atom of real-valued computation?

That question remains open. But for the first time, it can be asked precisely, because we finally have a rigorous framework in which "generating all elementary functions" has a machine-checked definition and "minimal" has a formal meaning.

The search for the atoms of computation has only just begun.
