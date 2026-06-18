# The Hidden Geometry of Computation: Energy Landscapes and the Boundaries of What Machines Can Do

## A potential function lurking inside every calculation

Imagine dropping a marble onto a curved surface. The marble rolls, accelerates, and eventually settles — or doesn't — depending on the shape of the terrain. Now imagine that this terrain isn't a physical landscape but a *mathematical* one, and the marble isn't a ball but a computation unfolding step by step.

This is the core insight behind a new body of work connecting the geometry of a deceptively simple function to fundamental questions about what computers can and cannot do efficiently. The function in question is:

$$f(x) = e^x - \ln x - 1$$

It looks innocent enough — just the exponential minus the logarithm, shifted down by one. But this function, which arises naturally from the interplay of the two most important transcendental operations in mathematics, possesses a remarkable collection of properties that make it a natural "potential energy" for computational processes.

## The valley that never flattens

The first surprise is that this potential has a hard floor. For every positive value of *x*, the function *f(x)* is always at least 1. Not approximately. Not asymptotically. *Always*. This is the kind of result that sounds obvious until you try to prove it rigorously — it requires the subtle interplay of two classical inequalities: the fact that $e^x \geq x + 1$ for all real numbers, and the fact that $\ln x \leq x - 1$ for all positive reals.

This universal lower bound means that the EML potential defines a landscape with no escape to zero. Any computation modeled as motion in this landscape carries an irreducible "energy cost" — a mathematical echo of the physical principle that you can't get something for nothing.

The result extends to a full *positive energy theorem*: when you add kinetic energy (the energy of motion through the landscape, measured by a natural Riemannian metric $g(x) = e^x + x^{-2}$), the total energy $E = K + f$ is always at least 1. A computation in motion through this landscape always carries at least one unit of energy. There is no way to coast for free.

## The shape of inevitability

But the story gets richer. The potential $f(x)$ isn't just bounded below — it's *convex* on the positive reals. Convexity is the mathematician's way of saying the landscape curves upward everywhere, like the inside of a bowl. Any straight-line path between two points on the surface lies above the surface itself.

Proving this convexity requires computing the second derivative of $f$ and showing it's always non-negative. The second derivative turns out to be $e^x + 1/x^2$ — a sum of two terms that are each individually non-negative. The exponential is always positive, and the reciprocal square is always non-negative. Their sum can never dip below zero.

Convexity has profound consequences. It means the potential has no local minima other than the global one. There are no "traps" — no deceptive valleys that might lure a computation into a dead end. In optimization language, any local solution is a global solution. In computational language, greedy descent always leads to the right answer.

## Orbits that always climb

Perhaps the most striking result concerns what happens when you iterate the natural map $x \mapsto e^x - \ln x$. This map takes a point in the landscape and sends it to a new point determined by the same exponential-logarithm interplay that defines the potential. The theorem states that the potential *strictly increases* along these orbits:

$$f(e^x - \ln x) > f(x) \quad \text{for all } x > 0$$

This is an orbit growth theorem — each iteration of the map pushes the system to a higher energy state. The computation doesn't settle; it escalates. In the language of dynamical systems, there are no periodic orbits; in the language of computation, certain natural iterative processes are guaranteed to diverge.

The proof is delicate, requiring careful bounds on the exponential function and the logarithm, combined with nonlinear arithmetic. The key intermediate step shows that the iterated point $y = e^x - \ln x$ always exceeds 1, which then unlocks the chain of inequalities needed to establish the strict increase.

## From continuous landscapes to discrete machines

The second strand of this work takes a sharp turn from the continuous to the discrete. Here, the objects of study are not smooth functions but *lambda calculus terms* — the atoms of computation in the foundational theory of computer science.

Lambda calculus, invented by Alonzo Church in the 1930s, reduces all of computation to three operations: naming a variable, applying one function to another, and abstracting a variable to create a new function. Every program ever written, every algorithm ever conceived, can be expressed in this austere notation. The fundamental operation is *beta-reduction*: replacing a function application $(\lambda x. M)N$ with the result of substituting $N$ for $x$ in $M$.

Beta-reduction can go on forever — some computations never terminate. But what if we impose a budget? What if we say: "You have exactly *d* steps of beta-reduction. Show me everything you can reach"?

This is the idea of *bounded reachability*. Given a starting term $t$ and a depth bound $d$, the set of all terms reachable within $d$ beta-reduction steps forms a finite transition system — a directed graph with a distinguished starting node and edges for each reduction step. This finite system is an exact window into the first $d$ steps of a potentially infinite computation.

## The algebra of finite windows

The bounded reduct systems have beautiful structural properties. First, bounded reachability is *monotone*: if you can reach a term in $d_1$ steps, you can certainly reach it in $d_2 \geq d_1$ steps. The window only grows as you increase the budget.

Second, every term reachable within the budget is *beta-equivalent* to the original — it represents the same computation, just partially evaluated. The window preserves meaning.

These systems can be organized into *finite transition systems* (FTS) — abstract machines with states, transitions, and a starting state. The natural notion of equivalence between such machines is *bisimulation*: two systems are bisimilar if there exists a relation between their states that preserves the transition structure in both directions. If system A can take a step, system B can match it, and vice versa.

Bisimulation is the gold standard of process equivalence in computer science. Two bisimilar systems are indistinguishable by any observation you can make. The work proves that bisimilarity is reflexive, symmetric, and transitive — it is a genuine equivalence relation on finite transition systems. This means we can quotient the space of computational processes by bisimilarity and study the resulting equivalence classes.

## Seeing with modal eyes

To observe these finite machines, the framework introduces *modal logic* — a logic augmented with a "diamond" operator ◇ that expresses possibility. The formula ◇φ holds at a state if there *exists* a successor state where φ holds. This is the logic of branching possibility, of "what could happen next."

Each modal formula has a *depth* — the maximum nesting of diamond operators. A formula of depth *d* can only "see" *d* steps into the future. This creates a natural hierarchy: deeper formulas make finer distinctions between states, shallower formulas see only coarse-grained behavior.

The connection to bounded beta-reduction is immediate: a modal formula of depth *d* can distinguish exactly those computational behaviors that differ within *d* steps. The bounded reduct system at depth *d* contains precisely the information needed to evaluate all modal formulas of depth at most *d*.

## The bridge

What connects the continuous energy landscape to the discrete world of bounded computation? The potential $f(x) = e^x - \ln x - 1$ provides a *measure of computational complexity* — a way to assign a real-valued "cost" to computational states that respects the structure of computation. The convexity ensures that this cost function is well-behaved; the positive energy theorem ensures it is bounded away from zero; the orbit growth theorem ensures that certain computational processes always increase in cost.

Meanwhile, the bounded beta-reduction framework provides the *finite approximations* that make these ideas computable. Instead of reasoning about infinite computations, we can work with finite windows and use modal logic to state precisely what we can observe.

Together, these results form the mathematical infrastructure for a new approach to proof complexity — the study of how hard it is to prove mathematical theorems. If we can model proof systems as transition systems and measure their complexity using energy landscapes, we open a path toward understanding the most fundamental question in computer science: the relationship between finding solutions and verifying them.

The marble is rolling. The landscape is charted. The computation continues.
