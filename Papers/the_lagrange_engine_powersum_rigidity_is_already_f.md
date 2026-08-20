# Computational Evidence

All numbers below were produced by `#eval` **on the Lean definitions themselves**
(`InvisibleWeights.moment`, `InvisibleWeights.binWeight`, and the search helpers reproduced
at the end of this file), not by an external script.  Statements that are *proved* in Lean
are marked ✅ and point to the theorem; statements that are only exploratory are marked ⚠️.

Notation: a weight vector `e : ℕ → ℤ` on the nodes `{0,…,N}` is **invisible at window `K`**
when `m_k(e) = ∑_{j ≤ N} e j · j^k = 0` for every `k < K`.  Its `ℓ¹` norm is `∑_{j ≤ N} |e j|`.

## 1. The binomial basis: moments and support

`moment 6 (binWeight (R := ℤ) 3 i) k` for `k = 0,…,4`:

| shift `i` | `k = 0` | `1` | `2` | `3` | `4` |
|-----------|---------|-----|-----|-----|-----|
| `i = 0`   | 0 | 0 | 0 | **6** | 36 |
| `i = 2`   | 0 | 0 | 0 | **6** | 84 |

The window `k < 3` is blind to both, and the first visible moment is `3! = 6`, independent of
the shift.  ✅ `binWeight_invisible`, `moment_binWeight_top`.

Basis rows at `N = 5`, `K = 3` (entries `j = 0,…,5`):

```
binWeight 3 0 = [-1,  3, -3,  1,  0,  0]
binWeight 3 1 = [ 0, -1,  3, -3,  1,  0]
binWeight 3 2 = [ 0,  0, -1,  3, -3,  1]
```

Each has support `4 = K + 1` (✅ `card_nodeSupport_binWeight`) and `ℓ¹ = 8 = 2^K`.
Three rows at `N = 5`, `K = 3` matches ✅ `finrank_invisibleSpace = N + 1 - K = 3`.

## 2. Counterexample hunt: is `2^K` the minimal `ℓ¹`?

Search: for each `K` and each `N`, enumerate all coefficient vectors
`c ∈ {-2,…,2}^{N+1-K}`, form `e = ∑_i c_i · binWeight K i` (by the structure theorem this
enumerates every integral invisible vector with bounded coefficients), and record the least
nonzero `ℓ¹`.

| `K` | minimal `ℓ¹` found, by `N` | best | `2^K` | `2K` |
|-----|-----------------------------|------|-------|------|
| 1 | `N=1,…,5`: 2, 2, 2, 2, 2 | 2 | 2 | 2 |
| 2 | `N=2,…,6`: 4, 4, 4, 4, 4 | 4 | 4 | 4 |
| 3 | `N=3,…,6`: 8, **6**, 6, 6 | 6 | 8 | 6 |
| 4 | `N=4,…,9`: 16, 12, 12, **8**, 8, 8 | 8 | 16 | 8 |
| 5 | `N=5,…,11`: 32, 20, 20, **14**, 14, 14, 14 | 14 | 32 | 10 |

⚠️ These are *upper* bounds for the true minimum (bounded coefficient box `r = 2`, bounded
`N`); the `K = 5` value `14 > 2K = 10` reflects the bounded range, since ideal
Prouhet–Tarry–Escott solutions of degree 4 need nodes far beyond `N = 11`.

**Conclusion of the hunt.** The conjecture `ℓ¹ ≥ 2^K` is *false*, first at `K = 3`.
The minimal witness found is

```
e = (-1, 2, 0, -2, 1)   on nodes {0,1,2,3,4},   ℓ¹ = 6 < 8 = 2^3
```

i.e. the coefficient vector of `(X-1)^3 (X+1)`.  Its moments are
`m_0 = m_1 = m_2 = 0`, `m_3 = 12`.

✅ Formalised: `pteWitness`, `pteWitness_invisible`, `pteWitness_moment_top`,
`pteWitness_l1`, and the propagation to all `K ≥ 3` in
`exists_invisible_l1_lt_two_pow` / `two_pow_l1_conjecture_false`.
✅ The boundary is exactly located: for `K ≤ 2` the bound `ℓ¹ ≥ 2^K` is *true*
(`l1_ge_two_pow_of_window_le_two`).

⚠️ The first formal propagation (difference operator, doubling per step) gives `6 · 2^{K-3}`:
`12` at `K = 4` and `24` at `K = 5`, against the searched values `8` and `14`.  So that bound
is correct but not optimal.

✅ A second propagation, by *convolution* rather than differencing
(`exists_invisible_l1_le_six_pow`), does much better: `ℓ¹ ≤ 6^n` at window `K = 3n`, against
`2^K = 8^n`.  Check at `n = 2` (`#eval`): convolving the witness with itself gives

```
e = [1, -4, 4, 4, -10, 4, 4, -4, 1]        on nodes {0,…,8}
moments  m_0 … m_7 = 0, 0, 0, 0, 0, 0, 2880, 80640
ℓ¹(e) = 36 = 6²   against   2^6 = 64
```

The vector is invisible exactly to the window `k < 6`, and its first visible moment
`2880 = C(6,3) · 12 · 12` matches ✅ `moment_kconv_top` on the nose.  Closing the remaining gap
between `6^{K/3} ≈ 1.817^K` and the conjectured `2K` is Conjecture 1 of
`FUTURE_DIRECTIONS.md`.

## 3. Rigidity data at the sharp support bound

Two invisible vectors on exactly `K + 1 = 4` nodes, checked against the identity
`e i · ∏_{j ≠ i} (i - j) = m_K(e)` (✅ `minimal_support_divided_difference`):

| node set `S` | `e` | `i` | `e i · ∏_{j≠i}(i-j)` | `m_3(e)` |
|--------------|-----|-----|----------------------|----------|
| `{0,1,2,3}` | `(-1, 3, -3, 1)` | 0 | `-1 · (-1)(-2)(-3) = 6` | 6 |
| `{0,1,2,3}` | `(-1, 3, -3, 1)` | 1 | `3 · (1)(-1)(-2) = 6` | 6 |
| `{0,1,3,4}` | `(-1, 2, -2, 1)` | 0 | `-1 · (-1)(-3)(-4) = 12` | 12 |
| `{0,1,3,4}` | `(-1, 2, -2, 1)` | 4 | `1 · (4)(3)(1) = 12` | 12 |

The sign patterns `-,+,-,+` in both rows are forced, not accidental:
✅ `minimal_support_sign_alternates`.

## 3b. How close are the proved bounds?

| `K` | proved lower bound | best witness found | `2^K` |
|-----|--------------------|--------------------|-------|
| 1 | 2 (`l1_ge_of_invisible_int`) | 2 | 2 |
| 2 | 4 (`l1_ge_window_add_two`) | 4 | 4 |
| 3 | 6 (`l1_ge_window_add_three_of_odd`) | 6 | 8 |
| 4 | 6 (`l1_ge_window_add_two`) | 8 | 16 |
| 5 | 8 (`l1_ge_window_add_three_of_odd`) | ≤14 | 32 |

✅ The lower bounds are sharp at `K = 1, 2, 3`.  The upper witnesses for `K ≥ 4` are
exploratory (bounded search).

## 4. Sequence lookup

Invisible integral vectors are exactly the differences of two multisets with equal power sums
up to order `K - 1`, i.e. solutions of the **Prouhet–Tarry–Escott** problem of degree `K-1`
(✅ the dictionary `nearMiss_of_invisible` / `invisible_of_nearMiss`).  The classical size
bound "each side has at least `K` elements … " appears here as the proved pair
`card_nodeSupport_ge` (`≥ K+1` nodes in total) and `nearMiss_two_mul_card_ge`
(`2 · card ≥ K + 1` per side).  ⚠️ We deliberately do not assert an OEIS identifier for the
minimal-`ℓ¹` sequence `2, 4, 6, 8, ≤14, …`, since we have not verified a match; the first four
terms agree with `2K`, which is the ideal-PTE value.

## 5. Reproducing the search

```lean
import Applications.InvisibleWeightsSupport
open InvisibleWeights

def boxes (n r : ℕ) : List (List ℤ) :=
  match n with
  | 0 => [[]]
  | n+1 => (boxes n r).flatMap fun v =>
      ((List.range (2*r+1)).map fun i => (i : ℤ) - r).map fun a => a :: v

def evec (K : ℕ) (c : List ℤ) (N : ℕ) : List ℤ :=
  (List.range (N+1)).map fun j => (c.zipIdx.map fun p => p.1 * binWeight (R := ℤ) K p.2 j).sum

def minL1 (K N r : ℕ) : ℤ :=
  ((boxes (N+1-K) r).map fun c => ((evec K c N).map fun x => |x|).sum).filter (· ≠ 0)
    |>.foldl min 1000

#eval (List.range 4).map fun N => minL1 3 (N+3) 2   -- [8, 6, 6, 6]
#eval (List.range 6).map fun N => minL1 4 (N+4) 2   -- [16, 12, 12, 8, 8, 8]
#eval (List.range 7).map fun N => minL1 5 (N+5) 2   -- [32, 20, 20, 14, 14, 14, 14]
```
