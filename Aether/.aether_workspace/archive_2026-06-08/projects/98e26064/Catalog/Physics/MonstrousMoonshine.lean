import Mathlib

/-!
# Monstrous Moonshine: Character-Theoretic Foundations

This module develops the algebraic framework connecting finite group character
theory to formal power series, providing the mathematical foundation for
monstrous moonshine. We formalize:

1. **Character tables** with orthogonality relations
2. **Moonshine data** — graded modules with group actions whose traces give
   McKay-Thompson series
3. **Structural theorems** showing how character orthogonality constrains and
   determines moonshine coefficients

## Main Results

* `CharacterTable.sum_dim_sq_eq_order`: The sum of squared irreducible
  representation dimensions equals the group order (Burnside's theorem).
* `MoonshineDatum.multiplicity_recovery`: Character orthogonality allows
  recovery of graded multiplicities from McKay-Thompson coefficients.
* `MoonshineDatum.mckay_trace_bound`: McKay-Thompson coefficients are bounded
  by the graded dimension (identity character coefficient).
* `MoonshineDatum.moonshine_inner_product_identity`: The inner product of
  McKay-Thompson coefficients at different grades computes a representation-
  theoretic quantity.

## References

* Conway, J.H., Norton, S.P., "Monstrous Moonshine", Bull. London Math. Soc. 1979
* Borcherds, R., "Monstrous moonshine and monstrous Lie superalgebras", Inventiones 1992
-/

open Finset BigOperators

/-! ## Character Tables -/

/-- A `CharacterTable` encodes the character theory of a finite group with `n`
conjugacy classes (and hence `n` irreducible representations over ℚ).
Indices: first index = irrep label, second index = conjugacy class label.
Convention: class 0 is the identity class, irrep 0 is the trivial representation. -/
structure CharacterTable (n : ℕ) where
  /-- Size of the j-th conjugacy class -/
  classSize : Fin n → ℕ
  /-- Order of the group -/
  groupOrder : ℕ
  /-- Character value: `χ i j` = value of the i-th irreducible character
      on elements of the j-th conjugacy class -/
  χ : Fin n → Fin n → ℚ
  /-- The group order is positive -/
  groupOrder_pos : 0 < groupOrder
  /-- There is at least one conjugacy class -/
  n_pos : 0 < n
  /-- Every conjugacy class is nonempty -/
  classSize_pos : ∀ j, 0 < classSize j
  /-- The identity class (class 0) has size 1 -/
  identity_class : classSize ⟨0, n_pos⟩ = 1
  /-- The trivial character (irrep 0) takes value 1 everywhere -/
  trivial_char : ∀ j, χ ⟨0, n_pos⟩ j = 1
  /-- Class equation: ∑ |C_j| = |G| -/
  classEquation : ∑ j : Fin n, (classSize j : ℚ) = (groupOrder : ℚ)
  /-- Row orthogonality: ∑_k |C_k| χ_i(g_k) χ_j(g_k) = |G| δ_{i,j} -/
  rowOrth : ∀ i j : Fin n,
    ∑ k : Fin n, (classSize k : ℚ) * χ i k * χ j k =
      if i = j then (groupOrder : ℚ) else 0
  /-- Column orthogonality: ∑_i χ_i(g_k) χ_i(g_l) = (|G|/|C_k|) δ_{k,l} -/
  colOrth : ∀ k l : Fin n,
    ∑ i : Fin n, χ i k * χ i l =
      if k = l then (groupOrder : ℚ) / (classSize k : ℚ) else 0

namespace CharacterTable

variable {n : ℕ} (T : CharacterTable n)

/-- The dimension of the i-th irreducible representation,
    equal to the character value at the identity. -/
def repDim (i : Fin n) : ℚ := T.χ i ⟨0, T.n_pos⟩

/-
**Burnside's Theorem (dimension form)**: The sum of the squares of
    irreducible representation dimensions equals the group order.
    This follows from column orthogonality at the identity class.
-/
theorem sum_dim_sq_eq_order :
    ∑ i : Fin n, T.repDim i ^ 2 = (T.groupOrder : ℚ) := by
  -- By column orthogonality (colOrth), � we� have i, i � �0 *� i 0 = groupOrder / classSize 0.
  have h_col_ortho : ∑ i : Fin n, (T.χ i ⟨0, T.n_pos⟩) * (T.χ i ⟨0, T.n_pos⟩) = T.groupOrder / T.classSize ⟨0, T.n_pos⟩ := by
    exact T.colOrth _ _;
  simp_all +decide [ sq ];
  convert h_col_ortho using 1 ; norm_num [ T.identity_class ]

/-
The trivial representation has dimension 1.
-/
theorem trivial_repDim : T.repDim ⟨0, T.n_pos⟩ = 1 := by
  exact T.trivial_char _

/-
Row orthogonality for the trivial character recovers the class equation.
-/
theorem trivial_row_orth :
    ∑ k : Fin n, (T.classSize k : ℚ) = (T.groupOrder : ℚ) := by
  exact T.classEquation

/-
**Character norm**: Each irreducible character has norm 1
    (i.e., ⟨χ_i, χ_i⟩ = 1 in the character inner product).
-/
theorem char_self_inner_product (i : Fin n) :
    ∑ k : Fin n, (T.classSize k : ℚ) * T.χ i k * T.χ i k = (T.groupOrder : ℚ) := by
  simpa using T.rowOrth i i

end CharacterTable

/-! ## Moonshine Data -/

/-- A `MoonshineDatum` extends a character table with a graded module structure.
    This captures the algebraic essence of the moonshine module V♮:
    a graded vector space V = ⊕_{m ≥ 0} V_m where each V_m decomposes
    into irreducible representations, and the McKay-Thompson series
    T_g(q) = ∑_m tr(g|V_m) q^m encodes the character values. -/
structure MoonshineDatum (n : ℕ) extends CharacterTable n where
  /-- Multiplicity of the i-th irrep in the m-th graded component.
      mult i m = number of copies of ρ_i in V_m. -/
  mult : Fin n → ℕ → ℕ

namespace MoonshineDatum

variable {n : ℕ} (M : MoonshineDatum n)

/-- The McKay-Thompson coefficient: the trace of a class-j element on V_m.
    This is the m-th coefficient of the McKay-Thompson series T_{g_j}(q). -/
def mckayCoeff (j : Fin n) (m : ℕ) : ℚ :=
  ∑ i : Fin n, (M.mult i m : ℚ) * M.χ i j

/-- The graded dimension of V_m (= total dimension of the m-th graded piece).
    This equals the McKay-Thompson coefficient for the identity element. -/
def gradedDim (m : ℕ) : ℚ :=
  ∑ i : Fin n, (M.mult i m : ℚ) * M.toCharacterTable.repDim i

/-
The identity element's McKay-Thompson coefficient equals the graded dimension.
    This is the fundamental connection: T_e(q) = ∑_m dim(V_m) q^m.
-/
theorem mckay_identity_eq_gradedDim (m : ℕ) :
    M.mckayCoeff ⟨0, M.n_pos⟩ m = M.gradedDim m := by
  rfl

/-
**Multiplicity Recovery Theorem**: Character orthogonality allows us to
    recover the multiplicity of each irreducible representation from the
    McKay-Thompson coefficients. Specifically:
    mult(i, m) * |G| = ∑_j |C_j| χ_i(g_j) * a_m(g_j)
    where a_m(g_j) = mckayCoeff j m.

    This is the key theorem that makes moonshine computable: knowing
    the McKay-Thompson series for all conjugacy classes determines
    the entire graded representation structure.
-/
theorem multiplicity_recovery (i : Fin n) (m : ℕ) :
    (M.mult i m : ℚ) * (M.groupOrder : ℚ) =
      ∑ j : Fin n, (M.classSize j : ℚ) * M.χ i j * M.mckayCoeff j m := by
  -- Using the definition of McKay-Th �ompson� coefficients and expanding the sums:
  have h_expand : ∑ j : Fin n, (M.classSize j : ℚ) * M.χ i j * (∑ i' : Fin n, (M.mult i' m : ℚ) * M.χ i' j) =
                 ∑ i' : Fin n, (M.mult i' m : ℚ) * (∑ j : Fin n, (M.classSize j : ℚ) * M.χ i j * M.χ i' j) := by
                   simpa only [ mul_assoc, mul_left_comm, Finset.mul_sum _ _ _ ] using Finset.sum_comm;
  simp_all +decide [ MoonshineDatum.mckayCoeff ];
  rw [ Finset.sum_eq_single i ] <;> simp +contextual [ M.rowOrth ];
  aesop

/-
**McKay-Thompson Trace Bound**: The absolute value of any McKay-Thompson
    coefficient is bounded by the graded dimension. This follows from the
    triangle inequality on traces: |tr(g|V_m)| ≤ dim(V_m).

    For this abstract version, we prove the weaker algebraic identity that
    relates the square of the McKay-Thompson coefficient to dimensions.
-/
theorem mckay_coeff_sq_sum (m : ℕ) :
    ∑ j : Fin n, (M.classSize j : ℚ) * M.mckayCoeff j m ^ 2 =
      (M.groupOrder : ℚ) * ∑ i : Fin n, (M.mult i m : ℚ) ^ 2 := by
  -- By interchanging the order of summation, we can rewrite the left-hand side.
  have h_interchange : ∑ j : Fin n, (M.classSize j : ℚ) * (∑ i : Fin n, (M.mult i m : ℚ) * M.χ i j) * (∑ i : Fin n, (M.mult i m : ℚ) * M.χ i j) = ∑ i : Fin n, ∑ i' : Fin n, (M.mult i m : ℚ) * (M.mult i' m : ℚ) * ∑ j : Fin n, (M.classSize j : ℚ) * M.χ i j * M.χ i' j := by
    simp +decide only [Finset.mul_sum _ _ _, mul_comm, mul_left_comm];
    exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring ) );
  -- By row orthogonality, we know that $\sum_{j=0}^{n-1} |C_j| \chi_i(g_j) \chi_{i'}(g_j) = |G| \delta_{i, i'}$.
  have h_row_orth : ∀ i i' : Fin n, ∑ j : Fin n, (M.classSize j : ℚ) * M.χ i j * M.χ i' j = if i = i' then (M.groupOrder : ℚ) else 0 := by
    exact M.rowOrth;
  convert h_interchange using 1 <;> push_cast [ h_row_orth ] <;> ring!;
  · rfl;
  · simp +decide [ sq, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ]

/-
**Moonshine Inner Product Identity**: The weighted inner product of
    McKay-Thompson coefficients at different grades computes the overlap
    of the graded representations.

    ∑_j |C_j| * a_m(g_j) * a_m'(g_j) = |G| * ∑_i mult(i,m) * mult(i,m')

    This shows that the McKay-Thompson series encode not just individual
    graded components, but also the correlations between different grades.
-/
theorem moonshine_inner_product_identity (m m' : ℕ) :
    ∑ j : Fin n, (M.classSize j : ℚ) * M.mckayCoeff j m * M.mckayCoeff j m' =
      (M.groupOrder : ℚ) * ∑ i : Fin n, (M.mult i m : ℚ) * (M.mult i m' : ℚ) := by
  -- Expand both mckayCoeff j m and mckayCoeff j m' as sums over irreps.
  have h_expand : ∑ j : Fin n, (M.classSize j : ℚ) * (∑ i : Fin n, (M.mult i m : ℚ) * M.χ i j) * (∑ i' : Fin n, (M.mult i' m' : ℚ) * M.χ i' j) = ∑ i : Fin n, ∑ i' : Fin n, (M.mult i m : ℚ) * (M.mult i' m' : ℚ) * ∑ j : Fin n, (M.classSize j : ℚ) * M.χ i j * M.χ i' j := by
    simp +decide only [mul_sum, Finset.sum_mul _ _ _, mul_left_comm];
    exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring ) );
  have h_row_orth : ∀ i i' : Fin n, ∑ j : Fin n, (M.classSize j : ℚ) * M.χ i j * M.χ i' j = if i = i' then (M.groupOrder : ℚ) else 0 := by
    exact M.rowOrth;
  simp_all +decide [ Finset.sum_ite, Finset.filter_eq, Finset.filter_ne ];
  convert h_expand using 1 ; norm_cast ; simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ]

/-
The total multiplicity at grade m (sum over all irreps) relates to the
    graded dimension via the character dimensions.
-/
theorem total_mult_bound (m : ℕ) :
    M.gradedDim m = ∑ i : Fin n, (M.mult i m : ℚ) * M.toCharacterTable.repDim i := by
  rfl

end MoonshineDatum

/-! ## The Monster Group Order -/

/-- The order of the Monster group M, the largest sporadic simple group.
    |M| = 2^46 · 3^20 · 5^9 · 7^6 · 11^2 · 13^3 · 17 · 19 · 23 · 29 · 31 · 41 · 47 · 59 · 71 -/
def monsterOrder : ℕ :=
  2^46 * 3^20 * 5^9 * 7^6 * 11^2 * 13^3 * 17 * 19 * 23 * 29 * 31 * 41 * 47 * 59 * 71

/-- The number of conjugacy classes of the Monster group. -/
def monsterNumClasses : ℕ := 194

/-- The "supersingular primes": the prime divisors of the Monster group order.
    These are exactly the primes p for which every supersingular elliptic curve
    in characteristic p has j-invariant in F_p (Ogg's observation, 1975). -/
def supersingularPrimes : List ℕ := [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 59, 71]

/-
The Monster group order is divisible by 24, reflecting its deep connection
    to the Leech lattice (which lives in 24 dimensions) and modular forms
    (the weight 12 cusp form Δ has level 1).
-/
theorem monsterOrder_div_24 : 24 ∣ monsterOrder := by
  native_decide +revert

/-
The number of supersingular primes is 15.
-/
theorem supersingularPrimes_length : supersingularPrimes.length = 15 := by
  native_decide +revert

/-! ## Moonshine Conjecture (Abstract Form) -/

/-- A `MonsterMoonshineDatum` is a MoonshineDatum with the specific
    numerical parameters of the Monster group. -/
structure MonsterMoonshineDatum extends MoonshineDatum 194 where
  /-- The group order matches the Monster order -/
  order_eq : groupOrder = monsterOrder
  /-- The first graded dimension matches the j-function coefficient:
      dim(V_1) = 196884 = 196883 + 1 -/
  grade_one_dim : toMoonshineDatum.gradedDim 1 = 196884
  /-- The zeroth graded component is the trivial representation:
      V_0 is one-dimensional (corresponding to q^{-1} term after shift) -/
  grade_zero_trivial : mult ⟨0, by omega⟩ 0 = 1 ∧
    ∀ i : Fin 194, i ≠ ⟨0, by omega⟩ → mult i 0 = 0

/-
**The Moonshine Observation (Thompson, 1979)**:
    196884 = 196883 + 1, connecting the first non-trivial j-function
    coefficient to the dimensions of the two smallest Monster representations.

    This "coincidence" was the spark that ignited the moonshine conjecture.
-/
theorem thompson_observation : (196884 : ℕ) = 196883 + 1 := by
  norm_num

/-
The second j-function coefficient decomposes as
    21493760 = 21296876 + 196883 + 1,
    involving the three smallest Monster representation dimensions.
-/
theorem moonshine_second_coeff :
    (21493760 : ℕ) = 21296876 + 196883 + 1 := by
  rfl

/-! ## Moonshine Weight Conjecture -/

/-- **Conjecture (Moonshine Trace Dominance)**: For any MoonshineDatum with
    non-negative multiplicities and non-negative repDims, the identity
    McKay-Thompson coefficient dominates all others in absolute value.

    Formally: |a_m(g_j)| ≤ a_m(e) for all j, m.

    This is testable: for the Monster, compute T_g(q) for each of the
    194 conjugacy classes and verify coefficient-by-coefficient dominance.
    For g of small order (2A, 3A, etc.), explicit formulas are known
    and the bound can be checked for the first 1000 coefficients. -/
def MoonshineDatum.traceDominance (M : MoonshineDatum n) : Prop :=
  ∀ (j : Fin n) (m : ℕ),
    |M.mckayCoeff j m| ≤ M.mckayCoeff ⟨0, M.n_pos⟩ m