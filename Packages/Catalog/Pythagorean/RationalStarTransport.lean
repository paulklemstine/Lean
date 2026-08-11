import Pythagorean.RationalStarVisibility

/-!
# Star transport: the tree moves the fans, and a parity invariant separates them

`RationalStarPencil` records the *covariance* of the charge: for each Berggren move `B` there
is a linear map `T` on the pair `(p, q)` of star parameters with

```
chargeZ p q (B (m,n)) = chargeZ (T (p,q)) (m,n).
```

So the tree does not merely act on nodes: it **transports whole fans**. This file develops
the resulting action.

## Main results

* `transL`, `transM`, `transR`, `trans`, `transWord` : the transport action of the three
  Berggren moves — and of an arbitrary word in them — on the star parameter `(p, q) ∈ ℤ²`.
* `chargeZ_trans` : the covariance identity, uniformly over the three moves.
* `trans_parity`, `transWord_parity` : **the parity of `p + q` is a transport invariant.**
  This is the conceptual reason for the quantisation dichotomy of
  `RationalStarRealization.realised_charges_eq`: the fan at `p/q` is full when `p + q` is odd
  and half-empty (odd charges only) when `p + q` is even, and no word of Berggren moves can
  ever convert one type into the other.
* `zero_star_not_transport_of_one_star`, `one_star_not_transport_of_zero_star` : the two
  classical stars of the picture — the `0`-star (all charges) and the `1`-star (odd charges)
  — lie in *different* transport classes. The visual asymmetry between them is therefore
  permanent, not an artefact of the choice of root.
* `transWord_isCoprime` : transport preserves primitivity, so it really acts on rational
  ideal points in lowest terms.
* `ladder_transport_zero_star` : the star at `k/(k+1)` is carried to the `0`-star by the word
  `B₁ᵏ`. Hence **infinitely many of the visible fans are one and the same fan, transported**;
  and by `full_fan_of_ladder` each of them realises every integer charge.

Taken with `RationalStarVisibility`, this completes the explanation of the picture: there is
a fan at *every* rational, only the small-denominator fans are resolved, and those fans come
in exactly two tree-inequivalent flavours, the `0`-type and the `1`-type.
-/

namespace BerggrenRationalStar

open BerggrenHypercycleStars

/-! ## Part 1. The transport action -/

/-- Transport of the star parameter under `B₁ : (m,n) ↦ (2m - n, m)`. -/
def transL (v : ℤ × ℤ) : ℤ × ℤ := (2 * v.1 - v.2, v.1)

/-- Transport of the star parameter under `B₂ : (m,n) ↦ (2m + n, m)`. -/
def transM (v : ℤ × ℤ) : ℤ × ℤ := (2 * v.1 - v.2, -v.1)

/-- Transport of the star parameter under `B₃ : (m,n) ↦ (m + 2n, n)`. -/
def transR (v : ℤ × ℤ) : ℤ × ℤ := (v.1, v.2 - 2 * v.1)

/-- The transport action of the three Berggren moves, indexed by `Fin 3`. -/
def trans : Fin 3 → (ℤ × ℤ) → ℤ × ℤ
  | 0 => transL
  | 1 => transM
  | 2 => transR

/-- The Berggren move on seeds corresponding to each index. -/
def seedMove : Fin 3 → (ℤ × ℤ) → ℤ × ℤ
  | 0 => fun s => (2 * s.1 - s.2, s.1)
  | 1 => fun s => (2 * s.1 + s.2, s.1)
  | 2 => fun s => (s.1 + 2 * s.2, s.2)

/-- **Uniform covariance.** For each of the three moves, the charge of the image seed at the
star `(p,q)` equals the charge of the original seed at the transported star `trans i (p,q)`.
This is the single identity behind the whole transport picture. -/
theorem chargeZ_trans (i : Fin 3) (v s : ℤ × ℤ) :
    chargeZ v.1 v.2 (seedMove i s).1 (seedMove i s).2
      = chargeZ (trans i v).1 (trans i v).2 s.1 s.2 := by
  fin_cases i <;> simp only [trans, seedMove, transL, transM, transR, chargeZ] <;> ring

/-- Transport of a word of Berggren moves, read left to right. -/
def transWord (w : List (Fin 3)) (v : ℤ × ℤ) : ℤ × ℤ :=
  w.foldl (fun v i => trans i v) v

@[simp] theorem transWord_nil (v : ℤ × ℤ) : transWord [] v = v := rfl

@[simp] theorem transWord_cons (i : Fin 3) (w : List (Fin 3)) (v : ℤ × ℤ) :
    transWord (i :: w) v = transWord w (trans i v) := rfl

/-! ## Part 2. The parity invariant -/

/-- Each generator preserves the parity of `p + q`. -/
theorem trans_parity (i : Fin 3) (v : ℤ × ℤ) :
    ((trans i v).1 + (trans i v).2) % 2 = (v.1 + v.2) % 2 := by
  fin_cases i <;> simp only [trans, transL, transM, transR] <;> omega

/-- **The parity of `p + q` is a transport invariant.** No word of Berggren moves can change
the parity class of a star. -/
theorem transWord_parity (w : List (Fin 3)) (v : ℤ × ℤ) :
    ((transWord w v).1 + (transWord w v).2) % 2 = (v.1 + v.2) % 2 := by
  induction w generalizing v with
  | nil => rfl
  | cons i w ih => rw [transWord_cons, ih, trans_parity]

/-- The `0`-star is not a transport of the `1`-star: `0 + 1` is odd while `1 + 1` is even. -/
theorem zero_star_not_transport_of_one_star (w : List (Fin 3)) :
    transWord w (1, 1) ≠ (0, 1) := by
  intro h
  have := transWord_parity w (1, 1)
  rw [h] at this
  norm_num at this

/-- Symmetrically, the `1`-star is not a transport of the `0`-star. -/
theorem one_star_not_transport_of_zero_star (w : List (Fin 3)) :
    transWord w (0, 1) ≠ (1, 1) := by
  intro h
  have := transWord_parity w (0, 1)
  rw [h] at this
  norm_num at this

/-- More generally: a star with `p + q` odd (full fan) is never a transport of a star with
`p + q` even (half fan). The visible asymmetry of the two star types is permanent. -/
theorem no_transport_between_parity_classes {v v' : ℤ × ℤ} (w : List (Fin 3))
    (hv : (v.1 + v.2) % 2 = 0) (hv' : (v'.1 + v'.2) % 2 = 1) : transWord w v ≠ v' := by
  intro h
  have := transWord_parity w v
  rw [h, hv, hv'] at this
  exact absurd this (by norm_num)

/-! ## Part 3. Transport preserves primitivity -/

/-- Each generator preserves coprimality of the star parameters, so transport acts on
rationals in lowest terms. -/
theorem trans_isCoprime (i : Fin 3) {v : ℤ × ℤ} (h : IsCoprime v.1 v.2) :
    IsCoprime (trans i v).1 (trans i v).2 := by
  obtain ⟨a, b, hab⟩ := h
  fin_cases i <;> simp only [trans, transL, transM, transR]
  · exact ⟨-b, a + 2 * b, by linarith [hab]⟩
  · exact ⟨-b, -(a + 2 * b), by linarith [hab]⟩
  · exact ⟨a + 2 * b, b, by linarith [hab]⟩

/-- Transport by an arbitrary word preserves primitivity. -/
theorem transWord_isCoprime (w : List (Fin 3)) {v : ℤ × ℤ} (h : IsCoprime v.1 v.2) :
    IsCoprime (transWord w v).1 (transWord w v).2 := by
  induction w generalizing v with
  | nil => exact h
  | cons i w ih => exact ih (trans_isCoprime i h)

/-! ## Part 4. An infinite orbit: the ladder of Farey neighbours -/

/-- The star at `k/(k+1)`. -/
def ladder (k : ℕ) : ℤ × ℤ := ((k : ℤ), (k : ℤ) + 1)

/-- One `B₁`-transport walks the ladder down by one rung. -/
theorem trans_ladder_succ (k : ℕ) : trans 0 (ladder (k + 1)) = ladder k := by
  simp only [trans, transL, ladder, Prod.mk.injEq]
  push_cast
  constructor <;> ring

/-- **The ladder collapses to the `0`-star.** The word `B₁ᵏ` transports the star at
`k/(k+1)` onto the star at `0`. Hence infinitely many of the fans visible in the picture are
tree-transports of one single fan. -/
theorem ladder_transport_zero_star (k : ℕ) :
    transWord (List.replicate k 0) (ladder k) = (0, 1) := by
  induction k with
  | zero => simp [ladder]
  | succ k ih =>
      rw [List.replicate_succ, transWord_cons, trans_ladder_succ]
      exact ih

/-- Every rung of the ladder is a genuine star centre in lowest terms, of odd parameter sum:
so by `realised_charges_eq` its fan is *full* — every integer charge occurs. -/
theorem full_fan_of_ladder {k : ℕ} (hk : 0 < k) :
    {c : ℤ | ∃ m n : ℕ, IsSeed m n ∧ charge (k : ℤ) (k + 1) m n = c} = Set.univ := by
  have hcop : Nat.Coprime k (k + 1) := by simp [Nat.Coprime]
  have hpar : (k + (k + 1)) % 2 = 1 := by omega
  have := realised_charges_eq (p := k) (q := k + 1) hk (by omega) hcop
  rw [this, if_pos hpar]

/-- Package: for every `k ≥ 1` the fan at `k/(k+1)` is a transport of the `0`-star, is a
primitive star centre, and realises every integer charge — while no word of Berggren moves
carries the `1`-star to any of them. -/
theorem ladder_fans_are_zero_type {k : ℕ} (hk : 0 < k) :
    transWord (List.replicate k 0) (ladder k) = (0, 1) ∧
      IsCoprime (ladder k).1 (ladder k).2 ∧
      {c : ℤ | ∃ m n : ℕ, IsSeed m n ∧ charge (k : ℤ) (k + 1) m n = c} = Set.univ ∧
      ∀ w : List (Fin 3), transWord w (1, 1) ≠ ladder k := by
  refine ⟨ladder_transport_zero_star k, ?_, full_fan_of_ladder hk, ?_⟩
  · exact ⟨-1, 1, by simp [ladder]⟩
  · intro w
    refine no_transport_between_parity_classes w ?_ ?_
    · norm_num
    · simp only [ladder]
      omega

end BerggrenRationalStar