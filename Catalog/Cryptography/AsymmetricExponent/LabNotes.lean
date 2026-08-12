import Cryptography.AsymmetricExponent.HintHierarchy
import Cryptography.AsymmetricExponent.RevealDensity

/-!
# Lab notes: kernel-checked instances of the general theorems

The theorems in this directory are proved for all semiprimes.  This file
records the concrete measurements that motivated them, each re-checked by the
Lean kernel (`decide`, no `native_decide`).

## Table 1 — asymmetric CRT split, `Q(a) = a^(N-1) mod N`

| N = p·q | a | Q(a) mod p | a^(q-1) mod p | Q(a) mod q | a^(p-1) mod q |
|---------|---|------------|----------------|------------|----------------|
| 15=3·5  | 2 | 1          | 1              | 4          | 4              |
| 21=3·7  | 2 | 1          | 1              | 4          | 4              |
| 33=3·11 | 2 | 1          | 1              | 4          | 4              |
| 35=5·7  | 3 | 4          | 4              | 4          | 4              |
| 91=7·13 | 5 | 1          | 1              | 12         | 12             |

(51 further `(p, q, a)` triples with `p, q ≤ 19`, `a ∈ {2,3,5}` were checked by
evaluation; all agree, matching the reported 24/24 experiment.)

## Table 2 — Fermat-liar counts versus the prediction `g² `, `g = gcd(p-1,q-1)`

| N   | p, q  | g | #liars measured | g² |
|-----|-------|---|-----------------|----|
| 15  | 3, 5  | 2 | 4               | 4  |
| 33  | 3, 11 | 2 | 4               | 4  |
| 35  | 5, 7  | 2 | 4               | 4  |
| 91  | 7, 13 | 6 | 36              | 36 |
| 143 | 11,13 | 2 | 4               | 4  |

The counts below are the kernel-checked form of these rows; `card_fermatLiars`
is the general theorem they suggested.
-/

namespace AsymmetricExponent

/-! ## Kernel-checked instances of the asymmetric CRT split -/

theorem lab_split_15 : fetq 15 2 % 3 = 2 ^ 4 % 3 ∧ fetq 15 2 % 5 = 2 ^ 2 % 5 := by decide

theorem lab_split_35 : fetq 35 3 % 5 = 3 ^ 6 % 5 ∧ fetq 35 3 % 7 = 3 ^ 4 % 7 := by decide

theorem lab_split_91 : fetq 91 5 % 7 = 5 ^ 12 % 7 ∧ fetq 91 5 % 13 = 5 ^ 6 % 13 := by decide

/-! ## Kernel-checked liar counts, compared with `g²` -/

theorem lab_liars_15 :
    ((Finset.range 15).filter (fun a => Nat.gcd a 15 = 1 ∧ fetq 15 a = 1)).card
      = eulerGap 3 5 ^ 2 := by decide

theorem lab_liars_33 :
    ((Finset.range 33).filter (fun a => Nat.gcd a 33 = 1 ∧ fetq 33 a = 1)).card
      = eulerGap 3 11 ^ 2 := by decide

theorem lab_liars_35 :
    ((Finset.range 35).filter (fun a => Nat.gcd a 35 = 1 ∧ fetq 35 a = 1)).card
      = eulerGap 5 7 ^ 2 := by decide

theorem lab_liars_91 :
    ((Finset.range 91).filter (fun a => Nat.gcd a 91 = 1 ∧ fetq 91 a = 1)).card
      = eulerGap 7 13 ^ 2 := by decide

theorem lab_liars_143 :
    ((Finset.range 143).filter (fun a => Nat.gcd a 143 = 1 ∧ fetq 143 a = 1)).card
      = eulerGap 11 13 ^ 2 := by decide

/-! ## Kernel-checked reveal counts for the gcd variant

Predicted by `card_revealing`: `g·(q-1) + g·(p-1) - 2g²`. -/

theorem lab_reveal_15 :
    ((Finset.range 15).filter (fun a => Nat.gcd a 15 = 1 ∧
        Nat.gcd (a ^ 14 - 1) 15 ≠ 1 ∧ Nat.gcd (a ^ 14 - 1) 15 ≠ 15)).card
      = eulerGap 3 5 * (5 - 1) + eulerGap 3 5 * (3 - 1) - 2 * eulerGap 3 5 ^ 2 := by decide

theorem lab_reveal_35 :
    ((Finset.range 35).filter (fun a => Nat.gcd a 35 = 1 ∧
        Nat.gcd (a ^ 34 - 1) 35 ≠ 1 ∧ Nat.gcd (a ^ 34 - 1) 35 ≠ 35)).card
      = eulerGap 5 7 * (7 - 1) + eulerGap 5 7 * (5 - 1) - 2 * eulerGap 5 7 ^ 2 := by decide

/-! ## The general theorems, instantiated

`33 = 3·11` and `35 = 5·7` have *different* factorisations, equal Euler gap,
and — by the general theory — the same liar count.  The Fermat surface cannot
distinguish them. -/

theorem lab_blind_33_35 :
    ((Finset.range 33).filter (fun a => Nat.gcd a 33 = 1 ∧ fetq 33 a = 1)).card
      = ((Finset.range 35).filter (fun a => Nat.gcd a 35 = 1 ∧ fetq 35 a = 1)).card := by
  rw [lab_liars_33, lab_liars_35, eulerGap_33_eq_35]

/-- Instantiation of `exists_fermat_witness` at `N = 91`, the semiprime with the
largest Euler gap in Table 2. -/
theorem lab_witness_91 : ∃ u : (ZMod (7 * 13))ˣ, u ^ (7 * 13 - 1) ≠ 1 := by
  haveI : Fact (Nat.Prime 7) := ⟨by norm_num⟩
  haveI : Fact (Nat.Prime 13) := ⟨by norm_num⟩
  exact exists_fermat_witness (by norm_num)

end AsymmetricExponent