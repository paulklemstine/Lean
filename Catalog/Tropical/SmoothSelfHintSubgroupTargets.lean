import Tropical.SmoothSelfHintSymmetricClassification

/-!
# Subgroup targets always leak

The classification `miF_symJointG_eq_zero_iff_autocorrelation` says the symmetric
statistic for a target `A ⊆ G` is invisible exactly when the autocorrelation
`n ↦ |A ∩ n·A⁻¹|` is constant.  This file settles the arithmetically most important
family of targets: **proper subgroups**.

If `A = H` is a subgroup then `A ∩ n·A⁻¹` is `H` for `n ∈ H` and empty otherwise, so the
autocorrelation is as far from constant as possible and the leak is strictly positive
whenever `H ≠ ⊤`.  Instances of this: "`l ∣ x - 1`" (`H = 1`, the singleton case),
"`x` is a `k`-th power mod `l`", and in particular "`x` is a quadratic residue mod `l`".

This also refutes the guess that cosets of subgroups are the invisible sets: they are the
*most* visible ones.

* `SmoothSelfHint.subgroupFinset` — a subgroup viewed as a `Finset`.
* `SmoothSelfHint.sym_fiber_subgroup_mem` / `sym_fiber_subgroup_not_mem` — the two fibre
  counts, `|H|` and `2|H|`.
* `SmoothSelfHint.miF_symJointG_pos_of_subgroup` — **every proper subgroup leaks**.
* `SmoothSelfHint.miF_symJointG_pos_of_subgroup_units` — the arithmetic corollary in
  `(ZMod l)ˣ`.
-/

open Finset

namespace SmoothSelfHint

section Group

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-- A subgroup, viewed as a `Finset` of the ambient finite group. -/
def subgroupFinset (H : Subgroup G) [DecidablePred (· ∈ H)] : Finset G :=
  Finset.univ.filter (· ∈ H)

omit [DecidableEq G] in
@[simp]
theorem mem_subgroupFinset {H : Subgroup G} [DecidablePred (· ∈ H)] {a : G} :
    a ∈ subgroupFinset H ↔ a ∈ H := by
  simp [subgroupFinset]

/-- For `n` inside the subgroup the symmetric fibre has `|H|` elements. -/
theorem sym_fiber_subgroup_mem (H : Subgroup G) [DecidablePred (· ∈ H)] {n : G} (hn : n ∈ H) :
    (symFiber (subgroupFinset H) n).card = (subgroupFinset H).card := by
  rw [sym_fiber_card]
  congr 1
  apply Finset.union_eq_left.mpr
  intro c hc
  simp only [Finset.mem_image, mem_subgroupFinset] at hc
  obtain ⟨b, hb, rfl⟩ := hc
  exact mem_subgroupFinset.mpr (H.mul_mem hn (H.inv_mem hb))

/-- For `n` outside the subgroup the symmetric fibre has `2|H|` elements: the two cosets
`H` and `nH` are disjoint. -/
theorem sym_fiber_subgroup_not_mem (H : Subgroup G) [DecidablePred (· ∈ H)] {n : G}
    (hn : n ∉ H) :
    (symFiber (subgroupFinset H) n).card = 2 * (subgroupFinset H).card := by
  rw [sym_fiber_card]
  have hinj : Set.InjOn (fun b => n * b⁻¹) (subgroupFinset H) := by
    intro a _ b _ hab
    simpa using mul_left_cancel hab
  have hcard : ((subgroupFinset H).image (fun b => n * b⁻¹)).card = (subgroupFinset H).card :=
    Finset.card_image_of_injOn hinj
  have hdisj : Disjoint (subgroupFinset H) ((subgroupFinset H).image (fun b => n * b⁻¹)) := by
    rw [Finset.disjoint_left]
    intro c hc hc'
    simp only [Finset.mem_image, mem_subgroupFinset] at hc'
    obtain ⟨b, hb, rfl⟩ := hc'
    exact hn (by simpa using H.mul_mem (mem_subgroupFinset.mp hc) hb)
  rw [Finset.card_union_of_disjoint hdisj, hcard]
  ring

/-- **Every proper subgroup leaks.**  If `H ≠ ⊤` then the symmetric event
"`a ∈ H` or `b ∈ H`" carries strictly positive information about the product `a·b`. -/
theorem miF_symJointG_pos_of_subgroup (H : Subgroup G) [DecidablePred (· ∈ H)]
    (hH : ∃ x : G, x ∉ H) : 0 < miF (symJointG (subgroupFinset H)) := by
  obtain ⟨x, hx⟩ := hH
  have hone : (1 : G) ∈ subgroupFinset H := mem_subgroupFinset.mpr H.one_mem
  have hpos : 0 < (subgroupFinset H).card := Finset.card_pos.mpr ⟨1, hone⟩
  refine miF_symJointG_pos_of_ne _ (n₀ := 1) (m₀ := x) ?_
  rw [sym_fiber_subgroup_mem H H.one_mem, sym_fiber_subgroup_not_mem H hx]
  omega

end Group

/-- The arithmetic corollary: for a prime `l` and any proper subgroup `H` of `(ZMod l)ˣ`
— for instance the quadratic residues, or the `k`-th powers — the symmetric event
"`p mod l ∈ H` or `q mod l ∈ H`" leaks strictly positive information about `N mod l`,
whereas by `miF_asym_zero` the corresponding one-sided event leaks nothing at all. -/
theorem miF_symJointG_pos_of_subgroup_units (l : ℕ) [Fact (Nat.Prime l)]
    (H : Subgroup (ZMod l)ˣ) [DecidablePred (· ∈ H)] (hH : ∃ x : (ZMod l)ˣ, x ∉ H) :
    0 < miF (symJointG (subgroupFinset H)) ∧ miF (jointAsym (subgroupFinset H)) = 0 :=
  ⟨miF_symJointG_pos_of_subgroup H hH, miF_asym_zero _⟩

end SmoothSelfHint