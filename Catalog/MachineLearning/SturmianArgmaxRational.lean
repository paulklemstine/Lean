/-
# Rational slope: the exact complexity of the binomial argmax word

Completion of `MachineLearning.SturmianArgmaxComplexity`.  For irrational slope the
increment word of the argmax staircase has exactly `L + 1` factors of length `L`.  For a
*rational* slope `α = P/(P+Q)` in lowest terms the word is periodic with period `P + Q`,
so the complexity saturates.  Here it is proved that it saturates as late as possible:

`p(L) = min (L + 1) (P + Q)`,

the complexity function of a periodic balanced (Christoffel) word.

## Main results

* `exists_mul_mod_eq` — the orbit `k ↦ k a mod b` is onto for `gcd(a,b) = 1`.
* `fract_nat_div` — `{k · a/b} = ((k a) mod b)/b`.
* `exists_level_eq_rat` — every level `v ≤ L < b` is attained for slope `a/b`.
* `factorSet_ncard_eq_rat`, `binomial_factorSet_ncard_eq` — `p(L) = L + 1` for `L < P+Q`.
* `binomial_complexity_eq_min` — the full classification `p(L) = min (L+1) (P+Q)`.
-/
import Mathlib
import MachineLearning.SturmianArgmaxComplexity

namespace Shared
namespace SturmianArgmax

open Shared.UnimodalArgmaxBracketing

/-! ## Arithmetic of the rational rotation -/

/-- For `gcd(a,b) = 1` every residue is hit by a *positive* multiple of `a`. -/
theorem exists_mul_mod_eq {a b : ℕ} (hb : 0 < b) (hcop : Nat.Coprime a b) (i : ℕ) (hi : i < b) :
    ∃ k : ℕ, 0 < k ∧ (k * a) % b = i := by
  haveI : NeZero b := ⟨by omega⟩
  set u : ZMod b := (i : ZMod b) * (a : ZMod b)⁻¹ with hu
  have hmul : (u : ZMod b) * (a : ZMod b) = (i : ZMod b) := by
    rw [hu, mul_assoc, ZMod.inv_mul_of_unit]
    · ring
    · exact (ZMod.isUnit_iff_coprime a b).2 (by simpa [Nat.coprime_comm] using hcop)
  refine ⟨if u.val = 0 then b else u.val, by split <;> omega, ?_⟩
  have hcast : (((if u.val = 0 then b else u.val) * a : ℕ) : ZMod b) = (i : ZMod b) := by
    push_cast
    split
    · rename_i h
      have hu0 : u = 0 := (ZMod.val_eq_zero u).mp h
      rw [hu0] at hmul
      simp only [zero_mul] at hmul
      simp [← hmul]
    · rw [ZMod.natCast_val, ZMod.cast_id]
      exact hmul
  have h2 : ((if u.val = 0 then b else u.val) * a) % b = i % b :=
    (ZMod.natCast_eq_natCast_iff _ _ _).1 hcast
  rwa [Nat.mod_eq_of_lt hi] at h2

/-- The fractional part of a rational multiple, in lowest terms of the residue. -/
theorem fract_nat_div (k a b : ℕ) (hb : 0 < b) :
    Int.fract ((k : ℝ) * ((a : ℝ) / (b : ℝ))) = (((k * a) % b : ℕ) : ℝ) / (b : ℝ) := by
  have hb' : (0 : ℝ) < (b : ℝ) := by exact_mod_cast hb
  obtain ⟨q, hq⟩ : ∃ q : ℕ, q = (k * a) / b := ⟨_, rfl⟩
  obtain ⟨r, hr⟩ : ∃ r : ℕ, r = (k * a) % b := ⟨_, rfl⟩
  have hdm : (b : ℕ) * q + r = k * a := by rw [hq, hr]; exact Nat.div_add_mod _ _
  have h : ((k : ℝ)) * ((a : ℝ)) = (b : ℝ) * (q : ℝ) + (r : ℝ) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) hdm.symm
  have hcast : (k : ℝ) * ((a : ℝ) / (b : ℝ)) = ((q : ℤ) : ℝ) + (r : ℝ) / (b : ℝ) := by
    field_simp
    push_cast
    linarith [h]
  rw [hcast, Int.fract_intCast_add, ← hr]
  refine Int.fract_eq_self.2 ⟨by positivity, ?_⟩
  rw [div_lt_one hb', hr]
  exact_mod_cast Nat.mod_lt _ hb

/-! ## A combinatorial lemma: every count is realised *at an orbit point* -/

/-- For a finite set `T` of positive reals and any `v ≤ #T` there is a point `x`, either
`0` or an element of `T`, with exactly `v` elements of `T` below it. -/
theorem exists_mem_insert_zero_filter_card_eq :
    ∀ n : ℕ, ∀ T : Finset ℝ, T.card = n → ∀ v : ℕ, v ≤ T.card → (∀ t ∈ T, 0 < t) →
      ∃ x : ℝ, (x = 0 ∨ x ∈ T) ∧ (T.filter (fun t : ℝ => t ≤ x)).card = v := by
  intro n
  induction n with
  | zero =>
      intro T hT v hv _
      have hTe : T = ∅ := Finset.card_eq_zero.1 hT
      subst hTe
      simp at hv
      subst hv
      exact ⟨0, Or.inl rfl, by simp⟩
  | succ n ih =>
      intro T hT v hv hpos
      have hne : T.Nonempty := Finset.card_pos.1 (by omega)
      set M := T.max' hne with hM
      have hMmem : M ∈ T := T.max'_mem hne
      rcases eq_or_lt_of_le hv with heq | hlt
      · refine ⟨M, Or.inr hMmem, ?_⟩
        have hfil : T.filter (fun t : ℝ => t ≤ M) = T :=
          Finset.filter_true_of_mem fun t ht => T.le_max' t ht
        rw [hfil, ← heq]
      · have hcard' : (T.erase M).card = n := by
          rw [Finset.card_erase_of_mem hMmem, hT]
          omega
        have hpos' : ∀ t ∈ T.erase M, 0 < t := fun t ht => hpos t (Finset.mem_of_mem_erase ht)
        obtain ⟨x, hxmem, hxcard⟩ := ih (T.erase M) hcard' v (by omega) hpos'
        have hxM : x < M := by
          rcases hxmem with rfl | hx
          · exact hpos M hMmem
          · exact lt_of_le_of_ne (T.le_max' x (Finset.mem_of_mem_erase hx))
              (Finset.ne_of_mem_erase hx)
        refine ⟨x, ?_, ?_⟩
        · rcases hxmem with rfl | hx
          · exact Or.inl rfl
          · exact Or.inr (Finset.mem_of_mem_erase hx)
        · have hins : T = insert M (T.erase M) := (Finset.insert_erase hMmem).symm
          rw [hins, Finset.filter_insert, if_neg (by linarith), hxcard]

/-! ## Every level is attained for a rational slope of denominator `b > L` -/

/-- **Level attainment for a rational slope.**  For `α = a/b` in lowest terms and
`L < b`, every level `v ≤ L` occurs at some position of the staircase. -/
theorem exists_level_eq_rat {a b : ℕ} (hb : 0 < b) (hcop : Nat.Coprime a b)
    {L : ℕ} (hL : L < b) {v : ℕ} (hv : v ≤ L) :
    ∃ m : ℕ, level ((a : ℝ) / (b : ℝ)) L m = (v : ℤ) := by
  classical
  set α : ℝ := (a : ℝ) / (b : ℝ) with hα
  have hb' : (0 : ℝ) < (b : ℝ) := by exact_mod_cast hb
  have hfract : ∀ k : ℕ, Int.fract ((k : ℝ) * α) = (((k * a) % b : ℕ) : ℝ) / (b : ℝ) :=
    fun k => fract_nat_div k a b hb
  have hmod_ne : ∀ j : ℕ, 1 ≤ j → j < b → (j * a) % b ≠ 0 := by
    intro j hj1 hjb h0
    have hdvd : b ∣ j * a := Nat.dvd_of_mod_eq_zero h0
    have : b ∣ j := (Nat.Coprime.dvd_of_dvd_mul_right (by simpa [Nat.coprime_comm] using hcop))
      hdvd
    have := Nat.le_of_dvd (by omega) this
    omega
  set t : ℕ → ℝ := fun j => 1 - Int.fract ((j : ℝ) * α) with ht
  set T : Finset ℝ := (Finset.Icc 1 L).image t with hT
  have hfr_pos : ∀ j : ℕ, 1 ≤ j → j ≤ L → 0 < Int.fract ((j : ℝ) * α) := by
    intro j hj1 hjL
    rw [hfract j]
    have : 0 < (j * a) % b := Nat.pos_of_ne_zero (hmod_ne j hj1 (by omega))
    positivity
  have hinj : Set.InjOn t ↑(Finset.Icc 1 L) := by
    intro c hc d hd hcd
    simp only [Finset.coe_Icc, Set.mem_Icc] at hc hd
    have hfr : Int.fract ((c : ℝ) * α) = Int.fract ((d : ℝ) * α) := by
      simp only [ht] at hcd
      linarith
    have hbne : (b : ℝ) ≠ 0 := ne_of_gt hb'
    rw [hfract c, hfract d] at hfr
    field_simp at hfr
    have hmodeq : (c * a) % b = (d * a) % b := by exact_mod_cast hfr
    have hcong : c * a ≡ d * a [MOD b] := hmodeq
    have := (Nat.ModEq.cancel_right_of_coprime (by simpa [Nat.coprime_comm] using hcop) hcong)
    have hc' : c % b = c := Nat.mod_eq_of_lt (by omega)
    have hd' : d % b = d := Nat.mod_eq_of_lt (by omega)
    have := this
    unfold Nat.ModEq at this
    omega
  have hTcard : T.card = L := by
    rw [hT, Finset.card_image_of_injOn hinj, Nat.card_Icc]
    omega
  have hTpos : ∀ s ∈ T, 0 < s := by
    intro s hs
    rw [hT, Finset.mem_image] at hs
    obtain ⟨j, hj, rfl⟩ := hs
    obtain ⟨hj1, hj2⟩ := Finset.mem_Icc.1 hj
    have := Int.fract_lt_one ((j : ℝ) * α)
    simp only [ht]
    linarith
  obtain ⟨x, hxmem, hxcard⟩ :=
    exists_mem_insert_zero_filter_card_eq T.card T rfl v (by omega) hTpos
  have hx1 : x < 1 := by
    rcases hxmem with rfl | hx
    · norm_num
    · rw [hT, Finset.mem_image] at hx
      obtain ⟨j, hj, rfl⟩ := hx
      obtain ⟨hj1, hj2⟩ := Finset.mem_Icc.1 hj
      have := hfr_pos j hj1 hj2
      simp only [ht]
      linarith
  -- `x` is a multiple of `1/b`
  obtain ⟨i, hib, hxi⟩ : ∃ i : ℕ, i < b ∧ x = (i : ℝ) / (b : ℝ) := by
    rcases hxmem with rfl | hx
    · exact ⟨0, hb, by norm_num⟩
    · rw [hT, Finset.mem_image] at hx
      obtain ⟨j, hj, rfl⟩ := hx
      obtain ⟨hj1, hj2⟩ := Finset.mem_Icc.1 hj
      have hr : 0 < (j * a) % b := Nat.pos_of_ne_zero (hmod_ne j hj1 (by omega))
      have hrb : (j * a) % b < b := Nat.mod_lt _ hb
      refine ⟨b - (j * a) % b, by omega, ?_⟩
      rw [ht]
      simp only
      rw [hfract j, Nat.cast_sub (le_of_lt hrb)]
      field_simp
  obtain ⟨k, hk0, hk⟩ := exists_mul_mod_eq hb hcop i hib
  have hkx : Int.fract ((k : ℝ) * α) = x := by rw [hfract k, hk, hxi]
  refine ⟨k - 1, ?_⟩
  have hk1 : (((k - 1 : ℕ) : ℝ) + 1) = (k : ℝ) := by
    have h1 : (1 : ℕ) ≤ k := hk0
    have : ((k - 1 : ℕ) : ℝ) = (k : ℝ) - 1 := by
      rw [Nat.cast_sub h1]
      norm_num
    rw [this]
    ring
  rw [level_eq_card_filter, hk1, hkx]
  have hcount : ((Finset.range (L + 1)).filter (fun j : ℕ => t j ≤ x)).card = v := by
    have h1 : (Finset.range (L + 1)).filter (fun j : ℕ => t j ≤ x)
        = (Finset.Icc 1 L).filter (fun j : ℕ => t j ≤ x) := by
      ext j
      simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_Icc]
      constructor
      · rintro ⟨hj, hle⟩
        refine ⟨⟨?_, by omega⟩, hle⟩
        rcases Nat.eq_zero_or_pos j with rfl | hpos
        · exfalso
          simp only [ht, Nat.cast_zero, zero_mul, Int.fract_zero, sub_zero] at hle
          linarith
        · omega
      · rintro ⟨⟨hj1, hj2⟩, hle⟩
        exact ⟨by omega, hle⟩
    have hsub : Set.InjOn t ↑((Finset.Icc 1 L).filter (fun j : ℕ => t j ≤ x)) := by
      refine hinj.mono ?_
      intro c hc
      simp only [Finset.coe_filter, Set.mem_setOf_eq] at hc
      exact Finset.mem_coe.2 hc.1
    calc ((Finset.range (L + 1)).filter (fun j : ℕ => t j ≤ x)).card
        = ((Finset.Icc 1 L).filter (fun j : ℕ => t j ≤ x)).card := by rw [h1]
      _ = (((Finset.Icc 1 L).filter (fun j : ℕ => t j ≤ x)).image t).card :=
            (Finset.card_image_of_injOn hsub).symm
      _ = (T.filter (fun s : ℝ => s ≤ x)).card := by rw [hT, Finset.filter_image]
      _ = v := hxcard
  simpa only [ht] using congrArg (fun n : ℕ => (n : ℤ)) hcount

/-- **Exact complexity for a rational slope, below the period.** -/
theorem factorSet_ncard_eq_rat {a b : ℕ} (hb : 0 < b) (hcop : Nat.Coprime a b)
    {L : ℕ} (hL : L < b) :
    {w : ℕ → ℤ | ∃ m, w = factor ((a : ℝ) / (b : ℝ)) m L}.ncard = L + 1 :=
  factorSet_ncard_eq_of_levels_attained (fun _ hv => exists_level_eq_rat hb hcop hL hv)

/-! ## Monotonicity of the complexity function -/

/-- For a periodic increment word the factor sets are finite. -/
theorem factorSet_finite_of_periodic {α : ℝ} {T : ℕ} (hT : 0 < T)
    (hper : ∀ n, incWord α (n + T) = incWord α n) (L : ℕ) :
    {w : ℕ → ℤ | ∃ m, w = factor α m L}.Finite := by
  refine Set.Finite.subset (Set.finite_range (fun i : Fin T => factor α (i : ℕ) L)) ?_
  rintro w ⟨m, rfl⟩
  exact ⟨⟨m % T, Nat.mod_lt _ hT⟩, (factor_mod hT hper m L).symm⟩

/-- Truncating a factor of length `L+1` gives a factor of length `L`, so the complexity
function is non-decreasing. -/
theorem factorSet_ncard_le_succ {α : ℝ} (L : ℕ)
    (hfin : {w : ℕ → ℤ | ∃ m, w = factor α m (L + 1)}.Finite) :
    {w : ℕ → ℤ | ∃ m, w = factor α m L}.ncard
      ≤ {w : ℕ → ℤ | ∃ m, w = factor α m (L + 1)}.ncard := by
  classical
  set tr : (ℕ → ℤ) → (ℕ → ℤ) := fun w t => if t < L then w t else 0 with htr
  have himg : {w : ℕ → ℤ | ∃ m, w = factor α m L}
      = tr '' {w : ℕ → ℤ | ∃ m, w = factor α m (L + 1)} := by
    ext w
    constructor
    · rintro ⟨m, rfl⟩
      refine ⟨factor α m (L + 1), ⟨m, rfl⟩, ?_⟩
      funext t
      by_cases ht : t < L
      · simp [htr, factor, ht, Nat.lt_succ_of_lt ht]
      · simp [htr, factor, ht]
    · rintro ⟨w', ⟨m, rfl⟩, rfl⟩
      refine ⟨m, ?_⟩
      funext t
      by_cases ht : t < L
      · simp [htr, factor, ht, Nat.lt_succ_of_lt ht]
      · simp [htr, factor, ht]
  rw [himg]
  exact Set.ncard_image_le hfin

theorem factorSet_ncard_mono {α : ℝ} {T : ℕ} (hT : 0 < T)
    (hper : ∀ n, incWord α (n + T) = incWord α n) {L L' : ℕ} (h : L ≤ L') :
    {w : ℕ → ℤ | ∃ m, w = factor α m L}.ncard
      ≤ {w : ℕ → ℤ | ∃ m, w = factor α m L'}.ncard := by
  obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le h
  clear h
  induction d with
  | zero => simp
  | succ d ih =>
      refine le_trans ih ?_
      have := factorSet_ncard_le_succ (α := α) (L + d) (factorSet_finite_of_periodic hT hper _)
      exact this

/-! ## The complexity of the binomial argmax word, in full -/

theorem slope_eq_nat_div (P Q : ℕ) :
    slope (P : ℝ) (Q : ℝ) = ((P : ℕ) : ℝ) / ((P + Q : ℕ) : ℝ) := by
  rw [slope]
  push_cast
  ring

/-- **Exact complexity below the period.**  For coprime `P, Q` the argmax word of the
binomial weights `C(n,k) P^k Q^(n-k)` has exactly `L + 1` factors of length `L < P + Q`. -/
theorem binomial_factorSet_ncard_eq {P Q : ℕ}
    (hcop : Nat.Coprime P Q) {L : ℕ} (hL : L < P + Q) :
    {w : ℕ → ℤ | ∃ m, w = factor (slope (P : ℝ) (Q : ℝ)) m L}.ncard = L + 1 := by
  have hcop' : Nat.Coprime P (P + Q) := by simpa using (Nat.coprime_add_self_left).2 hcop
  rw [slope_eq_nat_div]
  exact factorSet_ncard_eq_rat (by omega) hcop' hL

/-- **The complexity function of the binomial argmax word.**  For coprime weights the
increment word of the argmax staircase has exactly `min (L+1) (P+Q)` factors of length
`L`: it is `L + 1` (Sturmian growth) until the period `P + Q` is reached, and constant
afterwards. -/
theorem binomial_complexity_eq_min {P Q : ℕ} (hP : 0 < P) (hQ : 0 < Q)
    (hcop : Nat.Coprime P Q) (L : ℕ) :
    {w : ℕ → ℤ | ∃ m, w = factor (slope (P : ℝ) (Q : ℝ)) m L}.ncard = min (L + 1) (P + Q) := by
  by_cases h : L < P + Q
  · rw [min_eq_left (by omega)]
    exact binomial_factorSet_ncard_eq hcop h
  · have hPQ : 0 < P + Q := by omega
    have hupper := factorSet_ncard_le_period (P := P) (Q := Q) hPQ L
    have hbase := binomial_factorSet_ncard_eq hcop (L := P + Q - 1) (by omega)
    have hmono := factorSet_ncard_mono (α := slope (P : ℝ) (Q : ℝ)) (T := P + Q) hPQ
      (fun n => incWord_periodic_slope hPQ n) (L := P + Q - 1) (L' := L) (by omega)
    rw [min_eq_right (by omega)]
    omega

end SturmianArgmax
end Shared