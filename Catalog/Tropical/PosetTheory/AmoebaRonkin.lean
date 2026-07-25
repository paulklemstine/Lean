import Mathlib

/-!
# Tropical Amoebas, Ronkin Functions, and Maslov Dequantization

This file develops a rigorous, computation-free core of the theory of **amoebas** of
Laurent polynomials, their **Ronkin functions**, and the **Maslov dequantization** that
links amoebas to tropical geometry.

## Mathematical background

For a Laurent polynomial `f(z) = Σ_i c_i z^{m_i}` in `n` complex variables, write each
monomial in *log-modulus coordinates* `x = (log|z_1|, …, log|z_n|)`.  The log-modulus of
the `i`-th monomial is the **affine function**

  `A_i(x) = log|c_i| + ⟨m_i, x⟩`.

The boundary between the regions where different monomials dominate is exactly the
combinatorial skeleton (the *spine*) of the amoeba `𝒜(f) = Log(V(f))`.  The piecewise-linear
function controlling this dominance is the **tropical polynomial**

  `trop f (x) = max_i A_i(x)`,

and the smooth `t`-deformation

  `R_t(x) = t · log Σ_i exp(A_i(x)/t)`

is the **Maslov / log-sum-exp deformation**.  As `t → 0⁺`, `R_t → trop f` — this is
Maslov's dequantization, the analytic bridge between classical and tropical geometry.
`R_1` is precisely the convex upper envelope `log Σ_i |c_i| e^{⟨m_i,x⟩}` that dominates the
genuine Ronkin function `N_f`.

## Main results

* `TropicalAmoeba.affFun_convexOn` — each monomial log-modulus is convex (indeed affine).
* `TropicalAmoeba.convexOn_finset_sup'` — a finite supremum of convex functions is convex.
* `TropicalAmoeba.tropPoly_convexOn` — **the tropical polynomial is convex** (the Ronkin
  spine is a convex PL function).
* `TropicalAmoeba.tropPoly_eq_affFun_of_dominant` — **piecewise linearity**: on the region
  where one monomial dominates, the tropical polynomial equals that affine function.
* `TropicalAmoeba.dominantRegion_convex` — each amoeba-complement (dominance) region is
  convex.
* `TropicalAmoeba.tropPoly_slope_on_dominant` — the **order map**: on a dominance region the
  tropical polynomial has constant integer slope `m_k` (a lattice point of the Newton
  polytope).
* `TropicalAmoeba.maslov_lower`, `maslov_upper` — two-sided bounds
  `trop f ≤ R_t ≤ trop f + t·log N`.
* `TropicalAmoeba.maslov_dequantization_rate` — `|R_t − trop f| ≤ t·log N`.
* `TropicalAmoeba.maslov_tendsto` — **Maslov dequantization** `R_t → trop f` as `t → 0⁺`.

## Catalog synthesis

This extends the Maslov-dequantization theme of `TSM.zeroTemperature_limit`
(`Catalog/Tropical/SemiclassicalLimit.lean`), where the free energy `F(β) → E₀`, and the
log-sum-exp analysis of `LSEConvexity` (`Catalog/Tropical/LSEConvexity.lean`).  Here the
same dequantization mechanism is realised in the *geometric* setting of amoebas: the
partition-function limit becomes the convergence of the Ronkin smoothing to the amoeba
spine, and the index set `Ω` becomes the monomial support of a Laurent polynomial.
-/

noncomputable section

open Real Finset

namespace TropicalAmoeba

variable {n : ℕ} {ι : Type*} [Fintype ι]

/-! ## Affine log-modulus functions -/

/-- The linear part of a monomial's log-modulus: `⟨m, x⟩ = Σ_j m_j x_j`. -/
def affLin (m : Fin n → ℝ) (x : Fin n → ℝ) : ℝ := ∑ j, m j * x j

/-- The log-modulus of a monomial `c · z^m` at log-modulus coordinate `x`:
`A(x) = c + ⟨m, x⟩` (here `c` plays the role of `log|c|`). -/
def affFun (c : ℝ) (m : Fin n → ℝ) (x : Fin n → ℝ) : ℝ := c + affLin m x

/-- `affLin` is genuinely linear in `x` (compatible with arbitrary linear combinations). -/
theorem affLin_combo (m : Fin n → ℝ) (a b : ℝ) (x y : Fin n → ℝ) :
    affLin m (a • x + b • y) = a * affLin m x + b * affLin m y := by
  simp only [affLin, Pi.add_apply, Pi.smul_apply, smul_eq_mul, mul_add, Finset.sum_add_distrib,
    Finset.mul_sum]
  congr 1 <;> apply Finset.sum_congr rfl <;> intro j _ <;> ring

/-- The linear part respects subtraction: `⟨m, x − y⟩ = ⟨m, x⟩ − ⟨m, y⟩`. -/
theorem affLin_sub (m : Fin n → ℝ) (x y : Fin n → ℝ) :
    affLin m (x - y) = affLin m x - affLin m y := by
  simp only [affLin, Pi.sub_apply, mul_sub, Finset.sum_sub_distrib]

-- !-- An affine function is an affine combination of its endpoint values whenever the
-- weights sum to one; expand the linear part and cancel the constant via `a + b = 1`. -- !--
/-- For a convex combination (`a + b = 1`), the affine function `affFun` commutes with it. -/
theorem affFun_combo (c : ℝ) (m : Fin n → ℝ) {a b : ℝ} (hab : a + b = 1)
    (x y : Fin n → ℝ) :
    affFun c m (a • x + b • y) = a * affFun c m x + b * affFun c m y := by
  simp only [affFun, affLin_combo]
  linear_combination (-c) * hab

-- !-- Affine functions are convex because the convexity inequality holds with equality;
-- use `affFun_combo`. -- !--
/-- Each monomial log-modulus `A_i(x) = c + ⟨m, x⟩` is convex (it is affine). -/
theorem affFun_convexOn (c : ℝ) (m : Fin n → ℝ) :
    ConvexOn ℝ Set.univ (affFun c m) := by
  refine ⟨convex_univ, ?_⟩
  intro x _ y _ a b ha hb hab
  exact le_of_eq (affFun_combo c m hab x y)

/-! ## Convexity of finite suprema -/

-- !-- Induct on the (nonempty) finset; the inductive step rewrites `sup'` over a `cons`
-- as a binary `max` and applies `ConvexOn.sup`. -- !--
/-- A finite supremum of convex functions on a real vector space is convex. -/
theorem convexOn_finset_sup' {E : Type*} [AddCommMonoid E] [Module ℝ E]
    {κ : Type*} (s : Finset κ) (hs : s.Nonempty)
    (f : κ → E → ℝ) (hf : ∀ i ∈ s, ConvexOn ℝ Set.univ (f i)) :
    ConvexOn ℝ Set.univ (fun x => s.sup' hs (fun i => f i x)) := by
  induction hs using Finset.Nonempty.cons_induction with
  | singleton a => simpa using hf a (by simp)
  | cons a s ha hs ih =>
      have hih := ih (fun i hi => hf i (by simp [hi]))
      have hfa := hf a (by simp)
      have hcons : (fun x => (cons a s ha).sup' (by simp) (fun i => f i x))
          = (fun x => max (f a x) (s.sup' hs (fun i => f i x))) := by
        funext x; rw [Finset.sup'_cons]
      rw [hcons]
      exact hfa.sup hih

/-! ## The tropical polynomial (amoeba spine) -/

variable [Nonempty ι]

/-- Nonemptiness of the monomial index set. -/
theorem univ_ne : (Finset.univ : Finset ι).Nonempty := Finset.univ_nonempty

/-- The **tropical polynomial** `trop f (x) = max_i A_i(x)`: the piecewise-linear
combinatorial skeleton (spine) of the amoeba of `f = Σ_i c_i z^{m_i}`. -/
def tropPoly (c : ι → ℝ) (m : ι → Fin n → ℝ) (x : Fin n → ℝ) : ℝ :=
  Finset.univ.sup' univ_ne (fun i => affFun (c i) (m i) x)

-- !-- The tropical polynomial is a finite max of affine (hence convex) functions, so
-- `convexOn_finset_sup'` applies. -- !--
/-- **The tropical polynomial is convex.** The Ronkin spine is a convex PL function. -/
theorem tropPoly_convexOn (c : ι → ℝ) (m : ι → Fin n → ℝ) :
    ConvexOn ℝ Set.univ (tropPoly c m) :=
  convexOn_finset_sup' Finset.univ univ_ne _ (fun i _ => affFun_convexOn (c i) (m i))

-- !-- `sup'` equals any term that upper-bounds all others; antisymmetry of `≤`. -- !--
/-- **Piecewise linearity.** Where monomial `k` dominates all others, the tropical
polynomial coincides with the single affine function `A_k`. -/
theorem tropPoly_eq_affFun_of_dominant (c : ι → ℝ) (m : ι → Fin n → ℝ) (x : Fin n → ℝ)
    (k : ι) (hk : ∀ i, affFun (c i) (m i) x ≤ affFun (c k) (m k) x) :
    tropPoly c m x = affFun (c k) (m k) x := by
  apply le_antisymm
  · exact Finset.sup'_le univ_ne _ (fun i _ => hk i)
  · exact Finset.le_sup' (fun i => affFun (c i) (m i) x) (Finset.mem_univ k)

/-! ## Amoeba-complement (dominance) regions -/

/-- The closed region of log-modulus space where monomial `k` dominates: a component of the
amoeba complement, on which the tropical polynomial is affine. -/
def dominantRegion (c : ι → ℝ) (m : ι → Fin n → ℝ) (k : ι) : Set (Fin n → ℝ) :=
  {x | ∀ i, affFun (c i) (m i) x ≤ affFun (c k) (m k) x}

-- !-- The region is an intersection of half-spaces `A_i − A_k ≤ 0`; affineness of `affFun`
-- (via `affFun_combo`) preserves each inequality under convex combinations. -- !--
omit [Fintype ι] [Nonempty ι] in
/-- Each dominance region (amoeba-complement component) is convex. -/
theorem dominantRegion_convex (c : ι → ℝ) (m : ι → Fin n → ℝ) (k : ι) :
    Convex ℝ (dominantRegion c m k) := by
  intro x hx y hy a b ha hb hab i
  rw [affFun_combo (c i) (m i) hab, affFun_combo (c k) (m k) hab]
  have hxi := hx i
  have hyi := hy i
  nlinarith [mul_le_mul_of_nonneg_left hxi ha, mul_le_mul_of_nonneg_left hyi hb]

-- !-- On a dominance region both points evaluate `tropPoly` to `A_k`; subtract and use
-- linearity of the slope `affLin (m k)`. -- !--
/-- **The order map / integer slope.** On the region where monomial `k` dominates, the
tropical polynomial has constant slope `m_k`: its increments are exactly `⟨m_k, x − y⟩`.
When the `m_i` are integer vectors (Newton-polytope lattice points) this is the integral
slope characterising the amoeba complement. -/
theorem tropPoly_slope_on_dominant (c : ι → ℝ) (m : ι → Fin n → ℝ) (k : ι)
    {x y : Fin n → ℝ} (hx : x ∈ dominantRegion c m k) (hy : y ∈ dominantRegion c m k) :
    tropPoly c m x - tropPoly c m y = affLin (m k) (x - y) := by
  rw [tropPoly_eq_affFun_of_dominant c m x k hx,
      tropPoly_eq_affFun_of_dominant c m y k hy]
  simp only [affFun, affLin_sub]
  ring

/-! ## The Maslov / Ronkin smoothing and dequantization -/

/-- The **Maslov-deformed Ronkin function**
`R_t(x) = t · log Σ_i exp(A_i(x)/t)`.  `R_1(x) = log Σ_i e^{A_i(x)}` is the convex
upper envelope dominating the genuine Ronkin function `N_f`; the family interpolates to the
amoeba spine as `t → 0⁺`. -/
def ronkinDeform (c : ι → ℝ) (m : ι → Fin n → ℝ) (t : ℝ) (x : Fin n → ℝ) : ℝ :=
  t * Real.log (∑ i, Real.exp (affFun (c i) (m i) x / t))

-- !-- A single term lower-bounds the sum, and `log` is monotone: pick the maximiser. -- !--
/-- **Lower Maslov bound**: `trop f (x) ≤ R_t(x)` for `t > 0`. -/
theorem maslov_lower (c : ι → ℝ) (m : ι → Fin n → ℝ) (t : ℝ) (ht : 0 < t)
    (x : Fin n → ℝ) :
    tropPoly c m x ≤ ronkinDeform c m t x := by
  set g : ι → ℝ := fun i => affFun (c i) (m i) x with hg
  obtain ⟨i0, _, hi0⟩ := Finset.exists_mem_eq_sup' (univ_ne (ι := ι)) g
  rw [tropPoly, ronkinDeform]
  show Finset.univ.sup' univ_ne g ≤ t * Real.log (∑ i, Real.exp (g i / t))
  rw [hi0]
  have hle : Real.exp (g i0 / t) ≤ ∑ i, Real.exp (g i / t) :=
    Finset.single_le_sum (f := fun i => Real.exp (g i / t))
      (fun i _ => (Real.exp_pos _).le) (Finset.mem_univ i0)
  have hlog : g i0 / t ≤ Real.log (∑ i, Real.exp (g i / t)) := by
    have := Real.log_le_log (Real.exp_pos _) hle
    rwa [Real.log_exp] at this
  have := (div_le_iff₀ ht).mp hlog
  linarith

-- !-- Each term is ≤ `exp(max/t)`, so the sum is ≤ `N · exp(max/t)`; take `log`. -- !--
/-- **Upper Maslov bound**: `R_t(x) ≤ trop f (x) + t·log N` for `t > 0`. -/
theorem maslov_upper (c : ι → ℝ) (m : ι → Fin n → ℝ) (t : ℝ) (ht : 0 < t)
    (x : Fin n → ℝ) :
    ronkinDeform c m t x ≤ tropPoly c m x + t * Real.log (Fintype.card ι) := by
  set g : ι → ℝ := fun i => affFun (c i) (m i) x with hg
  rw [tropPoly, ronkinDeform]
  set M := Finset.univ.sup' univ_ne g with hM
  have hbound : ∀ i, g i ≤ M := fun i => Finset.le_sup' g (Finset.mem_univ i)
  have hsum_le : (∑ i, Real.exp (g i / t)) ≤ (Fintype.card ι) * Real.exp (M / t) := by
    have hstep : (∑ i, Real.exp (g i / t)) ≤ ∑ _i : ι, Real.exp (M / t) := by
      apply Finset.sum_le_sum
      intro i _
      apply Real.exp_le_exp.mpr
      gcongr
      exact hbound i
    simpa [Finset.sum_const, Finset.card_univ] using hstep
  have hsum_pos : 0 < ∑ i, Real.exp (g i / t) :=
    Finset.sum_pos (fun i _ => Real.exp_pos _) (univ_ne (ι := ι))
  have hlog := Real.log_le_log hsum_pos hsum_le
  rw [Real.log_mul (by positivity) (by positivity), Real.log_exp] at hlog
  have hmul : t * Real.log (∑ i, Real.exp (g i / t))
      ≤ t * (Real.log (Fintype.card ι) + M / t) :=
    mul_le_mul_of_nonneg_left hlog ht.le
  rw [mul_add, mul_div_cancel₀ _ ht.ne'] at hmul
  linarith

-- !-- Combine the two Maslov bounds: the deviation lies in `[0, t·log N]`. -- !--
/-- **Dequantization rate**: `|R_t(x) − trop f (x)| ≤ t·log N`. -/
theorem maslov_dequantization_rate (c : ι → ℝ) (m : ι → Fin n → ℝ) (t : ℝ) (ht : 0 < t)
    (x : Fin n → ℝ) :
    |ronkinDeform c m t x - tropPoly c m x| ≤ t * Real.log (Fintype.card ι) := by
  rw [abs_le]
  constructor
  · have hlogn : 0 ≤ Real.log (Fintype.card ι) :=
      Real.log_nonneg (by exact_mod_cast Fintype.card_pos)
    have h2 := maslov_lower c m t ht x
    nlinarith [mul_nonneg ht.le hlogn, h2]
  · have := maslov_upper c m t ht x
    linarith

-- !-- The deviation is squeezed between `0` and `t·log N`, which tends to `0` as
-- `t → 0⁺`; conclude by the squeeze theorem. -- !--
/-- **Maslov dequantization**: the Ronkin smoothing converges to the amoeba spine,
`R_t(x) → trop f (x)` as `t → 0⁺`.  This is the analytic bridge from the smooth (classical)
world to tropical geometry. -/
theorem maslov_tendsto (c : ι → ℝ) (m : ι → Fin n → ℝ) (x : Fin n → ℝ) :
    Filter.Tendsto (fun t => ronkinDeform c m t x)
      (nhdsWithin 0 (Set.Ioi 0)) (nhds (tropPoly c m x)) := by
  rw [Metric.tendsto_nhdsWithin_nhds]
  intro ε hε
  have hcard : (0:ℝ) ≤ Real.log (Fintype.card ι) := by
    have : (1:ℝ) ≤ Fintype.card ι := by exact_mod_cast Fintype.card_pos
    exact Real.log_nonneg this
  refine ⟨ε / (Real.log (Fintype.card ι) + 1), by positivity, ?_⟩
  intro t ht hdist
  rw [Set.mem_Ioi] at ht
  rw [Real.dist_eq, sub_zero, abs_of_pos ht] at hdist
  rw [Real.dist_eq]
  have hb := maslov_dequantization_rate c m t ht x
  have hle : t * Real.log (Fintype.card ι) < ε := by
    have h2 : t * (Real.log (Fintype.card ι) + 1) < ε := by
      rw [lt_div_iff₀ (by positivity)] at hdist
      linarith
    nlinarith [mul_pos ht (show (0:ℝ) < Real.log (Fintype.card ι) + 1 by positivity)]
  calc |ronkinDeform c m t x - tropPoly c m x| ≤ t * Real.log (Fintype.card ι) := hb
    _ < ε := hle

/-! ## Generalization and boundary behaviour -/

-- !-- Convexity of `R_t` is exactly the finite Hölder inequality
-- `∑ u_i^a v_i^b ≤ (∑u_i)^a (∑v_i)^b`: affineness turns `exp(A_i(a•x+b•y)/t)` into
-- `(exp A_i x/t)^a (exp A_i y/t)^b`, and `t·log` of Hölder gives the convexity inequality. -- !--
/-- **Generalization (Ronkin convexity).** For every fixed `t > 0` the deformed Ronkin
function `R_t` is convex (log-sum-exp of affine functions).  Together with `maslov_tendsto`,
the convex spine `trop f` is a pointwise limit of these smooth convex functions, giving a
second, analytic proof of `tropPoly_convexOn`. -/
theorem ronkinDeform_convexOn (c : ι → ℝ) (m : ι → Fin n → ℝ) {t : ℝ} (ht : 0 < t) :
    ConvexOn ℝ Set.univ (ronkinDeform c m t) := by
  -- Apply the Hölder's inequality to the sum of exponentials.
  have h_holder : ∀ (x y : Fin n → ℝ) (a b : ℝ), 0 ≤ a → 0 ≤ b → a + b = 1 → (∑ i, Real.exp (affFun (c i) (m i) (a • x + b • y) / t)) ≤ (∑ i, Real.exp (affFun (c i) (m i) x / t)) ^ a * (∑ i, Real.exp (affFun (c i) (m i) y / t)) ^ b := by
    intro x y a b ha hb hab
    have h_holder : (∑ i, (Real.exp (affFun (c i) (m i) x / t)) ^ a * (Real.exp (affFun (c i) (m i) y / t)) ^ b) ≤ (∑ i, Real.exp (affFun (c i) (m i) x / t)) ^ a * (∑ i, Real.exp (affFun (c i) (m i) y / t)) ^ b := by
      have := @Real.inner_le_Lp_mul_Lq;
      by_cases ha' : a = 0 <;> by_cases hb' : b = 0 <;> simp_all +decide [ Real.rpow_def_of_pos, Real.exp_pos ];
      convert this Finset.univ ( fun i => Real.exp ( affFun ( c i ) ( m i ) x / t ) ^ a ) ( fun i => Real.exp ( affFun ( c i ) ( m i ) y / t ) ^ b ) ( show Real.HolderConjugate ( 1 / a ) ( 1 / b ) from ?_ ) using 1 <;> norm_num [ Real.rpow_def_of_pos, Real.exp_pos ];
      · simp +decide [ ha', hb' ];
      · constructor <;> norm_num [ ha', hb', hab ]; all_goals positivity;
    convert h_holder using 2 ; rw [ ← Real.exp_mul, ← Real.exp_mul ] ; ring;
    rw [ ← Real.exp_add ] ; rw [ affFun_combo _ _ hab ] ; ring;
  refine' ⟨ convex_univ, fun x _ y _ a b ha hb hab => _ ⟩;
  unfold ronkinDeform; have := h_holder x y a b ha hb hab; simp_all +decide [ ← mul_assoc ] ;
  have := Real.log_le_log ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ( h_holder x y a b ha hb hab ) ; rw [ Real.log_mul ( ne_of_gt <| Real.rpow_pos_of_pos ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) _ ) ( ne_of_gt <| Real.rpow_pos_of_pos ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) _ ), Real.log_rpow ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ), Real.log_rpow ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ] at this ; nlinarith;

/-- **Boundary case.** With a single monomial the spine is globally affine, so it is convex
but *not strictly* convex — strict convexity genuinely fails on amoeba-complement regions. -/
example (c0 : ℝ) (m0 : Fin n → ℝ) :
    tropPoly (ι := Fin 1) (fun _ => c0) (fun _ => m0) = affFun c0 m0 := by
  funext x
  apply tropPoly_eq_affFun_of_dominant (k := 0)
  intro i
  fin_cases i
  exact le_refl _

end TropicalAmoeba

end