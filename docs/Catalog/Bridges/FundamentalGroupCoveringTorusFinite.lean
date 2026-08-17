/-
# Every finite covering of the torus is a torus

`FundamentalGroupCoveringTorus` and `FundamentalGroupCoveringTorusTriple` computed the
connected coverings of the torus `K(ℤ²,1)` in degrees two and three, and observed in both
cases that all the total spaces are again tori.  This file proves the general statement,
which was the open sub-conjecture **C2b** of the thread:

* `torus_finite_index_subgroup_mulEquiv` — **every finite-index subgroup of `ℤ²` is
  isomorphic to `ℤ²`.**  The subgroup contains `k · ℤ²` for `k` its index, so it has rank
  at least two; being a submodule of a free module of rank two over the principal ideal
  domain `ℤ` it is free of rank at most two, hence free of rank exactly two.
* `torus_finite_covering_is_torus` — consequently **the total space of every connected
  covering of the torus with finitely many sheets is again a torus**: its fundamental
  group, the stabiliser of a point of the fibre, is isomorphic to `ℤ²`.
* `torus_covering_of_every_degree` / `torus_infinitely_many_coverings` — the degrees are
  not restricted: for every `n ≥ 1` the torus carries a connected `n`-sheeted covering,
  and coverings of different degrees are non-isomorphic, so the torus has infinitely many
  pairwise non-isomorphic connected coverings *all of whose total spaces are tori*.  This
  is the strongest possible form of the failure of π₁ to distinguish covering spaces over
  a fixed base.
-/
import Mathlib
import Bridges.FundamentalGroupCoveringGalois
import Bridges.FundamentalGroupCoveringTorus

open CategoryTheory MulAction Module

namespace FundamentalGroupCovering

/-! ## Subgroups of the torus lattice as `ℤ`-submodules -/

section Submodule

/-- A subgroup of `ℤ²` (written multiplicatively as the fundamental group of the torus)
viewed as a `ℤ`-submodule of `ℤ²`. -/
def torusSubmodule (H : Subgroup Torus) : Submodule ℤ (ℤ × ℤ) where
  carrier := {x : ℤ × ℤ | Multiplicative.ofAdd x ∈ H}
  add_mem' ha hb := H.mul_mem ha hb
  zero_mem' := H.one_mem
  smul_mem' c _ hx := H.zpow_mem hx c

theorem mem_torusSubmodule_iff {H : Subgroup Torus} {x : ℤ × ℤ} :
    x ∈ torusSubmodule H ↔ Multiplicative.ofAdd x ∈ H := Iff.rfl

/-- A subgroup of index `k` contains `k · ℤ²`. -/
theorem index_smul_mem_torusSubmodule (H : Subgroup Torus) (x : ℤ × ℤ) :
    ((H.index : ℤ)) • x ∈ torusSubmodule H := by
  show Multiplicative.ofAdd (((H.index : ℤ)) • x) ∈ H
  rw [natCast_zsmul, ofAdd_nsmul]
  exact Subgroup.pow_index_mem H _

/-- The subgroup and its submodule have the same underlying subtype. -/
def torusSubMulEquiv (H : Subgroup Torus) : H ≃* Multiplicative (torusSubmodule H) where
  toFun x := Multiplicative.ofAdd (⟨Multiplicative.toAdd x.1, x.2⟩ : torusSubmodule H)
  invFun y := ⟨Multiplicative.ofAdd (Multiplicative.toAdd y).1, (Multiplicative.toAdd y).2⟩
  left_inv _ := rfl
  right_inv _ := rfl
  map_mul' _ _ := rfl

end Submodule

/-! ## Finite-index sublattices of `ℤ²` are lattices of rank two -/

section Rank

/-- **A submodule of `ℤ²` containing `k · ℤ²` for some `k ≠ 0` is free of rank two**, hence
isomorphic to `ℤ²`.  Rank at most two because a submodule of a free module of rank two over
a principal ideal domain is free of rank at most two; rank at least two because
multiplication by `k` embeds `ℤ²` into it. -/
theorem linearEquiv_of_smul_mem {k : ℤ} (hk : k ≠ 0) (L : Submodule ℤ (ℤ × ℤ))
    (h : ∀ x : ℤ × ℤ, k • x ∈ L) : Nonempty (L ≃ₗ[ℤ] (ℤ × ℤ)) := by
  classical
  have hrank2 : finrank ℤ (ℤ × ℤ) = 2 := by simp
  have hinj : Function.Injective (LinearMap.codRestrict L (k • LinearMap.id) h) := by
    intro x y hxy
    have hkxy : k • x = k • y := congrArg Subtype.val hxy
    exact smul_right_injective (ℤ × ℤ) hk hkxy
  have h1 : finrank ℤ (ℤ × ℤ) ≤ finrank ℤ L := LinearMap.finrank_le_finrank_of_injective hinj
  have h2 : finrank ℤ L ≤ finrank ℤ (ℤ × ℤ) := Submodule.finrank_le L
  have hL : finrank ℤ L = 2 := by omega
  have hcard : Fintype.card (Free.ChooseBasisIndex ℤ L) = 2 := by
    rw [← finrank_eq_card_chooseBasisIndex, hL]
  exact ⟨(Free.chooseBasis ℤ L).equiv (Basis.finTwoProd ℤ) (Fintype.equivFinOfCardEq hcard)⟩

/-- **Every finite-index subgroup of `ℤ²` is isomorphic to `ℤ²`.** -/
theorem torus_finite_index_subgroup_mulEquiv {H : Subgroup Torus} (h : H.index ≠ 0) :
    Nonempty (H ≃* Torus) := by
  obtain ⟨e⟩ := linearEquiv_of_smul_mem (k := (H.index : ℤ))
    (Int.natCast_ne_zero.mpr h) (torusSubmodule H) (index_smul_mem_torusSubmodule H)
  exact ⟨(torusSubMulEquiv H).trans
    (AddEquiv.toMultiplicative (e.toAddEquiv))⟩

end Rank

/-! ## The covering-theoretic statement -/

section Coverings

variable {X : Type} [MulAction Torus X]

/-- **The total space of a connected covering of the torus with finitely many sheets is
again a torus.**  Its fundamental group — the stabiliser of a point of the fibre — is
isomorphic to `ℤ²`. -/
theorem torus_finite_covering_is_torus [IsPretransitive Torus X] (x : X)
    (hX : Nat.card X ≠ 0) :
    Nonempty (Aut (ActionCategory.objEquiv Torus X x) ≃* Torus) := by
  have hidx : (stabilizer Torus x).index ≠ 0 := by
    rw [← card_eq_index_stabilizer x]; exact hX
  obtain ⟨e⟩ := torus_finite_index_subgroup_mulEquiv hidx
  exact ⟨(autMulEquivStabilizer x).trans e⟩

end Coverings

/-! ## Coverings of every degree -/

section Degrees

/-- Reduction of the first coordinate modulo `n`. -/
def torusProj (n : ℕ) : Torus →* Multiplicative (ZMod n) :=
  MonoidHom.mk' (fun x => Multiplicative.ofAdd (((Multiplicative.toAdd x).1 : ZMod n)))
    (by
      intro a b
      show Multiplicative.ofAdd ((((Multiplicative.toAdd a).1 +
          (Multiplicative.toAdd b).1 : ℤ) : ZMod n)) = _
      push_cast
      rfl)

theorem torusProj_surjective (n : ℕ) : Function.Surjective (torusProj n) := by
  intro y
  obtain ⟨m, hm⟩ := ZMod.intCast_surjective (n := n) (Multiplicative.toAdd y)
  refine ⟨Multiplicative.ofAdd ((m, 0) : ℤ × ℤ), ?_⟩
  show Multiplicative.ofAdd ((m : ZMod n)) = y
  rw [hm]
  rfl

/-- The sublattice `{(a,b) : n ∣ a}`, of index `n`. -/
def torusSubOfDegree (n : ℕ) : Subgroup Torus := (torusProj n).ker

theorem index_torusSubOfDegree (n : ℕ) [NeZero n] : (torusSubOfDegree n).index = n := by
  rw [torusSubOfDegree, Subgroup.index_ker, MonoidHom.range_eq_top.mpr (torusProj_surjective n),
    Subgroup.card_top]
  show Nat.card (ZMod n) = n
  rw [Nat.card_eq_fintype_card, ZMod.card]

/-- **The torus has a connected covering of every finite degree, and every one of the total
spaces is again a torus.** -/
theorem torus_covering_of_every_degree (n : ℕ) (hn : n ≠ 0) :
    ∃ H : Subgroup Torus, H.index = n ∧ Nonempty (H ≃* Torus) := by
  haveI : NeZero n := ⟨hn⟩
  refine ⟨torusSubOfDegree n, index_torusSubOfDegree n, ?_⟩
  exact torus_finite_index_subgroup_mulEquiv (by rw [index_torusSubOfDegree n]; exact hn)

/-- **π₁ fails as an invariant of coverings over the torus in the strongest possible way**:
there is an injection from the positive integers to connected coverings of the torus,
pairwise non-isomorphic (they have different numbers of sheets), all of whose total spaces
have fundamental group `ℤ²` — the same group as the base. -/
theorem torus_infinitely_many_coverings :
    ∀ m n : ℕ, m ≠ 0 → n ≠ 0 → m ≠ n →
      (torusSubOfDegree m).index ≠ (torusSubOfDegree n).index ∧
        ¬ Nonempty (GEquiv Torus (Torus ⧸ torusSubOfDegree m) (Torus ⧸ torusSubOfDegree n)) ∧
        Nonempty (torusSubOfDegree m ≃* Torus) ∧ Nonempty (torusSubOfDegree n ≃* Torus) := by
  intro m n hm hn hmn
  haveI : NeZero m := ⟨hm⟩
  haveI : NeZero n := ⟨hn⟩
  have hidx : (torusSubOfDegree m).index ≠ (torusSubOfDegree n).index := by
    rw [index_torusSubOfDegree m, index_torusSubOfDegree n]; exact hmn
  refine ⟨hidx, ?_, torus_finite_index_subgroup_mulEquiv (by
      rw [index_torusSubOfDegree m]; exact hm),
    torus_finite_index_subgroup_mulEquiv (by rw [index_torusSubOfDegree n]; exact hn)⟩
  rintro ⟨e⟩
  -- an isomorphism of coverings is in particular a bijection of the total spaces, so the
  -- two coverings have the same number of sheets, i.e. the same index
  exact hidx (by
    rw [Subgroup.index_eq_card (torusSubOfDegree m), Subgroup.index_eq_card (torusSubOfDegree n)]
    exact Nat.card_congr e.toEquiv)

end Degrees

end FundamentalGroupCovering