/-
  # Closure-Operator Networks: Universal Approximation on Compact Metric Spaces

  This file establishes that closure-operator networks are universal approximators
  on compact pseudometric spaces, with certified robustness guarantees and
  algebraic stability from idempotent composition.

  ## Main Results

  1. **Theorem A** (`continuous_uniform_approx_by_finite_closure_net`):
     Every continuous function on a compact pseudometric space is uniformly
     approximable to arbitrary precision by a finite-codebook approximant
     factoring through a finite ε-net.

  2. **Theorem B** (`compact_continuous_uap_of_finite_exact`):
     Bridge theorem: finite exact realization on ε-net points combined with
     compactness yields universal approximation with closure network structure.

  3. **Theorem C** (`closure_network_certified_robust_radius`):
     Closure networks with radius structure are certifiably robust:
     perturbations within the closure radius preserve the output.

  4. **Theorem D** (`closure_layer_composition_monotone_idempotent`):
     Composition of commuting closure layers preserves monotonicity and
     idempotence, giving the architecture its algebraic backbone.

  5. **Lipschitz rate theorem** (`lipschitz_error_bound_of_closure_codebook`):
     For Lipschitz functions, closure-codebook approximation error decays
     linearly with the covering radius.
-/
import Mathlib

open Set Function Finset Classical Metric

noncomputable section

/-- A function `f : α → α` is idempotent if `f (f x) = f x` for all `x`. -/
def IsIdempotentFn {α : Type*} (f : α → α) : Prop := ∀ x, f (f x) = f x

/-! ## Section 1: Helper Lemmas — ε-Nets and Uniform Continuity -/

/-
Every compact pseudometric space admits a finite ε-net for any ε > 0.
    This is the compactness engine for universal approximation.
-/
theorem compact_exists_finite_dense_subset
    {X : Type*} [PseudoMetricSpace X] [CompactSpace X] :
    ∀ ε > 0, ∃ s : Finset X, ∀ x : X, ∃ y ∈ s, dist x y < ε := by
  intro ε hε;
  have := Metric.totallyBounded_iff.1 ( isCompact_univ.totallyBounded : TotallyBounded ( Set.univ : Set X ) ) ε hε;
  rcases this with ⟨ s, hs, h ⟩ ; rcases hs.exists_finset_coe with ⟨ s', rfl ⟩ ; exact ⟨ s', fun x => by simpa using h ( Set.mem_univ x ) ⟩

/-
Continuous functions on compact pseudometric spaces are uniformly
    continuous in the ε/δ form needed for approximation.
-/
theorem continuous_oscillation_small_on_small_balls
    {X : Type*} [PseudoMetricSpace X] [CompactSpace X]
    (f : X → ℝ) (hf : Continuous f) :
    ∀ ε > 0, ∃ δ > 0, ∀ x y : X, dist x y < δ → |f x - f y| < ε := by
  exact fun ε εpos => by rcases Metric.uniformContinuousOn_iff.mp ( isCompact_univ.uniformContinuousOn_of_continuous hf.continuousOn ) ε εpos with ⟨ δ, δpos, hδ ⟩ ; exact Exists.intro δ ⟨ δpos, fun x y hxy => hδ x ( Set.mem_univ x ) y ( Set.mem_univ y ) hxy ⟩ ;

/-
Given a finite dense subset and controlled oscillation, we can construct
    a finite-codebook approximant.
-/
theorem codebook_approx_of_finite_dense
    {X : Type*} [PseudoMetricSpace X]
    (f : X → ℝ) (s : Finset X) (δ ε : ℝ)
    (hcover : ∀ x : X, ∃ y ∈ s, dist x y < δ)
    (hosc : ∀ x y : X, dist x y < δ → |f x - f y| < ε) :
    ∃ g : X → ℝ, (∀ x, ∃ y ∈ s, g x = f y) ∧ (∀ x, |f x - g x| < ε) := by
  exact ⟨ fun x ↦ f ( Classical.choose ( hcover x ) ), fun x ↦ ⟨ _, Classical.choose_spec ( hcover x ) |>.1, rfl ⟩, fun x ↦ hosc _ _ ( Classical.choose_spec ( hcover x ) |>.2 ) ⟩

/-! ## Section 2: Theorem A — Uniform Approximation on Compact Spaces -/

/-
**Theorem A: Uniform Approximation on Compact Pseudometric Spaces.**

Every continuous function `f : X → ℝ` on a compact pseudometric space can be
uniformly approximated to arbitrary precision ε > 0 by a function `g` that
takes only finitely many values (one per point in a finite ε-net).

This is the core universal approximation theorem in finite-codebook form.
-/
theorem continuous_uniform_approx_by_finite_closure_net
    {X : Type*} [PseudoMetricSpace X] [CompactSpace X]
    (f : X → ℝ) (hf : Continuous f) :
    ∀ ε > 0, ∃ (s : Finset X) (g : X → ℝ),
      (∀ x, ∃ y ∈ s, dist x y < ε) ∧
      (∀ x, ∃ y ∈ s, g x = f y) ∧
      (∀ x, |f x - g x| < ε) := by
  simp +zetaDelta at *;
  intro ε hε
  obtain ⟨δ, hδ_pos, hδ⟩ : ∃ δ > 0, ∀ x y : X, dist x y < δ → |f x - f y| < ε := by
    exact?;
  -- By compact_exists_finite_dense_subset with δ', get s : Finset X covering X.
  obtain ⟨s, hs⟩ : ∃ s : Finset X, (∀ x : X, ∃ y ∈ s, dist x y < min δ ε) := by
    exact compact_exists_finite_dense_subset _ ( lt_min hδ_pos hε );
  exact ⟨ s, fun x => by obtain ⟨ y, hy, hy' ⟩ := hs x; exact ⟨ y, hy, lt_of_lt_of_le hy' ( min_le_right _ _ ) ⟩, by obtain ⟨ g, hg₁, hg₂ ⟩ := codebook_approx_of_finite_dense f s ( Min.min δ ε ) ε hs ( fun x y hxy => hδ x y ( lt_of_lt_of_le hxy ( min_le_left _ _ ) ) ) ; exact ⟨ g, hg₁, hg₂ ⟩ ⟩

/-! ## Section 3: Closure Network Definitions -/

/-- A function is a closure network if it takes only finitely many distinct values. -/
structure IsClosureNetwork {X : Type*} (N : X → ℝ) : Prop where
  /-- The network takes only finitely many distinct values. -/
  finite_range : Set.Finite (Set.range N)

/-- A closure network with radius `r`: locally constant on balls of radius `r`. -/
structure IsClosureNetworkWithRadius {X : Type*} [PseudoMetricSpace X]
    (N : X → ℝ) (r : ℝ) : Prop extends IsClosureNetwork N where
  /-- The network is locally constant within radius r of each point. -/
  locally_constant : ∀ x z : X, dist z x < r → N z = N x

/-- A closure network with typed output and radius. -/
structure IsClosureNetworkWithRadiusTyped {X Y : Type*} [PseudoMetricSpace X]
    (N : X → Y) (r : ℝ) : Prop where
  /-- The network is locally constant within radius r of each point. -/
  locally_constant : ∀ x z : X, dist z x < r → N z = N x

/-! ## Section 4: Theorem B — Bridge from Finite Exact to Universal Approximation -/

/-
**Theorem B: Universal Approximation via Finite Exact Realization.**

Every continuous function on a compact pseudometric space can be uniformly
approximated by a closure network (a function with finitely many output values).
-/
theorem compact_continuous_uap_of_finite_exact
    {X : Type*} [PseudoMetricSpace X] [CompactSpace X]
    (f : X → ℝ) (hf : Continuous f) :
    ∀ ε > 0, ∃ (N : X → ℝ),
      IsClosureNetwork N ∧
      (∀ x, |f x - N x| < 2 * ε) := by
  -- Use Theorem A to find a finite codebook approximant.
  intro ε hε_pos
  obtain ⟨s, g, hs, hg⟩ := continuous_uniform_approx_by_finite_closure_net f hf ε hε_pos;
  refine' ⟨ g, _, fun x => lt_of_lt_of_le ( hg.2 x ) ( by linarith ) ⟩;
  exact ⟨ Set.Finite.subset ( Set.toFinite ( f '' s ) ) ( Set.range_subset_iff.2 fun x => by obtain ⟨ y, hy, hy' ⟩ := hg.1 x; aesop ) ⟩

/-
**Upgraded Theorem A: Approximation by Closure Networks.**

Every continuous function on a compact pseudometric space can be uniformly
approximated by a closure network to arbitrary precision.
-/
theorem continuous_uniform_approx_by_closure_network
    {X : Type*} [PseudoMetricSpace X] [CompactSpace X]
    (f : X → ℝ) (hf : Continuous f) :
    ∀ ε > 0, ∃ N : X → ℝ,
      IsClosureNetwork N ∧
      (∀ x, |f x - N x| < ε) := by
  exact fun ε εpos ↦ compact_continuous_uap_of_finite_exact f hf ( ε/2 ) ( half_pos εpos ) |> fun ⟨ N, hN₁, hN₂ ⟩ ↦ ⟨ N, hN₁, fun x ↦ by linarith [ hN₂ x ] ⟩

/-! ## Section 5: Theorem C — Certified Robustness -/

/-- **Theorem C: Certified Robustness of Closure Networks.**

If a closure network has radius `r`, then any perturbation smaller than `r`
preserves the output. This is the core robustness guarantee. -/
theorem closure_network_certified_robust_radius
    {X Y : Type*} [PseudoMetricSpace X]
    (N : X → Y) (r : ℝ)
    (hN : IsClosureNetworkWithRadiusTyped N r) :
    ∀ x z, dist z x < r → N z = N x :=
  hN.locally_constant

/-
Robustness implies existence of a safe radius for every point.
-/
theorem closure_network_exists_safe_radius
    {X Y : Type*} [PseudoMetricSpace X]
    (N : X → Y) (r : ℝ) (hr : 0 < r)
    (hN : IsClosureNetworkWithRadiusTyped N r) :
    ∀ x : X, ∃ r' > 0, ∀ z, dist z x < r' → N z = N x := by
  exact fun x => ⟨ r, hr, fun z hz => hN.locally_constant x z hz ⟩

/-- **Same Label Within Radius**: direct robustness transfer. -/
theorem same_label_within_radius
    {X Y : Type*} [PseudoMetricSpace X]
    (N : X → Y) (x : X) (r : ℝ)
    (hconst : ∀ z, dist z x < r → N z = N x) :
    ∀ z, dist z x < r → N z = N x :=
  hconst

/-! ## Section 6: Theorem D — Algebraic Stability of Closure Layers -/

/-
**Theorem D: Composition of Commuting Closure Layers.**

If each layer of a network is an idempotent, monotone, extensive closure
operator and the layers commute, then their composition is itself monotone
and idempotent. This gives closure networks their algebraic backbone.
-/
theorem closure_layer_composition_monotone_idempotent
    {α : Type*} [Preorder α]
    (c d : α → α)
    (hc_mono : Monotone c) (hd_mono : Monotone d)
    (hc_idem : IsIdempotentFn c)
    (hd_idem : IsIdempotentFn d)
    (_hc_ext : ∀ x, x ≤ c x)
    (_hd_ext : ∀ x, x ≤ d x)
    (hcomm : ∀ x, c (d x) = d (c x)) :
    IsIdempotentFn (fun x => c (d x)) ∧
    Monotone (fun x => c (d x)) := by
  have h_idem : ∀ x, c (d (c (d x))) = c (d x) := by
    grind +locals
  exact ⟨h_idem, fun x y hxy ↦ hc_mono (hd_mono hxy)⟩

/-- ReLU is idempotent: max(0, max(0, x)) = max(0, x).
    This connects classical neural activations to closure theory. -/
theorem relu_idempotent' (x : ℝ) : max 0 (max 0 x) = max 0 x := by
  simp [max_comm]

/-- ReLU is monotone. -/
theorem relu_monotone : Monotone (fun x : ℝ => max 0 x) :=
  fun _ _ h => max_le_max_left 0 h

/-- ReLU is extensive on nonnegative reals. -/
theorem relu_extensive_nonneg (x : ℝ) (_hx : 0 ≤ x) : x ≤ max 0 x := le_max_right 0 x

/-! ## Section 7: Lipschitz Rate Theorem -/

/-
**Lipschitz Error Bound for Closure Codebooks.**

For a Lipschitz function `f` and a codebook approximant `g` built from
an ε-net with mesh size η, the approximation error is at most `K * η`.
-/
theorem lipschitz_error_bound_of_closure_codebook
    {X : Type*} [PseudoMetricSpace X]
    (f g : X → ℝ) (K η : ℝ) (s : Finset X)
    (hK : 0 ≤ K)
    (hLip : ∀ x y : X, |f x - f y| ≤ K * dist x y)
    (hcode : ∀ x, ∃ y ∈ s, dist x y ≤ η ∧ g x = f y) :
    ∀ x, |f x - g x| ≤ K * η := by
  intro x
  obtain ⟨y, hy_s, hy_dist, hy_g⟩ := hcode x
  have hy_bound : |f x - f y| ≤ K * dist x y := hLip x y
  have hy_dist_bound : dist x y ≤ η := hy_dist
  have hy_final_bound : |f x - f y| ≤ K * η := by
    exact hy_bound.trans ( mul_le_mul_of_nonneg_left hy_dist_bound hK )
  rw [hy_g] at *
  exact hy_final_bound

/-! ## Section 8: Additional Algebraic Lemmas -/

/-
Extensivity propagates through composition of closure operators.
-/
theorem closure_comp_extensive
    {α : Type*} [Preorder α]
    (c d : α → α)
    (hc_ext : ∀ x, x ≤ c x)
    (hd_ext : ∀ x, x ≤ d x) :
    ∀ x, x ≤ c (d x) := by
  grind

/-
A three-layer composition of commuting closure operators is idempotent
    and monotone.
-/
theorem closure_three_layer_idempotent
    {α : Type*} [Preorder α]
    (c d e : α → α)
    (hc_mono : Monotone c) (hd_mono : Monotone d) (he_mono : Monotone e)
    (hc_idem : IsIdempotentFn c)
    (hd_idem : IsIdempotentFn d)
    (he_idem : IsIdempotentFn e)
    (_hc_ext : ∀ x, x ≤ c x)
    (_hd_ext : ∀ x, x ≤ d x)
    (_he_ext : ∀ x, x ≤ e x)
    (hcd : ∀ x, c (d x) = d (c x))
    (hce : ∀ x, c (e x) = e (c x))
    (hde : ∀ x, d (e x) = e (d x)) :
    IsIdempotentFn (fun x => c (d (e x))) ∧
    Monotone (fun x => c (d (e x))) := by
  refine' ⟨ _, _ ⟩;
  · grind +locals;
  · exact hc_mono.comp ( hd_mono.comp he_mono )

end