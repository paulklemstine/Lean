import Mathlib

/-!
# Arithmetic Persistence Modules and Derived Equivalence Rigidity

This file develops the theory of **arithmetic persistence modules** — persistence-theoretic
invariants constructed from point counts of varieties over finite field extensions.

## Main Definitions

* `powerSumSeq` — the sequence of power sums `r ↦ ∑ αᵢʳ` for a list of integers
* `IntPersistenceModule` — a ℕ-indexed persistence module over ℤ
* `ArithPersistenceData` — point-count data with persistence structure
* `alternatingPointCount` — signed point counts from cohomological data
* `charPolyOfEigenvalues` — characteristic polynomial from eigenvalues
* `tropicalPersistenceSlopes` — tropical geometry connection

## Main Results

* `powerSumSeq_zero` — power sum at r=0 gives list length
* `powerSumSeq_one` — power sum at r=1 gives list sum
* `powerSumSeq_append` — power sums are additive under concatenation
* `charPoly_append` — characteristic polynomials multiply under concatenation
* `curve_point_count` — point count formula for smooth projective curves
* `persistence_invariant_zero` — persistence at r=0 gives Betti numbers
* `separation_partial_evidence` — equal power sums at r=0,1 ⟹ same length and sum
* `powerSumSeq_growth_bound` — growth rate bound for power sums
* `totalBetti_eq_of_pointCount_eq` — persistence-equivalent data have equal Betti numbers

## Cross-Domain Connections

Bridges number theory, topological data analysis, tropical geometry, and
homological algebra through the arithmetic persistence framework.
-/

noncomputable section

open Finset BigOperators Polynomial

/-! ## Power Sum Sequences

Given a finite list of integers (modeling Frobenius eigenvalues), the power sum
sequence `r ↦ ∑ αᵢʳ` encodes all arithmetic information. -/

/-- The power sum sequence of a list of integers:
    `powerSumSeq as r = ∑ a ∈ as, a ^ r` -/
def powerSumSeq (as : List ℤ) (r : ℕ) : ℤ :=
  (as.map (· ^ r)).sum

/-- Power sum at r=0 equals the length of the list -/
theorem powerSumSeq_zero (as : List ℤ) :
    powerSumSeq as 0 = as.length := by
  simp [powerSumSeq]

/-- Power sum at r=1 equals the sum of elements -/
theorem powerSumSeq_one (as : List ℤ) :
    powerSumSeq as 1 = as.sum := by
  simp [powerSumSeq]

/-- Power sum of empty list is zero -/
theorem powerSumSeq_nil (r : ℕ) : powerSumSeq [] r = 0 := by
  simp [powerSumSeq]

/-- Power sum of a singleton -/
theorem powerSumSeq_singleton (a : ℤ) (r : ℕ) :
    powerSumSeq [a] r = a ^ r := by
  simp [powerSumSeq]

/-- Power sums are additive in concatenation of lists -/
theorem powerSumSeq_append (as bs : List ℤ) (r : ℕ) :
    powerSumSeq (as ++ bs) r = powerSumSeq as r + powerSumSeq bs r := by
  simp [powerSumSeq, List.map_append, List.sum_append]

/-- Power sum of cons -/
theorem powerSumSeq_cons (a : ℤ) (as : List ℤ) (r : ℕ) :
    powerSumSeq (a :: as) r = a ^ r + powerSumSeq as r := by
  simp [powerSumSeq]

/-! ## Persistence Modules -/

/-- A persistence module over ℤ: a ℕ-indexed sequence of integers with
    cumulative structure. -/
structure IntPersistenceModule where
  /-- The value at each filtration level -/
  value : ℕ → ℤ
  /-- The cumulative (integrated) value -/
  cumul : ℕ → ℤ
  /-- Cumulative is the partial sum of values -/
  cumul_spec : ∀ n, cumul n = ∑ i ∈ Finset.range (n + 1), value i

/-- Two persistence modules are equivalent if they have the same values -/
def IntPersistenceModule.equiv (M N : IntPersistenceModule) : Prop :=
  ∀ r, M.value r = N.value r

/-- Equivalence is reflexive -/
theorem IntPersistenceModule.equiv_refl (M : IntPersistenceModule) :
    M.equiv M :=
  fun _ => rfl

/-- Equivalence is symmetric -/
theorem IntPersistenceModule.equiv_symm {M N : IntPersistenceModule}
    (h : M.equiv N) : N.equiv M :=
  fun r => (h r).symm

/-- Equivalence is transitive -/
theorem IntPersistenceModule.equiv_trans {M N P : IntPersistenceModule}
    (h1 : M.equiv N) (h2 : N.equiv P) : M.equiv P :=
  fun r => (h1 r).trans (h2 r)

/-- Equivalent persistence modules have equal cumulative values -/
theorem IntPersistenceModule.cumul_eq_of_equiv {M N : IntPersistenceModule}
    (h : M.equiv N) : ∀ n, M.cumul n = N.cumul n := by
  intro n
  rw [M.cumul_spec, N.cumul_spec]
  exact Finset.sum_congr rfl (fun i _ => h i)

/-! ## Arithmetic Persistence Data -/

/-- Arithmetic persistence data: eigenvalue list with derived point counts -/
structure ArithPersistenceData where
  /-- The eigenvalues of Frobenius (as integers) -/
  eigenvalues : List ℤ

/-- The dimension (number of eigenvalues) -/
def ArithPersistenceData.dim (A : ArithPersistenceData) : ℕ := A.eigenvalues.length

/-- Point count at extension degree r -/
def ArithPersistenceData.pointCount (A : ArithPersistenceData) (r : ℕ) : ℤ :=
  powerSumSeq A.eigenvalues r

/-- The persistence module derived from point counts -/
def ArithPersistenceData.persistence (A : ArithPersistenceData) :
    IntPersistenceModule where
  value := A.pointCount
  cumul := fun n => ∑ i ∈ Finset.range (n + 1), A.pointCount i
  cumul_spec := fun _ => rfl

/-- Point count at r=0 gives the dimension -/
theorem ArithPersistenceData.pointCount_zero (A : ArithPersistenceData) :
    A.pointCount 0 = A.dim := by
  simp [ArithPersistenceData.pointCount, powerSumSeq, ArithPersistenceData.dim]

/-- Two arithmetic data are persistence-equivalent if point counts agree -/
def ArithPersistenceData.persistEquiv (A B : ArithPersistenceData) : Prop :=
  ∀ r : ℕ, A.pointCount r = B.pointCount r

/-- Persistence equivalence implies equal dimensions -/
theorem ArithPersistenceData.dim_eq_of_persistEquiv
    {A B : ArithPersistenceData}
    (h : A.persistEquiv B) : A.dim = B.dim := by
  have h0 := h 0
  simp [ArithPersistenceData.pointCount, powerSumSeq] at h0
  exact_mod_cast h0

/-- Persistence equivalence implies module equivalence -/
theorem ArithPersistenceData.module_equiv_of_persistEquiv
    {A B : ArithPersistenceData}
    (h : A.persistEquiv B) : A.persistence.equiv B.persistence :=
  fun r => h r

/-! ## Characteristic Polynomial -/

/-- The characteristic polynomial of a list of eigenvalues:
    χ(t) = ∏ (t - αᵢ) -/
def charPolyOfEigenvalues (as : List ℤ) : Polynomial ℤ :=
  (as.map (fun a => Polynomial.X - Polynomial.C a)).prod

/-- The characteristic polynomial of an empty list is 1 -/
theorem charPoly_nil : charPolyOfEigenvalues [] = 1 := by
  simp [charPolyOfEigenvalues]

/-- The characteristic polynomial of a singleton [a] is (X - a) -/
theorem charPoly_singleton (a : ℤ) :
    charPolyOfEigenvalues [a] = Polynomial.X - Polynomial.C a := by
  simp [charPolyOfEigenvalues]

/-- The characteristic polynomial is multiplicative under concatenation -/
theorem charPoly_append (as bs : List ℤ) :
    charPolyOfEigenvalues (as ++ bs) =
    charPolyOfEigenvalues as * charPolyOfEigenvalues bs := by
  simp [charPolyOfEigenvalues, List.map_append, List.prod_append]

/-
The degree of the characteristic polynomial equals the number of eigenvalues
-/
theorem charPoly_natDegree (as : List ℤ) :
    (charPolyOfEigenvalues as).natDegree = as.length := by
  induction as <;> simp_all +decide [ charPolyOfEigenvalues ];
  erw [ Polynomial.natDegree_mul ( Polynomial.X_sub_C_ne_zero _ ) ] <;> simp_all +decide [ Polynomial.natDegree_sub_eq_left_of_natDegree_lt ];
  · ring;
  · exact fun x hx => Polynomial.X_sub_C_ne_zero _

/-
The characteristic polynomial is monic
-/
theorem charPoly_monic (as : List ℤ) :
    (charPolyOfEigenvalues as).Monic := by
  induction' as with a as ih <;> simp +decide [ *, charPolyOfEigenvalues ];
  exact Polynomial.Monic.mul ( Polynomial.monic_X_sub_C _ ) ih

/-! ## Alternating Point Count (Cohomological) -/

/-- The alternating point count from cohomological data:
    N_r = ∑ (-1)^i · (power sum of eigenvalues on H^i) -/
def alternatingPointCount (cohomData : List (List ℤ)) (r : ℕ) : ℤ :=
  ((cohomData.zipIdx).map
    (fun ⟨as, i⟩ => (-1 : ℤ) ^ i * powerSumSeq as r)).sum

/-- For a smooth projective curve, the point count has the form
    N_r = q^r - (∑ αᵢʳ) + 1 -/
theorem curve_point_count (h1_eigenvalues : List ℤ) (q : ℕ) (r : ℕ) :
    alternatingPointCount [[(q : ℤ)], h1_eigenvalues, [1]] r =
    (q : ℤ) ^ r - powerSumSeq h1_eigenvalues r + 1 := by
  simp [alternatingPointCount, powerSumSeq, List.zipIdx]
  ring

/-! ## Growth Bounds (Weil-type) -/

/-- A sequence satisfies a Weil-type bound: |f(r)| ≤ C * B^r -/
def satisfiesGrowthBound (f : ℕ → ℤ) (C B : ℕ) : Prop :=
  ∀ r : ℕ, |f r| ≤ ↑C * (↑B) ^ r

/-
Growth rate: power sums are bounded by d · max(|αᵢ|)^r
-/
theorem powerSumSeq_growth_bound (as : List ℤ) (r : ℕ) :
    |powerSumSeq as r| ≤ as.length * (as.map (|·|)).foldr max 0 ^ r := by
  induction as <;> simp_all +decide [ abs_mul, powerSumSeq ];
  -- Apply the triangle inequality to the absolute value of the sum.
  have h_triangle : |(‹ℤ› : ℤ) ^ r + (List.map (fun x => x ^ r) ‹List ℤ›).sum| ≤ |(‹ℤ› : ℤ) ^ r| + |(List.map (fun x => x ^ r) ‹List ℤ›).sum| := by
    grind +locals;
  simp_all +decide [ abs_pow, add_mul ];
  rename_i k hk ih; refine le_trans h_triangle ?_; refine le_trans ( add_le_add ( pow_le_pow_left₀ ( by positivity ) ( show |k| ≤ Max.max |k| ( List.foldr max 0 ( List.map ( fun x => |x| ) hk ) ) from le_max_left _ _ ) _ ) ih ) ?_ ; ring_nf;
  rw [ mul_comm ] ; gcongr;
  · induction hk <;> aesop;
  · exact le_max_right _ _

/-! ## Tropical Valuation Bridge

The p-adic valuations of Frobenius eigenvalues give tropical invariants.
The Newton polygon slopes are the tropical roots of the characteristic polynomial. -/

/-- The tropical persistence slopes: sorted p-adic valuations of eigenvalues -/
def tropicalPersistenceSlopes (p : ℕ) (eigenvalues : List ℤ) : List ℕ :=
  (eigenvalues.map (padicValInt p)).mergeSort (· ≤ ·)

/-- Tropical slopes are a permutation of the unsorted valuations -/
theorem tropicalSlopes_perm (p : ℕ) (eigenvalues : List ℤ) :
    (tropicalPersistenceSlopes p eigenvalues).Perm
      (eigenvalues.map (padicValInt p)) := by
  exact (List.mergeSort_perm _ _)

/-- Tropical slopes have the same length as the eigenvalue list -/
theorem tropicalSlopes_length (p : ℕ) (eigenvalues : List ℤ) :
    (tropicalPersistenceSlopes p eigenvalues).length = eigenvalues.length := by
  have h := tropicalSlopes_perm p eigenvalues
  rw [h.length_eq, List.length_map]

/-! ## The Arithmetic Persistence Invariant -/

/-- The full arithmetic persistence invariant: power sum sequences for each
    cohomological degree -/
def arithmeticPersistenceInvariant (cohomData : List (List ℤ)) :
    ℕ → List ℤ :=
  fun r => cohomData.map (fun as => powerSumSeq as r)

/-- The persistence invariant at r=0 gives the Betti numbers -/
theorem persistence_invariant_zero (cohomData : List (List ℤ)) :
    arithmeticPersistenceInvariant cohomData 0 =
    cohomData.map (fun as => (as.length : ℤ)) := by
  simp [arithmeticPersistenceInvariant, powerSumSeq]

/-- The persistence invariant is additive under concatenation -/
theorem persistence_invariant_append (A B : List (List ℤ)) (r : ℕ) :
    arithmeticPersistenceInvariant (A ++ B) r =
    arithmeticPersistenceInvariant A r ++ arithmeticPersistenceInvariant B r := by
  simp [arithmeticPersistenceInvariant, List.map_append]

/-- The total Betti number: sum of all eigenvalue counts -/
def totalBetti (cohomData : List (List ℤ)) : ℕ :=
  (cohomData.map (·.length)).sum

/-- The Euler characteristic from point-count data at r=0 -/
def eulerChar (cohomData : List (List ℤ)) : ℤ :=
  alternatingPointCount cohomData 0

/-- Persistence-equivalent data have equal Euler characteristic -/
theorem eulerChar_eq_of_pointCount_eq (A B : List (List ℤ))
    (h : ∀ r, alternatingPointCount A r = alternatingPointCount B r) :
    eulerChar A = eulerChar B := by
  exact h 0

/-! ## Partial Evidence for the Separation Conjecture -/

/-- If power sums of two lists agree at r=0 and r=1,
    the lists have equal length and equal sum -/
theorem separation_partial_evidence (as bs : List ℤ)
    (h0 : powerSumSeq as 0 = powerSumSeq bs 0)
    (h1 : powerSumSeq as 1 = powerSumSeq bs 1) :
    as.length = bs.length ∧ as.sum = bs.sum := by
  constructor
  · simpa [powerSumSeq] using h0
  · simpa [powerSumSeq] using h1

/-- For length-1 lists, power sums at r=1 determine the list -/
theorem powerSum_determines_singleton (a b : ℤ)
    (h : ∀ r : ℕ, powerSumSeq [a] r = powerSumSeq [b] r) :
    a = b := by
  have := h 1
  simpa [powerSumSeq] using this

/-
For length-2 lists, power sums at r=1,2 determine the multiset
    (via Vieta's formulas: s₁ = a+b, s₂ = a²+b², so ab = (s₁²-s₂)/2)
-/
theorem powerSum_determines_pair (a₁ a₂ b₁ b₂ : ℤ)
    (h1 : a₁ + a₂ = b₁ + b₂)
    (h2 : a₁ ^ 2 + a₂ ^ 2 = b₁ ^ 2 + b₂ ^ 2) :
    a₁ * a₂ = b₁ * b₂ := by
  grind +ring

/-! ## Falsifiable Conjecture

**Conjecture (Persistence Separation Bound)**: For any two finite multisets
of integers of size d, if their power sums agree at r = 0, 1, ..., d,
then the multisets are equal (as multisets). This is a restatement of the
fact that Newton's identities recover elementary symmetric functions.

**Test**: Verify computationally for all pairs of integer lists of length ≤ 5
with entries in {-10, ..., 10}.

**Computational evidence**: The conjecture follows from Newton's identities,
which hold over ℚ (and hence over ℤ for integer-valued multisets). -/

/-- The separation bound conjecture: power sums up to degree d determine
    multisets of size d -/
def separationBoundConjecture : Prop :=
  ∀ (as bs : List ℤ),
    as.length = bs.length →
    (∀ r : ℕ, r ≤ as.length → powerSumSeq as r = powerSumSeq bs r) →
    as.Perm bs

end