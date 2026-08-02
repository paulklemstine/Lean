import Mathlib

/-!
# Algebraic foundations for graded encoding systems

This file isolates the algebraic interface needed by multilinear Diffie--Hellman
reductions. It builds on Mathlib's `CommMonoid`; no new group operation is
introduced. Levels are tracked by the type of each encoding.
-/

open scoped BigOperators

namespace Cryptography.GradedEncoding

universe u v

/-- A graded encoding system over an existing commutative monoid. Multiplication
adds levels and agrees with multiplication of plaintexts on canonical encodings. -/
structure System (R : Type u) [CommMonoid R] where
  Code : ℕ → Type v
  encode : (level : ℕ) → R → Code level
  mul : {i j : ℕ} → Code i → Code j → Code (i + j)
  mul_encode : ∀ {i j : ℕ} (x y : R),
    mul (encode i x) (encode j y) = encode (i + j) (x * y)

namespace System

variable {R : Type u} [CommMonoid R]

/-- Canonical multilinear evaluation of plaintext inputs. The result level is
exactly the number of inputs. -/
def multilinearEval (S : System R) (xs : List R) : S.Code xs.length :=
  S.encode xs.length xs.prod

/-- Multiplying a canonical evaluation by one more level-one input produces
the product at the incremented level. -/
theorem multilinearEval_step (S : System R) (xs : List R) (x : R) :
    S.mul (S.multilinearEval xs) (S.encode 1 x) =
      S.encode (xs.length + 1) (xs.prod * x) := by
  exact S.mul_encode xs.prod x

/-- A canonical `k`-multilinear Diffie--Hellman source challenge. -/
structure MDHSource (R : Type u) (k : ℕ) where
  exponents : Fin k → R

/-- The multilinear Diffie--Hellman target in the plaintext monoid. -/
def MDHSource.target {k : ℕ} (C : MDHSource R k) : R :=
  ∏ i, C.exponents i

/-- The public graded transcript associated with a source challenge. -/
structure MDHTranscript (S : System R) (k : ℕ) where
  publicEncoding : Fin k → S.Code 1
  targetEncoding : S.Code k

/-- Canonically encode a multilinear Diffie--Hellman source challenge. -/
def encodeChallenge (S : System R) {k : ℕ} (C : MDHSource R k) : MDHTranscript S k where
  publicEncoding := fun i => S.encode 1 (C.exponents i)
  targetEncoding := S.encode k C.target

/-- The challenge target canonically encodes the product of all source exponents. -/
theorem encodeChallenge_target (S : System R) {k : ℕ} (C : MDHSource R k) :
    (S.encodeChallenge C).targetEncoding =
      S.encode k (∏ i, C.exponents i) := by
  simp [encodeChallenge, MDHSource.target]

end System
end Cryptography.GradedEncoding