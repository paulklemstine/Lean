/-
# Tower weights, tower radix representations, and the position function `K`

This file develops, from scratch, the arithmetic of the *tower weight sequence*

```
W 0 = 1,   W (k+1) = 2 ^ (W k) * W k
```

together with the *position function* `K n = least k with n < W k`, and proves a chain of
results about it:

* `W_eq_two_pow_sumW` : `W k = 2 ^ (∑_{i<k} W i)`, i.e. `log₂ (W k) = ∑_{i<k} W i`;
* strict monotonicity of `W`, well-definedness and monotonicity of `K`;
* `towerDigit_sum` / `towerDigit_unique` : existence and uniqueness of the mixed radix
  ("tower radix") expansion `n = ∑_{i<k} d i * W i` with `d i < 2 ^ W i`;
* `no_binary_compression` : *any* injective binary encoding of the `W k` valid length-`k`
  tower representations has a codeword of length at least `log₂ (W k) = ∑_{i<k} W i`,
  and `padBits_length` / `padBits_injOn` show that this bound is attained;
* `K_le_L2_add_two` and `L2_le_K_add_one`, giving `|K n - L₂ n| ≤ 2` where `L₂` is the
  number of iterations of `x ↦ ⌈log₂ (x+1)⌉` needed to reach a value `≤ 2`.

Everything is elementary and self-contained (only Mathlib is imported).
-/

import Mathlib

namespace TowerRadix

open Finset

/-! ## The tower weights `W` -/

/-- The tower weights: `W 0 = 1` and `W (k+1) = 2 ^ (W k) * W k`. -/
def W : ℕ → ℕ
  | 0 => 1
  | k + 1 => 2 ^ W k * W k

@[simp] theorem W_zero : W 0 = 1 := rfl

theorem W_succ (k : ℕ) : W (k + 1) = 2 ^ W k * W k := rfl

@[simp] theorem W_one : W 1 = 2 := rfl

@[simp] theorem W_two : W 2 = 8 := rfl

theorem W_pos (k : ℕ) : 0 < W k := by
  induction k with
  | zero => simp
  | succ k ih => exact Nat.mul_pos (Nat.two_pow_pos _) ih

/-- The exponent sum `sumW k = ∑_{i<k} W i`; it is exactly `log₂ (W k)`. -/
def sumW (k : ℕ) : ℕ := ∑ i ∈ range k, W i

@[simp] theorem sumW_zero : sumW 0 = 0 := by simp [sumW]

theorem sumW_succ (k : ℕ) : sumW (k + 1) = sumW k + W k := by
  simp [sumW, Finset.sum_range_succ]

/-- **`W k` is a power of two**, with exponent the sum of the previous weights. -/
theorem W_eq_two_pow_sumW (k : ℕ) : W k = 2 ^ sumW k := by
  induction k with
  | zero => simp
  | succ k ih =>
      rw [W_succ, sumW_succ, pow_add, ih, mul_comm]

theorem one_le_W (k : ℕ) : 1 ≤ W k := W_pos k

theorem W_lt_W_succ (k : ℕ) : W k < W (k + 1) := by
  have h1 : 2 ≤ 2 ^ W k := by
    calc (2:ℕ) = 2 ^ 1 := (pow_one 2).symm
    _ ≤ 2 ^ W k := Nat.pow_le_pow_right (by norm_num) (one_le_W k)
  calc W k = 1 * W k := (one_mul _).symm
  _ < 2 * W k := by
        exact Nat.mul_lt_mul_of_lt_of_le (by norm_num) le_rfl (W_pos k)
  _ ≤ 2 ^ W k * W k := Nat.mul_le_mul_right _ h1
  _ = W (k + 1) := (W_succ k).symm

theorem W_strictMono : StrictMono W := strictMono_nat_of_lt_succ W_lt_W_succ

theorem W_mono : Monotone W := W_strictMono.monotone

theorem self_lt_W (k : ℕ) : k < W k := by
  induction k with
  | zero => simp
  | succ k ih => exact lt_of_le_of_lt ih (W_lt_W_succ k)

theorem exists_lt_W (n : ℕ) : ∃ k, n < W k := ⟨n, self_lt_W n⟩

/-! ## The position function `K` -/

/-- `K n` is the least `k` with `n < W k`. -/
def K (n : ℕ) : ℕ := Nat.find (⟨n, self_lt_W n⟩ : ∃ k, n < W k)

theorem lt_W_K (n : ℕ) : n < W (K n) := Nat.find_spec (⟨n, self_lt_W n⟩ : ∃ k, n < W k)

theorem K_le_of_lt {n k : ℕ} (h : n < W k) : K n ≤ k :=
  Nat.find_le h

theorem le_of_lt_K {n k : ℕ} (h : k < K n) : W k ≤ n := by
  by_contra hc
  exact absurd (K_le_of_lt (Nat.lt_of_not_le hc)) (not_le.mpr h)

theorem K_mono : Monotone K := fun _ n hmn =>
  K_le_of_lt (lt_of_le_of_lt hmn (lt_W_K n))

@[simp] theorem K_zero : K 0 = 0 := Nat.le_zero.mp (K_le_of_lt (by simp))

@[simp] theorem K_one : K 1 = 1 := by
  have h1 : K 1 ≤ 1 := K_le_of_lt (by simp)
  have h2 : K 1 ≠ 0 := by
    intro h
    have := lt_W_K 1
    rw [h] at this
    simp at this
  omega

@[simp] theorem K_two : K 2 = 2 := by
  have h1 : K 2 ≤ 2 := K_le_of_lt (by simp)
  have h2 : ¬ (K 2 ≤ 1) := by
    intro h
    have := lt_W_K 2
    have := W_mono h
    simp at this
    omega
  omega

/-- Characterisation of `K`: `K n = k+1` exactly when `W k ≤ n < W (k+1)`. -/
theorem K_eq_succ_iff {n k : ℕ} : K n = k + 1 ↔ (W k ≤ n ∧ n < W (k + 1)) := by
  constructor
  · intro h
    refine ⟨le_of_lt_K (by omega), by rw [← h]; exact lt_W_K n⟩
  · rintro ⟨h1, h2⟩
    have hle : K n ≤ k + 1 := K_le_of_lt h2
    have : ¬ K n ≤ k := by
      intro hk
      exact absurd (lt_of_lt_of_le (lt_W_K n) (W_mono hk)) (not_lt.mpr h1)
    omega


/-! ## The tower radix expansion

The recursion `W (i+1) = 2 ^ (W i) * W i` says that the radix used at position `i` is
`2 ^ W i`.  We show that every `n < W k` has a unique expansion
`n = ∑_{i<k} d i * W i` with digits `d i < 2 ^ W i`.
-/

/-- The radix used at position `i` of a tower representation. -/
def radix (i : ℕ) : ℕ := 2 ^ W i

theorem W_succ_eq_radix_mul (i : ℕ) : W (i + 1) = radix i * W i := rfl

theorem W_dvd_W {i k : ℕ} (h : i ≤ k) : W i ∣ W k := by
  induction k with
  | zero => simp_all
  | succ k ih =>
      rcases Nat.lt_or_ge i (k + 1) with h' | h'
      · exact dvd_trans (ih (by omega)) ⟨2 ^ W k, by rw [W_succ]; ring⟩
      · have : i = k + 1 := by omega
        simp [this]

/-- The `i`-th digit of `n` in the tower radix system. -/
def towerDigit (i n : ℕ) : ℕ := (n % W (i + 1)) / W i

theorem towerDigit_lt (i n : ℕ) : towerDigit i n < radix i := by
  have h := Nat.mod_lt n (W_pos (i + 1))
  rw [towerDigit, Nat.div_lt_iff_lt_mul (W_pos i)]
  simpa [W_succ_eq_radix_mul] using h

theorem towerDigit_mod {i k n : ℕ} (h : i < k) :
    towerDigit i (n % W k) = towerDigit i n := by
  have hdvd : W (i + 1) ∣ W k := W_dvd_W (by omega)
  rw [towerDigit, towerDigit, Nat.mod_mod_of_dvd n hdvd]

theorem towerDigit_top {k n : ℕ} (h : n < W (k + 1)) : towerDigit k n = n / W k := by
  rw [towerDigit, Nat.mod_eq_of_lt h]

/-- Any family of admissible digits produces a value below `W k`. -/
theorem sum_digits_lt {k : ℕ} (d : ℕ → ℕ) (hd : ∀ i < k, d i < radix i) :
    ∑ i ∈ range k, d i * W i < W k := by
  induction k with
  | zero => simp
  | succ k ih =>
      rw [Finset.sum_range_succ, W_succ_eq_radix_mul]
      have h1 : ∑ i ∈ range k, d i * W i < W k := ih (fun i hi => hd i (by omega))
      have h2 : d k + 1 ≤ radix k := hd k (by omega)
      have h3 : (d k + 1) * W k ≤ radix k * W k := Nat.mul_le_mul_right _ h2
      have h4 : (d k + 1) * W k = d k * W k + W k := by ring
      omega

/-- **Existence**: the tower digits of `n` reconstruct `n`, for every `n < W k`. -/
theorem towerDigit_sum {k n : ℕ} (h : n < W k) :
    ∑ i ∈ range k, towerDigit i n * W i = n := by
  induction k generalizing n with
  | zero =>
      have : n = 0 := by simpa using Nat.lt_one_iff.mp (by simpa using h)
      simp [this]
  | succ k ih =>
      rw [Finset.sum_range_succ]
      have hmod : n % W k < W k := Nat.mod_lt _ (W_pos k)
      have h1 : ∑ i ∈ range k, towerDigit i n * W i = n % W k := by
        rw [← ih hmod]
        exact Finset.sum_congr rfl fun i hi => by
          rw [towerDigit_mod (Finset.mem_range.mp hi)]
      rw [h1, towerDigit_top h]
      exact Nat.mod_add_div' n (W k)

/-- **Uniqueness**: any admissible digit family representing `n` consists of the tower
digits of `n`. -/
theorem towerDigit_eq_of_repr {k n : ℕ} (d : ℕ → ℕ) (hd : ∀ i < k, d i < radix i)
    (hn : n = ∑ i ∈ range k, d i * W i) : ∀ i < k, d i = towerDigit i n := by
  induction k generalizing n with
  | zero => intro i hi; omega
  | succ k ih =>
      rw [Finset.sum_range_succ] at hn
      set S := ∑ i ∈ range k, d i * W i with hS
      have hSlt : S < W k := sum_digits_lt d (fun i hi => hd i (by omega))
      have hdk : d k + 1 ≤ radix k := hd k (by omega)
      have hnlt : n < W (k + 1) := by
        rw [W_succ_eq_radix_mul, hn]
        have h3 : (d k + 1) * W k ≤ radix k * W k := Nat.mul_le_mul_right _ hdk
        have h4 : (d k + 1) * W k = d k * W k + W k := by ring
        omega
      have hdiv : n / W k = d k := by
        rw [hn, Nat.add_mul_div_right _ _ (W_pos k), Nat.div_eq_of_lt hSlt, Nat.zero_add]
      have hmod : n % W k = S := by
        rw [hn, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hSlt]
      intro i hi
      rcases Nat.lt_or_ge i k with hik | hik
      · have h5 := ih (n := S) (fun j hj => hd j (by omega)) hS i hik
        rw [h5, ← hmod, towerDigit_mod hik]
      · have hik' : i = k := by omega
        subst hik'
        rw [towerDigit_top hnlt, hdiv]

/-- Two admissible digit families representing the same number agree. -/
theorem towerDigit_unique {k : ℕ} (d e : ℕ → ℕ) (hd : ∀ i < k, d i < radix i)
    (he : ∀ i < k, e i < radix i)
    (h : ∑ i ∈ range k, d i * W i = ∑ i ∈ range k, e i * W i) : ∀ i < k, d i = e i := by
  intro i hi
  rw [towerDigit_eq_of_repr d hd rfl i hi, towerDigit_eq_of_repr e he h i hi]


/-! ## Binary encodings: no worst-case compression, and attainment of the bound

We show that any injective binary encoding of the `W k` numbers `n < W k` (equivalently, of
the valid length-`k` tower representations) must use a codeword of length at least
`sumW k = log₂ (W k)`, and that this is attained.
-/

/-- An injective arithmetisation of binary strings: `code [] = 1`,
`code (b :: t) = 2 * code t + b`. -/
def code : List Bool → ℕ
  | [] => 1
  | b :: t => 2 * code t + (if b then 1 else 0)

theorem code_pos (l : List Bool) : 0 < code l := by
  induction l with
  | nil => simp [code]
  | cons b t ih => simp only [code]; omega

theorem code_lt (l : List Bool) : code l < 2 ^ (l.length + 1) := by
  induction l with
  | nil => simp [code]
  | cons b t ih =>
      have : (2:ℕ) ^ (t.length + 1 + 1) = 2 * 2 ^ (t.length + 1) := by ring
      simp only [code, List.length_cons]
      split <;> omega

theorem code_injective : Function.Injective code := by
  intro l₁
  induction l₁ with
  | nil =>
      intro l₂ h
      cases l₂ with
      | nil => rfl
      | cons b t =>
          exfalso
          have := code_pos t
          simp only [code] at h
          split at h <;> omega
  | cons b t ih =>
      intro l₂ h
      cases l₂ with
      | nil =>
          exfalso
          have := code_pos t
          simp only [code] at h
          split at h <;> omega
      | cons b' t' =>
          simp only [code] at h
          have hb : b = b' := by
            by_contra hne
            have : b' = !b := by cases b <;> cases b' <;> simp_all
            subst this
            cases b <;> simp at h <;> omega
          subst hb
          have : code t = code t' := by cases b <;> simp at h <;> omega
          rw [ih this]

/-- Pigeonhole: an injective binary encoding of a finite set of numbers using codewords of
length at most `m` can cover fewer than `2 ^ (m+1)` values. -/
theorem card_lt_two_pow_of_injOn {S : Finset ℕ} {f : ℕ → List Bool}
    (hinj : Set.InjOn f (S : Set ℕ)) {m : ℕ} (hlen : ∀ n ∈ S, (f n).length ≤ m) :
    S.card < 2 ^ (m + 1) := by
  have hmaps : Set.MapsTo (fun n => code (f n)) (S : Set ℕ) (Finset.Ico 1 (2 ^ (m + 1))) := by
    intro n hn
    simp only [Finset.coe_Ico, Set.mem_Ico]
    refine ⟨code_pos _, lt_of_lt_of_le (code_lt (f n)) ?_⟩
    exact Nat.pow_le_pow_right (by norm_num) (by have := hlen n (by simpa using hn); omega)
  have hinj' : Set.InjOn (fun n => code (f n)) (S : Set ℕ) :=
    fun a ha b hb h => hinj ha hb (code_injective h)
  have hcard := Finset.card_le_card_of_injOn _ hmaps hinj'
  have hIco : (Finset.Ico 1 (2 ^ (m + 1))).card = 2 ^ (m + 1) - 1 := by
    simp
  have hpos : 0 < 2 ^ (m + 1) := Nat.two_pow_pos _
  omega

/-- **No worst-case binary compression.** For any encoding `f` of the numbers below `W k`
that is injective on `[0, W k)` (in particular, for any injective prefix-free code of the
valid length-`k` tower representations), some codeword has length at least
`sumW k = log₂ (W k)`. -/
theorem no_binary_compression (k : ℕ) (f : ℕ → List Bool)
    (hinj : Set.InjOn f (Set.Iio (W k))) :
    ∃ n < W k, sumW k ≤ (f n).length := by
  by_contra hcon
  push_neg at hcon
  rcases Nat.eq_zero_or_pos (sumW k) with h0 | h0
  · exact absurd (hcon 0 (W_pos k)) (by omega)
  have hS : Set.InjOn f ((Finset.range (W k) : Finset ℕ) : Set ℕ) := by
    intro a ha b hb hab
    exact hinj (by simpa using ha) (by simpa using hb) hab
  have hlen : ∀ n ∈ Finset.range (W k), (f n).length ≤ sumW k - 1 := by
    intro n hn
    have := hcon n (Finset.mem_range.mp hn)
    omega
  have := card_lt_two_pow_of_injOn hS hlen
  rw [Finset.card_range] at this
  have hEq : sumW k - 1 + 1 = sumW k := by omega
  rw [hEq, ← W_eq_two_pow_sumW] at this
  exact absurd this (lt_irrefl _)

/-- The tower digits of `n < W k` vanish in positions `≥ k`. -/
theorem towerDigit_eq_zero_of_le {i k n : ℕ} (hk : k ≤ i) (hn : n < W k) :
    towerDigit i n = 0 := by
  have h1 : n < W i := lt_of_lt_of_le hn (W_mono hk)
  have h2 : n < W (i + 1) := lt_trans h1 (W_lt_W_succ i)
  rw [towerDigit_top h2, Nat.div_eq_of_lt h1]

/-- **No compression, digit form.** Any encoding of the admissible length-`k` digit
families that is injective on them has a codeword of length at least `sumW k`. -/
theorem no_binary_compression_digits (k : ℕ) (f : (ℕ → ℕ) → List Bool)
    (hinj : Set.InjOn f {d | (∀ i < k, d i < radix i) ∧ ∀ i, k ≤ i → d i = 0}) :
    ∃ d ∈ {d | (∀ i < k, d i < radix i) ∧ ∀ i, k ≤ i → d i = 0}, sumW k ≤ (f d).length := by
  set D : Set (ℕ → ℕ) := {d | (∀ i < k, d i < radix i) ∧ ∀ i, k ≤ i → d i = 0} with hD
  have hmem : ∀ n < W k, (fun i => towerDigit i n) ∈ D :=
    fun n hn => ⟨fun i _ => towerDigit_lt i n, fun i hi => towerDigit_eq_zero_of_le hi hn⟩
  have hginj : Set.InjOn (fun n => f (fun i => towerDigit i n)) (Set.Iio (W k)) := by
    intro a ha b hb hab
    have h := hinj (hmem a ha) (hmem b hb) hab
    have : ∀ i, towerDigit i a = towerDigit i b := fun i => congrFun h i
    calc a = ∑ i ∈ range k, towerDigit i a * W i := (towerDigit_sum ha).symm
    _ = ∑ i ∈ range k, towerDigit i b * W i := by
          exact Finset.sum_congr rfl fun i _ => by rw [this i]
    _ = b := towerDigit_sum hb
  obtain ⟨n, hn, hlen⟩ := no_binary_compression k _ hginj
  exact ⟨_, hmem n hn, hlen⟩

/-! ### Injective codes on a general interval `[0, n]`

For a general interval the sharp statement is slightly weaker than `⌈log₂ (n+1)⌉`: an
injective (not necessarily prefix-free) code can save one bit, and does so for `n = 2`.
-/

/-- Any injective binary encoding of `[0, n]` has a codeword of length at least
`⌈log₂ (n+2)⌉ - 1`. -/
theorem exists_codeword_length_ge {n : ℕ} (f : ℕ → List Bool)
    (hinj : Set.InjOn f (Set.Iic n)) :
    ∃ m ≤ n, Nat.clog 2 (n + 2) ≤ (f m).length + 1 := by
  rcases Nat.lt_or_ge (Nat.clog 2 (n + 2)) 2 with hsmall | hL2
  · exact ⟨0, Nat.zero_le _, by omega⟩
  by_contra hcon
  push_neg at hcon
  set L := Nat.clog 2 (n + 2) with hL
  have hS : Set.InjOn f ((Finset.range (n + 1) : Finset ℕ) : Set ℕ) := by
    intro a ha b hb hab
    exact hinj (by simp only [Finset.coe_range, Set.mem_Iio] at ha; simpa using Nat.lt_succ_iff.mp ha)
      (by simp only [Finset.coe_range, Set.mem_Iio] at hb; simpa using Nat.lt_succ_iff.mp hb) hab
  have hlen : ∀ m ∈ Finset.range (n + 1), (f m).length ≤ L - 2 := by
    intro m hm
    have := hcon m (Nat.lt_succ_iff.mp (Finset.mem_range.mp hm))
    omega
  have hcard := card_lt_two_pow_of_injOn hS hlen
  rw [Finset.card_range] at hcard
  have hlow : 2 ^ (L - 1) < n + 2 := by
    have := Nat.pow_pred_clog_lt_self (b := 2) (by norm_num) (x := n + 2) (by omega)
    simpa [hL, Nat.pred_eq_sub_one] using this
  have hmono : (2:ℕ) ^ (L - 2 + 1) ≤ 2 ^ (L - 1) :=
    Nat.pow_le_pow_right (by norm_num) (by omega)
  omega

/-- The bound of `exists_codeword_length_ge` cannot be improved to `⌈log₂ (n+1)⌉` for
injective codes: the three values `0, 1, 2` admit an injective code with all codewords of
length at most `1`, while `⌈log₂ 3⌉ = 2`. -/
theorem injective_code_can_beat_clog :
    ∃ f : ℕ → List Bool, Set.InjOn f (Set.Iic 2) ∧
      (∀ m ≤ 2, (f m).length + 1 ≤ Nat.clog 2 (2 + 1)) := by
  refine ⟨fun m => if m = 0 then [] else if m = 1 then [true] else [false], ?_, ?_⟩
  · intro a ha b hb hab
    simp only [Set.mem_Iic] at ha hb
    interval_cases a <;> interval_cases b <;> simp_all
  · intro m _
    have : Nat.clog 2 3 = 2 := by decide
    rcases Nat.lt_or_ge m 1 with h | h
    · simp [show m = 0 by omega, this]
    · rcases Nat.lt_or_ge m 2 with h' | h'
      · simp [show m = 1 by omega, this]
      · simp [show m ≠ 0 by omega, show m ≠ 1 by omega, this]

/-! ### The bound is attained by fixed-width digit blocks -/

/-- The little-endian `L`-bit binary expansion of `n`. -/
def padBits (L n : ℕ) : List Bool := (List.range L).map (fun i => n.testBit i)

@[simp] theorem padBits_length (L n : ℕ) : (padBits L n).length = L := by
  simp [padBits]

theorem padBits_injOn {L m n : ℕ} (hm : m < 2 ^ L) (hn : n < 2 ^ L)
    (h : padBits L m = padBits L n) : m = n := by
  refine Nat.eq_of_testBit_eq fun i => ?_
  rcases Nat.lt_or_ge i L with hi | hi
  · rw [padBits, padBits, List.map_eq_map_iff] at h
    exact h i (List.mem_range.mpr hi)
  · have h2 : (2:ℕ) ^ L ≤ 2 ^ i := Nat.pow_le_pow_right (by norm_num) hi
    rw [Nat.testBit_lt_two_pow (lt_of_lt_of_le hm h2),
      Nat.testBit_lt_two_pow (lt_of_lt_of_le hn h2)]

/-- The tower block code: the digit at position `i` written in exactly `W i` bits, for
`i = 0, …, k-1`, concatenated. -/
def blockCode : ℕ → ℕ → List Bool
  | 0, _ => []
  | k + 1, n => blockCode k n ++ padBits (W k) (towerDigit k n)

@[simp] theorem blockCode_length (k n : ℕ) : (blockCode k n).length = sumW k := by
  induction k with
  | zero => simp [blockCode]
  | succ k ih => simp [blockCode, ih, sumW_succ]

theorem blockCode_mod (k : ℕ) : ∀ n, blockCode k (n % W k) = blockCode k n := by
  induction k with
  | zero => simp [blockCode]
  | succ k ih =>
      intro n
      have hdvd : W k ∣ W (k + 1) := W_dvd_W (Nat.le_succ k)
      have hmm : (n % W (k + 1)) % W k = n % W k := Nat.mod_mod_of_dvd n hdvd
      simp only [blockCode]
      congr 1
      · calc blockCode k (n % W (k + 1))
            = blockCode k ((n % W (k + 1)) % W k) := (ih _).symm
        _ = blockCode k (n % W k) := by rw [hmm]
        _ = blockCode k n := ih n
      · rw [towerDigit_mod (Nat.lt_succ_self k)]

/-- The block code is injective on `[0, W k)`: it is a genuine encoding. -/
theorem blockCode_injOn {k m n : ℕ} (hm : m < W k) (hn : n < W k)
    (h : blockCode k m = blockCode k n) : m = n := by
  induction k generalizing m n with
  | zero => simp only [W_zero] at hm hn; omega
  | succ k ih =>
      simp only [blockCode] at h
      obtain ⟨h1, h2⟩ := List.append_inj h (by simp)
      have hd : towerDigit k m = towerDigit k n :=
        padBits_injOn (by simpa [radix] using towerDigit_lt k m)
          (by simpa [radix] using towerDigit_lt k n) h2
      have hq : m / W k = n / W k := by
        rw [← towerDigit_top hm, ← towerDigit_top hn]; exact hd
      have hr : m % W k = n % W k := by
        refine ih (Nat.mod_lt _ (W_pos k)) (Nat.mod_lt _ (W_pos k)) ?_
        rw [blockCode_mod, blockCode_mod]
        exact h1
      calc m = W k * (m / W k) + m % W k := (Nat.div_add_mod m (W k)).symm
      _ = W k * (n / W k) + n % W k := by rw [hq, hr]
      _ = n := Nat.div_add_mod n (W k)

/-- **Attainment**: the fixed-width digit-block code is an injective binary encoding of all
`n < W k` whose codewords all have length exactly `sumW k = log₂ (W k)`, matching the lower
bound of `no_binary_compression`. -/
theorem blockCode_optimal (k : ℕ) :
    (∀ n, (blockCode k n).length = sumW k) ∧ Set.InjOn (blockCode k) (Set.Iio (W k)) :=
  ⟨fun n => blockCode_length k n, fun _ hm _ hn h => blockCode_injOn hm hn h⟩


/-! ## Comparison with the iterated binary logarithm

Let `clg n = ⌈log₂ (n+1)⌉` and let `L2 n` be the least number of iterations of `clg`
needed to bring `n` down to a value `≤ 2`.  We prove `|K n - L2 n| ≤ 2`.
-/

/-- `clg n = ⌈log₂ (n+1)⌉`. -/
def clg (n : ℕ) : ℕ := Nat.clog 2 (n + 1)

theorem succ_le_two_pow_clg (n : ℕ) : n + 1 ≤ 2 ^ clg n :=
  (Nat.clog_le_iff_le_pow (by norm_num)).mp le_rfl

theorem clg_le_of_le_two_pow {n m : ℕ} (h : n + 1 ≤ 2 ^ m) : clg n ≤ m :=
  (Nat.clog_le_iff_le_pow (by norm_num)).mpr h

theorem clg_mono : Monotone clg := fun _ _ h => Nat.clog_mono_right 2 (by omega)

theorem succ_le_two_pow_pred {n : ℕ} (h : 3 ≤ n) : n + 1 ≤ 2 ^ (n - 1) := by
  induction n with
  | zero => omega
  | succ m ih =>
      rcases Nat.lt_or_ge m 3 with hm | hm
      · interval_cases m <;> simp_all
      · have h1 := ih (by omega)
        have h2 : (2:ℕ) ^ (m + 1 - 1) = 2 * 2 ^ (m - 1) := by
          have h3 : m + 1 - 1 = (m - 1) + 1 := by omega
          rw [h3]; ring
        omega

theorem clg_lt {n : ℕ} (h : 3 ≤ n) : clg n < n := by
  have := clg_le_of_le_two_pow (succ_le_two_pow_pred h)
  omega

/-- `L2 n` = number of iterations of `clg` needed to reach a value `≤ 2`. -/
def L2 (n : ℕ) : ℕ := if n ≤ 2 then 0 else L2 (clg n) + 1
decreasing_by exact clg_lt (by omega)

theorem L2_of_le_two {n : ℕ} (h : n ≤ 2) : L2 n = 0 := by rw [L2]; simp [h]

theorem L2_of_three_le {n : ℕ} (h : 3 ≤ n) : L2 n = L2 (clg n) + 1 := by
  rw [L2]; simp [Nat.not_le.mpr (by omega : 2 < n)]

theorem L2_mono : Monotone L2 := by
  intro m n hmn
  induction n using Nat.strong_induction_on generalizing m with
  | _ n ih =>
      rcases Nat.lt_or_ge n 3 with hn | hn
      · rw [L2_of_le_two (show m ≤ 2 by omega)]
        exact Nat.zero_le _
      rcases Nat.lt_or_ge m 3 with hm | hm
      · rw [L2_of_le_two (show m ≤ 2 by omega)]
        exact Nat.zero_le _
      rw [L2_of_three_le hn, L2_of_three_le hm]
      have := ih (clg n) (clg_lt hn) (clg_mono hmn)
      omega

/-! ### `K` is at most `L2 + 2` -/

/-- One `clg`-step costs at most one tower level. -/
theorem K_le_K_clg_succ (n : ℕ) : K n ≤ K (clg n) + 1 := by
  refine K_le_of_lt ?_
  set k := K (clg n) with hk
  have h1 : clg n < W k := lt_W_K (clg n)
  have h2 : n + 1 ≤ 2 ^ clg n := succ_le_two_pow_clg n
  have h3 : (2:ℕ) ^ clg n ≤ 2 ^ W k := Nat.pow_le_pow_right (by norm_num) (le_of_lt h1)
  have h4 : (2:ℕ) ^ W k ≤ 2 ^ W k * W k := Nat.le_mul_of_pos_right _ (W_pos k)
  rw [W_succ]
  omega

/-- **Upper half of conjecture 1**: `K n ≤ L2 n + 2`. -/
theorem K_le_L2_add_two (n : ℕ) : K n ≤ L2 n + 2 := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
      rcases Nat.lt_or_ge n 3 with hn | hn
      · have : K n ≤ K 2 := K_mono (by omega)
        simp only [K_two] at this
        omega
      · have h1 := K_le_K_clg_succ n
        have h2 := ih (clg n) (clg_lt hn)
        rw [L2_of_three_le hn]
        omega

/-! ### `L2` is at most `K + 1` -/

theorem sumW_mono : Monotone sumW := by
  intro a b hab
  have hsub : range a ⊆ range b := fun x hx =>
    Finset.mem_range.mpr (lt_of_lt_of_le (Finset.mem_range.mp hx) hab)
  exact Finset.sum_le_sum_of_subset hsub

theorem three_le_sumW {k : ℕ} (h : 2 ≤ k) : 3 ≤ sumW k := by
  have : sumW 2 ≤ sumW k := sumW_mono h
  simpa [sumW, Finset.sum_range_succ] using this

theorem L2_le_two_of_le_six {m : ℕ} (h : m ≤ 6) : L2 m ≤ 2 := by
  have h3 : L2 3 ≤ 1 := by
    rw [L2_of_three_le (by norm_num)]
    have : clg 3 ≤ 2 := clg_le_of_le_two_pow (by norm_num)
    rw [L2_of_le_two this]
  rcases Nat.lt_or_ge m 3 with hm | hm
  · rw [L2_of_le_two (by omega)]; omega
  · rw [L2_of_three_le hm]
    have hc : clg m ≤ 3 := clg_le_of_le_two_pow (by omega)
    have := L2_mono hc
    omega

/-- The key quantitative step: everything up to `2 * sumW k` is killed in `k` steps. -/
theorem L2_le_of_le_two_sumW : ∀ {k : ℕ}, 2 ≤ k → ∀ m ≤ 2 * sumW k, L2 m ≤ k := by
  intro k
  induction k with
  | zero => omega
  | succ k ih =>
      intro hk m hm
      rcases Nat.lt_or_ge k 2 with hk2 | hk2
      · -- then `k + 1 = 2`, i.e. `2 * sumW 2 = 6`
        have hk' : k = 1 := by omega
        subst hk'
        have h6 : 2 * sumW (1 + 1) = 6 := by simp [sumW, Finset.sum_range_succ]
        exact L2_le_two_of_le_six (by omega)
      · rcases Nat.lt_or_ge m 3 with hm3 | hm3
        · rw [L2_of_le_two (by omega)]; omega
        rw [L2_of_three_le hm3]
        have hsum : 3 ≤ sumW k := three_le_sumW hk2
        have hlt : sumW k < 2 ^ sumW k := Nat.lt_two_pow_self
        have hW : W k = 2 ^ sumW k := W_eq_two_pow_sumW k
        have hmle : m + 1 ≤ 2 ^ (sumW k + 2) := by
          have hpow : (2:ℕ) ^ (sumW k + 2) = 4 * 2 ^ sumW k := by ring
          have : 2 * sumW (k + 1) = 2 * sumW k + 2 * 2 ^ sumW k := by
            rw [sumW_succ, hW]; ring
          omega
        have hc : clg m ≤ sumW k + 2 := clg_le_of_le_two_pow hmle
        have := L2_mono (le_trans hc (by omega : sumW k + 2 ≤ 2 * sumW k))
        have := ih hk2 (2 * sumW k) le_rfl
        omega

/-- **Lower half of conjecture 1**: `L2 n ≤ K n + 1`. -/
theorem L2_le_K_add_one (n : ℕ) : L2 n ≤ K n + 1 := by
  set k := K n with hk
  have hn : n < W k := lt_W_K n
  rcases Nat.lt_or_ge k 2 with hk2 | hk2
  · have : W k ≤ W 1 := W_mono (by omega)
    simp only [W_one] at this
    rw [L2_of_le_two (by omega)]
    omega
  · rcases Nat.lt_or_ge n 3 with hn3 | hn3
    · rw [L2_of_le_two (by omega)]; omega
    rw [L2_of_three_le hn3]
    have hW : W k = 2 ^ sumW k := W_eq_two_pow_sumW k
    have hc : clg n ≤ sumW k := clg_le_of_le_two_pow (by omega)
    have hs : 3 ≤ sumW k := three_le_sumW hk2
    have h1 := L2_mono (le_trans hc (by omega : sumW k ≤ 2 * sumW k))
    have h2 := L2_le_of_le_two_sumW hk2 (2 * sumW k) le_rfl
    omega

/-- **Conjecture 1 (iterated-log position bound)**: the tower position `K n` and the
iterated-logarithm depth `L2 n` differ by at most `2`, for every `n`. -/
theorem abs_K_sub_L2_le_two (n : ℕ) : |(K n : ℤ) - (L2 n : ℤ)| ≤ 2 := by
  have h1 := K_le_L2_add_two n
  have h2 := L2_le_K_add_one n
  rw [abs_le]
  constructor <;> omega


/-! ## Comparison with the Zeckendorf representation

`Zidx n` is the largest Fibonacci index `m` with `fib m ≤ n`; this is exactly the largest
index occurring in the canonical Zeckendorf expansion of `n` (the greedy algorithm starts
by subtracting the largest Fibonacci number `≤ n`).  We show

* `Zidx` is squeezed between `log₂ n + 1` and `2 * log₂ n + 3`, and
* `K` is `o (Zidx)`: for every `c` we have `c * K n ≤ Zidx n` for all large `n`.
-/

theorem exists_lt_fib (n : ℕ) : ∃ m, n < Nat.fib m :=
  ⟨n + 5, lt_of_lt_of_le (by omega) (Nat.le_fib_self (by omega))⟩

/-- The largest Fibonacci index `m` with `fib m ≤ n`. -/
def Zidx (n : ℕ) : ℕ := Nat.find (exists_lt_fib n) - 1

theorem one_le_find_fib (n : ℕ) : 1 ≤ Nat.find (exists_lt_fib n) := by
  rcases Nat.eq_zero_or_pos (Nat.find (exists_lt_fib n)) with h | h
  · have := Nat.find_spec (exists_lt_fib n)
    rw [h] at this
    simp at this
  · exact h

theorem fib_Zidx_le (n : ℕ) : Nat.fib (Zidx n) ≤ n := by
  have h1 := one_le_find_fib n
  have h2 : Zidx n = Nat.find (exists_lt_fib n) - 1 := rfl
  have h3 := Nat.find_min (exists_lt_fib n) (m := Zidx n) (by omega)
  omega

theorem lt_fib_Zidx_succ (n : ℕ) : n < Nat.fib (Zidx n + 1) := by
  have h1 := one_le_find_fib n
  have h2 : Zidx n + 1 = Nat.find (exists_lt_fib n) := by
    simp only [Zidx]; omega
  rw [h2]
  exact Nat.find_spec (exists_lt_fib n)

theorem fib_succ_le_two_pow (m : ℕ) : Nat.fib (m + 1) ≤ 2 ^ m := by
  induction m using Nat.strong_induction_on with
  | _ m ih =>
      match m with
      | 0 => simp
      | 1 => simp [Nat.fib_add_two]
      | (j + 2) =>
          show Nat.fib (j + 3) ≤ 2 ^ (j + 2)
          have h1 : Nat.fib (j + 1) ≤ 2 ^ j := ih j (by omega)
          have h2 : Nat.fib (j + 2) ≤ 2 ^ (j + 1) := ih (j + 1) (by omega)
          have h3 : Nat.fib (j + 3) = Nat.fib (j + 1) + Nat.fib (j + 2) := Nat.fib_add_two
          have h4 : (2:ℕ) ^ (j + 2) = 4 * 2 ^ j := by ring
          have h5 : (2:ℕ) ^ (j + 1) = 2 * 2 ^ j := by ring
          omega

theorem two_pow_le_fib (m : ℕ) : 2 ^ m ≤ Nat.fib (2 * m + 2) := by
  induction m with
  | zero => simp
  | succ m ih =>
      have h1 : Nat.fib (2 * m + 4) = Nat.fib (2 * m + 2) + Nat.fib (2 * m + 3) :=
        Nat.fib_add_two
      have h2 : Nat.fib (2 * m + 2) ≤ Nat.fib (2 * m + 3) := Nat.fib_le_fib_succ
      have h3 : 2 * (m + 1) + 2 = 2 * m + 4 := by ring
      have h4 : (2:ℕ) ^ (m + 1) = 2 ^ m + 2 ^ m := by ring
      rw [h3]
      omega

/-- **Lower Zeckendorf bound**: `log₂ n + 1 ≤ Zidx n`. -/
theorem log_add_one_le_Zidx {n : ℕ} (hn : 1 ≤ n) : Nat.log 2 n + 1 ≤ Zidx n := by
  have h1 : n < 2 ^ Zidx n := lt_of_lt_of_le (lt_fib_Zidx_succ n) (fib_succ_le_two_pow _)
  have := Nat.log_lt_of_lt_pow (b := 2) (by omega) h1
  omega

/-- **Upper Zeckendorf bound**: `Zidx n ≤ 2 * log₂ n + 3`. -/
theorem Zidx_le_two_log_add_three {n : ℕ} (hn : 1 ≤ n) : Zidx n ≤ 2 * Nat.log 2 n + 3 := by
  by_contra hcon
  push_neg at hcon
  set L := Nat.log 2 n with hL
  have h1 : 2 * (L + 1) + 2 ≤ Zidx n := by omega
  have h2 : Nat.fib (2 * (L + 1) + 2) ≤ Nat.fib (Zidx n) := Nat.fib_mono h1
  have h3 : 2 ^ (L + 1) ≤ Nat.fib (2 * (L + 1) + 2) := two_pow_le_fib (L + 1)
  have h4 : Nat.fib (Zidx n) ≤ n := fib_Zidx_le n
  have h5 : 2 ^ (L + 1) ≤ n := by omega
  have h6 : L + 1 ≤ Nat.log 2 n := (Nat.le_log_iff_pow_le (by norm_num) (by omega)).mpr h5
  omega

/-- **Zeckendorf indices are logarithmic**: for `n ≥ 1`,
`log₂ n + 1 ≤ Zidx n ≤ 2 * log₂ n + 3`. -/
theorem Zidx_bounds {n : ℕ} (hn : 1 ≤ n) :
    Nat.log 2 n + 1 ≤ Zidx n ∧ Zidx n ≤ 2 * Nat.log 2 n + 3 :=
  ⟨log_add_one_le_Zidx hn, Zidx_le_two_log_add_three hn⟩

/-! ### `K` grows slower than `Zidx` -/

theorem two_pow_le_W (k : ℕ) : 2 ^ k ≤ W k := by
  induction k with
  | zero => simp
  | succ k ih =>
      have h1 : k + 1 ≤ W k := self_lt_W k
      have h2 : (2:ℕ) ^ (k + 1) ≤ 2 ^ W k := Nat.pow_le_pow_right (by norm_num) h1
      have h3 : (2:ℕ) ^ W k ≤ 2 ^ W k * W k := Nat.le_mul_of_pos_right _ (W_pos k)
      rw [W_succ]
      omega

theorem W_le_sumW_succ (k : ℕ) : W k ≤ sumW (k + 1) := by
  rw [sumW_succ]
  omega

theorem two_mul_add_four_le_two_pow (j : ℕ) : 2 * j + 4 ≤ 2 ^ (j + 2) := by
  induction j with
  | zero => norm_num
  | succ j ih =>
      show 2 * (j + 1) + 4 ≤ 2 ^ (j + 3)
      have h1 : (2:ℕ) ^ (j + 3) = 2 * 2 ^ (j + 2) := by ring
      omega

/-- A linear function of the level is dwarfed by the exponent sum `sumW`. -/
theorem linear_le_sumW {c j : ℕ} (hc : c ≤ j) : c * (j + 5) ≤ sumW (j + 4) := by
  have h1 : c ≤ 2 ^ c := Nat.le_of_lt Nat.lt_two_pow_self
  have h2 : j + 5 ≤ 2 ^ (j + 4) := by
    have : j + 4 < 2 ^ (j + 4) := Nat.lt_two_pow_self
    omega
  have h3 : c * (j + 5) ≤ 2 ^ c * 2 ^ (j + 4) := Nat.mul_le_mul h1 h2
  have h4 : (2:ℕ) ^ c * 2 ^ (j + 4) = 2 ^ (c + j + 4) := by rw [← pow_add]; ring_nf
  have h5 : c + j + 4 ≤ 2 ^ (j + 2) := by
    have := two_mul_add_four_le_two_pow j
    omega
  have h6 : (2:ℕ) ^ (c + j + 4) ≤ 2 ^ (2 ^ (j + 2)) := Nat.pow_le_pow_right (by norm_num) h5
  have h7 : (2:ℕ) ^ (2 ^ (j + 2)) ≤ 2 ^ W (j + 2) :=
    Nat.pow_le_pow_right (by norm_num) (two_pow_le_W (j + 2))
  have h8 : W (j + 2) ≤ sumW (j + 3) := W_le_sumW_succ (j + 2)
  have h9 : (2:ℕ) ^ W (j + 2) ≤ 2 ^ sumW (j + 3) := Nat.pow_le_pow_right (by norm_num) h8
  have h10 : (2:ℕ) ^ sumW (j + 3) = W (j + 3) := (W_eq_two_pow_sumW (j + 3)).symm
  have h11 : W (j + 3) ≤ sumW (j + 4) := W_le_sumW_succ (j + 3)
  omega

/-- **Conjecture 5, growth comparison**: `K n = o (Zidx n)`.  For every constant `c` we
have `c * K n ≤ Zidx n` for all sufficiently large `n`. -/
theorem K_littleO_Zidx (c : ℕ) : ∃ N, ∀ n ≥ N, c * K n ≤ Zidx n := by
  refine ⟨W (c + 4), fun n hn => ?_⟩
  have hn1 : 1 ≤ n := le_trans (W_pos (c + 4)) hn
  have hK : c + 4 < K n := by
    by_contra hc
    push_neg at hc
    have : n < W (c + 4) := lt_of_lt_of_le (lt_W_K n) (W_mono hc)
    omega
  obtain ⟨j, hj⟩ : ∃ j, K n = j + 5 := ⟨K n - 5, by omega⟩
  have hcj : c ≤ j := by omega
  have hWle : W (j + 4) ≤ n := le_of_lt_K (by omega)
  have hpow : 2 ^ sumW (j + 4) ≤ n := by
    rw [← W_eq_two_pow_sumW]
    exact hWle
  have hlog : sumW (j + 4) ≤ Nat.log 2 n :=
    (Nat.le_log_iff_pow_le (by norm_num) (by omega)).mpr hpow
  have hZ : Nat.log 2 n + 1 ≤ Zidx n := log_add_one_le_Zidx hn1
  have hlin : c * (j + 5) ≤ sumW (j + 4) := linear_le_sumW hcj
  rw [hj]
  omega


/-! ## A radix-growth threshold

Consider generalised weights `V 0 = 1`, `V (k+1) = r (V k) * V k`.

* If `r` is monotone and `r x ≥ 2 ^ x`, the weights grow at least as fast as the tower
  weights, so the position function inherits the `log*`-type bound
  `K_V n ≤ L2 n + 2` (`genPos_le_L2_add_two`).
* For polynomially growing radices this fails badly.  We exhibit the borderline case
  `r x = x`, i.e. the squaring recursion `V k = 2 ^ (2 ^ k)`, whose position function is
  *not* `O (L2 n)` (`squarePos_not_bigO_L2`).
-/

section GeneralWeights

variable (r : ℕ → ℕ)

/-- Generalised weights `V 0 = 1`, `V (k+1) = r (V k) * V k`. -/
def genW : ℕ → ℕ
  | 0 => 1
  | k + 1 => r (genW k) * genW k

/-- The position function of the generalised weights: the least `k` with `n < V k`
(or `0` if there is none). -/
noncomputable def genPos (n : ℕ) : ℕ := sInf {k | n < genW r k}

variable {r}

/-- Radices growing at least like `x ↦ 2 ^ x` produce weights growing at least like the
tower weights. -/
theorem W_le_genW (hfast : ∀ x, 2 ^ x ≤ r x) (k : ℕ) : W k ≤ genW r k := by
  induction k with
  | zero => simp [genW]
  | succ k ih =>
      have h1 : (2:ℕ) ^ W k ≤ 2 ^ genW r k := Nat.pow_le_pow_right (by norm_num) ih
      have h2 : (2:ℕ) ^ genW r k ≤ r (genW r k) := hfast _
      calc W (k + 1) = 2 ^ W k * W k := W_succ k
      _ ≤ r (genW r k) * genW r k := Nat.mul_le_mul (le_trans h1 h2) ih
      _ = genW r (k + 1) := rfl

theorem genPos_le_K (hfast : ∀ x, 2 ^ x ≤ r x) (n : ℕ) : genPos r n ≤ K n :=
  Nat.sInf_le (lt_of_lt_of_le (lt_W_K n) (W_le_genW hfast (K n)))

/-- **Conjecture 3, fast-growth half**: if every radix satisfies `r x ≥ 2 ^ x`, the
position function of the generalised weights is bounded by the iterated logarithm
`L2 n + 2`, hence is `O (log* n)`. -/
theorem genPos_le_L2_add_two (hfast : ∀ x, 2 ^ x ≤ r x) (n : ℕ) :
    genPos r n ≤ L2 n + 2 :=
  le_trans (genPos_le_K hfast n) (K_le_L2_add_two n)

end GeneralWeights

section SquareWeights

/-- The squaring weights `V k = 2 ^ (2 ^ k)`, i.e. `V 0 = 2`, `V (k+1) = V k * V k`: the
borderline polynomial case `r x = x` of the growth threshold. -/
def sqW (k : ℕ) : ℕ := 2 ^ (2 ^ k)

theorem sqW_succ (k : ℕ) : sqW (k + 1) = sqW k * sqW k := by
  rw [sqW, sqW, ← pow_add]
  congr 1
  ring

theorem sqW_pos (k : ℕ) : 0 < sqW k := Nat.two_pow_pos _

theorem sqW_strictMono : StrictMono sqW := by
  intro a b hab
  refine Nat.pow_lt_pow_right (by norm_num) ?_
  exact Nat.pow_lt_pow_right (by norm_num) hab

theorem exists_lt_sqW (n : ℕ) : ∃ k, n < sqW k := by
  refine ⟨n, lt_of_lt_of_le Nat.lt_two_pow_self ?_⟩
  exact Nat.pow_le_pow_right (by norm_num) (Nat.le_of_lt Nat.lt_two_pow_self)

/-- The position function of the squaring weights. -/
def sqPos (n : ℕ) : ℕ := Nat.find (exists_lt_sqW n)

theorem lt_sqW_sqPos (n : ℕ) : n < sqW (sqPos n) := Nat.find_spec (exists_lt_sqW n)

theorem lt_sqPos_of_sqW_le {k n : ℕ} (h : sqW k ≤ n) : k < sqPos n := by
  by_contra hc
  push_neg at hc
  have : sqW (sqPos n) ≤ sqW k := sqW_strictMono.monotone hc
  have := lt_sqW_sqPos n
  omega

theorem two_mul_add_ten_le_two_pow (j : ℕ) : 2 * j + 10 ≤ 2 ^ (j + 4) := by
  induction j with
  | zero => norm_num
  | succ j ih =>
      show 2 * (j + 1) + 10 ≤ 2 ^ (j + 5)
      have h1 : (2:ℕ) ^ (j + 5) = 2 * 2 ^ (j + 4) := by ring
      omega

/-- The tower weights dwarf any fixed linear function of the level. -/
theorem linear_add_two_le_W {c j : ℕ} (hc : c ≤ j) : c * (j + 9) + 2 ≤ W (j + 5) := by
  have h1 : c ≤ 2 ^ c := Nat.le_of_lt Nat.lt_two_pow_self
  have h2 : j + 9 ≤ 2 ^ (j + 9) := Nat.le_of_lt Nat.lt_two_pow_self
  have h3 : c * (j + 9) ≤ 2 ^ c * 2 ^ (j + 9) := Nat.mul_le_mul h1 h2
  have h4 : (2:ℕ) ^ c * 2 ^ (j + 9) = 2 ^ (c + j + 9) := by
    rw [← pow_add, Nat.add_assoc]
  have h5 : (2:ℕ) ^ (c + j + 10) = 2 * 2 ^ (c + j + 9) := by ring
  have h6 : (2:ℕ) ^ 1 ≤ 2 ^ (c + j + 9) := Nat.pow_le_pow_right (by norm_num) (by omega)
  have h7 : c + j + 10 ≤ 2 ^ (j + 4) := by
    have := two_mul_add_ten_le_two_pow j
    omega
  have h8 : (2:ℕ) ^ (c + j + 10) ≤ 2 ^ (2 ^ (j + 4)) := Nat.pow_le_pow_right (by norm_num) h7
  have h9 : (2:ℕ) ^ (2 ^ (j + 4)) ≤ 2 ^ W (j + 4) :=
    Nat.pow_le_pow_right (by norm_num) (two_pow_le_W (j + 4))
  have h10 : (2:ℕ) ^ W (j + 4) ≤ 2 ^ sumW (j + 5) :=
    Nat.pow_le_pow_right (by norm_num) (W_le_sumW_succ (j + 4))
  have h11 : (2:ℕ) ^ sumW (j + 5) = W (j + 5) := (W_eq_two_pow_sumW (j + 5)).symm
  simp only [pow_one] at h6
  omega

theorem K_W (k : ℕ) : K (W k) = k + 1 := K_eq_succ_iff.mpr ⟨le_rfl, W_lt_W_succ k⟩

/-- The `L2`-value of a squaring weight minus one is tiny. -/
theorem L2_sqW_sub_one_le {m : ℕ} (hm : 2 ≤ m) : L2 (sqW m - 1) ≤ 2 + L2 (m + 1) := by
  have hbig : (2:ℕ) ^ 2 ≤ sqW m := by
    refine Nat.pow_le_pow_right (by norm_num) ?_
    calc (2:ℕ) = 2 ^ 1 := rfl
    _ ≤ 2 ^ m := Nat.pow_le_pow_right (by norm_num) (by omega)
  have h3 : 3 ≤ sqW m - 1 := by omega
  have hclg : clg (sqW m - 1) = 2 ^ m := by
    have : sqW m - 1 + 1 = 2 ^ (2 ^ m) := by
      have := sqW_pos m
      simp only [sqW] at *
      omega
    rw [clg, this, Nat.clog_pow 2 _ (by norm_num)]
  have hpow3 : 3 ≤ 2 ^ m := by
    have : (2:ℕ) ^ 2 ≤ 2 ^ m := Nat.pow_le_pow_right (by norm_num) hm
    omega
  have hstep1 : L2 (sqW m - 1) = L2 (2 ^ m) + 1 := by
    rw [L2_of_three_le h3, hclg]
  have hstep2 : L2 (2 ^ m) = L2 (clg (2 ^ m)) + 1 := L2_of_three_le hpow3
  have hclg2 : clg (2 ^ m) ≤ m + 1 := by
    refine clg_le_of_le_two_pow ?_
    have : (2:ℕ) ^ (m + 1) = 2 * 2 ^ m := by ring
    have h1 : 1 ≤ (2:ℕ) ^ m := Nat.one_le_two_pow
    omega
  have := L2_mono hclg2
  omega

/-- **Conjecture 3, slow-growth half**: for the squaring weights `V k = 2 ^ (2 ^ k)`
(radix `r x = x`, a polynomial radix) the position function is *not* `O (L2 n)`: for every
constant `c` there is an `n` with `c * L2 n < sqPos n`. -/
theorem sqPos_not_bigO_L2 (c : ℕ) : ∃ n, c * L2 n < sqPos n := by
  set m : ℕ := W (c + 5) - 1 with hm
  have hWbig : 2 ^ (c + 5) ≤ W (c + 5) := two_pow_le_W (c + 5)
  have hpow : 32 ≤ (2:ℕ) ^ (c + 5) := by
    calc (32:ℕ) = 2 ^ 5 := by norm_num
    _ ≤ 2 ^ (c + 5) := Nat.pow_le_pow_right (by norm_num) (by omega)
  have hm2 : 2 ≤ m := by omega
  refine ⟨sqW m - 1, ?_⟩
  have hlow : m ≤ sqPos (sqW m - 1) := by
    have h1 : sqW (m - 1) < sqW m := sqW_strictMono (by omega)
    have h2 : sqW (m - 1) ≤ sqW m - 1 := by omega
    have := lt_sqPos_of_sqW_le h2
    omega
  have hL2 : L2 (sqW m - 1) ≤ 2 + L2 (m + 1) := L2_sqW_sub_one_le hm2
  have hmW : m + 1 = W (c + 5) := by
    have := W_pos (c + 5)
    omega
  have hKW : K (W (c + 5)) = c + 6 := K_W (c + 5)
  have hL2W : L2 (W (c + 5)) ≤ c + 7 := by
    have := L2_le_K_add_one (W (c + 5))
    omega
  have hfin : L2 (sqW m - 1) ≤ c + 9 := by
    rw [hmW] at hL2
    omega
  have hlin : c * (c + 9) + 2 ≤ W (c + 5) := linear_add_two_le_W (le_refl c)
  have hmul : c * L2 (sqW m - 1) ≤ c * (c + 9) := Nat.mul_le_mul_left c hfin
  omega

end SquareWeights

end TowerRadix