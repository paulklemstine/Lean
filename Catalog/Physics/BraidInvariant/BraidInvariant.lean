import Mathlib

/-!
# Braid Group Invariants and the BraidSignature

We formalize the braid group B_{n+2} via the Artin presentation and develop
a theory of braid invariants. The central novel structure is the **BraidSignature**,
which packages the writhe (algebraic crossing number) and strand permutation into
a combined invariant living in ℤ × S_{n+2}.

## Novel mathematical structure: BraidSignature

The `BraidSignature n` is a product invariant ℤ × S_{n+2}. We prove it is a
well-defined braid invariant and that its two components (writhe and permutation)
are *independent* — neither determines the other — establishing the signature as
a strictly stronger invariant than either component alone.

## Main results

* `writhe_braidEquiv` — The writhe is a braid invariant (abelianization B_n → ℤ)
* `wordPerm_braidEquiv` — The strand permutation is a braid invariant (B_n ↠ S_n)
* `genPerm_braid_relation` — Yang-Baxter equation for adjacent transpositions
* `genPerm_far_commute` — Non-adjacent transpositions commute (Coxeter relation)
* `exists_same_writhe_diff_perm` — Writhe and permutation are independent invariants
-/

namespace BraidInvariant

/-! ## Core Definitions -/

/-- Generator of the braid group B_{n+2}: positive (σ_i) or negative (σ_i⁻¹)
    crossing of strands i and i+1, where i ∈ Fin(n+1). -/
inductive BraidGen (n : ℕ) : Type where
  | pos : Fin (n + 1) → BraidGen n
  | neg : Fin (n + 1) → BraidGen n
  deriving DecidableEq

/-- A braid word: a finite sequence of generators. -/
abbrev BraidWord (n : ℕ) := List (BraidGen n)

/-- Sign of a generator: +1 for positive, −1 for negative crossings. -/
def BraidGen.sign {n : ℕ} : BraidGen n → ℤ
  | .pos _ => 1
  | .neg _ => -1

/-- Strand index of a generator (which pair of adjacent strands cross). -/
def BraidGen.index {n : ℕ} : BraidGen n → Fin (n + 1)
  | .pos i => i
  | .neg i => i

@[simp] lemma BraidGen.sign_pos {n : ℕ} (i : Fin (n + 1)) :
    (BraidGen.pos i : BraidGen n).sign = 1 := rfl
@[simp] lemma BraidGen.sign_neg {n : ℕ} (i : Fin (n + 1)) :
    (BraidGen.neg i : BraidGen n).sign = -1 := rfl
@[simp] lemma BraidGen.index_pos {n : ℕ} (i : Fin (n + 1)) :
    (BraidGen.pos i : BraidGen n).index = i := rfl
@[simp] lemma BraidGen.index_neg {n : ℕ} (i : Fin (n + 1)) :
    (BraidGen.neg i : BraidGen n).index = i := rfl

/-! ## Writhe (Algebraic Crossing Number) -/

/-- The writhe of a braid word: sum of signs of all crossings.
    This is the abelianization map B_n → ℤ. -/
def writhe {n : ℕ} (w : BraidWord n) : ℤ :=
  (w.map BraidGen.sign).sum

/-! ## Strand Permutation -/

/-- Transposition of adjacent strands i and i+1 in S_{n+2}. -/
def genPerm {n : ℕ} (i : Fin (n + 1)) : Equiv.Perm (Fin (n + 2)) :=
  Equiv.swap i.castSucc i.succ

/-- Permutation induced by a braid word. Both σ_i and σ_i⁻¹ induce
    the same transposition (i, i+1). -/
def wordPerm {n : ℕ} : BraidWord n → Equiv.Perm (Fin (n + 2))
  | [] => 1
  | g :: w => genPerm g.index * wordPerm w

/-! ## Braid Relations (Artin Presentation) -/

/-- One-step rewriting rules for B_{n+2}: cancellation (σ_i σ_i⁻¹ = 1),
    the braid/Yang-Baxter relation (σ_i σ_{i+1} σ_i = σ_{i+1} σ_i σ_{i+1}),
    and far commutativity (σ_i σ_j = σ_j σ_i for |i−j| ≥ 2). -/
inductive BraidRelStep (n : ℕ) : BraidWord n → BraidWord n → Prop where
  | cancel (pfx sfx : BraidWord n) (i : Fin (n + 1)) :
      BraidRelStep n (pfx ++ [.pos i, .neg i] ++ sfx) (pfx ++ sfx)
  | cancel' (pfx sfx : BraidWord n) (i : Fin (n + 1)) :
      BraidRelStep n (pfx ++ [.neg i, .pos i] ++ sfx) (pfx ++ sfx)
  | braid (pfx sfx : BraidWord n) (i j : Fin (n + 1))
      (h : i.val + 1 = j.val) :
      BraidRelStep n
        (pfx ++ [.pos i, .pos j, .pos i] ++ sfx)
        (pfx ++ [.pos j, .pos i, .pos j] ++ sfx)
  | far_comm (pfx sfx : BraidWord n) (i j : Fin (n + 1))
      (h : i.val + 2 ≤ j.val) :
      BraidRelStep n
        (pfx ++ [.pos i, .pos j] ++ sfx)
        (pfx ++ [.pos j, .pos i] ++ sfx)

/-- Braid equivalence: the equivalence closure of Artin relations.
    Two words are equivalent iff they represent the same element of B_{n+2}. -/
def BraidEquiv (n : ℕ) (w₁ w₂ : BraidWord n) : Prop :=
  Relation.EqvGen (BraidRelStep n) w₁ w₂

/-! ## Writhe Invariance -/

/-
!-- PEGB for writhe_braidEquiv:
P: Case-split on BraidRelStep; each case preserves sign-sum. Extend by EqvGen induction.
E: Trefoil [σ₁,σ₁,σ₁] has writhe 3; figure-eight [σ₁,σ₂⁻¹,σ₁,σ₂⁻¹] has writhe 0.
G: Generalizes to any group homomorphism from B_n to an abelian group.
B: Writhe alone cannot distinguish σ₁ from σ₂ (both writhe 1). Not a complete invariant.
!--
-/
lemma writhe_append {n : ℕ} (w₁ w₂ : BraidWord n) :
    writhe (w₁ ++ w₂) = writhe w₁ + writhe w₂ := by
  -- By definition of writhe, we can expand the sum of the signs of the generators in the concatenated list.
  simp [writhe, List.map_append, List.sum_append]

lemma writhe_relStep {n : ℕ} {w₁ w₂ : BraidWord n} (h : BraidRelStep n w₁ w₂) :
    writhe w₁ = writhe w₂ := by
  obtain h|h|h|h := h;
  · unfold writhe;
    simp +decide [ BraidGen.sign ];
  · unfold writhe; simp +decide [ List.map_append ] ;
  · unfold writhe; aesop;
  · unfold writhe; simp +decide ;

/-
**Theorem 1**: The writhe (algebraic crossing number) is invariant under
    braid equivalence. This realizes the abelianization homomorphism B_n → ℤ.
-/
theorem writhe_braidEquiv {n : ℕ} {w₁ w₂ : BraidWord n} (h : BraidEquiv n w₁ w₂) :
    writhe w₁ = writhe w₂ := by
  induction h;
  · grind +suggestions;
  · rfl;
  · lia;
  · linarith

/-! ## Yang-Baxter and Commutativity for Transpositions -/

/-
!-- PEGB for genPerm_braid_relation:
P: By ext; case split x = a, b, c, or other for a = i.castSucc, b = i.succ, c = j.succ.
E: In S₄, swap(0,1)·swap(1,2)·swap(0,1) = swap(1,2)·swap(0,1)·swap(1,2) = (0 2).
G: This is the type A Coxeter relation; generalizes to Coxeter groups of all types.
B: Non-adjacent transpositions fail this — they commute instead (Theorem 3).
!--

Adjacent transpositions are self-inverse.
-/
lemma genPerm_mul_self {n : ℕ} (i : Fin (n + 1)) :
    genPerm i * genPerm i = 1 := by
  exact Equiv.swap_mul_self _ _

/-
**Theorem 2**: Adjacent transpositions satisfy the Yang-Baxter (braid) relation:
    (i,i+1)(i+1,i+2)(i,i+1) = (i+1,i+2)(i,i+1)(i+1,i+2).
    This is the fundamental relation of the symmetric group presentation.
-/
theorem genPerm_braid_relation {n : ℕ} (i j : Fin (n + 1))
    (h : i.val + 1 = j.val) :
    genPerm i * genPerm j * genPerm i = genPerm j * genPerm i * genPerm j := by
  ext x;
  simp +decide [ genPerm, Equiv.swap_apply_def ];
  grind

/-
!-- PEGB for genPerm_far_commute:
P: Show the four Fin values are distinct when |i−j| ≥ 2, then use Equiv.swap commutativity.
E: In S₅, swap(0,1) and swap(2,3) commute.
G: Disjoint permutations commute (general symmetric group fact).
B: When |i−j| = 1, transpositions do NOT commute; they satisfy the braid relation instead.
!--

**Theorem 3**: Non-adjacent transpositions commute:
    (i,i+1)(j,j+1) = (j,j+1)(i,i+1) when j ≥ i+2.
-/
theorem genPerm_far_commute {n : ℕ} (i j : Fin (n + 1))
    (h : i.val + 2 ≤ j.val) :
    genPerm i * genPerm j = genPerm j * genPerm i := by
  -- By definition of swap, we can expand both sides.
  ext x
  simp [genPerm];
  grind

/-! ## Permutation Invariance -/

/-
!-- PEGB for wordPerm_braidEquiv:
P: Show each BraidRelStep preserves wordPerm (using genPerm lemmas), then EqvGen induction.
E: σ₁σ₂σ₁ and σ₂σ₁σ₂ both give cycle (0 2) in S₃.
G: The permutation map is a surjective group homomorphism B_n ↠ S_n.
B: Not injective: σ₁² and id have the same permutation but are different braids.
!--
-/
lemma wordPerm_append {n : ℕ} (w₁ w₂ : BraidWord n) :
    wordPerm (w₁ ++ w₂) = wordPerm w₁ * wordPerm w₂ := by
  induction w₁ <;> simp +decide [ *, wordPerm ];
  rw [ mul_assoc ]

lemma wordPerm_relStep {n : ℕ} {w₁ w₂ : BraidWord n} (h : BraidRelStep n w₁ w₂) :
    wordPerm w₁ = wordPerm w₂ := by
  rcases h with ( ⟨ pfx, sfx, i ⟩ | ⟨ pfx, sfx, i ⟩ | ⟨ pfx, sfx, i, j, h ⟩ | ⟨ pfx, sfx, i, j, h ⟩ ) <;> simp_all +decide [ wordPerm_append ];
  · simp +decide [ wordPerm ];
    simp +decide [ ← mul_assoc, genPerm_mul_self ];
  · -- By definition of wordPerm, we have:
    have h_wordPerm_neg_pos : wordPerm (BraidGen.neg i :: BraidGen.pos i :: sfx) = genPerm i * genPerm i * wordPerm sfx := by
      rfl;
    rw [ h_wordPerm_neg_pos, genPerm_mul_self, one_mul ];
  · convert congr_arg ( fun x : Equiv.Perm ( Fin ( n + 2 ) ) => x * wordPerm sfx ) ( genPerm_braid_relation i j h ) using 1;
  · convert congr_arg ( fun x : Equiv.Perm ( Fin ( n + 2 ) ) => x * wordPerm sfx ) ( genPerm_far_commute i j h ) using 1

/-
**Theorem 4**: The strand permutation is invariant under braid equivalence.
    This realizes the canonical surjection B_n ↠ S_n.
-/
theorem wordPerm_braidEquiv {n : ℕ} {w₁ w₂ : BraidWord n} (h : BraidEquiv n w₁ w₂) :
    wordPerm w₁ = wordPerm w₂ := by
  induction h;
  · rename_i x y h;
    exact wordPerm_relStep h;
  · rfl;
  · aesop;
  · grind

/-! ## Novel Structure: BraidSignature -/

/-- The **BraidSignature**: a combined algebraic invariant packaging writhe and
    permutation. It lives in ℤ × S_{n+2} and detects strictly more braid
    inequivalences than either component alone (Theorems 5a/5b). -/
structure BraidSignature (n : ℕ) where
  w : ℤ
  p : Equiv.Perm (Fin (n + 2))

instance {n : ℕ} : DecidableEq (BraidSignature n) := by
  intro a b
  cases a; cases b
  simp [BraidSignature.mk.injEq]
  exact instDecidableAnd

/-- Compute the signature of a braid word. -/
def braidSignature {n : ℕ} (word : BraidWord n) : BraidSignature n where
  w := writhe word
  p := wordPerm word

/-
The BraidSignature is a braid invariant: equivalent braids have equal signatures.
-/
theorem braidSignature_braidEquiv {n : ℕ} {w₁ w₂ : BraidWord n}
    (h : BraidEquiv n w₁ w₂) : braidSignature w₁ = braidSignature w₂ := by
  have := writhe_braidEquiv h;
  exact congr_arg₂ _ this ( wordPerm_braidEquiv h )

/-! ## Independence of Invariants -/

/-
!-- PEGB for independence:
P: Exhibit explicit witnesses in B₄ (n=2, 4 strands).
E: [σ₁] vs [σ₂] have same writhe 1 but swap(0,1) ≠ swap(1,2).
G: For n ≥ 2, writhe × perm is a proper subquotient of the full braid invariant.
B: For B₂ (n=0, one generator), writhe mod 2 determines the permutation completely.
!--

**Theorem 5a**: Writhe does not determine permutation:
    [σ₁] and [σ₂] in B₄ have writhe 1 but distinct permutations.
-/
theorem exists_same_writhe_diff_perm :
    ∃ (w₁ w₂ : BraidWord 2),
      writhe w₁ = writhe w₂ ∧ wordPerm w₁ ≠ wordPerm w₂ := by
  exists [ BraidGen.pos 0 ], [ BraidGen.pos 1 ]

/-
**Theorem 5b**: Permutation does not determine writhe:
    [σ₁,σ₁] and [] in B₄ have the same permutation (id) but writhes 2 ≠ 0.
-/
theorem exists_same_perm_diff_writhe :
    ∃ (w₁ w₂ : BraidWord 2),
      wordPerm w₁ = wordPerm w₂ ∧ writhe w₁ ≠ writhe w₂ := by
  exists [ BraidGen.pos 0, BraidGen.pos 0 ], [ ]

/-! ## Concrete Examples -/

/-- The trivial braid (identity element of B_{n+2}). -/
def trivialBraid (n : ℕ) : BraidWord n := []

/-- The trefoil braid σ₁³ in B₃ (closure gives the trefoil knot). -/
def trefoilBraid : BraidWord 1 := [.pos 0, .pos 0, .pos 0]

/-- The figure-eight knot braid σ₁σ₂⁻¹σ₁σ₂⁻¹ in B₄. -/
def figureEightBraid : BraidWord 2 := [.pos 0, .neg 1, .pos 0, .neg 1]

theorem writhe_trivial (n : ℕ) : writhe (trivialBraid n) = 0 := by
  simp [trivialBraid, writhe]

theorem writhe_trefoil : writhe trefoilBraid = 3 := by
  rfl

theorem writhe_figureEight : writhe figureEightBraid = 0 := by
  decide +kernel

theorem wordPerm_trivial (n : ℕ) : wordPerm (trivialBraid n) = 1 := by
  simp [trivialBraid, wordPerm]

/-! ## Falsifiable Conjecture

**Conjecture (Braid Complexity Gap)**: For every n ≥ 3, there exist braid words
w₁, w₂ ∈ B_n with identical BraidSignatures but which are not braid-equivalent.
Equivalently, the BraidSignature is not a complete invariant for n ≥ 3.

*Computational test*: In B₄, search for distinct braid words of length ≤ 8
with the same (writhe, permutation) pair and verify they are inequivalent
by checking their Burau matrices disagree.
-/

end BraidInvariant