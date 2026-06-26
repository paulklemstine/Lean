/-
# The Boltzmann Bridge IX — The Persistence Functor and the Representation Theorem

This file discharges **Future Directions 3 and 5** of Boltzmann Bridge VIII
(`Applications.BoltzmannBridge.InterleavingIsometry`).  Bridge VIII proved the
closed-form **isometry formula**

> `eInterleavingDist F G = ⨆ σ, ENNReal.ofReal |F.weight σ - G.weight σ|`
> (`eInterleavingDist_eq_weightSupEDist`),

identifying the interleaving emetric with the sup-distance of the weight
functions.  With the metric pinned to a sup-norm on functions, two purely
structural questions become tractable.

## Direction 3 — Functoriality (the contravariant pullback is short)

A vertex map `f : α → β` induces a **pullback** `pullback f : Filtration β →
Filtration α`, `(pullback f F).weight σ = F.weight (σ.image f)`, monotone because
`Finset.image` is.  This is a genuine contravariant functor (`pullback_id`,
`pullback_comp`), and Bridge VIII makes it **`1`-Lipschitz**
(`eInterleavingDist_pullback_le`, `pullback_lipschitzWith_one`): the simplex-sup of
`pullback`-weight gaps ranges over a *subset* of the simplex-sup of weight gaps, so
the bound is monotonicity of `⨆` over a reindexing.  When `f` is **surjective** the
reindexing is itself surjective onto all simplices of `β`, upgrading the bound to an
**equality** (`eInterleavingDist_pullback_eq_of_surjective`).

> *Correction to the published Direction 3.*  Bridge VIII's narrative claimed
> equality for *injective* `f`.  This is false: an injective `f : α → β` with `α`
> strictly smaller than `β` leaves simplices of `β` outside the image of
> `·.image f`, where `F` and `G` may differ arbitrarily, so the pullback distance
> can strictly undercut `eInterleavingDist F G`.  The reindexing
> `σ ↦ σ.image f` is *surjective* (hence the sups agree) exactly when `f` is
> surjective, which is the correct hypothesis proved here.

## Direction 5 — The representation theorem (surjectivity of `weight`)

Bridge VII's `ext_weight` showed `weight` is *injective*: a filtration is its
weight function.  The converse constructor `ofWeight` shows it is *surjective* onto
the monotone, `∅`-grounded functions: every `w : Finset α → ℝ` with `w ∅ ≤ 0` and
`Monotone w` is the weight of a (unique) filtration (`weight_surjective`).  Packaged
as a bijection (`weightEquiv`), and combined with Bridge VIII, this **completely
classifies** the persistence emetric: `(Filtration α, eInterleavingDist)` is, up to
the explicit isometry `weightEquiv`, nothing but the order interval of monotone
`∅`-grounded functions under the sup-emetric (`eInterleavingDist_ofWeight`).

## Main results

* `pullback`, `pullback_weight`, `pullback_id`, `pullback_comp` — the contravariant
  persistence functor.
* `eInterleavingDist_pullback_le` / `pullback_lipschitzWith_one` — pullback is
  `1`-Lipschitz (Direction 3).
* `eInterleavingDist_pullback_eq_of_surjective` — equality for surjective maps
  (corrected Direction 3).
* `ofWeight`, `weight_surjective`, `weightEquiv` — the representation theorem
  (Direction 5).
* `eInterleavingDist_ofWeight` — the emetric in fully explicit weight-function form.
-/
import Mathlib
import Applications.BoltzmannBridge.HigherPersistence
import Applications.BoltzmannBridge.PersistenceStability
import Applications.BoltzmannBridge.BottleneckStability
import Applications.BoltzmannBridge.InterleavingMetric
import Applications.BoltzmannBridge.InterleavingClosure
import Applications.BoltzmannBridge.InterleavingIsometry

open Finset BigOperators
open scoped ENNReal

namespace BoltzmannBridge

namespace Filtration

variable {α β γ : Type*}

/-! ## The contravariant pullback functor (Direction 3) -/

-- !-- `weight σ := F.weight (σ.image f)`.  `weight_empty`: `(∅).image f = ∅`.
-- !-- `weight_mono`: `σ ⊆ τ ⇒ σ.image f ⊆ τ.image f` (`Finset.image_subset_image`),
-- !-- then `F.weight_mono`. -- !--
/-- **The pullback of a filtration along a vertex map.**  `pullback f F` assigns the
simplex `σ` the weight `F.weight (σ.image f)`; monotone because `Finset.image` is.
This is the action on objects of the contravariant persistence functor. -/
def pullback [DecidableEq β] (f : α → β) (F : Filtration β) : Filtration α where
  weight := fun σ => F.weight (σ.image f)
  weight_empty := by simpa using F.weight_empty
  weight_mono := fun h => F.weight_mono (Finset.image_subset_image h)

@[simp] theorem pullback_weight [DecidableEq β] (f : α → β) (F : Filtration β)
    (σ : Finset α) : (pullback f F).weight σ = F.weight (σ.image f) := rfl

-- !-- `image id = id`, so weights agree; conclude by `ext_weight`. -- !--
/-- **Functoriality (identity).**  Pullback along the identity is the identity. -/
theorem pullback_id [DecidableEq α] (F : Filtration α) : pullback id F = F := by
  apply ext_weight; funext σ; simp

-- !-- `(σ.image f).image g = σ.image (g ∘ f)` (`Finset.image_image`), so the weights
-- !-- of the two filtrations agree; conclude by `ext_weight`. -- !--
/-- **Functoriality (composition, contravariant).**  Pullback turns composition
around: `pullback (g ∘ f) = pullback f ∘ pullback g`. -/
theorem pullback_comp [DecidableEq β] [DecidableEq γ] (f : α → β) (g : β → γ)
    (F : Filtration γ) : pullback (g ∘ f) F = pullback f (pullback g F) := by
  apply ext_weight; funext σ; simp [Finset.image_image]

-- !-- Rewrite both distances by the Bridge VIII isometry formula
-- !-- `eInterleavingDist_eq_weightSupEDist`.  Then `⨆ σ, ofReal |…(σ.image f)…|` is a
-- !-- reindexing of `⨆ τ, ofReal |…τ…|` along `σ ↦ σ.image f`; bound each term by
-- !-- `le_iSup` at `τ = σ.image f`. -- !--
/-- **Pullback is `1`-Lipschitz (Direction 3).**  The interleaving distance can only
contract under pullback: persistence is functorial into short maps. -/
theorem eInterleavingDist_pullback_le [DecidableEq β] (f : α → β) (F G : Filtration β) :
    eInterleavingDist (pullback f F) (pullback f G) ≤ eInterleavingDist F G := by
  rw [eInterleavingDist_eq_weightSupEDist, eInterleavingDist_eq_weightSupEDist,
      weightSupEDist, weightSupEDist]
  refine iSup_le fun σ => ?_
  simp only [pullback_weight]
  exact le_iSup (fun τ : Finset β => ENNReal.ofReal |F.weight τ - G.weight τ|) (σ.image f)

-- !-- `le_antisymm` with `eInterleavingDist_pullback_le`.  For `≥`: by the isometry
-- !-- formula, every `τ : Finset β` is `σ.image f` for some `σ` (use `Function.surjInv`
-- !-- and `Finset.image_image`), so each weight gap at `τ` is realised by the pullback
-- !-- gap at `σ`; bound by `le_iSup`. -- !--
/-- **Pullback along a surjection is an isometry (corrected Direction 3).**  When `f`
is surjective the reindexing `σ ↦ σ.image f` is surjective onto all simplices of
`β`, so the pullback *preserves* the interleaving distance.  (Surjectivity, not
injectivity, is the correct hypothesis — see the file header.) -/
theorem eInterleavingDist_pullback_eq_of_surjective [DecidableEq α] [DecidableEq β]
    (f : α → β) (hf : Function.Surjective f) (F G : Filtration β) :
    eInterleavingDist (pullback f F) (pullback f G) = eInterleavingDist F G := by
  refine le_antisymm (eInterleavingDist_pullback_le f F G) ?_
  rw [eInterleavingDist_eq_weightSupEDist, eInterleavingDist_eq_weightSupEDist,
      weightSupEDist, weightSupEDist]
  refine iSup_le fun τ => ?_
  obtain ⟨σ, rfl⟩ : ∃ σ : Finset α, σ.image f = τ :=
    ⟨τ.image (Function.surjInv hf), by
      rw [Finset.image_image]
      simp only [Function.comp_def, Function.surjInv_eq hf, Finset.image_id']⟩
  exact le_iSup
    (fun σ : Finset α => ENNReal.ofReal |(pullback f F).weight σ - (pullback f G).weight σ|) σ

/-! ## Pullback as a Mathlib short map -/

/-- The Bridge V/VIII pseudo-emetric, as a file-local instance for every vertex
type, so `LipschitzWith` and `edist` are available below. -/
noncomputable local instance pullbackInterleavingPseudoEMetricInst {δ : Type*} :
    PseudoEMetricSpace (Filtration δ) := interleavingPseudoEMetric

-- !-- `LipschitzWith 1 g` unfolds to `edist (g F) (g G) ≤ 1 * edist F G`; here
-- !-- `edist = eInterleavingDist` and `1 * x = x`, so this is
-- !-- `eInterleavingDist_pullback_le`. -- !--
/-- **Pullback is a short map.**  In Mathlib's vocabulary, `pullback f` is
`LipschitzWith 1` for the interleaving emetric. -/
theorem pullback_lipschitzWith_one [DecidableEq β] (f : α → β) :
    LipschitzWith 1 (pullback f : Filtration β → Filtration α) := by
  intro F G
  simp only [ENNReal.coe_one, one_mul]
  exact eInterleavingDist_pullback_le f F G

/-! ## The representation theorem (Direction 5) -/

-- !-- The two non-`weight` fields of `Filtration` are exactly `w ∅ ≤ 0` and
-- !-- monotonicity, so the constructor is immediate. -- !--
/-- **The filtration with a prescribed weight.**  Every monotone, `∅`-grounded
function is the weight of a filtration — the converse constructor to Bridge VII's
`ext_weight`. -/
def ofWeight (w : Finset α → ℝ) (h0 : w ∅ ≤ 0) (hmono : Monotone w) : Filtration α where
  weight := w
  weight_empty := h0
  weight_mono := fun h => hmono h

@[simp] theorem ofWeight_weight (w : Finset α → ℝ) (h0 : w ∅ ≤ 0) (hmono : Monotone w) :
    (ofWeight w h0 hmono).weight = w := rfl

-- !-- `weight_mono` is precisely `Monotone` for the `⊆` order on `Finset α`. -- !--
/-- A filtration's weight is a monotone function (the `⊆`-order form of
`weight_mono`). -/
theorem weight_monotone (F : Filtration α) : Monotone F.weight :=
  fun _ _ h => F.weight_mono h

-- !-- Witness `ofWeight w h0 hmono`; its weight is `w` by `rfl`. -- !--
/-- **`weight` is surjective onto monotone, `∅`-grounded functions (Direction 5).**
Every such function arises as some filtration's weight. -/
theorem weight_surjective (w : Finset α → ℝ) (h0 : w ∅ ≤ 0) (hmono : Monotone w) :
    ∃ F : Filtration α, F.weight = w :=
  ⟨ofWeight w h0 hmono, rfl⟩

-- !-- `toFun = weight`, `invFun = ofWeight`; `left_inv` is `ext_weight rfl`, `right_inv`
-- !-- is `Subtype.ext rfl`. -- !--
/-- **The representation bijection.**  `Filtration α` is in canonical bijection with
the set of monotone, `∅`-grounded functions `Finset α → ℝ`, via `F ↦ F.weight`.
Together with Bridge VIII's isometry formula (`eInterleavingDist_ofWeight`), this
classifies the persistence emetric completely. -/
def weightEquiv : Filtration α ≃ {w : Finset α → ℝ // w ∅ ≤ 0 ∧ Monotone w} where
  toFun F := ⟨F.weight, F.weight_empty, weight_monotone F⟩
  invFun w := ofWeight w.1 w.2.1 w.2.2
  left_inv := fun _ => ext_weight rfl
  right_inv := fun _ => Subtype.ext rfl

-- !-- `eInterleavingDist_eq_weightSupEDist` then unfold `weightSupEDist`; the weights
-- !-- of `ofWeight …` are `w₁`, `w₂` by `rfl`. -- !--
/-- **The persistence emetric in fully explicit form.**  Between the filtrations of
two prescribed weight functions, the interleaving distance is literally the
sup-distance of those functions.  This is the distance-preserving content of
`weightEquiv`: the representation of Direction 5 is *isometric*. -/
theorem eInterleavingDist_ofWeight (w₁ w₂ : Finset α → ℝ)
    (h01 : w₁ ∅ ≤ 0) (hm1 : Monotone w₁) (h02 : w₂ ∅ ≤ 0) (hm2 : Monotone w₂) :
    eInterleavingDist (ofWeight w₁ h01 hm1) (ofWeight w₂ h02 hm2)
      = ⨆ σ, ENNReal.ofReal |w₁ σ - w₂ σ| := by
  rw [eInterleavingDist_eq_weightSupEDist]; rfl

end Filtration

/-
-- !-- Lab Notebook -- !--

## Hypothesis
Bridge VIII collapsed the interleaving emetric to a closed sup-norm on weight
functions.  The adversarial hypotheses: (3) the abstract "persistence is a functor
into short maps" claim is now a one-line `⨆`-monotonicity fact, and (5) Bridge VII's
injectivity of `weight` is half of a *full* representation theorem — `weight` is a
bijection onto monotone `∅`-grounded functions, and Bridge VIII makes that bijection
an isometry.

## Result
Both confirmed.  The contravariant `pullback f` is a functor (`pullback_id`,
`pullback_comp`) and is `1`-Lipschitz (`eInterleavingDist_pullback_le`,
`pullback_lipschitzWith_one`), becoming an isometry for *surjective* `f`
(`eInterleavingDist_pullback_eq_of_surjective`).  The constructor `ofWeight` makes
`weight` surjective (`weight_surjective`), packaged as the bijection `weightEquiv`,
and `eInterleavingDist_ofWeight` exhibits the distance in fully explicit
weight-function form — the representation is isometric, classifying the persistence
emetric completely.

## Insight
Once Bridge VIII identified the metric with a sup-norm, *every* structural question
about the persistence emetric reduces to elementary facts about `⨆` and `Finset.image`:
Lipschitz-ness is `iSup`-monotonicity over a reindexing, isometry-under-surjection is
surjectivity of that reindexing, and the representation theorem is the observation
that the two non-`weight` fields of `Filtration` are exactly the defining constraints
of the target function set.  The closed form turns geometry into bookkeeping.

## Failure analysis
The published Direction 3 over-reached: equality of pullback distances holds for
*surjective*, not *injective*, maps — an injective `f : α → β` leaves simplices of
`β` outside the image of `·.image f`, where the weights may differ without affecting
the pullback distance, so the inequality is strict in general.  We therefore prove
the honest statement (`…_of_surjective`) and document the correction in the header.
The pullback also requires `DecidableEq` on the codomain (for `Finset.image`), the
sole non-structural hypothesis; it is harmless (every type carries a classical
`DecidableEq`) and is discharged at each use site.
-/

end BoltzmannBridge