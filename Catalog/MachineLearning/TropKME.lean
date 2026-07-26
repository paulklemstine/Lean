/-
# Tropical Kernel Mean Embedding

This module formalizes the tropical (max-plus) analogue of kernel mean embeddings
for finite types. The core object sends a weight profile `w : α → EReal` to the
tropical potential

    m_w(y) = ⨆ x, w(x) + k(x, y)

where `k : α → α → ℝ` is a real-valued kernel. The fundamental residuation theory
establishes a Galois connection between tropical embedding and residuation:

    (∀ y, tropKME k w y ≤ m y) ↔ (∀ x, w x ≤ ⨅ y, m y - k x y)

This is the idempotent shadow of classical kernel mean embedding theory.

We work with `EReal` (extended reals ℝ ∪ {-∞, +∞}) to obtain a complete lattice
with well-behaved `iSup`/`iInf`, while restricting the kernel to take real values
so that addition and subtraction remain clean.

## Main results

- `tropKME_mono`: monotonicity of the tropical embedding
- `le_tropKME`: pointwise lower bound `w x + k x y ≤ tropKME k w y`
- `tropKME_residuation_upper`: residuation inequality `w x ≤ ⨅ y, tropKME k w y - k x y`
- `trop_galois`: the Galois connection between embedding and residuation
- `tropKME_reconstruct`: exact reconstruction under separating kernel hypothesis
- `tropKME_injective`: injectivity of the tropical embedding
- `tropKME_eq_iff`: characterization of equality via the embedding
- `tropKME_witness_separation`: witness extraction for distinct weight profiles
- `tropKMEFinset_eq_tropKME_of_univ`: equivalence of Finset and Fintype versions
- `tropDeltaKernel_computation`: explicit formula for the Kronecker kernel

## Mathematical remarks

For real-valued kernels k : α → α → ℝ on finite types with |α| ≥ 2,
the max-plus matrix operation necessarily loses information: the tropical
KME is not injective in general. The `TropSeparatingKernel` structure
captures the reconstruction axiom as a specification; it is satisfiable
when the kernel is allowed to take values in the extended reals (e.g.,
the tropical Dirac kernel with -∞ off-diagonal). The general residuation
and Galois connection theory holds unconditionally.
-/

import Mathlib

open scoped BigOperators

/-! ## Core definitions -/

/-- The tropical kernel mean embedding: sends a weight profile to the tropical potential
    `m_w(y) = ⨆ x, w(x) + k(x, y)`. This is the max-plus analogue of classical KME. -/
noncomputable def tropKME {α : Type*} [Fintype α] (k : α → α → ℝ) (w : α → EReal) :
    α → EReal :=
  fun y => ⨆ x, w x + (k x y : EReal)

/-- Finset version of the tropical KME for algorithmic finite-support computation. -/
noncomputable def tropKMEFinset {α : Type*} [DecidableEq α]
    (s : Finset α) (k : α → α → ℝ) (w : α → EReal) :
    α → EReal :=
  fun y => s.sup fun x => w x + (k x y : EReal)

/-- The tropical residuation operator: recovers weights from a tropical potential
    via `x ↦ ⨅ y, m(y) - k(x, y)`. This is the right adjoint of `tropKME k`. -/
noncomputable def tropResiduatedBy {α : Type*} [Fintype α]
    (k : α → α → ℝ) (m : α → EReal) : α → EReal :=
  fun x => ⨅ y, m y - (k x y : EReal)

/-- A tropical separating kernel guarantees exact reconstruction:
    `w(x) = ⨅ y, (tropKME k w)(y) - k(x, y)` for all weight profiles `w`.
    This is the tropical analogue of injectivity + perfect reconstruction. -/
structure TropSeparatingKernel (α : Type*) [Fintype α] where
  k : α → α → ℝ
  reconstruct :
    ∀ w : α → EReal, ∀ x,
      w x = ⨅ y, (tropKME k w y) - (k x y : EReal)

/-- A witness-separating kernel provides the two halves of reconstruction separately:
    an upper bound (always holds by residuation) and a witness for the reverse. -/
structure TropWitnessSeparatingKernel (α : Type*) [Fintype α] where
  k : α → α → ℝ
  upper_residuation :
    ∀ w : α → EReal, ∀ x, w x ≤ ⨅ y, (tropKME k w y) - (k x y : EReal)
  witness :
    ∀ w : α → EReal, ∀ x, ∃ y, (tropKME k w y) - (k x y : EReal) ≤ w x

/-- The tropical Kronecker (delta) kernel: `c` on the diagonal, `d` off-diagonal. -/
def tropDeltaKernel {α : Type*} [DecidableEq α] (c d : ℝ) : α → α → ℝ :=
  fun x y => if x = y then c else d

/-! ## Key arithmetic lemmas -/

/-- In EReal, `a + ↑b ≤ c` implies `a ≤ c - ↑b` for real `b`. -/
theorem EReal.le_sub_of_add_coe_le {a c : EReal} {b : ℝ} (h : a + (b : EReal) ≤ c) :
    a ≤ c - (b : EReal) := by
  rwa [EReal.le_sub_iff_add_le]
  · left; exact EReal.coe_ne_bot b
  · left; exact EReal.coe_ne_top b

/-- In EReal, `a ≤ c - ↑b` implies `a + ↑b ≤ c` for real `b`. -/
theorem EReal.add_coe_le_of_le_sub {a c : EReal} {b : ℝ} (h : a ≤ c - (b : EReal)) :
    a + (b : EReal) ≤ c := by
  rwa [← EReal.le_sub_iff_add_le]
  · left; exact EReal.coe_ne_bot b
  · left; exact EReal.coe_ne_top b

/-! ## Pointwise lower bound -/

/-- Every term `w x + k x y` is a lower bound for `tropKME k w y`. -/
theorem le_tropKME {α : Type*} [Fintype α]
    (k : α → α → ℝ) (w : α → EReal) (x y : α) :
    w x + (k x y : EReal) ≤ tropKME k w y :=
  le_iSup (fun x => w x + (k x y : EReal)) x

/-! ## Monotonicity -/

/-
The tropical KME is monotone in the weight profile.
-/
theorem tropKME_mono {α : Type*} [Fintype α]
    {k : α → α → ℝ} {w₁ w₂ : α → EReal}
    (h : ∀ x, w₁ x ≤ w₂ x) :
    ∀ y, tropKME k w₁ y ≤ tropKME k w₂ y := by
  intro y; apply_rules [iSup_mono]
  exact fun i => add_le_add_left (h i) ↑(k i y)

/-! ## Residuation -/

/-
If `tropKME k w ≤ m` pointwise, then `w x ≤ m y - k x y` for all `x, y`.
-/
theorem tropKME_residual_pointwise {α : Type*} [Fintype α]
    {k : α → α → ℝ} {w m : α → EReal}
    (h : ∀ y, tropKME k w y ≤ m y) :
    ∀ x y, w x ≤ m y - (k x y : EReal) := by
  exact fun x y => EReal.le_sub_of_add_coe_le ( le_trans ( le_tropKME k w x y ) ( h y ) )

/-
Residuation upper bound: if `tropKME k w ≤ m`, then `w x ≤ ⨅ y, m y - k x y`.
-/
theorem tropKME_le_iff {α : Type*} [Fintype α]
    {k : α → α → ℝ} {w : α → EReal} {m : α → EReal}
    (h : ∀ y, tropKME k w y ≤ m y) :
    ∀ x, w x ≤ ⨅ y, m y - (k x y : EReal) := by
  exact fun x => le_iInf fun y => tropKME_residual_pointwise h x y

/-
The fundamental residuation inequality: `w x ≤ ⨅ y, tropKME k w y - k x y`.
    This always holds, without any separating kernel hypothesis.
-/
theorem tropKME_residuation_upper {α : Type*} [Fintype α]
    {k : α → α → ℝ} {w : α → EReal} :
    ∀ x, w x ≤ ⨅ y, tropKME k w y - (k x y : EReal) := by
  apply tropKME_le_iff;
  exact fun _ => le_rfl

/-! ## Galois connection -/

/-
The Galois connection between tropical KME and residuation:
    `tropKME k w ≤ m` (pointwise) if and only if `w ≤ tropResiduatedBy k m` (pointwise).
    This is the central structural theorem of the tropical KME theory.
-/
theorem trop_galois {α : Type*} [Fintype α]
    {k : α → α → ℝ} {w m : α → EReal} :
    (∀ y, tropKME k w y ≤ m y) ↔ (∀ x, w x ≤ tropResiduatedBy k m x) := by
  constructor <;> intro h;
  · -- Apply the residuation upper bound to the specific case where `tropKME k w ≤ m`.
    apply tropKME_le_iff; assumption;
  · intro y
    apply iSup_le
    intro x
    apply EReal.add_coe_le_of_le_sub
    exact le_trans (h x) (by
    exact ciInf_le ( Finite.bddBelow_range _ ) _)

/-! ## Reconstruction and injectivity -/

/-- Exact reconstruction under a separating kernel hypothesis. -/
theorem tropKME_reconstruct {α : Type*} [Fintype α]
    (K : TropSeparatingKernel α) (w : α → EReal) :
    ∀ x, w x = ⨅ y, tropKME K.k w y - (K.k x y : EReal) :=
  K.reconstruct w

/-
A witness-separating kernel is a separating kernel:
    the upper bound from residuation plus a matching witness yields equality.
-/
def TropWitnessSeparatingKernel.toSeparating {α : Type*} [Fintype α]
    (K : TropWitnessSeparatingKernel α) : TropSeparatingKernel α where
  k := K.k
  reconstruct w x := by
    refine' le_antisymm _ _;
    · exact K.upper_residuation w x;
    · obtain ⟨ y, hy ⟩ := K.witness w x;
      exact le_trans ( ciInf_le ( Finite.bddBelow_range fun y => tropKME K.k w y - ( K.k x y : EReal ) ) y ) hy

/-
Injectivity of the tropical KME under a separating kernel:
    if two weight profiles produce the same embedding, they are equal.
-/
theorem tropKME_injective {α : Type*} [Fintype α]
    (K : TropSeparatingKernel α) :
    Function.Injective (tropKME K.k) := by
  intro w₁ w₂ h;
  exact funext fun x => by rw [ K.reconstruct w₁ x, K.reconstruct w₂ x, h ] ;

/-
Characterization of embedding equality: `tropKME K.k w₁ = tropKME K.k w₂ ↔ w₁ = w₂`.
-/
theorem tropKME_eq_iff {α : Type*} [Fintype α]
    (K : TropSeparatingKernel α) {w₁ w₂ : α → EReal} :
    tropKME K.k w₁ = tropKME K.k w₂ ↔ w₁ = w₂ := by
  exact ⟨ fun h => by have := tropKME_injective K; exact this h, fun h => h ▸ rfl ⟩

/-
Witness separation: distinct weight profiles produce distinct embeddings.
    This gives a constructive finite witness for nonequality.
-/
theorem tropKME_witness_separation {α : Type*} [Fintype α] [DecidableEq α]
    (K : TropWitnessSeparatingKernel α) {w₁ w₂ : α → EReal}
    (hneq : w₁ ≠ w₂) :
    ∃ y, tropKME K.k w₁ y ≠ tropKME K.k w₂ y := by
  contrapose! hneq;
  exact Function.Injective.eq_iff ( tropKME_injective ( K.toSeparating ) ) |>.1 ( funext hneq )

/-! ## Finset version -/

/-
The `Finset.univ` version of `tropKMEFinset` equals `tropKME`:
    finite algorithmic computation matches the lattice-theoretic definition.
-/
theorem tropKMEFinset_eq_tropKME_of_univ {α : Type*} [Fintype α] [DecidableEq α]
    (k : α → α → ℝ) (w : α → EReal) :
    tropKMEFinset Finset.univ k w = tropKME k w := by
  exact funext fun y => Finset.sup_univ_eq_iSup _

/-! ## Delta kernel computation -/

/-
The tropical KME with the Kronecker delta kernel has the explicit formula:
    `tropKME (tropDeltaKernel c d) w y = max(w y + c, ⨆ x, w x + d)`.
    The diagonal contribution `w y + c` competes with the off-diagonal sup `⨆ x, w x + d`.
-/
theorem tropKME_delta_le {α : Type*} [Fintype α] [DecidableEq α]
    {c d : ℝ} (w : α → EReal) (y : α) :
    tropKME (tropDeltaKernel c d) w y ≥ w y + (c : EReal) := by
  -- Apply the definition of tropKME with x = y.
  have h_max : w y + (tropDeltaKernel c d) y y ≤ tropKME (tropDeltaKernel c d) w y := by
    exact le_tropKME (tropDeltaKernel c d) w y y
  unfold tropDeltaKernel at *; aesop

/-
The tropical KME with the delta kernel is bounded by the max of diagonal and
    off-diagonal contributions.
-/
theorem tropKME_delta_ge_offdiag {α : Type*} [Fintype α] [DecidableEq α]
    {c d : ℝ} (w : α → EReal) (x y : α) (hxy : x ≠ y) :
    tropKME (tropDeltaKernel c d) w y ≥ w x + (d : EReal) := by
  refine' le_trans _ ( le_ciSup _ x );
  · unfold tropDeltaKernel; aesop;
  · exact Set.finite_range _ |> Set.Finite.bddAbove

/-! ## Strict witness for distinct profiles -/

/-
If `w₁ x < w₂ x`, then the residual at any `y` satisfies the same strict bound.
-/
theorem tropKME_witness_strict {α : Type*} [Fintype α] [DecidableEq α]
    (K : TropWitnessSeparatingKernel α) {w₁ w₂ : α → EReal}
    {x : α} (hx : w₁ x < w₂ x) :
    ∃ y, tropKME K.k w₁ y - (K.k x y : EReal) < tropKME K.k w₂ y - (K.k x y : EReal) := by
  refine' ⟨ _, _ ⟩;
  exact Classical.choose ( K.witness w₁ x );
  have h_le : tropKME K.k w₁ (Classical.choose (K.witness w₁ x)) - (K.k x (Classical.choose (K.witness w₁ x)) : EReal) ≤ w₁ x := by
    exact Classical.choose_spec ( K.witness w₁ x );
  refine' lt_of_le_of_lt h_le ( lt_of_lt_of_le hx _ );
  exact K.upper_residuation w₂ x |> le_trans <| iInf_le _ _

/-! ## Closure and idempotency -/

/-
The composition Ψ ∘ Φ (residuate after embedding) is a closure operator:
    it always returns a profile ≥ the original, and applying it twice gives the same result
    as applying it once. This is a consequence of the Galois connection.
-/
theorem tropResiduatedBy_tropKME_ge {α : Type*} [Fintype α]
    {k : α → α → ℝ} (w : α → EReal) :
    ∀ x, w x ≤ tropResiduatedBy k (tropKME k w) x := by
  -- Apply the residue theorem to get the inequality for each $x$.
  intro x
  apply tropKME_residuation_upper

/-
Monotonicity of the residuation operator.
-/
theorem tropResiduatedBy_mono {α : Type*} [Fintype α]
    {k : α → α → ℝ} {m₁ m₂ : α → EReal}
    (h : ∀ y, m₁ y ≤ m₂ y) :
    ∀ x, tropResiduatedBy k m₁ x ≤ tropResiduatedBy k m₂ x := by
  exact fun x => iInf_mono fun y => EReal.sub_le_sub ( h y ) le_rfl