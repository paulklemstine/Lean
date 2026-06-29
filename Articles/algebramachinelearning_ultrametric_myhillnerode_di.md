# The Mathematics of Forgetting: How Non-Archimedean Geometry Reveals When Machines Can Safely Ignore the Future

## A Hidden Symmetry in Computation

Imagine you're watching a chess game between two grandmasters. After twenty moves, the positions on both boards are different—but a seasoned analyst might tell you they're "effectively the same." The pawn structures are equivalent, the piece activity is comparable, and any future sequence of moves will produce outcomes that are indistinguishable to within a small margin. The two games have *merged*, observationally speaking.

Now scale that intuition to millions of states. A neural network processing language has billions of possible hidden configurations. A theorem-proving engine exploring mathematical proofs has an astronomical number of partial proof states. An autonomous vehicle's planning system tracks a vast space of possible futures. In each case, many of these states are *observationally redundant*—they look different internally, but no experiment you could ever run would tell them apart.

The question is: can you safely merge them? And if so, how many distinct states do you actually need?

A new mathematical theorem provides a surprisingly clean answer, drawing on one of the most exotic corners of number theory: the geometry of *p*-adic numbers.

## Distance, But Not As You Know It

We all have an intuitive sense of distance. New York is closer to Boston than to Los Angeles. The number 7 is closer to 8 than to 100. This intuition is governed by what mathematicians call the *triangle inequality*: the distance from A to C is never more than the distance from A to B plus the distance from B to C.

But there's a much stronger version of this rule that holds in certain mathematical spaces. In an *ultrametric* space, the triangle inequality is replaced by something sharper:

> The distance from A to C is never more than the *maximum* of the distances from A to B and from B to C.

This seemingly small change has enormous consequences. In an ultrametric world, every triangle is isosceles. Every point inside a ball is its center. And balls are either completely disjoint or one contains the other—there are no partial overlaps.

These aren't abstract curiosities. Ultrametric spaces arise naturally in the *p*-adic numbers, a number system that has been central to modern number theory since Kurt Hensel introduced them in 1897. In the *p*-adic world, the number 1,000,000 is "closer" to zero than the number 1/7, because what matters is not magnitude but divisibility by a prime *p*. The *p*-adic numbers have proved indispensable in solving deep problems in algebra and geometry—from Andrew Wiles's proof of Fermat's Last Theorem to modern developments in the Langlands program.

But here's what's surprising: ultrametric geometry also appears in places far removed from pure number theory. Hierarchical clustering algorithms produce ultrametric distance structures. Phylogenetic trees in biology define ultrametric relationships between species. And the state spaces of certain computational systems—including neural networks with specific architectural constraints—naturally carry ultrametric structure.

## The Forgetting Theorem

The new result, which we might call the *Ultrametric Myhill–Nerode Theorem*, connects this exotic geometry to a fundamental principle of computation.

The classical Myhill–Nerode theorem, proved in the 1950s, is a cornerstone of theoretical computer science. It says that any regular language—the kind recognized by the simplest type of computing machine—has a unique minimal recognizer. You can always compress a machine to its smallest possible form, and the compressed machine is canonical: there's only one way to do it.

The ultrametric version extends this principle to a much richer setting. Instead of asking whether two states produce exactly the same behavior, we ask whether they produce behavior that's *indistinguishable up to a tolerance ε*. And instead of working with the flat, structureless state spaces of classical automata, we work with states that carry ultrametric geometry.

The theorem has five key parts, building from simple observations to a powerful structural conclusion.

**First: contraction kills the future.** If the system's dynamics are *contractive*—meaning each transition step brings states closer together by a fixed ratio *c* < 1—then the influence of the distant future on present observations decays exponentially. Specifically, any observation made after *k* steps of evolution contributes at most *L* · *c*^*k* · *D* to the observational distance, where *L* measures the sensitivity of the output and *D* is the diameter of the state space. This is the non-Archimedean analogue of signal decay in a lossy channel.

**Second: finite depth suffices.** Because the future contribution decays exponentially, there exists a finite depth *N* beyond which no new observational distinctions can arise. If two states look the same for all experiments of length at most *N*, they will look the same forever. The value of *N* depends only on the contraction ratio, the Lipschitz constant of the output, the space diameter, and the tolerance—all computable quantities.

**Third: equivalence is a congruence.** The observational equivalence relation respects the system's dynamics. If two states are equivalent, they remain equivalent after any transition. This is the property that makes the quotient well-defined: you can build a smaller system on the equivalence classes without breaking anything.

**Fourth: the quotient is canonical.** The equivalence classes form a quotient system that is the *coarsest possible* semantics-preserving abstraction. Any other way of compressing the system that preserves observations up to tolerance ε must factor through this canonical quotient. It is the unique minimal machine—the tightest possible compression that still captures all observable behavior.

**Fifth: the ultrametric structure matters.** Because the underlying distance is ultrametric (not merely metric), the equivalence classes have a rigid topological structure. In a standard metric space, equivalence classes can have messy boundaries. In an ultrametric space, they are *clopen*—simultaneously open and closed—which means they are robust to small perturbations. Move a state slightly, and it stays in the same equivalence class or jumps cleanly to another. There is no ambiguous boundary zone.

## Why This Matters Beyond Pure Mathematics

The theorem's significance extends well beyond the world of abstract algebra and topology. Here are three domains where it has immediate implications.

### Certified Neural Network Compression

Modern AI systems are enormous. Large language models have hundreds of billions of parameters and astronomical numbers of possible internal states. *Distillation*—the process of compressing a large model into a smaller one that behaves similarly—is one of the most important practical techniques in machine learning.

But current distillation methods are heuristic. They work well in practice, but there are no guarantees about what information is lost. The ultrametric quotient theorem provides a *certified* compression framework: merge hidden states that are observationally equivalent up to tolerance ε, and the resulting compressed model is provably faithful to the original up to that tolerance. The compression is optimal—no further merging is possible without losing information.

For systems whose state dynamics are contractive (a common property in well-trained recurrent networks, where hidden states converge during inference), the theorem gives explicit bounds on how much compression is achievable and how deep you need to look to verify it.

### Proof Search Optimization

Automated theorem provers explore vast spaces of partial proofs. Many of these partial proofs are effectively redundant—they will lead to the same outcomes regardless of what proof steps are applied next. Identifying and merging these redundant states can dramatically reduce the search space.

The ultrametric quotient provides a principled way to do this. If proof-state transitions are contractive (each step brings the state closer to a fixed point, as happens in many normalization procedures), the theorem guarantees that only a finite exploration depth is needed to identify all redundant states. This transforms proof compression from a syntactic heuristic into a semantic optimization with mathematical guarantees.

### Hierarchical Data Structures

The ultrametric ball structure of equivalence classes suggests natural hierarchical representations. As the tolerance ε varies, the quotient changes: small ε gives many fine-grained classes; large ε gives few coarse classes. This hierarchy of quotients forms a nested tree structure—a *dendogram*—that captures the multi-scale observational structure of the system.

This is precisely the kind of structure used in hierarchical clustering, taxonomy, and multi-resolution analysis. The theorem shows that for contractive ultrametric systems, this hierarchy is not just a convenient approximation but the *mathematically canonical* way to organize the system's states.

## The Deeper Pattern

What makes this result feel like the beginning of something larger is the way it unifies ideas from disparate mathematical traditions.

From **automata theory**, it inherits the Myhill–Nerode framework: words act by transitions, outputs define observability, the stable equivalence is the Nerode relation, and the quotient is the minimal machine.

From **non-Archimedean analysis**, it inherits the rigidity of ultrametric geometry: clopen balls, hierarchical nesting, and the absence of partial overlaps that plague Euclidean approximation theory.

From **dynamical systems**, it inherits the contraction principle: iterative dynamics with a contraction ratio below 1 converge to a fixed point, and the convergence rate controls how quickly the future becomes irrelevant.

From **category theory**, it inherits the universal property: the quotient is characterized not by its internal construction but by its relationship to all other possible compressions—it is the unique factorization through which every semantics-preserving quotient must pass.

These four perspectives, which developed independently over the past century, converge in a single theorem that says something simple and profound: *contractive non-Archimedean computation is inherently compressible, and the compression is canonical.*

## Looking Forward

The theorem opens several immediate research directions. Can the quotient size be characterized by the rank of an appropriate Hankel-type matrix, as in classical automata theory? Does the construction commute with composition—can you compress subsystems independently before assembling them? How stable is the quotient under perturbations of the system dynamics?

Perhaps most intriguing is the connection to learning theory. In classical machine learning, generalization bounds are typically expressed in terms of Euclidean covering numbers or Rademacher complexity. The ultrametric quotient suggests an alternative framework where compression and generalization are controlled by non-Archimedean covering numbers—quantities that behave very differently from their Euclidean counterparts due to the rigid ball structure of ultrametric spaces.

If this program succeeds, it could establish a new paradigm for understanding neural computation: not through the lens of continuous optimization in Euclidean space, but through the sharp, hierarchical, tree-like geometry of ultrametric spaces. In this world, the distinction between "approximate" and "exact" is not a matter of degree but of kind—you're either inside the ball or outside it. And that rigidity, paradoxically, is what makes everything compressible.

The ancient Greek mathematicians knew that the world of pure forms was simpler than the world of appearances. The ultrametric Myhill–Nerode theorem suggests that for a certain class of computational systems, the same is true: beneath the apparent complexity of an astronomical state space lies a small, canonical, mathematically inevitable quotient. The machine wants to be simple. Mathematics just tells us how.
