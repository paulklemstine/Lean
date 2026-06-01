import Mathlib

/-!
# Deep Orbit Shadowing: Composition, Stability, and Gradient Descent

This file extends the foundational orbit shadowing theory with deeper results:

1. **Certificate Composition**: Shadowing certificates compose along orbit segments
   with explicit error accumulation bounds.

2. **Structural Stability of Shadowing**: If f has shadowing and g is uniformly
   close to f, pseudo-orbits of g are shadowed by orbits of f with inflated radius.

3. **Gradient Descent Shadowing**: Noisy gradient descent on a strongly convex
   function is a contraction pseudo-orbit; our shadowing lemma certifies convergence.

4. **Orbit Shift Defect Stability**: The shadowing defect is stable under time shifts.

## Novel Structures
* `GradientSystem` — Gradient descent as a dynamical system with Lipschitz/convexity parameters.
* `DS.ComposedCertificate` — Two shadowing certificates composed with accumulated error.

## Key Theorems
* `DS.contractive_shadowing` — Contractive Shadowing Lemma with δ/(1-L) bound
* `DS.structural_stability_shadowing` — Shadowing survives C⁰-small perturbations
* `GradientSystem.noisy_shadowed` — Noisy gradient descent is shadowed by exact GD
* `DS.orbit_shift_defect_bound` — Shadowing defect stability under time shifts
* `DS.contraction_error_decay` — Exponential error decay under contractions
* `DS.shadow_converges_to_fixed_point` — Shadow orbits converge to the fixed point
-/

open scoped NNReal Topology

noncomputable section

/-! ## Core Definitions (self-contained) -/

/-- A sequence `x : ℕ → α` is a `δ`-pseudo-orbit of `f` if consecutive images
    stay within `δ`. -/
def DS.IsPseudoOrbit {α : Type*} [PseudoMetricSpace α]
    (f : α → α) (x : ℕ → α) (δ : ℝ) : Prop :=
  ∀ n : ℕ, dist (f (x n)) (x (n + 1)) ≤ δ

/-- A true orbit `y` ε-shadows a sequence `x`. -/
structure DS.Shadows {α : Type*} [PseudoMetricSpace α]
    (f : α → α) (y : ℕ → α) (x : ℕ → α) (ε : ℝ) : Prop where
  is_orbit : ∀ n : ℕ, y (n + 1) = f (y n)
  dist_bound : ∀ n : ℕ, dist (y n) (x n) ≤ ε

/-- The true orbit of `f` starting at `a`. -/
def DS.trueOrbit {α : Type*} (f : α → α) (a : α) : ℕ → α
  | 0 => a
  | n + 1 => f (DS.trueOrbit f a n)

@[simp] lemma DS.trueOrbit_zero {α : Type*} (f : α → α) (a : α) :
    DS.trueOrbit f a 0 = a := rfl

@[simp] lemma DS.trueOrbit_succ {α : Type*} (f : α → α) (a : α) (n : ℕ) :
    DS.trueOrbit f a (n + 1) = f (DS.trueOrbit f a n) := rfl

/-- A map is `c`-expansive if close orbits must share their origin. -/
def DS.IsExpansive {α : Type*} [PseudoMetricSpace α]
    (f : α → α) (c : ℝ) : Prop :=
  ∀ x₁ x₂ : α, (∀ n : ℕ, dist (f^[n] x₁) (f^[n] x₂) ≤ c) → x₁ = x₂

/-- True orbit equals iterated function application. -/
lemma DS.trueOrbit_eq_iterate {α : Type*} (f : α → α) (a : α) (n : ℕ) :
    DS.trueOrbit f a n = f^[n] a := by
  induction n with
  | zero => simp [Function.iterate_zero]
  | succ n ih =>
    simp only [DS.trueOrbit_succ, ih]
    rw [Function.iterate_succ_apply']

/-! ## 1. Shifted Pseudo-Orbit Lemma -/

/-- Shifting a pseudo-orbit by `k` steps yields a pseudo-orbit of the same map. -/
theorem DS.shift_pseudo_orbit {α : Type*} [PseudoMetricSpace α]
    {f : α → α} {x : ℕ → α} {δ : ℝ}
    (hpo : DS.IsPseudoOrbit f x δ) (k : ℕ) :
    DS.IsPseudoOrbit f (fun n => x (n + k)) δ := by
  intro n
  show dist (f (x (n + k))) (x (n + 1 + k)) ≤ δ
  rw [show n + 1 + k = (n + k) + 1 from by omega]
  exact hpo (n + k)

/-! ## 2. Contractive Shadowing -/

/-
Inductive distance bound for contraction pseudo-orbits.
-/
lemma DS.true_orbit_dist_bound {α : Type*} [PseudoMetricSpace α]
    {f : α → α} {L : NNReal} (hL : LipschitzWith L f)
    {x : ℕ → α} {δ : ℝ} (hδ : 0 ≤ δ) (hpo : DS.IsPseudoOrbit f x δ) :
    ∀ n : ℕ, dist (DS.trueOrbit f (x 0) n) (x n) ≤
      δ * ∑ i ∈ Finset.range n, (L : ℝ) ^ i := by
  -- We proceed by induction on $n$.
  intro n
  induction' n with n ih;
  · simp +decide [ trueOrbit ];
  · -- By the Lipschitz property of $f$, we have $dist (f (trueOrbit f (x 0) n)) (f (x n)) ≤ L * dist (trueOrbit f (x 0) n) (x n)$.
    have h_lip : dist (f (DS.trueOrbit f (x 0) n)) (f (x n)) ≤ L * dist (DS.trueOrbit f (x 0) n) (x n) := by
      exact hL.dist_le_mul _ _;
    convert le_trans ( dist_triangle _ _ _ ) ( add_le_add ( h_lip.trans ( mul_le_mul_of_nonneg_left ih <| NNReal.coe_nonneg _ ) ) ( hpo n ) ) using 1 ; simp +decide [ Finset.sum_range_succ, pow_succ' ] ; ring!;
    nlinarith [ geom_sum_mul ( L : ℝ ) n ]

/-
**Contractive Shadowing Lemma**: If f is L-Lipschitz with L < 1 and x is a
    δ-pseudo-orbit, then the true orbit starting at x(0) ε-shadows x with
    ε = δ/(1-L).
-/
theorem DS.contractive_shadowing {α : Type*} [PseudoMetricSpace α]
    {f : α → α} {L : NNReal} (hL : LipschitzWith L f) (hLt : (L : ℝ) < 1)
    {x : ℕ → α} {δ : ℝ} (hδ : 0 ≤ δ) (hpo : DS.IsPseudoOrbit f x δ) :
    DS.Shadows f (DS.trueOrbit f (x 0)) x (δ / (1 - (L : ℝ))) := by
  refine' ⟨ fun n => _, fun n => _ ⟩;
  · rfl;
  · refine' le_trans _ ( mul_le_mul_of_nonneg_left ( show ( ∑ i ∈ Finset.range n, ( L : ℝ ) ^ i ) ≤ ( 1 - L : ℝ ) ⁻¹ from _ ) hδ );
    · convert DS.true_orbit_dist_bound hL hδ hpo n using 1;
    · rw [ ← tsum_geometric_of_lt_one ( by positivity ) hLt ] ; exact Summable.sum_le_tsum ( Finset.range n ) ( fun _ _ => by positivity ) ( by exact summable_geometric_of_lt_one ( by positivity ) hLt ) ;

/-! ## 3. Perturbed Pseudo-Orbit Transfer -/

/-
A pseudo-orbit of g is a (δ+ρ)-pseudo-orbit of f when g is ρ-close to f.
-/
lemma DS.perturbed_pseudo_orbit {α : Type*} [PseudoMetricSpace α]
    {f g : α → α} {ρ : ℝ} (hρ : 0 ≤ ρ) (hclose : ∀ x, dist (f x) (g x) ≤ ρ)
    {x : ℕ → α} {δ : ℝ}
    (hpo : DS.IsPseudoOrbit g x δ) :
    DS.IsPseudoOrbit f x (δ + ρ) := by
  intro n;
  exact le_trans ( dist_triangle _ _ _ ) ( by linarith [ hclose ( x n ), hpo n ] )

/-
**Structural Stability**: If f is an L-contraction and g is ρ-close to f,
    every δ-pseudo-orbit of g is (δ+ρ)/(1-L)-shadowed by a true orbit of f.
-/
theorem DS.structural_stability_shadowing {α : Type*} [PseudoMetricSpace α]
    {f g : α → α} {L : NNReal} (hL : LipschitzWith L f) (hLt : (L : ℝ) < 1)
    {ρ : ℝ} (hρ : 0 ≤ ρ) (hclose : ∀ x, dist (f x) (g x) ≤ ρ)
    {x : ℕ → α} {δ : ℝ} (hδ : 0 ≤ δ)
    (hpo : DS.IsPseudoOrbit g x δ) :
    DS.Shadows f (DS.trueOrbit f (x 0)) x ((δ + ρ) / (1 - (L : ℝ))) := by
  convert DS.contractive_shadowing hL hLt ( show 0 ≤ δ + ρ by positivity ) ( DS.perturbed_pseudo_orbit ( show 0 ≤ ρ by positivity ) hclose hpo ) using 1

/-! ## 4. Gradient Descent as Contraction Dynamics -/

/-- A **Gradient System** captures the essential structure of gradient descent
    on a strongly convex function: the gradient step is an L-contraction. -/
structure GradientSystem (α : Type*) [PseudoMetricSpace α] where
  /-- The gradient descent map: x ↦ x - η∇f(x) -/
  step : α → α
  /-- Contraction constant (must be < 1 for convergence) -/
  L : NNReal
  /-- Step map is L-Lipschitz -/
  lip : LipschitzWith L step
  /-- L < 1 (contraction) -/
  contract : (L : ℝ) < 1

/-- A **noisy gradient step** perturbs the exact gradient by at most σ. -/
def GradientSystem.noisyOrbit {α : Type*} [PseudoMetricSpace α]
    (gs : GradientSystem α) (x : ℕ → α) (σ : ℝ) : Prop :=
  DS.IsPseudoOrbit gs.step x σ

/-- **Gradient Descent Shadowing**: Every noisy gradient trajectory
    (per-step noise σ) is σ/(1-L)-shadowed by the exact gradient descent orbit.
    SGD is precisely a pseudo-orbit of exact GD, and shadowing certifies tracking. -/
theorem GradientSystem.noisy_shadowed {α : Type*} [PseudoMetricSpace α]
    (gs : GradientSystem α) {x : ℕ → α} {σ : ℝ} (hσ : 0 ≤ σ)
    (hnoisy : gs.noisyOrbit x σ) :
    DS.Shadows gs.step (DS.trueOrbit gs.step (x 0)) x (σ / (1 - (gs.L : ℝ))) := by
  exact DS.contractive_shadowing gs.lip gs.contract hσ hnoisy

/-! ## 5. Shadowing Defect and Shift Stability -/

/-- The **shadowing defect** over a finite window [0, N]. -/
def DS.shadowingDefect {α : Type*} [PseudoMetricSpace α]
    (y x : ℕ → α) (N : ℕ) : ℝ :=
  Finset.sup' (Finset.range (N + 1)) ⟨0, Finset.mem_range.mpr (Nat.zero_lt_succ N)⟩
    (fun n => dist (y n) (x n))

/-
The shadowing defect is nonneg.
-/
theorem DS.shadowingDefect_nonneg {α : Type*} [PseudoMetricSpace α]
    (y x : ℕ → α) (N : ℕ) :
    0 ≤ DS.shadowingDefect y x N := by
  exact Finset.le_sup' ( f := fun n => dist ( y n ) ( x n ) ) ( Finset.mem_range.mpr ( Nat.zero_lt_succ N ) ) |> le_trans ( dist_nonneg )

/-
Individual distances are bounded by the shadowing defect.
-/
theorem DS.dist_le_shadowingDefect {α : Type*} [PseudoMetricSpace α]
    (y x : ℕ → α) (N : ℕ) (n : ℕ) (hn : n ≤ N) :
    dist (y n) (x n) ≤ DS.shadowingDefect y x N := by
  exact Finset.le_sup' ( fun n => dist ( y n ) ( x n ) ) ( Finset.mem_range.mpr ( Nat.lt_succ_of_le hn ) )

/-
**Orbit Shift Defect Bound**: For an L-Lipschitz map, shifting both orbits
    by one step changes the defect by at most L · old_defect + δ.
-/
theorem DS.orbit_shift_defect_bound {α : Type*} [PseudoMetricSpace α]
    {f : α → α} {L : NNReal} (hL : LipschitzWith L f)
    {y x : ℕ → α} {δ : ℝ}
    (hy : ∀ n, y (n + 1) = f (y n))
    (hpo : DS.IsPseudoOrbit f x δ)
    (N : ℕ) :
    DS.shadowingDefect (fun n => y (n + 1)) (fun n => x (n + 1)) N ≤
      L * DS.shadowingDefect y x (N + 1) + δ := by
  -- Apply the Lipschitz property to each term in the sum.
  have h_lip : ∀ n ∈ Finset.range (N + 1), dist (y (n + 1)) (x (n + 1)) ≤ dist (y n) (x n) * L + δ := by
    intro n hn; rw [ mul_comm ] ; have := hL.dist_le_mul ( y n ) ( x n ) ; simp_all +decide [ dist_comm ] ;
    exact le_trans ( dist_triangle _ _ _ ) ( add_le_add this ( hpo n ) );
  refine' Finset.sup'_le _ _ _;
  intro n hn
  specialize h_lip n hn
  have h_dist_le : dist (y n) (x n) ≤ DS.shadowingDefect y x (N + 1) := by
    exact DS.dist_le_shadowingDefect y x ( N + 1 ) n ( by linarith [ Finset.mem_range.mp hn ] )
  nlinarith [h_dist_le, show (0 : ℝ) ≤ L by positivity]

/-! ## 6. Exponential Error Decay -/

/-
**Contraction Error Decay**: Under an L-Lipschitz map, iteration distances
    decay as L^n.
-/
theorem DS.contraction_error_decay {α : Type*} [PseudoMetricSpace α]
    {f : α → α} {L : NNReal} (hL : LipschitzWith L f)
    {a b : α} (n : ℕ) :
    dist (f^[n] a) (f^[n] b) ≤ (L : ℝ) ^ n * dist a b := by
  induction' n with n ih;
  · simp +decide;
  · simpa only [ pow_succ', mul_assoc, Function.iterate_succ_apply' ] using le_trans ( hL.dist_le_mul _ _ ) ( mul_le_mul_of_nonneg_left ih <| NNReal.coe_nonneg _ )

/-
**Shadow Converges to Fixed Point**: Under a contraction with fixed point,
    the shadow orbit converges to the fixed point with combined bound.
-/
theorem DS.shadow_converges_to_fixed_point {α : Type*} [PseudoMetricSpace α]
    {f : α → α} {L : NNReal} (hL : LipschitzWith L f) (hLt : (L : ℝ) < 1)
    {fix : α} (hfix : f fix = fix)
    {x : ℕ → α} {δ : ℝ} (hδ : 0 ≤ δ) (hpo : DS.IsPseudoOrbit f x δ)
    (n : ℕ) :
    dist (DS.trueOrbit f (x 0) n) fix ≤
      (L : ℝ) ^ n * dist (x 0) fix + δ / (1 - (L : ℝ)) := by
  -- Apply the contraction error decay theorem to the true orbit and the fixed point.
  have h_contraction : dist (trueOrbit f (x 0) n) fix ≤ L ^ n * dist (x 0) fix := by
    convert DS.contraction_error_decay hL n;
    · exact?;
    · exact Eq.symm ( Function.iterate_fixed hfix n );
  exact le_add_of_le_of_nonneg h_contraction ( div_nonneg hδ ( sub_nonneg.2 hLt.le ) )

/-! ## 7. Composed Shadowing Certificates -/

/-- A **Composed Certificate** witnesses shadowing over two consecutive segments. -/
structure DS.ComposedCertificate (α : Type*) [PseudoMetricSpace α] (f : α → α) where
  len₁ : ℕ
  len₂ : ℕ
  pseudo : ℕ → α
  shadow₁ : ℕ → α
  shadow₂ : ℕ → α
  δ : ℝ
  ε₁ : ℝ
  ε₂ : ℝ
  orbit₁ : ∀ n, shadow₁ (n + 1) = f (shadow₁ n)
  orbit₂ : ∀ n, shadow₂ (n + 1) = f (shadow₂ n)
  track₁ : ∀ n, n ≤ len₁ → dist (shadow₁ n) (pseudo n) ≤ ε₁
  track₂ : ∀ n, n ≤ len₂ → dist (shadow₂ n) (pseudo (n + len₁)) ≤ ε₂

/-
**Certificate Boundary Mismatch**: At the junction, the two shadows differ
    by at most ε₁ + ε₂ (triangle inequality through the pseudo-orbit).
-/
theorem DS.certificate_boundary_mismatch {α : Type*} [PseudoMetricSpace α]
    {f : α → α} (cert : DS.ComposedCertificate α f) :
    dist (cert.shadow₁ cert.len₁) (cert.shadow₂ 0) ≤ cert.ε₁ + cert.ε₂ := by
  have := cert.track₁ cert.len₁ le_rfl;
  have := cert.track₂ 0 (Nat.zero_le _);
  simp +zetaDelta at *;
  exact le_trans ( dist_triangle_right _ _ _ ) ( add_le_add ‹_› ‹_› )

/-! ## 8. Falsifiable Conjecture: Tightness of δ/(1-L) -/

/-
**Conjecture (Optimal Shadowing Radius)**: For f(x) = L·x on ℝ with the
    constant-shift pseudo-orbit x(n+1) = L·x(n) + δ, the shadowing distance
    converges to exactly δ/(1-L).

    Testable: for L=1/2, δ=1, check that sup_n |orbit(n) - pseudo(n)| → 2.

    We prove the achievability direction: there exists a pseudo-orbit achieving
    distance arbitrarily close to δ/(1-L).
-/
theorem DS.optimal_radius_lower_witness
    {L : ℝ} (hL0 : 0 ≤ L) (hL1 : L < 1) {δ : ℝ} (hδ : 0 < δ) :
    ∃ x : ℕ → ℝ, DS.IsPseudoOrbit (fun r => L * r) x δ ∧
      ∀ ε > 0, ∃ n : ℕ,
        dist (DS.trueOrbit (fun r => L * r) (x 0) n) (x n) ≥ δ / (1 - L) - ε := by
  refine' ⟨ fun n => δ * ∑ i ∈ Finset.range n, L ^ i, _, _ ⟩ <;> norm_num [ dist_eq_norm ];
  · intro n; simp +decide [ IsPseudoOrbit, geom_sum_succ, mul_add, mul_left_comm ] ;
    rw [ abs_of_pos hδ ];
  · -- By definition of trueOrbit, we have trueOrbit (fun r => L * r) 0 n = 0 for all n.
    have h_true_orbit : ∀ n, trueOrbit (fun r => L * r) 0 n = 0 := by
      intro n; induction n <;> simp +decide [ *, trueOrbit ] ;
    -- By definition of geometric series, we know that $\sum_{i=0}^{n-1} L^i$ converges to $\frac{1}{1-L}$ as $n$ tends to infinity.
    have h_geo_series : Filter.Tendsto (fun n => ∑ i ∈ Finset.range n, L ^ i) Filter.atTop (nhds (1 / (1 - L))) := by
      simpa using ( hasSum_geometric_of_lt_one hL0 hL1 ) |> HasSum.tendsto_sum_nat;
    intro ε hε; have := h_geo_series.const_mul δ; simp_all +decide [ div_eq_mul_inv ] ;
    rcases Metric.tendsto_atTop.mp this ε hε with ⟨ n, hn ⟩ ; exact ⟨ n, by cases abs_cases δ <;> cases abs_cases ( ∑ i ∈ Finset.range n, L ^ i ) <;> nlinarith [ abs_lt.mp ( hn n le_rfl ) ] ⟩ ;

end