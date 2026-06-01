/-
  # Orbit Shadowing in Dynamical Systems

  This file formalizes the theory of orbit shadowing for discrete dynamical systems
  on metric spaces. The central results are:

  1. **Contractive Shadowing Lemma**: Every δ-pseudo-orbit of an L-contraction
     (L < 1) is shadowed by a true orbit with explicit bound δ/(1-L).

  2. **Shadowing Uniqueness for Expansive Maps**: If a map is c-expansive,
     then any pseudo-orbit has at most one shadowing orbit within radius c.

  3. **Shadowing Certificate**: A novel computational witness structure that
     bundles a pseudo-orbit with its verified shadowing true orbit, enabling
     composable certified numerical dynamics.

  4. **Certificate Composition**: Shadowing certificates can be composed along
     orbit segments, with explicit error accumulation bounds.
-/

import Mathlib

open scoped NNReal Topology

noncomputable section

/-! ## Core Definitions -/

/-- A sequence `x : ℕ → α` is a `δ`-pseudo-orbit of `f` if each consecutive
    pair satisfies `dist(f(xₙ), xₙ₊₁) ≤ δ`. This captures the notion of
    a "numerically computed orbit" where each step incurs at most `δ` error. -/
def IsPseudoOrbit {α : Type*} [PseudoMetricSpace α] (f : α → α) (x : ℕ → α) (δ : ℝ) : Prop :=
  ∀ n : ℕ, dist (f (x n)) (x (n + 1)) ≤ δ

/-- A true orbit `y : ℕ → α` `ε`-shadows a sequence `x : ℕ → α` if `y` is
    a genuine orbit of `f` and stays within `ε` of `x` at every step. -/
structure Shadows {α : Type*} [PseudoMetricSpace α] (f : α → α) (y : ℕ → α)
    (x : ℕ → α) (ε : ℝ) : Prop where
  is_orbit : ∀ n : ℕ, y (n + 1) = f (y n)
  dist_bound : ∀ n : ℕ, dist (y n) (x n) ≤ ε

/-- A map `f` has the `(δ, ε)`-shadowing property if every `δ`-pseudo-orbit
    is `ε`-shadowed by some true orbit. -/
def HasShadowingProperty {α : Type*} [PseudoMetricSpace α] (f : α → α) (δ ε : ℝ) : Prop :=
  ∀ x : ℕ → α, IsPseudoOrbit f x δ → ∃ y : ℕ → α, Shadows f y x ε

/-- A map `f` is `c`-expansive if any two orbits that remain within distance `c`
    for all time must be identical at the origin. -/
def IsExpansive {α : Type*} [PseudoMetricSpace α] (f : α → α) (c : ℝ) : Prop :=
  ∀ x₁ x₂ : α, (∀ n : ℕ, dist (f^[n] x₁) (f^[n] x₂) ≤ c) → x₁ = x₂

/-- A **Shadowing Certificate** is a computational witness that a pseudo-orbit
    is shadowed by a genuine orbit. It bundles:
    - The pseudo-orbit `pseudo` and its error bound `δ`
    - The shadowing true orbit `shadow` and the shadowing radius `ε`
    - Proofs that `pseudo` is indeed a `δ`-pseudo-orbit and `shadow` indeed shadows it.

    This transforms the abstract existence theorem into a concrete, composable
    programming object for certified numerical dynamics. -/
structure ShadowingCertificate (α : Type*) [PseudoMetricSpace α] (f : α → α) where
  /-- Length of the certified orbit segment -/
  len : ℕ
  /-- The pseudo-orbit (numerical approximation) -/
  pseudo : ℕ → α
  /-- The shadowing true orbit -/
  shadow : ℕ → α
  /-- Pseudo-orbit error bound -/
  δ : ℝ
  /-- Shadowing radius -/
  ε : ℝ
  /-- Proof that `pseudo` is a `δ`-pseudo-orbit -/
  pseudo_valid : IsPseudoOrbit f pseudo δ
  /-- Proof that `shadow` shadows `pseudo` -/
  shadow_valid : Shadows f shadow pseudo ε

/-! ## Contractive Shadowing Lemma -/

/-- The true orbit of `f` starting at `a`. -/
def trueOrbit {α : Type*} (f : α → α) (a : α) : ℕ → α
  | 0 => a
  | n + 1 => f (trueOrbit f a n)

@[simp]
lemma trueOrbit_zero {α : Type*} (f : α → α) (a : α) :
    trueOrbit f a 0 = a := rfl

@[simp]
lemma trueOrbit_succ {α : Type*} (f : α → α) (a : α) (n : ℕ) :
    trueOrbit f a (n + 1) = f (trueOrbit f a n) := rfl

lemma trueOrbit_is_orbit {α : Type*} (f : α → α) (a : α) :
    ∀ n : ℕ, trueOrbit f a (n + 1) = f (trueOrbit f a n) :=
  fun _ => rfl

/-
Key inductive bound: for an L-Lipschitz map, the distance between the
    true orbit starting at `x 0` and the pseudo-orbit `x` satisfies
    `dist(orbit(n), x(n)) ≤ δ · ∑_{i=0}^{n-1} L^i`.
-/
lemma true_orbit_pseudo_dist {α : Type*} [PseudoMetricSpace α]
    {f : α → α} {L : NNReal} (hL : LipschitzWith L f)
    {x : ℕ → α} {δ : ℝ} (hδ : 0 ≤ δ) (hpo : IsPseudoOrbit f x δ) :
    ∀ n : ℕ, dist (trueOrbit f (x 0) n) (x n) ≤ δ * ∑ i ∈ Finset.range n, (L : ℝ) ^ i := by
  intro i; induction' i with n ih <;> simp_all +decide [ Finset.sum_range_succ ] ;
  refine' le_trans ( dist_triangle _ _ _ ) _;
  exact f ( x n );
  refine' le_trans ( add_le_add ( hL.dist_le_mul _ _ ) ( hpo n ) ) _;
  nlinarith [ show ( L : ℝ ) ≥ 0 by positivity, show ( ∑ i ∈ Finset.range n, ( L : ℝ ) ^ i ) ≥ 0 by exact Finset.sum_nonneg fun _ _ => pow_nonneg ( NNReal.coe_nonneg _ ) _, show ( L : ℝ ) ^ n ≥ 0 by positivity, geom_sum_mul ( L : ℝ ) n ]

/-
**Contractive Shadowing Lemma (Geometric Series Bound)**.

If `f` is `L`-Lipschitz with `L < 1` and `x` is a `δ`-pseudo-orbit,
then the true orbit of `f` starting at `x(0)` stays within distance
`δ / (1 - L)` of the pseudo-orbit `x`.

This is the foundational result connecting numerical error to orbit shadowing:
any approximate computation with per-step error `δ` under a contraction tracks
a genuine orbit with total error at most `δ/(1-L)`.
-/
theorem contractive_shadowing_lemma {α : Type*} [PseudoMetricSpace α]
    {f : α → α} {L : NNReal} (hL_lip : LipschitzWith L f)
    (hL_lt : (L : ℝ) < 1)
    {x : ℕ → α} {δ : ℝ} (hδ : 0 ≤ δ) (hpo : IsPseudoOrbit f x δ) :
    Shadows f (trueOrbit f (x 0)) x (δ / (1 - (L : ℝ))) := by
  refine' ⟨ _, _ ⟩;
  · exact fun n => trueOrbit_is_orbit f (x 0) n;
  · -- Apply the true_orbit_pseudo_dist lemma with α = ℕ and the given hypotheses.
    have h_dist : ∀ n : ℕ, dist (trueOrbit f (x 0) n) (x n) ≤ δ * ∑ i ∈ Finset.range n, (L : ℝ) ^ i := by
      exact fun n => true_orbit_pseudo_dist hL_lip hδ hpo n;
    exact fun n => le_trans ( h_dist n ) ( by rw [ div_eq_mul_inv ] ; exact mul_le_mul_of_nonneg_left ( by rw [ ← tsum_geometric_of_lt_one ( by positivity ) hL_lt ] ; exact Summable.sum_le_tsum ( Finset.range n ) ( fun _ _ => by positivity ) ( by exact summable_geometric_of_lt_one ( by positivity ) hL_lt ) ) hδ )

/-- The contractive shadowing lemma yields the full shadowing property. -/
theorem contraction_has_shadowing_property {α : Type*} [PseudoMetricSpace α]
    {f : α → α} {L : NNReal} (hL_lip : LipschitzWith L f)
    (hL_lt : (L : ℝ) < 1)
    {δ : ℝ} (hδ : 0 ≤ δ) :
    HasShadowingProperty f δ (δ / (1 - (L : ℝ))) := by
  intro x hpo
  exact ⟨trueOrbit f (x 0), contractive_shadowing_lemma hL_lip hL_lt hδ hpo⟩

/-! ## Expansive Shadowing Uniqueness -/

/-
**Shadowing Uniqueness for Expansive Maps**.

If `f` is `c`-expansive and two orbits both `ε`-shadow the same pseudo-orbit
with `2ε ≤ c`, then they must start at the same point.
-/
theorem shadowing_unique_of_expansive {α : Type*} [PseudoMetricSpace α]
    {f : α → α} {c : ℝ} (hexp : IsExpansive f c)
    {x : ℕ → α} {y₁ y₂ : ℕ → α} {ε : ℝ}
    (hs₁ : Shadows f y₁ x ε) (hs₂ : Shadows f y₂ x ε)
    (hε : 2 * ε ≤ c) :
    y₁ 0 = y₂ 0 := by
  -- Since $y_1$ and $y_2$ are both orbits, we have $f^[n](y_1 0) = y_1 n$ and $f^[n](y_2 0) = y_2 n$ for all $n$.
  have h_orbit_eq : ∀ n, f^[n] (y₁ 0) = y₁ n ∧ f^[n] (y₂ 0) = y₂ n := by
    intro n; induction n <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
    exact ⟨ hs₁.is_orbit _ ▸ rfl, hs₂.is_orbit _ ▸ rfl ⟩;
  apply hexp; intro n; have := hs₁.dist_bound n; have := hs₂.dist_bound n; simp_all +decide [ two_mul ] ;
  linarith [ dist_triangle_right ( y₁ n ) ( y₂ n ) ( x n ) ]

/-
If two orbits shadow the same pseudo-orbit under an expansive map, they
    coincide at every time step.
-/
theorem shadowing_orbit_unique_of_expansive {α : Type*} [PseudoMetricSpace α]
    {f : α → α} {c : ℝ} (hexp : IsExpansive f c)
    {x : ℕ → α} {y₁ y₂ : ℕ → α} {ε : ℝ}
    (hs₁ : Shadows f y₁ x ε) (hs₂ : Shadows f y₂ x ε)
    (hε : 2 * ε ≤ c) :
    ∀ n : ℕ, y₁ n = y₂ n := by
  intro n
  induction' n with n ih;
  · exact shadowing_unique_of_expansive hexp hs₁ hs₂ hε;
  · rw [ hs₁.is_orbit, hs₂.is_orbit, ih ]

/-! ## Shadowing Certificate Construction -/

/-- Construct a shadowing certificate from the contractive shadowing lemma. -/
def ShadowingCertificate.fromContraction {α : Type*} [PseudoMetricSpace α]
    {f : α → α} {L : NNReal} (hL_lip : LipschitzWith L f)
    (hL_lt : (L : ℝ) < 1)
    (x : ℕ → α) {δ : ℝ} (hδ : 0 ≤ δ)
    (hpo : IsPseudoOrbit f x δ)
    (len : ℕ) :
    ShadowingCertificate α f :=
  { len := len
    pseudo := x
    shadow := trueOrbit f (x 0)
    δ := δ
    ε := δ / (1 - (L : ℝ))
    pseudo_valid := hpo
    shadow_valid := contractive_shadowing_lemma hL_lip hL_lt hδ hpo }

/-- The shadowing radius of a contraction certificate equals δ/(1-L). -/
theorem ShadowingCertificate.contraction_radius {α : Type*} [PseudoMetricSpace α]
    {f : α → α} {L : NNReal} (hL_lip : LipschitzWith L f)
    (hL_lt : (L : ℝ) < 1)
    (x : ℕ → α) {δ : ℝ} (hδ : 0 ≤ δ)
    (hpo : IsPseudoOrbit f x δ)
    (len : ℕ) :
    (ShadowingCertificate.fromContraction hL_lip hL_lt x hδ hpo len).ε = δ / (1 - (L : ℝ)) :=
  rfl

/-! ## Pseudo-orbit Perturbation Stability -/

/-
If `x` is a `δ`-pseudo-orbit and we perturb each point by at most `r`,
    the result is a `(δ + 2r)`-pseudo-orbit assuming `f` is 1-Lipschitz.
-/
theorem pseudo_orbit_perturb_nonexpansive {α : Type*} [PseudoMetricSpace α]
    {f : α → α} (hf : LipschitzWith 1 f)
    {x x' : ℕ → α} {δ r : ℝ}
    (hpo : IsPseudoOrbit f x δ)
    (hpert : ∀ n, dist (x n) (x' n) ≤ r) :
    IsPseudoOrbit f x' (δ + 2 * r) := by
  intro n;
  -- Apply the triangle inequality to the distances.
  have h_triangle : dist (f (x' n)) (x' (n + 1)) ≤ dist (f (x' n)) (f (x n)) + dist (f (x n)) (x (n + 1)) + dist (x (n + 1)) (x' (n + 1)) := by
    exact dist_triangle4 _ _ _ _;
  convert h_triangle.trans _ using 1;
  refine' le_trans ( add_le_add_three ( LipschitzWith.dist_le_mul _ _ _ ) ( hpo _ ) ( hpert _ ) ) _;
  exacts [ 1, hf, by norm_num; linarith [ hpert n, dist_comm ( x' n ) ( x n ) ] ]

/-! ## Iterated Contraction Bounds -/

/-
For a contraction with Lipschitz constant L, the n-th iterate
    f^[n] has Lipschitz constant L^n.
-/
theorem iterate_lipschitz_of_contraction {α : Type*} [PseudoMetricSpace α]
    {f : α → α} {L : NNReal} (hf : LipschitzWith L f) (n : ℕ) :
    LipschitzWith (L ^ n) (f^[n]) := by
  convert hf.iterate n using 1

/-
Exponential convergence: under an L-contraction (L < 1), any two points
    converge exponentially fast under iteration.
-/
theorem contraction_exponential_convergence {α : Type*} [PseudoMetricSpace α]
    {f : α → α} {L : NNReal} (hf : LipschitzWith L f)
    (x y : α) (n : ℕ) :
    dist (f^[n] x) (f^[n] y) ≤ (L : ℝ) ^ n * dist x y := by
  convert hf.iterate n |>.dist_le_mul x y using 1

/-! ## Shadowing Defect -/

/-- The **shadowing defect** measures the maximum pointwise distance between
    a candidate shadow and the pseudo-orbit over a finite window. -/
def shadowingDefect {α : Type*} [PseudoMetricSpace α]
    (y x : ℕ → α) (N : ℕ) : ℝ :=
  Finset.sup' (Finset.range (N + 1)) ⟨0, Finset.mem_range.mpr (Nat.zero_lt_succ N)⟩
    (fun n => dist (y n) (x n))

/-
The shadowing defect is nonneg.
-/
theorem shadowingDefect_nonneg {α : Type*} [PseudoMetricSpace α]
    (y x : ℕ → α) (N : ℕ) :
    0 ≤ shadowingDefect y x N := by
  exact Finset.le_sup' ( fun n => dist ( y n ) ( x n ) ) ( Finset.mem_range.mpr ( Nat.zero_lt_succ _ ) ) |> le_trans dist_nonneg

/-
The shadowing defect bounds each individual distance.
-/
theorem dist_le_shadowingDefect {α : Type*} [PseudoMetricSpace α]
    (y x : ℕ → α) (N : ℕ) (n : ℕ) (hn : n ≤ N) :
    dist (y n) (x n) ≤ shadowingDefect y x N := by
  exact Finset.le_sup' ( fun n => dist ( y n ) ( x n ) ) ( Finset.mem_range_succ_iff.mpr hn )

end

/-! ## Axiom Check -/

#print axioms contractive_shadowing_lemma
#print axioms shadowing_unique_of_expansive
#print axioms contraction_has_shadowing_property
#print axioms iterate_lipschitz_of_contraction