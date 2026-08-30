import Catalog.Cryptography.SurrealOrderTopology

/-!
# The surreal line is totally separated

The order topology on `Surreal` is densely ordered, hence has no isolated points, yet we
show here that it is **totally separated**: any two distinct surreals are separated by a
clopen partition of the whole line.  The separating clopen set is the *archimedean-class
cut*

`smallerPart x d = {z | ∀ n, z - x < d * powHalf n}`,

the set of surreals whose distance above `x` is infinitesimal compared with `d`.  It is
downward closed with no greatest element (using positivity of `2 ⬝ powHalf (n+1) = powHalf n`
and, for the degenerate case, a positive surreal infinitesimal relative to `d`, produced by
the Conway cut `{0 | d·powHalf n}`), while its complement is upward closed with no least
element.  In an order topology this makes it clopen.

This is a genuinely "cross-domain" statement: the algebraic dyadic structure of the
surreals (`Surreal.powHalf`, from `Mathlib.SetTheory.Surreal.Dyadic`) feeds directly into a
topological separation theorem, and it complements the local-character results in
`Catalog.Cryptography.SurrealLocalCharacter`: the surreal line is simultaneously dense (so
not discrete), sequentially discrete, of uncountable character everywhere, and totally
disconnected.
-/

open SetTheory PGame Filter Set Topology

/-! ## Generic order-topology criteria for openness -/

section OrderTopologyGeneric

variable {α : Type*} [LinearOrder α] [TopologicalSpace α] [OrderTopology α]

/-- A downward-closed set without a greatest element is open. -/
theorem isOpen_of_isLowerSet_of_no_max {S : Set α}
    (hdown : ∀ ⦃a b : α⦄, a ≤ b → b ∈ S → a ∈ S) (hnomax : ∀ a ∈ S, ∃ b ∈ S, a < b) :
    IsOpen S := by
  have hS : S = ⋃ z ∈ S, Iio z := by
    ext a
    constructor
    · intro ha
      obtain ⟨b, hb, hab⟩ := hnomax a ha
      exact mem_biUnion hb hab
    · rintro ha
      obtain ⟨z, hz, haz⟩ := mem_iUnion₂.1 ha
      exact hdown haz.le hz
  rw [hS]
  exact isOpen_biUnion fun _ _ => isOpen_Iio

/-- An upward-closed set without a least element is open. -/
theorem isOpen_of_isUpperSet_of_no_min {S : Set α}
    (hup : ∀ ⦃a b : α⦄, a ≤ b → a ∈ S → b ∈ S) (hnomin : ∀ a ∈ S, ∃ b ∈ S, b < a) :
    IsOpen S := by
  have hS : S = ⋃ z ∈ S, Ioi z := by
    ext a
    constructor
    · intro ha
      obtain ⟨b, hb, hab⟩ := hnomin a ha
      exact mem_biUnion hb hab
    · rintro ha
      obtain ⟨z, hz, haz⟩ := mem_iUnion₂.1 ha
      exact hup haz.le hz
  rw [hS]
  exact isOpen_biUnion fun _ _ => isOpen_Ioi

end OrderTopologyGeneric

namespace Surreal

/-! ## Dyadic powers of one half -/

theorem powHalf_pos (n : ℕ) : 0 < powHalf n := by
  induction n with
  | zero => simp
  | succ n ih => nlinarith [double_powHalf_succ_eq_powHalf n, ih]

theorem powHalf_succ_lt (n : ℕ) : powHalf (n + 1) < powHalf n := by
  have h := double_powHalf_succ_eq_powHalf n
  nlinarith [powHalf_pos (n + 1)]

theorem mul_powHalf_pos {d : Surreal.{u}} (hd : 0 < d) (n : ℕ) : 0 < d * powHalf n :=
  mul_pos hd (powHalf_pos n)

theorem mul_powHalf_succ_lt {d : Surreal.{u}} (hd : 0 < d) (n : ℕ) :
    d * powHalf (n + 1) < d * powHalf n :=
  mul_lt_mul_of_pos_left (powHalf_succ_lt n) hd

theorem double_mul_powHalf_succ {d : Surreal.{u}} (n : ℕ) :
    d * powHalf (n + 1) + d * powHalf (n + 1) = d * powHalf n := by
  have h := double_powHalf_succ_eq_powHalf n
  calc d * powHalf (n + 1) + d * powHalf (n + 1) = d * (2 * powHalf (n + 1)) := by ring
    _ = d * powHalf n := by rw [h]

/-- For every positive `d` there is a positive surreal that is infinitesimal relative to
`d`: it lies below `d * powHalf n` for every `n`. -/
theorem exists_pos_lt_mul_powHalf {d : Surreal.{u}} (hd : 0 < d) :
    ∃ e : Surreal.{u}, 0 < e ∧ ∀ n : ℕ, e < d * powHalf n :=
  exists_pos_lt_seq (fun n => d * powHalf n) fun n => mul_powHalf_pos hd n

/-! ## The archimedean-class cut and total separation -/

/-- The set of surreals lying above `x` by an amount infinitesimal relative to `d`
(together with everything below `x`). -/
def smallerPart (x d : Surreal.{u}) : Set Surreal.{u} :=
  {z | ∀ n : ℕ, z - x < d * powHalf n}

theorem mem_smallerPart_self {x d : Surreal.{u}} (hd : 0 < d) : x ∈ smallerPart x d := by
  intro n
  simpa using mul_powHalf_pos hd n

theorem smallerPart_isLowerSet {x d : Surreal.{u}} ⦃a b : Surreal.{u}⦄ (hab : a ≤ b)
    (hb : b ∈ smallerPart x d) : a ∈ smallerPart x d := fun n =>
  lt_of_le_of_lt (by linarith [hab]) (hb n)

theorem smallerPart_no_max {x d : Surreal.{u}} (hd : 0 < d) (a : Surreal.{u})
    (ha : a ∈ smallerPart x d) : ∃ b ∈ smallerPart x d, a < b := by
  rcases lt_or_ge x a with hxa | hax
  · -- `a` is strictly above `x`: double the (positive) distance.
    refine ⟨x + (a - x) + (a - x), fun n => ?_, by linarith⟩
    have h1 : a - x < d * powHalf (n + 1) := ha (n + 1)
    have h2 := double_mul_powHalf_succ (d := d) n
    have : x + (a - x) + (a - x) - x = (a - x) + (a - x) := by ring
    rw [this]
    linarith
  · -- `a ≤ x`: step up to `x + e` for `e` infinitesimal relative to `d`.
    obtain ⟨e, he0, he⟩ := exists_pos_lt_mul_powHalf hd
    refine ⟨x + e, fun n => ?_, by linarith⟩
    have : x + e - x = e := by ring
    rw [this]
    exact he n

theorem compl_smallerPart_isUpperSet {x d : Surreal.{u}} ⦃a b : Surreal.{u}⦄ (hab : a ≤ b)
    (ha : a ∈ (smallerPart x d)ᶜ) : b ∈ (smallerPart x d)ᶜ := by
  simp only [smallerPart, mem_compl_iff, mem_setOf_eq, not_forall, not_lt] at ha ⊢
  obtain ⟨n, hn⟩ := ha
  exact ⟨n, by linarith⟩

theorem compl_smallerPart_no_min {x d : Surreal.{u}} (hd : 0 < d) (a : Surreal.{u})
    (ha : a ∈ (smallerPart x d)ᶜ) : ∃ b ∈ (smallerPart x d)ᶜ, b < a := by
  simp only [smallerPart, mem_compl_iff, mem_setOf_eq, not_forall, not_lt] at ha ⊢
  obtain ⟨n, hn⟩ := ha
  refine ⟨x + d * powHalf (n + 1), ⟨n + 1, by simp⟩, ?_⟩
  -- `x + d·2^{-(n+1)} < x + d·2^{-n} ≤ a`
  have hlt : d * powHalf (n + 1) < d * powHalf n := mul_powHalf_succ_lt hd n
  linarith

theorem isOpen_smallerPart {x d : Surreal.{u}} (hd : 0 < d) : IsOpen (smallerPart x d) :=
  isOpen_of_isLowerSet_of_no_max smallerPart_isLowerSet (smallerPart_no_max hd)

theorem isOpen_compl_smallerPart {x d : Surreal.{u}} (hd : 0 < d) :
    IsOpen (smallerPart x d)ᶜ :=
  isOpen_of_isUpperSet_of_no_min compl_smallerPart_isUpperSet (compl_smallerPart_no_min hd)

theorem isClopen_smallerPart {x d : Surreal.{u}} (hd : 0 < d) : IsClopen (smallerPart x d) :=
  ⟨isOpen_compl_iff.1 (isOpen_compl_smallerPart hd), isOpen_smallerPart hd⟩

/-- If `x < y` then `y` is *not* infinitesimally close to `x` at scale `y - x`. -/
theorem not_mem_smallerPart_of_lt {x y : Surreal.{u}} (hxy : x < y) :
    y ∉ smallerPart x (y - x) := by
  intro hy
  have h1 := hy 1
  have h2 := double_mul_powHalf_succ (d := y - x) 0
  have h3 : (y - x) * powHalf 0 = y - x := by simp
  have h4 : 0 < (y - x) * powHalf 1 := mul_powHalf_pos (by linarith) 1
  rw [h3] at h2
  linarith

/-- **The surreal line is totally separated**: distinct surreals are separated by a clopen
partition.  In particular (via Mathlib's instance) it is totally disconnected. -/
instance instTotallySeparatedSpace : TotallySeparatedSpace Surreal.{u} := by
  constructor
  intro x _ y _ hxy
  -- work with the smaller of the two points
  rcases lt_or_gt_of_ne hxy with h | h
  · refine ⟨smallerPart x (y - x), (smallerPart x (y - x))ᶜ, isOpen_smallerPart (by linarith),
      isOpen_compl_smallerPart (by linarith), mem_smallerPart_self (by linarith),
      not_mem_smallerPart_of_lt h, ?_, disjoint_compl_right⟩
    intro z _
    by_cases hz : z ∈ smallerPart x (y - x)
    · exact Or.inl hz
    · exact Or.inr hz
  · refine ⟨(smallerPart y (x - y))ᶜ, smallerPart y (x - y),
      isOpen_compl_smallerPart (by linarith),
      isOpen_smallerPart (by linarith), not_mem_smallerPart_of_lt h,
      mem_smallerPart_self (by linarith), ?_, ?_⟩
    · intro z _
      by_cases hz : z ∈ smallerPart y (x - y)
      · exact Or.inr hz
      · exact Or.inl hz
    · exact disjoint_compl_left

/-- The surreal line is totally disconnected, despite being densely ordered. -/
theorem totallyDisconnectedSpace : TotallyDisconnectedSpace Surreal.{u} := inferInstance

/-- The surreal line is not connected. -/
theorem not_preconnectedSpace : ¬ PreconnectedSpace Surreal.{u} := by
  intro hconn
  haveI := hconn
  have hclopen : IsClopen (smallerPart (0 : Surreal.{u}) 1) :=
    isClopen_smallerPart (by norm_num)
  have h0 : (0 : Surreal.{u}) ∈ smallerPart (0 : Surreal.{u}) 1 :=
    mem_smallerPart_self (by norm_num)
  have h1 : (1 : Surreal.{u}) ∉ smallerPart (0 : Surreal.{u}) 1 := by
    have := not_mem_smallerPart_of_lt (x := (0 : Surreal.{u})) (y := 1) (by norm_num)
    simpa using this
  rcases isClopen_iff.mp hclopen with h | h
  · rw [h] at h0; exact h0
  · rw [h] at h1; exact h1 (mem_univ _)

end Surreal