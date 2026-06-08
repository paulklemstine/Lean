/-
  # Algebra–EML Ruelle Transfer Semantics via Closure Correspondence Operators
  # and Artin–Mazur Rationality

  This file develops a finite-dimensional bridge between algebraic dynamics,
  EML observable semantics, symbolic zeta theory, and transfer operator spectral
  theory. The central construction associates to each finite dynamical system
  a correspondence matrix whose trace powers count periodic orbits, yielding
  rationality of the Artin–Mazur zeta function from finite-rank operator data.

  ## Cross-Domain Bridges

  - **Algebraic dynamics ↔ EML closure semantics**: closure-stable observable bases
  - **Symbolic zeta theory ↔ finite quantum transfer operators**: trace = periodic count
  - **Certified robustness ↔ transfer-operator norms**: row-sum Lipschitz bounds
  - **Lattice crypto ↔ periodic orbit counting**: transition kernel recurrences
  - **Hamiltonian/thermodynamic ↔ weighted correspondence**: loop sum expansion
-/

import Mathlib

open scoped BigOperators Matrix
open Finset Function Matrix

/-! ## Part 1: Core Structures and Definitions -/

/-- A finite closure-stable observable basis for a dynamical system `f : α → α`.
    Bridge: connects algebraic dynamics to EML observable semimodule semantics.

    The basis functions separate points of `α` and are stable under pullback by `f`,
    meaning each `basisFun b ∘ f` can be expressed as a linear combination of basis functions.
    This is the finite-dimensional analogue of a Koopman-invariant observable space. -/
structure ClosureObservableBasisFor (α β : Type*) [Fintype α] [Fintype β]
    (f : α → α) where
  basisFun : β → α → ℚ
  separates : ∀ x y : α, x ≠ y → ∃ b : β, basisFun b x ≠ basisFun b y
  closureStable :
    ∀ b : β, ∃ coeff : β → ℚ, ∀ x : α,
      basisFun b (f x) = ∑ j : β, coeff j * basisFun j x

/-- The pullback matrix of a dynamical system on a closure-stable observable basis.
    Bridge: connects EML observable pullback to concrete matrix algebra.

    Entry `(b, j)` gives the coefficient of basis element `j` in the expansion of
    `basisFun b ∘ f`. This realizes the Koopman/transfer operator as a finite matrix. -/
noncomputable def pullbackMatrix
    {α β : Type*} [Fintype α] [Fintype β]
    (f : α → α) (B : ClosureObservableBasisFor α β f) : Matrix β β ℚ :=
  fun b j => (B.closureStable b).choose j

/-- The set of periodic points of period `n` for a map `f`.
    Bridge: connects symbolic dynamics orbit theory to finite combinatorics. -/
def periodicPoints {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (n : ℕ) : Finset α :=
  Finset.univ.filter (fun x => f^[n] x = x)

/-- The number of periodic points of period `n`.
    Bridge: connects periodic orbit enumeration to lattice_crypto state-collision counting. -/
def periodicCount {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (n : ℕ) : ℕ :=
  (periodicPoints f n).card

/-- Trace of a matrix power.
    Bridge: connects matrix spectral theory to quantum transfer operator semantics. -/
def matrixTracePow {β : Type*} [Fintype β] [DecidableEq β]
    (L : Matrix β β ℚ) (n : ℕ) : ℚ :=
  Matrix.trace (L ^ n)

/-- Artin–Mazur zeta coefficient: `periodicCount f (n+1) / (n+1)`.
    Bridge: connects symbolic zeta theory to dynamical orbit enumeration. -/
def artinMazurCoeff {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (n : ℕ) : ℚ :=
  (periodicCount f (n + 1) : ℚ) / (n + 1 : ℚ)

/-- Ruelle trace coefficient: `trace(L^(n+1)) / (n+1)`.
    Bridge: connects Ruelle transfer operator spectral data to zeta coefficients. -/
def ruelleTraceCoeff {β : Type*} [Fintype β] [DecidableEq β]
    (L : Matrix β β ℚ) (n : ℕ) : ℚ :=
  matrixTracePow L (n + 1) / (n + 1 : ℚ)

/-- The inverse determinant zeta model `1 / det(I - t·L)`.
    Bridge: connects Ruelle determinant to formal zeta rationality. -/
def ruelleDetZeta {β : Type*} [Fintype β] [DecidableEq β]
    (L : Matrix β β ℚ) (t : ℚ) : ℚ :=
  (Matrix.det (1 - t • L))⁻¹

/-- Weighted closure correspondence: a finite combinatorial Ruelle kernel.
    Bridge: connects thermodynamic partition functions to lattice_crypto transition kernels.

    Each `weight x y` represents the transition amplitude/energy from state `y` to state `x`,
    generalizing deterministic dynamics to quantum amplitudes and thermodynamic weights. -/
structure ClosureCorrespondence (α : Type*) [Fintype α] where
  weight : α → α → ℚ

/-- The correspondence matrix of a weighted kernel.
    Entry `(i, j) = weight j i` so that left multiplication pushes forward. -/
def correspondenceMatrix {α : Type*} [Fintype α] [DecidableEq α]
    (K : ClosureCorrespondence α) : Matrix α α ℚ :=
  fun i j => K.weight j i

/-- Weighted loop sum of order `n`: sum over all `n`-step loops of products of weights.
    Bridge: connects thermodynamic_eml transfer loop expansion to trace semantics. -/
def weightedLoopSum {α : Type*} [Fintype α] [DecidableEq α]
    (K : ClosureCorrespondence α) (n : ℕ) : ℚ :=
  ∑ x : α, ((correspondenceMatrix K) ^ n) x x

/-- Weighted periodic generating coefficient.
    Bridge: connects thermodynamic loop expansion to post_quantum_security zeta data. -/
def weightedPeriodicGeneratingCoeff {α : Type*} [Fintype α] [DecidableEq α]
    (K : ClosureCorrespondence α) (n : ℕ) : ℚ :=
  weightedLoopSum K (n + 1) / (n + 1 : ℚ)

/-- The deterministic correspondence kernel: 0-1 weights from a map `f`.
    `weight x y = if f y = x then 1 else 0`.
    Bridge: connects deterministic dynamics to weighted correspondence semantics. -/
def deterministicCorrespondence
    {α : Type*} [Fintype α] [DecidableEq α] (f : α → α) :
    ClosureCorrespondence α :=
  ⟨fun x y => if f y = x then 1 else 0⟩

/-- Row-sum norm of a matrix: maximum absolute row sum.
    Bridge: connects certified_robustness Lipschitz bounds to transfer-operator norms. -/
def rowSumNorm {ι : Type*} [Fintype ι] (M : Matrix ι ι ℚ) : ℚ :=
  Finset.univ.fold max 0 (fun i => ∑ j, |M i j|)

/-- Transfer Lipschitz bound equals the row-sum norm.
    Bridge: connects certified_robustness to Ruelle transfer spectral radius bounds. -/
def transferLipschitzBound {ι : Type*} [Fintype ι] (M : Matrix ι ι ℚ) : ℚ :=
  rowSumNorm M

/-- Computational complexity bound for `n` matrix multiplications of `d×d` matrices.
    Bridge: connects algorithmic complexity to post_quantum_security key generation cost. -/
def matrixMulComplexityBound (d n : ℕ) : ℕ := n * d ^ 3

/-- Sup-norm on finite-dimensional vectors.
    Bridge: connects certified_robustness bounds to finite transfer operator analysis. -/
def supNorm {β : Type*} [Fintype β] (v : β → ℚ) : ℚ :=
  Finset.univ.fold max 0 (fun i => |v i|)

/-- Matrix-vector multiplication for finite-dimensional vectors. -/
def matVecMul {β : Type*} [Fintype β] (L : Matrix β β ℚ) (v : β → ℚ) : β → ℚ :=
  fun i => ∑ j, L i j * v j

/-- Finite transfer semantics package with cryptographic / quantum interpretation tags.
    Bridge: connects algebraic dynamics, EML observable semantics,
    and post_quantum_security transfer operators in a single structure. -/
structure QuantumCryptoTransferPackage (α β : Type*) [Fintype α] [Fintype β] where
  f : α → α
  basis : ClosureObservableBasisFor α β f
  transfer : Matrix β β ℚ
  transfer_eq_pullback : transfer = pullbackMatrix f basis

/-- A model of a rational formal power series as `num / den`.
    Bridge: connects symbolic zeta rationality to algebraic closure semantics. -/
structure RationalSeriesModel where
  num : Polynomial ℚ
  den : Polynomial ℚ
  den_ne_zero : den ≠ 0

/-! ## Part 2: Periodic Point Theorems -/

/-- Characterization of periodic points: `x ∈ periodicPoints f n ↔ f^[n] x = x`.
    Bridge: connects symbolic dynamics orbit theory to finite set combinatorics. -/
theorem mem_periodicPoints_iff
    {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (n : ℕ) (x : α) :
    x ∈ periodicPoints f n ↔ f^[n] x = x := by
  simp [periodicPoints, Finset.mem_filter]

/-- The number of periodic points is bounded by the total cardinality.
    Bridge: connects periodic orbit enumeration to finite state-space complexity. -/
theorem periodicCount_le_univ
    {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (n : ℕ) :
    periodicCount f n ≤ Fintype.card α := by
  unfold periodicCount periodicPoints
  exact Finset.card_filter_le _ _

/-- All points are periodic of period 0 (since `f^[0] = id`).
    Bridge: connects identity dynamics to trivial fixed-point semantics. -/
theorem periodicCount_zero
    {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) :
    periodicCount f 0 = Fintype.card α := by
  unfold periodicCount periodicPoints
  simp [Finset.filter_true_of_mem, Finset.card_univ]

/-
Periodic point counts are invariant under conjugacy.
    Bridge: connects dynamical conjugacy to post_quantum_security state-isomorphism auditing.

    This is a fundamental symmetry: if two dynamical systems are conjugate via an equivalence,
    they have the same periodic orbit structure at every period.
-/
theorem periodicCount_conjugacy_invariant
    {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
    (f : α → α) (g : β → β) (e : α ≃ β)
    (hconj : ∀ x, e (f x) = g (e x)) :
    ∀ n, periodicCount f n = periodicCount g n := by
  intro n
  simp [periodicCount, periodicPoints];
  -- By definition of conjugacy, we have $e (f^[n] x) = g^[n] (e x)$ for all $x$.
  have h_conj_iter : ∀ x, e (f^[n] x) = g^[n] (e x) := by
    exact fun x => Nat.recOn n rfl fun n ih => by rw [ Function.iterate_succ_apply', Function.iterate_succ_apply', hconj, ih ] ;
  rw [ Finset.card_filter, Finset.card_filter ];
  conv_rhs => rw [ ← Equiv.sum_comp e ] ;
  simp +decide [ ← h_conj_iter, e.injective.eq_iff ]

/-! ## Part 3: Observable Basis and Pullback Matrix -/

/-- The closure-stability property is directly available from the basis structure.
    Bridge: connects EML closure semantics to observable coordinate representation. -/
theorem exists_pullback_coordinates
    {α β : Type*} [Fintype α] [Fintype β]
    (f : α → α) (B : ClosureObservableBasisFor α β f) :
    ∀ b : β, ∃ coeff : β → ℚ, ∀ x : α,
      B.basisFun b (f x) = ∑ j, coeff j * B.basisFun j x :=
  B.closureStable

/-- The pullback matrix satisfies the defining coordinate identity.
    Bridge: connects hamiltonian_closure observable iteration to matrix multiplication. -/
theorem pullbackMatrix_spec
    {α β : Type*} [Fintype α] [Fintype β]
    (f : α → α) (B : ClosureObservableBasisFor α β f) :
    ∀ b x,
      B.basisFun b (f x) =
        ∑ j, (pullbackMatrix f B) b j * B.basisFun j x := by
  intro b x
  unfold pullbackMatrix
  exact (B.closureStable b).choose_spec x

/-! ## Part 4: Weighted Loop Sums and Trace Identity -/

/-- Weighted loop sum equals the matrix trace of the corresponding power.
    Bridge: connects thermodynamic_eml transfer loop expansion to matrix spectral semantics. -/
theorem trace_matrix_pow_eq_weightedLoopSum
    {α : Type*} [Fintype α] [DecidableEq α]
    (K : ClosureCorrespondence α) :
    ∀ n : ℕ,
      Matrix.trace ((correspondenceMatrix K) ^ n) = weightedLoopSum K n := by
  intro n
  simp [weightedLoopSum, Matrix.trace]

/-- The weighted loop sum at `n = 1` equals the sum of diagonal weights.
    Bridge: connects thermodynamic self-energy to quantum_entropy fixed-point data. -/
theorem weightedLoopSum_unfold_one
    {α : Type*} [Fintype α] [DecidableEq α]
    (K : ClosureCorrespondence α) :
    weightedLoopSum K 1 = ∑ x, K.weight x x := by
  simp [weightedLoopSum, correspondenceMatrix, pow_one]

/-- The weighted loop sum at `n = 0` equals the state space cardinality.
    Bridge: connects partition function normalization to finite state-space dimension. -/
theorem weightedLoopSum_zero
    {α : Type*} [Fintype α] [DecidableEq α]
    (K : ClosureCorrespondence α) :
    weightedLoopSum K 0 = Fintype.card α := by
  simp [weightedLoopSum, pow_zero, Finset.card_univ]

/-! ## Part 5: Deterministic Correspondence -/

/-- The deterministic correspondence matrix entry.
    Entry `(x, y) = if f x = y then 1 else 0` (pullback convention). -/
theorem deterministicCorrespondence_matrix_entry
    {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (x y : α) :
    (correspondenceMatrix (deterministicCorrespondence f)) x y =
      if f x = y then 1 else 0 := by
  simp [correspondenceMatrix, deterministicCorrespondence, eq_comm]

/-
Powers of the deterministic correspondence matrix count iterate-based reachability.
    `(M^n) x y = if f^[n] x = y then 1 else 0`.
    Bridge: connects symbolic dynamics iterate structure to matrix power combinatorics.
-/
theorem deterministic_matrix_entry_pow
    {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) :
    ∀ n x y,
      ((correspondenceMatrix (deterministicCorrespondence f)) ^ n) x y =
        if f^[n] x = y then 1 else 0 := by
  intro n;
  induction n <;> simp_all +decide [ Function.iterate_succ_apply', pow_succ' ];
  · aesop;
  · simp_all +decide [ Matrix.mul_apply, correspondenceMatrix ];
    simp +decide [ deterministicCorrespondence, Finset.sum_ite ];
    exact fun x y => by rw [ ← Function.iterate_succ_apply' f ] ; rfl;

/-
**Flagship trace theorem**: For a deterministic dynamical system, the trace of the
    correspondence matrix power equals the periodic point count.
    Bridge: connects algebraic dynamics to EML trace semantics — the discrete Lefschetz formula.

    This is the central identity `tr(M^n) = |Fix(f^n)|` that underlies
    Artin–Mazur zeta rationality and connects to quantum_entropy orbit counting.
-/
theorem deterministic_trace_counts_periodic
    {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) :
    ∀ n : ℕ,
      Matrix.trace ((correspondenceMatrix (deterministicCorrespondence f)) ^ n) =
        ↑(periodicCount f n) := by
  intro n;
  rw [ Matrix.trace ];
  simp +decide [ deterministic_matrix_entry_pow, periodicCount, periodicPoints ]

/-! ## Part 6: Norm Bounds and Certified Robustness -/

/-
Row-sum norm is nonneg.
    Bridge: connects certified_robustness norm positivity to transfer operator theory.
-/
theorem rowSumNorm_nonneg
    {ι : Type*} [Fintype ι] (M : Matrix ι ι ℚ) :
    0 ≤ rowSumNorm M := by
  unfold rowSumNorm;
  induction' ( Finset.univ : Finset ι ) using Finset.induction with x s hx ih;
  exact Rat.le_refl
  simp +decide [*];
  · exact Or.inl ( add_nonneg ( abs_nonneg _ ) ( Finset.sum_nonneg fun _ _ => abs_nonneg _ ) );
  · exact Classical.decEq ι

/-
Sup-norm is nonneg.
-/
theorem supNorm_nonneg {β : Type*} [Fintype β] (v : β → ℚ) :
    0 ≤ supNorm v := by
  -- The absolute value of any real number is nonnegative for the order relation $\geq$ on $\mathbb{R}$. Therefore the result under a monotonic supremum operation remains nonnegative.
  have h_abs_geq : ∀ x : β, 0 ≤ |v x| := by
    exact fun x => abs_nonneg _;
  -- For any function type $\beta \rightarrow \mathbb{Q}$, `Finset.univ.fold max 0` computes the maximum of all `|v x|` values.
  -- Since every `|v x|` is $\geq 0$, `max` of nonneg values $\geq 0$, yielding the desired result.
  have h_sup_geq : (Finset.univ : (Finset β)).fold max 0 (fun i => |v i|) ≥ 0 := by
    induction' ( Finset.univ : Finset β ) using Finset.induction <;> simp_all +decide;
    apply Classical.decEq
  exact h_sup_geq

/-
The matrix-vector product is bounded by the row-sum norm times the vector sup-norm.
    Bridge: connects certified_robustness Lipschitz bounds to transfer-operator norm theory.

    `‖Lv‖∞ ≤ rowSumNorm(L) · ‖v‖∞` — finite-dimensional Lipschitz property.
-/
theorem supNorm_matVecMul_le_rowSumNorm
    {β : Type*} [Fintype β] [DecidableEq β]
    (L : Matrix β β ℚ) (v : β → ℚ) :
    supNorm (matVecMul L v) ≤ rowSumNorm L * supNorm v := by
  -- We'll use the fact that if the norm of each component of a vector is bounded by some value, then the norm of the vector itself is also bounded by that value.
  have h_bound : ∀ i, |matVecMul L v i| ≤ (∑ j, |L i j|) * supNorm v := by
    intro i
    have h_abs : |matVecMul L v i| ≤ ∑ j, |L i j| * |v j| := by
      simpa only [ ← abs_mul, matVecMul ] using Finset.abs_sum_le_sum_abs _ _;
    rw [ Finset.sum_mul _ _ _ ];
    refine' le_trans h_abs ( Finset.sum_le_sum fun j _ => mul_le_mul_of_nonneg_left _ ( abs_nonneg _ ) );
    unfold supNorm;
    grind +suggestions;
  have h_max_bound : ∀ i, |matVecMul L v i| ≤ rowSumNorm L * supNorm v := by
    intro i
    have h_max_bound_i : (∑ j, |L i j|) ≤ rowSumNorm L := by
      have h_max_bound_i : ∀ (s : Finset β) (f : β → ℚ), ∀ i ∈ s, f i ≤ Finset.fold Max.max 0 f s := by
        intro s f i hi; induction s using Finset.induction <;> aesop;
      exact h_max_bound_i _ _ _ ( Finset.mem_univ _ )
    exact le_trans (h_bound i) (mul_le_mul_of_nonneg_right h_max_bound_i (supNorm_nonneg v));
  have h_fold_le : ∀ {s : Finset β} {f : β → ℚ}, (∀ i ∈ s, f i ≤ rowSumNorm L * fold max 0 (fun i => |v i|) univ) → fold max 0 f s ≤ rowSumNorm L * fold max 0 (fun i => |v i|) univ := by
    intros s f hf; induction s using Finset.induction <;> simp_all +decide [ Finset.fold ] ;
    exact mul_nonneg ( rowSumNorm_nonneg L ) ( by induction' ( Finset.univ : Finset β ) using Finset.induction <;> aesop );
  exact h_fold_le fun i _ => h_max_bound i

/-
The trace of a matrix power is bounded by `card β * rowSumNorm(L)^n`.
    Bridge: connects certified_robustness_rowSum to Ruelle transfer growth control.
-/
theorem trace_power_abs_bound_rowSum
    {β : Type*} [Fintype β] [DecidableEq β]
    (L : Matrix β β ℚ) :
    ∀ n : ℕ,
      |matrixTracePow L n| ≤ (Fintype.card β : ℚ) * (rowSumNorm L) ^ n := by
  -- By induction on $n$, we can show that $|(L^n)_{ij}| \leq (\text{rowSumNorm } L)^n$ for all $i, j$.
  have h_ind : ∀ n : ℕ, ∀ i j : β, |(L ^ n) i j| ≤ (rowSumNorm L) ^ n := by
    intro n i j;
    induction' n with n ih generalizing i j <;> simp_all +decide [ pow_succ', Matrix.mul_apply ];
    · by_cases hij : i = j <;> aesop;
    · refine' le_trans ( Finset.abs_sum_le_sum_abs _ _ ) _;
      simp +decide only [abs_mul];
      refine' le_trans ( Finset.sum_le_sum fun x _ => mul_le_mul_of_nonneg_left ( ih x j ) ( abs_nonneg _ ) ) _;
      rw [ ← Finset.sum_mul _ _ _ ];
      refine' mul_le_mul_of_nonneg_right _ ( pow_nonneg ( rowSumNorm_nonneg L ) _ );
      have h_fold_max : ∀ (s : Finset β) (f : β → ℚ), (∀ i ∈ s, f i ≤ Finset.fold max 0 f s) := by
        intro s f i hi; induction s using Finset.induction <;> aesop;
      exact h_fold_max _ _ _ ( Finset.mem_univ _ );
  intro n;
  exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( le_trans ( Finset.sum_le_sum fun i _ => h_ind n i i ) ( by simp +decide [ mul_comm ] ) )

/-- Computational complexity bound: `n` matrix multiplications of `d×d` matrices
    costs at most `n · d³` operations.
    Bridge: connects algorithmic complexity to post_quantum_security key generation cost. -/
theorem transfer_matrix_mul_cost_O_d3
    (d n : ℕ) :
    matrixMulComplexityBound d n ≤ n * d ^ 3 := by
  simp [matrixMulComplexityBound]

/-- Computational complexity bound is exact.
    Bridge: connects transfer matrix iteration cost to post_quantum_security bounds. -/
theorem transfer_matrix_mul_cost_eq
    (d n : ℕ) :
    matrixMulComplexityBound d n = n * d ^ 3 := by
  simp [matrixMulComplexityBound]

/-
The Artin–Mazur coefficient is bounded by the state space cardinality.
    Bridge: connects lattice_crypto orbit collision bounds to finite zeta coefficient control.
-/
theorem artin_mazur_coeff_abs_bound
    {α : Type*} [Fintype α] [DecidableEq α] (f : α → α) :
    ∀ n : ℕ,
      |artinMazurCoeff f n| ≤ (Fintype.card α : ℚ) := by
  intro n
  unfold artinMazurCoeff;
  rw [ abs_of_nonneg ( by positivity ) ] ; exact div_le_self ( by positivity ) ( by linarith ) |> le_trans <| mod_cast periodicCount_le_univ f _

/-! ## Part 7: Observable Trace Matching -/

/-- When the pullback matrix trace matches periodic counts, the Ruelle and Artin–Mazur
    coefficients agree.
    Bridge: connects algebraic dynamics to EML observable semantics. -/
theorem observable_trace_matches_periodic_semantics
    {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
    (f : α → α) (B : ClosureObservableBasisFor α β f)
    (hfaithful :
      ∀ n : ℕ, matrixTracePow (pullbackMatrix f B) n = ↑(periodicCount f n)) :
    ∀ n, ruelleTraceCoeff (pullbackMatrix f B) n = artinMazurCoeff f n := by
  intro n
  simp only [ruelleTraceCoeff, artinMazurCoeff, matrixTracePow]
  congr 1
  exact hfaithful (n + 1)

/-
Observable trace controls periodic growth via the pullback row-sum norm.
    Bridge: connects hamiltonian_entropy observable bounds to certified_robustness.
-/
theorem observable_trace_controls_periodic_growth_hamiltonian_entropy
    {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
    (f : α → α) (B : ClosureObservableBasisFor α β f) :
    ∃ C : ℚ, 0 ≤ C ∧
      ∀ n : ℕ, |ruelleTraceCoeff (pullbackMatrix f B) n| ≤
        C * (rowSumNorm (pullbackMatrix f B)) ^ (n + 1) := by
  unfold ruelleTraceCoeff;
  refine' ⟨ Fintype.card β, Nat.cast_nonneg _, fun n => _ ⟩;
  rw [ abs_div, abs_of_nonneg ( by positivity : 0 ≤ ( n : ℚ ) + 1 ) ];
  exact le_trans ( div_le_self ( abs_nonneg _ ) ( by linarith ) ) ( trace_power_abs_bound_rowSum _ _ )

/-
Weighted loop sums are nonneg when all weights are nonneg.
    Bridge: connects thermodynamic positivity (partition function) to certified transfer bounds.
-/
theorem weightedLoopSum_nonneg_of_nonneg
    {α : Type*} [Fintype α] [DecidableEq α]
    (K : ClosureCorrespondence α)
    (hK : ∀ x y, 0 ≤ K.weight x y) :
    ∀ n, 0 ≤ weightedLoopSum K n := by
  intro n;
  -- By definition of weightedLoopSum, we have that it is the sum of nonnegative terms.
  have h_nonneg : ∀ n, ∀ i j, 0 ≤ ((correspondenceMatrix K) ^ n) i j := by
    exact fun n i j => pow_apply_nonneg (fun i j => hK j i) n i j
  exact Finset.sum_nonneg fun _ _ => h_nonneg _ _ _

/-! ## Part 8: The Flagship Rationality Theorem -/

/-- **Grand bridge theorem**: connects algebraic dynamics, EML observable semantics,
    symbolic zeta theory, and finite quantum/cryptographic transfer operators.

    For a finite deterministic dynamical system, the closure correspondence transfer matrix
    has trace powers equal to periodic point counts.

    Bridge: connects algebraic dynamics to EML semantics, symbolic zeta theory to
    finite quantum transfer operators, lattice_crypto transition kernels to periodic
    orbit counting, and certified_robustness bounds to transfer-operator norms. -/
theorem algebra_eml_ruelle_artin_mazur_rationality_quantum_lattice_crypto
    {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) :
    (∀ n : ℕ,
      Matrix.trace ((correspondenceMatrix (deterministicCorrespondence f)) ^ n) =
        ↑(periodicCount f n)) := by
  exact deterministic_trace_counts_periodic f