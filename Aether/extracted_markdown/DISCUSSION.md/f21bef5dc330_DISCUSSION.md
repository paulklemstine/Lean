# backprop_as_cotangent: When Neural Nets Meet the Future

## LEDE

In 1986, David Rumelhart, Geoffrey Hinton, and Ronald Williams published a paper that would quietly reshape civilization. Their algorithm — backpropagation — showed computers how to learn from their mistakes, propagating error signals backward through a neural network to adjust its parameters. Four decades later, this same algorithm powers the large language models that write poetry, the vision systems that drive cars, and the protein folders that predict the shape of life itself.

But here is the secret that most machine learning engineers never learn: backpropagation is not really an algorithm at all. It is a theorem of differential geometry, hiding in plain sight. The reverse-mode traversal that defines backprop — the reason it works backward through the network — is not a clever engineering trick. It is a mathematical inevitability, forced by the structure of duality in the category of smooth manifolds.

The formal name for this inevitability is *cotangent lift*, and proving it rigorously in a computer-verified proof assistant reveals something profound about the relationship between geometry, computation, and intelligence.

## THE MATHEMATICAL HEART

Imagine you are standing on a curved surface — a hillside, perhaps. At your feet, the ground slopes away in various directions. The collection of all possible "slope measurements" you could make at your location forms what mathematicians call the *cotangent space*. If you imagine collecting all such measurements at every point on the entire hillside, you get the *cotangent bundle* — a mathematical object that encodes all the local gradient information of the surface simultaneously.

Now imagine a smooth path from one hillside to another — a function that maps each point on the first surface to a point on the second. This function "pushes" tangent directions forward (if you're walking northeast, the map tells you which direction you end up walking on the new surface). But something magical happens when you look at gradients instead of directions: they flow *backward*. A gradient measurement on the second surface naturally "pulls back" to a gradient measurement on the first. This pullback is the cotangent lift.

A neural network is nothing more than a chain of such maps: Layer 1 sends data from one space to another, Layer 2 continues the journey, and so on. The forward pass is the composition of these maps. But when we want to compute how the loss changes with respect to early parameters — the very heart of learning — we need gradients. And gradients, living in cotangent spaces, naturally flow in reverse.

This is backpropagation. Not an invention, but a discovery. The algorithm's backward traversal is the contravariant functoriality of the cotangent bundle — a deep structural fact about how duality works in geometry.

## WHY IT MATTERS

Understanding backprop as cotangent lift is not merely an intellectual curiosity. It opens doors that the purely algorithmic perspective cannot.

**Geometric deep learning.** When neural networks operate on curved spaces — molecular surfaces, Lie groups, hyperbolic embeddings — the naive "multiply by the transpose Jacobian" recipe breaks down. But the cotangent lift generalizes seamlessly to any smooth manifold. This geometric perspective enables correct gradient computation on non-Euclidean data, powering advances in drug discovery, robotics, and computer graphics.

**Formal verification of AI.** As artificial intelligence systems take on safety-critical roles — medical diagnosis, autonomous driving, financial trading — we need mathematical guarantees that gradient computations are correct. By formalizing backprop as a theorem of differential geometry in the Lean proof assistant, we can verify these computations with the same rigor applied to bridge engineering or aircraft design. The proof compiles. There is no room for error.

**Tropical connections.** The most common activation function in deep learning, ReLU (Rectified Linear Unit), computes the maximum of zero and its input. This "max" operation is the addition operation in *tropical mathematics* — an exotic algebra where addition is replaced by maximum and multiplication by ordinary addition. This hints at deep connections between neural networks and tropical geometry, algebraic geometry, and combinatorial optimization. The cotangent perspective provides the bridge.

## THE BEAUTY

What makes this result beautiful is its inevitability. Engineers spent years optimizing backpropagation, developing tricks to make it faster, more stable, more memory-efficient. But the core algorithm — the fact that you traverse layers in reverse order — was never a design decision. It was forced by mathematics.

There is a functor, $T^*$, that takes a smooth manifold and returns its cotangent bundle. This functor is *contravariant*: it reverses the direction of maps. When you compose smooth functions $f_1, f_2, f_3$ in forward order, the cotangent lift composes their duals in *reverse* order: $f_1^* \circ f_2^* \circ f_3^*$. This reversal is not optional. It is as fundamental as the fact that putting on socks and then shoes means removing shoes and then socks.

The beauty lies in the universality. Every neural network, regardless of architecture — convolutional, recurrent, transformer, graph neural network — learns by the same geometric principle. The cotangent functor does not care about implementation details. It sees only the smooth structure and acts accordingly.

## LOOKING AHEAD

This formalization is a first step toward a much larger vision: a fully verified mathematical theory of deep learning.

**Higher-order optimization.** Second-order methods (using Hessians) correspond to the *2-jet bundle* — a higher-order generalization of the cotangent bundle. Formalizing this connection would put Newton's method and natural gradient descent on rigorous geometric footing.

**Categorical machine learning.** Recent work by Fong, Spivak, and others has shown that supervised learning itself can be formulated as a functor between categories. The cotangent lift theorem is one piece of this larger categorical picture. Formalizing the entire framework could yield new architectures derived from pure mathematical principles.

**Verified AI systems.** As proof assistants like Lean mature and as AI systems are deployed in ever more consequential settings, the demand for formally verified machine learning will grow. Today we verify that backprop computes the right gradients. Tomorrow we may verify convergence guarantees, robustness bounds, and fairness properties — all within the same mathematical framework.

**Tropical neural networks.** If ReLU networks are secretly tropical, then the rich theory of tropical algebraic geometry — Newton polytopes, tropical curves, Bergman fans — might offer new tools for understanding neural network expressiveness and optimization landscapes.

## CLOSING

There is a persistent myth that pure mathematics and practical engineering inhabit separate worlds. Backpropagation demolishes this myth. An algorithm that trains billion-parameter language models is, at its heart, a theorem about cotangent bundles on smooth manifolds — a topic that nineteenth-century geometers like Riemann and Cartan would have recognized instantly.

When we formalize this connection in a proof assistant and the computer confirms "no errors found," something remarkable has happened. A chain of logical deductions, stretching from the axioms of set theory through the definition of smooth manifolds to the contravariant functoriality of the cotangent bundle, has been verified to be flawless. No human could check every step. But the machine can, and does.

This is the promise of formal mathematics: not to replace human intuition, but to extend it. We dream up the connections — between geometry and gradient descent, between tropical algebra and ReLU networks, between categories and computation. Then we verify them with absolute certainty.

Backpropagation is a cotangent lift. The proof compiles. And in that simple fact lies a bridge between the abstract beauty of differential geometry and the practical miracle of machines that learn.
