/-! # CatalogBuild.Computation.Oracles.Experiments

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 17
-/

import Mathlib

noncomputable section

/-- Oracle that rounds down to the nearest even number. -/
def evenOracle' : ℕ → ℕ := fun n => 2 * (n / 2)


/-- The even oracle is idempotent. -/
theorem evenOracle'_idempotent (n : ℕ) :
    evenOracle' (evenOracle' n) = evenOracle' n := by
  unfold evenOracle'; omega


/-- The modular oracle is idempotent (for m > 0). -/
theorem modOracle'_idempotent (m : ℕ) (hm : 0 < m) (n : ℕ) :
    modOracle' m (modOracle' m n) = modOracle' m n := by
  simp [modOracle', Nat.mod_mod_of_dvd]

example : modOracle' 7 15 = 1 := by native_decide
example : modOracle' 7 3 = 3 := by native_decide

-- ═══════════════════════════════════════════════════════════════════════════════
-- EXPERIMENT 3: Boolean Logic Oracles
-- ═══════════════════════════════════════════════════════════════════════════════


/-- AND with true is idempotent. -/
theorem andTrue_idempotent' (x : Bool) :
    Bool.and (Bool.and x true) true = Bool.and x true := by
  cases x <;> rfl


/-- NOT is NOT an oracle (not idempotent). -/
theorem not_not_idempotent' : ¬∀ x : Bool, (!!x) = (!x) := by
  push_neg; exact ⟨true, by decide⟩

-- ═══════════════════════════════════════════════════════════════════════════════
-- EXPERIMENT 4: The Tropical Max Oracle
-- ═══════════════════════════════════════════════════════════════════════════════


/-- Tropical max with a threshold. -/
def tropicalOracle' (threshold : ℝ) : ℝ → ℝ := fun x => max threshold x


/-- The tropical oracle is idempotent. -/
theorem tropicalOracle'_idempotent (t : ℝ) (x : ℝ) :
    tropicalOracle' t (tropicalOracle' t x) = tropicalOracle' t x := by
  simp [tropicalOracle', max_assoc]


/-- Fixed points of the tropical oracle. -/
theorem tropicalOracle'_fixed_iff (t x : ℝ) :
    tropicalOracle' t x = x ↔ t ≤ x := by
  simp [tropicalOracle', max_eq_right_iff]

-- ═══════════════════════════════════════════════════════════════════════════════
-- EXPERIMENT 5: Convergence
-- ═══════════════════════════════════════════════════════════════════════════════


/-- For any n ≥ 1, f^n = f for idempotent f. -/
theorem convergence_is_immediate' {α : Type*} (f : α → α) (hf : ∀ x, f (f x) = f x)
    (n : ℕ) (hn : 0 < n) : f^[n] = f := by
  ext x
  induction n with
  | zero => omega
  | succ k ih =>
    simp [Function.iterate_succ_apply']
    cases k with
    | zero => simp
    | succ m => rw [ih (by omega)]; exact hf x

-- ═══════════════════════════════════════════════════════════════════════════════
-- EXPERIMENT 6: The Projection Oracle on ℝ²
-- ═══════════════════════════════════════════════════════════════════════════════


/-- Project onto the x-axis. -/
def projectX' : ℝ × ℝ → ℝ × ℝ := fun p => (p.1, 0)


/-- Projection onto x-axis is idempotent. -/
theorem projectX'_idempotent (p : ℝ × ℝ) :
    projectX' (projectX' p) = projectX' p := by
  simp [projectX']


/-- Fixed points are the x-axis. -/
theorem projectX'_fixed_iff (p : ℝ × ℝ) :
    projectX' p = p ↔ p.2 = 0 := by
  constructor
  · intro h
    have : (projectX' p).2 = p.2 := by rw [h]
    simp [projectX'] at this
    linarith
  · intro h
    ext <;> simp [projectX', h]

-- ═══════════════════════════════════════════════════════════════════════════════
-- EXPERIMENT 7: Tropical Geometry Laws
-- ═══════════════════════════════════════════════════════════════════════════════


/-- In tropical geometry, max(a, a) = a. -/
theorem tropical_idempotent' (a : ℝ) : max a a = a := max_self a


/-- Tropical addition is commutative. -/
theorem tropical_comm' (a b : ℝ) : max a b = max b a := max_comm a b


/-- Tropical addition is associative. -/
theorem tropical_assoc' (a b c : ℝ) : max (max a b) c = max a (max b c) :=
  max_assoc a b c


/-- Tropical multiplication distributes over tropical addition. -/
theorem tropical_distrib' (a b c : ℝ) :
    a + max b c = max (a + b) (a + c) := by
  simp [max_def]; split_ifs <;> linarith


/-- The tropical oracle converges in one step. -/
theorem tropical_one_step' (t x : ℝ) :
    max t (max t x) = max t x := by
  simp [max_assoc]

-- ═══════════════════════════════════════════════════════════════════════════════
-- SUMMARY
-- ═══════════════════════════════════════════════════════════════════════════════


end
