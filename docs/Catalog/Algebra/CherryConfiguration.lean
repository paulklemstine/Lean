import Mathlib

/-!
# Cherry configurations on cakes

We model `g` labelled cherries placed in `m` distinguishable admissible positions.  A valid
configuration has no collisions, hence is an embedding `Fin g ↪ Fin m`.  This gives an exact
finite probability model for the configuration-space part of pointed-cake moduli.  Separately,
we record the expected complex dimension `3g - 3 + n` of a genus-`g` surface carrying `n`
marked cherries.  The file does not claim to construct an algebraic moduli space.
-/

namespace CakeResearch

/-- Collision-free placements of `g` labelled cherries in `m` slots. -/
abbrev CherryConfiguration (g m : ℕ) := Fin g ↪ Fin m

/-
The exact number of collision-free cherry configurations is a falling factorial.
-/
theorem card_cherryConfiguration (g m : ℕ) :
    Fintype.card (CherryConfiguration g m) = m.descFactorial g := by
  norm_num

/-
If there are fewer slots than cherries, collision-free placement is impossible.
-/
theorem no_configuration_of_fewer_slots {g m : ℕ} (h : m < g) :
    IsEmpty (CherryConfiguration g m) := by
  exact ⟨ fun f => by have := Fintype.card_le_of_injective f f.injective; norm_num at *; linarith ⟩

/-
If enough slots exist, at least one collision-free placement exists.
-/
theorem configuration_exists_of_le {g m : ℕ} (h : g ≤ m) :
    Nonempty (CherryConfiguration g m) := by
  exact ⟨ ⟨ Fin.castLE h, Fin.castLE_injective h ⟩ ⟩

/-- The probability of no collision under uniform independent placement in `m` slots.
The `m = 0` convention is harmless: there are no assignments unless `g = 0`. -/
def collisionFreeProbability (g m : ℕ) : ℚ :=
  (m.descFactorial g : ℚ) / (m ^ g : ℚ)

/-
Collision-free probability is never greater than one.
-/
theorem collisionFreeProbability_le_one (g m : ℕ) :
    collisionFreeProbability g m ≤ 1 := by
  exact div_le_one_of_le₀ ( mod_cast Nat.descFactorial_le_pow _ _ ) ( by positivity )

/-
For a nonempty slot set, the collision-free probability vanishes exactly when there are
more cherries than slots.
-/
theorem collisionFreeProbability_eq_zero_iff {g m : ℕ} (hm : 0 < m) :
    collisionFreeProbability g m = 0 ↔ m < g := by
  unfold collisionFreeProbability; aesop;

/-
With at most one cherry, collisions are impossible.
-/
theorem collisionFreeProbability_one (g m : ℕ) (hg : g ≤ 1) (hm : 0 < m) :
    collisionFreeProbability g m = 1 := by
  interval_cases g <;> simp +decide [ *, collisionFreeProbability ]
  grind

/-
For a nonempty slot set, collisions are impossible with probability one exactly when
there is at most one cherry.
-/
theorem collisionFreeProbability_eq_one_iff {g m : ℕ} (hm : 0 < m) :
    collisionFreeProbability g m = 1 ↔ g ≤ 1 := by
  refine' ⟨ fun h => _, fun h => _ ⟩;
  · contrapose! h;
    refine' ne_of_lt ( div_lt_one _ |>.2 _ );
    · positivity;
    · induction h <;> simp_all +decide [ Nat.descFactorial_succ, pow_succ' ];
      exact mul_lt_mul'' ( mod_cast Nat.sub_lt hm ( by linarith ) ) ‹_› ( by positivity ) ( by positivity );
  · interval_cases g <;> unfold collisionFreeProbability <;> aesop

/-- Expected complex dimension of the moduli of genus `g` cakes with `n` marked cherries. -/
def expectedModuliDimension (g n : ℤ) : ℤ := 3 * g - 3 + n

/-
Each additional cherry contributes one marked-point parameter.
-/
theorem dimension_add_cherry (g n : ℤ) :
    expectedModuliDimension g (n + 1) = expectedModuliDimension g n + 1 := by
  unfold expectedModuliDimension; ring;

/-
Each additional handle contributes three complex parameters.
-/
theorem dimension_add_handle (g n : ℤ) :
    expectedModuliDimension (g + 1) n = expectedModuliDimension g n + 3 := by
  unfold expectedModuliDimension; ring;

/-
In the proposed unmarked model, the dimensions for genus two through five are
`3, 6, 9, 12`.
-/
theorem genus_two_through_five_dimensions :
    expectedModuliDimension 2 0 = 3 ∧
    expectedModuliDimension 3 0 = 6 ∧
    expectedModuliDimension 4 0 = 9 ∧
    expectedModuliDimension 5 0 = 12 := by
  norm_num [expectedModuliDimension]

/-- Exact small-case probability evidence for up to five cherries in ten slots. -/
theorem ten_slot_probability_table :
    collisionFreeProbability 0 10 = 1 ∧
    collisionFreeProbability 1 10 = 1 ∧
    collisionFreeProbability 2 10 = 9 / 10 ∧
    collisionFreeProbability 3 10 = 18 / 25 ∧
    collisionFreeProbability 4 10 = 63 / 125 ∧
    collisionFreeProbability 5 10 = 189 / 625 := by
  norm_num [collisionFreeProbability, Nat.descFactorial]

/-
**Finite cherry-configuration theorem.**  For `g ≤ m`, collision-free configurations
exist, their exact number is `m(m-1)…(m-g+1)`, and their uniform probability is at most one.
This is the fully formal finite-probability result underlying the cherry-position model.
-/
theorem fundamental_cherry_configuration_theorem {g m : ℕ} (h : g ≤ m) :
    Nonempty (CherryConfiguration g m) ∧
    Fintype.card (CherryConfiguration g m) = m.descFactorial g ∧
    collisionFreeProbability g m ≤ 1 := by
  exact ⟨ configuration_exists_of_le h, card_cherryConfiguration g m, collisionFreeProbability_le_one g m ⟩

end CakeResearch