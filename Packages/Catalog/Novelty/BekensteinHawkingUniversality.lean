import Novelty.BekensteinHawkingProjectionConstraint

/-!
# Universality of the horizon area law

The two previous files analyse one concrete quantum-horizon model, in which a
puncture of spin label `k = 2j` carries `k` area quanta and `k+1` internal
states.  Here we show that the *area law itself* is a structural phenomenon: it
holds for an **arbitrary** puncture model, i.e. for an arbitrary degeneracy
function `deg : ℕ → ℕ` assigning to each area quantum number `k ≥ 1` the number
`deg k` of internal states of a puncture of area `k`.

The only hypotheses are:

* `1 ≤ deg 1` — punctures of minimal area exist (physically: spin-`1/2`
  punctures);
* `deg k ≤ B ^ k` — the degeneracies grow at most exponentially in the area.

Under these hypotheses we prove

* `gW_supermul` : *supermultiplicativity* `W(n) · W(m) ≤ W(n+m)`, by
  concatenation of horizons (the combinatorial expression of the fact that
  horizons are extensive in area);
* `gW_le_pow` and `pow_le_gW` : `(deg 1)^n ≤ W(n) ≤ (2B)^n`;
* `gEntropy_area_law` : the entropy density
  `L = lim log W(n) / n` **exists**, is finite, and satisfies
  `log (deg 1) ≤ L ≤ log (2B)`.  This is Fekete's subadditive lemma applied to
  the horizon microstate count.

Finally we connect the general theory back to the explicit model:

* `gW_eq_hStates` : the concrete model is the case `deg k = k + 1`;
* `entropyDensity_eq_universal_limit` : its universal density is the explicitly
  computed `log (2+√2)`;
* `entropyDensity_bracket` : consequently `log 2 ≤ log (2+√2) ≤ log 4`, the
  general bracket evaluated on the concrete model.
-/

open Finset

namespace BekensteinHawking
namespace Universal

/-! ## A general puncture model -/

/-- Configurations of total area `n` in the model with degeneracy function
`deg`: lists of punctures `(k, a)` with `k ≥ 1` an area quantum number and
`a < deg k` an internal label. -/
def gStates (deg : ℕ → ℕ) : ℕ → Finset (List (ℕ × ℕ))
  | 0 => {[]}
  | (n + 1) => (Finset.range (n + 1)).biUnion (fun i =>
      (Finset.range (deg (i + 1))).biUnion (fun a =>
        (gStates deg (n - i)).image (fun l => (i + 1, a) :: l)))

/-- The microstate count of the general model. -/
def gW (deg : ℕ → ℕ) (n : ℕ) : ℕ := (gStates deg n).card

/-- Total area of a general configuration. -/
def gArea (l : List (ℕ × ℕ)) : ℕ := (l.map Prod.fst).sum

/-- Admissibility of a general configuration. -/
def IsGConfig (deg : ℕ → ℕ) (l : List (ℕ × ℕ)) : Prop :=
  ∀ p ∈ l, 1 ≤ p.1 ∧ p.2 < deg p.1

@[simp] lemma gArea_nil : gArea [] = 0 := rfl
@[simp] lemma gArea_cons (p : ℕ × ℕ) (l : List (ℕ × ℕ)) : gArea (p :: l) = p.1 + gArea l := rfl

lemma gArea_append (l l' : List (ℕ × ℕ)) : gArea (l ++ l') = gArea l + gArea l' := by
  simp [gArea]

@[simp] lemma gW_zero (deg : ℕ → ℕ) : gW deg 0 = 1 := by
  simp [gW, gStates]

lemma gcons_injective (p : ℕ × ℕ) : Function.Injective (fun l : List (ℕ × ℕ) => p :: l) := by
  intro a b h; simpa using h

/-- The renewal recursion in the general model. -/
lemma gW_succ (deg : ℕ → ℕ) (n : ℕ) :
    gW deg (n + 1) = ∑ i ∈ Finset.range (n + 1), deg (i + 1) * gW deg (n - i) := by
  unfold gW
  rw [gStates, Finset.card_biUnion]
  · refine Finset.sum_congr rfl ?_
    intro i _
    rw [Finset.card_biUnion]
    · have h : ∀ a ∈ Finset.range (deg (i + 1)),
          ((gStates deg (n - i)).image (fun l => ((i + 1, a) :: l))).card
            = (gStates deg (n - i)).card :=
        fun a _ => Finset.card_image_of_injective _ (gcons_injective _)
      rw [Finset.sum_congr rfl h, Finset.sum_const, Finset.card_range, smul_eq_mul]
    · intro a _ a' _ hne
      simp only [Finset.disjoint_left, Finset.mem_image]
      rintro l ⟨u, hu, rfl⟩ ⟨v, hv, hv2⟩
      simp only [List.cons.injEq, Prod.mk.injEq] at hv2
      exact hne hv2.1.2.symm
  · intro i _ j _ hne
    simp only [Finset.disjoint_left, Finset.mem_biUnion, Finset.mem_image]
    rintro l ⟨a, ha, u, hu, rfl⟩ ⟨a', ha', v, hv, hv2⟩
    simp only [List.cons.injEq, Prod.mk.injEq] at hv2
    omega

/-- Membership characterisation in the general model. -/
theorem mem_gStates_iff (deg : ℕ → ℕ) (n : ℕ) (l : List (ℕ × ℕ)) :
    l ∈ gStates deg n ↔ (IsGConfig deg l ∧ gArea l = n) := by
  induction n using Nat.strong_induction_on generalizing l with
  | _ n ih =>
    match n with
    | 0 =>
      rw [gStates]
      simp only [Finset.mem_singleton]
      constructor
      · rintro rfl; exact ⟨by simp [IsGConfig], rfl⟩
      · rintro ⟨hc, ha⟩
        cases l with
        | nil => rfl
        | cons p t =>
          exfalso
          have := (hc p (by simp)).1
          simp only [gArea_cons] at ha
          omega
    | (n + 1) =>
      rw [gStates]
      simp only [Finset.mem_biUnion, Finset.mem_image, Finset.mem_range]
      constructor
      · rintro ⟨i, hi, a, ha, l', hl', rfl⟩
        have hrec := (ih (n - i) (by omega) l').mp hl'
        refine ⟨?_, ?_⟩
        · intro p hp
          rcases List.mem_cons.mp hp with rfl | hp'
          · exact ⟨by omega, ha⟩
          · exact hrec.1 p hp'
        · simp only [gArea_cons]
          have h2 := hrec.2
          omega
      · rintro ⟨hc, ha⟩
        cases l with
        | nil => simp [gArea] at ha
        | cons p t =>
          obtain ⟨hk, hd⟩ := hc p (by simp)
          simp only [gArea_cons] at ha
          refine ⟨p.1 - 1, by omega, p.2, ?_, t, ?_, ?_⟩
          · have h : p.1 - 1 + 1 = p.1 := by omega
            rw [h]; exact hd
          · exact (ih (n - (p.1 - 1)) (by omega) t).mpr
              ⟨fun q hq => hc q (by simp [hq]), by omega⟩
          · have h : p.1 - 1 + 1 = p.1 := by omega
            rw [h]

lemma isGConfig_of_mem {deg : ℕ → ℕ} {n : ℕ} {l : List (ℕ × ℕ)} (h : l ∈ gStates deg n) :
    IsGConfig deg l := ((mem_gStates_iff deg n l).mp h).1

lemma gArea_of_mem {deg : ℕ → ℕ} {n : ℕ} {l : List (ℕ × ℕ)} (h : l ∈ gStates deg n) :
    gArea l = n := ((mem_gStates_iff deg n l).mp h).2

lemma eq_nil_of_gArea_zero {deg : ℕ → ℕ} {l : List (ℕ × ℕ)}
    (hc : IsGConfig deg l) (h : gArea l = 0) : l = [] := by
  cases l with
  | nil => rfl
  | cons p t =>
    exfalso
    have := (hc p (by simp)).1
    simp only [gArea_cons] at h
    omega

lemma gappend_left_inj {deg : ℕ → ℕ} {l₁ l₁' l₂ l₂' : List (ℕ × ℕ)}
    (h₁ : IsGConfig deg l₁) (h₁' : IsGConfig deg l₁')
    (harea : gArea l₁ = gArea l₁') (h : l₁ ++ l₂ = l₁' ++ l₂') :
    l₁ = l₁' ∧ l₂ = l₂' := by
  rcases List.append_eq_append_iff.mp h with ⟨a, rfl, rfl⟩ | ⟨c, rfl, rfl⟩
  · have hca : IsGConfig deg a := fun p hp => h₁' p (by simp [hp])
    have hz : gArea a = 0 := by rw [gArea_append] at harea; omega
    rw [eq_nil_of_gArea_zero hca hz]; simp
  · have hcc : IsGConfig deg c := fun p hp => h₁ p (by simp [hp])
    have hz : gArea c = 0 := by rw [gArea_append] at harea; omega
    rw [eq_nil_of_gArea_zero hcc hz]; simp

/-- **Supermultiplicativity**: horizons concatenate. -/
theorem gW_supermul (deg : ℕ → ℕ) (n m : ℕ) : gW deg n * gW deg m ≤ gW deg (n + m) := by
  classical
  have hcard : ((gStates deg n) ×ˢ (gStates deg m)).card = gW deg n * gW deg m :=
    Finset.card_product _ _
  rw [← hcard, gW]
  refine Finset.card_le_card_of_injOn (fun p => p.1 ++ p.2) ?_ ?_
  · rintro ⟨l₁, l₂⟩ hp
    simp only [Finset.mem_coe, Finset.mem_product] at hp ⊢
    rw [mem_gStates_iff]
    refine ⟨?_, ?_⟩
    · intro p hp'
      rcases List.mem_append.mp hp' with h | h
      · exact isGConfig_of_mem hp.1 p h
      · exact isGConfig_of_mem hp.2 p h
    · rw [gArea_append, gArea_of_mem hp.1, gArea_of_mem hp.2]
  · rintro ⟨l₁, l₂⟩ hp ⟨l₁', l₂'⟩ hp' heq
    simp only [Finset.mem_coe, Finset.mem_product] at hp hp'
    have hkey := gappend_left_inj (isGConfig_of_mem hp.1) (isGConfig_of_mem hp'.1)
      (by rw [gArea_of_mem hp.1, gArea_of_mem hp'.1]) heq
    simp only [Prod.mk.injEq]
    exact ⟨hkey.1, hkey.2⟩

/-! ## Two-sided exponential bounds -/

lemma one_le_gW (deg : ℕ → ℕ) (hdeg1 : 1 ≤ deg 1) (n : ℕ) : 1 ≤ gW deg n := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [gW_succ]
    have hterm : deg 1 * gW deg n ≤ ∑ i ∈ Finset.range (n + 1), deg (i + 1) * gW deg (n - i) := by
      refine Finset.single_le_sum (f := fun i => deg (i + 1) * gW deg (n - i)) ?_ ?_
      · intro i _; positivity
      · simp
    calc 1 ≤ deg 1 * gW deg n := Nat.one_le_iff_ne_zero.mpr (by positivity)
      _ ≤ _ := hterm

/-- Punctures of unit area alone already produce `(deg 1)^n` states. -/
theorem pow_le_gW (deg : ℕ → ℕ) (n : ℕ) : (deg 1) ^ n ≤ gW deg n := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [gW_succ]
    have hterm : deg 1 * gW deg n ≤ ∑ i ∈ Finset.range (n + 1), deg (i + 1) * gW deg (n - i) := by
      refine Finset.single_le_sum (f := fun i => deg (i + 1) * gW deg (n - i)) ?_ ?_
      · intro i _; positivity
      · simp
    calc (deg 1) ^ (n + 1) = deg 1 * (deg 1) ^ n := by ring
      _ ≤ deg 1 * gW deg n := Nat.mul_le_mul_left _ ih
      _ ≤ _ := hterm

lemma sum_two_pow_lt (m : ℕ) : ∑ i ∈ Finset.range m, 2 ^ i < 2 ^ m := by
  induction m with
  | zero => simp
  | succ m ih =>
    rw [Finset.sum_range_succ, pow_succ]
    omega

/-- With at most exponentially growing degeneracies the microstate count is at
most exponential in the area. -/
theorem gW_le_pow (deg : ℕ → ℕ) (B : ℕ) (hdeg : ∀ k, deg k ≤ B ^ k) (n : ℕ) :
    gW deg n ≤ (2 * B) ^ n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => simp
    | (n + 1) =>
      rw [gW_succ]
      have hstep : ∀ i ∈ Finset.range (n + 1),
          deg (i + 1) * gW deg (n - i) ≤ 2 ^ (n - i) * B ^ (n + 1) := by
        intro i hi
        simp only [Finset.mem_range] at hi
        have h1 : deg (i + 1) ≤ B ^ (i + 1) := hdeg _
        have h2 : gW deg (n - i) ≤ (2 * B) ^ (n - i) := ih (n - i) (by omega)
        calc deg (i + 1) * gW deg (n - i) ≤ B ^ (i + 1) * (2 * B) ^ (n - i) :=
              Nat.mul_le_mul h1 h2
          _ = 2 ^ (n - i) * (B ^ (i + 1) * B ^ (n - i)) := by rw [mul_pow]; ring
          _ = 2 ^ (n - i) * B ^ (n + 1) := by
              rw [← pow_add]
              congr 2
              omega
      calc ∑ i ∈ Finset.range (n + 1), deg (i + 1) * gW deg (n - i)
          ≤ ∑ i ∈ Finset.range (n + 1), 2 ^ (n - i) * B ^ (n + 1) :=
            Finset.sum_le_sum hstep
        _ = (∑ i ∈ Finset.range (n + 1), 2 ^ (n - i)) * B ^ (n + 1) := by
            rw [← Finset.sum_mul]
        _ = (∑ i ∈ Finset.range (n + 1), 2 ^ i) * B ^ (n + 1) := by
            congr 1
            rw [← Finset.sum_range_reflect (fun i => 2 ^ i) (n + 1)]
            simp
        _ ≤ 2 ^ (n + 1) * B ^ (n + 1) := by
            have := sum_two_pow_lt (n + 1)
            exact Nat.mul_le_mul_right _ (le_of_lt this)
        _ = (2 * B) ^ (n + 1) := by rw [mul_pow]

/-! ## Existence of the entropy density (Fekete) -/

/-- **Universal area law.**  For any puncture model with minimal-area punctures
and at most exponential degeneracies, the entropy per unit area converges to a
finite density, bracketed by the two elementary bounds. -/
theorem gEntropy_area_law (deg : ℕ → ℕ) (hdeg1 : 1 ≤ deg 1) (B : ℕ) (hB : 1 ≤ B)
    (hdeg : ∀ k, deg k ≤ B ^ k) :
    ∃ L : ℝ, Real.log (deg 1) ≤ L ∧ L ≤ Real.log (2 * B) ∧
      Filter.Tendsto (fun n : ℕ => Real.log (gW deg n) / n) Filter.atTop (nhds L) := by
  set u : ℕ → ℝ := fun n => -Real.log (gW deg n) with hu
  have hWpos : ∀ n, (0:ℝ) < (gW deg n : ℝ) := by
    intro n
    exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one (one_le_gW deg hdeg1 n)
  have hsub : Subadditive u := by
    intro m n
    have h := gW_supermul deg m n
    have hcast : ((gW deg m : ℝ)) * (gW deg n : ℝ) ≤ (gW deg (m + n) : ℝ) := by
      exact_mod_cast h
    have hlog : Real.log ((gW deg m : ℝ) * (gW deg n : ℝ)) ≤ Real.log (gW deg (m + n)) :=
      Real.log_le_log (mul_pos (hWpos m) (hWpos n)) hcast
    rw [Real.log_mul (ne_of_gt (hWpos m)) (ne_of_gt (hWpos n))] at hlog
    simp only [hu]
    linarith
  have hbdd : BddBelow (Set.range fun n => u n / n) := by
    refine ⟨-Real.log (2 * B), ?_⟩
    rintro x ⟨n, rfl⟩
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · have hB1 : (1:ℝ) ≤ 2 * (B:ℝ) := by
        have : (1:ℝ) ≤ (B:ℝ) := by exact_mod_cast hB
        linarith
      simp only [hu, Nat.cast_zero, div_zero, gW_zero, Nat.cast_one, Real.log_one, neg_zero]
      simpa using Real.log_nonneg hB1
    · have hnpos : (0:ℝ) < n := by exact_mod_cast hn
      have hle : (gW deg n : ℝ) ≤ ((2 * B : ℕ) : ℝ) ^ n := by
        exact_mod_cast gW_le_pow deg B hdeg n
      have hlog : Real.log (gW deg n) ≤ n * Real.log ((2 * B : ℕ) : ℝ) := by
        have := Real.log_le_log (hWpos n) hle
        rwa [Real.log_pow] at this
      simp only [hu]
      rw [le_div_iff₀ hnpos]
      push_cast at hlog ⊢
      nlinarith
  have htend := hsub.tendsto_lim hbdd
  have hmain : Filter.Tendsto (fun n : ℕ => Real.log (gW deg n) / n) Filter.atTop
      (nhds (-hsub.lim)) := htend.neg.congr (fun n => by simp [hu, neg_div, neg_neg])
  refine ⟨-hsub.lim, ?_, ?_, hmain⟩
  · -- lower bound from `(deg 1)^n ≤ gW n`
    have hlow : ∀ n : ℕ, 1 ≤ n → Real.log (deg 1) ≤ Real.log (gW deg n) / n := by
      intro n hn
      have hnpos : (0:ℝ) < n := by exact_mod_cast hn
      have hle : ((deg 1 : ℕ) : ℝ) ^ n ≤ (gW deg n : ℝ) := by
        exact_mod_cast pow_le_gW deg n
      have h1 : (0:ℝ) < ((deg 1 : ℕ) : ℝ) := by exact_mod_cast hdeg1
      have := Real.log_le_log (by positivity) hle
      rw [Real.log_pow] at this
      rw [le_div_iff₀ hnpos]
      linarith
    refine le_of_tendsto_of_tendsto tendsto_const_nhds hmain ?_
    filter_upwards [Filter.eventually_ge_atTop 1] with n hn using hlow n hn
  · have hhigh : ∀ n : ℕ, 1 ≤ n → Real.log (gW deg n) / n ≤ Real.log (2 * B) := by
      intro n hn
      have hnpos : (0:ℝ) < n := by exact_mod_cast hn
      have hle : (gW deg n : ℝ) ≤ ((2 * B : ℕ) : ℝ) ^ n := by
        exact_mod_cast gW_le_pow deg B hdeg n
      have := Real.log_le_log (hWpos n) hle
      rw [Real.log_pow] at this
      rw [div_le_iff₀ hnpos]
      push_cast at this ⊢
      linarith
    refine le_of_tendsto_of_tendsto hmain tendsto_const_nhds ?_
    filter_upwards [Filter.eventually_ge_atTop 1] with n hn using hhigh n hn

/-! ## Monotonicity in the degeneracies -/

/-- More internal states per puncture means more horizon microstates. -/
theorem gW_mono {deg deg' : ℕ → ℕ} (h : ∀ k, deg k ≤ deg' k) (n : ℕ) :
    gW deg n ≤ gW deg' n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => simp
    | (n + 1) =>
      rw [gW_succ, gW_succ]
      refine Finset.sum_le_sum ?_
      intro i hi
      simp only [Finset.mem_range] at hi
      exact Nat.mul_le_mul (h _) (ih (n - i) (by omega))

lemma log_natCast_le_log_natCast {a b : ℕ} (h : a ≤ b) :
    Real.log a ≤ Real.log b := by
  rcases Nat.eq_zero_or_pos a with rfl | ha
  · simp only [Nat.cast_zero, Real.log_zero]
    rcases Nat.eq_zero_or_pos b with rfl | hb
    · simp
    · exact Real.log_nonneg (by exact_mod_cast hb)
  · exact Real.log_le_log (by exact_mod_cast ha) (by exact_mod_cast h)

/-- The entropy density is monotone in the degeneracy function. -/
theorem gDensity_mono {deg deg' : ℕ → ℕ} (h : ∀ k, deg k ≤ deg' k) {L L' : ℝ}
    (hL : Filter.Tendsto (fun n : ℕ => Real.log (gW deg n) / n) Filter.atTop (nhds L))
    (hL' : Filter.Tendsto (fun n : ℕ => Real.log (gW deg' n) / n) Filter.atTop (nhds L')) :
    L ≤ L' := by
  refine le_of_tendsto_of_tendsto hL hL' ?_
  filter_upwards [Filter.eventually_ge_atTop 1] with n hn
  have hnpos : (0:ℝ) < n := by exact_mod_cast hn
  have hlog := log_natCast_le_log_natCast (gW_mono h n)
  exact div_le_div_of_nonneg_right hlog (le_of_lt hnpos)

/-! ## The concrete model is the case `deg k = k + 1` -/

/-- The explicit isolated-horizon model of `BekensteinHawkingAreaLaw` is the
general model with degeneracy `deg k = k + 1 = 2j + 1`. -/
theorem gW_eq_hStates (n : ℕ) : gW (fun k => k + 1) n = hStates n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => simp
    | (n + 1) =>
      rw [gW_succ, hStates_succ]
      refine Finset.sum_congr rfl ?_
      intro i hi
      simp only [Finset.mem_range] at hi
      rw [ih (n - i) (by omega)]

/-- The universal entropy density of the concrete model is the explicitly
computed `log (2 + √2)`. -/
theorem entropyDensity_eq_universal_limit :
    Filter.Tendsto (fun n : ℕ => Real.log (gW (fun k => k + 1) n) / n)
      Filter.atTop (nhds entropyDensity) := by
  refine entropy_area_law.congr ?_
  intro n
  rw [gW_eq_hStates]
  rfl

/-- Evaluating the universal bracket on the concrete model:
`log 2 ≤ log (2+√2) ≤ log 4`. -/
theorem entropyDensity_bracket : Real.log 2 ≤ entropyDensity ∧ entropyDensity ≤ Real.log 4 := by
  obtain ⟨L, hL1, hL2, hL3⟩ :=
    gEntropy_area_law (fun k => k + 1) (by norm_num) 2 (by norm_num) (fun k => by
      induction k with
      | zero => norm_num
      | succ k ih =>
        have h1 : k < 2 ^ k := Nat.lt_two_pow_self
        calc k + 1 + 1 ≤ 2 ^ k + 2 ^ k := by omega
          _ = 2 ^ (k + 1) := by ring)
  have heq : L = entropyDensity :=
    tendsto_nhds_unique hL3 entropyDensity_eq_universal_limit
  rw [heq] at hL1 hL2
  constructor
  · norm_num at hL1
    exact hL1
  · norm_num at hL2
    exact hL2

end Universal
end BekensteinHawking