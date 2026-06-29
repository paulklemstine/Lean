# Computational Evidence — Primality Testing (AKS criterion & Miller–Rabin)

All computations below were run in Lean (`#eval` / `native_decide`) against
Mathlib, and the qualitative conclusions are exactly what the formal theorems in
`AKSCriterion.lean` and `MillerRabin.lean` establish.

## 1. The AKS polynomial criterion `(X+a)^n = X^n + a` over `ZMod n`

For a base `a` coprime to `n`, the identity holds **iff** `n` is prime
(`aks_criterion`). Spot checks for `2 ≤ n ≤ 13`, base `a = 1`:

| n  | prime? | identity `(X+1)^n = X^n + 1` in `(ZMod n)[X]` |
|----|--------|----------------------------------------------|
| 2  | yes    | holds   |
| 3  | yes    | holds   |
| 4  | no     | fails (coeff of `X^2` is `C(4,2)=6 ≡ 2 ≠ 0`) |
| 5  | yes    | holds   |
| 6  | no     | fails (coeff of `X^3` is `C(6,3)=20 ≡ 2 ≠ 0`) |
| 7  | yes    | holds   |
| 9  | no     | fails (coeff of `X^3` is `C(9,3)=84 ≡ 3 ≠ 0`) |
| 11 | yes    | holds   |
| 13 | yes    | holds   |

The failing inner coefficient is always `C(n,q)·a^{n-q}` for a prime divisor `q`,
which is the content of the key lemma `not_dvd_choose_prime_dvd : n ∤ C(n,q)`.

## 2. Carmichael numbers: Fermat liars but AKS-detectable

Fermat's congruence `a^n ≡ a (mod n)` for **all** `a` (a Carmichael number)
fails to detect compositeness. Enumerating `n < 1106` with the Nat predicate
`∀ a < n, a^n ≡ a (mod n)` and `n` composite:

```
#eval (List.range 1106).filter (fun n => n > 1 && ¬ Nat.Prime n && fermatLiarAll n)
-- output: [561, 1105]
```

These are the first two Carmichael numbers — **OEIS A002997** (561, 1105, 1729,
2465, 2821, …). The smallest, `561 = 3·11·17`, is the witness used in
`carmichael_561_fools_fermat_not_aks`:
`∀ a : ZMod 561, a^561 = a` (verified by `native_decide`) yet the AKS identity
fails for base `2`.

Korselt's criterion check for `561` (`n-1 = 560`):
`560 % 2 = 0`, `560 % 10 = 0`, `560 % 16 = 0`, i.e. `(p-1) ∣ (n-1)` for every
prime `p ∈ {3, 11, 17}` and `561` is squarefree — confirming it is Carmichael.

## 3. Miller–Rabin soundness sanity checks

For a prime `n` with `n - 1 = 2^s·d` (`d` odd), every base `a` with `n ∤ a`
satisfies `a^d ≡ 1` or `a^{2^r d} ≡ -1 (mod n)` for some `r < s`
(`miller_rabin_sound`). Example `n = 561` is **not** prime, and base `a = 2` is a
Miller–Rabin *witness*: with `560 = 2^4 · 35`,

```
2^35  mod 561 = 263            (≠ 1)
2^(2·35) mod 561 = 166         (≠ ±1)
2^(4·35) mod 561 = 67          (≠ ±1)
2^(8·35) mod 561 = 1           (a nontrivial square root of 1 appeared: 67² ≡ 1)
```

so `561` is exposed as composite by base `2`, consistent with the field-theoretic
square-root-of-unity argument behind `sqrt_one_in_ZMod_prime`: a nontrivial
square root of `1` can only exist modulo a composite.

## Conclusion

The computational evidence matches the formal results: the AKS identity is an
exact primality test on coprime bases, Carmichael numbers (A002997) are precisely
where the Fermat test fails while AKS does not, and Miller–Rabin never
misclassifies a prime.
