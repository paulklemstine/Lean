/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.SchubertCalculus.FiniteField

/-!
# Schubert calculus IX: every Schubert cell is an affine space over a finite field

This file settles the *local* (cell by cell) half of Conjecture 1 of `FUTURE_DIRECTIONS.md`:
over a finite field `𝔽_q`, for any complete flag `F` of an `N`-dimensional space `V` and any
jump set `S ⊆ {0, …, N-1}`, the Schubert cell

`{W ≤ V | jumpSet W = S}`

has exactly `q ^ dimCell N S` elements.  Summing over `S` recovers the Gaussian binomial
point count proved in `Geometry.SchubertCalculus.FiniteField`; here we obtain the finer,
stratum-by-stratum statement, i.e. that each Schubert cell is an affine space of the predicted
dimension.

The proof needs no normal form theory (no row reduction, no echelon uniqueness).  It runs by
induction along the flag itself, counting the subspaces contained in `F_j` for growing `j`.
The geometric input is a single *affine fibration lemma*: if `U ≤ H ≤ P` with
`dim P = dim H + 1`, then the set of `W ≤ P` with `W ⊓ H = U` and `W ⊄ H` has exactly
`q ^ (dim H - dim U)` elements (`SchubertCalculus.card_extSet`).  Such a `W` is `U + K·v` for
`v ∈ P \ H`, and two vectors give the same `W` exactly when they differ by an element of
`W \ U`, so the count is `(q^{j+1} - q^j) / (q^{d+1} - q^d) = q^{j-d}`.

The combinatorics on the other side is exactly `dimCell_insert`: adding a new largest jump `j`
to a jump set of size `d` raises the cell dimension by `j - d`.  The two match, which is the
whole content of the theorem.

Main results:

* `SchubertCalculus.card_extSet` : the affine fibration lemma;
* `SchubertCalculus.jumpSet_inf_part` : the jump set of `W ⊓ F_j` is the part of the jump set
  of `W` below `j`;
* `SchubertCalculus.card_cell_le_part` : the count of subspaces of `F_j` with a given jump
  set, proved by induction on `j`;
* `SchubertCalculus.card_cell` : **the Schubert cell of `S` has `q ^ dimCell N S` points**;
* `SchubertCalculus.card_cell_top` : the top cell has `q ^ (k(N-k))` points.
-/

namespace SchubertCalculus

open Finset Module Submodule

/-! ### Counting preliminaries -/

section Counting

variable {K V : Type*} [Field K] [Fintype K] [AddCommGroup V] [Module K V]
  [FiniteDimensional K V]

/-- If all fibres of `f` have the same cardinality `c`, the source has `#β * c` elements. -/
lemma card_eq_card_mul_of_fibers {α β : Type*} [Finite α] [Fintype β] (f : α → β) (c : ℕ)
    (h : ∀ b, Nat.card {a // f a = b} = c) :
    Nat.card α = Nat.card β * c := by
  classical
  haveI : ∀ b : β, Finite {a // f a = b} := fun _ => Finite.of_injective _ Subtype.val_injective
  rw [← Nat.card_congr (Equiv.sigmaFiberEquiv f), Nat.card_sigma]
  simp [h, Nat.card_eq_fintype_card, mul_comm]

/-- A subspace of dimension `m` over a field with `q` elements has `q ^ m` vectors. -/
lemma card_submodule (P : Submodule K V) : Nat.card P = Fintype.card K ^ finrank K P := by
  haveI : Finite V := Module.finite_of_finite K
  haveI : Fintype V := Fintype.ofFinite V
  haveI : Fintype P := Fintype.ofFinite P
  rw [Nat.card_eq_fintype_card]
  exact Module.card_eq_pow_finrank

/-- The number of vectors of `P` outside a subspace `H`. -/
lemma ncard_sdiff_submodule {H P : Submodule K V} (h : H ≤ P) :
    ((P : Set V) \ (H : Set V)).ncard
      = Fintype.card K ^ finrank K P - Fintype.card K ^ finrank K H := by
  haveI : Finite V := Module.finite_of_finite K
  rw [Set.ncard_diff (show (H : Set V) ⊆ (P : Set V) from h) (Set.toFinite _),
    ← Nat.card_coe_set_eq, ← Nat.card_coe_set_eq,
    show Nat.card ((P : Set V)) = Nat.card P from rfl,
    show Nat.card ((H : Set V)) = Nat.card H from rfl, card_submodule, card_submodule]

end Counting

/-! ### The affine fibration lemma -/

section Fibration

variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V] [FiniteDimensional K V]

/-- A subspace of `P` meeting the hyperplane `H` of `P` in `U`, but not contained in `H`, has
dimension `dim U + 1`. -/
lemma finrank_of_inf_eq {P H U W : Submodule K V} (hHP : H ≤ P) (hWP : W ≤ P)
    (hWH : W ⊓ H = U) (hnot : ¬ W ≤ H) (hrank : finrank K P = finrank K H + 1) :
    finrank K W = finrank K U + 1 := by
  have key := Submodule.finrank_sup_add_finrank_inf_eq W H
  rw [hWH] at key
  have hle : finrank K (W ⊔ H : Submodule K V) ≤ finrank K H + 1 := by
    rw [← hrank]; exact Submodule.finrank_mono (sup_le hWP hHP)
  have hlt : finrank K H < finrank K (W ⊔ H : Submodule K V) :=
    Submodule.finrank_lt_finrank_of_lt (lt_of_le_of_ne le_sup_right
      fun h => hnot (le_sup_left.trans h.ge))
  omega

omit [FiniteDimensional K V] in
/-- Adding a vector outside `H` to a subspace `U ≤ H` does not enlarge the intersection with
`H`. -/
lemma sup_span_singleton_inf {H U : Submodule K V} (hUH : U ≤ H) {v : V} (hv : v ∉ H) :
    (U ⊔ Submodule.span K {v}) ⊓ H = U := by
  apply le_antisymm
  · intro x hx
    rw [Submodule.mem_inf, Submodule.mem_sup] at hx
    obtain ⟨⟨u, hu, w, hw, rfl⟩, hx2⟩ := hx
    rw [Submodule.mem_span_singleton] at hw
    obtain ⟨c, rfl⟩ := hw
    rcases eq_or_ne c 0 with rfl | hc
    · simpa using hu
    · exact absurd (by
        have h1 : c • v ∈ H := by simpa using H.sub_mem hx2 (hUH hu)
        have h2 := H.smul_mem c⁻¹ h1
        rwa [smul_smul, inv_mul_cancel₀ hc, one_smul] at h2) hv
  · exact le_inf le_sup_left hUH

variable (P H U : Submodule K V)

/-- The subspaces of `P` meeting the hyperplane `H` exactly in `U`: the fibre of the Schubert
stratification over `U`. -/
abbrev extSet : Type _ := {W : Submodule K V // W ≤ P ∧ W ⊓ H = U ∧ ¬ W ≤ H}

variable {P H U}

omit [FiniteDimensional K V] in
lemma le_of_extSet (W : extSet P H U) : U ≤ W.1 := W.2.2.1.ge.trans inf_le_left

omit [FiniteDimensional K V] in
lemma notMem_of_mem_extSet {W : extSet P H U} {v : V} (hv : v ∈ W.1) (hvU : v ∉ U) : v ∉ H := by
  intro hvH
  exact hvU (by rw [← W.2.2.1]; exact Submodule.mem_inf.mpr ⟨hv, hvH⟩)

/-- The parametrisation `v ↦ U + K·v` of the extensions of `U` by a vector outside `H`. -/
def extMap (hHP : H ≤ P) (hUH : U ≤ H)
    (v : {v : V // v ∈ (P : Set V) \ (H : Set V)}) : extSet P H U :=
  ⟨U ⊔ Submodule.span K {v.1}, by
    refine ⟨sup_le (hUH.trans hHP) ?_, sup_span_singleton_inf hUH v.2.2, ?_⟩
    · rw [Submodule.span_le, Set.singleton_subset_iff]; exact v.2.1
    · exact fun hle =>
        v.2.2 (hle (Submodule.mem_sup_right (Submodule.mem_span_singleton_self _)))⟩

/-- The fibre of `extMap` over `W` is the set of vectors of `W` outside `U`. -/
def extFiberEquiv (hHP : H ≤ P) (hUH : U ≤ H) (hrank : finrank K P = finrank K H + 1)
    (W : extSet P H U) :
    {v : {v : V // v ∈ (P : Set V) \ (H : Set V)} // extMap hHP hUH v = W} ≃
      {v : V // v ∈ (W.1 : Set V) \ (U : Set V)} where
  toFun v := ⟨v.1.1, by
    have hW : U ⊔ Submodule.span K {v.1.1} = W.1 := congrArg Subtype.val v.2
    refine ⟨?_, fun hu => v.1.2.2 (hUH hu)⟩
    rw [← hW]
    exact Submodule.mem_sup_right (Submodule.mem_span_singleton_self _)⟩
  invFun v := ⟨⟨v.1, ⟨W.2.1 v.2.1, notMem_of_mem_extSet v.2.1 v.2.2⟩⟩, by
    apply Subtype.ext
    show U ⊔ Submodule.span K {v.1} = W.1
    have hle : U ⊔ Submodule.span K {v.1} ≤ W.1 := by
      refine sup_le (le_of_extSet W) ?_
      rw [Submodule.span_le, Set.singleton_subset_iff]; exact v.2.1
    have hvH : v.1 ∉ H := notMem_of_mem_extSet v.2.1 v.2.2
    have h1 : finrank K (U ⊔ Submodule.span K {v.1} : Submodule K V) = finrank K U + 1 :=
      finrank_of_inf_eq hHP (sup_le (hUH.trans hHP) (by
        rw [Submodule.span_le, Set.singleton_subset_iff]; exact W.2.1 v.2.1))
        (sup_span_singleton_inf hUH hvH)
        (fun hle' => hvH (hle' (Submodule.mem_sup_right (Submodule.mem_span_singleton_self _))))
        hrank
    have h2 : finrank K W.1 = finrank K U + 1 :=
      finrank_of_inf_eq hHP W.2.1 W.2.2.1 W.2.2.2 hrank
    exact Submodule.eq_of_le_of_finrank_eq hle (by rw [h1, h2])⟩
  left_inv v := by apply Subtype.ext; apply Subtype.ext; rfl
  right_inv v := by apply Subtype.ext; rfl

variable [Fintype K]

/-- **Affine fibration lemma.**  For `U ≤ H ≤ P` with `H` a hyperplane of `P`, the subspaces of
`P` meeting `H` exactly in `U` and not contained in `H` form an affine space of dimension
`dim H - dim U`: there are exactly `q ^ (dim H - dim U)` of them. -/
theorem card_extSet (hHP : H ≤ P) (hUH : U ≤ H) (hrank : finrank K P = finrank K H + 1) :
    Nat.card (extSet P H U) = Fintype.card K ^ (finrank K H - finrank K U) := by
  classical
  set q := Fintype.card K with hq
  have hq2 : 2 ≤ q := Fintype.one_lt_card
  haveI : Finite V := Module.finite_of_finite K
  haveI : Fintype (extSet P H U) := Fintype.ofFinite _
  set j := finrank K H with hj
  set d := finrank K U with hd
  have hdj : d ≤ j := Submodule.finrank_mono hUH
  have hdom : Nat.card {v : V // v ∈ (P : Set V) \ (H : Set V)} = q ^ (j + 1) - q ^ j := by
    rw [Nat.card_coe_set_eq, ncard_sdiff_submodule hHP, hrank]
  have hfib : ∀ W : extSet P H U,
      Nat.card {v : {v : V // v ∈ (P : Set V) \ (H : Set V)} // extMap hHP hUH v = W}
        = q ^ (d + 1) - q ^ d := by
    intro W
    rw [Nat.card_congr (extFiberEquiv hHP hUH hrank W), Nat.card_coe_set_eq,
      ncard_sdiff_submodule (le_of_extSet W),
      finrank_of_inf_eq hHP W.2.1 W.2.2.1 W.2.2.2 hrank]
  have hcount := card_eq_card_mul_of_fibers (extMap hHP hUH) (q ^ (d + 1) - q ^ d) hfib
  rw [hdom] at hcount
  have hpos : 0 < q ^ (d + 1) - q ^ d := by
    have : q ^ d < q ^ (d + 1) := Nat.pow_lt_pow_right (by omega) (by omega)
    omega
  have hkey : q ^ (j - d) * (q ^ (d + 1) - q ^ d) = q ^ (j + 1) - q ^ j := by
    have e1 : q ^ (d + 1) - q ^ d = q ^ d * (q - 1) := by rw [Nat.mul_sub, mul_one, ← pow_succ]
    have e2 : q ^ (j + 1) - q ^ j = q ^ j * (q - 1) := by rw [Nat.mul_sub, mul_one, ← pow_succ]
    rw [e1, e2, ← mul_assoc, ← pow_add, Nat.sub_add_cancel hdj]
  rw [← hkey] at hcount
  exact (Nat.eq_of_mul_eq_mul_right hpos hcount).symm

end Fibration

/-! ### Jump sets along the flag -/

namespace CompleteFlag

section Jumps

variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V] [FiniteDimensional K V]
  {N : ℕ} (Fl : CompleteFlag K V N)

lemma jumpSet_bot : Fl.jumpSet ⊥ = ∅ := by
  have h := Fl.card_jumpSet (⊥ : Submodule K V)
  rw [finrank_bot] at h
  exact Finset.card_eq_zero.mp h

omit [FiniteDimensional K V] in
/-- A subspace contained in `F_m` has all its jumps below `m`. -/
lemma jumpSet_subset_range_of_le {W : Submodule K V} {m : ℕ} (hW : W ≤ Fl.part m) :
    Fl.jumpSet W ⊆ range m := by
  intro i hi
  rw [Fl.mem_jumpSet] at hi
  by_contra hmi
  rw [Finset.mem_range] at hmi
  push_neg at hmi
  have h1 : W ⊓ Fl.part i = W := inf_eq_left.2 (hW.trans (Fl.mono hmi))
  have h2 : W ⊓ Fl.part (i + 1) = W := inf_eq_left.2 (hW.trans (Fl.mono (by omega)))
  rw [h1, h2] at hi
  omega

/-- If `j` is not a jump of `W ≤ F_{j+1}`, then in fact `W ≤ F_j`. -/
lemma le_part_of_notMem_jumpSet {W : Submodule K V} {j : ℕ} (hj : j < N)
    (hW : W ≤ Fl.part (j + 1)) (hjs : j ∉ Fl.jumpSet W) : W ≤ Fl.part j := by
  have hne : finrank K ((W ⊓ Fl.part (j + 1) : Submodule K V))
      ≠ finrank K ((W ⊓ Fl.part j : Submodule K V)) + 1 := by
    intro h
    exact hjs (Fl.mem_jumpSet W |>.mpr ⟨hj, h⟩)
  have hmono := Fl.finrank_inf_mono W (show j ≤ j + 1 by omega)
  have hstep := Fl.finrank_inf_step_le W hj
  have heq : finrank K ((W ⊓ Fl.part j : Submodule K V))
      = finrank K ((W ⊓ Fl.part (j + 1) : Submodule K V)) := by omega
  have hle : (W ⊓ Fl.part j : Submodule K V) ≤ W ⊓ Fl.part (j + 1) :=
    inf_le_inf_left _ (Fl.mono (Nat.le_succ j))
  have := Submodule.eq_of_le_of_finrank_eq hle heq
  have htop : (W ⊓ Fl.part (j + 1) : Submodule K V) = W := inf_eq_left.2 hW
  rw [htop] at this
  exact this.ge.trans inf_le_right

omit [FiniteDimensional K V] in
/-- **Truncation of the jump datum.**  The jumps of `W ⊓ F_j` are exactly the jumps of `W`
below `j`. -/
lemma jumpSet_inf_part (W : Submodule K V) (j : ℕ) :
    Fl.jumpSet (W ⊓ Fl.part j) = (Fl.jumpSet W).filter (· < j) := by
  ext i
  rw [Finset.mem_filter, Fl.mem_jumpSet, Fl.mem_jumpSet]
  constructor
  · rintro ⟨hiN, hstep⟩
    by_cases hij : i < j
    · have e1 : (W ⊓ Fl.part j) ⊓ Fl.part i = W ⊓ Fl.part i := by
        rw [inf_assoc, inf_eq_right.2 (Fl.mono hij.le)]
      have e2 : (W ⊓ Fl.part j) ⊓ Fl.part (i + 1) = W ⊓ Fl.part (i + 1) := by
        rw [inf_assoc, inf_eq_right.2 (Fl.mono (by omega))]
      rw [e1, e2] at hstep
      exact ⟨⟨hiN, hstep⟩, hij⟩
    · exfalso
      push_neg at hij
      have e1 : (W ⊓ Fl.part j) ⊓ Fl.part i = W ⊓ Fl.part j := by
        rw [inf_assoc, inf_eq_left.2 (Fl.mono hij)]
      have e2 : (W ⊓ Fl.part j) ⊓ Fl.part (i + 1) = W ⊓ Fl.part j := by
        rw [inf_assoc, inf_eq_left.2 (Fl.mono (by omega))]
      rw [e1, e2] at hstep
      omega
  · rintro ⟨⟨hiN, hstep⟩, hij⟩
    have e1 : (W ⊓ Fl.part j) ⊓ Fl.part i = W ⊓ Fl.part i := by
      rw [inf_assoc, inf_eq_right.2 (Fl.mono hij.le)]
    have e2 : (W ⊓ Fl.part j) ⊓ Fl.part (i + 1) = W ⊓ Fl.part (i + 1) := by
      rw [inf_assoc, inf_eq_right.2 (Fl.mono (by omega))]
    exact ⟨hiN, by rw [e1, e2]; exact hstep⟩

/-- Conversely, a subspace of `F_{j+1}` not contained in `F_j` has jump set obtained from that
of `W ⊓ F_j` by adding `j`. -/
lemma jumpSet_of_not_le {W U : Submodule K V} {j : ℕ} (hj : j < N)
    (hWP : W ≤ Fl.part (j + 1)) (hWU : W ⊓ Fl.part j = U) (hnot : ¬ W ≤ Fl.part j) :
    Fl.jumpSet W = insert j (Fl.jumpSet U) := by
  have hrank : finrank K (Fl.part (j + 1)) = finrank K (Fl.part j) + 1 := by
    rw [Fl.finrank_part (j + 1) hj, Fl.finrank_part j hj.le]
  have hfr : finrank K W = finrank K U + 1 :=
    finrank_of_inf_eq (Fl.mono (Nat.le_succ j)) hWP hWU hnot hrank
  have hjmem : j ∈ Fl.jumpSet W := by
    rw [Fl.mem_jumpSet]
    refine ⟨hj, ?_⟩
    rw [inf_eq_left.2 hWP, hWU, hfr]
  have hsub : Fl.jumpSet W ⊆ range (j + 1) := Fl.jumpSet_subset_range_of_le hWP
  have hfilter : (Fl.jumpSet W).filter (· < j) = (Fl.jumpSet W).erase j := by
    ext i
    simp only [Finset.mem_filter, Finset.mem_erase]
    constructor
    · rintro ⟨hi, hij⟩; exact ⟨by omega, hi⟩
    · rintro ⟨hij, hi⟩
      have := Finset.mem_range.mp (hsub hi)
      exact ⟨hi, by omega⟩
  have hU : Fl.jumpSet U = (Fl.jumpSet W).erase j := by
    rw [← hWU, Fl.jumpSet_inf_part W j, hfilter]
  rw [hU, Finset.insert_erase hjmem]

end Jumps

end CompleteFlag

/-! ### The cell count -/

section CellCount

variable {K V : Type*} [Field K] [Fintype K] [AddCommGroup V] [Module K V]
  [FiniteDimensional K V] {N : ℕ} (Fl : CompleteFlag K V N)

/-- Cell dimensions do not depend on the ambient size, as long as it is large enough. -/
lemma dimCell_ambient {m n : ℕ} {S : Finset ℕ} (hS : S ⊆ range m) (hmn : m ≤ n) :
    dimCell n S = dimCell m S := by
  induction n, hmn using Nat.le_induction with
  | base => rfl
  | succ n hmn ih =>
      have hSn : S ⊆ range n := fun i hi =>
        Finset.mem_range.mpr (lt_of_lt_of_le (Finset.mem_range.mp (hS hi)) hmn)
      rw [dimCell_succ_of_subset hSn, ih]

/-- **Cell count along the flag.**  The subspaces of `F_j` with jump set `S ⊆ {0,…,j-1}` form
an affine space of dimension `dimCell N S`.  Induction on `j`: the subspaces with `j ∉ S` are
those already contained in `F_j`, while for `j ∈ S` the fibration over `W ↦ W ⊓ F_j` has all
fibres of size `q ^ (j - #S')` by `card_extSet`, matching `dimCell_insert`. -/
theorem card_cell_le_part (j : ℕ) (hj : j ≤ N) (S : Finset ℕ) (hS : S ⊆ range j) :
    Nat.card {W : Submodule K V // W ≤ Fl.part j ∧ Fl.jumpSet W = S}
      = Fintype.card K ^ dimCell N S := by
  classical
  haveI : Finite V := Module.finite_of_finite K
  induction j generalizing S with
  | zero =>
      have hS0 : S = ∅ := Finset.subset_empty.mp (by simpa using hS)
      subst hS0
      have huniq : Nat.card {W : Submodule K V // W ≤ Fl.part 0 ∧ Fl.jumpSet W = ∅} = 1 := by
        rw [Nat.card_eq_one_iff_unique]
        constructor
        · constructor
          intro a b
          apply Subtype.ext
          have ha : a.1 = ⊥ := le_bot_iff.mp (Fl.part_zero ▸ a.2.1)
          have hb : b.1 = ⊥ := le_bot_iff.mp (Fl.part_zero ▸ b.2.1)
          rw [ha, hb]
        · exact ⟨⟨⊥, by rw [Fl.part_zero], Fl.jumpSet_bot⟩⟩
      rw [huniq, dimCell_empty, pow_zero]
  | succ j ih =>
      have hjN : j < N := hj
      by_cases hjS : j ∈ S
      · -- the inductive step: `S = insert j S'`
        set S' := S.erase j with hS'def
        have hS'sub : S' ⊆ range j := by
          intro i hi
          rw [hS'def, Finset.mem_erase] at hi
          have := Finset.mem_range.mp (hS hi.2)
          exact Finset.mem_range.mpr (by omega)
        have hSins : S = insert j S' := (Finset.insert_erase hjS).symm
        haveI : Fintype {U : Submodule K V // U ≤ Fl.part j ∧ Fl.jumpSet U = S'} :=
          Fintype.ofFinite _
        have hrank : finrank K (Fl.part (j + 1)) = finrank K (Fl.part j) + 1 := by
          rw [Fl.finrank_part (j + 1) hj, Fl.finrank_part j hjN.le]
        -- the fibration
        have hmap : ∀ W : {W : Submodule K V // W ≤ Fl.part (j + 1) ∧ Fl.jumpSet W = S},
            (W.1 ⊓ Fl.part j : Submodule K V) ≤ Fl.part j ∧
              Fl.jumpSet (W.1 ⊓ Fl.part j) = S' := by
          intro W
          refine ⟨inf_le_right, ?_⟩
          rw [Fl.jumpSet_inf_part W.1 j, W.2.2, hS'def]
          ext i
          simp only [Finset.mem_filter, Finset.mem_erase]
          constructor
          · rintro ⟨hi, hij⟩; exact ⟨by omega, hi⟩
          · rintro ⟨hij, hi⟩
            have := Finset.mem_range.mp (hS hi)
            exact ⟨hi, by omega⟩
        set f : {W : Submodule K V // W ≤ Fl.part (j + 1) ∧ Fl.jumpSet W = S} →
            {U : Submodule K V // U ≤ Fl.part j ∧ Fl.jumpSet U = S'} :=
          fun W => ⟨W.1 ⊓ Fl.part j, hmap W⟩ with hfdef
        have hfiber : ∀ U : {U : Submodule K V // U ≤ Fl.part j ∧ Fl.jumpSet U = S'},
            Nat.card {W // f W = U} = Fintype.card K ^ (j - S'.card) := by
          intro U
          have hUrank : finrank K U.1 = S'.card := by
            rw [← Fl.card_jumpSet U.1, U.2.2]
          have hequiv : {W // f W = U} ≃ extSet (Fl.part (j + 1)) (Fl.part j) U.1 := by
            refine ⟨fun W => ⟨W.1.1, W.1.2.1, congrArg Subtype.val W.2, ?_⟩,
              fun W => ⟨⟨W.1, W.2.1, ?_⟩, ?_⟩, ?_, ?_⟩
            · intro hle
              have hj' := Fl.jumpSet_subset_range_of_le hle
              rw [W.1.2.2] at hj'
              simpa using hj' hjS
            · have hjs : Fl.jumpSet W.1 = insert j (Fl.jumpSet U.1) :=
                Fl.jumpSet_of_not_le hjN W.2.1 W.2.2.1 W.2.2.2
              rw [hjs, U.2.2, ← hSins]
            · exact Subtype.ext W.2.2.1
            · intro W; apply Subtype.ext; apply Subtype.ext; rfl
            · intro W; apply Subtype.ext; rfl
          rw [Nat.card_congr hequiv,
            card_extSet (Fl.mono (Nat.le_succ j)) U.2.1 hrank,
            Fl.finrank_part j hjN.le, hUrank]
        haveI : Finite {W : Submodule K V // W ≤ Fl.part (j + 1) ∧ Fl.jumpSet W = S} :=
          Subtype.finite
        have hcount := card_eq_card_mul_of_fibers f (Fintype.card K ^ (j - S'.card)) hfiber
        rw [hcount, ih hjN.le S' hS'sub, ← pow_add]
        congr 1
        have e1 : dimCell N S = dimCell (j + 1) S := dimCell_ambient hS hj
        have e2 : dimCell (j + 1) S = dimCell j S' + (j - S'.card) := by
          rw [hSins]; exact dimCell_insert hS'sub rfl
        have e3 : dimCell N S' = dimCell j S' := dimCell_ambient hS'sub hjN.le
        rw [e1, e2, e3]
      · -- `j` is not a jump: nothing new appears
        have hSj : S ⊆ range j := by
          intro i hi
          have := Finset.mem_range.mp (hS hi)
          have hij : i ≠ j := by rintro rfl; exact hjS hi
          exact Finset.mem_range.mpr (by omega)
        have hequiv : {W : Submodule K V // W ≤ Fl.part (j + 1) ∧ Fl.jumpSet W = S} ≃
            {W : Submodule K V // W ≤ Fl.part j ∧ Fl.jumpSet W = S} := by
          refine Equiv.subtypeEquivRight ?_
          intro W
          constructor
          · rintro ⟨hWP, hWS⟩
            exact ⟨Fl.le_part_of_notMem_jumpSet hjN hWP (by rw [hWS]; exact hjS), hWS⟩
          · rintro ⟨hWP, hWS⟩
            exact ⟨hWP.trans (Fl.mono (Nat.le_succ j)), hWS⟩
        rw [Nat.card_congr hequiv, ih hjN.le S hSj]

/-- **Every Schubert cell is an affine space.**  Over a field with `q` elements, the Schubert
cell of a jump set `S ⊆ {0,…,N-1}` relative to any complete flag of an `N`-dimensional space
has exactly `q ^ dimCell N S` points. -/
theorem card_cell (S : Finset ℕ) (hS : S ⊆ range N) :
    Nat.card {W : Submodule K V // Fl.jumpSet W = S} = Fintype.card K ^ dimCell N S := by
  have hequiv : {W : Submodule K V // Fl.jumpSet W = S} ≃
      {W : Submodule K V // W ≤ Fl.part N ∧ Fl.jumpSet W = S} := by
    refine (Equiv.subtypeEquivRight ?_).symm
    intro W
    rw [Fl.part_top]
    exact ⟨fun h => h.2, fun h => ⟨le_top, h⟩⟩
  rw [Nat.card_congr hequiv, card_cell_le_part Fl N (le_refl N) S hS]

/-- No Schubert cell exceeds the dimension `k(N-k)` of the Grassmannian. -/
theorem card_cell_le (S : Finset ℕ) (hS : S ⊆ range N) (k : ℕ) (hcard : S.card = k) :
    Nat.card {W : Submodule K V // Fl.jumpSet W = S} ≤ Fintype.card K ^ (k * (N - k)) := by
  rw [card_cell Fl S hS]
  exact Nat.pow_le_pow_right (le_of_lt Fintype.one_lt_card) (dimCell_le hS hcard)

/-- **Consistency of the two counts.**  Summing the cell sizes over all `k`-element jump sets
returns the Gaussian binomial coefficient, i.e. the point count of `Gr(k, N)` obtained
independently in `Geometry.SchubertCalculus.FiniteField`. -/
theorem sum_card_cell (k : ℕ) :
    ∑ S ∈ (range N).powersetCard k, Nat.card {W : Submodule K V // Fl.jumpSet W = S}
      = poincare ℕ k N (Fintype.card K) :=
  Finset.sum_congr rfl fun S hS => card_cell Fl S (Finset.mem_powersetCard.mp hS).1

/-- The big cell of `Gr(2, 𝔽₂⁴)` for the standard coordinate flag: the plane transverse to the
last two coordinate hyperplanes moves in an affine space of dimension `4`, so the cell has
`2 ^ 4 = 16` points (out of the `35` points of `Gr(2, 𝔽₂⁴)`). -/
theorem card_big_cell_two_four :
    Nat.card {W : Submodule (ZMod 2) (Fin 4 → ZMod 2) //
      (stdFlag (ZMod 2) 4).jumpSet W = {2, 3}} = 16 := by
  have hdim : dimCell 4 {2, 3} = 4 := by decide
  have hsub : ({2, 3} : Finset ℕ) ⊆ range 4 := by decide
  rw [card_cell (stdFlag (ZMod 2) 4) {2, 3} hsub, hdim, show Fintype.card (ZMod 2) = 2 from rfl]
  norm_num

end CellCount

end SchubertCalculus