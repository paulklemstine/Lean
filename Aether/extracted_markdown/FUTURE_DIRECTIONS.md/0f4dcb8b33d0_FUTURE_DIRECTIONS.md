# Future Directions: Large Cardinal Hierarchy

## 1. Measurable Cardinals are Strongly Inaccessible

**Conjecture**: Every measurable cardinal is strongly inaccessible (regular + strong limit).

The key insight is that the κ-complete nonprincipal ultrafilter impossibility result (`no_kappa_complete_nonprincipal_on_small`) can be leveraged to prove both regularity and the strong limit property. For regularity: if κ were singular with cf(κ) = λ < κ, partition κ into λ-many pieces each of size < κ; one piece must be in U by κ-completeness, but then we have a nonprincipal κ-complete ultrafilter on a set of size < κ — contradiction. For strong limit: if λ < κ but 2^λ ≥ κ, encode each ordinal below κ as a distinct subset of λ; use U to pick a "generic" subset and show it equals all but one encoded ordinal — contradiction.

**Why now?** The foundational `measurable_ultrafilter_compl_small` and `no_kappa_complete_nonprincipal_on_small` lemmas are now proved, providing the exact tools needed. The partition argument for regularity requires formalizing cofinal sequences in ordinals, which Mathlib's `Ordinal.cof` supports. This is the natural next step that would complete the measurable → inaccessible implication formally.

## 2. Club Filter Closure Properties

**Conjecture**: For any regular uncountable cardinal κ, the intersection of two club subsets of κ is club, and the club sets generate a proper normal filter on κ (the "club filter").

The key insight is that unboundedness of the intersection follows from a "ping-pong" construction: alternately pick elements from each club, forming an ω-sequence whose supremum (which is < κ by regularity since cf(κ) > ω) lies in both clubs by closure. The club filter is then κ-complete, and the dual ideal (nonstationary sets) is the nonstationary ideal, which is a proper ideal.

**Why now?** The `IsClub` and `IsStationary` definitions are formalized with ω-sequence closure, which is exactly the right formulation for the ping-pong argument. Mathlib's ordinal cofinality (`Ordinal.cof`) and supremum (`iSup`) APIs provide the needed arithmetic. Proving this would unlock Fodor's pressing-down lemma and the full theory of stationary reflection.

## 3. Measurable implies Mahlo (Full Implication)

**Conjecture**: Every measurable cardinal is Mahlo, completing the formal verification of the implication chain measurable → Mahlo → inaccessible.

The key insight is that measurability provides not just inaccessibility but stationarity of inaccessibles below κ: if C is a club of ordinals below κ, then C ∈ U (the measurable ultrafilter, transferred to ordinals via `Ordinal.card`); similarly the set of inaccessibles below κ must be large (in the ultrafilter sense), hence stationary. The ultrafilter witnesses that "most" cardinals below κ are inaccessible.

**Why now?** With `measurable_ultrafilter_compl_small` proved, we know small sets are not in U. The connection between the ultrafilter and club sets requires showing that club sets have cardinality κ (hence are in U). This builds on Direction 2 (club filter theory) and Direction 1 (measurable → inaccessible).

## 4. The Ulam Matrix and Non-Measurability of Successor Cardinals

**Conjecture**: No successor cardinal κ⁺ carries a κ⁺-complete nonprincipal ultrafilter (hence no successor cardinal is measurable).

The key insight is the Ulam matrix construction: given a surjection f : κ⁺ → κ (which exists since κ⁺ = κ ∪ {cofinally many}... more precisely since |κ| < κ⁺), we build a κ × κ⁺ matrix of sets that forms a partition of κ⁺ into κ-many families, each of size ≤ κ. Any κ⁺-complete ultrafilter must contain one row, but that row has ≤ κ elements, giving a nonprincipal ultrafilter on a set of size ≤ κ < κ⁺ — contradiction via `no_kappa_complete_nonprincipal_on_small`.

**Why now?** The impossibility lemma is proved. The main new ingredient is the Ulam matrix, which is a combinatorial construction on cardinals and successor cardinals. This would be a significant formalization contribution since it connects cardinal arithmetic to the measurability question and is a key result in Jech's "Set Theory" (Chapter 10).

## 5. Transfinite Mahlo Hierarchy (α-Mahlo Cardinals)

**Conjecture**: Define the α-Mahlo hierarchy for all ordinals α by transfinite recursion: κ is 0-Mahlo if inaccessible, and (α+1)-Mahlo if α-Mahlo and the set of α-Mahlo cardinals below κ is stationary; κ is λ-Mahlo (limit λ) if α-Mahlo for all α < λ. Then for each ordinal α, if κ is (α+1)-Mahlo, it is α-Mahlo.

The key insight is that this hierarchy is strict: the consistency strength of "∃ an (α+1)-Mahlo" strictly exceeds "∃ an α-Mahlo" for each α, by Gödel's second incompleteness theorem. The formal challenge is defining this hierarchy by well-founded recursion on ordinals within Lean's type theory, using the `IsStationary` predicate.

**Why now?** We have `Cardinal.IsMahlo` and `Cardinal.IsOneMahlo` as the base cases. The generalization to all ordinals requires `Ordinal.rec` or well-founded recursion on ordinals, which Mathlib supports. This would formalize the first infinite fragment of the large cardinal hierarchy as a single recursive definition, demonstrating that the hierarchy has "depth" — it doesn't collapse after finitely many levels.
