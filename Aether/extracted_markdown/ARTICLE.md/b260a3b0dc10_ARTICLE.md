# The Unreasonable Expressiveness of Exp-Log Networks

## How Two Elementary Functions Can Approximate Anything

Imagine you had just two tools: a lever and a fulcrum. Archimedes supposedly claimed that with these alone, he could move the Earth. In mathematics, the exponential and logarithm functions play a similar role. A new line of research shows that networks built from nothing more than `exp`, `log`, addition, and multiplication can approximate *any* continuous function to arbitrary precision — and do so with quantifiable efficiency.

This result, known informally as the Stone-Weierstrass theorem for exp-log networks, reveals that these humble building blocks are far more powerful than they might appear. The key is not any individual function, but the *algebra* they generate: the vast family of expressions you can build by combining them.

## The Algebra of Everything

Consider a single "neuron" of the form:

> f(x) = e^a · log(b·x + c)

where a, b, and c are adjustable parameters. This is a simple function — it takes an input x, applies a linear transformation, takes the logarithm, and scales by an exponential. Nothing exotic. But what happens when you combine many such neurons into a network?

The answer turns out to be: everything.

The mathematical foundation is a 75-year-old theorem due to Marshall Stone and Karl Weierstrass. In its modern form, it says: if you have a collection of continuous functions on a compact space that (1) includes constants, (2) is closed under addition and multiplication, and (3) can distinguish between any two distinct points, then combinations of your functions can approximate *any* continuous function as closely as you want.

The critical property is point separation: given any two distinct points x ≠ y, there must be some function in your collection that assigns different values to them. For exp-log neurons, this is guaranteed by a beautiful chain of reasoning. The logarithm is strictly monotone on positive reals, so log(x) ≠ log(y) whenever x ≠ y. The exponential amplifier exp(a) preserves this distinctness because it's always positive. Together, they create a function that *provably* tells apart any two points you give it.

## Why Not Just Use Polynomials?

If the Stone-Weierstrass theorem applies equally well to polynomials — which it does — why should anyone care about exp-log networks?

Three reasons.

First, **efficiency**. While polynomials can approximate any continuous function, they may need enormous degree to do so. The function |x − 1/2| on the interval [0, 1], for instance, is only Lipschitz continuous, and polynomial approximation converges painfully slowly. Exp-log networks can represent this function much more compactly because the logarithm's curvature naturally captures the kind of "kinks" that polynomials struggle with.

Second, **depth creates exponential savings**. A single exp-log layer grows logarithmically — slowly. But stack two layers deep, and you get log(log(x)), which grows *doubly* logarithmically. To achieve any target value M, a single layer needs input of size e^M, but a depth-2 network needs only e^(e^M). This means deep networks can represent functions with vastly different growth rates, something shallow networks cannot do efficiently. The formal proof of this is surprisingly elegant: the composition log ∘ log ∘ ... converges to constants so slowly that you need tower-exponential inputs to match the output of a shallower network.

Third, **the tropical connection**. There is a deep and unexpected link between exp-log algebra and tropical mathematics — the exotic algebraic system where "addition" means taking the maximum and "multiplication" means ordinary addition. The bridge is the identity:

> exp(max(a, b)) = max(exp(a), exp(b))

This equation says that the exponential function is a *homomorphism* between tropical and classical algebra. This is not just a curiosity. It means that results proved in the tropical world — about piecewise-linear functions, optimization, and combinatorics — transfer directly to the exp-log setting. The density of tropical functions (closed under max, min, and shifts) implies a corresponding density for the exp-log family.

## Measuring the Speed of Convergence

The Stone-Weierstrass theorem is *existential*: it guarantees that good approximations exist, but doesn't say how large the network needs to be. The quantitative question — how many neurons do you need for ε-accuracy? — is where the real engineering value lies.

For Lipschitz functions (those whose rate of change is bounded by some constant K), the answer is elegantly simple. If you want to approximate a K-Lipschitz function within error ε on [0, 1], you need at most ⌈K/ε⌉ + 1 neurons. The proof uses a "mesh" argument: cover the domain with evenly spaced points, match the function at those points, and the Lipschitz condition bounds the error everywhere else at 2Kδ, where δ is the mesh spacing.

A deeper conjecture goes further. For functions in the Hölder class Lip_α — those whose modulus of continuity behaves like |x − y|^α — the conjecture predicts that width O((K/ε)^(1/α)) suffices. This "Jackson-type" rate would mean that smoother functions (larger α) can be approximated with dramatically fewer neurons. The conjecture is falsifiable: numerical experiments with specific functions like √x (which is 1/2-Hölder) should show width scaling as O(1/ε²). If the actual scaling is worse, the conjecture fails.

## The Power Function Trick

One of the most striking features of exp-log networks is their ability to represent power functions exactly:

> exp(n · log(x)) = x^n

This identity, valid for all positive x, means that EML networks contain all monomial functions for free. Since any polynomial is a sum of monomials, and EML networks are closed under addition and scalar multiplication, the entire polynomial algebra sits *inside* the EML algebra. Polynomials are a special case of what exp-log networks can do.

But the converse is spectacularly false. The function exp(x) itself cannot be represented by any polynomial — it grows faster than x^n for every n. Yet it's trivially an EML function (with a = x, b = 0, c = e). This asymmetry — EML strictly contains polynomials — explains why exp-log networks are fundamentally more expressive.

## A New Architecture for Neural Networks?

The practical implications extend beyond pure mathematics. Modern neural networks typically use activation functions like ReLU (the function max(0, x)) or sigmoid (a smoothed step function). These choices are largely historical accidents, driven by computational convenience rather than mathematical optimality.

Exp-log networks offer a principled alternative. Their density property is *proved*, not assumed. Their approximation rates are *quantified*, not estimated. And their connection to tropical geometry opens the door to a rich mathematical theory that could guide architecture design.

The catch? Numerical stability. Computing exp and log requires care: exp grows explosively, and log has a singularity at zero. Any practical implementation must handle these issues. But the mathematical guarantee remains: if you can build it, it will work.

## What Comes Next

The separation property — the ability of a single exp-log neuron to distinguish any two points — is the foundation of everything. From it flows density (via Stone-Weierstrass), which implies universal approximation, which enables learning.

The open frontier is quantitative. How fast, exactly, do exp-log networks converge for different function classes? Is the Jackson-type rate conjecture true, or are there functions that defeat the predicted scaling? Can depth be traded for width with provable guarantees?

These questions sit at the intersection of approximation theory, tropical geometry, and machine learning. The answers could reshape how we think about function representation — not as an engineering problem to be solved by trial and error, but as a mathematical structure to be understood, quantified, and optimized.

The exponential and the logarithm. Two functions. One universe of approximation.
