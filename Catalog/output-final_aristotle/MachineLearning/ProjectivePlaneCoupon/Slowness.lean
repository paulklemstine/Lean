/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Projective-plane coupon collection is slower than uniform: the structural engine

Fix a prime power `q ≥ 2` and a projective plane of order `q`.  It has
`n = q² + q + 1` points and the same number of lines; every line is a
`(q+1)`-subset of points, every point lies on `q+1` lines, and any two
distinct points lie on a unique common line.

We study two coupon-collection mechanisms on the `n` points:

* **plane mechanism** — each draw is a uniformly random *line* (one of the
  `n` lines), revealing the `q+1` points on it;
* **uniform mechanism** — each draw is a uniformly random `(q+1)`-subset of
  the `n` points.

For a covering process whose single-draw probability of *avoiding* a fixed set
`A` is `p_A`, the expected time to cover everything is the inclusion–exclusion
sum `E = Σ_{∅ ≠ A} (-1)^{|A|+1} / (1 - p_A)`.  The Grünbaum–Yaakobi question
(disproved for `q = 2`, the Fano plane) asks whether the plane mechanism is
*slower*, i.e. has the larger `E`.  The general statement (all prime powers)
is open; this file isolates the structural mechanism that drives it.

## Avoid-probabilities

For a single draw, `p_A = (number of draws avoiding A) / (number of draws)`.

* Uniform: `p_A` depends only on `k = |A|`, namely
  `uAvoid q k = C(n-k, q+1) / C(n, q+1) = ∏_{i<k}(q² - i) / ∏_{i<k}(n - i)`
  (the falling-factorial form, with `n - (q+1) = q²`).
* Plane: `p_A` depends on the *geometry* of `A`.  A single point is missed by
  `q²` lines (`pPoint`); a pair by `q² - q` (`pPair`); a **collinear** triple by
  `q² - 2q` (`pColl`); a **generic** (non-collinear) triple by `(q-1)²`
  (`pGen`).

## Main results

* `meanMatch` — the **mean-matching identity** (a binomial subset-of-a-subset
  identity): averaged over all `k`-subsets, the plane mechanism avoids a set
  with exactly the uniform probability.  This is why low orders agree.
* `match1`, `match2` — at orders `1` and `2` *every* subset is geometrically
  equivalent, so the plane and uniform avoid-probabilities coincide *exactly*;
  hence the `E`-contributions of orders `1` and `2` are identical.
* `jensen2` — strict two-point Jensen inequality for `x ↦ 1/(1-x)`.
* `slowness3` — at order `3` the plane mechanism splits a single uniform value
  into two distinct ones (`pColl ≠ pGen`) **with the same mean**, so by strict
  convexity its order-`3` contribution to `E` is strictly larger.  This is the
  first order at which the two mechanisms diverge, and it diverges in the
  "slower" direction.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The plane mechanism is slower for *every* prime
  power `q`.  Bolder: the divergence is forced entirely by collinearity — the
  two mechanisms agree to all orders "on average", and disagree pointwise for
  the first time at triples, where convexity of `1/(1-p)` makes the spread-out
  plane values cost strictly more.
Experiment (Experimenter): (1) Proved the binomial identity
  `C(n,k)·C(n-k,q+1) = C(n,q+1)·C(n-(q+1),k)` from factorials — this is exactly
  "mean of plane avoid-prob over k-sets = uniform avoid-prob". (2) Proved the
  exact pointwise equalities at orders 1,2 (`match1`,`match2`). (3) Proved the
  order-3 weighted-mean identity `match3` and combined it with a freshly proved
  strict Jensen lemma `jensen2` to get `slowness3`.  Computationally verified
  the *full* `E`-inequality for `q = 2,3` (see `FanoEvidence.lean` and
  `ComputationalEvidence.md`).
Analysis (Analyst): The number of collinear triples is `n·C(q+1,3)`; the rest
  are generic.  Their avoid-counts differ by exactly one line
  (`(q-1)² - (q²-2q) = 1`), so `pColl ≠ pGen` always.  The clean factorization
  `#generic·6 = n·q³(q+1)` (used in `slowness3`) shows generic triples dominate,
  so the plane really does carry two genuinely different values at order 3.
  "True but hard": the full all-orders statement needs control of the
  alternating tail (orders `≥ 4`), which is why only `q = 2,3,4,5` are known.
Critique (Critic): `slowness3` is a genuine strict inequality (uses `jensen2`,
  itself proved by `nlinarith` on `(x-y)² > 0`), not `decide`/`native_decide`.
  The geometric avoid-counts are taken as definitions; their correctness is
  cross-checked against the explicit Fano plane in `FanoEvidence.lean`.
Synthesis (PI): Orders 1–2 contribute equally; order 3 strictly favours the
  plane (slower).  The open problem is exactly the sign-controlled tail.
-/
import Mathlib

open Nat Finset

namespace ProjectivePlaneCoupon

/-- Number of points (= number of lines) of a projective plane of order `q`. -/
def Npt (q : ℕ) : ℕ := q ^ 2 + q + 1

/-- Line size of a projective plane of order `q`. -/
def lineSz (q : ℕ) : ℕ := q + 1

theorem Npt_cast (q : ℕ) : (Npt q : ℚ) = (q : ℚ) ^ 2 + (q : ℚ) + 1 := by
  push_cast [Npt]; ring

/-- `n - (q+1) = q²`: removing one line's worth of points from the plane. -/
theorem Npt_sub_lineSz (q : ℕ) : Npt q - lineSz q = q ^ 2 := by
  simp only [Npt, lineSz]; omega

/-! ### The binomial subset-of-a-subset identity (mean-matching) -/

/-- **Subset-of-a-subset identity.** Choosing a `k`-block then a `j`-block from
the remainder is symmetric in `k` and `j`; both count `n! / (k! j! (n-k-j)!)`. -/
theorem choose_choose_comm (n k j : ℕ) (h : k + j ≤ n) :
    n.choose k * (n - k).choose j = n.choose j * (n - j).choose k := by
  have hk : k ≤ n := le_trans (Nat.le_add_right k j) h
  have hj : j ≤ n := le_trans (Nat.le_add_left j k) h
  have hjk : j ≤ n - k := by omega
  have hkj : k ≤ n - j := by omega
  have W : 0 < k ! * j ! * (n - k - j)! := by positivity
  apply Nat.eq_of_mul_eq_mul_right W
  have a1 := Nat.choose_mul_factorial_mul_factorial hk
  have a1' := Nat.choose_mul_factorial_mul_factorial hj
  have a2 : (n - k).choose j * j ! * ((n - k) - j)! = (n - k)! :=
    Nat.choose_mul_factorial_mul_factorial hjk
  have a3 : (n - j).choose k * k ! * ((n - j) - k)! = (n - j)! :=
    Nat.choose_mul_factorial_mul_factorial hkj
  have enj : (n - k) - j = n - k - j := by omega
  have enk : (n - j) - k = n - k - j := by omega
  rw [enj] at a2; rw [enk] at a3
  have lhs : n.choose k * (n - k).choose j * (k ! * j ! * (n - k - j)!) = n ! := by
    have e : n.choose k * (n - k).choose j * (k ! * j ! * (n - k - j)!)
        = (n.choose k * k !) * ((n - k).choose j * j ! * (n - k - j)!) := by ring
    rw [e, a2]; exact a1
  have rhs : n.choose j * (n - j).choose k * (k ! * j ! * (n - k - j)!) = n ! := by
    have e : n.choose j * (n - j).choose k * (k ! * j ! * (n - k - j)!)
        = (n.choose j * j !) * ((n - j).choose k * k ! * (n - k - j)!) := by ring
    rw [e, a3]; exact a1'
  rw [lhs, rhs]

/-- **Mean-matching identity.** Cross-multiplied form of
`C(n-k, q+1)/C(n, q+1) = C(n-(q+1), k)/C(n, k)`: the uniform `(q+1)`-subset
avoid-probability of any `k`-set equals the plane line-avoid-probability
averaged over all `k`-sets.  (Here `n - (q+1) = q²` by `Npt_sub_lineSz`.) -/
theorem meanMatch (q k : ℕ) (hk : k + lineSz q ≤ Npt q) :
    (Npt q).choose k * (Npt q - k).choose (lineSz q)
      = (Npt q).choose (lineSz q) * (Npt q - lineSz q).choose k :=
  choose_choose_comm (Npt q) k (lineSz q) hk

/-! ### Avoid-probabilities -/

/-- Uniform `(q+1)`-subset avoid-probability of a `k`-set, in falling-factorial
form `∏_{i<k}(q² - i) / ∏_{i<k}(n - i) = C(n-k, q+1)/C(n, q+1)`. -/
noncomputable def uAvoid (q k : ℕ) : ℚ :=
  (∏ i ∈ range k, ((q : ℚ) ^ 2 - i)) / (∏ i ∈ range k, ((Npt q : ℚ) - i))

/-- Plane avoid-probability of a single point: `q²` of the `n` lines miss it. -/
def pPoint (q : ℕ) : ℚ := (q : ℚ) ^ 2 / (Npt q)

/-- Plane avoid-probability of a pair: `q² - q` lines miss both. -/
def pPair (q : ℕ) : ℚ := ((q : ℚ) ^ 2 - q) / (Npt q)

/-- Plane avoid-probability of a **collinear** triple: `q² - 2q` lines miss all. -/
def pColl (q : ℕ) : ℚ := ((q : ℚ) ^ 2 - 2 * q) / (Npt q)

/-- Plane avoid-probability of a **generic** (non-collinear) triple:
`(q-1)²` lines miss all. -/
def pGen (q : ℕ) : ℚ := ((q : ℚ) - 1) ^ 2 / (Npt q)

noncomputable def NN (q : ℕ) : ℚ := (Npt q : ℚ)

/-- Total number of triples `C(n,3)`. -/
noncomputable def T3 (q : ℕ) : ℚ := NN q * (NN q - 1) * (NN q - 2) / 6

/-- Number of collinear triples `n · C(q+1,3)`. -/
noncomputable def cColl (q : ℕ) : ℚ := NN q * ((q : ℚ) + 1) * (q : ℚ) * ((q : ℚ) - 1) / 6

/-- Number of generic (non-collinear) triples `C(n,3) - n·C(q+1,3)`. -/
noncomputable def cGen (q : ℕ) : ℚ := T3 q - cColl q

/-! ### Orders 1 and 2: the mechanisms agree exactly -/

/-- At order `1` the plane and uniform avoid-probabilities coincide. -/
theorem match1 (q : ℕ) : pPoint q = uAvoid q 1 := by
  simp [uAvoid, pPoint]

/-- At order `2` the plane and uniform avoid-probabilities coincide exactly
(every pair lies on a unique line, so all pairs are equivalent). -/
theorem match2 (q : ℕ) (hq : 2 ≤ q) : pPair q = uAvoid q 2 := by
  have hN : (Npt q : ℚ) = (q : ℚ) ^ 2 + q + 1 := Npt_cast q
  have hq2 : (2 : ℚ) ≤ q := by exact_mod_cast hq
  simp only [uAvoid, pPair, Finset.prod_range_succ, Finset.prod_range_zero, one_mul,
    Nat.cast_zero, Nat.cast_one, sub_zero]
  rw [hN, div_eq_div_iff]
  · ring
  · positivity
  · nlinarith

/-! ### Order 3: the weighted-mean identity and the strict divergence -/

/-- **Order-3 mean matching.** The (count-weighted) total plane avoid-mass over
all triples equals `C(n,3)` times the uniform value: the collinear and generic
plane probabilities `pColl`, `pGen` average to the uniform `uAvoid q 3`. -/
theorem match3 (q : ℕ) (hq : 2 ≤ q) :
    cColl q * pColl q + cGen q * pGen q = T3 q * uAvoid q 3 := by
  have hq2 : (2 : ℚ) ≤ q := by exact_mod_cast hq
  set m : ℚ := (Npt q : ℚ) with hm
  have hN : m = (q : ℚ) ^ 2 + q + 1 := Npt_cast q
  have hmpos : (7 : ℚ) ≤ m := by rw [hN]; nlinarith
  simp only [cGen, T3, cColl, pColl, pGen, NN, uAvoid, Finset.prod_range_succ,
    Finset.prod_range_zero, one_mul, Nat.cast_zero, Nat.cast_one, Nat.cast_ofNat, sub_zero, ← hm]
  have hd : m ≠ 0 := by linarith
  have hd1 : m - 1 ≠ 0 := by linarith
  have hd2 : m - 2 ≠ 0 := by linarith
  field_simp
  rw [hN]; ring

/-- **Strict two-point Jensen inequality** for the convex function `x ↦ 1/(1-x)`
on `x < 1`: the weighted average of the function values at two *distinct* points
strictly exceeds the function at the weighted mean.  (Stated multiplied through
by the total weight `wA + wB`.) -/
theorem jensen2 {a b wA wB : ℚ} (ha : a < 1) (hb : b < 1)
    (hA : 0 < wA) (hB : 0 < wB) (hab : a ≠ b) :
    (wA + wB) / (1 - (wA * a + wB * b) / (wA + wB)) < wA / (1 - a) + wB / (1 - b) := by
  have hxa : 0 < 1 - a := by linarith
  have hxb : 0 < 1 - b := by linarith
  have hw : 0 < wA + wB := by linarith
  have hmean : 1 - (wA * a + wB * b) / (wA + wB)
      = (wA * (1 - a) + wB * (1 - b)) / (wA + wB) := by
    field_simp; ring
  rw [hmean, div_div_eq_mul_div, div_add_div _ _ (ne_of_gt hxa) (ne_of_gt hxb),
    div_lt_div_iff₀ (by positivity) (by positivity)]
  have hsq : 0 < ((1 - a) - (1 - b)) ^ 2 := by
    have : (1 - a) - (1 - b) ≠ 0 := by intro h; apply hab; linarith
    positivity
  nlinarith [mul_pos hA hB, mul_pos hxa hxb, mul_pos (mul_pos hA hB) hsq]

/-- **Order-3 slowness.** For every `q ≥ 2`, the plane mechanism's contribution
to the expected cover time at order `3`,
`Σ_{|A|=3} 1/(1 - p_A^plane)`, strictly exceeds the uniform contribution
`C(n,3)/(1 - uAvoid q 3)`.  This is the first order at which the two mechanisms
differ, and it differs in the direction making the plane slower.  The proof
combines the mean-matching identity `match3` with strict convexity `jensen2`,
using that collinear and generic triples carry distinct probabilities. -/
theorem slowness3 (q : ℕ) (hq : 2 ≤ q) :
    T3 q / (1 - uAvoid q 3) < cColl q / (1 - pColl q) + cGen q / (1 - pGen q) := by
  have hq2 : (2 : ℚ) ≤ q := by exact_mod_cast hq
  have hN : (Npt q : ℚ) = (q : ℚ) ^ 2 + q + 1 := Npt_cast q
  have hNpos : (0 : ℚ) < (Npt q : ℚ) := by rw [hN]; positivity
  have hpColl : pColl q < 1 := by rw [pColl, div_lt_one hNpos, hN]; nlinarith
  have hpGen : pGen q < 1 := by rw [pGen, div_lt_one hNpos, hN]; nlinarith
  have a1 : 0 < (q : ℚ) ^ 2 + q + 1 := by positivity
  have a2 : 0 < (q : ℚ) + 1 := by positivity
  have a3 : 0 < (q : ℚ) := by linarith
  have a4 : 0 < (q : ℚ) - 1 := by linarith
  have hcColl : 0 < cColl q := by
    rw [cColl, NN, hN]
    exact div_pos (mul_pos (mul_pos (mul_pos a1 a2) a3) a4) (by norm_num)
  have hcGen : 0 < cGen q := by
    have e : cGen q = ((q : ℚ) ^ 2 + q + 1) * (q : ℚ) ^ 3 * ((q : ℚ) + 1) / 6 := by
      rw [cGen, T3, cColl, NN, hN]; ring
    rw [e]; positivity
  have hsum : cColl q + cGen q = T3 q := by rw [cGen]; ring
  have hT3 : 0 < T3 q := by rw [← hsum]; linarith
  have hlt : pColl q < pGen q := by
    rw [pColl, pGen, div_lt_div_iff₀ hNpos hNpos, hN]; nlinarith
  have hne : pColl q ≠ pGen q := ne_of_lt hlt
  have key : (cColl q * pColl q + cGen q * pGen q) / (cColl q + cGen q) = uAvoid q 3 := by
    rw [match3 q hq, hsum, mul_comm, mul_div_assoc, div_self (ne_of_gt hT3), mul_one]
  have H := jensen2 hpColl hpGen hcColl hcGen hne
  rw [key, hsum] at H
  exact H

end ProjectivePlaneCoupon