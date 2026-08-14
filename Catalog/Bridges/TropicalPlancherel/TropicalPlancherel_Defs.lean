import Mathlib

/-!
# Tropical Plancherel — definitions

This file replaces a placeholder that contained only a stale file path and did not
compile.  It sets up the minimal max-plus harmonic analysis on the cyclic group
`ZMod m` needed to state a tropical Plancherel identity:

* `TropicalPlancherel.tropConv` — max-plus (tropical) convolution
  `(f ⋆ g)(n) = max_x (f x + g (n - x))`;
* `TropicalPlancherel.tropSup` — the tropical total mass `max_x f x`, the max-plus
  analogue of the `L¹` norm (a sum in the ordinary semiring, a max here).

The Plancherel-type theorem `tropSup (f ⋆ g) = tropSup f + tropSup g` is proved in
`TropicalPlancherel_Theorems.lean`.
-/

noncomputable section

namespace TropicalPlancherel

variable {m : ℕ} [NeZero m]

/-- **Tropical convolution** on `ZMod m`: `(f ⋆ g)(n) = max_x (f x + g (n - x))`. -/
def tropConv (f g : ZMod m → ℝ) (n : ZMod m) : ℝ :=
  (Finset.univ : Finset (ZMod m)).sup' Finset.univ_nonempty (fun x => f x + g (n - x))

/-- **Tropical mass**: the max-plus analogue of the total mass of `f`. -/
def tropSup (f : ZMod m → ℝ) : ℝ :=
  (Finset.univ : Finset (ZMod m)).sup' Finset.univ_nonempty f

/-- Every value is below the tropical mass. -/
theorem le_tropSup (f : ZMod m → ℝ) (x : ZMod m) : f x ≤ tropSup f :=
  Finset.le_sup' f (Finset.mem_univ x)

/-- Universal property of the tropical mass. -/
theorem tropSup_le {f : ZMod m → ℝ} {c : ℝ} (h : ∀ x, f x ≤ c) : tropSup f ≤ c :=
  Finset.sup'_le _ f (fun x _ => h x)

/-- Every term of the convolution is below the convolution. -/
theorem le_tropConv (f g : ZMod m → ℝ) (n x : ZMod m) :
    f x + g (n - x) ≤ tropConv f g n :=
  Finset.le_sup' (fun y => f y + g (n - y)) (Finset.mem_univ x)

/-- Universal property of the tropical convolution. -/
theorem tropConv_le {f g : ZMod m → ℝ} {n : ZMod m} {c : ℝ}
    (h : ∀ x, f x + g (n - x) ≤ c) : tropConv f g n ≤ c :=
  Finset.sup'_le _ _ (fun x _ => h x)

/-- The tropical mass is attained: the max-plus semiring has no approximation issues on
a finite group. -/
theorem exists_tropSup_eq (f : ZMod m → ℝ) : ∃ x, f x = tropSup f := by
  obtain ⟨x, _, hx⟩ := Finset.exists_mem_eq_sup' (Finset.univ_nonempty (α := ZMod m)) f
  exact ⟨x, hx.symm⟩

end TropicalPlancherel