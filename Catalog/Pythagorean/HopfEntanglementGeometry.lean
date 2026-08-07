/-
  # Hopf Geometry of Two-Qubit Entanglement

  Deepening of `Bridges.QuantumSystems.QuantumEntanglementLinkingNumber`.

  The previous cycle established the *algebraic* side of the entanglement story:
  the entanglement determinant `αδ - βγ`, the concurrence `C = 2‖αδ - βγ‖`, and
  the equivalence `IsProduct ↔ entanglementDet = 0`.

  This file supplies the missing *geometric* half: the Hopf fibration
  `S³ → S²` written concretely as the map `h(z,w) = (2 Re(z w̄), 2 Im(z w̄), |z|² - |w|²)`,
  and the exact dictionary between entanglement and Hopf geometry.

  Main results.

  * `hopfVec_normSq` — `‖h(z,w)‖² = (|z|² + |w|²)²`: the Hopf map really lands on
    the sphere of radius `|z|²+|w|²`.  (A Pythagorean identity in disguise.)
  * `pythagorean_quadruple_of_gaussian` — the integral shadow of the previous
    identity: every pair of Gaussian integers produces a Pythagorean quadruple
    `x² + y² + z² = n²`.  This is the bridge to the Pythagorean catalogue.
  * `hopf_dot_identity` — **the key identity**
      `‖u‖²‖v‖² - ⟨h(u), h(v)⟩ = 2 |αδ - βγ|²`,
    where `u = (α,β)`, `v = (γ,δ)` are the two "halves" of the two-qubit state.
    Entanglement is exactly the failure of the two Hopf base points to coincide.
  * `concurrence_sq_eq_hopf_gap`, `concurrence_sq_eq_bloch_dist` —
    `C(ψ)² = 2(pq - ⟨h(u),h(v)⟩) = p q ‖n_u - n_v‖²`, i.e. the concurrence is the
    geometric mean of the two sub-norms times the Euclidean distance between the
    two Hopf/Bloch base points (Mosseri–Dandoloff dictionary).
  * `concurrence_le_one_hopf` — a *geometric* reproof of `C ≤ 1` from
    Cauchy–Schwarz on the Bloch sphere, and
  * `maximally_entangled_iff_antipodal` — `C(ψ) = 1` iff the two Hopf base points
    are antipodal and the two halves have equal norm.
-/
import Mathlib
import Bridges.QuantumSystems.QuantumEntanglementLinkingNumber

open Complex

noncomputable section

namespace HopfEntanglement

/-! ## The Hopf map, concretely -/

/-- Euclidean 3-space, modelled as an iterated product so that all identities are
plain polynomial identities in the coordinates. -/
abbrev R3 := ℝ × ℝ × ℝ

/-- Euclidean inner product on `R3`. -/
def dot3 (a b : R3) : ℝ := a.1 * b.1 + a.2.1 * b.2.1 + a.2.2 * b.2.2

/-- Squared Euclidean length on `R3`. -/
def sq3 (a : R3) : ℝ := dot3 a a

/-- Euclidean distance squared on `R3`. -/
def dist3sq (a b : R3) : ℝ := sq3 (a.1 - b.1, a.2.1 - b.2.1, a.2.2 - b.2.2)

/-- The Hopf map `ℂ² → ℝ³`, `h(z,w) = (2 Re(z w̄), 2 Im(z w̄), |z|² - |w|²)`.
Restricted to the unit sphere `S³ ⊆ ℂ²` this is the Hopf fibration `S³ → S²`. -/
def hopfVec (z w : ℂ) : R3 :=
  (2 * (z * (starRingEnd ℂ) w).re, 2 * (z * (starRingEnd ℂ) w).im,
    Complex.normSq z - Complex.normSq w)

/-- The "weight" `|z|² + |w|²` of a pair; the Hopf image lies on the sphere of this radius. -/
def wt (z w : ℂ) : ℝ := Complex.normSq z + Complex.normSq w

lemma dot3_comm (a b : R3) : dot3 a b = dot3 b a := by
  simp [dot3]; ring

/-- **Hopf sphere identity**: `‖h(z,w)‖² = (|z|² + |w|²)²`. -/
theorem hopfVec_normSq (z w : ℂ) : sq3 (hopfVec z w) = (wt z w) ^ 2 := by
  simp only [sq3, dot3, hopfVec, wt, Complex.normSq_apply, Complex.mul_re, Complex.mul_im,
    Complex.conj_re, Complex.conj_im]
  ring

/-- Integral shadow of `hopfVec_normSq`: every pair of Gaussian integers
`(m + n i, p + q i)` yields a **Pythagorean quadruple**
`(2(mp+nq))² + (2(np-mq))² + (m²+n²-p²-q²)² = (m²+n²+p²+q²)²`.
This is the arithmetic core of the Hopf fibration, and the link with the
Pythagorean catalogue: the Hopf map is a quadruple-generating machine. -/
theorem pythagorean_quadruple_of_gaussian (m n p q : ℤ) :
    (2 * (m * p + n * q)) ^ 2 + (2 * (n * p - m * q)) ^ 2
      + (m ^ 2 + n ^ 2 - p ^ 2 - q ^ 2) ^ 2
      = (m ^ 2 + n ^ 2 + p ^ 2 + q ^ 2) ^ 2 := by
  ring

/-! ## The key identity -/

/-- **Hopf–entanglement identity.**  For `u = (α,β)` and `v = (γ,δ)`,
`‖u‖²‖v‖² - ⟨h(u), h(v)⟩ = 2 |αδ - βγ|²`.

The left side is a purely geometric quantity — it vanishes exactly when the two
Hopf base points on the Bloch sphere coincide — while the right side is the
entanglement determinant of the previous cycle.  Geometry = algebra. -/
theorem hopf_dot_identity (a b c d : ℂ) :
    wt a b * wt c d - dot3 (hopfVec a b) (hopfVec c d)
      = 2 * Complex.normSq (a * d - b * c) := by
  simp only [dot3, hopfVec, wt, Complex.normSq_apply, Complex.mul_re, Complex.mul_im,
    Complex.conj_re, Complex.conj_im, Complex.sub_re, Complex.sub_im]
  ring

/-- Reformulation: the Hopf inner product is `pq - 2|det|²`. -/
theorem dot3_hopf_eq (a b c d : ℂ) :
    dot3 (hopfVec a b) (hopfVec c d)
      = wt a b * wt c d - 2 * Complex.normSq (a * d - b * c) := by
  have := hopf_dot_identity a b c d; linarith

/-! ## Dictionary with the catalogue's concurrence -/

open TwoQubitState

/-- The first half `(α, β)` of a two-qubit state, as a Hopf vector. -/
def leftHopf (ψ : TwoQubitState) : R3 := hopfVec ψ.α ψ.β

/-- The second half `(γ, δ)` of a two-qubit state, as a Hopf vector. -/
def rightHopf (ψ : TwoQubitState) : R3 := hopfVec ψ.γ ψ.δ

/-- Norm of the first half. -/
def leftWt (ψ : TwoQubitState) : ℝ := wt ψ.α ψ.β

/-- Norm of the second half. -/
def rightWt (ψ : TwoQubitState) : ℝ := wt ψ.γ ψ.δ

lemma leftWt_add_rightWt (ψ : TwoQubitState) : leftWt ψ + rightWt ψ = ψ.normSq := by
  simp [leftWt, rightWt, wt, TwoQubitState.normSq]; ring

lemma leftWt_nonneg (ψ : TwoQubitState) : 0 ≤ leftWt ψ :=
  add_nonneg (Complex.normSq_nonneg _) (Complex.normSq_nonneg _)

lemma rightWt_nonneg (ψ : TwoQubitState) : 0 ≤ rightWt ψ :=
  add_nonneg (Complex.normSq_nonneg _) (Complex.normSq_nonneg _)

/-- **Concurrence as a Hopf gap.** `C(ψ)² = 2 (p q - ⟨h(u), h(v)⟩)`. -/
theorem concurrence_sq_eq_hopf_gap (ψ : TwoQubitState) :
    ψ.concurrence ^ 2 = 2 * (leftWt ψ * rightWt ψ - dot3 (leftHopf ψ) (rightHopf ψ)) := by
  have h := hopf_dot_identity ψ.α ψ.β ψ.γ ψ.δ
  have hn : Complex.normSq ψ.entanglementDet = ‖ψ.entanglementDet‖ ^ 2 :=
    Complex.normSq_eq_norm_sq _
  simp only [leftWt, rightWt, leftHopf, rightHopf]
  rw [h]
  simp only [TwoQubitState.concurrence, TwoQubitState.entanglementDet] at *
  rw [hn]; ring

/-- Polarisation: `‖a - b‖² = ‖a‖² - 2⟨a,b⟩ + ‖b‖²`. -/
lemma dist3sq_expand (a b : R3) : dist3sq a b = sq3 a - 2 * dot3 a b + sq3 b := by
  simp only [dist3sq, sq3, dot3]; ring

/-- Lagrange identity in `ℝ³`, giving Cauchy–Schwarz. -/
lemma dot3_sq_le (a b : R3) : (dot3 a b) ^ 2 ≤ sq3 a * sq3 b := by
  simp only [dot3, sq3]
  nlinarith [sq_nonneg (a.1 * b.2.1 - a.2.1 * b.1), sq_nonneg (a.1 * b.2.2 - a.2.2 * b.1),
    sq_nonneg (a.2.1 * b.2.2 - a.2.2 * b.2.1)]

/-- The squared distance between the two (unnormalised) Hopf vectors. -/
theorem dist3sq_hopf (ψ : TwoQubitState) :
    dist3sq (leftHopf ψ) (rightHopf ψ)
      = (leftWt ψ - rightWt ψ) ^ 2 + ψ.concurrence ^ 2 := by
  have hL : sq3 (leftHopf ψ) = leftWt ψ ^ 2 := hopfVec_normSq _ _
  have hR : sq3 (rightHopf ψ) = rightWt ψ ^ 2 := hopfVec_normSq _ _
  have hD : dot3 (leftHopf ψ) (rightHopf ψ)
      = leftWt ψ * rightWt ψ - ψ.concurrence ^ 2 / 2 := by
    have := concurrence_sq_eq_hopf_gap ψ; linarith
  rw [dist3sq_expand, hL, hR, hD]; ring

/-- **Concurrence is a Bloch-sphere distance.**  If both halves are nonzero, then
with `n_u = h(u)/p` and `n_v = h(v)/q` the *unit* Hopf base points,
`C(ψ)² = p q ‖n_u - n_v‖²`.

Thus the concurrence is literally the (weighted) distance between the two points
of the Bloch sphere `S²` that the state determines. -/
theorem concurrence_sq_eq_bloch_dist (ψ : TwoQubitState)
    (hp : leftWt ψ ≠ 0) (hq : rightWt ψ ≠ 0) :
    ψ.concurrence ^ 2 =
      leftWt ψ * rightWt ψ *
        dist3sq ((leftWt ψ)⁻¹ • leftHopf ψ) ((rightWt ψ)⁻¹ • rightHopf ψ) := by
  have hL : sq3 (leftHopf ψ) = leftWt ψ ^ 2 := hopfVec_normSq _ _
  have hR : sq3 (rightHopf ψ) = rightWt ψ ^ 2 := hopfVec_normSq _ _
  have hD : dot3 (leftHopf ψ) (rightHopf ψ)
      = leftWt ψ * rightWt ψ - ψ.concurrence ^ 2 / 2 := by
    have := concurrence_sq_eq_hopf_gap ψ; linarith
  have hsm : dist3sq ((leftWt ψ)⁻¹ • leftHopf ψ) ((rightWt ψ)⁻¹ • rightHopf ψ)
      = (leftWt ψ)⁻¹ ^ 2 * sq3 (leftHopf ψ)
        - 2 * ((leftWt ψ)⁻¹ * (rightWt ψ)⁻¹) * dot3 (leftHopf ψ) (rightHopf ψ)
        + (rightWt ψ)⁻¹ ^ 2 * sq3 (rightHopf ψ) := by
    simp only [dist3sq, sq3, dot3, Prod.smul_fst, Prod.smul_snd, smul_eq_mul]; ring
  rw [hsm, hL, hR, hD]
  field_simp
  ring

/-! ## Geometric bounds on entanglement -/

/-- Cauchy–Schwarz on the Bloch sphere: `⟨h(u), h(v)⟩ ≥ -pq`. -/
theorem dot3_hopf_ge (ψ : TwoQubitState) :
    - (leftWt ψ * rightWt ψ) ≤ dot3 (leftHopf ψ) (rightHopf ψ) := by
  have hL : sq3 (leftHopf ψ) = leftWt ψ ^ 2 := hopfVec_normSq _ _
  have hR : sq3 (rightHopf ψ) = rightWt ψ ^ 2 := hopfVec_normSq _ _
  have hcs := dot3_sq_le (leftHopf ψ) (rightHopf ψ)
  rw [hL, hR] at hcs
  have hpq : 0 ≤ leftWt ψ * rightWt ψ := mul_nonneg (leftWt_nonneg ψ) (rightWt_nonneg ψ)
  nlinarith [hcs, hpq]

/-- `C(ψ)² ≤ 4 p q`: entanglement is bounded by the geometry of the two halves. -/
theorem concurrence_sq_le_four_mul (ψ : TwoQubitState) :
    ψ.concurrence ^ 2 ≤ 4 * (leftWt ψ * rightWt ψ) := by
  have h := concurrence_sq_eq_hopf_gap ψ
  have h2 := dot3_hopf_ge ψ
  linarith

/-- **Geometric reproof of the concurrence bound.**  For a normalised state,
`C(ψ) ≤ 1`, obtained from Bloch-sphere Cauchy–Schwarz together with AM–GM
`4pq ≤ (p+q)² = 1` — a genuinely different route from the analytic proof in the
previous cycle. -/
theorem concurrence_le_one_hopf (ψ : TwoQubitState) (h : ψ.IsNormalized) :
    ψ.concurrence ≤ 1 := by
  have hsum : leftWt ψ + rightWt ψ = 1 := by
    rw [leftWt_add_rightWt]; exact h
  have hle := concurrence_sq_le_four_mul ψ
  have hamgm : 4 * (leftWt ψ * rightWt ψ) ≤ 1 := by
    nlinarith [sq_nonneg (leftWt ψ - rightWt ψ)]
  have hsq : ψ.concurrence ^ 2 ≤ 1 := le_trans hle hamgm
  nlinarith [TwoQubitState.concurrence_nonneg ψ]

/-- **Maximal entanglement is antipodality.**  A normalised state has
`C(ψ) = 1` iff its two halves have equal norm `1/2` and their Hopf base points
are antipodal on the Bloch sphere (`⟨h(u), h(v)⟩ = -pq`). -/
theorem maximally_entangled_iff_antipodal (ψ : TwoQubitState) (h : ψ.IsNormalized) :
    ψ.concurrence = 1 ↔
      (leftWt ψ = 1 / 2 ∧ rightWt ψ = 1 / 2 ∧
        dot3 (leftHopf ψ) (rightHopf ψ) = -(leftWt ψ * rightWt ψ)) := by
  have hsum : leftWt ψ + rightWt ψ = 1 := by rw [leftWt_add_rightWt]; exact h
  have hgap := concurrence_sq_eq_hopf_gap ψ
  have hge := dot3_hopf_ge ψ
  constructor
  · intro hC
    rw [hC] at hgap
    have hpq : 4 * (leftWt ψ * rightWt ψ) ≥ 1 := by linarith
    have hp : leftWt ψ = 1 / 2 := by nlinarith [sq_nonneg (leftWt ψ - rightWt ψ)]
    have hq : rightWt ψ = 1 / 2 := by linarith
    refine ⟨hp, hq, by rw [hp, hq] at hgap ⊢; linarith⟩
  · rintro ⟨hp, hq, hdot⟩
    rw [hp, hq] at hgap
    rw [hp, hq] at hdot
    rw [hdot] at hgap
    have h1 : ψ.concurrence ^ 2 = 1 := by linarith
    nlinarith [TwoQubitState.concurrence_nonneg ψ]

/-- Unentangled ⇔ the two Hopf base points coincide (as unnormalised vectors,
`⟨h(u),h(v)⟩ = pq`, i.e. equality in Cauchy–Schwarz with the same direction). -/
theorem isProduct_iff_hopf_aligned (ψ : TwoQubitState) :
    ψ.IsProduct ↔ dot3 (leftHopf ψ) (rightHopf ψ) = leftWt ψ * rightWt ψ := by
  rw [TwoQubitState.entangled_iff_det_nonzero]
  have h := hopf_dot_identity ψ.α ψ.β ψ.γ ψ.δ
  simp only [leftHopf, rightHopf, leftWt, rightWt]
  constructor
  · intro hd
    have : Complex.normSq ψ.entanglementDet = 0 := by
      rw [hd]; simp
    simp only [TwoQubitState.entanglementDet] at this
    linarith
  · intro hd
    have hz : Complex.normSq (ψ.α * ψ.δ - ψ.β * ψ.γ) = 0 := by linarith
    have := (Complex.normSq_eq_zero).1 hz
    simpa [TwoQubitState.entanglementDet] using this

end HopfEntanglement