import Mathlib

/-! # The rank of apparition is a lattice (lcm-)morphism

Domain: Number Theory / Applications (Conceptual Unification).

This file extends the *rank of apparition* engine developed in the catalog
(`Catalog/Applications/RankOfApparition.lean` and
`Catalog/Applications/UnifiedRankOfApparition.lean`).  Those files build, for an arbitrary
**strong divisibility sequence** `u` (one with `u (gcd m n) = gcd (u m) (u n)`), the rank
function `rank u`, the *spine* `rank_dvd_iff : m ∣ u n ↔ rank u m ∣ n`, the order-morphism
law `rank_dvd_of_dvd`, the rigidity `rank_self`, and the value biconditionals for Fibonacci
(`F a ∣ F b ↔ a ∣ b`) and Mersenne (`aᵐ−1 ∣ aⁿ−1 ↔ m ∣ n`).

What was *missing* from every catalog thread is the **join law**: how the rank interacts with
`lcm` on the modulus side.  The catalog only ever proved the order-morphism law
(`b ∣ a → rank b ∣ rank a`), i.e. that `rank` is *monotone* for divisibility.  Here we prove
the sharp structural statement that `rank` is in fact a **homomorphism of join-semilattices**
`(ℕ_{>0}, lcm) → (ℕ_{>0}, lcm)`:

* `rank_lcm`           — *new, generic*: `rank u (lcm a b) = lcm (rank u a) (rank u b)`,
  from the bare `IsStrongDivSeq` hypothesis and existence of `rank u a`, `rank u b`
  (existence of the rank of `lcm a b` is *derived*, `hasRank_lcm`, not assumed).
* `rank_mul_coprime`   — *new corollary*: for coprime `a, b`,
  `rank u (a * b) = lcm (rank u a) (rank u b)` (the multiplicative entry-point law).
* `fibRank_lcm`        — *new instance*: `rank F (lcm a b) = lcm (rank F a) (rank F b)` for
  `a, b ≥ 1` (the classical *Fibonacci entry point of an lcm*; totality comes from the
  Pisano pigeonhole `fib_hasRank`, copied from `RankOfApparition`).
* `mersenne_rank_lcm`  — *new cross-domain instance*: in the Mersenne sequence `k ↦ aᵏ − 1`,
  `rank (lcm (aᵐ−1) (aⁿ−1)) = lcm m n` for `a ≥ 2`, `m, n ≥ 1`.

The point is conceptual: the **same** join law specialises to Fibonacci and to `aⁿ−1`, two
sequences with no surface resemblance, because both are strong divisibility sequences.  This
is the lattice-theoretic core of the "Law of Apparition" duality flagged in the catalog's
`FUTURE_DIRECTIONS` synthesis.

The file is self-contained against Mathlib (the catalog's `import` graph is fragmented), so it
restates the small engine core it uses, in the established style of the catalog.
-/

namespace RankLat

open scoped Classical

/-- A **strong divisibility sequence**: `u (gcd m n) = gcd (u m) (u n)` for all `m, n`.
(Same notion as in `UnifiedRankOfApparition`; restated for self-containment.) -/
def IsStrongDivSeq (u : ℕ → ℕ) : Prop := ∀ m n, u (Nat.gcd m n) = Nat.gcd (u m) (u n)

-- !-- A strong divisibility sequence is a divisibility sequence:
-- !-- `m ∣ n` gives `gcd m n = m`, so `u m = gcd (u m) (u n) ∣ u n`. -- !--
theorem IsStrongDivSeq.dvd_of_dvd {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {m n : ℕ}
    (h : m ∣ n) : u m ∣ u n := by
  have hg : Nat.gcd m n = m := Nat.gcd_eq_left h
  have hmn := hu m n
  rw [hg] at hmn; rw [hmn]; exact Nat.gcd_dvd_right _ _

/-! ## §1. The rank function (engine core, restated) -/

/-- `m` *has a rank of apparition* for `u` if it divides some positive-index value `u k`. -/
def HasRank (u : ℕ → ℕ) (m : ℕ) : Prop := ∃ k, 0 < k ∧ m ∣ u k

/-- The rank of apparition of `m` in `u`: the least positive `k` with `m ∣ u k`
(or `0` if none exists). -/
noncomputable def rank (u : ℕ → ℕ) (m : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ m ∣ u k then Nat.find h else 0

theorem rank_pos {u : ℕ → ℕ} {m : ℕ} (hm : HasRank u m) : 0 < rank u m := by
  unfold rank; split_ifs with h
  · exact (Nat.find_spec h).1
  · exact absurd hm h

theorem dvd_rank {u : ℕ → ℕ} {m : ℕ} (hm : HasRank u m) : m ∣ u (rank u m) := by
  unfold rank; split_ifs with h
  · exact (Nat.find_spec h).2
  · exact absurd hm h

theorem rank_min {u : ℕ → ℕ} {m k : ℕ} (hk : 0 < k) (hlt : k < rank u m) : ¬ m ∣ u k := by
  unfold rank at hlt; split_ifs at hlt with h
  · exact fun hd => Nat.find_min h hlt ⟨hk, hd⟩
  · simp at hlt

-- !-- The spine `m ∣ u n ↔ rank u m ∣ n`: (←) weak law + `m ∣ u(rank)`; (→) push `m` into the
-- !-- meet law and use minimality of the rank to force `gcd (rank) n = rank`. -- !--
theorem rank_dvd_iff {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {m : ℕ} (hm : HasRank u m) (n : ℕ) :
    m ∣ u n ↔ rank u m ∣ n := by
  have hz : 0 < rank u m := rank_pos hm
  have hmz : m ∣ u (rank u m) := dvd_rank hm
  constructor <;> intro hn
  · contrapose! hn
    have hgcd_lt : Nat.gcd (rank u m) n < rank u m :=
      lt_of_le_of_ne (Nat.le_of_dvd hz (Nat.gcd_dvd_left _ _))
        (fun h => hn (h ▸ Nat.gcd_dvd_right _ _))
    refine fun hcontra => rank_min (Nat.gcd_pos_of_pos_left _ hz) hgcd_lt ?_
    have := Nat.dvd_gcd hmz hcontra
    rw [hu]; exact this
  · obtain ⟨k, rfl⟩ := hn
    exact dvd_trans hmz (hu.dvd_of_dvd ⟨k, rfl⟩)

-- !-- Rigidity `rank u (u k) = k` under positivity + strict growth below `k`
-- !-- (`Nat.find_eq_iff`: `u k ∣ u k`; for `0 < j < k`, `0 < u j < u k` blocks division). -- !--
theorem rank_self {u : ℕ → ℕ} {k : ℕ} (hk : 0 < k)
    (hpos : ∀ j, 0 < j → 0 < u j) (hgrow : ∀ j, 0 < j → j < k → u j < u k) :
    rank u (u k) = k := by
  have hhas : ∃ j, 0 < j ∧ u k ∣ u j := ⟨k, hk, dvd_rfl⟩
  unfold rank
  rw [dif_pos hhas, Nat.find_eq_iff]
  refine ⟨⟨hk, dvd_rfl⟩, ?_⟩
  intro j hj hcontra
  obtain ⟨hj0, hdvd⟩ := hcontra
  exact Nat.not_dvd_of_pos_of_lt (hpos j hj0) (hgrow j hj0 hj) hdvd

/-! ## §2. NEW — existence of the rank of an lcm -/

/-
!-- Lab Notebook: hasRank_lcm -- !--
!-- Hypothesis: If `a` and `b` both have ranks for `u`, then so does `lcm a b` — no global
totality assumption needed. -- !--
!-- Result: Proved. Let `k = lcm (rank a) (rank b)`. Since `rank a ∣ k`, the weak law gives
`a ∣ u(rank a) ∣ u k`; symmetrically `b ∣ u k`; hence `lcm a b ∣ u k`, and `k > 0`. -- !--
!-- Insight: existence of ranks is closed under `lcm`, so the join law `rank_lcm` never has to
postulate the rank of the join — it manufactures the witness from the two given ranks. -- !--
!-- Failure analysis: needs the weak law `dvd_of_dvd`, i.e. that `u` is a divisibility
sequence (a free consequence of `IsStrongDivSeq`). -- !--
!-- End Lab Notebook -- !--
-/
theorem hasRank_lcm {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {a b : ℕ}
    (ha : HasRank u a) (hb : HasRank u b) : HasRank u (Nat.lcm a b) := by
  have hra : 0 < rank u a := rank_pos ha
  have hrb : 0 < rank u b := rank_pos hb
  set k := Nat.lcm (rank u a) (rank u b) with hk
  have hkpos : 0 < k := Nat.lcm_pos hra hrb
  have haL : a ∣ u k := dvd_trans (dvd_rank ha) (hu.dvd_of_dvd (Nat.dvd_lcm_left _ _))
  have hbL : b ∣ u k := dvd_trans (dvd_rank hb) (hu.dvd_of_dvd (Nat.dvd_lcm_right _ _))
  exact ⟨k, hkpos, Nat.lcm_dvd haL hbL⟩

/-! ## §3. NEW — the join (lcm-)morphism law -/

/-
!-- Lab Notebook: rank_lcm -- !--
!-- Hypothesis: `rank` is a join-semilattice morphism for divisibility:
`rank u (lcm a b) = lcm (rank u a) (rank u b)`. -- !--
!-- Result: Proved by divisibility-antisymmetry, all four legs via the spine + `Nat.lcm_dvd`.
`r ∣ L`: `lcm a b ∣ u L` because `a ∣ u L` and `b ∣ u L` (spine: `rank a ∣ L`, `rank b ∣ L`),
then spine for `lcm a b`. `L ∣ r`: `rank a ∣ r` and `rank b ∣ r` because `a, b ∣ lcm a b ∣ u r`
(spine again). -- !--
!-- Insight: This upgrades the catalog's *monotone* order-morphism `rank_dvd_of_dvd` to a full
*join homomorphism*. Both ranks `r` and `L` cut out the exact same principal ideal of indices,
so the spine forces them equal — the load-bearing structural fact of apparition. -- !--
!-- Failure analysis: the dual `gcd` law fails in general (gcd of the moduli need not have rank
gcd of the ranks), so only the join law holds — a genuine asymmetry, not an oversight. -- !--
!-- End Lab Notebook -- !--
-/
theorem rank_lcm {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {a b : ℕ}
    (ha : HasRank u a) (hb : HasRank u b) :
    rank u (Nat.lcm a b) = Nat.lcm (rank u a) (rank u b) := by
  have hab : HasRank u (Nat.lcm a b) := hasRank_lcm hu ha hb
  apply Nat.dvd_antisymm
  · rw [← rank_dvd_iff hu hab]
    refine Nat.lcm_dvd ?_ ?_
    · rw [rank_dvd_iff hu ha]; exact Nat.dvd_lcm_left _ _
    · rw [rank_dvd_iff hu hb]; exact Nat.dvd_lcm_right _ _
  · refine Nat.lcm_dvd ?_ ?_
    · rw [← rank_dvd_iff hu ha]; exact dvd_trans (Nat.dvd_lcm_left _ _) (dvd_rank hab)
    · rw [← rank_dvd_iff hu hb]; exact dvd_trans (Nat.dvd_lcm_right _ _) (dvd_rank hab)

/-
!-- Lab Notebook: rank_mul_coprime -- !--
!-- Hypothesis: for coprime `a, b`, `rank u (a * b) = lcm (rank u a) (rank u b)`. -- !--
!-- Result: Proved. Coprimality gives `lcm a b = a * b` (`Nat.Coprime.lcm_eq_mul`), so this is
`rank_lcm` rewritten. -- !--
!-- Insight: the multiplicative entry-point law (e.g. the classical formula for the Fibonacci
entry point of a coprime product) is a one-line corollary of the join morphism. -- !--
!-- Failure analysis: coprimality is essential; without it `lcm a b ≠ a * b`. -- !--
!-- End Lab Notebook -- !--
-/
theorem rank_mul_coprime {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {a b : ℕ}
    (hco : Nat.Coprime a b) (ha : HasRank u a) (hb : HasRank u b) :
    rank u (a * b) = Nat.lcm (rank u a) (rank u b) := by
  rw [← hco.lcm_eq_mul]; exact rank_lcm hu ha hb

/-! ## §4. Instance I — Fibonacci -/

/-- The Fibonacci "shift" permutation on `ZMod m × ZMod m`; reversibility drives apparition.
(Copied from `RankOfApparition` for self-containment.) -/
def fibStep (m : ℕ) : ZMod m × ZMod m ≃ ZMod m × ZMod m where
  toFun p := (p.2, p.1 + p.2)
  invFun p := (p.2 - p.1, p.1)
  left_inv := by intro p; simp
  right_inv := by intro p; simp [add_comm]

-- !-- Lab Notebook: fib_hasRank -- !--
-- !-- Hypothesis: every positive modulus has a Fibonacci rank (apparition is total). -- !--
-- !-- Result: pigeonhole on the finite `(ZMod m)²`; back-step a repeated pair to `(0,1)` via
-- the reversible shift to get `0 < k` with `m ∣ F k`. (Copied from `RankOfApparition`.) -- !--
-- !-- Insight: totality is what lets `fibRank_lcm` quantify over all positive `a, b`. -- !--
-- !-- Failure analysis: the `m = 0` `ZMod` case is split off. -- !--
-- !-- End Lab Notebook -- !--
theorem fib_hasRank {m : ℕ} (hm : 0 < m) : HasRank Nat.fib m := by
  obtain ⟨i, j, hij, h_pair⟩ :
      ∃ i j : ℕ, i < j ∧
        ((Nat.fib i : ZMod m) = (Nat.fib j : ZMod m) ∧
          (Nat.fib (i + 1) : ZMod m) = (Nat.fib (j + 1) : ZMod m)) := by
    have h_pigeonhole :
        ∃ i j : ℕ, i < j ∧
          ((Nat.fib i : ZMod m), (Nat.fib (i + 1) : ZMod m))
            = ((Nat.fib j : ZMod m), (Nat.fib (j + 1) : ZMod m)) := by
      by_contra! h
      have h_finite :
          Set.Finite (Set.range
            (fun n : ℕ => ((Nat.fib n : ZMod m), (Nat.fib (n + 1) : ZMod m)))) := by
        cases m <;> [ aesop; exact Set.toFinite _ ]
      exact h_finite.not_infinite <| Set.infinite_range_of_injective fun i j hij =>
        le_antisymm (le_of_not_gt fun hi => h _ _ hi hij.symm)
          (le_of_not_gt fun hj => h _ _ hj hij)
    aesop
  induction' i with i ih generalizing j
  · exact ⟨ j, hij, by simpa [ ← ZMod.natCast_eq_zero_iff ] using h_pair.1.symm ⟩
  · specialize ih ( j - 1 ) ( Nat.lt_pred_iff.mpr hij )
    rcases j <;> simp_all +decide [ Nat.fib_add_two ]
    grind

-- !-- Fibonacci is a strong divisibility sequence by `Nat.fib_gcd`. -- !--
theorem fib_isStrongDivSeq : IsStrongDivSeq Nat.fib := fun m n => Nat.fib_gcd m n

/-
!-- Lab Notebook: fibRank_lcm -- !--
!-- Hypothesis: `rank F (lcm a b) = lcm (rank F a) (rank F b)` for all `a, b ≥ 1`
(the Fibonacci entry point of an lcm). -- !--
!-- Result: instance of `rank_lcm` with `u = Nat.fib`; ranks exist by `fib_hasRank`. -- !--
!-- Insight: the classical "entry point of lcm is lcm of entry points" is now a one-line
specialisation of the generic join morphism. -- !--
!-- Failure analysis: needs `a, b ≥ 1` for totality. -- !--
!-- End Lab Notebook -- !--
-/
theorem fibRank_lcm {a b : ℕ} (ha : 0 < a) (hb : 0 < b) :
    rank Nat.fib (Nat.lcm a b) = Nat.lcm (rank Nat.fib a) (rank Nat.fib b) :=
  rank_lcm fib_isStrongDivSeq (fib_hasRank ha) (fib_hasRank hb)

/-! ## §5. Instance II — Mersenne / `aⁿ − 1` (cross-domain corollary) -/

-- !-- The Mersenne sequence `n ↦ aⁿ − 1` is a strong divisibility sequence. -- !--
theorem mersenne_isStrongDivSeq (a : ℕ) : IsStrongDivSeq (fun n => a ^ n - 1) := by
  intro m n
  by_cases ha : a = 0 <;> simp_all +decide [Nat.pow_sub_one_gcd_pow_sub_one]

-- !-- Lab Notebook: mersenne_rank_value -- !--
-- !-- Hypothesis: `rank (·↦ aᵏ−1) (aᵏ−1) = k` for `a ≥ 2`, `k ≥ 1`. -- !--
-- !-- Result: instance of `rank_self`; positivity `1 < aʲ` and strict growth from
-- `Nat.pow_lt_pow_right`. -- !--
-- !-- Insight: each Mersenne value is rank-rigid, so the lcm law reads off the indices. -- !--
-- !-- Failure analysis: `a ≤ 1` collapses the sequence; `k = 0` gives `a⁰−1 = 0`. -- !--
-- !-- End Lab Notebook -- !--
theorem mersenne_rank_value {a k : ℕ} (ha : 2 ≤ a) (hk : 0 < k) :
    rank (fun n => a ^ n - 1) (a ^ k - 1) = k := by
  have h := rank_self (u := fun n => a ^ n - 1) (k := k) hk
    (by intro j hj
        show 0 < a ^ j - 1
        have : 1 < a ^ j := Nat.one_lt_pow (by omega) (by omega); omega)
    (by intro j hj0 hj
        show a ^ j - 1 < a ^ k - 1
        have h1 : a ^ j < a ^ k := Nat.pow_lt_pow_right (by omega) hj
        have h2 : 1 < a ^ j := Nat.one_lt_pow (by omega) (by omega); omega)
  simpa using h

/-
!-- Lab Notebook: mersenne_rank_lcm -- !--
!-- Hypothesis: `rank (·↦ aᵏ−1) (lcm (aᵐ−1) (aⁿ−1)) = lcm m n` for `a ≥ 2`, `m, n ≥ 1`. -- !--
!-- Result: `rank_lcm` for the Mersenne SDS, with the two ranks computed by
`mersenne_rank_value`. -- !--
!-- Insight: the SAME join law that gives the Fibonacci lcm-entry-point gives the Mersenne one —
a genuine cross-domain bridge through `IsStrongDivSeq`, with no growth/Pisano theory in common. -- !--
!-- Failure analysis: `a ≤ 1` or `m = 0`/`n = 0` break rank-rigidity. -- !--
!-- End Lab Notebook -- !--
-/
theorem mersenne_rank_lcm {a m n : ℕ} (ha : 2 ≤ a) (hm : 0 < m) (hn : 0 < n) :
    rank (fun k => a ^ k - 1) (Nat.lcm (a ^ m - 1) (a ^ n - 1)) = Nat.lcm m n := by
  have hsm : HasRank (fun k => a ^ k - 1) (a ^ m - 1) := ⟨m, hm, dvd_rfl⟩
  have hsn : HasRank (fun k => a ^ k - 1) (a ^ n - 1) := ⟨n, hn, dvd_rfl⟩
  rw [rank_lcm (mersenne_isStrongDivSeq a) hsm hsn,
      mersenne_rank_value ha hm, mersenne_rank_value ha hn]

end RankLat