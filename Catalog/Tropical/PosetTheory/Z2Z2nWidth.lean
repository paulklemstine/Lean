import Mathlib

/-!
# β(ℤ₂ × ℤ₂ⁿ): the Boolean-lattice width invariant

## Precise formulation

Let `G n := ℤ₂ × ℤ₂ⁿ` (written in Lean as `ZMod 2 × (Fin n → ZMod 2)`).  Because
`ℤ₂ × ℤ₂ⁿ ≅ ℤ₂ⁿ⁺¹`, the group `G n` is canonically the vertex set of the
`(n+1)`-dimensional discrete hypercube, equivalently the **Boolean lattice**
`B_{n+1}` (the finite poset of subsets of an `(n+1)`-element set ordered by
inclusion), whose rank of a vertex is its Hamming weight.

The *refined construction* studied here is the invariant

```
β(ℤ₂ × ℤ₂ⁿ) := C(n+1, ⌊(n+1)/2⌋),
```

the **width** of `B_{n+1}` in the sense of finite poset theory: the size of the
largest rank layer (the number of subsets of size `⌊(n+1)/2⌋`).  The `k`-th rank
layer of `B_{n+1}` is the discrete-geometry object `powersetCard k univ`, the set
of `k`-faces / weight-`k` vertices, and its cardinality is `C(n+1, k)`.

## Contribution (what is formalized and machine-checked here)

* `card_G` / `card_G_eq_cube` : the structural identification
  `|ℤ₂ × ℤ₂ⁿ| = 2^{n+1} = |ℤ₂ⁿ⁺¹|`, pinning down `G n` as the `(n+1)`-cube.
* `iso_cube` : an explicit additive-group isomorphism `ℤ₂ × ℤ₂ⁿ ≃+ ℤ₂ⁿ⁺¹`.
* `layer_card` : each rank layer `powersetCard k univ` of `B_{n+1}` has size
  `C(n+1, k)` (the level-set / `k`-face count).
* `sum_layers` : the rank layers partition the group, `∑_k C(n+1,k) = 2^{n+1}`.
* `beta_is_max` / `beta_attained` : `β` dominates every rank layer and is attained
  by the middle layer, i.e. `β` is exactly the poset width of `B_{n+1}`.
* `tropical_width_dual` : the min-plus (tropical) aggregation of the layer sizes,
  `⨁_k C(n+1,k) = min_k C(n+1,k) = 1`, is the tropical-additive dual of the width,
  which is the tropical-multiplicative (max) extremum — a min/max duality on the
  rank profile of the Boolean lattice.

All statements are elementary consequences of standard finite-poset and binomial
identities; the point is a fully verified, self-contained package rather than any
claim of depth.  The min-plus statement records the tropical reading of the rank
profile: `inf'` is exactly tropical (min-plus) addition on `ℕ`.
-/

namespace Tropical.Z2Z2nWidth

open Finset

/-- The group `ℤ₂ × ℤ₂ⁿ`. -/
abbrev G (n : ℕ) : Type := ZMod 2 × (Fin n → ZMod 2)

/-- `β(ℤ₂ × ℤ₂ⁿ)`: the width of the Boolean lattice `B_{n+1}`, i.e. the size of
its largest rank layer, the central binomial coefficient `C(n+1, ⌊(n+1)/2⌋)`. -/
def beta (n : ℕ) : ℕ := (n + 1).choose ((n + 1) / 2)

/-
The order of `ℤ₂ × ℤ₂ⁿ` is `2^{n+1}`.
-/
theorem card_G (n : ℕ) : Fintype.card (G n) = 2 ^ (n + 1) := by
  norm_num [ pow_succ' ]

/-
`ℤ₂ × ℤ₂ⁿ` has the same cardinality as the `(n+1)`-cube `ℤ₂ⁿ⁺¹`.
-/
theorem card_G_eq_cube (n : ℕ) :
    Fintype.card (G n) = Fintype.card (Fin (n + 1) → ZMod 2) := by
      simp +zetaDelta at *;
      rw [ pow_succ' ]

/-
The explicit additive-group isomorphism `ℤ₂ × ℤ₂ⁿ ≃+ ℤ₂ⁿ⁺¹` underlying the
identification of `G n` with the `(n+1)`-cube / Boolean lattice `B_{n+1}`.
-/
theorem iso_cube (n : ℕ) :
    Nonempty ((ZMod 2 × (Fin n → ZMod 2)) ≃+ (Fin (n + 1) → ZMod 2)) := by
      refine' ⟨ { Equiv.ofBijective ( fun x ↦ Fin.cons x.1 x.2 ) ⟨ fun x y h ↦ _, fun x ↦ _ ⟩ with map_add' := _ } ⟩;
      all_goals norm_num [ funext_iff, Fin.forall_fin_succ ] at *;
      · exact Prod.ext h.1 ( funext h.2 );
      · exact ⟨ _, fun i => rfl ⟩

/-
The `k`-th rank layer of the Boolean lattice `B_{n+1}` (the weight-`k`
vertices / `k`-faces) has cardinality `C(n+1, k)`.
-/
theorem layer_card (n k : ℕ) :
    (Finset.powersetCard k (Finset.univ : Finset (Fin (n + 1)))).card
      = (n + 1).choose k := by
        rw [ Finset.card_powersetCard, Finset.card_univ, Fintype.card_fin ]

/-
The rank layers partition the `2^{n+1}` group elements: `∑_k C(n+1,k) = 2^{n+1}`.
-/
theorem sum_layers (n : ℕ) :
    ∑ k ∈ Finset.range (n + 2), (n + 1).choose k = 2 ^ (n + 1) := by
      rw [ ← Nat.sum_range_choose ]

/-
`β` dominates every rank layer: it is an upper bound for the width of `B_{n+1}`.
-/
theorem beta_is_max (n k : ℕ) : (n + 1).choose k ≤ beta n := by
  apply_rules [ Nat.choose_le_middle ]

/-
`β` is attained by the middle rank layer: it is exactly the width of `B_{n+1}`.
-/
theorem beta_attained (n : ℕ) : ∃ k ≤ n + 1, (n + 1).choose k = beta n := by
  exact ⟨ ( n + 1 ) / 2, Nat.div_le_self _ _, rfl ⟩

/-
**Tropical dual of the width.** The min-plus (tropical) aggregation of the rank
profile equals `1`: `⨁_k C(n+1,k) = min_k C(n+1,k) = 1`, dual to the (max) width `β`.
-/
theorem tropical_width_dual (n : ℕ) :
    (Finset.range (n + 2)).inf'
        (Finset.nonempty_range_iff.mpr (Nat.succ_ne_zero _))
        (fun k => (n + 1).choose k) = 1 := by
          refine' le_antisymm ( Finset.inf'_le _ ( Finset.mem_range.mpr ( Nat.succ_pos _ ) ) |> le_trans <| by norm_num ) ( Finset.le_inf' _ _ _ );
          exact fun k hk => Nat.choose_pos <| Finset.mem_range_succ_iff.mp hk

end Tropical.Z2Z2nWidth