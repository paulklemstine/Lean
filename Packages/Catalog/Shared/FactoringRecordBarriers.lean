import Mathlib

/-!
# Round-33 record corrections: GFHP precondition window, UMW covering guards,
# and the Berggren spine collapse

Formalises §6 and §8 of the round-33 corrections note, with one
**correction of a correction** (GFHP).

## GFHP Lemma 3.5 precondition (§8) — the window is BOUNDED

The precondition `δ ≥ N^{1/4} lg⁸N` at `δ = N^{1/3}`, raised to the 12th power,
reads `N ≥ (lg N)^96`; for `N = 2^k` this is `k^96 ≤ 2^k` (`gfhpPre k`).

* `gfhpPre_fails_window` — the precondition **fails for every `k ∈ [96, 949]`**.
* `gfhpPre_holds_from` — it **holds for every `k ≥ 950`**.
* `gfhpPre_rsa2048` — in particular it holds at `N = 2^2048`.

So the note's "violates the precondition for every `N ≥ 2^96`" is **false**: the
violation window is exactly `2^96 ≤ N < 2^950` (within `k ≥ 96`), and for
cryptographic `N ≥ 2^950` (e.g. RSA-2048) the lemma's precondition *is* met.
(Base-2 logarithm; the asymptotic step is `gfhp_step`, proved with `exp`/`log`.)

## UMW covering guards (§6)

`CoversByDiv S T n` : every `k ∈ [1, n]` divides some difference `s - t`.

* `covers_of_inter_nonempty` — guard 1: if `S ∩ T ≠ ∅` the property holds for
  every `n` (the zero difference), so such candidates measure nothing.
* `covers_card_le_divisor_sum` — with `S ∩ T = ∅`, covering forces
  `n ≤ Σ_{s,t} d(|s - t|)` (union bound over divisor sets).
* `covers_pairs_lower_bound` — hence if every `|s - t|` has at most `D` divisors,
  `n ≤ |S|·|T|·D`: the counting barrier behind the "generic case is killed".

## Berggren spine (§8)

* `spine_diff` — along the `B`-spine from `(3,4,5)`, `a_k - b_k = (-1)^{k+1}`.
* `spine_gcd_trivial` — consequently `gcd(a_k - b_k, N) = 1` for every `N`:
  any gcd test built on `a_k - b_k` reveals nothing, collapsing such probes.
-/

namespace FactoringRecordBarriers

open Finset

/-! ## GFHP precondition window -/

/-- The GFHP Lemma 3.5 precondition at `δ = N^{1/3}`, `N = 2^k`, after raising to
the 12th power: `k^96 ≤ 2^k`. -/
def gfhpPre (k : ℕ) : Prop := k ^ 96 ≤ 2 ^ k

instance (k : ℕ) : Decidable (gfhpPre k) := by unfold gfhpPre; infer_instance

/-- Growth step: for `k ≥ 139`, `(k+1)^96 ≤ 2·k^96`. -/
theorem gfhp_step (k : ℕ) (hk : 139 ≤ k) : (k + 1) ^ 96 ≤ 2 * k ^ 96 := by
  have hk' : (139 : ℝ) ≤ k := by exact_mod_cast hk
  have hkpos : (0 : ℝ) < k := by linarith
  have key : ((k : ℝ) + 1) ^ 96 ≤ 2 * (k : ℝ) ^ 96 := by
    have e : ((k : ℝ) + 1) = k * (1 / k + 1) := by field_simp; ring
    rw [e, mul_pow, mul_comm]
    apply mul_le_mul_of_nonneg_right _ (by positivity)
    calc (1 / (k : ℝ) + 1) ^ 96 ≤ (Real.exp (1 / k)) ^ 96 :=
          pow_le_pow_left₀ (by positivity) (Real.add_one_le_exp _) _
      _ = Real.exp (96 * (1 / k)) := by rw [← Real.exp_nat_mul]; norm_num
      _ ≤ Real.exp (Real.log 2) := by
          apply Real.exp_le_exp.2
          have hl := Real.log_two_gt_d9
          rw [mul_one_div, div_le_iff₀ hkpos]
          nlinarith
      _ = 2 := Real.exp_log (by norm_num)
  exact_mod_cast key

theorem gfhpPre_succ (k : ℕ) (hk : 139 ≤ k) (h : gfhpPre k) : gfhpPre (k + 1) := by
  unfold gfhpPre at *
  calc (k + 1) ^ 96 ≤ 2 * k ^ 96 := gfhp_step k hk
    _ ≤ 2 * 2 ^ k := by omega
    _ = 2 ^ (k + 1) := by ring

/-- **The precondition holds for all `k ≥ 950`.** -/
theorem gfhpPre_holds_from (k : ℕ) (hk : 950 ≤ k) : gfhpPre k := by
  induction k, hk using Nat.le_induction with
  | base => unfold gfhpPre; decide +kernel
  | succ n hn ih => exact gfhpPre_succ n (by omega) ih

/-- **Holding propagates upward** (from `k ≥ 139`), so failure propagates
downward on `[139, ∞)`. -/
theorem gfhpPre_mono (j k : ℕ) (hj : 139 ≤ j) (hjk : j ≤ k) (h : gfhpPre j) : gfhpPre k := by
  induction k, hjk using Nat.le_induction with
  | base => exact h
  | succ n hn ih => exact gfhpPre_succ n (by omega) ih

/-- **The precondition fails on the whole window `k ∈ [96, 949]`.** -/
theorem gfhpPre_fails_window (k : ℕ) (h1 : 96 ≤ k) (h2 : k ≤ 949) : ¬ gfhpPre k := by
  have h949 : ¬ gfhpPre 949 := by unfold gfhpPre; decide +kernel
  by_cases hk : 139 ≤ k
  · exact fun h => h949 (gfhpPre_mono k 949 hk h2 h)
  · interval_cases k <;> (unfold gfhpPre; decide +kernel)

theorem gfhpPre_rsa2048 : gfhpPre 2048 := gfhpPre_holds_from 2048 (by norm_num)

/-- The note's universal claim is refuted. -/
theorem not_fails_for_all_beyond_96 : ¬ ∀ k, 96 ≤ k → ¬ gfhpPre k :=
  fun h => h 2048 (by norm_num) gfhpPre_rsa2048

/-! ## UMW covering guards -/

/-- Every `k ∈ [1, n]` divides some difference `s - t` with `s ∈ S`, `t ∈ T`. -/
def CoversByDiv (S T : Finset ℤ) (n : ℕ) : Prop :=
  ∀ k ∈ Icc 1 n, ∃ s ∈ S, ∃ t ∈ T, (k : ℤ) ∣ s - t

/-- **Guard 1.** A common element gives the zero difference, which every `k`
divides: spurious 100% coverage. -/
theorem covers_of_inter_nonempty (S T : Finset ℤ) (h : (S ∩ T).Nonempty) (n : ℕ) :
    CoversByDiv S T n := by
  obtain ⟨x, hx⟩ := h
  rw [mem_inter] at hx
  intro k _
  exact ⟨x, hx.1, x, hx.2, by simp⟩

/-- **Union bound.** With `S ∩ T = ∅`, covering `[1, n]` forces
`n ≤ Σ_{(s,t)} d(|s - t|)`. -/
theorem covers_card_le_divisor_sum (S T : Finset ℤ) (hdisj : Disjoint S T) (n : ℕ)
    (hcov : CoversByDiv S T n) :
    n ≤ ∑ x ∈ S ×ˢ T, (Int.natAbs (x.1 - x.2)).divisors.card := by
  have hsub : Icc 1 n ⊆ (S ×ˢ T).biUnion (fun x => (Int.natAbs (x.1 - x.2)).divisors) := by
    intro k hk
    obtain ⟨s, hs, t, ht, hdiv⟩ := hcov k hk
    rw [mem_biUnion]
    refine ⟨(s, t), mem_product.2 ⟨hs, ht⟩, ?_⟩
    have hne : s - t ≠ 0 := by
      intro h0
      have : s = t := by linarith
      exact Finset.disjoint_left.1 hdisj hs (this ▸ ht)
    rw [Nat.mem_divisors]
    refine ⟨?_, by simpa using hne⟩
    exact Int.natAbs_dvd_natAbs.2 hdiv |>.trans (by simp)
  calc n = #(Icc 1 n) := by simp
    _ ≤ #((S ×ˢ T).biUnion (fun x => (Int.natAbs (x.1 - x.2)).divisors)) := card_le_card hsub
    _ ≤ _ := card_biUnion_le

/-- **Counting barrier.** If every difference has at most `D` divisors, a
disjoint covering of `[1, n]` needs `|S|·|T|·D ≥ n`. -/
theorem covers_pairs_lower_bound (S T : Finset ℤ) (hdisj : Disjoint S T) (n D : ℕ)
    (hD : ∀ s ∈ S, ∀ t ∈ T, (Int.natAbs (s - t)).divisors.card ≤ D)
    (hcov : CoversByDiv S T n) : n ≤ #S * #T * D := by
  calc n ≤ ∑ x ∈ S ×ˢ T, (Int.natAbs (x.1 - x.2)).divisors.card :=
        covers_card_le_divisor_sum S T hdisj n hcov
    _ ≤ ∑ _x ∈ S ×ˢ T, D := by
        apply sum_le_sum
        rintro ⟨s, t⟩ h
        rw [mem_product] at h
        exact hD s h.1 t h.2
    _ = #S * #T * D := by rw [sum_const, card_product, smul_eq_mul]

/-- Lab note (guard 1 in action): `S = {0, 5}`, `T = {5, 7}` share `5` and
"cover" `[1, 1000]`, while the disjoint `S = {0, 5}`, `T = {7}` fail at `k = 3`
(differences `-7, -2`). -/
example : CoversByDiv {0, 5} {5, 7} 1000 ∧ ¬ CoversByDiv {0, 5} {7} 3 := by
  refine ⟨covers_of_inter_nonempty _ _ ⟨5, by decide⟩ _, ?_⟩
  intro h
  obtain ⟨s, hs, t, ht, hd⟩ := h 3 (by decide)
  simp only [mem_insert, mem_singleton] at hs ht
  rcases hs with rfl | rfl <;> subst ht <;> omega

/-! ## Berggren `B`-spine -/

/-- The Berggren `B` matrix acting on a triple. -/
def bergB (x : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (x.1 + 2 * x.2.1 + 2 * x.2.2, 2 * x.1 + x.2.1 + 2 * x.2.2, 2 * x.1 + 2 * x.2.1 + 3 * x.2.2)

/-- The `B`-spine from the root `(3, 4, 5)`. -/
def spine : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | k + 1 => bergB (spine k)

theorem spine_pyth (k : ℕ) :
    (spine k).1 ^ 2 + (spine k).2.1 ^ 2 = (spine k).2.2 ^ 2 := by
  induction k with
  | zero => norm_num [spine]
  | succ k ih => simp only [spine, bergB]; nlinarith [ih]

/-- **Spine identity** `a_k - b_k = (-1)^{k+1}`. -/
theorem spine_diff (k : ℕ) : (spine k).1 - (spine k).2.1 = (-1) ^ (k + 1) := by
  induction k with
  | zero => norm_num [spine]
  | succ k ih =>
    simp only [spine, bergB]
    rw [pow_succ]
    linarith

/-- **Collapse.** `gcd(a_k - b_k, N) = 1` for every `N`. -/
theorem spine_gcd_trivial (k : ℕ) (N : ℤ) : Int.gcd ((spine k).1 - (spine k).2.1) N = 1 := by
  rw [spine_diff]
  rcases neg_one_pow_eq_or ℤ (k + 1) with h | h <;> rw [h] <;> simp

/-! ## Effective-sample-size lab note (§8) -/

/-- Strip all factors `q` from `n` (with fuel). -/
def stripP (q : ℕ) : ℕ → ℕ → ℕ
  | 0, n => n
  | fuel + 1, n => if 0 < n ∧ q ∣ n then stripP q fuel (n / q) else n

/-- `n < 2^20` is `13`-smooth (fuel `20` suffices below `2^20`). -/
def smooth13 (n : ℕ) : Bool :=
  stripP 13 20 (stripP 11 20 (stripP 7 20 (stripP 5 20 (stripP 3 20 (stripP 2 20 n))))) == 1

/-- Lab note (computation, compiled evaluation): of the `38 635` primes in
`[2^19, 2^20)`, exactly `163` have `13`-smooth `p - 1`. -/
theorem effective_sample_size :
    #{p ∈ Ico (2 ^ 19) (2 ^ 20) | Nat.Prime p} = 38635 ∧
    #{p ∈ Ico (2 ^ 19) (2 ^ 20) | Nat.Prime p ∧ smooth13 (p - 1) = true} = 163 := by
  native_decide

end FactoringRecordBarriers