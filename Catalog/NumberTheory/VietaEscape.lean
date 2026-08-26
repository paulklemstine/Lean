import Catalog.NumberTheory.VietaInjectiveFamilies
import Catalog.NumberTheory.CubeDigitFamilies

/-!
# The arithmetic ceiling of the Vieta family, and how to escape it

This file compares the Vieta three-cube family `a³ + b³ + (-a-b)³ = -3ab(a+b)`
with the cube-digit family of `Catalog.NumberTheory.CubeDigitFamilies`.

Two complementary results:

* **Ceiling.**  Every Vieta value is divisible by `6` (`six_dvd_vietaValue`), so
  the Vieta identity can represent at most `⌊N/6⌋` integers below `N`
  (`vieta_count_le`).  Together with the square-root lower bound of
  `Catalog.NumberTheory.VietaInjectiveFamilies` this sandwiches the Vieta
  counting function:  `⌊√(N/6)⌋ ≤ #Vieta(N) ≤ ⌊N/6⌋` (`vieta_count_sandwich`).

* **Escape.**  Restricting the cube-digit box to arguments `≡ 1 (mod 6)` gives,
  for every `t ≥ 1`, at least `136 t¹⁹` integers below `10⁸ t²⁷` which are sums
  of three positive cubes but are **not** Vieta values at all
  (`escape_count`).  Since `n³ ≡ n (mod 6)`, all these values are `≡ 3 (mod 6)`,
  hence lie outside the Vieta value set by the ceiling theorem.

So the cube-digit construction is not merely quantitatively stronger
(`N^(19/27)` against `N^(1/2)`); it produces integers the Vieta identity can
never reach.
-/

namespace VietaEscape

open VietaInjectiveFamilies CubeDigitFamilies

/-! ## The ceiling: Vieta values are multiples of six -/

/-- **Every Vieta value is divisible by 6.**  Indeed `ab(a+b)` is always even. -/
theorem six_dvd_vietaValue (a b : ℤ) : (6 : ℤ) ∣ vietaValue a b := by
  have h2 : (2 : ℤ) ∣ a * b * (a + b) := by
    rcases Int.even_or_odd a with ⟨k, hk⟩ | ⟨k, hk⟩
    · exact ⟨k * b * (a + b), by rw [hk]; ring⟩
    · rcases Int.even_or_odd b with ⟨l, hl⟩ | ⟨l, hl⟩
      · exact ⟨a * l * (a + b), by rw [hl]; ring⟩
      · exact ⟨a * b * (k + l + 1), by rw [hk, hl]; ring⟩
  obtain ⟨m, hm⟩ := h2
  refine ⟨-m, ?_⟩
  unfold vietaValue
  have : a * b * (a + b) = 2 * m := hm
  calc -3 * a * b * (a + b) = -3 * (a * b * (a + b)) := by ring
    _ = -3 * (2 * m) := by rw [this]
    _ = 6 * -m := by ring

/-- An integer which is not divisible by `6` is not a Vieta value. -/
theorem not_vietaValue_of_not_six_dvd {k : ℤ} (h : ¬ (6 : ℤ) ∣ k) (a b : ℤ) :
    vietaValue a b ≠ k := by
  intro hk
  exact h (hk ▸ six_dvd_vietaValue a b)

/-- **The Vieta ceiling.**  At most `⌊N/6⌋` positive integers `≤ N` are Vieta
values, because they all are multiples of six. -/
theorem vieta_count_le (N : ℕ) : (repSet N).ncard ≤ N / 6 := by
  classical
  set T : Finset ℤ := (Finset.Icc 1 (N / 6)).image (fun j : ℕ => (6 * j : ℤ)) with hT
  have hsub : repSet N ⊆ ↑T := by
    rintro k ⟨hk0, hkN, a, b, -, -, -, hval⟩
    have hdvd : (6 : ℤ) ∣ k := hval ▸ six_dvd_vietaValue a b
    obtain ⟨j, hj⟩ := hdvd
    have hj0 : 0 < j := by nlinarith [hk0, hj]
    have hjN : 6 * j ≤ (N : ℤ) := by rw [← hj]; exact hkN
    refine Finset.mem_coe.mpr ?_
    rw [hT, Finset.mem_image]
    refine ⟨j.toNat, ?_, ?_⟩
    · rw [Finset.mem_Icc]
      constructor
      · omega
      · have hjn : 6 * j.toNat ≤ N := by omega
        omega
    · rw [hj]
      have : ((j.toNat : ℤ)) = j := Int.toNat_of_nonneg (le_of_lt hj0)
      rw [this]
  have hcard : T.card ≤ N / 6 := by
    calc T.card ≤ (Finset.Icc 1 (N / 6)).card := Finset.card_image_le
      _ = N / 6 := by rw [Nat.card_Icc]; omega
  calc (repSet N).ncard ≤ (↑T : Set ℤ).ncard := Set.ncard_le_ncard hsub T.finite_toSet
    _ = T.card := Set.ncard_coe_finset T
    _ ≤ N / 6 := hcard

/-- **Sandwich for the Vieta counting function.** -/
theorem vieta_count_sandwich (N : ℕ) :
    Nat.sqrt (N / 6) ≤ (repSet N).ncard ∧ (repSet N).ncard ≤ N / 6 :=
  ⟨vieta_count_ge_sqrt N, vieta_count_le N⟩

/-! ## Escaping the Vieta family: cube-digit values `≡ 3 (mod 6)` -/

/-- The residue-restricted cube-digit box. -/
def escBox (t : ℕ) : Finset (ℕ × ℕ × ℕ) :=
  Finset.Icc 1 (t ^ 4) ×ˢ Finset.Ico (4 * t ^ 6) (8 * t ^ 6) ×ˢ
    Finset.Ico (34 * t ^ 9) (68 * t ^ 9)

/-- The value attached to a box point: all three cube roots are `≡ 1 (mod 6)`. -/
def escVal (p : ℕ × ℕ × ℕ) : ℕ :=
  (6 * p.1 + 1) ^ 3 + (6 * p.2.1 + 1) ^ 3 + (6 * p.2.2 + 1) ^ 3

theorem mem_escBox_iff {t u v w : ℕ} :
    (u, v, w) ∈ escBox t ↔
      (1 ≤ u ∧ u ≤ t ^ 4) ∧ (4 * t ^ 6 ≤ v ∧ v < 8 * t ^ 6) ∧
        (34 * t ^ 9 ≤ w ∧ w < 68 * t ^ 9) := by
  simp [escBox, Finset.mem_product, Finset.mem_Icc, Finset.mem_Ico, and_assoc]

theorem escBox_card (t : ℕ) : (escBox t).card = 136 * t ^ 19 := by
  rw [escBox, Finset.card_product, Finset.card_product, Nat.card_Icc, Nat.card_Ico,
    Nat.card_Ico]
  have h1 : t ^ 4 + 1 - 1 = t ^ 4 := by omega
  have h2 : 8 * t ^ 6 - 4 * t ^ 6 = 4 * t ^ 6 := by omega
  have h3 : 68 * t ^ 9 - 34 * t ^ 9 = 34 * t ^ 9 := by omega
  rw [h1, h2, h3]
  ring

/-- First greedy window for the residue-restricted box. -/
theorem escBox_gap_x {t u v w : ℕ} (ht : 1 ≤ t) (h : (u, v, w) ∈ escBox t) :
    (6 * u + 1) ^ 3 < 3 * (6 * v + 1) ^ 2 + 3 * (6 * v + 1) + 1 := by
  rw [mem_escBox_iff] at h
  obtain ⟨⟨-, hu⟩, ⟨hv, -⟩, -⟩ := h
  have h4 : 1 ≤ t ^ 4 := Nat.one_le_pow _ _ ht
  have hx : 6 * u + 1 ≤ 7 * t ^ 4 := by omega
  have hx3 : (6 * u + 1) ^ 3 ≤ (7 * t ^ 4) ^ 3 := Nat.pow_le_pow_left hx 3
  have hy : 24 * t ^ 6 ≤ 6 * v + 1 := by omega
  have hy2 : (24 * t ^ 6) ^ 2 ≤ (6 * v + 1) ^ 2 := Nat.pow_le_pow_left hy 2
  have e1 : (7 * t ^ 4) ^ 3 = 343 * t ^ 12 := by ring
  have e2 : (24 * t ^ 6) ^ 2 = 576 * t ^ 12 := by ring
  rw [e1] at hx3
  rw [e2] at hy2
  have h0 : 0 ≤ 6 * v + 1 := Nat.zero_le _
  have hp12 : 1 ≤ t ^ 12 := Nat.one_le_pow _ _ ht
  linarith

/-- Second greedy window for the residue-restricted box. -/
theorem escBox_gap_xy {t u v w : ℕ} (ht : 1 ≤ t) (h : (u, v, w) ∈ escBox t) :
    (6 * u + 1) ^ 3 + (6 * v + 1) ^ 3 <
      3 * (6 * w + 1) ^ 2 + 3 * (6 * w + 1) + 1 := by
  rw [mem_escBox_iff] at h
  obtain ⟨⟨-, hu⟩, ⟨-, hv⟩, ⟨hw, -⟩⟩ := h
  have h4 : 1 ≤ t ^ 4 := Nat.one_le_pow _ _ ht
  have hx : 6 * u + 1 ≤ 7 * t ^ 4 := by omega
  have hx3 : (6 * u + 1) ^ 3 ≤ (7 * t ^ 4) ^ 3 := Nat.pow_le_pow_left hx 3
  have hy : 6 * v + 1 < 48 * t ^ 6 := by omega
  have hy3 : (6 * v + 1) ^ 3 < (48 * t ^ 6) ^ 3 := Nat.pow_lt_pow_left hy (by norm_num)
  have hz : 204 * t ^ 9 ≤ 6 * w + 1 := by omega
  have hz2 : (204 * t ^ 9) ^ 2 ≤ (6 * w + 1) ^ 2 := Nat.pow_le_pow_left hz 2
  have e1 : (7 * t ^ 4) ^ 3 = 343 * t ^ 12 := by ring
  have e2 : (48 * t ^ 6) ^ 3 = 110592 * t ^ 18 := by ring
  have e3 : (204 * t ^ 9) ^ 2 = 41616 * t ^ 18 := by ring
  have e4 : t ^ 12 ≤ t ^ 18 := Nat.pow_le_pow_right ht (by norm_num)
  rw [e1] at hx3
  rw [e2] at hy3
  rw [e3] at hz2
  have h0 : 0 ≤ 6 * w + 1 := Nat.zero_le _
  have hp18 : 1 ≤ t ^ 18 := Nat.one_le_pow _ _ ht
  linarith

/-- Every value of the residue-restricted box is at most `10⁸ t²⁷`. -/
theorem escVal_le {t u v w : ℕ} (ht : 1 ≤ t) (h : (u, v, w) ∈ escBox t) :
    escVal (u, v, w) ≤ 100000000 * t ^ 27 := by
  rw [mem_escBox_iff] at h
  obtain ⟨⟨-, hu⟩, ⟨-, hv⟩, ⟨-, hw⟩⟩ := h
  have h4 : 1 ≤ t ^ 4 := Nat.one_le_pow _ _ ht
  have hx : 6 * u + 1 ≤ 7 * t ^ 4 := by omega
  have hx3 : (6 * u + 1) ^ 3 ≤ (7 * t ^ 4) ^ 3 := Nat.pow_le_pow_left hx 3
  have hy : 6 * v + 1 < 48 * t ^ 6 := by omega
  have hy3 : (6 * v + 1) ^ 3 < (48 * t ^ 6) ^ 3 := Nat.pow_lt_pow_left hy (by norm_num)
  have hz : 6 * w + 1 < 408 * t ^ 9 := by omega
  have hz3 : (6 * w + 1) ^ 3 < (408 * t ^ 9) ^ 3 := Nat.pow_lt_pow_left hz (by norm_num)
  have e1 : (7 * t ^ 4) ^ 3 = 343 * t ^ 12 := by ring
  have e2 : (48 * t ^ 6) ^ 3 = 110592 * t ^ 18 := by ring
  have e3 : (408 * t ^ 9) ^ 3 = 67917312 * t ^ 27 := by ring
  have e4 : t ^ 12 ≤ t ^ 27 := Nat.pow_le_pow_right ht (by norm_num)
  have e5 : t ^ 18 ≤ t ^ 27 := Nat.pow_le_pow_right ht (by norm_num)
  rw [e1] at hx3
  rw [e2] at hy3
  rw [e3] at hz3
  have hp27 : 1 ≤ t ^ 27 := Nat.one_le_pow _ _ ht
  unfold escVal
  simp only
  linarith

/-- Every value of the residue-restricted box is `≡ 3 (mod 6)`. -/
theorem escVal_mod_six (p : ℕ × ℕ × ℕ) : escVal p % 6 = 3 := by
  obtain ⟨u, v, w⟩ := p
  have hrep : escVal (u, v, w) =
      6 * (36 * u ^ 3 + 18 * u ^ 2 + 3 * u + 36 * v ^ 3 + 18 * v ^ 2 + 3 * v +
        36 * w ^ 3 + 18 * w ^ 2 + 3 * w) + 3 := by
    unfold escVal
    simp only
    ring
  omega

/-- Consequently no value of the residue-restricted box is a Vieta value. -/
theorem escVal_not_vietaValue (p : ℕ × ℕ × ℕ) (a b : ℤ) :
    vietaValue a b ≠ (escVal p : ℤ) := by
  refine not_vietaValue_of_not_six_dvd ?_ a b
  intro hdvd
  obtain ⟨m, hm⟩ := hdvd
  have h6 : (6 : ℤ) ∣ (escVal p : ℤ) := ⟨m, hm⟩
  have : (6 : ℕ) ∣ escVal p := by exact_mod_cast h6
  have := escVal_mod_six p
  omega

/-- Positive integers `≤ N` which are sums of three positive cubes but are not
Vieta values. -/
def escapeSet (N : ℕ) : Set ℤ :=
  {k | 0 < k ∧ k ≤ (N : ℤ) ∧ SumOfThreePositiveCubes k ∧
    ∀ a b : ℤ, vietaValue a b ≠ k}

theorem escapeSet_finite (N : ℕ) : (escapeSet N).Finite :=
  (Set.finite_Icc (1 : ℤ) (N : ℤ)).subset (by rintro k ⟨h1, h2, -, -⟩; exact ⟨h1, h2⟩)

theorem card_le_ncard_escapeSet {N : ℕ} (T : Finset ℤ)
    (hT : ∀ k ∈ T, k ∈ escapeSet N) : T.card ≤ (escapeSet N).ncard := by
  have hsub : (↑T : Set ℤ) ⊆ escapeSet N := fun k hk => hT k (by simpa using hk)
  have := Set.ncard_le_ncard hsub (escapeSet_finite N)
  simpa [Set.ncard_coe_finset] using this

/-- **Escape theorem.**  For every `t ≥ 1` there are at least `136 t¹⁹` integers
in `[1, 10⁸ t²⁷]` that are sums of three positive cubes and are *not* values of
the Vieta identity for any pair of integers.  The count is again of order
`N^(19/27)` in `N = 10⁸ t²⁷`. -/
theorem escape_count (t : ℕ) (ht : 1 ≤ t) :
    136 * t ^ 19 ≤ (escapeSet (100000000 * t ^ 27)).ncard := by
  classical
  set T : Finset ℤ := (escBox t).image (fun p => (escVal p : ℤ)) with hT
  have hinj : Set.InjOn (fun p : ℕ × ℕ × ℕ => (escVal p : ℤ)) ↑(escBox t) := by
    rintro ⟨u, v, w⟩ hp ⟨u', v', w'⟩ hq hEq
    have hp' : (u, v, w) ∈ escBox t := hp
    have hq' : (u', v', w') ∈ escBox t := hq
    have hEq' : ((escVal (u, v, w) : ℤ)) = ((escVal (u', v', w') : ℤ)) := hEq
    have hval : escVal (u, v, w) = escVal (u', v', w') := by exact_mod_cast hEq'
    have hval2 : (6 * u + 1) ^ 3 + (6 * v + 1) ^ 3 + (6 * w + 1) ^ 3 =
        (6 * u' + 1) ^ 3 + (6 * v' + 1) ^ 3 + (6 * w' + 1) ^ 3 := hval
    obtain ⟨hx, hy, hz⟩ :=
      cubeSum_inj_of_gaps (escBox_gap_x ht hp') (escBox_gap_x ht hq')
        (escBox_gap_xy ht hp') (escBox_gap_xy ht hq') hval2
    have : u = u' ∧ v = v' ∧ w = w' := by omega
    simp [this.1, this.2.1, this.2.2]
  have hcard : T.card = 136 * t ^ 19 := by
    rw [hT, Finset.card_image_of_injOn hinj, escBox_card]
  have hmem : ∀ k ∈ T, k ∈ escapeSet (100000000 * t ^ 27) := by
    intro k hk
    rw [hT, Finset.mem_image] at hk
    obtain ⟨⟨u, v, w⟩, huvw, rfl⟩ := hk
    have hmemb : (u, v, w) ∈ escBox t := huvw
    refine ⟨?_, ?_, ?_, ?_⟩
    · have : 0 < escVal (u, v, w) := by
        unfold escVal; simp only; positivity
      exact_mod_cast this
    · exact_mod_cast escVal_le ht hmemb
    · refine ⟨((6 * u + 1 : ℕ) : ℤ), ((6 * v + 1 : ℕ) : ℤ), ((6 * w + 1 : ℕ) : ℤ),
        by positivity, by positivity, by positivity, ?_⟩
      unfold escVal
      push_cast
      ring
    · intro a b
      exact escVal_not_vietaValue (u, v, w) a b
  calc 136 * t ^ 19 = T.card := hcard.symm
    _ ≤ (escapeSet (100000000 * t ^ 27)).ncard := card_le_ncard_escapeSet T hmem

end VietaEscape