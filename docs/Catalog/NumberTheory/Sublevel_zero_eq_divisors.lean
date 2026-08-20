import Mathlib
import Catalog.Shared.CatalogbuildSharedE.E

/-! # CatalogBuild.Shared.Sublevel_zero_eq_divisors

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 3
-/

/-- Sublevel set: the set of x ∈ [1,N] with E(x) ≤ t. -/
def sublevel_set (N t : ℕ) : Finset ℕ :=
  (Finset.Icc 1 N).filter (fun x => E N x ≤ t)

/-- [Section: # CatalogBuild.Shared.Sublevel_zero_eq_divisors
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 3] -/
theorem sublevel_zero_eq_divisors (N : ℕ) (hN : 0 < N) :
    sublevel_set N 0 = N.divisors := by
  -- By definition of sublevel_set, we have:
  ext x
  simp [sublevel_set];
  exact ⟨ fun h => ⟨ Nat.dvd_of_mod_eq_zero h.2, hN.ne' ⟩, fun h => ⟨ ⟨ Nat.pos_of_dvd_of_pos h.1 hN, Nat.le_of_dvd hN h.1 ⟩, Nat.mod_eq_zero_of_dvd h.1 ⟩ ⟩

/-- [Section: # CatalogBuild.Shared.Sublevel_zero_eq_divisors
Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 3] -/
theorem sublevel_monotone (N t₁ t₂ : ℕ) (h : t₁ ≤ t₂) :
    sublevel_set N t₁ ⊆ sublevel_set N t₂ := by
  exact fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, le_trans ( Finset.mem_filter.mp hx |>.2 ) h ⟩