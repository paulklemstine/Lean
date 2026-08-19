import Logic.AlmostLossless.Hashing

/-!
# The exact failure probability of the planar inner-product compressor

The union bound of `AlmostLossless.collisionProb_le` charges one `1/p` per pair
of typical words.  In dimension `k = 2` the truth is *exactly* computable, and
it is strictly better whenever two pairs of typical words happen to differ by
proportional vectors: only the **projective directions** of the difference set
matter.

For a seed `a ∈ (ZMod p)²` the hash `x ↦ ⟨a,x⟩` confuses `x` and `y` iff `a`
lies on the line orthogonal to `x - y`.  Distinct projective directions give
lines meeting only at the origin, so the bad seeds form a "pencil" of `d` lines
through `0`:

`#{bad seeds} = 1 + d·(p-1)`, i.e. `P(failure) = (1 + d(p-1))/p²`,

where `d` is the number of distinct directions among the differences of typical
words (`AlmostLossless.exact_card_collides_planar`).  Since `d ≤ |T|(|T|-1)/2`,
this refines the union bound, and it is an *equality*, so the falsifiability
gate of the research thread is met with an exact figure rather than a bound.

This is a small bridge between finite projective geometry over `𝔽_p` and the
Monte-Carlo analysis of a compressor.
-/

namespace AlmostLossless

open Finset

section Planar

variable {p : ℕ} [Fact p.Prime]

/-! ## Elementary identities for the inner-product hash -/

theorem dotHom_sub {k : ℕ} (a x y : Fin k → ZMod p) :
    dotHom (x - y) a = dotHash p k a x - dotHash p k a y := by
  simp only [dotHom, dotHash, AddMonoidHom.coe_mk, ZeroHom.coe_mk, Pi.sub_apply,
    ← Finset.sum_sub_distrib]
  exact Finset.sum_congr rfl fun i _ => by ring

theorem dotHom_smul {k : ℕ} (c : ZMod p) (z a : Fin k → ZMod p) :
    dotHom (c • z) a = c * dotHom z a := by
  simp only [dotHom, AddMonoidHom.coe_mk, ZeroHom.coe_mk, Pi.smul_apply, smul_eq_mul,
    Finset.mul_sum]
  exact Finset.sum_congr rfl fun i _ => by ring

/-- The line of seeds orthogonal to `z`. -/
def orth (z : Fin 2 → ZMod p) : Finset (Fin 2 → ZMod p) := {a | dotHom z a = 0}

/-- Each such line has exactly `p` seeds. -/
theorem card_orth {z : Fin 2 → ZMod p} (hz : z ≠ 0) : (orth z).card = p := by
  have h := card_ker_mul_card_eq (dotHom z) (surjective_dotHom hz)
  have hp : Fintype.card (ZMod p) = p := ZMod.card p
  have hcard : Fintype.card (Fin 2 → ZMod p) = p * p := by
    simp [ZMod.card, pow_two]
  rw [hp, hcard] at h
  have hppos : 0 < p := (Fact.out (p := p.Prime)).pos
  exact Nat.eq_of_mul_eq_mul_right hppos h

theorem zero_mem_orth (z : Fin 2 → ZMod p) : (0 : Fin 2 → ZMod p) ∈ orth z := by
  simp [orth, dotHom]

/-- Two non-proportional directions give lines meeting only at the origin. -/
theorem eq_zero_of_orth_two {z w : Fin 2 → ZMod p} (h : z 0 * w 1 - z 1 * w 0 ≠ 0)
    {a : Fin 2 → ZMod p} (hz : dotHom z a = 0) (hw : dotHom w a = 0) : a = 0 := by
  have hz' : a 0 * z 0 + a 1 * z 1 = 0 := by
    simpa [dotHom, Fin.sum_univ_two] using hz
  have hw' : a 0 * w 0 + a 1 * w 1 = 0 := by
    simpa [dotHom, Fin.sum_univ_two] using hw
  have h0 : a 0 * (z 0 * w 1 - z 1 * w 0) = 0 := by
    linear_combination w 1 * hz' - z 1 * hw'
  have h1 : a 1 * (z 0 * w 1 - z 1 * w 0) = 0 := by
    linear_combination z 0 * hw' - w 0 * hz'
  have ha0 : a 0 = 0 := by
    rcases mul_eq_zero.1 h0 with h' | h'
    · exact h'
    · exact absurd h' h
  have ha1 : a 1 = 0 := by
    rcases mul_eq_zero.1 h1 with h' | h'
    · exact h'
    · exact absurd h' h
  funext i
  fin_cases i
  · simpa using ha0
  · simpa using ha1

/-! ## The pencil of bad seeds -/

/-- **Exact count of bad seeds.**  If `D` is a nonempty set of pairwise
non-proportional nonzero directions, the seeds orthogonal to at least one of
them form a pencil of `|D|` lines through the origin, of total size
`1 + |D|(p-1)`. -/
theorem card_bad_seeds (D : Finset (Fin 2 → ZMod p)) (hD : D.Nonempty)
    (h0 : ∀ z ∈ D, z ≠ 0)
    (hnp : ∀ z ∈ D, ∀ w ∈ D, z ≠ w → z 0 * w 1 - z 1 * w 0 ≠ 0) :
    #{a : Fin 2 → ZMod p | ∃ z ∈ D, dotHom z a = 0} = 1 + D.card * (p - 1) := by
  classical
  have hBeq : ({a : Fin 2 → ZMod p | ∃ z ∈ D, dotHom z a = 0} : Finset _)
      = insert 0 (D.biUnion (fun z => (orth z).erase 0)) := by
    ext a
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_insert,
      Finset.mem_biUnion, Finset.mem_erase, orth]
    constructor
    · rintro ⟨z, hz, hza⟩
      by_cases ha : a = 0
      · exact Or.inl ha
      · exact Or.inr ⟨z, hz, ha, by simpa using hza⟩
    · rintro (rfl | ⟨z, hz, _, hza⟩)
      · obtain ⟨z, hz⟩ := hD
        exact ⟨z, hz, by simp [dotHom]⟩
      · exact ⟨z, hz, by simpa using hza⟩
  have hdisj : ∀ z ∈ D, ∀ w ∈ D, z ≠ w →
      Disjoint ((orth z).erase 0) ((orth w).erase 0) := by
    intro z hz w hw hzw
    rw [Finset.disjoint_left]
    intro a haz haw
    rw [Finset.mem_erase] at haz haw
    have hza : dotHom z a = 0 := by simpa [orth] using haz.2
    have hwa : dotHom w a = 0 := by simpa [orth] using haw.2
    exact haz.1 (eq_zero_of_orth_two (hnp z hz w hw hzw) hza hwa)
  have hcardU : (D.biUnion (fun z => (orth z).erase 0)).card = D.card * (p - 1) := by
    rw [Finset.card_biUnion hdisj]
    have : ∀ z ∈ D, ((orth z).erase 0).card = p - 1 := by
      intro z hz
      rw [Finset.card_erase_of_mem (zero_mem_orth z), card_orth (h0 z hz)]
    rw [Finset.sum_congr rfl this, Finset.sum_const, smul_eq_mul]
  have hnotmem : (0 : Fin 2 → ZMod p) ∉ D.biUnion (fun z => (orth z).erase 0) := by
    simp
  rw [hBeq, Finset.card_insert_of_notMem hnotmem, hcardU, Nat.add_comm]

/-! ## Exact failure probability of the planar compressor -/

/-- **Exact collision count for a typical set.**  Let `D` be a set of
representatives for the projective directions of the differences of `T`
(nonzero, pairwise non-proportional, covering every difference, and each really
occurring as a difference).  Then the number of bad seeds is exactly
`1 + |D|(p-1)` — no union bound, an identity. -/
theorem exact_card_collides_planar (T : Finset (Fin 2 → ZMod p))
    (D : Finset (Fin 2 → ZMod p)) (hD : D.Nonempty) (h0 : ∀ z ∈ D, z ≠ 0)
    (hnp : ∀ z ∈ D, ∀ w ∈ D, z ≠ w → z 0 * w 1 - z 1 * w 0 ≠ 0)
    (hcov : ∀ x ∈ T, ∀ y ∈ T, x ≠ y → ∃ z ∈ D, ∃ c : ZMod p, c ≠ 0 ∧ x - y = c • z)
    (hreal : ∀ z ∈ D, ∃ x ∈ T, ∃ y ∈ T, ∃ c : ZMod p, c ≠ 0 ∧ x - y = c • z) :
    #{a : Fin 2 → ZMod p | CollidesOn (dotHash p 2) T a} = 1 + D.card * (p - 1) := by
  classical
  have hiff : ∀ a : Fin 2 → ZMod p,
      CollidesOn (dotHash p 2) T a ↔ ∃ z ∈ D, dotHom z a = 0 := by
    intro a
    constructor
    · rintro ⟨q, hq, hcol⟩
      rw [Finset.mem_offDiag] at hq
      obtain ⟨z, hz, c, hc, hzc⟩ := hcov q.1 hq.1 q.2 hq.2.1 hq.2.2
      refine ⟨z, hz, ?_⟩
      have hd : dotHom (q.1 - q.2) a = 0 := by
        rw [dotHom_sub, hcol, sub_self]
      rw [hzc, dotHom_smul] at hd
      rcases mul_eq_zero.1 hd with h' | h'
      · exact absurd h' hc
      · exact h'
    · rintro ⟨z, hz, hza⟩
      obtain ⟨x, hx, y, hy, c, hc, hzc⟩ := hreal z hz
      have hne : x ≠ y := by
        intro hxy
        have : c • z = 0 := by rw [← hzc, hxy, sub_self]
        rcases smul_eq_zero.1 this with h' | h'
        · exact hc h'
        · exact h0 z hz h'
      refine ⟨(x, y), Finset.mem_offDiag.2 ⟨hx, hy, hne⟩, ?_⟩
      have hd : dotHom (x - y) a = 0 := by rw [hzc, dotHom_smul, hza, mul_zero]
      rw [dotHom_sub] at hd
      exact sub_eq_zero.1 hd
  have : ({a : Fin 2 → ZMod p | CollidesOn (dotHash p 2) T a} : Finset _)
      = ({a : Fin 2 → ZMod p | ∃ z ∈ D, dotHom z a = 0} : Finset _) := by
    ext a
    simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    exact hiff a
  rw [this, card_bad_seeds D hD h0 hnp]

/-- The exact Monte-Carlo failure probability of the planar compressor:
`(1 + d(p-1))/p²`, where `d` is the number of projective directions of the
difference set of `T`.  Compare the union bound `|T|(|T|-1)/p`: since
`d ≤ |T|(|T|-1)/2`, the exact value is never worse, and is strictly smaller as
soon as two differences are proportional. -/
theorem exact_collisionProb_planar (T : Finset (Fin 2 → ZMod p))
    (D : Finset (Fin 2 → ZMod p)) (hD : D.Nonempty) (h0 : ∀ z ∈ D, z ≠ 0)
    (hnp : ∀ z ∈ D, ∀ w ∈ D, z ≠ w → z 0 * w 1 - z 1 * w 0 ≠ 0)
    (hcov : ∀ x ∈ T, ∀ y ∈ T, x ≠ y → ∃ z ∈ D, ∃ c : ZMod p, c ≠ 0 ∧ x - y = c • z)
    (hreal : ∀ z ∈ D, ∃ x ∈ T, ∃ y ∈ T, ∃ c : ZMod p, c ≠ 0 ∧ x - y = c • z) :
    (#{a : Fin 2 → ZMod p | CollidesOn (dotHash p 2) T a} : ℚ)
        / (Fintype.card (Fin 2 → ZMod p) : ℚ)
      = (1 + (D.card : ℚ) * ((p : ℚ) - 1)) / (p : ℚ) ^ 2 := by
  have hppos : 0 < p := (Fact.out (p := p.Prime)).pos
  have hcount := exact_card_collides_planar T D hD h0 hnp hcov hreal
  have hcard : Fintype.card (Fin 2 → ZMod p) = p ^ 2 := by
    simp [ZMod.card, pow_two]
  rw [hcount, hcard]
  have : ((1 + D.card * (p - 1) : ℕ) : ℚ) = 1 + (D.card : ℚ) * ((p : ℚ) - 1) := by
    push_cast [Nat.cast_sub hppos]
    ring
  rw [this]
  push_cast
  ring

end Planar

/-! ## A worked example, cross-checked by exhaustive computation

The hypotheses of `exact_card_collides_planar` are satisfiable: here is a
concrete typical set over `ZMod 11`.  The count predicted by the theorem
(`1 + 3·(11-1) = 31` bad seeds out of `121`) is confirmed independently by
brute-force evaluation, which also shows the theorem is not vacuous. -/

section Example

instance : Fact (Nat.Prime 11) := ⟨by norm_num⟩

/-- A three-element typical set in `(ZMod 11)²`. -/
def exampleTypical : Finset (Fin 2 → ZMod 11) := {![1, 0], ![0, 1], ![2, 3]}

/-- Representatives of the three projective directions of its difference set. -/
def exampleDirections : Finset (Fin 2 → ZMod 11) := {![1, 10], ![10, 8], ![9, 9]}

set_option maxRecDepth 100000 in
/-- The general theorem, instantiated: exactly `1 + 3·(11-1) = 31` of the `121`
seeds are bad, i.e. the compressor fails with probability exactly `31/121`. -/
theorem example_card_collides :
    #{a : Fin 2 → ZMod 11 | CollidesOn (dotHash 11 2) exampleTypical a} = 1 + 3 * (11 - 1) := by
  have hD : exampleDirections.Nonempty := by decide
  have h := exact_card_collides_planar (p := 11) exampleTypical exampleDirections hD
    (by decide) (by decide) (by decide) (by decide)
  simpa using h

set_option maxRecDepth 1000000 in
/-- Independent brute-force confirmation of the same number, obtained by
enumerating all `121` seeds rather than by the geometric argument. -/
theorem example_card_collides_bruteForce :
    #{a : Fin 2 → ZMod 11 | CollidesOn (dotHash 11 2) exampleTypical a} = 31 := by decide

/-- The union bound for this example would only give `6/11 = 66/121`; the exact
answer is `31/121`, so the bound is loose by more than a factor of two. -/
theorem example_beats_union_bound :
    (#{a : Fin 2 → ZMod 11 | CollidesOn (dotHash 11 2) exampleTypical a} : ℚ) / 121
      < (exampleTypical.offDiag.card : ℚ) / 11 := by
  have hoff : exampleTypical.offDiag.card = 6 := by decide
  rw [example_card_collides_bruteForce, hoff]
  norm_num

end Example

end AlmostLossless