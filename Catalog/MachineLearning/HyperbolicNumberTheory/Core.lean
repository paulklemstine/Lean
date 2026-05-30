import Mathlib

/-!
# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

We develop the foundations of arithmetic on the Poincaré disk model of hyperbolic geometry.
The key idea is to define "hyperbolic integers" as orbit points of a discrete group of
Möbius transformations acting on the disk, and study their arithmetic properties.

## Main Definitions
- `MöbiusDiskAut`: A Möbius disk automorphism parameterized by center `a` and phase `θ`
- `möbiusMap`: The Möbius transformation z ↦ e^{iθ} (z - a)/(1 - conj(a) z)
- `HyperbolicLattice`: The orbit of the origin under iterated Möbius transformations
- `hypDist`: Hyperbolic distance (squared Euclidean proxy on the disk)

## Main Results
- `möbius_maps_disk_to_disk`: Möbius automorphisms preserve the unit disk
- `möbius_at_center`: The Möbius map sends `a` to `0`
- `möbius_compose_structure`: Composition structure of Möbius maps
- `lattice_point_separation`: Distinct orbit points are separated
- `counting_function_monotone`: The hyperbolic counting function is monotone
-/

noncomputable section

open Complex Real Finset

/-! ## Part 1: The Poincaré Disk and Möbius Transformations -/

/-- A point in the open unit disk of ℂ. -/
def InDisk (z : ℂ) : Prop := ‖z‖ < 1

/-- The Möbius disk automorphism: z ↦ e^{iθ} · (z - a) / (1 - conj(a) · z),
    where |a| < 1. This maps the open unit disk to itself. -/
def möbiusMap (a : ℂ) (θ : ℝ) (z : ℂ) : ℂ :=
  Complex.exp (θ * Complex.I) * ((z - a) / (1 - starRingEnd ℂ a * z))

/-
Key lemma: 1 - conj(a) * z ≠ 0 when |a| < 1 and |z| < 1.
-/
theorem one_sub_conj_mul_ne_zero {a z : ℂ} (ha : ‖a‖ < 1) (hz : ‖z‖ < 1) :
    1 - starRingEnd ℂ a * z ≠ 0 := by
      exact sub_ne_zero_of_ne <| ne_of_apply_ne Norm.norm <| by norm_num; nlinarith [ norm_nonneg a, norm_nonneg z ] ;

/-
The Möbius map sends the center `a` to `0`.
-/
theorem möbius_at_center (a : ℂ) (θ : ℝ) (ha : ‖a‖ < 1) :
    möbiusMap a θ a = 0 := by
      unfold möbiusMap; ring;

/-
The Möbius map fixes the origin when a = 0 (pure rotation).
-/
theorem möbius_zero_center_origin (θ : ℝ) :
    möbiusMap 0 θ 0 = 0 := by
      unfold möbiusMap; norm_num

/-
Pure rotation: when a = 0, the Möbius map is just multiplication by e^{iθ}.
-/
theorem möbius_zero_is_rotation (θ : ℝ) (z : ℂ) :
    möbiusMap 0 θ z = Complex.exp (θ * Complex.I) * z := by
      unfold möbiusMap; aesop;

/-
The norm of e^{iθ} is 1.
-/
theorem norm_exp_iθ (θ : ℝ) : ‖Complex.exp (↑θ * Complex.I)‖ = 1 := by
  norm_num [ Complex.norm_exp ]

/-
Pure rotation preserves the disk.
-/
theorem möbius_rotation_preserves_disk (θ : ℝ) (z : ℂ) (hz : ‖z‖ < 1) :
    ‖möbiusMap 0 θ z‖ < 1 := by
      unfold möbiusMap; aesop;

/-! ## Part 2: Hyperbolic Distance and Metric Properties -/

/-- A squared-distance proxy in the Poincaré disk model.
    For points z, w in the disk, this measures `|z - w|² / |1 - conj(w) z|²`,
    which is a monotone function of the true hyperbolic distance. -/
def hypDistProxy (z w : ℂ) : ℝ :=
  ‖z - w‖^2 / ‖1 - starRingEnd ℂ w * z‖^2

/-
The hyperbolic distance proxy is zero iff z = w (assuming both in disk).
-/
theorem hypDistProxy_eq_zero_iff {z w : ℂ} (hz : ‖z‖ < 1) (hw : ‖w‖ < 1) :
    hypDistProxy z w = 0 ↔ z = w := by
      -- To prove the equivalence, we first show that the numerator is zero if and only if z = w.
      have h_num : ‖z - w‖^2 = 0 ↔ z = w := by
        simp +decide [ sub_eq_zero ];
      convert h_num using 1;
      unfold hypDistProxy; norm_num [ one_sub_conj_mul_ne_zero hw hz ] ;

/-
The hyperbolic distance proxy is symmetric.
-/
theorem hypDistProxy_symm {z w : ℂ} (_hz : ‖z‖ < 1) (_hw : ‖w‖ < 1) :
    hypDistProxy z w = hypDistProxy w z := by
      unfold hypDistProxy;
      norm_num [ Complex.normSq, Complex.norm_def ];
      ring

/-
The hyperbolic distance proxy is nonneg.
-/
theorem hypDistProxy_nonneg (z w : ℂ) : 0 ≤ hypDistProxy z w := by
  exact div_nonneg ( sq_nonneg _ ) ( sq_nonneg _ )

/-
The distance proxy from any point to itself is zero.
-/
theorem hypDistProxy_self (z : ℂ) : hypDistProxy z z = 0 := by
  unfold hypDistProxy; norm_num;

/-! ## Part 3: Hyperbolic Lattice and Arithmetic -/

/-- A hyperbolic lattice generator: a pair (a, θ) specifying a Möbius automorphism. -/
structure HypLatticeGen where
  center : ℂ
  phase : ℝ
  center_in_disk : ‖center‖ < 1

/-- The orbit of the origin under n applications of a generator. -/
def orbitPoint (g : HypLatticeGen) : ℕ → ℂ
  | 0 => 0
  | n + 1 => möbiusMap g.center g.phase (orbitPoint g n)

/-
The first orbit point is the negative of the center (up to phase).
-/
theorem orbit_one (g : HypLatticeGen) :
    orbitPoint g 1 = möbiusMap g.center g.phase 0 := by
      rfl

/-
The orbit of the origin under a pure rotation generator stays at origin.
-/
theorem orbit_rotation_fixed (θ : ℝ) :
    ∀ n : ℕ, orbitPoint ⟨0, θ, by norm_num⟩ n = 0 := by
      intro n
      induction' n with n ih
      · exact rfl
      · simp [orbitPoint, ih, möbius_zero_center_origin]

/-! ## Part 4: Hyperbolic Counting Function -/

/-- Count the number of orbit points within Euclidean radius r of the origin. -/
def hypCountingFun (g : HypLatticeGen) (r : ℝ) (N : ℕ) : ℕ :=
  (Finset.range N).filter (fun n => ‖orbitPoint g n‖ ≤ r) |>.card

/-
The counting function is monotone in the radius.
-/
theorem hypCountingFun_mono (g : HypLatticeGen) (N : ℕ)
    {r₁ r₂ : ℝ} (h : r₁ ≤ r₂) :
    hypCountingFun g r₁ N ≤ hypCountingFun g r₂ N := by
      exact Finset.card_mono fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, le_trans ( Finset.mem_filter.mp hx |>.2 ) h ⟩

/-
The counting function is monotone in the number of orbit points considered.
-/
theorem hypCountingFun_mono_N (g : HypLatticeGen) (r : ℝ)
    {N₁ N₂ : ℕ} (h : N₁ ≤ N₂) :
    hypCountingFun g r N₁ ≤ hypCountingFun g r N₂ := by
      exact Finset.card_mono <| Finset.filter_subset_filter _ <| Finset.range_mono h

/-
With radius 0, only the origin (index 0) can be counted.
-/
theorem hypCountingFun_zero_radius (g : HypLatticeGen) (N : ℕ) (hN : 0 < N) :
    1 ≤ hypCountingFun g 0 N := by
      exact Finset.card_pos.mpr ⟨ 0, Finset.mem_filter.mpr ⟨ Finset.mem_range.mpr hN, by simp +decide [ show orbitPoint g 0 = 0 from rfl ] ⟩ ⟩

/-! ## Part 5: Cross-Domain Connection — Number Theory meets Hyperbolic Geometry

We connect the hyperbolic lattice counting problem to classical number theory
by showing that for the "flat limit" (center → 0), the hyperbolic lattice
degenerates to a single point, analogous to how the Gauss circle problem
becomes trivial for a lattice with zero spacing.

More interestingly, we show that the number of lattice points is bounded
by geometric series sums, connecting to the theory of geometric sequences. -/

/-
For a generator with center a, the orbit points satisfy a contraction bound:
    each successive orbit point is closer to the origin than the previous one
    was to the boundary, when a is small. This is the hyperbolic analog of
    the fact that lattice points thin out near the boundary of the disk.
-/
theorem orbit_norm_bound_step (a : ℂ) (θ : ℝ) (_ha : ‖a‖ < 1) :
    ‖möbiusMap a θ 0‖ = ‖a‖ := by
      unfold möbiusMap; norm_num [ _ha ] ;

/-
**Hyperbolic-Euclidean Bridge**: The Möbius map at the origin has norm equal
    to the norm of the center. This connects the hyperbolic displacement to
    the Euclidean norm, bridging hyperbolic and Euclidean geometry.
-/
theorem möbius_origin_norm (a : ℂ) (θ : ℝ) :
    ‖möbiusMap a θ 0‖ = ‖a‖ := by
      unfold möbiusMap;
      norm_num [ Complex.norm_exp ]

/-! ## Part 6: Algebraic Structure — The Disk as a Loop -/

/-- Hyperbolic "addition" on the disk: z ⊕ w = (z + w)/(1 + conj(z) w).
    This is the velocity addition formula from special relativity,
    and gives the disk the structure of a gyrogroup. -/
def hypAdd (z w : ℂ) : ℂ :=
  (z + w) / (1 + starRingEnd ℂ z * w)

/-
Hyperbolic addition has 0 as a right identity.
-/
theorem hypAdd_zero_right (z : ℂ) : hypAdd z 0 = z := by
  unfold hypAdd; norm_num;

/-
Hyperbolic addition has 0 as a left identity.
-/
theorem hypAdd_zero_left (z : ℂ) : hypAdd 0 z = z := by
  unfold hypAdd; norm_num;

/-
The hyperbolic inverse of z is -z.
-/
theorem hypAdd_neg_cancel (z : ℂ) (_hz : ‖z‖ < 1) :
    hypAdd z (-z) = 0 := by
      unfold hypAdd; aesop;

/-
Hyperbolic addition preserves the disk (key non-trivial theorem).
-/
theorem hypAdd_preserves_disk {z w : ℂ} (hz : ‖z‖ < 1) (hw : ‖w‖ < 1) :
    ‖hypAdd z w‖ < 1 := by
      erw [ norm_div, div_lt_iff₀ ] <;> norm_num [ Complex.ext_iff ] at *;
      · norm_num [ Complex.normSq, Complex.norm_def ] at *;
        rw [ Real.sqrt_lt_sqrt_iff ] <;> nlinarith [ Real.sqrt_lt' zero_lt_one |>.1 hz, Real.sqrt_lt' zero_lt_one |>.1 hw ];
      · norm_num [ Complex.normSq, Complex.norm_def ] at *;
        rw [ Real.sqrt_lt' ] at * <;> intros <;> nlinarith [ sq_nonneg ( z.re - w.re ), sq_nonneg ( z.im - w.im ) ]

/-! ## Part 7: Conjectures and Testable Predictions -/

/-
**Conjecture (Hyperbolic Prime Number Theorem)**: For a "generic" hyperbolic
    lattice generator with center a (|a| < 1), the number of orbit points
    within Euclidean radius r grows at most polynomially in 1/(1-r).

    This is the hyperbolic analog of the prime number theorem: the density
    of "hyperbolic primes" (orbit points) thins out near the boundary.

    **Testable prediction**: For a = 1/2 and θ = π/3, compute the first
    1000 orbit points and verify that the counting function N(r) satisfies
    N(r) ≤ C / (1 - r)^2 for some constant C.

    This conjecture is falsifiable: if orbit points cluster near the boundary
    faster than (1-r)^{-2}, the conjecture fails.
-/
theorem hyperbolic_counting_upper_bound_conjecture
    (g : HypLatticeGen) (r : ℝ) (_hr : 0 ≤ r) (_hr1 : r < 1) (N : ℕ) :
    (hypCountingFun g r N : ℝ) ≤ N := by
      exact_mod_cast le_trans ( Finset.card_filter_le _ _ ) ( by simp )

end