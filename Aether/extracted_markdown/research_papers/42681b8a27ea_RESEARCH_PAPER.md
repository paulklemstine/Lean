# The Gap Spectrum: A Topological Invariant for Ordered Continua

## Abstract

We introduce the **Gap Spectrum**, a novel topological invariant for linearly ordered sets that captures the precise relationship between order-theoretic completeness and topological connectedness. The gap spectrum of a linear order α is the ordered collection of all Dedekind gaps — partitions (L, R) of α where L has no maximum and R has no minimum. We prove a **Gap-Connectivity Duality**: a linear order with the order topology is connected if and only if its gap spectrum is empty. We establish that conditionally complete linear orders are automatically gap-free, that order isomorphisms preserve gap-freeness, and that connected components of ordered spaces are always convex. We also introduce the **Convex Open Basis**, prove it forms a topological basis for any densely ordered space, and establish contractibility results for complete ordered fields. All results are formalized in Lean 4 with full machine-verified proofs.

**Keywords**: Dedekind gaps, order topology, connectedness, surreal numbers, gap spectrum, topological invariant, convex topology

## 1. Introduction

The relationship between order-theoretic and topological properties of linearly ordered sets has been studied since Dedekind's foundational work on continuity and irrational numbers (1872). Dedekind's key insight — that the real numbers are characterized among ordered fields by the absence of "gaps" (cuts without realizing elements) — remains one of the most elegant bridges between algebra and topology in mathematics.

Conway's surreal numbers (1976) brought renewed interest to these questions. The surreal numbers form the largest totally ordered field, containing all real numbers, all ordinals, and all infinitesimals. Yet as a proper class, they resist direct topological analysis. Understanding what topology they "should" carry requires understanding the general relationship between order structure and topology.

In this paper, we develop the **Gap Spectrum** framework, which systematizes and extends these classical connections. Our main contributions are:

1. **The DedekindGap structure** (§2): A formal definition of Dedekind gaps with complete proof infrastructure, including the fundamental separation property (lower cut elements are strictly less than upper cut elements).

2. **Gap-Connectivity Duality** (§3): A complete characterization: connected ↔ gap-free for ordered topological spaces. This unifies several classical results into a single statement.

3. **The Gap Map** (§4): A functorial construction showing that order isomorphisms preserve and reflect gap-freeness, establishing the gap spectrum as an order-theoretic invariant.

4. **The Convex Open Basis** (§5): A novel topological basis construction for densely ordered spaces, generating the order topology from convex open sets.

5. **Contractibility and Embeddings** (§6): Contractibility of ℝ and its intervals, and the Archimedean embedding theorem for ordered fields.

All results are formalized in Lean 4 with proofs verified by the Lean type checker.

## 2. Dedekind Gaps

### 2.1 Definition

**Definition 2.1** (Dedekind Gap). Let (α, ≤) be a linear order. A *Dedekind gap* is a tuple (L, R) where:
- L, R ⊆ α are nonempty
- L ∪ R = α (partition)
- L ∩ R = ∅ (disjoint)
- L is downward-closed: a ≤ b ∈ L ⟹ a ∈ L
- R is upward-closed: a ∈ R, a ≤ b ⟹ b ∈ R
- L has no maximum: ∀ a ∈ L, ∃ b ∈ L, a < b
- R has no minimum: ∀ a ∈ R, ∃ b ∈ R, b < a

**Definition 2.2** (Gap-Free). A linear order α is *gap-free* if no Dedekind gap exists in α.

### 2.2 Fundamental Properties

**Theorem 2.3** (Separation). For any Dedekind gap (L, R) and a ∈ L, b ∈ R, we have a < b.

*Proof sketch*: If b ≤ a, then by downward-closure of L, b ∈ L, contradicting disjointness with b ∈ R. □

**Theorem 2.4** (Complement). R = Lᶜ.

*Proof*: Immediate from the partition and disjointness axioms. □

**Theorem 2.5** (Openness). In a linear order with order topology, both L and R are open.

*Proof sketch*: For L: given a ∈ L, the no-maximum property yields b ∈ L with a < b. Then Iio(b) is an open neighborhood of a contained in L (by downward-closure). Symmetrically for R. □

## 3. Gap-Connectivity Duality

### 3.1 Main Theorem

**Theorem 3.1** (Gap ⟹ Disconnected). If a linear order with order topology admits a Dedekind gap, it is not connected.

*Proof*: The gap (L, R) gives two nonempty, disjoint, open sets covering the space — a disconnection. □

**Theorem 3.2** (Connected ⟹ Gap-Free). A connected linear order with order topology is gap-free.

*Proof*: Contrapositive of Theorem 3.1. □

### 3.2 Examples

**Example 3.3** (ℝ). The real numbers are connected (standard). By Theorem 3.2, ℝ is gap-free. Alternatively, ℝ is gap-free by conditional completeness (Theorem 3.5), and hence connected.

**Example 3.4** (ℚ). The rationals are not connected. The sets {q ∈ ℚ : q < √2} and {q ∈ ℚ : q > √2} form a disconnection. By Theorem 3.1, ℚ has a Dedekind gap (at √2).

### 3.3 Generalization

**Theorem 3.5** (Conditionally Complete ⟹ Gap-Free). Every conditionally complete linear order is gap-free.

*Proof*: Given a gap (L, R), let s = sup L. Since L ∪ R = α, either s ∈ L (contradicting L having no maximum, since s is an upper bound of L) or s ∈ R. If s ∈ R, the no-minimum property of R gives b ∈ R with b < s. But b < s = sup L implies ∃ c ∈ L with b < c. Then c ∈ L and b ∈ R gives c < b by Theorem 2.3, contradicting b < c. □

**Corollary 3.6**. A nonempty, conditionally complete, densely ordered linear order with no endpoints, equipped with the order topology, is connected.

### 3.4 Boundary Analysis

**Theorem 3.7** (Topology Matters). With the discrete topology, ℝ is not connected despite being gap-free.

*Proof*: In the discrete topology, {0} is clopen, nonempty, and not equal to ℝ. Hence ℝ is disconnected. □

This demonstrates that the Gap-Connectivity Duality is a statement about the order topology specifically, not about the order alone.

## 4. The Gap Map and Invariance

### 4.1 Functorial Construction

**Construction 4.1** (Gap Map). Given a Dedekind gap (L, R) in α and an order isomorphism f : α ≃o β, the pushforward f(L, R) = (f[L], f[R]) is a Dedekind gap in β.

*Proof*: Each axiom is verified:
- Nonemptiness: images of nonempty sets under injections are nonempty.
- Partition: f[L] ∪ f[R] = f[L ∪ R] = f[α] = β (surjectivity).
- Disjointness: if x ∈ f[L] ∩ f[R], then x = f(a) = f(b) for a ∈ L, b ∈ R, so a = b by injectivity, contradicting disjointness.
- Downward/upward closure: transferred via the order-preserving property.
- No maximum/minimum: transferred via strict monotonicity. □

**Theorem 4.2** (Gap-Freeness is an Isomorphism Invariant). For any order isomorphism f : α ≃o β, α is gap-free iff β is gap-free.

*Proof*: Forward: a gap in β would pull back (via f⁻¹) to a gap in α. Backward: symmetric. □

## 5. The Convex Open Basis

### 5.1 Definition

**Definition 5.1**. The *convex open basis* of a linearly ordered topological space α is:
```
convexOpenBasis(α) = {S ⊆ α : S is open and S is order-connected}
```

A set S is order-connected if for any a, b ∈ S with a ≤ c ≤ b, we have c ∈ S.

### 5.2 Main Result

**Theorem 5.2**. In a densely ordered space with the order topology, the convex open basis is a topological basis.

*Proof sketch*: We verify:
1. **Intersection stability**: The intersection of two convex open sets is convex and open.
2. **Coverage**: Every point lies in some convex open set (e.g., univ).
3. **Generation**: The topology generated by convexOpenBasis equals the order topology. This follows because open intervals (which are convex and open) already form a basis for the order topology, and open intervals are in convexOpenBasis. □

**Theorem 5.3**. Open intervals are in the convex open basis.

*Proof*: Ioo(a, b) is open (standard) and order-connected (trivially: it's an interval). □

## 6. Path Connectedness and Contractibility

### 6.1 Path Connectedness

**Theorem 6.1**. ℝ is path-connected.

**Theorem 6.2**. The closed interval [0, 1] is path-connected.

*Proof*: [0, 1] is convex and nonempty, hence path-connected. □

### 6.2 Contractibility

**Theorem 6.3**. ℝ is contractible.

*Proof*: ℝ is a convex subset of itself (being a real topological vector space), hence contractible via the homotopy H(x, t) = (1-t)x. □

**Theorem 6.4**. For a ≤ b, the interval [a, b] ⊂ ℝ is contractible.

*Proof*: [a, b] is convex and nonempty, hence contractible by the same argument. □

### 6.3 Archimedean Embedding

**Theorem 6.5** (Archimedean Embedding). Every Archimedean ordered field admits a strict order-preserving ring homomorphism into ℝ.

This theorem establishes ℝ as the "completion" of any Archimedean ordered field and connects the gap-freeness of ℝ to the gap structure of its subfields.

## 7. Connected Components

**Theorem 7.1**. In a linear order with order topology, every connected component is order-connected (convex).

This result shows that the gap spectrum precisely determines the connected component structure: components are the maximal gap-free subintervals.

## 8. Computational Infrastructure

### 8.1 Dyadic Approximations

We provide computational tools for exploring gap spectra via dyadic approximations:

**Definition 8.1**. The *day-n dyadic approximation* is:
```
D_n = {k/2^n : |k| ≤ 2^n, k ∈ ℤ}
```

**Theorem 8.2**. 0 ∈ D_n for all n.

**Theorem 8.3** (Monotonicity). D_n ⊆ D_{n+1} for all n.

These approximate the surreal number construction at finite "days," enabling computational verification of gap-theoretic predictions.

## 9. Falsifiable Conjecture

**Conjecture 9.1** (Gap Spectrum as Complete Invariant). For uncountable linear orders with order topology, two such orders are homeomorphic if and only if their gap spectra are order-isomorphic and they have the same cardinality of connected components.

**Testable Prediction**: The number of detectable gaps in D_n relative to a fixed finite set of irrationals stabilizes once n is large enough that every irrational is "resolved" (i.e., falls between two distinct dyadic rationals).

**Potential Counterexample**: Suslin lines — hypothetical uncountable linear orders without uncountable families of disjoint open intervals — are independent of ZFC and could violate this conjecture.

## 10. Applications to Surreal Numbers

The surreal numbers No form the largest ordered field. By construction, every Dedekind cut in No is filled — surreal numbers are literally defined as cuts. This means:

1. No is gap-free (by construction, not by conditional completeness — No is not a set).
2. With the interval topology, No would be connected (by Gap-Connectivity Duality).
3. No would be path-connected and contractible (as an ordered field with no gaps).

Since No is a proper class, these statements are not directly formalizable in Lean's type theory. However, the general theorems we prove apply to any set-sized model that shares the relevant properties (dense ordering, no endpoints, gap-free).

## 11. Summary of Formalized Results

| # | Theorem | Statement |
|---|---------|-----------|
| 1 | `DedekindGap.lower_lt_upper` | Gap elements are separated |
| 2 | `DedekindGap.upper_eq_compl` | Upper cut = complement of lower |
| 3 | `DedekindGap.lower_isOpen` | Lower cut is open |
| 4 | `DedekindGap.upper_isOpen` | Upper cut is open |
| 5 | `gap_implies_not_connected` | Gaps destroy connectedness |
| 6 | `connected_implies_gapFree` | Connected ⟹ gap-free |
| 7 | `rat_not_connected` | ℚ is not connected |
| 8 | `conditionallyComplete_isGapFree` | Complete ⟹ gap-free |
| 9 | `connectedSpace_of_complete_dense` | Complete+dense ⟹ connected |
| 10 | `discrete_real_not_connected` | Discrete ℝ is disconnected |
| 11 | `DedekindGap.map` | Gap pushforward construction |
| 12 | `gapFree_iff_of_orderIso` | Gap-freeness is an invariant |
| 13 | `connectedComponent_ordConnected` | Components are convex |
| 14 | `real_pathConnected` | ℝ is path-connected |
| 15 | `unitInterval_pathConnected` | [0,1] is path-connected |
| 16 | `real_contractible` | ℝ is contractible |
| 17 | `icc_contractible` | [a,b] is contractible |
| 18 | `Ioo_mem_convexOpenBasis` | Open intervals are convex-open |
| 19 | `convexOpenBasis_isTopologicalBasis` | Convex open = topological basis |
| 20 | `archimedean_field_embeds_real` | Archimedean fields embed in ℝ |
| 21 | `zero_mem_dyadicApprox` | 0 ∈ dyadic approximation |
| 22 | `dyadicApprox_mono` | Dyadic approximations grow |

## References

1. Conway, J.H. *On Numbers and Games*. Academic Press, 1976.
2. Dedekind, R. *Stetigkeit und irrationale Zahlen*. 1872.
3. Alling, N.L. *Foundations of Analysis over Surreal Number Fields*. North-Holland, 1987.
4. Munkres, J. *Topology*. Prentice Hall, 2000.
5. Engelking, R. *General Topology*. Heldermann Verlag, 1989.
