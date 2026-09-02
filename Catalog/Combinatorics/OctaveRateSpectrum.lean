import Combinatorics.OctaveShiftLaw

/-!
# The exchange-rate spectrum: why the rate is *one* octave (NET-66)

`Combinatorics.OctaveShiftLaw` fixes the exchange rate at one context doubling per scale
doubling.  Nothing in the abstraction requires that: a rate-`p` law reads

`F(s+1, j+p) = F(s, j)`,  `F(s+1, i) = F(s, 0)` for `i < p`,

i.e. one scale doubling buys `p` context doublings.  This file develops the whole
spectrum and then *identifies* the measured rate.

* `RateFamily.eq_shiftBy` — rigidity at every rate: a rate-`p` family is its base chain
  translated by `p·s` octaves.  The `p = 1` rigidity theorem is the special case.
* `RateFamily.antitone_scale`, `RateFamily.no_flattening` — the two structural
  refutations (P3, P2) survive the whole spectrum: at *no* rate can scale amplify or
  eliminate context sensitivity.
* `RateFamily.budget_table` — at rate `p` a fixed budget gains exactly `p` context
  doublings per scale step.
* `rate_unique` — the rate is identifiable: two rate laws with a common strictly
  increasing base chain that predict the same `s = 1` chain have the same rate.
* `net66_rate_eq_one` — **the measurement selects `p = 1`**: any rate-`p` family whose
  base is the measured 0.5B chain `{16, 20, 24}` and whose 1.5B cell at `ctx = 2048`
  reads `20` must have `p = 1`.  In particular the rate-`2` law (which predicts `16`
  there) is refuted by that single cell, and `net66_rate_two_refuted` records this.
* `rate_p_prediction` — what each rate predicts for the next scale step, the
  discriminating experiment for the 7B ladder.
-/

namespace Combinatorics.OctaveRateSpectrum

open Combinatorics.OctaveShiftLaw

/-- The shift of a chain by `p` octaves per scale step. -/
def shiftBy (p : ℕ) (K : Chain) (s : ℕ) : Chain := fun j => K (j - p * s)

@[simp] theorem shiftBy_apply (p : ℕ) (K : Chain) (s j : ℕ) :
    shiftBy p K s j = K (j - p * s) := rfl

theorem shiftBy_one (K : Chain) (s : ℕ) : shiftBy 1 K s = shift K s := by
  funext j; simp [shiftBy, shift]

/-- A **rate-`p` scale family**: one scale doubling buys `p` context doublings. -/
structure RateFamily (p : ℕ) where
  /-- `chain s j` is the knee at scale `s` and context octave `j`. -/
  chain : ℕ → Chain
  /-- The rate is positive. -/
  rate_pos : 0 < p
  /-- The base chain is monotone in context. -/
  base_mono : Monotone (chain 0)
  /-- One scale doubling buys `p` context doublings. -/
  exchange : ∀ s j, chain (s + 1) (j + p) = chain s j
  /-- Below the purchased headroom, scale is inert. -/
  boundary : ∀ s i, i < p → chain (s + 1) i = chain s 0

namespace RateFamily

variable {p : ℕ} (F : RateFamily p)

/-- **Rigidity at rate `p`.**  The two local laws determine the whole table: the chain at
scale `s` is the base chain translated by `p·s` octaves. -/
theorem eq_shiftBy : ∀ s, F.chain s = shiftBy p (F.chain 0) s := by
  intro s
  induction s with
  | zero => funext j; simp [shiftBy]
  | succ s ih =>
      funext j
      rcases Nat.lt_or_ge j p with hj | hj
      · have h0 : F.chain s 0 = F.chain 0 0 := by
          rw [ih]
          simp [shiftBy]
        rw [F.boundary s j hj, h0]
        have : j - p * (s + 1) = 0 := by
          have : p ≤ p * (s + 1) := Nat.le_mul_of_pos_right p (Nat.succ_pos s)
          omega
        simp [shiftBy, this]
      · obtain ⟨i, rfl⟩ : ∃ i, j = i + p := ⟨j - p, by omega⟩
        rw [F.exchange s i, ih]
        have : i + p - p * (s + 1) = i - p * s := by
          have : p * (s + 1) = p * s + p := by ring
          omega
        simp [shiftBy, this]

theorem apply_eq (s j : ℕ) : F.chain s j = F.chain 0 (j - p * s) := by
  rw [F.eq_shiftBy s]; rfl

theorem chain_mono (s : ℕ) : Monotone (F.chain s) := by
  intro a b h
  rw [F.apply_eq s a, F.apply_eq s b]
  exact F.base_mono (by omega)

/-- **P3 at every rate.**  Scale can never raise the knee, whatever the exchange rate. -/
theorem antitone_scale (s j : ℕ) : F.chain (s + 1) j ≤ F.chain s j := by
  rw [F.apply_eq (s + 1) j, F.apply_eq s j]
  refine F.base_mono ?_
  have : p * s ≤ p * (s + 1) := Nat.mul_le_mul_left p (by omega)
  omega

/-- **P2 at every rate.**  An unbounded base chain stays unbounded at every scale: no
exchange rate, however generous, flattens the context axis. -/
theorem no_flattening (hub : ∀ b, ∃ j, b < F.chain 0 j) (s b : ℕ) : ∃ j, b < F.chain s j := by
  obtain ⟨j, hj⟩ := hub b
  refine ⟨j + p * s, ?_⟩
  rw [F.apply_eq s (j + p * s)]
  simpa using hj

/-- **The rate-`p` budget table.**  A fixed key budget gains exactly `p` context
doublings per scale doubling. -/
theorem budget_table {b : ℕ} (hne : ∃ j, b < F.chain 0 j) (hf : 0 < firstFail (F.chain 0) b)
    (s : ℕ) : firstFail (F.chain s) b = firstFail (F.chain 0) b + p * s := by
  have hkey : F.chain s = shift (F.chain 0) (p * s) := by
    funext j
    rw [F.apply_eq s j]
    rfl
  rw [hkey]
  exact firstFail_shift hne hf (p * s)

end RateFamily

/-! ## Identifying the rate -/

/-- **The rate is identifiable.**  Two exchange laws sharing a strictly increasing base
chain and predicting the same first scale step have the same rate. -/
theorem rate_unique {K : Chain} (hK : StrictMono K) {p q : ℕ}
    (h : ∀ j, shiftBy p K 1 j = shiftBy q K 1 j) : p = q := by
  have : shift K p = shift K q := by
    funext j
    have := h j
    simpa [shiftBy, shift] using this
  exact shift_rate_unique hK this

/-- What a rate-`p` law predicts at scale `s`, octave `j`, for the measured base chain. -/
theorem rate_p_prediction {p : ℕ} (F : RateFamily p) (hbase : F.chain 0 = net66Base)
    (s j : ℕ) : F.chain s j = 16 + 4 * (j - p * s) := by
  rw [F.apply_eq s j, hbase]
  rfl

/-- **The measurement selects the one-octave rate.**  Any exchange law whose base is the
measured 0.5B chain `{16, 20, 24}` and which reproduces the measured 1.5B cell at
`ctx = 2048` (`k* = 20`) has rate exactly `1`. -/
theorem net66_rate_eq_one {p : ℕ} (F : RateFamily p) (hbase : F.chain 0 = net66Base)
    (hcell : F.chain 1 2 = 20) : p = 1 := by
  have h := rate_p_prediction F hbase 1 2
  rw [hcell] at h
  have hp : 0 < p := F.rate_pos
  have : 2 - p * 1 = 1 := by omega
  omega

/-- **The rate-`2` law is refuted by a single cell.**  A two-octaves-per-scale-step law
with the measured base chain predicts `k*(1.5B, 2048) = 16`, not the measured `20`. -/
theorem net66_rate_two_refuted (F : RateFamily 2) (hbase : F.chain 0 = net66Base) :
    F.chain 1 2 = 16 ∧ F.chain 1 2 ≠ 20 := by
  have h := rate_p_prediction F hbase 1 2
  norm_num at h
  exact ⟨h, by omega⟩

/-- **Every rate is consistent.**  For each positive `p` and each monotone base chain the
rate-`p` law has a model, so the refutations above are statements about the data, not
about the consistency of the laws. -/
def ofBase (p : ℕ) (hp : 0 < p) (K : Chain) (hK : Monotone K) : RateFamily p where
  chain := fun s => shiftBy p K s
  rate_pos := hp
  base_mono := by
    intro a b h
    simp only [shiftBy]
    exact hK (by omega)
  exchange := fun s j => by
    simp only [shiftBy]
    congr 1
    have : p * (s + 1) = p * s + p := by ring
    omega
  boundary := fun s i hi => by
    simp only [shiftBy]
    congr 1
    have h1 : p * (s + 1) = p * s + p := by ring
    omega

/-- The rate-`2` model on the measured base chain: it predicts `k*(1.5B, 2048) = 16`,
which the measurement contradicts. -/
theorem net66_rate_two_model :
    (ofBase 2 (by norm_num) net66Base net66Base_mono).chain 1 2 = 16 := by
  norm_num [ofBase, shiftBy, net66Base]

/-- The measured family is the rate-`1` member of the spectrum. -/
def net66Rate : RateFamily 1 where
  chain := fun s => shift net66Base s
  rate_pos := Nat.one_pos
  base_mono := by simpa using net66Base_mono
  exchange := fun s j => shift_succ_succ net66Base s j
  boundary := fun s i hi => by
    have : i = 0 := by omega
    subst this
    exact shift_succ_zero net66Base s

theorem net66Rate_chain_eq (s j : ℕ) : net66Rate.chain s j = net66.chain s j := rfl

/-- The rate-`1` reading reproduces the measured 1.5B cell, so the identification in
`net66_rate_eq_one` is not vacuous. -/
theorem net66Rate_cell : net66Rate.chain 1 2 = 20 := by
  norm_num [net66Rate, shift, net66Base]

end Combinatorics.OctaveRateSpectrum