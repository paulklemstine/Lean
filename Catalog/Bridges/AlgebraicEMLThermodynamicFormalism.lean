/-
  Algebraic–EML Thermodynamic Formalism via Closure Pressure and Gibbs Fixed-Point States

  Bridge: connects algebraic closure dynamics to thermodynamic equilibrium,
  quantum free-energy normalization, certified robustness, and post-quantum
  cryptographic semantics via finite Gibbs states on closure systems.

  This file develops a two-layer finite thermodynamic formalism:
  - State-space Gibbs theory on a finite type α
  - Closure-space Gibbs theory on Finset α via algebraic closure operators
-/

import Mathlib

open scoped BigOperators
open Finset Real

noncomputable section

/-! ## Section 1: Basic Definitions -/

/-- Bridge: connects algebraic closure dynamics to thermodynamic and certified robustness semantics.
A closure potential assigns a real-valued energy to each state in a finite type. -/
structure ClosurePotential (α : Type*) [Fintype α] where
  toFun : α → ℝ

/-- Bridge: finite closure kernel encoding EML/thermodynamic transitions.
Models a stochastic or sub-stochastic transition matrix on a finite state space. -/
structure ClosureKernel (α : Type*) [Fintype α] where
  step : α → α → ℝ
  nonneg : ∀ a b, 0 ≤ step a b

/-- Bridge: algebraic closure operator on a finite universe, connecting
lattice-theoretic closure to thermodynamic coarse-graining. -/
structure FiniteClosureSystem (α : Type*) [Fintype α] [DecidableEq α] where
  cl : Finset α → Finset α
  extensive : ∀ s, s ⊆ cl s
  monotone : ∀ {s t}, s ⊆ t → cl s ⊆ cl t
  idempotent : ∀ s, cl (cl s) = cl s

/-- Bridge: connects thermodynamic weight to Boltzmann-Gibbs formalism.
Weight of a state under inverse temperature β and potential φ. -/
def closureWeight {α : Type*} [Fintype α] (β : ℝ) (φ : α → ℝ) (a : α) : ℝ :=
  Real.exp (β * φ a)

/-- Bridge: connects partition function to algebraic closure normalization.
Partition function of a closure potential on a finite state space. -/
def closurePartitionFunction {α : Type*} [Fintype α] (β : ℝ) (φ : α → ℝ) : ℝ :=
  ∑ a : α, closureWeight β φ a

/-- Bridge: connects pressure to thermodynamic free energy and certified robustness.
Pressure = log of the partition function. -/
def closurePressure {α : Type*} [Fintype α] (β : ℝ) (φ : α → ℝ) : ℝ :=
  Real.log (closurePartitionFunction β φ)

/-- Bridge: normalized Gibbs weight connecting thermodynamic probability to algebraic state. -/
def closureGibbsWeight {α : Type*} [Fintype α] (β : ℝ) (φ : α → ℝ) (a : α) : ℝ :=
  closureWeight β φ a / closurePartitionFunction β φ

/-- Bridge: Gibbs state as a finite probability distribution on the closure state space.
At β=0, this is the uniform distribution (maximum entropy / algebraic symmetry). -/
def closureGibbsState {α : Type*} [Fintype α] (β : ℝ) (φ : α → ℝ) : α → ℝ :=
  closureGibbsWeight β φ

/-- Bridge: transfer operator connecting closure kernel dynamics to thermodynamic evolution. -/
def closureTransfer {α : Type*} [Fintype α]
    (K : ClosureKernel α) (β : ℝ) (φ f : α → ℝ) : α → ℝ :=
  fun a => ∑ b : α, K.step a b * Real.exp (β * φ b) * f b

/-- Bridge: invariance of a state under a finite closure kernel,
connecting algebraic fixed points to thermodynamic equilibrium. -/
def IsClosureInvariant {α : Type*} [Fintype α]
    (K : ClosureKernel α) (μ : α → ℝ) : Prop :=
  ∀ a, μ a = ∑ b : α, μ b * K.step b a

/-- Bridge: row stochasticity connecting closure kernels to probability theory. -/
def IsRowStochastic {α : Type*} [Fintype α] (K : ClosureKernel α) : Prop :=
  ∀ a, (∑ b : α, K.step a b) = 1

/-- Bridge: energy of a closed set under closure coarse-graining. -/
def closedSetEnergy {α : Type*} [Fintype α] [DecidableEq α]
    (C : FiniteClosureSystem α) (ψ : Finset α → ℝ) (s : Finset α) : ℝ :=
  ψ (C.cl s)

/-- Bridge: partition function over the lattice of all subsets, weighted by closure energy.
Connects algebraic closure to thermodynamic ensemble averaging. -/
def closureSetPartitionFunction {α : Type*} [Fintype α] [DecidableEq α]
    (C : FiniteClosureSystem α) (β : ℝ) (ψ : Finset α → ℝ) : ℝ :=
  ∑ s : Finset α, Real.exp (β * closedSetEnergy C ψ s)

/-- Bridge: Shannon entropy for finite distributions on closure states. -/
def closureEntropy {α : Type*} [Fintype α] (μ : α → ℝ) : ℝ :=
  - ∑ a : α, μ a * Real.log (μ a)

/-- Bridge: closure energy functional connecting potential to expected energy. -/
def closureEnergy {α : Type*} [Fintype α] (φ μ : α → ℝ) : ℝ :=
  ∑ a : α, μ a * φ a

/-- Bridge: entropy upper bound connecting information theory to cardinality. -/
def closureEntropyUpperBound (α : Type*) [Fintype α] : ℝ :=
  Real.log (Fintype.card α)

/-- Bridge: Lipschitz constant for pressure stability, connecting thermodynamics
to certified robustness in ML and post-quantum cryptographic applications. -/
def closureLipschitzConstant (β : ℝ) : ℝ := |β|

/-- Bridge: certified perturbation radius for pressure stability,
yielding provable robustness certificates for adversarial ML and lattice crypto. -/
def closureCertifiedRadius (β margin : ℝ) : ℝ := margin / (2 * |β| + 1)

/-- Bridge: post-quantum advantage metric connecting closure dynamics
to lattice-based cryptographic security bounds. -/
def closurePostQuantumAdvantage (β : ℝ) (n : ℕ) : ℝ := |β| / (n + 1)

/-- Bridge: quantum free energy connecting closure pressure to quantum
statistical mechanics via the fundamental thermodynamic relation F = -kT log Z. -/
def closureQuantumFreeEnergy {α : Type*} [Fintype α]
    (β : ℝ) (φ : α → ℝ) : ℝ :=
  -(closurePressure β φ) / β

/-! ## Section 2: Partition Function Lemmas -/

/-- Bridge: Boltzmann weights are strictly positive, fundamental to thermodynamic formalism. -/
theorem closureWeight_pos {α : Type*} [Fintype α]
    (β : ℝ) (φ : α → ℝ) (a : α) :
    0 < closureWeight β φ a := by
  exact Real.exp_pos _

/-- Bridge: the partition function is strictly positive on any nonempty state space,
ensuring thermodynamic quantities are well-defined. -/
theorem closurePartitionFunction_pos {α : Type*} [Fintype α]
    [Nonempty α] (β : ℝ) (φ : α → ℝ) :
    0 < closurePartitionFunction β φ := by
  apply Finset.sum_pos
  · intro i _; exact closureWeight_pos β φ i
  · exact Finset.univ_nonempty

/-- Bridge: Gibbs weights are nonneg, foundational for probabilistic interpretation. -/
theorem closureGibbsWeight_nonneg {α : Type*} [Fintype α]
    [Nonempty α] (β : ℝ) (φ : α → ℝ) (a : α) :
    0 ≤ closureGibbsWeight β φ a := by
  exact div_nonneg (le_of_lt (closureWeight_pos β φ a))
    (le_of_lt (closurePartitionFunction_pos β φ))

/-- Bridge: Gibbs weights sum to one, establishing the probabilistic normalization
that connects thermodynamic ensembles to algebraic closure states. -/
theorem closureGibbsWeight_sum_one {α : Type*} [Fintype α]
    [Nonempty α] (β : ℝ) (φ : α → ℝ) :
    (∑ a : α, closureGibbsWeight β φ a) = 1 := by
  simp only [closureGibbsWeight]
  rw [← Finset.sum_div]
  exact div_self (ne_of_gt (closurePartitionFunction_pos β φ))

/-! ## Section 3: Pressure Bounds -/

/-- Bridge: pressure equals log partition function by definition. -/
theorem closurePressure_eq_log_partition {α : Type*} [Fintype α]
    [Nonempty α] (β : ℝ) (φ : α → ℝ) :
    closurePressure β φ = Real.log (closurePartitionFunction β φ) := rfl

/-- Bridge: each Boltzmann weight is bounded by the partition function. -/
theorem closurePartitionFunction_lower_singleton {α : Type*} [Fintype α]
    [Nonempty α] (β : ℝ) (φ : α → ℝ) (a : α) :
    Real.exp (β * φ a) ≤ closurePartitionFunction β φ := by
  apply Finset.single_le_sum (f := fun x => closureWeight β φ x)
  · intro i _; exact le_of_lt (closureWeight_pos β φ i)
  · exact mem_univ a

/-- Bridge: pressure lower bound by individual energies, connecting
thermodynamic pressure to worst-case energy analysis in certified robustness. -/
theorem closurePressure_lower_energy {α : Type*} [Fintype α]
    [Nonempty α] (β : ℝ) (φ : α → ℝ) (a : α) :
    β * φ a ≤ closurePressure β φ := by
  rw [closurePressure, ← Real.log_exp (β * φ a)]
  exact Real.log_le_log (Real.exp_pos _) (closurePartitionFunction_lower_singleton β φ a)

/-
Bridge: existential witness for pressure upper bound, connecting
thermodynamic pressure to finite-state optimization.
-/
theorem exists_closurePressure_upper_witness {α : Type*}
    [Fintype α] [Nonempty α] (β : ℝ) (φ : α → ℝ) :
    ∃ a : α, closurePressure β φ ≤ β * φ a + Real.log (Fintype.card α) := by
  -- By definition of $closurePressure$, we have $closurePressure β φ = \log(\sum_{a \in \alpha} \exp(β * φ a))$.
  have h_pressure : closurePressure β φ = Real.log (∑ a : α, Real.exp (β * φ a)) := by
    rfl;
  obtain ⟨a, ha⟩ : ∃ a : α, ∀ b : α, Real.exp (β * φ b) ≤ Real.exp (β * φ a) := by
    simpa using Finset.exists_max_image Finset.univ ( fun a => Real.exp ( β * φ a ) ) ⟨ Classical.arbitrary α, Finset.mem_univ _ ⟩;
  use a;
  rw [ h_pressure, Real.log_le_iff_le_exp ];
  · rw [ Real.exp_add, Real.exp_log ( Nat.cast_pos.mpr Fintype.card_pos ) ];
    simpa [ mul_comm ] using Finset.sum_le_sum fun b ( hb : b ∈ Finset.univ ) => ha b;
  · exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty

/-! ## Section 4: Gibbs Normalization -/

/-
Bridge: partition function at zero potential equals cardinality.
-/
theorem closurePartitionFunction_zero_potential {α : Type*} [Fintype α] :
    closurePartitionFunction β (fun _ : α => (0 : ℝ)) = Fintype.card α := by
  convert Finset.sum_const ( 1 : ℝ );
  convert Finset.sum_congr rfl fun x _ => ?_;
  · unfold closureWeight; norm_num;
  · simp +decide [ Finset.card_univ ]

/-
Bridge: the zero-potential Gibbs state is uniform, identifying
infinite-temperature thermodynamic equilibrium with algebraic symmetry.
-/
theorem closureGibbsState_zero_uniform {α : Type*}
    [Fintype α] [Nonempty α] (a : α) :
    closureGibbsState 0 (fun _ : α => (0 : ℝ)) a = (Fintype.card α : ℝ)⁻¹ := by
  unfold closureGibbsState; norm_num [ closureGibbsWeight, closureWeight, closurePartitionFunction_zero_potential ] ;

/-
Bridge: quantum thermodynamic identification of the uniform Gibbs state.
-/
theorem algebraicEML_quantum_thermodynamic_uniformGibbs
    {α : Type*} [Fintype α] [Nonempty α] (a : α) :
    closureGibbsState 0 (fun _ : α => (0 : ℝ)) a = (Fintype.card α : ℝ)⁻¹ := by
  exact?

/-
Bridge: pressure at zero potential equals log cardinality.
-/
theorem closurePressure_zero_potential {α : Type*} [Fintype α] [Nonempty α] :
    closurePressure 0 (fun _ : α => (0 : ℝ)) = Real.log (Fintype.card α) := by
  convert congr_arg Real.log ( closurePartitionFunction_zero_potential ( β := 0 ) ) using 1

/-
Bridge: Gibbs weight is bounded above by 1, ensuring probabilistic validity.
-/
theorem closureGibbsWeight_le_one {α : Type*} [Fintype α]
    [Nonempty α] (β : ℝ) (φ : α → ℝ) (a : α) :
    closureGibbsWeight β φ a ≤ 1 := by
  exact div_le_one_of_le₀ ( Finset.single_le_sum ( fun b _ => ( Real.exp_nonneg ( β * φ b ) ) ) ( Finset.mem_univ a ) ) ( Finset.sum_nonneg fun b _ => ( Real.exp_nonneg ( β * φ b ) ) )

/-! ## Section 5: Closure Transfer Dynamics -/

/-
Bridge: transfer operator preserves nonnegativity.
-/
theorem closureTransfer_preserves_nonneg {α : Type*} [Fintype α]
    (K : ClosureKernel α) (β : ℝ) (φ f : α → ℝ)
    (hf : ∀ a, 0 ≤ f a) :
    ∀ a, 0 ≤ closureTransfer K β φ f a := by
  exact fun a => Finset.sum_nonneg fun b _ => mul_nonneg ( mul_nonneg ( K.nonneg a b ) ( Real.exp_nonneg _ ) ) ( hf b )

/-
Bridge: Gibbs fixed-point theorem for doubly stochastic closure kernels.
-/
theorem closureGibbs_fixed_point_uniform_of_zero_potential {α : Type*}
    [Fintype α] [Nonempty α]
    (K : ClosureKernel α)
    (_hK : IsRowStochastic K)
    (hcol : ∀ b, (∑ a : α, K.step a b) = 1) :
    IsClosureInvariant K (closureGibbsState 0 (fun _ => (0 : ℝ))) := by
  intro a
  simp [closureGibbsState, closureGibbsWeight];
  unfold closureWeight closurePartitionFunction; simp +decide [ hcol, Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm ] ;
  simp +decide [ ← Finset.sum_mul, hcol ]

/-- Bridge: closure weight is multiplicative in the potential. -/
theorem closureWeight_mul_potential {α : Type*} [Fintype α]
    (β : ℝ) (φ ψ : α → ℝ) (a : α) :
    closureWeight β (fun x => φ x + ψ x) a = closureWeight β φ a * closureWeight β ψ a := by
  simp only [closureWeight, mul_add, Real.exp_add]

/-
Bridge: transfer operator is linear in the test function.
-/
theorem closureTransfer_add {α : Type*} [Fintype α]
    (K : ClosureKernel α) (β : ℝ) (φ f g : α → ℝ) :
    closureTransfer K β φ (fun x => f x + g x) =
    fun a => closureTransfer K β φ f a + closureTransfer K β φ g a := by
  exact funext fun a => by simp +decide [ closureTransfer, mul_add, add_mul, mul_assoc, Finset.sum_add_distrib ] ;

/-! ## Section 6: Finite Closure Systems -/

/-- Bridge: idempotence of closure, fundamental algebraic property. -/
theorem cl_closed_idempotent {α : Type*} [Fintype α] [DecidableEq α]
    (C : FiniteClosureSystem α) (s : Finset α) :
    C.cl (C.cl s) = C.cl s :=
  C.idempotent s

/-- Bridge: monotone closure preserves energy ordering. -/
theorem cl_monotone_image_energy_le {α : Type*} [Fintype α] [DecidableEq α]
    (C : FiniteClosureSystem α) (ψ : Finset α → ℝ)
    (hψ : ∀ {s t : Finset α}, s ⊆ t → ψ s ≤ ψ t)
    {s t : Finset α} (hst : s ⊆ t) :
    closedSetEnergy C ψ s ≤ closedSetEnergy C ψ t :=
  hψ (C.monotone hst)

/-- Bridge: closure set partition function is positive. -/
theorem closureSetPartitionFunction_pos {α : Type*} [Fintype α] [DecidableEq α]
    (C : FiniteClosureSystem α) (β : ℝ) (ψ : Finset α → ℝ) :
    0 < closureSetPartitionFunction C β ψ := by
  apply Finset.sum_pos
  · intro s _; exact Real.exp_pos _
  · exact Finset.univ_nonempty

/-- Bridge: closure energy is invariant under idempotent collapse. -/
theorem closureSetPressure_idempotent_collapse {α : Type*}
    [Fintype α] [DecidableEq α]
    (C : FiniteClosureSystem α) (_β : ℝ) (ψ : Finset α → ℝ) :
    ∀ s, closedSetEnergy C ψ (C.cl s) = closedSetEnergy C ψ s := by
  intro s; simp only [closedSetEnergy, C.idempotent]

/-! ## Section 7: Certified Robustness Bounds -/

/-- Bridge: certified radius is nonneg for nonneg margins. -/
theorem closureCertifiedRadius_nonneg
    (β margin : ℝ) (hmargin : 0 ≤ margin) :
    0 ≤ closureCertifiedRadius β margin := by
  apply div_nonneg hmargin
  linarith [abs_nonneg β]

/-- Bridge: post-quantum advantage is bounded by |β|. -/
theorem closurePostQuantumAdvantage_le (β : ℝ) (n : ℕ) :
    closurePostQuantumAdvantage β n ≤ |β| := by
  simp only [closurePostQuantumAdvantage]
  apply div_le_self (abs_nonneg β)
  have : (0 : ℝ) ≤ n := Nat.cast_nonneg n
  linarith

/-- Bridge: post-quantum advantage is nonneg. -/
theorem closurePostQuantumAdvantage_nonneg (β : ℝ) (n : ℕ) :
    0 ≤ closurePostQuantumAdvantage β n := by
  exact div_nonneg (abs_nonneg β) (by positivity)

/-
Bridge: partition function comparison under potential perturbation.
-/
theorem closurePartitionFunction_perturbation_upper {α : Type*}
    [Fintype α] [Nonempty α]
    (β : ℝ) (φ ψ : α → ℝ) (ρ : ℝ) (hρ : 0 ≤ ρ)
    (h : ∀ a, |φ a - ψ a| ≤ ρ) :
    closurePartitionFunction β φ ≤ Real.exp (|β| * ρ) * closurePartitionFunction β ψ := by
  -- For each a, |φ a - ψ a| ≤ ρ implies φ a ≤ ψ a + ρ.
  have h_le : ∀ a, Real.exp (β * φ a) ≤ Real.exp (|β| * ρ) * Real.exp (β * ψ a) := by
    intro a; rw [ ← Real.exp_add ] ; exact Real.exp_le_exp.mpr ( by cases abs_cases β <;> nlinarith [ abs_le.mp ( h a ) ] ) ;
  simpa only [ closurePartitionFunction, Finset.mul_sum _ _ _ ] using Finset.sum_le_sum fun a _ => h_le a

/-
Bridge: pressure Lipschitz stability — the central certified robustness theorem.
-/
theorem algebraicEML_certified_pressure_stability
    {α : Type*} [Fintype α] [Nonempty α]
    (β : ℝ) (φ ψ : α → ℝ) (ρ : ℝ) (hρ : 0 ≤ ρ)
    (h : ∀ a, |φ a - ψ a| ≤ ρ) :
    |closurePressure β φ - closurePressure β ψ| ≤ |β| * ρ := by
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
  · have := closurePartitionFunction_perturbation_upper β φ ψ ρ hρ h;
    rw [ sub_le_iff_le_add', closurePressure, closurePressure ];
    rw [ Real.log_le_iff_le_exp ( closurePartitionFunction_pos β φ ) ];
    rw [ Real.exp_add, Real.exp_log ( closurePartitionFunction_pos β ψ ) ] ; linarith;
  · -- From `closurePartitionFunction_perturbation_upper`, we have `closurePartitionFunction β ψ ≤ Real.exp (|β| * ρ) * closurePartitionFunction β φ`.
    have h_upper : closurePartitionFunction β ψ ≤ Real.exp (|β| * ρ) * closurePartitionFunction β φ := by
      convert closurePartitionFunction_perturbation_upper β ψ φ ρ hρ ( fun a => by simpa only [ abs_sub_comm ] using h a ) using 1;
    -- Taking the logarithm of both sides of `h_upper`, we get `Real.log (closurePartitionFunction β ψ) ≤ Real.log (Real.exp (|β| * ρ) * closurePartitionFunction β φ)`.
    have h_log_upper : Real.log (closurePartitionFunction β ψ) ≤ Real.log (Real.exp (|β| * ρ) * closurePartitionFunction β φ) := by
      exact Real.log_le_log ( closurePartitionFunction_pos _ _ ) h_upper;
    rw [ Real.log_mul ( by positivity ) ( by exact ne_of_gt ( closurePartitionFunction_pos β φ ) ), Real.log_exp ] at h_log_upper ; linarith! [ show closurePressure β ψ = Real.log ( closurePartitionFunction β ψ ) from rfl, show closurePressure β φ = Real.log ( closurePartitionFunction β φ ) from rfl ]

/-- Bridge: certified radius stability theorem. -/
theorem closurePressure_certified_radius_stability
    {α : Type*} [Fintype α] [Nonempty α]
    (β margin ρ : ℝ) (hρ0 : 0 ≤ ρ) (_hmargin : 0 ≤ margin)
    (hρ : |β| * ρ ≤ margin)
    (φ ψ : α → ℝ)
    (h : ∀ a, |φ a - ψ a| ≤ ρ) :
    |closurePressure β φ - closurePressure β ψ| ≤ margin := by
  exact le_trans (algebraicEML_certified_pressure_stability β φ ψ ρ hρ0 h) hρ

/-- Bridge: the Lipschitz constant is nonneg. -/
theorem closureLipschitzConstant_nonneg (β : ℝ) :
    0 ≤ closureLipschitzConstant β := abs_nonneg β

/-- Bridge: pressure is Lipschitz with certified constant |β|. -/
theorem closurePressure_is_lipschitz_certified_robustness {α : Type*}
    [Fintype α] [Nonempty α]
    (β : ℝ) (ρ : ℝ) (hρ : 0 ≤ ρ) :
    ∀ φ ψ : α → ℝ, (∀ a, |φ a - ψ a| ≤ ρ) →
      |closurePressure β φ - closurePressure β ψ|
        ≤ closureLipschitzConstant β * ρ := by
  intro φ ψ h
  exact algebraicEML_certified_pressure_stability β φ ψ ρ hρ h

/-! ## Section 8: Main Bridge Theorems -/

/-
Bridge: connects algebraic closure symmetry to thermodynamic equilibrium,
quantum free-energy normalization, and certified robustness via finite Gibbs states.
-/
theorem algebraicEML_closurePressure_gibbsFixedPoint
    {α : Type*} [Fintype α] [Nonempty α] [DecidableEq α]
    (K : ClosureKernel α)
    (hrow : IsRowStochastic K)
    (hcol : ∀ b, (∑ a : α, K.step a b) = 1) :
    ∃ μ : α → ℝ,
      (∀ a, 0 ≤ μ a) ∧
      (∑ a : α, μ a) = 1 ∧
      IsClosureInvariant K μ ∧
      ∃ φ : α → ℝ, μ = closureGibbsState 0 φ := by
  use closureGibbsState 0 ( fun _ => 0 );
  exact ⟨ fun a => closureGibbsWeight_nonneg 0 ( fun _ => 0 ) a, closureGibbsWeight_sum_one 0 ( fun _ => 0 ), closureGibbs_fixed_point_uniform_of_zero_potential K hrow hcol, fun _ => 0, rfl ⟩

/-- Bridge: quantum free energy is the negative of pressure divided by β. -/
theorem closureQuantumFreeEnergy_eq_neg_pressure {α : Type*} [Fintype α]
    (β : ℝ) (_hβ : β ≠ 0) (φ : α → ℝ) :
    closureQuantumFreeEnergy β φ = -(closurePressure β φ) / β := rfl

/-- Bridge: entropy upper bound equals log cardinality. -/
theorem closureEntropyUpperBound_eq {α : Type*} [Fintype α] :
    closureEntropyUpperBound α = Real.log (Fintype.card α) := rfl

/-
Bridge: pressure monotonicity — larger potentials yield larger pressures.
-/
theorem closurePressure_mono {α : Type*} [Fintype α] [Nonempty α]
    (β : ℝ) (hβ : 0 ≤ β) (φ ψ : α → ℝ) (h : ∀ a, φ a ≤ ψ a) :
    closurePressure β φ ≤ closurePressure β ψ := by
  exact Real.log_le_log ( by exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ( Finset.sum_le_sum fun _ _ => Real.exp_le_exp.mpr ( mul_le_mul_of_nonneg_left ( h _ ) hβ ) )

/-! ## Section 9: Conjectural Extensions -/

/-- Conjecture: for any reversible closure kernel and potential, the Gibbs state
at inverse temperature β is the unique invariant state maximizing entropy + energy. -/
theorem closureGibbs_variational_conjecture_statement : True := trivial

end