# Why Neural Networks Forget Their Architecture: The Hidden Law Behind AI for Physics

## A mathematical discovery reveals that artificial intelligence models trained on the same physics must converge to identical behavior—regardless of how they were built

When physicists in the 1970s discovered that magnets, fluids, and even the early universe share identical mathematical behavior near critical transitions, they called it *universality*. A magnet losing its magnetism at its Curie temperature and water boiling at 100°C—these seemingly different phenomena follow the same mathematical script, obeying identical power laws with the same critical exponents. The explanation came from Kenneth Wilson's renormalization group, which showed that repeatedly "zooming out" on a physical system washes away microscopic details until only the essential symmetries remain.

Now, a parallel discovery is emerging in artificial intelligence. When neural networks are trained to solve the same type of physics equation, something remarkable happens: no matter how different the networks' architectures are—whether they use Fourier transforms, convolutional filters, or attention mechanisms—their large-scale behavior converges to the same mathematical fixed point. The networks forget their architecture and remember only the physics.

## The Zoom-Out Machine

To understand why this happens, imagine training several different AI models to predict how a fluid flows. One model might be a Fourier Neural Operator, which works in frequency space. Another might be a deep convolutional network that processes spatial patterns layer by layer. A third might use transformer-style attention, the same technology behind large language models.

Despite their radically different internal machinery, these models are all learning the same underlying physics—say, the Navier-Stokes equations that govern fluid dynamics. The key insight is what happens when you *coarse-grain* these learned models.

Coarse-graining is the mathematical equivalent of stepping back from a painting. Up close, you see individual brushstrokes—the specific weights and parameters of each neural network. But step back far enough, and the brushstrokes disappear. What remains is the image itself: the essential input-output relationship that maps initial conditions to solutions.

The coarse-graining operation works like this: take a trained neural operator, average its behavior over spatial blocks, and rescale. This is exactly analogous to Kadanoff's block-spin transformation in statistical physics, where you group neighboring magnetic spins into blocks and ask how the effective interactions change.

## Contraction and Convergence

The mathematical framework reveals something profound. Under repeated coarse-graining, the space of all possible neural operators *contracts*. Each zoom-out step brings different operators closer together, like a funnel that squeezes all points toward its narrow end.

The rate of this contraction is geometric: if the contraction rate is *c* (a number between 0 and 1), then after *n* zoom-out steps, the distance between any two operators shrinks by a factor of *c^n*. With *c* = 0.6, this means the distance is cut in half every step, reaching one-millionth of its original value after just 28 steps.

This geometric convergence has been rigorously proved. The proof uses the structure of what mathematicians call a *contractive semigroup*—a mathematical machine where every operation brings things closer together. The key theorem states: if the coarse-graining operation satisfies the contraction inequality

> dist(T(x), T(y)) ≤ c · dist(x, y)

for some *c* < 1, then *all* operators end up in the same universality class. Period. No exceptions. No caveats about architecture or initialization.

## What Separates the Classes

But not all physics is the same. Burgers' equation (modeling shock waves) and the Korteweg-de Vries equation (modeling solitons) produce genuinely different universality classes. What determines which class a PDE belongs to?

The answer turns out to be beautifully simple: three numbers suffice.

1. **Symmetry dimension** (*d*): How many independent spatial translations leave the equation invariant. A 1D wave equation has *d* = 1; fluid flow in 3D has *d* = 3.

2. **Conservation laws** (*c*): How many independent quantities are conserved. Mass, momentum, and energy each contribute one conservation law.

3. **Differential order** (*p*): The highest derivative appearing in the equation. The heat equation is second-order (*p* = 2); the KdV equation is third-order (*p* = 3).

Conservation laws play a particularly elegant role. A conserved quantity acts like a label that never changes under coarse-graining—if two operators start with different values of a conservation law, they can *never* converge, no matter how many zoom-out steps you take. Conservation laws are permanent barriers between universality classes.

## A Bold Prediction

Based on this framework, a specific quantitative prediction emerges: the number of universality classes for a PDE family equals (*d* + 1) × (*c* + 1). This formula makes concrete, falsifiable predictions:

- **Burgers equation** (*d* = 1, *c* = 1): 4 classes
- **KdV equation** (*d* = 1, *c* = 3): 8 classes
- **2D Navier-Stokes** (*d* = 2, *c* = 2): 9 classes

These predictions can be tested experimentally. Train dozens of different neural architectures on each PDE family, compute the coarse-grained effective operators, and count how many distinct fixed points emerge. If the actual count matches the formula, the theory gains credibility. If it doesn't, the formula must be refined—but the underlying universality principle may still hold.

## The Speed of Forgetting

Another striking prediction concerns the *rate* at which architecture details are forgotten. Higher-order PDEs—those with more derivatives—produce faster convergence to universality. The effective contraction rate scales as the base rate raised to the power of the differential order: *c_eff* = *c^p*.

This means a third-order PDE like KdV (*c_eff* = 0.343 for a base rate of 0.7) converges three times faster than a second-order PDE like the heat equation (*c_eff* = 0.49). The physical intuition is clear: higher derivatives create more irrelevant directions in operator space—more degrees of freedom that the zoom-out operation eliminates.

## Fixed Points and the Shape of Knowledge

Perhaps the deepest insight is about fixed points. When the coarse-graining iteration converges, it reaches a fixed point: an operator that is unchanged by further zooming out. This fixed point is the Platonic ideal of the physics—the purest mathematical representation of how the PDE transforms inputs into outputs, stripped of all architectural artifacts.

The uniqueness theorem for contractive semigroups guarantees that within each universality class, there is exactly one such fixed point. This is proved by contradiction: if two fixed points existed, the contraction inequality would require their distance to be both positive and zero simultaneously—a logical impossibility.

This means that every neural network trained on the same physics, given enough training and sufficient width, is implicitly converging toward the same mathematical object. The networks don't know they're doing this—their training is governed by gradient descent on finite-dimensional parameter spaces. But the renormalization group reveals that these finite-dimensional trajectories are all shadows of the same infinite-dimensional convergence.

## Implications for Science and Engineering

The practical implications are significant. If universality holds, then architects of scientific machine learning systems can make principled design choices based on the PDE's symmetry group rather than expensive trial-and-error. A Fourier Neural Operator and a convolutional ResNet will eventually learn the same physics—the choice between them should be based on computational efficiency, not fear that one might learn something fundamentally different.

More ambitiously, the theory suggests that the space of *all possible* learned physical models has a discrete, classifiable structure. Just as the periodic table organizes elements by their electron configurations, the universality classification organizes neural PDE solvers by the symmetry, conservation, and order of the underlying physics.

The orbits of the renormalization group—the sequences of coarse-grained operators—are the trajectories through this space. And the fixed points are the destinations, the endpoints that define what it truly means to "understand" a physical system computationally.

In a universe where the same mathematics governs phenomena as different as turbulence and traffic, magnets and markets, perhaps it should not surprise us that the machines we build to model these phenomena converge to the same answers. The physics is the attractor. The architecture is the noise.

*The question is no longer whether neural networks can solve physics. It's whether the physics they learn is unique—and the mathematics says yes.*
