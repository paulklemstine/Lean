import Mathlib

/-!
# Tropical linear spaces: the vector elimination axiom

This file develops the structural core of *tropical ideal* theory in the sense of
Maclagan–Rincón: a tropical ideal is a subsemimodule of the tropical polynomial
semiring which, in each degree, is the set of vectors of a valuated matroid, i.e.
satisfies the **vector elimination axiom**.  The previous catalog file
`Catalog/Tropical/GroebnerBases.lean` treated tropical ideals purely as
`Submodule`s (tropical linear combinations only).  Here we add the missing
matroidal layer and prove that a genuinely interesting semimodule — the set of
tropical vectors *vanishing* against a fixed coefficient vector, i.e. the
tropical hyperplane — satisfies elimination.

Main results:

* `tropVanishing_isTropSemimodule` : tropical hyperplanes are subsemimodules.
* `mem_tropVanishing_iff_min_attained_twice` : the relational definition used
  here agrees with "the minimum is attained at least twice".
* `tropVanishing_elimination` : **the vector elimination axiom holds for every
  tropical hyperplane**.  This is the main theorem; the proof is a genuine
  two-case argument resting on a nontrivial rigidity lemma
  (`tropVanishing_eq_of_unique_min`).
* `tropVanishing_isTropicalLinearSpace` : consequently a tropical hyperplane is a
  tropical linear space.
* `support_elimination` : elimination plus tropical scaling yields the matroid
  (Minty) vector elimination property on supports — a bridge from tropical
  algebra to matroid combinatorics.
* `card_support_ge_two` and `exists_mem_support_eq_pair` : the underlying matroid
  of a tropical hyperplane with finite coefficients is the uniform matroid: the
  minimal supports are exactly the two-element subsets.
-/

namespace TropicalElimination

/-- The min-plus tropical semiring carrier: rationals with `⊤` as tropical zero. -/
abbrev TT := WithTop ℚ

variable {E : Type*}

/-- Tropical (coordinatewise) addition of vectors: pointwise minimum. -/
def tropAdd (x y : E → TT) : E → TT := fun i => min (x i) (y i)

/-- Tropical scalar multiplication: pointwise addition of a constant. -/
def tropSMul (a : TT) (x : E → TT) : E → TT := fun i => a + x i

/-- The tropical zero vector, all coordinates `⊤`. -/
def tropZero (E : Type*) : E → TT := fun _ => ⊤

/-- A set of tropical vectors that is a subsemimodule: it contains the tropical
zero and is closed under tropical addition and tropical scaling. -/
structure IsTropSemimodule (V : Set (E → TT)) : Prop where
  zero_mem : tropZero E ∈ V
  add_mem : ∀ {x y}, x ∈ V → y ∈ V → tropAdd x y ∈ V
  smul_mem : ∀ (a : TT) {x}, x ∈ V → tropSMul a x ∈ V

/-- The valuated-matroid **vector elimination axiom**: given two members agreeing
at a coordinate `e` where they are both nonzero, some member is `⊤` at `e`,
dominates their tropical sum, and is *equal* to the tropical sum at every
coordinate where the two differ. -/
def SatisfiesElimination (V : Set (E → TT)) : Prop :=
  ∀ x ∈ V, ∀ y ∈ V, ∀ e : E, x e = y e → x e ≠ ⊤ →
    ∃ z ∈ V, z e = ⊤ ∧ (∀ i, min (x i) (y i) ≤ z i) ∧
      ∀ i, x i ≠ y i → z i = min (x i) (y i)

/-- A tropical linear space: a subsemimodule of tropical vectors satisfying the
vector elimination axiom. -/
structure IsTropicalLinearSpace (V : Set (E → TT)) : Prop where
  semimodule : IsTropSemimodule V
  elimination : SatisfiesElimination V

/-- The tropical hyperplane attached to a coefficient vector `c`: the set of
tropical vectors `x` such that for each coordinate `i` some other coordinate `j`
has value at most that of `i`.  Over a finite index set this says exactly that
the minimum of `c i + x i` is attained at least twice. -/
def tropVanishing (c : E → TT) : Set (E → TT) :=
  {x | ∀ i, ∃ j, j ≠ i ∧ c j + x j ≤ c i + x i}

/-- The support of a tropical vector: the coordinates that are not tropically
zero. -/
def supp (x : E → TT) : Set E := {i | x i ≠ ⊤}

section Semimodule

variable [Nontrivial E] (c : E → TT)

theorem tropZero_mem_tropVanishing : tropZero E ∈ tropVanishing c := by
  intro i
  obtain ⟨j, hj⟩ := exists_ne i
  exact ⟨j, hj, by simp [tropZero]⟩

omit [Nontrivial E] in
theorem tropAdd_mem_tropVanishing {x y : E → TT} (hx : x ∈ tropVanishing c)
    (hy : y ∈ tropVanishing c) : tropAdd x y ∈ tropVanishing c := by
  intro i
  rcases le_total (x i) (y i) with h | h
  · obtain ⟨j, hj, hle⟩ := hx i
    refine ⟨j, hj, ?_⟩
    have h1 : c j + min (x j) (y j) ≤ c j + x j := by gcongr; exact min_le_left _ _
    have h2 : c i + min (x i) (y i) = c i + x i := by rw [min_eq_left h]
    simp only [tropAdd]
    rw [h2]
    exact h1.trans hle
  · obtain ⟨j, hj, hle⟩ := hy i
    refine ⟨j, hj, ?_⟩
    have h1 : c j + min (x j) (y j) ≤ c j + y j := by gcongr; exact min_le_right _ _
    have h2 : c i + min (x i) (y i) = c i + y i := by rw [min_eq_right h]
    simp only [tropAdd]
    rw [h2]
    exact h1.trans hle

omit [Nontrivial E] in
theorem tropSMul_mem_tropVanishing (a : TT) {x : E → TT} (hx : x ∈ tropVanishing c) :
    tropSMul a x ∈ tropVanishing c := by
  intro i
  obtain ⟨j, hj, hle⟩ := hx i
  refine ⟨j, hj, ?_⟩
  simp only [tropSMul]
  calc c j + (a + x j) = a + (c j + x j) := by simp [add_left_comm]
    _ ≤ a + (c i + x i) := by gcongr
    _ = c i + (a + x i) := by simp [add_left_comm]

/-- Tropical hyperplanes are subsemimodules of the tropical vector semimodule. -/
theorem tropVanishing_isTropSemimodule : IsTropSemimodule (tropVanishing c) where
  zero_mem := tropZero_mem_tropVanishing c
  add_mem := tropAdd_mem_tropVanishing c
  smul_mem := tropSMul_mem_tropVanishing c

end Semimodule

section Characterisation

variable [Fintype E] [Nonempty E] (c : E → TT)

/-- Over a finite index set, membership in `tropVanishing c` is exactly the
classical tropical vanishing condition: the minimum of `c i + x i` is attained at
least twice. -/
theorem mem_tropVanishing_iff_min_attained_twice (x : E → TT) :
    x ∈ tropVanishing c ↔
      ∃ i j, i ≠ j ∧ (∀ k, c i + x i ≤ c k + x k) ∧ c j + x j = c i + x i := by
  constructor
  · intro hx
    obtain ⟨i, -, hi⟩ :=
      Finset.exists_min_image (Finset.univ : Finset E) (fun k => c k + x k)
        (Finset.univ_nonempty)
    obtain ⟨j, hji, hle⟩ := hx i
    exact ⟨i, j, (Ne.symm hji), fun k => hi k (Finset.mem_univ k),
      le_antisymm hle (hi j (Finset.mem_univ j))⟩
  · rintro ⟨i, j, hij, hmin, hval⟩ k
    by_cases hk : k = i
    · subst hk
      exact ⟨j, Ne.symm hij, le_of_eq hval⟩
    · exact ⟨i, fun h => hk h.symm, hmin k⟩

end Characterisation

section Elimination

variable [Fintype E] [DecidableEq E] [Nontrivial E]

omit [Fintype E] [Nontrivial E] in
/-- **Rigidity lemma** (ordered version).  Suppose the tropical sum of two
members of a tropical hyperplane, with the coordinate `e` deleted, has a
*strictly* unique minimal coordinate `i₀`.  Then the two members already agree at
`i₀`.  This is the combinatorial heart of the elimination theorem: the forced
part of the eliminated vector can never have a lonely minimum at a coordinate
where the two inputs differ. -/
theorem tropVanishing_eq_of_unique_min_aux (c : E → TT) {x y : E → TT}
    (hx : x ∈ tropVanishing c) (hy : y ∈ tropVanishing c) {e i₀ : E}
    (hi₀e : i₀ ≠ e) (hxye : x e = y e)
    (hmin : ∀ j, j ≠ i₀ →
      c i₀ + min (x i₀) (y i₀) < c j + (if j = e then ⊤ else min (x j) (y j)))
    (hle : x i₀ ≤ y i₀) : x i₀ = y i₀ := by
  by_contra hne
  have hlt : x i₀ < y i₀ := lt_of_le_of_ne hle hne
  have hmin_eq : min (x i₀) (y i₀) = x i₀ := min_eq_left hle
  -- `α` is the forced value at `i₀`; it is finite since it is `< ⊤`
  have hαtop : c i₀ + min (x i₀) (y i₀) ≠ ⊤ := by
    have h := hmin e (fun h => hi₀e h.symm)
    rw [if_pos rfl, add_top] at h
    exact ne_top_of_lt h
  have hci₀ : c i₀ ≠ ⊤ := by
    intro h; apply hαtop; rw [h, top_add]
  -- from `x ∈ V` at `i₀`, the only possible competitor is `e`
  obtain ⟨j, hj, hjle⟩ := hx i₀
  have hjxle : c j + x j ≤ c i₀ + min (x i₀) (y i₀) := by rw [hmin_eq]; exact hjle
  have hje : j = e := by
    by_contra hjne
    have h1 := hmin j hj
    rw [if_neg hjne] at h1
    have h2 : c j + min (x j) (y j) ≤ c j + x j := by gcongr; exact min_le_left _ _
    exact absurd (h2.trans hjxle) (not_le.mpr h1)
  have hexle : c e + x e ≤ c i₀ + min (x i₀) (y i₀) := by rw [← hje]; exact hjxle
  -- from `y ∈ V` at `e`, the only possible competitor is `i₀`
  obtain ⟨j', hj', hj'le⟩ := hy e
  have hj'yle : c j' + y j' ≤ c i₀ + min (x i₀) (y i₀) :=
    hj'le.trans (by rw [← hxye]; exact hexle)
  have hj'i : j' = i₀ := by
    by_contra hj'ne
    have h1 := hmin j' hj'ne
    rw [if_neg hj'] at h1
    have h2 : c j' + min (x j') (y j') ≤ c j' + y j' := by gcongr; exact min_le_right _ _
    exact absurd (h2.trans hj'yle) (not_le.mpr h1)
  rw [hj'i, hmin_eq] at hj'yle
  exact absurd hj'yle (not_le.mpr ((WithTop.add_lt_add_iff_left hci₀).mpr hlt))

omit [Fintype E] [Nontrivial E] in
/-- **Rigidity lemma.**  Symmetric form of `tropVanishing_eq_of_unique_min_aux`. -/
theorem tropVanishing_eq_of_unique_min (c : E → TT) {x y : E → TT}
    (hx : x ∈ tropVanishing c) (hy : y ∈ tropVanishing c) {e i₀ : E}
    (hi₀e : i₀ ≠ e) (hxye : x e = y e)
    (hmin : ∀ j, j ≠ i₀ →
      c i₀ + min (x i₀) (y i₀) < c j + (if j = e then ⊤ else min (x j) (y j))) :
    x i₀ = y i₀ := by
  rcases le_total (x i₀) (y i₀) with h | h
  · exact tropVanishing_eq_of_unique_min_aux c hx hy hi₀e hxye hmin h
  · refine (tropVanishing_eq_of_unique_min_aux c hy hx hi₀e hxye.symm ?_ h).symm
    intro j hj
    rw [min_comm (y i₀) (x i₀), min_comm (y j) (x j)]
    exact hmin j hj

/-- **Main theorem: tropical hyperplanes satisfy the vector elimination axiom.**

Given `x, y` vanishing against `c` and a coordinate `e` where they agree with a
finite value, one can eliminate `e`: there is a vanishing `z` with `z e = ⊤`
dominating `min x y` and equal to it wherever `x` and `y` differ. -/
theorem tropVanishing_elimination (c : E → TT) :
    SatisfiesElimination (tropVanishing c) := by
  classical
  intro x hx y hy e hxye _hxe
  set m : E → TT := fun i => min (x i) (y i) with hm
  set z₀ : E → TT := fun i => if i = e then ⊤ else m i with hz₀
  by_cases h0 : z₀ ∈ tropVanishing c
  · refine ⟨z₀, h0, by simp [hz₀], ?_, ?_⟩
    · intro i
      by_cases hi : i = e
      · simp [hz₀, hi]
      · simp [hz₀, hi, hm]
    · intro i hi
      have hie : i ≠ e := by rintro rfl; exact hi hxye
      simp [hz₀, hie, hm]
  · -- there is a strictly unique minimum coordinate `i₀`
    simp only [tropVanishing, Set.mem_setOf_eq, not_forall] at h0
    obtain ⟨i₀, hi₀⟩ := h0
    push_neg at hi₀
    have hstrict : ∀ j, j ≠ i₀ → c i₀ + z₀ i₀ < c j + z₀ j := fun j hj => hi₀ j hj
    have hi₀e : i₀ ≠ e := by
      rintro rfl
      obtain ⟨j, hj⟩ := exists_ne i₀
      have h := hstrict j hj
      rw [show z₀ i₀ = ⊤ by simp [hz₀], add_top] at h
      exact not_top_lt h
    have hz₀i₀ : z₀ i₀ = m i₀ := by simp [hz₀, hi₀e]
    have hstrict' : ∀ j, j ≠ i₀ →
        c i₀ + min (x i₀) (y i₀) < c j + (if j = e then ⊤ else min (x j) (y j)) := by
      intro j hj
      have h := hstrict j hj
      rwa [hz₀i₀] at h
    -- so `x` and `y` agree at `i₀`
    have hagree : x i₀ = y i₀ :=
      tropVanishing_eq_of_unique_min c hx hy hi₀e hxye hstrict'
    -- the second smallest value
    have hne : (Finset.univ.erase i₀).Nonempty := by
      obtain ⟨j, hj⟩ := exists_ne i₀
      exact ⟨j, Finset.mem_erase.mpr ⟨hj, Finset.mem_univ j⟩⟩
    set β : TT := (Finset.univ.erase i₀).inf' hne (fun j => c j + z₀ j) with hβ
    obtain ⟨j₁, hj₁mem, hj₁⟩ := Finset.exists_mem_eq_inf' hne (fun j => c j + z₀ j)
    have hj₁ne : j₁ ≠ i₀ := (Finset.mem_erase.mp hj₁mem).1
    have hαβ : c i₀ + z₀ i₀ < β := by rw [hβ, hj₁]; exact hstrict j₁ hj₁ne
    have hαtop : c i₀ + z₀ i₀ ≠ ⊤ := ne_top_of_lt hαβ
    have hci₀ : c i₀ ≠ ⊤ := by intro h; apply hαtop; rw [h, top_add]
    have hmi₀ : m i₀ ≠ ⊤ := by
      intro h; apply hαtop; rw [hz₀i₀, h, add_top]
    obtain ⟨q, hq⟩ : ∃ q : ℚ, c i₀ = (q : TT) := ⟨(c i₀).untop hci₀, by simp⟩
    obtain ⟨p, hp⟩ : ∃ p : ℚ, m i₀ = (p : TT) := ⟨(m i₀).untop hmi₀, by simp⟩
    -- raise the lonely coordinate up to the level `β`
    obtain ⟨t, htm, hct⟩ : ∃ t : TT, m i₀ ≤ t ∧ c i₀ + t = β := by
      by_cases hβtop : β = ⊤
      · exact ⟨⊤, le_top, by rw [hβtop, add_top]⟩
      · obtain ⟨b, hb⟩ : ∃ b : ℚ, β = (b : TT) := ⟨β.untop hβtop, by simp⟩
        refine ⟨((b - q : ℚ) : TT), ?_, ?_⟩
        · rw [hp, WithTop.coe_le_coe]
          have hlt : ((q : TT) + (p : TT)) < (b : TT) := by
            rw [← hq, ← hp, ← hz₀i₀, ← hb]; exact hαβ
          rw [← WithTop.coe_add] at hlt
          have := WithTop.coe_lt_coe.mp hlt
          linarith
        · rw [hq, ← WithTop.coe_add, hb]
          norm_num
    refine ⟨Function.update z₀ i₀ t, ?_, ?_, ?_, ?_⟩
    · -- membership: the minimum is now attained both at `i₀` and at `j₁`
      intro i
      by_cases hi : i = i₀
      · subst hi
        refine ⟨j₁, hj₁ne, ?_⟩
        rw [Function.update_of_ne hj₁ne, Function.update_self, hct, ← hj₁]
      · refine ⟨i₀, fun h => hi h.symm, ?_⟩
        rw [Function.update_self, Function.update_of_ne hi, hct, hβ]
        exact Finset.inf'_le _ (Finset.mem_erase.mpr ⟨hi, Finset.mem_univ i⟩)
    · rw [Function.update_of_ne (Ne.symm hi₀e)]
      simp [hz₀]
    · intro i
      by_cases hi : i = i₀
      · subst hi; rw [Function.update_self]; exact htm
      · rw [Function.update_of_ne hi]
        by_cases hie : i = e
        · simp [hz₀, hie]
        · simp [hz₀, hie, hm]
    · intro i hdiff
      have hii₀ : i ≠ i₀ := by rintro rfl; exact hdiff hagree
      have hie : i ≠ e := by rintro rfl; exact hdiff hxye
      rw [Function.update_of_ne hii₀]
      simp [hz₀, hie, hm]

/-- Tropical hyperplanes are tropical linear spaces: subsemimodules satisfying
the valuated-matroid vector elimination axiom. -/
theorem tropVanishing_isTropicalLinearSpace (c : E → TT) :
    IsTropicalLinearSpace (tropVanishing c) where
  semimodule := tropVanishing_isTropSemimodule c
  elimination := tropVanishing_elimination c

end Elimination

section Matroid

variable {V : Set (E → TT)}

/-- **Matroid (Minty) elimination on supports.**  In any tropical linear space,
given two members whose supports both contain `e`, some member has support inside
the union of their supports with `e` removed.  This is the vector-elimination
axiom for the underlying matroid, obtained from the tropical axiom by first
rescaling one vector so that the two agree at `e`. -/
theorem support_elimination (hV : IsTropicalLinearSpace V) {x y : E → TT}
    (hx : x ∈ V) (hy : y ∈ V) {e : E} (hxe : e ∈ supp x) (hye : e ∈ supp y) :
    ∃ z ∈ V, supp z ⊆ (supp x ∪ supp y) \ {e} := by
  have hxe' : x e ≠ ⊤ := hxe
  have hye' : y e ≠ ⊤ := hye
  obtain ⟨p, hp⟩ : ∃ p : ℚ, x e = (p : TT) := ⟨(x e).untop hxe', by simp⟩
  obtain ⟨r, hr⟩ : ∃ r : ℚ, y e = (r : TT) := ⟨(y e).untop hye', by simp⟩
  set y' : E → TT := tropSMul ((p - r : ℚ) : TT) y with hy'
  have hy'mem : y' ∈ V := hV.semimodule.smul_mem _ hy
  have hy'e : y' e = x e := by
    rw [hy', tropSMul, hr, ← WithTop.coe_add, hp]
    norm_num
  obtain ⟨z, hzV, hze, hzge, -⟩ :=
    hV.elimination x hx y' hy'mem e hy'e.symm (by rw [hp]; exact WithTop.coe_ne_top)
  refine ⟨z, hzV, ?_⟩
  intro i hi
  have hi' : z i ≠ ⊤ := hi
  refine ⟨?_, ?_⟩
  · -- `i` lies in the union of the two supports
    by_contra hmem
    simp only [Set.mem_union, supp, Set.mem_setOf_eq, not_or, not_not] at hmem
    have hxi : x i = ⊤ := hmem.1
    have hyi : y i = ⊤ := hmem.2
    have hy'i : y' i = ⊤ := by rw [hy', tropSMul, hyi, add_top]
    have hge := hzge i
    rw [hxi, hy'i, min_self] at hge
    exact hi' (top_le_iff.mp hge)
  · simp only [Set.mem_singleton_iff]
    rintro rfl
    exact hi' hze

variable [Fintype E] [Nonempty E]

/-- In a tropical hyperplane with everywhere-finite coefficients, every nonzero
member has at least two support coordinates: the underlying matroid has no
loops. -/
theorem card_support_ge_two (c : E → TT) (hc : ∀ i, c i ≠ ⊤) {x : E → TT}
    (hx : x ∈ tropVanishing c) (hx0 : x ≠ tropZero E) :
    ∃ i j, i ≠ j ∧ x i ≠ ⊤ ∧ x j ≠ ⊤ := by
  obtain ⟨i, -, hi⟩ :=
    Finset.exists_min_image (Finset.univ : Finset E) (fun k => c k + x k) Finset.univ_nonempty
  obtain ⟨k, hk0⟩ : ∃ k, x k ≠ ⊤ := by
    by_contra h
    push_neg at h
    exact hx0 (funext fun k => h k)
  have hival : c i + x i ≠ ⊤ := by
    have hle := hi k (Finset.mem_univ k)
    have hk : c k + x k ≠ ⊤ := by
      simp only [ne_eq, WithTop.add_eq_top, not_or]
      exact ⟨hc k, hk0⟩
    exact ne_top_of_le_ne_top hk hle
  have hxi : x i ≠ ⊤ := by intro h; apply hival; rw [h, add_top]
  obtain ⟨j, hj, hjle⟩ := hx i
  have hjval : c j + x j ≠ ⊤ := ne_top_of_le_ne_top hival hjle
  have hxj : x j ≠ ⊤ := by intro h; apply hjval; rw [h, add_top]
  exact ⟨i, j, fun h => hj h.symm, hxi, hxj⟩

omit [Fintype E] [Nonempty E] in
/-- Conversely, every two-element subset is the support of a member: the
underlying matroid of a tropical hyperplane with finite coefficients is the
uniform matroid `U_{n-1,n}`, whose circuits are exactly the pairs. -/
theorem exists_mem_support_eq_pair [DecidableEq E] (c : E → TT) (hc : ∀ i, c i ≠ ⊤)
    {i j : E} (hij : i ≠ j) :
    ∃ x ∈ tropVanishing c, supp x = {i, j} := by
  classical
  obtain ⟨a, ha⟩ : ∃ a : ℚ, c i = (a : TT) := ⟨(c i).untop (hc i), by simp⟩
  obtain ⟨b, hb⟩ : ∃ b : ℚ, c j = (b : TT) := ⟨(c j).untop (hc j), by simp⟩
  set xv : E → TT :=
    fun k => if k = i then ((-a : ℚ) : TT) else if k = j then ((-b : ℚ) : TT) else ⊤ with hxv
  have hvi : c i + ((-a : ℚ) : TT) = ((0 : ℚ) : TT) := by
    rw [ha, ← WithTop.coe_add]; norm_num
  have hvj : c j + ((-b : ℚ) : TT) = ((0 : ℚ) : TT) := by
    rw [hb, ← WithTop.coe_add]; norm_num
  have hxi : xv i = ((-a : ℚ) : TT) := by simp [hxv]
  have hxj : xv j = ((-b : ℚ) : TT) := by simp [hxv, Ne.symm hij]
  have hxk : ∀ k, k ≠ i → k ≠ j → xv k = ⊤ := by
    intro k h1 h2; simp [hxv, h1, h2]
  refine ⟨xv, ?_, ?_⟩
  · intro k
    by_cases hk : k = i
    · subst hk
      exact ⟨j, Ne.symm hij, le_of_eq (by rw [hxi, hxj, hvi, hvj])⟩
    · by_cases hk' : k = j
      · subst hk'
        exact ⟨i, hij, le_of_eq (by rw [hxi, hxj, hvi, hvj])⟩
      · refine ⟨i, fun h => hk h.symm, ?_⟩
        rw [hxk k hk hk', add_top]
        exact le_top
  · ext k
    simp only [supp, Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff]
    constructor
    · intro hk
      by_contra hcon
      push_neg at hcon
      exact hk (hxk k hcon.1 hcon.2)
    · rintro (rfl | rfl)
      · rw [hxi]; exact WithTop.coe_ne_top
      · rw [hxj]; exact WithTop.coe_ne_top

end Matroid

end TropicalElimination