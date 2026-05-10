# The Hidden Geometry of One-Way Streets

*How mathematicians discovered that the cost of going forward is fundamentally different from the cost of going back — and why that matters for everything from cryptography to climate science.*

---

Imagine you're standing at the top of a mountain. Getting down is easy — gravity does most of the work. Getting back up? That's a different story entirely. The energy you need to climb is far greater than what you spent descending.

This simple asymmetry — the difference between going forward and going back — turns out to be one of the most profound ideas in modern mathematics. And a new theoretical framework has just made it precise enough to prove things about it that nobody could prove before.

## The Problem with Ordinary Distance

When you look up the distance from New York to Los Angeles, you get the same answer regardless of direction: about 2,450 miles. That's how most people think about distance — it's symmetric. The mathematical term is a *metric*, and it's been the workhorse of geometry since Euclid.

But the real world isn't symmetric. It costs more energy to pump water uphill than to let it flow down. It takes more computational effort to factor a large number than to multiply its factors. It requires more energy to unscramble an egg than to scramble it in the first place.

In 1973, the American mathematician F. William Lawvere proposed a radical idea: what if distance itself could be one-directional? He defined what's now called a *Lawvere metric* — a way of measuring the "cost" of getting from point A to point B that doesn't have to equal the cost of getting from B to A.

The idea was elegant but largely theoretical. For decades, it sat quietly in the corners of category theory, appreciated by a small circle of specialists but largely unknown to the broader mathematical world.

Until now.

## Two Rivers Converge

Meanwhile, in a completely different part of mathematics, researchers in *optimal transport theory* were solving a problem that would have delighted ancient merchants: what's the cheapest way to move a pile of earth from one shape to another?

The field traces back to the French mathematician Gaspard Monge in 1781, but its modern renaissance began with the Russian mathematician Leonid Kantorovich, who in 1942 discovered something remarkable: instead of directly computing the cheapest transport plan, you could compute the same answer by looking at the problem from the opposite direction.

Kantorovich's insight, called *duality*, says that the cost of the optimal transport equals the maximum "profit" achievable by a certain kind of pricing scheme. The prices — which mathematicians call *1-Lipschitz functions* — can't change too fast relative to the distance between locations. The beauty of duality is that checking whether a pricing scheme is valid is often much easier than finding an optimal transport plan.

What the new framework achieves is a marriage of these two ideas. It proves that Kantorovich's duality theorem works perfectly in Lawvere's asymmetric world — and that this combination unlocks applications that neither theory could reach alone.

## The Bridge Theorem

The central result is deceptively simple to state. Given any system where you can measure the one-way cost of moving between states — whether those states represent chemical compounds, encryption keys, or neural network configurations — the cost of going from state A to state B equals the maximum advantage that any "fair observer" can detect between A and B.

What makes an observer "fair"? They can't report differences between states that exceed the actual cost of transitioning between them. A fair observer looking at two adjacent rooms can report a difference of at most the cost of walking between them.

The theorem proves exact equality: the asymmetric distance is *precisely* the supremum of all fair observable differences. Not approximately, not in some limit — exactly.

And the proof is constructive. It exhibits a specific observer that achieves the maximum: the *Bellman potential*, which assigns to each state its minimum cost of reaching a fixed target. This potential function, borrowed from dynamic programming and tropical geometry, turns out to be the universal optimal witness for Lawvere-Kantorovich duality.

## What the Asymmetry Reveals

The framework introduces a quantity called the *thermodynamic asymmetry index*: the difference between forward and reverse costs. This single number captures something fundamental about irreversibility.

In chemistry, it measures the free energy difference that drives reactions forward. In computation, it measures the inherent difficulty gap between encryption and decryption. In machine learning, it measures how much harder it is to fool a classifier than to verify a classification.

The formalization proves that this asymmetry index is perfectly antisymmetric — swapping the direction negates the value — and that it vanishes precisely for reversible transitions. These aren't deep facts individually, but having them as precise, machine-verified theorems means they can serve as reliable building blocks for much larger arguments.

## Certified Safety

Perhaps the most immediately practical application comes from combining the duality theorem with the concept of *certified robustness* in machine learning.

Modern AI systems are notoriously fragile. A self-driving car's image classifier can be fooled by carefully chosen pixel perturbations invisible to the human eye. The question "how much do you have to change an input before the classifier gives a wrong answer?" is literally a matter of life and death.

The new framework provides a mathematical certificate for this. Given a classifier with a Lipschitz-bounded decision function, the Kantorovich dual witness provides a *provable lower bound* on the minimum perturbation needed to change the classification. If the certificate says an input is robust within a margin of 0.5, then no adversarial perturbation smaller than 0.5 can change the answer. Period.

What makes this particularly powerful in the asymmetric setting is that it naturally captures situations where perturbations are easier in some directions than others — exactly the situation in real-world adversarial attacks, where the attacker has limited computational resources.

## The Convergence Engine

The framework also includes a convergence theory for iterative closure systems — processes that repeatedly apply a refinement operation to approach a fixed point.

Think of image denoising: you start with a noisy image and repeatedly apply a smoothing filter. Or think of a database that's being iteratively made consistent according to business rules. Or think of an optimization algorithm approaching its solution.

The formalization proves that if each step contracts the distance to the solution by a fixed factor c < 1, then after n steps the remaining distance is bounded by D₀ · cⁿ, where D₀ is the initial distance. More importantly, it proves that for any target accuracy ε, there exists a specific number of iterations N that guarantees the result is within ε of the solution.

This isn't surprising to anyone who's studied geometric series, but having it as a formal theorem within the Kantorovich-Lawvere framework means it can be combined with the duality theorem and the certified robustness bounds to produce end-to-end guarantees for complex systems.

## The Tropical Connection

One of the most elegant aspects of the framework is its connection to *tropical geometry* — a relatively young branch of mathematics that replaces ordinary addition and multiplication with minimum and addition.

In tropical geometry, the "shortest path" operation is the fundamental building block, just as ordinary addition is the building block of classical algebra. The derivation cost in the new framework is precisely a tropical shortest-path distance. The Bellman potential that achieves duality is a tropical polynomial. The convergence of closure iterations is a tropical fixed-point theorem.

This connection is more than just a pretty analogy. It means that the entire apparatus of tropical algebraic geometry — including deep results about tropical varieties, tropical intersection theory, and tropical moduli spaces — becomes potentially available as a toolbox for studying closure dynamics and optimal transport.

## Looking Forward

The framework opens several concrete research directions.

First, extending the duality from finite-dimensional distances to full probability measures would connect it to the modern theory of Wasserstein spaces, with applications to generative AI models and statistical inference.

Second, the thermodynamic interpretation suggests connections to quantum information theory, where the asymmetry between quantum channels and their reverses is central to understanding decoherence and error correction.

Third, the lattice attack surface concept provides a new lens for analyzing post-quantum cryptographic security, where the hardness of lattice problems is measured not by worst-case complexity but by the optimal transport cost of reaching a secret key.

What's perhaps most remarkable about this work is how it emerged from the convergence of three seemingly unrelated streams of mathematical thought: Lawvere's enriched category theory, Kantorovich's optimal transport duality, and tropical algebraic geometry. Each was powerful on its own; together, they reveal a unified structure that was always there, waiting to be discovered.

The one-way streets of mathematics turn out to be connected by a highway that runs in both directions — if you know where to look.
