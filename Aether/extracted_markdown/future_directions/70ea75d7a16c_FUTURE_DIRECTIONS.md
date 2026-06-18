# Future Directions: Braid Group Invariants and Strand Topology

## 1. The Burau Representation and its Faithfulness Boundary

The BraidSignature (writhe × permutation) we formalized is a coarse invariant — it captures the abelianization and the symmetric group image but loses the rich non-abelian structure of the braid group. The next natural step is formalizing the *Burau representation*, which maps B_n into GL_{n-1}(ℤ[t, t⁻¹]) via matrices encoding how each strand crosses over or under its neighbors.

The key insight is that the Burau representation is known to be *unfaithful* for n ≥ 5 (Bigelow 1999), but the question remains open for n = 4. A Lean formalization could provide a constructive proof of unfaithfulness for n = 5 by exhibiting an explicit kernel element, and potentially settle the n = 4 case computationally.

Why now? Our formalization already has the generator-and-relation framework for B_n, and Mathlib's polynomial ring and matrix algebra provide the necessary algebraic infrastructure. The Burau matrices are concrete 2×2 or 3×3 matrices over ℤ[t], making verification tractable.

**Testable prediction**: For n = 5, there exists an explicit braid word of length ≤ 20 in the kernel of the Burau representation. Search computationally by evaluating Burau matrices for all words up to length 20 and checking which give the identity matrix.

## 2. Braid Group Orderability and the Dehornoy Order

The braid group B_n admits a left-invariant total order (the Dehornoy order), which is a remarkable property not shared by most non-abelian groups. This order has deep connections to set theory (arising from the self-distributive algebra of elementary embeddings) and to dynamics (via the action on the real line).

The key insight is that the Dehornoy order can be characterized purely combinatorially: a braid β is Dehornoy-positive if every representative word can be rewritten so that the highest-index generator σ_{n-1} appears only positively. This is a decidable condition, and the proof that it defines a total order uses the key lemma that every non-trivial braid is either σ-positive or σ-negative.

Why now? Our BraidWord type and BraidRelStep relation provide the right substrate for formalizing word-rewriting arguments. The decidability of the Dehornoy order would give a formally verified comparison function on braids — a tool with applications in knot theory and cryptography.

**Testable prediction**: For every braid word w of length ≤ 10 in B_3, either w is equivalent to the identity, or exactly one of w and w⁻¹ can be rewritten using only σ₂-positive occurrences of σ₂. Verify computationally.

## 3. Lawrence-Krammer Representation and Braid Linearity

While the Burau representation fails to be faithful for large n, the Lawrence-Krammer representation (into GL_{n(n-1)/2}(ℤ[q±1, t±1])) is faithful for all n (Bigelow 2001, Krammer 2002). This solved the 70-year-old problem of whether braid groups are linear.

The key insight is that faithfulness can be reduced to a finite computation for each n: one needs to show that the representation sends non-trivial braids to non-trivial matrices, which for a given n reduces to checking that certain polynomial entries are non-zero. A formalization would provide the first machine-verified proof that B_n embeds into a matrix group.

Why now? The Lawrence-Krammer representation requires matrices over a bivariate Laurent polynomial ring, which is significantly more complex than the univariate Burau case. However, Mathlib's recent improvements to polynomial ring infrastructure (MvPolynomial, LaurentPolynomial) make this increasingly tractable. Starting with n = 3 (where the representation is 3×3) would be a natural first step.

**Testable prediction**: For B_3, the Lawrence-Krammer representation is injective on all braid words of length ≤ 12. Verify by computing LK matrices for all such words and checking distinctness.

## 4. Garside Normal Form and the Conjugacy Problem

Every braid has a unique *Garside normal form* — a canonical representative of its equivalence class that can be computed in polynomial time. This normal form is the key to the algorithmic theory of braid groups, solving the word problem (are two braids equal?) and providing tools for the conjugacy problem (are two braids conjugate?).

The key insight is that the Garside normal form decomposes a braid into a power of the "Garside element" Δ (the half-twist) times a product of "simple" braids (permutation braids). The uniqueness proof relies on the lattice structure of the positive braid monoid B_n^+, where every pair of elements has a unique gcd and lcm.

Why now? Our BraidRelStep relation generates braid equivalence, but equivalence is not decidable from the presentation alone — one needs a normal form. Formalizing Garside's algorithm would give a verified decision procedure for braid equality, bridging our abstract invariant theory with computational algebra. The positive braid monoid B_n^+ can be defined as a sub-monoid of our BraidWord type restricted to positive generators.

**Testable prediction**: In B_4, every positive braid word of length ≤ 10 has a unique Garside normal form of length ≤ 10. Compute normal forms for all such words and verify uniqueness.

## 5. Topological Quantum Computing: Jones Polynomial via Braid Traces

The deepest connection between braid groups and physics is the Jones polynomial, which arises as a trace of the braid group representation into the Temperley-Lieb algebra. For a braid β ∈ B_n, the Jones polynomial of its closure (the link obtained by connecting the top and bottom endpoints) is V_β(t) = (−1)^{n-1} · t^{(n−1−w)/2} · Tr(ρ(β)), where ρ is the Temperley-Lieb representation and w is the writhe.

The key insight is that the writhe correction factor — which we have already formalized — is essential: without it, the trace is only a Markov trace (invariant under conjugation and stabilization), not a link invariant. Our writhe_braidEquiv theorem provides half of the Jones polynomial's invariance proof; the other half requires formalizing the Temperley-Lieb algebra and its trace.

Why now? The existing Catalog file BraidingUniversality.lean already contains a formalization of the Temperley-Lieb algebra. Connecting our BraidSignature framework to that existing work would create a cross-domain bridge theorem: the Jones polynomial as a composition of the braid-to-TL representation with the Markov trace, corrected by the writhe. This would be the first formally verified construction of a quantum knot invariant.

**Testable prediction**: For the trefoil braid σ₁³ ∈ B_3, the Jones polynomial of its closure equals −t⁻⁴ + t⁻³ + t⁻¹. Compute via the Temperley-Lieb trace and verify against the known value.
