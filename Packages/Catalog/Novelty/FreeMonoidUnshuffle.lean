/-
# The unshuffle coproduct and shuffle/unshuffle duality

Continuation of `Novelty.FreeMonoidShuffle`.  We introduce the *unshuffle* coproduct

`Δ_⧢ (w) = Σ_{w = u ⧢ v} u ⊗ v`

defined by the recursion `Δ_⧢(a·w) = (a ⊗ 1 + 1 ⊗ a) · Δ_⧢(w)` (the unique
concatenation-algebra morphism making every letter primitive), and prove:

* `count_shuf_eq_count_unsh` : **duality** — the multiplicity of `w` in the shuffle
  `u ⧢ v` equals the multiplicity of `(u,v)` in the unshuffle of `w`.  This is the
  statement that the shuffle product and the unshuffle coproduct are transposes of one
  another for the canonical pairing on words.
* `unsh_append` : the unshuffle coproduct is multiplicative for concatenation
  (the bialgebra axiom for `(K⟨X⟩, concatenation, Δ_⧢)`).
* `unsh_coassoc` : the unshuffle coproduct is coassociative.
* `unsh_card`, `unsh_length_mem` : grading data.
-/
import Novelty.FreeMonoidShuffle

namespace FreeMonoidShuffle

variable {X : Type*}

/-! ## The unshuffle coproduct -/

/-- The unshuffle coproduct of a word: the multiset of all pairs `(u,v)` obtained by
splitting the positions of `w` into two complementary sets. -/
def unsh : List X → Multiset (List X × List X)
  | [] => {([], [])}
  | a :: w => ((unsh w).map (fun p => (a :: p.1, p.2))) + ((unsh w).map (fun p => (p.1, a :: p.2)))

@[simp] lemma unsh_nil : unsh ([] : List X) = {([], [])} := rfl

lemma unsh_cons (a : X) (w : List X) :
    unsh (a :: w) = ((unsh w).map (fun p => (a :: p.1, p.2))) +
      ((unsh w).map (fun p => (p.1, a :: p.2))) := rfl

@[simp] lemma unsh_card (w : List X) : (unsh w).card = 2 ^ w.length := by
  induction w with
  | nil => simp
  | cons a w ih => simp [unsh_cons, ih, pow_succ]; ring

lemma unsh_length_mem {w : List X} {p : List X × List X} (hp : p ∈ unsh w) :
    p.1.length + p.2.length = w.length := by
  induction w generalizing p with
  | nil => simp [unsh] at hp; simp [hp]
  | cons a w ih =>
    rw [unsh_cons] at hp
    rcases Multiset.mem_add.1 hp with h | h <;>
      · obtain ⟨y, hy, rfl⟩ := Multiset.mem_map.1 h
        have := ih hy
        simp only [List.length_cons]
        omega

/-! ## Counting lemmas -/

section Count
variable [DecidableEq X]

lemma count_map_cons (a c : X) (w : List X) (s : Multiset (List X)) :
    Multiset.count (c :: w) (s.map (a :: ·)) = if a = c then Multiset.count w s else 0 := by
  by_cases h : a = c
  · subst h
    rw [if_pos rfl]
    exact Multiset.count_map_eq_count' _ _ (fun x y hxy => by simpa using hxy) _
  · rw [if_neg h]
    refine Multiset.count_eq_zero_of_notMem ?_
    intro hmem
    obtain ⟨y, _, hy⟩ := Multiset.mem_map.1 hmem
    simp only [List.cons.injEq] at hy
    exact h hy.1

lemma count_map_consL (a c : X) (u v : List X) (s : Multiset (List X × List X)) :
    Multiset.count (c :: u, v) (s.map (fun q => (a :: q.1, q.2))) =
      if a = c then Multiset.count (u, v) s else 0 := by
  by_cases h : a = c
  · subst h
    rw [if_pos rfl]
    have : ((a :: u, v) : List X × List X) = (fun q : List X × List X => (a :: q.1, q.2)) (u, v) :=
      rfl
    rw [this]
    exact Multiset.count_map_eq_count' _ _ (fun x y hxy => by
      simp only [Prod.mk.injEq, List.cons.injEq] at hxy
      exact Prod.ext hxy.1.2 hxy.2) _
  · rw [if_neg h]
    refine Multiset.count_eq_zero_of_notMem ?_
    intro hmem
    obtain ⟨y, _, hy⟩ := Multiset.mem_map.1 hmem
    simp only [Prod.mk.injEq, List.cons.injEq] at hy
    exact h hy.1.1

lemma count_map_consR (a c : X) (u v : List X) (s : Multiset (List X × List X)) :
    Multiset.count (u, c :: v) (s.map (fun q => (q.1, a :: q.2))) =
      if a = c then Multiset.count (u, v) s else 0 := by
  by_cases h : a = c
  · subst h
    rw [if_pos rfl]
    have : ((u, a :: v) : List X × List X) = (fun q : List X × List X => (q.1, a :: q.2)) (u, v) :=
      rfl
    rw [this]
    exact Multiset.count_map_eq_count' _ _ (fun x y hxy => by
      simp only [Prod.mk.injEq, List.cons.injEq] at hxy
      exact Prod.ext hxy.1 hxy.2.2) _
  · rw [if_neg h]
    refine Multiset.count_eq_zero_of_notMem ?_
    intro hmem
    obtain ⟨y, _, hy⟩ := Multiset.mem_map.1 hmem
    simp only [Prod.mk.injEq, List.cons.injEq] at hy
    exact h hy.2.1

lemma count_map_consL_nil (a : X) (v : List X) (s : Multiset (List X × List X)) :
    Multiset.count (([] : List X), v) (s.map (fun q => (a :: q.1, q.2))) = 0 := by
  refine Multiset.count_eq_zero_of_notMem ?_
  intro hmem
  obtain ⟨y, _, hy⟩ := Multiset.mem_map.1 hmem
  simp at hy

lemma count_map_consR_nil (a : X) (u : List X) (s : Multiset (List X × List X)) :
    Multiset.count (u, ([] : List X)) (s.map (fun q => (q.1, a :: q.2))) = 0 := by
  refine Multiset.count_eq_zero_of_notMem ?_
  intro hmem
  obtain ⟨y, _, hy⟩ := Multiset.mem_map.1 hmem
  simp at hy

/-- **Shuffle/unshuffle duality.**  The multiplicity of the word `w` in the shuffle
`u ⧢ v` equals the multiplicity of the pair `(u,v)` in the unshuffle coproduct of `w`.
Equivalently: the shuffle product and the unshuffle coproduct are adjoint for the
canonical scalar product of `K⟨X⟩` in which words are orthonormal. -/
theorem count_shuf_eq_count_unsh (u v w : List X) :
    Multiset.count w (shuf u v) = Multiset.count (u, v) (unsh w) := by
  induction w generalizing u v with
  | nil =>
    match u, v with
    | [], [] => simp
    | [], b :: v => simp
    | a :: u, [] => simp
    | a :: u, b :: v => rw [shuf_cons_cons]; simp
  | cons c w ih =>
    match u, v with
    | [], [] =>
      rw [shuf_nil_left, unsh_cons, Multiset.count_add, count_map_consL_nil,
        count_map_consR_nil]
      simp
    | [], d :: v =>
      rw [shuf_nil_left, unsh_cons, Multiset.count_add, count_map_consL_nil,
        count_map_consR c d [] v]
      by_cases h : c = d
      · subst h
        rw [if_pos rfl, ← ih [] v, shuf_nil_left]
        simp [Multiset.count_singleton]
      · rw [if_neg h]
        simp only [Multiset.count_singleton, zero_add]
        rw [if_neg]
        rintro ⟨rfl, rfl⟩
        exact h rfl
    | a :: u, [] =>
      rw [shuf_nil_right, unsh_cons, Multiset.count_add, count_map_consL c a u [],
        count_map_consR_nil]
      by_cases h : c = a
      · subst h
        rw [if_pos rfl, ← ih u [], shuf_nil_right]
        simp [Multiset.count_singleton]
      · rw [if_neg h]
        simp only [Multiset.count_singleton, add_zero]
        rw [if_neg]
        rintro ⟨rfl, rfl⟩
        exact h rfl
    | a :: u, b :: v =>
      rw [shuf_cons_cons, unsh_cons, Multiset.count_add, Multiset.count_add,
        count_map_cons a c w, count_map_cons b c w,
        count_map_consL c a u (b :: v), count_map_consR c b (a :: u) v,
        ih u (b :: v), ih (a :: u) v]
      by_cases h1 : a = c <;> by_cases h2 : b = c <;> simp [h1, h2, Ne.symm]

end Count

/-! ## The unshuffle coproduct is an algebra morphism for concatenation -/

/-- Componentwise concatenation of two multisets of pairs of words: the product of the
tensor square of `K⟨X⟩` for the concatenation product. -/
def pairMul (s t : Multiset (List X × List X)) : Multiset (List X × List X) :=
  s.bind (fun p => t.map (fun q => (p.1 ++ q.1, p.2 ++ q.2)))

@[simp] lemma pairMul_add_left (s t r : Multiset (List X × List X)) :
    pairMul (s + t) r = pairMul s r + pairMul t r := by
  simp [pairMul, Multiset.add_bind]

@[simp] lemma pairMul_singleton_nil (t : Multiset (List X × List X)) :
    pairMul {(([] : List X), ([] : List X))} t = t := by
  simp [pairMul]

/-- **Bialgebra axiom for `(K⟨X⟩, concatenation, Δ_⧢)`**: the unshuffle coproduct is
multiplicative with respect to concatenation of words. -/
theorem unsh_append (u v : List X) : unsh (u ++ v) = pairMul (unsh u) (unsh v) := by
  induction u with
  | nil => simp
  | cons a u ih =>
    rw [List.cons_append, unsh_cons, ih, unsh_cons, pairMul_add_left]
    congr 1 <;>
    · simp only [pairMul, Multiset.bind_map, Multiset.map_bind, Multiset.map_map]
      exact Multiset.bind_congr (fun p _ => by
        refine Multiset.map_congr rfl (fun q _ => ?_)
        simp)

/-! ## Coassociativity -/

/-- Left iterate of the unshuffle coproduct: `(Δ ⊗ id) ∘ Δ`. -/
def coL (w : List X) : Multiset (List X × List X × List X) :=
  (unsh w).bind (fun p => (unsh p.1).map (fun r => (r.1, r.2, p.2)))

/-- Right iterate of the unshuffle coproduct: `(id ⊗ Δ) ∘ Δ`. -/
def coR (w : List X) : Multiset (List X × List X × List X) :=
  (unsh w).bind (fun p => (unsh p.2).map (fun r => (p.1, r.1, r.2)))

lemma coL_cons (a : X) (w : List X) :
    coL (a :: w) = (coL w).map (fun t => (a :: t.1, t.2.1, t.2.2)) +
      ((coL w).map (fun t => (t.1, a :: t.2.1, t.2.2)) +
       (coL w).map (fun t => (t.1, t.2.1, a :: t.2.2))) := by
  simp only [coL, unsh_cons, Multiset.add_bind, Multiset.bind_map, Multiset.map_bind,
    Multiset.map_map, Multiset.map_add, Function.comp]
  rw [Multiset.bind_add]
  abel

lemma coR_cons (a : X) (w : List X) :
    coR (a :: w) = (coR w).map (fun t => (a :: t.1, t.2.1, t.2.2)) +
      ((coR w).map (fun t => (t.1, a :: t.2.1, t.2.2)) +
       (coR w).map (fun t => (t.1, t.2.1, a :: t.2.2))) := by
  simp only [coR, unsh_cons, Multiset.add_bind, Multiset.bind_map, Multiset.map_bind,
    Multiset.map_map, Multiset.map_add, Function.comp]
  rw [Multiset.bind_add]

/-- **Coassociativity of the unshuffle coproduct.** -/
theorem unsh_coassoc (w : List X) : coL w = coR w := by
  induction w with
  | nil => simp [coL, coR]
  | cons a w ih => rw [coL_cons, coR_cons, ih]

/-! ## Cocommutativity -/

/-- **The unshuffle coproduct is cocommutative**: this is the "co-commutative" half of the
graded noncommutative co-commutative bialgebra `(K⟨X⟩, concatenation, Δ_⧢)`. -/
theorem unsh_swap (w : List X) : (unsh w).map Prod.swap = unsh w := by
  induction w with
  | nil => rfl
  | cons a w ih =>
    rw [unsh_cons, Multiset.map_add, Multiset.map_map, Multiset.map_map]
    rw [show ((Prod.swap ∘ fun p : List X × List X => (a :: p.1, p.2))
        = (fun p : List X × List X => (p.1, a :: p.2)) ∘ Prod.swap) from rfl,
      show ((Prod.swap ∘ fun p : List X × List X => (p.1, a :: p.2))
        = (fun p : List X × List X => (a :: p.1, p.2)) ∘ Prod.swap) from rfl,
      ← Multiset.map_map, ← Multiset.map_map, ih]
    exact add_comm _ _

end FreeMonoidShuffle