/-
# CONVERSE-COST-CURVE, part IV: NO-POLYLOG-ROUTE-ANYWHERE

The synthesis of the three previous parts.  The experimental claim is that the
whole known factor-revealing witness family sits on **one** cost–information
plane: every definition route costs at least the `√N` scale, while the
information it delivers is the single symmetric datum `s = p + q`, which then
pins `{p, q}`.

This file proves the two halves of that statement that are mathematically
meaningful:

* `ConverseCost.route_cost_sq_bound` — for a balanced semiprime every route cost
  `c` in `routeCosts` satisfies `N ≤ 2c²`, i.e. `c ≥ √(N/2)`.
* `ConverseCost.poly_lt_exp` — polynomials lose to `2^m` eventually.
* `ConverseCost.no_polylog_route_anywhere` — **the verdict**: for every degree
  `d` there is a threshold beyond which *every* route cost of *every* balanced
  semiprime exceeds `(log₂ N)^d`.  No route in the family is `poly(log N)`.
* `ConverseCost.firstHit_determines_pair` — the information half for W2, the
  companion of `pillai_determines_pair` (W1) from part I.

The honest boundary is recorded in the docstrings: the statement is a theorem
about these *definition routes* (the cost of evaluating each witness by its
defining scan), not a lower bound over all algorithms; the latter is the open
theoretical target of the programme.
-/
import Mathlib
import Combinatorics.ConverseCostWitnessFamily
import Combinatorics.ConverseCostScanBarrier
import Combinatorics.ConverseCostIdempotentPlane

namespace ConverseCost

open Filter Asymptotics

/-- The costs of the definition routes of the witness family for `N = p q`:
the full `N`-scans of W1 (`M₁ = ∑ gcd`) and W4 (idempotent count) cost `N`, and
the zero-divisor scan W2 stops after `min p q` steps (part II). -/
def routeCosts (p q : ℕ) : Finset ℕ := {p * q, min p q}

/-- Every route cost is at least the cheapest one, `min p q`. -/
theorem min_le_routeCost {p q c : ℕ} (hp : 0 < p) (hq : 0 < q)
    (hc : c ∈ routeCosts p q) : min p q ≤ c := by
  simp only [routeCosts, Finset.mem_insert, Finset.mem_singleton] at hc
  rcases hc with rfl | rfl
  · rcases le_total p q with h | h
    · rw [min_eq_left h]
      calc p = p * 1 := (Nat.mul_one p).symm
        _ ≤ p * q := Nat.mul_le_mul_left p hq
    · rw [min_eq_right h]
      calc q = 1 * q := (Nat.one_mul q).symm
        _ ≤ p * q := Nat.mul_le_mul_right q hp
  · exact le_rfl

/-- **The `√N` floor of the plane.**  For a balanced semiprime every definition
route of the family costs at least `√(N/2)`. -/
theorem route_cost_sq_bound {p q c : ℕ} (hp : 0 < p) (hq : 0 < q) (hpq : p ≤ q)
    (hbal : q ≤ 2 * p) (hc : c ∈ routeCosts p q) : p * q ≤ 2 * (c * c) := by
  have h1 : min p q ≤ c := min_le_routeCost hp hq hc
  have h2 : p * q ≤ 2 * (min p q * min p q) := balanced_scan_cost hpq hbal
  exact le_trans h2 (by nlinarith [h1, Nat.zero_le (min p q)])

/-! ## Polynomials lose to exponentials -/

/-- For every degree `d`, `(m+1)^d < 2^m` for all large `m`. -/
theorem poly_lt_exp (d : ℕ) : ∃ K : ℕ, ∀ m ≥ K, (m + 1) ^ d < 2 ^ m := by
  have h := isLittleO_pow_const_const_pow_of_one_lt (R := ℝ) d (by norm_num : (1:ℝ) < 2)
  have h4 := h.def (by norm_num : (0:ℝ) < 1/4)
  obtain ⟨K, hK⟩ := eventually_atTop.mp h4
  refine ⟨K + 1, fun m hm => ?_⟩
  have hmK : K ≤ m + 1 := by omega
  have hle := hK (m + 1) hmK
  simp only [norm_pow, Real.norm_natCast, Real.norm_ofNat] at hle
  have hreal : ((m + 1 : ℕ) : ℝ) ^ d < 2 ^ m := by
    have hpos : (0:ℝ) < 2 ^ m := by positivity
    have hsplit : (2:ℝ) ^ (m + 1) = 2 * 2 ^ m := by ring
    push_cast at hle ⊢
    nlinarith [hle, hpos, hsplit]
  exact_mod_cast hreal

/-! ## The verdict -/

/-- **NO-POLYLOG-ROUTE-ANYWHERE.**  Fix any polynomial degree `d`.  Beyond an
explicit threshold, *every* definition route of the witness family, evaluated on
*any* balanced semiprime `N = p q` (`p ≤ q ≤ 2p`), costs more than
`(log₂ N)^d` operations.

Formally: the cheapest route cost `min p q` already dominates every fixed power
of the bit length, because the route costs live on the `√N` scale while
`log₂ N` is the bit length itself.  This is the formal shadow of the measured
cost curve: `α = 1.000` for the two full scans and `cost = min(p,q)` for the
zero-divisor scan — no `poly(log N)` route anywhere in the family. -/
theorem no_polylog_route_anywhere (d : ℕ) :
    ∃ K : ℕ, ∀ p q : ℕ, 0 < p → 0 < q → p ≤ q → q ≤ 2 * p → K ≤ p * q →
      ∀ c ∈ routeCosts p q, (Nat.log 2 (p * q)) ^ d < c := by
  obtain ⟨K₀, hK₀⟩ := poly_lt_exp (2 * d)
  refine ⟨2 ^ (K₀ + 1), fun p q hp hq hpq hbal hN c hc => ?_⟩
  set N := p * q with hNdef
  have hN0 : N ≠ 0 := by positivity
  set k := Nat.log 2 N with hk
  -- the bit length is large
  have hklarge : K₀ + 1 ≤ k := (Nat.le_log_iff_pow_le (by norm_num) hN0).mpr hN
  have hk1 : 1 ≤ k := by omega
  -- `2^k ≤ N ≤ 2 p²`, so `2^(k-1) ≤ p²`
  have hpow : 2 ^ k ≤ N := Nat.pow_log_le_self 2 hN0
  have hbalsq : N ≤ 2 * (p * p) := by nlinarith [hpq, hbal]
  have hstep : 2 ^ (k - 1) ≤ p * p := by
    have h2 : 2 ^ k = 2 * 2 ^ (k - 1) := by
      conv_lhs => rw [show k = (k - 1) + 1 by omega]
      ring
    omega
  -- polynomials lose: `k^(2d) < 2^(k-1) ≤ p²`
  have hkm : (k - 1) + 1 = k := by omega
  have hpoly : k ^ (2 * d) < 2 ^ (k - 1) := by
    have := hK₀ (k - 1) (by omega)
    rwa [hkm] at this
  have hlt : (k ^ d) * (k ^ d) < p * p := by
    calc (k ^ d) * (k ^ d) = k ^ (2 * d) := by rw [two_mul, pow_add]
      _ < 2 ^ (k - 1) := hpoly
      _ ≤ p * p := hstep
  have hkp : k ^ d < p := by
    by_contra hcon
    push_neg at hcon
    exact absurd hlt (not_lt.mpr (Nat.mul_le_mul hcon hcon))
  have hmin : min p q = p := min_eq_left hpq
  exact lt_of_lt_of_le hkp (by rw [← hmin]; exact min_le_routeCost hp hq hc)

/-! ## The information half: each route pins the same pair -/

/-- **W2 reaches the factors.**  Two semiprimes with the same modulus and the
same zero-divisor scan cost have the same factors: the stopping point of the
scan, together with `N`, determines `{p, q}`. -/
theorem firstHit_determines_pair {p q p' q' : ℕ}
    (hp : p.Prime) (hle : p ≤ q) (hle' : p' ≤ q')
    (hN : p * q = p' * q') (hhit : min p q = min p' q') :
    p = p' ∧ q = q' := by
  rw [min_eq_left hle, min_eq_left hle'] at hhit
  refine ⟨hhit, ?_⟩
  subst hhit
  exact Nat.eq_of_mul_eq_mul_left hp.pos hN

/-- **One plane.**  For a balanced semiprime the two informative routes (W1's
gcd-sum and W2's first hit) pin exactly the same object — the unordered pair
`{p, q}` — while the W4 counter returns the constant `4` (part III) and hence
pins nothing.  The content of the family is the single number `s = p + q`. -/
theorem witness_family_one_plane {p q p' q' : ℕ}
    (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (hp' : p'.Prime) (hq' : q'.Prime) (hne' : p' ≠ q')
    (hle : p ≤ q) (hle' : p' ≤ q') (hN : p * q = p' * q') :
    (pillai (p * q) = pillai (p' * q') ↔ p + q = p' + q') ∧
    (min p q = min p' q' ↔ p + q = p' + q') ∧
    (p + q = p' + q' ↔ (p = p' ∧ q = q')) := by
  have h1 := pillai_semiprime hp hq hne
  have h2 := pillai_semiprime hp' hq' hne'
  rw [hN] at h1
  refine ⟨⟨fun _ => by omega, fun _ => by rw [hN]⟩, ⟨fun h => ?_, fun h => ?_⟩,
    ⟨fun h => sum_rigidity h hN hle hle', fun h => by rw [h.1, h.2]⟩⟩
  · obtain ⟨he1, he2⟩ := firstHit_determines_pair hp hle hle' hN h
    omega
  · obtain ⟨he1, he2⟩ := sum_rigidity h hN hle hle'
    rw [he1, he2]

end ConverseCost