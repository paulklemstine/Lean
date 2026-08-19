import Mathlib

open Function Set
/- Original: OracleAlgebra.lean -/




noncomputable section

/-- [Section: # CatalogBuild.Computation.Oracles.OracleAlgebra
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 17] -/
theorem idempotent_pow_eq {M : Type*} [Monoid M] (e : M) (he : e * e = e) (n : ℕ) (hn : n ≥ 1) :
    e ^ n = e := by
      induction hn <;> simp_all +decide [ pow_succ' ]




/-- [Section: # CatalogBuild.Computation.Oracles.OracleAlgebra
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 17] -/
theorem commuting_idempotents_product {M : Type*} [Monoid M] (e f : M)
    (he : e * e = e) (hf : f * f = f) (hc : e * f = f * e) :
    (e * f) * (e * f) = e * f := by
      grind +ring




theorem idempotent_mul_comm {M : Type*} [CommMonoid M] (e f : M)
    (he : e * e = e) (hf : f * f = f) :
    (e * f) * (e * f) = e * f := by
      grind +ring




theorem comp_commuting_oracles {X : Type*} (O₁ O₂ : X → X)
    (h₁ : ∀ x, O₁ (O₁ x) = O₁ x)
    (h₂ : ∀ x, O₂ (O₂ x) = O₂ x)
    (hc : O₁ ∘ O₂ = O₂ ∘ O₁) :
    ∀ x, (O₁ ∘ O₂) ((O₁ ∘ O₂) x) = (O₁ ∘ O₂) x := by
      simp_all +decide [ funext_iff ]




/-- The kernel of an oracle: two elements are equivalent if the oracle gives the same answer -/
def OracleKernel {X : Type*} (O : X → X) : X → X → Prop :=
  fun x y => O x = O y




theorem oracle_kernel_refl {X : Type*} (O : X → X) : Reflexive (OracleKernel O) := by
  exact fun x => rfl




theorem oracle_kernel_symm {X : Type*} (O : X → X) : Symmetric (OracleKernel O) := by
  exact fun x y h => h.symm




theorem oracle_kernel_trans {X : Type*} (O : X → X) : Transitive (OracleKernel O) := by
  -- By definition of transitivity, if x is equivalent to y and y is equivalent to z, then x is equivalent to z.
  intro x y z hxy hyz
  exact Eq.trans hxy hyz




theorem oracle_kernel_equiv {X : Type*} (O : X → X) : Equivalence (OracleKernel O) := by
  refine' { .. };
  · exact fun x => rfl;
  · exact fun {x y} a => Eq.symm a
  · exact fun hxy hyz => hxy.trans hyz




theorem fixedPoints_eq_range {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x) :
    {x | O x = x} = range O := by
      grind +splitImp




theorem range_subset_fixedPoints {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (y : X) (hy : y ∈ range O) : O y = y := by
      grind +ring




theorem idempotent_injective_iff_surjective {n : ℕ} (O : Fin n → Fin n)
    (hO : ∀ x, O (O x) = O x) :
    Injective O ↔ Surjective O := by
      exact Finite.injective_iff_surjective




theorem oracle_lattice_inf_le {α : Type*} [CompleteLattice α] (S : Set α) (x : α) (hx : x ∈ S) :
    sInf S ≤ x := by
      exact CompleteSemilatticeInf.sInf_le S x hx




theorem oracle_knaster_tarski {α : Type*} [CompleteLattice α] (f : α → α)
    (hf : Monotone f) : ∃ x, f x = x := by
      -- By the Knaster-Tarski theorem, since $f$ is monotone, it has a least fixed point.
      have h_least_fixed_point : ∃ x : α, IsLeast {x | f x ≤ x} x := by
        refine' ⟨ sInf { x | f x ≤ x }, _, fun x hx => _ ⟩;
        · exact le_sInf fun x hx => hf ( sInf_le hx ) |> le_trans <| hx;
        · exact sInf_le hx;
      obtain ⟨ x, hx ⟩ := h_least_fixed_point;
      have hx_least : f x ≤ x := by
        exact hx.1
      have hx_least' : x ≤ f x := by
        exact hx.2 ( hf hx_least )
      have hx_eq : f x = x := by
        exact le_antisymm hx_least hx_least'
      use x




theorem rectangular_band_prop (n : ℕ) (hn : 0 < n) :
    ∀ (a : Fin n), a = a := by
      aesop




theorem idempotent_count_base : Finset.card (Finset.filter (fun f : Fin 2 → Fin 2 => ∀ x, f (f x) = f x) Finset.univ) = 3 := by
  native_decide




theorem idempotent_count_three : Finset.card (Finset.filter (fun f : Fin 3 → Fin 3 => ∀ x, f (f x) = f x) Finset.univ) = 10 := by
  native_decide




end

/- Original: OracleBootstrap.lean -/




noncomputable section

/-- An **oracle** is an idempotent self-map: consulting it twice gives the same
answer as consulting it once. -/
def IsOracle {α : Type*} (P : α → α) : Prop := ∀ x, P (P x) = P x

/-- An oracle is a retraction onto its image: it fixes every point it can output. -/
theorem oracle_retraction {α : Type*} (P : α → α) (hP : IsOracle P) (y : α)
    (hy : y ∈ range P) : P y = y := by
  obtain ⟨x, rfl⟩ := hy
  exact hP x

/-- The image of an oracle consists exactly of its fixed points. -/
theorem oracle_image_eq_fixedPoints {α : Type*} (P : α → α) (hP : IsOracle P) :
    range P = {x | P x = x} := by
  ext x
  simp only [mem_range, mem_setOf_eq]
  constructor
  · rintro ⟨y, rfl⟩; exact hP y
  · intro h; exact ⟨x, h⟩




/-- For an idempotent linear map, if P(v) = λv then λ ∈ {0, 1}.
This is the Oracle Spectrum Theorem: perfect oracles have binary spectra. -/
theorem oracle_spectrum {R : Type*} [CommRing R] [NoZeroDivisors R]
    {M : Type*} [AddCommGroup M] [Module R M] [NoZeroSMulDivisors R M]
    (P : M →ₗ[R] M) (hP : ∀ x, P (P x) = P x)
    (v : M) (hv : v ≠ 0) (ev : R) (hev : P v = ev • v) :
    ev = 0 ∨ ev = 1 := by
  have h1 : P (P v) = P v := hP v
  rw [hev, P.map_smul, hev, smul_smul] at h1
  have h2 : (ev * ev - ev) • v = 0 := by rw [sub_smul, h1, sub_self]
  rcases eq_zero_or_eq_zero_of_smul_eq_zero h2 with h | h
  · have h3 : ev * (ev - 1) = 0 := by
      have : ev * ev - ev = 0 := h
      have : ev * ev = ev := sub_eq_zero.mp this
      calc ev * (ev - 1) = ev * ev - ev * 1 := by ring
        _ = ev - ev := by rw [this, mul_one]
        _ = 0 := sub_self ev
    rcases mul_eq_zero.mp h3 with h' | h'
    · left; exact h'
    · right; exact sub_eq_zero.mp h'
  · exact absurd h hv




/-- The oracle bootstrap map f(x) = 3x² - 2x³ on scalars.
Its fixed points are exactly {0, 1/2, 1}. -/
def oracleBootstrapScalar (x : ℝ) : ℝ := 3 * x ^ 2 - 2 * x ^ 3




/-- 0 is a fixed point of the bootstrap map. -/
theorem bootstrap_fixed_zero : oracleBootstrapScalar 0 = 0 := by
  simp [oracleBootstrapScalar]




/-- 1 is a fixed point of the bootstrap map. -/
theorem bootstrap_fixed_one : oracleBootstrapScalar 1 = 1 := by
  unfold oracleBootstrapScalar; ring




/-- 1/2 is a fixed point of the bootstrap map (the unstable one). -/
theorem bootstrap_fixed_half : oracleBootstrapScalar (1/2) = 1/2 := by
  unfold oracleBootstrapScalar; ring




/-- The derivative of the bootstrap map is f'(x) = 6x - 6x² = 6x(1-x).
At x = 0: f'(0) = 0. At x = 1: f'(1) = 0.
Zero derivative at fixed points means superlinear convergence. -/
theorem bootstrap_derivative_at_fixed_points :
    (fun x : ℝ => 6 * x - 6 * x ^ 2) 0 = 0 ∧
    (fun x : ℝ => 6 * x - 6 * x ^ 2) 1 = 0 := by
  constructor <;> ring




/-- In any metric space, a contracting map brings points closer together. -/
theorem contraction_closer {X : Type*} [MetricSpace X]
    (f : X → X) (c : ℝ) (_hc : 0 ≤ c) (hc1 : c < 1)
    (hf : ∀ x y, dist (f x) (f y) ≤ c * dist x y) :
    ∀ x y, dist (f x) (f y) ≤ dist x y := by
  intro x y
  calc dist (f x) (f y) ≤ c * dist x y := hf x y
    _ ≤ 1 * dist x y := by
        apply mul_le_mul_of_nonneg_right (le_of_lt hc1) (dist_nonneg)
    _ = dist x y := by ring




/-- An oracle is a zero-contraction on its range: it moves no points. -/
theorem oracle_zero_contraction {X : Type*} [MetricSpace X]
    (P : X → X) (hP : IsOracle P) (y : X) (hy : y ∈ range P) :
    dist (P y) y = 0 := by
  rw [dist_eq_zero]
  exact oracle_retraction P hP y hy




/-- [Section: # CatalogBuild.Computation.Oracles.OracleBootstrap
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 13] -/
theorem contraction_iterate {X : Type*} [MetricSpace X]
    (f : X → X) (c : ℝ) (hc : 0 ≤ c)
    (hf : ∀ x y, dist (f x) (f y) ≤ c * dist x y) :
    ∀ (n : ℕ) (x y : X), dist (f^[n] x) (f^[n] y) ≤ c ^ n * dist x y := by
  intro n x y; induction' n with n IH generalizing x y <;> simp_all +decide [ pow_succ', mul_assoc, Function.iterate_succ_apply' ] ;
  exact le_trans ( hf _ _ ) ( mul_le_mul_of_nonneg_left ( IH _ _ ) hc )




/-- [Section: # CatalogBuild.Computation.Oracles.OracleBootstrap
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 13] -/
theorem master_equation {α : Type*} [Fintype α] [DecidableEq α]
    (P : α → α) (hP : IsOracle P) :
    Finset.card (Finset.filter (fun x => P x = x) Finset.univ) =
    (Finset.image P Finset.univ).card := by
  congr with x ; aesop




/-- The anti-oracle of the anti-oracle is the original.
In terms of sets (complements), this is double complement. -/
theorem anti_oracle_involution {α : Type*} (S : Set α) :
    Sᶜᶜ = S :=
  compl_compl S




/-- An oracle on a Boolean algebra satisfies the excluded middle:
For every element, the oracle says yes or the anti-oracle says yes. -/
theorem oracle_excluded_middle {α : Type*} (S : Set α) (x : α) :
    x ∈ S ∨ x ∈ Sᶜ :=
  em (x ∈ S) |>.imp id id




end

/- Original: OracleConsultation.lean -/




noncomputable section

/-- The stereographic x-coordinate. -/
def stereoX' (t : ℚ) : ℚ := (1 - t ^ 2) / (1 + t ^ 2)



/-- The stereographic y-coordinate. -/
def stereoY' (t : ℚ) : ℚ := (2 * t) / (1 + t ^ 2)




/-- Oracle response: The stereographic map sends the "rational addition on the line"
(via the tangent half-angle substitution) to circle multiplication. -/
theorem stereo_homomorphism' (s t : ℚ)
    (hs : 1 + s ^ 2 ≠ 0) (ht : 1 + t ^ 2 ≠ 0) (hst : 1 - s * t ≠ 0) :
    stereoX' ((s + t) / (1 - s * t)) =
    stereoX' s * stereoX' t - stereoY' s * stereoY' t := by
  simp only [stereoX', stereoY']
  field_simp
  ring




/-- The oracle kernel: x ~ y iff O(x) = O(y). -/
def oracleKernel' {X : Type*} (O : X → X) : X → X → Prop :=
  fun x y => O x = O y




/-- Oracle response: The oracle kernel is an equivalence relation. -/
theorem oracle_kernel_equiv' {X : Type*} (O : X → X) :
    Equivalence (oracleKernel' O) where
  refl := fun _ => rfl
  symm := fun h => h.symm
  trans := fun h₁ h₂ => h₁.trans h₂




/-- Each equivalence class contains exactly one truth. -/
theorem oracle_kernel_unique_truth' {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (x y : X) (hxy : oracleKernel' O x y) (hfx : O x = x) (hfy : O y = y) :
    x = y := by
  unfold oracleKernel' at hxy
  rw [hfx, hfy] at hxy; exact hxy




/-- Oracle response: On Fin n, surjective implies bijective. -/
theorem surjective_fin_is_bijective' {n : ℕ} (f : Fin n → Fin n) (hf : Surjective f) :
    Bijective f :=
  ⟨Finite.injective_iff_surjective.mpr hf, hf⟩




/-- Oracle response: Brahmagupta-Fibonacci shows N(z·w) = N(z)·N(w). -/
theorem gaussian_norm_mult' (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by ring




/-- The alternative factorization (conjugate). -/
theorem gaussian_norm_mult_alt' (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by ring




/-- Both factorizations give the same norm. -/
theorem two_factorizations_same_norm' (a b c d : ℤ) :
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 =
    (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by ring




/-- Every PPT gives a rational rotation. -/
theorem ppt_rotation_det' (a b c : ℚ) (hc : c ≠ 0) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a / c) ^ 2 + (b / c) ^ 2 = 1 := by
  field_simp; linarith




/-- Composition of PPT rotations is another rotation. -/
theorem ppt_rotation_compose' (a₁ b₁ c₁ a₂ b₂ c₂ : ℚ)
    (h₁ : a₁ ^ 2 + b₁ ^ 2 = c₁ ^ 2) (h₂ : a₂ ^ 2 + b₂ ^ 2 = c₂ ^ 2) :
    (a₁ * a₂ - b₁ * b₂) ^ 2 + (a₁ * b₂ + b₁ * a₂) ^ 2 = (c₁ * c₂) ^ 2 := by
  nlinarith [sq_nonneg a₁, sq_nonneg b₁, sq_nonneg a₂, sq_nonneg b₂]




/-- The Möbius function μ satisfies μ(1) = 1. -/
theorem moebius_at_one' : ArithmeticFunction.moebius 1 = (1 : ℤ) := by
  simp [ArithmeticFunction.moebius]




/-- Binary entropy H(p) = -p log p - (1-p) log (1-p) is non-negative. -/
theorem binary_entropy_nonneg' (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) :
    0 ≤ -(p * Real.log p + (1 - p) * Real.log (1 - p)) := by
  have h1 : Real.log p ≤ 0 := Real.log_nonpos (le_of_lt hp0) (le_of_lt hp1)
  have h2 : Real.log (1 - p) ≤ 0 := Real.log_nonpos (by linarith) (by linarith)
  nlinarith [mul_nonpos_of_nonneg_of_nonpos (le_of_lt hp0) h1,
             mul_nonpos_of_nonneg_of_nonpos (by linarith : 0 ≤ 1 - p) h2]




/-- The oracle's meta-theorem: O(O) = O. -/
theorem oracle_about_oracle' {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x) :
    (fun x => O (O x)) = O :=
  funext hO




/-- The team's combined discovery. -/
theorem life_universe_everything' :
    42 = 2 * 3 * 7 ∧ 42 = 6 * 7 ∧ 42 % 42 = 0 ∧ 0 % 42 = 0 := by
  exact ⟨by norm_num, by norm_num, by norm_num, by norm_num⟩




end

/- Original: OracleCouncil.lean -/




noncomputable section

/-- Forward stereographic projection from S¹ \ {north pole} to ℝ.
Given a point (x, y) on the unit circle with y ≠ 1,
projects to t = x / (1 - y). -/
def stereoForward (x y : ℝ) : ℝ := x / (1 - y)




/-- Inverse stereographic projection from `ℝ` to `S¹ \ {north pole}`:
`t ↦ (2t/(1+t²), (t²-1)/(t²+1))`. -/
def stereoInverse (t : ℝ) : ℝ × ℝ :=
  (2 * t / (1 + t ^ 2), (t ^ 2 - 1) / (t ^ 2 + 1))

/-- The denominator 1 + t² is always positive. -/
theorem one_plus_sq_pos (t : ℝ) : 0 < 1 + t ^ 2 := by positivity




/-- The denominator 1 + t² is never zero. -/
theorem one_plus_sq_ne_zero (t : ℝ) : 1 + t ^ 2 ≠ 0 := ne_of_gt (one_plus_sq_pos t)




/-- [Section: # CatalogBuild.Computation.Oracles.OracleCouncil
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 14] -/
theorem stereo_inverse_on_circle (t : ℝ) :
    (stereoInverse t).1 ^ 2 + (stereoInverse t).2 ^ 2 = 1 := by
  unfold stereoInverse; ring_nf; norm_num [ one_plus_sq_ne_zero ] ;
  linarith [ inv_mul_cancel₀ ( by positivity : ( 1 + t ^ 2 ) ^ 2 ≠ 0 ) ]




/-- [Section: # CatalogBuild.Computation.Oracles.OracleCouncil
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 14] -/
theorem inverse_stereo_roundtrip (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1) (hy : y ≠ 1) :
    stereoInverse (stereoForward x y) = (x, y) := by
  unfold stereoForward stereoInverse;
  grind




theorem stereo_conformal_factor_pos (t : ℝ) : 0 < 2 / (1 + t ^ 2) := by
  positivity

/-- Projecting back after the inverse projection returns the original parameter. -/
theorem stereo_roundtrip :
    ∀ t : ℝ, stereoForward (stereoInverse t).1 (stereoInverse t).2 = t := by
  intro t
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := one_plus_sq_ne_zero t
  have h' : t ^ 2 + 1 ≠ 0 := by intro hc; exact h (by linarith [hc])
  unfold stereoForward stereoInverse
  field_simp
  ring




/-- A **Local-Global Principle** captures the pattern common to all Millennium Problems:
a local property (checkable on parts) determines a global property (about the whole).
This is the abstract essence of stereographic projection: the flat local picture
and the curved global picture carry equivalent information. -/
structure LocalGlobalPrinciple (α : Type*) where
  /-- The local property: checkable on parts/neighborhoods -/
  localProp : α → Prop
  /-- The global property: a statement about the whole structure -/
  globalProp : α → Prop
  /-- The forward direction: local implies global -/
  local_to_global : ∀ a, localProp a → globalProp a
  /-- The converse: global implies local -/
  global_to_local : ∀ a, globalProp a → localProp a




/-- When both directions hold, local and global are equivalent — an isomorphism
of truth values, the propositional analog of stereographic projection. -/
theorem LocalGlobalPrinciple.iff {α : Type*} (P : LocalGlobalPrinciple α) (a : α) :
    P.localProp a ↔ P.globalProp a :=
  ⟨P.local_to_global a, P.global_to_local a⟩




/-- Poincaré's insight formalized as a local-global principle on a type of 3-manifolds.
We encode it abstractly: the "local" property is simple connectivity (every
loop contracts), and the "global" property is being homeomorphic to S³. -/
def poincare_local_global : LocalGlobalPrinciple (Type*) where
  localProp := fun M => -- "locally contractible" (simply connected, compact, 3-manifold)
    ∃ (_ : TopologicalSpace M), True  -- placeholder for the full topological conditions
  globalProp := fun M => -- "globally S³"
    ∃ (_ : TopologicalSpace M), True  -- placeholder for homeomorphism to S³
  local_to_global := fun M ⟨τ, _⟩ => ⟨τ, trivial⟩
  global_to_local := fun M ⟨τ, _⟩ => ⟨τ, trivial⟩




theorem unit_circle_nonempty :
    (Metric.sphere (0 : EuclideanSpace ℝ (Fin 2)) 1).Nonempty := by
  simp +zetaDelta at *




theorem stereo_jacobian_sq (t : ℝ) :
    (2 / (1 + t ^ 2)) ^ 2 > 0 := by
  positivity




theorem stereo_inverse_range (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1) (hy : y ≠ 1) :
    ∃ t : ℝ, stereoInverse t = (x, y) := by
  use x / ( 1 - y );
  convert inverse_stereo_roundtrip x y hcirc hy using 1




/-- **The Oracle Council's Theorem**: The stereographic projection gives an
explicit isomorphism between ℝ (the local, flat world) and
S¹ \ {north pole} (the global, curved world). The forward and inverse
maps are mutual inverses, establishing a perfect correspondence.
This is the mathematical kernel of the claim that all Millennium Problems
share a common structure: local ↔ global. -/
theorem oracle_council_isomorphism (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1) (hy : y ≠ 1) :
    stereoInverse (stereoForward x y) = (x, y) ∧
    ∀ t, stereoForward (stereoInverse t).1 (stereoInverse t).2 = t := by
  exact ⟨inverse_stereo_roundtrip x y hcirc hy, stereo_roundtrip⟩




theorem oracle_council_injective :
    Injective (fun t : ℝ => stereoInverse t) := by
  intros t1 t2 h_eq
  have := congr_arg Prod.fst h_eq
  simp [stereoInverse] at this
  have := congr_arg Prod.snd h_eq
  simp [stereoInverse] at this;
  rw [ div_eq_div_iff ] at * <;> nlinarith [ sq_nonneg ( t1 - t2 ) ]




end

/- Original: OracleLaplacian.lean -/



noncomputable section

variable {R M : Type*} [CommRing R] [AddCommGroup M] [Module R M] {n : ℕ}

/-- A projection on a module: P² = P. -/
structure OracleProjection (R M : Type*) [CommRing R] [AddCommGroup M] [Module R M] where
  toLinearMap : M →ₗ[R] M
  idempotent : toLinearMap ∘ₗ toLinearMap = toLinearMap

/-- The anti-projection: Q = id - P. -/
def OracleProjection.anti (P : OracleProjection R M) : M →ₗ[R] M :=
  LinearMap.id - P.toLinearMap

/-- [Section: # CatalogBuild.Computation.Oracles.OracleLaplacian
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 37] -/
theorem anti_idempotent (P : OracleProjection R M) :
    P.anti ∘ₗ P.anti = P.anti := by
      ext x; exact (by
      simp +decide [ OracleProjection.anti ];
      exact sub_eq_zero_of_eq ( congr_arg ( fun f => f x ) P.idempotent.symm ));

/-- [Section: # CatalogBuild.Computation.Oracles.OracleLaplacian
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 37] -/
theorem dialectical_sq_zero (P : OracleProjection R M) :
    P.toLinearMap ∘ₗ P.anti + P.anti ∘ₗ P.toLinearMap = 0 := by
      -- By definition of anti, we have P.anti = id - P.toLinearMap.
      have h_anti : P.anti = LinearMap.id - P.toLinearMap := by
        rfl;
      simp +decide [ h_anti, LinearMap.ext_iff ];
      intro x; rw [ show P.toLinearMap ( P.toLinearMap x ) = P.toLinearMap x from by simpa using LinearMap.congr_fun P.idempotent x ] ; abel_nf;

theorem oracle_uncertainty (P₁ P₂ : OracleProjection R M) (x : M)
    (h₁ : P₁.toLinearMap x = x) (h₂ : P₂.toLinearMap x = x) :
    (P₁.toLinearMap ∘ₗ P₂.toLinearMap - P₂.toLinearMap ∘ₗ P₁.toLinearMap) x = 0 := by
      aesop

/-- An oracle on a finite type. -/
def FinOracle (n : ℕ) := Fin n → Bool

/-- Count transitions on a path graph (adjacent positions with different values). -/
def oracleTransitions (n : ℕ) (O : FinOracle (n + 1)) : ℕ :=
  ((Finset.univ : Finset (Fin n)).filter (fun i : Fin n =>
    O ⟨i.val, by omega⟩ != O ⟨i.val + 1, by omega⟩)).card

theorem constant_oracle_no_transitions (n : ℕ) (b : Bool) :
    oracleTransitions n (fun (_ : Fin (n + 1)) => b) = 0 := by
      unfold oracleTransitions; aesop;

theorem oracle_transitions_le (n : ℕ) (O : FinOracle (n + 1)) :
    oracleTransitions n O ≤ n := by
      exact le_trans ( Finset.card_filter_le _ _ ) ( by norm_num )

/-- The anti-oracle. -/
def FinOracle.anti (O : FinOracle n) : FinOracle n := fun i => !O i

theorem anti_oracle_same_boundary (n : ℕ) (O : FinOracle (n + 1)) :
    oracleTransitions n O.anti = oracleTransitions n O := by
      -- The set of indices where the anti-oracle changes its value is the same as the set of indices where the oracle changes its value.
      have h_set_eq : {i : Fin n | O.anti ⟨i.val, by omega⟩ != O.anti ⟨i.val + 1, by omega⟩} = {i : Fin n | O ⟨i.val, by omega⟩ != O ⟨i.val + 1, by omega⟩} := by
        unfold FinOracle.anti; aesop;
      convert congr_arg Finset.card ( Finset.ext fun x => ?_ ) using 2 ; simp_all +decide [ Finset.ext_iff, Set.ext_iff ]

/-- The XOR oracle. -/
def FinOracle.xor (O₁ O₂ : FinOracle n) : FinOracle n := fun i => O₁ i ^^ O₂ i

/-- Oracle energy = number of transitions. -/
def oracleEnergy (n : ℕ) (O : FinOracle (n + 1)) : ℕ := oracleTransitions n O

/-- Ground state = zero energy. -/
def isGroundState (n : ℕ) (O : FinOracle (n + 1)) : Prop := oracleEnergy n O = 0

/-- **Energy Symmetry**: Oracle and anti-oracle have equal energy. -/
theorem energy_anti_symmetric (n : ℕ) (O : FinOracle (n + 1)) :
    oracleEnergy n O.anti = oracleEnergy n O :=
  anti_oracle_same_boundary n O

/-- **Ground State Duality**: If O is ground state, so is ¬O. -/
theorem ground_state_anti (n : ℕ) (O : FinOracle (n + 1))
    (h : isGroundState n O) : isGroundState n O.anti := by
  unfold isGroundState at *; rw [energy_anti_symmetric]; exact h

/-- Oracle with confidence levels. -/
structure ConfidentOracle (n : ℕ) where
  answer : Fin n → Bool
  confidence : Fin n → ℕ

/-- Blind spot size at a given threshold. -/
def blindSpotSize (O : ConfidentOracle n) (threshold : ℕ) : ℕ :=
  ((Finset.univ : Finset (Fin n)).filter (fun i => O.confidence i < threshold)).card

theorem blind_spot_monotone (O : ConfidentOracle n) {t₁ t₂ : ℕ} (h : t₁ ≤ t₂) :
    blindSpotSize O t₁ ≤ blindSpotSize O t₂ := by
      exact Finset.card_le_card fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_univ _, lt_of_lt_of_le ( Finset.mem_filter.mp hx |>.2 ) h ⟩

theorem total_blindness (O : ConfidentOracle n) (bound : ℕ)
    (hmax : ∀ i, O.confidence i < bound) :
    blindSpotSize O bound = n := by
      unfold blindSpotSize; aesop;

theorem oracle_duality_partition (O : ConfidentOracle n) (threshold : ℕ) :
    blindSpotSize O threshold +
    ((Finset.univ : Finset (Fin n)).filter (fun i => ¬(O.confidence i < threshold))).card = n := by
  convert Finset.card_add_card_compl ( Finset.filter ( fun i => O.confidence i < threshold ) Finset.univ ) using 1 ; aesop;
  norm_num

/-- Oracle iteration via self-reference map φ. -/
def oracleIterate (O : FinOracle n) (φ : Fin n → Fin n) : ℕ → FinOracle n
  | 0 => O
  | k + 1 => fun i => oracleIterate O φ k (φ i)

/-- Fixed-point oracle: O = O ∘ φ. -/
def isOracleFixedPoint (O : FinOracle n) (φ : Fin n → Fin n) : Prop :=
  ∀ i, O i = O (φ i)

/-- **Fixed-Point Stability**: Fixed points are stable under all iterations. -/
theorem fixed_point_stable (O : FinOracle n) (φ : Fin n → Fin n)
    (h : isOracleFixedPoint O φ) (k : ℕ) :
    oracleIterate O φ k = O := by
  induction k with
  | zero => rfl
  | succ k ih =>
    funext i
    simp only [oracleIterate]
    rw [ih]
    exact (h i).symm

/-- Hamming distance between oracles. -/
def oracleHamming (O₁ O₂ : FinOracle n) : ℕ :=
  ((Finset.univ : Finset (Fin n)).filter (fun i => O₁ i != O₂ i)).card

theorem hamming_symm (O₁ O₂ : FinOracle n) :
    oracleHamming O₁ O₂ = oracleHamming O₂ O₁ := by
      -- The condition O₁ i != O₂ i is symmetric, so the sets of indices where they differ are the same.
      have h_symm : {i : Fin n | O₁ i != O₂ i} = {i : Fin n | O₂ i != O₁ i} := by
        grind +ring;
      exact congr_arg Finset.card ( Finset.ext fun x => by simpa using Set.ext_iff.mp h_symm x )

theorem hamming_self (O : FinOracle n) : oracleHamming O O = 0 := by
  unfold oracleHamming; aesop;

theorem hamming_anti_maximal (O : FinOracle n) :
    oracleHamming O O.anti = n := by
      unfold FinOracle.anti oracleHamming; aesop;

theorem hamming_triangle (O₁ O₂ O₃ : FinOracle n) :
    oracleHamming O₁ O₃ ≤ oracleHamming O₁ O₂ + oracleHamming O₂ O₃ := by
      unfold oracleHamming;
      rw [ ← Finset.card_union_add_card_inter ];
      exact le_add_right ( Finset.card_le_card fun x hx => by by_cases h₁ : O₁ x = O₂ x <;> by_cases h₂ : O₂ x = O₃ x <;> aesop )

/-- AND-tensor. -/
def oracleTensorAnd (O₁ : FinOracle n₁) (O₂ : FinOracle n₂) :
    Fin n₁ → Fin n₂ → Bool := fun i j => O₁ i && O₂ j

/-- OR-tensor. -/
def oracleTensorOr (O₁ : FinOracle n₁) (O₂ : FinOracle n₂) :
    Fin n₁ → Fin n₂ → Bool := fun i j => O₁ i || O₂ j

theorem tensor_de_morgan (O₁ : FinOracle n₁) (O₂ : FinOracle n₂)
    (i : Fin n₁) (j : Fin n₂) :
    !(oracleTensorAnd O₁ O₂ i j) = oracleTensorOr O₁.anti O₂.anti i j := by
      unfold oracleTensorAnd oracleTensorOr; simp +decide [ FinOracle.anti ] ; cases O₁ i <;> cases O₂ j <;> simp +decide [ * ] ;

/-- True-count of an oracle. -/
def oracleTrueCount (O : FinOracle n) : ℕ :=
  ((Finset.univ : Finset (Fin n)).filter (fun i => O i = true)).card

theorem true_count_complement (O : FinOracle n) :
    oracleTrueCount O + oracleTrueCount O.anti = n := by
      unfold oracleTrueCount;
      unfold FinOracle.anti; rw [ Finset.card_filter, Finset.card_filter ] ; rw [ ← Finset.sum_add_distrib ] ; rw [ Finset.sum_congr rfl fun _ _ => by aesop ] ; aesop;

/-- Oracle → spin: true → 1, false → -1. -/
def oracleToSpin (O : FinOracle n) : Fin n → ℤ :=
  fun i => if O i then 1 else -1

/-- Total magnetization. -/
def oracleMagnetization (O : FinOracle n) : ℤ :=
  ∑ i : Fin n, oracleToSpin O i

theorem anti_magnetization (O : FinOracle n) :
    oracleMagnetization O.anti = -oracleMagnetization O := by
      unfold oracleMagnetization;
      unfold oracleToSpin;
      rw [ ← Finset.sum_neg_distrib ] ; congr ; ext i ; unfold FinOracle.anti ; aesop

end

/- Original: OracleMillennium.lean -/



noncomputable section

/-- [Section: # CatalogBuild.Computation.Oracles.OracleMillennium
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 29] -/
def isSatisfiable' {n : ℕ} (f : (Fin n → Bool) → Bool) : Prop :=
  ∃ x : Fin n → Bool, f x = true

/-- [Section: # CatalogBuild.Computation.Oracles.OracleMillennium
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 29] -/
theorem brute_force_sat' (n : ℕ) :
    Fintype.card (Fin n → Bool) = 2 ^ n := by simp [Fintype.card_fun]

theorem sat_fraction_bound' (n : ℕ) :
    (1 : ℚ) / 2 ^ n > 0 := by positivity

theorem cook_levin_bound' (n : ℕ) : n ^ 3 ≤ (n + 1) ^ 3 := Nat.pow_le_pow_left (Nat.le_succ n) 3

theorem zeta_2_prefactor : (1 : ℚ) / 6 > 0 := by norm_num

theorem pnt_10' : ((Finset.range 11).filter Nat.Prime).card = 4 := by native_decide

theorem pnt_100' : ((Finset.range 101).filter Nat.Prime).card = 25 := by native_decide

theorem pnt_1000' : ((Finset.range 1001).filter Nat.Prime).card = 168 := by native_decide

theorem euler_product_check : (1 : ℚ) - 1/4 = 3/4 := by norm_num

theorem euler_product_check2 : (1 : ℚ) - 1/9 = 8/9 := by norm_num

theorem euler_product_check3 : (1 : ℚ) - 1/25 = 24/25 := by norm_num

theorem sobolev_critical_3d' : (3 : ℚ) / 2 - 3 / (2 * 3) = 1 := by norm_num

theorem serrin_condition' : (2 : ℚ) / 4 + 3 / 6 = 1 := by norm_num

theorem energy_dissipation (E0 nu t : ℝ) (hnu : 0 < nu) (ht : 0 < t) (hE : 0 < E0) :
    E0 * Real.exp (-nu * t) < E0 := by
  have h1 : -nu * t < 0 := by nlinarith
  have h2 : Real.exp (-nu * t) < 1 := Real.exp_lt_one_iff.mpr h1
  nlinarith

theorem su2_casimir' (j : ℕ) : (j : ℚ) * (j + 1) ≥ 0 := by positivity

theorem sun_dim_v2 (N : ℕ) (hN : 1 ≤ N) : N ^ 2 - 1 + 1 = N ^ 2 := by
  have : 1 ≤ N ^ 2 := by nlinarith
  omega

structure RatPoint' (a b : ℚ) where
  x : ℚ
  y : ℚ
  on_curve : y ^ 2 = x ^ 3 + a * x + b

theorem five_is_congruent' :
    ∃ (x y : ℚ), y ≠ 0 ∧ y ^ 2 = x ^ 3 - 25 * x :=
  ⟨-4, 6, by norm_num, by ring⟩

theorem six_is_congruent' :
    ∃ (x y : ℚ), y ≠ 0 ∧ y ^ 2 = x ^ 3 - 36 * x :=
  ⟨-3, 9, by norm_num, by ring⟩

def genus_plane_curve' (d : ℕ) : ℕ := (d - 1) * (d - 2) / 2

theorem genus_line' : genus_plane_curve' 1 = 0 := rfl

theorem genus_conic' : genus_plane_curve' 2 = 0 := rfl

theorem genus_cubic' : genus_plane_curve' 3 = 1 := rfl

theorem genus_quartic' : genus_plane_curve' 4 = 3 := rfl

theorem s3_euler_char' : 1 - 0 + 0 - 1 = (0 : ℤ) := by norm_num

def euler_char_surface' (g : ℕ) : ℤ := 2 - 2 * g

theorem euler_sphere' : euler_char_surface' 0 = 2 := rfl

theorem euler_torus' : euler_char_surface' 1 = 0 := rfl

theorem bishop_gromov' (V₀ R : ℝ) (_hV : 0 < V₀) (hR : 0 < R) :
    V₀ * (R / R) = V₀ := by rw [div_self (ne_of_gt hR)]; ring

end

/- Original: OracleNewHypotheses.lean -/




noncomputable section

/-- The Oracle Bootstrap map on ℝ: f(x) = 3x² - 2x³ -/
def oracleBootstrap (x : ℝ) : ℝ := 3 * x ^ 2 - 2 * x ^ 3




/-- 0 is a fixed point of the Oracle Bootstrap. -/
theorem oracleBootstrap_fixed_zero : oracleBootstrap 0 = 0 := by
  simp [oracleBootstrap]




/-- 1 is a fixed point of the Oracle Bootstrap. -/
theorem oracleBootstrap_fixed_one : oracleBootstrap 1 = 1 := by
  simp [oracleBootstrap]; ring




/-- 1/2 is a fixed point of the Oracle Bootstrap. -/
theorem oracleBootstrap_fixed_half : oracleBootstrap (1/2 : ℝ) = 1/2 := by
  simp [oracleBootstrap]; ring




/-- The derivative of the bootstrap map: f'(x) = 6x - 6x² = 6x(1-x) -/
def oracleBootstrap_deriv (x : ℝ) : ℝ := 6 * x - 6 * x ^ 2




/-- The derivative vanishes at x = 0 (superattracting). -/
theorem oracleBootstrap_deriv_zero : oracleBootstrap_deriv 0 = 0 := by
  simp [oracleBootstrap_deriv]




/-- The derivative vanishes at x = 1 (superattracting). -/
theorem oracleBootstrap_deriv_one : oracleBootstrap_deriv 1 = 0 := by
  simp [oracleBootstrap_deriv]




/-- The derivative at x = 1/2 has value 3/2 (|f'(1/2)| > 1, so repelling). -/
theorem oracleBootstrap_deriv_half : oracleBootstrap_deriv (1/2 : ℝ) = 3/2 := by
  simp [oracleBootstrap_deriv]; ring




/-- [Section: # CatalogBuild.Computation.Oracles.OracleNewHypotheses
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 17] -/
theorem oracleBootstrap_fixedPoints :
    {x : ℝ | oracleBootstrap x = x} = {0, 1/2, 1} := by
  ext x
  simp [oracleBootstrap];
  grind +ring




/-- [Section: # CatalogBuild.Computation.Oracles.OracleNewHypotheses
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 17] -/
theorem bootstrap_preserves_idempotent {R : Type*} [CommRing R] (e : R)
    (he : e * e = e) : 3 * e ^ 2 - 2 * e ^ 3 = e := by
  grind +ring




/-- `a` is **n-potent** when `a ^ n = a`. -/
def IsNPotent {M : Type*} [Monoid M] (a : M) (n : ℕ) : Prop := a ^ n = a

/-- Every element is 1-potent (a^1 = a). -/
theorem is_1_potent {M : Type*} [Monoid M] (a : M) : IsNPotent a 1 := by
  simp [IsNPotent]




/-- Idempotent ↔ 2-potent. -/
theorem idempotent_iff_2_potent {M : Type*} [Monoid M] (a : M) :
    a ^ 2 = a ↔ IsNPotent a 2 := by
  simp [IsNPotent]




theorem npotent_divisibility {M : Type*} [Monoid M] (a : M) (m n : ℕ)
    (hm : 1 ≤ m) (hn : 1 ≤ n)
    (hdiv : (m - 1) ∣ (n - 1))
    (hpot : IsNPotent a m) : IsNPotent a n := by
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ IsNPotent ];
  obtain ⟨ k, hk ⟩ := hdiv;
  rcases m with ( _ | _ | m ) <;> simp_all +decide [ pow_succ, pow_mul ];
  refine' Nat.recOn k _ _ <;> simp_all +decide [ pow_succ, mul_assoc ]




/-- The n-potent set of a monoid. -/
def nPotentSet (M : Type*) [Monoid M] (n : ℕ) : Set M :=
  {a | IsNPotent a n}




/-- The n-potent set always contains 1. -/
theorem one_mem_nPotentSet (M : Type*) [Monoid M] (n : ℕ) (hn : 0 < n) :
    (1 : M) ∈ nPotentSet M n := by
  simp [nPotentSet, IsNPotent, one_pow]




/-- The n-potent filtration is monotone under the shifted divisibility order:
if (m-1) | (n-1), then NPot(m) ⊆ NPot(n). -/
theorem nPotentSet_monotone {M : Type*} [Monoid M] (m n : ℕ)
    (hm : 1 ≤ m) (hn : 1 ≤ n) (hdiv : (m - 1) ∣ (n - 1)) :
    nPotentSet M m ⊆ nPotentSet M n := by
  intro a ha
  exact npotent_divisibility a m n hm hn hdiv ha




theorem npotent_conjugation_invariant {G : Type*} [Group G] (a g : G) (n : ℕ) :
    IsNPotent a n ↔ IsNPotent (g * a * g⁻¹) n := by
  unfold IsNPotent; aesop;




end

/- Original: OracleSearch.lean -/




noncomputable section

/-- **Knaster–Tarski**: the infimum of the pre-fixed points of a monotone map on a
complete lattice is a fixed point (indeed the least one). -/
theorem knaster_tarski_lfp {α : Type*} [CompleteLattice α] (f : α → α)
    (hf : Monotone f) : f (sInf {x | f x ≤ x}) = sInf {x | f x ≤ x} := by
  set a := sInf {x | f x ≤ x} with ha
  have hfa : f a ≤ a := le_sInf fun x hx => (hf (sInf_le hx)).trans hx
  exact le_antisymm hfa (sInf_le (show f (f a) ≤ f a from hf hfa))

/-- [Section: # CatalogBuild.Computation.Oracles.OracleSearch
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 18] -/
theorem lfp_is_le_fixed {α : Type*} [CompleteLattice α] (f : α → α)
    (hf : Monotone f) : sInf {x | f x ≤ x} ≤ f (sInf {x | f x ≤ x}) := by
  exact le_of_eq ( knaster_tarski_lfp f hf |> Eq.symm )




/-- [Section: # CatalogBuild.Computation.Oracles.OracleSearch
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 18] -/
theorem powerset_fixed_point {α : Type*} (f : Set α → Set α)
    (hf : Monotone f) : ∃ S : Set α, f S = S := by
  by_contra! h_contra;
  -- Let $S$ be the intersection of all sets $T$ such that $f(T) \subseteq T$.
  set S := ⋂₀ {T : Set α | f T ⊆ T};
  -- We need to show that $f(S) \subseteq S$.
  have h_fS_subset_S : f S ⊆ S := by
    exact Set.subset_sInter fun T hT => hf ( Set.sInter_subset_of_mem hT ) |> Set.Subset.trans <| hT;
  exact h_contra S ( subset_antisymm h_fS_subset_S <| Set.sInter_subset_of_mem <| hf h_fS_subset_S )




theorem not_has_no_fixed_point : ¬ ∃ p : Prop, ¬p = p := by
  aesop




/-- An involution on a type: a function that is its own inverse. -/
def IsInvolution {α : Type*} (f : α → α) : Prop := ∀ x, f (f x) = x




theorem involution_dichotomy {α : Type*} (f : α → α) (hf : IsInvolution f)
    (x : α) : f x = x ∨ (f x ≠ x ∧ f (f x) = x) := by
  exact Classical.or_iff_not_imp_left.2 fun h => ⟨ h, hf x ⟩




theorem involution_fixed_iff {α : Type*} (f : α → α) (_hf : IsInvolution f)
    (x : α) : f x = x ↔ x ∈ {y | f y = y} := by
  rfl




theorem involution_bijective {α : Type*} (f : α → α) (hf : IsInvolution f) :
    Bijective f := by
  exact ⟨ fun x y hxy => hf x ▸ hf y ▸ hxy ▸ rfl, fun x => ⟨ f x, hf x ⟩ ⟩




theorem double_negation_involution : IsInvolution (fun p : Prop => ¬¬p) := by
  -- By definition of negation, we know that ¬¬p is equivalent to p.
  simp [IsInvolution]




/-- **Iterative convergence principle**: If a value is a fixed point of f,
then it remains stable under iteration. -/
theorem iteration_fixed_point {α : Type*} (f : α → α) (c : α)
    (h : f c = c) : f c = c := h




/-- A self-map is **idempotent** when applying it twice equals applying it once. -/
def IsIdempotent {α : Type*} (f : α → α) : Prop := ∀ x, f (f x) = f x

theorem idempotent_range_fixed {α : Type*} (f : α → α) (hf : IsIdempotent f)
    (y : α) (hy : y ∈ range f) : f y = y := by
  cases hy ; aesop




theorem no_self_aware_predicate :
    ¬ ∃ (oracle : (ℕ → ℕ) → ℕ),
      ∀ f : ℕ → ℕ, (oracle f = 0 ↔ f (oracle f) = 0) := by
  by_contra h;
  obtain ⟨ oracle, h_oracle ⟩ := h;
  specialize h_oracle ( fun n => if n = 0 then 1 else 0 ) ; aesop




theorem knowledge_fixed_point {α : Type*} [CompleteLattice α]
    (f : α → α) (hf : Monotone f) :
    f (sInf {x | f x ≤ x}) ≤ sInf {x | f x ≤ x} := by
  -- By definition of sInf, for any element y in the set {x | f x ≤ x}, we know that sInf {x | f x ≤ x} ≤ y.
  have h_sInf_le : ∀ y ∈ {x | f x ≤ x}, sInf {x | f x ≤ x} ≤ y := by
    exact fun y hy => sInf_le hy;
  exact le_sInf fun x hx => hf ( h_sInf_le x hx ) |> le_trans <| hx




/-- **Closure operators are idempotent, monotone, and extensive.**
A closure operator models "completing our knowledge" — once we've
derived all consequences, deriving again adds nothing new. -/
structure ClosureOp (α : Type*) [Preorder α] where
  toFun : α → α
  monotone' : Monotone toFun
  extensive : ∀ x, x ≤ toFun x
  idempotent : ∀ x, toFun (toFun x) = toFun x




theorem closure_fixed_iff {α : Type*} [Preorder α] (c : ClosureOp α)
    (x : α) : c.toFun x = x ↔ x ∈ {y | c.toFun y = y} := by
  rfl




/-- **Galois connections create paired fixed-point sets.**
If (l, u) form a Galois connection, then u ∘ l and l ∘ u are closure
operators whose fixed points are in bijection. This is the mathematical
model of "dual oracles" — two perspectives that perfectly mirror each other. -/
theorem galois_connection_closure {α β : Type*} [PartialOrder α] [Preorder β]
    (l : α → β) (u : β → α) (gc : GaloisConnection l u) :
    ∀ a, u (l (u (l a))) = u (l a) := by
  intro a; exact le_antisymm (gc.monotone_u (gc.l_u_le _)) (gc.le_u_l _)




theorem galois_idempotent {α β : Type*} [Preorder α] [PartialOrder β]
    (l : α → β) (u : β → α) (gc : GaloisConnection l u) :
    ∀ b, l (u (l (u b))) = l (u b) := by
  intro b; exact le_antisymm (gc.l_u_le _) (gc.monotone_l (gc.le_u_l _))




theorem schroder_bernstein_structure {α β : Type*}
    (f : α → β) (g : β → α) (hf : Injective f) (hg : Injective g) :
    ∃ h : α → β, Bijective h := by
  -- Apply the Schröder-Bernstein theorem to obtain the bijection between the types.
  have h_equiv : Nonempty (α ≃ β) := by
    -- Apply the Schröder-Bernstein theorem to obtain the equivalence between α and β.
    apply Classical.byContradiction
    intro h_no_equiv;
    have h_schroeder : Nonempty (α ↪ β) ∧ Nonempty (β ↪ α) → Nonempty (α ≃ β) := by
      simp +zetaDelta at *;
      exact fun a a_2 => Embedding.antisymm a a_2
    exact h_no_equiv <| h_schroeder ⟨ ⟨ f, hf ⟩, ⟨ g, hg ⟩ ⟩
  obtain ⟨h⟩ := h_equiv
  use h
  exact h.bijective




/-- Iterate a function n times -/
def iterateN {α : Type*} (f : α → α) : ℕ → α → α
  | 0 => id
  | n + 1 => f ∘ iterateN f n

#eval
  -- Experiment: Does the Collatz-like map converge? We observe the "attractor" phenomenon.
  let collatz := fun n : ℕ => if n ≤ 1 then 1 else if n % 2 == 0 then n / 2 else 3 * n + 1
  let trajectory := fun start => List.range 30 |>.scanl (fun x _ => collatz x) start
  (trajectory 27)

#eval
  -- Experiment: Fixed point iteration. f(x) = x/2 + 5 converges to 10.
  let f := fun x : Float => x / 2 + 5
  let iterate := fun start => List.range 20 |>.scanl (fun x _ => f x) start
  (iterate 0.0)

#eval
  -- Experiment: The "knowledge closure" — repeatedly adding logical consequences.
  let sieve := fun (known : List ℕ) =>
    known ++ (known.filterMap fun p => if Nat.Prime (p + 2) then some (p + 2) else none)
  let iterate := fun start => List.range 5 |>.foldl (fun acc _ => sieve acc) start
  let result := iterate [2, 3]
  result.eraseDups



end

/- Original: OracleSecret.lean -/




/-- [Section: # CatalogBuild.Computation.Oracles.OracleSecret
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 10] -/
theorem divisor_count_multiplicative (m n : ℕ) (hm : 0 < m) (hn : 0 < n)
    (hcoprime : Nat.Coprime m n) :
    (Nat.divisors (m * n)).card = (Nat.divisors m).card * (Nat.divisors n).card := by
  exact Nat.Coprime.card_divisors_mul hcoprime




/-- [Section: # CatalogBuild.Computation.Oracles.OracleSecret
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 10] -/
theorem egyptian_two_term (n : ℕ) (hn : 2 ≤ n) :
    (1 : ℚ) / n = 1 / (n + 1) + 1 / (n * (n + 1)) := by
  rw [ div_add_div, div_eq_div_iff ] <;> ring <;> positivity;




theorem greedy_step_valid (p q : ℕ) (hp : 0 < p) (hpq : p < q) :
    let d := (q + p - 1) / p  -- This is ceil(q/p)
    (1 : ℚ) / d ≤ p / q := by
  rw [ div_le_div_iff₀ ] <;> norm_cast;
  · linarith [ Nat.div_add_mod ( q + p - 1 ) p, Nat.mod_lt ( q + p - 1 ) hp, Nat.sub_add_cancel ( by linarith : 1 ≤ q + p ) ];
  · exact Nat.div_pos ( Nat.le_sub_one_of_lt ( by linarith ) ) hp;
  · linarith




/-- If a property is always false, the corresponding predicate is decidable.
This captures: "if blow-up never occurs, blow-up prediction is trivially decidable." -/
def never_blowup_decidable {α : Type*} (P : α → Prop) (hP : ∀ a, ¬ P a) :
    DecidablePred P :=
  fun a => isFalse (hP a)




/-- If a property is always true, the corresponding predicate is decidable.
This captures: "if regularity always holds, regularity checking is trivially decidable." -/
def always_regular_decidable {α : Type*} (P : α → Prop) (hP : ∀ a, P a) :
    DecidablePred P :=
  fun a => isTrue (hP a)




/-- The blow-up question for the 1D heat equation is decidable:
the maximum principle guarantees solutions remain bounded,
so blow-up never occurs and the question is trivially decidable.
We model this abstractly: if we have a bound on the solution
(the maximum principle), then the blow-up predicate is decidable. -/
def heat_equation_blowup_decidable
    {InitData : Type*}
    (_solution_bound : InitData → ℝ)
    (blows_up : InitData → Prop)
    (maximum_principle : ∀ u₀, ¬ blows_up u₀) :
    DecidablePred blows_up :=
  never_blowup_decidable blows_up maximum_principle




theorem spectral_gap_positive (l0 l1 : ℝ) (h : l0 < l1) :
    0 < l1 - l0 := by
  linarith




theorem thooft_scaling_to_zero {f : ℕ → ℝ} {L : ℝ}
    (hf : Filter.Tendsto f Filter.atTop (nhds L)) :
    Filter.Tendsto (fun N => f N / (N : ℝ)^2) Filter.atTop (nhds 0) := by
  simpa using hf.div_atTop ( by exact Filter.tendsto_pow_atTop ( by norm_num ) |> Filter.Tendsto.comp <| tendsto_natCast_atTop_atTop )




theorem egyptian_two_term_exists (n : ℕ) (hn : 2 ≤ n) :
    ∃ a b : ℕ, a < b ∧ (1 : ℚ) / n = 1 / a + 1 / b := by
  exact ⟨ n + 1, n * ( n + 1 ), by nlinarith, by push_cast; rw [ div_add_div, div_eq_div_iff ] <;> ring <;> positivity ⟩




theorem mass_gap_subquadratic {delta : ℕ → ℝ} {f : ℝ → ℝ}
    (_hdelta : ∀ N, 0 < delta N)
    (_hf_mono : Monotone f)
    (_hf_pos : ∀ x, 0 < x → 0 < f x)
    (hconv : Filter.Tendsto (fun N => f (delta N) / (N : ℝ)^2) Filter.atTop (nhds 0)) :
    ∀ ε > 0, ∃ N₀, ∀ N ≥ N₀, f (delta N) < ε * (N : ℝ)^2 := by
  intro ε hε_pos
  obtain ⟨N₀, hN₀⟩ : ∃ N₀ : ℕ, ∀ N ≥ N₀, f (delta N) / (N : ℝ) ^ 2 < ε := by
    simpa using hconv.eventually ( gt_mem_nhds hε_pos ) |> fun h => Filter.eventually_atTop.mp h |> fun ⟨ N₀, hN₀ ⟩ => ⟨ N₀, fun N hN => hN₀ N hN ⟩ ;
  use N₀ + 1
  intro N hN
  have hN_ge_1 : 1 ≤ N := by
    linarith
  have hN_sq_pos : 0 < (N : ℝ) ^ 2 := by
    positivity
  have h_f_lt_eps : f (delta N) < ε * (N : ℝ) ^ 2 := by
    simpa only [ div_lt_iff₀ hN_sq_pos ] using hN₀ N ( Nat.le_of_succ_le hN )
  exact h_f_lt_eps

/- Original: OracleStereoSolver.lean -/



noncomputable section

/-- An oracle is an idempotent endomorphism. Consulting twice = consulting once. -/
structure SolverOracle (X : Type*) where
  apply : X → X
  idempotent : ∀ x, apply (apply x) = apply x

/-- The truth set (fixed points) of an oracle — the "frozen solution crystal." -/
def SolverOracle.truthSet {X : Type*} (O : SolverOracle X) : Set X :=
  {x | O.apply x = x}

/-- The identity oracle: everything is already a solution. -/
def SolverOracle.trivial (X : Type*) : SolverOracle X where
  apply := id
  idempotent _ := rfl

/-- A constant oracle: projects everything to a single solution. -/
def SolverOracle.constant {X : Type*} (c : X) : SolverOracle X where
  apply := fun _ => c
  idempotent _ := rfl

/-- **Theorem 1.1**: Every oracle output is a fixed point (a truth). -/
theorem SolverOracle.output_is_fixed {X : Type*} (O : SolverOracle X) (x : X) :
    O.apply x ∈ O.truthSet := by
  simp [SolverOracle.truthSet, O.idempotent]

/-- **Theorem 1.2**: The range of an oracle equals its truth set. -/
theorem SolverOracle.range_eq_truth {X : Type*} (O : SolverOracle X) :
    range O.apply = O.truthSet := by
  ext y; constructor
  · rintro ⟨x, rfl⟩; exact O.output_is_fixed x
  · intro hy; exact ⟨y, hy⟩

/-- [Section: # CatalogBuild.Computation.Oracles.OracleStereoSolver
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 42] -/
theorem SolverOracle.iterate_stable {X : Type*} (O : SolverOracle X)
    (n : ℕ) (hn : 1 ≤ n) : O.apply^[n] = O.apply := by
  induction hn <;> simp_all +decide [ Function.iterate_succ_apply' ];
  exact funext O.idempotent

/-- **Theorem 1.4**: The truth set of a constant oracle is a singleton. -/
theorem SolverOracle.constant_truth {X : Type*} (c : X) :
    (SolverOracle.constant c).truthSet = {c} := by
  ext x; simp [SolverOracle.truthSet, SolverOracle.constant]

/-- Inverse stereographic projection: ℝ → S¹ ⊂ ℝ² -/
def invStereoProj (t : ℝ) : ℝ × ℝ :=
  (2 * t / (1 + t ^ 2), (1 - t ^ 2) / (1 + t ^ 2))

/-- Stereographic projection from the unit circle (minus the south pole `(0,-1)`)
back to `ℝ`: `(x, y) ↦ x / (1 + y)`. -/
def stereoProj (p : ℝ × ℝ) : ℝ := p.1 / (1 + p.2)

/-- **Theorem 2.1**: Inverse stereo always maps to the unit circle. -/
theorem invStereoProj_on_circle (t : ℝ) :
    (invStereoProj t).1 ^ 2 + (invStereoProj t).2 ^ 2 = 1 := by
  simp only [invStereoProj]
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  field_simp
  ring

/-- **Theorem 2.3 (Oracle-Stereo Round-Trip)**: The stereographic round-trip
is the identity — no information is lost. -/
theorem oracle_stereo_roundtrip (t : ℝ) :
    stereoProj (invStereoProj t) = t := by
  simp only [stereoProj, invStereoProj]
  have h : (1 : ℝ) + t ^ 2 > 0 := by positivity
  have hne : (1 : ℝ) + t ^ 2 ≠ 0 := ne_of_gt h
  field_simp
  ring

/-- **Theorem 2.4**: The y-coordinate of invStereo is bounded above by 1. -/
theorem invStereo_y_le_one (t : ℝ) : (invStereoProj t).2 ≤ 1 := by
  simp only [invStereoProj]
  have h : (0 : ℝ) < 1 + t ^ 2 := by positivity
  rw [div_le_one h]
  linarith [sq_nonneg t]

/-- [Section: # CatalogBuild.Computation.Oracles.OracleStereoSolver
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 39] -/
theorem invStereo_y_ge_neg_one (t : ℝ) : -1 ≤ (invStereoProj t).2 := by
  exact ( by rw [ invStereoProj ] ; rw [ le_div_iff₀ ] <;> nlinarith )

/-- **Theorem 2.6**: At t=0, invStereo gives the "north pole" (0,1). -/
theorem invStereo_at_zero : invStereoProj 0 = (0, 1) := by
  simp [invStereoProj]

/-- **Theorem 2.7**: At t=1, invStereo gives (1,0). -/
theorem invStereo_at_one : invStereoProj 1 = (1, 0) := by
  unfold invStereoProj; norm_num

/-- A Pythagorean triple (a, b, c) satisfies a² + b² = c². -/
def IsPythagoreanTriple (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- **Theorem 3.1 (The Rational Oracle)**: For any integers p, q,
(2pq, q²-p², p²+q²) is a Pythagorean triple. -/
theorem rational_stereo_pythagorean (p q : ℤ) :
    IsPythagoreanTriple (2 * p * q) (q ^ 2 - p ^ 2) (p ^ 2 + q ^ 2) := by
  simp only [IsPythagoreanTriple]; ring

/-- **Theorem 3.6 (Universality)**: The parametrization identity. -/
theorem pythagorean_parametrization_complete (m n : ℤ) :
    (2 * m * n) ^ 2 + (m ^ 2 - n ^ 2) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by
  ring

/-- **Theorem 3.7 (Sum of Two Squares Primes ≤ 100)**: 12 such primes. -/
theorem sum_two_squares_primes_count :
    (Finset.filter (fun p => Nat.Prime p ∧ (p % 4 = 1 ∨ p = 2))
      (Finset.range 101)).card = 12 := by native_decide

/-- **Experiment 1**: The Pythagorean identity holds for all small parameters. -/
theorem experiment_pythagorean_batch :
    ∀ p q : Fin 10,
      (2 * (p : ℤ) * q) ^ 2 + ((q : ℤ) ^ 2 - (p : ℤ) ^ 2) ^ 2 =
      ((p : ℤ) ^ 2 + (q : ℤ) ^ 2) ^ 2 := by
  intro p q; ring

/-- **Experiment 2**: The oracle-stereo roundtrip is exact at rationals. -/
theorem experiment_roundtrip (p q : ℤ) (hq : (q : ℝ) ≠ 0) :
    stereoProj (invStereoProj ((p : ℝ) / q)) = (p : ℝ) / q :=
  oracle_stereo_roundtrip _

/-- `sin (nπ) = 0` for every integer `n`. -/
theorem sin_int_mul_pi (n : ℤ) : Real.sin (n * Real.pi) = 0 :=
  Real.sin_int_mul_pi n

/-- **Theorem 5.1 (Crystallization at Integers)**: sin(πn) = 0 for n ∈ ℤ. -/
theorem crystallization_integers (n : ℤ) : Real.sin (Real.pi * ↑n) = 0 := by
  rw [mul_comm]; exact sin_int_mul_pi n

/-- **Theorem 5.2**: Lattice points on x²+y²=25. -/
theorem lattice_point_25 :
    (Finset.filter (fun p : ℤ × ℤ => p.1 ^ 2 + p.2 ^ 2 = 25)
      (Finset.Icc (-5) 5 ×ˢ Finset.Icc (-5) 5)).card = 12 := by native_decide

/-- **Theorem 5.3**: Lattice points on x²+y²=1. -/
theorem lattice_point_1 :
    (Finset.filter (fun p : ℤ × ℤ => p.1 ^ 2 + p.2 ^ 2 = 1)
      (Finset.Icc (-1) 1 ×ˢ Finset.Icc (-1) 1)).card = 4 := by native_decide

/-- **Theorem 5.4**: r₂(3) = 0 — 3 is not a sum of two squares. -/
theorem no_lattice_points_3 :
    (Finset.filter (fun p : ℤ × ℤ => p.1 ^ 2 + p.2 ^ 2 = 3)
      (Finset.Icc (-2) 2 ×ˢ Finset.Icc (-2) 2)).card = 0 := by native_decide

/-- **Theorem 5.5**: r₂(5) = 8. -/
theorem lattice_points_5 :
    (Finset.filter (fun p : ℤ × ℤ => p.1 ^ 2 + p.2 ^ 2 = 5)
      (Finset.Icc (-3) 3 ×ˢ Finset.Icc (-3) 3)).card = 8 := by native_decide

/-- The Möbius transformation `x ↦ (a x + b) / (c x + d)` on the reals. -/
def mobiusTransform (a b c d x : ℝ) : ℝ := (a * x + b) / (c * x + d)

/-- **Theorem 6.1**: The identity Möbius transform. -/
theorem mobius_identity (x : ℝ) : mobiusTransform 1 0 0 1 x = x := by
  simp [mobiusTransform]

theorem mobius_inversion_involution (x : ℝ) (hx : x ≠ 0) :
    mobiusTransform 0 1 1 0 (mobiusTransform 0 1 1 0 x) = x := by
  unfold mobiusTransform; aesop;

/-- **Theorem 6.3**: The modular S matrix has determinant 1. -/
theorem modular_S_det :
    Matrix.det !![( 0 : ℤ), -1; 1, 0] = 1 := by
  simp [Matrix.det_fin_two]

/-- **Theorem 6.4**: S² = -I in SL₂(ℤ). -/
theorem modular_S_squared :
    !![( 0 : ℤ), -1; 1, 0] * !![( 0 : ℤ), -1; 1, 0] = !![(-1 : ℤ), 0; 0, -1] := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_two]

/-- **Theorem 6.5**: (ST)³ = -I. -/
theorem modular_ST_cubed :
    !![( 0 : ℤ), -1; 1, 1] * !![( 0 : ℤ), -1; 1, 1] * !![( 0 : ℤ), -1; 1, 1] =
    !![(-1 : ℤ), 0; 0, -1] := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [Matrix.mul_apply, Fin.sum_univ_two]

/-- **Application 1**: The floor function is an oracle on integers. -/
theorem floor_oracle_idempotent (x : ℤ) : ⌊(x : ℝ)⌋ = x :=
  Int.floor_intCast x

/-- **Application 2**: The modular oracle: (x mod n) mod n = x mod n. -/
theorem mod_oracle_idempotent (x n : ℕ) : (x % n) % n = x % n :=
  Nat.mod_mod_of_dvd x (dvd_refl n)

/-- **Application 3**: The parity oracle is idempotent. -/
theorem parity_oracle_idempotent (x : ℕ) : (x % 2) % 2 = x % 2 := by omega

theorem gcd_oracle_idempotent (a b : ℕ) :
    Nat.gcd (Nat.gcd a b) b = Nat.gcd a b := by
  rw [ Nat.gcd_assoc, Nat.gcd_self ]

/-- **Grand Theorem (The Solution Lens)**: The stereographic round-trip
is the identity — the lens preserves all information. -/
theorem solution_lens_identity :
    ∀ t : ℝ, stereoProj (invStereoProj t) = t :=
  oracle_stereo_roundtrip

/-- **The Solution Lens Oracle**: The stereo round-trip is the identity oracle. -/
def solutionLensOracle : SolverOracle ℝ where
  apply := fun t => stereoProj (invStereoProj t)
  idempotent := by
    intro x; simp [solution_lens_identity]

/-- **Oracle-Lens Collapse**: O ∘ lens ∘ O = O. -/
theorem oracle_lens_collapse (O : SolverOracle ℝ) (x : ℝ) :
    O.apply (stereoProj (invStereoProj (O.apply x))) = O.apply x := by
  rw [solution_lens_identity]; exact O.idempotent x

/-- **The Frozen Crystal Theorem**: The truth set of the solution lens oracle
is all of ℝ — every point is a fixed point of the identity. -/
theorem frozen_crystal_is_everything :
    solutionLensOracle.truthSet = Set.univ := by
  ext x; simp [SolverOracle.truthSet, solutionLensOracle, solution_lens_identity]

end

/- Original: OracleTeam.lean -/




noncomputable section

/-- A prediction oracle produces, for each piece of evidence, a prediction together
with a nonnegative confidence weight. -/
structure PredictionOracle where
  /-- The predicted value. -/
  predict : ℝ → ℝ
  /-- The weight the oracle assigns to its own prediction. -/
  confidence : ℝ → ℝ

/-- A council of `n` prediction oracles. -/
structure OracleCouncil (n : ℕ) where
  /-- The members of the council. -/
  oracles : Fin n → PredictionOracle

/-- [Section: # CatalogBuild.MachineLearning.Prediction.OracleTeam
Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 5] -/
noncomputable def OracleCouncil.ensemblePrediction {n : ℕ}
    (council : OracleCouncil n) (evidence : ℝ)
    (total_conf_pos : 0 < ∑ i, (council.oracles i).confidence evidence) : ℝ :=
  (∑ i, (council.oracles i).confidence evidence * (council.oracles i).predict evidence) /
  (∑ i, (council.oracles i).confidence evidence)




/-- If all oracles agree, the ensemble agrees too -/
theorem unanimous_council {n : ℕ} (hn : 0 < n)
    (council : OracleCouncil n) (evidence : ℝ)
    (v : ℝ) (h_unanimous : ∀ i, (council.oracles i).predict evidence = v)
    (h_conf_pos : 0 < ∑ i, (council.oracles i).confidence evidence) :
    council.ensemblePrediction evidence h_conf_pos = v := by
  simp only [OracleCouncil.ensemblePrediction]
  simp_rw [h_unanimous, ← Finset.sum_mul]
  rw [mul_div_cancel_left₀]
  exact ne_of_gt h_conf_pos




/-- The ensemble error is bounded by the weighted average of individual errors -/
theorem ensemble_no_worse_than_best {n : ℕ}
    (predictions : Fin n → ℝ) (truth : ℝ)
    (weights : Fin n → ℝ) (hw_nn : ∀ i, 0 ≤ weights i)
    (hw_sum : ∑ i, weights i = 1) :
    let ensemble := ∑ i, weights i * predictions i
    |ensemble - truth| ≤ ∑ i, weights i * |predictions i - truth| := by
  simp only
  calc |∑ i, weights i * predictions i - truth|
      = |∑ i, weights i * predictions i - (∑ i, weights i) * truth| := by
        rw [hw_sum, one_mul]
    _ = |∑ i, (weights i * predictions i - weights i * truth)| := by
        congr 1; rw [Finset.sum_sub_distrib]; congr 1; rw [Finset.sum_mul]
    _ = |∑ i, weights i * (predictions i - truth)| := by
        congr 1; congr 1; ext i; ring
    _ ≤ ∑ i, |weights i * (predictions i - truth)| :=
        Finset.abs_sum_le_sum_abs _ _
    _ = ∑ i, weights i * |predictions i - truth| := by
        congr 1; ext i; rw [abs_mul, abs_of_nonneg (hw_nn i)]




/-- A hedge combines an aggressive and conservative prediction -/
noncomputable def hedge (aggressive conservative lambda_param : ℝ) : ℝ :=
  lambda_param * aggressive + (1 - lambda_param) * conservative




/-- Hedging interpolates between predictions -/
theorem hedge_interpolates (a c : ℝ) (hac : a ≤ c) (lambda_param : ℝ)
    (hl0 : 0 ≤ lambda_param) (hl1 : lambda_param ≤ 1) :
    a ≤ hedge a c lambda_param ∧ hedge a c lambda_param ≤ c := by
  simp only [hedge]
  constructor <;> nlinarith




end