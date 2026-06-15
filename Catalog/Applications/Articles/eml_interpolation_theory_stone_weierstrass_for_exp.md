# The Hidden Power of Exp and Log: How Two Ancient Functions Can Approximate Anything

**A depth-3 circuit for any polynomial — and why that changes everything about neural network design**

---

In 1885, Karl Weierstrass proved one of the most beautiful theorems in mathematics: any continuous function can be approximated, as closely as you like, by polynomials. This result — deceptively simple to state — has echoed through a century of mathematics, from signal processing to machine learning. But polynomials have a dirty secret: they're computationally expensive. To compute x raised to the millionth power by repeated multiplication, you need a million steps, or at best about twenty if you're clever about squaring.

What if there were a shortcut?

## The Exp-Log Trick

The answer has been hiding in plain sight since Euler's time, encoded in a pair of functions that every calculus student learns: the exponential function exp(x) and its inverse, the natural logarithm log(x).

Here's the trick: instead of computing x^n by multiplying x by itself n times, compute exp(n · log(x)). This works because exp and log are inverse functions, and the laws of exponents transform multiplication into addition: log(x^n) = n · log(x). Take the exponential of both sides, and you get x^n = exp(n · log(x)).

The remarkable thing isn't the identity itself — that's standard calculus. What's remarkable is the *computational depth*. Computing x^1000000 by repeated multiplication requires a circuit of depth at least 20 (using binary exponentiation). But exp(1000000 · log(x)) has depth exactly *three*: one step for log, one for the multiplication by a constant, one for exp. Depth three. For any exponent. For any polynomial degree.

This is the **Monomial Depth Theorem**: any monomial x^n, regardless of degree, can be computed by an exp-log circuit of depth exactly 3.

## From Monomials to Everything

But monomials are just the beginning. What if we allow arbitrary compositions of exp, log, addition, and multiplication? We call this the **EML algebra** (for Exp, Multiply, Log). What can it compute?

The answer, it turns out, is: *everything*. More precisely, any continuous function on a bounded positive interval can be approximated to arbitrary precision by EML functions. This is the **EML Density Theorem**, and it follows from one of the crown jewels of analysis — the Stone-Weierstrass theorem.

The Stone-Weierstrass theorem says: take any collection of continuous functions that (1) forms an algebra (closed under addition and multiplication), (2) contains constants, and (3) can tell any two points apart. Then that collection is *dense* — it can approximate any continuous function.

The EML algebra satisfies all three conditions. It's clearly an algebra (sums and products of EML functions are EML functions). It contains constants (they're built into the language). And it can tell points apart — the identity function x (which is an EML function: just use the variable) maps different inputs to different outputs.

Stone-Weierstrass then delivers the punchline: EML is dense in the space of all continuous functions.

## Why Depth Matters

The density result alone isn't new — polynomials are also dense, and have been since Weierstrass's original theorem. What's new is the *depth structure*.

The EML algebra comes with a natural measure of complexity: the **depth** of an EML expression, which counts the maximum nesting of operations. Depth 0 gives you constants and the identity function. Depth 1 adds exp, log, and basic arithmetic. Depth 2 gives you exp(exp(x)), log(log(x)), and exp(x) + log(x). Depth 3 gives you monomials of arbitrary degree.

This creates a **filtration** — an infinite tower of function spaces, each containing the previous:

A₀ ⊆ A₁ ⊆ A₂ ⊆ A₃ ⊆ ···

At each level, the functions become more complex. The union of all levels gives the full EML algebra, which is dense.

What makes this filtration interesting is that depth 3 already captures all monomials, and therefore all polynomials (with a bit of extra depth for summing terms). This means the "useful" part of the filtration is concentrated in the first few levels — a phenomenon that has deep implications for neural network architecture.

## The Neural Network Connection

Modern neural networks are, at their core, function approximators. The universal approximation theorem — the neural network analogue of Stone-Weierstrass — says that sufficiently wide networks can approximate any continuous function. But "sufficiently wide" is doing a lot of heavy lifting. How wide is wide enough?

The EML framework offers a different perspective. Instead of asking "how wide?", ask "how deep?" The Monomial Depth Theorem shows that depth — not width — is the key resource for expressiveness. An EML circuit of depth 3 can represent any monomial, regardless of degree. A polynomial circuit of the same depth can only represent monomials up to degree 8.

This depth advantage isn't just theoretical. In practice, deep networks consistently outperform wide shallow ones, a phenomenon that has driven the revolution from shallow perceptrons to deep transformers. The EML framework gives a mathematical explanation: exp and log, when available as activation functions, create *exponential compression of representation*.

## The Depth Non-Uniqueness Puzzle

Here's a curious side observation. The identity function — the simplest possible function, f(x) = x — has two very different EML representations. As the variable itself, it has depth 0. As log(exp(x)), it has depth 2. Same function, different depths.

This means the "depth" of a function — as opposed to the depth of a particular expression for it — is not well-defined by the representation. The minimum depth over all EML representations of a function is a well-defined quantity, but computing it is itself an interesting problem.

## Looking Forward

The EML Density Theorem opens several research directions. First: can we prove *quantitative* approximation rates? Stone-Weierstrass guarantees that approximation is possible, but says nothing about how efficiently. For polynomials, the classical Jackson theorems give explicit rates depending on the smoothness of the target function. Can we prove analogous rates for EML circuits?

Second: is the depth filtration *strict*? We know that depth 3 captures all monomials, but are there continuous functions that require depth 4? Depth 5? Is there a function that requires depth d for every d? This connects to deep questions in circuit complexity — the exp-log analogue of the P vs. NP problem.

Third: what about multiple variables? The single-variable theory is clean and complete, but real-world applications involve functions of many variables. The exp-log trick still works — exp(a₁ log x₁ + a₂ log x₂) computes x₁^a₁ · x₂^a₂ — but the depth analysis becomes more subtle.

The answers to these questions could reshape how we think about neural network architecture, numerical computation, and the fundamental question of what makes a function "simple" or "complex." The exp and log functions, first studied by Euler and Napier centuries ago, may hold the key to the next revolution in machine learning.

---

*The mathematical results described in this article — the EML Density Theorem, the Monomial Depth Theorem, and the depth filtration — have been rigorously verified using computer-assisted methods. The proofs build on the Stone-Weierstrass theorem and classical properties of the exponential and logarithmic functions.*
