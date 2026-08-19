import Mathlib

/-!
# A quantitative sieve for Euclid parameters

This file is the purely combinatorial engine behind the counting theorems for the
Berggren tree.  Write

* `parityPairs N` for the pairs `(m, n)` with `0 < n < m ≤ N` and `m + n` odd, and
* `coprimePairs N` for those that are moreover coprime.

By `MachineLearning.BerggrenEuclidParam`, `coprimePairs N` is exactly the set of Euclid
parameters of the nodes of the Berggren tree with `m ≤ N`.  The main result is the
*explicit* lower bound

`theorem card_coprimePairs_lower : 4 ≤ N → N ^ 2 ≤ 16 * (coprimePairs N).card`,

i.e. a positive proportion of all parity pairs is coprime.  The proof is a Legendre-style
sieve, but with a twist that keeps it completely elementary: a *non*-coprime pair is
covered by the divisor `k = gcd m n`, which is automatically **odd** and lies in `[3, N]`,
so no prime enumeration is needed.  The self-similarity

`#{(m,n) ∈ parityPairs N : k ∣ m, k ∣ n} ≤ #(parityPairs ⌊N/k⌋) ≤ N²/(4k²)`

together with the telescoping estimate `∑_{k≥3} 1/k² ≤ 1/2` gives

`#coprimePairs N ≥ (N² - N)/4 - N²/8 = N²/8 - N/4 ≥ N²/16  (N ≥ 4).`

The constant `1/16` is of course far from the truth (`4/π² · 1/4 ≈ 0.101`, and the true
density of `coprimePairs` is `2/π² ≈ 0.2026` of the full square); what matters is that it
is an explicit positive constant, proved from scratch.
-/

namespace BerggrenSieve

open Finset

/-- Pairs `(m, n)` with `0 < n < m ≤ N` of opposite parity. -/
def parityPairs (N : ℕ) : Finset (ℕ × ℕ) :=
  ((Finset.Icc 1 N) ×ˢ (Finset.Icc 1 N)).filter fun p => p.2 < p.1 ∧ (p.1 + p.2) % 2 = 1

/-- The coprime ones: Euclid parameters of primitive Pythagorean triples. -/
def coprimePairs (N : ℕ) : Finset (ℕ × ℕ) :=
  (parityPairs N).filter fun p => Nat.gcd p.1 p.2 = 1

theorem mem_parityPairs {N : ℕ} {p : ℕ × ℕ} :
    p ∈ parityPairs N ↔ 1 ≤ p.2 ∧ p.2 < p.1 ∧ p.1 ≤ N ∧ (p.1 + p.2) % 2 = 1 := by
  simp only [parityPairs, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc]
  constructor
  · rintro ⟨⟨⟨h1, h2⟩, h3, h4⟩, h5, h6⟩
    exact ⟨h3, h5, h2, h6⟩
  · rintro ⟨h1, h2, h3, h4⟩
    exact ⟨⟨⟨by omega, h3⟩, h1, by omega⟩, h2, h4⟩

theorem mem_coprimePairs {N : ℕ} {p : ℕ × ℕ} :
    p ∈ coprimePairs N ↔
      1 ≤ p.2 ∧ p.2 < p.1 ∧ p.1 ≤ N ∧ (p.1 + p.2) % 2 = 1 ∧ Nat.gcd p.1 p.2 = 1 := by
  simp only [coprimePairs, Finset.mem_filter, mem_parityPairs]
  tauto

/-! ### The exact cardinality of `parityPairs` -/

/-- The fibre of `parityPairs N` over a first coordinate `m` has `⌊m/2⌋` elements. -/
theorem card_fiber (m : ℕ) :
    ((Finset.Ico 1 m).filter fun n => (m + n) % 2 = 1).card = m / 2 := by
  have hev : ((Finset.Ioc 0 m).filter fun x => 2 ∣ x).card = m / 2 :=
    Nat.Ioc_filter_dvd_card_eq_div m 2
  have hsplit :
      ((Finset.Ioc 0 m).filter fun x => 2 ∣ x).card
        + ((Finset.Ioc 0 m).filter fun x => ¬ 2 ∣ x).card = (Finset.Ioc 0 m).card :=
    Finset.card_filter_add_card_filter_not _
  have hIoc : (Finset.Ioc 0 m).card = m := by simp
  rcases Nat.even_or_odd m with he | ho
  · obtain ⟨t, ht⟩ := he
    have hset : ((Finset.Ico 1 m).filter fun n => (m + n) % 2 = 1)
        = (Finset.Ioc 0 m).filter fun x => ¬ 2 ∣ x := by
      ext n
      simp only [Finset.mem_filter, Finset.mem_Ico, Finset.mem_Ioc, Nat.dvd_iff_mod_eq_zero]
      omega
    rw [hset]
    omega
  · obtain ⟨t, ht⟩ := ho
    have hset : ((Finset.Ico 1 m).filter fun n => (m + n) % 2 = 1)
        = (Finset.Ioc 0 m).filter fun x => 2 ∣ x := by
      ext n
      simp only [Finset.mem_filter, Finset.mem_Ico, Finset.mem_Ioc, Nat.dvd_iff_mod_eq_zero]
      omega
    rw [hset, hev]

theorem card_parityPairs (N : ℕ) : (parityPairs N).card = ∑ m ∈ Finset.Icc 1 N, m / 2 := by
  rw [Finset.card_eq_sum_card_fiberwise
    (f := Prod.fst) (t := Finset.Icc 1 N) (fun p hp => by
      have hp' := mem_parityPairs.mp hp
      simp only [Finset.mem_coe, Finset.mem_Icc]
      omega)]
  refine Finset.sum_congr rfl fun m hm => ?_
  have hfib : (parityPairs N).filter (fun p => p.1 = m)
      = ((Finset.Ico 1 m).filter fun n => (m + n) % 2 = 1).image (fun n => (m, n)) := by
    ext p
    simp only [Finset.mem_filter, mem_parityPairs, Finset.mem_image, Finset.mem_Ico]
    simp only [Finset.mem_Icc] at hm
    constructor
    · rintro ⟨⟨h1, h2, h3, h4⟩, rfl⟩
      exact ⟨p.2, ⟨⟨h1, h2⟩, h4⟩, rfl⟩
    · rintro ⟨n, ⟨⟨h1, h2⟩, h3⟩, rfl⟩
      exact ⟨⟨h1, h2, hm.2, h3⟩, rfl⟩
  rw [hfib, Finset.card_image_of_injective _ (fun a b h => by simpa using h), card_fiber]

theorem sum_div_two (N : ℕ) : ∑ m ∈ Finset.Icc 1 N, m / 2 = (N / 2) * ((N + 1) / 2) := by
  induction N with
  | zero => simp
  | succ n ih =>
      rw [Finset.sum_Icc_succ_top (by omega), ih]
      rcases Nat.even_or_odd n with he | ho
      · obtain ⟨t, ht⟩ := he
        subst ht
        have h1 : (t + t) / 2 = t := by omega
        have h2 : (t + t + 1) / 2 = t := by omega
        have h3 : (t + t + 1 + 1) / 2 = t + 1 := by omega
        rw [h1, h2, h3]
        ring
      · obtain ⟨t, ht⟩ := ho
        subst ht
        have h1 : (2 * t + 1) / 2 = t := by omega
        have h2 : (2 * t + 1 + 1) / 2 = t + 1 := by omega
        have h3 : (2 * t + 1 + 1 + 1) / 2 = t + 1 := by omega
        rw [h1, h2, h3]
        ring

theorem card_parityPairs_eq (N : ℕ) : (parityPairs N).card = (N / 2) * ((N + 1) / 2) := by
  rw [card_parityPairs, sum_div_two]

theorem card_parityPairs_le (N : ℕ) : 4 * (parityPairs N).card ≤ N ^ 2 := by
  rw [card_parityPairs_eq]
  rcases Nat.even_or_odd N with he | ho
  · obtain ⟨t, ht⟩ := he
    subst ht
    have h1 : (t + t) / 2 = t := by omega
    have h2 : (t + t + 1) / 2 = t := by omega
    rw [h1, h2]; ring_nf; omega
  · obtain ⟨t, ht⟩ := ho
    subst ht
    have h1 : (2 * t + 1) / 2 = t := by omega
    have h2 : (2 * t + 1 + 1) / 2 = t + 1 := by omega
    rw [h1, h2]; ring_nf; nlinarith

theorem card_parityPairs_ge (N : ℕ) : N ^ 2 ≤ 4 * (parityPairs N).card + N := by
  rw [card_parityPairs_eq]
  rcases Nat.even_or_odd N with he | ho
  · obtain ⟨t, ht⟩ := he
    subst ht
    have h1 : (t + t) / 2 = t := by omega
    have h2 : (t + t + 1) / 2 = t := by omega
    rw [h1, h2]; ring_nf; omega
  · obtain ⟨t, ht⟩ := ho
    subst ht
    have h1 : (2 * t + 1) / 2 = t := by omega
    have h2 : (2 * t + 1 + 1) / 2 = t + 1 := by omega
    rw [h1, h2]; ring_nf; nlinarith

/-! ### Self-similarity of the divisibility slices -/

theorem card_divisible_le (N k : ℕ) (hk : 1 ≤ k) :
    ((parityPairs N).filter fun p => k ∣ p.1 ∧ k ∣ p.2).card ≤ (parityPairs (N / k)).card := by
  refine Finset.card_le_card_of_injOn (fun p => (p.1 / k, p.2 / k)) ?_ ?_
  · intro p hp
    simp only [Finset.mem_coe, Finset.mem_filter, mem_parityPairs] at hp
    obtain ⟨⟨h1, h2, h3, h4⟩, ⟨a, ha⟩, ⟨b, hb⟩⟩ := hp
    have hk0 : 0 < k := hk
    have hda : p.1 / k = a := by rw [ha]; exact Nat.mul_div_cancel_left a hk0
    have hdb : p.2 / k = b := by rw [hb]; exact Nat.mul_div_cancel_left b hk0
    rw [Finset.mem_coe, mem_parityPairs]
    refine ⟨?_, ?_, ?_, ?_⟩
    · simp only [hdb]
      rcases Nat.eq_zero_or_pos b with rfl | hb0
      · omega
      · exact hb0
    · simp only [hda, hdb]
      exact Nat.lt_of_mul_lt_mul_left (a := k) (by omega)
    · simp only [hda]
      exact Nat.le_div_iff_mul_le hk0 |>.mpr (by rw [Nat.mul_comm]; omega)
    · simp only [hda, hdb]
      have hodd : Odd (k * a + k * b) := Nat.odd_iff.mpr (by omega)
      have : Odd (k * (a + b)) := by rwa [Nat.mul_add]
      exact Nat.odd_iff.mp (Nat.odd_mul.mp this).2
  · intro p hp q hq hpq
    simp only [Finset.mem_coe, Finset.mem_filter] at hp hq
    obtain ⟨-, hp1, hp2⟩ := hp
    obtain ⟨-, hq1, hq2⟩ := hq
    have e1 : p.1 / k = q.1 / k := congrArg Prod.fst hpq
    have e2 : p.2 / k = q.2 / k := congrArg Prod.snd hpq
    have h1 : p.1 = q.1 := by
      rw [← Nat.div_mul_cancel hp1, ← Nat.div_mul_cancel hq1, e1]
    have h2 : p.2 = q.2 := by
      rw [← Nat.div_mul_cancel hp2, ← Nat.div_mul_cancel hq2, e2]
    exact Prod.ext h1 h2

/-! ### The union bound -/

theorem bad_subset (N : ℕ) :
    ((parityPairs N).filter fun p => Nat.gcd p.1 p.2 ≠ 1) ⊆
      (Finset.Icc 3 N).biUnion fun k => (parityPairs N).filter fun p => k ∣ p.1 ∧ k ∣ p.2 := by
  intro p hp
  simp only [Finset.mem_filter] at hp
  obtain ⟨hmem, hgcd⟩ := hp
  have hmem' := mem_parityPairs.mp hmem
  obtain ⟨h1, h2, h3, h4⟩ := hmem'
  set k := Nat.gcd p.1 p.2 with hkdef
  have hk1 : k ∣ p.1 := Nat.gcd_dvd_left _ _
  have hk2 : k ∣ p.2 := Nat.gcd_dvd_right _ _
  have hkpos : 0 < k := Nat.gcd_pos_of_pos_left _ (by omega)
  have hkodd : ¬ 2 ∣ k := by
    intro h2k
    have hda : 2 ∣ p.1 := h2k.trans hk1
    have hdb : 2 ∣ p.2 := h2k.trans hk2
    rw [Nat.dvd_iff_mod_eq_zero] at hda hdb
    omega
  have hkle : k ≤ N := le_trans (Nat.le_of_dvd (by omega) hk2) (by omega)
  have hne1 : k ≠ 1 := hgcd
  have hne2 : k ≠ 2 := fun h => hkodd (by rw [h])
  have hk3 : 3 ≤ k := by omega
  exact Finset.mem_biUnion.mpr ⟨k, Finset.mem_Icc.mpr ⟨hk3, hkle⟩,
    Finset.mem_filter.mpr ⟨hmem, hk1, hk2⟩⟩

theorem card_bad_le (N : ℕ) :
    ((parityPairs N).filter fun p => Nat.gcd p.1 p.2 ≠ 1).card
      ≤ ∑ k ∈ Finset.Icc 3 N, (parityPairs (N / k)).card := by
  refine le_trans (Finset.card_le_card (bad_subset N)) ?_
  refine le_trans (Finset.card_biUnion_le) ?_
  refine Finset.sum_le_sum fun k hk => ?_
  exact card_divisible_le N k (by simp only [Finset.mem_Icc] at hk; omega)

/-! ### The telescoping estimate `∑_{k=3}^{N} 1/k² ≤ 1/2` -/

theorem sum_inv_sq_le_aux : ∀ N : ℕ, 2 ≤ N →
    ∑ k ∈ Finset.Icc 3 N, ((k : ℚ) ^ 2)⁻¹ ≤ 1 / 2 - 1 / N := by
  intro N hN
  induction N, hN using Nat.le_induction with
  | base => norm_num
  | succ n hn ih =>
      have hn2 : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
      have hn0 : (0 : ℚ) < (n : ℚ) := by linarith
      have hn1 : (0 : ℚ) < (n : ℚ) + 1 := by linarith
      rw [Finset.sum_Icc_succ_top (by omega)]
      have hstep : (((n : ℚ) + 1) ^ 2)⁻¹ ≤ 1 / (n : ℚ) - 1 / ((n : ℚ) + 1) := by
        rw [div_sub_div _ _ (ne_of_gt hn0) (ne_of_gt hn1), inv_le_iff_one_le_mul₀ (by positivity)]
        rw [div_mul_eq_mul_div, le_div_iff₀ (by positivity)]
        ring_nf
        nlinarith
      have hcast : ((((n : ℕ) + 1 : ℕ) : ℚ) ^ 2)⁻¹ = (((n : ℚ) + 1) ^ 2)⁻¹ := by push_cast; ring
      rw [hcast]
      have : ((n : ℚ) + 1) = ((n + 1 : ℕ) : ℚ) := by push_cast; ring
      rw [← this]
      linarith [ih]

theorem sum_inv_sq_le (N : ℕ) : ∑ k ∈ Finset.Icc 3 N, ((k : ℚ) ^ 2)⁻¹ ≤ 1 / 2 := by
  rcases Nat.lt_or_ge N 2 with h | h
  · interval_cases N <;> simp
  · have h1 := sum_inv_sq_le_aux N h
    have h2 : (0 : ℚ) < N := by
      have : (2 : ℚ) ≤ (N : ℚ) := by exact_mod_cast h
      linarith
    have : (0 : ℚ) < 1 / (N : ℚ) := by positivity
    linarith

/-! ### The main lower bound -/

/-- The sieve estimate: the non-coprime parity pairs occupy at most `N²/8`. -/
theorem card_bad_le_eighth (N : ℕ) :
    (8 : ℚ) * (((parityPairs N).filter fun p => ¬ Nat.gcd p.1 p.2 = 1).card : ℚ) ≤ (N : ℚ) ^ 2 := by
  have h1 : ((((parityPairs N).filter fun p => ¬ Nat.gcd p.1 p.2 = 1).card : ℕ) : ℚ)
      ≤ ∑ k ∈ Finset.Icc 3 N, (((parityPairs (N / k)).card : ℕ) : ℚ) := by
    have := card_bad_le N
    have hc : ((((parityPairs N).filter fun p => ¬ Nat.gcd p.1 p.2 = 1).card : ℕ) : ℚ)
        ≤ ((∑ k ∈ Finset.Icc 3 N, (parityPairs (N / k)).card : ℕ) : ℚ) := by
      exact_mod_cast this
    simpa using hc
  have h3 : ∀ k ∈ Finset.Icc 3 N,
      (((parityPairs (N / k)).card : ℕ) : ℚ) ≤ (N : ℚ) ^ 2 / 4 * ((k : ℚ) ^ 2)⁻¹ := by
    intro k hk
    simp only [Finset.mem_Icc] at hk
    have hk0 : (0 : ℚ) < (k : ℚ) := by
      have : (3 : ℚ) ≤ (k : ℚ) := by exact_mod_cast hk.1
      linarith
    have hM : 4 * (parityPairs (N / k)).card ≤ (N / k) ^ 2 := card_parityPairs_le _
    have hMQ : (4 : ℚ) * (((parityPairs (N / k)).card : ℕ) : ℚ) ≤ (((N / k : ℕ) : ℚ)) ^ 2 := by
      exact_mod_cast hM
    have hle : ((N / k : ℕ) : ℚ) ≤ (N : ℚ) / (k : ℚ) := Nat.cast_div_le
    have hnn : (0 : ℚ) ≤ ((N / k : ℕ) : ℚ) := by positivity
    have hsq : (((N / k : ℕ) : ℚ)) ^ 2 ≤ ((N : ℚ) / (k : ℚ)) ^ 2 := by
      exact pow_le_pow_left₀ hnn hle 2
    have hexp : ((N : ℚ) / (k : ℚ)) ^ 2 = (N : ℚ) ^ 2 * ((k : ℚ) ^ 2)⁻¹ := by
      field_simp
    linarith [hMQ, hsq, hexp ▸ hsq]
  have h4 : ∑ k ∈ Finset.Icc 3 N, (((parityPairs (N / k)).card : ℕ) : ℚ)
      ≤ ∑ k ∈ Finset.Icc 3 N, (N : ℚ) ^ 2 / 4 * ((k : ℚ) ^ 2)⁻¹ := Finset.sum_le_sum h3
  have h5 : ∑ k ∈ Finset.Icc 3 N, (N : ℚ) ^ 2 / 4 * ((k : ℚ) ^ 2)⁻¹
      = (N : ℚ) ^ 2 / 4 * ∑ k ∈ Finset.Icc 3 N, ((k : ℚ) ^ 2)⁻¹ := by
    rw [Finset.mul_sum]
  have h6 : (N : ℚ) ^ 2 / 4 * ∑ k ∈ Finset.Icc 3 N, ((k : ℚ) ^ 2)⁻¹ ≤ (N : ℚ) ^ 2 / 4 * (1 / 2) := by
    apply mul_le_mul_of_nonneg_left (sum_inv_sq_le N) (by positivity)
  linarith

/-- **A positive proportion of parity pairs is coprime.**  For `N ≥ 4` at least `N²/16`
of the pairs `0 < n < m ≤ N` with `m + n` odd are coprime. -/
theorem card_coprimePairs_lower (N : ℕ) (hN : 4 ≤ N) : N ^ 2 ≤ 16 * (coprimePairs N).card := by
  have hsplit : (coprimePairs N).card
      + ((parityPairs N).filter fun p => ¬ Nat.gcd p.1 p.2 = 1).card = (parityPairs N).card := by
    rw [coprimePairs]
    exact Finset.card_filter_add_card_filter_not _
  have hbad : 8 * ((parityPairs N).filter fun p => ¬ Nat.gcd p.1 p.2 = 1).card ≤ N ^ 2 := by
    have := card_bad_le_eighth N
    exact_mod_cast this
  have hge := card_parityPairs_ge N
  have hsq : 4 * N ≤ N ^ 2 := by nlinarith
  -- linear arithmetic in the atoms `N`, `N ^ 2`, and the two cardinalities
  have hg : N ^ 2 ≤ 4 * ((coprimePairs N).card
      + ((parityPairs N).filter fun p => ¬ Nat.gcd p.1 p.2 = 1).card) + N := by
    rw [hsplit]; exact hge
  omega

end BerggrenSieve