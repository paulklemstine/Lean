import Mathlib

/-!
# A tropical (max-plus) model of a mathematical phase transition

This file develops a self-contained chain of results around a *tropical order
parameter* modelling a phase transition in mathematical coherence.

The speculative motivation is that mathematical discovery proceeds in an
"incoherent" phase (isolated results, sub-critical cross-field connectivity)
until a critical connectivity `c` is reached, after which a "coherent" phase
emerges with an order parameter growing linearly in the excess connectivity.
The natural language for such a piecewise-linear order parameter is *tropical
(max-plus) geometry*: the order parameter is the tropical binomial

`order κ c x = max (κ · (x - c)) 0`,

i.e. the evaluation of the tropical polynomial with monomials `κ·(x-c)` and the
tropical zero (the constant `0`).  Its unique breakpoint at `x = c` is the phase
transition, and the piecewise-linear "kink" there is the tropical hypersurface.

The chain of results, each building on the previous ones:

* `order_nonneg` — the order parameter is nonnegative;
* `order_eq_zero_of_le` — sub-critical (incoherent) phase: it vanishes below `c`;
* `order_eq_of_ge` / `order_at_critical` — critical value and the linear law above `c`;
* `order_pos_of_lt` — strict positivity in the coherent phase;
* `order_mono` — monotonicity in connectivity;
* `affine_convexOn` / `order_convexOn` — **convexity** of the order parameter
  (a tropical polynomial is convex, being a max of affine functions);
* `order_lipschitz` — the order parameter is `|κ|`-Lipschitz;
* `order_strictMonoOn_above` — strict growth in the coherent phase;
* `phase_transition` — the qualitative dichotomy summarising the transition;
* `numberTheoryCriticalEdges` specialisations — the model at a fixed threshold.

The numerical threshold is a *model parameter*, not an empirical claim.
-/

namespace TropicalPhaseTransition

/-- Tropical (max-plus) order parameter: the tropical binomial with monomials
`κ · (x - c)` and the tropical zero `0`.  It is the ReLU of the scaled excess
connectivity above the critical threshold `c`. -/
noncomputable def order (κ c x : ℝ) : ℝ := max (κ * (x - c)) 0

/-- The order parameter is always nonnegative. -/
theorem order_nonneg (κ c x : ℝ) : 0 ≤ order κ c x := le_max_right _ _

/-- Sub-critical (incoherent) phase: at or below the critical connectivity the
order parameter vanishes (for nonnegative coupling). -/
theorem order_eq_zero_of_le (κ c x : ℝ) (hκ : 0 ≤ κ) (hx : x ≤ c) :
    order κ c x = 0 := by
  unfold order
  apply max_eq_right
  exact mul_nonpos_of_nonneg_of_nonpos hκ (sub_nonpos.mpr hx)

/-- Coherent phase: above the critical connectivity the order parameter follows
the linear law `κ · (x - c)` (for nonnegative coupling). -/
theorem order_eq_of_ge (κ c x : ℝ) (hκ : 0 ≤ κ) (hx : c ≤ x) :
    order κ c x = κ * (x - c) := by
  unfold order
  apply max_eq_left
  exact mul_nonneg hκ (sub_nonneg.mpr hx)

/-- At the critical point the order parameter is exactly zero. -/
theorem order_at_critical (κ c : ℝ) (hκ : 0 ≤ κ) : order κ c c = 0 :=
  order_eq_zero_of_le κ c c hκ le_rfl

/-- Strict positivity in the coherent phase: with positive coupling, above the
critical connectivity the order parameter is strictly positive. -/
theorem order_pos_of_lt (κ c x : ℝ) (hκ : 0 < κ) (hx : c < x) :
    0 < order κ c x := by
  rw [order_eq_of_ge κ c x hκ.le hx.le]
  exact mul_pos hκ (sub_pos.mpr hx)

/-- The order parameter is monotone in the connectivity `x` (for nonnegative
coupling). -/
theorem order_mono (κ c : ℝ) (hκ : 0 ≤ κ) : Monotone (order κ c) := by
  intro x y hxy
  unfold order
  apply max_le_max _ le_rfl
  exact mul_le_mul_of_nonneg_left (sub_le_sub_right hxy c) hκ

/-- Any affine function `x ↦ κ · (x - c)` on the reals is convex on the whole
line.  (This is the "tropical monomial is affine, hence convex" step.) -/
theorem affine_convexOn (κ c : ℝ) :
    ConvexOn ℝ Set.univ (fun x : ℝ => κ * (x - c)) := by
  refine ⟨convex_univ, ?_⟩
  intro x _ y _ p q _ _ hpq
  simp only [smul_eq_mul]
  apply le_of_eq
  linear_combination (κ * c) * hpq

/-- **Convexity of the tropical order parameter.**  A tropical polynomial is a
maximum of affine functions and is therefore convex.  Convexity of the order
parameter is the quantitative signature of a *continuous* (second-order) phase
transition: no jump, but a kink at criticality. -/
theorem order_convexOn (κ c : ℝ) : ConvexOn ℝ Set.univ (order κ c) := by
  have h1 : ConvexOn ℝ Set.univ (fun x : ℝ => κ * (x - c)) := affine_convexOn κ c
  have h2 : ConvexOn ℝ Set.univ (fun _ : ℝ => (0 : ℝ)) := convexOn_const 0 convex_univ
  have h := h1.sup h2
  simpa [order, Pi.sup_def] using h

/-- The order parameter is `|κ|`-Lipschitz: the tropical/ReLU nonlinearity does
not amplify perturbations in the connectivity beyond the coupling strength. -/
theorem order_lipschitz (κ c x y : ℝ) :
    |order κ c x - order κ c y| ≤ |κ| * |x - y| := by
  have h := abs_max_sub_max_le_abs (κ * (x - c)) (κ * (y - c)) 0
  have heq : κ * (x - c) - κ * (y - c) = κ * (x - y) := by ring
  calc |order κ c x - order κ c y|
      = |max (κ * (x - c)) 0 - max (κ * (y - c)) 0| := rfl
    _ ≤ |κ * (x - c) - κ * (y - c)| := h
    _ = |κ * (x - y)| := by rw [heq]
    _ = |κ| * |x - y| := abs_mul κ (x - y)

/-- Strict growth in the coherent phase: once past criticality the order
parameter is strictly increasing (for positive coupling). -/
theorem order_strictMonoOn_above (κ c : ℝ) (hκ : 0 < κ) :
    StrictMonoOn (order κ c) (Set.Ici c) := by
  intro x hx y hy hxy
  rw [order_eq_of_ge κ c x hκ.le hx, order_eq_of_ge κ c y hκ.le (le_trans hx hxy.le)]
  exact mul_lt_mul_of_pos_left (by linarith) hκ

/-- **Qualitative phase transition.**  With positive coupling the model exhibits
a sharp dichotomy about the critical connectivity `c`: identically zero (an
incoherent plateau) at or below `c`, and strictly positive (a coherent phase)
strictly above `c`. -/
theorem phase_transition (κ c : ℝ) (hκ : 0 < κ) :
    (∀ x ≤ c, order κ c x = 0) ∧ (∀ x, c < x → 0 < order κ c x) := by
  refine ⟨fun x hx => order_eq_zero_of_le κ c x hκ.le hx, fun x hx => order_pos_of_lt κ c x hκ hx⟩

/-- The proposed number-theory connectivity threshold, a model parameter. -/
def numberTheoryCriticalEdges : ℕ := 10000

/-- At or below the threshold, the integer-indexed model is in the incoherent
phase. -/
theorem numberTheory_inactive (κ : ℝ) (hκ : 0 ≤ κ) (edges : ℕ)
    (hedges : edges ≤ numberTheoryCriticalEdges) :
    order κ numberTheoryCriticalEdges edges = 0 :=
  order_eq_zero_of_le _ _ _ hκ (by exact_mod_cast hedges)

/-- Above the threshold, positive coupling yields a coherent (positive) phase. -/
theorem numberTheory_active (κ : ℝ) (hκ : 0 < κ) (edges : ℕ)
    (hedges : numberTheoryCriticalEdges < edges) :
    0 < order κ numberTheoryCriticalEdges edges :=
  order_pos_of_lt _ _ _ hκ (by exact_mod_cast hedges)

end TropicalPhaseTransition