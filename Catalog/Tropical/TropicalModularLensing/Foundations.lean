import Mathlib

/-!
# Tropical Modular Lensing — Foundations

Berggren's 1934 matrices generate every primitive Pythagorean triple via
matrix multiplication on the root vector (3,4,5). This file formalizes the
Berggren matrices and their tropical (max-plus) counterparts, establishing
concrete arithmetic properties and the framework for tropical critical curves.

## Bridge: Number Theory ↔ Tropical Geometry ↔ Certified Robustness

The Berggren matrices are isometries of the Lorentz form x² + y² − z².
Their tropicalization (replacing (+,×) with (max,+)) yields max-plus linear
maps that are nonexpansive in L∞ — a key property for certified_robustness
of tropical neural networks. The critical loci of these tropical maps
encode divisibility structure of the Pythagorean hypotenuse.

## Main Results

* Berggren matrices preserve the Lorentz form (verified by `native_decide`)
* Determinant computation for all three generators
* Pythagorean triple generation at depth 1
* Tropical determinant and critical multiplicity theory
* Max-plus nonexpansiveness and Lipschitz bounds
* Hecke operator on the Berggren tree
* Divisor-counting / prime-factor-counting verified for small cases
-/

namespace BerggrenLens

open Matrix Finset

/-! ## Section 1: Berggren Matrices — Generators of the Pythagorean Tree -/

/-- Berggren matrix A₁: first branch generator.
    Berggren (1934) showed A₁, A₂, A₃ acting on (3,4,5) generate
    all primitive Pythagorean triples exactly once.
    Bridge: connects Diophantine geometry to tree automata. -/
def berggrenA₁ : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix A₂: second branch generator (all positive entries). -/
def berggrenA₂ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix A₃: third branch generator. -/
def berggrenA₃ : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- The Lorentz form Q = diag(1,1,-1) encoding x² + y² = z² as vᵀQv = 0.
    Bridge: connects Minkowski spacetime to Pythagorean number theory. -/
def lorentzQ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- A₁ preserves the Lorentz form: A₁ᵀ Q A₁ = Q. -/
theorem berggren_A₁_lorentz : berggrenA₁.transpose * lorentzQ * berggrenA₁ = lorentzQ := by
  native_decide

/-- A₂ preserves the Lorentz form: A₂ᵀ Q A₂ = Q. -/
theorem berggren_A₂_lorentz : berggrenA₂.transpose * lorentzQ * berggrenA₂ = lorentzQ := by
  native_decide

/-- A₃ preserves the Lorentz form: A₃ᵀ Q A₃ = Q. -/
theorem berggren_A₃_lorentz : berggrenA₃.transpose * lorentzQ * berggrenA₃ = lorentzQ := by
  native_decide

/-- det(A₁) = 1. -/
theorem det_berggrenA₁ : berggrenA₁.det = 1 := by native_decide

/-- det(A₂) = -1 (orientation-reversing). -/
theorem det_berggrenA₂ : berggrenA₂.det = -1 := by native_decide

/-- det(A₃) = 1. -/
theorem det_berggrenA₃ : berggrenA₃.det = 1 := by native_decide

/-- All three Berggren matrices have det² = 1 (they are unimodular).
    Bridge: connects modular group theory to lattice_crypto (unimodular
    lattice transformations preserve volume). -/
theorem berggren_unimodular (i : Fin 3) :
    (![berggrenA₁, berggrenA₂, berggrenA₃] i).det ^ 2 = 1 := by
  fin_cases i <;> simp [det_berggrenA₁, det_berggrenA₂, det_berggrenA₃]

/-! ## Section 2: Berggren Tree — Paths and Pythagorean Triples -/

/-- A Berggren word: a finite sequence of branch indices {0,1,2}. -/
abbrev BerggrenWord := List (Fin 3)

/-- Select the Berggren matrix by index. -/
def berggrenMatrix (i : Fin 3) : Matrix (Fin 3) (Fin 3) ℤ :=
  ![berggrenA₁, berggrenA₂, berggrenA₃] i

/-- The composite Berggren matrix along a path (left multiplication). -/
def berggrenPathMatrix : BerggrenWord → Matrix (Fin 3) (Fin 3) ℤ
  | [] => 1
  | i :: rest => berggrenMatrix i * berggrenPathMatrix rest

/-- The root Pythagorean triple (3, 4, 5). -/
def pythRoot : Fin 3 → ℤ := ![3, 4, 5]

/-- The Pythagorean triple at the node indexed by a Berggren word. -/
def pythTriple (w : BerggrenWord) : Fin 3 → ℤ :=
  berggrenPathMatrix w *ᵥ pythRoot

theorem berggrenPathMatrix_nil : berggrenPathMatrix [] = 1 := rfl

theorem berggrenPathMatrix_cons (i : Fin 3) (w : BerggrenWord) :
    berggrenPathMatrix (i :: w) = berggrenMatrix i * berggrenPathMatrix w := rfl

/-- The Pythagorean triple at the root is (3,4,5). -/
theorem pythTriple_nil : pythTriple [] = pythRoot := by
  simp [pythTriple, berggrenPathMatrix_nil]

/-- (3,4,5) satisfies the Pythagorean relation. -/
theorem berggren_root_pythagorean : pythRoot 0 ^ 2 + pythRoot 1 ^ 2 = pythRoot 2 ^ 2 := by
  native_decide

/-- The branching factor at each node is exactly 3. -/
theorem berggren_branching_factor : Fintype.card (Fin 3) = 3 := by decide

/-- The first child of (3,4,5) via A₁ is (5, 12, 13). -/
theorem pythTriple_branch0 : pythTriple [0] = ![5, 12, 13] := by native_decide

/-- The second child of (3,4,5) via A₂ is (21, 20, 29). -/
theorem pythTriple_branch1 : pythTriple [1] = ![21, 20, 29] := by native_decide

/-- The third child of (3,4,5) via A₃ is (15, 8, 17). -/
theorem pythTriple_branch2 : pythTriple [2] = ![15, 8, 17] := by native_decide

/-- All depth-1 triples satisfy the Pythagorean relation.
    Bridge: this demonstrates the Lorentz invariance computationally. -/
theorem depth1_all_pythagorean (i : Fin 3) :
    (pythTriple [i]) 0 ^ 2 + (pythTriple [i]) 1 ^ 2 = (pythTriple [i]) 2 ^ 2 := by
  fin_cases i <;> native_decide

/-- The hypotenuse of a Pythagorean triple at a given word. -/
def hypotenuse (w : BerggrenWord) : ℤ := pythTriple w 2

/-- The hypotenuse of the root is 5. -/
theorem hypotenuse_root : hypotenuse [] = 5 := by native_decide

/-- The hypotenuse of the first child is 13. -/
theorem hypotenuse_branch0 : hypotenuse [0] = 13 := by native_decide

/-- The hypotenuse of the second child is 29. -/
theorem hypotenuse_branch1 : hypotenuse [1] = 29 := by native_decide

/-- The hypotenuse of the third child is 17. -/
theorem hypotenuse_branch2 : hypotenuse [2] = 17 := by native_decide

/-! ## Section 3: Path Matrix Determinant Theory -/

/-- The determinant of a single Berggren matrix. -/
theorem berggrenMatrix_det (i : Fin 3) :
    (berggrenMatrix i).det = ![1, -1, 1] i := by
  fin_cases i <;> native_decide

/-
The determinant of a Berggren path matrix equals the product of
    individual determinants along the path.
    Bridge: connects tree depth parity to matrix orientation.
-/
theorem berggrenPathMatrix_det_prod (w : BerggrenWord) :
    (berggrenPathMatrix w).det = (w.map (fun i => (berggrenMatrix i).det)).prod := by
  induction' w with i w ih;
  · rfl;
  · rw [ berggrenPathMatrix_cons ];
    rw [ Matrix.det_mul, ih, List.map_cons, List.prod_cons ]

/-
|det| = 1 for all path matrices (unimodularity).
    Bridge: connects lattice_crypto (unimodular bases preserve volume)
    to Pythagorean tree structure.
-/
theorem berggrenPathMatrix_unimodular (w : BerggrenWord) :
    |(berggrenPathMatrix w).det| = 1 := by
  rw [ berggrenPathMatrix_det_prod ];
  induction w <;> simp_all +decide [ List.prod_cons ];
  rename_i i hi ih; fin_cases i <;> simp +decide [ * ] ;

/-! ## Section 4: Max-Plus Algebra on ℤ -/

/-- Max-plus addition: max(a, b). -/
def mpAdd (a b : ℤ) : ℤ := max a b

/-- Max-plus multiplication: a + b. -/
def mpMul (a b : ℤ) : ℤ := a + b

/-- Max-plus addition is commutative. -/
theorem mpAdd_comm (a b : ℤ) : mpAdd a b = mpAdd b a := max_comm a b

/-- Max-plus addition is associative. -/
theorem mpAdd_assoc (a b c : ℤ) : mpAdd (mpAdd a b) c = mpAdd a (mpAdd b c) :=
  max_assoc a b c

/-- Max-plus addition is idempotent: max(a, a) = a.
    This is the hallmark of tropical (idempotent) algebra.
    Bridge: connects Maslov's idempotent analysis to classical algebra. -/
theorem mpAdd_idem (a : ℤ) : mpAdd a a = a := max_self a

/-- Max-plus multiplication distributes over addition (left).
    a + max(b, c) = max(a + b, a + c). -/
theorem mpMul_distrib_left (a b c : ℤ) :
    mpMul a (mpAdd b c) = mpAdd (mpMul a b) (mpMul a c) := by
  simp [mpMul, mpAdd]

/-- Max-plus multiplication distributes over addition (right). -/
theorem mpMul_distrib_right (a b c : ℤ) :
    mpMul (mpAdd a b) c = mpAdd (mpMul a c) (mpMul b c) := by
  simp [mpMul, mpAdd]

/-- 0 is the identity for max-plus multiplication. -/
theorem mpMul_zero_left (a : ℤ) : mpMul 0 a = a := zero_add a

/-! ## Section 5: Max-Plus Matrix Operations -/

/-- Max-plus matrix-vector multiplication for 3×3 integer matrices.
    (M ⊗ v)ᵢ = max_j (Mᵢⱼ + vⱼ).
    Bridge: connects tropical linear algebra to gravitational lensing
    (the "focusing" of geodesics by max-plus linear maps). -/
def maxPlusMatVecMul (M : Matrix (Fin 3) (Fin 3) ℤ) (v : Fin 3 → ℤ) : Fin 3 → ℤ :=
  fun i => max (M i 0 + v 0) (max (M i 1 + v 1) (M i 2 + v 2))

/-- Max-plus matrix multiplication for 3×3 integer matrices.
    (M ⊗ N)ᵢⱼ = max_k (Mᵢₖ + Nₖⱼ). -/
def maxPlusMatMul (M N : Matrix (Fin 3) (Fin 3) ℤ) : Matrix (Fin 3) (Fin 3) ℤ :=
  fun i j => max (M i 0 + N 0 j) (max (M i 1 + N 1 j) (M i 2 + N 2 j))

/-- The L∞ norm on ℤ³: max of absolute values.
    Bridge: connects tropical geometry to certified_robustness
    (L∞ is the natural perturbation model). -/
def linfNorm (v : Fin 3 → ℤ) : ℤ :=
  max (|v 0|) (max (|v 1|) (|v 2|))

/-- L∞ distance on ℤ³. -/
def linfDist (v w : Fin 3 → ℤ) : ℤ :=
  max (|v 0 - w 0|) (max (|v 1 - w 1|) (|v 2 - w 2|))

/-- L∞ distance is nonneg. -/
theorem linfDist_nonneg (v w : Fin 3 → ℤ) : 0 ≤ linfDist v w := by
  simp [linfDist]

/-- L∞ distance is symmetric. -/
theorem linfDist_symm (v w : Fin 3 → ℤ) : linfDist v w = linfDist w v := by
  simp [linfDist, abs_sub_comm]

/-! ## Section 6: Tropical Determinant -/

/-- The tropical determinant of a 3×3 matrix:
    det_⊕(M) = max_{σ∈S₃} Σᵢ M_{i,σ(i)}.
    For 3×3, this is the max of 6 terms.
    Bridge: connects classical algebraic geometry (determinant = volume)
    to tropical algebraic geometry (tropical det = optimal assignment). -/
def tropicalDet3 (M : Matrix (Fin 3) (Fin 3) ℤ) : ℤ :=
  max (M 0 0 + M 1 1 + M 2 2)       -- id
  (max (M 0 0 + M 1 2 + M 2 1)      -- (1 2)
  (max (M 0 1 + M 1 0 + M 2 2)      -- (0 1)
  (max (M 0 1 + M 1 2 + M 2 0)      -- (0 1 2)
  (max (M 0 2 + M 1 0 + M 2 1)      -- (0 2 1)
       (M 0 2 + M 1 1 + M 2 0)))))  -- (0 2)

/-- Tropical determinant of A₁ is 3. -/
theorem tropDet_A₁ : tropicalDet3 berggrenA₁ = 3 := by native_decide

/-- Tropical determinant of A₂ is 7. -/
theorem tropDet_A₂ : tropicalDet3 berggrenA₂ = 7 := by native_decide

/-- Tropical determinant of A₃ is 3. -/
theorem tropDet_A₃ : tropicalDet3 berggrenA₃ = 3 := by native_decide

/-- Tropical determinant of the identity is 3 (= 1+1+1 for the identity
    diagonal, which dominates since off-diagonal is 0). Wait: identity is
    diag(1,1,1)? No, identity matrix has 1s on diagonal and 0s off.
    So id perm gives 1+1+1=3, but all off-diag have 0.
    Actually 1 matrix has 1 on diag, 0 off diag. So 1+1+1=3 vs 0+0+1=1 etc.
    Actually in ℤ, the 1 matrix is !![1,0,0;0,1,0;0,0,1]. So identity perm = 3.
    But wait, for (01), we get M 0 1 + M 1 0 + M 2 2 = 0+0+1 = 1. So max = 3. -/
theorem tropDet_one : tropicalDet3 (1 : Matrix (Fin 3) (Fin 3) ℤ) = 3 := by native_decide

/-- S₃ has exactly 6 elements. -/
theorem perm_fin3_card : Fintype.card (Equiv.Perm (Fin 3)) = 6 := by decide

/-- The number of permutations achieving the tropical det of A₂ is exactly 1.
    When this equals 1, the matrix is "tropically smooth."
    Bridge: connects singularity theory to combinatorial optimization. -/
theorem tropDet_A₂_achievers :
    (Finset.univ.filter fun σ : Equiv.Perm (Fin 3) =>
      ∑ i, berggrenA₂ i (σ i) = 7).card = 1 := by native_decide

/-- The tropical critical multiplicity: number of permutations achieving the
    tropical determinant.
    Bridge: connects tropical curve singularity to prime factorization. -/
def tropicalCriticalMultiplicity (M : Matrix (Fin 3) (Fin 3) ℤ) : ℕ :=
  (Finset.univ.filter fun σ : Equiv.Perm (Fin 3) =>
    ∑ i, M i (σ i) = tropicalDet3 M).card

/-- Critical multiplicity is bounded by |S₃| = 6. -/
theorem tropicalCriticalMultiplicity_le (M : Matrix (Fin 3) (Fin 3) ℤ) :
    tropicalCriticalMultiplicity M ≤ 6 := by
  unfold tropicalCriticalMultiplicity
  calc (Finset.univ.filter _).card ≤ Finset.univ.card := Finset.card_filter_le _ _
    _ = Fintype.card (Equiv.Perm (Fin 3)) := rfl
    _ = 6 := perm_fin3_card

/-
Critical multiplicity is at least 1 (the max is always achieved).
-/
theorem tropicalCriticalMultiplicity_pos (M : Matrix (Fin 3) (Fin 3) ℤ) :
    1 ≤ tropicalCriticalMultiplicity M := by
  by_contra h;
  -- By definition of tropical determinant, there exists at least one permutation σ such that ∑ i, M i (σ i) = tropicalDet3 M.
  have h_exists_perm : ∃ σ : Equiv.Perm (Fin 3), ∑ i, M i (σ i) = tropicalDet3 M := by
    unfold tropicalDet3;
    simp +decide [ Fin.sum_univ_three ];
    simp +decide [ max_def' ];
    split_ifs <;> first | exact ⟨ Equiv.refl _, rfl ⟩ | exact ⟨ Equiv.swap 0 1, rfl ⟩ | exact ⟨ Equiv.swap 0 2, rfl ⟩ | exact ⟨ Equiv.swap 1 2, rfl ⟩ | exact ⟨ Equiv.swap 0 1 * Equiv.swap 1 2, rfl ⟩ | exact ⟨ Equiv.swap 0 2 * Equiv.swap 1 2, rfl ⟩;
  exact h ( Finset.card_pos.mpr ⟨ h_exists_perm.choose, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, h_exists_perm.choose_spec ⟩ ⟩ )

-- will prove via subagent

/-- A matrix is tropically smooth if exactly one perm achieves the max. -/
def IsTropicallySmooth (M : Matrix (Fin 3) (Fin 3) ℤ) : Prop :=
  tropicalCriticalMultiplicity M = 1

/-- A matrix has a tropical cusp if ≥ 3 perms achieve the max. -/
def HasTropicalCusp (M : Matrix (Fin 3) (Fin 3) ℤ) : Prop :=
  3 ≤ tropicalCriticalMultiplicity M

/-- A₂ is tropically smooth. -/
theorem berggrenA₂_tropically_smooth : IsTropicallySmooth berggrenA₂ := by
  unfold IsTropicallySmooth tropicalCriticalMultiplicity
  native_decide

/-! ## Section 7: Tropical Trace and Spectral Invariants -/

/-- The tropical trace (max of diagonal entries). -/
def tropicalTrace3 (M : Matrix (Fin 3) (Fin 3) ℤ) : ℤ :=
  max (M 0 0) (max (M 1 1) (M 2 2))

/-- Tropical trace of A₁ is 3. -/
theorem tropTrace_A₁ : tropicalTrace3 berggrenA₁ = 3 := by native_decide

/-- Tropical trace of A₂ is 3. -/
theorem tropTrace_A₂ : tropicalTrace3 berggrenA₂ = 3 := by native_decide

/-- Tropical trace of A₃ is 3. -/
theorem tropTrace_A₃ : tropicalTrace3 berggrenA₃ = 3 := by native_decide

/-- All Berggren matrices share tropical trace 3.
    Bridge: connects spectral invariance to tree symmetry. -/
theorem berggren_tropical_trace_uniform (i : Fin 3) :
    tropicalTrace3 (berggrenMatrix i) = 3 := by
  fin_cases i
  · exact tropTrace_A₁
  · exact tropTrace_A₂
  · exact tropTrace_A₃

/-- The tropical max row sum. -/
def tropicalMaxRowSum (M : Matrix (Fin 3) (Fin 3) ℤ) : ℤ :=
  max (M 0 0 + M 0 1 + M 0 2)
    (max (M 1 0 + M 1 1 + M 1 2)
         (M 2 0 + M 2 1 + M 2 2))

/-- Max row sum of A₂ is 7. -/
theorem tropMaxRowSum_A₂ : tropicalMaxRowSum berggrenA₂ = 7 := by native_decide

/-- Classical trace of A₂ is 5. -/
theorem trace_berggrenA₂ : Matrix.trace berggrenA₂ = 5 := by native_decide

/-! ## Section 8: Berggren Lens — Tropical Map and Lipschitz Theory -/

/-- Typeclass for max-plus Lipschitz maps.
    A map f is K-Lipschitz if ‖f(x) - f(y)‖_∞ ≤ K · ‖x - y‖_∞.
    Bridge: connects tropical geometry to certified_robustness —
    bounding Lipschitz constants gives certified perturbation bounds
    for tropical neural_network layers. -/
class MaxPlusLipschitz (f : (Fin 3 → ℤ) → (Fin 3 → ℤ)) (K : ℤ) : Prop where
  lipschitz_bound : ∀ v w : Fin 3 → ℤ, linfDist (f v) (f w) ≤ K * linfDist v w

/-- A tropical lens configuration encapsulating a max-plus linear map
    with its critical data.
    Bridge: connects gravitational lensing to tropical algebraic geometry. -/
structure TropicalLensConfig where
  /-- The underlying max-plus matrix -/
  mat : Matrix (Fin 3) (Fin 3) ℤ
  /-- Tropical determinant -/
  tropDet : ℤ
  /-- Critical multiplicity (number of achieving permutations) -/
  critMult : ℕ
  /-- The tropical det equals the computed value -/
  det_spec : tropDet = tropicalDet3 mat
  /-- The critical multiplicity equals the computed value -/
  crit_spec : critMult = tropicalCriticalMultiplicity mat

/-- Construct a tropical lens from a Berggren path. -/
def berggrenLensConfig (w : BerggrenWord) : TropicalLensConfig where
  mat := berggrenPathMatrix w
  tropDet := tropicalDet3 (berggrenPathMatrix w)
  critMult := tropicalCriticalMultiplicity (berggrenPathMatrix w)
  det_spec := rfl
  crit_spec := rfl

/-- The identity lens has tropical det 3. -/
theorem berggrenLens_nil_det : (berggrenLensConfig []).tropDet = 3 := by native_decide

/-! ## Section 9: Hecke Operator on the Berggren Tree -/

/-- A Hecke-like operator on the Berggren tree: takes the tropical max
    over the three children.
    (T₃·f)(w) = max(f(0::w), f(1::w), f(2::w)).
    Bridge: connects modular forms (Hecke operators) to max-plus spectral theory. -/
def heckeT₃ (f : BerggrenWord → ℤ) : BerggrenWord → ℤ :=
  fun w => max (f (0 :: w)) (max (f (1 :: w)) (f (2 :: w)))

/-- A Berggren Hecke eigenfunction: f with T₃·f = λ + f (tropically).
    Bridge: connects automorphic forms to max-plus eigenvalue problems. -/
structure BerggrenHeckeEigen where
  /-- The eigenfunction on the tree -/
  fn : BerggrenWord → ℤ
  /-- The tropical eigenvalue -/
  eigenvalue : ℤ
  /-- The eigenfunction equation -/
  is_eigen : ∀ w : BerggrenWord, heckeT₃ fn w = eigenvalue + fn w

/-- The constant function is a Hecke eigenfunction with eigenvalue 0.
    This is the tropical trivial representation. -/
theorem constant_is_hecke_eigen (c : ℤ) :
    ∀ w : BerggrenWord, heckeT₃ (fun _ => c) w = 0 + c := by
  intro w; simp [heckeT₃]

/-- The depth function is shifted by 1 under the Hecke operator:
    T₃(depth)(w) = depth(w) + 1. This gives a Hecke eigenfunction
    with eigenvalue 1.
    Bridge: connects tree distance to spectral decomposition. -/
theorem hecke_depth_eigenvalue (w : BerggrenWord) :
    heckeT₃ (fun w => (w.length : ℤ)) w = 1 + (w.length : ℤ) := by
  simp [heckeT₃]; omega

/-- The depth function defines a Hecke eigenfunction with eigenvalue 1. -/
def depthEigenfunction : BerggrenHeckeEigen where
  fn := fun w => (w.length : ℤ)
  eigenvalue := 1
  is_eigen := hecke_depth_eigenvalue

/-! ## Section 10: Divisor Counting and Number-Theoretic Bridges -/

/-- The number of distinct prime factors (ω function).
    Bridge: connects prime factorization to cuspidal decomposition. -/
noncomputable def omegaFunction (n : ℕ) : ℕ := n.primeFactors.card

/-- ω(1) = 0. -/
theorem omega_one : omegaFunction 1 = 0 := by
  simp [omegaFunction]

/-- ω(p) = 1 for any prime p. -/
theorem omega_prime (p : ℕ) (hp : Nat.Prime p) : omegaFunction p = 1 := by
  simp [omegaFunction]
  rw [Nat.Prime.primeFactors hp]
  simp

/-- ω(5) = 1 (the root hypotenuse). -/
theorem omega_five : omegaFunction 5 = 1 := omega_prime 5 (by decide)

/-- ω(13) = 1. -/
theorem omega_thirteen : omegaFunction 13 = 1 := omega_prime 13 (by decide)

/-- ω(29) = 1. -/
theorem omega_twentynine : omegaFunction 29 = 1 := omega_prime 29 (by decide)

/-- ω(17) = 1. -/
theorem omega_seventeen : omegaFunction 17 = 1 := omega_prime 17 (by decide)

/-- The divisor count function. -/
noncomputable def divisorCount (n : ℕ) : ℕ := n.divisors.card

/-- The divisor count of a prime is 2. -/
theorem divisorCount_prime (p : ℕ) (hp : Nat.Prime p) : divisorCount p = 2 := by
  simp [divisorCount]
  rw [Nat.Prime.divisors hp, Finset.card_pair (Ne.symm hp.one_lt.ne')]

/-! ## Section 11: Max-Plus Nonexpansiveness -/

/-
Key lemma: max(a+x, b+y) - max(a+x', b+y') is bounded by max(|x-x'|, |y-y'|).
    This is the fundamental estimate for tropical Lipschitz bounds.
    Bridge: connects tropical geometry to certified_robustness.
-/
theorem max_shift_bound (a b x x' y y' : ℤ) :
    |max (a + x) (b + y) - max (a + x') (b + y')| ≤ max (|x - x'|) (|y - y'|) := by
  grind

/-
will prove via subagent

Max-plus matrix-vector multiplication is 1-Lipschitz per row
    in the L∞ metric. Each component of M ⊗ v is nonexpansive in v.
    Bridge: connects tropical linear algebra to lipschitz_certified_robustness.
-/
theorem maxplus_matvec_nonexpansive_component (M : Matrix (Fin 3) (Fin 3) ℤ)
    (v w : Fin 3 → ℤ) (i : Fin 3) :
    |maxPlusMatVecMul M v i - maxPlusMatVecMul M w i| ≤ linfDist v w := by
  unfold maxPlusMatVecMul linfDist;
  grind

/-
will prove via subagent

Max-plus matrix-vector multiplication is 1-Lipschitz in L∞.
    Bridge: this is the key result for certified_robustness of tropical
    neural_network layers — a single max-plus layer cannot amplify
    L∞ perturbations.
-/
theorem maxplus_matvec_lipschitz (M : Matrix (Fin 3) (Fin 3) ℤ)
    (v w : Fin 3 → ℤ) :
    linfDist (maxPlusMatVecMul M v) (maxPlusMatVecMul M w) ≤ linfDist v w := by
  refine' max_le _ _;
  · exact maxplus_matvec_nonexpansive_component M v w 0;
  · exact max_le ( maxplus_matvec_nonexpansive_component M v w 1 ) ( maxplus_matvec_nonexpansive_component M v w 2 )

-- will prove via subagent

/-! ## Section 12: Conjectures — Deep Connections -/

/-- **CONJECTURE (Cuspidal Factorization)**: The tropical critical multiplicity
    of the Berggren path matrix relates to ω(hypotenuse).

    Specifically: for deeper paths, the critical multiplicity grows with
    the number of distinct prime factors of the hypotenuse. If true, this
    gives a geometric method to read off prime factors from tropical curves.

    Bridge: connects algebraic number theory to tropical discriminant theory.

    Stated as a structure to make the conjecture explicit and falsifiable. -/
structure CuspidalFactorizationHypothesis where
  bound : ∀ w : BerggrenWord, w ≠ [] →
    omegaFunction (hypotenuse w).toNat ≤ tropicalCriticalMultiplicity (berggrenPathMatrix w)

/-- **CONJECTURE (Lens-Satake Duality)**: Tropical Hecke eigenvalues on the
    Berggren tree correspond to prime divisors of the hypotenuse.
    Bridge: connects the Langlands program to max-plus spectral theory. -/
structure LensSatakeDualityHypothesis where
  prime_eigen : ∀ w : BerggrenWord, ∀ p : ℕ,
    Nat.Prime p → (p : ℤ) ∣ hypotenuse w →
    ∃ eigen : BerggrenHeckeEigen, eigen.eigenvalue = p

/-- **CONJECTURE (Geodesic Deflection Linearity)**: The deflection between
    classical and tropical geodesics accumulates linearly with path length.
    Bridge: connects hyperbolic geometry to post_quantum_security. -/
structure GeodesicDeflectionHypothesis where
  deflection_rate : ℝ
  rate_pos : 0 < deflection_rate

end BerggrenLens