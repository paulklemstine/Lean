import Mathlib
import Bridges.QRLottoDial
import Bridges.QRLottoDialIndependence

/-!
# No fit can beat the theory dial: exact optimality of the weights `2/p`

The experimental claim behind the QR-lottery programme is that the *zero-fit* dial
`T(N) = ∑ 2/p` over the quadratic-residue primes of a factor base outperforms models
whose per-prime coefficients are fitted, and that truncating the support of the weight
vector loses accuracy.  Here both statements are proved exactly, over the CRT sample
space of `Bridges.QRLottoDialIndependence`.

## Main results

* `QRLotto.sum_sq_weightedDial` — the exact second moment of an arbitrary linear read-out
  `∑ w i · b i` of the QR bit vector: `#Ω · ((∑ w i/2)² + ∑ (w i)²/4)`.
* `QRLotto.risk_eq` — the **exact risk formula** for a fitted weight vector `w`:
  `risk(w) = #Ω · ((∑ (2/q i - w i)/2)² + ∑ (2/q i - w i)²/4)`.
* `QRLotto.risk_theory_eq_zero`, `QRLotto.risk_nonneg`, `QRLotto.risk_eq_zero_iff` —
  **the theory weights are the unique risk minimiser**: fitting can at best rediscover
  `2/p`, and any other weight vector is strictly worse.
* `QRLotto.risk_truncation` — the **exact cost of bit truncation**: dropping the primes
  outside `S` costs `#Ω · ((∑_{i ∉ S} 1/q i)² + ∑_{i ∉ S} 1/(q i)²)`, which is strictly
  positive as soon as one prime is dropped.  Full `p ≤ B` support therefore dominates
  every truncation.
-/

open Finset

namespace QRLotto

variable {k : ℕ}

/-! ## Linearity of the read-out in the weights -/

lemma weightedDial_sub (q : Fin k → ℕ) (a b : Fin k → ℝ) (x : ∀ i, ZMod (q i)) :
    weightedDial q (fun i => a i - b i) x = weightedDial q a x - weightedDial q b x := by
  rw [weightedDial, weightedDial, weightedDial, ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl (fun i _ => ?_)
  split_ifs <;> ring

lemma dialOf_sub_weightedDial (q : Fin k → ℕ) (w : Fin k → ℝ) (x : ∀ i, ZMod (q i)) :
    dialOf q x - weightedDial q w x
      = weightedDial q (fun i => 2 / (q i : ℝ) - w i) x := by
  rw [weightedDial_sub]
  rfl

/-! ## The exact second moment of a fitted read-out -/

/-- **Uncentred second moment** of a linear read-out of the QR bits. -/
theorem sum_sq_weightedDial (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2)
    (w : Fin k → ℝ) :
    ∑ x ∈ sampleSpace q, (weightedDial q w x) ^ 2
      = (#(sampleSpace q) : ℝ) * ((∑ i, w i / 2) ^ 2 + ∑ i, (w i) ^ 2 / 4) := by
  set m : ℝ := ∑ i, w i / 2 with hm
  have expand : ∀ x : ∀ i, ZMod (q i), (weightedDial q w x) ^ 2
      = (weightedDial q w x - m) ^ 2 + 2 * m * weightedDial q w x - m ^ 2 := by
    intro x; ring
  rw [Finset.sum_congr rfl (fun x _ => expand x), Finset.sum_sub_distrib,
    Finset.sum_add_distrib, ← Finset.mul_sum, sum_sq_weightedDial_centred q hq h2 w,
    sum_weightedDial q hq h2 w, Finset.sum_const, nsmul_eq_mul, ← hm]
  ring

/-! ## The risk of a fitted weight vector -/

/-- The total squared error of the linear model with weights `w` against the true
per-`N` footprint. -/
noncomputable def risk (q : Fin k → ℕ) (w : Fin k → ℝ) : ℝ :=
  ∑ x ∈ sampleSpace q, (dialOf q x - weightedDial q w x) ^ 2

/-- **Exact risk formula.**  The error of any fitted weight vector is completely
determined by its deviation from the theory weights `2/p`. -/
theorem risk_eq (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2)
    (w : Fin k → ℝ) :
    risk q w = (#(sampleSpace q) : ℝ)
      * ((∑ i, (2 / (q i : ℝ) - w i) / 2) ^ 2 + ∑ i, (2 / (q i : ℝ) - w i) ^ 2 / 4) := by
  rw [risk, Finset.sum_congr rfl (fun x _ => by rw [dialOf_sub_weightedDial q w x]),
    sum_sq_weightedDial q hq h2 (fun i => 2 / (q i : ℝ) - w i)]

/-- The theory weights `2/p` reproduce the footprint exactly: zero error, zero fitting. -/
theorem risk_theory_eq_zero (q : Fin k → ℕ) : risk q (fun i => 2 / (q i : ℝ)) = 0 := by
  rw [risk]
  refine Finset.sum_eq_zero (fun x _ => ?_)
  rw [dialOf_sub_weightedDial q (fun i => 2 / (q i : ℝ)) x]
  have : (fun i : Fin k => 2 / (q i : ℝ) - 2 / (q i : ℝ)) = fun _ => (0 : ℝ) := by
    funext i; ring
  rw [this, weightedDial]
  simp

theorem risk_nonneg (q : Fin k → ℕ) (w : Fin k → ℝ) : 0 ≤ risk q w :=
  Finset.sum_nonneg (fun _ _ => sq_nonneg _)

/-- The sample space is nonempty: each prime contributes at least two invertible classes. -/
lemma card_sampleSpace_pos (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2) :
    0 < #(sampleSpace q) := by
  rw [sampleSpace, Fintype.card_piFinset]
  refine Finset.prod_pos (fun i _ => ?_)
  haveI : Fact (q i).Prime := ⟨hq i⟩
  have hc := card_nzZ (q i) (h2 i)
  have h3 : 3 ≤ q i := by
    have := (hq i).two_le
    have := h2 i
    omega
  omega

/-- **Uniqueness of the theory weights.**  Over the CRT sample space the risk vanishes
*only* for `w i = 2/q i`: no fitted coefficient vector can match, let alone beat, the
zero-fit dial. -/
theorem risk_eq_zero_iff (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2)
    (w : Fin k → ℝ) :
    risk q w = 0 ↔ ∀ i, w i = 2 / (q i : ℝ) := by
  constructor
  · intro h0
    have hcard : (0 : ℝ) < (#(sampleSpace q) : ℝ) := by
      exact_mod_cast card_sampleSpace_pos q hq h2
    rw [risk_eq q hq h2 w] at h0
    have hsum : (∑ i, (2 / (q i : ℝ) - w i) / 2) ^ 2
        + ∑ i, (2 / (q i : ℝ) - w i) ^ 2 / 4 = 0 := by
      rcases mul_eq_zero.1 h0 with h | h
      · exact absurd h (ne_of_gt hcard)
      · exact h
    have hnn : (0 : ℝ) ≤ ∑ i, (2 / (q i : ℝ) - w i) ^ 2 / 4 :=
      Finset.sum_nonneg (fun i _ => by positivity)
    have hz : ∑ i, (2 / (q i : ℝ) - w i) ^ 2 / 4 = 0 := by
      nlinarith [sq_nonneg (∑ i, (2 / (q i : ℝ) - w i) / 2)]
    intro i
    have := (Finset.sum_eq_zero_iff_of_nonneg (fun i _ => by positivity :
      ∀ i ∈ (univ : Finset (Fin k)), (0 : ℝ) ≤ (2 / (q i : ℝ) - w i) ^ 2 / 4)).1 hz i
      (mem_univ i)
    have hsq : (2 / (q i : ℝ) - w i) ^ 2 = 0 := by linarith
    have := pow_eq_zero_iff (n := 2) (by norm_num) |>.1 hsq
    linarith
  · intro h
    have : w = fun i => 2 / (q i : ℝ) := funext h
    rw [this]
    exact risk_theory_eq_zero q

/-! ## The exact cost of truncating the factor base -/

/-- **Truncation cost.**  Restricting the weight vector to a sub-base `S` (i.e. setting
the coefficients of the dropped primes to zero) costs exactly
`#Ω · ((∑_{i ∉ S} 1/q i)² + ∑_{i ∉ S} 1/(q i)²)`. -/
theorem risk_truncation (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2)
    (S : Finset (Fin k)) :
    risk q (fun i => if i ∈ S then 2 / (q i : ℝ) else 0)
      = (#(sampleSpace q) : ℝ)
        * ((∑ i ∈ Sᶜ, 1 / (q i : ℝ)) ^ 2 + ∑ i ∈ Sᶜ, 1 / (q i : ℝ) ^ 2) := by
  classical
  rw [risk_eq q hq h2]
  congr 2
  · rw [← Finset.sum_filter_add_sum_filter_not univ (fun i => i ∈ S)]
    have h1 : ∑ i ∈ univ with i ∈ S,
        (2 / (q i : ℝ) - if i ∈ S then 2 / (q i : ℝ) else 0) / 2 = 0 := by
      refine Finset.sum_eq_zero (fun i hi => ?_)
      rw [if_pos (Finset.mem_filter.1 hi).2]
      ring
    have h2' : ∑ i ∈ univ with i ∉ S,
        (2 / (q i : ℝ) - if i ∈ S then 2 / (q i : ℝ) else 0) / 2
          = ∑ i ∈ Sᶜ, 1 / (q i : ℝ) := by
      rw [Finset.filter_not, Finset.compl_eq_univ_sdiff]
      refine Finset.sum_congr (by simp [Finset.sdiff_eq_filter]) (fun i hi => ?_)
      have hnot : i ∉ S := by simpa using hi
      rw [if_neg hnot]
      ring
    rw [h1, h2', zero_add]
  · rw [← Finset.sum_filter_add_sum_filter_not univ (fun i => i ∈ S)]
    have h1 : ∑ i ∈ univ with i ∈ S,
        (2 / (q i : ℝ) - if i ∈ S then 2 / (q i : ℝ) else 0) ^ 2 / 4 = 0 := by
      refine Finset.sum_eq_zero (fun i hi => ?_)
      rw [if_pos (Finset.mem_filter.1 hi).2]
      norm_num
    have h2' : ∑ i ∈ univ with i ∉ S,
        (2 / (q i : ℝ) - if i ∈ S then 2 / (q i : ℝ) else 0) ^ 2 / 4
          = ∑ i ∈ Sᶜ, 1 / (q i : ℝ) ^ 2 := by
      rw [Finset.filter_not, Finset.compl_eq_univ_sdiff]
      refine Finset.sum_congr (by simp [Finset.sdiff_eq_filter]) (fun i hi => ?_)
      have hnot : i ∉ S := by simpa using hi
      rw [if_neg hnot, sub_zero, div_pow]
      ring
    rw [h1, h2', zero_add]

/-- **Truncation strictly hurts.**  Dropping even a single prime from the support of the
weight vector makes the risk strictly positive, while the full support has risk zero.
This is the exact form of "keep the full `p ≤ B` support over bit truncation". -/
theorem risk_truncation_pos (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2)
    (S : Finset (Fin k)) (hS : Sᶜ.Nonempty) :
    0 < risk q (fun i => if i ∈ S then 2 / (q i : ℝ) else 0) := by
  classical
  obtain ⟨j, hj⟩ := hS
  have hcard : (0 : ℝ) < (#(sampleSpace q) : ℝ) := by
    exact_mod_cast card_sampleSpace_pos q hq h2
  have hqj : (0 : ℝ) < (q j : ℝ) := by
    have := (hq j).pos
    exact_mod_cast this
  have hterm : 0 < ∑ i ∈ Sᶜ, 1 / (q i : ℝ) ^ 2 := by
    refine Finset.sum_pos' (fun i _ => by positivity) ⟨j, hj, by positivity⟩
  have hfirst : (0 : ℝ) ≤ (∑ i ∈ Sᶜ, 1 / (q i : ℝ)) ^ 2 := sq_nonneg _
  rw [risk_truncation q hq h2 S]
  have : 0 < (∑ i ∈ Sᶜ, 1 / (q i : ℝ)) ^ 2 + ∑ i ∈ Sᶜ, 1 / (q i : ℝ) ^ 2 := by linarith
  positivity

/-! ## Bridge: the integer dial and the CRT dial agree -/

/-- The QR bit of an integer `N` at `p` is exactly membership of its class in the winning
ticket set. -/
lemma qrBit_iff_mem_winZ (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) {N : ℤ}
    (hN : ¬ (p : ℤ) ∣ N) : qrBit p N = true ↔ ((N : ZMod p) ∈ winZ p) := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  constructor
  · intro hb
    have hsq : IsSquare ((N : ZMod p)) := (qrBit_iff p hp N).1 hb
    have h2 : rootCount p N = 2 := rootCount_eq_two p hp hN hsq
    set n : ℕ := ((N : ZMod p)).val with hn
    have hcast : ((n : ℤ) : ZMod p) = (N : ZMod p) := by
      push_cast [hn]
      simp [ZMod.natCast_val]
    have hmem : n ∈ winners p :=
      mem_winners_iff.2 ⟨ZMod.val_lt _, by rw [rootCount_congr p hcast]; exact h2⟩
    exact Finset.mem_image.2 ⟨n, hmem, by exact_mod_cast hcast⟩
  · intro hmem
    obtain ⟨n, hn, hcast⟩ := Finset.mem_image.1 hmem
    have h2 : rootCount p (n : ℤ) = 2 := (mem_winners_iff.1 hn).2
    have hcast' : ((N : ℤ) : ZMod p) = ((n : ℤ) : ZMod p) := by
      push_cast
      exact hcast.symm
    have : rootCount p N = 2 := by rw [rootCount_congr p hcast']; exact h2
    simp [qrBit, this]

/-- **The two dials agree.**  For a factor base of distinct odd primes and any `N`
coprime to it, the integer-level dial of `Bridges.QRLottoDial` coincides with the
CRT-level dial of `Bridges.QRLottoDialIndependence` evaluated at the residue vector of
`N`.  Hence the exact distribution results transfer to the arithmetic dial. -/
theorem theoryDial_eq_dialOf (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2)
    (hinj : Function.Injective q) {N : ℤ} (hN : ∀ i, ¬ (q i : ℤ) ∣ N) :
    theoryDial (univ.image q) N = dialOf q (fun i => (N : ZMod (q i))) := by
  classical
  rw [theoryDial, Finset.sum_filter,
    Finset.sum_image (fun i _ j _ h => hinj h), dialOf, weightedDial]
  refine Finset.sum_congr rfl (fun i _ => ?_)
  haveI : Fact (q i).Prime := ⟨hq i⟩
  by_cases hb : qrBit (q i) N = true
  · rw [if_pos hb, if_pos ((qrBit_iff_mem_winZ (q i) (h2 i) (hN i)).1 hb)]
  · rw [if_neg hb, if_neg (fun hcon => hb ((qrBit_iff_mem_winZ (q i) (h2 i) (hN i)).2 hcon))]

/-! ## The full spectrum of the dial -/

/-- **The dial attains its theoretical maximum.**  Some integer switches on every bit of
the factor base, so the dial reaches `∑ 2/q i`. -/
theorem exists_dial_eq_max (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2)
    (hinj : Function.Injective q) :
    ∃ N : ℕ, theoryDial (univ.image q) (N : ℤ) = ∑ i, 2 / (q i : ℝ) := by
  classical
  obtain ⟨N, hN⟩ := exists_prescribed_bits q hq h2 hinj (fun _ => true)
  refine ⟨N, ?_⟩
  have hbit : ∀ i, qrBit (q i) (N : ℤ) = true := by
    intro i
    have h := hN i
    simp [qrBit, h]
  have hfil : {p ∈ univ.image q | qrBit p (N : ℤ) = true} = univ.image q := by
    refine Finset.filter_true_of_mem (fun p hp => ?_)
    obtain ⟨i, _, rfl⟩ := Finset.mem_image.1 hp
    exact hbit i
  rw [theoryDial, hfil, Finset.sum_image (fun i _ j _ h => hinj h)]

/-- **The dial attains zero.**  Some integer is a non-residue at every factor-base prime,
so the dial reads `0`.  Together with `exists_dial_eq_max` the readings span the whole
`2^k`-point spectrum. -/
theorem exists_dial_eq_zero (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2)
    (hinj : Function.Injective q) :
    ∃ N : ℕ, theoryDial (univ.image q) (N : ℤ) = 0 := by
  classical
  obtain ⟨N, hN⟩ := exists_prescribed_bits q hq h2 hinj (fun _ => false)
  refine ⟨N, ?_⟩
  have hbit : ∀ i, qrBit (q i) (N : ℤ) = false := by
    intro i
    have h := hN i
    simp only [Bool.false_eq_true] at h
    simp [qrBit, h]
  have hfil : {p ∈ univ.image q | qrBit p (N : ℤ) = true} = ∅ := by
    refine Finset.filter_false_of_mem (fun p hp => ?_)
    obtain ⟨i, _, rfl⟩ := Finset.mem_image.1 hp
    simp [hbit i]
  rw [theoryDial, hfil, Finset.sum_empty]

end QRLotto