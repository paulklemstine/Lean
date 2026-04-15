/-! # CatalogBuild.FutureResearch.SigmaArithmetic

Auto-generated from theorem catalog database.
Domain: FutureResearch
Declarations: 15
-/

import Mathlib

noncomputable section

/-- [Section: # σ₁ Arithmetic for General Integers (B10b, A6c, NEW)
## Main Results
* `sigma1_gt_self'` — σ₁(n) > n for n > 1
* `sigma1_prime_pow'` — σ₁(p^k) = Σ pⁱ
* `prime_is_deficient'` — All primes are deficient
* `six_perfect'` / `twentyeight_perfect'` — Verified perfect numbers] -/
noncomputable def σ₁'' (n : ℕ) : ℕ := ∑ d ∈ n.divisors, d


theorem sigma1_zero' : σ₁'' 0 = 0 := by simp [σ₁'']

theorem sigma1_one' : σ₁'' 1 = 1 := by simp [σ₁'']


theorem sigma1_prime' (p : ℕ) (hp : Nat.Prime p) : σ₁'' p = p + 1 := by
  simp [σ₁'', hp.sum_divisors, add_comm]


theorem sigma1_ge_self' (n : ℕ) (hn : 0 < n) : n ≤ σ₁'' n := by
  unfold σ₁''
  have hmem : n ∈ n.divisors := Nat.mem_divisors.mpr ⟨dvd_refl n, hn.ne'⟩
  calc n = ∑ d ∈ ({n} : Finset ℕ), d := by simp
    _ ≤ ∑ d ∈ n.divisors, d := Finset.sum_le_sum_of_subset (Finset.singleton_subset_iff.mpr hmem)


theorem sigma1_gt_self' (n : ℕ) (hn : 1 < n) : n < σ₁'' n := by
  unfold σ₁'';
  rw [ Nat.sum_divisors_eq_sum_properDivisors_add_self ] ; linarith [ Finset.sum_pos ( fun x hx => Nat.pos_of_mem_properDivisors hx ) ⟨ 1, Nat.mem_properDivisors.2 ⟨ by norm_num, hn ⟩ ⟩ ]


/-- [Section: ### Prime Power] -/
theorem sigma1_prime_pow' (p k : ℕ) (hp : Nat.Prime p) :
    σ₁'' (p ^ k) = ∑ i ∈ Finset.range (k + 1), p ^ i := by
  unfold σ₁''; rw [Nat.divisors_prime_pow hp]; simp


/-- [Section: ### Abundancy] -/
def IsAbundant' (n : ℕ) : Prop := 2 * n < σ₁'' n

def IsDeficient' (n : ℕ) : Prop := σ₁'' n < 2 * n

def IsPerfect' (n : ℕ) : Prop := σ₁'' n = 2 * n


theorem prime_is_deficient' (p : ℕ) (hp : Nat.Prime p) : IsDeficient' p := by
  unfold IsDeficient'
  rw [sigma1_prime' p hp]
  have := hp.two_le
  omega


theorem twelve_abundant' : IsAbundant' 12 := by
  unfold IsAbundant' σ₁''; native_decide


theorem six_perfect' : IsPerfect' 6 := by
  unfold IsPerfect' σ₁''; native_decide


theorem twentyeight_perfect' : IsPerfect' 28 := by
  unfold IsPerfect' σ₁''; native_decide


theorem abundancy_trichotomy (n : ℕ) :
    IsAbundant' n ∨ IsDeficient' n ∨ IsPerfect' n := by
  unfold IsAbundant' IsDeficient' IsPerfect'; omega

end
