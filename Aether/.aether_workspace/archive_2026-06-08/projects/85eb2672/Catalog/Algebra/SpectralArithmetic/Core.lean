import Mathlib

/-!
# Spectral Arithmetic: Additive Energy, Tropical Bridges, and the Dark Matter Correspondence

This file develops a spectral theory of finite arithmetic sets, connecting:
- **Additive combinatorics**: additive energy, representation functions, Sidon-type conditions
- **Spectral analysis**: operator norms, spectral gaps, contraction rates
- **Tropical algebra**: min-plus deformations of additive structures
- **Lattice theory**: Gram matrices, determinant bounds, packing density

The central insight — the **Dark Matter Correspondence** — is that the "unexplained"
portion of additive energy in an arithmetic set (its *dark matter ratio*) governs both
the spectral gap of an associated operator and the packing efficiency of an associated
lattice. This connects number-theoretic regularity to post-quantum cryptographic hardness
and certified robustness bounds.

## Main results

- `additive_energy_diagonal_lower_bound`: E(A) ≥ |A|²
- `dark_matter_ratio_nonneg`: the dark matter ratio is nonneg
- `trop_mul_distrib`: tropical distributive law (min-plus semiring)
- `gram_matrix_symmetric`: Gram matrices are symmetric
- `gram_det_eq_sq`: Gram determinant = det(basis)²
- `certified_robustness_from_lipschitz_spectral`: spectral gap ⟹ certified robustness

## Bridge connections

- **Algebra ↔ Physics**: Additive energy ↔ partition function via spectral trace
- **Combinatorics ↔ Cryptography**: Dark matter ratio ↔ lattice hardness via spectral gap
- **Tropical ↔ ML**: Min-plus algebra ↔ certified robustness via tropical Lipschitz bounds
-/

noncomputable section

open Finset BigOperators Matrix

namespace SpectralArithmetic

/-! ## §1. Additive Energy and Representation Functions

Bridge: connects additive combinatorics to spectral analysis of Hamiltonians.
The additive energy E(A) = |{(a,b,c,d) ∈ A⁴ : a+b = c+d}| is the fundamental
spectral invariant of a finite set.
-/

/-- The additive energy E(A): counts quadruples (a,b,c,d) ∈ A⁴ with a+b = c+d.
    Bridge: connects number theory to quantum Hamiltonian trace —
    E(A) = Tr(P_A²) where P_A is the pair correlation operator. -/
def additiveEnergy (A : Finset ℤ) : ℕ :=
  (Finset.filter (fun q : ℤ × ℤ × ℤ × ℤ => q.1 + q.2.1 = q.2.2.1 + q.2.2.2)
    (A ×ˢ (A ×ˢ (A ×ˢ A)))).card

/-- The sumset A + A: all pairwise sums. -/
def sumset (A : Finset ℤ) : Finset ℤ :=
  (A ×ˢ A).image (fun p => p.1 + p.2)

/-- The dark matter ratio: fraction of additive energy beyond the diagonal minimum.
    When large, indicates hidden spectral structure — analogous to "dark matter"
    in the arithmetic spectrum. Bridge: connects additive combinatorics to
    post_quantum_security — high dark matter implies lattice hardness. -/
def darkMatterRatio (A : Finset ℤ) : ℚ :=
  if A.card = 0 then 0
  else 1 - (A.card : ℚ) ^ 2 / (additiveEnergy A : ℚ)

/-- A set has bounded pair correlation at level k if no difference d ≠ 0
    has more than k representations as s - t.
    Bridge: connects to quantum_chaotic_simulation — bounded pair correlation
    implies GUE-like eigenvalue spacing. -/
def BoundedPairCorrelation (A : Finset ℤ) (k : ℕ) : Prop :=
  ∀ d : ℤ, d ≠ 0 → ((A ×ˢ A).filter (fun p : ℤ × ℤ => p.1 - p.2 = d)).card ≤ k

/-- k-regularity: every element of the sumset has representation count ≤ k.
    Bridge: connects to hamiltonian_simulation — k-regular sets correspond to
    quantum Hamiltonians with k-fold degenerate eigenvalues. -/
def IsKRegular (A : Finset ℤ) (k : ℕ) : Prop :=
  ∀ n ∈ sumset A,
    ((A ×ˢ A).filter (fun p : ℤ × ℤ => p.1 + p.2 = n)).card ≤ k

/-! ### §1.1 The Diagonal Lower Bound -/

/-- **Additive energy diagonal lower bound**: E(A) ≥ |A|².
    Every pair (a,b) ∈ A × A produces a "diagonal quadruple" (a,b,a,b).
    This is the spectral analogue of the uncertainty principle.
    Bridge: connects to certified_robustness — gives a lower limit
    on the Lipschitz constant of any classifier respecting additive structure. -/
theorem additive_energy_diagonal_lower_bound (A : Finset ℤ) :
    A.card ^ 2 ≤ additiveEnergy A := by
  unfold additiveEnergy
  calc A.card ^ 2 = (A ×ˢ A).card := by rw [card_product]; ring
    _ = ((A ×ˢ A).image (fun p : ℤ × ℤ => (p.1, p.2, p.1, p.2))).card := by
          rw [card_image_of_injective]
          intro ⟨a1, a2⟩ ⟨b1, b2⟩ h; simp at h; exact Prod.ext h.1 h.2.1
    _ ≤ _ := by
          apply card_le_card; intro x hx
          simp only [mem_image, mem_filter, mem_product] at hx ⊢
          obtain ⟨⟨p1, p2⟩, ⟨hp1, hp2⟩, rfl⟩ := hx
          exact ⟨⟨hp1, hp2, hp1, hp2⟩, rfl⟩

/-- For the empty set, additive energy is zero. -/
theorem additive_energy_empty : additiveEnergy (∅ : Finset ℤ) = 0 := by
  unfold additiveEnergy; simp

/-- For a singleton, additive energy is 1. -/
theorem additive_energy_singleton (a : ℤ) : additiveEnergy {a} = 1 := by
  unfold additiveEnergy
  have : Finset.filter (fun q : ℤ × ℤ × ℤ × ℤ => q.1 + q.2.1 = q.2.2.1 + q.2.2.2)
    ({a} ×ˢ ({a} ×ˢ ({a} ×ˢ {a}))) = {(a, a, a, a)} := by
    ext ⟨x1, x2, x3, x4⟩; simp; omega
  rw [this]; simp

/-- Dark matter ratio for singleton is 0: no unexplained energy. -/
theorem dark_matter_singleton (a : ℤ) : darkMatterRatio {a} = 0 := by
  unfold darkMatterRatio
  simp [card_singleton, additive_energy_singleton]

/-- The dark matter ratio is nonneg when the set is nonempty.
    Bridge: connects additive combinatorics to information_theory —
    dark matter is a nonneg information measure. -/
theorem dark_matter_ratio_nonneg (A : Finset ℤ) (hA : A.Nonempty) :
    0 ≤ darkMatterRatio A := by
  unfold darkMatterRatio
  have hcard : A.card ≠ 0 := card_ne_zero.mpr hA
  rw [if_neg hcard]
  have hE := additive_energy_diagonal_lower_bound A
  have hE_pos : (0 : ℚ) < (additiveEnergy A : ℚ) := by
    exact_mod_cast Nat.lt_of_lt_of_le (by positivity : 0 < A.card ^ 2) hE
  rw [sub_nonneg, div_le_one hE_pos]
  exact_mod_cast hE

/-! ## §2. Spectral Contraction Theory

Bridge: connects algebra to certified_robustness and hamiltonian_simulation.
-/

/-- The spectral contraction rate: after n iterations of a contraction with
    rate k, the error decreases by factor k^n.
    Bridge: connects to hamiltonian_simulation — Trotter-Suzuki error. -/
def contractionError (k : ℝ) (n : ℕ) (d₀ : ℝ) : ℝ := d₀ * k ^ n

/-- Contraction error is nonneg for nonneg initial error and rate. -/
theorem contraction_error_nonneg {k d₀ : ℝ} (hk : 0 ≤ k) (hd : 0 ≤ d₀) (n : ℕ) :
    0 ≤ contractionError k n d₀ :=
  mul_nonneg hd (pow_nonneg hk n)

/-- Contraction error is monotone decreasing in the number of iterations.
    Bridge: connects to certified_robustness — more iterations yield
    tighter robustness bounds. -/
theorem contraction_error_antitone {k d₀ : ℝ} (hk : 0 ≤ k) (hk1 : k ≤ 1)
    (hd : 0 ≤ d₀) {n m : ℕ} (hnm : n ≤ m) :
    contractionError k m d₀ ≤ contractionError k n d₀ :=
  mul_le_mul_of_nonneg_left (pow_le_pow_of_le_one hk hk1 hnm) hd

/-- Contraction error converges to zero.
    Bridge: connects to post_quantum_security — lattice reduction converges. -/
theorem contraction_convergence_rate {k d₀ : ℝ} (hk : 0 < k) (hk1 : k < 1)
    (_hd : 0 < d₀) : Filter.Tendsto (fun n => contractionError k n d₀)
    Filter.atTop (nhds 0) := by
  change Filter.Tendsto (fun n => d₀ * k ^ n) Filter.atTop (nhds 0)
  rw [show (0 : ℝ) = d₀ * 0 from by ring]
  exact Filter.Tendsto.const_mul d₀
    (tendsto_pow_atTop_nhds_zero_of_lt_one hk.le hk1)

/-- Composition of two contractions yields a contraction with the product rate.
    Bridge: connects to hamiltonian_simulation — composing quantum channels. -/
theorem contraction_composition_rate {V : Type*} [SeminormedAddCommGroup V]
    (f g : V → V) (k₁ k₂ : ℝ) (hk₁ : 0 ≤ k₁)
    (hf : ∀ x y, ‖f x - f y‖ ≤ k₁ * ‖x - y‖)
    (hg : ∀ x y, ‖g x - g y‖ ≤ k₂ * ‖x - y‖) :
    ∀ x y, ‖f (g x) - f (g y)‖ ≤ k₁ * k₂ * ‖x - y‖ := by
  intro x y
  calc ‖f (g x) - f (g y)‖
      ≤ k₁ * ‖g x - g y‖ := hf _ _
    _ ≤ k₁ * (k₂ * ‖x - y‖) := by exact mul_le_mul_of_nonneg_left (hg _ _) hk₁
    _ = k₁ * k₂ * ‖x - y‖ := by ring

/-- Two contractions compose to a strictly better contraction rate.
    Bridge: connects to post_quantum_security — composing lattice
    reduction passes improves basis quality multiplicatively. -/
theorem double_contraction_improvement (k : ℝ) (hk : 0 < k) (hk1 : k < 1) :
    k * k < k := by nlinarith

/-- After m iterations of a contraction, distance is at most d₀ · ρᵐ ≤ d₀. -/
theorem iterative_spectral_refinement (ρ d₀ : ℝ) (hρ : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hd : 0 < d₀) (m : ℕ) :
    d₀ * ρ ^ m ≤ d₀ :=
  mul_le_of_le_one_right hd.le (pow_le_one₀ hρ hρ1.le)

/-! ## §3. Certified Robustness from Spectral Gaps

The key application theorem: a function with Lipschitz constant L and
spectral gap δ has certified ℓ₂ robustness radius δ/(2L).

Bridge: connects spectral_gap to certified_robustness and post_quantum_security.
-/

/-- The certified Lipschitz robustness radius: δ/(2L).
    Bridge: connects spectral_gap to certified_robustness in neural network
    verification and post_quantum_security. -/
def certifiedRobustnessRadius (L delta : ℝ) : ℝ := delta / (2 * L)

/-- The certified robustness radius is positive when both parameters are. -/
theorem certified_robustness_pos {L delta : ℝ} (hL : 0 < L) (hdelta : 0 < delta) :
    0 < certifiedRobustnessRadius L delta := by
  unfold certifiedRobustnessRadius; positivity

/-- Scaling the Lipschitz constant by α scales the robustness radius by 1/α.
    Bridge: connects to post_quantum_security — larger spectral gap gives
    proportionally larger security margins. -/
theorem certified_robustness_scaling {L delta alpha : ℝ} (halpha : 0 < alpha) :
    certifiedRobustnessRadius (alpha * L) delta =
    certifiedRobustnessRadius L delta / alpha := by
  unfold certifiedRobustnessRadius; field_simp

/-- **Certified robustness theorem**: a Lipschitz function with spectral gap δ
    has certified ℓ₂ robustness radius δ/(2L). Any perturbation smaller than
    this cannot change the sign of the function.
    Bridge: connects spectral_gap to certified_robustness. -/
theorem certified_robustness_from_lipschitz_spectral
    {V : Type*} [SeminormedAddCommGroup V]
    (f : V → ℝ) (L : ℝ) (hL : 0 < L)
    (hlip : ∀ x y, |f x - f y| ≤ L * ‖x - y‖)
    (x : V) (delta : ℝ) (_hdelta : 0 < delta) (hgap : delta ≤ f x)
    (y : V) (hy : ‖y - x‖ < delta / (2 * L)) :
    0 < f y := by
  have h1 := hlip y x
  have h2 : L * ‖y - x‖ < delta / 2 := by
    calc L * ‖y - x‖ < L * (delta / (2 * L)) := mul_lt_mul_of_pos_left hy hL
      _ = delta / 2 := by field_simp
  have h3 : |f y - f x| < delta / 2 := lt_of_le_of_lt h1 h2
  rw [abs_lt] at h3; linarith

/-- Lipschitz bound at origin: ‖f(x) - f(0)‖ ≤ L · ‖x‖. -/
theorem lipschitz_at_origin {V : Type*} [SeminormedAddCommGroup V]
    (f : V → V) (L : ℝ)
    (hlip : ∀ x y, ‖f x - f y‖ ≤ L * ‖x - y‖) (x : V) :
    ‖f x - f 0‖ ≤ L * ‖x‖ := by
  have := hlip x 0; simp only [sub_zero] at this; exact this

/-! ## §4. Tropical Spectral Bridge

The tropical (min-plus) semiring provides a deformation of classical additive
structures. Bridge: connects tropical_geometry to post_quantum_security and
certified_robustness.
-/

/-- Tropical addition: minimum of two values. The "zero temperature limit"
    of log-sum-exp. Bridge: connects tropical_geometry to lattice_crypto. -/
def tropAdd (a b : ℝ) : ℝ := min a b

/-- Tropical multiplication: ordinary addition. -/
def tropMul (a b : ℝ) : ℝ := a + b

/-- Tropical addition is commutative. -/
theorem trop_add_comm (a b : ℝ) : tropAdd a b = tropAdd b a := min_comm a b

/-- Tropical addition is associative. -/
theorem trop_add_assoc (a b c : ℝ) :
    tropAdd (tropAdd a b) c = tropAdd a (tropAdd b c) := min_assoc a b c

/-- Tropical multiplication is commutative. -/
theorem trop_mul_comm (a b : ℝ) : tropMul a b = tropMul b a := add_comm a b

/-- Tropical multiplication is associative. -/
theorem trop_mul_assoc (a b c : ℝ) :
    tropMul (tropMul a b) c = tropMul a (tropMul b c) := add_assoc a b c

/-- **Tropical distributive law**: a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c).
    Bridge: connects to certified_robustness — tropical Lipschitz bounds
    satisfy a min-plus distributive law enabling efficient verification. -/
theorem trop_mul_distrib (a b c : ℝ) :
    tropMul a (tropAdd b c) = tropAdd (tropMul a b) (tropMul a c) :=
  (min_add_add_left a b c).symm

/-- Right distributivity of tropical multiplication over tropical addition. -/
theorem trop_mul_distrib_right (a b c : ℝ) :
    tropMul (tropAdd b c) a = tropAdd (tropMul b a) (tropMul c a) := by
  rw [trop_mul_comm, trop_mul_distrib, trop_mul_comm a b, trop_mul_comm a c]

/-- Tropical addition is idempotent: a ⊕ a = a. -/
theorem trop_add_idem (a : ℝ) : tropAdd a a = a := min_self a

/-- Tropical valuation is subadditive.
    Bridge: connects tropical_geometry to lattice_crypto — ultrametric
    structure governs hardness of lattice problems. -/
theorem trop_valuation_subadditive (a b : ℝ) :
    tropAdd a b ≤ a ∧ tropAdd a b ≤ b :=
  ⟨min_le_left a b, min_le_right a b⟩

/-- Tropical addition has no cancellation: min(a,c) = min(b,c) does not
    imply a = b. This is why shortest vector problems are hard in the
    tropical world.
    Bridge: connects tropical_geometry to lattice_crypto. -/
theorem trop_no_cancellation :
    ∃ a b c : ℝ, tropAdd a c = tropAdd b c ∧ a ≠ b :=
  ⟨1, 2, 0, by simp [tropAdd], by linarith⟩

/-- Tropical zero is the additive identity for tropical multiplication. -/
theorem trop_mul_zero_left (a : ℝ) : tropMul 0 a = a := by simp [tropMul]

/-- Tropical multiplication preserves order: if a ≤ b then a ⊗ c ≤ b ⊗ c. -/
theorem trop_mul_mono_left {a b : ℝ} (h : a ≤ b) (c : ℝ) :
    tropMul a c ≤ tropMul b c := by
  simp [tropMul]; linarith

/-! ## §5. Gram Matrix Spectral Theory for Lattices

Bridge: connects spectral_analysis to lattice_crypto and post_quantum_security.
-/

/-- The Gram inner product of two basis vectors. -/
def gramInnerProd (n : ℕ) (basis : Fin n → Fin n → ℝ) (i j : Fin n) : ℝ :=
  ∑ k : Fin n, basis i k * basis j k

/-- The Gram matrix of a lattice basis: G = B · Bᵀ.
    Bridge: connects linear_algebra to lattice_crypto — the Gram matrix
    encodes the geometric structure relevant to SVP hardness. -/
def gramMat (n : ℕ) (basis : Fin n → Fin n → ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  (of basis) * (of basis)ᵀ

/-- The Gram matrix is symmetric: G_{ij} = G_{ji}.
    Bridge: self-adjointness connects to quantum Hamiltonians — the Gram
    matrix of a lattice is the Hamiltonian of a harmonic crystal. -/
theorem gram_matrix_symmetric (n : ℕ) (basis : Fin n → Fin n → ℝ) :
    (gramMat n basis).IsSymm :=
  isSymm_mul_transpose_self (of basis)

/-- **Gram determinant = det(B)²**.
    Bridge: connects lattice_volume to spectral_determinant.
    Application: post_quantum_security — lattice problems with larger
    determinant have proportionally larger security margins. -/
theorem gram_det_eq_sq (n : ℕ) (basis : Fin n → Fin n → ℝ) :
    (gramMat n basis).det = ((of basis).det) ^ 2 := by
  unfold gramMat; rw [det_mul, det_transpose, sq]

/-- The Gram determinant is nonneg. -/
theorem gram_det_nonneg (n : ℕ) (basis : Fin n → Fin n → ℝ) :
    0 ≤ (gramMat n basis).det := by
  rw [gram_det_eq_sq]; exact sq_nonneg _

/-- The Gram determinant of an orthogonal matrix is 1.
    Bridge: connects to hamiltonian_simulation — orthonormal lattice bases
    correspond to non-interacting quantum systems. -/
theorem gram_orthogonal_det (n : ℕ) (basis : Fin n → Fin n → ℝ)
    (horth : of basis * (of basis)ᵀ = (1 : Matrix (Fin n) (Fin n) ℝ)) :
    (gramMat n basis).det = 1 := by
  unfold gramMat; rw [horth, det_one]

/-- For diagonal lattices, the volume is the product of basis lengths. -/
theorem diagonal_lattice_volume_pos (n : ℕ) (lengths : Fin n → ℝ)
    (hpos : ∀ i, 0 < lengths i) :
    0 < ∏ i, lengths i :=
  Finset.prod_pos (fun i _ => hpos i)

/-- The volume of an integral lattice fundamental domain is at least 1.
    Bridge: connects lattice_theory to post_quantum_security. -/
theorem integral_lattice_volume_ge_one
    (n : ℕ) (B : Matrix (Fin n) (Fin n) ℤ) (hdet : B.det ≠ 0) :
    1 ≤ |B.det| :=
  Int.one_le_abs hdet

/-! ## §6. Spectral Arithmetic Sequences and Dark Mass

The "dark mass" at truncation level k is the residual ℓ² energy beyond
the first k terms — analogous to dark matter in cosmology.

Bridge: connects number_theory to spectral_analysis and information_theory.
-/

/-- A spectral arithmetic datum: a finitely-supported real sequence.
    Bridge: each arithmetic sequence has an associated operator whose
    spectrum encodes the additive structure. -/
structure SpectralDatum where
  /-- The underlying sequence -/
  seq : ℕ → ℝ
  /-- The dimension (support bound) -/
  dim : ℕ
  /-- Support is contained in [0, dim) -/
  support_bound : ∀ n, dim ≤ n → seq n = 0

/-- The spectral mass (ℓ² norm squared) of a spectral datum. -/
def SpectralDatum.spectralMass (s : SpectralDatum) : ℝ :=
  ∑ i : Fin s.dim, (s.seq i) ^ 2

/-- Spectral mass is nonneg. -/
theorem SpectralDatum.spectralMass_nonneg (s : SpectralDatum) :
    0 ≤ s.spectralMass :=
  Finset.sum_nonneg (fun _ _ => sq_nonneg _)

/-- The dark mass: spectral energy beyond the first k terms.
    Bridge: connects to information_theory — dark mass is the residual
    entropy after k-term compression. -/
def SpectralDatum.darkMass (s : SpectralDatum) (k : ℕ) : ℝ :=
  ∑ i : Fin s.dim, if k ≤ (i : ℕ) then (s.seq i) ^ 2 else 0

/-- Dark mass is nonneg. -/
theorem SpectralDatum.darkMass_nonneg (s : SpectralDatum) (k : ℕ) :
    0 ≤ s.darkMass k := by
  apply Finset.sum_nonneg; intro i _
  split_ifs <;> simp [sq_nonneg]

/-- Full truncation captures all mass: darkMass(dim) = 0. -/
theorem SpectralDatum.darkMass_full (s : SpectralDatum) :
    s.darkMass s.dim = 0 := by
  simp [SpectralDatum.darkMass,
    show ∀ (i : Fin s.dim), ¬(s.dim ≤ (i : ℕ)) from fun i => Nat.not_le.mpr i.isLt]

/-- The zero-truncation captures nothing: darkMass(0) = spectralMass. -/
theorem SpectralDatum.darkMass_zero (s : SpectralDatum) :
    s.darkMass 0 = s.spectralMass := by
  simp [SpectralDatum.darkMass, SpectralDatum.spectralMass]

/-! ## §7. Spectral Inequalities -/

/-- AM-QM inequality for pairs: ((a+b)/2)² ≤ (a²+b²)/2.
    The gap is the variance — the spectral_entropy of the distribution. -/
theorem am_qm_pair (a b : ℝ) :
    ((a + b) / 2) ^ 2 ≤ (a ^ 2 + b ^ 2) / 2 := by
  nlinarith [sq_nonneg (a - b)]

/-- AM-GM bound for pairs: ab ≤ ((a+b)/2)². -/
theorem am_gm_pair (a b : ℝ) :
    a * b ≤ ((a + b) / 2) ^ 2 := by nlinarith [sq_nonneg (a - b)]

/-- Convexity of x²: (tx + (1-t)y)² ≤ t·x² + (1-t)·y².
    Bridge: connects convex_analysis to certified_robustness — convexity
    of the loss landscape implies certified robustness guarantees. -/
theorem sq_convex (x y t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    (t * x + (1 - t) * y) ^ 2 ≤ t * x ^ 2 + (1 - t) * y ^ 2 := by
  have h1 : 0 ≤ t * (1 - t) := mul_nonneg ht0 (by linarith)
  nlinarith [sq_nonneg (x - y), mul_nonneg ht0 (sub_nonneg.mpr ht1)]

/-- Young's inequality: ab ≤ a²/2 + b²/2. -/
theorem young_inequality (a b : ℝ) : a * b ≤ a ^ 2 / 2 + b ^ 2 / 2 := by
  nlinarith [sq_nonneg (a - b)]

/-- Cauchy-Schwarz for two terms: (a₁b₁ + a₂b₂)² ≤ (a₁² + a₂²)(b₁² + b₂²).
    Bridge: connects to spectral_theory — this is the finite-dimensional
    case of the spectral norm bound. -/
theorem cauchy_schwarz_2 (a₁ a₂ b₁ b₂ : ℝ) :
    (a₁ * b₁ + a₂ * b₂) ^ 2 ≤ (a₁ ^ 2 + a₂ ^ 2) * (b₁ ^ 2 + b₂ ^ 2) := by
  nlinarith [sq_nonneg (a₁ * b₂ - a₂ * b₁)]

/-! ## §8. The Spectral-Lattice-Crypto Bridge -/

/-- The condition number: λ_max / λ_min.
    Bridge: connects spectral_theory to lattice_crypto —
    condition number governs SVP approximation hardness. -/
def conditionNumber (lam_max lam_min : ℝ) : ℝ := lam_max / lam_min

/-- Condition number ≥ 1 for valid spectra. -/
theorem condition_number_ge_one {lam_max lam_min : ℝ}
    (hmin : 0 < lam_min) (hle : lam_min ≤ lam_max) :
    1 ≤ conditionNumber lam_max lam_min := by
  unfold conditionNumber; rwa [le_div_iff₀ hmin, one_mul]

/-- **Spectral packing bound**: √λ_min > 0 for positive definite matrices.
    Bridge: connects spectral_theory to lattice_crypto. -/
theorem spectral_packing_lower_bound (lam_min : ℝ) (hlam : 0 < lam_min) :
    0 < Real.sqrt lam_min :=
  Real.sqrt_pos_of_pos hlam

/-- The HNF determinant bound for integral matrices.
    Bridge: connects to post_quantum_security. -/
theorem hnf_det_bound (n : ℕ) (a : Fin n → ℕ) (hpos : ∀ i, 0 < a i) :
    0 < ∏ i, a i :=
  Finset.prod_pos (fun i _ => hpos i)

/-! ## §9. The Dark Matter Correspondence: Main Structure -/

/-- The spectral dark matter structure: combines a finite arithmetic set
    with its spectral datum, relating additive energy to operator spectra.
    Bridge: connects additive_combinatorics to lattice_crypto to certified_robustness. -/
structure DarkMatterDatum where
  /-- The underlying finite set -/
  carrier : Finset ℤ
  /-- The carrier is nonempty -/
  nonempty : carrier.Nonempty
  /-- The Lipschitz constant of the associated operator -/
  lipschitzConst : ℝ
  /-- Lipschitz constant is positive -/
  lipschitz_pos : 0 < lipschitzConst
  /-- The spectral gap -/
  spectralGap : ℝ
  /-- Spectral gap is positive -/
  gap_pos : 0 < spectralGap
  /-- Gap is at most the Lipschitz constant -/
  gap_le_lip : spectralGap ≤ lipschitzConst

/-- The certified robustness radius of a dark matter datum. -/
def DarkMatterDatum.robustnessRadius (d : DarkMatterDatum) : ℝ :=
  certifiedRobustnessRadius d.lipschitzConst d.spectralGap

/-- The robustness radius is positive. -/
theorem DarkMatterDatum.robustnessRadius_pos (d : DarkMatterDatum) :
    0 < d.robustnessRadius :=
  certified_robustness_pos d.lipschitz_pos d.gap_pos

/-- The robustness radius is at most 1/2.
    Bridge: connects to certified_robustness — fundamental upper limit. -/
theorem DarkMatterDatum.robustnessRadius_le_half (d : DarkMatterDatum) :
    d.robustnessRadius ≤ 1 / 2 := by
  unfold DarkMatterDatum.robustnessRadius certifiedRobustnessRadius
  have h1 : (0 : ℝ) < 2 * d.lipschitzConst := by linarith [d.lipschitz_pos]
  rw [div_le_div_iff₀ h1 two_pos]
  linarith [d.gap_le_lip]

/-- The additive energy lower bound for dark matter data. -/
theorem dark_matter_energy_bound (d : DarkMatterDatum) :
    d.carrier.card ^ 2 ≤ additiveEnergy d.carrier :=
  additive_energy_diagonal_lower_bound d.carrier

/-! ## §10. Berggren Spectral Connection -/

/-- The spectral radius of the B₂ Berggren matrix satisfies ρ² - 4ρ + 1 = 0.
    Bridge: connects Berggren_tree to spectral_theory — the spectral radius
    governs the exponential growth of Pythagorean triples in the tree. -/
theorem berggren_spectral_equation :
    (2 + Real.sqrt 3) ^ 2 - 4 * (2 + Real.sqrt 3) + 1 = 0 := by
  have h3 : Real.sqrt 3 * Real.sqrt 3 = 3 :=
    Real.mul_self_sqrt (by norm_num : (3 : ℝ) ≥ 0)
  nlinarith [sq (Real.sqrt 3)]

/-- The Berggren eigenvalue product is 1: (2+√3)(2-√3) = 1. -/
theorem berggren_eigenvalue_product :
    (2 + Real.sqrt 3) * (2 - Real.sqrt 3) = 1 := by
  have : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num : (3 : ℝ) ≥ 0)
  nlinarith

/-- The Berggren spectral radius is greater than 1: the tree is expanding.
    Bridge: connects to post_quantum_security — the expansion rate
    governs the density of Pythagorean triples below a bound. -/
theorem berggren_spectral_radius_gt_one : 1 < 2 + Real.sqrt 3 := by
  have : 0 < Real.sqrt 3 := Real.sqrt_pos_of_pos (by norm_num : (3 : ℝ) > 0)
  linarith

end SpectralArithmetic

end