# The Hidden Algebra of Approximation: How Mathematics Reveals the Limits of Computation

*What if every function you could ever want to compute was hiding inside a precise mathematical hierarchy — and the key to finding it was knowing exactly which shelf to look on?*

---

In the world of mathematics, there is a theorem so beautiful it deserves to be better known. It says, roughly: *any continuous function can be approximated as closely as you like by polynomials*. Karl Weierstrass proved this in 1885, and it remains one of the cornerstones of analysis. But it leaves a tantalizing question unanswered: how *complex* does the approximating expression need to be?

This is not an idle question. It sits at the heart of modern artificial intelligence, where "approximating a function" is precisely what neural networks do. When a language model predicts the next word, or an image classifier distinguishes cats from dogs, or a climate model projects future temperatures, the underlying mathematics is always the same: find a computable expression that is close enough to the true function.

## The Library of Functions

Imagine organizing all possible mathematical functions into a vast library, like Jorge Luis Borges's Library of Babel, but with perfect order. Each shelf is labeled with three numbers: a *depth*, a *size*, and a *tolerance*.

The **depth** measures how many times you need to nest exponentials and logarithms. A polynomial — no matter how complicated — sits at depth zero. The function e^x sits at depth one. The function e^(e^x) sits at depth two. Each additional layer of exponentiation pushes you one shelf deeper into the library.

The **size** measures the total amount of computation: how many additions, multiplications, and exponentiations you need. A degree-100 polynomial might have a large size but still sit at depth zero.

The **tolerance** measures how precise the approximation needs to be. At tolerance ε = 1, you only need to be within one unit. At tolerance ε = 0.001, you need three decimal places of accuracy.

This triple-indexed organization — which we call the **EML Approximation Filtration** — turns out to have remarkable mathematical structure. It is not just a classification scheme; it is an *algebra*.

## An Algebra of Approximation

Here is what makes the filtration special: it respects arithmetic.

If you can approximate function *f* with an expression of depth d₁ and size s₁ to tolerance ε₁, and you can approximate function *g* with depth d₂ and size s₂ to tolerance ε₂, then you can automatically approximate *f + g* with depth max(d₁, d₂) and size s₁ + s₂ + 1 to tolerance ε₁ + ε₂. The tolerances add — which makes intuitive sense, since each approximation introduces its own error — and the depths take the maximum, since you need whatever depth either factor required.

Multiplication is more subtle. When you multiply approximations, the errors don't just add — they interact. If *f* and *g* are both bounded (say |f| ≤ B_f and |g| ≤ B_g), then the product's error is at most ε₁·B_g + ε₂·B_f + ε₁·ε₂. The last term, ε₁·ε₂, is the *cross-error*: the product of the two individual approximation errors. For high-precision work (small ε), this cross-term is negligible. But for coarse approximations, it matters.

These closure properties mean the filtration forms something like a graded ring — an algebraic structure where the "grade" tracks complexity and the operations respect the grading. This is not just bookkeeping. It means you can *compose* approximate computations and predict exactly how much error will accumulate.

## The Depth Hierarchy: Why Some Functions Are Inherently Hard

Not all functions are created equal. A polynomial, no matter how high its degree, can always be represented at depth zero. But the iterated exponential — applying e^x to itself n times — requires depth exactly n.

This creates a strict *hierarchy*: the depth-0 functions (polynomials) are a proper subset of the depth-1 functions (which include e^x and its algebraic combinations), which are a proper subset of the depth-2 functions, and so on forever. Each level genuinely contains functions that cannot be represented at any lower level.

This hierarchy has a physical interpretation. In a neural network, each layer of the network corresponds roughly to one level of the depth hierarchy. A single-layer network can only compute polynomials (in a suitable sense). Adding a second layer gives access to exponentials. Adding a third gives access to double exponentials. The *depth* of the network determines the *class* of functions it can represent — and no amount of width (more neurons per layer) can compensate for insufficient depth.

## The Composition Principle: How Errors Propagate

Perhaps the most practically important result is the **composition contraction principle**. When you compose two approximate computations — feeding the output of one into the input of another — the errors don't add; they multiply by the *Lipschitz constant* of the outer function.

Concretely: if the outer function is L-Lipschitz (meaning it stretches distances by at most a factor of L), and the inner approximation has error ε₂, then the composed approximation has error at most ε₁ + L·ε₂, where ε₁ is the outer approximation error.

For the exponential function, the Lipschitz constant on [0, M] is e^M — which grows extremely fast. This explains, at a fundamental level, why deep networks are hard to train: each layer amplifies the errors from the layers below by an exponential factor. The mathematics doesn't just *predict* this phenomenon; it *requires* it.

## Information Decay: The Bottleneck Principle

There is another way to see the limits of deep computation. Imagine that each layer of an EML expression can only "retain" a fraction α of the information from the previous layer. After l layers, the retained information is α^l times the original — exponential decay.

This is a formalization of the *information bottleneck* principle from deep learning theory. It says that deep architectures inevitably lose information about their inputs, and the rate of loss is exponential in the depth. To maintain a certain level of approximation accuracy, you need either:
- Enough initial information (a large expression at the bottom)
- Few enough layers (shallow depth)
- A contraction factor α close to 1 (layers that don't lose much information)

## What This Means for AI

The EML Approximation Filtration is not just a mathematical curiosity. It provides a precise language for talking about the *complexity* of function approximation — the central task of machine learning.

When a neural network architect chooses between a deep, narrow network and a shallow, wide one, they are implicitly navigating the filtration. Deep networks access higher levels of the depth hierarchy, gaining the ability to represent more complex functions. But they pay a price in error amplification and information loss. Wide networks stay at lower depth levels but can represent more functions within those levels.

The filtration makes this tradeoff precise. It tells you that the depth × size product is a complexity invariant — a quantity that measures the total computational work independently of how it is distributed between depth and width. For the iterated exponential of order n, this product is n(n+1), and no clever rearrangement of the computation can reduce it.

## The Road Ahead

Several deep questions remain open. Can we prove that the iterated exponential *requires* depth n — not just that the natural construction uses depth n? What is the precise relationship between EML description complexity and Kolmogorov complexity? Can the filtration be extended to handle functions of multiple variables, or to stochastic approximation?

These questions connect to some of the deepest problems in mathematics and computer science. They touch on the nature of computation itself: what it means to "approximate" a function, how complexity grows with accuracy, and why some functions are intrinsically harder to compute than others.

The EML Approximation Filtration provides the mathematical framework to ask these questions precisely — and, perhaps, to answer them.

---

*The author thanks the Harmonic research team for computational support.*
