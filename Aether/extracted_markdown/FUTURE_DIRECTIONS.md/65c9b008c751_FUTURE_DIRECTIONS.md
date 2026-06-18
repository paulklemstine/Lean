# Future Directions: Do-Calculus Formalization

## 1. Concrete d-Separation via Path Blocking

The current formalization uses an abstract `DSepOracle` satisfying graphoid axioms. The natural next step is to define d-separation concretely via path blocking (chains, forks, and colliders) and prove it satisfies all graphoid axioms. The key insight is that d-separation can be characterized as a reachability problem in a "moralized ancestral graph," which reduces the problem to ordinary graph connectivity. Why now? The `CausalDAG` infrastructure (topological ordering, reachability, mutilation) is fully in place, and the `DPath` structure already exists — we just need the blocking predicate and the moralization construction.

## 2. Completeness of Do-Calculus for Identifiability

Shpitser and Pearl (2006) proved that do-calculus is complete for identifying causal effects in semi-Markovian models. Formalizing this would require: (a) defining the "hedge" criterion, (b) showing that non-identifiability implies existence of two models agreeing on observational but not interventional distributions, and (c) showing every identifiable effect has a do-calculus derivation. The key insight is that the hedge structure provides a finite witness for non-identifiability, making the completeness proof constructive. Why now? The `DoDerivation` inductive type and `DoCalculusRule.graphCondition` already encode the derivation system — what's missing is the connection to actual probability distributions.

## 3. Algorithmic Identifiability via ID Algorithm

The ID algorithm (Tian and Pearl, 2002) provides a recursive decision procedure for causal effect identifiability. Formalizing this as a verified algorithm in Lean 4 would give us a certified decision procedure with extraction to executable code. The key insight is that the ID algorithm's recursion follows the c-component (confounding component) decomposition of the DAG, which can be defined using the `descendantsSet` and `ancestorsSet` operations already formalized. Why now? The mutilation algebra (composition, commutativity, idempotence) provides the foundation for reasoning about the graph transformations the algorithm performs.

## 4. Structural Causal Models with Measure-Theoretic Semantics

The current formalization captures the syntactic/graph-theoretic side of do-calculus. A deeper formalization would attach measure-theoretic semantics: each vertex carries a measurable space, each structural equation is a measurable function, and the do-operator corresponds to replacing a structural equation with a constant. The key insight is that the `intervention_disconnects` theorem (ancestors become empty after mutilation) is the graph-theoretic shadow of the measure-theoretic fact that intervened variables become independent of their former causes. Why now? Mathlib's measure theory library is mature enough to support this, and the graph-theoretic foundation proven here ensures the combinatorial side is solid.

## 5. Causal Discovery: Faithfulness and the PC Algorithm

Moving from causal inference (given a known DAG) to causal discovery (learning the DAG from data) requires the faithfulness assumption: that d-separation exactly characterizes conditional independence. Formalizing the PC algorithm's correctness under faithfulness would connect the d-separation oracle to statistical testing. The key insight is that under faithfulness, the `DSepOracle.symmetry`, `decomposition`, and `weak_union` axioms are not just sufficient but necessary — they characterize exactly the conditional independence relations that can arise from a DAG. Why now? The abstract `DSepOracle` structure is designed to be instantiated with concrete independence relations, making it the natural bridge between the graph-theoretic and statistical worlds.
