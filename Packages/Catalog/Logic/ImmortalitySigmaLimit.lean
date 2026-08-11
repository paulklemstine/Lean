import Logic.ImmortalityHierarchy

/-!
# Lexicographic limits of increasing families of survival games

The limit clock of `Catalog/Logic/ImmortalityHierarchy.lean` stacks the finite-depth clocks in a
dependent lexicographic sigma type and has survival value `ω ^ ω`.  This file isolates the
general mechanism behind that computation.

Given any family `A : ℕ → SurvivalGame`, the game `sigmaGame A` plays the lives `A 0, A 1, …`
one after another, lexicographically.  Well-foundedness of the resulting order — which Mathlib
does not provide for lexicographic sigma types — is obtained from the explicit *key*

```
sigmaKey ⟨k, a⟩ = landmark k + typein a,    landmark k = (A 0).value + ⋯ + (A (k-1)).value.
```

The main theorem `sigmaGame_value_eq` says: if `o` is additively principal, every `(A k).value`
is below `o`, and the values are cofinal in `o`, then `(sigmaGame A).value = o`.  Additive
principality is exactly what makes the running landmarks stay below `o`, so the family cannot
overshoot its own supremum.  Conjecture 4 is the instance `A k = natClock k`, `o = ω ^ ω`
(`sigmaGame_natClock_value`).
-/

namespace ImmortalitySigmaLimit

open Ordinal ImmortalityGame ImmortalityHierarchy

variable (A : ℕ → SurvivalGame)

/-- The starting time of the `k`-th life: the sum of all earlier survival values. -/
noncomputable def landmark : ℕ → Ordinal.{0}
  | 0 => 0
  | (k + 1) => landmark k + (A k).value

/-- The absolute time of a moment: its position inside its own life, shifted by the landmark. -/
noncomputable def sigmaKey (x : Σ k : ℕ, (A k).Moment) : Ordinal.{0} :=
  landmark A x.1 + typein (α := (A x.1).Moment) (· < ·) x.2

theorem typein_lt_value {k : ℕ} (a : (A k).Moment) :
    typein (α := (A k).Moment) (· < ·) a < (A k).value :=
  typein_lt_type _ a

theorem sigmaKey_lt_landmark_succ (x : Σ k : ℕ, (A k).Moment) :
    sigmaKey A x < landmark A (x.1 + 1) :=
  add_lt_add_right (typein_lt_value A x.2) _

theorem landmark_mono : Monotone (landmark A) := by
  refine monotone_nat_of_le_succ fun k => ?_
  show landmark A k ≤ landmark A k + (A k).value
  exact le_self_add

theorem sigmaKey_strictMono {x y : Σₗ k : ℕ, (A k).Moment} (h : x < y) :
    sigmaKey A x < sigmaKey A y := by
  cases h with
  | @left i j a b hij =>
      refine (sigmaKey_lt_landmark_succ A ⟨i, a⟩).trans_le ?_
      exact (landmark_mono A hij).trans le_self_add
  | @right i a b hab =>
      exact add_lt_add_right ((typein_lt_typein _).2 hab) _

theorem sigmaLt_wellFounded :
    WellFounded ((· < ·) : (Σₗ k : ℕ, (A k).Moment) → (Σₗ k : ℕ, (A k).Moment) → Prop) :=
  Subrelation.wf (fun {_ _} h => sigmaKey_strictMono A h)
    (InvImage.wf (sigmaKey A) Ordinal.lt_wf)

instance instIsWellFoundedSigmaLex : IsWellFounded (Σₗ k : ℕ, (A k).Moment) (· < ·) :=
  ⟨sigmaLt_wellFounded A⟩

instance instIsWellOrderSigmaLex : IsWellOrder (Σₗ k : ℕ, (A k).Moment) (· < ·) := {}

/-- Living the lives `A 0, A 1, …` one after another. -/
def sigmaGame : SurvivalGame where
  Moment := Σₗ k : ℕ, (A k).Moment

/-- Each individual life embeds into the concatenated one. -/
def sigmaFiber (k : ℕ) : ((· < ·) : (A k).Moment → (A k).Moment → Prop) ↪r
    ((· < ·) : (sigmaGame A).Moment → (sigmaGame A).Moment → Prop) :=
  RelEmbedding.ofMonotone (fun a => (⟨k, a⟩ : Σₗ k : ℕ, (A k).Moment))
    (fun _ _ h => Sigma.Lex.lt_def.2 (Or.inr ⟨rfl, h⟩))

theorem value_le_sigmaGame_value (k : ℕ) : (A k).value ≤ (sigmaGame A).value := by
  have h := (sigmaFiber A k).ordinal_type_le
  rwa [← SurvivalGame.value, ← SurvivalGame.value] at h

/-- Additive principality keeps every landmark below `o`. -/
theorem landmark_lt {o : Ordinal.{0}} (ho : Principal (· + ·) o) (hpos : 0 < o)
    (hA : ∀ k, (A k).value < o) : ∀ k, landmark A k < o := by
  intro k
  induction k with
  | zero => exact hpos
  | succ k ih => exact ho ih (hA k)

theorem sigmaGame_value_le {o : Ordinal.{0}} (ho : Principal (· + ·) o) (hpos : 0 < o)
    (hA : ∀ k, (A k).value < o) : (sigmaGame A).value ≤ o := by
  have hlt : ∀ x : (sigmaGame A).Moment, sigmaKey A x < o := fun x =>
    (sigmaKey_lt_landmark_succ A x).trans (landmark_lt A ho hpos hA (x.1 + 1))
  have e : ((· < ·) : (sigmaGame A).Moment → (sigmaGame A).Moment → Prop) ↪r
      ((· < ·) : o.ToType → o.ToType → Prop) :=
    RelEmbedding.ofMonotone (fun x => Ordinal.ToType.mk ⟨sigmaKey A x, hlt x⟩)
      (fun _ _ h => by simpa using sigmaKey_strictMono A h)
  have h := e.ordinal_type_le
  rwa [← SurvivalGame.value, type_toType] at h

theorem le_sigmaGame_value {o : Ordinal.{0}} (hcof : ∀ p < o, ∃ k, p < (A k).value) :
    o ≤ (sigmaGame A).value := by
  by_contra hlt
  push_neg at hlt
  obtain ⟨k, hk⟩ := hcof _ hlt
  exact absurd (value_le_sigmaGame_value A k) (not_le.2 hk)

/-- **Limit theorem.**  A lexicographic chain of lives whose values are cofinal in an additively
principal ordinal `o`, and all below `o`, has survival value exactly `o`. -/
theorem sigmaGame_value_eq {o : Ordinal.{0}} (ho : Principal (· + ·) o) (hpos : 0 < o)
    (hA : ∀ k, (A k).value < o) (hcof : ∀ p < o, ∃ k, p < (A k).value) :
    (sigmaGame A).value = o :=
  le_antisymm (sigmaGame_value_le A ho hpos hA) (le_sigmaGame_value A hcof)

/-! ## The finite-refinement limit as an instance -/

theorem principal_add_omega_opow_omega : Principal (· + ·) (ω ^ ω : Ordinal.{0}) :=
  principal_add_omega0_opow ω

/-- Conjecture 4 rederived from the general limit theorem. -/
theorem sigmaGame_natClock_value : (sigmaGame natClock).value = ω ^ ω := by
  refine sigmaGame_value_eq natClock principal_add_omega_opow_omega
    (opow_pos _ omega0_pos) (fun k => ?_) (fun p hp => ?_)
  · rw [natClock_value]
    exact (opow_lt_opow_iff_right one_lt_omega0).2 (nat_lt_omega0 k)
  · obtain ⟨c, hc, hpc⟩ :=
      ((Ordinal.isNormal_opow one_lt_omega0).lt_iff_exists_lt isSuccLimit_omega0).1 hp
    obtain ⟨n, rfl⟩ := lt_omega0.1 hc
    exact ⟨n, by rwa [natClock_value]⟩

/-- The bespoke limit clock and the general lexicographic chain agree. -/
theorem limitGame_value_eq_sigmaGame : limitGame.value = (sigmaGame natClock).value := by
  rw [limitGame_value, sigmaGame_natClock_value]

end ImmortalitySigmaLimit