import Mathlib

/-! # Entry points for strong divisibility sequences: a dual/representation unifier

## Overview

The *entry point* (rank of apparition) of `p` in a sequence `a : ℕ → ℕ` is the least
`k > 0` with `p ∣ a k`.  For Fibonacci numbers this is the classical organizing object
behind Carmichael's primitive-divisor theorem (see the catalog file
`Catalog/Applications/FibonacciEntryPoints.lean`, with `entryPoint`,
`dvd_fib_iff_entry_dvd`, `primitive_iff_entry_eq`, `fib_twelve_no_primitive`).

This file isolates the **only** structural fact those proofs used — *strong
divisibility*

  `a (gcd m n) = gcd (a m) (a n)`

— and rebuilds the entire entry-point calculus over it.  The payoff is a genuine
*conceptual unification*: the very same three theorems

  * `dvd_iff_entryPoint_dvd`        : `p ∣ a n ↔ z(p) ∣ n`
  * `primitive_iff_entryPoint_eq`   : `p` is primitive for `a n` ↔ `z(p) = n`
  * `entryPoint` minimality package

now apply *verbatim* to two a-priori unrelated families:

  * **Fibonacci** `Nat.fib`            (strong divisibility = `Nat.fib_gcd`), and
  * **`b`-Mersenne / Bang–Zsygmondy** `n ↦ b^n - 1`
    (strong divisibility = `Nat.pow_sub_one_gcd_pow_sub_one`).

This is the order-theoretic *duality* advertised in the research direction: a
primitive divisor of `a n` is exactly a prime whose entry point equals `n`, i.e. a
prime whose "order" in the dual index lattice is maximal.  Fibonacci primitivity and
`b^n - 1` primitivity are then two faces of one statement about the divisor lattice
`(ℕ, ∣)` pulled back along `a`.

## Main results (`sorry`-free)

* `StrongDiv.dvd_of_index_dvd`   — `m ∣ n → a m ∣ a n` from strong divisibility alone.
* `dvd_iff_entryPoint_dvd`        — `p ∣ a n ↔ entryPoint a p ∣ n`.
* `primitive_iff_entryPoint_eq`   — primitivity ⇔ `entryPoint a p = n`.
* `fib_strongDiv`, `mersenne_strongDiv` — the two instances.
* `fib_dvd_iff_entryPoint_dvd`, `mersenne_dvd_iff_entryPoint_dvd` — specializations.

-/

/-
!-- Lab Notebook -- !--
Hypothesis: The Fibonacci entry-point theory (catalog: FibonacciEntryPoints) never
  touches Fibonacci-specific facts beyond `Nat.fib_gcd`; therefore it should lift to
  any sequence with `a (gcd m n) = gcd (a m) (a n)` (strong divisibility), unifying
  Fibonacci with the classical `b^n - 1` (Mersenne / Bang–Zsygmondy) family.
Result: Confirmed. The abstract `StrongDiv` predicate suffices to reprove the
  divisibility bridge `p ∣ a n ↔ z(p) ∣ n` and the primitivity characterization
  `IsPrimitive ↔ z(p) = n`. Both Fibonacci (`Nat.fib_gcd`) and `b^n - 1`
  (`Nat.pow_sub_one_gcd_pow_sub_one`) are instances obtained for free.
Insight: "Strong divisibility" is the *dual* incarnation of the index gcd-lattice:
  `a` is a lattice (anti)morphism `(ℕ, gcd) → (ℕ, gcd)`, and the entry point is the
  pullback of `p ∣ −` to a single generator. Primitivity = maximal order = the
  generator is hit for the first time exactly at `n`.
Failure analysis: The `b^n - 1` family genuinely needs `b ≥ 2` and `n` interaction
  only through the gcd lemma; no monotonicity or growth estimate is used here, which
  is exactly why the *existence* of primitive divisors (Carmichael/Zsygmondy) stays
  open — that requires growth, the missing multiplicative half (see FUTURE_DIRECTIONS).
-/

namespace EntryPointCalculus

/-- A `ℕ`-indexed `ℕ`-valued sequence is a **strong divisibility sequence** when the
value at a gcd of indices is the gcd of the values:
`a (gcd m n) = gcd (a m) (a n)`. -/
def StrongDiv (a : ℕ → ℕ) : Prop := ∀ m n, a (Nat.gcd m n) = Nat.gcd (a m) (a n)

variable {a : ℕ → ℕ}

/-
!-- If `m ∣ n` then `gcd m n = m`, so strong divisibility reads `a m = gcd (a m) (a n)`,
giving `a m ∣ a n`. -- !--
-/
theorem StrongDiv.dvd_of_index_dvd (h : StrongDiv a) {m n : ℕ} (hmn : m ∣ n) :
    a m ∣ a n := by
  have hg : Nat.gcd m n = m := Nat.gcd_eq_left hmn
  have hmn' := h m n
  rw [hg] at hmn'
  rw [hmn']
  exact Nat.gcd_dvd_right _ _

/-
!-- The gcd bridge: if `p` divides `a m` and `a n` then it divides `a (gcd m n)`,
because `a (gcd m n) = gcd (a m) (a n)`. -- !--
-/
theorem StrongDiv.dvd_gcd (h : StrongDiv a) {p m n : ℕ} (hm : p ∣ a m) (hn : p ∣ a n) :
    p ∣ a (Nat.gcd m n) := by
  rw [h m n]; exact Nat.dvd_gcd hm hn

open Classical in
/-- The **entry point** (rank of apparition) of `p` in the sequence `a`: the least
`k > 0` with `p ∣ a k`, or `0` if no such `k` exists. -/
noncomputable def entryPoint (a : ℕ → ℕ) (p : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ p ∣ a k then Nat.find h else 0

/-
!-- Positivity, witness, and minimality of the entry point read directly off `Nat.find`. -- !--
-/
theorem entryPoint_pos (p : ℕ) (hex : ∃ k, 0 < k ∧ p ∣ a k) :
    0 < entryPoint a p := by
  unfold entryPoint; rw [dif_pos hex]; exact (Nat.find_spec hex).1

theorem dvd_a_entryPoint (p : ℕ) (hex : ∃ k, 0 < k ∧ p ∣ a k) :
    p ∣ a (entryPoint a p) := by
  unfold entryPoint; rw [dif_pos hex]; exact (Nat.find_spec hex).2

theorem entryPoint_min (p m : ℕ) (hm : 0 < m) (hlt : m < entryPoint a p) :
    ¬ p ∣ a m := by
  intro hdvd
  unfold entryPoint at hlt
  by_cases hex : ∃ k, 0 < k ∧ p ∣ a k
  · rw [dif_pos hex] at hlt
    exact Nat.find_min hex hlt ⟨hm, hdvd⟩
  · rw [dif_neg hex] at hlt; exact absurd hlt (by omega)

/-
!-- `p ∣ a n ↔ z(p) ∣ n`. (←) is `StrongDiv.dvd_of_index_dvd` from `z(p) ∣ n`.
(→) is the contrapositive: if `z(p) ∤ n` then `gcd z(p) n < z(p)` is a smaller index
at which `p` divides `a`, contradicting minimality via the gcd bridge. -- !--
-/
theorem dvd_iff_entryPoint_dvd (h : StrongDiv a) (p n : ℕ)
    (hex : ∃ k, 0 < k ∧ p ∣ a k) :
    p ∣ a n ↔ entryPoint a p ∣ n := by
  set e := entryPoint a p with he
  have he_pos : 0 < e := entryPoint_pos p hex
  have he_div : p ∣ a e := dvd_a_entryPoint p hex
  constructor
  · intro hn
    by_contra hcon
    have h_gcd_lt_e : Nat.gcd e n < e :=
      lt_of_le_of_ne (Nat.le_of_dvd he_pos (Nat.gcd_dvd_left _ _))
        (fun hh => hcon (hh ▸ Nat.gcd_dvd_right _ _))
    exact entryPoint_min p (Nat.gcd e n) (Nat.gcd_pos_of_pos_left _ he_pos) h_gcd_lt_e
      (h.dvd_gcd he_div hn)
  · intro hdvd
    exact dvd_trans he_div (h.dvd_of_index_dvd hdvd)

/-- `p` is a **primitive divisor** of `a n`: it divides `a n` but none of `a k` for
`0 < k < n`. -/
def IsPrimitive (a : ℕ → ℕ) (p n : ℕ) : Prop :=
  p ∣ a n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ a k

/-
!-- Primitivity ⇔ `z(p) = n`. (→) `z(p) ≤ n` by minimality of `Nat.find` and `n ≥ z(p)`
since `p ∣ a n` and nothing smaller works; (←) `p ∣ a (z(p))` and minimality kill all
earlier indices.  Notably this direction needs *no* strong-divisibility assumption:
primitivity is a statement about the entry point alone. -- !--
-/
theorem primitive_iff_entryPoint_eq (p n : ℕ) (hn : 0 < n)
    (hex : ∃ k, 0 < k ∧ p ∣ a k) :
    IsPrimitive a p n ↔ entryPoint a p = n := by
  constructor
  · intro hp
    apply le_antisymm
    · unfold entryPoint; rw [dif_pos hex]; exact Nat.find_min' hex ⟨hn, hp.1⟩
    · exact le_of_not_gt fun h' =>
        hp.2 _ (entryPoint_pos p hex) h' (dvd_a_entryPoint p hex)
  · intro hz
    refine ⟨hz ▸ dvd_a_entryPoint p hex, fun k hk₁ hk₂ => ?_⟩
    exact entryPoint_min p k hk₁ (by omega)

/-! ## Instance 1 — Fibonacci numbers -/

/-
!-- Fibonacci is a strong divisibility sequence: this is exactly `Nat.fib_gcd`. -- !--
-/
theorem fib_strongDiv : StrongDiv Nat.fib := fun m n => Nat.fib_gcd m n

/-- Fibonacci entry-point divisibility bridge, recovered from the abstract theory. -/
theorem fib_dvd_iff_entryPoint_dvd (p n : ℕ) (hex : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
    p ∣ Nat.fib n ↔ entryPoint Nat.fib p ∣ n :=
  dvd_iff_entryPoint_dvd fib_strongDiv p n hex

/-- Fibonacci primitivity characterization, recovered from the abstract theory. -/
theorem fib_primitive_iff_entryPoint_eq (p n : ℕ) (hn : 0 < n)
    (hex : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
    IsPrimitive Nat.fib p n ↔ entryPoint Nat.fib p = n :=
  primitive_iff_entryPoint_eq p n hn hex

/-! ## Instance 2 — `b`-Mersenne sequences `n ↦ b ^ n - 1` (Bang–Zsygmondy) -/

/-
!-- `n ↦ b^n - 1` is a strong divisibility sequence: this is exactly
`Nat.pow_sub_one_gcd_pow_sub_one`. -- !--
-/
theorem mersenne_strongDiv (b : ℕ) : StrongDiv (fun n => b ^ n - 1) :=
  fun m n => (Nat.pow_sub_one_gcd_pow_sub_one b m n).symm

/-- `b`-Mersenne entry-point divisibility bridge: `p ∣ b^n - 1 ↔ z(p) ∣ n`.
With `b` a primitive root mod a prime `p`, `entryPoint` is the multiplicative order
of `b` in `(ℤ/p)ˣ` — the spectral/representation incarnation of the entry point. -/
theorem mersenne_dvd_iff_entryPoint_dvd (b p n : ℕ)
    (hex : ∃ k, 0 < k ∧ p ∣ b ^ k - 1) :
    p ∣ b ^ n - 1 ↔ entryPoint (fun n => b ^ n - 1) p ∣ n :=
  dvd_iff_entryPoint_dvd (mersenne_strongDiv b) p n hex

/-- `b`-Mersenne primitivity characterization (the `b^n - 1` analogue of
Carmichael's primitive-divisor condition). -/
theorem mersenne_primitive_iff_entryPoint_eq (b p n : ℕ) (hn : 0 < n)
    (hex : ∃ k, 0 < k ∧ p ∣ b ^ k - 1) :
    IsPrimitive (fun n => b ^ n - 1) p n ↔ entryPoint (fun n => b ^ n - 1) p = n :=
  primitive_iff_entryPoint_eq p n hn hex

/-! ## Sanity checks -/

/-- `13 ∣ F₇ = 13` and divides no earlier Fibonacci, so its entry point is `7`. -/
example : entryPoint Nat.fib 13 = 7 := by
  have hex : ∃ k, 0 < k ∧ (13 : ℕ) ∣ Nat.fib k := ⟨7, by decide, by decide⟩
  refine (fib_primitive_iff_entryPoint_eq 13 7 (by decide) hex).1 ?_
  refine ⟨by decide, ?_⟩
  intro k hk hk'
  interval_cases k <;> decide

/-- For base `b = 2`, `7 ∣ 2³ - 1 = 7` and divides no `2^k - 1` for `0 < k < 3`,
so the entry point of `7` in the Mersenne sequence is `3`. -/
example : entryPoint (fun n => 2 ^ n - 1) 7 = 3 := by
  have hex : ∃ k, 0 < k ∧ (7 : ℕ) ∣ 2 ^ k - 1 := ⟨3, by decide, by decide⟩
  refine (mersenne_primitive_iff_entryPoint_eq 2 7 3 (by decide) hex).1 ?_
  refine ⟨by decide, ?_⟩
  intro k hk hk'
  interval_cases k <;> decide

end EntryPointCalculus