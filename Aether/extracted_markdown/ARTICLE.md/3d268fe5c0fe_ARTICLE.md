# When Computers Simplify Math, Does the Answer Depend on the Path?

## A hidden symmetry in how machines handle tensor algebra reveals that there's always one right answer — if you know where to look.

---

Imagine you're baking a cake, and the recipe says to mix flour and sugar first, then add butter, *or* to mix flour and butter first, then add sugar. Assuming you're a perfect baker, both orders should give the same cake. But in the world of mathematics — particularly the symbolic mathematics that powers everything from physics simulations to machine learning — proving that rearranging the steps always gives the same result turns out to be surprisingly deep.

This is the story of how a small team proved that a particular set of simplification rules for tensor expressions — the mathematical objects that underpin modern science — always produces the same answer, no matter what order you apply them. It sounds obvious. It isn't. And the proof reveals something beautiful about the hidden structure of symbolic computation.

## The Simplification Problem

Every time a computer runs a physics simulation, optimizes a neural network, or renders a 3D scene, it manipulates vast arrays of numbers organized into structures called tensors. Think of a vector as a list of numbers, a matrix as a grid, and a tensor as a higher-dimensional generalization. The operations between them — multiplication, scaling, addition, inner products — follow precise algebraic rules.

When scientists write formulas involving tensors, these formulas often contain redundancy. The expression "multiply matrix A by the sum of vectors v and w" can be simplified to "multiply A by v, then multiply A by w, and add the results." This is the distributive law, the same rule you learned in middle school: *a(b + c) = ab + ac*.

In tensor algebra, there are eight such distributivity rules, governing how multiplication, scalar multiplication, and inner products interact with addition. A symbolic simplifier applies these rules to "push additions outward," producing a standard form where every term is a product of atomic pieces. The result is cleaner, faster to compute, and easier to reason about.

But here's the catch: when multiple rules can apply simultaneously, the order in which you choose to apply them might — in principle — lead to different results. Two different simplification paths might arrive at different "simplified" expressions. If that happens, the simplifier is useless as a decision procedure: you can't trust that two expressions that simplify to different things are genuinely different.

## The Confluence Question

In the theory of rewriting systems, this problem has a precise name: **confluence**. A system is confluent if, whenever a single expression can be simplified in two different ways, there's always a common point where the two paths reconverge. Like two rivers that fork around an island and then rejoin downstream.

Confluence is the mathematical property that separates a "seems-to-work" simplifier from a "provably-correct" decision procedure. Without confluence, you have a heuristic. With it, you have a theorem.

For the eight tensor distributivity rules, confluence is not obvious. Consider the expression *dot(smulVec(a, v), vecAdd(w, u))* — the inner product of a scaled vector with a sum of vectors. Two rules apply at the same time:

- **Rule 7** distributes the inner product over the sum, yielding *dot(smulVec(a,v), w) + dot(smulVec(a,v), u)*
- **Rule 8** pulls the scalar out, yielding *a · dot(v, vecAdd(w, u))*

Following each path to completion produces two different expressions:
- Path 1: *a·dot(v,w) + a·dot(v,u)*
- Path 2: *a·(dot(v,w) + dot(v,u))*

These are clearly equal by the distributive law for scalar multiplication. But they're syntactically different — they look different as strings of symbols. The question is: are such differences always "trivial," or can they compound into something genuinely ambiguous?

## The Proof

The answer, established in the new formal development, is that the differences are always trivial — specifically, every pair of irreducible forms of the same expression differs only by the commutative and associative rearrangement of addition, plus the distribution of scalar multiplication over scalar addition. This is called **confluence modulo AC** (associativity-commutativity).

The proof proceeds in three stages.

**Stage 1: Termination.** Every sequence of simplification steps must eventually stop. This is proved using a clever numerical measure called the *distributivity potential* — a polynomial interpretation that assigns a positive integer to each expression. The key insight is that additive nodes (sums) receive a "+1" bonus, while multiplicative nodes (products, scaling, inner products) multiply their children's values. Scalar-multiplication and scalar-matrix nodes get an additional "+1" to handle associativity rewrites. Every simplification step strictly decreases this number, which — since it's a positive integer — means the process must terminate.

**Stage 2: Local confluence.** When two rules overlap on the same expression, the resulting "critical pair" is always joinable. The proof examines every possible overlap among the eight rules. Most are trivial: the rules fire in non-interfering parts of the expression. The genuinely interesting overlaps involve interactions between distribution of inner products over sums (rules 6-7) and the scalar-extraction rule (rule 8). These produce terms that differ by the distribution of scalar multiplication over scalar addition — a relationship explicitly included in the equivalence relation.

**Stage 3: Canonicalization.** A deterministic normalization algorithm is defined that recursively normalizes subterms and then fully distributes all multiplicative structure over additive structure. This algorithm is proved to produce irreducible expressions, and — crucially — to map rewrite-equivalent expressions to AC-equivalent outputs.

## Why It Matters

The significance extends far beyond a clean mathematical result. The eight distributivity rules are the core simplification engine for tensor expressions in scientific computing. Proving their confluence transforms an *ad hoc* simplifier into a *certified canonical form*.

**For compilers:** An optimizing compiler for scientific code can apply these simplification rules in any order — parallel, random, or opportunistic — with the guarantee that the output is deterministic (up to trivial rearrangements). Different optimization schedules cannot produce semantically inequivalent code.

**For verification:** Two tensor expressions can be definitively compared by simplifying both to normal form and checking AC-equivalence. If the normal forms match, the expressions are provably equal under the tensor algebra axioms covered by the eight rules.

**For algebra:** The confluence result is a small but concrete *coherence theorem* — a statement that different paths through a system of algebraic identities always compose consistently. Such theorems are the foundation of categorical algebra and have deep connections to proof theory.

## The Deeper Pattern

The discovery illuminates a broader phenomenon: when a rewriting system for an algebraic theory is confluent, it gives you canonical representatives for equivalence classes of expressions. This is the same principle behind Gröbner bases in polynomial algebra, Knuth-Bendix completion in group theory, and Church-Rosser theorems in lambda calculus.

What's new here is the modular decomposition of the confluence proof. The eight rules form a *distributivity fragment* — they express only how products distribute over sums. The residual ambiguity (AC-equivalence plus scalar distribution) is exactly the part of the algebra that the rules don't orient. The proof isolates this residual cleanly, separating what the rewrite system decides from what it leaves to an equivalence check.

This modular structure suggests a roadmap for extending the result to richer tensor algebras: add rules for commutativity of inner products, trace operations, or contraction, and analyze the new critical pairs. Each extension would enlarge the fragment of tensor algebra with certified canonical forms.

## Looking Forward

The immediate practical consequence is a verified simplification procedure for tensor expressions — one where "verified" means mathematically certified, not just extensively tested. The longer-term consequence is conceptual: a demonstration that symbolic tensor computation has enough structure to support rigorous normal-form theory.

This matters because tensor computation is everywhere. The energy functionals of quantum mechanics, the loss functions of machine learning, the stress tensors of engineering — all are expressions in a tensor algebra that computers must manipulate symbolically. Knowing that the simplification of such expressions is deterministic and canonical is a foundation for building tools that are not just fast, but provably correct.

The eight rules are simple. The proof that they behave well is not. And in the gap between simplicity and proof lies the substance of mathematical science: the patient work of establishing that our computational tools do what we believe they do, and that the paths we choose through the space of simplifications always lead to the same destination.

*Mathematics, it turns out, doesn't care which way you go. It just cares that you arrive.*
