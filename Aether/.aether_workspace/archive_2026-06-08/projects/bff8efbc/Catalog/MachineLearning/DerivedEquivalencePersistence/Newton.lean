import Mathlib
import Speculative.DerivedEquivalencePersistence.Defs

/-!
# Newton's Identities and Power Sum Recovery

This file proves the key algebraic results underlying the arithmetic persistence
framework: Newton's identities connect power sums to elementary symmetric polynomials,
establishing that power sum sequences determine characteristic polynomials.

## Main Results

* `newton_recurrence_two` — Newton's recurrence for two eigenvalues
* `same_sym_same_power_sums` — equal symmetric functions ⟹ equal power sums
* `power_sums_determine_sym2` — power sums determine symmetric functions of pairs
* `charPoly_eval_zero` — characteristic polynomial evaluation
* `product_point_count` — multiplicativity of power sums for tensor products
* `tropical_slope_sum` — additivity of tropical slopes
-/

noncomputable section

open Finset BigOperators Polynomial

/-! ## Newton's Recurrence for Two Eigenvalues

For a pair {α, β}, the power sums s_r = αʳ + βʳ satisfy:
  s_r = (α + β) · s_{r-1} - αβ · s_{r-2}

This is the simplest case of Newton's identities. -/

/-- Newton's recurrence for two eigenvalues:
    s_{r+2} = (α + β) · s_{r+1} - αβ · s_r -/
theorem newton_recurrence_two (α β : ℤ) (r : ℕ) :
    α ^ (r + 2) + β ^ (r + 2) =
    (α + β) * (α ^ (r + 1) + β ^ (r + 1)) - α * β * (α ^ r + β ^ r) := by
  ring

/-
Two pairs with the same sum and product have the same power sums.
    This is the key direction: elementary symmetric functions determine power sums.
-/
theorem same_sym_same_power_sums (a₁ a₂ b₁ b₂ : ℤ)
    (hsum : a₁ + a₂ = b₁ + b₂)
    (hprod : a₁ * a₂ = b₁ * b₂) :
    ∀ r : ℕ, a₁ ^ r + a₂ ^ r = b₁ ^ r + b₂ ^ r := by
  intro r;
  induction' r using Nat.strong_induction_on with r ih;
  rcases r with ( _ | _ | r ) <;> simp_all +decide;
  have := ih r ( by linarith ) ; have := ih ( r + 1 ) ( by linarith ) ; simp_all +decide [ pow_succ' ] ;
  grind

/-- Power sums at r=1,2 determine the elementary symmetric functions of a pair -/
theorem power_sums_determine_sym2 (a₁ a₂ b₁ b₂ : ℤ)
    (h1 : a₁ + a₂ = b₁ + b₂)
    (h2 : a₁ ^ 2 + a₂ ^ 2 = b₁ ^ 2 + b₂ ^ 2) :
    a₁ + a₂ = b₁ + b₂ ∧ a₁ * a₂ = b₁ * b₂ := by
  exact ⟨h1, powerSum_determines_pair a₁ a₂ b₁ b₂ h1 h2⟩

/-- For two eigenvalues, Newton's recurrence gives an efficient computation -/
theorem two_eigenvalue_recurrence (a b : ℤ) :
    ∀ r : ℕ, powerSumSeq [a, b] (r + 2) =
      (a + b) * powerSumSeq [a, b] (r + 1) - a * b * powerSumSeq [a, b] r := by
  intro r
  simp [powerSumSeq]
  ring

/-! ## Characteristic Polynomial Properties -/

/-
The characteristic polynomial evaluated at 0 gives (-1)^n times the
    product of eigenvalues
-/
theorem charPoly_eval_zero (as : List ℤ) :
    (charPolyOfEigenvalues as).eval 0 = (as.map (fun a => -a)).prod := by
  induction as <;> simp_all +decide [ powerSumSeq, charPolyOfEigenvalues ]

/-
Characteristic polynomial of a permutation of eigenvalues is equal
-/
theorem charPoly_perm {as bs : List ℤ} (h : as.Perm bs) :
    charPolyOfEigenvalues as = charPolyOfEigenvalues bs := by
  exact List.Perm.prod_eq ( h.map _ )

/-! ## Tensor Product / Convolution Structure

For product varieties X × Y, the Künneth formula gives:
eigenvalues of H^k(X×Y) = {αᵢ · βⱼ : αᵢ ∈ H^i(X), βⱼ ∈ H^j(Y), i+j=k}

At the level of total point counts: N_r(X × Y) = N_r(X) · N_r(Y). -/

/-
Power sums of the "tensor product" eigenvalue list (all pairwise products)
    equal the product of the individual power sums
-/
theorem product_point_count (as bs : List ℤ) (r : ℕ) :
    powerSumSeq (as.flatMap (fun a => bs.map (a * ·))) r =
    powerSumSeq as r * powerSumSeq bs r := by
  induction as <;> simp +decide [ *, powerSumSeq ];
  simp_all +decide [ mul_pow, add_mul, List.sum_map_mul_left, List.sum_map_mul_right ];
  simp_all +decide [ Function.comp_def, mul_pow, List.sum_map_mul_left, List.sum_map_mul_right, ← mul_assoc, powerSumSeq ]

/-
The dimension of the tensor product is the product of dimensions
-/
theorem product_dim (as bs : List ℤ) :
    (as.flatMap (fun a => bs.map (a * ·))).length =
    as.length * bs.length := by
  simp +decide [ List.length_flatMap ]

/-! ## Tropical Geometry Connection

The sum of tropical slopes (p-adic valuations) equals the p-adic
valuation of the product of eigenvalues. -/

/-- The sum of tropical slopes equals the sum of p-adic valuations -/
theorem tropical_slope_sum (p : ℕ) (eigenvalues : List ℤ) :
    (tropicalPersistenceSlopes p eigenvalues).sum =
    (eigenvalues.map (padicValInt p)).sum := by
  have h := tropicalSlopes_perm p eigenvalues
  exact h.sum_eq

/-! ## The Persistence-Zeta Duality

The zeta function Z(t) and the persistence module contain the same information.
The key observation is that the logarithmic derivative t·Z'/Z has coefficients
equal to the power sum sequence.

For rational zeta functions (Weil conjectures), the persistence module
decomposes into a direct sum indexed by cohomological degree. -/

/-- The total point count from full cohomological data is the alternating sum -/
theorem total_from_cohomological (cohomData : List (List ℤ)) (r : ℕ) :
    alternatingPointCount cohomData r =
    ((cohomData.zipIdx).map
      (fun ⟨as, i⟩ => (-1 : ℤ) ^ i * powerSumSeq as r)).sum := by
  rfl

/-- For a curve (3 cohomological degrees), the zeta function structure:
    N_r = q^r - trace(Frob^r on H^1) + 1 -/
theorem curve_zeta_structure (q : ℕ) (h1_eigs : List ℤ) (r : ℕ) :
    alternatingPointCount [[(q : ℤ)], h1_eigs, [1]] r =
    (q : ℤ) ^ r - powerSumSeq h1_eigs r + 1 := by
  exact curve_point_count h1_eigs q r

/-! ## Inductive Proof: Power Sums via Strong Induction

We prove that if two pairs agree on elementary symmetric functions,
they agree on all power sums, using strong induction and the Newton recurrence. -/

/-- The power sum at r=0 for a pair is always 2 -/
theorem pair_power_sum_zero (a b : ℤ) : powerSumSeq [a, b] 0 = 2 := by
  simp [powerSumSeq]

/-- The power sum at r=1 for a pair is the sum -/
theorem pair_power_sum_one (a b : ℤ) : powerSumSeq [a, b] 1 = a + b := by
  simp [powerSumSeq]

/-
Newton's recurrence uniquely determines the power sum sequence from
    the initial conditions s_0 = 2, s_1 = e₁ and the recurrence
    s_{r+2} = e₁ · s_{r+1} - e₂ · s_r
-/
theorem newton_determines_sequence (e₁ e₂ : ℤ) (s t : ℕ → ℤ)
    (hs0 : s 0 = 2) (ht0 : t 0 = 2)
    (hs1 : s 1 = e₁) (ht1 : t 1 = e₁)
    (hsrec : ∀ r, s (r + 2) = e₁ * s (r + 1) - e₂ * s r)
    (htrec : ∀ r, t (r + 2) = e₁ * t (r + 1) - e₂ * t r) :
    ∀ r, s r = t r := by
  intro r; induction' r using Nat.strongRecOn with r ih; rcases r with ( _ | _ | r ) <;> simp_all +decide ;

/-! ## Cross-Domain: Connection to Thermodynamic Formalism

The "partition function" Z_β = ∑ |αᵢ|^β (for real β > 0) generalizes
the power sum to continuous parameter. Its Legendre transform gives
a "free energy" function, connecting to thermodynamic formalism.

This bridges persistence modules to statistical physics. -/

/-- The partition function at integer inverse temperature β = r -/
def partitionFunction (as : List ℤ) (r : ℕ) : ℤ :=
  (as.map (fun a => |a| ^ r)).sum

/-
The partition function is always non-negative
-/
theorem partitionFunction_nonneg (as : List ℤ) (r : ℕ) :
    0 ≤ partitionFunction as r := by
  exact List.sum_nonneg ( by aesop )

/-- The partition function at r=0 gives the number of eigenvalues -/
theorem partitionFunction_zero (as : List ℤ) :
    partitionFunction as 0 = as.length := by
  simp [partitionFunction]

/-
The partition function bounds the absolute value of power sums
-/
theorem powerSum_le_partition (as : List ℤ) (r : ℕ) :
    |powerSumSeq as r| ≤ partitionFunction as r := by
  -- By the triangle inequality for sums, we have � |�∑ i ∈ as, i^r| ≤ i ∈ as, |i^r|.
  have h_triangle : ∀ (l : List ℤ), |l.sum| ≤ (l.map (|·|)).sum := by
    intro l; induction l <;> simp +decide [ *, abs_mul ] ;
    grind +revert;
  convert h_triangle _ using 2 ; simp +decide [ partitionFunction, powerSumSeq ];
  exact congr_arg _ ( List.map_congr_left fun x hx => by simp +decide [ abs_pow ] )

end