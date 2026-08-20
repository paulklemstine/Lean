import Bridges.DominationPackingRatio

/-!
# Tightness of the domination–packing duality on paths

`Bridges.DominationPackingRatio` proves the general inequality `ρ(G) ≤ γ(G)` and Erdős–Pósa type
upper bounds `γ ≤ c·ρ`.  This file settles the *other* extreme: on paths the duality is exact,

`γ(Pₙ) = ρ(Pₙ) = ⌈n/3⌉ = (n+2)/3`  (`pathGraph_dominationNumber_eq_packingNumber`),

the case `c = 1` of the Erdős–Pósa hierarchy.  Combined with the Wagner graph (`γ/ρ = 3`) and
the `4`-cycle (`γ/ρ = 2`, a unit disk graph) this pins down the extremes that any bound of the
form `γ ≤ c·ρ` has to accommodate.

The upper bound `ρ ≤ γ` is the general duality; for the lower bound we exhibit the explicit
packing `{v : Fin n | v ≡ 0 mod 3}`, whose radius-`1` balls `{v-1, v, v+1}` are pairwise
disjoint, and compute its cardinality.  The value of `γ(Pₙ)` is taken from the catalog result
`dominationNumber_pathGraph_eq`.

We also record the existential ("Erdős–Pósa") form of the unit disk bound.
-/

namespace DominationPacking

open Finset SimpleGraph

/-! ## Counting the residue-`0` vertices of a path -/

lemma card_range_filter_mod_three (n : ℕ) :
    ((Finset.range n).filter (fun m => m % 3 = 0)).card = (n + 2) / 3 := by
  induction n with
  | zero => simp
  | succ k ih =>
    rw [Finset.range_add_one, Finset.filter_insert]
    by_cases h : k % 3 = 0
    · rw [if_pos h, Finset.card_insert_of_notMem (by simp), ih]
      omega
    · rw [if_neg h, ih]
      omega

lemma card_univ_filter_mod_three (n : ℕ) :
    (Finset.univ.filter (fun v : Fin n => v.val % 3 = 0)).card = (n + 2) / 3 := by
  classical
  rw [← card_range_filter_mod_three n]
  have himg : (Finset.univ.filter (fun v : Fin n => v.val % 3 = 0)).image Fin.val
      = (Finset.range n).filter (fun m => m % 3 = 0) := by
    ext m
    simp only [Finset.mem_image, Finset.mem_filter, Finset.mem_univ, true_and,
      Finset.mem_range]
    constructor
    · rintro ⟨v, hv, rfl⟩
      exact ⟨v.isLt, hv⟩
    · rintro ⟨hm, hmod⟩
      exact ⟨⟨m, hm⟩, hmod, rfl⟩
  rw [← himg, Finset.card_image_of_injective _ Fin.val_injective]

/-! ## The explicit packing of a path -/

lemma mem_ball_pathGraph {n : ℕ} {u w : Fin n} (h : w ∈ ball (pathGraph n) u) :
    w.val = u.val ∨ w.val + 1 = u.val ∨ u.val + 1 = w.val := by
  rcases h with rfl | hadj
  · exact Or.inl rfl
  · rw [pathGraph_adj] at hadj
    rcases hadj with h | h
    · exact Or.inr (Or.inr h)
    · exact Or.inr (Or.inl h)

/-- The vertices of a path with index divisible by `3` form a packing. -/
theorem isPacking_pathGraph_mod_three (n : ℕ) :
    IsPacking (pathGraph n) (Finset.univ.filter (fun v : Fin n => v.val % 3 = 0)) := by
  classical
  intro u hu v hv huv
  rw [Finset.mem_filter] at hu hv
  rw [Set.disjoint_left]
  intro w hwu hwv
  have h1 := mem_ball_pathGraph hwu
  have h2 := mem_ball_pathGraph hwv
  have huv' : u.val ≠ v.val := fun h => huv (Fin.ext h)
  omega

/-- **The packing number of a path** is `⌈n/3⌉ = (n+2)/3`. -/
theorem pathGraph_packingNumber (n : ℕ) : packingNumber (pathGraph n) = (n + 2) / 3 := by
  classical
  refine le_antisymm ?_ ?_
  · calc packingNumber (pathGraph n) ≤ dominationNumber (pathGraph n) :=
          packingNumber_le_dominationNumber _
      _ = (n + 2) / 3 := dominationNumber_pathGraph_eq n
  · calc (n + 2) / 3 = (Finset.univ.filter (fun v : Fin n => v.val % 3 = 0)).card :=
          (card_univ_filter_mod_three n).symm
      _ ≤ packingNumber (pathGraph n) := card_le_packingNumber (isPacking_pathGraph_mod_three n)

/-- **Exactness of the duality on paths.**  For every `n`, `γ(Pₙ) = ρ(Pₙ)`; the
domination–packing ratio of a path is `1`. -/
theorem pathGraph_dominationNumber_eq_packingNumber (n : ℕ) :
    dominationNumber (pathGraph n) = packingNumber (pathGraph n) := by
  rw [dominationNumber_pathGraph_eq n, pathGraph_packingNumber n]

/-! ## Erdős–Pósa form of the unit disk bound -/

variable {V : Type*}

/-- The domination number is attained by an actual dominating set. -/
lemma exists_dominating_card_eq [Fintype V] (G : SimpleGraph V) :
    ∃ D : Finset V, IsDominatingSet G D ∧ D.card = dominationNumber G := by
  classical
  have hne : {k | ∃ D : Finset V, IsDominatingSet G D ∧ D.card = k}.Nonempty :=
    ⟨Finset.univ.card, Finset.univ, fun v => Or.inl (Finset.mem_univ v), rfl⟩
  obtain ⟨D, hD, hDcard⟩ := Nat.sInf_mem hne
  exact ⟨D, hD, hDcard⟩

/-- **Erdős–Pósa form.**  In a unit disk graph either there are `k` pairwise disjoint radius-`1`
balls, or `25·k` vertices meet all of them; equivalently, some dominating set has at most
`25·ρ(G)` vertices. -/
theorem exists_dominating_card_le_25_mul_packingNumber [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} (rep : SemitotalDomination.UnitDiskRep G) :
    ∃ D : Finset V, IsDominatingSet G D ∧ D.card ≤ 25 * packingNumber G := by
  obtain ⟨D, hD, hcard⟩ := exists_dominating_card_eq G
  exact ⟨D, hD, hcard ▸ dominationNumber_le_25_mul_packingNumber rep⟩

end DominationPacking