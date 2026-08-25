/-
# Positional geometry of the Fermat / quadratic-sieve polynomial

For a modulus `N` and a base `b` (in practice `b = ⌈√N⌉`) the *sieve polynomial* is

    `sieveVal b N j = (b + j)^2 - N`,

and a *hit* at position `j` is a position at which `sieveVal b N j` is `B`-smooth.
Empirically (paper 228 / exp 578, replicated here in `evidence/`) hits cluster toward
small `j`.  The question is whether this is *only* the magnitude decay of `sieveVal`
(the polynomial is increasing in `j`) or whether there is genuine *positional*
arithmetic structure.

This file isolates the arithmetic, magnitude-free content of the question.

Main results.

* `sieveVal_sub_base` / `sieveVal_strictMonoOn` : the exact expansion
  `v(j) - v(0) = j (j + 2b)` and strict monotonicity in `j ≥ 0`.
* `gcd_position_law` : `gcd (j, v(j)) = gcd (j, v(0))` — the **position–gcd law**.
  Position `j` and the *fixed* integer `v(0)` determine the guaranteed common factor;
  in particular `j ∣ v(j) ↔ j ∣ v(0)`.
* `smooth_iff_cofactor_smooth` : the guaranteed factor `g = gcd (j, v(0))` may be
  divided out for free when `g < B`, so the smoothness test at position `j` only
  concerns the cofactor `v(j)/g`.  This is an *arithmetic* enrichment that is
  invisible to `|v(j)|`: a genuinely beyond-magnitude carrier.
* `window_card_eq_zmod`, `window_card_indep_of_start` : a general equidistribution
  device.  Any position predicate that factors through `ZMod T` has exactly the same
  count in every window of `T` consecutive positions.
* `prime_hit_positions_card_le_two` and `prime_window_card_indep` : for a prime `p`
  the positions with `p ∣ v(j)` form at most two residue classes mod `p` and are
  **exactly equidistributed**: no single small prime can produce a small-`j` excess.
* `gcd_carrier_window_card_indep` : the gcd-carrier of `smooth_iff_cofactor_smooth`
  is *itself* exactly equidistributed in position (period `|v(0)|`).  Hence the
  carrier is real but **cannot** be the source of a small-`j` excess.
* `sizeClass_ordConnected` and `cell_collapse` : the confound-analysis theorems.
  Because `v` is strictly monotone, every magnitude class is an *interval of
  positions*, and a magnitude cell of width a factor `2` confines positions to a
  window `j₂ ≤ 2 j₁ + 2 + j₁²/b`.  Stratifying by `|v|` therefore cannot decorrelate
  position from magnitude within a single `N`.
-/
import Mathlib

namespace FermatPosition

open Finset

/-! ## The sieve polynomial -/

/-- The Fermat / quadratic-sieve polynomial `v(j) = (b + j)^2 - N`. -/
def sieveVal (b N j : ℤ) : ℤ := (b + j) ^ 2 - N

lemma sieveVal_zero (b N : ℤ) : sieveVal b N 0 = b ^ 2 - N := by
  simp [sieveVal]

/-- Exact expansion of the sieve polynomial around position `0`. -/
theorem sieveVal_sub_base (b N j : ℤ) :
    sieveVal b N j - sieveVal b N 0 = j * (j + 2 * b) := by
  simp only [sieveVal]; ring

/-- The sieve polynomial is strictly increasing in the position `j ≥ 0`
(for a nonnegative base): position and magnitude are functionally dependent. -/
theorem sieveVal_strictMonoOn (b N : ℤ) (hb : 0 ≤ b) {j₁ j₂ : ℤ}
    (h₁ : 0 ≤ j₁) (h : j₁ < j₂) : sieveVal b N j₁ < sieveVal b N j₂ := by
  have : (b + j₁) ^ 2 < (b + j₂) ^ 2 := by nlinarith
  simpa [sieveVal] using this

/-! ## The position–gcd law -/

/-- **Position–gcd law.**  The greatest common divisor of a position `j` with its own
sieve value equals its gcd with the *base value* `v(0) = b² - N`.  The arithmetic
interaction between a position and its value is completely determined by the fixed
integer `v(0)`. -/
theorem gcd_position_law (b N j : ℤ) :
    Int.gcd j (sieveVal b N j) = Int.gcd j (sieveVal b N 0) := by
  have h : sieveVal b N j = sieveVal b N 0 + (j + 2 * b) * j := by
    have := sieveVal_sub_base b N j; linarith [this]
  rw [h, Int.gcd_comm, Int.gcd_comm j]
  exact Int.gcd_add_mul_right_left j (sieveVal b N 0) (j + 2 * b)

/-- The self-divisibility form of the position–gcd law. -/
theorem dvd_sieveVal_self_iff (b N j : ℤ) :
    j ∣ sieveVal b N j ↔ j ∣ sieveVal b N 0 := by
  constructor <;> intro h
  · have := sieveVal_sub_base b N j
    have : sieveVal b N 0 = sieveVal b N j - j * (j + 2 * b) := by linarith
    rw [this]; exact dvd_sub h ⟨j + 2 * b, rfl⟩
  · have h2 : sieveVal b N j = sieveVal b N 0 + j * (j + 2 * b) :=
      by have := sieveVal_sub_base b N j; linarith
    rw [h2]; exact dvd_add h ⟨j + 2 * b, rfl⟩

/-! ## The gcd carrier: a beyond-magnitude smoothness enrichment -/

/-- **Free cofactor reduction.**  If `g` is a divisor of `v` which is smaller than the
smoothness bound `B`, then `v` is `B`-smooth iff the cofactor `v / g` is.  Applied with
`g = gcd (j, v(0))` (Theorem `gcd_position_law`) this says: at position `j` the
smoothness test only has to be passed by `v(j) / gcd (j, v(0))`, a *smaller* number.
This enrichment depends on the arithmetic of the position, not on `|v(j)|`. -/
theorem smooth_iff_cofactor_smooth {B v g : ℕ} (hg : g ∣ v) (hgB : 0 < g)
    (hlt : g < B) : v ∈ Nat.smoothNumbers B ↔ v / g ∈ Nat.smoothNumbers B := by
  constructor
  · intro h; exact Nat.mem_smoothNumbers_of_dvd h (Nat.div_dvd_of_dvd hg)
  · intro h
    have hgs : g ∈ Nat.smoothNumbers B := Nat.mem_smoothNumbers_of_lt hgB hlt
    have : g * (v / g) = v := Nat.mul_div_cancel' hg
    have := Nat.mul_mem_smoothNumbers hgs h
    rwa [Nat.mul_div_cancel' hg] at this

/-- The gcd carrier in the form used by the experiments: at a position `j` with
`0 < j < B` that divides the base value `v(0)`, the value `v(j)` is `B`-smooth as soon
as the reduced cofactor `v(j)/j` is. -/
theorem smooth_of_pos_dvd_base {B : ℕ} {b N j : ℤ} (hj : 0 < j) (hjB : j.natAbs < B)
    (hdvd : j ∣ sieveVal b N 0)
    (hcof : ((sieveVal b N j) / j).natAbs ∈ Nat.smoothNumbers B) :
    (sieveVal b N j).natAbs ∈ Nat.smoothNumbers B := by
  have hjv : j ∣ sieveVal b N j := (dvd_sieveVal_self_iff b N j).2 hdvd
  have hnat : j.natAbs ∣ (sieveVal b N j).natAbs := Int.natAbs_dvd_natAbs.2 hjv
  have hpos : 0 < j.natAbs := Int.natAbs_pos.2 (ne_of_gt hj)
  rw [smooth_iff_cofactor_smooth hnat hpos hjB]
  have h4 : (sieveVal b N j).natAbs / j.natAbs = ((sieveVal b N j) / j).natAbs :=
    (Int.natAbs_ediv_of_dvd hjv).symm
  rwa [h4]

/-! ## Equidistribution device -/

/-- If a position predicate `P` factors through `ZMod T`, then every window of `T`
consecutive positions contains exactly the same number of positions satisfying `P`,
namely the number of solutions in `ZMod T`. -/
theorem window_card_eq_zmod (T : ℕ) [NeZero T] (P : ℤ → Prop) [DecidablePred P]
    (Q : ZMod T → Prop) [DecidablePred Q] (hPQ : ∀ j : ℤ, P j ↔ Q (j : ZMod T)) (a : ℤ) :
    ((range T).filter (fun i : ℕ => P (a + (i : ℤ)))).card = (univ.filter Q).card := by
  classical
  have hval : ∀ x : ZMod T, (((x - (a : ZMod T)).val : ℤ) : ZMod T) = x - (a : ZMod T) := by
    intro x; push_cast [ZMod.natCast_val, ZMod.cast_id]; rfl
  refine Finset.card_bij' (fun (i : ℕ) _ => ((a + (i : ℤ) : ℤ) : ZMod T))
    (fun (x : ZMod T) _ => ((x - (a : ZMod T)).val)) ?_ ?_ ?_ ?_
  · intro i hi
    simp only [mem_filter, mem_range] at hi
    simpa [mem_filter, mem_univ] using (hPQ (a + (i : ℤ))).1 hi.2
  · intro x hx
    simp only [mem_filter, mem_univ, true_and] at hx
    refine mem_filter.2 ⟨mem_range.2 (ZMod.val_lt _), ?_⟩
    refine (hPQ _).2 ?_
    have h2 : ((a + (((x - (a : ZMod T)).val : ℕ) : ℤ) : ℤ) : ZMod T) = x := by
      push_cast [hval x]; ring
    rw [h2]; exact hx
  · intro i hi
    simp only [mem_filter, mem_range] at hi
    show ((((a + (i : ℤ) : ℤ) : ZMod T) - (a : ZMod T)).val) = i
    have h3 : ((a + (i : ℤ) : ℤ) : ZMod T) - (a : ZMod T) = ((i : ℕ) : ZMod T) := by
      push_cast; ring
    rw [h3, ZMod.val_natCast_of_lt hi.1]
  · intro x hx
    show ((a + (((x - (a : ZMod T)).val : ℕ) : ℤ) : ℤ) : ZMod T) = x
    push_cast [hval x]; ring

/-- Window counts of a `ZMod T`-periodic position predicate do not depend on where the
window starts: exact positional equidistribution. -/
theorem window_card_indep_of_start (T : ℕ) [NeZero T] (P : ℤ → Prop) [DecidablePred P]
    (Q : ZMod T → Prop) [DecidablePred Q] (hPQ : ∀ j : ℤ, P j ↔ Q (j : ZMod T)) (a a' : ℤ) :
    ((range T).filter (fun i : ℕ => P (a + (i : ℤ)))).card
      = ((range T).filter (fun i : ℕ => P (a' + (i : ℤ)))).card := by
  rw [window_card_eq_zmod T P Q hPQ a, window_card_eq_zmod T P Q hPQ a']

/-! ## No single prime can create a small-`j` excess -/

/-- For a prime `p`, the positions `j` with `p ∣ v(j)` form at most **two** residue
classes modulo `p`. -/
theorem prime_hit_positions_card_le_two (p : ℕ) [Fact p.Prime] (b N : ZMod p) :
    (univ.filter (fun x : ZMod p => (b + x) ^ 2 = N)).card ≤ 2 := by
  classical
  by_cases h : ∃ r : ZMod p, (b + r) ^ 2 = N
  · obtain ⟨r, hr⟩ := h
    have hsub : (univ.filter (fun x : ZMod p => (b + x) ^ 2 = N)) ⊆ {r, -r - 2 * b} := by
      intro x hx
      simp only [mem_filter, mem_univ, true_and] at hx
      have hz : (x - r) * (x + r + 2 * b) = 0 := by
        have : (b + x) ^ 2 - (b + r) ^ 2 = 0 := by rw [hx, hr]; ring
        linear_combination this
      rcases mul_eq_zero.1 hz with h1 | h2
      · exact mem_insert.2 (Or.inl (sub_eq_zero.1 h1))
      · refine mem_insert.2 (Or.inr (mem_singleton.2 ?_))
        linear_combination h2
    calc (univ.filter (fun x : ZMod p => (b + x) ^ 2 = N)).card
        ≤ ({r, -r - 2 * b} : Finset (ZMod p)).card := card_le_card hsub
      _ ≤ 2 := (card_insert_le _ _).trans (by simp)
  · push_neg at h
    have : (univ.filter (fun x : ZMod p => (b + x) ^ 2 = N)) = ∅ := by
      refine filter_eq_empty_iff.2 ?_
      intro x _; exact h x
    simp [this]

/-- **Positional uniformity of prime divisibility.**  For every prime `p` the number of
positions `j` in a window of `p` consecutive positions with `p ∣ v(j)` is the same for
every window, and is at most `2`.  Divisibility by a fixed small prime is therefore
*exactly* uniform in position: no single small prime can be a carrier of a small-`j`
excess of smooth values. -/
theorem prime_window_card_indep (p : ℕ) [hp : Fact p.Prime] (b N : ℤ) (a a' : ℤ) :
    ((range p).filter (fun i : ℕ => (p : ℤ) ∣ sieveVal b N (a + (i : ℤ)))).card
      = ((range p).filter (fun i : ℕ => (p : ℤ) ∣ sieveVal b N (a' + (i : ℤ)))).card := by
  classical
  haveI : NeZero p := ⟨hp.out.ne_zero⟩
  refine window_card_indep_of_start p (fun j : ℤ => (p : ℤ) ∣ sieveVal b N j)
    (fun x : ZMod p => ((b : ZMod p) + x) ^ 2 = (N : ZMod p)) ?_ a a'
  intro j
  constructor
  · intro h
    have := (ZMod.intCast_zmod_eq_zero_iff_dvd _ p).2 h
    have h2 : (((b + j) ^ 2 - N : ℤ) : ZMod p) = 0 := by simpa [sieveVal] using this
    push_cast at h2
    linear_combination h2
  · intro h
    refine (ZMod.intCast_zmod_eq_zero_iff_dvd _ p).1 ?_
    have : (((b + j) ^ 2 - N : ℤ) : ZMod p) = 0 := by push_cast; linear_combination h
    simpa [sieveVal] using this

theorem prime_window_card_le_two (p : ℕ) [hp : Fact p.Prime] (b N a : ℤ) :
    ((range p).filter (fun i : ℕ => (p : ℤ) ∣ sieveVal b N (a + (i : ℤ)))).card ≤ 2 := by
  classical
  haveI : NeZero p := ⟨hp.out.ne_zero⟩
  have h := window_card_eq_zmod p (fun j => (p : ℤ) ∣ sieveVal b N j)
    (fun x : ZMod p => ((b : ZMod p) + x) ^ 2 = (N : ZMod p)) ?_ a
  · rw [h]; exact prime_hit_positions_card_le_two p _ _
  · intro j
    constructor
    · intro hdvd
      have := (ZMod.intCast_zmod_eq_zero_iff_dvd _ p).2 hdvd
      have h2 : (((b + j) ^ 2 - N : ℤ) : ZMod p) = 0 := by simpa [sieveVal] using this
      push_cast at h2
      linear_combination h2
    · intro hq
      refine (ZMod.intCast_zmod_eq_zero_iff_dvd _ p).1 ?_
      have : (((b + j) ^ 2 - N : ℤ) : ZMod p) = 0 := by push_cast; linear_combination hq
      simpa [sieveVal] using this

/-- **Prime powers behave like primes.**  For an odd prime `p` not dividing `N`, any two
positions at which `p^k` divides the sieve value are either congruent modulo `p^k` or
*conjugate*, `x + y + 2b ≡ 0`.  The lifting is exact: no extra solutions appear at higher
prime powers, so the positions with `p^k ∣ v(j)` still form at most two residue classes
mod `p^k` and are exactly equidistributed at that scale. -/
theorem prime_pow_two_classes {p k : ℕ} (hp : p.Prime) (hodd : p ≠ 2) {b N x y : ℤ}
    (hk : 1 ≤ k) (hN : ¬ ((p : ℤ) ∣ N))
    (hx : ((p : ℤ) ^ k) ∣ sieveVal b N x) (hy : ((p : ℤ) ^ k) ∣ sieveVal b N y) :
    ((p : ℤ) ^ k) ∣ (x - y) ∨ ((p : ℤ) ^ k) ∣ (x + y + 2 * b) := by
  have hprod : ((p : ℤ) ^ k) ∣ (x - y) * (x + y + 2 * b) := by
    have hid : (x - y) * (x + y + 2 * b) = sieveVal b N x - sieveVal b N y := by
      simp only [sieveVal]; ring
    rw [hid]; exact dvd_sub hx hy
  have hp1 : (p : ℤ) ∣ sieveVal b N x := dvd_trans (dvd_pow_self _ (by omega)) hx
  have hpbx : ¬ ((p : ℤ) ∣ (b + x)) := by
    intro hd
    apply hN
    have h2 : (p : ℤ) ∣ (b + x) ^ 2 := Dvd.dvd.pow hd (by norm_num)
    have h3 : (p : ℤ) ∣ ((b + x) ^ 2 - sieveVal b N x) := dvd_sub h2 hp1
    simpa [sieveVal] using h3
  have hpprime : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  have hsum : (x - y) + (x + y + 2 * b) = 2 * (b + x) := by ring
  have hp2 : ¬ ((p : ℤ) ∣ 2) := by
    intro hd
    have hle := Int.le_of_dvd (by norm_num) hd
    have h2 := hp.two_le
    exact hodd (by omega)
  by_cases h1 : (p : ℤ) ∣ (x - y)
  · left
    have hnd : ¬ ((p : ℤ) ∣ (x + y + 2 * b)) := by
      intro hd
      have hs : (p : ℤ) ∣ 2 * (b + x) := by rw [← hsum]; exact dvd_add h1 hd
      rcases hpprime.dvd_mul.1 hs with h | h
      · exact hp2 h
      · exact hpbx h
    exact hpprime.pow_dvd_of_dvd_mul_left k hnd (by rwa [mul_comm] at hprod)
  · right
    exact hpprime.pow_dvd_of_dvd_mul_left k h1 hprod

/-- Congruence form of `prime_pow_two_classes`: every position where `p^k` divides the
sieve value is congruent mod `p^k` to a fixed solution `r` or to its conjugate
`-r - 2b`. -/
theorem prime_pow_position_classes {p k : ℕ} (hp : p.Prime) (hodd : p ≠ 2) {b N r x : ℤ}
    (hk : 1 ≤ k) (hN : ¬ ((p : ℤ) ∣ N))
    (hr : ((p : ℤ) ^ k) ∣ sieveVal b N r) (hx : ((p : ℤ) ^ k) ∣ sieveVal b N x) :
    x ≡ r [ZMOD (p : ℤ) ^ k] ∨ x ≡ -r - 2 * b [ZMOD (p : ℤ) ^ k] := by
  rcases prime_pow_two_classes hp hodd hk hN hx hr with h | h
  · left
    exact (Int.modEq_iff_dvd.2 (by simpa using (dvd_neg.2 h)))
  · right
    refine Int.modEq_iff_dvd.2 ?_
    have : -r - 2 * b - x = -(x + r + 2 * b) := by ring
    rw [this]
    exact dvd_neg.2 (by simpa [add_comm, add_left_comm, add_assoc] using h)

/-! ## The gcd carrier is itself positionally uniform -/

/-- The gcd carrier `g(j) = gcd (j, v(0))` is periodic in the position with period
`|v(0)|`. -/
theorem gcd_carrier_periodic (b N j : ℤ) :
    Int.gcd (j + sieveVal b N 0) (sieveVal b N 0) = Int.gcd j (sieveVal b N 0) := by
  simp

/-- **The carrier cannot explain a small-`j` excess.**  The set of positions carrying a
nontrivial guaranteed common factor `gcd (j, v(0)) > 1` has exactly the same count in
every window of `|v(0)|` consecutive positions.  Combined with
`smooth_iff_cofactor_smooth` this says: the gcd carrier is a real, magnitude-free
smoothness enrichment, but it is *positionally uniform*, so it is not the source of the
observed clustering of hits at small `j`. -/
theorem gcd_carrier_window_card_indep (b N : ℤ) (hv : sieveVal b N 0 ≠ 0) (a a' : ℤ) :
    ((range (sieveVal b N 0).natAbs).filter
        (fun i : ℕ => 1 < Int.gcd (a + (i : ℤ)) (sieveVal b N 0))).card
      = ((range (sieveVal b N 0).natAbs).filter
        (fun i : ℕ => 1 < Int.gcd (a' + (i : ℤ)) (sieveVal b N 0))).card := by
  classical
  set v₀ := sieveVal b N 0 with hv₀
  haveI : NeZero v₀.natAbs := ⟨Int.natAbs_ne_zero.2 hv⟩
  refine window_card_indep_of_start v₀.natAbs (fun j : ℤ => 1 < Int.gcd j v₀)
    (fun x : ZMod v₀.natAbs => 1 < Int.gcd ((x.val : ℤ)) v₀) ?_ a a'
  intro j
  have hmod : ((j : ZMod v₀.natAbs).val : ℤ) % v₀ = j % v₀ := by
    have : ((j : ZMod v₀.natAbs).val : ℤ) % (v₀.natAbs : ℤ) = j % (v₀.natAbs : ℤ) := by
      have h1 : (((j : ZMod v₀.natAbs).val : ℤ) : ZMod v₀.natAbs) = (j : ZMod v₀.natAbs) := by
        push_cast [ZMod.natCast_val, ZMod.cast_id]; rfl
      have := (ZMod.intCast_eq_intCast_iff' _ _ _).1 h1
      simpa using this
    rcases Int.natAbs_eq v₀ with h | h
    · rw [← h] at this; exact this
    · have hneg : ((v₀.natAbs : ℤ)) = -v₀ := by omega
      rw [hneg] at this
      simpa [Int.emod_neg] using this
  have hg : ∀ x y : ℤ, x % v₀ = y % v₀ → Int.gcd x v₀ = Int.gcd y v₀ := by
    intro x y hxy
    have hx : Int.gcd x v₀ = Int.gcd (x % v₀) v₀ := (Int.gcd_emod x v₀).symm
    have hy : Int.gcd y v₀ = Int.gcd (y % v₀) v₀ := (Int.gcd_emod y v₀).symm
    rw [hx, hy, hxy]
  simp only [hg _ _ hmod.symm]

/-! ## Confound analysis: magnitude cells are position intervals -/

/-- **Stratification collapse.**  Any classification of positions by a monotone function
of the magnitude `v(j)` has *order-connected* classes: a magnitude cell is an interval of
positions.  Within a single `N`, conditioning on `|v|` therefore cannot decorrelate
position from magnitude. -/
theorem sizeClass_ordConnected (b N : ℤ) (hb : 0 ≤ b) (f : ℤ → ℤ) (hf : Monotone f) (c : ℤ)
    {j₁ j j₂ : ℤ} (h₁ : 0 ≤ j₁) (hj : j₁ ≤ j) (hj2 : j ≤ j₂)
    (hc₁ : f (sieveVal b N j₁) = c) (hc₂ : f (sieveVal b N j₂) = c) :
    f (sieveVal b N j) = c := by
  have hmono : ∀ {x y : ℤ}, 0 ≤ x → x ≤ y → sieveVal b N x ≤ sieveVal b N y := by
    intro x y hx hxy
    rcases eq_or_lt_of_le hxy with rfl | h
    · exact le_rfl
    · exact le_of_lt (sieveVal_strictMonoOn b N hb hx h)
  have h1 : f (sieveVal b N j₁) ≤ f (sieveVal b N j) := hf (hmono h₁ hj)
  have h2 : f (sieveVal b N j) ≤ f (sieveVal b N j₂) := hf (hmono (le_trans h₁ hj) hj2)
  omega

/-- **Quantitative cell collapse.**  Take `b = ⌈√N⌉`, i.e. `(b-1)^2 ≤ N ≤ b^2`, and two
positions in the same magnitude cell in the weak sense that `v(j₂) ≤ 2 v(j₁)` (a cell of
one bit of `|v|`).  Then the positions are confined to a factor-two window:
`b * j₂ ≤ 2 b j₁ + 2 b + j₁²`, i.e. `j₂ ≤ 2 j₁ + 2 + j₁²/b`.  A bit-length cell of `|v|`
therefore contains only a bounded multiplicative range of positions — the pooled
"stratified" positional statistic of exp 578 cannot be reading within-cell geometry. -/
theorem cell_collapse {b N j₁ j₂ : ℤ} (hb : 1 ≤ b) (hN₁ : (b - 1) ^ 2 ≤ N)
    (h : sieveVal b N j₂ ≤ 2 * sieveVal b N j₁) :
    b * j₂ ≤ 2 * b * j₁ + 2 * b + j₁ ^ 2 := by
  simp only [sieveVal] at h
  nlinarith [sq_nonneg j₁, sq_nonneg j₂, sq_nonneg (j₂ - j₁)]

/-- Sharp form for the small-position regime: if `j₁ ≤ √b` then a one-bit magnitude cell
confines positions to `j₂ ≤ 2 j₁ + 3`. -/
theorem cell_collapse_small {b N j₁ j₂ : ℤ} (hb : 1 ≤ b) (hN₁ : (b - 1) ^ 2 ≤ N)
    (hsmall : j₁ ^ 2 ≤ b)
    (h : sieveVal b N j₂ ≤ 2 * sieveVal b N j₁) : j₂ ≤ 2 * j₁ + 3 := by
  have hkey := cell_collapse hb hN₁ h
  nlinarith

end FermatPosition