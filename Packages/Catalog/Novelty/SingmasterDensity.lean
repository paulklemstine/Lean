/-
# Almost every number occurs exactly twice in Pascal's triangle

Singmaster's problem asks for a bound on the multiplicity `N(t)`.  Whatever the answer,
the *typical* behaviour can be settled completely, and that is what this file does:

> the number of `t ≤ X` with `N(t) ≥ 3` is at most `(√(2X) + 2)(log₂ X + 1)`,

so the integers of multiplicity exactly two have density one
(`Catalog.Novelty.SingmasterDensity.eventually_high_mult_small`).  Numerically, below
`10⁶` the bound gives `28 320`, and the true count is `1 732`.

## Mechanism

A number `t` with `N(t) ≥ 3` must have an occurrence `C(n,k) = t` with `2 ≤ k` and
`2k ≤ n` — the reflection decomposition
`N(t) = 2 + 2·#leftInt(t) + #centerOcc(t)` of `Combinatorics.SingmasterMaxBelowMillion`
leaves no other possibility.  Such an occurrence is heavily constrained:

* `C(n,2) ≤ C(n,k) = t ≤ X` forces `n ≤ √(2X) + 1` (the row index is *small*);
* `2 ^ k ≤ C(n,k) = t ≤ X` forces `k ≤ log₂ X` (the column index is *tiny*).

So all of these `t` are values of the map `(n,k) ↦ C(n,k)` on an explicit
`(√(2X)+2) × (log₂ X + 1)` box, and a cardinality estimate finishes the proof.  The
mechanism is the same "geometry × arithmetic" cross-cut used in
`Catalog.Novelty.SingmasterSmoothness`, but applied to *counting* rather than to
factorisation.

## Results

* `exists_interior_occ_of_three_le_mult` — a multiplicity `≥ 3` produces an occurrence
  with `2 ≤ k` and `2k ≤ n`;
* `card_highMult_le` — **the counting bound** `#{t ≤ X : N(t) ≥ 3} ≤ (√(2X)+2)(log₂X+1)`;
* `log_succ_le_two_mul_sqrt`, `mul_log_succ_le_self` — elementary "log beats linear"
  estimates;
* `eventually_high_mult_small` — **density one**: for every `c` there is an `N` such that
  `c · #{t ≤ X : N(t) ≥ 3} ≤ X` for all `X ≥ N`.
-/
import Mathlib
import Combinatorics.SingmasterOccurrences
import Combinatorics.SingmasterParity
import Combinatorics.SingmasterMaxBelowMillion
import Novelty.SingmasterSmoothness

open Finset

namespace Catalog.Novelty.SingmasterDensity

open Singmaster Catalog.Novelty.SingmasterSmooth

/-- The numbers up to `X` occurring at least three times in Pascal's triangle. -/
def highMult (X : ℕ) : Finset ℕ := (Finset.Icc 2 X).filter (fun t => 3 ≤ mult t)

theorem mem_highMult {X t : ℕ} : t ∈ highMult X ↔ (2 ≤ t ∧ t ≤ X) ∧ 3 ≤ mult t := by
  simp [highMult, Finset.mem_filter, Finset.mem_Icc, and_assoc]

/-- A number occurring at least three times has a genuinely interior occurrence: a
position `(n,k)` with `2 ≤ k` and `2k ≤ n`. -/
theorem exists_interior_occ_of_three_le_mult {t : ℕ} (ht : 3 ≤ t) (hmul : 3 ≤ mult t) :
    ∃ n k : ℕ, n.choose k = t ∧ 2 ≤ k ∧ 2 * k ≤ n := by
  classical
  have ht2 : 2 ≤ t := by omega
  have hdec := mult_eq_two_add_two_mul_leftInt ht
  rcases Finset.eq_empty_or_nonempty (leftInt t) with hL | ⟨⟨n, k⟩, hmem⟩
  · -- no left interior occurrence: the extra occurrence must be central
    rw [hL] at hdec
    simp only [Finset.card_empty, Nat.mul_zero, Nat.add_zero] at hdec
    have hcen : 1 ≤ (centerOcc t).card := by omega
    obtain ⟨⟨n, k⟩, hp⟩ := Finset.card_pos.1 hcen
    rw [mem_centerOcc, mem_occ_iff ht2] at hp
    obtain ⟨⟨hkn, hck⟩, hn⟩ := hp
    have hk2 : 2 ≤ k := by
      by_contra hcon
      interval_cases k
      · simp at hck; omega
      · subst hn; norm_num at hck; omega
    exact ⟨n, k, hck, hk2, by omega⟩
  · rw [mem_leftInt ht2] at hmem
    exact ⟨n, k, hmem.1.2, hmem.2.2, by omega⟩

/-- **Counting bound.**  At most `(√(2X)+2)(log₂X+1)` numbers below `X` occur three or
more times in Pascal's triangle. -/
theorem card_highMult_le (X : ℕ) :
    (highMult X).card ≤ (Nat.sqrt (2 * X) + 2) * (Nat.log 2 X + 1) := by
  classical
  set B := (Finset.range (Nat.sqrt (2 * X) + 2)) ×ˢ (Finset.range (Nat.log 2 X + 1)) with hB
  have hsub : highMult X ⊆ B.image (fun p : ℕ × ℕ => p.1.choose p.2) := by
    intro t htmem
    rw [mem_highMult] at htmem
    obtain ⟨⟨ht2, htX⟩, hmul⟩ := htmem
    have ht3 : 3 ≤ t := by
      rcases Nat.lt_or_ge t 3 with h | h
      · interval_cases t
        · rw [mult_two] at hmul; omega
      · exact h
    obtain ⟨n, k, hck, hk2, hkn⟩ := exists_interior_occ_of_three_le_mult ht3 hmul
    -- the row index is at most `√(2X) + 1`
    have hrow : n * (n - 1) ≤ 2 * X := by
      have := row_mul_pred_le_of_interior hk2 (by omega) hck
      omega
    have hnbound : n < Nat.sqrt (2 * X) + 2 := by
      by_contra hcon
      push_neg at hcon
      have h1 : (Nat.sqrt (2 * X) + 1) * (Nat.sqrt (2 * X) + 1) ≤ n * (n - 1) :=
        Nat.mul_le_mul (by omega) (by omega)
      have h2 : 2 * X < (Nat.sqrt (2 * X) + 1) * (Nat.sqrt (2 * X) + 1) := by
        have := Nat.lt_succ_sqrt' (2 * X)
        simpa [pow_two, Nat.succ_eq_add_one] using this
      omega
    -- the column index is at most `log₂ X`
    have hpow : 2 ^ k ≤ X := le_trans (by rw [← hck]; exact two_pow_le_choose hkn) htX
    have hkbound : k < Nat.log 2 X + 1 := by
      have : k ≤ Nat.log 2 X :=
        (Nat.le_log_iff_pow_le (by norm_num) (by omega)).2 hpow
      omega
    refine Finset.mem_image.2 ⟨(n, k), ?_, hck⟩
    rw [hB, Finset.mem_product, Finset.mem_range, Finset.mem_range]
    exact ⟨hnbound, hkbound⟩
  calc (highMult X).card ≤ (B.image (fun p : ℕ × ℕ => p.1.choose p.2)).card :=
        Finset.card_le_card hsub
    _ ≤ B.card := Finset.card_image_le
    _ = (Nat.sqrt (2 * X) + 2) * (Nat.log 2 X + 1) := by
        rw [hB, Finset.card_product, Finset.card_range, Finset.card_range]

/-! ## The density statement -/

/-- Elementary estimate: `log₂ u + 1 ≤ 2 √u` for `u ≥ 1`. -/
theorem log_succ_le_two_mul_sqrt {u : ℕ} (hu : 1 ≤ u) :
    Nat.log 2 u + 1 ≤ 2 * Nat.sqrt u := by
  set L := Nat.log 2 u with hL
  have hpow : 2 ^ L ≤ u := Nat.pow_log_le_self 2 (by omega)
  have hhalf : 2 ^ (L / 2) * 2 ^ (L / 2) ≤ u := by
    calc 2 ^ (L / 2) * 2 ^ (L / 2) = 2 ^ (L / 2 + L / 2) := by rw [← pow_add]
      _ ≤ 2 ^ L := Nat.pow_le_pow_right (by norm_num) (by omega)
      _ ≤ u := hpow
  have hsqrt : 2 ^ (L / 2) ≤ Nat.sqrt u := Nat.le_sqrt.2 hhalf
  have hexp : L / 2 + 1 ≤ 2 ^ (L / 2) := Nat.succ_le_of_lt (Nat.lt_two_pow_self)
  omega

/-- If `2a ≤ √u` then `a (log₂ u + 1) ≤ u`. -/
theorem mul_log_succ_le_self {a u : ℕ} (hu : 1 ≤ u) (h : 2 * a ≤ Nat.sqrt u) :
    a * (Nat.log 2 u + 1) ≤ u := by
  have h1 : a * (Nat.log 2 u + 1) ≤ a * (2 * Nat.sqrt u) :=
    Nat.mul_le_mul_left _ (log_succ_le_two_mul_sqrt hu)
  have h2 : a * (2 * Nat.sqrt u) = (2 * a) * Nat.sqrt u := by ring
  have h3 : (2 * a) * Nat.sqrt u ≤ Nat.sqrt u * Nat.sqrt u :=
    Nat.mul_le_mul_right _ h
  have h4 : Nat.sqrt u * Nat.sqrt u ≤ u := by
    have := Nat.sqrt_le' u
    rw [pow_two] at this
    exact this
  omega

/-- **Density one.**  For every `c` there is a threshold beyond which the numbers of
multiplicity at least three below `X` are fewer than `X / c`; equivalently, the numbers
occurring exactly twice have density one. -/
theorem eventually_high_mult_small (c : ℕ) :
    ∃ N : ℕ, ∀ X : ℕ, N ≤ X → c * (highMult X).card ≤ X := by
  classical
  refine ⟨(21 * c + 21) ^ 4 + 16, fun X hX => ?_⟩
  have hpow0 : 0 ≤ (21 * c + 21) ^ 4 := Nat.zero_le _
  set u := Nat.sqrt X with hu
  set v := Nat.sqrt u with hv
  have hX16 : 16 ≤ X := by omega
  have husq : u * u ≤ X := by
    have := Nat.sqrt_le' X
    rw [pow_two] at this
    exact this
  have hvsq : v * v ≤ u := by
    have := Nat.sqrt_le' u
    rw [pow_two] at this
    exact this
  have hu4 : 4 ≤ u := Nat.le_sqrt.2 (by omega)
  -- the threshold gives `v ≥ 21c + 21`
  have hA : ((21 * c + 21) * (21 * c + 21)) * ((21 * c + 21) * (21 * c + 21)) ≤ X := by
    have hid : ((21 * c + 21) * (21 * c + 21)) * ((21 * c + 21) * (21 * c + 21)) =
        (21 * c + 21) ^ 4 := by ring
    omega
  have hv21 : 21 * c + 21 ≤ v := Nat.le_sqrt.2 (Nat.le_sqrt.2 hA)
  -- `log₂ X + 1 ≤ 4 v + 3`
  have hL : Nat.log 2 X + 1 ≤ 4 * v + 3 := by
    have hXlt : X < (u + 1) * (u + 1) := by
      have := Nat.lt_succ_sqrt' X
      rw [pow_two] at this
      exact this
    have h4u : X < (2 * u) * (2 * u) := by nlinarith [hXlt, hu4]
    have hpu : u < 2 ^ (Nat.log 2 u + 1) := Nat.lt_pow_succ_log_self (by norm_num) u
    have h2u : (2 * u) * (2 * u) ≤ 2 ^ (2 * Nat.log 2 u + 4) := by
      calc (2 * u) * (2 * u) ≤ (2 * 2 ^ (Nat.log 2 u + 1)) * (2 * 2 ^ (Nat.log 2 u + 1)) :=
            Nat.mul_le_mul (by omega) (by omega)
        _ = 2 ^ (2 * Nat.log 2 u + 4) := by ring
    have hlogX : Nat.log 2 X < 2 * Nat.log 2 u + 4 :=
      Nat.log_lt_of_lt_pow (b := 2) (x := 2 * Nat.log 2 u + 4) (y := X) (by omega) (by omega)
    have hlu : Nat.log 2 u + 1 ≤ 2 * v := log_succ_le_two_mul_sqrt (u := u) (by omega)
    omega
  -- the counting bound, in terms of `u` and `v`
  have hcount : (highMult X).card ≤ (2 * u + 3) * (4 * v + 3) := by
    refine le_trans (card_highMult_le X) ?_
    have hs : Nat.sqrt (2 * X) ≤ 2 * u + 1 := by
      by_contra hcon
      push_neg at hcon
      have h1 : (2 * u + 2) * (2 * u + 2) ≤ Nat.sqrt (2 * X) * Nat.sqrt (2 * X) :=
        Nat.mul_le_mul (by omega) (by omega)
      have h2 : Nat.sqrt (2 * X) * Nat.sqrt (2 * X) ≤ 2 * X := by
        have := Nat.sqrt_le' (2 * X)
        rw [pow_two] at this
        exact this
      have h3 : X < (u + 1) * (u + 1) := by
        have := Nat.lt_succ_sqrt' X
        rw [pow_two] at this
        exact this
      nlinarith [h1, h2, h3]
    exact Nat.mul_le_mul (by omega) hL
  -- assemble
  have h15 : 15 * c * v ≤ u := by nlinarith [hvsq, hv21, Nat.zero_le c]
  have hstep1 : c * (highMult X).card ≤ c * ((2 * u + 3) * (4 * v + 3)) :=
    Nat.mul_le_mul_left _ hcount
  have hb : (2 * u + 3) * (4 * v + 3) ≤ 15 * (u * v) := by
    have h1 : 4 * v ≤ u * v := Nat.mul_le_mul_right v hu4
    have h2 : 21 * u ≤ u * v := by
      calc 21 * u = u * 21 := by ring
        _ ≤ u * v := Nat.mul_le_mul_left u (by omega)
    nlinarith [h1, h2, hu4]
  have hstep2 : c * ((2 * u + 3) * (4 * v + 3)) ≤ c * (15 * (u * v)) :=
    Nat.mul_le_mul_left _ hb
  have hstep3 : c * (15 * (u * v)) ≤ u * u := by
    calc c * (15 * (u * v)) = (15 * c * v) * u := by ring
      _ ≤ u * u := Nat.mul_le_mul_right _ h15
  omega

end Catalog.Novelty.SingmasterDensity