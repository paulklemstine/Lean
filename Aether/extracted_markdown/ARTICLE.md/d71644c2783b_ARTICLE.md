# Why Neural Networks Learn: The Hidden Kernel That Governs Training

## A Frozen Mirror Inside Every Neural Network

In the summer of 2012, a neural network called AlexNet stunned the computer vision community by crushing the ImageNet competition. Within a few years, deep learning crossed a threshold that nobody had anticipated. Networks with millions of parameters began to solve problems that had resisted decades of engineering — translating languages, recognizing faces, diagnosing diseases. But here was the paradox: nobody could explain *why* training worked. The mathematics of optimization said that gradient descent should get trapped in terrible local minima, that the loss landscape should be a nightmarish labyrinth. Instead, neural networks sailed through it as if guided by an invisible hand.

In 2018, three researchers at EPFL — Arthur Jacot, Franck Gabriel, and Clément Hongler — discovered what that invisible hand was. They called it the **Neural Tangent Kernel**, and it revealed that behind the apparent complexity of neural network training, a surprisingly elegant mathematical structure was hiding in plain sight.

## The Fingerprint of a Network at Birth

To understand the NTK, we first need to appreciate what a neural network actually *is* from a mathematical standpoint. It is a function — a very complicated, heavily parameterized function — that takes an input (an image, a sentence, a molecular structure) and produces an output (a classification, a translation, a binding energy). The function is defined by millions or billions of adjustable parameters called weights, and "training" the network means finding the right values for these weights.

Now imagine you've just initialized a neural network. Its parameters are random noise — it knows nothing. But already, at this very moment, the network has encoded a particular way of comparing any two inputs. If you feed it two images, say a photo of a cat and a photo of a dog, the network's random parameters define a kind of "similarity score" between them — not based on what the images look like to a human, but based on how sensitively the network's output changes when you tweak each parameter.

This similarity score is the Neural Tangent Kernel. Mathematically, it's defined as an inner product: take the gradient of the network's output with respect to all parameters for input *x*, do the same for input *y*, and compute the dot product. The result, *K(x, y)*, measures how "aligned" the two inputs are in the network's internal parameter space.

What Jacot and colleagues proved is that this kernel — computed once, at initialization — essentially *controls the entire training process*. For sufficiently wide networks, the kernel barely changes during training. The network learns, but its fingerprint stays frozen.

## The Geometry of Descent

The frozen kernel idea is beautiful, but it would be a mere curiosity without a precise connection to training. That connection is what makes the NTK theory powerful.

To understand why this matters, think about what gradient descent actually does. At each step, the network looks at its current errors on the training data — a vector of residuals — and nudges its parameters to reduce those errors. The key insight is that these residuals evolve according to a simple linear rule:

**At each step, the residual gets multiplied by the matrix (I - ηK).**

Here, *I* is the identity matrix, *η* is the learning rate, and *K* is the NTK matrix evaluated on all pairs of training points. This is not an approximation — it is an exact algebraic identity for the linearized model, and a near-exact description for wide networks.

This means that training a neural network is, in the right limit, equivalent to solving a system of linear equations using an iterative method that dates back to the 19th century. The "deep learning revolution" is, at its core, kernel regression with a particular kernel.

The formalized proof of this residual iteration formula (see @file[Catalog/MachineLearning/NTKConvergence.lean], theorem `NTKDynamics.residual_eq_pow_mulVec`) establishes this identity rigorously by mathematical induction: after *t* steps of gradient descent, the residual equals *(I - ηK)^t* applied to the initial error vector. No approximations, no hand-waving.

## The Contraction Principle: Why Training Converges

Once you see training as repeated multiplication by a matrix, convergence becomes a question about that matrix's properties. This is a profound simplification — the entire complexity of deep learning optimization has been reduced to undergraduate-level linear algebra. If every time you multiply by *(I - ηK)*, the residual vector gets shorter — if the matrix is *contractive* — then the errors shrink geometrically toward zero.

The contraction bound (theorem `NTKDynamics.contraction_bound`) makes this precise: if there exists a constant *c < 1* such that ‖(I - ηK)v‖ ≤ c‖v‖ for every vector *v*, then after *t* steps, the residual norm satisfies:

**‖u_t‖ ≤ c^t · ‖u₀‖**

This is exponential convergence. If *c = 0.9*, then after 100 steps the error is down to about 0.003% of its initial value. If *c = 0.5*, it takes only about 20 steps to reduce the error by a factor of a million.

The beauty of this result is its generality. It doesn't depend on the network architecture, the data distribution, or the loss function in any specific way. It depends only on the spectral properties of the kernel matrix — on whether the learning rate is chosen so that the eigenvalues of *(I - ηK)* all lie strictly inside the unit disk.

## When You Reach the Bottom

Every optimization story needs an ending. What happens when the iteration converges — when the network reaches a fixed point? The fixed point theorem (theorem `NTKDynamics.fixed_point_kernel_null`) gives a clean answer: if *u* is a fixed point of the map *u ↦ u - ηKu*, then *Ku = 0*. The residual must lie in the null space of the kernel matrix.

For a positive definite kernel (which the NTK is, generically), the null space is trivial: only the zero vector. This means convergence implies *exact interpolation* — the network fits the training data perfectly. This explains the puzzling empirical observation that overparameterized networks routinely achieve zero training loss: the mathematics guarantees it.

## A Kernel Born from Geometry

All the convergence results above depend on the kernel matrix having good properties. But why is the NTK matrix always well-behaved? The answer lies in a elegant geometric fact. Because it is a **Gram matrix** — a matrix of inner products. The proof of positive semidefiniteness (theorem `ntkMatrix_posSemidef`) shows that for any vector *v*:

**v^T K v = Σⱼ (Σᵢ vᵢ · ∂f/∂θⱼ(xᵢ))² ≥ 0**

This is a sum of squares — manifestly non-negative. No matter what the network architecture is, no matter what the training data is, the NTK matrix can never have negative eigenvalues. This structural guarantee is what makes the convergence theory robust.

The symmetry of the kernel (theorem `ntkMatrix_symmetric`) is equally fundamental: *K(x, y) = K(y, x)* for all inputs. This follows from the commutativity of the dot product in parameter space. Together, symmetry and positive semidefiniteness mean that the NTK matrix is always a valid covariance structure — the same kind of mathematical object that governs Gaussian processes.

## Architecture Doesn't Matter (In the Limit)

The practical implications of these structural results are already significant: they guarantee that gradient descent *can* converge for any architecture, given the right learning rate. But perhaps the most profound consequence is the **universality principle** (theorem `ntk_universality`): two completely different network architectures that happen to produce the same NTK matrix will have identical training dynamics. A convolutional network and a transformer, if their tangent kernels coincide, will learn exactly the same function from the same data.

This means that the NTK is the *sufficient statistic* of the architecture for training purposes. In the infinite-width limit, the details of how you wire up your neurons — skip connections, attention heads, pooling layers — all collapse into a single object: the kernel. Understanding kernels is understanding training.

## The Perturbation Question

Of course, real networks don't live in the infinite-width idealization. They have finite (though often enormous) width, and their kernels do change during training — just a little. The perturbation analysis (theorem `ntk_single_step_perturbation`) quantifies exactly what happens when the kernel drifts: the difference between dynamics under kernel *K₁* versus kernel *K₂* is:

**(I - ηK₁)u - (I - ηK₂)u = η(K₂ - K₁)u**

This linear relationship means that small kernel perturbations produce proportionally small deviations. The "lazy training" regime — where the kernel stays approximately constant — is not a fragile knife-edge but a robust basin of attraction.

## What This Means for the Future of AI

The NTK theory has done something remarkable: it has provided a complete, rigorous mathematical framework for understanding a phenomenon — neural network training — that was previously understood only empirically. It provides a complete mathematical framework for understanding when and why training succeeds, makes precise predictions about generalization, and connects the mysterious world of deep networks to the well-understood theory of kernel methods.

But it also has limits. The infinite-width regime describes networks that are "lazy learners" — they don't learn new features during training. Real networks, especially modern large language models, clearly do learn features. The frontier of research lies in understanding the transition from the kernel regime (where the NTK governs everything) to the "rich" or "feature learning" regime (where the kernel evolves substantially during training). This transition, governed by the ratio of network width to training time, is where the most interesting behavior lives.

The mathematical foundations laid here — residual iteration, contraction bounds, spectral analysis, perturbation theory — provide the rigorous scaffold on which this deeper understanding will be built. Every advance in understanding why neural networks learn begins with the observation that, at their core, they are kernel machines that have forgotten they are kernel machines.

## A Bridge Between Worlds

Beyond its practical implications, the NTK sits at a remarkable crossroads of mathematics, connecting disciplines that rarely speak to each other. It connects:

- **Linear algebra** (matrix iteration, spectral theory) to **optimization** (gradient descent convergence)
- **Kernel methods** (reproducing kernel Hilbert spaces) to **neural networks** (parameterized function approximation)
- **Random matrix theory** (kernel at random initialization) to **probability** (concentration in high dimensions)
- **Functional analysis** (operator theory) to **machine learning** (generalization bounds)

What started as an empirical observation — "wide networks train easily" — has been transformed into a precise mathematical theory with clean definitions, sharp theorems, and rigorous proofs. The kernel was always there, hidden in the gradients, waiting to be found.

## Looking Ahead

The NTK story is far from over. Several frontier questions remain tantalizingly open. Can we make the convergence rate *explicit* — computing the exact number of training steps needed from the kernel's eigenvalues alone? Can we formalize the width-dependent stability bound, showing that the kernel perturbation is *O(1/√m)* for networks of width *m*? Can we extend the theory to multi-output networks, where the kernel becomes a block matrix?

Perhaps most importantly, can we characterize the *boundary* between the lazy regime and the feature-learning regime? The NTK theory tells us what happens when networks are wide enough to stay lazy. But the most powerful models in practice — large language models, protein structure predictors, image generators — seem to operate in a richer regime where features evolve during training. Understanding that transition, with the same level of mathematical rigor that the NTK theory brings to the lazy regime, is one of the great open challenges in the mathematics of artificial intelligence.

The foundation is laid. The kernel has been found, its properties proved, its convergence guaranteed. Now the real work begins: understanding what happens when the kernel wakes up.
