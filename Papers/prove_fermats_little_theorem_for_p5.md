# Computational Evidence — Fermat's Little Theorem for p = 5

## 1. Small-case calculations

We tabulate `a^5 - a` and its residues modulo `5` and `30` for `a = 0..11`.

| a | a^5 - a | (a^5 - a) mod 5 | (a^5 - a) mod 30 |
|---|---------|-----------------|-------------------|
| 0 | 0       | 0 | 0 |
| 1 | 0       | 0 | 0 |
| 2 | 30      | 0 | 0 |
| 3 | 240     | 0 | 0 |
| 4 | 1020    | 0 | 0 |
| 5 | 3120    | 0 | 0 |
| 6 | 7770    | 0 | 0 |
| 7 | 16800   | 0 | 0 |
| 8 | 32760   | 0 | 0 |
| 9 | 59040   | 0 | 0 |
| 10| 99990   | 0 | 0 |
| 11| 161040  | 0 | 0 |

Verified in Lean:

```
#eval (List.range 12).map (fun a => ((a:Int)^5 - a) % 5)   -- all 0
#eval (List.range 12).map (fun a => ((a:Int)^5 - a) % 30)  -- all 0
```

Both lists are uniformly `0`. This confirms the headline claim `5 ∣ a^5 - a`
**and** the sharper claim `30 ∣ a^5 - a`.

## 2. Sequence identification

`a^5 - a` for `a = 1,2,3,…` gives `0, 30, 240, 1020, 3120, 7770, …`.
Dividing by 30 yields `0, 1, 8, 34, 104, 259, …`. The generating object is the
integer polynomial `a(a-1)(a+1)(a^2+1)`, matching the factorisation used in the
formal development (`pow_five_sub_factor`).

## 3. Counterexample hunt

The universal claim `5 ∣ a^5 - a` was tested on all residues mod 5 (via
`interval_cases`/`decide` on `ZMod 5`), and the `30`-strengthening on all
residues mod 30. No counterexample exists: every residue class satisfies the
congruence, because `x^5 = x` holds for every `x` in each of `ZMod 2`, `ZMod 3`,
`ZMod 5`.

## 4. Why the strengthening to 30 holds

`p - 1 ∣ 4` for each of `p = 2, 3, 5` (namely `1 ∣ 4`, `2 ∣ 4`, `4 ∣ 4`).
Hence by Fermat's Little Theorem `a^5 ≡ a (mod p)` for each such prime, and since
`2, 3, 5` are pairwise coprime with product `30`, we get `a^5 ≡ a (mod 30)`.
`30` is optimal: `a = 2` gives `a^5 - a = 30`, so no larger constant divides all
values.
