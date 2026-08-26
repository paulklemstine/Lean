/-
# Spike-origin degeneracy: the left-edge decile of a Fermat window carries only tiny residues

Setting (exp 589 / paper 239).  For a modulus `N` one scans trial points `j` in the
Fermat-style window `j ∈ (s, 3s]`, `s = ⌊√N⌋`, and records the residue `v = j² − N`.
Positions are normalised to `u = (j − s) / (2s) ∈ (0, 1]`.  The empirical study reports a
left-edge spike concentrated in the *first decile* `D1 = {u ≲ 1/10}` and asks whether the
"exclude `v < 2⁹⁵`" clause can discriminate anything there.

This file proves, by exact arithmetic, that the clause is **degenerate**: every `D1` point
of a `96`-bit modulus has `v < 2⁹⁵`, i.e. `bitlen v ≤ 95`, so the exclusion removes
*100 %* of the `D1` mass by geometry alone.  The mechanism is scale free
(`resid_lt_of_firstDecile_scalefree`: `v < 0.45 · N`) and it is **sharp**: past position
`u ≈ 0.21` the residue is provably full size, and in the continuum the exact transition
point is the crossing curve `u₀(N) = (√(1 + 2⁹⁵/N) − 1)/2`, which is pinned to the interval
`((√6 − 2)/4, (√2 − 1)/2] ⊂ (0.1123, 0.2072]`.  In particular the decile boundary `1/10`
lies *strictly below* the smallest possible crossing `(√6 − 2)/4 = 0.11237…`, which is the
structural reason for the degeneracy — and it also explains the reported kept-support left
edge `u ≈ 0.114`.
-/
import Mathlib

namespace SpikeOrigin

/-! ## Discrete layer: window, residue, first decile -/

/-- The residue attached to a trial point `j` for the modulus `N`, i.e. `j² − N`
(truncated subtraction; in all uses below `j > ⌊√N⌋`, so `j² > N`). -/
def resid (N j : ℕ) : ℕ := j ^ 2 - N

/-- The Fermat scan window: `⌊√N⌋ < j ≤ 3⌊√N⌋`. -/
def InWindow (N j : ℕ) : Prop := Nat.sqrt N < j ∧ j ≤ 3 * Nat.sqrt N

/-- The first decile of the window, in the (slack) form used by the experiment:
`δ = j − s` satisfies `5δ < s + 5`, i.e. `δ < 0.2 s + 1`.  Since the window has width
`2s`, this is the normalised position range `u = δ/(2s) ≲ 1/10`. -/
def FirstDecile (N j : ℕ) : Prop := Nat.sqrt N < j ∧ 5 * (j - Nat.sqrt N) < Nat.sqrt N + 5

lemma resid_pos {N j : ℕ} (hj : Nat.sqrt N < j) : 0 < resid N j := by
  have h : N < j ^ 2 := lt_of_lt_of_le (Nat.lt_succ_sqrt' N) (Nat.pow_le_pow_left hj 2)
  simpa [resid] using Nat.sub_pos_of_lt h

/-- **Core arithmetic bound.**  On the first decile the residue obeys
`25 v ≤ 11 N + 48 √N + 16`; the leading constant `11/25 = 0.44` is exactly the
`(1 + 0.2)² − 1` of the informal computation. -/
lemma resid_mul_25_le {N j : ℕ} (h : FirstDecile N j) :
    25 * resid N j ≤ 11 * N + 48 * Nat.sqrt N + 16 := by
  obtain ⟨hj, hd⟩ := h
  set s := Nat.sqrt N with hs
  set d := j - s with hdef
  have hjs : j = s + d := by omega
  have hsq : s * s ≤ N := Nat.sqrt_le N
  have h1 : resid N j ≤ 2 * s * d + d * d := by
    have hj2 : j ^ 2 = s * s + (2 * s * d + d * d) := by rw [hjs]; ring
    have : resid N j = s * s + (2 * s * d + d * d) - N := by rw [resid, hj2]
    omega
  have h5 : 5 * d ≤ s + 4 := by omega
  have key : 25 * (2 * s * d + d * d) ≤ 11 * (s * s) + 48 * s + 16 := by nlinarith
  calc 25 * resid N j ≤ 25 * (2 * s * d + d * d) := by exact Nat.mul_le_mul_left _ h1
    _ ≤ 11 * (s * s) + 48 * s + 16 := key
    _ ≤ 11 * N + 48 * s + 16 := by
        have := Nat.mul_le_mul_left 11 hsq
        omega

/-- **Scale-free degeneracy.**  For every modulus `N ≥ 2¹⁶`, a first-decile trial point has
residue smaller than `0.45 · N`.  (`0.45 < 1/2`, so the residue always loses at least one
bit relative to `N`.)  This is the exact-arithmetic mechanism, valid at every scale. -/
theorem resid_lt_of_firstDecile_scalefree {N j : ℕ} (hN : 2 ^ 16 ≤ N)
    (h : FirstDecile N j) : 100 * resid N j < 45 * N := by
  have h25 := resid_mul_25_le h
  have hs256 : 256 ≤ Nat.sqrt N := by
    rw [Nat.le_sqrt]; norm_num at hN ⊢; omega
  have hsq : Nat.sqrt N * Nat.sqrt N ≤ N := Nat.sqrt_le N
  have hlin : 256 * Nat.sqrt N ≤ N :=
    le_trans (Nat.mul_le_mul_right _ hs256) hsq
  have hbig : 192 * Nat.sqrt N + 64 < N := by
    have : (65536 : ℕ) ≤ N := by norm_num at hN; omega
    omega
  omega

/-- **The exclusion clause is degenerate for 96-bit moduli.**  Every first-decile hit of a
`96`-bit modulus has residue `< 2⁹⁵`, so filtering out `v < 2⁹⁵` deletes the entire
first-decile mass, by geometry rather than by any property of the data. -/
theorem firstDecile_resid_lt_two_pow_95 {N j : ℕ} (hlo : 2 ^ 95 ≤ N) (hhi : N < 2 ^ 96)
    (h : FirstDecile N j) : resid N j < 2 ^ 95 := by
  have hN16 : 2 ^ 16 ≤ N := le_trans (Nat.pow_le_pow_right (by norm_num) (by norm_num)) hlo
  have h45 := resid_lt_of_firstDecile_scalefree hN16 h
  have h96 : (2 : ℕ) ^ 96 = 2 * 2 ^ 95 := by ring
  omega

/-- Bit-length form: every first-decile residue of a `96`-bit modulus has `bitlen ≤ 95`. -/
theorem firstDecile_bitlen_le_95 {N j : ℕ} (hlo : 2 ^ 95 ≤ N) (hhi : N < 2 ^ 96)
    (h : FirstDecile N j) : (resid N j).size ≤ 95 :=
  Nat.size_le.2 (firstDecile_resid_lt_two_pow_95 hlo hhi h)

/-- **Non-vacuity / sharpness of the discrete threshold.**  Past normalised position
`u = 0.21` (i.e. `100 j ≥ 142 s`) the residue of a `96`-bit modulus is provably *full size*,
`v ≥ 2⁹⁵`.  So the exclusion clause is not globally trivial: it is exactly the first decile
that it annihilates. -/
theorem resid_ge_two_pow_95_of_far {N j : ℕ} (hlo : 2 ^ 95 ≤ N) (hhi : N < 2 ^ 96)
    (hfar : 142 * Nat.sqrt N ≤ 100 * j) : 2 ^ 95 ≤ resid N j := by
  set s := Nat.sqrt N with hs
  have hup : N < (s + 1) * (s + 1) := by
    have := Nat.lt_succ_sqrt' N
    simpa [hs, pow_two] using this
  have hsle : s ≤ 2 ^ 48 := by
    have : Nat.sqrt N < 2 ^ 48 := Nat.sqrt_lt'.2 (by calc N < 2 ^ 96 := hhi
      _ = (2 ^ 48) ^ 2 := by norm_num)
    omega
  have hexp : (s + 1) * (s + 1) = s * s + 2 * s + 1 := by ring
  have hsq : N ≤ s * s + 2 * s := by omega
  have hj2 : 20164 * (s * s) ≤ 10000 * j ^ 2 := by nlinarith [hfar, sq_nonneg j]
  -- 10000 (j² − N) ≥ 10164 N − 40328 s ≥ 10164·2⁹⁵ − 40328·2⁴⁸ > 10000·2⁹⁵
  have hNj : N ≤ j ^ 2 := by nlinarith
  have hres : 10000 * resid N j = 10000 * j ^ 2 - 10000 * N := by
    rw [resid, Nat.mul_sub]
  have hslack : 40328 * s + 10000 * 2 ^ 95 ≤ 10164 * N := by
    have h1 : 40328 * s ≤ 40328 * 2 ^ 48 := Nat.mul_le_mul_left _ hsle
    have h2 : 40328 * 2 ^ 48 ≤ 164 * 2 ^ 95 := by norm_num
    have h3 : 10164 * 2 ^ 95 ≤ 10164 * N := Nat.mul_le_mul_left _ hlo
    omega
  have : 10000 * 2 ^ 95 ≤ 10000 * resid N j := by
    rw [hres]
    omega
  omega

/-! ## Continuum layer: the exact crossing curve and its sharp interval -/

open Real

/-- Normalised crossing position: the value of `u = (j − s)/(2s)` at which the residue
`((1 + 2u)² − 1) · N` first reaches the full-size threshold `2⁹⁵`. -/
noncomputable def crossingPos (N : ℝ) : ℝ := (Real.sqrt (1 + 2 ^ 95 / N) - 1) / 2

/-- `crossingPos` is exactly the residue-crossing point of the continuum model. -/
theorem crossingPos_spec {N u : ℝ} (hN : 0 < N) (hu : 0 ≤ u) :
    (2 : ℝ) ^ 95 ≤ ((1 + 2 * u) ^ 2 - 1) * N ↔ crossingPos N ≤ u := by
  have hA : (0:ℝ) ≤ 1 + 2 ^ 95 / N := by positivity
  constructor
  · intro h
    have h1 : 1 + 2 ^ 95 / N ≤ (1 + 2 * u) ^ 2 := by
      have h0 : (2:ℝ) ^ 95 / N ≤ (1 + 2 * u) ^ 2 - 1 := (div_le_iff₀ hN).2 h
      linarith
    have h2 : Real.sqrt (1 + 2 ^ 95 / N) ≤ 1 + 2 * u := by
      have := Real.sqrt_le_sqrt h1
      rwa [Real.sqrt_sq (by linarith)] at this
    unfold crossingPos; linarith
  · intro h
    unfold crossingPos at h
    have h2 : Real.sqrt (1 + 2 ^ 95 / N) ≤ 1 + 2 * u := by linarith
    have h3 : 1 + 2 ^ 95 / N ≤ (1 + 2 * u) ^ 2 := by
      have := Real.sq_sqrt hA
      nlinarith [Real.sqrt_nonneg (1 + 2 ^ 95 / N)]
    have h4 : (2:ℝ) ^ 95 / N ≤ (1 + 2 * u) ^ 2 - 1 := by linarith
    have := (div_le_iff₀ hN).1 h4
    linarith

/-- Upper end of the crossing interval: for `N ≥ 2⁹⁵`, `u₀(N) ≤ (√2 − 1)/2 ≈ 0.20711`. -/
theorem crossingPos_le {N : ℝ} (hlo : (2:ℝ) ^ 95 ≤ N) :
    crossingPos N ≤ (Real.sqrt 2 - 1) / 2 := by
  have hN : (0:ℝ) < N := lt_of_lt_of_le (by positivity) hlo
  have hdiv : (2:ℝ) ^ 95 / N ≤ 1 := (div_le_one hN).2 hlo
  have : Real.sqrt (1 + 2 ^ 95 / N) ≤ Real.sqrt 2 := Real.sqrt_le_sqrt (by linarith)
  unfold crossingPos; linarith

/-- Lower end of the crossing interval: for `N < 2⁹⁶`, `u₀(N) > (√6 − 2)/4 ≈ 0.11237`.
This is the smallest position at which a full-size residue can occur, and it matches the
reported kept-support left edge `u ≈ 0.114`. -/
theorem crossingPos_gt {N : ℝ} (hhi : N < 2 ^ 96) (hN : 0 < N) :
    (Real.sqrt 6 - 2) / 4 < crossingPos N := by
  have hdiv : (1:ℝ) / 2 < 2 ^ 95 / N := by
    rw [lt_div_iff₀ hN]
    nlinarith
  have hs6 : Real.sqrt 6 ^ 2 = 6 := Real.sq_sqrt (by norm_num)
  have h6 : Real.sqrt 6 / 2 = Real.sqrt (3 / 2) := by
    rw [show (3:ℝ) / 2 = (Real.sqrt 6 / 2) ^ 2 by rw [div_pow, hs6]; norm_num,
      Real.sqrt_sq (by positivity)]
  have hlt : Real.sqrt (3 / 2) < Real.sqrt (1 + 2 ^ 95 / N) := by
    apply Real.sqrt_lt_sqrt (by norm_num); linarith
  unfold crossingPos
  rw [show (Real.sqrt 6 - 2) / 4 = (Real.sqrt 6 / 2 - 1) / 2 by ring, h6]
  linarith

/-- **The structural reason for the degeneracy.**  The decile boundary `1/10` lies strictly
below the smallest possible crossing position `(√6 − 2)/4`, hence strictly below `u₀(N)` for
every `96`-bit `N`: no full-size residue can ever occur in the first decile. -/
theorem one_tenth_lt_crossingPos {N : ℝ} (hhi : N < 2 ^ 96) (hN : 0 < N) :
    (1 : ℝ) / 10 < crossingPos N := by
  have h6 : (2.4 : ℝ) < Real.sqrt 6 := by
    have : Real.sqrt (2.4 ^ 2) < Real.sqrt 6 := by
      apply Real.sqrt_lt_sqrt <;> norm_num
    rwa [Real.sqrt_sq (by norm_num)] at this
  have := crossingPos_gt hhi hN
  linarith

/-- **Sharp phase transition of the exclusion clause.**  Let `c` be a candidate normalised
cut-off.  If `c ≤ (√6 − 2)/4` the clause is degenerate for *every* `96`-bit modulus (no
full-size residue below `c`), whereas if `c > (√2 − 1)/2` it is informative for *every*
`96`-bit modulus (full-size residues occur below `c`).  The transition window is exactly
`((√6 − 2)/4, (√2 − 1)/2]`, and the experiment's `c = 1/10` sits strictly inside the
degenerate regime. -/
theorem exclusion_phase_transition {c : ℝ} :
    (c ≤ (Real.sqrt 6 - 2) / 4 →
      ∀ N u : ℝ, 0 < N → N < 2 ^ 96 → 0 ≤ u → u < c →
        ((1 + 2 * u) ^ 2 - 1) * N < 2 ^ 95) ∧
    ((Real.sqrt 2 - 1) / 2 < c →
      ∀ N : ℝ, (2:ℝ) ^ 95 ≤ N → ∃ u : ℝ, 0 ≤ u ∧ u < c ∧ 2 ^ 95 ≤ ((1 + 2 * u) ^ 2 - 1) * N) := by
  constructor
  · intro hc N u hN hhi hu hlt
    by_contra hcon
    push_neg at hcon
    have := (crossingPos_spec hN hu).1 hcon
    have := crossingPos_gt hhi hN
    linarith
  · intro hc N hlo
    have hN : (0:ℝ) < N := lt_of_lt_of_le (by positivity) hlo
    refine ⟨(Real.sqrt 2 - 1) / 2, ?_, hc, ?_⟩
    · have : (1:ℝ) ≤ Real.sqrt 2 := by
        rw [show (1:ℝ) = Real.sqrt 1 by simp]
        exact Real.sqrt_le_sqrt (by norm_num)
      linarith
    · exact (crossingPos_spec hN (by
        have : (1:ℝ) ≤ Real.sqrt 2 := by
          rw [show (1:ℝ) = Real.sqrt 1 by simp]
          exact Real.sqrt_le_sqrt (by norm_num)
        linarith)).2 (crossingPos_le hlo)

end SpikeOrigin