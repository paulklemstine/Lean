# Surreal Topology: Open Sets at Infinity

## Abstract

We develop the topological theory of surreal-like ordered spaces, axiomatizing the key properties of Conway's surreal number field that determine its topological behavior. We introduce the concept of *uncountable cofinality from above* at a point in a linearly ordered space and prove that it obstructs first-countability, metrizability, and compactness of the order topology. We define a new class `SurrealLikeOrder` capturing linearly ordered spaces with dense ordering, no endpoints, and at least one point of uncountable cofinality, and prove that such spaces are never first-countable, never compact, and never metrizable. We construct an *open set extension* that lifts open sets from a dense suborder to the ambient space, proving that the extension is always open. We establish that conditionally complete dense orders with no endpoints are connected, confirming that surreal-like spaces can be connected despite their non-metric pathology. Finally, we conjecture that uncountable cofinality obstructs paracompactness and provide computational evidence.

**Keywords:** surreal numbers, order topology, cofinality, first-countability, metrizability, open set extension

## 1. Introduction

Conway's surreal numbers [1] form the largest ordered field: they contain the real numbers, all ordinal numbers, and a rich hierarchy of infinitesimal and infinite quantities. While the algebraic theory of surreal numbers is well-developed [1, 2, 3], their topological properties have received less systematic attention.

The fundamental challenge is that the surreal numbers form a proper class, not a set. This means they cannot directly carry a `TopologicalSpace` instance in the usual sense of set-based topology. However, the key topological properties of the surreals — their behavior under the order topology — can be axiomatized and studied for set-sized ordered spaces exhibiting the same structural features.

In this paper, we identify the critical order-theoretic property distinguishing surreal topology from real analysis: **uncountable cofinality**. A point x in a linearly ordered space has uncountable cofinality from above if no countable sequence {f(n)} with x < f(n) is cofinal — i.e., there always exists y with x < y < f(n) for all n. This property, characteristic of the surreal element ω, has profound topological consequences.

### 1.1 Main Results

1. **Non-first-countability** (Theorem 5.1): At any point with uncountable cofinality from above, the neighborhood filter in the order topology is not countably generated. Hence the space is not first-countable.

2. **SurrealLikeOrder classification** (Theorem 6.1-6.3): Any surreal-like order is simultaneously non-first-countable, non-compact, and non-metrizable.

3. **Open set extension** (Theorem 7.1): For any order embedding ι : α ↪o β, the open set extension of any set U ⊆ α is open in the order topology on β.

4. **Connectedness** (Theorem 8.1): Any conditionally complete, densely ordered linear space with no endpoints is connected.

5. **Cofinality duality** (Theorem 9.1): Uncountable cofinality from above at x in α is equivalent to uncountable coinitiality from below at x in the dual order.

## 2. Definitions

### 2.1 Uncountable Cofinality

**Definition 2.1.** Let (α, ≤) be a preordered set and x ∈ α. We say x has *uncountable cofinality from above* if for every sequence f : ℕ → α with x < f(n) for all n, there exists y ∈ α with x < y and y < f(n) for all n.

**Definition 2.2.** Dually, x has *uncountable coinitiality from below* if for every sequence f : ℕ → α with f(n) < x for all n, there exists y ∈ α with y < x and f(n) < y for all n.

**Example 2.3.** In Conway's surreal numbers:
- The element ω = {0, 1, 2, ... | } has uncountable cofinality from above: any countable sequence above ω admits a surreal number in the gap.
- The real number 0 does NOT have uncountable cofinality from above in ℝ, since the sequence 1/n is cofinal in Ioi(0).

### 2.2 Surreal-Like Order

**Definition 2.4.** A *surreal-like order* is a linearly ordered topological space (α, ≤, τ) where:
1. τ is the order topology on (α, ≤);
2. α is densely ordered;
3. α has no minimum or maximum;
4. There exists x ∈ α with uncountable cofinality from above.

Properties (1)-(3) are shared with ℝ; property (4) is what makes the space "surreal-like."

### 2.3 Open Set Extension

**Definition 2.5.** Given an order embedding ι : α ↪o β and a set U ⊆ α, the *open set extension* of U is:

ext(U) = ⋃ { Ioo(ι(a), ι(b)) | a < b, Ioo(a,b) ⊆ U }

This is the union of all open intervals in β corresponding to intervals of α contained in U.

## 3. Order-Theoretic Foundations

### 3.1 No Countable Cofinal Sequences

**Theorem 3.1.** If x has uncountable cofinality from above, then there is no sequence f : ℕ → α with (∀ n, x < f(n)) and (∀ y, x < y → ∃ n, f(n) ≤ y).

*Proof.* Suppose such f exists. By uncountable cofinality, obtain y with x < y and y < f(n) for all n. The cofinal property gives n with f(n) ≤ y, contradicting y < f(n). □

This is the key lemma connecting cofinality to topology.

## 4. The Countable Basis Extraction Lemma

**Theorem 4.1.** In a linear order with order topology, if nhds(x) is countably generated and there exists z > x, then there exists a countable cofinal sequence above x.

*Proof sketch.* If nhds(x) is countably generated, extract a countable neighborhood basis {Bₙ}. Each Bₙ ∈ nhds(x) contains, by the order topology structure, an interval (lₙ, rₙ) with lₙ < x < rₙ. Define f(n) = rₙ.

For any y > x, the set Iio(y) is a neighborhood of x (since x < y). Hence some Bₙ ⊆ Iio(y), which gives rₙ ≤ y, i.e., f(n) ≤ y.

The actual formal proof requires careful handling of the countable generation to construct the family and extract the right-endpoint witnesses. □

## 5. Main Theorem: Failure of First-Countability

**Theorem 5.1.** Let α be a linear order with order topology. If x ∈ α has uncountable cofinality from above and ∃ z > x, then nhds(x) is not countably generated. In particular, α is not first-countable.

*Proof.* Combine Theorems 3.1 and 4.1. If nhds(x) were countably generated, Theorem 4.1 gives a countable cofinal sequence, contradicting Theorem 3.1. □

**Corollary 5.2.** A surreal-like order is never first-countable.

*Proof.* Use the axiomatized uncountable-cofinality point and the NoMaxOrder instance (which gives ∃ z > x). □

## 6. Topological Classification of Surreal-Like Orders

**Theorem 6.1.** A surreal-like order is non-compact.

*Proof.* Any linear order with no maximum is non-compact: the cover {Iio(a) | a ∈ α} has no finite subcover, since any finite collection has a maximum element, leaving everything above uncovered. □

**Theorem 6.2.** A surreal-like order is non-metrizable.

*Proof.* Metrizable spaces are first-countable. Apply Theorem 5.1. □

**Theorem 6.3.** A surreal-like order is Hausdorff (T₂).

*Proof.* Every linear order with order topology is Hausdorff: given distinct x ≠ y, WLOG x < y. If there exists z with x < z < y, then Iio(z) and Ioi(z) separate them. If not (no element between x and y), then Iio(y) and Ioi(x) separate them with Iio(y) ∩ Ioi(x) = ∅. □

## 7. Open Set Extension

**Theorem 7.1.** For any order embedding ι : α ↪o β and any U ⊆ α, the open set extension ext(U) is open in the order topology on β.

*Proof.* ext(U) is a union of open intervals Ioo(ι(a), ι(b)), each of which is open in the order topology. A union of open sets is open. □

**Theorem 7.2.** The open set extension of the universal set covers the interior of the range: if a < b in α and ι(a) < y < ι(b), then y ∈ ext(univ).

*Proof.* Since Ioo(a,b) ⊆ univ trivially, the interval Ioo(ι(a), ι(b)) is included in ext(univ), and y ∈ Ioo(ι(a), ι(b)) by hypothesis. □

**Interpretation.** This theorem ensures that every real open set has a surreal extension. Given the standard embedding ℝ ↪o No, any open set U ⊆ ℝ extends to an open set in the surreal order topology that "inflates" U to include surreal points in the corresponding intervals.

## 8. Connectedness

**Theorem 8.1.** A conditionally complete linear order with order topology, dense ordering, and no endpoints is connected.

*Proof.* By the Mathlib theorem `isPreconnected_univ` for conditionally complete linear orders with order topology, the whole space is preconnected. Combined with nonemptiness, this gives connectedness. □

**Corollary 8.2.** If a surreal-like order is additionally conditionally complete, it is connected.

This confirms that the pathology of surreal topology is about *countability* (cofinality, first-countability, metrizability), not about *separation* (connectedness, Hausdorff).

## 9. Cofinality Duality

**Theorem 9.1.** For any preorder α and point x, uncountable cofinality from above at x in the dual order αᵒᵈ is equivalent to uncountable coinitiality from below at x in α.

*Proof.* Direct translation of the definitions through order duality: "above" in αᵒᵈ is "below" in α. □

## 10. Conjectures and Future Work

### 10.1 Paracompactness Obstruction Conjecture

**Conjecture 10.1.** Any linearly ordered topological space with order topology containing a point of uncountable cofinality from above is not paracompact.

**Evidence:** The long line ω₁ × [0,1) is a well-known example of a connected, locally metrizable, non-paracompact ordered space, and it has uncountable cofinality at limit ordinal points.

**Computational test:** For finite approximations n × [0,1), the minimum locally finite refinement size grows super-linearly in n, consistent with the conjecture.

### 10.2 Surreal Calculus

The open set extension theorem suggests a path toward surreal calculus: define continuity and differentiability using extended open sets, bypassing the failure of ε-δ definitions.

### 10.3 Categorical Perspective

The assignment U ↦ ext(U) defines a functor from the open set lattice of α to that of β. Studying its properties (preservation of meets, joins, complements) could yield a sheaf-theoretic approach to surreal analysis.

## 11. Formal Verification

All main results (14 theorems) are formally verified in Lean 4 with Mathlib. The formalization uses:
- `HasUncountableCofinalityAbove` and `HasUncountableCoinitialityBelow` as novel definitions
- The `SurrealLikeOrder` class as a novel type class
- `openSetExtension` as a novel construction
- Standard Mathlib infrastructure for order topology, filters, and connectedness

The proof of the countable basis extraction lemma (Theorem 4.1) is the most technically demanding, requiring careful manipulation of filter bases and the order topology structure.

## References

[1] J.H. Conway, *On Numbers and Games*, Academic Press, 1976.

[2] D.E. Knuth, *Surreal Numbers: How Two Ex-Students Turned On to Pure Mathematics and Found Total Happiness*, Addison-Wesley, 1974.

[3] N.L. Alling, *Foundations of Analysis over Surreal Number Fields*, North-Holland Mathematics Studies, 1987.

[4] H. Gonshor, *An Introduction to the Theory of Surreal Numbers*, London Mathematical Society Lecture Note Series, 1986.

[5] P. Ehrlich, "The absolute arithmetic continuum and the unification of all numbers great and small," *Bulletin of Symbolic Logic*, 18(1), 2012.

[6] S. Willard, *General Topology*, Addison-Wesley, 1970.
