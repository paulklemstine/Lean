import Novelty.DiophantineLatticeCharacteristic

/-!
# Cycle 5: lattice reduction — the spectral gap is a `GL_n(ℤ)`-invariant

All the invariants of the previous cycles (`IsMinEnergy`, `IsInhomMin`, hence the spectral gap
`λ₁/r²` and the covering radius) were defined through a *coordinate* description of the lattice
`ℤⁿ` together with a Gram matrix `B`.  Lattice reduction changes the basis by a unimodular
matrix `U`, which replaces `B` by the congruent matrix `Uᵀ B U`.  This file proves that nothing
in the theory depends on that choice:

* `form_congr` : `Q_{UᵀBU}(x) = Q_B(U x)` for arbitrary matrices — the congruence identity;
* `isMinEnergy_congr` : the minimal lattice energy is unchanged by a unimodular change of
  basis;
* `isInhomMin_congr` : the spectral gap at a shift `t` equals the spectral gap of the
  congruent form at `U t`;
* `covering_ge_quarter_min_congr` : consequently the packing–covering inequality is a statement
  about the lattice, not about a chosen basis.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the `λ₁/r²` gap should be an isometry invariant of the lattice; if
it were not, the whole programme would be an artefact of coordinates.
Experiment (Experimenter): the congruence identity reduces to a four-fold sum interchange
(`sum4_comm`); the lattice transfer then needs only that `m ↦ U m` is a bijection of `ℤⁿ`,
which follows from `V U = 1` and `U V = 1` — no positivity, no reduction theory.
Analysis (Analyst): the two hypotheses `U V = 1` and `V U = 1` are exactly unimodularity;
the transfer of `IsInhomMin` moves the shift as `t ↦ U t`, so half-lattice points are carried to
half-lattice points, i.e. the cycle-1 and cycle-4 theorems are basis-independent as well.
Critique (Critic): the invariance is stated as an `iff`, so both directions are proved; the
congruence lemma holds for *arbitrary* `U` (not just unimodular), isolating exactly where
unimodularity is needed.
Synthesis (PI): every spectral quantity in this project is a `GL_n(ℤ)`-invariant of the pair
(lattice, quadratic form), which is what makes "lattice reduction" a legitimate tool for
computing it.
-/

namespace DiophantineLattice

open Finset Matrix

variable {n : ℕ}

/-- A four-fold interchange of summation. -/
lemma sum4_comm (f : Fin n → Fin n → Fin n → Fin n → ℚ) :
    ∑ k, ∑ l, ∑ i, ∑ j, f i j k l = ∑ i, ∑ j, ∑ k, ∑ l, f i j k l := by
  calc ∑ k, ∑ l, ∑ i, ∑ j, f i j k l = ∑ k, ∑ i, ∑ l, ∑ j, f i j k l :=
        sum_congr rfl fun k _ => Finset.sum_comm
    _ = ∑ i, ∑ k, ∑ l, ∑ j, f i j k l := Finset.sum_comm
    _ = ∑ i, ∑ k, ∑ j, ∑ l, f i j k l :=
        sum_congr rfl fun i _ => sum_congr rfl fun k _ => Finset.sum_comm
    _ = ∑ i, ∑ j, ∑ k, ∑ l, f i j k l :=
        sum_congr rfl fun i _ => Finset.sum_comm

lemma mulVec_apply' (M : Matrix (Fin n) (Fin n) ℚ) (v : Fin n → ℚ) (i : Fin n) :
    (M *ᵥ v) i = ∑ j, M i j * v j := by
  simp [Matrix.mulVec, dotProduct]

lemma conj_apply (B U : Matrix (Fin n) (Fin n) ℚ) (k l : Fin n) :
    (Uᵀ * B * U) k l = ∑ i, ∑ j, U i k * B i j * U j l := by
  simp only [Matrix.mul_apply, Matrix.transpose_apply, Finset.sum_mul]
  rw [Finset.sum_comm]

/-- **Congruence identity.**  Changing coordinates by `U` replaces the Gram matrix `B` by
`Uᵀ B U`. -/
theorem form_congr (B U : Matrix (Fin n) (Fin n) ℚ) (x : Fin n → ℚ) :
    form (Uᵀ * B * U) x = form B (U *ᵥ x) := by
  have hL : form (Uᵀ * B * U) x
      = ∑ k, ∑ l, ∑ i, ∑ j, U i k * B i j * U j l * x k * x l := by
    simp only [form, bil, conj_apply, Finset.sum_mul]
  have hR : form B (U *ᵥ x)
      = ∑ i, ∑ j, ∑ k, ∑ l, U i k * B i j * U j l * x k * x l := by
    have hstep : ∀ (a : ℚ) (f g : Fin n → ℚ),
        a * (∑ k, f k) * (∑ l, g l) = ∑ k, ∑ l, a * f k * g l := by
      intro a f g
      rw [mul_assoc, Finset.sum_mul_sum, Finset.mul_sum]
      exact sum_congr rfl fun k _ => by
        rw [Finset.mul_sum]; exact sum_congr rfl fun l _ => by ring
    simp only [form, bil]
    refine sum_congr rfl fun i _ => sum_congr rfl fun j _ => ?_
    rw [mulVec_apply', mulVec_apply', hstep]
    exact sum_congr rfl fun k _ => sum_congr rfl fun l _ => by ring
  rw [hL, hR, sum4_comm]

/-! ## Unimodular transfer -/

variable {U V : Matrix (Fin n) (Fin n) ℤ}

lemma emb_mulVec (U : Matrix (Fin n) (Fin n) ℤ) (m : Fin n → ℤ) :
    emb (U *ᵥ m) = (toRat U) *ᵥ (emb m) := by
  funext i
  rw [mulVec_apply']
  simp only [emb_apply, Matrix.mulVec, dotProduct, toRat, Matrix.map_apply]
  push_cast
  rfl

lemma mulVec_eq_zero_iff (hVU : V * U = 1) (m : Fin n → ℤ) : U *ᵥ m = 0 ↔ m = 0 := by
  constructor
  · intro h
    have : V *ᵥ (U *ᵥ m) = 0 := by rw [h]; simp
    rwa [Matrix.mulVec_mulVec, hVU, Matrix.one_mulVec] at this
  · intro h; rw [h]; simp

/-- The minimal lattice energy is invariant under a unimodular change of basis. -/
theorem isMinEnergy_congr (hUV : U * V = 1) (hVU : V * U = 1)
    (B : Matrix (Fin n) (Fin n) ℚ) (lam : ℚ) :
    IsMinEnergy ((toRat U)ᵀ * B * (toRat U)) lam ↔ IsMinEnergy B lam := by
  have key : ∀ m : Fin n → ℤ,
      form ((toRat U)ᵀ * B * (toRat U)) (emb m) = form B (emb (U *ᵥ m)) := by
    intro m
    rw [form_congr, emb_mulVec]
  constructor
  · rintro ⟨⟨w, hw, hwlam⟩, hmin⟩
    refine ⟨⟨U *ᵥ w, ?_, ?_⟩, ?_⟩
    · rw [Ne, mulVec_eq_zero_iff hVU]; exact hw
    · rw [← key w]; exact hwlam
    · intro m hm
      have hm' : V *ᵥ m ≠ 0 := by rw [Ne, mulVec_eq_zero_iff hUV]; exact hm
      have := hmin (V *ᵥ m) hm'
      rw [key (V *ᵥ m), Matrix.mulVec_mulVec, hUV, Matrix.one_mulVec] at this
      exact this
  · rintro ⟨⟨w, hw, hwlam⟩, hmin⟩
    refine ⟨⟨V *ᵥ w, ?_, ?_⟩, ?_⟩
    · rw [Ne, mulVec_eq_zero_iff hUV]; exact hw
    · rw [key (V *ᵥ w), Matrix.mulVec_mulVec, hUV, Matrix.one_mulVec]; exact hwlam
    · intro m hm
      rw [key m]
      exact hmin (U *ᵥ m) (by rw [Ne, mulVec_eq_zero_iff hVU]; exact hm)

/-- The spectral gap is invariant under a unimodular change of basis: the gap of the congruent
form at `t` is the gap of the original form at `U t`. -/
theorem isInhomMin_congr (hUV : U * V = 1)
    (B : Matrix (Fin n) (Fin n) ℚ) (t : Fin n → ℚ) (mu : ℚ) :
    IsInhomMin ((toRat U)ᵀ * B * (toRat U)) t mu ↔ IsInhomMin B ((toRat U) *ᵥ t) mu := by
  have key : ∀ m : Fin n → ℤ,
      form ((toRat U)ᵀ * B * (toRat U)) (fun i => t i - emb m i)
        = form B (fun i => ((toRat U) *ᵥ t) i - emb (U *ᵥ m) i) := by
    intro m
    have hsub : (fun i => t i - emb m i) = t - emb m := rfl
    rw [hsub, form_congr, Matrix.mulVec_sub, emb_mulVec]
    rfl
  constructor
  · rintro ⟨⟨m0, hm0⟩, hlow⟩
    refine ⟨⟨U *ᵥ m0, ?_⟩, ?_⟩
    · rw [← key m0]; exact hm0
    · intro m
      have := hlow (V *ᵥ m)
      rwa [key (V *ᵥ m), Matrix.mulVec_mulVec, hUV, Matrix.one_mulVec] at this
  · rintro ⟨⟨m0, hm0⟩, hlow⟩
    refine ⟨⟨V *ᵥ m0, ?_⟩, ?_⟩
    · rw [key (V *ᵥ m0), Matrix.mulVec_mulVec, hUV, Matrix.one_mulVec]; exact hm0
    · intro m
      rw [key m]
      exact hlow (U *ᵥ m)

/-- Positive definiteness is also a congruence invariant (for unimodular, indeed for any
invertible, change of basis). -/
theorem posDef_congr (hUV : U * V = 1) (hVU : V * U = 1) (B : Matrix (Fin n) (Fin n) ℚ) :
    PosDef ((toRat U)ᵀ * B * (toRat U)) ↔ PosDef B := by
  have hmul : ∀ M N : Matrix (Fin n) (Fin n) ℤ, toRat (M * N) = toRat M * toRat N := by
    intro M N
    funext i j
    simp only [toRat, Matrix.map_apply, Matrix.mul_apply]
    push_cast
    rfl
  have hone : toRat (1 : Matrix (Fin n) (Fin n) ℤ) = 1 := by
    funext i j
    rcases eq_or_ne i j with h | h
    · simp [toRat, Matrix.one_apply, h]
    · simp [toRat, h]
  have hUVq : (toRat U) * (toRat V) = 1 := by rw [← hmul, hUV, hone]
  have hVUq : (toRat V) * (toRat U) = 1 := by rw [← hmul, hVU, hone]
  constructor
  · intro hpd x hx
    have hx' : (toRat V) *ᵥ x ≠ 0 := by
      intro hcon
      apply hx
      have : (toRat U) *ᵥ ((toRat V) *ᵥ x) = 0 := by rw [hcon]; simp
      rwa [Matrix.mulVec_mulVec, hUVq, Matrix.one_mulVec] at this
    have := hpd _ hx'
    rwa [form_congr, Matrix.mulVec_mulVec, hUVq, Matrix.one_mulVec] at this
  · intro hpd x hx
    rw [form_congr]
    refine hpd _ ?_
    intro hcon
    apply hx
    have : (toRat V) *ᵥ ((toRat U) *ᵥ x) = 0 := by rw [hcon]; simp
    rwa [Matrix.mulVec_mulVec, hVUq, Matrix.one_mulVec] at this

/-- **Basis independence of the packing–covering inequality.**  Stated for the reduced basis,
it holds for the original one. -/
theorem covering_ge_quarter_min_congr (hUV : U * V = 1) (hVU : V * U = 1)
    {B : Matrix (Fin n) (Fin n) ℚ} (hpd : PosDef B) {lam : ℚ}
    (h : IsMinEnergy ((toRat U)ᵀ * B * (toRat U)) lam) {mu : ℚ}
    (hcov : ∀ t : Fin n → ℚ, ∃ m : Fin n → ℤ, form B (fun i => t i - emb m i) ≤ mu) :
    lam / 4 ≤ mu :=
  covering_ge_quarter_min hpd ((isMinEnergy_congr hUV hVU B lam).1 h) hcov

end DiophantineLattice