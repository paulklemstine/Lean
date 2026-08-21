import Novelty.BerggrenTreeZetaCore

/-!
# The silver growth dichotomy of the Berggren tree

The Berggren generators have spectral data governed by the units `3 ± 2√2 = (1 ± √2)²` of
`ℤ[√2]`.  This file makes the corresponding growth statements exact for the hypotenuse
`c(w) = m² + n²` of a node:

* `hyp_step_le_silver` — one Berggren move multiplies the hypotenuse by at most
  `3 + 2√2 = (1+√2)²`, the square of the silver ratio, for **all three** moves;
* `hyp_le_silver_pow` — hence `c(w) ≤ 5 · (3+2√2)^{|w|}`: the silver speed limit;
* `Mspine_hyp_lower`, `Mspine_silver_growth` — along the middle (Pell) spine the bound is
  attained up to a constant: `4 (3+2√2)^k ≤ c ≤ 5 (3+2√2)^k`;
* `Lspine_hyp`, `Rspine_hyp` — but along the two outer spines the hypotenuse grows only
  **quadratically**: `2k² + 6k + 5` and `4k² + 8k + 5`.

This dichotomy — exponential extremal branch, polynomial outer branches, `3^k` nodes at
depth `k` — is exactly what makes the abscissa of convergence of the tree zeta function
equal to `1` rather than the "silver" value `log 3 / (2 log(1+√2))` predicted by a purely
exponential branching model (see `Novelty.BerggrenTreeZetaAbscissa`).  The final result
`depth_slice_lower` quantifies the silver side: the depth-`k` slice of the tree zeta series
dominates the term `3^k (5 (3+2√2)^k)^{-s}` of the silver Ihara-type zeta of
`Novelty.BerggrenTreeCriticalLine`.
-/

namespace BerggrenZeta

open Real

/-! ## Part A. The silver speed limit -/

theorem sqrt_two_sq : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)

theorem one_le_sqrt_two : (1 : ℝ) ≤ Real.sqrt 2 := by
  have h : Real.sqrt 1 ≤ Real.sqrt 2 := Real.sqrt_le_sqrt (by norm_num)
  simp only [Real.sqrt_one] at h
  exact h

/-- The quadratic form inequality behind the silver bound for the middle move. -/
theorem silver_quad_M (m n : ℝ) :
    5 * m ^ 2 + 4 * m * n + n ^ 2 ≤ (3 + 2 * Real.sqrt 2) * (m ^ 2 + n ^ 2) := by
  have hs := sqrt_two_sq
  have hgt : (1 : ℝ) < Real.sqrt 2 := by nlinarith [Real.sqrt_nonneg 2]
  have key : (2 * Real.sqrt 2 - 2) *
      ((3 + 2 * Real.sqrt 2) * (m ^ 2 + n ^ 2) - (5 * m ^ 2 + 4 * m * n + n ^ 2))
      = ((2 * Real.sqrt 2 - 2) * m - 2 * n) ^ 2 := by
    linear_combination (4 * n ^ 2) * hs
  have hnn : 0 ≤ (2 * Real.sqrt 2 - 2) *
      ((3 + 2 * Real.sqrt 2) * (m ^ 2 + n ^ 2) - (5 * m ^ 2 + 4 * m * n + n ^ 2)) := by
    rw [key]; positivity
  nlinarith [hnn, hgt]

/-- The quadratic form inequality behind the silver bound for the right move. -/
theorem silver_quad_R (m n : ℝ) :
    m ^ 2 + 4 * m * n + 5 * n ^ 2 ≤ (3 + 2 * Real.sqrt 2) * (m ^ 2 + n ^ 2) := by
  have hs := sqrt_two_sq
  have hgt : (1 : ℝ) < Real.sqrt 2 := by nlinarith [Real.sqrt_nonneg 2]
  have key : (2 * Real.sqrt 2 - 2) *
      ((3 + 2 * Real.sqrt 2) * (m ^ 2 + n ^ 2) - (m ^ 2 + 4 * m * n + 5 * n ^ 2))
      = (2 * m - (2 * Real.sqrt 2 - 2) * n) ^ 2 := by
    linear_combination (4 * m ^ 2) * hs
  have hnn : 0 ≤ (2 * Real.sqrt 2 - 2) *
      ((3 + 2 * Real.sqrt 2) * (m ^ 2 + n ^ 2) - (m ^ 2 + 4 * m * n + 5 * n ^ 2)) := by
    rw [key]; positivity
  nlinarith [hnn, hgt]

/-- **The silver speed limit, one step.**  Every Berggren move multiplies the hypotenuse by
at most `3 + 2√2 = (1+√2)²`, the square of the silver ratio (the fundamental unit of
`ℤ[√2]`). -/
theorem hyp_step_le_silver (i : Fin 3) (w : List (Fin 3)) :
    (hyp (i :: w) : ℝ) ≤ (3 + 2 * Real.sqrt 2) * (hyp w : ℝ) := by
  obtain ⟨h1, h2, _, _⟩ := seed_isSeed w
  have h1' : ((seed w).2 : ℝ) < ((seed w).1 : ℝ) := by exact_mod_cast h1
  have h2' : (0 : ℝ) < ((seed w).2 : ℝ) := by exact_mod_cast h2
  have hs := sqrt_two_sq
  have hsq := one_le_sqrt_two
  set m : ℝ := ((seed w).1 : ℝ)
  set n : ℝ := ((seed w).2 : ℝ)
  fin_cases i
  · -- move `L`: `5m² - 4mn + n² ≤ 5 (m²+n²) ≤ (3+2√2)(m²+n²)`
    have hle : (seed w).2 ≤ 2 * (seed w).1 := by omega
    show ((hyp ((0 : Fin 3) :: w) : ℕ) : ℝ) ≤ (3 + 2 * Real.sqrt 2) * (hyp w : ℝ)
    simp only [hyp, seed_cons, step, mvL]
    push_cast [hle]
    nlinarith
  · -- move `M`: the extremal (Pell) move
    simp only [hyp, seed_cons, step, mvM]
    push_cast
    have := silver_quad_M m n
    nlinarith
  · -- move `R`
    simp only [hyp, seed_cons, step, mvR]
    push_cast
    have := silver_quad_R m n
    nlinarith

@[simp] theorem hyp_nil : hyp [] = 5 := rfl

/-- **The silver speed limit.**  At depth `k` no hypotenuse exceeds `5 (3+2√2)^k`. -/
theorem hyp_le_silver_pow (w : List (Fin 3)) :
    (hyp w : ℝ) ≤ 5 * (3 + 2 * Real.sqrt 2) ^ w.length := by
  induction w with
  | nil => simp
  | cons i w ih =>
    have hpos : (0 : ℝ) < 3 + 2 * Real.sqrt 2 := by positivity
    calc (hyp (i :: w) : ℝ) ≤ (3 + 2 * Real.sqrt 2) * (hyp w : ℝ) := hyp_step_le_silver i w
      _ ≤ (3 + 2 * Real.sqrt 2) * (5 * (3 + 2 * Real.sqrt 2) ^ w.length) := by
          exact mul_le_mul_of_nonneg_left ih (le_of_lt hpos)
      _ = 5 * (3 + 2 * Real.sqrt 2) ^ (i :: w).length := by
          simp [List.length_cons, pow_succ]
          ring

/-! ## Part B. The three spines: one exponential, two quadratic -/

/-- The Pell (middle) spine: the word `MM…M` of length `k`. -/
def Mspine (k : ℕ) : List (Fin 3) := List.replicate k 1

/-- The left spine `LL…L` of length `k`. -/
def Lspine (k : ℕ) : List (Fin 3) := List.replicate k 0

/-- The right spine `RR…R` of length `k`. -/
def Rspine (k : ℕ) : List (Fin 3) := List.replicate k 2

theorem Lspine_seed (k : ℕ) : seed (Lspine k) = (k + 2, k + 1) := by
  induction k with
  | zero => rfl
  | succ k ih =>
    have : Lspine (k + 1) = (0 : Fin 3) :: Lspine k := rfl
    rw [this, seed_cons, ih]
    simp only [step, mvL]
    exact Prod.ext (by simp; omega) (by simp)

theorem Rspine_seed (k : ℕ) : seed (Rspine k) = (2 * k + 2, 1) := by
  induction k with
  | zero => rfl
  | succ k ih =>
    have : Rspine (k + 1) = (2 : Fin 3) :: Rspine k := rfl
    rw [this, seed_cons, ih]
    simp only [step, mvR]
    exact Prod.ext (by simp; omega) (by simp)

/-- **The left spine grows quadratically**: `c = 2k² + 6k + 5` (the triples
`(3,4,5), (5,12,13), (7,24,25), …`). -/
theorem Lspine_hyp (k : ℕ) : hyp (Lspine k) = 2 * k ^ 2 + 6 * k + 5 := by
  simp only [hyp, Lspine_seed]
  ring

/-- **The right spine grows quadratically**: `c = 4k² + 8k + 5` (the triples
`(3,4,5), (15,8,17), (35,12,37), …`). -/
theorem Rspine_hyp (k : ℕ) : hyp (Rspine k) = 4 * k ^ 2 + 8 * k + 5 := by
  simp only [hyp, Rspine_seed]
  ring

/-- The Pell spine obeys the silver recursion `m_{k+1} = 2 m_k + n_k`, `n_{k+1} = m_k`. -/
theorem Mspine_seed_succ (k : ℕ) :
    seed (Mspine (k + 1)) = (2 * (seed (Mspine k)).1 + (seed (Mspine k)).2,
      (seed (Mspine k)).1) := rfl

/-- The two-sided silver invariant along the Pell spine. -/
theorem Mspine_lower_invariant (k : ℕ) :
    2 * (1 + Real.sqrt 2) ^ k ≤ ((seed (Mspine k)).1 : ℝ) ∧
      2 * (1 + Real.sqrt 2) ^ k * (Real.sqrt 2 - 1) ≤ ((seed (Mspine k)).2 : ℝ) := by
  have hs := sqrt_two_sq
  have h1 := one_le_sqrt_two
  have hsle : Real.sqrt 2 ≤ 3 / 2 := by
    nlinarith [Real.sq_sqrt (show (0:ℝ) ≤ 2 by norm_num), Real.sqrt_nonneg 2]
  induction k with
  | zero =>
    constructor
    · norm_num [Mspine, seed]
    · norm_num [Mspine, seed]
      linarith
  | succ k ih =>
    obtain ⟨ihm, ihn⟩ := ih
    have hpow : (0 : ℝ) < (1 + Real.sqrt 2) ^ k := by positivity
    rw [Mspine_seed_succ]
    constructor
    · simp only
      push_cast
      have : 2 * (1 + Real.sqrt 2) ^ (k + 1) =
          2 * (2 * (1 + Real.sqrt 2) ^ k) + 2 * (1 + Real.sqrt 2) ^ k * (Real.sqrt 2 - 1) := by
        rw [pow_succ]
        ring
      rw [this]
      linarith
    · simp only
      have : 2 * (1 + Real.sqrt 2) ^ (k + 1) * (Real.sqrt 2 - 1) = 2 * (1 + Real.sqrt 2) ^ k := by
        rw [pow_succ]
        nlinarith
      rw [this]
      exact ihm

/-- **The Pell spine attains the silver rate.**  Along the middle branch the hypotenuse
satisfies `4 (3+2√2)^k ≤ c ≤ 5 (3+2√2)^k`, so it grows exactly like the square of the
silver ratio — the eigenvalue `3 + 2√2` of the Berggren generator. -/
theorem Mspine_silver_growth (k : ℕ) :
    4 * (3 + 2 * Real.sqrt 2) ^ k ≤ (hyp (Mspine k) : ℝ) ∧
      (hyp (Mspine k) : ℝ) ≤ 5 * (3 + 2 * Real.sqrt 2) ^ k := by
  have hs := sqrt_two_sq
  have h1 := one_le_sqrt_two
  constructor
  · obtain ⟨hm, -⟩ := Mspine_lower_invariant k
    have hsq : (1 + Real.sqrt 2) ^ 2 = 3 + 2 * Real.sqrt 2 := by nlinarith
    have hpow : ((1 + Real.sqrt 2) ^ k) ^ 2 = (3 + 2 * Real.sqrt 2) ^ k := by
      rw [← pow_mul, mul_comm, pow_mul, hsq]
    have hmpos : (0 : ℝ) ≤ 2 * (1 + Real.sqrt 2) ^ k := by positivity
    have hcast : (hyp (Mspine k) : ℝ)
        = ((seed (Mspine k)).1 : ℝ) ^ 2 + ((seed (Mspine k)).2 : ℝ) ^ 2 := by
      simp only [hyp]
      push_cast
      ring
    rw [hcast]
    nlinarith [sq_nonneg ((seed (Mspine k)).2 : ℝ)]
  · have := hyp_le_silver_pow (Mspine k)
    simpa [Mspine, List.length_replicate] using this

/-! ## Part C. The depth slice of the tree zeta series -/

/-- **The depth-`k` slice dominates the silver term.**  For `s ≥ 0` the sum of `c(w)^{-s}`
over the `3^k` nodes at depth `k` is at least `3^k (5 (3+2√2)^k)^{-s}`: the term of index
`k` of the silver Ihara-type zeta `∑_k 3^k (1+√2)^{-2ks}`. -/
theorem depth_slice_lower {s : ℝ} (hs : 0 ≤ s) (k : ℕ) :
    (3 : ℝ) ^ k * (5 * (3 + 2 * Real.sqrt 2) ^ k) ^ (-s) ≤
      ∑ v : Fin k → Fin 3, (hyp (List.ofFn v) : ℝ) ^ (-s) := by
  have hterm : ∀ v : Fin k → Fin 3,
      (5 * (3 + 2 * Real.sqrt 2) ^ k) ^ (-s) ≤ (hyp (List.ofFn v) : ℝ) ^ (-s) := by
    intro v
    have hlen : (List.ofFn v).length = k := by simp
    have hle : (hyp (List.ofFn v) : ℝ) ≤ 5 * (3 + 2 * Real.sqrt 2) ^ k := by
      have := hyp_le_silver_pow (List.ofFn v)
      rwa [hlen] at this
    have hpos : (0 : ℝ) < (hyp (List.ofFn v) : ℝ) := by
      have : 0 < hyp (List.ofFn v) := by
        obtain ⟨h1, h2, -, -⟩ := seed_isSeed (List.ofFn v)
        simp only [hyp]
        positivity
      exact_mod_cast this
    exact Real.rpow_le_rpow_of_nonpos hpos hle (by linarith)
  have hcard : (Finset.univ : Finset (Fin k → Fin 3)).card = 3 ^ k := by
    simp [Finset.card_univ]
  have := Finset.card_nsmul_le_sum (Finset.univ : Finset (Fin k → Fin 3))
    (fun v => (hyp (List.ofFn v) : ℝ) ^ (-s)) _ (fun v _ => hterm v)
  rw [hcard, nsmul_eq_mul] at this
  simpa using this

end BerggrenZeta