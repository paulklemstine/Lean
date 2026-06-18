# Backprop as Cotangent Lift: When Neural Nets Meet the Future

## LEDE

In 1986, a trio of researchers — David Rumelhart, Geoffrey Hinton, and Ronald Williams — published a paper that would reshape the world. Their algorithm, *backpropagation*, taught neural networks to learn by flowing error signals backward through layers of artificial neurons. It was elegant, it was effective, and for three decades, almost nobody asked *why* it worked so well.

Not why it converges, or why it's efficient — those questions had technical answers involving calculus and computational complexity. The deeper question was: why does the algorithm have this peculiar structure? Why must the gradients flow *backward*? Why does the order of operations *reverse*?

Now, a formal proof in the Lean theorem prover has made the answer precise: backpropagation isn't just an algorithm. It's a theorem of differential geometry, as inevitable as the fact that pulling a glove inside out reverses left and right. The backward flow of gradients is forced by a mathematical structure called the *cotangent functor* — and its reversal of direction is not a design choice, but a law of nature.

## THE MATHEMATICAL HEART

Imagine you're standing on a hillside and you want to describe how steep the slope is beneath your feet. You could talk about which direction is "uphill" — that's a *tangent vector*, pointing along the surface. Or you could talk about how fast your altitude changes as you take a step — that's a *cotangent vector*, measuring the rate of change.

These two descriptions seem like mirror images, and they nearly are. But there's a crucial asymmetry. Tangent vectors push forward: if you have a map from one surface to another, tangent vectors ride along for free, carried in the direction of the map. Cotangent vectors, however, pull back: they travel in the *opposite* direction.

This is not a quirk. It's a fundamental feature of geometry, as basic as the fact that a shadow on the ground gets larger when you move the object closer to the light. Mathematicians call it *contravariance*, and it governs everything from coordinate changes in general relativity to the behavior of differential forms in electromagnetism.

Now picture a neural network as a chain of transformations. Raw data enters at one end — pixels of an image, perhaps — and flows through successive layers, each one reshaping and refining the representation. This is the *forward pass*: a composition of smooth maps, $f = f_n \circ \cdots \circ f_1$, from the space of inputs to the space of outputs.

Training the network means adjusting its parameters to minimize a loss function — a measure of how wrong the network's predictions are. To do this, you need the gradient of the loss with respect to every parameter. And the gradient, it turns out, is a cotangent vector.

Here is where the magic happens. The gradient of the loss lives at the output end of the network. To propagate it back to the input — to compute how each parameter contributed to the error — you must apply the *cotangent lift*, the geometric operation that pulls covectors backward through a map. And because the cotangent lift is contravariant, it automatically reverses the order of the layers:

$$T^*(f_n \circ \cdots \circ f_1) = T^*f_1 \circ \cdots \circ T^*f_n$$

Read that equation aloud: the cotangent lift of the whole network equals the lift of the first layer, applied after the lift of the second layer, applied after ... the lift of the last layer. That reversed sequence *is* backpropagation. The algorithm doesn't reverse the order because someone was clever. It reverses the order because cotangent vectors are contravariant, full stop.

## WHY IT MATTERS

This isn't merely an exercise in mathematical aesthetics — though it is certainly that. The identification of backpropagation with the cotangent lift has practical consequences that ripple across multiple fields.

**Geometric deep learning.** Modern neural networks increasingly operate on non-Euclidean data: molecules modeled as graphs, proteins as surfaces, cosmological fields on the sphere. The cotangent framework extends effortlessly to these settings. On a curved manifold, the "Jacobian transpose" of flat-space backpropagation must be replaced by the metric-dependent cotangent lift. Getting this wrong introduces subtle errors; getting it right, via the geometric framework, guarantees correctness by construction.

**Verified AI systems.** As neural networks infiltrate safety-critical applications — autonomous vehicles, medical diagnosis, infrastructure control — the demand for formally verified training algorithms grows urgent. The Lean formalization proves that the mathematical structure is sound, providing a foundation on which verified automatic differentiation systems can be built.

**Physics and Hamiltonian mechanics.** The cotangent bundle of a configuration space is the phase space of classical mechanics. Training a neural network, viewed through this lens, becomes a dynamical system on a symplectic manifold. This connection has already inspired new optimization algorithms (Hamiltonian Monte Carlo, symplectic integrators for training) and promises deeper insights into why certain training procedures converge while others don't.

**Category theory and compositionality.** The cotangent lift is a *functor* — a structure-preserving map between categories. This means neural network training is compositional: the gradient of a composed network is automatically the composition of gradients, assembled in reverse. This functorial perspective is the foundation of modern compositional approaches to machine learning, where complex systems are built from modular, independently-trainable components.

## THE BEAUTY

What makes this result beautiful is its inevitability. There are exactly two natural things you can do with a smooth map between manifolds: push tangent vectors forward, or pull cotangent vectors back. There is no third option. The entire edifice of backpropagation — the reversed ordering, the chain rule, the accumulation of gradients — is a consequence of this binary choice.

There's a deeper beauty, too, in the connection to tropical geometry. The ReLU activation function, $\max(0, x)$, is the fundamental operation of *tropical algebra* — a version of mathematics where addition is replaced by maximum and multiplication by addition. A ReLU network computes a tropical polynomial, and its "derivative" is a tropical subdifferential. The cotangent lift, in this tropical limit, degenerates into a combinatorial operation on Newton polytopes. The continuous geometry of smooth manifolds and the discrete geometry of tropical varieties are two faces of the same mathematical coin, connected by the single thread of contravariance.

## LOOKING AHEAD

The formalization of backpropagation as a cotangent lift opens doors that mathematicians are only beginning to push through.

**Higher-order differentiation.** If the cotangent bundle gives us first derivatives, what about second and third? The *jet bundle* — a higher-order generalization — should encode Hessians and beyond. Formalizing this could lead to verified second-order optimization methods with provable convergence guarantees.

**Infinite-dimensional extensions.** Neural ODEs and diffusion models operate in infinite-dimensional function spaces. The cotangent lift should extend to Fréchet manifolds, with the adjoint sensitivity method (Pontryagin's maximum principle) emerging as a special case. Making this precise could unify neural network training with optimal control theory.

**Quantum backpropagation.** Quantum circuits are maps between Hilbert spaces, and their "gradients" involve the *parameter-shift rule*. Is this rule a cotangent lift in the category of quantum channels? If so, the entire framework of classical backpropagation might have a quantum analogue, with profound implications for quantum machine learning.

The next century of mathematics will likely see the boundary between pure and applied dissolve further. The cotangent lift — born in the abstract world of differential geometry — has found its most consequential application in the training of neural networks. And the formal proof, written in a language that a computer can verify, ensures that this bridge between worlds rests on unshakable foundations.

## CLOSING

There is something profoundly satisfying about discovering that an algorithm invented by engineers to solve practical problems turns out to be a theorem that mathematicians have known, in different guise, for over a century. The cotangent bundle was introduced to study the motion of planets and the curvature of space. That it also explains how a neural network learns to recognize a cat in a photograph is not a coincidence — it is evidence that mathematics is not merely a tool we invented, but a structure we discovered.

Backpropagation is not clever. It is *necessary*. And that necessity, formalized in a dozen lines of Lean code and verified by machine, is perhaps the most elegant statement we can make about the mathematics of learning: the gradient flows backward because geometry demands it.
