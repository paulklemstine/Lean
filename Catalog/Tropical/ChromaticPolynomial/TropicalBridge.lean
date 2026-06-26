/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Tropical.ChromaticPolynomial.Counting
import Tropical.Core.TropicalPolynomials

/-!
# A tropical view of the chromatic polynomial

The chromatic counting function `chromCount G` is monotone in the number of colors,
and its deletion–contraction recursion *tropicalizes*: under `log`, the integer
addition `P(G−e) = P(G) + P(G/e)` becomes a max-plus (tropical) operation, up to an
additive `log 2` distortion (`a + b` lies between `max a b` and `2 · max a b`).  This
is the link between chromatic-polynomial theory and the tropical/min-plus algebra
developed in `Tropical.Core.TropicalPolynomials`.

## Main results

* `ChromaticTropical.chromCount_monotone` : `k ↦ chromCount G k` is monotone (more
  colors never decrease the number of proper colorings).
* `ChromaticTropical.tropical_deletion_contraction_lower` /
  `tropical_deletion_contraction_upper` : the log of the deletion count is sandwiched
  between the tropical max of the two child counts and that max plus `log 2`.
* `ChromaticTropical.log_chromCount_bot_two` : on a two-vertex edgeless graph the log
  of the chromatic polynomial `k ↦ k²` is *exactly* the degree-two tropical monomial
  `tropicalQuadratic 0 0 0 (log k)` from the catalog (for `k ≥ 1`).
* `ChromaticTropical.tropical_chromatic_envelope_two_mono` : that tropical envelope is
  monotone, via the catalog lemma `TropicalPolynomials.tropical_quadratic_mono`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the additive deletion–contraction recursion is a
"dequantized" tropical recursion: taking `log` sends `+` to `max` up to bounded error,
so the chromatic polynomial is governed by a tropical (max-plus) recursion.

Experiment (Experimenter): we proved the two-sided log bound `max(log a, log b) ≤
log(a+b) ≤ log 2 + max(log a, log b)` for positive `a, b`, instantiated at
`a = chromCount G k`, `b = contractCount …` via `chromCount_deletion_contraction`.
The `k²` law of the two-vertex graph matched the catalog's `tropicalQuadratic`
exactly, giving a clean bridge to the tropical-polynomial file.

Analysis (Analyst): the catalog's tropical polynomials only reach degree 2, which is
why the *exact* tropicalization identity is stated for the two-vertex graph (slope 2);
higher vertex counts need higher-degree tropical monomials.  The deletion–contraction
sandwich, by contrast, holds in full generality.

Critique (Critic): the bounds require positivity of both child counts (otherwise
`Real.log 0 = 0` breaks monotonicity), so those hypotheses are included and are not
vacuous.  The two-vertex identity is genuinely an equality, not an inequality.
-/

open ChromaticPoly

namespace ChromaticTropical

variable {V : Type*} [Fintype V] [DecidableEq V]

/-
**Monotonicity of the chromatic polynomial.**  Adding colors never decreases the
number of proper colorings: `k ↦ chromCount G k` is monotone.
-/
theorem chromCount_monotone (G : SimpleGraph V) [DecidableRel G.Adj] :
    Monotone (fun k => chromCount G k) := by
  intro k l hkl;
  refine' le_trans _ ( Finset.card_le_card _ );
  rotate_left;
  exact Finset.image ( fun f : V → Fin k => fun v => Fin.castLE hkl ( f v ) ) ( properColorings G k );
  · intro;
    simp +decide [ mem_properColorings ];
    rintro f hf rfl a b hab; exact fun h => hf a b hab <| Fin.castLE_injective _ h;
  · rw [ Finset.card_image_of_injective ];
    · rfl;
    · exact fun f g hfg => funext fun v => by simpa [ Fin.ext_iff ] using congr_fun hfg v;

/-
**Tropical deletion–contraction, lower bound.**  The log of the deletion count
dominates the tropical max of the two child counts.
-/
theorem tropical_deletion_contraction_lower {Gdel G : SimpleGraph V} {u v : V}
    [DecidableRel Gdel.Adj] [DecidableRel G.Adj] (hne : u ≠ v)
    (hadd : ∀ a b, G.Adj a b ↔ (Gdel.Adj a b ∨ s(a, b) = s(u, v))) (k : ℕ)
    (ha : 0 < chromCount G k) (hb : 0 < contractCount Gdel u v k) :
    max (Real.log (chromCount G k)) (Real.log (contractCount Gdel u v k))
      ≤ Real.log (chromCount Gdel k) := by
  rw [ chromCount_deletion_contraction hne hadd ];
  exact max_le ( Real.log_le_log ( by positivity ) ( by norm_cast; linarith ) ) ( Real.log_le_log ( by positivity ) ( by norm_cast; linarith ) )

/-
**Tropical deletion–contraction, upper bound.**  The log of the deletion count
exceeds the tropical max of the children by at most `log 2`.
-/
theorem tropical_deletion_contraction_upper {Gdel G : SimpleGraph V} {u v : V}
    [DecidableRel Gdel.Adj] [DecidableRel G.Adj] (hne : u ≠ v)
    (hadd : ∀ a b, G.Adj a b ↔ (Gdel.Adj a b ∨ s(a, b) = s(u, v))) (k : ℕ)
    (ha : 0 < chromCount G k) (hb : 0 < contractCount Gdel u v k) :
    Real.log (chromCount Gdel k)
      ≤ Real.log 2 + max (Real.log (chromCount G k)) (Real.log (contractCount Gdel u v k)) := by
  rw [ show chromCount Gdel k = chromCount G k + contractCount Gdel u v k from ?_ ];
  · rw [ Real.log_le_iff_le_exp, Real.exp_add, Real.exp_log ] <;> norm_cast;
    · have := Real.log_le_iff_le_exp ( by positivity ) |>.1 ( le_max_left ( Real.log ( chromCount G k ) ) ( Real.log ( contractCount Gdel u v k ) ) ) ; ( have := Real.log_le_iff_le_exp ( by positivity ) |>.1 ( le_max_right ( Real.log ( chromCount G k ) ) ( Real.log ( contractCount Gdel u v k ) ) ) ; ( norm_num at * ; linarith; ) );
    · positivity;
  · exact chromCount_deletion_contraction hne hadd k

/-
**Exact tropicalization on the two-vertex edgeless graph.**  Its chromatic
polynomial is `k ↦ k²`, whose log is exactly the catalog's degree-two tropical
monomial `tropicalQuadratic 0 0 0 (log k)`, for `k ≥ 1`.
-/
theorem log_chromCount_bot_two {W : Type*} [Fintype W] [DecidableEq W]
    (hcard : Fintype.card W = 2) {k : ℕ} (hk : 1 ≤ k) :
    Real.log (chromCount (⊥ : SimpleGraph W) k)
      = tropicalQuadratic 0 0 0 (Real.log k) := by
  unfold tropicalQuadratic;
  rw [ chromCount_bot, show Fintype.card W = 2 from hcard, Nat.cast_pow, Real.log_pow ] ; norm_num;
  rw [ max_eq_right ] <;> rw [ max_eq_right ] <;> linarith [ Real.log_nonneg ( Nat.one_le_cast.mpr hk ) ]

/-
The tropical envelope of the two-vertex chromatic polynomial is monotone, via the
catalog lemma `TropicalPolynomials.tropical_quadratic_mono`.
-/
theorem tropical_chromatic_envelope_two_mono :
    Monotone (tropicalQuadratic 0 0 0) := by
  exact TropicalPolynomials.tropical_quadratic_mono 0 0 0 ( by norm_num ) ( by norm_num )

end ChromaticTropical