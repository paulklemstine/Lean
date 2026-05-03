import Mathlib
import Cryptography.BerggrenSL2.MatRed

/-!
# Berggren Words and Semigroup Evaluation

We define a type `BergWord` representing words in two generators `A, B`
of a Berggren-type semigroup, together with an evaluation function into
2×2 matrices over any ring, and the functoriality of reduction mod `p`.

This provides the bridge from the Berggren tree structure to the
matrix-level DH protocol: each tree path corresponds to a `BergWord`,
and reduction mod `p` transports it faithfully to `SL₂(𝔽_p)`.
-/

open Matrix

/-! ## Word Type -/

/-- A word in the free semigroup on two generators A and B,
representing a path in a binary Berggren-type tree. -/
inductive BergWord : Type
  | one : BergWord
  | mulA : BergWord → BergWord
  | mulB : BergWord → BergWord
  deriving Repr, DecidableEq

/-! ## Evaluation -/

/-- Evaluate a `BergWord` in two generator matrices over any semiring.
`one` maps to the identity, `mulA w` maps to `A * eval w`,
`mulB w` maps to `B * eval w`. -/
def BergWord.eval {R : Type*} [Semiring R]
    (A B : Matrix (Fin 2) (Fin 2) R) : BergWord → Matrix (Fin 2) (Fin 2) R
  | .one => 1
  | .mulA w => A * w.eval A B
  | .mulB w => B * w.eval A B

/-- The length (number of generator applications) in a BergWord. -/
def BergWord.length : BergWord → ℕ
  | .one => 0
  | .mulA w => w.length + 1
  | .mulB w => w.length + 1

/-! ## Functoriality of Reduction -/

/-
Reduction mod `p` commutes with BergWord evaluation.
This is the bridge from Berggren-word public parameters to
matrix-level DH over `𝔽_p`.
-/
theorem bergWord_eval_matRed
    {p : ℕ}
    (A B : Matrix (Fin 2) (Fin 2) ℤ)
    (w : BergWord) :
    matRed p (w.eval A B) =
      w.eval (matRed p A) (matRed p B) := by
  induction' w with w ih;
  · exact map_one _;
  · erw [ show BergWord.eval A B w.mulA = A * BergWord.eval A B w from rfl, show BergWord.eval ( matRed p A ) ( matRed p B ) w.mulA = matRed p A * BergWord.eval ( matRed p A ) ( matRed p B ) w from rfl ];
    rw [ ← ih, matRed_mul ];
  · simp_all +decide [ BergWord.eval ]

/-! ## Powers as Special Words -/

/-- A word consisting of `n` applications of generator A. -/
def BergWord.powA : ℕ → BergWord
  | 0 => .one
  | n + 1 => .mulA (BergWord.powA n)

/-
Evaluating `powA n` gives `A^n`.
-/
theorem bergWord_powA_eval {R : Type*} [Semiring R]
    (A B : Matrix (Fin 2) (Fin 2) R) (n : ℕ) :
    (BergWord.powA n).eval A B = A ^ n := by
  -- We'll use induction on $n$.
  induction' n with n ih;
  · rfl;
  · rw [ pow_succ' ];
    exact ih ▸ rfl

/-- If a BergWord evaluates to a power of `A`, then its reduction mod `p`
is the corresponding power of the reduced generator. -/
theorem bergWord_power_to_dh
    {p : ℕ} [Fact p.Prime]
    (A B : Matrix (Fin 2) (Fin 2) ℤ) (n : ℕ) :
    matRed p ((BergWord.powA n).eval A B) = (matRed p A) ^ n := by
  rw [bergWord_eval_matRed, bergWord_powA_eval]