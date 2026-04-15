/-! # CatalogBuild.Computation.Oracles.MetaOracles

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 21
-/

import Mathlib

noncomputable section

/-- Minkowski inner product in (1+1) dimensions. -/
def minkowski (v w : ℝ × ℝ) : ℝ := v.1 * w.1 - v.2 * w.2


/-- A vector is null (lightlike) if its Minkowski self-product vanishes. -/
def IsNull (v : ℝ × ℝ) : Prop := minkowski v v = 0


/-- The right-moving photon vector is null. -/
theorem photonRight_isNull : IsNull (1, 1) := by
  unfold IsNull minkowski; ring


/-- The left-moving photon vector is null. -/
theorem photonLeft_isNull : IsNull (1, -1) := by
  unfold IsNull minkowski; ring


theorem null_right_eigenvector (φ a : ℝ) :
    lorentzBoost φ (a, a) = (a * Real.exp φ, a * Real.exp φ) := by
  unfold lorentzBoost;
  rw [ Real.cosh_eq, Real.sinh_eq ] ; ring


theorem null_left_eigenvector (φ a : ℝ) :
    lorentzBoost φ (a, -a) = (a * Real.exp (-φ), -(a * Real.exp (-φ))) := by
  unfold lorentzBoost; ring; ext <;> norm_num [ Real.exp_neg, Real.cosh_eq, Real.sinh_eq ] <;> ring;


theorem lorentz_preserves_minkowski (φ : ℝ) (v w : ℝ × ℝ) :
    minkowski (lorentzBoost φ v) (lorentzBoost φ w) = minkowski v w := by
  unfold minkowski lorentzBoost ; ring ; norm_num [ Real.sinh_sq _, mul_comm ] ; ring;


/-- **Null cone is Lorentz-invariant**: if v is null, then its boost is null. -/
theorem null_preserved_by_boost (φ : ℝ) (v : ℝ × ℝ) (hv : IsNull v) :
    IsNull (lorentzBoost φ v) := by
  unfold IsNull at *
  rw [lorentz_preserves_minkowski]
  exact hv


/-- The fixed-point set of a function. -/
def fixedPointSet (f : α → α) : Set α := {x | f x = x}


/-- **Fixed points are stable under iteration**: applying f any number of times
to a fixed point returns the same point. -/
theorem fixed_point_iterate {α : Type*} {f : α → α} {x : α} (hx : f x = x)
    (n : ℕ) : f^[n] x = x := by
  induction n with
  | zero => rfl
  | succ n ih => rw [Function.iterate_succ_apply', ih, hx]


/-- **Composition of viewpoints**: if x is a fixed point of both f and g,
it is a fixed point of f ∘ g. -/
theorem fixed_point_comp {f g : α → α} {x : α}
    (hf : f x = x) (hg : g x = x) :
    (f ∘ g) x = x := by
  show f (g x) = x
  rw [hg, hf]


theorem linear_iterate (c x : ℝ) (n : ℕ) :
    (fun x : ℝ => c * x)^[n] x = c ^ n * x := by
  induction n <;> simp +decide [ *, pow_succ', mul_assoc, Function.iterate_succ_apply' ]


theorem oracle_diagonalization (P : ℕ → ℕ → Bool) :
    ∃ f : ℕ → Bool, ∀ n : ℕ, f ≠ P n := by
  exact ⟨ fun n => if P n n = Bool.true then Bool.false else Bool.true, fun n => fun h => by have := congr_fun h n; by_cases h' : P n n = Bool.true <;> simp +decide [ h' ] at this ⟩


theorem no_universal_oracle (enumerate : ℕ → (ℕ → Bool)) :
    ¬ Function.Surjective enumerate := by
  by_contra! h_surj;
  obtain ⟨ m, hm ⟩ := h_surj ( fun n ↦ !enumerate n n ) ; specialize hm ; replace hm := congr_fun hm m ; aesop;


/-- A **Viewpoint** is a fixed point of a dynamical system. -/
structure Viewpoint {α : Type*} (f : α → α) where
  state : α
  consistent : f state = state


/-- **Viewpoint Stability**: A viewpoint persists through arbitrarily
many applications of the dynamics. -/
theorem viewpoint_stable {f : α → α} (v : Viewpoint f) (n : ℕ) :
    f^[n] v.state = v.state :=
  fixed_point_iterate v.consistent n


/-- **Existence of Viewpoints from Self-Reference (Consciousness Theorem)**:
If a system can completely model its own state transformations,
then every transformation has a self-consistent viewpoint. -/
theorem consciousness_has_viewpoints {A : Type*} (φ : A → (A → A))
    (hφ : Function.Surjective φ) (f : A → A) :
    ∃ v : Viewpoint f, True := by
  obtain ⟨b, hb⟩ := lawvere_fixed_point φ hφ f
  exact ⟨⟨b, hb⟩, trivial⟩


/-- The light cone at the origin: all null vectors. -/
def lightCone : Set (ℝ × ℝ) := {v | IsNull v}


theorem lightCone_characterization (v : ℝ × ℝ) :
    v ∈ lightCone ↔ v.1 = v.2 ∨ v.1 = -v.2 := by
  grind +locals


theorem lightCone_lorentz_invariant (φ : ℝ) :
    lorentzBoost φ '' lightCone = lightCone := by
  ext v;
  -- To prove the forward direction, assume $v$ is in the image of the light cone under the Lorentz boost.
  apply Iff.intro
  intro hv
  obtain ⟨w, hw, rfl⟩ := hv
  exact null_preserved_by_boost φ w hw;
  intro hv
  use lorentzBoost (-φ) v;
  constructor;
  · exact null_preserved_by_boost _ _ hv;
  · unfold lorentzBoost; ring; norm_num [ Real.sinh_neg, Real.cosh_neg, Real.sinh_sq ] ; ring;
    norm_num [ Real.sinh_sq ] ; ring


theorem viewpoint_universality :
    -- Part 1: Photon viewpoints exist (null eigenvectors of boosts)
    (∀ φ : ℝ, ∃ v : ℝ × ℝ, v ≠ (0, 0) ∧
      ∃ c : ℝ, lorentzBoost φ v = (c * v.1, c * v.2)) ∧
    -- Part 2: Self-referential viewpoints exist (Lawvere)
    (∀ (A : Type) (φ : A → (A → A)), Function.Surjective φ →
      ∀ f : A → A, ∃ x : A, f x = x) := by
  constructor;
  · -- Consider the null vector $(1, 1)$ which is non-zero.
    intro φ
    use (1, 1)
    simp [lorentzBoost];
  · exact?


end
