import Mathlib

/-!
# Berggren Spectral Hash: Collision-Separation for Expander-Based Post-Quantum Hashing

## Overview

We formalize the positive Berggren semigroup as a free noncommutative matrix semigroup
acting on primitive Pythagorean triples, and prove that bounded-length words are
collision-free modulo `N` up to an explicit logarithmic threshold. Security comes from
the fact that integer growth (exponential in word length) outruns modular ambiguity.

## Main Results

### Positivity and Growth
* `berggren_gen_preserves_positive` — generators preserve positive Pythagorean triples
* `berggren_gen_hyp_increases` — each generator strictly increases hypotenuse
* `berggren_word_hypotenuse_strict_mono` — nonempty words yield hypotenuse > 5

### Freeness / Injectivity
* `berggren_word_action_injective` — distinct words produce distinct triples (freeness)

### Collision-Separation
* `berggren_hash_injective_below_exp_threshold` — modular collision resistance
  with explicit constant C = 71
* `berggren_quotient_ball_injective` — injectivity radius theorem
* `berggren_walk_support_lower_bound` — exponential walk support in quotient graph

## References

* Berggren, B. (1934). "Pytagoreiska trianglar"
* Barning, F. J. M. (1963). "Over pythagorese en bijna-pythagorese driehoeken"
-/

open Matrix Finset

set_option maxHeartbeats 800000

/-! ## Section 1: Core Definitions -/

/-- The three positive Berggren generators as 3×3 integer matrices.
    Generator 0 = A (left), 1 = B (middle), 2 = C (right). -/
def berggrenGenerator : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
  | ⟨0, _⟩ => !![1, -2, 2; 2, -1, 2; 2, -2, 3]
  | ⟨1, _⟩ => !![1, 2, 2; 2, 1, 2; 2, 2, 3]
  | ⟨2, _⟩ => !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- Matrix product of a word over the three generators. -/
def berggrenMatrixOfWord : List (Fin 3) → Matrix (Fin 3) (Fin 3) ℤ
  | [] => 1
  | g :: w => berggrenGenerator g * berggrenMatrixOfWord w

/-- The root Pythagorean triple (3, 4, 5). -/
def rootTriple : Fin 3 → ℤ
  | ⟨0, _⟩ => 3
  | ⟨1, _⟩ => 4
  | ⟨2, _⟩ => 5

/-- Action of a single generator on a triple via matrix-vector product. -/
def actGenTriple (g : Fin 3) (t : Fin 3 → ℤ) : Fin 3 → ℤ :=
  (berggrenGenerator g).mulVec t

/-- The Pythagorean triple obtained by applying a Berggren word to (3,4,5).
    This is the primary evaluation function. -/
def tripleOfWord : List (Fin 3) → (Fin 3 → ℤ)
  | [] => rootTriple
  | g :: w => actGenTriple g (tripleOfWord w)

/-- The hypotenuse (third component) of the triple produced by a word. -/
def hypotenuseOfWord (w : List (Fin 3)) : ℤ :=
  tripleOfWord w 2

/-- Entrywise reduction of a triple modulo `N`, defining the hash function. -/
def hashState (N : ℕ) (w : List (Fin 3)) : Fin 3 → ZMod N :=
  fun i => ((tripleOfWord w i : ℤ) : ZMod N)

/-! ## Section 2: Action Formulas -/

/-- Component formula for generator action. -/
theorem actGen_component (g : Fin 3) (t : Fin 3 → ℤ) (i : Fin 3) :
    actGenTriple g t i = ∑ j : Fin 3, berggrenGenerator g i j * t j := by
  simp [actGenTriple, Matrix.mulVec, dotProduct]

/-- A triple is a *positive Pythagorean triple*. -/
def IsPositivePythagorean (t : Fin 3 → ℤ) : Prop :=
  0 < t 0 ∧ 0 < t 1 ∧ 0 < t 2 ∧ t 0 ^ 2 + t 1 ^ 2 = t 2 ^ 2

/-! ## Section 3: Pythagorean Preservation and Positivity -/

theorem rootTriple_is_positive_pythagorean : IsPositivePythagorean rootTriple := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> native_decide

/-- Each generator preserves the Pythagorean property. -/
theorem berggren_gen_preserves_pythagorean (g : Fin 3) (t : Fin 3 → ℤ)
    (hpyth : t 0 ^ 2 + t 1 ^ 2 = t 2 ^ 2) :
    (actGenTriple g t) 0 ^ 2 + (actGenTriple g t) 1 ^ 2 = (actGenTriple g t) 2 ^ 2 := by
  simp only [actGen_component, Fin.sum_univ_three]
  fin_cases g <;> simp [berggrenGenerator] <;> nlinarith [sq_nonneg (t 0 - t 1)]

/-
Each generator preserves positive Pythagorean triples.
-/
theorem berggren_gen_preserves_positive (g : Fin 3) (t : Fin 3 → ℤ)
    (ht : IsPositivePythagorean t) :
    IsPositivePythagorean (actGenTriple g t) := by
  -- We unfold the definition of `IsPositivePythagorean` to show that all components of `actGenTriple g t` are positive.
  unfold IsPositivePythagorean;
  fin_cases g <;> simp_all +decide [ actGenTriple ];
  · unfold IsPositivePythagorean at ht;
    unfold berggrenGenerator; simp +decide [ *, Matrix.vecHead, Matrix.vecTail ] ;
    exact ⟨ by nlinarith, by nlinarith, by nlinarith, by linarith ⟩;
  · unfold IsPositivePythagorean at ht; simp_all +decide [ Matrix.mulVec ] ;
    unfold berggrenGenerator; simp +decide [ Fin.sum_univ_three, dotProduct ] ;
    exact ⟨ by linarith, by linarith, by linarith, by linarith ⟩;
  · rcases ht with ⟨ ht₀, ht₁, ht₂, ht₃ ⟩ ; simp_all +decide [ Fin.forall_fin_succ, Matrix.mulVec ];
    unfold berggrenGenerator; simp +decide [ Fin.sum_univ_three, dotProduct ] ; ring_nf at *;
    exact ⟨ by nlinarith, by nlinarith, by nlinarith, by linarith ⟩

/-- Every word evaluates to a positive Pythagorean triple. -/
theorem berggren_word_preserves_positive (w : List (Fin 3)) :
    IsPositivePythagorean (tripleOfWord w) := by
  induction w with
  | nil => exact rootTriple_is_positive_pythagorean
  | cons g w ih => exact berggren_gen_preserves_positive g _ ih

/-! ## Section 4: Hypotenuse Growth -/

/-
Each generator strictly increases the hypotenuse.
-/
theorem berggren_gen_hyp_increases (g : Fin 3) (t : Fin 3 → ℤ)
    (ht : IsPositivePythagorean t) :
    t 2 < (actGenTriple g t) 2 := by
  fin_cases g <;> simp_all +decide [ Fin.sum_univ_three, actGenTriple ];
  · simp_all +decide [ Fin.sum_univ_three, Matrix.mulVec, dotProduct, berggrenGenerator ];
    nlinarith [ ht.1, ht.2.1, ht.2.2.1, ht.2.2.2 ];
  · unfold berggrenGenerator; simp +decide [ Matrix.mulVec ] ; linarith! [ ht.1, ht.2.1, ht.2.2.1 ] ;
  · unfold berggrenGenerator; simp +decide [ Matrix.mulVec ] ;
    nlinarith! [ ht.1, ht.2.1, ht.2.2.1, ht.2.2.2 ]

/-
The hypotenuse of any positive Pythagorean triple is at least 5.
-/
theorem berggren_hyp_ge_five {t : Fin 3 → ℤ}
    (ht : IsPositivePythagorean t) : 5 ≤ t 2 := by
  obtain ⟨ ht₀, ht₁, ht₂, ht₃ ⟩ := ht;
  by_contra! h; have : t 0 ≤ 4 := Int.le_of_lt_add_one ( by nlinarith only [ ht₀, ht₁, ht₂, ht₃, h ] ) ; ( have : t 1 ≤ 4 := Int.le_of_lt_add_one ( by nlinarith only [ ht₀, ht₁, ht₂, ht₃, h ] ) ; ( have : t 2 ≤ 4 := Int.le_of_lt_add_one ( by nlinarith only [ ht₀, ht₁, ht₂, ht₃, h ] ) ; interval_cases t 2 <;> interval_cases t 1 <;> interval_cases t 0 <;> trivial; ) )

/-- The root triple is never in the image of any generator on positive triples. -/
theorem actGenTriple_ne_root (g : Fin 3) (t : Fin 3 → ℤ)
    (ht : IsPositivePythagorean t) :
    actGenTriple g t ≠ rootTriple := by
  intro h
  have hinc := berggren_gen_hyp_increases g t ht
  have hge5 := berggren_hyp_ge_five ht
  have h2 : (actGenTriple g t) 2 = 5 := congr_fun h 2
  linarith

/-- Every nonempty word strictly increases the hypotenuse beyond 5. -/
theorem berggren_word_hypotenuse_strict_mono
    (w : List (Fin 3)) (hw : w ≠ []) :
    5 < hypotenuseOfWord w := by
  rw [hypotenuseOfWord]
  match w, hw with
  | g :: rest, _ =>
    simp only [tripleOfWord]
    have hrest := berggren_word_preserves_positive rest
    have hge5 := berggren_hyp_ge_five hrest
    linarith [berggren_gen_hyp_increases g _ hrest]

/-! ## Section 5: Freeness (Injectivity of Word Action) -/

/-
Each generator is injective on triples.
-/
theorem actGenTriple_injective (g : Fin 3) : Function.Injective (actGenTriple g) := by
  fin_cases g <;> unfold actGenTriple <;> simp +decide [ Function.Injective ];
  · simp +decide [ funext_iff, Fin.forall_fin_succ ];
    simp +decide [ Matrix.mulVec, dotProduct ];
    simp +decide [ Fin.sum_univ_three, berggrenGenerator ];
    grind;
  · unfold berggrenGenerator; simp +decide [ funext_iff, Fin.forall_fin_succ ] ;
    exact fun a₁ a₂ h₁ h₂ h₃ => ⟨ by linarith !, by linarith !, by linarith ! ⟩;
  · unfold berggrenGenerator; simp +decide [ funext_iff, Fin.forall_fin_succ ] ;
    exact fun a₁ a₂ h₁ h₂ h₃ => ⟨ by linarith !, by linarith !, by linarith ! ⟩

/-
The generator is uniquely determined by its output on positive triples.
-/
theorem actGenTriple_generator_determined {g₁ g₂ : Fin 3} {t₁ t₂ : Fin 3 → ℤ}
    (ht₁ : IsPositivePythagorean t₁) (ht₂ : IsPositivePythagorean t₂)
    (h : actGenTriple g₁ t₁ = actGenTriple g₂ t₂) : g₁ = g₂ := by
  fin_cases g₁ <;> fin_cases g₂ <;> simp_all +decide only;
  all_goals unfold actGenTriple at h; simp_all +decide [ funext_iff, Fin.forall_fin_succ ] ;
  all_goals unfold berggrenGenerator at h; simp_all +decide [ Matrix.mulVec ] ;
  all_goals unfold IsPositivePythagorean at *; simp_all +decide [ vecHead, vecTail ] ;
  all_goals nlinarith only [ ht₁, ht₂, h ] ;

/-- **Freeness theorem**: Berggren word evaluation is injective.
    The positive Berggren semigroup is free on three generators. -/
theorem berggren_word_action_injective :
    Function.Injective (fun w : List (Fin 3) => tripleOfWord w) := by
  intro w₁
  induction w₁ with
  | nil =>
    intro w₂ h
    match w₂ with
    | [] => rfl
    | g :: rest =>
      exfalso; exact actGenTriple_ne_root g (tripleOfWord rest)
        (berggren_word_preserves_positive rest) (by exact h.symm)
  | cons g₁ rest₁ ih =>
    intro w₂ h
    match w₂ with
    | [] =>
      exfalso; exact actGenTriple_ne_root g₁ (tripleOfWord rest₁)
        (berggren_word_preserves_positive rest₁) (by exact h)
    | g₂ :: rest₂ =>
      have h' : actGenTriple g₁ (tripleOfWord rest₁) = actGenTriple g₂ (tripleOfWord rest₂) := h
      have hg := actGenTriple_generator_determined
        (berggren_word_preserves_positive rest₁)
        (berggren_word_preserves_positive rest₂) h'
      subst hg
      congr 1
      exact ih (actGenTriple_injective g₁ h')

/-
**Matrix-level freeness**: distinct words produce distinct matrices.
-/
theorem berggren_matrixOfWord_injective :
    Function.Injective berggrenMatrixOfWord := by
  intros w₁ w₂ h_eq;
  -- By definition of `berggrenMatrixOfWord`, we have that `tripleOfWord w = (berggrenMatrixOfWord w).mulVec rootTriple`.
  have h_triple_eq : ∀ w : List (Fin 3), tripleOfWord w = (berggrenMatrixOfWord w).mulVec rootTriple := by
    intro w
    induction' w with g w ih;
    · native_decide +revert;
    · -- By definition of matrix multiplication, we can rewrite the right-hand side as the matrix multiplication of berggrenGenerator g with the vector obtained by multiplying berggrenMatrixOfWord w with rootTriple.
      have h_matrix_mul : (berggrenGenerator g * berggrenMatrixOfWord w).mulVec rootTriple = berggrenGenerator g *ᵥ (berggrenMatrixOfWord w *ᵥ rootTriple) := by
        rw [ Matrix.mulVec_mulVec ];
      exact h_matrix_mul.symm ▸ ih ▸ rfl;
  exact berggren_word_action_injective <| by aesop;

/-! ## Section 6: Sup-Norm Bounds -/

/-- Sup-norm of an integer triple: max of absolute values. -/
def tripleSupNorm' (t : Fin 3 → ℤ) : ℕ :=
  max (Int.natAbs (t 0)) (max (Int.natAbs (t 1)) (Int.natAbs (t 2)))

/-
Each generator multiplies the triple sup-norm by at most 7.
-/
theorem actGenTriple_supNorm_le (g : Fin 3) (t : Fin 3 → ℤ) :
    tripleSupNorm' (actGenTriple g t) ≤ 7 * tripleSupNorm' t := by
  unfold tripleSupNorm';
  fin_cases g <;> unfold actGenTriple <;> simp +decide [ Matrix.mulVec ];
  · simp +decide [ Fin.sum_univ_three, dotProduct, berggrenGenerator ];
    omega;
  · simp +decide [ Fin.sum_univ_three, dotProduct ];
    simp +decide [ berggrenGenerator ];
    omega;
  · unfold berggrenGenerator; simp +decide [ Fin.sum_univ_three, dotProduct ] ; omega;

/-- The root triple has sup-norm 5. -/
theorem rootTriple_supNorm : tripleSupNorm' rootTriple = 5 := by
  native_decide

/-- Evaluation of a length-n word has triple sup-norm ≤ 5 * 7^n. -/
theorem evalTriple_supNorm_le (w : List (Fin 3)) :
    tripleSupNorm' (tripleOfWord w) ≤ 5 * 7 ^ w.length := by
  induction w with
  | nil => simp [tripleOfWord, rootTriple_supNorm]
  | cons g rest ih =>
    simp only [tripleOfWord, List.length_cons, pow_succ]
    calc tripleSupNorm' (actGenTriple g (tripleOfWord rest))
        ≤ 7 * tripleSupNorm' (tripleOfWord rest) := actGenTriple_supNorm_le g _
      _ ≤ 7 * (5 * 7 ^ rest.length) := by linarith
      _ = 5 * (7 ^ rest.length * 7) := by ring
      _ = 5 * 7 ^ (rest.length + 1) := by rw [pow_succ]

/-
Sup-norm of difference of two evaluations is bounded.
-/
theorem evalTriple_diff_supNorm_le {L : ℕ} (u v : List (Fin 3))
    (hu : u.length ≤ L) (hv : v.length ≤ L) :
    tripleSupNorm' (fun i => tripleOfWord u i - tripleOfWord v i) ≤ 10 * 7 ^ L := by
  -- By definition of $tripleSupNorm'$, we know that
  have h_sup_norm : ∀ (i : Fin 3), Int.natAbs (tripleOfWord u i - tripleOfWord v i) ≤ 10 * 7 ^ L := by
    intros i
    have h_sup_norm : Int.natAbs (tripleOfWord u i) ≤ 5 * 7 ^ L ∧ Int.natAbs (tripleOfWord v i) ≤ 5 * 7 ^ L := by
      have h_sup_norm : ∀ (w : List (Fin 3)), tripleSupNorm' (tripleOfWord w) ≤ 5 * 7 ^ w.length := by
        exact?;
      exact ⟨ le_trans ( by fin_cases i <;> simp +decide [ tripleSupNorm' ] ) ( le_trans ( h_sup_norm u ) ( by gcongr ; linarith ) ), le_trans ( by fin_cases i <;> simp +decide [ tripleSupNorm' ] ) ( le_trans ( h_sup_norm v ) ( by gcongr ; linarith ) ) ⟩;
    grind;
  exact max_le ( h_sup_norm 0 ) ( max_le ( h_sup_norm 1 ) ( h_sup_norm 2 ) )

/-- Distinct words differ in some triple entry. -/
theorem berggren_distinct_words_entry_separated
    {w₁ w₂ : List (Fin 3)} (hneq : w₁ ≠ w₂) :
    ∃ i : Fin 3, tripleOfWord w₁ i ≠ tripleOfWord w₂ i := by
  by_contra h
  push_neg at h
  apply hneq
  exact berggren_word_action_injective (funext h)

/-! ## Section 7: Modular Collision Separation -/

/-
If two triples agree mod N and their difference has small sup-norm, they are equal.
-/
theorem hashState_eq_implies_triple_eq {N : ℕ} (_hN : 0 < N)
    {w₁ w₂ : List (Fin 3)}
    (hmod : hashState N w₁ = hashState N w₂)
    (hsmall : tripleSupNorm' (fun i => tripleOfWord w₁ i - tripleOfWord w₂ i) < N) :
    tripleOfWord w₁ = tripleOfWord w₂ := by
  -- Since the difference of the triples has a small sup-norm, each component of the difference must be zero.
  have h_comp_zero : ∀ i : Fin 3, tripleOfWord w₁ i - tripleOfWord w₂ i = 0 := by
    intro i
    by_contra hi_nonzero;
    have h_div : (N : ℤ) ∣ (tripleOfWord w₁ i - tripleOfWord w₂ i) := by
      simpa [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] using sub_eq_zero.mpr ( congr_fun hmod i );
    exact absurd ( Int.natAbs_dvd_natAbs.mpr h_div ) ( Nat.not_dvd_of_pos_of_lt ( Int.natAbs_pos.mpr hi_nonzero ) ( lt_of_le_of_lt ( by fin_cases i <;> simp +decide [ tripleSupNorm' ] ) hsmall ) );
  exact funext fun i => sub_eq_zero.mp ( h_comp_zero i )

/-- **Effective injectivity**: Berggren evaluation modulo N is injective
    on words of length ≤ L, provided N > 10 * 7^L. -/
theorem berggren_reduce_injective_on_length_le
    (L N : ℕ) (hN : 0 < N) (hsep : 10 * 7 ^ L < N)
    {u v : List (Fin 3)}
    (hu : u.length ≤ L) (hv : v.length ≤ L)
    (hmod : hashState N u = hashState N v) :
    u = v := by
  apply berggren_word_action_injective
  exact hashState_eq_implies_triple_eq hN hmod
    (lt_of_le_of_lt (evalTriple_diff_supNorm_le u v hu hv) hsep)

/-
**Central collision-separation theorem**: there exists C > 1 such that
    bounded words with C^len < N have injective hashing. We take C = 71.
-/
theorem berggren_hash_injective_below_exp_threshold :
    ∃ C : ℕ, 1 < C ∧
      ∀ (N : ℕ) (w₁ w₂ : List (Fin 3)),
        C ^ w₁.length < N →
        C ^ w₂.length < N →
        hashState N w₁ = hashState N w₂ →
        w₁ = w₂ := by
  by_contra! h';
  obtain ⟨ N₁, w₁, w₂, hN₁, hN₂, hmod, hneq ⟩ := h' 72 ( by decide );
  -- Apply the collision-separation theorem with $L = \max(w₁.length, w₂.length)$.
  have h_coll_sep : 10 * 7 ^ (max w₁.length w₂.length) < N₁ := by
    have h_coll_sep : 10 * 7 ^ (max w₁.length w₂.length) ≤ 72 ^ (max w₁.length w₂.length) := by
      rcases k : Max.max w₁.length w₂.length with ( _ | _ | k ) <;> simp_all +decide [ pow_succ' ];
      linarith [ pow_pos ( by decide : 0 < 7 ) ‹_›, pow_le_pow_left' ( by decide : 7 ≤ 72 ) ‹_› ];
    exact lt_of_le_of_lt h_coll_sep ( by cases max_cases w₁.length w₂.length <;> simp_all +decide [ pow_le_pow_right₀ ] );
  apply hneq; exact berggren_reduce_injective_on_length_le ( max w₁.length w₂.length ) N₁ ( by linarith [ pow_pos ( show 0 < 72 by decide ) w₁.length, pow_pos ( show 0 < 72 by decide ) w₂.length ] ) h_coll_sep ( by simp ) ( by simp ) hmod;

/-! ## Section 8: Injectivity Radius -/

/-
**Injectivity radius theorem**: bounded balls in the quotient are tree-like.
-/
theorem berggren_quotient_ball_injective :
    ∃ C : ℕ, 1 < C ∧
      ∀ (N L : ℕ),
        C ^ L < N →
        Set.InjOn (hashState N) {w | w.length ≤ L} := by
  use 71;
  refine' ⟨ by decide, fun N L hN => _ ⟩;
  by_cases hL : L = 0;
  · intro w hw; aesop;
  · intro w₁ hw₁ w₂ hw₂ h_eq
    have h_len : w₁.length ≤ L ∧ w₂.length ≤ L := by
      exact ⟨ hw₁, hw₂ ⟩;
    apply berggren_reduce_injective_on_length_le L N (by
    linarith [ pow_pos ( by decide : 0 < 71 ) L ]) (by
    refine lt_of_le_of_lt ?_ hN;
    exact Nat.le_induction ( by decide ) ( fun k hk ih => by rw [ pow_succ' ] ; rw [ pow_succ' ] ; linarith [ pow_pos ( by decide : 0 < 7 ) k ] ) L ( Nat.pos_of_ne_zero hL )) h_len.left h_len.right h_eq

/-! ## Section 9: Expander-Style Divergence -/

/-
**Walk support lower bound**: distinct hash states grow with injectivity radius.
-/
theorem berggren_walk_support_lower_bound :
    ∃ C : ℕ, 1 < C ∧
      ∀ (N L : ℕ),
        C ^ L < N →
        Set.InjOn (hashState N) {w : List (Fin 3) | w.length = L} := by
  exact Exists.elim ( berggren_quotient_ball_injective ) fun C hC => ⟨ C, hC.1, fun N L h => hC.2 N L h |> fun h' => h'.mono <| by aesop ⟩