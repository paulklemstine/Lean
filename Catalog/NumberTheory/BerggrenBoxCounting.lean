import Mathlib
import Catalog.NumberTheory.CoprimePairDensity
import Catalog.NumberTheory.BerggrenTreeCompleteness

/-!
# How many triples in a box are Berggren-generated?

Let `bergBox H` be the set of triples `(a,b,c)` with `0 < a, b, c ≤ H` that are produced
from the seed `(3,4,5)` by the three Berggren matrices, and let `ppBox H` be the set of
*all* primitive Pythagorean triples inside the same box.

The main results are:

* `bergBox_card_le` : `#(bergBox H) ≤ 4 H` (upper bound, via the `(m,n)` parametrisation);
* `bergBox_card_ge` : `H ≤ 100 · #(bergBox H)` for `H ≥ 5` (lower bound, via the
  effective coprime-pair density of `Catalog.NumberTheory.CoprimePairDensity`);
* `bergBox_density_tendsto_zero` : `#(bergBox H) / H³ → 0`, i.e. Berggren-generated
  triples are a vanishing proportion of all triples in the box;
* `bergBox_eq_ppOddBox` and `card_ppBox_eq_two_mul_card_bergBox` : the Berggren tree
  captures *exactly* the primitive Pythagorean triples of the box with odd first leg,
  hence exactly one half of all (ordered) primitive Pythagorean triples of the box and
  *all* of them up to swapping the two legs.  So the "`1 - o(1)`" proportion is in fact
  an exact `1`.
-/

namespace BerggrenBoxCounting

open BerggrenTree

/-- The full integer box `[1,H]³`. -/
def boxAll (H : ℕ) : Finset Tri :=
  Finset.Icc (1 : ℤ) (H : ℤ) ×ˢ Finset.Icc (1 : ℤ) (H : ℤ) ×ˢ Finset.Icc (1 : ℤ) (H : ℤ)

lemma mem_boxAll {H : ℕ} {t : Tri} :
    t ∈ boxAll H ↔ (1 ≤ t.1 ∧ t.1 ≤ H) ∧ (1 ≤ t.2.1 ∧ t.2.1 ≤ H) ∧ (1 ≤ t.2.2 ∧ t.2.2 ≤ H) := by
  simp [boxAll, Finset.mem_product, Finset.mem_Icc, and_assoc]

open Classical in
/-- The Berggren-generated triples inside the box `[1,H]³`. -/
noncomputable def bergBox (H : ℕ) : Finset Tri := (boxAll H).filter (fun t => Reach t)

open Classical in
/-- All primitive Pythagorean triples inside the box `[1,H]³`. -/
noncomputable def ppBox (H : ℕ) : Finset Tri :=
  (boxAll H).filter (fun t => t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 ∧ Int.gcd t.1 t.2.1 = 1)

lemma mem_bergBox {H : ℕ} {t : Tri} :
    t ∈ bergBox H ↔ Reach t ∧ t.1 ≤ H ∧ t.2.1 ≤ H ∧ t.2.2 ≤ H := by
  classical
  rw [bergBox, Finset.mem_filter]
  constructor
  · rintro ⟨hbox, hr⟩
    obtain ⟨⟨_, h1⟩, ⟨_, h2⟩, ⟨_, h3⟩⟩ := mem_boxAll.mp hbox
    exact ⟨hr, h1, h2, h3⟩
  · rintro ⟨hr, h1, h2, h3⟩
    obtain ⟨ha, hb, hc, _, _, _⟩ := reach_valid hr
    exact ⟨mem_boxAll.mpr ⟨⟨by omega, h1⟩, ⟨by omega, h2⟩, ⟨by omega, h3⟩⟩, hr⟩

lemma mem_ppBox {H : ℕ} {t : Tri} :
    t ∈ ppBox H ↔ (1 ≤ t.1 ∧ t.1 ≤ H) ∧ (1 ≤ t.2.1 ∧ t.2.1 ≤ H) ∧ (1 ≤ t.2.2 ∧ t.2.2 ≤ H) ∧
      t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 ∧ Int.gcd t.1 t.2.1 = 1 := by
  classical
  rw [ppBox, Finset.mem_filter]
  constructor
  · rintro ⟨hbox, hpy, hg⟩
    obtain ⟨h1, h2, h3⟩ := mem_boxAll.mp hbox
    exact ⟨h1, h2, h3, hpy, hg⟩
  · rintro ⟨h1, h2, h3, hpy, hg⟩
    exact ⟨mem_boxAll.mpr ⟨h1, h2, h3⟩, hpy, hg⟩

/-! ### The `(m,n)` parametrisation of a valid triple -/

/-- A positive primitive Pythagorean triple with odd first leg has `c + a = 2m²` and
`c - a = 2n²` for natural numbers `m, n`. -/
lemma valid_sq_decomposition {t : Tri} (h : Valid t) :
    ∃ M N : ℕ, t.2.2 + t.1 = 2 * (M : ℤ) ^ 2 ∧ t.2.2 - t.1 = 2 * (N : ℤ) ^ 2 := by
  obtain ⟨a, b, c⟩ := t
  obtain ⟨ha, hb, hc, hpy, hgcd, hodd⟩ := h
  simp only at ha hb hc hpy hgcd hodd ⊢
  have hpt : PythagoreanTriple a b c := by
    unfold PythagoreanTriple
    linarith [hpy]
  obtain ⟨m, n, hab, hcc, _, _⟩ := PythagoreanTriple.coprime_classification.mp ⟨hpt, hgcd⟩
  have hcpos : c = m ^ 2 + n ^ 2 := by
    rcases hcc with h | h
    · exact h
    · exfalso
      nlinarith [sq_nonneg m, sq_nonneg n]
  have ha' : a = m ^ 2 - n ^ 2 := by
    rcases hab with ⟨h1, _⟩ | ⟨h1, _⟩
    · exact h1
    · exfalso
      have h2 : (2 : ℤ) ∣ a := ⟨m * n, by linarith [h1]⟩
      omega
  refine ⟨m.natAbs, n.natAbs, ?_, ?_⟩
  · have hM : ((m.natAbs : ℤ)) ^ 2 = m ^ 2 := Int.natAbs_pow_two m
    rw [hM, hcpos, ha']; ring
  · have hN : ((n.natAbs : ℤ)) ^ 2 = n ^ 2 := Int.natAbs_pow_two n
    rw [hN, hcpos, ha']; ring

/-! ### Upper bound -/

/-- **Sharp upper bound.**  The map `(a,b,c) ↦ (c+a, c-a)` sends a valid triple to a pair of
doubled squares, so the box contains at most `(⌊√H⌋+1)²` Berggren-generated triples. -/
theorem bergBox_card_le_sq_succ_sqrt (H : ℕ) :
    (bergBox H).card ≤ (Nat.sqrt H + 1) ^ 2 := by
  classical
  set s := Nat.sqrt H with hs
  set target : Finset (ℤ × ℤ) :=
    (Finset.Icc 0 s ×ˢ Finset.Icc 0 s).image (fun p => (2 * (p.1 : ℤ) ^ 2, 2 * (p.2 : ℤ) ^ 2))
    with htarget
  have hmap : ∀ t ∈ bergBox H, (t.2.2 + t.1, t.2.2 - t.1) ∈ target := by
    intro t ht
    obtain ⟨hr, h1, h2, h3⟩ := mem_bergBox.mp ht
    have hv := reach_valid hr
    obtain ⟨M, N, hM, hN⟩ := valid_sq_decomposition hv
    obtain ⟨ha, hb, hc, hpy, hgcd, hodd⟩ := hv
    have hMle : M ≤ s := by
      have : (M : ℤ) ^ 2 ≤ (H : ℤ) := by nlinarith [hM, ha, h3]
      have hMn : (M ^ 2 : ℕ) ≤ H := by exact_mod_cast this
      exact Nat.le_sqrt'.mpr (by nlinarith [hMn])
    have hNle : N ≤ s := by
      have : (N : ℤ) ^ 2 ≤ (H : ℤ) := by nlinarith [hN, ha, h3]
      have hNn : (N ^ 2 : ℕ) ≤ H := by exact_mod_cast this
      exact Nat.le_sqrt'.mpr (by nlinarith [hNn])
    refine Finset.mem_image.mpr ⟨(M, N), ?_, ?_⟩
    · simp only [Finset.mem_product, Finset.mem_Icc]
      exact ⟨⟨Nat.zero_le _, hMle⟩, Nat.zero_le _, hNle⟩
    · simp only [Prod.mk.injEq]
      exact ⟨hM.symm, hN.symm⟩
  have hinj : ∀ t ∈ bergBox H, ∀ t' ∈ bergBox H,
      (t.2.2 + t.1, t.2.2 - t.1) = (t'.2.2 + t'.1, t'.2.2 - t'.1) → t = t' := by
    intro t ht t' ht' heq
    obtain ⟨hr, _, _, _⟩ := mem_bergBox.mp ht
    obtain ⟨hr', _, _, _⟩ := mem_bergBox.mp ht'
    obtain ⟨ha, hb, hc, hpy, _, _⟩ := reach_valid hr
    obtain ⟨ha', hb', hc', hpy', _, _⟩ := reach_valid hr'
    simp only [Prod.mk.injEq] at heq
    obtain ⟨e1, e2⟩ := heq
    have hA : t.1 = t'.1 := by omega
    have hC : t.2.2 = t'.2.2 := by omega
    have hB : t.2.1 = t'.2.1 := by nlinarith [hpy, hpy', hA, hC]
    exact Prod.ext hA (Prod.ext hB hC)
  have hcard : (bergBox H).card ≤ target.card :=
    Finset.card_le_card_of_injOn (fun t => (t.2.2 + t.1, t.2.2 - t.1)) hmap
      (fun t ht t' ht' h => hinj t ht t' ht' h)
  have htc : target.card ≤ (s + 1) ^ 2 := by
    refine le_trans (Finset.card_image_le) ?_
    simp [Finset.card_product, Nat.card_Icc, pow_two]
  exact le_trans hcard htc

/-- **Upper bound.**  At most `4H` triples of the box are Berggren-generated. -/
theorem bergBox_card_le (H : ℕ) (hH : 1 ≤ H) : (bergBox H).card ≤ 4 * H := by
  have hmain := bergBox_card_le_sq_succ_sqrt H
  have hsq : Nat.sqrt H ^ 2 ≤ H := Nat.sqrt_le' H
  have hs1 : 1 ≤ Nat.sqrt H := Nat.le_sqrt'.mpr (by simpa using hH)
  nlinarith

/-! ### Lower bound -/

/-- Turning a coprime opposite-parity pair into a primitive Pythagorean triple. -/
lemma pair_valid {n m : ℕ} (hn : 1 ≤ n) (hnm : n < m) (hg : Nat.gcd n m = 1)
    (hpar : (n + m) % 2 = 1) :
    Valid (((m : ℤ) ^ 2 - (n : ℤ) ^ 2, 2 * (m : ℤ) * (n : ℤ), (m : ℤ) ^ 2 + (n : ℤ) ^ 2)) := by
  have hn0 : (0 : ℤ) < (n : ℤ) := by exact_mod_cast hn
  have hnm' : ((n : ℤ)) < (m : ℤ) := by exact_mod_cast hnm
  have hm0 : (0 : ℤ) < (m : ℤ) := by linarith
  have hgz : Int.gcd (m : ℤ) (n : ℤ) = 1 := by
    rw [Int.gcd_natCast_natCast, Nat.gcd_comm]
    exact hg
  -- parity of `m` and `n`
  have hpar' : ((m : ℤ) % 2 = 0 ∧ (n : ℤ) % 2 = 1) ∨ ((m : ℤ) % 2 = 1 ∧ (n : ℤ) % 2 = 0) := by
    omega
  have hclass := PythagoreanTriple.coprime_classification (x := (m : ℤ) ^ 2 - (n : ℤ) ^ 2)
    (y := 2 * (m : ℤ) * (n : ℤ)) (z := (m : ℤ) ^ 2 + (n : ℤ) ^ 2)
  obtain ⟨hpt, hgcd⟩ := hclass.mpr ⟨(m : ℤ), (n : ℤ),
    Or.inl ⟨rfl, rfl⟩, Or.inl rfl, hgz, hpar'⟩
  have hpy : ((m : ℤ) ^ 2 - (n : ℤ) ^ 2) ^ 2 + (2 * (m : ℤ) * (n : ℤ)) ^ 2
      = ((m : ℤ) ^ 2 + (n : ℤ) ^ 2) ^ 2 := by ring
  refine ⟨by simp only; nlinarith, by simp only; positivity, by simp only; positivity, hpy,
    hgcd, ?_⟩
  -- the first leg is odd
  simp only
  rcases hpar' with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · obtain ⟨k, hk⟩ : ∃ k : ℤ, (m : ℤ) = 2 * k := ⟨(m : ℤ) / 2, by omega⟩
    obtain ⟨l, hl⟩ : ∃ l : ℤ, (n : ℤ) = 2 * l + 1 := ⟨((n : ℤ) - 1) / 2, by omega⟩
    have : (m : ℤ) ^ 2 - (n : ℤ) ^ 2 = 2 * (2 * k ^ 2 - 2 * l ^ 2 - 2 * l) - 1 := by
      rw [hk, hl]; ring
    omega
  · obtain ⟨k, hk⟩ : ∃ k : ℤ, (m : ℤ) = 2 * k + 1 := ⟨((m : ℤ) - 1) / 2, by omega⟩
    obtain ⟨l, hl⟩ : ∃ l : ℤ, (n : ℤ) = 2 * l := ⟨(n : ℤ) / 2, by omega⟩
    have : (m : ℤ) ^ 2 - (n : ℤ) ^ 2 = 2 * (2 * k ^ 2 + 2 * k - 2 * l ^ 2) + 1 := by
      rw [hk, hl]; ring
    omega

/-- **Lower bound.**  At least `H / 100` triples of the box are Berggren-generated. -/
theorem bergBox_card_ge (H : ℕ) (hH : 5 ≤ H) : H ≤ 100 * (bergBox H).card := by
  classical
  set X := Nat.sqrt (H / 2) with hX
  -- the injection from coprime opposite-parity pairs
  have hmap : ∀ p ∈ CoprimePairDensity.copOpp X,
      (((p.2 : ℤ) ^ 2 - (p.1 : ℤ) ^ 2, 2 * (p.2 : ℤ) * (p.1 : ℤ),
        (p.2 : ℤ) ^ 2 + (p.1 : ℤ) ^ 2) : Tri) ∈ bergBox H := by
    rintro ⟨n, m⟩ hp
    obtain ⟨hn1, hnX, hm1, hmX, hgcd, hnm, hpar⟩ := CoprimePairDensity.mem_copOpp.mp hp
    simp only at hn1 hnX hm1 hmX hgcd hnm hpar
    have hval := pair_valid hn1 hnm hgcd hpar
    have hsum : m ^ 2 + n ^ 2 ≤ H := by
      have h1 : X ^ 2 ≤ H / 2 := Nat.sqrt_le' (H / 2)
      have h2 : m ^ 2 ≤ X ^ 2 := Nat.pow_le_pow_left hmX 2
      have h3 : n ^ 2 ≤ X ^ 2 := Nat.pow_le_pow_left hnX 2
      omega
    have hsumZ : ((m : ℤ)) ^ 2 + ((n : ℤ)) ^ 2 ≤ (H : ℤ) := by exact_mod_cast hsum
    have hn0 : (0 : ℤ) < (n : ℤ) := by exact_mod_cast hn1
    have hnm' : ((n : ℤ)) < (m : ℤ) := by exact_mod_cast hnm
    refine mem_bergBox.mpr ⟨reach_iff_valid _ |>.mpr hval, ?_, ?_, ?_⟩
    · simp only; nlinarith
    · simp only; nlinarith
    · simpa using hsumZ
  have hinj : ∀ p ∈ CoprimePairDensity.copOpp X, ∀ q ∈ CoprimePairDensity.copOpp X,
      (((p.2 : ℤ) ^ 2 - (p.1 : ℤ) ^ 2, 2 * (p.2 : ℤ) * (p.1 : ℤ),
        (p.2 : ℤ) ^ 2 + (p.1 : ℤ) ^ 2) : Tri)
        = (((q.2 : ℤ) ^ 2 - (q.1 : ℤ) ^ 2, 2 * (q.2 : ℤ) * (q.1 : ℤ),
        (q.2 : ℤ) ^ 2 + (q.1 : ℤ) ^ 2) : Tri) → p = q := by
    rintro ⟨n, m⟩ _ ⟨n', m'⟩ _ heq
    simp only [Prod.mk.injEq] at heq
    obtain ⟨e1, _, e3⟩ := heq
    have hm : ((m : ℤ)) ^ 2 = ((m' : ℤ)) ^ 2 := by linarith
    have hn : ((n : ℤ)) ^ 2 = ((n' : ℤ)) ^ 2 := by linarith
    have hmn : m ^ 2 = m' ^ 2 := by exact_mod_cast hm
    have hnn : n ^ 2 = n' ^ 2 := by exact_mod_cast hn
    have : m = m' := Nat.pow_left_injective (by norm_num) hmn
    have : n = n' := Nat.pow_left_injective (by norm_num) hnn
    simp_all
  have hcard : (CoprimePairDensity.copOpp X).card ≤ (bergBox H).card :=
    Finset.card_le_card_of_injOn _ hmap (fun p hp q hq h => hinj p hp q hq h)
  -- the root is in the box, so the box is non-empty
  have hroot : ((3 : ℤ), (4 : ℤ), (5 : ℤ)) ∈ bergBox H := by
    have h5 : (5 : ℤ) ≤ (H : ℤ) := by exact_mod_cast hH
    refine mem_bergBox.mpr ⟨Reach.root, ?_, ?_, ?_⟩ <;> simp only <;> omega
  have hne : 1 ≤ (bergBox H).card := Finset.card_pos.mpr ⟨_, hroot⟩
  -- quantitative chain
  have hdens := CoprimePairDensity.card_copOpp_ge X
  have hX1 : 1 ≤ X := by
    rw [hX]
    exact Nat.le_sqrt'.mpr (by omega)
  have hXsq : H / 2 ≤ 3 * X ^ 2 := by
    have h1 : H / 2 < (X + 1) ^ 2 := Nat.lt_succ_sqrt' (H / 2)
    nlinarith
  have hH2 : H ≤ 2 * (H / 2) + 1 := by omega
  nlinarith [hdens, hcard, hne, hXsq, hH2]

/-! ### Vanishing density in the full box -/

/-- **Berggren-generated triples are a vanishing proportion of the box.** -/
theorem bergBox_density_tendsto_zero :
    Filter.Tendsto (fun H : ℕ => ((bergBox H).card : ℝ) / (H : ℝ) ^ 3) Filter.atTop
      (nhds 0) := by
  have hbound : ∀ᶠ H : ℕ in Filter.atTop,
      ((bergBox H).card : ℝ) / (H : ℝ) ^ 3 ≤ 4 / (H : ℝ) := by
    filter_upwards [Filter.eventually_ge_atTop 1] with H hH
    have hHR : (1 : ℝ) ≤ (H : ℝ) := by exact_mod_cast hH
    have hcard : ((bergBox H).card : ℝ) ≤ 4 * (H : ℝ) := by
      exact_mod_cast bergBox_card_le H hH
    rw [div_le_div_iff₀ (by positivity) (by positivity)]
    have h1 : ((bergBox H).card : ℝ) * (H : ℝ) ≤ 4 * (H : ℝ) * (H : ℝ) := by nlinarith
    have hcube : (H : ℝ) ^ 3 = (H : ℝ) * (H : ℝ) * (H : ℝ) := by ring
    have h2 : (4 : ℝ) * (H : ℝ) * (H : ℝ) ≤ 4 * (H : ℝ) ^ 3 := by
      rw [hcube]; nlinarith
    linarith
  have hnn : ∀ᶠ H : ℕ in Filter.atTop, (0 : ℝ) ≤ ((bergBox H).card : ℝ) / (H : ℝ) ^ 3 := by
    filter_upwards [Filter.eventually_ge_atTop 1] with H _
    positivity
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds ?_ hnn hbound
  exact tendsto_const_div_atTop_nhds_zero_nat 4

/-! ### Comparison with the primitive Pythagorean triples of the box -/

open Classical in
/-- Primitive Pythagorean triples of the box whose first leg is odd. -/
noncomputable def ppOddBox (H : ℕ) : Finset Tri := (ppBox H).filter (fun t => t.1 % 2 = 1)

/-- **The Berggren tree captures exactly the odd-first-leg primitive Pythagorean triples
of the box.** -/
theorem bergBox_eq_ppOddBox (H : ℕ) : bergBox H = ppOddBox H := by
  classical
  ext t
  rw [ppOddBox, Finset.mem_filter]
  constructor
  · intro ht
    obtain ⟨hr, h1, h2, h3⟩ := mem_bergBox.mp ht
    obtain ⟨ha, hb, hc, hpy, hgcd, hodd⟩ := reach_valid hr
    exact ⟨mem_ppBox.mpr ⟨⟨by omega, h1⟩, ⟨by omega, h2⟩, ⟨by omega, h3⟩, hpy, hgcd⟩, hodd⟩
  · rintro ⟨hpp, hodd⟩
    obtain ⟨⟨ha1, ha2⟩, ⟨hb1, hb2⟩, ⟨hc1, hc2⟩, hpy, hgcd⟩ := mem_ppBox.mp hpp
    refine mem_bergBox.mpr ⟨?_, ha2, hb2, hc2⟩
    exact (reach_iff_valid t).mpr ⟨by omega, by omega, by omega, hpy, hgcd, hodd⟩

/-- In a primitive Pythagorean triple exactly one leg is odd, so swapping the legs is a
bijection between the odd-first-leg and even-first-leg triples of the box. -/
theorem card_ppBox_eq_two_mul_card_bergBox (H : ℕ) :
    (ppBox H).card = 2 * (bergBox H).card := by
  classical
  have hsplit : (ppOddBox H).card + ((ppBox H).filter (fun t => ¬ t.1 % 2 = 1)).card
      = (ppBox H).card := by
    rw [ppOddBox]
    exact Finset.card_filter_add_card_filter_not _
  have hswap1 : ((ppBox H).filter (fun t => ¬ t.1 % 2 = 1)).card ≤ (ppOddBox H).card := by
    refine Finset.card_le_card_of_injOn (fun t => (t.2.1, t.1, t.2.2)) ?_ ?_
    · intro t ht
      obtain ⟨hpp, heven⟩ := Finset.mem_filter.mp ht
      obtain ⟨⟨ha1, ha2⟩, ⟨hb1, hb2⟩, ⟨hc1, hc2⟩, hpy, hgcd⟩ := mem_ppBox.mp hpp
      have hbodd : t.2.1 % 2 = 1 := by
        rcases Int.emod_two_eq_zero_or_one t.1 with h1 | h1
        · rcases Int.emod_two_eq_zero_or_one t.2.1 with h2 | h2
          · exfalso
            have hd1 : (2 : ℤ) ∣ t.1 := by omega
            have hd2 : (2 : ℤ) ∣ t.2.1 := by omega
            have := (Int.isCoprime_iff_gcd_eq_one.mpr hgcd).isUnit_of_dvd' hd1 hd2
            have := Int.isUnit_iff.1 this
            omega
          · exact h2
        · exact absurd h1 heven
      refine Finset.mem_filter.mpr ⟨mem_ppBox.mpr ⟨⟨hb1, hb2⟩, ⟨ha1, ha2⟩, ⟨hc1, hc2⟩, ?_, ?_⟩,
        hbodd⟩
      · simp only; linarith [hpy]
      · simp only; rwa [Int.gcd_comm]
    · intro t _ t' _ heq
      simp only [Prod.mk.injEq] at heq
      exact Prod.ext heq.2.1 (Prod.ext heq.1 heq.2.2)
  have hswap2 : (ppOddBox H).card ≤ ((ppBox H).filter (fun t => ¬ t.1 % 2 = 1)).card := by
    refine Finset.card_le_card_of_injOn (fun t => (t.2.1, t.1, t.2.2)) ?_ ?_
    · intro t ht
      obtain ⟨hpp, hodd⟩ := Finset.mem_filter.mp ht
      obtain ⟨⟨ha1, ha2⟩, ⟨hb1, hb2⟩, ⟨hc1, hc2⟩, hpy, hgcd⟩ := mem_ppBox.mp hpp
      have hbeven : ¬ t.2.1 % 2 = 1 := by
        intro h2
        have hc2' : t.2.2 ^ 2 % 4 = 2 := by
          obtain ⟨k, hk⟩ : ∃ k : ℤ, t.1 = 2 * k + 1 := ⟨(t.1 - 1) / 2, by omega⟩
          obtain ⟨l, hl⟩ : ∃ l : ℤ, t.2.1 = 2 * l + 1 := ⟨(t.2.1 - 1) / 2, by omega⟩
          have : t.2.2 ^ 2 = 4 * (k ^ 2 + k + l ^ 2 + l) + 2 := by
            rw [← hpy, hk, hl]; ring
          omega
        obtain ⟨j, hj⟩ : ∃ j : ℤ, t.2.2 = 2 * j ∨ t.2.2 = 2 * j + 1 :=
          ⟨t.2.2 / 2, by omega⟩
        rcases hj with hj | hj
        · have : t.2.2 ^ 2 = 4 * j ^ 2 := by rw [hj]; ring
          omega
        · have : t.2.2 ^ 2 = 4 * (j ^ 2 + j) + 1 := by rw [hj]; ring
          omega
      refine Finset.mem_filter.mpr ⟨mem_ppBox.mpr ⟨⟨hb1, hb2⟩, ⟨ha1, ha2⟩, ⟨hc1, hc2⟩, ?_, ?_⟩, ?_⟩
      · simp only; linarith [hpy]
      · simp only; rwa [Int.gcd_comm]
      · simpa using hbeven
    · intro t _ t' _ heq
      simp only [Prod.mk.injEq] at heq
      exact Prod.ext heq.2.1 (Prod.ext heq.1 heq.2.2)
  rw [bergBox_eq_ppOddBox]
  omega

/-- Since both legs of a Pythagorean triple are smaller than the hypotenuse, the box
condition is equivalent to a bound on the hypotenuse alone. -/
theorem mem_bergBox_iff_hyp {H : ℕ} {t : Tri} : t ∈ bergBox H ↔ Reach t ∧ t.2.2 ≤ H := by
  constructor
  · intro h
    obtain ⟨hr, _, _, h3⟩ := mem_bergBox.mp h
    exact ⟨hr, h3⟩
  · rintro ⟨hr, h3⟩
    obtain ⟨ha, hb, hc, hpy, _, _⟩ := reach_valid hr
    refine mem_bergBox.mpr ⟨hr, ?_, ?_, h3⟩
    · nlinarith
    · nlinarith

/-- **Every primitive Pythagorean triple of the box is Berggren-generated, up to swapping
the two legs.**  This is the sharp form of the `(1 - o(1))` statement: the proportion is
in fact exactly `1`. -/
theorem ppBox_mem_bergBox_or_swap {H : ℕ} {t : Tri} (ht : t ∈ ppBox H) :
    t ∈ bergBox H ∨ (t.2.1, t.1, t.2.2) ∈ bergBox H := by
  obtain ⟨⟨ha1, ha2⟩, ⟨hb1, hb2⟩, ⟨hc1, hc2⟩, hpy, hgcd⟩ := mem_ppBox.mp ht
  rcases Int.emod_two_eq_zero_or_one t.1 with heven | hodd
  · -- the first leg is even, hence the second one is odd
    right
    have hbodd : t.2.1 % 2 = 1 := by
      rcases Int.emod_two_eq_zero_or_one t.2.1 with h2 | h2
      · exfalso
        have hd1 : (2 : ℤ) ∣ t.1 := by omega
        have hd2 : (2 : ℤ) ∣ t.2.1 := by omega
        have hu := (Int.isCoprime_iff_gcd_eq_one.mpr hgcd).isUnit_of_dvd' hd1 hd2
        have := Int.isUnit_iff.1 hu
        omega
      · exact h2
    refine mem_bergBox.mpr ⟨(reach_iff_valid _).mpr ⟨?_, ?_, ?_, ?_, ?_, ?_⟩, hb2, ha2, hc2⟩ <;>
      simp only
    · omega
    · omega
    · omega
    · linarith [hpy]
    · rwa [Int.gcd_comm]
    · exact hbodd
  · left
    exact mem_bergBox.mpr ⟨(reach_iff_valid _).mpr
      ⟨by omega, by omega, by omega, hpy, hgcd, hodd⟩, ha2, hb2, hc2⟩

/-- **Summary theorem.**  The number of Berggren-generated triples in the box `[1,H]³` is
`Θ(H)` — hence a vanishing fraction of the `H³` triples of the box — while it is exactly
one half of the number of ordered primitive Pythagorean triples in the same box, i.e. all
of them up to swapping the legs. -/
theorem berggren_box_theta (H : ℕ) (hH : 5 ≤ H) :
    H ≤ 100 * (bergBox H).card ∧ (bergBox H).card ≤ 4 * H ∧
      (bergBox H).card ≤ (Nat.sqrt H + 1) ^ 2 ∧
      (ppBox H).card = 2 * (bergBox H).card :=
  ⟨bergBox_card_ge H hH, bergBox_card_le H (by omega), bergBox_card_le_sq_succ_sqrt H,
    card_ppBox_eq_two_mul_card_bergBox H⟩

end BerggrenBoxCounting