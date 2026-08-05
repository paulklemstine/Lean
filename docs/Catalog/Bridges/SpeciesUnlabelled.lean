/-
# Unlabelled species structures: the symmetric-group action and Burnside's lemma

Functoriality of a species `F` makes the set `F[n]` of structures on `Fin n` a
`Sym(n)`-set; the orbits are the *unlabelled* (= isomorphism types of) `F`-structures.
This file records that action, defines the *type generating series* (the ordinary
generating series of unlabelled structures) and proves the species form of Burnside's
lemma:

    n! · (number of unlabelled F-structures on n points) = ∑_{σ ∈ Sym(n)} |Fix F(σ)|.

Together with `Bridges.SpeciesAnalyticBridge` this exhibits the two classical
generating series attached to one and the same functor: e.g. the species `E` of sets
has exponential generating series `exp X` and type generating series `1/(1-X)`.
-/
import Bridges.SpeciesAnalyticBridge

noncomputable section

namespace SpeciesEGF

open scoped BigOperators
open PowerSeries

namespace Species

/-- The symmetric group `Sym(n)` acts on the set of `F`-structures on `Fin n`
by transport of structure. -/
instance permAction (F : Species) (n : ℕ) :
    MulAction (Equiv.Perm (Fin n)) (F.obj (Fin n)) where
  smul σ x := F.map σ x
  one_smul x := F.map_refl x
  mul_smul σ τ x := (F.map_trans τ σ x).symm

theorem perm_smul_def (F : Species) {n : ℕ} (σ : Equiv.Perm (Fin n)) (x : F.obj (Fin n)) :
    σ • x = F.map σ x := rfl

variable (F : Species)

/-- The number of *unlabelled* `F`-structures on `n` points, i.e. the number of
isomorphism classes of `F`-structures, i.e. the number of `Sym(n)`-orbits on `F[n]`. -/
def unlabelled (n : ℕ) : ℕ :=
  Nat.card (Quotient (MulAction.orbitRel (Equiv.Perm (Fin n)) (F.obj (Fin n))))

/-- The type (ordinary) generating series of a species. -/
def tgf : ℚ⟦X⟧ := PowerSeries.mk fun n => (F.unlabelled n : ℚ)

@[simp] theorem coeff_tgf (n : ℕ) : coeff n F.tgf = (F.unlabelled n : ℚ) := coeff_mk _ _

/-- There are at most as many unlabelled structures as labelled ones. -/
theorem unlabelled_le_card (n : ℕ) : F.unlabelled n ≤ F.card n := by
  classical
  have hsurj : Function.Surjective
      (Quotient.mk (MulAction.orbitRel (Equiv.Perm (Fin n)) (F.obj (Fin n)))) :=
    Quotient.mk_surjective
  exact Nat.card_le_card_of_surjective _ hsurj

/-- **Burnside's lemma for species.**  The number of unlabelled `F`-structures on `n`
points, multiplied by `n!`, is the total number of structures fixed by the transport
maps `F(σ)`, `σ ∈ Sym(n)`. -/
theorem burnside (n : ℕ) :
    ∑ σ : Equiv.Perm (Fin n), Nat.card {x : F.obj (Fin n) // F.map σ x = x}
      = F.unlabelled n * n.factorial := by
  classical
  letI : Fintype (F.obj (Fin n)) := Fintype.ofFinite _
  letI : ∀ σ : Equiv.Perm (Fin n), Fintype (MulAction.fixedBy (F.obj (Fin n)) σ) :=
    fun _ => Fintype.ofFinite _
  letI : Fintype (Quotient (MulAction.orbitRel (Equiv.Perm (Fin n)) (F.obj (Fin n)))) :=
    Fintype.ofFinite _
  have key := MulAction.sum_card_fixedBy_eq_card_orbits_mul_card_group
    (Equiv.Perm (Fin n)) (F.obj (Fin n))
  have hperm : Fintype.card (Equiv.Perm (Fin n)) = n.factorial := by
    simp [Fintype.card_perm]
  rw [unlabelled, Nat.card_eq_fintype_card, ← hperm, ← key]
  refine Finset.sum_congr rfl fun σ _ => ?_
  rw [Nat.card_eq_fintype_card]
  exact Fintype.card_congr (Equiv.refl _)

/-- Only the identity contributes all structures, so `n!` times the unlabelled count
dominates the labelled count. -/
theorem card_le_factorial_mul_unlabelled (n : ℕ) :
    F.card n ≤ F.unlabelled n * n.factorial := by
  classical
  rw [← burnside]
  have h1 : Nat.card {x : F.obj (Fin n) // F.map (1 : Equiv.Perm (Fin n)) x = x}
      = F.card n := by
    have : {x : F.obj (Fin n) // F.map (1 : Equiv.Perm (Fin n)) x = x} ≃ F.obj (Fin n) :=
      { toFun := fun x => x.1
        invFun := fun x => ⟨x, F.map_refl x⟩
        left_inv := fun x => Subtype.ext rfl
        right_inv := fun _ => rfl }
    rw [Nat.card_congr this, card]
  calc F.card n = Nat.card {x : F.obj (Fin n) // F.map (1 : Equiv.Perm (Fin n)) x = x} := h1.symm
    _ ≤ ∑ σ : Equiv.Perm (Fin n), Nat.card {x : F.obj (Fin n) // F.map σ x = x} :=
        Finset.single_le_sum (f := fun σ : Equiv.Perm (Fin n) =>
          Nat.card {x : F.obj (Fin n) // F.map σ x = x}) (fun _ _ => Nat.zero_le _)
          (Finset.mem_univ 1)

/-! ## Examples -/

/-- There is exactly one unlabelled set structure of each size. -/
@[simp] theorem unlabelled_set (n : ℕ) : set.unlabelled n = 1 := by
  have : Unique (Quotient (MulAction.orbitRel (Equiv.Perm (Fin n)) (set.obj (Fin n)))) :=
    { default := Quotient.mk _ PUnit.unit
      uniq := fun q => by
        induction q using Quotient.inductionOn with
        | h x => cases x; rfl }
  simp [unlabelled]

/-- The species of sets has type generating series `1/(1-X)`, while its exponential
generating series is `exp X` (`egf_set`). -/
theorem tgf_set : set.tgf * (1 - PowerSeries.X) = 1 := by
  ext n
  match n with
  | 0 =>
      have h0 : coeff 0 set.tgf = 1 := by simp
      rw [PowerSeries.coeff_zero_eq_constantCoeff] at h0
      simp [h0]
  | (n + 1) =>
      rw [mul_sub, map_sub, mul_one, coeff_tgf, PowerSeries.coeff_succ_mul_X, coeff_tgf]
      simp

/-- Transport of a permutation along a permutation is conjugation. -/
theorem perm_map_eq_conj {n : ℕ} (σ x : Equiv.Perm (Fin n)) :
    perm.map σ x = σ * x * σ⁻¹ := Equiv.ext fun _ => rfl

/-- Unlabelled structures for the species of permutations are exactly the conjugacy
classes of the symmetric group. -/
theorem unlabelled_perm (n : ℕ) :
    perm.unlabelled n = Nat.card (ConjClasses (Equiv.Perm (Fin n))) := by
  rw [unlabelled]
  refine Nat.card_congr (Quotient.congr (Equiv.refl _) ?_)
  intro x y
  show (∃ σ : Equiv.Perm (Fin n), perm.map σ y = x) ↔
      IsConj (show Equiv.Perm (Fin n) from x) (show Equiv.Perm (Fin n) from y)
  constructor
  · rintro ⟨σ, hσ⟩
    have h2 : σ * (show Equiv.Perm (Fin n) from y) * σ⁻¹ = x := by
      rw [← perm_map_eq_conj]; exact hσ
    exact (isConj_iff.2 ⟨σ, h2⟩).symm
  · intro h
    obtain ⟨σ, hσ⟩ := isConj_iff.1 h.symm
    exact ⟨σ, by rw [perm_map_eq_conj]; exact hσ⟩

end Species

end SpeciesEGF