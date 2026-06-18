# backprop_as_cotangent: When AI Meets the Future

## LEDE

In 1986, David Rumelhart, Geoffrey Hinton, and Ronald Williams published a paper that would reshape civilization. Their contribution wasn't a new theorem or a breakthrough algorithm in the traditional sense — it was a recipe called *backpropagation*, a method for teaching neural networks by propagating errors backward through layers of computation. Nearly four decades later, every large language model, every image generator, every AlphaFold prediction of protein structure runs on this same idea. Backpropagation is the heartbeat of modern AI.

But here's what's strange: for all its practical triumph, backpropagation has always seemed like a clever trick rather than a deep truth. Why does it work? Why does it flow *backward*? Is there some hidden mathematical law that makes reverse-mode differentiation not just efficient, but *inevitable*?

The answer, it turns out, was hiding in 19th-century geometry.

## THE MATHEMATICAL HEART

Imagine you're hiking in a mountain range. At every point on the landscape, you can feel the slope beneath your feet — the gradient tells you which direction is steepest. Now imagine you're not standing *on* the mountain, but hovering just above it, holding a sheet of tracing paper flat against the slope. That sheet captures something subtler than the slope itself: it records how *measurements change* as you move. In mathematics, this is called a *covector*, and the collection of all possible covectors at every point forms the *cotangent bundle*.

Here's the key intuition. When you walk forward along a path — say, from base camp through a valley to a summit — your position moves forward through space. But the covectors, those measurement-sheets, transform in the *opposite* direction. If you want to know how a measurement at the summit relates to conditions at base camp, you have to pull the information *backward* along the path. This reversal isn't a choice or a convention. It's a mathematical law as rigid as the fact that multiplying two negative numbers gives a positive one.

A neural network is, at its core, a chain of smooth transformations: input data enters at one end, passes through layers of computation, and emerges as a prediction at the other. The forward pass — computing the output from the input — is like hiking forward along the trail. But computing how the *loss function* (the measure of error) depends on each internal parameter requires pulling covectors backward through every layer. This is backpropagation, and it is nothing more and nothing less than the cotangent lift: the natural, canonical, mathematically forced way to transport dual information through a composed smooth map.

In the language of category theory, the cotangent bundle defines a *contravariant functor* — a mathematical gadget that systematically reverses arrows. When you compose three maps $f$, $g$, $h$ going forward, the cotangent functor gives you $h^*$, $g^*$, $f^*$ going backward. This reversal is the *only* mathematically consistent way to propagate covectors through a composition. Backpropagation doesn't just happen to run backward — it *must*.

## WHY IT MATTERS

This isn't merely an aesthetic observation. Understanding backpropagation as a cotangent lift has concrete consequences for the future of AI and science.

**Geometric deep learning.** Modern neural networks increasingly operate on curved spaces — molecular surfaces, meshes of physical objects, the hyperbolic spaces used in natural language processing. The cotangent perspective immediately tells you how to do backpropagation on manifolds: use the cotangent lift, which is defined for *any* smooth map between *any* smooth manifolds. No Euclidean coordinates required.

**Correctness guarantees.** As AI systems are deployed in safety-critical settings — autonomous vehicles, medical diagnosis, nuclear reactor control — we need mathematical *proof* that gradient computations are correct. The cotangent framework provides exactly this: backpropagation is correct because it's a theorem of differential geometry, not because someone checked it on a million test cases.

**Physics-informed neural networks.** In Hamiltonian mechanics, the cotangent bundle is the *phase space* — the arena where all of classical physics plays out. The fact that backpropagation lives in the same mathematical structure suggests deep, still-unexplored connections between learning and physics. Could the training dynamics of a neural network be understood as a Hamiltonian flow? Early results suggest yes.

**Automatic differentiation at scale.** The distinction between forward-mode and reverse-mode automatic differentiation maps perfectly onto the covariant/contravariant dichotomy. Forward mode computes tangent vectors (covariant, like the tangent bundle). Reverse mode computes cotangent vectors (contravariant, like the cotangent bundle). This categorical understanding enables compiler optimizations that can accelerate training on next-generation hardware.

## THE BEAUTY

What makes this result beautiful is the collision of worlds. On one side, you have the intensely practical, engineering-driven world of deep learning — GPUs humming, loss curves descending, models learning to speak and see. On the other, you have the austere, abstract world of differential geometry and category theory — cotangent bundles, contravariant functors, pullbacks on smooth manifolds.

The beauty lies in the discovery that these aren't two separate worlds at all. The reason backpropagation works — the reason it has powered a revolution in artificial intelligence — is the same reason that Hamiltonian mechanics works, that Maxwell's equations have a dual formulation, that the Hodge star operator exists. It's contravariance. It's the mathematical universe telling us that for every natural way to push information forward, there is an equally natural, equally canonical way to pull information back.

There is also beauty in the formalization itself. By encoding this insight in Lean 4, a proof assistant that checks every logical step with machine precision, we transform a folk theorem of the AI community into a certified mathematical artifact. The proof is short — almost embarrassingly so — because the statement, properly understood, is a direct consequence of functoriality. And that's perhaps the deepest beauty of all: the most important algorithm in modern computing is, at its heart, a one-line consequence of abstract nonsense.

## LOOKING AHEAD

This formalization opens several tantalizing doors.

First, **higher-order backpropagation**. The cotangent bundle captures first derivatives. But the *jet bundle* — a natural generalization — captures derivatives of all orders. Could a jet-bundle functor give us a principled framework for computing Hessians, third-order tensors, and beyond? This would revolutionize second-order optimization methods in deep learning.

Second, **quantum backpropagation**. Quantum computing operates not on smooth manifolds but on complex projective spaces and operator algebras. The cotangent lift has analogues in this setting — completely positive maps, Stinespring dilations — and understanding backpropagation categorically may be the key to training quantum neural networks efficiently.

Third, **backpropagation on stratified spaces**. Real neural networks use ReLU activations, which are not smooth — they have kinks. The correct mathematical setting is *stratified spaces*, where smooth manifolds are glued together along lower-dimensional boundaries. Extending the cotangent framework to this setting would provide the first fully rigorous foundation for backpropagation as actually practiced.

And perhaps most speculatively: if backpropagation is a theorem of geometry, what other algorithms are theorems in disguise? Could attention mechanisms, normalization layers, or skip connections be understood as instances of known mathematical structures? The categorical perspective suggests that the answer is yes — and that the deepest insights of modern AI are still waiting to be formalized.

## CLOSING

There is something profoundly satisfying about discovering that an algorithm invented by engineers, refined by hackers, and scaled by corporations turns out to be a theorem that a 19th-century geometer would have recognized. Backpropagation is not a trick. It is not a heuristic. It is the cotangent lift — the unique, canonical, mathematically inevitable way to propagate dual information through a composition of smooth maps.

Mathematics has a way of revealing hidden necessities. We build our tools thinking they are arbitrary choices, engineering conveniences, pragmatic compromises. And then, sometimes, we look more carefully and discover that what we built was the only thing we *could* have built — that the universe of mathematical truth had been quietly guiding our hands all along.

In formalizing this connection in Lean, we do more than verify a theorem. We build a bridge between the two great intellectual projects of our age: artificial intelligence and the foundations of mathematics. And we catch a glimpse of something that both projects share — the conviction that beneath the complexity of the world, there is structure, and that structure can be understood.
