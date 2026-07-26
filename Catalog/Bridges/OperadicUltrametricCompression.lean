import Mathlib

/-! # Operadic Ultrametric Compression: Non-Archimedean Learning Theory for Proof Dynamics

This file establishes a **structural duality** between operadic generation of proof
dynamics and ultrametric compression quotients. Proof traces become data points in an
ultrametric state space, neural operads become structured hypothesis classes, and
compression becomes a canonical quotient detected by observers.

## Main Results
* `observerDistillation_isUltraPseudoDist` — observer distillation is ultrametric pseudometric
* `observerKernel_ctx_congr` — kernel is an operadic congruence
* `certificateMap_kernel_const` — certificate factors through quotient
* `certificateMap_nonexpansive` — certificate is 1-Lipschitz
* `quotient_dist_well_defined` — quotient metric is well-defined
* `applyWord_nonexpansive` — words in nonexpansive generators are nonexpansive

## Bridges
- **Operadic deep learning ↔ Ultrametric geometry**
- **Proof compression ↔ Non-Archimedean analysis**
- **Tropical certification ↔ Behavioral equivalence**
-/

noncomputable section

open Function Finset

namespace OperadicUltrametricCompression

/-! ## §1. Ultrametric Pseudo-Distance -/

/-- Bundled ultrametric pseudo-distance. Allows `d(x,y) = 0` for `x ≠ y`. -/
structure UltraPseudoDist (P : Type*) where
  dist : P → P → ℝ
  dist_nonneg : ∀ x y, 0 ≤ dist x y
  dist_self : ∀ x, dist x x = 0
  dist_symm : ∀ x y, dist x y = dist y x
  dist_ultra : ∀ x y z, dist x z ≤ max (dist x y) (dist y z)

/-! ## §2. Nonexpansiveness -/

/-- `f` is nonexpansive w.r.t. `d` if `d(f(x), f(y)) ≤ d(x, y)`. -/
def IsNonexpansiveFn {P : Type*} (d : P → P → ℝ) (f : P → P) : Prop :=
  ∀ x y, d (f x) (f y) ≤ d x y

theorem isNonexpansiveFn_id {P : Type*} (d : P → P → ℝ) :
    IsNonexpansiveFn d id := fun _ _ => le_refl _

theorem isNonexpansiveFn_comp {P : Type*} {d : P → P → ℝ} {f g : P → P}
    (hf : IsNonexpansiveFn d f) (hg : IsNonexpansiveFn d g) :
    IsNonexpansiveFn d (f ∘ g) :=
  fun x y => le_trans (hf _ _) (hg _ _)

/-- Iterates of a nonexpansive function are nonexpansive. -/
theorem isNonexpansiveFn_iterate {P : Type*} {d : P → P → ℝ} {f : P → P}
    (hf : IsNonexpansiveFn d f) (m : ℕ) :
    IsNonexpansiveFn d (f^[m]) := by
  induction m with
  | zero => exact isNonexpansiveFn_id d
  | succ n ih =>
    intro x y
    show d (f^[n] (f x)) (f^[n] (f y)) ≤ d x y
    exact le_trans (ih _ _) (hf x y)

/-! ## §3. Words in Generators -/

/-- Apply a word (list of generator indices) right-to-left. -/
def applyWord {P : Type*} {k : ℕ} (gens : Fin k → P → P) : List (Fin k) → P → P
  | [], x => x
  | i :: w, x => gens i (applyWord gens w x)

@[simp]
theorem applyWord_nil {P : Type*} {k : ℕ} (gens : Fin k → P → P) (x : P) :
    applyWord gens [] x = x := rfl

/-- Words in nonexpansive generators are nonexpansive. -/
theorem applyWord_nonexpansive {P : Type*} {k : ℕ}
    {d : P → P → ℝ} {gens : Fin k → P → P}
    (hgens : ∀ i, IsNonexpansiveFn d (gens i))
    (w : List (Fin k)) :
    IsNonexpansiveFn d (applyWord gens w) := by
  induction w with
  | nil => exact isNonexpansiveFn_id d
  | cons i w ih => exact fun x y => le_trans (hgens i _ _) (ih x y)

/-- Concatenation of words = composition of actions. -/
theorem applyWord_append {P : Type*} {k : ℕ} (gens : Fin k → P → P)
    (w₁ w₂ : List (Fin k)) (x : P) :
    applyWord gens (w₁ ++ w₂) x = applyWord gens w₁ (applyWord gens w₂ x) := by
  induction w₁ with
  | nil => simp [applyWord]
  | cons i w₁ ih => simp [applyWord, ih]

/-! ## §4. Closed Observer Systems -/

/-- A **closed observer system**: ultrametric space + compression + finite closed context family.
    The closure condition ensures compositions of contexts remain in the family (mod compression). -/
structure ClosedObserverSystem (P : Type*) where
  d : P → P → ℝ
  d_nonneg : ∀ x y, 0 ≤ d x y
  d_self : ∀ x, d x x = 0
  d_symm : ∀ x y, d x y = d y x
  d_ultra : ∀ x y z, d x z ≤ max (d x y) (d y z)
  C : P → P
  hC_nonexp : ∀ x y, d (C x) (C y) ≤ d x y
  n : ℕ
  hn : 0 < n
  ctx : Fin n → P → P
  hctx_nonexp : ∀ i, IsNonexpansiveFn d (ctx i)
  hctx_comp_closed : ∀ i j, ∃ k, ∀ x, C (ctx j (ctx i x)) = C (ctx k x)

variable {P : Type*}

/-- Nonemptiness witness for the context family. -/
def ClosedObserverSystem.ctxNonempty (S : ClosedObserverSystem P) :
    (Finset.univ : Finset (Fin S.n)).Nonempty :=
  Finset.univ_nonempty_iff.mpr ⟨⟨0, S.hn⟩⟩

/-! ## §5. Observer Scores -/

/-- Observer score for context `i`: `d(C(ctx_i(x)), C(ctx_i(y)))`. -/
def ctxObserverScore (S : ClosedObserverSystem P) (i : Fin S.n) (x y : P) : ℝ :=
  S.d (S.C (S.ctx i x)) (S.C (S.ctx i y))

theorem ctxObserverScore_self (S : ClosedObserverSystem P) (i : Fin S.n) (x : P) :
    ctxObserverScore S i x x = 0 := S.d_self _

theorem ctxObserverScore_symm (S : ClosedObserverSystem P) (i : Fin S.n) (x y : P) :
    ctxObserverScore S i x y = ctxObserverScore S i y x := S.d_symm _ _

theorem ctxObserverScore_nonneg (S : ClosedObserverSystem P) (i : Fin S.n) (x y : P) :
    0 ≤ ctxObserverScore S i x y := S.d_nonneg _ _

theorem ctxObserverScore_ultra (S : ClosedObserverSystem P) (i : Fin S.n)
    (x y z : P) :
    ctxObserverScore S i x z ≤
      max (ctxObserverScore S i x y) (ctxObserverScore S i y z) :=
  S.d_ultra _ _ _

theorem ctxObserverScore_le_dist (S : ClosedObserverSystem P) (i : Fin S.n)
    (x y : P) : ctxObserverScore S i x y ≤ S.d x y :=
  le_trans (S.hC_nonexp _ _) (S.hctx_nonexp i x y)

/-! ## §6. Observer Distillation -/

/-- The **observer distillation**: `δ(x,y) = sup_i d(C(ctx_i(x)), C(ctx_i(y)))`. -/
def observerDistillation (S : ClosedObserverSystem P) (x y : P) : ℝ :=
  Finset.sup' Finset.univ S.ctxNonempty (fun i => ctxObserverScore S i x y)

theorem observerDistillation_nonneg (S : ClosedObserverSystem P) (x y : P) :
    0 ≤ observerDistillation S x y := by
  exact le_trans (ctxObserverScore_nonneg S ⟨0, S.hn⟩ x y)
    (le_sup' (fun i => ctxObserverScore S i x y) (Finset.mem_univ _))

theorem observerDistillation_self (S : ClosedObserverSystem P) (x : P) :
    observerDistillation S x x = 0 := by
  apply le_antisymm
  · exact sup'_le _ _ (fun i _ => le_of_eq (ctxObserverScore_self S i x))
  · exact observerDistillation_nonneg S x x

theorem observerDistillation_symm (S : ClosedObserverSystem P) (x y : P) :
    observerDistillation S x y = observerDistillation S y x := by
  simp only [observerDistillation, ctxObserverScore_symm]

/-- **Core**: supremum of ultrametric pseudometrics over a finite family is ultrametric. -/
theorem observerDistillation_ultra (S : ClosedObserverSystem P) (x y z : P) :
    observerDistillation S x z ≤
      max (observerDistillation S x y) (observerDistillation S y z) := by
  apply sup'_le
  intro i _
  calc ctxObserverScore S i x z
      ≤ max (ctxObserverScore S i x y) (ctxObserverScore S i y z) :=
        ctxObserverScore_ultra S i x y z
    _ ≤ max (observerDistillation S x y) (observerDistillation S y z) := by
        exact max_le_max
          (le_sup' (fun j => ctxObserverScore S j x y) (Finset.mem_univ i))
          (le_sup' (fun j => ctxObserverScore S j y z) (Finset.mem_univ i))

/-- **Flagship Theorem 1a**: Observer distillation is an ultrametric pseudometric. -/
def observerDistillation_isUltraPseudoDist (S : ClosedObserverSystem P) :
    UltraPseudoDist P where
  dist := observerDistillation S
  dist_nonneg := observerDistillation_nonneg S
  dist_self := observerDistillation_self S
  dist_symm := observerDistillation_symm S
  dist_ultra := observerDistillation_ultra S

theorem observerDistillation_le_dist (S : ClosedObserverSystem P) (x y : P) :
    observerDistillation S x y ≤ S.d x y :=
  sup'_le _ _ (fun i _ => ctxObserverScore_le_dist S i x y)

theorem ctxObserverScore_le_distillation (S : ClosedObserverSystem P)
    (i : Fin S.n) (x y : P) :
    ctxObserverScore S i x y ≤ observerDistillation S x y :=
  le_sup' (fun j => ctxObserverScore S j x y) (Finset.mem_univ i)

/-! ## §7. Observer Kernel -/

/-- The observer kernel: `x ~_O y ↔ δ_O(x,y) = 0`. -/
def observerKernel (S : ClosedObserverSystem P) (x y : P) : Prop :=
  observerDistillation S x y = 0

theorem observerKernel_refl (S : ClosedObserverSystem P) (x : P) :
    observerKernel S x x := observerDistillation_self S x

theorem observerKernel_symm (S : ClosedObserverSystem P) {x y : P}
    (h : observerKernel S x y) : observerKernel S y x := by
  unfold observerKernel; rw [observerDistillation_symm]; exact h

theorem observerKernel_trans (S : ClosedObserverSystem P) {x y z : P}
    (hxy : observerKernel S x y) (hyz : observerKernel S y z) :
    observerKernel S x z := by
  unfold observerKernel at *
  linarith [observerDistillation_ultra S x y z, observerDistillation_nonneg S x z,
            max_le (le_of_eq hxy) (le_of_eq hyz)]

/-- The observer kernel as a setoid. -/
def observerKernel_setoid (S : ClosedObserverSystem P) : Setoid P where
  r := observerKernel S
  iseqv := ⟨observerKernel_refl S, fun h => observerKernel_symm S h,
            fun h1 h2 => observerKernel_trans S h1 h2⟩

/-- Observer kernel iff all individual scores zero. -/
theorem observerKernel_iff_all_scores_zero (S : ClosedObserverSystem P) (x y : P) :
    observerKernel S x y ↔ ∀ i, ctxObserverScore S i x y = 0 := by
  constructor
  · intro h i
    have h' : observerDistillation S x y = 0 := h
    linarith [ctxObserverScore_le_distillation S i x y, ctxObserverScore_nonneg S i x y]
  · intro h
    unfold observerKernel observerDistillation
    apply le_antisymm
    · exact sup'_le _ _ (fun i _ => le_of_eq (h i))
    · exact le_trans (ctxObserverScore_nonneg S ⟨0, S.hn⟩ x y)
        (le_sup' (fun j => ctxObserverScore S j x y) (Finset.mem_univ _))

/-! ## §8. Context Congruence -/

/-- **Flagship Theorem 1b**: Observer kernel is an operadic congruence. -/
theorem observerKernel_ctx_congr (S : ClosedObserverSystem P) (i : Fin S.n)
    {x y : P} (h : observerKernel S x y) :
    observerKernel S (S.ctx i x) (S.ctx i y) := by
  rw [observerKernel_iff_all_scores_zero] at h ⊢
  intro j
  obtain ⟨k, hk⟩ := S.hctx_comp_closed i j
  show S.d (S.C (S.ctx j (S.ctx i x))) (S.C (S.ctx j (S.ctx i y))) = 0
  rw [hk x, hk y]
  exact h k

/-! ## §9. Quotient and Certificate -/

/-- The compression quotient type. -/
def CompressionQuotient (S : ClosedObserverSystem P) :=
  Quotient (observerKernel_setoid S)

/-- Certificate map: `cert(x) = δ(p₀, x)`. -/
def certificateMap (S : ClosedObserverSystem P) (p₀ : P) (x : P) : ℝ :=
  observerDistillation S p₀ x

/-
Certificate is constant on observer-equivalent states.
-/
theorem certificateMap_kernel_const (S : ClosedObserverSystem P) (p₀ : P)
    {x y : P} (h : observerKernel S x y) :
    certificateMap S p₀ x = certificateMap S p₀ y := by
  unfold certificateMap;
  -- By definition of observerKernel, we have that observerDistillation S x y = 0.
  have h_dist_zero : observerDistillation S x y = 0 := by
    exact h;
  have h_ultra : observerDistillation S p₀ x ≤ max (observerDistillation S p₀ y) (observerDistillation S y x) := by
    apply observerDistillation_ultra;
  have h_ultra' : observerDistillation S p₀ y ≤ max (observerDistillation S p₀ x) (observerDistillation S x y) := by
    apply observerDistillation_ultra;
  simp_all +decide [ observerKernel, observerDistillation_symm ];
  cases h_ultra <;> cases h_ultra' <;> linarith [ observerDistillation_nonneg S p₀ x, observerDistillation_nonneg S p₀ y ]

/-
Certificate is nonexpansive (1-Lipschitz).
-/
theorem certificateMap_nonexpansive (S : ClosedObserverSystem P) (p₀ x y : P) :
    |certificateMap S p₀ x - certificateMap S p₀ y| ≤ observerDistillation S x y := by
  rw [ abs_sub_le_iff ];
  constructor;
  · unfold certificateMap;
    rw [ sub_le_iff_le_add' ];
    have := observerDistillation_ultra S p₀ y x;
    exact this.trans ( max_le ( le_add_of_nonneg_right ( observerDistillation_nonneg S _ _ ) ) ( by rw [ observerDistillation_symm ] ; exact le_add_of_nonneg_left ( observerDistillation_nonneg S _ _ ) ) );
  · have h_ultra : observerDistillation S p₀ y ≤ max (observerDistillation S p₀ x) (observerDistillation S x y) := by
      apply observerDistillation_ultra;
    cases max_cases ( observerDistillation S p₀ x ) ( observerDistillation S x y ) <;> linarith! [ observerDistillation_nonneg S p₀ x, observerDistillation_nonneg S p₀ y, observerDistillation_nonneg S x y ]

/-- Certificate bounded by original distance. -/
theorem certificateMap_le_dist (S : ClosedObserverSystem P) (p₀ x : P) :
    certificateMap S p₀ x ≤ S.d p₀ x :=
  observerDistillation_le_dist S p₀ x

/-! ## §10. Observer Complexity -/

/-
If all scores < ε, then distillation < ε.
-/
theorem observer_complexity_factored (S : ClosedObserverSystem P)
    {ε : ℝ} {x y : P}
    (h : ∀ i : Fin S.n, ctxObserverScore S i x y < ε) :
    observerDistillation S x y < ε := by
  obtain ⟨ i, hi ⟩ := Finset.exists_max_image Finset.univ ( fun i => ctxObserverScore S i x y ) ⟨ ⟨ 0, S.hn ⟩, Finset.mem_univ _ ⟩;
  exact lt_of_le_of_lt ( Finset.sup'_le _ _ fun j _ => hi.2 j ‹_› ) ( h i )

/-- If distillation < ε, then every individual score < ε. -/
theorem observer_scores_lt_of_distillation_lt (S : ClosedObserverSystem P)
    {ε : ℝ} {x y : P}
    (h : observerDistillation S x y < ε) (i : Fin S.n) :
    ctxObserverScore S i x y < ε :=
  lt_of_le_of_lt (ctxObserverScore_le_distillation S i x y) h

/-! ## §11. Tropical Certificate Properties -/

/-- Tropical subadditivity: `cert(x) ≤ max(cert(y), δ(y, x))`. -/
theorem tropical_certificate_subadditive (S : ClosedObserverSystem P) (p₀ x y : P) :
    certificateMap S p₀ x ≤
      max (certificateMap S p₀ y) (observerDistillation S y x) :=
  observerDistillation_ultra S p₀ y x

/-- Non-equivalent states have positive distillation distance. -/
theorem certificate_separation (S : ClosedObserverSystem P) (x y : P)
    (hne : ¬ observerKernel S x y) :
    observerDistillation S x y > 0 :=
  lt_of_le_of_ne (observerDistillation_nonneg S x y) (Ne.symm hne)

/-! ## §12. Concrete Example -/

/-- Trivial observer system with discrete metric. -/
def trivialObserverSystem (P : Type*) [Inhabited P] [DecidableEq P] :
    ClosedObserverSystem P where
  d := fun x y => if x = y then 0 else 1
  d_nonneg := fun x y => by split_ifs <;> norm_num
  d_self := fun x => if_pos rfl
  d_symm := fun x y => by split_ifs with h1 h2 <;> simp_all [eq_comm]
  d_ultra := fun x y z => by
    by_cases hxz : x = z <;> by_cases hxy : x = y <;> by_cases hyz : y = z <;>
      simp_all
  C := id
  hC_nonexp := fun _ _ => le_refl _
  n := 1
  hn := Nat.one_pos
  ctx := fun _ => id
  hctx_nonexp := fun _ _ _ => le_refl _
  hctx_comp_closed := fun _ _ => ⟨0, fun _ => rfl⟩

/-! ## §13. Quotient Metric -/

/-
Quotient distance is well-defined.
-/
theorem quotient_dist_well_defined (S : ClosedObserverSystem P)
    {x₁ x₂ y₁ y₂ : P}
    (hx : observerKernel S x₁ x₂) (hy : observerKernel S y₁ y₂) :
    observerDistillation S x₁ y₁ = observerDistillation S x₂ y₂ := by
  refine' le_antisymm _ _;
  · have h₁ := observerDistillation_ultra S x₁ x₂ y₁
    have h₂ := observerDistillation_ultra S x₂ y₂ y₁
    have h₃ := observerDistillation_ultra S x₁ y₂ y₁
    have h₄ := observerDistillation_ultra S x₂ y₁ y₂
    have h₅ := observerDistillation_ultra S x₁ y₁ y₂
    have h₆ := observerDistillation_ultra S x₂ y₂ y₂
    simp_all +decide [ observerKernel ];
    cases h₁ <;> cases h₂ <;> cases h₃ <;> cases h₄ <;> cases h₅ <;> linarith [ observerDistillation_nonneg S x₁ y₁, observerDistillation_nonneg S x₂ y₁, observerDistillation_nonneg S x₁ y₂, observerDistillation_nonneg S x₂ y₂, observerDistillation_nonneg S y₁ y₂, observerDistillation_symm S y₁ y₂ ];
  · have := observerDistillation_ultra S x₂ x₁ y₁;
    have := observerDistillation_ultra S x₂ y₁ y₂; simp_all +decide [ observerKernel ] ;
    cases this <;> cases ‹observerDistillation S x₂ y₁ ≤ observerDistillation S x₂ x₁ ∨ observerDistillation S x₂ y₁ ≤ observerDistillation S x₁ y₁› <;> linarith [ observerDistillation_symm S x₁ x₂, observerDistillation_symm S y₁ y₂, observerDistillation_nonneg S x₂ y₁, observerDistillation_nonneg S x₁ y₁ ]

/-! ## §14. Monotonicity -/

/-
Larger context families produce finer distillation.
-/
theorem deeper_contexts_finer_distillation
    (S₁ S₂ : ClosedObserverSystem P)
    (hd : S₁.d = S₂.d) (hC : S₁.C = S₂.C)
    (hembed : ∀ i : Fin S₁.n, ∃ j : Fin S₂.n, ∀ x, S₁.ctx i x = S₂.ctx j x) :
    ∀ x y, observerDistillation S₁ x y ≤ observerDistillation S₂ x y := by
  intro x y;
  unfold observerDistillation;
  simp +decide [ ctxObserverScore, hd, hC ];
  choose f hf using hembed;
  have := Finset.exists_max_image Finset.univ ( fun i => S₂.d ( S₂.C ( S₂.ctx i x ) ) ( S₂.C ( S₂.ctx i y ) ) ) ⟨ f ⟨ 0, S₁.hn ⟩, Finset.mem_univ _ ⟩ ; aesop;

/-
Idempotent compression doesn't increase distillation, provided the identity
    context is in the family (so that `d(C x, C y)` is one of the observer scores).
-/
theorem idempotent_compression_distillation_stable
    (S : ClosedObserverSystem P) (_hC_idem : ∀ x, S.C (S.C x) = S.C x)
    (hid : ∃ i₀ : Fin S.n, ∀ x, S.ctx i₀ x = x) {x y : P} :
    observerDistillation S (S.C x) (S.C y) ≤ observerDistillation S x y := by
  obtain ⟨ i₀, hi₀ ⟩ := hid;
  simp_all +decide [ observerDistillation ];
  use i₀;
  intro i
  simp [ctxObserverScore, hi₀];
  exact S.hctx_nonexp i _ _ |> le_trans ( S.hC_nonexp _ _ )

/-! ## §15. Finite Observer Extraction -/

/-- Words up to any depth in nonexpansive generators are nonexpansive. -/
theorem finite_observer_family_suffices {P : Type*}
    {d_met : P → P → ℝ} {k : ℕ} (gens : Fin k → P → P)
    (hgens : ∀ i, IsNonexpansiveFn d_met (gens i)) :
    ∀ w : List (Fin k), IsNonexpansiveFn d_met (applyWord gens w) :=
  fun w => applyWord_nonexpansive hgens w

/-- Word concatenation = composition of generated contexts. -/
theorem generated_contexts_closed {P : Type*} {k : ℕ}
    (gens : Fin k → P → P) (w₁ w₂ : List (Fin k)) (x : P) :
    applyWord gens w₁ (applyWord gens w₂ x) = applyWord gens (w₁ ++ w₂) x :=
  (applyWord_append gens w₁ w₂ x).symm

/-! ## §16. Bridge to Contraction Theory -/

/-- Contractive maps are nonexpansive. -/
theorem contraction_is_nonexpansive
    {α : Type*} {d : α → α → ℝ} {F : α → α} {q : ℝ}
    (hq : q ≤ 1)
    (hF : ∀ x y, d (F x) (F y) ≤ q * d x y)
    (hd_nn : ∀ x y, 0 ≤ d x y) :
    IsNonexpansiveFn d F := fun x y =>
  calc d (F x) (F y) ≤ q * d x y := hF x y
    _ ≤ 1 * d x y := mul_le_mul_of_nonneg_right hq (hd_nn x y)
    _ = d x y := one_mul _

end OperadicUltrametricCompression

end