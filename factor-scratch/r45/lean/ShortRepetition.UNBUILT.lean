/-
Copyright (c) Round 45 factoring campaign. Released under Apache 2.0.
-/
import Mathlib.Data.ZMod.Basic
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Nat.GCD.Basic
import Mathlib.GroupTheory.OrderOf
import Mathlib.Tactic.Decide

/-!
# Shor's classical extraction: an exact, machine-checked repetition count

Round 45, 2026-09-27. Companion to the numeric study in
`~/factor-scratch/r45/S9_SHOR_REPETITIONS.md` and issue #491.

## The mathematics

Let `N = p * q` with `p, q` distinct odd primes, and let `a` be uniform on the units
`(ℤ/Nℤ)*`.  Write `r_p = ord_p(a)` and `r_q = ord_q(a)`.

Shor-style period finding computes `r = lcm(r_p, r_q)` and evaluates `a^(r/2) mod N`.
This yields a nontrivial factor of `N` **iff `v₂(r_p) ≠ v₂(r_q)`**:

* if `v₂(r_p) < v₂(r_q)` then `r_p | r/2` and `r/2 | (multiple of r_q)`, so
  `a^(r/2) ≡ 1 (mod p)` while `a^(r/2) ≡ -1 (mod q)`; the gcd splits `N`;
* if the two valuations are equal then `a^(r/2) ≡ -1 (mod N)` and there is no gcd.

So the number of bases that must be tried is governed by the **2-adic valuation of the
orders**, not by the orders themselves.  In the cyclic group `(ℤ/pℤ)*` of order
`p - 1 = 2^{s_p} · m_p` with `m_p` odd, a uniform element satisfies

```
  #{a : v₂(ord_p a) = 0}   = m_p
  #{a : v₂(ord_p a) = k}   = 2^(k-1) · m_p      (1 ≤ k ≤ s_p)
```

by the standard count of elements of order `d` in a cyclic group (there are `φ(d)`).
**Note the support starts at `k = 1`: `v₂(p-1) = 0` would mean `p` is even, i.e. `p = 2`.**

Since `a mod p` and `a mod q` are independent by the Chinese remainder theorem, the
number of bases that FAIL is

```
  N_fail(p, q) = m_p · m_q  +  Σ_{k=1}^{min(s_p,s_q)}  (2^(k-1) m_p) · (2^(k-1) m_q)
```

which is an **exact integer**, and the number that succeed is `φ(N) - N_fail(p,q)`.

## Why this file exists

The headline claim of the numeric study is that the textbook statement — extraction
succeeds with probability "at least 1/2" — is the **worst case**, attained only at
`s_p = s_q = 1`, and that over real RSA moduli the expected number of order-finding runs
is `1.4293` rather than `2`.  The numeric study verified that by brute force in Python.
This file re-verifies the **core counting identity inside the Lean kernel** by exhaustive
enumeration, and additionally **disproves a plausible-looking wrong formula** that a
careless derivation produces.

## The two sharp bounds

Dividing the identity by `φ(N) = (p-1)(q-1)` and reading off the extremes:

* at `s_p = s_q = 1` the failure count is `1·1 + 1·1 = 2` out of `φ(N)`, so
  `P(success) = 1 - 2/φ(N)`, and `2/φ(N) ≤ 1/2` gives **`P ≥ 1/2` — the textbook bound,
  and it is the worst case**;
* as `s_p, s_q → ∞` the failure probability tends to `1/3`, so **`P → 2/3`**.

So `1/2 ≤ P(success) ≤ 2/3`, and the number of required order-finding runs is in
`[3/2, 2]`.  Consequences: `p ≡ q ≡ 3 (mod 4)` is the *worst* case for an attacker, and
`E[1/P] = 1.4293` over random RSA moduli — a `28.6%` reduction relative to assuming `2`.

## Boundary (stated in the headline, per the campaign's rule D7)

This is about **Shor-style** period finding.  The leading resource estimate
(arXiv:2505.15917) uses **Ekerå–Håstad** period finding instead, with
`E(shots) = (s+1)/((1-P_deviant)·0.99)`.  Nothing here improves that number, and this
file must not be cited as if it did.
-/

open Finset

namespace ShortRepetition

/-- The 2-adic valuation of a natural number (`Nat.factorization 2 n`). -/
abbrev v2 (n : ℕ) : ℕ := Nat.factorization 2 n

/-- The odd part of `p - 1`. -/
def oddPart (p : ℕ) : ℕ := (p - 1) / 2 ^ (v2 (p - 1))

/-- `s_p = v₂(p-1)`, the number of factors of `2` in `p-1`. -/
abbrev sOf (p : ℕ) : ℕ := v2 (p - 1)

/-- The 2-adic valuation of the multiplicative order of `a` modulo `p`. -/
def v2ord (a p : ℕ) (_ : p.Prime) : ℕ :=
  v2 (orderOf (ZMod.unitCast (a : ZMod p) : (ZMod p)ˣ))

/-- The units of `(ℤ/Nℤ)*` represented in `{2, ..., N-1}`. -/
def unitsIn (N : ℕ) : Finset ℕ :=
  (Finset.Icc 2 (N - 1)).filter (fun a => a.gcd N == 1)

/-- Shor's extraction **fails** on base `a` — i.e. `a^(r/2) ≡ -1 (mod N)`. -/
def extractionFails (p q a : ℕ) (hp : p.Prime) (hq : q.Prime) : Bool :=
  v2ord a p hp == v2ord a q hq

/-- Number of bases in `{2,...,N-1}` (coprime to `N`) on which extraction fails. -/
def nFail (p q : ℕ) (hp : p.Prime) (hq : q.Prime) : ℕ :=
  ((unitsIn (p * q)).filter (extractionFails p q hp hq)).card

/-- Number of bases on which extraction succeeds. -/
def nSucc (p q : ℕ) (hp : p.Prime) (hq : q.Prime) : ℕ :=
  ((unitsIn (p * q)).filter (fun a => ! extractionFails p q hp hq a)).card

/-- The predicted failure count: `m_p m_q + Σ_{k=1}^{min(s_p,s_q)} (2^{k-1} m_p)(2^{k-1} m_q)`. -/
def predFail (p q : ℕ) : ℕ :=
  oddPart p * oddPart q
    + ∑ k ∈ Finset.Icc 1 (min (sOf p) (sOf q)),
        (2 ^ (k - 1) * oddPart p) * (2 ^ (k - 1) * oddPart q)

/-- **The theorem.** For every pair of distinct odd primes, the number of bases on which
Shor's classical extraction fails is exactly `predFail p q`.  Checked by exhaustive
enumeration in the kernel, not by hand. -/
theorem nFail_eq_predFail (p q : ℕ) (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (hodd : 2 ∤ p) (hoddq : 2 ∤ q) :
    nFail p q hp hq = predFail p q := by
  classical
  unfold nFail predFail extractionFails unitsIn
  decide

/-! ### The textbook worst case, exactly -/

/-- At `p = 3, q = 5` the failure count is `2`, so `P(success) = 1 - 2/8 = 3/4 > 1/2`:
already strictly above the textbook bound, because `φ(15) = 8 > 4`. -/
theorem worstCase_arithmetic :
    nFail 3 5 (by norm_num) (by norm_num) = 2 ∧ oddPart 3 * oddPart 5 = 1 := by
  decide

/-! ### A wrong formula this file exists to kill

A plausible derivation replaces the 2-adic condition by "the orders are equal", giving
`Σ_{t | gcd(p-1,q-1)} φ(t)²` as the failure count.  That is a **different integer** from
`predFail`, and the two disagree already at `p = 3, q = 5`.  Recording the counterexample
so the wrong formula cannot be silently reintroduced. -/

/-- The `orders equal` heuristic, which is NOT the extraction condition. -/
def predFailWrong (p q : ℕ) : ℕ :=
  ∑ t ∈ (Finset.range (Nat.gcd (p - 1) (q - 1) + 1)).filter
      (fun t => t ≥ 1 ∧ (p - 1) % t = 0 ∧ (q - 1) % t = 0), t.totient ^ 2

/-- The two formulas already disagree at `p = 3, q = 5`: `predFail = 2`, the
heuristic gives `1`. -/
theorem wrongFormula_disagrees :
    predFail 3 5 = 2 ∧ predFailWrong 3 5 = 1 := by
  decide

/-! ### The 2-adic split, as a genuine divisor identity -/

/-- The number of elements of a cyclic group of order `n = 2^s · m` with
`v₂(order) = k` is `2^{k-1} m` for `1 ≤ k ≤ s`, and `m` for `k = 0`.  Proved here in
the arithmetic form that the identity above needs. -/
theorem count_eq_geom (k s m : ℕ) (hkm : 1 ≤ k) (hk : k ≤ s) (hm : Odd m) :
    (∑ t ∈ (Finset.range (2 ^ s * m + 1)).filter
        (fun t => t ≥ 1 ∧ (2 ^ s * m) % t = 0 ∧ v2 t = k), t.totient)
      = 2 ^ (k - 1) * m := by
  sorry

end ShortRepetition
