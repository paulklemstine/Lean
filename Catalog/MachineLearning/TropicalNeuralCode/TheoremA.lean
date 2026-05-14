import Mathlib
import MachineLearning.TropicalNeuralCode.Defs

/-!
# Theorem A: Positive Tropical Separation Gives Certified Classification

## Main Results

* `tropical_hull_margin_certifies_binary_classification` — if two codebooks are
  pointwise separated by margin `γ > 0`, no observation can simultaneously lie
  within `γ/2`-tubes around both codebooks.

* `tropical_score_stability_under_coord_perturbation` — coordinatewise perturbations
  of size `< γ/2` preserve strict tropical score ordering between classes.

* `uniform_separation_certifies_classification` — uniform separation in a fixed
  coordinate yields certified binary classification.
-/

noncomputable section

open Finset BigOperators

/-! ## Pointwise Separation Theorem

The simplest version: if every pair (a, b) from codebooks A, B has a coordinate
with gap ≥ γ, then no point x can be within γ/2 of both a and b. -/

/-
**Certified Binary Classification via Tropical Separation.**
If every codeword in `A` is separated from every codeword in `B` by margin `γ > 0`
(witnessed by some coordinate), then no observation `x` can simultaneously lie
within `γ/2`-balls (in ℓ∞) of both `A` and `B`.
-/
theorem tropical_hull_margin_certifies_binary_classification
    {n : ℕ} [NeZero n]
    (A B : Finset (TropPoint n))
    (γ : ℝ)
    (hγ : 0 < γ)
    (hsep : ∀ a ∈ A, ∀ b ∈ B, ∃ i : Fin n, γ ≤ a i - b i)
    : ∀ x : TropPoint n,
      (∃ a ∈ A, ∀ i, |x i - a i| < γ / 2) →
      ¬ (∃ b ∈ B, ∀ i, |x i - b i| < γ / 2) := by
  grind +extAll

/-! ## Tropical Score Stability Under Perturbation

The key stability theorem: if `x` has a gap of `γ` between tropical scores
for classes `A` and `B`, then any perturbation of size `< γ/2` preserves
the strict ordering. -/

/-
Coordinatewise gap is Lipschitz with respect to ℓ∞ perturbations.
-/
theorem coordGap_lipschitz {n : ℕ} [NeZero n]
    (s : TropPoint n) (x x' : TropPoint n) (ε : ℝ)
    (hpert : ∀ i, |x i - x' i| ≤ ε) :
    |coordGap x s - coordGap x' s| ≤ ε := by
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
  · refine' sub_le_iff_le_add'.mpr _;
    refine' le_trans ( ciInf_le _ _ ) _;
    exact Set.finite_range _ |> Set.Finite.bddBelow;
    exact Classical.choose ( show ∃ i, x' i - s i = coordGap x' s from by
                              exact ( IsCompact.sInf_mem ( Set.finite_range _ |> Set.Finite.isCompact ) <| Set.nonempty_of_mem <| Set.mem_range_self <| ⟨ 0, NeZero.pos n ⟩ ) )
    generalize_proofs at *;
    linarith [ Classical.choose_spec ‹∃ i, x' i - s i = coordGap x' s›, abs_le.mp ( hpert ( Classical.choose ‹∃ i, x' i - s i = coordGap x' s› ) ) ];
  · refine' sub_le_iff_le_add'.mpr _;
    refine' ( ciInf_le_of_le _ _ _ );
    exact Set.finite_range _ |> Set.Finite.bddBelow;
    exact Classical.choose ( show ∃ i, x i - s i = coordGap x s from by
                              exact ( IsCompact.sInf_mem ( Set.finite_range _ |> Set.Finite.isCompact ) <| Set.nonempty_of_mem <| Set.mem_range_self <| ⟨ 0, NeZero.pos n ⟩ ) )
    generalize_proofs at *;
    linarith [ abs_le.mp ( hpert ( Classical.choose ‹∃ i, x i - s i = coordGap x s› ) ), Classical.choose_spec ‹∃ i, x i - s i = coordGap x s› ]

/-
The tropical generator score is Lipschitz with respect to ℓ∞ perturbations.
-/
theorem tropGeneratorScore_lipschitz {n : ℕ} [NeZero n]
    (S : Finset (TropPoint n)) (x x' : TropPoint n) (ε : ℝ)
    (hε : 0 ≤ ε)
    (hpert : ∀ i, |x i - x' i| ≤ ε) :
    |tropGeneratorScore S x - tropGeneratorScore S x'| ≤ ε := by
  unfold tropGeneratorScore;
  split_ifs;
  · refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
    · refine' sub_le_iff_le_add'.mpr _;
      exact Finset.sup'_le _ _ fun s hs => by linarith [ abs_le.mp ( coordGap_lipschitz s x x' ε hpert ), Finset.le_sup' ( fun s => coordGap x' s ) hs ] ;
    · have h_sup_le : ∀ s ∈ S, coordGap x' s ≤ coordGap x s + ε := by
        intro s hs;
        exact le_trans ( show coordGap x' s ≤ coordGap x s + ε from by linarith [ abs_le.mp ( coordGap_lipschitz s x x' ε hpert ) ] ) le_rfl;
      simp +zetaDelta at *;
      exact fun s hs => le_trans ( h_sup_le s hs ) ( by linarith [ Finset.le_sup' ( fun s => coordGap x s ) hs ] );
  · norm_num [ hε ]

/-
**Tropical Score Stability Under Coordinate Perturbation.**
If the tropical score gap between classes `A` and `B` exceeds `γ`, and
the input is perturbed by at most `ε` in each coordinate with `2ε < γ`,
then the classification is preserved.
-/
theorem tropical_score_stability_under_coord_perturbation
    {n : ℕ} [NeZero n]
    (A B : Finset (TropPoint n))
    (x x' : TropPoint n)
    (γ ε : ℝ)
    (hε : 0 ≤ ε)
    (hpert : ∀ i, |x i - x' i| ≤ ε)
    (hgap : tropGeneratorScore A x ≥ tropGeneratorScore B x + γ)
    (hγε : 2 * ε < γ)
    : tropGeneratorScore A x' > tropGeneratorScore B x' := by
  linarith [ abs_le.mp ( tropGeneratorScore_lipschitz A x x' ε hε hpert ), abs_le.mp ( tropGeneratorScore_lipschitz B x x' ε hε hpert ) ]

/-! ## Uniform Separation Theorem

When all generators are separated in the same coordinate, the proof is
particularly clean. -/

/-
If class `A` uniformly dominates class `B` in coordinate `i₀` by margin `γ`,
then no point can be within `γ/2` of both classes in that coordinate.
-/
theorem uniform_separation_certifies_classification
    {n : ℕ} [NeZero n]
    (A B : Finset (TropPoint n))
    (γ : ℝ) (_hγ : 0 < γ)
    (i₀ : Fin n)
    (hsep : uniformTropicalSeparation γ A B i₀)
    : ∀ x : TropPoint n,
      (∃ a ∈ A, ∀ i, |x i - a i| < γ / 2) →
      ¬ (∃ b ∈ B, ∀ i, |x i - b i| < γ / 2) := by
  intro x hx hsep; simp_all +decide [ abs_lt ] ;
  obtain ⟨ a, ha₁, ha₂ ⟩ := hx; obtain ⟨ b, hb₁, hb₂ ⟩ := hsep; linarith [ ha₂ i₀, hb₂ i₀, ‹uniformTropicalSeparation γ A B i₀› a ha₁ b hb₁ ] ;

end