# The Hidden Algebra of Neural Networks: How exp and log Build Universal Approximators

*A new mathematical framework reveals that networks built from just exponentiation and logarithm can approximate any continuous function — with explicit guarantees on how large the network needs to be.*

---

## The Universal Language of Functions

In the early 1900s, Karl Weierstrass proved one of the most beautiful results in mathematics: any continuous function on a closed interval can be approximated arbitrarily well by polynomials. This theorem, later generalized by Marshall Stone, became a cornerstone of approximation theory — the mathematical study of how simple functions can stand in for complex ones.

A century later, a parallel revolution was unfolding in computer science. Neural networks — computational architectures inspired by biological brains — were being shown to approximate any continuous function, given enough neurons. This "universal approximation theorem" of the late 1980s launched an era of deep learning that has transformed everything from image recognition to drug discovery.

But there was always a gap between the two worlds. The classical approximation theorems gave *explicit rates*: if your target function is smooth enough, you know exactly how many polynomial terms you need. The neural network theorems, by contrast, were purely existential: they said an approximation *exists*, but said nothing about how large the network must be.

This article describes a new mathematical framework that bridges that gap — by studying networks built from just two operations that are as old as mathematics itself.

## The EML Algebra: Simplicity from Complexity

The framework centers on what mathematicians call the **EML algebra** — networks constructed from three primitive operations: **E**xponentiation (exp), **M**ultiplication (×), and the identity function. These are combined through addition to create increasingly complex functions.

At first glance, this seems absurdly restrictive. Modern neural networks use sophisticated activation functions, batch normalization, attention mechanisms, and residual connections. How could plain old exp and multiply compete?

The answer lies in a deep algebraic insight. When you combine exp and multiply with addition, you don't just get a grab-bag of functions — you get a *subalgebra* of the space of all continuous functions. This means the set is closed under the operations that matter: you can add two EML functions and get another EML function. You can multiply them and stay in the family. You can scale them by constants.

And crucially, this algebra has a property that mathematicians call *point separation*: given any two distinct inputs, there exists an EML function that produces different outputs for them. This is the key that unlocks Stone's generalization of Weierstrass's theorem.

## The Density Theorem

The main result can be stated simply: **on any compact subset of the real line, EML functions are dense in the space of continuous functions.** In plain language: pick any continuous function you want to approximate, pick any accuracy target, and there exists an EML network that meets it.

But this goes further than the standard neural network universality results in a crucial way. Because EML networks have a natural notion of *complexity* — measured by their width (number of leaf nodes) and depth (nesting level of operations) — we can study how these resources trade off against approximation quality.

The key structural insight is that width and depth play fundamentally different roles:

- **Width** provides parallelism: adding more terms lets you sum up more component functions.
- **Depth** provides composition: nesting exp inside exp creates functions that grow at rates no polynomial can match.

This asymmetry has profound consequences.

## The Depth Hierarchy

Consider the iterated exponential: exp(exp(x)). This function grows so fast that no polynomial, no matter how high its degree, can keep up. And it turns out this isn't just a quirk — it's a fundamental structural feature.

The new framework establishes a strict **depth hierarchy**: for each depth level k, there exist functions that can be computed at depth k+1 with just a single unit of width, but require increasing resources at depth k. The witness is the k-fold iterated exponential exp(exp(...exp(x)...)), which has depth k and width 1.

The growth rate theorem makes this precise: the (k+1)-fold exponential eventually exceeds any constant multiple of the k-fold exponential. This means that each additional layer of depth doesn't just help — it unlocks an entirely new regime of expressiveness.

## Quantitative Bounds: The Mean Value Connection

Beyond the existential density theorem, the framework provides quantitative separation bounds. The key tool is an inequality rooted in the mean value theorem:

**For any two distinct reals x and y:**
|exp(x) - exp(y)| ≥ |x - y| × exp(min(x, y))

This says that the exponential function doesn't just separate points — it separates them by an amount that depends explicitly on how far apart the points are and where they sit on the real line. This is the engine that drives the quantitative approximation theory.

For functions that satisfy a Lipschitz condition (meaning they don't change too quickly), this inequality chains through the network structure to give explicit bounds on how wide and deep an EML network needs to be to achieve a given approximation accuracy.

## A Classification of Simple Networks

At the simplest level — depth 1 and width 1 — the framework completely characterizes what EML networks can compute. Such a network can only represent four types of functions:

1. A constant function (f(x) = c)
2. The identity function (f(x) = x)
3. The exponential function (f(x) = exp(x))
4. A constant exponential (f(x) = exp(c))

This classification is tight: any depth-1, width-1 EML network computes exactly one of these. The proof works by structural induction on the term algebra, eliminating addition and multiplication (which require width ≥ 2) and nested operations (which require depth ≥ 2).

This classification illustrates why depth matters: at depth 2, width 1 already gives you exp(exp(x)), a function qualitatively different from anything at depth 1. Each increment in depth opens a new world.

## From Theory to Practice

The implications for practical machine learning are significant. Current neural network architectures typically use activation functions like ReLU (rectified linear units) or sigmoid functions. The EML framework suggests that exponential activations might deserve more attention — not because they are computationally convenient, but because they come with mathematical guarantees that other activations lack.

The explicit width-depth tradeoff provides something that practitioners have long sought: a principled way to decide network architecture. Instead of trial and error, the EML complexity measures offer a theoretical compass. Need to approximate a function that oscillates at multiple scales? The theory predicts you'll need depth proportional to the number of scales, but width can stay moderate.

Perhaps most intriguingly, the framework connects neural network approximation to classical analysis in a way that opens new research directions. The subalgebra structure of EML networks means that tools from abstract algebra — ring theory, ideal theory, representation theory — become available for studying neural network expressiveness.

## The Bigger Picture

The density of EML networks in the space of continuous functions is not just a technical result. It tells us something profound about the relationship between simple operations and complex behavior. Just as the real numbers can be built from rational numbers by taking limits, any continuous function can be built from exponentials and polynomials by taking limits.

This perspective invites a rethinking of what neural networks fundamentally *are*. They are not just flexible function approximators — they are algebraic objects with rich internal structure. Understanding that structure is the key to understanding their power, their limitations, and their potential.

The depth hierarchy result, in particular, suggests that the revolution in deep learning isn't just about having more parameters — it's about having more *levels of composition*. Each layer of depth doesn't just add more of the same; it qualitatively expands the class of functions that can be efficiently represented.

As mathematicians continue to map the frontier between what simple networks can and cannot compute, the EML framework provides a laboratory where these questions can be asked precisely and answered rigorously. The algebra of exp, log, and multiply may be ancient, but the mathematics it generates is thoroughly modern — and full of surprises.

---

*The research described here establishes a formal connection between classical approximation theory (Stone-Weierstrass) and neural network expressiveness, proving density theorems with explicit complexity bounds for networks built from exponential and polynomial operations.*
