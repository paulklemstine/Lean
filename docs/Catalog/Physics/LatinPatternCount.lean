import Mathlib

/-!
# Counting Latin squares realizing a one-row partial pattern

This file proves a self-contained finite counting theorem for Latin squares of order `n`
that realize a prescribed *one-row partial pattern*.

A Latin square is recorded as a function `M : Fin n → Fin n → Fin n` whose every row and
every column is injective (`IsLatin`).  Fixing a row `r` and a set of columns `C ⊆ Fin n`,
the *pattern* of `M` is the embedding `rowEmb r C M : C ↪ Fin n` reading row `r` of `M` on
the columns in `C` (it is an embedding precisely because rows are injective).

The main result, `latin_pattern_count_mul`, states the cardinal identity

`Fintype.card (LatinSet n)
   = Fintype.card (C ↪ Fin n) * Fintype.card {M : LatinSet n // rowEmb r C M = e}`,

i.e. every pattern is realized by the *same* number of Latin squares.  The proof partitions
`LatinSet n` into the fibers of `rowEmb r C` and shows all fibers are equinumerous; the
equinumerosity comes from an explicit bijection induced by relabelling symbols with a
permutation extending one pattern to another (`fiber_equiv`), not from any uniformity
assumption.  In particular the counting theorem is **not** used to prove itself.
-/

open Equiv Function

namespace LatinPatternCount

variable {n : ℕ}

/-- A function `M : Fin n → Fin n → Fin n` is *Latin* if every row and every column is
injective. -/
def IsLatin (M : Fin n → Fin n → Fin n) : Prop :=
  (∀ i, Function.Injective (M i)) ∧ (∀ j, Function.Injective fun i => M i j)

/-- The type of Latin squares of order `n`. -/
def LatinSet (n : ℕ) : Type := {M : Fin n → Fin n → Fin n // IsLatin M}

namespace LatinSet

/-- Relabelling the symbols of a Latin square by a permutation keeps it Latin. -/
theorem smul_isLatin (σ : Equiv.Perm (Fin n)) (M : LatinSet n) :
    IsLatin (fun i j => σ (M.val i j)) := by
  refine ⟨fun i a b h => ?_, fun j a b h => ?_⟩
  · exact M.prop.1 i (σ.injective h)
  · exact M.prop.2 j (σ.injective h)

/-- Symbol relabelling: `(σ • M) i j = σ (M i j)`. -/
instance : SMul (Equiv.Perm (Fin n)) (LatinSet n) where
  smul σ M := ⟨fun i j => σ (M.val i j), smul_isLatin σ M⟩

@[simp] theorem smul_val (σ : Equiv.Perm (Fin n)) (M : LatinSet n) (i j : Fin n) :
    (σ • M).val i j = σ (M.val i j) := rfl

/-- The identity permutation acts trivially. -/
theorem one_smul_latin (M : LatinSet n) : (1 : Equiv.Perm (Fin n)) • M = M := by
  apply Subtype.ext; funext i j; simp

/-- Symbol relabelling is compatible with composition of permutations. -/
theorem mul_smul_latin (σ τ : Equiv.Perm (Fin n)) (M : LatinSet n) :
    (σ * τ) • M = σ • τ • M := by
  apply Subtype.ext; funext i j; simp [Equiv.Perm.mul_apply]

/-- Symbol relabelling is a lawful `Equiv.Perm (Fin n)`-action on `LatinSet n`. -/
instance : MulAction (Equiv.Perm (Fin n)) (LatinSet n) where
  one_smul := one_smul_latin
  mul_smul := mul_smul_latin

instance : Finite (LatinSet n) := by unfold LatinSet; infer_instance

noncomputable instance : Fintype (LatinSet n) := Fintype.ofFinite _

end LatinSet

open LatinSet

/-- The one-row pattern of `M`: reading row `r` of `M` on the columns in `C`.  This is an
embedding because the rows of a Latin square are injective. -/
def rowEmb (r : Fin n) (C : Set (Fin n)) (M : LatinSet n) : C ↪ Fin n where
  toFun c := M.val r c.1
  inj' _ _ h := Subtype.ext (M.prop.1 r h)

@[simp] theorem rowEmb_apply (r : Fin n) (C : Set (Fin n)) (M : LatinSet n) (c : C) :
    rowEmb r C M c = M.val r c.1 := rfl

noncomputable instance instFintypeEmb (C : Set (Fin n)) : Fintype (C ↪ Fin n) :=
  Fintype.ofFinite _

noncomputable instance instFintypeFiber (r : Fin n) (C : Set (Fin n)) (e : C ↪ Fin n) :
    Fintype {M : LatinSet n // rowEmb r C M = e} := Fintype.ofFinite _

/-- Relabelling symbols transforms the pattern by post-composition with the permutation. -/
theorem rowEmb_smul (r : Fin n) (C : Set (Fin n)) (σ : Equiv.Perm (Fin n)) (M : LatinSet n) :
    rowEmb r C (σ • M) = (rowEmb r C M).trans σ.toEmbedding := by
  ext c; rfl

/-- Any two embeddings of `C` into `Fin n` are related by a permutation of `Fin n`:
there is a `σ` with `σ (e₁ c) = e₂ c` for all `c`.  This is the finite extension of an
injection between subsets to a permutation of the ambient finite type; its proof does not
use the Latin pattern counting theorem. -/
theorem exists_perm_comp (C : Set (Fin n)) (e₁ e₂ : C ↪ Fin n) :
    ∃ σ : Equiv.Perm (Fin n), ∀ c : C, σ (e₁ c) = e₂ c := by
  -- `g : ↥(Set.range e₁) ≃ ↥(Set.range e₂)` carries `⟨e₁ c, _⟩` to `e₂ c`.
  let g := (e₁.toEquivRange).symm.trans e₂.toEquivRange
  have hg : ∀ c : C, g ⟨e₁ c, Set.mem_range_self _⟩ = e₂.toEquivRange c := by
    aesop
  generalize_proofs at *
  -- Extend `g` to a permutation of `Fin n` using `Equiv.extendSubtype`.
  refine ⟨Equiv.extendSubtype g, fun c => ?_⟩
  specialize hg c
  have := Equiv.extendSubtype_apply_of_mem g (e₁ c) (by aesop)
  aesop

/-- The bijection between the fiber of `rowEmb r C` over `e₁` and the fiber over `e₂`,
induced by relabelling symbols with a permutation `σ` that carries `e₁` to `e₂`. -/
def fiber_equiv (r : Fin n) (C : Set (Fin n)) (e₁ e₂ : C ↪ Fin n)
    (σ : Equiv.Perm (Fin n)) (hσ : ∀ c : C, σ (e₁ c) = e₂ c) :
    {M : LatinSet n // rowEmb r C M = e₁} ≃ {M : LatinSet n // rowEmb r C M = e₂} where
  toFun M := ⟨σ • M.1, by rw [rowEmb_smul, M.2]; ext c; simp [hσ c]⟩
  invFun M := ⟨σ.symm • M.1, by rw [rowEmb_smul, M.2]; ext c; simp [← hσ c]⟩
  left_inv M := by
    apply Subtype.ext
    show σ.symm • σ • M.1 = M.1
    rw [← LatinSet.mul_smul_latin, show σ.symm * σ = 1 by ext x; simp, LatinSet.one_smul_latin]
  right_inv M := by
    apply Subtype.ext
    show σ • σ.symm • M.1 = M.1
    rw [← LatinSet.mul_smul_latin, show σ * σ.symm = 1 by ext x; simp, LatinSet.one_smul_latin]

/-- All fibers of `rowEmb r C` over embeddings `C ↪ Fin n` have equal cardinality. -/
theorem fiber_card_eq (r : Fin n) (C : Set (Fin n)) (e₁ e₂ : C ↪ Fin n) :
    Fintype.card {M : LatinSet n // rowEmb r C M = e₁}
      = Fintype.card {M : LatinSet n // rowEmb r C M = e₂} := by
  obtain ⟨σ, hσ⟩ := exists_perm_comp C e₁ e₂
  exact Fintype.card_congr (fiber_equiv r C e₁ e₂ σ hσ)

/-- **Latin pattern counting (multiplicative form).**  The number of Latin squares of order
`n` equals the number of one-row patterns `C ↪ Fin n` times the number of Latin squares
realizing any fixed pattern `e`.  Proved by summing the cardinalities of the fibers of
`rowEmb r C` and using `fiber_card_eq`; it does not assume the formula it proves. -/
theorem latin_pattern_count_mul (r : Fin n) (C : Set (Fin n)) (e : C ↪ Fin n) :
    Fintype.card (LatinSet n)
      = Fintype.card (C ↪ Fin n) * Fintype.card {M : LatinSet n // rowEmb r C M = e} := by
  rw [← Fintype.card_congr (Equiv.sigmaFiberEquiv (rowEmb r C))]
  rw [Fintype.card_sigma]
  rw [Finset.sum_congr rfl (fun e' _ => fiber_card_eq r C e' e)]
  rw [Finset.sum_const, Finset.card_univ, smul_eq_mul]

/-- **Probability corollary.**  Under the (necessary and sufficient) hypothesis that Latin
squares of order `n` exist, the proportion of Latin squares realizing a fixed pattern `e`
is `1 / Fintype.card (C ↪ Fin n)`. -/
theorem latin_pattern_prob (r : Fin n) (C : Set (Fin n)) (e : C ↪ Fin n)
    (hL : Fintype.card (LatinSet n) ≠ 0) :
    (Fintype.card {M : LatinSet n // rowEmb r C M = e} : ℚ) / Fintype.card (LatinSet n)
      = 1 / Fintype.card (C ↪ Fin n) := by
  have := @latin_pattern_count_mul n r C e
  rw [div_eq_div_iff] <;> norm_cast <;> nlinarith [Nat.pos_of_ne_zero hL]

end LatinPatternCount