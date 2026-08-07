/-
  # Cycle 3: Three Qubits, Cayley's Hyperdeterminant, and Borromean Rings

  The two-qubit story is now complete: entanglement = nonvanishing of a
  determinant = a Hopf link (`Pythagorean.HopfLinkingEntanglement`), invariant
  under local unitaries (`Pythagorean.EntanglementInvariance`).

  The topological picture predicts something sharp for **three** qubits.  A
  three-component link can be *Brunnian*: pairwise unlinked, yet globally
  inseparable — the Borromean rings.  Quantum mechanically that is exactly the
  GHZ state: every two-party reduced state is a classical mixture of product
  states, yet the triple carries maximal genuine tripartite entanglement.
  This file proves both halves of that statement, and identifies the invariant
  detecting the Brunnian phenomenon: **Cayley's `2 × 2 × 2` hyperdeterminant**,
  whose modulus (times 4) is the 3-tangle.

  Main results.

  * `hyperdet_act1`, `hyperdet_act2`, `hyperdet_act3` — the hyperdeterminant is
    a relative invariant of `SL(2) × SL(2) × SL(2)`: acting on any one qubit by
    `A` multiplies it by `(det A)²`.  (Classical invariant theory, verified as a
    polynomial identity in 12 variables.)
  * `threeTangle_sl2_invariant` — hence the 3-tangle is a genuine entanglement
    monotone-style invariant of local special-linear operations.
  * `hyperdet_eq_zero_of_productA` — the hyperdeterminant vanishes on states
    that factor across the first cut; so a nonzero 3-tangle certifies *genuine*
    tripartite entanglement.
  * `threeTangle_ghz` — `τ(GHZ) = 1`, and `threeTangle_w` — `τ(W) = 0`.
  * `w_entangled_across_cutA` — yet `W` is entangled across every cut: the
    3-tangle is strictly finer than bipartite entanglement.
  * `ghz_rhoAB_separable` — the two-party reduced state of GHZ is a classical
    mixture `½|00⟩⟨00| + ½|11⟩⟨11|` of product states, i.e. **pairwise
    unlinked**.
  * `ghz_borromean` — the two facts together: GHZ is the Borromean ring of
    quantum information.
-/
import Mathlib
import Pythagorean.HopfEntanglementGeometry
import Pythagorean.HopfLinkingEntanglement

open Complex

noncomputable section

namespace ThreeTangle

/-- A pure state of three qubits, as its array of amplitudes `a_{ijk}`. -/
abbrev ThreeQubit := Fin 2 → Fin 2 → Fin 2 → ℂ

/-- **Cayley's `2 × 2 × 2` hyperdeterminant** of a three-qubit amplitude array. -/
def hyperdet (ψ : ThreeQubit) : ℂ :=
  (ψ 0 0 0)^2 * (ψ 1 1 1)^2 + (ψ 0 0 1)^2 * (ψ 1 1 0)^2
    + (ψ 0 1 0)^2 * (ψ 1 0 1)^2 + (ψ 0 1 1)^2 * (ψ 1 0 0)^2
  - 2 * (ψ 0 0 0 * ψ 0 0 1 * ψ 1 1 0 * ψ 1 1 1
        + ψ 0 0 0 * ψ 0 1 0 * ψ 1 0 1 * ψ 1 1 1
        + ψ 0 0 0 * ψ 1 0 0 * ψ 0 1 1 * ψ 1 1 1
        + ψ 0 0 1 * ψ 0 1 0 * ψ 1 0 1 * ψ 1 1 0
        + ψ 0 0 1 * ψ 1 0 0 * ψ 0 1 1 * ψ 1 1 0
        + ψ 0 1 0 * ψ 1 0 0 * ψ 0 1 1 * ψ 1 0 1)
  + 4 * (ψ 0 0 0 * ψ 0 1 1 * ψ 1 0 1 * ψ 1 1 0
        + ψ 0 0 1 * ψ 0 1 0 * ψ 1 0 0 * ψ 1 1 1)

/-- The 3-tangle `τ = 4 |Det ψ|`, the standard measure of genuine tripartite
entanglement. -/
def threeTangle (ψ : ThreeQubit) : ℝ := 4 * ‖hyperdet ψ‖

/-! ## Local `SL(2)` covariance -/

/-- Act by the matrix `A` on the first qubit. -/
def act1 (A : Matrix (Fin 2) (Fin 2) ℂ) (ψ : ThreeQubit) : ThreeQubit :=
  fun i j k => ∑ l, A i l * ψ l j k

/-- Act by the matrix `A` on the second qubit. -/
def act2 (A : Matrix (Fin 2) (Fin 2) ℂ) (ψ : ThreeQubit) : ThreeQubit :=
  fun i j k => ∑ l, A j l * ψ i l k

/-- Act by the matrix `A` on the third qubit. -/
def act3 (A : Matrix (Fin 2) (Fin 2) ℂ) (ψ : ThreeQubit) : ThreeQubit :=
  fun i j k => ∑ l, A k l * ψ i j l

/-- **Relative invariance, first factor**: `Det(A₁ψ) = (det A)² Det(ψ)`. -/
theorem hyperdet_act1 (A : Matrix (Fin 2) (Fin 2) ℂ) (ψ : ThreeQubit) :
    hyperdet (act1 A ψ) = A.det ^ 2 * hyperdet ψ := by
  simp only [hyperdet, act1, Fin.sum_univ_two, Matrix.det_fin_two]
  ring

/-- **Relative invariance, second factor.** -/
theorem hyperdet_act2 (A : Matrix (Fin 2) (Fin 2) ℂ) (ψ : ThreeQubit) :
    hyperdet (act2 A ψ) = A.det ^ 2 * hyperdet ψ := by
  simp only [hyperdet, act2, Fin.sum_univ_two, Matrix.det_fin_two]
  ring

/-- **Relative invariance, third factor.** -/
theorem hyperdet_act3 (A : Matrix (Fin 2) (Fin 2) ℂ) (ψ : ThreeQubit) :
    hyperdet (act3 A ψ) = A.det ^ 2 * hyperdet ψ := by
  simp only [hyperdet, act3, Fin.sum_univ_two, Matrix.det_fin_two]
  ring

/-- The 3-tangle is invariant under `SL(2)` acting on any single qubit. -/
theorem threeTangle_sl2_invariant (A : Matrix (Fin 2) (Fin 2) ℂ) (hA : A.det = 1)
    (ψ : ThreeQubit) :
    threeTangle (act1 A ψ) = threeTangle ψ ∧ threeTangle (act2 A ψ) = threeTangle ψ ∧
      threeTangle (act3 A ψ) = threeTangle ψ := by
  refine ⟨?_, ?_, ?_⟩ <;>
    simp [threeTangle, hyperdet_act1, hyperdet_act2, hyperdet_act3, hA]

/-- More precisely, an arbitrary invertible local operation rescales the tangle
by `|det A|²`. -/
theorem threeTangle_act1_scaling (A : Matrix (Fin 2) (Fin 2) ℂ) (ψ : ThreeQubit) :
    threeTangle (act1 A ψ) = ‖A.det‖ ^ 2 * threeTangle ψ := by
  simp [threeTangle, hyperdet_act1, norm_pow]
  ring

/-! ## Genuine tripartite entanglement -/

/-- States that factor across the first cut, `a_{ijk} = b_i m_{jk}`. -/
def IsProductA (ψ : ThreeQubit) : Prop :=
  ∃ (b : Fin 2 → ℂ) (m : Fin 2 → Fin 2 → ℂ), ∀ i j k, ψ i j k = b i * m j k

/-- **The hyperdeterminant certifies genuine tripartite entanglement**: it
vanishes on every state that factors across the first cut. -/
theorem hyperdet_eq_zero_of_productA (ψ : ThreeQubit) (h : IsProductA ψ) :
    hyperdet ψ = 0 := by
  obtain ⟨b, m, hb⟩ := h
  simp only [hyperdet, hb]
  ring

/-- Entanglement across the `A | BC` cut: some `2 × 2` minor of the `2 × 4`
coefficient matrix is nonzero. -/
def EntangledAcrossCutA (ψ : ThreeQubit) : Prop :=
  ∃ j k j' k', ψ 0 j k * ψ 1 j' k' - ψ 0 j' k' * ψ 1 j k ≠ 0

/-- A state that factors across the first cut is unentangled across that cut. -/
theorem not_entangled_of_productA (ψ : ThreeQubit) (h : IsProductA ψ) :
    ¬ EntangledAcrossCutA ψ := by
  obtain ⟨b, m, hb⟩ := h
  rintro ⟨j, k, j', k', hne⟩
  apply hne
  simp only [hb]
  ring

/-! ## The GHZ and W states -/

/-- `1/√2`, as a complex number. -/
def invSqrt2 : ℂ := ((Real.sqrt 2)⁻¹ : ℝ)

lemma invSqrt2_sq : invSqrt2 * invSqrt2 = (1/2 : ℂ) := by
  have h2 : Real.sqrt 2 * Real.sqrt 2 = 2 := Real.mul_self_sqrt (by norm_num)
  have hne : Real.sqrt 2 ≠ 0 := by positivity
  have : ((Real.sqrt 2)⁻¹ * (Real.sqrt 2)⁻¹ : ℝ) = 1/2 := by
    field_simp
    linarith [h2]
  simp only [invSqrt2, ← Complex.ofReal_mul, this]
  norm_num

lemma invSqrt2_conj : (starRingEnd ℂ) invSqrt2 = invSqrt2 := by
  simp [invSqrt2, Complex.conj_ofReal]

/-- The GHZ state `(|000⟩ + |111⟩)/√2`. -/
def ghz : ThreeQubit := fun i j k =>
  if i = 0 ∧ j = 0 ∧ k = 0 then invSqrt2 else if i = 1 ∧ j = 1 ∧ k = 1 then invSqrt2 else 0

/-- `1/√3`, as a complex number. -/
def invSqrt3 : ℂ := ((Real.sqrt 3)⁻¹ : ℝ)

lemma invSqrt3_ne_zero : invSqrt3 ≠ 0 := by
  have h : Real.sqrt 3 ≠ 0 := by positivity
  simp only [invSqrt3, ne_eq, Complex.ofReal_eq_zero, inv_eq_zero]
  exact h

/-- The W state `(|001⟩ + |010⟩ + |100⟩)/√3`. -/
def wState : ThreeQubit := fun i j k =>
  if (i, j, k) = (0, 0, 1) ∨ (i, j, k) = (0, 1, 0) ∨ (i, j, k) = (1, 0, 0) then invSqrt3 else 0

/-- **`τ(GHZ) = 1`**: the GHZ state has maximal genuine tripartite entanglement. -/
theorem threeTangle_ghz : threeTangle ghz = 1 := by
  have hd : hyperdet ghz = (1/4 : ℂ) := by
    simp only [hyperdet, ghz]
    norm_num
    linear_combination (invSqrt2 * invSqrt2 + 1/2) * invSqrt2_sq
  simp [threeTangle, hd]

/-- **`τ(W) = 0`**: the W state carries no GHZ-type tripartite entanglement. -/
theorem threeTangle_w : threeTangle wState = 0 := by
  have hd : hyperdet wState = 0 := by
    simp only [hyperdet, wState]
    norm_num
  simp [threeTangle, hd]

/-- **But `W` is entangled across the `A|BC` cut.**  Hence a vanishing 3-tangle
does not mean separability: the hyperdeterminant sees only the GHZ-type sector. -/
theorem w_entangled_across_cutA : EntangledAcrossCutA wState := by
  refine ⟨0, 1, 0, 0, ?_⟩
  simp only [wState]
  norm_num
  exact invSqrt3_ne_zero

/-- `W` therefore does not factor across the first cut. -/
theorem w_not_productA : ¬ IsProductA wState :=
  fun h => not_entangled_of_productA wState h w_entangled_across_cutA

/-! ## Borromean rings: the two-party reduced state of GHZ -/

/-- The two-party reduced density matrix `ρ_AB = Tr_C |ψ⟩⟨ψ|`. -/
def rhoAB (ψ : ThreeQubit) : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) ℂ :=
  fun p q => ∑ k, ψ p.1 p.2 k * (starRingEnd ℂ) (ψ q.1 q.2 k)

/-- Separability of a two-qubit (unnormalised) density matrix: a nonnegative
mixture of product pure states. -/
def IsSeparable (R : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) ℂ) : Prop :=
  ∃ (n : ℕ) (w : Fin n → ℝ) (x y : Fin n → Fin 2 → ℂ), (∀ i, 0 ≤ w i) ∧
    ∀ p q, R p q =
      ∑ i, (w i : ℂ) * (x i p.1 * y i p.2) * (starRingEnd ℂ) (x i q.1 * y i q.2)

/-- **Remove one ring and the other two fall apart.**  The two-party reduced
state of GHZ is the classical mixture `½|00⟩⟨00| + ½|11⟩⟨11|`: a separable
state.  Any two of the three qubits are unentangled — pairwise unlinked. -/
theorem ghz_rhoAB_separable : IsSeparable (rhoAB ghz) := by
  refine ⟨2, ![1/2, 1/2], ![![1,0], ![0,1]], ![![1,0], ![0,1]], ?_, ?_⟩
  · intro i; fin_cases i <;> norm_num
  · intro p q
    obtain ⟨p1, p2⟩ := p
    obtain ⟨q1, q2⟩ := q
    fin_cases p1 <;> fin_cases p2 <;> fin_cases q1 <;> fin_cases q2 <;>
      simp [rhoAB, ghz, Fin.sum_univ_two, invSqrt2_conj, invSqrt2_sq]

/-! ## The Peres criterion, and the contrast with W -/

/-- Partial transpose on the second (B) tensor factor. -/
def partialTransposeB (R : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) ℂ) :
    Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) ℂ :=
  fun p q => R (p.1, q.2) (q.1, p.2)

/-- The quadratic form `⟨v, R v⟩`. -/
def expectation (R : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) ℂ) (v : Fin 2 × Fin 2 → ℂ) : ℂ :=
  ∑ p, ∑ q, (starRingEnd ℂ) (v p) * R p q * v q

/-- **Peres criterion (the easy direction, proved from scratch).**  If a state is
separable then its partial transpose is positive semidefinite.  A negative
expectation value therefore certifies entanglement. -/
theorem separable_partialTransposeB_nonneg (R : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) ℂ)
    (h : IsSeparable R) (v : Fin 2 × Fin 2 → ℂ) :
    0 ≤ (expectation (partialTransposeB R) v).re := by
  obtain ⟨n, w, x, y, hw, hR⟩ := h
  set A : Fin n → (Fin 2 × Fin 2) → ℂ :=
    fun i p => (starRingEnd ℂ) (v p) * (x i p.1) * (starRingEnd ℂ) (y i p.2) with hA
  set B : Fin n → (Fin 2 × Fin 2) → ℂ :=
    fun i q => (v q) * (y i q.2) * (starRingEnd ℂ) (x i q.1) with hB
  set F : Fin n → (Fin 2 × Fin 2) → (Fin 2 × Fin 2) → ℂ :=
    fun i p q => (w i : ℂ) * A i p * B i q with hF
  have step1 : expectation (partialTransposeB R) v
      = ∑ p : Fin 2 × Fin 2, ∑ q : Fin 2 × Fin 2, ∑ i, F i p q := by
    simp only [expectation, partialTransposeB, hR, Finset.mul_sum, Finset.sum_mul, hF, hA, hB,
      map_mul]
    exact Finset.sum_congr rfl fun p _ => Finset.sum_congr rfl fun q _ =>
      Finset.sum_congr rfl fun i _ => by ring
  have step2 : ∀ p : Fin 2 × Fin 2, ∑ q : Fin 2 × Fin 2, ∑ i, F i p q
      = ∑ i, ∑ q : Fin 2 × Fin 2, F i p q := fun p => Finset.sum_comm
  have step3 : expectation (partialTransposeB R) v
      = ∑ i, ∑ p : Fin 2 × Fin 2, ∑ q : Fin 2 × Fin 2, F i p q := by
    rw [step1]; simp_rw [step2]; exact Finset.sum_comm
  have step4 : ∀ i, ∑ p : Fin 2 × Fin 2, ∑ q : Fin 2 × Fin 2, F i p q
      = (w i : ℂ) * ((∑ p : Fin 2 × Fin 2, A i p) * (∑ q : Fin 2 × Fin 2, B i q)) := by
    intro i
    have e1 : ∀ p : Fin 2 × Fin 2, ∑ q : Fin 2 × Fin 2, F i p q
        = ((w i : ℂ) * A i p) * (∑ q : Fin 2 × Fin 2, B i q) := by
      intro p; rw [hF]; simp only []; rw [Finset.mul_sum]
    rw [Finset.sum_congr rfl (fun p _ => e1 p), ← Finset.sum_mul, ← Finset.mul_sum, mul_assoc]
  have hBconj : ∀ i, (∑ q : Fin 2 × Fin 2, B i q)
      = (starRingEnd ℂ) (∑ p : Fin 2 × Fin 2, A i p) := by
    intro i
    rw [map_sum]
    exact Finset.sum_congr rfl fun p _ => by simp [hA, hB]; ring
  have key : expectation (partialTransposeB R) v
      = ∑ i, (w i : ℂ) * ((∑ p : Fin 2 × Fin 2, A i p)
          * (starRingEnd ℂ) (∑ p : Fin 2 × Fin 2, A i p)) := by
    rw [step3]
    exact Finset.sum_congr rfl fun i _ => by rw [step4 i, hBconj i]
  rw [key]
  have hre : (∑ i, (w i : ℂ) * ((∑ p : Fin 2 × Fin 2, A i p)
        * (starRingEnd ℂ) (∑ p : Fin 2 × Fin 2, A i p))).re
      = ∑ i, w i * Complex.normSq (∑ p : Fin 2 × Fin 2, A i p) := by
    rw [Complex.re_sum]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [Complex.mul_conj]
    simp
  rw [hre]
  exact Finset.sum_nonneg fun i _ => mul_nonneg (hw i) (Complex.normSq_nonneg _)

lemma invSqrt3_sq : invSqrt3 * invSqrt3 = (1/3 : ℂ) := by
  have h3 : Real.sqrt 3 * Real.sqrt 3 = 3 := Real.mul_self_sqrt (by norm_num)
  have hne : Real.sqrt 3 ≠ 0 := by positivity
  have h : ((Real.sqrt 3)⁻¹ * (Real.sqrt 3)⁻¹ : ℝ) = 1/3 := by
    field_simp
    linarith [h3]
  simp only [invSqrt3, ← Complex.ofReal_mul, h]
  norm_num

lemma invSqrt3_conj : (starRingEnd ℂ) invSqrt3 = invSqrt3 := by
  simp [invSqrt3, Complex.conj_ofReal]

/-- The singlet-like test vector `|00⟩ - |11⟩`. -/
def testVec : Fin 2 × Fin 2 → ℂ := fun p => if p = (0,0) then 1 else if p = (1,1) then -1 else 0

/-- The partial transpose of the two-party reduced state of `W` has a strictly
negative expectation value on `|00⟩ - |11⟩`. -/
theorem w_partialTranspose_negative :
    (expectation (partialTransposeB (rhoAB wState)) testVec).re = -(1/3) := by
  simp [expectation, partialTransposeB, rhoAB, wState, testVec, Fintype.sum_prod_type,
    Fin.sum_univ_two, invSqrt3_conj, invSqrt3_sq]

/-- **The two-party reduced state of `W` is entangled.**  In sharp contrast with
GHZ: removing one qubit from `W` leaves the other two linked. -/
theorem w_rhoAB_not_separable : ¬ IsSeparable (rhoAB wState) := by
  intro h
  have hnn := separable_partialTransposeB_nonneg (rhoAB wState) h testVec
  rw [w_partialTranspose_negative] at hnn
  norm_num at hnn

/-- **The Borromean theorem for GHZ.**  Maximal genuine tripartite entanglement
(`τ = 1`) coexists with complete pairwise separability of the reduced state:
the quantum analogue of the Borromean rings, where every two-component sublink
is trivial while the three-component link is not. -/
theorem ghz_borromean : threeTangle ghz = 1 ∧ IsSeparable (rhoAB ghz) :=
  ⟨threeTangle_ghz, ghz_rhoAB_separable⟩

/-- **GHZ versus W: Brunnian versus chained.**  GHZ has maximal 3-tangle and
separable (unlinked) pairs — Borromean rings.  W has zero 3-tangle yet
entangled (linked) pairs — a chain.  The two invariants are therefore logically
independent, and neither alone classifies tripartite entanglement. -/
theorem ghz_vs_w_dichotomy :
    (threeTangle ghz = 1 ∧ IsSeparable (rhoAB ghz)) ∧
      (threeTangle wState = 0 ∧ ¬ IsSeparable (rhoAB wState)) :=
  ⟨ghz_borromean, threeTangle_w, w_rhoAB_not_separable⟩

end ThreeTangle