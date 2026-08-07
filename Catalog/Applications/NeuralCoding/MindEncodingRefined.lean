import Mathlib

/-!
# Digital Immortality, Refined: Merging, Directionality, and Incompressibility

This file extends the information-theoretic model of a neural connectome with
several new, self-contained results.  A connectome on `N` neurons is a Boolean
assignment on the `synapseSlots N = N.choose 2` unordered pairs of neurons
(one flag per potential synapse).

The new theorems are:

* `synapseSlots_add` — **superadditivity of mind-merging**: joining an `M`-neuron
  brain and an `N`-neuron brain creates exactly `M * N` *new* cross-synapse
  slots beyond the two brains' own slots, i.e.
  `synapseSlots (M + N) = synapseSlots M + synapseSlots N + M * N`.
* `connectome_count_mono` — the number of connectomes is monotone in the neuron
  count.
* `directed_eq_two_mul`, `directed_count_sq` — modelling directed synapses
  doubles the slot count, hence *squares* the number of distinguishable minds.
* `card_connectome`, `card_weighted_connectome` — exact state counts for Boolean
  and `w`-valued (weighted) synapses.
* `few_small_codewords` — an incompressibility counting bound: under any
  injective code, at most `B` connectomes receive a codeword of numerical value
  `< B`.
* `most_incompressible` — consequently at least `2 ^ synapseSlots N - B`
  connectomes are *incompressible* below `B` (the overwhelming majority when
  `B ≪ 2 ^ synapseSlots N`).
* `synapseSlots_lower_real`, `neuron_count_bound`, `neuron_count_sqrt_bound` —
  feeding the quadratic slot count into the Bekenstein bound yields an explicit
  upper bound on the number of neurons whose connectome fits in a given physical
  region: `N ≤ 1 + √(2 · Bekenstein capacity)`.
-/

namespace DigitalImmortality.Refined

open scoped BigOperators
open Real

/-- Number of potential synapses among `N` neurons: one per unordered pair. -/
def synapseSlots (N : ℕ) : ℕ := N.choose 2

/-- Number of *directed* synapse slots: one per ordered pair of distinct
neurons, `N * (N - 1)`. -/
def directedSlots (N : ℕ) : ℕ := N * (N - 1)

/-- A connectome configuration: a Boolean flag per potential synapse. -/
abbrev Connectome (N : ℕ) := Fin (synapseSlots N) → Bool

/-! ### State counts -/

/-- There are exactly `2 ^ (N.choose 2)` distinct connectomes on `N` neurons. -/
theorem card_connectome (N : ℕ) :
    Fintype.card (Connectome N) = 2 ^ synapseSlots N := by
  rw [Fintype.card_pi]; simp

/-- With `w` weight levels per synapse there are exactly `w ^ (N.choose 2)`
distinct weighted connectomes. -/
theorem card_weighted_connectome (N w : ℕ) :
    Fintype.card (Fin (synapseSlots N) → Fin w) = w ^ synapseSlots N := by
  simp

/-! ### Arithmetic of the slot count -/

/-- Twice the slot count equals `N (N - 1)`. -/
theorem two_mul_synapseSlots (N : ℕ) : 2 * synapseSlots N = N * (N - 1) := by
  unfold synapseSlots
  rw [Nat.choose_two_right, mul_comm]
  exact Nat.div_mul_cancel (even_iff_two_dvd.mp (Nat.even_mul_pred_self _))

/-- **Superadditivity of mind-merging.**  Fusing an `M`-neuron brain with an
`N`-neuron brain produces exactly `M * N` new cross-synapse slots on top of the
two brains' internal slots. -/
theorem synapseSlots_add (M N : ℕ) :
    synapseSlots (M + N) = synapseSlots M + synapseSlots N + M * N := by
  have h : 2 * synapseSlots (M + N)
      = 2 * (synapseSlots M + synapseSlots N + M * N) := by
    rw [two_mul_synapseSlots, mul_add, mul_add, two_mul_synapseSlots,
        two_mul_synapseSlots]
    cases M <;> cases N
    all_goals simp
    all_goals ring_nf
  exact Nat.eq_of_mul_eq_mul_left (by norm_num) h

/-- The number of connectomes is monotone in the neuron count. -/
theorem connectome_count_mono {M N : ℕ} (h : M ≤ N) :
    2 ^ synapseSlots M ≤ 2 ^ synapseSlots N :=
  Nat.pow_le_pow_right (by norm_num) (Nat.choose_le_choose 2 h)

/-- Modelling synapses as directed doubles the slot count. -/
theorem directed_eq_two_mul (N : ℕ) : directedSlots N = 2 * synapseSlots N := by
  rw [directedSlots, two_mul_synapseSlots]

/-- **Directionality squares the mind count.**  The number of directed
connectomes is the square of the number of undirected ones. -/
theorem directed_count_sq (N : ℕ) :
    2 ^ directedSlots N = (2 ^ synapseSlots N) ^ 2 := by
  rw [directed_eq_two_mul, ← pow_mul, mul_comm]

/-! ### Incompressibility (counting / Kolmogorov flavour) -/

/-- **Incompressibility counting bound.**  Under any injective encoding of
connectomes as natural numbers, at most `B` connectomes are assigned a codeword
whose numerical value is `< B`. -/
theorem few_small_codewords (N B : ℕ) {enc : Connectome N → ℕ}
    (hinj : Function.Injective enc) :
    (Finset.univ.filter (fun c : Connectome N => enc c < B)).card ≤ B := by
  have hsub : (Finset.univ.filter (fun c : Connectome N => enc c < B)).image enc
      ⊆ Finset.range B := by
    intro x hx
    simp only [Finset.mem_image, Finset.mem_filter] at hx
    obtain ⟨c, ⟨_, hc⟩, rfl⟩ := hx
    exact Finset.mem_range.mpr hc
  calc (Finset.univ.filter (fun c : Connectome N => enc c < B)).card
      = ((Finset.univ.filter (fun c : Connectome N => enc c < B)).image enc).card := by
        rw [Finset.card_image_of_injective _ hinj]
    _ ≤ (Finset.range B).card := Finset.card_le_card hsub
    _ = B := Finset.card_range B

/-- **Most connectomes are incompressible.**  Under any injective encoding, at
least `2 ^ synapseSlots N - B` connectomes get a codeword of value `≥ B`.  Since
the slot count is quadratic in `N`, taking `B = 2 ^ (synapseSlots N - 1)` shows
that a full half of all minds resist compression below the raw slot count. -/
theorem most_incompressible (N B : ℕ) {enc : Connectome N → ℕ}
    (hinj : Function.Injective enc) :
    2 ^ synapseSlots N - B ≤
      (Finset.univ.filter (fun c : Connectome N => B ≤ enc c)).card := by
  have hcongr : (Finset.univ.filter (fun c : Connectome N => B ≤ enc c))
      = (Finset.univ.filter (fun c : Connectome N => ¬ enc c < B)) := by
    apply Finset.filter_congr; intro x _; simp [not_lt]
  have hsplit := Finset.card_filter_add_card_filter_not
    (s := Finset.univ (α := Connectome N)) (fun c => enc c < B)
  rw [← hcongr, Finset.card_univ, card_connectome] at hsplit
  have := few_small_codewords N B hinj
  omega

/-! ### Physical bound via the Bekenstein bound -/

/-- The Bekenstein information bound, in bits, for a region of radius `R`,
enclosed energy `E`, reduced Planck constant `hbar` and speed of light `c`:
`I ≤ 2π R E / (ħ c ln 2)`. -/
noncomputable def bekensteinBits (R E hbar c : ℝ) : ℝ :=
  2 * π * R * E / (hbar * c * Real.log 2)

/-- Real-valued lower bound on the slot count: `(N - 1)² ≤ 2 · slots`. -/
theorem synapseSlots_lower_real (N : ℕ) (hN : 1 ≤ N) :
    ((N : ℝ) - 1) ^ 2 ≤ 2 * (synapseSlots N : ℝ) := by
  have hcast : ((N - 1 : ℕ) : ℝ) = (N : ℝ) - 1 := by
    rw [Nat.cast_sub hN]; norm_num
  have h : (2 : ℝ) * (synapseSlots N : ℝ) = (N : ℝ) * ((N : ℝ) - 1) := by
    have h2 : ((2 * synapseSlots N : ℕ) : ℝ) = ((N * (N - 1) : ℕ) : ℝ) :=
      congrArg (Nat.cast : ℕ → ℝ) (two_mul_synapseSlots N)
    push_cast [hcast] at h2 ⊢
    linarith [h2]
  have hNr : (1 : ℝ) ≤ (N : ℝ) := by exact_mod_cast hN
  rw [h]; nlinarith [hNr]

/-- **Neuron-count bound from the Bekenstein bound.**  If the `synapseSlots N`
bits needed to distinguish all `N`-neuron connectomes fit within the Bekenstein
capacity of a region, then `(N - 1)²` is bounded by twice that capacity. -/
theorem neuron_count_bound (N : ℕ) (R E hbar c : ℝ) (hN : 1 ≤ N)
    (hstore : (synapseSlots N : ℝ) ≤ bekensteinBits R E hbar c) :
    ((N : ℝ) - 1) ^ 2 ≤ 2 * bekensteinBits R E hbar c := by
  have := synapseSlots_lower_real N hN
  linarith

/-- **Explicit neuron ceiling.**  The number of neurons whose connectome can be
stored in a region is at most `1 + √(2 · Bekenstein capacity)`. -/
theorem neuron_count_sqrt_bound (N : ℕ) (R E hbar c : ℝ) (hN : 1 ≤ N)
    (hstore : (synapseSlots N : ℝ) ≤ bekensteinBits R E hbar c) :
    (N : ℝ) ≤ 1 + Real.sqrt (2 * bekensteinBits R E hbar c) := by
  set B := bekensteinBits R E hbar c with hB
  have hquad : ((N : ℝ) - 1) ^ 2 ≤ 2 * B := neuron_count_bound N R E hbar c hN hstore
  have hNr : (1 : ℝ) ≤ (N : ℝ) := by exact_mod_cast hN
  have hnn : (0 : ℝ) ≤ (N : ℝ) - 1 := by linarith
  have hsq : ((N : ℝ) - 1) ^ 2 ≤ (Real.sqrt (2 * B)) ^ 2 := by
    rw [Real.sq_sqrt (by nlinarith [hnn, hquad])]
    exact hquad
  have : (N : ℝ) - 1 ≤ Real.sqrt (2 * B) := by
    nlinarith [Real.sqrt_nonneg (2 * B), hsq, hnn]
  linarith

/-! ### Concrete instantiations -/

-- A 5-neuron column admits `C(5,2) = 10` synapse slots and `1024` connectomes.
example : synapseSlots 5 = 10 := by decide
example : Fintype.card (Connectome 5) = 1024 := by rw [card_connectome]; decide

-- Merging a 3-neuron and a 4-neuron brain creates `3 * 4 = 12` cross-synapses.
example : synapseSlots (3 + 4) = synapseSlots 3 + synapseSlots 4 + 12 := by decide

-- Directed connectomes on 4 neurons: `2^12 = (2^6)^2 = 4096`.
example : 2 ^ directedSlots 4 = (2 ^ synapseSlots 4) ^ 2 := by decide

#check @synapseSlots_add
#check @most_incompressible
#check @neuron_count_sqrt_bound

end DigitalImmortality.Refined