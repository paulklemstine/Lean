import Mathlib

/-!
# Tropical Certified Robustness for Multiclass Residual Networks

This file develops a formal robustness theory for multiclass residual
piecewise-linear (tropical) networks in the L∞ metric. The central result is
that the predicted class is stable on an L∞ ball whose radius is controlled by
the global one-vs-all logit gap divided by twice the network's Lipschitz constant.

## Mathematical overview

For a network `f : (Fin d → ℝ) → Fin C → ℝ` that is `K`-Lipschitz coordinatewise
in the L∞ metric, and a point `x` where class `y` is the argmax with gap
`γ = min_{j ≠ y} (f(x)(y) - f(x)(j))`, the classification is stable for all
perturbations of L∞-radius `r < γ / (2K)`.

The key algebraic ingredient specific to residual networks is the skip-connection
Lipschitz bound: if `g` is `Kg`-Lipschitz, then `x ↦ x + g(x)` is `(1 + Kg)`-Lipschitz.
Composing `n` such blocks gives Lipschitz constant `∏ᵢ (1 + Kᵢ)`.

## Main definitions

* `LinfDist` — L∞ distance between finite-dimensional real vectors
* `LogitLipschitz` — coordinatewise Lipschitz condition
* `IsArgmaxAt` — class `y` achieves maximum logit at `x`
* `Margin` — pairwise logit margin `f(x)(y) - f(x)(j)`
* `GapAtFinset` — minimum margin over all competitors
* `ArgmaxStableOnBall` — argmax invariance on an L∞ ball

## Main results

* `residual_block_lipschitz` — skip-connection Lipschitz bound
* `margin_lipschitz` — margins are `2K`-Lipschitz
* `gap_le_margin` — the gap lower-bounds every individual margin
* `certified_radius_lower_bound` — `r < γ/(2K) → ArgmaxStableOnBall`
* `local_certified_radius_lower_bound` — local version with restricted Lipschitz
* `residual_network_lipschitz_two_blocks` — composition of two residual blocks
-/

noncomputable section

open Finset

/-! ## Core Definitions -/

/-- The L∞ distance between two vectors in `Fin d → ℝ`.
Returns `0` when `d = 0` (trivial input space). -/
def LinfDist {d : ℕ} (x y : Fin d → ℝ) : ℝ :=
  if h : 0 < d then
    Finset.sup' Finset.univ
      (Finset.univ_nonempty_iff.mpr ⟨⟨0, h⟩⟩) (fun i => |x i - y i|)
  else 0

/-- Coordinatewise Lipschitz condition for a map `f : (Fin d → ℝ) → Fin C → ℝ`. -/
def LogitLipschitz {d C : ℕ} (K : ℝ) (f : (Fin d → ℝ) → Fin C → ℝ) : Prop :=
  0 ≤ K ∧ ∀ i x y, |f x i - f y i| ≤ K * LinfDist x y

/-- Class `y` achieves maximum logit at input `x`. -/
def IsArgmaxAt {d C : ℕ} (f : (Fin d → ℝ) → Fin C → ℝ)
    (x : Fin d → ℝ) (y : Fin C) : Prop :=
  ∀ j, f x j ≤ f x y

/-- Pairwise margin: `f(x)(y) - f(x)(j)`. -/
def Margin {d C : ℕ} (f : (Fin d → ℝ) → Fin C → ℝ)
    (y j : Fin C) (x : Fin d → ℝ) : ℝ :=
  f x y - f x j

/-- The minimum margin (gap) over all competitors `j ≠ y`.
Uses `Finset.inf'` on the nonempty set `univ.erase y` (requires `C ≥ 2`). -/
def GapAtFinset {d C : ℕ} [Fact (2 ≤ C)]
    (f : (Fin d → ℝ) → Fin C → ℝ) (x : Fin d → ℝ) (y : Fin C) : ℝ :=
  Finset.inf' (Finset.univ.erase y)
    (by
      have hC : 2 ≤ C := Fact.out
      obtain ⟨j, hj⟩ : ∃ j : Fin C, j ≠ y := by
        by_contra h; push_neg at h
        have : Fintype.card (Fin C) ≤ 1 := Fintype.card_le_one_iff.mpr
          (fun a b => (h a).trans (h b).symm)
        simp at this; omega
      exact ⟨j, Finset.mem_erase.mpr ⟨hj, Finset.mem_univ _⟩⟩)
    (fun j => Margin f y j x)

/-- Classification is stable on the L∞ ball of radius `r` around `x`. -/
def ArgmaxStableOnBall {d C : ℕ}
    (f : (Fin d → ℝ) → Fin C → ℝ) (x : Fin d → ℝ)
    (y : Fin C) (r : ℝ) : Prop :=
  ∀ x', LinfDist x x' ≤ r → ∀ j, f x' j ≤ f x' y

/-! ## Basic L∞ Distance Properties -/

theorem LinfDist_nonneg {d : ℕ} (x y : Fin d → ℝ) : 0 ≤ LinfDist x y := by
  unfold LinfDist;
  split_ifs <;> [ exact le_trans ( by norm_num ) ( Finset.le_sup' _ ( Finset.mem_univ ⟨ 0, by linarith ⟩ ) ) ; norm_num ]

theorem abs_sub_le_LinfDist {d : ℕ} (x y : Fin d → ℝ) (i : Fin d) :
    |x i - y i| ≤ LinfDist x y := by
  unfold LinfDist;
  split_ifs <;> simp_all +decide;
  · use i;
  · exact absurd ‹_› ( Nat.ne_of_gt ( Fin.pos i ) )

theorem LinfDist_self {d : ℕ} (x : Fin d → ℝ) : LinfDist x x = 0 := by
  -- The supremum of a set of zeros is zero.
  simp [LinfDist]

/-! ## Section 1: Residual Block Lipschitz Calculus -/

/-
A residual block `x ↦ x + g(x)` is `(1 + Kg)`-Lipschitz coordinatewise
when `g` is `Kg`-Lipschitz coordinatewise.

**Proof sketch**: For each coordinate `i`,
`|(x_i + g(x)_i) - (y_i + g(y)_i)| ≤ |x_i - y_i| + |g(x)_i - g(y)_i|`
`≤ LinfDist(x,y) + Kg · LinfDist(x,y) = (1 + Kg) · LinfDist(x,y)`.
-/
theorem residual_block_lipschitz
    {d : ℕ} {g : (Fin d → ℝ) → Fin d → ℝ} {Kg : ℝ}
    (_hKg : 0 ≤ Kg)
    (hg : ∀ x y i, |g x i - g y i| ≤ Kg * LinfDist x y) :
    ∀ x y i,
      |(x i + g x i) - (y i + g y i)| ≤ (1 + Kg) * LinfDist x y := by
  intros x y i
  have h_triangle : |x i + g x i - (y i + g y i)| ≤ |x i - y i| + |g x i - g y i| := by
    cases abs_cases ( x i + g x i - ( y i + g y i ) ) <;> cases abs_cases ( x i - y i ) <;> cases abs_cases ( g x i - g y i ) <;> linarith
  have h_abs_sub : |x i - y i| ≤ LinfDist x y :=
    abs_sub_le_LinfDist x y i
  have h_abs_g : |g x i - g y i| ≤ Kg * LinfDist x y := by
    exact hg x y i
  linarith [h_triangle, h_abs_sub, h_abs_g]

/-
Composition of two coordinatewise-Lipschitz maps: if `f₁` is `K₁`-Lipschitz
and `f₂` is `K₂`-Lipschitz (both coordinatewise in L∞), then `f₂ ∘ f₁` is
`(K₂ * K₁)`-Lipschitz.
-/
theorem comp_coordinate_lipschitz
    {d₁ d₂ d₃ : ℕ} {K₁ K₂ : ℝ}
    {f₁ : (Fin d₁ → ℝ) → Fin d₂ → ℝ}
    {f₂ : (Fin d₂ → ℝ) → Fin d₃ → ℝ}
    (hK₁ : 0 ≤ K₁) (hK₂ : 0 ≤ K₂)
    (hf₁ : ∀ x y i, |f₁ x i - f₁ y i| ≤ K₁ * LinfDist x y)
    (hf₂ : ∀ u v i, |f₂ u i - f₂ v i| ≤ K₂ * LinfDist u v) :
    ∀ x y i, |f₂ (f₁ x) i - f₂ (f₁ y) i| ≤ (K₂ * K₁) * LinfDist x y := by
  intro x y i;
  refine' le_trans ( hf₂ _ _ _ ) _;
  rw [ mul_assoc ];
  unfold LinfDist;
  split_ifs <;> norm_num;
  · gcongr;
    unfold LinfDist at hf₁; aesop;
  · simp_all +decide [ show x = y by ext i; linarith [ Fin.is_lt i ] ];
  · exact mul_nonneg hK₂ ( mul_nonneg hK₁ ( by exact le_trans ( by norm_num ) ( Finset.le_sup' ( fun i => |x i - y i| ) ( Finset.mem_univ ⟨ 0, by linarith ⟩ ) ) ) )

/-
Two sequential residual blocks `x ↦ x + g₁(x)` then `x ↦ x + g₂(x)` give
a composite with Lipschitz constant `(1 + K₁) * (1 + K₂)`.
-/
theorem residual_network_lipschitz_two_blocks
    {d : ℕ} {g₁ g₂ : (Fin d → ℝ) → Fin d → ℝ} {K₁ K₂ : ℝ}
    (hK₁ : 0 ≤ K₁) (hK₂ : 0 ≤ K₂)
    (hg₁ : ∀ x y i, |g₁ x i - g₁ y i| ≤ K₁ * LinfDist x y)
    (hg₂ : ∀ x y i, |g₂ x i - g₂ y i| ≤ K₂ * LinfDist x y) :
    let T₁ := fun x i => x i + g₁ x i
    let T₂ := fun x i => x i + g₂ x i
    ∀ x y i, |T₂ (T₁ x) i - T₂ (T₁ y) i| ≤ ((1 + K₂) * (1 + K₁)) * LinfDist x y := by
  -- Apply the residual_block_lipschitz theorem to the first residual block.
  have hT₁_lipschitz : ∀ x y i, |(x i + g₁ x i) - (y i + g₁ y i)| ≤ (1 + K₁) * LinfDist x y :=
    residual_block_lipschitz hK₁ hg₁
  have hT₂_lipschitz : ∀ x y i, |(x i + g₂ x i) - (y i + g₂ y i)| ≤ (1 + K₂) * LinfDist x y :=
    residual_block_lipschitz hK₂ hg₂
  convert comp_coordinate_lipschitz ( show 0 ≤ 1 + K₁ by linarith ) ( show 0 ≤ 1 + K₂ by linarith ) hT₁_lipschitz hT₂_lipschitz using 1

/-! ## Section 2: Pairwise Margin Lipschitz Bounds -/

/-
The pairwise margin `Margin f y j` is `2K`-Lipschitz: the absolute change
in margin is at most `2K · LinfDist(x, x')`.

**Proof**: `|Margin f y j x - Margin f y j x'|`
`= |(f(x)(y) - f(x)(j)) - (f(x')(y) - f(x')(j))|`
`≤ |f(x)(y) - f(x')(y)| + |f(x)(j) - f(x')(j)|`
`≤ K · d∞(x,x') + K · d∞(x,x') = 2K · d∞(x,x')`.
-/
theorem margin_lipschitz
    {d C : ℕ} {f : (Fin d → ℝ) → Fin C → ℝ} {K : ℝ}
    (_hK : 0 ≤ K)
    (hf : ∀ i x y, |f x i - f y i| ≤ K * LinfDist x y) :
    ∀ y j x x',
      |Margin f y j x - Margin f y j x'| ≤ (2 * K) * LinfDist x x' := by
  intro y j x x';
  unfold Margin;
  exact abs_le.mpr ⟨ by linarith [ abs_le.mp ( hf y x x' ), abs_le.mp ( hf j x x' ) ], by linarith [ abs_le.mp ( hf y x x' ), abs_le.mp ( hf j x x' ) ] ⟩

/-
One-sided margin bound: the margin at a perturbed point is at least
the margin at the original point minus `2K · d∞(x, x')`.
-/
theorem margin_lower_bound_under_perturbation
    {d C : ℕ} {f : (Fin d → ℝ) → Fin C → ℝ} {K : ℝ}
    (_hK : 0 ≤ K)
    (hf : ∀ i x y, |f x i - f y i| ≤ K * LinfDist x y) :
    ∀ y j x x',
      Margin f y j x' ≥ Margin f y j x - (2 * K) * LinfDist x x' := by
  exact fun y j x x' => by linarith [ abs_le.mp ( margin_lipschitz _hK hf y j x x' ) ] ;

/-! ## Section 3: Gap and Stability -/

/-
The gap lower-bounds every individual margin for `j ≠ y`.
-/
theorem gap_le_margin {d C : ℕ} [Fact (2 ≤ C)]
    (f : (Fin d → ℝ) → Fin C → ℝ) (x : Fin d → ℝ) (y : Fin C)
    (j : Fin C) (hj : j ≠ y) :
    GapAtFinset f x y ≤ Margin f y j x := by
  -- By definition of infimum, for any element j in the set (univ.erase y), the infimum is less than or equal to j.
  apply Finset.inf'_le; simp [hj]

/-
If `y` is argmax at `x`, then the gap is nonneg.
-/
theorem gap_nonneg_of_argmax {d C : ℕ} [Fact (2 ≤ C)]
    (f : (Fin d → ℝ) → Fin C → ℝ) (x : Fin d → ℝ) (y : Fin C)
    (hy : IsArgmaxAt f x y) :
    0 ≤ GapAtFinset f x y := by
  exact Finset.le_inf' _ _ fun j hj => sub_nonneg_of_le <| hy j

/-
**Argmax stability from pairwise margin bounds**: if every competitor margin
at `x` exceeds `2K · r`, then classification is stable on the L∞ ball of radius `r`.
-/
theorem argmax_stable_of_pairwise_margin_bound
    {d C : ℕ}
    {f : (Fin d → ℝ) → Fin C → ℝ} {K r : ℝ}
    {x : Fin d → ℝ} {y : Fin C}
    (_hK : 0 ≤ K)
    (hf : ∀ i x x', |f x i - f x' i| ≤ K * LinfDist x x')
    (hmargin : ∀ j, j ≠ y → 2 * K * r < Margin f y j x) :
    ArgmaxStableOnBall f x y r := by
  intro x' hx' j;
  by_cases hj : j = y;
  · rw [ hj ];
  · have := margin_lower_bound_under_perturbation _hK hf y j x x';
    unfold Margin at *; nlinarith [ hmargin j hj ] ;

/-! ## Section 4: Main Certified Radius Theorems -/

/-
**The certified radius theorem**: if `f` is `K`-Lipschitz, `y` is argmax at `x`,
and `r < gap / (2K)`, then classification is stable on the L∞ ball of radius `r`.

This is the formal version of the certificate `r*(x) ≥ γ(x) / (2K)`.
-/
theorem certified_radius_lower_bound
    {d C : ℕ} [Fact (2 ≤ C)]
    {f : (Fin d → ℝ) → Fin C → ℝ} {K : ℝ}
    {x : Fin d → ℝ} {y : Fin C}
    (hK : 0 < K)
    (hf : ∀ i x x', |f x i - f x' i| ≤ K * LinfDist x x')
    (_hy : IsArgmaxAt f x y)
    (_hgap : 0 < GapAtFinset f x y) :
    ∀ r, r < GapAtFinset f x y / (2 * K) → ArgmaxStableOnBall f x y r := by
  intro r hr;
  apply argmax_stable_of_pairwise_margin_bound;
  exact le_of_lt hK;
  · assumption;
  · exact fun j hj => by rw [ lt_div_iff₀ ( by positivity ) ] at hr; nlinarith [ gap_le_margin f x y j hj ] ;

/-- Specialization to residual networks: certified radius using the residual
Lipschitz constant. -/
theorem residual_multiclass_certified_radius
    {d C : ℕ} [Fact (2 ≤ C)]
    {f : (Fin d → ℝ) → Fin C → ℝ}
    {Kres : ℝ} {x : Fin d → ℝ} {y : Fin C}
    (hKres : 0 < Kres)
    (hf : ∀ i x x', |f x i - f x' i| ≤ Kres * LinfDist x x')
    (hy : IsArgmaxAt f x y)
    (hgap : 0 < GapAtFinset f x y) :
    ∀ r, r < GapAtFinset f x y / (2 * Kres) → ArgmaxStableOnBall f x y r :=
  certified_radius_lower_bound hKres hf hy hgap

/-! ## Section 5: Local Certified Radius -/

/-
**Local certified radius**: if `f` is only `Kloc`-Lipschitz on a ball of radius `ρ`,
then classification is stable for `r < min(ρ, gap/(2·Kloc))`.
-/
theorem local_certified_radius_lower_bound
    {d C : ℕ} [Fact (2 ≤ C)]
    {f : (Fin d → ℝ) → Fin C → ℝ} {Kloc : ℝ}
    {x : Fin d → ℝ} {y : Fin C} {ρ : ℝ}
    (hKloc : 0 < Kloc)
    (hlocal : ∀ i x', LinfDist x x' ≤ ρ →
      |f x i - f x' i| ≤ Kloc * LinfDist x x')
    (hy : IsArgmaxAt f x y)
    (_hgap : 0 < GapAtFinset f x y)
    (_hρ : 0 < ρ) :
    ∀ r, r < min ρ (GapAtFinset f x y / (2 * Kloc)) →
      ArgmaxStableOnBall f x y r := by
  intro r hr
  have hr' : r < ρ := lt_of_lt_of_le hr (min_le_left _ _)
  have hr'' : r < GapAtFinset f x y / (2 * Kloc) := lt_of_lt_of_le hr (min_le_right _ _)
  have hIsArgmax := hy  -- explicitly bind to suppress linter
  intro x' hx' i
  by_cases h_eq : i = y;
  · rw [h_eq]
  · have := hlocal i x' (le_trans hx' hr'.le)
    have := hlocal y x' (le_trans hx' hr'.le)
    rw [lt_div_iff₀] at hr'' <;> nlinarith [
      abs_le.mp ‹|f x i - f x' i| ≤ Kloc * LinfDist x x'›,
      abs_le.mp ‹|f x y - f x' y| ≤ Kloc * LinfDist x x'›,
      hIsArgmax i, hIsArgmax y,
      show GapAtFinset f x y ≤ f x y - f x i from gap_le_margin f x y i h_eq]

end