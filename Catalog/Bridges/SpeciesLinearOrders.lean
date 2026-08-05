/-
# Equipotent but non-isomorphic species

The species `L` of linear orders and the species `S` of permutations both have `n!`
structures on an `n`-element set, so they have the same exponential generating series
`1/(1-X)`.  They are nevertheless **not isomorphic** as species: `Sym(n)` acts
transitively on linear orders (all linear orders of a finite set look alike), while it
acts on permutations by conjugation, which for `n = 2` is the trivial action with two
orbits.

Thus the exponential generating series — a complete invariant of the *counting
sequence* (`Species.egf_eq_iff`) — is *not* a complete invariant of a species up to
natural isomorphism.  The finer invariant `Species.unlabelled` separates them.
-/
import Bridges.SpeciesIso

noncomputable section

namespace SpeciesEGF

open scoped BigOperators
open PowerSeries

namespace Species

/-- The species of linear orders: a linear order on `A` is encoded as a bijection with
the standard ordered set `Fin |A|`. -/
def linOrd : Species where
  obj A := A ≃ Fin (Nat.card A)
  map e l := (e.symm.trans l).trans (finCongr (Nat.card_congr e))
  map_refl _ := Equiv.ext fun _ => rfl
  map_trans _ _ _ := Equiv.ext fun _ => rfl
  finite _ _ := Equiv.finite_left

@[simp] theorem card_linOrd (n : ℕ) : linOrd.card n = n.factorial := by
  have h : Nat.card (Fin n) = n := by simp
  have : Nat.card (linOrd.obj (Fin n)) = Nat.card (Fin n ≃ Fin n) :=
    Nat.card_congr (Equiv.equivCongr (Equiv.refl _) (finCongr h))
  rw [card, this, Nat.card_eq_fintype_card, Fintype.card_equiv (Equiv.refl (Fin n))]
  simp

/-- Linear orders and permutations have the same counting sequence. -/
theorem card_linOrd_eq_card_perm (n : ℕ) : linOrd.card n = perm.card n := by
  simp

/-- Hence they have the same exponential generating series, namely `1/(1-X)`. -/
theorem egf_linOrd_eq_egf_perm : linOrd.egf = perm.egf :=
  (egf_eq_iff _ _).2 card_linOrd_eq_card_perm

theorem egf_linOrd : linOrd.egf * (1 - PowerSeries.X) = 1 := by
  rw [egf_linOrd_eq_egf_perm]
  exact egf_perm

/-! ## The symmetric group acts transitively on linear orders -/

theorem linOrd_transitive {n : ℕ} (x y : linOrd.obj (Fin n)) :
    ∃ σ : Equiv.Perm (Fin n), linOrd.map σ x = y := by
  refine ⟨((y.trans (finCongr (Nat.card_congr (Equiv.refl (Fin n)))).symm).trans x.symm).symm, ?_⟩
  apply Equiv.ext
  intro b
  simp [linOrd]

/-- There is exactly one unlabelled linear order on `n` points. -/
@[simp] theorem unlabelled_linOrd (n : ℕ) : linOrd.unlabelled n = 1 := by
  have hne : Nonempty (linOrd.obj (Fin n)) :=
    ⟨show Fin n ≃ Fin (Nat.card (Fin n)) from finCongr (by simp)⟩
  have : Unique (Quotient (MulAction.orbitRel (Equiv.Perm (Fin n)) (linOrd.obj (Fin n)))) :=
    { default := Quotient.mk _ hne.some
      uniq := by
        intro q
        induction q using Quotient.inductionOn with
        | h x =>
            obtain ⟨σ, hσ⟩ := linOrd_transitive hne.some x
            exact Quotient.sound
              (show ∃ τ : Equiv.Perm (Fin n), τ • hne.some = x from ⟨σ, hσ⟩) }
  simp [unlabelled]

/-! ## Permutations of a two-element set: the action is trivial -/

/-- On two points the transport action on permutations is trivial, so there are two
unlabelled structures. -/
theorem unlabelled_perm_two : perm.unlabelled 2 = 2 := by
  classical
  have hcomm : ∀ a b : Equiv.Perm (Fin 2), a * b = b * a := by decide
  have htriv : ∀ (σ : Equiv.Perm (Fin 2)) (x : perm.obj (Fin 2)), perm.map σ x = x := by
    intro σ x
    rw [perm_map_eq_conj, hcomm]
    simp
  have hbij : Function.Bijective
      (Quotient.mk (MulAction.orbitRel (Equiv.Perm (Fin 2)) (perm.obj (Fin 2)))) := by
    refine ⟨?_, Quotient.mk_surjective⟩
    intro x y h
    obtain ⟨σ, hσ⟩ := Quotient.exact h
    have h2 : perm.map σ y = x := hσ
    rw [htriv] at h2
    exact h2.symm
  rw [unlabelled, ← Nat.card_eq_of_bijective _ hbij]
  show Nat.card (Equiv.Perm (Fin 2)) = 2
  rw [Nat.card_eq_fintype_card, Fintype.card_perm]
  simp

/-! ## The two species are not isomorphic -/

/-- **Equipotent but not isomorphic.**  The species of linear orders and the species of
permutations have equal exponential generating series but are not isomorphic; the
exponential generating series is therefore not a complete invariant of a species. -/
theorem linOrd_not_iso_perm : IsEmpty (linOrd ≃ₛ perm) := by
  refine ⟨fun φ => ?_⟩
  have h := φ.unlabelled_eq 2
  rw [unlabelled_linOrd, unlabelled_perm_two] at h
  exact absurd h (by decide)

end Species

end SpeciesEGF