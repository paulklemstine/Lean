# When Neural Networks Freeze: Learning at Absolute Zero

## A tale of two arithmetics

Imagine a version of arithmetic where you never multiply and you never really add. Instead, "adding" two numbers means *taking the larger one*, and "multiplying" them means *adding them in the ordinary sense*. So

$$3 \oplus 5 = \max(3,5) = 5, \qquad 3 \odot 5 = 3 + 5 = 8.$$

This is the **max-plus** or **tropical** semiring. It looks like a party trick, but it obeys most of the laws you expect: $\oplus$ and $\odot$ are commutative and associative, $\odot$ distributes over $\oplus$, the number $-\infty$ acts as zero and $0$ acts as one. What it lacks is subtraction — you cannot undo a maximum.

A *tropical polynomial* in one variable is what you get by writing an ordinary polynomial in this arithmetic:

$$p(x) = c_0 \oplus (a_1 \odot x) \oplus (a_2 \odot x^{\odot 2}) \oplus \cdots = \max\{c_0,\; a_1 + x,\; a_2 + 2x, \dots\}.$$

In plain language: a tropical polynomial is a **maximum of finitely many straight lines**. Its graph is a convex, piecewise-linear curve with a finite number of kinks. A *tropical rational function* is a difference $p(x) - q(x)$ of two such maxima; dropping the convexity, these are exactly the piecewise-linear functions with finitely many pieces.

Now hold that thought and look at a modern neural network. Strip away the mystique and a ReLU network is a machine built from three moves: affine maps $x \mapsto ax+b$, additions, scalings, and the rectifier $\mathrm{relu}(u) = \max(u,0)$. Every one of these operations is *piecewise linear*. The network is a piecewise-linear function pretending to be smooth.

The story of this article is that the pretence can be dropped entirely, that when you drop it the training problem becomes visibly *combinatorial*, and that the combinatorics tells you exactly how fast learning can go.

## Freezing the network

Consider a soft aggregator — the thing hiding inside softmax attention, inside log-partition functions, inside the "exp–log" units that appear whenever a model has to blend several alternatives:

$$\mathrm{LSE}_T(u_1,\dots,u_k) = T \log\!\left(e^{u_1/T} + \cdots + e^{u_k/T}\right).$$

Here $T > 0$ is a temperature; equivalently, $s = 1/T$ is the overall scale of the weights. At $T=1$ this is the familiar log-sum-exp: a smooth, differentiable blend. As $T \to 0^{+}$ — the *large-weight limit* — something clean happens. The largest term overwhelms the others and the blend collapses to a choice:

$$\mathrm{LSE}_T(u_1,\dots,u_k) \longrightarrow \max(u_1,\dots,u_k).$$

This collapse has a name, **Maslov dequantization**, and it is more than a limit: it is an inequality with a rate. Writing $M = \max_i u_i$, one checks that $e^{M/T}$ is one of the $k$ summands, so the sum is at least $e^{M/T}$; and every summand is at most $e^{M/T}$, so the sum is at most $k\,e^{M/T}$. Taking $T\log(\cdot)$ of both bounds gives, exactly,

$$\max_i u_i \;\le\; \mathrm{LSE}_T(u_1,\dots,u_k) \;\le\; \max_i u_i \;+\; T\log k .$$

**The Dequantization Theorem.** *A smooth exp–log unit and its tropical shadow never differ by more than $T \log k$, where $k$ is the number of terms — uniformly in the inputs. In particular, as the temperature falls to zero (equivalently, as the weights are scaled up without bound), the smooth unit converges to the max-plus unit.*

Two features of this bound deserve emphasis. First, it is *uniform*: the same $T\log k$ works at every input $x$, so an entire neuron $x \mapsto \mathrm{LSE}_T(a_1x+b_1, \dots, a_kx+b_k)$ is within $T\log k$ of the tropical polynomial $\max_i (a_i x + b_i)$ everywhere on the real line. Second, the dependence on the size of the layer is only *logarithmic*. A layer with a thousand units at temperature $10^{-3}$ is within about $0.007$ of its tropical shadow, everywhere.

So: at low temperature, the network *is* a tropical object, to a controlled error. The question is what happens when you train it there.

## The dictionary

Before training, we should know exactly which functions live in the frozen world. The answer is a clean equivalence.

**The Tropical–ReLU Dictionary.** *A function $f:\mathbb{R}\to\mathbb{R}$ is a tropical rational function — a difference of two finite maxima of affine functions — if and only if it is computed exactly by some feed-forward network of rectifier units of arbitrary depth built from affine maps, sums, scalar multiples and $\mathrm{relu}$.*

Neither direction is a soft existence argument; both are constructions.

Going from networks to tropical functions is an induction on the structure of the network. Affine maps are tropical rational. Sums and differences of tropical rational functions are tropical rational (add numerators and denominators crosswise, exactly as with ordinary fractions). Scalar multiples are, too, with a twist: multiplying by a *negative* scalar swaps the roles of the two maxima, because $c\max(u,v) = \min(cu,cv)$ when $c<0$, and $\min$ is expressible as a difference. Finally, $\mathrm{relu}(f) = \max(f,0)$, and the maximum of two tropical rational functions $p_1-q_1$, $p_2-q_2$ is $\max(p_1+q_2,\,p_2+q_1) - (q_1+q_2)$ — a difference of tropical polynomials, because a max of tropical polynomials is a tropical polynomial and so is a sum. The tropical rational functions form a lattice-ordered vector space, and the network can never leave it.

Going the other way is a one-line identity with real consequences:

$$\max(u,v) = v + \mathrm{relu}(u-v).$$

Each extra line in a tropical polynomial costs exactly one rectifier. A tropical polynomial with $k$ monomials is realized by a network with $k-1$ rectifiers, and a tropical rational function $p-q$ by the difference of two such blocks. **The number of tropical monomials is the number of ReLU units.** The abstract algebraic complexity and the concrete architectural cost are the same number.

## The loss landscape is a polytope in disguise

Now we can train. Take the simplest nontrivial frozen model: the max-plus monomial

$$M_\theta(z) = z \odot \theta = z + \theta,$$

a single trainable shift — and fit it to data $(X_i, Y_i)$, $i = 0,\dots,N-1$, under the absolute-error risk

$$R(\theta) = \sum_{i} \bigl| M_\theta(X_i) - Y_i \bigr| = \sum_i |\theta - y_i|, \qquad y_i := Y_i - X_i.$$

The $L^1$ loss is the natural companion of a max-plus model: both are built from the same piecewise-linear vocabulary, and indeed the loss $R$ is *itself* a tropical polynomial in $\theta$ — a maximum of $2^N$ affine functions of $\theta$, one for each choice of signs. Training a tropical model on a tropical loss never leaves the tropical category.

This landscape has no curvature anywhere. It is a stack of straight segments glued at the data points. Classical optimization theory says such landscapes are bad news: for a general non-differentiable convex objective, no first-order method can beat an error of order $1/\sqrt{n}$ after $n$ steps, and the standard subgradient method achieves exactly that. Concretely, running $\theta_{k+1} = \theta_k - \eta\, g(\theta_k)$ with a subgradient $g$ bounded by $G$ and step $\eta = D/(G\sqrt{n})$, where $D$ is the initial distance to the optimum, some iterate before time $n$ has risk within $DG/\sqrt{n}$ of optimal. For our tropical loss the subgradient is a sum of $N$ signs, so $G = N$ exactly, and the guarantee reads $DN/\sqrt{n}$.

That would be the end of the story if the tropical loss were a *generic* nonsmooth convex function. It is not, and the reason is the most beautiful part of this circle of ideas.

## Sharpness: the V-shape that curvature forgot

Order the residuals $y_0 \le y_1 \le \cdots \le y_{2m}$ and let $\theta^\star = y_m$ be the median. Then the following holds for **every** $\theta$:

$$R(\theta) \;\ge\; R(\theta^\star) \;+\; |\theta - \theta^\star| .$$

**The Sharpness Theorem.** *The tropical absolute-error risk grows at least linearly, with constant exactly $1$, as you move away from the median parameter. Consequently the median is a minimizer, and it is the unique one.*

The proof is a lovely pairing argument. Sum the loss against its own reflection $i \mapsto 2m-i$:

$$2R(\theta) = \sum_{i=0}^{2m} \bigl( |\theta - y_i| + |\theta - y_{2m-i}| \bigr).$$

For each $i$, the median $y_m$ lies *between* $y_i$ and $y_{2m-i}$, and for a point $v$ between $u$ and $w$ the elementary inequality $|v-u| + |v-w| \le |\theta-u| + |\theta-w|$ holds for every $\theta$ — the sum of distances to two fixed points is minimized on the segment joining them. So each of the $2m+1$ paired terms is at least as large at $\theta^\star$ as it is at $\theta$... and one of the pairs, the diagonal one $i = m$, contributes exactly $2|\theta - y_m|$ of slack. Keep that single term and discard the rest: $2R(\theta) - 2R(\theta^\star) \ge 2|\theta - \theta^\star|$. Done.

This is the piecewise-linear replacement for strong convexity. A strongly convex function grows *quadratically* away from its minimum; the tropical loss grows *linearly*. Linear growth is a stronger constraint near the optimum, not a weaker one — and it is exactly what a nonsmooth method needs.

## Free lunch: from $1/\sqrt{n}$ to geometric

Sharpness has an immediate consequence: it converts a guarantee about *loss* into a guarantee about *parameters*. If some iterate has risk within $\varepsilon$ of optimal, then by the theorem it lies within $\varepsilon$ of the true median. So the $O(DN/\sqrt{n})$ risk rate is simultaneously an $O(DN/\sqrt{n})$ parameter rate — for free.

But we can do far better. Suppose you know the optimal loss value $R^\star$ (for the median fit, you often do, and if not it can be estimated). Then use the **Polyak step**: instead of a fixed $\eta$, take

$$\theta_{k+1} = \theta_k - \frac{R(\theta_k)-R^\star}{g(\theta_k)^2}\, g(\theta_k),$$

stopping if $g(\theta_k)=0$. The step is self-tuning: far from the optimum the gap $R(\theta_k)-R^\star$ is large and the step is bold; near it, the step vanishes.

**The Geometric Convergence Theorem.** *Let $R$ be convex with a subgradient oracle bounded by $G$, sharp with constant $\mu>0$ at a minimizer $\theta^\star$. Then every Polyak step contracts the squared distance to the optimum:*

$$(\theta_{k+1}-\theta^\star)^2 \;\le\; \Bigl(1 - \frac{\mu^2}{G^2}\Bigr)(\theta_k-\theta^\star)^2,$$

*hence $(\theta_n - \theta^\star)^2 \le (1-\mu^2/G^2)^n (\theta_0-\theta^\star)^2$ and the iterates converge to $\theta^\star$.*

Two ingredients make this work. From convexity, the gap is dominated by the subgradient: $R(\theta)-R^\star \le g(\theta)(\theta-\theta^\star)$, which after expanding the square gives $(\theta_{k+1}-\theta^\star)^2 \le (\theta_k-\theta^\star)^2 - t\,d$ with $d$ the gap and $t = d/g^2$ the step scale. From sharpness, $d \ge \mu|\theta_k-\theta^\star|$, so $t d = d^2/g^2 \ge \mu^2(\theta_k-\theta^\star)^2/G^2$. Subtract. (A pleasant by-product of the same reasoning: the sharpness constant can never exceed the subgradient bound, $\mu \le G$, so the contraction factor is genuinely in $[0,1)$.)

For the tropical fit, $\mu = 1$ and $G = N$, so:

**Linear Rate for Tropical Training.** *With Polyak steps, tropical absolute-error training of a max-plus monomial on $N = 2m+1$ ordered samples satisfies*

$$(\theta_n - \theta^\star)^2 \le \Bigl(1 - \tfrac{1}{N^2}\Bigr)^{n}(\theta_0-\theta^\star)^2 .$$

*The parameter — and hence the trained model, pointwise — converges to the unique tropical rational minimizer.*

Compare: the fixed-step guarantee decays as $n^{-1/2}$; the Polyak rate decays as $e^{-n/(2N^2)}$. To gain a factor of a thousand in accuracy, the first method needs a million times more steps; the second needs about $14 N^2$ more steps.

## The knife's edge: fixed steps can fail forever

It is tempting to imagine that any reasonable step size eventually works. On a piecewise-linear landscape it does not, and the counterexample fits on one line. Take the three samples $0, 1, 2$, whose median is $1$, and run fixed-step subgradient descent from $\theta_0 = 3$ with $\eta = 3$. Away from the data the subgradient has constant magnitude $3$, so the iterate jumps by $9$ every time:

$$3 \;\to\; -6 \;\to\; 3 \;\to\; -6 \;\to\; \cdots$$

an exact two-cycle. Every iterate stays at distance at least $2$ from the optimum, for all time. There is no decay, no averaging that helps, no asymptotic rescue. The `$1/\sqrt{n}$` theorem is not being violated — it *requires* the step to shrink like $1/\sqrt{n}$ — but the example shows that the requirement is real, and that "gradient descent converges to the optimum" is simply false for a fixed step on a tropical loss. The correct statements are the best-iterate bound and the Polyak bound. Sharpness rescues you only if the step rule can exploit it.

## Does the rectifier network do any better?

A natural objection: we analysed a max-plus monomial. Real practitioners train ReLU networks. Do they see a friendlier landscape?

They see the *identical* landscape. Precisely:

**Risk-Landscape Equivalence.** *A one-variable function is tropical rational if and only if there is a rectifier network whose absolute-error empirical risk agrees with it on every finite data set.*

One direction is the dictionary plus the observation that equal functions have equal risks. The other direction is a cunning single-point test: apply the hypothesis to the one-sample data set $X_0 = x$, $Y_0 = f(x)$. The risk of $f$ is zero, so the risk of the network is zero, which forces the network to agree with $f$ at $x$ — and $x$ was arbitrary. Equality of risks on all data sets is therefore equality of functions, and the two hypothesis classes coincide as sets of *landscapes*, not merely as sets of functions.

The moral is deflationary and clarifying. Whatever speed-up you observe when training a piecewise-linear model does not come from the parameterization — from depth, from the rectifier, from any architectural cleverness. It comes from the *geometry of the loss*: the ratio $\mu/G$ between the sharpness constant and the largest slope. That ratio is a combinatorial quantity, computed from which lines are active at the optimum, not from any analytic estimate. The tropical picture makes it visible.

## What freezing teaches us

Step back and the shape of the theory is this. A smooth exp–log network at low temperature is within $T\log k$ of a max-plus network, uniformly. Max-plus networks in one variable are exactly rectifier networks, with an explicit unit-for-monomial translation. Their absolute-error training landscape is a convex piecewise-linear function that is *sharp*, and sharpness — not smoothness, which is absent — is what governs speed. With the right step rule, the ostensibly hostile nonsmooth problem is solved geometrically fast, at a rate written entirely in terms of two tropical invariants: the largest slope and the growth constant.

There is an appealing physical analogy. Statistical mechanics at temperature $T$ is a smooth, blended affair; at $T=0$ the system snaps into its ground state and the free energy becomes a piecewise-linear function of the parameters, whose kinks are phase transitions. Tropical geometry is the mathematics of that zero-temperature limit, and the dequantization bound $T\log k$ is the price of the approximation. A neural network trained with large weights is a system near absolute zero — and the surprise is that the frozen system is not harder to optimize than the warm one. It is easier, because you can finally see the crystal.

The obvious frontier is dimension. In one variable the median argument is exact and the sharpness constant is $1$ on the nose. In $\mathbb{R}^d$, the pairing trick fails for non-separable losses, and the right generalization of $\mu/G$ is a ratio of slopes in the normal fan of a Newton polytope at the optimal vertex — a purely combinatorial object attached to the model's tropical geometry. If that programme succeeds, the convergence rate of first-order training will be computable from a polytope, without a single analytic estimate. That is a strange and rather wonderful prospect: optimization theory replaced by counting the faces of a shape.
