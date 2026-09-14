import MachineLearning.BerggrenHolyConstruction

/-!
# Holy-construction rigidity on the Pythagorean null cone

Fifth and final file of the *Moonshine from the null cone* cycle.  It closes the ternary
case of the open conjecture `D4` of `FUTURE_DIRECTIONS.md`.

`MachineLearning.BerggrenHolyConstruction` computed Conway's holy construction
`ρ^⊥ / ℤρ` at the root node `(3,4,5)` of the Berggren tree and transported the answer to
every node by the Berggren isometries.  The answer was always the rank-one lattice `⟨1⟩`
(`A₁ = ⟨2⟩` after the even rescaling), never the rootless Leech lattice.

Here that computation is made **unconditional**: it holds at *every* primitive isotropic
vector of `ℤ^{2,1}`, whether or not it belongs to the Berggren tree, and the proof no
longer uses the tree at all.  The mechanism is a Lorentzian cross product

  `lorCross ρ σ = (b r − c q, c p − a r, b p − a q)`   (`ρ = (a,b,c)`, `σ = (p,q,r)`),

whose defining properties are the two orthogonality identities `bil_lorCross_left`,
`bil_lorCross_right` and the Lagrange-type norm identity
`qform_lorCross : qform (lorCross ρ σ) = bil ρ σ ^ 2 − qform ρ * qform σ`.

If `ρ` is isotropic and primitive, unimodularity of `ℤ^{2,1}` produces `σ` with
`bil ρ σ = 1` (`exists_pairing_one`), and then `τ = lorCross ρ σ` automatically has
`qform τ = 1` — a **root** of the even rescaling.  The determinant of the frame
`{ρ, τ, σ}` is `−1` (`frame_det`), which is what makes `{ρ, τ}` a basis of `ρ^⊥` over `ℤ`
(`perp_triple_eq_zero`, `primitive_isotropic_perp_basis`).

## Main results

* `qform_lorCross` — the Lagrange identity for the Lorentzian cross product.
* `exists_pairing_one` — a primitive vector pairs to `1` with some lattice vector.
* `perp_triple_eq_zero` — a vector orthogonal to the whole frame `{ρ, τ, σ}` is `0`.
* `primitive_isotropic_holy_construction` — **the rigidity theorem**: for every primitive
  isotropic `ρ` there is a `τ` with `bil τ ρ = 0`, `qform τ = 1`, `τ ∉ ℤρ`, and every
  `v ⊥ ρ` is `x • ρ + y • τ` with `qform v = y ^ 2`.  So `ρ^⊥/ℤρ ≅ ⟨1⟩` always: the holy
  construction on the Pythagorean null cone is **never** rootless, hence never Leech-like
  — rootlessness is a strictly *even* phenomenon.
* `perp_coords_unique` — the coordinates in that basis are unique.
* `applyGens_isPrimitive`, `node_isotropic_primitive_holy` — the Berggren tree nodes are
  primitive, so they are a special case: this recovers `node_holy_construction` with no
  transport argument.
-/

namespace BerggrenStars

/-! ### Bilinear algebra of the Lorentz form

`bil_comm`, `bil_add_left`, `bil_add_right` are already in the catalog
(`BerggrenHyperbolicStars`, `BerggrenEvenLatticeEmbedding`); here are the missing
scalar and subtraction rules. -/

theorem bil_smul_left (k : ℤ) (v w : Vec) : bil (k • v) w = k * bil v w := by
  obtain ⟨a, b, c⟩ := v; obtain ⟨p, q, r⟩ := w
  simp only [bil, Prod.smul_mk, smul_eq_mul]; ring

theorem bil_smul_right (k : ℤ) (v w : Vec) : bil v (k • w) = k * bil v w := by
  rw [bil_comm, bil_smul_left, bil_comm]

theorem bil_sub_left (v w z : Vec) : bil (v - w) z = bil v z - bil w z := by
  obtain ⟨a, b, c⟩ := v; obtain ⟨p, q, r⟩ := w; obtain ⟨x, y, t⟩ := z
  simp only [bil, Prod.mk_sub_mk]; ring

/-- On the plane spanned by an isotropic `ρ` and a vector `τ` orthogonal to it, the
quadratic form only sees the `τ`-coordinate. -/
theorem qform_combo (ρ τ : Vec) (hρ : qform ρ = 0) (hτ : bil τ ρ = 0) (x y : ℤ) :
    qform (x • ρ + y • τ) = y ^ 2 * qform τ := by
  obtain ⟨a, b, c⟩ := ρ; obtain ⟨d, e, f⟩ := τ
  simp only [qform, bil, Prod.smul_mk, smul_eq_mul, Prod.mk_add_mk] at hρ hτ ⊢
  linear_combination (x ^ 2) * hρ + (2 * x * y) * hτ

/-! ### The Lorentzian cross product -/

/-- The Lorentzian cross product: the Euclidean cross product of `v` and `w` followed by
the sign flip of the timelike coordinate.  It is orthogonal to both arguments **for the
Lorentz form** `x² + y² − z²`. -/
def lorCross (v w : Vec) : Vec :=
  (v.2.1 * w.2.2 - v.2.2 * w.2.1, v.2.2 * w.1 - v.1 * w.2.2, v.2.1 * w.1 - v.1 * w.2.1)

theorem bil_lorCross_left (v w : Vec) : bil (lorCross v w) v = 0 := by
  obtain ⟨a, b, c⟩ := v; obtain ⟨p, q, r⟩ := w
  simp only [lorCross, bil]; ring

theorem bil_lorCross_right (v w : Vec) : bil (lorCross v w) w = 0 := by
  obtain ⟨a, b, c⟩ := v; obtain ⟨p, q, r⟩ := w
  simp only [lorCross, bil]; ring

/-- **Lagrange identity for the Lorentzian cross product.**  The norm of `lorCross v w` is
the negative of the Gram determinant of `(v, w)`. -/
theorem qform_lorCross (v w : Vec) :
    qform (lorCross v w) = bil v w ^ 2 - qform v * qform w := by
  obtain ⟨a, b, c⟩ := v; obtain ⟨p, q, r⟩ := w
  simp only [lorCross, qform, bil]; ring

/-- The determinant of the frame `{v, lorCross v w, w}`, written out in coordinates,
equals `−(bil v w ^ 2 − qform v * qform w)`; so it is `−1` exactly when the Lagrange
quantity is `1`.  This is what makes the frame unimodular. -/
theorem frame_det (v w : Vec) :
    v.1 * ((lorCross v w).2.1 * w.2.2 - (lorCross v w).2.2 * w.2.1)
      - v.2.1 * ((lorCross v w).1 * w.2.2 - (lorCross v w).2.2 * w.1)
      + v.2.2 * ((lorCross v w).1 * w.2.1 - (lorCross v w).2.1 * w.1)
      = -(bil v w ^ 2 - qform v * qform w) := by
  obtain ⟨a, b, c⟩ := v; obtain ⟨p, q, r⟩ := w
  simp only [lorCross, qform, bil]; ring

/-! ### Primitive vectors pair to `1` -/

/-- A vector of `ℤ^{2,1}` is **primitive** when its coordinates have no common
non-unit divisor. -/
def IsPrimitive (v : Vec) : Prop :=
  ∀ d : ℤ, d ∣ v.1 → d ∣ v.2.1 → d ∣ v.2.2 → IsUnit d

/-- **Unimodularity of `ℤ^{2,1}`.**  A primitive vector pairs to `1` with some lattice
vector; equivalently the functional `bil ρ · : ℤ³ → ℤ` is surjective.  Two applications
of Bézout's identity. -/
theorem exists_pairing_one {ρ : Vec} (h : IsPrimitive ρ) : ∃ σ : Vec, bil ρ σ = 1 := by
  obtain ⟨a, b, c⟩ := ρ
  simp only [IsPrimitive] at h
  set g : ℤ := ((Int.gcd ((Int.gcd a b : ℕ) : ℤ) c : ℕ) : ℤ) with hg
  have hga : g ∣ a := dvd_trans (Int.gcd_dvd_left _ _) (Int.gcd_dvd_left _ _)
  have hgb : g ∣ b := dvd_trans (Int.gcd_dvd_left _ _) (Int.gcd_dvd_right _ _)
  have hgc : g ∣ c := Int.gcd_dvd_right _ _
  have hgu : IsUnit g := h g hga hgb hgc
  have hgnonneg : (0 : ℤ) ≤ g := by positivity
  have hg1 : g = 1 := by
    rcases Int.isUnit_iff.mp hgu with h1 | h1
    · exact h1
    · omega
  have hab : ((Int.gcd a b : ℕ) : ℤ) = a * Int.gcdA a b + b * Int.gcdB a b :=
    Int.gcd_eq_gcd_ab a b
  have hgc' : g = ((Int.gcd a b : ℕ) : ℤ) * Int.gcdA ((Int.gcd a b : ℕ) : ℤ) c
      + c * Int.gcdB ((Int.gcd a b : ℕ) : ℤ) c := Int.gcd_eq_gcd_ab _ c
  rw [hg1] at hgc'
  refine ⟨(Int.gcdA a b * Int.gcdA ((Int.gcd a b : ℕ) : ℤ) c,
      Int.gcdB a b * Int.gcdA ((Int.gcd a b : ℕ) : ℤ) c,
      -Int.gcdB ((Int.gcd a b : ℕ) : ℤ) c), ?_⟩
  simp only [bil]
  linear_combination (-(Int.gcdA ((Int.gcd a b : ℕ) : ℤ) c)) * hab - hgc'

/-! ### The frame `{ρ, τ, σ}` detects zero -/

/-- If `bil ρ σ = 1` and `ρ` is isotropic, a vector orthogonal to `ρ`, to
`τ = lorCross ρ σ` and to `σ` must vanish: the frame has determinant `−1`, so Cramer's
rule applies over `ℤ`. -/
theorem perp_triple_eq_zero {ρ σ u : Vec} (hρ : qform ρ = 0) (hσ : bil ρ σ = 1)
    (h1 : bil u ρ = 0) (h2 : bil u (lorCross ρ σ) = 0) (h3 : bil u σ = 0) : u = 0 := by
  obtain ⟨a, b, c⟩ := ρ; obtain ⟨p, q, r⟩ := σ; obtain ⟨u1, u2, u3⟩ := u
  simp only [qform, bil, lorCross] at hρ hσ h1 h2 h3 ⊢
  refine Prod.ext ?_ (Prod.ext ?_ ?_)
  · show u1 = 0
    linear_combination (u1 * (p * p + q * q - r * r)) * hρ
      - (u1 * (a * p + b * q - c * r + 1)) * hσ
      - (a * q ^ 2 - a * r ^ 2 - b * p * q + c * p * r) * h1
      - (-b * r + c * q) * h2
      - (-a * b * q + a * c * r + b ^ 2 * p - c ^ 2 * p) * h3
  · show u2 = 0
    linear_combination (u2 * (p * p + q * q - r * r)) * hρ
      - (u2 * (a * p + b * q - c * r + 1)) * hσ
      - (-a * p * q + b * p ^ 2 - b * r ^ 2 + c * q * r) * h1
      - (a * r - c * p) * h2
      - (a ^ 2 * q - a * b * p + b * c * r - c ^ 2 * q) * h3
  · show u3 = 0
    linear_combination (u3 * (p * p + q * q - r * r)) * hρ
      - (u3 * (a * p + b * q - c * r + 1)) * hσ
      + (a * p * r + b * q * r - c * p ^ 2 - c * q ^ 2) * h1
      + (-a * q + b * p) * h2
      + (-a ^ 2 * r + a * c * p - b ^ 2 * r + b * c * q) * h3

/-! ### The rigidity theorem -/

/-- `{ρ, τ}` spans the orthogonal lattice `ρ^⊥` over `ℤ`, for `τ = lorCross ρ σ`, with
coordinates read off by the form itself. -/
theorem primitive_isotropic_perp_basis {ρ σ : Vec} (hρ : qform ρ = 0) (hσ : bil ρ σ = 1)
    {v : Vec} (hv : bil v ρ = 0) :
    v = (bil v σ) • ρ + (bil v (lorCross ρ σ)) • lorCross ρ σ := by
  have hτρ : bil (lorCross ρ σ) ρ = 0 := bil_lorCross_left ρ σ
  have hτσ : bil (lorCross ρ σ) σ = 0 := bil_lorCross_right ρ σ
  have hρτ : bil ρ (lorCross ρ σ) = 0 := by rw [bil_comm]; exact hτρ
  have hqτ : bil (lorCross ρ σ) (lorCross ρ σ) = 1 := by
    have := qform_lorCross ρ σ
    simp only [qform] at this hρ
    rw [this, hσ, hρ]; ring
  have hρρ : bil ρ ρ = 0 := by simpa [qform] using hρ
  set w : Vec := (bil v σ) • ρ + (bil v (lorCross ρ σ)) • lorCross ρ σ with hw
  have key : v - w = 0 := by
    refine perp_triple_eq_zero hρ hσ ?_ ?_ ?_
    · rw [bil_sub_left, hw, bil_add_left, bil_smul_left, bil_smul_left, hτρ, hρρ, hv]; ring
    · rw [bil_sub_left, hw, bil_add_left, bil_smul_left, bil_smul_left, hρτ, hqτ]; ring
    · rw [bil_sub_left, hw, bil_add_left, bil_smul_left, bil_smul_left, hσ, hτσ]; ring
  exact sub_eq_zero.mp key

/-- **Holy-construction rigidity on the Pythagorean null cone.**  For *every* primitive
isotropic vector `ρ` of `ℤ^{2,1}` — tree node or not — the Conway quotient `ρ^⊥ / ℤρ` is
the rank-one odd unimodular lattice `⟨1⟩`: there is a vector `τ ⊥ ρ` of norm `1`, not a
multiple of `ρ`, such that `{ρ, τ}` spans `ρ^⊥` and the induced form is `y ↦ y²`.

In the even rescaling `ℤ^{2,1}(2)` the class of `τ` is a **root** (norm `2`).  The Leech
lattice, the holy construction of `II(25,1)`, is rootless; so no holy construction on the
Pythagorean null cone can be Leech-like.  Rootlessness is a strictly even phenomenon. -/
theorem primitive_isotropic_holy_construction {ρ : Vec} (hρ : qform ρ = 0)
    (hprim : IsPrimitive ρ) :
    ∃ τ : Vec, bil τ ρ = 0 ∧ qform τ = 1 ∧ (∀ x : ℤ, τ ≠ x • ρ) ∧
      (∀ v : Vec, bil v ρ = 0 → ∃ x y : ℤ, v = x • ρ + y • τ ∧ qform v = y ^ 2) := by
  obtain ⟨σ, hσ⟩ := exists_pairing_one hprim
  have hq : qform (lorCross ρ σ) = 1 := by rw [qform_lorCross, hσ, hρ]; ring
  refine ⟨lorCross ρ σ, bil_lorCross_left ρ σ, hq, ?_, ?_⟩
  · intro x hx
    rw [hx] at hq
    have hmul : qform (x • ρ) = x ^ 2 * qform ρ := by
      simp only [qform]
      rw [bil_smul_left, bil_smul_right]
      ring
    rw [hmul, hρ] at hq
    simp at hq
  · intro v hv
    refine ⟨bil v σ, bil v (lorCross ρ σ), primitive_isotropic_perp_basis hρ hσ hv, ?_⟩
    conv_lhs => rw [primitive_isotropic_perp_basis hρ hσ hv]
    rw [qform_combo ρ (lorCross ρ σ) hρ (bil_lorCross_left ρ σ), hq, mul_one]

/-- The coordinates in the basis `{ρ, τ}` of `ρ^⊥` are unique. -/
theorem perp_coords_unique {ρ σ : Vec} (hρ : qform ρ = 0) (hσ : bil ρ σ = 1)
    {x y x' y' : ℤ}
    (h : x • ρ + y • lorCross ρ σ = x' • ρ + y' • lorCross ρ σ) : x = x' ∧ y = y' := by
  have hτρ : bil (lorCross ρ σ) ρ = 0 := bil_lorCross_left ρ σ
  have hρτ : bil ρ (lorCross ρ σ) = 0 := by rw [bil_comm]; exact hτρ
  have hτσ : bil (lorCross ρ σ) σ = 0 := bil_lorCross_right ρ σ
  have hqτ : bil (lorCross ρ σ) (lorCross ρ σ) = 1 := by
    have := qform_lorCross ρ σ
    simp only [qform] at this hρ
    rw [this, hσ, hρ]; ring
  have hy : y = y' := by
    have hcong := congrArg (fun z => bil z (lorCross ρ σ)) h
    simp only [bil_add_left, bil_smul_left, hρτ, hqτ] at hcong
    linarith [hcong]
  refine ⟨?_, hy⟩
  have hcong := congrArg (fun z => bil z σ) h
  simp only [bil_add_left, bil_smul_left, hσ, hτσ, hy] at hcong
  linarith [hcong]

/-! ### The Berggren tree nodes are a special case -/

/-- A common divisor of all three coordinates survives a unit reflection. -/
theorem dvd_coords_reflU {d : ℤ} (r : Vec) {x : Vec}
    (h : d ∣ x.1 ∧ d ∣ x.2.1 ∧ d ∣ x.2.2) :
    d ∣ (reflU r x).1 ∧ d ∣ (reflU r x).2.1 ∧ d ∣ (reflU r x).2.2 := by
  obtain ⟨r1, r2, r3⟩ := r; obtain ⟨x1, x2, x3⟩ := x
  obtain ⟨⟨k1, rfl⟩, ⟨k2, rfl⟩, ⟨k3, rfl⟩⟩ := h
  refine ⟨⟨k1 - 2 * (k1 * r1 + k2 * r2 - k3 * r3) * r1, ?_⟩,
    ⟨k2 - 2 * (k1 * r1 + k2 * r2 - k3 * r3) * r2, ?_⟩,
    ⟨k3 - 2 * (k1 * r1 + k2 * r2 - k3 * r3) * r3, ?_⟩⟩ <;>
    simp only [reflU, bil] <;> ring

/-- …and hence a whole word of unit reflections. -/
theorem dvd_coords_reflWord {d : ℤ} (rs : List Vec) {x : Vec}
    (h : d ∣ x.1 ∧ d ∣ x.2.1 ∧ d ∣ x.2.2) :
    d ∣ (reflWord rs x).1 ∧ d ∣ (reflWord rs x).2.1 ∧ d ∣ (reflWord rs x).2.2 := by
  induction rs with
  | nil => simpa using h
  | cons r t ih => rw [reflWord_cons]; exact dvd_coords_reflU r ih

/-- **Every node of the Berggren tree is a primitive vector.**  Berggren words are
invertible over `ℤ` (they are reflection words), so a common divisor of the coordinates of
a node also divides the coordinates `3, 4, 5` of the root. -/
theorem applyGens_isPrimitive (g : List Gen) : IsPrimitive (applyGens g root) := by
  intro d h1 h2 h3
  have hroot : reflWord (wordRefl g).reverse (applyGens g root) = root := by
    rw [applyGens_isReflectionWord]
    exact reflWord_reverse _ (wordRefl_unit g) root
  have hdiv := dvd_coords_reflWord (d := d) (wordRefl g).reverse ⟨h1, h2, h3⟩
  rw [hroot] at hdiv
  have h3' : d ∣ (3 : ℤ) := hdiv.1
  have h4' : d ∣ (4 : ℤ) := hdiv.2.1
  have hone : d ∣ (1 : ℤ) := by
    have hs := dvd_sub h4' h3'
    norm_num at hs
    exact hs
  exact isUnit_of_dvd_one hone

/-- Every Berggren node is isotropic and primitive, so the rigidity theorem applies to it,
recovering `node_holy_construction` with no transport argument. -/
theorem node_isotropic_primitive_holy (g : List Gen) :
    ∃ τ : Vec, bil τ (applyGens g root) = 0 ∧ qform τ = 1 ∧
      (∀ x : ℤ, τ ≠ x • applyGens g root) ∧
      (∀ v : Vec, bil v (applyGens g root) = 0 →
        ∃ x y : ℤ, v = x • applyGens g root + y • τ ∧ qform v = y ^ 2) := by
  refine primitive_isotropic_holy_construction ?_ (applyGens_isPrimitive g)
  rw [qform, bil_applyGens]
  decide

end BerggrenStars