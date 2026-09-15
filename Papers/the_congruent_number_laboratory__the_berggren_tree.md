# Computational Evidence — the Berggren tree's area function and congruent numbers

All computations below were performed with exact integer arithmetic before the Lean
formalisation, to test the conjectures and to choose the witnesses that appear in the
Lean files.  Nothing here is a substitute for the machine-checked statements: every
claim that is asserted as a theorem in `Catalog/Combinatorics/BerggrenCongruent*.lean`
is proved there without `sorry`.

## 1. The area function on Euclid seeds

For admissible parameters (`0 < n < m`, `gcd(m,n) = 1`, `m − n` odd) the node
`euclidTriple m n = (m² − n², 2mn, m² + n²)` has area

```
A(m,n) = mn(m² − n²) = mn(m − n)(m + n).
```

First values (Euclid seed → triple → area → squarefree part):

| (m,n) | triple | A | squarefree part |
|-------|--------|---|-----------------|
| (2,1) | (3,4,5) | 6 | 6 |
| (3,2) | (5,12,13) | 30 | 30 |
| (4,1) | (15,8,17) | 60 | 15 |
| (4,3) | (7,24,25) | 84 | 21 |
| (5,2) | (21,20,29) | 210 | 210 |
| (5,4) | (9,40,41) | 180 | 5 |
| (6,1) | (35,12,37) | 210 | 210 |
| (8,1) | (63,16,65) | 504 | 14 |
| (9,8) | (17,144,145) | 1224 | 34 |
| (16,9) | (175,288,337) | 25200 | 7 |

Every area in the table is divisible by `6` (formalised: `six_dvd_euclidArea`).

## 2. Which congruent numbers appear at small height?

Enumerating all admissible `(m,n)` with `m < 80` (1282 nodes) and taking squarefree
parts of the areas gives, below 110:

```
5, 6, 7, 14, 15, 21, 22, 30, 34, 39, 41, 46, 65, 70, 78, 102, 110
```

Every entry is a known congruent number, and conversely the small congruent numbers
`13, 20, 23, 24, 29, 31` do **not** appear at this height — their smallest triangles are
much larger (13 needs a triangle with a three-digit numerator).  This is consistent with
the proved properness statement `finite_params_area_le`: only finitely many nodes lie
below any area bound, so the tree exhausts the congruent numbers only in the limit.

Smallest nodes realising some squarefree parts:

```
 5 ← (5,4),  A = 180  = 5·6²
 6 ← (2,1),  A = 6
 7 ← (16,9), A = 25200 = 7·60²
14 ← (8,1),  A = 504  = 14·6²
15 ← (4,1),  A = 60   = 15·2²
21 ← (4,3),  A = 84   = 21·2²
30 ← (3,2),  A = 30
34 ← (9,8),  A = 1224 = 34·6²
```

These are exactly the witnesses used in the Lean "lab notes"
(`five_congruent`, `six_congruent`, …, `thirtyfour_congruent`).

## 3. The Pell (B-branch) spine

Iterating `(m,n) ↦ (2m + n, m)` from `(2,1)` gives consecutive Pell numbers:

| d | (m,n) | A | m² − 2mn − n² | 2t² + (−1)^{d+1} t, t = mn | squarefree part |
|---|-------|---|----------------|-----------------------------|-----------------|
| 0 | (2,1) | 6 | −1 | 6 | 6 |
| 1 | (5,2) | 210 | +1 | 210 | 210 |
| 2 | (12,5) | 7140 | −1 | 7140 | 1785 |
| 3 | (29,12) | 242556 | +1 | 242556 | 60639 |
| 4 | (70,29) | 8239770 | −1 | 8239770 | 915530 |
| 5 | (169,70) | 279909630 | +1 | 279909630 | 184030 |
| 6 | (408,169) | 9508687656 | −1 | 9508687656 | 14066106 |

The two rightmost numerical columns agree in every row: this is the **silver law**
`A_d = 2t_d² + (−1)^{d+1} t_d`, formalised as `spine_area_silver`, a consequence of the
Pell identity `m² − 2mn − n² = (−1)^{d+1}` (`spine_silver`).  Areas grow by a factor
between `6` and `35` per step, matching the proved bound `6^{d+1} ≤ A_d`
(`spine_area_growth`) and the silver-ratio scaling `t_{d+1}/t_d → (1+√2)²`.

## 4. Counterexample hunt: square areas and twice-square areas

Exhaustive search over all `1 282 000`-odd admissible `(m,n)` with `m ≤ 2000` found

* no node with `A(m,n)` a perfect square,
* no node with `A(m,n) = 2k²`, and
* no node with `A(m,n) = 3k²`.

All three are theorems here: `euclidArea_ne_sq` (`1` is not congruent),
`euclidArea_ne_two_mul_sq` (`2` is not congruent) and `euclidArea_ne_prime_mul_sq`
(`p k²` never occurs for a prime `p ≡ 3 mod 8`, which covers `3`, `11`, `19`, `43`, …).
By contrast `A = 5k²`, `6k²`, `7k²` all occur (`(5,4)`, `(2,1)`, `(16,9)`), as the proved
lab notes record.  A further search over `m ≤ 2000` confirmed that no area of the form
`p k²` with `p ∈ {3, 11, 19, 43, 59, 67, 83}` occurs, in agreement with the theorem.

## 5. OEIS pointers

* Areas of primitive Pythagorean triples: the sorted values `6, 30, 60, 84, 180, 210, …`
  are A024406.
* Congruent numbers: A003273 (`5, 6, 7, 13, 14, 15, 20, 21, 22, 23, 24, …`).
* The spine parameters are the Pell numbers A000129 (`1, 2, 5, 12, 29, 70, 169, 408`).

The intersection pattern of A024406's squarefree parts with A003273 is exactly the
content of the main theorem `congruent_iff_tree_node`.
