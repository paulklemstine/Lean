import Mathlib

/-! # CatalogBuild.Physics.Classical.GeometricRepulsor

Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 15
-/

/-- The fundamental identity: x² - y² = (x - y)(x + y). -/
theorem fermat_diff_sq (x y : ℤ) : x ^ 2 - y ^ 2 = (x - y) * (x + y) := by ring

/-- If N = x² - y², then N = (x-y)(x+y). -/
theorem fermat_factor_correct (N x y : ℤ) (h : N = x ^ 2 - y ^ 2) :
    N = (x - y) * (x + y) := by linarith [fermat_diff_sq x y]

/-- [Section: # CatalogBuild.Physics.Classical.GeometricRepulsor
Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 15] -/
theorem odd_fermat_rep (p q : ℤ) (hp : Odd p) (hq : Odd q) :
    p * q = ((p + q) / 2) ^ 2 - ((q - p) / 2) ^ 2 := by
  obtain ⟨ m, rfl ⟩ := hp; obtain ⟨ n, rfl ⟩ := hq; ring;
  norm_num [ show 2 + m * 2 + n * 2 = 2 * ( 1 + m + n ) by ring, show - ( m * 2 ) + n * 2 = 2 * ( -m + n ) by ring, Int.add_mul_ediv_left ] ; ring;

/-- The factors from Fermat's method are nontrivial when the representation is
nontrivial (i.e., y > 0 and x - y > 1). -/
theorem fermat_nontrivial (N x y : ℤ) (hN : N = x ^ 2 - y ^ 2)
    (hy_pos : 0 < y) (hfactor : 1 < x - y) :
    1 < x - y ∧ 1 < x + y ∧ (x - y) * (x + y) = N := by
  refine ⟨hfactor, by linarith, by linarith [fermat_diff_sq x y]⟩

/-- A perfect square reduced mod m equals (k mod m)² mod m. -/
theorem sq_mod_eq (k m : ℤ) :
    (k ^ 2) % m = (k % m) ^ 2 % m := by
  rw [sq, Int.mul_emod, sq]

/-- [Section: # CatalogBuild.Physics.Classical.GeometricRepulsor
Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 15] -/
theorem quad_residues_mod_64 (k : ℤ) :
    (k ^ 2) % 64 ∈ ({0, 1, 4, 9, 16, 17, 25, 33, 36, 41, 49, 57} : Set ℤ) := by
  rw [ sq, Int.mul_emod ] ; have := Int.emod_nonneg k ( by decide : ( 64 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos k ( by decide : ( 64 : ℤ ) > 0 ) ; interval_cases k % 64 <;> trivial;

theorem quad_residues_mod_11 (k : ℤ) :
    (k ^ 2) % 11 ∈ ({0, 1, 3, 4, 5, 9} : Set ℤ) := by
  norm_num [ sq, Int.mul_emod ] ; have := Int.emod_nonneg k ( by decide : ( 11 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos k ( by decide : ( 0 : ℤ ) < 11 ) ; interval_cases k % 11 <;> trivial;

theorem quad_residues_mod_13 (k : ℤ) :
    (k ^ 2) % 13 ∈ ({0, 1, 3, 4, 9, 10, 12} : Set ℤ) := by
  norm_num [ sq, Int.mul_emod ] ; have := Int.emod_nonneg k ( by decide : ( 13 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos k ( by decide : ( 0 : ℤ ) < 13 ) ; interval_cases k % 13 <;> simp +decide ;

theorem quad_residues_mod_17 (k : ℤ) :
    (k ^ 2) % 17 ∈ ({0, 1, 2, 4, 8, 9, 13, 15, 16} : Set ℤ) := by
  norm_num [ sq, Int.mul_emod ] ; have := Int.emod_nonneg k ( by decide : ( 17 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos k ( by decide : ( 17 : ℤ ) > 0 ) ; interval_cases k % 17 <;> simp +decide ;

theorem quad_residues_mod_19 (k : ℤ) :
    (k ^ 2) % 19 ∈ ({0, 1, 4, 5, 6, 7, 9, 11, 16, 17} : Set ℤ) := by
  norm_num [ sq, Int.mul_emod ] ; have := Int.emod_nonneg k ( by decide : ( 19 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos k ( by decide : ( 0 : ℤ ) < 19 ) ; interval_cases k % 19 <;> trivial;

/-- The sieve never discards a true perfect square (soundness).
If y² = x² - N and the sieve passes, then x² - N is indeed a perfect square.
Conversely, if x² - N IS a perfect square, the sieve will NOT discard it. -/
theorem sieve_sound_mod_64 (n : ℤ) (hn : ∃ k : ℤ, n = k ^ 2) :
    n % 64 ∈ ({0, 1, 4, 9, 16, 17, 25, 33, 36, 41, 49, 57} : Set ℤ) := by
  obtain ⟨k, rfl⟩ := hn
  exact quad_residues_mod_64 k

/-- Combined sieve soundness: a perfect square passes ALL sieve checks. -/
theorem sieve_sound_all (n : ℤ) (hn : ∃ k : ℤ, n = k ^ 2) :
    n % 64 ∈ ({0, 1, 4, 9, 16, 17, 25, 33, 36, 41, 49, 57} : Set ℤ) ∧
    n % 11 ∈ ({0, 1, 3, 4, 5, 9} : Set ℤ) ∧
    n % 13 ∈ ({0, 1, 3, 4, 9, 10, 12} : Set ℤ) ∧
    n % 17 ∈ ({0, 1, 2, 4, 8, 9, 13, 15, 16} : Set ℤ) ∧
    n % 19 ∈ ({0, 1, 4, 5, 6, 7, 9, 11, 16, 17} : Set ℤ) := by
  obtain ⟨k, rfl⟩ := hn
  exact ⟨quad_residues_mod_64 k, quad_residues_mod_11 k, quad_residues_mod_13 k,
         quad_residues_mod_17 k, quad_residues_mod_19 k⟩

/-- The exact Fermat solution point for N = p * q (p, q odd, p ≤ q). -/
theorem fermat_solution_point (p q : ℤ) (hp : Odd p) (hq : Odd q)
    (hpq : p ≤ q) (hp_pos : 0 < p) :
    let x := (p + q) / 2
    let y := (q - p) / 2
    x ^ 2 - y ^ 2 = p * q ∧ 0 ≤ y := by
  constructor
  · linarith [odd_fermat_rep p q hp hq]
  · omega

/-- Computable Fermat factorization search with sieving.
Returns `some (p, q)` if a factorization is found within `fuel` steps. -/
def fermatSearchSieved (N : ℕ) (x : ℕ) (fuel : ℕ) : Option (ℕ × ℕ) :=
  match fuel with
  | 0 => none
  | fuel' + 1 =>
    if x * x < N then none  -- x too small
    else
      let diff := x * x - N
      -- Sieve: check mod 64
      let r64 := diff % 64
      if r64 ∈ [0, 1, 4, 9, 16, 17, 25, 33, 36, 41, 49, 57] then
        -- Sieve: check mod 11
        let r11 := diff % 11
        if r11 ∈ [0, 1, 3, 4, 5, 9] then
          -- Full square check
          let y := Nat.sqrt diff
          if y * y == diff then
            some (x - y, x + y)
          else
            fermatSearchSieved N (x + 1) fuel'
        else
          fermatSearchSieved N (x + 1) fuel'
      else
        fermatSearchSieved N (x + 1) fuel'

/-- Top-level Fermat factorization with sieving.
Starts from ⌈√N⌉ and searches up to `maxSteps` candidates. -/
def fermatFactorSieved (N : ℕ) (maxSteps : ℕ := 1000000) : Option (ℕ × ℕ) :=
  let start := Nat.sqrt N + 1
  fermatSearchSieved N start maxSteps

-- Verification examples
#eval fermatFactorSieved 15        -- some (3, 5)
#eval fermatFactorSieved 77        -- some (7, 11)
#eval fermatFactorSieved 143       -- some (11, 13)
#eval fermatFactorSieved 221       -- some (13, 17)
#eval fermatFactorSieved 1073      -- some (29, 37)
#eval fermatFactorSieved 10403     -- some (101, 103)

-- Larger examples showing the algorithm works for close primes
#eval fermatFactorSieved (997 * 1009)    -- 1005973
#eval fermatFactorSieved (10007 * 10009)