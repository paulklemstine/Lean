/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.AffineParityGap

/-!
# Affine subspace statistics in `𝔽₂ⁿ`: the exact parity maximum for `2`-cubes

`Catalog/Geometry/AffineParityGap.lean` proves that the parity bound `1/2` is never attained:
for cubes of dimension `≥ 2`,
`P[|F ∩ A| odd] ≤ 1/2 - 2^{-(nd+1)}`.

Here we show that for **affine `2`-cubes** in even ambient dimension this bound is *exactly*
attained, so the rate `2^{-(n+1)}` obtained there is the true one.

The extremal set is the *bent set*
`A = {x ∈ 𝔽₂^{2m} : ∑_{i<m} x_i x_{m+i} = 1}`,
the support of the standard bent function.  What is needed is precisely the defining
property of bentness: for every `a ≠ 0` the derivative `x ↦ f(x + a) + f(x)` is a
*nonconstant affine* function and therefore takes the value `1` on exactly half of `𝔽₂^{2m}`.

## Main results

* `AffineParityBent.card_eq_half_of_shift` : a function `g : 𝔽₂ⁿ → 𝔽₂` admitting a vector
  `e` with `g(x + e) = g(x) + 1` for all `x` is balanced.
* `AffineParityBent.bent_derivative_balanced` : for `a ≠ 0` the derivative of the bent
  function at `a` is balanced.
* `AffineParityBent.oddProb_eq_of_balanced` : if all the "derivative sets" of `A` are
  balanced then `P[|F ∩ A| odd] = 1/2 - 2^{-(n+1)}` for random affine `2`-cubes.
* `AffineParityBent.oddProb_bentSet` : the bent set achieves this.
* `AffineParityBent.maxOddProb_two_eq` : **the exact value**
  `max_{A ⊆ 𝔽₂^{2m}} P[|F ∩ A| odd] = 1/2 - 2^{-(2m+1)}` for affine `2`-cubes.
  For `m = 1` this is `3/8`, recovering `AffineStats.maxOddProb_dim2_lt_half` with the exact
  constant.
-/

namespace AffineParityBent

open Finset AffineStats AffineParityGap

section Balanced

variable {n : ℕ}

/-- A function on `𝔽₂ⁿ` that is flipped by translation along some vector `e` is balanced. -/
theorem card_eq_half_of_shift (g : Vec n → ZMod 2) (e : Vec n)
    (h : ∀ x, g (x + e) = g x + 1) :
    2 * (univ.filter fun x : Vec n => g x = 1).card = 2 ^ n := by
  classical
  have hinv : Function.Involutive (fun x : Vec n => x + e) := by
    intro x
    funext i
    simp [add_assoc, CharTwo.add_self_eq_zero]
  have hflip : ∀ x : Vec n, (g (x + e) = 1) ↔ ¬ (g x = 1) := by
    intro x
    rw [h x]
    generalize g x = t
    revert t
    decide
  have := card_filter_involutive (fun x : Vec n => g x = 1) (fun x => x + e) hinv hflip
  rwa [card_Vec] at this

end Balanced

section OneDirection

variable {n : ℕ}

/-- An affine `1`-cube consists of the two points `c` and `c + w`. -/
lemma cnt_one_dir (A : Finset (Vec n)) (c w : Vec n) :
    cnt A c (fun _ : Fin 1 => w)
      = (if c ∈ A then 1 else 0) + (if c + w ∈ A then 1 else 0) := by
  classical
  rw [cnt_eq_sum]
  rw [← Fintype.sum_equiv (Equiv.funUnique (Fin 1) (ZMod 2)).symm
      (fun t : ZMod 2 => if pt c (fun _ : Fin 1 => w) (fun _ => t) ∈ A then 1 else 0)
      (fun y : Fin 1 → ZMod 2 => if pt c (fun _ : Fin 1 => w) y ∈ A then 1 else 0)
      (fun t => by rfl)]
  have h2 : (univ : Finset (ZMod 2)) = {0, 1} := by decide
  rw [h2, Finset.sum_pair (show (0 : ZMod 2) ≠ 1 by decide)]
  simp [pt]

/-- The base points with odd count for a single direction `w` are exactly the points where
membership in `A` differs from membership of the translate. -/
lemma oddBase_one_dir (A : Finset (Vec n)) (w : Vec n) :
    oddBase A (fun _ : Fin 1 => w)
      = univ.filter fun c : Vec n => ¬ ((c ∈ A) ↔ (c + w ∈ A)) := by
  classical
  refine Finset.filter_congr fun c _ => ?_
  rw [cnt_one_dir]
  by_cases h1 : c ∈ A <;> by_cases h2 : c + w ∈ A <;> simp [h1, h2]

end OneDirection

section ExactValue

variable {n : ℕ}

/-- **The exact odd-intersection probability of a "perfectly balanced" set.**  If for every
nonzero `w` exactly half of the points `c` of `𝔽₂ⁿ` have `c ∈ A` and `c + w ∈ A` differ,
then a random affine `2`-cube meets `A` in an odd number of points with probability exactly
`1/2 - 2^{-(n+1)}`, matching the upper bound `AffineParityGap.oddProb_le_half_sub`. -/
theorem oddProb_eq_of_balanced (A : Finset (Vec n))
    (hbal : ∀ w : Vec n, w ≠ 0 →
      2 * (univ.filter fun c : Vec n => ¬ ((c ∈ A) ↔ (c + w ∈ A))).card = 2 ^ n) :
    oddProb n 2 A = 1 / 2 - 1 / 2 ^ (n + 1) := by
  classical
  -- the contribution of a single direction
  have hterm : ∀ w : Fin 1 → Vec n,
      ((univ.filter fun p : Vec n × Vec n =>
        ¬ (2 ∣ (cnt A p.1 w + cnt A (p.1 + p.2) w))).card : ℚ)
        = if w 0 = 0 then 0 else 2 ^ (2 * n) / 2 := by
    intro w
    have hw : w = fun _ : Fin 1 => w 0 := by funext i; rw [Subsingleton.elim i 0]
    rw [card_pairs_eq]
    by_cases h0 : w 0 = 0
    · rw [if_pos h0]
      have : ¬ Indep w := by
        rw [hw, h0]
        exact not_indep_zero (n := n) (d := 1) one_pos
      rw [oddBase_eq_empty_of_not_indep A this]
      simp
    · rw [if_neg h0]
      have hcard : 2 * (oddBase A w).card = 2 ^ n := by
        rw [hw, oddBase_one_dir]
        exact hbal (w 0) h0
      have hk : ((oddBase A w).card : ℚ) = 2 ^ n / 2 := by
        have : (2 : ℚ) * (oddBase A w).card = 2 ^ n := by exact_mod_cast hcard
        linarith
      have hle : (oddBase A w).card ≤ 2 ^ n := by omega
      have : ((2 * ((oddBase A w).card * (2 ^ n - (oddBase A w).card)) : ℕ) : ℚ)
          = 2 * (((oddBase A w).card : ℚ) * ((2 : ℚ) ^ n - (oddBase A w).card)) := by
        push_cast [Nat.cast_sub hle]
        ring
      rw [this, hk, two_mul n, pow_add]
      ring
  -- sum over the single direction
  have hsum : ((oddSet n 2 A).card : ℚ)
      = ∑ w : Fin 1 → Vec n, (if w 0 = 0 then 0 else (2 : ℚ) ^ (2 * n) / 2) := by
    have key : (oddSet n 2 A).card = ∑ w : Fin 1 → Vec n,
        (univ.filter fun p : Vec n × Vec n =>
          ¬ (2 ∣ (cnt A p.1 w + cnt A (p.1 + p.2) w))).card := oddSet_card_eq_sum A
    rw [key]
    push_cast
    exact Finset.sum_congr rfl fun w _ => hterm w
  have hcount : ∑ w : Fin 1 → Vec n, (if w 0 = 0 then 0 else (2 : ℚ) ^ (2 * n) / 2)
      = ((2 : ℚ) ^ n - 1) * ((2 : ℚ) ^ (2 * n) / 2) := by
    rw [Fintype.sum_equiv (Equiv.funUnique (Fin 1) (Vec n))
      (fun w : Fin 1 → Vec n => if w 0 = 0 then 0 else (2 : ℚ) ^ (2 * n) / 2)
      (fun v : Vec n => if v = 0 then 0 else (2 : ℚ) ^ (2 * n) / 2) (fun w => rfl)]
    rw [Finset.sum_ite, Finset.sum_const, Finset.sum_const]
    have h1 : (univ.filter fun v : Vec n => v = 0).card = 1 := by
      rw [Finset.filter_eq' univ (0 : Vec n)]
      simp
    have h2 : (univ.filter fun v : Vec n => ¬ (v = 0)).card = 2 ^ n - 1 := by
      classical
      have := Finset.card_filter_add_card_filter_not (s := (univ : Finset (Vec n)))
        (p := fun v : Vec n => v = 0)
      rw [h1, Finset.card_univ, card_Vec] at this
      omega
    have hone : (1 : ℕ) ≤ 2 ^ n := Nat.one_le_two_pow
    have hc : ((2 ^ n - 1 : ℕ) : ℚ) = (2 : ℚ) ^ n - 1 := by
      rw [Nat.cast_sub hone]; push_cast; ring
    rw [h1, h2]
    simp only [nsmul_eq_mul, hc]
    ring
  rw [oddProb, hsum, hcount]
  have hne : ((2 : ℚ) ^ (n * (2 + 1))) ≠ 0 := by positivity
  rw [show n * (2 + 1) = n + (2 * n) from by ring, pow_add]
  field_simp
  ring

end ExactValue

section Bent

variable {m : ℕ}

/-- The standard bent function `∑_{i<m} x_i x_{m+i}` on `𝔽₂^{m+m}`. -/
def bentFun (x : Vec (m + m)) : ZMod 2 :=
  ∑ i : Fin m, x (Fin.castAdd m i) * x (Fin.natAdd m i)

/-- The support of the standard bent function. -/
def bentSet (m : ℕ) : Finset (Vec (m + m)) := univ.filter fun x => bentFun x = 1

/-- The second derivative of the bent function is the "symplectic form" of the two shifts.
Here it is computed for a single index `i`, coordinatewise. -/
lemma bent_second_derivative (a e : Vec (m + m)) (x : Vec (m + m)) :
    bentFun (x + e + a) + bentFun (x + e) + bentFun (x + a) + bentFun x
      = ∑ i : Fin m, (e (Fin.castAdd m i) * a (Fin.natAdd m i)
          + a (Fin.castAdd m i) * e (Fin.natAdd m i)) := by
  simp only [bentFun, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun i _ => ?_
  simp only [Pi.add_apply]
  generalize x (Fin.castAdd m i) = u
  generalize x (Fin.natAdd m i) = u'
  generalize e (Fin.castAdd m i) = s
  generalize e (Fin.natAdd m i) = s'
  generalize a (Fin.castAdd m i) = t
  generalize a (Fin.natAdd m i) = t'
  revert u u' s s' t t'
  decide

/-- The indicator vector of a coordinate. -/
def basisVec {k : ℕ} (j : Fin k) : Vec k := fun i => if i = j then 1 else 0

lemma castAdd_ne_natAdd (i i' : Fin m) : (Fin.castAdd m i : Fin (m + m)) ≠ Fin.natAdd m i' := by
  intro h
  have hv := congrArg Fin.val h
  rw [Fin.val_castAdd, Fin.val_natAdd] at hv
  have := i.isLt
  omega

lemma basisVec_castAdd_natAdd (i i' : Fin m) :
    basisVec (Fin.natAdd m i' : Fin (m + m)) (Fin.castAdd m i) = 0 :=
  if_neg (castAdd_ne_natAdd i i')

lemma basisVec_natAdd_castAdd (i i' : Fin m) :
    basisVec (Fin.castAdd m i' : Fin (m + m)) (Fin.natAdd m i) = 0 :=
  if_neg fun h => castAdd_ne_natAdd i' i h.symm

lemma basisVec_natAdd_natAdd (i i' : Fin m) :
    basisVec (Fin.natAdd m i' : Fin (m + m)) (Fin.natAdd m i) = if i = i' then 1 else 0 := by
  by_cases h : i = i' <;> simp [basisVec, h]

lemma basisVec_castAdd_castAdd (i i' : Fin m) :
    basisVec (Fin.castAdd m i' : Fin (m + m)) (Fin.castAdd m i) = if i = i' then 1 else 0 := by
  by_cases h : i = i'
  · simp [basisVec, h]
  · have hne : (Fin.castAdd m i : Fin (m + m)) ≠ Fin.castAdd m i' := by
      intro hcon
      refine h ?_
      have hv := congrArg Fin.val hcon
      rw [Fin.val_castAdd, Fin.val_castAdd] at hv
      exact Fin.ext hv
    simp [basisVec, hne, h]

/-- Every index of `Fin (m + m)` is in the left or in the right half. -/
lemma index_cases (j : Fin (m + m)) :
    (∃ i, j = Fin.castAdd m i) ∨ (∃ i, j = Fin.natAdd m i) :=
  Fin.addCases (motive := fun j => (∃ i, j = Fin.castAdd m i) ∨ (∃ i, j = Fin.natAdd m i))
    (fun i => Or.inl ⟨i, rfl⟩) (fun i => Or.inr ⟨i, rfl⟩) j

/-- **Bentness.**  For every nonzero `a`, the derivative `x ↦ f(x+a) + f(x)` of the standard
bent function is balanced: it equals `1` on exactly `2^{2m-1}` points. -/
theorem bent_derivative_balanced {a : Vec (m + m)} (ha : a ≠ 0) :
    2 * (univ.filter fun x : Vec (m + m) => bentFun (x + a) + bentFun x = 1).card
      = 2 ^ (m + m) := by
  classical
  obtain ⟨j, hj⟩ := exists_coord_one ha
  -- choose the coordinate "conjugate" to `j`
  obtain ⟨e, he⟩ : ∃ e : Vec (m + m),
      ∑ i : Fin m, (e (Fin.castAdd m i) * a (Fin.natAdd m i)
        + a (Fin.castAdd m i) * e (Fin.natAdd m i)) = 1 := by
    rcases index_cases j with ⟨i₀, rfl⟩ | ⟨i₀, rfl⟩
    · refine ⟨basisVec (Fin.natAdd m i₀), ?_⟩
      have hpt : ∀ i : Fin m,
          basisVec (Fin.natAdd m i₀ : Fin (m + m)) (Fin.castAdd m i) * a (Fin.natAdd m i)
            + a (Fin.castAdd m i) * basisVec (Fin.natAdd m i₀ : Fin (m + m)) (Fin.natAdd m i)
            = if i = i₀ then a (Fin.castAdd m i₀) else 0 := by
        intro i
        rw [basisVec_castAdd_natAdd, basisVec_natAdd_natAdd]
        by_cases h : i = i₀ <;> simp [h]
      rw [Finset.sum_congr rfl (fun i _ => hpt i),
        Finset.sum_ite_eq' univ i₀ (fun _ => a (Fin.castAdd m i₀))]
      simpa using hj
    · refine ⟨basisVec (Fin.castAdd m i₀), ?_⟩
      have hpt : ∀ i : Fin m,
          basisVec (Fin.castAdd m i₀ : Fin (m + m)) (Fin.castAdd m i) * a (Fin.natAdd m i)
            + a (Fin.castAdd m i) * basisVec (Fin.castAdd m i₀ : Fin (m + m)) (Fin.natAdd m i)
            = if i = i₀ then a (Fin.natAdd m i₀) else 0 := by
        intro i
        rw [basisVec_natAdd_castAdd, basisVec_castAdd_castAdd]
        by_cases h : i = i₀ <;> simp [h]
      rw [Finset.sum_congr rfl (fun i _ => hpt i),
        Finset.sum_ite_eq' univ i₀ (fun _ => a (Fin.natAdd m i₀))]
      simpa using hj
  refine card_eq_half_of_shift (fun x => bentFun (x + a) + bentFun x) e ?_
  intro x
  have h := bent_second_derivative a e x
  rw [he] at h
  show bentFun (x + e + a) + bentFun (x + e) = bentFun (x + a) + bentFun x + 1
  revert h
  generalize bentFun (x + e + a) = A
  generalize bentFun (x + e) = B
  generalize bentFun (x + a) = C
  generalize bentFun x = D
  revert A B C D
  decide

/-- The bent set has the balanced-derivative property. -/
lemma bentSet_balanced (w : Vec (m + m)) (hw : w ≠ 0) :
    2 * (univ.filter fun c : Vec (m + m) =>
        ¬ ((c ∈ bentSet m) ↔ (c + w ∈ bentSet m))).card = 2 ^ (m + m) := by
  classical
  rw [show (univ.filter fun c : Vec (m + m) => ¬ ((c ∈ bentSet m) ↔ (c + w ∈ bentSet m)))
      = univ.filter fun x : Vec (m + m) => bentFun (x + w) + bentFun x = 1 from by
    refine Finset.filter_congr fun c _ => ?_
    simp only [bentSet, mem_filter, mem_univ, true_and]
    generalize bentFun c = s
    generalize bentFun (c + w) = t
    revert s t
    decide]
  exact bent_derivative_balanced hw

/-- **The bent set attains the parity bound for `2`-cubes.** -/
theorem oddProb_bentSet (m : ℕ) :
    oddProb (m + m) 2 (bentSet m) = 1 / 2 - 1 / 2 ^ (m + m + 1) :=
  oddProb_eq_of_balanced _ bentSet_balanced

/-- **The exact parity maximum for affine `2`-cubes in even dimension.**
`max_{A ⊆ 𝔽₂^{2m}} P[|F ∩ A| odd] = 1/2 - 2^{-(2m+1)}`.  For `m = 1` the value is `3/8`. -/
theorem maxOddProb_two_eq (m : ℕ) :
    maxOddProb (m + m) 2 = 1 / 2 - 1 / 2 ^ (m + m + 1) := by
  refine le_antisymm ?_ ?_
  · refine Finset.sup'_le _ _ fun A _ => ?_
    have := oddProb_le_half_sub (n := m + m) (d := 1) A one_pos
    simpa using this
  · rw [← oddProb_bentSet m]
    exact Finset.le_sup' (fun A => oddProb (m + m) 2 A) (mem_univ _)

/-- The maximum for `n = 2`, `d = 2` is exactly `3/8`; this pins down the constant in
`AffineStats.maxOddProb_dim2_lt_half`. -/
theorem maxOddProb_dim2_eq : maxOddProb 2 2 = 3 / 8 := by
  have := maxOddProb_two_eq 1
  norm_num at this
  simpa using this

end Bent

end AffineParityBent