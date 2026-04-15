/-! # CatalogBuild.Computation.Oracles.ThreeDreams

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 30
-/

import Mathlib

noncomputable section

/-- A deductive system: a set of sentences with a monotone, extensive,
idempotent closure operator (Tarski-style consequence). -/
structure DeductiveSystem (α : Type*) where
  /-- The closure (consequence) operator -/
  cl : Set α → Set α
  /-- Closure is extensive: A ⊆ Cl(A) -/
  extensive : ∀ A, A ⊆ cl A
  /-- Closure is monotone: A ⊆ B → Cl(A) ⊆ Cl(B) -/
  monotone : ∀ A B, A ⊆ B → cl A ⊆ cl B
  /-- Closure is idempotent: Cl(Cl(A)) = Cl(A) -/
  idempotent : ∀ A, cl (cl A) = cl A

/-- The emergent content of combining two theories T₁ and T₂:
    sentences in Cl(T₁ ∪ T₂) that are not in Cl(T₁) ∪ Cl(T₂). -/

def emergentContent {α : Type*} (D : DeductiveSystem α) (T₁ T₂ : Set α) : Set α :=
  D.cl (T₁ ∪ T₂) \ (D.cl T₁ ∪ D.cl T₂)

/-
PROBLEM
Emergent content is a subset of the combined closure.

PROVIDED SOLUTION
Unfold emergentContent. It's a set difference, so elements are in the first set by definition.
-/

theorem emergent_subset_combined {α : Type*} (D : DeductiveSystem α) (T₁ T₂ : Set α) :
    emergentContent D T₁ T₂ ⊆ D.cl (T₁ ∪ T₂) := by
  exact Set.diff_subset

/-
PROBLEM
If T₁ ⊆ T₂, the emergent content is empty (subsumption kills emergence).

PROVIDED SOLUTION
If T₁ ⊆ T₂, then T₁ ∪ T₂ = T₂ (by Set.union_eq_right.mpr h), so Cl(T₁ ∪ T₂) = Cl(T₂). But Cl(T₂) ⊆ Cl(T₁) ∪ Cl(T₂), so the set difference is empty.
-/

theorem emergent_empty_of_subset {α : Type*} (D : DeductiveSystem α) (T₁ T₂ : Set α)
    (h : T₁ ⊆ T₂) : emergentContent D T₁ T₂ = ∅ := by
  -- Since $T₁ \subseteq T₂$, we have $T₁ ∪ T₂ = T₂$.
  have h_union : T₁ ∪ T₂ = T₂ := by
    exact Set.union_eq_right.mpr h;
  -- Substitute $T₁ ∪ T₂ = T₂$ into the definition of emergent content.
  simp [h_union, emergentContent];
  aesop_cat

/-
PROBLEM
The combined closure always contains both individual closures.

PROVIDED SOLUTION
Use D.monotone. T₁ ⊆ T₁ ∪ T₂ so Cl(T₁) ⊆ Cl(T₁ ∪ T₂). Similarly for T₂. Then union of subsets is subset.
-/

theorem combined_contains_parts {α : Type*} (D : DeductiveSystem α) (T₁ T₂ : Set α) :
    D.cl T₁ ∪ D.cl T₂ ⊆ D.cl (T₁ ∪ T₂) := by
  exact Set.union_subset ( D.monotone _ _ ( Set.subset_union_left ) ) ( D.monotone _ _ ( Set.subset_union_right ) )

/-- A theory pair exhibits interference if its emergent content is nonempty. -/

def exhibitsInterference {α : Type*} (D : DeductiveSystem α) (T₁ T₂ : Set α) : Prop :=
  (emergentContent D T₁ T₂).Nonempty

/-- An interference system: a deductive system where we can control
    the amount of emergent content via a "vocabulary overlap" parameter. -/

structure InterferenceSystem extends DeductiveSystem ℕ where
  /-- For each overlap size n, there exist theories with at least n emergent truths -/
  interference_growth : ∀ n : ℕ, ∃ T₁ T₂ : Set ℕ,
    ∃ S : Finset ℕ, S.card ≥ n ∧ ↑S ⊆ emergentContent toDeductiveSystem T₁ T₂

/-- In an interference system, the emergent content is unbounded. -/

theorem interference_unbounded (I : InterferenceSystem) :
    ∀ n : ℕ, ∃ T₁ T₂ : Set ℕ, ∃ S : Finset ℕ,
      S.card ≥ n ∧ ↑S ⊆ emergentContent I.toDeductiveSystem T₁ T₂ :=
  I.interference_growth

/-! ### Interference Counting Theorem -/

/-- A theory with explicit finite axiom count and shared vocabulary. -/

structure FiniteTheoryPair where
  /-- Size of theory 1's axioms -/
  size₁ : ℕ
  /-- Size of theory 2's axioms -/
  size₂ : ℕ
  /-- Size of shared vocabulary -/
  sharedVocab : ℕ
  /-- Number of emergent truths -/
  emergentCount : ℕ
  /-- Emergent truths grow at least quadratically in shared vocabulary -/
  quadratic_growth : emergentCount ≥ sharedVocab * sharedVocab

/-- The interference ratio: fraction of combined theorems that are emergent -/

def interferenceRatio (p : FiniteTheoryPair) : ℚ :=
  if p.size₁ + p.size₂ + p.emergentCount = 0 then 0
  else p.emergentCount / (p.size₁ + p.size₂ + p.emergentCount)

/-
PROBLEM
The interference ratio is nonnegative.

PROVIDED SOLUTION
Unfold interferenceRatio. In the if-true branch it's 0. In the if-false branch, both numerator and denominator are natural number casts, hence nonneg. Use div_nonneg and Nat.cast_nonneg.
-/

theorem interferenceRatio_nonneg (p : FiniteTheoryPair) :
    0 ≤ interferenceRatio p := by
  unfold interferenceRatio; positivity;

/-! ═══════════════════════════════════════════════════════════════════════════
    DREAM 7: THE DEPTH-VALUE DUALITY
    "The most valuable theorems live at intermediate depth."

    We model theorem value as V(d) = d^α · e^{-βd}, a Gamma-like distribution.
    The unique maximum occurs at d* = α/β, the "sweet spot."
    ═══════════════════════════════════════════════════════════════════════════ -/

/-- The value function for a theorem at depth d, parameterized by α and β.
    V(d) = d^α · exp(-β·d) -/

def theoremValue (a b d : ℝ) : ℝ := d ^ a * Real.exp (-b * d)

/-
PROBLEM
The value function is zero at depth zero (trivial theorems have no value).

PROVIDED SOLUTION
theoremValue a b 0 = 0^a * exp(-b*0). Since a > 0, 0^a = 0 (use zero_rpow with ne_of_gt ha). Then 0 * anything = 0.
-/

theorem value_zero_at_origin (a b : ℝ) (ha : 0 < a) :
    theoremValue a b 0 = 0 := by
  unfold theoremValue; norm_num [ ha.ne' ]

/-
PROBLEM
The value function approaches zero as depth → ∞.

PROVIDED SOLUTION
theoremValue a b d = d^a * exp(-b*d). As d → ∞, exp(-b*d) → 0 exponentially while d^a grows polynomially. The product tends to 0. Use tendsto_rpow_mul_exp_neg_mul_atTop_nhds_zero or a similar Mathlib lemma about polynomial times exponential decay.
-/

theorem value_tendsto_zero (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    Filter.Tendsto (fun d => theoremValue a b d) Filter.atTop (nhds 0) := by
  -- Let $y = bd$, therefore the limit becomes $\lim_{y \to \infty} \left(\frac{y}{b}\right)^a e^{-y}$.
  suffices h_change_var : Filter.Tendsto (fun y => (y / b) ^ a * Real.exp (-y)) Filter.atTop (nhds 0) by
    convert h_change_var.comp ( Filter.tendsto_id.const_mul_atTop hb ) using 2 ; norm_num [ theoremValue ] ; ring;
    rw [ mul_right_comm, mul_inv_cancel₀ hb.ne', one_mul ];
  -- We can factor out $y^a$ and use the fact that $\exp(-y)$ tends to $0$ as $y$ tends to infinity.
  suffices h_factor : Filter.Tendsto (fun y => y ^ a * Real.exp (-y)) Filter.atTop (nhds 0) by
    have := h_factor.div_const ( b ^ a ) ; simp_all +decide [ Real.div_rpow, hb.le ] ;
    refine this.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with x hx using by rw [ Real.div_rpow hx.le hb.le ] ; ring );
  have := Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero ( ⌈a⌉₊ : ℕ );
  refine' squeeze_zero_norm' _ this;
  filter_upwards [ Filter.eventually_gt_atTop 1 ] with x hx using by rw [ Real.norm_of_nonneg ( by positivity ) ] ; exact mul_le_mul_of_nonneg_right ( by exact_mod_cast Real.rpow_le_rpow_of_exponent_le hx.le ( Nat.le_ceil _ ) ) ( by positivity ) ;

/-- The optimal depth (sweet spot) where value is maximized. -/

def optimalDepth (a b : ℝ) : ℝ := a / b

/-
PROBLEM
At the optimal depth, the critical point equation holds:
    a - b · d* = 0.

PROVIDED SOLUTION
optimalDepth a b = a/b. So b * (a/b) = a (since b ≠ 0 by hb). Thus a - b*(a/b) = a - a = 0. Use field_simp or div_mul_cancel₀.
-/

theorem optimal_depth_critical_point (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    a - b * optimalDepth a b = 0 := by
  rw [ optimalDepth, mul_div_cancel₀ _ hb.ne' ] ; ring

/-
PROBLEM
The value at the optimal depth is positive.

PROVIDED SOLUTION
At d* = a/b with a,b > 0, d* > 0. So d*^a > 0 (rpow_pos_of_pos) and exp(-b*d*) > 0 (exp_pos). Product of positives is positive.
-/

theorem value_positive_at_optimum (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    0 < theoremValue a b (optimalDepth a b) := by
  exact mul_pos ( Real.rpow_pos_of_pos ( div_pos ha hb ) _ ) ( Real.exp_pos _ )

/-- A depth-stratified mathematical corpus with empirical value data. -/

structure MathCorpus where
  /-- Maximum depth considered -/
  maxDepth : ℕ
  /-- Value (e.g., citation count) at each depth -/
  value : ℕ → ℝ
  /-- Values are nonneg -/
  value_nonneg : ∀ d, 0 ≤ value d
  /-- The sweet spot depth -/
  sweetSpot : ℕ
  /-- Sweet spot is in range -/
  sweetSpot_range : sweetSpot ≤ maxDepth
  /-- Sweet spot has maximum value -/
  sweetSpot_max : ∀ d, d ≤ maxDepth → value d ≤ value sweetSpot

/-- The total value of a corpus is concentrated around the sweet spot. -/

theorem sweet_spot_dominance (C : MathCorpus) (d : ℕ) (hd : d ≤ C.maxDepth) :
    C.value d ≤ C.value C.sweetSpot :=
  C.sweetSpot_max d hd

/-
PROBLEM
The "Depth-Value Inequality": the average value is bounded by the peak.

PROVIDED SOLUTION
Average of values ≤ max value. Each value d ≤ sweetSpot value by sweetSpot_max. Sum of n+1 terms each ≤ M gives sum ≤ (n+1)*M. Divide by (n+1). Use Finset.sum_le_card_nMul or sum_div_card_le_max approach.
-/

theorem depth_value_inequality (C : MathCorpus) (hM : 0 < C.maxDepth) :
    (∑ d ∈ range (C.maxDepth + 1), C.value d) / (C.maxDepth + 1) ≤ C.value C.sweetSpot := by
  exact div_le_iff₀' ( by positivity ) |>.2 ( le_trans ( Finset.sum_le_sum fun _ _ => C.sweetSpot_max _ <| Finset.mem_range_succ_iff.mp ‹_› ) <| by norm_num )

/-! ═══════════════════════════════════════════════════════════════════════════
    DREAM 8: THE ORACLE UNCERTAINTY PRINCIPLE
    "No system can simultaneously maximize both breadth and depth."

    We formalize a tradeoff: for a system with total resource budget R,
    Breadth × Depth ≤ R.

    This is analogous to Heisenberg's ΔxΔp ≥ ℏ/2.
    ═══════════════════════════════════════════════════════════════════════════ -/

/-- A mathematical exploration system with bounded resources. -/

structure ExplorationSystem where
  /-- Total resource budget -/
  budget : ℝ
  /-- Budget is positive -/
  budget_pos : 0 < budget
  /-- Breadth: number of distinct mathematical domains covered -/
  breadth : ℝ
  /-- Depth: maximum proof chain length in any domain -/
  depth : ℝ
  /-- Breadth is positive -/
  breadth_pos : 0 < breadth
  /-- Depth is positive -/
  depth_pos : 0 < depth
  /-- The uncertainty constraint: breadth × depth ≤ budget -/
  uncertainty : breadth * depth ≤ budget

/-- The Oracle Uncertainty Principle: breadth × depth is bounded. -/

theorem breadth_depth_tradeoff (E : ExplorationSystem)
    (b' : ℝ) (hb' : E.breadth < b') :
    E.budget / b' < E.budget / E.breadth := by
  gcongr;
  · exact E.budget_pos;
  · exact E.breadth_pos

/-- The balanced system: breadth = depth = √budget. -/

def balancedSystem (R : ℝ) (hR : 0 < R) : ExplorationSystem where
  budget := R
  budget_pos := hR
  breadth := Real.sqrt R
  depth := Real.sqrt R
  breadth_pos := Real.sqrt_pos_of_pos hR
  depth_pos := Real.sqrt_pos_of_pos hR
  uncertainty := le_of_eq (Real.mul_self_sqrt (le_of_lt hR))

/-- The balanced system achieves equality in the uncertainty bound. -/

theorem balanced_saturates (R : ℝ) (hR : 0 < R) :
    (balancedSystem R hR).breadth * (balancedSystem R hR).depth = R := by
  simp [balancedSystem, Real.mul_self_sqrt (le_of_lt hR)]

/-- Specialization index: depth/breadth ratio. -/

def specializationIndex (E : ExplorationSystem) : ℝ :=
  E.depth / E.breadth

/-- Generalization index: breadth/depth ratio. -/

def generalizationIndex (E : ExplorationSystem) : ℝ :=
  E.breadth / E.depth

/-
PROBLEM
The specialization and generalization indices are reciprocals.

PROVIDED SOLUTION
(depth/breadth) * (breadth/depth) = 1. Use div_mul_div_comm and then div_self. Both breadth and depth are positive (ne_of_gt).
-/

theorem spec_gen_reciprocal (E : ExplorationSystem) :
    specializationIndex E * generalizationIndex E = 1 := by
  unfold specializationIndex generalizationIndex;
  rw [ div_mul_div_cancel₀, div_self ] <;> linarith [ E.breadth_pos, E.depth_pos ]

/-
PROBLEM
The harmonic mean of breadth and depth is bounded by √budget.

PROVIDED SOLUTION
By AM-GM: breadth + depth ≥ 2*√(breadth*depth). So 2*B*D/(B+D) ≤ 2*B*D/(2*√(B*D)) = √(B*D) ≤ √budget (since B*D ≤ budget). Use Real.sqrt_le_sqrt and the uncertainty constraint.
-/

theorem harmonic_mean_bound (E : ExplorationSystem) :
    2 * E.breadth * E.depth / (E.breadth + E.depth) ≤ Real.sqrt E.budget := by
  refine Real.le_sqrt_of_sq_le ?_;
  field_simp;
  rw [ div_le_iff₀ ] <;> nlinarith [ sq_nonneg ( E.breadth - E.depth ), mul_pos E.breadth_pos E.depth_pos, E.uncertainty ]

/-! ═══════════════════════════════════════════════════════════════════════════
    CROSS-DREAM SYNTHESIS
    ═══════════════════════════════════════════════════════════════════════════ -/

/-- The Interference-Depth connection: emergent truths from Dream 6
    tend to cluster at intermediate depth (Dream 7's sweet spot). -/

structure InterferenceDepthConnection where
  /-- Depth assignment for propositions -/
  depthOf : ℕ → ℕ
  /-- Maximum depth -/
  maxDepth : ℕ
  /-- Emergent truths at each depth level -/
  emergentAtDepth : ℕ → ℕ
  /-- Sweet spot depth -/
  peakDepth : ℕ
  /-- Peak is in range -/
  peakInRange : peakDepth ≤ maxDepth
  /-- Peak dominates -/
  peakDominates : ∀ d, d ≤ maxDepth → emergentAtDepth d ≤ emergentAtDepth peakDepth

/-- The interference-depth peak property. -/

theorem interference_peaks_at_sweet_spot (conn : InterferenceDepthConnection)
    (d : ℕ) (hd : d ≤ conn.maxDepth) :
    conn.emergentAtDepth d ≤ conn.emergentAtDepth conn.peakDepth :=
  conn.peakDominates d hd


end
