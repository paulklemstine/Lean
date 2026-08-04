import Mathlib

/-!
# Vacuum-energy accounting meets finite information theory

This file connects a conservation-law model of energy harvesting with Landauer's
finite-state information-erasure bound.  A cycle may export useful energy, change
stored energy, and perform a finite computation.  The computation's erased Shannon
capacity is charged at the Landauer rate.

The flagship bound says that useful output plus the information-theoretic cost of
compressing the cycle's finite state space cannot exceed external input plus the
initial reserve.  A second result gives a rigidity statement: an unpowered cyclic
process can neither harvest energy nor perform a logically irreversible step.
-/

open scoped BigOperators

namespace ZeroPointInformationBridge

/-- Number of outputs actually reached by a finite computation. -/
def imageCard {γ δ : Type*} [Fintype γ] [DecidableEq δ] (f : γ → δ) : ℕ :=
  (Finset.univ.image f).card

/-- Shannon-capacity loss, measured in bits, of a finite computation. -/
noncomputable def erasedBits {γ δ : Type*} [Fintype γ] [DecidableEq δ]
    (f : γ → δ) : ℝ :=
  Real.logb 2 (Fintype.card γ) - Real.logb 2 (imageCard f)

/-- Energy dissipated when `bits` distinctions are erased. -/
noncomputable def landauerCost (bits kB temperature : ℝ) : ℝ :=
  bits * (kB * temperature * Real.log 2)

/-- A finite computation loses at least the log-cardinality gap between its input
and output spaces. -/
theorem erasedBits_lower_bound {γ δ : Type*} [Fintype γ] [Fintype δ]
    [DecidableEq δ] [Nonempty γ] (f : γ → δ) :
    Real.logb 2 (Fintype.card γ) - Real.logb 2 (Fintype.card δ) ≤ erasedBits f := by
  unfold erasedBits
  -- Need to show: logb 2 (Fintype.card γ) - logb 2 (Fintype.card δ) ≤ logb 2 (Fintype.card γ) - logb 2 (imageCard f)
  -- Equivalently: -logb 2 (Fintype.card δ) ≤ -logb 2 (imageCard f)
  -- Which is: logb 2 (imageCard f) ≤ logb 2 (Fintype.card δ)
  have h_card : imageCard f ≤ Fintype.card δ := by
    unfold imageCard
    exact Finset.card_le_univ _
  have h_card_pos : 0 < imageCard f := by
    have : Nonempty γ := ‹_›
    obtain ⟨x⟩ := this
    unfold imageCard
    have hx : f x ∈ Finset.univ.image f := Finset.mem_image_of_mem _ (Finset.mem_univ x)
    exact Finset.card_pos.mpr ⟨f x, hx⟩
  have h_logb : Real.logb 2 (imageCard f : ℝ) ≤ Real.logb 2 (Fintype.card δ : ℝ) := by
    apply Real.logb_le_logb_of_le (by norm_num : (1 : ℝ) < 2) (by positivity) (by norm_cast)
  linarith

/-- Zero capacity loss is equivalent to logical reversibility. -/
theorem erasedBits_eq_zero_iff_injective {γ δ : Type*} [Fintype γ]
    [DecidableEq δ] [Nonempty γ] (f : γ → δ) :
    erasedBits f = 0 ↔ Function.Injective f := by
  unfold erasedBits
  rw [sub_eq_zero]
  have h1 : (0:ℝ) < imageCard f := by
    unfold imageCard; exact_mod_cast Finset.card_pos.mpr ((Finset.univ_nonempty).image f)
  have hα : (0:ℝ) < Fintype.card γ := by
    have : 0 < Fintype.card γ := Fintype.card_pos; exact_mod_cast this
  constructor
  · intro h
    have hlog : Real.logb 2 (Fintype.card γ) = Real.logb 2 (imageCard f) := by linarith
    have hcard : (Fintype.card γ : ℝ) = imageCard f :=
      Real.logb_injOn_pos (by norm_num) (Set.mem_Ioi.mpr hα) (Set.mem_Ioi.mpr h1) hlog
    have hcard' : Fintype.card γ = imageCard f := by exact_mod_cast hcard
    have hcard'' : imageCard f = (Finset.univ : Finset γ).card := by
      unfold imageCard at hcard' ⊢; simp [Finset.card_univ] at hcard' ⊢; omega
    have hinj := Finset.injOn_of_card_image_eq hcard''
    intro a b hab; exact hinj (by simp) (by simp) hab
  · intro hinj
    have : imageCard f = Fintype.card γ := by
      unfold imageCard; rw [Finset.card_image_of_injective _ hinj]; simp [Finset.card_univ]
    rw [this]

variable (α β : ℕ → Type*)
variable [∀ t, Fintype (α t)] [∀ t, DecidableEq (β t)]

/-- An energy-accounted sequence of finite computations.  Each step pays its
Landauer cost in addition to any useful energy it exports. -/
structure InformationProcess where
  stored : ℕ → ℝ
  injected : ℕ → ℝ
  harvested : ℕ → ℝ
  step : ∀ t, α t → β t
  kB : ℝ
  temperature : ℝ
  stored_nonneg : ∀ t, 0 ≤ stored t
  injected_nonneg : ∀ t, 0 ≤ injected t
  harvested_nonneg : ∀ t, 0 ≤ harvested t
  kB_nonneg : 0 ≤ kB
  temperature_nonneg : 0 ≤ temperature
  balance : ∀ t,
    stored (t + 1) + harvested t +
        landauerCost (erasedBits (step t)) kB temperature =
      stored t + injected t

/-- The Landauer price of one erased bit for this process. -/
noncomputable def InformationProcess.bitPrice
    (P : InformationProcess α β) : ℝ :=
  P.kB * P.temperature * Real.log 2

/-- Exact conservation over a finite horizon, including computational dissipation. -/
theorem finite_horizon_information_conservation
    (P : InformationProcess α β) (N : ℕ) :
    P.stored N + (∑ t ∈ Finset.range N, P.harvested t) +
        (∑ t ∈ Finset.range N,
          landauerCost (erasedBits (P.step t)) P.kB P.temperature) =
      P.stored 0 + ∑ t ∈ Finset.range N, P.injected t := by
  induction N with
  | zero => simp
  | succ N ih =>
    simp only [Finset.sum_range_succ]
    have balance := P.balance N
    linarith

/-- Useful energy plus actual Landauer dissipation is bounded by the initial reserve
and all externally injected energy. -/
theorem harvested_add_landauer_le_budget
    (P : InformationProcess α β) (N : ℕ) :
    (∑ t ∈ Finset.range N, P.harvested t) +
        (∑ t ∈ Finset.range N,
          landauerCost (erasedBits (P.step t)) P.kB P.temperature) ≤
      P.stored 0 + ∑ t ∈ Finset.range N, P.injected t := by
  have h := finite_horizon_information_conservation (α := α) (β := β) P N
  have hstored := P.stored_nonneg N
  linarith

variable [∀ t, Nonempty (α t)]

/-- **Information/energy connector.** The finite-state compression performed by all
cycles produces an explicit debit from the harvesting budget.  Thus a cardinality
bound from information theory becomes an upper bound on physically useful output. -/
theorem harvested_add_log_cardinality_cost_le_budget
    (P : InformationProcess α β) (N : ℕ)
    [∀ t, Fintype (β t)] :
    (∑ t ∈ Finset.range N, P.harvested t) +
        (∑ t ∈ Finset.range N,
          (Real.logb 2 (Fintype.card (α t)) -
            Real.logb 2 (Fintype.card (β t))) * P.bitPrice) ≤
      P.stored 0 + ∑ t ∈ Finset.range N, P.injected t := by
  -- First, show that log-cardinality cost ≤ Landauer cost for each term
  have h_le : ∀ t < N, (Real.logb 2 (Fintype.card (α t)) - Real.logb 2 (Fintype.card (β t))) * P.bitPrice ≤
      landauerCost (erasedBits (P.step t)) P.kB P.temperature := by
    intro t _
    have h1 := erasedBits_lower_bound (P.step t)
    have h2 : P.bitPrice = P.kB * P.temperature * Real.log 2 := rfl
    rw [h2, landauerCost]
    have h3 : 0 ≤ P.bitPrice := by rw [h2]; exact mul_nonneg (mul_nonneg P.kB_nonneg P.temperature_nonneg) (Real.log_nonneg (by norm_num : (1 : ℝ) ≤ 2))
    gcongr
  -- Sum the inequalities
  have h_sum_le : ∑ t ∈ Finset.range N, (Real.logb 2 (Fintype.card (α t)) - Real.logb 2 (Fintype.card (β t))) * P.bitPrice ≤
      ∑ t ∈ Finset.range N, landauerCost (erasedBits (P.step t)) P.kB P.temperature := by
    apply Finset.sum_le_sum
    intro t ht
    exact h_le t (Finset.mem_range.mp ht)
  -- Use finite_horizon_information_conservation
  have h_conservation :=
    finite_horizon_information_conservation (α := α) (β := β) P N
  linarith [P.stored_nonneg N, h_conservation, h_sum_le]

/-- At positive temperature, a closed cyclic process with no external input is rigid:
it exports no useful energy and every finite computation it performs before the
horizon is injective (logically reversible). -/
theorem cyclic_unpowered_rigidity
    (P : InformationProcess α β) (N : ℕ)
    (hkB : 0 < P.kB) (hT : 0 < P.temperature)
    (hcycle : P.stored N = P.stored 0)
    (hinput : ∀ t < N, P.injected t = 0) :
    (∀ t < N, P.harvested t = 0) ∧
      (∀ t < N, Function.Injective (P.step t)) := by
  -- First, derive that the sum of harvested energy + Landauer costs = 0
  have cons := finite_horizon_information_conservation α β P N
  have hinput_sum : ∑ t ∈ Finset.range N, P.injected t = 0 := by
    apply Finset.sum_eq_zero
    intro t ht
    exact hinput t (Finset.mem_range.mp ht)
  rw [hcycle, hinput_sum] at cons
  -- Simplify: the sums must equal zero
  have h_eq : (∑ t ∈ Finset.range N, P.harvested t) +
      (∑ t ∈ Finset.range N, landauerCost (erasedBits (P.step t)) P.kB P.temperature) = 0 := by
    linarith
  -- Helper: imageCard ≤ Fintype.card for any function
  have imageCard_le : ∀ (t : ℕ) (f : α t → β t), imageCard f ≤ Fintype.card (α t) := fun t f => by
    unfold imageCard
    calc (Finset.univ.image f).card ≤ (Finset.univ : Finset (α t)).card := Finset.card_image_le
      _ = Fintype.card (α t) := Finset.card_univ
  -- Helper: erasedBits ≥ 0
  have erasedBits_nonneg : ∀ (t : ℕ) (f : α t → β t), 0 ≤ erasedBits f := fun t f => by
    unfold erasedBits
    have hne : Nonempty (α t) := by infer_instance
    have h1 : (0:ℝ) < imageCard f := by
      unfold imageCard
      have : (Finset.image f Finset.univ).Nonempty := Finset.univ_nonempty.image f
      exact_mod_cast Finset.card_pos.mpr this
    have h2 : (imageCard f : ℝ) ≤ Fintype.card (α t) := by exact_mod_cast imageCard_le t f
    have := (Real.logb_le_logb (b := 2) (by norm_num) h1 (lt_of_lt_of_le h1 h2)).2 h2
    linarith
  -- Helper: landauerCost ≥ 0
  have landauer_nonneg : ∀ (t : ℕ), 0 ≤ landauerCost (erasedBits (P.step t)) P.kB P.temperature := fun t => by
    unfold landauerCost
    have hb := erasedBits_nonneg t (P.step t)
    exact mul_nonneg hb (mul_nonneg (mul_nonneg P.kB_nonneg (le_of_lt hT)) (Real.log_nonneg (by norm_num)))
  -- Since both sums are non-negative and sum to 0, each sum is 0
  have hharv_nonneg : 0 ≤ ∑ t ∈ Finset.range N, P.harvested t := by
    apply Finset.sum_nonneg; intro t _; exact P.harvested_nonneg t
  have hland_nonneg : 0 ≤ ∑ t ∈ Finset.range N, landauerCost (erasedBits (P.step t)) P.kB P.temperature := by
    apply Finset.sum_nonneg; intro t _; exact landauer_nonneg t
  have h_harv_zero : ∑ t ∈ Finset.range N, P.harvested t = 0 := by linarith
  have h_Landauer_zero : ∑ t ∈ Finset.range N, landauerCost (erasedBits (P.step t)) P.kB P.temperature = 0 := by linarith
  -- Extract: each harvested t = 0
  have h_harv_each : ∀ t < N, P.harvested t = 0 := by
    intro t ht
    have := Finset.sum_eq_zero_iff_of_nonneg (fun i _ => P.harvested_nonneg i) |>.mp h_harv_zero
    exact this t (Finset.mem_range.mpr ht)
  -- Extract: each landauerCost = 0
  have h_Landauer_each : ∀ t < N, landauerCost (erasedBits (P.step t)) P.kB P.temperature = 0 := by
    intro t ht
    have := Finset.sum_eq_zero_iff_of_nonneg (fun i _ => landauer_nonneg i) |>.mp h_Landauer_zero
    exact this t (Finset.mem_range.mpr ht)
  -- From landauerCost = 0 and positive kB, T, derive erasedBits = 0
  have h_bits_zero : ∀ t < N, erasedBits (P.step t) = 0 := by
    intro t ht
    specialize h_Landauer_each t ht
    unfold landauerCost at h_Landauer_each
    have hlog_pos : 0 < Real.log 2 := Real.log_pos (by norm_num)
    have hfactor_pos : 0 < P.kB * P.temperature * Real.log 2 := by positivity
    exact (mul_eq_zero.mp h_Landauer_each).resolve_right hfactor_pos.ne'
  -- Use erasedBits_eq_zero_iff_injective to get injectivity
  have h_inj : ∀ t < N, Function.Injective (P.step t) := by
    intro t ht
    exact (erasedBits_eq_zero_iff_injective (P.step t)).mp (h_bits_zero t ht)
  exact ⟨h_harv_each, h_inj⟩

end ZeroPointInformationBridge