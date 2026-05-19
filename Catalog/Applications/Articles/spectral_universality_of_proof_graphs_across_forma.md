# The Hidden Music of Mathematical Proof

## Every proof has a shape. A new theorem says that shape tells the same story, no matter how you write it down.

Imagine you could see mathematics not as symbols on a page, but as architecture. Each theorem is a structure — a lattice of logical dependencies, where conclusions rest on premises, which rest on still deeper premises, all the way down to the axioms. Now imagine you could *hear* this architecture: convert it into a spectrum of frequencies, the way a prism splits white light into a rainbow. A new mathematical result suggests that when you do this, something remarkable emerges: the resulting "spectral signature" of a proof depends on its *mathematical content*, not on the language used to express it.

This is not metaphor. It is a theorem.

## The Problem of Proof Identity

Here is a question that has quietly troubled mathematicians and computer scientists for decades: when are two proofs "really the same"?

Consider the Pythagorean theorem. You can prove it by rearranging squares. You can prove it using similar triangles. You can prove it with trigonometry, or with coordinate geometry, or with vectors. Euclid's proof looks nothing like a proof using modern algebra. And if you encode these proofs in the formal languages used by today's computer-checked mathematics — and there are now millions of lines of such computer-verified proofs — they look even more different. Different variable names, different structural choices, different bureaucratic scaffolding.

Yet something remains constant. The *logical skeleton* — the pattern of which facts depend on which other facts — has a shape. And that shape, it turns out, carries information that transcends the surface form of the proof.

## Graphs: The Skeleton of Reasoning

To make this precise, mathematicians represent proofs as *graphs*: networks of nodes connected by edges. Each node is a logical step or a referenced result. Each edge connects a step to something it directly depends on. The Pythagorean theorem's proof becomes a web of connections: this step uses that lemma, which in turn uses those axioms.

The resulting structure is called a *proof dependency graph*. It strips away all the prose, all the notation, all the stylistic choices, and leaves only the bare logical wiring.

But here is the subtlety. Even at the level of bare wiring, there is noise. Different ways of organizing the proof — unfolding a definition here, compressing a chain of reasoning there — create small variations in the graph. These variations are like different dialects of the same language: they change the surface form without changing the meaning.

The question becomes: how do you measure the "true shape" of a proof graph in a way that is immune to this noise?

## Enter the Spectrum

The answer comes from an unexpected direction: the physics of vibrating systems.

When you pluck a guitar string, it vibrates at many frequencies simultaneously. The fundamental frequency and its harmonics — the *spectrum* — characterize the string's physical properties. Change the string's length or tension, and the spectrum shifts. But small perturbations (a tiny change in temperature, a speck of dust on the string) barely affect it.

Matrices have spectra too. The *adjacency matrix* of a graph — a table of zeros and ones recording which nodes are connected — has a set of characteristic numbers called *eigenvalues*. These eigenvalues encode deep structural properties of the graph: its connectivity, its expansion, the distribution of local neighborhoods, and the statistics of random walks along its edges.

The *empirical spectral measure* of a graph is the histogram of these eigenvalues. It is a fingerprint — a compressed summary of the graph's global architecture.

## The Trace-Walk Bridge

The new results establish a clean mathematical bridge between three different ways of looking at proof structure.

**The algebraic view:** The eigenvalues of the adjacency matrix. These are numbers that emerge from solving a polynomial equation — they are inherently global, requiring knowledge of the entire graph.

**The combinatorial view:** Closed walks in the graph. A walk of length *k* is a sequence of *k* steps along edges, each step moving to an adjacent node. A *closed* walk returns to where it started. The number of closed walks of length *k* is a purely local statistic — it depends only on the graph's neighborhood structure.

**The analytic view:** The trace of a matrix power. Computing the trace (the sum of diagonal entries) of the *k*-th power of the adjacency matrix gives a single number that summarizes certain global properties of the graph.

The bridge theorem says: *these three quantities are the same*.

The trace of *A^k* equals the sum of the *k*-th powers of the eigenvalues. For adjacency matrices, this also counts the closed walks of length *k*. This identity — proven here with complete mathematical rigor — means that local information (walk counts) determines global information (the spectral measure).

## The Universality Theorem

With this bridge in place, the main result follows. Consider two families of proof graphs that "look locally similar" — meaning that if you pick a random vertex in either graph and look at its neighborhood out to some fixed radius, you see the same patterns with the same frequencies. This is a formalization of the intuition that the proofs have the same local logical structure.

The **moment universality theorem** says: if two such families have the same limiting normalized traces (equivalently, the same local walk densities), their spectral measures converge to the same limit.

In plain language: *local proof geometry determines global spectral law*.

This is not obvious. Global spectral properties could, in principle, depend on long-range correlations that no finite-radius neighborhood inspection could detect. The theorem says they do not — at least for graphs with bounded degree, which is exactly the case for proof dependency graphs (where each theorem references a bounded number of predecessors).

## Stability: Why Syntax Doesn't Matter

The second key result addresses the noise problem. When you normalize a proof — unfold a definition, compress a chain of reasoning, rename variables — you change a bounded number of edges in the dependency graph. This is formalized as a "bounded local rewrite": a perturbation that affects at most *C* rows of the adjacency matrix.

The **perturbation stability theorem** says: such a rewrite changes the trace of *A^k* by at most *O(R^k)*, where *R* is the spectral radius bound. For normalized traces (divided by the graph size *n*), this perturbation is *O(1/n)* — it vanishes as the proof corpus grows.

The mathematical content is normalization-invariant. Change the proof's surface form, and the spectrum barely budges.

## Bounded Degree: Why Proof Graphs Are Special

Why do proof graphs behave so well spectrally? Because they have *bounded degree*.

In a proof dependency graph, each theorem references a bounded number of other results. The maximum degree *D* of the graph is typically small — a theorem might cite 5 or 10 lemmas, rarely 100. This bounded degree has a beautiful spectral consequence: every eigenvalue of the adjacency matrix has absolute value at most *D*.

This is the **spectral radius bound**, proven here via a clever argument involving eigenvectors and the maximum-entry principle. It says that bounded-degree graphs live in a "spectrally compact" regime where all the machinery of moment methods applies. The eigenvalues cannot escape to infinity; the spectral measure is supported on a bounded interval; and the moments determine the measure uniquely.

This is not true for arbitrary graphs. But it is true for proof graphs, and it is what makes the entire universality theory work.

## A New Science of Proof Geometry

What does this mean in practice?

First, it provides a rigorous foundation for comparing the "complexity" of different mathematical theories. The spectral moments of a proof corpus — the average closed walk densities — are computable invariants that measure something intrinsic about the mathematical content. Elementary arithmetic, abstract algebra, and higher-order categorical reasoning may well have different spectral signatures, just as different materials have different resonant frequencies.

Second, it opens a path to *transfer learning* in automated mathematics. If two proof systems have the same limiting spectral law — because they encode the same mathematical content — then strategies learned in one system should transfer to another. The spectral moments provide a common coordinate system.

Third, it connects proof theory to a vast body of mathematics that has been developed for completely different purposes. Spectral graph theory, random matrix theory, Benjamini–Schramm convergence, measured groupoids — these are tools from physics, combinatorics, and probability that now have a natural home in the study of mathematical reasoning.

## The Road Ahead

The theorems proven here are the beginning, not the end. They establish the mathematical *mechanism* — the reduction from spectral universality to local proof geometry. What remains is the *empirical question*: do real proof corpora actually exhibit the convergence that the theorems predict?

Initial computational experiments (comparing small dependency graphs from arithmetic and algebra) show the expected behavior: proof corpora with similar local structure produce similar spectral moments, and bounded perturbations leave the spectrum nearly unchanged. But the decisive tests require large-scale extraction of dependency graphs from real formalized mathematics — millions of theorems, across multiple systems.

The conjecture is bold: that all of mathematics, when viewed through the lens of proof dependency, belongs to a small number of *spectral universality classes*. That the sound of a proof — its spectral fingerprint — is determined not by who wrote it, or in what language, or with what tools, but by its mathematical soul.

If this is true, it would be among the most surprising discoveries in the foundations of mathematics: that the deepest structural invariant of a proof is not logical, but *spectral*.

---

*The results described here have been formally verified with complete computer-checked proofs. Every theorem mentioned — the trace-eigenvalue identity, the spectral radius bound, the moment universality theorem, the perturbation stability result — has been proven with zero gaps, using only the standard axioms of mathematics.*
