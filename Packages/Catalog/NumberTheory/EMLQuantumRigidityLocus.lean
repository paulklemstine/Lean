import Mathlib
import Catalog.NumberTheory.EMLQuantumHermitianRigidity

/-!
# The rigidity locus of the quantum EML logarithmic activation

`Catalog/NumberTheory/EMLQuantumHermitianRigidity.lean` proved the presentation-free
rigidity theorem: for a Hermitian `H`, the logarithmic activation `log (I + i H)` is
unitary **iff** `H² = t*² · I`, where `t*` is the unique positive root of
`‖log (1 + t i)‖ = 1`.

This file studies the resulting *rigidity locus*

`𝓛 n = {H : Matrix n n ℂ | H Hermitian ∧ H² = t*² I}`

and proves the structural statements that were left conjectural in the previous
instalment (`FUTURE_DIRECTIONS.md`, Conjectures 3 and 6):

* `mem_rigidityLocus_iff_exists_projection` — the locus is *exactly* the image of the
  set of orthogonal projections under `P ↦ t*(2P − I)`; the parameterisation is
  two-sided, so the algebraic half of the "disjoint union of Grassmannians" picture is
  complete.
* `add_smul_one_notMem`, `exists_close_notMem`,
  `exists_hermitian_close_logActivation_not_mem_unitary` — the locus has **empty
  interior** in a fully explicit, entrywise sense: every admissible Hamiltonian has
  Hermitian matrices arbitrarily close to it whose activation is *not* unitary.  This is
  the topological (measure-zero surrogate) half of Conjecture 3, proved without any
  manifold machinery.
* `not_convex`, `zero_notMem` — the locus is not convex; the segment between the two
  scalar solutions leaves it immediately.
* `trace_eq_or_two_scalarLogRoot_le_dist` — a **spectral gap for traces**: two admissible
  Hamiltonians either have the same trace or their traces differ by at least `2 t*`.
* `row_normSq_eq` — every row of an admissible Hamiltonian has squared Euclidean norm
  exactly `t*²`.
* `not_mem_rigidityLocus_of_gaussianInt`,
  `not_logActivation_mem_unitary_of_gaussianInt` — the **Gaussian-integer obstruction**:
  no Hermitian matrix with entries in `ℤ[i]` has a unitary logarithmic activation.  This
  strictly extends `not_logActivation_mem_unitary_of_intCast` (integer entries) and uses
  only the certified enclosure `1 < t*² < 2`.
* `mem_rigidityLocus_iff_of_unique` — in dimension one the locus is the two-point set
  `{± t*}`, so it is disconnected already in the smallest nontrivial case.

All results are unconditional and use only the standard Lean axioms.
-/

open Complex Matrix Set

namespace QuantumEML

namespace Locus

variable {n : Type*} [Fintype n] [DecidableEq n]

/-- The **rigidity locus**: Hermitian matrices satisfying the quadratic relation
`H² = t*² I`, equivalently (`mem_rigidityLocus_iff_logActivation`) those whose
logarithmic activation is unitary. -/
def rigidityLocus (n : Type*) [Fintype n] [DecidableEq n] : Set (Matrix n n ℂ) :=
  {H | H.IsHermitian ∧ H * H = ((scalarLogRoot ^ 2 : ℝ) : ℂ) • (1 : Matrix n n ℂ)}

theorem isHermitian_of_mem {H : Matrix n n ℂ} (h : H ∈ rigidityLocus n) : H.IsHermitian := h.1

theorem sq_eq_of_mem {H : Matrix n n ℂ} (h : H ∈ rigidityLocus n) :
    H * H = ((scalarLogRoot ^ 2 : ℝ) : ℂ) • (1 : Matrix n n ℂ) := h.2

/-- Membership in the locus is exactly unitarity of the logarithmic activation. -/
theorem mem_rigidityLocus_iff_logActivation {H : Matrix n n ℂ} (hH : H.IsHermitian) :
    H ∈ rigidityLocus n ↔ logActivation hH ∈ unitary (Matrix n n ℂ) := by
  rw [logActivation_mem_unitary_iff_sq hH]
  exact ⟨fun h => h.2, fun h => ⟨hH, h⟩⟩

/-! ### The projection parameterisation -/

/-- **Two-sided projection parameterisation.**  A matrix lies in the rigidity locus iff
it is of the form `t* (2P − I)` for an orthogonal projection `P`.  Combined with
`Locus.mem_rigidityLocus_iff_logActivation` this says the admissible Hamiltonians are
*precisely* the affine images of the projections — the algebraic description of the
"disjoint union of Grassmannians". -/
theorem mem_rigidityLocus_iff_exists_projection {H : Matrix n n ℂ} :
    H ∈ rigidityLocus n ↔
      ∃ P : Matrix n n ℂ, P.IsHermitian ∧ IsIdempotentElem P ∧
        H = ((scalarLogRoot : ℝ) : ℂ) • ((2 : ℂ) • P - 1) := by
  have hne : ((scalarLogRoot : ℝ) : ℂ) ≠ 0 :=
    Complex.ofReal_ne_zero.2 scalarLogRoot_ne_zero
  constructor
  · rintro hH
    have hHerm := hH.1
    have hu : logActivation hHerm ∈ unitary (Matrix n n ℂ) :=
      (mem_rigidityLocus_iff_logActivation hHerm).1 hH
    refine ⟨((2 : ℂ)⁻¹) • ((1 : Matrix n n ℂ) + ((scalarLogRoot⁻¹ : ℝ) : ℂ) • H),
      isHermitian_projection hHerm, isIdempotentElem_projection hHerm hu, ?_⟩
    have h2 : ((2 : ℂ) • (((2 : ℂ)⁻¹) • ((1 : Matrix n n ℂ) + ((scalarLogRoot⁻¹ : ℝ) : ℂ) • H))
        - 1) = ((scalarLogRoot⁻¹ : ℝ) : ℂ) • H := by
      rw [smul_smul]
      norm_num
    rw [h2, smul_smul]
    push_cast
    rw [mul_inv_cancel₀ hne, one_smul]
  · rintro ⟨P, hP, hPi, rfl⟩
    constructor
    · have : ((2 : ℂ) • P - 1).IsHermitian := by
        unfold Matrix.IsHermitian
        rw [Matrix.conjTranspose_sub, Matrix.conjTranspose_smul, Matrix.conjTranspose_one, hP.eq]
        norm_num
      unfold Matrix.IsHermitian
      rw [Matrix.conjTranspose_smul, this.eq]
      simp
    · have hPP : P * P = P := hPi
      rw [smul_mul_smul_comm]
      have hexp : ((2 : ℂ) • P - 1) * ((2 : ℂ) • P - 1) = (1 : Matrix n n ℂ) := by
        have h4 : ((2 : ℂ) • P - 1) * ((2 : ℂ) • P - 1)
            = (4 : ℂ) • (P * P) - (4 : ℂ) • P + 1 := by
          simp only [Matrix.smul_mul, Matrix.mul_smul, Matrix.one_mul, Matrix.mul_one,
            sub_mul, mul_sub, smul_smul]
          module
        rw [h4, hPP]
        module
      rw [hexp]
      congr 1
      push_cast
      ring

/-! ### Elementary closure properties -/

theorem smul_one_mem : ((scalarLogRoot : ℝ) : ℂ) • (1 : Matrix n n ℂ) ∈ rigidityLocus n := by
  constructor
  · unfold Matrix.IsHermitian
    rw [Matrix.conjTranspose_smul, Matrix.conjTranspose_one]
    simp
  · rw [smul_mul_smul_comm, Matrix.one_mul]
    congr 1
    push_cast
    ring

theorem neg_mem {H : Matrix n n ℂ} (h : H ∈ rigidityLocus n) : -H ∈ rigidityLocus n := by
  refine ⟨h.1.neg, ?_⟩
  rw [Matrix.neg_mul, Matrix.mul_neg, neg_neg]
  exact h.2

/-- The locus is invariant under unitary conjugation: it is a union of unitary orbits. -/
theorem unitary_conj_mem {U H : Matrix n n ℂ} (hU : U ∈ unitary (Matrix n n ℂ))
    (hH : H ∈ rigidityLocus n) : U * H * star U ∈ rigidityLocus n := by
  have hUs : star U * U = 1 := hU.1
  have hsU : U * star U = 1 := hU.2
  constructor
  · unfold Matrix.IsHermitian
    have : (U * H * star U)ᴴ = U * Hᴴ * star U := by
      simp [Matrix.conjTranspose_mul, Matrix.mul_assoc, Matrix.star_eq_conjTranspose]
    rw [this, hH.1.eq]
  · have : U * H * star U * (U * H * star U) = U * (H * (star U * U) * H) * star U := by
      simp [Matrix.mul_assoc]
    rw [this, hUs, Matrix.mul_one, hH.2]
    rw [Matrix.mul_smul, Matrix.smul_mul, Matrix.mul_one, hsU]

/-! ### Non-convexity and empty interior -/

theorem zero_notMem [Nonempty n] : (0 : Matrix n n ℂ) ∉ rigidityLocus n := by
  intro h
  obtain ⟨i⟩ := ‹Nonempty n›
  have h2 : (0 : Matrix n n ℂ) = ((scalarLogRoot ^ 2 : ℝ) : ℂ) • (1 : Matrix n n ℂ) := by
    simpa using h.2
  have hz := congrFun (congrFun h2 i) i
  simp only [Matrix.zero_apply, Matrix.smul_apply, Matrix.one_apply_eq, smul_eq_mul,
    mul_one] at hz
  have hzero : (scalarLogRoot : ℝ) ^ 2 = 0 := by exact_mod_cast hz.symm
  exact pow_ne_zero 2 scalarLogRoot_ne_zero hzero

/-- **The rigidity locus is not convex.**  The two scalar solutions `± t* I` lie in it,
but their midpoint `0` does not: gradient interpolation between admissible Hamiltonians
leaves the admissible set immediately. -/
theorem not_convex [Nonempty n] : ¬ Convex ℝ (rigidityLocus n) := by
  intro hconv
  have h1 : ((scalarLogRoot : ℝ) : ℂ) • (1 : Matrix n n ℂ) ∈ rigidityLocus n := smul_one_mem
  have h2 : -(((scalarLogRoot : ℝ) : ℂ) • (1 : Matrix n n ℂ)) ∈ rigidityLocus n := neg_mem h1
  have hmid := hconv h1 h2 (by norm_num : (0:ℝ) ≤ 1/2) (by norm_num : (0:ℝ) ≤ 1/2)
    (by norm_num)
  have hzero : ((1:ℝ)/2) • (((scalarLogRoot : ℝ) : ℂ) • (1 : Matrix n n ℂ)) +
      ((1:ℝ)/2) • (-(((scalarLogRoot : ℝ) : ℂ) • (1 : Matrix n n ℂ))) = 0 := by
    module
  rw [hzero] at hmid
  exact zero_notMem hmid

/-- A scalar perturbation of an admissible Hamiltonian is inadmissible, unless the shift
is large enough to flip the spectrum (`ε = 2 t*`). -/
theorem add_smul_one_notMem [Nonempty n] {H : Matrix n n ℂ} (hH : H ∈ rigidityLocus n)
    {e : ℝ} (he : 0 < e) (he2 : e < 2 * scalarLogRoot) :
    H + ((e : ℝ) : ℂ) • (1 : Matrix n n ℂ) ∉ rigidityLocus n := by
  intro hK
  obtain ⟨i⟩ := ‹Nonempty n›
  have hsq := hK.2
  have hexpand : (H + ((e : ℝ) : ℂ) • (1 : Matrix n n ℂ)) *
      (H + ((e : ℝ) : ℂ) • (1 : Matrix n n ℂ))
      = H * H + ((2 * e : ℝ) : ℂ) • H + ((e ^ 2 : ℝ) : ℂ) • (1 : Matrix n n ℂ) := by
    simp only [Matrix.add_mul, Matrix.mul_add, Matrix.smul_mul, Matrix.mul_smul,
      Matrix.mul_one, Matrix.one_mul]
    push_cast
    module
  rw [hexpand, hH.2] at hsq
  -- hence `(2e) • H = -(e²) • 1`
  have hlin : ((2 * e : ℝ) : ℂ) • H = ((-(e ^ 2) : ℝ) : ℂ) • (1 : Matrix n n ℂ) := by
    push_cast at hsq ⊢
    linear_combination (norm := module) hsq
  -- squaring the linear relation eliminates `H`
  have hmul := congrArg (fun M : Matrix n n ℂ => M * M) hlin
  simp only [Matrix.smul_mul, Matrix.mul_smul, Matrix.one_mul, smul_smul] at hmul
  rw [hH.2, smul_smul] at hmul
  have hentry := congrFun (congrFun hmul i) i
  simp only [Matrix.smul_apply, Matrix.one_apply_eq, smul_eq_mul, mul_one] at hentry
  have hreal : (2 * e) * (2 * e) * scalarLogRoot ^ 2 = (e ^ 2) * (e ^ 2) := by
    have hc : (((2 * e) * (2 * e) * scalarLogRoot ^ 2 : ℝ) : ℂ) = (((e ^ 2) * (e ^ 2) : ℝ) : ℂ) := by
      push_cast at hentry ⊢
      linear_combination hentry
    exact_mod_cast hc
  have hlt : e ^ 2 < 4 * scalarLogRoot ^ 2 := by nlinarith [scalarLogRoot_pos, he, he2]
  nlinarith [hreal, hlt, mul_pos he he]

/-- **Empty interior, entrywise.**  Every admissible Hamiltonian is an entrywise limit of
Hermitian matrices that are *not* admissible: the rigidity locus contains no ball. -/
theorem exists_close_notMem [Nonempty n] {H : Matrix n n ℂ} (hH : H ∈ rigidityLocus n)
    {ε : ℝ} (hε : 0 < ε) :
    ∃ K : Matrix n n ℂ, K.IsHermitian ∧ (∀ i j, ‖K i j - H i j‖ ≤ ε) ∧ K ∉ rigidityLocus n := by
  set e : ℝ := min ε scalarLogRoot with he_def
  have hepos : 0 < e := lt_min hε scalarLogRoot_pos
  have hele : e ≤ ε := min_le_left _ _
  have helt : e < 2 * scalarLogRoot := by
    have : e ≤ scalarLogRoot := min_le_right _ _
    nlinarith [scalarLogRoot_pos]
  refine ⟨H + ((e : ℝ) : ℂ) • (1 : Matrix n n ℂ), ?_, ?_, add_smul_one_notMem hH hepos helt⟩
  · refine hH.1.add ?_
    unfold Matrix.IsHermitian
    rw [Matrix.conjTranspose_smul, Matrix.conjTranspose_one]
    simp
  · intro i j
    have : (H + ((e : ℝ) : ℂ) • (1 : Matrix n n ℂ)) i j - H i j
        = ((e : ℝ) : ℂ) * (if i = j then 1 else 0) := by
      by_cases hij : i = j <;> simp [hij]
    rw [this]
    by_cases hij : i = j
    · simp [hij, abs_of_pos hepos, hele]
    · simp [hij, le_of_lt hε]

/-- The same statement in the language of the catalog: unitarity of the logarithmic
activation is **not** a generic property — it is destroyed by arbitrarily small Hermitian
perturbations. -/
theorem exists_hermitian_close_logActivation_not_mem_unitary [Nonempty n] {H : Matrix n n ℂ}
    (hH : H.IsHermitian) (hu : logActivation hH ∈ unitary (Matrix n n ℂ)) {ε : ℝ} (hε : 0 < ε) :
    ∃ (K : Matrix n n ℂ) (hK : K.IsHermitian), (∀ i j, ‖K i j - H i j‖ ≤ ε) ∧
      logActivation hK ∉ unitary (Matrix n n ℂ) := by
  obtain ⟨K, hK, hclose, hKnot⟩ :=
    exists_close_notMem ((mem_rigidityLocus_iff_logActivation hH).2 hu) hε
  exact ⟨K, hK, hclose, fun hc => hKnot ((mem_rigidityLocus_iff_logActivation hK).2 hc)⟩

/-! ### The trace gap -/

/-- **Trace gap.**  Two admissible Hamiltonians either share the same trace, or their
traces are at distance at least `2 t*`: the trace of an admissible Hamiltonian is confined
to the lattice `t* (2k − n)`. -/
theorem trace_eq_or_two_scalarLogRoot_le_dist {A B : Matrix n n ℂ}
    (hA : A ∈ rigidityLocus n) (hB : B ∈ rigidityLocus n) :
    A.trace = B.trace ∨ 2 * scalarLogRoot ≤ ‖A.trace - B.trace‖ := by
  classical
  have hAu : logActivation hA.1 ∈ unitary (Matrix n n ℂ) :=
    (mem_rigidityLocus_iff_logActivation hA.1).1 hA
  have hBu : logActivation hB.1 ∈ unitary (Matrix n n ℂ) :=
    (mem_rigidityLocus_iff_logActivation hB.1).1 hB
  have htA := trace_eq hA.1 hAu
  have htB := trace_eq hB.1 hBu
  set k : ℕ := upperLevelCount hA.1
  set l : ℕ := upperLevelCount hB.1
  by_cases hkl : k = l
  · left; rw [htA, htB, hkl]
  · right
    have hdiff : A.trace - B.trace = ((2 * scalarLogRoot * ((k : ℝ) - (l : ℝ)) : ℝ) : ℂ) := by
      rw [htA, htB]
      push_cast
      ring
    rw [hdiff, Complex.norm_real, Real.norm_eq_abs, abs_mul, abs_mul]
    have h1 : (1 : ℝ) ≤ |(k : ℝ) - (l : ℝ)| := by
      have : ((k : ℤ) - (l : ℤ)) ≠ 0 := by
        simpa [sub_eq_zero] using fun h => hkl (by exact_mod_cast h)
      have h1' : (1 : ℤ) ≤ |(k : ℤ) - (l : ℤ)| := Int.one_le_abs this
      have : ((1 : ℤ) : ℝ) ≤ ((|(k : ℤ) - (l : ℤ)| : ℤ) : ℝ) := by exact_mod_cast h1'
      simpa [Int.cast_abs] using this
    have h2 : |(2 : ℝ)| = 2 := by norm_num
    have h3 : |scalarLogRoot| = scalarLogRoot := abs_of_pos scalarLogRoot_pos
    rw [h2, h3]
    nlinarith [scalarLogRoot_pos, h1]

/-! ### Row quantization and the Gaussian-integer obstruction -/

/-- **Row quantization.**  Every row of an admissible Hamiltonian has squared Euclidean
norm exactly `t*²`.  (Summing over rows recovers the Frobenius quantization
`tr H² = n t*²` of the previous instalment.) -/
theorem row_normSq_eq {H : Matrix n n ℂ} (hH : H ∈ rigidityLocus n) (i : n) :
    ∑ j, ‖H i j‖ ^ 2 = scalarLogRoot ^ 2 := by
  have hentry := congrFun (congrFun hH.2 i) i
  rw [Matrix.mul_apply] at hentry
  simp only [Matrix.smul_apply, Matrix.one_apply_eq, smul_eq_mul, mul_one] at hentry
  have hterm : ∀ j, H i j * H j i = ((‖H i j‖ ^ 2 : ℝ) : ℂ) := by
    intro j
    have hji : H j i = star (H i j) := (hH.1.apply j i).symm
    rw [hji, show (star (H i j)) = (starRingEnd ℂ) (H i j) from rfl, Complex.mul_conj]
    norm_cast
    exact Complex.normSq_eq_norm_sq (H i j)
  rw [Finset.sum_congr rfl (fun j _ => hterm j)] at hentry
  have : ((∑ j, ‖H i j‖ ^ 2 : ℝ) : ℂ) = ((scalarLogRoot ^ 2 : ℝ) : ℂ) := by
    push_cast at hentry ⊢
    exact hentry
  exact_mod_cast this

/-- **Gaussian-integer obstruction.**  No Hermitian matrix with entries in `ℤ[i]` lies in
the rigidity locus.  Indeed each row would give `∑_j |H_{ij}|² = t*²`, but the left side is
a nonnegative integer while `1 < t*² < 2`.  This strictly extends the integrality
obstruction of the previous instalment, which covered only real integer entries. -/
theorem not_mem_rigidityLocus_of_gaussianInt [Nonempty n] {H : Matrix n n ℂ}
    (hz : ∀ i j, ∃ a b : ℤ, H i j = (a : ℂ) + (b : ℂ) * I) : H ∉ rigidityLocus n := by
  intro hH
  obtain ⟨i⟩ := ‹Nonempty n›
  choose a b hab using hz i
  have hrow := row_normSq_eq hH i
  have hnorm : ∀ j, ‖H i j‖ ^ 2 = ((a j ^ 2 + b j ^ 2 : ℤ) : ℝ) := by
    intro j
    rw [hab j, ← Complex.normSq_eq_norm_sq]
    simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im,
      Complex.mul_re, Complex.mul_im, Complex.I_re, Complex.I_im,
      Complex.intCast_re, Complex.intCast_im]
    push_cast
    ring
  rw [Finset.sum_congr rfl (fun j _ => hnorm j)] at hrow
  have hcast : ((∑ j, (a j ^ 2 + b j ^ 2) : ℤ) : ℝ) = scalarLogRoot ^ 2 := by
    rw [← hrow]
    push_cast
    ring
  have h1 : (1 : ℝ) < ((∑ j, (a j ^ 2 + b j ^ 2) : ℤ) : ℝ) := by
    rw [hcast]; exact one_lt_scalarLogRoot_sq
  have h2 : ((∑ j, (a j ^ 2 + b j ^ 2) : ℤ) : ℝ) < 2 := by
    rw [hcast]; exact scalarLogRoot_sq_lt_two
  have h1' : (1 : ℤ) < ∑ j, (a j ^ 2 + b j ^ 2) := by exact_mod_cast h1
  have h2' : (∑ j, (a j ^ 2 + b j ^ 2) : ℤ) < 2 := by exact_mod_cast h2
  omega

/-- The Gaussian-integer obstruction in activation form. -/
theorem not_logActivation_mem_unitary_of_gaussianInt [Nonempty n] {H : Matrix n n ℂ}
    (hH : H.IsHermitian) (hz : ∀ i j, ∃ a b : ℤ, H i j = (a : ℂ) + (b : ℂ) * I) :
    logActivation hH ∉ unitary (Matrix n n ℂ) := fun hu =>
  not_mem_rigidityLocus_of_gaussianInt hz ((mem_rigidityLocus_iff_logActivation hH).2 hu)

/-! ### Dimension one -/

/-- In dimension one the rigidity locus is the two-point set `{t*, −t*}`: it is already
disconnected, which is the smallest instance of the "disjoint union of Grassmannians"
picture. -/
theorem mem_rigidityLocus_iff_of_unique [Unique n] {H : Matrix n n ℂ} :
    H ∈ rigidityLocus n ↔
      H = ((scalarLogRoot : ℝ) : ℂ) • (1 : Matrix n n ℂ) ∨
      H = -(((scalarLogRoot : ℝ) : ℂ) • (1 : Matrix n n ℂ)) := by
  constructor
  · intro hH
    have hentry := congrFun (congrFun hH.2 default) default
    rw [Matrix.mul_apply] at hentry
    simp only [Finset.univ_unique, Finset.sum_singleton, Matrix.smul_apply, Matrix.one_apply_eq,
      smul_eq_mul, mul_one] at hentry
    have hsq : (H default default) ^ 2 = (((scalarLogRoot : ℝ) : ℂ)) ^ 2 := by
      rw [pow_two, hentry]
      push_cast
      ring
    have := sq_eq_sq_iff_eq_or_eq_neg.mp hsq
    rcases this with h | h
    · left
      ext p q
      have hp : p = default := Subsingleton.elim _ _
      have hq : q = default := Subsingleton.elim _ _
      subst hp; subst hq
      simp [h]
    · right
      ext p q
      have hp : p = default := Subsingleton.elim _ _
      have hq : q = default := Subsingleton.elim _ _
      subst hp; subst hq
      simp [h]
  · rintro (rfl | rfl)
    · exact smul_one_mem
    · exact neg_mem smul_one_mem

/-! ### Sharpness of the trace gap, and the failure of a distance gap -/

/-- **The trace gap `2 t*` is attained.**  In every nonzero dimension there are two
admissible Hamiltonians whose traces are exactly `2 t*` apart, so the constant in
`trace_eq_or_two_scalarLogRoot_le_dist` is optimal. -/
theorem exists_pair_trace_dist_eq_two_scalarLogRoot [Nonempty n] :
    ∃ A ∈ rigidityLocus n, ∃ B ∈ rigidityLocus n,
      ‖A.trace - B.trace‖ = 2 * scalarLogRoot := by
  have hcard : 1 ≤ Fintype.card n := Fintype.card_pos
  obtain ⟨A, hA, hAu, hAt⟩ := exists_hermitian_logActivation_unitary_trace_of_le
    (n := n) (k := 1) hcard
  obtain ⟨B, hB, hBu, hBt⟩ := exists_hermitian_logActivation_unitary_trace_of_le
    (n := n) (k := 0) (Nat.zero_le _)
  refine ⟨A, (mem_rigidityLocus_iff_logActivation hA).2 hAu, B,
    (mem_rigidityLocus_iff_logActivation hB).2 hBu, ?_⟩
  rw [hAt, hBt, ← Complex.ofReal_sub, Complex.norm_real, Real.norm_eq_abs]
  rw [show scalarLogRoot * (2 * (1 : ℕ) - Fintype.card n)
        - scalarLogRoot * (2 * (0 : ℕ) - Fintype.card n) = 2 * scalarLogRoot by push_cast; ring]
  exact abs_of_pos (by linarith [scalarLogRoot_pos])

/-- A two-level Hamiltonian built from a point `(c, s)` of the unit circle lies in the
rigidity locus. -/
theorem smul_two_level_mem (c s : ℝ) (h : c ^ 2 + s ^ 2 = 1) :
    ((scalarLogRoot : ℝ) : ℂ) • !![(c : ℂ), (s : ℂ); (s : ℂ), -(c : ℂ)] ∈
      rigidityLocus (Fin 2) := by
  constructor
  · unfold Matrix.IsHermitian
    ext i j
    fin_cases i <;> fin_cases j <;>
      simp [Matrix.conjTranspose_apply, Complex.conj_ofReal]
  · have hM : (!![(c : ℂ), (s : ℂ); (s : ℂ), -(c : ℂ)]) * !![(c : ℂ), (s : ℂ); (s : ℂ), -(c : ℂ)]
        = ((c ^ 2 + s ^ 2 : ℝ) : ℂ) • (1 : Matrix (Fin 2) (Fin 2) ℂ) := by
      rw [Matrix.mul_fin_two]
      ext i j
      fin_cases i <;> fin_cases j <;> simp <;> ring
    rw [smul_mul_smul_comm, hM, h, smul_smul]
    congr 1
    push_cast
    ring

/-- The Bloch-circle family of admissible two-level Hamiltonians, in the rational
parameterisation `c = (1 − u²)/(1 + u²)`, `s = 2u/(1 + u²)` of the unit circle. -/
noncomputable def spinMatrix (u : ℝ) : Matrix (Fin 2) (Fin 2) ℂ :=
  ((scalarLogRoot : ℝ) : ℂ) •
    !![(((1 - u ^ 2) / (1 + u ^ 2) : ℝ) : ℂ), ((2 * u / (1 + u ^ 2) : ℝ) : ℂ);
       ((2 * u / (1 + u ^ 2) : ℝ) : ℂ), -(((1 - u ^ 2) / (1 + u ^ 2) : ℝ) : ℂ)]

theorem spinMatrix_mem (u : ℝ) : spinMatrix u ∈ rigidityLocus (Fin 2) := by
  have hu : (0 : ℝ) < 1 + u ^ 2 := by positivity
  refine smul_two_level_mem _ _ ?_
  field_simp
  ring

/-- **No distance gap.**  Although admissible traces are `2 t*`-separated, the locus itself
has no separation: in dimension two there are distinct admissible Hamiltonians at
arbitrarily small entrywise distance.  The quantization is therefore a phenomenon of the
*spectrum*, not of the matrices — the components of the locus are continua (Bloch
spheres), a boundary case that the trace gap alone might have hidden. -/
theorem exists_distinct_close_mem {ε : ℝ} (hε : 0 < ε) :
    ∃ A B : Matrix (Fin 2) (Fin 2) ℂ, A ∈ rigidityLocus (Fin 2) ∧ B ∈ rigidityLocus (Fin 2) ∧
      A ≠ B ∧ ∀ i j, ‖A i j - B i j‖ ≤ ε := by
  have ht : 0 < scalarLogRoot := scalarLogRoot_pos
  set u : ℝ := min 1 (ε / (2 * scalarLogRoot + 2)) with hu_def
  have hupos : 0 < u :=
    lt_min one_pos (div_pos hε (by linarith [ht]))
  have hule : u ≤ 1 := min_le_left _ _
  have hden : (0 : ℝ) < 1 + u ^ 2 := by positivity
  have hbound : 2 * scalarLogRoot * u ≤ ε := by
    have h1 : u ≤ ε / (2 * scalarLogRoot + 2) := min_le_right _ _
    have h2 : 2 * scalarLogRoot * u ≤ 2 * scalarLogRoot * (ε / (2 * scalarLogRoot + 2)) := by
      nlinarith [ht]
    have h3 : 2 * scalarLogRoot * (ε / (2 * scalarLogRoot + 2)) ≤ ε := by
      rw [show 2 * scalarLogRoot * (ε / (2 * scalarLogRoot + 2))
            = (2 * scalarLogRoot * ε) / (2 * scalarLogRoot + 2) by ring,
        div_le_iff₀ (by linarith [ht] : (0:ℝ) < 2 * scalarLogRoot + 2)]
      nlinarith [ht, hε]
    linarith
  refine ⟨spinMatrix u, spinMatrix 0, spinMatrix_mem u, spinMatrix_mem 0, ?_, ?_⟩
  · intro hEq
    have h01 := congrFun (congrFun hEq 0) 1
    simp only [spinMatrix, Matrix.smul_apply, smul_eq_mul] at h01
    have hne : ((scalarLogRoot : ℝ) : ℂ) ≠ 0 := Complex.ofReal_ne_zero.2 (ne_of_gt ht)
    have hs : ((2 * u / (1 + u ^ 2) : ℝ) : ℂ) = ((2 * 0 / (1 + (0:ℝ) ^ 2) : ℝ) : ℂ) :=
      mul_left_cancel₀ hne h01
    have hs' : 2 * u / (1 + u ^ 2) = 0 := by
      have := Complex.ofReal_injective hs
      simpa using this
    have : u = 0 := by
      field_simp at hs'
      linarith
    exact absurd this (ne_of_gt hupos)
  · intro i j
    have hc : |(1 - u ^ 2) / (1 + u ^ 2) - 1| ≤ 2 * u := by
      have hval : (1 - u ^ 2) / (1 + u ^ 2) - 1 = -(2 * u ^ 2) / (1 + u ^ 2) := by
        field_simp
        ring
      rw [hval, abs_div, abs_of_pos hden, div_le_iff₀ hden]
      have : |(-(2 * u ^ 2) : ℝ)| = 2 * u ^ 2 := by
        rw [abs_neg, abs_of_nonneg (by positivity)]
      rw [this]
      nlinarith [hupos, hule]
    have hsval : |2 * u / (1 + u ^ 2)| ≤ 2 * u := by
      rw [abs_div, abs_of_pos hden, div_le_iff₀ hden]
      have : |(2 * u : ℝ)| = 2 * u := abs_of_pos (by positivity)
      rw [this]
      nlinarith [hupos]
    have key : ∀ x : ℝ, |x| ≤ 2 * u → ‖((scalarLogRoot : ℝ) : ℂ) * ((x : ℝ) : ℂ)‖ ≤ ε := by
      intro x hx
      rw [norm_mul, Complex.norm_real, Complex.norm_real, Real.norm_eq_abs, Real.norm_eq_abs,
        abs_of_pos ht]
      calc scalarLogRoot * |x| ≤ scalarLogRoot * (2 * u) := by nlinarith [ht, abs_nonneg x]
        _ ≤ ε := by linarith [hbound]
    fin_cases i <;> fin_cases j <;>
      simp only [spinMatrix, Matrix.smul_apply, smul_eq_mul, ← mul_sub]
    · have := key ((1 - u ^ 2) / (1 + u ^ 2) - (1 - (0:ℝ) ^ 2) / (1 + (0:ℝ) ^ 2)) (by
        simpa using hc)
      simpa using this
    · have := key (2 * u / (1 + u ^ 2) - 2 * (0:ℝ) / (1 + (0:ℝ) ^ 2)) (by simpa using hsval)
      simpa using this
    · have := key (2 * u / (1 + u ^ 2) - 2 * (0:ℝ) / (1 + (0:ℝ) ^ 2)) (by simpa using hsval)
      simpa using this
    · have := key (-((1 - u ^ 2) / (1 + u ^ 2)) + (1 - (0:ℝ) ^ 2) / (1 + (0:ℝ) ^ 2)) (by
        rw [abs_sub_comm] at hc
        simpa [sub_eq_neg_add] using hc)
      simpa using this


/-! ### Topology of the rigidity locus -/

/-- The rigidity locus is closed: it is cut out by the two continuous conditions
`Hᴴ = H` and `H² = t*² I`. -/
theorem isClosed_rigidityLocus : IsClosed (rigidityLocus n) := by
  have h1 : IsClosed {H : Matrix n n ℂ | Hᴴ = H} :=
    isClosed_eq continuous_id.matrix_conjTranspose continuous_id
  have h2 : IsClosed {H : Matrix n n ℂ |
      H * H = ((scalarLogRoot ^ 2 : ℝ) : ℂ) • (1 : Matrix n n ℂ)} :=
    isClosed_eq (continuous_id.matrix_mul continuous_id) continuous_const
  exact h1.inter h2

/-- **Empty interior, topologically.**  The rigidity locus contains no open set: this is
the perturbation statement `add_smul_one_notMem` upgraded from the entrywise formulation
to the topology of `Matrix n n ℂ`. -/
theorem interior_rigidityLocus_eq_empty [Nonempty n] : interior (rigidityLocus n) = ∅ := by
  rw [Set.eq_empty_iff_forall_notMem]
  intro H hH
  have hmem : H ∈ rigidityLocus n := interior_subset hH
  have hcont : Continuous (fun e : ℝ => H + ((e : ℝ) : ℂ) • (1 : Matrix n n ℂ)) :=
    continuous_const.add (Complex.continuous_ofReal.smul continuous_const)
  have hopen : IsOpen ((fun e : ℝ => H + ((e : ℝ) : ℂ) • (1 : Matrix n n ℂ)) ⁻¹'
      interior (rigidityLocus n)) := isOpen_interior.preimage hcont
  have h0 : (0 : ℝ) ∈ (fun e : ℝ => H + ((e : ℝ) : ℂ) • (1 : Matrix n n ℂ)) ⁻¹'
      interior (rigidityLocus n) := by simpa using hH
  obtain ⟨δ, hδ, hsub⟩ := Metric.isOpen_iff.1 hopen 0 h0
  set e : ℝ := min (δ / 2) scalarLogRoot with he_def
  have hepos : 0 < e := lt_min (by linarith) scalarLogRoot_pos
  have heδ : e < δ := lt_of_le_of_lt (min_le_left _ _) (by linarith)
  have helt : e < 2 * scalarLogRoot := by
    have : e ≤ scalarLogRoot := min_le_right _ _
    linarith [scalarLogRoot_pos]
  have hball : e ∈ Metric.ball (0 : ℝ) δ := by
    simp only [Metric.mem_ball, Real.dist_eq, sub_zero, abs_of_pos hepos]
    exact heδ
  exact add_smul_one_notMem hmem hepos helt (interior_subset (hsub hball))

/-- The complement of the rigidity locus is dense: a generic Hermitian perturbation
destroys unitarity of the logarithmic activation. -/
theorem dense_compl_rigidityLocus [Nonempty n] : Dense (rigidityLocus n)ᶜ :=
  interior_eq_empty_iff_dense_compl.1 interior_rigidityLocus_eq_empty

/-- **The rigidity locus is nowhere dense.**  Closed with empty interior: this is the
topological form of the "measure-zero constraint" heuristic, proved without any manifold
or measure theory. -/
theorem isNowhereDense_rigidityLocus [Nonempty n] : IsNowhereDense (rigidityLocus n) := by
  unfold IsNowhereDense
  rw [isClosed_rigidityLocus.closure_eq]
  exact interior_rigidityLocus_eq_empty

/-- Every entry of an admissible Hamiltonian is bounded by `t*` in modulus, a consequence
of row quantization. -/
theorem norm_entry_le {H : Matrix n n ℂ} (hH : H ∈ rigidityLocus n) (i j : n) :
    ‖H i j‖ ≤ scalarLogRoot := by
  have hsum := row_normSq_eq hH i
  have hle : ‖H i j‖ ^ 2 ≤ ∑ k, ‖H i k‖ ^ 2 :=
    Finset.single_le_sum (f := fun k => ‖H i k‖ ^ 2) (fun k _ => sq_nonneg _)
      (Finset.mem_univ j)
  rw [hsum] at hle
  nlinarith [norm_nonneg (H i j), scalarLogRoot_pos]

/-- The rigidity locus is compact: closed, and bounded by `norm_entry_le`. -/
theorem isCompact_rigidityLocus : IsCompact (rigidityLocus n) := by
  have hcomp : IsCompact {H : Matrix n n ℂ |
      ∀ i, H i ∈ {v : n → ℂ | ∀ j, v j ∈ Metric.closedBall (0 : ℂ) scalarLogRoot}} :=
    isCompact_pi_infinite fun _ =>
      isCompact_pi_infinite fun _ => isCompact_closedBall _ _
  refine hcomp.of_isClosed_subset isClosed_rigidityLocus ?_
  intro H hH i j
  simpa [Metric.mem_closedBall, dist_eq_norm] using norm_entry_le hH i j


end Locus

end QuantumEML