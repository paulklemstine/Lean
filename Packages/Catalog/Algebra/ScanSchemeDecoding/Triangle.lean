import Mathlib

/-!
# Triangular cost and the exact `ε`-pigeonhole optimum

This file develops the arithmetic backbone of the *scan-scheme* cost model.

A scan scheme distributes `N` keys into `m` buckets; decoding a key costs its
`1`-based position inside its bucket, so a bucket holding `k` keys contributes
`1 + 2 + ⋯ + k = triangle k` to the total decoding cost.  Optimising a scheme is
therefore exactly the discrete problem

  minimise `∑ i, triangle (f i)`  subject to `f : Fin m → ℕ`, `∑ i, f i = N`.

## Main results

* `ScanSchemeDecoding.triangle_tangent` — the *integral tangent-line inequality*
  `triangle q + (q+1) * (k - q) ≤ triangle k`, valid for **all** naturals `k, q`
  (over `ℤ`), the discrete convexity fact driving everything below.
* `ScanSchemeDecoding.sum_triangle_ge` — the exact pigeonhole lower bound
  `r * triangle (q+1) + (m - r) * triangle q ≤ ∑ i, triangle (f i)` where
  `q = N / m`, `r = N % m`.
* `ScanSchemeDecoding.sum_triangle_balanced` — the balanced profile attains it,
  so the bound is the *exact* optimum, not merely a bound.
* `ScanSchemeDecoding.triangleOpt_two_mul_ge` — the averaged ("`ε`") form:
  `N * (N / m + 1) ≤ 2 * optimum`.
-/

namespace ScanSchemeDecoding

open Finset

/-- `triangle k = 1 + 2 + ⋯ + k`, the cost of scanning a bucket of size `k`
when every key of the bucket is decoded once. -/
def triangle (k : ℕ) : ℕ := k * (k + 1) / 2

@[simp] lemma triangle_zero : triangle 0 = 0 := rfl

@[simp] lemma triangle_one : triangle 1 = 1 := rfl

lemma two_mul_triangle (k : ℕ) : 2 * triangle k = k * (k + 1) := by
  have h : 2 ∣ k * (k + 1) := (Nat.even_mul_succ_self k).two_dvd
  rw [triangle, Nat.mul_div_cancel' h]

lemma triangle_succ (k : ℕ) : triangle (k + 1) = triangle k + (k + 1) := by
  have h1 := two_mul_triangle k
  have h2 := two_mul_triangle (k + 1)
  have h3 : (k + 1) * (k + 1 + 1) = k * (k + 1) + 2 * (k + 1) := by ring
  omega

/-- `triangle` as a sum: the cost of decoding every key of a bucket of size `k`. -/
lemma triangle_eq_sum (k : ℕ) : triangle k = ∑ j ∈ range k, (j + 1) := by
  induction k with
  | zero => simp
  | succ n ih => rw [Finset.sum_range_succ, ← ih, triangle_succ]

/-- **Integral tangent-line inequality.**  Discrete convexity of `triangle` at the
point `q`, using the *upper* slope `q + 1`.  The inequality holds for every pair of
naturals because `(k - q) * (k - q - 1) ≥ 0` for every integer `k - q`. -/
lemma triangle_tangent (q k : ℕ) :
    (triangle q : ℤ) + ((q : ℤ) + 1) * ((k : ℤ) - q) ≤ (triangle k : ℤ) := by
  have hd : 0 ≤ ((k : ℤ) - q) * ((k : ℤ) - q - 1) := by
    rcases le_or_gt (k : ℤ) q with h | h
    · have h1 : (k : ℤ) - q ≤ 0 := by linarith
      have h2 : (k : ℤ) - q - 1 ≤ 0 := by linarith
      nlinarith
    · have h1 : (1 : ℤ) ≤ (k : ℤ) - q := by omega
      nlinarith
  have hq : (2 : ℤ) * triangle q = (q : ℤ) * (q + 1) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℤ)) (two_mul_triangle q)
  have hk : (2 : ℤ) * triangle k = (k : ℤ) * (k + 1) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℤ)) (two_mul_triangle k)
  nlinarith

/-- The optimal total scan cost of `N` keys in `m` buckets. -/
def triangleOpt (N m : ℕ) : ℕ :=
  N % m * triangle (N / m + 1) + (m - N % m) * triangle (N / m)

/-- Closed form for the optimum: `m` buckets of size `⌊N/m⌋` plus one extra key in each
of the `N % m` overloaded buckets. -/
lemma triangleOpt_eq {m : ℕ} (hm : 0 < m) (N : ℕ) :
    triangleOpt N m = m * triangle (N / m) + N % m * (N / m + 1) := by
  have hr : N % m ≤ m := (Nat.mod_lt _ hm).le
  obtain ⟨s, hs⟩ : ∃ s, m = s + N % m := ⟨m - N % m, by omega⟩
  have hms : m - N % m = s := by omega
  have key : N % m * (triangle (N / m) + (N / m + 1)) + s * triangle (N / m)
      = (s + N % m) * triangle (N / m) + N % m * (N / m + 1) := by ring
  unfold triangleOpt
  rw [triangle_succ, hms, key, ← hs]

/-- The tangent lower bounds sum **exactly** to the optimum: the tangent line at the
balanced size is tight on average, which is what makes the bound below sharp. -/
lemma sum_tangent_eq {m : ℕ} (hm : 0 < m) (f : Fin m → ℕ) (N : ℕ) (hf : ∑ i, f i = N) :
    ∑ i : Fin m, ((triangle (N / m) : ℤ)
        + (((N / m : ℕ) : ℤ) + 1) * ((f i : ℤ) - ((N / m : ℕ) : ℤ)))
      = (triangleOpt N m : ℤ) := by
  have hN : m * (N / m) + N % m = N := Nat.div_add_mod N m
  have hfz : ∑ i : Fin m, (f i : ℤ) = (N : ℤ) := by rw [← Nat.cast_sum, hf]
  rw [Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_sub_distrib, hfz]
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  have hsub : (N : ℤ) - (m : ℤ) * ((N / m : ℕ) : ℤ) = ((N % m : ℕ) : ℤ) := by
    have hcast : ((m * (N / m) + N % m : ℕ) : ℤ) = (N : ℤ) := by exact_mod_cast hN
    push_cast at hcast ⊢
    linarith
  rw [hsub, triangleOpt_eq hm]
  push_cast
  ring

/-- **Exact pigeonhole lower bound.**  Any distribution of `N` keys into `m` buckets
pays at least `triangleOpt N m` in total scan cost. -/
theorem sum_triangle_ge {m : ℕ} (hm : 0 < m) (f : Fin m → ℕ) (N : ℕ)
    (hf : ∑ i, f i = N) : triangleOpt N m ≤ ∑ i, triangle (f i) := by
  have hsum := Finset.sum_le_sum (fun i (_ : i ∈ (Finset.univ : Finset (Fin m))) =>
    triangle_tangent (N / m) (f i))
  rw [sum_tangent_eq hm f N hf] at hsum
  have hcast : (triangleOpt N m : ℤ) ≤ ((∑ i, triangle (f i) : ℕ) : ℤ) := by
    rw [Nat.cast_sum]; exact hsum
  exact_mod_cast hcast

/-- The balanced profile: `r` buckets of size `q + 1` and `m - r` of size `q`. -/
def balancedProfile (N m : ℕ) (i : Fin m) : ℕ :=
  N / m + (if (i : ℕ) < N % m then 1 else 0)

lemma card_filter_lt (m r : ℕ) (hr : r ≤ m) :
    (Finset.univ.filter (fun i : Fin m => (i : ℕ) < r)).card = r := by
  classical
  have : (Finset.univ.filter (fun i : Fin m => (i : ℕ) < r))
      = (Finset.range r).attachFin (fun j hj => lt_of_lt_of_le (Finset.mem_range.mp hj) hr) := by
    ext i
    simp [Finset.mem_attachFin]
  rw [this]
  simp

lemma sum_ite_lt {M : Type*} [AddCommMonoid M] (m r : ℕ) (hr : r ≤ m) (a b : M) :
    ∑ i : Fin m, (if (i : ℕ) < r then a else b) = r • a + (m - r) • b := by
  classical
  rw [Finset.sum_ite]
  have h1 : (Finset.univ.filter (fun i : Fin m => (i : ℕ) < r)).card = r :=
    card_filter_lt m r hr
  have h2 : (Finset.univ.filter (fun i : Fin m => ¬ (i : ℕ) < r)).card = m - r := by
    have := Finset.card_filter_add_card_filter_not
      (s := (Finset.univ : Finset (Fin m))) (p := fun i : Fin m => (i : ℕ) < r)
    simp only [Finset.card_univ, Fintype.card_fin] at this
    omega
  rw [Finset.sum_const, Finset.sum_const, h1, h2]

lemma sum_balancedProfile {m : ℕ} (hm : 0 < m) (N : ℕ) :
    ∑ i, balancedProfile N m i = N := by
  have hr : N % m < m := Nat.mod_lt _ hm
  unfold balancedProfile
  rw [Finset.sum_add_distrib, sum_ite_lt m (N % m) hr.le 1 0]
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, smul_eq_mul, mul_one,
    mul_zero, add_zero]
  have := Nat.div_add_mod N m
  omega

/-- **The balanced profile attains the bound**, so `triangleOpt` is the exact optimum. -/
theorem sum_triangle_balanced {m : ℕ} (hm : 0 < m) (N : ℕ) :
    ∑ i, triangle (balancedProfile N m i) = triangleOpt N m := by
  have hr : N % m < m := Nat.mod_lt _ hm
  unfold balancedProfile triangleOpt
  have : ∀ i : Fin m, triangle (N / m + (if (i : ℕ) < N % m then 1 else 0))
      = if (i : ℕ) < N % m then triangle (N / m + 1) else triangle (N / m) := by
    intro i; by_cases h : (i : ℕ) < N % m <;> simp [h]
  rw [Finset.sum_congr rfl (fun i _ => this i),
    sum_ite_lt m (N % m) hr.le (triangle (N / m + 1)) (triangle (N / m))]
  simp [smul_eq_mul]

/-- **Averaged (`ε`-)form of the optimum.**  With `m = ⌊εN⌋` buckets the mean decoding
cost is at least `(N / m + 1) / 2`: no bucketing scheme can do better than half the
average bucket size. -/
theorem triangleOpt_two_mul_ge {m : ℕ} (hm : 0 < m) (N : ℕ) :
    N * (N / m + 1) ≤ 2 * triangleOpt N m := by
  set q := N / m with hq
  set r := N % m with hrdef
  have hN : m * q + r = N := Nat.div_add_mod N m
  have hr : r < m := Nat.mod_lt _ hm
  obtain ⟨s, hs⟩ : ∃ s, m = s + r := ⟨m - r, by omega⟩
  have hmr : m - r = s := by omega
  unfold triangleOpt
  rw [triangle_succ, ← hq, ← hrdef, hmr]
  have h1 := two_mul_triangle q
  have hNsub : N = (s + r) * q + r := by rw [← hN, hs]
  calc N * (q + 1) = ((s + r) * q + r) * (q + 1) := by rw [← hNsub]
    _ ≤ (r + s) * (q * (q + 1)) + 2 * r * (q + 1) := by nlinarith [Nat.zero_le (r * (q+1))]
    _ = 2 * (r * (triangle q + (q + 1)) + s * triangle q) := by rw [← h1]; ring

end ScanSchemeDecoding