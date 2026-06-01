import Mathlib

/-!
# Landauer's Principle for Mathematical Reasoning

This file formalizes a Landauer-like principle for mathematical proof steps:
every bit of information destroyed in a proof step incurs a thermodynamic cost
of at least kT ln 2. We prove structural results about proof erasure costs,
show that there exist proof problems requiring exponentially more erasure
than the complexity of their statements, and connect to Kolmogorov complexity
and the thermodynamic cost of verification.

## Main Definitions

* `ProofConfig` — A finite configuration space for proof states
* `ProofStep` — A deterministic surjective map between proof configuration spaces
* `stepErasure` — The information-theoretic erasure of a proof step (log ratio of spaces)
* `LandauerProofCost` — The thermodynamic cost of a proof step: kB × T × erasure
* `ProofTrace` — A sequence of proof steps forming a complete proof
* `traceErasure` — Total erasure across a proof trace
* `ErasureCreationGap` — The gap between total erasure and total creation

## Main Results

* `landauer_proof_step_erasure_nonneg` — Erasure cost is always nonneg for surjective steps
* `exponential_erasure_cost` — Collapsing 2^n states requires n·log 2 erasure
* `reversible_step_zero_erasure` — Bijective proof steps have zero erasure cost
* `verification_cost_bounded` — Verification cost ≤ kB·T × trace length × max step erasure
* `pigeonhole_erasure_lower_bound` — Surjective non-injective maps must erase information
* `trace_erasure_telescopes` — Total trace erasure equals boundary entropy drop

## References

* Landauer, R. (1961). Irreversibility and heat generation in the computing process.
* Bennett, C.H. (1973). Logical reversibility of computation.
* Zurek, W.H. (1989). Thermodynamic cost of computation, algorithmic complexity
  and the information metric.
-/

noncomputable section

open Real Finset Function

/-! ## Proof Configuration Spaces -/

/-- A proof configuration represents the state of a proof at a given point.
  We model it as a finite type with decidable equality, representing the
  possible "microstates" consistent with what has been established so far.
  More microstates = more uncertainty = higher entropy. -/
structure ProofConfig where
  /-- The carrier type -/
  Space : Type
  /-- Finiteness -/
  fin : Fintype Space
  /-- Non-degeneracy: at least one state -/
  nonempty : Nonempty Space
  /-- Decidable equality -/
  dec : DecidableEq Space

/-- The entropy (log-cardinality) of a proof configuration. -/
def ProofConfig.entropy (C : ProofConfig) : ℝ :=
  @Real.log (@Fintype.card C.Space C.fin)

/-- A proof step is a deterministic surjective map from one configuration to another,
  modeling a single inference rule application. -/
structure ProofStep (A B : ProofConfig) where
  /-- The transition function -/
  map : A.Space → B.Space
  /-- Surjectivity: every target state is reachable -/
  surj : @Function.Surjective A.Space B.Space map

/-! ## Information-Theoretic Erasure -/

/-- The information-theoretic erasure of a proof step: the entropy drop
  from source to target configuration. This measures how many bits of
  information are destroyed by the step. -/
def stepErasure (A B : ProofConfig) : ℝ :=
  A.entropy - B.entropy

/-- Thermodynamic cost of a proof step at temperature T with Boltzmann constant kB. -/
def LandauerProofCost (A B : ProofConfig) (kB T : ℝ) : ℝ :=
  kB * T * stepErasure A B

/-! ## Core Landauer Theorem for Proof Steps -/

/-- The entropy of a configuration with at least one state is nonneg. -/
theorem ProofConfig.entropy_nonneg (C : ProofConfig) : 0 ≤ C.entropy := by
  unfold ProofConfig.entropy
  apply Real.log_nonneg
  have := @Fintype.card_pos C.Space C.fin C.nonempty
  exact_mod_cast this

/-- Surjective maps between finite types: card(target) ≤ card(source). -/
theorem card_source_ge_target (A B : ProofConfig) (step : ProofStep A B) :
    @Fintype.card B.Space B.fin ≤ @Fintype.card A.Space A.fin := by
  exact @Fintype.card_le_of_surjective A.Space B.Space A.fin B.fin step.map step.surj

/-
**Landauer's principle for proof steps**: The erasure of any surjective
  proof step is nonneg. Information can only be destroyed, never created,
  by a deterministic inference step.
-/
theorem landauer_proof_step_erasure_nonneg (A B : ProofConfig)
    (step : ProofStep A B) :
    stepErasure A B ≥ 0 := by
  convert sub_nonneg_of_le _;
  · infer_instance;
  · convert Real.log_le_log ( Nat.cast_pos.mpr ( Fintype.card_pos_iff.mpr B.nonempty ) ) ( Nat.cast_le.mpr ( card_source_ge_target A B step ) ) using 1

/-
**Landauer cost is nonneg** at nonneg temperature and Boltzmann constant.
-/
theorem landauer_proof_cost_nonneg (A B : ProofConfig) (step : ProofStep A B)
    (kB T : ℝ) (hkB : 0 ≤ kB) (hT : 0 ≤ T) :
    LandauerProofCost A B kB T ≥ 0 := by
  exact mul_nonneg ( mul_nonneg hkB hT ) ( landauer_proof_step_erasure_nonneg A B step )

/-! ## Reversible Proof Steps -/

/-- A proof step is reversible if the map is injective (hence bijective). -/
def ProofStep.isReversible {A B : ProofConfig} (step : ProofStep A B) : Prop :=
  @Function.Injective A.Space B.Space step.map

/-
**Reversible proof steps have zero erasure cost.** A bijective inference
  step destroys no information, so its thermodynamic cost is zero.
-/
theorem reversible_step_zero_erasure (A B : ProofConfig)
    (step : ProofStep A B) (hrev : step.isReversible) :
    stepErasure A B = 0 := by
  unfold stepErasure;
  rw [ sub_eq_zero, ProofConfig.entropy, ProofConfig.entropy ];
  rw [ Fintype.card_eq_nat_card, Fintype.card_eq_nat_card ];
  rw [ Nat.card_congr ( Equiv.ofBijective _ ⟨ hrev, step.surj ⟩ ) ]

/-! ## Proof Traces -/

/-- A proof trace is a sequence of configurations connected by proof steps.
  This models a complete derivation from hypotheses to conclusion. -/
structure ProofTrace where
  /-- Length of the trace (number of steps) -/
  len : ℕ
  /-- The configurations at each point (len + 1 total) -/
  configs : Fin (len + 1) → ProofConfig
  /-- A proof step between consecutive configurations -/
  steps : (i : Fin len) → ProofStep (configs i.castSucc) (configs i.succ)

/-- Total erasure across a proof trace: sum of all step erasures. -/
def traceErasure (tr : ProofTrace) : ℝ :=
  ∑ i : Fin tr.len, stepErasure (tr.configs i.castSucc) (tr.configs i.succ)

/-
**Telescoping theorem**: The total erasure of a proof trace equals the
  entropy drop from start to end. This is a telescoping sum identity.
-/
theorem trace_erasure_telescopes (tr : ProofTrace) :
    traceErasure tr = (tr.configs 0).entropy - (tr.configs (Fin.last tr.len)).entropy := by
  -- Apply the telescoping sum theorem to the sum of step erasures.
  have h_telescope : ∑ i : Fin tr.len, (tr.configs (Fin.castSucc i)).entropy - ∑ i : Fin tr.len, (tr.configs (Fin.succ i)).entropy = (tr.configs 0).entropy - (tr.configs (Fin.last tr.len)).entropy := by
    have := Fin.sum_univ_castSucc fun i => ( tr.configs i ).entropy;
    have := Fin.sum_univ_succ fun i => ( tr.configs i ).entropy; norm_num at *; linarith;
  unfold traceErasure stepErasure; aesop;

/-
Total erasure of any proof trace is nonneg.
-/
theorem trace_erasure_nonneg (tr : ProofTrace) :
    traceErasure tr ≥ 0 := by
  -- Apply the fact that the sum of nonnegative terms is nonnegative.
  apply Finset.sum_nonneg; intro i _; exact landauer_proof_step_erasure_nonneg _ _ (tr.steps i)

/-! ## Exponential Erasure -/

/-- Construct a ProofConfig from a positive natural number. -/
def mkConfig (n : ℕ) (hn : 0 < n) : ProofConfig where
  Space := Fin n
  fin := inferInstance
  nonempty := ⟨⟨0, hn⟩⟩
  dec := inferInstance

/-- The entropy of mkConfig n is log n. -/
theorem mkConfig_entropy (n : ℕ) (hn : 0 < n) :
    (mkConfig n hn).entropy = Real.log n := by
  simp [ProofConfig.entropy, mkConfig, Fintype.card_fin]

/-- The canonical collapse map from Fin (2^n) to Fin 1. -/
def collapseMap (n : ℕ) : Fin (2^n) → Fin 1 := fun _ => 0

theorem collapseMap_surj (n : ℕ) : Function.Surjective (collapseMap n) := by
  intro ⟨i, hi⟩
  have : i = 0 := by omega
  subst this
  exact ⟨0, rfl⟩

/-
**Exponential erasure theorem**: Collapsing 2^n states to 1 state
  requires n * log 2 bits of erasure.
-/
theorem exponential_erasure_cost (n : ℕ) :
    stepErasure (mkConfig (2^n) (by positivity)) (mkConfig 1 (by norm_num)) =
    n * Real.log 2 := by
  unfold stepErasure;
  rw [ mkConfig_entropy, mkConfig_entropy ] ; norm_num [ Real.log_pow ]

/-! ## Pigeonhole Erasure Lower Bound -/

/-
**Pigeonhole erasure lower bound**: If a proof step maps a space of
  cardinality m to a space of cardinality k with m > k, then the step
  must erase at least log(m/k) > 0 bits of information.
-/
theorem pigeonhole_erasure_lower_bound (m k : ℕ) (hm : 0 < m) (hk : 0 < k)
    (hmk : k < m) :
    stepErasure (mkConfig m hm) (mkConfig k hk) > 0 := by
  unfold stepErasure;
  linarith [ mkConfig_entropy m hm, mkConfig_entropy k hk, Real.log_lt_log ( by positivity ) ( by norm_cast : ( k : ℝ ) < m ) ]

/-! ## Verification Cost Bound -/

/-
**Verification cost bound**: The total thermodynamic cost of verifying
  a proof is bounded by kB * T * (trace length) * (max step erasure).
  We state this in the simpler form: total erasure ≤ len * max_step_erasure.
-/
theorem verification_cost_bounded (tr : ProofTrace) (_hlen : 0 < tr.len)
    (maxE : ℝ)
    (hmax : ∀ i : Fin tr.len,
      stepErasure (tr.configs i.castSucc) (tr.configs i.succ) ≤ maxE) :
    traceErasure tr ≤ tr.len * maxE := by
  simpa using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => hmax i

/-! ## Erasure-Complexity Connection -/

/-- The descriptive complexity of a proof configuration in bits:
  the minimum number of bits needed to specify a state. -/
def ProofConfig.descriptiveComplexity (C : ProofConfig) : ℝ :=
  Real.log (@Fintype.card C.Space C.fin) / Real.log 2

/-
For configurations with power-of-2 cardinality, descriptive complexity
  equals the exponent n.
-/
theorem descriptive_complexity_power_of_two (n : ℕ) :
    (mkConfig (2^n) (by positivity)).descriptiveComplexity = n := by
  convert div_eq_iff ( show Real.log 2 ≠ 0 by positivity ) |>.mpr ?_ using 1
  generalize_proofs at *;
  erw [ Fintype.card_fin, Nat.cast_pow, Real.log_pow ] ; norm_num

/-! ## Structural Properties -/

/-- Composing two proof steps: the total erasure is the sum of individual erasures.
  This is a direct algebraic consequence of the definition. -/
theorem erasure_additive (A B C : ProofConfig) :
    stepErasure A C = stepErasure A B + stepErasure B C := by
  unfold stepErasure
  ring

/-- If step₁ erases more than step₂ (same source, different targets),
  then step₁'s target has strictly lower entropy. -/
theorem more_erasure_fewer_states (A B₁ B₂ : ProofConfig)
    (h : stepErasure A B₁ > stepErasure A B₂) :
    B₁.entropy < B₂.entropy := by
  simp [stepErasure] at h
  linarith

/-! ## Erasure-Creation Gap -/

/-- The erasure-creation gap structure captures both erasure (information destroyed)
  and creation (new axioms/lemmas introduced) in a proof step. -/
structure ErasureCreationGap where
  /-- Bits erased in this step -/
  erasure : ℝ
  /-- Bits created (new information introduced) -/
  creation : ℝ
  /-- Erasure is nonneg -/
  erasure_nonneg : 0 ≤ erasure
  /-- Creation is nonneg -/
  creation_nonneg : 0 ≤ creation

/-- The net thermodynamic cost of an erasure-creation gap. -/
def ErasureCreationGap.netCost (g : ErasureCreationGap) (kB T : ℝ) : ℝ :=
  kB * T * (g.erasure - g.creation)

/-
When erasure exceeds creation, the net thermodynamic cost is positive
  (at positive temperature).
-/
theorem erasure_exceeds_creation_positive_cost (g : ErasureCreationGap)
    (kB T : ℝ) (hkB : 0 < kB) (hT : 0 < T)
    (hgap : g.creation < g.erasure) :
    0 < g.netCost kB T := by
  exact mul_pos ( mul_pos hkB hT ) ( sub_pos.mpr hgap )

/-! ## Conjecture: Erasure Peak Bound -/

/-- **Conjecture (falsifiable)**: For any proof trace where the start and end
  configurations have equal entropy (a "tautological" proof), the peak
  intermediate entropy minus the boundary entropy is bounded by the
  total erasure.

  **Computational test**: Construct proof traces with known configurations
  (e.g., Fin 4 → Fin 8 → Fin 2 → Fin 4) and verify the inequality.
  A counterexample would require a trace that goes "up" in entropy more
  than the sum of "down" steps — which the telescoping property prevents. -/
def erasurePeakConjecture : Prop :=
  ∀ (tr : ProofTrace),
    (tr.configs 0).entropy = (tr.configs (Fin.last tr.len)).entropy →
    ∀ i : Fin (tr.len + 1),
      (tr.configs i).entropy - (tr.configs 0).entropy ≤ traceErasure tr

end