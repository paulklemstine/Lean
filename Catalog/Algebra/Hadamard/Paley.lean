/-
  # Skew Conference Matrices and the Paley Construction Core

  This file formalizes the algebraic heart of the **Paley I construction** for
  Hadamard matrices: the order-preserving passage between *skew conference
  matrices* and *skew-Hadamard matrices*.

  A skew conference matrix `C` of order `n` has zero diagonal, ±1 off-diagonal
  entries, satisfies `Cᵀ = -C`, and the conference identity `C Cᵀ = (n-1) I`.
  The Jacobsthal (quadratic residue) matrix over `GF(q)` for `q ≡ 3 (mod 4)` is
  the canonical example; this file isolates the construction step that turns such
  a `C` into a genuine Hadamard matrix `I + C`, *without* yet building the
  quadratic-residue matrix itself.

  Main results:
  * `skewConference_mulSelf`                  — `C * C = (1 - n) • I`  (algebraic core)
  * `skewConference_add_one_isSkewHadamard`   — `I + C` is skew-Hadamard
  * `skewConference_hadamardOrder`            — a skew conference matrix of order
                                                `n` yields a Hadamard order `n`
  * `isSkewHadamard_sub_one_skewConference`   — the converse: `H - I` recovers a
                                                skew conference matrix

  These extend the catalog's Hadamard development (`IsHadamard'`,
  `HadamardOrder'`, `hadamardOrder'_mul`, the Sylvester family in
  `Algebra/Hadamard/Constructions.lean`) by adding the first construction
  yielding orders that are NOT forced to be powers of two: skew conference
  matrices exist e.g. for every `n = q + 1` with `q ≡ 3 (mod 4)` prime power.

  All predicates are redefined self-containedly (matching the catalog's
  `IsHadamard'` verbatim) so the file compiles against `import Mathlib` alone,
  consistent with every other file in `Algebra/Hadamard/`.
-/
import Mathlib

open Matrix Finset BigOperators

/-! ## Core predicates (self-contained; `IsHadamardP` matches catalog `IsHadamard'`) -/

/-- A matrix is Hadamard if all entries are ±1 and `H * Hᵀ = n • I`.
    Identical to the catalog's `IsHadamard'` / `IsHadamard`. -/
def IsHadamardP {n : ℕ} (H : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  (∀ i j, H i j = 1 ∨ H i j = -1) ∧
  H * H.transpose = (n : ℤ) • (1 : Matrix (Fin n) (Fin n) ℤ)

/-- An order `n` admits a Hadamard matrix (matches catalog `HadamardOrder'`). -/
def HadamardOrderP (n : ℕ) : Prop :=
  ∃ H : Matrix (Fin n) (Fin n) ℤ, IsHadamardP H

/-- A **skew conference matrix** of order `n`: zero diagonal, ±1 off the
    diagonal, antisymmetric (`Cᵀ = -C`), and satisfying the conference identity
    `C Cᵀ = (n - 1) • I`. -/
def IsSkewConference {n : ℕ} (C : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  (∀ i, C i i = 0) ∧
  (∀ i j, i ≠ j → C i j = 1 ∨ C i j = -1) ∧
  C.transpose = -C ∧
  C * C.transpose = ((n : ℤ) - 1) • (1 : Matrix (Fin n) (Fin n) ℤ)

/-- A **skew-Hadamard matrix**: a Hadamard matrix `H` whose "skew part" is
    trivial, i.e. `H + Hᵀ = 2 • I`. Equivalently `H - I` is antisymmetric. -/
def IsSkewHadamardP {n : ℕ} (H : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  IsHadamardP H ∧ H + H.transpose = (2 : ℤ) • (1 : Matrix (Fin n) (Fin n) ℤ)

/-! ## Algebraic core -/

-- !-- Lab Notebook: skewConference_mulSelf -- !--
-- !-- Hypothesis: antisymmetry + the conference identity should pin down C*C exactly -- !--
-- !-- Result: C*C = (1-n)•I, obtained by substituting Cᵀ = -C into C*Cᵀ = (n-1)•I -- !--
-- !-- Insight: this single identity is the engine; everything downstream is bookkeeping -- !--
-- !-- Failure analysis: stating it with (1-n) rather than -(n-1) avoids smul_neg friction -- !--
-- !-- End Lab Notebook -- !--

-- !-- Sketch: from Cᵀ = -C, C*Cᵀ = C*(-C) = -(C*C); equate with (n-1)•I and negate. -- !--
/-- The defining square of a skew conference matrix: `C * C = (1 - n) • I`. -/
theorem skewConference_mulSelf {n : ℕ} {C : Matrix (Fin n) (Fin n) ℤ}
    (hC : IsSkewConference C) :
    C * C = ((1 : ℤ) - n) • (1 : Matrix (Fin n) (Fin n) ℤ) := by
  convert congr_arg Neg.neg hC.2.2.2 using 1 <;> norm_num [ mul_neg, neg_mul ];
  rw [ hC.2.2.1, Matrix.mul_neg, neg_neg ]

/-! ## Forward construction: skew conference ⟹ skew-Hadamard -/

-- !-- Lab Notebook: skewConference_add_one_isSkewHadamard -- !--
-- !-- Hypothesis: I + C is Hadamard of the same order n (the Paley I core step) -- !--
-- !-- Result: (I+C)(I+C)ᵀ = (I+C)(I-C) = I - C*C = I + (n-1)I = nI; diagonal entries are 1 -- !--
-- !-- Insight: skewness makes the cross terms -C + C cancel, leaving only I - C*C -- !--
-- !-- Failure analysis: entries are ±1 even on the diagonal (1+0=1), so no order hypothesis is needed -- !--
-- !-- End Lab Notebook -- !--

-- !-- Sketch: diagonal of I+C is 1 (=1), off-diagonal is C i j (=±1); product collapses via skewConference_mulSelf. -- !--
/-- **Paley I core (forward).** If `C` is a skew conference matrix of order `n`,
    then `I + C` is a skew-Hadamard matrix of order `n`. -/
theorem skewConference_add_one_isSkewHadamard {n : ℕ}
    {C : Matrix (Fin n) (Fin n) ℤ} (hC : IsSkewConference C) :
    IsSkewHadamardP (1 + C) := by
  constructor;
  · constructor;
    · intro i j; by_cases hij : i = j <;> simp_all +decide [ IsSkewConference ] ;
    · obtain ⟨ h₁, h₂, h₃, h₄ ⟩ := hC;
      simp_all +decide [ Matrix.add_mul, Matrix.mul_add ];
      abel1;
  · simp_all +decide [ IsSkewConference, two_smul ];
    abel1

-- !-- Sketch: forgetting the skew refinement gives a plain Hadamard matrix. -- !--
/-- A skew conference matrix of order `n` yields a Hadamard matrix of order `n`. -/
theorem skewConference_isHadamard {n : ℕ}
    {C : Matrix (Fin n) (Fin n) ℤ} (hC : IsSkewConference C) :
    IsHadamardP (1 + C) :=
  (skewConference_add_one_isSkewHadamard hC).1

-- !-- Lab Notebook: skewConference_hadamardOrder -- !--
-- !-- Hypothesis: existence of a skew conference matrix forces the Hadamard order -- !--
-- !-- Result: immediate from the forward construction by exhibiting 1 + C -- !--
-- !-- Insight: this is the bridge to non-power-of-two orders (n = q+1, q ≡ 3 mod 4) -- !--
-- !-- Failure analysis: none; pure existential introduction over skewConference_isHadamard -- !--
-- !-- End Lab Notebook -- !--

/-- **Existence corollary.** If a skew conference matrix of order `n` exists,
    then `n` is a Hadamard order. -/
theorem skewConference_hadamardOrder {n : ℕ}
    (h : ∃ C : Matrix (Fin n) (Fin n) ℤ, IsSkewConference C) :
    HadamardOrderP n := by
  exact ⟨ _, skewConference_isHadamard h.choose_spec ⟩

/-! ## Converse: skew-Hadamard ⟹ skew conference -/

-- !-- Lab Notebook: isSkewHadamard_sub_one_skewConference -- !--
-- !-- Hypothesis: subtracting I from a skew-Hadamard matrix recovers a skew conference matrix -- !--
-- !-- Result: C := H - I has zero diagonal (H i i = 1), ±1 off-diagonal, Cᵀ = -C, C Cᵀ = (n-1)I -- !--
-- !-- Insight: the correspondence C ↔ H = I+C is a bijection between the two classes -- !--
-- !-- Failure analysis: H i i = 1 needs H + Hᵀ = 2I read on the diagonal, not Hadamard-ness alone -- !--
-- !-- End Lab Notebook -- !--

-- !-- Sketch: C Cᵀ = (H-I)(Hᵀ-I) = HHᵀ - (H+Hᵀ) + I = nI - 2I + I = (n-1)I. -- !--
/-- **Converse.** If `H` is a skew-Hadamard matrix of order `n`, then `H - I`
    is a skew conference matrix. Together with the forward direction this gives
    a bijective correspondence between skew conference and skew-Hadamard
    matrices of order `n`. -/
theorem isSkewHadamard_sub_one_skewConference {n : ℕ}
    {H : Matrix (Fin n) (Fin n) ℤ} (hH : IsSkewHadamardP H) :
    IsSkewConference (H - 1) := by
  obtain ⟨hH1, hH2⟩ := hH;
  refine' ⟨ _, _, _, _ ⟩;
  · intro i; have := congr_fun ( congr_fun hH2 i ) i; norm_num at *; linarith;
  · intro i j hij; have := hH1.1 i j; aesop;
  · exact eq_of_sub_eq_zero ( by ext i j; have := congr_fun ( congr_fun hH2 i ) j; norm_num at *; linarith );
  · simp_all +decide [ mul_sub, sub_mul ];
    rw [ hH1.2 ] ; abel_nf;
    convert congr_arg ( fun x : Matrix ( Fin n ) ( Fin n ) ℤ => -x + ( n : ℤ ) • 1 + 1 ) hH2 using 1 <;> abel_nf;
    ext i j ; norm_num ; ring;
    erw [ show ( 2 : Matrix ( Fin n ) ( Fin n ) ℤ ) = 2 • 1 by norm_num, Matrix.smul_apply ] ; norm_num ; ring

/-! ## Critique / generalization (conjecture)

  The skew (Paley I) construction is order-preserving and applies exactly when a
  skew conference matrix exists. The *symmetric* (Paley II) case, where `Cᵀ = C`
  and the conference matrix exists for `n ≡ 2 (mod 4)` (e.g. `n = q + 1`,
  `q ≡ 1 (mod 4)`), is genuinely different: `I + C` is no longer Hadamard, and
  one must instead double the order via the block matrix
  `[[C + I, C - I], [C - I, -(C + I)]]`, producing a Hadamard matrix of order
  `2n`. We record this boundary as a conjecture for the next cycle. -/

/-- A **symmetric conference matrix**: zero diagonal, ±1 off-diagonal,
    symmetric, with `C Cᵀ = (n-1) • I`. -/
def IsSymmetricConference {n : ℕ} (C : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  (∀ i, C i i = 0) ∧
  (∀ i j, i ≠ j → C i j = 1 ∨ C i j = -1) ∧
  C.transpose = C ∧
  C * C.transpose = ((n : ℤ) - 1) • (1 : Matrix (Fin n) (Fin n) ℤ)

-- !-- CONJECTURE (boundary case): symmetric conference doubles the order. -- !--
/-- **Conjecture (Paley II doubling).** A symmetric conference matrix of order
    `n` yields a Hadamard matrix of order `2 * n`. Deferred: requires a block
    `fromBlocks` construction over `Fin n ⊕ Fin n` and an order recount; this is
    Research Direction 1 in `FUTURE_DIRECTIONS.md`. -/
theorem symmetricConference_hadamardOrder_two_mul {n : ℕ}
    (h : ∃ C : Matrix (Fin n) (Fin n) ℤ, IsSymmetricConference C) :
    HadamardOrderP (2 * n) := by
  sorry