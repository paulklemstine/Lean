import Speculative.DepthSeparation.Derivative
import Mathlib

/-!
# Depth Separation: Lipschitz Obstruction for Shallow Approximation

This file proves that functions with bounded derivative cannot uniformly
approximate iterated exponentials on `[0,1]`. This is the core separation theorem:
any approximant with derivative bounded by `L` must incur error at least
`(iterExp k 1 - iterExp k 0 - L) / 2` when approximating `iterExp k`.

## Main results

* `iterExp_endpoint_gap` — `iterExp (k+1) 1 - iterExp (k+1) 0 ≥ Real.exp 1 - 1`
* `not_uniformApprox_of_small_lipschitz` — the Lipschitz obstruction theorem
* `iterExp_endpoint_gap_grows` — endpoint gap grows with `k`

## Cross-domain interpretation

This result is an analytic analogue of circuit-depth lower bounds in complexity theory:
just as AC⁰ circuits cannot compute parity without exponential size, Lipschitz-bounded
"shallow" functions cannot approximate exponential towers without large error. The
derivative product formula plays the role of a "switching lemma" — it certifies that
the analytical complexity of towers exceeds any bounded-slope budget.
-/

noncomputable section

open Real Set

/-
The variation (endpoint gap) of `iterExp (k+1)` on `[0,1]` is at least `e - 1 > 0`.
-/
theorem iterExp_endpoint_gap (k : ℕ) :
    Real.exp 1 - 1 ≤ iterExp (k + 1) 1 - iterExp (k + 1) 0 := by
  induction' k with k ih <;> norm_num [ iterExp ] at *;
  -- Apply the mean value theorem to the interval $[e^{iterExp k 0}, e^{iterExp k 1}]$.
  obtain ⟨c, hc⟩ : ∃ c ∈ Set.Ioo (Real.exp (iterExp k 0)) (Real.exp (iterExp k 1)), deriv Real.exp c = (Real.exp (Real.exp (iterExp k 1)) - Real.exp (Real.exp (iterExp k 0))) / (Real.exp (iterExp k 1) - Real.exp (iterExp k 0)) := by
    apply_rules [ exists_deriv_eq_slope ];
    · linarith [ Real.add_one_le_exp 1 ];
    · exact Real.continuousOn_exp;
    · exact Differentiable.differentiableOn Real.differentiable_exp;
  norm_num at *;
  nlinarith [ Real.add_one_le_exp 1, Real.add_one_le_exp c, Real.exp_pos ( iterExp k 0 ), Real.exp_pos ( iterExp k 1 ), mul_div_cancel₀ ( Real.exp ( Real.exp ( iterExp k 1 ) ) - Real.exp ( Real.exp ( iterExp k 0 ) ) ) ( sub_ne_zero_of_ne <| by linarith : ( Real.exp ( iterExp k 1 ) - Real.exp ( iterExp k 0 ) ) ≠ 0 ) ]

/-
**Lipschitz obstruction theorem.** If a differentiable function `g` has derivative
bounded by `L` on `[0,1]`, and `L` is too small relative to the variation of
`iterExp k` on `[0,1]`, then `g` cannot uniformly approximate `iterExp k` within `ε`.

Concretely: if `L + 2ε < iterExp k 1 - iterExp k 0`, then no `ε`-approximation exists.
This is the key depth-separation result.
-/
theorem not_uniformApprox_of_small_lipschitz
    (k : ℕ) (g : ℝ → ℝ) (L ε : ℝ)
    (hg_diff : DifferentiableOn ℝ g (Icc (0 : ℝ) 1))
    (hg_deriv : ∀ x ∈ Icc (0 : ℝ) 1, ‖deriv g x‖ ≤ L)
    (hL : L + 2 * ε < iterExp k 1 - iterExp k 0) :
    ¬ uniformApproxOn (iterExp k) g (Icc (0 : ℝ) 1) ε := by
  contrapose! hL;
  -- By the mean value theorem, there exists some $c \in (0,1)$ such that $g(1) - g(0) = deriv g c$.
  obtain ⟨c, hc⟩ : ∃ c ∈ Set.Ioo 0 1, g 1 - g 0 = deriv g c := by
    have := exists_deriv_eq_slope g zero_lt_one;
    exact this ( hg_diff.continuousOn ) ( hg_diff.mono ( Set.Ioo_subset_Icc_self ) ) |> fun ⟨ c, hc₁, hc₂ ⟩ => ⟨ c, hc₁, by norm_num [ hc₂ ] ⟩;
  linarith [ abs_le.mp ( hL 0 ( by norm_num ) ), abs_le.mp ( hL 1 ( by norm_num ) ), abs_le.mp ( hg_deriv c ⟨ hc.1.1.le, hc.1.2.le ⟩ ) ]

/-
The endpoint gap of `iterExp` grows monotonically with `k` for `k ≥ 1`.
-/
theorem iterExp_endpoint_gap_grows (k : ℕ) :
    iterExp (k + 1) 1 - iterExp (k + 1) 0 ≤
    iterExp (k + 2) 1 - iterExp (k + 2) 0 := by
  -- Apply the mean value theorem to the interval [iterExp (k + 1) 0, iterExp (k + 1) 1].
  obtain ⟨c, hc⟩ : ∃ c ∈ Set.Ioo (iterExp (k + 1) 0) (iterExp (k + 1) 1), deriv Real.exp c = (Real.exp (iterExp (k + 1) 1) - Real.exp (iterExp (k + 1) 0)) / (iterExp (k + 1) 1 - iterExp (k + 1) 0) := by
    apply_rules [ exists_deriv_eq_slope ];
    · exact Real.exp_lt_exp.mpr ( show iterExp k 0 < iterExp k 1 from by exact Nat.recOn k ( by norm_num ) fun n ihn => by rw [ iterExp_succ, iterExp_succ ] ; exact Real.exp_lt_exp.mpr ihn );
    · exact Real.continuousOn_exp;
    · exact Differentiable.differentiableOn Real.differentiable_exp;
  norm_num +zetaDelta at *;
  rw [ eq_div_iff ] at hc <;> nlinarith [ Real.add_one_le_exp c, Real.add_one_le_exp ( iterExp k 0 ), Real.add_one_le_exp ( iterExp k 1 ), Real.exp_pos ( iterExp k 0 ), Real.exp_pos ( iterExp k 1 ) ]

end