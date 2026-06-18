# Backprop as Cotangent Lift: When Neural Nets Meet the Future

## LEDE

In 1986, David Rumelhart, Geoffrey Hinton, and Ronald Williams published a paper that would reshape the world. Their method — backpropagation — showed how to train neural networks by propagating errors backward through layers of computation. Four decades later, backprop powers everything from the language models writing poetry to the vision systems guiding autonomous cars. It is arguably the most consequential algorithm of the 21st century.

But here is a secret that most practitioners never learn: backpropagation was not invented. It was *discovered*. The algorithm is not an engineering trick — it is a theorem of differential geometry, hiding in plain sight since the 19th century. The backward traversal that gives backprop its name is not a design choice that some clever programmer made. It is a mathematical inevitability, forced by the deep structure of how smooth spaces relate to each other.

A new formal proof, verified by machine in the Lean theorem prover, makes this precise: backpropagation is the *cotangent lift* of the forward map. To understand what that means — and why it matters — we need to take a journey through the geometry of curved spaces.

## THE MATHEMATICAL HEART

Imagine you are standing on a hillside. The slope beneath your feet tells you which way is downhill — it is a *gradient*, a tiny arrow pointing in the direction of steepest descent. If you were an ant crawling on a curved surface, you could feel the slope at every point, and by following it, you would eventually reach the bottom of the valley.

Now imagine the hillside is not a literal mountain but the "landscape" of a neural network's errors. Each point in this landscape represents a particular setting of the network's millions of parameters, and the height at that point is the network's error on its training data. Training the network means finding the bottom of the valley — the parameter settings that minimize error.

To get there, you need to know the slope. That is what backpropagation computes.

But here is where geometry enters. A neural network is a *composition* of layers — data flows forward through layer after layer, each one transforming it. Think of it as a chain of tunnels: the input enters tunnel one, emerges transformed, enters tunnel two, and so on until the final output appears.

Computing the slope (gradient) of this entire chain requires the *chain rule* of calculus. And the chain rule has a beautiful geometric interpretation. At each point of a smooth curved space — a "manifold" — there is a tiny flat patch called the *tangent space*, which captures all the directions you could move. The dual of this tangent space, called the *cotangent space*, captures all the ways you could *measure* movement — slopes, rates, prices. The collection of all cotangent spaces across the entire surface forms the *cotangent bundle*.

When a smooth map sends one surface to another — like a single neural network layer transforming data — it naturally pulls back measurements from the output surface to the input surface. This pullback is called the *cotangent lift*. And here is the crucial fact: the cotangent lift *reverses the direction of maps*. If the forward pass goes from input to output, the cotangent lift goes from output to input.

Mathematicians call this *contravariance*. The cotangent bundle is a *contravariant functor* — a gadget that systematically reverses arrows. When you compose two forward maps (layer one, then layer two), their cotangent lifts compose in the opposite order (layer two's lift, then layer one's lift).

This is backpropagation. The backward traversal — the "back" in "backprop" — is not an algorithmic choice. It is the contravariance of the cotangent functor, as inescapable as the fact that putting on socks then shoes means taking off shoes then socks.

## WHY IT MATTERS

This is more than an aesthetic observation. Recognizing backprop as a cotangent lift has practical consequences that are reshaping the frontier of AI research.

**Geometric deep learning.** Modern neural networks increasingly operate on curved spaces — proteins folding on the surface of spheres, molecules rotating in three-dimensional space, robots navigating non-Euclidean environments. The cotangent perspective tells us exactly how to generalize backpropagation to these settings: compute the cotangent lift with respect to the manifold's geometry. Research groups at DeepMind and elsewhere are already building networks on Lie groups and hyperbolic spaces using precisely this principle.

**Correct by construction.** By formalizing the theorem in a proof assistant — a program that mechanically checks every logical step — we obtain an ironclad guarantee that the gradient computation is correct. As AI systems are deployed in safety-critical applications like medical diagnosis and autonomous driving, machine-verified correctness of the training algorithm itself becomes not a luxury but a necessity.

**Connections to physics.** The cotangent bundle is not just a mathematical abstraction — it is the *phase space* of classical mechanics, the arena where Hamiltonian dynamics unfolds. The identification of backprop with cotangent lifts connects neural network training to optimal control theory, symplectic geometry, and even quantum mechanics. Some researchers speculate that this connection could lead to fundamentally new training algorithms inspired by physical dynamics.

## THE BEAUTY

What makes this result beautiful is its inevitability. Backpropagation was developed independently by multiple researchers in different decades and different fields — control theory in the 1960s, neural networks in the 1980s, automatic differentiation in applied mathematics. Each time, the algorithm was "discovered" as if it were a natural law. The cotangent lift perspective explains why: there is essentially only one way to compute gradients of compositions, and it is dictated by the structure of smooth geometry itself.

There is also a profound symmetry at work. The forward pass and backward pass are not separate algorithms — they are two faces of the same geometric object, the cotangent bundle. The forward pass lives in the tangent direction (how small changes in input produce changes in output), while the backward pass lives in the cotangent direction (how sensitivities to output propagate back to sensitivities to input). They are dual to each other in the precise mathematical sense, like a vector and a linear functional, like a force and a displacement.

This duality is what category theorists call a *functor between opposite categories*. It is the same pattern that appears when you transpose a matrix, take the dual of a vector space, or reverse the edges of a graph. Backpropagation is one instance of a universal mathematical motif.

## LOOKING AHEAD

The formalization opens several doors.

First, it provides a foundation for *verified AI*. As proof assistants become more powerful, we can envision a future where not just the training algorithm but the entire machine learning pipeline — data preprocessing, model architecture, optimization, and deployment — is formally verified. The gap between "we think this works" and "we have proved this works" is exactly the gap that formal methods aim to close.

Second, the cotangent perspective suggests new algorithms. If backpropagation is the first-order cotangent lift, what is the second-order version? The mathematical answer involves *jet bundles* — higher-order generalizations of the cotangent bundle. These could yield new optimization methods that capture curvature information more efficiently than current second-order methods like L-BFGS or natural gradient descent.

Third, there is a tantalizing connection to tropical geometry. The ReLU activation function, which computes max(0, x), is a tropical polynomial. Tropical geometry — the geometry of the "max-plus" semiring — could provide entirely new tools for analyzing deep networks, replacing smooth differential geometry with combinatorial geometry. The cotangent lift theorem suggests that there should be a "tropical cotangent lift" governing backpropagation through ReLU networks, and finding it is an open problem.

## CLOSING

Mathematics has a way of revealing that things we thought were human inventions are actually features of reality. The Pythagorean theorem was not created by Pythagoras — it was waiting for him, embedded in the structure of space. The fundamental theorem of calculus was not designed by Newton and Leibniz — it was implicit in the nature of change and accumulation.

Backpropagation, it turns out, belongs in the same category. It is not a human invention but a mathematical inevitability — the unique consequence of how smooth spaces transform under composition. When Rumelhart, Hinton, and Williams wrote their 1986 paper, they were not inventing an algorithm. They were rediscovering a theorem that the cotangent bundle had known all along.

In the formal proof verified by machine, we see this truth crystallized into its purest form: a handful of symbols, mechanically checked, capturing the geometric soul of the algorithm that is reshaping our world. It is a small theorem with large implications — a reminder that the deepest truths in applied mathematics often turn out to be the simplest truths in pure mathematics, patiently waiting to be recognized.
