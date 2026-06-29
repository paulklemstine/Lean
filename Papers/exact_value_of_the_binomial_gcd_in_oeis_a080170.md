# Computational Evidence — OEIS A080170 binomial GCD

Definitions used throughout (all computed in Lean via `#eval`):

* `D(k) = gcd_{2 ≤ q ≤ k+1} C(q·k, k)`  (OEIS **A080170**, indexed from `k ≥ 2`).
* `P(n) = max_{p ∣ n} p^{v_p(n)}`        (Stephan's "largest exact prime-power component").
* Stephan's closed form (conjecture 17): `D(k) = P(k+1)` when `(k+1)/P ≤ P`, else `1`.

## 1. Small-case calculations: `D(k)` vs the conjectured value `P(k+1)`

`(k, D(k), conjectured value, equal?)` for `k = 2 … 41`:

```
(2,3,3,T) (3,4,4,T) (4,5,5,T) (5,3,3,T) (6,7,7,T) (7,8,8,T) (8,9,9,T) (9,5,5,T)
(10,11,11,T) (11,2,4,F) (12,13,13,T) (13,7,7,T) (14,5,5,T) (15,16,16,T) (16,17,17,T)
(17,9,9,T) (18,19,19,T) (19,5,5,T) (20,7,7,T) (21,11,11,T) (22,23,23,T) (23,4,8,F)
(24,25,25,T) (25,13,13,T) (26,27,27,T) (27,7,7,T) (28,29,29,T) (29,1,1,T) (30,31,31,T)
(31,32,32,T) (32,11,11,T) (33,17,17,T) (34,7,7,T) (35,3,9,F) (36,37,37,T) (37,19,19,T)
(38,13,13,T) (39,2,8,F) (40,41,41,T) (41,7,7,T)
```

**The conjectured exact value is WRONG at `k = 11, 23, 35, 39`** (and, continuing the
search to `k = 201`, also at `44, 47, 55, 62, 71, 79, …`). The first counterexample
is `k = 11`.

## 2. Counterexample detail (`k = 11`, `n = 12 = 2²·3`)

The eleven terms `C(q·11, 11)` for `q = 2 … 12` and their `2`- and `3`-adic valuations:

```
q :  2  3  4  5  6  7  8  9 10 11 12
v2:  3  4  2  1  6  1  4  2  2  3  6
v3:  1  2  0  3  1  0  3  2  1  1  1
```

* `min_q v2 = 1` (attained at `q = 5, 7`)  ⇒ the gcd contains `2¹`.
* `min_q v3 = 0` (attained at `q = 4, 7`)  ⇒ the gcd contains no factor `3`.

Hence `D(11) = 2`, whereas Stephan predicts `P(12) = max(2², 3) = 4`. The single
base-2 carry in `C(55, 11)` (`q = 5`) is what kills the `2`-part down to `2¹`:
`C(55,11) = 119653565850 ≡ 2 (mod 4)`. This is exactly the argument formalised in
`exact_value_conjecture_false`.

## 3. What survives — the two conjectures that hold on the whole tested range

Tested for all `2 ≤ k ≤ 201` with no counterexample:

* **(Nontriviality / claim a)** `D(k) > 1  ⟺  (k+1)/P ≤ P`.
* **(Prime-power shape / claim c)** every `D(k)` is `1` or a prime power.
* **(Divisibility)** `D(k) ∣ (k+1)` always.
* **(Prime powers / claim H4)** on `n = p^a` Stephan's value is exact:
  `D(p^a - 1) = p^a` for `(p,a) ∈ {(2,2),(2,3),(2,4),(3,2),(3,3),(5,2),(5,3),(7,2)}`,
  i.e. `D(3)=4, D(7)=8, D(15)=16, D(8)=9, D(26)=27, D(24)=25, D(124)=125, D(48)=49`.
* **(Prime fibre)** `D(p-1) = p` for every prime `p ≤ 41` (`p ∣ C(q(p-1),p-1)` for all `2 ≤ q ≤ p`).

## 4. A corrected closed form (matches `D(k)` for all `2 ≤ k ≤ 201`)

Let `p` range over primes dividing `n = k+1`, write `p^a ∥ n` and `m = n/p^a`.
Define the per-prime exponent `b(p) = a − ⌊log_p m⌋` (only kept when `b(p) ≥ 1`).
Then

```
D(k) = max_{p ∣ n}  p^{ a − ⌊log_p m⌋ }        (and 1 if every exponent is ≤ 0).
```

This reproduces every value `D(k)` for `2 ≤ k ≤ 201`. Stephan's `P` is the special
case `m = 1` (`n` a prime power), where `⌊log_p 1⌋ = 0` and the formula collapses
to `p^a = P`. The corrected formula explains the failures: each counterexample has
`m > 1` and `⌊log_p m⌋ ≥ 1`, so the true exponent drops below `a`.

Mismatch table `(k, n, D(k), P(n))` from the search:

```
(11,12,2,4) (23,24,4,8) (35,36,3,9) (39,40,2,8) (44,45,3,9) (47,48,8,16)
(55,56,2,8) (62,63,3,9) (71,72,3,9) (79,80,4,16)
```

## 5. OEIS

The sequence `D(2), D(3), … = 3, 4, 5, 3, 7, 8, 9, 5, 11, 2, 13, 7, 5, 16, 17, …`
is OEIS **A080170** (gcd of `C(q·k, k)`). The conjectured closed form is item (17)
on Ralf Stephan's "Prove or disprove: 100 conjectures from the OEIS"; the data above
*disproves* the exact-value form and isolates the regimes where it is correct.

All computations were performed with exact integer / `Nat` arithmetic in Lean 4
(`#eval`), so no floating point or sampling error is involved.
