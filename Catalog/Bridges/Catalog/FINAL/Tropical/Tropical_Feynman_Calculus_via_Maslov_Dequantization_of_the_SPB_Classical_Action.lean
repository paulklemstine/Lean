import Mathlib

open Real Filter Finset BigOperators Topology

set_option maxHeartbeats 800000

/-! # Maslov Dequantization: Tropical Collapse of the Finite-Lattice Propagator

This file proves that the Maslov dequantization of a finite sum of exponentials
converges to the minimum (infimum) of the exponents. Concretely, for a finite
nonempty family of real numbers `{S_γ}_{γ ∈ Γ}`:

  `lim_{h → 0⁺} -h · log(∑_{γ ∈ Γ} exp(-S_γ / h)) = min_{γ ∈ Γ} S_γ`

This is the **Laplace principle** for finite sums, and constitutes the rigorous
foundation for the tropical collapse of the quantum propagator path integral
to a min-plus (tropical) sum over extremal paths.
-/

section LaplacePrinciple

variable {α : Type*}

/-
The sum of exponentials over a nonempty finset is strictly positive.
-/
lemma sum_exp_pos (Γ : Finset α) (hΓ : Γ.Nonempty) (f : α → ℝ) :
    0 < ∑ γ ∈ Γ, exp (-f γ / h) := by
  exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) hΓ

/-
Upper bound: `-h * log(∑ exp(-f γ/h)) ≤ inf' f` for `h > 0`. The single
minimizing term gives a lower bound on the sum, which after `-h * log` becomes
an upper bound.
-/
lemma laplace_upper_bound (Γ : Finset α) (hΓ : Γ.Nonempty) (f : α → ℝ)
    (h : ℝ) (hh : 0 < h) :
    -h * log (∑ γ ∈ Γ, exp (-f γ / h)) ≤ Γ.inf' hΓ f := by
  obtain ⟨ γ, hγ ⟩ := Finset.exists_mem_eq_inf' hΓ f;
  nlinarith [ Real.log_exp ( -f γ / h ), Real.log_le_log ( by positivity ) ( show ∑ γ ∈ Γ, Real.exp ( -f γ / h ) ≥ Real.exp ( -f γ / h ) by exact Finset.single_le_sum ( fun a _ => Real.exp_nonneg ( -f a / h ) ) hγ.1 ), mul_div_cancel₀ ( -f γ ) hh.ne' ]

/-
Lower bound: `inf' f - h * log(card Γ) ≤ -h * log(∑ exp(-f γ/h))` for `h > 0`.
Each term is bounded by the minimum, giving an upper bound on the sum, which after
`-h * log` becomes a lower bound.
-/
lemma laplace_lower_bound (Γ : Finset α) (hΓ : Γ.Nonempty) (f : α → ℝ)
    (h : ℝ) (hh : 0 < h) :
    Γ.inf' hΓ f - h * Real.log (Γ.card : ℝ) ≤
      -h * log (∑ γ ∈ Γ, exp (-f γ / h)) := by
  -- Let S* = Γ.inf' hΓ f. For every γ ∈ Γ, S* ≤ f γ, so -f γ / h ≤ -S* / h (dividing by positive h preserves; negation reverses).
  set S_star := Γ.inf' hΓ f with hS_star
  have h_le : ∀ γ ∈ Γ, -f γ / h ≤ -S_star / h := by
    exact fun γ hγ => by gcongr ; exact Finset.inf'_le _ hγ;
  -- Thus exp(-f γ / h) ≤ exp(-S*/h). Summing over Γ: ∑ exp(-f γ / h) ≤ Γ.card * exp(-S*/h).
  have h_sum_le : ∑ γ ∈ Γ, Real.exp (-f γ / h) ≤ Γ.card * Real.exp (-S_star / h) := by
    exact le_trans ( Finset.sum_le_sum fun x hx => Real.exp_le_exp.mpr ( h_le x hx ) ) ( by simp +decide );
  have := Real.log_le_log ( show 0 < ∑ γ ∈ Γ, Real.exp ( -f γ / h ) from ?_ ) h_sum_le;
  · rw [ Real.log_mul ( Nat.cast_ne_zero.mpr hΓ.card_pos.ne' ) ( ne_of_gt ( Real.exp_pos _ ) ), Real.log_exp ] at this ; nlinarith [ mul_div_cancel₀ ( -S_star ) hh.ne' ];
  · exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) hΓ

/-
The correction term `h * log(card Γ)` tends to 0 as `h → 0⁺`.
-/
lemma correction_tendsto_zero (Γ : Finset α) :
    Tendsto (fun h : ℝ ↦ h * Real.log (Γ.card : ℝ)) (𝓝[>] 0) (𝓝 0) := by
  exact tendsto_nhdsWithin_of_tendsto_nhds ( Continuous.tendsto' ( by continuity ) _ _ ( by norm_num ) )

/-
**Laplace principle for finite sums (Maslov dequantization).**

For any finite nonempty collection of real numbers indexed by `Γ`,
the Maslov dequantization `-h · log(∑_{γ ∈ Γ} exp(-f(γ)/h))` converges
to `inf'_{γ ∈ Γ} f(γ)` as `h → 0⁺`. This is the rigorous tropical
collapse: the quantum sum-over-histories reduces to the tropical
minimum of the classical action.
-/
theorem laplace_principle_finset
    (Γ : Finset α) (hΓ : Γ.Nonempty)
    (f : α → ℝ) :
    Tendsto
      (fun (h : ℝ) ↦ -h * log (∑ γ ∈ Γ, exp (-f γ / h)))
      (𝓝[>] 0)
      (𝓝 (Γ.inf' hΓ f)) := by
  refine' ( tendsto_iff_norm_sub_tendsto_zero.mpr _ );
  refine' squeeze_zero_norm' _ _;
  refine' fun n => |n * Real.log ( Γ.card : ℝ )|;
  · filter_upwards [ self_mem_nhdsWithin ] with n hn;
    simp +zetaDelta at *;
    rw [ ← abs_mul ];
    rw [ abs_le ];
    constructor <;> cases abs_cases ( n * Real.log ( Γ.card : ℝ ) ) <;> linarith [ laplace_lower_bound Γ hΓ f n hn, laplace_upper_bound Γ hΓ f n hn ];
  · exact tendsto_nhdsWithin_of_tendsto_nhds ( Continuous.tendsto' ( by continuity ) _ _ ( by simp +decide ) )

end LaplacePrinciple

section SPBPropagator

/-- Piecewise-linear paths in SPB 3-space with fixed endpoints x, y and n segments. -/
abbrev PLPath (x y : ℝ × ℝ × ℝ) (n : ℕ) :=
  {γ : Fin (n+1) → ℝ × ℝ × ℝ // γ 0 = x ∧ γ ⟨n, Nat.lt_succ_of_le le_rfl⟩ = y}

/-- The Lohmiller–Slotine classical action in the SPB Lorentz metric over time T.

This is defined as the sum of squared Euclidean distances between consecutive
vertices, divided by the time step `T/(n+1)`. This discretizes the classical
action `∫ |γ'(t)|² dt` over the piecewise-linear path. -/
noncomputable def spbLohmillerAction (x y : ℝ × ℝ × ℝ) (n : ℕ)
    (γ : PLPath x y n) (T : ℝ) : ℝ :=
  let path := γ.val
  let dt := T / (n + 1 : ℝ)
  ∑ i : Fin n,
    let p := path i.castSucc
    let q := path i.succ
    ((q.1 - p.1)^2 + (q.2.1 - p.2.1)^2 + (q.2.2 - p.2.2)^2) / dt

variable {n : ℕ}

/-- **Maslov dequantization of the finite-lattice SPB propagator.**

The quantum propagator amplitude over a finite family of PL paths collapses
to the tropical (min-plus) minimum of the classical action as the
deformation parameter `h → 0⁺`. This is the keystone theorem connecting
quantum path integrals to tropical geometry via Maslov dequantization. -/
theorem maslov_spb_propagator_dequantization
    (x y : ℝ × ℝ × ℝ) (T : ℝ) (_hT : T > 0)
    (Γ : Finset (PLPath x y n)) (hΓ : Γ.Nonempty) :
    Tendsto
      (fun (h : ℝ) ↦ -h * log (∑ γ ∈ Γ, exp (- spbLohmillerAction x y n γ T / h)))
      (𝓝[>] 0)
      (𝓝 (inf' Γ hΓ (fun γ ↦ spbLohmillerAction x y n γ T))) :=
  laplace_principle_finset Γ hΓ (fun γ ↦ spbLohmillerAction x y n γ T)

end SPBPropagator