import Physics.SpectralLinkHomology.ConeAcyclic

/-!
# Spectral bound arithmetic and the apex ⇒ acyclic necessity result

This file connects the combinatorial cone machinery to the extremal spectral
bound `q_{r-1}(K) = t n - (t-1)(r+1)` and proves the *intrinsic* form of the
necessity statement: a complex possessing an **apex** (a vertex contained,
together with each face, in a face) has vanishing reduced Euler characteristic.
Specialized to links, this is exactly the homological condition forced by
saturation of the spectral bound.

## Main results

* `SpectralLinkHomology.qBound_factor` — the factorization
  `q = (t-1)(n-r-1) + n` of the bound.
* `SpectralLinkHomology.qBound_succ_n`, `_succ_r` — its discrete derivatives.
* `SpectralLinkHomology.link_facet_codim` — codimension bookkeeping: an
  `(r-t)`-face inside an `r`-facet has a complementary `t`-set (so the relevant
  homology degree is `t`).
* `SpectralLinkHomology.ASC.reducedEuler_eq_zero_of_apex` — **apex ⇒ acyclic**
  (numerical shadow), proved by a sign-reversing involution.
* `SpectralLinkHomology.ASC.reducedEuler_link_eq_zero_of_apex` — the necessity
  result applied to a link.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The bound `q = tn-(t-1)(r+1)` should factor through the
codimension `n-r-1` of a facet; saturation then pins down the link of every
`(r-t)`-face as a cone. The intrinsic certificate of "cone" is an *apex* vertex.
Experiment (Experimenter): `qBound` identities are pure `ring`. The apex result is
a sign-reversing involution `F ↦ F △ {w}` (toggle the apex), which is closed on
faces (insert by the apex hypothesis, erase by downward closure), fixed-point-free
(membership of `w` flips), and flips the cardinality parity.
Analysis (Analyst): `Finset.sum_involution` packages exactly this. The toggle map
generalizes the fresh-apex cone of `ConeAcyclic.lean`: here the apex may already be
a vertex, so the statement is strictly more general and directly applicable to
links.
Critique (Critic): As before, vanishing of the reduced Euler characteristic is
necessary, not sufficient, for trivial reduced homology; the theorem names and
docstrings flag this honestly. The codimension lemma uses `t ≤ r` to avoid ℕ
truncation pitfalls.
-/

namespace SpectralLinkHomology

open Finset

/-! ### Spectral bound arithmetic (over `ℤ`) -/

/-- The extremal spectral-radius bound `q_{r-1}(K) = t n - (t-1)(r+1)`. -/
def qBound (t n r : ℤ) : ℤ := t * n - (t - 1) * (r + 1)

/-- Factorization of the bound through the facet codimension `n - r - 1`. -/
theorem qBound_factor (t n r : ℤ) : qBound t n r = (t - 1) * (n - r - 1) + n := by
  unfold qBound; ring

/-- Discrete derivative in `n`: each extra vertex raises the bound by `t`. -/
theorem qBound_succ_n (t n r : ℤ) : qBound t (n + 1) r = qBound t n r + t := by
  unfold qBound; ring

/-- Discrete derivative in `r`: raising the dimension lowers the bound by `t-1`. -/
theorem qBound_succ_r (t n r : ℤ) : qBound t n (r + 1) = qBound t n r - (t - 1) := by
  unfold qBound; ring

/-! ### Codimension bookkeeping inside a facet -/

variable {V : Type*} [DecidableEq V]

/-- Codimension bookkeeping: if an `(r-t)`-dimensional face `σ` (so
`σ.card = r - t + 1`) sits inside an `r`-dimensional facet `F`
(`F.card = r + 1`) with `t ≤ r`, then the complementary set `F \ σ` has exactly
`t` elements — i.e. the link of `σ` in `F` is a `(t-1)`-simplex and the relevant
reduced homology lives in degree `t`. -/
theorem link_facet_codim {σ F : Finset V} {r t : ℕ}
    (hsub : σ ⊆ F) (hF : F.card = r + 1) (hσ : σ.card = r - t + 1) (htr : t ≤ r) :
    (F \ σ).card = t := by
  rw [Finset.card_sdiff_of_subset hsub, hF, hσ]
  omega

/-! ### Apex ⇒ acyclic (numerical shadow), via a sign-reversing involution -/

/-
**Apex ⇒ acyclic (numerical shadow).** If a complex has an *apex* `w` — a
vertex such that `insert w F` is a face whenever `F` is — then its reduced Euler
characteristic vanishes. The proof toggles `w` in and out of each face, a
fixed-point-free, sign-reversing involution on faces.
-/
theorem ASC.reducedEuler_eq_zero_of_apex (K : ASC V) (w : V)
    (hapex : ∀ F ∈ K.faces, insert w F ∈ K.faces) :
    K.reducedEuler = 0 := by
  convert Finset.sum_involution _ _ _ _ _
  use fun F _ => if w ∈ F then F.erase w else insert w F
  · grind
  · grind +qlia
  · intro F hF
    split_ifs with hw
    · exact K.down_closed hF (Finset.erase_subset _ _)
    · exact hapex F hF
  · grind

/-- **Necessity for links.** If the link of a face `σ` has an apex `w`, then the
reduced Euler characteristic of the link vanishes — the homological condition
forced by saturating the spectral bound. -/
theorem ASC.reducedEuler_link_eq_zero_of_apex (K : ASC V) (σ : Finset V)
    (hσ : σ ∈ K.faces) (w : V)
    (hapex : ∀ F ∈ (K.link σ hσ).faces, insert w F ∈ (K.link σ hσ).faces) :
    (K.link σ hσ).reducedEuler = 0 :=
  ASC.reducedEuler_eq_zero_of_apex (K.link σ hσ) w hapex

end SpectralLinkHomology