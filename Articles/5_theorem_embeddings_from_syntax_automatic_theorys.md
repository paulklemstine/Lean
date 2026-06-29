# When Theorems Learn to Describe Themselves

## The Library That Reads Its Own Books

Imagine walking into the largest library in the world — except none of the books have titles, and the shelves have no labels. You know the answer to your question is somewhere in the collection. But to find it, you would need to open every book, read every page, and somehow recognize the relevant passage when you see it.

This is, more or less, the situation facing modern mathematics. Over the past century, mathematicians have proven hundreds of thousands of theorems across dozens of fields. These results are scattered across journals, textbooks, preprints, and increasingly, formal digital libraries where every logical step has been verified by computer. The knowledge is there. The problem is finding it.

What if theorems could describe themselves?

Not in the vague way that an abstract summarizes a paper, but precisely — in a machine-readable format that captures exactly what the theorem guarantees, what it requires, and how strong its conclusion is. A team of researchers has taken the first steps toward making this vision real, and the implications reach far beyond mathematics.

## The Shape of a Guarantee

The key insight begins with a simple observation about the structure of mathematical theorems. Consider the following pattern, which appears across nearly every branch of mathematics:

*"For any object satisfying certain conditions, a particular measurement of that object is at least some fixed amount."*

This single sentence template captures an enormous range of results:

- In computer science: "Any sorting algorithm must make at least *n* log *n* comparisons."
- In geometry: "Any convex body with a given surface area has volume at least..."
- In machine learning: "Any learning algorithm requires at least this many training examples."
- In physics: "The entropy of any closed system is at least..."

These are all **lower-bound theorems**. They guarantee that some quantity cannot drop below a certain threshold, provided certain conditions are met. And crucially, they all share the same logical skeleton: there is a *type of object*, a *condition* on those objects, a *measurement function*, and a *minimum value*.

The researchers formalized this skeleton as what they call a **TheorySpec** — a "theory specification" that packages together these four components along with a proof that they fit together correctly. Think of it as a standardized shipping container for mathematical knowledge: regardless of whether the cargo is topology, algebra, or statistics, it fits the same format and can be handled by the same machinery.

## Mining Theorems from Theorems

Here is where things get genuinely surprising. The researchers proved that the extraction of a TheorySpec from a theorem is not just a convenient packaging trick — it is a mathematically rigorous operation with precise correctness guarantees.

Their central result, which they call the **extraction pipeline correctness theorem**, establishes that when you decompose a lower-bound theorem into its components and reassemble them into a TheorySpec, you get back exactly what you started with. Nothing is lost, nothing is distorted. The extracted specification is a perfect semantic representation of the original theorem.

This might sound obvious, but it is not. Mathematical theorems can be stated in many equivalent ways, and the relationship between a theorem's syntactic form (how it is written) and its semantic content (what it means) is notoriously subtle. What the researchers showed is that for a well-defined class of theorems — those matching the lower-bound pattern — the syntax *is* the semantics, in a precise formal sense.

They went further, proving what they call the **section theorem**: the extraction operation is a one-sided inverse of the "forgetful" operation that reads off the soundness proof from a TheorySpec. In mathematical language, extraction is a *section* of a *functor* — a structure-preserving map between categories. This means the extraction pipeline doesn't just work; it works for deep structural reasons.

## The Periodic Table of Bounds

To demonstrate that this is not merely abstract, the researchers applied their extraction framework to a catalog of existing mathematical results. They successfully embedded several concrete theorems into TheorySpec format:

**The Depth Obstruction Bound** from the theory of neural network architectures: for any network of depth *d* organized in layers of width *W*, the total capacity is at least *d*, bounded by a function of *W* and the quotient *d/W*. This result, originally proven in the context of homological algebra applied to deep learning, becomes a parameterized family of TheorySpecs — one for each layer width.

**The Exponential Growth Bound**, a fundamental result stating that *d* ≤ 2^*d* for all natural numbers. Simple as it sounds, this bound is a workhorse of complexity theory, and its TheorySpec packaging makes it instantly composable with other bounds.

**The Quadratic-Exponential Bound**, showing that *d*² ≤ 2^(2*d*), which arises in cryptographic security analysis and coding theory.

Each of these embeddings is not just a reformatting exercise. The resulting TheorySpec objects carry machine-checkable proofs of their own correctness. They can be composed (two lower bounds on compatible objects yield a combined lower bound), weakened (replacing a bound with a smaller one), strengthened (restricting to a subclass of objects), or pulled back along functions between different domains.

The researchers built what they call a **TheorySpec Registry** — essentially a curated database of extracted specifications. Their initial registry contains five entries, but the framework is designed to scale to thousands.

## Morphisms: When Theorems Talk to Each Other

Perhaps the most elegant aspect of the work is the notion of **TheorySpec morphisms** — structure-preserving maps between specifications. A morphism from spec *A* to spec *B* consists of a function mapping *A*'s objects to *B*'s objects, a proof that this function preserves the witness condition, and a proof that *A*'s lower bound is at most *B*'s.

These morphisms form a category, with identity and composition satisfying the expected laws (which the researchers proved formally). This categorical structure means that relationships between theorems become first-class mathematical objects that can themselves be studied, composed, and classified.

Imagine a graph where each node is a theorem (represented as a TheorySpec) and each edge is a morphism showing how one theorem's guarantee relates to another's. This "theorem graph" would make visible the hidden structure of mathematical knowledge — which results imply which others, which bounds are tighter, which domains share common patterns.

## Beyond Lower Bounds

The framework extends naturally beyond simple lower bounds. The researchers also formalized:

- **Upper-bound specs**, capturing theorems of the form "the measurement is at most..."
- **Exact specs**, for theorems establishing precise values, which decompose into both a lower and an upper bound.
- **Bounded specs**, combining both bounds with a consistency proof.
- **Conjunctive witnesses**, handling theorems with multiple conditions ("if the object is both red and heavy, then...").
- **Generalized specs** over arbitrary ordered types, not just natural numbers.

This family of specification types covers the vast majority of quantitative theorems in mathematics. The dream — still distant but now architecturally plausible — is a universal format for mathematical guarantees.

## What This Means for Science

The practical implications extend well beyond pure mathematics.

**For artificial intelligence:** Current AI systems that work with mathematical knowledge treat theorems as opaque strings of symbols. TheorySpec extraction turns them into structured data with typed fields and verified invariants. This is the difference between searching text and querying a database.

**For scientific discovery:** Many breakthroughs come from recognizing that two apparently different phenomena obey the same mathematical law. If theorems across physics, biology, economics, and engineering were all represented as TheorySpecs, pattern-matching algorithms could discover such connections automatically.

**For engineering:** Safety-critical systems need mathematical guarantees — that a bridge can bear a load, that an encryption scheme resists attack, that a control system remains stable. TheorySpec extraction provides a uniform way to state, verify, and compose such guarantees.

**For education:** Students often struggle to see connections between different areas of mathematics. A TheorySpec-indexed view of a mathematical library would make these connections visible and navigable.

## The Road Ahead

The current work establishes the mathematical foundations, but the full vision of a "self-describing theorem library" requires further development.

The most immediate next step is scaling: running the extraction pipeline over the hundreds of thousands of theorems in existing formal libraries and building a searchable index. This is primarily an engineering challenge, but one that the current framework is designed to support.

A more ambitious goal is **conjecture transfer**: using structural similarities between extracted specs to automatically propose new theorems. If a tight lower bound is known in domain *A*, and domain *B* has a spec with the same witness structure, the system could conjecture that *B* has a similar bound — and then attempt to prove it.

The deepest question is whether the categorical structure of TheorySpec morphisms reveals new mathematics. When we have a complete map of which theorems morph into which others, will we see patterns that no one has noticed before? Will the "theorem graph" have its own mathematical properties worth studying?

We are used to thinking of theorems as endpoints — finished products of mathematical reasoning. The TheorySpec framework suggests they might better be understood as components in a larger machine: standardized parts that can be assembled, compared, and transformed. The library is beginning to read its own books.

---

*This research builds on work at the intersection of mathematical logic, type theory, and knowledge representation. The formal proofs have been machine-verified, ensuring that every claim about extraction correctness is not just plausible but certain.*
