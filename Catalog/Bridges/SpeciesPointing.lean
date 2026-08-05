/-
# Pointing a species

The *pointed* species `F•` has as structures on `A` the pairs consisting of an
`F`-structure on `A` and a distinguished element of `A`.  Pointing is the combinatorial
counterpart of the operator `X · d/dX` on exponential generating series:

    egf (F•) = X · (d/dX) (egf F),

and on the combinatorial side `F• ` is equipotent with `X · F′` (`Species.card_pointing`
in the core file counts the latter).

As an application, pointing the species of sets gives the species of pointed sets, whose
exponential generating series is `X · exp X`, and iterating the construction gives
`∑ₙ nᵏ Xⁿ/n!` as the `k`-fold pointing of `E`.
-/
import Bridges.SpeciesIso

noncomputable section

namespace SpeciesEGF

open scoped BigOperators
open PowerSeries

namespace Species

variable (F : Species)

/-- The pointed species `F•`: an `F`-structure together with a distinguished point of the
underlying set. -/
def point : Species where
  obj A := A × F.obj A
  map e x := (e x.1, F.map e x.2)
  map_refl x := by simp
  map_trans e f x := by
    refine Prod.ext rfl ?_
    exact F.map_trans e f x.2
  finite A _ := inferInstance

/-- Pointing multiplies the number of structures by the size of the underlying set. -/
@[simp] theorem card_point (n : ℕ) : F.point.card n = n * F.card n := by
  show Nat.card (Fin n × F.obj (Fin n)) = n * F.card n
  rw [Nat.card_prod]
  simp [card]

/-- `F•` and `X · F′` have the same counting sequence: pointing is `X · d/dX`. -/
theorem card_point_eq_card_sing_mul_deriv (n : ℕ) :
    F.point.card n = (sing.mul F.deriv).card n := by
  rw [card_point, card_pointing]

/-- **The bridge theorem for pointing**: `egf (F•) = X · (d/dX) (egf F)`. -/
theorem egf_point : F.point.egf = PowerSeries.X * d⁄dX ℚ F.egf := by
  ext n
  match n with
  | 0 =>
      rw [coeff_egf, card_point]
      simp
  | (n + 1) =>
      rw [coeff_egf, card_point, PowerSeries.coeff_succ_X_mul, PowerSeries.coeff_derivative,
        coeff_egf, Nat.factorial_succ]
      have h : (n.factorial : ℚ) ≠ 0 := Nat.cast_ne_zero.2 (Nat.factorial_ne_zero n)
      push_cast
      field_simp

/-! ## Pointing is `X · F′` -/

open scoped Classical

/-- Puncturing `A` at the unique point where the Boolean predicate `p` is true. -/
def punctureEquiv {A : Type} (a : A) (p : A → Bool) (hp : ∀ b, p b = true ↔ b = a) :
    A ≃ Option {b : A // p b = false} where
  toFun b := if h : p b = true then none else some ⟨b, by simpa using h⟩
  invFun o := Option.elim o a Subtype.val
  left_inv b := by
    dsimp only
    by_cases h : p b = true
    · rw [dif_pos h]
      exact ((hp b).1 h).symm
    · rw [dif_neg h]
      rfl
  right_inv o := by
    dsimp only
    cases o with
    | none => exact dif_pos ((hp a).2 rfl)
    | some c =>
        have h : ¬ p c.1 = true := by simp [c.2]
        exact dif_neg h

/-- A pointed `F`-structure gives a splitting of the underlying set into the marked point
and its complement, with an `F′`-structure on the complement. -/
def pointHom (A : Type) : F.point.obj A → (sing.mul F.deriv).obj A := fun x =>
  ⟨fun b => decide (b = x.1),
    ⟨⟨x.1, by simp⟩, fun c => Subtype.ext (by simpa using c.2)⟩,
    F.map (punctureEquiv x.1 (fun b => decide (b = x.1)) (by simp)) x.2⟩

/-- The inverse construction: the marked point is the unique point of the singleton part,
and the `F′`-structure on the complement becomes an `F`-structure on all of `A`. -/
def pointInv (A : Type) : (sing.mul F.deriv).obj A → F.point.obj A := fun x =>
  (x.2.1.1.1,
    F.map (punctureEquiv x.2.1.1.1 x.1
      (fun b => ⟨fun h => congrArg Subtype.val (x.2.1.2 ⟨b, h⟩), fun h => h ▸ x.2.1.1.2⟩)).symm
      x.2.2)

theorem pointInv_pointHom (A : Type) (x : F.point.obj A) :
    pointInv F A (pointHom F A x) = x := by
  refine Prod.ext rfl ?_
  have key : ∀ h : ∀ b, (decide (b = x.1) : Bool) = true ↔ b = x.1,
      F.map (punctureEquiv x.1 (fun b => decide (b = x.1)) h).symm
        (F.map (punctureEquiv x.1 (fun b => decide (b = x.1)) h) x.2) = x.2 := by
    intro h
    rw [F.map_trans, Equiv.self_trans_symm, F.map_refl]
  exact key (by simp)

theorem pointHom_pointInv (A : Type) (x : (sing.mul F.deriv).obj A) :
    pointHom F A (pointInv F A x) = x := by
  obtain ⟨p, ⟨⟨a, ha⟩, hu⟩, y⟩ := x
  have hp : ∀ b, p b = true ↔ b = a :=
    fun b => ⟨fun h => congrArg Subtype.val (hu ⟨b, h⟩), fun h => h ▸ ha⟩
  have hpe : (fun b => decide (b = a)) = p := by
    funext b
    by_cases h : b = a
    · subst h
      simp [ha]
    · have h' : p b = false := by
        rcases Bool.eq_false_or_eq_true (p b) with hb | hb
        · exact absurd ((hp b).1 hb) h
        · exact hb
      simp [h, h']
  subst hpe
  refine Sigma.ext rfl (heq_of_eq (Prod.ext ?_ ?_))
  · exact Subtype.ext (Subtype.ext rfl)
  · have key : ∀ h : ∀ b, (decide (b = a) : Bool) = true ↔ b = a,
        F.map (punctureEquiv a (fun b => decide (b = a)) h)
          (F.map (punctureEquiv a (fun b => decide (b = a)) h).symm y) = y := by
      intro h
      rw [F.map_trans, Equiv.symm_trans_self, F.map_refl]
    exact key (by simp)

/-- Pointing is the same thing as multiplying the derivative by `X`, as an equivalence of
structure sets. -/
def pointEquiv (A : Type) : F.point.obj A ≃ (sing.mul F.deriv).obj A where
  toFun := pointHom F A
  invFun := pointInv F A
  left_inv := pointInv_pointHom F A
  right_inv := pointHom_pointInv F A

/-- Transport along equal bijections agrees. -/
theorem map_congr {A B : Type} {e f : A ≃ B} (h : e = f) (x : F.obj A) :
    F.map e x = F.map f x := by rw [h]

theorem pointHom_naturality {A B : Type} (e : A ≃ B) (x : F.point.obj A) :
    pointHom F B (F.point.map e x) = (sing.mul F.deriv).map e (pointHom F A x) := by
  apply (pointEquiv F B).symm.injective
  have hL : (pointEquiv F B).symm (pointHom F B (F.point.map e x)) = F.point.map e x :=
    pointInv_pointHom F B _
  rw [hL]
  refine Prod.ext rfl ?_
  show F.map e x.2 = F.map _ (F.map _ (F.map _ x.2))
  rw [F.map_trans, F.map_trans]
  refine map_congr F ?_ x.2
  refine Equiv.ext fun b => ?_
  by_cases hb : b = x.1
  · subst hb
    simp [punctureEquiv, pointHom, mul, sing, Equiv.subtypeEquiv]
  · simp [punctureEquiv, pointHom, mul, sing, Equiv.subtypeEquiv, hb]

/-- **Pointing is `X · F′`**: the pointed species is naturally isomorphic to the product
of the singleton species with the derivative. -/
def pointIso : F.point ≃ₛ sing.mul F.deriv where
  hom := pointEquiv F
  naturality e x := pointHom_naturality F e x

/-- Consequently `egf (F•) = X · (d/dX) (egf F)` also follows from the isomorphism. -/
theorem egf_point_of_iso : F.point.egf = (sing.mul F.deriv).egf :=
  (pointIso F).egf_eq

/-! ## Examples -/

/-- A pointed set on `n` points: `n` structures. -/
@[simp] theorem card_point_set (n : ℕ) : set.point.card n = n := by
  simp

/-- The exponential generating series of pointed sets is `X · exp X`. -/
theorem egf_point_set : set.point.egf = PowerSeries.X * d⁄dX ℚ (PowerSeries.exp ℚ) := by
  rw [egf_point, egf_set]

/-- Iterated pointing of the species of sets counts functions to a fixed `k`-element set
in disguise: `|E•⋯•[n]| = nᵏ`. -/
theorem card_iterate_point_set (k n : ℕ) : (point^[k] set).card n = n ^ k := by
  induction k with
  | zero => simp
  | succ k ih =>
      rw [Function.iterate_succ_apply', card_point, ih, pow_succ]
      ring

/-- Pointing the species of permutations: `n · n!` structures on `n` points. -/
@[simp] theorem card_point_perm (n : ℕ) : perm.point.card n = n * n.factorial := by
  simp

end Species

end SpeciesEGF