/-
# The species of cycles and the logarithm

A *cyclic structure* on a finite set `A` is a permutation of `A` which acts transitively
on `A` (so `A` must be nonempty); equivalently, `A` is arranged in a single cycle.
Cyclic structures form a species `C`, and the classical count is

    |C[n]| = (n-1)!   (n ≥ 1),      |C[0]| = 0 .

On the analytic side this says that the derivative of the exponential generating series
of `C` is `1/(1-X)` — i.e. `egf C = log (1/(1-X))` — which we state without logarithms as

    (d/dX) (egf C) · (1 - X) = 1,      constantCoeff (egf C) = 0 .

Finally, all cyclic structures on a fixed finite set are equivalent under relabelling
(any two `n`-cycles are conjugate), so `C` has exactly one unlabelled structure in each
positive size, and its type generating series is `X/(1-X)`.
-/
import Bridges.SpeciesLinearOrders

noncomputable section

namespace SpeciesEGF

open scoped BigOperators
open Equiv Equiv.Perm PowerSeries

namespace Species

/-- Transporting a permutation along a bijection preserves the property of acting
transitively on the whole set. -/
theorem isCycleOn_univ_congr {A B : Type} (e : A ≃ B) {σ : Perm A}
    (h : σ.IsCycleOn (Set.univ : Set A)) :
    (Equiv.permCongrHom e σ).IsCycleOn (Set.univ : Set B) := by
  refine ⟨(Equiv.permCongrHom e σ : Perm B).bijective.bijOn_univ, ?_⟩
  intro x _ y _
  obtain ⟨i, hi⟩ := h.2 (Set.mem_univ (e.symm x)) (Set.mem_univ (e.symm y))
  refine ⟨i, ?_⟩
  rw [← map_zpow]
  show e ((σ ^ i) (e.symm x)) = y
  rw [hi]
  simp

/-- The species `C` of cycles: a `C`-structure on `A` is a permutation of the nonempty
set `A` acting transitively on it. -/
def cyc : Species where
  obj A := {σ : Perm A // Nonempty A ∧ σ.IsCycleOn (Set.univ : Set A)}
  map e x := ⟨Equiv.permCongrHom e x.1, x.2.1.map e, isCycleOn_univ_congr e x.2.2⟩
  map_refl _ := Subtype.ext (Equiv.ext fun _ => rfl)
  map_trans _ _ _ := Subtype.ext (Equiv.ext fun _ => rfl)
  finite A _ := by
    have : Finite (Perm A) := Equiv.finite_left
    exact Subtype.finite

/-! ## Counting cycles -/

/-- There is no cyclic structure on the empty set. -/
@[simp] theorem card_cyc_zero : cyc.card 0 = 0 := by
  have : IsEmpty (cyc.obj (Fin 0)) := ⟨fun x => x.2.1.elim (fun a => a.elim0)⟩
  simp [card]

/-- There is exactly one cyclic structure on a one-element set. -/
@[simp] theorem card_cyc_one : cyc.card 1 = 1 := by
  have : Unique (cyc.obj (Fin 1)) :=
    { default := ⟨1, ⟨0⟩, isCycleOn_of_subsingleton _ _⟩
      uniq := fun x => Subtype.ext (Equiv.ext fun a => Subsingleton.elim _ _) }
  simp [card]

/-- On a set with at least two elements, acting transitively is the same as being an
`n`-cycle, i.e. having cycle type `{n}`. -/
theorem isCycleOn_univ_iff_cycleType {n : ℕ} (hn : 2 ≤ n) (σ : Perm (Fin n)) :
    σ.IsCycleOn (Set.univ : Set (Fin n)) ↔ σ.cycleType = {(n : ℕ)} := by
  have hntriv : (Set.univ : Set (Fin n)).Nontrivial := by
    refine ⟨⟨0, by omega⟩, Set.mem_univ _, ⟨1, by omega⟩, Set.mem_univ _, ?_⟩
    simp [Fin.ext_iff]
  constructor
  · intro h
    have hcycle : σ.IsCycle :=
      Equiv.Perm.isCycle_iff_exists_isCycleOn.2 ⟨Set.univ, hntriv, h, fun _ _ => Set.mem_univ _⟩
    have hsupp : σ.support = Finset.univ :=
      Finset.eq_univ_iff_forall.2 fun a =>
        Perm.mem_support.2 (h.apply_ne hntriv (Set.mem_univ a))
    rw [hcycle.cycleType, hsupp]
    simp
  · intro h
    have hcycle : σ.IsCycle := by
      rw [← Equiv.Perm.card_cycleType_eq_one, h]
      simp
    have hcard : σ.support.card = n := by
      rw [← Equiv.Perm.sum_cycleType, h]
      simp
    have hsupp : {x : Fin n | σ x ≠ x} = (Set.univ : Set (Fin n)) := by
      have : σ.support = Finset.univ :=
        Finset.eq_univ_of_card _ (by simpa using hcard)
      ext a
      simpa using (Perm.mem_support (f := σ) (x := a)).1 (this ▸ Finset.mem_univ a)
    exact hsupp ▸ hcycle.isCycleOn

/-- **There are `(n-1)!` cyclic structures on `n ≥ 2` points.** -/
theorem card_cyc_of_two_le {n : ℕ} (hn : 2 ≤ n) : cyc.card n = (n - 1).factorial := by
  classical
  have hne : Nonempty (Fin n) := ⟨⟨0, by omega⟩⟩
  have hequiv : cyc.obj (Fin n) ≃ {σ : Perm (Fin n) // σ.cycleType = {(n : ℕ)}} :=
    { toFun := fun x => ⟨x.1, (isCycleOn_univ_iff_cycleType hn x.1).1 x.2.2⟩
      invFun := fun x => ⟨x.1, hne, (isCycleOn_univ_iff_cycleType hn x.1).2 x.2⟩
      left_inv := fun _ => Subtype.ext rfl
      right_inv := fun _ => Subtype.ext rfl }
  have hcard : Fintype.card (Fin n) = n := Fintype.card_fin n
  have hfin := Equiv.Perm.card_of_cycleType_singleton (α := Fin n) hn (by rw [hcard])
  rw [card, Nat.card_congr hequiv, Nat.card_eq_fintype_card, Fintype.card_subtype]
  rw [show (Finset.univ.filter fun σ : Perm (Fin n) => σ.cycleType = {(n : ℕ)})
      = ({g | g.cycleType = {(n : ℕ)}} : Finset (Perm (Fin n))) from rfl, hfin, hcard]
  simp

/-- The number of cyclic structures on `n ≥ 1` points is `(n-1)!`. -/
theorem card_cyc {n : ℕ} (hn : 1 ≤ n) : cyc.card n = (n - 1).factorial := by
  match n, hn with
  | 1, _ => simp
  | (n + 2), _ => exact card_cyc_of_two_le (by omega)

/-! ## The generating series: cycles and the logarithm -/

/-- The derivative species of `C` counts `n!` structures: pointing a cycle at a marked
point turns it into a linear order. -/
@[simp] theorem card_deriv_cyc (n : ℕ) : cyc.deriv.card n = n.factorial := by
  rw [card_deriv, card_cyc (n := n + 1) (by omega)]
  simp

/-- The derivative of the species of cycles is equipotent with the species of linear
orders. -/
theorem egf_deriv_cyc_eq_egf_linOrd : cyc.deriv.egf = linOrd.egf :=
  (egf_eq_iff _ _).2 fun n => by rw [card_deriv_cyc, card_linOrd]

/-- **`egf C = log (1/(1-X))`**, stated as: the derivative of `egf C` is `1/(1-X)`. -/
theorem deriv_egf_cyc : (d⁄dX ℚ cyc.egf) * (1 - PowerSeries.X) = 1 := by
  rw [← egf_deriv, egf_deriv_cyc_eq_egf_linOrd]
  exact egf_linOrd

/-- The exponential generating series of `C` has zero constant term. -/
@[simp] theorem constantCoeff_egf_cyc : constantCoeff cyc.egf = 0 := by
  rw [← PowerSeries.coeff_zero_eq_constantCoeff, coeff_egf]
  simp

/-! ## Unlabelled cycles -/

/-- Any two cyclic structures on the same finite set are related by a relabelling. -/
theorem cyc_transitive {n : ℕ} (x y : cyc.obj (Fin n)) :
    ∃ σ : Equiv.Perm (Fin n), cyc.map σ x = y := by
  classical
  rcases Nat.lt_or_ge n 2 with hn | hn
  · refine ⟨1, Subtype.ext (Equiv.ext fun a => ?_)⟩
    have hsub : Subsingleton (Fin n) := by
      match n, hn with
      | 0, _ => exact ⟨fun a => a.elim0⟩
      | 1, _ => infer_instance
    exact Subsingleton.elim _ _
  · have hx := (isCycleOn_univ_iff_cycleType hn x.1).1 x.2.2
    have hy := (isCycleOn_univ_iff_cycleType hn y.1).1 y.2.2
    have hconj : IsConj x.1 y.1 := Equiv.Perm.isConj_iff_cycleType_eq.2 (by rw [hx, hy])
    obtain ⟨σ, hσ⟩ := isConj_iff.1 hconj
    exact ⟨σ, Subtype.ext (Equiv.ext fun a => congrArg (fun f : Perm (Fin n) => f a) hσ)⟩

/-- There is exactly one unlabelled cyclic structure on `n ≥ 1` points. -/
theorem unlabelled_cyc {n : ℕ} (hn : 1 ≤ n) : cyc.unlabelled n = 1 := by
  classical
  have hne : Nonempty (cyc.obj (Fin n)) := by
    have hne0 : Nonempty (Fin n) := ⟨⟨0, by omega⟩⟩
    rcases Nat.lt_or_ge n 2 with h2 | h2
    · haveI hsub : Subsingleton (Fin n) := by
        match n, hn, h2 with
        | 1, _, _ => infer_instance
      exact ⟨⟨1, hne0, isCycleOn_of_subsingleton _ _⟩⟩
    · have hpos : (0 : ℕ) < cyc.card n := by
        rw [card_cyc hn]
        exact Nat.factorial_pos _
      rw [card, Nat.card_pos_iff] at hpos
      exact hpos.1
  have : Unique (Quotient (MulAction.orbitRel (Equiv.Perm (Fin n)) (cyc.obj (Fin n)))) :=
    { default := Quotient.mk _ hne.some
      uniq := by
        intro q
        induction q using Quotient.inductionOn with
        | h x =>
            obtain ⟨σ, hσ⟩ := cyc_transitive hne.some x
            exact Quotient.sound
              (show ∃ τ : Equiv.Perm (Fin n), τ • hne.some = x from ⟨σ, hσ⟩) }
  simp [unlabelled]

/-- There are no unlabelled cyclic structures on the empty set. -/
@[simp] theorem unlabelled_cyc_zero : cyc.unlabelled 0 = 0 := by
  have : IsEmpty (cyc.obj (Fin 0)) := ⟨fun x => x.2.1.elim (fun a => a.elim0)⟩
  have : IsEmpty (Quotient (MulAction.orbitRel (Equiv.Perm (Fin 0)) (cyc.obj (Fin 0)))) :=
    ⟨fun q => Quotient.inductionOn q fun x => (this.false x)⟩
  simp [unlabelled]

/-- The type generating series of the species of cycles is `X/(1-X)`. -/
theorem tgf_cyc : cyc.tgf * (1 - PowerSeries.X) = PowerSeries.X := by
  ext n
  match n with
  | 0 =>
      have h0 : coeff 0 cyc.tgf = 0 := by simp
      rw [mul_sub, map_sub, mul_one, h0]
      simp
  | 1 =>
      rw [mul_sub, map_sub, mul_one, coeff_tgf, unlabelled_cyc le_rfl,
        PowerSeries.coeff_succ_mul_X, coeff_tgf]
      simp
  | (n + 2) =>
      rw [mul_sub, map_sub, mul_one, coeff_tgf, unlabelled_cyc (by omega),
        PowerSeries.coeff_succ_mul_X, coeff_tgf, unlabelled_cyc (by omega)]
      simp [PowerSeries.coeff_X]

end Species

end SpeciesEGF