/-
Copyright (c) 2026 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Standard-part projection-valued measures

A **hyperreal projection-valued measure (PVM)** on `Matrix n n ℝ*` indexed by a finite type `ι`
is a family `P : ι → Matrix n n ℝ*` of matrices over the hyperreals which is a resolution of the
identity *only up to infinitesimal error*: the products `P a * P b` (`a ≠ b`) are entrywise
infinitesimal, and `∑ a, P a` is entrywise infinitesimally close to `1`.  Such families model
measurements performed by a non-Archimedean observer: the algebraic identities of a PVM are only
required to hold within the observer's (infinitesimal) resolution.

The **observation map** is the entrywise standard part `stMat = Matrix.map Hyperreal.st`.

## Main results

* `StandardPartPVM.stMat_mul`, `stMat_add`, `stMat_sum` — `stMat` is a ring-like homomorphism on
  the (non-subring!) collection of matrices with finite entries.
* `StandardPartPVM.approxEq_iff_stMat_eq` — `A ≈ B` (entrywise infinitesimal difference) iff
  `stMat A = stMat B`, for finite-entry matrices.
* `StandardPartPVM.isPVM_stMat_iff` — **the descent theorem**: for a family of finite-entry
  hyperreal matrices, the entrywise standard parts form an honest projection-valued measure
  *if and only if* the family is pairwise orthogonal up to infinitesimals and its total is
  infinitesimally close to `1`.  No idempotency hypothesis is needed.
* `StandardPartPVM.approxIdem_of_approxOrth_of_approxTotal` — **idempotency is redundant**:
  approximate orthogonality plus approximate completeness *forces* each `P a` to be an approximate
  idempotent.  This is the structural reason the conjecture's hypothesis list is exactly right.
* `StandardPartPVM.sum_rank_eq_card` and `StandardPartPVM.exists_nat_st_trace` —
  **dimension quantization**: the observed traces of the members of a hyperreal PVM are natural
  numbers (the ranks of the descended projections) and they sum to `Fintype.card n`.  A
  non-Archimedean measurement therefore always collapses onto an integral direct-sum decomposition.
* `StandardPartPVM.infinitesimalEntries_iff_mulVec` — the entrywise notion coincides with the
  operator-theoretic one: `A` is entrywise infinitesimal iff `A` maps every finite hyperreal
  vector to an infinitesimal vector.
* `StandardPartPVM.bornMeasure_sum_eq_one`, `bornMeasure_nonneg` — the descended PVM applied to a
  real unit vector yields an honest probability measure on the index set.
* `StandardPartPVM.exists_exact_pvm_infinite_entries_not_descending` and
  `StandardPartPVM.exists_stMat_isPVM_not_approxOrth` — **sharpness**: both implications of the
  descent theorem genuinely fail when the finiteness hypothesis on entries is dropped, witnessed
  by explicit `2 × 2` and `1 × 1` hyperreal matrices built from `ω`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): polynomial identities `P² = P`, `P a P b = 0`, `∑ P a = 1` are
preserved by the entrywise standard part precisely when no entry is infinite; conversely the
standard part of a hyperreal family is a PVM only if those identities hold infinitesimally.

Experiment (Experimenter): the `1 × 1` family `(1, ω)` has a PVM standard part `(1, 0)` although
`P 0 * P 1 = ω` is infinite — killing the naive "only if" direction without finiteness.  The
exact hyperreal projection `P = !![2, ω; -2ω⁻¹, -1]` (idempotent since `2·(1-2) = ω · (-2ω⁻¹)`)
together with `1 - P` is an *exactly* orthogonal, *exactly* complete family whose entrywise
standard part `!![2,0;0,-1]` is not idempotent — killing the "if" direction without finiteness.
Both experiments are formalized (`exists_stMat_isPVM_not_approxOrth`,
`exists_exact_pvm_infinite_entries_not_descending`).

Analysis (Analyst): approximate idempotency is *not* an independent hypothesis.  Multiplying the
completeness relation by `P a` and using pairwise orthogonality gives `P a ² ≈ P a`; at the real
level this is the two-line argument `Q a = Q a * ∑ Q b = Q a * Q a`.  Hence the conjecture's
hypothesis list is minimal, and the descent theorem is an honest iff with no side conditions
beyond finiteness of the entries.

Critique (Critic): all statements avoid vacuity — the descent theorem's two sides are each
falsifiable (the sharpness examples exhibit families satisfying one side and not the other once
finiteness is dropped), the quantization theorem produces the nontrivial equation
`∑ rank = card n`, and no proof uses `decide`/`native_decide`.

Synthesis (PI): the "observable" content of a non-Archimedean spectral measurement is exactly an
integral orthogonal decomposition of the real space; infinitesimal violations of the projection
identities are invisible, infinite entries are not.
-- !-- Lab Notes -- !--
-/

open Hyperreal Matrix Finset

namespace StandardPartPVM

/-! ## Scalar layer: standard parts of finite hyperreals -/

/-- A hyperreal is infinitesimal iff it is finite with vanishing standard part. -/
theorem infinitesimal_iff_st_eq_zero {x : ℝ*} :
    Infinitesimal x ↔ ¬Infinite x ∧ st x = 0 := by
  constructor
  · intro h
    exact ⟨h.not_infinite, h.st_eq⟩
  · rintro ⟨h1, h2⟩
    have := isSt_st' h1
    rwa [h2] at this

/-- The standard part of a difference of finite hyperreals. -/
theorem st_sub' {x y : ℝ*} (hx : ¬Infinite x) (hy : ¬Infinite y) :
    st (x - y) = st x - st y := by
  rw [sub_eq_add_neg, st_add hx (not_infinite_neg hy), st_neg, ← sub_eq_add_neg]

/-- Two finite hyperreals differ by an infinitesimal iff they have the same standard part. -/
theorem infinitesimal_sub_iff {x y : ℝ*} (hx : ¬Infinite x) (hy : ¬Infinite y) :
    Infinitesimal (x - y) ↔ st x = st y := by
  rw [infinitesimal_iff_st_eq_zero, st_sub' hx hy, sub_eq_zero]
  simp only [and_iff_right_iff_imp]
  intro _
  exact not_infinite_add hx (not_infinite_neg hy) ∘ (by rw [sub_eq_add_neg] at *; exact id)

/-- A finite sum of finite hyperreals is finite. -/
theorem not_infinite_sum {α : Type*} {s : Finset α} {f : α → ℝ*}
    (h : ∀ i ∈ s, ¬Infinite (f i)) : ¬Infinite (∑ i ∈ s, f i) := by
  classical
  induction s using Finset.cons_induction with
  | empty => simpa using not_infinite_real 0
  | cons a s ha ih =>
      rw [Finset.sum_cons]
      exact not_infinite_add (h a (Finset.mem_cons_self a s))
        (ih fun i hi => h i (Finset.mem_cons_of_mem hi))

/-- The standard part is additive over finite sums of finite hyperreals. -/
theorem st_sum {α : Type*} {s : Finset α} {f : α → ℝ*} (h : ∀ i ∈ s, ¬Infinite (f i)) :
    st (∑ i ∈ s, f i) = ∑ i ∈ s, st (f i) := by
  classical
  induction s using Finset.cons_induction with
  | empty => simpa using st_id_real 0
  | cons a s ha ih =>
      rw [Finset.sum_cons, Finset.sum_cons,
        st_add (h a (Finset.mem_cons_self a s))
          (not_infinite_sum fun i hi => h i (Finset.mem_cons_of_mem hi)),
        ih fun i hi => h i (Finset.mem_cons_of_mem hi)]

/-- An infinitesimal times a finite hyperreal is infinitesimal. -/
theorem Infinitesimal.mul_finite {x y : ℝ*} (hx : Infinitesimal x) (hy : ¬Infinite y) :
    Infinitesimal (x * y) := by
  have h : IsSt (x * y) (0 * st y) := IsSt.mul hx (isSt_st' hy)
  rwa [zero_mul] at h

/-! ## Matrix layer: entrywise standard part -/

variable {n ι : Type*}

/-- The observation map: entrywise standard part of a hyperreal matrix. -/
noncomputable def stMat (A : Matrix n n ℝ*) : Matrix n n ℝ := A.map st

@[simp] theorem stMat_apply (A : Matrix n n ℝ*) (i j : n) : stMat A i j = st (A i j) := rfl

/-- A hyperreal matrix has *finite entries* if no entry is infinite. -/
def FiniteEntries (A : Matrix n n ℝ*) : Prop := ∀ i j, ¬Infinite (A i j)

/-- A hyperreal matrix is *infinitesimal* if every entry is infinitesimal. -/
def InfinitesimalEntries (A : Matrix n n ℝ*) : Prop := ∀ i j, Infinitesimal (A i j)

/-- `A ≈ B`: the two hyperreal matrices differ by an infinitesimal matrix. -/
def ApproxEq (A B : Matrix n n ℝ*) : Prop := InfinitesimalEntries (A - B)

@[inherit_doc] infix:50 " ≈ₕ " => ApproxEq

theorem InfinitesimalEntries.finiteEntries {A : Matrix n n ℝ*} (h : InfinitesimalEntries A) :
    FiniteEntries A := fun i j => (h i j).not_infinite

theorem FiniteEntries.add {A B : Matrix n n ℝ*} (hA : FiniteEntries A) (hB : FiniteEntries B) :
    FiniteEntries (A + B) := fun i j => not_infinite_add (hA i j) (hB i j)

theorem FiniteEntries.neg {A : Matrix n n ℝ*} (hA : FiniteEntries A) : FiniteEntries (-A) :=
  fun i j => not_infinite_neg (hA i j)

theorem FiniteEntries.sub {A B : Matrix n n ℝ*} (hA : FiniteEntries A) (hB : FiniteEntries B) :
    FiniteEntries (A - B) := by
  intro i j
  have := not_infinite_add (hA i j) (not_infinite_neg (hB i j))
  simpa [sub_eq_add_neg] using this

theorem FiniteEntries.mul [Fintype n] {A B : Matrix n n ℝ*} (hA : FiniteEntries A) (hB : FiniteEntries B) :
    FiniteEntries (A * B) := by
  intro i j
  rw [Matrix.mul_apply]
  exact not_infinite_sum fun k _ => not_infinite_mul (hA i k) (hB k j)

theorem FiniteEntries.sum [Fintype ι] {P : ι → Matrix n n ℝ*} (h : ∀ a, FiniteEntries (P a)) :
    FiniteEntries (∑ a, P a) := by
  intro i j
  rw [Matrix.sum_apply]
  exact not_infinite_sum fun a _ => h a i j

theorem finiteEntries_one [DecidableEq n] : FiniteEntries (1 : Matrix n n ℝ*) := by
  intro i j
  by_cases h : i = j
  · subst h
    rw [Matrix.one_apply_eq]
    simpa using not_infinite_real 1
  · rw [Matrix.one_apply_ne h]
    simpa using not_infinite_real 0

@[simp] theorem stMat_zero : stMat (0 : Matrix n n ℝ*) = 0 := by
  ext i j
  simpa using st_id_real 0

@[simp] theorem stMat_one [DecidableEq n] : stMat (1 : Matrix n n ℝ*) = 1 := by
  ext i j
  by_cases h : i = j
  · subst h; simpa [Matrix.one_apply_eq] using st_id_real 1
  · simp only [stMat_apply, Matrix.one_apply_ne h]
    simpa using st_id_real 0

theorem stMat_add {A B : Matrix n n ℝ*} (hA : FiniteEntries A) (hB : FiniteEntries B) :
    stMat (A + B) = stMat A + stMat B := by
  ext i j
  exact st_add (hA i j) (hB i j)

theorem stMat_sub {A B : Matrix n n ℝ*} (hA : FiniteEntries A) (hB : FiniteEntries B) :
    stMat (A - B) = stMat A - stMat B := by
  ext i j
  exact st_sub' (hA i j) (hB i j)

/-- **Multiplicativity of observation.** The entrywise standard part is multiplicative on
matrices with finite entries: the polynomial identities of matrix algebra survive observation. -/
theorem stMat_mul [Fintype n] {A B : Matrix n n ℝ*} (hA : FiniteEntries A) (hB : FiniteEntries B) :
    stMat (A * B) = stMat A * stMat B := by
  ext i j
  simp only [stMat_apply, Matrix.mul_apply]
  rw [st_sum fun k _ => not_infinite_mul (hA i k) (hB k j)]
  exact Finset.sum_congr rfl fun k _ => st_mul (hA i k) (hB k j)

theorem stMat_sum [Fintype ι] {P : ι → Matrix n n ℝ*} (h : ∀ a, FiniteEntries (P a)) :
    stMat (∑ a, P a) = ∑ a, stMat (P a) := by
  ext i j
  simp only [stMat_apply, Matrix.sum_apply]
  exact st_sum fun a _ => h a i j

@[simp] theorem stMat_transpose (A : Matrix n n ℝ*) : stMat Aᵀ = (stMat A)ᵀ := rfl

/-- Infinitesimality of a finite-entry matrix is detected by its standard part. -/
theorem infinitesimalEntries_iff_stMat_eq_zero {A : Matrix n n ℝ*} (hA : FiniteEntries A) :
    InfinitesimalEntries A ↔ stMat A = 0 := by
  constructor
  · intro h; ext i j; exact (h i j).st_eq
  · intro h i j
    refine infinitesimal_iff_st_eq_zero.2 ⟨hA i j, ?_⟩
    have := congrFun (congrFun h i) j
    simpa using this

/-- **Observation identifies infinitesimally close matrices.** -/
theorem approxEq_iff_stMat_eq {A B : Matrix n n ℝ*} (hA : FiniteEntries A)
    (hB : FiniteEntries B) : A ≈ₕ B ↔ stMat A = stMat B := by
  constructor
  · intro h
    ext i j
    exact (infinitesimal_sub_iff (hA i j) (hB i j)).1 (h i j)
  · intro h i j
    refine (infinitesimal_sub_iff (hA i j) (hB i j)).2 ?_
    exact congrFun (congrFun h i) j

/-! ### Self-adjointness descends -/

/-- Approximate symmetry of a finite-entry hyperreal matrix descends to exact symmetry of its
standard part; combined with the descent theorem, an approximately symmetric approximate PVM
descends to a family of *orthogonal* projections. -/
theorem stMat_transpose_eq_of_approx_symm {A : Matrix n n ℝ*} (hA : FiniteEntries A)
    (hsymm : Aᵀ ≈ₕ A) : (stMat A)ᵀ = stMat A := by
  rw [← stMat_transpose]
  exact (approxEq_iff_stMat_eq (fun i j => hA j i) hA).1 hsymm

/-! ## Projection-valued measures -/

section PVM

variable [Fintype n] [DecidableEq n] [Fintype ι]

/-- An ordinary (real, finite, sharp) projection-valued measure on `ℝⁿ`: a family of idempotents
that are pairwise orthogonal and resolve the identity. -/
structure IsPVM (Q : ι → Matrix n n ℝ) : Prop where
  idem : ∀ a, Q a * Q a = Q a
  orth : ∀ a b, a ≠ b → Q a * Q b = 0
  total : ∑ a, Q a = 1

/-- A hyperreal family is an **approximate PVM** if its entries are finite, distinct members are
orthogonal up to infinitesimals, and the total is infinitesimally close to the identity. -/
structure IsApproxPVM (P : ι → Matrix n n ℝ*) : Prop where
  finite : ∀ a, FiniteEntries (P a)
  orth : ∀ a b, a ≠ b → InfinitesimalEntries (P a * P b)
  total : (∑ a, P a) ≈ₕ 1

/-- **Idempotency is redundant at the real level**: pairwise orthogonality together with
completeness forces each member of the family to be idempotent. -/
theorem isIdempotent_of_orth_of_total {Q : ι → Matrix n n ℝ}
    (horth : ∀ a b, a ≠ b → Q a * Q b = 0) (htot : ∑ a, Q a = 1) (a : ι) :
    Q a * Q a = Q a := by
  have h : Q a * ∑ b, Q b = Q a := by rw [htot, mul_one]
  rw [Finset.mul_sum, Finset.sum_eq_single a] at h
  · exact h
  · intro b _ hb; exact horth a b (Ne.symm hb)
  · intro hmem; exact absurd (Finset.mem_univ a) hmem

/-! ### The descent theorem -/

/-- **Descent theorem.** For a family of hyperreal matrices with finite entries, the entrywise
standard parts form a genuine projection-valued measure if and only if the family is pairwise
orthogonal up to infinitesimals and its total is infinitesimally close to the identity.

Note that no (approximate) idempotency hypothesis appears: it is a consequence, see
`approxIdem_of_approxOrth_of_approxTotal`. -/
theorem isPVM_stMat_iff (P : ι → Matrix n n ℝ*) (hfin : ∀ a, FiniteEntries (P a)) :
    IsPVM (fun a => stMat (P a)) ↔
      ((∀ a b, a ≠ b → InfinitesimalEntries (P a * P b)) ∧ (∑ a, P a) ≈ₕ 1) := by
  constructor
  · rintro ⟨-, horth, htot⟩
    refine ⟨fun a b hab => ?_, ?_⟩
    · rw [infinitesimalEntries_iff_stMat_eq_zero ((hfin a).mul (hfin b)),
        stMat_mul (hfin a) (hfin b)]
      exact horth a b hab
    · rw [approxEq_iff_stMat_eq (FiniteEntries.sum hfin) finiteEntries_one, stMat_one,
        stMat_sum hfin]
      exact htot
  · rintro ⟨horth, htot⟩
    have hst_orth : ∀ a b, a ≠ b → stMat (P a) * stMat (P b) = 0 := by
      intro a b hab
      rw [← stMat_mul (hfin a) (hfin b)]
      exact (infinitesimalEntries_iff_stMat_eq_zero ((hfin a).mul (hfin b))).1 (horth a b hab)
    have hst_tot : ∑ a, stMat (P a) = 1 := by
      rw [← stMat_sum hfin, ← stMat_one (n := n)]
      exact (approxEq_iff_stMat_eq (FiniteEntries.sum hfin) finiteEntries_one).1 htot
    exact ⟨isIdempotent_of_orth_of_total hst_orth hst_tot, hst_orth, hst_tot⟩

/-- The descent theorem, packaged: an approximate hyperreal PVM descends to a real PVM. -/
theorem IsApproxPVM.isPVM_stMat {P : ι → Matrix n n ℝ*} (h : IsApproxPVM P) :
    IsPVM (fun a => stMat (P a)) :=
  (isPVM_stMat_iff P h.finite).2 ⟨h.orth, h.total⟩

/-- **Approximate idempotency is redundant.** For finite-entry families, approximate pairwise
orthogonality and approximate completeness already force `P a * P a ≈ P a`. -/
theorem approxIdem_of_approxOrth_of_approxTotal {P : ι → Matrix n n ℝ*}
    (hfin : ∀ a, FiniteEntries (P a)) (horth : ∀ a b, a ≠ b → InfinitesimalEntries (P a * P b))
    (htot : (∑ a, P a) ≈ₕ 1) (a : ι) : (P a * P a) ≈ₕ P a := by
  have h := (isPVM_stMat_iff P hfin).2 ⟨horth, htot⟩
  rw [approxEq_iff_stMat_eq ((hfin a).mul (hfin a)) (hfin a), stMat_mul (hfin a) (hfin a)]
  exact h.idem a

/-- Conversely, an approximate PVM in the strong sense (with approximate idempotency assumed)
is an approximate PVM in the above sense; the two notions therefore agree. -/
theorem isApproxPVM_iff_isPVM_stMat {P : ι → Matrix n n ℝ*} (hfin : ∀ a, FiniteEntries (P a)) :
    IsApproxPVM P ↔ IsPVM (fun a => stMat (P a)) := by
  constructor
  · exact fun h => h.isPVM_stMat
  · intro h
    obtain ⟨horth, htot⟩ := (isPVM_stMat_iff P hfin).1 h
    exact ⟨hfin, horth, htot⟩

/-! ## Dimension quantization -/

/-- The trace of a real idempotent matrix equals its rank. -/
theorem trace_eq_rank_of_idem {Q : Matrix n n ℝ} (h : Q * Q = Q) : Q.trace = (Q.rank : ℝ) := by
  have hidem : IsIdempotentElem (Matrix.toLin' Q) := by
    show Matrix.toLin' Q * Matrix.toLin' Q = Matrix.toLin' Q
    rw [Module.End.mul_eq_comp, ← Matrix.toLin'_mul, h]
  have hproj := (LinearMap.isProj_range_iff_isIdempotentElem (Matrix.toLin' Q)).2 hidem
  have htr : LinearMap.trace ℝ _ (Matrix.toLin' Q) =
      (Module.finrank ℝ (LinearMap.range (Matrix.toLin' Q)) : ℝ) := hproj.trace
  have h1 : LinearMap.trace ℝ (n → ℝ) (Matrix.toLin' Q) = Q.trace := by
    rw [LinearMap.trace_eq_matrix_trace ℝ (Pi.basisFun ℝ n)]
    simp
  have h2 : Q.rank = Module.finrank ℝ (LinearMap.range (Matrix.toLin' Q)) := rfl
  rw [← h1, htr, h2]

/-- **Dimension quantization.** The ranks of the projections observed from a hyperreal PVM sum to
the dimension of the space: an infinitesimally-approximate measurement always collapses onto an
integral orthogonal decomposition of `ℝⁿ`. -/
theorem sum_rank_eq_card {Q : ι → Matrix n n ℝ} (h : IsPVM Q) :
    ∑ a, (Q a).rank = Fintype.card n := by
  have hR : ((∑ a, (Q a).rank : ℕ) : ℝ) = (Fintype.card n : ℝ) := by
    push_cast
    have : ∑ a, ((Q a).rank : ℝ) = ∑ a, (Q a).trace := by
      refine Finset.sum_congr rfl fun a _ => ?_
      rw [trace_eq_rank_of_idem (h.idem a)]
    rw [this, ← Matrix.trace_sum, h.total, Matrix.trace_one]
  exact_mod_cast hR

/-- The observed trace of a member of a hyperreal PVM is a natural number, namely the rank of the
descended projection: **spectral weights are quantized by observation**. -/
theorem exists_nat_st_trace {P : ι → Matrix n n ℝ*} (h : IsApproxPVM P) (a : ι) :
    ∃ k : ℕ, st (P a).trace = (k : ℝ) ∧ k ≤ Fintype.card n := by
  refine ⟨(stMat (P a)).rank, ?_, ?_⟩
  · have hst : st (P a).trace = (stMat (P a)).trace := by
      simp only [Matrix.trace, Matrix.diag]
      exact st_sum fun i _ => h.finite a i i
    rw [hst, trace_eq_rank_of_idem (h.isPVM_stMat.idem a)]
  · have hsum := sum_rank_eq_card h.isPVM_stMat
    calc (stMat (P a)).rank ≤ ∑ b, (stMat (P b)).rank :=
          Finset.single_le_sum (f := fun b => (stMat (P b)).rank) (fun _ _ => Nat.zero_le _)
            (Finset.mem_univ a)
      _ = Fintype.card n := hsum

/-! ## Operator-theoretic characterization of infinitesimal matrices -/

/-- A hyperreal vector is finite if all its coordinates are. -/
def FiniteVec (v : n → ℝ*) : Prop := ∀ i, ¬Infinite (v i)

/-- **Entrywise = operator-theoretic.** A hyperreal matrix is entrywise infinitesimal iff it sends
every finite hyperreal vector to an infinitesimal vector, i.e. iff it has infinitesimal operator
norm.  (In finite dimensions all norms are equivalent, and this is the non-Archimedean shadow of
that fact.) -/
theorem infinitesimalEntries_iff_mulVec (A : Matrix n n ℝ*) :
    InfinitesimalEntries A ↔
      ∀ v : n → ℝ*, FiniteVec v → ∀ i, Infinitesimal (A.mulVec v i) := by
  constructor
  · intro h v hv i
    rw [Matrix.mulVec, dotProduct]
    refine infinitesimal_iff_st_eq_zero.2 ⟨?_, ?_⟩
    · exact not_infinite_sum fun k _ => not_infinite_mul (h i k).not_infinite (hv k)
    · rw [st_sum fun k _ => not_infinite_mul (h i k).not_infinite (hv k)]
      refine Finset.sum_eq_zero fun k _ => ?_
      rw [st_mul (h i k).not_infinite (hv k), (h i k).st_eq, zero_mul]
  · intro h i j
    have hv : FiniteVec (Pi.single j (1 : ℝ*)) := by
      intro k
      by_cases hk : k = j
      · subst hk; simpa using not_infinite_real 1
      · simp only [Pi.single_eq_of_ne hk]
        simpa using not_infinite_real 0
    have := h _ hv i
    rwa [show A.mulVec (Pi.single j (1 : ℝ*)) i = A i j by
      simp [Matrix.mulVec, dotProduct, Pi.single_apply, Finset.sum_ite_eq']] at this

/-! ## The observed Born measure -/

/-- The observed probability that the state `v` is found in the `a`-th channel. -/
def bornWeight (Q : ι → Matrix n n ℝ) (v : n → ℝ) (a : ι) : ℝ := v ⬝ᵥ (Q a).mulVec v

/-- The observed Born weights of a real unit vector sum to one: a hyperreal PVM yields an honest
probability measure on the index set after observation. -/
theorem bornMeasure_sum_eq_one {Q : ι → Matrix n n ℝ} (h : IsPVM Q) (v : n → ℝ)
    (hv : v ⬝ᵥ v = 1) : ∑ a, bornWeight Q v a = 1 := by
  have key : ∑ a, bornWeight Q v a = v ⬝ᵥ ((∑ a, Q a).mulVec v) := by
    simp only [bornWeight, Matrix.sum_mulVec, dotProduct_sum]
  rw [key, h.total, Matrix.one_mulVec, hv]

/-- Born weights of a symmetric (orthogonal) projection are nonnegative. -/
theorem bornMeasure_nonneg {Q : ι → Matrix n n ℝ} (h : IsPVM Q) (hsymm : ∀ a, (Q a)ᵀ = Q a)
    (v : n → ℝ) (a : ι) : 0 ≤ bornWeight Q v a := by
  have hvm : v ᵥ* Q a = Q a *ᵥ v := by
    conv_lhs => rw [← hsymm a]
    rw [Matrix.vecMul_transpose]
  have hQ : v ⬝ᵥ (Q a).mulVec v = ((Q a).mulVec v) ⬝ᵥ ((Q a).mulVec v) := by
    conv_lhs => rw [← h.idem a]
    rw [← Matrix.mulVec_mulVec, dotProduct_mulVec, hvm]
  rw [bornWeight, hQ, dotProduct]
  exact Finset.sum_nonneg fun i _ => mul_self_nonneg _

end PVM

/-! ## Sharpness: finiteness of the entries cannot be dropped -/

section Sharpness

/-- The `2 × 2` hyperreal matrix `!![2, ω; -2ω⁻¹, -1]`. It is an *exact* idempotent, yet its
entrywise standard part `!![2,0;0,-1]` is not. -/
noncomputable def badProj : Matrix (Fin 2) (Fin 2) ℝ* := !![2, ω; -2 * ω⁻¹, -1]

theorem badProj_mul_self : badProj * badProj = badProj := by
  have hωε : (ω : ℝ*) * ε = 1 := by rw [mul_comm]; exact epsilon_mul_omega
  have hεω : (ε : ℝ*) * ω = 1 := epsilon_mul_omega
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [badProj, Matrix.mul_apply, Fin.sum_univ_succ] <;>
    linarith [hωε, hεω]

theorem st_neg_two_mul_epsilon : st (-(2 * ε)) = 0 := by
  have h : Infinitesimal ((ε : ℝ*) * 2) :=
    Infinitesimal.mul_finite infinitesimal_epsilon (by simpa using not_infinite_real 2)
  have h' : Infinitesimal (-(2 * (ε : ℝ*))) := by
    rw [mul_comm]
    exact h.neg
  exact h'.st_eq

theorem stMat_badProj : stMat badProj = !![2, 0; 0, -1] := by
  have h1 : st (ω : ℝ*) = 0 := infinite_omega.st_eq
  have h2 : st (-(2 * (ε : ℝ*))) = 0 := st_neg_two_mul_epsilon
  have h3 : st (2 : ℝ*) = 2 := by simpa using st_id_real 2
  have h4 : st (-1 : ℝ*) = -1 := by simpa using st_id_real (-1)
  ext i j
  fin_cases i <;> fin_cases j <;> simp [badProj, stMat, h1, h2, h3, h4]

/-- **Sharpness of the descent theorem, part I.** Without the finiteness hypothesis the
"if" direction fails: the family `(badProj, 1 - badProj)` is *exactly* pairwise orthogonal and
*exactly* complete, yet its entrywise standard part is not a projection-valued measure. -/
theorem exists_exact_pvm_infinite_entries_not_descending :
    ∃ P : Fin 2 → Matrix (Fin 2) (Fin 2) ℝ*,
      (∀ a b, a ≠ b → P a * P b = 0) ∧ (∑ a, P a) = 1 ∧
        ¬ IsPVM (fun a => stMat (P a)) := by
  classical
  refine ⟨![badProj, 1 - badProj], ?_, ?_, ?_⟩
  · intro a b hab
    fin_cases a <;> fin_cases b <;> simp_all <;>
      simp [mul_sub, sub_mul, badProj_mul_self]
  · simp [Fin.sum_univ_succ]
  · intro h
    have hidem := h.idem 0
    simp only [Matrix.cons_val_zero] at hidem
    rw [stMat_badProj] at hidem
    have h00 := congrFun (congrFun hidem 0) 0
    norm_num [Matrix.mul_apply, Fin.sum_univ_succ] at h00

/-- **Sharpness of the descent theorem, part II.** Without the finiteness hypothesis the
"only if" direction fails: the `1 × 1` family `(1, ω)` has a projection-valued standard part
`(1, 0)`, yet the product `P 0 * P 1 = ω` is infinite, hence very far from infinitesimal. -/
theorem stMat_omegaOne : stMat (!![(ω : ℝ*)]) = 0 := by
  ext i j
  fin_cases i
  fin_cases j
  simp [stMat, infinite_omega.st_eq]

theorem exists_stMat_isPVM_not_approxOrth :
    ∃ P : Fin 2 → Matrix (Fin 1) (Fin 1) ℝ*,
      IsPVM (fun a => stMat (P a)) ∧ ¬ InfinitesimalEntries (P 0 * P 1) := by
  classical
  refine ⟨![1, !![ω]], ⟨?_, ?_, ?_⟩, ?_⟩
  · intro a
    fin_cases a
    · simp
    · simp [stMat_omegaOne]
  · intro a b hab
    fin_cases a <;> fin_cases b <;> simp_all [stMat_omegaOne]
  · simp [Fin.sum_univ_succ, stMat_omegaOne]
  · intro h
    have h0 := h 0 0
    have hentry : (![(1 : Matrix (Fin 1) (Fin 1) ℝ*), !![ω]] 0 *
        ![(1 : Matrix (Fin 1) (Fin 1) ℝ*), !![ω]] 1) 0 0 = ω := by
      simp [Matrix.mul_apply]
    rw [hentry] at h0
    exact infinite_omega.not_infinitesimal h0

end Sharpness

end StandardPartPVM