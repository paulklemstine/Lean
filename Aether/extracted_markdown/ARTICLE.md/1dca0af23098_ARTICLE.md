# The Hidden Mathematics of Networks That Think in Exponentials

*How a 19th-century theorem guarantees that a surprisingly simple class of mathematical functions can approximate anything*

---

In 1885, Karl Weierstrass proved something that unsettled many mathematicians: any continuous curve—no matter how wild, jagged, or convoluted—can be approximated as closely as desired by a polynomial. Take any continuous function drawn on a piece of paper, and there exists a polynomial that hugs it so tightly that no measurement could distinguish the two.

This result, now called the Weierstrass approximation theorem, was one of the great surprises of 19th-century mathematics. It meant that the humble polynomial—sums of powers like 3x² + 2x − 7—was, in principle, sufficient to describe any continuous phenomenon. But "in principle" is a far cry from "in practice." Polynomials can be terrible approximators: to capture a sharp corner or a rapid oscillation, you might need a polynomial of degree in the millions. For practical computation, we need something better.

## Enter the Exponential

Nature speaks in exponentials. Radioactive decay, population growth, compound interest, the distribution of energy among molecules—the exponential function exp(x) = eˣ appears everywhere in science. Its inverse, the logarithm log(x), is equally ubiquitous: it measures earthquake magnitudes, sound intensity, and the entropy of information.

What happens when you build a computational network—a small mathematical circuit—out of just these two functions plus basic arithmetic? You get what researchers call an **EML network**: a system that computes using **E**xponentiation, **M**ultiplication, and **L**ogarithms.

The key insight is startlingly elegant. Multiplication—which is normally a separate operation—can be reduced to addition in logarithmic space:

> a × b = exp(log(a) + log(b))

This isn't just a mathematical curiosity. It means that EML networks can naturally represent multiplicative relationships that plague standard computational approaches. Want to compute x⁵? That's exp(5 · log(x)). Want to compute 1/x? That's exp(−log(x)). The exponential and logarithm together form a universal translator between additive and multiplicative worlds.

## A Guarantee, Not Just a Hope

The question that drove this research was deceptively simple: **Can EML networks approximate any continuous function?**

If the answer is yes, it would mean that these exponential-logarithmic circuits are, in principle, as powerful as any computational system for representing continuous phenomena. If no, there would exist functions forever beyond their reach—continuous curves that no arrangement of exp and log could capture.

The answer turns out to be yes, and the proof is surprisingly clean. It relies on a generalization of Weierstrass's 1885 theorem, proved by Marshall Stone in 1937. Stone's version says: if you have a collection of continuous functions that (1) forms an algebra (closed under addition and multiplication), (2) contains constant functions, and (3) can distinguish any two distinct points, then that collection can approximate *any* continuous function.

The argument for EML networks runs as follows. Every polynomial—every expression like 3x² + 2x − 7—is an EML function. (We already know x² = exp(2 · log(x)) for positive x, and the full polynomial case follows by induction.) Polynomials clearly separate points: if x ≠ y, then the polynomial f(t) = t gives f(x) = x ≠ y = f(y). And polynomials include constants. So by Stone's theorem, the polynomial subalgebra (and hence the larger EML algebra) is dense in the space of all continuous functions.

This may sound like a roundabout argument—we prove EML density by going through polynomials. But the detour is the point. It shows that EML networks inherit the universality of polynomials while gaining the computational advantages of exponential representations.

## How Fast Can They Learn?

Knowing that EML networks *can* approximate anything tells us nothing about *how efficiently* they do it. This is the gap between existence and construction—the difference between knowing a solution exists and being able to find it.

Classical approximation theory, dating back to Dunham Jackson's work in 1912, gives precise answers for polynomials. If a function f is "α-smooth" (technically, α-Hölder continuous), then a polynomial of degree n approximates it with error at most C · n^{-α}. The smoother the function, the faster the convergence.

For EML networks, we conjecture an analogous result: an EML network of *width* W should approximate an α-Hölder function with error at most C · W^{-α}. In other words, to achieve error ε, you need a network of width proportional to (1/ε)^{1/α}.

This conjecture has immediate practical implications. For smooth functions (α = 1, Lipschitz continuous), you need width proportional to 1/ε. For rougher functions like √x (α = 1/2), you need width proportional to 1/ε². The conjecture precisely quantifies the price of roughness.

Numerical experiments support this prediction. When we fit EML networks to functions like |x − 1/2| (a tent function, Lipschitz with α = 1) and √x (Hölder with α = 1/2), the error-width relationship follows the predicted power law with remarkable fidelity.

## Why Width Matters

One of the sharper results in this theory concerns networks of width zero. A width-zero EML network is just a constant—it outputs the same value regardless of input. How well can a constant approximate a non-constant function?

The answer: not very well. If a function f takes values f(x) and f(y) that differ by some gap Δ, then *any* constant approximation must have error at least Δ/2 at one of the two points. This is proved by the triangle inequality: if a constant c is within ε of both f(x) and f(y), then |f(x) − f(y)| ≤ 2ε, so ε ≥ Δ/2.

This width lower bound is simple but important. It establishes that network width is a genuine resource—you need at least some neurons to capture non-trivial behavior. Combined with the Jackson rate conjecture, it suggests an intimate connection between function complexity and network complexity.

## The Separation Principle

At the heart of the Stone–Weierstrass theorem lies a beautiful idea: **separation**. Two points are "separated" by a function if the function takes different values at those points. The theorem requires that our function class can separate any pair of distinct points.

For EML networks, separation is almost trivially satisfied. The exponential function exp(x) is strictly increasing: if x < y, then exp(x) < exp(y). This means exp separates every pair of distinct real numbers. Similarly, log is injective on positive reals—it separates every pair of distinct positive numbers.

But the most elementary separator is the identity function f(x) = x itself. It's a polynomial (of degree 1), hence an EML function, and it separates every pair of distinct points. The separation property is not deep—it's almost obvious. What *is* deep is Stone's insight that separation, combined with algebraic closure, guarantees universal approximation.

## The Bigger Picture

EML networks occupy a sweet spot in the landscape of computational architectures. They are:

- **More natural than polynomials**: Exponentials and logarithms appear throughout science, making EML representations physically meaningful.
- **More structured than general neural networks**: The exp-log operations give algebraic identities (like a · b = exp(log a + log b)) that enable exact arithmetic.
- **Provably universal**: The Stone–Weierstrass theorem guarantees they can approximate any continuous function.
- **Quantifiably efficient**: The conjectured Jackson-type rates predict how network size scales with accuracy.

The density theorem established here is a starting point. It says EML networks are universal—but it doesn't say they're *optimal*. Are there functions that EML networks approximate faster than ReLU networks? Slower? Are the conjectured rates tight, or can they be improved?

These questions connect approximation theory—a classical branch of mathematics concerned with how well functions can be represented—to modern machine learning, where computational efficiency determines practical feasibility. The EML framework offers a bridge between these worlds: classical enough for rigorous analysis, modern enough for practical computation.

## A 140-Year Journey

From Weierstrass's 1885 polynomial approximation theorem to Stone's 1937 algebraic generalization to today's EML networks, the story of function approximation is one of progressive abstraction. Each generation asked: what is the *minimal* structure needed to approximate everything?

Weierstrass showed that polynomials suffice. Stone showed that any point-separating algebra suffices. And now, EML theory shows that the humble exponential and logarithm—two of the oldest functions in mathematics—generate an algebra rich enough to approximate any continuous phenomenon.

The exponential function was discovered (or invented) in the 17th century by mathematicians studying compound interest. The logarithm was developed by John Napier in 1614 as a computational tool for simplifying multiplication. Four centuries later, these same functions turn out to be the building blocks of a universal approximation theory—one with precise, conjectured bounds on the cost of accuracy.

Sometimes the most powerful tools are the ones that have been hiding in plain sight.
