import Combinatorics.OctaveShiftLaw

/-!
# Stability of the one-octave law under measurement noise (NET-66)

`Combinatorics.OctaveShiftLaw` proves the *exact* rigidity statement: the exchange law
`F(s+1, j+1) = F(s, j)` and the boundary law `F(s+1, 0) = F(s, 0)` force the whole
scale × context knee table to be one chain translated by one octave per scale step.

A measured table never satisfies an equation on the nose: knees are read off a finite
budget grid, so each cell carries an error.  This file proves that the law is *stable*:

* `ApproxScaleFamily.abs_sub_shift_le` — if every exchange and boundary comparison holds
  up to `ε`, then the whole table is within `ε · s` of the exactly shifted one.  Errors
  accumulate only linearly in the number of scale steps, so a two-scale ladder such as
  NET-66 is within `ε` of exact.
* `ApproxScaleFamily.exact_of_zero_error` — at `ε = 0` this recovers the rigidity theorem
  in integer form, so the stable statement is a genuine deformation of the exact one.
* `rate_unique_of_noise` — **noise-robust identifiability**: if the base chain rises by at
  least `δ` per octave and the noise level is `ε < δ`, the octave rate is still uniquely
  determined by the data.  For NET-66 (`δ = 4` keys per doubling) any knee error up to `3`
  keys still pins the rate at one octave (`net66_rate_robust`).
* `net66_predict_7B` — the falsifiable prediction the law makes for the next scale step:
  the `s = 2` chain must read `{16, 16, 16, 20}`, i.e. the first upward break moves to
  `ctx = 4096`.
-/

namespace Combinatorics.OctaveShiftStability

open Combinatorics.OctaveShiftLaw

/-! ## Approximate scale families -/

/-- A **noisy knee table**: integer-valued cells satisfying the exchange and boundary
laws up to an additive error `eps`. -/
structure ApproxScaleFamily (eps : ℤ) where
  /-- `chain s j` is the measured knee at scale `s` and context octave `j`. -/
  chain : ℕ → ℕ → ℤ
  /-- The exchange law holds up to `eps`. -/
  exchange : ∀ s j, |chain (s + 1) (j + 1) - chain s j| ≤ eps
  /-- The boundary law holds up to `eps`. -/
  boundary : ∀ s, |chain (s + 1) 0 - chain s 0| ≤ eps

namespace ApproxScaleFamily

variable {eps : ℤ} (F : ApproxScaleFamily eps)

/-- **Stability of the one-octave law.**  A table obeying the two local laws up to `eps`
is within `eps · s` of the exactly shifted table: the error accumulates only linearly in
the number of scale doublings. -/
theorem abs_sub_shift_le : ∀ s j, |F.chain s j - F.chain 0 (j - s)| ≤ eps * s := by
  intro s
  induction s with
  | zero => intro j; simp
  | succ s ih =>
      intro j
      have hpos : (0 : ℤ) ≤ eps := le_trans (abs_nonneg _) (F.boundary 0)
      cases j with
      | zero =>
          have h1 : |F.chain (s + 1) 0 - F.chain s 0| ≤ eps := F.boundary s
          have h2 : |F.chain s 0 - F.chain 0 0| ≤ eps * s := by simpa using ih 0
          have htri : |F.chain (s + 1) 0 - F.chain 0 0|
              ≤ |F.chain (s + 1) 0 - F.chain s 0| + |F.chain s 0 - F.chain 0 0| :=
            abs_sub_le _ _ _
          simp only [Nat.zero_sub]
          push_cast
          linarith
      | succ i =>
          have h1 : |F.chain (s + 1) (i + 1) - F.chain s i| ≤ eps := F.exchange s i
          have h2 : |F.chain s i - F.chain 0 (i - s)| ≤ eps * s := ih i
          have htri : |F.chain (s + 1) (i + 1) - F.chain 0 (i - s)|
              ≤ |F.chain (s + 1) (i + 1) - F.chain s i| + |F.chain s i - F.chain 0 (i - s)| :=
            abs_sub_le _ _ _
          have hsub : i + 1 - (s + 1) = i - s := by omega
          rw [hsub]
          have : |F.chain (s + 1) (i + 1) - F.chain 0 (i - s)| ≤ eps * s + eps := by linarith
          push_cast
          linarith

/-- At zero error, stability degenerates to the exact rigidity theorem. -/
theorem exact_of_zero_error (F : ApproxScaleFamily 0) (s j : ℕ) :
    F.chain s j = F.chain 0 (j - s) := by
  have h := F.abs_sub_shift_le s j
  simp only [zero_mul] at h
  have := abs_nonpos_iff.mp h
  linarith [sub_eq_zero.mp this]

end ApproxScaleFamily

/-! ## Noise-robust identifiability of the octave rate -/

/-- A chain rising by at least `delta` per octave rises by at least `delta * m` over `m`
octaves. -/
theorem le_of_rise {K : Chain} {delta : ℕ} (hrise : ∀ j, K j + delta ≤ K (j + 1)) :
    ∀ m, K 0 + delta * m ≤ K m := by
  intro m
  induction m with
  | zero => simp
  | succ m ih =>
      have := hrise m
      have : K 0 + delta * m + delta ≤ K (m + 1) := by omega
      calc K 0 + delta * (m + 1) = K 0 + delta * m + delta := by ring
        _ ≤ K (m + 1) := this

/-- **Noise-robust rate identifiability.**  If the base chain rises by at least `delta`
keys per context doubling and two octave shifts of it agree to within `eps < delta` at
every octave, the two shifts are equal.  A genuinely rising chain therefore pins the
scale ↔ context exchange rate even from noisy knee measurements. -/
theorem rate_unique_of_noise {K : Chain} {delta eps : ℕ} (hrise : ∀ j, K j + delta ≤ K (j + 1))
    (hlt : eps < delta) {a b : ℕ}
    (h : ∀ j, |(shift K a j : ℤ) - (shift K b j : ℤ)| ≤ (eps : ℤ)) : a = b := by
  have key : ∀ x y : ℕ, x < y → (∀ j, |(shift K x j : ℤ) - (shift K y j : ℤ)| ≤ (eps : ℤ)) →
      False := by
    intro x y hxy hxy'
    have hval := hxy' y
    simp only [shift, Nat.sub_self] at hval
    have hrise' : K 0 + delta * (y - x) ≤ K (y - x) := le_of_rise hrise (y - x)
    have hge : K 0 + delta ≤ K (y - x) := by
      have : 1 ≤ y - x := by omega
      nlinarith [hrise']
    have hZ : (delta : ℤ) ≤ (K (y - x) : ℤ) - (K 0 : ℤ) := by
      have : (K 0 : ℤ) + (delta : ℤ) ≤ (K (y - x) : ℤ) := by exact_mod_cast hge
      linarith
    have habs : (delta : ℤ) ≤ |(K (y - x) : ℤ) - (K 0 : ℤ)| := le_trans hZ (le_abs_self _)
    have : (eps : ℤ) < (delta : ℤ) := by exact_mod_cast hlt
    linarith [le_trans habs hval]
  rcases lt_trichotomy a b with hab | hab | hab
  · exact (key a b hab h).elim
  · exact hab
  · refine (key b a hab fun j => ?_).elim
    rw [abs_sub_comm]
    exact h j

/-- **The NET-66 rate survives realistic noise.**  The measured base chain rises by four
keys per context doubling, so any knee error up to three keys still identifies the shift
between the 0.5B and 1.5B chains as exactly one octave. -/
theorem net66_rate_robust {r : ℕ}
    (h : ∀ j, |(shift net66Base r j : ℤ) - (shift net66Base 1 j : ℤ)| ≤ 3) : r = 1 :=
  rate_unique_of_noise (K := net66Base) (delta := 4) (eps := 3)
    (fun j => by simp only [net66Base]; omega) (by norm_num) h

/-- **The prediction for the next scale step.**  If the one-octave law extends, the `s = 2`
cell (the 7B ladder) must read `{16, 16, 16, 20}`: the first upward break moves out to
`ctx = 4096`, and a 16-key budget covers it to `ctx = 2048`. -/
theorem net66_predict_7B :
    net66.chain 2 0 = 16 ∧ net66.chain 2 1 = 16 ∧ net66.chain 2 2 = 16 ∧
      net66.chain 2 3 = 20 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> norm_num [net66, shift, net66Base]

/-- The same prediction in budget-table form: at scale `2` a 16-key budget first fails at
octave `3` (ctx 4096). -/
theorem net66_predict_7B_budget : firstFail (net66.chain 2) 16 = 3 := by
  have h1 : net66.chain 0 1 = 20 := by norm_num [net66, shift, net66Base]
  have hne : ∃ j, 16 < net66.chain 0 j := ⟨1, by rw [h1]; norm_num⟩
  have hbase : firstFail (net66.chain 0) 16 = 1 := net66_budget_16.1
  rw [net66.budget_table hne (by rw [hbase]; omega) 2, hbase]

end Combinatorics.OctaveShiftStability