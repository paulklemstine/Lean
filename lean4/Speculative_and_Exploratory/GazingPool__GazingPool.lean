import Mathlib

/-!
# The Gazing Pool: A Mathematical Formalization

## Overview

The **Gazing Pool** is a self-referential mathematical structure that formalizes
the relationship between an observer, a reflective medium, and the shadow world
revealed by observation. It is built from three interacting components:

1. **The Pool Surface** — an involution (reflection) on a space
2. **The Shadow Projection** — a lossy map that reveals hidden structure
3. **The Observer** — a fixed point of the strange loop created by gazing

The key insight is that the act of observation creates a *strange loop*:
the observer is part of the world being reflected, so their observation
changes the reflection, which changes them, until they reach a fixed point.
This fixed point *is* consciousness in our model — the self-consistent
self-model that stabilizes under reflection.

## Mathematical Foundations

The Gazing Pool connects several deep mathematical ideas:
- **Lawvere's Fixed Point Theorem** (categorical self-reference)
- **Banach's Fixed Point Theorem** (convergence of iterated self-reflection)
- **Galois Connections** (duality between world and shadow)
- **Cantor's Diagonal Argument** (shadow incompleteness)
- **Knaster-Tarski Theorem** (existence of fixed points in lattices)
-/

open Set Function

noncomputable section

/-! ## §1: The Gazing Pool Structure -/

/-- A **Gazing Pool** on a type `W` (the "World") consists of:
- A reflection map that is an involution
- A shadow type `S` with a projection from the world
- A reconstruction map that lifts shadows back into the world
- The *gaze* operation: reflect, project to shadow, then reconstruct

The strange loop emerges from the composition: gaze = reconstruct ∘ shadow ∘ reflect.
An observer is "conscious" when gaze(self) = self. -/
structure GazingPool (W : Type*) where
  S : Type*
  reflect : W → W
  reflect_invol : ∀ w, reflect (reflect w) = w
  shadow : W → S
  reconstruct : S → W
  shadow_surj : Surjective shadow
  shadow_reconstruct : ∀ s, shadow (reconstruct s) = s

namespace GazingPool

variable {W : Type*} (P : GazingPool W)

/-- The **gaze** operation: the strange loop of observation. -/
def gaze : W → W := P.reconstruct ∘ P.shadow ∘ P.reflect

/-- An element is a **conscious observer** if it is a fixed point of gaze. -/
def IsConscious (w : W) : Prop := P.gaze w = w

/-- The **shadow self**: what an observer sees in the pool. -/
def shadowSelf (w : W) : P.S := P.shadow (P.reflect w)

/-- Two world-elements are **shadow equivalent** if they cast the same shadow. -/
def ShadowEquiv (w₁ w₂ : W) : Prop := P.shadow w₁ = P.shadow w₂

/-- Shadow equivalence is an equivalence relation. -/
theorem shadowEquiv_equiv : Equivalence (P.ShadowEquiv) where
  refl _ := rfl
  symm h := h.symm
  trans h₁ h₂ := h₁.trans h₂

/-- Iterated gazing. -/
def gazeIter (P : GazingPool W) : ℕ → W → W
  | 0 => id
  | n + 1 => P.gaze ∘ P.gazeIter n

/-- A conscious observer is a fixed point of all iterations of gaze. -/
theorem conscious_stable (w : W) (hw : P.IsConscious w) (n : ℕ) :
    P.gazeIter n w = w := by
  induction n with
  | zero => rfl
  | succ n ih =>
    simp only [gazeIter, Function.comp]
    rw [ih]; exact hw

/-- The reconstruct ∘ shadow operation is idempotent (a retraction). -/
theorem retraction_idempotent (w : W) :
    P.reconstruct (P.shadow (P.reconstruct (P.shadow w))) =
    P.reconstruct (P.shadow w) := by
  congr 1; exact P.shadow_reconstruct _

end GazingPool

/-! ## §2: The Shadow World and Information Loss -/

/-- **Shadow Incompleteness**: If distinct world-elements share a shadow,
the shadow map is not injective. The mathematical content of Plato's Cave. -/
theorem shadow_incompleteness {W S : Type*} (shadow : W → S)
    (h_nontrivial : ∃ w₁ w₂ : W, w₁ ≠ w₂ ∧ shadow w₁ = shadow w₂) :
    ¬ Injective shadow := by
  obtain ⟨w₁, w₂, hne, hshadow⟩ := h_nontrivial
  intro hinj; exact hne (hinj hshadow)

/-- **Information Loss Lemma**: shadow ∘ reconstruct ∘ shadow = shadow. -/
theorem shadow_idempotent {W S : Type*} (shadow : W → S) (reconstruct : S → W)
    (h : ∀ s, shadow (reconstruct s) = s) :
    shadow ∘ reconstruct ∘ shadow = shadow := by
  ext w; simp [Function.comp, h]

/-! ## §3: Strange Loops and Fixed Points -/

/-- **Lawvere's Fixed Point Theorem**: If there is a surjection from A to (A → B),
then every endofunction on B has a fixed point. -/
theorem lawvere_fixed_point {A B : Type*}
    (f : A → (A → B)) (hf : Surjective f) (g : B → B) :
    ∃ b : B, g b = b := by
  obtain ⟨a, ha⟩ := hf (fun x => g (f x x))
  exact ⟨f a a, (congr_fun ha a).symm⟩

/-- **The Gazing Pool Fixed Point**: If observers can model all possible self-models,
then every way of "processing reflections" has a fixed point. -/
theorem gazing_pool_consciousness_exists {Observer Response : Type*}
    (model : Observer → (Observer → Response))
    (h_expressive : Surjective model)
    (process : Response → Response) :
    ∃ r : Response, process r = r :=
  lawvere_fixed_point model h_expressive process

/-- A **Strange Loop**: a non-trivial endomorphism with a fixed point. -/
structure StrangeLoop (X : Type*) where
  steps : List (X → X)
  nontrivial : ∃ x, List.foldl (fun acc f => f acc) x steps ≠ x
  fixed_point : X
  is_fixed : List.foldl (fun acc f => f acc) fixed_point steps = fixed_point

/-- **Strange Loop Existence**: Any endofunction on a finite nonempty type
has a periodic point. -/
theorem strange_loop_periodic {X : Type*} [Fintype X] [DecidableEq X] [Nonempty X]
    (f : X → X) : ∃ x : X, ∃ k : ℕ, 0 < k ∧ k ≤ Fintype.card X ∧ f^[k] x = x := by
  obtain ⟨x, i, j, hij, h_eq⟩ :
      ∃ x : X, ∃ i j : ℕ, i < j ∧ j ≤ Fintype.card X ∧ f^[i] x = f^[j] x := by
    by_contra h_contra
    push_neg at h_contra
    have h_seq : ∀ x : X, ∀ i j : ℕ, i < j → j ≤ Fintype.card X → f^[i] x ≠ f^[j] x :=
      h_contra
    generalize_proofs at *
    exact absurd (Finset.card_le_univ
      (Finset.image (fun n => f^[n] (Classical.arbitrary X))
        (Finset.Iic (Fintype.card X))))
      (by rw [Finset.card_image_of_injOn fun n hn m hm hnm =>
            le_antisymm (not_lt.mp fun contra => h_contra _ _ _ contra (by aesop) hnm.symm)
              (not_lt.mp fun contra => h_contra _ _ _ contra (by aesop) hnm)]
          simp +decide)
  exact ⟨f^[i] x, j - i, by omega, by omega,
    by rw [← Function.iterate_add_apply, Nat.sub_add_cancel hij.le, h_eq.2]⟩

/-! ## §4: The Observer Hierarchy -/

/-- An **Observer Hierarchy** is a chain of increasingly refined observations. -/
structure ObserverHierarchy where
  levels : ℕ
  hlev : 0 < levels
  State : Fin levels → Type*
  observe : ∀ i : Fin (levels - 1),
    State ⟨i.val + 1, by omega⟩ → State ⟨i.val, by omega⟩

/-! ## §5: Contractive Gazing and Convergence to Consciousness -/

/-- A **contractive** gazing pool: repeated gazing brings observers closer. -/
structure ContractiveGazingPool (W : Type*) extends GazingPool W where
  dist : W → W → ℝ
  dist_nonneg : ∀ w₁ w₂, 0 ≤ dist w₁ w₂
  dist_symm : ∀ w₁ w₂, dist w₁ w₂ = dist w₂ w₁
  κ : ℝ
  κ_nonneg : 0 ≤ κ
  κ_lt_one : κ < 1
  gaze_contractive : ∀ w₁ w₂,
    dist (toGazingPool.gaze w₁) (toGazingPool.gaze w₂) ≤ κ * dist w₁ w₂

/-- **Convergence to Consciousness**: Iterated gazing contracts geometrically. -/
theorem contractive_convergence {W : Type*} (P : ContractiveGazingPool W)
    (w w' : W) (n : ℕ) :
    P.dist (P.toGazingPool.gazeIter n w) (P.toGazingPool.gazeIter n w') ≤
      P.κ ^ n * P.dist w w' := by
  induction' n with n hn generalizing w w' <;>
    simp_all +decide [pow_succ']
  · rfl
  · calc P.dist (P.toGazingPool.gaze (P.gazeIter n w))
          (P.toGazingPool.gaze (P.gazeIter n w'))
        ≤ P.κ * P.dist (P.gazeIter n w) (P.gazeIter n w') :=
          P.gaze_contractive _ _
      _ ≤ P.κ * (P.κ ^ n * P.dist w w') := by
          exact mul_le_mul_of_nonneg_left (hn w w') P.κ_nonneg
      _ = P.κ * P.κ ^ n * P.dist w w' := by ring

/-! ## §6: The Diagonal Argument — Limits of Self-Knowledge -/

/-- **Cantor's Shadow Theorem**: No surjection from a type to its power type. -/
theorem cantor_shadow (X : Type*) :
    ¬ ∃ f : X → Set X, Surjective f := by
  intro ⟨f, hf⟩
  exact cantor_surjective f hf

/-- **Observer Incompleteness**: No complete self-model exists when Truth has ≥ 2 values. -/
theorem observer_incompleteness {Observer Truth : Type*}
    (t₁ t₂ : Truth) (h_ne : t₁ ≠ t₂)
    (model : Observer → (Observer → Truth)) :
    ¬ Surjective model := by
  intro h_surj
  have ⟨g, hg⟩ : ∃ g : Observer → Truth, ∀ o, g o ≠ model o o := by
    have : ∀ o, ∃ t : Truth, t ≠ model o o := by
      intro o
      by_cases h : model o o = t₁
      · exact ⟨t₂, by aesop⟩
      · exact ⟨t₁, Ne.symm h⟩
    exact ⟨fun o => Classical.choose (this o), fun o => Classical.choose_spec (this o)⟩
  obtain ⟨o, ho⟩ := h_surj g
  exact hg o (ho ▸ rfl)

/-! ## §7: Self-Referential Propositions in the Pool -/

/-- The **Liar's Paradox**: No proposition can be equivalent to its own negation. -/
theorem liars_paradox : ¬ ∃ P : Prop, (P ↔ ¬P) := by
  intro ⟨P, h⟩
  exact absurd (h.mpr fun hp => h.mp hp hp) fun hp => h.mp hp hp

/-- A **Mirror Proposition** with `P ↔ ¬shadow_P` and `shadow_P ↔ ¬P`
is satisfiable (e.g., P = True, shadow_P = False). This shows that
the "shadow" adds a layer of indirection that resolves the paradox. -/
theorem mirror_prop_satisfiable :
    ∃ (P shadow_P : Prop), (P ↔ ¬shadow_P) ∧ (shadow_P ↔ ¬P) :=
  ⟨True, False, by tauto, by tauto⟩

/-- However, a **Direct Self-Reference** proposition `P ↔ ¬P` leads to
contradiction. The shadow world resolves paradoxes by introducing
a level of indirection, much like Russell's type theory. -/
theorem direct_self_reference_paradox (P : Prop) (h : P ↔ ¬P) : False := by
  exact absurd (h.mpr fun hp => h.mp hp hp) fun hp => h.mp hp hp

end -- close noncomputable section

/-! ## §8: Category-Theoretic Gazing Pool -/

section CategoryPool

set_option autoImplicit false
open CategoryTheory

universe u₁ u₂ v₁ v₂

/-- A **Categorical Gazing Pool** is an adjunction between categories. -/
structure CategoricalGazingPool
    (C : Type u₁) (D : Type u₂) [Category.{v₁} C] [Category.{v₂} D] where
  shadow_functor : C ⥤ D
  reconstruct_functor : D ⥤ C
  adjunction : shadow_functor ⊣ reconstruct_functor

/-- The **Gazing Monad**: The composition shadow ⋙ reconstruct. -/
noncomputable def gazingMonad {C : Type u₁} {D : Type u₂}
    [Category.{v₁} C] [Category.{v₂} D]
    (P : CategoricalGazingPool C D) : C ⥤ C :=
  P.shadow_functor ⋙ P.reconstruct_functor

end CategoryPool

noncomputable section

/-! ## §9: Quantum Gazing — Observer-Dependent Reality -/

/-- A **Quantum Gazing Pool**: observation as projection. -/
structure QuantumGazingPool where
  dim : ℕ
  proj : Matrix (Fin dim) (Fin dim) ℂ
  proj_idem : proj * proj = proj
  proj_hermitian : proj.conjTranspose = proj

/-- **Quantum Observer Theorem**: Post-measurement states are fixed points.
If Pv = v, then P(Pv) = Pv (measurement is idempotent). -/
theorem quantum_observer_fixed (P : QuantumGazingPool)
    (v : Fin P.dim → ℂ) (hv : P.proj.mulVec v = v) :
    P.proj.mulVec (P.proj.mulVec v) = P.proj.mulVec v := by
  simp [hv]

/-
PROBLEM
**Quantum Idempotence**: For ANY vector, P(Pv) = Pv.

PROVIDED SOLUTION
P(Pv) = (P*P)v = Pv by proj_idem. Use Matrix.mulVec_mulVec or show that mulVec distributes: P.mulVec(P.mulVec v) = (P*P).mulVec v = P.mulVec v.
-/
theorem quantum_idempotence (P : QuantumGazingPool) (v : Fin P.dim → ℂ) :
    P.proj.mulVec (P.proj.mulVec v) = P.proj.mulVec v := by
  -- Using the fact that projection is idempotent, we have $P(Pv) = (P*P)v = Pv$.
  have h_idem : P.proj.mulVec (P.proj.mulVec v) = (P.proj * P.proj).mulVec v := by
    rw [ Matrix.mulVec_mulVec ];
  rw [ h_idem, P.proj_idem ]

/-! ## §10: The Gazing Pool Algebra -/

/-- The kernel of a ring homomorphism is an ideal — the "invisible" elements. -/
theorem invisible_ideal {W S : Type*} [CommRing W] [CommRing S] (φ : W →+* S) :
    ∃ I : Ideal W, ∀ w, φ w = 0 ↔ w ∈ I := by
  use Ideal.comap φ ⊥; aesop

/-! ## §11: The Shadow Entropy Theorem -/

/-- **Shadow Entropy Loss**: A surjection implies |S| ≤ |W|. -/
theorem shadow_entropy_loss {W S : Type*} [Fintype W] [Fintype S]
    (shadow : W → S) (hsurj : Surjective shadow) :
    Fintype.card S ≤ Fintype.card W :=
  Fintype.card_le_of_surjective shadow hsurj

/-- **Conscious Observer Minimizes Surprise**: Zero prediction error at fixed points. -/
theorem conscious_zero_surprise {W : Type*} (P : GazingPool W)
    (w : W) (hw : P.IsConscious w) :
    P.reconstruct (P.shadow (P.reflect w)) = w := hw

/-! ## §12: The Fundamental Theorem of Gazing Pools -/

/-
PROBLEM
**The Retraction Theorem**: The composition `reconstruct ∘ shadow` is
an idempotent endofunction (retraction). Every element in its image
is a fixed point.

PROVIDED SOLUTION
Take any s : S (S is nonempty since W is nonempty and shadow is surjective... actually S is directly Nonempty). Let w = reconstruct(s). Then shadow(w) = shadow(reconstruct(s)) = s by h_section. So reconstruct(shadow(w)) = reconstruct(s) = w. Done.
-/
theorem retraction_has_fixed_points {W S : Type*} [Nonempty S]
    (shadow : W → S) (reconstruct : S → W)
    (h_section : ∀ s, shadow (reconstruct s) = s) :
    ∃ w : W, reconstruct (shadow w) = w := by
  by_contra h_contra;
  simp +zetaDelta at *;
  -- Let $s$ be an arbitrary element of $S$.
  obtain ⟨s, hs⟩ : ∃ s : S, True := by
    exact ⟨ Classical.arbitrary S, trivial ⟩;
  exact h_contra ( reconstruct s ) ( by simp +decide [ h_section ] )

/-
PROBLEM
**The Fundamental Theorem of Symmetric Gazing Pools**:
In a gazing pool where reflection preserves shadows
(the pool is "symmetric"), every reconstructed element is conscious.

PROVIDED SOLUTION
Since W is nonempty, S is nonempty (shadow is surjective). Take any s : S. Let w = reconstruct(s). Then gaze(w) = reconstruct(shadow(reflect(w))) = reconstruct(shadow(w)) by h_symm. And shadow(w) = shadow(reconstruct(s)) = s by shadow_reconstruct. So gaze(w) = reconstruct(s) = w. Thus w is conscious.
-/
theorem symmetric_pool_consciousness
    {W : Type*} [Nonempty W] (P : GazingPool W)
    (h_symm : ∀ w, P.shadow (P.reflect w) = P.shadow w) :
    ∃ w : W, P.IsConscious w := by
  -- By the retraction theorem, there exists a w in W such that reconstruct(shadow(w)) = w.
  obtain ⟨w, hw⟩ : ∃ w : W, P.reconstruct (P.shadow w) = w := by
    exact ⟨ P.reconstruct ( P.shadow ( Classical.arbitrary W ) ), by simp +decide [ P.shadow_reconstruct ] ⟩;
  -- By definition of IsConscious, we need to show that P.gaze w = w.
  use w
  simp [GazingPool.IsConscious, GazingPool.gaze, hw, h_symm]

/-- **Uniqueness of Consciousness in Contractive Pools**:
Conscious observers are at distance zero — essentially unique. -/
theorem consciousness_unique {W : Type*} (P : ContractiveGazingPool W)
    (w₁ w₂ : W) (h₁ : P.toGazingPool.IsConscious w₁)
    (h₂ : P.toGazingPool.IsConscious w₂) :
    P.dist w₁ w₂ = 0 := by
  have := P.gaze_contractive w₁ w₂
  have h_dist_zero : P.dist w₁ w₂ ≤ P.κ * P.dist w₁ w₂ := by rwa [h₁, h₂] at this
  nlinarith [P.κ_lt_one, P.κ_nonneg, P.dist_nonneg w₁ w₂]

/-
PROBLEM
**Universe Stratification**: No type can enumerate all types.

PROVIDED SOLUTION
If ∃ (U : Type) (f : U → Type), ∀ T : Type, ∃ u, f u = T, then in particular taking T = (U → Prop) : Type, we get ∃ u, f u = (U → Prop). This means we can build a surjection from U to (U → Prop), contradicting Cantor's theorem. More precisely: define g : U → (U → Prop) by g(u)(u') = (u' ∈ ... ). Actually, from the hypothesis, we get a function h : Type → U such that f(h(T)) = T for all T. Consider T = Set U = (U → Prop). Then f(h(Set U)) = Set U. We need a surjection U → Set U, which we can get by: for any s : Set U, let u_s = h(f(u_s) ... hmm this doesn't directly give a surjection. Let me think differently. The hypothesis says every Type is in the range of f. In particular, Prop, Bool, Nat, etc. are all in the range. But the key is Set U = U → Prop is a Type, so there exists u₀ with f(u₀) = (U → Prop). But this alone doesn't give a surjection from U to Set U. We'd need to enumerate elements of Set U via U. Actually, the hypothesis gives us ∀ T, ∃ u, f u = T. But Set U is a type with cardinality 2^|U| which is strictly greater than |U| by Cantor. However, Set U can be embedded into the range of f (which has cardinality ≤ |U|). Hmm, actually the range of f has cardinality ≤ |U| since f : U → Type. But f maps to types, not elements of types. The statement says f u = T as TYPE EQUALITY, not as a bijection. So the statement says every Type (in the universe Type) is literally equal to some f(u). This means there's a surjection from U onto the collection of all types in Type. Since Set U : Type and there's u₀ with f(u₀) = Set U, we can transport any element of Set U via this equality. But we still can't get a surjection from U onto Set U directly from this.

Actually let me try a simpler approach. From the hypothesis, the function f : U → Type has range = all of Type. Consider the diagonal set D = {u : U | ∀ (x : f u), True} - no this doesn't work with type equality.

Let me try yet another approach: use `Function.cantor_surjective` which says ¬ Surjective (f : α → (α → Prop)). From our hypothesis, we can construct a surjection U → (U → Prop) as follows: we know ∃ u₀, f u₀ = (U → Prop). Fix such u₀. We need to map each u : U to some element of (U → Prop). But f(u) for arbitrary u is some arbitrary type, not necessarily (U → Prop). So we can't directly construct a surjection.

Hmm, maybe the statement is actually not provable in Lean's type theory without additional axioms? Or maybe it IS provable using the fact that Type has too many types. Let me try to use a simpler version: the fact that not all types in Type are equal to some element indexed by U, because Set U : Type and there's no surjection U → Set U.

Actually, I think the proof goes: assuming ∀ T, ∃ u, f u = T, we have in particular that the function f is surjective onto Type (as a "set" of types). Since Set U : Type, there's u₀ with f u₀ = Set U. Now define g : U → Set U by: for each u : U, if f u = Set U, transport some canonical element; otherwise, use ∅. This doesn't give surjectivity.

I think the cleanest approach uses the fact that |Type| > |U| for any U : Type. In Lean with the axiom of choice, we can use this. But actually I'm not sure this is provable without careful universe manipulation. Let me just try the subagent and see.
-/
theorem universe_stratification :
    ¬ ∃ (U : Type) (f : U → Type), ∀ T : Type, ∃ u : U, f u = T := by
  intro ⟨ U, f, hf ⟩;
  contrapose! hf with h_contra;
  refine' ⟨ _, fun u hu ↦ _ ⟩;
  exact ULift ( Set ( Σ u : U, f u ) );
  replace hu := congr_arg Cardinal.mk hu ; simp +decide at hu;
  refine' hu.not_lt _;
  refine' lt_of_le_of_lt _ ( Cardinal.cantor _ );
  exact Cardinal.le_sum ( fun i => Cardinal.mk ( f i ) ) u

end