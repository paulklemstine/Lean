/-
# Elementary abelian quotients: the Gaussian-binomial Solomon coefficients

This file settles Conjecture **C3** of `FUTURE_DIRECTIONS.md`: the Möbius weight attached to
the free lattice `ℤⁿ` and the *elementary abelian* finite module `X = (ℤ/p)^d` is the
`q`-factorial product

  `Σ_{Y ≤ X} μ(Y, X) · |Y|ⁿ  =  ∏_{i=0}^{d-1} (pⁿ - p^i)`,

so that the Solomon zeta coefficient of `ℤⁿ` at the quotient type `(ℤ/p)^d` is the Gaussian
binomial coefficient

  `#GL_d(𝔽_p) · #{N ≤ ℤⁿ : ℤⁿ/N ≅ (ℤ/p)^d}  =  ∏_{i=0}^{d-1} (pⁿ - p^i)`,
  `#GL_d(𝔽_p) = ∏_{i=0}^{d-1} (p^d - p^i)`.

The proof runs through the orbit theorem of `Shared.SolomonZeta.Core`:

* surjections `ℤⁿ ↠ X` are generating `n`-tuples of `X` (`homEqCount_top_free_eq_card_spanning`);
* over a `ℤ/p`-module the `ℤ`-span and the `𝔽_p`-span agree (`span_int_eq_top_iff_span_zmod`);
* a tuple of `n` vectors spans `𝔽_p^d` exactly when the *transposed* `d`-tuple of covectors is
  linearly independent (`span_cols_eq_top_iff_linearIndependent_rows`, a rank duality);
* independent `d`-tuples in an `n`-dimensional space over `𝔽_q` number `∏ (qⁿ - q^i)`
  (Mathlib's `card_linearIndependent`), which also covers the degenerate range `d > n`.

Consequences proved here: the Gaussian-binomial identity
(`card_GL_mul_quotIsoCount_elementaryAbelian`), the vanishing `d > n` case
(`quotIsoCount_elementaryAbelian_eq_zero`), the uniqueness statement
`#{N ≤ ℤ^d : ℤ^d/N ≅ (ℤ/p)^d} = 1` (`quotIsoCount_elementaryAbelian_self`) and the explicit
rank two formula (`quotIsoCount_elementaryAbelian_two`).
-/
import Catalog.Shared.SolomonZeta.CyclicPPower

namespace SolomonZeta

open Finset Matrix Module

/-! ### Rank duality: spanning columns versus independent rows -/

/-- **Rank duality.** The columns of a `d × n` matrix over a field span the whole of `K^d`
if and only if its `d` rows are linearly independent. -/
theorem span_cols_eq_top_iff_linearIndependent_rows {K : Type*} [Field K] {d n : ℕ}
    (A : Matrix (Fin d) (Fin n) K) :
    Submodule.span K (Set.range A.col) = ⊤ ↔ LinearIndependent K A.row := by
  constructor
  · intro h
    have hrank : A.rank = d := by
      rw [Matrix.rank, Matrix.range_mulVecLin, h]
      simp [finrank_top]
    rw [linearIndependent_iff_card_eq_finrank_span, Set.finrank,
      ← Matrix.rank_eq_finrank_span_row, hrank, Fintype.card_fin]
  · intro h
    have hrank : A.rank = d := by simpa using h.rank_matrix
    have hr : LinearMap.range A.mulVecLin = ⊤ := by
      apply Submodule.eq_top_of_finrank_eq
      rw [← Matrix.rank] at *
      simp [hrank]
    rw [← Matrix.range_mulVecLin, hr]

/-- The number of `n`-tuples of vectors spanning `K^d`, for a finite field `K` with `q`
elements, is `∏_{i<d} (qⁿ - q^i)`.  (For `d > n` both sides vanish, the right-hand side
because of the factor at `i = n`.) -/
theorem card_spanning_tuples_field (K : Type*) [Field K] [Fintype K] (d n : ℕ) :
    Nat.card {v : Fin n → (Fin d → K) // Submodule.span K (Set.range v) = ⊤} =
      ∏ i : Fin d, (Fintype.card K ^ n - Fintype.card K ^ (i : ℕ)) := by
  have e : {v : Fin n → (Fin d → K) // Submodule.span K (Set.range v) = ⊤} ≃
      {w : Fin d → (Fin n → K) // LinearIndependent K w} :=
    Equiv.subtypeEquiv (Equiv.piComm (fun (_ : Fin n) (_ : Fin d) => K))
      (fun v => span_cols_eq_top_iff_linearIndependent_rows (Matrix.of (fun j i => v i j)))
  rw [Nat.card_congr e]
  by_cases hdn : d ≤ n
  · rw [card_linearIndependent (K := K) (V := Fin n → K)]
    · simp [Module.finrank_fintype_fun_eq_card]
    · simpa [Module.finrank_fintype_fun_eq_card] using hdn
  · push_neg at hdn
    have hempty : IsEmpty {w : Fin d → (Fin n → K) // LinearIndependent K w} := by
      constructor
      rintro ⟨w, hw⟩
      have hrank : (Matrix.of w).rank = d := by simpa using hw.rank_matrix
      have hle := (Matrix.of w).rank_le_card_width
      simp [hrank] at hle
      omega
    rw [Nat.card_of_isEmpty]
    exact (Finset.prod_eq_zero (i := ⟨n, hdn⟩) (Finset.mem_univ _) (by simp)).symm

/-! ### Restriction of scalars along `ℤ ↠ ℤ/p` -/

/-- For a module over `ℤ/p`, a set generates over `ℤ` iff it generates over `ℤ/p`. -/
theorem span_int_eq_top_iff_span_zmod (p : ℕ) (X : Type*) [AddCommGroup X] [Module (ZMod p) X]
    (S : Set X) : Submodule.span ℤ S = ⊤ ↔ Submodule.span (ZMod p) S = ⊤ := by
  rw [← Submodule.restrictScalars_span ℤ (ZMod p) ZMod.intCast_surjective S]
  exact Submodule.restrictScalars_eq_top_iff _ _ _

/-- Every `ℤ`-linear automorphism of a `ℤ/p`-module is `ℤ/p`-linear: the scalars act through
`ℤ ↠ ℤ/p`. -/
noncomputable def intAutEquivZModAut (p : ℕ) (X : Type*) [AddCommGroup X] [Module (ZMod p) X] :
    (X ≃ₗ[ℤ] X) ≃ (X ≃ₗ[ZMod p] X) where
  toFun e :=
    { toFun := e, invFun := e.symm
      map_add' := e.map_add
      map_smul' := by
        intro c x
        obtain ⟨k, rfl⟩ := ZMod.intCast_surjective (n := p) c
        simp only [RingHom.id_apply]
        rw [Int.cast_smul_eq_zsmul, map_zsmul, ← Int.cast_smul_eq_zsmul (R := ZMod p)]
      left_inv := e.left_inv, right_inv := e.right_inv }
  invFun e := e.restrictScalars ℤ
  left_inv := by intro e; ext x; rfl
  right_inv := by intro e; ext x; rfl

/-- The `ℤ`-automorphism group of the elementary abelian group `(ℤ/p)^d` is `GL_d(𝔽_p)`, of
order `∏_{i<d} (p^d - p^i)`. -/
theorem autCard_elementaryAbelian (p d : ℕ) [Fact p.Prime] :
    autCard ℤ (Fin d → ZMod p) = ∏ i : Fin d, (p ^ d - p ^ (i : ℕ)) := by
  have e : Matrix.GeneralLinearGroup (Fin d) (ZMod p) ≃
      ((Fin d → ZMod p) ≃ₗ[ZMod p] (Fin d → ZMod p)) :=
    (Matrix.GeneralLinearGroup.toLin.trans
      (LinearMap.GeneralLinearGroup.generalLinearEquiv (ZMod p) (Fin d → ZMod p))).toEquiv
  rw [autCard, Nat.card_congr (intAutEquivZModAut p (Fin d → ZMod p)), ← Nat.card_congr e,
    Matrix.card_GL_field, ZMod.card]

/-! ### The Möbius weight of an elementary abelian quotient -/

/-- The number of surjections `ℤⁿ ↠ (ℤ/p)^d` is `∏_{i<d} (pⁿ - p^i)`. -/
theorem homEqCount_top_elementaryAbelian (p d n : ℕ) [Fact p.Prime] :
    homEqCount ℤ (Fin n → ℤ) (Fin d → ZMod p) ⊤ = ∏ i : Fin d, (p ^ n - p ^ (i : ℕ)) := by
  rw [homEqCount_top_free_eq_card_spanning]
  have hcongr : Nat.card {v : Fin n → (Fin d → ZMod p) //
        Submodule.span ℤ (Set.range v) = ⊤} =
      Nat.card {v : Fin n → (Fin d → ZMod p) // Submodule.span (ZMod p) (Set.range v) = ⊤} :=
    Nat.card_congr (Equiv.subtypeEquivRight
      (fun v => span_int_eq_top_iff_span_zmod p (Fin d → ZMod p) (Set.range v)))
  rw [hcongr, card_spanning_tuples_field (ZMod p) d n, ZMod.card]

/-- **Gaussian binomial form of the Solomon coefficient.**  For the free lattice `ℤⁿ` and the
elementary abelian quotient type `(ℤ/p)^d`,

  `#GL_d(𝔽_p) · #{N ≤ ℤⁿ : ℤⁿ/N ≅ (ℤ/p)^d} = ∏_{i<d} (pⁿ - p^i)`,

i.e. the count itself is the Gaussian binomial coefficient `[n choose d]_p`. -/
theorem card_GL_mul_quotIsoCount_elementaryAbelian (p d n : ℕ) [Fact p.Prime] :
    (∏ i : Fin d, (p ^ d - p ^ (i : ℕ))) * quotIsoCount ℤ (Fin n → ℤ) (Fin d → ZMod p)
      = ∏ i : Fin d, (p ^ n - p ^ (i : ℕ)) := by
  rw [← autCard_elementaryAbelian p d, ← homEqCount_top_eq_autCard_mul_quotIsoCount,
    homEqCount_top_elementaryAbelian]

/-- Every factor of the Gaussian-binomial product is positive when `i < d ≤ n`. -/
theorem prod_pow_sub_pos (p d n : ℕ) (hp : 1 < p) (hdn : d ≤ n) :
    0 < ∏ i : Fin d, (p ^ n - p ^ (i : ℕ)) := by
  refine Finset.prod_pos fun i _ => ?_
  have hlt : p ^ (i : ℕ) < p ^ n :=
    Nat.pow_lt_pow_right hp (lt_of_lt_of_le i.isLt hdn)
  omega

/-- **The Möbius weight of `(ℤⁿ, (ℤ/p)^d)`.**  For `d ≤ n` the Möbius-weighted polynomial of
the subspace lattice of `𝔽_p^d` evaluates to the integral `q`-factorial product. -/
theorem mobiusWeight_elementaryAbelian (p d n : ℕ) [hp : Fact p.Prime] (hdn : d ≤ n) :
    mobiusWeight ℤ (Fin n → ℤ) (Fin d → ZMod p)
      = ∏ i : Fin d, ((p : ℤ) ^ n - (p : ℤ) ^ (i : ℕ)) := by
  have hkey := card_GL_mul_quotIsoCount_elementaryAbelian p d n
  have hcast : ((∏ i : Fin d, (p ^ n - p ^ (i : ℕ)) : ℕ) : ℤ)
      = ∏ i : Fin d, ((p : ℤ) ^ n - (p : ℤ) ^ (i : ℕ)) := by
    push_cast
    refine Finset.prod_congr rfl fun i _ => ?_
    have hle : p ^ (i : ℕ) ≤ p ^ n :=
      Nat.pow_le_pow_right hp.out.pos (le_of_lt (lt_of_lt_of_le i.isLt hdn))
    push_cast [Nat.cast_sub hle]
    ring
  rw [← autCard_mul_quotIsoCount_eq_mobiusWeight, ← hcast, ← hkey,
    autCard_elementaryAbelian p d]
  push_cast
  ring

/-! ### Corollaries -/

/-- There is no surjection `ℤⁿ ↠ (ℤ/p)^d` when `d > n`: the Solomon coefficient vanishes. -/
theorem quotIsoCount_elementaryAbelian_eq_zero (p d n : ℕ) [hp : Fact p.Prime] (hnd : n < d) :
    quotIsoCount ℤ (Fin n → ℤ) (Fin d → ZMod p) = 0 := by
  have hkey := card_GL_mul_quotIsoCount_elementaryAbelian p d n
  have hzero : ∏ i : Fin d, (p ^ n - p ^ (i : ℕ)) = 0 :=
    Finset.prod_eq_zero (i := ⟨n, hnd⟩) (Finset.mem_univ _) (by simp)
  rw [hzero] at hkey
  rcases Nat.mul_eq_zero.1 hkey with h | h
  · exact absurd h (prod_pow_sub_pos p d d hp.out.one_lt le_rfl).ne'
  · exact h

/-- The only sublattice of `ℤ^d` with elementary abelian quotient `(ℤ/p)^d` is `p·ℤ^d`. -/
theorem quotIsoCount_elementaryAbelian_self (p d : ℕ) [hp : Fact p.Prime] :
    quotIsoCount ℤ (Fin d → ℤ) (Fin d → ZMod p) = 1 := by
  have hkey := card_GL_mul_quotIsoCount_elementaryAbelian p d d
  have hpos := prod_pow_sub_pos p d d hp.out.one_lt le_rfl
  nlinarith [hkey, hpos]

/-- Rank one specialisation: the Gaussian binomial `[n choose 1]_p = (pⁿ-1)/(p-1)`, recovering
the count of index `p` sublattices of `ℤⁿ`. -/
theorem quotIsoCount_elementaryAbelian_one (p n : ℕ) [Fact p.Prime] :
    (p - 1) * quotIsoCount ℤ (Fin n → ℤ) (Fin 1 → ZMod p) = p ^ n - 1 := by
  have hkey := card_GL_mul_quotIsoCount_elementaryAbelian p 1 n
  simpa using hkey

/-- Rank two specialisation: `#GL₂(𝔽_p) = (p²-1)(p²-p)` weights the number of sublattices of
`ℤⁿ` with quotient `(ℤ/p)²`, and the product formula gives `(pⁿ-1)(pⁿ-p)`. -/
theorem quotIsoCount_elementaryAbelian_two (p n : ℕ) [Fact p.Prime] :
    ((p ^ 2 - 1) * (p ^ 2 - p)) * quotIsoCount ℤ (Fin n → ℤ) (Fin 2 → ZMod p)
      = (p ^ n - 1) * (p ^ n - p) := by
  have hkey := card_GL_mul_quotIsoCount_elementaryAbelian p 2 n
  simpa [Fin.prod_univ_two] using hkey

end SolomonZeta