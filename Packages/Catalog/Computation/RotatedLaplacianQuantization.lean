/-
# Quantization / rigidity of the periodicity energy

A companion to `Computation.RotatedLaplacianPeriodicity`.

**Bold conjecture (proved here).**  *There is no digraph that is "strictly nearly
periodic".*  More precisely, for a digraph whose nonzero weights are at least
`1`, the rotated (periodicity) energy of a unimodular `p`-phase vector cannot be
positive but tiny: it is either exactly `0` — in which case the digraph really is
`p`-periodic — or at least the explicit constant `rootGap p`, the minimal squared
distance from `1` to a nontrivial `p`-th root of unity.

This is a rigidity phenomenon: below the threshold `rootGap p`, "nearly periodic"
collapses to "periodic".  (For `p = 2` the threshold is `4`; in general
`rootGap p = 4 sin²(π/p)`, although we only need positivity here.)

The last theorem shows that the hypothesis on the weights cannot be dropped: by
scaling the weights of the directed `4`-cycle one obtains digraphs with
arbitrarily small *positive* `3`-periodicity energy, so no universal
`0`-or-large dichotomy holds for arbitrary nonnegative weights.
-/
import Mathlib
import Computation.RotatedLaplacianPeriodicity

namespace RotatedLaplacian

open Finset

variable {V : Type*} [Fintype V]

/-! ## The gap between distinct `p`-th roots of unity -/

/-- Powers of `rotWeight p` only depend on the exponent modulo `p`. -/
theorem rotWeight_pow_congr {p : ℕ} (hp : p ≠ 0) {m n : ℕ} (h : (m : ZMod p) = (n : ZMod p)) :
    rotWeight p ^ m = rotWeight p ^ n := by
  rcases le_total n m with hle | hle
  · have hd : p ∣ m - n := by
      have hz : ((m - n : ℕ) : ZMod p) = 0 := by push_cast [Nat.cast_sub hle]; rw [h]; ring
      exact (ZMod.natCast_eq_zero_iff _ _).mp hz
    have h1 : rotWeight p ^ (m - n) = 1 := (rotWeight_pow_eq_one_iff hp _).2 hd
    calc rotWeight p ^ m = rotWeight p ^ (n + (m - n)) := by rw [Nat.add_sub_cancel' hle]
      _ = rotWeight p ^ n * rotWeight p ^ (m - n) := pow_add _ _ _
      _ = rotWeight p ^ n := by rw [h1, mul_one]
  · have hd : p ∣ n - m := by
      have hz : ((n - m : ℕ) : ZMod p) = 0 := by push_cast [Nat.cast_sub hle]; rw [h]; ring
      exact (ZMod.natCast_eq_zero_iff _ _).mp hz
    have h1 : rotWeight p ^ (n - m) = 1 := (rotWeight_pow_eq_one_iff hp _).2 hd
    calc rotWeight p ^ m = rotWeight p ^ m * rotWeight p ^ (n - m) := by rw [h1, mul_one]
      _ = rotWeight p ^ (m + (n - m)) := (pow_add _ _ _).symm
      _ = rotWeight p ^ n := by rw [Nat.add_sub_cancel' hle]

/-- The minimal squared distance from `1` to a nontrivial `p`-th root of unity
(equal to `4 sin²(π/p)`); set to `0` for `p < 2`. -/
noncomputable def rootGap (p : ℕ) : ℝ :=
  if h : ((Finset.range p).erase 0).Nonempty then
    ((Finset.range p).erase 0).inf' h (fun j => ‖rotWeight p ^ j - 1‖ ^ 2)
  else 0

theorem erase_range_nonempty {p : ℕ} (hp : 2 ≤ p) : ((Finset.range p).erase 0).Nonempty :=
  ⟨1, by simp [Finset.mem_erase, Finset.mem_range]; omega⟩

theorem rootGap_pos {p : ℕ} (hp : 2 ≤ p) : 0 < rootGap p := by
  rw [rootGap, dif_pos (erase_range_nonempty hp), Finset.lt_inf'_iff]
  intro j hj
  rw [Finset.mem_erase, Finset.mem_range] at hj
  have hne : rotWeight p ^ j ≠ 1 := by
    intro hcon
    have := (rotWeight_pow_eq_one_iff (by omega) j).1 hcon
    exact hj.1 (Nat.eq_zero_of_dvd_of_lt this hj.2)
  have : rotWeight p ^ j - 1 ≠ 0 := sub_ne_zero.2 hne
  positivity

/-- Two distinct powers of `rotWeight p` are at squared distance at least
`rootGap p`. -/
theorem rootGap_le_norm_sub_sq {p : ℕ} (hp : 2 ≤ p) {a b : ℕ}
    (hab : rotWeight p ^ a ≠ rotWeight p ^ b) :
    rootGap p ≤ ‖rotWeight p ^ a - rotWeight p ^ b‖ ^ 2 := by
  have hp0 : p ≠ 0 := by omega
  haveI : NeZero p := ⟨hp0⟩
  set j : ℕ := ((a : ZMod p) - (b : ZMod p)).val with hj
  have hjlt : j < p := ZMod.val_lt _
  have hjmem : j ∈ (Finset.range p).erase 0 := by
    refine Finset.mem_erase.2 ⟨?_, Finset.mem_range.2 hjlt⟩
    intro h0
    apply hab
    have hz : ((a : ZMod p) - (b : ZMod p)) = 0 := (ZMod.val_eq_zero _).mp h0
    exact rotWeight_pow_congr hp0 (by linear_combination hz)
  have hpow : rotWeight p ^ a = rotWeight p ^ b * rotWeight p ^ j := by
    rw [← pow_add]
    refine rotWeight_pow_congr hp0 ?_
    push_cast
    have hv : ((j : ZMod p)) = (a : ZMod p) - (b : ZMod p) := by
      rw [hj, ZMod.natCast_val, ZMod.cast_id]
    rw [hv]; ring
  have hnorm : ‖rotWeight p ^ a - rotWeight p ^ b‖ = ‖rotWeight p ^ j - 1‖ := by
    rw [hpow]
    have : rotWeight p ^ b * rotWeight p ^ j - rotWeight p ^ b
        = rotWeight p ^ b * (rotWeight p ^ j - 1) := by ring
    rw [this, norm_mul, norm_pow, norm_rotWeight hp0, one_pow, one_mul]
  rw [hnorm, rootGap, dif_pos (erase_range_nonempty hp)]
  exact Finset.inf'_le _ hjmem

/-! ## The quantization theorem -/

/-- **Quantization of the periodicity energy.**  If every nonzero weight of the
digraph is at least `1` and `x` is a unimodular `p`-phase vector, then the
rotated energy of `x` is either exactly `0` or at least `rootGap p`.  There is no
"strictly nearly periodic" configuration below the threshold. -/
theorem rotEnergy_eq_zero_or_rootGap_le {w : V → V → ℝ}
    (hw1 : ∀ u v, w u v = 0 ∨ 1 ≤ w u v) {p : ℕ} (hp : 2 ≤ p) {x : V → ℂ}
    (hx : ∀ v, ∃ k : ℕ, x v = rotWeight p ^ k) :
    rotEnergy w (rotWeight p) x = 0 ∨ rootGap p ≤ rotEnergy w (rotWeight p) x := by
  have hw : ∀ u v, 0 ≤ w u v := by
    intro u v; rcases hw1 u v with h | h
    · rw [h]
    · linarith
  by_cases hedge : ∀ u v, w u v ≠ 0 → x v = rotWeight p * x u
  · exact Or.inl (rotEnergy_eq_zero_of_edges hedge)
  · right
    push_neg at hedge
    obtain ⟨u, v, hne, hbad⟩ := hedge
    obtain ⟨ku, hku⟩ := hx u
    obtain ⟨kv, hkv⟩ := hx v
    have hbad' : rotWeight p ^ kv ≠ rotWeight p ^ (ku + 1) := by
      rw [← hkv, pow_succ, ← hku, mul_comm]
      exact hbad
    have hterm : rootGap p ≤ w u v * ‖x v - rotWeight p * x u‖ ^ 2 := by
      have h1 : x v - rotWeight p * x u = rotWeight p ^ kv - rotWeight p ^ (ku + 1) := by
        rw [hkv, hku, pow_succ, mul_comm]
      rw [h1]
      have h2 : rootGap p ≤ ‖rotWeight p ^ kv - rotWeight p ^ (ku + 1)‖ ^ 2 :=
        rootGap_le_norm_sub_sq hp hbad'
      rcases hw1 u v with h | h
      · exact absurd h hne
      · nlinarith [sq_nonneg ‖rotWeight p ^ kv - rotWeight p ^ (ku + 1)‖, rootGap_pos hp]
    calc rootGap p ≤ w u v * ‖x v - rotWeight p * x u‖ ^ 2 := hterm
      _ ≤ ∑ z, w u z * ‖x z - rotWeight p * x u‖ ^ 2 :=
          Finset.single_le_sum (f := fun z => w u z * ‖x z - rotWeight p * x u‖ ^ 2)
            (fun z _ => mul_nonneg (hw u z) (by positivity)) (Finset.mem_univ v)
      _ ≤ rotEnergy w (rotWeight p) x :=
          Finset.single_le_sum (f := fun y => ∑ z, w y z * ‖x z - rotWeight p * x y‖ ^ 2)
            (fun y _ => Finset.sum_nonneg fun z _ =>
              mul_nonneg (hw y z) (by positivity)) (Finset.mem_univ u)

/-- **Rigidity below the threshold.**  For a strongly connected digraph with
weights in `{0} ∪ [1, ∞)`, a unimodular `p`-phase vector with rotated energy
strictly below `rootGap p` forces the digraph to be exactly `p`-periodic: every
closed walk has length divisible by `p`. -/
theorem dvd_of_rotEnergy_lt_rootGap {w : V → V → ℝ}
    (hw1 : ∀ u v, w u v = 0 ∨ 1 ≤ w u v) {p : ℕ} (hp : 2 ≤ p) {x : V → ℂ}
    (hx : ∀ v, ∃ k : ℕ, x v = rotWeight p ^ k)
    (hsmall : rotEnergy w (rotWeight p) x < rootGap p) {v : V} {n : ℕ}
    (hR : Reach w v v n) : p ∣ n := by
  have hw : ∀ u v, 0 ≤ w u v := by
    intro u v; rcases hw1 u v with h | h
    · rw [h]
    · linarith
  have h0 : rotEnergy w (rotWeight p) x = 0 := by
    rcases rotEnergy_eq_zero_or_rootGap_le hw1 hp hx with h | h
    · exact h
    · linarith
  obtain ⟨k, hk⟩ := hx v
  have hxv : x v ≠ 0 := by
    rw [hk]
    exact pow_ne_zero _ (by
      intro hcon
      have := norm_rotWeight (show p ≠ 0 by omega)
      rw [hcon] at this
      simp at this)
  exact dvd_of_rotEnergy_eq_zero hw (by omega) hxv h0 hR

/-! ## The weight hypothesis is necessary -/

/-- The directed `4`-cycle with all weights scaled by `t`. -/
noncomputable def C4scaled (t : ℝ) : ZMod 4 → ZMod 4 → ℝ := fun u v => t * C4 u v

theorem rotEnergy_C4scaled (t : ℝ) (om : ℂ) (x : ZMod 4 → ℂ) :
    rotEnergy (C4scaled t) om x = t * rotEnergy C4 om x := by
  rw [rotEnergy, rotEnergy, Finset.mul_sum]
  refine Finset.sum_congr rfl fun u _ => ?_
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun v _ => by rw [C4scaled]; ring

/-- **No universal dichotomy for arbitrary nonnegative weights.**  For every
`eps > 0` there is a strongly connected nonnegatively weighted digraph and a
unimodular `3`-phase vector whose rotated `3`-energy is positive but smaller than
`eps`.  Hence the hypothesis "nonzero weights are at least `1`" in
`rotEnergy_eq_zero_or_rootGap_le` cannot be removed. -/
theorem exists_small_positive_rotEnergy {eps : ℝ} (heps : 0 < eps) :
    ∃ (t : ℝ) (x : ZMod 4 → ℂ), 0 < t ∧ (∀ v, ‖x v‖ = 1) ∧
      (∀ u v, 0 ≤ C4scaled t u v) ∧ (∀ u v : ZMod 4, ∃ n, Reach (C4scaled t) u v n) ∧
      0 < rotEnergy (C4scaled t) (rotWeight 3) x ∧
      rotEnergy (C4scaled t) (rotWeight 3) x < eps := by
  classical
  -- the constant vector `1` has positive `3`-energy on the `4`-cycle
  set x : ZMod 4 → ℂ := fun _ => 1 with hxdef
  have hE : rotEnergy C4 (rotWeight 3) x = 4 * ‖(1 : ℂ) - rotWeight 3‖ ^ 2 := by
    rw [rotEnergy]
    simp only [hxdef, mul_one]
    rw [show ((Finset.univ : Finset (ZMod 4)).sum
        (fun u => (Finset.univ : Finset (ZMod 4)).sum
          (fun v => C4 u v * ‖(1 : ℂ) - rotWeight 3‖ ^ 2)))
        = ∑ u : ZMod 4, (∑ v : ZMod 4, C4 u v) * ‖(1 : ℂ) - rotWeight 3‖ ^ 2 from
      Finset.sum_congr rfl fun u _ => by rw [Finset.sum_mul]]
    have hrow : ∀ u : ZMod 4, (∑ v : ZMod 4, C4 u v) = 1 := by
      intro u
      rw [Finset.sum_eq_single (u + 1)]
      · simp [C4]
      · intro b _ hb; simp [C4, hb]
      · intro h; exact absurd (Finset.mem_univ _) h
    rw [Finset.sum_congr rfl fun u _ => by rw [hrow u, one_mul]]
    simp
  have hpos : 0 < rotEnergy C4 (rotWeight 3) x := by
    rw [hE]
    have h1 : (1 : ℂ) - rotWeight 3 ≠ 0 := by
      intro hcon
      have h2 : rotWeight 3 = 1 := by linear_combination -hcon
      have := (rotWeight_pow_eq_one_iff (p := 3) (by norm_num) 1).1 (by simpa using h2)
      norm_num at this
    positivity
  set E := rotEnergy C4 (rotWeight 3) x with hEdef
  refine ⟨min 1 (eps / (2 * E)), x, ?_, fun v => by simp [hxdef], ?_, ?_, ?_, ?_⟩
  · exact lt_min one_pos (by positivity)
  · intro u v
    have := C4_nonneg u v
    have h0 : 0 < min 1 (eps / (2 * E)) := lt_min one_pos (by positivity)
    exact mul_nonneg h0.le this
  · intro u v
    obtain ⟨n, hn⟩ := C4_strongly_connected u v
    refine ⟨n, ?_⟩
    clear_value E
    induction hn with
    | refl => exact Reach.refl _
    | @step b c m _ he ih =>
        refine Reach.step ih ?_
        rw [C4scaled]
        exact mul_ne_zero (ne_of_gt (lt_min one_pos (by positivity))) he
  · rw [rotEnergy_C4scaled, ← hEdef]
    have h0 : 0 < min 1 (eps / (2 * E)) := lt_min one_pos (by positivity)
    positivity
  · rw [rotEnergy_C4scaled, ← hEdef]
    have hle : min 1 (eps / (2 * E)) ≤ eps / (2 * E) := min_le_right _ _
    have : min 1 (eps / (2 * E)) * E ≤ (eps / (2 * E)) * E :=
      mul_le_mul_of_nonneg_right hle hpos.le
    have h2 : (eps / (2 * E)) * E = eps / 2 := by field_simp
    linarith [this, h2 ▸ this]

end RotatedLaplacian