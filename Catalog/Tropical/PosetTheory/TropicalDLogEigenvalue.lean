import Mathlib

/-!
# A tropical-eigenvalue reading of the discrete logarithm

Let `G` be a finite cyclic group of prime order `p`, written multiplicatively with
generator `g`.  Fix `h ∈ G` and let `k ∈ ZMod p` satisfy `h = g ^ k`.

We form the `1 × 1` matrix `M = [log_g h]` over the **min-plus semiring** (the real
numbers with `min` as addition and `+` as multiplication, modelled by Mathlib's
`Tropical ℝ`).  The single entry of `M` is the discrete logarithm `log_g h`, viewed
as a real number through the constructive search `dlogNat`.

The headline results are:

* `isTropEigenvalue_iff` : for a `1 × 1` tropical matrix `M`, a scalar `lam` is a
  tropical eigenvalue iff `lam = M 0 0`.  (Min-plus multiplication is real addition,
  which is cancellative, so the eigenvalue is forced to be the matrix entry.)
* `tropical_dlog` : the unique tropical eigenvalue of `M = [log_g h]` is
  `trop (k.val : ℝ)`, and reducing it modulo `p` recovers the secret exponent `k`.
* `tropMap_eigenline` : the equivariant tropical-linear map `T v = M ⊗ v` acts on the
  whole `1`-dimensional min-plus space (its eigenline) as scaling by `trop (k.val)`,
  so the eigenline likewise encodes `k`.
* `dlogNat_correct` : the constructive algorithm `dlogNat g h p`, which is exactly the
  computation of the tropical eigenvalue's exponent, returns `k.val`.

**Remark.**  Together these give a tropical-algebraic reduction of the discrete
logarithm problem to a `1`-dimensional tropical eigenvalue computation: recovering the
secret exponent `k` is the same as reading off the (unique) eigenvalue of the
associated min-plus matrix.
-/

namespace Catalog.Tropical.TropicalDLogEigenvalue

open _root_.Tropical

/-! ## The constructive discrete-logarithm search -/

/-- Constructive discrete-log search: the first exponent `k ∈ {0, …, p-1}` with
`g ^ k = h`, or `p` if none exists.  This is the constructive algorithm that the
main theorem identifies with the tropical eigenvalue computation. -/
def dlogNat {G : Type*} [Group G] [DecidableEq G] (g h : G) (p : ℕ) : ℕ :=
  (List.range p).findIdx (fun k => decide (g ^ k = h))

/-- The discrete logarithm as an element of `ZMod p`. -/
def dlog {G : Type*} [Group G] [DecidableEq G] (g h : G) (p : ℕ) : ZMod p :=
  (dlogNat g h p : ZMod p)

variable {G : Type*} [Group G] [DecidableEq G] {p : ℕ}

/-- Within `{0, …, p-1}`, if `g` has order `p` then `g ^ j = h` happens for exactly the
exponent `m`. -/
omit [DecidableEq G] in
lemma pow_eq_iff_of_orderOf {g h : G} {m : ℕ} (hord : orderOf g = p) (hm : m < p)
    (hgh : g ^ m = h) {j : ℕ} (hj : j < p) : g ^ j = h ↔ j = m := by
  refine ⟨ fun h => ?_, fun h => h ▸ hgh ⟩
  rw [ ← hgh, pow_eq_pow_iff_modEq ] at h
  rw [ Nat.ModEq, Nat.mod_eq_of_lt, Nat.mod_eq_of_lt ] at h <;> aesop

/-- The constructive search returns the unique exponent `m`. -/
lemma dlogNat_eq {g h : G} {m : ℕ} (hord : orderOf g = p) (hm : m < p)
    (hgh : g ^ m = h) : dlogNat g h p = m := by
  unfold dlogNat
  have hex : ∃ x ∈ List.range p, (fun k => decide (g ^ k = h)) x = true :=
    ⟨m, List.mem_range.mpr hm, by simp [hgh]⟩
  have hlt : (List.range p).findIdx (fun k => decide (g ^ k = h)) < (List.range p).length :=
    List.findIdx_lt_length_of_exists hex
  have hltp : (List.range p).findIdx (fun k => decide (g ^ k = h)) < p := by
    simpa [List.length_range] using hlt
  have hsat := List.findIdx_getElem (p := fun k => decide (g ^ k = h)) (xs := List.range p) (w := hlt)
  rw [List.getElem_range] at hsat
  have hval : g ^ (List.range p).findIdx (fun k => decide (g ^ k = h)) = h := by
    simpa using hsat
  exact (pow_eq_iff_of_orderOf hord hm hgh hltp).1 hval

/-- **Correctness of the constructive algorithm.**  Computing the tropical eigenvalue's
exponent returns the discrete logarithm `k.val`. -/
theorem dlogNat_correct {g h : G} {k : ZMod p} [Fact p.Prime] (hord : orderOf g = p)
    (hgh : h = g ^ k.val) : dlogNat g h p = k.val := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).pos.ne'⟩
  exact dlogNat_eq hord (ZMod.val_lt k) hgh.symm

/-! ## The 1×1 tropical (min-plus) matrix and its eigenvalue -/

/-- The `1 × 1` min-plus matrix `M = [log_g h]`.  Over `Tropical ℝ`, tropical
multiplication is ordinary addition and tropical addition is `min`. -/
def tropMatrix (g h : G) (p : ℕ) : Matrix (Fin 1) (Fin 1) (Tropical ℝ) :=
  fun _ _ => trop ((dlogNat g h p : ℝ))

/-- Tropical matrix–vector product for a `1 × 1` matrix: its only entry is
`M₀₀ ⊗ v₀` (tropical multiplication). -/
def tropApply (M : Matrix (Fin 1) (Fin 1) (Tropical ℝ)) (v : Fin 1 → Tropical ℝ) :
    Fin 1 → Tropical ℝ := fun i => M i i * v i

/-- `lam` is a tropical eigenvalue of the `1 × 1` matrix `M` if there is an eigenvector
`v` with `M ⊗ v = lam ⊗ v`. -/
def IsTropEigenvalue (M : Matrix (Fin 1) (Fin 1) (Tropical ℝ)) (lam : Tropical ℝ) :
    Prop :=
  ∃ v : Fin 1 → Tropical ℝ, tropApply M v = fun i => lam * v i

/-- **Tropical eigenvalue of a `1 × 1` matrix.**  Since min-plus multiplication is real
addition (which is cancellative), the only tropical eigenvalue is the matrix entry. -/
theorem isTropEigenvalue_iff (M : Matrix (Fin 1) (Fin 1) (Tropical ℝ)) (lam : Tropical ℝ) :
    IsTropEigenvalue M lam ↔ lam = M 0 0 := by
  constructor
  · rintro ⟨v, hv⟩
    have := congrFun hv 0
    simp only [tropApply] at this
    exact (mul_right_cancel this).symm
  · intro h
    refine ⟨fun _ => (1 : Tropical ℝ), ?_⟩
    funext i
    have : i = 0 := Subsingleton.elim _ _
    subst this
    simp [tropApply, h]

/-! ## The equivariant tropical-linear map and its eigenline -/

/-- The equivariant tropical-linear map `T` induced by the matrix on the
`1`-dimensional min-plus space: `T v = M ⊗ v`. -/
def tropMap (g h : G) (p : ℕ) : (Fin 1 → Tropical ℝ) → (Fin 1 → Tropical ℝ) :=
  tropApply (tropMatrix g h p)

/-! ## Main theorems -/

/-- **Tropical reduction of the discrete logarithm.**  For `M = [log_g h]`, the unique
tropical eigenvalue is `trop (k.val : ℝ)`, and reducing it modulo `p` recovers the
secret exponent `k`. -/
theorem tropical_dlog {g h : G} {k : ZMod p} [Fact p.Prime] (hord : orderOf g = p)
    (hgh : h = g ^ k.val) :
    (∀ lam : Tropical ℝ,
      IsTropEigenvalue (tropMatrix g h p) lam ↔ lam = trop ((k.val : ℝ))) ∧
      dlog g h p = k := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).pos.ne'⟩
  have hd : dlogNat g h p = k.val := dlogNat_correct hord hgh
  refine ⟨fun lam => ?_, ?_⟩
  · rw [isTropEigenvalue_iff]
    simp [tropMatrix, hd]
  · simp [dlog, hd, ZMod.natCast_rightInverse k]

/-- **The eigenline encodes `k`.**  The equivariant tropical-linear map `T v = M ⊗ v`
acts on the whole `1`-dimensional min-plus space (its eigenline) as tropical scaling by
`trop (k.val)`; thus every vector is an eigenvector and the eigenline encodes `k`. -/
theorem tropMap_eigenline {g h : G} {k : ZMod p} [Fact p.Prime] (hord : orderOf g = p)
    (hgh : h = g ^ k.val) (v : Fin 1 → Tropical ℝ) :
    tropMap g h p v = fun i => trop ((k.val : ℝ)) * v i := by
  have hd : dlogNat g h p = k.val := dlogNat_correct hord hgh
  funext i
  simp [tropMap, tropApply, tropMatrix, hd]

/-! ### A concrete computation

In the cyclic group `Multiplicative (ZMod 7)` with generator `ofAdd 1`, the algorithm
recovers the exponent `3` from `g ^ 3`. -/

example :
    dlogNat (Multiplicative.ofAdd (1 : ZMod 7))
      (Multiplicative.ofAdd (1 : ZMod 7) ^ 3) 7 = 3 := by decide

end Catalog.Tropical.TropicalDLogEigenvalue