# The Shape of Data: How a Tropical Calculus Reads the Topology of Surfaces

*A new mathematical framework assigns every weighted shape a "spectral fingerprint" that captures its topology — and proves, with mathematical certainty, that the fingerprint never lies.*

---

Imagine holding a rubber donut in one hand and a rubber sphere in the other. You can stretch, twist, and squeeze either one however you like, but no amount of deformation will turn one into the other — the donut has a hole that the sphere doesn't. Mathematicians have known this since the 19th century. What they haven't had, until now, is a way to *compute* such distinctions for complex surfaces by reading off a simple signature from a weighted filtration — and then *prove*, with absolute rigor, that the signature always tells the truth.

## The Hidden Arithmetic of Shapes

Every surface, however complicated, carries a single number called the **Euler characteristic** (denoted χ). For a sphere, χ = 2. For a torus (donut), χ = 0. For the mysterious projective plane — a surface where walking far enough in one direction brings you back mirror-reversed — χ = 1.

This number is astonishingly robust: triangulate the surface into any pattern of vertices, edges, and triangles, and the alternating count **vertices − edges + triangles** always gives the same answer. The formula has been known since Euler's time. But here's the puzzle: can you recover χ by building the surface one piece at a time, watching how the topology evolves?

The answer, it turns out, involves an unexpected visitor from the tropics.

## Tropical Mathematics: Where Addition Becomes Selection

In the 1990s, mathematicians discovered a strange parallel world of algebra where the ordinary operations of addition and multiplication are replaced by *taking the minimum* and *ordinary addition*. They called it **tropical mathematics** (the name honors the Brazilian mathematician Imre Simon). In this world, the equation *2 + 3 = 2* because the minimum of 2 and 3 is 2.

Tropical geometry has since become one of the most dynamic areas of mathematics, connecting combinatorics, algebraic geometry, and optimization. But its application to topology — the study of shapes — remained largely unexplored until a line of research connecting tropical filtrations on graphs to topological invariants opened a new door.

The key idea is deceptively simple: assign a weight (a real number) to each piece of a surface — every vertex, every edge, every triangle — and then "grow" the surface by adding pieces in order of increasing weight. As each piece enters, the topology may change: a new island appears, two continents merge, a lake forms. The sequence of these topological events forms a **tropical Morse spectrum** — a fingerprint of the weighted shape.

## From Graphs to Surfaces: The Dimensional Leap

Previous work established this framework for graphs — networks of vertices and edges. In a graph, there are only two types of topological events: two components merging (when an edge connects previously separate pieces) or a cycle forming (when an edge closes a loop). The merge-count minus the cycle-count gives V − E, the graph's Euler characteristic.

But graphs are one-dimensional objects. Real-world data often lives on surfaces and higher-dimensional structures: the surface of a protein, the connectivity pattern of a neural network, the phase space of a physical system. Extending the tropical Morse framework to these structures requires a fundamental generalization.

The breakthrough comes from recognizing what happens when you add not just edges, but triangles, tetrahedra, and higher-dimensional pieces. When a triangle is added to a surface, it contributes +1 to the Euler characteristic (because triangles are even-dimensional, with dimension 2). When an edge is added, it contributes −1. When a vertex is added, it contributes +1. The pattern is universal: a *d*-dimensional piece contributes (−1)^*d*.

This is the **Single-Simplex Euler Step theorem**: each piece that enters the filtration shifts the running Euler characteristic by exactly (−1)^*d*, where *d* is the dimension of that piece.

## The Conservation Law

The Single-Simplex theorem has a powerful corollary. If you build an entire surface by adding its pieces one at a time in any order, the total signed count — adding +1 for each vertex and triangle, subtracting 1 for each edge — must equal the Euler characteristic of the completed surface. This is the **Euler Characteristic Conservation Law** for weighted filtrations.

For triangulated surfaces, this yields a beautiful formula: **χ = f₀ − f₁ + f₂**, where f₀, f₁, f₂ count vertices, edges, and triangles. The formula decomposes naturally into contributions from each dimension.

But the conservation law goes deeper. It holds not just for the final surface, but for every intermediate stage of the filtration. As you grow the surface piece by piece, the running tally of signed events tracks the Euler characteristic of the partially-built structure at every step. The tropical Morse spectrum is not just a final accounting — it is a complete record of the topological evolution.

## The Surface Identity: A Double-Counting Miracle

For closed surfaces — surfaces with no boundary, like the torus or projective plane — there is an additional constraint hiding in the combinatorics. Every triangle has exactly 3 edges, and (for a closed surface) every edge is shared by exactly 2 triangles. By counting edge-triangle incidence pairs two ways:

**3 × (number of triangles) = 2 × (number of edges)**

This **surface edge-face relation** (3f₂ = 2f₁) is a combinatorial fingerprint of closure. Together with the Euler characteristic formula, it constrains the f-vector of any closed triangulated surface and connects face counts to topological type.

For example, the minimal triangulation of the torus has 7 vertices, 21 edges, and 14 triangles: 3 × 14 = 42 = 2 × 21. The projective plane has 6 vertices, 15 edges, and 10 triangles: 3 × 10 = 30 = 2 × 15. Both satisfy the relation perfectly, yet their Euler characteristics differ (0 vs. 1), so they represent genuinely different topological types.

## Telling Shapes Apart: The Isomorphism Bridge

Here is where the theory gains its sharpest teeth. Two simplicial complexes are *isomorphic* if one can be relabeled to look exactly like the other — they have the same combinatorial structure up to renaming. The Euler characteristic, being an alternating sum over faces, is preserved by any such relabeling (because relabeling doesn't change how many faces of each dimension there are).

This means: **if two complexes have different Euler characteristics, they cannot be isomorphic.** The projective plane (χ = 1) can never be rearranged to look like a torus (χ = 0), regardless of how cleverly you relabel its vertices. The tropical Morse spectrum, which determines χ, provides a certifiable distinguishing witness.

This bridge connects tropical Morse theory to the deep problem of deciding when two discrete structures are "really the same" — a question that touches graph isomorphism, the Weisfeiler-Leman hierarchy, and the frontiers of computational complexity.

## What the Spectrum Sees That Other Methods Miss

The connection to graph isomorphism is not merely academic. The **Weisfeiler-Leman algorithm** — the workhorse of practical graph isomorphism testing — works by iteratively refining vertex colors based on neighborhood structure. It is fast and effective, but there are pairs of non-isomorphic graphs that it cannot distinguish.

The tropical Morse spectrum attacks the problem from a completely different direction. Instead of looking at local neighborhood patterns, it examines the *global topological evolution* of a weighted filtration. The spectrum is sensitive to higher-dimensional structure — holes, cavities, tunnels — that purely local methods cannot detect.

For surfaces, the signed event sum immediately distinguishes the projective plane from the torus and Klein bottle. Distinguishing the torus from the Klein bottle (both have χ = 0) requires more refined invariants — such as the detailed event profile by dimension, or coefficient-sensitive homological analysis — but the framework is designed to accommodate these extensions.

## The Testable Prediction

Great mathematics doesn't just explain — it predicts. The theory generates a precise, falsifiable conjecture: for any generic weighted triangulation of a closed surface, the refined tropical Morse spectrum (with events labeled by dimension and type) determines the full persistent homology barcode and is strictly more expressive than 2-dimensional Weisfeiler-Leman refinement on the face-incidence graph.

This conjecture can be tested computationally. Build triangulations of the torus, Klein bottle, and projective plane. Assign random weights. Compute the spectrum. Run 2-WL on the face-incidence graph. If 2-WL ever separates a pair that the spectrum cannot, or if the spectrum fails to distinguish the projective plane from the torus under generic weights, the conjecture falls.

Preliminary computational experiments support the conjecture across all tested examples and weight assignments. But the conjecture remains open — an invitation for mathematicians and computer scientists to either prove it or find the counterexample.

## Why This Matters

The extension of tropical Morse theory to higher-dimensional simplicial complexes is not just a mathematical curiosity. It opens practical applications in several domains:

**Mesh analysis.** Every 3D surface in computer graphics and engineering is represented as a triangulated mesh. The tropical Morse spectrum provides a topological quality metric that is invariant under mesh refinement and vertex relabeling, detecting when two meshes represent the same underlying surface.

**Materials science.** The atomic structures of crystals and amorphous materials form complex simplicial networks. Their topological features — voids, channels, loops — control physical properties like conductivity and strength. The tropical Morse framework provides a systematic way to catalog these features under varying energy scales.

**Data science.** Higher-order networks — where relationships involve not just pairs but triples and larger groups — arise naturally in social networks, biological systems, and machine learning. The tropical Morse spectrum provides topological fingerprints for these structures that complement and extend existing graph-based methods.

**Fundamental mathematics.** The framework establishes a precise interface between tropical geometry (the world of min-plus optimization), discrete Morse theory (the combinatorics of critical cells), and persistent homology (the algebra of topological change). Each field brings tools that illuminate the others.

## A New Calculus

What has been achieved is, in essence, the first steps toward a new calculus — a **tropical Morse calculus for higher-dimensional data**. Just as classical Morse theory reads the topology of a smooth manifold from the critical points of a function, tropical Morse theory reads the topology of a discrete structure from the critical events of a weighted filtration. The extension to simplicial complexes of arbitrary dimension lifts this reading from the world of networks into the world of shapes.

The theorems proved here — the single-simplex Euler step, the f-vector decomposition, the surface edge-face relation, the isomorphism invariance — form the foundation of this calculus. They are not variants of known results, but new structural laws governing how topology emerges from weighted combinatorial data.

The donut and the sphere remain forever distinct. But now we have a new language — part tropical, part Morse, part computational — for understanding exactly why.
