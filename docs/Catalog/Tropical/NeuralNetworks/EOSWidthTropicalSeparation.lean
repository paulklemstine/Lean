import Mathlib

/-!
# Tropical separation theory of boundary tokens ("EOS width")

This file gives a max-plus (tropical) model of the empirical phenomenon
recorded in round NET-26 (*EOS-WIDTH-DISTRIBUTION-SHIFT*): a boundary
("end-of-sequence") input of width `E` cures a recurrent carry-wall failure
robustly exactly when it owns dimensions that no digit token uses, and is
seed-fragile when its width sits inside the digit subspace (`E ≤ D`).

The formal claim isolated here is that the *control variable is
representational distinctness, not width*:

* `eos_mem_digitSpan_iff` — a boundary vector lies in the tropical (max-plus)
  span of the one-hot digit atoms **iff** it has no exclusive dimension.
* `score_supported_eq_tropComb_of_digitScores` — if it has no exclusive
  dimension, then for **every** max-plus readout `w` the boundary response is a
  fixed tropical combination of the digit responses: the readout cannot tell the
  boundary from a digit step except through digit-controlled quantities.
* `margin_le_of_no_exclusive_dim` — consequently the boundary-vs-digit margin is
  bounded by the boundary's own coefficients, uniformly in `w`.
* `exclusive_dim_unbounded_margin` — with one exclusive dimension the margin
  becomes unbounded (indeed the digit responses can be driven to the tropical
  zero `⊥`), and
* `exclusive_dim_margin_robust` — the separation survives arbitrary bounded
  perturbations of the readout weights.

Everything is stated over the max-plus semiring on `WithBot ℝ`
(`⊕ = max = ⊔`, `⊙ = +`, tropical zero `⊥ = -∞`, tropical one `0`).
-/

namespace EOSWidth

open Finset

/-- Max-plus vectors of width `N`: coordinates in `WithBot ℝ`, where `⊥` plays
the role of the tropical zero `-∞` ("this dimension is not used"). -/
abbrev TVec (N : ℕ) := Fin N → WithBot ℝ

/-- The one-hot tropical digit atom for digit `j`: tropical one (`0`) on
coordinate `j`, tropical zero (`⊥`) elsewhere.  There are `D` digit atoms,
living in the ambient width `N`. -/
def digit (N D : ℕ) (j : Fin D) : TVec N := fun i => if (i : ℕ) = (j : ℕ) then 0 else ⊥

/-- A tropical (max-plus) linear combination `⨁ₖ λₖ ⊙ aₖ` of a finite family of
vectors. -/
def tropComb {N K : ℕ} (a : Fin K → TVec N) (l : Fin K → WithBot ℝ) : TVec N :=
  fun i => univ.sup fun k => l k + a k i

/-- The tropical span of the `D` digit atoms inside width `N`. -/
def InDigitSpan (N D : ℕ) (x : TVec N) : Prop :=
  ∃ l : Fin D → WithBot ℝ, x = tropComb (digit N D) l

/-- `x` uses no dimension beyond the digit block `{0,…,D-1}`. -/
def NoExclusiveDim (N D : ℕ) (x : TVec N) : Prop := ∀ i : Fin N, D ≤ (i : ℕ) → x i = ⊥

/-- `p` is a dimension owned exclusively by `x` (outside the digit block). -/
def ExclusiveDim (N D : ℕ) (x : TVec N) (p : Fin N) : Prop := D ≤ (p : ℕ) ∧ x p ≠ ⊥

/-- Auxiliary: a tropical sup of a family that is `⊥` off a single index. -/
lemma sup_ite_bot {ι : Type*} [Fintype ι] [DecidableEq ι] (a : ι) (f : ι → WithBot ℝ) :
    (univ.sup fun k => if k = a then f k else ⊥) = f a := by
  refine le_antisymm (Finset.sup_le ?_) ?_
  · intro k _
    by_cases h : k = a <;> simp [h]
  · exact le_trans (le_of_eq (by simp))
      (Finset.le_sup (f := fun k => if k = a then f k else ⊥) (mem_univ a))

/-! ## Part 1: which boundary vectors are tropically indistinguishable -/

lemma digit_apply_self {N D : ℕ} (hDN : D ≤ N) (j : Fin D) :
    digit N D j (Fin.castLE hDN j) = 0 := by
  simp [digit]

lemma digit_apply_of_ne {N D : ℕ} (j : Fin D) (i : Fin N) (h : (i : ℕ) ≠ (j : ℕ)) :
    digit N D j i = ⊥ := by
  simp [digit, h]

/-- Evaluating a tropical combination of digit atoms at a coordinate inside the
digit block returns the corresponding coefficient. -/
lemma tropComb_digit_apply_lt {N D : ℕ} (l : Fin D → WithBot ℝ) (i : Fin N)
    (hi : (i : ℕ) < D) :
    tropComb (digit N D) l i = l ⟨(i : ℕ), hi⟩ := by
  classical
  have key : ∀ k : Fin D,
      (l k + digit N D k i) = if k = (⟨(i : ℕ), hi⟩ : Fin D) then l k else ⊥ := by
    intro k
    by_cases hk : k = (⟨(i : ℕ), hi⟩ : Fin D)
    · subst hk; simp [digit]
    · have hne : (i : ℕ) ≠ (k : ℕ) := by
        intro h; exact hk (Fin.ext (by simpa using h.symm))
      simp [digit_apply_of_ne k i hne, hk]
  rw [tropComb]
  simp only [key]
  exact sup_ite_bot _ _

/-- Evaluating a tropical combination of digit atoms outside the digit block
gives the tropical zero: the digit atoms simply do not reach there. -/
lemma tropComb_digit_apply_ge {N D : ℕ} (l : Fin D → WithBot ℝ) (i : Fin N)
    (hi : D ≤ (i : ℕ)) :
    tropComb (digit N D) l i = ⊥ := by
  have hb : ∀ k : Fin D, (l k + digit N D k i) = ⊥ := by
    intro k
    have hne : (i : ℕ) ≠ (k : ℕ) := by have := k.isLt; omega
    simp [digit_apply_of_ne k i hne]
  simp [tropComb, hb]

/-- **Representational distinctness is exactly the absence of exclusive
dimensions.**  A boundary vector lies in the tropical span of the digit atoms
iff it uses no dimension outside the digit block. -/
theorem eos_mem_digitSpan_iff {N D : ℕ} (hDN : D ≤ N) (x : TVec N) :
    InDigitSpan N D x ↔ NoExclusiveDim N D x := by
  constructor
  · rintro ⟨l, rfl⟩ i hi
    exact tropComb_digit_apply_ge l i hi
  · intro hx
    refine ⟨fun j => x (Fin.castLE hDN j), ?_⟩
    funext i
    by_cases hi : (i : ℕ) < D
    · have hcast : Fin.castLE hDN (⟨(i : ℕ), hi⟩ : Fin D) = i := Fin.ext (by simp)
      rw [tropComb_digit_apply_lt _ i hi, hcast]
    · rw [tropComb_digit_apply_ge _ i (by omega), hx i (by omega)]

/-- A boundary vector with an exclusive dimension is **not** a tropical
combination of digit atoms. -/
theorem not_inDigitSpan_of_exclusiveDim {N D : ℕ} (hDN : D ≤ N) (x : TVec N)
    {p : Fin N} (hp : ExclusiveDim N D x p) : ¬ InDigitSpan N D x := by
  rw [eos_mem_digitSpan_iff hDN]
  intro h
  exact hp.2 (h p hp.1)

/-! ## Part 2: max-plus readouts cannot separate a span member -/

/-- A max-plus readout (tropical linear functional) with weights `w`. -/
def score {N : ℕ} (w x : TVec N) : WithBot ℝ := univ.sup fun i => w i + x i

lemma score_digit {N D : ℕ} (hDN : D ≤ N) (w : TVec N) (j : Fin D) :
    score w (digit N D j) = w (Fin.castLE hDN j) := by
  classical
  have key : ∀ i : Fin N,
      (w i + digit N D j i) = if i = Fin.castLE hDN j then w i else ⊥ := by
    intro i
    by_cases hi : i = Fin.castLE hDN j
    · subst hi; simp [digit]
    · have hne : (i : ℕ) ≠ (j : ℕ) := by
        intro h; exact hi (Fin.ext (by simpa using h))
      simp [digit_apply_of_ne j i hne, hi]
  rw [score]
  simp only [key]
  exact sup_ite_bot _ _

/-- **The ambiguity theorem.**  If the boundary vector has no exclusive
dimension then, for *every* readout `w`, its response is the same fixed tropical
combination of the digit responses — the readout has no channel that sees the
boundary but no digit. -/
theorem score_supported_eq_tropComb_of_digitScores {N D : ℕ} (hDN : D ≤ N)
    (x : TVec N) (hx : NoExclusiveDim N D x) (w : TVec N) :
    score w x = univ.sup fun j : Fin D => x (Fin.castLE hDN j) + score w (digit N D j) := by
  classical
  have hright : (univ.sup fun j : Fin D => x (Fin.castLE hDN j) + score w (digit N D j))
      = univ.sup fun j : Fin D => w (Fin.castLE hDN j) + x (Fin.castLE hDN j) := by
    refine Finset.sup_congr rfl ?_
    intro j _
    rw [score_digit hDN w j, add_comm]
  rw [hright, score]
  apply le_antisymm
  · refine Finset.sup_le ?_
    intro i _
    by_cases hi : (i : ℕ) < D
    · have hcast : Fin.castLE hDN (⟨(i : ℕ), hi⟩ : Fin D) = i := Fin.ext (by simp)
      calc w i + x i
          = w (Fin.castLE hDN ⟨(i : ℕ), hi⟩) + x (Fin.castLE hDN ⟨(i : ℕ), hi⟩) := by rw [hcast]
        _ ≤ _ := Finset.le_sup (f := fun j : Fin D =>
              w (Fin.castLE hDN j) + x (Fin.castLE hDN j)) (mem_univ _)
    · rw [hx i (by omega)]
      simp
  · refine Finset.sup_le ?_
    intro j _
    exact Finset.le_sup (f := fun i : Fin N => w i + x i) (mem_univ (Fin.castLE hDN j))

/-- **Bounded margin in the fragile regime.**  With no exclusive dimension the
boundary response never exceeds the best digit response by more than the
boundary's own largest coefficient: the "boundary vs digit step" margin is
uniformly bounded over all readouts. -/
theorem margin_le_of_no_exclusive_dim {N D : ℕ} (hDN : D ≤ N)
    (x : TVec N) (hx : NoExclusiveDim N D x) (w : TVec N) :
    score w x ≤ (univ.sup fun j : Fin D => x (Fin.castLE hDN j))
      + (univ.sup fun j : Fin D => score w (digit N D j)) := by
  classical
  rw [score_supported_eq_tropComb_of_digitScores hDN x hx w]
  refine Finset.sup_le ?_
  intro j _
  exact add_le_add
    (Finset.le_sup (f := fun j : Fin D => x (Fin.castLE hDN j)) (mem_univ j))
    (Finset.le_sup (f := fun j : Fin D => score w (digit N D j)) (mem_univ j))

/-! ## Part 3: an exclusive dimension buys unbounded, robust separation -/

/-- The readout that listens only to coordinate `p` with gain `g`. -/
def probe {N : ℕ} (p : Fin N) (g : ℝ) : TVec N := fun i => if i = p then (g : WithBot ℝ) else ⊥

lemma score_probe {N : ℕ} (p : Fin N) (g : ℝ) (x : TVec N) :
    score (probe p g) x = (g : WithBot ℝ) + x p := by
  classical
  have key : ∀ i : Fin N,
      (probe p g i + x i) = if i = p then (g : WithBot ℝ) + x p else ⊥ := by
    intro i
    by_cases hi : i = p <;> simp [probe, hi]
  rw [score]
  simp only [key]
  exact sup_ite_bot (f := fun _ => (g : WithBot ℝ) + x p) p

lemma score_probe_digit {N D : ℕ} {p : Fin N} (hp : D ≤ (p : ℕ))
    (g : ℝ) (j : Fin D) : score (probe p g) (digit N D j) = ⊥ := by
  rw [score_probe]
  have hne : (p : ℕ) ≠ (j : ℕ) := by have := j.isLt; omega
  rw [digit_apply_of_ne j p hne]
  simp

/-- **Unbounded margin in the robust regime.**  One exclusive dimension already
lets a readout answer with an arbitrarily large value on the boundary token
while every digit atom is mapped to the tropical zero `⊥`. -/
theorem exclusive_dim_unbounded_margin {N D : ℕ} (x : TVec N)
    {p : Fin N} (hp : ExclusiveDim N D x p) (M : ℝ) :
    ∃ w : TVec N, (M : WithBot ℝ) ≤ score w x ∧ ∀ j : Fin D, score w (digit N D j) = ⊥ := by
  obtain ⟨hpD, hxp⟩ := hp
  obtain ⟨v, hv⟩ : ∃ v : ℝ, x p = (v : WithBot ℝ) := by
    cases hxpc : x p with
    | bot => exact absurd hxpc hxp
    | coe v => exact ⟨v, rfl⟩
  refine ⟨probe p (M - v), ?_, fun j => score_probe_digit hpD _ j⟩
  rw [score_probe, hv]
  rw [show ((M - v : ℝ) : WithBot ℝ) + (v : WithBot ℝ) = ((M - v + v : ℝ) : WithBot ℝ) from rfl]
  simp

/-- **Robustness of the exclusive-dimension separation.**  If the readout gain
is perturbed by at most `r`, the boundary still scores at least `M - r` while
every digit still scores `⊥`: the separation is stable, not knife-edge. -/
theorem exclusive_dim_margin_robust {N D : ℕ} (x : TVec N)
    {p : Fin N} (hp : ExclusiveDim N D x p) (v : ℝ) (hv : x p = (v : WithBot ℝ))
    (M r e : ℝ) (he : |e| ≤ r) :
    ((M - r : ℝ) : WithBot ℝ) ≤ score (probe p ((M - v) + e)) x ∧
      ∀ j : Fin D, score (probe p ((M - v) + e)) (digit N D j) = ⊥ := by
  obtain ⟨hpD, -⟩ := hp
  refine ⟨?_, fun j => score_probe_digit hpD _ j⟩
  rw [score_probe, hv]
  rw [show (((M - v) + e : ℝ) : WithBot ℝ) + (v : WithBot ℝ) = (((M - v) + e + v : ℝ) : WithBot ℝ)
      from rfl]
  have hle : M - r ≤ (M - v) + e + v := by
    have habs := abs_le.mp he
    linarith [habs.1]
  exact WithBot.coe_le_coe.mpr hle

/-- **Width is not the control variable.**  Two boundary vectors with tropical
support of the *same* size can sit on opposite sides of the distinctness
dichotomy as soon as one of them places its mass outside the digit block: for
`D < N` there is a width-one boundary vector that is tropically
indistinguishable from a digit step and a width-one boundary vector that is
not. -/
theorem width_is_not_the_control_variable {N D : ℕ} (hD : 0 < D) (hDN : D < N) :
    ∃ x y : TVec N, InDigitSpan N D x ∧ ¬ InDigitSpan N D y := by
  refine ⟨digit N D ⟨0, hD⟩, probe ⟨D, hDN⟩ 0, ?_, ?_⟩
  · rw [eos_mem_digitSpan_iff (le_of_lt hDN)]
    intro i hi
    exact digit_apply_of_ne _ i (by omega)
  · refine not_inDigitSpan_of_exclusiveDim (le_of_lt hDN) _ (p := ⟨D, hDN⟩) ⟨by simp, ?_⟩
    simp [probe]

/-! ## Part 4: zero-padded EOS embeddings -/

/-- The zero-padded EOS embedding of width `E` inside ambient width `N`:
tropical one on the first `E` coordinates, tropical zero beyond. -/
def eosVec (N E : ℕ) : TVec N := fun i => if (i : ℕ) < E then 0 else ⊥

/-- **Width controls distinctness only through the digit block.**  A zero-padded
EOS of width `E` is a tropical combination of the digit atoms — hence invisible
to every max-plus readout as a category of its own — exactly when `E ≤ D`. -/
theorem eosVec_inDigitSpan_iff {N D E : ℕ} (hDN : D < N) :
    InDigitSpan N D (eosVec N E) ↔ E ≤ D := by
  rw [eos_mem_digitSpan_iff (le_of_lt hDN)]
  constructor
  · intro h
    by_contra hED
    have hp : D < E := by omega
    have hval := h ⟨D, hDN⟩ (by simp)
    simp only [eosVec, if_pos hp] at hval
    exact absurd hval (by simp)
  · intro hED i hi
    simp only [eosVec]
    rw [if_neg (by omega)]

end EOSWidth