/-! # CatalogBuild.Speculative.RudyRucker.CantorsParadise

Auto-generated from theorem catalog database.
Domain: Speculative/RudyRucker
Declarations: 3
-/

import Mathlib

theorem nat_is_aleph_zero : Cardinal.mk ℕ = ℵ₀ :=
  Cardinal.mk_nat

/-- The power set of the naturals is strictly larger than the naturals.
This is the formal statement of the uncountability of the continuum,
which Rucker calls "Cantor's most stunning result." -/

theorem power_set_nat_gt_nat :
    Cardinal.mk ℕ < Cardinal.mk (Set ℕ) := by
  simp +zetaDelta at *
  exact Cardinal.aleph0_lt_continuum

/-- For any cardinal κ, we have κ < 2^κ.
The engine of Rucker's "endless tower of infinities." -/

theorem cardinal_lt_power (κ : Cardinal) : κ < 2 ^ κ :=
  Cardinal.cantor κ

/-! ## The Schröder–Bernstein Theorem

Rucker discusses how comparing infinite sets requires care. The
Schröder–Bernstein theorem tells us that if A injects into B and
B injects into A, then A and B have the same cardinality. -/

/-- Schröder–Bernstein: mutual injection implies bijection. -/
