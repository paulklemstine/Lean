# When Local Experts Disagree: The Hidden Mathematics of Assembling Intelligence

## The Puzzle of the Blind Architects

Imagine five architects, each designing a different wing of a massive hospital. Architect A designs the emergency room. Architect B handles the surgical suites. Architect C plans the patient wards. Each is brilliant within their domain. But when the blueprints arrive at the construction site, a terrible question arises: *Do these five designs actually fit together into a coherent building?*

This isn't just an architectural problem. It's one of the deepest challenges in modern artificial intelligence — and a team of mathematicians has just cracked it wide open.

The breakthrough is a theorem that answers, with mathematical certainty, a question that has haunted engineers building complex AI systems: **When can you assemble local specialists into a globally coherent system, and when is it provably impossible?**

## The Crisis of Modular Intelligence

Modern AI systems are rarely monolithic. A self-driving car doesn't have one brain — it has dozens. A camera module interprets visual scenes. A lidar module maps 3D geometry. A radar module tracks velocities. A planning module decides where to steer. Each module is trained separately, often by different teams, on different data.

The trillion-dollar question: when you bolt these modules together, do you get a *coherent* intelligence — or a Frankenstein's monster of contradictory judgments?

Until now, engineers have relied on testing, heuristics, and prayer. They'd plug modules together, run millions of simulations, and hope nothing catastrophic emerged from the seams. But hope is not a strategy, especially when lives depend on the system working correctly.

What's been missing is a *mathematical guarantee* — a way to look at the local modules and determine, before assembly, whether a globally coherent system even exists.

## A Surprising Connection to 19th-Century Geometry

The solution came from an unexpected direction: a branch of abstract mathematics called *sheaf theory*, invented in the 1940s and 1950s to solve problems in algebraic geometry that had nothing to do with computers.

A sheaf is, at its heart, a mathematical structure that manages local-to-global assembly. Imagine you have data defined on overlapping patches of a surface — temperatures on weather station zones, elevation measurements on map tiles, or signal strengths on cell tower coverage areas. A sheaf tells you when and how local data can be stitched into a consistent global picture.

The key insight of the new work is that AI modules are, mathematically, *exactly* like local data on overlapping patches. Each module produces predictions on its domain. Where domains overlap — where the camera and lidar both see the same object, for instance — the predictions had better agree. And the question "can we assemble these into a global system?" is precisely the question that sheaf theory was designed to answer.

But there's a twist that makes the AI problem harder than classical geometry.

## The Idempotent Secret

In classical sheaf theory, local data combines by addition or averaging. But AI systems don't aggregate evidence that way. When two modules both detect an obstacle, the system doesn't count it twice. When three experts all give the same diagnosis, the confidence doesn't triple. The aggregation is *idempotent* — combining a piece of evidence with itself produces nothing new.

This is the mathematical signature of max-operations, consensus voting, constraint satisfaction, and many other aggregation methods used in practice. And it changes the geometry dramatically.

The new theorem operates in the world of *idempotent semimodules* — algebraic structures where the aggregation operation satisfies the law: *a combined with a equals a*. This isn't just a technical refinement. It's a fundamentally different mathematical regime from the linear algebra that dominates most of mathematics and engineering. It's closer to the mathematics of tropical geometry, dynamic programming, and lattice theory.

Working in this regime, the researchers proved three interconnected results that together constitute a complete theory of modular AI assembly.

## The Three Theorems

**The Gluing Theorem.** Local modules can be assembled into a globally coherent system if and only if a certain *compatibility cocycle* vanishes. This cocycle is a concrete, computable object that measures the disagreement between overlapping modules. If it's zero everywhere — meaning all modules agree wherever their domains overlap — then a global system exists. If it's nonzero anywhere, assembly is impossible, and the cocycle tells you exactly where and how the modules conflict.

**The Uniqueness Theorem.** On systems satisfying a natural *separation* condition — meaning modules actually carry enough information to determine the global behavior — the assembled system is unique. There's no ambiguity about which global system the local modules produce.

**The Obstruction Theorem.** When assembly fails, the theory produces a *certificate* — a minimal piece of evidence proving impossibility. This isn't just "something went wrong." It's a specific pair of modules, a specific overlap, and a specific quantified disagreement that constitutes irrefutable proof that no globally coherent system exists. This certificate can be verified independently, without re-running the entire assembly attempt.

## What Makes This Different

Previous approaches to modular AI consistency have been either empirical (test and hope) or overly abstract (category theory formulations that can't be computed). This new theory is simultaneously:

- **Finite and combinatorial.** It works on finite sets of modules with finite-dimensional prediction spaces. No infinite-dimensional functional analysis required.
- **Constructive.** The reconstruction algorithm doesn't just prove existence — it builds the global system or produces the obstruction certificate. The algorithm runs in polynomial time.
- **Certified.** Every output comes with a mathematical guarantee. If it says "compatible," there provably exists a global system. If it says "incompatible," assembly is provably impossible.

## Beyond Self-Driving Cars

The applications extend far beyond autonomous vehicles.

**Federated learning.** Hospitals training AI models on patient data can't share that data due to privacy regulations. But they want to combine their models into a better global model. The new theorem tells them exactly when this is possible and when their data distributions have drifted too far apart for coherent combination.

**Sensor fusion.** Any system combining multiple sensors — smartphones, satellites, medical imaging devices — faces the assembly problem. The theory provides the first general framework for detecting sensor malfunction through mathematical inconsistency, not just statistical outlier detection.

**Mixture of experts.** Large language models and other AI systems increasingly use "mixture of experts" architectures, where different neural network modules handle different types of inputs. The theory gives conditions for when these experts produce a coherent overall system versus a collection of confident but contradictory specialists.

**Distributed databases.** When copies of a database are maintained at different sites and updated independently, eventual consistency is the holy grail. The compatibility cocycle measures exactly how far the system is from consistency and identifies the specific updates causing conflicts.

## The Deeper Pattern

What makes mathematicians most excited about this work isn't any single application — it's the revelation of a deep structural pattern.

The theorem says that *local consistency*, *modular learning*, and *certified reconstruction* are not three separate engineering goals. They are mathematically equivalent phenomena, different faces of the same geometric object. Solving any one of them automatically solves the other two.

This kind of unification is what mathematicians live for. When seemingly different problems turn out to be the same problem in disguise, it usually signals the beginning of a new field rather than the end of an investigation.

Indeed, the researchers have identified immediate extensions: higher-dimensional obstruction groups that capture multi-module failures (not just pairwise), tropical linearization techniques that connect to optimization theory, and concept-lattice cohomology that could yield new sample complexity bounds for learning.

## A New Language for Trust

Perhaps the most profound implication is philosophical. The theorem gives us a precise mathematical language for talking about *trust* in composite systems.

When you ask "Can I trust this AI system?", you're really asking a local-to-global question. You might trust the camera module. You might trust the lidar module. You might trust each expert individually. But can you trust them *together*? The compatibility cocycle is, in a real sense, a *measure of trustworthiness* for the assembled system. When it vanishes, trust in the parts implies trust in the whole. When it doesn't, no amount of confidence in individual components can rescue the system.

In a world increasingly dependent on complex AI systems assembled from specialized components — from medical diagnosis to financial trading to infrastructure management — this is perhaps the most important theorem we didn't know we needed.

The blind architects finally have a way to check their blueprints. And for the first time, we can prove — not just hope — that the building will stand.
