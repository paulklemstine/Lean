# The Hidden Simplicity of How Neural Networks Learn

## A surprising bridge between calculus, linear algebra, and machine learning

Train a modern neural network and you set in motion a staggeringly complicated
process. Millions — sometimes billions — of numerical knobs, called *parameters*,
are nudged a tiny amount at every step, each adjustment rippling through a tangle
of nonlinear functions. It looks like chaos. It looks like the kind of thing no
human could ever predict.

And yet, over the last few years, mathematicians and machine-learning theorists
have discovered something almost magical: when a network is wide enough, this
apparent chaos collapses into a clean, classical piece of mathematics. The
learning process stops behaving like a wild nonlinear beast and starts behaving
like a single matrix being applied over and over again. The whole story of
training — whether it converges, how fast, and to what — gets governed by one
object: a symmetric matrix called the **Neural Tangent Kernel**, or NTK.

This article is about that bridge. It is the story of how the most intimidating
object in modern AI turns out, in the right regime, to be a problem you could
have solved in a linear algebra course. And it is the story of a set of results
that have been pinned down so precisely that every step can be checked, line by
line, with no room for hand-waving.

## The picture: learning as a downhill walk

Start with the basic idea of how a network learns. We have a model — call it
`f` — that takes some parameters `θ` (the knobs) and an input `x` (say, an image),
and produces a prediction `f(θ, x)`. We have training data: inputs
`x₁, …, xₙ` with desired answers `y₁, …, yₙ`. We measure how wrong the model is
with a loss, the classic choice being the squared error

  L(θ) = ½ Σᵢ ( f(θ, xᵢ) − yᵢ )².

Training is just rolling downhill on this loss surface. At each step we compute
the gradient — the direction of steepest increase — and take a small step in the
opposite direction, scaled by a *learning rate* `η`:

  θ ← θ − η ∇L(θ).

So far this is honest, full, nonlinear training. The trouble is that `f` is a
deeply nonlinear function of `θ`, so the loss surface is a wrinkled, high-
dimensional landscape, and there's no obvious reason the walk should end
anywhere good.

## The linearization trick

Here is the key move. Suppose we don't wander far from where we started. Call the
starting parameters `θ₀`. If we only ever take small steps and stay close to
`θ₀`, then a first-year calculus idea applies: near a point, any smooth function
looks like its tangent line. Replace `f` by its first-order Taylor expansion
around `θ₀`:

  f_lin(θ, x) = f(θ₀, x) + J(θ₀, x) · (θ − θ₀).

Here `J(θ₀, x)` is the **Jacobian** — the vector of partial derivatives of the
prediction with respect to each parameter, evaluated at the starting point. The
crucial feature of `f_lin` is that it is *linear* in the parameters `θ`. The
wrinkled landscape has been flattened into a simple bowl.

This is not just a convenient fiction. In the "wide network" or *lazy training*
regime — networks with enormous numbers of parameters — it has been shown that
the real network barely moves away from `θ₀` during training, so this linear
approximation is extraordinarily accurate. The network trains as if it were its
own tangent line.

## Enter the kernel

Now watch what happens to the *residual* — the vector of current errors,
`uᵢ = f_lin(θ, xᵢ) − yᵢ`. We can ask: how does this error vector change after one
step of gradient descent? When you grind through the algebra of the linearized
model, something beautiful drops out. The new residual is

  u' = u − η · K · u,

where `K` is a single fixed `n × n` matrix built entirely from the Jacobians at
the starting point:

  K_{ij} = Σ_k J(θ₀, xᵢ)_k · J(θ₀, xⱼ)_k = ⟨∇f(xᵢ), ∇f(xⱼ)⟩.

This matrix `K` is the **Neural Tangent Kernel**. Its entry in row `i`, column `j`
is the inner product (the dot product) between the gradient of the prediction at
training point `i` and the gradient at training point `j`. It measures how
"aligned" the network's sensitivities are at different data points.

The headline is this: in the linearized regime, the entire training dynamics
reduce to repeatedly applying the simple operator `I − ηK` to the error vector.
The kernel `K` never changes. This is the formalized statement that *the kernel is
constant along the training trajectory* — the mathematical heart of lazy training.
After `t` steps, the error is exactly

  u_t = (I − ηK)^t · u₀.

Training has become a power iteration. The wild nonlinear beast is, in this
regime, just one matrix raised to a power.

## Why the kernel is so well-behaved

A matrix that comes out of nowhere could do anything. But `K` is not an arbitrary
matrix — it is a **Gram matrix**, the matrix of all pairwise inner products of a
collection of vectors (here, the gradient vectors). Gram matrices are some of the
nicest objects in linear algebra, and they have two properties that make the
whole convergence story work.

**First, `K` is symmetric.** Because the dot product doesn't care about order,
`⟨∇f(xᵢ), ∇f(xⱼ)⟩ = ⟨∇f(xⱼ), ∇f(xᵢ)⟩`, so `K_{ij} = K_{ji}`. Symmetry is what lets
us talk about `K`'s eigenvalues as real numbers and decompose its action into
independent one-dimensional modes.

**Second, and most importantly, `K` is positive semidefinite.** This means that
for *any* vector `v`, the quantity `vᵀ K v` is never negative. The reason is a tiny
gem of an argument. Writing `K = Φ Φᵀ` where `Φ` stacks up the gradient vectors,
we get

  vᵀ K v = vᵀ Φ Φᵀ v = ‖Φᵀ v‖² ≥ 0.

A quadratic form turns into a sum of squares, which can never be negative. This
single inequality is the structural guarantee that gradient descent on the kernel
won't blow up: there are no negative eigenvalues to send the error spiraling off
to infinity. Every "mode" of the error either shrinks or holds steady, never
grows uncontrollably (provided the learning rate is sane).

## Convergence, made rigorous

Once you know `u_t = (I − ηK)^t u₀` and you know `K` is symmetric and positive
semidefinite, convergence is within reach. Suppose the update operator `I − ηK` is
**contractive** with some constant `c < 1`, meaning it shrinks every vector by at
least the factor `c`:

  ‖(I − ηK) v‖ ≤ c · ‖v‖ for all `v`.

Then a clean induction shows the error decays *geometrically*:

  ‖u_t‖ ≤ c^t · ‖u₀‖.

Each step multiplies the worst-case error by `c`, so after `t` steps it has been
multiplied by `c^t`, which races to zero. This is exponential convergence — the
gold standard. The network's error doesn't just shrink; it shrinks faster and
faster on a logarithmic scale.

There is also a precise statement of *what* the network converges to. A fixed
point of training — a residual `u` that one gradient step leaves unchanged — must
satisfy `K u = 0` (assuming a positive learning rate). In words: training stops
exactly when the error vector lies in the null space of the kernel. If `K` is
strictly positive definite (no null space except zero), the only fixed point is
zero error: the network perfectly interpolates its training data. Convergence and
interpolation are two sides of the same coin.

## The contractivity constant, and where the real depth lies

Everything above hangs on that contractivity constant `c`. In the elementary
theory, `c` is taken as a given — a black box. But it is not really a black box,
and opening it reveals where the spectrum of `K` enters the story.

The operator `I − ηK` is diagonal in any eigenbasis of `K`: along an eigenvector
with eigenvalue `λ`, it acts as pure multiplication by the scalar `1 − ηλ`. So the
error decomposes into independent modes, and each mode is multiplied by `1 − ηλ`
every step. A mode is stable — it shrinks — exactly when `|1 − ηλ| < 1`, which is
the clean scalar window `0 < ηλ < 2`. The overall contractivity constant is
`c = maxᵢ |1 − ηλᵢ|`, the worst case over all eigenvalues.

This immediately tells you how to pick the best learning rate. If the eigenvalues
of `K` range from a smallest `μ > 0` to a largest `L`, the two extreme modes pull
in opposite directions: too large an `η` destabilizes the big-eigenvalue mode, too
small an `η` barely moves the small-eigenvalue mode. The sweet spot balances them
at

  η* = 2 / (μ + L),

where both extremes contract by exactly `(L − μ) / (L + μ)` — one minus the
inverse of the *condition number* `L/μ`. Well-conditioned kernels (eigenvalues
all similar) train fast; ill-conditioned kernels (a huge spread of eigenvalues)
crawl. This is the same condition-number law that governs every iterative linear
solver, reappearing in the heart of deep learning.

## Universality: the architecture disappears

Perhaps the most philosophically striking consequence is **universality**. Notice
that everything we said depends only on the matrix `K` and the learning rate `η`.
The specific architecture — how many layers, what activation functions, the exact
wiring — enters *only* through how it shapes `K`. Two completely different networks
that happen to produce the same NTK will have *identical* training trajectories,
step for step.

This is a remarkable inversion of how we usually think about deep learning. We
obsess over architecture. But in the lazy regime, the architecture is just a
machine for manufacturing a kernel. Once the kernel is fixed, the learning is
fixed. The network's identity dissolves into a single symmetric matrix.

## What stays robust when the kernel wobbles

Real networks aren't perfectly linear, and the NTK does drift a little during
training. So a natural question is: if we run training with a slightly wrong
kernel, how far do we end up from where we should be? The single-step answer is
exact and reassuringly simple. The difference between one step driven by kernel
`K₁` versus kernel `K₂` is precisely

  (I − ηK₁) u − (I − ηK₂) u = η (K₂ − K₁) u.

The error introduced in one step is just the kernel discrepancy, scaled by the
learning rate, applied to the current residual. Small kernel errors produce
small trajectory errors, and they accumulate gracefully — controllably — over
many steps. This is the stability backbone of the whole "approximately lazy"
picture: the infinite-width limit is an idealization, but finite, very wide
networks stay close to it.

## Why pin this down so precisely?

It is one thing to sketch these arguments on a whiteboard. It is another to
insist that every inequality, every algebraic identity, every induction is
correct beyond any doubt. The results described here have been verified at that
level of rigor: the positive-semidefiniteness of the kernel, the power-iteration
formula for the residual, the geometric decay under contractivity, the fixed-
point characterization, the constancy of the kernel in the linearized model, the
single-step perturbation identity, and universality. Each is a precise theorem
with a complete, checkable proof.

Why does this matter beyond tidiness? Because deep learning is increasingly
deployed where mistakes are expensive — medicine, finance, infrastructure. The
intuitions of the field are powerful but informal, and informal intuitions
occasionally hide bugs. Turning the core of NTK theory into airtight mathematics
does two things. It confirms that the beautiful informal story is actually true
in the regime where it's claimed. And it builds a foundation on which sharper,
more quantitative results — exact convergence rates from eigenvalues, optimal
learning-rate schedules, width-dependent stability bounds — can be erected with
the same certainty.

## The bridge

The deepest pleasure here is the bridge itself. On one side stands modern machine
learning: empirical, sprawling, GPU-hungry, often more art than science. On the
other side stands classical mathematics: Gram matrices, quadratic forms,
eigenvalues, power iteration, condition numbers — ideas that predate computers by
a century. The Neural Tangent Kernel is the span that connects them.

It says that beneath the bewildering surface of training a giant network lies a
piece of mathematics so clean you could teach it to an undergraduate: a symmetric
positive-semidefinite matrix, applied over and over, contracting an error vector
geometrically toward zero. The chaos was never really chaos. It was linear
algebra wearing a very convincing disguise — and now we can prove it.
