# Why Neural Networks Learn: The Hidden Kernel Inside Every AI

## The Mystery of Deep Learning

Every time you ask an AI chatbot a question, every time your phone recognizes your face, every time a self-driving car navigates an intersection, a neural network is doing something remarkable — and until recently, no one fully understood why it works.

Neural networks learn by trial and error. They start with random guesses and gradually improve through a process called gradient descent, adjusting millions of tiny numerical knobs (called parameters or weights) to reduce errors on training data. But here's the puzzle that haunted researchers for decades: with millions of parameters, a neural network has so much flexibility that it could memorize any dataset perfectly — even random noise. So why does it generalize? Why does it learn genuine patterns instead of memorizing trivia?

The answer turns out to involve a beautiful mathematical object hidden inside every neural network — an object that connects deep learning to a century of mathematical theory about kernels, and reveals that the most successful AI systems in the world are, in a precise sense, doing something surprisingly simple.

## The Neural Tangent Kernel

In 2018, three mathematicians at EPFL — Arthur Jacot, Franck Gabriel, and Clément Hongler — published a paper that changed how researchers think about neural networks. They discovered the **Neural Tangent Kernel** (NTK), a mathematical function that captures the essence of how a neural network learns.

The idea is elegant. A neural network is a function from inputs to outputs, parameterized by its weights. When you train the network, you're moving through a vast landscape of possible weight configurations, following the gradient of the loss function downhill. The NTK captures how much the network's predictions at two different inputs "talk to each other" during this descent.

More precisely, the NTK between two inputs x and y is the inner product of the network's sensitivities: how much the prediction at x changes when you wiggle each parameter, dotted with how much the prediction at y changes. This simple construction has profound consequences.

## The Lazy Regime: When Networks Simplify

The key insight came when Jacot, Gabriel, and Hongler considered what happens when a neural network is very wide — when each layer has an enormous number of neurons. In this regime, something remarkable occurs: the NTK barely changes during training.

Think of it this way. A very wide network is like a huge choir where each singer contributes only a tiny fraction of the total sound. When you train the network, each individual weight changes only a little. Because the NTK is computed from the collective behavior of all these weights, it remains nearly constant — "frozen" — throughout training.

This frozen-kernel regime is called the **lazy regime**, and it transforms the complex, nonlinear dynamics of neural network training into something much simpler: a linear system driven by a fixed kernel.

## From Chaos to Clockwork

Here's where the mathematics becomes beautiful. When the NTK stays fixed, the training dynamics become a simple linear iteration. Let's call the training error at step t the "residual" u(t). Then:

**u(t+1) = u(t) − η · K · u(t)**

where η is the learning rate and K is the NTK matrix. This is just repeated multiplication by the matrix (I − ηK), and after t steps:

**u(t) = (I − ηK)^t · u(0)**

This formula is the heartbeat of NTK convergence theory. It says that the training error decays exponentially, like a vibrating string losing energy to damping. The rate of decay is governed by the eigenvalues of the kernel matrix K.

If all eigenvalues of K are positive and the learning rate is small enough, every component of the error shrinks geometrically. The network converges to perfect interpolation of the training data, and the solution it finds is the unique kernel regression solution — the smoothest function (as measured by the kernel) that fits the data.

## Universality: Architecture Doesn't Matter

Perhaps the most striking consequence of NTK theory is **universality**: two neural networks with completely different architectures — different depths, activation functions, connectivity patterns — will have identical training dynamics if they happen to produce the same NTK matrix.

This is counterintuitive. You might expect that a convolutional network and a fully connected network would learn in fundamentally different ways. But NTK theory says that, in the lazy regime, the only thing that matters is the kernel. The architecture determines which kernel you get, but once the kernel is fixed, the learning dynamics are universal.

This has a precise mathematical formulation. If two dynamical systems share the same kernel matrix K and learning rate η, their residuals after t steps are identical, regardless of what generated those systems. The convergence depends on the spectrum of K alone.

## The Geometry of Convergence

The convergence story has a beautiful geometric interpretation. The update operator T = I − ηK maps the current error to the next error. Each application of T shrinks the error in every direction, like squeezing a rubber ball.

The quadratic expansion of the squared error reveals the mechanism:

**⟨Tu, Tu⟩ = ⟨u, u⟩ − 2η⟨u, Ku⟩ + η²⟨Ku, Ku⟩**

The middle term, −2η⟨u, Ku⟩, is the energy extracted by one step of gradient descent. When K is positive definite, this term is always negative — every step reduces the error. The last term, η²⟨Ku, Ku⟩, represents "overshooting" — moving too far downhill. When the learning rate η is small enough, the extraction term dominates, and the system converges.

The fixed points of this system — the states where the error stops changing — satisfy Ku = 0. For a positive definite kernel, the only solution is u = 0: zero error, perfect interpolation.

## The Positive Definiteness Guarantee

Why is the NTK matrix always at least positive semidefinite? Because it's a **Gram matrix** — a matrix of inner products. The NTK matrix entry K_{ij} equals ⟨∇f(x_i), ∇f(x_j)⟩, where ∇f(x) is the gradient of the network output with respect to all parameters, evaluated at input x.

Any matrix of inner products is positive semidefinite. For any vector v, the quadratic form v^T K v equals the squared norm of the linear combination Σ v_i ∇f(x_i). Squared norms are always non-negative.

This structural guarantee means the NTK matrix can never have negative eigenvalues, which would cause the training dynamics to diverge. The worst case is a zero eigenvalue, corresponding to a direction in which the network cannot learn — but divergence is impossible.

## Tropical Walls and Feature Learning

The lazy regime isn't the whole story. Recent mathematical work on **tropical neural networks** — networks analyzed through the lens of tropical geometry — reveals that the lazy regime is separated from a richer **feature learning** regime by geometric boundaries called tropical walls.

Inside a tropical cell (a polyhedral region of input space), the network behaves linearly and the kernel formula freezes to a simple form. But when training pushes the network across a tropical wall, the active neurons change, the kernel shifts, and the network enters the feature learning regime where it can discover new representations.

This dichotomy — lazy inside cells, feature learning across walls — is the geometric heart of why neural networks can be both stable (converging reliably) and expressive (learning complex features).

## What This Means for AI

NTK theory provides the first rigorous foundation for understanding why neural networks converge during training. It explains several empirical observations:

- **Why wider is better**: Wider networks are closer to the lazy regime, where convergence guarantees are strongest.
- **Why learning rates matter**: Too large, and the overshooting term dominates; too small, and training is impractically slow.
- **Why architectures are interchangeable**: In the lazy regime, the architecture only matters through the kernel it induces.
- **Why overparameterization helps**: More parameters push the system toward the lazy regime, where the kernel stays fixed and convergence is guaranteed.

But NTK theory also reveals the limits of the lazy regime. The most powerful neural networks — the ones that learn remarkable features like edge detectors in vision or syntactic structures in language — operate outside the lazy regime, in the feature learning zone. Understanding this transition zone remains one of the deepest open problems in the theory of deep learning.

## The Road Ahead

The NTK convergence theorem is not the end of the story — it's the beginning. The key conjecture driving current research is that as network width m grows, the NTK at initialization converges to a deterministic limit kernel at rate O(1/√m). This has been proved for specific architectures but remains open in full generality.

Beyond convergence, researchers are exploring how the NTK evolves during training in the feature learning regime, how it relates to the generalization properties of the trained network, and whether there are other hidden mathematical structures — beyond kernels — that govern deep learning.

The discovery of the NTK shows that even in the most complex AI systems, mathematical structure lurks beneath the surface. The challenge now is to find the mathematics of feature learning — the theory that will explain not just that neural networks converge, but why they learn the right things.
