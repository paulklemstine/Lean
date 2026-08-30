import Algebra.EulerTwoSquaresCount

/-!
# The representation count, as a finite cardinality

`EulerTwoSquares.exactly_two_reps` describes the representations of `p*q` as a list of four
ordered integer pairs.  Here we package the same information as a *cardinality*: the finite
set of normalised representations

`repFinset n = {(a,b) : 0 < a ≤ b, a² + b² = n}`

has exactly two elements when `n = p*q` for distinct primes `p ≡ q ≡ 1 [MOD 4]`.  This is the
form in which the eligibility statistics of a factorisation experiment are actually measured.
-/

namespace EulerTwoSquares

variable {p q : ℕ}

/-- The normalised two-square representations of `n`: pairs `0 < a ≤ b` with `a² + b² = n`. -/
def repFinset (n : ℕ) : Finset (ℕ × ℕ) :=
  (Finset.range (n + 1) ×ˢ Finset.range (n + 1)).filter
    (fun z => 0 < z.1 ∧ z.1 ≤ z.2 ∧ z.1 ^ 2 + z.2 ^ 2 = n)

theorem mem_repFinset {n : ℕ} {z : ℕ × ℕ} :
    z ∈ repFinset n ↔ 0 < z.1 ∧ z.1 ≤ z.2 ∧ z.1 ^ 2 + z.2 ^ 2 = n := by
  simp only [repFinset, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
  constructor
  · rintro ⟨-, h⟩; exact h
  · rintro ⟨h1, h2, h3⟩
    have hz1 : z.1 ≤ z.1 ^ 2 := Nat.le_self_pow (by norm_num) _
    have hz2 : z.2 ≤ z.2 ^ 2 := Nat.le_self_pow (by norm_num) _
    exact ⟨⟨by omega, by omega⟩, h1, h2, h3⟩

/-- A positive integral representation, normalised, is an element of `repFinset`. -/
theorem minmax_mem_repFinset {n : ℕ} {U V : ℤ} (hU : 0 < U) (hV : 0 < V)
    (h : U ^ 2 + V ^ 2 = (n : ℤ)) : ((min U V).toNat, (max U V).toNat) ∈ repFinset n := by
  have hmin : 0 < min U V := lt_min hU hV
  have hmax : min U V ≤ max U V := min_le_max
  have hsum : (min U V) ^ 2 + (max U V) ^ 2 = (n : ℤ) := by
    rcases le_total U V with hle | hle
    · rw [min_eq_left hle, max_eq_right hle]; exact h
    · rw [min_eq_right hle, max_eq_left hle]; linarith [h]
  refine mem_repFinset.2 ⟨?_, ?_, ?_⟩
  · simpa using hmin
  · exact Int.toNat_le_toNat hmax
  · have hc : (((min U V).toNat : ℤ)) ^ 2 + (((max U V).toNat : ℤ)) ^ 2 = (n : ℤ) := by
      rw [Int.toNat_of_nonneg hmin.le, Int.toNat_of_nonneg (hmin.le.trans hmax)]
      exact hsum
    exact_mod_cast hc

/-- Reading a normalised pair back as the `min`/`max` of an integral representation. -/
theorem pair_eq_minmax {U V : ℤ} {z : ℕ × ℕ} (h1 : (z.1 : ℤ) = U) (h2 : (z.2 : ℤ) = V)
    (hle : z.1 ≤ z.2) : z = ((min U V).toNat, (max U V).toNat) := by
  have hUV : U ≤ V := by rw [← h1, ← h2]; exact_mod_cast hle
  rw [min_eq_left hUV, max_eq_right hUV, ← h1, ← h2]
  simp

theorem pair_eq_minmax' {U V : ℤ} {z : ℕ × ℕ} (h1 : (z.1 : ℤ) = V) (h2 : (z.2 : ℤ) = U)
    (hle : z.1 ≤ z.2) : z = ((min U V).toNat, (max U V).toNat) := by
  have hUV : V ≤ U := by rw [← h1, ← h2]; exact_mod_cast hle
  rw [min_eq_right hUV, max_eq_left hUV, ← h1, ← h2]
  simp

/-- **The representation count of an eligible semiprime is exactly two.**  For distinct primes
`p ≡ q ≡ 1 [MOD 4]` the finite set of normalised two-square representations of `p*q` has
cardinality `2`. -/
theorem repFinset_card_eq_two (hp : p.Prime) (hq : q.Prime) (hp4 : p % 4 = 1) (hq4 : q % 4 = 1)
    (hpq : p ≠ q) : (repFinset (p * q)).card = 2 := by
  obtain ⟨A, B, C, D, hA, hB, hC, hD, hAB, hCD, hne1, hne2, hall⟩ :=
    exactly_two_reps hp hq hp4 hq4 hpq
  have hABn : A ^ 2 + B ^ 2 = ((p * q : ℕ) : ℤ) := by push_cast; exact hAB
  have hCDn : C ^ 2 + D ^ 2 = ((p * q : ℕ) : ℤ) := by push_cast; exact hCD
  set x : ℕ × ℕ := ((min A B).toNat, (max A B).toNat) with hxdef
  set y : ℕ × ℕ := ((min C D).toNat, (max C D).toNat) with hydef
  have hxmem : x ∈ repFinset (p * q) := minmax_mem_repFinset hA hB hABn
  have hymem : y ∈ repFinset (p * q) := minmax_mem_repFinset hC hD hCDn
  have hxy : x ≠ y := by
    intro hEq
    have hmin : min A B = min C D := by
      have := congrArg Prod.fst hEq
      simp only [hxdef, hydef] at this
      have h1 : (0 : ℤ) ≤ min A B := (lt_min hA hB).le
      have h2 : (0 : ℤ) ≤ min C D := (lt_min hC hD).le
      omega
    have hmax : max A B = max C D := by
      have := congrArg Prod.snd hEq
      simp only [hxdef, hydef] at this
      have h1 : (0 : ℤ) ≤ max A B := le_trans hA.le (le_max_left _ _)
      have h2 : (0 : ℤ) ≤ max C D := le_trans hC.le (le_max_left _ _)
      omega
    rcases le_total A B with hab | hab <;> rcases le_total C D with hcd | hcd
    · rw [min_eq_left hab, min_eq_left hcd] at hmin
      rw [max_eq_right hab, max_eq_right hcd] at hmax
      exact hne1 ⟨hmin.symm, hmax.symm⟩
    · rw [min_eq_left hab, min_eq_right hcd] at hmin
      rw [max_eq_right hab, max_eq_left hcd] at hmax
      exact hne2 ⟨hmin.symm, hmax.symm⟩
    · rw [min_eq_right hab, min_eq_left hcd] at hmin
      rw [max_eq_left hab, max_eq_right hcd] at hmax
      exact hne2 ⟨hmax.symm, hmin.symm⟩
    · rw [min_eq_right hab, min_eq_right hcd] at hmin
      rw [max_eq_left hab, max_eq_left hcd] at hmax
      exact hne1 ⟨hmax.symm, hmin.symm⟩
  have hset : repFinset (p * q) = {x, y} := by
    apply Finset.ext
    intro z
    constructor
    · intro hz
      obtain ⟨hz1, hz2, hz3⟩ := mem_repFinset.1 hz
      have hz1' : (0 : ℤ) < (z.1 : ℤ) := by exact_mod_cast hz1
      have hz2' : (0 : ℤ) < (z.2 : ℤ) := by omega
      have hz3' : (z.1 : ℤ) ^ 2 + (z.2 : ℤ) ^ 2 = (p : ℤ) * q := by
        have : ((z.1 ^ 2 + z.2 ^ 2 : ℕ) : ℤ) = ((p * q : ℕ) : ℤ) := by exact_mod_cast hz3
        push_cast at this
        exact this
      rcases hall (z.1 : ℤ) (z.2 : ℤ) hz1' hz2' hz3' with ⟨e1, e2⟩ | ⟨e1, e2⟩ | ⟨e1, e2⟩ | ⟨e1, e2⟩
      · exact Finset.mem_insert.2 (Or.inl (pair_eq_minmax e1 e2 hz2))
      · exact Finset.mem_insert.2 (Or.inl (pair_eq_minmax' e1 e2 hz2))
      · exact Finset.mem_insert.2 (Or.inr (Finset.mem_singleton.2
          (pair_eq_minmax e1 e2 hz2)))
      · exact Finset.mem_insert.2 (Or.inr (Finset.mem_singleton.2
          (pair_eq_minmax' e1 e2 hz2)))
    · intro hz
      rcases Finset.mem_insert.1 hz with h | h
      · rw [h]; exact hxmem
      · rw [Finset.mem_singleton.1 h]; exact hymem
  rw [hset, Finset.card_pair hxy]

end EulerTwoSquares