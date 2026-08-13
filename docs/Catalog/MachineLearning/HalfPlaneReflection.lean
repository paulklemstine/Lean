import MachineLearning.HalfPlaneCRTSeparable

/-!
# The half-plane cut: reflection identity, quadrant bound, and non-separability

The cut `x + y < N/2` uses the *integer* sum of the representatives and is therefore
**not** a CRT-separable condition.  Nevertheless the count `H(N)` is rigidly
controlled by the reflection symmetries of the circle:

* `halfPlaneCount_eq_highCount_add` :
  `H(N) = high(N) + 2 · R(N)` for `N ≥ 2`, where `high(N)` counts the circle points
  in the *opposite* corner `x + y > 3N/2` and `R(N)` is the number of square roots
  of `1` below `N/2` (the "axis" points `(0, u)` and `(u, 0)`).
  The bijection is the antipodal map `(x, y) ↦ (N - x, N - y)`.

* `four_mul_highCount_le_circleCount` :
  `4 · high(N) ≤ C(N)`, via four pairwise disjoint copies of the corner
  produced by the reflection group `⟨x ↦ N - x, y ↦ N - y⟩`.

* `four_mul_halfPlaneCount_le` :
  `4 · H(N) ≤ C(N) + 8 · R(N)`, i.e. `H` is at most a quarter of the circle count
  up to the (tiny, `2^ω(N)`-sized) square-root-of-unity correction.

* `halfPlaneCount_not_multiplicative` : `H` is **not** CRT-separable:
  `H(35) = 6 ≠ 4 = H(5) · H(7)`, while `C(35) = C(5) · C(7)`.
  This is the formal statement of the "classification boundary".
-/

namespace HalfPlane

open Finset

/-! ### The low, high, inner and axis parts of the circle -/

/-- Circle points in the low half-plane `2(x+y) < N`. -/
def lowFinset (N : ℕ) : Finset (ℕ × ℕ) :=
  (circleFinset N).filter (fun p => 2 * (p.1 + p.2) < N)

/-- Circle points in the opposite corner `2(x+y) > 3N`. -/
def highFinset (N : ℕ) : Finset (ℕ × ℕ) :=
  (circleFinset N).filter (fun p => 3 * N < 2 * (p.1 + p.2))

/-- Low points off the coordinate axes. -/
def lowInner (N : ℕ) : Finset (ℕ × ℕ) :=
  (lowFinset N).filter (fun p => 1 ≤ p.1 ∧ 1 ≤ p.2)

/-- Low points on a coordinate axis. -/
def lowAxis (N : ℕ) : Finset (ℕ × ℕ) :=
  (lowFinset N).filter (fun p => ¬ (1 ≤ p.1 ∧ 1 ≤ p.2))

/-- Square roots of `1` modulo `N` lying below `N/2`. -/
def unitRootFinset (N : ℕ) : Finset ℕ :=
  (Finset.range N).filter (fun u => 2 * u < N ∧ u ^ 2 % N = 1 % N)

lemma halfPlaneCount_eq_card_low (N : ℕ) : halfPlaneCount N = (lowFinset N).card := rfl

lemma highCount_eq_card_high (N : ℕ) : highCount N = (highFinset N).card := rfl

lemma unitRootCount_eq_card (N : ℕ) : unitRootCount N = (unitRootFinset N).card := rfl

lemma mem_lowFinset {N : ℕ} {p : ℕ × ℕ} :
    p ∈ lowFinset N ↔ (p.1 < N ∧ p.2 < N ∧ (p.1 ^ 2 + p.2 ^ 2) % N = 1 % N)
      ∧ 2 * (p.1 + p.2) < N := by
  simp [lowFinset, Finset.mem_filter, mem_circleFinset]

lemma mem_highFinset {N : ℕ} {p : ℕ × ℕ} :
    p ∈ highFinset N ↔ (p.1 < N ∧ p.2 < N ∧ (p.1 ^ 2 + p.2 ^ 2) % N = 1 % N)
      ∧ 3 * N < 2 * (p.1 + p.2) := by
  simp [highFinset, Finset.mem_filter, mem_circleFinset]

/-! ### Reflecting one coordinate preserves the circle -/

/-- Replacing `a` by `N - a` does not change the value of `a²` modulo `N`. -/
lemma circle_reflect_fst {N a b : ℕ} [NeZero N] (ha : a ≤ N) :
    (((N - a) ^ 2 + b ^ 2) % N = 1 % N) ↔ ((a ^ 2 + b ^ 2) % N = 1 % N) := by
  rw [circle_cast_iff, circle_cast_iff]
  have hcast : ((N - a : ℕ) : ZMod N) = -(a : ZMod N) := by
    rw [Nat.cast_sub ha]
    simp
  rw [hcast]
  ring_nf

lemma circle_reflect_snd {N a b : ℕ} [NeZero N] (hb : b ≤ N) :
    ((a ^ 2 + (N - b) ^ 2) % N = 1 % N) ↔ ((a ^ 2 + b ^ 2) % N = 1 % N) := by
  rw [circle_cast_iff, circle_cast_iff]
  have hcast : ((N - b : ℕ) : ZMod N) = -(b : ZMod N) := by
    rw [Nat.cast_sub hb]
    simp
  rw [hcast]
  ring_nf

/-! ### The antipodal bijection between the inner low set and the high corner -/

/-- Points of the high corner have both coordinates above `N/2`. -/
lemma high_coord_bounds {N : ℕ} {p : ℕ × ℕ} (hp : p ∈ highFinset N) :
    N < 2 * p.1 ∧ N < 2 * p.2 := by
  rw [mem_highFinset] at hp
  obtain ⟨⟨h1, h2, _⟩, h3⟩ := hp
  omega

/-- **Antipodal reflection**: the inner low set and the high corner are equinumerous. -/
theorem card_lowInner_eq_card_high (N : ℕ) [NeZero N] :
    (lowInner N).card = (highFinset N).card := by
  have hN : 0 < N := Nat.pos_of_ne_zero (NeZero.ne N)
  refine Finset.card_bij'
    (fun p _ => (N - p.1, N - p.2))
    (fun p _ => (N - p.1, N - p.2))
    ?_ ?_ ?_ ?_
  · intro p hp
    simp only [lowInner, Finset.mem_filter, mem_lowFinset] at hp
    obtain ⟨⟨⟨h1, h2, hc⟩, hs⟩, hx1, hy1⟩ := hp
    rw [mem_highFinset]
    dsimp only
    refine ⟨⟨by omega, by omega, ?_⟩, by omega⟩
    rw [circle_reflect_fst (by omega), circle_reflect_snd (by omega)]
    exact hc
  · intro p hp
    have hb := high_coord_bounds hp
    rw [mem_highFinset] at hp
    obtain ⟨⟨h1, h2, hc⟩, hs⟩ := hp
    simp only [lowInner, Finset.mem_filter, mem_lowFinset]
    refine ⟨⟨⟨by omega, by omega, ?_⟩, by omega⟩, by omega, by omega⟩
    rw [circle_reflect_fst (by omega), circle_reflect_snd (by omega)]
    exact hc
  · intro p hp
    simp only [lowInner, Finset.mem_filter, mem_lowFinset] at hp
    obtain ⟨⟨⟨h1, h2, _⟩, _⟩, _, _⟩ := hp
    exact Prod.ext (by simp; omega) (by simp; omega)
  · intro p hp
    rw [mem_highFinset] at hp
    obtain ⟨⟨h1, h2, _⟩, _⟩ := hp
    exact Prod.ext (by simp; omega) (by simp; omega)

/-! ### The axis part -/

/-- The axis part of the low half-plane consists of the two families `(0,u)` and `(u,0)`
with `u` a square root of `1` below `N/2`. -/
theorem card_lowAxis (N : ℕ) (hN : 2 ≤ N) :
    (lowAxis N).card = 2 * unitRootCount N := by
  classical
  have hsplit : lowAxis N =
      (unitRootFinset N).image (fun u => ((0 : ℕ), u))
        ∪ (unitRootFinset N).image (fun u => (u, (0 : ℕ))) := by
    ext p
    simp only [lowAxis, Finset.mem_filter, mem_lowFinset, Finset.mem_union,
      Finset.mem_image, unitRootFinset, Finset.mem_range]
    constructor
    · rintro ⟨⟨⟨h1, h2, hc⟩, hs⟩, hax⟩
      rcases Nat.eq_zero_or_pos p.1 with hx | hx
      · left
        refine ⟨p.2, ⟨h2, by omega, ?_⟩, ?_⟩
        · rw [hx] at hc; simpa using hc
        · exact Prod.ext (by simpa using hx.symm) rfl
      · have hy : p.2 = 0 := by omega
        right
        refine ⟨p.1, ⟨h1, by omega, ?_⟩, ?_⟩
        · rw [hy] at hc; simpa using hc
        · exact Prod.ext rfl (by simpa using hy.symm)
    · rintro (⟨u, ⟨hu1, hu2, hu3⟩, rfl⟩ | ⟨u, ⟨hu1, hu2, hu3⟩, rfl⟩)
      · exact ⟨⟨⟨by omega, hu1, by simpa using hu3⟩, by simpa using hu2⟩, by simp⟩
      · exact ⟨⟨⟨hu1, by omega, by simpa using hu3⟩, by simpa using hu2⟩, by simp⟩
  have hdisj : Disjoint ((unitRootFinset N).image (fun u => ((0 : ℕ), u)))
      ((unitRootFinset N).image (fun u => (u, (0 : ℕ)))) := by
    rw [Finset.disjoint_left]
    rintro p hp hq
    simp only [Finset.mem_image, unitRootFinset, Finset.mem_filter, Finset.mem_range] at hp hq
    obtain ⟨u, ⟨_, _, hu⟩, rfl⟩ := hp
    obtain ⟨v, ⟨_, _, hv⟩, hveq⟩ := hq
    have hv0 : v = 0 := by
      have h := congrArg Prod.fst hveq
      simp only at h
      omega
    have h1N : 1 % N = 1 := Nat.mod_eq_of_lt (by omega)
    rw [hv0] at hv
    norm_num [h1N] at hv
  have hinj1 : ((unitRootFinset N).image (fun u => ((0 : ℕ), u))).card
      = (unitRootFinset N).card :=
    Finset.card_image_of_injective _ (fun a b hab => by simpa using congrArg Prod.snd hab)
  have hinj2 : ((unitRootFinset N).image (fun u => (u, (0 : ℕ)))).card
      = (unitRootFinset N).card :=
    Finset.card_image_of_injective _ (fun a b hab => by simpa using congrArg Prod.fst hab)
  rw [hsplit, Finset.card_union_of_disjoint hdisj, hinj1, hinj2, unitRootCount_eq_card]
  ring

/-! ### The reflection identity -/

/-- **Reflection identity**: `H(N) = high(N) + 2 R(N)` for `N ≥ 2`.

The low half-plane splits into an inner part, which the antipodal map matches
bijectively with the opposite corner, and the axis part, which consists of the
`2 R(N)` points `(0,u)`, `(u,0)` with `u² ≡ 1` and `2u < N`. -/
theorem halfPlaneCount_eq_highCount_add (N : ℕ) (hN : 2 ≤ N) :
    halfPlaneCount N = highCount N + 2 * unitRootCount N := by
  haveI : NeZero N := ⟨by omega⟩
  have hpart : (lowInner N).card + (lowAxis N).card = (lowFinset N).card := by
    simpa [lowInner, lowAxis] using
      (Finset.card_filter_add_card_filter_not (s := lowFinset N)
        (p := fun p => 1 ≤ p.1 ∧ 1 ≤ p.2))
  rw [halfPlaneCount_eq_card_low, ← hpart, card_lowInner_eq_card_high,
    card_lowAxis N hN, highCount_eq_card_high]

/-! ### The quadrant bound -/

/-- Four pairwise disjoint reflected copies of the high corner fit inside the circle,
hence `4 · high(N) ≤ C(N)`. -/
theorem four_mul_highCount_le_circleCount (N : ℕ) (hN : 0 < N) :
    4 * highCount N ≤ circleCount N := by
  haveI : NeZero N := ⟨by omega⟩
  classical
  set Hs := highFinset N with hHs
  set S1 := Hs with hS1
  set S2 := Hs.image (fun p => (N - p.1, N - p.2)) with hS2
  set S3 := Hs.image (fun p => (N - p.1, p.2)) with hS3
  set S4 := Hs.image (fun p => (p.1, N - p.2)) with hS4
  -- coordinate information for each block
  have hmem1 : ∀ p ∈ S1, N < 2 * p.1 ∧ N < 2 * p.2 ∧ p ∈ circleFinset N := by
    intro p hp
    refine ⟨(high_coord_bounds hp).1, (high_coord_bounds hp).2, ?_⟩
    exact Finset.mem_of_mem_filter _ hp
  have hmem2 : ∀ p ∈ S2, 2 * p.1 < N ∧ 2 * p.2 < N ∧ p ∈ circleFinset N := by
    intro p hp
    rw [hS2, Finset.mem_image] at hp
    obtain ⟨q, hq, rfl⟩ := hp
    have hb := high_coord_bounds hq
    rw [mem_highFinset] at hq
    obtain ⟨⟨h1, h2, hc⟩, hs⟩ := hq
    refine ⟨by omega, by omega, ?_⟩
    rw [mem_circleFinset]
    refine ⟨by omega, by omega, ?_⟩
    rw [circle_reflect_fst (by omega), circle_reflect_snd (by omega)]
    exact hc
  have hmem3 : ∀ p ∈ S3, 2 * p.1 < N ∧ N < 2 * p.2 ∧ p ∈ circleFinset N := by
    intro p hp
    rw [hS3, Finset.mem_image] at hp
    obtain ⟨q, hq, rfl⟩ := hp
    have hb := high_coord_bounds hq
    rw [mem_highFinset] at hq
    obtain ⟨⟨h1, h2, hc⟩, hs⟩ := hq
    refine ⟨by omega, by omega, ?_⟩
    rw [mem_circleFinset]
    refine ⟨by omega, by omega, ?_⟩
    rw [circle_reflect_fst (by omega)]
    exact hc
  have hmem4 : ∀ p ∈ S4, N < 2 * p.1 ∧ 2 * p.2 < N ∧ p ∈ circleFinset N := by
    intro p hp
    rw [hS4, Finset.mem_image] at hp
    obtain ⟨q, hq, rfl⟩ := hp
    have hb := high_coord_bounds hq
    rw [mem_highFinset] at hq
    obtain ⟨⟨h1, h2, hc⟩, hs⟩ := hq
    refine ⟨by omega, by omega, ?_⟩
    rw [mem_circleFinset]
    refine ⟨by omega, by omega, ?_⟩
    rw [circle_reflect_snd (by omega)]
    exact hc
  -- all four blocks have the same cardinality
  have hcard2 : S2.card = Hs.card := by
    refine Finset.card_image_of_injOn ?_
    intro a ha b hb hab
    have ha' := mem_highFinset.mp ha
    have hb' := mem_highFinset.mp hb
    have e1 : N - a.1 = N - b.1 := by simpa using congrArg Prod.fst hab
    have e2 : N - a.2 = N - b.2 := by simpa using congrArg Prod.snd hab
    exact Prod.ext (by omega) (by omega)
  have hcard3 : S3.card = Hs.card := by
    refine Finset.card_image_of_injOn ?_
    intro a ha b hb hab
    have ha' := mem_highFinset.mp ha
    have hb' := mem_highFinset.mp hb
    have e1 : N - a.1 = N - b.1 := by simpa using congrArg Prod.fst hab
    have e2 : a.2 = b.2 := by simpa using congrArg Prod.snd hab
    exact Prod.ext (by omega) e2
  have hcard4 : S4.card = Hs.card := by
    refine Finset.card_image_of_injOn ?_
    intro a ha b hb hab
    have ha' := mem_highFinset.mp ha
    have hb' := mem_highFinset.mp hb
    have e1 : a.1 = b.1 := by simpa using congrArg Prod.fst hab
    have e2 : N - a.2 = N - b.2 := by simpa using congrArg Prod.snd hab
    exact Prod.ext e1 (by omega)
  -- pairwise disjointness, read off from the coordinate information
  have d12 : Disjoint S1 S2 := by
    rw [Finset.disjoint_left]; intro p h1 h2
    have := hmem1 p h1; have := hmem2 p h2; omega
  have d13 : Disjoint S1 S3 := by
    rw [Finset.disjoint_left]; intro p h1 h3
    have := hmem1 p h1; have := hmem3 p h3; omega
  have d14 : Disjoint S1 S4 := by
    rw [Finset.disjoint_left]; intro p h1 h4
    have := hmem1 p h1; have := hmem4 p h4; omega
  have d23 : Disjoint S2 S3 := by
    rw [Finset.disjoint_left]; intro p h2 h3
    have := hmem2 p h2; have := hmem3 p h3; omega
  have d24 : Disjoint S2 S4 := by
    rw [Finset.disjoint_left]; intro p h2 h4
    have := hmem2 p h2; have := hmem4 p h4; omega
  have d34 : Disjoint S3 S4 := by
    rw [Finset.disjoint_left]; intro p h3 h4
    have := hmem3 p h3; have := hmem4 p h4; omega
  have hsub : S1 ∪ S2 ∪ S3 ∪ S4 ⊆ circleFinset N := by
    intro p hp
    simp only [Finset.mem_union] at hp
    rcases hp with ((h | h) | h) | h
    · exact (hmem1 p h).2.2
    · exact (hmem2 p h).2.2
    · exact (hmem3 p h).2.2
    · exact (hmem4 p h).2.2
  have hcardU : (S1 ∪ S2 ∪ S3 ∪ S4).card = 4 * Hs.card := by
    rw [Finset.card_union_of_disjoint, Finset.card_union_of_disjoint,
      Finset.card_union_of_disjoint d12, hcard2, hcard3, hcard4]
    · ring
    · rw [Finset.disjoint_union_left]; exact ⟨d13, d23⟩
    · rw [Finset.disjoint_union_left, Finset.disjoint_union_left]
      exact ⟨⟨d14, d24⟩, d34⟩
  calc 4 * highCount N = (S1 ∪ S2 ∪ S3 ∪ S4).card := by
        rw [hcardU, highCount_eq_card_high]
    _ ≤ (circleFinset N).card := Finset.card_le_card hsub
    _ = circleCount N := rfl

/-- **The half-plane count is at most a quarter of the circle count**, up to the
square-root-of-unity correction: `4 H(N) ≤ C(N) + 8 R(N)`. -/
theorem four_mul_halfPlaneCount_le (N : ℕ) (hN : 2 ≤ N) :
    4 * halfPlaneCount N ≤ circleCount N + 8 * unitRootCount N := by
  have h := halfPlaneCount_eq_highCount_add N hN
  have h4 := four_mul_highCount_le_circleCount N (by omega)
  omega

/-! ### Non-separability of the half-plane count

The circle count is a product of local factors; the half-plane count is not. -/

/-- `C` is separable at `35 = 5 · 7`. -/
theorem circleCount_35 : circleCount 35 = circleCount 5 * circleCount 7 := by decide

/-- **The half-plane count is not CRT-separable**: `H(35) = 6` but `H(5)·H(7) = 4`. -/
theorem halfPlaneCount_not_multiplicative :
    Nat.Coprime 5 7 ∧ halfPlaneCount (5 * 7) ≠ halfPlaneCount 5 * halfPlaneCount 7 := by
  refine ⟨by decide, ?_⟩
  have h1 : halfPlaneCount (5 * 7) = 6 := by decide
  have h2 : halfPlaneCount 5 * halfPlaneCount 7 = 4 := by decide
  omega

/-- The defect is not an artefact of one example: at `33 = 3 · 11` the half-plane
count exceeds the product of its local counterparts as well. -/
theorem halfPlaneCount_not_multiplicative_33 :
    halfPlaneCount (3 * 11) = 8 ∧ halfPlaneCount 3 * halfPlaneCount 11 = 4 := by
  constructor
  · decide
  · decide

/-! ### Lab notes: the reflection identity in action

```
N        : 15  16  17  20  21  24  25  28  33  35
H(N)     :  4   6   3   6   4  12   6  10   8   6
high(N)  :  0   2   1   2   0   4   4   6   4   2
R(N)     :  2   2   1   2   2   4   1   2   2   2
4·high   :  0   8   4   8   0  16  16  24  16   8
C(N)     : 16  32  16  32  32  64  20  64  48  32
```
Each column satisfies `H = high + 2R` and `4·high ≤ C`.
-/

example : halfPlaneCount 24 = highCount 24 + 2 * unitRootCount 24 := by decide
example : 4 * highCount 28 ≤ circleCount 28 := by decide

end HalfPlane