# When Computers Make Mistakes: The Mathematics of Almost-Right Orbits

## How a 50-year-old idea from chaos theory now certifies that AI learns correctly

---

Every time you ask a smartphone to navigate from home to work, a weather model to forecast tomorrow's rain, or a neural network to recognize a face, the answer arrives through billions of tiny arithmetic steps. And every single one of those steps is slightly wrong.

Computers don't do exact arithmetic. They round. They truncate. They approximate. The number π becomes 3.14159265358979... and then stops. The square root of two becomes a string of digits that ends, somewhere, prematurely. These errors are individually microscopic — often smaller than one part in a quadrillion. But they accumulate. Step after step, error upon error, the computed answer drifts away from the "true" mathematical answer like a ship pushed by an invisible current.

For decades, this was one of the deepest anxieties in computational science. Can we trust long simulations? If we simulate a planet's orbit for a million years with tiny rounding errors at each step, does the computed orbit bear any resemblance to the real one? If a neural network takes a million steps of noisy gradient descent, does it end up anywhere near where exact optimization would have taken it?

The answer, it turns out, is a resounding — and quantifiable — *yes*. And the mathematics behind this assurance is surprisingly beautiful.

## The Shadow on the Wall

In the 1970s, mathematicians studying chaotic dynamical systems — systems like weather, turbulent fluids, and the three-body problem — discovered something remarkable. They called it the **shadowing lemma**.

Imagine you're computing the orbit of a point under some rule: take a point, apply a function, get a new point, apply the function again, and so on forever. Because of rounding errors, what you actually compute isn't a true orbit — it's a *pseudo-orbit*, a sequence where each step is only approximately correct. The shadowing lemma says: if the function behaves nicely enough, then somewhere nearby there exists a genuine orbit — a *shadow* — that follows your pseudo-orbit faithfully at every single step.

The pseudo-orbit is the silhouette. The shadow is the real object casting it.

What makes this profound is the quantitative guarantee. If your per-step error is δ and the function contracts distances by a factor L < 1, then the shadow stays within distance δ/(1−L) of your computed trajectory. Forever. Not approximately forever, not probably forever — *forever*, with a hard mathematical bound.

## Contraction: The Universe's Favorite Stabilizer

The key ingredient is *contraction*. A function is a contraction if it brings points closer together. Think of it like kneading dough: each fold-and-press reduces the distance between any two raisins embedded in the dough. After enough kneading, all the raisins are clustered together regardless of where they started.

Contractions are everywhere in applied mathematics. Gradient descent on a strongly convex loss function — the workhorse algorithm behind virtually all modern AI training — is a contraction. Newton's method for finding roots is a contraction (near the solution). The iterative algorithms that solve systems of linear equations in engineering simulators are contractions.

The new results extend the classical shadowing lemma in three directions that matter for modern computation.

## First Discovery: Structural Stability

What if you don't just have rounding errors in the *computation*, but also errors in the *function itself*? This is the situation in virtually all real-world computing: the mathematical model is itself an approximation of reality. The weather model approximates fluid dynamics. The neural network loss function approximates true generalization error. The engineering simulator approximates actual physics.

The structural stability theorem says: if your approximate function g stays uniformly close to the true function f (within distance ρ), then pseudo-orbits of g are still shadowed by true orbits of f. The price is that the shadowing radius inflates from δ/(1−L) to (δ+ρ)/(1−L). The model error ρ and the computational error δ combine *additively*, not multiplicatively — they don't amplify each other catastrophically. This is much better than anyone had a right to hope.

## Second Discovery: Gradient Descent Is a Pseudo-Orbit

Here's where the mathematics meets artificial intelligence. When you train a neural network using stochastic gradient descent (SGD), you're not computing the true gradient at each step. Instead, you estimate it from a random mini-batch of data. This introduces noise — typically bounded noise — at every step.

This is exactly a pseudo-orbit. The "true" dynamical system is exact gradient descent (using the full dataset). The noisy SGD trajectory is a pseudo-orbit with per-step error σ equal to the noise magnitude. The shadowing theorem immediately certifies that the SGD trajectory tracks the exact gradient descent path within distance σ/(1−L), where L is the contraction rate determined by the loss function's curvature.

This provides a new lens on why SGD works so well in practice. It's not that the noise doesn't matter — it's that the noise is *shadowed*. There's always a nearby exact trajectory that the stochastic one is faithfully following. The noise shakes the trajectory but never tears it away from a genuine mathematical solution path.

## Third Discovery: Composable Certificates

Perhaps the most practically important innovation is the idea of *shadowing certificates*. Instead of just proving that shadows exist in the abstract, the new theory packages the proof into a concrete computational object: a certificate that contains the pseudo-orbit, its shadow, and the mathematical guarantee of closeness.

These certificates *compose*. If you've certified that segment A of a computation is shadowed, and separately certified that segment B is shadowed, you can glue the certificates together with a precisely bounded error at the junction. This enables modular certification of long computations: verify each piece independently, then assemble the global guarantee.

The boundary mismatch between two composed certificates is bounded by the sum of their individual shadowing radii — a clean, predictable error accumulation law.

## The Optimal Bound

Is the shadowing radius δ/(1−L) the best possible? Or is it a loose upper bound that could be tightened?

The mathematical analysis reveals that this bound is *tight*. There exist pseudo-orbits — specifically, the constant-shift pseudo-orbit where each step adds exactly δ to the true orbit's image — whose distance from any true orbit converges to exactly δ/(1−L). The bound cannot be improved in general.

This is satisfying mathematically and practically important: it means the guarantee isn't conservative. When the theory says "your computation is within ε of a true solution," it means ε and not 10ε or 100ε.

## Forgetting and Convergence

Under a contraction, errors don't just stay bounded — they *decay*. The distance between two orbits starting at different points shrinks exponentially: after n steps, the distance is at most L^n times the initial distance. This is the mathematical expression of a deep physical principle: contractive systems *forget their initial conditions*.

When combined with the shadowing lemma, this yields a powerful convergence result. If the true dynamical system has a fixed point (as gradient descent converging to a minimum does), then the shadow orbit approaches this fixed point with a combined bound: L^n times the initial distance plus δ/(1−L). The first term decays exponentially to zero. The second term is the irreducible noise floor. The shadow orbit converges to within δ/(1−L) of the fixed point, regardless of where it started.

## Looking Forward

These results open several compelling research directions. The most ambitious is extending shadowing theory to *hyperbolic* systems — the regime of genuine chaos, where the dynamics simultaneously stretch in some directions and compress in others. The classical Anosov-Bowen shadowing theorem handles this case, but formalizing it requires stable and unstable manifold theory that remains a grand challenge.

More immediately, the connection to machine learning suggests applying shadowing theory to certify not just gradient descent but MCMC sampling algorithms (used in Bayesian statistics), reinforcement learning trajectories, and the training dynamics of large language models. Each of these involves a contractive or partially contractive iteration perturbed by noise — exactly the setting where shadowing provides guarantees.

The mathematics of almost-right orbits turns out to be the mathematics of trustworthy computation. In an age where algorithms make decisions affecting billions of lives, having rigorous guarantees that computational approximations track genuine mathematical solutions isn't just elegant — it's essential.

---

*The research described in this article establishes rigorous mathematical foundations for orbit shadowing in discrete dynamical systems, with applications to certified numerical dynamics and machine learning convergence theory.*
