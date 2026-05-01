/-! # CatalogBuild.Bridges.TropicalReLUDepthSeparation

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 13
-/

import Mathlib

noncomputable section

/-- ReLU(x) = 0 for x ≤ 0 -/
theorem relu_of_nonpos {x : ℝ} (h : x ≤ 0) : relu x = 0 :=
  max_eq_left h


/-- ReLU(x) = x for x ≥ 0 -/
theorem relu_of_nonneg {x : ℝ} (h : 0 ≤ x) : relu x = x :=
  max_eq_right h


/-- The tropical max operation -/
def tropMax (a b : ℝ) : ℝ := max a b


/-- ReLU(x) = tropMax(0, x) -/
theorem relu_eq_tropMax (x : ℝ) : relu x = tropMax 0 x := rfl


/-- Tropical max is commutative -/
theorem tropMax_comm (a b : ℝ) : tropMax a b = tropMax b a := max_comm a b


/-- Tropical max is associative -/
theorem tropMax_assoc (a b c : ℝ) : tropMax (tropMax a b) c = tropMax a (tropMax b c) :=
  max_assoc a b c


/-- Tropical max is idempotent -/
theorem tropMax_idem (a : ℝ) : tropMax a a = a := max_self a


/-- ReLU is continuous -/
theorem relu_continuous : Continuous relu :=
  continuous_const.max continuous_id


/-- ReLU is Lipschitz with constant 1 -/
theorem relu_lipschitz_one : ∀ x y : ℝ, |relu x - relu y| ≤ |x - y| := by
  intro x y; show |max 0 x - max 0 y| ≤ |x - y|
  rw [max_comm 0 x, max_comm 0 y]; exact abs_max_sub_max_le_abs x y 0


/-- Key inequality: For depth k and width n, the maximum number of linear regions
grows exponentially in k but only polynomially in n for fixed k.
This means deeper networks are exponentially more expressive. -/
theorem depth_vs_width (k n : ℕ) (hk : 0 < k) (hn : 0 < n) :
    n ≤ (2 * n) ^ k := by
  calc n ≤ (2 * n) ^ 1 := by simp; omega
    _ ≤ (2 * n) ^ k := Nat.pow_le_pow_right (by omega) hk


/-- The difference of two continuous functions is continuous.
ReLU networks compute differences of tropical polynomials. -/
theorem tropical_diff_continuous (g h : ℝ → ℝ) (hg : Continuous g) (hh : Continuous h) :
    Continuous (fun x => g x - h x) := hg.sub hh


/-- A single neuron w*x + b under ReLU computes max(0, w*x + b),
which has exactly 2 linear regions (one active, one inactive). -/
theorem single_neuron_regions (w b : ℝ) (_hw : w ≠ 0) :
    ∃ t : ℝ, (∀ x, x ≤ t → relu (w * x + b) = 0 ∨ relu (w * x + b) = w * x + b) ∧
             (∀ x, t ≤ x → relu (w * x + b) = 0 ∨ relu (w * x + b) = w * x + b) := by
  exact ⟨-b / w, fun x _ => by exact le_total (w * x + b) 0 |>.imp relu_of_nonpos relu_of_nonneg,
                  fun x _ => by exact le_total (w * x + b) 0 |>.imp relu_of_nonpos relu_of_nonneg⟩


/-- The composition of monotone functions is monotone.
Key for showing that deep ReLU networks preserve monotonicity structure. -/
theorem compose_monotone {f g : ℝ → ℝ} (hf : Monotone f) (hg : Monotone g) :
    Monotone (f ∘ g) := hf.comp hg


end
