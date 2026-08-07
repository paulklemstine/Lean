import Computation.BerggrenSquareDiscriminant

/-!
# Cycle 8: alignment classes — the census of the lines through the centre is exhaustive

Cycle 7 (`BerggrenSquareDiscriminant`) proved that a rational line of the Poincaré-disk picture is
either empty or infinite, and that the line through any node is infinite.  This file closes the
loop by proving the *converse* half of Conjecture 1 of `FUTURE_DIRECTIONS.md` for the lines through
the centre: exact hyperbolic alignment with the base point `i` is **exactly** membership in a
rational conic, so the conic families of cycles 2, 6 and 7 exhaust the alignments through the
centre — nothing else can happen.

## Main results

* `alignment_iff_ratConic` — for nodes `(m₁,n₁)`, `(m₂,n₂)` with positive coordinates the
  Cayley–Menger determinant `seedDet 1 0 m₁ n₁ m₂ n₂` vanishes **iff** `(m₂,n₂)` lies on the
  rational conic `RatConic (m₁² - n₁² - 1) (m₁ n₁)`.  Alignment through the centre is a purely
  Diophantine condition, and every alignment is a conic.
* `alignmentClass_eq_ratConic` — hence the *alignment class* of a node (the set of integral nodes
  exactly collinear with it and with the centre) is precisely the positive part of one rational
  line.
* `alignmentClass_infinite`, `self_mem_alignmentClass` — every alignment class is infinite and
  contains its own node.  Combined with cycle 7: **through every node of the Berggren picture
  passes exactly one line through the centre, and it carries infinitely many nodes.**  This is the
  precise form of the visual observation that started the investigation.
* `alignment_trans`, `alignmentClass_eq_of_mem` — alignment through the centre is transitive on
  nodes, so the alignment classes partition the nodes into disjoint infinite lines; two nodes are
  aligned iff they have the same class.

## Lab notes

Alignment classes of the first few seeds, listed by their radial invariant `ϱ = (m²-n²-1)/(mn)`
and the next members of the class computed from the conic:

| node   | ϱ    | further Euclid seeds in the class     |
|--------|------|----------------------------------------|
| (2,1)  | 1    | (13,8), (34,21), (233,144), (610,377) |
| (3,2)  | 2/3  | (25,18), (111,80), (949,684)          |
| (4,3)  | 1/2  | (41,32), (260,203), (2705,2112)       |
| (5,2)  | 2    | (29,12), (169,70), (985,408)          |
| (6,5)  | 1/3  | (85,72), (870,737)                    |

Only genuine Euclid seeds (coprime, opposite parity) are listed; the classes also contain other
integral nodes — on the `ϱ = 1` line, for example, `(5,3)`, `(89,55)`, `(1597,987)`.
Every one of these classes is infinite, as `alignmentClass_infinite` now proves in general; the
discriminants `5, 40, 17, 8, 37` are all non-squares, as `radialDiscriminant_not_isSquare`
guarantees they must be.
-/

noncomputable section

namespace BerggrenHyperbolic

/-! ## 1. Alignment through the centre is a conic condition -/

/-- **Alignment is a conic condition.**  Two nodes are exactly hyperbolically collinear with the
centre `i` iff the second lies on the rational line determined by the first.  Every alignment
through the centre is therefore one of the conics of cycles 2, 6 and 7 — the census of lines through the centre is exhaustive. -/
theorem alignment_iff_ratConic (m₁ n₁ m₂ n₂ : ℤ) :
    seedDet 1 0 (m₁ : ℝ) (n₁ : ℝ) (m₂ : ℝ) (n₂ : ℝ) = 0
      ↔ RatConic (m₁ ^ 2 - n₁ ^ 2 - 1) (m₁ * n₁) (m₂, n₂) := by
  have hZ : (n₁ * m₁ * (m₂ ^ 2 - n₂ ^ 2 - 1) - n₂ * m₂ * (m₁ ^ 2 - n₁ ^ 2 - 1) = 0)
      ↔ RatConic (m₁ ^ 2 - n₁ ^ 2 - 1) (m₁ * n₁) (m₂, n₂) := by
    simp only [RatConic]
    constructor <;> intro h <;> linarith [h]
  rw [seedDet_base_eq, ← hZ]
  constructor
  · intro h
    have : ((n₁ * m₁ * (m₂ ^ 2 - n₂ ^ 2 - 1) - n₂ * m₂ * (m₁ ^ 2 - n₁ ^ 2 - 1) : ℤ) : ℝ) = 0 := by
      push_cast
      linarith [h]
    exact_mod_cast this
  · intro h
    have : ((n₁ * m₁ * (m₂ ^ 2 - n₂ ^ 2 - 1) - n₂ * m₂ * (m₁ ^ 2 - n₁ ^ 2 - 1) : ℤ) : ℝ) = 0 := by
      exact_mod_cast congrArg (fun x : ℤ => (x : ℝ)) h
    push_cast at this
    linarith [this]

/-- The alignment class of a node: all integral nodes with positive coordinates that are exactly
hyperbolically collinear with it and with the centre of the picture. -/
def alignmentClass (m n : ℤ) : Set (ℤ × ℤ) :=
  {q : ℤ × ℤ | 0 < q.1 ∧ 0 < q.2 ∧ seedDet 1 0 (m : ℝ) (n : ℝ) ((q.1 : ℤ) : ℝ) ((q.2 : ℤ) : ℝ) = 0}

/-- The alignment class of a node is exactly the positive part of its rational line. -/
theorem alignmentClass_eq_ratConic (m n : ℤ) :
    alignmentClass m n
      = {q : ℤ × ℤ | RatConic (m ^ 2 - n ^ 2 - 1) (m * n) q ∧ 0 < q.1 ∧ 0 < q.2} := by
  ext ⟨p, q⟩
  simp only [alignmentClass, Set.mem_setOf_eq]
  constructor
  · rintro ⟨hp, hq, hdet⟩
    exact ⟨(alignment_iff_ratConic m n p q).1 hdet, hp, hq⟩
  · rintro ⟨hc, hp, hq⟩
    exact ⟨hp, hq, (alignment_iff_ratConic m n p q).2 hc⟩

/-- A node belongs to its own alignment class. -/
theorem self_mem_alignmentClass {m n : ℤ} (hm : 0 < m) (hn : 0 < n) :
    (m, n) ∈ alignmentClass m n := by
  refine ⟨hm, hn, ?_⟩
  rw [seedDet_base_eq]
  ring

/-- **Every node lies on an infinite line through the centre.**  The alignment class of any node
`(m,n)` with `0 < n < m` is infinite: the straight lines visible in the Poincaré-disk picture pass
through every node and never terminate. -/
theorem alignmentClass_infinite {m n : ℤ} (hn : 0 < n) (hmn : n < m) :
    (alignmentClass m n).Infinite := by
  rw [alignmentClass_eq_ratConic m n]
  exact node_line_infinite hn hmn

/-! ## 2. Alignment classes partition the nodes -/

/-- Alignment through the centre is transitive: if `(m₂,n₂)` and `(m₃,n₃)` are both aligned with
`(m₁,n₁)` through the centre, they are aligned with each other. -/
theorem alignment_trans {m₁ n₁ m₂ n₂ m₃ n₃ : ℤ} (hm₁ : 0 < m₁) (hn₁ : 0 < n₁) (hm₂ : 0 < m₂)
    (hn₂ : 0 < n₂) (hm₃ : 0 < m₃) (hn₃ : 0 < n₃)
    (h₂ : seedDet 1 0 (m₁ : ℝ) (n₁ : ℝ) (m₂ : ℝ) (n₂ : ℝ) = 0)
    (h₃ : seedDet 1 0 (m₁ : ℝ) (n₁ : ℝ) (m₃ : ℝ) (n₃ : ℝ) = 0) :
    seedDet 1 0 (m₂ : ℝ) (n₂ : ℝ) (m₃ : ℝ) (n₃ : ℝ) = 0 := by
  have c₁ : (0 : ℝ) < (m₁ : ℝ) := by exact_mod_cast hm₁
  have c₂ : (0 : ℝ) < (n₁ : ℝ) := by exact_mod_cast hn₁
  have c₃ : (0 : ℝ) < (m₂ : ℝ) := by exact_mod_cast hm₂
  have c₄ : (0 : ℝ) < (n₂ : ℝ) := by exact_mod_cast hn₂
  have c₅ : (0 : ℝ) < (m₃ : ℝ) := by exact_mod_cast hm₃
  have c₆ : (0 : ℝ) < (n₃ : ℝ) := by exact_mod_cast hn₃
  rw [seedDet_base_eq_zero_iff_radial _ _ _ _ c₁ c₂ c₃ c₄] at h₂
  rw [seedDet_base_eq_zero_iff_radial _ _ _ _ c₁ c₂ c₅ c₆] at h₃
  rw [seedDet_base_eq_zero_iff_radial _ _ _ _ c₃ c₄ c₅ c₆, ← h₂, ← h₃]

/-- **The classes partition the nodes.**  If a node lies in the alignment class of another, the
two classes coincide; so the picture decomposes into disjoint infinite lines through the
centre. -/
theorem alignmentClass_eq_of_mem {m₁ n₁ m₂ n₂ : ℤ} (hm₁ : 0 < m₁) (hn₁ : 0 < n₁) (hm₂ : 0 < m₂)
    (hn₂ : 0 < n₂) (h : (m₂, n₂) ∈ alignmentClass m₁ n₁) :
    alignmentClass m₁ n₁ = alignmentClass m₂ n₂ := by
  obtain ⟨-, -, hdet⟩ := h
  ext ⟨p, q⟩
  simp only [alignmentClass, Set.mem_setOf_eq]
  constructor
  · rintro ⟨hp, hq, hpq⟩
    exact ⟨hp, hq, alignment_trans hm₁ hn₁ hm₂ hn₂ hp hq hdet hpq⟩
  · rintro ⟨hp, hq, hpq⟩
    exact ⟨hp, hq, alignment_trans hm₂ hn₂ hm₁ hn₁ hp hq
      (by
        have c₁ : (0 : ℝ) < (m₁ : ℝ) := by exact_mod_cast hm₁
        have c₂ : (0 : ℝ) < (n₁ : ℝ) := by exact_mod_cast hn₁
        have c₃ : (0 : ℝ) < (m₂ : ℝ) := by exact_mod_cast hm₂
        have c₄ : (0 : ℝ) < (n₂ : ℝ) := by exact_mod_cast hn₂
        rw [seedDet_base_eq_zero_iff_radial _ _ _ _ c₃ c₄ c₁ c₂]
        rw [seedDet_base_eq_zero_iff_radial _ _ _ _ c₁ c₂ c₃ c₄] at hdet
        exact hdet.symm) hpq⟩

end BerggrenHyperbolic