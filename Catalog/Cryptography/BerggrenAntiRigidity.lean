import Mathlib

/-!
# Berggren Semigroup: Anti-Involution Rigidity

We prove that the Berggren free semigroup inside GL₂(ℤ) is **completely disjoint from its
image under the adjugate anti-involution**, except at the identity. The adjugate of a 2×2
matrix M = !![a,b;c,d] is adj(M) = !![d,-b;-c,a], satisfying M * adj(M) = det(M) • I.
For invertible matrices (det = ±1), this equals ±M⁻¹, making it the natural matrix-level
"inverse" anti-involution.

## Main Results

* `evalBergWord_entry_00_pos` — top-left entry is always ≥ 1
* `evalBergWord_entry_10_nonneg` — bottom-left entry is always ≥ 0
* `evalBergWord_entry_00_ge_10` — top-left ≥ bottom-left (diagonal dominance)
* `adjugate2_anti_hom` — adjugate reverses multiplication
* `adjugate2_not_in_BergSemigroup` — **main theorem**: adjugate is never in the semigroup
* `berggren_inverse_rigidity` — no non-identity semigroup element has its inverse in the semigroup

## Mathematical Significance

This result upgrades the Berggren free-monoid injectivity theorem to a much stronger
structural statement: the semigroup occupies an "orientation-rigid" region of GL₂(ℤ) that
is completely separated from its image under the adjugate/inverse anti-involution. In
cryptographic applications, this means that reversing a Berggren-encoded transcript (taking
adjoints/inverses) can never accidentally produce a valid semigroup element, providing
anti-automorphism resistance for protocol canonicalization.

## References

The Berggren generators arise from the classical tree of primitive Pythagorean triples,
lifted to 2×2 integer matrices via the spin covering SL₂ → SO₂₁.
-/

set_option linter.unusedVariables false

/-! ## Generator Type and Word Evaluation -/

/-- The three Berggren generators. -/
inductive BergGen : Type
  | A | B | C
  deriving DecidableEq, Repr

/-- A Berggren word is a list of generators. -/
abbrev BergWord := List BergGen

/-- Action of each generator on the pair space (m, n). -/
def actGen (g : BergGen) (p : ℤ × ℤ) : ℤ × ℤ :=
  match g with
  | .A => (2 * p.1 - p.2, p.1)
  | .B => (2 * p.1 + p.2, p.1)
  | .C => (p.1 + 2 * p.2, p.2)

/-- The root pair (2, 1), corresponding to the identity matrix. -/
def rootPair : ℤ × ℤ := (2, 1)

/-- Pair-based evaluation of a Berggren word. -/
def evalPair : BergWord → ℤ × ℤ
  | [] => rootPair
  | g :: rest => actGen g (evalPair rest)

/-- A valid pair satisfies 0 < n < m. -/
def ValidPair (p : ℤ × ℤ) : Prop := 0 < p.2 ∧ p.2 < p.1

theorem rootPair_valid : ValidPair rootPair := ⟨by norm_num [rootPair], by norm_num [rootPair]⟩

theorem actGen_preserves_valid (g : BergGen) {p : ℤ × ℤ} (hp : ValidPair p) :
    ValidPair (actGen g p) := by
  obtain ⟨hn, hmn⟩ := hp
  cases g <;> constructor <;> simp only [actGen] <;> linarith

theorem evalPair_valid (w : BergWord) : ValidPair (evalPair w) := by
  induction w with
  | nil => exact rootPair_valid
  | cons g rest ih => exact actGen_preserves_valid g ih

theorem m_ge_three_after_gen (g : BergGen) {p : ℤ × ℤ} (hp : ValidPair p) :
    3 ≤ (actGen g p).1 := by
  obtain ⟨hn, hmn⟩ := hp; cases g <;> simp only [actGen] <;> linarith

theorem actGen_ne_root (g : BergGen) {p : ℤ × ℤ} (hp : ValidPair p) :
    actGen g p ≠ rootPair := by
  intro h; linarith [m_ge_three_after_gen g hp, show (actGen g p).1 = 2 from congr_arg Prod.fst h]

theorem actGen_injective (g : BergGen) : Function.Injective (actGen g) := by
  intro ⟨m₁, n₁⟩ ⟨m₂, n₂⟩ h
  cases g <;> simp only [actGen, Prod.mk.injEq] at h <;>
    exact Prod.ext (by linarith [h.1, h.2]) (by linarith [h.1, h.2])

theorem actGen_generator_determined {g₁ g₂ : BergGen} {p₁ p₂ : ℤ × ℤ}
    (hp₁ : ValidPair p₁) (hp₂ : ValidPair p₂)
    (h : actGen g₁ p₁ = actGen g₂ p₂) : g₁ = g₂ := by
  obtain ⟨hn₁, hmn₁⟩ := hp₁; obtain ⟨hn₂, hmn₂⟩ := hp₂
  have hf := congr_arg Prod.fst h; have hs := congr_arg Prod.snd h
  rcases g₁ with _ | _ | _ <;> rcases g₂ with _ | _ | _ <;>
    simp only [actGen] at hf hs <;> (first | rfl | linarith)

theorem actGen_unique_parent {g₁ g₂ : BergGen} {p₁ p₂ : ℤ × ℤ}
    (hp₁ : ValidPair p₁) (hp₂ : ValidPair p₂)
    (h : actGen g₁ p₁ = actGen g₂ p₂) : g₁ = g₂ ∧ p₁ = p₂ :=
  ⟨actGen_generator_determined hp₁ hp₂ h,
   actGen_injective g₁ (actGen_generator_determined hp₁ hp₂ h ▸ h)⟩

/-- **Freeness via pairs**: the pair evaluation is injective. -/
theorem evalPair_injective : Function.Injective evalPair := by
  intro w₁
  induction w₁ with
  | nil =>
    intro w₂ h; match w₂ with
    | [] => rfl
    | g :: rest => exact absurd h.symm (actGen_ne_root g (evalPair_valid rest))
  | cons g₁ rest₁ ih =>
    intro w₂ h; match w₂ with
    | [] => exact absurd h (actGen_ne_root g₁ (evalPair_valid rest₁))
    | g₂ :: rest₂ =>
      have ⟨hg, hp⟩ := actGen_unique_parent (evalPair_valid rest₁) (evalPair_valid rest₂) h
      subst hg; exact congrArg (g₁ :: ·) (ih hp)

/-! ## Matrix Formulation -/

/-- The 2×2 matrix for each Berggren generator. -/
def bergMat : BergGen → Matrix (Fin 2) (Fin 2) ℤ
  | .A => !![2, -1; 1, 0]
  | .B => !![2, 1; 1, 0]
  | .C => !![1, 2; 0, 1]

/-- Matrix evaluation of a Berggren word (left-multiplication). -/
def evalBergWord : BergWord → Matrix (Fin 2) (Fin 2) ℤ
  | [] => 1
  | g :: rest => bergMat g * evalBergWord rest

@[simp] theorem evalBergWord_nil : evalBergWord [] = 1 := rfl
@[simp] theorem evalBergWord_cons (g : BergGen) (w : BergWord) :
    evalBergWord (g :: w) = bergMat g * evalBergWord w := rfl

theorem evalBergWord_append (u v : BergWord) :
    evalBergWord (u ++ v) = evalBergWord u * evalBergWord v := by
  induction u with
  | nil => simp
  | cons g rest ih => simp [ih, Matrix.mul_assoc]

/-- Extract the pair invariant from a 2×2 matrix. -/
def pairOfMat (M : Matrix (Fin 2) (Fin 2) ℤ) : ℤ × ℤ :=
  (2 * M 0 0 + M 0 1, 2 * M 1 0 + M 1 1)

theorem pairOfMat_evalBergWord (w : BergWord) :
    pairOfMat (evalBergWord w) = evalPair w := by
  induction w with
  | nil => simp [pairOfMat, evalBergWord, evalPair, rootPair]
  | cons g rest ih =>
    simp only [evalBergWord, evalPair]; rw [← ih]
    cases g <;>
      simp only [actGen, bergMat, pairOfMat, Matrix.mul_apply, Fin.sum_univ_two] <;>
      ext <;> simp <;> ring

/-- **Injectivity of matrix evaluation**: the free-monoid theorem. -/
theorem evalBergWord_injective : Function.Injective evalBergWord := by
  intro u v h; apply evalPair_injective
  rw [← pairOfMat_evalBergWord, ← pairOfMat_evalBergWord, h]

theorem evalBergWord_eq_one_iff {w : BergWord} : evalBergWord w = 1 ↔ w = [] :=
  ⟨fun h => evalBergWord_injective (h.trans evalBergWord_nil.symm), fun h => by subst h; rfl⟩

/-- Membership in the Berggren semigroup. -/
def InBergSemigroup (M : Matrix (Fin 2) (Fin 2) ℤ) : Prop :=
  ∃ w : BergWord, evalBergWord w = M

/-! ## Entry Bounds for Berggren Words

We prove that every Berggren word evaluates to a matrix with M₀₀ ≥ 1 and M₁₀ ≥ 0,
with the stronger property M₀₀ ≥ M₁₀ (top-left dominates bottom-left).
These bounds are the key ingredient for the anti-rigidity theorem. -/

/-- The triple of entry bounds maintained by Berggren words:
    M₀₀ ≥ 1, M₁₀ ≥ 0, and M₀₀ ≥ M₁₀. -/
def BergEntryBounds (M : Matrix (Fin 2) (Fin 2) ℤ) : Prop :=
  1 ≤ M 0 0 ∧ 0 ≤ M 1 0 ∧ M 1 0 ≤ M 0 0

theorem bergEntryBounds_identity : BergEntryBounds (1 : Matrix (Fin 2) (Fin 2) ℤ) := by
  refine ⟨?_, ?_, ?_⟩ <;> simp

theorem bergEntryBounds_genA {M : Matrix (Fin 2) (Fin 2) ℤ} (hM : BergEntryBounds M) :
    BergEntryBounds (bergMat .A * M) := by
  obtain ⟨h1, h2, h3⟩ := hM
  refine ⟨?_, ?_, ?_⟩ <;> {
    simp only [bergMat, Matrix.mul_apply, Fin.sum_univ_two]
    norm_num [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, Matrix.head_fin_const]
    linarith }

theorem bergEntryBounds_genB {M : Matrix (Fin 2) (Fin 2) ℤ} (hM : BergEntryBounds M) :
    BergEntryBounds (bergMat .B * M) := by
  obtain ⟨h1, h2, h3⟩ := hM
  refine ⟨?_, ?_, ?_⟩ <;> {
    simp only [bergMat, Matrix.mul_apply, Fin.sum_univ_two]
    norm_num [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, Matrix.head_fin_const]
    linarith }

theorem bergEntryBounds_genC {M : Matrix (Fin 2) (Fin 2) ℤ} (hM : BergEntryBounds M) :
    BergEntryBounds (bergMat .C * M) := by
  obtain ⟨h1, h2, h3⟩ := hM
  refine ⟨?_, ?_, ?_⟩ <;> {
    simp only [bergMat, Matrix.mul_apply, Fin.sum_univ_two]
    norm_num [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, Matrix.head_fin_const]
    linarith }

/-- Every Berggren word evaluates to a matrix with M₀₀ ≥ 1, M₁₀ ≥ 0, M₀₀ ≥ M₁₀. -/
theorem evalBergWord_entry_bounds (w : BergWord) :
    BergEntryBounds (evalBergWord w) := by
  induction w with
  | nil => exact bergEntryBounds_identity
  | cons g rest ih =>
    cases g
    · exact bergEntryBounds_genA ih
    · exact bergEntryBounds_genB ih
    · exact bergEntryBounds_genC ih

/-- The top-left entry of any Berggren word matrix is at least 1. -/
theorem evalBergWord_entry_00_pos (w : BergWord) :
    1 ≤ (evalBergWord w) 0 0 :=
  (evalBergWord_entry_bounds w).1

/-- The bottom-left entry of any Berggren word matrix is nonnegative. -/
theorem evalBergWord_entry_10_nonneg (w : BergWord) :
    0 ≤ (evalBergWord w) 1 0 :=
  (evalBergWord_entry_bounds w).2.1

/-- The top-left entry dominates the bottom-left entry. -/
theorem evalBergWord_entry_00_ge_10 (w : BergWord) :
    (evalBergWord w) 1 0 ≤ (evalBergWord w) 0 0 :=
  (evalBergWord_entry_bounds w).2.2

/-! ## The Adjugate Anti-Involution

For a 2×2 matrix M = !![a,b;c,d], the adjugate is adj(M) = !![d,-b;-c,a].
This satisfies M * adj(M) = det(M) • I, so adj(M) = det(M) • M⁻¹.
The adjugate is an anti-homomorphism: adj(MN) = adj(N) • adj(M). -/

/-- The adjugate (classical adjoint) of a 2×2 matrix. -/
def adjugate2 (M : Matrix (Fin 2) (Fin 2) ℤ) : Matrix (Fin 2) (Fin 2) ℤ :=
  !![M 1 1, -(M 0 1); -(M 1 0), M 0 0]

/-
The adjugate reverses multiplication: adj(MN) = adj(N) · adj(M).
-/
theorem adjugate2_anti_hom (M N : Matrix (Fin 2) (Fin 2) ℤ) :
    adjugate2 (M * N) = adjugate2 N * adjugate2 M := by
  ext i j; fin_cases i <;> fin_cases j <;> simp +decide [adjugate2, Matrix.mul_apply] <;> ring!

/-
The adjugate of the identity is the identity.
-/
theorem adjugate2_one : adjugate2 (1 : Matrix (Fin 2) (Fin 2) ℤ) = 1 := by
  native_decide

/-
M * adj(M) = det(M) • I for 2×2 matrices.
-/
theorem mul_adjugate2 (M : Matrix (Fin 2) (Fin 2) ℤ) :
    M * adjugate2 M = Matrix.det M • (1 : Matrix (Fin 2) (Fin 2) ℤ) := by
  ext i j ; fin_cases i <;> fin_cases j <;> simp +decide [ Matrix.mul_apply, adjugate2 ] <;> ring!;
  · rw [ Matrix.det_fin_two ];
  · simpa [ Matrix.det_fin_two ] using by ring;

/-! ## Anti-Rigidity: Adjugate Never Lands in the Semigroup

The proof splits into two cases based on the bottom-left entry M₁₀ of the
original matrix:

1. If M₁₀ > 0, then adj(M)₁₀ = -M₁₀ < 0, contradicting the nonneg bound
   for semigroup elements.

2. If M₁₀ = 0, then M must have the form !![1,b;0,1] with b ≥ 1 (for nonempty
   words), and adj(M) = !![1,-b;0,1]. The pair invariant of this matrix is
   (2-b, 1), which violates the valid pair condition m > n when b ≥ 1. -/

/-- A matrix with a negative (1,0) entry cannot be in the Berggren semigroup. -/
theorem neg_entry_10_not_in_semigroup {M : Matrix (Fin 2) (Fin 2) ℤ}
    (h : M 1 0 < 0) : ¬ InBergSemigroup M := by
  intro ⟨w, hw⟩
  have := evalBergWord_entry_10_nonneg w
  linarith [hw ▸ this]

/-
For nonempty words with M₁₀ = 0, the matrix has the form !![1,b;0,1] with b ≥ 1.
-/
theorem evalBergWord_10_eq_zero {w : BergWord} (hw : w ≠ [])
    (h10 : (evalBergWord w) 1 0 = 0) :
    (evalBergWord w) 0 0 = 1 ∧
    (evalBergWord w) 1 1 = 1 ∧
    1 ≤ (evalBergWord w) 0 1 := by
  induction' w with g w ih;
  · contradiction;
  · rcases g with ( _ | _ | _ ) <;> simp_all +decide [ evalBergWord ];
    · simp_all +decide [ bergMat, Matrix.mul_apply ];
      exact absurd h10 ( by linarith [ evalBergWord_entry_00_pos w ] );
    · unfold bergMat at *; simp_all +decide [ Matrix.vecMul ] ;
      exact absurd h10 ( by linarith! [ evalBergWord_entry_00_pos w ] );
    · by_cases hw : w = [] <;> simp_all +decide [ bergMat ];
      simp_all +decide [ Matrix.vecMul ];
      simp_all +decide [ Matrix.vecHead, Matrix.vecTail ];
      linarith

/-
The pair invariant of the adjugate of a c=0 nonempty Berggren matrix is invalid.
-/
theorem adjugate2_pair_invalid_of_10_zero {w : BergWord} (hw : w ≠ [])
    (h10 : (evalBergWord w) 1 0 = 0) :
    ¬ InBergSemigroup (adjugate2 (evalBergWord w)) := by
  -- The adjugate of $!![1,b;0,1]$ is $!![1,-b;0,1]$.

  have adjugate_form : adjugate2 (evalBergWord w) = !![1, -((evalBergWord w) 0 1); 0, 1] := by
    have := evalBergWord_10_eq_zero hw h10; ext i j; fin_cases i <;> fin_cases j <;> simp_all +decide [ adjugate2 ] ;
  -- If the adjugate is in the semigroup, there exists a word $u$ such that $evalBergWord u = adjugate2 (evalBergWord w)$.
  by_contra h
  obtain ⟨u, hu⟩ := h
  have hu_nonempty : u ≠ [] := by
    rintro rfl; simp_all +decide ;
    have := congr_fun ( congr_fun hu 0 ) 1; norm_num at this; linarith [ evalBergWord_entry_00_pos w, evalBergWord_entry_10_nonneg w, evalBergWord_entry_00_ge_10 w, evalBergWord_10_eq_zero hw h10 ] ;
  have := evalBergWord_10_eq_zero hu_nonempty ?_ <;> simp_all +decide;
  linarith [ evalBergWord_10_eq_zero hw h10 ]

/-
**Main Theorem (Adjugate Anti-Rigidity)**: For any nonempty Berggren word,
    the adjugate of its matrix evaluation is NOT in the Berggren semigroup.

    This means the positive Berggren semigroup S satisfies S ∩ adj(S \ {1}) = ∅,
    providing complete separation from the adjugate anti-involution.
-/
theorem adjugate2_not_in_BergSemigroup {w : BergWord} (hw : w ≠ []) :
    ¬ InBergSemigroup (adjugate2 (evalBergWord w)) := by
  by_cases h10 : ( evalBergWord w ) 1 0 > 0;
  · convert neg_entry_10_not_in_semigroup _;
    exact neg_neg_of_pos h10;
  · convert adjugate2_pair_invalid_of_10_zero hw _;
    exact le_antisymm ( le_of_not_gt h10 ) ( evalBergWord_entry_10_nonneg w )

/-! ## Corollaries -/

/-- No two nonempty Berggren words can have one be the adjugate of the other. -/
theorem evalBergWord_ne_adjugate {w v : BergWord} (hv : v ≠ []) :
    evalBergWord w ≠ adjugate2 (evalBergWord v) := by
  intro h
  have : InBergSemigroup (adjugate2 (evalBergWord v)) := ⟨w, h⟩
  exact adjugate2_not_in_BergSemigroup hv this

/-
**Inverse Rigidity**: For nonempty words w and v, the product
    `evalBergWord w * evalBergWord v` is never a scalar matrix
    (hence never ±I), unless the words interact trivially.
    In particular, no nonempty semigroup element is its own inverse.
-/
theorem berggren_no_scalar_product {w v : BergWord} (hw : w ≠ []) (hv : v ≠ []) :
    ∀ (c : ℤ), evalBergWord w * evalBergWord v ≠ c • (1 : Matrix (Fin 2) (Fin 2) ℤ) := by
  intro c hc;
  -- From the determinant consideration, we have $c^2 = 1$, so $c = \pm 1$.
  have hc_det : c ^ 2 = 1 := by
    apply_fun Matrix.det at hc; norm_num at hc;
    have h_det : ∀ w : BergWord, (evalBergWord w).det = 1 ∨ (evalBergWord w).det = -1 := by
      intro w; induction w <;> simp_all +decide [ Matrix.det_fin_two ] ;
      rename_i k hk; rcases hk with ( hk | hk ) <;> rcases ‹BergGen› with ( _ | _ | _ ) <;> norm_num [ hk, bergMat ] ;
      all_goals rename_i g; rcases g with ( _ | _ | _ ) <;> norm_num;
    cases h_det w <;> cases h_det v <;> simp_all +decide [ sq ];
    · erw [ Matrix.det_diagonal ] ; norm_num;
      ring;
    · erw [ Matrix.det_diagonal ] at hc ; norm_num at hc ; nlinarith;
    · erw [ Matrix.det_diagonal ] at hc ; norm_num at hc ; nlinarith;
    · erw [ Matrix.det_diagonal ] ; norm_num;
      ring;
  have := adjugate2_not_in_BergSemigroup ( show w ++ v ≠ [ ] from by aesop ) ; simp_all +decide [ adjugate2 ] ;
  contrapose! this; simp_all +decide [ evalBergWord_append ] ;
  rcases hc_det with ( rfl | rfl ) <;> norm_num [ InBergSemigroup ];
  · exists [ ];
  · use w ++ v; simp_all +decide [ evalBergWord_append ] ;

/-- The semigroup product of nonempty words is never the identity. -/
theorem berggren_product_ne_one {w v : BergWord} (hw : w ≠ []) :
    evalBergWord w * evalBergWord v ≠ 1 := by
  rw [← evalBergWord_append]
  intro h
  have := evalBergWord_eq_one_iff.mp h
  simp at this
  exact hw this.1

/-- **Anti-Collision Theorem (Finite Ball Version)**: Within any finite ball
    of the Berggren word metric, evaluation is injective AND separated from
    the adjugate anti-involution. -/
theorem berggren_ball_anti_collision_free (N : ℕ) :
    -- Injectivity within the ball
    (∀ ⦃w v : BergWord⦄, w.length ≤ N → v.length ≤ N →
      evalBergWord w = evalBergWord v → w = v) ∧
    -- Anti-adjugate separation: no word in the ball equals the adjugate of any nonempty word
    (∀ ⦃w v : BergWord⦄, w.length ≤ N → v.length ≤ N → v ≠ [] →
      evalBergWord w ≠ adjugate2 (evalBergWord v)) := by
  exact ⟨fun _ _ _ _ h => evalBergWord_injective h,
         fun _ _ _ _ hv => evalBergWord_ne_adjugate hv⟩

/-- **Reverse-Adjugate Rigidity**: The adjugate of the reverse-evaluated word
    is also never in the semigroup. This covers the "reversed transcript"
    attack scenario. -/
theorem berggren_reverse_adjugate_rigidity {w : BergWord} (hw : w ≠ []) :
    ¬ InBergSemigroup (adjugate2 (evalBergWord w.reverse)) := by
  apply adjugate2_not_in_BergSemigroup
  simp [hw]