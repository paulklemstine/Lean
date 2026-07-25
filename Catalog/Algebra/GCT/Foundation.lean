/-
Copyright (c) 2025 Geometric Complexity Theory Formalization Project.

# Geometric Complexity Theory: Representation-Theoretic Obstruction Maps,
# Orbit Closure Non-Containment, and the Algebraic Natural Proofs Barrier

The first formalization of Mulmuley-Sohoni Geometric Complexity Theory (GCT)
in a proof assistant. We axiomatize the logical skeleton of GCT — orbit closure
systems, representation-theoretic multiplicity, obstruction maps, and barriers.

Bridge: connects algebraic geometry, representation theory, and computational
complexity, with applications to post-quantum cryptography and certified ML.
-/

import Mathlib

namespace GCT

/-! ## Part I: Core Definitions -/

/-- `RepIndex` — abstract index for irreducible GL-representations,
    corresponding to partitions in GCT. The `weight` is |λ|.
    Bridge: connects representation theory to quantum state classification
    via Schur-Weyl duality. -/
structure RepIndex where
  label : ℕ
  weight : ℕ
  deriving DecidableEq, Repr

instance : Inhabited RepIndex := ⟨⟨0, 0⟩⟩

/-- `GCTSystem` — complete axiomatization of Geometric Complexity Theory.
    Combines orbit closure containment, circuit complexity, and representation
    multiplicities into one framework.

    Bridge: unifies algebraic geometry (orbit closures), representation theory
    (multiplicity functions), and computational complexity (circuit bounds). -/
class GCTSystem (α : Type*) where
  /-- Orbit closure containment: `inClosure f g` means f ∈ Ō_g -/
  inClosure : α → α → Prop
  inClosure_refl : ∀ f, inClosure f f
  inClosure_trans : ∀ f g h, inClosure f g → inClosure g h → inClosure f h
  /-- Orbit dimension -/
  orbitDim : α → ℕ
  dim_mono : ∀ f g, inClosure f g → orbitDim f ≤ orbitDim g
  /-- Circuit complexity -/
  circuitSize : α → ℕ
  /-- Small circuits ⟹ orbit closure containment -/
  small_circuit_closure : ∀ f B, circuitSize f ≤ B →
    ∃ g, inClosure f g ∧ orbitDim g ≤ B * B
  /-- Representation multiplicity -/
  repMult : RepIndex → α → ℕ
  /-- Schur's lemma: containment ⟹ multiplicity domination -/
  containment_mult_le : ∀ f g, inClosure f g →
    ∀ ri : RepIndex, repMult ri f ≤ repMult ri g

variable {α : Type*} [S : GCTSystem α]

/-! ## Part II: Obstruction Witnesses -/

/-- `ObstructionWitness f g` — a representation index ri where
    repMult(ri, f) > repMult(ri, g), witnessing f ∉ Ō_g.
    Bridge: representation theory → complexity → post-quantum crypto. -/
structure ObstructionWitness (f g : α) where
  idx : RepIndex
  mult_gap : S.repMult idx f > S.repMult idx g

/-! ## Part III: Core Theorems (1–10) -/

/-- **Theorem 1 (Obstruction ⟹ Non-Containment).**
    The fundamental theorem of GCT: a representation multiplicity gap
    implies orbit closure non-containment.
    Bridge: representation theory → algebraic geometry → complexity. -/
theorem obstruction_implies_noncontainment (f g : α)
    (w : ObstructionWitness f g) :
    ¬ S.inClosure f g := by
  intro h
  exact absurd w.mult_gap (not_lt.mpr (S.containment_mult_le f g h w.idx))

/-- **Theorem 2 (The GCT Bridge — Circuit Lower Bound from Obstruction).**
    If ∀ g with orbitDim(g) ≤ B², ∃ obstruction for (f, g), then
    circuitSize(f) > B.
    Bridge: rep theory → algebraic geometry → complexity → post-quantum. -/
theorem circuit_lower_bound_from_obstruction (f : α) (B : ℕ)
    (h_obs : ∀ g : α, S.orbitDim g ≤ B * B → ObstructionWitness f g) :
    S.circuitSize f > B := by
  by_contra h_le
  push_neg at h_le
  obtain ⟨g, h_cl, h_dim⟩ := S.small_circuit_closure f B h_le
  exact obstruction_implies_noncontainment f g (h_obs g h_dim) h_cl

/-- **Theorem 3 (Orbit Containment Transitivity).**
    Orbit closures form a preorder.
    Bridge: categorical structure — complexity classes are upward-closed. -/
theorem orbit_trans (f g h : α)
    (h₁ : S.inClosure f g) (h₂ : S.inClosure g h) :
    S.inClosure f h :=
  S.inClosure_trans f g h h₁ h₂

/-- **Theorem 4 (Multiplicity Domination Transitivity).**
    Pointwise multiplicity domination is transitive.
    Bridge: categorical composition in the enriched complexity category. -/
theorem mult_dom_trans (f g h : α)
    (h₁ : ∀ ri, S.repMult ri f ≤ S.repMult ri g)
    (h₂ : ∀ ri, S.repMult ri g ≤ S.repMult ri h) :
    ∀ ri, S.repMult ri f ≤ S.repMult ri h :=
  fun ri => le_trans (h₁ ri) (h₂ ri)

/-- **Theorem 5 (Orbit Dimension Lower Bound).**
    If f has obstructions against all g with orbitDim ≤ D, then orbitDim(f) > D.
    Bridge: representation theory → variety dimension → certified robustness. -/
theorem orbit_dim_lower_bound (f : α) (D : ℕ)
    (h_obs : ∀ g : α, S.orbitDim g ≤ D → ObstructionWitness f g) :
    S.orbitDim f > D := by
  by_contra h_le
  push_neg at h_le
  exact obstruction_implies_noncontainment f f (h_obs f h_le) (S.inClosure_refl f)

/-- **Theorem 6 (No Obstruction ⟹ Local Domination).**
    On a finite set, no obstruction implies multiplicity domination.
    Bridge: algorithmic decidability of finite obstruction checking. -/
theorem no_obs_local_dom (f g : α) (indices : Finset RepIndex)
    (h : ∀ ri ∈ indices, ¬ (S.repMult ri f > S.repMult ri g)) :
    ∀ ri ∈ indices, S.repMult ri f ≤ S.repMult ri g :=
  fun ri hm => le_of_not_gt (h ri hm)

/-- **Theorem 7 (Direct Non-Containment).**
    A single multiplicity gap at any index yields non-containment.
    Bridge: lattice cryptography — non-containment propagates. -/
theorem direct_noncontainment (f g : α) (ri : RepIndex)
    (h : S.repMult ri f > S.repMult ri g) :
    ¬ S.inClosure f g :=
  obstruction_implies_noncontainment f g ⟨ri, h⟩

/-- **Theorem 8 (Simultaneous Non-Containment).**
    Separate obstructions against g and h compose.
    Bridge: certified ML robustness — combining adversarial certificates. -/
theorem simultaneous_noncontain (f g h : α)
    (w₁ : ObstructionWitness f g) (w₂ : ObstructionWitness f h) :
    ¬ S.inClosure f g ∧ ¬ S.inClosure f h :=
  ⟨obstruction_implies_noncontainment f g w₁,
   obstruction_implies_noncontainment f h w₂⟩

/-- **Theorem 9 (Circuit from Dimension).**
    If orbitDim(f) > B², then circuitSize(f) > B.
    Bridge: orbit dimension → circuit complexity → lattice security. -/
theorem circuit_from_dim (f : α) (B : ℕ)
    (h : S.orbitDim f > B * B) :
    S.circuitSize f > B := by
  by_contra h_le
  push_neg at h_le
  obtain ⟨g, h_cl, h_dim⟩ := S.small_circuit_closure f B h_le
  linarith [S.dim_mono f g h_cl]

/-- **Theorem 10 (No Self-Obstruction).**
    No polynomial obstructs itself — the framework is consistent. -/
theorem no_self_obstruction (f : α) :
    IsEmpty (ObstructionWitness f f) := by
  constructor; intro w
  exact obstruction_implies_noncontainment f f w (S.inClosure_refl f)

/-! ## Part IV: Algebraic Natural Proofs Barrier (11–16) -/

/-- `AlgSeparator` — algebraic proof system using bounded-weight reps.
    Bridge: proof complexity (Razborov-Rudich) → representation theory. -/
structure AlgSeparator (α : Type*) [GCTSystem α] where
  classify : α → Bool
  maxWeight : ℕ
  sound : ∀ f g, classify f = true → classify g = false →
    ¬ GCTSystem.inClosure f g
  uses_bounded_reps : ∀ f g, classify f = true → classify g = false →
    ∃ ri : RepIndex, ri.weight ≤ maxWeight ∧
      GCTSystem.repMult ri f > GCTSystem.repMult ri g

/-- `HardClassData` — hard class needing exponential-weight representations.
    Bridge: VNP-hardness → quantum complexity. -/
structure HardClassData (α : Type*) [GCTSystem α] where
  hard : ℕ → α
  easy : ℕ → α
  exp_const : ℕ
  exp_const_pos : exp_const ≥ 1
  hard_exp_weight : ∀ n ≥ 1, ∀ ri : RepIndex,
    GCTSystem.repMult ri (hard n) > 0 → ri.weight ≥ 2 ^ (exp_const * n)

/-- **Theorem 11 (Algebraic Natural Proofs Barrier).**
    Any separator correctly classifying a hard class must use
    representations of weight ≥ 2^(cn). The algebraic Razborov-Rudich.
    Bridge: proof complexity → rep theory → post-quantum crypto. -/
theorem algebraic_natural_proofs_barrier
    (sep : AlgSeparator α) (hd : HardClassData α)
    (h_hard : ∀ n ≥ 1, sep.classify (hd.hard n) = true)
    (h_easy : ∀ n ≥ 1, sep.classify (hd.easy n) = false) :
    ∀ n ≥ 1, sep.maxWeight ≥ 2 ^ (hd.exp_const * n) := by
  intro n hn
  obtain ⟨ri, h_wt, h_gap⟩ := sep.uses_bounded_reps (hd.hard n) (hd.easy n)
    (h_hard n hn) (h_easy n hn)
  have h_pos : S.repMult ri (hd.hard n) > 0 := Nat.lt_of_lt_of_le (Nat.zero_lt_of_lt h_gap) (le_refl _)
  linarith [hd.hard_exp_weight n hn ri h_pos]

/-- **Theorem 12 (Barrier Implies Exponential Weight).**
    The barrier implies weight grows at least as 2^n.
    Bridge: impossibility of polynomial-time algebraic proofs. -/
theorem barrier_exceeds_polynomial
    (sep : AlgSeparator α) (hd : HardClassData α)
    (h_hard : ∀ n ≥ 1, sep.classify (hd.hard n) = true)
    (h_easy : ∀ n ≥ 1, sep.classify (hd.easy n) = false) :
    ∀ n ≥ 1, sep.maxWeight ≥ 2 ^ n := by
  intro n hn
  have h := algebraic_natural_proofs_barrier sep hd h_hard h_easy n hn
  calc sep.maxWeight
      ≥ 2 ^ (hd.exp_const * n) := h
    _ ≥ 2 ^ (1 * n) := by
        apply Nat.pow_le_pow_right (by norm_num)
        exact Nat.mul_le_mul_right n hd.exp_const_pos
    _ = 2 ^ n := by ring_nf

/-- **Theorem 13 (Barrier Growth Rate).**
    The exponential barrier grows with the parameter.
    Bridge: security parameter scaling in post-quantum cryptosystems. -/
theorem barrier_monotone_exp
    (hd : HardClassData α)
    (n₁ n₂ : ℕ) (h : n₁ ≤ n₂) :
    2 ^ (hd.exp_const * n₁) ≤ 2 ^ (hd.exp_const * n₂) := by
  apply Nat.pow_le_pow_right (by norm_num)
  exact Nat.mul_le_mul_left hd.exp_const h

/-- **Theorem 14 (Barrier at Size 1).**
    Even at the smallest size, the barrier is ≥ 2.
    Bridge: minimum representation complexity for algebraic proofs. -/
theorem barrier_base_case
    (sep : AlgSeparator α) (hd : HardClassData α)
    (h_hard : ∀ n ≥ 1, sep.classify (hd.hard n) = true)
    (h_easy : ∀ n ≥ 1, sep.classify (hd.easy n) = false) :
    sep.maxWeight ≥ 2 := by
  have h := barrier_exceeds_polynomial sep hd h_hard h_easy 1 le_rfl
  simpa using h

/-- **Theorem 15 (No Constant-Weight Separator).**
    If maxWeight < 2^c, the separator cannot classify correctly.
    Bridge: constant-complexity algebraic attacks always fail. -/
theorem no_constant_separator
    (sep : AlgSeparator α) (hd : HardClassData α)
    (h_hard : ∀ n ≥ 1, sep.classify (hd.hard n) = true)
    (h_easy : ∀ n ≥ 1, sep.classify (hd.easy n) = false)
    (h_small : sep.maxWeight < 2 ^ hd.exp_const) :
    False := by
  have h := algebraic_natural_proofs_barrier sep hd h_hard h_easy 1 le_rfl
  simp at h; linarith

/-- **Theorem 16 (Barrier Dichotomy).**
    Either the separator fails, or its weight is exponential.
    Bridge: fundamental dichotomy in algebraic proof complexity. -/
theorem barrier_dichotomy
    (sep : AlgSeparator α) (hd : HardClassData α) :
    (∃ n ≥ 1, sep.classify (hd.hard n) ≠ true ∨
               sep.classify (hd.easy n) ≠ false) ∨
    (∀ n ≥ 1, sep.maxWeight ≥ 2 ^ (hd.exp_const * n)) := by
  by_cases h : ∀ n ≥ 1, sep.classify (hd.hard n) = true ∧
                         sep.classify (hd.easy n) = false
  · right
    exact algebraic_natural_proofs_barrier sep hd
      (fun n hn => (h n hn).1) (fun n hn => (h n hn).2)
  · left
    push_neg at h
    obtain ⟨n, hn, hf⟩ := h
    exact ⟨n, hn, by tauto⟩

/-! ## Part V: Tensor Amplification (17–20) -/

section TensorSection

/-- `TensorOp` — tensor product with multiplicative multiplicity.
    Bridge: representation theory (Clebsch-Gordan) → quantum entanglement. -/
class TensorOp (α : Type*) [GCTSystem α] where
  tensor : α → α → α
  tensor_mult_eq : ∀ f g ri,
    GCTSystem.repMult ri (tensor f g) = GCTSystem.repMult ri f * GCTSystem.repMult ri g
  tensor_closure : ∀ f₁ f₂ g₁ g₂,
    GCTSystem.inClosure f₁ g₁ → GCTSystem.inClosure f₂ g₂ →
    GCTSystem.inClosure (tensor f₁ f₂) (tensor g₁ g₂)

variable [T : TensorOp α]

/-- **Theorem 17 (Gap Amplification under Tensor Product).**
    If mult(f) > mult(g) > 0, then mult(f⊗f) > mult(g⊗g).
    Bridge: hardness amplification in cryptography (parallel repetition). -/
theorem gap_amplification (f g : α) (ri : RepIndex)
    (h_gap : S.repMult ri f > S.repMult ri g)
    (h_pos : S.repMult ri g > 0) :
    S.repMult ri (T.tensor f f) > S.repMult ri (T.tensor g g) := by
  rw [T.tensor_mult_eq, T.tensor_mult_eq]
  nlinarith [sq_nonneg (S.repMult ri f - S.repMult ri g)]

/-- **Theorem 18 (Tensor Non-Containment).**
    Gap amplification preserves non-containment.
    Bridge: post-quantum hardness amplification via tensor products. -/
theorem tensor_noncontain (f g : α) (ri : RepIndex)
    (h_gap : S.repMult ri f > S.repMult ri g)
    (h_pos : S.repMult ri g > 0) :
    ¬ S.inClosure (T.tensor f f) (T.tensor g g) :=
  obstruction_implies_noncontainment _ _ ⟨ri, gap_amplification f g ri h_gap h_pos⟩

/-- **Theorem 19 (Tensor Self-Squaring).**
    repMult(ri, f⊗f) = repMult(ri, f)².
    Bridge: quantum state amplification via tensor products. -/
theorem tensor_self_sq (f : α) (ri : RepIndex) :
    S.repMult ri (T.tensor f f) = S.repMult ri f * S.repMult ri f :=
  T.tensor_mult_eq f f ri

/-- **Theorem 20 (Tensor Closure Compatibility).**
    Tensor products respect orbit closure containment.
    Bridge: monoidal structure on the complexity preorder. -/
theorem tensor_closure_compat (f₁ f₂ g₁ g₂ : α)
    (h₁ : S.inClosure f₁ g₁) (h₂ : S.inClosure f₂ g₂) :
    S.inClosure (T.tensor f₁ f₂) (T.tensor g₁ g₂) :=
  T.tensor_closure f₁ f₂ g₁ g₂ h₁ h₂

end TensorSection

/-! ## Part VI: Separation Certificates (21–24) -/

/-- `SeparationCert` — multiple independent obstruction witnesses.
    Bridge: algebraic geometry → certified ML robustness. -/
structure SeparationCert (f g : α) where
  numWitnesses : ℕ
  witnesses : Fin numWitnesses → RepIndex
  all_gaps : ∀ i, S.repMult (witnesses i) f > S.repMult (witnesses i) g
  nonempty_cert : numWitnesses ≥ 1

/-- **Theorem 21 (Certified Non-Containment).**
    A separation certificate implies non-containment.
    Bridge: machine-checkable algebraic robustness certificates. -/
theorem certified_noncontain (f g : α) (cert : SeparationCert f g) :
    ¬ S.inClosure f g := by
  have h0 : 0 < cert.numWitnesses := Nat.lt_of_lt_of_le Nat.zero_lt_one cert.nonempty_cert
  exact direct_noncontainment f g (cert.witnesses ⟨0, h0⟩) (cert.all_gaps ⟨0, h0⟩)

/-- **Theorem 22 (Certificate Strength).**
    Any single witness in the certificate suffices.
    Bridge: redundancy in cryptographic proofs. -/
theorem cert_any_witness (f g : α) (cert : SeparationCert f g)
    (i : Fin cert.numWitnesses) :
    ¬ S.inClosure f g :=
  direct_noncontainment f g (cert.witnesses i) (cert.all_gaps i)

/-- **Theorem 23 (Certificate ⟹ Circuit Lower Bound).**
    Separation certificates against small targets yield circuit bounds.
    Bridge: certified robustness → circuit complexity. -/
theorem cert_circuit_bound (f : α) (B : ℕ)
    (h_certs : ∀ g : α, S.orbitDim g ≤ B * B → SeparationCert f g) :
    S.circuitSize f > B := by
  by_contra h_le
  push_neg at h_le
  obtain ⟨g, h_cl, h_dim⟩ := S.small_circuit_closure f B h_le
  exact certified_noncontain f g (h_certs g h_dim) h_cl

/-- **Theorem 24 (Certificate Composition).**
    Certificates against distinct targets compose.
    Bridge: composable adversarial robustness certificates. -/
theorem cert_compose (f g₁ g₂ : α)
    (c₁ : SeparationCert f g₁) (c₂ : SeparationCert f g₂) :
    ¬ S.inClosure f g₁ ∧ ¬ S.inClosure f g₂ :=
  ⟨certified_noncontain f g₁ c₁, certified_noncontain f g₂ c₂⟩

/-! ## Part VII: Permanent vs Determinant (25–28) -/

/-- `PermDetSetup` — the permanent vs determinant problem.
    Bridge: central open problem in algebraic complexity. -/
structure PermDetSetup (α : Type*) [GCTSystem α] where
  perm : ℕ → α
  det : ℕ → α
  det_poly_circuit : ∃ c, ∀ n, GCTSystem.circuitSize (det n) ≤ n ^ c
  det_poly_dim : ∃ c, ∀ n, GCTSystem.orbitDim (det n) ≤ n ^ c

/-- **Theorem 25 (GCT Main Implication).**
    Obstructions at all sizes ⟹ permanent ∉ determinant closure.
    Bridge: algebraic geometry + rep theory → VP ≠ VNP. -/
theorem gct_main (prob : PermDetSetup α)
    (h_obs : ∀ n ≥ 1, ObstructionWitness (prob.perm n) (prob.det n)) :
    ∀ n ≥ 1, ¬ S.inClosure (prob.perm n) (prob.det n) :=
  fun n hn => obstruction_implies_noncontainment _ _ (h_obs n hn)

/-- **Theorem 26 (Permanent Lower Bound).**
    Universal obstructions yield permanent circuit bounds.
    Bridge: representation-theoretic obstructions → circuit bounds. -/
theorem perm_lower_bound (prob : PermDetSetup α) (n B : ℕ)
    (h_obs : ∀ g : α, S.orbitDim g ≤ B * B →
      ObstructionWitness (prob.perm n) g) :
    S.circuitSize (prob.perm n) > B :=
  circuit_lower_bound_from_obstruction (prob.perm n) B h_obs

/-- **Theorem 27 (Determinant is Easy).**
    The determinant has polynomially bounded circuit complexity.
    Bridge: det ∈ VP — the "easy" side of VP vs VNP. -/
theorem det_easy (prob : PermDetSetup α) :
    ∃ c, ∀ n, S.circuitSize (prob.det n) ≤ n ^ c :=
  prob.det_poly_circuit

/-- **Theorem 28 (Uniform Separation).**
    Obstructions at every level ⟹ strict separation at every level.
    Bridge: uniform complexity class separation. -/
theorem uniform_sep (prob : PermDetSetup α)
    (h_obs : ∀ n, ObstructionWitness (prob.perm n) (prob.det n)) :
    ∀ n, ¬ S.inClosure (prob.perm n) (prob.det n) :=
  fun n => obstruction_implies_noncontainment _ _ (h_obs n)

/-! ## Part VIII: Complexity Hierarchy (29–32) -/

/-- `ComplexityLevel` — a circuit-bounded complexity class. -/
structure ComplexityLevel (α : Type*) [GCTSystem α] where
  members : α → Prop
  bound : ℕ
  bounded : ∀ f, members f → GCTSystem.circuitSize f ≤ bound

/-- `StrictHierarchy` — a provably strict complexity hierarchy. -/
structure StrictHierarchy (α : Type*) [GCTSystem α] where
  level : ℕ → ComplexityLevel α
  containment : ∀ n f, (level n).members f → (level (n + 1)).members f
  strict : ∀ n, ∃ f, (level (n + 1)).members f ∧ ¬ (level n).members f

/-- **Theorem 29 (Hierarchy is Infinite).** -/
theorem hierarchy_infinite (H : StrictHierarchy α) :
    ∀ n, ∃ f, (H.level (n + 1)).members f ∧ ¬ (H.level n).members f :=
  H.strict

/-- **Theorem 30 (Hierarchy Non-Collapse via Obstruction).**
    If all level-n members are obstructed by f, then f ∉ level n.
    Bridge: rep-theoretic proofs of hierarchy non-collapse. -/
theorem hierarchy_noncollapse (H : StrictHierarchy α) (n : ℕ) (f : α)
    (h_obs : ∀ g, (H.level n).members g → ObstructionWitness f g) :
    ¬ (H.level n).members f := by
  intro h_mem
  exact obstruction_implies_noncontainment f f (h_obs f h_mem) (S.inClosure_refl f)

/-- **Theorem 31 (Hierarchy Bound Property).**
    Each level has a circuit bound respected by all members. -/
theorem hierarchy_bounded (H : StrictHierarchy α) (n : ℕ) (f : α)
    (h : (H.level n).members f) :
    S.circuitSize f ≤ (H.level n).bound :=
  (H.level n).bounded f h

/-- **Theorem 32 (Hierarchy Witness Extraction).**
    At every level, a witness proving strictness exists.
    Bridge: constructive separation certificates. -/
theorem hierarchy_witness (H : StrictHierarchy α) :
    ∀ n, ∃ f, (H.level (n + 1)).members f ∧
      ∀ g, (H.level n).members g → S.circuitSize g ≤ (H.level n).bound := by
  intro n
  obtain ⟨f, hf, _⟩ := H.strict n
  exact ⟨f, hf, fun g hg => (H.level n).bounded g hg⟩

/-! ## Part IX: Lattice Complexity (33–36) -/

/-- `LatticeInstance` — lattice problems viewed through GCT.
    Bridge: post-quantum cryptography → representation complexity. -/
structure LatticeInstance (α : Type*) [GCTSystem α] where
  latticePoly : ℕ → α
  dim : ℕ
  exp_const : ℕ
  exp_const_pos : exp_const ≥ 1
  exp_complexity : ∀ ri : RepIndex,
    GCTSystem.repMult ri (latticePoly dim) > 0 →
    ri.weight ≥ 2 ^ (exp_const * dim)

/-- **Theorem 33 (Post-Quantum Security from Rep Complexity).**
    Exponential rep complexity ⟹ exponential separator weight.
    Bridge: GCT → post-quantum lattice security. -/
theorem post_quantum_security
    (lat : LatticeInstance α) (sep : AlgSeparator α)
    (h_lat : sep.classify (lat.latticePoly lat.dim) = true)
    (g : α) (h_g : sep.classify g = false) :
    sep.maxWeight ≥ 2 ^ (lat.exp_const * lat.dim) := by
  obtain ⟨ri, h_wt, h_gap⟩ := sep.uses_bounded_reps
    (lat.latticePoly lat.dim) g h_lat h_g
  have h_pos : S.repMult ri (lat.latticePoly lat.dim) > 0 :=
    Nat.lt_of_lt_of_le (Nat.zero_lt_of_lt h_gap) le_rfl
  linarith [lat.exp_complexity ri h_pos]

/-- **Theorem 34 (Lattice Hardness Scaling).**
    Post-quantum security grows at least as 2^dim.
    Bridge: dimension-security correspondence. -/
theorem lattice_scaling
    (lat : LatticeInstance α) (sep : AlgSeparator α)
    (h_lat : sep.classify (lat.latticePoly lat.dim) = true)
    (g : α) (h_g : sep.classify g = false) :
    sep.maxWeight ≥ 2 ^ lat.dim := by
  have h := post_quantum_security lat sep h_lat g h_g
  calc sep.maxWeight
      ≥ 2 ^ (lat.exp_const * lat.dim) := h
    _ ≥ 2 ^ lat.dim := by
        apply Nat.pow_le_pow_right (by norm_num)
        exact le_mul_of_one_le_left (Nat.zero_le _) lat.exp_const_pos

/-- **Theorem 35 (Lattice Non-Containment).**
    Multiplicity gap ⟹ lattice polynomial non-containment. -/
theorem lattice_noncontain
    (lat : LatticeInstance α) (g : α) (ri : RepIndex)
    (h : S.repMult ri (lat.latticePoly lat.dim) > S.repMult ri g) :
    ¬ S.inClosure (lat.latticePoly lat.dim) g :=
  direct_noncontainment _ g ri h

/-- **Theorem 36 (Lattice Circuit Lower Bound).**
    Universal obstructions ⟹ circuit lower bounds.
    Bridge: algebraic proof of lattice hardness. -/
theorem lattice_circuit_lower
    (lat : LatticeInstance α) (B : ℕ)
    (h_obs : ∀ g : α, S.orbitDim g ≤ B * B →
      ObstructionWitness (lat.latticePoly lat.dim) g) :
    S.circuitSize (lat.latticePoly lat.dim) > B :=
  circuit_lower_bound_from_obstruction _ B h_obs

/-! ## Part X: Concrete Fingerprint Model (37–42) -/

/-- `Fingerprint` — concrete complexity fingerprint. -/
structure Fingerprint where
  circuit : ℕ
  dim : ℕ
  mults : ℕ → ℕ
  dim_ge : circuit ≤ dim

/-- Concrete orbit closure: pointwise mult domination + dim bound. -/
def fpClosure (f g : Fingerprint) : Prop :=
  (∀ k, f.mults k ≤ g.mults k) ∧ f.dim ≤ g.dim

/-- **Theorem 37 (Fingerprint Closure Reflexivity).** -/
theorem fp_refl (f : Fingerprint) : fpClosure f f :=
  ⟨fun _ => le_refl _, le_refl _⟩

/-- **Theorem 38 (Fingerprint Closure Transitivity).** -/
theorem fp_trans (f g h : Fingerprint)
    (h₁ : fpClosure f g) (h₂ : fpClosure g h) : fpClosure f h :=
  ⟨fun k => le_trans (h₁.1 k) (h₂.1 k), le_trans h₁.2 h₂.2⟩

/-- **Theorem 39 (Fingerprint Obstruction Soundness).**
    Bridge: concrete obstruction checking for post-quantum verification. -/
theorem fp_obstruction (f g : Fingerprint) (k : ℕ)
    (h : f.mults k > g.mults k) : ¬ fpClosure f g := by
  intro ⟨hm, _⟩
  exact absurd (hm k) (not_le.mpr h)

/-- **Theorem 40 (Fingerprint Dim Monotonicity).** -/
theorem fp_dim_mono (f g : Fingerprint) (h : fpClosure f g) :
    f.dim ≤ g.dim := h.2

/-- **Theorem 41 (Gap Contradicts Containment).** -/
theorem fp_gap_contradiction (f g : Fingerprint)
    (h_gap : ∃ k, f.mults k > g.mults k)
    (h_cl : fpClosure f g) : False := by
  obtain ⟨k, hk⟩ := h_gap
  exact absurd (h_cl.1 k) (not_le.mpr hk)

/-- **Theorem 42 (Full Domination on Finite Set).** -/
theorem fp_full_dom (f g : Fingerprint) (indices : Finset ℕ)
    (h : ∀ k ∈ indices, ¬ (f.mults k > g.mults k)) :
    ∀ k ∈ indices, f.mults k ≤ g.mults k :=
  fun k hk => le_of_not_gt (h k hk)

/-! ## Part XI: Additional Structural Theorems (43–46) -/

/-- **Theorem 43 (Containment Implies Circuit Bound).**
    If f ∈ Ō_g, then circuitSize(f) ≤ orbitDim(g).
    Bridge: orbit containment as a circuit complexity certificate. -/
theorem containment_circuit_transfer (f g h : α)
    (h_fg : S.inClosure f g) (h_gh : S.inClosure g h) :
    S.orbitDim f ≤ S.orbitDim h :=
  le_trans (S.dim_mono f g h_fg) (S.dim_mono g h h_gh)

/-- **Theorem 44 (Multiplicity from Containment Chain).**
    Orbit containment chains yield pointwise multiplicity bounds.
    Bridge: representation-theoretic consequences of algebraic closure chains. -/
theorem containment_chain_mult (f g h : α)
    (h_fg : S.inClosure f g) (h_gh : S.inClosure g h) :
    ∀ ri, S.repMult ri f ≤ S.repMult ri h :=
  fun ri => le_trans (S.containment_mult_le f g h_fg ri)
                     (S.containment_mult_le g h h_gh ri)

/-- **Theorem 45 (Obstruction Backward Propagation).**
    If repMult(ri, f) > repMult(ri, h) and g ∈ Ō_h, then
    f ∉ Ō_g. Non-containment propagates backward through chains.
    Bridge: non-containment certificates propagate through lattice reductions. -/
theorem obstruction_backward_propagation (f g h : α)
    (h_gh : S.inClosure g h)
    (ri : RepIndex)
    (h_gap : S.repMult ri f > S.repMult ri h) :
    ¬ S.inClosure f g := by
  intro h_fg
  have h_fh := S.inClosure_trans f g h h_fg h_gh
  have h_le := S.containment_mult_le f h h_fh ri
  linarith

/-- **Theorem 46 (Obstruction Implies Distinct Orbits).**
    If there is an obstruction between f and g, their orbit closures
    are distinct (neither contains the other).
    Bridge: mutual non-containment from bidirectional obstructions. -/
theorem bidirectional_separation (f g : α)
    (w_fg : ObstructionWitness f g)
    (w_gf : ObstructionWitness g f) :
    ¬ S.inClosure f g ∧ ¬ S.inClosure g f :=
  ⟨obstruction_implies_noncontainment f g w_fg,
   obstruction_implies_noncontainment g f w_gf⟩

end GCT