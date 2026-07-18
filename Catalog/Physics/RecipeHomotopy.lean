import Mathlib

/-!
# A finite substitution model for recipe spaces

A recipe with `n` independent binary ingredient choices is represented by a vector over
`ZMod 2`.  A method is another such vector: its nonzero coordinates are precisely the
substitutions performed an odd number of times.  This gives a finite cubical model in
which independent substitutions commute.
-/

namespace RecipeHomotopy

/-- Recipes with `n` independent binary ingredient choices. -/
abbrev Recipe (n : ℕ) := Fin n → ZMod 2

/-- A normalized transformation method records the parity of every substitution. -/
abbrev Method (n : ℕ) := Fin n → ZMod 2

/-- Apply a normalized substitution method to a recipe. -/
def transform {n : ℕ} (p : Method n) (r : Recipe n) : Recipe n := r + p

/-- The elementary method which toggles ingredient choice `i`. -/
def toggle {n : ℕ} (i : Fin n) : Method n := Pi.single i 1

/--
Normalized methods act freely and transitively on recipes: between two recipes
there is exactly one parity-normalized substitution method.
-/
theorem unique_normalized_method {n : ℕ} (r s : Recipe n) :
    ∃! p : Method n, transform p r = s := by
  refine' ⟨ s - r, _, _ ⟩ <;> simp_all +decide [ transform ];
  exact fun y hy => eq_sub_of_add_eq' hy

/--
A normalized method is a loop at a recipe exactly when every substitution occurs
an even number of times.  Thus the binary-choice model has no nontrivial normalized
loops, contrary to what would be required for a fundamental group such as `ℤ`.
-/
theorem transform_eq_self_iff {n : ℕ} (p : Method n) (r : Recipe n) :
    transform p r = r ↔ p = 0 := by
  unfold transform; aesop;

/--
Independent ingredient substitutions form a commuting square.  These squares are
the two-dimensional cells of the Boolean cubical recipe complex.
-/
theorem toggle_square {n : ℕ} (r : Recipe n) (i j : Fin n) :
    transform (toggle j) (transform (toggle i) r) =
      transform (toggle i) (transform (toggle j) r) := by
  simp +decide only [transform] ; ring

/--
If two ingredient choices are distinct, toggling them gives four distinct vertices
of a genuine square in the recipe cube.
-/
theorem toggle_square_vertices_distinct {n : ℕ} (r : Recipe n) (i j : Fin n)
    (hij : i ≠ j) :
    let ri := transform (toggle i) r
    let rj := transform (toggle j) r
    let rij := transform (toggle j) ri
    r ≠ ri ∧ r ≠ rj ∧ r ≠ rij ∧ ri ≠ rj ∧ ri ≠ rij ∧ rj ≠ rij := by
  refine' ⟨ _, _, _, _, _, _ ⟩ <;> intro h <;> simp_all +decide [funext_iff];
  all_goals have := h i; have := h j; simp +decide [ transform, toggle ] at *;; all_goals grind +qlia

/--
There are exactly `2^n` recipes with `n` independent binary choices.
-/
theorem card_recipe (n : ℕ) : Fintype.card (Recipe n) = 2 ^ n := by
  norm_num

/--
The nuts/no-nuts fiber has two recipes.  If transformations are restricted to
identity methods, its reachability relation is equality, so its two points lie in
separate components—the finite combinatorial analogue of `S⁰`.
-/
theorem nuts_no_nuts_two_components :
    Fintype.card (Recipe 1) = 2 ∧
      ∀ r s : Recipe 1, transform (0 : Method 1) r = s ↔ r = s := by
  constructor
  · norm_num [card_recipe]
  · intro r s
    simp [transform]

end RecipeHomotopy