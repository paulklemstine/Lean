/-
# General mixed radix systems, standard and balanced

Given a sequence of radices `r : ℕ → ℕ` with `r i ≥ 1`, the associated weights are
`wt 0 = 1` and `wt (k+1) = r k * wt k`.  This file proves, from scratch:

* `MixedRadix.digit_sum` / `MixedRadix.digit_unique` : every `n < wt r k` has a unique
  expansion `n = ∑_{i<k} d i * wt r i` with `d i < r i`;
* `MixedRadix.balanced_exists` / `MixedRadix.balanced_unique` : for *odd* radices
  `r i = 2 * s i + 1`, every integer `x` with `|x| ≤ (wt r k - 1)/2` has a unique
  *balanced* expansion `x = ∑_{i<k} d i * wt r i` with `|d i| ≤ s i`.

These are the general facts behind the tower radix system `W (k+1) = 2 ^ (W k) * W k`
studied in `Pythagorean.TowerRadix` and `Pythagorean.TowerBalanced`.
-/

import Mathlib

namespace MixedRadix

open Finset

variable (r : ℕ → ℕ)

/-- The weights attached to a radix sequence: `wt 0 = 1`, `wt (k+1) = r k * wt k`. -/
def wt : ℕ → ℕ
  | 0 => 1
  | k + 1 => r k * wt k

@[simp] theorem wt_zero : wt r 0 = 1 := rfl

theorem wt_succ (k : ℕ) : wt r (k + 1) = r k * wt r k := rfl

variable {r}

theorem wt_pos (hr : ∀ i, 0 < r i) (k : ℕ) : 0 < wt r k := by
  induction k with
  | zero => simp
  | succ k ih => exact Nat.mul_pos (hr k) ih

theorem wt_dvd_wt {i k : ℕ} (h : i ≤ k) : wt r i ∣ wt r k := by
  induction k with
  | zero => simp_all
  | succ k ih =>
      rcases Nat.lt_or_ge i (k + 1) with h' | h'
      · exact dvd_trans (ih (by omega)) ⟨r k, by rw [wt_succ]; ring⟩
      · have : i = k + 1 := by omega
        simp [this]

variable (r)

/-- The `i`-th digit of `n` in the mixed radix system with radices `r`. -/
def digit (i n : ℕ) : ℕ := (n % wt r (i + 1)) / wt r i

variable {r}

theorem digit_lt (hr : ∀ i, 0 < r i) (i n : ℕ) : digit r i n < r i := by
  have h := Nat.mod_lt n (wt_pos hr (i + 1))
  rw [digit, Nat.div_lt_iff_lt_mul (wt_pos hr i)]
  simpa [wt_succ] using h

theorem digit_mod {i k n : ℕ} (h : i < k) :
    digit r i (n % wt r k) = digit r i n := by
  have hdvd : wt r (i + 1) ∣ wt r k := wt_dvd_wt (by omega)
  rw [digit, digit, Nat.mod_mod_of_dvd n hdvd]

theorem digit_top {k n : ℕ} (h : n < wt r (k + 1)) : digit r k n = n / wt r k := by
  rw [digit, Nat.mod_eq_of_lt h]

/-- Any admissible digit family produces a value below `wt r k`. -/
theorem sum_digits_lt {k : ℕ} (d : ℕ → ℕ) (hd : ∀ i < k, d i < r i) :
    ∑ i ∈ range k, d i * wt r i < wt r k := by
  induction k with
  | zero => simp
  | succ k ih =>
      rw [Finset.sum_range_succ, wt_succ]
      have h1 : ∑ i ∈ range k, d i * wt r i < wt r k := ih (fun i hi => hd i (by omega))
      have h2 : d k + 1 ≤ r k := hd k (by omega)
      have h3 : (d k + 1) * wt r k ≤ r k * wt r k := Nat.mul_le_mul_right _ h2
      have h4 : (d k + 1) * wt r k = d k * wt r k + wt r k := by ring
      omega

/-- **Existence**: the digits of `n` reconstruct `n`, for every `n < wt r k`. -/
theorem digit_sum (hr : ∀ i, 0 < r i) {k n : ℕ} (h : n < wt r k) :
    ∑ i ∈ range k, digit r i n * wt r i = n := by
  induction k generalizing n with
  | zero =>
      have : n = 0 := by simpa using Nat.lt_one_iff.mp (by simpa using h)
      simp [this]
  | succ k ih =>
      rw [Finset.sum_range_succ]
      have hmod : n % wt r k < wt r k := Nat.mod_lt _ (wt_pos hr k)
      have h1 : ∑ i ∈ range k, digit r i n * wt r i = n % wt r k := by
        rw [← ih hmod]
        exact Finset.sum_congr rfl fun i hi => by
          rw [digit_mod (Finset.mem_range.mp hi)]
      rw [h1, digit_top h]
      exact Nat.mod_add_div' n (wt r k)

/-- **Uniqueness**: an admissible digit family representing `n` consists of the digits
of `n`. -/
theorem digit_eq_of_repr (hr : ∀ i, 0 < r i) {k n : ℕ} (d : ℕ → ℕ) (hd : ∀ i < k, d i < r i)
    (hn : n = ∑ i ∈ range k, d i * wt r i) : ∀ i < k, d i = digit r i n := by
  induction k generalizing n with
  | zero => intro i hi; omega
  | succ k ih =>
      rw [Finset.sum_range_succ] at hn
      set S := ∑ i ∈ range k, d i * wt r i with hS
      have hSlt : S < wt r k := sum_digits_lt d (fun i hi => hd i (by omega))
      have hdk : d k + 1 ≤ r k := hd k (by omega)
      have hnlt : n < wt r (k + 1) := by
        rw [wt_succ, hn]
        have h3 : (d k + 1) * wt r k ≤ r k * wt r k := Nat.mul_le_mul_right _ hdk
        have h4 : (d k + 1) * wt r k = d k * wt r k + wt r k := by ring
        omega
      have hdiv : n / wt r k = d k := by
        rw [hn, Nat.add_mul_div_right _ _ (wt_pos hr k), Nat.div_eq_of_lt hSlt, Nat.zero_add]
      have hmod : n % wt r k = S := by
        rw [hn, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hSlt]
      intro i hi
      rcases Nat.lt_or_ge i k with hik | hik
      · have h5 := ih (n := S) (fun j hj => hd j (by omega)) hS i hik
        rw [h5, ← hmod, digit_mod hik]
      · have hik' : i = k := by omega
        subst hik'
        rw [digit_top hnlt, hdiv]

/-- Two admissible digit families representing the same number agree. -/
theorem digit_unique (hr : ∀ i, 0 < r i) {k : ℕ} (d e : ℕ → ℕ) (hd : ∀ i < k, d i < r i)
    (he : ∀ i < k, e i < r i)
    (h : ∑ i ∈ range k, d i * wt r i = ∑ i ∈ range k, e i * wt r i) : ∀ i < k, d i = e i := by
  intro i hi
  rw [digit_eq_of_repr hr d hd rfl i hi, digit_eq_of_repr hr e he h i hi]

/-! ## Balanced digits for odd radices

Now assume every radix is odd, `r i = 2 * s i + 1`.  Then all the weights are odd as well,
and the numbers representable with digits in the symmetric range `[-s i, s i]` are exactly
the integers of absolute value at most `(wt r k - 1) / 2`.
-/

section Balanced

variable {s : ℕ → ℕ}

/-- The centre `(wt r k - 1) / 2` of the balanced range, defined as
`∑_{i<k} s i * wt r i`. -/
def centre (r s : ℕ → ℕ) (k : ℕ) : ℕ := ∑ i ∈ range k, s i * wt r i

theorem two_centre_succ (hrs : ∀ i, r i = 2 * s i + 1) (k : ℕ) :
    2 * centre r s k + 1 = wt r k := by
  induction k with
  | zero => simp [centre]
  | succ k ih =>
      rw [centre, Finset.sum_range_succ, wt_succ, hrs k]
      have : centre r s k = ∑ i ∈ range k, s i * wt r i := rfl
      rw [← this]
      have h2 : 2 * (centre r s k + s k * wt r k) + 1
          = (2 * centre r s k + 1) + 2 * s k * wt r k := by ring
      rw [h2, ih]
      ring

theorem centre_lt_wt (hrs : ∀ i, r i = 2 * s i + 1) (k : ℕ) : centre r s k < wt r k := by
  have := two_centre_succ hrs (s := s) k
  omega

theorem radix_pos (hrs : ∀ i, r i = 2 * s i + 1) : ∀ i, 0 < r i := by
  intro i; rw [hrs i]; omega

/-- **Existence of the balanced expansion**: every integer `x` with `|x| ≤ centre r s k`
has a length-`k` expansion with digits bounded by `s i` in absolute value. -/
theorem balanced_exists (hrs : ∀ i, r i = 2 * s i + 1) {k : ℕ} {x : ℤ}
    (hx : |x| ≤ (centre r s k : ℤ)) :
    ∃ d : ℕ → ℤ, (∀ i < k, |d i| ≤ (s i : ℤ)) ∧ x = ∑ i ∈ range k, d i * (wt r i : ℤ) := by
  have hr := radix_pos hrs
  have habs := abs_le.mp hx
  set y : ℕ := (x + (centre r s k : ℤ)).toNat with hy
  have hynn : 0 ≤ x + (centre r s k : ℤ) := by omega
  have hycast : (y : ℤ) = x + (centre r s k : ℤ) := Int.toNat_of_nonneg hynn
  have hwt := two_centre_succ hrs (s := s) k
  have hylt : y < wt r k := by
    have h1 : (y : ℤ) ≤ 2 * (centre r s k : ℤ) := by rw [hycast]; omega
    have h2 : y ≤ 2 * centre r s k := by exact_mod_cast h1
    omega
  have hcen : centre r s k = ∑ i ∈ range k, s i * wt r i := rfl
  refine ⟨fun i => (digit r i y : ℤ) - (s i : ℤ), ?_, ?_⟩
  · intro i _
    have h1 : digit r i y ≤ 2 * s i := by
      have h0 := digit_lt hr i y
      rw [hrs i] at h0
      omega
    have h2 : ((digit r i y : ℤ)) ≤ 2 * (s i : ℤ) := by exact_mod_cast h1
    show |(digit r i y : ℤ) - (s i : ℤ)| ≤ (s i : ℤ)
    rw [abs_le]
    omega
  · have hdig := digit_sum hr hylt
    have expand : ∑ i ∈ range k, ((digit r i y : ℤ) - (s i : ℤ)) * (wt r i : ℤ)
        = (∑ i ∈ range k, (digit r i y : ℤ) * (wt r i : ℤ))
          - (∑ i ∈ range k, (s i : ℤ) * (wt r i : ℤ)) := by
      rw [← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun i _ => by ring
    have c1 : (∑ i ∈ range k, (digit r i y : ℤ) * (wt r i : ℤ)) = (y : ℤ) := by
      rw [show (y : ℤ) = ((∑ i ∈ range k, digit r i y * wt r i : ℕ) : ℤ) by rw [hdig]]
      push_cast
      ring
    have c2 : (∑ i ∈ range k, (s i : ℤ) * (wt r i : ℤ)) = (centre r s k : ℤ) := by
      rw [hcen]
      push_cast
      ring
    show x = ∑ i ∈ range k, ((digit r i y : ℤ) - (s i : ℤ)) * (wt r i : ℤ)
    rw [expand, c1, c2, hycast]
    ring

/-- **Uniqueness of the balanced expansion**. -/
theorem balanced_unique (hrs : ∀ i, r i = 2 * s i + 1) {k : ℕ} (d e : ℕ → ℤ)
    (hd : ∀ i < k, |d i| ≤ (s i : ℤ)) (he : ∀ i < k, |e i| ≤ (s i : ℤ))
    (h : ∑ i ∈ range k, d i * (wt r i : ℤ) = ∑ i ∈ range k, e i * (wt r i : ℤ)) :
    ∀ i < k, d i = e i := by
  have hr := radix_pos hrs
  -- transport to natural number digits by shifting each digit by `s i`
  set D : ℕ → ℕ := fun i => (d i + (s i : ℤ)).toNat with hD
  set E : ℕ → ℕ := fun i => (e i + (s i : ℤ)).toNat with hE
  have hDcast : ∀ i < k, (D i : ℤ) = d i + (s i : ℤ) := by
    intro i hi
    have := abs_le.mp (hd i hi)
    exact Int.toNat_of_nonneg (by omega)
  have hEcast : ∀ i < k, (E i : ℤ) = e i + (s i : ℤ) := by
    intro i hi
    have := abs_le.mp (he i hi)
    exact Int.toNat_of_nonneg (by omega)
  have hDlt : ∀ i < k, D i < r i := by
    intro i hi
    have h1 := abs_le.mp (hd i hi)
    have h2 : (D i : ℤ) ≤ 2 * (s i : ℤ) := by rw [hDcast i hi]; omega
    have : (D i : ℤ) < ((r i : ℕ) : ℤ) := by rw [hrs i]; push_cast; omega
    exact_mod_cast this
  have hElt : ∀ i < k, E i < r i := by
    intro i hi
    have h1 := abs_le.mp (he i hi)
    have h2 : (E i : ℤ) ≤ 2 * (s i : ℤ) := by rw [hEcast i hi]; omega
    have : (E i : ℤ) < ((r i : ℕ) : ℤ) := by rw [hrs i]; push_cast; omega
    exact_mod_cast this
  have hsum : ∑ i ∈ range k, D i * wt r i = ∑ i ∈ range k, E i * wt r i := by
    have hcast : ((∑ i ∈ range k, D i * wt r i : ℕ) : ℤ)
        = ((∑ i ∈ range k, E i * wt r i : ℕ) : ℤ) := by
      push_cast
      have hD' : ∑ i ∈ range k, (D i : ℤ) * (wt r i : ℤ)
          = ∑ i ∈ range k, (d i + (s i : ℤ)) * (wt r i : ℤ) :=
        Finset.sum_congr rfl fun i hi => by rw [hDcast i (Finset.mem_range.mp hi)]
      have hE' : ∑ i ∈ range k, (E i : ℤ) * (wt r i : ℤ)
          = ∑ i ∈ range k, (e i + (s i : ℤ)) * (wt r i : ℤ) :=
        Finset.sum_congr rfl fun i hi => by rw [hEcast i (Finset.mem_range.mp hi)]
      rw [hD', hE']
      have hsplit : ∀ f : ℕ → ℤ, ∑ i ∈ range k, (f i + (s i : ℤ)) * (wt r i : ℤ)
          = (∑ i ∈ range k, f i * (wt r i : ℤ))
            + ∑ i ∈ range k, (s i : ℤ) * (wt r i : ℤ) := by
        intro f
        rw [← Finset.sum_add_distrib]
        exact Finset.sum_congr rfl fun i _ => by ring
      rw [hsplit, hsplit, h]
    exact_mod_cast hcast
  intro i hi
  have := digit_unique hr D E hDlt hElt hsum i hi
  have h1 := hDcast i hi
  have h2 := hEcast i hi
  rw [this] at h1
  omega

end Balanced

end MixedRadix

/-! ## Balanced tower digits

Specialising to the odd radices `r k = 2 ^ (W k + 1) + 1` attached to the tower weights
`W 0 = 1`, `W (k+1) = 2 ^ (W k) * W k`.  (The tower weights are also developed, together
with the position function `K`, in `Pythagorean.TowerRadix`; the short definition is
repeated here so that this file stands alone.)
-/

namespace TowerBalanced

open Finset MixedRadix

/-- The tower weights `W 0 = 1`, `W (k+1) = 2 ^ (W k) * W k`. -/
def W : ℕ → ℕ
  | 0 => 1
  | k + 1 => 2 ^ W k * W k

/-- Half of the balanced digit range at position `k`. -/
def halfRadix (k : ℕ) : ℕ := 2 ^ W k

/-- The odd radices `r k = 2 ^ (W k + 1) + 1`. -/
def r (k : ℕ) : ℕ := 2 * halfRadix k + 1

theorem r_eq (k : ℕ) : r k = 2 ^ (W k + 1) + 1 := by
  rw [r, halfRadix, pow_succ]
  ring

/-- The balanced tower weights `U 0 = 1`, `U (k+1) = r k * U k`. -/
def U : ℕ → ℕ := wt r

theorem U_zero : U 0 = 1 := rfl

theorem U_succ (k : ℕ) : U (k + 1) = r k * U k := rfl

theorem two_centre_succ_U (k : ℕ) : 2 * centre r halfRadix k + 1 = U k :=
  two_centre_succ (fun _ => rfl) k

/-- **Conjecture 4 (balanced recursive digits).** With the odd radices
`r i = 2 ^ (W i + 1) + 1` and weights `U 0 = 1`, `U (k+1) = r k * U k`, every integer `x`
in the symmetric range `2 * |x| + 1 ≤ U k` (that is, `|x| ≤ (U k - 1)/2`) has a length-`k`
expansion with `i`-th digit in `[-(r i - 1)/2, (r i - 1)/2] = [-2 ^ W i, 2 ^ W i]`, and the
digits are uniquely determined. -/
theorem balanced_tower_repr {k : ℕ} {x : ℤ} (hx : 2 * |x| + 1 ≤ (U k : ℤ)) :
    (∃ d : ℕ → ℤ, (∀ i < k, |d i| ≤ ((2 : ℤ) ^ W i)) ∧
        x = ∑ i ∈ range k, d i * (U i : ℤ)) ∧
      (∀ d e : ℕ → ℤ, (∀ i < k, |d i| ≤ ((2 : ℤ) ^ W i)) →
        (∀ i < k, |e i| ≤ ((2 : ℤ) ^ W i)) →
        ∑ i ∈ range k, d i * (U i : ℤ) = ∑ i ∈ range k, e i * (U i : ℤ) →
        ∀ i < k, d i = e i) := by
  have hrs : ∀ i, r i = 2 * halfRadix i + 1 := fun _ => rfl
  have hcen : 2 * centre r halfRadix k + 1 = U k := two_centre_succ_U k
  have hcast : (2 : ℤ) * (centre r halfRadix k : ℤ) + 1 = (U k : ℤ) := by exact_mod_cast hcen
  have hxc : |x| ≤ (centre r halfRadix k : ℤ) := by omega
  have hhalf : ∀ i, ((halfRadix i : ℕ) : ℤ) = (2 : ℤ) ^ W i := by
    intro i; simp [halfRadix]
  constructor
  · obtain ⟨d, hd, hsum⟩ := balanced_exists hrs hxc
    exact ⟨d, fun i hi => by rw [← hhalf i]; exact hd i hi, hsum⟩
  · intro d e hd he h i hi
    refine balanced_unique hrs d e (fun j hj => ?_) (fun j hj => ?_) h i hi
    · rw [hhalf j]; exact hd j hj
    · rw [hhalf j]; exact he j hj


/-- The balanced range is non-empty: for `k = 2` the radices are `5` and `9`, the weight is
`U 2 = 45`, and every `|x| ≤ 22` is representable. -/
example : U 2 = 45 := by decide

example : ∃ d : ℕ → ℤ, (∀ i < 2, |d i| ≤ ((2 : ℤ) ^ W i)) ∧
    (22 : ℤ) = ∑ i ∈ Finset.range 2, d i * (U i : ℤ) :=
  (balanced_tower_repr (k := 2) (x := 22) (by decide)).1

end TowerBalanced