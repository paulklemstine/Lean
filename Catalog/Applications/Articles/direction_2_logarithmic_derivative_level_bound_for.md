# Why Taking Logarithms Doesn't Make Math Harder

## The Hidden Symmetry Behind a Century of Physics

In 1926, physicists Gregor Wentzel, Hendrik Kramers, and Léon Brillouin independently discovered a trick that would become one of the most powerful tools in quantum mechanics. Their idea was breathtakingly simple: instead of solving the Schrödinger equation directly for a particle's wave function ψ, write ψ = exp(S) and solve for S instead. By taking the logarithm first, the problem transforms from a desperately difficult second-order equation into something far more tractable.

This technique — now called the WKB approximation — works so well that it underpins everything from semiconductor physics to quantum tunneling calculations. Engineers at Intel use it to design transistors. Astrophysicists use it to model neutron stars. It appears in at least a dozen subfields of physics and applied mathematics.

But here's what nobody could explain until now: *why* does it work?

Not mechanically — physicists understood the algebra. The deeper question was: why doesn't taking the logarithm make things *worse*? After all, applying a transcendental function to a transcendental function should, by any reasonable measure, increase mathematical complexity. Yet the WKB trick consistently simplifies problems. There seemed to be a hidden conservation law at work, but no one had proved it existed.

Now, a new mathematical result has finally identified this law — and the answer turns out to be surprisingly elegant.

## The Complexity Ladder

To understand the discovery, imagine mathematical functions arranged on a ladder. At the bottom rung sit polynomials: expressions like x² + 3x + 7. These are the simplest transcendental-free functions, built from just addition and multiplication.

One rung up, you find functions like exp(x) and exp(x² + 1) — polynomials wrapped in a single layer of exponentiation. These grow much faster than any polynomial, but they're still relatively tame.

Two rungs up live functions like exp(exp(x)) — exponentials of exponentials. Three rungs up: exp(exp(exp(x))). And so on, forever upward, each rung containing functions that grow incomprehensibly faster than the rung below.

This ladder has a name: the **Hardy hierarchy**, after the great British mathematician G.H. Hardy, who first studied it in the early twentieth century. The rung number — 0 for polynomials, 1 for single exponentials, 2 for double exponentials — is called the **depth** of the function. It measures, in a precise sense, how transcendentally complex a function is.

The Hardy hierarchy isn't just an abstract curiosity. It's the natural classification system for the functions that appear in asymptotic analysis — the branch of mathematics concerned with how things behave "at infinity." Virtually every function encountered in physics, engineering, or computer science sits somewhere on this ladder.

## The Derivative Question

Here's where things get interesting. Calculus tells us how to differentiate any function on this ladder. The derivative of x² is 2x. The derivative of exp(x) is exp(x). The derivative of exp(exp(x)) is exp(x) · exp(exp(x)).

But what happens to the *rung number* when you differentiate?

Look at that last example. The function exp(exp(x)) sits at depth 2. Its derivative, exp(x) · exp(exp(x)), involves a product of a depth-1 function and a depth-2 function. What depth is the product? Is it still at depth 2, or has it climbed to depth 3?

This question turns out to have a definitive answer, and it's the answer that explains why the WKB approximation works.

## Differentiation Is Free

The new theorem proves that **differentiation never increases depth**. If you start with a function at depth d on the Hardy ladder, its derivative sits at depth d or below — never higher.

This might sound obvious, but it isn't. Consider the product rule from calculus: the derivative of f·g is f'·g + f·g'. This creates a *sum of products*, and there's no obvious reason why the sum shouldn't be more complex than either term alone. The proof requires carefully tracking how each operation — addition, multiplication, exponentiation — interacts with the depth measure, and showing that the cancellations always work out.

The proof proceeds by a technique called structural induction: verifying the claim for the simplest functions (constants and the variable x), then showing that if it holds for any two functions f and g, it also holds for f + g, f · g, and exp(f). The exponential case is the crucial one: the derivative of exp(f) is f' · exp(f), and since f' has depth ≤ depth(f) by the inductive hypothesis, the product has depth ≤ max(depth(f), depth(f) + 1) = depth(f) + 1, which equals depth(exp(f)). The bound is tight.

## The WKB Connection

Now we can see why the WKB trick works. When a physicist writes ψ = exp(S) and substitutes into a differential equation, they're computing the **logarithmic derivative** of ψ: the quantity ψ'/ψ, which equals S'.

The depth stability theorem tells us that S' has depth ≤ depth(S). Since ψ = exp(S) has depth = depth(S) + 1, the logarithmic derivative S' = ψ'/ψ has depth *strictly less* than ψ itself. Taking the logarithm doesn't just preserve complexity — it actually *reduces* it by one level.

This is the hidden conservation law. The WKB approximation works because it moves the problem down one rung on the Hardy ladder. You're not just rearranging the algebra; you're genuinely simplifying the mathematical structure.

The same principle extends to higher logarithmic derivatives. The second logarithmic derivative — the quantity S'' + (S')², which arises in the Riccati equation associated with WKB — also stays within depth(S). You can differentiate the logarithmic derivative as many times as you like, and you'll never climb above the original depth. The complexity is permanently tamed.

## Tropical Echoes

One of the most unexpected aspects of this result is its connection to tropical geometry, a relatively new branch of mathematics that replaces ordinary arithmetic with "tropical" arithmetic: addition becomes maximum, and multiplication becomes addition.

When you "tropicalize" a function — essentially taking its logarithm and working in the tropical world — the depth structure is perfectly preserved. A depth-3 function becomes a depth-3 tropical expression. And the depth stability theorem has an exact tropical counterpart: tropical differentiation (the appropriate analog) also preserves depth.

This isn't a coincidence. Tropical geometry is the mathematical language of optimization and valuations, and the logarithm is the bridge between the "classical" world and the "tropical" world. The depth stability theorem tells us that this bridge preserves the fundamental complexity measure. The classical and tropical worlds are, in a precise sense, equally complex.

This connection suggests that depth stability may be a universal mathematical phenomenon, not just a property of one particular algebraic system. When different branches of mathematics independently exhibit the same structural law, mathematicians take notice — it usually means there's a deeper truth waiting to be uncovered.

## A Democracy of Complexity

There's a beautiful consequence for the study of Pythagorean triples — those ancient number-theoretic objects satisfying a² + b² = c². When you lift a Pythagorean parameterization into the exponential domain via exp, every resulting function lands at exactly depth 1, regardless of how complicated the polynomial parameterization is. Depth stability then guarantees that differentiating these exponential-Pythagorean functions keeps them at depth 1.

This "depth democracy" — the fact that all polynomial-level information collapses to a single depth upon exponentiation — is a small but vivid illustration of why the Hardy hierarchy is such a natural classification system. The hierarchy cares only about the tower of exponentials, not the algebraic details within each level.

## The Riccati Connection

The mathematical implications extend beyond WKB to the theory of Riccati equations, a family of nonlinear differential equations that have fascinated mathematicians since the eighteenth century. The Riccati equation z' + z² = q(x) arises when you substitute z = y'/y into the linear equation y'' = q(x)y.

The depth stability theorem shows that if the coefficient q(x) has depth d, then the solution z has depth at most d as well. The nonlinearity of the Riccati equation — the z² term — does not increase depth. This is remarkable because nonlinear equations are generally much harder than linear ones, yet the Hardy complexity measure treats them equally.

This result provides a rigorous foundation for what practitioners of asymptotic analysis have long known intuitively: the Riccati substitution is a "free" operation in terms of transcendental complexity. It transforms equations without moving them up the Hardy ladder.

## Looking Forward

The depth stability theorem opens several fascinating questions. Does the same property hold for more general expression algebras that include logarithms and subtraction, not just the positive fragment? Are there analogs in other mathematical settings — p-adic analysis, for instance, or the theory of o-minimal structures?

Most intriguingly, the theorem suggests a classification program for differential equations based on the Hardy hierarchy. Which equations have solutions at depth d? Can we always reduce a depth-d equation to a depth-(d-1) equation via logarithmic substitution? If so, this would give a systematic "descent" procedure for solving differential equations, peeling off one layer of transcendental complexity at a time until reaching the polynomial level.

Hardy himself might have appreciated this line of inquiry. He was famously devoted to "pure" mathematics — mathematics pursued for its own beauty, without concern for applications. Yet the very hierarchy he introduced turns out to be the key to understanding one of the most practical tools in mathematical physics.

Mathematics has a way of surprising us like that. The abstract and the applied are never as far apart as they seem. A ladder built to classify functions by their growth rates turns out to explain why quantum mechanics is computable. A theorem about symbolic differentiation turns out to illuminate the structure of tropical geometry. And a question about complexity — does taking logarithms make things harder? — turns out to have an answer that is both definitive and beautiful: no, it doesn't. Not ever. Not even a little.
