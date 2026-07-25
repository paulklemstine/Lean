/-
  Speculative/ProofCompression.lean

  Normalizer-Invariance and Universality Classes for Proof Compression

  This file formalizes the theory that asymptotic proof compression phases
  are invariant under polynomial simulation between deterministic normalizers.
  The central insight: whether normalization causes polynomial or superpolynomial
  blowup is an intrinsic property of the proof system and statement family,
  not an artifact of the chosen normalizer.
-/
import Mathlib

namespace ProofCompression

/-! ## Section 1: Basic Definitions -/

/-- A proof system over statements `Stmt` and proofs `Proof`, with a provability
    relation and a size measure. We separate the proof system from normalizers
    so that multiple normalizers can be compared on a common foundation. -/
structure ProofSystem (Stmt Proof : Type*) where
  /-- Whether proof `p` proves statement `φ`. -/
  proves  : Proof → Stmt → Prop
  /-- The size of a raw proof. -/
  rawSize : Proof → ℕ

variable {Stmt Proof : Type*}

/-- A normalizer is sound if it preserves provability. -/
def ProofSystem.SoundNormalizer (PS : ProofSystem Stmt Proof) (N : Proof → Proof) : Prop :=
  ∀ ⦃p φ⦄, PS.proves p φ → PS.proves (N p) φ

/-! ## Section 2: Asymptotic Predicates -/

/-- Normalization is **polynomially bounded** on a family `fam`: there exist `k, c`
    such that for every proof of any family member, the normalized size is at most
    `c * (rawSize + 1)^k`. The `+1` ensures the bound is meaningful even for
    proofs of size zero. -/
def ProofSystem.PolyBoundedNorm (PS : ProofSystem Stmt Proof)
    (N : Proof → Proof) (fam : ℕ → Stmt) : Prop :=
  ∃ k c : ℕ, ∀ n p, PS.proves p (fam n) →
    PS.rawSize (N p) ≤ c * (PS.rawSize p + 1) ^ k

/-- Normalization exhibits **superpolynomial blowup** on a family: for every
    polynomial bound `c * (rawSize + 1)^k`, there exists a proof of some family
    member that violates it. This is precisely the negation of `PolyBoundedNorm`. -/
def ProofSystem.SuperPolyBlowup (PS : ProofSystem Stmt Proof)
    (N : Proof → Proof) (fam : ℕ → Stmt) : Prop :=
  ∀ k c : ℕ, ∃ n p, PS.proves p (fam n) ∧
    c * (PS.rawSize p + 1) ^ k < PS.rawSize (N p)

/-- One normalizer **polynomially simulates** another: `N₂`'s normalized sizes
    are bounded by a polynomial of `N₁`'s normalized sizes. -/
def ProofSystem.NormPolySimulates (PS : ProofSystem Stmt Proof)
    (N₁ N₂ : Proof → Proof) : Prop :=
  ∃ k c : ℕ, ∀ p,
    PS.rawSize (N₂ p) ≤ c * (PS.rawSize (N₁ p) + 1) ^ k

/-- Two normalizers are **norm-polynomially equivalent**: each polynomially
    simulates the other. -/
def ProofSystem.NormPolyEquiv (PS : ProofSystem Stmt Proof)
    (N₁ N₂ : Proof → Proof) : Prop :=
  PS.NormPolySimulates N₁ N₂ ∧ PS.NormPolySimulates N₂ N₁

/-! ## Section 3: Arithmetic Foundation

The key technical engine: polynomial bounds compose under substitution.
If `a ≤ c₁ * (b+1)^k₁` and `b ≤ c₂ * (x+1)^k₂`, then
`a ≤ (c₁ * (c₂+1)^k₁) * (x+1)^(k₂*k₁)`.

This is the formal backbone of all transfer theorems. -/

/-
Polynomial bounds compose: if `a` is polynomially bounded in `b` and
    `b` is polynomially bounded in `x`, then `a` is polynomially bounded in `x`.
-/
theorem poly_bound_comp {a b x c₁ c₂ k₁ k₂ : ℕ}
    (h1 : a ≤ c₁ * (b + 1) ^ k₁)
    (h2 : b ≤ c₂ * (x + 1) ^ k₂) :
    a ≤ c₁ * (c₂ + 1) ^ k₁ * (x + 1) ^ (k₂ * k₁) := by
  refine le_trans h1 ?_;
  rw [ mul_assoc, pow_mul ];
  exact Nat.mul_le_mul_left _ ( by rw [ ← mul_pow ] ; gcongr ; nlinarith [ pow_pos ( Nat.succ_pos x ) k₂ ] )

/-! ## Section 4: Duality of Phases

`SuperPolyBlowup` and `PolyBoundedNorm` are exact negations of each other.
This is essential for the contrapositive arguments in transfer theorems. -/

/-
Superpolynomial blowup implies the absence of polynomial bounds.
-/
theorem superPoly_implies_not_polyBounded (PS : ProofSystem Stmt Proof)
    {N : Proof → Proof} {fam : ℕ → Stmt}
    (hS : PS.SuperPolyBlowup N fam) :
    ¬PS.PolyBoundedNorm N fam := by
  exact fun h => by obtain ⟨ k, c, h₁ ⟩ := h; obtain ⟨ n, p, h₂, h₃ ⟩ := hS k c; linarith [ h₁ n p h₂ ] ;

/-
The absence of polynomial bounds implies superpolynomial blowup.
-/
theorem not_polyBounded_implies_superPoly (PS : ProofSystem Stmt Proof)
    {N : Proof → Proof} {fam : ℕ → Stmt}
    (hNP : ¬PS.PolyBoundedNorm N fam) :
    PS.SuperPolyBlowup N fam := by
  exact fun k c => by contrapose! hNP; exact ⟨ k, c, hNP ⟩ ;

/-
Polynomial boundedness and superpolynomial blowup are contradictory.
-/
theorem polyBounded_superPoly_contradiction (PS : ProofSystem Stmt Proof)
    {N : Proof → Proof} {fam : ℕ → Stmt}
    (hP : PS.PolyBoundedNorm N fam)
    (hS : PS.SuperPolyBlowup N fam) :
    False := by
  exact superPoly_implies_not_polyBounded PS hS hP

/-! ## Section 5: Transfer Theorems

The main results: polynomial normalization bounds transfer across
polynomial simulation, and the same holds for superpolynomial blowup. -/

/-
**Polynomial Transfer Theorem.** If `N₁` polynomially simulates `N₂`
    (i.e., `N₂`'s normalized sizes are bounded by a polynomial of `N₁`'s),
    and `N₁` has polynomially bounded normalization on a family, then `N₂`
    also has polynomially bounded normalization.
-/
theorem poly_transfer_of_norm_sim (PS : ProofSystem Stmt Proof)
    {N₁ N₂ : Proof → Proof} {fam : ℕ → Stmt}
    (hSim : PS.NormPolySimulates N₁ N₂)
    (hBound : PS.PolyBoundedNorm N₁ fam) :
    PS.PolyBoundedNorm N₂ fam := by
  -- By definition of polynomial simulation, we have that for any proof p, the size of N₂ p is bounded by a polynomial of the size of N₁ p.
  obtain ⟨k, c, hSim⟩ := hSim;
  -- By definition of polynomial boundedness, we have that for any proof p, the size of N₁ p is bounded by a polynomial of the raw size of p.
  obtain ⟨k', c', hBound⟩ := hBound;
  exact ⟨ k' * k, c * ( c' + 1 ) ^ k, fun n p hp => by simpa [ mul_assoc, mul_comm, mul_left_comm, pow_mul ] using poly_bound_comp ( hSim p ) ( hBound n p hp ) ⟩

/-
**No Poly-vs-SuperPoly Separation Theorem.** Under polynomial simulation,
    one normalizer cannot have polynomial normalization while the other has
    superpolynomial blowup. This is the formal impossibility result showing
    that compression phase is not an artifact of normalizer choice.
-/
theorem no_poly_vs_superpoly_separation (PS : ProofSystem Stmt Proof)
    {N₁ N₂ : Proof → Proof} {fam : ℕ → Stmt}
    (hSim : PS.NormPolySimulates N₁ N₂)
    (hPoly : PS.PolyBoundedNorm N₁ fam)
    (hSuper : PS.SuperPolyBlowup N₂ fam) :
    False := by
  exact polyBounded_superPoly_contradiction PS ( poly_transfer_of_norm_sim PS hSim hPoly ) hSuper

/-
**Superpolynomial Transfer Theorem.** If `N₂` polynomially simulates `N₁`
    and `N₁` has superpolynomial blowup, then `N₂` also has superpolynomial blowup.
    This is the contrapositive of the polynomial transfer theorem.
-/
theorem superpoly_transfer_of_norm_sim (PS : ProofSystem Stmt Proof)
    {N₁ N₂ : Proof → Proof} {fam : ℕ → Stmt}
    (hSim : PS.NormPolySimulates N₂ N₁)
    (hBlow : PS.SuperPolyBlowup N₁ fam) :
    PS.SuperPolyBlowup N₂ fam := by
  grind +suggestions

/-! ## Section 6: Phase Invariance

We define a compression phase dichotomy and prove it is invariant under
norm-polynomial equivalence. -/

/-- Compression phase: either polynomial or superpolynomial normalization. -/
inductive CompressionPhase
  | poly
  | superpoly
  deriving DecidableEq

/-- A family has a given compression phase under a normalizer. -/
def ProofSystem.HasPhase (PS : ProofSystem Stmt Proof)
    (N : Proof → Proof) (fam : ℕ → Stmt) : CompressionPhase → Prop
  | .poly => PS.PolyBoundedNorm N fam
  | .superpoly => PS.SuperPolyBlowup N fam

/-
**Phase Invariance Theorem.** Under norm-polynomial equivalence,
    the compression phase is preserved. If two normalizers are polynomially
    equivalent, they assign the same compression phase to every family.
-/
theorem phase_invariant_of_norm_equiv (PS : ProofSystem Stmt Proof)
    {N₁ N₂ : Proof → Proof} {fam : ℕ → Stmt}
    (hEquiv : PS.NormPolyEquiv N₁ N₂) :
    ∀ π, PS.HasPhase N₁ fam π → PS.HasPhase N₂ fam π := by
  intro π hπ; cases π <;> simp_all +decide only [ProofSystem.HasPhase] ;
  · exact poly_transfer_of_norm_sim PS hEquiv.1 hπ;
  · exact superpoly_transfer_of_norm_sim PS hEquiv.2 hπ

/-! ## Section 7: Algebraic Properties of Polynomial Simulation

Norm-polynomial simulation forms a preorder, and equivalence classes
constitute universality classes for proof compression. -/

/-
**Reflexivity**: every normalizer polynomially simulates itself.
-/
theorem norm_poly_sim_refl (PS : ProofSystem Stmt Proof) (N : Proof → Proof) :
    PS.NormPolySimulates N N := by
  exact ⟨ 1, 1, fun p => by simp +decide ⟩

/-
**Transitivity**: polynomial simulation composes.
-/
theorem norm_poly_sim_trans (PS : ProofSystem Stmt Proof)
    {N₁ N₂ N₃ : Proof → Proof}
    (h₁₂ : PS.NormPolySimulates N₁ N₂)
    (h₂₃ : PS.NormPolySimulates N₂ N₃) :
    PS.NormPolySimulates N₁ N₃ := by
  -- By definition of norm-polynomial simulation, obtain k₁, c₁ and k₂, c₂ from h₁₂ and h₂₃.
  obtain ⟨k₁, c₁, h₁₂⟩ := h₁₂
  obtain ⟨k₂, c₂, h₂₃⟩ := h₂₃
  use k₁ * k₂, c₂ * (c₁ + 1)^k₂;
  intro p
  specialize h₂₃ p
  specialize h₁₂ p
  have h_poly_bound : PS.rawSize (N₃ p) ≤ c₂ * (c₁ * (PS.rawSize (N₁ p) + 1) ^ k₁ + 1) ^ k₂ := by
    exact h₂₃.trans ( Nat.mul_le_mul_left _ ( Nat.pow_le_pow_left ( Nat.succ_le_succ h₁₂ ) _ ) );
  rw [ mul_assoc, pow_mul ];
  refine' h_poly_bound.trans ( Nat.mul_le_mul_left _ _ );
  rw [ ← mul_pow ] ; gcongr ; nlinarith [ pow_pos ( Nat.succ_pos ( PS.rawSize ( N₁ p ) ) ) k₁ ] ;

/-- **Norm-polynomial equivalence is reflexive.** -/
theorem norm_poly_equiv_refl (PS : ProofSystem Stmt Proof) (N : Proof → Proof) :
    PS.NormPolyEquiv N N :=
  ⟨norm_poly_sim_refl PS N, norm_poly_sim_refl PS N⟩

/-- **Norm-polynomial equivalence is symmetric.** -/
theorem norm_poly_equiv_symm (PS : ProofSystem Stmt Proof)
    {N₁ N₂ : Proof → Proof}
    (h : PS.NormPolyEquiv N₁ N₂) :
    PS.NormPolyEquiv N₂ N₁ :=
  ⟨h.2, h.1⟩

/-- **Norm-polynomial equivalence is transitive.** -/
theorem norm_poly_equiv_trans (PS : ProofSystem Stmt Proof)
    {N₁ N₂ N₃ : Proof → Proof}
    (h₁₂ : PS.NormPolyEquiv N₁ N₂)
    (h₂₃ : PS.NormPolyEquiv N₂ N₃) :
    PS.NormPolyEquiv N₁ N₃ :=
  ⟨norm_poly_sim_trans PS h₁₂.1 h₂₃.1, norm_poly_sim_trans PS h₂₃.2 h₁₂.2⟩

end ProofCompression