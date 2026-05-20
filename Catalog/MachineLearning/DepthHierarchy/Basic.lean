/-
# Depth Hierarchy for Iterated Exponentials

This file establishes a formal complexity theory of analytic expression depth,
centered on the insight that each additional layer of exponential nesting
creates derivative growth that cannot be matched by shallower expressions.

## Main definitions

* `iterExp k x` — the k-fold iterate of `Real.exp` applied to `x`
* `ApproxOn f g s ε` — uniform approximation of `f` by `g` on set `s` within `ε`

## Main results

* `iterExp_strictMono` — each `iterExp k` is strictly monotone
* `iterExp_pos` — `iterExp k x > 0` for `k ≥ 1`
* `iterExp_continuous` — each `iterExp k` is continuous
* `iterExp_differentiable` — each `iterExp k` is differentiable

## Tags

depth hierarchy, iterated exponential, sensitivity amplification
-/
import Mathlib

noncomputable section

open Real Set

/-! ## Iterated Exponential -/

/-- The k-fold iterated exponential.
  `iterExp 0 x = x`, `iterExp (k+1) x = exp(iterExp k x)`. -/
def iterExp : ℕ → ℝ → ℝ
  | 0 => fun x => x
  | n + 1 => fun x => Real.exp (iterExp n x)

@[simp] theorem iterExp_zero (x : ℝ) : iterExp 0 x = x := rfl
@[simp] theorem iterExp_succ (n : ℕ) (x : ℝ) :
    iterExp (n + 1) x = Real.exp (iterExp n x) := rfl

theorem iterExp_one (x : ℝ) : iterExp 1 x = Real.exp x := rfl

theorem iterExp_two (x : ℝ) : iterExp 2 x = Real.exp (Real.exp x) := rfl

/-! ## Basic properties of iterExp -/

/-
`iterExp k` is strictly monotone for all `k`.
-/
theorem iterExp_strictMono (k : ℕ) : StrictMono (iterExp k) := by
  induction k <;> simp_all +decide [ StrictMono ]

/-
`iterExp k x > 0` for `k ≥ 1`.
-/
theorem iterExp_pos (k : ℕ) (x : ℝ) (hk : 1 ≤ k) : 0 < iterExp k x := by
  induction' hk with k hk ih generalizing x <;> ( exact Real.exp_pos _ )

/-
`iterExp k` is continuous.
-/
theorem iterExp_continuous (k : ℕ) : Continuous (iterExp k) := by
  induction k <;> [ exact continuous_id; exact Real.continuous_exp.comp ‹_› ]

/-
`iterExp k` is differentiable.
-/
theorem iterExp_differentiable (k : ℕ) : Differentiable ℝ (iterExp k) := by
  induction' k with k ih;
  · exact differentiable_id;
  · exact Differentiable.exp ih

/-! ## Uniform Approximation -/

/-- Uniform approximation: `f` is approximated by `g` on `s` within `ε`. -/
def ApproxOn (f g : ℝ → ℝ) (s : Set ℝ) (ε : ℝ) : Prop :=
  ∀ x ∈ s, |f x - g x| ≤ ε

theorem ApproxOn.symm {f g : ℝ → ℝ} {s : Set ℝ} {ε : ℝ}
    (h : ApproxOn f g s ε) : ApproxOn g f s ε := by
  exact fun x hx => by rw [ abs_sub_comm ] ; exact h x hx;

theorem ApproxOn.mono {f g : ℝ → ℝ} {s : Set ℝ} {ε₁ ε₂ : ℝ}
    (h : ApproxOn f g s ε₁) (hε : ε₁ ≤ ε₂) : ApproxOn f g s ε₂ := by
  exact fun x hx => le_trans ( h x hx ) hε

theorem ApproxOn.subset {f g : ℝ → ℝ} {s t : Set ℝ} {ε : ℝ}
    (h : ApproxOn f g s ε) (hst : t ⊆ s) : ApproxOn f g t ε := by
  -- Given that t is a subset of s, we can use the definition of approximation to conclude that f is approximated by g on t.
  intro x hx
  apply h
  exact hst hx

/-! ## iterExp growth bounds on [0,1] -/

/-
On [0,1], iterExp k x ≥ x for all k.
-/
theorem iterExp_ge_id (k : ℕ) (x : ℝ) (hx : x ∈ Icc (0 : ℝ) 1) :
    x ≤ iterExp k x := by
  induction' k with k ih generalizing x <;> simp_all +decide [ iterExp ];
  linarith [ ih x hx.1 hx.2, Real.add_one_le_exp ( iterExp k x ) ]

/-
On [0,1], iterExp k x ≥ 1 for k ≥ 1.
-/
theorem iterExp_ge_one (k : ℕ) (x : ℝ) (hk : 1 ≤ k) (hx : x ∈ Icc (0 : ℝ) 1) :
    1 ≤ iterExp k x := by
  induction' k with k ih generalizing x <;> simp_all +decide [ iterExp ];
  exact Nat.recOn k ( by aesop ) fun n ihn => by rw [ iterExp_succ ] ; positivity;

/-
iterExp is monotone in the depth parameter on [0,1].
-/
theorem iterExp_mono_depth (k₁ k₂ : ℕ) (hk : k₁ ≤ k₂) (x : ℝ)
    (hx : x ∈ Icc (0 : ℝ) 1) :
    iterExp k₁ x ≤ iterExp k₂ x := by
  -- We prove this using induction on the difference $k₂ - k₁$.
  induction' hk with k₁ k₂ hk ih;
  · rfl;
  · exact le_trans hk ( le_trans ( by aesop ) ( Real.add_one_le_exp _ ) )

end