# Future Directions: Closure-Extractor-Syndrome Duality

## 1. Submodular Capacity from Matroid-Like Rule Presentations

**Status**: Open — key structural gap

**Problem**: The rule-count capacity `ruleCount(rules, cl(A))` is NOT submodular for
arbitrary rule sets. We proved this by counterexample: rules whose premises span
elements from `A\B` and `B\A` can violate the lattice inequality.

**Next Step**: Characterize precisely which rule sets yield submodular capacity.

**Conjecture**: If the rule set forms a *matroid presentation* — where every rule
has a unique conclusion not in its premises, and the closure satisfies the
Steinitz-Mac Lane exchange property — then `ruleCount ∘ cl` is submodular.

**Proof Strategy**:
1. Show that exchange closure implies the rank function `ρ(A) = |cl(A)| - |A|` is
   submodular.
2. Express `ruleCount` as a function of `ρ` for matroid presentations.
3. Derive submodularity of `ruleCount ∘ cl` from submodularity of `ρ`.

**Lean Statement**:
```lean
theorem matroid_rules_give_submodular_cap
    (rules : Finset (Finset X × X))
    (h_exchange : ∀ A x y, y ∈ implClosure rules (A ∪ {x}) →
      y ∉ implClosure rules A → x ∈ implClosure rules (A ∪ {y})) :
    ∀ A B, ruleCount rules (implClosure rules (A ∪ B)) +
           ruleCount rules (implClosure rules (A ∩ B)) ≤
           ruleCount rules (implClosure rules A) +
           ruleCount rules (implClosure rules B) := sorry
```

## 2. Categorical Equivalence on Parity-Realizable Subcategory

**Status**: Foundation laid — categorical structure needed

**Problem**: Define a category `ParityRealizable` of closure-capacity objects
that admit parity-check realizations, and a category `CanonicalPC` of canonical
minimal parity-check presentations modulo column permutation. Prove these
categories are equivalent.

**Key Insight**: The round-trip theorem already provides the unit of an adjunction.
The missing piece is the counit: showing that applying closure-shadow to a
canonical presentation and then reconstructing gives back the same presentation.

**Proof Strategy**:
1. Define morphisms as closure-preserving maps that are capacity-non-increasing.
2. Show the reconstruction functor is left adjoint to the closure-shadow functor.
3. Prove the unit and counit are natural isomorphisms on the subcategory.

**Impact**: This would be a Tannaka-type reconstruction theorem for coding theory.

## 3. q-ary Syndrome Semimodules

**Status**: Binary case done — generalization straightforward but nontrivial

**Problem**: Extend from `ZMod 2` to `ZMod q` for prime `q`. The closure
semantics changes: instead of "any support element determines the rest,"
we get "the linear combination over `GF(q)` determines elements."

**Key Difference**: Over `GF(q)`, the closure of `{x₁, ..., xₖ}` includes
all elements that are `GF(q)`-linear combinations of the rows restricted
to `{x₁, ..., xₖ}`. This is strictly richer than the binary case.

**Lean Statement**:
```lean
def qaryImplClosure (q : ℕ) [Fact q.Prime]
    (H : Matrix (Fin r) X (ZMod q)) (A : Finset X) : Finset X :=
  Finset.univ.filter (fun x =>
    ∀ v : X → ZMod q, (∀ i, ∑ j, H i j * v j = 0) →
      (∀ a ∈ A, v a = 0) → v x = 0)
```

## 4. Cryptographic Leakage Bounds from Capacity

**Status**: Conceptual — needs formalization

**Problem**: In the extractor/leakage model, the capacity `cap(A)` measures how
much syndrome information leaks about the complement `X \ A`. The capacity
increment `capIncrement(A, x) = 0` means "x reveals no additional syndrome
information given A."

**Concrete Application**: For a secret-sharing scheme based on a linear code C
with parity-check H:
- `cap(A)` = number of parity constraints satisfied by the shares in A
- `cap(A) = cap(cl(A))` means the leakage depends only on the closure class
- Submodularity bounds the joint leakage of combined share sets

**Next Step**: Formalize the min-entropy bound:
```
H_∞(secret | shares_A) ≥ log₂(|C|) - cap(A)
```
This would connect the capacity-increment characterization to quantitative
cryptographic security.

## 5. Tropical Spectral Invariants

**Status**: Speculative — high potential impact

**Problem**: The capacity function `cap : P(X) → ℕ` can be viewed as a tropical
polynomial. The "tropical spectrum" of a closure-capacity object would be the
set of capacity values attained, together with the multiplicity structure.

**Conjecture**: Two closure-capacity objects are isomorphic iff they have the
same tropical spectrum (up to permutation of the ground set).

**Connection**: This relates to the existing `PadicClosureInformationDuality`
module, which establishes ultrametric information functionals as tropicalizations
of closure capacities.

**Proof Strategy**: Use the capacity-increment characterization: the tropical
spectrum determines the closure lattice (via zero increments), and the closure
lattice plus capacity values determine the object up to isomorphism.

## 6. Polynomial-Time Reconstruction Algorithm

**Status**: Algorithm clear — complexity analysis needed

**Problem**: Given a closure oracle `cl` and capacity oracle `cap` on a finite
set of size n, reconstruct a minimal implication presentation in polynomial time.

**Algorithm Sketch**:
1. Compute the lattice of closed sets by bottom-up closure (O(2ⁿ) in general,
   but O(n² · |closed sets|) with incremental generation)
2. For each pair (C₁, C₂) of closed sets with C₁ ⊂ C₂ and no intermediate
   closed set, extract a rule (C₁, x) for each x ∈ C₂ \ C₁
3. Minimize by removing redundant rules (greedy)

**Complexity**: O(n² · L) where L is the number of closed sets. For matroid-like
presentations, L = O(nᵏ) for rank k.

## 7. Decoding Complexity from Closure Capacity

**Status**: New research direction

**Problem**: The capacity increment structure determines the syndrome decoding
complexity. Specifically:
- `capIncrement(A, x) = 0` means x is "free" given A — no decoding needed
- `capIncrement(A, x) > 0` means x requires active syndrome computation

**Conjecture**: The maximum-likelihood decoding complexity of a code C with
parity-check H is bounded by:
```
complexity(C) ≥ max_A Σ_{x ∉ cl(A)} capIncrement(A, x)
```

This would connect closure-capacity theory to algorithmic coding theory.

## Summary

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|--------------|
| Submodular characterization | Medium | High | None |
| Categorical equivalence | Hard | Very high | Direction 1 |
| q-ary extension | Medium | High | None |
| Cryptographic bounds | Medium | High | None |
| Tropical spectrum | Hard | Very high | Direction 1 |
| Reconstruction algorithm | Medium | Medium | None |
| Decoding complexity | Hard | High | Direction 1 |

**Recommended order**: 1 → 3 → 4 → 6 → 2 → 5 → 7
