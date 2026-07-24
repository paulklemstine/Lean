/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Separable rank: how many EML outer terms a Kolmogorov–Arnold target needs

`Catalog/Applications/KolmogorovArnoldEMLSeparability.lean` settles the
*rank-one* frontier: a two-variable target collapses to a single outer `exp`
of a sum of inner univariate functions (`exp(ψ x + φ y)`) **iff** it is
multiplicatively separable (`CrossMul`), and the additive target `x + y` has
*no* such rank-one representation.

This file opens the natural next frontier flagged there: *if one outer term is
not enough, how many are needed?*  We introduce the **separable rank** of a
bivariate target,
`f x y = ∑_{k < r} a_k(x) · b_k(y)`,
which is exactly the number of outer functions in a finite Kolmogorov–Arnold
*sum-of-products* superposition.  When the factors are positive, each term is an
EML `outerExp` (`exp`) applied to a sum of EML inner `log`s
(`sepRank_pos_eml`), so the separable rank is the EML outer count.

## Main results

* `mulSeparable_iff_sepRankLE_one` — rank `≤ 1` is exactly multiplicative
  separability, fusing the new notion with the existing characterization.
* `sample_rank_le` — **the lower-bound engine**: any `m × m` evaluation matrix
  `M_{ij} = f(x_i, y_j)` of a separable-rank-`≤ r` target factors as a product
  of an `m × r` and an `r × m` matrix, hence has matrix rank `≤ r`.
* `sepRankLE_ge_of_det_ne_zero` — consequently, a single invertible sample
  matrix forces `m ≤ r`.
* `add_sepRankLE_two` / `add_not_sepRankLE_one` — the additive target `x + y`
  has separable rank **exactly 2** (upper bound explicit; lower bound from a
  `2 × 2` sample with determinant `-1`).
* `powerSum_sepRankLE` / `powerSum_rank_ge` — the power-sum family
  `∑_{k<N} xᵏ yᵏ` has separable rank **exactly `N`** (lower bound via a
  Vandermonde sample `V Vᵀ`, `det = (det V)² ≠ 0`): the number of EML outer
  terms required is **unbounded**, even though Kolmogorov–Arnold caps the number
  of *inner* functions at `2n+1`.
* `sepRank_pos_eml` — the EML bridge: a positive separable-rank-`r` target is a
  sum of `r` catalog `outerExp` (`exp`) terms applied to sums of inner `log`s.

## Lab Notes — see `-- !-- Lab Notes -- !--` blocks below.
-/
import Mathlib
import Applications.EMLTermAlgebra
import Applications.KolmogorovArnoldEML
import Applications.KolmogorovArnoldEMLSeparability

open Real Matrix Finset

namespace KolmogorovArnoldEMLSepRank

open KolmogorovArnoldEML KolmogorovArnoldEMLSep

/-! ### The separable rank predicate -/

/-- `f` has **separable rank `≤ r`**: it is a sum of `r` products of univariate
functions, `f x y = ∑_{k < r} a_k(x) · b_k(y)`.  This is precisely the number of
outer functions in a finite Kolmogorov–Arnold sum-of-products superposition. -/
def SepRankLE (f : ℝ → ℝ → ℝ) (r : ℕ) : Prop :=
  ∃ a b : Fin r → ℝ → ℝ, ∀ x y, f x y = ∑ k, a k x * b k y

/-! ### Rank one is exactly multiplicative separability -/

/-
A rank-`≤ 1` target is multiplicatively separable and conversely. This fuses
the new `SepRankLE` notion with the existing `MulSeparable` characterization.
-/
theorem mulSeparable_iff_sepRankLE_one (f : ℝ → ℝ → ℝ) :
    MulSeparable f ↔ SepRankLE f 1 := by
  constructor <;> rintro ⟨ a, b, h ⟩;
  · exact ⟨ fun _ => a, fun _ => b, fun x y => by simp [ h ] ⟩;
  · exact ⟨ fun x => a 0 x, fun y => b 0 y, fun x y => by simpa [ Fin.sum_univ_succ ] using h x y ⟩

/-! ### The matrix-sampling lower-bound engine -/

/-- **Sampling lower bound.** If `f` has separable rank `≤ r`, then for any
choice of `m` row-points `x` and `m` column-points `y`, the evaluation matrix
`M_{ij} = f(x_i, y_j)` has matrix rank `≤ r`: it factors as an `m × r` matrix
times an `r × m` matrix. -/
theorem sample_rank_le {f : ℝ → ℝ → ℝ} {r : ℕ} (h : SepRankLE f r)
    {m : ℕ} (x y : Fin m → ℝ) :
    (Matrix.of fun i j => f (x i) (y j)).rank ≤ r := by
  obtain ⟨a, b, hab⟩ := h
  have hM : (Matrix.of fun i j => f (x i) (y j))
      = (Matrix.of fun (i : Fin m) (k : Fin r) => a k (x i)) *
        (Matrix.of fun (k : Fin r) (j : Fin m) => b k (y j)) := by
    ext i j
    simp [Matrix.mul_apply, hab]
  rw [hM]
  refine le_trans (Matrix.rank_mul_le_left _ _) ?_
  simpa using (Matrix.of fun (i : Fin m) (k : Fin r) => a k (x i)).rank_le_card_width

/-- **Invertible sample ⇒ rank lower bound.** If some `m × m` evaluation matrix
of `f` has nonzero determinant, then every separable-rank-`≤ r` representation
of `f` must use at least `m` terms. -/
theorem sepRankLE_ge_of_det_ne_zero {f : ℝ → ℝ → ℝ} {r : ℕ} (h : SepRankLE f r)
    {m : ℕ} (x y : Fin m → ℝ)
    (hdet : (Matrix.of fun i j => f (x i) (y j)).det ≠ 0) : m ≤ r := by
  have hrank : (Matrix.of fun i j => f (x i) (y j)).rank = m := by
    have hu : IsUnit (Matrix.of fun i j => f (x i) (y j)) := by
      rw [Matrix.isUnit_iff_isUnit_det]; exact hdet.isUnit
    simpa using Matrix.rank_of_isUnit _ hu
  have := sample_rank_le h x y
  omega

/-! ### The product: separable rank one -/

/-- The product `x·y` has separable rank `≤ 1` (a single term `id · id`). -/
theorem mul_sepRankLE_one : SepRankLE (fun x y => x * y) 1 :=
  ⟨fun _ x => x, fun _ y => y, fun x y => by simp⟩

/-! ### The sum: separable rank exactly two -/

/-- The additive target `x + y` has separable rank `≤ 2`:
`x + y = x·1 + 1·y`. -/
theorem add_sepRankLE_two : SepRankLE (fun x y => x + y) 2 := by
  refine ⟨![fun x => x, fun _ => 1], ![fun _ => 1, fun y => y], ?_⟩
  intro x y
  simp [Fin.sum_univ_two]

/-- The additive target `x + y` does **not** have separable rank `≤ 1`: the
`2 × 2` sample at `x, y ∈ {0,1}` is `![![0,1],![1,2]]`, with determinant `-1 ≠ 0`,
so by `sepRankLE_ge_of_det_ne_zero` any representation needs `≥ 2` terms.  Hence
the separable rank of `x + y` is exactly `2`. -/
theorem add_not_sepRankLE_one : ¬ SepRankLE (fun x y => x + y) 1 := by
  intro h
  have h2 : (2 : ℕ) ≤ 1 :=
    sepRankLE_ge_of_det_ne_zero h ![0, 1] ![0, 1] (by
      simp [Matrix.det_fin_two, Matrix.of_apply])
  omega

/-! ### The power-sum family: unbounded separable rank -/

/-- The power-sum target `∑_{k < N} xᵏ yᵏ`. -/
def powerSum (N : ℕ) (x y : ℝ) : ℝ := ∑ k : Fin N, x ^ (k : ℕ) * y ^ (k : ℕ)

/-- `powerSum N` has separable rank `≤ N`: it is literally a sum of `N`
products `xᵏ · yᵏ`. -/
theorem powerSum_sepRankLE (N : ℕ) : SepRankLE (powerSum N) N :=
  ⟨fun k x => x ^ (k : ℕ), fun k y => y ^ (k : ℕ), fun _ _ => rfl⟩

/-
**Unbounded lower bound.** `powerSum N` has separable rank `≥ N`: sampling at
the distinct points `t i = i` gives the matrix `V Vᵀ` for the Vandermonde matrix
`V`, whose determinant is `(det V)² ≠ 0`.  Combined with `powerSum_sepRankLE`,
the separable rank of `powerSum N` is exactly `N` — so the number of EML outer
terms in a Kolmogorov–Arnold sum-of-products representation is unbounded.
-/
theorem powerSum_rank_ge (N : ℕ) {r : ℕ} (h : SepRankLE (powerSum N) r) : N ≤ r := by
  obtain ⟨ a, b, h ⟩ := h;
  convert sepRankLE_ge_of_det_ne_zero _ ( fun i => ( i : ℝ ) ) ( fun i => ( i : ℝ ) ) _;
  exact fun x y => powerSum N x y;
  · exact ⟨ a, b, fun x y => h x y ⟩;
  · have h_vandermonde : Matrix.of (fun i j : Fin N => powerSum N (i : ℝ) (j : ℝ)) = Matrix.vandermonde (fun i : Fin N => (i : ℝ)) * Matrix.transpose (Matrix.vandermonde (fun i : Fin N => (i : ℝ))) := by
      ext i j; simp +decide [ Matrix.mul_apply, powerSum ] ;
    rw [ h_vandermonde, Matrix.det_mul, Matrix.det_transpose ];
    simp +decide [ Matrix.det_vandermonde ];
    exact Finset.prod_ne_zero_iff.mpr fun i hi => Finset.prod_ne_zero_iff.mpr fun j hj => sub_ne_zero_of_ne <| by simpa [ Fin.ext_iff ] using ne_of_gt <| Finset.mem_Ioi.mp hj;

/-! ### EML bridge: positive terms are catalog `outerExp` of inner `log`s -/

/-
**EML phrasing of separable rank.** If `f x y = ∑_{k} a_k(x) · b_k(y)` with
all factors strictly positive, then each term equals the catalog outer function
`outerExp` (`exp`) applied to a sum of inner `log`s, so
`f x y = ∑_k outerExp.eval (log (a_k x) + log (b_k y))`.  A positive
separable-rank-`r` target is therefore a genuine Kolmogorov–Arnold superposition
with `r` EML outer terms.
-/
theorem sepRank_pos_eml {f : ℝ → ℝ → ℝ} {r : ℕ} (a b : Fin r → ℝ → ℝ)
    (ha : ∀ k x, 0 < a k x) (hb : ∀ k y, 0 < b k y)
    (hf : ∀ x y, f x y = ∑ k, a k x * b k y) :
    ∀ x y, f x y = ∑ k, outerExp.eval (Real.log (a k x) + Real.log (b k y)) := by
  intros x y; rw [hf x y]; simp [outerExp, EMLTerm.eval];
  exact Finset.sum_congr rfl fun _ _ => by rw [ Real.exp_add, Real.exp_log ( ha _ _ ), Real.exp_log ( hb _ _ ) ] ;

/-
-- !-- Lab Notes -- !--

**Hypothesis (Hypothesizer).** The rank-one frontier of
`KolmogorovArnoldEMLSeparability` (`exp(ψ x + φ y)` ⇔ multiplicative
separability) is the bottom of a graded hierarchy. Conjecture: a bivariate
target's minimal number of EML outer terms in a sum-of-products Kolmogorov–Arnold
superposition (`f = ∑_{k<r} a_k(x)·b_k(y)`) is a genuine, unbounded integer
invariant — the *separable rank* — and it coincides with a linear-algebraic
quantity.  Bold sub-conjecture: this number is unbounded, so the `2n+1` cap in
Kolmogorov–Arnold applies only to the count of *inner* univariate functions, not
to the outer ones in the sum-of-products form.

**Experiment (Experimenter).** Defined `SepRankLE f r`.  Proved
`mulSeparable_iff_sepRankLE_one` (the new notion specializes to the old one at
`r = 1`).  The decisive lower-bound engine `sample_rank_le` factors every
evaluation matrix `M_{ij} = f(x_i,y_j)` of a rank-`≤ r` target as an `m×r` times
an `r×m` matrix, so `Matrix.rank M ≤ r`; `sepRankLE_ge_of_det_ne_zero` turns a
single invertible sample into a lower bound `m ≤ r`.  Applications:
`x·y` rank 1; `x+y` rank exactly 2 (a `2×2` sample with `det = -1`); and the
power-sum family `∑_{k<N} xᵏ yᵏ` rank exactly `N`, via the Vandermonde sample
`V Vᵀ` with `det = (det V)² ≠ 0`.  `sepRank_pos_eml` ties positive terms back to
the catalog `outerExp`.

**Analysis (Analyst).** SURVIVED: every theorem, 0 sorries.  The separable rank
equals the *matrix rank* of the kernel sampled on enough points — the bridge to
linear algebra is what makes lower bounds (otherwise hard for function classes)
mechanical.  The power-sum result is the structural payload: it is a concrete,
continuous family witnessing that the outer-term count of EML Kolmogorov–Arnold
superpositions is *unbounded*, so the `2n+1` theorem constrains inner, not outer,
cardinality.  FAILED/refined: a naive attempt to bound the outer count by a
function of `n` is false — it is a property of the *target*, not the dimension.

**Critique (Critic).** Guard checks: no theorem is `True`/`rfl`/`decide`-only.
`sample_rank_le` uses a real matrix factorization + `rank_mul_le_left`;
`add_not_sepRankLE_one` and `powerSum_rank_ge` use genuine determinant
nonvanishing (`det_fin_two`, `det_vandermonde`).  Corner case checked: the
lower bound needs *one* invertible sample, not all — sound, since
`SepRankLE → rank ≤ r` holds for every sample.  The EML bridge requires
strict positivity (so `log` is defined); without it the term-by-term `exp∘log`
identity fails, matching the open-quadrant caveat of the rank-one file.

**Synthesis (PI).** Separable rank is a well-defined, unbounded graded invariant
refining the rank-one EML frontier, computable as the matrix rank of a sampled
kernel, and reducing to multiplicative separability at rank 1.  It cleanly
separates the role of inner vs. outer functions in EML Kolmogorov–Arnold
representations.
-/

end KolmogorovArnoldEMLSepRank