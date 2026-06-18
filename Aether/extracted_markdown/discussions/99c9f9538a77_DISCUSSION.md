# Backprop as Cotangent: When Neural Nets Meet the Future

## LEDE

In 1854, Bernhard Riemann stood before a small audience in Göttingen and described curved spaces that would, sixty years later, become the language of Einstein's general relativity. Nobody in the room imagined that Riemann's geometry of curved surfaces would one day underpin the technology recognizing faces in your phone or translating languages in real time. Yet here we are: a theorem proved this year in the Lean proof assistant reveals that the algorithm powering every modern neural network — backpropagation — is not a clever engineering trick. It is a fundamental operation in Riemann's differential geometry, as inevitable as gravity bending starlight.

The result is deceptively simple: *backpropagation is the cotangent lift of the forward map.* In plain language, the process of training a neural network is the mathematical dual of running it — the same geometric structure, viewed from the opposite side of the mirror.

## THE MATHEMATICAL HEART

Imagine you're standing on a hillside, and you want to get to the bottom of the valley. You can feel the slope under your feet — that slope tells you which direction is steepest. Now imagine the hillside isn't just a surface in ordinary three-dimensional space, but a vast landscape with millions of dimensions, one for each adjustable parameter of a neural network. The slope you feel under your feet is a *covector* — a mathematical object that lives in the "cotangent space," which is the set of all possible ways to measure how steeply a function changes at a given point.

When a neural network processes an input — say, an image of a cat — data flows forward through layers of computation: layer one extracts edges, layer two finds textures, layer three recognizes ears and whiskers. Each layer is a smooth mathematical function, and the whole pipeline is their composition. Geometers call this a *smooth map between manifolds*.

Now comes the revelation. To train the network, we need to know: if I nudge each parameter slightly, how does the output error change? The chain rule of calculus answers this, but it answers it in a very specific geometric way. The gradient flows *backward* through the layers, and at each step, it is transformed by the *transpose* of that layer's derivative. This reverse flow is not just computationally convenient — it is the *cotangent lift*, a canonical construction that differential geometers have studied for over a century.

Think of it this way: the forward pass is like water flowing downhill through a series of channels. The backward pass — backpropagation — is like sound echoing back through those same channels, but the acoustic properties are determined by the *dual* geometry of the channels. Water (data) flows covariant; sound (gradients) flows contravariant. Same structure, opposite direction.

The key equation is breathtaking in its simplicity: for two composable functions $f$ and $g$, the cotangent lift of their composition satisfies $(g \circ f)^* = f^* \circ g^*$. The order reverses. This is exactly the backpropagation algorithm: to compute gradients through a stack of layers, you apply the transpose of each layer's derivative *in reverse order*.

## WHY IT MATTERS

This isn't merely an exercise in mathematical aesthetics, though the aesthetics are stunning. The identification of backprop with cotangent lifts has practical consequences that ripple across science and engineering.

**Correctness for free.** If backprop is a cotangent lift, then its correctness follows from the functoriality of the cotangent bundle — a theorem that has been established beyond doubt for over a century. There is no need to verify backpropagation implementation by implementation. Any system that correctly implements the cotangent lift is automatically a correct implementation of backprop.

**Beyond flat spaces.** Modern deep learning takes place in Euclidean space — flat, featureless, infinite. But the real world is curved. Molecules live on Riemannian manifolds. Rotations form Lie groups. The cotangent perspective immediately tells us how to do backpropagation on these curved spaces, opening the door to geometric deep learning on proteins, crystal structures, and spacetime itself.

**Adjoint methods everywhere.** The cotangent lift is the same mathematical object that appears in weather prediction (adjoint atmospheric models), aircraft design (adjoint shape optimization), and quantum mechanics (the Schrödinger equation's adjoint). This theorem reveals that all these computational techniques are siblings — different faces of the same geometric crystal.

## THE BEAUTY

What makes this result beautiful is its inevitability. Backpropagation was discovered independently by multiple researchers in the 1960s and 70s — Linnainmaa in Finland, Werbos at Harvard, later Rumelhart, Hinton, and Williams. Each discovered it through computation and cleverness. But the cotangent perspective reveals that they had no choice. Any reasonable algorithm for computing derivatives in reverse *must* be the cotangent lift, because the cotangent lift is the *only* functorial way to pull back linear forms through smooth maps.

There is a deep symmetry here that echoes through physics. In Hamiltonian mechanics, the positions of particles live on a manifold $M$, while their momenta live on the cotangent bundle $T^*M$. The phase space of physics — the arena where all of mechanics plays out — is a cotangent bundle. So when a neural network learns, its gradients live in exactly the same mathematical space as the momenta of physical particles. Learning is a kind of mechanics. The loss landscape is a kind of potential energy. And backpropagation is the analog of Hamilton's equations, transporting momentum backward through the layers.

## LOOKING AHEAD

The formalization of this theorem in Lean 4 is a milestone, but it is also a beginning.

The most tantalizing direction is *higher-order differentiation*. If first-order backprop is the cotangent lift, what is second-order backprop? The natural answer involves *jet bundles* — spaces that encode not just first derivatives but all derivatives up to order $k$. A full theory of higher-order automatic differentiation through jet bundle lifts could revolutionize optimization, enabling Hessian-based methods at scale.

Another frontier is *non-smooth networks*. ReLU, the most popular activation function, is not differentiable at zero. Yet backpropagation works anyway. The cotangent perspective suggests looking at stratified spaces and tropical geometry — the mathematics of piecewise-linear functions — to make this rigorous. ReLU networks, it turns out, are tropical polynomials, and their "gradients" may be understood as flows on tropical cotangent complexes.

Perhaps most ambitious is the dream of *synthetic differential geometry* for machine learning. In this framework, infinitesimally small quantities are genuine mathematical objects, not limits. A programming language built on synthetic differential geometry could make automatic differentiation a primitive operation, compiled directly from the mathematics rather than patched on after the fact.

## CLOSING

There is something deeply moving about discovering that the workhorse algorithm of modern AI — the engine behind language models, image generators, and protein folders — was always, secretly, a piece of 19th-century differential geometry. Riemann could not have imagined neural networks, and the inventors of backpropagation were not thinking about cotangent bundles. Yet the mathematics knew. The structure was there, waiting patiently for 170 years, for someone to notice that the gradient flowing backward through a neural network follows the same path that a covector traces on a smooth manifold.

This is the unreasonable effectiveness of mathematics made manifest: not merely that mathematics applies to the physical world, but that the same deep structures arise independently in wildly different contexts — in the curvature of spacetime, in the phase spaces of classical mechanics, and in the training loops of artificial intelligence. The cotangent bundle does not care whether it is describing the orbit of a planet or the loss landscape of GPT. The mathematics is one.

And that, perhaps, is the most beautiful thing of all.
