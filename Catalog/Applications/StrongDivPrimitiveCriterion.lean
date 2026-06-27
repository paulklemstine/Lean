import Mathlib
import Applications.StrongDivisibilitySequences

/-! # The strong primitive-divisor criterion: the rank of apparition

Domain: Number Theory / Applications.

This file **extends** `Catalog/Applications/StrongDivisibilitySequences.lean` (the abstract
strong-divisibility-sequence theory `StrongDivSeq.IsStrongDivSeq`, with its primitivity and
simultaneous-apparition results) by introducing the **rank of apparition**

  `rank u p := sInf {k | 0 < k ∧ p ∣ u k}`,

the least positive index at which `p` appears in the sequence `u`.  Where the parent file's
results (`StrongDivSeq.dvd_iff_index_dvd_of_primitive`, `StrongDivSeq.simultaneous_apparition`)
require the caller to *supply* a primitive index, here we **manufacture** that index canonically
from `p` alone and turn the whole theory into a self-contained *criterion* phrased purely in
terms of `rank`.  This unifies the Fibonacci entry-point theory
(`Catalog/Applications/FibonacciEntryPoints.lean`) and the Mersenne/`aⁿ−1` family under one
definition.

Main results (for an arbitrary strong divisibility sequence `u`):

* `rank_primitive`        — `p` is a primitive divisor of `u (rank u p)` whenever it appears at
  all; i.e. the rank is always a primitive index.  (Cf. `StrongDivSeq.IsPrimitive`.)
* `dvd_iff_rank_dvd`      — the **strong primitive-divisor criterion**: `p ∣ u m ↔ rank u p ∣ m`.
  Builds on `StrongDivSeq.dvd_iff_index_dvd_of_primitive`.
* `isPrimitive_iff_eq_rank` — `IsPrimitive u p n ↔ n = rank u p` (for `0 < n`): the rank is the
  unique primitive index, sharpening `StrongDivSeq.isPrimitive_unique`.
* `joint_dvd_iff_lcm_rank_dvd` — the **join law in ranks**: `(p ∣ u n ∧ q ∣ u n) ↔
  lcm (rank u p) (rank u q) ∣ n`, a rank-only form of `StrongDivSeq.simultaneous_apparition`.
* `fib_dvd_iff_rank_dvd` / `mersenne_dvd_iff_rank_dvd` — the criterion specialized to the
  Fibonacci and `aⁿ−1` sequences, recovering the law of apparition from one definition.
-/

namespace StrongDivSeq

open scoped Classical

/-- The **rank of apparition** of `p` in the sequence `u`: the least *positive* index `k`
with `p ∣ u k` (and `0` if `p` never appears at a positive index). -/
noncomputable def rank (u : ℕ → ℕ) (p : ℕ) : ℕ :=
  sInf {k | 0 < k ∧ p ∣ u k}

/-- `p` *appears* in `u` if it divides some `u k` at a positive index `k`. -/
def Appears (u : ℕ → ℕ) (p : ℕ) : Prop := ∃ k, 0 < k ∧ p ∣ u k

/-! ## §1. Basic properties of the rank -/

/-
!-- Lab Notebook: rank_pos / rank_mem -- !--
!-- Hypothesis: When `p` appears, its rank is a positive index at which `p` divides `u`. -- !--
!-- Result: `Nat.sInf_mem` on the nonempty appearance set gives membership; the set's
!-- defining predicate carries both `0 < rank` and `p ∣ u rank`. -- !--
!-- Insight: The rank is the canonical witness of appearance. -- !--
!-- End Lab Notebook -- !--

!-- `Nat.sInf_mem` applied to the nonempty appearance set. -- !--
-/
theorem rank_mem {u : ℕ → ℕ} {p : ℕ} (h : Appears u p) :
    0 < rank u p ∧ p ∣ u (rank u p) := by
      exact Nat.sInf_mem h

theorem rank_pos {u : ℕ → ℕ} {p : ℕ} (h : Appears u p) : 0 < rank u p :=
  (rank_mem h).1

theorem rank_dvd {u : ℕ → ℕ} {p : ℕ} (h : Appears u p) : p ∣ u (rank u p) :=
  (rank_mem h).2

/-
!-- Lab Notebook: rank_le -- !--
!-- Hypothesis: The rank is `≤` every positive index at which `p` divides `u`. -- !--
!-- Result: `Nat.sInf_le` on membership of `k` in the appearance set. -- !--
!-- Insight: Minimality of the rank, the engine behind primitivity. -- !--
!-- End Lab Notebook -- !--

!-- `Nat.sInf_le` with the witness `⟨hk, hdvd⟩`. -- !--
-/
theorem rank_le {u : ℕ → ℕ} {p k : ℕ} (hk : 0 < k) (hdvd : p ∣ u k) :
    rank u p ≤ k := by
      exact Nat.sInf_le ⟨ hk, hdvd ⟩

/-! ## §2. The rank is the unique primitive index -/

/-
!-- Lab Notebook: rank_primitive -- !--
!-- Hypothesis: `p` is a primitive divisor of `u (rank u p)`. -- !--
!-- Result: `rank_dvd` gives divisibility at the rank; `rank_le` (contrapositive) forbids
!-- divisibility at any smaller positive index, which is exactly minimality. -- !--
!-- Insight: The rank canonically produces the primitive index that the parent file's
!-- `dvd_iff_index_dvd_of_primitive` had to take as input. -- !--
!-- End Lab Notebook -- !--

!-- Combine `rank_dvd` with the contrapositive of `rank_le`. -- !--
-/
theorem rank_primitive {u : ℕ → ℕ} {p : ℕ} (h : Appears u p) :
    IsPrimitive u p (rank u p) := by
      exact ⟨ rank_dvd h, fun k hk₁ hk₂ hk₃ => not_lt_of_ge ( rank_le hk₁ hk₃ ) hk₂ ⟩

/-
!-- Lab Notebook: isPrimitive_iff_eq_rank -- !--
!-- Hypothesis: For `0 < n`, `p` is primitive at `n` iff `n` equals its rank. -- !--
!-- Result: (←) `rank_primitive`. (→) primitivity makes `p` appear, so `rank_primitive`
!-- holds, and `isPrimitive_unique` forces `n = rank u p`. -- !--
!-- Insight: Sharpens `isPrimitive_unique`: the single primitive index is computable as `rank`. -- !--
!-- End Lab Notebook -- !--

!-- (→) via `isPrimitive_unique` with `rank_primitive`; (←) is `rank_primitive` after `n = rank`. -- !--
-/
theorem isPrimitive_iff_eq_rank {u : ℕ → ℕ} {p n : ℕ} (hn : 0 < n) :
    IsPrimitive u p n ↔ n = rank u p := by
      constructor <;> intro h;
      · apply isPrimitive_unique hn (rank_pos (by
        exact ⟨ n, hn, h.1 ⟩)) h (rank_primitive (by
        exact ⟨ n, hn, h.1 ⟩));
      · rw [ h ];
        apply rank_primitive;
        contrapose! hn; simp_all +singlePass [ rank ] ;
        exact Set.eq_empty_of_forall_notMem fun k hk => hn ⟨ k, hk ⟩

/-! ## §3. The strong primitive-divisor criterion -/

/-
!-- Lab Notebook: dvd_iff_rank_dvd -- !--
!-- Hypothesis: In a strong divisibility sequence, `p ∣ u m ↔ rank u p ∣ m`. -- !--
!-- Result: `rank_primitive` provides the primitive index `rank u p`; apply
!-- `dvd_iff_index_dvd_of_primitive` from the parent file. -- !--
!-- Insight: The central apparition criterion, now phrased with no external index — the
!-- divisibility set of `p` is exactly the multiples of its rank. -- !--
!-- Failure analysis: requires `p` to appear; otherwise `rank = 0` and the equivalence fails. -- !--
!-- End Lab Notebook -- !--

!-- `dvd_iff_index_dvd_of_primitive hu (rank_pos h) (rank_primitive h) m`. -- !--
-/
theorem dvd_iff_rank_dvd {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {p : ℕ}
    (h : Appears u p) (m : ℕ) : p ∣ u m ↔ rank u p ∣ m := by
      exact StrongDivSeq.dvd_iff_index_dvd_of_primitive hu (rank_pos h) (rank_primitive h) m

/-! ## §4. The join law in ranks -/

/-
!-- Lab Notebook: joint_dvd_iff_lcm_rank_dvd -- !--
!-- Hypothesis: Two appearing divisors both divide `u n` exactly at multiples of the lcm
!-- of their ranks. -- !--
!-- Result: Rewrite each conjunct via `dvd_iff_rank_dvd`, then `Nat.lcm_dvd_iff`. -- !--
!-- Insight: A rank-only form of `simultaneous_apparition`: the joint apparition set is the
!-- apparition class of `lcm (rank u p) (rank u q)`. -- !--
!-- End Lab Notebook -- !--

!-- Two applications of `dvd_iff_rank_dvd` and `Nat.lcm_dvd_iff`. -- !--
-/
theorem joint_dvd_iff_lcm_rank_dvd {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {p q : ℕ}
    (hp : Appears u p) (hq : Appears u q) (n : ℕ) :
    (p ∣ u n ∧ q ∣ u n) ↔ Nat.lcm (rank u p) (rank u q) ∣ n := by
      rw [ dvd_iff_rank_dvd hu hp n, dvd_iff_rank_dvd hu hq n, Nat.lcm_dvd_iff ]

/-! ## §5. Concrete specializations -/

-- !-- Lab Notebook: fib_dvd_iff_rank_dvd -- !--
-- !-- Hypothesis: For Fibonacci, `p ∣ F_m ↔ rank Nat.fib p ∣ m`. -- !--
-- !-- Result: `dvd_iff_rank_dvd` with `fib_isStrongDivSeq`. -- !--
-- !-- Insight: Recovers the Fibonacci law of apparition from the abstract rank. -- !--
-- !-- End Lab Notebook -- !--
theorem fib_dvd_iff_rank_dvd {p : ℕ} (h : Appears Nat.fib p) (m : ℕ) :
    p ∣ Nat.fib m ↔ rank Nat.fib p ∣ m :=
  dvd_iff_rank_dvd fib_isStrongDivSeq h m

-- !-- Lab Notebook: mersenne_dvd_iff_rank_dvd -- !--
-- !-- Hypothesis: For `u n = aⁿ − 1`, `p ∣ aᵐ − 1 ↔ rank ∣ m`. -- !--
-- !-- Result: `dvd_iff_rank_dvd` with `mersenne_isStrongDivSeq`. -- !--
-- !-- Insight: The multiplicative-order law of apparition is the same criterion as Fibonacci's. -- !--
-- !-- End Lab Notebook -- !--
theorem mersenne_dvd_iff_rank_dvd {a p : ℕ} (h : Appears (fun n => a ^ n - 1) p) (m : ℕ) :
    p ∣ a ^ m - 1 ↔ rank (fun n => a ^ n - 1) p ∣ m :=
  dvd_iff_rank_dvd (mersenne_isStrongDivSeq a) h m

end StrongDivSeq