import Mathlib
import Computation.ToyQSHenselLines
import Computation.ToyQSSieveThreshold

/-!
# The sieve's work bound: ~2 log-additions per value per prime power (H1)

Context (experiment 470, H1 confirmed).  Naive trial division of `M` sieve values
over a factor base `S` costs `M · |S|` divisions.  The sieve instead walks the two
lines modulo each `p^k` (`ToyQSHensel.rootCountPow_eq_two`), touching only the
values it actually hits.  This file proves the corresponding *unconditional*
work bound, which is the formal shape of the measured mechanism
"~100 divisions/value → ~2 log-adds/value + division of survivors only":

* `card_window_modEq_le` — a window of `M` consecutive integers contains at most
  `M / m + 1` members of a residue class modulo `m`;
* `card_window_hits_le` — at most `2 (M / p^k + 1)` values `x² - N` in the window
  are divisible by `p^k` (two Hensel lines);
* `sieve_work_le` — **total sieve work** (number of log-additions) over the
  window is at most `∑_{p ∈ S} ∑_{k ≤ K} 2 (M / p^k + 1)`, independent of the
  trial-division cost `M · |S|`;
* `effective_u_qr` — the QR-restriction reading of H2: replacing the smoothness
  bound `B` by the "effective" `B / 2` multiplies `u = log v / log B` exactly by
  `log B / (log B - log 2)`, which strictly exceeds `1`.
-/

namespace ToyQSCost

open Finset

/-- **Residue classes in a window.**  For `m > 0`, a window of `M` consecutive
integers contains at most `M / m + 1` integers congruent to `r` modulo `m`. -/
theorem card_window_modEq_le (a r : ℤ) (M m : ℕ) (hm : 0 < m) :
    ((Finset.Ico a (a + M)).filter (fun x => (m : ℤ) ∣ x - r)).card ≤ M / m + 1 := by
  set s := (Finset.Ico a (a + M)).filter (fun x => (m : ℤ) ∣ x - r)
  have hmz : (0 : ℤ) < m := by exact_mod_cast hm
  -- index each member by its quotient `(x - a) / m`
  have hmaps : ∀ x ∈ s, (x - a) / (m : ℤ) ∈ Finset.Icc (0 : ℤ) ((M / m : ℕ) : ℤ) := by
    intro x hx
    simp only [s, Finset.mem_filter, Finset.mem_Ico] at hx
    simp only [Finset.mem_Icc]
    refine ⟨Int.ediv_nonneg (by linarith) hmz.le, ?_⟩
    have : (x - a) / (m : ℤ) ≤ (M : ℤ) / (m : ℤ) :=
      Int.ediv_le_ediv hmz (by linarith)
    simpa [Int.natCast_div] using this
  have hinj : Set.InjOn (fun x => (x - a) / (m : ℤ)) s := by
    intro x hx y hy hxy
    simp only [s, Finset.coe_filter, Set.mem_setOf_eq] at hx hy
    have hmod : (x - a) % (m : ℤ) = (y - a) % (m : ℤ) := by
      have h1 : (m : ℤ) ∣ (x - a) - (y - a) := by
        have := dvd_sub hx.2 hy.2
        have e : x - r - (y - r) = (x - a) - (y - a) := by ring
        rwa [e] at this
      have h2 : (m : ℤ) ∣ (y - a) - (x - a) := by
        have := dvd_neg.2 h1
        have e : -((x - a) - (y - a)) = (y - a) - (x - a) := by ring
        rwa [e] at this
      exact Int.modEq_iff_dvd.2 h2
    have hx' := Int.mul_ediv_add_emod (x - a) (m : ℤ)
    have hy' := Int.mul_ediv_add_emod (y - a) (m : ℤ)
    simp only at hxy
    rw [hxy, hmod] at hx'
    linarith
  have := Finset.card_le_card_of_injOn (t := Finset.Icc (0 : ℤ) ((M / m : ℕ) : ℤ))
    (fun x => (x - a) / (m : ℤ)) (fun x hx => by simpa using hmaps x (by simpa using hx)) hinj
  rw [Int.card_Icc] at this
  have h0 : (0 : ℤ) ≤ ((M / m : ℕ) : ℤ) := Nat.cast_nonneg _
  omega

/-- **Two Hensel lines per prime power.**  For an odd prime `p ∤ N`, at most
`2 (M / p^k + 1)` of the `M` values `x² - N` (`x` in a window) are divisible by
`p^k`. -/
theorem card_window_hits_le {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) {N : ℤ}
    (hpN : ¬ (p : ℤ) ∣ N) (a : ℤ) (M k : ℕ) :
    ((Finset.Ico a (a + M)).filter (fun x => (p : ℤ) ^ k ∣ x ^ 2 - N)).card
      ≤ 2 * (M / p ^ k + 1) := by
  classical
  set s := (Finset.Ico a (a + M)).filter (fun x => (p : ℤ) ^ k ∣ x ^ 2 - N)
  have hpk : 0 < p ^ k := pow_pos hp.pos k
  by_cases hne : s.Nonempty
  · obtain ⟨y, hy⟩ := hne
    have hy' : (p : ℤ) ^ k ∣ y ^ 2 - N := (Finset.mem_filter.1 hy).2
    have hsub : s ⊆ (Finset.Ico a (a + M)).filter (fun x => ((p ^ k : ℕ) : ℤ) ∣ x - y) ∪
        (Finset.Ico a (a + M)).filter (fun x => ((p ^ k : ℕ) : ℤ) ∣ x - (-y)) := by
      intro x hx
      have hx' := Finset.mem_filter.1 hx
      rcases ToyQSHensel.prime_pow_dichotomy hp hp2 hpN hx'.2 hy' with h | h
      · exact Finset.mem_union_left _ (Finset.mem_filter.2 ⟨hx'.1, by push_cast; exact h⟩)
      · exact Finset.mem_union_right _
          (Finset.mem_filter.2 ⟨hx'.1, by push_cast; simpa using h⟩)
    calc s.card ≤ _ := Finset.card_le_card hsub
      _ ≤ _ := Finset.card_union_le _ _
      _ ≤ (M / p ^ k + 1) + (M / p ^ k + 1) :=
          add_le_add (card_window_modEq_le a y M _ hpk) (card_window_modEq_le a (-y) M _ hpk)
      _ = 2 * (M / p ^ k + 1) := by ring
  · rw [Finset.not_nonempty_iff_eq_empty.1 hne]; simp

/-- **Total sieve work.**  For a factor base `S` of odd primes not dividing `N`,
the total number of log-additions performed by the sieve with lines up to height
`K` over a window of `M` values is at most `∑_{p∈S} ∑_{k=1}^{K} 2 (M/p^k + 1)`.
Per value this is `≈ 2 ∑ 1/p^k`, i.e. a few additions, against the `|S|` divisions
per value of trial division. -/
theorem sieve_work_le {S : Finset ℕ} {N : ℤ}
    (hS : ∀ p ∈ S, p.Prime ∧ p ≠ 2 ∧ ¬ (p : ℤ) ∣ N) (a : ℤ) (M K : ℕ) :
    ∑ x ∈ Finset.Ico a (a + M), ∑ p ∈ S, ToyQSSieve.sieveHits K (x ^ 2 - N).natAbs p
      ≤ ∑ p ∈ S, ∑ k ∈ Finset.Icc 1 K, 2 * (M / p ^ k + 1) := by
  classical
  unfold ToyQSSieve.sieveHits
  rw [Finset.sum_comm]
  refine Finset.sum_le_sum (fun p hp => ?_)
  -- swap the window sum and the height sum
  have hswap : ∑ x ∈ Finset.Ico a (a + M),
        ((Finset.Icc 1 K).filter (fun k => p ^ k ∣ (x ^ 2 - N).natAbs)).card
      = ∑ k ∈ Finset.Icc 1 K,
        ((Finset.Ico a (a + M)).filter (fun x => (p : ℤ) ^ k ∣ x ^ 2 - N)).card := by
    simp only [Finset.card_filter]
    rw [Finset.sum_comm]
    refine Finset.sum_congr rfl (fun k _ => Finset.sum_congr rfl (fun x _ => ?_))
    congr 1
    apply propext
    rw [← Int.natCast_dvd]
    push_cast
    rfl
  rw [hswap]
  obtain ⟨hpp, hp2, hpN⟩ := hS p hp
  exact Finset.sum_le_sum (fun k _ => card_window_hits_le hpp hp2 hpN a M k)

/-- **The QR-restriction reading of H2.**  If only the admissible half of the
primes is available, the smoothness bound behaves like `B / 2`; the effective
`u = log v / log (B/2)` equals the nominal `u = log v / log B` multiplied by
`log B / (log B - log 2)`, and is strictly larger whenever `log v > 0`. -/
theorem effective_u_qr {B v : ℝ} (hB : 2 < B) (hv : 1 < v) :
    Real.log v / Real.log (B / 2) =
        (Real.log v / Real.log B) * (Real.log B / (Real.log B - Real.log 2)) ∧
      Real.log v / Real.log B < Real.log v / Real.log (B / 2) := by
  have hlogB2 : 0 < Real.log (B / 2) := Real.log_pos (by linarith)
  have hlogB : 0 < Real.log B := Real.log_pos (by linarith)
  have hlogv : 0 < Real.log v := Real.log_pos hv
  have hsplit : Real.log (B / 2) = Real.log B - Real.log 2 :=
    Real.log_div (by linarith) (by norm_num)
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  refine ⟨?_, ?_⟩
  · rw [hsplit] at hlogB2 ⊢
    field_simp
  · apply div_lt_div_of_pos_left hlogv hlogB2
    rw [hsplit]; linarith

end ToyQSCost