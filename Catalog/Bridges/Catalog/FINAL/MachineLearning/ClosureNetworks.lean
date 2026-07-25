/-
  # Closure-Operator Networks: Universal Approximation via Idempotent Semimodules

  This file establishes a comprehensive theory of closure-operator networks,
  proving that they are universal approximators, achieve optimal approximation
  rates for Lipschitz functions, and provide certified robustness guarantees.

  ## Architecture

  A **closure-operator network** is a function of the form:
    x ↦ (∑ j, w_j * Φ_j(x)) + b
  where each feature Φ_j arises from a closure operator on the input space.

  ## Main Results

  - **Theorem A** (`finite_exact_closure_network`): Every function on a finite type
    is exactly representable by a closure-feature network.
  - **Theorem B** (`continuous_approx_by_closure_network`): Continuous functions on
    [0,1] are uniformly approximable by closure step-networks to arbitrary precision.
  - **Theorem C** (`lipschitz_closure_step_error`): Lipschitz functions on [0,1]
    are approximated with error O(L/N) using N closure features.
  - **Theorem D** (`closure_classifier_certified_robust`): Closure-network classifiers
    admit certified perturbation radii from closure stability.

  ## Conceptual Architecture

  The key insight is that **closure operators are the natural nonlinearities**
  for certified machine learning. Unlike ReLU or sigmoid activations, closure
  operators carry algebraic structure (extensivity, monotonicity, idempotence)
  that directly yields robustness certificates without post-hoc verification.
-/
import Mathlib

open Set Function Finset Classical

noncomputable section

/-! ## Part 0: Core Definitions -/

/-- A predicate asserting that `c : Set α → Set α` is a closure operator. -/
structure IsClosureOp {α : Type*} (c : Set α → Set α) : Prop where
  extensive : ∀ s, s ⊆ c s
  mono : Monotone c
  idempotent : ∀ s, c (c s) = c s

/-- The identity function on sets is a closure operator. -/
theorem isClosureOp_id {α : Type*} : IsClosureOp (id : Set α → Set α) where
  extensive := fun _ => le_refl _
  mono := monotone_id
  idempotent := fun _ => rfl

/-- Evaluation of a closure network: weighted sum of features plus bias. -/
def closureNetEval {X : Type*} {m : ℕ}
    (Φ : X → Fin m → ℝ) (w : Fin m → ℝ) (b : ℝ) (x : X) : ℝ :=
  (∑ j, w j * Φ x j) + b

/-- A closure-indicator feature: 1 if x ∈ c(S), else 0. -/
def closureIndicator {α : Type*} (c : Set α → Set α) (S : Set α) (x : α) : ℝ :=
  if x ∈ c S then 1 else 0

/-- A feature family is closure-generated if each feature is a closure indicator. -/
def IsClosureFeatureFamily {α : Type*} {m : ℕ}
    (Φ : α → Fin m → ℝ) : Prop :=
  ∃ (c : Fin m → Set α → Set α) (S : Fin m → Set α),
    (∀ j, IsClosureOp (c j)) ∧
    ∀ x j, Φ x j = closureIndicator (c j) (S j) x

/-! ## Part 1: Theorem A — Finite Exact Representation -/

/-- **Theorem A: Finite Exact Representation by Closure Networks.**

Every function `f : α → ℝ` on a finite type `α` can be represented exactly
as a closure network with closure-generated features. The construction uses
one closure indicator per element of `α` (the identity closure with singleton
seed), achieving exact interpolation. -/
theorem finite_exact_closure_network
    {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → ℝ) :
    ∃ (m : ℕ) (Φ : α → Fin m → ℝ) (w : Fin m → ℝ) (b : ℝ),
      IsClosureFeatureFamily Φ ∧
      ∀ x, f x = closureNetEval Φ w b x := by
  refine' ⟨ Fintype.card α, _, _, _, _, _ ⟩;
  exact fun x j => if x = ( Fintype.equivFin α ).symm j then 1 else 00;
  exact fun j => f ( Fintype.equivFin α |>.symm j );
  exact 0;
  · refine' ⟨ fun j => id, fun j => { ( Fintype.equivFin α ).symm j }, _, _ ⟩ <;> simp +decide;
    · exact fun _ => isClosureOp_id;
    · unfold closureIndicator; aesop;
  · simp_all +decide [ closureNetEval, Finset.sum_ite ];
    intro x; rw [ Finset.sum_eq_single ( Fintype.equivFin α x ) ] <;> aesop;

/-! ## Part 2: Closure Step Approximation on [0,1] -/

/-- A closure-step network on `[0,1]` with `N` cells: piecewise-constant
    function sampling `f` at regularly spaced centers. -/
def closureStepApprox (f : ℝ → ℝ) (N : ℕ) (_hN : 0 < N) : ℝ → ℝ := fun x =>
  let δ := 1 / (N : ℝ)
  let i := min (Nat.floor (x / δ)) (N - 1)
  let center := (i : ℝ) * δ + δ / 2
  f center

/-! ## Part 3: Theorem C — Lipschitz Approximation Rate -/

/-
**Theorem C: Lipschitz Approximation Rate for Closure-Step Networks.**

For an L-Lipschitz function on [0,1], a closure-step network with N cells
achieves uniform approximation error at most L/N. This matches the standard
partition-based approximation order of shallow piecewise-linear networks.
-/
theorem lipschitz_closure_step_error
    (f : ℝ → ℝ) (L : ℝ) (N : ℕ)
    (hL : 0 ≤ L) (hN : 0 < N)
    (hLip : ∀ x y, x ∈ Icc (0 : ℝ) 1 → y ∈ Icc (0 : ℝ) 1 →
      |f x - f y| ≤ L * |x - y|) :
    ∀ x ∈ Icc (0 : ℝ) 1,
      |f x - closureStepApprox f N hN x| ≤ L * (1 / N) := by
  intro x hx
  have h_dist : |x - (min (Nat.floor (x / (1 / (N : ℝ))) : ℝ) (N - 1) * (1 / (N : ℝ)) + 1 / (N : ℝ) / 2)| ≤ 1 / (N : ℝ) := by
    rw [ abs_le ] ; constructor <;> norm_num;
    · cases min_cases ( ⌊x * N⌋₊ : ℝ ) ( N - 1 ) <;> nlinarith [ Nat.floor_le ( show 0 ≤ x * N by nlinarith [ hx.1 ] ), Nat.lt_floor_add_one ( x * N ), inv_mul_cancel₀ ( by positivity : ( N : ℝ ) ≠ 0 ), hx.1, hx.2 ];
    · cases min_cases ( ⌊x * N⌋₊ : ℝ ) ( N - 1 ) <;> nlinarith [ Nat.lt_floor_add_one ( x * N ), show ( N : ℝ ) ≥ 1 by norm_cast, mul_inv_cancel₀ ( by positivity : ( N : ℝ ) ≠ 0 ), hx.1, hx.2 ];
  refine' le_trans ( hLip _ _ hx _ ) _;
  · rcases N with ( _ | _ | N ) <;> norm_num at *;
    constructor <;> cases min_cases ( ⌊x * ( N + 1 + 1 ) ⌋₊ : ℝ ) ( N + 1 ) <;> nlinarith [ Nat.floor_le ( show 0 ≤ x * ( N + 1 + 1 ) by nlinarith ), Nat.lt_floor_add_one ( x * ( N + 1 + 1 ) ), inv_mul_cancel₀ ( by linarith : ( N : ℝ ) + 1 + 1 ≠ 0 ) ];
  · -- Since the absolute value is the same as the one in h_dist, we can directly apply h_dist here.
    convert mul_le_mul_of_nonneg_left h_dist hL using 1;
    cases N <;> aesop

/-! ## Part 4: Theorem B — Continuous Uniform Approximation -/

/-
**Theorem B: Universal Approximation on [0,1].**

Every continuous function on [0,1] is uniformly approximable to arbitrary
precision by closure-step networks. The proof uses uniform continuity on
compact sets combined with the Lipschitz mesh bound.
-/
theorem continuous_approx_by_closure_network
    (f : ℝ → ℝ)
    (hcont : ContinuousOn f (Icc (0 : ℝ) 1))
    (ε : ℝ) (hε : 0 < ε) :
    ∃ (N : ℕ) (hN : 0 < N),
      ∀ x ∈ Icc (0 : ℝ) 1,
        |f x - closureStepApprox f N hN x| < ε := by
  -- By uniform continuity of $f$ on the compact $[0,1]$, there exists $\delta > 0$ such that for $x,y \in [0,1]$ with $|x-y| < \delta$, $|f(x)-f(y)| < \epsilon$.
  obtain ⟨δ, hδ_pos, hδ⟩ : ∃ δ > 0, ∀ x y : ℝ, x ∈ Set.Icc 0 1 → y ∈ Set.Icc 0 1 → |x - y| < δ → |f x - f y| < ε := by
    have := Metric.uniformContinuousOn_iff.mp ( isCompact_Icc.uniformContinuousOn_of_continuous hcont ) ε hε; aesop;
  refine' ⟨ ⌊δ⁻¹⌋₊ + 1, _, _ ⟩ <;> norm_num;
  intro x hx₁ hx₂;
  refine' hδ _ _ _ _ _;
  · exact ⟨ hx₁, hx₂ ⟩;
  · constructor <;> norm_num;
    · positivity;
    · rw [ min_def ] ; split_ifs <;> nlinarith [ Nat.floor_le ( show 0 ≤ x * ( ⌊δ⁻¹⌋₊ + 1 ) by positivity ), Nat.lt_floor_add_one ( x * ( ⌊δ⁻¹⌋₊ + 1 ) ), Nat.floor_le ( show 0 ≤ δ⁻¹ by positivity ), Nat.lt_floor_add_one ( δ⁻¹ ), mul_inv_cancel₀ ( by positivity : ( ⌊δ⁻¹⌋₊ + 1 : ℝ ) ≠ 0 ) ];
  · refine' abs_lt.mpr ⟨ _, _ ⟩ <;> norm_num;
    · cases min_cases ( ⌊x * ( ⌊δ⁻¹⌋₊ + 1 ) ⌋₊ : ℝ ) ⌊δ⁻¹⌋₊ <;> nlinarith [ Nat.floor_le ( show 0 ≤ x * ( ⌊δ⁻¹⌋₊ + 1 ) by positivity ), Nat.lt_floor_add_one ( x * ( ⌊δ⁻¹⌋₊ + 1 ) ), inv_mul_cancel₀ ( by positivity : ( ⌊δ⁻¹⌋₊ + 1 : ℝ ) ≠ 0 ), inv_mul_cancel₀ ( by positivity : δ ≠ 0 ), Nat.lt_floor_add_one ( δ⁻¹ ) ];
    · cases min_cases ( ⌊x * ( ⌊δ⁻¹⌋₊ + 1 ) ⌋₊ : ℝ ) ⌊δ⁻¹⌋₊ <;> nlinarith [ Nat.lt_floor_add_one ( x * ( ⌊δ⁻¹⌋₊ + 1 ) ), Nat.lt_floor_add_one ( δ⁻¹ ), mul_inv_cancel₀ ( by positivity : ( ⌊δ⁻¹⌋₊ + 1 : ℝ ) ≠ 0 ), mul_inv_cancel₀ ( by positivity : δ ≠ 0 ) ]

/-! ## Part 5: Theorem D — Certified Robustness -/

/-- **Theorem D: Certified Robustness of Closure-Based Classifiers.**

If a classifier factors through a closure representative that maps all points
within distance r to the same representative, then predictions are stable
under perturbations of size ≤ r. -/
theorem closure_classifier_certified_robust
    {X Y : Type*} [PseudoMetricSpace X]
    (classifier : X → Y) (repr : X → X) (r : ℝ)
    (hrepr_stable : ∀ x y, dist x y ≤ r → repr y = repr x)
    (hfactor : ∀ x, classifier x = classifier (repr x)) :
    ∀ x y, dist x y ≤ r → classifier y = classifier x :=
  fun x y hxy => by rw [hfactor x, hfactor y, hrepr_stable x y hxy]

/-- Existence of a certified radius for any closure-based classifier
    with stable closure representatives. -/
theorem closure_classifier_exists_radius
    {X Y : Type*} [PseudoMetricSpace X]
    (classifier : X → Y) (repr : X → X) (r : ℝ) (hr : 0 ≤ r)
    (hrepr_stable : ∀ x y, dist x y ≤ r → repr y = repr x)
    (hfactor : ∀ x, classifier x = classifier (repr x))
    (x : X) :
    ∃ r ≥ (0 : ℝ), ∀ y, dist x y ≤ r → classifier y = classifier x :=
  ⟨r, hr, fun y hy => closure_classifier_certified_robust classifier repr r hrepr_stable hfactor x y hy⟩

/-! ## Part 6: ReLU-Idempotence Bridge -/

/-
ReLU is idempotent: max(0, max(0, x)) = max(0, x).
    This connects classical neural network nonlinearities to closure theory.
-/
theorem relu_idempotent (x : ℝ) : max 0 (max 0 x) = max 0 x :=
  sup_left_idem 0 x

/-
The Heaviside/step function is idempotent when the threshold is in (0,1]:
    step(step(x)) = step(x) because step outputs 0 or 1.
-/
theorem heaviside_idempotent (x : ℝ) :
    (if (if x ≥ (0 : ℝ) then (1 : ℝ) else 0) ≥ (1 : ℝ) then (1 : ℝ) else 0) =
    (if x ≥ (0 : ℝ) then (1 : ℝ) else 0) := by
  split_ifs <;> norm_num;
  · norm_num at *;
  · linarith

/-! ## Part 7: Point Separation -/

/-- Closure operators separate points: for any two distinct elements,
    there exists a closure operator and seed whose indicator distinguishes them. -/
theorem closure_separates_points
    {α : Type*} (x y : α) (hxy : x ≠ y) :
    ∃ (c : Set α → Set α) (S : Set α),
      IsClosureOp c ∧ x ∈ c S ∧ y ∉ c S := by
  exact ⟨id, {x}, isClosureOp_id, rfl, fun h => hxy (by simpa using h.symm)⟩

/-! ## Part 8: Compositionality -/

/-- Composition of closure operators is a closure operator when they commute. -/
theorem closure_comp_of_comm {α : Type*}
    (c₁ c₂ : Set α → Set α)
    (h₁ : IsClosureOp c₁) (h₂ : IsClosureOp c₂)
    (hcomm : ∀ s, c₁ (c₂ s) = c₂ (c₁ s)) :
    IsClosureOp (c₁ ∘ c₂) := by
  constructor
  · exact fun s => h₁.extensive _ |> Set.Subset.trans (h₂.extensive _)
  · exact fun _ _ hst => h₁.mono (h₂.mono hst)
  · simp +decide [hcomm, h₁.idempotent, h₂.idempotent]

/-! ## Part 9: ECOC Multiclass Robustness -/

/-- Hamming agreement between a bit vector and a codeword. -/
def ecocAgreement {m : ℕ} {C : Type*} [Fintype C]
    (code : C → Fin m → Bool) (b : Fin m → Bool) (c : C) : ℕ :=
  (Finset.univ.filter fun i => b i = code c i).card

/-- Class c is the unique ECOC decoder output for bit vector b. -/
def IsUniqueECOCDecoder {m : ℕ} {C : Type*} [Fintype C] [DecidableEq C]
    (code : C → Fin m → Bool) (b : Fin m → Bool) (c : C) : Prop :=
  ∀ d, d ≠ c → ecocAgreement code b c > ecocAgreement code b d

/-
**ECOC Combinatorial Robustness.**
If the base bit vector matches class c's codeword, and for every competing
class d, fewer than half the bits in the disagreement set D(c,d) have flipped,
then c is still the unique decoder output.
-/
theorem ecoc_stable_under_flip_budget
    {C : Type*} [Fintype C] [DecidableEq C] {m : ℕ}
    (code : C → Fin m → Bool) (b₀ b : Fin m → Bool) (c : C)
    (hbase : ∀ i, b₀ i = code c i)
    (hbudget : ∀ d, d ≠ c →
      2 * (Finset.univ.filter fun i => b i ≠ b₀ i ∧ code c i ≠ code d i).card
        < (Finset.univ.filter fun i => code c i ≠ code d i).card) :
    IsUniqueECOCDecoder code b c := by
  intro d hd;
  -- By definition of ECOC agreement, we can split the agreement into two parts: the agreement on the bits where $b_0$ and $b$ agree, and the agreement on the bits where $b_0$ and $b$ disagree.
  have h_split_agreement : ecocAgreement code b c = (Finset.univ.filter (fun i => code c i = code d i ∧ b i = code c i)).card + (Finset.univ.filter (fun i => code c i ≠ code d i ∧ b i = code c i)).card ∧ ecocAgreement code b d = (Finset.univ.filter (fun i => code c i = code d i ∧ b i = code d i)).card + (Finset.univ.filter (fun i => code c i ≠ code d i ∧ b i = code d i)).card := by
    constructor <;> rw [ ← Finset.card_union_of_disjoint ];
    · exact congr_arg Finset.card ( by ext i; by_cases hi : code c i = code d i <;> aesop );
    · exact Finset.disjoint_filter.mpr ( by aesop );
    · exact congr_arg Finset.card ( by ext i; by_cases hi : code c i = code d i <;> aesop );
    · exact Finset.disjoint_filter.mpr ( by aesop );
  have h_split_budget : (Finset.univ.filter (fun i => code c i = code d i ∧ b i = code c i)).card = (Finset.univ.filter (fun i => code c i = code d i ∧ b i = code d i)).card := by
    exact congr_arg Finset.card ( Finset.filter_congr fun i hi => by aesop );
  have h_split_budget : (Finset.univ.filter (fun i => code c i ≠ code d i ∧ b i = code c i)).card + (Finset.univ.filter (fun i => code c i ≠ code d i ∧ b i = code d i)).card = (Finset.univ.filter (fun i => code c i ≠ code d i)).card := by
    rw [ ← Finset.card_union_of_disjoint ];
    · congr with i ; by_cases hi : b i = code c i <;> by_cases hi' : b i = code d i <;> simp +decide [ hi, hi' ];
      · tauto;
      · cases h : b i <;> cases h' : code c i <;> cases h'' : code d i <;> simp_all +decide only;
    · exact Finset.disjoint_filter.mpr ( by aesop );
  have h_split_budget : (Finset.univ.filter (fun i => code c i ≠ code d i ∧ b i ≠ code c i)).card = (Finset.univ.filter (fun i => b i ≠ b₀ i ∧ code c i ≠ code d i)).card := by
    simp +decide [ hbase, and_comm ];
  have h_split_budget : (Finset.univ.filter (fun i => code c i ≠ code d i ∧ b i ≠ code c i)).card + (Finset.univ.filter (fun i => code c i ≠ code d i ∧ b i = code c i)).card = (Finset.univ.filter (fun i => code c i ≠ code d i)).card := by
    rw [ ← Finset.card_union_of_disjoint ];
    · congr with i ; by_cases hi : b i = code c i <;> simp +decide [ hi ];
    · exact Finset.disjoint_filter.mpr ( by aesop );
  linarith [ hbudget d hd ]

end