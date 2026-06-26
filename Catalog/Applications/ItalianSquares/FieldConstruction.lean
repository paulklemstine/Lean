import Applications.ItalianSquares.UpperBound

/-!
# Tightness of the bound: `q - 1` orthogonal Italian squares over a field of order `q`

For a finite field `F` we realize the upper bound `#F - 1` by the classical affine
construction: for each nonzero `a : F` the array `(i, j) ↦ a * i + j` is an Italian
square, and squares for distinct `a` are orthogonal.  As `a` ranges over the `#F - 1`
nonzero field elements we obtain a maximum family of mutually orthogonal Italian
squares.  Specializing `F` to a Galois field `GF(p^k)` yields `n - 1` orthogonal
Italian squares of order `n` for every prime power `n = p^k ≥ 2`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the affine maps `x ↦ a*x + b` of a finite field give a
sharply 2-transitive group; the "slope" `a` parametrizes orthogonal squares.

Experiment (Experimenter): orthogonality of `Sₐ, S_b` reduces to invertibility of
the 2×2 system with matrix `[[a,1],[b,1]]`, i.e. `a ≠ b`. Over a field this is exactly
`(a - b) ≠ 0`, the heart of the construction.

Analysis (Analyst): the bound `#F - 1` is met since the nonzero elements number
`#F - 1`. Hence for prime powers the maximum is attained — the "if" direction of the
problem's claim.

Critique (Critic): the converse ("attained only for prime powers") is equivalent to
the existence question for finite projective planes and is OPEN in general (the only
nonexistence results, e.g. orders 6 and 10, are special). We therefore prove the
prime-power (sufficiency) direction and do NOT assert the converse; see
`FUTURE_DIRECTIONS.md`.
-/

namespace ItalianSquares

open Function

variable {F : Type} [Field F]

/-
Each row `j ↦ a*i + j` of the affine array is a bijection.
-/
lemma affine_row_bij (a i : F) : Bijective (fun j : F => a * i + j) := by
  exact ⟨ add_right_injective _, add_left_surjective _ ⟩

/-
For `a ≠ 0`, each column `i ↦ a*i + j` of the affine array is a bijection.
-/
lemma affine_col_bij {a : F} (ha : a ≠ 0) (j : F) : Bijective (fun i : F => a * i + j) := by
  exact ⟨ fun x y h => mul_left_cancel₀ ha <| by linear_combination' h, fun x => ⟨ ( x - j ) / a, by simp +decide [ mul_div_cancel₀ _ ha ] ⟩ ⟩

/-- The affine Italian square with slope `a ≠ 0`: `(i, j) ↦ a * i + j`. -/
def affineSquare {a : F} (ha : a ≠ 0) : ItalianSquare F where
  toFun i j := a * i + j
  row_bij i := affine_row_bij a i
  col_bij j := affine_col_bij ha j

/-- Affine squares with distinct slopes are orthogonal. -/
lemma affineSquare_orthogonal {a b : F} (ha : a ≠ 0) (hb : b ≠ 0) (hab : a ≠ b) :
    Orthogonal (affineSquare ha) (affineSquare hb) := by
  have hab' : a - b ≠ 0 := sub_ne_zero.mpr hab
  refine ⟨fun x y hxy => ?_, fun u => ?_⟩
  · simp only [affineSquare, Prod.mk.injEq] at hxy
    obtain ⟨h1, h2⟩ := hxy
    have hi : x.1 = y.1 := mul_left_cancel₀ hab' (by linear_combination h1 - h2)
    have hj : x.2 = y.2 := by linear_combination h1 - a * hi
    exact Prod.ext hi hj
  · refine ⟨((u.1 - u.2) / (a - b), u.1 - a * ((u.1 - u.2) / (a - b))), ?_⟩
    simp only [affineSquare]
    refine Prod.ext ?_ ?_
    · ring
    · field_simp
      ring

variable [Fintype F] [DecidableEq F]

/-- **Tightness.** Over a finite field with at least two elements there is a family of
pairwise orthogonal Italian squares whose size equals the upper bound `#F - 1`. -/
theorem exists_mols_card_eq_card_sub_one :
    ∃ (K : Type) (_ : Fintype K) (L : K → ItalianSquare F),
      (∀ s t, s ≠ t → Orthogonal (L s) (L t)) ∧ Fintype.card K = Fintype.card F - 1 := by
  refine ⟨{a : F // a ≠ 0}, inferInstance,
    fun a => affineSquare a.2, ?_, ?_⟩
  · intro s t hst
    exact affineSquare_orthogonal s.2 t.2 (fun h => hst (Subtype.ext h))
  · rw [Fintype.card_subtype_compl]
    simp

/-- Combining tightness with the upper bound: over a finite field with `≥ 2` elements,
the maximum size of a family of pairwise orthogonal Italian squares is exactly `#F - 1`,
and this maximum is achieved. -/
theorem maximum_mols_eq_card_sub_one (hF : 2 ≤ Fintype.card F) :
    (∃ (K : Type) (_ : Fintype K) (L : K → ItalianSquare F),
      (∀ s t, s ≠ t → Orthogonal (L s) (L t)) ∧ Fintype.card K = Fintype.card F - 1) ∧
    (∀ (K : Type) [Fintype K] (L : K → ItalianSquare F),
      (∀ s t, s ≠ t → Orthogonal (L s) (L t)) → Fintype.card K ≤ Fintype.card F - 1) := by
  refine ⟨exists_mols_card_eq_card_sub_one, ?_⟩
  intro K _ L horth
  exact card_le_card_sub_one hF L horth

/-- **Prime-power realization.** For every prime `p` and `k ≥ 1` with `n = p^k ≥ 2`,
there exist `n - 1` pairwise orthogonal Italian squares of order `n` (on the Galois
field `GF(p^k)`). This is the "if" direction of the problem's claim. -/
theorem exists_mols_prime_power (p k : ℕ) [Fact p.Prime] (hk : k ≠ 0) :
    ∃ (K : Type) (_ : Fintype K) (L : K → ItalianSquare (GaloisField p k)),
      (∀ s t, s ≠ t → Orthogonal (L s) (L t)) ∧ Fintype.card K = p ^ k - 1 := by
  haveI : Fintype (GaloisField p k) := Fintype.ofFinite _
  haveI : DecidableEq (GaloisField p k) := Classical.decEq _
  have hcard : Fintype.card (GaloisField p k) = p ^ k := by
    rw [← Nat.card_eq_fintype_card]; exact GaloisField.card p k hk
  obtain ⟨K, hK, L, horth, hsize⟩ :=
    exists_mols_card_eq_card_sub_one (F := GaloisField p k)
  exact ⟨K, hK, L, horth, by rw [hsize, hcard]⟩

end ItalianSquares