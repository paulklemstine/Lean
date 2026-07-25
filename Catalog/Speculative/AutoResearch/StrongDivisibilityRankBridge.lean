import Mathlib

/-! # The abstract rank of apparition for strong divisibility sequences,
and its identification with the multiplicative order

Domain: Number Theory / Algebra (cross-domain bridge).

The catalog develops the *rank of apparition* `r(p) = min { k > 0 : p ∣ F(k) }` for the
Fibonacci sequence (`Catalog/Applications/RankOfApparition.lean`: `fibRank`, the spine
`m ∣ F n ↔ r(m) ∣ n`, `fibRank_fib`, `fib_prime_index_has_primitive`) and separately a
*structure-only* theory of strong divisibility sequences
(`Catalog/Applications/StrongDivisibilitySequences.lean`: `IsStrongDivSeq`, `IsPrimitive`,
`isPrimitive_unique`, `dvd_iff_index_dvd_of_primitive`, the counting laws).  The latter file
has **no rank function** and the former is **Fibonacci-specific**.

This file unifies the two: it equips an *arbitrary* strong divisibility sequence `u` with a
rank-of-apparition function `seqRank u`, proves the spine and the primitivity
characterization at this level of generality (so they specialise to Fibonacci, Mersenne,
Lucas, … verbatim), and then closes a genuinely cross-domain loop:

> **For the Mersenne family `u(n) = aⁿ − 1`, the rank of apparition of `m` is exactly the
> multiplicative order of `a` modulo `m`** (`seqRank_mer_eq_orderOf`).

Thus the divisibility-theoretic invariant `r(m)` and the group-theoretic invariant
`orderOf (a : ZMod m)` are *the same number*.  This realises **Direction 3** ("generalisation
to Lucas / strong divisibility sequences") of the previous cycle's `FUTURE_DIRECTIONS.md`,
and connects it to the order theory of `ZMod m`.

Main results (all `sorry`-free):

* `seqRank_spine`             — `m ∣ u n ↔ seqRank u m ∣ n`, for any strong divisibility
  sequence `u` in which `m` has a rank.  The abstract version of the catalog's Fibonacci spine.
* `isPrimitive_iff_seqRank_eq` — `IsPrimitive u p n ↔ seqRank u p = n` (for `0 < n`):
  a value is a primitive divisor of `u n` iff its rank is exactly `n`.
* `mer_dvd_iff_orderOf_dvd`   — `m ∣ aⁿ − 1 ↔ orderOf (a : ZMod m) ∣ n`.
* `seqRank_mer_eq_orderOf`    — `seqRank (fun n => aⁿ − 1) m = orderOf (a : ZMod m)`
  for `1 ≤ a`, `0 < m`, `Nat.Coprime a m`: rank of apparition = multiplicative order.

-/

namespace StrongDivRankBridge

/-! ## §0. The abstract setting -/

/-- A **strong divisibility sequence**: `u (gcd m n) = gcd (u m) (u n)` for all `m, n`.
Both `Nat.fib` and `n ↦ aⁿ − 1` satisfy this. -/
def IsStrongDivSeq (u : ℕ → ℕ) : Prop := ∀ m n, u (Nat.gcd m n) = Nat.gcd (u m) (u n)

/-- `m` *has a rank* in `u` if it divides some positive-index term. -/
def HasRank (u : ℕ → ℕ) (m : ℕ) : Prop := ∃ k, 0 < k ∧ m ∣ u k

/-- `p` is a *primitive divisor* of `u n`: it divides `u n` but none of `u 1, …, u (n-1)`. -/
def IsPrimitive (u : ℕ → ℕ) (p n : ℕ) : Prop :=
  p ∣ u n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ u k

/-
!-- Lab Notebook: IsStrongDivSeq.dvd_of_dvd -- !--
!-- Hypothesis: A strong divisibility sequence is a divisibility sequence: `m ∣ n → u m ∣ u n`. -- !--
!-- Result: Proved. `m ∣ n` gives `gcd m n = m`, so `u m = gcd (u m) (u n) ∣ u n`. -- !--
!-- Insight: The *weak* law is a free corollary of the *strong* law; this is the only
divisibility fact the backward direction of the spine needs. -- !--
!-- Failure analysis: none. -- !--
!-- End Lab Notebook -- !--
-/
-- !-- `gcd m n = m` (from `m ∣ n`), rewrite the strong law, then `Nat.gcd_dvd_right`. -- !--
theorem IsStrongDivSeq.dvd_of_dvd {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {m n : ℕ}
    (h : m ∣ n) : u m ∣ u n := by
  have h_gcd : Nat.gcd m n = m := Nat.gcd_eq_left h
  have := hu m n
  rw [h_gcd] at this
  rw [this]
  exact Nat.gcd_dvd_right _ _

/-! ## §1. The abstract rank-of-apparition function -/

open scoped Classical in
/-- The rank of apparition of `m` in the sequence `u`: the least positive `k` with `m ∣ u k`
(or `0` if no such `k` exists). -/
noncomputable def seqRank (u : ℕ → ℕ) (m : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ m ∣ u k then Nat.find h else 0

theorem seqRank_pos {u : ℕ → ℕ} {m : ℕ} (hm : HasRank u m) : 0 < seqRank u m := by
  unfold seqRank; split_ifs with h
  · exact (Nat.find_spec h).1
  · exact absurd hm h

theorem dvd_seqRank {u : ℕ → ℕ} {m : ℕ} (hm : HasRank u m) : m ∣ u (seqRank u m) := by
  unfold seqRank; split_ifs with h
  · exact (Nat.find_spec h).2
  · exact absurd hm h

theorem seqRank_min {u : ℕ → ℕ} {m k : ℕ} (hk : 0 < k) (hlt : k < seqRank u m) :
    ¬ m ∣ u k := by
  unfold seqRank at hlt; split_ifs at hlt with h
  · exact fun hd => Nat.find_min h hlt ⟨hk, hd⟩
  · simp at hlt

/-! ## §2. The spine: `m ∣ u n ↔ seqRank u m ∣ n` -/

/-
!-- Lab Notebook: seqRank_spine -- !--
!-- Hypothesis: For any strong divisibility sequence in which `m` has a rank,
`m ∣ u n ↔ seqRank u m ∣ n` (the abstract version of `RankOfApparition.fibRank_dvd_iff`). -- !--
!-- Result: Proved. (←) `seqRank u m ∣ n → u (seqRank) ∣ u n` (`dvd_of_dvd`) and
`m ∣ u (seqRank)`. (→) push `m` into `u (gcd (seqRank) n) = gcd (u …) (u n)` (strong law);
if `seqRank ∤ n` the gcd index is positive and `< seqRank`, contradicting minimality. -- !--
!-- Insight: The proof uses ONLY the strong-divisibility hypothesis — nothing Fibonacci-
specific — so the catalog's whole apparition theory is an instance of this one biconditional. -- !--
!-- Failure analysis: needs `HasRank u m` so the rank is positive. -- !--
!-- End Lab Notebook -- !--
-/
theorem seqRank_spine {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {m : ℕ} (hm : HasRank u m) (n : ℕ) :
    m ∣ u n ↔ seqRank u m ∣ n := by
  have hz : 0 < seqRank u m := seqRank_pos hm
  have hmz : m ∣ u (seqRank u m) := dvd_seqRank hm
  constructor <;> intro hn
  · contrapose! hn
    have hgcd_lt : Nat.gcd (seqRank u m) n < seqRank u m :=
      lt_of_le_of_ne (Nat.le_of_dvd hz (Nat.gcd_dvd_left _ _))
        (fun h => hn (h ▸ Nat.gcd_dvd_right _ _))
    refine fun hcontra => seqRank_min (Nat.gcd_pos_of_pos_left _ hz) hgcd_lt ?_
    have := Nat.dvd_gcd hmz hcontra
    rw [← hu] at this
    exact this
  · obtain ⟨k, rfl⟩ := hn
    exact dvd_trans hmz (hu.dvd_of_dvd ⟨k, rfl⟩)

/-! ## §3. Primitivity ⟺ the rank equals the index -/

/-
!-- Lab Notebook: isPrimitive_iff_seqRank_eq -- !--
!-- Hypothesis: `IsPrimitive u p n ↔ seqRank u p = n` for `0 < n`. -- !--
!-- Result: Proved. (→) `p ∣ u n` gives `seqRank ∣ n` (spine), so `seqRank ≤ n`; if it were
`< n`, primitivity would forbid `p ∣ u (seqRank)`, contradicting `dvd_seqRank`. (←) with
`seqRank = n`: `p ∣ u n` is `dvd_seqRank`, and minimality of the rank gives the no-earlier
clause. -- !--
!-- Insight: This is the conceptual core "primitive divisor exists ↔ some value has rank
exactly n", the abstract form of `fibRank_eq_iff_primitive` flagged in the synthesis. -- !--
!-- Failure analysis: index `0` must be excluded; `seqRank u p = 0` would mean no rank. -- !--
!-- End Lab Notebook -- !--
-/
theorem isPrimitive_iff_seqRank_eq {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {p n : ℕ}
    (hp : HasRank u p) (hn : 0 < n) : IsPrimitive u p n ↔ seqRank u p = n := by
  constructor
  · rintro ⟨hpn, hmin⟩
    have hle : seqRank u p ≤ n := Nat.le_of_dvd hn ((seqRank_spine hu hp n).1 hpn)
    rcases lt_or_eq_of_le hle with hlt | heq
    · exact absurd (dvd_seqRank hp) (hmin _ (seqRank_pos hp) hlt)
    · exact heq
  · intro heq
    refine ⟨heq ▸ dvd_seqRank hp, fun k hk hkn => ?_⟩
    exact seqRank_min hk (heq ▸ hkn)

/-! ## §4. Instance: the Fibonacci sequence -/

/-
!-- Lab Notebook: fib_isStrongDivSeq -- !--
!-- Hypothesis: `Nat.fib` is a strong divisibility sequence. -- !--
!-- Result: Immediate from `Nat.fib_gcd`. -- !--
!-- Insight: Specialising `seqRank_spine`/`isPrimitive_iff_seqRank_eq` to `Nat.fib` recovers
the catalog's Fibonacci rank theory (`RankOfApparition.fibRank_dvd_iff`); existence of the
rank for every positive modulus is the pigeonhole argument in that file. -- !--
!-- End Lab Notebook -- !--
-/
theorem fib_isStrongDivSeq : IsStrongDivSeq Nat.fib := fun m n => Nat.fib_gcd m n

/-! ## §5. Instance + bridge: the Mersenne family `aⁿ − 1` and the multiplicative order -/

/-- The Mersenne-type sequence `mer a n = aⁿ − 1`. -/
def mer (a : ℕ) : ℕ → ℕ := fun n => a ^ n - 1

/-
!-- Lab Notebook: mer_isStrongDivSeq -- !--
!-- Hypothesis: `n ↦ aⁿ − 1` is a strong divisibility sequence, for every base `a`. -- !--
!-- Result: Immediate from `Nat.pow_sub_one_gcd_pow_sub_one`. -- !--
!-- Insight: The same rank/primitivity machinery governs the `aⁿ−1` family, including all
Mersenne numbers (`a = 2`). -- !--
!-- End Lab Notebook -- !--
-/
theorem mer_isStrongDivSeq (a : ℕ) : IsStrongDivSeq (mer a) := by
  intro m n
  simp only [mer]
  rw [Nat.pow_sub_one_gcd_pow_sub_one]

/-
!-- Lab Notebook: mer_dvd_iff_pow_eq_one -- !--
!-- Hypothesis: `m ∣ aⁿ − 1 ↔ (a : ZMod m)ⁿ = 1`, for `1 ≤ a`. -- !--
!-- Result: Proved. Recast `m ∣ aⁿ−1` as `(↑(aⁿ−1) : ZMod m) = 0` (`ZMod.natCast_eq_zero_iff`),
then `push_cast` with `Nat.cast_pred` (using `0 < aⁿ`) turns it into `(↑a)ⁿ − 1 = 0`. -- !--
!-- Insight: This is the precise dictionary entry translating divisibility of `aⁿ−1` into the
`ZMod m` power equation — the doorway from number theory to group theory. -- !--
!-- Failure analysis: `1 ≤ a` is needed so `aⁿ ≥ 1` and `Nat.cast_pred` applies. -- !--
!-- End Lab Notebook -- !--
-/
theorem mer_dvd_iff_pow_eq_one (a m n : ℕ) (ha : 1 ≤ a) :
    m ∣ mer a n ↔ (a : ZMod m) ^ n = 1 := by
  simp only [mer]
  rw [← (ZMod.natCast_eq_zero_iff (a ^ n - 1) m)]
  push_cast [Nat.cast_pred (by positivity : 0 < a ^ n)]
  constructor <;> intro h <;> linear_combination h

/-
!-- Lab Notebook: mer_dvd_iff_orderOf_dvd -- !--
!-- Hypothesis: `m ∣ aⁿ − 1 ↔ orderOf (a : ZMod m) ∣ n`, for `1 ≤ a`. -- !--
!-- Result: Proved by composing `mer_dvd_iff_pow_eq_one` with `orderOf_dvd_iff_pow_eq_one`. -- !--
!-- Insight: The apparition set of `m` in the Mersenne sequence is exactly the multiples of
the multiplicative order of `a mod m` — divisibility data = group-order data. -- !--
!-- Failure analysis: none beyond `1 ≤ a`. -- !--
!-- End Lab Notebook -- !--
-/
theorem mer_dvd_iff_orderOf_dvd (a m n : ℕ) (ha : 1 ≤ a) :
    m ∣ mer a n ↔ orderOf (a : ZMod m) ∣ n := by
  rw [mer_dvd_iff_pow_eq_one a m n ha, orderOf_dvd_iff_pow_eq_one]

/-
!-- Lab Notebook: mer_hasRank_of_coprime -- !--
!-- Hypothesis: If `1 ≤ a`, `0 < m` and `gcd a m = 1`, then `m` has a rank in `aⁿ − 1`. -- !--
!-- Result: Proved with Euler's theorem: `a^φ(m) ≡ 1 [MOD m]` (`Nat.ModEq.pow_totient`), so
`m ∣ a^φ(m) − 1` (`Nat.modEq_iff_dvd'`), and `φ(m) > 0` (`Nat.totient_pos`). -- !--
!-- Insight: Coprimality is exactly the condition for the rank to exist — i.e. for `a` to be a
unit mod `m`; the witness is Euler's totient. -- !--
!-- Failure analysis: without coprimality `a` is a zero-divisor mod `m` and may never be `1`. -- !--
!-- End Lab Notebook -- !--
-/
theorem mer_hasRank_of_coprime {a m : ℕ} (ha : 1 ≤ a) (hm : 0 < m) (hco : Nat.Coprime a m) :
    HasRank (mer a) m := by
  refine ⟨m.totient, Nat.totient_pos.2 hm, ?_⟩
  simp only [mer]
  have hmod : a ^ m.totient ≡ 1 [MOD m] := Nat.ModEq.pow_totient hco
  exact (Nat.modEq_iff_dvd' (Nat.one_le_pow _ _ ha)).1 hmod.symm

/-
!-- Lab Notebook: seqRank_mer_eq_orderOf -- !--
!-- Hypothesis: `seqRank (mer a) m = orderOf (a : ZMod m)` for `1 ≤ a`, `0 < m`, coprime. -- !--
!-- Result: Proved. Both the abstract spine (`seqRank_spine` for `mer a`, valid since `mer a`
is a strong divisibility sequence and `m` has a rank) and `mer_dvd_iff_orderOf_dvd` say
`m ∣ mer a n ↔ X ∣ n`; matching them gives `seqRank ∣ n ↔ orderOf ∣ n` for all `n`. Taking
`n` to be each side yields mutual divisibility, hence equality (`Nat.dvd_antisymm`). -- !--
!-- Insight: The rank of apparition (a least-witness / divisibility invariant) and the
multiplicative order (a group invariant) are literally the same natural number. This is the
cross-domain payoff: number-theoretic apparition theory = order theory in `ZMod m`. -- !--
!-- Failure analysis: needs `HasRank` (hence coprimality) to invoke the spine; for non-units
`orderOf = 0 = seqRank` as well, but the clean statement assumes coprimality. -- !--
!-- End Lab Notebook -- !--
-/
theorem seqRank_mer_eq_orderOf {a m : ℕ} (ha : 1 ≤ a) (hm : 0 < m) (hco : Nat.Coprime a m) :
    seqRank (mer a) m = orderOf (a : ZMod m) := by
  have hr : HasRank (mer a) m := mer_hasRank_of_coprime ha hm hco
  have key : ∀ n, seqRank (mer a) m ∣ n ↔ orderOf (a : ZMod m) ∣ n := by
    intro n
    rw [← seqRank_spine (mer_isStrongDivSeq a) hr n, mer_dvd_iff_orderOf_dvd a m n ha]
  exact Nat.dvd_antisymm ((key _).2 dvd_rfl) ((key _).1 dvd_rfl)

end StrongDivRankBridge