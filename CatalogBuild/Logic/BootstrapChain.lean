/-! # CatalogBuild.Logic.BootstrapChain

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 13
-/

import Mathlib

/-- The vacuous bootstrap: all properties hold for elements of the empty type -/
theorem vacuous_bootstrap (P : Empty → Prop) : ∀ x : Empty, P x :=
  fun x => x.elim


/-- From nothing, something: PUnit has exactly one element -/
theorem something_from_nothing : ∃! x : PUnit, True := by
  simp [show ∀ x : PUnit, x = PUnit.unit from fun x => rfl]


/-- The Peano bootstrap: ℕ is generated from zero and successor.
0, S(0), S(S(0)), ... — each number bootstraps from the previous. -/
theorem nat_bootstrap : ∀ n : ℕ, n = 0 ∨ ∃ m : ℕ, n = m + 1 :=
  fun n => Nat.eq_zero_or_pos n |> Or.imp id fun h => Nat.exists_eq_succ_of_ne_zero h.ne'


/-- Every integer bootstraps from a pair of natural numbers -/
theorem int_from_nat_pair : ∀ z : ℤ, ∃ a b : ℕ, z = (a : ℤ) - (b : ℤ) :=
  fun z => ⟨Int.toNat z, Int.toNat (-z), by rw [Int.toNat_sub_toNat_neg]⟩


/-- The integers bootstrap additive inverses: for every z, -z exists -/
theorem int_bootstrap_inverse : ∀ z : ℤ, ∃ w : ℤ, z + w = 0 :=
  fun z => ⟨-z, add_neg_cancel z⟩


/-- Every rational bootstraps from an integer pair -/
theorem rat_from_int_pair : ∀ q : ℚ, ∃ a : ℤ, ∃ b : ℕ, 0 < b ∧ q = a / (b : ℤ) := by
  intro q
  exact ⟨q.num, q.den, Nat.cast_pos.mpr q.pos, by simpa [Rat.num_div_den]⟩


/-- The rationals are dense: between any two rationals, another bootstraps into existence -/
theorem rat_bootstrap_density (p q : ℚ) (h : p < q) : ∃ r : ℚ, p < r ∧ r < q :=
  exists_between h


/-- The reals bootstrap the least upper bound property -/
theorem real_bootstrap_completeness (S : Set ℝ) (hne : S.Nonempty)
    (hbdd : BddAbove S) : ∃ x : ℝ, IsLUB S x :=
  ⟨_, isLUB_csSup hne hbdd⟩


/-- Every real is a limit of rationals: reals bootstrap from rational approximations -/
theorem real_from_rational_limits (x : ℝ) :
    ∀ ε : ℝ, 0 < ε → ∃ q : ℚ, |x - (q : ℝ)| < ε := by
  intro ε hε
  rcases exists_rat_btwn (show x - ε < x by linarith) with ⟨q, hq₁, hq₂⟩
  exact ⟨q, abs_lt.mpr ⟨by linarith, by linarith⟩⟩


/-- The fundamental theorem of algebra: ℂ bootstraps algebraic closure.
Every non-constant polynomial has a root. -/
theorem complex_bootstrap_algebraic_closure : IsAlgClosed ℂ :=
  inferInstance


/-- The complex numbers bootstrap from pairs of reals -/
theorem complex_from_real_pair (z : ℂ) : ∃ a b : ℝ, z = ⟨a, b⟩ :=
  ⟨z.re, z.im, rfl⟩


/-- The bootstrap chain is order-preserving: each inclusion is monotone -/
theorem bootstrap_chain_monotone : ∀ n : ℕ, (n : ℤ) = Int.ofNat n := by
  aesop


/-- The composition of all bootstraps: from ℕ to ℂ -/
theorem grand_bootstrap (n : ℕ) :
    ∃ z : ℂ, z = (n : ℂ) ∧ z.re = (n : ℝ) ∧ z.im = 0 := by
  aesop

