import Mathlib
import Novelty.ZeroFitDialU64
import Pythagorean.ZeroFitDialBalanced60

/-!
# The radix-`q` tie-attenuation constant

## Research context (FACT round-51 #3, exp 521, `CELL-CLOSED-DIAL-HOLDS-60`)

Every ceiling in this thread is measured against the single constant `6/7`:
`Catalog.Novelty.ZeroFitDialU64.dyadic_spearmanSq` gives the exact uniform-draw ceiling
`(6/7)(1 + 1/(2^b(2^b+1)))` at bitlen `b`, and the fixed-weight results of
`Pythagorean.ZeroFitDialSparseWindow60` show that `6/7` is the level set of the half-weight
line.  This file answers the obvious question: **what is `6/7` a function of?**

The answer is the alphabet size.  For uniform draws of length `b` over a `q`-letter
alphabet the trailing-zero tie profile is the geometric profile with ratio `1/q`, and

```
ρ²(q, b) = (3q / (q² + q + 1)) · (1 + 1/(q^b (q^b + 1))).
```

At `q = 2` this is exactly `(6/7)(1 + 1/(2^b(2^b+1)))`, recovering the catalog value; the
universal constant is therefore `3q/(q²+q+1)`, i.e. `1 − (q−1)²/(q²+q+1)`.

## Main results

* `radixBlocks`, `radixBlocks_sum` — the `q`-adic trailing-zero tie profile
  (`(q−1)q^{b−1−k}` words with exactly `k` trailing zeros, plus the all-zero word).
* `radixBlocks_eq_dyadic` — at `q = 2` it is the catalog's `dyadicBlocks`, so this file is a
  strict generalisation and not a parallel development.
* `radix_spearmanSq` — the exact ceiling displayed above, for every `q ≥ 2` and `b ≥ 1`.
* `radix_ceiling_gt`, `radix_ceiling_tendsto_const` — the ceiling is strictly above the
  constant `3q/(q²+q+1)` at every finite length and converges to it.
* `radix_constant_strict_anti` — the constant is strictly decreasing in the alphabet size:
  richer alphabets tie less, so the dial has *less* headroom, not more.
* `band_is_binary_specific` — a deployment consequence with teeth.  The validation band
  `[0.55, 0.85]` used at bitlen 60 is admissible only because the alphabet is binary: over
  any alphabet with `q ≥ 3` letters and length `b ≥ 2` the ceiling is at most `7/10`, so a
  reading of `0.85` would be *impossible* rather than merely high.

## The scientific payload

`6/7` is not a fact about bits, and it is not a fact about the response either: it is the
value at `q = 2` of the geometric-profile functional `1 − (q−1)²/(q²+q+1)`.  The
`3` in the numerator `3q` is the same `3` that appears in the asymptotic window inequality
`3c² + 3c + 1 > 7` of `Pythagorean.ZeroFitDialSparseWindow60`: both come from the identity
`(1+c)³ − c³ = 3c² + 3c + 1` for the cube sum of a geometric profile.
-/

open Catalog.Novelty.ZeroFitDialU64

namespace Catalog.Pythagorean.ZeroFitDialRadixCeiling60

/-! ## 1. The `q`-adic tie profile -/

/-- The trailing-zero tie profile of uniform draws of length `b` over an alphabet with
`q = p + 2` letters: `(q−1)q^{b-1-k}` words have exactly `k` trailing zeros, and the
all-zero word is alone in its block.  The parametrisation `q = p + 2` keeps everything in
`ℕ` without truncated subtraction. -/
def radixBlocks (p : ℕ) : ℕ → List ℕ
  | 0 => [1]
  | b + 1 => (p + 1) * (p + 2) ^ b :: radixBlocks p b

/-- The profile accounts for all `q^b` words. -/
lemma radixBlocks_sum (p b : ℕ) : (radixBlocks p b).sum = (p + 2) ^ b := by
  induction b with
  | zero => simp [radixBlocks]
  | succ b ih =>
      rw [radixBlocks, List.sum_cons, ih, pow_succ]
      ring

/-- At `q = 2` the profile is the catalog's dyadic profile: this file generalises
`Catalog.Novelty.ZeroFitDialU64.dyadicBlocks` rather than duplicating it. -/
lemma radixBlocks_eq_dyadic (b : ℕ) : radixBlocks 0 b = dyadicBlocks b := by
  induction b with
  | zero => rfl
  | succ b ih => rw [radixBlocks, dyadicBlocks, ih]; norm_num

/-! ## 2. The closed form of the tie correction -/

/-- Closed form of the Kendall tie correction of the `q`-adic profile:
`12·tieCorr = (q−1)²(q^{3b} − 1)/(q²+q+1) − (q^b − 1)`. -/
lemma tieCorr_radix (p b : ℕ) :
    12 * tieCorr (radixBlocks p b)
      = (((p : ℚ) + 1) ^ 2 * (((p : ℚ) + 2) ^ (3 * b) - 1))
          / (((p : ℚ) + 2) ^ 2 + ((p : ℚ) + 2) + 1)
        - (((p : ℚ) + 2) ^ b - 1) := by
  have hQ : (0 : ℚ) < ((p : ℚ) + 2) ^ 2 + ((p : ℚ) + 2) + 1 := by positivity
  induction b with
  | zero => norm_num [radixBlocks, tieCorr]
  | succ b ih =>
      rw [radixBlocks, tieCorr_cons, mul_add, ih]
      have hcast : ((((p + 1) * (p + 2) ^ b : ℕ)) : ℚ) = ((p : ℚ) + 1) * ((p : ℚ) + 2) ^ b := by
        push_cast
        ring
      rw [hcast]
      have h3 : (3 : ℕ) * (b + 1) = 3 * b + 3 := by ring
      rw [h3, pow_add, pow_succ]
      field_simp
      ring

/-! ## 3. The exact radix ceiling -/

/-- **The radix-`q` tie ceiling.**  For uniform draws of length `b ≥ 1` over an alphabet of
`q = p+2` letters, the largest Spearman coefficient attainable against any response
refining the trailing-zero blocks satisfies

`ρ² = (3q/(q²+q+1)) · (1 + 1/(q^b(q^b+1)))`.

At `p = 0` this is the catalog's `(6/7)(1 + 1/(2^b(2^b+1)))`. -/
theorem radix_spearmanSq (p b : ℕ) (hb : 1 ≤ b) :
    spearmanSq (radixBlocks p b)
      = (3 * ((p : ℚ) + 2) / (((p : ℚ) + 2) ^ 2 + ((p : ℚ) + 2) + 1))
        * (1 + 1 / (((p : ℚ) + 2) ^ b * (((p : ℚ) + 2) ^ b + 1))) := by
  have hQ2 : (2 : ℚ) ≤ (p : ℚ) + 2 := by
    have : (0 : ℚ) ≤ (p : ℚ) := Nat.cast_nonneg p
    linarith
  have hn : (2 : ℚ) ≤ ((p : ℚ) + 2) ^ b := by
    have h1 : ((p : ℚ) + 2) ^ 1 ≤ ((p : ℚ) + 2) ^ b :=
      pow_le_pow_right₀ (by linarith) hb
    rw [pow_one] at h1
    linarith
  have hsum : (radixBlocks p b).sum = (p + 2) ^ b := radixBlocks_sum p b
  have hsum2 : 2 ≤ (radixBlocks p b).sum := by
    have hnat : 2 ^ 1 ≤ (p + 2) ^ b := by
      calc 2 ^ 1 ≤ (p + 2) ^ 1 := Nat.pow_le_pow_left (by omega) 1
        _ ≤ (p + 2) ^ b := Nat.pow_le_pow_right (by omega) hb
    omega
  have hcast : (((radixBlocks p b).sum : ℕ) : ℚ) = ((p : ℚ) + 2) ^ b := by
    rw [hsum]; push_cast; ring
  rw [spearmanSq_eq _ hsum2, hcast, tieCorr_radix p b]
  have hcube : ((p : ℚ) + 2) ^ (3 * b) = (((p : ℚ) + 2) ^ b) ^ 3 := by
    rw [← pow_mul, mul_comm]
  rw [hcube]
  set N : ℚ := ((p : ℚ) + 2) ^ b with hN
  set Q : ℚ := (p : ℚ) + 2 with hQ
  have hp1 : (p : ℚ) + 1 = Q - 1 := by rw [hQ]; ring
  have hQ0 : (0 : ℚ) < Q ^ 2 + Q + 1 := by positivity
  have hN0 : (0 : ℚ) < N := by linarith
  have hfac : N ^ 3 - N = N * (N - 1) * (N + 1) := by ring
  have hN1 : N - 1 ≠ 0 := by
    intro h
    rw [sub_eq_zero] at h
    rw [h] at hn
    linarith
  have hNp : N + 1 ≠ 0 := by intro h; linarith
  rw [hp1, hfac]
  field_simp
  ring

/-! ## 4. Consequences -/

/-- The finite-length ceiling is strictly above the universal radix constant. -/
theorem radix_ceiling_gt (p b : ℕ) (hb : 1 ≤ b) :
    3 * ((p : ℚ) + 2) / (((p : ℚ) + 2) ^ 2 + ((p : ℚ) + 2) + 1) < spearmanSq (radixBlocks p b) := by
  rw [radix_spearmanSq p b hb]
  have hQ0 : (0 : ℚ) < 3 * ((p : ℚ) + 2) / (((p : ℚ) + 2) ^ 2 + ((p : ℚ) + 2) + 1) := by
    have hnum : (0 : ℚ) < 3 * ((p : ℚ) + 2) := by positivity
    have hden : (0 : ℚ) < ((p : ℚ) + 2) ^ 2 + ((p : ℚ) + 2) + 1 := by positivity
    exact div_pos hnum hden
  have hsmall : (0 : ℚ) < 1 / (((p : ℚ) + 2) ^ b * (((p : ℚ) + 2) ^ b + 1)) := by
    have hp : (0 : ℚ) < ((p : ℚ) + 2) ^ b := by positivity
    have : (0 : ℚ) < ((p : ℚ) + 2) ^ b * (((p : ℚ) + 2) ^ b + 1) := by nlinarith
    exact div_pos one_pos this
  nlinarith [hQ0, hsmall]

/-- The excess over the constant is `O(q^{-2b})`: an explicit envelope for the convergence
`ρ²(q, b) → 3q/(q²+q+1)`. -/
theorem radix_ceiling_tendsto_const (p b : ℕ) (hb : 1 ≤ b) :
    spearmanSq (radixBlocks p b)
        - 3 * ((p : ℚ) + 2) / (((p : ℚ) + 2) ^ 2 + ((p : ℚ) + 2) + 1)
      ≤ 1 / (((p : ℚ) + 2) ^ b) ^ 2 := by
  rw [radix_spearmanSq p b hb]
  set N : ℚ := ((p : ℚ) + 2) ^ b with hN
  set Q : ℚ := (p : ℚ) + 2 with hQ
  have hQ2 : (2 : ℚ) ≤ Q := by
    have : (0 : ℚ) ≤ (p : ℚ) := Nat.cast_nonneg p
    rw [hQ]; linarith
  have hN2 : (2 : ℚ) ≤ N := by
    rw [hN]
    have h1 : Q ^ 1 ≤ Q ^ b := pow_le_pow_right₀ (by linarith [hQ2]) hb
    rw [pow_one] at h1
    linarith [hQ2]
  have hQ0 : (0 : ℚ) < Q ^ 2 + Q + 1 := by positivity
  have hN0 : (0 : ℚ) < N := by linarith
  have hfrac : 3 * Q / (Q ^ 2 + Q + 1) ≤ 1 := by
    rw [div_le_one hQ0]
    nlinarith [sq_nonneg (Q - 1)]
  have hexp : (3 * Q / (Q ^ 2 + Q + 1)) * (1 + 1 / (N * (N + 1)))
      - 3 * Q / (Q ^ 2 + Q + 1) = (3 * Q / (Q ^ 2 + Q + 1)) * (1 / (N * (N + 1))) := by
    ring
  rw [hexp]
  have hpos : (0 : ℚ) < N * (N + 1) := by nlinarith
  have h1 : (3 * Q / (Q ^ 2 + Q + 1)) * (1 / (N * (N + 1))) ≤ 1 / (N * (N + 1)) := by
    have hinv : (0 : ℚ) < 1 / (N * (N + 1)) := div_pos one_pos hpos
    nlinarith [hfrac, hinv]
  have h2 : 1 / (N * (N + 1)) ≤ 1 / N ^ 2 := by
    apply div_le_div_of_nonneg_left one_pos.le (by positivity)
    nlinarith
  linarith

/-- **The constant is strictly decreasing in the alphabet size.**  A richer alphabet
produces fewer ties, hence a *lower* attainable Spearman ceiling. -/
theorem radix_constant_strict_anti (p p' : ℕ) (h : p < p') :
    3 * ((p' : ℚ) + 2) / (((p' : ℚ) + 2) ^ 2 + ((p' : ℚ) + 2) + 1)
      < 3 * ((p : ℚ) + 2) / (((p : ℚ) + 2) ^ 2 + ((p : ℚ) + 2) + 1) := by
  have hlt : ((p : ℚ) + 2) < ((p' : ℚ) + 2) := by
    have : (p : ℚ) < (p' : ℚ) := by exact_mod_cast h
    linarith
  have hp2 : (2 : ℚ) ≤ (p : ℚ) + 2 := by
    have : (0 : ℚ) ≤ (p : ℚ) := Nat.cast_nonneg p
    linarith
  set Q : ℚ := (p : ℚ) + 2 with hQ
  set Q' : ℚ := (p' : ℚ) + 2 with hQ'
  have hd : (0 : ℚ) < Q ^ 2 + Q + 1 := by positivity
  have hd' : (0 : ℚ) < Q' ^ 2 + Q' + 1 := by positivity
  rw [div_lt_div_iff₀ hd' hd]
  have hQQ : (1 : ℚ) < Q * Q' := by nlinarith [hlt, hp2]
  nlinarith [mul_pos (sub_pos.2 hlt) (sub_pos.2 hQQ)]

/-- **The validation band is binary-specific.**  Over any alphabet with at least three
letters and any length `b ≥ 2`, the trailing-zero ceiling is at most `7/10`, strictly below
`0.85² = 0.7225`.  So the band `[0.55, 0.85]` recorded at bitlen 60 is admissible *because*
the draws are binary: transplanting the dial to a larger alphabet requires re-deriving the
band, since its top end would be unattainable. -/
theorem band_is_binary_specific (p b : ℕ) (hp : 1 ≤ p) (hb : 2 ≤ b) :
    spearmanSq (radixBlocks p b) ≤ 7 / 10
      ∧ spearmanSq (radixBlocks p b) < (85 / 100 : ℚ) ^ 2 := by
  have hQ3 : (3 : ℚ) ≤ (p : ℚ) + 2 := by
    have : (1 : ℚ) ≤ (p : ℚ) := by exact_mod_cast hp
    linarith
  have hkey : spearmanSq (radixBlocks p b) ≤ 7 / 10 := by
    rw [radix_spearmanSq p b (by omega)]
    set Q : ℚ := (p : ℚ) + 2 with hQ
    set N : ℚ := Q ^ b with hN
    have hd : (0 : ℚ) < Q ^ 2 + Q + 1 := by positivity
    -- the constant is at most `9/13`
    have hconst : 3 * Q / (Q ^ 2 + Q + 1) ≤ 9 / 13 := by
      rw [div_le_div_iff₀ hd (by norm_num)]
      nlinarith [hQ3]
    have hconst0 : (0 : ℚ) < 3 * Q / (Q ^ 2 + Q + 1) := by
      apply div_pos (by linarith) hd
    -- the finite-length correction is at most `1 + 1/90`
    have hN9 : (9 : ℚ) ≤ N := by
      rw [hN]
      calc (9 : ℚ) = 3 ^ 2 := by norm_num
        _ ≤ Q ^ 2 := by nlinarith [hQ3]
        _ ≤ Q ^ b := pow_le_pow_right₀ (by linarith [hQ3]) hb
    have hpos : (0 : ℚ) < N * (N + 1) := by nlinarith
    have hcorr : 1 + 1 / (N * (N + 1)) ≤ 1 + 1 / 90 := by
      have : 1 / (N * (N + 1)) ≤ 1 / 90 := by
        apply div_le_div_of_nonneg_left one_pos.le (by norm_num)
        nlinarith
      linarith
    have hcorr0 : (0 : ℚ) < 1 + 1 / (N * (N + 1)) := by
      have : (0 : ℚ) < 1 / (N * (N + 1)) := div_pos one_pos hpos
      linarith
    calc (3 * Q / (Q ^ 2 + Q + 1)) * (1 + 1 / (N * (N + 1)))
        ≤ (9 / 13) * (1 + 1 / 90) := by
          apply mul_le_mul hconst hcorr (le_of_lt hcorr0) (by norm_num)
      _ = 7 / 10 := by norm_num
  exact ⟨hkey, by nlinarith [hkey]⟩

/-- Consistency with the catalog: the general formula reproduces the binary ceiling
`(6/7)(1 + 1/(2^b(2^b+1)))` of `dyadic_spearmanSq`. -/
theorem radix_spearmanSq_binary (b : ℕ) (hb : 1 ≤ b) :
    spearmanSq (dyadicBlocks b) = (6 / 7) * (1 + 1 / ((2 : ℚ) ^ b * (2 ^ b + 1))) := by
  rw [← radixBlocks_eq_dyadic b, radix_spearmanSq 0 b hb]
  norm_num

/-!
## Lab Notes (cycle 8)

Exact rational ceilings `ρ²(q, b)` of the `q`-adic trailing-zero profile, and the universal
constant `3q/(q²+q+1)` they converge to:

| `q` | `3q/(q²+q+1)` | `b = 1` | `b = 2` | `b = 4` | `b = 8` |
|-----|----------------|---------|---------|---------|---------|
| 2 | 6/7 = 0.857143 | 1.000000 | 0.900000 | 0.860294 | 0.857156 |
| 3 | 9/13 = 0.692308 | 0.750000 | 0.700000 | 0.692412 | 0.692308 |
| 4 | 12/21 = 0.571429 | 0.600000 | 0.573529 | 0.571437 | 0.571429 |
| 10 | 30/111 = 0.270270 | 0.272727 | 0.270297 | 0.270270 | 0.270270 |

The `b = 1` column is `3q/(q²+q+1) · (1 + 1/(q(q+1)))`, which simplifies to `3/(q+1)` — at
`q = 2` it is `1`, correctly reporting that two-letter words of length one have no ties; the
convergence is `O(q^{-2b})`, formalised as `radix_ceiling_tendsto_const`.

Two sanity checks against the rest of the thread:

* at `q = 2, b = 60` the formula gives `(6/7)(1 + 1/(2⁶⁰(2⁶⁰+1)))`, the value used in the
  round-51 envelope statements (`radix_spearmanSq_binary`);
* the band top `0.85² = 0.7225` sits below the ceiling for `q = 2` but *above* it for every
  `q ≥ 3` and `b ≥ 2` (the largest such ceiling being `0.7` at `q = 3, b = 2`), which is
  `band_is_binary_specific`.

Where the constant comes from: for a geometric profile with ratio `1/q` and total `n`, the
cube sum is `n³(q−1)²/(q²+q+1)` up to `O(n)`, and `1 − (q−1)²/(q²+q+1) = 3q/(q²+q+1)`.  The
numerator `3q` is the same `3` as in `(1+c)³ − c³ = 3c² + 3c + 1`, the identity that decides
the half-weight phase boundary in `Pythagorean.ZeroFitDialSparseWindow60`.
-/

end Catalog.Pythagorean.ZeroFitDialRadixCeiling60