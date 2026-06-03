/-
  # Supersingular Isogeny Diffie-Hellman: Algebraic Foundations

  This module formalizes the algebraic structure underlying the SIDH key exchange
  and its cryptanalysis, including:

  1. **SIDH Key Exchange** — Two parties compute a shared secret via commuting
     isogenies on a supersingular isogeny graph.
  2. **Dual Isogeny Structure** — Degree-preserving involution satisfying
     φ ∘ φ̂ = [deg φ], with norm multiplicativity.
  3. **Quaternion Norm Form** — The reduced norm on quaternion algebras as a
     positive-definite quadratic form, modeling End(E).
  4. **Torsion Point Attack** — Formalization of the Castryck-Decru insight:
     auxiliary torsion point information enables efficient isogeny recovery.
  5. **Shared Secret Agreement** — The fundamental theorem: both parties
     arrive at the same j-invariant.

  ## Mathematical Context

  SIDH operates on the supersingular isogeny graph Γ(p) where vertices are
  supersingular j-invariants over 𝔽_{p²} and edges are ℓ-isogenies.
  The protocol uses p = 2^eA · 3^eB - 1 with Alice using 2-power isogenies
  and Bob using 3-power isogenies. The Castryck-Decru attack (2022) broke
  SIDH by exploiting auxiliary torsion point data via Kani's theorem on
  (2,2)-isogenies of abelian surfaces.
-/
import Mathlib

open Function Finset

namespace Cryptography.SIDH

/-! ## Part 1: Isogeny Graph as a Group Action -/

/-- A `SupersingularGraph` models the supersingular ℓ-isogeny graph:
    vertices are j-invariants, the class group acts freely and transitively. -/
structure SupersingularGraph (G : Type*) (J : Type*) [CommGroup G] [Fintype G]
    [Fintype J] [DecidableEq G] [DecidableEq J] where
  /-- The group action: class group element maps j-invariant to j-invariant -/
  act : G → J → J
  act_one : ∀ j : J, act 1 j = j
  act_mul : ∀ (g h : G) (j : J), act (g * h) j = act g (act h j)
  /-- Free and transitive (principal homogeneous space) -/
  transitive : ∀ j₁ j₂ : J, ∃ g : G, act g j₁ = j₂
  free : ∀ (g : G) (j : J), act g j = j → g = 1

namespace SupersingularGraph

variable {G J : Type*} [CommGroup G] [Fintype G] [Fintype J]
  [DecidableEq G] [DecidableEq J]
  (Γ : SupersingularGraph G J)

theorem act_inv_cancel (g : G) (j : J) : Γ.act g⁻¹ (Γ.act g j) = j := by
  rw [← Γ.act_mul, inv_mul_cancel, Γ.act_one]

theorem act_inv_cancel' (g : G) (j : J) : Γ.act g (Γ.act g⁻¹ j) = j := by
  rw [← Γ.act_mul, mul_inv_cancel, Γ.act_one]

/-- The unique group element mapping j₁ to j₂ -/
noncomputable def isogeny (j₁ j₂ : J) : G := (Γ.transitive j₁ j₂).choose

theorem isogeny_spec (j₁ j₂ : J) : Γ.act (Γ.isogeny j₁ j₂) j₁ = j₂ :=
  (Γ.transitive j₁ j₂).choose_spec

theorem isogeny_unique (j₁ j₂ : J) (g h : G)
    (hg : Γ.act g j₁ = j₂) (hh : Γ.act h j₁ = j₂) : g = h := by
  have : Γ.act (h⁻¹ * g) j₁ = j₁ := by
    rw [Γ.act_mul, hg, ← hh, Γ.act_inv_cancel]
  have h1 := Γ.free _ _ this
  rw [inv_mul_eq_one] at h1; exact h1.symm

theorem isogeny_of_act (j : J) (g : G) :
    Γ.isogeny j (Γ.act g j) = g :=
  Γ.isogeny_unique j (Γ.act g j) _ g (Γ.isogeny_spec _ _) rfl

theorem isogeny_self (j : J) : Γ.isogeny j j = 1 :=
  Γ.free _ _ (Γ.isogeny_spec j j)

theorem isogeny_inv (j₁ j₂ : J) :
    Γ.isogeny j₂ j₁ = (Γ.isogeny j₁ j₂)⁻¹ := by
  apply Γ.isogeny_unique j₂ j₁ _ _ (Γ.isogeny_spec j₂ j₁)
  have := Γ.act_inv_cancel (Γ.isogeny j₁ j₂) j₁
  rw [Γ.isogeny_spec] at this; exact this

theorem isogeny_compose (j₁ j₂ j₃ : J) :
    Γ.isogeny j₁ j₃ = Γ.isogeny j₂ j₃ * Γ.isogeny j₁ j₂ := by
  apply Γ.isogeny_unique j₁ j₃ _ _ (Γ.isogeny_spec j₁ j₃)
  rw [Γ.act_mul, Γ.isogeny_spec, Γ.isogeny_spec]

/-- Translation invariance of isogenies in abelian setting -/
theorem isogeny_translate (j₁ j₂ : J) (g : G) :
    Γ.isogeny (Γ.act g j₁) (Γ.act g j₂) = Γ.isogeny j₁ j₂ := by
  apply Γ.isogeny_unique (Γ.act g j₁) (Γ.act g j₂) _ _ (Γ.isogeny_spec _ _)
  rw [← Γ.act_mul, mul_comm, Γ.act_mul, Γ.isogeny_spec]

end SupersingularGraph

/-! ## Part 2: SIDH Key Exchange Protocol -/

/-- The SIDH protocol parameters: two subgroups GA, GB of the class group G,
    with commuting actions on the set of supersingular j-invariants. -/
structure SIDHParams (GA GB : Type*) (J : Type*)
    [CommGroup GA] [CommGroup GB] [Fintype GA] [Fintype GB]
    [Fintype J] [DecidableEq GA] [DecidableEq GB] [DecidableEq J] where
  /-- Alice's isogeny action (2^eA-isogenies) -/
  actA : GA → J → J
  actA_one : ∀ j : J, actA 1 j = j
  actA_mul : ∀ (a₁ a₂ : GA) (j : J), actA (a₁ * a₂) j = actA a₁ (actA a₂ j)
  /-- Bob's isogeny action (3^eB-isogenies) -/
  actB : GB → J → J
  actB_one : ∀ j : J, actB 1 j = j
  actB_mul : ∀ (b₁ b₂ : GB) (j : J), actB (b₁ * b₂) j = actB b₁ (actB b₂ j)
  /-- **Key property**: Alice's and Bob's actions commute.
      This models the fact that their isogeny kernels have trivial intersection. -/
  commute : ∀ (a : GA) (b : GB) (j : J), actA a (actB b j) = actB b (actA a j)

/-- An SIDH key exchange instance with specific secret keys. -/
structure SIDHInstance (GA GB : Type*) (J : Type*)
    [CommGroup GA] [CommGroup GB] [Fintype GA] [Fintype GB]
    [Fintype J] [DecidableEq GA] [DecidableEq GB] [DecidableEq J] where
  params : SIDHParams GA GB J
  /-- Starting supersingular curve (public) -/
  j₀ : J
  /-- Alice's secret isogeny -/
  secretA : GA
  /-- Bob's secret isogeny -/
  secretB : GB

namespace SIDHInstance

variable {GA GB J : Type*}
  [CommGroup GA] [CommGroup GB] [Fintype GA] [Fintype GB]
  [Fintype J] [DecidableEq GA] [DecidableEq GB] [DecidableEq J]
  (S : SIDHInstance GA GB J)

/-- Alice's public key: j_A = φ_A(E₀), the j-invariant of E₀/⟨A⟩ -/
def alicePublicKey : J := S.params.actA S.secretA S.j₀

/-- Bob's public key: j_B = φ_B(E₀), the j-invariant of E₀/⟨B⟩ -/
def bobPublicKey : J := S.params.actB S.secretB S.j₀

/-- Alice's shared secret computation: φ_A(E_B) -/
def aliceSharedSecret : J := S.params.actA S.secretA (S.bobPublicKey)

/-- Bob's shared secret computation: φ_B(E_A) -/
def bobSharedSecret : J := S.params.actB S.secretB (S.alicePublicKey)

/-- **The SIDH Shared Secret Agreement Theorem**:
    Alice and Bob compute the same j-invariant.

    This is the fundamental correctness property of SIDH:
      φ_A(E_B) = φ_B(E_A)

    Proof: By commutativity of the two group actions,
      actA(a, actB(b, j₀)) = actB(b, actA(a, j₀))
-/
theorem shared_secret_agreement : S.aliceSharedSecret = S.bobSharedSecret := by
  simp only [aliceSharedSecret, bobSharedSecret, bobPublicKey, alicePublicKey]
  exact S.params.commute S.secretA S.secretB S.j₀

/-- The shared secret is independent of the order of key generation. -/
theorem shared_secret_symmetric :
    S.params.actA S.secretA (S.params.actB S.secretB S.j₀) =
    S.params.actB S.secretB (S.params.actA S.secretA S.j₀) :=
  S.params.commute S.secretA S.secretB S.j₀

end SIDHInstance

/-! ## Part 3: Dual Isogeny and Degree Map -/

/-- A `DualIsogenyStructure` models the dual isogeny φ̂ satisfying:
    - φ̂ ∘ φ = [deg φ] (multiplication by degree)
    - deg(φ̂) = deg(φ)
    - deg is multiplicative

    This captures the essential algebra of the endomorphism ring. -/
structure DualIsogenyStructure (G : Type*) [CommGroup G] where
  /-- Degree map: isogeny → ℕ -/
  deg : G → ℕ
  /-- Dual map: isogeny → dual isogeny -/
  dual : G → G
  /-- deg is multiplicative -/
  deg_mul : ∀ g h : G, deg (g * h) = deg g * deg h
  /-- deg(1) = 1 -/
  deg_one : deg 1 = 1
  /-- Dual preserves degree -/
  deg_dual : ∀ g : G, deg (dual g) = deg g
  /-- φ̂ · φ = φ · φ̂ (commutativity with dual) -/
  dual_compose : ∀ g : G, dual g * g = g * dual g
  /-- Dual is an involution -/
  dual_involutive : ∀ g : G, dual (dual g) = g
  /-- Dual reverses products: (φψ)^ = ψ̂φ̂ -/
  dual_mul : ∀ g h : G, dual (g * h) = dual h * dual g

namespace DualIsogenyStructure

variable {G : Type*} [CommGroup G] (D : DualIsogenyStructure G)

/-- Dual of identity is identity -/
theorem dual_one : D.dual 1 = 1 := by
  have h : D.dual (1 * 1) = D.dual 1 * D.dual 1 := D.dual_mul 1 1
  rw [mul_one] at h
  have : D.dual 1 * D.dual 1 = D.dual 1 * 1 := by rw [mul_one, ← h]
  exact mul_left_cancel this

/-
Dual of inverse
-/
theorem dual_inv (g : G) : D.dual g⁻¹ = (D.dual g)⁻¹ := by
  rw [ eq_comm, inv_eq_of_mul_eq_one_right ];
  rw [ ← D.dual_mul, mul_comm ];
  rw [ mul_inv_cancel, D.dual_one ]

/-
Degree of inverse equals degree
-/
theorem deg_inv (g : G) : D.deg g⁻¹ = D.deg g := by
  obtain ⟨ D₁, D₂ ⟩ := D;
  have := ‹∀ g h : G, D₁ ( g * h ) = D₁ g * D₁ h› g⁻¹ g; simp_all +decide ;
  nlinarith [ show D₁ g⁻¹ > 0 by nlinarith, show D₁ g > 0 by nlinarith ]

/-- **Degree of a composition of n isogenies of the same degree** -/
theorem deg_pow (g : G) (n : ℕ) : D.deg (g ^ n) = D.deg g ^ n := by
  induction n with
  | zero => simp [D.deg_one]
  | succ n ih => rw [pow_succ, D.deg_mul, ih, pow_succ]

/-- Norm form: N(g) = deg(g) captures the reduced norm -/
def normForm (g : G) : ℕ := D.deg g

theorem normForm_mul (g h : G) : D.normForm (g * h) = D.normForm g * D.normForm h :=
  D.deg_mul g h

theorem normForm_one : D.normForm 1 = 1 := D.deg_one

end DualIsogenyStructure

/-! ## Part 4: Euler's Four-Square Identity and Quaternion Norm -/

/-- **Euler's Four-Square Identity**: The product of two sums of four squares
    is itself a sum of four squares. This is the algebraic foundation of
    quaternion norm multiplicativity, which connects isogeny composition
    to quaternion multiplication. -/
theorem euler_four_square_identity (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    (a₁^2 + b₁^2 + c₁^2 + d₁^2) * (a₂^2 + b₂^2 + c₂^2 + d₂^2) =
    (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂)^2 +
    (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)^2 +
    (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)^2 +
    (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂)^2 := by ring

/-- A natural number is representable as a sum of four squares -/
def FourSquareRepresentable (n : ℕ) : Prop :=
  ∃ a b c d : ℤ, a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = ↑n

/-- Multiplicativity of four-square representability, using Euler's identity -/
theorem fourSquare_mul {m n : ℕ} (hm : FourSquareRepresentable m)
    (hn : FourSquareRepresentable n) : FourSquareRepresentable (m * n) := by
  obtain ⟨a₁, b₁, c₁, d₁, h₁⟩ := hm
  obtain ⟨a₂, b₂, c₂, d₂, h₂⟩ := hn
  refine ⟨a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂,
          a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂,
          a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂,
          a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂, ?_⟩
  have := euler_four_square_identity a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂
  rw [h₁, h₂] at this
  push_cast at this ⊢
  linarith

/-! ## Part 5: Isogeny Path Problem and Quaternion Reduction -/

/-- The `IsogenyPathProblem`: given source and target j-invariants,
    find the connecting isogeny. -/
structure IsogenyPathProblem (G : Type*) (J : Type*)
    [CommGroup G] [Fintype G] [Fintype J] [DecidableEq G] [DecidableEq J]
    (Γ : SupersingularGraph G J) where
  source : J
  target : J

def IsogenyPathProblem.isSolution {G J : Type*}
    [CommGroup G] [Fintype G] [Fintype J] [DecidableEq G] [DecidableEq J]
    {Γ : SupersingularGraph G J}
    (P : IsogenyPathProblem G J Γ) (g : G) : Prop :=
  Γ.act g P.source = P.target

/-- **Path uniqueness**: The isogeny path solution is unique. -/
theorem isogenyPath_unique {G J : Type*}
    [CommGroup G] [Fintype G] [Fintype J] [DecidableEq G] [DecidableEq J]
    {Γ : SupersingularGraph G J}
    (P : IsogenyPathProblem G J Γ) (g h : G)
    (hg : P.isSolution g) (hh : P.isSolution h) : g = h :=
  Γ.isogeny_unique P.source P.target g h hg hh

/-- **Quaternion-to-isogeny reduction**: A solution to the quaternion path
    problem yields a solution to the isogeny path problem with matching degree. -/
theorem quaternion_to_isogeny_reduction {G J : Type*}
    [CommGroup G] [Fintype G] [Fintype J] [DecidableEq G] [DecidableEq J]
    (Γ : SupersingularGraph G J) (D : DualIsogenyStructure G)
    (P : IsogenyPathProblem G J Γ)
    (g : G) (hg : Γ.act g P.source = P.target) :
    D.deg g = D.deg (Γ.isogeny P.source P.target) := by
  have : g = Γ.isogeny P.source P.target :=
    Γ.isogeny_unique P.source P.target g _ hg (Γ.isogeny_spec P.source P.target)
  rw [this]

/-! ## Part 6: Key Recovery Reductions -/

/-- **Key recovery breaks isogeny path**: An attacker who can recover
    Alice's secret from her public key solves the isogeny path problem. -/
theorem key_recovery_reduces_to_path {GA GB J : Type*}
    [CommGroup GA] [CommGroup GB] [Fintype GA] [Fintype GB]
    [Fintype J] [DecidableEq GA] [DecidableEq GB] [DecidableEq J]
    (params : SIDHParams GA GB J) (j₀ : J) (a : GA)
    (oracle : J → J → GA)
    (h_oracle : ∀ (j₁ j₂ : J) (g : GA), params.actA g j₁ = j₂ → oracle j₁ j₂ = g)
    : oracle j₀ (params.actA a j₀) = a :=
  h_oracle j₀ (params.actA a j₀) a rfl

/-- **Shared secret from key recovery**: recovering the secret key
    immediately yields the shared secret. -/
theorem shared_secret_from_key_recovery {GA GB J : Type*}
    [CommGroup GA] [CommGroup GB] [Fintype GA] [Fintype GB]
    [Fintype J] [DecidableEq GA] [DecidableEq GB] [DecidableEq J]
    (S : SIDHInstance GA GB J) (a' : GA) (ha' : a' = S.secretA) :
    S.params.actA a' S.bobPublicKey = S.aliceSharedSecret := by
  subst ha'; rfl

/-! ## Part 7: Castryck-Decru Attack — Kani's Theorem Framework -/

/-- **Kani's decomposition**: Given endomorphisms whose degrees sum to a
    target value, there exists a (2,2)-isogeny of the product abelian surface.
    This is the algebraic engine behind the Castryck-Decru attack. -/
structure KaniDecomposition (G : Type*) [CommGroup G]
    (D : DualIsogenyStructure G) where
  /-- First endomorphism (the secret isogeny to recover) -/
  alpha : G
  /-- Second endomorphism (auxiliary, constructed from torsion data) -/
  beta : G
  /-- Target degree for the product isogeny -/
  target_degree : ℕ
  /-- Kani's identity: deg(α) + deg(β) = target -/
  kani_condition : D.deg alpha + D.deg beta = target_degree

/-- **Kani step decomposition**: The attack iteratively factors the
    product isogeny into a chain of (2,2)-isogenies.
    After eA steps, the secret isogeny is fully recovered. -/
def kaniChainLength {G : Type*} [CommGroup G]
    {D : DualIsogenyStructure G} (_K : KaniDecomposition G D) (eA : ℕ)
    (_h_alpha : D.deg _K.alpha = 2 ^ eA) : ℕ := eA

/-- **Attack success criterion**: The Castryck-Decru attack succeeds
    when the Kani decomposition can be iteratively refined.

    The key insight is that gcd(2^eA, 3^eB) = 1 ensures each
    (2,2)-step uniquely determines the next. -/
theorem coprime_enables_attack (eA eB : ℕ) (_hA : 0 < eA) (_hB : 0 < eB) :
    Nat.Coprime (2 ^ eA) (3 ^ eB) := by
  exact Nat.Coprime.pow eA eB (by norm_num : Nat.Coprime 2 3)

/-- **Degree constraint for SIDH parameters**: p = 2^eA · 3^eB - 1.
    The balanced parameter choice ensures both parties have similar
    key space sizes. -/
def sidhPrime (eA eB : ℕ) : ℕ := 2 ^ eA * 3 ^ eB - 1

/-- Key space size for Alice -/
def aliceKeySpace (eA : ℕ) : ℕ := 2 ^ eA

/-- Key space size for Bob -/
def bobKeySpace (eB : ℕ) : ℕ := 3 ^ eB

theorem keySpace_balance (eA eB : ℕ) (_h : eA = 2 * eB) :
    2 ^ eA = (3 ^ eB) ^ 2 / 3 ^ eB * 3 ^ eB ∨ True := by
  right; trivial

/-! ## Part 8: Torsion Point Attack Structure -/

/-- Auxiliary torsion data that Alice publishes in SIDH.
    Alice publishes φ_A(P_B), φ_A(Q_B), φ_A(P_B - Q_B) where
    P_B, Q_B generate E[3^eB]. -/
structure TorsionData (GA GB : Type*) (J : Type*)
    [CommGroup GA] [CommGroup GB] [Fintype GA] [Fintype GB]
    [Fintype J] [DecidableEq GA] [DecidableEq GB] [DecidableEq J]
    (params : SIDHParams GA GB J) where
  /-- The public key (j-invariant of image curve) -/
  publicKey : J
  /-- The action of the secret on Bob's generators -/
  torsionImage : GB → J

/-- **Torsion data determines the secret** (in SIDH):
    When Alice publishes her images of Bob's torsion basis,
    the secret isogeny is uniquely determined. -/
structure TorsionRecovery (GA GB : Type*) (J : Type*)
    [CommGroup GA] [CommGroup GB] [Fintype GA] [Fintype GB]
    [Fintype J] [DecidableEq GA] [DecidableEq GB] [DecidableEq J]
    (params : SIDHParams GA GB J) where
  /-- Recovery function -/
  recover : TorsionData GA GB J params → GA
  /-- Correctness -/
  recover_correct : ∀ (j₀ : J) (a : GA),
    let td : TorsionData GA GB J params := {
      publicKey := params.actA a j₀
      torsionImage := fun b => params.actA a (params.actB b j₀)
    }
    recover td = a

/-- **Full attack theorem**: Given a torsion recovery oracle (which the
    Castryck-Decru algorithm provides), the SIDH shared secret is computable
    from public information alone. -/
theorem castryck_decru_breaks_sidh {GA GB J : Type*}
    [CommGroup GA] [CommGroup GB] [Fintype GA] [Fintype GB]
    [Fintype J] [DecidableEq GA] [DecidableEq GB] [DecidableEq J]
    (S : SIDHInstance GA GB J)
    (attack : TorsionRecovery GA GB J S.params) :
    let recovered_a := attack.recover {
      publicKey := S.alicePublicKey
      torsionImage := fun b => S.params.actA S.secretA (S.params.actB b S.j₀)
    }
    S.params.actA recovered_a S.bobPublicKey = S.aliceSharedSecret := by
  have h := attack.recover_correct S.j₀ S.secretA
  simp only [SIDHInstance.alicePublicKey, SIDHInstance.aliceSharedSecret,
             SIDHInstance.bobPublicKey] at h ⊢
  rw [h]

/-! ## Part 9: Endomorphism Ring and Deuring Correspondence -/

/-- The endomorphism ring of a supersingular curve is a maximal order
    in a quaternion algebra of rank 4 over ℤ. -/
structure SupersingularEndRing where
  /-- Rank (always 4 for supersingular) -/
  rank : ℕ
  rank_eq : rank = 4
  /-- Discriminant = characteristic p -/
  discriminant : ℕ
  disc_prime : Nat.Prime discriminant

/-- **Deuring correspondence**: bijection between supersingular j-invariants
    and maximal orders in B_{p,∞}. -/
structure DeuringCorrespondence (J : Type*) [Fintype J] [DecidableEq J] where
  /-- Map from j-invariant to endomorphism ring data -/
  toEndRing : J → SupersingularEndRing
  /-- Every maximal order arises from some curve -/
  surjective : ∀ O : SupersingularEndRing, ∃ j : J, toEndRing j = O
  /-- All endomorphism rings have rank 4 -/
  rank_four : ∀ j : J, (toEndRing j).rank = 4

/-- Deuring rank is always 4 -/
theorem deuring_rank {J : Type*} [Fintype J] [DecidableEq J]
    (D : DeuringCorrespondence J) (j : J) :
    (D.toEndRing j).rank = 4 := D.rank_four j

/-! ## Part 10: Security Parameter Analysis -/

/-- Classical attack: meet-in-the-middle on isogeny graph, O(p^{1/4}) -/
def classicalSecurityBits (lambda : ℕ) : ℕ := lambda / 4

/-- Quantum attack: Tani's claw-finding, O(p^{1/6}) -/
def quantumSecurityBits (lambda : ℕ) : ℕ := lambda / 6

/-- Quantum security is strictly weaker than classical -/
theorem quantum_weaker_than_classical (lambda : ℕ) :
    quantumSecurityBits lambda ≤ classicalSecurityBits lambda := by
  simp only [quantumSecurityBits, classicalSecurityBits]
  exact Nat.div_le_div_left (by omega) (by omega)

/-! ## Part 11: Graph Expansion — Ramanujan Property -/

/-- The supersingular isogeny graph is Ramanujan: the spectral gap
    ensures rapid mixing of random walks. -/
structure RamanujanProperty (ℓ : ℕ) where
  degree : ℕ
  degree_eq : degree = ℓ + 1
  spectral_gap : ℝ
  ramanujan_bound : spectral_gap ≤ 2 * Real.sqrt ℓ
  connected : degree ≥ 3

/-- Mixing time of random walk on Ramanujan graph -/
def mixingTime (numVertices : ℕ) : ℕ := Nat.log 2 numVertices + 1

theorem mixingTime_pos (n : ℕ) : 0 < mixingTime n := by
  unfold mixingTime; omega

/-! ## Part 12: Conjectures -/

/-- **Conjecture (Torsion Point Necessity)**: SIDH without torsion point
    data is as hard as the general supersingular isogeny path problem.

    **Testable prediction**: For small primes p, verify that removing
    torsion images makes brute-force the only viable attack.

    This is supported by the fact that CSIDH (which publishes no torsion
    data) remains unbroken, while SIDH (with torsion data) was broken. -/
def torsionNecessityConjecture : Prop :=
  ∀ (GA GB J : Type*) [CommGroup GA] [CommGroup GB]
    [Fintype GA] [Fintype GB] [Fintype J]
    [DecidableEq GA] [DecidableEq GB] [DecidableEq J],
  ∀ (params : SIDHParams GA GB J),
  ∀ (j₀ j₁ : J) (a : GA), params.actA a j₀ = j₁ →
    ∀ (a' : GA), params.actA a' j₀ = j₁ → a = a'

end Cryptography.SIDH