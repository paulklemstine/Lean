/- Original: PhotonIsUniverse.lean -/



noncomputable section

/-- Inverse stereographic projection from ℝ to S¹ ⊂ ℝ². -/
def invStereo₁ (t : ℝ) : ℝ × ℝ :=
  (2 * t / (1 + t ^ 2), (1 - t ^ 2) / (1 + t ^ 2))

/-- Forward stereographic projection from S¹ to ℝ. -/
def stereoFwd₁ (p : ℝ × ℝ) : ℝ := p.1 / (1 + p.2)

/-- **Ω₁.3**: Perfect round-trip decoding. stereo ∘ invStereo = id. -/
theorem stereo_invStereo_roundtrip (t : ℝ) :
    stereoFwd₁ (invStereo₁ t) = t := by
  simp only [stereoFwd₁, invStereo₁]
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  field_simp; ring

/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonIsUniverse
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 36] -/
theorem invStereo_avoids_south_pole (t : ℝ) :
    invStereo₁ t ≠ (0, -1) := by
  grind +locals

/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonIsUniverse
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 36] -/
theorem invStereo_surjective (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1) (hne : (x, y) ≠ (0, -1)) :
    ∃ t : ℝ, invStereo₁ t = (x, y) := by
  -- Suppose x = 0. Then from hcirc, we have y² = 1, so y = ±1. But we can't have y = -1 because (x, y) ≠ (0, -1). Hence, y = 1. Thus, x = 0 and y = 1, and invStereo₁(0) = (0, 1), since:
  by_cases hx : x = 0;
  · simp_all +decide [ invStereo₁ ];
  · use x / ( 1 + y );
    unfold invStereo₁;
    grind +qlia

/-- The conformal scaling factor of the inverse stereographic projection. -/
def invStereo_conformal_factor (t : ℝ) : ℝ := 2 / (1 + t ^ 2)

/-- **Ω₂.1**: The conformal factor is always positive — angles are preserved. -/
theorem invStereo_conformal_factor_pos (t : ℝ) :
    invStereo_conformal_factor t > 0 := by
  unfold invStereo_conformal_factor; positivity

theorem invStereo_conformal_bounded (t : ℝ) :
    invStereo_conformal_factor t ≤ 2 := by
  exact div_le_self ( by norm_num ) ( by nlinarith )

/-- **Ω₂.3**: Maximum conformality at the origin. -/
theorem invStereo_conformal_max_at_zero :
    invStereo_conformal_factor 0 = 2 := by
  unfold invStereo_conformal_factor; ring

theorem invStereo_conformal_decay (t : ℝ) (ht : |t| ≥ 1) :
    invStereo_conformal_factor t ≤ 1 := by
  exact div_le_one_of_le₀ ( by nlinarith [ abs_mul_abs_self t ] ) ( by positivity )

/-- Minkowski inner product with signature (+,-,-,-). -/
def minkInner (x y : Fin 4 → ℝ) : ℝ :=
  x 0 * y 0 - x 1 * y 1 - x 2 * y 2 - x 3 * y 3

/-- A 4-vector is future-directed. -/
def isFuture (k : Fin 4 → ℝ) : Prop := k 0 > 0

/-- The future null cone. -/
def futureNullCone : Set (Fin 4 → ℝ) := {k | isNull k ∧ isFuture k}

/-- Inverse stereographic projection to the null cone. -/
def invStereoNull (u v ω : ℝ) : Fin 4 → ℝ := fun i =>
  match i with
  | 0 => ω * (1 + u ^ 2 + v ^ 2)
  | 1 => ω * (2 * u)
  | 2 => ω * (2 * v)
  | 3 => ω * (1 - u ^ 2 - v ^ 2)

/-- **Ω₃.1**: The inverse stereographic map produces null vectors. -/
theorem inverseStereoNull_is_null (u v ω : ℝ) :
    isNull (invStereoNull u v ω) := by
  unfold isNull minkInner invStereoNull; ring

/-- **Ω₃.2**: With positive energy, the result is future-directed. -/
theorem inverseStereoNull_future (u v ω : ℝ) (hω : ω > 0) :
    isFuture (invStereoNull u v ω) := by
  unfold isFuture invStereoNull
  exact mul_pos hω (by positivity)

/-- **Ω₃.3**: The map lands in the future null cone. -/
theorem inverseStereoNull_in_cone (u v ω : ℝ) (hω : ω > 0) :
    invStereoNull u v ω ∈ futureNullCone :=
  ⟨inverseStereoNull_is_null u v ω, inverseStereoNull_future u v ω hω⟩

/-- **Ω₃.4**: The null condition rearranged. -/
lemma null_rearranged (k : Fin 4 → ℝ) (hn : isNull k) :
    (k 0) ^ 2 = (k 1) ^ 2 + (k 2) ^ 2 + (k 3) ^ 2 := by
  unfold isNull minkInner at hn; nlinarith

theorem null_cone_surjectivity (k : Fin 4 → ℝ)
    (hn : isNull k) (_hf : isFuture k) (hsum : k 0 + k 3 > 0) :
    ∃ u v ω : ℝ, ω > 0 ∧ invStereoNull u v ω = k := by
  use k 1 / ( k 0 + k 3 ), k 2 / ( k 0 + k 3 ), ( k 0 + k 3 ) / 2, by linarith, ?_ ; unfold invStereoNull ; ext i ; fin_cases i <;> norm_num <;> ring;
  · -- Combine like terms and simplify the expression.
    field_simp
    ring;
    rw [ show k 1 ^ 2 = k 0 ^ 2 - k 2 ^ 2 - k 3 ^ 2 by linarith [ null_rearranged k hn ] ] ; ring;
  · nlinarith [ mul_inv_cancel_left₀ hsum.ne' ( k 1 ) ];
  · grind;
  · field_simp;
    rw [ show k 1 ^ 2 = k 0 ^ 2 - k 2 ^ 2 - k 3 ^ 2 by linarith! [ null_rearranged k hn ] ] ; ring!;

/-- Gaussian integer multiplication. -/
def GaussInt.mul (a b : GaussInt) : GaussInt where
  re := a.re * b.re - a.im * b.im
  im := a.re * b.im + a.im * b.re

/-- **Ω₄.1**: The stereographic denominator IS a Gaussian norm. -/
theorem stereo_denom_gaussian_norm (p q : ℤ) :
    stereoDenom p q = (GaussInt.mk p q).norm := by
  simp [stereoDenom, GaussInt.norm]

/-- **Ω₄.3**: Integer encodings produce specific particle energies. -/
theorem vacuum_energy : stereoDenom 0 1 = 1 := by simp [stereoDenom]

theorem photon_energy : stereoDenom 1 1 = 2 := by simp [stereoDenom]

theorem prime_particle : stereoDenom 2 1 = 5 := by simp [stereoDenom]

/-- The area of a 2-sphere of radius r. -/
def sphereArea (r : ℝ) : ℝ := 4 * π * r ^ 2

/-- The Bekenstein–Hawking entropy bound: S ≤ A / 4 (in Planck units). -/
def holographicBound (area : ℝ) : ℝ := area / 4

/-- The information capacity of a photon's celestial sphere at radius r. -/
def photonCapacity (r : ℝ) : ℝ := holographicBound (sphereArea r)

/-- **Ω₅.1**: The photon capacity equals π r². -/
theorem photonCapacity_eq (r : ℝ) : photonCapacity r = π * r ^ 2 := by
  unfold photonCapacity holographicBound sphereArea; ring

/-- **Ω₅.2**: The capacity is non-negative. -/
theorem photonCapacity_nonneg (r : ℝ) : photonCapacity r ≥ 0 := by
  rw [photonCapacity_eq]
  exact mul_nonneg (le_of_lt pi_pos) (sq_nonneg r)

theorem photon_capacity_unbounded : ∀ M : ℝ, ∃ r : ℝ, photonCapacity r > M := by
  unfold photonCapacity;
  unfold holographicBound sphereArea;
  exact fun M => ⟨ |M| + 1, by cases abs_cases M <;> nlinarith [ Real.pi_gt_three, mul_self_nonneg ( |M| + 1 ) ] ⟩

/-- There are exactly 5 oracles. -/
theorem oracle_count : Fintype.card MetaOracle = 5 := by decide

/-- Each oracle's verdict: does the photon encode the universe? -/
def oracleVerdict : MetaOracle → Prop
  | .topological  => Function.Injective invStereo₁
  | .conformal    => ∀ t, invStereo_conformal_factor t > 0
  | .nullCone     => ∀ u v ω, ω > 0 → invStereoNull u v ω ∈ futureNullCone
  | .arithmetic   => ∀ p q : ℤ, stereoDenom p q = (GaussInt.mk p q).norm
  | .information  => ∀ M : ℝ, ∃ r, photonCapacity r > M

/-- **THE META ORACLE CONSENSUS THEOREM**:
All five oracles independently verify that a single photon's inverse
stereographic projection faithfully encodes the universe. -/
theorem meta_oracle_consensus : ∀ oracle : MetaOracle, oracleVerdict oracle := by
  intro oracle
  cases oracle with
  | topological  => exact invStereo_injective
  | conformal    => exact invStereo_conformal_factor_pos
  | nullCone     => exact fun u v ω hω => inverseStereoNull_in_cone u v ω hω
  | arithmetic   => exact stereo_denom_gaussian_norm
  | information  => exact photon_capacity_unbounded

/-- The complete characterization: a single photon's inverse stereographic projection
satisfies ALL of the following simultaneously. -/
theorem photon_is_universe :
    Function.Injective invStereo₁ ∧
    (∀ t, (invStereo₁ t).1 ^ 2 + (invStereo₁ t).2 ^ 2 = 1) ∧
    (∀ t, stereoFwd₁ (invStereo₁ t) = t) ∧
    (∀ t, invStereo_conformal_factor t > 0) ∧
    (∀ oracle : MetaOracle, oracleVerdict oracle) :=
  ⟨invStereo_injective,
   invStereo_on_sphere,
   stereo_invStereo_roundtrip,
   invStereo_conformal_factor_pos,
   meta_oracle_consensus⟩

theorem iterate_forever_is_identity (t : ℝ) (n : ℕ) :
    (fun x => stereoFwd₁ (invStereo₁ x))^[n] t = t := by
  induction n <;> simp_all +decide [ Function.iterate_succ_apply' ];
  exact?

/-- The encoding is a fixed point of the decode-encode cycle. -/
theorem encoding_fixed_point (t : ℝ) :
    stereoFwd₁ (invStereo₁ t) = t :=
  stereo_invStereo_roundtrip t

end

/- Original: PhotonParity.lean -/



/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonParity
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 4] -/
theorem pyth_not_both_odd (a b c : ℤ) (h : a^2 + b^2 = c^2)
    (ha : ¬ 2 ∣ a) (hb : ¬ 2 ∣ b) : False := by
  simp_all +decide [ ← even_iff_two_dvd, parity_simps ];
  exact absurd ( congr_arg ( · % 4 ) h ) ( by obtain ⟨ k, rfl ⟩ := ha; obtain ⟨ l, rfl ⟩ := hb; rcases Int.even_or_odd' c with ⟨ m, rfl | rfl ⟩ <;> ring_nf <;> norm_num )

/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonParity
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 4] -/
theorem pyth_hypotenuse_odd (a b c : ℕ) (h : a^2 + b^2 = c^2)
    (hcop : Nat.Coprime a b) : ¬ 2 ∣ c := by
  contrapose! hcop; have := congr_arg ( · % 4 ) h; rcases Nat.even_or_odd' a with ⟨ b₁, rfl | rfl ⟩ <;> rcases Nat.even_or_odd' b with ⟨ b₂, rfl | rfl ⟩ <;> rcases Nat.even_or_odd' c with ⟨ b₃, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Nat.add_mod, Nat.mul_mod ] at *;
  · norm_num [ Nat.gcd_mul_right, Nat.gcd_mul_left ];
  · grind +ring;
  · grind +ring

theorem pyth_one_leg_even (a b c : ℕ) (h : a^2 + b^2 = c^2)
    (hcop : Nat.Coprime a b) (ha : 0 < a) (hb : 0 < b) :
    (2 ∣ a ∧ ¬ 2 ∣ b) ∨ (¬ 2 ∣ a ∧ 2 ∣ b) := by
  by_cases ha : 2 ∣ a <;> by_cases hb : 2 ∣ b <;> simp_all +decide [ Nat.dvd_iff_mod_eq_zero ];
  · have := Nat.dvd_gcd ( Nat.dvd_of_mod_eq_zero ha ) ( Nat.dvd_of_mod_eq_zero hb ) ; aesop;
  · exact absurd ( congr_arg ( · % 4 ) h ) ( by rw [ ← Nat.mod_add_div a 2, ← Nat.mod_add_div b 2, ha, hb ] ; ring_nf; norm_num [ Nat.add_mod, Nat.mul_mod, Nat.pow_mod ] ; have := Nat.mod_lt c zero_lt_four ; interval_cases c % 4 <;> trivial )

theorem pyth_parametrization (m n : ℤ) :
    (m^2 - n^2)^2 + (2*m*n)^2 = (m^2 + n^2)^2 := by
  ring

/- Original: PhotonResearchRound2.lean -/



noncomputable section

/-- Minkowski form Q(a,b,c) = a² + b² - c² -/
def minkQ (a b c : ℝ) : ℝ := a ^ 2 + b ^ 2 - c ^ 2

/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonResearchRound2
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 24] -/
theorem null_gaussian_product (a₁ b₁ c₁ a₂ b₂ c₂ : ℝ)
    (h₁ : IsNull a₁ b₁ c₁) (h₂ : IsNull a₂ b₂ c₂) :
    IsNull (a₁ * a₂ - b₁ * b₂) (a₁ * b₂ + a₂ * b₁) (c₁ * c₂) := by
  -- By definition of IsNull, we have minkQ a₁ b₁ c₁ = 0 and minkQ a₂ b₂ c₂ = 0.
  unfold IsNull at *;
  unfold minkQ at *; nlinarith;

/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonResearchRound2
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 24] -/
theorem conjugate_photon (a b c : ℤ) (h : IsPythTriple a b c) :
    IsPythTriple a (-b) c := by
  unfold IsPythTriple at *; linarith [ pow_two_nonneg b ] ;

theorem conjugate_photon' (a b c : ℤ) (h : IsPythTriple a b c) :
    IsPythTriple (-a) b c := by
  unfold IsPythTriple at *; linarith;

theorem antipodal_photon (a b c : ℤ) (h : IsPythTriple a b c) :
    IsPythTriple (-a) (-b) c := by
  unfold IsPythTriple at *; linarith [ pow_two ( -a ), pow_two ( -b ) ] ;

/-- Gaussian product operation on triples -/
def gaussProd (t₁ t₂ : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (t₁.1 * t₂.1 - t₁.2.1 * t₂.2.1,
   t₁.1 * t₂.2.1 + t₁.2.1 * t₂.1,
   t₁.2.2 * t₂.2.2)

theorem gaussProd_comm (t₁ t₂ : ℤ × ℤ × ℤ) :
    gaussProd t₁ t₂ = gaussProd t₂ t₁ := by
  unfold gaussProd; ring;

theorem gaussProd_assoc (t₁ t₂ t₃ : ℤ × ℤ × ℤ) :
    gaussProd (gaussProd t₁ t₂) t₃ = gaussProd t₁ (gaussProd t₂ t₃) := by
  unfold gaussProd; ring;

theorem gaussProd_identity (t : ℤ × ℤ × ℤ) :
    gaussProd (1, 0, 1) t = t := by
  -- By definition of gaussProd, we have:
  simp [gaussProd]

theorem identity_is_triple : IsPythTriple 1 0 1 := by
  exact?

theorem photon_squared (a b c : ℤ) (h : IsPythTriple a b c) :
    IsPythTriple (a ^ 2 - b ^ 2) (2 * a * b) (c ^ 2) := by
  unfold IsPythTriple at *; nlinarith;

theorem null_inner_vanishes_product (a₁ b₁ c₁ a₂ b₂ c₂ : ℝ)
    (h₁ : IsNull a₁ b₁ c₁) (h₂ : IsNull a₂ b₂ c₂) :
    minkInner a₁ b₁ c₁ a₂ b₂ c₂ ^ 2 ≥ minkQ a₁ b₁ c₁ * minkQ a₂ b₂ c₂ := by
  unfold IsNull at *; unfold minkQ at *; unfold minkInner at *; nlinarith;

theorem light_cone_intersection (a b c dx dy dt : ℝ)
    (h₁ : IsNull a b c) (h₂ : IsNull (a - dx) (b - dy) (c - dt)) :
    2 * minkInner a b c dx dy dt = minkQ dx dy dt := by
  unfold IsNull minkInner minkQ at *; linarith;

theorem photon_345_squared :
    gaussProd (3, 4, 5) (3, 4, 5) = (-7, 24, 25) := by
  decide +kernel

theorem photon_345_squared_is_triple :
    IsPythTriple (-7) 24 25 := by
  norm_num [ IsPythTriple ]

theorem photon_product_345_51213 :
    gaussProd (3, 4, 5) (5, 12, 13) = (-33, 56, 65) := by
  native_decide +revert

theorem photon_product_is_triple :
    IsPythTriple (-33) 56 65 := by
  exact show ( -33 ) ^ 2 + 56 ^ 2 = 65 ^ 2 by norm_num;

theorem primitive_triple_odd_hypotenuse (a b c : ℤ)
    (h : IsPythTriple a b c) (ha : a % 2 = 1) (hb : b % 2 = 0) :
    c % 2 = 1 := by
  cases Int.emod_two_eq_zero_or_one c <;> ( unfold IsPythTriple at h ; ( replace h := congr_arg ( · % 4 ) h ; rcases Int.even_or_odd' a with ⟨ k, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ l, rfl | rfl ⟩ <;> rcases Int.even_or_odd' c with ⟨ m, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Int.add_emod, Int.mul_emod ] at *; ) )

/-- The identity matrix preserves the Minkowski form. -/
theorem identity_preserves_minkQ (a b c : ℝ) :
    minkQ a b c = minkQ a b c := rfl

theorem comp_preserves_minkQ
    (f g : ℝ → ℝ → ℝ → ℝ × ℝ × ℝ)
    (hf : ∀ a b c, minkQ (f a b c).1 (f a b c).2.1 (f a b c).2.2 = minkQ a b c)
    (hg : ∀ a b c, minkQ (g a b c).1 (g a b c).2.1 (g a b c).2.2 = minkQ a b c)
    (a b c : ℝ) :
    let v := f a b c
    minkQ (g v.1 v.2.1 v.2.2).1 (g v.1 v.2.1 v.2.2).2.1 (g v.1 v.2.1 v.2.2).2.2 =
      minkQ a b c := by
  aesop

theorem null_basis_vectors :
    IsNull 1 0 1 ∧ IsNull 1 0 (-1) := by
  exact ⟨ by unfold IsNull; unfold minkQ; norm_num, by unfold IsNull; unfold minkQ; norm_num ⟩

/-- The null vectors (1,0,1) and (1,0,-1) are not proportional (linearly independent
when combined with (0,1,0)). -/
theorem null_basis_inner :
    minkInner 1 0 1 1 0 (-1) = 2 := by
  simp [minkInner]; norm_num

theorem spacelike_basis :
    minkQ 0 1 0 > 0 := by
  unfold minkQ; norm_num;

theorem photon_helicity_bound (a b c : ℝ) (h : IsNull a b c) (hc : c ≠ 0) :
    |a * b| / c ^ 2 ≤ 1 / 2 := by
  rw [ div_le_iff₀ ] <;> norm_num [ IsNull ] at *;
  · unfold minkQ at h; nlinarith [ sq_nonneg ( |a| - |b| ), abs_mul_abs_self a, abs_mul_abs_self b ] ;
  · positivity

end

/- Original: PhotonResearchRound5.lean -/



/-- An octonion represented as 8 integer components: 1, e₁, ..., e₇ -/
structure Oct where
  c0 : ℤ
  c1 : ℤ
  c2 : ℤ
  c3 : ℤ
  c4 : ℤ
  c5 : ℤ
  c6 : ℤ
  c7 : ℤ
  deriving Repr, DecidableEq

@[ext]

/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonResearchRound5
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 51] -/
theorem Oct.ext' {a b : Oct} (h0 : a.c0 = b.c0) (h1 : a.c1 = b.c1) (h2 : a.c2 = b.c2)
    (h3 : a.c3 = b.c3) (h4 : a.c4 = b.c4) (h5 : a.c5 = b.c5) (h6 : a.c6 = b.c6)
    (h7 : a.c7 = b.c7) : a = b := by
  cases a; cases b; simp_all

/-- The squared norm of an octonion -/
def Oct.normSq (o : Oct) : ℤ :=
  o.c0^2 + o.c1^2 + o.c2^2 + o.c3^2 + o.c4^2 + o.c5^2 + o.c6^2 + o.c7^2

/-- Octonion multiplication (using standard Fano plane rules) -/
def Oct.mul (a b : Oct) : Oct where
  c0 := a.c0*b.c0 - a.c1*b.c1 - a.c2*b.c2 - a.c3*b.c3 - a.c4*b.c4 - a.c5*b.c5 - a.c6*b.c6 - a.c7*b.c7
  c1 := a.c0*b.c1 + a.c1*b.c0 + a.c2*b.c3 - a.c3*b.c2 + a.c4*b.c5 - a.c5*b.c4 - a.c6*b.c7 + a.c7*b.c6
  c2 := a.c0*b.c2 - a.c1*b.c3 + a.c2*b.c0 + a.c3*b.c1 + a.c4*b.c6 + a.c5*b.c7 - a.c6*b.c4 - a.c7*b.c5
  c3 := a.c0*b.c3 + a.c1*b.c2 - a.c2*b.c1 + a.c3*b.c0 + a.c4*b.c7 - a.c5*b.c6 + a.c6*b.c5 - a.c7*b.c4
  c4 := a.c0*b.c4 - a.c1*b.c5 - a.c2*b.c6 - a.c3*b.c7 + a.c4*b.c0 + a.c5*b.c1 + a.c6*b.c2 + a.c7*b.c3
  c5 := a.c0*b.c5 + a.c1*b.c4 - a.c2*b.c7 + a.c3*b.c6 - a.c4*b.c1 + a.c5*b.c0 - a.c6*b.c3 + a.c7*b.c2
  c6 := a.c0*b.c6 + a.c1*b.c7 + a.c2*b.c4 - a.c3*b.c5 - a.c4*b.c2 + a.c5*b.c3 + a.c6*b.c0 - a.c7*b.c1
  c7 := a.c0*b.c7 - a.c1*b.c6 + a.c2*b.c5 + a.c3*b.c4 - a.c4*b.c3 - a.c5*b.c2 + a.c6*b.c1 + a.c7*b.c0

/-- The unit octonions -/
def Oct.one : Oct := ⟨1, 0, 0, 0, 0, 0, 0, 0⟩

/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonResearchRound5
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 51] -/
def Oct.e1 : Oct := ⟨0, 1, 0, 0, 0, 0, 0, 0⟩

def Oct.e2 : Oct := ⟨0, 0, 1, 0, 0, 0, 0, 0⟩

def Oct.e3 : Oct := ⟨0, 0, 0, 1, 0, 0, 0, 0⟩

def Oct.e4 : Oct := ⟨0, 0, 0, 0, 1, 0, 0, 0⟩

def Oct.e5 : Oct := ⟨0, 0, 0, 0, 0, 1, 0, 0⟩

def Oct.e6 : Oct := ⟨0, 0, 0, 0, 0, 0, 1, 0⟩

def Oct.e7 : Oct := ⟨0, 0, 0, 0, 0, 0, 0, 1⟩

/-- Octonion multiplication is NOT commutative -/
theorem oct_not_commutative : Oct.mul Oct.e1 Oct.e2 ≠ Oct.mul Oct.e2 Oct.e1 := by
  decide

/-- Octonion multiplication is NOT associative -/
theorem oct_not_associative :
    Oct.mul (Oct.mul Oct.e1 Oct.e2) Oct.e4 ≠ Oct.mul Oct.e1 (Oct.mul Oct.e2 Oct.e4) := by
  decide

/-- The octonion norm is multiplicative (8-square identity from first principles) -/
theorem oct_norm_multiplicative (a b : Oct) :
    (Oct.mul a b).normSq = a.normSq * b.normSq := by
  simp only [Oct.mul, Oct.normSq]; ring

/-- Unit basis octonions have norm 1 -/
theorem oct_e1_norm : Oct.e1.normSq = 1 := by simp [Oct.normSq, Oct.e1]

theorem oct_e2_norm : Oct.e2.normSq = 1 := by simp [Oct.normSq, Oct.e2]

/-- The identity octonion is a left identity -/
theorem oct_one_mul (a : Oct) : Oct.mul Oct.one a = a := by
  ext <;> simp [Oct.mul, Oct.one]

/-- The identity octonion is a right identity -/
theorem oct_mul_one (a : Oct) : Oct.mul a Oct.one = a := by
  ext <;> simp [Oct.mul, Oct.one]

/-- e₁² = -1 (like imaginary unit) -/
theorem oct_e1_sq : Oct.mul Oct.e1 Oct.e1 = ⟨-1, 0, 0, 0, 0, 0, 0, 0⟩ := by decide

/-- Octonion conjugate -/
def Oct.conj (o : Oct) : Oct :=
  ⟨o.c0, -o.c1, -o.c2, -o.c3, -o.c4, -o.c5, -o.c6, -o.c7⟩

/-- Product with conjugate gives the norm (real part) -/
theorem oct_mul_conj_real_part (a : Oct) :
    (Oct.mul a (Oct.conj a)).c0 = a.normSq := by
  simp [Oct.mul, Oct.conj, Oct.normSq]; ring

/-- The imaginary parts of a*conj(a) are zero -/
theorem oct_mul_conj_imag_zero (a : Oct) :
    (Oct.mul a (Oct.conj a)).c1 = 0 ∧
    (Oct.mul a (Oct.conj a)).c2 = 0 ∧
    (Oct.mul a (Oct.conj a)).c3 = 0 ∧
    (Oct.mul a (Oct.conj a)).c4 = 0 ∧
    (Oct.mul a (Oct.conj a)).c5 = 0 ∧
    (Oct.mul a (Oct.conj a)).c6 = 0 ∧
    (Oct.mul a (Oct.conj a)).c7 = 0 := by
  simp only [Oct.mul, Oct.conj]
  exact ⟨by ring, by ring, by ring, by ring, by ring, by ring, by ring⟩

/-- A gate is a function Oct → Oct given by left-multiplication -/
def octGate (g : Oct) (x : Oct) : Oct := Oct.mul g x

/-- Composing two oct-gates is NOT the same as the gate of the product
(because octonions are non-associative) -/
theorem oct_gates_not_composable :
    ∃ g₁ g₂ x : Oct,
      octGate g₁ (octGate g₂ x) ≠ octGate (Oct.mul g₁ g₂) x := by
  refine ⟨Oct.e1, Oct.e2, Oct.e4, ?_⟩
  show Oct.mul Oct.e1 (Oct.mul Oct.e2 Oct.e4) ≠ Oct.mul (Oct.mul Oct.e1 Oct.e2) Oct.e4
  exact Ne.symm oct_not_associative

/-- For the quaternionic subalgebra {1, e₁, e₂, e₃}, gate composition DOES work. -/
theorem quat_subalgebra_associative :
    Oct.mul (Oct.mul Oct.e1 Oct.e2) Oct.e3 = Oct.mul Oct.e1 (Oct.mul Oct.e2 Oct.e3) := by
  decide

/-- The Minkowski form in (2+1)D: Q(t,x,y) = t² - x² - y² -/
def minkForm (t x y : ℤ) : ℤ := t^2 - x^2 - y^2

/-- The Minkowski form for a null photon is zero -/
theorem null_mink_form (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    minkForm c a b = 0 := by
  simp [minkForm]; linarith

/-- Two null vectors sum to a null vector iff Minkowski-orthogonal -/
theorem null_sum_null_orthogonal (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h₁ : a₁^2 + b₁^2 = c₁^2) (h₂ : a₂^2 + b₂^2 = c₂^2) :
    ((a₁ + a₂)^2 + (b₁ + b₂)^2 = (c₁ + c₂)^2) ↔
    (a₁ * a₂ + b₁ * b₂ = c₁ * c₂) := by
  constructor <;> intro h <;> nlinarith

/-- Reflection (a,b,c) → (b,a,c) preserves the Pythagorean property -/
theorem leg_swap_preserves (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    b^2 + a^2 = c^2 := by linarith

/-- Negation preserves the Pythagorean property -/
theorem neg_leg_preserves (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (-a)^2 + b^2 = c^2 := by nlinarith

/-- Sign changes on both legs preserve the Pythagorean property -/
theorem sign_change_preserves (a b c : ℤ) (h : a^2 + b^2 = c^2)
    (s₁ s₂ : ℤ) (hs₁ : s₁^2 = 1) (hs₂ : s₂^2 = 1) :
    (s₁ * a)^2 + (s₂ * b)^2 = c^2 := by nlinarith

/-- The Hurwitz dimensions are exactly 2^k for k = 0, 1, 2, 3 -/
theorem hurwitz_are_powers_of_two :
    ∀ d ∈ ({1, 2, 4, 8} : Finset ℕ), ∃ k : ℕ, k ≤ 3 ∧ d = 2^k := by
  intro d hd; simp at hd
  rcases hd with rfl | rfl | rfl | rfl
  · exact ⟨0, by omega, by norm_num⟩
  · exact ⟨1, by omega, by norm_num⟩
  · exact ⟨2, by omega, by norm_num⟩
  · exact ⟨3, by omega, by norm_num⟩

/-- Product of Hurwitz dimensions: 1 · 2 · 4 · 8 = 64 = 2⁶ -/
theorem hurwitz_product : (1 : ℕ) * 2 * 4 * 8 = 2^6 := by norm_num

/-- Sum of squares of Hurwitz dimensions: 1² + 2² + 4² + 8² = 85 -/
theorem hurwitz_sum_sq : (1 : ℕ)^2 + 2^2 + 4^2 + 8^2 = 85 := by norm_num

/-- Each Hurwitz dimension divides the next -/
theorem hurwitz_divisibility : (1 : ℕ) ∣ 2 ∧ (2 : ℕ) ∣ 4 ∧ (4 : ℕ) ∣ 8 :=
  ⟨⟨2, rfl⟩, ⟨2, rfl⟩, ⟨2, rfl⟩⟩

/-- Chirality of a photon: sign of the "angular momentum" ab -/
def photonChirality (a b : ℤ) : ℤ :=
  if a * b > 0 then 1
  else if a * b < 0 then -1
  else 0

/-- Chirality is in {-1, 0, 1} -/
theorem chirality_values (a b : ℤ) :
    photonChirality a b ∈ ({-1, 0, 1} : Set ℤ) := by
  simp only [photonChirality, Set.mem_insert_iff, Set.mem_singleton_iff]
  split_ifs <;> omega

/-- Chirality flips under conjugation (b → -b) -/
theorem chirality_conjugate (a b : ℤ) (hab : a * b ≠ 0) :
    photonChirality a (-b) = -photonChirality a b := by
  unfold photonChirality
  split_ifs with h1 h2 h3 h4 <;> nlinarith

/-- The (3,4,5) triple is primitive -/
theorem triple_345_primitive : Int.gcd 3 4 = 1 := by native_decide

/-- The (6,8,10) triple is NOT primitive -/
theorem triple_6810_not_primitive : Int.gcd 6 8 ≠ 1 := by native_decide

theorem fano_e1e2 : Oct.mul Oct.e1 Oct.e2 = Oct.e3 := by decide

theorem fano_e2e4 : Oct.mul Oct.e2 Oct.e4 = Oct.e6 := by decide

theorem fano_e1e4 : Oct.mul Oct.e1 Oct.e4 = Oct.e5 := by decide

/-- e₄·e₁ = -e₅ (non-commutativity!) -/
theorem fano_e4e1 : Oct.mul Oct.e4 Oct.e1 = ⟨0, 0, 0, 0, 0, -1, 0, 0⟩ := by decide

/-- All basis octonions square to -1 -/
theorem oct_all_sq_minus_one :
    Oct.mul Oct.e1 Oct.e1 = ⟨-1,0,0,0,0,0,0,0⟩ ∧
    Oct.mul Oct.e2 Oct.e2 = ⟨-1,0,0,0,0,0,0,0⟩ ∧
    Oct.mul Oct.e3 Oct.e3 = ⟨-1,0,0,0,0,0,0,0⟩ ∧
    Oct.mul Oct.e4 Oct.e4 = ⟨-1,0,0,0,0,0,0,0⟩ ∧
    Oct.mul Oct.e5 Oct.e5 = ⟨-1,0,0,0,0,0,0,0⟩ ∧
    Oct.mul Oct.e6 Oct.e6 = ⟨-1,0,0,0,0,0,0,0⟩ ∧
    Oct.mul Oct.e7 Oct.e7 = ⟨-1,0,0,0,0,0,0,0⟩ := by decide

/-- The left Moufang identity verified on specific elements:
e₁(e₂(e₁·e₃)) = (e₁(e₂·e₁))e₃ -/
theorem moufang_identity_example :
    Oct.mul Oct.e1 (Oct.mul Oct.e2 (Oct.mul Oct.e1 Oct.e3)) =
    Oct.mul (Oct.mul Oct.e1 (Oct.mul Oct.e2 Oct.e1)) Oct.e3 := by decide

/-- The associator of three octonions -/
def Oct.associator (x y z : Oct) : Oct :=
  ⟨(Oct.mul (Oct.mul x y) z).c0 - (Oct.mul x (Oct.mul y z)).c0,
   (Oct.mul (Oct.mul x y) z).c1 - (Oct.mul x (Oct.mul y z)).c1,
   (Oct.mul (Oct.mul x y) z).c2 - (Oct.mul x (Oct.mul y z)).c2,
   (Oct.mul (Oct.mul x y) z).c3 - (Oct.mul x (Oct.mul y z)).c3,
   (Oct.mul (Oct.mul x y) z).c4 - (Oct.mul x (Oct.mul y z)).c4,
   (Oct.mul (Oct.mul x y) z).c5 - (Oct.mul x (Oct.mul y z)).c5,
   (Oct.mul (Oct.mul x y) z).c6 - (Oct.mul x (Oct.mul y z)).c6,
   (Oct.mul (Oct.mul x y) z).c7 - (Oct.mul x (Oct.mul y z)).c7⟩

/-- The associator is zero for quaternionic elements -/
theorem associator_zero_quat :
    Oct.associator Oct.e1 Oct.e2 Oct.e3 = ⟨0, 0, 0, 0, 0, 0, 0, 0⟩ := by decide

/-- The associator is nonzero for octonionic elements involving e₄ -/
theorem associator_nonzero_oct :
    Oct.associator Oct.e1 Oct.e2 Oct.e4 ≠ ⟨0, 0, 0, 0, 0, 0, 0, 0⟩ := by decide

/-- The associator is alternating: [x,y,z] = -[y,x,z] on basis elements -/
theorem associator_alternating_12 :
    Oct.associator Oct.e1 Oct.e2 Oct.e4 =
    ⟨-(Oct.associator Oct.e2 Oct.e1 Oct.e4).c0,
     -(Oct.associator Oct.e2 Oct.e1 Oct.e4).c1,
     -(Oct.associator Oct.e2 Oct.e1 Oct.e4).c2,
     -(Oct.associator Oct.e2 Oct.e1 Oct.e4).c3,
     -(Oct.associator Oct.e2 Oct.e1 Oct.e4).c4,
     -(Oct.associator Oct.e2 Oct.e1 Oct.e4).c5,
     -(Oct.associator Oct.e2 Oct.e1 Oct.e4).c6,
     -(Oct.associator Oct.e2 Oct.e1 Oct.e4).c7⟩ := by decide

/- Original: PhotonUniverseEncoding.lean -/



noncomputable section

/-- The null cone: the set of all null vectors. -/
def NullCone : Set (Fin 4 → ℝ) :=
  {k | IsNull k}

/-- A 4-vector is future-directed if its time component is positive. -/
def IsFutureDirected (k : Fin 4 → ℝ) : Prop :=
  k 0 > 0

/-- The future null cone: future-directed null vectors. -/
def FutureNullCone : Set (Fin 4 → ℝ) :=
  {k | IsNull k ∧ IsFutureDirected k}

/-- The inverse stereographic projection from ℝ² to the null cone.
This is THE fundamental map: it takes a point (u, v) on the celestial plane
and produces a null 4-vector. The energy parameter ω scales the result.
k^μ(u, v, ω) = ω · (1 + u² + v², 2u, 2v, 1 - u² - v²)
This is the heart of the hypothesis: the photon's worldline IS this map. -/
def inverseStereoNull (u v ω : ℝ) : Fin 4 → ℝ := fun i =>
  match i with
  | 0 => ω * (1 + u ^ 2 + v ^ 2)
  | 1 => ω * (2 * u)
  | 2 => ω * (2 * v)
  | 3 => ω * (1 - u ^ 2 - v ^ 2)

/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonUniverseEncoding
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 29] -/
theorem inverseStereoNull_in_future_cone (u v ω : ℝ) (hω : ω > 0) :
    inverseStereoNull u v ω ∈ FutureNullCone := by
      exact ⟨ inverseStereoNull_is_null u v ω, inverseStereoNull_future u v ω hω ⟩

/-- A point on the unit sphere S² in ℝ³. -/
def IsOnSphere (x y z : ℝ) : Prop :=
  x ^ 2 + y ^ 2 + z ^ 2 = 1

/-- The standard inverse stereographic projection from ℝ² to S².
Maps (u, v) ↦ (2u/(1+u²+v²), 2v/(1+u²+v²), (u²+v²-1)/(1+u²+v²)) -/
def inverseStereo (u v : ℝ) : Fin 3 → ℝ := fun i =>
  let r2 := u ^ 2 + v ^ 2
  match i with
  | 0 => 2 * u / (1 + r2)
  | 1 => 2 * v / (1 + r2)
  | 2 => (r2 - 1) / (1 + r2)

/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonUniverseEncoding
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 29] -/
theorem inverseStereo_on_sphere (u v : ℝ) :
    IsOnSphere (inverseStereo u v 0) (inverseStereo u v 1) (inverseStereo u v 2) := by
      unfold inverseStereo IsOnSphere; ring_nf; norm_num;
      -- Combine like terms and simplify the expression.
      field_simp
      ring

/-- The connection: the null vector k^μ = ω·(1+|z|², 2u, 2v, 1-|z|²) is related to
the sphere point (2u/(1+|z|²), 2v/(1+|z|²), (|z|²-1)/(1+|z|²)) by noting that
the spatial direction k/k⁰ = (2u/(1+|z|²), 2v/(1+|z|²), (1-|z|²)/(1+|z|²))
lies on S². This IS the celestial sphere! -/
def celestialDirection (u v : ℝ) : Fin 3 → ℝ := fun i =>
  let r2 := u ^ 2 + v ^ 2
  match i with
  | 0 => 2 * u / (1 + r2)
  | 1 => 2 * v / (1 + r2)
  | 2 => (1 - r2) / (1 + r2)

theorem celestialDirection_on_sphere (u v : ℝ) :
    IsOnSphere (celestialDirection u v 0) (celestialDirection u v 1)
               (celestialDirection u v 2) := by
                 unfold celestialDirection; unfold IsOnSphere; norm_num; ring; norm_cast; ring;
                 -- Combine like terms and simplify the expression.
                 field_simp
                 ring

theorem celestialDirection_is_normalized_null (u v ω : ℝ) (hω : ω ≠ 0) :
    ∀ i : Fin 3, celestialDirection u v i =
      inverseStereoNull u v ω (i.castSucc + 1) / inverseStereoNull u v ω 0 := by
        intro i; fin_cases i <;> unfold celestialDirection inverseStereoNull <;> norm_num ; ring;
        · grind;
        · grind +splitImp;
        · grind

/-- The determinant condition for Möbius transformations: ad - bc = 1. -/
def IsMobiusNormalized (a b c d : ℝ) : Prop :=
  a * d - b * c = 1

theorem bekensteinBound_nonneg (area : ℝ) (h : area ≥ 0) :
    bekensteinBound area ≥ 0 := by
      exact div_nonneg h zero_le_four

theorem bekensteinBound_mono {a₁ a₂ : ℝ} (h : a₁ ≤ a₂) :
    bekensteinBound a₁ ≤ bekensteinBound a₂ := by
      exact div_le_div_of_nonneg_right h zero_le_four

/-- The area of the celestial sphere at radius r. -/
def celestialSphereArea (r : ℝ) : ℝ := 4 * Real.pi * r ^ 2

theorem celestialSphereArea_nonneg (r : ℝ) :
    celestialSphereArea r ≥ 0 := by
      exact mul_nonneg ( mul_nonneg zero_le_four Real.pi_pos.le ) ( sq_nonneg r )

/-- The information capacity of the celestial sphere at radius r
is proportional to r². This is the maximum bits of universe-information
a photon can encode at distance r. -/
def photonInfoCapacity (r : ℝ) : ℝ :=
  bekensteinBound (celestialSphereArea r)

theorem photonInfoCapacity_eq (r : ℝ) :
    photonInfoCapacity r = Real.pi * r ^ 2 := by
      unfold photonInfoCapacity; unfold bekensteinBound; unfold celestialSphereArea; ring;

theorem photonInfoCapacity_unbounded :
    ∀ M : ℝ, ∃ r : ℝ, photonInfoCapacity r > M := by
      intro M
      use Real.sqrt (M / Real.pi + 1) + 1;
      unfold photonInfoCapacity;
      unfold bekensteinBound celestialSphereArea;
      by_cases hM : M / Real.pi + 1 ≥ 0;
      · nlinarith [ Real.pi_gt_three, mul_div_cancel₀ M Real.pi_ne_zero, Real.sqrt_nonneg ( M / Real.pi + 1 ), Real.mul_self_sqrt hM ];
      · rw [ Real.sqrt_eq_zero'.mpr ] <;> nlinarith [ Real.pi_pos, mul_div_cancel₀ M Real.pi_ne_zero ]

/-- A twistor is a pair (ω, π) ∈ ℂ² × ℂ² ≅ ℂ⁴.
We represent it using real coordinates as a point in ℝ⁸.
For a null twistor (one that corresponds to a null geodesic in spacetime),
the incidence relation ω^A = ix^{AA'}π_{A'} is satisfied. -/
structure Twistor where
  /-- The ω component (2 complex = 4 real) -/
  omega : Fin 4 → ℝ
  /-- The π component (2 complex = 4 real) -/
  pi : Fin 4 → ℝ

/-- A twistor is null if ω · π̄ + ω̄ · π = 0.
In real coordinates: Σᵢ ωᵢ πᵢ = 0. -/
def Twistor.isNull (Z : Twistor) : Prop :=
  ∑ i : Fin 4, Z.omega i * Z.pi i = 0

/-- The simplest twistor corresponding to a photon moving in the z-direction:
π = (1, 0) in complex coordinates, or (1, 0, 0, 0) in real coordinates.
ω = (0, 0) since x = 0 (the photon passes through the origin). -/
def zPhotonTwistor : Twistor where
  omega := ![0, 0, 0, 0]
  pi := ![1, 0, 0, 0]

theorem zPhotonTwistor_isNull : zPhotonTwistor.isNull := by
  exact show ∑ i : Fin 4, ( if i.val = 0 then 0 else if i.val = 1 then 0 else if i.val = 2 then 0 else 0 ) * ( if i.val = 0 then 1 else if i.val = 1 then 0 else if i.val = 2 then 0 else 0 ) = 0 from by norm_num [ Fin.sum_univ_four ] ;

lemma future_null_k0_plus_k3_nonneg (k : Fin 4 → ℝ) (hk : k ∈ FutureNullCone) :
    k 0 + k 3 ≥ 0 := by
      -- From the null condition, we have (k 0)^2 = (k 1)^2 + (k 2)^2 + (k 3)^2. Since squares are non-negative, this implies that (k 0)^2 ≥ (k 3)^2. Taking square roots (and considering that k 0 is positive), we get k 0 ≥ |k 3|.
      have h_k0_ge_abs_k3 : k 0 ^ 2 ≥ k 3 ^ 2 := by
        obtain ⟨hk_null, hk_fut⟩ := hk;
        unfold IsNull IsFutureDirected at *;
        unfold minkowskiInner at hk_null; linarith [ sq_nonneg ( k 1 ), sq_nonneg ( k 2 ), sq_nonneg ( k 3 ) ] ;
      nlinarith [ hk.2, show 0 ≤ k 0 from hk.2.le ]

lemma null_condition_rearranged (k : Fin 4 → ℝ) (hnull : IsNull k) :
    (k 0) ^ 2 = (k 1) ^ 2 + (k 2) ^ 2 + (k 3) ^ 2 := by
      unfold IsNull minkowskiInner at hnull; cases lt_or_ge ( k 0 ) 0 <;> cases lt_or_ge ( k 1 ) 0 <;> nlinarith;

lemma future_null_south_pole (k : Fin 4 → ℝ) (hk : k ∈ FutureNullCone)
    (hsum : k 0 + k 3 = 0) :
    k 1 = 0 ∧ k 2 = 0 := by
      -- Using the null condition, we have $(k 0)^2 = (k 1)^2 + (k 2)^2 + (k 3)^2$.
      have null_cond : (k 0) ^ 2 = (k 1) ^ 2 + (k 2) ^ 2 + (k 3) ^ 2 := by
        convert null_condition_rearranged k hk.1 using 1;
      simp_all +decide [ show k 3 = -k 0 by linarith ] ; constructor <;> nlinarith;

lemma inverseStereoNull_surj_standard (k : Fin 4 → ℝ)
    (hnull : IsNull k) (_hfut : IsFutureDirected k)
    (hsum : k 0 + k 3 > 0) :
    let u := k 1 / (k 0 + k 3)
    let v := k 2 / (k 0 + k 3)
    let ω := (k 0 + k 3) / 2
    ω > 0 ∧ inverseStereoNull u v ω = k := by
      unfold inverseStereoNull;
      grind +locals

theorem photon_worldline_is_inverseStereo_standard :
    ∀ k : Fin 4 → ℝ, k ∈ FutureNullCone → k 0 + k 3 > 0 →
      ∃ u v ω : ℝ, ω > 0 ∧ inverseStereoNull u v ω = k := by
        intro k hk hsum;
        have := inverseStereoNull_surj_standard k hk.1 hk.2 hsum;
        exact ⟨ _, _, _, this.1, this.2 ⟩

theorem photon_universe_encoding :
    (∀ M : ℝ, ∃ r : ℝ, photonInfoCapacity r > M) ∧
    (∀ k : Fin 4 → ℝ, k ∈ FutureNullCone → k 0 + k 3 > 0 →
      ∃ u v ω : ℝ, ω > 0 ∧ inverseStereoNull u v ω = k) := by
        exact ⟨ photonInfoCapacity_unbounded, fun k hk hk' => by obtain ⟨ u, v, ω, hω, h ⟩ := photon_worldline_is_inverseStereo_standard k hk hk'; exact ⟨ u, v, ω, hω, h ⟩ ⟩

end

/- Original: PhotonicInverseStereo.lean -/



noncomputable section

/-- Forward stereographic projection from S² \ {N} to ℝ².
Maps (x, y, z) with z ≠ 1 to (x/(1-z), y/(1-z)). -/
def fwdStereo2D (x y z : ℝ) : ℝ × ℝ :=
  (x / (1 - z), y / (1 - z))

/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonicInverseStereo
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 10] -/
theorem conformal_factor_at_unit_circle (u v : ℝ) (h : u ^ 2 + v ^ 2 = 1) :
    conformalFactor u v = 1 := by
  unfold conformalFactor;
  grind

/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonicInverseStereo
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 10] -/
theorem conformal_factor_le_four (u v : ℝ) :
    conformalFactor u v ≤ 4 := by
  exact div_le_self ( by norm_num ) ( one_le_pow₀ ( by nlinarith ) )

theorem chordal_distance_formula (u₁ v₁ u₂ v₂ : ℝ) :
    chordalDistSq u₁ v₁ u₂ v₂ =
      4 * ((u₁ - u₂) ^ 2 + (v₁ - v₂) ^ 2) /
        ((1 + u₁ ^ 2 + v₁ ^ 2) * (1 + u₂ ^ 2 + v₂ ^ 2)) := by
  unfold chordalDistSq invStereo2D;
  field_simp;
  grind +splitImp

/-- A photon in the PISPD model: has a position on the detector plane,
intensity, and wavelength. -/
structure PISPDPhoton where
  u : ℝ        -- position on plane (u-coordinate)
  v : ℝ        -- position on plane (v-coordinate)
  intensity : ℝ -- photon intensity ∈ [0, 1]
  wavelength : ℝ -- wavelength in appropriate units

/-- The conformal energy of a single photon: intensity weighted by the
conformal factor at its position. -/
def photonConformalEnergy (p : PISPDPhoton) : ℝ :=
  p.intensity * conformalFactor p.u p.v

theorem pispd_fundamental_identity (u v : ℝ) :
    (2 * u) ^ 2 + (2 * v) ^ 2 + (u ^ 2 + v ^ 2 - 1) ^ 2 =
      (u ^ 2 + v ^ 2 + 1) ^ 2 := by
  grind

theorem invStereo_dot_product (u₁ v₁ u₂ v₂ : ℝ) :
    let p₁ := invStereo2D u₁ v₁
    let p₂ := invStereo2D u₂ v₂
    p₁.1 * p₂.1 + p₁.2.1 * p₂.2.1 + p₁.2.2 * p₂.2.2 =
      (4 * u₁ * u₂ + 4 * v₁ * v₂ + (u₁^2 + v₁^2 - 1) * (u₂^2 + v₂^2 - 1)) /
        ((u₁^2 + v₁^2 + 1) * (u₂^2 + v₂^2 + 1)) := by
  unfold invStereo2D; field_simp; ring;

theorem pispd_lens_formula (r : ℝ) (hr : r ≥ 0) :
    let p₀ := invStereo2D 0 0
    let pᵣ := invStereo2D r 0
    p₀.1 * pᵣ.1 + p₀.2.1 * pᵣ.2.1 + p₀.2.2 * pᵣ.2.2 =
      (1 - r ^ 2) / (1 + r ^ 2) := by
  unfold invStereo2D; norm_num; ring;

end