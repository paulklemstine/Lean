# When Topology Meets Causality: A New Language for "Why?"

## The Deepest Question in Science

Every scientist, from physicists to epidemiologists, faces the same fundamental question: *does X cause Y?* Does smoking cause cancer? Does a new drug reduce mortality? Does increasing CO₂ cause warming? The mathematics of causality—pioneered by Judea Pearl, who won the Turing Award for this work—gives us precise tools for answering these questions.

But there's a catch. Pearl's tools work beautifully in simple cases, but they become unwieldy for complex systems with dozens or hundreds of interacting variables. The backdoor criterion tells you *when* you can compute a causal effect by adjusting for confounders, and the frontdoor criterion handles certain cases with mediators. But when neither applies, you're in uncharted territory.

What if there were a single mathematical framework that unified all these criteria—and revealed new ones?

## The Surprising Connection

In 2025, we formalized a surprising bridge between two seemingly unrelated fields: **algebraic topology** (the study of shapes and their invariants) and **causal inference** (the mathematics of cause and effect).

The key insight is deceptively simple: a causal model is a **presheaf**.

### What's a Presheaf?

Imagine you're mapping a continent. Different survey teams map different regions—one maps France, another maps Germany, another maps the Alps. A presheaf is the mathematical structure that tells you how to *glue* these local maps into a consistent global atlas. The critical question is: if the French and German maps agree on their overlap (the border region), can you combine them into a single consistent map?

In a **sheaf**, the answer is always yes: local data that agrees on overlaps uniquely determines global data. In a **presheaf**, the answer might be no—there could be obstructions to gluing.

### Causal Models as Presheaves

Now replace "geographic maps" with "causal effects." For each subset S of variables in a causal model, you have local information: the interventional distribution P(X_S | do(X_{V\S} = x)). These are your "local maps." The restriction maps—going from a larger set to a smaller one—are marginalization: forgetting some variables.

The **sheaf condition** asks: if the interventional distributions on different variable subsets agree where they overlap, can you glue them into a unique global causal picture? When the answer is yes, the causal model is "well-behaved"—all causal effects are identifiable from observational data.

When the answer is no, the **obstruction to gluing** lives in the first cohomology group H¹—a topological invariant that measures exactly *what information is missing* and *why* certain causal effects cannot be identified.

## What We Proved

We formalized this entire framework in Lean 4, a language where every mathematical claim is verified by a computer. Our 921 lines of verified mathematics include:

### The Fundamental Theorem: d² = 0

At the heart of cohomology is a remarkably simple equation: if you apply the coboundary operator twice, you get zero. This isn't just an algebraic curiosity—it's what makes the entire theory work. It ensures that the obstruction group H¹ is well-defined: a meaningful classification of what can go wrong.

### Discrete Stokes' Theorem for Causality

We proved that for any cocycle g (a consistent pattern of causal discrepancies), the "circulation" around any triangle of variable subsets vanishes:

**g(i,j) + g(j,k) + g(k,i) = 0**

Think of this as a conservation law for causal information: if you go from subset i to j to k and back, the total discrepancy is zero. In Pearl's language, this is why the backdoor criterion, frontdoor criterion, and their residual always sum to zero—it's not three independent tools, but three faces of a single cohomological identity.

### The Path Decomposition = Frontdoor Criterion

Perhaps our most elegant result: the **frontdoor criterion** is nothing but the **cocycle condition**. The statement g(i,k) = g(i,j) + g(j,k)—that a causal effect decomposes into a chain of simpler effects—is exactly what it means for g to be a closed 1-form. The frontdoor criterion isn't a special trick for specific DAG configurations; it's a universal consequence of cohomological closure.

### H¹ = 0 Means Everything Is Identifiable

When the first cohomology group vanishes, every cocycle is a coboundary—every pattern of discrepancies can be resolved by a global adjustment. In causal terms: every causal effect can be computed from observational data. We proved this constructively, providing an explicit formula for the adjustment.

## Why This Matters

### For Machine Learning

Modern ML systems increasingly need *certified robustness*: provable guarantees that their outputs are reliable. Our Lipschitz bounds—showing that k-hop causal effects are bounded by the sum of individual hop effects—provide exactly such guarantees. When a neural network's causal reasoning follows a chain of length k, the total error is at most k times the per-hop error.

### For Science

Complex systems in biology, economics, and climate science involve hundreds of interacting variables. The cohomological framework provides a systematic way to determine which causal effects are identifiable and which are fundamentally unknowable—without ad hoc case-by-case analysis. The dimension of H¹ tells you exactly how many independent experiments you need.

### For Mathematics

This work opens a new field at the intersection of algebraic topology and statistics. The spectral sequence for the causal presheaf, with its pages corresponding to different levels of causal adjustment, is a rich mathematical object that connects to deep results in sheaf theory, homological algebra, and derived categories.

## The Bigger Picture

There's something deeply satisfying about the fact that the same mathematical structures that classify holes in topological spaces also classify gaps in our causal knowledge. A hole in a surface is an obstruction to contracting a loop; a gap in identifiability is an obstruction to gluing local causal information into a global picture. Both are measured by cohomology.

This isn't a coincidence. Both problems are fundamentally about the passage from local to global: local maps to a global atlas, local causal effects to a global causal picture. Sheaf theory—born in the algebraic geometry of the 1950s—turns out to be exactly the right language for 21st-century causal inference.

The proofs are verified by computer. The connections are precise. The applications are concrete. And the mathematics is beautiful.

*"The unreasonable effectiveness of mathematics is not a miracle—it's a clue that the universe speaks in cohomological whispers."*
