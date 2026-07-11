/-
  Geometry Between Dimensions: spaces of unbounded Hausdorff dimension
  ===================================================================

  This file develops a rigorous core for the theme *"a surface whose dimension
  lies beyond every finite dimension"*.  The informal slogan speaks of a
  Hausdorff dimension equal to a cardinal such as `ℵ₁`.  Hausdorff dimension,
  however, is by definition an element of the extended nonnegative reals
  `ℝ≥0∞`, never a cardinal; the honest and strongest faithful reading of the
  slogan is therefore

        `dimH S = ⊤`,

  i.e. the dimension exceeds every natural number.  We show that this single
  extended‑real value already captures all the qualitative phenomena in the
  informal description:

  * **Finite‑dimensional obstruction.**  A set of infinite Hausdorff dimension
    admits no distance‑expanding (antilipschitz) map into *any* finite
    dimensional normed real vector space — in particular into no Euclidean
    space `ℝⁿ`.

  * **A concrete realization inside a Hilbert space.**  The unit of `ℓ²`
    (the sequence Hilbert space, which contains the Hilbert cube) has
    Hausdorff dimension `⊤`, because it receives an *isometric* copy of every
    finite‑dimensional Euclidean space.  Thus the object *does* live inside a
    single separable Hilbert space even though it escapes every `ℝⁿ`.

  * **No finite triangulation.**  A space of infinite Hausdorff dimension is
    never the union of finitely many pieces of finite dimension; in
    particular it carries no finite simplicial triangulation.

  The central quantitative engine is the behaviour of `dimH` under
  metric maps: a `K`‑antilipschitz map cannot decrease dimension
  (`AntilipschitzWith.le_dimH_image`), while every subset of an
  `n`‑dimensional normed space has dimension at most `n`
  (`Real.dimH_univ_eq_finrank`).

  -- !-- Lab Notes -- !--
  Hypothesis (Hypothesizer).  The intuition "dimension between the finite
    dimensions" should be formalizable as `dimH = ⊤`, and this value alone
    should be a complete obstruction to finite‑dimensional embeddings while
    still being realizable inside `ℓ²`.
  Experiment (Experimenter).  We built the ladder of isometric inclusions
    `EuclideanSpace ℝ (Fin n) ↪ ℓ²` sending the standard basis to the first
    `n` unit sequences, and proved `dimH (univ : Set ℓ²) = ⊤` from the fact
    that this ladder pushes the dimension of every `ℝⁿ` inside.
  Analysis (Analyst).  What survives is a clean four‑theorem package:
    obstruction, strict dimension ladder, Hilbert‑space realization, and the
    triangulation corollary.  The naive attempt to read the dimension as a
    genuine cardinal `ℵ₁` fails at the level of *types*: `dimH` lands in
    `ℝ≥0∞`, so the only faithful transfinite value available is `⊤`.
  Critique (Critic).  Each main theorem uses a genuine geometric inequality
    (`by_contra`/`omega`/`calc` over `ℝ≥0∞`), none is definitional or
    vacuous, and the construction theorem exhibits an explicit isometry rather
    than an abstract existence argument.  The obstruction is stated for an
    arbitrary finite‑dimensional normed space, not merely `ℝⁿ`, closing the
    "hidden Euclidean assumption" gap.
  Synthesis (PI).  Infinite Hausdorff dimension is exactly the fixed point of
    the phrase "between the dimensions": too large for any `ℝⁿ`, small enough
    for one separable Hilbert space, and incompatible with finite
    combinatorial descriptions.
-/
import Mathlib

open MeasureTheory Set
open scoped ENNReal

namespace AlephOneSurface

/-! ## The finite‑dimensional obstruction -/

/-- **Finite‑dimensional obstruction.**  A set `s` of infinite Hausdorff
dimension admits no antilipschitz (distance‑expanding) map into any
finite‑dimensional normed real vector space.  Since an isometric or
bi‑Lipschitz embedding is in particular antilipschitz, such a set embeds into
no finite‑dimensional Euclidean space. -/
theorem no_antilipschitz_to_finiteDim
    {X : Type*} [EMetricSpace X] {s : Set X}
    (E : Type*) [NormedAddCommGroup E] [NormedSpace ℝ E] [FiniteDimensional ℝ E]
    (hs : dimH s = ⊤) :
    ¬ ∃ (K : NNReal) (f : X → E), AntilipschitzWith K f := by
  rintro ⟨K, f, hf⟩
  have h1 : dimH s ≤ dimH (f '' s) := hf.le_dimH_image s
  have h2 : dimH (f '' s) ≤ dimH (univ : Set E) := dimH_mono (subset_univ _)
  have h3 : dimH (univ : Set E) = (Module.finrank ℝ E : ℝ≥0∞) := Real.dimH_univ_eq_finrank E
  rw [hs] at h1
  rw [h3] at h2
  have hle : (⊤ : ℝ≥0∞) ≤ (Module.finrank ℝ E : ℝ≥0∞) := le_trans h1 h2
  simp at hle

/-! ## The strict dimension ladder -/

/-- **Strict dimension ladder.**  There is no antilipschitz map from the
`n`‑dimensional Euclidean space into a normed space of strictly smaller
dimension.  Concretely, no distance‑expanding map `ℝⁿ → ℝᵐ` exists when
`m < n`: one cannot "fit" a higher‑dimensional Euclidean space into a lower
dimensional one without collapsing distances. -/
theorem no_antilipschitz_of_finrank_lt
    (n : ℕ) (E : Type*) [NormedAddCommGroup E] [NormedSpace ℝ E] [FiniteDimensional ℝ E]
    (h : Module.finrank ℝ E < n) :
    ¬ ∃ (K : NNReal) (f : EuclideanSpace ℝ (Fin n) → E), AntilipschitzWith K f := by
  rintro ⟨K, f, hf⟩
  have h1 : dimH (univ : Set (EuclideanSpace ℝ (Fin n))) ≤ dimH (f '' univ) :=
    hf.le_dimH_image univ
  have h2 : dimH (f '' univ) ≤ dimH (univ : Set E) := dimH_mono (subset_univ _)
  rw [Real.dimH_univ_eq_finrank (EuclideanSpace ℝ (Fin n))] at h1
  rw [Real.dimH_univ_eq_finrank E] at h2
  simp only [finrank_euclideanSpace, Fintype.card_fin] at h1
  have hchain : (n : ℝ≥0∞) ≤ (Module.finrank ℝ E : ℝ≥0∞) := le_trans h1 h2
  have : n ≤ Module.finrank ℝ E := by exact_mod_cast hchain
  omega

/-! ## Realization inside the sequence Hilbert space `ℓ²`

`lp (fun _ : ℕ => ℝ) 2` is the space `ℓ²` of square‑summable real sequences;
it is a separable Hilbert space and contains the Hilbert cube.  The map
`euclToLp n` places an `n`‑dimensional Euclidean vector into the first `n`
coordinates, giving an isometric copy of `ℝⁿ` inside `ℓ²` for every `n`. -/

/-- The isometric inclusion of `n`‑dimensional Euclidean space into `ℓ²`
that uses the first `n` coordinates. -/
noncomputable def euclToLp (n : ℕ) (x : EuclideanSpace ℝ (Fin n)) : lp (fun _ : ℕ => ℝ) 2 :=
  ∑ i : Fin n, lp.single 2 (i : ℕ) (x i)

/-- The inclusion `euclToLp` is additive on differences (it is in fact
linear), because `lp.single` is additive in its value. -/
theorem euclToLp_sub (n : ℕ) (x y : EuclideanSpace ℝ (Fin n)) :
    euclToLp n (x - y) = euclToLp n x - euclToLp n y := by
  unfold euclToLp
  rw [← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro i _
  rw [← lp.single_sub]
  congr 1

/-
The inclusion `euclToLp` preserves norms: since the images of distinct
basis vectors are supported on distinct coordinates, the `ℓ²` norm of the
image equals the Euclidean norm of the source.
-/
theorem euclToLp_norm (n : ℕ) (x : EuclideanSpace ℝ (Fin n)) :
    ‖euclToLp n x‖ = ‖x‖ := by
  have h_euclToLp_norm : ∀ j : ℕ, (euclToLp n x) j = if h : j < n then x ⟨j, h⟩ else 0 := by
    intro j
    simp [euclToLp, lp.single];
    split_ifs <;> simp_all +decide [ Pi.single_apply ];
    · rw [ Finset.sum_eq_single ⟨ j, by linarith ⟩ ] <;> aesop;
    · exact Finset.sum_eq_zero fun i hi => if_neg ( by linarith [ Fin.is_lt i ] );
  rw [ lp.norm_eq_tsum_rpow ] <;> norm_num [ h_euclToLp_norm ];
  rw [ tsum_eq_sum ];
  any_goals exact Finset.range n;
  · simp +decide [ Finset.sum_range, EuclideanSpace.norm_eq ];
    norm_num [ Real.sqrt_eq_rpow ];
  · aesop

/-- `euclToLp n` is an isometry of `ℝⁿ` onto its image in `ℓ²`. -/
theorem euclToLp_isometry (n : ℕ) : Isometry (euclToLp n) := by
  rw [isometry_iff_dist_eq]
  intro x y
  rw [dist_eq_norm, dist_eq_norm, ← euclToLp_sub, euclToLp_norm]

/-- **Every finite‑dimensional Euclidean space embeds isometrically in `ℓ²`.**
This is the positive counterpart to the obstruction theorems: although the
full transfinite object escapes every `ℝⁿ`, each finite stage lives faithfully
inside a single separable Hilbert space. -/
theorem exists_isometry_euclidean_to_lp (n : ℕ) :
    ∃ f : EuclideanSpace ℝ (Fin n) → lp (fun _ : ℕ => ℝ) 2, Isometry f :=
  ⟨euclToLp n, euclToLp_isometry n⟩

/-- **The sequence Hilbert space has infinite Hausdorff dimension.**  Because
`ℓ²` contains an isometric copy of `ℝⁿ` for every `n`, its Hausdorff dimension
dominates every natural number, hence equals `⊤`.  This is the concrete
"surface between the dimensions". -/
theorem dimH_univ_lp_top :
    dimH (univ : Set (lp (fun _ : ℕ => ℝ) 2)) = ⊤ := by
  refine top_le_iff.mp ?_
  calc (⊤ : ℝ≥0∞) = ⨆ n : ℕ, (n : ℝ≥0∞) := ENNReal.iSup_natCast.symm
    _ ≤ dimH (univ : Set (lp (fun _ : ℕ => ℝ) 2)) := by
        refine iSup_le (fun n => ?_)
        have hanti := (euclToLp_isometry n).antilipschitz
        have h1 : dimH (univ : Set (EuclideanSpace ℝ (Fin n))) ≤ dimH (euclToLp n '' univ) :=
          hanti.le_dimH_image univ
        have h2 : dimH (euclToLp n '' univ) ≤ dimH (univ : Set (lp (fun _ : ℕ => ℝ) 2)) :=
          dimH_mono (subset_univ _)
        rw [Real.dimH_univ_eq_finrank (EuclideanSpace ℝ (Fin n))] at h1
        simp only [finrank_euclideanSpace, Fintype.card_fin] at h1
        exact le_trans h1 h2

/-! ## No finite triangulation -/

/-- **No finite triangulation.**  A set of infinite Hausdorff dimension cannot
be covered by finitely many pieces each of finite Hausdorff dimension.  In
particular it admits no finite simplicial triangulation, whose (finitely many)
simplices are each contained in a finite‑dimensional space and therefore have
finite dimension. -/
theorem no_finite_finiteDim_cover
    {X : Type*} [EMetricSpace X] {s : Set X} (hs : dimH s = ⊤)
    (m : ℕ) (t : Fin m → Set X) (hcov : s ⊆ ⋃ i, t i) (hfin : ∀ i, dimH (t i) ≠ ⊤) :
    False := by
  have hmono : dimH s ≤ dimH (⋃ i, t i) := dimH_mono hcov
  rw [dimH_iUnion, hs] at hmono
  have hsup : (⨆ i, dimH (t i)) ≠ ⊤ := by
    rw [ne_eq, iSup_eq_top]; push_neg
    rcases isEmpty_or_nonempty (Fin m) with he | hne
    · exact ⟨0, by simp⟩
    · obtain ⟨i, -, hi⟩ := Finset.exists_max_image (Finset.univ) (fun i => dimH (t i))
        ⟨Classical.arbitrary _, Finset.mem_univ _⟩
      exact ⟨dimH (t i), lt_top_iff_ne_top.mpr (hfin i), fun j => hi j (Finset.mem_univ _)⟩
  exact hsup (top_le_iff.mp hmono)

/-! ## Synthesis: the transfinite surface -/

/-- **The transfinite surface exists.**  There is a separable Hilbert space
carrying a set `S` such that

* `S` has infinite Hausdorff dimension (`dimH S = ⊤`);
* `S` admits no antilipschitz map into any finite‑dimensional normed space
  (hence no bi‑Lipschitz or isometric embedding into any `ℝⁿ`); and
* every finite‑dimensional Euclidean space embeds isometrically into the
  ambient space.

This packages the three phenomena of the informal "aleph‑one surface" into a
single concrete object. -/
theorem transfinite_surface_exists :
    ∃ (H : Type) (_ : EMetricSpace H) (S : Set H),
      dimH S = ⊤ ∧
      (∀ (E : Type) [NormedAddCommGroup E] [NormedSpace ℝ E] [FiniteDimensional ℝ E],
        ¬ ∃ (K : NNReal) (f : H → E), AntilipschitzWith K f) ∧
      (∀ n : ℕ, ∃ f : EuclideanSpace ℝ (Fin n) → H, Isometry f) := by
  refine ⟨lp (fun _ : ℕ => ℝ) 2, inferInstance, univ, dimH_univ_lp_top, ?_, ?_⟩
  · intro E _ _ _
    exact no_antilipschitz_to_finiteDim E dimH_univ_lp_top
  · intro n
    exact exists_isometry_euclidean_to_lp n

end AlephOneSurface