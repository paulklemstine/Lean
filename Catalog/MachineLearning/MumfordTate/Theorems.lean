/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Speculative.MumfordTate.Defs

/-!
# Tensor Invariants and Mumford–Tate Groups: Main Theorems

This file proves the core structural results:

1. **Evaluation tensor** (identity) is always a Hodge class
2. **Anti-monotonicity**: more Hodge invariants ⟹ smaller stabilizer
3. **Generic case**: scalar-only Hodge data ⟹ stabilizer = GL(W)
4. **CM dichotomy**: non-scalar Hodge endomorphism ⟹ stabilizer ⊊ GL(W)

The CM dichotomy is the key result: it formalizes the principle that complex
multiplication creates extra tensor invariants that constrain the Mumford–Tate group.
-/

noncomputable section

namespace MumfordTate

variable {W : Type*} [AddCommGroup W] [Module ℚ W]

/-! ### Theorem 1: The evaluation tensor is always a Hodge class -/

/-- The identity endomorphism (= evaluation tensor in W ⊗ W∨) is always Hodge. -/
theorem evalTensor_mem_hodgeEndos (H : WeightOneHodgeData W) :
    (1 : Module.End ℚ W) ∈ H.hodgeEndos :=
  H.hodgeEndos.one_mem

/-- All scalar endomorphisms are Hodge-compatible. -/
theorem scalar_mem_hodgeEndos (H : WeightOneHodgeData W) (a : ℚ) :
    algebraMap ℚ (Module.End ℚ W) a ∈ H.hodgeEndos :=
  H.hodgeEndos.algebraMap_mem a

/-- Scalar endomorphisms are pointwise fixed by conjugation. -/
theorem conjugateEndo_preserves_scalars (g : W ≃ₗ[ℚ] W) (a : ℚ) :
    conjugateEndo g (algebraMap ℚ (Module.End ℚ W) a) =
    algebraMap ℚ (Module.End ℚ W) a :=
  conjugateEndo_algebraMap g a

/-! ### Theorem 2: Anti-monotonicity of stabilizers -/

/-- **Anti-monotonicity**: if H₁ ≤ H₂ (more Hodge endomorphisms), then the
pointwise stabilizer of H₂ is contained in that of H₁.
Adding Hodge invariants can only shrink the centralizer. -/
theorem tensorInvariantStabilizer_antitone (H₁ H₂ : WeightOneHodgeData W)
    (h : H₁ ≤ H₂) : tensorInvariantStabilizer H₂ ≤ tensorInvariantStabilizer H₁ := by
  intro g hg φ hφ
  exact hg φ (h hφ)

/-- The scalar Hodge data is the bottom element. -/
theorem scalarHodge_le (H : WeightOneHodgeData W) :
    (ScalarHodge : WeightOneHodgeData W) ≤ H := by
  intro φ hφ
  change φ ∈ (⊥ : Subalgebra ℚ (Module.End ℚ W)) at hφ
  rw [Algebra.mem_bot] at hφ
  obtain ⟨a, rfl⟩ := hφ
  exact H.hodgeEndos.algebraMap_mem a

/-! ### Theorem 3: Generic case — stabilizer is maximal -/

/-- **Generic case**: when only scalars are Hodge-compatible, every automorphism
pointwise fixes them, so the stabilizer is all of GL(W). -/
theorem tensorInvariantStabilizer_top_of_scalar :
    tensorInvariantStabilizer (ScalarHodge : WeightOneHodgeData W) = ⊤ := by
  ext g
  simp only [Subgroup.mem_top, iff_true, mem_tensorInvariantStabilizer]
  intro φ hφ
  change φ ∈ (⊥ : Subalgebra ℚ (Module.End ℚ W)) at hφ
  rw [Algebra.mem_bot] at hφ
  obtain ⟨a, rfl⟩ := hφ
  exact conjugateEndo_algebraMap g a

/-- Scalar Hodge data has no CM witness. -/
theorem scalarHodge_no_CM : IsEmpty (HasCMWitness (ScalarHodge : WeightOneHodgeData W)) :=
  ⟨fun ⟨_, hφ, hns⟩ => hns hφ⟩

/-! ### Theorem 4: CM dichotomy -/

/-
**Key lemma**: If φ ∈ End(W) is not a scalar, it is not in the center of End(W).
This uses the fact that End(W) is a central simple algebra over ℚ.
-/
lemma not_mem_center_of_nonScalar
    [FiniteDimensional ℚ W] (φ : Module.End ℚ W)
    (hφ : φ ∉ (⊥ : Subalgebra ℚ (Module.End ℚ W))) :
    φ ∉ Subalgebra.center ℚ (Module.End ℚ W) := by
  convert hφ using 1;
  simp +decide [ Subalgebra.mem_center_iff ]

/-
**Lifting lemma**: for any endomorphism ψ not commuting with φ, there exists
an invertible endomorphism (i.e., a linear equivalence) not commuting with φ.
This uses the fact that invertible elements are Zariski dense in End(W).
-/
set_option maxHeartbeats 800000 in
lemma exists_linearEquiv_noncommuting
    [FiniteDimensional ℚ W] (φ : Module.End ℚ W)
    (hφ : φ ∉ (⊥ : Subalgebra ℚ (Module.End ℚ W)))
    (hdim : 1 < Module.finrank ℚ W) :
    ∃ g : W ≃ₗ[ℚ] W, conjugateEndo g φ ≠ φ := by
  -- By `not_mem_center_of_nonScalar`, φ is not in the center of End(W), so ∃ ψ : End(W) with φ * ψ ≠ ψ * φ (otherwise φ would be central).
  obtain ⟨ψ, hψ⟩ : ∃ ψ : Module.End ℚ W, φ * ψ ≠ ψ * φ := by
    have := not_mem_center_of_nonScalar φ hφ;
    contrapose! this;
    grind +suggestions;
  -- Consider the map $c \mapsto 1 + c \cdot \psi$ from $\mathbb{Q}$ to $\operatorname{End}(W)$.
  set f : ℚ → Module.End ℚ W := fun c => 1 + c • ψ;
  -- The determinant $\det(1 + c \cdot \psi)$ is a polynomial in $c$ over $\mathbb{Q}$ with $\det(0) = 1 \neq 0$.
  have h_det_poly : ∃ p : Polynomial ℚ, p ≠ 0 ∧ ∀ c : ℚ, LinearMap.det (f c) = p.eval c := by
    -- The determinant of a linear map is a polynomial function of its entries.
    have h_det_poly : ∃ p : Polynomial ℚ, ∀ c : ℚ, LinearMap.det (f c) = p.eval c := by
      have h_det_poly : ∀ (A : Matrix (Module.Free.ChooseBasisIndex ℚ W) (Module.Free.ChooseBasisIndex ℚ W) ℚ), ∃ p : Polynomial ℚ, ∀ c : ℚ, Matrix.det (1 + c • A) = p.eval c := by
        intro A;
        use Matrix.det (Matrix.of (fun i j => Polynomial.C (if i = j then 1 else 0) + Polynomial.X * Polynomial.C (A i j)));
        simp +decide [ Matrix.det_apply', Polynomial.eval_finset_sum ];
        simp +decide [ Polynomial.eval_prod, Matrix.one_apply ];
        exact fun c => Finset.sum_congr rfl fun _ _ => by congr; ext; split_ifs <;> simp +decide [ *, mul_comm ] ;
      obtain ⟨ p, hp ⟩ := h_det_poly ( LinearMap.toMatrix ( Module.Free.chooseBasis ℚ W ) ( Module.Free.chooseBasis ℚ W ) ψ );
      use p;
      intro c; specialize hp c; simp_all +decide [ LinearMap.det_toMatrix ] ;
      convert hp using 1;
      rw [ ← LinearMap.det_toMatrix ( Module.Free.chooseBasis ℚ W ) ];
      congr ; ext i j ; simp +decide [ f ];
    obtain ⟨ p, hp ⟩ := h_det_poly;
    refine' ⟨ p, _, hp ⟩;
    intro h; specialize hp 0; simp_all +decide ;
    simp +zetaDelta at *;
  -- Since $p$ is a non-zero polynomial, there exists a non-zero $c \in \mathbb{Q}$ such that $p(c) \neq 0$.
  obtain ⟨c, hc⟩ : ∃ c : ℚ, c ≠ 0 ∧ LinearMap.det (f c) ≠ 0 ∧ f c * φ ≠ φ * f c := by
    have h_poly_nonzero : ∃ p : Polynomial ℚ, p ≠ 0 ∧ ∀ c : ℚ, f c * φ - φ * f c = p.eval c • (ψ * φ - φ * ψ) := by
      refine' ⟨ Polynomial.X, Polynomial.X_ne_zero, fun c => _ ⟩ ; simp +decide [ f, mul_add, add_mul, mul_assoc, sub_eq_add_neg ];
      abel1;
    obtain ⟨ p, hp_ne_zero, hp_eval ⟩ := h_poly_nonzero
    obtain ⟨ q, hq_ne_zero, hq_eval ⟩ := h_det_poly
    have h_poly_nonzero : ∃ c : ℚ, c ≠ 0 ∧ p.eval c ≠ 0 ∧ q.eval c ≠ 0 := by
      have h_poly_nonzero : Set.Finite {c : ℚ | p.eval c = 0 ∨ q.eval c = 0} := by
        exact Set.Finite.subset ( p.roots.toFinset.finite_toSet.union q.roots.toFinset.finite_toSet ) fun x hx => by aesop;
      exact Exists.imp ( by aesop ) ( Set.Infinite.nonempty ( h_poly_nonzero.infinite_compl.diff ( Set.finite_singleton 0 ) ) );
    obtain ⟨ c, hc₁, hc₂, hc₃ ⟩ := h_poly_nonzero; use c; simp_all +decide [ sub_eq_iff_eq_add ] ;
    exact fun h => hψ <| h.symm ▸ rfl;
  -- Let $g = f(c)$.
  use LinearEquiv.ofBijective (f c) (by
  have h_inv : Function.Injective ⇑(f c) := by
    exact LinearEquiv.injective ( LinearMap.equivOfDetNeZero _ hc.2.1 )
  generalize_proofs at *;
  exact ⟨ h_inv, LinearMap.surjective_of_injective h_inv ⟩)
  generalize_proofs at *;
  simp_all +decide [ conjugateEndo_eq_iff ];
  exact hc.2.2

/-- **The CM dichotomy theorem.** If a weight-1 Hodge structure admits a CM witness
(a non-scalar Hodge-compatible endomorphism), then the tensor-invariant stabilizer
is a proper subgroup of GL(W).

This is the arithmetic bifurcation: the extra endomorphism creates a tensor invariant
that constrains the Mumford–Tate group, separating generic from CM elliptic curves.

The proof uses two steps:
1. A non-scalar endomorphism is not central in End(W) (by central simplicity)
2. Non-centrality lifts to the existence of a non-commuting invertible element
-/
theorem tensorInvariantStabilizer_proper_of_CM
    [FiniteDimensional ℚ W]
    (H : WeightOneHodgeData W)
    (hdim : 1 < Module.finrank ℚ W)
    (hCM : HasCMWitness H) :
    tensorInvariantStabilizer H < ⊤ := by
  rw [lt_top_iff_ne_top]
  intro heq
  obtain ⟨φ, hφmem, hφns⟩ := hCM
  -- Every g ∈ GL(W) fixes φ under conjugation
  have hfix : ∀ g : W ≃ₗ[ℚ] W, conjugateEndo g φ = φ := by
    intro g
    have : g ∈ tensorInvariantStabilizer H := heq ▸ Subgroup.mem_top g
    exact this φ hφmem
  -- But φ is non-scalar, so there exists g not fixing φ
  obtain ⟨g, hg⟩ := exists_linearEquiv_noncommuting φ hφns hdim
  exact hg (hfix g)

/-! ### The commutant subalgebra -/

/-- The commutant of φ in End(W). -/
def endoCommutant (φ : Module.End ℚ W) : Subalgebra ℚ (Module.End ℚ W) where
  carrier := { ψ | φ * ψ = ψ * φ }
  mul_mem' := by
    intro a b (ha : φ * a = a * φ) (hb : φ * b = b * φ)
    show φ * (a * b) = (a * b) * φ
    calc φ * (a * b) = (φ * a) * b := (mul_assoc _ _ _).symm
      _ = (a * φ) * b := by rw [ha]
      _ = a * (φ * b) := mul_assoc _ _ _
      _ = a * (b * φ) := by rw [hb]
      _ = (a * b) * φ := (mul_assoc _ _ _).symm
  one_mem' := by show φ * 1 = 1 * φ; simp
  add_mem' := by
    intro a b (ha : φ * a = a * φ) (hb : φ * b = b * φ)
    show φ * (a + b) = (a + b) * φ
    simp [mul_add, add_mul, ha, hb]
  zero_mem' := by show φ * 0 = 0 * φ; simp
  algebraMap_mem' := by
    intro r; show φ * algebraMap ℚ _ r = algebraMap ℚ _ r * φ
    simp [Algebra.algebraMap_eq_smul_one]

/-- The pointwise stabilizer of {φ} is exactly GL(W) ∩ centralizer(φ). -/
lemma mem_stabilizer_singleton_iff (φ : Module.End ℚ W) (g : W ≃ₗ[ℚ] W) :
    conjugateEndo g φ = φ ↔ g.toLinearMap ∘ₗ φ = φ ∘ₗ g.toLinearMap :=
  conjugateEndo_eq_iff g φ

/-- Stabilizer detects commutativity with the CM endomorphism:
if g is in the stabilizer, then g (as a linear map) commutes with every Hodge
endomorphism. -/
theorem stabilizer_implies_commutation (H : WeightOneHodgeData W)
    (g : W ≃ₗ[ℚ] W) (hg : g ∈ tensorInvariantStabilizer H) (φ : Module.End ℚ W)
    (hφ : φ ∈ H.hodgeEndos) : g.toLinearMap ∘ₗ φ = φ ∘ₗ g.toLinearMap :=
  (conjugateEndo_eq_iff g φ).mp (hg φ hφ)

end MumfordTate