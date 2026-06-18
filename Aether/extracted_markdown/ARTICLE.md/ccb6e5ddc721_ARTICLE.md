# The Hidden Universe Inside exp and log

## How two ancient functions secretly contain an entire mathematical universe—with products, parameters, and a complexity hierarchy

---

Mathematicians have studied the exponential function and the logarithm for centuries. Euler played with them. Gauss mastered them. Every calculus student meets them. But what happens when you step back and ask a different kind of question—not "what does exp of 3 equal?" but "what is the *universe* of all functions you can build from exp, log, addition, and multiplication?"

The answer turns out to be far richer than anyone expected. This universe—call it the *EML world* (for Exp-Minus-Log)—isn't just a grab bag of formulas. It has deep geometric structure: products, symmetries, a notion of complexity, and even its own version of the fundamental operation of "currying" that computer scientists use to decompose multi-variable functions into families of simpler ones.

## Building a World from Two Operations

The starting point is deceptively simple. Take the real numbers. Allow yourself five operations: add two numbers, multiply two numbers, take the exponential of a number, take the logarithm of a number, and use any constant you like. Now close under composition: anything you can build by plugging these operations into each other is fair game.

What do you get?

First, the obvious: all polynomials, since addition and multiplication suffice for those. But you also get power laws like $x^{2.7}$ (write it as $\exp(2.7 \cdot \log x)$), all exponential growth and decay curves, logarithmic scaling, and—critically—anything you get by *nesting* these operations to arbitrary depth. The function $\exp(\log(x) \cdot \exp(\log(y) + 3))$ is in the club. So is $\log(\exp(x^2) + \exp(y^2))$, the "log-sum-exp" function beloved by machine learning engineers.

This is the EML world: the collection of all functions from $\mathbb{R}^n$ to $\mathbb{R}^m$ that can be expressed as finite compositions of these five operations.

## A Category Is Born

Here is the surprising discovery: the EML world isn't just a *set* of functions. It's a **category**—a mathematical structure with objects, morphisms, and composition laws that obey strict algebraic rules.

The objects are the Euclidean spaces $\mathbb{R}^0, \mathbb{R}^1, \mathbb{R}^2, \ldots$—or rather, the natural numbers that index them. The morphisms from $\mathbb{R}^n$ to $\mathbb{R}^m$ are exactly the EML-computable functions: those built from the five operations above, applied coordinate-by-coordinate to produce $m$ output values from $n$ input values.

The identity morphism on $\mathbb{R}^n$ is just the identity function—trivially EML-computable, since each output coordinate $x_i$ is just reading off the $i$-th input. Composition works because plugging one EML expression into another gives another EML expression. And associativity? That's just associativity of function composition, which is automatic.

So far, perhaps not shocking. The real depth appears when we ask: what *extra* structure does this category have?

## Products: The Geometry of Pairing

The EML category has **finite products**. This is the categorical way of saying: you can always combine two functions side-by-side.

If you have an EML-computable function $f: \mathbb{R}^n \to \mathbb{R}^m$ and another $g: \mathbb{R}^n \to \mathbb{R}^k$, you can form the "paired" function $(f, g): \mathbb{R}^n \to \mathbb{R}^{m+k}$ that outputs $f(x)$ in the first $m$ coordinates and $g(x)$ in the last $k$. This paired function is still EML-computable.

Moreover, you have projections: given $\mathbb{R}^{m+k}$, you can project onto the first $m$ coordinates or the last $k$, and these projections are EML-computable. And the universal property holds: the pairing is the *unique* function that makes both projections work correctly.

The terminal object is $\mathbb{R}^0$—the zero-dimensional space, a single point. Every space has exactly one EML-computable map to a point (the trivial map that discards all information). This is terminality.

This product structure enables a crucial operation: the **diagonal map** $\Delta: \mathbb{R}^n \to \mathbb{R}^{2n}$, which sends $x$ to $(x, x)$. This is how the EML world handles *variable sharing*—when the same input appears in multiple places in a formula, the diagonal duplicates it. The fact that $\Delta$ is EML-computable is what makes the EML world closed under operations that reuse variables.

## The exp-log Retraction: An Almost-Isomorphism

One of the most elegant results concerns the exponential and logarithm themselves, viewed as morphisms in the EML category.

The exponential $\exp: \mathbb{R}^1 \to \mathbb{R}^1$ and logarithm $\log: \mathbb{R}^1 \to \mathbb{R}^1$ are both EML morphisms. Composing them gives:

$$\log \circ \exp = \text{id}$$

This is an exact equality of morphisms in the EML category—not just "they cancel on nice inputs," but a genuine categorical identity. In the other direction, $\exp \circ \log$ equals the identity only on positive reals, making the pair a *retraction* rather than a full isomorphism.

This retraction is the categorical expression of the fact that the positive reals and all of $\mathbb{R}$ are "almost the same" from the EML perspective—connected by a morphism pair that cancels in one direction and partially cancels in the other.

## Currying: Parameters as Inputs

Perhaps the most powerful structural result is the **currying theorem**. Given an EML-computable function $f: \mathbb{R}^{p+n} \to \mathbb{R}^m$ on a combined input space, and any fixed parameter vector $\theta \in \mathbb{R}^p$, the specialized function $x \mapsto f(\theta, x)$ is again EML-computable.

This is the mechanism behind *parameter sharing* in neural networks and statistical models. A single EML-computable family, when specialized to particular parameters, gives a family of EML-computable functions. The EML world is closed under this operation—you never leave the universe by fixing parameters.

In categorical language, this is a shadow of the exponential (internal hom) structure that characterizes Cartesian closed categories. The EML category isn't fully Cartesian closed—the full exponential object $\mathbb{R}^{\mathbb{R}}$ would require *all* EML functions, which can't be indexed by a finite-dimensional space—but it has enough exponential structure for the parameter-sharing applications that matter in practice.

## A Complexity Hierarchy

The final surprise is that the EML world has a natural **complexity hierarchy** measured by *derivation depth*—the nesting depth of the derivation tree that witnesses EML computability.

At depth 0, you have only constants and coordinate projections—the "atomic" functions. At depth 1, you gain a single application of exp, log, addition, or multiplication. Each additional level of depth allows one more layer of nesting.

A fundamental result is that this hierarchy is *strict*: depth 0 is strictly contained in depth 1. The exponential function $\exp(x)$ cannot be expressed at depth 0 (it's neither a constant nor a coordinate projection), but it lives at depth 1. And a remarkable *depth-size inequality* holds: the depth of any derivation is always bounded by its size (the total number of nodes in the derivation tree).

This gives a two-dimensional complexity measure for EML computations: breadth (size) and depth, with depth always dominated by size. Functions with small depth relative to their size are "wide and shallow"—lots of parallel operations. Functions with depth close to size are "tall and thin"—deeply nested chains.

## The Endomorphism Monoid

The EML-computable self-maps of $\mathbb{R}^n$—the endomorphisms—form a monoid under composition. This is the algebraic backbone of iterative EML computation: applying the same transformation repeatedly.

The endomorphism monoid of $\mathbb{R}^1$ contains every univariate EML function composed with itself: $\exp \circ \exp$, $\log \circ \exp \circ \log$, and so on. The monoid of $\mathbb{R}^n$ is correspondingly richer, containing all self-maps of $n$-dimensional space expressible through EML operations.

## Why It Matters

The EML category theorem transforms how we think about a ubiquitous class of mathematical functions. Rather than treating individual formulas involving exp and log as isolated objects, we now have a coherent *universe* with known structural properties: products, terminals, retractions, currying, a complexity hierarchy, and a monoid of dynamics.

This has implications across several domains. In machine learning, it explains why architectures based on exp and log (softmax, log-sum-exp, attention mechanisms) are so compositionally well-behaved: they live in a category with products and currying. In numerical analysis, the depth hierarchy gives a new way to measure and bound the complexity of transcendental computations. In pure mathematics, the EML category provides a concrete, computable subcategory of the category of smooth manifolds that retains enough structure to be interesting.

The broader lesson is one that mathematicians have learned again and again: when you have a collection of objects with operations, look for the category. The categorical structure reveals hidden symmetries, universal properties, and complexity measures that are invisible at the level of individual formulas. In the case of exp and log, the category was hiding in plain sight—waiting for someone to ask the right question.

---

*The results described in this article were formalized and verified using computer-assisted mathematical proof, establishing their correctness with absolute certainty. The full categorical structure—identity laws, associativity, product universality, the retraction theorem, and the depth-size inequality—has been rigorously established.*
