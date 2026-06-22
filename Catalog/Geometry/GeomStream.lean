/-
  Coinductive Geometric Streams
  =============================

  A *geometric stream* is the infinite sequence

      a, a*r, a*r^2, a*r^3, ...

  realized as a coinductive object of type `Stream' α`.  Geometric streams are a
  clean formal model of *exact self-similarity*: scaling the whole stream by the
  common ratio `r` produces exactly the tail of the stream.  In other words, the
  stream "looks the same" after one shift, up to multiplication by `r`.

  We build `geomStream` from `Stream'.iterate`, the standard Mathlib coinductive
  iteration combinator, which gives convenient definitional equations for `head`
  and `tail`.  Rather than developing a bespoke bisimulation framework, all
  stream equalities are proved by extensionality on `get n` (`Stream'.ext`),
  which is the directly usable Mathlib idiom.

  Algebraic assumptions are minimized theorem-by-theorem:

  * the closed form and the self-similarity result only need `[Monoid α]`;
  * the stronger "scaling commutes with the generator" compatibility
    (`map_geomStream`) needs `[CommMonoid α]`.
-/
import Mathlib.Data.Stream.Init
import Mathlib.Algebra.Group.Defs
import Mathlib.Algebra.Group.Basic

open Stream'

namespace Geometry

variable {α : Type*}

/-- The geometric stream `a, a*r, a*r^2, ...` with first term `a` and common
ratio `r`.  It is defined coinductively by iterating multiplication by `r`. -/
def geomStream [Mul α] (a r : α) : Stream' α :=
  Stream'.iterate (fun x => x * r) a

/-! ### Basic equations -/

/-- The head of a geometric stream is its first term. -/
@[simp]
theorem geomStream_head [Mul α] (a r : α) : (geomStream a r).head = a :=
  Stream'.head_iterate _ _

/-- The tail of a geometric stream is again a geometric stream, with first term
`a * r` and the same ratio. -/
@[simp]
theorem geomStream_tail [Mul α] (a r : α) :
    (geomStream a r).tail = geomStream (a * r) r :=
  Stream'.tail_iterate _ _

/-- The coinductive unfolding of a geometric stream: it is `a` consed onto the
geometric stream starting at `a * r`. -/
theorem geomStream_unfold [Mul α] (a r : α) :
    geomStream a r = a :: geomStream (a * r) r := by
  conv_lhs => rw [← Stream'.eta (geomStream a r)]
  rw [geomStream_head, geomStream_tail]

/-! ### Closed form -/

/-- Closed form for the `n`-th element of a geometric stream.  This needs only a
`Monoid` structure. -/
theorem geomStream_get [Monoid α] (a r : α) (n : ℕ) :
    (geomStream a r).get n = a * r ^ n := by
  induction n generalizing a with
  | zero => simp [geomStream, Stream'.head_iterate]
  | succ n ih =>
      rw [geomStream, Stream'.get_succ_iterate, ← geomStream, ih (a * r)]
      rw [pow_succ', mul_assoc]

/-! ### Shift / tail / drop structure -/

/-- The tail of a geometric stream, as a geometric stream.  (This is definitional
via `Stream'.iterate`, but we record it with the geometric naming and the
`a * r` first term made explicit.) -/
theorem geomStream_tail_eq [Mul α] (a r : α) :
    (geomStream a r).tail = geomStream (a * r) r :=
  geomStream_tail a r

/-- Dropping the first `n` elements of a geometric stream yields the geometric
stream whose first term is `a * r ^ n`. -/
theorem geomStream_drop [Monoid α] (a r : α) (n : ℕ) :
    (geomStream a r).drop n = geomStream (a * r ^ n) r := by
  apply Stream'.ext
  intro k
  rw [Stream'.get_drop, geomStream_get, geomStream_get, pow_add, mul_assoc]

/-- A shifted closed form: the `(n + k)`-th element factors as
`a * r ^ n * r ^ k`. -/
theorem geomStream_get_add [Monoid α] (a r : α) (n k : ℕ) :
    (geomStream a r).get (n + k) = a * r ^ n * r ^ k := by
  rw [geomStream_get, pow_add, mul_assoc]

/-! ### Exact self-similarity -/

/-- **Exact self-similarity.**  Multiplying every element of a geometric stream
by the common ratio `r` produces exactly the tail of the stream.  This is the
formal statement that a geometric stream is self-similar under the shift. -/
theorem geomStream_selfSimilar [Monoid α] (a r : α) :
    Stream'.map (fun x => x * r) (geomStream a r) = (geomStream a r).tail := by
  apply Stream'.ext
  intro n
  rw [Stream'.get_map, Stream'.get_tail, geomStream_get, geomStream_get,
    pow_succ, mul_assoc]

/-! ### Scaling compatibility -/

/-- Scaling a geometric stream by a constant `c` is again a geometric stream,
with first term `a * c` and the same ratio.  This needs commutativity so that
`(a * r ^ n) * c = (a * c) * r ^ n`. -/
theorem map_geomStream [CommMonoid α] (a r c : α) :
    Stream'.map (fun x => x * c) (geomStream a r) = geomStream (a * c) r := by
  apply Stream'.ext
  intro n
  rw [Stream'.get_map, geomStream_get, geomStream_get]
  rw [mul_right_comm]

end Geometry