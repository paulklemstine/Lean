import Mathlib

/-!
# The `M × N` torus surface code: cellular chain complex

This file builds the *geometric* object requested by target 3 of the previous
research cycle: the cellular chain complex of the standard square-grid
cellulation of the two-dimensional torus `(ℤ/M) × (ℤ/N)`, over the binary field
`𝔽₂`.

* vertices  `Vert M N = ZMod M × ZMod N`                      (`MN` of them),
* edges     `Edge M N = Bool × ZMod M × ZMod N`               (`2MN` of them):
  the edge `(false, u)` joins `u` to `u + (1,0)`, the edge `(true, u)` joins `u`
  to `u + (0,1)`,
* faces     `Face M N = ZMod M × ZMod N`                      (`MN` of them):
  the face `f` is the unit square with corners `f, f+(1,0), f+(0,1), f+(1,1)`.

The two boundary matrices are `d1 : Vert × Edge` and `d2 : Edge × Face`.  The
main content of this file is a set of *explicit pointwise formulas* for the four
maps `d1 *ᵥ ·`, `d2 *ᵥ ·`, `d1ᵀ *ᵥ ·`, `d2ᵀ *ᵥ ·`, together with the chain
condition `d1 ∘ d2 = 0`.  Everything downstream is proved from these formulas,
never by unfolding the matrices again.
-/

open Matrix

namespace ToricCode

/-- The binary field. -/
abbrev F2 := ZMod 2

variable (M N : ℕ) [NeZero M] [NeZero N]

/-- Vertices (`0`-cells) of the torus grid. -/
abbrev Vert := ZMod M × ZMod N

/-- Edges (`1`-cells, i.e. physical qubits).  `(false, u)` is the horizontal
edge based at `u`, `(true, u)` the vertical one. -/
abbrev Edge := Bool × ZMod M × ZMod N

/-- Faces (`2`-cells) of the torus grid. -/
abbrev Face := ZMod M × ZMod N

/-- The lattice step associated to an edge direction. -/
def step (b : Bool) : ZMod M × ZMod N := cond b (0, 1) (1, 0)

omit [NeZero M] [NeZero N] in @[simp] lemma step_false : step M N false = (1, 0) := rfl
omit [NeZero M] [NeZero N] in @[simp] lemma step_true : step M N true = (0, 1) := rfl

/-- The `1`-boundary matrix: an edge is sent to the sum of its two endpoints. -/
def d1 : Matrix (Vert M N) (Edge M N) F2 :=
  fun v e => (if v = e.2 then 1 else 0) + (if v = e.2 + step M N e.1 then 1 else 0)

/-- The `2`-boundary matrix: a face is sent to the sum of its four sides. -/
def d2 : Matrix (Edge M N) (Face M N) F2 :=
  fun e f => (if e.2 = f then 1 else 0) + (if e.2 = f + step M N (!e.1) then 1 else 0)

/-! ### Pointwise formulas -/

private lemma sum_two_ind (s v : ZMod M × ZMod N) (f : (ZMod M × ZMod N) → F2) :
    ∑ u : ZMod M × ZMod N,
        ((if v = u then (1:F2) else 0) + (if v = u + s then 1 else 0)) * f u
      = f v + f (v - s) := by
  classical
  have h : ∀ u : ZMod M × ZMod N,
      ((if v = u then (1:F2) else 0) + (if v = u + s then 1 else 0)) * f u
        = (if v = u then f u else 0) + (if v - s = u then f u else 0) := by
    intro u
    simp only [add_mul, ite_mul, one_mul, zero_mul]
    congr 2
    simp only [eq_iff_iff]
    constructor
    · intro h; rw [h]; ring
    · intro h; rw [← h]; ring
  rw [Finset.sum_congr rfl (fun u _ => h u), Finset.sum_add_distrib]
  simp

private lemma sum_two_ind_comm (s v : ZMod M × ZMod N) (f : (ZMod M × ZMod N) → F2) :
    ∑ u : ZMod M × ZMod N,
        ((if u = v then (1:F2) else 0) + (if u = v + s then 1 else 0)) * f u
      = f v + f (v + s) := by
  classical
  have h : ∀ u : ZMod M × ZMod N,
      ((if u = v then (1:F2) else 0) + (if u = v + s then 1 else 0)) * f u
        = (if v = u then f u else 0) + (if v + s = u then f u else 0) := by
    intro u
    simp only [add_mul, ite_mul, one_mul, zero_mul]
    congr 2 <;> simp only [eq_iff_iff] <;> exact eq_comm
  rw [Finset.sum_congr rfl (fun u _ => h u), Finset.sum_add_distrib]
  simp

/-- The cellular boundary of a `1`-chain at a vertex: the sum of the four
incident edges. -/
lemma d1_mulVec (z : Edge M N → F2) (v : Vert M N) :
    (d1 M N *ᵥ z) v = z (false, v) + z (false, v - (1, 0))
      + (z (true, v) + z (true, v - (0, 1))) := by
  classical
  simp only [Matrix.mulVec, d1, dotProduct]
  rw [Fintype.sum_prod_type, Fintype.sum_bool,
      sum_two_ind M N (step M N false) v (fun u => z (false, u)),
      sum_two_ind M N (step M N true) v (fun u => z (true, u))]
  simp only [step_false, step_true]
  ring

/-- The cellular boundary of a `2`-chain, evaluated on an edge. -/
lemma d2_mulVec (g : Face M N → F2) (b : Bool) (u : ZMod M × ZMod N) :
    (d2 M N *ᵥ g) (b, u) = g u + g (u - step M N (!b)) := by
  classical
  simp only [Matrix.mulVec, d2, dotProduct]
  exact sum_two_ind M N (step M N (!b)) u g

/-- The coboundary of a `0`-cochain, evaluated on an edge. -/
lemma d1T_mulVec (h : Vert M N → F2) (b : Bool) (u : ZMod M × ZMod N) :
    ((d1 M N)ᵀ *ᵥ h) (b, u) = h u + h (u + step M N b) := by
  classical
  simp only [Matrix.mulVec, Matrix.transpose_apply, d1, dotProduct]
  exact sum_two_ind_comm M N (step M N b) u h

/-- The coboundary of a `1`-cochain, evaluated on a face: the sum of the four
sides of that face. -/
lemma d2T_mulVec (z : Edge M N → F2) (f : Face M N) :
    ((d2 M N)ᵀ *ᵥ z) f = z (false, f) + z (false, f + (0, 1))
      + (z (true, f) + z (true, f + (1, 0))) := by
  classical
  simp only [Matrix.mulVec, Matrix.transpose_apply, d2, dotProduct]
  rw [Fintype.sum_prod_type, Fintype.sum_bool]
  rw [sum_two_ind_comm M N (step M N (!true)) f (fun u => z (true, u)),
      sum_two_ind_comm M N (step M N (!false)) f (fun u => z (false, u))]
  simp only [Bool.not_true, Bool.not_false, step_false, step_true]
  ring

/-! ### The chain condition -/

private lemma f2_four (a b c d : F2) : a + b + (c + d) + (a + c + (b + d)) = 0 := by
  have h : ∀ x : F2, x + x = 0 := by decide
  linear_combination (h a) + (h b) + (h c) + (h d)

/-- **The torus grid is a chain complex**: the boundary of a boundary vanishes. -/
theorem d1_d2_mulVec (g : Face M N → F2) : d1 M N *ᵥ (d2 M N *ᵥ g) = 0 := by
  funext v
  rw [d1_mulVec]
  simp only [d2_mulVec, Bool.not_false, Bool.not_true, step_false, step_true]
  have hcomm : v - (1, 0) - ((0:ZMod M), (1:ZMod N)) = v - (0, 1) - ((1:ZMod M), (0:ZMod N)) := by
    obtain ⟨a, b⟩ := v
    simp only [Prod.mk_sub_mk, Prod.mk.injEq]
    constructor <;> ring
  rw [hcomm]
  simpa using f2_four (g v) (g (v - (0,1))) (g (v - (1,0))) (g (v - (0,1) - (1,0)))

/-- The chain condition, as an identity of linear maps. -/
theorem chain_condition :
    (d1 M N).mulVecLin.comp (d2 M N).mulVecLin = 0 := by
  refine LinearMap.ext fun g => ?_
  simp only [LinearMap.comp_apply, Matrix.mulVecLin_apply, LinearMap.zero_apply]
  exact d1_d2_mulVec M N g

/-! ### Basic counting -/

lemma card_vert : Fintype.card (Vert M N) = M * N := by
  simp [Fintype.card_prod, ZMod.card]

lemma card_face : Fintype.card (Face M N) = M * N := by
  simp [Fintype.card_prod, ZMod.card]

lemma card_edge : Fintype.card (Edge M N) = 2 * (M * N) := by
  simp [Fintype.card_prod, ZMod.card]

/-! ### Kernels of the two coboundary operators are the constants -/

/-- A function on the torus invariant under both unit translations is constant. -/
lemma const_of_shift (f : ZMod M × ZMod N → F2)
    (hx : ∀ u : ZMod M × ZMod N, f (u + (1, 0)) = f u)
    (hy : ∀ u : ZMod M × ZMod N, f (u + (0, 1)) = f u) :
    ∀ u, f u = f 0 := by
  have hz : ((0 : ZMod M), (0 : ZMod N)) = 0 := rfl
  have hxn : ∀ (n : ℕ) (u : ZMod M × ZMod N), f (u + ((n : ZMod M), 0)) = f u := by
    intro n
    induction n with
    | zero => intro u; rw [Nat.cast_zero, hz, add_zero]
    | succ k ih =>
        intro u
        obtain ⟨a, b⟩ := u
        have h : ((a, b) : ZMod M × ZMod N) + (((k + 1 : ℕ) : ZMod M), 0)
            = ((a, b) + ((k : ZMod M), 0)) + (1, 0) := by
          push_cast
          simp only [Prod.mk_add_mk, Prod.mk.injEq]
          constructor <;> ring
        rw [h, hx, ih]
  have hyn : ∀ (n : ℕ) (u : ZMod M × ZMod N), f (u + (0, (n : ZMod N))) = f u := by
    intro n
    induction n with
    | zero => intro u; rw [Nat.cast_zero, hz, add_zero]
    | succ k ih =>
        intro u
        obtain ⟨a, b⟩ := u
        have h : ((a, b) : ZMod M × ZMod N) + (0, ((k + 1 : ℕ) : ZMod N))
            = ((a, b) + (0, (k : ZMod N))) + (0, 1) := by
          push_cast
          simp only [Prod.mk_add_mk, Prod.mk.injEq]
          constructor <;> ring
        rw [h, hy, ih]
  intro u
  obtain ⟨x, y⟩ := u
  have e1 : f (x, 0) = f 0 := by
    have h := hxn x.val 0
    rw [ZMod.natCast_rightInverse x] at h
    rw [← h, zero_add]
  have e2 : f (x, y) = f (x, 0) := by
    have h := hyn y.val (x, 0)
    rw [ZMod.natCast_rightInverse y] at h
    rw [← h]
    congr 1
    simp only [Prod.mk_add_mk, add_zero, zero_add]
  rw [e2, e1]

end ToricCode