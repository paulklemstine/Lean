--- a/Physics/Basic.lean
+++ b/Physics/Basic.lean
@@ -1,12956 +1,3640 @@
---- a/EML/Basic.lean
-+++ b/EML/Basic.lean
-@@ -1,50 +1,312 @@
- --- a/Bridges/Basic.lean
- +++ b/Bridges/Basic.lean
--@@ -1,17594 +1,5794 @@
-+@@ -1,6079 +1,5794 @@
- ---- a/Bridges/Basic.lean
- -+++ b/Bridges/Basic.lean
---@@ -1,11860 +1,5794 @@
------- a/Bridges/Basic.lean
----+++ b/Bridges/Basic.lean
----@@ -1,6079 +1,5794 @@
-------- a/Bridges/Basic.lean
-----+++ b/Bridges/Basic.lean
-----@@ -1,283 +1,5794 @@
---+--- a/Logic/Basic.lean
-+-@@ -1,283 +1,5794 @@
-+--/-
-+--Copyright (c) 2025. All rights reserved.
-+--Released under Apache 2.0 license as described in the file LICENSE.
-+--
-+--# Thermodynamic Elimination via Prime-Spectral Legendre Duality
-+--
-+--This file establishes that elimination of an adjoined variable in a proof semiring
-+--is governed by a prime-spectral variational principle: membership in the elimination
-+--ideal equals domination against all compatible primes.
-+--
-+--## Main results
-+--
-+--* `mem_radicalElim_iff_spectral` — **the main duality theorem**:
-+--  radical elimination ↔ spectral domination against all compatible primes
-+--* `radicalElim_eq_spectralElim` — set equality form of the duality
-+--* `not_mem_radicalElim_iff_exists_prime_witness` — non-elimination
-+--  yields a separating prime witness
-+--* `radicalElim_eq_variationalKernel` — the full duality chain
-+--* `mem_radicalElim_iff_sup_gap_zero` — variational principle: elimination iff
-+--  all free-energy gaps vanish
-+--
-+--## Mathematical significance
-+--
-+--Existential projection in a proof-semiring world is governed by a variational
-+--principle on the prime spectrum: elimination = intersection over prime-compatible
-+--contractions. This bridges algebraic geometry, proof theory, and thermodynamics.
-+---/
-+--
-+--import Mathlib
-+--
-+--open Set Polynomial Ideal Classical
-+--
-+--noncomputable section
-+--
-+--universe u
-+--
-+--/-! ## Closure Operator Framework -/
-+--
-+--/-- A closure operator on a commutative semiring, modeling derivability. -/
-+--structure ClosureTheory (S : Type u) [CommSemiring S] where
-+--  cl : Set S → Set S
-+--  cl_extensive : ∀ A : Set S, A ⊆ cl A
-+--  cl_mono : ∀ {A B : Set S}, A ⊆ B → cl A ⊆ cl B
-+--  cl_idem : ∀ A : Set S, cl (cl A) = cl A
-+--
-+--/-- A **coherent closure** commutes with directed unions. -/
-+--structure CoherentClosure (S : Type u) [CommSemiring S] extends ClosureTheory S where
-+--  coherent : ∀ (A : Set S) (a : S), a ∈ cl A →
-+--    ∃ F : Finset S, (F : Set S) ⊆ A ∧ a ∈ cl (F : Set S)
-+--
-+--/-! ## Polynomial Extension and Elimination Ideals -/
-+--
-+--variable {R : Type u} [CommRing R]
-+--
-+--/-- The **elimination ideal**: contraction of `I ⊆ R[X]` to `R` via `C`. -/
-+--def eliminationIdeal (I : Ideal (Polynomial R)) : Ideal R :=
-+--  I.comap Polynomial.C
-+--
-+--/-- The **radical elimination ideal**: contraction of `√I` to `R`. -/
-+--def radicalEliminationIdeal (I : Ideal (Polynomial R)) : Ideal R :=
-+--  I.radical.comap Polynomial.C
-+--
-+--theorem mem_eliminationIdeal_iff (I : Ideal (Polynomial R)) (a : R) :
-+--    a ∈ eliminationIdeal I ↔ Polynomial.C a ∈ I :=
-+--  Ideal.mem_comap
-+--
-+--theorem mem_radicalEliminationIdeal_iff (I : Ideal (Polynomial R)) (a : R) :
-+--    a ∈ radicalEliminationIdeal I ↔ Polynomial.C a ∈ I.radical :=
-+--  Ideal.mem_comap
-+--
-+--theorem mem_radicalEliminationIdeal_iff' (I : Ideal (Polynomial R)) (a : R) :
-+--    a ∈ radicalEliminationIdeal I ↔ ∃ n : ℕ, Polynomial.C (a ^ n) ∈ I := by
-+--  rw [mem_radicalEliminationIdeal_iff, Ideal.mem_radical_iff]
-+--  simp [map_pow]
-+--
-+--/-! ## Prime Compatibility and Spectral Elimination -/
-+--
-+--/-- A prime `P` of `R[X]` is **compatible** with ideal `I` if `I ≤ P`. -/
-+--def primeCompatible (I : Ideal (Polynomial R)) (P : PrimeSpectrum (Polynomial R)) : Prop :=
-+--  I ≤ P.asIdeal
-+--
-+--/-- The **spectral elimination set**: `{a ∈ R | ∀ P prime, I ≤ P → C(a) ∈ P}`. -/
-+--def spectralElimination (I : Ideal (Polynomial R)) : Set R :=
-+--  {a : R | ∀ P : PrimeSpectrum (Polynomial R), primeCompatible I P → Polynomial.C a ∈ P.asIdeal}
-+--
-+--theorem mem_spectralElimination_iff (I : Ideal (Polynomial R)) (a : R) :
-+--    a ∈ spectralElimination I ↔
-+--      ∀ P : PrimeSpectrum (Polynomial R), I ≤ P.asIdeal → Polynomial.C a ∈ P.asIdeal :=
-+--  Iff.rfl
-+--
-+--/-! ## The Main Duality Theorem -/
-+--
-+--/-- **Key lemma**: radical membership ↔ membership in all containing primes.
-+--This wraps `Ideal.radical_eq_sInf` into the `PrimeSpectrum` formulation. -/
-+--theorem mem_radical_iff_mem_all_primeSpectrum
-+--    (I : Ideal (Polynomial R)) (f : Polynomial R) :
-+--    f ∈ I.radical ↔
-+--      ∀ P : PrimeSpectrum (Polynomial R), I ≤ P.asIdeal → f ∈ P.asIdeal := by
-+--  constructor
-+--  · intro hf P hIP
-+--    rw [Ideal.radical_eq_sInf, Ideal.mem_sInf] at hf
-+--    exact hf ⟨hIP, P.isPrime⟩
-+--  · intro hf
-+--    rw [Ideal.radical_eq_sInf, Ideal.mem_sInf]
-+--    intro J ⟨hIJ, hJprime⟩
-+--    exact hf ⟨J, hJprime⟩ hIJ
-+--
-+--/-- **Main duality theorem**: radical elimination ↔ spectral elimination. -/
-+--theorem mem_radicalElim_iff_spectral (I : Ideal (Polynomial R)) (a : R) :
-+--    a ∈ radicalEliminationIdeal I ↔ a ∈ spectralElimination I := by
-+--  simp only [mem_radicalEliminationIdeal_iff, mem_spectralElimination_iff]
-+--  exact mem_radical_iff_mem_all_primeSpectrum I (Polynomial.C a)
-+--
-+--/-- **Set equality form of the main theorem.** -/
-+--theorem radicalElim_eq_spectralElim (I : Ideal (Polynomial R)) :
-+--    (radicalEliminationIdeal I : Set R) = spectralElimination I :=
-+--  Set.ext (mem_radicalElim_iff_spectral I)
-+--
-+--/-- **Soundness**: radical elimination ⊆ spectral elimination. -/
-+--theorem elim_subset_spectral (I : Ideal (Polynomial R)) :
-+--    (radicalEliminationIdeal I : Set R) ⊆ spectralElimination I :=
-+--  (radicalElim_eq_spectralElim I).subset
-+--
-+--/-- **Completeness**: spectral elimination ⊆ radical elimination. -/
-+--theorem spectral_subset_elim (I : Ideal (Polynomial R)) :
-+--    spectralElimination I ⊆ (radicalEliminationIdeal I : Set R) :=
-+--  (radicalElim_eq_spectralElim I).superset
-+--
-+--/-! ## Spectral Intersection Formulations -/
-+--
-+--/-- Spectral elimination as `⋂₀` over prime contraction sets. -/
-+--theorem spectralElimination_eq_sInter (I : Ideal (Polynomial R)) :
-+--    spectralElimination I =
-+--      ⋂₀ {T : Set R | ∃ P : PrimeSpectrum (Polynomial R),
-+--        primeCompatible I P ∧ T = {a : R | Polynomial.C a ∈ P.asIdeal}} := by
-+--  ext a
-+--  simp only [mem_sInter, mem_setOf_eq, spectralElimination, primeCompatible]
-+--  exact ⟨fun h T ⟨P, hP, hT⟩ => hT ▸ h P hP,
-+--         fun h P hP => h _ ⟨P, hP, rfl⟩⟩
-+--
-+--/-! ## Prime Witness Extraction -/
-+--
-+--/-- If `a ∉ radicalElim(I)`, there exists a separating prime witness. -/
-+--theorem exists_prime_witness_of_not_mem_radicalElim
-+--    (I : Ideal (Polynomial R)) (a : R)
-+--    (ha : a ∉ radicalEliminationIdeal I) :
-+--    ∃ P : PrimeSpectrum (Polynomial R),
-+--      primeCompatible I P ∧ Polynomial.C a ∉ P.asIdeal := by
-+--  rw [mem_radicalElim_iff_spectral] at ha
-+--  simp only [spectralElimination, primeCompatible, mem_setOf_eq] at ha
-+--  push_neg at ha
-+--  exact ha
-+--
-+--/-- **Contrapositive characterization**: non-elimination ↔ ∃ separating prime. -/
-+--theorem not_mem_radicalElim_iff_exists_prime_witness
-+--    (I : Ideal (Polynomial R)) (a : R) :
-+--    a ∉ radicalEliminationIdeal I ↔
-+--      ∃ P : PrimeSpectrum (Polynomial R),
-+--        primeCompatible I P ∧ Polynomial.C a ∉ P.asIdeal := by
-+--  constructor
-+--  · exact exists_prime_witness_of_not_mem_radicalElim I a
-+--  · intro ⟨P, hP, hnotmem⟩ hmem
-+--    rw [mem_radicalElim_iff_spectral] at hmem
-+--    exact hnotmem (hmem P hP)
-+--
-+--/-! ## Thermodynamic Functionals -/
-+--
-+--/-- **Prime pressure indicator**: `1` if `a ∉ P` (positive pressure), `0` if `a ∈ P`. -/
-+--def primePressureIndicator (P : PrimeSpectrum (Polynomial R)) (a : R) : ℝ :=
-+--  if Polynomial.C a ∈ P.asIdeal then (0 : ℝ) else (1 : ℝ)
-+--
-+--/-- `a ∈ spectralElim(I)` iff pressure vanishes at all compatible primes. -/
-+--theorem mem_spectralElimination_iff_pressure_zero
-+--    (I : Ideal (Polynomial R)) (a : R) :
-+--    a ∈ spectralElimination I ↔
-+--      ∀ P : PrimeSpectrum (Polynomial R),
-+--        primeCompatible I P → primePressureIndicator P a = 0 := by
-+--  simp only [spectralElimination, primeCompatible, mem_setOf_eq, primePressureIndicator]
-+--  constructor
-+--  · intro h P hP; simp [h P hP]
-+--  · intro h P hP
-+--    specialize h P hP
-+--    split_ifs at h with hmem
-+--    · exact hmem
-+--    · norm_num at h
-+--
-+--/-- Non-elimination implies a positive-pressure prime witness. -/
-+--theorem exists_positive_pressure_witness
-+--    (I : Ideal (Polynomial R)) (a : R)
-+--    (ha : a ∉ radicalEliminationIdeal I) :
-+--    ∃ P : PrimeSpectrum (Polynomial R),
-+--      primeCompatible I P ∧ primePressureIndicator P a = 1 := by
-+--  obtain ⟨P, hP, hnotmem⟩ := exists_prime_witness_of_not_mem_radicalElim I a ha
-+--  exact ⟨P, hP, by simp [primePressureIndicator, hnotmem]⟩
-+--
-+--/-- **Free-energy gap** at a prime: same as the pressure indicator. -/
-+--def freeEnergyGap (P : PrimeSpectrum (Polynomial R)) (a : R) : ℝ :=
-+--  primePressureIndicator P a
-+--
-+--/-- **The variational kernel set**: elements with zero pressure everywhere. -/
-+--def primeVariationalKernelSet (I : Ideal (Polynomial R)) : Set R :=
-+--  {a : R | ∀ P : PrimeSpectrum (Polynomial R),
-+--    primeCompatible I P → primePressureIndicator P a = 0}
-+--
-+--/-- Variational kernel = spectral elimination. -/
-+--theorem primeVariationalKernelSet_eq_spectralElimination
-+--    (I : Ideal (Polynomial R)) :
-+--    primeVariationalKernelSet I = spectralElimination I := by
-+--  ext a
-+--  exact (mem_spectralElimination_iff_pressure_zero I a).symm
-+--
-+--/-- **Full duality chain**: radical elim = spectral elim = variational kernel. -/
-+--theorem radicalElim_eq_variationalKernel (I : Ideal (Polynomial R)) :
-+--    (radicalEliminationIdeal I : Set R) = primeVariationalKernelSet I := by
-+--  rw [primeVariationalKernelSet_eq_spectralElimination, ← radicalElim_eq_spectralElim]
-+--
-+--/-- **Variational principle**: elimination iff all free-energy gaps vanish. -/
-+--theorem mem_radicalElim_iff_sup_gap_zero (I : Ideal (Polynomial R)) (a : R) :
-+--    a ∈ radicalEliminationIdeal I ↔
-+--      ∀ P : PrimeSpectrum (Polynomial R),
-+--        primeCompatible I P → freeEnergyGap P a = 0 := by
-+--  rw [mem_radicalElim_iff_spectral]
-+--  exact mem_spectralElimination_iff_pressure_zero I a
-+--
-+--/-! ## Monotonicity -/
-+--
-+--theorem eliminationIdeal_mono {I J : Ideal (Polynomial R)} (h : I ≤ J) :
-+--    eliminationIdeal I ≤ eliminationIdeal J :=
-+--  Ideal.comap_mono h
-+--
-+--theorem radicalEliminationIdeal_mono {I J : Ideal (Polynomial R)} (h : I ≤ J) :
-+--    radicalEliminationIdeal I ≤ radicalEliminationIdeal J :=
-+--  Ideal.comap_mono (Ideal.radical_mono h)
-+--
-+--/-- Spectral elimination is monotone: `I ≤ J → spectralElim(I) ⊆ spectralElim(J)`.
-+--Larger ideals eliminate into larger sets, because they impose constraints on
-+--fewer primes. -/
-+--theorem spectralElimination_mono {I J : Ideal (Polynomial R)} (h : I ≤ J) :
-+--    spectralElimination I ⊆ spectralElimination J := by
-+--  intro a ha P hP
-+--  exact ha P (le_trans h hP)
-+--
-+--/-! ## Contraction Map -/
-+--
-+--/-- The contraction map `Spec(R[X]) → Spec(R)`. -/
-+--def contractionMap : PrimeSpectrum (Polynomial R) → PrimeSpectrum R :=
-+--  fun P => ⟨Ideal.comap Polynomial.C P.asIdeal, Ideal.IsPrime.comap Polynomial.C⟩
-+--
-+--theorem mem_contractionMap_iff (P : PrimeSpectrum (Polynomial R)) (a : R) :
-+--    a ∈ (contractionMap P).asIdeal ↔ Polynomial.C a ∈ P.asIdeal :=
-+--  Ideal.mem_comap
-+--
-+--/-! ## Pressure Set Equality -/
-+--
-+--/-- Radical elimination = set of elements with non-positive pressure everywhere. -/
-+--theorem radicalElim_eq_pressure_set (I : Ideal (Polynomial R)) :
-+--    (radicalEliminationIdeal I : Set R) =
-+--      {a | ∀ P : PrimeSpectrum (Polynomial R), primeCompatible I P →
-+--        primePressureIndicator P a ≤ 0} := by
-+--  ext a
-+--  simp only [SetLike.mem_coe, mem_setOf_eq]
-+--  rw [mem_radicalElim_iff_spectral]
-+--  simp only [spectralElimination, primeCompatible, mem_setOf_eq, primePressureIndicator]
-+--  constructor
-+--  · intro h P hP; simp [h P hP]
-+--  · intro h P hP
-+--    specialize h P hP
-+--    split_ifs at h with hmem
-+--    · exact hmem
-+--    · linarith
-+--
-+--/-! ## Axiom verification -/
-+--
-+--#print axioms mem_eliminationIdeal_iff
-+--#print axioms mem_radical_iff_mem_all_primeSpectrum
-+--#print axioms mem_radicalElim_iff_spectral
-+--#print axioms radicalElim_eq_spectralElim
-+--#print axioms not_mem_radicalElim_iff_exists_prime_witness
-+--#print axioms radicalElim_eq_variationalKernel
-+--#print axioms spectralElimination_eq_sInter
-+--#print axioms mem_radicalElim_iff_sup_gap_zero
-+--#print axioms exists_positive_pressure_witness
-+--#print axioms radicalElim_eq_pressure_set+--- a/Logic/Basic.lean
- -++++ b/Logic/Basic.lean
- -+@@ -1,2162 +1,3640 @@
- -+ --- a/MachineLearning/Basic.lean
- -+ +++ b/MachineLearning/Basic.lean
- -+-@@ -1,219 +1,1941 @@
--- --/-
------Copyright (c) 2025. All rights reserved.
-+-+--/-
- -+--Copyright (c) 2025 Harmonic. All rights reserved.
--- --Released under Apache 2.0 license as described in the file LICENSE.
-+-+--Released under Apache 2.0 license as described in the file LICENSE.
- -+---/
- -+--import Mathlib
--- --
------# Thermodynamic Elimination via Prime-Spectral Legendre Duality
-+-+--
- -+--/-!
- -+--# Gradient Descent Convergence Theory
--- --
------This file establishes that elimination of an adjoined variable in a proof semiring
------is governed by a prime-spectral variational principle: membership in the elimination
------ideal equals domination against all compatible primes.
-+-+--
- -+--This file formalizes the convergence theory of gradient descent for strongly convex
- -+--quadratic functions, establishing the fundamental result that underpins optimization
- -+--in machine learning.
--- --
------## Main results
-+-+--
- -+--## Main Results
--- --
------* `mem_radicalElim_iff_spectral` — **the main duality theorem**:
------  radical elimination ↔ spectral domination against all compatible primes
------* `radicalElim_eq_spectralElim` — set equality form of the duality
------* `not_mem_radicalElim_iff_exists_prime_witness` — non-elimination
------  yields a separating prime witness
------* `radicalElim_eq_variationalKernel` — the full duality chain
------* `mem_radicalElim_iff_sup_gap_zero` — variational principle: elimination iff
------  all free-energy gaps vanish
-+-+--
- -+--* `gd_error_eq` — The error of gradient descent on a quadratic `f(x) = (a/2)x²`
- -+--  with step size `η` satisfies `e_n = (1 - ηa)^n · e_0`
- -+--* `gd_contraction_factor_lt_one` — The contraction factor `|1 - ηa| < 1` when
-@@ -55,110 +317,69 @@
- -+--* `gd_optimal_step` — The optimal step size is `η = 1/a`, giving convergence in one step
- -+--* `gd_condition_number_bound` — For 2D quadratics with eigenvalues `μ ≤ L`,
- -+--  the optimal convergence rate is `(κ-1)/(κ+1)` where `κ = L/μ`
--- --
------## Mathematical significance
-+-+--
- -+--## References
--- --
------Existential projection in a proof-semiring world is governed by a variational
------principle on the prime spectrum: elimination = intersection over prime-compatible
------contractions. This bridges algebraic geometry, proof theory, and thermodynamics.
-+-+--
- -+--* Nesterov, Y. (2004). *Introductory Lectures on Convex Optimization*
- -+--* Boyd, S. & Vandenberghe, L. (2004). *Convex Optimization*
--- ---/
--- --
------import Mathlib
------
------open Set Polynomial Ideal Classical
-+-+---/
-+-+--
- -+--open Filter Topology Real
--- --
--- --noncomputable section
--- --
------universe u
-+-+--
-+-+--noncomputable section
-+-+--
- -+--/-!
- -+--## Part 1: Geometric Convergence of Linear Recurrences
--- --
------/-! ## Closure Operator Framework -/
-+-+--
- -+--We first establish that sequences satisfying `x_{n+1} = r · x_n` converge geometrically
- -+--when `|r| < 1`. This is the mathematical core of gradient descent convergence.
- -+---/
--- --
------/-- A closure operator on a commutative semiring, modeling derivability. -/
------structure ClosureTheory (S : Type u) [CommSemiring S] where
------  cl : Set S → Set S
------  cl_extensive : ∀ A : Set S, A ⊆ cl A
------  cl_mono : ∀ {A B : Set S}, A ⊆ B → cl A ⊆ cl B
------  cl_idem : ∀ A : Set S, cl (cl A) = cl A
-+-+--
- -+--/-
- -+--A geometric sequence `r^n * x₀` with `|r| < 1` converges to zero.
- -+---/
- -+--theorem geom_seq_tendsto_zero {r x₀ : ℝ} (hr : |r| < 1) :
- -+--    Tendsto (fun n => r ^ n * x₀) atTop (nhds 0) := by
- -+--      simpa using tendsto_pow_atTop_nhds_zero_of_abs_lt_one hr |> Filter.Tendsto.mul_const x₀
--- --
------/-- A **coherent closure** commutes with directed unions. -/
------structure CoherentClosure (S : Type u) [CommSemiring S] extends ClosureTheory S where
------  coherent : ∀ (A : Set S) (a : S), a ∈ cl A →
------    ∃ F : Finset S, (F : Set S) ⊆ A ∧ a ∈ cl (F : Set S)
-+-+--
- -+--/-
- -+--Geometric bound: `|r^n * x₀| ≤ |r|^n * |x₀|`.
- -+---/
- -+--theorem geom_seq_abs_bound (r x₀ : ℝ) (n : ℕ) :
- -+--    |r ^ n * x₀| = |r| ^ n * |x₀| := by
- -+--      rw [ abs_mul, abs_pow ]
--- --
------/-! ## Polynomial Extension and Elimination Ideals -/
-+-+--
- -+--/-
- -+--If `|r| < 1`, then `|r|^n → 0`.
- -+---/
- -+--theorem geom_decay {r : ℝ} (hr : |r| < 1) :
- -+--    Tendsto (fun n => |r| ^ n) atTop (nhds 0) := by
- -+--      exact tendsto_pow_atTop_nhds_zero_of_lt_one ( abs_nonneg r ) hr
--- --
------variable {R : Type u} [CommRing R]
-+-+--
- -+--/-!
- -+--## Part 2: Gradient Descent on Quadratic Functions
--- --
------/-- The **elimination ideal**: contraction of `I ⊆ R[X]` to `R` via `C`. -/
------def eliminationIdeal (I : Ideal (Polynomial R)) : Ideal R :=
------  I.comap Polynomial.C
-+-+--
- -+--We formalize gradient descent on the 1D quadratic `f(x) = (a/2) · x²` with `a > 0`.
- -+--The gradient is `f'(x) = a · x`, and the GD update is:
--- --
------/-- The **radical elimination ideal**: contraction of `√I` to `R`. -/
------def radicalEliminationIdeal (I : Ideal (Polynomial R)) : Ideal R :=
------  I.radical.comap Polynomial.C
-+-+--
- -+--  `x_{n+1} = x_n - η · a · x_n = (1 - η·a) · x_n`
--- --
------theorem mem_eliminationIdeal_iff (I : Ideal (Polynomial R)) (a : R) :
------    a ∈ eliminationIdeal I ↔ Polynomial.C a ∈ I :=
------  Ideal.mem_comap
-+-+--
- -+--The minimizer is `x* = 0`, so the error is `e_n = x_n - 0 = x_n`.
- -+---/
--- --
------theorem mem_radicalEliminationIdeal_iff (I : Ideal (Polynomial R)) (a : R) :
------    a ∈ radicalEliminationIdeal I ↔ Polynomial.C a ∈ I.radical :=
------  Ideal.mem_comap
-+-+--
- -+--/-- The gradient descent iteration for `f(x) = (a/2)x²`:
- -+--    `gd_step a η x = x - η * (a * x) = (1 - η * a) * x` -/
- -+--def gd_step (a η : ℝ) (x : ℝ) : ℝ := x - η * (a * x)
--- --
------theorem mem_radicalEliminationIdeal_iff' (I : Ideal (Polynomial R)) (a : R) :
------    a ∈ radicalEliminationIdeal I ↔ ∃ n : ℕ, Polynomial.C (a ^ n) ∈ I := by
------  rw [mem_radicalEliminationIdeal_iff, Ideal.mem_radical_iff]
------  simp [map_pow]
-+-+--
- -+--/-- The n-th iterate of gradient descent starting from `x₀`. -/
- -+--def gd_iterate (a η : ℝ) (x₀ : ℝ) : ℕ → ℝ
- -+--  | 0 => x₀
- -+--  | n + 1 => gd_step a η (gd_iterate a η x₀ n)
--- --
------/-! ## Prime Compatibility and Spectral Elimination -/
-+-+--
- -+--/-- The gradient descent step simplifies to multiplication by `(1 - η * a)`. -/
- -+--theorem gd_step_eq (a η x : ℝ) : gd_step a η x = (1 - η * a) * x := by
- -+--  unfold gd_step; ring
--- --
------/-- A prime `P` of `R[X]` is **compatible** with ideal `I` if `I ≤ P`. -/
------def primeCompatible (I : Ideal (Polynomial R)) (P : PrimeSpectrum (Polynomial R)) : Prop :=
------  I ≤ P.asIdeal
-+-+--
- -+--/-
- -+--The n-th GD iterate equals `(1 - η*a)^n * x₀`.
- -+---/
-@@ -168,55 +389,28 @@
- -+--      · aesop;
- -+--      · convert congr_arg ( fun x => ( 1 - η * a ) * x ) ih using 1 <;> ring;
- -+--        rw [ add_comm, show gd_iterate a η x₀ ( n + 1 ) = gd_step a η ( gd_iterate a η x₀ n ) by rfl, gd_step_eq ] ; ring
--- --
------/-- The **spectral elimination set**: `{a ∈ R | ∀ P prime, I ≤ P → C(a) ∈ P}`. -/
------def spectralElimination (I : Ideal (Polynomial R)) : Set R :=
------  {a : R | ∀ P : PrimeSpectrum (Polynomial R), primeCompatible I P → Polynomial.C a ∈ P.asIdeal}
-+-+--
- -+--/-!
- -+--## Part 3: Convergence Analysis
--- --
------theorem mem_spectralElimination_iff (I : Ideal (Polynomial R)) (a : R) :
------    a ∈ spectralElimination I ↔
------      ∀ P : PrimeSpectrum (Polynomial R), I ≤ P.asIdeal → Polynomial.C a ∈ P.asIdeal :=
------  Iff.rfl
-+-+--
- -+--The key insight: gradient descent converges when the contraction factor `|1 - η·a|`
- -+--is strictly less than 1, which holds precisely when `0 < η < 2/a`.
- -+---/
--- --
------/-! ## The Main Duality Theorem -/
-+-+--
- -+--/-
- -+--The contraction factor `|1 - η*a| < 1` when `0 < η*a < 2`.
- -+---/
- -+--theorem contraction_factor_lt_one {η a : ℝ} (hηa_pos : 0 < η * a) (hηa_lt : η * a < 2) :
- -+--    |1 - η * a| < 1 := by
- -+--      exact abs_lt.mpr ⟨ by linarith, by linarith ⟩
--- --
------/-- **Key lemma**: radical membership ↔ membership in all containing primes.
------This wraps `Ideal.radical_eq_sInf` into the `PrimeSpectrum` formulation. -/
------theorem mem_radical_iff_mem_all_primeSpectrum
------    (I : Ideal (Polynomial R)) (f : Polynomial R) :
------    f ∈ I.radical ↔
------      ∀ P : PrimeSpectrum (Polynomial R), I ≤ P.asIdeal → f ∈ P.asIdeal := by
------  constructor
------  · intro hf P hIP
------    rw [Ideal.radical_eq_sInf, Ideal.mem_sInf] at hf
------    exact hf ⟨hIP, P.isPrime⟩
------  · intro hf
------    rw [Ideal.radical_eq_sInf, Ideal.mem_sInf]
------    intro J ⟨hIJ, hJprime⟩
------    exact hf ⟨J, hJprime⟩ hIJ
-+-+--
- -+--/-
- -+--When `a > 0` and `0 < η < 2/a`, we have `0 < η*a < 2`.
- -+---/
- -+--theorem step_size_valid {a η : ℝ} (ha : 0 < a) (hη_pos : 0 < η) (hη_lt : η < 2 / a) :
- -+--    0 < η * a ∧ η * a < 2 := by
- -+--      constructor <;> nlinarith [ mul_div_cancel₀ 2 ha.ne' ]
--- --
------/-- **Main duality theorem**: radical elimination ↔ spectral elimination. -/
------theorem mem_radicalElim_iff_spectral (I : Ideal (Polynomial R)) (a : R) :
------    a ∈ radicalEliminationIdeal I ↔ a ∈ spectralElimination I := by
------  simp only [mem_radicalEliminationIdeal_iff, mem_spectralElimination_iff]
------  exact mem_radical_iff_mem_all_primeSpectrum I (Polynomial.C a)
-+-+--
- -+--/-
- -+--**Main convergence theorem**: Gradient descent on `f(x) = (a/2)x²` converges
- -+--    to the minimizer `x* = 0` when the step size satisfies `0 < η < 2/a`.
-@@ -227,22 +421,14 @@
- -+--      have h_seq_eq : ∀ n, gd_iterate a η x₀ n = (1 - η * a) ^ n * x₀ :=
- -+--        fun n => gd_iterate_eq a η x₀ n
- -+--      rw [ show gd_iterate a η x₀ = _ from funext h_seq_eq ] ; exact geom_seq_tendsto_zero ( by rw [ abs_lt ] ; constructor <;> nlinarith [ mul_div_cancel₀ 2 ha.ne' ] )
--- --
------/-- **Set equality form of the main theorem.** -/
------theorem radicalElim_eq_spectralElim (I : Ideal (Polynomial R)) :
------    (radicalEliminationIdeal I : Set R) = spectralElimination I :=
------  Set.ext (mem_radicalElim_iff_spectral I)
-+-+--
- -+--/-
- -+--**Geometric convergence rate**: `|x_n| ≤ |1 - ηa|^n · |x₀|`.
- -+---/
- -+--theorem gd_geometric_rate (a η x₀ : ℝ) (n : ℕ) :
- -+--    |gd_iterate a η x₀ n| = |1 - η * a| ^ n * |x₀| := by
- -+--      rw [ gd_iterate_eq, abs_mul, abs_pow ]
--- --
------/-- **Soundness**: radical elimination ⊆ spectral elimination. -/
------theorem elim_subset_spectral (I : Ideal (Polynomial R)) :
------    (radicalEliminationIdeal I : Set R) ⊆ spectralElimination I :=
------  (radicalElim_eq_spectralElim I).subset
-+-+--
- -+--/-
- -+--**Optimal step size**: When `η = 1/a`, gradient descent converges in one step:
- -+--    the contraction factor is 0, so `x₁ = 0`.
-@@ -250,11 +436,7 @@
- -+--theorem gd_optimal_one_step {a : ℝ} (ha : 0 < a) (x₀ : ℝ) :
- -+--    gd_iterate a (1 / a) x₀ 1 = 0 := by
- -+--      exact show x₀ - 1 / a * ( a * x₀ ) = 0 from by ring_nf; norm_num [ ha.ne' ] ;
--- --
------/-- **Completeness**: spectral elimination ⊆ radical elimination. -/
------theorem spectral_subset_elim (I : Ideal (Polynomial R)) :
------    spectralElimination I ⊆ (radicalEliminationIdeal I : Set R) :=
------  (radicalElim_eq_spectralElim I).superset
-+-+--
- -+--/-
- -+--For `η = 1/a`, all iterates after the first are 0.
- -+---/
-@@ -262,53 +444,21 @@
- -+--    gd_iterate a (1 / a) x₀ n = 0 := by
- -+--      convert gd_iterate_eq a ( 1 / a ) x₀ n using 1 ; norm_num [ ha.ne' ];
- -+--      aesop
--- --
------/-! ## Spectral Intersection Formulations -/
-+-+--
- -+--/-!
- -+--## Part 4: Condition Number and Two-Dimensional Analysis
--- --
------/-- Spectral elimination as `⋂₀` over prime contraction sets. -/
------theorem spectralElimination_eq_sInter (I : Ideal (Polynomial R)) :
------    spectralElimination I =
------      ⋂₀ {T : Set R | ∃ P : PrimeSpectrum (Polynomial R),
------        primeCompatible I P ∧ T = {a : R | Polynomial.C a ∈ P.asIdeal}} := by
------  ext a
------  simp only [mem_sInter, mem_setOf_eq, spectralElimination, primeCompatible]
------  exact ⟨fun h T ⟨P, hP, hT⟩ => hT ▸ h P hP,
------         fun h P hP => h _ ⟨P, hP, rfl⟩⟩
-+-+--
- -+--For the 2D quadratic `f(x,y) = (a/2)x² + (b/2)y²` with `0 < μ ≤ L` (eigenvalues),
- -+--the optimal step size is `η = 2/(μ + L)` and the convergence rate is
- -+--`(L - μ)/(L + μ) = (κ - 1)/(κ + 1)` where `κ = L/μ` is the condition number.
- -+---/
--- --
------/-! ## Prime Witness Extraction -/
-+-+--
- -+--/-- The condition number `κ = L/μ` for eigenvalues `μ ≤ L`. -/
- -+--def conditionNumber (μ L : ℝ) : ℝ := L / μ
--- --
------/-- If `a ∉ radicalElim(I)`, there exists a separating prime witness. -/
------theorem exists_prime_witness_of_not_mem_radicalElim
------    (I : Ideal (Polynomial R)) (a : R)
------    (ha : a ∉ radicalEliminationIdeal I) :
------    ∃ P : PrimeSpectrum (Polynomial R),
------      primeCompatible I P ∧ Polynomial.C a ∉ P.asIdeal := by
------  rw [mem_radicalElim_iff_spectral] at ha
------  simp only [spectralElimination, primeCompatible, mem_setOf_eq] at ha
------  push_neg at ha
------  exact ha
-+-+--
- -+--/-- The optimal convergence rate for a 2D quadratic with eigenvalues `μ` and `L`. -/
- -+--def optimalRate (μ L : ℝ) : ℝ := (L - μ) / (L + μ)
--- --
------/-- **Contrapositive characterization**: non-elimination ↔ ∃ separating prime. -/
------theorem not_mem_radicalElim_iff_exists_prime_witness
------    (I : Ideal (Polynomial R)) (a : R) :
------    a ∉ radicalEliminationIdeal I ↔
------      ∃ P : PrimeSpectrum (Polynomial R),
------        primeCompatible I P ∧ Polynomial.C a ∉ P.asIdeal := by
------  constructor
------  · exact exists_prime_witness_of_not_mem_radicalElim I a
------  · intro ⟨P, hP, hnotmem⟩ hmem
------    rw [mem_radicalElim_iff_spectral] at hmem
------    exact hnotmem (hmem P hP)
-+-+--
- -+--/-
- -+--The optimal convergence rate equals `(κ-1)/(κ+1)`.
- -+---/
-@@ -316,57 +466,28 @@
- -+--    optimalRate μ L = (conditionNumber μ L - 1) / (conditionNumber μ L + 1) := by
- -+--      unfold optimalRate conditionNumber;
- -+--      grind
--- --
------/-! ## Thermodynamic Functionals -/
-+-+--
- -+--/-
- -+--The optimal rate is in `[0, 1)` when `0 < μ ≤ L`.
- -+---/
- -+--theorem optimal_rate_nonneg {μ L : ℝ} (hμ : 0 < μ) (hμL : μ ≤ L) :
- -+--    0 ≤ optimalRate μ L := by
- -+--      exact div_nonneg ( by linarith ) ( by linarith )
--- --
------/-- **Prime pressure indicator**: `1` if `a ∉ P` (positive pressure), `0` if `a ∈ P`. -/
------def primePressureIndicator (P : PrimeSpectrum (Polynomial R)) (a : R) : ℝ :=
------  if Polynomial.C a ∈ P.asIdeal then (0 : ℝ) else (1 : ℝ)
-+-+--
- -+--theorem optimal_rate_lt_one {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
- -+--    optimalRate μ L < 1 := by
- -+--      exact div_lt_one ( by positivity ) |>.2 ( by linarith )
--- --
------/-- `a ∈ spectralElim(I)` iff pressure vanishes at all compatible primes. -/
------theorem mem_spectralElimination_iff_pressure_zero
------    (I : Ideal (Polynomial R)) (a : R) :
------    a ∈ spectralElimination I ↔
------      ∀ P : PrimeSpectrum (Polynomial R),
------        primeCompatible I P → primePressureIndicator P a = 0 := by
------  simp only [spectralElimination, primeCompatible, mem_setOf_eq, primePressureIndicator]
------  constructor
------  · intro h P hP; simp [h P hP]
------  · intro h P hP
------    specialize h P hP
------    split_ifs at h with hmem
------    · exact hmem
------    · norm_num at h
-+-+--
- -+--/-
- -+--Well-conditioned problems (κ ≈ 1) converge fast: rate = 0 when μ = L.
- -+---/
- -+--theorem optimal_rate_well_conditioned (μ : ℝ) :
- -+--    optimalRate μ μ = 0 := by
- -+--      unfold optimalRate; ring
--- --
------/-- Non-elimination implies a positive-pressure prime witness. -/
------theorem exists_positive_pressure_witness
------    (I : Ideal (Polynomial R)) (a : R)
------    (ha : a ∉ radicalEliminationIdeal I) :
------    ∃ P : PrimeSpectrum (Polynomial R),
------      primeCompatible I P ∧ primePressureIndicator P a = 1 := by
------  obtain ⟨P, hP, hnotmem⟩ := exists_prime_witness_of_not_mem_radicalElim I a ha
------  exact ⟨P, hP, by simp [primePressureIndicator, hnotmem]⟩
-+-+--
- -+--/-- The optimal step size for a 2D quadratic is `2/(μ + L)`. -/
- -+--def optimalStepSize (μ L : ℝ) : ℝ := 2 / (μ + L)
--- --
------/-- **Free-energy gap** at a prime: same as the pressure indicator. -/
------def freeEnergyGap (P : PrimeSpectrum (Polynomial R)) (a : R) : ℝ :=
------  primePressureIndicator P a
-+-+--
- -+--/-
- -+--With the optimal step size `η = 2/(μ+L)`, the contraction factors for
- -+--    both coordinates are `±(L-μ)/(L+μ)`, giving the optimal rate.
-@@ -374,21 +495,11 @@
- -+--theorem optimal_step_contraction_small {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
- -+--    1 - optimalStepSize μ L * μ = optimalRate μ L := by
- -+--      unfold optimalStepSize optimalRate; rw [ div_mul_eq_mul_div, one_sub_div ] ; ring ; positivity;
--- --
------/-- **The variational kernel set**: elements with zero pressure everywhere. -/
------def primeVariationalKernelSet (I : Ideal (Polynomial R)) : Set R :=
------  {a : R | ∀ P : PrimeSpectrum (Polynomial R),
------    primeCompatible I P → primePressureIndicator P a = 0}
-+-+--
- -+--theorem optimal_step_contraction_large {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
- -+--    1 - optimalStepSize μ L * L = -(optimalRate μ L) := by
- -+--      grind +locals
--- --
------/-- Variational kernel = spectral elimination. -/
------theorem primeVariationalKernelSet_eq_spectralElimination
------    (I : Ideal (Polynomial R)) :
------    primeVariationalKernelSet I = spectralElimination I := by
------  ext a
------  exact (mem_spectralElimination_iff_pressure_zero I a).symm
-+-+--
- -+--/-
- -+--**Fundamental bound**: The number of iterations needed to reduce error by factor ε
- -+--    is proportional to κ · log(1/ε), where κ is the condition number. This is captured
-@@ -398,89 +509,7 @@
- -+--    optimalRate μ L ≤ 1 - 2 / (conditionNumber μ L + 1) := by
- -+--      unfold optimalRate conditionNumber;
- -+--      rw [ one_sub_div, div_le_div_iff₀ ] <;> nlinarith [ mul_div_cancel₀ L hμ.ne' ]
--- --
------/-- **Full duality chain**: radical elim = spectral elim = variational kernel. -/
------theorem radicalElim_eq_variationalKernel (I : Ideal (Polynomial R)) :
------    (radicalEliminationIdeal I : Set R) = primeVariationalKernelSet I := by
------  rw [primeVariationalKernelSet_eq_spectralElimination, ← radicalElim_eq_spectralElim]
------
------/-- **Variational principle**: elimination iff all free-energy gaps vanish. -/
------theorem mem_radicalElim_iff_sup_gap_zero (I : Ideal (Polynomial R)) (a : R) :
------    a ∈ radicalEliminationIdeal I ↔
------      ∀ P : PrimeSpectrum (Polynomial R),
------        primeCompatible I P → freeEnergyGap P a = 0 := by
------  rw [mem_radicalElim_iff_spectral]
------  exact mem_spectralElimination_iff_pressure_zero I a
------
------/-! ## Monotonicity -/
------
------theorem eliminationIdeal_mono {I J : Ideal (Polynomial R)} (h : I ≤ J) :
------    eliminationIdeal I ≤ eliminationIdeal J :=
------  Ideal.comap_mono h
------
------theorem radicalEliminationIdeal_mono {I J : Ideal (Polynomial R)} (h : I ≤ J) :
------    radicalEliminationIdeal I ≤ radicalEliminationIdeal J :=
------  Ideal.comap_mono (Ideal.radical_mono h)
------
------/-- Spectral elimination is monotone: `I ≤ J → spectralElim(I) ⊆ spectralElim(J)`.
------Larger ideals eliminate into larger sets, because they impose constraints on
------fewer primes. -/
------theorem spectralElimination_mono {I J : Ideal (Polynomial R)} (h : I ≤ J) :
------    spectralElimination I ⊆ spectralElimination J := by
------  intro a ha P hP
------  exact ha P (le_trans h hP)
------
------/-! ## Contraction Map -/
------
------/-- The contraction map `Spec(R[X]) → Spec(R)`. -/
------def contractionMap : PrimeSpectrum (Polynomial R) → PrimeSpectrum R :=
------  fun P => ⟨Ideal.comap Polynomial.C P.asIdeal, Ideal.IsPrime.comap Polynomial.C⟩
------
------theorem mem_contractionMap_iff (P : PrimeSpectrum (Polynomial R)) (a : R) :
------    a ∈ (contractionMap P).asIdeal ↔ Polynomial.C a ∈ P.asIdeal :=
------  Ideal.mem_comap
------
------/-! ## Pressure Set Equality -/
------
------/-- Radical elimination = set of elements with non-positive pressure everywhere. -/
------theorem radicalElim_eq_pressure_set (I : Ideal (Polynomial R)) :
------    (radicalEliminationIdeal I : Set R) =
------      {a | ∀ P : PrimeSpectrum (Polynomial R), primeCompatible I P →
------        primePressureIndicator P a ≤ 0} := by
------  ext a
------  simp only [SetLike.mem_coe, mem_setOf_eq]
------  rw [mem_radicalElim_iff_spectral]
------  simp only [spectralElimination, primeCompatible, mem_setOf_eq, primePressureIndicator]
------  constructor
------  · intro h P hP; simp [h P hP]
------  · intro h P hP
------    specialize h P hP
------    split_ifs at h with hmem
------    · exact hmem
------    · linarith
------
------/-! ## Axiom verification -/
------
------#print axioms mem_eliminationIdeal_iff
------#print axioms mem_radical_iff_mem_all_primeSpectrum
------#print axioms mem_radicalElim_iff_spectral
------#print axioms radicalElim_eq_spectralElim
------#print axioms not_mem_radicalElim_iff_exists_prime_witness
------#print axioms radicalElim_eq_variationalKernel
------#print axioms spectralElimination_eq_sInter
------#print axioms mem_radicalElim_iff_sup_gap_zero
------#print axioms exists_positive_pressure_witness
------#print axioms radicalElim_eq_pressure_set+--- a/Logic/Basic.lean
-----++++ b/Logic/Basic.lean
-----+@@ -1,2162 +1,3640 @@
-----+ --- a/MachineLearning/Basic.lean
-----+ +++ b/MachineLearning/Basic.lean
-----+-@@ -1,219 +1,1941 @@
-----+--/-
-----+--Copyright (c) 2025 Harmonic. All rights reserved.
-----+--Released under Apache 2.0 license as described in the file LICENSE.
-----+---/
-----+--import Mathlib
-+-+--
- -+--end+--- a/MachineLearning/Basic.lean
- -+-++++ b/MachineLearning/Basic.lean
- -+-+@@ -1,241 +1,1700 @@
-@@ -489,10806 +518,7 @@
- -+-+-@@ -1,11 +1,228 @@
- -+-+--/-!
- -+-+--# Tropical Algebra Placeholder
--- -+--
-----+--/-!
-----+--# Gradient Descent Convergence Theory
-----+--
-----+--This file formalizes the convergence theory of gradient descent for strongly convex
-----+--quadratic functions, establishing the fundamental result that underpins optimization
-----+--in machine learning.
-----+--
-----+--## Main Results
-----+--
-----+--* `gd_error_eq` — The error of gradient descent on a quadratic `f(x) = (a/2)x²`
-----+--  with step size `η` satisfies `e_n = (1 - ηa)^n · e_0`
-----+--* `gd_contraction_factor_lt_one` — The contraction factor `|1 - ηa| < 1` when
-----+--  `0 < η < 2/a`
-----+--* `gd_converges` — Gradient descent converges: `x_n → x*`
-----+--* `gd_geometric_rate` — The convergence rate is geometric:
-----+--  `|x_n - x*| ≤ |1 - ηa|^n · |x_0 - x*|`
-----+--* `gd_optimal_step` — The optimal step size is `η = 1/a`, giving convergence in one step
-----+--* `gd_condition_number_bound` — For 2D quadratics with eigenvalues `μ ≤ L`,
-----+--  the optimal convergence rate is `(κ-1)/(κ+1)` where `κ = L/μ`
-----+--
-----+--## References
-----+--
-----+--* Nesterov, Y. (2004). *Introductory Lectures on Convex Optimization*
-----+--* Boyd, S. & Vandenberghe, L. (2004). *Convex Optimization*
-----+---/
-----+--
-----+--open Filter Topology Real
-----+--
-----+--noncomputable section
-----+--
-----+--/-!
-----+--## Part 1: Geometric Convergence of Linear Recurrences
-----+--
-----+--We first establish that sequences satisfying `x_{n+1} = r · x_n` converge geometrically
-----+--when `|r| < 1`. This is the mathematical core of gradient descent convergence.
-----+---/
-----+--
-----+--/-
-----+--A geometric sequence `r^n * x₀` with `|r| < 1` converges to zero.
-----+---/
-----+--theorem geom_seq_tendsto_zero {r x₀ : ℝ} (hr : |r| < 1) :
-----+--    Tendsto (fun n => r ^ n * x₀) atTop (nhds 0) := by
-----+--      simpa using tendsto_pow_atTop_nhds_zero_of_abs_lt_one hr |> Filter.Tendsto.mul_const x₀
-----+--
-----+--/-
-----+--Geometric bound: `|r^n * x₀| ≤ |r|^n * |x₀|`.
-----+---/
-----+--theorem geom_seq_abs_bound (r x₀ : ℝ) (n : ℕ) :
-----+--    |r ^ n * x₀| = |r| ^ n * |x₀| := by
-----+--      rw [ abs_mul, abs_pow ]
-----+--
-----+--/-
-----+--If `|r| < 1`, then `|r|^n → 0`.
-----+---/
-----+--theorem geom_decay {r : ℝ} (hr : |r| < 1) :
-----+--    Tendsto (fun n => |r| ^ n) atTop (nhds 0) := by
-----+--      exact tendsto_pow_atTop_nhds_zero_of_lt_one ( abs_nonneg r ) hr
-----+--
-----+--/-!
-----+--## Part 2: Gradient Descent on Quadratic Functions
-----+--
-----+--We formalize gradient descent on the 1D quadratic `f(x) = (a/2) · x²` with `a > 0`.
-----+--The gradient is `f'(x) = a · x`, and the GD update is:
-----+--
-----+--  `x_{n+1} = x_n - η · a · x_n = (1 - η·a) · x_n`
-----+--
-----+--The minimizer is `x* = 0`, so the error is `e_n = x_n - 0 = x_n`.
-----+---/
-----+--
-----+--/-- The gradient descent iteration for `f(x) = (a/2)x²`:
-----+--    `gd_step a η x = x - η * (a * x) = (1 - η * a) * x` -/
-----+--def gd_step (a η : ℝ) (x : ℝ) : ℝ := x - η * (a * x)
-----+--
-----+--/-- The n-th iterate of gradient descent starting from `x₀`. -/
-----+--def gd_iterate (a η : ℝ) (x₀ : ℝ) : ℕ → ℝ
-----+--  | 0 => x₀
-----+--  | n + 1 => gd_step a η (gd_iterate a η x₀ n)
-----+--
-----+--/-- The gradient descent step simplifies to multiplication by `(1 - η * a)`. -/
-----+--theorem gd_step_eq (a η x : ℝ) : gd_step a η x = (1 - η * a) * x := by
-----+--  unfold gd_step; ring
-----+--
-----+--/-
-----+--The n-th GD iterate equals `(1 - η*a)^n * x₀`.
-----+---/
-----+--theorem gd_iterate_eq (a η x₀ : ℝ) (n : ℕ) :
-----+--    gd_iterate a η x₀ n = (1 - η * a) ^ n * x₀ := by
-----+--      induction' n with n ih;
-----+--      · aesop;
-----+--      · convert congr_arg ( fun x => ( 1 - η * a ) * x ) ih using 1 <;> ring;
-----+--        rw [ add_comm, show gd_iterate a η x₀ ( n + 1 ) = gd_step a η ( gd_iterate a η x₀ n ) by rfl, gd_step_eq ] ; ring
-----+--
-----+--/-!
-----+--## Part 3: Convergence Analysis
-----+--
-----+--The key insight: gradient descent converges when the contraction factor `|1 - η·a|`
-----+--is strictly less than 1, which holds precisely when `0 < η < 2/a`.
-----+---/
-----+--
-----+--/-
-----+--The contraction factor `|1 - η*a| < 1` when `0 < η*a < 2`.
-----+---/
-----+--theorem contraction_factor_lt_one {η a : ℝ} (hηa_pos : 0 < η * a) (hηa_lt : η * a < 2) :
-----+--    |1 - η * a| < 1 := by
-----+--      exact abs_lt.mpr ⟨ by linarith, by linarith ⟩
-----+--
-----+--/-
-----+--When `a > 0` and `0 < η < 2/a`, we have `0 < η*a < 2`.
-----+---/
-----+--theorem step_size_valid {a η : ℝ} (ha : 0 < a) (hη_pos : 0 < η) (hη_lt : η < 2 / a) :
-----+--    0 < η * a ∧ η * a < 2 := by
-----+--      constructor <;> nlinarith [ mul_div_cancel₀ 2 ha.ne' ]
-----+--
-----+--/-
-----+--**Main convergence theorem**: Gradient descent on `f(x) = (a/2)x²` converges
-----+--    to the minimizer `x* = 0` when the step size satisfies `0 < η < 2/a`.
-----+---/
-----+--theorem gd_converges {a η : ℝ} (ha : 0 < a) (hη_pos : 0 < η) (hη_lt : η < 2 / a)
-----+--    (x₀ : ℝ) : Tendsto (gd_iterate a η x₀) atTop (nhds 0) := by
-----+--      -- Use `gd_iterate_eq` to rewrite the sequence as `(1 - η * a) ^ n * x₀`.
-----+--      have h_seq_eq : ∀ n, gd_iterate a η x₀ n = (1 - η * a) ^ n * x₀ :=
-----+--        fun n => gd_iterate_eq a η x₀ n
-----+--      rw [ show gd_iterate a η x₀ = _ from funext h_seq_eq ] ; exact geom_seq_tendsto_zero ( by rw [ abs_lt ] ; constructor <;> nlinarith [ mul_div_cancel₀ 2 ha.ne' ] )
-----+--
-----+--/-
-----+--**Geometric convergence rate**: `|x_n| ≤ |1 - ηa|^n · |x₀|`.
-----+---/
-----+--theorem gd_geometric_rate (a η x₀ : ℝ) (n : ℕ) :
-----+--    |gd_iterate a η x₀ n| = |1 - η * a| ^ n * |x₀| := by
-----+--      rw [ gd_iterate_eq, abs_mul, abs_pow ]
-----+--
-----+--/-
-----+--**Optimal step size**: When `η = 1/a`, gradient descent converges in one step:
-----+--    the contraction factor is 0, so `x₁ = 0`.
-----+---/
-----+--theorem gd_optimal_one_step {a : ℝ} (ha : 0 < a) (x₀ : ℝ) :
-----+--    gd_iterate a (1 / a) x₀ 1 = 0 := by
-----+--      exact show x₀ - 1 / a * ( a * x₀ ) = 0 from by ring_nf; norm_num [ ha.ne' ] ;
-----+--
-----+--/-
-----+--For `η = 1/a`, all iterates after the first are 0.
-----+---/
-----+--theorem gd_optimal_all_zero {a : ℝ} (ha : 0 < a) (x₀ : ℝ) (n : ℕ) (hn : 0 < n) :
-----+--    gd_iterate a (1 / a) x₀ n = 0 := by
-----+--      convert gd_iterate_eq a ( 1 / a ) x₀ n using 1 ; norm_num [ ha.ne' ];
-----+--      aesop
-----+--
-----+--/-!
-----+--## Part 4: Condition Number and Two-Dimensional Analysis
-----+--
-----+--For the 2D quadratic `f(x,y) = (a/2)x² + (b/2)y²` with `0 < μ ≤ L` (eigenvalues),
-----+--the optimal step size is `η = 2/(μ + L)` and the convergence rate is
-----+--`(L - μ)/(L + μ) = (κ - 1)/(κ + 1)` where `κ = L/μ` is the condition number.
-----+---/
-----+--
-----+--/-- The condition number `κ = L/μ` for eigenvalues `μ ≤ L`. -/
-----+--def conditionNumber (μ L : ℝ) : ℝ := L / μ
-----+--
-----+--/-- The optimal convergence rate for a 2D quadratic with eigenvalues `μ` and `L`. -/
-----+--def optimalRate (μ L : ℝ) : ℝ := (L - μ) / (L + μ)
-----+--
-----+--/-
-----+--The optimal convergence rate equals `(κ-1)/(κ+1)`.
-----+---/
-----+--theorem optimal_rate_eq_condition {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
-----+--    optimalRate μ L = (conditionNumber μ L - 1) / (conditionNumber μ L + 1) := by
-----+--      unfold optimalRate conditionNumber;
-----+--      grind
-----+--
-----+--/-
-----+--The optimal rate is in `[0, 1)` when `0 < μ ≤ L`.
-----+---/
-----+--theorem optimal_rate_nonneg {μ L : ℝ} (hμ : 0 < μ) (hμL : μ ≤ L) :
-----+--    0 ≤ optimalRate μ L := by
-----+--      exact div_nonneg ( by linarith ) ( by linarith )
-----+--
-----+--theorem optimal_rate_lt_one {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
-----+--    optimalRate μ L < 1 := by
-----+--      exact div_lt_one ( by positivity ) |>.2 ( by linarith )
-----+--
-----+--/-
-----+--Well-conditioned problems (κ ≈ 1) converge fast: rate = 0 when μ = L.
-----+---/
-----+--theorem optimal_rate_well_conditioned (μ : ℝ) :
-----+--    optimalRate μ μ = 0 := by
-----+--      unfold optimalRate; ring
-----+--
-----+--/-- The optimal step size for a 2D quadratic is `2/(μ + L)`. -/
-----+--def optimalStepSize (μ L : ℝ) : ℝ := 2 / (μ + L)
-----+--
-----+--/-
-----+--With the optimal step size `η = 2/(μ+L)`, the contraction factors for
-----+--    both coordinates are `±(L-μ)/(L+μ)`, giving the optimal rate.
-----+---/
-----+--theorem optimal_step_contraction_small {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
-----+--    1 - optimalStepSize μ L * μ = optimalRate μ L := by
-----+--      unfold optimalStepSize optimalRate; rw [ div_mul_eq_mul_div, one_sub_div ] ; ring ; positivity;
-----+--
-----+--theorem optimal_step_contraction_large {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
-----+--    1 - optimalStepSize μ L * L = -(optimalRate μ L) := by
-----+--      grind +locals
-----+--
-----+--/-
-----+--**Fundamental bound**: The number of iterations needed to reduce error by factor ε
-----+--    is proportional to κ · log(1/ε), where κ is the condition number. This is captured
-----+--    by the fact that log(1/rate) ≈ 2/κ for large κ.
-----+---/
-----+--theorem iteration_complexity_bound {μ L : ℝ} (hμ : 0 < μ) (hμL : μ ≤ L) :
-----+--    optimalRate μ L ≤ 1 - 2 / (conditionNumber μ L + 1) := by
-----+--      unfold optimalRate conditionNumber;
-----+--      rw [ one_sub_div, div_le_div_iff₀ ] <;> nlinarith [ mul_div_cancel₀ L hμ.ne' ]
-----+--
-----+--end+--- a/MachineLearning/Basic.lean
-----+-++++ b/MachineLearning/Basic.lean
-----+-+@@ -1,241 +1,1700 @@
-----+-+---- a/Bridges/Basic.lean
-----+-+-+++ b/Bridges/Basic.lean
-----+-+-@@ -1,11 +1,228 @@
-----+-+--/-!
-----+-+--# Tropical Algebra Placeholder
-----+-+--
-----+-+--The main tropical/max-plus spectral theory development is in `Bridges/`.
-----+-+--See:
-----+-+--- `Bridges.MaxPlusDefs` - Core definitions
-----+-+--- `Bridges.MaxPlusLemmas` - Structural lemmas
-----+-+--- `Bridges.EigenvectorIteration` - Eigenvector iteration theorem
-----+-+--- `Bridges.PerronTheorem` - Tropical Perron-Frobenius theorem
-----+-+--- `Bridges.EMLSpectral` - EML spectral duality
-----+-+---/+--- a/Bridges/Basic.lean
-----+-+-++++ b/Bridges/Basic.lean
-----+-+-+@@ -1,104 +1,149 @@
-----+-+-+ /-
-----+-+-+-# Bridge Theory in Simple Graphs
-----+-+-++Copyright (c) 2025. All rights reserved.
-----+-+-++Released under Apache 2.0 license.
-----+-+-++
-----+-+-++# Bridge Theory in Graph Theory
-----++@@ -1,1941 +1,1700 @@
-----++---- a/MachineLearning/Basic.lean
-----++-+++ b/MachineLearning/Basic.lean
-----++-@@ -1,241 +1,1700 @@
-----++----- a/Bridges/Basic.lean
-----++--+++ b/Bridges/Basic.lean
-----++--@@ -1,11 +1,228 @@
-----++---/-!
-----++---# Tropical Algebra Placeholder
-----++---
-----++---The main tropical/max-plus spectral theory development is in `Bridges/`.
-----++---See:
-----++---- `Bridges.MaxPlusDefs` - Core definitions
-----++---- `Bridges.MaxPlusLemmas` - Structural lemmas
-----++---- `Bridges.EigenvectorIteration` - Eigenvector iteration theorem
-----++---- `Bridges.PerronTheorem` - Tropical Perron-Frobenius theorem
-----++---- `Bridges.EMLSpectral` - EML spectral duality
-----++----/+--- a/Bridges/Basic.lean
-----++--++++ b/Bridges/Basic.lean
-----++--+@@ -1,104 +1,149 @@
-----++--+ /-
-----++--+-# Bridge Theory in Simple Graphs
-----++--++Copyright (c) 2025. All rights reserved.
-----++--++Released under Apache 2.0 license.
-----++--++
-----++--++# Bridge Theory in Graph Theory
-----++--+ 
-----++--+ This file develops the theory of bridges (cut edges) in simple graphs,
-----++--+-proving the fundamental equivalence between trees and connected graphs
-----++--+-where every edge is a bridge.
-----++--++building on Mathlib's `SimpleGraph.IsBridge` definition.
-----++--+ 
-----++--+-## Main Results
-----++--++## Main results
-----++--+ 
-----++--+-* `SimpleGraph.IsAcyclic.isBridge_of_mem_edgeSet` — In an acyclic graph, every edge is a bridge
-----++--+-* `SimpleGraph.IsTree.isBridge_of_mem_edgeSet` — In a tree, every edge is a bridge
-----++--+-* `SimpleGraph.isAcyclic_of_forall_isBridge` — If every edge is a bridge, the graph is acyclic
-----++--+-* `SimpleGraph.isTree_iff_connected_and_forall_isBridge` — **Tree-Bridge Equivalence**:
-----++--+-  A graph is a tree if and only if it is connected and every edge is a bridge
-----++--++* `IsBridge.connectedComponent_ne` — Endpoints of a bridge are in different
-----++--++  connected components after deletion.
-----++--++* `IsBridge.two_connected_components` — Removing a bridge from a connected
-----++--++  graph yields exactly two connected components.
-----++--++* `IsTree.isBridge_of_adj` — Every edge of a tree is a bridge.
-----++--++* `connected_isBridge_all_iff_isTree` — A connected graph is a tree iff
-----++--++  every edge is a bridge.
-----++--++* `IsBridge.forall_reachable_delete_left_or_right` — Every vertex in a
-----++--++  connected graph is reachable from one side of a bridge after deletion.
-----++--+ 
-----++--+-## Historical Context
-----++--++## Historical context
-----++--+ 
-----++--+-Bridges in graph theory originate from Euler's 1736 analysis of the Königsberg
-----++--+-bridge problem. The Tree-Bridge Equivalence Theorem provides a fundamental
-----++--+-structural characterization: trees are precisely the minimally connected graphs,
-----++--+-where the removal of any single edge disconnects the graph.
-----++--+-
-----++--+-## References
-----++--+-
-----++--+-* Reinhard Diestel, *Graph Theory*, 5th Edition, Springer, 2017
-----++--++The study of bridges in graph theory traces back to Euler's 1736 solution
-----++--++of the Königsberg Bridge Problem — widely considered the birth of graph
-----++--++theory. A bridge (or cut edge) is an edge whose removal disconnects the
-----++--++graph, making it a critical concept in network reliability and infrastructure
-----++--++analysis.
-----++-+--- a/Tropical/Basic.lean
-----++-++++ b/Tropical/Basic.lean
-----++-+@@ -1,1315 +1,383 @@
-----++-+---- a/Tropical/Basic.lean
-----++-+-+++ b/Tropical/Basic.lean
-----++-+-@@ -1,930 +1,383 @@
-----++-+----- a/Tropical/Basic.lean
-----++-+--+++ b/Tropical/Basic.lean
-----++-+--@@ -1,545 +1,383 @@
-----++-+------ a/Tropical/Basic.lean
-----++-+---+++ b/Tropical/Basic.lean
-----++-+---@@ -1,383 +1,160 @@
-----++-+------- a/EML/Basic.lean
-----++-+----+++ b/EML/Basic.lean
-----++-+----@@ -1,277 +1,125 @@
-----++-+-----/-
-----++-+-----Copyright (c) 2026 Harmonic. All rights reserved.
-----++-+-----Released under Apache 2.0 license as described in the file LICENSE.
-----++-+------/
-----++-+---- import Mathlib
-----++-+---- 
-----++-+-----/-!
-----++-+-----# Pullback Stability of Universal Approximation
-----++-+----+/-! # CatalogBuild.EML.Basic
-----++-+---- 
-----++-+-----Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
-----++-+-----subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
-----++-+-----closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
-----++-+-----When `φ` is injective, this gives density in all of `C(X, ℝ)`.
-----++-+-----
-----++-+-----This establishes a transport principle: universal approximation results (like
-----++-+-----Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
-----++-+-----with the precise target being the fiber-constant functions.
-----++-+-----
-----++-+-----## Main definitions
-----++-+-----
-----++-+-----* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
-----++-+-----  fibers of `φ`.
-----++-+-----* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
-----++-+-----
-----++-+-----## Main results
-----++-+-----
-----++-+-----### Basic properties (§1)
-----++-+-----* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
-----++-+-----* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
-----++-+-----* `norm_pullback_le` — the pullback map is norm-nonincreasing.
-----++-+-----* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
-----++-+-----* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
-----++-+-----
-----++-+-----### Factorization (§2)
-----++-+-----* `fiberConst_subset_range_pullback` — every fiber-constant function factors
-----++-+-----  through `Set.range φ`, hence is a pullback (via Tietze extension).
-----++-+-----
-----++-+-----### Density transport (§3)
-----++-+-----* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
-----++-+-----  subalgebra equals `FiberConst φ`.
-----++-+-----* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
-----++-+-----
-----++-+-----### ε-approximation (§4)
-----++-+-----* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
-----++-+-----* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
-----++-+----+Auto-generated from theorem catalog database.
-----++-+----+Domain: EML
-----++-+----+Declarations: 15
-----++-+---- -/
-----++-+---- 
-----++-+-----open scoped Topology
-----++-+-----open Topology
-----++-+----+noncomputable section
-----++-+---- 
-----++-+-----variable {X Y : Type*}
-----++-+-----variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
-----++-+-----variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
-----++-+----+/-- The inverse for hyperbolic SPB is also negation. -/
-----++-+----+theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
-----++-+----+  simp [spbH]
-----++-+---- 
-----++-+-----/-! ### §1: Definitions and basic properties -/
-----++-+----+/-- Wick duality: SPB with negated second argument equals the "difference"
-----++-+----+in the hyperbolic SPB. This is the real-variable manifestation of the
-----++-+----+Wick rotation t → it. -/
-----++-+----+theorem wick_duality (x y : ℝ) :
-----++-+----+    spb x (-y) = (x - y) / (1 + x * y) := by
-----++-+----+  simp only [spb]
-----++-+----+  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
-----++-+----+  rw [heq]; ring
-----++-+---- 
-----++-+-----/-- Continuous functions on `X` that are constant on fibers of `φ`.
-----++-+-----This is the natural functional-analytic object associated to a feature map:
-----++-+-----it captures exactly the observables visible through `φ`. -/
-----++-+-----def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
-----++-+-----  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
-----++-+-----  algebraMap_mem' r := by intro x x' _; simp
-----++-+-----  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----++-+-----  zero_mem' := by intro x x' _; simp
-----++-+-----  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----++-+-----  one_mem' := by intro x x' _; simp
-----++-+----+/-- The tangent addition law IS the stereographic sum.
-----++-+----+tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
-----++-+----+theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
-----++-+----+    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
-----++-+----+  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
-----++-+----+      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
-----++-+----+  field_simp
-----++-+---- 
-----++-+-----/-- Pullback of continuous real-valued functions along `φ`. -/
-----++-+-----def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
-----++-+-----  toFun f := f.comp φ
-----++-+-----  map_zero' := by ext; simp
-----++-+-----  map_one' := by ext; simp
-----++-+-----  map_add' := by intros; ext; simp
-----++-+-----  map_mul' := by intros; ext; simp
-----++-+-----  commutes' := by intros; ext; simp
-----++-+----+/-- SPB expression trees — analogous to EML expression trees. -/
-----++-+----+inductive SPBExpr where
-----++-+----+  | zero : SPBExpr
-----++-+----+  | one : SPBExpr
-----++-+----+  | var : ℕ → SPBExpr
-----++-+----+  | node : SPBExpr → SPBExpr → SPBExpr
-----++-+----+  deriving Repr, BEq
-----++-+---- 
-----++-+-----@[simp]
-----++-+-----theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
-----++-+-----    pullbackAlg φ f x = f (φ x) := rfl
-----++-+----+/-- Evaluate an SPB expression. -/
-----++-+----+def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
-----++-+----+  match e with
-----++-+----+  | .zero => 0
-----++-+----+  | .one => 1
-----++-+----+  | .var n => vars n
-----++-+----+  | .node l r => spb (l.eval vars) (r.eval vars)
-----++-+---- 
-----++-+-----theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----++-+-----    pullbackAlg φ f ∈ FiberConst φ := by
-----++-+-----  intro x x' h; simp [h]
-----++-+----+/-- Depth of an SPB expression. -/
-----++-+----+def SPBExpr.depth : SPBExpr → ℕ
-----++-+----+  | .zero => 0
-----++-+----+  | .one => 0
-----++-+----+  | .var _ => 0
-----++-+----+  | .node l r => 1 + max l.depth r.depth
-----++-+---- 
-----++-+-----theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
-----++-+-----    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----++-+-----  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
-----++-+----+/-- Leaf count. -/
-----++-+----+def SPBExpr.leafCount : SPBExpr → ℕ
-----++-+----+  | .zero => 1
-----++-+----+  | .one => 1
-----++-+----+  | .var _ => 1
-----++-+----+  | .node l r => l.leafCount + r.leafCount
-----++-+---- 
-----++-+-----theorem range_comp_subalgebra_subset_fiberConst
-----++-+-----    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
-----++-+-----    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----++-+-----  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
-----++-+----+/-- Internal node count. -/
-----++-+----+def SPBExpr.nodeCount : SPBExpr → ℕ
-----++-+----+  | .zero => 0
-----++-+----+  | .one => 0
-----++-+----+  | .var _ => 0
-----++-+----+  | .node l r => 1 + l.nodeCount + r.nodeCount
-----++-+---- 
-----++-+-----/-- `FiberConst φ` is closed in the uniform topology. -/
-----++-+-----theorem fiberConst_closed (φ : C(X, Y)) :
-----++-+-----    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
-----++-+-----  refine isClosed_of_closure_subset ?_
-----++-+-----  intro g hg x x' h
-----++-+-----  rw [mem_closure_iff_nhds] at hg
-----++-+-----  contrapose! hg
-----++-+-----  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
-----++-+-----    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
-----++-+-----    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
-----++-+----+/-- Binary tree identity: leaves = internal nodes + 1. -/
-----++-+----+theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
-----++-+----+    e.leafCount = e.nodeCount + 1 := by
-----++-+----+  induction e with
-----++-+----+  | zero => rfl
-----++-+----+  | one => rfl
-----++-+----+  | var _ => rfl
-----++-+----+  | node l r ihl ihr =>
-----++-+----+    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
-----++-+----+    omega
-----++-+---- 
-----++-+-----omit [T2Space X] [T2Space Y] in
-----++-+-----/-- The pullback map is norm-nonincreasing. -/
-----++-+-----theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----++-+-----    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
-----++-+-----  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
-----++-+-----    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
-----++-+----+/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
-----++-+----+def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
-----++-+---- 
-----++-+-----/-- When `φ` is surjective, pullback is an isometry. -/
-----++-+-----theorem pullback_isometry_of_surjective
-----++-+-----    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
-----++-+-----    ‖pullbackAlg φ f‖ = ‖f‖ := by
-----++-+-----  refine le_antisymm (norm_pullback_le φ f) ?_
-----++-+-----  rw [ContinuousMap.norm_le _ (by positivity)]
-----++-+-----  intro y; obtain ⟨x, rfl⟩ := hφ y
-----++-+-----  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
-----++-+----+/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
-----++-+----+theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
-----++-+----+  unfold logisticSigmoid
-----++-+----+  rw [Real.exp_neg]
-----++-+----+  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
-----++-+----+  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
-----++-+----+  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----++-+----+  field_simp; ring
-----++-+---- 
-----++-+-----omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----++-+-----theorem mem_fiberConst_of_injective
-----++-+-----    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
-----++-+-----    g ∈ FiberConst φ := by
-----++-+-----  intro x x' h; exact congrArg g (hφ h)
-----++-+----+/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
-----++-+----+theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
-----++-+----+  unfold softplus logisticSigmoid
-----++-+----+  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
-----++-+----+  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
-----++-+----+  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
-----++-+----+  simp at this
-----++-+----+  exact this
-----++-+---- 
-----++-+-----omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----++-+-----theorem fiberConst_eq_top_of_injective
-----++-+-----    (φ : C(X, Y)) (hφ : Function.Injective φ) :
-----++-+-----    FiberConst φ = ⊤ := by
-----++-+-----  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
-----++-+----+/-- ShefferAlg is closed under affine pre-composition. -/
-----++-+----+theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
-----++-+----+    (fun x => f (a * x + b)) ∈ ShefferAlg := by
-----++-+----+  obtain ⟨e, rfl⟩ := hf
-----++-+----+  exact ⟨.affinePrecomp a b e, rfl⟩
-----++-+---- 
-----++-+-----omit [CompactSpace Y] [T2Space Y] in
-----++-+-----/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
-----++-+-----theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
-----++-+-----    FiberConst φ = ⊤ ↔ Function.Injective φ := by
-----++-+-----  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
-----++-+-----  intro x x' hφ; by_contra h_ne
-----++-+-----  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
-----++-+-----    have := exists_continuous_zero_one_of_isClosed
-----++-+-----      (show IsClosed {x} from isClosed_singleton)
-----++-+-----      (show IsClosed {x'} from isClosed_singleton) (by aesop)
-----++-+-----    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
-----++-+-----      this.choose_spec.2.1 (Set.mem_singleton x')⟩
-----++-+-----  replace h := SetLike.ext_iff.mp h g
-----++-+-----  simp_all +decide [FiberConst]
-----++-+-----  exact absurd (h hφ) (by simp +decide [hg])
-----++-+----+/-- ShefferAlg is closed under affine combination. -/
-----++-+----+theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
-----++-+----+    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
-----++-+----+  obtain ⟨ef, rfl⟩ := hf
-----++-+----+  obtain ⟨eg, rfl⟩ := hg
-----++-+----+  exact ⟨.affineComb α β γ ef eg, rfl⟩
-----++-+---- 
-----++-+-----/-! ### §2: Image factorization -/
-----++-+----+/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
-----++-+----+theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
-----++-+----+  unfold softplus
-----++-+----+  rw [Real.exp_neg]
-----++-+----+  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
-----++-+----+  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----++-+----+  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
-----++-+----+  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
-----++-+----+  rw [this, Real.log_exp]
-----++-+---- 
-----++-+-----instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
-----++-+-----  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
-----++-+-----
-----++-+-----/-
-----++-+-----The corestriction `X → Set.range φ` is a quotient map.
-----++-+------/
-----++-+-----theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
-----++-+-----    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
-----++-+-----  apply IsClosedMap.isQuotientMap;
-----++-+-----  · intro s hs;
-----++-+-----    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
-----++-+-----    constructor <;> intro h;
-----++-+-----    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
-----++-+-----    · convert h.preimage ( continuous_subtype_val ) using 1;
-----++-+-----      ext; simp [Set.rangeFactorization];
-----++-+-----      grind;
-----++-+-----  · exact continuous_induced_rng.mpr φ.continuous;
-----++-+-----  · exact Set.rangeFactorization_surjective
-----++-+-----
-----++-+-----/-- Lift a fiber-constant function to `Set.range φ`. -/
-----++-+-----noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
-----++-+-----    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
-----++-+-----  toFun z := g z.property.choose
-----++-+-----  continuous_toFun := by
-----++-+-----    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
-----++-+-----    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
-----++-+-----    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
-----++-+-----      ext x; apply hg
-----++-+-----      exact (Set.rangeFactorization φ x).property.choose_spec
-----++-+-----    rw [this]; exact g.continuous
-----++-+-----
-----++-+-----theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
-----++-+-----    (hg : g ∈ FiberConst φ) (x : X) :
-----++-+-----    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
-----++-+-----  simp only [fiberConstLift]
-----++-+-----  apply hg
-----++-+-----  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
-----++-+-----
-----++-+-----/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
-----++-+-----theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
-----++-+-----    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
-----++-+-----  intro g hg
-----++-+-----  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
-----++-+-----  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
-----++-+-----    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
-----++-+-----  refine ⟨F, ?_⟩
-----++-+-----  ext x
-----++-+-----  simp only [pullbackAlg_apply]
-----++-+-----  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
-----++-+-----    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
-----++-+-----    simp [ContinuousMap.comp_apply] at this; exact this
-----++-+-----  rw [key, fiberConstLift_comp]
-----++-+-----
-----++-+-----/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
-----++-+-----theorem fiberConst_eq_range_pullback_of_surjective
-----++-+-----    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
-----++-+-----    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
-----++-+-----  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
-----++-+-----    (range_pullback_subset_fiberConst φ)
-----++-+-----
-----++-+-----/-! ### §3: Density transport -/
-----++-+-----
-----++-+-----/-
-----++-+-----The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
-----++-+------/
-----++-+-----theorem closure_range_pullback_eq_fiberConst
-----++-+-----    (φ : C(X, Y))
-----++-+-----    (A : Subalgebra ℝ C(Y, ℝ))
-----++-+-----    (hA : Dense (A : Set C(Y, ℝ))) :
-----++-+-----    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
-----++-+-----      = (FiberConst φ : Set C(X, ℝ)) := by
-----++-+-----  refine' le_antisymm ( closure_minimal _ _ ) _;
-----++-+-----  · exact range_comp_subalgebra_subset_fiberConst φ A;
-----++-+-----  · exact fiberConst_closed φ;
-----++-+-----  · intro g hg;
-----++-+-----    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
-----++-+-----    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
-----++-+-----      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
-----++-+-----    rw [ Metric.mem_closure_iff ];
-----++-+-----    intro ε εpos;
-----++-+-----    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
-----++-+-----    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
-----++-+-----    nontriviality;
-----++-+-----    rw [ hF, dist_eq_norm ] at *;
-----++-+-----    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
-----++-+-----
-----++-+-----/-
-----++-+-----Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
-----++-+------/
-----++-+-----theorem closure_range_pullback_eq_top_of_injective
-----++-+-----    (φ : C(X, Y))
-----++-+-----    (hφ : Function.Injective φ)
-----++-+-----    (A : Subalgebra ℝ C(Y, ℝ))
-----++-+-----    (hA : Dense (A : Set C(Y, ℝ))) :
-----++-+-----    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
-----++-+-----  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
-----++-+-----  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
-----++-+-----
-----++-+-----/-! ### §4: ε-approximation -/
-----++-+-----
-----++-+-----/-
-----++-+-----ε-approximation within `FiberConst φ`.
-----++-+------/
-----++-+-----theorem exists_pullback_approx_of_fiberConst
-----++-+-----    (φ : C(X, Y))
-----++-+-----    (A : Subalgebra ℝ C(Y, ℝ))
-----++-+-----    (hA : Dense (A : Set C(Y, ℝ)))
-----++-+-----    (g : C(X, ℝ))
-----++-+-----    (hg : g ∈ FiberConst φ)
-----++-+-----    {ε : ℝ} (hε : 0 < ε) :
-----++-+-----    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----++-+-----  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
-----++-+-----    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
-----++-+-----  rw [ Metric.mem_closure_iff ] at h_closure;
-----++-+-----  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
-----++-+-----
-----++-+-----/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
-----++-+-----theorem exists_pullback_approx_of_injective
-----++-+-----    (φ : C(X, Y))
-----++-+-----    (hφ : Function.Injective φ)
-----++-+-----    (A : Subalgebra ℝ C(Y, ℝ))
-----++-+-----    (hA : Dense (A : Set C(Y, ℝ)))
-----++-+-----    (g : C(X, ℝ))
-----++-+-----    {ε : ℝ} (hε : 0 < ε) :
-----++-+-----    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----++-+-----  exact exists_pullback_approx_of_fiberConst φ A hA g
-----++-+-----    (mem_fiberConst_of_injective φ hφ g) hε+end+/-
-----++-+---+Copyright (c) 2025. All rights reserved.
-----++-+---+Released under Apache 2.0 license as described in the file LICENSE.
-----++-+---+-/
-----++-+---+import Mathlib
-----++-+---+
-----++-+---+/-!
-----++-+---+# GL₃ Tropical Satake: Core Definitions
-----++-+---+
-----++-+---+This file establishes the foundational types and operations for the GL₃ tropical
-----++-+---+Satake finite-determinacy theory.
-----++-+---+
-----++-+---+## Overview
-----++-+---+
-----++-+---+For GL₃, a **dominant coweight** is a triple `(a, b, c) ∈ ℕ³` with `a ≥ b ≥ c`.
-----++-+---+The **dominant box** `BoxDom(B)` is the finite set of dominant coweights with `a ≤ B`.
-----++-+---+
-----++-+---+We define three families of **tropical Satake observables**, corresponding to the
-----++-+---+three fundamental representations `ω₁, ω₂, ω₃` of GL₃:
-----++-+---+
-----++-+---+1. **Rank-1 profile** (`rank1Profile`): tropical convolution with the standard
-----++-+---+   representation character. Uses the weights `e₁, e₂, e₃`.
-----++-+---+2. **Rank-2 profile** (`rank2Profile`): tropical convolution with the exterior square
-----++-+---+   character. Uses the weights `e₁+e₂, e₁+e₃, e₂+e₃`.
-----++-+---+3. **Edge moment** (`edgeMoment`): tropical convolution with the determinant character
-----++-+---+   `ω₃ = (1,1,1)`. This is the key reconstruction tool: as a shift operator, it
-----++-+---+   recovers function values without the information loss inherent in max operations.
-----++-+---+
-----++-+---+The finite-determinacy theorem (proved in `FiniteDeterminacy.lean`) shows that
-----++-+---+equality of these observables on finite test sets forces equality of the underlying
-----++-+---+functions.
-----++-+---+-/
-----++-+---+
-----++-+---+open Finset
-----++-+---+
-----++-+---+/-! ### Dominance and support conditions -/
-----++-+---+
-----++-+---+/-- A triple `(a, b, c)` is dominant if `a ≥ b ≥ c`. -/
-----++-+---+def IsDominant (a b c : ℕ) : Prop := b ≤ a ∧ c ≤ b
-----++-+---+
-----++-+---+/-- A function on `ℕ³` has finite support within box `B` if it vanishes outside
-----++-+---+    the dominant box `{(a,b,c) : b ≤ a, c ≤ b, a ≤ B}`. -/
-----++-+---+def FiniteSupportWithin (B : ℕ) (f : ℕ → ℕ → ℕ → ℤ) : Prop :=
-----++-+---+  ∀ a b c : ℕ, (B < a ∨ a < b ∨ b < c) → f a b c = 0
-----++-+---+
-----++-+---+/-- The box `BoxDom(B)` as a `Finset` of triples. -/
-----++-+---+def boxDomFinset (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
-----++-+---+  (Finset.range (B + 1) ×ˢ Finset.range (B + 1) ×ˢ Finset.range (B + 1)).filter
-----++-+---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
-----++-+---+
-----++-+---+lemma mem_boxDomFinset {B : ℕ} {a b c : ℕ} :
-----++-+---+    (a, b, c) ∈ boxDomFinset B ↔ a ≤ B ∧ b ≤ a ∧ c ≤ b := by
-----++-+---+  simp [boxDomFinset, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
-----++-+---+  omega
-----++-+---+
-----++-+---+/-! ### Tropical Satake observables -/
-----++-+---+
-----++-+---+/-- **Rank-1 profile**: tropical convolution with the standard representation `ω₁`.
-----++-+---+
-----++-+---+The weights of the standard representation of GL₃ are `e₁ = (1,0,0)`,
-----++-+---+`e₂ = (0,1,0)`, `e₃ = (0,0,1)`. The rank-1 profile at `(a,b,c)` is
-----++-+---+`max{f(a-1,b,c), f(a,b-1,c), f(a,b,c-1)}` with appropriate guards for ℕ subtraction.
-----++-+---+
-----++-+---+Note: Invalid shifts (where subtraction would go below 0) contribute the value `0`,
-----++-+---+which serves as the tropical "zero" in this ℤ-valued model. -/
-----++-+---+def rank1Profile (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
-----++-+---+  let v1 := if 1 ≤ a then f (a - 1) b c else 0
-----++-+---+  let v2 := if 1 ≤ b then f a (b - 1) c else 0
-----++-+---+  let v3 := if 1 ≤ c then f a b (c - 1) else 0
-----++-+---+  max v1 (max v2 v3)
-----++-+---+
-----++-+---+/-- **Rank-2 profile**: tropical convolution with the exterior square `ω₂ = ∧²`.
-----++-+---+
-----++-+---+The weights of `∧²(ℂ³)` are `e₁+e₂ = (1,1,0)`, `e₁+e₃ = (1,0,1)`,
-----++-+---+`e₂+e₃ = (0,1,1)`. The rank-2 profile at `(a,b,c)` is
-----++-+---+`max{f(a-1,b-1,c), f(a-1,b,c-1), f(a,b-1,c-1)}`. -/
-----++-+---+def rank2Profile (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
-----++-+---+  let v1 := if 1 ≤ a ∧ 1 ≤ b then f (a - 1) (b - 1) c else 0
-----++-+---+  let v2 := if 1 ≤ a ∧ 1 ≤ c then f (a - 1) b (c - 1) else 0
-----++-+---+  let v3 := if 1 ≤ b ∧ 1 ≤ c then f a (b - 1) (c - 1) else 0
-----++-+---+  max v1 (max v2 v3)
-----++-+---+
-----++-+---+/-- **Edge moment**: tropical convolution with the determinant character `ω₃ = (1,1,1)`.
-----++-+---+
-----++-+---+This is the shift operator: `edgeMoment f (a,b,c) = f(a-1, b-1, c-1)`.
-----++-+---+As a representation-theoretic operation, it corresponds to convolution with the
-----++-+---+one-dimensional determinant representation `det = ∧³(ℂ³)`. Unlike the rank-1 and
-----++-+---+rank-2 profiles (which use `max` and can lose information), the determinant
-----++-+---+convolution perfectly preserves all function values.
-----++-+---+
-----++-+---+This is the key observable that makes finite determinacy possible: it acts as an
-----++-+---+exact reconstruction tool rather than a lossy tropical projection. -/
-----++-+---+def edgeMoment (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
-----++-+---+  if 1 ≤ a ∧ 1 ≤ b ∧ 1 ≤ c then f (a - 1) (b - 1) (c - 1) else 0
-----++-+---+
-----++-+---+/-- Combined triple convolution observable using both rank-1 and rank-2 generators.
-----++-+---+    This packages rank-1 and rank-2 data together for the combined hypothesis form. -/
-----++-+---+def tripleConvObservable (f : ℕ → ℕ → ℕ → ℤ) (t s : ℕ × ℕ × ℕ) : ℤ :=
-----++-+---+  rank1Profile f t.1 t.2.1 t.2.2 + rank2Profile f s.1 s.2.1 s.2.2
-----++-+---+
-----++-+---+/-! ### Finite test ranges -/
-----++-+---+
-----++-+---+/-- The finite range of rank-1 test parameters determined by box bound `B`. -/
-----++-+---+def finiteRank1Range (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
-----++-+---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
-----++-+---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
-----++-+---+
-----++-+---+/-- The finite range of rank-2 test parameters determined by box bound `B`. -/
-----++-+---+def finiteRank2Range (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
-----++-+---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
-----++-+---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
-----++-+---+
-----++-+---+/-- The finite range of edge moment test parameters determined by box bound `B`.
-----++-+---+    These are the shifted dominant coweights `(a+1, b+1, c+1)` for `(a,b,c) ∈ BoxDom(B)`. -/
-----++-+---+def finiteEdgeMomentRange (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
-----++-+---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
-----++-+---+    fun ⟨a, b, c⟩ => 1 ≤ c ∧ c ≤ b ∧ b ≤ a
-----++-+---+
-----++-+---+/-! ### Key computation lemmas -/
-----++-+---+
-----++-+---+/-- The edge moment at a shifted point exactly recovers the function value.
-----++-+---+    This is the fundamental reconstruction identity. -/
-----++-+---+@[simp]
-----++-+---+lemma edgeMoment_succ (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) :
-----++-+---+    edgeMoment f (a + 1) (b + 1) (c + 1) = f a b c := by
-----++-+---+  simp [edgeMoment]
-----++-+---+
-----++-+---+/-- Shifted dominant coweights lie in the edge moment range. -/
-----++-+---+lemma shifted_mem_finiteEdgeMomentRange {B a b c : ℕ}
-----++-+---+    (haB : a ≤ B) (hab : b ≤ a) (hbc : c ≤ b) :
-----++-+---+    (a + 1, b + 1, c + 1) ∈ finiteEdgeMomentRange B := by
-----++-+---+  simp [finiteEdgeMomentRange, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
-----++-+---+  omega
-----++-+---+
-----++-+---+/-- The rank-2 profile at the floor level `(a+1, b+1, 0)` yields `max(f(a,b,0), 0)`.
-----++-+---+    When `f` is nonneg-valued on the floor, this equals `f(a,b,0)`.
-----++-+---+    The `c = 0` case is special because both `ω₂`-weight shifts involving `c-1`
-----++-+---+    fall outside `ℕ`, leaving only the `(1,1,0)`-weight shift. -/
-----++-+---+lemma rank2Profile_floor_level (f : ℕ → ℕ → ℕ → ℤ) (a b : ℕ) :
-----++-+---+    rank2Profile f (a + 1) (b + 1) 0 = max (f a b 0) 0 := by
-----++-+---+  simp [rank2Profile]
-----++-+---+
-----++-+---+/-- For functions supported in `BoxDom(B)`, values at `a > B` vanish. -/
-----++-+---+lemma FiniteSupportWithin.vanish_above {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
-----++-+---+    (hf : FiniteSupportWithin B f) {a : ℕ} (ha : B < a) (b c : ℕ) :
-----++-+---+    f a b c = 0 := by
-----++-+---+  exact hf a b c (Or.inl ha)
-----++-+---+
-----++-+---+/-- For functions supported in `BoxDom(B)`, values outside dominant cone vanish. -/
-----++-+---+lemma FiniteSupportWithin.vanish_nondominant {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
-----++-+---+    (hf : FiniteSupportWithin B f) {a b c : ℕ} (h : a < b ∨ b < c) :
-----++-+---+    f a b c = 0 := by
-----++-+---+  exact hf a b c (by tauto)
-----++-+---+
-----++-+---+/-- Bounded-support functions vanish outside the box: explicit formulation. -/
-----++-+---+lemma bounded_support_implies_vanishing_outside {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
-----++-+---+    (hf : FiniteSupportWithin B f) {a b c : ℕ}
-----++-+---+    (h : ¬(a ≤ B ∧ b ≤ a ∧ c ≤ b)) :
-----++-+---+    f a b c = 0 := by
-----++-+---+  apply hf; push_neg at h; omega+--- a/EML/Basic.lean
-----++-+--++++ b/EML/Basic.lean
-----++-+--+@@ -1,277 +1,125 @@
-----++-+--+-/-
-----++-+--+-Copyright (c) 2026 Harmonic. All rights reserved.
-----++-+--+-Released under Apache 2.0 license as described in the file LICENSE.
-----++-+--+--/
-----++-+--+ import Mathlib
-----++-+--+ 
-----++-+--+-/-!
-----++-+--+-# Pullback Stability of Universal Approximation
-----++-+--++/-! # CatalogBuild.EML.Basic
-----++-+--+ 
-----++-+--+-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
-----++-+--+-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
-----++-+--+-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
-----++-+--+-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
-----++-+--+-
-----++-+--+-This establishes a transport principle: universal approximation results (like
-----++-+--+-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
-----++-+--+-with the precise target being the fiber-constant functions.
-----++-+--+-
-----++-+--+-## Main definitions
-----++-+--+-
-----++-+--+-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
-----++-+--+-  fibers of `φ`.
-----++-+--+-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
-----++-+--+-
-----++-+--+-## Main results
-----++-+--+-
-----++-+--+-### Basic properties (§1)
-----++-+--+-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
-----++-+--+-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
-----++-+--+-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
-----++-+--+-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
-----++-+--+-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
-----++-+--+-
-----++-+--+-### Factorization (§2)
-----++-+--+-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
-----++-+--+-  through `Set.range φ`, hence is a pullback (via Tietze extension).
-----++-+--+-
-----++-+--+-### Density transport (§3)
-----++-+--+-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
-----++-+--+-  subalgebra equals `FiberConst φ`.
-----++-+--+-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
-----++-+--+-
-----++-+--+-### ε-approximation (§4)
-----++-+--+-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
-----++-+--+-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
-----++-+--++Auto-generated from theorem catalog database.
-----++-+--++Domain: EML
-----++-+--++Declarations: 15
-----++-+--+ -/
-----++-+--+ 
-----++-+--+-open scoped Topology
-----++-+--+-open Topology
-----++-+--++noncomputable section
-----++-+--+ 
-----++-+--+-variable {X Y : Type*}
-----++-+--+-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
-----++-+--+-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
-----++-+--++/-- The inverse for hyperbolic SPB is also negation. -/
-----++-+--++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
-----++-+--++  simp [spbH]
-----++-+--+ 
-----++-+--+-/-! ### §1: Definitions and basic properties -/
-----++-+--++/-- Wick duality: SPB with negated second argument equals the "difference"
-----++-+--++in the hyperbolic SPB. This is the real-variable manifestation of the
-----++-+--++Wick rotation t → it. -/
-----++-+--++theorem wick_duality (x y : ℝ) :
-----++-+--++    spb x (-y) = (x - y) / (1 + x * y) := by
-----++-+--++  simp only [spb]
-----++-+--++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
-----++-+--++  rw [heq]; ring
-----++-+--+ 
-----++-+--+-/-- Continuous functions on `X` that are constant on fibers of `φ`.
-----++-+--+-This is the natural functional-analytic object associated to a feature map:
-----++-+--+-it captures exactly the observables visible through `φ`. -/
-----++-+--+-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
-----++-+--+-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
-----++-+--+-  algebraMap_mem' r := by intro x x' _; simp
-----++-+--+-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----++-+--+-  zero_mem' := by intro x x' _; simp
-----++-+--+-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----++-+--+-  one_mem' := by intro x x' _; simp
-----++-+--++/-- The tangent addition law IS the stereographic sum.
-----++-+--++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
-----++-+--++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
-----++-+--++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
-----++-+--++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
-----++-+--++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
-----++-+--++  field_simp
-----++-+--+ 
-----++-+--+-/-- Pullback of continuous real-valued functions along `φ`. -/
-----++-+--+-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
-----++-+--+-  toFun f := f.comp φ
-----++-+--+-  map_zero' := by ext; simp
-----++-+--+-  map_one' := by ext; simp
-----++-+--+-  map_add' := by intros; ext; simp
-----++-+--+-  map_mul' := by intros; ext; simp
-----++-+--+-  commutes' := by intros; ext; simp
-----++-+--++/-- SPB expression trees — analogous to EML expression trees. -/
-----++-+--++inductive SPBExpr where
-----++-+--++  | zero : SPBExpr
-----++-+--++  | one : SPBExpr
-----++-+--++  | var : ℕ → SPBExpr
-----++-+--++  | node : SPBExpr → SPBExpr → SPBExpr
-----++-+--++  deriving Repr, BEq
-----++-+--+ 
-----++-+--+-@[simp]
-----++-+--+-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
-----++-+--+-    pullbackAlg φ f x = f (φ x) := rfl
-----++-+--++/-- Evaluate an SPB expression. -/
-----++-+--++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
-----++-+--++  match e with
-----++-+--++  | .zero => 0
-----++-+--++  | .one => 1
-----++-+--++  | .var n => vars n
-----++-+--++  | .node l r => spb (l.eval vars) (r.eval vars)
-----++-+--+ 
-----++-+--+-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----++-+--+-    pullbackAlg φ f ∈ FiberConst φ := by
-----++-+--+-  intro x x' h; simp [h]
-----++-+--++/-- Depth of an SPB expression. -/
-----++-+--++def SPBExpr.depth : SPBExpr → ℕ
-----++-+--++  | .zero => 0
-----++-+--++  | .one => 0
-----++-+--++  | .var _ => 0
-----++-+--++  | .node l r => 1 + max l.depth r.depth
-----++-+--+ 
-----++-+--+-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
-----++-+--+-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----++-+--+-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
-----++-+--++/-- Leaf count. -/
-----++-+--++def SPBExpr.leafCount : SPBExpr → ℕ
-----++-+--++  | .zero => 1
-----++-+--++  | .one => 1
-----++-+--++  | .var _ => 1
-----++-+--++  | .node l r => l.leafCount + r.leafCount
-----++-+--+ 
-----++-+--+-theorem range_comp_subalgebra_subset_fiberConst
-----++-+--+-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
-----++-+--+-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----++-+--+-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
-----++-+--++/-- Internal node count. -/
-----++-+--++def SPBExpr.nodeCount : SPBExpr → ℕ
-----++-+--++  | .zero => 0
-----++-+--++  | .one => 0
-----++-+--++  | .var _ => 0
-----++-+--++  | .node l r => 1 + l.nodeCount + r.nodeCount
-----++-+--+ 
-----++-+--+-/-- `FiberConst φ` is closed in the uniform topology. -/
-----++-+--+-theorem fiberConst_closed (φ : C(X, Y)) :
-----++-+--+-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
-----++-+--+-  refine isClosed_of_closure_subset ?_
-----++-+--+-  intro g hg x x' h
-----++-+--+-  rw [mem_closure_iff_nhds] at hg
-----++-+--+-  contrapose! hg
-----++-+--+-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
-----++-+--+-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
-----++-+--+-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
-----++-+--++/-- Binary tree identity: leaves = internal nodes + 1. -/
-----++-+--++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
-----++-+--++    e.leafCount = e.nodeCount + 1 := by
-----++-+--++  induction e with
-----++-+--++  | zero => rfl
-----++-+--++  | one => rfl
-----++-+--++  | var _ => rfl
-----++-+--++  | node l r ihl ihr =>
-----++-+--++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
-----++-+--++    omega
-----++-+--+ 
-----++-+--+-omit [T2Space X] [T2Space Y] in
-----++-+--+-/-- The pullback map is norm-nonincreasing. -/
-----++-+--+-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----++-+--+-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
-----++-+--+-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
-----++-+--+-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
-----++-+--++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
-----++-+--++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
-----++-+--+ 
-----++-+--+-/-- When `φ` is surjective, pullback is an isometry. -/
-----++-+--+-theorem pullback_isometry_of_surjective
-----++-+--+-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
-----++-+--+-    ‖pullbackAlg φ f‖ = ‖f‖ := by
-----++-+--+-  refine le_antisymm (norm_pullback_le φ f) ?_
-----++-+--+-  rw [ContinuousMap.norm_le _ (by positivity)]
-----++-+--+-  intro y; obtain ⟨x, rfl⟩ := hφ y
-----++-+--+-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
-----++-+--++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
-----++-+--++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
-----++-+--++  unfold logisticSigmoid
-----++-+--++  rw [Real.exp_neg]
-----++-+--++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
-----++-+--++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
-----++-+--++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----++-+--++  field_simp; ring
-----++-+--+ 
-----++-+--+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----++-+--+-theorem mem_fiberConst_of_injective
-----++-+--+-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
-----++-+--+-    g ∈ FiberConst φ := by
-----++-+--+-  intro x x' h; exact congrArg g (hφ h)
-----++-+--++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
-----++-+--++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
-----++-+--++  unfold softplus logisticSigmoid
-----++-+--++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
-----++-+--++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
-----++-+--++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
-----++-+--++  simp at this
-----++-+--++  exact this
-----++-+--+ 
-----++-+--+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----++-+--+-theorem fiberConst_eq_top_of_injective
-----++-+--+-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
-----++-+--+-    FiberConst φ = ⊤ := by
-----++-+--+-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
-----++-+--++/-- ShefferAlg is closed under affine pre-composition. -/
-----++-+--++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
-----++-+--++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
-----++-+--++  obtain ⟨e, rfl⟩ := hf
-----++-+--++  exact ⟨.affinePrecomp a b e, rfl⟩
-----++-+--+ 
-----++-+--+-omit [CompactSpace Y] [T2Space Y] in
-----++-+--+-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
-----++-+--+-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
-----++-+--+-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
-----++-+--+-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
-----++-+--+-  intro x x' hφ; by_contra h_ne
-----++-+--+-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
-----++-+--+-    have := exists_continuous_zero_one_of_isClosed
-----++-+--+-      (show IsClosed {x} from isClosed_singleton)
-----++-+--+-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
-----++-+--+-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
-----++-+--+-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
-----++-+--+-  replace h := SetLike.ext_iff.mp h g
-----++-+--+-  simp_all +decide [FiberConst]
-----++-+--+-  exact absurd (h hφ) (by simp +decide [hg])
-----++-+--++/-- ShefferAlg is closed under affine combination. -/
-----++-+--++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
-----++-+--++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
-----++-+--++  obtain ⟨ef, rfl⟩ := hf
-----++-+--++  obtain ⟨eg, rfl⟩ := hg
-----++-+--++  exact ⟨.affineComb α β γ ef eg, rfl⟩
-----++-+--+ 
-----++-+--+-/-! ### §2: Image factorization -/
-----++-+--++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
-----++-+--++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
-----++-+--++  unfold softplus
-----++-+--++  rw [Real.exp_neg]
-----++-+--++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
-----++-+--++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----++-+--++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
-----++-+--++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
-----++-+--++  rw [this, Real.log_exp]
-----++-+--+ 
-----++-+--+-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
-----++-+--+-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
-----++-+--+-
-----++-+--+-/-
-----++-+--+-The corestriction `X → Set.range φ` is a quotient map.
-----++-+--+--/
-----++-+--+-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
-----++-+--+-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
-----++-+--+-  apply IsClosedMap.isQuotientMap;
-----++-+--+-  · intro s hs;
-----++-+--+-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
-----++-+--+-    constructor <;> intro h;
-----++-+--+-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
-----++-+--+-    · convert h.preimage ( continuous_subtype_val ) using 1;
-----++-+--+-      ext; simp [Set.rangeFactorization];
-----++-+--+-      grind;
-----++-+--+-  · exact continuous_induced_rng.mpr φ.continuous;
-----++-+--+-  · exact Set.rangeFactorization_surjective
-----++-+--+-
-----++-+--+-/-- Lift a fiber-constant function to `Set.range φ`. -/
-----++-+--+-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
-----++-+--+-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
-----++-+--+-  toFun z := g z.property.choose
-----++-+--+-  continuous_toFun := by
-----++-+--+-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
-----++-+--+-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
-----++-+--+-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
-----++-+--+-      ext x; apply hg
-----++-+--+-      exact (Set.rangeFactorization φ x).property.choose_spec
-----++-+--+-    rw [this]; exact g.continuous
-----++-+--+-
-----++-+--+-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
-----++-+--+-    (hg : g ∈ FiberConst φ) (x : X) :
-----++-+--+-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
-----++-+--+-  simp only [fiberConstLift]
-----++-+--+-  apply hg
-----++-+--+-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
-----++-+--+-
-----++-+--+-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
-----++-+--+-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
-----++-+--+-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
-----++-+--+-  intro g hg
-----++-+--+-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
-----++-+--+-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
-----++-+--+-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
-----++-+--+-  refine ⟨F, ?_⟩
-----++-+--+-  ext x
-----++-+--+-  simp only [pullbackAlg_apply]
-----++-+--+-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
-----++-+--+-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
-----++-+--+-    simp [ContinuousMap.comp_apply] at this; exact this
-----++-+--+-  rw [key, fiberConstLift_comp]
-----++-+--+-
-----++-+--+-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
-----++-+--+-theorem fiberConst_eq_range_pullback_of_surjective
-----++-+--+-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
-----++-+--+-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
-----++-+--+-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
-----++-+--+-    (range_pullback_subset_fiberConst φ)
-----++-+--+-
-----++-+--+-/-! ### §3: Density transport -/
-----++-+--+-
-----++-+--+-/-
-----++-+--+-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
-----++-+--+--/
-----++-+--+-theorem closure_range_pullback_eq_fiberConst
-----++-+--+-    (φ : C(X, Y))
-----++-+--+-    (A : Subalgebra ℝ C(Y, ℝ))
-----++-+--+-    (hA : Dense (A : Set C(Y, ℝ))) :
-----++-+--+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
-----++-+--+-      = (FiberConst φ : Set C(X, ℝ)) := by
-----++-+--+-  refine' le_antisymm ( closure_minimal _ _ ) _;
-----++-+--+-  · exact range_comp_subalgebra_subset_fiberConst φ A;
-----++-+--+-  · exact fiberConst_closed φ;
-----++-+--+-  · intro g hg;
-----++-+--+-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
-----++-+--+-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
-----++-+--+-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
-----++-+--+-    rw [ Metric.mem_closure_iff ];
-----++-+--+-    intro ε εpos;
-----++-+--+-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
-----++-+--+-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
-----++-+--+-    nontriviality;
-----++-+--+-    rw [ hF, dist_eq_norm ] at *;
-----++-+--+-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
-----++-+--+-
-----++-+--+-/-
-----++-+--+-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
-----++-+--+--/
-----++-+--+-theorem closure_range_pullback_eq_top_of_injective
-----++-+--+-    (φ : C(X, Y))
-----++-+--+-    (hφ : Function.Injective φ)
-----++-+--+-    (A : Subalgebra ℝ C(Y, ℝ))
-----++-+--+-    (hA : Dense (A : Set C(Y, ℝ))) :
-----++-+--+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
-----++-+--+-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
-----++-+--+-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
-----++-+--+-
-----++-+--+-/-! ### §4: ε-approximation -/
-----++-+--+-
-----++-+--+-/-
-----++-+--+-ε-approximation within `FiberConst φ`.
-----++-+--+--/
-----++-+--+-theorem exists_pullback_approx_of_fiberConst
-----++-+--+-    (φ : C(X, Y))
-----++-+--+-    (A : Subalgebra ℝ C(Y, ℝ))
-----++-+--+-    (hA : Dense (A : Set C(Y, ℝ)))
-----++-+--+-    (g : C(X, ℝ))
-----++-+--+-    (hg : g ∈ FiberConst φ)
-----++-+--+-    {ε : ℝ} (hε : 0 < ε) :
-----++-+--+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----++-+--+-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
-----++-+--+-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
-----++-+--+-  rw [ Metric.mem_closure_iff ] at h_closure;
-----++-+--+-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
-----++-+--+-
-----++-+--+-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
-----++-+--+-theorem exists_pullback_approx_of_injective
-----++-+--+-    (φ : C(X, Y))
-----++-+--+-    (hφ : Function.Injective φ)
-----++-+--+-    (A : Subalgebra ℝ C(Y, ℝ))
-----++-+--+-    (hA : Dense (A : Set C(Y, ℝ)))
-----++-+--+-    (g : C(X, ℝ))
-----++-+--+-    {ε : ℝ} (hε : 0 < ε) :
-----++-+--+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----++-+--+-  exact exists_pullback_approx_of_fiberConst φ A hA g
-----++-+--+-    (mem_fiberConst_of_injective φ hφ g) hε+end+--- a/EML/Basic.lean
-----++-+-++++ b/EML/Basic.lean
-----++-+-+@@ -1,277 +1,125 @@
-----++-+-+-/-
-----++-+-+-Copyright (c) 2026 Harmonic. All rights reserved.
-----++-+-+-Released under Apache 2.0 license as described in the file LICENSE.
-----++-+-+--/
-----++-+-+ import Mathlib
-----++-+-+ 
-----++-+-+-/-!
-----++-+-+-# Pullback Stability of Universal Approximation
-----++-+-++/-! # CatalogBuild.EML.Basic
-----++-+-+ 
-----++-+-+-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
-----++-+-+-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
-----++-+-+-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
-----++-+-+-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
-----++-+-+-
-----++-+-+-This establishes a transport principle: universal approximation results (like
-----++-+-+-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
-----++-+-+-with the precise target being the fiber-constant functions.
-----++-+-+-
-----++-+-+-## Main definitions
-----++-+-+-
-----++-+-+-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
-----++-+-+-  fibers of `φ`.
-----++-+-+-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
-----++-+-+-
-----++-+-+-## Main results
-----++-+-+-
-----++-+-+-### Basic properties (§1)
-----++-+-+-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
-----++-+-+-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
-----++-+-+-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
-----++-+-+-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
-----++-+-+-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
-----++-+-+-
-----++-+-+-### Factorization (§2)
-----++-+-+-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
-----++-+-+-  through `Set.range φ`, hence is a pullback (via Tietze extension).
-----++-+-+-
-----++-+-+-### Density transport (§3)
-----++-+-+-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
-----++-+-+-  subalgebra equals `FiberConst φ`.
-----++-+-+-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
-----++-+-+-
-----++-+-+-### ε-approximation (§4)
-----++-+-+-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
-----++-+-+-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
-----++-+-++Auto-generated from theorem catalog database.
-----++-+-++Domain: EML
-----++-+-++Declarations: 15
-----++-+-+ -/
-----++-+-+ 
-----++-+-+-open scoped Topology
-----++-+-+-open Topology
-----++-+-++noncomputable section
-----++-+-+ 
-----++-+-+-variable {X Y : Type*}
-----++-+-+-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
-----++-+-+-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
-----++-+-++/-- The inverse for hyperbolic SPB is also negation. -/
-----++-+-++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
-----++-+-++  simp [spbH]
-----++-+-+ 
-----++-+-+-/-! ### §1: Definitions and basic properties -/
-----++-+-++/-- Wick duality: SPB with negated second argument equals the "difference"
-----++-+-++in the hyperbolic SPB. This is the real-variable manifestation of the
-----++-+-++Wick rotation t → it. -/
-----++-+-++theorem wick_duality (x y : ℝ) :
-----++-+-++    spb x (-y) = (x - y) / (1 + x * y) := by
-----++-+-++  simp only [spb]
-----++-+-++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
-----++-+-++  rw [heq]; ring
-----++-+-+ 
-----++-+-+-/-- Continuous functions on `X` that are constant on fibers of `φ`.
-----++-+-+-This is the natural functional-analytic object associated to a feature map:
-----++-+-+-it captures exactly the observables visible through `φ`. -/
-----++-+-+-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
-----++-+-+-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
-----++-+-+-  algebraMap_mem' r := by intro x x' _; simp
-----++-+-+-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----++-+-+-  zero_mem' := by intro x x' _; simp
-----++-+-+-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----++-+-+-  one_mem' := by intro x x' _; simp
-----++-+-++/-- The tangent addition law IS the stereographic sum.
-----++-+-++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
-----++-+-++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
-----++-+-++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
-----++-+-++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
-----++-+-++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
-----++-+-++  field_simp
-----++-+-+ 
-----++-+-+-/-- Pullback of continuous real-valued functions along `φ`. -/
-----++-+-+-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
-----++-+-+-  toFun f := f.comp φ
-----++-+-+-  map_zero' := by ext; simp
-----++-+-+-  map_one' := by ext; simp
-----++-+-+-  map_add' := by intros; ext; simp
-----++-+-+-  map_mul' := by intros; ext; simp
-----++-+-+-  commutes' := by intros; ext; simp
-----++-+-++/-- SPB expression trees — analogous to EML expression trees. -/
-----++-+-++inductive SPBExpr where
-----++-+-++  | zero : SPBExpr
-----++-+-++  | one : SPBExpr
-----++-+-++  | var : ℕ → SPBExpr
-----++-+-++  | node : SPBExpr → SPBExpr → SPBExpr
-----++-+-++  deriving Repr, BEq
-----++-+-+ 
-----++-+-+-@[simp]
-----++-+-+-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
-----++-+-+-    pullbackAlg φ f x = f (φ x) := rfl
-----++-+-++/-- Evaluate an SPB expression. -/
-----++-+-++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
-----++-+-++  match e with
-----++-+-++  | .zero => 0
-----++-+-++  | .one => 1
-----++-+-++  | .var n => vars n
-----++-+-++  | .node l r => spb (l.eval vars) (r.eval vars)
-----++-+-+ 
-----++-+-+-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----++-+-+-    pullbackAlg φ f ∈ FiberConst φ := by
-----++-+-+-  intro x x' h; simp [h]
-----++-+-++/-- Depth of an SPB expression. -/
-----++-+-++def SPBExpr.depth : SPBExpr → ℕ
-----++-+-++  | .zero => 0
-----++-+-++  | .one => 0
-----++-+-++  | .var _ => 0
-----++-+-++  | .node l r => 1 + max l.depth r.depth
-----++-+-+ 
-----++-+-+-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
-----++-+-+-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----++-+-+-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
-----++-+-++/-- Leaf count. -/
-----++-+-++def SPBExpr.leafCount : SPBExpr → ℕ
-----++-+-++  | .zero => 1
-----++-+-++  | .one => 1
-----++-+-++  | .var _ => 1
-----++-+-++  | .node l r => l.leafCount + r.leafCount
-----++-+-+ 
-----++-+-+-theorem range_comp_subalgebra_subset_fiberConst
-----++-+-+-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
-----++-+-+-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----++-+-+-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
-----++-+-++/-- Internal node count. -/
-----++-+-++def SPBExpr.nodeCount : SPBExpr → ℕ
-----++-+-++  | .zero => 0
-----++-+-++  | .one => 0
-----++-+-++  | .var _ => 0
-----++-+-++  | .node l r => 1 + l.nodeCount + r.nodeCount
-----++-+-+ 
-----++-+-+-/-- `FiberConst φ` is closed in the uniform topology. -/
-----++-+-+-theorem fiberConst_closed (φ : C(X, Y)) :
-----++-+-+-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
-----++-+-+-  refine isClosed_of_closure_subset ?_
-----++-+-+-  intro g hg x x' h
-----++-+-+-  rw [mem_closure_iff_nhds] at hg
-----++-+-+-  contrapose! hg
-----++-+-+-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
-----++-+-+-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
-----++-+-+-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
-----++-+-++/-- Binary tree identity: leaves = internal nodes + 1. -/
-----++-+-++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
-----++-+-++    e.leafCount = e.nodeCount + 1 := by
-----++-+-++  induction e with
-----++-+-++  | zero => rfl
-----++-+-++  | one => rfl
-----++-+-++  | var _ => rfl
-----++-+-++  | node l r ihl ihr =>
-----++-+-++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
-----++-+-++    omega
-----++-+-+ 
-----++-+-+-omit [T2Space X] [T2Space Y] in
-----++-+-+-/-- The pullback map is norm-nonincreasing. -/
-----++-+-+-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----++-+-+-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
-----++-+-+-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
-----++-+-+-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
-----++-+-++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
-----++-+-++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
-----++-+-+ 
-----++-+-+-/-- When `φ` is surjective, pullback is an isometry. -/
-----++-+-+-theorem pullback_isometry_of_surjective
-----++-+-+-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
-----++-+-+-    ‖pullbackAlg φ f‖ = ‖f‖ := by
-----++-+-+-  refine le_antisymm (norm_pullback_le φ f) ?_
-----++-+-+-  rw [ContinuousMap.norm_le _ (by positivity)]
-----++-+-+-  intro y; obtain ⟨x, rfl⟩ := hφ y
-----++-+-+-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
-----++-+-++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
-----++-+-++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
-----++-+-++  unfold logisticSigmoid
-----++-+-++  rw [Real.exp_neg]
-----++-+-++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
-----++-+-++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
-----++-+-++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----++-+-++  field_simp; ring
-----++-+-+ 
-----++-+-+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----++-+-+-theorem mem_fiberConst_of_injective
-----++-+-+-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
-----++-+-+-    g ∈ FiberConst φ := by
-----++-+-+-  intro x x' h; exact congrArg g (hφ h)
-----++-+-++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
-----++-+-++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
-----++-+-++  unfold softplus logisticSigmoid
-----++-+-++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
-----++-+-++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
-----++-+-++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
-----++-+-++  simp at this
-----++-+-++  exact this
-----++-+-+ 
-----++-+-+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----++-+-+-theorem fiberConst_eq_top_of_injective
-----++-+-+-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
-----++-+-+-    FiberConst φ = ⊤ := by
-----++-+-+-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
-----++-+-++/-- ShefferAlg is closed under affine pre-composition. -/
-----++-+-++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
-----++-+-++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
-----++-+-++  obtain ⟨e, rfl⟩ := hf
-----++-+-++  exact ⟨.affinePrecomp a b e, rfl⟩
-----++-+-+ 
-----++-+-+-omit [CompactSpace Y] [T2Space Y] in
-----++-+-+-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
-----++-+-+-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
-----++-+-+-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
-----++-+-+-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
-----++-+-+-  intro x x' hφ; by_contra h_ne
-----++-+-+-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
-----++-+-+-    have := exists_continuous_zero_one_of_isClosed
-----++-+-+-      (show IsClosed {x} from isClosed_singleton)
-----++-+-+-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
-----++-+-+-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
-----++-+-+-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
-----++-+-+-  replace h := SetLike.ext_iff.mp h g
-----++-+-+-  simp_all +decide [FiberConst]
-----++-+-+-  exact absurd (h hφ) (by simp +decide [hg])
-----++-+-++/-- ShefferAlg is closed under affine combination. -/
-----++-+-++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
-----++-+-++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
-----++-+-++  obtain ⟨ef, rfl⟩ := hf
-----++-+-++  obtain ⟨eg, rfl⟩ := hg
-----++-+-++  exact ⟨.affineComb α β γ ef eg, rfl⟩
-----++-+-+ 
-----++-+-+-/-! ### §2: Image factorization -/
-----++-+-++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
-----++-+-++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
-----++-+-++  unfold softplus
-----++-+-++  rw [Real.exp_neg]
-----++-+-++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
-----++-+-++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----++-+-++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
-----++-+-++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
-----++-+-++  rw [this, Real.log_exp]
-----++-+-+ 
-----++-+-+-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
-----++-+-+-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
-----++-+-+-
-----++-+-+-/-
-----++-+-+-The corestriction `X → Set.range φ` is a quotient map.
-----++-+-+--/
-----++-+-+-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
-----++-+-+-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
-----++-+-+-  apply IsClosedMap.isQuotientMap;
-----++-+-+-  · intro s hs;
-----++-+-+-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
-----++-+-+-    constructor <;> intro h;
-----++-+-+-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
-----++-+-+-    · convert h.preimage ( continuous_subtype_val ) using 1;
-----++-+-+-      ext; simp [Set.rangeFactorization];
-----++-+-+-      grind;
-----++-+-+-  · exact continuous_induced_rng.mpr φ.continuous;
-----++-+-+-  · exact Set.rangeFactorization_surjective
-----++-+-+-
-----++-+-+-/-- Lift a fiber-constant function to `Set.range φ`. -/
-----++-+-+-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
-----++-+-+-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
-----++-+-+-  toFun z := g z.property.choose
-----++-+-+-  continuous_toFun := by
-----++-+-+-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
-----++-+-+-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
-----++-+-+-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
-----++-+-+-      ext x; apply hg
-----++-+-+-      exact (Set.rangeFactorization φ x).property.choose_spec
-----++-+-+-    rw [this]; exact g.continuous
-----++-+-+-
-----++-+-+-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
-----++-+-+-    (hg : g ∈ FiberConst φ) (x : X) :
-----++-+-+-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
-----++-+-+-  simp only [fiberConstLift]
-----++-+-+-  apply hg
-----++-+-+-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
-----++-+-+-
-----++-+-+-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
-----++-+-+-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
-----++-+-+-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
-----++-+-+-  intro g hg
-----++-+-+-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
-----++-+-+-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
-----++-+-+-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
-----++-+-+-  refine ⟨F, ?_⟩
-----++-+-+-  ext x
-----++-+-+-  simp only [pullbackAlg_apply]
-----++-+-+-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
-----++-+-+-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
-----++-+-+-    simp [ContinuousMap.comp_apply] at this; exact this
-----++-+-+-  rw [key, fiberConstLift_comp]
-----++-+-+-
-----++-+-+-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
-----++-+-+-theorem fiberConst_eq_range_pullback_of_surjective
-----++-+-+-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
-----++-+-+-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
-----++-+-+-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
-----++-+-+-    (range_pullback_subset_fiberConst φ)
-----++-+-+-
-----++-+-+-/-! ### §3: Density transport -/
-----++-+-+-
-----++-+-+-/-
-----++-+-+-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
-----++-+-+--/
-----++-+-+-theorem closure_range_pullback_eq_fiberConst
-----++-+-+-    (φ : C(X, Y))
-----++-+-+-    (A : Subalgebra ℝ C(Y, ℝ))
-----++-+-+-    (hA : Dense (A : Set C(Y, ℝ))) :
-----++-+-+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
-----++-+-+-      = (FiberConst φ : Set C(X, ℝ)) := by
-----++-+-+-  refine' le_antisymm ( closure_minimal _ _ ) _;
-----++-+-+-  · exact range_comp_subalgebra_subset_fiberConst φ A;
-----++-+-+-  · exact fiberConst_closed φ;
-----++-+-+-  · intro g hg;
-----++-+-+-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
-----++-+-+-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
-----++-+-+-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
-----++-+-+-    rw [ Metric.mem_closure_iff ];
-----++-+-+-    intro ε εpos;
-----++-+-+-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
-----++-+-+-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
-----++-+-+-    nontriviality;
-----++-+-+-    rw [ hF, dist_eq_norm ] at *;
-----++-+-+-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
-----++-+-+-
-----++-+-+-/-
-----++-+-+-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
-----++-+-+--/
-----++-+-+-theorem closure_range_pullback_eq_top_of_injective
-----++-+-+-    (φ : C(X, Y))
-----++-+-+-    (hφ : Function.Injective φ)
-----++-+-+-    (A : Subalgebra ℝ C(Y, ℝ))
-----++-+-+-    (hA : Dense (A : Set C(Y, ℝ))) :
-----++-+-+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
-----++-+-+-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
-----++-+-+-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
-----++-+-+-
-----++-+-+-/-! ### §4: ε-approximation -/
-----++-+-+-
-----++-+-+-/-
-----++-+-+-ε-approximation within `FiberConst φ`.
-----++-+-+--/
-----++-+-+-theorem exists_pullback_approx_of_fiberConst
-----++-+-+-    (φ : C(X, Y))
-----++-+-+-    (A : Subalgebra ℝ C(Y, ℝ))
-----++-+-+-    (hA : Dense (A : Set C(Y, ℝ)))
-----++-+-+-    (g : C(X, ℝ))
-----++-+-+-    (hg : g ∈ FiberConst φ)
-----++-+-+-    {ε : ℝ} (hε : 0 < ε) :
-----++-+-+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----++-+-+-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
-----++-+-+-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
-----++-+-+-  rw [ Metric.mem_closure_iff ] at h_closure;
-----++-+-+-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
-----++-+-+-
-----++-+-+-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
-----++-+-+-theorem exists_pullback_approx_of_injective
-----++-+-+-    (φ : C(X, Y))
-----++-+-+-    (hφ : Function.Injective φ)
-----++-+-+-    (A : Subalgebra ℝ C(Y, ℝ))
-----++-+-+-    (hA : Dense (A : Set C(Y, ℝ)))
-----++-+-+-    (g : C(X, ℝ))
-----++-+-+-    {ε : ℝ} (hε : 0 < ε) :
-----++-+-+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----++-+-+-  exact exists_pullback_approx_of_fiberConst φ A hA g
-----++-+-+-    (mem_fiberConst_of_injective φ hφ g) hε+end+--- a/EML/Basic.lean
-----++-+++++ b/EML/Basic.lean
-----++-++@@ -1,277 +1,125 @@
-----++-++-/-
-----++-++-Copyright (c) 2026 Harmonic. All rights reserved.
-----++-++-Released under Apache 2.0 license as described in the file LICENSE.
-----++-++--/
-----++-++ import Mathlib
-----++-++ 
-----++-++-/-!
-----++-++-# Pullback Stability of Universal Approximation
-----++-+++/-! # CatalogBuild.EML.Basic
-----++-++ 
-----++-++-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
-----++-++-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
-----++-++-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
-----++-++-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
-----++-++-
-----++-++-This establishes a transport principle: universal approximation results (like
-----++-++-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
-----++-++-with the precise target being the fiber-constant functions.
-----++-++-
-----++-++-## Main definitions
-----++-++-
-----++-++-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
-----++-++-  fibers of `φ`.
-----++-++-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
-----++-++-
-----++-++-## Main results
-----++-++-
-----++-++-### Basic properties (§1)
-----++-++-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
-----++-++-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
-----++-++-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
-----++-++-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
-----++-++-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
-----++-++-
-----++-++-### Factorization (§2)
-----++-++-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
-----++-++-  through `Set.range φ`, hence is a pullback (via Tietze extension).
-----++-++-
-----++-++-### Density transport (§3)
-----++-++-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
-----++-++-  subalgebra equals `FiberConst φ`.
-----++-++-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
-----++-++-
-----++-++-### ε-approximation (§4)
-----++-++-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
-----++-++-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
-----++-+++Auto-generated from theorem catalog database.
-----++-+++Domain: EML
-----++-+++Declarations: 15
-----++- + -/
-----++- + 
-----+++--- a/Tropical/Basic.lean
-----++++++ b/Tropical/Basic.lean
-----+++@@ -1,1315 +1,383 @@
-----+++---- a/Tropical/Basic.lean
-----+++-+++ b/Tropical/Basic.lean
-----+++-@@ -1,930 +1,383 @@
-----+++----- a/Tropical/Basic.lean
-----+++--+++ b/Tropical/Basic.lean
-----+++--@@ -1,545 +1,383 @@
-----+++------ a/Tropical/Basic.lean
-----+++---+++ b/Tropical/Basic.lean
-----+++---@@ -1,383 +1,160 @@
-----+++------- a/EML/Basic.lean
-----+++----+++ b/EML/Basic.lean
-----+++----@@ -1,277 +1,125 @@
-----+++-----/-
-----+++-----Copyright (c) 2026 Harmonic. All rights reserved.
-----+++-----Released under Apache 2.0 license as described in the file LICENSE.
-----+++------/
-----+++---- import Mathlib
-----+++---- 
-----+++-----/-!
-----+++-----# Pullback Stability of Universal Approximation
-----+++----+/-! # CatalogBuild.EML.Basic
-----+++---- 
-----+++-----Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
-----+++-----subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
-----+++-----closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
-----+++-----When `φ` is injective, this gives density in all of `C(X, ℝ)`.
-----+++-----
-----+++-----This establishes a transport principle: universal approximation results (like
-----+++-----Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
-----+++-----with the precise target being the fiber-constant functions.
-----+++-----
-----+++-----## Main definitions
-----+++-----
-----+++-----* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
-----+++-----  fibers of `φ`.
-----+++-----* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
-----+++-----
-----+++-----## Main results
-----+++-----
-----+++-----### Basic properties (§1)
-----+++-----* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
-----+++-----* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
-----+++-----* `norm_pullback_le` — the pullback map is norm-nonincreasing.
-----+++-----* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
-----+++-----* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
-----+++-----
-----+++-----### Factorization (§2)
-----+++-----* `fiberConst_subset_range_pullback` — every fiber-constant function factors
-----+++-----  through `Set.range φ`, hence is a pullback (via Tietze extension).
-----+++-----
-----+++-----### Density transport (§3)
-----+++-----* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
-----+++-----  subalgebra equals `FiberConst φ`.
-----+++-----* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
-----+++-----
-----+++-----### ε-approximation (§4)
-----+++-----* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
-----+++-----* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
-----+++----+Auto-generated from theorem catalog database.
-----+++----+Domain: EML
-----+++----+Declarations: 15
-----+++---- -/
-----+++---- 
-----+++-----open scoped Topology
-----+++-----open Topology
-----+++----+noncomputable section
-----+++---- 
-----+++-----variable {X Y : Type*}
-----+++-----variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
-----+++-----variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
-----+++----+/-- The inverse for hyperbolic SPB is also negation. -/
-----+++----+theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
-----+++----+  simp [spbH]
-----+++---- 
-----+++-----/-! ### §1: Definitions and basic properties -/
-----+++----+/-- Wick duality: SPB with negated second argument equals the "difference"
-----+++----+in the hyperbolic SPB. This is the real-variable manifestation of the
-----+++----+Wick rotation t → it. -/
-----+++----+theorem wick_duality (x y : ℝ) :
-----+++----+    spb x (-y) = (x - y) / (1 + x * y) := by
-----+++----+  simp only [spb]
-----+++----+  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
-----+++----+  rw [heq]; ring
-----+++---- 
-----+++-----/-- Continuous functions on `X` that are constant on fibers of `φ`.
-----+++-----This is the natural functional-analytic object associated to a feature map:
-----+++-----it captures exactly the observables visible through `φ`. -/
-----+++-----def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
-----+++-----  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
-----+++-----  algebraMap_mem' r := by intro x x' _; simp
-----+++-----  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----+++-----  zero_mem' := by intro x x' _; simp
-----+++-----  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----+++-----  one_mem' := by intro x x' _; simp
-----+++----+/-- The tangent addition law IS the stereographic sum.
-----+++----+tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
-----+++----+theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
-----+++----+    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
-----+++----+  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
-----+++----+      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
-----+++----+  field_simp
-----+++---- 
-----+++-----/-- Pullback of continuous real-valued functions along `φ`. -/
-----+++-----def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
-----+++-----  toFun f := f.comp φ
-----+++-----  map_zero' := by ext; simp
-----+++-----  map_one' := by ext; simp
-----+++-----  map_add' := by intros; ext; simp
-----+++-----  map_mul' := by intros; ext; simp
-----+++-----  commutes' := by intros; ext; simp
-----+++----+/-- SPB expression trees — analogous to EML expression trees. -/
-----+++----+inductive SPBExpr where
-----+++----+  | zero : SPBExpr
-----+++----+  | one : SPBExpr
-----+++----+  | var : ℕ → SPBExpr
-----+++----+  | node : SPBExpr → SPBExpr → SPBExpr
-----+++----+  deriving Repr, BEq
-----+++---- 
-----+++-----@[simp]
-----+++-----theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
-----+++-----    pullbackAlg φ f x = f (φ x) := rfl
-----+++----+/-- Evaluate an SPB expression. -/
-----+++----+def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
-----+++----+  match e with
-----+++----+  | .zero => 0
-----+++----+  | .one => 1
-----+++----+  | .var n => vars n
-----+++----+  | .node l r => spb (l.eval vars) (r.eval vars)
-----+++---- 
-----+++-----theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----+++-----    pullbackAlg φ f ∈ FiberConst φ := by
-----+++-----  intro x x' h; simp [h]
-----+++----+/-- Depth of an SPB expression. -/
-----+++----+def SPBExpr.depth : SPBExpr → ℕ
-----+++----+  | .zero => 0
-----+++----+  | .one => 0
-----+++----+  | .var _ => 0
-----+++----+  | .node l r => 1 + max l.depth r.depth
-----+++---- 
-----+++-----theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
-----+++-----    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----+++-----  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
-----+++----+/-- Leaf count. -/
-----+++----+def SPBExpr.leafCount : SPBExpr → ℕ
-----+++----+  | .zero => 1
-----+++----+  | .one => 1
-----+++----+  | .var _ => 1
-----+++----+  | .node l r => l.leafCount + r.leafCount
-----+++---- 
-----+++-----theorem range_comp_subalgebra_subset_fiberConst
-----+++-----    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
-----+++-----    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----+++-----  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
-----+++----+/-- Internal node count. -/
-----+++----+def SPBExpr.nodeCount : SPBExpr → ℕ
-----+++----+  | .zero => 0
-----+++----+  | .one => 0
-----+++----+  | .var _ => 0
-----+++----+  | .node l r => 1 + l.nodeCount + r.nodeCount
-----+++---- 
-----+++-----/-- `FiberConst φ` is closed in the uniform topology. -/
-----+++-----theorem fiberConst_closed (φ : C(X, Y)) :
-----+++-----    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
-----+++-----  refine isClosed_of_closure_subset ?_
-----+++-----  intro g hg x x' h
-----+++-----  rw [mem_closure_iff_nhds] at hg
-----+++-----  contrapose! hg
-----+++-----  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
-----+++-----    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
-----+++-----    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
-----+++----+/-- Binary tree identity: leaves = internal nodes + 1. -/
-----+++----+theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
-----+++----+    e.leafCount = e.nodeCount + 1 := by
-----+++----+  induction e with
-----+++----+  | zero => rfl
-----+++----+  | one => rfl
-----+++----+  | var _ => rfl
-----+++----+  | node l r ihl ihr =>
-----+++----+    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
-----+++----+    omega
-----+++---- 
-----+++-----omit [T2Space X] [T2Space Y] in
-----+++-----/-- The pullback map is norm-nonincreasing. -/
-----+++-----theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----+++-----    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
-----+++-----  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
-----+++-----    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
-----+++----+/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
-----+++----+def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
-----+++---- 
-----+++-----/-- When `φ` is surjective, pullback is an isometry. -/
-----+++-----theorem pullback_isometry_of_surjective
-----+++-----    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
-----+++-----    ‖pullbackAlg φ f‖ = ‖f‖ := by
-----+++-----  refine le_antisymm (norm_pullback_le φ f) ?_
-----+++-----  rw [ContinuousMap.norm_le _ (by positivity)]
-----+++-----  intro y; obtain ⟨x, rfl⟩ := hφ y
-----+++-----  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
-----+++----+/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
-----+++----+theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
-----+++----+  unfold logisticSigmoid
-----+++----+  rw [Real.exp_neg]
-----+++----+  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
-----+++----+  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
-----+++----+  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----+++----+  field_simp; ring
-----+++---- 
-----+++-----omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----+++-----theorem mem_fiberConst_of_injective
-----+++-----    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
-----+++-----    g ∈ FiberConst φ := by
-----+++-----  intro x x' h; exact congrArg g (hφ h)
-----+++----+/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
-----+++----+theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
-----+++----+  unfold softplus logisticSigmoid
-----+++----+  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
-----+++----+  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
-----+++----+  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
-----+++----+  simp at this
-----+++----+  exact this
-----+++---- 
-----+++-----omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----+++-----theorem fiberConst_eq_top_of_injective
-----+++-----    (φ : C(X, Y)) (hφ : Function.Injective φ) :
-----+++-----    FiberConst φ = ⊤ := by
-----+++-----  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
-----+++----+/-- ShefferAlg is closed under affine pre-composition. -/
-----+++----+theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
-----+++----+    (fun x => f (a * x + b)) ∈ ShefferAlg := by
-----+++----+  obtain ⟨e, rfl⟩ := hf
-----+++----+  exact ⟨.affinePrecomp a b e, rfl⟩
-----+++---- 
-----+++-----omit [CompactSpace Y] [T2Space Y] in
-----+++-----/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
-----+++-----theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
-----+++-----    FiberConst φ = ⊤ ↔ Function.Injective φ := by
-----+++-----  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
-----+++-----  intro x x' hφ; by_contra h_ne
-----+++-----  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
-----+++-----    have := exists_continuous_zero_one_of_isClosed
-----+++-----      (show IsClosed {x} from isClosed_singleton)
-----+++-----      (show IsClosed {x'} from isClosed_singleton) (by aesop)
-----+++-----    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
-----+++-----      this.choose_spec.2.1 (Set.mem_singleton x')⟩
-----+++-----  replace h := SetLike.ext_iff.mp h g
-----+++-----  simp_all +decide [FiberConst]
-----+++-----  exact absurd (h hφ) (by simp +decide [hg])
-----+++----+/-- ShefferAlg is closed under affine combination. -/
-----+++----+theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
-----+++----+    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
-----+++----+  obtain ⟨ef, rfl⟩ := hf
-----+++----+  obtain ⟨eg, rfl⟩ := hg
-----+++----+  exact ⟨.affineComb α β γ ef eg, rfl⟩
-----+++---- 
-----+++-----/-! ### §2: Image factorization -/
-----+++----+/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
-----+++----+theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
-----+++----+  unfold softplus
-----+++----+  rw [Real.exp_neg]
-----+++----+  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
-----+++----+  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----+++----+  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
-----+++----+  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
-----+++----+  rw [this, Real.log_exp]
-----+++---- 
-----+++-----instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
-----+++-----  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
-----+++-----
-----+++-----/-
-----+++-----The corestriction `X → Set.range φ` is a quotient map.
-----+++------/
-----+++-----theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
-----+++-----    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
-----+++-----  apply IsClosedMap.isQuotientMap;
-----+++-----  · intro s hs;
-----+++-----    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
-----+++-----    constructor <;> intro h;
-----+++-----    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
-----+++-----    · convert h.preimage ( continuous_subtype_val ) using 1;
-----+++-----      ext; simp [Set.rangeFactorization];
-----+++-----      grind;
-----+++-----  · exact continuous_induced_rng.mpr φ.continuous;
-----+++-----  · exact Set.rangeFactorization_surjective
-----+++-----
-----+++-----/-- Lift a fiber-constant function to `Set.range φ`. -/
-----+++-----noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
-----+++-----    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
-----+++-----  toFun z := g z.property.choose
-----+++-----  continuous_toFun := by
-----+++-----    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
-----+++-----    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
-----+++-----    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
-----+++-----      ext x; apply hg
-----+++-----      exact (Set.rangeFactorization φ x).property.choose_spec
-----+++-----    rw [this]; exact g.continuous
-----+++-----
-----+++-----theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
-----+++-----    (hg : g ∈ FiberConst φ) (x : X) :
-----+++-----    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
-----+++-----  simp only [fiberConstLift]
-----+++-----  apply hg
-----+++-----  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
-----+++-----
-----+++-----/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
-----+++-----theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
-----+++-----    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
-----+++-----  intro g hg
-----+++-----  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
-----+++-----  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
-----+++-----    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
-----+++-----  refine ⟨F, ?_⟩
-----+++-----  ext x
-----+++-----  simp only [pullbackAlg_apply]
-----+++-----  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
-----+++-----    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
-----+++-----    simp [ContinuousMap.comp_apply] at this; exact this
-----+++-----  rw [key, fiberConstLift_comp]
-----+++-----
-----+++-----/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
-----+++-----theorem fiberConst_eq_range_pullback_of_surjective
-----+++-----    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
-----+++-----    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
-----+++-----  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
-----+++-----    (range_pullback_subset_fiberConst φ)
-----+++-----
-----+++-----/-! ### §3: Density transport -/
-----+++-----
-----+++-----/-
-----+++-----The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
-----+++------/
-----+++-----theorem closure_range_pullback_eq_fiberConst
-----+++-----    (φ : C(X, Y))
-----+++-----    (A : Subalgebra ℝ C(Y, ℝ))
-----+++-----    (hA : Dense (A : Set C(Y, ℝ))) :
-----+++-----    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
-----+++-----      = (FiberConst φ : Set C(X, ℝ)) := by
-----+++-----  refine' le_antisymm ( closure_minimal _ _ ) _;
-----+++-----  · exact range_comp_subalgebra_subset_fiberConst φ A;
-----+++-----  · exact fiberConst_closed φ;
-----+++-----  · intro g hg;
-----+++-----    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
-----+++-----    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
-----+++-----      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
-----+++-----    rw [ Metric.mem_closure_iff ];
-----+++-----    intro ε εpos;
-----+++-----    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
-----+++-----    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
-----+++-----    nontriviality;
-----+++-----    rw [ hF, dist_eq_norm ] at *;
-----+++-----    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
-----+++-----
-----+++-----/-
-----+++-----Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
-----+++------/
-----+++-----theorem closure_range_pullback_eq_top_of_injective
-----+++-----    (φ : C(X, Y))
-----+++-----    (hφ : Function.Injective φ)
-----+++-----    (A : Subalgebra ℝ C(Y, ℝ))
-----+++-----    (hA : Dense (A : Set C(Y, ℝ))) :
-----+++-----    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
-----+++-----  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
-----+++-----  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
-----+++-----
-----+++-----/-! ### §4: ε-approximation -/
-----+++-----
-----+++-----/-
-----+++-----ε-approximation within `FiberConst φ`.
-----+++------/
-----+++-----theorem exists_pullback_approx_of_fiberConst
-----+++-----    (φ : C(X, Y))
-----+++-----    (A : Subalgebra ℝ C(Y, ℝ))
-----+++-----    (hA : Dense (A : Set C(Y, ℝ)))
-----+++-----    (g : C(X, ℝ))
-----+++-----    (hg : g ∈ FiberConst φ)
-----+++-----    {ε : ℝ} (hε : 0 < ε) :
-----+++-----    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----+++-----  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
-----+++-----    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
-----+++-----  rw [ Metric.mem_closure_iff ] at h_closure;
-----+++-----  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
-----+++-----
-----+++-----/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
-----+++-----theorem exists_pullback_approx_of_injective
-----+++-----    (φ : C(X, Y))
-----+++-----    (hφ : Function.Injective φ)
-----+++-----    (A : Subalgebra ℝ C(Y, ℝ))
-----+++-----    (hA : Dense (A : Set C(Y, ℝ)))
-----+++-----    (g : C(X, ℝ))
-----+++-----    {ε : ℝ} (hε : 0 < ε) :
-----+++-----    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----+++-----  exact exists_pullback_approx_of_fiberConst φ A hA g
-----+++-----    (mem_fiberConst_of_injective φ hφ g) hε+end+/-
-----+++---+Copyright (c) 2025. All rights reserved.
-----+++---+Released under Apache 2.0 license as described in the file LICENSE.
-----+++---+-/
-----+++---+import Mathlib
-----+++---+
-----+++---+/-!
-----+++---+# GL₃ Tropical Satake: Core Definitions
-----+++---+
-----+++---+This file establishes the foundational types and operations for the GL₃ tropical
-----+++---+Satake finite-determinacy theory.
-----+++---+
-----+++---+## Overview
-----+++---+
-----+++---+For GL₃, a **dominant coweight** is a triple `(a, b, c) ∈ ℕ³` with `a ≥ b ≥ c`.
-----+++---+The **dominant box** `BoxDom(B)` is the finite set of dominant coweights with `a ≤ B`.
-----+++---+
-----+++---+We define three families of **tropical Satake observables**, corresponding to the
-----+++---+three fundamental representations `ω₁, ω₂, ω₃` of GL₃:
-----+++---+
-----+++---+1. **Rank-1 profile** (`rank1Profile`): tropical convolution with the standard
-----+++---+   representation character. Uses the weights `e₁, e₂, e₃`.
-----+++---+2. **Rank-2 profile** (`rank2Profile`): tropical convolution with the exterior square
-----+++---+   character. Uses the weights `e₁+e₂, e₁+e₃, e₂+e₃`.
-----+++---+3. **Edge moment** (`edgeMoment`): tropical convolution with the determinant character
-----+++---+   `ω₃ = (1,1,1)`. This is the key reconstruction tool: as a shift operator, it
-----+++---+   recovers function values without the information loss inherent in max operations.
-----+++---+
-----+++---+The finite-determinacy theorem (proved in `FiniteDeterminacy.lean`) shows that
-----+++---+equality of these observables on finite test sets forces equality of the underlying
-----+++---+functions.
-----+++---+-/
-----+++---+
-----+++---+open Finset
-----+++---+
-----+++---+/-! ### Dominance and support conditions -/
-----+++---+
-----+++---+/-- A triple `(a, b, c)` is dominant if `a ≥ b ≥ c`. -/
-----+++---+def IsDominant (a b c : ℕ) : Prop := b ≤ a ∧ c ≤ b
-----+++---+
-----+++---+/-- A function on `ℕ³` has finite support within box `B` if it vanishes outside
-----+++---+    the dominant box `{(a,b,c) : b ≤ a, c ≤ b, a ≤ B}`. -/
-----+++---+def FiniteSupportWithin (B : ℕ) (f : ℕ → ℕ → ℕ → ℤ) : Prop :=
-----+++---+  ∀ a b c : ℕ, (B < a ∨ a < b ∨ b < c) → f a b c = 0
-----+++---+
-----+++---+/-- The box `BoxDom(B)` as a `Finset` of triples. -/
-----+++---+def boxDomFinset (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
-----+++---+  (Finset.range (B + 1) ×ˢ Finset.range (B + 1) ×ˢ Finset.range (B + 1)).filter
-----+++---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
-----+++---+
-----+++---+lemma mem_boxDomFinset {B : ℕ} {a b c : ℕ} :
-----+++---+    (a, b, c) ∈ boxDomFinset B ↔ a ≤ B ∧ b ≤ a ∧ c ≤ b := by
-----+++---+  simp [boxDomFinset, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
-----+++---+  omega
-----+++---+
-----+++---+/-! ### Tropical Satake observables -/
-----+++---+
-----+++---+/-- **Rank-1 profile**: tropical convolution with the standard representation `ω₁`.
-----+++---+
-----+++---+The weights of the standard representation of GL₃ are `e₁ = (1,0,0)`,
-----+++---+`e₂ = (0,1,0)`, `e₃ = (0,0,1)`. The rank-1 profile at `(a,b,c)` is
-----+++---+`max{f(a-1,b,c), f(a,b-1,c), f(a,b,c-1)}` with appropriate guards for ℕ subtraction.
-----+++---+
-----+++---+Note: Invalid shifts (where subtraction would go below 0) contribute the value `0`,
-----+++---+which serves as the tropical "zero" in this ℤ-valued model. -/
-----+++---+def rank1Profile (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
-----+++---+  let v1 := if 1 ≤ a then f (a - 1) b c else 0
-----+++---+  let v2 := if 1 ≤ b then f a (b - 1) c else 0
-----+++---+  let v3 := if 1 ≤ c then f a b (c - 1) else 0
-----+++---+  max v1 (max v2 v3)
-----+++---+
-----+++---+/-- **Rank-2 profile**: tropical convolution with the exterior square `ω₂ = ∧²`.
-----+++---+
-----+++---+The weights of `∧²(ℂ³)` are `e₁+e₂ = (1,1,0)`, `e₁+e₃ = (1,0,1)`,
-----+++---+`e₂+e₃ = (0,1,1)`. The rank-2 profile at `(a,b,c)` is
-----+++---+`max{f(a-1,b-1,c), f(a-1,b,c-1), f(a,b-1,c-1)}`. -/
-----+++---+def rank2Profile (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
-----+++---+  let v1 := if 1 ≤ a ∧ 1 ≤ b then f (a - 1) (b - 1) c else 0
-----+++---+  let v2 := if 1 ≤ a ∧ 1 ≤ c then f (a - 1) b (c - 1) else 0
-----+++---+  let v3 := if 1 ≤ b ∧ 1 ≤ c then f a (b - 1) (c - 1) else 0
-----+++---+  max v1 (max v2 v3)
-----+++---+
-----+++---+/-- **Edge moment**: tropical convolution with the determinant character `ω₃ = (1,1,1)`.
-----+++---+
-----+++---+This is the shift operator: `edgeMoment f (a,b,c) = f(a-1, b-1, c-1)`.
-----+++---+As a representation-theoretic operation, it corresponds to convolution with the
-----+++---+one-dimensional determinant representation `det = ∧³(ℂ³)`. Unlike the rank-1 and
-----+++---+rank-2 profiles (which use `max` and can lose information), the determinant
-----+++---+convolution perfectly preserves all function values.
-----+++---+
-----+++---+This is the key observable that makes finite determinacy possible: it acts as an
-----+++---+exact reconstruction tool rather than a lossy tropical projection. -/
-----+++---+def edgeMoment (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
-----+++---+  if 1 ≤ a ∧ 1 ≤ b ∧ 1 ≤ c then f (a - 1) (b - 1) (c - 1) else 0
-----+++---+
-----+++---+/-- Combined triple convolution observable using both rank-1 and rank-2 generators.
-----+++---+    This packages rank-1 and rank-2 data together for the combined hypothesis form. -/
-----+++---+def tripleConvObservable (f : ℕ → ℕ → ℕ → ℤ) (t s : ℕ × ℕ × ℕ) : ℤ :=
-----+++---+  rank1Profile f t.1 t.2.1 t.2.2 + rank2Profile f s.1 s.2.1 s.2.2
-----+++---+
-----+++---+/-! ### Finite test ranges -/
-----+++---+
-----+++---+/-- The finite range of rank-1 test parameters determined by box bound `B`. -/
-----+++---+def finiteRank1Range (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
-----+++---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
-----+++---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
-----+++---+
-----+++---+/-- The finite range of rank-2 test parameters determined by box bound `B`. -/
-----+++---+def finiteRank2Range (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
-----+++---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
-----+++---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
-----+++---+
-----+++---+/-- The finite range of edge moment test parameters determined by box bound `B`.
-----+++---+    These are the shifted dominant coweights `(a+1, b+1, c+1)` for `(a,b,c) ∈ BoxDom(B)`. -/
-----+++---+def finiteEdgeMomentRange (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
-----+++---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
-----+++---+    fun ⟨a, b, c⟩ => 1 ≤ c ∧ c ≤ b ∧ b ≤ a
-----+++---+
-----+++---+/-! ### Key computation lemmas -/
-----+++---+
-----+++---+/-- The edge moment at a shifted point exactly recovers the function value.
-----+++---+    This is the fundamental reconstruction identity. -/
-----+++---+@[simp]
-----+++---+lemma edgeMoment_succ (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) :
-----+++---+    edgeMoment f (a + 1) (b + 1) (c + 1) = f a b c := by
-----+++---+  simp [edgeMoment]
-----+++---+
-----+++---+/-- Shifted dominant coweights lie in the edge moment range. -/
-----+++---+lemma shifted_mem_finiteEdgeMomentRange {B a b c : ℕ}
-----+++---+    (haB : a ≤ B) (hab : b ≤ a) (hbc : c ≤ b) :
-----+++---+    (a + 1, b + 1, c + 1) ∈ finiteEdgeMomentRange B := by
-----+++---+  simp [finiteEdgeMomentRange, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
-----+++---+  omega
-----+++---+
-----+++---+/-- The rank-2 profile at the floor level `(a+1, b+1, 0)` yields `max(f(a,b,0), 0)`.
-----+++---+    When `f` is nonneg-valued on the floor, this equals `f(a,b,0)`.
-----+++---+    The `c = 0` case is special because both `ω₂`-weight shifts involving `c-1`
-----+++---+    fall outside `ℕ`, leaving only the `(1,1,0)`-weight shift. -/
-----+++---+lemma rank2Profile_floor_level (f : ℕ → ℕ → ℕ → ℤ) (a b : ℕ) :
-----+++---+    rank2Profile f (a + 1) (b + 1) 0 = max (f a b 0) 0 := by
-----+++---+  simp [rank2Profile]
-----+++---+
-----+++---+/-- For functions supported in `BoxDom(B)`, values at `a > B` vanish. -/
-----+++---+lemma FiniteSupportWithin.vanish_above {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
-----+++---+    (hf : FiniteSupportWithin B f) {a : ℕ} (ha : B < a) (b c : ℕ) :
-----+++---+    f a b c = 0 := by
-----+++---+  exact hf a b c (Or.inl ha)
-----+++---+
-----+++---+/-- For functions supported in `BoxDom(B)`, values outside dominant cone vanish. -/
-----+++---+lemma FiniteSupportWithin.vanish_nondominant {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
-----+++---+    (hf : FiniteSupportWithin B f) {a b c : ℕ} (h : a < b ∨ b < c) :
-----+++---+    f a b c = 0 := by
-----+++---+  exact hf a b c (by tauto)
-----+++---+
-----+++---+/-- Bounded-support functions vanish outside the box: explicit formulation. -/
-----+++---+lemma bounded_support_implies_vanishing_outside {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
-----+++---+    (hf : FiniteSupportWithin B f) {a b c : ℕ}
-----+++---+    (h : ¬(a ≤ B ∧ b ≤ a ∧ c ≤ b)) :
-----+++---+    f a b c = 0 := by
-----+++---+  apply hf; push_neg at h; omega+--- a/EML/Basic.lean
-----+++--++++ b/EML/Basic.lean
-----+++--+@@ -1,277 +1,125 @@
-----+++--+-/-
-----+++--+-Copyright (c) 2026 Harmonic. All rights reserved.
-----+++--+-Released under Apache 2.0 license as described in the file LICENSE.
-----+++--+--/
-----+++--+ import Mathlib
-----+++--+ 
-----+++--+-/-!
-----+++--+-# Pullback Stability of Universal Approximation
-----+++--++/-! # CatalogBuild.EML.Basic
-----+++--+ 
-----+++--+-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
-----+++--+-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
-----+++--+-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
-----+++--+-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
-----+++--+-
-----+++--+-This establishes a transport principle: universal approximation results (like
-----+++--+-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
-----+++--+-with the precise target being the fiber-constant functions.
-----+++--+-
-----+++--+-## Main definitions
-----+++--+-
-----+++--+-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
-----+++--+-  fibers of `φ`.
-----+++--+-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
-----+++--+-
-----+++--+-## Main results
-----+++--+-
-----+++--+-### Basic properties (§1)
-----+++--+-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
-----+++--+-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
-----+++--+-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
-----+++--+-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
-----+++--+-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
-----+++--+-
-----+++--+-### Factorization (§2)
-----+++--+-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
-----+++--+-  through `Set.range φ`, hence is a pullback (via Tietze extension).
-----+++--+-
-----+++--+-### Density transport (§3)
-----+++--+-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
-----+++--+-  subalgebra equals `FiberConst φ`.
-----+++--+-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
-----+++--+-
-----+++--+-### ε-approximation (§4)
-----+++--+-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
-----+++--+-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
-----+++--++Auto-generated from theorem catalog database.
-----+++--++Domain: EML
-----+++--++Declarations: 15
-----+++--+ -/
-----+++--+ 
-----+++--+-open scoped Topology
-----+++--+-open Topology
-----+++--++noncomputable section
-----+++--+ 
-----+++--+-variable {X Y : Type*}
-----+++--+-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
-----+++--+-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
-----+++--++/-- The inverse for hyperbolic SPB is also negation. -/
-----+++--++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
-----+++--++  simp [spbH]
-----+++--+ 
-----+++--+-/-! ### §1: Definitions and basic properties -/
-----+++--++/-- Wick duality: SPB with negated second argument equals the "difference"
-----+++--++in the hyperbolic SPB. This is the real-variable manifestation of the
-----+++--++Wick rotation t → it. -/
-----+++--++theorem wick_duality (x y : ℝ) :
-----+++--++    spb x (-y) = (x - y) / (1 + x * y) := by
-----+++--++  simp only [spb]
-----+++--++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
-----+++--++  rw [heq]; ring
-----+++--+ 
-----+++--+-/-- Continuous functions on `X` that are constant on fibers of `φ`.
-----+++--+-This is the natural functional-analytic object associated to a feature map:
-----+++--+-it captures exactly the observables visible through `φ`. -/
-----+++--+-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
-----+++--+-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
-----+++--+-  algebraMap_mem' r := by intro x x' _; simp
-----+++--+-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----+++--+-  zero_mem' := by intro x x' _; simp
-----+++--+-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----+++--+-  one_mem' := by intro x x' _; simp
-----+++--++/-- The tangent addition law IS the stereographic sum.
-----+++--++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
-----+++--++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
-----+++--++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
-----+++--++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
-----+++--++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
-----+++--++  field_simp
-----+++--+ 
-----+++--+-/-- Pullback of continuous real-valued functions along `φ`. -/
-----+++--+-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
-----+++--+-  toFun f := f.comp φ
-----+++--+-  map_zero' := by ext; simp
-----+++--+-  map_one' := by ext; simp
-----+++--+-  map_add' := by intros; ext; simp
-----+++--+-  map_mul' := by intros; ext; simp
-----+++--+-  commutes' := by intros; ext; simp
-----+++--++/-- SPB expression trees — analogous to EML expression trees. -/
-----+++--++inductive SPBExpr where
-----+++--++  | zero : SPBExpr
-----+++--++  | one : SPBExpr
-----+++--++  | var : ℕ → SPBExpr
-----+++--++  | node : SPBExpr → SPBExpr → SPBExpr
-----+++--++  deriving Repr, BEq
-----+++--+ 
-----+++--+-@[simp]
-----+++--+-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
-----+++--+-    pullbackAlg φ f x = f (φ x) := rfl
-----+++--++/-- Evaluate an SPB expression. -/
-----+++--++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
-----+++--++  match e with
-----+++--++  | .zero => 0
-----+++--++  | .one => 1
-----+++--++  | .var n => vars n
-----+++--++  | .node l r => spb (l.eval vars) (r.eval vars)
-----+++--+ 
-----+++--+-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----+++--+-    pullbackAlg φ f ∈ FiberConst φ := by
-----+++--+-  intro x x' h; simp [h]
-----+++--++/-- Depth of an SPB expression. -/
-----+++--++def SPBExpr.depth : SPBExpr → ℕ
-----+++--++  | .zero => 0
-----+++--++  | .one => 0
-----+++--++  | .var _ => 0
-----+++--++  | .node l r => 1 + max l.depth r.depth
-----+++--+ 
-----+++--+-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
-----+++--+-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----+++--+-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
-----+++--++/-- Leaf count. -/
-----+++--++def SPBExpr.leafCount : SPBExpr → ℕ
-----+++--++  | .zero => 1
-----+++--++  | .one => 1
-----+++--++  | .var _ => 1
-----+++--++  | .node l r => l.leafCount + r.leafCount
-----+++--+ 
-----+++--+-theorem range_comp_subalgebra_subset_fiberConst
-----+++--+-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
-----+++--+-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----+++--+-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
-----+++--++/-- Internal node count. -/
-----+++--++def SPBExpr.nodeCount : SPBExpr → ℕ
-----+++--++  | .zero => 0
-----+++--++  | .one => 0
-----+++--++  | .var _ => 0
-----+++--++  | .node l r => 1 + l.nodeCount + r.nodeCount
-----+++--+ 
-----+++--+-/-- `FiberConst φ` is closed in the uniform topology. -/
-----+++--+-theorem fiberConst_closed (φ : C(X, Y)) :
-----+++--+-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
-----+++--+-  refine isClosed_of_closure_subset ?_
-----+++--+-  intro g hg x x' h
-----+++--+-  rw [mem_closure_iff_nhds] at hg
-----+++--+-  contrapose! hg
-----+++--+-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
-----+++--+-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
-----+++--+-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
-----+++--++/-- Binary tree identity: leaves = internal nodes + 1. -/
-----+++--++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
-----+++--++    e.leafCount = e.nodeCount + 1 := by
-----+++--++  induction e with
-----+++--++  | zero => rfl
-----+++--++  | one => rfl
-----+++--++  | var _ => rfl
-----+++--++  | node l r ihl ihr =>
-----+++--++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
-----+++--++    omega
-----+++--+ 
-----+++--+-omit [T2Space X] [T2Space Y] in
-----+++--+-/-- The pullback map is norm-nonincreasing. -/
-----+++--+-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----+++--+-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
-----+++--+-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
-----+++--+-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
-----+++--++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
-----+++--++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
-----+++--+ 
-----+++--+-/-- When `φ` is surjective, pullback is an isometry. -/
-----+++--+-theorem pullback_isometry_of_surjective
-----+++--+-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
-----+++--+-    ‖pullbackAlg φ f‖ = ‖f‖ := by
-----+++--+-  refine le_antisymm (norm_pullback_le φ f) ?_
-----+++--+-  rw [ContinuousMap.norm_le _ (by positivity)]
-----+++--+-  intro y; obtain ⟨x, rfl⟩ := hφ y
-----+++--+-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
-----+++--++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
-----+++--++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
-----+++--++  unfold logisticSigmoid
-----+++--++  rw [Real.exp_neg]
-----+++--++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
-----+++--++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
-----+++--++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----+++--++  field_simp; ring
-----+++--+ 
-----+++--+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----+++--+-theorem mem_fiberConst_of_injective
-----+++--+-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
-----+++--+-    g ∈ FiberConst φ := by
-----+++--+-  intro x x' h; exact congrArg g (hφ h)
-----+++--++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
-----+++--++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
-----+++--++  unfold softplus logisticSigmoid
-----+++--++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
-----+++--++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
-----+++--++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
-----+++--++  simp at this
-----+++--++  exact this
-----+++--+ 
-----+++--+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----+++--+-theorem fiberConst_eq_top_of_injective
-----+++--+-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
-----+++--+-    FiberConst φ = ⊤ := by
-----+++--+-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
-----+++--++/-- ShefferAlg is closed under affine pre-composition. -/
-----+++--++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
-----+++--++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
-----+++--++  obtain ⟨e, rfl⟩ := hf
-----+++--++  exact ⟨.affinePrecomp a b e, rfl⟩
-----+++--+ 
-----+++--+-omit [CompactSpace Y] [T2Space Y] in
-----+++--+-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
-----+++--+-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
-----+++--+-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
-----+++--+-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
-----+++--+-  intro x x' hφ; by_contra h_ne
-----+++--+-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
-----+++--+-    have := exists_continuous_zero_one_of_isClosed
-----+++--+-      (show IsClosed {x} from isClosed_singleton)
-----+++--+-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
-----+++--+-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
-----+++--+-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
-----+++--+-  replace h := SetLike.ext_iff.mp h g
-----+++--+-  simp_all +decide [FiberConst]
-----+++--+-  exact absurd (h hφ) (by simp +decide [hg])
-----+++--++/-- ShefferAlg is closed under affine combination. -/
-----+++--++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
-----+++--++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
-----+++--++  obtain ⟨ef, rfl⟩ := hf
-----+++--++  obtain ⟨eg, rfl⟩ := hg
-----+++--++  exact ⟨.affineComb α β γ ef eg, rfl⟩
-----+++--+ 
-----+++--+-/-! ### §2: Image factorization -/
-----+++--++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
-----+++--++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
-----+++--++  unfold softplus
-----+++--++  rw [Real.exp_neg]
-----+++--++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
-----+++--++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----+++--++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
-----+++--++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
-----+++--++  rw [this, Real.log_exp]
-----+++--+ 
-----+++--+-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
-----+++--+-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
-----+++--+-
-----+++--+-/-
-----+++--+-The corestriction `X → Set.range φ` is a quotient map.
-----+++--+--/
-----+++--+-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
-----+++--+-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
-----+++--+-  apply IsClosedMap.isQuotientMap;
-----+++--+-  · intro s hs;
-----+++--+-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
-----+++--+-    constructor <;> intro h;
-----+++--+-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
-----+++--+-    · convert h.preimage ( continuous_subtype_val ) using 1;
-----+++--+-      ext; simp [Set.rangeFactorization];
-----+++--+-      grind;
-----+++--+-  · exact continuous_induced_rng.mpr φ.continuous;
-----+++--+-  · exact Set.rangeFactorization_surjective
-----+++--+-
-----+++--+-/-- Lift a fiber-constant function to `Set.range φ`. -/
-----+++--+-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
-----+++--+-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
-----+++--+-  toFun z := g z.property.choose
-----+++--+-  continuous_toFun := by
-----+++--+-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
-----+++--+-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
-----+++--+-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
-----+++--+-      ext x; apply hg
-----+++--+-      exact (Set.rangeFactorization φ x).property.choose_spec
-----+++--+-    rw [this]; exact g.continuous
-----+++--+-
-----+++--+-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
-----+++--+-    (hg : g ∈ FiberConst φ) (x : X) :
-----+++--+-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
-----+++--+-  simp only [fiberConstLift]
-----+++--+-  apply hg
-----+++--+-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
-----+++--+-
-----+++--+-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
-----+++--+-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
-----+++--+-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
-----+++--+-  intro g hg
-----+++--+-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
-----+++--+-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
-----+++--+-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
-----+++--+-  refine ⟨F, ?_⟩
-----+++--+-  ext x
-----+++--+-  simp only [pullbackAlg_apply]
-----+++--+-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
-----+++--+-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
-----+++--+-    simp [ContinuousMap.comp_apply] at this; exact this
-----+++--+-  rw [key, fiberConstLift_comp]
-----+++--+-
-----+++--+-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
-----+++--+-theorem fiberConst_eq_range_pullback_of_surjective
-----+++--+-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
-----+++--+-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
-----+++--+-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
-----+++--+-    (range_pullback_subset_fiberConst φ)
-----+++--+-
-----+++--+-/-! ### §3: Density transport -/
-----+++--+-
-----+++--+-/-
-----+++--+-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
-----+++--+--/
-----+++--+-theorem closure_range_pullback_eq_fiberConst
-----+++--+-    (φ : C(X, Y))
-----+++--+-    (A : Subalgebra ℝ C(Y, ℝ))
-----+++--+-    (hA : Dense (A : Set C(Y, ℝ))) :
-----+++--+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
-----+++--+-      = (FiberConst φ : Set C(X, ℝ)) := by
-----+++--+-  refine' le_antisymm ( closure_minimal _ _ ) _;
-----+++--+-  · exact range_comp_subalgebra_subset_fiberConst φ A;
-----+++--+-  · exact fiberConst_closed φ;
-----+++--+-  · intro g hg;
-----+++--+-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
-----+++--+-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
-----+++--+-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
-----+++--+-    rw [ Metric.mem_closure_iff ];
-----+++--+-    intro ε εpos;
-----+++--+-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
-----+++--+-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
-----+++--+-    nontriviality;
-----+++--+-    rw [ hF, dist_eq_norm ] at *;
-----+++--+-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
-----+++--+-
-----+++--+-/-
-----+++--+-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
-----+++--+--/
-----+++--+-theorem closure_range_pullback_eq_top_of_injective
-----+++--+-    (φ : C(X, Y))
-----+++--+-    (hφ : Function.Injective φ)
-----+++--+-    (A : Subalgebra ℝ C(Y, ℝ))
-----+++--+-    (hA : Dense (A : Set C(Y, ℝ))) :
-----+++--+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
-----+++--+-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
-----+++--+-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
-----+++--+-
-----+++--+-/-! ### §4: ε-approximation -/
-----+++--+-
-----+++--+-/-
-----+++--+-ε-approximation within `FiberConst φ`.
-----+++--+--/
-----+++--+-theorem exists_pullback_approx_of_fiberConst
-----+++--+-    (φ : C(X, Y))
-----+++--+-    (A : Subalgebra ℝ C(Y, ℝ))
-----+++--+-    (hA : Dense (A : Set C(Y, ℝ)))
-----+++--+-    (g : C(X, ℝ))
-----+++--+-    (hg : g ∈ FiberConst φ)
-----+++--+-    {ε : ℝ} (hε : 0 < ε) :
-----+++--+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----+++--+-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
-----+++--+-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
-----+++--+-  rw [ Metric.mem_closure_iff ] at h_closure;
-----+++--+-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
-----+++--+-
-----+++--+-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
-----+++--+-theorem exists_pullback_approx_of_injective
-----+++--+-    (φ : C(X, Y))
-----+++--+-    (hφ : Function.Injective φ)
-----+++--+-    (A : Subalgebra ℝ C(Y, ℝ))
-----+++--+-    (hA : Dense (A : Set C(Y, ℝ)))
-----+++--+-    (g : C(X, ℝ))
-----+++--+-    {ε : ℝ} (hε : 0 < ε) :
-----+++--+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----+++--+-  exact exists_pullback_approx_of_fiberConst φ A hA g
-----+++--+-    (mem_fiberConst_of_injective φ hφ g) hε+end+--- a/EML/Basic.lean
-----+++-++++ b/EML/Basic.lean
-----+++-+@@ -1,277 +1,125 @@
-----+++-+-/-
-----+++-+-Copyright (c) 2026 Harmonic. All rights reserved.
-----+++-+-Released under Apache 2.0 license as described in the file LICENSE.
-----+++-+--/
-----++ -+ import Mathlib
-----++ -+ 
-----++--+ namespace SimpleGraph
-----++--+ 
-----++--+-variable {V : Type*} {G : SimpleGraph V} {e : Sym2 V}
-----++--++variable {V : Type*} {G : SimpleGraph V}
-----++--+ 
-----++--+-/-! ### Trees have all bridges
-----++--++/-! ### Deletion equivalence
-----++--+ 
-----++--+-We prove that in a tree, every edge is a bridge. This follows from the
-----++--+-characterization that an edge is a bridge iff it does not lie on any cycle,
-----++--+-combined with the fact that trees are acyclic.
-----++--++`G.deleteEdges s` and `G \ fromEdgeSet s` have the same adjacency and
-----++--++hence the same reachability.  We prove the reachability equivalence
-----++--++we need. -/
-----++--++
-----++--++/-
-----++--++`deleteEdges {e}` and `G \ fromEdgeSet {e}` have the same reachability.
-----+++-+-/-!
-----+++-+-# Pullback Stability of Universal Approximation
-----+++-++/-! # CatalogBuild.EML.Basic
-----+ +-+ 
-----+-+-+ This file develops the theory of bridges (cut edges) in simple graphs,
-----+-+-+-proving the fundamental equivalence between trees and connected graphs
-----+-+-+-where every edge is a bridge.
-----+-+-++building on Mathlib's `SimpleGraph.IsBridge` definition.
-----+++-+-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
-----+++-+-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
-----+++-+-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
-----+++-+-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
-----+++-+-
-----+++-+-This establishes a transport principle: universal approximation results (like
-----+++-+-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
-----+++-+-with the precise target being the fiber-constant functions.
-----+++-+-
-----+++-+-## Main definitions
-----+++-+-
-----+++-+-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
-----+++-+-  fibers of `φ`.
-----+++-+-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
-----+++-+-
-----+++-+-## Main results
-----+++-+-
-----+++-+-### Basic properties (§1)
-----+++-+-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
-----+++-+-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
-----+++-+-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
-----+++-+-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
-----+++-+-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
-----+++-+-
-----+++-+-### Factorization (§2)
-----+++-+-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
-----+++-+-  through `Set.range φ`, hence is a pullback (via Tietze extension).
-----+++-+-
-----+++-+-### Density transport (§3)
-----+++-+-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
-----+++-+-  subalgebra equals `FiberConst φ`.
-----+++-+-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
-----+++-+-
-----+++-+-### ε-approximation (§4)
-----+++-+-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
-----+++-+-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
-----+++-++Auto-generated from theorem catalog database.
-----+++-++Domain: EML
-----+++-++Declarations: 15
-----++ -+ -/
-----++--++theorem reachable_deleteEdges_iff_reachable_sdiff {e : Sym2 V} {u v : V} :
-----++--++    (G.deleteEdges {e}).Reachable u v ↔ (G \ fromEdgeSet {e}).Reachable u v := by
-----++--++  constructor;
-----++--++  · intro h;
-----++--++    convert h.mono ?_;
-----++--++    intro u v; aesop;
-----++--++  · intro h;
-----++--++    convert h
-----++--+ 
-----++--+-/-- In an acyclic graph, every edge is a bridge. Since there are no cycles,
-----++--+-no edge can lie on a cycle, which is precisely the bridge characterization. -/
-----++--+-theorem IsAcyclic.isBridge_of_mem_edgeSet (hAcyclic : G.IsAcyclic)
-----++--+-    (he : e ∈ G.edgeSet) : G.IsBridge e := by
-----++--+-  rw [isBridge_iff_mem_and_forall_cycle_notMem]
-----++--+-  exact ⟨he, fun u p hp => absurd hp (hAcyclic p)⟩
-----++--++/-- Bridge characterization using `deleteEdges` instead of `sdiff`. -/
-----++--++theorem isBridge_iff_deleteEdges {u v : V} :
-----++--++    G.IsBridge s(u, v) ↔ G.Adj u v ∧ ¬(G.deleteEdges {s(u, v)}).Reachable u v := by
-----++--++  rw [isBridge_iff]
-----++--++  exact ⟨
-----++--++    fun ⟨h1, h2⟩ => ⟨h1, fun hr => h2 (reachable_deleteEdges_iff_reachable_sdiff.mp hr)⟩,
-----++--++    fun ⟨h1, h2⟩ => ⟨h1, fun hr => h2 (reachable_deleteEdges_iff_reachable_sdiff.mpr hr)⟩⟩
-----++--+ 
-----++--+-/-- In a tree, every edge is a bridge. This is a direct consequence of
-----++--+-acyclicity: since no cycles exist, no edge can participate in a cycle. -/
-----++--+-theorem IsTree.isBridge_of_mem_edgeSet (hTree : G.IsTree)
-----++--+-    (he : e ∈ G.edgeSet) : G.IsBridge e :=
-----++--+-  hTree.IsAcyclic.isBridge_of_mem_edgeSet he
-----++--++/-! ### Bridge fundamentals -/
-----++--+ 
-----++--+-/-! ### Connected graphs with all bridges are trees
-----++--++/-- The endpoints of a bridge lie in different connected components
-----++--++after the bridge is deleted. -/
-----++--++theorem IsBridge.connectedComponent_ne_deleteEdges {u v : V}
-----++--++    (hb : G.IsBridge s(u, v)) :
-----++--++    (G.deleteEdges {s(u, v)}).connectedComponentMk u ≠
-----++--++    (G.deleteEdges {s(u, v)}).connectedComponentMk v := by
-----++--++  rw [Ne, ConnectedComponent.eq]
-----++--++  exact (isBridge_iff_deleteEdges.mp hb).2
-----++--+ 
-----++--+-We prove the converse: if a connected graph has the property that every
-----++--+-edge is a bridge, then it must be acyclic (and hence a tree).
-----++--++/-! ### Bridge splitting: every vertex goes to one side -/
-----++--++
-----++--++/-
-----++--++In a connected graph, after removing a bridge {u,v}, every vertex
-----++--++is reachable from either u or v (but not both, since u and v are separated).
-----++--++This shows the bridge partitions the vertex set into exactly two parts.
-----++--+ -/
-----++--++theorem IsBridge.forall_reachable_delete_left_or_right
-----++--++    (hconn : G.Connected) {u v : V} (hb : G.IsBridge s(u, v)) (w : V) :
-----++--++    (G.deleteEdges {s(u, v)}).Reachable u w ∨
-----++--++    (G.deleteEdges {s(u, v)}).Reachable v w := by
-----++--++  obtain ⟨ p ⟩ := hconn w u;
-----++--++  induction' p with w' w'' p ih;
-----++--++  · exact Or.inl ( SimpleGraph.Reachable.refl _ );
-----++--++  · cases' eq_or_ne w'' ih with h h <;> cases' eq_or_ne w'' v with h' h' <;> simp_all +decide [ SimpleGraph.isBridge_iff ];
-----++--++    cases' ‹ ( G.deleteEdges { s(ih, v) } ).Reachable ih p ∨ ( G.deleteEdges { s(ih, v) } ).Reachable v p › with h'' h'' <;> [ left; right ] <;> refine' h''.trans _ <;> simp_all +decide [ SimpleGraph.deleteEdges ];
-----++--++    · exact SimpleGraph.Adj.reachable ( by aesop ) |> SimpleGraph.Reachable.symm;
-----++--++    · exact SimpleGraph.Reachable.symm ( SimpleGraph.Adj.reachable ( by aesop ) )
-----++--+ 
-----++--+-/-- If every edge of a graph is a bridge, then the graph is acyclic.
-----++--++/-! ### Two connected components -/
-----++--+ 
-----++--+-**Proof sketch**: Suppose for contradiction there exists a cycle `c`.
-----++--+-Since `c` is not nil, it has at least one edge `e`. This edge lies in the
-----++--+-edge set of `G`, so by hypothesis it is a bridge. But bridges cannot lie
-----++--+-on any cycle (by `isBridge_iff_mem_and_forall_cycle_notMem`), contradicting
-----++--+-that `e` lies on `c`. -/
-----++--+-theorem isAcyclic_of_forall_isBridge
-----++--+-    (h : ∀ e ∈ G.edgeSet, G.IsBridge e) : G.IsAcyclic := by
-----++--+-  intro v c hc
-----++--+-  -- A cycle must have at least one edge
-----++--+-  have hne : c.edges ≠ [] := by
-----++--+-    intro he
-----++--+-    cases c with
-----++--+-    | nil => exact hc.ne_nil rfl
-----++--+-    | cons _ _ => simp [Walk.edges_cons] at he
-----++--+-  obtain ⟨e, he⟩ := List.exists_mem_of_ne_nil _ hne
-----++--+-  have he_mem : e ∈ G.edgeSet := Walk.edges_subset_edgeSet _ he
-----++--+-  have hbridge := h e he_mem
-----++--+-  rw [isBridge_iff_mem_and_forall_cycle_notMem] at hbridge
-----++--+-  exact hbridge.2 c hc he
-----++--++/-
-----++--++Removing a bridge from a connected graph produces exactly two
-----++--++connected components. This is a fundamental structural result about
-----++--++bridges, showing that a bridge literally "bridges" two otherwise
-----++--++disconnected parts of the graph.
-----++--++-/
-----++--++theorem IsBridge.two_connected_components [DecidableEq V] [Fintype V]
-----++--++    [DecidableRel G.Adj]
-----++--++    (hconn : G.Connected) {u v : V} (hb : G.IsBridge s(u, v)) :
-----++--++    Fintype.card (G.deleteEdges {s(u, v)}).ConnectedComponent = 2 := by
-----++--++  convert Set.ncard_eq_two.mpr _;
-----++--++  rotate_left;
-----++--++  exact ( G.deleteEdges { s(u, v) } ).ConnectedComponent;
-----++--++  exact Set.range ( fun w => ( G.deleteEdges { s(u, v) } ).connectedComponentMk w );
-----++--++  · refine' ⟨ _, _, _, _ ⟩;
-----++--++    exact ( G.deleteEdges { s(u, v) } ).connectedComponentMk u;
-----++--++    exact ( G.deleteEdges { s(u, v) } ).connectedComponentMk v;
-----++--++    · exact connectedComponent_ne_deleteEdges hb;
-----++--++    · ext w;
-----++--++      obtain ⟨ x, rfl ⟩ := w.exists_rep;
-----++--++      have := hb.forall_reachable_delete_left_or_right hconn x;
-----++--++      cases this <;> simp_all +decide [ SimpleGraph.connectedComponentMk ];
-----++--++      · exact Or.inl ( Quot.sound ‹_› |> Eq.symm );
-----++--++      · exact Or.inr ( Quot.sound <| by tauto );
-----++--++  · rw [ Set.ncard_eq_toFinset_card _ ];
-----++--++    refine' Finset.card_bij ( fun x _ => x ) _ _ _ <;> simp +decide;
-----++--++    exact fun a => a.exists_rep
-----++--+ 
-----++--+-/-- **Tree-Bridge Equivalence Theorem.**
-----++--+-A graph is a tree if and only if it is connected and every edge is a bridge.
-----++--++/-! ### Trees and bridges -/
-----++--+ 
-----++--+-This is a fundamental characterization of trees: they are precisely the
-----++--+-connected graphs that are "minimally connected" — removing any single
-----++--+-edge disconnects the graph.
-----++--++/-
-----++--++Every edge of a tree is a bridge. In a tree, every edge is critical
-----++--++for connectivity — removing any edge disconnects the tree.
-----++--++-/
-----++--++theorem IsTree.isBridge_of_adj (hT : G.IsTree) {u v : V} (hadj : G.Adj u v) :
-----++--++    G.IsBridge s(u, v) := by
-----++--++  -- By definition of a tree, it is acyclic.
-----++--++  have h_acyclic : G.IsAcyclic := by
-----++--++    exact hT.2;
-----++--++  rw [ SimpleGraph.isAcyclic_iff_forall_adj_isBridge ] at h_acyclic ; aesop
-----++--+ 
-----++--+-### Forward direction
-----++--+-In a tree (connected + acyclic), every edge is a bridge because there are
-----++--+-no cycles, so no edge can lie on a cycle.
-----++--+-
-----++--+-### Reverse direction
-----++--+-If every edge is a bridge, the graph must be acyclic: any cycle would contain
-----++--+-an edge that both lies on a cycle and is a bridge, which is a contradiction. -/
-----++--+-theorem isTree_iff_connected_and_forall_isBridge :
-----++--+-    G.IsTree ↔ G.Connected ∧ ∀ e ∈ G.edgeSet, G.IsBridge e := by
-----++--+-  constructor
-----++--+-  · intro hTree
-----++--+-    exact ⟨hTree.isConnected, fun e he => hTree.isBridge_of_mem_edgeSet he⟩
-----++--+-  · intro ⟨hConn, hBridge⟩
-----++--+-    exact ⟨hConn, isAcyclic_of_forall_isBridge hBridge⟩
-----++--++/-
-----++--++A connected graph is a tree if and only if every edge is a bridge.
-----++--++This provides a characterization of trees in terms of edge criticality.
-----++--++-/
-----++--++theorem connected_isBridge_all_iff_isTree (hconn : G.Connected) :
-----++--++    (∀ ⦃u v : V⦄, G.Adj u v → G.IsBridge s(u, v)) ↔ G.IsTree := by
-----++--++  constructor;
-----++--++  · intro h;
-----++--++    constructor;
-----++--++    · assumption;
-----++--++    · exact isAcyclic_iff_forall_adj_isBridge.mpr h;
-----++--++  · exact fun a ⦃u v⦄ a_1 => IsTree.isBridge_of_adj a a_1
-----++--+ 
-----++--+ end SimpleGraph++-open scoped Topology
-----++-++-open Topology
-----++-+++noncomputable section
-----++-++ 
-----++-++-variable {X Y : Type*}
-----++-++-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
-----++-++-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
-----++-+++/-- The inverse for hyperbolic SPB is also negation. -/
-----++-+++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
-----++-+++  simp [spbH]
-----++-++ 
-----++-++-/-! ### §1: Definitions and basic properties -/
-----++-+++/-- Wick duality: SPB with negated second argument equals the "difference"
-----++-+++in the hyperbolic SPB. This is the real-variable manifestation of the
-----++-+++Wick rotation t → it. -/
-----++-+++theorem wick_duality (x y : ℝ) :
-----++-+++    spb x (-y) = (x - y) / (1 + x * y) := by
-----++-+++  simp only [spb]
-----++-+++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
-----++-+++  rw [heq]; ring
-----++-++ 
-----++-++-/-- Continuous functions on `X` that are constant on fibers of `φ`.
-----++-++-This is the natural functional-analytic object associated to a feature map:
-----++-++-it captures exactly the observables visible through `φ`. -/
-----++-++-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
-----++-++-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
-----++-++-  algebraMap_mem' r := by intro x x' _; simp
-----++-++-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----++-++-  zero_mem' := by intro x x' _; simp
-----++-++-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----++-++-  one_mem' := by intro x x' _; simp
-----++-+++/-- The tangent addition law IS the stereographic sum.
-----++-+++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
-----++-+++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
-----++-+++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
-----++-+++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
-----++-+++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
-----++-+++  field_simp
-----++-++ 
-----++-++-/-- Pullback of continuous real-valued functions along `φ`. -/
-----++-++-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
-----++-++-  toFun f := f.comp φ
-----++-++-  map_zero' := by ext; simp
-----++-++-  map_one' := by ext; simp
-----++-++-  map_add' := by intros; ext; simp
-----++-++-  map_mul' := by intros; ext; simp
-----++-++-  commutes' := by intros; ext; simp
-----++-+++/-- SPB expression trees — analogous to EML expression trees. -/
-----++-+++inductive SPBExpr where
-----++-+++  | zero : SPBExpr
-----++-+++  | one : SPBExpr
-----++-+++  | var : ℕ → SPBExpr
-----++-+++  | node : SPBExpr → SPBExpr → SPBExpr
-----++-+++  deriving Repr, BEq
-----++-++ 
-----++-++-@[simp]
-----++-++-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
-----++-++-    pullbackAlg φ f x = f (φ x) := rfl
-----++-+++/-- Evaluate an SPB expression. -/
-----++-+++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
-----++-+++  match e with
-----++-+++  | .zero => 0
-----++-+++  | .one => 1
-----++-+++  | .var n => vars n
-----++-+++  | .node l r => spb (l.eval vars) (r.eval vars)
-----++-++ 
-----++-++-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----++-++-    pullbackAlg φ f ∈ FiberConst φ := by
-----++-++-  intro x x' h; simp [h]
-----++-+++/-- Depth of an SPB expression. -/
-----++-+++def SPBExpr.depth : SPBExpr → ℕ
-----++-+++  | .zero => 0
-----++-+++  | .one => 0
-----++-+++  | .var _ => 0
-----++-+++  | .node l r => 1 + max l.depth r.depth
-----++-++ 
-----++-++-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
-----++-++-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----++-++-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
-----++-+++/-- Leaf count. -/
-----++-+++def SPBExpr.leafCount : SPBExpr → ℕ
-----++-+++  | .zero => 1
-----++-+++  | .one => 1
-----++-+++  | .var _ => 1
-----++-+++  | .node l r => l.leafCount + r.leafCount
-----++-++ 
-----++-++-theorem range_comp_subalgebra_subset_fiberConst
-----++-++-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
-----++-++-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----++-++-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
-----++-+++/-- Internal node count. -/
-----++-+++def SPBExpr.nodeCount : SPBExpr → ℕ
-----++-+++  | .zero => 0
-----++-+++  | .one => 0
-----++-+++  | .var _ => 0
-----++-+++  | .node l r => 1 + l.nodeCount + r.nodeCount
-----++-++ 
-----++-++-/-- `FiberConst φ` is closed in the uniform topology. -/
-----++-++-theorem fiberConst_closed (φ : C(X, Y)) :
-----++-++-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
-----++-++-  refine isClosed_of_closure_subset ?_
-----++-++-  intro g hg x x' h
-----++-++-  rw [mem_closure_iff_nhds] at hg
-----++-++-  contrapose! hg
-----++-++-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
-----++-++-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
-----++-++-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
-----++-+++/-- Binary tree identity: leaves = internal nodes + 1. -/
-----++-+++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
-----++-+++    e.leafCount = e.nodeCount + 1 := by
-----++-+++  induction e with
-----++-+++  | zero => rfl
-----++-+++  | one => rfl
-----++-+++  | var _ => rfl
-----++-+++  | node l r ihl ihr =>
-----++-+++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
-----++-+++    omega
-----++-++ 
-----++-++-omit [T2Space X] [T2Space Y] in
-----++-++-/-- The pullback map is norm-nonincreasing. -/
-----++-++-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----++-++-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
-----++-++-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
-----++-++-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
-----++-+++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
-----++-+++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
-----++-++ 
-----++-++-/-- When `φ` is surjective, pullback is an isometry. -/
-----++-++-theorem pullback_isometry_of_surjective
-----++-++-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
-----++-++-    ‖pullbackAlg φ f‖ = ‖f‖ := by
-----++-++-  refine le_antisymm (norm_pullback_le φ f) ?_
-----++-++-  rw [ContinuousMap.norm_le _ (by positivity)]
-----++-++-  intro y; obtain ⟨x, rfl⟩ := hφ y
-----++-++-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
-----++-+++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
-----++-+++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
-----++-+++  unfold logisticSigmoid
-----++-+++  rw [Real.exp_neg]
-----++-+++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
-----++-+++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
-----++-+++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----++-+++  field_simp; ring
-----++-++ 
-----++-++-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----++-++-theorem mem_fiberConst_of_injective
-----++-++-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
-----++-++-    g ∈ FiberConst φ := by
-----++-++-  intro x x' h; exact congrArg g (hφ h)
-----++-+++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
-----++-+++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
-----++-+++  unfold softplus logisticSigmoid
-----++-+++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
-----++-+++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
-----++-+++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
-----++-+++  simp at this
-----++-+++  exact this
-----++-++ 
-----++-++-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----++-++-theorem fiberConst_eq_top_of_injective
-----++-++-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
-----++-++-    FiberConst φ = ⊤ := by
-----++-++-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
-----++-+++/-- ShefferAlg is closed under affine pre-composition. -/
-----++-+++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
-----++-+++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
-----++-+++  obtain ⟨e, rfl⟩ := hf
-----++-+++  exact ⟨.affinePrecomp a b e, rfl⟩
-----++-++ 
-----++-++-omit [CompactSpace Y] [T2Space Y] in
-----++-++-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
-----++-++-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
-----++-++-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
-----++-++-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
-----++-++-  intro x x' hφ; by_contra h_ne
-----++-++-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
-----++-++-    have := exists_continuous_zero_one_of_isClosed
-----++-++-      (show IsClosed {x} from isClosed_singleton)
-----++-++-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
-----++-++-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
-----++-++-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
-----++-++-  replace h := SetLike.ext_iff.mp h g
-----++-++-  simp_all +decide [FiberConst]
-----++-++-  exact absurd (h hφ) (by simp +decide [hg])
-----++-+++/-- ShefferAlg is closed under affine combination. -/
-----++-+++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
-----++-+++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
-----++-+++  obtain ⟨ef, rfl⟩ := hf
-----++-+++  obtain ⟨eg, rfl⟩ := hg
-----++-+++  exact ⟨.affineComb α β γ ef eg, rfl⟩
-----++-++ 
-----++-++-/-! ### §2: Image factorization -/
-----++-+++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
-----++-+++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
-----++-+++  unfold softplus
-----++-+++  rw [Real.exp_neg]
-----++-+++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
-----++-+++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----++-+++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
-----++-+++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
-----++-+++  rw [this, Real.log_exp]
-----++-++ 
-----++-++-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
-----++-++-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
-----++-++-
-----++-++-/-
-----++-++-The corestriction `X → Set.range φ` is a quotient map.
-----++-++--/
-----++-++-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
-----++-++-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
-----++-++-  apply IsClosedMap.isQuotientMap;
-----++-++-  · intro s hs;
-----++-++-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
-----++-++-    constructor <;> intro h;
-----++-++-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
-----++-++-    · convert h.preimage ( continuous_subtype_val ) using 1;
-----++-++-      ext; simp [Set.rangeFactorization];
-----++-++-      grind;
-----++-++-  · exact continuous_induced_rng.mpr φ.continuous;
-----++-++-  · exact Set.rangeFactorization_surjective
-----++-++-
-----++-++-/-- Lift a fiber-constant function to `Set.range φ`. -/
-----++-++-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
-----++-++-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
-----++-++-  toFun z := g z.property.choose
-----++-++-  continuous_toFun := by
-----++-++-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
-----++-++-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
-----++-++-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
-----++-++-      ext x; apply hg
-----++-++-      exact (Set.rangeFactorization φ x).property.choose_spec
-----++-++-    rw [this]; exact g.continuous
-----++-++-
-----++-++-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
-----++-++-    (hg : g ∈ FiberConst φ) (x : X) :
-----++-++-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
-----++-++-  simp only [fiberConstLift]
-----++-++-  apply hg
-----++-++-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
-----++-++-
-----++-++-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
-----++-++-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
-----++-++-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
-----++-++-  intro g hg
-----++-++-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
-----++-++-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
-----++-++-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
-----++-++-  refine ⟨F, ?_⟩
-----++-++-  ext x
-----++-++-  simp only [pullbackAlg_apply]
-----++-++-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
-----++-++-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
-----++-++-    simp [ContinuousMap.comp_apply] at this; exact this
-----++-++-  rw [key, fiberConstLift_comp]
-----++-++-
-----++-++-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
-----++-++-theorem fiberConst_eq_range_pullback_of_surjective
-----++-++-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
-----++-++-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
-----++-++-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
-----++-++-    (range_pullback_subset_fiberConst φ)
-----++-++-
-----++-++-/-! ### §3: Density transport -/
-----++-++-
-----++-++-/-
-----++-++-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
-----++-++--/
-----++-++-theorem closure_range_pullback_eq_fiberConst
-----++-++-    (φ : C(X, Y))
-----++-++-    (A : Subalgebra ℝ C(Y, ℝ))
-----++-++-    (hA : Dense (A : Set C(Y, ℝ))) :
-----++-++-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
-----++-++-      = (FiberConst φ : Set C(X, ℝ)) := by
-----++-++-  refine' le_antisymm ( closure_minimal _ _ ) _;
-----++-++-  · exact range_comp_subalgebra_subset_fiberConst φ A;
-----++-++-  · exact fiberConst_closed φ;
-----++-++-  · intro g hg;
-----++-++-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
-----++-++-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
-----++-++-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
-----++-++-    rw [ Metric.mem_closure_iff ];
-----++-++-    intro ε εpos;
-----++-++-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
-----++-++-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
-----++-++-    nontriviality;
-----++-++-    rw [ hF, dist_eq_norm ] at *;
-----++-++-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
-----++-++-
-----++-++-/-
-----++-++-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
-----++-++--/
-----++-++-theorem closure_range_pullback_eq_top_of_injective
-----++-++-    (φ : C(X, Y))
-----++-++-    (hφ : Function.Injective φ)
-----++-++-    (A : Subalgebra ℝ C(Y, ℝ))
-----++-++-    (hA : Dense (A : Set C(Y, ℝ))) :
-----++-++-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
-----++-++-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
-----++-++-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
-----++-++-
-----++-++-/-! ### §4: ε-approximation -/
-----++-++-
-----++-++-/-
-----++-++-ε-approximation within `FiberConst φ`.
-----++-++--/
-----++-++-theorem exists_pullback_approx_of_fiberConst
-----++-++-    (φ : C(X, Y))
-----++-++-    (A : Subalgebra ℝ C(Y, ℝ))
-----++-++-    (hA : Dense (A : Set C(Y, ℝ)))
-----++-++-    (g : C(X, ℝ))
-----++-++-    (hg : g ∈ FiberConst φ)
-----++-++-    {ε : ℝ} (hε : 0 < ε) :
-----++-++-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----++-++-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
-----++-++-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
-----++-++-  rw [ Metric.mem_closure_iff ] at h_closure;
-----++-++-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
-----++-++-
-----++-++-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
-----++-++-theorem exists_pullback_approx_of_injective
-----++-++-    (φ : C(X, Y))
-----++-++-    (hφ : Function.Injective φ)
-----++-++-    (A : Subalgebra ℝ C(Y, ℝ))
-----++-++-    (hA : Dense (A : Set C(Y, ℝ)))
-----++-++-    (g : C(X, ℝ))
-----++-++-    {ε : ℝ} (hε : 0 < ε) :
-----++-++-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----++-++-  exact exists_pullback_approx_of_fiberConst φ A hA g
-----++-++-    (mem_fiberConst_of_injective φ hφ g) hε+end+-+ 
-----+++-+-open scoped Topology
-----+++-+-open Topology
-----+++-++noncomputable section
-----+ +-+ 
-----+-+-+-## Main Results
-----+-+-++## Main results
-----+++-+-variable {X Y : Type*}
-----+++-+-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
-----+++-+-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
-----+++-++/-- The inverse for hyperbolic SPB is also negation. -/
-----+++-++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
-----+++-++  simp [spbH]
-----+ +-+ 
-----+-+-+-* `SimpleGraph.IsAcyclic.isBridge_of_mem_edgeSet` — In an acyclic graph, every edge is a bridge
-----+-+-+-* `SimpleGraph.IsTree.isBridge_of_mem_edgeSet` — In a tree, every edge is a bridge
-----+-+-+-* `SimpleGraph.isAcyclic_of_forall_isBridge` — If every edge is a bridge, the graph is acyclic
-----+-+-+-* `SimpleGraph.isTree_iff_connected_and_forall_isBridge` — **Tree-Bridge Equivalence**:
-----+-+-+-  A graph is a tree if and only if it is connected and every edge is a bridge
-----+-+-++* `IsBridge.connectedComponent_ne` — Endpoints of a bridge are in different
-----+-+-++  connected components after deletion.
-----+-+-++* `IsBridge.two_connected_components` — Removing a bridge from a connected
-----+-+-++  graph yields exactly two connected components.
-----+-+-++* `IsTree.isBridge_of_adj` — Every edge of a tree is a bridge.
-----+-+-++* `connected_isBridge_all_iff_isTree` — A connected graph is a tree iff
-----+-+-++  every edge is a bridge.
-----+-+-++* `IsBridge.forall_reachable_delete_left_or_right` — Every vertex in a
-----+-+-++  connected graph is reachable from one side of a bridge after deletion.
-----+++-+-/-! ### §1: Definitions and basic properties -/
-----+++-++/-- Wick duality: SPB with negated second argument equals the "difference"
-----+++-++in the hyperbolic SPB. This is the real-variable manifestation of the
-----+++-++Wick rotation t → it. -/
-----+++-++theorem wick_duality (x y : ℝ) :
-----+++-++    spb x (-y) = (x - y) / (1 + x * y) := by
-----+++-++  simp only [spb]
-----+++-++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
-----+++-++  rw [heq]; ring
-----+ +-+ 
-----+-+-+-## Historical Context
-----+-+-++## Historical context
-----+++-+-/-- Continuous functions on `X` that are constant on fibers of `φ`.
-----+++-+-This is the natural functional-analytic object associated to a feature map:
-----+++-+-it captures exactly the observables visible through `φ`. -/
-----+++-+-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
-----+++-+-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
-----+++-+-  algebraMap_mem' r := by intro x x' _; simp
-----+++-+-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----+++-+-  zero_mem' := by intro x x' _; simp
-----+++-+-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----+++-+-  one_mem' := by intro x x' _; simp
-----+++-++/-- The tangent addition law IS the stereographic sum.
-----+++-++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
-----+++-++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
-----+++-++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
-----+++-++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
-----+++-++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
-----+++-++  field_simp
-----+ +-+ 
-----+-+-+-Bridges in graph theory originate from Euler's 1736 analysis of the Königsberg
-----+-+-+-bridge problem. The Tree-Bridge Equivalence Theorem provides a fundamental
-----+-+-+-structural characterization: trees are precisely the minimally connected graphs,
-----+-+-+-where the removal of any single edge disconnects the graph.
-----+++-+-/-- Pullback of continuous real-valued functions along `φ`. -/
-----+++-+-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
-----+++-+-  toFun f := f.comp φ
-----+++-+-  map_zero' := by ext; simp
-----+++-+-  map_one' := by ext; simp
-----+++-+-  map_add' := by intros; ext; simp
-----+++-+-  map_mul' := by intros; ext; simp
-----+++-+-  commutes' := by intros; ext; simp
-----+++-++/-- SPB expression trees — analogous to EML expression trees. -/
-----+++-++inductive SPBExpr where
-----+++-++  | zero : SPBExpr
-----+++-++  | one : SPBExpr
-----+++-++  | var : ℕ → SPBExpr
-----+++-++  | node : SPBExpr → SPBExpr → SPBExpr
-----+++-++  deriving Repr, BEq
-----+++-+ 
-----+++-+-@[simp]
-----+++-+-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
-----+++-+-    pullbackAlg φ f x = f (φ x) := rfl
-----+++-++/-- Evaluate an SPB expression. -/
-----+++-++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
-----+++-++  match e with
-----+++-++  | .zero => 0
-----+++-++  | .one => 1
-----+++-++  | .var n => vars n
-----+++-++  | .node l r => spb (l.eval vars) (r.eval vars)
-----+++-+ 
-----+++-+-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----+++-+-    pullbackAlg φ f ∈ FiberConst φ := by
-----+++-+-  intro x x' h; simp [h]
-----+++-++/-- Depth of an SPB expression. -/
-----+++-++def SPBExpr.depth : SPBExpr → ℕ
-----+++-++  | .zero => 0
-----+++-++  | .one => 0
-----+++-++  | .var _ => 0
-----+++-++  | .node l r => 1 + max l.depth r.depth
-----+++-+ 
-----+++-+-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
-----+++-+-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----+++-+-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
-----+++-++/-- Leaf count. -/
-----+++-++def SPBExpr.leafCount : SPBExpr → ℕ
-----+++-++  | .zero => 1
-----+++-++  | .one => 1
-----+++-++  | .var _ => 1
-----+++-++  | .node l r => l.leafCount + r.leafCount
-----+++-+ 
-----+++-+-theorem range_comp_subalgebra_subset_fiberConst
-----+++-+-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
-----+++-+-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----+++-+-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
-----+++-++/-- Internal node count. -/
-----+++-++def SPBExpr.nodeCount : SPBExpr → ℕ
-----+++-++  | .zero => 0
-----+++-++  | .one => 0
-----+++-++  | .var _ => 0
-----+++-++  | .node l r => 1 + l.nodeCount + r.nodeCount
-----+++-+ 
-----+++-+-/-- `FiberConst φ` is closed in the uniform topology. -/
-----+++-+-theorem fiberConst_closed (φ : C(X, Y)) :
-----+++-+-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
-----+++-+-  refine isClosed_of_closure_subset ?_
-----+++-+-  intro g hg x x' h
-----+++-+-  rw [mem_closure_iff_nhds] at hg
-----+++-+-  contrapose! hg
-----+++-+-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
-----+++-+-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
-----+++-+-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
-----+++-++/-- Binary tree identity: leaves = internal nodes + 1. -/
-----+++-++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
-----+++-++    e.leafCount = e.nodeCount + 1 := by
-----+++-++  induction e with
-----+++-++  | zero => rfl
-----+++-++  | one => rfl
-----+++-++  | var _ => rfl
-----+++-++  | node l r ihl ihr =>
-----+++-++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
-----+++-++    omega
-----+++-+ 
-----+++-+-omit [T2Space X] [T2Space Y] in
-----+++-+-/-- The pullback map is norm-nonincreasing. -/
-----+++-+-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----+++-+-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
-----+++-+-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
-----+++-+-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
-----+++-++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
-----+++-++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
-----+++-+ 
-----+++-+-/-- When `φ` is surjective, pullback is an isometry. -/
-----+++-+-theorem pullback_isometry_of_surjective
-----+++-+-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
-----+++-+-    ‖pullbackAlg φ f‖ = ‖f‖ := by
-----+++-+-  refine le_antisymm (norm_pullback_le φ f) ?_
-----+++-+-  rw [ContinuousMap.norm_le _ (by positivity)]
-----+++-+-  intro y; obtain ⟨x, rfl⟩ := hφ y
-----+++-+-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
-----+++-++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
-----+++-++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
-----+++-++  unfold logisticSigmoid
-----+++-++  rw [Real.exp_neg]
-----+++-++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
-----+++-++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
-----+++-++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----+++-++  field_simp; ring
-----+++-+ 
-----+++-+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----+++-+-theorem mem_fiberConst_of_injective
-----+++-+-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
-----+++-+-    g ∈ FiberConst φ := by
-----+++-+-  intro x x' h; exact congrArg g (hφ h)
-----+++-++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
-----+++-++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
-----+++-++  unfold softplus logisticSigmoid
-----+++-++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
-----+++-++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
-----+++-++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
-----+++-++  simp at this
-----+++-++  exact this
-----+++-+ 
-----+++-+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----+++-+-theorem fiberConst_eq_top_of_injective
-----+++-+-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
-----+++-+-    FiberConst φ = ⊤ := by
-----+++-+-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
-----+++-++/-- ShefferAlg is closed under affine pre-composition. -/
-----+++-++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
-----+++-++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
-----+++-++  obtain ⟨e, rfl⟩ := hf
-----+++-++  exact ⟨.affinePrecomp a b e, rfl⟩
-----+++-+ 
-----+++-+-omit [CompactSpace Y] [T2Space Y] in
-----+++-+-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
-----+++-+-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
-----+++-+-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
-----+++-+-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
-----+++-+-  intro x x' hφ; by_contra h_ne
-----+++-+-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
-----+++-+-    have := exists_continuous_zero_one_of_isClosed
-----+++-+-      (show IsClosed {x} from isClosed_singleton)
-----+++-+-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
-----+++-+-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
-----+++-+-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
-----+++-+-  replace h := SetLike.ext_iff.mp h g
-----+++-+-  simp_all +decide [FiberConst]
-----+++-+-  exact absurd (h hφ) (by simp +decide [hg])
-----+++-++/-- ShefferAlg is closed under affine combination. -/
-----+++-++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
-----+++-++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
-----+++-++  obtain ⟨ef, rfl⟩ := hf
-----+++-++  obtain ⟨eg, rfl⟩ := hg
-----+++-++  exact ⟨.affineComb α β γ ef eg, rfl⟩
-----+++-+ 
-----+++-+-/-! ### §2: Image factorization -/
-----+++-++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
-----+++-++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
-----+++-++  unfold softplus
-----+++-++  rw [Real.exp_neg]
-----+++-++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
-----+++-++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----+++-++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
-----+++-++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
-----+++-++  rw [this, Real.log_exp]
-----+++-+ 
-----+++-+-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
-----+++-+-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
-----+ +-+-
-----+-+-+-## References
-----+++-+-/-
-----+++-+-The corestriction `X → Set.range φ` is a quotient map.
-----+++-+--/
-----+++-+-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
-----+++-+-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
-----+++-+-  apply IsClosedMap.isQuotientMap;
-----+++-+-  · intro s hs;
-----+++-+-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
-----+++-+-    constructor <;> intro h;
-----+++-+-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
-----+++-+-    · convert h.preimage ( continuous_subtype_val ) using 1;
-----+++-+-      ext; simp [Set.rangeFactorization];
-----+++-+-      grind;
-----+++-+-  · exact continuous_induced_rng.mpr φ.continuous;
-----+++-+-  · exact Set.rangeFactorization_surjective
-----+ +-+-
-----+-+-+-* Reinhard Diestel, *Graph Theory*, 5th Edition, Springer, 2017
-----+-+-++The study of bridges in graph theory traces back to Euler's 1736 solution
-----+-+-++of the Königsberg Bridge Problem — widely considered the birth of graph
-----+-+-++theory. A bridge (or cut edge) is an edge whose removal disconnects the
-----+-+-++graph, making it a critical concept in network reliability and infrastructure
-----+-+-++analysis.
-----+-++--- a/Tropical/Basic.lean
-----+-+++++ b/Tropical/Basic.lean
-----+-++@@ -1,1315 +1,383 @@
-----+-++---- a/Tropical/Basic.lean
-----+-++-+++ b/Tropical/Basic.lean
-----+-++-@@ -1,930 +1,383 @@
-----+-++----- a/Tropical/Basic.lean
-----+-++--+++ b/Tropical/Basic.lean
-----+-++--@@ -1,545 +1,383 @@
-----+-++------ a/Tropical/Basic.lean
-----+-++---+++ b/Tropical/Basic.lean
-----+-++---@@ -1,383 +1,160 @@
-----+-++------- a/EML/Basic.lean
-----+-++----+++ b/EML/Basic.lean
-----+-++----@@ -1,277 +1,125 @@
-----+-++-----/-
-----+-++-----Copyright (c) 2026 Harmonic. All rights reserved.
-----+-++-----Released under Apache 2.0 license as described in the file LICENSE.
-----+-++------/
-----+-++---- import Mathlib
-----+-++---- 
-----+-++-----/-!
-----+-++-----# Pullback Stability of Universal Approximation
-----+-++----+/-! # CatalogBuild.EML.Basic
-----+-++---- 
-----+-++-----Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
-----+-++-----subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
-----+-++-----closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
-----+-++-----When `φ` is injective, this gives density in all of `C(X, ℝ)`.
-----+-++-----
-----+-++-----This establishes a transport principle: universal approximation results (like
-----+-++-----Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
-----+-++-----with the precise target being the fiber-constant functions.
-----+-++-----
-----+-++-----## Main definitions
-----+-++-----
-----+-++-----* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
-----+-++-----  fibers of `φ`.
-----+-++-----* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
-----+-++-----
-----+-++-----## Main results
-----+-++-----
-----+-++-----### Basic properties (§1)
-----+-++-----* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
-----+-++-----* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
-----+-++-----* `norm_pullback_le` — the pullback map is norm-nonincreasing.
-----+-++-----* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
-----+-++-----* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
-----+-++-----
-----+-++-----### Factorization (§2)
-----+-++-----* `fiberConst_subset_range_pullback` — every fiber-constant function factors
-----+-++-----  through `Set.range φ`, hence is a pullback (via Tietze extension).
-----+-++-----
-----+-++-----### Density transport (§3)
-----+-++-----* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
-----+-++-----  subalgebra equals `FiberConst φ`.
-----+-++-----* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
-----+-++-----
-----+-++-----### ε-approximation (§4)
-----+-++-----* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
-----+-++-----* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
-----+-++----+Auto-generated from theorem catalog database.
-----+-++----+Domain: EML
-----+-++----+Declarations: 15
-----+-++---- -/
-----+-++---- 
-----+-++-----open scoped Topology
-----+-++-----open Topology
-----+-++----+noncomputable section
-----+-++---- 
-----+-++-----variable {X Y : Type*}
-----+-++-----variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
-----+-++-----variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
-----+-++----+/-- The inverse for hyperbolic SPB is also negation. -/
-----+-++----+theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
-----+-++----+  simp [spbH]
-----+-++---- 
-----+-++-----/-! ### §1: Definitions and basic properties -/
-----+-++----+/-- Wick duality: SPB with negated second argument equals the "difference"
-----+-++----+in the hyperbolic SPB. This is the real-variable manifestation of the
-----+-++----+Wick rotation t → it. -/
-----+-++----+theorem wick_duality (x y : ℝ) :
-----+-++----+    spb x (-y) = (x - y) / (1 + x * y) := by
-----+-++----+  simp only [spb]
-----+-++----+  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
-----+-++----+  rw [heq]; ring
-----+-++---- 
-----+-++-----/-- Continuous functions on `X` that are constant on fibers of `φ`.
-----+-++-----This is the natural functional-analytic object associated to a feature map:
-----+-++-----it captures exactly the observables visible through `φ`. -/
-----+-++-----def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
-----+-++-----  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
-----+-++-----  algebraMap_mem' r := by intro x x' _; simp
-----+-++-----  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----+-++-----  zero_mem' := by intro x x' _; simp
-----+-++-----  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----+-++-----  one_mem' := by intro x x' _; simp
-----+-++----+/-- The tangent addition law IS the stereographic sum.
-----+-++----+tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
-----+-++----+theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
-----+-++----+    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
-----+-++----+  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
-----+-++----+      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
-----+-++----+  field_simp
-----+-++---- 
-----+-++-----/-- Pullback of continuous real-valued functions along `φ`. -/
-----+-++-----def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
-----+-++-----  toFun f := f.comp φ
-----+-++-----  map_zero' := by ext; simp
-----+-++-----  map_one' := by ext; simp
-----+-++-----  map_add' := by intros; ext; simp
-----+-++-----  map_mul' := by intros; ext; simp
-----+-++-----  commutes' := by intros; ext; simp
-----+-++----+/-- SPB expression trees — analogous to EML expression trees. -/
-----+-++----+inductive SPBExpr where
-----+-++----+  | zero : SPBExpr
-----+-++----+  | one : SPBExpr
-----+-++----+  | var : ℕ → SPBExpr
-----+-++----+  | node : SPBExpr → SPBExpr → SPBExpr
-----+-++----+  deriving Repr, BEq
-----+-++---- 
-----+-++-----@[simp]
-----+-++-----theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
-----+-++-----    pullbackAlg φ f x = f (φ x) := rfl
-----+-++----+/-- Evaluate an SPB expression. -/
-----+-++----+def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
-----+-++----+  match e with
-----+-++----+  | .zero => 0
-----+-++----+  | .one => 1
-----+-++----+  | .var n => vars n
-----+-++----+  | .node l r => spb (l.eval vars) (r.eval vars)
-----+-++---- 
-----+-++-----theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----+-++-----    pullbackAlg φ f ∈ FiberConst φ := by
-----+-++-----  intro x x' h; simp [h]
-----+-++----+/-- Depth of an SPB expression. -/
-----+-++----+def SPBExpr.depth : SPBExpr → ℕ
-----+-++----+  | .zero => 0
-----+-++----+  | .one => 0
-----+-++----+  | .var _ => 0
-----+-++----+  | .node l r => 1 + max l.depth r.depth
-----+-++---- 
-----+-++-----theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
-----+-++-----    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----+-++-----  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
-----+-++----+/-- Leaf count. -/
-----+-++----+def SPBExpr.leafCount : SPBExpr → ℕ
-----+-++----+  | .zero => 1
-----+-++----+  | .one => 1
-----+-++----+  | .var _ => 1
-----+-++----+  | .node l r => l.leafCount + r.leafCount
-----+-++---- 
-----+-++-----theorem range_comp_subalgebra_subset_fiberConst
-----+-++-----    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
-----+-++-----    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----+-++-----  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
-----+-++----+/-- Internal node count. -/
-----+-++----+def SPBExpr.nodeCount : SPBExpr → ℕ
-----+-++----+  | .zero => 0
-----+-++----+  | .one => 0
-----+-++----+  | .var _ => 0
-----+-++----+  | .node l r => 1 + l.nodeCount + r.nodeCount
-----+-++---- 
-----+-++-----/-- `FiberConst φ` is closed in the uniform topology. -/
-----+-++-----theorem fiberConst_closed (φ : C(X, Y)) :
-----+-++-----    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
-----+-++-----  refine isClosed_of_closure_subset ?_
-----+-++-----  intro g hg x x' h
-----+-++-----  rw [mem_closure_iff_nhds] at hg
-----+-++-----  contrapose! hg
-----+-++-----  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
-----+-++-----    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
-----+-++-----    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
-----+-++----+/-- Binary tree identity: leaves = internal nodes + 1. -/
-----+-++----+theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
-----+-++----+    e.leafCount = e.nodeCount + 1 := by
-----+-++----+  induction e with
-----+-++----+  | zero => rfl
-----+-++----+  | one => rfl
-----+-++----+  | var _ => rfl
-----+-++----+  | node l r ihl ihr =>
-----+-++----+    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
-----+-++----+    omega
-----+-++---- 
-----+-++-----omit [T2Space X] [T2Space Y] in
-----+-++-----/-- The pullback map is norm-nonincreasing. -/
-----+-++-----theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----+-++-----    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
-----+-++-----  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
-----+-++-----    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
-----+-++----+/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
-----+-++----+def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
-----+-++---- 
-----+-++-----/-- When `φ` is surjective, pullback is an isometry. -/
-----+-++-----theorem pullback_isometry_of_surjective
-----+-++-----    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
-----+-++-----    ‖pullbackAlg φ f‖ = ‖f‖ := by
-----+-++-----  refine le_antisymm (norm_pullback_le φ f) ?_
-----+-++-----  rw [ContinuousMap.norm_le _ (by positivity)]
-----+-++-----  intro y; obtain ⟨x, rfl⟩ := hφ y
-----+-++-----  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
-----+-++----+/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
-----+-++----+theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
-----+-++----+  unfold logisticSigmoid
-----+-++----+  rw [Real.exp_neg]
-----+-++----+  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
-----+-++----+  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
-----+-++----+  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----+-++----+  field_simp; ring
-----+-++---- 
-----+-++-----omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----+-++-----theorem mem_fiberConst_of_injective
-----+-++-----    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
-----+-++-----    g ∈ FiberConst φ := by
-----+-++-----  intro x x' h; exact congrArg g (hφ h)
-----+-++----+/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
-----+-++----+theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
-----+-++----+  unfold softplus logisticSigmoid
-----+-++----+  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
-----+-++----+  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
-----+-++----+  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
-----+-++----+  simp at this
-----+-++----+  exact this
-----+-++---- 
-----+-++-----omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----+-++-----theorem fiberConst_eq_top_of_injective
-----+-++-----    (φ : C(X, Y)) (hφ : Function.Injective φ) :
-----+-++-----    FiberConst φ = ⊤ := by
-----+-++-----  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
-----+-++----+/-- ShefferAlg is closed under affine pre-composition. -/
-----+-++----+theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
-----+-++----+    (fun x => f (a * x + b)) ∈ ShefferAlg := by
-----+-++----+  obtain ⟨e, rfl⟩ := hf
-----+-++----+  exact ⟨.affinePrecomp a b e, rfl⟩
-----+-++---- 
-----+-++-----omit [CompactSpace Y] [T2Space Y] in
-----+-++-----/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
-----+-++-----theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
-----+-++-----    FiberConst φ = ⊤ ↔ Function.Injective φ := by
-----+-++-----  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
-----+-++-----  intro x x' hφ; by_contra h_ne
-----+-++-----  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
-----+-++-----    have := exists_continuous_zero_one_of_isClosed
-----+-++-----      (show IsClosed {x} from isClosed_singleton)
-----+-++-----      (show IsClosed {x'} from isClosed_singleton) (by aesop)
-----+-++-----    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
-----+-++-----      this.choose_spec.2.1 (Set.mem_singleton x')⟩
-----+-++-----  replace h := SetLike.ext_iff.mp h g
-----+-++-----  simp_all +decide [FiberConst]
-----+-++-----  exact absurd (h hφ) (by simp +decide [hg])
-----+-++----+/-- ShefferAlg is closed under affine combination. -/
-----+-++----+theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
-----+-++----+    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
-----+-++----+  obtain ⟨ef, rfl⟩ := hf
-----+-++----+  obtain ⟨eg, rfl⟩ := hg
-----+-++----+  exact ⟨.affineComb α β γ ef eg, rfl⟩
-----+-++---- 
-----+-++-----/-! ### §2: Image factorization -/
-----+-++----+/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
-----+-++----+theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
-----+-++----+  unfold softplus
-----+-++----+  rw [Real.exp_neg]
-----+-++----+  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
-----+-++----+  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----+-++----+  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
-----+-++----+  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
-----+-++----+  rw [this, Real.log_exp]
-----+-++---- 
-----+-++-----instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
-----+-++-----  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
-----+-++-----
-----+-++-----/-
-----+-++-----The corestriction `X → Set.range φ` is a quotient map.
-----+-++------/
-----+-++-----theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
-----+-++-----    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
-----+-++-----  apply IsClosedMap.isQuotientMap;
-----+-++-----  · intro s hs;
-----+-++-----    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
-----+-++-----    constructor <;> intro h;
-----+-++-----    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
-----+-++-----    · convert h.preimage ( continuous_subtype_val ) using 1;
-----+-++-----      ext; simp [Set.rangeFactorization];
-----+-++-----      grind;
-----+-++-----  · exact continuous_induced_rng.mpr φ.continuous;
-----+-++-----  · exact Set.rangeFactorization_surjective
-----+-++-----
-----+-++-----/-- Lift a fiber-constant function to `Set.range φ`. -/
-----+-++-----noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
-----+-++-----    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
-----+-++-----  toFun z := g z.property.choose
-----+-++-----  continuous_toFun := by
-----+-++-----    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
-----+-++-----    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
-----+-++-----    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
-----+-++-----      ext x; apply hg
-----+-++-----      exact (Set.rangeFactorization φ x).property.choose_spec
-----+-++-----    rw [this]; exact g.continuous
-----+-++-----
-----+-++-----theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
-----+-++-----    (hg : g ∈ FiberConst φ) (x : X) :
-----+-++-----    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
-----+-++-----  simp only [fiberConstLift]
-----+-++-----  apply hg
-----+-++-----  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
-----+-++-----
-----+-++-----/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
-----+-++-----theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
-----+-++-----    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
-----+-++-----  intro g hg
-----+-++-----  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
-----+-++-----  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
-----+-++-----    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
-----+-++-----  refine ⟨F, ?_⟩
-----+-++-----  ext x
-----+-++-----  simp only [pullbackAlg_apply]
-----+-++-----  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
-----+-++-----    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
-----+-++-----    simp [ContinuousMap.comp_apply] at this; exact this
-----+-++-----  rw [key, fiberConstLift_comp]
-----+-++-----
-----+-++-----/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
-----+-++-----theorem fiberConst_eq_range_pullback_of_surjective
-----+-++-----    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
-----+-++-----    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
-----+-++-----  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
-----+-++-----    (range_pullback_subset_fiberConst φ)
-----+-++-----
-----+-++-----/-! ### §3: Density transport -/
-----+-++-----
-----+-++-----/-
-----+-++-----The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
-----+-++------/
-----+-++-----theorem closure_range_pullback_eq_fiberConst
-----+-++-----    (φ : C(X, Y))
-----+-++-----    (A : Subalgebra ℝ C(Y, ℝ))
-----+-++-----    (hA : Dense (A : Set C(Y, ℝ))) :
-----+-++-----    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
-----+-++-----      = (FiberConst φ : Set C(X, ℝ)) := by
-----+-++-----  refine' le_antisymm ( closure_minimal _ _ ) _;
-----+-++-----  · exact range_comp_subalgebra_subset_fiberConst φ A;
-----+-++-----  · exact fiberConst_closed φ;
-----+-++-----  · intro g hg;
-----+-++-----    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
-----+-++-----    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
-----+-++-----      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
-----+-++-----    rw [ Metric.mem_closure_iff ];
-----+-++-----    intro ε εpos;
-----+-++-----    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
-----+-++-----    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
-----+-++-----    nontriviality;
-----+-++-----    rw [ hF, dist_eq_norm ] at *;
-----+-++-----    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
-----+-++-----
-----+-++-----/-
-----+-++-----Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
-----+-++------/
-----+-++-----theorem closure_range_pullback_eq_top_of_injective
-----+-++-----    (φ : C(X, Y))
-----+-++-----    (hφ : Function.Injective φ)
-----+-++-----    (A : Subalgebra ℝ C(Y, ℝ))
-----+-++-----    (hA : Dense (A : Set C(Y, ℝ))) :
-----+-++-----    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
-----+-++-----  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
-----+-++-----  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
-----+-++-----
-----+-++-----/-! ### §4: ε-approximation -/
-----+-++-----
-----+-++-----/-
-----+-++-----ε-approximation within `FiberConst φ`.
-----+-++------/
-----+-++-----theorem exists_pullback_approx_of_fiberConst
-----+-++-----    (φ : C(X, Y))
-----+-++-----    (A : Subalgebra ℝ C(Y, ℝ))
-----+-++-----    (hA : Dense (A : Set C(Y, ℝ)))
-----+-++-----    (g : C(X, ℝ))
-----+-++-----    (hg : g ∈ FiberConst φ)
-----+-++-----    {ε : ℝ} (hε : 0 < ε) :
-----+-++-----    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----+-++-----  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
-----+-++-----    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
-----+-++-----  rw [ Metric.mem_closure_iff ] at h_closure;
-----+-++-----  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
-----+-++-----
-----+-++-----/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
-----+-++-----theorem exists_pullback_approx_of_injective
-----+-++-----    (φ : C(X, Y))
-----+-++-----    (hφ : Function.Injective φ)
-----+-++-----    (A : Subalgebra ℝ C(Y, ℝ))
-----+-++-----    (hA : Dense (A : Set C(Y, ℝ)))
-----+-++-----    (g : C(X, ℝ))
-----+-++-----    {ε : ℝ} (hε : 0 < ε) :
-----+-++-----    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----+-++-----  exact exists_pullback_approx_of_fiberConst φ A hA g
-----+-++-----    (mem_fiberConst_of_injective φ hφ g) hε+end+/-
-----+-++---+Copyright (c) 2025. All rights reserved.
-----+-++---+Released under Apache 2.0 license as described in the file LICENSE.
-----+-++---+-/
-----+-++---+import Mathlib
-----+-++---+
-----+-++---+/-!
-----+-++---+# GL₃ Tropical Satake: Core Definitions
-----+-++---+
-----+-++---+This file establishes the foundational types and operations for the GL₃ tropical
-----+-++---+Satake finite-determinacy theory.
-----+-++---+
-----+-++---+## Overview
-----+-++---+
-----+-++---+For GL₃, a **dominant coweight** is a triple `(a, b, c) ∈ ℕ³` with `a ≥ b ≥ c`.
-----+-++---+The **dominant box** `BoxDom(B)` is the finite set of dominant coweights with `a ≤ B`.
-----+-++---+
-----+-++---+We define three families of **tropical Satake observables**, corresponding to the
-----+-++---+three fundamental representations `ω₁, ω₂, ω₃` of GL₃:
-----+-++---+
-----+-++---+1. **Rank-1 profile** (`rank1Profile`): tropical convolution with the standard
-----+-++---+   representation character. Uses the weights `e₁, e₂, e₃`.
-----+-++---+2. **Rank-2 profile** (`rank2Profile`): tropical convolution with the exterior square
-----+-++---+   character. Uses the weights `e₁+e₂, e₁+e₃, e₂+e₃`.
-----+-++---+3. **Edge moment** (`edgeMoment`): tropical convolution with the determinant character
-----+-++---+   `ω₃ = (1,1,1)`. This is the key reconstruction tool: as a shift operator, it
-----+-++---+   recovers function values without the information loss inherent in max operations.
-----+-++---+
-----+-++---+The finite-determinacy theorem (proved in `FiniteDeterminacy.lean`) shows that
-----+-++---+equality of these observables on finite test sets forces equality of the underlying
-----+-++---+functions.
-----+-++---+-/
-----+-++---+
-----+-++---+open Finset
-----+-++---+
-----+-++---+/-! ### Dominance and support conditions -/
-----+-++---+
-----+-++---+/-- A triple `(a, b, c)` is dominant if `a ≥ b ≥ c`. -/
-----+-++---+def IsDominant (a b c : ℕ) : Prop := b ≤ a ∧ c ≤ b
-----+-++---+
-----+-++---+/-- A function on `ℕ³` has finite support within box `B` if it vanishes outside
-----+-++---+    the dominant box `{(a,b,c) : b ≤ a, c ≤ b, a ≤ B}`. -/
-----+-++---+def FiniteSupportWithin (B : ℕ) (f : ℕ → ℕ → ℕ → ℤ) : Prop :=
-----+-++---+  ∀ a b c : ℕ, (B < a ∨ a < b ∨ b < c) → f a b c = 0
-----+-++---+
-----+-++---+/-- The box `BoxDom(B)` as a `Finset` of triples. -/
-----+-++---+def boxDomFinset (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
-----+-++---+  (Finset.range (B + 1) ×ˢ Finset.range (B + 1) ×ˢ Finset.range (B + 1)).filter
-----+-++---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
-----+-++---+
-----+-++---+lemma mem_boxDomFinset {B : ℕ} {a b c : ℕ} :
-----+-++---+    (a, b, c) ∈ boxDomFinset B ↔ a ≤ B ∧ b ≤ a ∧ c ≤ b := by
-----+-++---+  simp [boxDomFinset, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
-----+-++---+  omega
-----+-++---+
-----+-++---+/-! ### Tropical Satake observables -/
-----+-++---+
-----+-++---+/-- **Rank-1 profile**: tropical convolution with the standard representation `ω₁`.
-----+-++---+
-----+-++---+The weights of the standard representation of GL₃ are `e₁ = (1,0,0)`,
-----+-++---+`e₂ = (0,1,0)`, `e₃ = (0,0,1)`. The rank-1 profile at `(a,b,c)` is
-----+-++---+`max{f(a-1,b,c), f(a,b-1,c), f(a,b,c-1)}` with appropriate guards for ℕ subtraction.
-----+-++---+
-----+-++---+Note: Invalid shifts (where subtraction would go below 0) contribute the value `0`,
-----+-++---+which serves as the tropical "zero" in this ℤ-valued model. -/
-----+-++---+def rank1Profile (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
-----+-++---+  let v1 := if 1 ≤ a then f (a - 1) b c else 0
-----+-++---+  let v2 := if 1 ≤ b then f a (b - 1) c else 0
-----+-++---+  let v3 := if 1 ≤ c then f a b (c - 1) else 0
-----+-++---+  max v1 (max v2 v3)
-----+-++---+
-----+-++---+/-- **Rank-2 profile**: tropical convolution with the exterior square `ω₂ = ∧²`.
-----+-++---+
-----+-++---+The weights of `∧²(ℂ³)` are `e₁+e₂ = (1,1,0)`, `e₁+e₃ = (1,0,1)`,
-----+-++---+`e₂+e₃ = (0,1,1)`. The rank-2 profile at `(a,b,c)` is
-----+-++---+`max{f(a-1,b-1,c), f(a-1,b,c-1), f(a,b-1,c-1)}`. -/
-----+-++---+def rank2Profile (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
-----+-++---+  let v1 := if 1 ≤ a ∧ 1 ≤ b then f (a - 1) (b - 1) c else 0
-----+-++---+  let v2 := if 1 ≤ a ∧ 1 ≤ c then f (a - 1) b (c - 1) else 0
-----+-++---+  let v3 := if 1 ≤ b ∧ 1 ≤ c then f a (b - 1) (c - 1) else 0
-----+-++---+  max v1 (max v2 v3)
-----+-++---+
-----+-++---+/-- **Edge moment**: tropical convolution with the determinant character `ω₃ = (1,1,1)`.
-----+-++---+
-----+-++---+This is the shift operator: `edgeMoment f (a,b,c) = f(a-1, b-1, c-1)`.
-----+-++---+As a representation-theoretic operation, it corresponds to convolution with the
-----+-++---+one-dimensional determinant representation `det = ∧³(ℂ³)`. Unlike the rank-1 and
-----+-++---+rank-2 profiles (which use `max` and can lose information), the determinant
-----+-++---+convolution perfectly preserves all function values.
-----+-++---+
-----+-++---+This is the key observable that makes finite determinacy possible: it acts as an
-----+-++---+exact reconstruction tool rather than a lossy tropical projection. -/
-----+-++---+def edgeMoment (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
-----+-++---+  if 1 ≤ a ∧ 1 ≤ b ∧ 1 ≤ c then f (a - 1) (b - 1) (c - 1) else 0
-----+-++---+
-----+-++---+/-- Combined triple convolution observable using both rank-1 and rank-2 generators.
-----+-++---+    This packages rank-1 and rank-2 data together for the combined hypothesis form. -/
-----+-++---+def tripleConvObservable (f : ℕ → ℕ → ℕ → ℤ) (t s : ℕ × ℕ × ℕ) : ℤ :=
-----+-++---+  rank1Profile f t.1 t.2.1 t.2.2 + rank2Profile f s.1 s.2.1 s.2.2
-----+-++---+
-----+-++---+/-! ### Finite test ranges -/
-----+-++---+
-----+-++---+/-- The finite range of rank-1 test parameters determined by box bound `B`. -/
-----+-++---+def finiteRank1Range (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
-----+-++---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
-----+-++---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
-----+-++---+
-----+-++---+/-- The finite range of rank-2 test parameters determined by box bound `B`. -/
-----+-++---+def finiteRank2Range (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
-----+-++---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
-----+-++---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
-----+-++---+
-----+-++---+/-- The finite range of edge moment test parameters determined by box bound `B`.
-----+-++---+    These are the shifted dominant coweights `(a+1, b+1, c+1)` for `(a,b,c) ∈ BoxDom(B)`. -/
-----+-++---+def finiteEdgeMomentRange (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
-----+-++---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
-----+-++---+    fun ⟨a, b, c⟩ => 1 ≤ c ∧ c ≤ b ∧ b ≤ a
-----+-++---+
-----+-++---+/-! ### Key computation lemmas -/
-----+-++---+
-----+-++---+/-- The edge moment at a shifted point exactly recovers the function value.
-----+-++---+    This is the fundamental reconstruction identity. -/
-----+-++---+@[simp]
-----+-++---+lemma edgeMoment_succ (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) :
-----+-++---+    edgeMoment f (a + 1) (b + 1) (c + 1) = f a b c := by
-----+-++---+  simp [edgeMoment]
-----+-++---+
-----+-++---+/-- Shifted dominant coweights lie in the edge moment range. -/
-----+-++---+lemma shifted_mem_finiteEdgeMomentRange {B a b c : ℕ}
-----+-++---+    (haB : a ≤ B) (hab : b ≤ a) (hbc : c ≤ b) :
-----+-++---+    (a + 1, b + 1, c + 1) ∈ finiteEdgeMomentRange B := by
-----+-++---+  simp [finiteEdgeMomentRange, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
-----+-++---+  omega
-----+-++---+
-----+-++---+/-- The rank-2 profile at the floor level `(a+1, b+1, 0)` yields `max(f(a,b,0), 0)`.
-----+-++---+    When `f` is nonneg-valued on the floor, this equals `f(a,b,0)`.
-----+-++---+    The `c = 0` case is special because both `ω₂`-weight shifts involving `c-1`
-----+-++---+    fall outside `ℕ`, leaving only the `(1,1,0)`-weight shift. -/
-----+-++---+lemma rank2Profile_floor_level (f : ℕ → ℕ → ℕ → ℤ) (a b : ℕ) :
-----+-++---+    rank2Profile f (a + 1) (b + 1) 0 = max (f a b 0) 0 := by
-----+-++---+  simp [rank2Profile]
-----+-++---+
-----+-++---+/-- For functions supported in `BoxDom(B)`, values at `a > B` vanish. -/
-----+-++---+lemma FiniteSupportWithin.vanish_above {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
-----+-++---+    (hf : FiniteSupportWithin B f) {a : ℕ} (ha : B < a) (b c : ℕ) :
-----+-++---+    f a b c = 0 := by
-----+-++---+  exact hf a b c (Or.inl ha)
-----+-++---+
-----+-++---+/-- For functions supported in `BoxDom(B)`, values outside dominant cone vanish. -/
-----+-++---+lemma FiniteSupportWithin.vanish_nondominant {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
-----+-++---+    (hf : FiniteSupportWithin B f) {a b c : ℕ} (h : a < b ∨ b < c) :
-----+-++---+    f a b c = 0 := by
-----+-++---+  exact hf a b c (by tauto)
-----+-++---+
-----+-++---+/-- Bounded-support functions vanish outside the box: explicit formulation. -/
-----+-++---+lemma bounded_support_implies_vanishing_outside {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
-----+-++---+    (hf : FiniteSupportWithin B f) {a b c : ℕ}
-----+-++---+    (h : ¬(a ≤ B ∧ b ≤ a ∧ c ≤ b)) :
-----+-++---+    f a b c = 0 := by
-----+-++---+  apply hf; push_neg at h; omega+--- a/EML/Basic.lean
-----+-++--++++ b/EML/Basic.lean
-----+-++--+@@ -1,277 +1,125 @@
-----+-++--+-/-
-----+-++--+-Copyright (c) 2026 Harmonic. All rights reserved.
-----+-++--+-Released under Apache 2.0 license as described in the file LICENSE.
-----+-++--+--/
-----+-++--+ import Mathlib
-----+-++--+ 
-----+-++--+-/-!
-----+-++--+-# Pullback Stability of Universal Approximation
-----+-++--++/-! # CatalogBuild.EML.Basic
-----+-++--+ 
-----+-++--+-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
-----+-++--+-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
-----+-++--+-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
-----+-++--+-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
-----+-++--+-
-----+-++--+-This establishes a transport principle: universal approximation results (like
-----+-++--+-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
-----+-++--+-with the precise target being the fiber-constant functions.
-----+-++--+-
-----+-++--+-## Main definitions
-----+-++--+-
-----+-++--+-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
-----+-++--+-  fibers of `φ`.
-----+-++--+-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
-----+-++--+-
-----+-++--+-## Main results
-----+-++--+-
-----+-++--+-### Basic properties (§1)
-----+-++--+-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
-----+-++--+-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
-----+-++--+-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
-----+-++--+-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
-----+-++--+-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
-----+-++--+-
-----+-++--+-### Factorization (§2)
-----+-++--+-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
-----+-++--+-  through `Set.range φ`, hence is a pullback (via Tietze extension).
-----+-++--+-
-----+-++--+-### Density transport (§3)
-----+-++--+-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
-----+-++--+-  subalgebra equals `FiberConst φ`.
-----+-++--+-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
-----+-++--+-
-----+-++--+-### ε-approximation (§4)
-----+-++--+-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
-----+-++--+-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
-----+-++--++Auto-generated from theorem catalog database.
-----+-++--++Domain: EML
-----+-++--++Declarations: 15
-----+-++--+ -/
-----+-++--+ 
-----+-++--+-open scoped Topology
-----+-++--+-open Topology
-----+-++--++noncomputable section
-----+-++--+ 
-----+-++--+-variable {X Y : Type*}
-----+-++--+-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
-----+-++--+-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
-----+-++--++/-- The inverse for hyperbolic SPB is also negation. -/
-----+-++--++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
-----+-++--++  simp [spbH]
-----+-++--+ 
-----+-++--+-/-! ### §1: Definitions and basic properties -/
-----+-++--++/-- Wick duality: SPB with negated second argument equals the "difference"
-----+-++--++in the hyperbolic SPB. This is the real-variable manifestation of the
-----+-++--++Wick rotation t → it. -/
-----+-++--++theorem wick_duality (x y : ℝ) :
-----+-++--++    spb x (-y) = (x - y) / (1 + x * y) := by
-----+-++--++  simp only [spb]
-----+-++--++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
-----+-++--++  rw [heq]; ring
-----+-++--+ 
-----+-++--+-/-- Continuous functions on `X` that are constant on fibers of `φ`.
-----+-++--+-This is the natural functional-analytic object associated to a feature map:
-----+-++--+-it captures exactly the observables visible through `φ`. -/
-----+-++--+-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
-----+-++--+-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
-----+-++--+-  algebraMap_mem' r := by intro x x' _; simp
-----+-++--+-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----+-++--+-  zero_mem' := by intro x x' _; simp
-----+-++--+-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----+-++--+-  one_mem' := by intro x x' _; simp
-----+-++--++/-- The tangent addition law IS the stereographic sum.
-----+-++--++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
-----+-++--++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
-----+-++--++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
-----+-++--++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
-----+-++--++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
-----+-++--++  field_simp
-----+-++--+ 
-----+-++--+-/-- Pullback of continuous real-valued functions along `φ`. -/
-----+-++--+-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
-----+-++--+-  toFun f := f.comp φ
-----+-++--+-  map_zero' := by ext; simp
-----+-++--+-  map_one' := by ext; simp
-----+-++--+-  map_add' := by intros; ext; simp
-----+-++--+-  map_mul' := by intros; ext; simp
-----+-++--+-  commutes' := by intros; ext; simp
-----+-++--++/-- SPB expression trees — analogous to EML expression trees. -/
-----+-++--++inductive SPBExpr where
-----+-++--++  | zero : SPBExpr
-----+-++--++  | one : SPBExpr
-----+-++--++  | var : ℕ → SPBExpr
-----+-++--++  | node : SPBExpr → SPBExpr → SPBExpr
-----+-++--++  deriving Repr, BEq
-----+-++--+ 
-----+-++--+-@[simp]
-----+-++--+-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
-----+-++--+-    pullbackAlg φ f x = f (φ x) := rfl
-----+-++--++/-- Evaluate an SPB expression. -/
-----+-++--++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
-----+-++--++  match e with
-----+-++--++  | .zero => 0
-----+-++--++  | .one => 1
-----+-++--++  | .var n => vars n
-----+-++--++  | .node l r => spb (l.eval vars) (r.eval vars)
-----+-++--+ 
-----+-++--+-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----+-++--+-    pullbackAlg φ f ∈ FiberConst φ := by
-----+-++--+-  intro x x' h; simp [h]
-----+-++--++/-- Depth of an SPB expression. -/
-----+-++--++def SPBExpr.depth : SPBExpr → ℕ
-----+-++--++  | .zero => 0
-----+-++--++  | .one => 0
-----+-++--++  | .var _ => 0
-----+-++--++  | .node l r => 1 + max l.depth r.depth
-----+-++--+ 
-----+-++--+-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
-----+-++--+-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----+-++--+-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
-----+-++--++/-- Leaf count. -/
-----+-++--++def SPBExpr.leafCount : SPBExpr → ℕ
-----+-++--++  | .zero => 1
-----+-++--++  | .one => 1
-----+-++--++  | .var _ => 1
-----+-++--++  | .node l r => l.leafCount + r.leafCount
-----+-++--+ 
-----+-++--+-theorem range_comp_subalgebra_subset_fiberConst
-----+-++--+-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
-----+-++--+-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----+-++--+-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
-----+-++--++/-- Internal node count. -/
-----+-++--++def SPBExpr.nodeCount : SPBExpr → ℕ
-----+-++--++  | .zero => 0
-----+-++--++  | .one => 0
-----+-++--++  | .var _ => 0
-----+-++--++  | .node l r => 1 + l.nodeCount + r.nodeCount
-----+-++--+ 
-----+-++--+-/-- `FiberConst φ` is closed in the uniform topology. -/
-----+-++--+-theorem fiberConst_closed (φ : C(X, Y)) :
-----+-++--+-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
-----+-++--+-  refine isClosed_of_closure_subset ?_
-----+-++--+-  intro g hg x x' h
-----+-++--+-  rw [mem_closure_iff_nhds] at hg
-----+-++--+-  contrapose! hg
-----+-++--+-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
-----+-++--+-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
-----+-++--+-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
-----+-++--++/-- Binary tree identity: leaves = internal nodes + 1. -/
-----+-++--++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
-----+-++--++    e.leafCount = e.nodeCount + 1 := by
-----+-++--++  induction e with
-----+-++--++  | zero => rfl
-----+-++--++  | one => rfl
-----+-++--++  | var _ => rfl
-----+-++--++  | node l r ihl ihr =>
-----+-++--++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
-----+-++--++    omega
-----+-++--+ 
-----+-++--+-omit [T2Space X] [T2Space Y] in
-----+-++--+-/-- The pullback map is norm-nonincreasing. -/
-----+-++--+-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----+-++--+-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
-----+-++--+-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
-----+-++--+-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
-----+-++--++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
-----+-++--++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
-----+-++--+ 
-----+-++--+-/-- When `φ` is surjective, pullback is an isometry. -/
-----+-++--+-theorem pullback_isometry_of_surjective
-----+-++--+-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
-----+-++--+-    ‖pullbackAlg φ f‖ = ‖f‖ := by
-----+-++--+-  refine le_antisymm (norm_pullback_le φ f) ?_
-----+-++--+-  rw [ContinuousMap.norm_le _ (by positivity)]
-----+-++--+-  intro y; obtain ⟨x, rfl⟩ := hφ y
-----+-++--+-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
-----+-++--++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
-----+-++--++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
-----+-++--++  unfold logisticSigmoid
-----+-++--++  rw [Real.exp_neg]
-----+-++--++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
-----+-++--++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
-----+-++--++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----+-++--++  field_simp; ring
-----+-++--+ 
-----+-++--+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----+-++--+-theorem mem_fiberConst_of_injective
-----+-++--+-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
-----+-++--+-    g ∈ FiberConst φ := by
-----+-++--+-  intro x x' h; exact congrArg g (hφ h)
-----+-++--++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
-----+-++--++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
-----+-++--++  unfold softplus logisticSigmoid
-----+-++--++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
-----+-++--++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
-----+-++--++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
-----+-++--++  simp at this
-----+-++--++  exact this
-----+-++--+ 
-----+-++--+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----+-++--+-theorem fiberConst_eq_top_of_injective
-----+-++--+-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
-----+-++--+-    FiberConst φ = ⊤ := by
-----+-++--+-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
-----+-++--++/-- ShefferAlg is closed under affine pre-composition. -/
-----+-++--++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
-----+-++--++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
-----+-++--++  obtain ⟨e, rfl⟩ := hf
-----+-++--++  exact ⟨.affinePrecomp a b e, rfl⟩
-----+-++--+ 
-----+-++--+-omit [CompactSpace Y] [T2Space Y] in
-----+-++--+-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
-----+-++--+-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
-----+-++--+-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
-----+-++--+-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
-----+-++--+-  intro x x' hφ; by_contra h_ne
-----+-++--+-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
-----+-++--+-    have := exists_continuous_zero_one_of_isClosed
-----+-++--+-      (show IsClosed {x} from isClosed_singleton)
-----+-++--+-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
-----+-++--+-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
-----+-++--+-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
-----+-++--+-  replace h := SetLike.ext_iff.mp h g
-----+-++--+-  simp_all +decide [FiberConst]
-----+-++--+-  exact absurd (h hφ) (by simp +decide [hg])
-----+-++--++/-- ShefferAlg is closed under affine combination. -/
-----+-++--++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
-----+-++--++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
-----+-++--++  obtain ⟨ef, rfl⟩ := hf
-----+-++--++  obtain ⟨eg, rfl⟩ := hg
-----+-++--++  exact ⟨.affineComb α β γ ef eg, rfl⟩
-----+-++--+ 
-----+-++--+-/-! ### §2: Image factorization -/
-----+-++--++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
-----+-++--++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
-----+-++--++  unfold softplus
-----+-++--++  rw [Real.exp_neg]
-----+-++--++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
-----+-++--++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----+-++--++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
-----+-++--++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
-----+-++--++  rw [this, Real.log_exp]
-----+-++--+ 
-----+-++--+-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
-----+-++--+-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
-----+-++--+-
-----+-++--+-/-
-----+-++--+-The corestriction `X → Set.range φ` is a quotient map.
-----+-++--+--/
-----+-++--+-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
-----+-++--+-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
-----+-++--+-  apply IsClosedMap.isQuotientMap;
-----+-++--+-  · intro s hs;
-----+-++--+-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
-----+-++--+-    constructor <;> intro h;
-----+-++--+-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
-----+-++--+-    · convert h.preimage ( continuous_subtype_val ) using 1;
-----+-++--+-      ext; simp [Set.rangeFactorization];
-----+-++--+-      grind;
-----+-++--+-  · exact continuous_induced_rng.mpr φ.continuous;
-----+-++--+-  · exact Set.rangeFactorization_surjective
-----+-++--+-
-----+-++--+-/-- Lift a fiber-constant function to `Set.range φ`. -/
-----+-++--+-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
-----+-++--+-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
-----+-++--+-  toFun z := g z.property.choose
-----+-++--+-  continuous_toFun := by
-----+-++--+-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
-----+-++--+-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
-----+-++--+-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
-----+-++--+-      ext x; apply hg
-----+-++--+-      exact (Set.rangeFactorization φ x).property.choose_spec
-----+-++--+-    rw [this]; exact g.continuous
-----+-++--+-
-----+-++--+-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
-----+-++--+-    (hg : g ∈ FiberConst φ) (x : X) :
-----+-++--+-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
-----+-++--+-  simp only [fiberConstLift]
-----+-++--+-  apply hg
-----+-++--+-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
-----+-++--+-
-----+-++--+-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
-----+-++--+-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
-----+-++--+-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
-----+-++--+-  intro g hg
-----+-++--+-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
-----+-++--+-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
-----+-++--+-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
-----+-++--+-  refine ⟨F, ?_⟩
-----+-++--+-  ext x
-----+-++--+-  simp only [pullbackAlg_apply]
-----+-++--+-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
-----+-++--+-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
-----+-++--+-    simp [ContinuousMap.comp_apply] at this; exact this
-----+-++--+-  rw [key, fiberConstLift_comp]
-----+-++--+-
-----+-++--+-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
-----+-++--+-theorem fiberConst_eq_range_pullback_of_surjective
-----+-++--+-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
-----+-++--+-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
-----+-++--+-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
-----+-++--+-    (range_pullback_subset_fiberConst φ)
-----+-++--+-
-----+-++--+-/-! ### §3: Density transport -/
-----+-++--+-
-----+-++--+-/-
-----+-++--+-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
-----+-++--+--/
-----+-++--+-theorem closure_range_pullback_eq_fiberConst
-----+-++--+-    (φ : C(X, Y))
-----+-++--+-    (A : Subalgebra ℝ C(Y, ℝ))
-----+-++--+-    (hA : Dense (A : Set C(Y, ℝ))) :
-----+-++--+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
-----+-++--+-      = (FiberConst φ : Set C(X, ℝ)) := by
-----+-++--+-  refine' le_antisymm ( closure_minimal _ _ ) _;
-----+-++--+-  · exact range_comp_subalgebra_subset_fiberConst φ A;
-----+-++--+-  · exact fiberConst_closed φ;
-----+-++--+-  · intro g hg;
-----+-++--+-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
-----+-++--+-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
-----+-++--+-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
-----+-++--+-    rw [ Metric.mem_closure_iff ];
-----+-++--+-    intro ε εpos;
-----+-++--+-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
-----+-++--+-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
-----+-++--+-    nontriviality;
-----+-++--+-    rw [ hF, dist_eq_norm ] at *;
-----+-++--+-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
-----+-++--+-
-----+-++--+-/-
-----+-++--+-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
-----+-++--+--/
-----+-++--+-theorem closure_range_pullback_eq_top_of_injective
-----+-++--+-    (φ : C(X, Y))
-----+-++--+-    (hφ : Function.Injective φ)
-----+-++--+-    (A : Subalgebra ℝ C(Y, ℝ))
-----+-++--+-    (hA : Dense (A : Set C(Y, ℝ))) :
-----+-++--+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
-----+-++--+-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
-----+-++--+-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
-----+-++--+-
-----+-++--+-/-! ### §4: ε-approximation -/
-----+-++--+-
-----+-++--+-/-
-----+-++--+-ε-approximation within `FiberConst φ`.
-----+-++--+--/
-----+-++--+-theorem exists_pullback_approx_of_fiberConst
-----+-++--+-    (φ : C(X, Y))
-----+-++--+-    (A : Subalgebra ℝ C(Y, ℝ))
-----+-++--+-    (hA : Dense (A : Set C(Y, ℝ)))
-----+-++--+-    (g : C(X, ℝ))
-----+-++--+-    (hg : g ∈ FiberConst φ)
-----+-++--+-    {ε : ℝ} (hε : 0 < ε) :
-----+-++--+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----+-++--+-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
-----+-++--+-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
-----+-++--+-  rw [ Metric.mem_closure_iff ] at h_closure;
-----+-++--+-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
-----+-++--+-
-----+-++--+-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
-----+-++--+-theorem exists_pullback_approx_of_injective
-----+-++--+-    (φ : C(X, Y))
-----+-++--+-    (hφ : Function.Injective φ)
-----+-++--+-    (A : Subalgebra ℝ C(Y, ℝ))
-----+-++--+-    (hA : Dense (A : Set C(Y, ℝ)))
-----+-++--+-    (g : C(X, ℝ))
-----+-++--+-    {ε : ℝ} (hε : 0 < ε) :
-----+-++--+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----+-++--+-  exact exists_pullback_approx_of_fiberConst φ A hA g
-----+-++--+-    (mem_fiberConst_of_injective φ hφ g) hε+end+--- a/EML/Basic.lean
-----+-++-++++ b/EML/Basic.lean
-----+-++-+@@ -1,277 +1,125 @@
-----+-++-+-/-
-----+-++-+-Copyright (c) 2026 Harmonic. All rights reserved.
-----+-++-+-Released under Apache 2.0 license as described in the file LICENSE.
-----+-++-+--/
-----+-++-+ import Mathlib
-----+-++-+ 
-----+-++-+-/-!
-----+-++-+-# Pullback Stability of Universal Approximation
-----+-++-++/-! # CatalogBuild.EML.Basic
-----+-++-+ 
-----+-++-+-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
-----+-++-+-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
-----+-++-+-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
-----+-++-+-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
-----+-++-+-
-----+-++-+-This establishes a transport principle: universal approximation results (like
-----+-++-+-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
-----+-++-+-with the precise target being the fiber-constant functions.
-----+-++-+-
-----+-++-+-## Main definitions
-----+-++-+-
-----+-++-+-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
-----+-++-+-  fibers of `φ`.
-----+-++-+-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
-----+-++-+-
-----+-++-+-## Main results
-----+-++-+-
-----+-++-+-### Basic properties (§1)
-----+-++-+-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
-----+-++-+-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
-----+-++-+-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
-----+-++-+-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
-----+-++-+-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
-----+-++-+-
-----+-++-+-### Factorization (§2)
-----+-++-+-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
-----+-++-+-  through `Set.range φ`, hence is a pullback (via Tietze extension).
-----+-++-+-
-----+-++-+-### Density transport (§3)
-----+-++-+-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
-----+-++-+-  subalgebra equals `FiberConst φ`.
-----+-++-+-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
-----+-++-+-
-----+-++-+-### ε-approximation (§4)
-----+-++-+-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
-----+-++-+-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
-----+-++-++Auto-generated from theorem catalog database.
-----+-++-++Domain: EML
-----+-++-++Declarations: 15
-----+-++-+ -/
-----+-++-+ 
-----+-++-+-open scoped Topology
-----+-++-+-open Topology
-----+-++-++noncomputable section
-----+-++-+ 
-----+-++-+-variable {X Y : Type*}
-----+-++-+-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
-----+-++-+-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
-----+-++-++/-- The inverse for hyperbolic SPB is also negation. -/
-----+-++-++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
-----+-++-++  simp [spbH]
-----+-++-+ 
-----+-++-+-/-! ### §1: Definitions and basic properties -/
-----+-++-++/-- Wick duality: SPB with negated second argument equals the "difference"
-----+-++-++in the hyperbolic SPB. This is the real-variable manifestation of the
-----+-++-++Wick rotation t → it. -/
-----+-++-++theorem wick_duality (x y : ℝ) :
-----+-++-++    spb x (-y) = (x - y) / (1 + x * y) := by
-----+-++-++  simp only [spb]
-----+-++-++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
-----+-++-++  rw [heq]; ring
-----+-++-+ 
-----+-++-+-/-- Continuous functions on `X` that are constant on fibers of `φ`.
-----+-++-+-This is the natural functional-analytic object associated to a feature map:
-----+-++-+-it captures exactly the observables visible through `φ`. -/
-----+-++-+-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
-----+-++-+-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
-----+-++-+-  algebraMap_mem' r := by intro x x' _; simp
-----+-++-+-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----+-++-+-  zero_mem' := by intro x x' _; simp
-----+-++-+-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----+-++-+-  one_mem' := by intro x x' _; simp
-----+-++-++/-- The tangent addition law IS the stereographic sum.
-----+-++-++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
-----+-++-++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
-----+-++-++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
-----+-++-++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
-----+-++-++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
-----+-++-++  field_simp
-----+-++-+ 
-----+-++-+-/-- Pullback of continuous real-valued functions along `φ`. -/
-----+-++-+-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
-----+-++-+-  toFun f := f.comp φ
-----+-++-+-  map_zero' := by ext; simp
-----+-++-+-  map_one' := by ext; simp
-----+-++-+-  map_add' := by intros; ext; simp
-----+-++-+-  map_mul' := by intros; ext; simp
-----+-++-+-  commutes' := by intros; ext; simp
-----+-++-++/-- SPB expression trees — analogous to EML expression trees. -/
-----+-++-++inductive SPBExpr where
-----+-++-++  | zero : SPBExpr
-----+-++-++  | one : SPBExpr
-----+-++-++  | var : ℕ → SPBExpr
-----+-++-++  | node : SPBExpr → SPBExpr → SPBExpr
-----+-++-++  deriving Repr, BEq
-----+-++-+ 
-----+-++-+-@[simp]
-----+-++-+-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
-----+-++-+-    pullbackAlg φ f x = f (φ x) := rfl
-----+-++-++/-- Evaluate an SPB expression. -/
-----+-++-++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
-----+-++-++  match e with
-----+-++-++  | .zero => 0
-----+-++-++  | .one => 1
-----+-++-++  | .var n => vars n
-----+-++-++  | .node l r => spb (l.eval vars) (r.eval vars)
-----+-++-+ 
-----+-++-+-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----+-++-+-    pullbackAlg φ f ∈ FiberConst φ := by
-----+-++-+-  intro x x' h; simp [h]
-----+-++-++/-- Depth of an SPB expression. -/
-----+-++-++def SPBExpr.depth : SPBExpr → ℕ
-----+-++-++  | .zero => 0
-----+-++-++  | .one => 0
-----+-++-++  | .var _ => 0
-----+-++-++  | .node l r => 1 + max l.depth r.depth
-----+-++-+ 
-----+-++-+-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
-----+-++-+-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----+-++-+-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
-----+-++-++/-- Leaf count. -/
-----+-++-++def SPBExpr.leafCount : SPBExpr → ℕ
-----+-++-++  | .zero => 1
-----+-++-++  | .one => 1
-----+-++-++  | .var _ => 1
-----+-++-++  | .node l r => l.leafCount + r.leafCount
-----+-++-+ 
-----+-++-+-theorem range_comp_subalgebra_subset_fiberConst
-----+-++-+-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
-----+-++-+-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----+-++-+-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
-----+-++-++/-- Internal node count. -/
-----+-++-++def SPBExpr.nodeCount : SPBExpr → ℕ
-----+-++-++  | .zero => 0
-----+-++-++  | .one => 0
-----+-++-++  | .var _ => 0
-----+-++-++  | .node l r => 1 + l.nodeCount + r.nodeCount
-----+-++-+ 
-----+-++-+-/-- `FiberConst φ` is closed in the uniform topology. -/
-----+-++-+-theorem fiberConst_closed (φ : C(X, Y)) :
-----+-++-+-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
-----+-++-+-  refine isClosed_of_closure_subset ?_
-----+-++-+-  intro g hg x x' h
-----+-++-+-  rw [mem_closure_iff_nhds] at hg
-----+-++-+-  contrapose! hg
-----+-++-+-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
-----+-++-+-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
-----+-++-+-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
-----+-++-++/-- Binary tree identity: leaves = internal nodes + 1. -/
-----+-++-++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
-----+-++-++    e.leafCount = e.nodeCount + 1 := by
-----+-++-++  induction e with
-----+-++-++  | zero => rfl
-----+-++-++  | one => rfl
-----+-++-++  | var _ => rfl
-----+-++-++  | node l r ihl ihr =>
-----+-++-++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
-----+-++-++    omega
-----+-++-+ 
-----+-++-+-omit [T2Space X] [T2Space Y] in
-----+-++-+-/-- The pullback map is norm-nonincreasing. -/
-----+-++-+-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----+-++-+-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
-----+-++-+-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
-----+-++-+-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
-----+-++-++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
-----+-++-++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
-----+-++-+ 
-----+-++-+-/-- When `φ` is surjective, pullback is an isometry. -/
-----+-++-+-theorem pullback_isometry_of_surjective
-----+-++-+-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
-----+-++-+-    ‖pullbackAlg φ f‖ = ‖f‖ := by
-----+-++-+-  refine le_antisymm (norm_pullback_le φ f) ?_
-----+-++-+-  rw [ContinuousMap.norm_le _ (by positivity)]
-----+-++-+-  intro y; obtain ⟨x, rfl⟩ := hφ y
-----+-++-+-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
-----+-++-++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
-----+-++-++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
-----+-++-++  unfold logisticSigmoid
-----+-++-++  rw [Real.exp_neg]
-----+-++-++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
-----+-++-++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
-----+-++-++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----+-++-++  field_simp; ring
-----+-++-+ 
-----+-++-+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----+-++-+-theorem mem_fiberConst_of_injective
-----+-++-+-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
-----+-++-+-    g ∈ FiberConst φ := by
-----+-++-+-  intro x x' h; exact congrArg g (hφ h)
-----+-++-++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
-----+-++-++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
-----+-++-++  unfold softplus logisticSigmoid
-----+-++-++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
-----+-++-++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
-----+-++-++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
-----+-++-++  simp at this
-----+-++-++  exact this
-----+-++-+ 
-----+-++-+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----+-++-+-theorem fiberConst_eq_top_of_injective
-----+-++-+-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
-----+-++-+-    FiberConst φ = ⊤ := by
-----+-++-+-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
-----+-++-++/-- ShefferAlg is closed under affine pre-composition. -/
-----+-++-++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
-----+-++-++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
-----+-++-++  obtain ⟨e, rfl⟩ := hf
-----+-++-++  exact ⟨.affinePrecomp a b e, rfl⟩
-----+-++-+ 
-----+-++-+-omit [CompactSpace Y] [T2Space Y] in
-----+-++-+-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
-----+-++-+-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
-----+-++-+-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
-----+-++-+-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
-----+-++-+-  intro x x' hφ; by_contra h_ne
-----+-++-+-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
-----+-++-+-    have := exists_continuous_zero_one_of_isClosed
-----+-++-+-      (show IsClosed {x} from isClosed_singleton)
-----+-++-+-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
-----+-++-+-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
-----+-++-+-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
-----+-++-+-  replace h := SetLike.ext_iff.mp h g
-----+-++-+-  simp_all +decide [FiberConst]
-----+-++-+-  exact absurd (h hφ) (by simp +decide [hg])
-----+-++-++/-- ShefferAlg is closed under affine combination. -/
-----+-++-++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
-----+-++-++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
-----+-++-++  obtain ⟨ef, rfl⟩ := hf
-----+-++-++  obtain ⟨eg, rfl⟩ := hg
-----+-++-++  exact ⟨.affineComb α β γ ef eg, rfl⟩
-----+-++-+ 
-----+-++-+-/-! ### §2: Image factorization -/
-----+-++-++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
-----+-++-++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
-----+-++-++  unfold softplus
-----+-++-++  rw [Real.exp_neg]
-----+-++-++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
-----+-++-++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----+-++-++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
-----+-++-++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
-----+-++-++  rw [this, Real.log_exp]
-----+-++-+ 
-----+-++-+-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
-----+-++-+-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
-----+-++-+-
-----+-++-+-/-
-----+-++-+-The corestriction `X → Set.range φ` is a quotient map.
-----+-++-+--/
-----+-++-+-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
-----+-++-+-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
-----+-++-+-  apply IsClosedMap.isQuotientMap;
-----+-++-+-  · intro s hs;
-----+-++-+-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
-----+-++-+-    constructor <;> intro h;
-----+-++-+-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
-----+-++-+-    · convert h.preimage ( continuous_subtype_val ) using 1;
-----+-++-+-      ext; simp [Set.rangeFactorization];
-----+-++-+-      grind;
-----+-++-+-  · exact continuous_induced_rng.mpr φ.continuous;
-----+-++-+-  · exact Set.rangeFactorization_surjective
-----+-++-+-
-----+-++-+-/-- Lift a fiber-constant function to `Set.range φ`. -/
-----+-++-+-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
-----+-++-+-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
-----+-++-+-  toFun z := g z.property.choose
-----+-++-+-  continuous_toFun := by
-----+-++-+-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
-----+-++-+-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
-----+-++-+-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
-----+-++-+-      ext x; apply hg
-----+-++-+-      exact (Set.rangeFactorization φ x).property.choose_spec
-----+-++-+-    rw [this]; exact g.continuous
-----+-++-+-
-----+-++-+-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
-----+-++-+-    (hg : g ∈ FiberConst φ) (x : X) :
-----+-++-+-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
-----+-++-+-  simp only [fiberConstLift]
-----+-++-+-  apply hg
-----+-++-+-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
-----+-++-+-
-----+-++-+-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
-----+-++-+-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
-----+-++-+-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
-----+-++-+-  intro g hg
-----+-++-+-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
-----+-++-+-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
-----+-++-+-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
-----+-++-+-  refine ⟨F, ?_⟩
-----+-++-+-  ext x
-----+-++-+-  simp only [pullbackAlg_apply]
-----+-++-+-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
-----+-++-+-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
-----+-++-+-    simp [ContinuousMap.comp_apply] at this; exact this
-----+-++-+-  rw [key, fiberConstLift_comp]
-----+-++-+-
-----+-++-+-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
-----+-++-+-theorem fiberConst_eq_range_pullback_of_surjective
-----+-++-+-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
-----+-++-+-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
-----+-++-+-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
-----+-++-+-    (range_pullback_subset_fiberConst φ)
-----+-++-+-
-----+-++-+-/-! ### §3: Density transport -/
-----+-++-+-
-----+-++-+-/-
-----+-++-+-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
-----+-++-+--/
-----+-++-+-theorem closure_range_pullback_eq_fiberConst
-----+-++-+-    (φ : C(X, Y))
-----+-++-+-    (A : Subalgebra ℝ C(Y, ℝ))
-----+-++-+-    (hA : Dense (A : Set C(Y, ℝ))) :
-----+-++-+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
-----+-++-+-      = (FiberConst φ : Set C(X, ℝ)) := by
-----+-++-+-  refine' le_antisymm ( closure_minimal _ _ ) _;
-----+-++-+-  · exact range_comp_subalgebra_subset_fiberConst φ A;
-----+-++-+-  · exact fiberConst_closed φ;
-----+-++-+-  · intro g hg;
-----+-++-+-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
-----+-++-+-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
-----+-++-+-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
-----+-++-+-    rw [ Metric.mem_closure_iff ];
-----+-++-+-    intro ε εpos;
-----+-++-+-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
-----+-++-+-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
-----+-++-+-    nontriviality;
-----+-++-+-    rw [ hF, dist_eq_norm ] at *;
-----+-++-+-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
-----+-++-+-
-----+-++-+-/-
-----+-++-+-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
-----+-++-+--/
-----+-++-+-theorem closure_range_pullback_eq_top_of_injective
-----+-++-+-    (φ : C(X, Y))
-----+-++-+-    (hφ : Function.Injective φ)
-----+-++-+-    (A : Subalgebra ℝ C(Y, ℝ))
-----+-++-+-    (hA : Dense (A : Set C(Y, ℝ))) :
-----+-++-+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
-----+-++-+-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
-----+-++-+-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
-----+-++-+-
-----+-++-+-/-! ### §4: ε-approximation -/
-----+-++-+-
-----+-++-+-/-
-----+-++-+-ε-approximation within `FiberConst φ`.
-----+-++-+--/
-----+-++-+-theorem exists_pullback_approx_of_fiberConst
-----+-++-+-    (φ : C(X, Y))
-----+-++-+-    (A : Subalgebra ℝ C(Y, ℝ))
-----+-++-+-    (hA : Dense (A : Set C(Y, ℝ)))
-----+-++-+-    (g : C(X, ℝ))
-----+-++-+-    (hg : g ∈ FiberConst φ)
-----+-++-+-    {ε : ℝ} (hε : 0 < ε) :
-----+-++-+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----+-++-+-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
-----+-++-+-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
-----+-++-+-  rw [ Metric.mem_closure_iff ] at h_closure;
-----+-++-+-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
-----+-++-+-
-----+-++-+-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
-----+-++-+-theorem exists_pullback_approx_of_injective
-----+-++-+-    (φ : C(X, Y))
-----+-++-+-    (hφ : Function.Injective φ)
-----+-++-+-    (A : Subalgebra ℝ C(Y, ℝ))
-----+-++-+-    (hA : Dense (A : Set C(Y, ℝ)))
-----+-++-+-    (g : C(X, ℝ))
-----+-++-+-    {ε : ℝ} (hε : 0 < ε) :
-----+-++-+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----+-++-+-  exact exists_pullback_approx_of_fiberConst φ A hA g
-----+-++-+-    (mem_fiberConst_of_injective φ hφ g) hε+end+--- a/EML/Basic.lean
-----+-++++++ b/EML/Basic.lean
-----+-+++@@ -1,277 +1,125 @@
-----+-+++-/-
-----+-+++-Copyright (c) 2026 Harmonic. All rights reserved.
-----+-+++-Released under Apache 2.0 license as described in the file LICENSE.
-----+-+++--/
-----+-+++ import Mathlib
-----+-+++ 
-----+-+++-/-!
-----+-+++-# Pullback Stability of Universal Approximation
-----+-++++/-! # CatalogBuild.EML.Basic
-----+-+++ 
-----+-+++-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
-----+-+++-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
-----+-+++-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
-----+-+++-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
-----+-+++-
-----+-+++-This establishes a transport principle: universal approximation results (like
-----+-+++-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
-----+-+++-with the precise target being the fiber-constant functions.
-----+-+++-
-----+-+++-## Main definitions
-----+-+++-
-----+-+++-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
-----+-+++-  fibers of `φ`.
-----+-+++-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
-----+-+++-
-----+-+++-## Main results
-----+-+++-
-----+-+++-### Basic properties (§1)
-----+-+++-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
-----+-+++-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
-----+-+++-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
-----+-+++-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
-----+-+++-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
-----+-+++-
-----+-+++-### Factorization (§2)
-----+-+++-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
-----+-+++-  through `Set.range φ`, hence is a pullback (via Tietze extension).
-----+-+++-
-----+-+++-### Density transport (§3)
-----+-+++-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
-----+-+++-  subalgebra equals `FiberConst φ`.
-----+-+++-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
-----+-+++-
-----+-+++-### ε-approximation (§4)
-----+-+++-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
-----+-+++-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
-----+-++++Auto-generated from theorem catalog database.
-----+-++++Domain: EML
-----+-++++Declarations: 15
-----+-+ + -/
-----+-+ + 
----+--- a/Logic/Basic.lean
----++++ b/Logic/Basic.lean
----+@@ -1,2162 +1,3640 @@
----+ --- a/MachineLearning/Basic.lean
----+ +++ b/MachineLearning/Basic.lean
----+-@@ -1,219 +1,1941 @@
----+--/-
----+--Copyright (c) 2025 Harmonic. All rights reserved.
----+--Released under Apache 2.0 license as described in the file LICENSE.
----+---/
----+--import Mathlib
--+--- a/Logic/Basic.lean
--++++ b/Logic/Basic.lean
--+@@ -1,2162 +1,3640 @@
--+ --- a/MachineLearning/Basic.lean
--+ +++ b/MachineLearning/Basic.lean
--+-@@ -1,219 +1,1941 @@
--+--/-
--+--Copyright (c) 2025 Harmonic. All rights reserved.
--+--Released under Apache 2.0 license as described in the file LICENSE.
--+---/
--+--import Mathlib
--+--
--+--/-!
--+--# Gradient Descent Convergence Theory
--+--
--+--This file formalizes the convergence theory of gradient descent for strongly convex
--+--quadratic functions, establishing the fundamental result that underpins optimization
--+--in machine learning.
--+--
--+--## Main Results
--+--
--+--* `gd_error_eq` — The error of gradient descent on a quadratic `f(x) = (a/2)x²`
--+--  with step size `η` satisfies `e_n = (1 - ηa)^n · e_0`
--+--* `gd_contraction_factor_lt_one` — The contraction factor `|1 - ηa| < 1` when
--+--  `0 < η < 2/a`
--+--* `gd_converges` — Gradient descent converges: `x_n → x*`
--+--* `gd_geometric_rate` — The convergence rate is geometric:
--+--  `|x_n - x*| ≤ |1 - ηa|^n · |x_0 - x*|`
--+--* `gd_optimal_step` — The optimal step size is `η = 1/a`, giving convergence in one step
--+--* `gd_condition_number_bound` — For 2D quadratics with eigenvalues `μ ≤ L`,
--+--  the optimal convergence rate is `(κ-1)/(κ+1)` where `κ = L/μ`
--+--
--+--## References
--+--
--+--* Nesterov, Y. (2004). *Introductory Lectures on Convex Optimization*
--+--* Boyd, S. & Vandenberghe, L. (2004). *Convex Optimization*
--+---/
--+--
--+--open Filter Topology Real
--+--
--+--noncomputable section
--+--
--+--/-!
--+--## Part 1: Geometric Convergence of Linear Recurrences
--+--
--+--We first establish that sequences satisfying `x_{n+1} = r · x_n` converge geometrically
--+--when `|r| < 1`. This is the mathematical core of gradient descent convergence.
--+---/
--+--
--+--/-
--+--A geometric sequence `r^n * x₀` with `|r| < 1` converges to zero.
--+---/
--+--theorem geom_seq_tendsto_zero {r x₀ : ℝ} (hr : |r| < 1) :
--+--    Tendsto (fun n => r ^ n * x₀) atTop (nhds 0) := by
--+--      simpa using tendsto_pow_atTop_nhds_zero_of_abs_lt_one hr |> Filter.Tendsto.mul_const x₀
--+--
--+--/-
--+--Geometric bound: `|r^n * x₀| ≤ |r|^n * |x₀|`.
--+---/
--+--theorem geom_seq_abs_bound (r x₀ : ℝ) (n : ℕ) :
--+--    |r ^ n * x₀| = |r| ^ n * |x₀| := by
--+--      rw [ abs_mul, abs_pow ]
--+--
--+--/-
--+--If `|r| < 1`, then `|r|^n → 0`.
--+---/
--+--theorem geom_decay {r : ℝ} (hr : |r| < 1) :
--+--    Tendsto (fun n => |r| ^ n) atTop (nhds 0) := by
--+--      exact tendsto_pow_atTop_nhds_zero_of_lt_one ( abs_nonneg r ) hr
--+--
--+--/-!
--+--## Part 2: Gradient Descent on Quadratic Functions
--+--
--+--We formalize gradient descent on the 1D quadratic `f(x) = (a/2) · x²` with `a > 0`.
--+--The gradient is `f'(x) = a · x`, and the GD update is:
--+--
--+--  `x_{n+1} = x_n - η · a · x_n = (1 - η·a) · x_n`
--+--
--+--The minimizer is `x* = 0`, so the error is `e_n = x_n - 0 = x_n`.
--+---/
--+--
--+--/-- The gradient descent iteration for `f(x) = (a/2)x²`:
--+--    `gd_step a η x = x - η * (a * x) = (1 - η * a) * x` -/
--+--def gd_step (a η : ℝ) (x : ℝ) : ℝ := x - η * (a * x)
--+--
--+--/-- The n-th iterate of gradient descent starting from `x₀`. -/
--+--def gd_iterate (a η : ℝ) (x₀ : ℝ) : ℕ → ℝ
--+--  | 0 => x₀
--+--  | n + 1 => gd_step a η (gd_iterate a η x₀ n)
--+--
--+--/-- The gradient descent step simplifies to multiplication by `(1 - η * a)`. -/
--+--theorem gd_step_eq (a η x : ℝ) : gd_step a η x = (1 - η * a) * x := by
--+--  unfold gd_step; ring
--+--
--+--/-
--+--The n-th GD iterate equals `(1 - η*a)^n * x₀`.
--+---/
--+--theorem gd_iterate_eq (a η x₀ : ℝ) (n : ℕ) :
--+--    gd_iterate a η x₀ n = (1 - η * a) ^ n * x₀ := by
--+--      induction' n with n ih;
--+--      · aesop;
--+--      · convert congr_arg ( fun x => ( 1 - η * a ) * x ) ih using 1 <;> ring;
--+--        rw [ add_comm, show gd_iterate a η x₀ ( n + 1 ) = gd_step a η ( gd_iterate a η x₀ n ) by rfl, gd_step_eq ] ; ring
--+--
--+--/-!
--+--## Part 3: Convergence Analysis
--+--
--+--The key insight: gradient descent converges when the contraction factor `|1 - η·a|`
--+--is strictly less than 1, which holds precisely when `0 < η < 2/a`.
--+---/
--+--
--+--/-
--+--The contraction factor `|1 - η*a| < 1` when `0 < η*a < 2`.
--+---/
--+--theorem contraction_factor_lt_one {η a : ℝ} (hηa_pos : 0 < η * a) (hηa_lt : η * a < 2) :
--+--    |1 - η * a| < 1 := by
--+--      exact abs_lt.mpr ⟨ by linarith, by linarith ⟩
--+--
--+--/-
--+--When `a > 0` and `0 < η < 2/a`, we have `0 < η*a < 2`.
--+---/
--+--theorem step_size_valid {a η : ℝ} (ha : 0 < a) (hη_pos : 0 < η) (hη_lt : η < 2 / a) :
--+--    0 < η * a ∧ η * a < 2 := by
--+--      constructor <;> nlinarith [ mul_div_cancel₀ 2 ha.ne' ]
--+--
--+--/-
--+--**Main convergence theorem**: Gradient descent on `f(x) = (a/2)x²` converges
--+--    to the minimizer `x* = 0` when the step size satisfies `0 < η < 2/a`.
--+---/
--+--theorem gd_converges {a η : ℝ} (ha : 0 < a) (hη_pos : 0 < η) (hη_lt : η < 2 / a)
--+--    (x₀ : ℝ) : Tendsto (gd_iterate a η x₀) atTop (nhds 0) := by
--+--      -- Use `gd_iterate_eq` to rewrite the sequence as `(1 - η * a) ^ n * x₀`.
--+--      have h_seq_eq : ∀ n, gd_iterate a η x₀ n = (1 - η * a) ^ n * x₀ :=
--+--        fun n => gd_iterate_eq a η x₀ n
--+--      rw [ show gd_iterate a η x₀ = _ from funext h_seq_eq ] ; exact geom_seq_tendsto_zero ( by rw [ abs_lt ] ; constructor <;> nlinarith [ mul_div_cancel₀ 2 ha.ne' ] )
--+--
--+--/-
--+--**Geometric convergence rate**: `|x_n| ≤ |1 - ηa|^n · |x₀|`.
--+---/
--+--theorem gd_geometric_rate (a η x₀ : ℝ) (n : ℕ) :
--+--    |gd_iterate a η x₀ n| = |1 - η * a| ^ n * |x₀| := by
--+--      rw [ gd_iterate_eq, abs_mul, abs_pow ]
--+--
--+--/-
--+--**Optimal step size**: When `η = 1/a`, gradient descent converges in one step:
--+--    the contraction factor is 0, so `x₁ = 0`.
--+---/
--+--theorem gd_optimal_one_step {a : ℝ} (ha : 0 < a) (x₀ : ℝ) :
--+--    gd_iterate a (1 / a) x₀ 1 = 0 := by
--+--      exact show x₀ - 1 / a * ( a * x₀ ) = 0 from by ring_nf; norm_num [ ha.ne' ] ;
--+--
--+--/-
--+--For `η = 1/a`, all iterates after the first are 0.
--+---/
--+--theorem gd_optimal_all_zero {a : ℝ} (ha : 0 < a) (x₀ : ℝ) (n : ℕ) (hn : 0 < n) :
--+--    gd_iterate a (1 / a) x₀ n = 0 := by
--+--      convert gd_iterate_eq a ( 1 / a ) x₀ n using 1 ; norm_num [ ha.ne' ];
--+--      aesop
--+--
--+--/-!
--+--## Part 4: Condition Number and Two-Dimensional Analysis
--+--
--+--For the 2D quadratic `f(x,y) = (a/2)x² + (b/2)y²` with `0 < μ ≤ L` (eigenvalues),
--+--the optimal step size is `η = 2/(μ + L)` and the convergence rate is
--+--`(L - μ)/(L + μ) = (κ - 1)/(κ + 1)` where `κ = L/μ` is the condition number.
--+---/
--+--
--+--/-- The condition number `κ = L/μ` for eigenvalues `μ ≤ L`. -/
--+--def conditionNumber (μ L : ℝ) : ℝ := L / μ
--+--
--+--/-- The optimal convergence rate for a 2D quadratic with eigenvalues `μ` and `L`. -/
--+--def optimalRate (μ L : ℝ) : ℝ := (L - μ) / (L + μ)
--+--
--+--/-
--+--The optimal convergence rate equals `(κ-1)/(κ+1)`.
--+---/
--+--theorem optimal_rate_eq_condition {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
--+--    optimalRate μ L = (conditionNumber μ L - 1) / (conditionNumber μ L + 1) := by
--+--      unfold optimalRate conditionNumber;
--+--      grind
--+--
--+--/-
--+--The optimal rate is in `[0, 1)` when `0 < μ ≤ L`.
--+---/
--+--theorem optimal_rate_nonneg {μ L : ℝ} (hμ : 0 < μ) (hμL : μ ≤ L) :
--+--    0 ≤ optimalRate μ L := by
--+--      exact div_nonneg ( by linarith ) ( by linarith )
--+--
--+--theorem optimal_rate_lt_one {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
--+--    optimalRate μ L < 1 := by
--+--      exact div_lt_one ( by positivity ) |>.2 ( by linarith )
--+--
--+--/-
--+--Well-conditioned problems (κ ≈ 1) converge fast: rate = 0 when μ = L.
--+---/
--+--theorem optimal_rate_well_conditioned (μ : ℝ) :
--+--    optimalRate μ μ = 0 := by
--+--      unfold optimalRate; ring
--+--
--+--/-- The optimal step size for a 2D quadratic is `2/(μ + L)`. -/
--+--def optimalStepSize (μ L : ℝ) : ℝ := 2 / (μ + L)
--+--
--+--/-
--+--With the optimal step size `η = 2/(μ+L)`, the contraction factors for
--+--    both coordinates are `±(L-μ)/(L+μ)`, giving the optimal rate.
--+---/
--+--theorem optimal_step_contraction_small {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
--+--    1 - optimalStepSize μ L * μ = optimalRate μ L := by
--+--      unfold optimalStepSize optimalRate; rw [ div_mul_eq_mul_div, one_sub_div ] ; ring ; positivity;
--+--
--+--theorem optimal_step_contraction_large {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
--+--    1 - optimalStepSize μ L * L = -(optimalRate μ L) := by
--+--      grind +locals
--+--
--+--/-
--+--**Fundamental bound**: The number of iterations needed to reduce error by factor ε
--+--    is proportional to κ · log(1/ε), where κ is the condition number. This is captured
--+--    by the fact that log(1/rate) ≈ 2/κ for large κ.
--+---/
--+--theorem iteration_complexity_bound {μ L : ℝ} (hμ : 0 < μ) (hμL : μ ≤ L) :
--+--    optimalRate μ L ≤ 1 - 2 / (conditionNumber μ L + 1) := by
--+--      unfold optimalRate conditionNumber;
--+--      rw [ one_sub_div, div_le_div_iff₀ ] <;> nlinarith [ mul_div_cancel₀ L hμ.ne' ]
--+--
--+--end+--- a/MachineLearning/Basic.lean
--+-++++ b/MachineLearning/Basic.lean
--+-+@@ -1,241 +1,1700 @@
--+-+---- a/Bridges/Basic.lean
--+-+-+++ b/Bridges/Basic.lean
--+-+-@@ -1,11 +1,228 @@
--+-+--/-!
--+-+--# Tropical Algebra Placeholder
-- -+--
----+--/-!
----+--# Gradient Descent Convergence Theory
----+--
----+--This file formalizes the convergence theory of gradient descent for strongly convex
----+--quadratic functions, establishing the fundamental result that underpins optimization
----+--in machine learning.
----+--
----+--## Main Results
----+--
----+--* `gd_error_eq` — The error of gradient descent on a quadratic `f(x) = (a/2)x²`
----+--  with step size `η` satisfies `e_n = (1 - ηa)^n · e_0`
----+--* `gd_contraction_factor_lt_one` — The contraction factor `|1 - ηa| < 1` when
----+--  `0 < η < 2/a`
----+--* `gd_converges` — Gradient descent converges: `x_n → x*`
----+--* `gd_geometric_rate` — The convergence rate is geometric:
----+--  `|x_n - x*| ≤ |1 - ηa|^n · |x_0 - x*|`
----+--* `gd_optimal_step` — The optimal step size is `η = 1/a`, giving convergence in one step
----+--* `gd_condition_number_bound` — For 2D quadratics with eigenvalues `μ ≤ L`,
----+--  the optimal convergence rate is `(κ-1)/(κ+1)` where `κ = L/μ`
----+--
----+--## References
----+--
----+--* Nesterov, Y. (2004). *Introductory Lectures on Convex Optimization*
----+--* Boyd, S. & Vandenberghe, L. (2004). *Convex Optimization*
----+---/
----+--
----+--open Filter Topology Real
----+--
----+--noncomputable section
----+--
----+--/-!
----+--## Part 1: Geometric Convergence of Linear Recurrences
----+--
----+--We first establish that sequences satisfying `x_{n+1} = r · x_n` converge geometrically
----+--when `|r| < 1`. This is the mathematical core of gradient descent convergence.
----+---/
----+--
----+--/-
----+--A geometric sequence `r^n * x₀` with `|r| < 1` converges to zero.
----+---/
----+--theorem geom_seq_tendsto_zero {r x₀ : ℝ} (hr : |r| < 1) :
----+--    Tendsto (fun n => r ^ n * x₀) atTop (nhds 0) := by
----+--      simpa using tendsto_pow_atTop_nhds_zero_of_abs_lt_one hr |> Filter.Tendsto.mul_const x₀
----+--
----+--/-
----+--Geometric bound: `|r^n * x₀| ≤ |r|^n * |x₀|`.
----+---/
----+--theorem geom_seq_abs_bound (r x₀ : ℝ) (n : ℕ) :
----+--    |r ^ n * x₀| = |r| ^ n * |x₀| := by
----+--      rw [ abs_mul, abs_pow ]
----+--
----+--/-
----+--If `|r| < 1`, then `|r|^n → 0`.
----+---/
----+--theorem geom_decay {r : ℝ} (hr : |r| < 1) :
----+--    Tendsto (fun n => |r| ^ n) atTop (nhds 0) := by
----+--      exact tendsto_pow_atTop_nhds_zero_of_lt_one ( abs_nonneg r ) hr
----+--
----+--/-!
----+--## Part 2: Gradient Descent on Quadratic Functions
----+--
----+--We formalize gradient descent on the 1D quadratic `f(x) = (a/2) · x²` with `a > 0`.
----+--The gradient is `f'(x) = a · x`, and the GD update is:
----+--
----+--  `x_{n+1} = x_n - η · a · x_n = (1 - η·a) · x_n`
----+--
----+--The minimizer is `x* = 0`, so the error is `e_n = x_n - 0 = x_n`.
----+---/
----+--
----+--/-- The gradient descent iteration for `f(x) = (a/2)x²`:
----+--    `gd_step a η x = x - η * (a * x) = (1 - η * a) * x` -/
----+--def gd_step (a η : ℝ) (x : ℝ) : ℝ := x - η * (a * x)
----+--
----+--/-- The n-th iterate of gradient descent starting from `x₀`. -/
----+--def gd_iterate (a η : ℝ) (x₀ : ℝ) : ℕ → ℝ
----+--  | 0 => x₀
----+--  | n + 1 => gd_step a η (gd_iterate a η x₀ n)
----+--
----+--/-- The gradient descent step simplifies to multiplication by `(1 - η * a)`. -/
----+--theorem gd_step_eq (a η x : ℝ) : gd_step a η x = (1 - η * a) * x := by
----+--  unfold gd_step; ring
----+--
----+--/-
----+--The n-th GD iterate equals `(1 - η*a)^n * x₀`.
----+---/
----+--theorem gd_iterate_eq (a η x₀ : ℝ) (n : ℕ) :
----+--    gd_iterate a η x₀ n = (1 - η * a) ^ n * x₀ := by
----+--      induction' n with n ih;
----+--      · aesop;
----+--      · convert congr_arg ( fun x => ( 1 - η * a ) * x ) ih using 1 <;> ring;
----+--        rw [ add_comm, show gd_iterate a η x₀ ( n + 1 ) = gd_step a η ( gd_iterate a η x₀ n ) by rfl, gd_step_eq ] ; ring
----+--
----+--/-!
----+--## Part 3: Convergence Analysis
----+--
----+--The key insight: gradient descent converges when the contraction factor `|1 - η·a|`
----+--is strictly less than 1, which holds precisely when `0 < η < 2/a`.
----+---/
----+--
----+--/-
----+--The contraction factor `|1 - η*a| < 1` when `0 < η*a < 2`.
----+---/
----+--theorem contraction_factor_lt_one {η a : ℝ} (hηa_pos : 0 < η * a) (hηa_lt : η * a < 2) :
----+--    |1 - η * a| < 1 := by
----+--      exact abs_lt.mpr ⟨ by linarith, by linarith ⟩
----+--
----+--/-
----+--When `a > 0` and `0 < η < 2/a`, we have `0 < η*a < 2`.
----+---/
----+--theorem step_size_valid {a η : ℝ} (ha : 0 < a) (hη_pos : 0 < η) (hη_lt : η < 2 / a) :
----+--    0 < η * a ∧ η * a < 2 := by
----+--      constructor <;> nlinarith [ mul_div_cancel₀ 2 ha.ne' ]
----+--
----+--/-
----+--**Main convergence theorem**: Gradient descent on `f(x) = (a/2)x²` converges
----+--    to the minimizer `x* = 0` when the step size satisfies `0 < η < 2/a`.
----+---/
----+--theorem gd_converges {a η : ℝ} (ha : 0 < a) (hη_pos : 0 < η) (hη_lt : η < 2 / a)
----+--    (x₀ : ℝ) : Tendsto (gd_iterate a η x₀) atTop (nhds 0) := by
----+--      -- Use `gd_iterate_eq` to rewrite the sequence as `(1 - η * a) ^ n * x₀`.
----+--      have h_seq_eq : ∀ n, gd_iterate a η x₀ n = (1 - η * a) ^ n * x₀ :=
----+--        fun n => gd_iterate_eq a η x₀ n
----+--      rw [ show gd_iterate a η x₀ = _ from funext h_seq_eq ] ; exact geom_seq_tendsto_zero ( by rw [ abs_lt ] ; constructor <;> nlinarith [ mul_div_cancel₀ 2 ha.ne' ] )
----+--
----+--/-
----+--**Geometric convergence rate**: `|x_n| ≤ |1 - ηa|^n · |x₀|`.
----+---/
----+--theorem gd_geometric_rate (a η x₀ : ℝ) (n : ℕ) :
----+--    |gd_iterate a η x₀ n| = |1 - η * a| ^ n * |x₀| := by
----+--      rw [ gd_iterate_eq, abs_mul, abs_pow ]
----+--
----+--/-
----+--**Optimal step size**: When `η = 1/a`, gradient descent converges in one step:
----+--    the contraction factor is 0, so `x₁ = 0`.
----+---/
----+--theorem gd_optimal_one_step {a : ℝ} (ha : 0 < a) (x₀ : ℝ) :
----+--    gd_iterate a (1 / a) x₀ 1 = 0 := by
----+--      exact show x₀ - 1 / a * ( a * x₀ ) = 0 from by ring_nf; norm_num [ ha.ne' ] ;
----+--
----+--/-
----+--For `η = 1/a`, all iterates after the first are 0.
----+---/
----+--theorem gd_optimal_all_zero {a : ℝ} (ha : 0 < a) (x₀ : ℝ) (n : ℕ) (hn : 0 < n) :
----+--    gd_iterate a (1 / a) x₀ n = 0 := by
----+--      convert gd_iterate_eq a ( 1 / a ) x₀ n using 1 ; norm_num [ ha.ne' ];
----+--      aesop
----+--
----+--/-!
----+--## Part 4: Condition Number and Two-Dimensional Analysis
----+--
----+--For the 2D quadratic `f(x,y) = (a/2)x² + (b/2)y²` with `0 < μ ≤ L` (eigenvalues),
----+--the optimal step size is `η = 2/(μ + L)` and the convergence rate is
----+--`(L - μ)/(L + μ) = (κ - 1)/(κ + 1)` where `κ = L/μ` is the condition number.
----+---/
----+--
----+--/-- The condition number `κ = L/μ` for eigenvalues `μ ≤ L`. -/
----+--def conditionNumber (μ L : ℝ) : ℝ := L / μ
----+--
----+--/-- The optimal convergence rate for a 2D quadratic with eigenvalues `μ` and `L`. -/
----+--def optimalRate (μ L : ℝ) : ℝ := (L - μ) / (L + μ)
----+--
----+--/-
----+--The optimal convergence rate equals `(κ-1)/(κ+1)`.
----+---/
----+--theorem optimal_rate_eq_condition {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
----+--    optimalRate μ L = (conditionNumber μ L - 1) / (conditionNumber μ L + 1) := by
----+--      unfold optimalRate conditionNumber;
----+--      grind
----+--
----+--/-
----+--The optimal rate is in `[0, 1)` when `0 < μ ≤ L`.
----+---/
----+--theorem optimal_rate_nonneg {μ L : ℝ} (hμ : 0 < μ) (hμL : μ ≤ L) :
----+--    0 ≤ optimalRate μ L := by
----+--      exact div_nonneg ( by linarith ) ( by linarith )
----+--
----+--theorem optimal_rate_lt_one {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
----+--    optimalRate μ L < 1 := by
----+--      exact div_lt_one ( by positivity ) |>.2 ( by linarith )
----+--
----+--/-
----+--Well-conditioned problems (κ ≈ 1) converge fast: rate = 0 when μ = L.
----+---/
----+--theorem optimal_rate_well_conditioned (μ : ℝ) :
----+--    optimalRate μ μ = 0 := by
----+--      unfold optimalRate; ring
----+--
----+--/-- The optimal step size for a 2D quadratic is `2/(μ + L)`. -/
----+--def optimalStepSize (μ L : ℝ) : ℝ := 2 / (μ + L)
----+--
----+--/-
----+--With the optimal step size `η = 2/(μ+L)`, the contraction factors for
----+--    both coordinates are `±(L-μ)/(L+μ)`, giving the optimal rate.
----+---/
----+--theorem optimal_step_contraction_small {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
----+--    1 - optimalStepSize μ L * μ = optimalRate μ L := by
----+--      unfold optimalStepSize optimalRate; rw [ div_mul_eq_mul_div, one_sub_div ] ; ring ; positivity;
----+--
----+--theorem optimal_step_contraction_large {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
----+--    1 - optimalStepSize μ L * L = -(optimalRate μ L) := by
----+--      grind +locals
----+--
----+--/-
----+--**Fundamental bound**: The number of iterations needed to reduce error by factor ε
----+--    is proportional to κ · log(1/ε), where κ is the condition number. This is captured
----+--    by the fact that log(1/rate) ≈ 2/κ for large κ.
----+---/
----+--theorem iteration_complexity_bound {μ L : ℝ} (hμ : 0 < μ) (hμL : μ ≤ L) :
----+--    optimalRate μ L ≤ 1 - 2 / (conditionNumber μ L + 1) := by
----+--      unfold optimalRate conditionNumber;
----+--      rw [ one_sub_div, div_le_div_iff₀ ] <;> nlinarith [ mul_div_cancel₀ L hμ.ne' ]
----+--
----+--end+--- a/MachineLearning/Basic.lean
----+-++++ b/MachineLearning/Basic.lean
----+-+@@ -1,241 +1,1700 @@
----+-+---- a/Bridges/Basic.lean
----+-+-+++ b/Bridges/Basic.lean
----+-+-@@ -1,11 +1,228 @@
----+-+--/-!
----+-+--# Tropical Algebra Placeholder
----+-+--
----+-+--The main tropical/max-plus spectral theory development is in `Bridges/`.
----+-+--See:
----+-+--- `Bridges.MaxPlusDefs` - Core definitions
----+-+--- `Bridges.MaxPlusLemmas` - Structural lemmas
----+-+--- `Bridges.EigenvectorIteration` - Eigenvector iteration theorem
----+-+--- `Bridges.PerronTheorem` - Tropical Perron-Frobenius theorem
----+-+--- `Bridges.EMLSpectral` - EML spectral duality
----+-+---/+--- a/Bridges/Basic.lean
----+-+-++++ b/Bridges/Basic.lean
----+-+-+@@ -1,104 +1,149 @@
----+-+-+ /-
----+-+-+-# Bridge Theory in Simple Graphs
----+-+-++Copyright (c) 2025. All rights reserved.
----+-+-++Released under Apache 2.0 license.
----+-+-++
----+-+-++# Bridge Theory in Graph Theory
----++@@ -1,1941 +1,1700 @@
----++---- a/MachineLearning/Basic.lean
----++-+++ b/MachineLearning/Basic.lean
----++-@@ -1,241 +1,1700 @@
----++----- a/Bridges/Basic.lean
----++--+++ b/Bridges/Basic.lean
----++--@@ -1,11 +1,228 @@
----++---/-!
----++---# Tropical Algebra Placeholder
----++---
----++---The main tropical/max-plus spectral theory development is in `Bridges/`.
----++---See:
----++---- `Bridges.MaxPlusDefs` - Core definitions
----++---- `Bridges.MaxPlusLemmas` - Structural lemmas
----++---- `Bridges.EigenvectorIteration` - Eigenvector iteration theorem
----++---- `Bridges.PerronTheorem` - Tropical Perron-Frobenius theorem
----++---- `Bridges.EMLSpectral` - EML spectral duality
----++----/+--- a/Bridges/Basic.lean
----++--++++ b/Bridges/Basic.lean
----++--+@@ -1,104 +1,149 @@
----++--+ /-
----++--+-# Bridge Theory in Simple Graphs
----++--++Copyright (c) 2025. All rights reserved.
----++--++Released under Apache 2.0 license.
----++--++
----++--++# Bridge Theory in Graph Theory
----++--+ 
----++--+ This file develops the theory of bridges (cut edges) in simple graphs,
----++--+-proving the fundamental equivalence between trees and connected graphs
----++--+-where every edge is a bridge.
----++--++building on Mathlib's `SimpleGraph.IsBridge` definition.
----++--+ 
----++--+-## Main Results
----++--++## Main results
----++--+ 
----++--+-* `SimpleGraph.IsAcyclic.isBridge_of_mem_edgeSet` — In an acyclic graph, every edge is a bridge
----++--+-* `SimpleGraph.IsTree.isBridge_of_mem_edgeSet` — In a tree, every edge is a bridge
----++--+-* `SimpleGraph.isAcyclic_of_forall_isBridge` — If every edge is a bridge, the graph is acyclic
----++--+-* `SimpleGraph.isTree_iff_connected_and_forall_isBridge` — **Tree-Bridge Equivalence**:
----++--+-  A graph is a tree if and only if it is connected and every edge is a bridge
----++--++* `IsBridge.connectedComponent_ne` — Endpoints of a bridge are in different
----++--++  connected components after deletion.
----++--++* `IsBridge.two_connected_components` — Removing a bridge from a connected
----++--++  graph yields exactly two connected components.
----++--++* `IsTree.isBridge_of_adj` — Every edge of a tree is a bridge.
----++--++* `connected_isBridge_all_iff_isTree` — A connected graph is a tree iff
----++--++  every edge is a bridge.
----++--++* `IsBridge.forall_reachable_delete_left_or_right` — Every vertex in a
----++--++  connected graph is reachable from one side of a bridge after deletion.
----++--+ 
----++--+-## Historical Context
----++--++## Historical context
----++--+ 
----++--+-Bridges in graph theory originate from Euler's 1736 analysis of the Königsberg
----++--+-bridge problem. The Tree-Bridge Equivalence Theorem provides a fundamental
----++--+-structural characterization: trees are precisely the minimally connected graphs,
----++--+-where the removal of any single edge disconnects the graph.
----++--+-
----++--+-## References
----++--+-
----++--+-* Reinhard Diestel, *Graph Theory*, 5th Edition, Springer, 2017
----++--++The study of bridges in graph theory traces back to Euler's 1736 solution
----++--++of the Königsberg Bridge Problem — widely considered the birth of graph
----++--++theory. A bridge (or cut edge) is an edge whose removal disconnects the
----++--++graph, making it a critical concept in network reliability and infrastructure
----++--++analysis.
----++-+--- a/Tropical/Basic.lean
----++-++++ b/Tropical/Basic.lean
----++-+@@ -1,1315 +1,383 @@
----++-+---- a/Tropical/Basic.lean
----++-+-+++ b/Tropical/Basic.lean
----++-+-@@ -1,930 +1,383 @@
----++-+----- a/Tropical/Basic.lean
----++-+--+++ b/Tropical/Basic.lean
----++-+--@@ -1,545 +1,383 @@
----++-+------ a/Tropical/Basic.lean
----++-+---+++ b/Tropical/Basic.lean
----++-+---@@ -1,383 +1,160 @@
----++-+------- a/EML/Basic.lean
----++-+----+++ b/EML/Basic.lean
----++-+----@@ -1,277 +1,125 @@
----++-+-----/-
----++-+-----Copyright (c) 2026 Harmonic. All rights reserved.
----++-+-----Released under Apache 2.0 license as described in the file LICENSE.
----++-+------/
----++-+---- import Mathlib
----++-+---- 
----++-+-----/-!
----++-+-----# Pullback Stability of Universal Approximation
----++-+----+/-! # CatalogBuild.EML.Basic
----++-+---- 
----++-+-----Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
----++-+-----subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
----++-+-----closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
----++-+-----When `φ` is injective, this gives density in all of `C(X, ℝ)`.
----++-+-----
----++-+-----This establishes a transport principle: universal approximation results (like
----++-+-----Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
----++-+-----with the precise target being the fiber-constant functions.
----++-+-----
----++-+-----## Main definitions
----++-+-----
----++-+-----* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
----++-+-----  fibers of `φ`.
----++-+-----* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
----++-+-----
----++-+-----## Main results
----++-+-----
----++-+-----### Basic properties (§1)
----++-+-----* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
----++-+-----* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
----++-+-----* `norm_pullback_le` — the pullback map is norm-nonincreasing.
----++-+-----* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
----++-+-----* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
----++-+-----
----++-+-----### Factorization (§2)
----++-+-----* `fiberConst_subset_range_pullback` — every fiber-constant function factors
----++-+-----  through `Set.range φ`, hence is a pullback (via Tietze extension).
----++-+-----
----++-+-----### Density transport (§3)
----++-+-----* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
----++-+-----  subalgebra equals `FiberConst φ`.
----++-+-----* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
----++-+-----
----++-+-----### ε-approximation (§4)
----++-+-----* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
----++-+-----* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
----++-+----+Auto-generated from theorem catalog database.
----++-+----+Domain: EML
----++-+----+Declarations: 15
----++-+---- -/
----++-+---- 
----++-+-----open scoped Topology
----++-+-----open Topology
----++-+----+noncomputable section
----++-+---- 
----++-+-----variable {X Y : Type*}
----++-+-----variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
----++-+-----variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
----++-+----+/-- The inverse for hyperbolic SPB is also negation. -/
----++-+----+theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
----++-+----+  simp [spbH]
----++-+---- 
----++-+-----/-! ### §1: Definitions and basic properties -/
----++-+----+/-- Wick duality: SPB with negated second argument equals the "difference"
----++-+----+in the hyperbolic SPB. This is the real-variable manifestation of the
----++-+----+Wick rotation t → it. -/
----++-+----+theorem wick_duality (x y : ℝ) :
----++-+----+    spb x (-y) = (x - y) / (1 + x * y) := by
----++-+----+  simp only [spb]
----++-+----+  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
----++-+----+  rw [heq]; ring
----++-+---- 
----++-+-----/-- Continuous functions on `X` that are constant on fibers of `φ`.
----++-+-----This is the natural functional-analytic object associated to a feature map:
----++-+-----it captures exactly the observables visible through `φ`. -/
----++-+-----def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
----++-+-----  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
----++-+-----  algebraMap_mem' r := by intro x x' _; simp
----++-+-----  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----++-+-----  zero_mem' := by intro x x' _; simp
----++-+-----  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----++-+-----  one_mem' := by intro x x' _; simp
----++-+----+/-- The tangent addition law IS the stereographic sum.
----++-+----+tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
----++-+----+theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
----++-+----+    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
----++-+----+  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
----++-+----+      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
----++-+----+  field_simp
----++-+---- 
----++-+-----/-- Pullback of continuous real-valued functions along `φ`. -/
----++-+-----def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
----++-+-----  toFun f := f.comp φ
----++-+-----  map_zero' := by ext; simp
----++-+-----  map_one' := by ext; simp
----++-+-----  map_add' := by intros; ext; simp
----++-+-----  map_mul' := by intros; ext; simp
----++-+-----  commutes' := by intros; ext; simp
----++-+----+/-- SPB expression trees — analogous to EML expression trees. -/
----++-+----+inductive SPBExpr where
----++-+----+  | zero : SPBExpr
----++-+----+  | one : SPBExpr
----++-+----+  | var : ℕ → SPBExpr
----++-+----+  | node : SPBExpr → SPBExpr → SPBExpr
----++-+----+  deriving Repr, BEq
----++-+---- 
----++-+-----@[simp]
----++-+-----theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
----++-+-----    pullbackAlg φ f x = f (φ x) := rfl
----++-+----+/-- Evaluate an SPB expression. -/
----++-+----+def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
----++-+----+  match e with
----++-+----+  | .zero => 0
----++-+----+  | .one => 1
----++-+----+  | .var n => vars n
----++-+----+  | .node l r => spb (l.eval vars) (r.eval vars)
----++-+---- 
----++-+-----theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
----++-+-----    pullbackAlg φ f ∈ FiberConst φ := by
----++-+-----  intro x x' h; simp [h]
----++-+----+/-- Depth of an SPB expression. -/
----++-+----+def SPBExpr.depth : SPBExpr → ℕ
----++-+----+  | .zero => 0
----++-+----+  | .one => 0
----++-+----+  | .var _ => 0
----++-+----+  | .node l r => 1 + max l.depth r.depth
----++-+---- 
----++-+-----theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
----++-+-----    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----++-+-----  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
----++-+----+/-- Leaf count. -/
----++-+----+def SPBExpr.leafCount : SPBExpr → ℕ
----++-+----+  | .zero => 1
----++-+----+  | .one => 1
----++-+----+  | .var _ => 1
----++-+----+  | .node l r => l.leafCount + r.leafCount
----++-+---- 
----++-+-----theorem range_comp_subalgebra_subset_fiberConst
----++-+-----    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
----++-+-----    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----++-+-----  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
----++-+----+/-- Internal node count. -/
----++-+----+def SPBExpr.nodeCount : SPBExpr → ℕ
----++-+----+  | .zero => 0
----++-+----+  | .one => 0
----++-+----+  | .var _ => 0
----++-+----+  | .node l r => 1 + l.nodeCount + r.nodeCount
----++-+---- 
----++-+-----/-- `FiberConst φ` is closed in the uniform topology. -/
----++-+-----theorem fiberConst_closed (φ : C(X, Y)) :
----++-+-----    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
----++-+-----  refine isClosed_of_closure_subset ?_
----++-+-----  intro g hg x x' h
----++-+-----  rw [mem_closure_iff_nhds] at hg
----++-+-----  contrapose! hg
----++-+-----  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
----++-+-----    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
----++-+-----    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
----++-+----+/-- Binary tree identity: leaves = internal nodes + 1. -/
----++-+----+theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
----++-+----+    e.leafCount = e.nodeCount + 1 := by
----++-+----+  induction e with
----++-+----+  | zero => rfl
----++-+----+  | one => rfl
----++-+----+  | var _ => rfl
----++-+----+  | node l r ihl ihr =>
----++-+----+    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
----++-+----+    omega
----++-+---- 
----++-+-----omit [T2Space X] [T2Space Y] in
----++-+-----/-- The pullback map is norm-nonincreasing. -/
----++-+-----theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
----++-+-----    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
----++-+-----  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
----++-+-----    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
----++-+----+/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
----++-+----+def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
----++-+---- 
----++-+-----/-- When `φ` is surjective, pullback is an isometry. -/
----++-+-----theorem pullback_isometry_of_surjective
----++-+-----    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
----++-+-----    ‖pullbackAlg φ f‖ = ‖f‖ := by
----++-+-----  refine le_antisymm (norm_pullback_le φ f) ?_
----++-+-----  rw [ContinuousMap.norm_le _ (by positivity)]
----++-+-----  intro y; obtain ⟨x, rfl⟩ := hφ y
----++-+-----  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
----++-+----+/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
----++-+----+theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
----++-+----+  unfold logisticSigmoid
----++-+----+  rw [Real.exp_neg]
----++-+----+  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
----++-+----+  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
----++-+----+  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----++-+----+  field_simp; ring
----++-+---- 
----++-+-----omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----++-+-----theorem mem_fiberConst_of_injective
----++-+-----    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
----++-+-----    g ∈ FiberConst φ := by
----++-+-----  intro x x' h; exact congrArg g (hφ h)
----++-+----+/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
----++-+----+theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
----++-+----+  unfold softplus logisticSigmoid
----++-+----+  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
----++-+----+  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
----++-+----+  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
----++-+----+  simp at this
----++-+----+  exact this
----++-+---- 
----++-+-----omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----++-+-----theorem fiberConst_eq_top_of_injective
----++-+-----    (φ : C(X, Y)) (hφ : Function.Injective φ) :
----++-+-----    FiberConst φ = ⊤ := by
----++-+-----  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
----++-+----+/-- ShefferAlg is closed under affine pre-composition. -/
----++-+----+theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
----++-+----+    (fun x => f (a * x + b)) ∈ ShefferAlg := by
----++-+----+  obtain ⟨e, rfl⟩ := hf
----++-+----+  exact ⟨.affinePrecomp a b e, rfl⟩
----++-+---- 
----++-+-----omit [CompactSpace Y] [T2Space Y] in
----++-+-----/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
----++-+-----theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
----++-+-----    FiberConst φ = ⊤ ↔ Function.Injective φ := by
----++-+-----  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
----++-+-----  intro x x' hφ; by_contra h_ne
----++-+-----  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
----++-+-----    have := exists_continuous_zero_one_of_isClosed
----++-+-----      (show IsClosed {x} from isClosed_singleton)
----++-+-----      (show IsClosed {x'} from isClosed_singleton) (by aesop)
----++-+-----    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
----++-+-----      this.choose_spec.2.1 (Set.mem_singleton x')⟩
----++-+-----  replace h := SetLike.ext_iff.mp h g
----++-+-----  simp_all +decide [FiberConst]
----++-+-----  exact absurd (h hφ) (by simp +decide [hg])
----++-+----+/-- ShefferAlg is closed under affine combination. -/
----++-+----+theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
----++-+----+    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
----++-+----+  obtain ⟨ef, rfl⟩ := hf
----++-+----+  obtain ⟨eg, rfl⟩ := hg
----++-+----+  exact ⟨.affineComb α β γ ef eg, rfl⟩
----++-+---- 
----++-+-----/-! ### §2: Image factorization -/
----++-+----+/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
----++-+----+theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
----++-+----+  unfold softplus
----++-+----+  rw [Real.exp_neg]
----++-+----+  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
----++-+----+  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----++-+----+  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
----++-+----+  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
----++-+----+  rw [this, Real.log_exp]
----++-+---- 
----++-+-----instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
----++-+-----  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
----++-+-----
----++-+-----/-
----++-+-----The corestriction `X → Set.range φ` is a quotient map.
----++-+------/
----++-+-----theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
----++-+-----    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
----++-+-----  apply IsClosedMap.isQuotientMap;
----++-+-----  · intro s hs;
----++-+-----    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
----++-+-----    constructor <;> intro h;
----++-+-----    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
----++-+-----    · convert h.preimage ( continuous_subtype_val ) using 1;
----++-+-----      ext; simp [Set.rangeFactorization];
----++-+-----      grind;
----++-+-----  · exact continuous_induced_rng.mpr φ.continuous;
----++-+-----  · exact Set.rangeFactorization_surjective
----++-+-----
----++-+-----/-- Lift a fiber-constant function to `Set.range φ`. -/
----++-+-----noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
----++-+-----    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
----++-+-----  toFun z := g z.property.choose
----++-+-----  continuous_toFun := by
----++-+-----    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
----++-+-----    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
----++-+-----    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
----++-+-----      ext x; apply hg
----++-+-----      exact (Set.rangeFactorization φ x).property.choose_spec
----++-+-----    rw [this]; exact g.continuous
----++-+-----
----++-+-----theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
----++-+-----    (hg : g ∈ FiberConst φ) (x : X) :
----++-+-----    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
----++-+-----  simp only [fiberConstLift]
----++-+-----  apply hg
----++-+-----  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
----++-+-----
----++-+-----/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
----++-+-----theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
----++-+-----    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
----++-+-----  intro g hg
----++-+-----  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
----++-+-----  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
----++-+-----    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
----++-+-----  refine ⟨F, ?_⟩
----++-+-----  ext x
----++-+-----  simp only [pullbackAlg_apply]
----++-+-----  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
----++-+-----    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
----++-+-----    simp [ContinuousMap.comp_apply] at this; exact this
----++-+-----  rw [key, fiberConstLift_comp]
----++-+-----
----++-+-----/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
----++-+-----theorem fiberConst_eq_range_pullback_of_surjective
----++-+-----    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
----++-+-----    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
----++-+-----  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
----++-+-----    (range_pullback_subset_fiberConst φ)
----++-+-----
----++-+-----/-! ### §3: Density transport -/
----++-+-----
----++-+-----/-
----++-+-----The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
----++-+------/
----++-+-----theorem closure_range_pullback_eq_fiberConst
----++-+-----    (φ : C(X, Y))
----++-+-----    (A : Subalgebra ℝ C(Y, ℝ))
----++-+-----    (hA : Dense (A : Set C(Y, ℝ))) :
----++-+-----    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
----++-+-----      = (FiberConst φ : Set C(X, ℝ)) := by
----++-+-----  refine' le_antisymm ( closure_minimal _ _ ) _;
----++-+-----  · exact range_comp_subalgebra_subset_fiberConst φ A;
----++-+-----  · exact fiberConst_closed φ;
----++-+-----  · intro g hg;
----++-+-----    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
----++-+-----    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
----++-+-----      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
----++-+-----    rw [ Metric.mem_closure_iff ];
----++-+-----    intro ε εpos;
----++-+-----    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
----++-+-----    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
----++-+-----    nontriviality;
----++-+-----    rw [ hF, dist_eq_norm ] at *;
----++-+-----    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
----++-+-----
----++-+-----/-
----++-+-----Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
----++-+------/
----++-+-----theorem closure_range_pullback_eq_top_of_injective
----++-+-----    (φ : C(X, Y))
----++-+-----    (hφ : Function.Injective φ)
----++-+-----    (A : Subalgebra ℝ C(Y, ℝ))
----++-+-----    (hA : Dense (A : Set C(Y, ℝ))) :
----++-+-----    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
----++-+-----  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
----++-+-----  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
----++-+-----
----++-+-----/-! ### §4: ε-approximation -/
----++-+-----
----++-+-----/-
----++-+-----ε-approximation within `FiberConst φ`.
----++-+------/
----++-+-----theorem exists_pullback_approx_of_fiberConst
----++-+-----    (φ : C(X, Y))
----++-+-----    (A : Subalgebra ℝ C(Y, ℝ))
----++-+-----    (hA : Dense (A : Set C(Y, ℝ)))
----++-+-----    (g : C(X, ℝ))
----++-+-----    (hg : g ∈ FiberConst φ)
----++-+-----    {ε : ℝ} (hε : 0 < ε) :
----++-+-----    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----++-+-----  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
----++-+-----    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
----++-+-----  rw [ Metric.mem_closure_iff ] at h_closure;
----++-+-----  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
----++-+-----
----++-+-----/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
----++-+-----theorem exists_pullback_approx_of_injective
----++-+-----    (φ : C(X, Y))
----++-+-----    (hφ : Function.Injective φ)
----++-+-----    (A : Subalgebra ℝ C(Y, ℝ))
----++-+-----    (hA : Dense (A : Set C(Y, ℝ)))
----++-+-----    (g : C(X, ℝ))
----++-+-----    {ε : ℝ} (hε : 0 < ε) :
----++-+-----    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----++-+-----  exact exists_pullback_approx_of_fiberConst φ A hA g
----++-+-----    (mem_fiberConst_of_injective φ hφ g) hε+end+/-
----++-+---+Copyright (c) 2025. All rights reserved.
----++-+---+Released under Apache 2.0 license as described in the file LICENSE.
----++-+---+-/
----++-+---+import Mathlib
----++-+---+
----++-+---+/-!
----++-+---+# GL₃ Tropical Satake: Core Definitions
----++-+---+
----++-+---+This file establishes the foundational types and operations for the GL₃ tropical
----++-+---+Satake finite-determinacy theory.
----++-+---+
----++-+---+## Overview
----++-+---+
----++-+---+For GL₃, a **dominant coweight** is a triple `(a, b, c) ∈ ℕ³` with `a ≥ b ≥ c`.
----++-+---+The **dominant box** `BoxDom(B)` is the finite set of dominant coweights with `a ≤ B`.
----++-+---+
----++-+---+We define three families of **tropical Satake observables**, corresponding to the
----++-+---+three fundamental representations `ω₁, ω₂, ω₃` of GL₃:
----++-+---+
----++-+---+1. **Rank-1 profile** (`rank1Profile`): tropical convolution with the standard
----++-+---+   representation character. Uses the weights `e₁, e₂, e₃`.
----++-+---+2. **Rank-2 profile** (`rank2Profile`): tropical convolution with the exterior square
----++-+---+   character. Uses the weights `e₁+e₂, e₁+e₃, e₂+e₃`.
----++-+---+3. **Edge moment** (`edgeMoment`): tropical convolution with the determinant character
----++-+---+   `ω₃ = (1,1,1)`. This is the key reconstruction tool: as a shift operator, it
----++-+---+   recovers function values without the information loss inherent in max operations.
----++-+---+
----++-+---+The finite-determinacy theorem (proved in `FiniteDeterminacy.lean`) shows that
----++-+---+equality of these observables on finite test sets forces equality of the underlying
----++-+---+functions.
----++-+---+-/
----++-+---+
----++-+---+open Finset
----++-+---+
----++-+---+/-! ### Dominance and support conditions -/
----++-+---+
----++-+---+/-- A triple `(a, b, c)` is dominant if `a ≥ b ≥ c`. -/
----++-+---+def IsDominant (a b c : ℕ) : Prop := b ≤ a ∧ c ≤ b
----++-+---+
----++-+---+/-- A function on `ℕ³` has finite support within box `B` if it vanishes outside
----++-+---+    the dominant box `{(a,b,c) : b ≤ a, c ≤ b, a ≤ B}`. -/
----++-+---+def FiniteSupportWithin (B : ℕ) (f : ℕ → ℕ → ℕ → ℤ) : Prop :=
----++-+---+  ∀ a b c : ℕ, (B < a ∨ a < b ∨ b < c) → f a b c = 0
----++-+---+
----++-+---+/-- The box `BoxDom(B)` as a `Finset` of triples. -/
----++-+---+def boxDomFinset (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
----++-+---+  (Finset.range (B + 1) ×ˢ Finset.range (B + 1) ×ˢ Finset.range (B + 1)).filter
----++-+---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
----++-+---+
----++-+---+lemma mem_boxDomFinset {B : ℕ} {a b c : ℕ} :
----++-+---+    (a, b, c) ∈ boxDomFinset B ↔ a ≤ B ∧ b ≤ a ∧ c ≤ b := by
----++-+---+  simp [boxDomFinset, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
----++-+---+  omega
----++-+---+
----++-+---+/-! ### Tropical Satake observables -/
----++-+---+
----++-+---+/-- **Rank-1 profile**: tropical convolution with the standard representation `ω₁`.
----++-+---+
----++-+---+The weights of the standard representation of GL₃ are `e₁ = (1,0,0)`,
----++-+---+`e₂ = (0,1,0)`, `e₃ = (0,0,1)`. The rank-1 profile at `(a,b,c)` is
----++-+---+`max{f(a-1,b,c), f(a,b-1,c), f(a,b,c-1)}` with appropriate guards for ℕ subtraction.
----++-+---+
----++-+---+Note: Invalid shifts (where subtraction would go below 0) contribute the value `0`,
----++-+---+which serves as the tropical "zero" in this ℤ-valued model. -/
----++-+---+def rank1Profile (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
----++-+---+  let v1 := if 1 ≤ a then f (a - 1) b c else 0
----++-+---+  let v2 := if 1 ≤ b then f a (b - 1) c else 0
----++-+---+  let v3 := if 1 ≤ c then f a b (c - 1) else 0
----++-+---+  max v1 (max v2 v3)
----++-+---+
----++-+---+/-- **Rank-2 profile**: tropical convolution with the exterior square `ω₂ = ∧²`.
----++-+---+
----++-+---+The weights of `∧²(ℂ³)` are `e₁+e₂ = (1,1,0)`, `e₁+e₃ = (1,0,1)`,
----++-+---+`e₂+e₃ = (0,1,1)`. The rank-2 profile at `(a,b,c)` is
----++-+---+`max{f(a-1,b-1,c), f(a-1,b,c-1), f(a,b-1,c-1)}`. -/
----++-+---+def rank2Profile (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
----++-+---+  let v1 := if 1 ≤ a ∧ 1 ≤ b then f (a - 1) (b - 1) c else 0
----++-+---+  let v2 := if 1 ≤ a ∧ 1 ≤ c then f (a - 1) b (c - 1) else 0
----++-+---+  let v3 := if 1 ≤ b ∧ 1 ≤ c then f a (b - 1) (c - 1) else 0
----++-+---+  max v1 (max v2 v3)
----++-+---+
----++-+---+/-- **Edge moment**: tropical convolution with the determinant character `ω₃ = (1,1,1)`.
----++-+---+
----++-+---+This is the shift operator: `edgeMoment f (a,b,c) = f(a-1, b-1, c-1)`.
----++-+---+As a representation-theoretic operation, it corresponds to convolution with the
----++-+---+one-dimensional determinant representation `det = ∧³(ℂ³)`. Unlike the rank-1 and
----++-+---+rank-2 profiles (which use `max` and can lose information), the determinant
----++-+---+convolution perfectly preserves all function values.
----++-+---+
----++-+---+This is the key observable that makes finite determinacy possible: it acts as an
----++-+---+exact reconstruction tool rather than a lossy tropical projection. -/
----++-+---+def edgeMoment (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
----++-+---+  if 1 ≤ a ∧ 1 ≤ b ∧ 1 ≤ c then f (a - 1) (b - 1) (c - 1) else 0
----++-+---+
----++-+---+/-- Combined triple convolution observable using both rank-1 and rank-2 generators.
----++-+---+    This packages rank-1 and rank-2 data together for the combined hypothesis form. -/
----++-+---+def tripleConvObservable (f : ℕ → ℕ → ℕ → ℤ) (t s : ℕ × ℕ × ℕ) : ℤ :=
----++-+---+  rank1Profile f t.1 t.2.1 t.2.2 + rank2Profile f s.1 s.2.1 s.2.2
----++-+---+
----++-+---+/-! ### Finite test ranges -/
----++-+---+
----++-+---+/-- The finite range of rank-1 test parameters determined by box bound `B`. -/
----++-+---+def finiteRank1Range (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
----++-+---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
----++-+---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
----++-+---+
----++-+---+/-- The finite range of rank-2 test parameters determined by box bound `B`. -/
----++-+---+def finiteRank2Range (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
----++-+---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
----++-+---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
----++-+---+
----++-+---+/-- The finite range of edge moment test parameters determined by box bound `B`.
----++-+---+    These are the shifted dominant coweights `(a+1, b+1, c+1)` for `(a,b,c) ∈ BoxDom(B)`. -/
----++-+---+def finiteEdgeMomentRange (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
----++-+---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
----++-+---+    fun ⟨a, b, c⟩ => 1 ≤ c ∧ c ≤ b ∧ b ≤ a
----++-+---+
----++-+---+/-! ### Key computation lemmas -/
----++-+---+
----++-+---+/-- The edge moment at a shifted point exactly recovers the function value.
----++-+---+    This is the fundamental reconstruction identity. -/
----++-+---+@[simp]
----++-+---+lemma edgeMoment_succ (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) :
----++-+---+    edgeMoment f (a + 1) (b + 1) (c + 1) = f a b c := by
----++-+---+  simp [edgeMoment]
----++-+---+
----++-+---+/-- Shifted dominant coweights lie in the edge moment range. -/
----++-+---+lemma shifted_mem_finiteEdgeMomentRange {B a b c : ℕ}
----++-+---+    (haB : a ≤ B) (hab : b ≤ a) (hbc : c ≤ b) :
----++-+---+    (a + 1, b + 1, c + 1) ∈ finiteEdgeMomentRange B := by
----++-+---+  simp [finiteEdgeMomentRange, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
----++-+---+  omega
----++-+---+
----++-+---+/-- The rank-2 profile at the floor level `(a+1, b+1, 0)` yields `max(f(a,b,0), 0)`.
----++-+---+    When `f` is nonneg-valued on the floor, this equals `f(a,b,0)`.
----++-+---+    The `c = 0` case is special because both `ω₂`-weight shifts involving `c-1`
----++-+---+    fall outside `ℕ`, leaving only the `(1,1,0)`-weight shift. -/
----++-+---+lemma rank2Profile_floor_level (f : ℕ → ℕ → ℕ → ℤ) (a b : ℕ) :
----++-+---+    rank2Profile f (a + 1) (b + 1) 0 = max (f a b 0) 0 := by
----++-+---+  simp [rank2Profile]
----++-+---+
----++-+---+/-- For functions supported in `BoxDom(B)`, values at `a > B` vanish. -/
----++-+---+lemma FiniteSupportWithin.vanish_above {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
----++-+---+    (hf : FiniteSupportWithin B f) {a : ℕ} (ha : B < a) (b c : ℕ) :
----++-+---+    f a b c = 0 := by
----++-+---+  exact hf a b c (Or.inl ha)
----++-+---+
----++-+---+/-- For functions supported in `BoxDom(B)`, values outside dominant cone vanish. -/
----++-+---+lemma FiniteSupportWithin.vanish_nondominant {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
----++-+---+    (hf : FiniteSupportWithin B f) {a b c : ℕ} (h : a < b ∨ b < c) :
----++-+---+    f a b c = 0 := by
----++-+---+  exact hf a b c (by tauto)
----++-+---+
----++-+---+/-- Bounded-support functions vanish outside the box: explicit formulation. -/
----++-+---+lemma bounded_support_implies_vanishing_outside {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
----++-+---+    (hf : FiniteSupportWithin B f) {a b c : ℕ}
----++-+---+    (h : ¬(a ≤ B ∧ b ≤ a ∧ c ≤ b)) :
----++-+---+    f a b c = 0 := by
----++-+---+  apply hf; push_neg at h; omega+--- a/EML/Basic.lean
----++-+--++++ b/EML/Basic.lean
----++-+--+@@ -1,277 +1,125 @@
----++-+--+-/-
----++-+--+-Copyright (c) 2026 Harmonic. All rights reserved.
----++-+--+-Released under Apache 2.0 license as described in the file LICENSE.
----++-+--+--/
----++-+--+ import Mathlib
----++-+--+ 
----++-+--+-/-!
----++-+--+-# Pullback Stability of Universal Approximation
----++-+--++/-! # CatalogBuild.EML.Basic
----++-+--+ 
----++-+--+-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
----++-+--+-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
----++-+--+-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
----++-+--+-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
----++-+--+-
----++-+--+-This establishes a transport principle: universal approximation results (like
----++-+--+-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
----++-+--+-with the precise target being the fiber-constant functions.
----++-+--+-
----++-+--+-## Main definitions
----++-+--+-
----++-+--+-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
----++-+--+-  fibers of `φ`.
----++-+--+-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
----++-+--+-
----++-+--+-## Main results
----++-+--+-
----++-+--+-### Basic properties (§1)
----++-+--+-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
----++-+--+-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
----++-+--+-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
----++-+--+-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
----++-+--+-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
----++-+--+-
----++-+--+-### Factorization (§2)
----++-+--+-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
----++-+--+-  through `Set.range φ`, hence is a pullback (via Tietze extension).
----++-+--+-
----++-+--+-### Density transport (§3)
----++-+--+-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
----++-+--+-  subalgebra equals `FiberConst φ`.
----++-+--+-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
----++-+--+-
----++-+--+-### ε-approximation (§4)
----++-+--+-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
----++-+--+-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
----++-+--++Auto-generated from theorem catalog database.
----++-+--++Domain: EML
----++-+--++Declarations: 15
----++-+--+ -/
----++-+--+ 
----++-+--+-open scoped Topology
----++-+--+-open Topology
----++-+--++noncomputable section
----++-+--+ 
----++-+--+-variable {X Y : Type*}
----++-+--+-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
----++-+--+-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
----++-+--++/-- The inverse for hyperbolic SPB is also negation. -/
----++-+--++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
----++-+--++  simp [spbH]
----++-+--+ 
----++-+--+-/-! ### §1: Definitions and basic properties -/
----++-+--++/-- Wick duality: SPB with negated second argument equals the "difference"
----++-+--++in the hyperbolic SPB. This is the real-variable manifestation of the
----++-+--++Wick rotation t → it. -/
----++-+--++theorem wick_duality (x y : ℝ) :
----++-+--++    spb x (-y) = (x - y) / (1 + x * y) := by
----++-+--++  simp only [spb]
----++-+--++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
----++-+--++  rw [heq]; ring
----++-+--+ 
----++-+--+-/-- Continuous functions on `X` that are constant on fibers of `φ`.
----++-+--+-This is the natural functional-analytic object associated to a feature map:
----++-+--+-it captures exactly the observables visible through `φ`. -/
----++-+--+-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
----++-+--+-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
----++-+--+-  algebraMap_mem' r := by intro x x' _; simp
----++-+--+-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----++-+--+-  zero_mem' := by intro x x' _; simp
----++-+--+-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----++-+--+-  one_mem' := by intro x x' _; simp
----++-+--++/-- The tangent addition law IS the stereographic sum.
----++-+--++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
----++-+--++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
----++-+--++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
----++-+--++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
----++-+--++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
----++-+--++  field_simp
----++-+--+ 
----++-+--+-/-- Pullback of continuous real-valued functions along `φ`. -/
----++-+--+-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
----++-+--+-  toFun f := f.comp φ
----++-+--+-  map_zero' := by ext; simp
----++-+--+-  map_one' := by ext; simp
----++-+--+-  map_add' := by intros; ext; simp
----++-+--+-  map_mul' := by intros; ext; simp
----++-+--+-  commutes' := by intros; ext; simp
----++-+--++/-- SPB expression trees — analogous to EML expression trees. -/
----++-+--++inductive SPBExpr where
----++-+--++  | zero : SPBExpr
----++-+--++  | one : SPBExpr
----++-+--++  | var : ℕ → SPBExpr
----++-+--++  | node : SPBExpr → SPBExpr → SPBExpr
----++-+--++  deriving Repr, BEq
----++-+--+ 
----++-+--+-@[simp]
----++-+--+-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
----++-+--+-    pullbackAlg φ f x = f (φ x) := rfl
----++-+--++/-- Evaluate an SPB expression. -/
----++-+--++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
----++-+--++  match e with
----++-+--++  | .zero => 0
----++-+--++  | .one => 1
----++-+--++  | .var n => vars n
----++-+--++  | .node l r => spb (l.eval vars) (r.eval vars)
----++-+--+ 
----++-+--+-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
----++-+--+-    pullbackAlg φ f ∈ FiberConst φ := by
----++-+--+-  intro x x' h; simp [h]
----++-+--++/-- Depth of an SPB expression. -/
----++-+--++def SPBExpr.depth : SPBExpr → ℕ
----++-+--++  | .zero => 0
----++-+--++  | .one => 0
----++-+--++  | .var _ => 0
----++-+--++  | .node l r => 1 + max l.depth r.depth
----++-+--+ 
----++-+--+-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
----++-+--+-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----++-+--+-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
----++-+--++/-- Leaf count. -/
----++-+--++def SPBExpr.leafCount : SPBExpr → ℕ
----++-+--++  | .zero => 1
----++-+--++  | .one => 1
----++-+--++  | .var _ => 1
----++-+--++  | .node l r => l.leafCount + r.leafCount
----++-+--+ 
----++-+--+-theorem range_comp_subalgebra_subset_fiberConst
----++-+--+-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
----++-+--+-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----++-+--+-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
----++-+--++/-- Internal node count. -/
----++-+--++def SPBExpr.nodeCount : SPBExpr → ℕ
----++-+--++  | .zero => 0
----++-+--++  | .one => 0
----++-+--++  | .var _ => 0
----++-+--++  | .node l r => 1 + l.nodeCount + r.nodeCount
----++-+--+ 
----++-+--+-/-- `FiberConst φ` is closed in the uniform topology. -/
----++-+--+-theorem fiberConst_closed (φ : C(X, Y)) :
----++-+--+-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
----++-+--+-  refine isClosed_of_closure_subset ?_
----++-+--+-  intro g hg x x' h
----++-+--+-  rw [mem_closure_iff_nhds] at hg
----++-+--+-  contrapose! hg
----++-+--+-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
----++-+--+-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
----++-+--+-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
----++-+--++/-- Binary tree identity: leaves = internal nodes + 1. -/
----++-+--++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
----++-+--++    e.leafCount = e.nodeCount + 1 := by
----++-+--++  induction e with
----++-+--++  | zero => rfl
----++-+--++  | one => rfl
----++-+--++  | var _ => rfl
----++-+--++  | node l r ihl ihr =>
----++-+--++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
----++-+--++    omega
----++-+--+ 
----++-+--+-omit [T2Space X] [T2Space Y] in
----++-+--+-/-- The pullback map is norm-nonincreasing. -/
----++-+--+-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
----++-+--+-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
----++-+--+-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
----++-+--+-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
----++-+--++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
----++-+--++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
----++-+--+ 
----++-+--+-/-- When `φ` is surjective, pullback is an isometry. -/
----++-+--+-theorem pullback_isometry_of_surjective
----++-+--+-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
----++-+--+-    ‖pullbackAlg φ f‖ = ‖f‖ := by
----++-+--+-  refine le_antisymm (norm_pullback_le φ f) ?_
----++-+--+-  rw [ContinuousMap.norm_le _ (by positivity)]
----++-+--+-  intro y; obtain ⟨x, rfl⟩ := hφ y
----++-+--+-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
----++-+--++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
----++-+--++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
----++-+--++  unfold logisticSigmoid
----++-+--++  rw [Real.exp_neg]
----++-+--++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
----++-+--++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
----++-+--++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----++-+--++  field_simp; ring
----++-+--+ 
----++-+--+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----++-+--+-theorem mem_fiberConst_of_injective
----++-+--+-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
----++-+--+-    g ∈ FiberConst φ := by
----++-+--+-  intro x x' h; exact congrArg g (hφ h)
----++-+--++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
----++-+--++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
----++-+--++  unfold softplus logisticSigmoid
----++-+--++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
----++-+--++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
----++-+--++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
----++-+--++  simp at this
----++-+--++  exact this
----++-+--+ 
----++-+--+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----++-+--+-theorem fiberConst_eq_top_of_injective
----++-+--+-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
----++-+--+-    FiberConst φ = ⊤ := by
----++-+--+-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
----++-+--++/-- ShefferAlg is closed under affine pre-composition. -/
----++-+--++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
----++-+--++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
----++-+--++  obtain ⟨e, rfl⟩ := hf
----++-+--++  exact ⟨.affinePrecomp a b e, rfl⟩
----++-+--+ 
----++-+--+-omit [CompactSpace Y] [T2Space Y] in
----++-+--+-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
----++-+--+-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
----++-+--+-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
----++-+--+-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
----++-+--+-  intro x x' hφ; by_contra h_ne
----++-+--+-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
----++-+--+-    have := exists_continuous_zero_one_of_isClosed
----++-+--+-      (show IsClosed {x} from isClosed_singleton)
----++-+--+-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
----++-+--+-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
----++-+--+-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
----++-+--+-  replace h := SetLike.ext_iff.mp h g
----++-+--+-  simp_all +decide [FiberConst]
----++-+--+-  exact absurd (h hφ) (by simp +decide [hg])
----++-+--++/-- ShefferAlg is closed under affine combination. -/
----++-+--++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
----++-+--++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
----++-+--++  obtain ⟨ef, rfl⟩ := hf
----++-+--++  obtain ⟨eg, rfl⟩ := hg
----++-+--++  exact ⟨.affineComb α β γ ef eg, rfl⟩
----++-+--+ 
----++-+--+-/-! ### §2: Image factorization -/
----++-+--++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
----++-+--++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
----++-+--++  unfold softplus
----++-+--++  rw [Real.exp_neg]
----++-+--++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
----++-+--++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----++-+--++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
----++-+--++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
----++-+--++  rw [this, Real.log_exp]
----++-+--+ 
----++-+--+-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
----++-+--+-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
----++-+--+-
----++-+--+-/-
----++-+--+-The corestriction `X → Set.range φ` is a quotient map.
----++-+--+--/
----++-+--+-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
----++-+--+-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
----++-+--+-  apply IsClosedMap.isQuotientMap;
----++-+--+-  · intro s hs;
----++-+--+-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
----++-+--+-    constructor <;> intro h;
----++-+--+-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
----++-+--+-    · convert h.preimage ( continuous_subtype_val ) using 1;
----++-+--+-      ext; simp [Set.rangeFactorization];
----++-+--+-      grind;
----++-+--+-  · exact continuous_induced_rng.mpr φ.continuous;
----++-+--+-  · exact Set.rangeFactorization_surjective
----++-+--+-
----++-+--+-/-- Lift a fiber-constant function to `Set.range φ`. -/
----++-+--+-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
----++-+--+-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
----++-+--+-  toFun z := g z.property.choose
----++-+--+-  continuous_toFun := by
----++-+--+-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
----++-+--+-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
----++-+--+-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
----++-+--+-      ext x; apply hg
----++-+--+-      exact (Set.rangeFactorization φ x).property.choose_spec
----++-+--+-    rw [this]; exact g.continuous
----++-+--+-
----++-+--+-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
----++-+--+-    (hg : g ∈ FiberConst φ) (x : X) :
----++-+--+-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
----++-+--+-  simp only [fiberConstLift]
----++-+--+-  apply hg
----++-+--+-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
----++-+--+-
----++-+--+-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
----++-+--+-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
----++-+--+-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
----++-+--+-  intro g hg
----++-+--+-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
----++-+--+-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
----++-+--+-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
----++-+--+-  refine ⟨F, ?_⟩
----++-+--+-  ext x
----++-+--+-  simp only [pullbackAlg_apply]
----++-+--+-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
----++-+--+-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
----++-+--+-    simp [ContinuousMap.comp_apply] at this; exact this
----++-+--+-  rw [key, fiberConstLift_comp]
----++-+--+-
----++-+--+-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
----++-+--+-theorem fiberConst_eq_range_pullback_of_surjective
----++-+--+-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
----++-+--+-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
----++-+--+-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
----++-+--+-    (range_pullback_subset_fiberConst φ)
----++-+--+-
----++-+--+-/-! ### §3: Density transport -/
----++-+--+-
----++-+--+-/-
----++-+--+-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
----++-+--+--/
----++-+--+-theorem closure_range_pullback_eq_fiberConst
----++-+--+-    (φ : C(X, Y))
----++-+--+-    (A : Subalgebra ℝ C(Y, ℝ))
----++-+--+-    (hA : Dense (A : Set C(Y, ℝ))) :
----++-+--+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
----++-+--+-      = (FiberConst φ : Set C(X, ℝ)) := by
----++-+--+-  refine' le_antisymm ( closure_minimal _ _ ) _;
----++-+--+-  · exact range_comp_subalgebra_subset_fiberConst φ A;
----++-+--+-  · exact fiberConst_closed φ;
----++-+--+-  · intro g hg;
----++-+--+-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
----++-+--+-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
----++-+--+-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
----++-+--+-    rw [ Metric.mem_closure_iff ];
----++-+--+-    intro ε εpos;
----++-+--+-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
----++-+--+-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
----++-+--+-    nontriviality;
----++-+--+-    rw [ hF, dist_eq_norm ] at *;
----++-+--+-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
----++-+--+-
----++-+--+-/-
----++-+--+-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
----++-+--+--/
----++-+--+-theorem closure_range_pullback_eq_top_of_injective
----++-+--+-    (φ : C(X, Y))
----++-+--+-    (hφ : Function.Injective φ)
----++-+--+-    (A : Subalgebra ℝ C(Y, ℝ))
----++-+--+-    (hA : Dense (A : Set C(Y, ℝ))) :
----++-+--+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
----++-+--+-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
----++-+--+-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
----++-+--+-
----++-+--+-/-! ### §4: ε-approximation -/
----++-+--+-
----++-+--+-/-
----++-+--+-ε-approximation within `FiberConst φ`.
----++-+--+--/
----++-+--+-theorem exists_pullback_approx_of_fiberConst
----++-+--+-    (φ : C(X, Y))
----++-+--+-    (A : Subalgebra ℝ C(Y, ℝ))
----++-+--+-    (hA : Dense (A : Set C(Y, ℝ)))
----++-+--+-    (g : C(X, ℝ))
----++-+--+-    (hg : g ∈ FiberConst φ)
----++-+--+-    {ε : ℝ} (hε : 0 < ε) :
----++-+--+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----++-+--+-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
----++-+--+-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
----++-+--+-  rw [ Metric.mem_closure_iff ] at h_closure;
----++-+--+-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
----++-+--+-
----++-+--+-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
----++-+--+-theorem exists_pullback_approx_of_injective
----++-+--+-    (φ : C(X, Y))
----++-+--+-    (hφ : Function.Injective φ)
----++-+--+-    (A : Subalgebra ℝ C(Y, ℝ))
----++-+--+-    (hA : Dense (A : Set C(Y, ℝ)))
----++-+--+-    (g : C(X, ℝ))
----++-+--+-    {ε : ℝ} (hε : 0 < ε) :
----++-+--+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----++-+--+-  exact exists_pullback_approx_of_fiberConst φ A hA g
----++-+--+-    (mem_fiberConst_of_injective φ hφ g) hε+end+--- a/EML/Basic.lean
----++-+-++++ b/EML/Basic.lean
----++-+-+@@ -1,277 +1,125 @@
----++-+-+-/-
----++-+-+-Copyright (c) 2026 Harmonic. All rights reserved.
----++-+-+-Released under Apache 2.0 license as described in the file LICENSE.
----++-+-+--/
---- +-+-+ import Mathlib
---- +-+-+ 
-----+-+-+ namespace SimpleGraph
----++-+-+-/-!
----++-+-+-# Pullback Stability of Universal Approximation
----++-+-++/-! # CatalogBuild.EML.Basic
---- +-+-+ 
-----+-+-+-variable {V : Type*} {G : SimpleGraph V} {e : Sym2 V}
-----+-+-++variable {V : Type*} {G : SimpleGraph V}
----++-+-+-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
----++-+-+-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
----++-+-+-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
----++-+-+-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
----++-+-+-
----++-+-+-This establishes a transport principle: universal approximation results (like
----++-+-+-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
----++-+-+-with the precise target being the fiber-constant functions.
----++-+-+-
----++-+-+-## Main definitions
----++-+-+-
----++-+-+-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
----++-+-+-  fibers of `φ`.
----++-+-+-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
----++-+-+-
----++-+-+-## Main results
----++-+-+-
----++-+-+-### Basic properties (§1)
----++-+-+-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
----++-+-+-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
----++-+-+-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
----++-+-+-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
----++-+-+-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
----++-+-+-
----++-+-+-### Factorization (§2)
----++-+-+-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
----++-+-+-  through `Set.range φ`, hence is a pullback (via Tietze extension).
----++-+-+-
----++-+-+-### Density transport (§3)
----++-+-+-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
----++-+-+-  subalgebra equals `FiberConst φ`.
----++-+-+-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
----++-+-+-
----++-+-+-### ε-approximation (§4)
----++-+-+-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
----++-+-+-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
----++-+-++Auto-generated from theorem catalog database.
----++-+-++Domain: EML
----++-+-++Declarations: 15
----++-+-+ -/
---- +-+-+ 
-----+-+-+-/-! ### Trees have all bridges
-----+-+-++/-! ### Deletion equivalence
----++-+-+-open scoped Topology
----++-+-+-open Topology
----++-+-++noncomputable section
---- +-+-+ 
-----+-+-+-We prove that in a tree, every edge is a bridge. This follows from the
-----+-+-+-characterization that an edge is a bridge iff it does not lie on any cycle,
-----+-+-+-combined with the fact that trees are acyclic.
-----+-+-++`G.deleteEdges s` and `G \ fromEdgeSet s` have the same adjacency and
-----+-+-++hence the same reachability.  We prove the reachability equivalence
-----+-+-++we need. -/
-----+-+-++
-----+-+-++/-
-----+-+-++`deleteEdges {e}` and `G \ fromEdgeSet {e}` have the same reachability.
-----+-+-+ -/
-----+-+-++theorem reachable_deleteEdges_iff_reachable_sdiff {e : Sym2 V} {u v : V} :
-----+-+-++    (G.deleteEdges {e}).Reachable u v ↔ (G \ fromEdgeSet {e}).Reachable u v := by
-----+-+-++  constructor;
-----+-+-++  · intro h;
-----+-+-++    convert h.mono ?_;
-----+-+-++    intro u v; aesop;
-----+-+-++  · intro h;
-----+-+-++    convert h
----++-+-+-variable {X Y : Type*}
----++-+-+-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
----++-+-+-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
----++-+-++/-- The inverse for hyperbolic SPB is also negation. -/
----++-+-++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
----++-+-++  simp [spbH]
---- +-+-+ 
-----+-+-+-/-- In an acyclic graph, every edge is a bridge. Since there are no cycles,
-----+-+-+-no edge can lie on a cycle, which is precisely the bridge characterization. -/
-----+-+-+-theorem IsAcyclic.isBridge_of_mem_edgeSet (hAcyclic : G.IsAcyclic)
-----+-+-+-    (he : e ∈ G.edgeSet) : G.IsBridge e := by
-----+-+-+-  rw [isBridge_iff_mem_and_forall_cycle_notMem]
-----+-+-+-  exact ⟨he, fun u p hp => absurd hp (hAcyclic p)⟩
-----+-+-++/-- Bridge characterization using `deleteEdges` instead of `sdiff`. -/
-----+-+-++theorem isBridge_iff_deleteEdges {u v : V} :
-----+-+-++    G.IsBridge s(u, v) ↔ G.Adj u v ∧ ¬(G.deleteEdges {s(u, v)}).Reachable u v := by
-----+-+-++  rw [isBridge_iff]
-----+-+-++  exact ⟨
-----+-+-++    fun ⟨h1, h2⟩ => ⟨h1, fun hr => h2 (reachable_deleteEdges_iff_reachable_sdiff.mp hr)⟩,
-----+-+-++    fun ⟨h1, h2⟩ => ⟨h1, fun hr => h2 (reachable_deleteEdges_iff_reachable_sdiff.mpr hr)⟩⟩
----++-+-+-/-! ### §1: Definitions and basic properties -/
----++-+-++/-- Wick duality: SPB with negated second argument equals the "difference"
----++-+-++in the hyperbolic SPB. This is the real-variable manifestation of the
----++-+-++Wick rotation t → it. -/
----++-+-++theorem wick_duality (x y : ℝ) :
----++-+-++    spb x (-y) = (x - y) / (1 + x * y) := by
----++-+-++  simp only [spb]
----++-+-++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
----++-+-++  rw [heq]; ring
---- +-+-+ 
-----+-+-+-/-- In a tree, every edge is a bridge. This is a direct consequence of
-----+-+-+-acyclicity: since no cycles exist, no edge can participate in a cycle. -/
-----+-+-+-theorem IsTree.isBridge_of_mem_edgeSet (hTree : G.IsTree)
-----+-+-+-    (he : e ∈ G.edgeSet) : G.IsBridge e :=
-----+-+-+-  hTree.IsAcyclic.isBridge_of_mem_edgeSet he
-----+-+-++/-! ### Bridge fundamentals -/
----++-+-+-/-- Continuous functions on `X` that are constant on fibers of `φ`.
----++-+-+-This is the natural functional-analytic object associated to a feature map:
----++-+-+-it captures exactly the observables visible through `φ`. -/
----++-+-+-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
----++-+-+-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
----++-+-+-  algebraMap_mem' r := by intro x x' _; simp
----++-+-+-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----++-+-+-  zero_mem' := by intro x x' _; simp
----++-+-+-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----++-+-+-  one_mem' := by intro x x' _; simp
----++-+-++/-- The tangent addition law IS the stereographic sum.
----++-+-++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
----++-+-++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
----++-+-++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
----++-+-++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
----++-+-++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
----++-+-++  field_simp
---- +-+-+ 
-----+-+-+-/-! ### Connected graphs with all bridges are trees
-----+-+-++/-- The endpoints of a bridge lie in different connected components
-----+-+-++after the bridge is deleted. -/
-----+-+-++theorem IsBridge.connectedComponent_ne_deleteEdges {u v : V}
-----+-+-++    (hb : G.IsBridge s(u, v)) :
-----+-+-++    (G.deleteEdges {s(u, v)}).connectedComponentMk u ≠
-----+-+-++    (G.deleteEdges {s(u, v)}).connectedComponentMk v := by
-----+-+-++  rw [Ne, ConnectedComponent.eq]
-----+-+-++  exact (isBridge_iff_deleteEdges.mp hb).2
----++-+-+-/-- Pullback of continuous real-valued functions along `φ`. -/
----++-+-+-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
----++-+-+-  toFun f := f.comp φ
----++-+-+-  map_zero' := by ext; simp
----++-+-+-  map_one' := by ext; simp
----++-+-+-  map_add' := by intros; ext; simp
----++-+-+-  map_mul' := by intros; ext; simp
----++-+-+-  commutes' := by intros; ext; simp
----++-+-++/-- SPB expression trees — analogous to EML expression trees. -/
----++-+-++inductive SPBExpr where
----++-+-++  | zero : SPBExpr
----++-+-++  | one : SPBExpr
----++-+-++  | var : ℕ → SPBExpr
----++-+-++  | node : SPBExpr → SPBExpr → SPBExpr
----++-+-++  deriving Repr, BEq
---- +-+-+ 
-----+-+-+-We prove the converse: if a connected graph has the property that every
-----+-+-+-edge is a bridge, then it must be acyclic (and hence a tree).
-----+-+-++/-! ### Bridge splitting: every vertex goes to one side -/
-----+-+-++
-----+-+-++/-
-----+-+-++In a connected graph, after removing a bridge {u,v}, every vertex
-----+-+-++is reachable from either u or v (but not both, since u and v are separated).
-----+-+-++This shows the bridge partitions the vertex set into exactly two parts.
-----+-+-+ -/
-----+-+-++theorem IsBridge.forall_reachable_delete_left_or_right
-----+-+-++    (hconn : G.Connected) {u v : V} (hb : G.IsBridge s(u, v)) (w : V) :
-----+-+-++    (G.deleteEdges {s(u, v)}).Reachable u w ∨
-----+-+-++    (G.deleteEdges {s(u, v)}).Reachable v w := by
-----+-+-++  obtain ⟨ p ⟩ := hconn w u;
-----+-+-++  induction' p with w' w'' p ih;
-----+-+-++  · exact Or.inl ( SimpleGraph.Reachable.refl _ );
-----+-+-++  · cases' eq_or_ne w'' ih with h h <;> cases' eq_or_ne w'' v with h' h' <;> simp_all +decide [ SimpleGraph.isBridge_iff ];
-----+-+-++    cases' ‹ ( G.deleteEdges { s(ih, v) } ).Reachable ih p ∨ ( G.deleteEdges { s(ih, v) } ).Reachable v p › with h'' h'' <;> [ left; right ] <;> refine' h''.trans _ <;> simp_all +decide [ SimpleGraph.deleteEdges ];
-----+-+-++    · exact SimpleGraph.Adj.reachable ( by aesop ) |> SimpleGraph.Reachable.symm;
-----+-+-++    · exact SimpleGraph.Reachable.symm ( SimpleGraph.Adj.reachable ( by aesop ) )
----++-+-+-@[simp]
----++-+-+-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
----++-+-+-    pullbackAlg φ f x = f (φ x) := rfl
----++-+-++/-- Evaluate an SPB expression. -/
----++-+-++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
----++-+-++  match e with
----++-+-++  | .zero => 0
----++-+-++  | .one => 1
----++-+-++  | .var n => vars n
----++-+-++  | .node l r => spb (l.eval vars) (r.eval vars)
---- +-+-+ 
-----+-+-+-/-- If every edge of a graph is a bridge, then the graph is acyclic.
-----+-+-++/-! ### Two connected components -/
----++-+-+-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
----++-+-+-    pullbackAlg φ f ∈ FiberConst φ := by
----++-+-+-  intro x x' h; simp [h]
----++-+-++/-- Depth of an SPB expression. -/
----++-+-++def SPBExpr.depth : SPBExpr → ℕ
----++-+-++  | .zero => 0
----++-+-++  | .one => 0
----++-+-++  | .var _ => 0
----++-+-++  | .node l r => 1 + max l.depth r.depth
---- +-+-+ 
-----+-+-+-**Proof sketch**: Suppose for contradiction there exists a cycle `c`.
-----+-+-+-Since `c` is not nil, it has at least one edge `e`. This edge lies in the
-----+-+-+-edge set of `G`, so by hypothesis it is a bridge. But bridges cannot lie
-----+-+-+-on any cycle (by `isBridge_iff_mem_and_forall_cycle_notMem`), contradicting
-----+-+-+-that `e` lies on `c`. -/
-----+-+-+-theorem isAcyclic_of_forall_isBridge
-----+-+-+-    (h : ∀ e ∈ G.edgeSet, G.IsBridge e) : G.IsAcyclic := by
-----+-+-+-  intro v c hc
-----+-+-+-  -- A cycle must have at least one edge
-----+-+-+-  have hne : c.edges ≠ [] := by
-----+-+-+-    intro he
-----+-+-+-    cases c with
-----+-+-+-    | nil => exact hc.ne_nil rfl
-----+-+-+-    | cons _ _ => simp [Walk.edges_cons] at he
-----+-+-+-  obtain ⟨e, he⟩ := List.exists_mem_of_ne_nil _ hne
-----+-+-+-  have he_mem : e ∈ G.edgeSet := Walk.edges_subset_edgeSet _ he
-----+-+-+-  have hbridge := h e he_mem
-----+-+-+-  rw [isBridge_iff_mem_and_forall_cycle_notMem] at hbridge
-----+-+-+-  exact hbridge.2 c hc he
-----+-+-++/-
-----+-+-++Removing a bridge from a connected graph produces exactly two
-----+-+-++connected components. This is a fundamental structural result about
-----+-+-++bridges, showing that a bridge literally "bridges" two otherwise
-----+-+-++disconnected parts of the graph.
-----+-+-++-/
-----+-+-++theorem IsBridge.two_connected_components [DecidableEq V] [Fintype V]
-----+-+-++    [DecidableRel G.Adj]
-----+-+-++    (hconn : G.Connected) {u v : V} (hb : G.IsBridge s(u, v)) :
-----+-+-++    Fintype.card (G.deleteEdges {s(u, v)}).ConnectedComponent = 2 := by
-----+-+-++  convert Set.ncard_eq_two.mpr _;
-----+-+-++  rotate_left;
-----+-+-++  exact ( G.deleteEdges { s(u, v) } ).ConnectedComponent;
-----+-+-++  exact Set.range ( fun w => ( G.deleteEdges { s(u, v) } ).connectedComponentMk w );
-----+-+-++  · refine' ⟨ _, _, _, _ ⟩;
-----+-+-++    exact ( G.deleteEdges { s(u, v) } ).connectedComponentMk u;
-----+-+-++    exact ( G.deleteEdges { s(u, v) } ).connectedComponentMk v;
-----+-+-++    · exact connectedComponent_ne_deleteEdges hb;
-----+-+-++    · ext w;
-----+-+-++      obtain ⟨ x, rfl ⟩ := w.exists_rep;
-----+-+-++      have := hb.forall_reachable_delete_left_or_right hconn x;
-----+-+-++      cases this <;> simp_all +decide [ SimpleGraph.connectedComponentMk ];
-----+-+-++      · exact Or.inl ( Quot.sound ‹_› |> Eq.symm );
-----+-+-++      · exact Or.inr ( Quot.sound <| by tauto );
-----+-+-++  · rw [ Set.ncard_eq_toFinset_card _ ];
-----+-+-++    refine' Finset.card_bij ( fun x _ => x ) _ _ _ <;> simp +decide;
-----+-+-++    exact fun a => a.exists_rep
----++-+-+-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
----++-+-+-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----++-+-+-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
----++-+-++/-- Leaf count. -/
----++-+-++def SPBExpr.leafCount : SPBExpr → ℕ
----++-+-++  | .zero => 1
----++-+-++  | .one => 1
----++-+-++  | .var _ => 1
----++-+-++  | .node l r => l.leafCount + r.leafCount
---- +-+-+ 
-----+-+-+-/-- **Tree-Bridge Equivalence Theorem.**
-----+-+-+-A graph is a tree if and only if it is connected and every edge is a bridge.
-----+-+-++/-! ### Trees and bridges -/
----++-+-+-theorem range_comp_subalgebra_subset_fiberConst
----++-+-+-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
----++-+-+-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----++-+-+-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
----++-+-++/-- Internal node count. -/
----++-+-++def SPBExpr.nodeCount : SPBExpr → ℕ
----++-+-++  | .zero => 0
----++-+-++  | .one => 0
----++-+-++  | .var _ => 0
----++-+-++  | .node l r => 1 + l.nodeCount + r.nodeCount
---- +-+-+ 
-----+-+-+-This is a fundamental characterization of trees: they are precisely the
-----+-+-+-connected graphs that are "minimally connected" — removing any single
-----+-+-+-edge disconnects the graph.
-----+-+-++/-
-----+-+-++Every edge of a tree is a bridge. In a tree, every edge is critical
-----+-+-++for connectivity — removing any edge disconnects the tree.
-----+-+-++-/
-----+-+-++theorem IsTree.isBridge_of_adj (hT : G.IsTree) {u v : V} (hadj : G.Adj u v) :
-----+-+-++    G.IsBridge s(u, v) := by
-----+-+-++  -- By definition of a tree, it is acyclic.
-----+-+-++  have h_acyclic : G.IsAcyclic := by
-----+-+-++    exact hT.2;
-----+-+-++  rw [ SimpleGraph.isAcyclic_iff_forall_adj_isBridge ] at h_acyclic ; aesop
----++-+-+-/-- `FiberConst φ` is closed in the uniform topology. -/
----++-+-+-theorem fiberConst_closed (φ : C(X, Y)) :
----++-+-+-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
----++-+-+-  refine isClosed_of_closure_subset ?_
----++-+-+-  intro g hg x x' h
----++-+-+-  rw [mem_closure_iff_nhds] at hg
----++-+-+-  contrapose! hg
----++-+-+-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
----++-+-+-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
----++-+-+-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
----++-+-++/-- Binary tree identity: leaves = internal nodes + 1. -/
----++-+-++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
----++-+-++    e.leafCount = e.nodeCount + 1 := by
----++-+-++  induction e with
----++-+-++  | zero => rfl
----++-+-++  | one => rfl
----++-+-++  | var _ => rfl
----++-+-++  | node l r ihl ihr =>
----++-+-++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
----++-+-++    omega
---- +-+-+ 
-----+-+-+-### Forward direction
-----+-+-+-In a tree (connected + acyclic), every edge is a bridge because there are
-----+-+-+-no cycles, so no edge can lie on a cycle.
-----+++-+-/-- Lift a fiber-constant function to `Set.range φ`. -/
-----+++-+-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
-----+++-+-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
-----+++-+-  toFun z := g z.property.choose
-----+++-+-  continuous_toFun := by
-----+++-+-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
-----+++-+-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
-----+++-+-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
-----+++-+-      ext x; apply hg
-----+++-+-      exact (Set.rangeFactorization φ x).property.choose_spec
-----+++-+-    rw [this]; exact g.continuous
-----+ +-+-
-----+-+-+-### Reverse direction
-----+-+-+-If every edge is a bridge, the graph must be acyclic: any cycle would contain
-----+-+-+-an edge that both lies on a cycle and is a bridge, which is a contradiction. -/
-----+-+-+-theorem isTree_iff_connected_and_forall_isBridge :
-----+-+-+-    G.IsTree ↔ G.Connected ∧ ∀ e ∈ G.edgeSet, G.IsBridge e := by
-----+-+-+-  constructor
-----+-+-+-  · intro hTree
-----+-+-+-    exact ⟨hTree.isConnected, fun e he => hTree.isBridge_of_mem_edgeSet he⟩
-----+-+-+-  · intro ⟨hConn, hBridge⟩
-----+-+-+-    exact ⟨hConn, isAcyclic_of_forall_isBridge hBridge⟩
-----+-+-++/-
-----+-+-++A connected graph is a tree if and only if every edge is a bridge.
-----+-+-++This provides a characterization of trees in terms of edge criticality.
-----+-+-++-/
-----+-+-++theorem connected_isBridge_all_iff_isTree (hconn : G.Connected) :
-----+-+-++    (∀ ⦃u v : V⦄, G.Adj u v → G.IsBridge s(u, v)) ↔ G.IsTree := by
-----+-+-++  constructor;
-----+-+-++  · intro h;
-----+-+-++    constructor;
-----+-+-++    · assumption;
-----+-+-++    · exact isAcyclic_iff_forall_adj_isBridge.mpr h;
-----+-+-++  · exact fun a ⦃u v⦄ a_1 => IsTree.isBridge_of_adj a a_1
----++-+-+-omit [T2Space X] [T2Space Y] in
----++-+-+-/-- The pullback map is norm-nonincreasing. -/
----++-+-+-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
----++-+-+-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
----++-+-+-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
----++-+-+-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
----++-+-++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
----++-+-++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
---- +-+-+ 
-----+-+-+ end SimpleGraph++-open scoped Topology
-----+-+++-open Topology
-----+-++++noncomputable section
-----+-+++ 
-----+-+++-variable {X Y : Type*}
-----+-+++-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
-----+-+++-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
-----+-++++/-- The inverse for hyperbolic SPB is also negation. -/
-----+-++++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
-----+-++++  simp [spbH]
-----+-+++ 
-----+-+++-/-! ### §1: Definitions and basic properties -/
-----+-++++/-- Wick duality: SPB with negated second argument equals the "difference"
-----+-++++in the hyperbolic SPB. This is the real-variable manifestation of the
-----+-++++Wick rotation t → it. -/
-----+-++++theorem wick_duality (x y : ℝ) :
-----+-++++    spb x (-y) = (x - y) / (1 + x * y) := by
-----+-++++  simp only [spb]
-----+-++++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
-----+-++++  rw [heq]; ring
-----+-+++ 
-----+-+++-/-- Continuous functions on `X` that are constant on fibers of `φ`.
-----+-+++-This is the natural functional-analytic object associated to a feature map:
-----+-+++-it captures exactly the observables visible through `φ`. -/
-----+-+++-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
-----+-+++-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
-----+-+++-  algebraMap_mem' r := by intro x x' _; simp
-----+-+++-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----+-+++-  zero_mem' := by intro x x' _; simp
-----+-+++-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----+-+++-  one_mem' := by intro x x' _; simp
-----+-++++/-- The tangent addition law IS the stereographic sum.
-----+-++++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
-----+-++++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
-----+-++++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
-----+-++++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
-----+-++++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
-----+-++++  field_simp
-----+-+++ 
-----+-+++-/-- Pullback of continuous real-valued functions along `φ`. -/
-----+-+++-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
-----+-+++-  toFun f := f.comp φ
-----+-+++-  map_zero' := by ext; simp
-----+-+++-  map_one' := by ext; simp
-----+-+++-  map_add' := by intros; ext; simp
-----+-+++-  map_mul' := by intros; ext; simp
-----+-+++-  commutes' := by intros; ext; simp
-----+-++++/-- SPB expression trees — analogous to EML expression trees. -/
-----+-++++inductive SPBExpr where
-----+-++++  | zero : SPBExpr
-----+-++++  | one : SPBExpr
-----+-++++  | var : ℕ → SPBExpr
-----+-++++  | node : SPBExpr → SPBExpr → SPBExpr
-----+-++++  deriving Repr, BEq
-----+-+++ 
-----+-+++-@[simp]
-----+-+++-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
-----+-+++-    pullbackAlg φ f x = f (φ x) := rfl
-----+-++++/-- Evaluate an SPB expression. -/
-----+-++++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
-----+-++++  match e with
-----+-++++  | .zero => 0
-----+-++++  | .one => 1
-----+-++++  | .var n => vars n
-----+-++++  | .node l r => spb (l.eval vars) (r.eval vars)
-----+-+++ 
-----+-+++-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----+-+++-    pullbackAlg φ f ∈ FiberConst φ := by
-----+-+++-  intro x x' h; simp [h]
-----+-++++/-- Depth of an SPB expression. -/
-----+-++++def SPBExpr.depth : SPBExpr → ℕ
-----+-++++  | .zero => 0
-----+-++++  | .one => 0
-----+-++++  | .var _ => 0
-----+-++++  | .node l r => 1 + max l.depth r.depth
-----+-+++ 
-----+-+++-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
-----+-+++-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----+-+++-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
-----+-++++/-- Leaf count. -/
-----+-++++def SPBExpr.leafCount : SPBExpr → ℕ
-----+-++++  | .zero => 1
-----+-++++  | .one => 1
-----+-++++  | .var _ => 1
-----+-++++  | .node l r => l.leafCount + r.leafCount
-----+-+++ 
-----+-+++-theorem range_comp_subalgebra_subset_fiberConst
-----+-+++-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
-----+-+++-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----+-+++-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
-----+-++++/-- Internal node count. -/
-----+-++++def SPBExpr.nodeCount : SPBExpr → ℕ
-----+-++++  | .zero => 0
-----+-++++  | .one => 0
-----+-++++  | .var _ => 0
-----+-++++  | .node l r => 1 + l.nodeCount + r.nodeCount
-----+-+++ 
-----+-+++-/-- `FiberConst φ` is closed in the uniform topology. -/
-----+-+++-theorem fiberConst_closed (φ : C(X, Y)) :
-----+-+++-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
-----+-+++-  refine isClosed_of_closure_subset ?_
-----+-+++-  intro g hg x x' h
-----+-+++-  rw [mem_closure_iff_nhds] at hg
-----+-+++-  contrapose! hg
-----+-+++-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
-----+-+++-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
-----+-+++-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
-----+-++++/-- Binary tree identity: leaves = internal nodes + 1. -/
-----+-++++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
-----+-++++    e.leafCount = e.nodeCount + 1 := by
-----+-++++  induction e with
-----+-++++  | zero => rfl
-----+-++++  | one => rfl
-----+-++++  | var _ => rfl
-----+-++++  | node l r ihl ihr =>
-----+-++++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
-----+-++++    omega
-----+-+++ 
-----+-+++-omit [T2Space X] [T2Space Y] in
-----+-+++-/-- The pullback map is norm-nonincreasing. -/
-----+-+++-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----+-+++-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
-----+-+++-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
-----+-+++-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
-----+-++++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
-----+-++++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
-----+-+++ 
-----+-+++-/-- When `φ` is surjective, pullback is an isometry. -/
-----+-+++-theorem pullback_isometry_of_surjective
-----+-+++-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
-----+-+++-    ‖pullbackAlg φ f‖ = ‖f‖ := by
-----+-+++-  refine le_antisymm (norm_pullback_le φ f) ?_
-----+-+++-  rw [ContinuousMap.norm_le _ (by positivity)]
-----+-+++-  intro y; obtain ⟨x, rfl⟩ := hφ y
-----+-+++-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
-----+-++++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
-----+-++++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
-----+-++++  unfold logisticSigmoid
-----+-++++  rw [Real.exp_neg]
-----+-++++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
-----+-++++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
-----+-++++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----+-++++  field_simp; ring
-----+-+++ 
-----+-+++-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----+-+++-theorem mem_fiberConst_of_injective
-----+-+++-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
-----+-+++-    g ∈ FiberConst φ := by
-----+-+++-  intro x x' h; exact congrArg g (hφ h)
-----+-++++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
-----+-++++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
-----+-++++  unfold softplus logisticSigmoid
-----+-++++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
-----+-++++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
-----+-++++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
-----+-++++  simp at this
-----+-++++  exact this
-----+-+++ 
-----+-+++-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----+-+++-theorem fiberConst_eq_top_of_injective
-----+-+++-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
-----+-+++-    FiberConst φ = ⊤ := by
-----+-+++-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
-----+-++++/-- ShefferAlg is closed under affine pre-composition. -/
-----+-++++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
-----+-++++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
-----+-++++  obtain ⟨e, rfl⟩ := hf
-----+-++++  exact ⟨.affinePrecomp a b e, rfl⟩
-----+-+++ 
-----+-+++-omit [CompactSpace Y] [T2Space Y] in
-----+-+++-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
-----+-+++-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
-----+-+++-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
-----+-+++-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
-----+-+++-  intro x x' hφ; by_contra h_ne
-----+-+++-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
-----+-+++-    have := exists_continuous_zero_one_of_isClosed
-----+-+++-      (show IsClosed {x} from isClosed_singleton)
-----+-+++-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
-----+-+++-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
-----+-+++-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
-----+-+++-  replace h := SetLike.ext_iff.mp h g
-----+-+++-  simp_all +decide [FiberConst]
-----+-+++-  exact absurd (h hφ) (by simp +decide [hg])
-----+-++++/-- ShefferAlg is closed under affine combination. -/
-----+-++++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
-----+-++++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
-----+-++++  obtain ⟨ef, rfl⟩ := hf
-----+-++++  obtain ⟨eg, rfl⟩ := hg
-----+-++++  exact ⟨.affineComb α β γ ef eg, rfl⟩
-----+-+++ 
-----+-+++-/-! ### §2: Image factorization -/
-----+-++++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
-----+-++++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
-----+-++++  unfold softplus
-----+-++++  rw [Real.exp_neg]
-----+-++++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
-----+-++++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----+-++++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
-----+-++++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
-----+-++++  rw [this, Real.log_exp]
-----+-+++ 
-----+-+++-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
-----+-+++-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
-----+-+++-
-----+-+++-/-
-----+-+++-The corestriction `X → Set.range φ` is a quotient map.
-----+-+++--/
-----+-+++-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
-----+-+++-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
-----+-+++-  apply IsClosedMap.isQuotientMap;
-----+-+++-  · intro s hs;
-----+-+++-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
-----+-+++-    constructor <;> intro h;
-----+-+++-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
-----+-+++-    · convert h.preimage ( continuous_subtype_val ) using 1;
-----+-+++-      ext; simp [Set.rangeFactorization];
-----+-+++-      grind;
-----+-+++-  · exact continuous_induced_rng.mpr φ.continuous;
-----+-+++-  · exact Set.rangeFactorization_surjective
-----+-+++-
-----+-+++-/-- Lift a fiber-constant function to `Set.range φ`. -/
-----+-+++-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
-----+-+++-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
-----+-+++-  toFun z := g z.property.choose
-----+-+++-  continuous_toFun := by
-----+-+++-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
-----+-+++-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
-----+-+++-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
-----+-+++-      ext x; apply hg
-----+-+++-      exact (Set.rangeFactorization φ x).property.choose_spec
-----+-+++-    rw [this]; exact g.continuous
-----+-+++-
-----+-+++-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
-----+-+++-    (hg : g ∈ FiberConst φ) (x : X) :
-----+-+++-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
-----+-+++-  simp only [fiberConstLift]
-----+-+++-  apply hg
-----+-+++-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
-----+-+++-
-----+-+++-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
-----+-+++-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
-----+-+++-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
-----+-+++-  intro g hg
-----+-+++-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
-----+-+++-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
-----+-+++-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
-----+-+++-  refine ⟨F, ?_⟩
-----+-+++-  ext x
-----+-+++-  simp only [pullbackAlg_apply]
-----+-+++-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
-----+-+++-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
-----+-+++-    simp [ContinuousMap.comp_apply] at this; exact this
-----+-+++-  rw [key, fiberConstLift_comp]
-----+-+++-
-----+-+++-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
-----+-+++-theorem fiberConst_eq_range_pullback_of_surjective
-----+-+++-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
-----+-+++-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
-----+-+++-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
-----+-+++-    (range_pullback_subset_fiberConst φ)
-----+-+++-
-----+-+++-/-! ### §3: Density transport -/
-----+-+++-
-----+-+++-/-
-----+-+++-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
-----+-+++--/
-----+-+++-theorem closure_range_pullback_eq_fiberConst
-----+-+++-    (φ : C(X, Y))
-----+-+++-    (A : Subalgebra ℝ C(Y, ℝ))
-----+-+++-    (hA : Dense (A : Set C(Y, ℝ))) :
-----+-+++-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
-----+-+++-      = (FiberConst φ : Set C(X, ℝ)) := by
-----+-+++-  refine' le_antisymm ( closure_minimal _ _ ) _;
-----+-+++-  · exact range_comp_subalgebra_subset_fiberConst φ A;
-----+-+++-  · exact fiberConst_closed φ;
-----+-+++-  · intro g hg;
-----+-+++-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
-----+-+++-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
-----+-+++-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
-----+-+++-    rw [ Metric.mem_closure_iff ];
-----+-+++-    intro ε εpos;
-----+-+++-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
-----+-+++-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
-----+-+++-    nontriviality;
-----+-+++-    rw [ hF, dist_eq_norm ] at *;
-----+-+++-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
-----+-+++-
-----+-+++-/-
-----+-+++-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
-----+-+++--/
-----+-+++-theorem closure_range_pullback_eq_top_of_injective
-----+-+++-    (φ : C(X, Y))
-----+-+++-    (hφ : Function.Injective φ)
-----+-+++-    (A : Subalgebra ℝ C(Y, ℝ))
-----+-+++-    (hA : Dense (A : Set C(Y, ℝ))) :
-----+-+++-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
-----+-+++-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
-----+-+++-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
-----+-+++-
-----+-+++-/-! ### §4: ε-approximation -/
-----+-+++-
-----+-+++-/-
-----+-+++-ε-approximation within `FiberConst φ`.
-----+-+++--/
-----+-+++-theorem exists_pullback_approx_of_fiberConst
-----+-+++-    (φ : C(X, Y))
-----+-+++-    (A : Subalgebra ℝ C(Y, ℝ))
-----+-+++-    (hA : Dense (A : Set C(Y, ℝ)))
-----+-+++-    (g : C(X, ℝ))
-----+-+++-    (hg : g ∈ FiberConst φ)
-----+-+++-    {ε : ℝ} (hε : 0 < ε) :
-----+-+++-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----+-+++-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
-----+-+++-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
-----+-+++-  rw [ Metric.mem_closure_iff ] at h_closure;
-----+-+++-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
-----+-+++-
-----+-+++-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
-----+-+++-theorem exists_pullback_approx_of_injective
-----+-+++-    (φ : C(X, Y))
-----+-+++-    (hφ : Function.Injective φ)
-----+-+++-    (A : Subalgebra ℝ C(Y, ℝ))
-----+-+++-    (hA : Dense (A : Set C(Y, ℝ)))
-----+-+++-    (g : C(X, ℝ))
-----+-+++-    {ε : ℝ} (hε : 0 < ε) :
-----+-+++-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----+-+++-  exact exists_pullback_approx_of_fiberConst φ A hA g
-----+-+++-    (mem_fiberConst_of_injective φ hφ g) hε+end++-+-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
-----+++-+-    (hg : g ∈ FiberConst φ) (x : X) :
-----+++-+-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
-----+++-+-  simp only [fiberConstLift]
-----+++-+-  apply hg
-----+++-+-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
-----+++-+-
-----+++-+-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
-----+++-+-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
-----+++-+-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
-----+++-+-  intro g hg
-----+++-+-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
-----+++-+-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
-----+++-+-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
-----+++-+-  refine ⟨F, ?_⟩
-----+++-+-  ext x
-----+++-+-  simp only [pullbackAlg_apply]
-----+++-+-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
-----+++-+-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
-----+++-+-    simp [ContinuousMap.comp_apply] at this; exact this
-----+++-+-  rw [key, fiberConstLift_comp]
-----+++-+-
-----+++-+-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
-----+++-+-theorem fiberConst_eq_range_pullback_of_surjective
-----+++-+-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
-----+++-+-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
-----+++-+-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
-----+++-+-    (range_pullback_subset_fiberConst φ)
-----+++-+-
-----+++-+-/-! ### §3: Density transport -/
-----+++-+-
-----+++-+-/-
-----+++-+-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
-----+++-+--/
-----+++-+-theorem closure_range_pullback_eq_fiberConst
-----+++-+-    (φ : C(X, Y))
-----+++-+-    (A : Subalgebra ℝ C(Y, ℝ))
-----+++-+-    (hA : Dense (A : Set C(Y, ℝ))) :
-----+++-+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
-----+++-+-      = (FiberConst φ : Set C(X, ℝ)) := by
-----+++-+-  refine' le_antisymm ( closure_minimal _ _ ) _;
-----+++-+-  · exact range_comp_subalgebra_subset_fiberConst φ A;
-----+++-+-  · exact fiberConst_closed φ;
-----+++-+-  · intro g hg;
-----+++-+-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
-----+++-+-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
-----+++-+-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
-----+++-+-    rw [ Metric.mem_closure_iff ];
-----+++-+-    intro ε εpos;
-----+++-+-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
-----+++-+-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
-----+++-+-    nontriviality;
-----+++-+-    rw [ hF, dist_eq_norm ] at *;
-----+++-+-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
-----+++-+-
-----+++-+-/-
-----+++-+-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
-----+++-+--/
-----+++-+-theorem closure_range_pullback_eq_top_of_injective
-----+++-+-    (φ : C(X, Y))
-----+++-+-    (hφ : Function.Injective φ)
-----+++-+-    (A : Subalgebra ℝ C(Y, ℝ))
-----+++-+-    (hA : Dense (A : Set C(Y, ℝ))) :
-----+++-+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
-----+++-+-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
-----+++-+-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
-----+++-+-
-----+++-+-/-! ### §4: ε-approximation -/
-----+++-+-
-----+++-+-/-
-----+++-+-ε-approximation within `FiberConst φ`.
-----+++-+--/
-----+++-+-theorem exists_pullback_approx_of_fiberConst
-----+++-+-    (φ : C(X, Y))
-----+++-+-    (A : Subalgebra ℝ C(Y, ℝ))
-----+++-+-    (hA : Dense (A : Set C(Y, ℝ)))
-----+++-+-    (g : C(X, ℝ))
-----+++-+-    (hg : g ∈ FiberConst φ)
-----+++-+-    {ε : ℝ} (hε : 0 < ε) :
-----+++-+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----+++-+-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
-----+++-+-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
-----+++-+-  rw [ Metric.mem_closure_iff ] at h_closure;
-----+++-+-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
-----+++-+-
-----+++-+-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
-----+++-+-theorem exists_pullback_approx_of_injective
-----+++-+-    (φ : C(X, Y))
-----+++-+-    (hφ : Function.Injective φ)
-----+++-+-    (A : Subalgebra ℝ C(Y, ℝ))
-----+++-+-    (hA : Dense (A : Set C(Y, ℝ)))
-----+++-+-    (g : C(X, ℝ))
-----+++-+-    {ε : ℝ} (hε : 0 < ε) :
-----+++-+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----+++-+-  exact exists_pullback_approx_of_fiberConst φ A hA g
-----+++-+-    (mem_fiberConst_of_injective φ hφ g) hε+end+--- a/EML/Basic.lean
-----+++++++ b/EML/Basic.lean
-----++++@@ -1,277 +1,125 @@
-----++++-/-
-----++++-Copyright (c) 2026 Harmonic. All rights reserved.
-----++++-Released under Apache 2.0 license as described in the file LICENSE.
-----++++--/
-----++++ import Mathlib
-----++++ 
-----++++-/-!
-----++++-# Pullback Stability of Universal Approximation
-----+++++/-! # CatalogBuild.EML.Basic
-----++++ 
-----++++-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
-----++++-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
-----++++-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
-----++++-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
-----++++-
-----++++-This establishes a transport principle: universal approximation results (like
-----++++-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
-----++++-with the precise target being the fiber-constant functions.
-----++++-
-----++++-## Main definitions
-----++++-
-----++++-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
-----++++-  fibers of `φ`.
-----++++-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
-----++++-
-----++++-## Main results
-----++++-
-----++++-### Basic properties (§1)
-----++++-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
-----++++-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
-----++++-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
-----++++-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
-----++++-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
-----++++-
-----++++-### Factorization (§2)
-----++++-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
-----++++-  through `Set.range φ`, hence is a pullback (via Tietze extension).
-----++++-
-----++++-### Density transport (§3)
-----++++-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
-----++++-  subalgebra equals `FiberConst φ`.
-----++++-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
-----++++-
-----++++-### ε-approximation (§4)
-----++++-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
-----++++-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
-----+++++Auto-generated from theorem catalog database.
-----+++++Domain: EML
-----+++++Declarations: 15
-----++++ -/
-----++++ 
-----++++-open scoped Topology
-----++++-open Topology
-----+++++noncomputable section
-----++++ 
-----++++-variable {X Y : Type*}
-----++++-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
-----++++-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
-----+++++/-- The inverse for hyperbolic SPB is also negation. -/
-----+++++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
-----+++++  simp [spbH]
-----++++ 
-----++++-/-! ### §1: Definitions and basic properties -/
-----+++++/-- Wick duality: SPB with negated second argument equals the "difference"
-----+++++in the hyperbolic SPB. This is the real-variable manifestation of the
-----+++++Wick rotation t → it. -/
-----+++++theorem wick_duality (x y : ℝ) :
-----+++++    spb x (-y) = (x - y) / (1 + x * y) := by
-----+++++  simp only [spb]
-----+++++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
-----+++++  rw [heq]; ring
-----++++ 
-----++++-/-- Continuous functions on `X` that are constant on fibers of `φ`.
-----++++-This is the natural functional-analytic object associated to a feature map:
-----++++-it captures exactly the observables visible through `φ`. -/
-----++++-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
-----++++-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
-----++++-  algebraMap_mem' r := by intro x x' _; simp
-----++++-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----++++-  zero_mem' := by intro x x' _; simp
-----++++-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----++++-  one_mem' := by intro x x' _; simp
-----+++++/-- The tangent addition law IS the stereographic sum.
-----+++++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
-----+++++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
-----+++++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
-----+++++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
-----+++++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
-----+++++  field_simp
-----++++ 
-----++++-/-- Pullback of continuous real-valued functions along `φ`. -/
-----++++-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
-----++++-  toFun f := f.comp φ
-----++++-  map_zero' := by ext; simp
-----++++-  map_one' := by ext; simp
-----++++-  map_add' := by intros; ext; simp
-----++++-  map_mul' := by intros; ext; simp
-----++++-  commutes' := by intros; ext; simp
-----+++++/-- SPB expression trees — analogous to EML expression trees. -/
-----+++++inductive SPBExpr where
-----+++++  | zero : SPBExpr
-----+++++  | one : SPBExpr
-----+++++  | var : ℕ → SPBExpr
-----+++++  | node : SPBExpr → SPBExpr → SPBExpr
-----+++++  deriving Repr, BEq
-----++++ 
-----++++-@[simp]
-----++++-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
-----++++-    pullbackAlg φ f x = f (φ x) := rfl
-----+++++/-- Evaluate an SPB expression. -/
-----+++++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
-----+++++  match e with
-----+++++  | .zero => 0
-----+++++  | .one => 1
-----+++++  | .var n => vars n
-----+++++  | .node l r => spb (l.eval vars) (r.eval vars)
-----++++ 
-----++++-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----++++-    pullbackAlg φ f ∈ FiberConst φ := by
-----++++-  intro x x' h; simp [h]
-----+++++/-- Depth of an SPB expression. -/
-----+++++def SPBExpr.depth : SPBExpr → ℕ
-----+++++  | .zero => 0
-----+++++  | .one => 0
-----+++++  | .var _ => 0
-----+++++  | .node l r => 1 + max l.depth r.depth
-----++++ 
-----++++-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
-----++++-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----++++-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
-----+++++/-- Leaf count. -/
-----+++++def SPBExpr.leafCount : SPBExpr → ℕ
-----+++++  | .zero => 1
-----+++++  | .one => 1
-----+++++  | .var _ => 1
-----+++++  | .node l r => l.leafCount + r.leafCount
-----++++ 
-----++++-theorem range_comp_subalgebra_subset_fiberConst
-----++++-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
-----++++-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----++++-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
-----+++++/-- Internal node count. -/
-----+++++def SPBExpr.nodeCount : SPBExpr → ℕ
-----+++++  | .zero => 0
-----+++++  | .one => 0
-----+++++  | .var _ => 0
-----+++++  | .node l r => 1 + l.nodeCount + r.nodeCount
-----++++ 
-----++++-/-- `FiberConst φ` is closed in the uniform topology. -/
-----++++-theorem fiberConst_closed (φ : C(X, Y)) :
-----++++-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
-----++++-  refine isClosed_of_closure_subset ?_
-----++++-  intro g hg x x' h
-----++++-  rw [mem_closure_iff_nhds] at hg
-----++++-  contrapose! hg
-----++++-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
-----++++-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
-----++++-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
-----+++++/-- Binary tree identity: leaves = internal nodes + 1. -/
-----+++++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
-----+++++    e.leafCount = e.nodeCount + 1 := by
-----+++++  induction e with
-----+++++  | zero => rfl
-----+++++  | one => rfl
-----+++++  | var _ => rfl
-----+++++  | node l r ihl ihr =>
-----+++++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
-----+++++    omega
-----++++ 
-----++++-omit [T2Space X] [T2Space Y] in
-----++++-/-- The pullback map is norm-nonincreasing. -/
-----++++-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----++++-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
-----++++-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
-----++++-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
-----+++++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
-----+++++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
-----++++ 
-----++++-/-- When `φ` is surjective, pullback is an isometry. -/
-----++++-theorem pullback_isometry_of_surjective
-----++++-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
-----++++-    ‖pullbackAlg φ f‖ = ‖f‖ := by
-----++++-  refine le_antisymm (norm_pullback_le φ f) ?_
-----++++-  rw [ContinuousMap.norm_le _ (by positivity)]
-----++++-  intro y; obtain ⟨x, rfl⟩ := hφ y
-----++++-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
-----+++++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
-----+++++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
-----+++++  unfold logisticSigmoid
-----+++++  rw [Real.exp_neg]
-----+++++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
-----+++++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
-----+++++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----+++++  field_simp; ring
-----++++ 
-----++++-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----++++-theorem mem_fiberConst_of_injective
-----++++-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
-----++++-    g ∈ FiberConst φ := by
-----++++-  intro x x' h; exact congrArg g (hφ h)
-----+++++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
-----+++++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
-----+++++  unfold softplus logisticSigmoid
-----+++++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
-----+++++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
-----+++++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
-----+++++  simp at this
-----+++++  exact this
-----++++ 
-----++++-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----++++-theorem fiberConst_eq_top_of_injective
-----++++-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
-----++++-    FiberConst φ = ⊤ := by
-----++++-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
-----+++++/-- ShefferAlg is closed under affine pre-composition. -/
-----+++++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
-----+++++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
-----+++++  obtain ⟨e, rfl⟩ := hf
-----+++++  exact ⟨.affinePrecomp a b e, rfl⟩
-----++++ 
-----++++-omit [CompactSpace Y] [T2Space Y] in
-----++++-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
-----++++-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
-----++++-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
-----++++-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
-----++++-  intro x x' hφ; by_contra h_ne
-----++++-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
-----++++-    have := exists_continuous_zero_one_of_isClosed
-----++++-      (show IsClosed {x} from isClosed_singleton)
-----++++-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
-----++++-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
-----++++-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
-----++++-  replace h := SetLike.ext_iff.mp h g
-----++++-  simp_all +decide [FiberConst]
-----++++-  exact absurd (h hφ) (by simp +decide [hg])
-----+++++/-- ShefferAlg is closed under affine combination. -/
-----+++++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
-----+++++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
-----+++++  obtain ⟨ef, rfl⟩ := hf
-----+++++  obtain ⟨eg, rfl⟩ := hg
-----+++++  exact ⟨.affineComb α β γ ef eg, rfl⟩
-----++++ 
-----++++-/-! ### §2: Image factorization -/
-----+++++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
-----+++++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
-----+++++  unfold softplus
-----+++++  rw [Real.exp_neg]
-----+++++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
-----+++++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-----+++++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
-----+++++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
-----+++++  rw [this, Real.log_exp]
-----++++ 
-----++++-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
-----++++-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
-----++++-
-----++++-/-
-----++++-The corestriction `X → Set.range φ` is a quotient map.
-----++++--/
-----++++-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
-----++++-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
-----++++-  apply IsClosedMap.isQuotientMap;
-----++++-  · intro s hs;
-----++++-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
-----++++-    constructor <;> intro h;
-----++++-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
-----++++-    · convert h.preimage ( continuous_subtype_val ) using 1;
-----++++-      ext; simp [Set.rangeFactorization];
-----++++-      grind;
-----++++-  · exact continuous_induced_rng.mpr φ.continuous;
-----++++-  · exact Set.rangeFactorization_surjective
-----++++-
-----++++-/-- Lift a fiber-constant function to `Set.range φ`. -/
-----++++-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
-----++++-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
-----++++-  toFun z := g z.property.choose
-----++++-  continuous_toFun := by
-----++++-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
-----++++-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
-----++++-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
-----++++-      ext x; apply hg
-----++++-      exact (Set.rangeFactorization φ x).property.choose_spec
-----++++-    rw [this]; exact g.continuous
-----++++-
-----++++-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
-----++++-    (hg : g ∈ FiberConst φ) (x : X) :
-----++++-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
-----++++-  simp only [fiberConstLift]
-----++++-  apply hg
-----++++-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
-----++++-
-----++++-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
-----++++-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
-----++++-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
-----++++-  intro g hg
-----++++-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
-----++++-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
-----++++-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
-----++++-  refine ⟨F, ?_⟩
-----++++-  ext x
-----++++-  simp only [pullbackAlg_apply]
-----++++-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
-----++++-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
-----++++-    simp [ContinuousMap.comp_apply] at this; exact this
-----++++-  rw [key, fiberConstLift_comp]
-----++++-
-----++++-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
-----++++-theorem fiberConst_eq_range_pullback_of_surjective
-----++++-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
-----++++-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
-----++++-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
-----++++-    (range_pullback_subset_fiberConst φ)
-----++++-
-----++++-/-! ### §3: Density transport -/
-----++++-
-----++++-/-
-----++++-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
-----++++--/
-----++++-theorem closure_range_pullback_eq_fiberConst
-----++++-    (φ : C(X, Y))
-----++++-    (A : Subalgebra ℝ C(Y, ℝ))
-----++++-    (hA : Dense (A : Set C(Y, ℝ))) :
-----++++-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
-----++++-      = (FiberConst φ : Set C(X, ℝ)) := by
-----++++-  refine' le_antisymm ( closure_minimal _ _ ) _;
-----++++-  · exact range_comp_subalgebra_subset_fiberConst φ A;
-----++++-  · exact fiberConst_closed φ;
-----++++-  · intro g hg;
-----++++-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
-----++++-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
-----++++-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
-----++++-    rw [ Metric.mem_closure_iff ];
-----++++-    intro ε εpos;
-----++++-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
-----++++-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
-----++++-    nontriviality;
-----++++-    rw [ hF, dist_eq_norm ] at *;
-----++++-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
-----++++-
-----++++-/-
-----++++-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
-----++++--/
-----++++-theorem closure_range_pullback_eq_top_of_injective
-----++++-    (φ : C(X, Y))
-----++++-    (hφ : Function.Injective φ)
-----++++-    (A : Subalgebra ℝ C(Y, ℝ))
-----++++-    (hA : Dense (A : Set C(Y, ℝ))) :
-----++++-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
-----++++-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
-----++++-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
-----++++-
-----++++-/-! ### §4: ε-approximation -/
-----++++-
-----++++-/-
-----++++-ε-approximation within `FiberConst φ`.
-----++++--/
-----++++-theorem exists_pullback_approx_of_fiberConst
-----++++-    (φ : C(X, Y))
-----++++-    (A : Subalgebra ℝ C(Y, ℝ))
-----++++-    (hA : Dense (A : Set C(Y, ℝ)))
-----++++-    (g : C(X, ℝ))
-----++++-    (hg : g ∈ FiberConst φ)
-----++++-    {ε : ℝ} (hε : 0 < ε) :
-----++++-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----++++-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
-----++++-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
-----++++-  rw [ Metric.mem_closure_iff ] at h_closure;
-----++++-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
-----++++-
-----++++-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
-----++++-theorem exists_pullback_approx_of_injective
-----++++-    (φ : C(X, Y))
-----++++-    (hφ : Function.Injective φ)
-----++++-    (A : Subalgebra ℝ C(Y, ℝ))
-----++++-    (hA : Dense (A : Set C(Y, ℝ)))
-----++++-    (g : C(X, ℝ))
-----++++-    {ε : ℝ} (hε : 0 < ε) :
-----++++-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----++++-  exact exists_pullback_approx_of_fiberConst φ A hA g
-----++++-    (mem_fiberConst_of_injective φ hφ g) hε+end++-+-+-/-- When `φ` is surjective, pullback is an isometry. -/
----++-+-+-theorem pullback_isometry_of_surjective
----++-+-+-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
----++-+-+-    ‖pullbackAlg φ f‖ = ‖f‖ := by
----++-+-+-  refine le_antisymm (norm_pullback_le φ f) ?_
----++-+-+-  rw [ContinuousMap.norm_le _ (by positivity)]
----++-+-+-  intro y; obtain ⟨x, rfl⟩ := hφ y
----++-+-+-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
----++-+-++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
----++-+-++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
----++-+-++  unfold logisticSigmoid
----++-+-++  rw [Real.exp_neg]
----++-+-++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
----++-+-++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
----++-+-++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----++-+-++  field_simp; ring
----++-+-+ 
----++-+-+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----++-+-+-theorem mem_fiberConst_of_injective
----++-+-+-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
----++-+-+-    g ∈ FiberConst φ := by
----++-+-+-  intro x x' h; exact congrArg g (hφ h)
----++-+-++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
----++-+-++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
----++-+-++  unfold softplus logisticSigmoid
----++-+-++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
----++-+-++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
----++-+-++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
----++-+-++  simp at this
----++-+-++  exact this
----++-+-+ 
----++-+-+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----++-+-+-theorem fiberConst_eq_top_of_injective
----++-+-+-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
----++-+-+-    FiberConst φ = ⊤ := by
----++-+-+-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
----++-+-++/-- ShefferAlg is closed under affine pre-composition. -/
----++-+-++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
----++-+-++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
----++-+-++  obtain ⟨e, rfl⟩ := hf
----++-+-++  exact ⟨.affinePrecomp a b e, rfl⟩
----++-+-+ 
----++-+-+-omit [CompactSpace Y] [T2Space Y] in
----++-+-+-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
----++-+-+-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
----++-+-+-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
----++-+-+-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
----++-+-+-  intro x x' hφ; by_contra h_ne
----++-+-+-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
----++-+-+-    have := exists_continuous_zero_one_of_isClosed
----++-+-+-      (show IsClosed {x} from isClosed_singleton)
----++-+-+-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
----++-+-+-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
----++-+-+-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
----++-+-+-  replace h := SetLike.ext_iff.mp h g
----++-+-+-  simp_all +decide [FiberConst]
----++-+-+-  exact absurd (h hφ) (by simp +decide [hg])
----++-+-++/-- ShefferAlg is closed under affine combination. -/
----++-+-++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
----++-+-++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
----++-+-++  obtain ⟨ef, rfl⟩ := hf
----++-+-++  obtain ⟨eg, rfl⟩ := hg
----++-+-++  exact ⟨.affineComb α β γ ef eg, rfl⟩
----++-+-+ 
----++-+-+-/-! ### §2: Image factorization -/
----++-+-++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
----++-+-++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
----++-+-++  unfold softplus
----++-+-++  rw [Real.exp_neg]
----++-+-++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
----++-+-++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----++-+-++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
----++-+-++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
----++-+-++  rw [this, Real.log_exp]
----++-+-+ 
----++-+-+-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
----++-+-+-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
----++-+-+-
----++-+-+-/-
----++-+-+-The corestriction `X → Set.range φ` is a quotient map.
----++-+-+--/
----++-+-+-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
----++-+-+-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
----++-+-+-  apply IsClosedMap.isQuotientMap;
----++-+-+-  · intro s hs;
----++-+-+-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
----++-+-+-    constructor <;> intro h;
----++-+-+-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
----++-+-+-    · convert h.preimage ( continuous_subtype_val ) using 1;
----++-+-+-      ext; simp [Set.rangeFactorization];
----++-+-+-      grind;
----++-+-+-  · exact continuous_induced_rng.mpr φ.continuous;
----++-+-+-  · exact Set.rangeFactorization_surjective
----++-+-+-
----++-+-+-/-- Lift a fiber-constant function to `Set.range φ`. -/
----++-+-+-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
----++-+-+-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
----++-+-+-  toFun z := g z.property.choose
----++-+-+-  continuous_toFun := by
----++-+-+-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
----++-+-+-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
----++-+-+-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
----++-+-+-      ext x; apply hg
----++-+-+-      exact (Set.rangeFactorization φ x).property.choose_spec
----++-+-+-    rw [this]; exact g.continuous
----++-+-+-
----++-+-+-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
----++-+-+-    (hg : g ∈ FiberConst φ) (x : X) :
----++-+-+-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
----++-+-+-  simp only [fiberConstLift]
----++-+-+-  apply hg
----++-+-+-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
----++-+-+-
----++-+-+-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
----++-+-+-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
----++-+-+-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
----++-+-+-  intro g hg
----++-+-+-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
----++-+-+-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
----++-+-+-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
----++-+-+-  refine ⟨F, ?_⟩
----++-+-+-  ext x
----++-+-+-  simp only [pullbackAlg_apply]
----++-+-+-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
----++-+-+-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
----++-+-+-    simp [ContinuousMap.comp_apply] at this; exact this
----++-+-+-  rw [key, fiberConstLift_comp]
----++-+-+-
----++-+-+-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
----++-+-+-theorem fiberConst_eq_range_pullback_of_surjective
----++-+-+-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
----++-+-+-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
----++-+-+-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
----++-+-+-    (range_pullback_subset_fiberConst φ)
----++-+-+-
----++-+-+-/-! ### §3: Density transport -/
----++-+-+-
----++-+-+-/-
----++-+-+-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
----++-+-+--/
----++-+-+-theorem closure_range_pullback_eq_fiberConst
----++-+-+-    (φ : C(X, Y))
----++-+-+-    (A : Subalgebra ℝ C(Y, ℝ))
----++-+-+-    (hA : Dense (A : Set C(Y, ℝ))) :
----++-+-+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
----++-+-+-      = (FiberConst φ : Set C(X, ℝ)) := by
----++-+-+-  refine' le_antisymm ( closure_minimal _ _ ) _;
----++-+-+-  · exact range_comp_subalgebra_subset_fiberConst φ A;
----++-+-+-  · exact fiberConst_closed φ;
----++-+-+-  · intro g hg;
----++-+-+-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
----++-+-+-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
----++-+-+-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
----++-+-+-    rw [ Metric.mem_closure_iff ];
----++-+-+-    intro ε εpos;
----++-+-+-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
----++-+-+-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
----++-+-+-    nontriviality;
----++-+-+-    rw [ hF, dist_eq_norm ] at *;
----++-+-+-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
----++-+-+-
----++-+-+-/-
----++-+-+-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
----++-+-+--/
----++-+-+-theorem closure_range_pullback_eq_top_of_injective
----++-+-+-    (φ : C(X, Y))
----++-+-+-    (hφ : Function.Injective φ)
----++-+-+-    (A : Subalgebra ℝ C(Y, ℝ))
----++-+-+-    (hA : Dense (A : Set C(Y, ℝ))) :
----++-+-+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
----++-+-+-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
----++-+-+-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
----++-+-+-
----++-+-+-/-! ### §4: ε-approximation -/
----++-+-+-
----++-+-+-/-
----++-+-+-ε-approximation within `FiberConst φ`.
----++-+-+--/
----++-+-+-theorem exists_pullback_approx_of_fiberConst
----++-+-+-    (φ : C(X, Y))
----++-+-+-    (A : Subalgebra ℝ C(Y, ℝ))
----++-+-+-    (hA : Dense (A : Set C(Y, ℝ)))
----++-+-+-    (g : C(X, ℝ))
----++-+-+-    (hg : g ∈ FiberConst φ)
----++-+-+-    {ε : ℝ} (hε : 0 < ε) :
----++-+-+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----++-+-+-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
----++-+-+-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
----++-+-+-  rw [ Metric.mem_closure_iff ] at h_closure;
----++-+-+-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
----++-+-+-
----++-+-+-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
----++-+-+-theorem exists_pullback_approx_of_injective
----++-+-+-    (φ : C(X, Y))
----++-+-+-    (hφ : Function.Injective φ)
----++-+-+-    (A : Subalgebra ℝ C(Y, ℝ))
----++-+-+-    (hA : Dense (A : Set C(Y, ℝ)))
----++-+-+-    (g : C(X, ℝ))
----++-+-+-    {ε : ℝ} (hε : 0 < ε) :
----++-+-+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----++-+-+-  exact exists_pullback_approx_of_fiberConst φ A hA g
----++-+-+-    (mem_fiberConst_of_injective φ hφ g) hε+end+--- a/EML/Basic.lean
----++-+++++ b/EML/Basic.lean
----++-++@@ -1,277 +1,125 @@
----++-++-/-
----++-++-Copyright (c) 2026 Harmonic. All rights reserved.
----++-++-Released under Apache 2.0 license as described in the file LICENSE.
----++-++--/
----++-++ import Mathlib
----++-++ 
----++-++-/-!
----++-++-# Pullback Stability of Universal Approximation
----++-+++/-! # CatalogBuild.EML.Basic
----++-++ 
----++-++-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
----++-++-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
----++-++-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
----++-++-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
----++-++-
----++-++-This establishes a transport principle: universal approximation results (like
----++-++-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
----++-++-with the precise target being the fiber-constant functions.
----++-++-
----++-++-## Main definitions
----++-++-
----++-++-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
----++-++-  fibers of `φ`.
----++-++-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
----++-++-
----++-++-## Main results
----++-++-
----++-++-### Basic properties (§1)
----++-++-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
----++-++-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
----++-++-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
----++-++-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
----++-++-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
----++-++-
----++-++-### Factorization (§2)
----++-++-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
----++-++-  through `Set.range φ`, hence is a pullback (via Tietze extension).
----++-++-
----++-++-### Density transport (§3)
----++-++-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
----++-++-  subalgebra equals `FiberConst φ`.
----++-++-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
----++-++-
----++-++-### ε-approximation (§4)
----++-++-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
----++-++-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
----++-+++Auto-generated from theorem catalog database.
----++-+++Domain: EML
----++-+++Declarations: 15
----++- + -/
----++- + 
----+++--- a/Tropical/Basic.lean
----++++++ b/Tropical/Basic.lean
----+++@@ -1,1315 +1,383 @@
----+++---- a/Tropical/Basic.lean
----+++-+++ b/Tropical/Basic.lean
----+++-@@ -1,930 +1,383 @@
----+++----- a/Tropical/Basic.lean
----+++--+++ b/Tropical/Basic.lean
----+++--@@ -1,545 +1,383 @@
----+++------ a/Tropical/Basic.lean
----+++---+++ b/Tropical/Basic.lean
----+++---@@ -1,383 +1,160 @@
----+++------- a/EML/Basic.lean
----+++----+++ b/EML/Basic.lean
----+++----@@ -1,277 +1,125 @@
----+++-----/-
----+++-----Copyright (c) 2026 Harmonic. All rights reserved.
----+++-----Released under Apache 2.0 license as described in the file LICENSE.
----+++------/
----+++---- import Mathlib
----+++---- 
----+++-----/-!
----+++-----# Pullback Stability of Universal Approximation
----+++----+/-! # CatalogBuild.EML.Basic
----+++---- 
----+++-----Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
----+++-----subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
----+++-----closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
----+++-----When `φ` is injective, this gives density in all of `C(X, ℝ)`.
----+++-----
----+++-----This establishes a transport principle: universal approximation results (like
----+++-----Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
----+++-----with the precise target being the fiber-constant functions.
----+++-----
----+++-----## Main definitions
----+++-----
----+++-----* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
----+++-----  fibers of `φ`.
----+++-----* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
----+++-----
----+++-----## Main results
----+++-----
----+++-----### Basic properties (§1)
----+++-----* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
----+++-----* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
----+++-----* `norm_pullback_le` — the pullback map is norm-nonincreasing.
----+++-----* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
----+++-----* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
----+++-----
----+++-----### Factorization (§2)
----+++-----* `fiberConst_subset_range_pullback` — every fiber-constant function factors
----+++-----  through `Set.range φ`, hence is a pullback (via Tietze extension).
----+++-----
----+++-----### Density transport (§3)
----+++-----* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
----+++-----  subalgebra equals `FiberConst φ`.
----+++-----* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
----+++-----
----+++-----### ε-approximation (§4)
----+++-----* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
----+++-----* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
----+++----+Auto-generated from theorem catalog database.
----+++----+Domain: EML
----+++----+Declarations: 15
----+++---- -/
----+++---- 
----+++-----open scoped Topology
----+++-----open Topology
----+++----+noncomputable section
----+++---- 
----+++-----variable {X Y : Type*}
----+++-----variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
----+++-----variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
----+++----+/-- The inverse for hyperbolic SPB is also negation. -/
----+++----+theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
----+++----+  simp [spbH]
----+++---- 
----+++-----/-! ### §1: Definitions and basic properties -/
----+++----+/-- Wick duality: SPB with negated second argument equals the "difference"
----+++----+in the hyperbolic SPB. This is the real-variable manifestation of the
----+++----+Wick rotation t → it. -/
----+++----+theorem wick_duality (x y : ℝ) :
----+++----+    spb x (-y) = (x - y) / (1 + x * y) := by
----+++----+  simp only [spb]
----+++----+  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
----+++----+  rw [heq]; ring
----+++---- 
----+++-----/-- Continuous functions on `X` that are constant on fibers of `φ`.
----+++-----This is the natural functional-analytic object associated to a feature map:
----+++-----it captures exactly the observables visible through `φ`. -/
----+++-----def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
----+++-----  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
----+++-----  algebraMap_mem' r := by intro x x' _; simp
----+++-----  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----+++-----  zero_mem' := by intro x x' _; simp
----+++-----  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----+++-----  one_mem' := by intro x x' _; simp
----+++----+/-- The tangent addition law IS the stereographic sum.
----+++----+tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
----+++----+theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
----+++----+    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
----+++----+  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
----+++----+      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
----+++----+  field_simp
----+++---- 
----+++-----/-- Pullback of continuous real-valued functions along `φ`. -/
----+++-----def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
----+++-----  toFun f := f.comp φ
----+++-----  map_zero' := by ext; simp
----+++-----  map_one' := by ext; simp
----+++-----  map_add' := by intros; ext; simp
----+++-----  map_mul' := by intros; ext; simp
----+++-----  commutes' := by intros; ext; simp
----+++----+/-- SPB expression trees — analogous to EML expression trees. -/
----+++----+inductive SPBExpr where
----+++----+  | zero : SPBExpr
----+++----+  | one : SPBExpr
----+++----+  | var : ℕ → SPBExpr
----+++----+  | node : SPBExpr → SPBExpr → SPBExpr
----+++----+  deriving Repr, BEq
----+++---- 
----+++-----@[simp]
----+++-----theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
----+++-----    pullbackAlg φ f x = f (φ x) := rfl
----+++----+/-- Evaluate an SPB expression. -/
----+++----+def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
----+++----+  match e with
----+++----+  | .zero => 0
----+++----+  | .one => 1
----+++----+  | .var n => vars n
----+++----+  | .node l r => spb (l.eval vars) (r.eval vars)
----+++---- 
----+++-----theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
----+++-----    pullbackAlg φ f ∈ FiberConst φ := by
----+++-----  intro x x' h; simp [h]
----+++----+/-- Depth of an SPB expression. -/
----+++----+def SPBExpr.depth : SPBExpr → ℕ
----+++----+  | .zero => 0
----+++----+  | .one => 0
----+++----+  | .var _ => 0
----+++----+  | .node l r => 1 + max l.depth r.depth
----+++---- 
----+++-----theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
----+++-----    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----+++-----  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
----+++----+/-- Leaf count. -/
----+++----+def SPBExpr.leafCount : SPBExpr → ℕ
----+++----+  | .zero => 1
----+++----+  | .one => 1
----+++----+  | .var _ => 1
----+++----+  | .node l r => l.leafCount + r.leafCount
----+++---- 
----+++-----theorem range_comp_subalgebra_subset_fiberConst
----+++-----    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
----+++-----    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----+++-----  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
----+++----+/-- Internal node count. -/
----+++----+def SPBExpr.nodeCount : SPBExpr → ℕ
----+++----+  | .zero => 0
----+++----+  | .one => 0
----+++----+  | .var _ => 0
----+++----+  | .node l r => 1 + l.nodeCount + r.nodeCount
----+++---- 
----+++-----/-- `FiberConst φ` is closed in the uniform topology. -/
----+++-----theorem fiberConst_closed (φ : C(X, Y)) :
----+++-----    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
----+++-----  refine isClosed_of_closure_subset ?_
----+++-----  intro g hg x x' h
----+++-----  rw [mem_closure_iff_nhds] at hg
----+++-----  contrapose! hg
----+++-----  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
----+++-----    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
----+++-----    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
----+++----+/-- Binary tree identity: leaves = internal nodes + 1. -/
----+++----+theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
----+++----+    e.leafCount = e.nodeCount + 1 := by
----+++----+  induction e with
----+++----+  | zero => rfl
----+++----+  | one => rfl
----+++----+  | var _ => rfl
----+++----+  | node l r ihl ihr =>
----+++----+    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
----+++----+    omega
----+++---- 
----+++-----omit [T2Space X] [T2Space Y] in
----+++-----/-- The pullback map is norm-nonincreasing. -/
----+++-----theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
----+++-----    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
----+++-----  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
----+++-----    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
----+++----+/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
----+++----+def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
----+++---- 
----+++-----/-- When `φ` is surjective, pullback is an isometry. -/
----+++-----theorem pullback_isometry_of_surjective
----+++-----    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
----+++-----    ‖pullbackAlg φ f‖ = ‖f‖ := by
----+++-----  refine le_antisymm (norm_pullback_le φ f) ?_
----+++-----  rw [ContinuousMap.norm_le _ (by positivity)]
----+++-----  intro y; obtain ⟨x, rfl⟩ := hφ y
----+++-----  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
----+++----+/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
----+++----+theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
----+++----+  unfold logisticSigmoid
----+++----+  rw [Real.exp_neg]
----+++----+  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
----+++----+  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
----+++----+  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----+++----+  field_simp; ring
----+++---- 
----+++-----omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----+++-----theorem mem_fiberConst_of_injective
----+++-----    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
----+++-----    g ∈ FiberConst φ := by
----+++-----  intro x x' h; exact congrArg g (hφ h)
----+++----+/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
----+++----+theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
----+++----+  unfold softplus logisticSigmoid
----+++----+  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
----+++----+  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
----+++----+  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
----+++----+  simp at this
----+++----+  exact this
----+++---- 
----+++-----omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----+++-----theorem fiberConst_eq_top_of_injective
----+++-----    (φ : C(X, Y)) (hφ : Function.Injective φ) :
----+++-----    FiberConst φ = ⊤ := by
----+++-----  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
----+++----+/-- ShefferAlg is closed under affine pre-composition. -/
----+++----+theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
----+++----+    (fun x => f (a * x + b)) ∈ ShefferAlg := by
----+++----+  obtain ⟨e, rfl⟩ := hf
----+++----+  exact ⟨.affinePrecomp a b e, rfl⟩
----+++---- 
----+++-----omit [CompactSpace Y] [T2Space Y] in
----+++-----/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
----+++-----theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
----+++-----    FiberConst φ = ⊤ ↔ Function.Injective φ := by
----+++-----  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
----+++-----  intro x x' hφ; by_contra h_ne
----+++-----  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
----+++-----    have := exists_continuous_zero_one_of_isClosed
----+++-----      (show IsClosed {x} from isClosed_singleton)
----+++-----      (show IsClosed {x'} from isClosed_singleton) (by aesop)
----+++-----    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
----+++-----      this.choose_spec.2.1 (Set.mem_singleton x')⟩
----+++-----  replace h := SetLike.ext_iff.mp h g
----+++-----  simp_all +decide [FiberConst]
----+++-----  exact absurd (h hφ) (by simp +decide [hg])
----+++----+/-- ShefferAlg is closed under affine combination. -/
----+++----+theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
----+++----+    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
----+++----+  obtain ⟨ef, rfl⟩ := hf
----+++----+  obtain ⟨eg, rfl⟩ := hg
----+++----+  exact ⟨.affineComb α β γ ef eg, rfl⟩
----+++---- 
----+++-----/-! ### §2: Image factorization -/
----+++----+/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
----+++----+theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
----+++----+  unfold softplus
----+++----+  rw [Real.exp_neg]
----+++----+  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
----+++----+  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----+++----+  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
----+++----+  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
----+++----+  rw [this, Real.log_exp]
----+++---- 
----+++-----instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
----+++-----  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
----+++-----
----+++-----/-
----+++-----The corestriction `X → Set.range φ` is a quotient map.
----+++------/
----+++-----theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
----+++-----    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
----+++-----  apply IsClosedMap.isQuotientMap;
----+++-----  · intro s hs;
----+++-----    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
----+++-----    constructor <;> intro h;
----+++-----    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
----+++-----    · convert h.preimage ( continuous_subtype_val ) using 1;
----+++-----      ext; simp [Set.rangeFactorization];
----+++-----      grind;
----+++-----  · exact continuous_induced_rng.mpr φ.continuous;
----+++-----  · exact Set.rangeFactorization_surjective
----+++-----
----+++-----/-- Lift a fiber-constant function to `Set.range φ`. -/
----+++-----noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
----+++-----    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
----+++-----  toFun z := g z.property.choose
----+++-----  continuous_toFun := by
----+++-----    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
----+++-----    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
----+++-----    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
----+++-----      ext x; apply hg
----+++-----      exact (Set.rangeFactorization φ x).property.choose_spec
----+++-----    rw [this]; exact g.continuous
----+++-----
----+++-----theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
----+++-----    (hg : g ∈ FiberConst φ) (x : X) :
----+++-----    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
----+++-----  simp only [fiberConstLift]
----+++-----  apply hg
----+++-----  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
----+++-----
----+++-----/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
----+++-----theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
----+++-----    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
----+++-----  intro g hg
----+++-----  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
----+++-----  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
----+++-----    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
----+++-----  refine ⟨F, ?_⟩
----+++-----  ext x
----+++-----  simp only [pullbackAlg_apply]
----+++-----  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
----+++-----    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
----+++-----    simp [ContinuousMap.comp_apply] at this; exact this
----+++-----  rw [key, fiberConstLift_comp]
----+++-----
----+++-----/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
----+++-----theorem fiberConst_eq_range_pullback_of_surjective
----+++-----    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
----+++-----    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
----+++-----  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
----+++-----    (range_pullback_subset_fiberConst φ)
----+++-----
----+++-----/-! ### §3: Density transport -/
----+++-----
----+++-----/-
----+++-----The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
----+++------/
----+++-----theorem closure_range_pullback_eq_fiberConst
----+++-----    (φ : C(X, Y))
----+++-----    (A : Subalgebra ℝ C(Y, ℝ))
----+++-----    (hA : Dense (A : Set C(Y, ℝ))) :
----+++-----    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
----+++-----      = (FiberConst φ : Set C(X, ℝ)) := by
----+++-----  refine' le_antisymm ( closure_minimal _ _ ) _;
----+++-----  · exact range_comp_subalgebra_subset_fiberConst φ A;
----+++-----  · exact fiberConst_closed φ;
----+++-----  · intro g hg;
----+++-----    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
----+++-----    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
----+++-----      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
----+++-----    rw [ Metric.mem_closure_iff ];
----+++-----    intro ε εpos;
----+++-----    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
----+++-----    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
----+++-----    nontriviality;
----+++-----    rw [ hF, dist_eq_norm ] at *;
----+++-----    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
----+++-----
----+++-----/-
----+++-----Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
----+++------/
----+++-----theorem closure_range_pullback_eq_top_of_injective
----+++-----    (φ : C(X, Y))
----+++-----    (hφ : Function.Injective φ)
----+++-----    (A : Subalgebra ℝ C(Y, ℝ))
----+++-----    (hA : Dense (A : Set C(Y, ℝ))) :
----+++-----    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
----+++-----  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
----+++-----  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
----+++-----
----+++-----/-! ### §4: ε-approximation -/
----+++-----
----+++-----/-
----+++-----ε-approximation within `FiberConst φ`.
----+++------/
----+++-----theorem exists_pullback_approx_of_fiberConst
----+++-----    (φ : C(X, Y))
----+++-----    (A : Subalgebra ℝ C(Y, ℝ))
----+++-----    (hA : Dense (A : Set C(Y, ℝ)))
----+++-----    (g : C(X, ℝ))
----+++-----    (hg : g ∈ FiberConst φ)
----+++-----    {ε : ℝ} (hε : 0 < ε) :
----+++-----    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----+++-----  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
----+++-----    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
----+++-----  rw [ Metric.mem_closure_iff ] at h_closure;
----+++-----  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
----+++-----
----+++-----/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
----+++-----theorem exists_pullback_approx_of_injective
----+++-----    (φ : C(X, Y))
----+++-----    (hφ : Function.Injective φ)
----+++-----    (A : Subalgebra ℝ C(Y, ℝ))
----+++-----    (hA : Dense (A : Set C(Y, ℝ)))
----+++-----    (g : C(X, ℝ))
----+++-----    {ε : ℝ} (hε : 0 < ε) :
----+++-----    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----+++-----  exact exists_pullback_approx_of_fiberConst φ A hA g
----+++-----    (mem_fiberConst_of_injective φ hφ g) hε+end+/-
----+++---+Copyright (c) 2025. All rights reserved.
----+++---+Released under Apache 2.0 license as described in the file LICENSE.
----+++---+-/
----+++---+import Mathlib
----+++---+
----+++---+/-!
----+++---+# GL₃ Tropical Satake: Core Definitions
----+++---+
----+++---+This file establishes the foundational types and operations for the GL₃ tropical
----+++---+Satake finite-determinacy theory.
----+++---+
----+++---+## Overview
----+++---+
----+++---+For GL₃, a **dominant coweight** is a triple `(a, b, c) ∈ ℕ³` with `a ≥ b ≥ c`.
----+++---+The **dominant box** `BoxDom(B)` is the finite set of dominant coweights with `a ≤ B`.
----+++---+
----+++---+We define three families of **tropical Satake observables**, corresponding to the
----+++---+three fundamental representations `ω₁, ω₂, ω₃` of GL₃:
----+++---+
----+++---+1. **Rank-1 profile** (`rank1Profile`): tropical convolution with the standard
----+++---+   representation character. Uses the weights `e₁, e₂, e₃`.
----+++---+2. **Rank-2 profile** (`rank2Profile`): tropical convolution with the exterior square
----+++---+   character. Uses the weights `e₁+e₂, e₁+e₃, e₂+e₃`.
----+++---+3. **Edge moment** (`edgeMoment`): tropical convolution with the determinant character
----+++---+   `ω₃ = (1,1,1)`. This is the key reconstruction tool: as a shift operator, it
----+++---+   recovers function values without the information loss inherent in max operations.
----+++---+
----+++---+The finite-determinacy theorem (proved in `FiniteDeterminacy.lean`) shows that
----+++---+equality of these observables on finite test sets forces equality of the underlying
----+++---+functions.
----+++---+-/
----+++---+
----+++---+open Finset
----+++---+
----+++---+/-! ### Dominance and support conditions -/
----+++---+
----+++---+/-- A triple `(a, b, c)` is dominant if `a ≥ b ≥ c`. -/
----+++---+def IsDominant (a b c : ℕ) : Prop := b ≤ a ∧ c ≤ b
----+++---+
----+++---+/-- A function on `ℕ³` has finite support within box `B` if it vanishes outside
----+++---+    the dominant box `{(a,b,c) : b ≤ a, c ≤ b, a ≤ B}`. -/
----+++---+def FiniteSupportWithin (B : ℕ) (f : ℕ → ℕ → ℕ → ℤ) : Prop :=
----+++---+  ∀ a b c : ℕ, (B < a ∨ a < b ∨ b < c) → f a b c = 0
----+++---+
----+++---+/-- The box `BoxDom(B)` as a `Finset` of triples. -/
----+++---+def boxDomFinset (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
----+++---+  (Finset.range (B + 1) ×ˢ Finset.range (B + 1) ×ˢ Finset.range (B + 1)).filter
----+++---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
----+++---+
----+++---+lemma mem_boxDomFinset {B : ℕ} {a b c : ℕ} :
----+++---+    (a, b, c) ∈ boxDomFinset B ↔ a ≤ B ∧ b ≤ a ∧ c ≤ b := by
----+++---+  simp [boxDomFinset, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
----+++---+  omega
----+++---+
----+++---+/-! ### Tropical Satake observables -/
----+++---+
----+++---+/-- **Rank-1 profile**: tropical convolution with the standard representation `ω₁`.
----+++---+
----+++---+The weights of the standard representation of GL₃ are `e₁ = (1,0,0)`,
----+++---+`e₂ = (0,1,0)`, `e₃ = (0,0,1)`. The rank-1 profile at `(a,b,c)` is
----+++---+`max{f(a-1,b,c), f(a,b-1,c), f(a,b,c-1)}` with appropriate guards for ℕ subtraction.
----+++---+
----+++---+Note: Invalid shifts (where subtraction would go below 0) contribute the value `0`,
----+++---+which serves as the tropical "zero" in this ℤ-valued model. -/
----+++---+def rank1Profile (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
----+++---+  let v1 := if 1 ≤ a then f (a - 1) b c else 0
----+++---+  let v2 := if 1 ≤ b then f a (b - 1) c else 0
----+++---+  let v3 := if 1 ≤ c then f a b (c - 1) else 0
----+++---+  max v1 (max v2 v3)
----+++---+
----+++---+/-- **Rank-2 profile**: tropical convolution with the exterior square `ω₂ = ∧²`.
----+++---+
----+++---+The weights of `∧²(ℂ³)` are `e₁+e₂ = (1,1,0)`, `e₁+e₃ = (1,0,1)`,
----+++---+`e₂+e₃ = (0,1,1)`. The rank-2 profile at `(a,b,c)` is
----+++---+`max{f(a-1,b-1,c), f(a-1,b,c-1), f(a,b-1,c-1)}`. -/
----+++---+def rank2Profile (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
----+++---+  let v1 := if 1 ≤ a ∧ 1 ≤ b then f (a - 1) (b - 1) c else 0
----+++---+  let v2 := if 1 ≤ a ∧ 1 ≤ c then f (a - 1) b (c - 1) else 0
----+++---+  let v3 := if 1 ≤ b ∧ 1 ≤ c then f a (b - 1) (c - 1) else 0
----+++---+  max v1 (max v2 v3)
----+++---+
----+++---+/-- **Edge moment**: tropical convolution with the determinant character `ω₃ = (1,1,1)`.
----+++---+
----+++---+This is the shift operator: `edgeMoment f (a,b,c) = f(a-1, b-1, c-1)`.
----+++---+As a representation-theoretic operation, it corresponds to convolution with the
----+++---+one-dimensional determinant representation `det = ∧³(ℂ³)`. Unlike the rank-1 and
----+++---+rank-2 profiles (which use `max` and can lose information), the determinant
----+++---+convolution perfectly preserves all function values.
----+++---+
----+++---+This is the key observable that makes finite determinacy possible: it acts as an
----+++---+exact reconstruction tool rather than a lossy tropical projection. -/
----+++---+def edgeMoment (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
----+++---+  if 1 ≤ a ∧ 1 ≤ b ∧ 1 ≤ c then f (a - 1) (b - 1) (c - 1) else 0
----+++---+
----+++---+/-- Combined triple convolution observable using both rank-1 and rank-2 generators.
----+++---+    This packages rank-1 and rank-2 data together for the combined hypothesis form. -/
----+++---+def tripleConvObservable (f : ℕ → ℕ → ℕ → ℤ) (t s : ℕ × ℕ × ℕ) : ℤ :=
----+++---+  rank1Profile f t.1 t.2.1 t.2.2 + rank2Profile f s.1 s.2.1 s.2.2
----+++---+
----+++---+/-! ### Finite test ranges -/
----+++---+
----+++---+/-- The finite range of rank-1 test parameters determined by box bound `B`. -/
----+++---+def finiteRank1Range (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
----+++---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
----+++---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
----+++---+
----+++---+/-- The finite range of rank-2 test parameters determined by box bound `B`. -/
----+++---+def finiteRank2Range (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
----+++---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
----+++---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
----+++---+
----+++---+/-- The finite range of edge moment test parameters determined by box bound `B`.
----+++---+    These are the shifted dominant coweights `(a+1, b+1, c+1)` for `(a,b,c) ∈ BoxDom(B)`. -/
----+++---+def finiteEdgeMomentRange (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
----+++---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
----+++---+    fun ⟨a, b, c⟩ => 1 ≤ c ∧ c ≤ b ∧ b ≤ a
----+++---+
----+++---+/-! ### Key computation lemmas -/
----+++---+
----+++---+/-- The edge moment at a shifted point exactly recovers the function value.
----+++---+    This is the fundamental reconstruction identity. -/
----+++---+@[simp]
----+++---+lemma edgeMoment_succ (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) :
----+++---+    edgeMoment f (a + 1) (b + 1) (c + 1) = f a b c := by
----+++---+  simp [edgeMoment]
----+++---+
----+++---+/-- Shifted dominant coweights lie in the edge moment range. -/
----+++---+lemma shifted_mem_finiteEdgeMomentRange {B a b c : ℕ}
----+++---+    (haB : a ≤ B) (hab : b ≤ a) (hbc : c ≤ b) :
----+++---+    (a + 1, b + 1, c + 1) ∈ finiteEdgeMomentRange B := by
----+++---+  simp [finiteEdgeMomentRange, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
----+++---+  omega
----+++---+
----+++---+/-- The rank-2 profile at the floor level `(a+1, b+1, 0)` yields `max(f(a,b,0), 0)`.
----+++---+    When `f` is nonneg-valued on the floor, this equals `f(a,b,0)`.
----+++---+    The `c = 0` case is special because both `ω₂`-weight shifts involving `c-1`
----+++---+    fall outside `ℕ`, leaving only the `(1,1,0)`-weight shift. -/
----+++---+lemma rank2Profile_floor_level (f : ℕ → ℕ → ℕ → ℤ) (a b : ℕ) :
----+++---+    rank2Profile f (a + 1) (b + 1) 0 = max (f a b 0) 0 := by
----+++---+  simp [rank2Profile]
----+++---+
----+++---+/-- For functions supported in `BoxDom(B)`, values at `a > B` vanish. -/
----+++---+lemma FiniteSupportWithin.vanish_above {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
----+++---+    (hf : FiniteSupportWithin B f) {a : ℕ} (ha : B < a) (b c : ℕ) :
----+++---+    f a b c = 0 := by
----+++---+  exact hf a b c (Or.inl ha)
----+++---+
----+++---+/-- For functions supported in `BoxDom(B)`, values outside dominant cone vanish. -/
----+++---+lemma FiniteSupportWithin.vanish_nondominant {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
----+++---+    (hf : FiniteSupportWithin B f) {a b c : ℕ} (h : a < b ∨ b < c) :
----+++---+    f a b c = 0 := by
----+++---+  exact hf a b c (by tauto)
----+++---+
----+++---+/-- Bounded-support functions vanish outside the box: explicit formulation. -/
----+++---+lemma bounded_support_implies_vanishing_outside {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
----+++---+    (hf : FiniteSupportWithin B f) {a b c : ℕ}
----+++---+    (h : ¬(a ≤ B ∧ b ≤ a ∧ c ≤ b)) :
----+++---+    f a b c = 0 := by
----+++---+  apply hf; push_neg at h; omega+--- a/EML/Basic.lean
----+++--++++ b/EML/Basic.lean
----+++--+@@ -1,277 +1,125 @@
----+++--+-/-
----+++--+-Copyright (c) 2026 Harmonic. All rights reserved.
----+++--+-Released under Apache 2.0 license as described in the file LICENSE.
----+++--+--/
----+++--+ import Mathlib
----+++--+ 
----+++--+-/-!
----+++--+-# Pullback Stability of Universal Approximation
----+++--++/-! # CatalogBuild.EML.Basic
----+++--+ 
----+++--+-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
----+++--+-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
----+++--+-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
----+++--+-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
----+++--+-
----+++--+-This establishes a transport principle: universal approximation results (like
----+++--+-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
----+++--+-with the precise target being the fiber-constant functions.
----+++--+-
----+++--+-## Main definitions
----+++--+-
----+++--+-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
----+++--+-  fibers of `φ`.
----+++--+-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
----+++--+-
----+++--+-## Main results
----+++--+-
----+++--+-### Basic properties (§1)
----+++--+-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
----+++--+-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
----+++--+-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
----+++--+-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
----+++--+-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
----+++--+-
----+++--+-### Factorization (§2)
----+++--+-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
----+++--+-  through `Set.range φ`, hence is a pullback (via Tietze extension).
----+++--+-
----+++--+-### Density transport (§3)
----+++--+-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
----+++--+-  subalgebra equals `FiberConst φ`.
----+++--+-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
----+++--+-
----+++--+-### ε-approximation (§4)
----+++--+-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
----+++--+-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
----+++--++Auto-generated from theorem catalog database.
----+++--++Domain: EML
----+++--++Declarations: 15
----+++--+ -/
----+++--+ 
----+++--+-open scoped Topology
----+++--+-open Topology
----+++--++noncomputable section
----+++--+ 
----+++--+-variable {X Y : Type*}
----+++--+-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
----+++--+-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
----+++--++/-- The inverse for hyperbolic SPB is also negation. -/
----+++--++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
----+++--++  simp [spbH]
----+++--+ 
----+++--+-/-! ### §1: Definitions and basic properties -/
----+++--++/-- Wick duality: SPB with negated second argument equals the "difference"
----+++--++in the hyperbolic SPB. This is the real-variable manifestation of the
----+++--++Wick rotation t → it. -/
----+++--++theorem wick_duality (x y : ℝ) :
----+++--++    spb x (-y) = (x - y) / (1 + x * y) := by
----+++--++  simp only [spb]
----+++--++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
----+++--++  rw [heq]; ring
----+++--+ 
----+++--+-/-- Continuous functions on `X` that are constant on fibers of `φ`.
----+++--+-This is the natural functional-analytic object associated to a feature map:
----+++--+-it captures exactly the observables visible through `φ`. -/
----+++--+-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
----+++--+-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
----+++--+-  algebraMap_mem' r := by intro x x' _; simp
----+++--+-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----+++--+-  zero_mem' := by intro x x' _; simp
----+++--+-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----+++--+-  one_mem' := by intro x x' _; simp
----+++--++/-- The tangent addition law IS the stereographic sum.
----+++--++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
----+++--++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
----+++--++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
----+++--++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
----+++--++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
----+++--++  field_simp
----+++--+ 
----+++--+-/-- Pullback of continuous real-valued functions along `φ`. -/
----+++--+-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
----+++--+-  toFun f := f.comp φ
----+++--+-  map_zero' := by ext; simp
----+++--+-  map_one' := by ext; simp
----+++--+-  map_add' := by intros; ext; simp
----+++--+-  map_mul' := by intros; ext; simp
----+++--+-  commutes' := by intros; ext; simp
----+++--++/-- SPB expression trees — analogous to EML expression trees. -/
----+++--++inductive SPBExpr where
----+++--++  | zero : SPBExpr
----+++--++  | one : SPBExpr
----+++--++  | var : ℕ → SPBExpr
----+++--++  | node : SPBExpr → SPBExpr → SPBExpr
----+++--++  deriving Repr, BEq
----+++--+ 
----+++--+-@[simp]
----+++--+-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
----+++--+-    pullbackAlg φ f x = f (φ x) := rfl
----+++--++/-- Evaluate an SPB expression. -/
----+++--++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
----+++--++  match e with
----+++--++  | .zero => 0
----+++--++  | .one => 1
----+++--++  | .var n => vars n
----+++--++  | .node l r => spb (l.eval vars) (r.eval vars)
----+++--+ 
----+++--+-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
----+++--+-    pullbackAlg φ f ∈ FiberConst φ := by
----+++--+-  intro x x' h; simp [h]
----+++--++/-- Depth of an SPB expression. -/
----+++--++def SPBExpr.depth : SPBExpr → ℕ
----+++--++  | .zero => 0
----+++--++  | .one => 0
----+++--++  | .var _ => 0
----+++--++  | .node l r => 1 + max l.depth r.depth
----+++--+ 
----+++--+-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
----+++--+-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----+++--+-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
----+++--++/-- Leaf count. -/
----+++--++def SPBExpr.leafCount : SPBExpr → ℕ
----+++--++  | .zero => 1
----+++--++  | .one => 1
----+++--++  | .var _ => 1
----+++--++  | .node l r => l.leafCount + r.leafCount
----+++--+ 
----+++--+-theorem range_comp_subalgebra_subset_fiberConst
----+++--+-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
----+++--+-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----+++--+-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
----+++--++/-- Internal node count. -/
----+++--++def SPBExpr.nodeCount : SPBExpr → ℕ
----+++--++  | .zero => 0
----+++--++  | .one => 0
----+++--++  | .var _ => 0
----+++--++  | .node l r => 1 + l.nodeCount + r.nodeCount
----+++--+ 
----+++--+-/-- `FiberConst φ` is closed in the uniform topology. -/
----+++--+-theorem fiberConst_closed (φ : C(X, Y)) :
----+++--+-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
----+++--+-  refine isClosed_of_closure_subset ?_
----+++--+-  intro g hg x x' h
----+++--+-  rw [mem_closure_iff_nhds] at hg
----+++--+-  contrapose! hg
----+++--+-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
----+++--+-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
----+++--+-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
----+++--++/-- Binary tree identity: leaves = internal nodes + 1. -/
----+++--++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
----+++--++    e.leafCount = e.nodeCount + 1 := by
----+++--++  induction e with
----+++--++  | zero => rfl
----+++--++  | one => rfl
----+++--++  | var _ => rfl
----+++--++  | node l r ihl ihr =>
----+++--++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
----+++--++    omega
----+++--+ 
----+++--+-omit [T2Space X] [T2Space Y] in
----+++--+-/-- The pullback map is norm-nonincreasing. -/
----+++--+-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
----+++--+-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
----+++--+-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
----+++--+-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
----+++--++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
----+++--++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
----+++--+ 
----+++--+-/-- When `φ` is surjective, pullback is an isometry. -/
----+++--+-theorem pullback_isometry_of_surjective
----+++--+-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
----+++--+-    ‖pullbackAlg φ f‖ = ‖f‖ := by
----+++--+-  refine le_antisymm (norm_pullback_le φ f) ?_
----+++--+-  rw [ContinuousMap.norm_le _ (by positivity)]
----+++--+-  intro y; obtain ⟨x, rfl⟩ := hφ y
----+++--+-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
----+++--++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
----+++--++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
----+++--++  unfold logisticSigmoid
----+++--++  rw [Real.exp_neg]
----+++--++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
----+++--++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
----+++--++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----+++--++  field_simp; ring
----+++--+ 
----+++--+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----+++--+-theorem mem_fiberConst_of_injective
----+++--+-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
----+++--+-    g ∈ FiberConst φ := by
----+++--+-  intro x x' h; exact congrArg g (hφ h)
----+++--++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
----+++--++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
----+++--++  unfold softplus logisticSigmoid
----+++--++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
----+++--++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
----+++--++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
----+++--++  simp at this
----+++--++  exact this
----+++--+ 
----+++--+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----+++--+-theorem fiberConst_eq_top_of_injective
----+++--+-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
----+++--+-    FiberConst φ = ⊤ := by
----+++--+-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
----+++--++/-- ShefferAlg is closed under affine pre-composition. -/
----+++--++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
----+++--++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
----+++--++  obtain ⟨e, rfl⟩ := hf
----+++--++  exact ⟨.affinePrecomp a b e, rfl⟩
----+++--+ 
----+++--+-omit [CompactSpace Y] [T2Space Y] in
----+++--+-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
----+++--+-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
----+++--+-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
----+++--+-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
----+++--+-  intro x x' hφ; by_contra h_ne
----+++--+-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
----+++--+-    have := exists_continuous_zero_one_of_isClosed
----+++--+-      (show IsClosed {x} from isClosed_singleton)
----+++--+-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
----+++--+-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
----+++--+-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
----+++--+-  replace h := SetLike.ext_iff.mp h g
----+++--+-  simp_all +decide [FiberConst]
----+++--+-  exact absurd (h hφ) (by simp +decide [hg])
----+++--++/-- ShefferAlg is closed under affine combination. -/
----+++--++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
----+++--++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
----+++--++  obtain ⟨ef, rfl⟩ := hf
----+++--++  obtain ⟨eg, rfl⟩ := hg
----+++--++  exact ⟨.affineComb α β γ ef eg, rfl⟩
----+++--+ 
----+++--+-/-! ### §2: Image factorization -/
----+++--++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
----+++--++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
----+++--++  unfold softplus
----+++--++  rw [Real.exp_neg]
----+++--++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
----+++--++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----+++--++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
----+++--++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
----+++--++  rw [this, Real.log_exp]
----+++--+ 
----+++--+-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
----+++--+-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
----+++--+-
----+++--+-/-
----+++--+-The corestriction `X → Set.range φ` is a quotient map.
----+++--+--/
----+++--+-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
----+++--+-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
----+++--+-  apply IsClosedMap.isQuotientMap;
----+++--+-  · intro s hs;
----+++--+-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
----+++--+-    constructor <;> intro h;
----+++--+-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
----+++--+-    · convert h.preimage ( continuous_subtype_val ) using 1;
----+++--+-      ext; simp [Set.rangeFactorization];
----+++--+-      grind;
----+++--+-  · exact continuous_induced_rng.mpr φ.continuous;
----+++--+-  · exact Set.rangeFactorization_surjective
----+++--+-
----+++--+-/-- Lift a fiber-constant function to `Set.range φ`. -/
----+++--+-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
----+++--+-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
----+++--+-  toFun z := g z.property.choose
----+++--+-  continuous_toFun := by
----+++--+-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
----+++--+-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
----+++--+-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
----+++--+-      ext x; apply hg
----+++--+-      exact (Set.rangeFactorization φ x).property.choose_spec
----+++--+-    rw [this]; exact g.continuous
----+++--+-
----+++--+-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
----+++--+-    (hg : g ∈ FiberConst φ) (x : X) :
----+++--+-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
----+++--+-  simp only [fiberConstLift]
----+++--+-  apply hg
----+++--+-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
----+++--+-
----+++--+-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
----+++--+-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
----+++--+-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
----+++--+-  intro g hg
----+++--+-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
----+++--+-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
----+++--+-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
----+++--+-  refine ⟨F, ?_⟩
----+++--+-  ext x
----+++--+-  simp only [pullbackAlg_apply]
----+++--+-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
----+++--+-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
----+++--+-    simp [ContinuousMap.comp_apply] at this; exact this
----+++--+-  rw [key, fiberConstLift_comp]
----+++--+-
----+++--+-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
----+++--+-theorem fiberConst_eq_range_pullback_of_surjective
----+++--+-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
----+++--+-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
----+++--+-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
----+++--+-    (range_pullback_subset_fiberConst φ)
----+++--+-
----+++--+-/-! ### §3: Density transport -/
----+++--+-
----+++--+-/-
----+++--+-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
----+++--+--/
----+++--+-theorem closure_range_pullback_eq_fiberConst
----+++--+-    (φ : C(X, Y))
----+++--+-    (A : Subalgebra ℝ C(Y, ℝ))
----+++--+-    (hA : Dense (A : Set C(Y, ℝ))) :
----+++--+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
----+++--+-      = (FiberConst φ : Set C(X, ℝ)) := by
----+++--+-  refine' le_antisymm ( closure_minimal _ _ ) _;
----+++--+-  · exact range_comp_subalgebra_subset_fiberConst φ A;
----+++--+-  · exact fiberConst_closed φ;
----+++--+-  · intro g hg;
----+++--+-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
----+++--+-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
----+++--+-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
----+++--+-    rw [ Metric.mem_closure_iff ];
----+++--+-    intro ε εpos;
----+++--+-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
----+++--+-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
----+++--+-    nontriviality;
----+++--+-    rw [ hF, dist_eq_norm ] at *;
----+++--+-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
----+++--+-
----+++--+-/-
----+++--+-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
----+++--+--/
----+++--+-theorem closure_range_pullback_eq_top_of_injective
----+++--+-    (φ : C(X, Y))
----+++--+-    (hφ : Function.Injective φ)
----+++--+-    (A : Subalgebra ℝ C(Y, ℝ))
----+++--+-    (hA : Dense (A : Set C(Y, ℝ))) :
----+++--+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
----+++--+-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
----+++--+-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
----+++--+-
----+++--+-/-! ### §4: ε-approximation -/
----+++--+-
----+++--+-/-
----+++--+-ε-approximation within `FiberConst φ`.
----+++--+--/
----+++--+-theorem exists_pullback_approx_of_fiberConst
----+++--+-    (φ : C(X, Y))
----+++--+-    (A : Subalgebra ℝ C(Y, ℝ))
----+++--+-    (hA : Dense (A : Set C(Y, ℝ)))
----+++--+-    (g : C(X, ℝ))
----+++--+-    (hg : g ∈ FiberConst φ)
----+++--+-    {ε : ℝ} (hε : 0 < ε) :
----+++--+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----+++--+-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
----+++--+-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
----+++--+-  rw [ Metric.mem_closure_iff ] at h_closure;
----+++--+-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
----+++--+-
----+++--+-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
----+++--+-theorem exists_pullback_approx_of_injective
----+++--+-    (φ : C(X, Y))
----+++--+-    (hφ : Function.Injective φ)
----+++--+-    (A : Subalgebra ℝ C(Y, ℝ))
----+++--+-    (hA : Dense (A : Set C(Y, ℝ)))
----+++--+-    (g : C(X, ℝ))
----+++--+-    {ε : ℝ} (hε : 0 < ε) :
----+++--+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----+++--+-  exact exists_pullback_approx_of_fiberConst φ A hA g
----+++--+-    (mem_fiberConst_of_injective φ hφ g) hε+end+--- a/EML/Basic.lean
----+++-++++ b/EML/Basic.lean
----+++-+@@ -1,277 +1,125 @@
----+++-+-/-
----+++-+-Copyright (c) 2026 Harmonic. All rights reserved.
----+++-+-Released under Apache 2.0 license as described in the file LICENSE.
----+++-+--/
----++ -+ import Mathlib
----++ -+ 
----++--+ namespace SimpleGraph
----++--+ 
----++--+-variable {V : Type*} {G : SimpleGraph V} {e : Sym2 V}
----++--++variable {V : Type*} {G : SimpleGraph V}
----++--+ 
----++--+-/-! ### Trees have all bridges
----++--++/-! ### Deletion equivalence
----++--+ 
----++--+-We prove that in a tree, every edge is a bridge. This follows from the
----++--+-characterization that an edge is a bridge iff it does not lie on any cycle,
----++--+-combined with the fact that trees are acyclic.
----++--++`G.deleteEdges s` and `G \ fromEdgeSet s` have the same adjacency and
----++--++hence the same reachability.  We prove the reachability equivalence
----++--++we need. -/
----++--++
----++--++/-
----++--++`deleteEdges {e}` and `G \ fromEdgeSet {e}` have the same reachability.
----+++-+-/-!
----+++-+-# Pullback Stability of Universal Approximation
----+++-++/-! # CatalogBuild.EML.Basic
----+ +-+ 
----+-+-+ This file develops the theory of bridges (cut edges) in simple graphs,
----+-+-+-proving the fundamental equivalence between trees and connected graphs
----+-+-+-where every edge is a bridge.
----+-+-++building on Mathlib's `SimpleGraph.IsBridge` definition.
----+++-+-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
----+++-+-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
----+++-+-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
----+++-+-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
----+++-+-
----+++-+-This establishes a transport principle: universal approximation results (like
----+++-+-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
----+++-+-with the precise target being the fiber-constant functions.
----+++-+-
----+++-+-## Main definitions
----+++-+-
----+++-+-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
----+++-+-  fibers of `φ`.
----+++-+-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
----+++-+-
----+++-+-## Main results
----+++-+-
----+++-+-### Basic properties (§1)
----+++-+-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
----+++-+-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
----+++-+-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
----+++-+-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
----+++-+-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
----+++-+-
----+++-+-### Factorization (§2)
----+++-+-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
----+++-+-  through `Set.range φ`, hence is a pullback (via Tietze extension).
----+++-+-
----+++-+-### Density transport (§3)
----+++-+-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
----+++-+-  subalgebra equals `FiberConst φ`.
----+++-+-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
----+++-+-
----+++-+-### ε-approximation (§4)
----+++-+-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
----+++-+-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
----+++-++Auto-generated from theorem catalog database.
----+++-++Domain: EML
----+++-++Declarations: 15
----++ -+ -/
----++--++theorem reachable_deleteEdges_iff_reachable_sdiff {e : Sym2 V} {u v : V} :
----++--++    (G.deleteEdges {e}).Reachable u v ↔ (G \ fromEdgeSet {e}).Reachable u v := by
----++--++  constructor;
----++--++  · intro h;
----++--++    convert h.mono ?_;
----++--++    intro u v; aesop;
----++--++  · intro h;
----++--++    convert h
----++--+ 
----++--+-/-- In an acyclic graph, every edge is a bridge. Since there are no cycles,
----++--+-no edge can lie on a cycle, which is precisely the bridge characterization. -/
----++--+-theorem IsAcyclic.isBridge_of_mem_edgeSet (hAcyclic : G.IsAcyclic)
----++--+-    (he : e ∈ G.edgeSet) : G.IsBridge e := by
----++--+-  rw [isBridge_iff_mem_and_forall_cycle_notMem]
----++--+-  exact ⟨he, fun u p hp => absurd hp (hAcyclic p)⟩
----++--++/-- Bridge characterization using `deleteEdges` instead of `sdiff`. -/
----++--++theorem isBridge_iff_deleteEdges {u v : V} :
----++--++    G.IsBridge s(u, v) ↔ G.Adj u v ∧ ¬(G.deleteEdges {s(u, v)}).Reachable u v := by
----++--++  rw [isBridge_iff]
----++--++  exact ⟨
----++--++    fun ⟨h1, h2⟩ => ⟨h1, fun hr => h2 (reachable_deleteEdges_iff_reachable_sdiff.mp hr)⟩,
----++--++    fun ⟨h1, h2⟩ => ⟨h1, fun hr => h2 (reachable_deleteEdges_iff_reachable_sdiff.mpr hr)⟩⟩
----++--+ 
----++--+-/-- In a tree, every edge is a bridge. This is a direct consequence of
----++--+-acyclicity: since no cycles exist, no edge can participate in a cycle. -/
----++--+-theorem IsTree.isBridge_of_mem_edgeSet (hTree : G.IsTree)
----++--+-    (he : e ∈ G.edgeSet) : G.IsBridge e :=
----++--+-  hTree.IsAcyclic.isBridge_of_mem_edgeSet he
----++--++/-! ### Bridge fundamentals -/
----++--+ 
----++--+-/-! ### Connected graphs with all bridges are trees
----++--++/-- The endpoints of a bridge lie in different connected components
----++--++after the bridge is deleted. -/
----++--++theorem IsBridge.connectedComponent_ne_deleteEdges {u v : V}
----++--++    (hb : G.IsBridge s(u, v)) :
----++--++    (G.deleteEdges {s(u, v)}).connectedComponentMk u ≠
----++--++    (G.deleteEdges {s(u, v)}).connectedComponentMk v := by
----++--++  rw [Ne, ConnectedComponent.eq]
----++--++  exact (isBridge_iff_deleteEdges.mp hb).2
----++--+ 
----++--+-We prove the converse: if a connected graph has the property that every
----++--+-edge is a bridge, then it must be acyclic (and hence a tree).
----++--++/-! ### Bridge splitting: every vertex goes to one side -/
----++--++
----++--++/-
----++--++In a connected graph, after removing a bridge {u,v}, every vertex
----++--++is reachable from either u or v (but not both, since u and v are separated).
----++--++This shows the bridge partitions the vertex set into exactly two parts.
----++--+ -/
----++--++theorem IsBridge.forall_reachable_delete_left_or_right
----++--++    (hconn : G.Connected) {u v : V} (hb : G.IsBridge s(u, v)) (w : V) :
----++--++    (G.deleteEdges {s(u, v)}).Reachable u w ∨
----++--++    (G.deleteEdges {s(u, v)}).Reachable v w := by
----++--++  obtain ⟨ p ⟩ := hconn w u;
----++--++  induction' p with w' w'' p ih;
----++--++  · exact Or.inl ( SimpleGraph.Reachable.refl _ );
----++--++  · cases' eq_or_ne w'' ih with h h <;> cases' eq_or_ne w'' v with h' h' <;> simp_all +decide [ SimpleGraph.isBridge_iff ];
----++--++    cases' ‹ ( G.deleteEdges { s(ih, v) } ).Reachable ih p ∨ ( G.deleteEdges { s(ih, v) } ).Reachable v p › with h'' h'' <;> [ left; right ] <;> refine' h''.trans _ <;> simp_all +decide [ SimpleGraph.deleteEdges ];
----++--++    · exact SimpleGraph.Adj.reachable ( by aesop ) |> SimpleGraph.Reachable.symm;
----++--++    · exact SimpleGraph.Reachable.symm ( SimpleGraph.Adj.reachable ( by aesop ) )
----++--+ 
----++--+-/-- If every edge of a graph is a bridge, then the graph is acyclic.
----++--++/-! ### Two connected components -/
----++--+ 
----++--+-**Proof sketch**: Suppose for contradiction there exists a cycle `c`.
----++--+-Since `c` is not nil, it has at least one edge `e`. This edge lies in the
----++--+-edge set of `G`, so by hypothesis it is a bridge. But bridges cannot lie
----++--+-on any cycle (by `isBridge_iff_mem_and_forall_cycle_notMem`), contradicting
----++--+-that `e` lies on `c`. -/
----++--+-theorem isAcyclic_of_forall_isBridge
----++--+-    (h : ∀ e ∈ G.edgeSet, G.IsBridge e) : G.IsAcyclic := by
----++--+-  intro v c hc
----++--+-  -- A cycle must have at least one edge
----++--+-  have hne : c.edges ≠ [] := by
----++--+-    intro he
----++--+-    cases c with
----++--+-    | nil => exact hc.ne_nil rfl
----++--+-    | cons _ _ => simp [Walk.edges_cons] at he
----++--+-  obtain ⟨e, he⟩ := List.exists_mem_of_ne_nil _ hne
----++--+-  have he_mem : e ∈ G.edgeSet := Walk.edges_subset_edgeSet _ he
----++--+-  have hbridge := h e he_mem
----++--+-  rw [isBridge_iff_mem_and_forall_cycle_notMem] at hbridge
----++--+-  exact hbridge.2 c hc he
----++--++/-
----++--++Removing a bridge from a connected graph produces exactly two
----++--++connected components. This is a fundamental structural result about
----++--++bridges, showing that a bridge literally "bridges" two otherwise
----++--++disconnected parts of the graph.
----++--++-/
----++--++theorem IsBridge.two_connected_components [DecidableEq V] [Fintype V]
----++--++    [DecidableRel G.Adj]
----++--++    (hconn : G.Connected) {u v : V} (hb : G.IsBridge s(u, v)) :
----++--++    Fintype.card (G.deleteEdges {s(u, v)}).ConnectedComponent = 2 := by
----++--++  convert Set.ncard_eq_two.mpr _;
----++--++  rotate_left;
----++--++  exact ( G.deleteEdges { s(u, v) } ).ConnectedComponent;
----++--++  exact Set.range ( fun w => ( G.deleteEdges { s(u, v) } ).connectedComponentMk w );
----++--++  · refine' ⟨ _, _, _, _ ⟩;
----++--++    exact ( G.deleteEdges { s(u, v) } ).connectedComponentMk u;
----++--++    exact ( G.deleteEdges { s(u, v) } ).connectedComponentMk v;
----++--++    · exact connectedComponent_ne_deleteEdges hb;
----++--++    · ext w;
----++--++      obtain ⟨ x, rfl ⟩ := w.exists_rep;
----++--++      have := hb.forall_reachable_delete_left_or_right hconn x;
----++--++      cases this <;> simp_all +decide [ SimpleGraph.connectedComponentMk ];
----++--++      · exact Or.inl ( Quot.sound ‹_› |> Eq.symm );
----++--++      · exact Or.inr ( Quot.sound <| by tauto );
----++--++  · rw [ Set.ncard_eq_toFinset_card _ ];
----++--++    refine' Finset.card_bij ( fun x _ => x ) _ _ _ <;> simp +decide;
----++--++    exact fun a => a.exists_rep
----++--+ 
----++--+-/-- **Tree-Bridge Equivalence Theorem.**
----++--+-A graph is a tree if and only if it is connected and every edge is a bridge.
----++--++/-! ### Trees and bridges -/
----++--+ 
----++--+-This is a fundamental characterization of trees: they are precisely the
----++--+-connected graphs that are "minimally connected" — removing any single
----++--+-edge disconnects the graph.
----++--++/-
----++--++Every edge of a tree is a bridge. In a tree, every edge is critical
----++--++for connectivity — removing any edge disconnects the tree.
----++--++-/
----++--++theorem IsTree.isBridge_of_adj (hT : G.IsTree) {u v : V} (hadj : G.Adj u v) :
----++--++    G.IsBridge s(u, v) := by
----++--++  -- By definition of a tree, it is acyclic.
----++--++  have h_acyclic : G.IsAcyclic := by
----++--++    exact hT.2;
----++--++  rw [ SimpleGraph.isAcyclic_iff_forall_adj_isBridge ] at h_acyclic ; aesop
----++--+ 
----++--+-### Forward direction
----++--+-In a tree (connected + acyclic), every edge is a bridge because there are
----++--+-no cycles, so no edge can lie on a cycle.
----++--+-
----++--+-### Reverse direction
----++--+-If every edge is a bridge, the graph must be acyclic: any cycle would contain
----++--+-an edge that both lies on a cycle and is a bridge, which is a contradiction. -/
----++--+-theorem isTree_iff_connected_and_forall_isBridge :
----++--+-    G.IsTree ↔ G.Connected ∧ ∀ e ∈ G.edgeSet, G.IsBridge e := by
----++--+-  constructor
----++--+-  · intro hTree
----++--+-    exact ⟨hTree.isConnected, fun e he => hTree.isBridge_of_mem_edgeSet he⟩
----++--+-  · intro ⟨hConn, hBridge⟩
----++--+-    exact ⟨hConn, isAcyclic_of_forall_isBridge hBridge⟩
----++--++/-
----++--++A connected graph is a tree if and only if every edge is a bridge.
----++--++This provides a characterization of trees in terms of edge criticality.
----++--++-/
----++--++theorem connected_isBridge_all_iff_isTree (hconn : G.Connected) :
----++--++    (∀ ⦃u v : V⦄, G.Adj u v → G.IsBridge s(u, v)) ↔ G.IsTree := by
----++--++  constructor;
----++--++  · intro h;
----++--++    constructor;
----++--++    · assumption;
----++--++    · exact isAcyclic_iff_forall_adj_isBridge.mpr h;
----++--++  · exact fun a ⦃u v⦄ a_1 => IsTree.isBridge_of_adj a a_1
----++--+ 
----++--+ end SimpleGraph++-open scoped Topology
----++-++-open Topology
----++-+++noncomputable section
----++-++ 
----++-++-variable {X Y : Type*}
----++-++-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
----++-++-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
----++-+++/-- The inverse for hyperbolic SPB is also negation. -/
----++-+++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
----++-+++  simp [spbH]
----++-++ 
----++-++-/-! ### §1: Definitions and basic properties -/
----++-+++/-- Wick duality: SPB with negated second argument equals the "difference"
----++-+++in the hyperbolic SPB. This is the real-variable manifestation of the
----++-+++Wick rotation t → it. -/
----++-+++theorem wick_duality (x y : ℝ) :
----++-+++    spb x (-y) = (x - y) / (1 + x * y) := by
----++-+++  simp only [spb]
----++-+++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
----++-+++  rw [heq]; ring
----++-++ 
----++-++-/-- Continuous functions on `X` that are constant on fibers of `φ`.
----++-++-This is the natural functional-analytic object associated to a feature map:
----++-++-it captures exactly the observables visible through `φ`. -/
----++-++-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
----++-++-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
----++-++-  algebraMap_mem' r := by intro x x' _; simp
----++-++-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----++-++-  zero_mem' := by intro x x' _; simp
----++-++-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----++-++-  one_mem' := by intro x x' _; simp
----++-+++/-- The tangent addition law IS the stereographic sum.
----++-+++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
----++-+++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
----++-+++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
----++-+++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
----++-+++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
----++-+++  field_simp
----++-++ 
----++-++-/-- Pullback of continuous real-valued functions along `φ`. -/
----++-++-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
----++-++-  toFun f := f.comp φ
----++-++-  map_zero' := by ext; simp
----++-++-  map_one' := by ext; simp
----++-++-  map_add' := by intros; ext; simp
----++-++-  map_mul' := by intros; ext; simp
----++-++-  commutes' := by intros; ext; simp
----++-+++/-- SPB expression trees — analogous to EML expression trees. -/
----++-+++inductive SPBExpr where
----++-+++  | zero : SPBExpr
----++-+++  | one : SPBExpr
----++-+++  | var : ℕ → SPBExpr
----++-+++  | node : SPBExpr → SPBExpr → SPBExpr
----++-+++  deriving Repr, BEq
----++-++ 
----++-++-@[simp]
----++-++-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
----++-++-    pullbackAlg φ f x = f (φ x) := rfl
----++-+++/-- Evaluate an SPB expression. -/
----++-+++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
----++-+++  match e with
----++-+++  | .zero => 0
----++-+++  | .one => 1
----++-+++  | .var n => vars n
----++-+++  | .node l r => spb (l.eval vars) (r.eval vars)
----++-++ 
----++-++-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
----++-++-    pullbackAlg φ f ∈ FiberConst φ := by
----++-++-  intro x x' h; simp [h]
----++-+++/-- Depth of an SPB expression. -/
----++-+++def SPBExpr.depth : SPBExpr → ℕ
----++-+++  | .zero => 0
----++-+++  | .one => 0
----++-+++  | .var _ => 0
----++-+++  | .node l r => 1 + max l.depth r.depth
----++-++ 
----++-++-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
----++-++-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----++-++-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
----++-+++/-- Leaf count. -/
----++-+++def SPBExpr.leafCount : SPBExpr → ℕ
----++-+++  | .zero => 1
----++-+++  | .one => 1
----++-+++  | .var _ => 1
----++-+++  | .node l r => l.leafCount + r.leafCount
----++-++ 
----++-++-theorem range_comp_subalgebra_subset_fiberConst
----++-++-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
----++-++-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----++-++-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
----++-+++/-- Internal node count. -/
----++-+++def SPBExpr.nodeCount : SPBExpr → ℕ
----++-+++  | .zero => 0
----++-+++  | .one => 0
----++-+++  | .var _ => 0
----++-+++  | .node l r => 1 + l.nodeCount + r.nodeCount
----++-++ 
----++-++-/-- `FiberConst φ` is closed in the uniform topology. -/
----++-++-theorem fiberConst_closed (φ : C(X, Y)) :
----++-++-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
----++-++-  refine isClosed_of_closure_subset ?_
----++-++-  intro g hg x x' h
----++-++-  rw [mem_closure_iff_nhds] at hg
----++-++-  contrapose! hg
----++-++-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
----++-++-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
----++-++-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
----++-+++/-- Binary tree identity: leaves = internal nodes + 1. -/
----++-+++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
----++-+++    e.leafCount = e.nodeCount + 1 := by
----++-+++  induction e with
----++-+++  | zero => rfl
----++-+++  | one => rfl
----++-+++  | var _ => rfl
----++-+++  | node l r ihl ihr =>
----++-+++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
----++-+++    omega
----++-++ 
----++-++-omit [T2Space X] [T2Space Y] in
----++-++-/-- The pullback map is norm-nonincreasing. -/
----++-++-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
----++-++-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
----++-++-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
----++-++-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
----++-+++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
----++-+++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
----++-++ 
----++-++-/-- When `φ` is surjective, pullback is an isometry. -/
----++-++-theorem pullback_isometry_of_surjective
----++-++-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
----++-++-    ‖pullbackAlg φ f‖ = ‖f‖ := by
----++-++-  refine le_antisymm (norm_pullback_le φ f) ?_
----++-++-  rw [ContinuousMap.norm_le _ (by positivity)]
----++-++-  intro y; obtain ⟨x, rfl⟩ := hφ y
----++-++-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
----++-+++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
----++-+++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
----++-+++  unfold logisticSigmoid
----++-+++  rw [Real.exp_neg]
----++-+++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
----++-+++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
----++-+++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----++-+++  field_simp; ring
----++-++ 
----++-++-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----++-++-theorem mem_fiberConst_of_injective
----++-++-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
----++-++-    g ∈ FiberConst φ := by
----++-++-  intro x x' h; exact congrArg g (hφ h)
----++-+++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
----++-+++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
----++-+++  unfold softplus logisticSigmoid
----++-+++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
----++-+++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
----++-+++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
----++-+++  simp at this
----++-+++  exact this
----++-++ 
----++-++-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----++-++-theorem fiberConst_eq_top_of_injective
----++-++-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
----++-++-    FiberConst φ = ⊤ := by
----++-++-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
----++-+++/-- ShefferAlg is closed under affine pre-composition. -/
----++-+++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
----++-+++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
----++-+++  obtain ⟨e, rfl⟩ := hf
----++-+++  exact ⟨.affinePrecomp a b e, rfl⟩
----++-++ 
----++-++-omit [CompactSpace Y] [T2Space Y] in
----++-++-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
----++-++-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
----++-++-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
----++-++-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
----++-++-  intro x x' hφ; by_contra h_ne
----++-++-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
----++-++-    have := exists_continuous_zero_one_of_isClosed
----++-++-      (show IsClosed {x} from isClosed_singleton)
----++-++-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
----++-++-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
----++-++-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
----++-++-  replace h := SetLike.ext_iff.mp h g
----++-++-  simp_all +decide [FiberConst]
----++-++-  exact absurd (h hφ) (by simp +decide [hg])
----++-+++/-- ShefferAlg is closed under affine combination. -/
----++-+++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
----++-+++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
----++-+++  obtain ⟨ef, rfl⟩ := hf
----++-+++  obtain ⟨eg, rfl⟩ := hg
----++-+++  exact ⟨.affineComb α β γ ef eg, rfl⟩
----++-++ 
----++-++-/-! ### §2: Image factorization -/
----++-+++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
----++-+++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
----++-+++  unfold softplus
----++-+++  rw [Real.exp_neg]
----++-+++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
----++-+++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----++-+++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
----++-+++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
----++-+++  rw [this, Real.log_exp]
----++-++ 
----++-++-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
----++-++-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
----++-++-
----++-++-/-
----++-++-The corestriction `X → Set.range φ` is a quotient map.
----++-++--/
----++-++-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
----++-++-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
----++-++-  apply IsClosedMap.isQuotientMap;
----++-++-  · intro s hs;
----++-++-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
----++-++-    constructor <;> intro h;
----++-++-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
----++-++-    · convert h.preimage ( continuous_subtype_val ) using 1;
----++-++-      ext; simp [Set.rangeFactorization];
----++-++-      grind;
----++-++-  · exact continuous_induced_rng.mpr φ.continuous;
----++-++-  · exact Set.rangeFactorization_surjective
----++-++-
----++-++-/-- Lift a fiber-constant function to `Set.range φ`. -/
----++-++-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
----++-++-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
----++-++-  toFun z := g z.property.choose
----++-++-  continuous_toFun := by
----++-++-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
----++-++-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
----++-++-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
----++-++-      ext x; apply hg
----++-++-      exact (Set.rangeFactorization φ x).property.choose_spec
----++-++-    rw [this]; exact g.continuous
----++-++-
----++-++-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
----++-++-    (hg : g ∈ FiberConst φ) (x : X) :
----++-++-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
----++-++-  simp only [fiberConstLift]
----++-++-  apply hg
----++-++-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
----++-++-
----++-++-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
----++-++-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
----++-++-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
----++-++-  intro g hg
----++-++-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
----++-++-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
----++-++-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
----++-++-  refine ⟨F, ?_⟩
----++-++-  ext x
----++-++-  simp only [pullbackAlg_apply]
----++-++-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
----++-++-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
----++-++-    simp [ContinuousMap.comp_apply] at this; exact this
----++-++-  rw [key, fiberConstLift_comp]
----++-++-
----++-++-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
----++-++-theorem fiberConst_eq_range_pullback_of_surjective
----++-++-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
----++-++-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
----++-++-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
----++-++-    (range_pullback_subset_fiberConst φ)
----++-++-
----++-++-/-! ### §3: Density transport -/
----++-++-
----++-++-/-
----++-++-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
----++-++--/
----++-++-theorem closure_range_pullback_eq_fiberConst
----++-++-    (φ : C(X, Y))
----++-++-    (A : Subalgebra ℝ C(Y, ℝ))
----++-++-    (hA : Dense (A : Set C(Y, ℝ))) :
----++-++-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
----++-++-      = (FiberConst φ : Set C(X, ℝ)) := by
----++-++-  refine' le_antisymm ( closure_minimal _ _ ) _;
----++-++-  · exact range_comp_subalgebra_subset_fiberConst φ A;
----++-++-  · exact fiberConst_closed φ;
----++-++-  · intro g hg;
----++-++-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
----++-++-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
----++-++-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
----++-++-    rw [ Metric.mem_closure_iff ];
----++-++-    intro ε εpos;
----++-++-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
----++-++-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
----++-++-    nontriviality;
----++-++-    rw [ hF, dist_eq_norm ] at *;
----++-++-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
----++-++-
----++-++-/-
----++-++-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
----++-++--/
----++-++-theorem closure_range_pullback_eq_top_of_injective
----++-++-    (φ : C(X, Y))
----++-++-    (hφ : Function.Injective φ)
----++-++-    (A : Subalgebra ℝ C(Y, ℝ))
----++-++-    (hA : Dense (A : Set C(Y, ℝ))) :
----++-++-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
----++-++-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
----++-++-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
----++-++-
----++-++-/-! ### §4: ε-approximation -/
----++-++-
----++-++-/-
----++-++-ε-approximation within `FiberConst φ`.
----++-++--/
----++-++-theorem exists_pullback_approx_of_fiberConst
----++-++-    (φ : C(X, Y))
----++-++-    (A : Subalgebra ℝ C(Y, ℝ))
----++-++-    (hA : Dense (A : Set C(Y, ℝ)))
----++-++-    (g : C(X, ℝ))
----++-++-    (hg : g ∈ FiberConst φ)
----++-++-    {ε : ℝ} (hε : 0 < ε) :
----++-++-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----++-++-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
----++-++-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
----++-++-  rw [ Metric.mem_closure_iff ] at h_closure;
----++-++-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
----++-++-
----++-++-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
----++-++-theorem exists_pullback_approx_of_injective
----++-++-    (φ : C(X, Y))
----++-++-    (hφ : Function.Injective φ)
----++-++-    (A : Subalgebra ℝ C(Y, ℝ))
----++-++-    (hA : Dense (A : Set C(Y, ℝ)))
----++-++-    (g : C(X, ℝ))
----++-++-    {ε : ℝ} (hε : 0 < ε) :
----++-++-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----++-++-  exact exists_pullback_approx_of_fiberConst φ A hA g
----++-++-    (mem_fiberConst_of_injective φ hφ g) hε+end+-+ 
----+++-+-open scoped Topology
----+++-+-open Topology
----+++-++noncomputable section
----+ +-+ 
----+-+-+-## Main Results
----+-+-++## Main results
----+++-+-variable {X Y : Type*}
----+++-+-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
----+++-+-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
----+++-++/-- The inverse for hyperbolic SPB is also negation. -/
----+++-++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
----+++-++  simp [spbH]
----+ +-+ 
----+-+-+-* `SimpleGraph.IsAcyclic.isBridge_of_mem_edgeSet` — In an acyclic graph, every edge is a bridge
----+-+-+-* `SimpleGraph.IsTree.isBridge_of_mem_edgeSet` — In a tree, every edge is a bridge
----+-+-+-* `SimpleGraph.isAcyclic_of_forall_isBridge` — If every edge is a bridge, the graph is acyclic
----+-+-+-* `SimpleGraph.isTree_iff_connected_and_forall_isBridge` — **Tree-Bridge Equivalence**:
----+-+-+-  A graph is a tree if and only if it is connected and every edge is a bridge
----+-+-++* `IsBridge.connectedComponent_ne` — Endpoints of a bridge are in different
----+-+-++  connected components after deletion.
----+-+-++* `IsBridge.two_connected_components` — Removing a bridge from a connected
----+-+-++  graph yields exactly two connected components.
----+-+-++* `IsTree.isBridge_of_adj` — Every edge of a tree is a bridge.
----+-+-++* `connected_isBridge_all_iff_isTree` — A connected graph is a tree iff
----+-+-++  every edge is a bridge.
----+-+-++* `IsBridge.forall_reachable_delete_left_or_right` — Every vertex in a
----+-+-++  connected graph is reachable from one side of a bridge after deletion.
----+++-+-/-! ### §1: Definitions and basic properties -/
----+++-++/-- Wick duality: SPB with negated second argument equals the "difference"
----+++-++in the hyperbolic SPB. This is the real-variable manifestation of the
----+++-++Wick rotation t → it. -/
----+++-++theorem wick_duality (x y : ℝ) :
----+++-++    spb x (-y) = (x - y) / (1 + x * y) := by
----+++-++  simp only [spb]
----+++-++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
----+++-++  rw [heq]; ring
----+ +-+ 
----+-+-+-## Historical Context
----+-+-++## Historical context
----+++-+-/-- Continuous functions on `X` that are constant on fibers of `φ`.
----+++-+-This is the natural functional-analytic object associated to a feature map:
----+++-+-it captures exactly the observables visible through `φ`. -/
----+++-+-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
----+++-+-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
----+++-+-  algebraMap_mem' r := by intro x x' _; simp
----+++-+-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----+++-+-  zero_mem' := by intro x x' _; simp
----+++-+-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----+++-+-  one_mem' := by intro x x' _; simp
----+++-++/-- The tangent addition law IS the stereographic sum.
----+++-++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
----+++-++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
----+++-++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
----+++-++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
----+++-++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
----+++-++  field_simp
----+ +-+ 
----+-+-+-Bridges in graph theory originate from Euler's 1736 analysis of the Königsberg
----+-+-+-bridge problem. The Tree-Bridge Equivalence Theorem provides a fundamental
----+-+-+-structural characterization: trees are precisely the minimally connected graphs,
----+-+-+-where the removal of any single edge disconnects the graph.
----+++-+-/-- Pullback of continuous real-valued functions along `φ`. -/
----+++-+-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
----+++-+-  toFun f := f.comp φ
----+++-+-  map_zero' := by ext; simp
----+++-+-  map_one' := by ext; simp
----+++-+-  map_add' := by intros; ext; simp
----+++-+-  map_mul' := by intros; ext; simp
----+++-+-  commutes' := by intros; ext; simp
----+++-++/-- SPB expression trees — analogous to EML expression trees. -/
----+++-++inductive SPBExpr where
----+++-++  | zero : SPBExpr
----+++-++  | one : SPBExpr
----+++-++  | var : ℕ → SPBExpr
----+++-++  | node : SPBExpr → SPBExpr → SPBExpr
----+++-++  deriving Repr, BEq
----+++-+ 
----+++-+-@[simp]
----+++-+-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
----+++-+-    pullbackAlg φ f x = f (φ x) := rfl
----+++-++/-- Evaluate an SPB expression. -/
----+++-++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
----+++-++  match e with
----+++-++  | .zero => 0
----+++-++  | .one => 1
----+++-++  | .var n => vars n
----+++-++  | .node l r => spb (l.eval vars) (r.eval vars)
----+++-+ 
----+++-+-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
----+++-+-    pullbackAlg φ f ∈ FiberConst φ := by
----+++-+-  intro x x' h; simp [h]
----+++-++/-- Depth of an SPB expression. -/
----+++-++def SPBExpr.depth : SPBExpr → ℕ
----+++-++  | .zero => 0
----+++-++  | .one => 0
----+++-++  | .var _ => 0
----+++-++  | .node l r => 1 + max l.depth r.depth
----+++-+ 
----+++-+-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
----+++-+-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----+++-+-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
----+++-++/-- Leaf count. -/
----+++-++def SPBExpr.leafCount : SPBExpr → ℕ
----+++-++  | .zero => 1
----+++-++  | .one => 1
----+++-++  | .var _ => 1
----+++-++  | .node l r => l.leafCount + r.leafCount
----+++-+ 
----+++-+-theorem range_comp_subalgebra_subset_fiberConst
----+++-+-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
----+++-+-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----+++-+-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
----+++-++/-- Internal node count. -/
----+++-++def SPBExpr.nodeCount : SPBExpr → ℕ
----+++-++  | .zero => 0
----+++-++  | .one => 0
----+++-++  | .var _ => 0
----+++-++  | .node l r => 1 + l.nodeCount + r.nodeCount
----+++-+ 
----+++-+-/-- `FiberConst φ` is closed in the uniform topology. -/
----+++-+-theorem fiberConst_closed (φ : C(X, Y)) :
----+++-+-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
----+++-+-  refine isClosed_of_closure_subset ?_
----+++-+-  intro g hg x x' h
----+++-+-  rw [mem_closure_iff_nhds] at hg
----+++-+-  contrapose! hg
----+++-+-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
----+++-+-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
----+++-+-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
----+++-++/-- Binary tree identity: leaves = internal nodes + 1. -/
----+++-++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
----+++-++    e.leafCount = e.nodeCount + 1 := by
----+++-++  induction e with
----+++-++  | zero => rfl
----+++-++  | one => rfl
----+++-++  | var _ => rfl
----+++-++  | node l r ihl ihr =>
----+++-++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
----+++-++    omega
----+++-+ 
----+++-+-omit [T2Space X] [T2Space Y] in
----+++-+-/-- The pullback map is norm-nonincreasing. -/
----+++-+-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
----+++-+-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
----+++-+-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
----+++-+-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
----+++-++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
----+++-++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
----+++-+ 
----+++-+-/-- When `φ` is surjective, pullback is an isometry. -/
----+++-+-theorem pullback_isometry_of_surjective
----+++-+-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
----+++-+-    ‖pullbackAlg φ f‖ = ‖f‖ := by
----+++-+-  refine le_antisymm (norm_pullback_le φ f) ?_
----+++-+-  rw [ContinuousMap.norm_le _ (by positivity)]
----+++-+-  intro y; obtain ⟨x, rfl⟩ := hφ y
----+++-+-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
----+++-++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
----+++-++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
----+++-++  unfold logisticSigmoid
----+++-++  rw [Real.exp_neg]
----+++-++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
----+++-++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
----+++-++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----+++-++  field_simp; ring
----+++-+ 
----+++-+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----+++-+-theorem mem_fiberConst_of_injective
----+++-+-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
----+++-+-    g ∈ FiberConst φ := by
----+++-+-  intro x x' h; exact congrArg g (hφ h)
----+++-++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
----+++-++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
----+++-++  unfold softplus logisticSigmoid
----+++-++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
----+++-++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
----+++-++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
----+++-++  simp at this
----+++-++  exact this
----+++-+ 
----+++-+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----+++-+-theorem fiberConst_eq_top_of_injective
----+++-+-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
----+++-+-    FiberConst φ = ⊤ := by
----+++-+-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
----+++-++/-- ShefferAlg is closed under affine pre-composition. -/
----+++-++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
----+++-++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
----+++-++  obtain ⟨e, rfl⟩ := hf
----+++-++  exact ⟨.affinePrecomp a b e, rfl⟩
----+++-+ 
----+++-+-omit [CompactSpace Y] [T2Space Y] in
----+++-+-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
----+++-+-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
----+++-+-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
----+++-+-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
----+++-+-  intro x x' hφ; by_contra h_ne
----+++-+-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
----+++-+-    have := exists_continuous_zero_one_of_isClosed
----+++-+-      (show IsClosed {x} from isClosed_singleton)
----+++-+-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
----+++-+-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
----+++-+-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
----+++-+-  replace h := SetLike.ext_iff.mp h g
----+++-+-  simp_all +decide [FiberConst]
----+++-+-  exact absurd (h hφ) (by simp +decide [hg])
----+++-++/-- ShefferAlg is closed under affine combination. -/
----+++-++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
----+++-++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
----+++-++  obtain ⟨ef, rfl⟩ := hf
----+++-++  obtain ⟨eg, rfl⟩ := hg
----+++-++  exact ⟨.affineComb α β γ ef eg, rfl⟩
----+++-+ 
----+++-+-/-! ### §2: Image factorization -/
----+++-++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
----+++-++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
----+++-++  unfold softplus
----+++-++  rw [Real.exp_neg]
----+++-++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
----+++-++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----+++-++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
----+++-++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
----+++-++  rw [this, Real.log_exp]
----+++-+ 
----+++-+-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
----+++-+-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
----+ +-+-
----+-+-+-## References
----+++-+-/-
----+++-+-The corestriction `X → Set.range φ` is a quotient map.
----+++-+--/
----+++-+-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
----+++-+-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
----+++-+-  apply IsClosedMap.isQuotientMap;
----+++-+-  · intro s hs;
----+++-+-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
----+++-+-    constructor <;> intro h;
----+++-+-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
----+++-+-    · convert h.preimage ( continuous_subtype_val ) using 1;
----+++-+-      ext; simp [Set.rangeFactorization];
----+++-+-      grind;
----+++-+-  · exact continuous_induced_rng.mpr φ.continuous;
----+++-+-  · exact Set.rangeFactorization_surjective
----+ +-+-
----+-+-+-* Reinhard Diestel, *Graph Theory*, 5th Edition, Springer, 2017
----+-+-++The study of bridges in graph theory traces back to Euler's 1736 solution
----+-+-++of the Königsberg Bridge Problem — widely considered the birth of graph
----+-+-++theory. A bridge (or cut edge) is an edge whose removal disconnects the
----+-+-++graph, making it a critical concept in network reliability and infrastructure
----+-+-++analysis.
----+-++--- a/Tropical/Basic.lean
----+-+++++ b/Tropical/Basic.lean
----+-++@@ -1,1315 +1,383 @@
----+-++---- a/Tropical/Basic.lean
----+-++-+++ b/Tropical/Basic.lean
----+-++-@@ -1,930 +1,383 @@
----+-++----- a/Tropical/Basic.lean
----+-++--+++ b/Tropical/Basic.lean
----+-++--@@ -1,545 +1,383 @@
----+-++------ a/Tropical/Basic.lean
----+-++---+++ b/Tropical/Basic.lean
----+-++---@@ -1,383 +1,160 @@
----+-++------- a/EML/Basic.lean
----+-++----+++ b/EML/Basic.lean
----+-++----@@ -1,277 +1,125 @@
----+-++-----/-
----+-++-----Copyright (c) 2026 Harmonic. All rights reserved.
----+-++-----Released under Apache 2.0 license as described in the file LICENSE.
----+-++------/
----+-++---- import Mathlib
----+-++---- 
----+-++-----/-!
----+-++-----# Pullback Stability of Universal Approximation
----+-++----+/-! # CatalogBuild.EML.Basic
----+-++---- 
----+-++-----Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
----+-++-----subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
----+-++-----closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
----+-++-----When `φ` is injective, this gives density in all of `C(X, ℝ)`.
----+-++-----
----+-++-----This establishes a transport principle: universal approximation results (like
----+-++-----Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
----+-++-----with the precise target being the fiber-constant functions.
----+-++-----
----+-++-----## Main definitions
----+-++-----
----+-++-----* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
----+-++-----  fibers of `φ`.
----+-++-----* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
----+-++-----
----+-++-----## Main results
----+-++-----
----+-++-----### Basic properties (§1)
----+-++-----* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
----+-++-----* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
----+-++-----* `norm_pullback_le` — the pullback map is norm-nonincreasing.
----+-++-----* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
----+-++-----* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
----+-++-----
----+-++-----### Factorization (§2)
----+-++-----* `fiberConst_subset_range_pullback` — every fiber-constant function factors
----+-++-----  through `Set.range φ`, hence is a pullback (via Tietze extension).
----+-++-----
----+-++-----### Density transport (§3)
----+-++-----* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
----+-++-----  subalgebra equals `FiberConst φ`.
----+-++-----* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
----+-++-----
----+-++-----### ε-approximation (§4)
----+-++-----* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
----+-++-----* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
----+-++----+Auto-generated from theorem catalog database.
----+-++----+Domain: EML
----+-++----+Declarations: 15
----+-++---- -/
----+-++---- 
----+-++-----open scoped Topology
----+-++-----open Topology
----+-++----+noncomputable section
----+-++---- 
----+-++-----variable {X Y : Type*}
----+-++-----variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
----+-++-----variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
----+-++----+/-- The inverse for hyperbolic SPB is also negation. -/
----+-++----+theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
----+-++----+  simp [spbH]
----+-++---- 
----+-++-----/-! ### §1: Definitions and basic properties -/
----+-++----+/-- Wick duality: SPB with negated second argument equals the "difference"
----+-++----+in the hyperbolic SPB. This is the real-variable manifestation of the
----+-++----+Wick rotation t → it. -/
----+-++----+theorem wick_duality (x y : ℝ) :
----+-++----+    spb x (-y) = (x - y) / (1 + x * y) := by
----+-++----+  simp only [spb]
----+-++----+  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
----+-++----+  rw [heq]; ring
----+-++---- 
----+-++-----/-- Continuous functions on `X` that are constant on fibers of `φ`.
----+-++-----This is the natural functional-analytic object associated to a feature map:
----+-++-----it captures exactly the observables visible through `φ`. -/
----+-++-----def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
----+-++-----  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
----+-++-----  algebraMap_mem' r := by intro x x' _; simp
----+-++-----  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----+-++-----  zero_mem' := by intro x x' _; simp
----+-++-----  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----+-++-----  one_mem' := by intro x x' _; simp
----+-++----+/-- The tangent addition law IS the stereographic sum.
----+-++----+tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
----+-++----+theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
----+-++----+    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
----+-++----+  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
----+-++----+      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
----+-++----+  field_simp
----+-++---- 
----+-++-----/-- Pullback of continuous real-valued functions along `φ`. -/
----+-++-----def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
----+-++-----  toFun f := f.comp φ
----+-++-----  map_zero' := by ext; simp
----+-++-----  map_one' := by ext; simp
----+-++-----  map_add' := by intros; ext; simp
----+-++-----  map_mul' := by intros; ext; simp
----+-++-----  commutes' := by intros; ext; simp
----+-++----+/-- SPB expression trees — analogous to EML expression trees. -/
----+-++----+inductive SPBExpr where
----+-++----+  | zero : SPBExpr
----+-++----+  | one : SPBExpr
----+-++----+  | var : ℕ → SPBExpr
----+-++----+  | node : SPBExpr → SPBExpr → SPBExpr
----+-++----+  deriving Repr, BEq
----+-++---- 
----+-++-----@[simp]
----+-++-----theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
----+-++-----    pullbackAlg φ f x = f (φ x) := rfl
----+-++----+/-- Evaluate an SPB expression. -/
----+-++----+def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
----+-++----+  match e with
----+-++----+  | .zero => 0
----+-++----+  | .one => 1
----+-++----+  | .var n => vars n
----+-++----+  | .node l r => spb (l.eval vars) (r.eval vars)
----+-++---- 
----+-++-----theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
----+-++-----    pullbackAlg φ f ∈ FiberConst φ := by
----+-++-----  intro x x' h; simp [h]
----+-++----+/-- Depth of an SPB expression. -/
----+-++----+def SPBExpr.depth : SPBExpr → ℕ
----+-++----+  | .zero => 0
----+-++----+  | .one => 0
----+-++----+  | .var _ => 0
----+-++----+  | .node l r => 1 + max l.depth r.depth
----+-++---- 
----+-++-----theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
----+-++-----    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----+-++-----  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
----+-++----+/-- Leaf count. -/
----+-++----+def SPBExpr.leafCount : SPBExpr → ℕ
----+-++----+  | .zero => 1
----+-++----+  | .one => 1
----+-++----+  | .var _ => 1
----+-++----+  | .node l r => l.leafCount + r.leafCount
----+-++---- 
----+-++-----theorem range_comp_subalgebra_subset_fiberConst
----+-++-----    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
----+-++-----    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----+-++-----  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
----+-++----+/-- Internal node count. -/
----+-++----+def SPBExpr.nodeCount : SPBExpr → ℕ
----+-++----+  | .zero => 0
----+-++----+  | .one => 0
----+-++----+  | .var _ => 0
----+-++----+  | .node l r => 1 + l.nodeCount + r.nodeCount
----+-++---- 
----+-++-----/-- `FiberConst φ` is closed in the uniform topology. -/
----+-++-----theorem fiberConst_closed (φ : C(X, Y)) :
----+-++-----    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
----+-++-----  refine isClosed_of_closure_subset ?_
----+-++-----  intro g hg x x' h
----+-++-----  rw [mem_closure_iff_nhds] at hg
----+-++-----  contrapose! hg
----+-++-----  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
----+-++-----    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
----+-++-----    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
----+-++----+/-- Binary tree identity: leaves = internal nodes + 1. -/
----+-++----+theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
----+-++----+    e.leafCount = e.nodeCount + 1 := by
----+-++----+  induction e with
----+-++----+  | zero => rfl
----+-++----+  | one => rfl
----+-++----+  | var _ => rfl
----+-++----+  | node l r ihl ihr =>
----+-++----+    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
----+-++----+    omega
----+-++---- 
----+-++-----omit [T2Space X] [T2Space Y] in
----+-++-----/-- The pullback map is norm-nonincreasing. -/
----+-++-----theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
----+-++-----    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
----+-++-----  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
----+-++-----    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
----+-++----+/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
----+-++----+def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
----+-++---- 
----+-++-----/-- When `φ` is surjective, pullback is an isometry. -/
----+-++-----theorem pullback_isometry_of_surjective
----+-++-----    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
----+-++-----    ‖pullbackAlg φ f‖ = ‖f‖ := by
----+-++-----  refine le_antisymm (norm_pullback_le φ f) ?_
----+-++-----  rw [ContinuousMap.norm_le _ (by positivity)]
----+-++-----  intro y; obtain ⟨x, rfl⟩ := hφ y
----+-++-----  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
----+-++----+/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
----+-++----+theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
----+-++----+  unfold logisticSigmoid
----+-++----+  rw [Real.exp_neg]
----+-++----+  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
----+-++----+  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
----+-++----+  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----+-++----+  field_simp; ring
----+-++---- 
----+-++-----omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----+-++-----theorem mem_fiberConst_of_injective
----+-++-----    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
----+-++-----    g ∈ FiberConst φ := by
----+-++-----  intro x x' h; exact congrArg g (hφ h)
----+-++----+/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
----+-++----+theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
----+-++----+  unfold softplus logisticSigmoid
----+-++----+  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
----+-++----+  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
----+-++----+  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
----+-++----+  simp at this
----+-++----+  exact this
----+-++---- 
----+-++-----omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----+-++-----theorem fiberConst_eq_top_of_injective
----+-++-----    (φ : C(X, Y)) (hφ : Function.Injective φ) :
----+-++-----    FiberConst φ = ⊤ := by
----+-++-----  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
----+-++----+/-- ShefferAlg is closed under affine pre-composition. -/
----+-++----+theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
----+-++----+    (fun x => f (a * x + b)) ∈ ShefferAlg := by
----+-++----+  obtain ⟨e, rfl⟩ := hf
----+-++----+  exact ⟨.affinePrecomp a b e, rfl⟩
----+-++---- 
----+-++-----omit [CompactSpace Y] [T2Space Y] in
----+-++-----/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
----+-++-----theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
----+-++-----    FiberConst φ = ⊤ ↔ Function.Injective φ := by
----+-++-----  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
----+-++-----  intro x x' hφ; by_contra h_ne
----+-++-----  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
----+-++-----    have := exists_continuous_zero_one_of_isClosed
----+-++-----      (show IsClosed {x} from isClosed_singleton)
----+-++-----      (show IsClosed {x'} from isClosed_singleton) (by aesop)
----+-++-----    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
----+-++-----      this.choose_spec.2.1 (Set.mem_singleton x')⟩
----+-++-----  replace h := SetLike.ext_iff.mp h g
----+-++-----  simp_all +decide [FiberConst]
----+-++-----  exact absurd (h hφ) (by simp +decide [hg])
----+-++----+/-- ShefferAlg is closed under affine combination. -/
----+-++----+theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
----+-++----+    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
----+-++----+  obtain ⟨ef, rfl⟩ := hf
----+-++----+  obtain ⟨eg, rfl⟩ := hg
----+-++----+  exact ⟨.affineComb α β γ ef eg, rfl⟩
----+-++---- 
----+-++-----/-! ### §2: Image factorization -/
----+-++----+/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
----+-++----+theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
----+-++----+  unfold softplus
----+-++----+  rw [Real.exp_neg]
----+-++----+  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
----+-++----+  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----+-++----+  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
----+-++----+  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
----+-++----+  rw [this, Real.log_exp]
----+-++---- 
----+-++-----instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
----+-++-----  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
----+-++-----
----+-++-----/-
----+-++-----The corestriction `X → Set.range φ` is a quotient map.
----+-++------/
----+-++-----theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
----+-++-----    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
----+-++-----  apply IsClosedMap.isQuotientMap;
----+-++-----  · intro s hs;
----+-++-----    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
----+-++-----    constructor <;> intro h;
----+-++-----    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
----+-++-----    · convert h.preimage ( continuous_subtype_val ) using 1;
----+-++-----      ext; simp [Set.rangeFactorization];
----+-++-----      grind;
----+-++-----  · exact continuous_induced_rng.mpr φ.continuous;
----+-++-----  · exact Set.rangeFactorization_surjective
----+-++-----
----+-++-----/-- Lift a fiber-constant function to `Set.range φ`. -/
----+-++-----noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
----+-++-----    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
----+-++-----  toFun z := g z.property.choose
----+-++-----  continuous_toFun := by
----+-++-----    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
----+-++-----    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
----+-++-----    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
----+-++-----      ext x; apply hg
----+-++-----      exact (Set.rangeFactorization φ x).property.choose_spec
----+-++-----    rw [this]; exact g.continuous
----+-++-----
----+-++-----theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
----+-++-----    (hg : g ∈ FiberConst φ) (x : X) :
----+-++-----    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
----+-++-----  simp only [fiberConstLift]
----+-++-----  apply hg
----+-++-----  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
----+-++-----
----+-++-----/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
----+-++-----theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
----+-++-----    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
----+-++-----  intro g hg
----+-++-----  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
----+-++-----  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
----+-++-----    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
----+-++-----  refine ⟨F, ?_⟩
----+-++-----  ext x
----+-++-----  simp only [pullbackAlg_apply]
----+-++-----  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
----+-++-----    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
----+-++-----    simp [ContinuousMap.comp_apply] at this; exact this
----+-++-----  rw [key, fiberConstLift_comp]
----+-++-----
----+-++-----/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
----+-++-----theorem fiberConst_eq_range_pullback_of_surjective
----+-++-----    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
----+-++-----    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
----+-++-----  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
----+-++-----    (range_pullback_subset_fiberConst φ)
----+-++-----
----+-++-----/-! ### §3: Density transport -/
----+-++-----
----+-++-----/-
----+-++-----The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
----+-++------/
----+-++-----theorem closure_range_pullback_eq_fiberConst
----+-++-----    (φ : C(X, Y))
----+-++-----    (A : Subalgebra ℝ C(Y, ℝ))
----+-++-----    (hA : Dense (A : Set C(Y, ℝ))) :
----+-++-----    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
----+-++-----      = (FiberConst φ : Set C(X, ℝ)) := by
----+-++-----  refine' le_antisymm ( closure_minimal _ _ ) _;
----+-++-----  · exact range_comp_subalgebra_subset_fiberConst φ A;
----+-++-----  · exact fiberConst_closed φ;
----+-++-----  · intro g hg;
----+-++-----    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
----+-++-----    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
----+-++-----      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
----+-++-----    rw [ Metric.mem_closure_iff ];
----+-++-----    intro ε εpos;
----+-++-----    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
----+-++-----    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
----+-++-----    nontriviality;
----+-++-----    rw [ hF, dist_eq_norm ] at *;
----+-++-----    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
----+-++-----
----+-++-----/-
----+-++-----Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
----+-++------/
----+-++-----theorem closure_range_pullback_eq_top_of_injective
----+-++-----    (φ : C(X, Y))
----+-++-----    (hφ : Function.Injective φ)
----+-++-----    (A : Subalgebra ℝ C(Y, ℝ))
----+-++-----    (hA : Dense (A : Set C(Y, ℝ))) :
----+-++-----    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
----+-++-----  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
----+-++-----  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
----+-++-----
----+-++-----/-! ### §4: ε-approximation -/
----+-++-----
----+-++-----/-
----+-++-----ε-approximation within `FiberConst φ`.
----+-++------/
----+-++-----theorem exists_pullback_approx_of_fiberConst
----+-++-----    (φ : C(X, Y))
----+-++-----    (A : Subalgebra ℝ C(Y, ℝ))
----+-++-----    (hA : Dense (A : Set C(Y, ℝ)))
----+-++-----    (g : C(X, ℝ))
----+-++-----    (hg : g ∈ FiberConst φ)
----+-++-----    {ε : ℝ} (hε : 0 < ε) :
----+-++-----    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----+-++-----  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
----+-++-----    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
----+-++-----  rw [ Metric.mem_closure_iff ] at h_closure;
----+-++-----  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
----+-++-----
----+-++-----/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
----+-++-----theorem exists_pullback_approx_of_injective
----+-++-----    (φ : C(X, Y))
----+-++-----    (hφ : Function.Injective φ)
----+-++-----    (A : Subalgebra ℝ C(Y, ℝ))
----+-++-----    (hA : Dense (A : Set C(Y, ℝ)))
----+-++-----    (g : C(X, ℝ))
----+-++-----    {ε : ℝ} (hε : 0 < ε) :
----+-++-----    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----+-++-----  exact exists_pullback_approx_of_fiberConst φ A hA g
----+-++-----    (mem_fiberConst_of_injective φ hφ g) hε+end+/-
----+-++---+Copyright (c) 2025. All rights reserved.
----+-++---+Released under Apache 2.0 license as described in the file LICENSE.
----+-++---+-/
----+-++---+import Mathlib
----+-++---+
----+-++---+/-!
----+-++---+# GL₃ Tropical Satake: Core Definitions
----+-++---+
----+-++---+This file establishes the foundational types and operations for the GL₃ tropical
----+-++---+Satake finite-determinacy theory.
----+-++---+
----+-++---+## Overview
----+-++---+
----+-++---+For GL₃, a **dominant coweight** is a triple `(a, b, c) ∈ ℕ³` with `a ≥ b ≥ c`.
----+-++---+The **dominant box** `BoxDom(B)` is the finite set of dominant coweights with `a ≤ B`.
----+-++---+
----+-++---+We define three families of **tropical Satake observables**, corresponding to the
----+-++---+three fundamental representations `ω₁, ω₂, ω₃` of GL₃:
----+-++---+
----+-++---+1. **Rank-1 profile** (`rank1Profile`): tropical convolution with the standard
----+-++---+   representation character. Uses the weights `e₁, e₂, e₃`.
----+-++---+2. **Rank-2 profile** (`rank2Profile`): tropical convolution with the exterior square
----+-++---+   character. Uses the weights `e₁+e₂, e₁+e₃, e₂+e₃`.
----+-++---+3. **Edge moment** (`edgeMoment`): tropical convolution with the determinant character
----+-++---+   `ω₃ = (1,1,1)`. This is the key reconstruction tool: as a shift operator, it
----+-++---+   recovers function values without the information loss inherent in max operations.
----+-++---+
----+-++---+The finite-determinacy theorem (proved in `FiniteDeterminacy.lean`) shows that
----+-++---+equality of these observables on finite test sets forces equality of the underlying
----+-++---+functions.
----+-++---+-/
----+-++---+
----+-++---+open Finset
----+-++---+
----+-++---+/-! ### Dominance and support conditions -/
----+-++---+
----+-++---+/-- A triple `(a, b, c)` is dominant if `a ≥ b ≥ c`. -/
----+-++---+def IsDominant (a b c : ℕ) : Prop := b ≤ a ∧ c ≤ b
----+-++---+
----+-++---+/-- A function on `ℕ³` has finite support within box `B` if it vanishes outside
----+-++---+    the dominant box `{(a,b,c) : b ≤ a, c ≤ b, a ≤ B}`. -/
----+-++---+def FiniteSupportWithin (B : ℕ) (f : ℕ → ℕ → ℕ → ℤ) : Prop :=
----+-++---+  ∀ a b c : ℕ, (B < a ∨ a < b ∨ b < c) → f a b c = 0
----+-++---+
----+-++---+/-- The box `BoxDom(B)` as a `Finset` of triples. -/
----+-++---+def boxDomFinset (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
----+-++---+  (Finset.range (B + 1) ×ˢ Finset.range (B + 1) ×ˢ Finset.range (B + 1)).filter
----+-++---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
----+-++---+
----+-++---+lemma mem_boxDomFinset {B : ℕ} {a b c : ℕ} :
----+-++---+    (a, b, c) ∈ boxDomFinset B ↔ a ≤ B ∧ b ≤ a ∧ c ≤ b := by
----+-++---+  simp [boxDomFinset, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
----+-++---+  omega
----+-++---+
----+-++---+/-! ### Tropical Satake observables -/
----+-++---+
----+-++---+/-- **Rank-1 profile**: tropical convolution with the standard representation `ω₁`.
----+-++---+
----+-++---+The weights of the standard representation of GL₃ are `e₁ = (1,0,0)`,
----+-++---+`e₂ = (0,1,0)`, `e₃ = (0,0,1)`. The rank-1 profile at `(a,b,c)` is
----+-++---+`max{f(a-1,b,c), f(a,b-1,c), f(a,b,c-1)}` with appropriate guards for ℕ subtraction.
----+-++---+
----+-++---+Note: Invalid shifts (where subtraction would go below 0) contribute the value `0`,
----+-++---+which serves as the tropical "zero" in this ℤ-valued model. -/
----+-++---+def rank1Profile (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
----+-++---+  let v1 := if 1 ≤ a then f (a - 1) b c else 0
----+-++---+  let v2 := if 1 ≤ b then f a (b - 1) c else 0
----+-++---+  let v3 := if 1 ≤ c then f a b (c - 1) else 0
----+-++---+  max v1 (max v2 v3)
----+-++---+
----+-++---+/-- **Rank-2 profile**: tropical convolution with the exterior square `ω₂ = ∧²`.
----+-++---+
----+-++---+The weights of `∧²(ℂ³)` are `e₁+e₂ = (1,1,0)`, `e₁+e₃ = (1,0,1)`,
----+-++---+`e₂+e₃ = (0,1,1)`. The rank-2 profile at `(a,b,c)` is
----+-++---+`max{f(a-1,b-1,c), f(a-1,b,c-1), f(a,b-1,c-1)}`. -/
----+-++---+def rank2Profile (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
----+-++---+  let v1 := if 1 ≤ a ∧ 1 ≤ b then f (a - 1) (b - 1) c else 0
----+-++---+  let v2 := if 1 ≤ a ∧ 1 ≤ c then f (a - 1) b (c - 1) else 0
----+-++---+  let v3 := if 1 ≤ b ∧ 1 ≤ c then f a (b - 1) (c - 1) else 0
----+-++---+  max v1 (max v2 v3)
----+-++---+
----+-++---+/-- **Edge moment**: tropical convolution with the determinant character `ω₃ = (1,1,1)`.
----+-++---+
----+-++---+This is the shift operator: `edgeMoment f (a,b,c) = f(a-1, b-1, c-1)`.
----+-++---+As a representation-theoretic operation, it corresponds to convolution with the
----+-++---+one-dimensional determinant representation `det = ∧³(ℂ³)`. Unlike the rank-1 and
----+-++---+rank-2 profiles (which use `max` and can lose information), the determinant
----+-++---+convolution perfectly preserves all function values.
----+-++---+
----+-++---+This is the key observable that makes finite determinacy possible: it acts as an
----+-++---+exact reconstruction tool rather than a lossy tropical projection. -/
----+-++---+def edgeMoment (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
----+-++---+  if 1 ≤ a ∧ 1 ≤ b ∧ 1 ≤ c then f (a - 1) (b - 1) (c - 1) else 0
----+-++---+
----+-++---+/-- Combined triple convolution observable using both rank-1 and rank-2 generators.
----+-++---+    This packages rank-1 and rank-2 data together for the combined hypothesis form. -/
----+-++---+def tripleConvObservable (f : ℕ → ℕ → ℕ → ℤ) (t s : ℕ × ℕ × ℕ) : ℤ :=
----+-++---+  rank1Profile f t.1 t.2.1 t.2.2 + rank2Profile f s.1 s.2.1 s.2.2
----+-++---+
----+-++---+/-! ### Finite test ranges -/
----+-++---+
----+-++---+/-- The finite range of rank-1 test parameters determined by box bound `B`. -/
----+-++---+def finiteRank1Range (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
----+-++---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
----+-++---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
----+-++---+
----+-++---+/-- The finite range of rank-2 test parameters determined by box bound `B`. -/
----+-++---+def finiteRank2Range (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
----+-++---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
----+-++---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
----+-++---+
----+-++---+/-- The finite range of edge moment test parameters determined by box bound `B`.
----+-++---+    These are the shifted dominant coweights `(a+1, b+1, c+1)` for `(a,b,c) ∈ BoxDom(B)`. -/
----+-++---+def finiteEdgeMomentRange (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
----+-++---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
----+-++---+    fun ⟨a, b, c⟩ => 1 ≤ c ∧ c ≤ b ∧ b ≤ a
----+-++---+
----+-++---+/-! ### Key computation lemmas -/
----+-++---+
----+-++---+/-- The edge moment at a shifted point exactly recovers the function value.
----+-++---+    This is the fundamental reconstruction identity. -/
----+-++---+@[simp]
----+-++---+lemma edgeMoment_succ (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) :
----+-++---+    edgeMoment f (a + 1) (b + 1) (c + 1) = f a b c := by
----+-++---+  simp [edgeMoment]
----+-++---+
----+-++---+/-- Shifted dominant coweights lie in the edge moment range. -/
----+-++---+lemma shifted_mem_finiteEdgeMomentRange {B a b c : ℕ}
----+-++---+    (haB : a ≤ B) (hab : b ≤ a) (hbc : c ≤ b) :
----+-++---+    (a + 1, b + 1, c + 1) ∈ finiteEdgeMomentRange B := by
----+-++---+  simp [finiteEdgeMomentRange, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
----+-++---+  omega
----+-++---+
----+-++---+/-- The rank-2 profile at the floor level `(a+1, b+1, 0)` yields `max(f(a,b,0), 0)`.
----+-++---+    When `f` is nonneg-valued on the floor, this equals `f(a,b,0)`.
----+-++---+    The `c = 0` case is special because both `ω₂`-weight shifts involving `c-1`
----+-++---+    fall outside `ℕ`, leaving only the `(1,1,0)`-weight shift. -/
----+-++---+lemma rank2Profile_floor_level (f : ℕ → ℕ → ℕ → ℤ) (a b : ℕ) :
----+-++---+    rank2Profile f (a + 1) (b + 1) 0 = max (f a b 0) 0 := by
----+-++---+  simp [rank2Profile]
----+-++---+
----+-++---+/-- For functions supported in `BoxDom(B)`, values at `a > B` vanish. -/
----+-++---+lemma FiniteSupportWithin.vanish_above {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
----+-++---+    (hf : FiniteSupportWithin B f) {a : ℕ} (ha : B < a) (b c : ℕ) :
----+-++---+    f a b c = 0 := by
----+-++---+  exact hf a b c (Or.inl ha)
----+-++---+
----+-++---+/-- For functions supported in `BoxDom(B)`, values outside dominant cone vanish. -/
----+-++---+lemma FiniteSupportWithin.vanish_nondominant {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
----+-++---+    (hf : FiniteSupportWithin B f) {a b c : ℕ} (h : a < b ∨ b < c) :
----+-++---+    f a b c = 0 := by
----+-++---+  exact hf a b c (by tauto)
----+-++---+
----+-++---+/-- Bounded-support functions vanish outside the box: explicit formulation. -/
----+-++---+lemma bounded_support_implies_vanishing_outside {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
----+-++---+    (hf : FiniteSupportWithin B f) {a b c : ℕ}
----+-++---+    (h : ¬(a ≤ B ∧ b ≤ a ∧ c ≤ b)) :
----+-++---+    f a b c = 0 := by
----+-++---+  apply hf; push_neg at h; omega+--- a/EML/Basic.lean
----+-++--++++ b/EML/Basic.lean
----+-++--+@@ -1,277 +1,125 @@
----+-++--+-/-
----+-++--+-Copyright (c) 2026 Harmonic. All rights reserved.
----+-++--+-Released under Apache 2.0 license as described in the file LICENSE.
----+-++--+--/
----+-++--+ import Mathlib
----+-++--+ 
----+-++--+-/-!
----+-++--+-# Pullback Stability of Universal Approximation
----+-++--++/-! # CatalogBuild.EML.Basic
----+-++--+ 
----+-++--+-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
----+-++--+-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
----+-++--+-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
----+-++--+-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
----+-++--+-
----+-++--+-This establishes a transport principle: universal approximation results (like
----+-++--+-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
----+-++--+-with the precise target being the fiber-constant functions.
----+-++--+-
----+-++--+-## Main definitions
----+-++--+-
----+-++--+-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
----+-++--+-  fibers of `φ`.
----+-++--+-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
----+-++--+-
----+-++--+-## Main results
----+-++--+-
----+-++--+-### Basic properties (§1)
----+-++--+-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
----+-++--+-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
----+-++--+-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
----+-++--+-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
----+-++--+-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
----+-++--+-
----+-++--+-### Factorization (§2)
----+-++--+-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
----+-++--+-  through `Set.range φ`, hence is a pullback (via Tietze extension).
----+-++--+-
----+-++--+-### Density transport (§3)
----+-++--+-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
----+-++--+-  subalgebra equals `FiberConst φ`.
----+-++--+-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
----+-++--+-
----+-++--+-### ε-approximation (§4)
----+-++--+-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
----+-++--+-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
----+-++--++Auto-generated from theorem catalog database.
----+-++--++Domain: EML
----+-++--++Declarations: 15
----+-++--+ -/
----+-++--+ 
----+-++--+-open scoped Topology
----+-++--+-open Topology
----+-++--++noncomputable section
----+-++--+ 
----+-++--+-variable {X Y : Type*}
----+-++--+-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
----+-++--+-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
----+-++--++/-- The inverse for hyperbolic SPB is also negation. -/
----+-++--++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
----+-++--++  simp [spbH]
----+-++--+ 
----+-++--+-/-! ### §1: Definitions and basic properties -/
----+-++--++/-- Wick duality: SPB with negated second argument equals the "difference"
----+-++--++in the hyperbolic SPB. This is the real-variable manifestation of the
----+-++--++Wick rotation t → it. -/
----+-++--++theorem wick_duality (x y : ℝ) :
----+-++--++    spb x (-y) = (x - y) / (1 + x * y) := by
----+-++--++  simp only [spb]
----+-++--++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
----+-++--++  rw [heq]; ring
----+-++--+ 
----+-++--+-/-- Continuous functions on `X` that are constant on fibers of `φ`.
----+-++--+-This is the natural functional-analytic object associated to a feature map:
----+-++--+-it captures exactly the observables visible through `φ`. -/
----+-++--+-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
----+-++--+-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
----+-++--+-  algebraMap_mem' r := by intro x x' _; simp
----+-++--+-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----+-++--+-  zero_mem' := by intro x x' _; simp
----+-++--+-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----+-++--+-  one_mem' := by intro x x' _; simp
----+-++--++/-- The tangent addition law IS the stereographic sum.
----+-++--++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
----+-++--++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
----+-++--++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
----+-++--++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
----+-++--++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
----+-++--++  field_simp
----+-++--+ 
----+-++--+-/-- Pullback of continuous real-valued functions along `φ`. -/
----+-++--+-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
----+-++--+-  toFun f := f.comp φ
----+-++--+-  map_zero' := by ext; simp
----+-++--+-  map_one' := by ext; simp
----+-++--+-  map_add' := by intros; ext; simp
----+-++--+-  map_mul' := by intros; ext; simp
----+-++--+-  commutes' := by intros; ext; simp
----+-++--++/-- SPB expression trees — analogous to EML expression trees. -/
----+-++--++inductive SPBExpr where
----+-++--++  | zero : SPBExpr
----+-++--++  | one : SPBExpr
----+-++--++  | var : ℕ → SPBExpr
----+-++--++  | node : SPBExpr → SPBExpr → SPBExpr
----+-++--++  deriving Repr, BEq
----+-++--+ 
----+-++--+-@[simp]
----+-++--+-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
----+-++--+-    pullbackAlg φ f x = f (φ x) := rfl
----+-++--++/-- Evaluate an SPB expression. -/
----+-++--++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
----+-++--++  match e with
----+-++--++  | .zero => 0
----+-++--++  | .one => 1
----+-++--++  | .var n => vars n
----+-++--++  | .node l r => spb (l.eval vars) (r.eval vars)
----+-++--+ 
----+-++--+-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
----+-++--+-    pullbackAlg φ f ∈ FiberConst φ := by
----+-++--+-  intro x x' h; simp [h]
----+-++--++/-- Depth of an SPB expression. -/
----+-++--++def SPBExpr.depth : SPBExpr → ℕ
----+-++--++  | .zero => 0
----+-++--++  | .one => 0
----+-++--++  | .var _ => 0
----+-++--++  | .node l r => 1 + max l.depth r.depth
----+-++--+ 
----+-++--+-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
----+-++--+-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----+-++--+-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
----+-++--++/-- Leaf count. -/
----+-++--++def SPBExpr.leafCount : SPBExpr → ℕ
----+-++--++  | .zero => 1
----+-++--++  | .one => 1
----+-++--++  | .var _ => 1
----+-++--++  | .node l r => l.leafCount + r.leafCount
----+-++--+ 
----+-++--+-theorem range_comp_subalgebra_subset_fiberConst
----+-++--+-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
----+-++--+-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----+-++--+-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
----+-++--++/-- Internal node count. -/
----+-++--++def SPBExpr.nodeCount : SPBExpr → ℕ
----+-++--++  | .zero => 0
----+-++--++  | .one => 0
----+-++--++  | .var _ => 0
----+-++--++  | .node l r => 1 + l.nodeCount + r.nodeCount
----+-++--+ 
----+-++--+-/-- `FiberConst φ` is closed in the uniform topology. -/
----+-++--+-theorem fiberConst_closed (φ : C(X, Y)) :
----+-++--+-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
----+-++--+-  refine isClosed_of_closure_subset ?_
----+-++--+-  intro g hg x x' h
----+-++--+-  rw [mem_closure_iff_nhds] at hg
----+-++--+-  contrapose! hg
----+-++--+-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
----+-++--+-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
----+-++--+-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
----+-++--++/-- Binary tree identity: leaves = internal nodes + 1. -/
----+-++--++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
----+-++--++    e.leafCount = e.nodeCount + 1 := by
----+-++--++  induction e with
----+-++--++  | zero => rfl
----+-++--++  | one => rfl
----+-++--++  | var _ => rfl
----+-++--++  | node l r ihl ihr =>
----+-++--++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
----+-++--++    omega
----+-++--+ 
----+-++--+-omit [T2Space X] [T2Space Y] in
----+-++--+-/-- The pullback map is norm-nonincreasing. -/
----+-++--+-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
----+-++--+-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
----+-++--+-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
----+-++--+-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
----+-++--++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
----+-++--++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
----+-++--+ 
----+-++--+-/-- When `φ` is surjective, pullback is an isometry. -/
----+-++--+-theorem pullback_isometry_of_surjective
----+-++--+-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
----+-++--+-    ‖pullbackAlg φ f‖ = ‖f‖ := by
----+-++--+-  refine le_antisymm (norm_pullback_le φ f) ?_
----+-++--+-  rw [ContinuousMap.norm_le _ (by positivity)]
----+-++--+-  intro y; obtain ⟨x, rfl⟩ := hφ y
----+-++--+-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
----+-++--++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
----+-++--++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
----+-++--++  unfold logisticSigmoid
----+-++--++  rw [Real.exp_neg]
----+-++--++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
----+-++--++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
----+-++--++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----+-++--++  field_simp; ring
----+-++--+ 
----+-++--+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----+-++--+-theorem mem_fiberConst_of_injective
----+-++--+-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
----+-++--+-    g ∈ FiberConst φ := by
----+-++--+-  intro x x' h; exact congrArg g (hφ h)
----+-++--++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
----+-++--++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
----+-++--++  unfold softplus logisticSigmoid
----+-++--++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
----+-++--++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
----+-++--++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
----+-++--++  simp at this
----+-++--++  exact this
----+-++--+ 
----+-++--+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----+-++--+-theorem fiberConst_eq_top_of_injective
----+-++--+-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
----+-++--+-    FiberConst φ = ⊤ := by
----+-++--+-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
----+-++--++/-- ShefferAlg is closed under affine pre-composition. -/
----+-++--++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
----+-++--++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
----+-++--++  obtain ⟨e, rfl⟩ := hf
----+-++--++  exact ⟨.affinePrecomp a b e, rfl⟩
----+-++--+ 
----+-++--+-omit [CompactSpace Y] [T2Space Y] in
----+-++--+-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
----+-++--+-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
----+-++--+-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
----+-++--+-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
----+-++--+-  intro x x' hφ; by_contra h_ne
----+-++--+-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
----+-++--+-    have := exists_continuous_zero_one_of_isClosed
----+-++--+-      (show IsClosed {x} from isClosed_singleton)
----+-++--+-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
----+-++--+-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
----+-++--+-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
----+-++--+-  replace h := SetLike.ext_iff.mp h g
----+-++--+-  simp_all +decide [FiberConst]
----+-++--+-  exact absurd (h hφ) (by simp +decide [hg])
----+-++--++/-- ShefferAlg is closed under affine combination. -/
----+-++--++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
----+-++--++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
----+-++--++  obtain ⟨ef, rfl⟩ := hf
----+-++--++  obtain ⟨eg, rfl⟩ := hg
----+-++--++  exact ⟨.affineComb α β γ ef eg, rfl⟩
----+-++--+ 
----+-++--+-/-! ### §2: Image factorization -/
----+-++--++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
----+-++--++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
----+-++--++  unfold softplus
----+-++--++  rw [Real.exp_neg]
----+-++--++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
----+-++--++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----+-++--++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
----+-++--++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
----+-++--++  rw [this, Real.log_exp]
----+-++--+ 
----+-++--+-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
----+-++--+-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
----+-++--+-
----+-++--+-/-
----+-++--+-The corestriction `X → Set.range φ` is a quotient map.
----+-++--+--/
----+-++--+-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
----+-++--+-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
----+-++--+-  apply IsClosedMap.isQuotientMap;
----+-++--+-  · intro s hs;
----+-++--+-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
----+-++--+-    constructor <;> intro h;
----+-++--+-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
----+-++--+-    · convert h.preimage ( continuous_subtype_val ) using 1;
----+-++--+-      ext; simp [Set.rangeFactorization];
----+-++--+-      grind;
----+-++--+-  · exact continuous_induced_rng.mpr φ.continuous;
----+-++--+-  · exact Set.rangeFactorization_surjective
----+-++--+-
----+-++--+-/-- Lift a fiber-constant function to `Set.range φ`. -/
----+-++--+-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
----+-++--+-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
----+-++--+-  toFun z := g z.property.choose
----+-++--+-  continuous_toFun := by
----+-++--+-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
----+-++--+-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
----+-++--+-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
----+-++--+-      ext x; apply hg
----+-++--+-      exact (Set.rangeFactorization φ x).property.choose_spec
----+-++--+-    rw [this]; exact g.continuous
----+-++--+-
----+-++--+-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
----+-++--+-    (hg : g ∈ FiberConst φ) (x : X) :
----+-++--+-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
----+-++--+-  simp only [fiberConstLift]
----+-++--+-  apply hg
----+-++--+-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
----+-++--+-
----+-++--+-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
----+-++--+-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
----+-++--+-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
----+-++--+-  intro g hg
----+-++--+-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
----+-++--+-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
----+-++--+-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
----+-++--+-  refine ⟨F, ?_⟩
----+-++--+-  ext x
----+-++--+-  simp only [pullbackAlg_apply]
----+-++--+-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
----+-++--+-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
----+-++--+-    simp [ContinuousMap.comp_apply] at this; exact this
----+-++--+-  rw [key, fiberConstLift_comp]
----+-++--+-
----+-++--+-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
----+-++--+-theorem fiberConst_eq_range_pullback_of_surjective
----+-++--+-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
----+-++--+-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
----+-++--+-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
----+-++--+-    (range_pullback_subset_fiberConst φ)
----+-++--+-
----+-++--+-/-! ### §3: Density transport -/
----+-++--+-
----+-++--+-/-
----+-++--+-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
----+-++--+--/
----+-++--+-theorem closure_range_pullback_eq_fiberConst
----+-++--+-    (φ : C(X, Y))
----+-++--+-    (A : Subalgebra ℝ C(Y, ℝ))
----+-++--+-    (hA : Dense (A : Set C(Y, ℝ))) :
----+-++--+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
----+-++--+-      = (FiberConst φ : Set C(X, ℝ)) := by
----+-++--+-  refine' le_antisymm ( closure_minimal _ _ ) _;
----+-++--+-  · exact range_comp_subalgebra_subset_fiberConst φ A;
----+-++--+-  · exact fiberConst_closed φ;
----+-++--+-  · intro g hg;
----+-++--+-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
----+-++--+-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
----+-++--+-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
----+-++--+-    rw [ Metric.mem_closure_iff ];
----+-++--+-    intro ε εpos;
----+-++--+-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
----+-++--+-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
----+-++--+-    nontriviality;
----+-++--+-    rw [ hF, dist_eq_norm ] at *;
----+-++--+-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
----+-++--+-
----+-++--+-/-
----+-++--+-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
----+-++--+--/
----+-++--+-theorem closure_range_pullback_eq_top_of_injective
----+-++--+-    (φ : C(X, Y))
----+-++--+-    (hφ : Function.Injective φ)
----+-++--+-    (A : Subalgebra ℝ C(Y, ℝ))
----+-++--+-    (hA : Dense (A : Set C(Y, ℝ))) :
----+-++--+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
----+-++--+-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
----+-++--+-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
----+-++--+-
----+-++--+-/-! ### §4: ε-approximation -/
----+-++--+-
----+-++--+-/-
----+-++--+-ε-approximation within `FiberConst φ`.
----+-++--+--/
----+-++--+-theorem exists_pullback_approx_of_fiberConst
----+-++--+-    (φ : C(X, Y))
----+-++--+-    (A : Subalgebra ℝ C(Y, ℝ))
----+-++--+-    (hA : Dense (A : Set C(Y, ℝ)))
----+-++--+-    (g : C(X, ℝ))
----+-++--+-    (hg : g ∈ FiberConst φ)
----+-++--+-    {ε : ℝ} (hε : 0 < ε) :
----+-++--+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----+-++--+-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
----+-++--+-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
----+-++--+-  rw [ Metric.mem_closure_iff ] at h_closure;
----+-++--+-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
----+-++--+-
----+-++--+-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
----+-++--+-theorem exists_pullback_approx_of_injective
----+-++--+-    (φ : C(X, Y))
----+-++--+-    (hφ : Function.Injective φ)
----+-++--+-    (A : Subalgebra ℝ C(Y, ℝ))
----+-++--+-    (hA : Dense (A : Set C(Y, ℝ)))
----+-++--+-    (g : C(X, ℝ))
----+-++--+-    {ε : ℝ} (hε : 0 < ε) :
----+-++--+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----+-++--+-  exact exists_pullback_approx_of_fiberConst φ A hA g
----+-++--+-    (mem_fiberConst_of_injective φ hφ g) hε+end+--- a/EML/Basic.lean
----+-++-++++ b/EML/Basic.lean
----+-++-+@@ -1,277 +1,125 @@
----+-++-+-/-
----+-++-+-Copyright (c) 2026 Harmonic. All rights reserved.
----+-++-+-Released under Apache 2.0 license as described in the file LICENSE.
----+-++-+--/
----+-++-+ import Mathlib
----+-++-+ 
----+-++-+-/-!
----+-++-+-# Pullback Stability of Universal Approximation
----+-++-++/-! # CatalogBuild.EML.Basic
----+-++-+ 
----+-++-+-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
----+-++-+-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
----+-++-+-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
----+-++-+-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
----+-++-+-
----+-++-+-This establishes a transport principle: universal approximation results (like
----+-++-+-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
----+-++-+-with the precise target being the fiber-constant functions.
----+-++-+-
----+-++-+-## Main definitions
----+-++-+-
----+-++-+-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
----+-++-+-  fibers of `φ`.
----+-++-+-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
----+-++-+-
----+-++-+-## Main results
----+-++-+-
----+-++-+-### Basic properties (§1)
----+-++-+-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
----+-++-+-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
----+-++-+-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
----+-++-+-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
----+-++-+-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
----+-++-+-
----+-++-+-### Factorization (§2)
----+-++-+-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
----+-++-+-  through `Set.range φ`, hence is a pullback (via Tietze extension).
----+-++-+-
----+-++-+-### Density transport (§3)
----+-++-+-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
----+-++-+-  subalgebra equals `FiberConst φ`.
----+-++-+-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
----+-++-+-
----+-++-+-### ε-approximation (§4)
----+-++-+-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
----+-++-+-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
----+-++-++Auto-generated from theorem catalog database.
----+-++-++Domain: EML
----+-++-++Declarations: 15
----+-++-+ -/
----+-++-+ 
----+-++-+-open scoped Topology
----+-++-+-open Topology
----+-++-++noncomputable section
----+-++-+ 
----+-++-+-variable {X Y : Type*}
----+-++-+-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
----+-++-+-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
----+-++-++/-- The inverse for hyperbolic SPB is also negation. -/
----+-++-++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
----+-++-++  simp [spbH]
----+-++-+ 
----+-++-+-/-! ### §1: Definitions and basic properties -/
----+-++-++/-- Wick duality: SPB with negated second argument equals the "difference"
----+-++-++in the hyperbolic SPB. This is the real-variable manifestation of the
----+-++-++Wick rotation t → it. -/
----+-++-++theorem wick_duality (x y : ℝ) :
----+-++-++    spb x (-y) = (x - y) / (1 + x * y) := by
----+-++-++  simp only [spb]
----+-++-++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
----+-++-++  rw [heq]; ring
----+-++-+ 
----+-++-+-/-- Continuous functions on `X` that are constant on fibers of `φ`.
----+-++-+-This is the natural functional-analytic object associated to a feature map:
----+-++-+-it captures exactly the observables visible through `φ`. -/
----+-++-+-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
----+-++-+-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
----+-++-+-  algebraMap_mem' r := by intro x x' _; simp
----+-++-+-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----+-++-+-  zero_mem' := by intro x x' _; simp
----+-++-+-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----+-++-+-  one_mem' := by intro x x' _; simp
----+-++-++/-- The tangent addition law IS the stereographic sum.
----+-++-++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
----+-++-++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
----+-++-++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
----+-++-++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
----+-++-++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
----+-++-++  field_simp
----+-++-+ 
----+-++-+-/-- Pullback of continuous real-valued functions along `φ`. -/
----+-++-+-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
----+-++-+-  toFun f := f.comp φ
----+-++-+-  map_zero' := by ext; simp
----+-++-+-  map_one' := by ext; simp
----+-++-+-  map_add' := by intros; ext; simp
----+-++-+-  map_mul' := by intros; ext; simp
----+-++-+-  commutes' := by intros; ext; simp
----+-++-++/-- SPB expression trees — analogous to EML expression trees. -/
----+-++-++inductive SPBExpr where
----+-++-++  | zero : SPBExpr
----+-++-++  | one : SPBExpr
----+-++-++  | var : ℕ → SPBExpr
----+-++-++  | node : SPBExpr → SPBExpr → SPBExpr
----+-++-++  deriving Repr, BEq
----+-++-+ 
----+-++-+-@[simp]
----+-++-+-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
----+-++-+-    pullbackAlg φ f x = f (φ x) := rfl
----+-++-++/-- Evaluate an SPB expression. -/
----+-++-++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
----+-++-++  match e with
----+-++-++  | .zero => 0
----+-++-++  | .one => 1
----+-++-++  | .var n => vars n
----+-++-++  | .node l r => spb (l.eval vars) (r.eval vars)
----+-++-+ 
----+-++-+-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
----+-++-+-    pullbackAlg φ f ∈ FiberConst φ := by
----+-++-+-  intro x x' h; simp [h]
----+-++-++/-- Depth of an SPB expression. -/
----+-++-++def SPBExpr.depth : SPBExpr → ℕ
----+-++-++  | .zero => 0
----+-++-++  | .one => 0
----+-++-++  | .var _ => 0
----+-++-++  | .node l r => 1 + max l.depth r.depth
----+-++-+ 
----+-++-+-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
----+-++-+-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----+-++-+-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
----+-++-++/-- Leaf count. -/
----+-++-++def SPBExpr.leafCount : SPBExpr → ℕ
----+-++-++  | .zero => 1
----+-++-++  | .one => 1
----+-++-++  | .var _ => 1
----+-++-++  | .node l r => l.leafCount + r.leafCount
----+-++-+ 
----+-++-+-theorem range_comp_subalgebra_subset_fiberConst
----+-++-+-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
----+-++-+-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----+-++-+-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
----+-++-++/-- Internal node count. -/
----+-++-++def SPBExpr.nodeCount : SPBExpr → ℕ
----+-++-++  | .zero => 0
----+-++-++  | .one => 0
----+-++-++  | .var _ => 0
----+-++-++  | .node l r => 1 + l.nodeCount + r.nodeCount
----+-++-+ 
----+-++-+-/-- `FiberConst φ` is closed in the uniform topology. -/
----+-++-+-theorem fiberConst_closed (φ : C(X, Y)) :
----+-++-+-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
----+-++-+-  refine isClosed_of_closure_subset ?_
----+-++-+-  intro g hg x x' h
----+-++-+-  rw [mem_closure_iff_nhds] at hg
----+-++-+-  contrapose! hg
----+-++-+-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
----+-++-+-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
----+-++-+-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
----+-++-++/-- Binary tree identity: leaves = internal nodes + 1. -/
----+-++-++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
----+-++-++    e.leafCount = e.nodeCount + 1 := by
----+-++-++  induction e with
----+-++-++  | zero => rfl
----+-++-++  | one => rfl
----+-++-++  | var _ => rfl
----+-++-++  | node l r ihl ihr =>
----+-++-++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
----+-++-++    omega
----+-++-+ 
----+-++-+-omit [T2Space X] [T2Space Y] in
----+-++-+-/-- The pullback map is norm-nonincreasing. -/
----+-++-+-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
----+-++-+-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
----+-++-+-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
----+-++-+-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
----+-++-++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
----+-++-++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
----+-++-+ 
----+-++-+-/-- When `φ` is surjective, pullback is an isometry. -/
----+-++-+-theorem pullback_isometry_of_surjective
----+-++-+-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
----+-++-+-    ‖pullbackAlg φ f‖ = ‖f‖ := by
----+-++-+-  refine le_antisymm (norm_pullback_le φ f) ?_
----+-++-+-  rw [ContinuousMap.norm_le _ (by positivity)]
----+-++-+-  intro y; obtain ⟨x, rfl⟩ := hφ y
----+-++-+-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
----+-++-++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
----+-++-++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
----+-++-++  unfold logisticSigmoid
----+-++-++  rw [Real.exp_neg]
----+-++-++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
----+-++-++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
----+-++-++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----+-++-++  field_simp; ring
----+-++-+ 
----+-++-+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----+-++-+-theorem mem_fiberConst_of_injective
----+-++-+-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
----+-++-+-    g ∈ FiberConst φ := by
----+-++-+-  intro x x' h; exact congrArg g (hφ h)
----+-++-++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
----+-++-++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
----+-++-++  unfold softplus logisticSigmoid
----+-++-++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
----+-++-++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
----+-++-++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
----+-++-++  simp at this
----+-++-++  exact this
----+-++-+ 
----+-++-+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----+-++-+-theorem fiberConst_eq_top_of_injective
----+-++-+-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
----+-++-+-    FiberConst φ = ⊤ := by
----+-++-+-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
----+-++-++/-- ShefferAlg is closed under affine pre-composition. -/
----+-++-++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
----+-++-++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
----+-++-++  obtain ⟨e, rfl⟩ := hf
----+-++-++  exact ⟨.affinePrecomp a b e, rfl⟩
----+-++-+ 
----+-++-+-omit [CompactSpace Y] [T2Space Y] in
----+-++-+-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
----+-++-+-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
----+-++-+-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
----+-++-+-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
----+-++-+-  intro x x' hφ; by_contra h_ne
----+-++-+-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
----+-++-+-    have := exists_continuous_zero_one_of_isClosed
----+-++-+-      (show IsClosed {x} from isClosed_singleton)
----+-++-+-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
----+-++-+-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
----+-++-+-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
----+-++-+-  replace h := SetLike.ext_iff.mp h g
----+-++-+-  simp_all +decide [FiberConst]
----+-++-+-  exact absurd (h hφ) (by simp +decide [hg])
----+-++-++/-- ShefferAlg is closed under affine combination. -/
----+-++-++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
----+-++-++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
----+-++-++  obtain ⟨ef, rfl⟩ := hf
----+-++-++  obtain ⟨eg, rfl⟩ := hg
----+-++-++  exact ⟨.affineComb α β γ ef eg, rfl⟩
----+-++-+ 
----+-++-+-/-! ### §2: Image factorization -/
----+-++-++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
----+-++-++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
----+-++-++  unfold softplus
----+-++-++  rw [Real.exp_neg]
----+-++-++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
----+-++-++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----+-++-++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
----+-++-++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
----+-++-++  rw [this, Real.log_exp]
----+-++-+ 
----+-++-+-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
----+-++-+-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
----+-++-+-
----+-++-+-/-
----+-++-+-The corestriction `X → Set.range φ` is a quotient map.
----+-++-+--/
----+-++-+-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
----+-++-+-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
----+-++-+-  apply IsClosedMap.isQuotientMap;
----+-++-+-  · intro s hs;
----+-++-+-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
----+-++-+-    constructor <;> intro h;
----+-++-+-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
----+-++-+-    · convert h.preimage ( continuous_subtype_val ) using 1;
----+-++-+-      ext; simp [Set.rangeFactorization];
----+-++-+-      grind;
----+-++-+-  · exact continuous_induced_rng.mpr φ.continuous;
----+-++-+-  · exact Set.rangeFactorization_surjective
----+-++-+-
----+-++-+-/-- Lift a fiber-constant function to `Set.range φ`. -/
----+-++-+-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
----+-++-+-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
----+-++-+-  toFun z := g z.property.choose
----+-++-+-  continuous_toFun := by
----+-++-+-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
----+-++-+-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
----+-++-+-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
----+-++-+-      ext x; apply hg
----+-++-+-      exact (Set.rangeFactorization φ x).property.choose_spec
----+-++-+-    rw [this]; exact g.continuous
----+-++-+-
----+-++-+-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
----+-++-+-    (hg : g ∈ FiberConst φ) (x : X) :
----+-++-+-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
----+-++-+-  simp only [fiberConstLift]
----+-++-+-  apply hg
----+-++-+-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
----+-++-+-
----+-++-+-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
----+-++-+-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
----+-++-+-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
----+-++-+-  intro g hg
----+-++-+-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
----+-++-+-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
----+-++-+-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
----+-++-+-  refine ⟨F, ?_⟩
----+-++-+-  ext x
----+-++-+-  simp only [pullbackAlg_apply]
----+-++-+-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
----+-++-+-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
----+-++-+-    simp [ContinuousMap.comp_apply] at this; exact this
----+-++-+-  rw [key, fiberConstLift_comp]
----+-++-+-
----+-++-+-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
----+-++-+-theorem fiberConst_eq_range_pullback_of_surjective
----+-++-+-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
----+-++-+-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
----+-++-+-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
----+-++-+-    (range_pullback_subset_fiberConst φ)
----+-++-+-
----+-++-+-/-! ### §3: Density transport -/
----+-++-+-
----+-++-+-/-
----+-++-+-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
----+-++-+--/
----+-++-+-theorem closure_range_pullback_eq_fiberConst
----+-++-+-    (φ : C(X, Y))
----+-++-+-    (A : Subalgebra ℝ C(Y, ℝ))
----+-++-+-    (hA : Dense (A : Set C(Y, ℝ))) :
----+-++-+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
----+-++-+-      = (FiberConst φ : Set C(X, ℝ)) := by
----+-++-+-  refine' le_antisymm ( closure_minimal _ _ ) _;
----+-++-+-  · exact range_comp_subalgebra_subset_fiberConst φ A;
----+-++-+-  · exact fiberConst_closed φ;
----+-++-+-  · intro g hg;
----+-++-+-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
----+-++-+-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
----+-++-+-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
----+-++-+-    rw [ Metric.mem_closure_iff ];
----+-++-+-    intro ε εpos;
----+-++-+-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
----+-++-+-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
----+-++-+-    nontriviality;
----+-++-+-    rw [ hF, dist_eq_norm ] at *;
----+-++-+-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
----+-++-+-
----+-++-+-/-
----+-++-+-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
----+-++-+--/
----+-++-+-theorem closure_range_pullback_eq_top_of_injective
----+-++-+-    (φ : C(X, Y))
----+-++-+-    (hφ : Function.Injective φ)
----+-++-+-    (A : Subalgebra ℝ C(Y, ℝ))
----+-++-+-    (hA : Dense (A : Set C(Y, ℝ))) :
----+-++-+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
----+-++-+-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
----+-++-+-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
----+-++-+-
----+-++-+-/-! ### §4: ε-approximation -/
----+-++-+-
----+-++-+-/-
----+-++-+-ε-approximation within `FiberConst φ`.
----+-++-+--/
----+-++-+-theorem exists_pullback_approx_of_fiberConst
----+-++-+-    (φ : C(X, Y))
----+-++-+-    (A : Subalgebra ℝ C(Y, ℝ))
----+-++-+-    (hA : Dense (A : Set C(Y, ℝ)))
----+-++-+-    (g : C(X, ℝ))
----+-++-+-    (hg : g ∈ FiberConst φ)
----+-++-+-    {ε : ℝ} (hε : 0 < ε) :
----+-++-+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----+-++-+-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
----+-++-+-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
----+-++-+-  rw [ Metric.mem_closure_iff ] at h_closure;
----+-++-+-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
----+-++-+-
----+-++-+-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
----+-++-+-theorem exists_pullback_approx_of_injective
----+-++-+-    (φ : C(X, Y))
----+-++-+-    (hφ : Function.Injective φ)
----+-++-+-    (A : Subalgebra ℝ C(Y, ℝ))
----+-++-+-    (hA : Dense (A : Set C(Y, ℝ)))
----+-++-+-    (g : C(X, ℝ))
----+-++-+-    {ε : ℝ} (hε : 0 < ε) :
----+-++-+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----+-++-+-  exact exists_pullback_approx_of_fiberConst φ A hA g
----+-++-+-    (mem_fiberConst_of_injective φ hφ g) hε+end+--- a/EML/Basic.lean
----+-++++++ b/EML/Basic.lean
----+-+++@@ -1,277 +1,125 @@
----+-+++-/-
----+-+++-Copyright (c) 2026 Harmonic. All rights reserved.
----+-+++-Released under Apache 2.0 license as described in the file LICENSE.
----+-+++--/
----+-+++ import Mathlib
----+-+++ 
----+-+++-/-!
----+-+++-# Pullback Stability of Universal Approximation
----+-++++/-! # CatalogBuild.EML.Basic
----+-+++ 
----+-+++-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
----+-+++-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
----+-+++-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
----+-+++-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
----+-+++-
----+-+++-This establishes a transport principle: universal approximation results (like
----+-+++-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
----+-+++-with the precise target being the fiber-constant functions.
----+-+++-
----+-+++-## Main definitions
----+-+++-
----+-+++-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
----+-+++-  fibers of `φ`.
----+-+++-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
----+-+++-
----+-+++-## Main results
----+-+++-
----+-+++-### Basic properties (§1)
----+-+++-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
----+-+++-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
----+-+++-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
----+-+++-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
----+-+++-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
----+-+++-
----+-+++-### Factorization (§2)
----+-+++-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
----+-+++-  through `Set.range φ`, hence is a pullback (via Tietze extension).
----+-+++-
----+-+++-### Density transport (§3)
----+-+++-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
----+-+++-  subalgebra equals `FiberConst φ`.
----+-+++-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
----+-+++-
----+-+++-### ε-approximation (§4)
----+-+++-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
----+-+++-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
----+-++++Auto-generated from theorem catalog database.
----+-++++Domain: EML
----+-++++Declarations: 15
----+-+ + -/
----+-+ + 
-+-+-+--
- -+-+--The main tropical/max-plus spectral theory development is in `Bridges/`.
- -+-+--See:
- -+-+--- `Bridges.MaxPlusDefs` - Core definitions
-@@ -12313,15 +1543,12 @@
- -++-+-+-Copyright (c) 2026 Harmonic. All rights reserved.
- -++-+-+-Released under Apache 2.0 license as described in the file LICENSE.
- -++-+-+--/
--- +-+-+ import Mathlib
--- +-+-+ 
----+-+-+ namespace SimpleGraph
-+-++-+-+ import Mathlib
-+-++-+-+ 
- -++-+-+-/-!
- -++-+-+-# Pullback Stability of Universal Approximation
- -++-+-++/-! # CatalogBuild.EML.Basic
--- +-+-+ 
----+-+-+-variable {V : Type*} {G : SimpleGraph V} {e : Sym2 V}
----+-+-++variable {V : Type*} {G : SimpleGraph V}
-+-++-+-+ 
- -++-+-+-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
- -++-+-+-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
- -++-+-+-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
-@@ -12362,51 +1589,18 @@
- -++-+-++Domain: EML
- -++-+-++Declarations: 15
- -++-+-+ -/
--- +-+-+ 
----+-+-+-/-! ### Trees have all bridges
----+-+-++/-! ### Deletion equivalence
-+-++-+-+ 
- -++-+-+-open scoped Topology
- -++-+-+-open Topology
- -++-+-++noncomputable section
--- +-+-+ 
----+-+-+-We prove that in a tree, every edge is a bridge. This follows from the
----+-+-+-characterization that an edge is a bridge iff it does not lie on any cycle,
----+-+-+-combined with the fact that trees are acyclic.
----+-+-++`G.deleteEdges s` and `G \ fromEdgeSet s` have the same adjacency and
----+-+-++hence the same reachability.  We prove the reachability equivalence
----+-+-++we need. -/
----+-+-++
----+-+-++/-
----+-+-++`deleteEdges {e}` and `G \ fromEdgeSet {e}` have the same reachability.
----+-+-+ -/
----+-+-++theorem reachable_deleteEdges_iff_reachable_sdiff {e : Sym2 V} {u v : V} :
----+-+-++    (G.deleteEdges {e}).Reachable u v ↔ (G \ fromEdgeSet {e}).Reachable u v := by
----+-+-++  constructor;
----+-+-++  · intro h;
----+-+-++    convert h.mono ?_;
----+-+-++    intro u v; aesop;
----+-+-++  · intro h;
----+-+-++    convert h
-+-++-+-+ 
- -++-+-+-variable {X Y : Type*}
- -++-+-+-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
- -++-+-+-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
- -++-+-++/-- The inverse for hyperbolic SPB is also negation. -/
- -++-+-++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
- -++-+-++  simp [spbH]
--- +-+-+ 
----+-+-+-/-- In an acyclic graph, every edge is a bridge. Since there are no cycles,
----+-+-+-no edge can lie on a cycle, which is precisely the bridge characterization. -/
----+-+-+-theorem IsAcyclic.isBridge_of_mem_edgeSet (hAcyclic : G.IsAcyclic)
----+-+-+-    (he : e ∈ G.edgeSet) : G.IsBridge e := by
----+-+-+-  rw [isBridge_iff_mem_and_forall_cycle_notMem]
----+-+-+-  exact ⟨he, fun u p hp => absurd hp (hAcyclic p)⟩
----+-+-++/-- Bridge characterization using `deleteEdges` instead of `sdiff`. -/
----+-+-++theorem isBridge_iff_deleteEdges {u v : V} :
----+-+-++    G.IsBridge s(u, v) ↔ G.Adj u v ∧ ¬(G.deleteEdges {s(u, v)}).Reachable u v := by
----+-+-++  rw [isBridge_iff]
----+-+-++  exact ⟨
----+-+-++    fun ⟨h1, h2⟩ => ⟨h1, fun hr => h2 (reachable_deleteEdges_iff_reachable_sdiff.mp hr)⟩,
----+-+-++    fun ⟨h1, h2⟩ => ⟨h1, fun hr => h2 (reachable_deleteEdges_iff_reachable_sdiff.mpr hr)⟩⟩
-+-++-+-+ 
- -++-+-+-/-! ### §1: Definitions and basic properties -/
- -++-+-++/-- Wick duality: SPB with negated second argument equals the "difference"
- -++-+-++in the hyperbolic SPB. This is the real-variable manifestation of the
-@@ -12416,13 +1610,7 @@
- -++-+-++  simp only [spb]
- -++-+-++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
- -++-+-++  rw [heq]; ring
--- +-+-+ 
----+-+-+-/-- In a tree, every edge is a bridge. This is a direct consequence of
----+-+-+-acyclicity: since no cycles exist, no edge can participate in a cycle. -/
----+-+-+-theorem IsTree.isBridge_of_mem_edgeSet (hTree : G.IsTree)
----+-+-+-    (he : e ∈ G.edgeSet) : G.IsBridge e :=
----+-+-+-  hTree.IsAcyclic.isBridge_of_mem_edgeSet he
----+-+-++/-! ### Bridge fundamentals -/
-+-++-+-+ 
- -++-+-+-/-- Continuous functions on `X` that are constant on fibers of `φ`.
- -++-+-+-This is the natural functional-analytic object associated to a feature map:
- -++-+-+-it captures exactly the observables visible through `φ`. -/
-@@ -12440,16 +1628,7 @@
- -++-+-++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
- -++-+-++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
- -++-+-++  field_simp
--- +-+-+ 
----+-+-+-/-! ### Connected graphs with all bridges are trees
----+-+-++/-- The endpoints of a bridge lie in different connected components
----+-+-++after the bridge is deleted. -/
----+-+-++theorem IsBridge.connectedComponent_ne_deleteEdges {u v : V}
----+-+-++    (hb : G.IsBridge s(u, v)) :
----+-+-++    (G.deleteEdges {s(u, v)}).connectedComponentMk u ≠
----+-+-++    (G.deleteEdges {s(u, v)}).connectedComponentMk v := by
----+-+-++  rw [Ne, ConnectedComponent.eq]
----+-+-++  exact (isBridge_iff_deleteEdges.mp hb).2
-+-++-+-+ 
- -++-+-+-/-- Pullback of continuous real-valued functions along `φ`. -/
- -++-+-+-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
- -++-+-+-  toFun f := f.comp φ
-@@ -12465,27 +1644,7 @@
- -++-+-++  | var : ℕ → SPBExpr
- -++-+-++  | node : SPBExpr → SPBExpr → SPBExpr
- -++-+-++  deriving Repr, BEq
--- +-+-+ 
----+-+-+-We prove the converse: if a connected graph has the property that every
----+-+-+-edge is a bridge, then it must be acyclic (and hence a tree).
----+-+-++/-! ### Bridge splitting: every vertex goes to one side -/
----+-+-++
----+-+-++/-
----+-+-++In a connected graph, after removing a bridge {u,v}, every vertex
----+-+-++is reachable from either u or v (but not both, since u and v are separated).
----+-+-++This shows the bridge partitions the vertex set into exactly two parts.
----+-+-+ -/
----+-+-++theorem IsBridge.forall_reachable_delete_left_or_right
----+-+-++    (hconn : G.Connected) {u v : V} (hb : G.IsBridge s(u, v)) (w : V) :
----+-+-++    (G.deleteEdges {s(u, v)}).Reachable u w ∨
----+-+-++    (G.deleteEdges {s(u, v)}).Reachable v w := by
----+-+-++  obtain ⟨ p ⟩ := hconn w u;
----+-+-++  induction' p with w' w'' p ih;
----+-+-++  · exact Or.inl ( SimpleGraph.Reachable.refl _ );
----+-+-++  · cases' eq_or_ne w'' ih with h h <;> cases' eq_or_ne w'' v with h' h' <;> simp_all +decide [ SimpleGraph.isBridge_iff ];
----+-+-++    cases' ‹ ( G.deleteEdges { s(ih, v) } ).Reachable ih p ∨ ( G.deleteEdges { s(ih, v) } ).Reachable v p › with h'' h'' <;> [ left; right ] <;> refine' h''.trans _ <;> simp_all +decide [ SimpleGraph.deleteEdges ];
----+-+-++    · exact SimpleGraph.Adj.reachable ( by aesop ) |> SimpleGraph.Reachable.symm;
----+-+-++    · exact SimpleGraph.Reachable.symm ( SimpleGraph.Adj.reachable ( by aesop ) )
-+-++-+-+ 
- -++-+-+-@[simp]
- -++-+-+-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
- -++-+-+-    pullbackAlg φ f x = f (φ x) := rfl
-@@ -12496,9 +1655,7 @@
- -++-+-++  | .one => 1
- -++-+-++  | .var n => vars n
- -++-+-++  | .node l r => spb (l.eval vars) (r.eval vars)
--- +-+-+ 
----+-+-+-/-- If every edge of a graph is a bridge, then the graph is acyclic.
----+-+-++/-! ### Two connected components -/
-+-++-+-+ 
- -++-+-+-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
- -++-+-+-    pullbackAlg φ f ∈ FiberConst φ := by
- -++-+-+-  intro x x' h; simp [h]
-@@ -12508,53 +1665,7 @@
- -++-+-++  | .one => 0
- -++-+-++  | .var _ => 0
- -++-+-++  | .node l r => 1 + max l.depth r.depth
--- +-+-+ 
----+-+-+-**Proof sketch**: Suppose for contradiction there exists a cycle `c`.
----+-+-+-Since `c` is not nil, it has at least one edge `e`. This edge lies in the
----+-+-+-edge set of `G`, so by hypothesis it is a bridge. But bridges cannot lie
----+-+-+-on any cycle (by `isBridge_iff_mem_and_forall_cycle_notMem`), contradicting
----+-+-+-that `e` lies on `c`. -/
----+-+-+-theorem isAcyclic_of_forall_isBridge
----+-+-+-    (h : ∀ e ∈ G.edgeSet, G.IsBridge e) : G.IsAcyclic := by
----+-+-+-  intro v c hc
----+-+-+-  -- A cycle must have at least one edge
----+-+-+-  have hne : c.edges ≠ [] := by
----+-+-+-    intro he
----+-+-+-    cases c with
----+-+-+-    | nil => exact hc.ne_nil rfl
----+-+-+-    | cons _ _ => simp [Walk.edges_cons] at he
----+-+-+-  obtain ⟨e, he⟩ := List.exists_mem_of_ne_nil _ hne
----+-+-+-  have he_mem : e ∈ G.edgeSet := Walk.edges_subset_edgeSet _ he
----+-+-+-  have hbridge := h e he_mem
----+-+-+-  rw [isBridge_iff_mem_and_forall_cycle_notMem] at hbridge
----+-+-+-  exact hbridge.2 c hc he
----+-+-++/-
----+-+-++Removing a bridge from a connected graph produces exactly two
----+-+-++connected components. This is a fundamental structural result about
----+-+-++bridges, showing that a bridge literally "bridges" two otherwise
----+-+-++disconnected parts of the graph.
----+-+-++-/
----+-+-++theorem IsBridge.two_connected_components [DecidableEq V] [Fintype V]
----+-+-++    [DecidableRel G.Adj]
----+-+-++    (hconn : G.Connected) {u v : V} (hb : G.IsBridge s(u, v)) :
----+-+-++    Fintype.card (G.deleteEdges {s(u, v)}).ConnectedComponent = 2 := by
----+-+-++  convert Set.ncard_eq_two.mpr _;
----+-+-++  rotate_left;
----+-+-++  exact ( G.deleteEdges { s(u, v) } ).ConnectedComponent;
----+-+-++  exact Set.range ( fun w => ( G.deleteEdges { s(u, v) } ).connectedComponentMk w );
----+-+-++  · refine' ⟨ _, _, _, _ ⟩;
----+-+-++    exact ( G.deleteEdges { s(u, v) } ).connectedComponentMk u;
----+-+-++    exact ( G.deleteEdges { s(u, v) } ).connectedComponentMk v;
----+-+-++    · exact connectedComponent_ne_deleteEdges hb;
----+-+-++    · ext w;
----+-+-++      obtain ⟨ x, rfl ⟩ := w.exists_rep;
----+-+-++      have := hb.forall_reachable_delete_left_or_right hconn x;
----+-+-++      cases this <;> simp_all +decide [ SimpleGraph.connectedComponentMk ];
----+-+-++      · exact Or.inl ( Quot.sound ‹_› |> Eq.symm );
----+-+-++      · exact Or.inr ( Quot.sound <| by tauto );
----+-+-++  · rw [ Set.ncard_eq_toFinset_card _ ];
----+-+-++    refine' Finset.card_bij ( fun x _ => x ) _ _ _ <;> simp +decide;
----+-+-++    exact fun a => a.exists_rep
-+-++-+-+ 
- -++-+-+-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
- -++-+-+-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
- -++-+-+-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
-@@ -12564,10 +1675,7 @@
- -++-+-++  | .one => 1
- -++-+-++  | .var _ => 1
- -++-+-++  | .node l r => l.leafCount + r.leafCount
--- +-+-+ 
----+-+-+-/-- **Tree-Bridge Equivalence Theorem.**
----+-+-+-A graph is a tree if and only if it is connected and every edge is a bridge.
----+-+-++/-! ### Trees and bridges -/
-+-++-+-+ 
- -++-+-+-theorem range_comp_subalgebra_subset_fiberConst
- -++-+-+-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
- -++-+-+-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-@@ -12578,20 +1686,7 @@
- -++-+-++  | .one => 0
- -++-+-++  | .var _ => 0
- -++-+-++  | .node l r => 1 + l.nodeCount + r.nodeCount
--- +-+-+ 
----+-+-+-This is a fundamental characterization of trees: they are precisely the
----+-+-+-connected graphs that are "minimally connected" — removing any single
----+-+-+-edge disconnects the graph.
----+-+-++/-
----+-+-++Every edge of a tree is a bridge. In a tree, every edge is critical
----+-+-++for connectivity — removing any edge disconnects the tree.
----+-+-++-/
----+-+-++theorem IsTree.isBridge_of_adj (hT : G.IsTree) {u v : V} (hadj : G.Adj u v) :
----+-+-++    G.IsBridge s(u, v) := by
----+-+-++  -- By definition of a tree, it is acyclic.
----+-+-++  have h_acyclic : G.IsAcyclic := by
----+-+-++    exact hT.2;
----+-+-++  rw [ SimpleGraph.isAcyclic_iff_forall_adj_isBridge ] at h_acyclic ; aesop
-+-++-+-+ 
- -++-+-+-/-- `FiberConst φ` is closed in the uniform topology. -/
- -++-+-+-theorem fiberConst_closed (φ : C(X, Y)) :
- -++-+-+-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
-@@ -12612,44 +1707,7 @@
- -++-+-++  | node l r ihl ihr =>
- -++-+-++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
- -++-+-++    omega
--- +-+-+ 
----+-+-+-### Forward direction
----+-+-+-In a tree (connected + acyclic), every edge is a bridge because there are
----+-+-+-no cycles, so no edge can lie on a cycle.
----+++-+-/-- Lift a fiber-constant function to `Set.range φ`. -/
----+++-+-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
----+++-+-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
----+++-+-  toFun z := g z.property.choose
----+++-+-  continuous_toFun := by
----+++-+-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
----+++-+-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
----+++-+-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
----+++-+-      ext x; apply hg
----+++-+-      exact (Set.rangeFactorization φ x).property.choose_spec
----+++-+-    rw [this]; exact g.continuous
----+ +-+-
----+-+-+-### Reverse direction
----+-+-+-If every edge is a bridge, the graph must be acyclic: any cycle would contain
----+-+-+-an edge that both lies on a cycle and is a bridge, which is a contradiction. -/
----+-+-+-theorem isTree_iff_connected_and_forall_isBridge :
----+-+-+-    G.IsTree ↔ G.Connected ∧ ∀ e ∈ G.edgeSet, G.IsBridge e := by
----+-+-+-  constructor
----+-+-+-  · intro hTree
----+-+-+-    exact ⟨hTree.isConnected, fun e he => hTree.isBridge_of_mem_edgeSet he⟩
----+-+-+-  · intro ⟨hConn, hBridge⟩
----+-+-+-    exact ⟨hConn, isAcyclic_of_forall_isBridge hBridge⟩
----+-+-++/-
----+-+-++A connected graph is a tree if and only if every edge is a bridge.
----+-+-++This provides a characterization of trees in terms of edge criticality.
----+-+-++-/
----+-+-++theorem connected_isBridge_all_iff_isTree (hconn : G.Connected) :
----+-+-++    (∀ ⦃u v : V⦄, G.Adj u v → G.IsBridge s(u, v)) ↔ G.IsTree := by
----+-+-++  constructor;
----+-+-++  · intro h;
----+-+-++    constructor;
----+-+-++    · assumption;
----+-+-++    · exact isAcyclic_iff_forall_adj_isBridge.mpr h;
----+-+-++  · exact fun a ⦃u v⦄ a_1 => IsTree.isBridge_of_adj a a_1
-+-++-+-+ 
- -++-+-+-omit [T2Space X] [T2Space Y] in
- -++-+-+-/-- The pullback map is norm-nonincreasing. -/
- -++-+-+-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
-@@ -12658,813 +1716,8 @@
- -++-+-+-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
- -++-+-++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
- -++-+-++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
--- +-+-+ 
----+-+-+ end SimpleGraph++-open scoped Topology
----+-+++-open Topology
----+-++++noncomputable section
----+-+++ 
----+-+++-variable {X Y : Type*}
----+-+++-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
----+-+++-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
----+-++++/-- The inverse for hyperbolic SPB is also negation. -/
----+-++++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
----+-++++  simp [spbH]
----+-+++ 
----+-+++-/-! ### §1: Definitions and basic properties -/
----+-++++/-- Wick duality: SPB with negated second argument equals the "difference"
----+-++++in the hyperbolic SPB. This is the real-variable manifestation of the
----+-++++Wick rotation t → it. -/
----+-++++theorem wick_duality (x y : ℝ) :
----+-++++    spb x (-y) = (x - y) / (1 + x * y) := by
----+-++++  simp only [spb]
----+-++++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
----+-++++  rw [heq]; ring
----+-+++ 
----+-+++-/-- Continuous functions on `X` that are constant on fibers of `φ`.
----+-+++-This is the natural functional-analytic object associated to a feature map:
----+-+++-it captures exactly the observables visible through `φ`. -/
----+-+++-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
----+-+++-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
----+-+++-  algebraMap_mem' r := by intro x x' _; simp
----+-+++-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----+-+++-  zero_mem' := by intro x x' _; simp
----+-+++-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----+-+++-  one_mem' := by intro x x' _; simp
----+-++++/-- The tangent addition law IS the stereographic sum.
----+-++++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
----+-++++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
----+-++++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
----+-++++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
----+-++++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
----+-++++  field_simp
----+-+++ 
----+-+++-/-- Pullback of continuous real-valued functions along `φ`. -/
----+-+++-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
----+-+++-  toFun f := f.comp φ
----+-+++-  map_zero' := by ext; simp
----+-+++-  map_one' := by ext; simp
----+-+++-  map_add' := by intros; ext; simp
----+-+++-  map_mul' := by intros; ext; simp
----+-+++-  commutes' := by intros; ext; simp
----+-++++/-- SPB expression trees — analogous to EML expression trees. -/
----+-++++inductive SPBExpr where
----+-++++  | zero : SPBExpr
----+-++++  | one : SPBExpr
----+-++++  | var : ℕ → SPBExpr
----+-++++  | node : SPBExpr → SPBExpr → SPBExpr
----+-++++  deriving Repr, BEq
----+-+++ 
----+-+++-@[simp]
----+-+++-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
----+-+++-    pullbackAlg φ f x = f (φ x) := rfl
----+-++++/-- Evaluate an SPB expression. -/
----+-++++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
----+-++++  match e with
----+-++++  | .zero => 0
----+-++++  | .one => 1
----+-++++  | .var n => vars n
----+-++++  | .node l r => spb (l.eval vars) (r.eval vars)
----+-+++ 
----+-+++-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
----+-+++-    pullbackAlg φ f ∈ FiberConst φ := by
----+-+++-  intro x x' h; simp [h]
----+-++++/-- Depth of an SPB expression. -/
----+-++++def SPBExpr.depth : SPBExpr → ℕ
----+-++++  | .zero => 0
----+-++++  | .one => 0
----+-++++  | .var _ => 0
----+-++++  | .node l r => 1 + max l.depth r.depth
----+-+++ 
----+-+++-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
----+-+++-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----+-+++-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
----+-++++/-- Leaf count. -/
----+-++++def SPBExpr.leafCount : SPBExpr → ℕ
----+-++++  | .zero => 1
----+-++++  | .one => 1
----+-++++  | .var _ => 1
----+-++++  | .node l r => l.leafCount + r.leafCount
----+-+++ 
----+-+++-theorem range_comp_subalgebra_subset_fiberConst
----+-+++-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
----+-+++-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----+-+++-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
----+-++++/-- Internal node count. -/
----+-++++def SPBExpr.nodeCount : SPBExpr → ℕ
----+-++++  | .zero => 0
----+-++++  | .one => 0
----+-++++  | .var _ => 0
----+-++++  | .node l r => 1 + l.nodeCount + r.nodeCount
----+-+++ 
----+-+++-/-- `FiberConst φ` is closed in the uniform topology. -/
----+-+++-theorem fiberConst_closed (φ : C(X, Y)) :
----+-+++-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
----+-+++-  refine isClosed_of_closure_subset ?_
----+-+++-  intro g hg x x' h
----+-+++-  rw [mem_closure_iff_nhds] at hg
----+-+++-  contrapose! hg
----+-+++-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
----+-+++-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
----+-+++-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
----+-++++/-- Binary tree identity: leaves = internal nodes + 1. -/
----+-++++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
----+-++++    e.leafCount = e.nodeCount + 1 := by
----+-++++  induction e with
----+-++++  | zero => rfl
----+-++++  | one => rfl
----+-++++  | var _ => rfl
----+-++++  | node l r ihl ihr =>
----+-++++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
----+-++++    omega
----+-+++ 
----+-+++-omit [T2Space X] [T2Space Y] in
----+-+++-/-- The pullback map is norm-nonincreasing. -/
----+-+++-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
----+-+++-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
----+-+++-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
----+-+++-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
----+-++++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
----+-++++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
----+-+++ 
----+-+++-/-- When `φ` is surjective, pullback is an isometry. -/
----+-+++-theorem pullback_isometry_of_surjective
----+-+++-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
----+-+++-    ‖pullbackAlg φ f‖ = ‖f‖ := by
----+-+++-  refine le_antisymm (norm_pullback_le φ f) ?_
----+-+++-  rw [ContinuousMap.norm_le _ (by positivity)]
----+-+++-  intro y; obtain ⟨x, rfl⟩ := hφ y
----+-+++-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
----+-++++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
----+-++++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
----+-++++  unfold logisticSigmoid
----+-++++  rw [Real.exp_neg]
----+-++++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
----+-++++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
----+-++++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----+-++++  field_simp; ring
----+-+++ 
----+-+++-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----+-+++-theorem mem_fiberConst_of_injective
----+-+++-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
----+-+++-    g ∈ FiberConst φ := by
----+-+++-  intro x x' h; exact congrArg g (hφ h)
----+-++++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
----+-++++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
----+-++++  unfold softplus logisticSigmoid
----+-++++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
----+-++++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
----+-++++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
----+-++++  simp at this
----+-++++  exact this
----+-+++ 
----+-+++-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----+-+++-theorem fiberConst_eq_top_of_injective
----+-+++-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
----+-+++-    FiberConst φ = ⊤ := by
----+-+++-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
----+-++++/-- ShefferAlg is closed under affine pre-composition. -/
----+-++++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
----+-++++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
----+-++++  obtain ⟨e, rfl⟩ := hf
----+-++++  exact ⟨.affinePrecomp a b e, rfl⟩
----+-+++ 
----+-+++-omit [CompactSpace Y] [T2Space Y] in
----+-+++-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
----+-+++-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
----+-+++-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
----+-+++-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
----+-+++-  intro x x' hφ; by_contra h_ne
----+-+++-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
----+-+++-    have := exists_continuous_zero_one_of_isClosed
----+-+++-      (show IsClosed {x} from isClosed_singleton)
----+-+++-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
----+-+++-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
----+-+++-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
----+-+++-  replace h := SetLike.ext_iff.mp h g
----+-+++-  simp_all +decide [FiberConst]
----+-+++-  exact absurd (h hφ) (by simp +decide [hg])
----+-++++/-- ShefferAlg is closed under affine combination. -/
----+-++++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
----+-++++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
----+-++++  obtain ⟨ef, rfl⟩ := hf
----+-++++  obtain ⟨eg, rfl⟩ := hg
----+-++++  exact ⟨.affineComb α β γ ef eg, rfl⟩
----+-+++ 
----+-+++-/-! ### §2: Image factorization -/
----+-++++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
----+-++++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
----+-++++  unfold softplus
----+-++++  rw [Real.exp_neg]
----+-++++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
----+-++++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----+-++++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
----+-++++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
----+-++++  rw [this, Real.log_exp]
----+-+++ 
----+-+++-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
----+-+++-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
----+-+++-
----+-+++-/-
----+-+++-The corestriction `X → Set.range φ` is a quotient map.
----+-+++--/
----+-+++-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
----+-+++-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
----+-+++-  apply IsClosedMap.isQuotientMap;
----+-+++-  · intro s hs;
----+-+++-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
----+-+++-    constructor <;> intro h;
----+-+++-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
----+-+++-    · convert h.preimage ( continuous_subtype_val ) using 1;
----+-+++-      ext; simp [Set.rangeFactorization];
----+-+++-      grind;
----+-+++-  · exact continuous_induced_rng.mpr φ.continuous;
----+-+++-  · exact Set.rangeFactorization_surjective
----+-+++-
----+-+++-/-- Lift a fiber-constant function to `Set.range φ`. -/
----+-+++-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
----+-+++-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
----+-+++-  toFun z := g z.property.choose
----+-+++-  continuous_toFun := by
----+-+++-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
----+-+++-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
----+-+++-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
----+-+++-      ext x; apply hg
----+-+++-      exact (Set.rangeFactorization φ x).property.choose_spec
----+-+++-    rw [this]; exact g.continuous
----+-+++-
----+-+++-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
----+-+++-    (hg : g ∈ FiberConst φ) (x : X) :
----+-+++-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
----+-+++-  simp only [fiberConstLift]
----+-+++-  apply hg
----+-+++-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
----+-+++-
----+-+++-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
----+-+++-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
----+-+++-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
----+-+++-  intro g hg
----+-+++-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
----+-+++-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
----+-+++-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
----+-+++-  refine ⟨F, ?_⟩
----+-+++-  ext x
----+-+++-  simp only [pullbackAlg_apply]
----+-+++-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
----+-+++-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
----+-+++-    simp [ContinuousMap.comp_apply] at this; exact this
----+-+++-  rw [key, fiberConstLift_comp]
----+-+++-
----+-+++-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
----+-+++-theorem fiberConst_eq_range_pullback_of_surjective
----+-+++-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
----+-+++-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
----+-+++-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
----+-+++-    (range_pullback_subset_fiberConst φ)
----+-+++-
----+-+++-/-! ### §3: Density transport -/
----+-+++-
----+-+++-/-
----+-+++-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
----+-+++--/
----+-+++-theorem closure_range_pullback_eq_fiberConst
----+-+++-    (φ : C(X, Y))
----+-+++-    (A : Subalgebra ℝ C(Y, ℝ))
----+-+++-    (hA : Dense (A : Set C(Y, ℝ))) :
----+-+++-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
----+-+++-      = (FiberConst φ : Set C(X, ℝ)) := by
----+-+++-  refine' le_antisymm ( closure_minimal _ _ ) _;
----+-+++-  · exact range_comp_subalgebra_subset_fiberConst φ A;
----+-+++-  · exact fiberConst_closed φ;
----+-+++-  · intro g hg;
----+-+++-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
----+-+++-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
----+-+++-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
----+-+++-    rw [ Metric.mem_closure_iff ];
----+-+++-    intro ε εpos;
----+-+++-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
----+-+++-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
----+-+++-    nontriviality;
----+-+++-    rw [ hF, dist_eq_norm ] at *;
----+-+++-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
----+-+++-
----+-+++-/-
----+-+++-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
----+-+++--/
----+-+++-theorem closure_range_pullback_eq_top_of_injective
----+-+++-    (φ : C(X, Y))
----+-+++-    (hφ : Function.Injective φ)
----+-+++-    (A : Subalgebra ℝ C(Y, ℝ))
----+-+++-    (hA : Dense (A : Set C(Y, ℝ))) :
----+-+++-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
----+-+++-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
----+-+++-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
----+-+++-
----+-+++-/-! ### §4: ε-approximation -/
----+-+++-
----+-+++-/-
----+-+++-ε-approximation within `FiberConst φ`.
----+-+++--/
----+-+++-theorem exists_pullback_approx_of_fiberConst
----+-+++-    (φ : C(X, Y))
----+-+++-    (A : Subalgebra ℝ C(Y, ℝ))
----+-+++-    (hA : Dense (A : Set C(Y, ℝ)))
----+-+++-    (g : C(X, ℝ))
----+-+++-    (hg : g ∈ FiberConst φ)
----+-+++-    {ε : ℝ} (hε : 0 < ε) :
----+-+++-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----+-+++-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
----+-+++-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
----+-+++-  rw [ Metric.mem_closure_iff ] at h_closure;
----+-+++-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
----+-+++-
----+-+++-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
----+-+++-theorem exists_pullback_approx_of_injective
----+-+++-    (φ : C(X, Y))
----+-+++-    (hφ : Function.Injective φ)
----+-+++-    (A : Subalgebra ℝ C(Y, ℝ))
----+-+++-    (hA : Dense (A : Set C(Y, ℝ)))
----+-+++-    (g : C(X, ℝ))
----+-+++-    {ε : ℝ} (hε : 0 < ε) :
----+-+++-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----+-+++-  exact exists_pullback_approx_of_fiberConst φ A hA g
----+-+++-    (mem_fiberConst_of_injective φ hφ g) hε+end++-+-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
----+++-+-    (hg : g ∈ FiberConst φ) (x : X) :
----+++-+-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
----+++-+-  simp only [fiberConstLift]
----+++-+-  apply hg
----+++-+-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
----+++-+-
----+++-+-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
----+++-+-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
----+++-+-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
----+++-+-  intro g hg
----+++-+-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
----+++-+-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
----+++-+-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
----+++-+-  refine ⟨F, ?_⟩
----+++-+-  ext x
----+++-+-  simp only [pullbackAlg_apply]
----+++-+-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
----+++-+-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
----+++-+-    simp [ContinuousMap.comp_apply] at this; exact this
----+++-+-  rw [key, fiberConstLift_comp]
----+++-+-
----+++-+-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
----+++-+-theorem fiberConst_eq_range_pullback_of_surjective
----+++-+-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
----+++-+-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
----+++-+-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
----+++-+-    (range_pullback_subset_fiberConst φ)
----+++-+-
----+++-+-/-! ### §3: Density transport -/
----+++-+-
----+++-+-/-
----+++-+-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
----+++-+--/
----+++-+-theorem closure_range_pullback_eq_fiberConst
----+++-+-    (φ : C(X, Y))
----+++-+-    (A : Subalgebra ℝ C(Y, ℝ))
----+++-+-    (hA : Dense (A : Set C(Y, ℝ))) :
----+++-+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
----+++-+-      = (FiberConst φ : Set C(X, ℝ)) := by
----+++-+-  refine' le_antisymm ( closure_minimal _ _ ) _;
----+++-+-  · exact range_comp_subalgebra_subset_fiberConst φ A;
----+++-+-  · exact fiberConst_closed φ;
----+++-+-  · intro g hg;
----+++-+-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
----+++-+-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
----+++-+-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
----+++-+-    rw [ Metric.mem_closure_iff ];
----+++-+-    intro ε εpos;
----+++-+-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
----+++-+-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
----+++-+-    nontriviality;
----+++-+-    rw [ hF, dist_eq_norm ] at *;
----+++-+-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
----+++-+-
----+++-+-/-
----+++-+-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
----+++-+--/
----+++-+-theorem closure_range_pullback_eq_top_of_injective
----+++-+-    (φ : C(X, Y))
----+++-+-    (hφ : Function.Injective φ)
----+++-+-    (A : Subalgebra ℝ C(Y, ℝ))
----+++-+-    (hA : Dense (A : Set C(Y, ℝ))) :
----+++-+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
----+++-+-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
----+++-+-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
----+++-+-
----+++-+-/-! ### §4: ε-approximation -/
----+++-+-
----+++-+-/-
----+++-+-ε-approximation within `FiberConst φ`.
----+++-+--/
----+++-+-theorem exists_pullback_approx_of_fiberConst
----+++-+-    (φ : C(X, Y))
----+++-+-    (A : Subalgebra ℝ C(Y, ℝ))
----+++-+-    (hA : Dense (A : Set C(Y, ℝ)))
----+++-+-    (g : C(X, ℝ))
----+++-+-    (hg : g ∈ FiberConst φ)
----+++-+-    {ε : ℝ} (hε : 0 < ε) :
----+++-+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----+++-+-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
----+++-+-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
----+++-+-  rw [ Metric.mem_closure_iff ] at h_closure;
----+++-+-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
----+++-+-
----+++-+-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
----+++-+-theorem exists_pullback_approx_of_injective
----+++-+-    (φ : C(X, Y))
----+++-+-    (hφ : Function.Injective φ)
----+++-+-    (A : Subalgebra ℝ C(Y, ℝ))
----+++-+-    (hA : Dense (A : Set C(Y, ℝ)))
----+++-+-    (g : C(X, ℝ))
----+++-+-    {ε : ℝ} (hε : 0 < ε) :
----+++-+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----+++-+-  exact exists_pullback_approx_of_fiberConst φ A hA g
----+++-+-    (mem_fiberConst_of_injective φ hφ g) hε+end+--- a/EML/Basic.lean
----+++++++ b/EML/Basic.lean
----++++@@ -1,277 +1,125 @@
----++++-/-
----++++-Copyright (c) 2026 Harmonic. All rights reserved.
----++++-Released under Apache 2.0 license as described in the file LICENSE.
----++++--/
----++++ import Mathlib
----++++ 
----++++-/-!
----++++-# Pullback Stability of Universal Approximation
----+++++/-! # CatalogBuild.EML.Basic
----++++ 
----++++-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
----++++-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
----++++-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
----++++-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
----++++-
----++++-This establishes a transport principle: universal approximation results (like
----++++-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
----++++-with the precise target being the fiber-constant functions.
----++++-
----++++-## Main definitions
----++++-
----++++-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
----++++-  fibers of `φ`.
----++++-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
----++++-
----++++-## Main results
----++++-
----++++-### Basic properties (§1)
----++++-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
----++++-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
----++++-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
----++++-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
----++++-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
----++++-
----++++-### Factorization (§2)
----++++-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
----++++-  through `Set.range φ`, hence is a pullback (via Tietze extension).
----++++-
----++++-### Density transport (§3)
----++++-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
----++++-  subalgebra equals `FiberConst φ`.
----++++-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
----++++-
----++++-### ε-approximation (§4)
----++++-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
----++++-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
----+++++Auto-generated from theorem catalog database.
----+++++Domain: EML
----+++++Declarations: 15
----++++ -/
----++++ 
----++++-open scoped Topology
----++++-open Topology
----+++++noncomputable section
----++++ 
----++++-variable {X Y : Type*}
----++++-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
----++++-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
----+++++/-- The inverse for hyperbolic SPB is also negation. -/
----+++++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
----+++++  simp [spbH]
----++++ 
----++++-/-! ### §1: Definitions and basic properties -/
----+++++/-- Wick duality: SPB with negated second argument equals the "difference"
----+++++in the hyperbolic SPB. This is the real-variable manifestation of the
----+++++Wick rotation t → it. -/
----+++++theorem wick_duality (x y : ℝ) :
----+++++    spb x (-y) = (x - y) / (1 + x * y) := by
----+++++  simp only [spb]
----+++++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
----+++++  rw [heq]; ring
----++++ 
----++++-/-- Continuous functions on `X` that are constant on fibers of `φ`.
----++++-This is the natural functional-analytic object associated to a feature map:
----++++-it captures exactly the observables visible through `φ`. -/
----++++-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
----++++-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
----++++-  algebraMap_mem' r := by intro x x' _; simp
----++++-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----++++-  zero_mem' := by intro x x' _; simp
----++++-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
----++++-  one_mem' := by intro x x' _; simp
----+++++/-- The tangent addition law IS the stereographic sum.
----+++++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
----+++++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
----+++++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
----+++++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
----+++++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
----+++++  field_simp
----++++ 
----++++-/-- Pullback of continuous real-valued functions along `φ`. -/
----++++-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
----++++-  toFun f := f.comp φ
----++++-  map_zero' := by ext; simp
----++++-  map_one' := by ext; simp
----++++-  map_add' := by intros; ext; simp
----++++-  map_mul' := by intros; ext; simp
----++++-  commutes' := by intros; ext; simp
----+++++/-- SPB expression trees — analogous to EML expression trees. -/
----+++++inductive SPBExpr where
----+++++  | zero : SPBExpr
----+++++  | one : SPBExpr
----+++++  | var : ℕ → SPBExpr
----+++++  | node : SPBExpr → SPBExpr → SPBExpr
----+++++  deriving Repr, BEq
----++++ 
----++++-@[simp]
----++++-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
----++++-    pullbackAlg φ f x = f (φ x) := rfl
----+++++/-- Evaluate an SPB expression. -/
----+++++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
----+++++  match e with
----+++++  | .zero => 0
----+++++  | .one => 1
----+++++  | .var n => vars n
----+++++  | .node l r => spb (l.eval vars) (r.eval vars)
----++++ 
----++++-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
----++++-    pullbackAlg φ f ∈ FiberConst φ := by
----++++-  intro x x' h; simp [h]
----+++++/-- Depth of an SPB expression. -/
----+++++def SPBExpr.depth : SPBExpr → ℕ
----+++++  | .zero => 0
----+++++  | .one => 0
----+++++  | .var _ => 0
----+++++  | .node l r => 1 + max l.depth r.depth
----++++ 
----++++-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
----++++-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----++++-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
----+++++/-- Leaf count. -/
----+++++def SPBExpr.leafCount : SPBExpr → ℕ
----+++++  | .zero => 1
----+++++  | .one => 1
----+++++  | .var _ => 1
----+++++  | .node l r => l.leafCount + r.leafCount
----++++ 
----++++-theorem range_comp_subalgebra_subset_fiberConst
----++++-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
----++++-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
----++++-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
----+++++/-- Internal node count. -/
----+++++def SPBExpr.nodeCount : SPBExpr → ℕ
----+++++  | .zero => 0
----+++++  | .one => 0
----+++++  | .var _ => 0
----+++++  | .node l r => 1 + l.nodeCount + r.nodeCount
----++++ 
----++++-/-- `FiberConst φ` is closed in the uniform topology. -/
----++++-theorem fiberConst_closed (φ : C(X, Y)) :
----++++-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
----++++-  refine isClosed_of_closure_subset ?_
----++++-  intro g hg x x' h
----++++-  rw [mem_closure_iff_nhds] at hg
----++++-  contrapose! hg
----++++-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
----++++-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
----++++-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
----+++++/-- Binary tree identity: leaves = internal nodes + 1. -/
----+++++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
----+++++    e.leafCount = e.nodeCount + 1 := by
----+++++  induction e with
----+++++  | zero => rfl
----+++++  | one => rfl
----+++++  | var _ => rfl
----+++++  | node l r ihl ihr =>
----+++++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
----+++++    omega
----++++ 
----++++-omit [T2Space X] [T2Space Y] in
----++++-/-- The pullback map is norm-nonincreasing. -/
----++++-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
----++++-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
----++++-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
----++++-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
----+++++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
----+++++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
----++++ 
----++++-/-- When `φ` is surjective, pullback is an isometry. -/
----++++-theorem pullback_isometry_of_surjective
----++++-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
----++++-    ‖pullbackAlg φ f‖ = ‖f‖ := by
----++++-  refine le_antisymm (norm_pullback_le φ f) ?_
----++++-  rw [ContinuousMap.norm_le _ (by positivity)]
----++++-  intro y; obtain ⟨x, rfl⟩ := hφ y
----++++-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
----+++++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
----+++++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
----+++++  unfold logisticSigmoid
----+++++  rw [Real.exp_neg]
----+++++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
----+++++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
----+++++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----+++++  field_simp; ring
----++++ 
----++++-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----++++-theorem mem_fiberConst_of_injective
----++++-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
----++++-    g ∈ FiberConst φ := by
----++++-  intro x x' h; exact congrArg g (hφ h)
----+++++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
----+++++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
----+++++  unfold softplus logisticSigmoid
----+++++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
----+++++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
----+++++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
----+++++  simp at this
----+++++  exact this
----++++ 
----++++-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
----++++-theorem fiberConst_eq_top_of_injective
----++++-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
----++++-    FiberConst φ = ⊤ := by
----++++-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
----+++++/-- ShefferAlg is closed under affine pre-composition. -/
----+++++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
----+++++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
----+++++  obtain ⟨e, rfl⟩ := hf
----+++++  exact ⟨.affinePrecomp a b e, rfl⟩
----++++ 
----++++-omit [CompactSpace Y] [T2Space Y] in
----++++-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
----++++-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
----++++-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
----++++-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
----++++-  intro x x' hφ; by_contra h_ne
----++++-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
----++++-    have := exists_continuous_zero_one_of_isClosed
----++++-      (show IsClosed {x} from isClosed_singleton)
----++++-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
----++++-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
----++++-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
----++++-  replace h := SetLike.ext_iff.mp h g
----++++-  simp_all +decide [FiberConst]
----++++-  exact absurd (h hφ) (by simp +decide [hg])
----+++++/-- ShefferAlg is closed under affine combination. -/
----+++++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
----+++++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
----+++++  obtain ⟨ef, rfl⟩ := hf
----+++++  obtain ⟨eg, rfl⟩ := hg
----+++++  exact ⟨.affineComb α β γ ef eg, rfl⟩
----++++ 
----++++-/-! ### §2: Image factorization -/
----+++++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
----+++++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
----+++++  unfold softplus
----+++++  rw [Real.exp_neg]
----+++++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
----+++++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----+++++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
----+++++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
----+++++  rw [this, Real.log_exp]
----++++ 
----++++-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
----++++-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
----++++-
----++++-/-
----++++-The corestriction `X → Set.range φ` is a quotient map.
----++++--/
----++++-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
----++++-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
----++++-  apply IsClosedMap.isQuotientMap;
----++++-  · intro s hs;
----++++-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
----++++-    constructor <;> intro h;
----++++-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
----++++-    · convert h.preimage ( continuous_subtype_val ) using 1;
----++++-      ext; simp [Set.rangeFactorization];
----++++-      grind;
----++++-  · exact continuous_induced_rng.mpr φ.continuous;
----++++-  · exact Set.rangeFactorization_surjective
----++++-
----++++-/-- Lift a fiber-constant function to `Set.range φ`. -/
----++++-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
----++++-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
----++++-  toFun z := g z.property.choose
----++++-  continuous_toFun := by
----++++-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
----++++-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
----++++-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
----++++-      ext x; apply hg
----++++-      exact (Set.rangeFactorization φ x).property.choose_spec
----++++-    rw [this]; exact g.continuous
----++++-
----++++-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
----++++-    (hg : g ∈ FiberConst φ) (x : X) :
----++++-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
----++++-  simp only [fiberConstLift]
----++++-  apply hg
----++++-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
----++++-
----++++-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
----++++-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
----++++-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
----++++-  intro g hg
----++++-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
----++++-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
----++++-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
----++++-  refine ⟨F, ?_⟩
----++++-  ext x
----++++-  simp only [pullbackAlg_apply]
----++++-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
----++++-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
----++++-    simp [ContinuousMap.comp_apply] at this; exact this
----++++-  rw [key, fiberConstLift_comp]
----++++-
----++++-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
----++++-theorem fiberConst_eq_range_pullback_of_surjective
----++++-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
----++++-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
----++++-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
----++++-    (range_pullback_subset_fiberConst φ)
----++++-
----++++-/-! ### §3: Density transport -/
----++++-
----++++-/-
----++++-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
----++++--/
----++++-theorem closure_range_pullback_eq_fiberConst
----++++-    (φ : C(X, Y))
----++++-    (A : Subalgebra ℝ C(Y, ℝ))
----++++-    (hA : Dense (A : Set C(Y, ℝ))) :
----++++-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
----++++-      = (FiberConst φ : Set C(X, ℝ)) := by
----++++-  refine' le_antisymm ( closure_minimal _ _ ) _;
----++++-  · exact range_comp_subalgebra_subset_fiberConst φ A;
----++++-  · exact fiberConst_closed φ;
----++++-  · intro g hg;
----++++-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
----++++-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
----++++-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
----++++-    rw [ Metric.mem_closure_iff ];
----++++-    intro ε εpos;
----++++-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
----++++-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
----++++-    nontriviality;
----++++-    rw [ hF, dist_eq_norm ] at *;
----++++-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
----++++-
----++++-/-
----++++-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
----++++--/
----++++-theorem closure_range_pullback_eq_top_of_injective
----++++-    (φ : C(X, Y))
----++++-    (hφ : Function.Injective φ)
----++++-    (A : Subalgebra ℝ C(Y, ℝ))
----++++-    (hA : Dense (A : Set C(Y, ℝ))) :
----++++-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
----++++-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
----++++-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
----++++-
----++++-/-! ### §4: ε-approximation -/
----++++-
----++++-/-
----++++-ε-approximation within `FiberConst φ`.
----++++--/
----++++-theorem exists_pullback_approx_of_fiberConst
----++++-    (φ : C(X, Y))
----++++-    (A : Subalgebra ℝ C(Y, ℝ))
----++++-    (hA : Dense (A : Set C(Y, ℝ)))
----++++-    (g : C(X, ℝ))
----++++-    (hg : g ∈ FiberConst φ)
----++++-    {ε : ℝ} (hε : 0 < ε) :
----++++-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----++++-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
----++++-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
----++++-  rw [ Metric.mem_closure_iff ] at h_closure;
----++++-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
----++++-
----++++-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
----++++-theorem exists_pullback_approx_of_injective
----++++-    (φ : C(X, Y))
----++++-    (hφ : Function.Injective φ)
----++++-    (A : Subalgebra ℝ C(Y, ℝ))
----++++-    (hA : Dense (A : Set C(Y, ℝ)))
----++++-    (g : C(X, ℝ))
----++++-    {ε : ℝ} (hε : 0 < ε) :
----++++-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
----++++-  exact exists_pullback_approx_of_fiberConst φ A hA g
----++++-    (mem_fiberConst_of_injective φ hφ g) hε+end++-+-+-/-- When `φ` is surjective, pullback is an isometry. -/
-+-++-+-+ 
-+-++-+-+-/-- When `φ` is surjective, pullback is an isometry. -/
- -++-+-+-theorem pullback_isometry_of_surjective
- -++-+-+-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
- -++-+-+-    ‖pullbackAlg φ f‖ = ‖f‖ := by
-@@ -16834,6 +5087,239 @@
- -+-++++Declarations: 15
- -+-+ + -/
- -+-+ + 
-++--- a/Logic/Basic.lean
-+++++ b/Logic/Basic.lean
-++@@ -1,2162 +1,3640 @@
-++ --- a/MachineLearning/Basic.lean
-++ +++ b/MachineLearning/Basic.lean
-++-@@ -1,219 +1,1941 @@
-++--/-
-++--Copyright (c) 2025 Harmonic. All rights reserved.
-++--Released under Apache 2.0 license as described in the file LICENSE.
-++---/
-++--import Mathlib
-++--
-++--/-!
-++--# Gradient Descent Convergence Theory
-++--
-++--This file formalizes the convergence theory of gradient descent for strongly convex
-++--quadratic functions, establishing the fundamental result that underpins optimization
-++--in machine learning.
-++--
-++--## Main Results
-++--
-++--* `gd_error_eq` — The error of gradient descent on a quadratic `f(x) = (a/2)x²`
-++--  with step size `η` satisfies `e_n = (1 - ηa)^n · e_0`
-++--* `gd_contraction_factor_lt_one` — The contraction factor `|1 - ηa| < 1` when
-++--  `0 < η < 2/a`
-++--* `gd_converges` — Gradient descent converges: `x_n → x*`
-++--* `gd_geometric_rate` — The convergence rate is geometric:
-++--  `|x_n - x*| ≤ |1 - ηa|^n · |x_0 - x*|`
-++--* `gd_optimal_step` — The optimal step size is `η = 1/a`, giving convergence in one step
-++--* `gd_condition_number_bound` — For 2D quadratics with eigenvalues `μ ≤ L`,
-++--  the optimal convergence rate is `(κ-1)/(κ+1)` where `κ = L/μ`
-++--
-++--## References
-++--
-++--* Nesterov, Y. (2004). *Introductory Lectures on Convex Optimization*
-++--* Boyd, S. & Vandenberghe, L. (2004). *Convex Optimization*
-++---/
-++--
-++--open Filter Topology Real
-++--
-++--noncomputable section
-++--
-++--/-!
-++--## Part 1: Geometric Convergence of Linear Recurrences
-++--
-++--We first establish that sequences satisfying `x_{n+1} = r · x_n` converge geometrically
-++--when `|r| < 1`. This is the mathematical core of gradient descent convergence.
-++---/
-++--
-++--/-
-++--A geometric sequence `r^n * x₀` with `|r| < 1` converges to zero.
-++---/
-++--theorem geom_seq_tendsto_zero {r x₀ : ℝ} (hr : |r| < 1) :
-++--    Tendsto (fun n => r ^ n * x₀) atTop (nhds 0) := by
-++--      simpa using tendsto_pow_atTop_nhds_zero_of_abs_lt_one hr |> Filter.Tendsto.mul_const x₀
-++--
-++--/-
-++--Geometric bound: `|r^n * x₀| ≤ |r|^n * |x₀|`.
-++---/
-++--theorem geom_seq_abs_bound (r x₀ : ℝ) (n : ℕ) :
-++--    |r ^ n * x₀| = |r| ^ n * |x₀| := by
-++--      rw [ abs_mul, abs_pow ]
-++--
-++--/-
-++--If `|r| < 1`, then `|r|^n → 0`.
-++---/
-++--theorem geom_decay {r : ℝ} (hr : |r| < 1) :
-++--    Tendsto (fun n => |r| ^ n) atTop (nhds 0) := by
-++--      exact tendsto_pow_atTop_nhds_zero_of_lt_one ( abs_nonneg r ) hr
-++--
-++--/-!
-++--## Part 2: Gradient Descent on Quadratic Functions
-++--
-++--We formalize gradient descent on the 1D quadratic `f(x) = (a/2) · x²` with `a > 0`.
-++--The gradient is `f'(x) = a · x`, and the GD update is:
-++--
-++--  `x_{n+1} = x_n - η · a · x_n = (1 - η·a) · x_n`
-++--
-++--The minimizer is `x* = 0`, so the error is `e_n = x_n - 0 = x_n`.
-++---/
-++--
-++--/-- The gradient descent iteration for `f(x) = (a/2)x²`:
-++--    `gd_step a η x = x - η * (a * x) = (1 - η * a) * x` -/
-++--def gd_step (a η : ℝ) (x : ℝ) : ℝ := x - η * (a * x)
-++--
-++--/-- The n-th iterate of gradient descent starting from `x₀`. -/
-++--def gd_iterate (a η : ℝ) (x₀ : ℝ) : ℕ → ℝ
-++--  | 0 => x₀
-++--  | n + 1 => gd_step a η (gd_iterate a η x₀ n)
-++--
-++--/-- The gradient descent step simplifies to multiplication by `(1 - η * a)`. -/
-++--theorem gd_step_eq (a η x : ℝ) : gd_step a η x = (1 - η * a) * x := by
-++--  unfold gd_step; ring
-++--
-++--/-
-++--The n-th GD iterate equals `(1 - η*a)^n * x₀`.
-++---/
-++--theorem gd_iterate_eq (a η x₀ : ℝ) (n : ℕ) :
-++--    gd_iterate a η x₀ n = (1 - η * a) ^ n * x₀ := by
-++--      induction' n with n ih;
-++--      · aesop;
-++--      · convert congr_arg ( fun x => ( 1 - η * a ) * x ) ih using 1 <;> ring;
-++--        rw [ add_comm, show gd_iterate a η x₀ ( n + 1 ) = gd_step a η ( gd_iterate a η x₀ n ) by rfl, gd_step_eq ] ; ring
-++--
-++--/-!
-++--## Part 3: Convergence Analysis
-++--
-++--The key insight: gradient descent converges when the contraction factor `|1 - η·a|`
-++--is strictly less than 1, which holds precisely when `0 < η < 2/a`.
-++---/
-++--
-++--/-
-++--The contraction factor `|1 - η*a| < 1` when `0 < η*a < 2`.
-++---/
-++--theorem contraction_factor_lt_one {η a : ℝ} (hηa_pos : 0 < η * a) (hηa_lt : η * a < 2) :
-++--    |1 - η * a| < 1 := by
-++--      exact abs_lt.mpr ⟨ by linarith, by linarith ⟩
-++--
-++--/-
-++--When `a > 0` and `0 < η < 2/a`, we have `0 < η*a < 2`.
-++---/
-++--theorem step_size_valid {a η : ℝ} (ha : 0 < a) (hη_pos : 0 < η) (hη_lt : η < 2 / a) :
-++--    0 < η * a ∧ η * a < 2 := by
-++--      constructor <;> nlinarith [ mul_div_cancel₀ 2 ha.ne' ]
-++--
-++--/-
-++--**Main convergence theorem**: Gradient descent on `f(x) = (a/2)x²` converges
-++--    to the minimizer `x* = 0` when the step size satisfies `0 < η < 2/a`.
-++---/
-++--theorem gd_converges {a η : ℝ} (ha : 0 < a) (hη_pos : 0 < η) (hη_lt : η < 2 / a)
-++--    (x₀ : ℝ) : Tendsto (gd_iterate a η x₀) atTop (nhds 0) := by
-++--      -- Use `gd_iterate_eq` to rewrite the sequence as `(1 - η * a) ^ n * x₀`.
-++--      have h_seq_eq : ∀ n, gd_iterate a η x₀ n = (1 - η * a) ^ n * x₀ :=
-++--        fun n => gd_iterate_eq a η x₀ n
-++--      rw [ show gd_iterate a η x₀ = _ from funext h_seq_eq ] ; exact geom_seq_tendsto_zero ( by rw [ abs_lt ] ; constructor <;> nlinarith [ mul_div_cancel₀ 2 ha.ne' ] )
-++--
-++--/-
-++--**Geometric convergence rate**: `|x_n| ≤ |1 - ηa|^n · |x₀|`.
-++---/
-++--theorem gd_geometric_rate (a η x₀ : ℝ) (n : ℕ) :
-++--    |gd_iterate a η x₀ n| = |1 - η * a| ^ n * |x₀| := by
-++--      rw [ gd_iterate_eq, abs_mul, abs_pow ]
-++--
-++--/-
-++--**Optimal step size**: When `η = 1/a`, gradient descent converges in one step:
-++--    the contraction factor is 0, so `x₁ = 0`.
-++---/
-++--theorem gd_optimal_one_step {a : ℝ} (ha : 0 < a) (x₀ : ℝ) :
-++--    gd_iterate a (1 / a) x₀ 1 = 0 := by
-++--      exact show x₀ - 1 / a * ( a * x₀ ) = 0 from by ring_nf; norm_num [ ha.ne' ] ;
-++--
-++--/-
-++--For `η = 1/a`, all iterates after the first are 0.
-++---/
-++--theorem gd_optimal_all_zero {a : ℝ} (ha : 0 < a) (x₀ : ℝ) (n : ℕ) (hn : 0 < n) :
-++--    gd_iterate a (1 / a) x₀ n = 0 := by
-++--      convert gd_iterate_eq a ( 1 / a ) x₀ n using 1 ; norm_num [ ha.ne' ];
-++--      aesop
-++--
-++--/-!
-++--## Part 4: Condition Number and Two-Dimensional Analysis
-++--
-++--For the 2D quadratic `f(x,y) = (a/2)x² + (b/2)y²` with `0 < μ ≤ L` (eigenvalues),
-++--the optimal step size is `η = 2/(μ + L)` and the convergence rate is
-++--`(L - μ)/(L + μ) = (κ - 1)/(κ + 1)` where `κ = L/μ` is the condition number.
-++---/
-++--
-++--/-- The condition number `κ = L/μ` for eigenvalues `μ ≤ L`. -/
-++--def conditionNumber (μ L : ℝ) : ℝ := L / μ
-++--
-++--/-- The optimal convergence rate for a 2D quadratic with eigenvalues `μ` and `L`. -/
-++--def optimalRate (μ L : ℝ) : ℝ := (L - μ) / (L + μ)
-++--
-++--/-
-++--The optimal convergence rate equals `(κ-1)/(κ+1)`.
-++---/
-++--theorem optimal_rate_eq_condition {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
-++--    optimalRate μ L = (conditionNumber μ L - 1) / (conditionNumber μ L + 1) := by
-++--      unfold optimalRate conditionNumber;
-++--      grind
-++--
-++--/-
-++--The optimal rate is in `[0, 1)` when `0 < μ ≤ L`.
-++---/
-++--theorem optimal_rate_nonneg {μ L : ℝ} (hμ : 0 < μ) (hμL : μ ≤ L) :
-++--    0 ≤ optimalRate μ L := by
-++--      exact div_nonneg ( by linarith ) ( by linarith )
-++--
-++--theorem optimal_rate_lt_one {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
-++--    optimalRate μ L < 1 := by
-++--      exact div_lt_one ( by positivity ) |>.2 ( by linarith )
-++--
-++--/-
-++--Well-conditioned problems (κ ≈ 1) converge fast: rate = 0 when μ = L.
-++---/
-++--theorem optimal_rate_well_conditioned (μ : ℝ) :
-++--    optimalRate μ μ = 0 := by
-++--      unfold optimalRate; ring
-++--
-++--/-- The optimal step size for a 2D quadratic is `2/(μ + L)`. -/
-++--def optimalStepSize (μ L : ℝ) : ℝ := 2 / (μ + L)
-++--
-++--/-
-++--With the optimal step size `η = 2/(μ+L)`, the contraction factors for
-++--    both coordinates are `±(L-μ)/(L+μ)`, giving the optimal rate.
-++---/
-++--theorem optimal_step_contraction_small {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
-++--    1 - optimalStepSize μ L * μ = optimalRate μ L := by
-++--      unfold optimalStepSize optimalRate; rw [ div_mul_eq_mul_div, one_sub_div ] ; ring ; positivity;
-++--
-++--theorem optimal_step_contraction_large {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
-++--    1 - optimalStepSize μ L * L = -(optimalRate μ L) := by
-++--      grind +locals
-++--
-++--/-
-++--**Fundamental bound**: The number of iterations needed to reduce error by factor ε
-++--    is proportional to κ · log(1/ε), where κ is the condition number. This is captured
-++--    by the fact that log(1/rate) ≈ 2/κ for large κ.
-++---/
-++--theorem iteration_complexity_bound {μ L : ℝ} (hμ : 0 < μ) (hμL : μ ≤ L) :
-++--    optimalRate μ L ≤ 1 - 2 / (conditionNumber μ L + 1) := by
-++--      unfold optimalRate conditionNumber;
-++--      rw [ one_sub_div, div_le_div_iff₀ ] <;> nlinarith [ mul_div_cancel₀ L hμ.ne' ]
-++--
-++--end+--- a/MachineLearning/Basic.lean
-++-++++ b/MachineLearning/Basic.lean
-++-+@@ -1,241 +1,1700 @@
-++-+---- a/Bridges/Basic.lean
-++-+-+++ b/Bridges/Basic.lean
-++-+-@@ -1,11 +1,228 @@
-++-+--/-!
-++-+--# Tropical Algebra Placeholder
-++-+--
- +-+--The main tropical/max-plus spectral theory development is in `Bridges/`.
- +-+--See:
- +-+--- `Bridges.MaxPlusDefs` - Core definitions+--- a/MachineLearning/Basic.lean
++++ b/MachineLearning/Basic.lean
+@@ -1,1941 +1,1700 @@
+---- a/MachineLearning/Basic.lean
+-+++ b/MachineLearning/Basic.lean
+-@@ -1,241 +1,1700 @@
+----- a/Bridges/Basic.lean
+--+++ b/Bridges/Basic.lean
+--@@ -1,11 +1,228 @@
+---/-!
+---# Tropical Algebra Placeholder
+---
+---The main tropical/max-plus spectral theory development is in `Bridges/`.
+---See:
+---- `Bridges.MaxPlusDefs` - Core definitions
+---- `Bridges.MaxPlusLemmas` - Structural lemmas
+---- `Bridges.EigenvectorIteration` - Eigenvector iteration theorem
+---- `Bridges.PerronTheorem` - Tropical Perron-Frobenius theorem
+---- `Bridges.EMLSpectral` - EML spectral duality
+----/+--- a/Bridges/Basic.lean
+--++++ b/Bridges/Basic.lean
+--+@@ -1,104 +1,149 @@
+--+ /-
+--+-# Bridge Theory in Simple Graphs
+--++Copyright (c) 2025. All rights reserved.
+--++Released under Apache 2.0 license.
+--++
+--++# Bridge Theory in Graph Theory
+--+ 
+--+ This file develops the theory of bridges (cut edges) in simple graphs,
+--+-proving the fundamental equivalence between trees and connected graphs
+--+-where every edge is a bridge.
+--++building on Mathlib's `SimpleGraph.IsBridge` definition.
+--+ 
+--+-## Main Results
+--++## Main results
+--+ 
+--+-* `SimpleGraph.IsAcyclic.isBridge_of_mem_edgeSet` — In an acyclic graph, every edge is a bridge
+--+-* `SimpleGraph.IsTree.isBridge_of_mem_edgeSet` — In a tree, every edge is a bridge
+--+-* `SimpleGraph.isAcyclic_of_forall_isBridge` — If every edge is a bridge, the graph is acyclic
+--+-* `SimpleGraph.isTree_iff_connected_and_forall_isBridge` — **Tree-Bridge Equivalence**:
+--+-  A graph is a tree if and only if it is connected and every edge is a bridge
+--++* `IsBridge.connectedComponent_ne` — Endpoints of a bridge are in different
+--++  connected components after deletion.
+--++* `IsBridge.two_connected_components` — Removing a bridge from a connected
+--++  graph yields exactly two connected components.
+--++* `IsTree.isBridge_of_adj` — Every edge of a tree is a bridge.
+--++* `connected_isBridge_all_iff_isTree` — A connected graph is a tree iff
+--++  every edge is a bridge.
+--++* `IsBridge.forall_reachable_delete_left_or_right` — Every vertex in a
+--++  connected graph is reachable from one side of a bridge after deletion.
+--+ 
+--+-## Historical Context
+--++## Historical context
+--+ 
+--+-Bridges in graph theory originate from Euler's 1736 analysis of the Königsberg
+--+-bridge problem. The Tree-Bridge Equivalence Theorem provides a fundamental
+--+-structural characterization: trees are precisely the minimally connected graphs,
+--+-where the removal of any single edge disconnects the graph.
+--+-
+--+-## References
+--+-
+--+-* Reinhard Diestel, *Graph Theory*, 5th Edition, Springer, 2017
+--++The study of bridges in graph theory traces back to Euler's 1736 solution
+--++of the Königsberg Bridge Problem — widely considered the birth of graph
+--++theory. A bridge (or cut edge) is an edge whose removal disconnects the
+--++graph, making it a critical concept in network reliability and infrastructure
+--++analysis.
+-+--- a/Tropical/Basic.lean
+-++++ b/Tropical/Basic.lean
+-+@@ -1,1315 +1,383 @@
+-+---- a/Tropical/Basic.lean
+-+-+++ b/Tropical/Basic.lean
+-+-@@ -1,930 +1,383 @@
+-+----- a/Tropical/Basic.lean
+-+--+++ b/Tropical/Basic.lean
+-+--@@ -1,545 +1,383 @@
+-+------ a/Tropical/Basic.lean
+-+---+++ b/Tropical/Basic.lean
+-+---@@ -1,383 +1,160 @@
+-+------- a/EML/Basic.lean
+-+----+++ b/EML/Basic.lean
+-+----@@ -1,277 +1,125 @@
+-+-----/-
+-+-----Copyright (c) 2026 Harmonic. All rights reserved.
+-+-----Released under Apache 2.0 license as described in the file LICENSE.
+-+------/
+-+---- import Mathlib
+-+---- 
+-+-----/-!
+-+-----# Pullback Stability of Universal Approximation
+-+----+/-! # CatalogBuild.EML.Basic
+-+---- 
+-+-----Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
+-+-----subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
+-+-----closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
+-+-----When `φ` is injective, this gives density in all of `C(X, ℝ)`.
+-+-----
+-+-----This establishes a transport principle: universal approximation results (like
+-+-----Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
+-+-----with the precise target being the fiber-constant functions.
+-+-----
+-+-----## Main definitions
+-+-----
+-+-----* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
+-+-----  fibers of `φ`.
+-+-----* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
+-+-----
+-+-----## Main results
+-+-----
+-+-----### Basic properties (§1)
+-+-----* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
+-+-----* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
+-+-----* `norm_pullback_le` — the pullback map is norm-nonincreasing.
+-+-----* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
+-+-----* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
+-+-----
+-+-----### Factorization (§2)
+-+-----* `fiberConst_subset_range_pullback` — every fiber-constant function factors
+-+-----  through `Set.range φ`, hence is a pullback (via Tietze extension).
+-+-----
+-+-----### Density transport (§3)
+-+-----* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
+-+-----  subalgebra equals `FiberConst φ`.
+-+-----* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
+-+-----
+-+-----### ε-approximation (§4)
+-+-----* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
+-+-----* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
+-+----+Auto-generated from theorem catalog database.
+-+----+Domain: EML
+-+----+Declarations: 15
+-+---- -/
+-+---- 
+-+-----open scoped Topology
+-+-----open Topology
+-+----+noncomputable section
+-+---- 
+-+-----variable {X Y : Type*}
+-+-----variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
+-+-----variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
+-+----+/-- The inverse for hyperbolic SPB is also negation. -/
+-+----+theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
+-+----+  simp [spbH]
+-+---- 
+-+-----/-! ### §1: Definitions and basic properties -/
+-+----+/-- Wick duality: SPB with negated second argument equals the "difference"
+-+----+in the hyperbolic SPB. This is the real-variable manifestation of the
+-+----+Wick rotation t → it. -/
+-+----+theorem wick_duality (x y : ℝ) :
+-+----+    spb x (-y) = (x - y) / (1 + x * y) := by
+-+----+  simp only [spb]
+-+----+  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
+-+----+  rw [heq]; ring
+-+---- 
+-+-----/-- Continuous functions on `X` that are constant on fibers of `φ`.
+-+-----This is the natural functional-analytic object associated to a feature map:
+-+-----it captures exactly the observables visible through `φ`. -/
+-+-----def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
+-+-----  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
+-+-----  algebraMap_mem' r := by intro x x' _; simp
+-+-----  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
+-+-----  zero_mem' := by intro x x' _; simp
+-+-----  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
+-+-----  one_mem' := by intro x x' _; simp
+-+----+/-- The tangent addition law IS the stereographic sum.
+-+----+tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
+-+----+theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
+-+----+    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
+-+----+  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
+-+----+      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
+-+----+  field_simp
+-+---- 
+-+-----/-- Pullback of continuous real-valued functions along `φ`. -/
+-+-----def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
+-+-----  toFun f := f.comp φ
+-+-----  map_zero' := by ext; simp
+-+-----  map_one' := by ext; simp
+-+-----  map_add' := by intros; ext; simp
+-+-----  map_mul' := by intros; ext; simp
+-+-----  commutes' := by intros; ext; simp
+-+----+/-- SPB expression trees — analogous to EML expression trees. -/
+-+----+inductive SPBExpr where
+-+----+  | zero : SPBExpr
+-+----+  | one : SPBExpr
+-+----+  | var : ℕ → SPBExpr
+-+----+  | node : SPBExpr → SPBExpr → SPBExpr
+-+----+  deriving Repr, BEq
+-+---- 
+-+-----@[simp]
+-+-----theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
+-+-----    pullbackAlg φ f x = f (φ x) := rfl
+-+----+/-- Evaluate an SPB expression. -/
+-+----+def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
+-+----+  match e with
+-+----+  | .zero => 0
+-+----+  | .one => 1
+-+----+  | .var n => vars n
+-+----+  | .node l r => spb (l.eval vars) (r.eval vars)
+-+---- 
+-+-----theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
+-+-----    pullbackAlg φ f ∈ FiberConst φ := by
+-+-----  intro x x' h; simp [h]
+-+----+/-- Depth of an SPB expression. -/
+-+----+def SPBExpr.depth : SPBExpr → ℕ
+-+----+  | .zero => 0
+-+----+  | .one => 0
+-+----+  | .var _ => 0
+-+----+  | .node l r => 1 + max l.depth r.depth
+-+---- 
+-+-----theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
+-+-----    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
+-+-----  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
+-+----+/-- Leaf count. -/
+-+----+def SPBExpr.leafCount : SPBExpr → ℕ
+-+----+  | .zero => 1
+-+----+  | .one => 1
+-+----+  | .var _ => 1
+-+----+  | .node l r => l.leafCount + r.leafCount
+-+---- 
+-+-----theorem range_comp_subalgebra_subset_fiberConst
+-+-----    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
+-+-----    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
+-+-----  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
+-+----+/-- Internal node count. -/
+-+----+def SPBExpr.nodeCount : SPBExpr → ℕ
+-+----+  | .zero => 0
+-+----+  | .one => 0
+-+----+  | .var _ => 0
+-+----+  | .node l r => 1 + l.nodeCount + r.nodeCount
+-+---- 
+-+-----/-- `FiberConst φ` is closed in the uniform topology. -/
+-+-----theorem fiberConst_closed (φ : C(X, Y)) :
+-+-----    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
+-+-----  refine isClosed_of_closure_subset ?_
+-+-----  intro g hg x x' h
+-+-----  rw [mem_closure_iff_nhds] at hg
+-+-----  contrapose! hg
+-+-----  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
+-+-----    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
+-+-----    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
+-+----+/-- Binary tree identity: leaves = internal nodes + 1. -/
+-+----+theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
+-+----+    e.leafCount = e.nodeCount + 1 := by
+-+----+  induction e with
+-+----+  | zero => rfl
+-+----+  | one => rfl
+-+----+  | var _ => rfl
+-+----+  | node l r ihl ihr =>
+-+----+    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
+-+----+    omega
+-+---- 
+-+-----omit [T2Space X] [T2Space Y] in
+-+-----/-- The pullback map is norm-nonincreasing. -/
+-+-----theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
+-+-----    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
+-+-----  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
+-+-----    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
+-+----+/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
+-+----+def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
+-+---- 
+-+-----/-- When `φ` is surjective, pullback is an isometry. -/
+-+-----theorem pullback_isometry_of_surjective
+-+-----    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
+-+-----    ‖pullbackAlg φ f‖ = ‖f‖ := by
+-+-----  refine le_antisymm (norm_pullback_le φ f) ?_
+-+-----  rw [ContinuousMap.norm_le _ (by positivity)]
+-+-----  intro y; obtain ⟨x, rfl⟩ := hφ y
+-+-----  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
+-+----+/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
+-+----+theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
+-+----+  unfold logisticSigmoid
+-+----+  rw [Real.exp_neg]
+-+----+  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
+-+----+  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
+-+----+  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
+-+----+  field_simp; ring
+-+---- 
+-+-----omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
+-+-----theorem mem_fiberConst_of_injective
+-+-----    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
+-+-----    g ∈ FiberConst φ := by
+-+-----  intro x x' h; exact congrArg g (hφ h)
+-+----+/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
+-+----+theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
+-+----+  unfold softplus logisticSigmoid
+-+----+  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
+-+----+  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
+-+----+  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
+-+----+  simp at this
+-+----+  exact this
+-+---- 
+-+-----omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
+-+-----theorem fiberConst_eq_top_of_injective
+-+-----    (φ : C(X, Y)) (hφ : Function.Injective φ) :
+-+-----    FiberConst φ = ⊤ := by
+-+-----  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
+-+----+/-- ShefferAlg is closed under affine pre-composition. -/
+-+----+theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
+-+----+    (fun x => f (a * x + b)) ∈ ShefferAlg := by
+-+----+  obtain ⟨e, rfl⟩ := hf
+-+----+  exact ⟨.affinePrecomp a b e, rfl⟩
+-+---- 
+-+-----omit [CompactSpace Y] [T2Space Y] in
+-+-----/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
+-+-----theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
+-+-----    FiberConst φ = ⊤ ↔ Function.Injective φ := by
+-+-----  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
+-+-----  intro x x' hφ; by_contra h_ne
+-+-----  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
+-+-----    have := exists_continuous_zero_one_of_isClosed
+-+-----      (show IsClosed {x} from isClosed_singleton)
+-+-----      (show IsClosed {x'} from isClosed_singleton) (by aesop)
+-+-----    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
+-+-----      this.choose_spec.2.1 (Set.mem_singleton x')⟩
+-+-----  replace h := SetLike.ext_iff.mp h g
+-+-----  simp_all +decide [FiberConst]
+-+-----  exact absurd (h hφ) (by simp +decide [hg])
+-+----+/-- ShefferAlg is closed under affine combination. -/
+-+----+theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
+-+----+    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
+-+----+  obtain ⟨ef, rfl⟩ := hf
+-+----+  obtain ⟨eg, rfl⟩ := hg
+-+----+  exact ⟨.affineComb α β γ ef eg, rfl⟩
+-+---- 
+-+-----/-! ### §2: Image factorization -/
+-+----+/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
+-+----+theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
+-+----+  unfold softplus
+-+----+  rw [Real.exp_neg]
+-+----+  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
+-+----+  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
+-+----+  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
+-+----+  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
+-+----+  rw [this, Real.log_exp]
+-+---- 
+-+-----instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
+-+-----  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
+-+-----
+-+-----/-
+-+-----The corestriction `X → Set.range φ` is a quotient map.
+-+------/
+-+-----theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
+-+-----    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
+-+-----  apply IsClosedMap.isQuotientMap;
+-+-----  · intro s hs;
+-+-----    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
+-+-----    constructor <;> intro h;
+-+-----    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
+-+-----    · convert h.preimage ( continuous_subtype_val ) using 1;
+-+-----      ext; simp [Set.rangeFactorization];
+-+-----      grind;
+-+-----  · exact continuous_induced_rng.mpr φ.continuous;
+-+-----  · exact Set.rangeFactorization_surjective
+-+-----
+-+-----/-- Lift a fiber-constant function to `Set.range φ`. -/
+-+-----noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
+-+-----    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
+-+-----  toFun z := g z.property.choose
+-+-----  continuous_toFun := by
+-+-----    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
+-+-----    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
+-+-----    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
+-+-----      ext x; apply hg
+-+-----      exact (Set.rangeFactorization φ x).property.choose_spec
+-+-----    rw [this]; exact g.continuous
+-+-----
+-+-----theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
+-+-----    (hg : g ∈ FiberConst φ) (x : X) :
+-+-----    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
+-+-----  simp only [fiberConstLift]
+-+-----  apply hg
+-+-----  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
+-+-----
+-+-----/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
+-+-----theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
+-+-----    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
+-+-----  intro g hg
+-+-----  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
+-+-----  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
+-+-----    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
+-+-----  refine ⟨F, ?_⟩
+-+-----  ext x
+-+-----  simp only [pullbackAlg_apply]
+-+-----  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
+-+-----    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
+-+-----    simp [ContinuousMap.comp_apply] at this; exact this
+-+-----  rw [key, fiberConstLift_comp]
+-+-----
+-+-----/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
+-+-----theorem fiberConst_eq_range_pullback_of_surjective
+-+-----    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
+-+-----    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
+-+-----  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
+-+-----    (range_pullback_subset_fiberConst φ)
+-+-----
+-+-----/-! ### §3: Density transport -/
+-+-----
+-+-----/-
+-+-----The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
+-+------/
+-+-----theorem closure_range_pullback_eq_fiberConst
+-+-----    (φ : C(X, Y))
+-+-----    (A : Subalgebra ℝ C(Y, ℝ))
+-+-----    (hA : Dense (A : Set C(Y, ℝ))) :
+-+-----    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
+-+-----      = (FiberConst φ : Set C(X, ℝ)) := by
+-+-----  refine' le_antisymm ( closure_minimal _ _ ) _;
+-+-----  · exact range_comp_subalgebra_subset_fiberConst φ A;
+-+-----  · exact fiberConst_closed φ;
+-+-----  · intro g hg;
+-+-----    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
+-+-----    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
+-+-----      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
+-+-----    rw [ Metric.mem_closure_iff ];
+-+-----    intro ε εpos;
+-+-----    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
+-+-----    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
+-+-----    nontriviality;
+-+-----    rw [ hF, dist_eq_norm ] at *;
+-+-----    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
+-+-----
+-+-----/-
+-+-----Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
+-+------/
+-+-----theorem closure_range_pullback_eq_top_of_injective
+-+-----    (φ : C(X, Y))
+-+-----    (hφ : Function.Injective φ)
+-+-----    (A : Subalgebra ℝ C(Y, ℝ))
+-+-----    (hA : Dense (A : Set C(Y, ℝ))) :
+-+-----    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
+-+-----  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
+-+-----  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
+-+-----
+-+-----/-! ### §4: ε-approximation -/
+-+-----
+-+-----/-
+-+-----ε-approximation within `FiberConst φ`.
+-+------/
+-+-----theorem exists_pullback_approx_of_fiberConst
+-+-----    (φ : C(X, Y))
+-+-----    (A : Subalgebra ℝ C(Y, ℝ))
+-+-----    (hA : Dense (A : Set C(Y, ℝ)))
+-+-----    (g : C(X, ℝ))
+-+-----    (hg : g ∈ FiberConst φ)
+-+-----    {ε : ℝ} (hε : 0 < ε) :
+-+-----    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
+-+-----  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
+-+-----    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
+-+-----  rw [ Metric.mem_closure_iff ] at h_closure;
+-+-----  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
+-+-----
+-+-----/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
+-+-----theorem exists_pullback_approx_of_injective
+-+-----    (φ : C(X, Y))
+-+-----    (hφ : Function.Injective φ)
+-+-----    (A : Subalgebra ℝ C(Y, ℝ))
+-+-----    (hA : Dense (A : Set C(Y, ℝ)))
+-+-----    (g : C(X, ℝ))
+-+-----    {ε : ℝ} (hε : 0 < ε) :
+-+-----    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
+-+-----  exact exists_pullback_approx_of_fiberConst φ A hA g
+-+-----    (mem_fiberConst_of_injective φ hφ g) hε+end+/-
+-+---+Copyright (c) 2025. All rights reserved.
+-+---+Released under Apache 2.0 license as described in the file LICENSE.
+-+---+-/
+-+---+import Mathlib
+-+---+
+-+---+/-!
+-+---+# GL₃ Tropical Satake: Core Definitions
+-+---+
+-+---+This file establishes the foundational types and operations for the GL₃ tropical
+-+---+Satake finite-determinacy theory.
+-+---+
+-+---+## Overview
+-+---+
+-+---+For GL₃, a **dominant coweight** is a triple `(a, b, c) ∈ ℕ³` with `a ≥ b ≥ c`.
+-+---+The **dominant box** `BoxDom(B)` is the finite set of dominant coweights with `a ≤ B`.
+-+---+
+-+---+We define three families of **tropical Satake observables**, corresponding to the
+-+---+three fundamental representations `ω₁, ω₂, ω₃` of GL₃:
+-+---+
+-+---+1. **Rank-1 profile** (`rank1Profile`): tropical convolution with the standard
+-+---+   representation character. Uses the weights `e₁, e₂, e₃`.
+-+---+2. **Rank-2 profile** (`rank2Profile`): tropical convolution with the exterior square
+-+---+   character. Uses the weights `e₁+e₂, e₁+e₃, e₂+e₃`.
+-+---+3. **Edge moment** (`edgeMoment`): tropical convolution with the determinant character
+-+---+   `ω₃ = (1,1,1)`. This is the key reconstruction tool: as a shift operator, it
+-+---+   recovers function values without the information loss inherent in max operations.
+-+---+
+-+---+The finite-determinacy theorem (proved in `FiniteDeterminacy.lean`) shows that
+-+---+equality of these observables on finite test sets forces equality of the underlying
+-+---+functions.
+-+---+-/
+-+---+
+-+---+open Finset
+-+---+
+-+---+/-! ### Dominance and support conditions -/
+-+---+
+-+---+/-- A triple `(a, b, c)` is dominant if `a ≥ b ≥ c`. -/
+-+---+def IsDominant (a b c : ℕ) : Prop := b ≤ a ∧ c ≤ b
+-+---+
+-+---+/-- A function on `ℕ³` has finite support within box `B` if it vanishes outside
+-+---+    the dominant box `{(a,b,c) : b ≤ a, c ≤ b, a ≤ B}`. -/
+-+---+def FiniteSupportWithin (B : ℕ) (f : ℕ → ℕ → ℕ → ℤ) : Prop :=
+-+---+  ∀ a b c : ℕ, (B < a ∨ a < b ∨ b < c) → f a b c = 0
+-+---+
+-+---+/-- The box `BoxDom(B)` as a `Finset` of triples. -/
+-+---+def boxDomFinset (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
+-+---+  (Finset.range (B + 1) ×ˢ Finset.range (B + 1) ×ˢ Finset.range (B + 1)).filter
+-+---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
+-+---+
+-+---+lemma mem_boxDomFinset {B : ℕ} {a b c : ℕ} :
+-+---+    (a, b, c) ∈ boxDomFinset B ↔ a ≤ B ∧ b ≤ a ∧ c ≤ b := by
+-+---+  simp [boxDomFinset, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
+-+---+  omega
+-+---+
+-+---+/-! ### Tropical Satake observables -/
+-+---+
+-+---+/-- **Rank-1 profile**: tropical convolution with the standard representation `ω₁`.
+-+---+
+-+---+The weights of the standard representation of GL₃ are `e₁ = (1,0,0)`,
+-+---+`e₂ = (0,1,0)`, `e₃ = (0,0,1)`. The rank-1 profile at `(a,b,c)` is
+-+---+`max{f(a-1,b,c), f(a,b-1,c), f(a,b,c-1)}` with appropriate guards for ℕ subtraction.
+-+---+
+-+---+Note: Invalid shifts (where subtraction would go below 0) contribute the value `0`,
+-+---+which serves as the tropical "zero" in this ℤ-valued model. -/
+-+---+def rank1Profile (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
+-+---+  let v1 := if 1 ≤ a then f (a - 1) b c else 0
+-+---+  let v2 := if 1 ≤ b then f a (b - 1) c else 0
+-+---+  let v3 := if 1 ≤ c then f a b (c - 1) else 0
+-+---+  max v1 (max v2 v3)
+-+---+
+-+---+/-- **Rank-2 profile**: tropical convolution with the exterior square `ω₂ = ∧²`.
+-+---+
+-+---+The weights of `∧²(ℂ³)` are `e₁+e₂ = (1,1,0)`, `e₁+e₃ = (1,0,1)`,
+-+---+`e₂+e₃ = (0,1,1)`. The rank-2 profile at `(a,b,c)` is
+-+---+`max{f(a-1,b-1,c), f(a-1,b,c-1), f(a,b-1,c-1)}`. -/
+-+---+def rank2Profile (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
+-+---+  let v1 := if 1 ≤ a ∧ 1 ≤ b then f (a - 1) (b - 1) c else 0
+-+---+  let v2 := if 1 ≤ a ∧ 1 ≤ c then f (a - 1) b (c - 1) else 0
+-+---+  let v3 := if 1 ≤ b ∧ 1 ≤ c then f a (b - 1) (c - 1) else 0
+-+---+  max v1 (max v2 v3)
+-+---+
+-+---+/-- **Edge moment**: tropical convolution with the determinant character `ω₃ = (1,1,1)`.
+-+---+
+-+---+This is the shift operator: `edgeMoment f (a,b,c) = f(a-1, b-1, c-1)`.
+-+---+As a representation-theoretic operation, it corresponds to convolution with the
+-+---+one-dimensional determinant representation `det = ∧³(ℂ³)`. Unlike the rank-1 and
+-+---+rank-2 profiles (which use `max` and can lose information), the determinant
+-+---+convolution perfectly preserves all function values.
+-+---+
+-+---+This is the key observable that makes finite determinacy possible: it acts as an
+-+---+exact reconstruction tool rather than a lossy tropical projection. -/
+-+---+def edgeMoment (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
+-+---+  if 1 ≤ a ∧ 1 ≤ b ∧ 1 ≤ c then f (a - 1) (b - 1) (c - 1) else 0
+-+---+
+-+---+/-- Combined triple convolution observable using both rank-1 and rank-2 generators.
+-+---+    This packages rank-1 and rank-2 data together for the combined hypothesis form. -/
+-+---+def tripleConvObservable (f : ℕ → ℕ → ℕ → ℤ) (t s : ℕ × ℕ × ℕ) : ℤ :=
+-+---+  rank1Profile f t.1 t.2.1 t.2.2 + rank2Profile f s.1 s.2.1 s.2.2
+-+---+
+-+---+/-! ### Finite test ranges -/
+-+---+
+-+---+/-- The finite range of rank-1 test parameters determined by box bound `B`. -/
+-+---+def finiteRank1Range (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
+-+---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
+-+---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
+-+---+
+-+---+/-- The finite range of rank-2 test parameters determined by box bound `B`. -/
+-+---+def finiteRank2Range (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
+-+---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
+-+---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
+-+---+
+-+---+/-- The finite range of edge moment test parameters determined by box bound `B`.
+-+---+    These are the shifted dominant coweights `(a+1, b+1, c+1)` for `(a,b,c) ∈ BoxDom(B)`. -/
+-+---+def finiteEdgeMomentRange (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
+-+---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
+-+---+    fun ⟨a, b, c⟩ => 1 ≤ c ∧ c ≤ b ∧ b ≤ a
+-+---+
+-+---+/-! ### Key computation lemmas -/
+-+---+
+-+---+/-- The edge moment at a shifted point exactly recovers the function value.
+-+---+    This is the fundamental reconstruction identity. -/
+-+---+@[simp]
+-+---+lemma edgeMoment_succ (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) :
+-+---+    edgeMoment f (a + 1) (b + 1) (c + 1) = f a b c := by
+-+---+  simp [edgeMoment]
+-+---+
+-+---+/-- Shifted dominant coweights lie in the edge moment range. -/
+-+---+lemma shifted_mem_finiteEdgeMomentRange {B a b c : ℕ}
+-+---+    (haB : a ≤ B) (hab : b ≤ a) (hbc : c ≤ b) :
+-+---+    (a + 1, b + 1, c + 1) ∈ finiteEdgeMomentRange B := by
+-+---+  simp [finiteEdgeMomentRange, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
+-+---+  omega
+-+---+
+-+---+/-- The rank-2 profile at the floor level `(a+1, b+1, 0)` yields `max(f(a,b,0), 0)`.
+-+---+    When `f` is nonneg-valued on the floor, this equals `f(a,b,0)`.
+-+---+    The `c = 0` case is special because both `ω₂`-weight shifts involving `c-1`
+-+---+    fall outside `ℕ`, leaving only the `(1,1,0)`-weight shift. -/
+-+---+lemma rank2Profile_floor_level (f : ℕ → ℕ → ℕ → ℤ) (a b : ℕ) :
+-+---+    rank2Profile f (a + 1) (b + 1) 0 = max (f a b 0) 0 := by
+-+---+  simp [rank2Profile]
+-+---+
+-+---+/-- For functions supported in `BoxDom(B)`, values at `a > B` vanish. -/
+-+---+lemma FiniteSupportWithin.vanish_above {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
+-+---+    (hf : FiniteSupportWithin B f) {a : ℕ} (ha : B < a) (b c : ℕ) :
+-+---+    f a b c = 0 := by
+-+---+  exact hf a b c (Or.inl ha)
+-+---+
+-+---+/-- For functions supported in `BoxDom(B)`, values outside dominant cone vanish. -/
+-+---+lemma FiniteSupportWithin.vanish_nondominant {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
+-+---+    (hf : FiniteSupportWithin B f) {a b c : ℕ} (h : a < b ∨ b < c) :
+-+---+    f a b c = 0 := by
+-+---+  exact hf a b c (by tauto)
+-+---+
+-+---+/-- Bounded-support functions vanish outside the box: explicit formulation. -/
+-+---+lemma bounded_support_implies_vanishing_outside {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
+-+---+    (hf : FiniteSupportWithin B f) {a b c : ℕ}
+-+---+    (h : ¬(a ≤ B ∧ b ≤ a ∧ c ≤ b)) :
+-+---+    f a b c = 0 := by
+-+---+  apply hf; push_neg at h; omega+--- a/EML/Basic.lean
+-+--++++ b/EML/Basic.lean
+-+--+@@ -1,277 +1,125 @@
+-+--+-/-
+-+--+-Copyright (c) 2026 Harmonic. All rights reserved.
+-+--+-Released under Apache 2.0 license as described in the file LICENSE.
+-+--+--/
+-+--+ import Mathlib
+-+--+ 
+-+--+-/-!
+-+--+-# Pullback Stability of Universal Approximation
+-+--++/-! # CatalogBuild.EML.Basic
+-+--+ 
+-+--+-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
+-+--+-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
+-+--+-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
+-+--+-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
+-+--+-
+-+--+-This establishes a transport principle: universal approximation results (like
+-+--+-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
+-+--+-with the precise target being the fiber-constant functions.
+-+--+-
+-+--+-## Main definitions
+-+--+-
+-+--+-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
+-+--+-  fibers of `φ`.
+-+--+-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
+-+--+-
+-+--+-## Main results
+-+--+-
+-+--+-### Basic properties (§1)
+-+--+-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
+-+--+-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
+-+--+-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
+-+--+-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
+-+--+-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
+-+--+-
+-+--+-### Factorization (§2)
+-+--+-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
+-+--+-  through `Set.range φ`, hence is a pullback (via Tietze extension).
+-+--+-
+-+--+-### Density transport (§3)
+-+--+-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
+-+--+-  subalgebra equals `FiberConst φ`.
+-+--+-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
+-+--+-
+-+--+-### ε-approximation (§4)
+-+--+-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
+-+--+-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
+-+--++Auto-generated from theorem catalog database.
+-+--++Domain: EML
+-+--++Declarations: 15
+-+--+ -/
+-+--+ 
+-+--+-open scoped Topology
+-+--+-open Topology
+-+--++noncomputable section
+-+--+ 
+-+--+-variable {X Y : Type*}
+-+--+-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
+-+--+-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
+-+--++/-- The inverse for hyperbolic SPB is also negation. -/
+-+--++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
+-+--++  simp [spbH]
+-+--+ 
+-+--+-/-! ### §1: Definitions and basic properties -/
+-+--++/-- Wick duality: SPB with negated second argument equals the "difference"
+-+--++in the hyperbolic SPB. This is the real-variable manifestation of the
+-+--++Wick rotation t → it. -/
+-+--++theorem wick_duality (x y : ℝ) :
+-+--++    spb x (-y) = (x - y) / (1 + x * y) := by
+-+--++  simp only [spb]
+-+--++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
+-+--++  rw [heq]; ring
+-+--+ 
+-+--+-/-- Continuous functions on `X` that are constant on fibers of `φ`.
+-+--+-This is the natural functional-analytic object associated to a feature map:
+-+--+-it captures exactly the observables visible through `φ`. -/
+-+--+-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
+-+--+-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
+-+--+-  algebraMap_mem' r := by intro x x' _; simp
+-+--+-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
+-+--+-  zero_mem' := by intro x x' _; simp
+-+--+-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
+-+--+-  one_mem' := by intro x x' _; simp
+-+--++/-- The tangent addition law IS the stereographic sum.
+-+--++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
+-+--++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
+-+--++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
+-+--++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
+-+--++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
+-+--++  field_simp
+-+--+ 
+-+--+-/-- Pullback of continuous real-valued functions along `φ`. -/
+-+--+-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
+-+--+-  toFun f := f.comp φ
+-+--+-  map_zero' := by ext; simp
+-+--+-  map_one' := by ext; simp
+-+--+-  map_add' := by intros; ext; simp
+-+--+-  map_mul' := by intros; ext; simp
+-+--+-  commutes' := by intros; ext; simp
+-+--++/-- SPB expression trees — analogous to EML expression trees. -/
+-+--++inductive SPBExpr where
+-+--++  | zero : SPBExpr
+-+--++  | one : SPBExpr
+-+--++  | var : ℕ → SPBExpr
+-+--++  | node : SPBExpr → SPBExpr → SPBExpr
+-+--++  deriving Repr, BEq
+-+--+ 
+-+--+-@[simp]
+-+--+-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
+-+--+-    pullbackAlg φ f x = f (φ x) := rfl
+-+--++/-- Evaluate an SPB expression. -/
+-+--++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
+-+--++  match e with
+-+--++  | .zero => 0
+-+--++  | .one => 1
+-+--++  | .var n => vars n
+-+--++  | .node l r => spb (l.eval vars) (r.eval vars)
+-+--+ 
+-+--+-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
+-+--+-    pullbackAlg φ f ∈ FiberConst φ := by
+-+--+-  intro x x' h; simp [h]
+-+--++/-- Depth of an SPB expression. -/
+-+--++def SPBExpr.depth : SPBExpr → ℕ
+-+--++  | .zero => 0
+-+--++  | .one => 0
+-+--++  | .var _ => 0
+-+--++  | .node l r => 1 + max l.depth r.depth
+-+--+ 
+-+--+-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
+-+--+-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
+-+--+-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
+-+--++/-- Leaf count. -/
+-+--++def SPBExpr.leafCount : SPBExpr → ℕ
+-+--++  | .zero => 1
+-+--++  | .one => 1
+-+--++  | .var _ => 1
+-+--++  | .node l r => l.leafCount + r.leafCount
+-+--+ 
+-+--+-theorem range_comp_subalgebra_subset_fiberConst
+-+--+-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
+-+--+-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
+-+--+-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
+-+--++/-- Internal node count. -/
+-+--++def SPBExpr.nodeCount : SPBExpr → ℕ
+-+--++  | .zero => 0
+-+--++  | .one => 0
+-+--++  | .var _ => 0
+-+--++  | .node l r => 1 + l.nodeCount + r.nodeCount
+-+--+ 
+-+--+-/-- `FiberConst φ` is closed in the uniform topology. -/
+-+--+-theorem fiberConst_closed (φ : C(X, Y)) :
+-+--+-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
+-+--+-  refine isClosed_of_closure_subset ?_
+-+--+-  intro g hg x x' h
+-+--+-  rw [mem_closure_iff_nhds] at hg
+-+--+-  contrapose! hg
+-+--+-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
+-+--+-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
+-+--+-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
+-+--++/-- Binary tree identity: leaves = internal nodes + 1. -/
+-+--++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
+-+--++    e.leafCount = e.nodeCount + 1 := by
+-+--++  induction e with
+-+--++  | zero => rfl
+-+--++  | one => rfl
+-+--++  | var _ => rfl
+-+--++  | node l r ihl ihr =>
+-+--++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
+-+--++    omega
+-+--+ 
+-+--+-omit [T2Space X] [T2Space Y] in
+-+--+-/-- The pullback map is norm-nonincreasing. -/
+-+--+-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
+-+--+-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
+-+--+-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
+-+--+-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
+-+--++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
+-+--++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
+-+--+ 
+-+--+-/-- When `φ` is surjective, pullback is an isometry. -/
+-+--+-theorem pullback_isometry_of_surjective
+-+--+-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
+-+--+-    ‖pullbackAlg φ f‖ = ‖f‖ := by
+-+--+-  refine le_antisymm (norm_pullback_le φ f) ?_
+-+--+-  rw [ContinuousMap.norm_le _ (by positivity)]
+-+--+-  intro y; obtain ⟨x, rfl⟩ := hφ y
+-+--+-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
+-+--++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
+-+--++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
+-+--++  unfold logisticSigmoid
+-+--++  rw [Real.exp_neg]
+-+--++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
+-+--++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
+-+--++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
+-+--++  field_simp; ring
+-+--+ 
+-+--+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
+-+--+-theorem mem_fiberConst_of_injective
+-+--+-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
+-+--+-    g ∈ FiberConst φ := by
+-+--+-  intro x x' h; exact congrArg g (hφ h)
+-+--++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
+-+--++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
+-+--++  unfold softplus logisticSigmoid
+-+--++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
+-+--++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
+-+--++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
+-+--++  simp at this
+-+--++  exact this
+-+--+ 
+-+--+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
+-+--+-theorem fiberConst_eq_top_of_injective
+-+--+-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
+-+--+-    FiberConst φ = ⊤ := by
+-+--+-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
+-+--++/-- ShefferAlg is closed under affine pre-composition. -/
+-+--++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
+-+--++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
+-+--++  obtain ⟨e, rfl⟩ := hf
+-+--++  exact ⟨.affinePrecomp a b e, rfl⟩
+-+--+ 
+-+--+-omit [CompactSpace Y] [T2Space Y] in
+-+--+-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
+-+--+-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
+-+--+-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
+-+--+-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
+-+--+-  intro x x' hφ; by_contra h_ne
+-+--+-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
+-+--+-    have := exists_continuous_zero_one_of_isClosed
+-+--+-      (show IsClosed {x} from isClosed_singleton)
+-+--+-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
+-+--+-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
+-+--+-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
+-+--+-  replace h := SetLike.ext_iff.mp h g
+-+--+-  simp_all +decide [FiberConst]
+-+--+-  exact absurd (h hφ) (by simp +decide [hg])
+-+--++/-- ShefferAlg is closed under affine combination. -/
+-+--++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
+-+--++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
+-+--++  obtain ⟨ef, rfl⟩ := hf
+-+--++  obtain ⟨eg, rfl⟩ := hg
+-+--++  exact ⟨.affineComb α β γ ef eg, rfl⟩
+-+--+ 
+-+--+-/-! ### §2: Image factorization -/
+-+--++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
+-+--++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
+-+--++  unfold softplus
+-+--++  rw [Real.exp_neg]
+-+--++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
+-+--++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
+-+--++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
+-+--++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
+-+--++  rw [this, Real.log_exp]
+-+--+ 
+-+--+-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
+-+--+-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
+-+--+-
+-+--+-/-
+-+--+-The corestriction `X → Set.range φ` is a quotient map.
+-+--+--/
+-+--+-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
+-+--+-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
+-+--+-  apply IsClosedMap.isQuotientMap;
+-+--+-  · intro s hs;
+-+--+-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
+-+--+-    constructor <;> intro h;
+-+--+-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
+-+--+-    · convert h.preimage ( continuous_subtype_val ) using 1;
+-+--+-      ext; simp [Set.rangeFactorization];
+-+--+-      grind;
+-+--+-  · exact continuous_induced_rng.mpr φ.continuous;
+-+--+-  · exact Set.rangeFactorization_surjective
+-+--+-
+-+--+-/-- Lift a fiber-constant function to `Set.range φ`. -/
+-+--+-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
+-+--+-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
+-+--+-  toFun z := g z.property.choose
+-+--+-  continuous_toFun := by
+-+--+-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
+-+--+-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
+-+--+-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
+-+--+-      ext x; apply hg
+-+--+-      exact (Set.rangeFactorization φ x).property.choose_spec
+-+--+-    rw [this]; exact g.continuous
+-+--+-
+-+--+-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
+-+--+-    (hg : g ∈ FiberConst φ) (x : X) :
+-+--+-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
+-+--+-  simp only [fiberConstLift]
+-+--+-  apply hg
+-+--+-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
+-+--+-
+-+--+-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
+-+--+-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
+-+--+-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
+-+--+-  intro g hg
+-+--+-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
+-+--+-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
+-+--+-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
+-+--+-  refine ⟨F, ?_⟩
+-+--+-  ext x
+-+--+-  simp only [pullbackAlg_apply]
+-+--+-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
+-+--+-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
+-+--+-    simp [ContinuousMap.comp_apply] at this; exact this
+-+--+-  rw [key, fiberConstLift_comp]
+-+--+-
+-+--+-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
+-+--+-theorem fiberConst_eq_range_pullback_of_surjective
+-+--+-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
+-+--+-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
+-+--+-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
+-+--+-    (range_pullback_subset_fiberConst φ)
+-+--+-
+-+--+-/-! ### §3: Density transport -/
+-+--+-
+-+--+-/-
+-+--+-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
+-+--+--/
+-+--+-theorem closure_range_pullback_eq_fiberConst
+-+--+-    (φ : C(X, Y))
+-+--+-    (A : Subalgebra ℝ C(Y, ℝ))
+-+--+-    (hA : Dense (A : Set C(Y, ℝ))) :
+-+--+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
+-+--+-      = (FiberConst φ : Set C(X, ℝ)) := by
+-+--+-  refine' le_antisymm ( closure_minimal _ _ ) _;
+-+--+-  · exact range_comp_subalgebra_subset_fiberConst φ A;
+-+--+-  · exact fiberConst_closed φ;
+-+--+-  · intro g hg;
+-+--+-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
+-+--+-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
+-+--+-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
+-+--+-    rw [ Metric.mem_closure_iff ];
+-+--+-    intro ε εpos;
+-+--+-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
+-+--+-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
+-+--+-    nontriviality;
+-+--+-    rw [ hF, dist_eq_norm ] at *;
+-+--+-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
+-+--+-
+-+--+-/-
+-+--+-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
+-+--+--/
+-+--+-theorem closure_range_pullback_eq_top_of_injective
+-+--+-    (φ : C(X, Y))
+-+--+-    (hφ : Function.Injective φ)
+-+--+-    (A : Subalgebra ℝ C(Y, ℝ))
+-+--+-    (hA : Dense (A : Set C(Y, ℝ))) :
+-+--+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
+-+--+-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
+-+--+-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
+-+--+-
+-+--+-/-! ### §4: ε-approximation -/
+-+--+-
+-+--+-/-
+-+--+-ε-approximation within `FiberConst φ`.
+-+--+--/
+-+--+-theorem exists_pullback_approx_of_fiberConst
+-+--+-    (φ : C(X, Y))
+-+--+-    (A : Subalgebra ℝ C(Y, ℝ))
+-+--+-    (hA : Dense (A : Set C(Y, ℝ)))
+-+--+-    (g : C(X, ℝ))
+-+--+-    (hg : g ∈ FiberConst φ)
+-+--+-    {ε : ℝ} (hε : 0 < ε) :
+-+--+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
+-+--+-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
+-+--+-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
+-+--+-  rw [ Metric.mem_closure_iff ] at h_closure;
+-+--+-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
+-+--+-
+-+--+-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
+-+--+-theorem exists_pullback_approx_of_injective
+-+--+-    (φ : C(X, Y))
+-+--+-    (hφ : Function.Injective φ)
+-+--+-    (A : Subalgebra ℝ C(Y, ℝ))
+-+--+-    (hA : Dense (A : Set C(Y, ℝ)))
+-+--+-    (g : C(X, ℝ))
+-+--+-    {ε : ℝ} (hε : 0 < ε) :
+-+--+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
+-+--+-  exact exists_pullback_approx_of_fiberConst φ A hA g
+-+--+-    (mem_fiberConst_of_injective φ hφ g) hε+end+--- a/EML/Basic.lean
+-+-++++ b/EML/Basic.lean
+-+-+@@ -1,277 +1,125 @@
+-+-+-/-
+-+-+-Copyright (c) 2026 Harmonic. All rights reserved.
+-+-+-Released under Apache 2.0 license as described in the file LICENSE.
+-+-+--/
+-+-+ import Mathlib
+-+-+ 
+-+-+-/-!
+-+-+-# Pullback Stability of Universal Approximation
+-+-++/-! # CatalogBuild.EML.Basic
+-+-+ 
+-+-+-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
+-+-+-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
+-+-+-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
+-+-+-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
+-+-+-
+-+-+-This establishes a transport principle: universal approximation results (like
+-+-+-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
+-+-+-with the precise target being the fiber-constant functions.
+-+-+-
+-+-+-## Main definitions
+-+-+-
+-+-+-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
+-+-+-  fibers of `φ`.
+-+-+-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
+-+-+-
+-+-+-## Main results
+-+-+-
+-+-+-### Basic properties (§1)
+-+-+-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
+-+-+-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
+-+-+-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
+-+-+-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
+-+-+-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
+-+-+-
+-+-+-### Factorization (§2)
+-+-+-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
+-+-+-  through `Set.range φ`, hence is a pullback (via Tietze extension).
+-+-+-
+-+-+-### Density transport (§3)
+-+-+-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
+-+-+-  subalgebra equals `FiberConst φ`.
+-+-+-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
+-+-+-
+-+-+-### ε-approximation (§4)
+-+-+-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
+-+-+-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
+-+-++Auto-generated from theorem catalog database.
+-+-++Domain: EML
+-+-++Declarations: 15
+-+-+ -/
+-+-+ 
+-+-+-open scoped Topology
+-+-+-open Topology
+-+-++noncomputable section
+-+-+ 
+-+-+-variable {X Y : Type*}
+-+-+-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
+-+-+-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
+-+-++/-- The inverse for hyperbolic SPB is also negation. -/
+-+-++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
+-+-++  simp [spbH]
+-+-+ 
+-+-+-/-! ### §1: Definitions and basic properties -/
+-+-++/-- Wick duality: SPB with negated second argument equals the "difference"
+-+-++in the hyperbolic SPB. This is the real-variable manifestation of the
+-+-++Wick rotation t → it. -/
+-+-++theorem wick_duality (x y : ℝ) :
+-+-++    spb x (-y) = (x - y) / (1 + x * y) := by
+-+-++  simp only [spb]
+-+-++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
+-+-++  rw [heq]; ring
+-+-+ 
+-+-+-/-- Continuous functions on `X` that are constant on fibers of `φ`.
+-+-+-This is the natural functional-analytic object associated to a feature map:
+-+-+-it captures exactly the observables visible through `φ`. -/
+-+-+-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
+-+-+-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
+-+-+-  algebraMap_mem' r := by intro x x' _; simp
+-+-+-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
+-+-+-  zero_mem' := by intro x x' _; simp
+-+-+-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
+-+-+-  one_mem' := by intro x x' _; simp
+-+-++/-- The tangent addition law IS the stereographic sum.
+-+-++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
+-+-++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
+-+-++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
+-+-++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
+-+-++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
+-+-++  field_simp
+-+-+ 
+-+-+-/-- Pullback of continuous real-valued functions along `φ`. -/
+-+-+-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
+-+-+-  toFun f := f.comp φ
+-+-+-  map_zero' := by ext; simp
+-+-+-  map_one' := by ext; simp
+-+-+-  map_add' := by intros; ext; simp
+-+-+-  map_mul' := by intros; ext; simp
+-+-+-  commutes' := by intros; ext; simp
+-+-++/-- SPB expression trees — analogous to EML expression trees. -/
+-+-++inductive SPBExpr where
+-+-++  | zero : SPBExpr
+-+-++  | one : SPBExpr
+-+-++  | var : ℕ → SPBExpr
+-+-++  | node : SPBExpr → SPBExpr → SPBExpr
+-+-++  deriving Repr, BEq
+-+-+ 
+-+-+-@[simp]
+-+-+-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
+-+-+-    pullbackAlg φ f x = f (φ x) := rfl
+-+-++/-- Evaluate an SPB expression. -/
+-+-++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
+-+-++  match e with
+-+-++  | .zero => 0
+-+-++  | .one => 1
+-+-++  | .var n => vars n
+-+-++  | .node l r => spb (l.eval vars) (r.eval vars)
+-+-+ 
+-+-+-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
+-+-+-    pullbackAlg φ f ∈ FiberConst φ := by
+-+-+-  intro x x' h; simp [h]
+-+-++/-- Depth of an SPB expression. -/
+-+-++def SPBExpr.depth : SPBExpr → ℕ
+-+-++  | .zero => 0
+-+-++  | .one => 0
+-+-++  | .var _ => 0
+-+-++  | .node l r => 1 + max l.depth r.depth
+-+-+ 
+-+-+-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
+-+-+-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
+-+-+-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
+-+-++/-- Leaf count. -/
+-+-++def SPBExpr.leafCount : SPBExpr → ℕ
+-+-++  | .zero => 1
+-+-++  | .one => 1
+-+-++  | .var _ => 1
+-+-++  | .node l r => l.leafCount + r.leafCount
+-+-+ 
+-+-+-theorem range_comp_subalgebra_subset_fiberConst
+-+-+-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
+-+-+-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
+-+-+-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
+-+-++/-- Internal node count. -/
+-+-++def SPBExpr.nodeCount : SPBExpr → ℕ
+-+-++  | .zero => 0
+-+-++  | .one => 0
+-+-++  | .var _ => 0
+-+-++  | .node l r => 1 + l.nodeCount + r.nodeCount
+-+-+ 
+-+-+-/-- `FiberConst φ` is closed in the uniform topology. -/
+-+-+-theorem fiberConst_closed (φ : C(X, Y)) :
+-+-+-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
+-+-+-  refine isClosed_of_closure_subset ?_
+-+-+-  intro g hg x x' h
+-+-+-  rw [mem_closure_iff_nhds] at hg
+-+-+-  contrapose! hg
+-+-+-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
+-+-+-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
+-+-+-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
+-+-++/-- Binary tree identity: leaves = internal nodes + 1. -/
+-+-++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
+-+-++    e.leafCount = e.nodeCount + 1 := by
+-+-++  induction e with
+-+-++  | zero => rfl
+-+-++  | one => rfl
+-+-++  | var _ => rfl
+-+-++  | node l r ihl ihr =>
+-+-++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
+-+-++    omega
+-+-+ 
+-+-+-omit [T2Space X] [T2Space Y] in
+-+-+-/-- The pullback map is norm-nonincreasing. -/
+-+-+-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
+-+-+-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
+-+-+-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
+-+-+-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
+-+-++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
+-+-++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
+-+-+ 
+-+-+-/-- When `φ` is surjective, pullback is an isometry. -/
+-+-+-theorem pullback_isometry_of_surjective
+-+-+-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
+-+-+-    ‖pullbackAlg φ f‖ = ‖f‖ := by
+-+-+-  refine le_antisymm (norm_pullback_le φ f) ?_
+-+-+-  rw [ContinuousMap.norm_le _ (by positivity)]
+-+-+-  intro y; obtain ⟨x, rfl⟩ := hφ y
+-+-+-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
+-+-++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
+-+-++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
+-+-++  unfold logisticSigmoid
+-+-++  rw [Real.exp_neg]
+-+-++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
+-+-++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
+-+-++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
+-+-++  field_simp; ring
+-+-+ 
+-+-+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
+-+-+-theorem mem_fiberConst_of_injective
+-+-+-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
+-+-+-    g ∈ FiberConst φ := by
+-+-+-  intro x x' h; exact congrArg g (hφ h)
+-+-++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
+-+-++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
+-+-++  unfold softplus logisticSigmoid
+-+-++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
+-+-++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
+-+-++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
+-+-++  simp at this
+-+-++  exact this
+-+-+ 
+-+-+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
+-+-+-theorem fiberConst_eq_top_of_injective
+-+-+-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
+-+-+-    FiberConst φ = ⊤ := by
+-+-+-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
+-+-++/-- ShefferAlg is closed under affine pre-composition. -/
+-+-++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
+-+-++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
+-+-++  obtain ⟨e, rfl⟩ := hf
+-+-++  exact ⟨.affinePrecomp a b e, rfl⟩
+-+-+ 
+-+-+-omit [CompactSpace Y] [T2Space Y] in
+-+-+-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
+-+-+-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
+-+-+-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
+-+-+-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
+-+-+-  intro x x' hφ; by_contra h_ne
+-+-+-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
+-+-+-    have := exists_continuous_zero_one_of_isClosed
+-+-+-      (show IsClosed {x} from isClosed_singleton)
+-+-+-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
+-+-+-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
+-+-+-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
+-+-+-  replace h := SetLike.ext_iff.mp h g
+-+-+-  simp_all +decide [FiberConst]
+-+-+-  exact absurd (h hφ) (by simp +decide [hg])
+-+-++/-- ShefferAlg is closed under affine combination. -/
+-+-++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
+-+-++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
+-+-++  obtain ⟨ef, rfl⟩ := hf
+-+-++  obtain ⟨eg, rfl⟩ := hg
+-+-++  exact ⟨.affineComb α β γ ef eg, rfl⟩
+-+-+ 
+-+-+-/-! ### §2: Image factorization -/
+-+-++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
+-+-++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
+-+-++  unfold softplus
+-+-++  rw [Real.exp_neg]
+-+-++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
+-+-++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
+-+-++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
+-+-++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
+-+-++  rw [this, Real.log_exp]
+-+-+ 
+-+-+-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
+-+-+-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
+-+-+-
+-+-+-/-
+-+-+-The corestriction `X → Set.range φ` is a quotient map.
+-+-+--/
+-+-+-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
+-+-+-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
+-+-+-  apply IsClosedMap.isQuotientMap;
+-+-+-  · intro s hs;
+-+-+-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
+-+-+-    constructor <;> intro h;
+-+-+-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
+-+-+-    · convert h.preimage ( continuous_subtype_val ) using 1;
+-+-+-      ext; simp [Set.rangeFactorization];
+-+-+-      grind;
+-+-+-  · exact continuous_induced_rng.mpr φ.continuous;
+-+-+-  · exact Set.rangeFactorization_surjective
+-+-+-
+-+-+-/-- Lift a fiber-constant function to `Set.range φ`. -/
+-+-+-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
+-+-+-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
+-+-+-  toFun z := g z.property.choose
+-+-+-  continuous_toFun := by
+-+-+-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
+-+-+-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
+-+-+-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
+-+-+-      ext x; apply hg
+-+-+-      exact (Set.rangeFactorization φ x).property.choose_spec
+-+-+-    rw [this]; exact g.continuous
+-+-+-
+-+-+-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
+-+-+-    (hg : g ∈ FiberConst φ) (x : X) :
+-+-+-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
+-+-+-  simp only [fiberConstLift]
+-+-+-  apply hg
+-+-+-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
+-+-+-
+-+-+-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
+-+-+-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
+-+-+-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
+-+-+-  intro g hg
+-+-+-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
+-+-+-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
+-+-+-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
+-+-+-  refine ⟨F, ?_⟩
+-+-+-  ext x
+-+-+-  simp only [pullbackAlg_apply]
+-+-+-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
+-+-+-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
+-+-+-    simp [ContinuousMap.comp_apply] at this; exact this
+-+-+-  rw [key, fiberConstLift_comp]
+-+-+-
+-+-+-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
+-+-+-theorem fiberConst_eq_range_pullback_of_surjective
+-+-+-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
+-+-+-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
+-+-+-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
+-+-+-    (range_pullback_subset_fiberConst φ)
+-+-+-
+-+-+-/-! ### §3: Density transport -/
+-+-+-
+-+-+-/-
+-+-+-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
+-+-+--/
+-+-+-theorem closure_range_pullback_eq_fiberConst
+-+-+-    (φ : C(X, Y))
+-+-+-    (A : Subalgebra ℝ C(Y, ℝ))
+-+-+-    (hA : Dense (A : Set C(Y, ℝ))) :
+-+-+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
+-+-+-      = (FiberConst φ : Set C(X, ℝ)) := by
+-+-+-  refine' le_antisymm ( closure_minimal _ _ ) _;
+-+-+-  · exact range_comp_subalgebra_subset_fiberConst φ A;
+-+-+-  · exact fiberConst_closed φ;
+-+-+-  · intro g hg;
+-+-+-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
+-+-+-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
+-+-+-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
+-+-+-    rw [ Metric.mem_closure_iff ];
+-+-+-    intro ε εpos;
+-+-+-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
+-+-+-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
+-+-+-    nontriviality;
+-+-+-    rw [ hF, dist_eq_norm ] at *;
+-+-+-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
+-+-+-
+-+-+-/-
+-+-+-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
+-+-+--/
+-+-+-theorem closure_range_pullback_eq_top_of_injective
+-+-+-    (φ : C(X, Y))
+-+-+-    (hφ : Function.Injective φ)
+-+-+-    (A : Subalgebra ℝ C(Y, ℝ))
+-+-+-    (hA : Dense (A : Set C(Y, ℝ))) :
+-+-+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
+-+-+-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
+-+-+-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
+-+-+-
+-+-+-/-! ### §4: ε-approximation -/
+-+-+-
+-+-+-/-
+-+-+-ε-approximation within `FiberConst φ`.
+-+-+--/
+-+-+-theorem exists_pullback_approx_of_fiberConst
+-+-+-    (φ : C(X, Y))
+-+-+-    (A : Subalgebra ℝ C(Y, ℝ))
+-+-+-    (hA : Dense (A : Set C(Y, ℝ)))
+-+-+-    (g : C(X, ℝ))
+-+-+-    (hg : g ∈ FiberConst φ)
+-+-+-    {ε : ℝ} (hε : 0 < ε) :
+-+-+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
+-+-+-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
+-+-+-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
+-+-+-  rw [ Metric.mem_closure_iff ] at h_closure;
+-+-+-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
+-+-+-
+-+-+-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
+-+-+-theorem exists_pullback_approx_of_injective
+-+-+-    (φ : C(X, Y))
+-+-+-    (hφ : Function.Injective φ)
+-+-+-    (A : Subalgebra ℝ C(Y, ℝ))
+-+-+-    (hA : Dense (A : Set C(Y, ℝ)))
+-+-+-    (g : C(X, ℝ))
+-+-+-    {ε : ℝ} (hε : 0 < ε) :
+-+-+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
+-+-+-  exact exists_pullback_approx_of_fiberConst φ A hA g
+-+-+-    (mem_fiberConst_of_injective φ hφ g) hε+end+--- a/EML/Basic.lean
+-+++++ b/EML/Basic.lean
+-++@@ -1,277 +1,125 @@
+-++-/-
+-++-Copyright (c) 2026 Harmonic. All rights reserved.
+-++-Released under Apache 2.0 license as described in the file LICENSE.
+-++--/
+-++ import Mathlib
+-++ 
+-++-/-!
+-++-# Pullback Stability of Universal Approximation
+-+++/-! # CatalogBuild.EML.Basic
+-++ 
+-++-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
+-++-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
+-++-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
+-++-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
+-++-
+-++-This establishes a transport principle: universal approximation results (like
+-++-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
+-++-with the precise target being the fiber-constant functions.
+-++-
+-++-## Main definitions
+-++-
+-++-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
+-++-  fibers of `φ`.
+-++-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
+-++-
+-++-## Main results
+-++-
+-++-### Basic properties (§1)
+-++-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
+-++-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
+-++-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
+-++-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
+-++-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
+-++-
+-++-### Factorization (§2)
+-++-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
+-++-  through `Set.range φ`, hence is a pullback (via Tietze extension).
+-++-
+-++-### Density transport (§3)
+-++-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
+-++-  subalgebra equals `FiberConst φ`.
+-++-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
+-++-
+-++-### ε-approximation (§4)
+-++-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
+-++-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
+-+++Auto-generated from theorem catalog database.
+-+++Domain: EML
+-+++Declarations: 15
+- + -/
+- + 
++--- a/Tropical/Basic.lean
+++++ b/Tropical/Basic.lean
++@@ -1,1315 +1,383 @@
++---- a/Tropical/Basic.lean
++-+++ b/Tropical/Basic.lean
++-@@ -1,930 +1,383 @@
++----- a/Tropical/Basic.lean
++--+++ b/Tropical/Basic.lean
++--@@ -1,545 +1,383 @@
++------ a/Tropical/Basic.lean
++---+++ b/Tropical/Basic.lean
++---@@ -1,383 +1,160 @@
++------- a/EML/Basic.lean
++----+++ b/EML/Basic.lean
++----@@ -1,277 +1,125 @@
++-----/-
++-----Copyright (c) 2026 Harmonic. All rights reserved.
++-----Released under Apache 2.0 license as described in the file LICENSE.
++------/
++---- import Mathlib
++---- 
++-----/-!
++-----# Pullback Stability of Universal Approximation
++----+/-! # CatalogBuild.EML.Basic
++---- 
++-----Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
++-----subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
++-----closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
++-----When `φ` is injective, this gives density in all of `C(X, ℝ)`.
++-----
++-----This establishes a transport principle: universal approximation results (like
++-----Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
++-----with the precise target being the fiber-constant functions.
++-----
++-----## Main definitions
++-----
++-----* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
++-----  fibers of `φ`.
++-----* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
++-----
++-----## Main results
++-----
++-----### Basic properties (§1)
++-----* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
++-----* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
++-----* `norm_pullback_le` — the pullback map is norm-nonincreasing.
++-----* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
++-----* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
++-----
++-----### Factorization (§2)
++-----* `fiberConst_subset_range_pullback` — every fiber-constant function factors
++-----  through `Set.range φ`, hence is a pullback (via Tietze extension).
++-----
++-----### Density transport (§3)
++-----* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
++-----  subalgebra equals `FiberConst φ`.
++-----* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
++-----
++-----### ε-approximation (§4)
++-----* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
++-----* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
++----+Auto-generated from theorem catalog database.
++----+Domain: EML
++----+Declarations: 15
++---- -/
++---- 
++-----open scoped Topology
++-----open Topology
++----+noncomputable section
++---- 
++-----variable {X Y : Type*}
++-----variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
++-----variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
++----+/-- The inverse for hyperbolic SPB is also negation. -/
++----+theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
++----+  simp [spbH]
++---- 
++-----/-! ### §1: Definitions and basic properties -/
++----+/-- Wick duality: SPB with negated second argument equals the "difference"
++----+in the hyperbolic SPB. This is the real-variable manifestation of the
++----+Wick rotation t → it. -/
++----+theorem wick_duality (x y : ℝ) :
++----+    spb x (-y) = (x - y) / (1 + x * y) := by
++----+  simp only [spb]
++----+  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
++----+  rw [heq]; ring
++---- 
++-----/-- Continuous functions on `X` that are constant on fibers of `φ`.
++-----This is the natural functional-analytic object associated to a feature map:
++-----it captures exactly the observables visible through `φ`. -/
++-----def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
++-----  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
++-----  algebraMap_mem' r := by intro x x' _; simp
++-----  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
++-----  zero_mem' := by intro x x' _; simp
++-----  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
++-----  one_mem' := by intro x x' _; simp
++----+/-- The tangent addition law IS the stereographic sum.
++----+tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
++----+theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
++----+    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
++----+  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
++----+      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
++----+  field_simp
++---- 
++-----/-- Pullback of continuous real-valued functions along `φ`. -/
++-----def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
++-----  toFun f := f.comp φ
++-----  map_zero' := by ext; simp
++-----  map_one' := by ext; simp
++-----  map_add' := by intros; ext; simp
++-----  map_mul' := by intros; ext; simp
++-----  commutes' := by intros; ext; simp
++----+/-- SPB expression trees — analogous to EML expression trees. -/
++----+inductive SPBExpr where
++----+  | zero : SPBExpr
++----+  | one : SPBExpr
++----+  | var : ℕ → SPBExpr
++----+  | node : SPBExpr → SPBExpr → SPBExpr
++----+  deriving Repr, BEq
++---- 
++-----@[simp]
++-----theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
++-----    pullbackAlg φ f x = f (φ x) := rfl
++----+/-- Evaluate an SPB expression. -/
++----+def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
++----+  match e with
++----+  | .zero => 0
++----+  | .one => 1
++----+  | .var n => vars n
++----+  | .node l r => spb (l.eval vars) (r.eval vars)
++---- 
++-----theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
++-----    pullbackAlg φ f ∈ FiberConst φ := by
++-----  intro x x' h; simp [h]
++----+/-- Depth of an SPB expression. -/
++----+def SPBExpr.depth : SPBExpr → ℕ
++----+  | .zero => 0
++----+  | .one => 0
++----+  | .var _ => 0
++----+  | .node l r => 1 + max l.depth r.depth
++---- 
++-----theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
++-----    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
++-----  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
++----+/-- Leaf count. -/
++----+def SPBExpr.leafCount : SPBExpr → ℕ
++----+  | .zero => 1
++----+  | .one => 1
++----+  | .var _ => 1
++----+  | .node l r => l.leafCount + r.leafCount
++---- 
++-----theorem range_comp_subalgebra_subset_fiberConst
++-----    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
++-----    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
++-----  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
++----+/-- Internal node count. -/
++----+def SPBExpr.nodeCount : SPBExpr → ℕ
++----+  | .zero => 0
++----+  | .one => 0
++----+  | .var _ => 0
++----+  | .node l r => 1 + l.nodeCount + r.nodeCount
++---- 
++-----/-- `FiberConst φ` is closed in the uniform topology. -/
++-----theorem fiberConst_closed (φ : C(X, Y)) :
++-----    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
++-----  refine isClosed_of_closure_subset ?_
++-----  intro g hg x x' h
++-----  rw [mem_closure_iff_nhds] at hg
++-----  contrapose! hg
++-----  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
++-----    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
++-----    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
++----+/-- Binary tree identity: leaves = internal nodes + 1. -/
++----+theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
++----+    e.leafCount = e.nodeCount + 1 := by
++----+  induction e with
++----+  | zero => rfl
++----+  | one => rfl
++----+  | var _ => rfl
++----+  | node l r ihl ihr =>
++----+    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
++----+    omega
++---- 
++-----omit [T2Space X] [T2Space Y] in
++-----/-- The pullback map is norm-nonincreasing. -/
++-----theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
++-----    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
++-----  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
++-----    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
++----+/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
++----+def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
++---- 
++-----/-- When `φ` is surjective, pullback is an isometry. -/
++-----theorem pullback_isometry_of_surjective
++-----    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
++-----    ‖pullbackAlg φ f‖ = ‖f‖ := by
++-----  refine le_antisymm (norm_pullback_le φ f) ?_
++-----  rw [ContinuousMap.norm_le _ (by positivity)]
++-----  intro y; obtain ⟨x, rfl⟩ := hφ y
++-----  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
++----+/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
++----+theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
++----+  unfold logisticSigmoid
++----+  rw [Real.exp_neg]
++----+  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
++----+  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
++----+  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
++----+  field_simp; ring
++---- 
++-----omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
++-----theorem mem_fiberConst_of_injective
++-----    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
++-----    g ∈ FiberConst φ := by
++-----  intro x x' h; exact congrArg g (hφ h)
++----+/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
++----+theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
++----+  unfold softplus logisticSigmoid
++----+  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
++----+  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
++----+  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
++----+  simp at this
++----+  exact this
++---- 
++-----omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
++-----theorem fiberConst_eq_top_of_injective
++-----    (φ : C(X, Y)) (hφ : Function.Injective φ) :
++-----    FiberConst φ = ⊤ := by
++-----  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
++----+/-- ShefferAlg is closed under affine pre-composition. -/
++----+theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
++----+    (fun x => f (a * x + b)) ∈ ShefferAlg := by
++----+  obtain ⟨e, rfl⟩ := hf
++----+  exact ⟨.affinePrecomp a b e, rfl⟩
++---- 
++-----omit [CompactSpace Y] [T2Space Y] in
++-----/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
++-----theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
++-----    FiberConst φ = ⊤ ↔ Function.Injective φ := by
++-----  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
++-----  intro x x' hφ; by_contra h_ne
++-----  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
++-----    have := exists_continuous_zero_one_of_isClosed
++-----      (show IsClosed {x} from isClosed_singleton)
++-----      (show IsClosed {x'} from isClosed_singleton) (by aesop)
++-----    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
++-----      this.choose_spec.2.1 (Set.mem_singleton x')⟩
++-----  replace h := SetLike.ext_iff.mp h g
++-----  simp_all +decide [FiberConst]
++-----  exact absurd (h hφ) (by simp +decide [hg])
++----+/-- ShefferAlg is closed under affine combination. -/
++----+theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
++----+    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
++----+  obtain ⟨ef, rfl⟩ := hf
++----+  obtain ⟨eg, rfl⟩ := hg
++----+  exact ⟨.affineComb α β γ ef eg, rfl⟩
++---- 
++-----/-! ### §2: Image factorization -/
++----+/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
++----+theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
++----+  unfold softplus
++----+  rw [Real.exp_neg]
++----+  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
++----+  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
++----+  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
++----+  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
++----+  rw [this, Real.log_exp]
++---- 
++-----instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
++-----  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
++-----
++-----/-
++-----The corestriction `X → Set.range φ` is a quotient map.
++------/
++-----theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
++-----    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
++-----  apply IsClosedMap.isQuotientMap;
++-----  · intro s hs;
++-----    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
++-----    constructor <;> intro h;
++-----    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
++-----    · convert h.preimage ( continuous_subtype_val ) using 1;
++-----      ext; simp [Set.rangeFactorization];
++-----      grind;
++-----  · exact continuous_induced_rng.mpr φ.continuous;
++-----  · exact Set.rangeFactorization_surjective
++-----
++-----/-- Lift a fiber-constant function to `Set.range φ`. -/
++-----noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
++-----    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
++-----  toFun z := g z.property.choose
++-----  continuous_toFun := by
++-----    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
++-----    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
++-----    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
++-----      ext x; apply hg
++-----      exact (Set.rangeFactorization φ x).property.choose_spec
++-----    rw [this]; exact g.continuous
++-----
++-----theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
++-----    (hg : g ∈ FiberConst φ) (x : X) :
++-----    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
++-----  simp only [fiberConstLift]
++-----  apply hg
++-----  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
++-----
++-----/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
++-----theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
++-----    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
++-----  intro g hg
++-----  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
++-----  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
++-----    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
++-----  refine ⟨F, ?_⟩
++-----  ext x
++-----  simp only [pullbackAlg_apply]
++-----  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
++-----    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
++-----    simp [ContinuousMap.comp_apply] at this; exact this
++-----  rw [key, fiberConstLift_comp]
++-----
++-----/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
++-----theorem fiberConst_eq_range_pullback_of_surjective
++-----    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
++-----    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
++-----  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
++-----    (range_pullback_subset_fiberConst φ)
++-----
++-----/-! ### §3: Density transport -/
++-----
++-----/-
++-----The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
++------/
++-----theorem closure_range_pullback_eq_fiberConst
++-----    (φ : C(X, Y))
++-----    (A : Subalgebra ℝ C(Y, ℝ))
++-----    (hA : Dense (A : Set C(Y, ℝ))) :
++-----    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
++-----      = (FiberConst φ : Set C(X, ℝ)) := by
++-----  refine' le_antisymm ( closure_minimal _ _ ) _;
++-----  · exact range_comp_subalgebra_subset_fiberConst φ A;
++-----  · exact fiberConst_closed φ;
++-----  · intro g hg;
++-----    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
++-----    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
++-----      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
++-----    rw [ Metric.mem_closure_iff ];
++-----    intro ε εpos;
++-----    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
++-----    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
++-----    nontriviality;
++-----    rw [ hF, dist_eq_norm ] at *;
++-----    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
++-----
++-----/-
++-----Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
++------/
++-----theorem closure_range_pullback_eq_top_of_injective
++-----    (φ : C(X, Y))
++-----    (hφ : Function.Injective φ)
++-----    (A : Subalgebra ℝ C(Y, ℝ))
++-----    (hA : Dense (A : Set C(Y, ℝ))) :
++-----    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
++-----  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
++-----  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
++-----
++-----/-! ### §4: ε-approximation -/
++-----
++-----/-
++-----ε-approximation within `FiberConst φ`.
++------/
++-----theorem exists_pullback_approx_of_fiberConst
++-----    (φ : C(X, Y))
++-----    (A : Subalgebra ℝ C(Y, ℝ))
++-----    (hA : Dense (A : Set C(Y, ℝ)))
++-----    (g : C(X, ℝ))
++-----    (hg : g ∈ FiberConst φ)
++-----    {ε : ℝ} (hε : 0 < ε) :
++-----    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
++-----  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
++-----    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
++-----  rw [ Metric.mem_closure_iff ] at h_closure;
++-----  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
++-----
++-----/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
++-----theorem exists_pullback_approx_of_injective
++-----    (φ : C(X, Y))
++-----    (hφ : Function.Injective φ)
++-----    (A : Subalgebra ℝ C(Y, ℝ))
++-----    (hA : Dense (A : Set C(Y, ℝ)))
++-----    (g : C(X, ℝ))
++-----    {ε : ℝ} (hε : 0 < ε) :
++-----    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
++-----  exact exists_pullback_approx_of_fiberConst φ A hA g
++-----    (mem_fiberConst_of_injective φ hφ g) hε+end+/-
++---+Copyright (c) 2025. All rights reserved.
++---+Released under Apache 2.0 license as described in the file LICENSE.
++---+-/
++---+import Mathlib
++---+
++---+/-!
++---+# GL₃ Tropical Satake: Core Definitions
++---+
++---+This file establishes the foundational types and operations for the GL₃ tropical
++---+Satake finite-determinacy theory.
++---+
++---+## Overview
++---+
++---+For GL₃, a **dominant coweight** is a triple `(a, b, c) ∈ ℕ³` with `a ≥ b ≥ c`.
++---+The **dominant box** `BoxDom(B)` is the finite set of dominant coweights with `a ≤ B`.
++---+
++---+We define three families of **tropical Satake observables**, corresponding to the
++---+three fundamental representations `ω₁, ω₂, ω₃` of GL₃:
++---+
++---+1. **Rank-1 profile** (`rank1Profile`): tropical convolution with the standard
++---+   representation character. Uses the weights `e₁, e₂, e₃`.
++---+2. **Rank-2 profile** (`rank2Profile`): tropical convolution with the exterior square
++---+   character. Uses the weights `e₁+e₂, e₁+e₃, e₂+e₃`.
++---+3. **Edge moment** (`edgeMoment`): tropical convolution with the determinant character
++---+   `ω₃ = (1,1,1)`. This is the key reconstruction tool: as a shift operator, it
++---+   recovers function values without the information loss inherent in max operations.
++---+
++---+The finite-determinacy theorem (proved in `FiniteDeterminacy.lean`) shows that
++---+equality of these observables on finite test sets forces equality of the underlying
++---+functions.
++---+-/
++---+
++---+open Finset
++---+
++---+/-! ### Dominance and support conditions -/
++---+
++---+/-- A triple `(a, b, c)` is dominant if `a ≥ b ≥ c`. -/
++---+def IsDominant (a b c : ℕ) : Prop := b ≤ a ∧ c ≤ b
++---+
++---+/-- A function on `ℕ³` has finite support within box `B` if it vanishes outside
++---+    the dominant box `{(a,b,c) : b ≤ a, c ≤ b, a ≤ B}`. -/
++---+def FiniteSupportWithin (B : ℕ) (f : ℕ → ℕ → ℕ → ℤ) : Prop :=
++---+  ∀ a b c : ℕ, (B < a ∨ a < b ∨ b < c) → f a b c = 0
++---+
++---+/-- The box `BoxDom(B)` as a `Finset` of triples. -/
++---+def boxDomFinset (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
++---+  (Finset.range (B + 1) ×ˢ Finset.range (B + 1) ×ˢ Finset.range (B + 1)).filter
++---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
++---+
++---+lemma mem_boxDomFinset {B : ℕ} {a b c : ℕ} :
++---+    (a, b, c) ∈ boxDomFinset B ↔ a ≤ B ∧ b ≤ a ∧ c ≤ b := by
++---+  simp [boxDomFinset, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
++---+  omega
++---+
++---+/-! ### Tropical Satake observables -/
++---+
++---+/-- **Rank-1 profile**: tropical convolution with the standard representation `ω₁`.
++---+
++---+The weights of the standard representation of GL₃ are `e₁ = (1,0,0)`,
++---+`e₂ = (0,1,0)`, `e₃ = (0,0,1)`. The rank-1 profile at `(a,b,c)` is
++---+`max{f(a-1,b,c), f(a,b-1,c), f(a,b,c-1)}` with appropriate guards for ℕ subtraction.
++---+
++---+Note: Invalid shifts (where subtraction would go below 0) contribute the value `0`,
++---+which serves as the tropical "zero" in this ℤ-valued model. -/
++---+def rank1Profile (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
++---+  let v1 := if 1 ≤ a then f (a - 1) b c else 0
++---+  let v2 := if 1 ≤ b then f a (b - 1) c else 0
++---+  let v3 := if 1 ≤ c then f a b (c - 1) else 0
++---+  max v1 (max v2 v3)
++---+
++---+/-- **Rank-2 profile**: tropical convolution with the exterior square `ω₂ = ∧²`.
++---+
++---+The weights of `∧²(ℂ³)` are `e₁+e₂ = (1,1,0)`, `e₁+e₃ = (1,0,1)`,
++---+`e₂+e₃ = (0,1,1)`. The rank-2 profile at `(a,b,c)` is
++---+`max{f(a-1,b-1,c), f(a-1,b,c-1), f(a,b-1,c-1)}`. -/
++---+def rank2Profile (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
++---+  let v1 := if 1 ≤ a ∧ 1 ≤ b then f (a - 1) (b - 1) c else 0
++---+  let v2 := if 1 ≤ a ∧ 1 ≤ c then f (a - 1) b (c - 1) else 0
++---+  let v3 := if 1 ≤ b ∧ 1 ≤ c then f a (b - 1) (c - 1) else 0
++---+  max v1 (max v2 v3)
++---+
++---+/-- **Edge moment**: tropical convolution with the determinant character `ω₃ = (1,1,1)`.
++---+
++---+This is the shift operator: `edgeMoment f (a,b,c) = f(a-1, b-1, c-1)`.
++---+As a representation-theoretic operation, it corresponds to convolution with the
++---+one-dimensional determinant representation `det = ∧³(ℂ³)`. Unlike the rank-1 and
++---+rank-2 profiles (which use `max` and can lose information), the determinant
++---+convolution perfectly preserves all function values.
++---+
++---+This is the key observable that makes finite determinacy possible: it acts as an
++---+exact reconstruction tool rather than a lossy tropical projection. -/
++---+def edgeMoment (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
++---+  if 1 ≤ a ∧ 1 ≤ b ∧ 1 ≤ c then f (a - 1) (b - 1) (c - 1) else 0
++---+
++---+/-- Combined triple convolution observable using both rank-1 and rank-2 generators.
++---+    This packages rank-1 and rank-2 data together for the combined hypothesis form. -/
++---+def tripleConvObservable (f : ℕ → ℕ → ℕ → ℤ) (t s : ℕ × ℕ × ℕ) : ℤ :=
++---+  rank1Profile f t.1 t.2.1 t.2.2 + rank2Profile f s.1 s.2.1 s.2.2
++---+
++---+/-! ### Finite test ranges -/
++---+
++---+/-- The finite range of rank-1 test parameters determined by box bound `B`. -/
++---+def finiteRank1Range (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
++---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
++---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
++---+
++---+/-- The finite range of rank-2 test parameters determined by box bound `B`. -/
++---+def finiteRank2Range (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
++---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
++---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
++---+
++---+/-- The finite range of edge moment test parameters determined by box bound `B`.
++---+    These are the shifted dominant coweights `(a+1, b+1, c+1)` for `(a,b,c) ∈ BoxDom(B)`. -/
++---+def finiteEdgeMomentRange (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
++---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
++---+    fun ⟨a, b, c⟩ => 1 ≤ c ∧ c ≤ b ∧ b ≤ a
++---+
++---+/-! ### Key computation lemmas -/
++---+
++---+/-- The edge moment at a shifted point exactly recovers the function value.
++---+    This is the fundamental reconstruction identity. -/
++---+@[simp]
++---+lemma edgeMoment_succ (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) :
++---+    edgeMoment f (a + 1) (b + 1) (c + 1) = f a b c := by
++---+  simp [edgeMoment]
++---+
++---+/-- Shifted dominant coweights lie in the edge moment range. -/
++---+lemma shifted_mem_finiteEdgeMomentRange {B a b c : ℕ}
++---+    (haB : a ≤ B) (hab : b ≤ a) (hbc : c ≤ b) :
++---+    (a + 1, b + 1, c + 1) ∈ finiteEdgeMomentRange B := by
++---+  simp [finiteEdgeMomentRange, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
++---+  omega
++---+
++---+/-- The rank-2 profile at the floor level `(a+1, b+1, 0)` yields `max(f(a,b,0), 0)`.
++---+    When `f` is nonneg-valued on the floor, this equals `f(a,b,0)`.
++---+    The `c = 0` case is special because both `ω₂`-weight shifts involving `c-1`
++---+    fall outside `ℕ`, leaving only the `(1,1,0)`-weight shift. -/
++---+lemma rank2Profile_floor_level (f : ℕ → ℕ → ℕ → ℤ) (a b : ℕ) :
++---+    rank2Profile f (a + 1) (b + 1) 0 = max (f a b 0) 0 := by
++---+  simp [rank2Profile]
++---+
++---+/-- For functions supported in `BoxDom(B)`, values at `a > B` vanish. -/
++---+lemma FiniteSupportWithin.vanish_above {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
++---+    (hf : FiniteSupportWithin B f) {a : ℕ} (ha : B < a) (b c : ℕ) :
++---+    f a b c = 0 := by
++---+  exact hf a b c (Or.inl ha)
++---+
++---+/-- For functions supported in `BoxDom(B)`, values outside dominant cone vanish. -/
++---+lemma FiniteSupportWithin.vanish_nondominant {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
++---+    (hf : FiniteSupportWithin B f) {a b c : ℕ} (h : a < b ∨ b < c) :
++---+    f a b c = 0 := by
++---+  exact hf a b c (by tauto)
++---+
++---+/-- Bounded-support functions vanish outside the box: explicit formulation. -/
++---+lemma bounded_support_implies_vanishing_outside {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
++---+    (hf : FiniteSupportWithin B f) {a b c : ℕ}
++---+    (h : ¬(a ≤ B ∧ b ≤ a ∧ c ≤ b)) :
++---+    f a b c = 0 := by
++---+  apply hf; push_neg at h; omega+--- a/EML/Basic.lean
++--++++ b/EML/Basic.lean
++--+@@ -1,277 +1,125 @@
++--+-/-
++--+-Copyright (c) 2026 Harmonic. All rights reserved.
++--+-Released under Apache 2.0 license as described in the file LICENSE.
++--+--/
++--+ import Mathlib
++--+ 
++--+-/-!
++--+-# Pullback Stability of Universal Approximation
++--++/-! # CatalogBuild.EML.Basic
++--+ 
++--+-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
++--+-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
++--+-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
++--+-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
++--+-
++--+-This establishes a transport principle: universal approximation results (like
++--+-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
++--+-with the precise target being the fiber-constant functions.
++--+-
++--+-## Main definitions
++--+-
++--+-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
++--+-  fibers of `φ`.
++--+-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
++--+-
++--+-## Main results
++--+-
++--+-### Basic properties (§1)
++--+-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
++--+-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
++--+-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
++--+-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
++--+-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
++--+-
++--+-### Factorization (§2)
++--+-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
++--+-  through `Set.range φ`, hence is a pullback (via Tietze extension).
++--+-
++--+-### Density transport (§3)
++--+-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
++--+-  subalgebra equals `FiberConst φ`.
++--+-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
++--+-
++--+-### ε-approximation (§4)
++--+-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
++--+-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
++--++Auto-generated from theorem catalog database.
++--++Domain: EML
++--++Declarations: 15
++--+ -/
++--+ 
++--+-open scoped Topology
++--+-open Topology
++--++noncomputable section
++--+ 
++--+-variable {X Y : Type*}
++--+-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
++--+-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
++--++/-- The inverse for hyperbolic SPB is also negation. -/
++--++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
++--++  simp [spbH]
++--+ 
++--+-/-! ### §1: Definitions and basic properties -/
++--++/-- Wick duality: SPB with negated second argument equals the "difference"
++--++in the hyperbolic SPB. This is the real-variable manifestation of the
++--++Wick rotation t → it. -/
++--++theorem wick_duality (x y : ℝ) :
++--++    spb x (-y) = (x - y) / (1 + x * y) := by
++--++  simp only [spb]
++--++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
++--++  rw [heq]; ring
++--+ 
++--+-/-- Continuous functions on `X` that are constant on fibers of `φ`.
++--+-This is the natural functional-analytic object associated to a feature map:
++--+-it captures exactly the observables visible through `φ`. -/
++--+-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
++--+-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
++--+-  algebraMap_mem' r := by intro x x' _; simp
++--+-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
++--+-  zero_mem' := by intro x x' _; simp
++--+-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
++--+-  one_mem' := by intro x x' _; simp
++--++/-- The tangent addition law IS the stereographic sum.
++--++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
++--++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
++--++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
++--++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
++--++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
++--++  field_simp
++--+ 
++--+-/-- Pullback of continuous real-valued functions along `φ`. -/
++--+-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
++--+-  toFun f := f.comp φ
++--+-  map_zero' := by ext; simp
++--+-  map_one' := by ext; simp
++--+-  map_add' := by intros; ext; simp
++--+-  map_mul' := by intros; ext; simp
++--+-  commutes' := by intros; ext; simp
++--++/-- SPB expression trees — analogous to EML expression trees. -/
++--++inductive SPBExpr where
++--++  | zero : SPBExpr
++--++  | one : SPBExpr
++--++  | var : ℕ → SPBExpr
++--++  | node : SPBExpr → SPBExpr → SPBExpr
++--++  deriving Repr, BEq
++--+ 
++--+-@[simp]
++--+-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
++--+-    pullbackAlg φ f x = f (φ x) := rfl
++--++/-- Evaluate an SPB expression. -/
++--++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
++--++  match e with
++--++  | .zero => 0
++--++  | .one => 1
++--++  | .var n => vars n
++--++  | .node l r => spb (l.eval vars) (r.eval vars)
++--+ 
++--+-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
++--+-    pullbackAlg φ f ∈ FiberConst φ := by
++--+-  intro x x' h; simp [h]
++--++/-- Depth of an SPB expression. -/
++--++def SPBExpr.depth : SPBExpr → ℕ
++--++  | .zero => 0
++--++  | .one => 0
++--++  | .var _ => 0
++--++  | .node l r => 1 + max l.depth r.depth
++--+ 
++--+-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
++--+-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
++--+-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
++--++/-- Leaf count. -/
++--++def SPBExpr.leafCount : SPBExpr → ℕ
++--++  | .zero => 1
++--++  | .one => 1
++--++  | .var _ => 1
++--++  | .node l r => l.leafCount + r.leafCount
++--+ 
++--+-theorem range_comp_subalgebra_subset_fiberConst
++--+-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
++--+-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
++--+-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
++--++/-- Internal node count. -/
++--++def SPBExpr.nodeCount : SPBExpr → ℕ
++--++  | .zero => 0
++--++  | .one => 0
++--++  | .var _ => 0
++--++  | .node l r => 1 + l.nodeCount + r.nodeCount
++--+ 
++--+-/-- `FiberConst φ` is closed in the uniform topology. -/
++--+-theorem fiberConst_closed (φ : C(X, Y)) :
++--+-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
++--+-  refine isClosed_of_closure_subset ?_
++--+-  intro g hg x x' h
++--+-  rw [mem_closure_iff_nhds] at hg
++--+-  contrapose! hg
++--+-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
++--+-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
++--+-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
++--++/-- Binary tree identity: leaves = internal nodes + 1. -/
++--++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
++--++    e.leafCount = e.nodeCount + 1 := by
++--++  induction e with
++--++  | zero => rfl
++--++  | one => rfl
++--++  | var _ => rfl
++--++  | node l r ihl ihr =>
++--++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
++--++    omega
++--+ 
++--+-omit [T2Space X] [T2Space Y] in
++--+-/-- The pullback map is norm-nonincreasing. -/
++--+-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
++--+-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
++--+-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
++--+-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
++--++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
++--++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
++--+ 
++--+-/-- When `φ` is surjective, pullback is an isometry. -/
++--+-theorem pullback_isometry_of_surjective
++--+-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
++--+-    ‖pullbackAlg φ f‖ = ‖f‖ := by
++--+-  refine le_antisymm (norm_pullback_le φ f) ?_
++--+-  rw [ContinuousMap.norm_le _ (by positivity)]
++--+-  intro y; obtain ⟨x, rfl⟩ := hφ y
++--+-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
++--++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
++--++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
++--++  unfold logisticSigmoid
++--++  rw [Real.exp_neg]
++--++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
++--++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
++--++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
++--++  field_simp; ring
++--+ 
++--+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
++--+-theorem mem_fiberConst_of_injective
++--+-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
++--+-    g ∈ FiberConst φ := by
++--+-  intro x x' h; exact congrArg g (hφ h)
++--++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
++--++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
++--++  unfold softplus logisticSigmoid
++--++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
++--++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
++--++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
++--++  simp at this
++--++  exact this
++--+ 
++--+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
++--+-theorem fiberConst_eq_top_of_injective
++--+-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
++--+-    FiberConst φ = ⊤ := by
++--+-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
++--++/-- ShefferAlg is closed under affine pre-composition. -/
++--++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
++--++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
++--++  obtain ⟨e, rfl⟩ := hf
++--++  exact ⟨.affinePrecomp a b e, rfl⟩
++--+ 
++--+-omit [CompactSpace Y] [T2Space Y] in
++--+-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
++--+-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
++--+-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
++--+-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
++--+-  intro x x' hφ; by_contra h_ne
++--+-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
++--+-    have := exists_continuous_zero_one_of_isClosed
++--+-      (show IsClosed {x} from isClosed_singleton)
++--+-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
++--+-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
++--+-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
++--+-  replace h := SetLike.ext_iff.mp h g
++--+-  simp_all +decide [FiberConst]
++--+-  exact absurd (h hφ) (by simp +decide [hg])
++--++/-- ShefferAlg is closed under affine combination. -/
++--++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
++--++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
++--++  obtain ⟨ef, rfl⟩ := hf
++--++  obtain ⟨eg, rfl⟩ := hg
++--++  exact ⟨.affineComb α β γ ef eg, rfl⟩
++--+ 
++--+-/-! ### §2: Image factorization -/
++--++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
++--++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
++--++  unfold softplus
++--++  rw [Real.exp_neg]
++--++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
++--++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
++--++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
++--++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
++--++  rw [this, Real.log_exp]
++--+ 
++--+-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
++--+-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
++--+-
++--+-/-
++--+-The corestriction `X → Set.range φ` is a quotient map.
++--+--/
++--+-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
++--+-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
++--+-  apply IsClosedMap.isQuotientMap;
++--+-  · intro s hs;
++--+-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
++--+-    constructor <;> intro h;
++--+-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
++--+-    · convert h.preimage ( continuous_subtype_val ) using 1;
++--+-      ext; simp [Set.rangeFactorization];
++--+-      grind;
++--+-  · exact continuous_induced_rng.mpr φ.continuous;
++--+-  · exact Set.rangeFactorization_surjective
++--+-
++--+-/-- Lift a fiber-constant function to `Set.range φ`. -/
++--+-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
++--+-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
++--+-  toFun z := g z.property.choose
++--+-  continuous_toFun := by
++--+-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
++--+-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
++--+-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
++--+-      ext x; apply hg
++--+-      exact (Set.rangeFactorization φ x).property.choose_spec
++--+-    rw [this]; exact g.continuous
++--+-
++--+-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
++--+-    (hg : g ∈ FiberConst φ) (x : X) :
++--+-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
++--+-  simp only [fiberConstLift]
++--+-  apply hg
++--+-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
++--+-
++--+-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
++--+-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
++--+-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
++--+-  intro g hg
++--+-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
++--+-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
++--+-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
++--+-  refine ⟨F, ?_⟩
++--+-  ext x
++--+-  simp only [pullbackAlg_apply]
++--+-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
++--+-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
++--+-    simp [ContinuousMap.comp_apply] at this; exact this
++--+-  rw [key, fiberConstLift_comp]
++--+-
++--+-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
++--+-theorem fiberConst_eq_range_pullback_of_surjective
++--+-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
++--+-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
++--+-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
++--+-    (range_pullback_subset_fiberConst φ)
++--+-
++--+-/-! ### §3: Density transport -/
++--+-
++--+-/-
++--+-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
++--+--/
++--+-theorem closure_range_pullback_eq_fiberConst
++--+-    (φ : C(X, Y))
++--+-    (A : Subalgebra ℝ C(Y, ℝ))
++--+-    (hA : Dense (A : Set C(Y, ℝ))) :
++--+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
++--+-      = (FiberConst φ : Set C(X, ℝ)) := by
++--+-  refine' le_antisymm ( closure_minimal _ _ ) _;
++--+-  · exact range_comp_subalgebra_subset_fiberConst φ A;
++--+-  · exact fiberConst_closed φ;
++--+-  · intro g hg;
++--+-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
++--+-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
++--+-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
++--+-    rw [ Metric.mem_closure_iff ];
++--+-    intro ε εpos;
++--+-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
++--+-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
++--+-    nontriviality;
++--+-    rw [ hF, dist_eq_norm ] at *;
++--+-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
++--+-
++--+-/-
++--+-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
++--+--/
++--+-theorem closure_range_pullback_eq_top_of_injective
++--+-    (φ : C(X, Y))
++--+-    (hφ : Function.Injective φ)
++--+-    (A : Subalgebra ℝ C(Y, ℝ))
++--+-    (hA : Dense (A : Set C(Y, ℝ))) :
++--+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
++--+-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
++--+-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
++--+-
++--+-/-! ### §4: ε-approximation -/
++--+-
++--+-/-
++--+-ε-approximation within `FiberConst φ`.
++--+--/
++--+-theorem exists_pullback_approx_of_fiberConst
++--+-    (φ : C(X, Y))
++--+-    (A : Subalgebra ℝ C(Y, ℝ))
++--+-    (hA : Dense (A : Set C(Y, ℝ)))
++--+-    (g : C(X, ℝ))
++--+-    (hg : g ∈ FiberConst φ)
++--+-    {ε : ℝ} (hε : 0 < ε) :
++--+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
++--+-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
++--+-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
++--+-  rw [ Metric.mem_closure_iff ] at h_closure;
++--+-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
++--+-
++--+-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
++--+-theorem exists_pullback_approx_of_injective
++--+-    (φ : C(X, Y))
++--+-    (hφ : Function.Injective φ)
++--+-    (A : Subalgebra ℝ C(Y, ℝ))
++--+-    (hA : Dense (A : Set C(Y, ℝ)))
++--+-    (g : C(X, ℝ))
++--+-    {ε : ℝ} (hε : 0 < ε) :
++--+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
++--+-  exact exists_pullback_approx_of_fiberConst φ A hA g
++--+-    (mem_fiberConst_of_injective φ hφ g) hε+end+--- a/EML/Basic.lean
++-++++ b/EML/Basic.lean
++-+@@ -1,277 +1,125 @@
++-+-/-
++-+-Copyright (c) 2026 Harmonic. All rights reserved.
++-+-Released under Apache 2.0 license as described in the file LICENSE.
++-+--/
+ -+ import Mathlib
+ -+ 
+--+ namespace SimpleGraph
+--+ 
+--+-variable {V : Type*} {G : SimpleGraph V} {e : Sym2 V}
+--++variable {V : Type*} {G : SimpleGraph V}
+--+ 
+--+-/-! ### Trees have all bridges
+--++/-! ### Deletion equivalence
+--+ 
+--+-We prove that in a tree, every edge is a bridge. This follows from the
+--+-characterization that an edge is a bridge iff it does not lie on any cycle,
+--+-combined with the fact that trees are acyclic.
+--++`G.deleteEdges s` and `G \ fromEdgeSet s` have the same adjacency and
+--++hence the same reachability.  We prove the reachability equivalence
+--++we need. -/
+--++
+--++/-
+--++`deleteEdges {e}` and `G \ fromEdgeSet {e}` have the same reachability.
++-+-/-!
++-+-# Pullback Stability of Universal Approximation
++-++/-! # CatalogBuild.EML.Basic
++-+ 
++-+-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
++-+-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
++-+-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
++-+-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
++-+-
++-+-This establishes a transport principle: universal approximation results (like
++-+-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
++-+-with the precise target being the fiber-constant functions.
++-+-
++-+-## Main definitions
++-+-
++-+-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
++-+-  fibers of `φ`.
++-+-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
++-+-
++-+-## Main results
++-+-
++-+-### Basic properties (§1)
++-+-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
++-+-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
++-+-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
++-+-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
++-+-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
++-+-
++-+-### Factorization (§2)
++-+-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
++-+-  through `Set.range φ`, hence is a pullback (via Tietze extension).
++-+-
++-+-### Density transport (§3)
++-+-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
++-+-  subalgebra equals `FiberConst φ`.
++-+-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
++-+-
++-+-### ε-approximation (§4)
++-+-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
++-+-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
++-++Auto-generated from theorem catalog database.
++-++Domain: EML
++-++Declarations: 15
+ -+ -/
+--++theorem reachable_deleteEdges_iff_reachable_sdiff {e : Sym2 V} {u v : V} :
+--++    (G.deleteEdges {e}).Reachable u v ↔ (G \ fromEdgeSet {e}).Reachable u v := by
+--++  constructor;
+--++  · intro h;
+--++    convert h.mono ?_;
+--++    intro u v; aesop;
+--++  · intro h;
+--++    convert h
+--+ 
+--+-/-- In an acyclic graph, every edge is a bridge. Since there are no cycles,
+--+-no edge can lie on a cycle, which is precisely the bridge characterization. -/
+--+-theorem IsAcyclic.isBridge_of_mem_edgeSet (hAcyclic : G.IsAcyclic)
+--+-    (he : e ∈ G.edgeSet) : G.IsBridge e := by
+--+-  rw [isBridge_iff_mem_and_forall_cycle_notMem]
+--+-  exact ⟨he, fun u p hp => absurd hp (hAcyclic p)⟩
+--++/-- Bridge characterization using `deleteEdges` instead of `sdiff`. -/
+--++theorem isBridge_iff_deleteEdges {u v : V} :
+--++    G.IsBridge s(u, v) ↔ G.Adj u v ∧ ¬(G.deleteEdges {s(u, v)}).Reachable u v := by
+--++  rw [isBridge_iff]
+--++  exact ⟨
+--++    fun ⟨h1, h2⟩ => ⟨h1, fun hr => h2 (reachable_deleteEdges_iff_reachable_sdiff.mp hr)⟩,
+--++    fun ⟨h1, h2⟩ => ⟨h1, fun hr => h2 (reachable_deleteEdges_iff_reachable_sdiff.mpr hr)⟩⟩
+--+ 
+--+-/-- In a tree, every edge is a bridge. This is a direct consequence of
+--+-acyclicity: since no cycles exist, no edge can participate in a cycle. -/
+--+-theorem IsTree.isBridge_of_mem_edgeSet (hTree : G.IsTree)
+--+-    (he : e ∈ G.edgeSet) : G.IsBridge e :=
+--+-  hTree.IsAcyclic.isBridge_of_mem_edgeSet he
+--++/-! ### Bridge fundamentals -/
+--+ 
+--+-/-! ### Connected graphs with all bridges are trees
+--++/-- The endpoints of a bridge lie in different connected components
+--++after the bridge is deleted. -/
+--++theorem IsBridge.connectedComponent_ne_deleteEdges {u v : V}
+--++    (hb : G.IsBridge s(u, v)) :
+--++    (G.deleteEdges {s(u, v)}).connectedComponentMk u ≠
+--++    (G.deleteEdges {s(u, v)}).connectedComponentMk v := by
+--++  rw [Ne, ConnectedComponent.eq]
+--++  exact (isBridge_iff_deleteEdges.mp hb).2
+--+ 
+--+-We prove the converse: if a connected graph has the property that every
+--+-edge is a bridge, then it must be acyclic (and hence a tree).
+--++/-! ### Bridge splitting: every vertex goes to one side -/
+--++
+--++/-
+--++In a connected graph, after removing a bridge {u,v}, every vertex
+--++is reachable from either u or v (but not both, since u and v are separated).
+--++This shows the bridge partitions the vertex set into exactly two parts.
+--+ -/
+--++theorem IsBridge.forall_reachable_delete_left_or_right
+--++    (hconn : G.Connected) {u v : V} (hb : G.IsBridge s(u, v)) (w : V) :
+--++    (G.deleteEdges {s(u, v)}).Reachable u w ∨
+--++    (G.deleteEdges {s(u, v)}).Reachable v w := by
+--++  obtain ⟨ p ⟩ := hconn w u;
+--++  induction' p with w' w'' p ih;
+--++  · exact Or.inl ( SimpleGraph.Reachable.refl _ );
+--++  · cases' eq_or_ne w'' ih with h h <;> cases' eq_or_ne w'' v with h' h' <;> simp_all +decide [ SimpleGraph.isBridge_iff ];
+--++    cases' ‹ ( G.deleteEdges { s(ih, v) } ).Reachable ih p ∨ ( G.deleteEdges { s(ih, v) } ).Reachable v p › with h'' h'' <;> [ left; right ] <;> refine' h''.trans _ <;> simp_all +decide [ SimpleGraph.deleteEdges ];
+--++    · exact SimpleGraph.Adj.reachable ( by aesop ) |> SimpleGraph.Reachable.symm;
+--++    · exact SimpleGraph.Reachable.symm ( SimpleGraph.Adj.reachable ( by aesop ) )
+--+ 
+--+-/-- If every edge of a graph is a bridge, then the graph is acyclic.
+--++/-! ### Two connected components -/
+--+ 
+--+-**Proof sketch**: Suppose for contradiction there exists a cycle `c`.
+--+-Since `c` is not nil, it has at least one edge `e`. This edge lies in the
+--+-edge set of `G`, so by hypothesis it is a bridge. But bridges cannot lie
+--+-on any cycle (by `isBridge_iff_mem_and_forall_cycle_notMem`), contradicting
+--+-that `e` lies on `c`. -/
+--+-theorem isAcyclic_of_forall_isBridge
+--+-    (h : ∀ e ∈ G.edgeSet, G.IsBridge e) : G.IsAcyclic := by
+--+-  intro v c hc
+--+-  -- A cycle must have at least one edge
+--+-  have hne : c.edges ≠ [] := by
+--+-    intro he
+--+-    cases c with
+--+-    | nil => exact hc.ne_nil rfl
+--+-    | cons _ _ => simp [Walk.edges_cons] at he
+--+-  obtain ⟨e, he⟩ := List.exists_mem_of_ne_nil _ hne
+--+-  have he_mem : e ∈ G.edgeSet := Walk.edges_subset_edgeSet _ he
+--+-  have hbridge := h e he_mem
+--+-  rw [isBridge_iff_mem_and_forall_cycle_notMem] at hbridge
+--+-  exact hbridge.2 c hc he
+--++/-
+--++Removing a bridge from a connected graph produces exactly two
+--++connected components. This is a fundamental structural result about
+--++bridges, showing that a bridge literally "bridges" two otherwise
+--++disconnected parts of the graph.
+--++-/
+--++theorem IsBridge.two_connected_components [DecidableEq V] [Fintype V]
+--++    [DecidableRel G.Adj]
+--++    (hconn : G.Connected) {u v : V} (hb : G.IsBridge s(u, v)) :
+--++    Fintype.card (G.deleteEdges {s(u, v)}).ConnectedComponent = 2 := by
+--++  convert Set.ncard_eq_two.mpr _;
+--++  rotate_left;
+--++  exact ( G.deleteEdges { s(u, v) } ).ConnectedComponent;
+--++  exact Set.range ( fun w => ( G.deleteEdges { s(u, v) } ).connectedComponentMk w );
+--++  · refine' ⟨ _, _, _, _ ⟩;
+--++    exact ( G.deleteEdges { s(u, v) } ).connectedComponentMk u;
+--++    exact ( G.deleteEdges { s(u, v) } ).connectedComponentMk v;
+--++    · exact connectedComponent_ne_deleteEdges hb;
+--++    · ext w;
+--++      obtain ⟨ x, rfl ⟩ := w.exists_rep;
+--++      have := hb.forall_reachable_delete_left_or_right hconn x;
+--++      cases this <;> simp_all +decide [ SimpleGraph.connectedComponentMk ];
+--++      · exact Or.inl ( Quot.sound ‹_› |> Eq.symm );
+--++      · exact Or.inr ( Quot.sound <| by tauto );
+--++  · rw [ Set.ncard_eq_toFinset_card _ ];
+--++    refine' Finset.card_bij ( fun x _ => x ) _ _ _ <;> simp +decide;
+--++    exact fun a => a.exists_rep
+--+ 
+--+-/-- **Tree-Bridge Equivalence Theorem.**
+--+-A graph is a tree if and only if it is connected and every edge is a bridge.
+--++/-! ### Trees and bridges -/
+--+ 
+--+-This is a fundamental characterization of trees: they are precisely the
+--+-connected graphs that are "minimally connected" — removing any single
+--+-edge disconnects the graph.
+--++/-
+--++Every edge of a tree is a bridge. In a tree, every edge is critical
+--++for connectivity — removing any edge disconnects the tree.
+--++-/
+--++theorem IsTree.isBridge_of_adj (hT : G.IsTree) {u v : V} (hadj : G.Adj u v) :
+--++    G.IsBridge s(u, v) := by
+--++  -- By definition of a tree, it is acyclic.
+--++  have h_acyclic : G.IsAcyclic := by
+--++    exact hT.2;
+--++  rw [ SimpleGraph.isAcyclic_iff_forall_adj_isBridge ] at h_acyclic ; aesop
+--+ 
+--+-### Forward direction
+--+-In a tree (connected + acyclic), every edge is a bridge because there are
+--+-no cycles, so no edge can lie on a cycle.
+--+-
+--+-### Reverse direction
+--+-If every edge is a bridge, the graph must be acyclic: any cycle would contain
+--+-an edge that both lies on a cycle and is a bridge, which is a contradiction. -/
+--+-theorem isTree_iff_connected_and_forall_isBridge :
+--+-    G.IsTree ↔ G.Connected ∧ ∀ e ∈ G.edgeSet, G.IsBridge e := by
+--+-  constructor
+--+-  · intro hTree
+--+-    exact ⟨hTree.isConnected, fun e he => hTree.isBridge_of_mem_edgeSet he⟩
+--+-  · intro ⟨hConn, hBridge⟩
+--+-    exact ⟨hConn, isAcyclic_of_forall_isBridge hBridge⟩
+--++/-
+--++A connected graph is a tree if and only if every edge is a bridge.
+--++This provides a characterization of trees in terms of edge criticality.
+--++-/
+--++theorem connected_isBridge_all_iff_isTree (hconn : G.Connected) :
+--++    (∀ ⦃u v : V⦄, G.Adj u v → G.IsBridge s(u, v)) ↔ G.IsTree := by
+--++  constructor;
+--++  · intro h;
+--++    constructor;
+--++    · assumption;
+--++    · exact isAcyclic_iff_forall_adj_isBridge.mpr h;
+--++  · exact fun a ⦃u v⦄ a_1 => IsTree.isBridge_of_adj a a_1
+--+ 
+--+ end SimpleGraph++-open scoped Topology
+-++-open Topology
+-+++noncomputable section
+-++ 
+-++-variable {X Y : Type*}
+-++-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
+-++-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
+-+++/-- The inverse for hyperbolic SPB is also negation. -/
+-+++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
+-+++  simp [spbH]
+-++ 
+-++-/-! ### §1: Definitions and basic properties -/
+-+++/-- Wick duality: SPB with negated second argument equals the "difference"
+-+++in the hyperbolic SPB. This is the real-variable manifestation of the
+-+++Wick rotation t → it. -/
+-+++theorem wick_duality (x y : ℝ) :
+-+++    spb x (-y) = (x - y) / (1 + x * y) := by
+-+++  simp only [spb]
+-+++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
+-+++  rw [heq]; ring
+-++ 
+-++-/-- Continuous functions on `X` that are constant on fibers of `φ`.
+-++-This is the natural functional-analytic object associated to a feature map:
+-++-it captures exactly the observables visible through `φ`. -/
+-++-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
+-++-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
+-++-  algebraMap_mem' r := by intro x x' _; simp
+-++-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
+-++-  zero_mem' := by intro x x' _; simp
+-++-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
+-++-  one_mem' := by intro x x' _; simp
+-+++/-- The tangent addition law IS the stereographic sum.
+-+++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
+-+++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
+-+++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
+-+++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
+-+++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
+-+++  field_simp
+-++ 
+-++-/-- Pullback of continuous real-valued functions along `φ`. -/
+-++-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
+-++-  toFun f := f.comp φ
+-++-  map_zero' := by ext; simp
+-++-  map_one' := by ext; simp
+-++-  map_add' := by intros; ext; simp
+-++-  map_mul' := by intros; ext; simp
+-++-  commutes' := by intros; ext; simp
+-+++/-- SPB expression trees — analogous to EML expression trees. -/
+-+++inductive SPBExpr where
+-+++  | zero : SPBExpr
+-+++  | one : SPBExpr
+-+++  | var : ℕ → SPBExpr
+-+++  | node : SPBExpr → SPBExpr → SPBExpr
+-+++  deriving Repr, BEq
+-++ 
+-++-@[simp]
+-++-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
+-++-    pullbackAlg φ f x = f (φ x) := rfl
+-+++/-- Evaluate an SPB expression. -/
+-+++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
+-+++  match e with
+-+++  | .zero => 0
+-+++  | .one => 1
+-+++  | .var n => vars n
+-+++  | .node l r => spb (l.eval vars) (r.eval vars)
+-++ 
+-++-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
+-++-    pullbackAlg φ f ∈ FiberConst φ := by
+-++-  intro x x' h; simp [h]
+-+++/-- Depth of an SPB expression. -/
+-+++def SPBExpr.depth : SPBExpr → ℕ
+-+++  | .zero => 0
+-+++  | .one => 0
+-+++  | .var _ => 0
+-+++  | .node l r => 1 + max l.depth r.depth
+-++ 
+-++-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
+-++-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
+-++-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
+-+++/-- Leaf count. -/
+-+++def SPBExpr.leafCount : SPBExpr → ℕ
+-+++  | .zero => 1
+-+++  | .one => 1
+-+++  | .var _ => 1
+-+++  | .node l r => l.leafCount + r.leafCount
+-++ 
+-++-theorem range_comp_subalgebra_subset_fiberConst
+-++-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
+-++-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
+-++-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
+-+++/-- Internal node count. -/
+-+++def SPBExpr.nodeCount : SPBExpr → ℕ
+-+++  | .zero => 0
+-+++  | .one => 0
+-+++  | .var _ => 0
+-+++  | .node l r => 1 + l.nodeCount + r.nodeCount
+-++ 
+-++-/-- `FiberConst φ` is closed in the uniform topology. -/
+-++-theorem fiberConst_closed (φ : C(X, Y)) :
+-++-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
+-++-  refine isClosed_of_closure_subset ?_
+-++-  intro g hg x x' h
+-++-  rw [mem_closure_iff_nhds] at hg
+-++-  contrapose! hg
+-++-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
+-++-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
+-++-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
+-+++/-- Binary tree identity: leaves = internal nodes + 1. -/
+-+++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
+-+++    e.leafCount = e.nodeCount + 1 := by
+-+++  induction e with
+-+++  | zero => rfl
+-+++  | one => rfl
+-+++  | var _ => rfl
+-+++  | node l r ihl ihr =>
+-+++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
+-+++    omega
+-++ 
+-++-omit [T2Space X] [T2Space Y] in
+-++-/-- The pullback map is norm-nonincreasing. -/
+-++-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
+-++-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
+-++-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
+-++-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
+-+++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
+-+++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
+-++ 
+-++-/-- When `φ` is surjective, pullback is an isometry. -/
+-++-theorem pullback_isometry_of_surjective
+-++-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
+-++-    ‖pullbackAlg φ f‖ = ‖f‖ := by
+-++-  refine le_antisymm (norm_pullback_le φ f) ?_
+-++-  rw [ContinuousMap.norm_le _ (by positivity)]
+-++-  intro y; obtain ⟨x, rfl⟩ := hφ y
+-++-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
+-+++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
+-+++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
+-+++  unfold logisticSigmoid
+-+++  rw [Real.exp_neg]
+-+++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
+-+++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
+-+++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
+-+++  field_simp; ring
+-++ 
+-++-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
+-++-theorem mem_fiberConst_of_injective
+-++-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
+-++-    g ∈ FiberConst φ := by
+-++-  intro x x' h; exact congrArg g (hφ h)
+-+++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
+-+++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
+-+++  unfold softplus logisticSigmoid
+-+++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
+-+++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
+-+++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
+-+++  simp at this
+-+++  exact this
+-++ 
+-++-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
+-++-theorem fiberConst_eq_top_of_injective
+-++-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
+-++-    FiberConst φ = ⊤ := by
+-++-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
+-+++/-- ShefferAlg is closed under affine pre-composition. -/
+-+++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
+-+++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
+-+++  obtain ⟨e, rfl⟩ := hf
+-+++  exact ⟨.affinePrecomp a b e, rfl⟩
+-++ 
+-++-omit [CompactSpace Y] [T2Space Y] in
+-++-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
+-++-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
+-++-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
+-++-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
+-++-  intro x x' hφ; by_contra h_ne
+-++-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
+-++-    have := exists_continuous_zero_one_of_isClosed
+-++-      (show IsClosed {x} from isClosed_singleton)
+-++-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
+-++-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
+-++-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
+-++-  replace h := SetLike.ext_iff.mp h g
+-++-  simp_all +decide [FiberConst]
+-++-  exact absurd (h hφ) (by simp +decide [hg])
+-+++/-- ShefferAlg is closed under affine combination. -/
+-+++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
+-+++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
+-+++  obtain ⟨ef, rfl⟩ := hf
+-+++  obtain ⟨eg, rfl⟩ := hg
+-+++  exact ⟨.affineComb α β γ ef eg, rfl⟩
+-++ 
+-++-/-! ### §2: Image factorization -/
+-+++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
+-+++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
+-+++  unfold softplus
+-+++  rw [Real.exp_neg]
+-+++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
+-+++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
+-+++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
+-+++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
+-+++  rw [this, Real.log_exp]
+-++ 
+-++-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
+-++-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
+-++-
+-++-/-
+-++-The corestriction `X → Set.range φ` is a quotient map.
+-++--/
+-++-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
+-++-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
+-++-  apply IsClosedMap.isQuotientMap;
+-++-  · intro s hs;
+-++-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
+-++-    constructor <;> intro h;
+-++-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
+-++-    · convert h.preimage ( continuous_subtype_val ) using 1;
+-++-      ext; simp [Set.rangeFactorization];
+-++-      grind;
+-++-  · exact continuous_induced_rng.mpr φ.continuous;
+-++-  · exact Set.rangeFactorization_surjective
+-++-
+-++-/-- Lift a fiber-constant function to `Set.range φ`. -/
+-++-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
+-++-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
+-++-  toFun z := g z.property.choose
+-++-  continuous_toFun := by
+-++-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
+-++-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
+-++-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
+-++-      ext x; apply hg
+-++-      exact (Set.rangeFactorization φ x).property.choose_spec
+-++-    rw [this]; exact g.continuous
+-++-
+-++-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
+-++-    (hg : g ∈ FiberConst φ) (x : X) :
+-++-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
+-++-  simp only [fiberConstLift]
+-++-  apply hg
+-++-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
+-++-
+-++-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
+-++-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
+-++-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
+-++-  intro g hg
+-++-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
+-++-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
+-++-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
+-++-  refine ⟨F, ?_⟩
+-++-  ext x
+-++-  simp only [pullbackAlg_apply]
+-++-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
+-++-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
+-++-    simp [ContinuousMap.comp_apply] at this; exact this
+-++-  rw [key, fiberConstLift_comp]
+-++-
+-++-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
+-++-theorem fiberConst_eq_range_pullback_of_surjective
+-++-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
+-++-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
+-++-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
+-++-    (range_pullback_subset_fiberConst φ)
+-++-
+-++-/-! ### §3: Density transport -/
+-++-
+-++-/-
+-++-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
+-++--/
+-++-theorem closure_range_pullback_eq_fiberConst
+-++-    (φ : C(X, Y))
+-++-    (A : Subalgebra ℝ C(Y, ℝ))
+-++-    (hA : Dense (A : Set C(Y, ℝ))) :
+-++-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
+-++-      = (FiberConst φ : Set C(X, ℝ)) := by
+-++-  refine' le_antisymm ( closure_minimal _ _ ) _;
+-++-  · exact range_comp_subalgebra_subset_fiberConst φ A;
+-++-  · exact fiberConst_closed φ;
+-++-  · intro g hg;
+-++-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
+-++-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
+-++-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
+-++-    rw [ Metric.mem_closure_iff ];
+-++-    intro ε εpos;
+-++-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
+-++-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
+-++-    nontriviality;
+-++-    rw [ hF, dist_eq_norm ] at *;
+-++-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
+-++-
+-++-/-
+-++-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
+-++--/
+-++-theorem closure_range_pullback_eq_top_of_injective
+-++-    (φ : C(X, Y))
+-++-    (hφ : Function.Injective φ)
+-++-    (A : Subalgebra ℝ C(Y, ℝ))
+-++-    (hA : Dense (A : Set C(Y, ℝ))) :
+-++-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
+-++-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
+-++-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
+-++-
+-++-/-! ### §4: ε-approximation -/
+-++-
+-++-/-
+-++-ε-approximation within `FiberConst φ`.
+-++--/
+-++-theorem exists_pullback_approx_of_fiberConst
+-++-    (φ : C(X, Y))
+-++-    (A : Subalgebra ℝ C(Y, ℝ))
+-++-    (hA : Dense (A : Set C(Y, ℝ)))
+-++-    (g : C(X, ℝ))
+-++-    (hg : g ∈ FiberConst φ)
+-++-    {ε : ℝ} (hε : 0 < ε) :
+-++-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
+-++-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
+-++-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
+-++-  rw [ Metric.mem_closure_iff ] at h_closure;
+-++-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
+-++-
+-++-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
+-++-theorem exists_pullback_approx_of_injective
+-++-    (φ : C(X, Y))
+-++-    (hφ : Function.Injective φ)
+-++-    (A : Subalgebra ℝ C(Y, ℝ))
+-++-    (hA : Dense (A : Set C(Y, ℝ)))
+-++-    (g : C(X, ℝ))
+-++-    {ε : ℝ} (hε : 0 < ε) :
+-++-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
+-++-  exact exists_pullback_approx_of_fiberConst φ A hA g
+-++-    (mem_fiberConst_of_injective φ hφ g) hε+end+-+ 
++-+-open scoped Topology
++-+-open Topology
++-++noncomputable section
++-+ 
++-+-variable {X Y : Type*}
++-+-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
++-+-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
++-++/-- The inverse for hyperbolic SPB is also negation. -/
++-++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
++-++  simp [spbH]
++-+ 
++-+-/-! ### §1: Definitions and basic properties -/
++-++/-- Wick duality: SPB with negated second argument equals the "difference"
++-++in the hyperbolic SPB. This is the real-variable manifestation of the
++-++Wick rotation t → it. -/
++-++theorem wick_duality (x y : ℝ) :
++-++    spb x (-y) = (x - y) / (1 + x * y) := by
++-++  simp only [spb]
++-++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
++-++  rw [heq]; ring
++-+ 
++-+-/-- Continuous functions on `X` that are constant on fibers of `φ`.
++-+-This is the natural functional-analytic object associated to a feature map:
++-+-it captures exactly the observables visible through `φ`. -/
++-+-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
++-+-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
++-+-  algebraMap_mem' r := by intro x x' _; simp
++-+-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
++-+-  zero_mem' := by intro x x' _; simp
++-+-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
++-+-  one_mem' := by intro x x' _; simp
++-++/-- The tangent addition law IS the stereographic sum.
++-++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
++-++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
++-++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
++-++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
++-++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
++-++  field_simp
++-+ 
++-+-/-- Pullback of continuous real-valued functions along `φ`. -/
++-+-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
++-+-  toFun f := f.comp φ
++-+-  map_zero' := by ext; simp
++-+-  map_one' := by ext; simp
++-+-  map_add' := by intros; ext; simp
++-+-  map_mul' := by intros; ext; simp
++-+-  commutes' := by intros; ext; simp
++-++/-- SPB expression trees — analogous to EML expression trees. -/
++-++inductive SPBExpr where
++-++  | zero : SPBExpr
++-++  | one : SPBExpr
++-++  | var : ℕ → SPBExpr
++-++  | node : SPBExpr → SPBExpr → SPBExpr
++-++  deriving Repr, BEq
++-+ 
++-+-@[simp]
++-+-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
++-+-    pullbackAlg φ f x = f (φ x) := rfl
++-++/-- Evaluate an SPB expression. -/
++-++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
++-++  match e with
++-++  | .zero => 0
++-++  | .one => 1
++-++  | .var n => vars n
++-++  | .node l r => spb (l.eval vars) (r.eval vars)
++-+ 
++-+-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
++-+-    pullbackAlg φ f ∈ FiberConst φ := by
++-+-  intro x x' h; simp [h]
++-++/-- Depth of an SPB expression. -/
++-++def SPBExpr.depth : SPBExpr → ℕ
++-++  | .zero => 0
++-++  | .one => 0
++-++  | .var _ => 0
++-++  | .node l r => 1 + max l.depth r.depth
++-+ 
++-+-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
++-+-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
++-+-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
++-++/-- Leaf count. -/
++-++def SPBExpr.leafCount : SPBExpr → ℕ
++-++  | .zero => 1
++-++  | .one => 1
++-++  | .var _ => 1
++-++  | .node l r => l.leafCount + r.leafCount
++-+ 
++-+-theorem range_comp_subalgebra_subset_fiberConst
++-+-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
++-+-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
++-+-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
++-++/-- Internal node count. -/
++-++def SPBExpr.nodeCount : SPBExpr → ℕ
++-++  | .zero => 0
++-++  | .one => 0
++-++  | .var _ => 0
++-++  | .node l r => 1 + l.nodeCount + r.nodeCount
++-+ 
++-+-/-- `FiberConst φ` is closed in the uniform topology. -/
++-+-theorem fiberConst_closed (φ : C(X, Y)) :
++-+-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
++-+-  refine isClosed_of_closure_subset ?_
++-+-  intro g hg x x' h
++-+-  rw [mem_closure_iff_nhds] at hg
++-+-  contrapose! hg
++-+-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
++-+-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
++-+-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
++-++/-- Binary tree identity: leaves = internal nodes + 1. -/
++-++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
++-++    e.leafCount = e.nodeCount + 1 := by
++-++  induction e with
++-++  | zero => rfl
++-++  | one => rfl
++-++  | var _ => rfl
++-++  | node l r ihl ihr =>
++-++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
++-++    omega
++-+ 
++-+-omit [T2Space X] [T2Space Y] in
++-+-/-- The pullback map is norm-nonincreasing. -/
++-+-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
++-+-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
++-+-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
++-+-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
++-++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
++-++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
++-+ 
++-+-/-- When `φ` is surjective, pullback is an isometry. -/
++-+-theorem pullback_isometry_of_surjective
++-+-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
++-+-    ‖pullbackAlg φ f‖ = ‖f‖ := by
++-+-  refine le_antisymm (norm_pullback_le φ f) ?_
++-+-  rw [ContinuousMap.norm_le _ (by positivity)]
++-+-  intro y; obtain ⟨x, rfl⟩ := hφ y
++-+-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
++-++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
++-++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
++-++  unfold logisticSigmoid
++-++  rw [Real.exp_neg]
++-++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
++-++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
++-++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
++-++  field_simp; ring
++-+ 
++-+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
++-+-theorem mem_fiberConst_of_injective
++-+-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
++-+-    g ∈ FiberConst φ := by
++-+-  intro x x' h; exact congrArg g (hφ h)
++-++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
++-++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
++-++  unfold softplus logisticSigmoid
++-++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
++-++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
++-++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
++-++  simp at this
++-++  exact this
++-+ 
++-+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
++-+-theorem fiberConst_eq_top_of_injective
++-+-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
++-+-    FiberConst φ = ⊤ := by
++-+-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
++-++/-- ShefferAlg is closed under affine pre-composition. -/
++-++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
++-++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
++-++  obtain ⟨e, rfl⟩ := hf
++-++  exact ⟨.affinePrecomp a b e, rfl⟩
++-+ 
++-+-omit [CompactSpace Y] [T2Space Y] in
++-+-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
++-+-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
++-+-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
++-+-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
++-+-  intro x x' hφ; by_contra h_ne
++-+-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
++-+-    have := exists_continuous_zero_one_of_isClosed
++-+-      (show IsClosed {x} from isClosed_singleton)
++-+-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
++-+-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
++-+-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
++-+-  replace h := SetLike.ext_iff.mp h g
++-+-  simp_all +decide [FiberConst]
++-+-  exact absurd (h hφ) (by simp +decide [hg])
++-++/-- ShefferAlg is closed under affine combination. -/
++-++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
++-++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
++-++  obtain ⟨ef, rfl⟩ := hf
++-++  obtain ⟨eg, rfl⟩ := hg
++-++  exact ⟨.affineComb α β γ ef eg, rfl⟩
++-+ 
++-+-/-! ### §2: Image factorization -/
++-++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
++-++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
++-++  unfold softplus
++-++  rw [Real.exp_neg]
++-++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
++-++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
++-++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
++-++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
++-++  rw [this, Real.log_exp]
++-+ 
++-+-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
++-+-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
++-+-
++-+-/-
++-+-The corestriction `X → Set.range φ` is a quotient map.
++-+--/
++-+-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
++-+-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
++-+-  apply IsClosedMap.isQuotientMap;
++-+-  · intro s hs;
++-+-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
++-+-    constructor <;> intro h;
++-+-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
++-+-    · convert h.preimage ( continuous_subtype_val ) using 1;
++-+-      ext; simp [Set.rangeFactorization];
++-+-      grind;
++-+-  · exact continuous_induced_rng.mpr φ.continuous;
++-+-  · exact Set.rangeFactorization_surjective
++-+-
++-+-/-- Lift a fiber-constant function to `Set.range φ`. -/
++-+-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
++-+-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
++-+-  toFun z := g z.property.choose
++-+-  continuous_toFun := by
++-+-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
++-+-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
++-+-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
++-+-      ext x; apply hg
++-+-      exact (Set.rangeFactorization φ x).property.choose_spec
++-+-    rw [this]; exact g.continuous
++-+-
++-+-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
++-+-    (hg : g ∈ FiberConst φ) (x : X) :
++-+-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
++-+-  simp only [fiberConstLift]
++-+-  apply hg
++-+-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
++-+-
++-+-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
++-+-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
++-+-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
++-+-  intro g hg
++-+-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
++-+-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
++-+-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
++-+-  refine ⟨F, ?_⟩
++-+-  ext x
++-+-  simp only [pullbackAlg_apply]
++-+-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
++-+-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
++-+-    simp [ContinuousMap.comp_apply] at this; exact this
++-+-  rw [key, fiberConstLift_comp]
++-+-
++-+-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
++-+-theorem fiberConst_eq_range_pullback_of_surjective
++-+-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
++-+-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
++-+-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
++-+-    (range_pullback_subset_fiberConst φ)
++-+-
++-+-/-! ### §3: Density transport -/
++-+-
++-+-/-
++-+-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
++-+--/
++-+-theorem closure_range_pullback_eq_fiberConst
++-+-    (φ : C(X, Y))
++-+-    (A : Subalgebra ℝ C(Y, ℝ))
++-+-    (hA : Dense (A : Set C(Y, ℝ))) :
++-+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
++-+-      = (FiberConst φ : Set C(X, ℝ)) := by
++-+-  refine' le_antisymm ( closure_minimal _ _ ) _;
++-+-  · exact range_comp_subalgebra_subset_fiberConst φ A;
++-+-  · exact fiberConst_closed φ;
++-+-  · intro g hg;
++-+-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
++-+-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
++-+-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
++-+-    rw [ Metric.mem_closure_iff ];
++-+-    intro ε εpos;
++-+-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
++-+-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
++-+-    nontriviality;
++-+-    rw [ hF, dist_eq_norm ] at *;
++-+-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
++-+-
++-+-/-
++-+-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
++-+--/
++-+-theorem closure_range_pullback_eq_top_of_injective
++-+-    (φ : C(X, Y))
++-+-    (hφ : Function.Injective φ)
++-+-    (A : Subalgebra ℝ C(Y, ℝ))
++-+-    (hA : Dense (A : Set C(Y, ℝ))) :
++-+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
++-+-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
++-+-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
++-+-
++-+-/-! ### §4: ε-approximation -/
++-+-
++-+-/-
++-+-ε-approximation within `FiberConst φ`.
++-+--/
++-+-theorem exists_pullback_approx_of_fiberConst
++-+-    (φ : C(X, Y))
++-+-    (A : Subalgebra ℝ C(Y, ℝ))
++-+-    (hA : Dense (A : Set C(Y, ℝ)))
++-+-    (g : C(X, ℝ))
++-+-    (hg : g ∈ FiberConst φ)
++-+-    {ε : ℝ} (hε : 0 < ε) :
++-+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
++-+-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
++-+-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
++-+-  rw [ Metric.mem_closure_iff ] at h_closure;
++-+-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
++-+-
++-+-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
++-+-theorem exists_pullback_approx_of_injective
++-+-    (φ : C(X, Y))
++-+-    (hφ : Function.Injective φ)
++-+-    (A : Subalgebra ℝ C(Y, ℝ))
++-+-    (hA : Dense (A : Set C(Y, ℝ)))
++-+-    (g : C(X, ℝ))
++-+-    {ε : ℝ} (hε : 0 < ε) :
++-+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
++-+-  exact exists_pullback_approx_of_fiberConst φ A hA g
++-+-    (mem_fiberConst_of_injective φ hφ g) hε+end+--- a/EML/Basic.lean
++++++ b/EML/Basic.lean
+++@@ -1,277 +1,125 @@
+++-/-
+++-Copyright (c) 2026 Harmonic. All rights reserved.
+++-Released under Apache 2.0 license as described in the file LICENSE.
+++--/
+++ import Mathlib
+++ 
+++-/-!
+++-# Pullback Stability of Universal Approximation
++++/-! # CatalogBuild.EML.Basic
+++ 
+++-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
+++-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
+++-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
+++-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
+++-
+++-This establishes a transport principle: universal approximation results (like
+++-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
+++-with the precise target being the fiber-constant functions.
+++-
+++-## Main definitions
+++-
+++-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
+++-  fibers of `φ`.
+++-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
+++-
+++-## Main results
+++-
+++-### Basic properties (§1)
+++-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
+++-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
+++-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
+++-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
+++-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
+++-
+++-### Factorization (§2)
+++-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
+++-  through `Set.range φ`, hence is a pullback (via Tietze extension).
+++-
+++-### Density transport (§3)
+++-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
+++-  subalgebra equals `FiberConst φ`.
+++-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
+++-
+++-### ε-approximation (§4)
+++-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
+++-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
++++Auto-generated from theorem catalog database.
++++Domain: EML
++++Declarations: 15
+++ -/
+++ 
+++-open scoped Topology
+++-open Topology
++++noncomputable section
+++ 
+++-variable {X Y : Type*}
+++-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
+++-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
++++/-- The inverse for hyperbolic SPB is also negation. -/
++++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
++++  simp [spbH]
+++ 
+++-/-! ### §1: Definitions and basic properties -/
++++/-- Wick duality: SPB with negated second argument equals the "difference"
++++in the hyperbolic SPB. This is the real-variable manifestation of the
++++Wick rotation t → it. -/
++++theorem wick_duality (x y : ℝ) :
++++    spb x (-y) = (x - y) / (1 + x * y) := by
++++  simp only [spb]
++++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
++++  rw [heq]; ring
+++ 
+++-/-- Continuous functions on `X` that are constant on fibers of `φ`.
+++-This is the natural functional-analytic object associated to a feature map:
+++-it captures exactly the observables visible through `φ`. -/
+++-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
+++-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
+++-  algebraMap_mem' r := by intro x x' _; simp
+++-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
+++-  zero_mem' := by intro x x' _; simp
+++-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
+++-  one_mem' := by intro x x' _; simp
++++/-- The tangent addition law IS the stereographic sum.
++++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
++++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
++++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
++++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
++++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
++++  field_simp
+++ 
+++-/-- Pullback of continuous real-valued functions along `φ`. -/
+++-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
+++-  toFun f := f.comp φ
+++-  map_zero' := by ext; simp
+++-  map_one' := by ext; simp
+++-  map_add' := by intros; ext; simp
+++-  map_mul' := by intros; ext; simp
+++-  commutes' := by intros; ext; simp
++++/-- SPB expression trees — analogous to EML expression trees. -/
++++inductive SPBExpr where
++++  | zero : SPBExpr
++++  | one : SPBExpr
++++  | var : ℕ → SPBExpr
++++  | node : SPBExpr → SPBExpr → SPBExpr
++++  deriving Repr, BEq
+++ 
+++-@[simp]
+++-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
+++-    pullbackAlg φ f x = f (φ x) := rfl
++++/-- Evaluate an SPB expression. -/
++++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
++++  match e with
++++  | .zero => 0
++++  | .one => 1
++++  | .var n => vars n
++++  | .node l r => spb (l.eval vars) (r.eval vars)
+++ 
+++-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
+++-    pullbackAlg φ f ∈ FiberConst φ := by
+++-  intro x x' h; simp [h]
++++/-- Depth of an SPB expression. -/
++++def SPBExpr.depth : SPBExpr → ℕ
++++  | .zero => 0
++++  | .one => 0
++++  | .var _ => 0
++++  | .node l r => 1 + max l.depth r.depth
+++ 
+++-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
+++-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
+++-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
++++/-- Leaf count. -/
++++def SPBExpr.leafCount : SPBExpr → ℕ
++++  | .zero => 1
++++  | .one => 1
++++  | .var _ => 1
++++  | .node l r => l.leafCount + r.leafCount
+++ 
+++-theorem range_comp_subalgebra_subset_fiberConst
+++-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
+++-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
+++-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
++++/-- Internal node count. -/
++++def SPBExpr.nodeCount : SPBExpr → ℕ
++++  | .zero => 0
++++  | .one => 0
++++  | .var _ => 0
++++  | .node l r => 1 + l.nodeCount + r.nodeCount
+++ 
+++-/-- `FiberConst φ` is closed in the uniform topology. -/
+++-theorem fiberConst_closed (φ : C(X, Y)) :
+++-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
+++-  refine isClosed_of_closure_subset ?_
+++-  intro g hg x x' h
+++-  rw [mem_closure_iff_nhds] at hg
+++-  contrapose! hg
+++-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
+++-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
+++-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
++++/-- Binary tree identity: leaves = internal nodes + 1. -/
++++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
++++    e.leafCount = e.nodeCount + 1 := by
++++  induction e with
++++  | zero => rfl
++++  | one => rfl
++++  | var _ => rfl
++++  | node l r ihl ihr =>
++++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
++++    omega
+++ 
+++-omit [T2Space X] [T2Space Y] in
+++-/-- The pullback map is norm-nonincreasing. -/
+++-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
+++-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
+++-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
+++-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
++++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
++++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
+++ 
+++-/-- When `φ` is surjective, pullback is an isometry. -/
+++-theorem pullback_isometry_of_surjective
+++-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
+++-    ‖pullbackAlg φ f‖ = ‖f‖ := by
+++-  refine le_antisymm (norm_pullback_le φ f) ?_
+++-  rw [ContinuousMap.norm_le _ (by positivity)]
+++-  intro y; obtain ⟨x, rfl⟩ := hφ y
+++-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
++++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
++++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
++++  unfold logisticSigmoid
++++  rw [Real.exp_neg]
++++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
++++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
++++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
++++  field_simp; ring
+++ 
+++-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
+++-theorem mem_fiberConst_of_injective
+++-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
+++-    g ∈ FiberConst φ := by
+++-  intro x x' h; exact congrArg g (hφ h)
++++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
++++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
++++  unfold softplus logisticSigmoid
++++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
++++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
++++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
++++  simp at this
++++  exact this
+++ 
+++-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
+++-theorem fiberConst_eq_top_of_injective
+++-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
+++-    FiberConst φ = ⊤ := by
+++-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
++++/-- ShefferAlg is closed under affine pre-composition. -/
++++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
++++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
++++  obtain ⟨e, rfl⟩ := hf
++++  exact ⟨.affinePrecomp a b e, rfl⟩
+++ 
+++-omit [CompactSpace Y] [T2Space Y] in
+++-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
+++-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
+++-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
+++-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
+++-  intro x x' hφ; by_contra h_ne
+++-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
+++-    have := exists_continuous_zero_one_of_isClosed
+++-      (show IsClosed {x} from isClosed_singleton)
+++-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
+++-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
+++-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
+++-  replace h := SetLike.ext_iff.mp h g
+++-  simp_all +decide [FiberConst]
+++-  exact absurd (h hφ) (by simp +decide [hg])
++++/-- ShefferAlg is closed under affine combination. -/
++++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
++++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
++++  obtain ⟨ef, rfl⟩ := hf
++++  obtain ⟨eg, rfl⟩ := hg
++++  exact ⟨.affineComb α β γ ef eg, rfl⟩
+++ 
+++-/-! ### §2: Image factorization -/
++++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
++++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
++++  unfold softplus
++++  rw [Real.exp_neg]
++++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
++++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
++++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
++++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
++++  rw [this, Real.log_exp]
+++ 
+++-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
+++-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
+++-
+++-/-
+++-The corestriction `X → Set.range φ` is a quotient map.
+++--/
+++-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
+++-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
+++-  apply IsClosedMap.isQuotientMap;
+++-  · intro s hs;
+++-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
+++-    constructor <;> intro h;
+++-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
+++-    · convert h.preimage ( continuous_subtype_val ) using 1;
+++-      ext; simp [Set.rangeFactorization];
+++-      grind;
+++-  · exact continuous_induced_rng.mpr φ.continuous;
+++-  · exact Set.rangeFactorization_surjective
+++-
+++-/-- Lift a fiber-constant function to `Set.range φ`. -/
+++-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
+++-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
+++-  toFun z := g z.property.choose
+++-  continuous_toFun := by
+++-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
+++-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
+++-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
+++-      ext x; apply hg
+++-      exact (Set.rangeFactorization φ x).property.choose_spec
+++-    rw [this]; exact g.continuous
+++-
+++-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
+++-    (hg : g ∈ FiberConst φ) (x : X) :
+++-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
+++-  simp only [fiberConstLift]
+++-  apply hg
+++-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
+++-
+++-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
+++-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
+++-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
+++-  intro g hg
+++-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
+++-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
+++-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
+++-  refine ⟨F, ?_⟩
+++-  ext x
+++-  simp only [pullbackAlg_apply]
+++-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
+++-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
+++-    simp [ContinuousMap.comp_apply] at this; exact this
+++-  rw [key, fiberConstLift_comp]
+++-
+++-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
+++-theorem fiberConst_eq_range_pullback_of_surjective
+++-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
+++-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
+++-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
+++-    (range_pullback_subset_fiberConst φ)
+++-
+++-/-! ### §3: Density transport -/
+++-
+++-/-
+++-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
+++--/
+++-theorem closure_range_pullback_eq_fiberConst
+++-    (φ : C(X, Y))
+++-    (A : Subalgebra ℝ C(Y, ℝ))
+++-    (hA : Dense (A : Set C(Y, ℝ))) :
+++-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
+++-      = (FiberConst φ : Set C(X, ℝ)) := by
+++-  refine' le_antisymm ( closure_minimal _ _ ) _;
+++-  · exact range_comp_subalgebra_subset_fiberConst φ A;
+++-  · exact fiberConst_closed φ;
+++-  · intro g hg;
+++-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
+++-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
+++-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
+++-    rw [ Metric.mem_closure_iff ];
+++-    intro ε εpos;
+++-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
+++-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
+++-    nontriviality;
+++-    rw [ hF, dist_eq_norm ] at *;
+++-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
+++-
+++-/-
+++-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
+++--/
+++-theorem closure_range_pullback_eq_top_of_injective
+++-    (φ : C(X, Y))
+++-    (hφ : Function.Injective φ)
+++-    (A : Subalgebra ℝ C(Y, ℝ))
+++-    (hA : Dense (A : Set C(Y, ℝ))) :
+++-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
+++-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
+++-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
+++-
+++-/-! ### §4: ε-approximation -/
+++-
+++-/-
+++-ε-approximation within `FiberConst φ`.
+++--/
+++-theorem exists_pullback_approx_of_fiberConst
+++-    (φ : C(X, Y))
+++-    (A : Subalgebra ℝ C(Y, ℝ))
+++-    (hA : Dense (A : Set C(Y, ℝ)))
+++-    (g : C(X, ℝ))
+++-    (hg : g ∈ FiberConst φ)
+++-    {ε : ℝ} (hε : 0 < ε) :
+++-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
+++-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
+++-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
+++-  rw [ Metric.mem_closure_iff ] at h_closure;
+++-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
+++-
+++-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
+++-theorem exists_pullback_approx_of_injective
+++-    (φ : C(X, Y))
+++-    (hφ : Function.Injective φ)
+++-    (A : Subalgebra ℝ C(Y, ℝ))
+++-    (hA : Dense (A : Set C(Y, ℝ)))
+++-    (g : C(X, ℝ))
+++-    {ε : ℝ} (hε : 0 < ε) :
+++-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
+++-  exact exists_pullback_approx_of_fiberConst φ A hA g
+++-    (mem_fiberConst_of_injective φ hφ g) hε+end