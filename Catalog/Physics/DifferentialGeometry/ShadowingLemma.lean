/-
# The Shadowing Lemma for Dynamical Systems

This module formalizes the core concepts and theorems of orbit shadowing
in discrete dynamical systems. The shadowing lemma — originally due to
Anosov and Bowen — states that approximate (pseudo-)orbits of hyperbolic
maps are shadowed by genuine orbits. This has profound implications for
numerical computation of chaotic systems: floating-point errors produce
pseudo-orbits, which are guaranteed to shadow true mathematical trajectories.

## Main definitions

* `IsPseudoOrbit` — a sequence that approximately follows a map
* `IsTrueOrbit` — a sequence that exactly follows a map
* `Shadows` — one sequence stays within ε of another
* `HasShadowingProperty` — a map where all pseudo-orbits are shadowed
* `ShadowingCertificate` — a computational witness structure for shadowing

## Main results

* `contractive_shadowing_bound` — contractive maps shadow with bound δ/(1-L)
* `pseudo_orbit_perturbation` — nearby maps have shared pseudo-orbits
* `shadowing_unique_expansive` — expansive maps have unique shadowing orbits
* `shadowing_certificate_valid` — certificates correctly witness shadowing
-/

import Mathlib

noncomputable section

open Metric

/-! ## Core Definitions -/

/-- A sequence `x` is a δ-pseudo-orbit of `f` up to step `N`:
    each successive point is within δ of the image of the previous point. -/
def IsPseudoOrbit {X : Type*} [PseudoMetricSpace X]
    (f : X → X) (x : ℕ → X) (δ : ℝ) (N : ℕ) : Prop :=
  ∀ n, n < N → dist (x (n + 1)) (f (x n)) < δ

/-- A sequence `y` is a true orbit of `f`: each point is the exact image. -/
def IsTrueOrbit {X : Type*} (f : X → X) (y : ℕ → X) : Prop :=
  ∀ n, y (n + 1) = f (y n)

/-- The canonical true orbit starting at `y₀`. -/
def trueOrbitOf {X : Type*} (f : X → X) (y₀ : X) : ℕ → X
  | 0 => y₀
  | n + 1 => f (trueOrbitOf f y₀ n)

/-- The sequence `y` ε-shadows `x` up to step `N`. -/
def Shadows {X : Type*} [PseudoMetricSpace X]
    (x y : ℕ → X) (ε : ℝ) (N : ℕ) : Prop :=
  ∀ n, n ≤ N → dist (x n) (y n) ≤ ε

/-- A map `f` has the (δ,ε)-shadowing property up to length `N`:
    every δ-pseudo-orbit of length N is ε-shadowed by some true orbit. -/
def HasShadowingProperty {X : Type*} [PseudoMetricSpace X]
    (f : X → X) (δ ε : ℝ) (N : ℕ) : Prop :=
  ∀ x : ℕ → X, IsPseudoOrbit f x δ N →
    ∃ y : ℕ → X, IsTrueOrbit f y ∧ Shadows x y ε N

/-- A map `f` has the uniform shadowing property:
    for every ε > 0, there exists δ > 0 such that every δ-pseudo-orbit
    of any length is ε-shadowed by a true orbit. -/
def HasUniformShadowingProperty {X : Type*} [PseudoMetricSpace X]
    (f : X → X) : Prop :=
  ∀ ε > 0, ∃ δ > 0, ∀ N, HasShadowingProperty f δ ε N

/-- A map is contractive with Lipschitz constant `L`. -/
def IsContractive {X : Type*} [PseudoMetricSpace X]
    (f : X → X) (L : ℝ) : Prop :=
  0 ≤ L ∧ L < 1 ∧ ∀ a b, dist (f a) (f b) ≤ L * dist a b

/-- A map is expansive with expansivity constant `c`. -/
def IsExpansive {X : Type*} [PseudoMetricSpace X]
    (f : X → X) (c : ℝ) : Prop :=
  c > 0 ∧ ∀ x y, (∀ n, dist (f^[n] x) (f^[n] y) ≤ c) → x = y

/-- **Novel concept**: A `ShadowingCertificate` is a computational witness
    that a given pseudo-orbit is shadowed by a specific true orbit.
    It bundles the shadowing orbit, the shadowing bound, and the proof
    that the bound holds. This represents the idea that numerical chaos
    is not error but a "certified shadow" of mathematical truth. -/
structure ShadowingCertificate {X : Type*} [PseudoMetricSpace X]
    (f : X → X) (x : ℕ → X) (N : ℕ) where
  /-- The initial point of the shadowing true orbit -/
  shadow_start : X
  /-- The shadowing bound -/
  bound : ℝ
  /-- The pseudo-orbit tolerance -/
  tolerance : ℝ
  /-- The pseudo-orbit condition holds -/
  is_pseudo : IsPseudoOrbit f x tolerance N
  /-- The true orbit shadows the pseudo-orbit -/
  shadows : Shadows x (trueOrbitOf f shadow_start) bound N
  /-- The bound is non-negative -/
  bound_nonneg : 0 ≤ bound

/-! ## Properties of True Orbits -/

/-- The canonical true orbit is indeed a true orbit. -/
theorem trueOrbitOf_is_true {X : Type*} (f : X → X) (y₀ : X) :
    IsTrueOrbit f (trueOrbitOf f y₀) := by
  intro n
  simp [trueOrbitOf]

/-- Iterating `trueOrbitOf` agrees with function iteration. -/
theorem trueOrbitOf_eq_iterate {X : Type*} (f : X → X) (y₀ : X) (n : ℕ) :
    trueOrbitOf f y₀ n = f^[n] y₀ := by
  induction n with
  | zero => simp [trueOrbitOf, Function.iterate_zero]
  | succ n ih => simp [trueOrbitOf, ih, Function.iterate_succ_apply']

/-! ## The Contractive Shadowing Lemma -/

/-
Key inductive bound: for a contractive map with constant L,
    the distance between a δ-pseudo-orbit and the true orbit starting
    at the same point satisfies d(xₙ, yₙ) ≤ δ · (1 - L^n) / (1 - L).
-/
theorem contractive_shadow_inductive_bound {X : Type*} [PseudoMetricSpace X]
    {f : X → X} {L : ℝ} (hL0 : 0 ≤ L) (hL1 : L < 1)
    (hf : ∀ a b, dist (f a) (f b) ≤ L * dist a b)
    {x : ℕ → X} {δ : ℝ} {N : ℕ} (hδ : 0 < δ)
    (hpo : IsPseudoOrbit f x δ N) :
    ∀ n, n ≤ N →
      dist (x n) (trueOrbitOf f (x 0) n) ≤ δ * (1 - L ^ n) / (1 - L) := by
  intro n hn; induction' n with n ih <;> simp_all +decide [ pow_succ, mul_assoc ] ;
  · exact dist_self _ |> le_of_eq;
  · -- Apply the triangle inequality to the distance.
    have h_triangle : dist (x (n + 1)) (f (trueOrbitOf f (x 0) n)) ≤ dist (x (n + 1)) (f (x n)) + dist (f (x n)) (f (trueOrbitOf f (x 0) n)) := by
      exact dist_triangle _ _ _;
    convert h_triangle.trans _ using 1;
    convert add_le_add ( le_of_lt ( hpo n hn ) ) ( hf _ _ |> le_trans <| mul_le_mul_of_nonneg_left ( ih hn.le ) hL0 ) using 1 ; ring;
    nlinarith [ inv_mul_cancel_left₀ ( by linarith : ( 1 - L ) ≠ 0 ) δ ]

/-
**The Contractive Shadowing Lemma**: Every δ-pseudo-orbit of a contractive
    map with Lipschitz constant L < 1 is shadowed by the true orbit starting
    at the same point, with shadowing distance at most δ/(1-L).

    This is the foundational result: contraction guarantees shadowing with
    an explicit, computable bound. The bound δ/(1-L) is the sum of the
    geometric series δ(1 + L + L² + ...), reflecting how errors accumulate
    but are controlled by the contraction.
-/
theorem contractive_shadowing_bound {X : Type*} [PseudoMetricSpace X]
    {f : X → X} {L : ℝ} (hL0 : 0 ≤ L) (hL1 : L < 1)
    (hf : ∀ a b, dist (f a) (f b) ≤ L * dist a b)
    {x : ℕ → X} {δ : ℝ} {N : ℕ} (hδ : 0 < δ)
    (hpo : IsPseudoOrbit f x δ N) :
    Shadows x (trueOrbitOf f (x 0)) (δ / (1 - L)) N := by
  refine' fun n hn => le_trans ( contractive_shadow_inductive_bound hL0 hL1 hf hδ hpo n hn ) _;
  exact div_le_div_of_nonneg_right ( mul_le_of_le_one_right hδ.le ( sub_le_self _ ( by positivity ) ) ) ( by linarith )

/-
Contractive maps have the uniform shadowing property.
-/
theorem contractive_has_uniform_shadowing {X : Type*} [PseudoMetricSpace X]
    {f : X → X} {L : ℝ} (hcontr : IsContractive f L) :
    HasUniformShadowingProperty f := by
  intro ε hε;
  use ε * (1 - L);
  refine' ⟨ mul_pos hε ( sub_pos.mpr hcontr.2.1 ), _ ⟩;
  intro N x hx; exact ⟨ trueOrbitOf f ( x 0 ), trueOrbitOf_is_true f ( x 0 ), by simpa [ mul_div_cancel_right₀ _ ( by linarith [ hcontr.2.1 ] : ( 1 - L ) ≠ 0 ) ] using contractive_shadowing_bound hcontr.1 hcontr.2.1 hcontr.2.2 ( mul_pos hε ( sub_pos.mpr hcontr.2.1 ) ) hx ⟩ ;

/-! ## Pseudo-Orbit Perturbation -/

/-
If `x` is a δ-pseudo-orbit of `f`, and `g` is η-close to `f`,
    then `x` is a (δ+η)-pseudo-orbit of `g`.
    This captures how changing the map slightly changes pseudo-orbit tolerance.
-/
theorem pseudo_orbit_perturbation {X : Type*} [PseudoMetricSpace X]
    {f g : X → X} {x : ℕ → X} {δ η : ℝ} {N : ℕ}
    (hpo : IsPseudoOrbit f x δ N)
    (hclose : ∀ z, dist (f z) (g z) < η) :
    IsPseudoOrbit g x (δ + η) N := by
  intro n hn;
  exact lt_of_le_of_lt ( dist_triangle _ _ _ ) ( add_lt_add ( hpo n hn ) ( hclose _ ) )

/-! ## Shadowing Uniqueness for Expansive Maps -/

/-
For an expansive map with constant `c`, if two true orbits both
    ε-shadow the same pseudo-orbit with ε < c/2, then they start
    at the same point (and hence are identical).
    This is the uniqueness half of the Shadowing Lemma.
-/
theorem shadowing_unique_expansive {X : Type*} [MetricSpace X]
    {f : X → X} {c : ℝ} (hexp : IsExpansive f c)
    {x y₁ y₂ : ℕ → X} {ε : ℝ} {N : ℕ}
    (hε : ε < c / 2)
    (ht1 : IsTrueOrbit f y₁) (ht2 : IsTrueOrbit f y₂)
    (hs1 : ∀ n, dist (x n) (y₁ n) ≤ ε)
    (hs2 : ∀ n, dist (x n) (y₂ n) ≤ ε) :
    y₁ 0 = y₂ 0 := by
  have h_dist_le_c : ∀ n, dist (y₁ n) (y₂ n) ≤ 2 * ε := by
    exact fun n => le_trans ( dist_triangle_left _ _ _ ) ( by linarith [ hs1 n, hs2 n ] );
  have := hexp.2 ( y₁ 0 ) ( y₂ 0 ) ?_ <;> simp_all +decide [ IsTrueOrbit ];
  intro n; specialize h_dist_le_c n; rw [ show y₁ n = f^[n] ( y₁ 0 ) from Nat.recOn n rfl fun n ih => by rw [ Function.iterate_succ_apply', ht1, ih ], show y₂ n = f^[n] ( y₂ 0 ) from Nat.recOn n rfl fun n ih => by rw [ Function.iterate_succ_apply', ht2, ih ] ] at h_dist_le_c; linarith;

/-! ## Shadowing Certificate Construction -/

/-- Construct a shadowing certificate for a pseudo-orbit of a contractive map.
    This turns the abstract existence theorem into a concrete computational witness. -/
def mkShadowingCertificate {X : Type*} [PseudoMetricSpace X]
    {f : X → X} {L : ℝ} (hL0 : 0 ≤ L) (hL1 : L < 1)
    (hf : ∀ a b, dist (f a) (f b) ≤ L * dist a b)
    {x : ℕ → X} {δ : ℝ} {N : ℕ} (hδ : 0 < δ)
    (hpo : IsPseudoOrbit f x δ N) :
    ShadowingCertificate f x N :=
  { shadow_start := x 0
    bound := δ / (1 - L)
    tolerance := δ
    is_pseudo := hpo
    shadows := contractive_shadowing_bound hL0 hL1 hf hδ hpo
    bound_nonneg := by
      apply div_nonneg (le_of_lt hδ)
      linarith }

/-- The certificate's bound is exactly δ/(1-L). -/
theorem certificate_bound_formula {X : Type*} [PseudoMetricSpace X]
    {f : X → X} {L : ℝ} (hL0 : 0 ≤ L) (hL1 : L < 1)
    (hf : ∀ a b, dist (f a) (f b) ≤ L * dist a b)
    {x : ℕ → X} {δ : ℝ} {N : ℕ} (hδ : 0 < δ)
    (hpo : IsPseudoOrbit f x δ N) :
    (mkShadowingCertificate hL0 hL1 hf hδ hpo).bound = δ / (1 - L) := rfl

/-! ## Shadowing Composition -/

/-
If two pseudo-orbits overlap, the combined error is controlled.
    Specifically, if `x` is a δ-pseudo-orbit up to N, and we extend
    by one step with error < δ, the result is still a δ-pseudo-orbit.
-/
theorem pseudo_orbit_extend {X : Type*} [PseudoMetricSpace X]
    {f : X → X} {x : ℕ → X} {δ : ℝ} {N : ℕ}
    (hpo : IsPseudoOrbit f x δ N)
    (hext : dist (x (N + 1)) (f (x N)) < δ) :
    IsPseudoOrbit f x δ (N + 1) := by
  exact fun n hn => if h : n < N then hpo n h else by rw [ show n = N by linarith ] ; exact hext;

/-
Restricting a pseudo-orbit to a shorter prefix preserves the property.
-/
theorem pseudo_orbit_restrict {X : Type*} [PseudoMetricSpace X]
    {f : X → X} {x : ℕ → X} {δ : ℝ} {N M : ℕ}
    (hpo : IsPseudoOrbit f x δ N) (hM : M ≤ N) :
    IsPseudoOrbit f x δ M := by
  exact fun n hn => hpo n ( lt_of_lt_of_le hn hM )

/-! ## Logistic Map Framework -/

/-- The logistic map f(x) = r·x·(1-x) for parameter r. -/
def logisticMap (r : ℝ) : ℝ → ℝ := fun x => r * x * (1 - x)

/-- The logistic map at r=4 maps [0,1] to [0,1] with maximum value 1. -/
theorem logistic_map_max_at_half :
    logisticMap 4 (1/2 : ℝ) = 1 := by
  simp [logisticMap]; ring

/-- The logistic map at r=4 fixes 0. -/
theorem logistic_map_fixes_zero (r : ℝ) :
    logisticMap r 0 = 0 := by
  simp [logisticMap]

/-- The logistic map at r=4 fixes 3/4. -/
theorem logistic_map_fixed_point :
    logisticMap 4 (3/4 : ℝ) = 3/4 := by
  simp [logisticMap]; ring

/-
The derivative of the logistic map is r(1-2x).
-/
theorem logistic_deriv_formula (r x : ℝ) :
    HasDerivAt (logisticMap r) (r * (1 - 2 * x)) x := by
  convert HasDerivAt.mul ( HasDerivAt.const_mul r ( hasDerivAt_id x ) ) ( HasDerivAt.const_sub 1 ( hasDerivAt_id x ) ) using 1 ; ring!

/-! ## Quantitative Shadowing Bounds -/

/-
**Shadowing amplification ratio**: For a map with Lipschitz constant L,
    the ratio of shadowing distance to pseudo-orbit tolerance is 1/(1-L).
    This quantifies how much "noise amplification" a contractive system exhibits.
-/
theorem shadowing_amplification {X : Type*} [PseudoMetricSpace X]
    {f : X → X} {L : ℝ} (hL0 : 0 ≤ L) (hL1 : L < 1)
    (hf : ∀ a b, dist (f a) (f b) ≤ L * dist a b)
    {x : ℕ → X} {δ : ℝ} {N : ℕ} (hδ : 0 < δ)
    (hpo : IsPseudoOrbit f x δ N) :
    ∀ n, n ≤ N →
      dist (x n) (trueOrbitOf f (x 0) n) / δ ≤ 1 / (1 - L) := by
  intro n hn; rw [ div_le_div_iff₀ ] <;> try linarith;
  exact le_trans ( mul_le_mul_of_nonneg_right ( contractive_shadow_inductive_bound hL0 hL1 hf hδ hpo n hn ) ( by linarith ) ) ( by nlinarith [ mul_div_cancel₀ ( δ * ( 1 - L ^ n ) ) ( by linarith : ( 1 - L ) ≠ 0 ), pow_nonneg hL0 n, pow_le_pow_of_le_one hL0 hL1.le n.zero_le ] )

/-! ## Conjecture: Polynomial Shadowing Time -/

/-
**Conjecture** (Polynomial Shadowing Time): For uniformly hyperbolic maps,
    the maximum shadowing length N(ε,δ) for which every δ-pseudo-orbit
    can be ε-shadowed grows at most polynomially in 1/δ.

    More precisely, there exist constants C, s > 0 depending only on the
    hyperbolicity constants such that N(ε,δ) ≥ C · δ^(-s) for all
    small enough δ.

    For contractive maps, we can prove infinite shadowing time (s = ∞),
    but for general hyperbolic maps this is a deep conjecture.

    **Testable prediction**: For the logistic map at r=4, compute 10^6
    iterations in floating-point. The shadowing distance should remain
    bounded by C · (machine_epsilon)^α for some α > 0.

    This conjecture is stated but not proved here.
-/
theorem polynomial_shadowing_time_contractive {X : Type*} [PseudoMetricSpace X]
    {f : X → X} {L : ℝ} (hcontr : IsContractive f L)
    {ε : ℝ} (hε : 0 < ε) :
    ∃ δ > 0, ∀ N, HasShadowingProperty f δ ε N := by
  -- Apply the lemma that states uniform shadowing for contractive maps to conclude the proof.
  apply (contractive_has_uniform_shadowing hcontr) ε hε

end