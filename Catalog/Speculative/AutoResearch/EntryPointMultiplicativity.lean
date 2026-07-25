import Mathlib

/-!
# Multiplicativity of the rank of apparition in strong divisibility sequences

Domain: Number Theory (Applications / cross-domain).

This file **extends** the catalog's strong-divisibility-sequence program — namely
`Catalog/Applications/StrongDivisibilitySequences.lean` (`StrongDivSeq.IsStrongDivSeq`,
the meet law `dvd_gcd_index_iff`, the rigidity result `isPrimitive_unique`) and
`Catalog/Novelty/FibonacciEntryPointInvariant.lean` (`StrongDivSeq.entry`,
`entry_dvd`, `primitive_divisor_inj`).  Those files established the *gcd-side* of the
entry-point ("rank of apparition") lattice morphism and proved a fixed modulus is a
primitive divisor of at most one index.

The two facts that were **only available for the Fibonacci sequence** in the catalog
(via the — currently missing — `FibonacciApparition` module: the law of apparition
`fib_dvd_iff_fibEntry_dvd` and the coprime multiplicativity `fibEntry_mul_coprime`) are
here proved **abstractly**, for an arbitrary strong divisibility sequence, depending on
nothing but the renormalization identity `gcd (u m) (u n) = u (gcd m n)` and the boundary
value `u 0 = 0`.  This is a genuine generalization and a self-contained replacement for the
broken Fibonacci-specific chain.

## Main results

* `RankOfApparition.dvd_iff_entry_dvd` — **the abstract law of apparition**: for a modulus
  `m` that appears, `m ∣ u k ↔ entry u m ∣ k` for *every* `k` (the bridge that turns a
  divisibility question about terms into an arithmetic question about indices).
* `RankOfApparition.entry_eq_of_dvd_iff` — **rigidity**: the entry point is the unique
  positive number whose multiples are exactly the indices of appearance.
* `RankOfApparition.entry_dvd_entry_of_dvd` — **lattice morphism (order side)**: `d ∣ m`
  implies `entry u d ∣ entry u m`; the entry map is monotone for divisibility on moduli.
* `RankOfApparition.entry_mul_coprime` — **the join law / multiplicativity**: for coprime
  moduli `a, b` that appear, `entry u (a*b) = lcm (entry u a) (entry u b)`.  This is the
  dual of the catalog's `gcd ↦ gcd` half and reduces all entry-point computation to the
  prime-power case.

## Concrete instantiations (cross-domain)

* `RankOfApparition.mersenne_entry_mul_coprime` — for the Mersenne/repunit family
  `u n = a^n - 1` (a strong divisibility sequence by `Nat.pow_sub_one_gcd_pow_sub_one`),
  the rank of apparition is multiplicative on coprime moduli.  Since here `entry` is the
  multiplicative order, this *is* the classical fact `ord_{a*b} = lcm (ord_a) (ord_b)`.
* `RankOfApparition.fib_entry_mul_coprime` — the Fibonacci specialization (via
  `Nat.fib_gcd`), recovering the catalog's `fibEntry_mul_coprime` from the abstract theorem.
-/

namespace RankOfApparition

open Classical

/-- A **strong divisibility sequence**: `gcd (u m) (u n) = u (gcd m n)` (the
"renormalization" / self-similarity identity).  Both `Nat.fib` and `n ↦ aⁿ − 1` satisfy it.
This is the `Hgcd`-shaped restatement of `StrongDivSeq.IsStrongDivSeq`. -/
def IsSDS (u : ℕ → ℕ) : Prop := ∀ m n, Nat.gcd (u m) (u n) = u (Nat.gcd m n)

/-- The **entry point** (rank of apparition) of `m` in `u`: the least `k > 0` with
`m ∣ u k`, or `0` if no such index exists. -/
noncomputable def entry (u : ℕ → ℕ) (m : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ m ∣ u k then Nat.find h else 0

/-- `m` **appears** in `u`: it divides some positive term. -/
def Appears (u : ℕ → ℕ) (m : ℕ) : Prop := ∃ k, 0 < k ∧ m ∣ u k

variable {u : ℕ → ℕ}

/-! ## §1. Basic facts about the entry point (mirrors the catalog) -/

-- !-- `gcd(u d, u n) = u (gcd d n) = u d`, so `u d ∣ u n` by `gcd_eq_left_iff_dvd`. -- !--
/-- Divisibility of indices transports to divisibility of terms: `d ∣ n → u d ∣ u n`. -/
lemma dvd_of_dvd (Hgcd : IsSDS u) {d n : ℕ} (hd : d ∣ n) : u d ∣ u n := by
  have h1 : Nat.gcd (u d) (u n) = u d := by rw [Hgcd, Nat.gcd_eq_left hd]
  exact Nat.gcd_eq_left_iff_dvd.mp h1

/-- If `m` appears then its entry point is positive and witnesses divisibility. -/
lemma entry_spec {m : ℕ} (h : Appears u m) : 0 < entry u m ∧ m ∣ u (entry u m) := by
  have he : entry u m = Nat.find h := dif_pos h
  rw [he]; exact Nat.find_spec h

lemma entry_pos {m : ℕ} (h : Appears u m) : 0 < entry u m := (entry_spec h).1

lemma entry_dvd_self {m : ℕ} (h : Appears u m) : m ∣ u (entry u m) := (entry_spec h).2

-- !-- Pull `m ∣ u n` and `m ∣ u e` into `m ∣ u (gcd n e)`; minimality of `e = Nat.find` forces `gcd n e = e ∣ n`. -- !--
/-- **Rank of apparition divides the index.** If `m ∣ u n` with `n > 0`, then
`entry u m ∣ n`.  Uses only the strong-divisibility identity. -/
lemma entry_dvd (Hgcd : IsSDS u) {m n : ℕ} (hn : 0 < n) (hmn : m ∣ u n) :
    entry u m ∣ n := by
  have hex : Appears u m := ⟨n, hn, hmn⟩
  have he : entry u m = Nat.find hex := dif_pos hex
  have hspec := Nat.find_spec hex
  set e := Nat.find hex with he_def
  have he_pos : 0 < e := hspec.1
  have hme : m ∣ u e := hspec.2
  have hmg : m ∣ u (Nat.gcd n e) := by
    rw [← Hgcd]; exact Nat.dvd_gcd hmn hme
  have hg_pos : 0 < Nat.gcd n e := Nat.gcd_pos_of_pos_right _ he_pos
  have hg_le : e ≤ Nat.gcd n e := by
    by_contra h
    push_neg at h
    exact Nat.find_min hex h ⟨hg_pos, hmg⟩
  have hgcd_eq : Nat.gcd n e = e :=
    Nat.le_antisymm (Nat.le_of_dvd he_pos (Nat.gcd_dvd_right _ _)) hg_le
  rw [he, ← hgcd_eq]
  exact Nat.gcd_dvd_left _ _

/-! ## §2. The abstract law of apparition -/

/-
!-- Forward: `k = 0` uses `u 0 = 0`; `k > 0` is `entry_dvd`. Backward: `entry ∣ k → u(entry) ∣ u k` (`dvd_of_dvd`) and `m ∣ u(entry)`. -- !--

**The abstract law of apparition.** For a modulus `m` that appears in a strong
divisibility sequence `u` with `u 0 = 0`, divisibility of the `k`-th term is governed
entirely by the index: `m ∣ u k ↔ entry u m ∣ k`.
-/
theorem dvd_iff_entry_dvd (Hgcd : IsSDS u) (h0 : u 0 = 0) {m : ℕ}
    (hm : Appears u m) (k : ℕ) : m ∣ u k ↔ entry u m ∣ k := by
  constructor;
  · by_cases hk : 0 < k <;> simp_all +decide [ entry_dvd ];
  · intro hk;
    exact dvd_trans ( entry_spec hm |>.2 ) ( dvd_of_dvd Hgcd hk )

/-
!-- Antisymmetry of `∣`: `entry u m ∣ d` since `m ∣ u d` (from `h d`) and `entry_dvd`; and `d ∣ entry u m` from `h (entry u m)` applied to `entry_dvd_self`. -- !--

**Rigidity of the entry point.** If the indices of appearance of `m` are exactly the
multiples of a positive `d`, then `entry u m = d`.  The entry point is the unique positive
generator of the appearance set.
-/
theorem entry_eq_of_dvd_iff (Hgcd : IsSDS u) {m d : ℕ}
    (hm : Appears u m) (hd : 0 < d) (h : ∀ k, m ∣ u k ↔ d ∣ k) : entry u m = d := by
  apply Nat.dvd_antisymm;
  · apply entry_dvd Hgcd hd;
    exact h d |>.2 dvd_rfl;
  · exact h _ |>.1 ( entry_dvd_self hm )

/-! ## §3. The entry point is a divisibility-lattice morphism on moduli -/

/-
!-- `d ∣ m ∣ u (entry u m)` with `entry u m > 0`, so `entry_dvd` gives `entry u d ∣ entry u m`. -- !--

**Order side of the lattice morphism.** If `d ∣ m` and `m` appears, then
`entry u d ∣ entry u m`: refining the modulus refines (divides) the index of first
appearance.
-/
theorem entry_dvd_entry_of_dvd (Hgcd : IsSDS u) {d m : ℕ}
    (hm : Appears u m) (hdm : d ∣ m) : entry u d ∣ entry u m := by
  convert entry_dvd Hgcd ( entry_pos hm ) _;
  exact dvd_trans hdm ( entry_dvd_self hm )

/-! ## §4. Multiplicativity on coprime moduli (the join law) -/

/-- Coprime split of a product divisor. -/
lemma coprime_mul_dvd_iff {a b k : ℕ} (hab : Nat.Coprime a b) :
    a * b ∣ k ↔ a ∣ k ∧ b ∣ k := by
  constructor
  · intro h
    exact ⟨dvd_trans (dvd_mul_right a b) h, dvd_trans (dvd_mul_left b a) h⟩
  · rintro ⟨ha, hb⟩
    exact hab.mul_dvd_of_dvd_of_dvd ha hb

/-
!-- For all `k`: `a*b ∣ u k ↔ a∣u k ∧ b∣u k` (coprime) ↔ `entry a∣k ∧ entry b∣k` (law) ↔ `lcm∣k`; then `entry_eq_of_dvd_iff`. -- !--

**Multiplicativity / join law.** For coprime moduli `a, b` that appear in a strong
divisibility sequence `u` with `u 0 = 0`,
`entry u (a * b) = lcm (entry u a) (entry u b)`.  This is the dual of the catalog's
`gcd ↦ gcd` half (`StrongDivSeq.dvd_gcd_index_iff`) and reduces entry-point computation to
prime powers.
-/
theorem entry_mul_coprime (Hgcd : IsSDS u) (h0 : u 0 = 0) {a b : ℕ}
    (ha : Appears u a) (hb : Appears u b) (hab : Nat.Coprime a b) :
    entry u (a * b) = Nat.lcm (entry u a) (entry u b) := by
  apply entry_eq_of_dvd_iff Hgcd;
  · -- By the properties of the entry function, we know that $entry u a \mid entry u (a * b)$ and $entry u b \mid entry u (a * b)$.
    have h_div : a ∣ u (Nat.lcm (entry u a) (entry u b)) ∧ b ∣ u (Nat.lcm (entry u a) (entry u b)) := by
      exact ⟨ dvd_of_dvd ( Hgcd ) ( Nat.dvd_lcm_left _ _ ) |> fun x => dvd_trans ( entry_dvd_self ha ) x, dvd_of_dvd ( Hgcd ) ( Nat.dvd_lcm_right _ _ ) |> fun x => dvd_trans ( entry_dvd_self hb ) x ⟩;
    exact ⟨ _, Nat.lcm_pos ( entry_pos ha ) ( entry_pos hb ), hab.mul_dvd_of_dvd_of_dvd h_div.1 h_div.2 ⟩;
  · exact Nat.lcm_pos ( entry_pos ha ) ( entry_pos hb );
  · intro k
    rw [coprime_mul_dvd_iff hab];
    grind +suggestions

/-! ## §5. Concrete instantiation: the Mersenne / repunit family `u n = aⁿ − 1`

Here `entry` is the multiplicative order, so multiplicativity is the classical
`ord_{a*b} = lcm (ord_a) (ord_b)` on coprime moduli. -/

/-- The Mersenne/repunit sequence is a strong divisibility sequence. -/
lemma mersenne_isSDS (a : ℕ) : IsSDS (fun n => a ^ n - 1) := by
  intro m n
  by_cases ha : a = 0 <;> simp_all [Nat.pow_sub_one_gcd_pow_sub_one]

/-- For the Mersenne/repunit family `u n = aⁿ − 1`, the rank of apparition is multiplicative
on coprime moduli. -/
theorem mersenne_entry_mul_coprime (a : ℕ) {p q : ℕ}
    (hp : Appears (fun n => a ^ n - 1) p) (hq : Appears (fun n => a ^ n - 1) q)
    (hpq : Nat.Coprime p q) :
    entry (fun n => a ^ n - 1) (p * q)
      = Nat.lcm (entry (fun n => a ^ n - 1) p) (entry (fun n => a ^ n - 1) q) := by
  refine entry_mul_coprime (mersenne_isSDS a) ?_ hp hq hpq
  simp

/-! ## §6. Concrete instantiation: the Fibonacci sequence -/

/-- The Fibonacci sequence is a strong divisibility sequence (restatement of `Nat.fib_gcd`). -/
lemma fib_isSDS : IsSDS Nat.fib := fun m n => (Nat.fib_gcd m n).symm

/-- **Fibonacci rank of apparition is multiplicative on coprime moduli.** Recovers the
catalog's `fibEntry_mul_coprime` from the abstract theorem. -/
theorem fib_entry_mul_coprime {a b : ℕ}
    (ha : Appears Nat.fib a) (hb : Appears Nat.fib b) (hab : Nat.Coprime a b) :
    entry Nat.fib (a * b) = Nat.lcm (entry Nat.fib a) (entry Nat.fib b) := by
  refine entry_mul_coprime fib_isSDS ?_ ha hb hab
  rfl

end RankOfApparition
/-
-- !-- Lab Notebook -- !--

Hypothesis:
  The catalog had the law of apparition and coprime multiplicativity of the rank of
  apparition only for the Fibonacci sequence (via a now-missing `FibonacciApparition`
  module). We hypothesized that both depend on nothing Fibonacci-specific: only the
  renormalization identity `gcd (u m) (u n) = u (gcd m n)` (`IsSDS`) plus `u 0 = 0`.
  If so, `entry u` is a divisibility-lattice morphism from moduli to indices, with
  `gcd -> gcd` (already in the catalog) and `coprime-product -> lcm` (this file).

Result:
  Confirmed, sorry = 0 (axioms: propext, Classical.choice, Quot.sound only).
    * `dvd_iff_entry_dvd`      -- abstract law of apparition `m | u k <-> entry u m | k`.
    * `entry_eq_of_dvd_iff`    -- rigidity (needed only `IsSDS`, not `u 0 = 0`).
    * `entry_dvd_entry_of_dvd` -- `d | m -> entry u d | entry u m` (order side).
    * `entry_mul_coprime`      -- `entry u (a*b) = lcm (entry u a) (entry u b)`.
  Instantiations: `mersenne_entry_mul_coprime` (here `entry` is the multiplicative order,
  recovering `ord_(a*b) = lcm (ord_a) (ord_b)`) and `fib_entry_mul_coprime`.

Insight:
  `u 0 = 0` is load-bearing for the law of apparition (the `k = 0` edge case) and hence for
  multiplicativity, but irrelevant to rigidity and to the order side of the morphism.
  Multiplicativity reduces the entry-point function to prime powers, complementing the
  `gcd -> gcd` half from the catalog.

Failure analysis:
  Reusing the catalog's `StrongDivSeq.entry`/`FibonacciApparition.fibEntry` was abandoned:
  `Speculative.AutoResearch.FibonacciApparition` is absent, so the dependent `Novelty/` and
  `Applications/` files do not build and are not registered Lake libraries. We re-developed a
  minimal self-contained `entry` theory on Mathlib under the registered `Speculative` library.
  Instantiations use explicit `Appears` hypotheses rather than discharging totality, since
  Mathlib lacks a ready Fibonacci rank-of-apparition existence lemma (a Pisano fact).
-- !-- End Lab Notebook -- !--
-/