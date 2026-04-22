import Mathlib

/-! # CatalogBuild.Tropical.Langlands.AdvancedTheory

Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 24
-/

noncomputable section

/-- Tropical orbital integral: infimum over the "group" of conjugates -/
def tropOrbitalIntegral (f : ℝ → ℝ) (gamma : ℝ) : ℝ :=
  ⨅ g : ℝ, f (g + gamma - g)

/-- Tropical orbital integral simplifies when f is translation-invariant -/
theorem tropOrbitalIntegral_simp (f : ℝ → ℝ) (gamma : ℝ) :
    tropOrbitalIntegral f gamma = ⨅ _ : ℝ, f gamma := by
  simp [tropOrbitalIntegral, add_sub_cancel_left]

/-- Spectral side of the tropical trace formula for GL_1 -/
def tropSpectralSide (eigenvalues : Finset ℝ) (f : ℝ → ℝ) : ℝ :=
  ⨅ ev ∈ eigenvalues, f ev

/-- Geometric side of the tropical trace formula for GL_1 -/
def tropGeometricSide (conjugacyClasses : Finset ℝ) (f : ℝ → ℝ) : ℝ :=
  ⨅ gamma ∈ conjugacyClasses, f gamma

/-- Tropical trace formula for GL_1: spectral = geometric when eigenvalues = conjugacy classes -/
theorem tropTraceFormula_GL1
    (S : Finset ℝ) (f : ℝ → ℝ) :
    tropSpectralSide S f = tropGeometricSide S f := by
  simp [tropSpectralSide, tropGeometricSide]

/-- A tropical L-homomorphism is a piecewise-linear map between tropical Satake parameter spaces -/
structure TropicalLHomomorphism (m n : ℕ) where
  toFun : (Fin m → ℝ) → (Fin n → ℝ)
  preserves_order : ∀ (x : Fin m → ℝ) (i j : Fin n),
    i ≤ j → (toFun x) i ≤ (toFun x) j
  piecewise_linear : ∀ (x y : Fin m → ℝ) (t : ℝ),
    toFun (fun k => t * x k + (1 - t) * y k) =
    fun k => t * (toFun x) k + (1 - t) * (toFun y) k

/-- The symmetric power L-homomorphism: GL_2 → GL_{n+1}
sends Satake parameters (a, b) to (na, (n-1)a+b, ..., nb) -/
def tropSymPower (n : ℕ) : (Fin 2 → ℝ) → (Fin (n + 1) → ℝ) :=
  fun params => fun i =>
    let a := params 0
    let b := params 1
    (n - i.val) * a + i.val * b

/-- [Section: # CatalogBuild.Tropical.Langlands.AdvancedTheory
Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 24] -/
theorem tropSymPower_ordered (n : ℕ) (params : Fin 2 → ℝ)
    (hord : params 0 ≤ params 1) (i j : Fin (n + 1)) (hij : i ≤ j) :
    tropSymPower n params i ≤ tropSymPower n params j := by
  unfold tropSymPower;
  nlinarith [ show ( i : ℝ ) ≤ j from Nat.cast_le.mpr hij ]

/-- A tropical representation of the graph's fundamental group -/
structure TropicalRepresentation (G : MetricGraph) (n : ℕ) where
  generators : Fin G.vertices → (Fin n → ℝ) → (Fin n → ℝ)
  is_translation : ∀ v, ∃ shift : Fin n → ℝ,
    ∀ x : Fin n → ℝ, generators v x = fun i => x i + shift i

/-- A tropical line bundle on a metric graph is a divisor (function vertices -> Z) -/
structure TropicalLineBundle (G : MetricGraph) where
  degree_at : Fin G.vertices → ℤ

/-- The degree of a tropical line bundle -/
def TropicalLineBundle.degree (G : MetricGraph) (L : TropicalLineBundle G) : ℤ :=
  ∑ v : Fin G.vertices, L.degree_at v

/-- The tropical Picard group: line bundles modulo principal divisors.
Two divisors are equivalent if they differ by a chip-firing move. -/
def tropEquivalent (G : MetricGraph) (D1 D2 : TropicalLineBundle G) : Prop :=
  ∃ f : Fin G.vertices → ℤ,
    ∀ v : Fin G.vertices, D1.degree_at v - D2.degree_at v =
      ∑ w : Fin G.vertices, (if (G.edges v w).isSome then f v - f w else 0)

/-- [Section: # CatalogBuild.Tropical.Langlands.AdvancedTheory
Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 24] -/
theorem tropEquiv_same_degree (G : MetricGraph) (D1 D2 : TropicalLineBundle G)
    (h : tropEquivalent G D1 D2) :
    TropicalLineBundle.degree G D1 = TropicalLineBundle.degree G D2 := by
  -- By definition of degree, we can expand the difference in degrees.
  have h_deg_diff : ∑ v : Fin G.vertices, (D1.degree_at v - D2.degree_at v) = 0 := by
    obtain ⟨ f, hf ⟩ := h;
    simp_all +decide [ Finset.sum_ite ];
    rw [ sub_eq_zero, Finset.sum_congr rfl fun i hi => Finset.sum_filter _ _ ];
    rw [ Finset.sum_comm ];
    simp +decide [ Finset.sum_ite, MetricGraph.edge_sym ];
  exact eq_of_sub_eq_zero ( by simpa [ TropicalLineBundle.degree ] using h_deg_diff )

/-- Finite Kantorovich problem: optimal transport between finitely supported measures -/
def kantorovichCost (n m : ℕ) (c : Fin n → Fin m → ℝ)
    (coupling : Fin n → Fin m → ℝ) : ℝ :=
  ∑ i : Fin n, ∑ j : Fin m, coupling i j * c i j

/-- Kantorovich dual objective -/
def kantorovichDual (n m : ℕ) (phi : Fin n → ℝ) (psi : Fin m → ℝ)
    (mu : Fin n → ℝ) (nu : Fin m → ℝ) : ℝ :=
  ∑ i : Fin n, phi i * mu i + ∑ j : Fin m, psi j * nu j

theorem kantorovich_weak_duality
    (n m : ℕ) (c : Fin n → Fin m → ℝ) (mu : Fin n → ℝ) (nu : Fin m → ℝ)
    (coupling : Fin n → Fin m → ℝ)
    (phi : Fin n → ℝ) (psi : Fin m → ℝ)
    (hcoupling_nonneg : ∀ i j, 0 ≤ coupling i j)
    (hcoupling_mu : ∀ i, ∑ j : Fin m, coupling i j = mu i)
    (hcoupling_nu : ∀ j, ∑ i : Fin n, coupling i j = nu j)
    (hdual : ∀ i j, phi i + psi j ≤ c i j) :
    kantorovichDual n m phi psi mu nu ≤ kantorovichCost n m c coupling := by
  -- By definition of $kantorovichDual$ and $kantorovichCost$, we can expand both sides.
  have h_expand : (∑ i, phi i * mu i + ∑ j, psi j * nu j) = (∑ i, ∑ j, coupling i j * (phi i + psi j)) := by
    simp +decide only [← hcoupling_mu, Finset.mul_sum _ _ _, mul_comm, ← hcoupling_nu, mul_add, sum_add_distrib];
    exact congr rfl ( Finset.sum_comm );
  exact h_expand.le.trans ( Finset.sum_le_sum fun i hi => Finset.sum_le_sum fun j hj => mul_le_mul_of_nonneg_left ( hdual i j ) ( hcoupling_nonneg i j ) )

/-- Tropical norm map for a degree-d covering of metric graphs -/
def tropNormMap (d : ℕ) (f : Fin d → ℝ) : ℝ :=
  ∑ i : Fin d, f i

theorem tropNormMap_additive (d : ℕ) (f g : Fin d → ℝ) :
    tropNormMap d (fun i => f i + g i) = tropNormMap d f + tropNormMap d g := by
  exact Finset.sum_add_distrib

/-- Tropical local Langlands for GL_1: the identity correspondence -/
def tropLocalLanglands_GL1 : ℝ → ℝ := id

/-- Tropical local Langlands for GL_1 is a bijection -/
theorem tropLocalLanglands_GL1_bijective : Function.Bijective tropLocalLanglands_GL1 :=
  Function.bijective_id

/-- Tropical local Langlands for GL_1 preserves the L-function -/
theorem tropLocalLanglands_GL1_preserves_L (s a : ℝ) :
    (s - tropLocalLanglands_GL1 a) = (s - a) := by
  simp [tropLocalLanglands_GL1]

/-- Chip-firing Laplacian on a complete graph K_n -/
def chipFireLaplacian (n : ℕ) (f : Fin n → ℝ) : Fin n → ℝ :=
  fun v => (n - 1) * f v - ∑ w : Fin n, if v = w then 0 else f w

theorem chipFire_constant_kernel (n : ℕ) (c : ℝ) :
    chipFireLaplacian n (fun _ => c) = fun _ => 0 := by
  funext v; simp [chipFireLaplacian];
  simp +decide [ Finset.sum_ite, Finset.filter_ne ];
  rw [ Nat.cast_pred ] <;> linarith [ Fin.is_lt v ]

theorem chipFire_selfadjoint (n : ℕ) (f g : Fin n → ℝ) :
    ∑ v : Fin n, f v * chipFireLaplacian n g v =
    ∑ v : Fin n, chipFireLaplacian n f v * g v := by
  simp +decide only [chipFireLaplacian, mul_comm];
  simp +decide [ mul_sub, Finset.sum_ite, Finset.filter_ne ];
  simp +decide only [← sum_mul, mul_left_comm, mul_comm]

end
