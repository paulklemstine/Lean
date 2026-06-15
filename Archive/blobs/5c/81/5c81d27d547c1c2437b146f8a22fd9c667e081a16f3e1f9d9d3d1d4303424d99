# Fibonacci Divisibility: gcd identity, coprimality, and rank of apparition

**File:** `Catalog/Algebra/FibonacciDivisibility.lean`
**Namespace:** `FibonacciDivisibility`
**Dependencies:** Mathlib only (self-contained; module `Algebra.FibonacciDivisibility`, built by the default `Algebra` target).
**Status:** Complete — no `sorry`, axioms restricted to `propext`, `Classical.choice`, `Quot.sound`.

## Summary

This file gives a self-contained arithmetic development of the divisibility theory of the
Fibonacci numbers `Nat.fib`, organised around the four targets requested. All statements are
fully proved against Mathlib.

## §1. Strong divisibility / gcd identity

```lean
theorem fib_gcd_comm (m n : ℕ) :
    Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n)
```

Mathlib already proves the reverse orientation `Nat.fib_gcd : Nat.fib (gcd m n) = gcd (fib m) (fib n)`,
which expresses that `Nat.fib` is a *strong divisibility sequence*. We export the symmetric
statement `fib_gcd_comm` under a clean catalog name and use it downstream. The proof is a one-line
wrapper (`(Nat.fib_gcd m n).symm`), as recommended (reuse Mathlib rather than reprove).

## §2. Exact coprimality criterion

```lean
theorem one_lt_fib   {k : ℕ} (hk : 3 ≤ k) : 1 < Nat.fib k
theorem fib_eq_one_iff {k : ℕ} : Nat.fib k = 1 ↔ k = 1 ∨ k = 2
theorem fib_coprime_iff (m n : ℕ) :
    Nat.Coprime (Nat.fib m) (Nat.fib n) ↔ Nat.gcd m n = 1 ∨ Nat.gcd m n = 2
```

**Strategy.** Coprimality `Coprime (F m) (F n)` unfolds to `gcd (F m) (F n) = 1`. Rewriting through
`fib_gcd_comm` turns the left side into `F (gcd m n) = 1`. The auxiliary lemma `fib_eq_one_iff`
(proved via `one_lt_fib`, which uses `Nat.fib_lt_fib`, plus the base values `F 1 = F 2 = 1`) then
characterises exactly when a Fibonacci number equals `1`, giving the clean criterion
`gcd m n = 1 ∨ gcd m n = 2`. This isolates and proves the suggested helper
`Nat.fib k = 1 ↔ k = 1 ∨ k = 2`.

## §3. Rank of apparition: existence and the spine

```lean
def HasFibRank (m : ℕ) : Prop := ∃ k, 0 < k ∧ m ∣ Nat.fib k
def fibStep (m : ℕ) : ZMod m × ZMod m ≃ ZMod m × ZMod m         -- reversible Fibonacci shift
theorem fibStep_iterate (m k : ℕ) :
    (fibStep m)^[k] (0, 1) = ((Nat.fib k : ZMod m), (Nat.fib (k+1) : ZMod m))
theorem hasFibRank_of_pos (m : ℕ) (hm : 0 < m) : HasFibRank m   -- apparition is total

noncomputable def fibRank (m : ℕ) : ℕ                            -- least positive k with m ∣ F k, else 0
theorem fibRank_pos      {m : ℕ} (hm : HasFibRank m) : 0 < fibRank m
theorem dvd_fib_fibRank  {m : ℕ} (hm : HasFibRank m) : m ∣ Nat.fib (fibRank m)
theorem fibRank_min      {m k : ℕ} (hk : 0 < k) (hlt : k < fibRank m) : ¬ m ∣ Nat.fib k
theorem fibRank_dvd_iff  {m : ℕ} (hm : HasFibRank m) (n : ℕ) :
    m ∣ Nat.fib n ↔ fibRank m ∣ n                               -- THE SPINE
```

**Strategy.** `fibRank m` is `Nat.find` of the apparition predicate. Existence
(`hasFibRank_of_pos`) is the Pisano-period mechanism: the Fibonacci shift `(a,b) ↦ (b, a+b)` is a
bijection of the finite set `(ZMod m)²`, so the orbit of `(0,1)` (whose `k`-th point is
`(F k, F (k+1)) mod m`) is eventually periodic; back-stepping a repeated pair to index `0` yields a
positive `k` with `m ∣ F k`.

The **spine** `m ∣ F n ↔ fibRank m ∣ n` is proved with no primitivity hypothesis:
- (←) `fibRank m ∣ n ⇒ F (fibRank m) ∣ F n` (`Nat.fib_dvd`) and `m ∣ F (fibRank m)`.
- (→) push `m` into `F (gcd (fibRank m) n) = gcd (F …) (F n)` via `Nat.fib_gcd`; minimality of the
  rank forces `gcd (fibRank m) n = fibRank m`, i.e. `fibRank m ∣ n`.

### Edge cases (explicit)

```lean
theorem fibRank_one  : fibRank 1 = 1
theorem fibRank_zero : fibRank 0 = 0
```

`m = 1`: `1` divides every `F k`; the least positive index is `1`. `m = 0`: `0` divides no
positive-index Fibonacci number (all are positive), so the rank is the sentinel `0` and the spine
does not apply (its hypothesis `HasFibRank 0` is false). The spine `fibRank_dvd_iff` therefore holds
exactly on the admissible range `0 < m` (equivalently `HasFibRank m`).

### Order-morphism law

```lean
theorem fibRank_dvd_of_dvd {a b : ℕ} (ha : 0 < a) (hab : b ∣ a) : fibRank b ∣ fibRank a
```

From the spine: `b ∣ a ∣ F (fibRank a)`, so `b ∣ F (fibRank a)`, hence `fibRank b ∣ fibRank a`.

## §4. Lattice (join) law and coprime-product corollary

```lean
theorem nat_eq_of_dvd_iff {d e : ℕ} (h : ∀ k, d ∣ k ↔ e ∣ k) : d = e
theorem fibRank_lcm {a b : ℕ} (ha : 0 < a) (hb : 0 < b) :
    fibRank (Nat.lcm a b) = Nat.lcm (fibRank a) (fibRank b)
theorem fibRank_mul_coprime {a b : ℕ} (ha : 0 < a) (hb : 0 < b)
    (hab : Nat.Coprime a b) : fibRank (a * b) = Nat.lcm (fibRank a) (fibRank b)
```

**Strategy.** For each `k`, the spine and `Nat.lcm_dvd_iff` give
`lcm a b ∣ F k ↔ fibRank a ∣ k ∧ fibRank b ∣ k ↔ lcm (fibRank a) (fibRank b) ∣ k`.
Two naturals with the same divisors coincide (`nat_eq_of_dvd_iff`), yielding the join law. The
coprime-product corollary then follows from `Nat.Coprime.lcm_eq_mul`.

## What was reused vs. newly proved

- **Reused from Mathlib:** `Nat.fib_gcd`, `Nat.fib_dvd`, `Nat.fib_lt_fib`, `Nat.fib_pos`,
  `Nat.lcm_dvd_iff`, `Nat.Coprime.lcm_eq_mul`, `Nat.find` API.
- **Newly assembled here (self-contained):** the coprimality criterion and its `fib_eq_one_iff`
  helper; the rank-of-apparition existence/spine layer (existence proof inlined from the catalog's
  `Catalog/Applications/RankOfApparition.lean`, which is self-contained against Mathlib but not part
  of a default build target); explicit edge cases `fibRank_one`/`fibRank_zero`; and the lattice law
  with its coprime-product corollary.

## Rank-of-apparition completeness

The rank layer (targets 3 and 4) is **fully completed**, not deferred. The needed infrastructure
(existence via the reversible shift, minimality via `Nat.find`) is supported entirely from Mathlib,
so no partial definitions remain. The admissible range and edge cases are made explicit above.
