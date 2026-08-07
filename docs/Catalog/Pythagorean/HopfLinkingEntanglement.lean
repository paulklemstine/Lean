/-
  # The Linking Number *Is* Entanglement

  This file closes the central conjecture left open at the end of
  `Bridges.QuantumSystems.QuantumEntanglementLinkingNumber`:

  > For a pure two-qubit state, entanglement is a topological invariant — the
  > linking number of the two Hopf circles determined by the state.

  We work with the complex Hopf fibration `S³ ⊆ ℂ² → S²`, whose fibres are the
  circles `F_u = { e^{iθ} u : θ ∈ ℝ }`.  Two distinct fibres form a Hopf link.

  **How the linking number is defined here.**  For a fibre `F_u`, the complement
  `S³ \ F_u` is an open solid torus, and the function
  `x ↦ det(u, x) = u₁x₂ - u₂x₁` vanishes on `S³` exactly on `F_u`
  (`det2_eq_zero_iff_mem_fibre`).  Hence `det(u, ·)` is a nowhere-zero complex
  function on the complement, and the linking number of a loop `γ` with `F_u` is
  the winding number of `θ ↦ det(u, γ θ)` around `0`, computed by the classical
  contour integral `(2πi)⁻¹ ∮ dz/z`.  This is the standard "generator of
  `H₁(S³ \ F_u) ≅ ℤ`" description of linking, made completely concrete.

  Main results.

  * `winding_circle` — `wind(θ ↦ c e^{i n θ}) = n` for `c ≠ 0`: the integral
    definition is genuinely ℤ-valued and detects multiplicity.
  * `linkingNumber_eq_one` — two Hopf fibres with `det(u,v) ≠ 0` have linking
    number `1`: they form a Hopf link.
  * `linkingNumber_eq_zero_of_det_zero`, `linkingNumber_eq_ite` — and linking
    number `0` exactly when the two fibres coincide.
  * `hopfFibre_disjoint`, `hopfFibre_eq_of_det_zero` — the two fibres are
    disjoint iff `det(u,v) ≠ 0`, and are the *same* circle otherwise.
  * `linkingNumber_comm` — the invariant is symmetric.
  * `entangled_iff_linked` — **the main theorem**: a two-qubit state is
    entangled (nonzero concurrence) iff the linking number of its two Hopf
    circles is `1`; it is a product state iff the linking number is `0`.
  * `linkingNumber_eq_one_iff_hopf_gap` — the topological invariant equals the
    Bloch-sphere gap of `HopfEntanglementGeometry`, closing the triangle
    algebra ↔ geometry ↔ topology.
  * `linkingNumber_torus` — the `n`-fold Hopf loop links `n` times, so every
    integer is realised: the invariant is not a Boolean in disguise.
-/
import Mathlib
import Bridges.QuantumSystems.QuantumEntanglementLinkingNumber
import Pythagorean.HopfEntanglementGeometry

open Complex

noncomputable section

namespace HopfLink

/-! ## Winding numbers by contour integration -/

/-- The winding number of a loop `f : ℝ → ℂ` (period `2π`) around the origin,
`(2πi)⁻¹ ∮ f'/f`. -/
def windingNumber (f : ℝ → ℂ) : ℂ :=
  (2 * Real.pi * Complex.I)⁻¹ * ∫ t in (0:ℝ)..(2 * Real.pi), deriv f t / f t

/-- The winding number of the constant loop at `0` is `0` (degenerate case). -/
theorem windingNumber_zero : windingNumber (fun _ : ℝ => (0:ℂ)) = 0 := by
  simp [windingNumber]

/-- **The circle loop winds `n` times.**  For `c ≠ 0`,
`wind(θ ↦ c e^{i n θ}) = n`.  This is the computation that makes the integral
definition a genuine ℤ-valued topological invariant. -/
theorem winding_circle (c : ℂ) (n : ℤ) (hc : c ≠ 0) :
    windingNumber (fun θ : ℝ => c * Complex.exp ((n : ℂ) * (θ:ℂ) * Complex.I)) = (n : ℂ) := by
  have hd : ∀ θ : ℝ, HasDerivAt (fun θ : ℝ => c * Complex.exp ((n : ℂ) * (θ:ℂ) * Complex.I))
      (c * ((n:ℂ) * Complex.I) * Complex.exp ((n : ℂ) * (θ:ℂ) * Complex.I)) θ := by
    intro θ
    have h1 : HasDerivAt (fun θ : ℝ => ((n : ℂ) * (θ:ℂ) * Complex.I)) ((n:ℂ) * Complex.I) θ := by
      have h0 : HasDerivAt (fun θ : ℝ => ((θ:ℂ))) 1 θ := Complex.ofRealCLM.hasDerivAt
      simpa [mul_comm, mul_assoc, mul_left_comm] using
        (h0.const_mul ((n:ℂ))).mul_const Complex.I
    have h2 := (h1.cexp).const_mul c
    convert h2 using 1
    ring
  have key : ∀ t : ℝ, deriv (fun θ : ℝ => c * Complex.exp ((n : ℂ) * (θ:ℂ) * Complex.I)) t
      / (c * Complex.exp ((n : ℂ) * (t:ℂ) * Complex.I)) = (n : ℂ) * Complex.I := by
    intro t
    rw [(hd t).deriv]
    have hne : c * Complex.exp ((n : ℂ) * (t:ℂ) * Complex.I) ≠ 0 :=
      mul_ne_zero hc (Complex.exp_ne_zero _)
    field_simp
  unfold windingNumber
  rw [intervalIntegral.integral_congr (g := fun _ => (n:ℂ) * Complex.I) (fun t _ => key t)]
  rw [intervalIntegral.integral_const]
  have hpi : (Real.pi : ℂ) ≠ 0 := by simp [Real.pi_ne_zero]
  rw [sub_zero, Complex.real_smul]
  push_cast
  field_simp

/-! ## Hopf fibres and their linking -/

/-- The `2 × 2` determinant of two vectors of `ℂ²`.  For `u = (α,β)`,
`v = (γ,δ)` this is precisely the entanglement determinant `αδ - βγ`. -/
def det2 (u v : ℂ × ℂ) : ℂ := u.1 * v.2 - u.2 * v.1

/-- The `n`-fold Hopf loop through `u`: `θ ↦ e^{i n θ} u`.  For `n = 1` this is
the Hopf fibre through `u`. -/
def hopfLoop (n : ℤ) (u : ℂ × ℂ) (θ : ℝ) : ℂ × ℂ :=
  (Complex.exp ((n:ℂ) * (θ:ℂ) * Complex.I) * u.1,
   Complex.exp ((n:ℂ) * (θ:ℂ) * Complex.I) * u.2)

/-- The Hopf fibre (circle) through `u`. -/
def hopfCircle (u : ℂ × ℂ) (θ : ℝ) : ℂ × ℂ := hopfLoop 1 u θ

/-- The Hopf fibre through `u`, as a subset of `ℂ²`. -/
def hopfFibre (u : ℂ × ℂ) : Set (ℂ × ℂ) := Set.range (hopfCircle u)

/-- The linking number of the `n`-fold Hopf loop through `v` with the Hopf fibre
through `u`, computed as the winding number of `θ ↦ det(u, ·)` along the loop. -/
def linkingNumberLoop (n : ℤ) (u v : ℂ × ℂ) : ℂ :=
  windingNumber (fun θ => det2 u (hopfLoop n v θ))

/-- The linking number of the two Hopf fibres through `u` and `v`. -/
def linkingNumber (u v : ℂ × ℂ) : ℂ := linkingNumberLoop 1 u v

lemma det2_hopfLoop (n : ℤ) (u v : ℂ × ℂ) (θ : ℝ) :
    det2 u (hopfLoop n v θ) = det2 u v * Complex.exp ((n:ℂ) * (θ:ℂ) * Complex.I) := by
  simp only [det2, hopfLoop]; ring

lemma det2_swap (u v : ℂ × ℂ) : det2 v u = - det2 u v := by simp [det2]; ring

lemma det2_self (u : ℂ × ℂ) : det2 u u = 0 := by simp [det2]; ring

/-- The Hopf circle is a one-parameter group action: rotating twice adds angles. -/
lemma hopfCircle_add (u : ℂ × ℂ) (a b : ℝ) :
    hopfCircle (hopfCircle u a) b = hopfCircle u (b + a) := by
  have key : Complex.exp (((1:ℤ):ℂ) * (b:ℂ) * Complex.I)
      * Complex.exp (((1:ℤ):ℂ) * (a:ℂ) * Complex.I)
      = Complex.exp (((1:ℤ):ℂ) * ((b + a : ℝ):ℂ) * Complex.I) := by
    rw [← Complex.exp_add]; congr 1; push_cast; ring
  simp only [hopfCircle, hopfLoop, Prod.mk.injEq]
  constructor <;> · rw [← mul_assoc, key]

/-- On the sphere the function `det(u, ·)` vanishes exactly on the fibre `F_u`:
this is what makes it a legitimate "linking coordinate".  (Stated for `u ≠ 0`,
with `x` of the same length as `u`.) -/
theorem det2_eq_zero_iff_mem_fibre (u x : ℂ × ℂ) (hu : u ≠ (0,0))
    (hx : Complex.normSq x.1 + Complex.normSq x.2 = Complex.normSq u.1 + Complex.normSq u.2) :
    det2 u x = 0 ↔ x ∈ hopfFibre u := by
  constructor
  · intro h
    -- `det = 0` gives `x = c • u`; the length condition forces `|c| = 1`.
    obtain ⟨c, hc1, hc2⟩ : ∃ c : ℂ, x.1 = c * u.1 ∧ x.2 = c * u.2 := by
      by_cases h1 : u.1 = 0
      · have h2 : u.2 ≠ 0 := by
          intro h2; exact hu (Prod.ext h1 h2)
        have hx1 : x.1 = 0 := by
          have hz : u.2 * x.1 = 0 := by
            simp only [det2, h1] at h; linear_combination -h
          rcases mul_eq_zero.1 hz with h' | h'
          · exact absurd h' h2
          · exact h'
        exact ⟨x.2 / u.2, by simp [hx1, h1], by field_simp⟩
      · refine ⟨x.1 / u.1, by field_simp, ?_⟩
        have hxx : u.1 * x.2 = u.2 * x.1 := by
          simp only [det2] at h; linear_combination h
        field_simp
        linear_combination hxx
    have hcabs : Complex.normSq c = 1 := by
      have hnu : Complex.normSq u.1 + Complex.normSq u.2 ≠ 0 := by
        intro h0
        have h1 : Complex.normSq u.1 = 0 :=
          le_antisymm (by nlinarith [Complex.normSq_nonneg u.2]) (Complex.normSq_nonneg _)
        have h2 : Complex.normSq u.2 = 0 :=
          le_antisymm (by nlinarith [Complex.normSq_nonneg u.1]) (Complex.normSq_nonneg _)
        exact hu (Prod.ext (Complex.normSq_eq_zero.1 h1) (Complex.normSq_eq_zero.1 h2))
      rw [hc1, hc2] at hx
      simp only [Complex.normSq_mul] at hx
      have hfac : (Complex.normSq c - 1) * (Complex.normSq u.1 + Complex.normSq u.2) = 0 := by
        ring_nf; ring_nf at hx; linarith
      rcases mul_eq_zero.1 hfac with h' | h'
      · linarith
      · exact absurd h' hnu
    have hc0 : c ≠ 0 := by
      intro h0; rw [h0] at hcabs; simp at hcabs
    have hpolar : c = Complex.exp ((Complex.arg c : ℂ) * Complex.I) := by
      have habs : ‖c‖ = 1 := by
        have h2 : ‖c‖ ^ 2 = 1 := by
          rw [← Complex.normSq_eq_norm_sq]; exact hcabs
        nlinarith [norm_nonneg c]
      have hpa := Complex.norm_mul_exp_arg_mul_I c
      rw [habs] at hpa
      simpa using hpa.symm
    refine ⟨Complex.arg c, ?_⟩
    have hcast : ((1:ℤ):ℂ) * ((Complex.arg c : ℝ):ℂ) * Complex.I
        = (Complex.arg c : ℂ) * Complex.I := by
      push_cast; ring
    simp only [hopfCircle, hopfLoop, hcast]
    rw [← hpolar]
    exact Prod.ext hc1.symm hc2.symm
  · rintro ⟨θ, rfl⟩
    simp only [hopfCircle, hopfLoop, det2]
    ring

/-- **Distinct fibres are disjoint.**  If `det(u,v) ≠ 0` the two Hopf circles
never meet — a prerequisite for talking about their linking number. -/
theorem hopfFibre_disjoint (u v : ℂ × ℂ) (h : det2 u v ≠ 0) (θ φ : ℝ) :
    hopfCircle u θ ≠ hopfCircle v φ := by
  intro heq
  have hzero : det2 (hopfCircle u θ) (hopfCircle v φ) = 0 := by
    rw [heq]; exact det2_self _
  have hval : det2 (hopfCircle u θ) (hopfCircle v φ)
      = det2 u v * Complex.exp (((1:ℤ):ℂ) * (θ:ℂ) * Complex.I)
        * Complex.exp (((1:ℤ):ℂ) * (φ:ℂ) * Complex.I) := by
    simp only [hopfCircle, hopfLoop, det2]; ring
  rw [hval] at hzero
  exact h (by
    rcases mul_eq_zero.1 hzero with h' | h'
    · rcases mul_eq_zero.1 h' with h'' | h''
      · exact h''
      · exact absurd h'' (Complex.exp_ne_zero _)
    · exact absurd h' (Complex.exp_ne_zero _))

/-- **Vanishing determinant means one and the same circle.**  If `det(u,v) = 0`
and `u`, `v` have the same (nonzero) length, the two Hopf fibres coincide. -/
theorem hopfFibre_eq_of_det_zero (u v : ℂ × ℂ) (hu : u ≠ (0,0)) (hv : v ≠ (0,0))
    (hlen : Complex.normSq v.1 + Complex.normSq v.2
      = Complex.normSq u.1 + Complex.normSq u.2)
    (h : det2 u v = 0) : hopfFibre u = hopfFibre v := by
  have hv_mem : v ∈ hopfFibre u := (det2_eq_zero_iff_mem_fibre u v hu hlen).1 h
  have hu_mem : u ∈ hopfFibre v :=
    (det2_eq_zero_iff_mem_fibre v u hv hlen.symm).1 (by rw [det2_swap, h]; ring)
  obtain ⟨θ₀, hθ₀⟩ := hv_mem
  apply Set.eq_of_subset_of_subset
  · rintro _ ⟨θ, rfl⟩
    refine ⟨θ - θ₀, ?_⟩
    have hv' : hopfCircle v (θ - θ₀) = hopfCircle (hopfCircle u θ₀) (θ - θ₀) := by rw [hθ₀]
    rw [hv', hopfCircle_add]
    congr 1
    ring
  · rintro _ ⟨θ, rfl⟩
    refine ⟨θ + θ₀, ?_⟩
    have hv' : hopfCircle v θ = hopfCircle (hopfCircle u θ₀) θ := by rw [hθ₀]
    rw [hv', hopfCircle_add]

/-! ## The linking number of two Hopf fibres -/

/-- **The Hopf link.**  Two Hopf fibres with `det(u,v) ≠ 0` have linking number
`1`.  More generally the `n`-fold Hopf loop links `n` times. -/
theorem linkingNumberLoop_eq (n : ℤ) (u v : ℂ × ℂ) (h : det2 u v ≠ 0) :
    linkingNumberLoop n u v = (n : ℂ) := by
  have hfun : (fun θ : ℝ => det2 u (hopfLoop n v θ))
      = fun θ : ℝ => det2 u v * Complex.exp ((n : ℂ) * (θ:ℂ) * Complex.I) := by
    funext θ; exact det2_hopfLoop n u v θ
  rw [linkingNumberLoop, hfun, winding_circle _ n h]

/-- The `n`-fold Hopf loops realise every integer linking number: the invariant
is genuinely ℤ-valued (these are the `(n,n)` torus links). -/
theorem linkingNumber_torus (n : ℤ) (u v : ℂ × ℂ) (h : det2 u v ≠ 0) :
    linkingNumberLoop n u v = (n : ℂ) := linkingNumberLoop_eq n u v h

/-- Two distinct Hopf fibres are a Hopf link: linking number `1`. -/
theorem linkingNumber_eq_one (u v : ℂ × ℂ) (h : det2 u v ≠ 0) :
    linkingNumber u v = 1 := by
  have := linkingNumberLoop_eq 1 u v h
  simpa using this

/-- If the determinant vanishes the fibres coincide and the linking number
degenerates to `0`. -/
theorem linkingNumber_eq_zero_of_det_zero (u v : ℂ × ℂ) (h : det2 u v = 0) :
    linkingNumber u v = 0 := by
  have hfun : (fun θ : ℝ => det2 u (hopfLoop 1 v θ)) = fun _ : ℝ => (0:ℂ) := by
    funext θ; rw [det2_hopfLoop, h, zero_mul]
  simp [linkingNumber, linkingNumberLoop, hfun, windingNumber_zero]

/-- The complete dichotomy: `lk(F_u, F_v) = 1` if the fibres are distinct and
`0` if they coincide. -/
theorem linkingNumber_eq_ite (u v : ℂ × ℂ) :
    linkingNumber u v = if det2 u v = 0 then 0 else 1 := by
  by_cases h : det2 u v = 0
  · simp [h, linkingNumber_eq_zero_of_det_zero u v h]
  · simp [h, linkingNumber_eq_one u v h]

/-- Linking number is symmetric, as a linking number must be. -/
theorem linkingNumber_comm (u v : ℂ × ℂ) : linkingNumber u v = linkingNumber v u := by
  rw [linkingNumber_eq_ite, linkingNumber_eq_ite, det2_swap]
  simp [neg_eq_zero]

/-! ## Torus links: the invariant beyond the Hopf case -/

/-- The `(m,n)` torus loop on the Clifford torus through `u`:
`θ ↦ (e^{imθ}u₁, e^{inθ}u₂)`.  For `m = n = 1` it is a Hopf fibre. -/
def torusLoop (m n : ℤ) (u : ℂ × ℂ) (θ : ℝ) : ℂ × ℂ :=
  (Complex.exp ((m:ℂ) * (θ:ℂ) * Complex.I) * u.1,
   Complex.exp ((n:ℂ) * (θ:ℂ) * Complex.I) * u.2)

/-- **The `(m,n)` torus loop links the first core circle `n` times.**  The core
circle is the Hopf fibre through `(1,0)`. -/
theorem torusLoop_linking_first (m n : ℤ) (u : ℂ × ℂ) (hu : u.2 ≠ 0) :
    windingNumber (fun θ => det2 (1, 0) (torusLoop m n u θ)) = (n : ℂ) := by
  have hfun : (fun θ : ℝ => det2 (1, 0) (torusLoop m n u θ))
      = fun θ : ℝ => u.2 * Complex.exp ((n : ℂ) * (θ:ℂ) * Complex.I) := by
    funext θ; simp only [det2, torusLoop]; ring
  rw [hfun, winding_circle _ n hu]

/-- **The `(m,n)` torus loop links the second core circle `m` times.**  Hence the
winding-number invariant realises the full bidegree of a torus link, and the
Hopf link is exactly the case `m = n = 1`. -/
theorem torusLoop_linking_second (m n : ℤ) (u : ℂ × ℂ) (hu : u.1 ≠ 0) :
    windingNumber (fun θ => det2 (0, 1) (torusLoop m n u θ)) = (m : ℂ) := by
  have hne : -u.1 ≠ 0 := neg_ne_zero.2 hu
  have hfun : (fun θ : ℝ => det2 (0, 1) (torusLoop m n u θ))
      = fun θ : ℝ => (-u.1) * Complex.exp ((m : ℂ) * (θ:ℂ) * Complex.I) := by
    funext θ; simp only [det2, torusLoop]; ring
  rw [hfun, winding_circle _ m hne]

/-! ## Entanglement is the linking number -/

open TwoQubitState HopfEntanglement

/-- The first Hopf circle determined by a two-qubit state: the fibre through
`(α, β)`. -/
def leftVec (ψ : TwoQubitState) : ℂ × ℂ := (ψ.α, ψ.β)

/-- The second Hopf circle determined by a two-qubit state: the fibre through
`(γ, δ)`. -/
def rightVec (ψ : TwoQubitState) : ℂ × ℂ := (ψ.γ, ψ.δ)

/-- The linking number of the two Hopf circles of a two-qubit state. -/
def stateLinkingNumber (ψ : TwoQubitState) : ℂ := linkingNumber (leftVec ψ) (rightVec ψ)

/-- The linking coordinate of the two halves of a state *is* the entanglement
determinant of the previous cycle. -/
theorem det2_left_right (ψ : TwoQubitState) :
    det2 (leftVec ψ) (rightVec ψ) = ψ.entanglementDet := rfl

/-- **Main theorem — the linking number is entanglement.**
A two-qubit state has nonzero concurrence iff its two Hopf circles are linked
with linking number `1`. -/
theorem entangled_iff_linked (ψ : TwoQubitState) :
    ψ.concurrence ≠ 0 ↔ stateLinkingNumber ψ = 1 := by
  have hdet : det2 (leftVec ψ) (rightVec ψ) = ψ.entanglementDet := det2_left_right ψ
  constructor
  · intro hC
    have hd : ψ.entanglementDet ≠ 0 := by
      intro h0; apply hC; simp [TwoQubitState.concurrence, h0]
    exact linkingNumber_eq_one _ _ (by rw [hdet]; exact hd)
  · intro hlk hC
    have hd : ψ.entanglementDet = 0 := by
      have : ‖ψ.entanglementDet‖ = 0 := by
        simp only [TwoQubitState.concurrence] at hC; linarith
      simpa using this
    have : stateLinkingNumber ψ = 0 :=
      linkingNumber_eq_zero_of_det_zero _ _ (by rw [hdet]; exact hd)
    rw [this] at hlk
    exact zero_ne_one hlk

/-- **Product states are unlinked.**  A state is a product state iff the linking
number of its two Hopf circles is `0`. -/
theorem isProduct_iff_unlinked (ψ : TwoQubitState) :
    ψ.IsProduct ↔ stateLinkingNumber ψ = 0 := by
  rw [TwoQubitState.entangled_iff_det_nonzero]
  have hdet : det2 (leftVec ψ) (rightVec ψ) = ψ.entanglementDet := det2_left_right ψ
  constructor
  · intro h
    exact linkingNumber_eq_zero_of_det_zero _ _ (by rw [hdet]; exact h)
  · intro h
    by_contra hd
    have : stateLinkingNumber ψ = 1 :=
      linkingNumber_eq_one _ _ (by rw [hdet]; exact hd)
    rw [this] at h
    exact one_ne_zero h

/-- The linking number takes only the two values `0` and `1`, and it is `1`
exactly on entangled states. -/
theorem stateLinkingNumber_eq_ite (ψ : TwoQubitState) :
    stateLinkingNumber ψ = if ψ.concurrence = 0 then 0 else 1 := by
  by_cases h : ψ.concurrence = 0
  · simp only [h, if_true]
    exact (isProduct_iff_unlinked ψ).1 ((TwoQubitState.entangled_iff_det_nonzero ψ).2
      (by
        have : ‖ψ.entanglementDet‖ = 0 := by
          simp only [TwoQubitState.concurrence] at h; linarith
        simpa using this))
  · simp only [h, if_false]
    exact (entangled_iff_linked ψ).1 h

/-! ## Closing the triangle: topology = geometry = algebra -/

/-- **Topology equals Bloch geometry.**  The two Hopf circles are linked exactly
when the two Hopf base points on the Bloch sphere fail to coincide, i.e. exactly
when the Cauchy–Schwarz gap `pq - ⟨h(u),h(v)⟩` of `HopfEntanglementGeometry` is
strictly positive.  Together with `entangled_iff_linked` this closes the triangle
algebra (determinant) ↔ geometry (Bloch distance) ↔ topology (linking number). -/
theorem linkingNumber_eq_one_iff_hopf_gap (ψ : TwoQubitState) :
    stateLinkingNumber ψ = 1 ↔
      0 < leftWt ψ * rightWt ψ - dot3 (leftHopf ψ) (rightHopf ψ) := by
  rw [← entangled_iff_linked]
  have hgap := concurrence_sq_eq_hopf_gap ψ
  have hnn := TwoQubitState.concurrence_nonneg ψ
  constructor
  · intro hC
    have : 0 < ψ.concurrence := lt_of_le_of_ne hnn (Ne.symm hC)
    nlinarith [hgap, this]
  · intro hpos hC
    rw [hC] at hgap
    simp at hgap
    linarith

/-- Quantitative form: the concurrence is recovered from the Bloch gap, and the
link is nontrivial precisely when the concurrence is positive. -/
theorem concurrence_pos_iff_linked (ψ : TwoQubitState) :
    0 < ψ.concurrence ↔ stateLinkingNumber ψ = 1 := by
  rw [← entangled_iff_linked]
  constructor
  · intro h; exact ne_of_gt h
  · intro h; exact lt_of_le_of_ne (TwoQubitState.concurrence_nonneg ψ) (Ne.symm h)

end HopfLink