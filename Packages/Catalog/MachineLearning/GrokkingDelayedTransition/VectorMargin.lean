import Mathlib

/-!
# Delayed margin positivity for vector-valued two-layer ReLU networks

The catalog file `Catalog/MachineLearning/GrokkingPhaseTransition.lean` treats a
width-one *scalar* network.  This file carries out Future Direction 1 (finite
hidden width, matrix weights, a finite test set, and a classification margin)
and Direction 3 (train/test separation).

Main results.

* `exists_sharp_threshold`: any monotone continuous signal that starts negative
  and is eventually positive has a *sharp* threshold `τ`: it is `≤ 0` on
  `(-∞, τ]` and `> 0` on `(τ, ∞)`.  The threshold is unique
  (`sharp_threshold_unique`).
* `margin_sharp_threshold`: the same holds for the *minimum* over a finite test
  set of finitely many such signals — the delayed transition survives taking a
  worst-case margin over a test set.
* `netMargin_delayed_positivity`: for a genuinely vector-valued two-layer ReLU
  network (hidden width `m`, input dimension `d`, matrix weights, negative
  output bias, a finite two-class test set) the classification margin is
  nonpositive up to an explicit delay and strictly positive afterwards.
* `grokking_window_eq`: for a concrete dataset the set of times at which the
  training set is already perfectly classified while the test point is still
  misclassified is *exactly* the interval `(1/2, 2]` — a formal train/test
  separation window.
-/

namespace GrokkingVector

open Finset Set

/-! ### Sharp thresholds for monotone continuous signals -/

/-- **Sharp threshold.**  A monotone continuous function that is negative at `0`
and eventually positive has a threshold `τ ≥ 0` with `f ≤ 0` on `(-∞, τ]` and
`f > 0` on `(τ, ∞)`. -/
theorem exists_sharp_threshold (f : ℝ → ℝ) (hmono : Monotone f) (hcont : Continuous f)
    (h0 : f 0 < 0) (hT : ∃ T, 0 < f T) :
    ∃ tau : ℝ, 0 ≤ tau ∧ (∀ t ≤ tau, f t ≤ 0) ∧ (∀ t, tau < t → 0 < f t) := by
  obtain ⟨T, hTpos⟩ := hT
  set A : Set ℝ := {t : ℝ | f t ≤ 0} with hA
  have hAne : A.Nonempty := ⟨0, by simpa [hA] using h0.le⟩
  have hAbdd : BddAbove A := by
    refine ⟨T, fun a ha => ?_⟩
    by_contra hcon
    push_neg at hcon
    have : f T ≤ f a := hmono hcon.le
    have : f a ≤ 0 := ha
    linarith
  have hAclosed : IsClosed A := by
    have : A = f ⁻¹' (Iic 0) := rfl
    rw [this]
    exact IsClosed.preimage hcont isClosed_Iic
  have hmem : sSup A ∈ A := hAclosed.csSup_mem hAne hAbdd
  refine ⟨sSup A, le_csSup hAbdd (by simpa [hA] using h0.le), ?_, ?_⟩
  · intro t ht
    rcases eq_or_lt_of_le ht with rfl | hlt
    · exact hmem
    · by_contra hcon
      push_neg at hcon
      have hub : ∀ a ∈ A, a ≤ t := by
        intro a ha
        by_contra hca
        push_neg at hca
        have : f t ≤ f a := hmono hca.le
        have : f a ≤ 0 := ha
        linarith
      have : sSup A ≤ t := csSup_le hAne hub
      linarith
  · intro t ht
    by_contra hcon
    push_neg at hcon
    have : t ∈ A := hcon
    have : t ≤ sSup A := le_csSup hAbdd this
    linarith

/-- The sharp threshold is unique. -/
theorem sharp_threshold_unique (f : ℝ → ℝ) {tau tau' : ℝ}
    (h1 : (∀ t ≤ tau, f t ≤ 0) ∧ (∀ t, tau < t → 0 < f t))
    (h2 : (∀ t ≤ tau', f t ≤ 0) ∧ (∀ t, tau' < t → 0 < f t)) :
    tau = tau' := by
  by_contra hne
  rcases lt_or_gt_of_ne hne with h | h
  · have hpos := h1.2 tau' h
    have hnonpos := h2.1 tau' le_rfl
    linarith
  · have hpos := h2.2 tau h
    have hnonpos := h1.1 tau le_rfl
    linarith

/-! ### Worst-case margin over a finite test set -/

/-- The worst-case (minimum) value over a finite test set of signed scores. -/
noncomputable def margin {n : ℕ} (hn : 0 < n) (g : Fin n → ℝ → ℝ) (t : ℝ) : ℝ :=
  (Finset.univ : Finset (Fin n)).inf'
    (Finset.univ_nonempty_iff.mpr (Fin.pos_iff_nonempty.mp hn)) (fun k => g k t)

theorem margin_le {n : ℕ} (hn : 0 < n) (g : Fin n → ℝ → ℝ) (t : ℝ) (k : Fin n) :
    margin hn g t ≤ g k t :=
  Finset.inf'_le _ (Finset.mem_univ k)

theorem lt_margin {n : ℕ} (hn : 0 < n) (g : Fin n → ℝ → ℝ) (t : ℝ) {c : ℝ}
    (h : ∀ k, c < g k t) : c < margin hn g t :=
  (Finset.lt_inf'_iff _).mpr fun k _ => h k

theorem margin_monotone {n : ℕ} (hn : 0 < n) (g : Fin n → ℝ → ℝ)
    (hg : ∀ k, Monotone (g k)) : Monotone (margin hn g) := by
  intro a b hab
  exact Finset.le_inf' _ _ fun k _ => le_trans (margin_le hn g a k) (hg k hab)

theorem margin_continuous {n : ℕ} (hn : 0 < n) (g : Fin n → ℝ → ℝ)
    (hg : ∀ k, Continuous (g k)) : Continuous (margin hn g) :=
  Continuous.finset_inf'_apply _ fun k _ => hg k

/-- **Delayed positivity of a worst-case margin.**  If every one of finitely many
signed scores is monotone, continuous and eventually positive, and at least one
of them starts negative, then the margin has a sharp threshold. -/
theorem margin_sharp_threshold {n : ℕ} (hn : 0 < n) (g : Fin n → ℝ → ℝ)
    (hmono : ∀ k, Monotone (g k)) (hcont : ∀ k, Continuous (g k))
    (hneg : ∃ k, g k 0 < 0) (hpos : ∀ k, ∃ T, 0 < g k T) :
    ∃ tau : ℝ, 0 ≤ tau ∧
      (∀ t ≤ tau, margin hn g t ≤ 0) ∧ (∀ t, tau < t → 0 < margin hn g t) := by
  obtain ⟨k₀, hk₀⟩ := hneg
  choose Tk hTk using hpos
  set T : ℝ := (Finset.univ : Finset (Fin n)).sup'
    (Finset.univ_nonempty_iff.mpr (Fin.pos_iff_nonempty.mp hn)) Tk with hT
  refine exists_sharp_threshold (margin hn g) (margin_monotone hn g hmono)
    (margin_continuous hn g hcont) (lt_of_le_of_lt (margin_le hn g 0 k₀) hk₀) ⟨T, ?_⟩
  refine lt_margin hn g T fun k => ?_
  exact lt_of_lt_of_le (hTk k) (hmono k (Finset.le_sup' Tk (Finset.mem_univ k)))

/-! ### Vector-valued two-layer ReLU networks -/

/-- The rectifier. -/
noncomputable def relu (x : ℝ) : ℝ := max x 0

theorem relu_nonneg (x : ℝ) : 0 ≤ relu x := le_max_right _ _

theorem le_relu (x : ℝ) : x ≤ relu x := le_max_left _ _

theorem relu_of_nonpos {x : ℝ} (hx : x ≤ 0) : relu x = 0 := max_eq_right hx

theorem relu_mono : Monotone relu := fun _ _ h => max_le_max h le_rfl

/-- A two-layer ReLU network with hidden width `m`, input dimension `d`, matrix
hidden weights `W`, hidden biases `b`, output weights `a` and output bias `c`. -/
noncomputable def net {m d : ℕ} (W : Fin m → Fin d → ℝ) (b a : Fin m → ℝ) (c : ℝ)
    (x : Fin d → ℝ) : ℝ :=
  c + ∑ j, a j * relu ((∑ i, W j i * x i) + b j)

/-- The signal of hidden unit `j` on the input direction `p`. -/
def signal {m d : ℕ} (W : Fin m → Fin d → ℝ) (p : Fin d → ℝ) (j : Fin m) : ℝ :=
  ∑ i, W j i * p i

/-- The network evaluated on the ramped input `t · p`. -/
noncomputable def netRamp {m d : ℕ} (W : Fin m → Fin d → ℝ) (b a : Fin m → ℝ) (c : ℝ)
    (p : Fin d → ℝ) (t : ℝ) : ℝ :=
  net W b a c (fun i => t * p i)

theorem netRamp_eq {m d : ℕ} (W : Fin m → Fin d → ℝ) (b a : Fin m → ℝ) (c : ℝ)
    (p : Fin d → ℝ) (t : ℝ) :
    netRamp W b a c p t = c + ∑ j, a j * relu (t * signal W p j + b j) := by
  have hinner : ∀ j : Fin m, (∑ i, W j i * (t * p i)) = t * signal W p j := by
    intro j
    simp only [signal, Finset.mul_sum]
    exact Finset.sum_congr rfl fun i _ => by ring
  simp only [netRamp, net, hinner]

theorem netRamp_continuous {m d : ℕ} (W : Fin m → Fin d → ℝ) (b a : Fin m → ℝ) (c : ℝ)
    (p : Fin d → ℝ) : Continuous (netRamp W b a c p) := by
  have h : netRamp W b a c p
      = fun t => c + ∑ j, a j * relu (t * signal W p j + b j) :=
    funext fun t => netRamp_eq W b a c p t
  rw [h]
  refine continuous_const.add (continuous_finset_sum _ fun j _ => ?_)
  exact continuous_const.mul (((continuous_id.mul continuous_const).add
    continuous_const).max continuous_const)

/-- With nonnegative output weights and nonnegative signals the ramped network
output is monotone in the ramp parameter. -/
theorem netRamp_monotone {m d : ℕ} (W : Fin m → Fin d → ℝ) (b a : Fin m → ℝ) (c : ℝ)
    (p : Fin d → ℝ) (ha : ∀ j, 0 ≤ a j) (hsig : ∀ j, 0 ≤ signal W p j) :
    Monotone (netRamp W b a c p) := by
  intro t₁ t₂ ht
  simp only [netRamp_eq]
  have hsum : ∑ j, a j * relu (t₁ * signal W p j + b j)
      ≤ ∑ j, a j * relu (t₂ * signal W p j + b j) := by
    refine Finset.sum_le_sum fun j _ => ?_
    refine mul_le_mul_of_nonneg_left (relu_mono ?_) (ha j)
    have := mul_le_mul_of_nonneg_right ht (hsig j)
    linarith
  linarith

/-- If every hidden unit is silent on `p` for nonnegative ramps, the network
outputs exactly its output bias. -/
theorem netRamp_of_silent {m d : ℕ} (W : Fin m → Fin d → ℝ) (b a : Fin m → ℝ) (c : ℝ)
    (p : Fin d → ℝ) (hb : ∀ j, b j ≤ 0) (hsig : ∀ j, signal W p j ≤ 0)
    {t : ℝ} (ht : 0 ≤ t) : netRamp W b a c p t = c := by
  have h0 : ∀ j ∈ (Finset.univ : Finset (Fin m)),
      a j * relu (t * signal W p j + b j) = 0 := by
    intro j _
    have hle : t * signal W p j + b j ≤ 0 := by
      have := mul_nonpos_of_nonneg_of_nonpos ht (hsig j)
      linarith [hb j]
    rw [relu_of_nonpos hle, mul_zero]
  rw [netRamp_eq, Finset.sum_eq_zero h0, add_zero]

/-- At ramp `0` a network with nonpositive hidden biases outputs its output
bias. -/
theorem netRamp_zero {m d : ℕ} (W : Fin m → Fin d → ℝ) (b a : Fin m → ℝ) (c : ℝ)
    (p : Fin d → ℝ) (hb : ∀ j, b j ≤ 0) : netRamp W b a c p 0 = c := by
  have h0 : ∀ j ∈ (Finset.univ : Finset (Fin m)),
      a j * relu (0 * signal W p j + b j) = 0 := by
    intro j _
    have hle : 0 * signal W p j + b j ≤ 0 := by simpa using hb j
    rw [relu_of_nonpos hle, mul_zero]
  rw [netRamp_eq, Finset.sum_eq_zero h0, add_zero]

/-- A single active hidden unit forces the ramped output to become positive. -/
theorem netRamp_eventually_pos {m d : ℕ} (W : Fin m → Fin d → ℝ) (b a : Fin m → ℝ)
    (c : ℝ) (p : Fin d → ℝ) (ha : ∀ j, 0 ≤ a j) {j₀ : Fin m} (ha₀ : 0 < a j₀)
    (hs₀ : 0 < signal W p j₀) : ∃ T : ℝ, 0 < netRamp W b a c p T := by
  refine ⟨((1 - c) / a j₀ - b j₀) / signal W p j₀, ?_⟩
  rw [netRamp_eq]
  set T : ℝ := ((1 - c) / a j₀ - b j₀) / signal W p j₀ with hT
  have hTs : T * signal W p j₀ = (1 - c) / a j₀ - b j₀ := by
    rw [hT]
    exact div_mul_cancel₀ _ (ne_of_gt hs₀)
  have hterm : 1 - c ≤ a j₀ * relu (T * signal W p j₀ + b j₀) := by
    have h1 : (1 - c) / a j₀ ≤ relu (T * signal W p j₀ + b j₀) := by
      have : T * signal W p j₀ + b j₀ = (1 - c) / a j₀ := by rw [hTs]; ring
      rw [this]
      exact le_relu _
    calc 1 - c = a j₀ * ((1 - c) / a j₀) := by field_simp
      _ ≤ a j₀ * relu (T * signal W p j₀ + b j₀) := by
          exact mul_le_mul_of_nonneg_left h1 ha₀.le
  have hsum : a j₀ * relu (T * signal W p j₀ + b j₀)
      ≤ ∑ j, a j * relu (T * signal W p j + b j) := by
    refine Finset.single_le_sum (f := fun j => a j * relu (T * signal W p j + b j))
      (fun j _ => mul_nonneg (ha j) (relu_nonneg _)) (Finset.mem_univ j₀)
  linarith

/-! ### Delayed positivity of the classification margin -/

/-- The signed score of test point `k`: positive exactly when the network
classifies `k` correctly. -/
noncomputable def signedScore {m d n : ℕ} (W : Fin m → Fin d → ℝ) (b a : Fin m → ℝ)
    (c : ℝ) (p : Fin n → Fin d → ℝ) (y : Fin n → ℝ) (k : Fin n) (t : ℝ) : ℝ :=
  y k * netRamp W b a c (p k) t

/-- **Delayed positivity of the classification margin for a vector-valued
two-layer ReLU network.**

Data: hidden width `m`, input dimension `d`, matrix hidden weights `W`,
nonpositive hidden biases, nonnegative output weights, a strictly negative
output bias `c`, and a finite test set of `n` labelled points presented through
a ramp `t ↦ t·p k`.  Negative-class points (`y k = -1`) leave every hidden unit
silent, positive-class points (`y k = 1`) excite at least one hidden unit.

Conclusion: the worst-case margin over the test set is `≤ 0` up to an explicit
threshold `τ ≥ 0` and strictly positive after it. -/
theorem netMargin_delayed_positivity {m d n : ℕ} (hn : 0 < n)
    (W : Fin m → Fin d → ℝ) (b a : Fin m → ℝ) (c : ℝ)
    (p : Fin n → Fin d → ℝ) (y : Fin n → ℝ)
    (hc : c < 0) (ha : ∀ j, 0 ≤ a j) (hb : ∀ j, b j ≤ 0)
    (hlabel : ∀ k, y k = 1 ∨ y k = -1)
    (hneg : ∀ k, y k = -1 → ∀ j, signal W (p k) j ≤ 0)
    (hposdir : ∀ k, y k = 1 → ∀ j, 0 ≤ signal W (p k) j)
    (hactive : ∀ k, y k = 1 → ∃ j₀, 0 < a j₀ ∧ 0 < signal W (p k) j₀)
    (hexists_pos : ∃ k, y k = 1) :
    ∃ tau : ℝ, 0 ≤ tau ∧
      (∀ t ≤ tau, margin hn (signedScore W b a c p y) t ≤ 0) ∧
      (∀ t, tau < t → 0 < margin hn (signedScore W b a c p y) t) := by
  have hmono : ∀ k, Monotone (signedScore W b a c p y k) := by
    intro k
    rcases hlabel k with h1 | h1
    · intro t₁ t₂ ht
      simp only [signedScore, h1, one_mul]
      exact netRamp_monotone W b a c (p k) ha (hposdir k h1) ht
    · intro t₁ t₂ ht
      simp only [signedScore, h1]
      have hsame : ∀ t : ℝ, netRamp W b a c (p k) t
          = c + ∑ j, a j * relu (t * signal W (p k) j + b j) := netRamp_eq W b a c (p k)
      -- for a negative-class point every unit stays silent for `t ≥ 0`,
      -- but monotonicity must hold for all `t`; we use that the score is
      -- antitone in `t` since all signals are nonpositive
      have hanti : netRamp W b a c (p k) t₂ ≤ netRamp W b a c (p k) t₁ := by
        rw [hsame t₁, hsame t₂]
        have hsum : ∑ j, a j * relu (t₂ * signal W (p k) j + b j)
            ≤ ∑ j, a j * relu (t₁ * signal W (p k) j + b j) := by
          refine Finset.sum_le_sum fun j _ => ?_
          refine mul_le_mul_of_nonneg_left (relu_mono ?_) (ha j)
          have hsig := hneg k h1 j
          nlinarith
        linarith
      nlinarith
  have hcont : ∀ k, Continuous (signedScore W b a c p y k) := by
    intro k
    exact continuous_const.mul (netRamp_continuous W b a c (p k))
  have hpos : ∀ k, ∃ T, 0 < signedScore W b a c p y k T := by
    intro k
    rcases hlabel k with h1 | h1
    · obtain ⟨j₀, ha₀, hs₀⟩ := hactive k h1
      obtain ⟨T, hT⟩ := netRamp_eventually_pos W b a c (p k) ha ha₀ hs₀
      exact ⟨T, by simp only [signedScore, h1, one_mul]; exact hT⟩
    · refine ⟨0, ?_⟩
      simp only [signedScore, h1]
      rw [netRamp_zero W b a c (p k) hb]
      linarith
  obtain ⟨k₁, hk₁⟩ := hexists_pos
  have hstart : signedScore W b a c p y k₁ 0 < 0 := by
    simp only [signedScore, hk₁, one_mul]
    rw [netRamp_zero W b a c (p k₁) hb]
    exact hc
  exact margin_sharp_threshold hn _ hmono hcont ⟨k₁, hstart⟩ hpos

/-! ### An explicit train/test separation window -/

/-- Concrete width-one, one-dimensional network used for the separation
example: output bias `-1`, hidden weight `1`, hidden bias `0`, output weight
`1`. -/
noncomputable def exNet (p : ℝ) (t : ℝ) : ℝ :=
  netRamp (fun _ : Fin 1 => fun _ : Fin 1 => (1 : ℝ)) (fun _ => 0) (fun _ => 1) (-1)
    (fun _ : Fin 1 => p) t

theorem exNet_eq (p t : ℝ) : exNet p t = -1 + relu (t * p) := by
  simp [exNet, netRamp_eq, signal]

/-- Training set: a positive point with strong signal `2` and a negative point
with signal `-1`.  Both are classified correctly as soon as `t > 1/2`. -/
def TrainPerfect (t : ℝ) : Prop := 0 < 1 * exNet 2 t ∧ 0 < (-1) * exNet (-1) t

/-- Test point: a positive point with weak signal `1/2`. -/
def TestCorrect (t : ℝ) : Prop := 0 < 1 * exNet (1 / 2 : ℝ) t

/-- **Train/test separation.**  For nonnegative times, the training set is
perfectly classified while the test point is still misclassified *exactly* on
the interval `(1/2, 2]`.  On this window the training error is already zero and
the test error is still positive: a formal grokking window. -/
theorem grokking_window_eq :
    {t : ℝ | 0 ≤ t ∧ TrainPerfect t ∧ ¬ TestCorrect t} = Ioc (1 / 2 : ℝ) 2 := by
  ext t
  simp only [Set.mem_setOf_eq, Set.mem_Ioc, TrainPerfect, TestCorrect, exNet_eq, relu, one_mul]
  constructor
  · rintro ⟨ht0, ⟨h1, h2⟩, h3⟩
    constructor
    · by_contra hcon
      push_neg at hcon
      have : max (t * 2) 0 ≤ 1 := by
        rcases max_cases (t * 2) (0 : ℝ) with ⟨he, _⟩ | ⟨he, _⟩ <;> rw [he] <;> linarith
      linarith
    · by_contra hcon
      push_neg at hcon
      have hmax : max (t * (1 / 2)) 0 = t * (1 / 2) := max_eq_left (by linarith)
      rw [hmax] at h3
      apply h3
      linarith
  · rintro ⟨h1, h2⟩
    have ht0 : (0 : ℝ) ≤ t := by linarith
    refine ⟨ht0, ⟨?_, ?_⟩, ?_⟩
    · have hmax : max (t * 2) 0 = t * 2 := max_eq_left (by linarith)
      rw [hmax]; linarith
    · have hmax : max (t * (-1)) 0 = 0 := max_eq_right (by nlinarith)
      rw [hmax]; linarith
    · intro hcon
      have hmax : max (t * (1 / 2)) 0 = t * (1 / 2) := max_eq_left (by linarith)
      rw [hmax] at hcon
      linarith

/-- The training set of the example is *not* perfectly classified before time
`1/2`, and the test point *is* classified correctly after time `2`: the window
above is sharp on both sides. -/
theorem grokking_window_sharp :
    (∀ t : ℝ, 0 ≤ t → t ≤ 1 / 2 → ¬ TrainPerfect t) ∧
      (∀ t : ℝ, 2 < t → TestCorrect t) := by
  constructor
  · intro t _ ht hcon
    have h1 := hcon.1
    simp only [exNet_eq, relu, one_mul] at h1
    have : max (t * 2) 0 ≤ 1 := by
      rcases max_cases (t * 2) (0 : ℝ) with ⟨he, _⟩ | ⟨he, _⟩ <;> rw [he] <;> linarith
    linarith
  · intro t ht
    simp only [TestCorrect, exNet_eq, relu, one_mul]
    have hmax : max (t * (1 / 2)) 0 = t * (1 / 2) := max_eq_left (by linarith)
    rw [hmax]
    linarith


/-! ### A concrete instance: the hypotheses are satisfiable and the delay is exact

The general theorem `netMargin_delayed_positivity` is not vacuous: here is a
two-class test set on which all of its hypotheses hold, and for which the sharp
margin threshold can be computed exactly (it equals `1`).
-/

namespace Example

open GrokkingVector

/-- Hidden weight matrix of the example (width one, dimension one). -/
def exW : Fin 1 → Fin 1 → ℝ := fun _ _ => 1

/-- Hidden biases of the example. -/
def exB : Fin 1 → ℝ := fun _ => 0

/-- Output weights of the example. -/
def exA : Fin 1 → ℝ := fun _ => 1

/-- Two test points: a positive-class point in direction `+1` and a
negative-class point in direction `-1`. -/
def exP : Fin 2 → Fin 1 → ℝ := fun k _ => if k = 0 then 1 else -1

/-- Labels of the two test points. -/
def exY : Fin 2 → ℝ := fun k => if k = 0 then 1 else -1

/-- Signed scores of the example. -/
noncomputable def exSigned : Fin 2 → ℝ → ℝ := signedScore exW exB exA (-1) exP exY

theorem exSignal_zero (j : Fin 1) : signal exW (exP 0) j = 1 := by
  simp [signal, exW, exP]

theorem exSignal_one (j : Fin 1) : signal exW (exP 1) j = -1 := by
  simp [signal, exW, exP]

theorem exSigned_zero (t : ℝ) : exSigned 0 t = -1 + relu t := by
  simp [exSigned, signedScore, netRamp_eq, signal, exW, exB, exA, exP, exY]

theorem exSigned_one (t : ℝ) : exSigned 1 t = 1 - relu (-t) := by
  simp [exSigned, signedScore, netRamp_eq, signal, exW, exB, exA, exP, exY]
  ring

/-- The example satisfies all hypotheses of `netMargin_delayed_positivity`, so
its margin has a sharp delay. -/
theorem exMargin_delayed :
    ∃ tau : ℝ, 0 ≤ tau ∧
      (∀ t ≤ tau, margin (by norm_num : 0 < 2) exSigned t ≤ 0) ∧
      (∀ t, tau < t → 0 < margin (by norm_num : 0 < 2) exSigned t) := by
  refine netMargin_delayed_positivity (by norm_num) exW exB exA (-1) exP exY
    (by norm_num) (fun j => by simp [exA]) (fun j => by simp [exB]) ?_ ?_ ?_ ?_
    ⟨0, by simp [exY]⟩
  · exact Fin.forall_fin_two.mpr ⟨Or.inl (by simp [exY]), Or.inr (by simp [exY])⟩
  · refine Fin.forall_fin_two.mpr ⟨fun h j => ?_, fun _ j => ?_⟩
    · norm_num [exY] at h
    · rw [exSignal_one]; norm_num
  · refine Fin.forall_fin_two.mpr ⟨fun _ j => ?_, fun h j => ?_⟩
    · rw [exSignal_zero]; norm_num
    · norm_num [exY] at h
  · refine Fin.forall_fin_two.mpr ⟨fun _ => ⟨0, by simp [exA], ?_⟩, fun h => ?_⟩
    · rw [exSignal_zero]; norm_num
    · norm_num [exY] at h

/-- The exact delay of the example: the worst-case margin is nonpositive up to
time `1` and strictly positive afterwards. -/
theorem exMargin_threshold_one :
    (∀ t ≤ (1 : ℝ), margin (by norm_num : 0 < 2) exSigned t ≤ 0) ∧
      (∀ t, (1 : ℝ) < t → 0 < margin (by norm_num : 0 < 2) exSigned t) := by
  constructor
  · intro t ht
    refine le_trans (margin_le _ exSigned t 0) ?_
    rw [exSigned_zero]
    have : relu t ≤ 1 := max_le ht zero_le_one
    linarith
  · intro t ht
    refine lt_margin _ exSigned t (Fin.forall_fin_two.mpr ⟨?_, ?_⟩)
    · rw [exSigned_zero]
      have h : relu t = t := max_eq_left (by linarith)
      rw [h]; linarith
    · rw [exSigned_one]
      have h : relu (-t) = 0 := relu_of_nonpos (by linarith)
      rw [h]; norm_num

/-- Consequently the delay produced by the general theorem is exactly `1`. -/
theorem exMargin_tau_eq_one (tau : ℝ)
    (h : (∀ t ≤ tau, margin (by norm_num : 0 < 2) exSigned t ≤ 0) ∧
      (∀ t, tau < t → 0 < margin (by norm_num : 0 < 2) exSigned t)) : tau = 1 :=
  sharp_threshold_unique _ h exMargin_threshold_one

end Example

end GrokkingVector

/-!
# Quantitative delay bounds, convex (tropical) structure, and robustness

Second research cycle.  `VectorMargin.lean` proves that the worst-case margin of
a vector-valued two-layer ReLU network has a *sharp* delay `τ`.  Here we

* locate `τ` quantitatively: `delay_lower_bound_of_threshold` and
  `delay_upper_bound_of_threshold` sandwich the delay between `|c| / S`, where
  `S = ∑ⱼ aⱼ gⱼ` is the total signal of the point, and
  `(|c|/a_{j₀} - b_{j₀})/g_{j₀}` coming from any single active unit — so the
  delay scales like *output-bias magnitude divided by signal strength*;
* connect the delay to the *tropical / convex-geometric* picture of the catalog
  file `Catalog/Tropical/NeuralCoding/GrokPhaseTransition.lean`: the ramped
  network output is a convex piecewise-linear (tropical) function of the ramp
  parameter (`netRamp_convexOn`), hence the set of times at which the network
  still fails is always an interval (`failure_set_convex`) — the delayed
  transition can never happen twice;
* prove robustness of the delayed transition itself
  (`perturbed_delayed_transition`): a uniformly `ε`-close trajectory keeps the
  transition, with the threshold moving by at most `ε/κ` where `κ` is the growth
  rate after the threshold;
* prove that the ratio between test delay and train delay is unbounded
  (`grokking_ratio_unbounded`): weakening the test signal makes the grokking
  window arbitrarily long compared with the time to fit the training set.
-/

namespace GrokkingVector

open Finset Set

/-! ### Convexity: the tropical structure of the ramped output -/

/-- A real affine function is convex. -/
theorem affine_convexOn (u v : ℝ) : ConvexOn ℝ Set.univ (fun t : ℝ => t * u + v) := by
  refine ⟨convex_univ, fun x _ y _ p q hp hq hpq => ?_⟩
  simp only [smul_eq_mul]
  have h : (p * x + q * y) * u + v = p * (x * u + v) + q * (y * u + v) := by
    linear_combination (-v) * hpq
  exact le_of_eq h

/-- A rectified affine function is convex: this is the tropical
"max of monomials" convexity of `Catalog/Tropical/NeuralCoding`. -/
theorem relu_affine_convexOn (u v : ℝ) :
    ConvexOn ℝ Set.univ (fun t : ℝ => relu (t * u + v)) := by
  have h := (affine_convexOn u v).sup (convexOn_const (0 : ℝ) convex_univ)
  convert h using 1

/-- Finite sums of convex functions are convex. -/
theorem convexOn_finset_sum {ι : Type*} (s : Finset ι) (f : ι → ℝ → ℝ)
    (hf : ∀ i ∈ s, ConvexOn ℝ Set.univ (f i)) :
    ConvexOn ℝ Set.univ (fun t => ∑ i ∈ s, f i t) := by
  classical
  induction s using Finset.induction with
  | empty => simpa using convexOn_const (0 : ℝ) convex_univ
  | insert i s hi ih =>
      have hrw : (fun t => ∑ x ∈ insert i s, f x t)
          = fun t => f i t + ∑ x ∈ s, f x t := by
        funext t; rw [Finset.sum_insert hi]
      rw [hrw]
      exact (hf i (Finset.mem_insert_self i s)).add
        (ih fun j hj => hf j (Finset.mem_insert_of_mem hj))

/-- **The ramped network output is a convex (tropical) function of the ramp
parameter** whenever the output weights are nonnegative. -/
theorem netRamp_convexOn {m d : ℕ} (W : Fin m → Fin d → ℝ) (b a : Fin m → ℝ) (c : ℝ)
    (p : Fin d → ℝ) (ha : ∀ j, 0 ≤ a j) :
    ConvexOn ℝ Set.univ (netRamp W b a c p) := by
  have hrw : netRamp W b a c p
      = fun t => c + ∑ j, a j * relu (t * signal W p j + b j) :=
    funext fun t => netRamp_eq W b a c p t
  rw [hrw]
  refine (convexOn_const c convex_univ).add ?_
  refine convexOn_finset_sum _ _ fun j _ => ?_
  have h := (relu_affine_convexOn (signal W p j) (b j)).smul (ha j)
  simpa [smul_eq_mul] using h

/-- **The failure set is an interval.**  The set of ramp times at which the
network output has not yet become positive is convex, so the delayed transition
happens exactly once: there is no "un-generalizing". -/
theorem failure_set_convex {m d : ℕ} (W : Fin m → Fin d → ℝ) (b a : Fin m → ℝ) (c : ℝ)
    (p : Fin d → ℝ) (ha : ∀ j, 0 ≤ a j) :
    Convex ℝ {t : ℝ | netRamp W b a c p t ≤ 0} := by
  have h := (netRamp_convexOn W b a c p ha).convex_le 0
  simpa using h

/-! ### Quantitative bounds on the delay -/

/-- With nonpositive hidden biases the ramped output is dominated by its
linearization at nonnegative ramp times. -/
theorem netRamp_le_linear {m d : ℕ} (W : Fin m → Fin d → ℝ) (b a : Fin m → ℝ) (c : ℝ)
    (p : Fin d → ℝ) (ha : ∀ j, 0 ≤ a j) (hb : ∀ j, b j ≤ 0)
    (hsig : ∀ j, 0 ≤ signal W p j) {t : ℝ} (ht : 0 ≤ t) :
    netRamp W b a c p t ≤ c + t * ∑ j, a j * signal W p j := by
  have hlin : ∑ j, a j * (t * signal W p j) = t * ∑ j, a j * signal W p j := by
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun j _ => by ring
  have hsum : ∑ j, a j * relu (t * signal W p j + b j)
      ≤ ∑ j, a j * (t * signal W p j) := by
    refine Finset.sum_le_sum fun j _ => ?_
    exact mul_le_mul_of_nonneg_left
      (max_le (by linarith [hb j]) (mul_nonneg ht (hsig j))) (ha j)
  rw [netRamp_eq, ← hlin]
  linarith

/-- **Lower bound on the delay.**  A sharp threshold for the ramped output of a
network with negative output bias `c` and total signal `S > 0` is at least
`|c| / S`: strong output bias or weak signal means a long delay. -/
theorem delay_lower_bound_of_threshold {m d : ℕ} (W : Fin m → Fin d → ℝ)
    (b a : Fin m → ℝ) (c : ℝ) (p : Fin d → ℝ) (ha : ∀ j, 0 ≤ a j) (hb : ∀ j, b j ≤ 0)
    (hsig : ∀ j, 0 ≤ signal W p j)
    (hc : c < 0) (hS : 0 < ∑ j, a j * signal W p j) {tau : ℝ}
    (hafter : ∀ t, tau < t → 0 < netRamp W b a c p t) :
    -c / (∑ j, a j * signal W p j) ≤ tau := by
  set S : ℝ := ∑ j, a j * signal W p j with hSdef
  by_contra hcon
  push_neg at hcon
  have hbound : 0 < -c / S := div_pos (by linarith) hS
  set t : ℝ := max tau 0 + (-c / S - max tau 0) / 2 with htdef
  have hmaxlt : max tau 0 < -c / S := max_lt hcon hbound
  have ht1 : tau < t := by
    have h1 : tau ≤ max tau 0 := le_max_left _ _
    have h2 : 0 < (-c / S - max tau 0) / 2 := by linarith
    linarith
  have ht0 : 0 ≤ t := by
    have h1 : (0 : ℝ) ≤ max tau 0 := le_max_right _ _
    have h2 : 0 < (-c / S - max tau 0) / 2 := by linarith
    linarith
  have ht2 : t < -c / S := by
    have h2 : 0 < (-c / S - max tau 0) / 2 := by linarith
    simp only [htdef]
    linarith
  have hpos := hafter t ht1
  have hle := netRamp_le_linear W b a c p ha hb hsig ht0
  have hlin : c + t * S < 0 := by
    have : t * S < -c := by
      rw [lt_div_iff₀ hS] at ht2
      linarith
    linarith
  linarith

/-- **Upper bound on the delay.**  A single active hidden unit already forces the
transition by time `(|c|/a_{j₀} - b_{j₀})/g_{j₀}`. -/
theorem delay_upper_bound_of_threshold {m d : ℕ} (W : Fin m → Fin d → ℝ)
    (b a : Fin m → ℝ) (c : ℝ) (p : Fin d → ℝ) (ha : ∀ j, 0 ≤ a j) {j₀ : Fin m}
    (ha₀ : 0 < a j₀) (hs₀ : 0 < signal W p j₀) {tau : ℝ}
    (hbefore : ∀ t ≤ tau, netRamp W b a c p t ≤ 0) :
    tau ≤ (-c / a j₀ - b j₀) / signal W p j₀ := by
  by_contra hcon
  push_neg at hcon
  set T : ℝ := (-c / a j₀ - b j₀) / signal W p j₀ with hT
  have hTs : T * signal W p j₀ = -c / a j₀ - b j₀ := by
    rw [hT]; exact div_mul_cancel₀ _ (ne_of_gt hs₀)
  set T' : ℝ := (T + tau) / 2 with hT'
  have hTT' : T < T' := by simp only [hT']; linarith
  have hT'tau : T' ≤ tau := by simp only [hT']; linarith
  have hle := hbefore T' hT'tau
  rw [netRamp_eq] at hle
  have hstrict : -c / a j₀ < T' * signal W p j₀ + b j₀ := by
    have := mul_lt_mul_of_pos_right hTT' hs₀
    have hval : T * signal W p j₀ + b j₀ = -c / a j₀ := by rw [hTs]; ring
    linarith
  have hterm : -c < a j₀ * relu (T' * signal W p j₀ + b j₀) := by
    have h1 : -c / a j₀ < relu (T' * signal W p j₀ + b j₀) :=
      lt_of_lt_of_le hstrict (le_relu _)
    calc -c = a j₀ * (-c / a j₀) := by field_simp
      _ < a j₀ * relu (T' * signal W p j₀ + b j₀) := by
          exact mul_lt_mul_of_pos_left h1 ha₀
  have hsum : a j₀ * relu (T' * signal W p j₀ + b j₀)
      ≤ ∑ j, a j * relu (T' * signal W p j + b j) :=
    Finset.single_le_sum (f := fun j => a j * relu (T' * signal W p j + b j))
      (fun j _ => mul_nonneg (ha j) (relu_nonneg _)) (Finset.mem_univ j₀)
  linarith

/-- **Delay scaling law.**  Combining the two bounds, any sharp threshold of the
ramped output is sandwiched between the total-signal bound and the
single-unit bound. -/
theorem delay_scaling_sandwich {m d : ℕ} (W : Fin m → Fin d → ℝ) (b a : Fin m → ℝ)
    (c : ℝ) (p : Fin d → ℝ) (ha : ∀ j, 0 ≤ a j) (hb : ∀ j, b j ≤ 0) (hc : c < 0)
    (hsig : ∀ j, 0 ≤ signal W p j) {j₀ : Fin m} (ha₀ : 0 < a j₀) (hs₀ : 0 < signal W p j₀)
    (hS : 0 < ∑ j, a j * signal W p j) {tau : ℝ}
    (hbefore : ∀ t ≤ tau, netRamp W b a c p t ≤ 0)
    (hafter : ∀ t, tau < t → 0 < netRamp W b a c p t) :
    -c / (∑ j, a j * signal W p j) ≤ tau ∧
      tau ≤ (-c / a j₀ - b j₀) / signal W p j₀ :=
  ⟨delay_lower_bound_of_threshold W b a c p ha hb hsig hc hS hafter,
    delay_upper_bound_of_threshold W b a c p ha ha₀ hs₀ hbefore⟩

/-! ### Robustness of the delayed transition -/

/-- **The delayed transition is robust.**  If a perturbed trajectory stays
uniformly within `ε` of a trajectory that is nonpositive before `τ` and grows at
rate at least `κ > 0` after `τ`, then the perturbed trajectory is still at most
`ε` before `τ` and strictly positive after `τ + ε/κ`: the transition survives,
with the threshold displaced by at most `ε/κ`. -/
theorem perturbed_delayed_transition (f g : ℝ → ℝ) (eps kappa tau : ℝ)
    (heps : 0 ≤ eps) (hkappa : 0 < kappa)
    (hclose : ∀ t, |g t - f t| ≤ eps)
    (hbefore : ∀ t ≤ tau, f t ≤ 0)
    (hgrow : ∀ t, tau < t → kappa * (t - tau) ≤ f t) :
    (∀ t ≤ tau, g t ≤ eps) ∧ (∀ t, tau + eps / kappa < t → 0 < g t) := by
  constructor
  · intro t ht
    have h1 := abs_le.mp (hclose t)
    have h2 := hbefore t ht
    linarith [h1.2]
  · intro t ht
    have htau : tau < t := by
      have : 0 ≤ eps / kappa := div_nonneg heps hkappa.le
      linarith
    have hf := hgrow t htau
    have hkey : eps < kappa * (t - tau) := by
      have h0 : eps / kappa < t - tau := by linarith
      have h1 := (div_lt_iff₀ hkappa).mp h0
      nlinarith
    have h1 := abs_le.mp (hclose t)
    linarith [h1.1]

/-! ### The grokking ratio can be made arbitrarily large -/

/-- Single-unit ramped score with signal strength `s` and unit output bias. -/
noncomputable def unitScore (s t : ℝ) : ℝ := -1 + relu (t * s)

/-- For a positive signal strength the single-unit score has sharp threshold
`1/s`. -/
theorem unitScore_threshold (s : ℝ) (hs : 0 < s) :
    (∀ t ≤ 1 / s, unitScore s t ≤ 0) ∧ (∀ t, 1 / s < t → 0 < unitScore s t) := by
  constructor
  · intro t ht
    simp only [unitScore, relu]
    have hts : t * s ≤ 1 := (le_div_iff₀ hs).mp ht
    have : max (t * s) 0 ≤ 1 := max_le hts zero_le_one
    linarith
  · intro t ht
    simp only [unitScore, relu]
    have hts : 1 < t * s := (div_lt_iff₀ hs).mp ht
    have : max (t * s) 0 = t * s := max_eq_left (by linarith)
    rw [this]
    linarith

/-- **The grokking ratio is unbounded.**  Fixing the training signal strength,
the ratio (test delay)/(train delay) can be made larger than any `R` by taking
the test signal weak enough — while both delays remain finite and sharp. -/
theorem grokking_ratio_unbounded (strain : ℝ) (hstrain : 0 < strain) (R : ℝ) :
    ∃ stest : ℝ, 0 < stest ∧
      (∀ t ≤ 1 / strain, unitScore strain t ≤ 0) ∧
      (∀ t, 1 / strain < t → 0 < unitScore strain t) ∧
      (∀ t ≤ 1 / stest, unitScore stest t ≤ 0) ∧
      (∀ t, 1 / stest < t → 0 < unitScore stest t) ∧
      R < (1 / stest) / (1 / strain) := by
  obtain ⟨stest, hstest, hlt⟩ : ∃ stest : ℝ, 0 < stest ∧ stest * (R + 1) < strain := by
    rcases le_or_gt (R + 1) 0 with hR | hR
    · exact ⟨strain, hstrain, by nlinarith⟩
    · refine ⟨strain / (2 * (R + 1)), by positivity, ?_⟩
      rw [div_mul_eq_mul_div, mul_comm]
      rw [div_lt_iff₀ (by positivity)]
      nlinarith
  refine ⟨stest, hstest, (unitScore_threshold strain hstrain).1,
    (unitScore_threshold strain hstrain).2, (unitScore_threshold stest hstest).1,
    (unitScore_threshold stest hstest).2, ?_⟩
  have hratio : (1 / stest) / (1 / strain) = strain / stest := by
    field_simp
  rw [hratio, lt_div_iff₀ hstest]
  nlinarith

end GrokkingVector