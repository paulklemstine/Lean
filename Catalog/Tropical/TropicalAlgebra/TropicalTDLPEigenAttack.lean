import Mathlib

/-!
# A tropical discrete-logarithm counterexample on eigenlines

This file formalizes a small, self-contained counterexample to the security of a
naive *tropical discrete logarithm problem* (TDLP).

We work over `Nat` (the min-plus / tropical semiring carrier, ignoring `+∞`) to
avoid the complications of `WithTop` and partial subtraction.  The "scalar
multiplication" of the min-plus semiring is ordinary addition `λ + x`, and the
group operation that hides the secret exponent `k` is iterated min-plus matrix
application.

The two headline results are:

* `oneByOne_tropical_iterate`: applying the `1×1` tropical matrix with entry `λ`
  exactly `k` times sends `x` to `k * λ + x`.
* `tdlp_recover_oneByOne`: when `λ = 1`, the secret exponent `k` is recovered
  from a single input/output pair by ordinary subtraction `output - input = k`.

The abstract version `iterate_eigenline_attack` shows the same collapse happens
for *any* scalar-equivariant tropical-linear map restricted to one of its
eigenlines, with the coordinate-wise recovery statement
`tdlp_recover_eigenline`.
-/

namespace Catalog.Tropical.TropicalTDLPEigenAttack

/-! ## The 1×1 case -/

/-- The action of the `1×1` tropical matrix with entry `lam` on a `1`-dimensional
tropical vector `x : Nat` is min-plus multiplication, i.e. ordinary addition. -/
def oneByOneAction (lam : Nat) : Nat → Nat := fun x => lam + x

/-- Iterating the `1×1` tropical action `k` times adds `k * lam`. -/
theorem oneByOne_tropical_iterate (lam x k : Nat) :
    (fun y : Nat => lam + y)^[k] x = k * lam + x := by
  induction k with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ_apply', ih, Nat.succ_mul]
    ring

/-- **The 1×1 counterexample.**  When `lam = 1`, the secret exponent `k` is
recovered exactly by subtracting the input from the output. -/
theorem tdlp_recover_oneByOne (x k : Nat) :
    (fun y : Nat => 1 + y)^[k] x - x = k := by
  rw [oneByOne_tropical_iterate]
  simp

/-! ## The abstract eigenline attack -/

/-- A tropical vector indexed by `ι`. -/
abbrev Vec (ι : Type) := ι → Nat

/-- Tropical scalar addition: add the scalar `c` to every coordinate. -/
def tropScalarAdd {ι : Type} (c : Nat) (v : Vec ι) : Vec ι := fun i => c + v i

/-- A map `F` is scalar-equivariant if it commutes with tropical scalar addition. -/
def ScalarEquivariant {ι : Type} (F : Vec ι → Vec ι) : Prop :=
  ∀ (c : Nat) (v : Vec ι), F (tropScalarAdd c v) = tropScalarAdd c (F v)

/-- `v` is a tropical eigenvector of `F` with eigenvalue `lam`. -/
def IsTropicalEigen {ι : Type} (F : Vec ι → Vec ι) (v : Vec ι) (lam : Nat) : Prop :=
  F v = tropScalarAdd lam v

/-- `tropScalarAdd` is additive in the scalar. -/
theorem tropScalarAdd_add {ι : Type} (a b : Nat) (v : Vec ι) :
    tropScalarAdd a (tropScalarAdd b v) = tropScalarAdd (a + b) v := by
  funext i
  simp [tropScalarAdd, Nat.add_assoc]

/-- **The eigenline attack.**  On an eigenline, iterating a scalar-equivariant
tropical-linear map collapses to a single scalar addition `k * lam`, regardless
of the (possibly unknown) structure of `F`. -/
theorem iterate_eigenline_attack
    {ι : Type} {F : Vec ι → Vec ι} {v : Vec ι} {lam k : Nat}
    (hF : ScalarEquivariant F) (hev : IsTropicalEigen F v lam) :
    F^[k] v = tropScalarAdd (k * lam) v := by
  induction k with
  | zero => funext i; simp [tropScalarAdd]
  | succ n ih =>
    rw [Function.iterate_succ_apply', ih, hF, hev, tropScalarAdd_add, Nat.succ_mul, Nat.add_comm]

/-- **Coordinate recovery on an eigenline.**  When the eigenvalue is `1`, the
secret exponent `k` is recovered from any single coordinate of an input/output
pair. -/
theorem tdlp_recover_eigenline
    {ι : Type} {F : Vec ι → Vec ι} {v : Vec ι} {k : Nat}
    (hF : ScalarEquivariant F) (hev : IsTropicalEigen F v 1) (i : ι) :
    F^[k] v i - v i = k := by
  rw [iterate_eigenline_attack hF hev]
  simp [tropScalarAdd]

end Catalog.Tropical.TropicalTDLPEigenAttack