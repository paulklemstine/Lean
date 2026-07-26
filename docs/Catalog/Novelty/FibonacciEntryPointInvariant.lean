import Speculative.AutoResearch.FibonacciApparition

/-! # The entry-point invariant of a strong divisibility sequence

Domain: Number Theory / Novelty (cross-domain abstraction of the catalog's Fibonacci
Carmichael development).

This file **promotes** the Fibonacci-specific entry-point theory of
`Catalog/Speculative/AutoResearch/FibonacciApparition.lean`
(`FibonacciApparition.fibEntry`, `fib_dvd_iff_fibEntry_dvd`,
`prime_primitive_divisor_iff`) and of `CarmichaelComposite.lean`
(`fibEntryPt`, `primitive_of_entryPt_eq`) into a **fully abstract theory** that depends
on nothing but the *renormalization* (strong-divisibility) identity

  `gcd (u m) (u n) = u (gcd m n)`.

The conceptual claim — *"fractal injectivity"* — is that the entry-point map of **any**
strong divisibility sequence is a lattice morphism from the divisibility lattice of moduli
to that of indices, and in particular a fixed modulus can be a *primitive* divisor of at
most one term.  We prove this once, abstractly (`StrongDivSeq.primitive_divisor_inj`),
then harvest it for two concrete models with zero further work:

* the Fibonacci numbers `u = Nat.fib` (via `Nat.fib_gcd`), and
* the base-`a` repunit/Mersenne sequence `u n = a ^ n - 1` (via
  `Nat.pow_sub_one_gcd_pow_sub_one`).

We additionally prove the previously-conjectured **multiplicativity of the Fibonacci rank
of apparition on coprime moduli** (`fibEntry_mul_coprime`,
`fibEntry (a*b) = lcm (fibEntry a) (fibEntry b)`), the dual of the `gcd ↦ gcd` half already
recorded by `Nat.fib_gcd`.  This reduces all entry-point computation to the prime-power
case.

## Main results

* `StrongDivSeq.entry_dvd` — the rank of apparition divides every index of appearance,
  for an arbitrary strong divisibility sequence (no primality, no fib-specific value).
* `StrongDivSeq.entry_eq_of_primitive` — a primitive divisor pins the entry point.
* `StrongDivSeq.primitive_divisor_inj` — **(main)** a fixed modulus is a primitive divisor
  of at most one term.
* `StrongDivSeq.primitive_divisor_distinct` — distinct indices have disjoint
  primitive-divisor sets.
* `fibEntry_mul_coprime` — multiplicativity of the Fibonacci entry point on coprime moduli.
* `fib_primitive_divisor_inj`, `mersenne_primitive_divisor_inj` — the two concrete
  instantiations.
-/

namespace StrongDivSeq

open Classical

variable (u : ℕ → ℕ)

/-- The **entry point** (rank of apparition) of `m` in the sequence `u`: the least `k > 0`
with `m ∣ u k`, or `0` when no such index exists. -/
noncomputable def entry (m : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ m ∣ u k then Nat.find h else 0

/-- A modulus `m` is a **primitive divisor** of the index `n` when `m ∣ u n` but `m`
divides no earlier positive term — i.e. `n` is the first appearance of `m`. -/
def IsPrimitive (m n : ℕ) : Prop :=
  0 < n ∧ m ∣ u n ∧ ∀ k, 0 < k → k < n → ¬ m ∣ u k

variable {u}

/-- The renormalization identity forces divisibility to transport along the index lattice:
`d ∣ n → u d ∣ u n`. -/
-- !-- `gcd(u d, u n) = u (gcd d n) = u d`, so `u d ∣ u n` by `gcd_eq_left_iff_dvd`. -- !--
lemma dvd_of_dvd (Hgcd : ∀ m n, Nat.gcd (u m) (u n) = u (Nat.gcd m n))
    {d n : ℕ} (hd : d ∣ n) : u d ∣ u n := by
  have h1 : Nat.gcd (u d) (u n) = u d := by
    rw [Hgcd, Nat.gcd_eq_left hd]
  exact Nat.gcd_eq_left_iff_dvd.mp h1

/-- **Rank of apparition divides the index.** If `m ∣ u n` with `n > 0`, then the entry
point of `m` divides `n`. Needs only the strong-divisibility identity — no primality. -/
-- !-- Pull `m ∣ u n` and `m ∣ u e` into `m ∣ u (gcd n e)`; minimality of `e = Nat.find` forces `gcd n e = e ∣ n`. -- !--
lemma entry_dvd (Hgcd : ∀ m n, Nat.gcd (u m) (u n) = u (Nat.gcd m n))
    {m n : ℕ} (hn : 0 < n) (hmn : m ∣ u n) : entry u m ∣ n := by
  have hex : ∃ k, 0 < k ∧ m ∣ u k := ⟨n, hn, hmn⟩
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

/-- The entry point is positive and witnesses divisibility, whenever an index of
appearance exists. -/
lemma entry_pos_and_dvd (m n : ℕ) (hn : 0 < n) (hmn : m ∣ u n) :
    0 < entry u m ∧ m ∣ u (entry u m) := by
  have hex : ∃ k, 0 < k ∧ m ∣ u k := ⟨n, hn, hmn⟩
  have he : entry u m = Nat.find hex := dif_pos hex
  have hspec := Nat.find_spec hex
  rw [he]; exact hspec

/-- **A primitive divisor pins the entry point.** If `m` is a primitive divisor of `n`,
then `entry u m = n`. -/
-- !-- `entry_dvd` gives `entry ∣ n` hence `entry ≤ n`; primitivity forbids `entry < n`, so `entry = n`. -- !--
lemma entry_eq_of_primitive (Hgcd : ∀ m n, Nat.gcd (u m) (u n) = u (Nat.gcd m n))
    {m n : ℕ} (h : IsPrimitive u m n) : entry u m = n := by
  obtain ⟨hn, hmn, hmin⟩ := h
  have hdvd : entry u m ∣ n := entry_dvd Hgcd hn hmn
  have hle : entry u m ≤ n := Nat.le_of_dvd hn hdvd
  obtain ⟨hpos, hme⟩ := entry_pos_and_dvd m n hn hmn
  rcases lt_or_eq_of_le hle with hlt | heq
  · exact absurd hme (hmin _ hpos hlt)
  · exact heq

/-- **Fractal injectivity (main theorem).** A fixed modulus `m` is a primitive divisor of
*at most one* index: if `m` is a primitive divisor of both `n₁` and `n₂`, then `n₁ = n₂`.
The self-similar (strong-divisibility) lattice forbids a modulus from making a first
appearance twice. -/
-- !-- Both primitive indices equal the single value `entry u m` by `entry_eq_of_primitive`. -- !--
theorem primitive_divisor_inj (Hgcd : ∀ m n, Nat.gcd (u m) (u n) = u (Nat.gcd m n))
    {m n₁ n₂ : ℕ} (h₁ : IsPrimitive u m n₁) (h₂ : IsPrimitive u m n₂) : n₁ = n₂ := by
  have e₁ := entry_eq_of_primitive Hgcd h₁
  have e₂ := entry_eq_of_primitive Hgcd h₂
  rw [← e₁, ← e₂]

/-- Distinct indices have **disjoint** primitive-divisor sets: no modulus is primitive for
two different indices. -/
theorem primitive_divisor_distinct (Hgcd : ∀ m n, Nat.gcd (u m) (u n) = u (Nat.gcd m n))
    {m n₁ n₂ : ℕ} (hne : n₁ ≠ n₂) (h₁ : IsPrimitive u m n₁) : ¬ IsPrimitive u m n₂ :=
  fun h₂ => hne (primitive_divisor_inj Hgcd h₁ h₂)

end StrongDivSeq

/-! ## Concrete model 1 — the Fibonacci numbers -/

/-- Fibonacci numbers form a strong divisibility sequence (restatement of `Nat.fib_gcd`). -/
lemma fib_strong_div : ∀ m n, Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n) :=
  fun m n => (Nat.fib_gcd m n).symm

/-- A prime (indeed any modulus) is a primitive divisor of at most one Fibonacci number.
This recovers, abstractly, the catalog fact underlying Carmichael's primitive-divisor
theorem. -/
theorem fib_primitive_divisor_inj {m n₁ n₂ : ℕ}
    (h₁ : StrongDivSeq.IsPrimitive Nat.fib m n₁)
    (h₂ : StrongDivSeq.IsPrimitive Nat.fib m n₂) : n₁ = n₂ :=
  StrongDivSeq.primitive_divisor_inj fib_strong_div h₁ h₂

/-! ## Concrete model 2 — base-`a` repunit / Mersenne sequence `u n = a ^ n - 1` -/

/-- For any base `a`, the sequence `n ↦ a ^ n - 1` is a strong divisibility sequence
(restatement of `Nat.pow_sub_one_gcd_pow_sub_one`). -/
lemma mersenne_strong_div (a : ℕ) :
    ∀ m n, Nat.gcd (a ^ m - 1) (a ^ n - 1) = (a ^ Nat.gcd m n - 1) :=
  fun m n => Nat.pow_sub_one_gcd_pow_sub_one a m n

/-- A modulus is a primitive divisor of at most one base-`a` Mersenne/repunit number
`a ^ n - 1`. The entry-point theory transfers verbatim from Fibonacci to Mersenne. -/
theorem mersenne_primitive_divisor_inj (a : ℕ) {m n₁ n₂ : ℕ}
    (h₁ : StrongDivSeq.IsPrimitive (fun n => a ^ n - 1) m n₁)
    (h₂ : StrongDivSeq.IsPrimitive (fun n => a ^ n - 1) m n₂) : n₁ = n₂ :=
  StrongDivSeq.primitive_divisor_inj (mersenne_strong_div a) h₁ h₂

/-! ## Multiplicativity of the Fibonacci entry point on coprime moduli

We work with the Fibonacci entry point `FibonacciApparition.fibEntry`, for which the *law
of apparition* `m ∣ fib k ↔ fibEntry m ∣ k` (for `m > 0`) is already available
(`FibonacciApparition.fib_dvd_iff_fibEntry_dvd`) and total (every `m > 0` divides some
positive Fibonacci number, `FibonacciApparition.exists_pos_dvd_fib`). -/

open FibonacciApparition

/-- Two naturals that are divisibility-equivalent (`d ∣ k ↔ e ∣ k` for all `k`) coincide. -/
lemma Nat.eq_of_dvd_iff {d e : ℕ} (h : ∀ k, d ∣ k ↔ e ∣ k) : d = e :=
  Nat.dvd_antisymm ((h e).mpr dvd_rfl) ((h d).mp dvd_rfl)

/-- Coprime split of divisibility into a product. -/
lemma coprime_mul_dvd_iff {a b k : ℕ} (hab : Nat.Coprime a b) :
    a * b ∣ k ↔ a ∣ k ∧ b ∣ k := by
  constructor
  · intro h
    exact ⟨dvd_trans (dvd_mul_right a b) h, dvd_trans (dvd_mul_left b a) h⟩
  · rintro ⟨ha, hb⟩
    exact hab.mul_dvd_of_dvd_of_dvd ha hb

/-- **Multiplicativity of the rank of apparition on coprime moduli.** For coprime
`a, b > 0`, `fibEntry (a * b) = lcm (fibEntry a) (fibEntry b)`. Combined with `Nat.fib_gcd`
(the `gcd ↦ gcd` half), this exhibits `fibEntry` as a lattice morphism and reduces all
entry-point computation to the prime-power case. -/
-- !-- For every `k`: `a*b ∣ fib k ↔ a∣fib k ∧ b∣fib k` (coprime) ↔ `fibEntry a ∣ k ∧ fibEntry b ∣ k` (law of apparition) ↔ `lcm ∣ k`; divisibility-equivalence gives equality. -- !--
theorem fibEntry_mul_coprime {a b : ℕ} (ha : 0 < a) (hb : 0 < b) (hab : Nat.Coprime a b) :
    fibEntry (a * b) = Nat.lcm (fibEntry a) (fibEntry b) := by
  have hab_pos : 0 < a * b := Nat.mul_pos ha hb
  apply Nat.eq_of_dvd_iff
  intro k
  rw [← fib_dvd_iff_fibEntry_dvd (a * b) hab_pos k]
  rw [coprime_mul_dvd_iff hab]
  rw [fib_dvd_iff_fibEntry_dvd a ha k, fib_dvd_iff_fibEntry_dvd b hb k]
  rw [Nat.lcm_dvd_iff]