# When Machines Learn to Forget: A New Mathematics of Efficient Computation

## The Cost of Knowing Too Much

Imagine you are navigating a sprawling city with a paper map. Every intersection you pass, every turn you make, adds to your mental model of where you've been. But here's the thing: most of that history is irrelevant. Whether you took Oak Street or Elm Street three miles back doesn't matter if both routes brought you to the same intersection. What matters is where you are *now* and what lies *ahead*.

This simple insight — that the past matters only insofar as it affects the future — is one of the most powerful ideas in the theory of computation. In the 1950s, mathematicians John Myhill and Anil Nerode formalized it into a theorem that became a cornerstone of computer science. Their result says, roughly: for any computational task, there is a unique smallest machine that can perform it, and you find that machine by identifying states that no future input could ever distinguish.

Now, a team of researchers has extended this idea into startling new territory, fusing it with concepts from thermodynamics — the physics of heat, energy, and entropy. The result is a mathematical framework that treats computation not as abstract symbol manipulation, but as a physical process with energy costs, thermal constraints, and an intrinsic notion of "forgetting."

The implications ripple outward from pure mathematics into machine learning, program optimization, and even our understanding of what it means for a physical system to compute.

## Two Worlds Collide

To understand the breakthrough, you need to see two stories converging.

**Story one** comes from automata theory, the branch of mathematics that studies abstract machines. A finite automaton is a device with a fixed number of internal states that processes a sequence of inputs, transitioning from state to state according to fixed rules. Think of a vending machine: it has states like "waiting for coin," "coin inserted," and "dispensing item," and it transitions between them as you insert coins and press buttons.

The Myhill–Nerode theorem tells us that for any behavior you want a machine to exhibit, there is a unique minimal automaton — one with the fewest possible states — that exhibits exactly that behavior. You find it by merging states that are "behaviorally equivalent": states that would produce identical outputs for every possible future sequence of inputs. This is the computational version of Occam's razor: the simplest explanation (machine) that fits the data (behavior) is the canonical one.

**Story two** comes from statistical mechanics, where physicists study systems with enormous numbers of components — gases, magnets, neural networks — using the concept of *free energy*. Free energy is a single number that balances two competing concerns: minimizing energy (the system wants to be in a low-energy state) and maximizing entropy (the system wants to explore as many configurations as possible). The free-energy minimum determines the system's equilibrium — the state it naturally settles into.

The formula is elegant and universal: F = E − TS, where E is energy, T is temperature, and S is entropy. At low temperatures, energy dominates and the system freezes into an ordered state. At high temperatures, entropy dominates and disorder reigns. Free energy finds the sweet spot.

These two stories seem to belong to different universes. One is about abstract machines processing symbols. The other is about physical systems finding equilibrium. But the new work reveals they are two faces of the same mathematical structure.

## The Thermodynamic Automaton

The key innovation is a mathematical object called a *thermodynamic automaton*. Like a classical automaton, it has states, transitions, and inputs. But at each state, it also carries an *observable* — a number computed from a quantity the researchers call "closure entropy."

The term "closure" here is precise and powerful. A closure operator is a mathematical function that "completes" or "saturates" information. Think of it as a filter that rounds your observations to the nearest meaningful category. If you're measuring the temperature of a cup of coffee, closure might mean rounding to the nearest degree — the difference between 71.3°F and 71.7°F is irrelevant for deciding whether to drink it. Closure captures the idea of observing at a particular resolution.

The entropy part measures how much variety exists within a closure class — how many microscopically different states look the same after you apply the closure filter.

Combined with an "inverse temperature" parameter β that controls the energy–entropy trade-off, each state of the thermodynamic automaton carries a free-energy observable: a single number that encodes everything thermodynamically relevant about that state.

## The Breakthrough: A New Myhill–Nerode Theorem

The central result is what the researchers call the **thermodynamic Myhill–Nerode theorem**. It says:

> Two computational histories are the same thermodynamic state if and only if no future experiment can distinguish their free-energy profiles.

This is not a metaphor. It is a precise mathematical theorem with a complete proof. And it has several remarkable consequences.

**First**, the free-energy indistinguishability relation is a *right congruence* — the most important structural property in automata theory. This means that if two histories u and v are thermodynamically equivalent, then for any future input string w, the extended histories u·w and v·w remain equivalent. Equivalence is preserved as computation proceeds. This is what makes the quotient construction possible.

**Second**, the quotient — the machine obtained by merging thermodynamically equivalent states — is finite and unique. It has the fewest states of any machine that exhibits the same free-energy behavior. And its state count equals a quantity the researchers call the "Gibbs–Hankel generator rank," which measures the tropical-algebraic complexity of the system's observation matrix.

**Third**, and most remarkably, the minimization commutes with closure saturation. This means that two natural operations — simplifying the machine (merging equivalent states) and coarsening the observations (applying a stronger closure filter) — can be performed in either order with the same result. Simplification and coarse-graining are compatible, a fact that is far from obvious and requires careful proof.

## Why "Tropical"?

Throughout this work, the underlying algebra is not ordinary arithmetic but *tropical mathematics*. In tropical arithmetic, addition is replaced by the "min" operation (find the smaller of two numbers), and multiplication is replaced by ordinary addition. This sounds bizarre, but it arises naturally whenever you're optimizing: if you want the cheapest route between two cities, you take the minimum over paths (tropical addition) and add up edge costs along each path (tropical multiplication).

Tropical mathematics has deep connections to algebraic geometry, optimization, and phylogenetics. In this work, it provides the algebraic framework for free energy: the free-energy observable naturally lives in a tropical (or "idempotent") semiring, where the variational principle of thermodynamics — minimize free energy — becomes a structural feature of the algebra rather than an external optimization.

The Gibbs–Hankel semimodule — the tropical analogue of the classical Hankel matrix used in system identification — captures the full behavioral fingerprint of the automaton. Its generator rank (the tropical analogue of matrix rank) equals the number of thermodynamic states. This is the equation that crystallizes the entire theory:

**Thermodynamic complexity = tropical linear complexity.**

## A Conservation Law for Computation

One unexpected consequence of the theory is a conservation-type result for optimal computations. The researchers prove that all optimal paths of the same length — the computations that minimize free energy — share a common "dissipation class." In physical terms, optimal computations all dissipate the same amount; you cannot reduce dissipation by cleverly rearranging the computation steps.

This is reminiscent of Noether's theorem in physics, which connects symmetries to conservation laws (the symmetry of time gives conservation of energy; the symmetry of space gives conservation of momentum). Here, the "symmetry" is the invariance of the free-energy behavior under state equivalence, and the "conserved quantity" is the dissipation class.

## Practical Implications

The theoretical framework has immediate practical consequences.

**Model compression.** Any weighted transition system — a finite automaton where transitions carry costs — can be minimized using the thermodynamic quotient. The result is the smallest system with the same input-output behavior, and the minimization algorithm is constructive. This is directly applicable to compressing neural network architectures, simplifying reinforcement learning models, and optimizing communication protocols.

**Learning from observations.** The Gibbs–Hankel semimodule suggests a new approach to learning unknown systems from black-box observations. By querying the system with input sequences and measuring free-energy outputs, one can reconstruct the minimal underlying automaton. This is a tropical analogue of spectral learning methods used in machine learning, adapted to the energy–entropy trade-off setting.

**Verified optimization.** The minimization comes with a *certificate*: a mathematical proof that the result is correct and optimal. This matters in safety-critical applications — avionics, medical devices, autonomous vehicles — where you need to *prove*, not just test, that your system is correct.

## The Bigger Picture

What makes this work conceptually striking is the unification it achieves. Automata theory, tropical algebra, closure semantics, and thermodynamics are four mature fields that developed largely independently. The thermodynamic Myhill–Nerode theorem reveals a deep structural unity:

- **Closure semantics** provides the observation model (what can be measured).
- **Tropical algebra** provides the variational framework (how to optimize).
- **Automata theory** provides the computational model (what machines can do).
- **Thermodynamics** provides the physical interpretation (what nature actually computes).

The quotient automaton sits at the intersection of all four, the unique object that simultaneously satisfies all their constraints. It is the mathematical equivalent of a Rosetta Stone: a single artifact that translates between four different languages.

The researchers suggest that this is just the beginning. A "thermodynamic Kleene theorem" — characterizing thermodynamic behaviors by algebraic expressions — is within reach. Tropical spectral learning could enable data-driven discovery of thermodynamic models. And extending the framework to quantum systems could connect quantum error correction to tropical optimization.

## The Art of Forgetting

At its deepest level, this work is about the mathematics of forgetting. Every computation carries a history, but not all of that history matters. The thermodynamic quotient identifies exactly what can be forgotten without losing any predictive power about the future. It is the mathematically precise answer to the question: "What is the minimum I need to remember?"

In thermodynamics, forgetting has a cost — Landauer's principle tells us that erasing information requires energy. In computation, forgetting has a benefit — it simplifies the machine, reduces memory, and speeds execution. The thermodynamic automaton framework holds both facts in balance, providing a single mathematical language for reasoning about the costs and benefits of computational compression.

As our world fills with ever more complex computational systems — from deep neural networks to autonomous robots to climate models — the ability to rigorously compress without losing essential behavior becomes not just mathematically elegant but practically urgent. The thermodynamic Myhill–Nerode theorem offers a principled foundation for this compression, grounded simultaneously in the algebra of optimization and the physics of information.

Sometimes the deepest mathematics emerges not from solving a problem within one field, but from discovering that two seemingly unrelated fields were asking the same question all along. In this case, the question was: *What is the simplest machine that captures a given pattern of behavior?* The answer, it turns out, is thermodynamic.
