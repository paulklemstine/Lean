/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Equiangular lines with common angle `arccos(1/3)` — the spectral core of Balla's conjecture

This file develops, from first principles and fully formally, the linear-algebra
core underlying **Balla's conjecture for `α = 1/3`**:

> For all `d ≥ 1`, the maximum number of equiangular lines in `ℝ^d` whose common
> angle is `arccos(1/3)` is at most `max{28, 2(d − 1)}`.

The full conjecture (proved in the literature via a delicate spectral-multiplicity
argument, cf. `Balla-Draxler-Keevash-Sudakov-18`, `Jiang-Polyanskii-20`, building
on `Lemmens-Seidel-73`) is out of reach of a short formalisation, but its two
engines are captured here rigorously and with zero `sorry`s:

* **The projection / tensor bound (Gerzon's absolute bound machinery).**  Mapping
  each unit vector `v` to the symmetric tensor `v ⊗ v`, the pairwise inner
  products become *squares* of the original ones.  For an equiangular system with
  angle `arccos α` (`0 ≤ α < 1`) this gives a *constant-pattern* Gram matrix
  `(1 − α²)·I + α²·J`, which is positive definite, forcing linear independence of
  the tensors and hence the dimension cap `m ≤ d²`.  For `α = 1/3` the off-diagonal
  entry is exactly `1/9`.

* **The Seidel matrix / smallest-eigenvalue mechanism.**  For `α = 1/3` the Gram
  matrix is `G = I + (1/3)·S`, where `S` is a symmetric `0/±1` **Seidel matrix**
  (zero diagonal, `±1` off-diagonal).  Positive semidefiniteness of `G` is
  equivalent to `S ⪰ −3·I`; i.e. the smallest eigenvalue of `S` is at least `−3`.
  The number `3 = 1/α` is the *spectral radius order* `κ₁` in Balla's framework.

This bridges the *combinatorics of equiangular line systems* with the *spectral
theory of Gram matrices*, reusing the constant-pattern positive-definiteness
technique of `Novelty/SpectralBound.lean`.
-/
import Mathlib

open Matrix

namespace EquiangularOneThird

/-! ## A general constant-pattern spectral bound

If a finite family of vectors in a finite-dimensional real inner product space has
constant self inner product `k` and constant pairwise inner product `λ` with
`0 ≤ λ < k`, then it is linearly independent, hence its cardinality is at most the
dimension of the space.  This is the abstract engine reused throughout the file
(a generalisation of `HegedusSpectral.constGram_card_le` to an arbitrary inner
product space). -/

/-- The `m × m` all-ones matrix. -/
noncomputable def allOnes (m : ℕ) : Matrix (Fin m) (Fin m) ℝ := Matrix.of (fun _ _ => (1 : ℝ))

/-- The all-ones matrix is positive semidefinite (it is a Gram matrix `c·cᴴ`). -/
theorem allOnes_posSemidef (m : ℕ) : (allOnes m).PosSemidef := by
  have hJ : allOnes m = (Matrix.replicateCol (Fin 1) (1 : Fin m → ℝ)) *
      (Matrix.replicateCol (Fin 1) (1 : Fin m → ℝ))ᴴ := by
    ext i j; simp [allOnes, Matrix.mul_apply, Matrix.replicateCol, Matrix.conjTranspose]
  rw [hJ]
  exact Matrix.posSemidef_self_mul_conjTranspose _

/-- **Constant-pattern spectral bound.**  A family of `m` vectors in a
finite-dimensional real inner product space `E` with constant self inner product
`k`, constant pairwise inner product `λ`, and `0 ≤ λ < k`, has `m ≤ dim E`. -/
theorem constGram_finrank_le {m : ℕ} {E : Type*} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] [FiniteDimensional ℝ E]
    (v : Fin m → E) (k lam : ℝ) (hlam : 0 ≤ lam) (hkl : lam < k)
    (hdiag : ∀ i, inner ℝ (v i) (v i) = k)
    (hoff : ∀ i j, i ≠ j → inner ℝ (v i) (v j) = lam) :
    m ≤ Module.finrank ℝ E := by
  have hpat : Matrix.gram ℝ v = (k - lam) • (1 : Matrix (Fin m) (Fin m) ℝ) + lam • allOnes m := by
    ext i j
    rw [show (Matrix.gram ℝ v) i j = inner ℝ (v i) (v j) from rfl]
    by_cases h : i = j
    · subst h; rw [hdiag]; simp [Matrix.add_apply, Matrix.smul_apply, allOnes]
    · rw [hoff i j h]; simp [Matrix.add_apply, Matrix.smul_apply, Matrix.one_apply_ne h, allOnes]
  have hpd : (Matrix.gram ℝ v).PosDef := by
    rw [hpat]
    apply Matrix.PosDef.add_posSemidef
    · exact Matrix.PosDef.smul Matrix.PosDef.one (by linarith)
    · exact Matrix.PosSemidef.smul (allOnes_posSemidef m) hlam
  have hli : LinearIndependent ℝ v := (Matrix.posDef_gram_iff_linearIndependent).1 hpd
  simpa using hli.fintype_card_le_finrank

/-! ## The symmetric tensor embedding `v ↦ v ⊗ v` -/

/-- The **symmetric tensor** of a vector with itself, as a point of
`ℝ^{d×d}`: `(v ⊗ v)(s,t) = v s · v t`. -/
noncomputable def tensorEmb {d : ℕ} (v : EuclideanSpace ℝ (Fin d)) :
    EuclideanSpace ℝ (Fin d × Fin d) :=
  (WithLp.equiv 2 (Fin d × Fin d → ℝ)).symm (fun p => v p.1 * v p.2)

/-- **Key inner-product identity.**  The inner product of two tensors is the
*square* of the inner product of the original vectors:
`⟨v ⊗ v, w ⊗ w⟩ = ⟨v, w⟩²`.  This is what turns a common angle `α` into the
constant off-diagonal value `α²`. -/
theorem tensorEmb_inner {d : ℕ} (v w : EuclideanSpace ℝ (Fin d)) :
    inner ℝ (tensorEmb v) (tensorEmb w) = (inner ℝ v w) ^ 2 := by
  have h1 : inner ℝ (tensorEmb v) (tensorEmb w)
      = ∑ p : Fin d × Fin d, (v p.1 * v p.2) * (w p.1 * w p.2) := by
    rw [EuclideanSpace.inner_eq_star_dotProduct]
    simp [dotProduct, tensorEmb, mul_comm]
  rw [h1]
  have h2 : inner ℝ v w = ∑ i : Fin d, v i * w i := by
    rw [EuclideanSpace.inner_eq_star_dotProduct]; simp [dotProduct, mul_comm]
  rw [h2, sq, Finset.sum_mul_sum, ← Finset.sum_product']
  exact Finset.sum_congr rfl (fun p _ => by ring)

/-! ## Equiangular line systems and the absolute (tensor) bound -/

/-- A family `v : Fin m → ℝ^d` is **equiangular with parameter `α`** if every
vector is a unit vector and every pair of distinct vectors has `|⟨vᵢ, vⱼ⟩| = α`
(i.e. the lines they span pairwise meet at angle `arccos α`). -/
def Equiangular {d m : ℕ} (α : ℝ) (v : Fin m → EuclideanSpace ℝ (Fin d)) : Prop :=
  (∀ i, ‖v i‖ = 1) ∧ (∀ i j, i ≠ j → |inner ℝ (v i) (v j)| = α)

/-- Self inner product of a unit vector is `1`. -/
theorem inner_self_of_unit {d : ℕ} {v : EuclideanSpace ℝ (Fin d)} (h : ‖v‖ = 1) :
    inner ℝ v v = (1 : ℝ) := by
  rw [real_inner_self_eq_norm_sq, h]; norm_num

/-- **Absolute (tensor) bound for equiangular systems.**  Any equiangular family of
`m` lines in `ℝ^d` with parameter `α`, `0 ≤ α < 1`, satisfies `m ≤ d²`.

The proof sends each `vᵢ` to the tensor `vᵢ ⊗ vᵢ ∈ ℝ^{d×d}`; by `tensorEmb_inner`
the Gram matrix of the tensors is the constant pattern `(1 − α²)·I + α²·J`, which is
positive definite, so the tensors are linearly independent and `m ≤ dim ℝ^{d×d} = d²`. -/
theorem equiangular_card_le_sq {d m : ℕ} (α : ℝ) (hα : 0 ≤ α) (hα1 : α < 1)
    (v : Fin m → EuclideanSpace ℝ (Fin d)) (h : Equiangular α v) :
    m ≤ d * d := by
  obtain ⟨hunit, hangle⟩ := h
  have hfin : Module.finrank ℝ (EuclideanSpace ℝ (Fin d × Fin d)) = d * d := by
    simp [finrank_euclideanSpace]
  rw [← hfin]
  refine constGram_finrank_le (fun i => tensorEmb (v i)) 1 (α ^ 2) (by positivity) ?_ ?_ ?_
  · nlinarith [hα, hα1]
  · intro i
    rw [tensorEmb_inner, inner_self_of_unit (hunit i)]; norm_num
  · intro i j hij
    rw [tensorEmb_inner, ← sq_abs, hangle i j hij]

/-- **`α = 1/3` absolute bound.**  Equiangular lines in `ℝ^d` with common angle
`arccos(1/3)` number at most `d²`.  (The full Balla bound `max{28, 2(d−1)}` is a
much finer statement; this is the coarse absolute cap coming purely from the tensor
Gram argument.) -/
theorem equiangular_oneThird_card_le_sq {d m : ℕ}
    (v : Fin m → EuclideanSpace ℝ (Fin d)) (h : Equiangular (1 / 3) v) :
    m ≤ d * d :=
  equiangular_card_le_sq (1 / 3) (by norm_num) (by norm_num) v h

/-! ## The "one-sided" regime: all inner products `+1/3`

When *all* pairwise inner products are `+α` (a positive-definite constant pattern
with no sign changes), the sharper bound `m ≤ d` holds directly — this is the
regime with no `−α` entries, corresponding to a positive-eigenvalue Gram matrix. -/

/-- If a family of `m` unit vectors in `ℝ^d` has *all* pairwise inner products equal
to `α` with `0 ≤ α < 1`, then `m ≤ d`.  (No absolute values: genuine equality.) -/
theorem oneSided_card_le {d m : ℕ} (α : ℝ) (hα : 0 ≤ α) (hα1 : α < 1)
    (v : Fin m → EuclideanSpace ℝ (Fin d)) (hunit : ∀ i, ‖v i‖ = 1)
    (hoff : ∀ i j, i ≠ j → inner ℝ (v i) (v j) = α) :
    m ≤ d := by
  have hfin : Module.finrank ℝ (EuclideanSpace ℝ (Fin d)) = d := by
    simp [finrank_euclideanSpace]
  rw [← hfin]
  exact constGram_finrank_le v 1 α hα hα1 (fun i => inner_self_of_unit (hunit i)) hoff

/-! ## The Seidel matrix for `α = 1/3`

For an equiangular system with `α = 1/3`, the Gram matrix `G` (entries `⟨vᵢ, vⱼ⟩`)
has diagonal `1` and off-diagonal `±1/3`.  The **Seidel matrix** is
`S = 3·G − 3·I`: a symmetric matrix with zero diagonal and `±1` off-diagonal.
Positive semidefiniteness of `G` (a Gram matrix is always PSD) is equivalent to
`S + 3·I ⪰ 0`, i.e. `S ⪰ −3·I`: the smallest eigenvalue of `S` is `≥ −3`.  The
integer `3 = 1/α` is the spectral order `κ₁` in Balla's framework. -/

/-- The **Seidel matrix** `S = 3·G − 3·I` of an equiangular `1/3` system. -/
noncomputable def seidel {d m : ℕ} (v : Fin m → EuclideanSpace ℝ (Fin d)) :
    Matrix (Fin m) (Fin m) ℝ :=
  (3 : ℝ) • Matrix.gram ℝ v - (3 : ℝ) • (1 : Matrix (Fin m) (Fin m) ℝ)

/-- The Seidel matrix has **zero diagonal**. -/
theorem seidel_diag {d m : ℕ} (v : Fin m → EuclideanSpace ℝ (Fin d))
    (hunit : ∀ i, ‖v i‖ = 1) (i : Fin m) : seidel v i i = 0 := by
  have : (Matrix.gram ℝ v) i i = inner ℝ (v i) (v i) := rfl
  simp only [seidel, Matrix.sub_apply, Matrix.smul_apply, this,
    inner_self_of_unit (hunit i), Matrix.one_apply_eq, smul_eq_mul]
  ring

/-- The Seidel matrix has **`±1` off-diagonal entries** for an equiangular `1/3`
system: each off-diagonal entry is `+1` or `−1`. -/
theorem seidel_offdiag {d m : ℕ} (v : Fin m → EuclideanSpace ℝ (Fin d))
    (h : Equiangular (1 / 3) v) {i j : Fin m} (hij : i ≠ j) :
    seidel v i j = 1 ∨ seidel v i j = -1 := by
  obtain ⟨_, hangle⟩ := h
  have hg : (Matrix.gram ℝ v) i j = inner ℝ (v i) (v j) := rfl
  have habs : |inner ℝ (v i) (v j)| = 1 / 3 := hangle i j hij
  have hval : seidel v i j = 3 * inner ℝ (v i) (v j) := by
    simp only [seidel, Matrix.sub_apply, Matrix.smul_apply, hg,
      Matrix.one_apply_ne hij, smul_eq_mul]; ring
  rcases abs_eq (by norm_num : (0:ℝ) ≤ 1 / 3) |>.1 habs with hpos | hneg
  · left; rw [hval, hpos]; norm_num
  · right; rw [hval, hneg]; norm_num

/-- The Seidel matrix is **symmetric**. -/
theorem seidel_isSymm {d m : ℕ} (v : Fin m → EuclideanSpace ℝ (Fin d)) :
    (seidel v).IsSymm := by
  have hg : (Matrix.gram ℝ v).IsHermitian := Matrix.isHermitian_gram ℝ v
  unfold Matrix.IsSymm seidel
  rw [Matrix.transpose_sub, Matrix.transpose_smul, Matrix.transpose_smul,
    Matrix.transpose_one]
  congr 1
  simpa [Matrix.IsHermitian, Matrix.conjTranspose, Matrix.map] using hg

/-- **Smallest-eigenvalue bound.**  For an equiangular `1/3` system, `S + 3·I` is
positive semidefinite, i.e. `S ⪰ −3·I`: the smallest eigenvalue of the Seidel
matrix is at least `−3 = −1/α`.  This is the spectral heart of Balla's mechanism
for `α = 1/3`. -/
theorem seidel_add_three_posSemidef {d m : ℕ} (v : Fin m → EuclideanSpace ℝ (Fin d)) :
    (seidel v + (3 : ℝ) • (1 : Matrix (Fin m) (Fin m) ℝ)).PosSemidef := by
  have hEq : seidel v + (3 : ℝ) • (1 : Matrix (Fin m) (Fin m) ℝ)
      = (3 : ℝ) • Matrix.gram ℝ v := by
    simp only [seidel]; abel
  rw [hEq]
  exact (posSemidef_gram ℝ v).smul (by norm_num)

/-! ## The tight absolute (Gerzon) bound `m ≤ (d+1 choose 2) = d(d+1)/2`

The tensor `v ⊗ v` is *symmetric*, so it really lives in a space of dimension
`d(d+1)/2`, not `d²`.  We realise this by embedding into
`EuclideanSpace ℝ (Sym2 (Fin d))` (unordered pairs), with an off-diagonal weight
`√2` chosen so that the inner product is still exactly `⟨v, w⟩²`.  Since
`dim (EuclideanSpace ℝ (Sym2 (Fin d))) = (d+1 choose 2)`, the constant-pattern
argument now yields the sharp **Gerzon absolute bound** `m ≤ (d+1 choose 2)`.  At
`d = 7` this is `28`, exactly the constant appearing in `max{28, 2(d−1)}`. -/

/-- The symmetric bilinear value `v s · v t`, as a function of the *unordered* pair
`{s, t}`. -/
noncomputable def symG {d : ℕ} (v : EuclideanSpace ℝ (Fin d)) : Sym2 (Fin d) → ℝ :=
  Sym2.lift ⟨fun s t => v s * v t, fun s t => by ring⟩

/-- Off-diagonal unordered pairs carry weight `√2` (diagonal pairs weight `1`), so
that the resulting inner product reproduces `⟨v, w⟩²` without double counting. -/
noncomputable def symCoeff {d : ℕ} (p : Sym2 (Fin d)) : ℝ :=
  if p.IsDiag then 1 else Real.sqrt 2

/-- The weighted **symmetric embedding** `v ↦ v ⊗ v` into `ℝ^{Sym2(Fin d)}`. -/
noncomputable def symEmb {d : ℕ} (v : EuclideanSpace ℝ (Fin d)) :
    EuclideanSpace ℝ (Sym2 (Fin d)) :=
  (WithLp.equiv 2 (Sym2 (Fin d) → ℝ)).symm (fun p => symCoeff p * symG v p)

/-
**Inner-product identity for the weighted symmetric embedding.**
`⟨symEmb v, symEmb w⟩ = ⟨v, w⟩²`.

The sum over unordered pairs splits into the diagonal part `∑ᵢ vᵢ²wᵢ²` (weight `1`)
and the off-diagonal part `∑_{i<j} 2·vᵢvⱼwᵢwⱼ` (weight `(√2)² = 2`); together they
rebuild `(∑ᵢ vᵢwᵢ)² = ⟨v, w⟩²`.
-/
theorem symEmb_inner {d : ℕ} (v w : EuclideanSpace ℝ (Fin d)) :
    inner ℝ (symEmb v) (symEmb w) = (inner ℝ v w) ^ 2 := by
  rw [ EuclideanSpace.inner_eq_star_dotProduct ];
  -- Split the sum into diagonal and off-diagonal parts.
  have h_split : ∑ p : Sym2 (Fin d), (symCoeff p * symG v p) * (symCoeff p * symG w p) = ∑ i : Fin d, (v i * w i)^2 + ∑ i : Fin d, ∑ j ∈ Finset.Ioi i, 2 * (v i * w i) * (v j * w j) := by
    have h_split : ∑ p : Sym2 (Fin d), (symCoeff p * symG v p) * (symCoeff p * symG w p) = ∑ p ∈ Finset.univ.filter (fun p : Sym2 (Fin d) => p.IsDiag), (symCoeff p * symG v p) * (symCoeff p * symG w p) + ∑ p ∈ Finset.univ.filter (fun p : Sym2 (Fin d) => ¬p.IsDiag), (symCoeff p * symG v p) * (symCoeff p * symG w p) := by
      rw [ Finset.sum_filter_add_sum_filter_not ];
    convert h_split using 2;
    · refine' Finset.sum_bij ( fun i _ => Sym2.mk ( i, i ) ) _ _ _ _ <;> simp +decide [ symCoeff, symG ];
      · rintro ⟨ a, b ⟩ h; cases h; aesop;
      · exact fun _ => by ring;
    · rw [ show ( Finset.univ.filter fun p : Sym2 ( Fin d ) => ¬p.IsDiag ) = Finset.image ( fun p : Fin d × Fin d => s(p.1, p.2) ) ( Finset.filter ( fun p : Fin d × Fin d => p.1 < p.2 ) ( Finset.univ : Finset ( Fin d × Fin d ) ) ) from ?_, Finset.sum_image ];
      · rw [ Finset.sum_sigma' ];
        refine' Finset.sum_bij ( fun x hx => ( x.fst, x.snd ) ) _ _ _ _ <;> simp +decide [ symCoeff, symG ];
        · grind +revert;
        · grind;
      · intro p hp q hq; simp_all +decide ;
        grind;
      · ext ⟨i, j⟩; simp [Sym2.IsDiag];
        grind;
  convert h_split using 1;
  · simp +decide [ dotProduct, mul_comm ];
    rfl;
  · have h_expand : ∀ (n : ℕ) (f : Fin n → ℝ), (∑ i : Fin n, f i) ^ 2 = ∑ i : Fin n, f i ^ 2 + ∑ i : Fin n, ∑ j ∈ Finset.Ioi i, 2 * f i * f j := by
      intro n f; induction' n with n ih <;> simp +decide [ Fin.sum_univ_succ, * ] ; ring;
      simp_all +decide [ Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm ] ; ring;
    convert h_expand d ( fun i => v.ofLp i * w.ofLp i ) using 1;
    simp +decide [ inner ];
    ac_rfl

/-- **Tight absolute (Gerzon) bound.**  Any equiangular family of `m` lines in
`ℝ^d` with parameter `α`, `0 ≤ α < 1`, satisfies `m ≤ (d+1 choose 2) = d(d+1)/2`. -/
theorem equiangular_card_le_choose {d m : ℕ} (α : ℝ) (hα : 0 ≤ α) (hα1 : α < 1)
    (v : Fin m → EuclideanSpace ℝ (Fin d)) (h : Equiangular α v) :
    m ≤ (d + 1).choose 2 := by
  obtain ⟨hunit, hangle⟩ := h
  have hfin : Module.finrank ℝ (EuclideanSpace ℝ (Sym2 (Fin d))) = (d + 1).choose 2 := by
    rw [finrank_euclideanSpace, Sym2.card]; simp
  rw [← hfin]
  refine constGram_finrank_le (fun i => symEmb (v i)) 1 (α ^ 2) (by positivity) ?_ ?_ ?_
  · nlinarith [hα, hα1]
  · intro i
    rw [symEmb_inner, inner_self_of_unit (hunit i)]; norm_num
  · intro i j hij
    rw [symEmb_inner, ← sq_abs, hangle i j hij]

/-- **`α = 1/3`, `d = 7`: at most `28` equiangular lines.**  This recovers the
exact constant `28` in Balla's bound `max{28, 2(d−1)}` as Gerzon's absolute bound
`d(d+1)/2` evaluated at `d = 7`. -/
theorem equiangular_oneThird_dim7_card_le_28 {m : ℕ}
    (v : Fin m → EuclideanSpace ℝ (Fin 7)) (h : Equiangular (1 / 3) v) :
    m ≤ 28 := by
  have := equiangular_card_le_choose (1 / 3) (by norm_num) (by norm_num) v h
  simpa using this

end EquiangularOneThird