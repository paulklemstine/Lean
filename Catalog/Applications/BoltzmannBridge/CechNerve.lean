/-
# The Boltzmann Bridge IV — The Combinatorial Nerve Lemma for the Vietoris–Rips Filtration

This file extends the catalog's higher-dimensional persistence machinery
(`Applications.BoltzmannBridge.HigherPersistence`, which builds the abstract
`Filtration` calculus and the Vietoris–Rips construction `VRfaces`, together with
`vr_mem_iff_diam_le`) with the *combinatorial shadow of the Nerve Lemma*: the
explicit interleaving between the **Čech** filtration (the nerve of a ball cover)
and the **Vietoris–Rips** filtration.

The Čech complex `Čech(ε)` consists of those simplices whose vertices share a
common closed ball of radius `ε`.  It is the combinatorially-faithful model of the
union of `ε`-balls (Nerve Lemma), but it is expensive to compute; the
Vietoris–Rips complex `VR(ε)` is cheap (pairwise distances only) but only an
approximation.  The classical *interleaving* makes precise how good that
approximation is:

      Čech(ε)  ⊆  VR(2ε)  ⊆  Čech(2ε).

We prove the combinatorial core of this sandwich at the level of the face sets,
the metric content of which is *exactly* the triangle inequality applied to the
diameter weight `diamWeight` of `HigherPersistence`.  The Čech faces also form a
genuine sublevel-style family: down-closed at each scale, and monotone in `ε`.

## Main results

* `CechFaces`                — simplices covered by a common closed `ε`-ball
* `cech_down_closed`         — Čech faces form a complex (downward closed)
* `cech_mono`                — the Čech filtration is nested in the scale
* `cech_subset_vr`           — `Čech(ε) ⊆ VR(2ε)` (triangle inequality)
* `vr_subset_cech`           — nonempty `VR(ε)` faces are `Čech(ε)` faces
* `nerve_interleaving`       — the full sandwich `Čech(ε) ⊆ VR(2ε) ⊆ Čech(2ε)`
-/
import Mathlib
import Applications.BoltzmannBridge.HigherPersistence

open Finset BigOperators

namespace BoltzmannBridge

section Cech

variable {α : Type*} [PseudoMetricSpace α]

/-- The **Čech faces** at scale `ε`: finite simplices all of whose vertices lie in
a common closed ball of radius `ε`.  This is the combinatorial nerve of the cover
of the data by `ε`-balls. -/
def CechFaces (ε : ℝ) : Set (Finset α) :=
  {σ | ∃ c : α, ∀ x ∈ σ, dist x c ≤ ε}

/-- Membership in the Čech complex unfolds to the existence of a common center. -/
@[simp] theorem mem_CechFaces (ε : ℝ) (σ : Finset α) :
    σ ∈ CechFaces ε ↔ ∃ c : α, ∀ x ∈ σ, dist x c ≤ ε := Iff.rfl

-- !-- Lab Notebook: cech_down_closed -- !--
-- !-- Hypothesis: A subface of a Čech face is again a Čech face. -- !--
-- !-- Result: Proved — reuse the center witnessing the larger face. -- !--
-- !-- Insight: Down-closure is "free" because the covering condition is
-- !-- pointwise (∀ x ∈ σ), so restricting to a subset only drops obligations. -- !--
-- !-- Failure analysis: none; the existential center transfers verbatim. -- !--
-- !-- End Lab Notebook -- !--
/-- **The Čech faces form an abstract simplicial complex.**  Any subface of a Čech
face is covered by the same ball, hence is itself a Čech face. -/
theorem cech_down_closed {ε : ℝ} {σ τ : Finset α}
    (hσ : σ ∈ CechFaces ε) (hτσ : τ ⊆ σ) : τ ∈ CechFaces ε := by
  obtain ⟨c, hc⟩ := hσ
  exact ⟨c, fun x hx => hc x (hτσ hx)⟩

-- !-- Lab Notebook: cech_mono -- !--
-- !-- Hypothesis: The Čech filtration is nested in the radius parameter. -- !--
-- !-- Result: Proved — the same center works at the larger radius. -- !--
-- !-- Insight: Monotonicity mirrors `vr_mono`; both come from `le_trans`. -- !--
-- !-- End Lab Notebook -- !--
/-- **Čech filtration monotonicity.**  Enlarging the radius can only add faces. -/
theorem cech_mono {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) :
    (CechFaces ε₁ : Set (Finset α)) ⊆ CechFaces ε₂ := by
  rintro σ ⟨c, hc⟩
  exact ⟨c, fun x hx => le_trans (hc x hx) h⟩

-- !-- Lab Notebook: cech_subset_vr -- !--
-- !-- Hypothesis: A common ε-ball forces all pairwise distances ≤ 2ε. -- !--
-- !-- Result: Proved — `dist x y ≤ dist x c + dist c y ≤ ε + ε`. -- !--
-- !-- Insight: This is the forward half of the Nerve interleaving and is the
-- !-- ONLY metric input; everything else is combinatorial bookkeeping. -- !--
-- !-- Failure analysis: needed `dist_comm` to align `dist c y` with `dist y c`. -- !--
-- !-- End Lab Notebook -- !--
/-- **Nerve interleaving, forward direction: `Čech(ε) ⊆ VR(2ε)`.**  If all
vertices of `σ` lie in a common `ε`-ball, the triangle inequality bounds every
pairwise distance by `2ε`, so `σ` is a Vietoris–Rips face at scale `2ε`. -/
theorem cech_subset_vr (ε : ℝ) :
    (CechFaces ε : Set (Finset α)) ⊆ VRfaces (2 * ε) := by
  rintro σ ⟨c, hc⟩ x hx y hy
  calc dist x y ≤ dist x c + dist c y := dist_triangle x c y
    _ = dist x c + dist y c := by rw [dist_comm y c]
    _ ≤ ε + ε := add_le_add (hc x hx) (hc y hy)
    _ = 2 * ε := by ring

-- !-- Lab Notebook: vr_subset_cech -- !--
-- !-- Hypothesis: A nonempty VR(ε) face is covered by a ball centered at one
-- !-- of its own vertices. -- !--
-- !-- Result: Proved — pick any vertex x₀ as the center; VR gives dist x x₀ ≤ ε. -- !--
-- !-- Insight: This is the reverse half; nonemptiness is essential to supply a
-- !-- center, marking the boundary case (the empty simplex needs `Nonempty α`). -- !--
-- !-- End Lab Notebook -- !--
/-- **Nerve interleaving, reverse direction: `VR(ε) ⊆ Čech(ε)` on nonempty faces.**
A nonempty Vietoris–Rips face is covered by the ball centered at any of its
vertices, so it is a Čech face *at the same scale* (no factor of 2 lost). -/
theorem vr_subset_cech {ε : ℝ} {σ : Finset α} (hne : σ.Nonempty)
    (h : σ ∈ VRfaces ε) : σ ∈ CechFaces ε := by
  obtain ⟨x₀, hx₀⟩ := hne
  exact ⟨x₀, fun x hx => h x hx x₀ hx₀⟩

-- !-- Lab Notebook: nerve_interleaving -- !--
-- !-- Hypothesis: Combining the two halves yields the classical sandwich. -- !--
-- !-- Result: Proved — chain `cech_subset_vr` with `vr_subset_cech` applied
-- !-- pointwise to the nonempty faces of VR(2ε). -- !--
-- !-- Insight: The sandwich `Čech(ε) ⊆ VR(2ε) ⊆ Čech(2ε)` is the finite,
-- !-- combinatorial avatar of the Nerve Lemma's homotopy equivalence. -- !--
-- !-- End Lab Notebook -- !--
/-- **The combinatorial Nerve interleaving.**  Every Čech face at scale `ε` is a
VR face at scale `2ε`, and every nonempty VR face at scale `2ε` is a Čech face at
scale `2ε`.  Together this is the finite avatar of the sandwich
`Čech(ε) ⊆ VR(2ε) ⊆ Čech(2ε)`. -/
theorem nerve_interleaving (ε : ℝ) :
    (CechFaces ε : Set (Finset α)) ⊆ VRfaces (2 * ε) ∧
    ∀ σ ∈ (VRfaces (2 * ε) : Set (Finset α)), σ.Nonempty → σ ∈ CechFaces (2 * ε) := by
  refine ⟨cech_subset_vr ε, ?_⟩
  intro σ hσ hne
  exact vr_subset_cech hne hσ

end Cech

end BoltzmannBridge