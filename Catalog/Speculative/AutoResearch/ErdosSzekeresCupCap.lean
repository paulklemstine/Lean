/-
# The Erdős–Szekeres Cup–Cap Theorem

The Happy-End Problem (Erdős–Szekeres, 1935) asks for the least number `ES(n)` of
points in general position in the plane that force a convex `n`-gon.  The
combinatorial engine behind every known upper bound is the **cup–cap theorem**:

> Any set of `C(k+l-4, k-2) + 1` points in general position with distinct
> `x`-coordinates contains a `k`-cup or an `l`-cap.

Here a *cup* (resp. *cap*) is an `x`-increasing chain of points that turns
consistently counter-clockwise (resp. clockwise) at every consecutive triple —
i.e. a convex chain that is concave up (resp. concave down).

This file gives a **complete, self-contained proof** of that theorem (0 `sorry`s).
The proof is the original Erdős–Szekeres double induction based on the Pascal
recurrence `f(k,l) ≤ f(k-1,l) + f(k,l-1) - 1`, reparametrised as
`f(a,b) = C(a+b,a)` to avoid truncated natural-number subtraction.  A key design
choice is that cups and caps are defined by their **consecutive** triples only,
so the inductive extension steps are purely *local* and need no global
orientation transitivity.

## Main results

* `orient`, `XSorted`, `GeneralPosition` : the standard planar primitives.
* `IsCup` / `IsCap`, `HasCupIn` / `HasCapIn` : convex chains inside a point set.
* `erdos_szekeres_cupcap` : the cup–cap theorem in reparametrised form,
  `S.card ≤ C(a+b, a)` whenever `S` has no `(a+2)`-cup and no `(b+2)`-cap.
* `cup_or_cap_of_card` : the headline existence statement — more than
  `C(k+l-4, k-2)` points force a `k`-cup or an `l`-cap.
* `erdos_szekeres_diagonal` : the symmetric corollary `k = l = n`, giving the
  classical Erdős–Szekeres bound `C(2n-4, n-2) + 1`.
-/
import Mathlib

open Finset

namespace ESCupCap

variable {m : ℕ}

/-! ## Planar primitives -/

/-- The orientation (twice the signed area) of an ordered triple of planar points.
Positive means a counter-clockwise (left) turn, negative a clockwise (right) turn,
zero means the three points are collinear. -/
def orient (a b c : ℝ × ℝ) : ℝ :=
  (b.1 - a.1) * (c.2 - a.2) - (b.2 - a.2) * (c.1 - a.1)

/-- The points are indexed in strictly increasing order of `x`-coordinate. -/
def XSorted (p : Fin m → ℝ × ℝ) : Prop :=
  ∀ i j : Fin m, i < j → (p i).1 < (p j).1

/-- General position: no three (distinct-index) points are collinear. -/
def GeneralPosition (p : Fin m → ℝ × ℝ) : Prop :=
  ∀ i j k : Fin m, i ≠ j → j ≠ k → i ≠ k → orient (p i) (p j) (p k) ≠ 0

/-! ## Cups and caps as local turn conditions -/

/-- `CupTurns p L` holds when every *consecutive* triple of `L` makes a strictly
positive (counter-clockwise) turn.  Because the condition is local, extending a
cup on either side only requires checking the newly created triple. -/
def CupTurns (p : Fin m → ℝ × ℝ) : List (Fin m) → Prop
  | a :: b :: c :: t => orient (p a) (p b) (p c) > 0 ∧ CupTurns p (b :: c :: t)
  | _ => True

/-- `CapTurns p L` holds when every consecutive triple of `L` makes a strictly
negative (clockwise) turn. -/
def CapTurns (p : Fin m → ℝ × ℝ) : List (Fin m) → Prop
  | a :: b :: c :: t => orient (p a) (p b) (p c) < 0 ∧ CapTurns p (b :: c :: t)
  | _ => True

/-- A cup: an `x`-increasing chain (strictly increasing indices) whose every
consecutive triple turns counter-clockwise. -/
def IsCup (p : Fin m → ℝ × ℝ) (L : List (Fin m)) : Prop :=
  L.Pairwise (· < ·) ∧ CupTurns p L

/-- A cap: an `x`-increasing chain whose every consecutive triple turns clockwise. -/
def IsCap (p : Fin m → ℝ × ℝ) (L : List (Fin m)) : Prop :=
  L.Pairwise (· < ·) ∧ CapTurns p L

/-- `HasCupIn p S k` : the point set `S` contains a `k`-cup. -/
def HasCupIn (p : Fin m → ℝ × ℝ) (S : Finset (Fin m)) (k : ℕ) : Prop :=
  ∃ L : List (Fin m), (∀ x ∈ L, x ∈ S) ∧ IsCup p L ∧ L.length = k

/-- `HasCapIn p S l` : the point set `S` contains an `l`-cap. -/
def HasCapIn (p : Fin m → ℝ × ℝ) (S : Finset (Fin m)) (l : ℕ) : Prop :=
  ∃ L : List (Fin m), (∀ x ∈ L, x ∈ S) ∧ IsCap p L ∧ L.length = l

/-! ## Local extension lemmas -/

/-- Unfolding lemma for `CupTurns` on a list `a :: b :: w` with `w` nonempty. -/
theorem cupTurns_cons2 (p : Fin m → ℝ × ℝ) (a b : Fin m) (w : List (Fin m)) (hw : w ≠ []) :
    CupTurns p (a :: b :: w) ↔
      orient (p a) (p b) (p (w.head hw)) > 0 ∧ CupTurns p (b :: w) := by
  cases w with
  | nil => exact absurd rfl hw
  | cons c t => simp [CupTurns]

/-- Unfolding lemma for `CapTurns` on a list `a :: b :: w` with `w` nonempty. -/
theorem capTurns_cons2 (p : Fin m → ℝ × ℝ) (a b : Fin m) (w : List (Fin m)) (hw : w ≠ []) :
    CapTurns p (a :: b :: w) ↔
      orient (p a) (p b) (p (w.head hw)) < 0 ∧ CapTurns p (b :: w) := by
  cases w with
  | nil => exact absurd rfl hw
  | cons c t => simp [CapTurns]

/-- Appending a point to a cup only creates one new consecutive triple, so the
cup condition propagates from `L ++ [y, z]` to `L ++ [y, z, x]`. -/
theorem cupTurns_concat {p : Fin m → ℝ × ℝ} {L : List (Fin m)} {y z x : Fin m}
    (h : CupTurns p (L ++ [y, z])) (ho : orient (p y) (p z) (p x) > 0) :
    CupTurns p (L ++ [y, z, x]) := by
  induction L with
  | nil => exact ⟨ho, trivial⟩
  | cons a L' IH =>
    cases L' with
    | nil => exact ⟨h.1, ho, trivial⟩
    | cons b L'' =>
        have hne1 : L'' ++ [y, z] ≠ [] := by simp
        have hne2 : L'' ++ [y, z, x] ≠ [] := by simp
        rw [List.cons_append, List.cons_append, cupTurns_cons2 p a b _ hne2]
        rw [List.cons_append, List.cons_append, cupTurns_cons2 p a b _ hne1] at h
        have hhead : (L'' ++ [y, z, x]).head hne2 = (L'' ++ [y, z]).head hne1 := by
          cases L'' with
          | nil => rfl
          | cons _ _ => rfl
        rw [hhead]
        exact ⟨h.1, IH h.2⟩

/-- Cap analogue of `cupTurns_concat`. -/
theorem capTurns_concat {p : Fin m → ℝ × ℝ} {L : List (Fin m)} {y z x : Fin m}
    (h : CapTurns p (L ++ [y, z])) (ho : orient (p y) (p z) (p x) < 0) :
    CapTurns p (L ++ [y, z, x]) := by
  induction L with
  | nil => exact ⟨ho, trivial⟩
  | cons a L' IH =>
    cases L' with
    | nil => exact ⟨h.1, ho, trivial⟩
    | cons b L'' =>
        have hne1 : L'' ++ [y, z] ≠ [] := by simp
        have hne2 : L'' ++ [y, z, x] ≠ [] := by simp
        rw [List.cons_append, List.cons_append, capTurns_cons2 p a b _ hne2]
        rw [List.cons_append, List.cons_append, capTurns_cons2 p a b _ hne1] at h
        have hhead : (L'' ++ [y, z, x]).head hne2 = (L'' ++ [y, z]).head hne1 := by
          cases L'' with
          | nil => rfl
          | cons _ _ => rfl
        rw [hhead]
        exact ⟨h.1, IH h.2⟩

/-! ## Trichotomy from general position -/

/-- For three strictly `x`-increasing indices, general position forces the triple
to turn either strictly left (cup) or strictly right (cap). -/
theorem cup_or_cap_triple {p : Fin m → ℝ × ℝ} (hgp : GeneralPosition p)
    {a b c : Fin m} (hab : a < b) (hbc : b < c) :
    orient (p a) (p b) (p c) > 0 ∨ orient (p a) (p b) (p c) < 0 := by
  have hne : orient (p a) (p b) (p c) ≠ 0 :=
    hgp a b c (ne_of_lt hab) (ne_of_lt hbc) (ne_of_lt (hab.trans hbc))
  rcases lt_or_gt_of_ne hne with h | h
  · exact Or.inr h
  · exact Or.inl h

/-! ## Monotonicity in the ambient set -/

/-- A cup in a smaller set is a cup in a larger set. -/
theorem HasCupIn.mono {p : Fin m → ℝ × ℝ} {S T : Finset (Fin m)} {k : ℕ}
    (hST : S ⊆ T) (h : HasCupIn p S k) : HasCupIn p T k := by
  obtain ⟨L, hL, hcup, hlen⟩ := h
  exact ⟨L, fun x hx => hST (hL x hx), hcup, hlen⟩

/-- A cap in a smaller set is a cap in a larger set. -/
theorem HasCapIn.mono {p : Fin m → ℝ × ℝ} {S T : Finset (Fin m)} {l : ℕ}
    (hST : S ⊆ T) (h : HasCapIn p S l) : HasCapIn p T l := by
  obtain ⟨L, hL, hcap, hlen⟩ := h
  exact ⟨L, fun x hx => hST (hL x hx), hcap, hlen⟩

/-! ## Base cases: 2-cups and 2-caps -/

/-- Any two distinct points form a 2-cup (there are no triples to constrain). -/
theorem hasCupIn_two {p : Fin m → ℝ × ℝ} {S : Finset (Fin m)} (h : 2 ≤ S.card) :
    HasCupIn p S 2 := by
  obtain ⟨a, ha, b, hb, hab⟩ := Finset.one_lt_card.mp h
  rcases lt_or_gt_of_ne hab with hlt | hgt
  · exact ⟨[a, b], by intro x hx; simp at hx; rcases hx with rfl | rfl <;> assumption,
      ⟨by simp [hlt], trivial⟩, rfl⟩
  · exact ⟨[b, a], by intro x hx; simp at hx; rcases hx with rfl | rfl <;> assumption,
      ⟨by simp [hgt], trivial⟩, rfl⟩

/-- Any two distinct points form a 2-cap. -/
theorem hasCapIn_two {p : Fin m → ℝ × ℝ} {S : Finset (Fin m)} (h : 2 ≤ S.card) :
    HasCapIn p S 2 := by
  obtain ⟨a, ha, b, hb, hab⟩ := Finset.one_lt_card.mp h
  rcases lt_or_gt_of_ne hab with hlt | hgt
  · exact ⟨[a, b], by intro x hx; simp at hx; rcases hx with rfl | rfl <;> assumption,
      ⟨by simp [hlt], trivial⟩, rfl⟩
  · exact ⟨[b, a], by intro x hx; simp at hx; rcases hx with rfl | rfl <;> assumption,
      ⟨by simp [hgt], trivial⟩, rfl⟩

/-! ## The endpoint set and its two structural properties -/

/-- A list of length at least two can be written as `init ++ [a, b]`. -/
theorem list_eq_init_snoc_two {α : Type*} (L : List α) (h : 2 ≤ L.length) :
    ∃ (init : List α) (a b : α), L = init ++ [a, b] := by
  rcases hr : L.reverse with _ | ⟨r1, _ | ⟨r2, rest⟩⟩
  · have hlen := congrArg List.length hr
    simp only [List.length_reverse, List.length_nil] at hlen; omega
  · have hlen := congrArg List.length hr
    simp only [List.length_reverse, List.length_cons, List.length_nil] at hlen; omega
  · refine ⟨rest.reverse, r2, r1, ?_⟩
    have : L = (r1 :: r2 :: rest).reverse := by rw [← hr, List.reverse_reverse]
    rw [this]; simp

open scoped Classical in
/-- `cupEndpoints p S k` is the set of points of `S` that are the right endpoint
(largest index) of some `k`-cup contained in `S`.  This is the pivotal object in
the Erdős–Szekeres double induction. -/
noncomputable def cupEndpoints (p : Fin m → ℝ × ℝ) (S : Finset (Fin m)) (k : ℕ) :
    Finset (Fin m) :=
  S.filter (fun x => ∃ L : List (Fin m),
    (∀ y ∈ L, y ∈ S) ∧ IsCup p L ∧ L.length = k ∧ L.getLast? = some x)

open scoped Classical in
theorem cupEndpoints_subset {p : Fin m → ℝ × ℝ} {S : Finset (Fin m)} {k : ℕ} :
    cupEndpoints p S k ⊆ S := by
  unfold cupEndpoints; exact Finset.filter_subset _ _

open scoped Classical in
/-- **Property 1.**  Removing the `k`-cup endpoints destroys all `k`-cups: the set
`S \ cupEndpoints p S k` contains no `k`-cup, because any `k`-cup there would have
its own endpoint back inside `cupEndpoints`. -/
theorem no_cup_in_sdiff_cupEndpoints {p : Fin m → ℝ × ℝ} {S : Finset (Fin m)} {k : ℕ}
    (hk : 1 ≤ k) : ¬ HasCupIn p (S \ cupEndpoints p S k) k := by
  rintro ⟨L, hL, hcup, hlen⟩
  have hLne : L ≠ [] := by
    intro hnil; rw [hnil] at hlen; simp at hlen; omega
  set z := L.getLast hLne with hzdef
  have hzmem : z ∈ L := List.getLast_mem hLne
  have hzin : z ∈ S \ cupEndpoints p S k := hL z hzmem
  rw [Finset.mem_sdiff] at hzin
  apply hzin.2
  unfold cupEndpoints
  rw [Finset.mem_filter]
  refine ⟨hzin.1, L, fun y hy => (Finset.mem_sdiff.mp (hL y hy)).1, hcup, hlen, ?_⟩
  rw [hzdef]; exact List.getLast?_eq_some_getLast hLne

/-- Appending a strictly larger point that makes a left turn extends a cup. -/
theorem isCup_snoc {p : Fin m → ℝ × ℝ} {init : List (Fin m)} {c q1 q2 : Fin m}
    (hL : IsCup p (init ++ [c, q1])) (hlt : q1 < q2)
    (ho : orient (p c) (p q1) (p q2) > 0) :
    IsCup p (init ++ [c, q1, q2]) := by
  obtain ⟨hpair, hturn⟩ := hL
  refine ⟨?_, cupTurns_concat hturn ho⟩
  have hcq1 : c < q1 :=
    (List.pairwise_cons.mp (List.pairwise_append.mp hpair).2.1).1 q1 (by simp)
  have hall : ∀ y ∈ (init ++ [c, q1]), y < q2 := by
    intro y hy
    rw [List.mem_append] at hy
    rcases hy with hy | hy
    · exact lt_trans ((List.pairwise_append.mp hpair).2.2 y hy q1 (by simp)) hlt
    · simp only [List.mem_cons, List.not_mem_nil, or_false] at hy
      rcases hy with rfl | rfl
      · exact lt_trans hcq1 hlt
      · exact hlt
  have hp2 : ((init ++ [c, q1]) ++ [q2]).Pairwise (· < ·) := by
    rw [List.pairwise_append]
    refine ⟨hpair, by simp, fun a ha b hb => ?_⟩
    simp only [List.mem_singleton] at hb; subst hb; exact hall a ha
  rw [List.append_assoc] at hp2
  exact hp2

/-- Prepending a strictly smaller point that makes a right turn extends a cap. -/
theorem isCap_cons {p : Fin m → ℝ × ℝ} {c q1 q2 : Fin m} {rest : List (Fin m)}
    (hM : IsCap p (q1 :: q2 :: rest)) (hlt : c < q1)
    (ho : orient (p c) (p q1) (p q2) < 0) :
    IsCap p (c :: q1 :: q2 :: rest) := by
  obtain ⟨hpair, hturn⟩ := hM
  refine ⟨?_, ho, hturn⟩
  rw [List.pairwise_cons]
  refine ⟨?_, hpair⟩
  intro b hb
  simp only [List.mem_cons] at hb
  rcases hb with rfl | rfl | hb
  · exact hlt
  · exact lt_trans hlt ((List.pairwise_cons.mp hpair).1 b (by simp))
  · exact lt_trans hlt ((List.pairwise_cons.mp hpair).1 b (by simp [hb]))

open scoped Classical in
/-- **Property 2.**  The `(a'+2)`-cup endpoints contain no `(b'+2)`-cap, provided
the ambient set has no `(a'+3)`-cup and no `(b'+3)`-cap.  This is the geometric
heart of the argument: given a cap `q₁ < q₂ < …` all of whose points end an
`(a'+2)`-cup, look at the predecessor `c` of `q₁` in one such cup and consider the
turn `orient c q₁ q₂`.  If it turns left, the cup extends by `q₂` to an
`(a'+3)`-cup; if it turns right, prepending `c` to the cap yields a `(b'+3)`-cap. -/
theorem no_cap_in_cupEndpoints {p : Fin m → ℝ × ℝ}
    (hgp : GeneralPosition p) {S : Finset (Fin m)} {a' b' : ℕ}
    (hcup : ¬ HasCupIn p S (a' + 3)) (hcap : ¬ HasCapIn p S (b' + 3)) :
    ¬ HasCapIn p (cupEndpoints p S (a' + 2)) (b' + 2) := by
  classical
  rintro ⟨M, hM, hMcap, hMlen⟩
  obtain ⟨q1, q2, Mrest, rfl⟩ : ∃ q1 q2 Mrest, M = q1 :: q2 :: Mrest := by
    match M, hMlen with
    | q1 :: q2 :: Mrest, _ => exact ⟨q1, q2, Mrest, rfl⟩
  have hq1E := hM q1 (by simp)
  have hq2E := hM q2 (by simp)
  have hq2S : q2 ∈ S := cupEndpoints_subset hq2E
  rw [cupEndpoints, Finset.mem_filter] at hq1E
  obtain ⟨hq1S, L, hLS, hLcup, hLlen, hLlast⟩ := hq1E
  have hLlen2 : 2 ≤ L.length := by omega
  obtain ⟨init, c, q1', rfl⟩ := list_eq_init_snoc_two L hLlen2
  have hq1eq : q1' = q1 := by
    have hgl : (init ++ [c, q1']).getLast? = some q1' := by simp
    rw [hgl] at hLlast; exact Option.some_inj.mp hLlast
  rw [hq1eq] at hLS hLcup hLlen
  have hcq1 : c < q1 :=
    (List.pairwise_cons.mp (List.pairwise_append.mp hLcup.1).2.1).1 q1 (by simp)
  have hq1q2 : q1 < q2 := (List.pairwise_cons.mp hMcap.1).1 q2 (by simp)
  rcases cup_or_cap_triple hgp hcq1 hq1q2 with hpos | hneg
  · apply hcup
    refine ⟨init ++ [c, q1, q2], ?_, isCup_snoc hLcup hq1q2 hpos, ?_⟩
    · intro y hy
      rw [List.mem_append] at hy
      rcases hy with hy | hy
      · exact hLS y (by rw [List.mem_append]; left; exact hy)
      · simp only [List.mem_cons, List.not_mem_nil, or_false] at hy
        rcases hy with h | h | h
        · rw [h]; exact hLS c (by simp)
        · rw [h]; exact hLS q1 (by simp)
        · rw [h]; exact hq2S
    · have hi : init.length + 2 = a' + 2 := by simpa using hLlen
      simp only [List.length_append, List.length_cons, List.length_nil]; omega
  · apply hcap
    refine ⟨c :: q1 :: q2 :: Mrest, ?_, isCap_cons hMcap hcq1 hneg, ?_⟩
    · intro y hy
      rw [List.mem_cons] at hy
      rcases hy with h | hy
      · rw [h]; exact hLS c (by simp)
      · exact cupEndpoints_subset (hM y hy)
    · have hi : Mrest.length + 2 = b' + 2 := by simpa using hMlen
      simp only [List.length_cons]; omega

/-! ## The core double induction -/

open scoped Classical in
/-- **Erdős–Szekeres cup–cap theorem (reparametrised form).**
If the point set `S` contains no `(a+2)`-cup and no `(b+2)`-cap, then
`S.card ≤ C(a+b, a)`.  Equivalently, more than `C(a+b, a)` points force an
`(a+2)`-cup or a `(b+2)`-cap. -/
theorem erdos_szekeres_cupcap {p : Fin m → ℝ × ℝ}
    (hgp : GeneralPosition p) :
    ∀ (a b : ℕ) (S : Finset (Fin m)),
      ¬ HasCupIn p S (a + 2) → ¬ HasCapIn p S (b + 2) →
      S.card ≤ Nat.choose (a + b) a := by
  intro a
  induction a with
  | zero =>
    intro b S hcup _
    have : S.card ≤ 1 := by
      by_contra hc
      exact hcup (hasCupIn_two (by omega))
    simpa using this
  | succ a' IHa =>
    intro b
    induction b with
    | zero =>
      intro S _ hcap
      have : S.card ≤ 1 := by
        by_contra hc
        exact hcap (hasCapIn_two (by omega))
      calc S.card ≤ 1 := this
        _ = Nat.choose (a' + 1 + 0) (a' + 1) := by simp
    | succ b' IHb =>
      intro S hcup hcap
      -- The endpoint set of `(a'+2)`-cups.
      set E := cupEndpoints p S (a' + 2) with hE
      -- Property 1: `S \ E` has no `(a'+2)`-cup.
      have hP1 : ¬ HasCupIn p (S \ E) (a' + 2) :=
        no_cup_in_sdiff_cupEndpoints (by omega)
      -- Property 2: `E` has no `(b'+2)`-cap.
      have hP2 : ¬ HasCapIn p E (b' + 2) := by
        have h3 : (a' + 3) = (a' + 1 + 2) := by ring
        have h3' : (b' + 3) = (b' + 1 + 2) := by ring
        rw [hE]
        exact no_cap_in_cupEndpoints hgp (by rw [h3]; exact hcup)
          (by rw [h3']; exact hcap)
      -- Bound the two parts.
      have hEsub : E ⊆ S := by rw [hE]; exact cupEndpoints_subset
      have hcardE : E.card ≤ Nat.choose (a' + b' + 1) (a' + 1) := by
        have hnc : ¬ HasCupIn p E (a' + 1 + 2) := by
          intro hh; exact hcup (by
            have : (a' + 1 + 2) = (a' + 1 + 2) := rfl
            exact HasCupIn.mono hEsub hh)
        have := IHb E hnc hP2
        simpa [Nat.add_comm, Nat.add_left_comm, Nat.add_assoc] using this
      have hcardC : (S \ E).card ≤ Nat.choose (a' + b' + 1) a' := by
        have hnc : ¬ HasCupIn p (S \ E) (a' + 2) := hP1
        have hncap : ¬ HasCapIn p (S \ E) (b' + 1 + 2) := by
          intro hh; exact hcap (HasCapIn.mono (Finset.sdiff_subset) hh)
        have := IHa (b' + 1) (S \ E) hnc hncap
        simpa [Nat.add_comm, Nat.add_left_comm, Nat.add_assoc] using this
      -- Split the cardinality and apply Pascal's rule.
      have hsplit : E.card + (S \ E).card = S.card := by
        rw [Nat.add_comm]; exact Finset.card_sdiff_add_card_eq_card hEsub
      have hpascal : Nat.choose (a' + b' + 1) a' + Nat.choose (a' + b' + 1) (a' + 1)
          = Nat.choose (a' + 1 + (b' + 1)) (a' + 1) := by
        have := Nat.choose_succ_succ (a' + b' + 1) a'
        simp only [Nat.succ_eq_add_one] at this
        rw [show a' + 1 + (b' + 1) = a' + b' + 1 + 1 by ring]
        rw [this]
      calc S.card = E.card + (S \ E).card := hsplit.symm
        _ ≤ Nat.choose (a' + b' + 1) (a' + 1) + Nat.choose (a' + b' + 1) a' := by
              exact Nat.add_le_add hcardE hcardC
        _ = Nat.choose (a' + b' + 1) a' + Nat.choose (a' + b' + 1) (a' + 1) := by
              rw [Nat.add_comm]
        _ = Nat.choose (a' + 1 + (b' + 1)) (a' + 1) := hpascal

/-! ## Headline existence statements -/

open scoped Classical in
/-- **The cup–cap theorem, existence form.**  Among more than `C(k+l-4, k-2)`
points in general position there is a `k`-cup or an `l`-cap.  (Only
`GeneralPosition` is needed; with `XSorted` the resulting cup/cap is a genuine
convex chain — see `happy_end`.) -/
theorem cup_or_cap_of_card {p : Fin m → ℝ × ℝ}
    (hgp : GeneralPosition p) {k l : ℕ}
    (hk : 2 ≤ k) (hl : 2 ≤ l)
    (hcard : Nat.choose (k + l - 4) (k - 2) < m) :
    HasCupIn p Finset.univ k ∨ HasCapIn p Finset.univ l := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨hncup, hncap⟩ := hcon
  obtain ⟨a, rfl⟩ : ∃ a, k = a + 2 := ⟨k - 2, by omega⟩
  obtain ⟨b, rfl⟩ : ∃ b, l = b + 2 := ⟨l - 2, by omega⟩
  have hbound := erdos_szekeres_cupcap hgp a b Finset.univ hncup hncap
  rw [Finset.card_univ, Fintype.card_fin] at hbound
  have he1 : (a + 2) + (b + 2) - 4 = a + b := by omega
  have he2 : (a + 2) - 2 = a := by omega
  rw [he1, he2] at hcard
  omega

open scoped Classical in
/-- **Erdős–Szekeres diagonal bound.**  For `n ≥ 2`, any `C(2n-4, n-2) + 1`
points in general position contain an `n`-cup or an `n`-cap.  This is the
combinatorial core of the classical Erdős–Szekeres upper bound for the Happy-End
problem. -/
theorem erdos_szekeres_diagonal {p : Fin m → ℝ × ℝ}
    (hgp : GeneralPosition p) {n : ℕ}
    (hn : 2 ≤ n) (hcard : Nat.choose (2 * n - 4) (n - 2) + 1 ≤ m) :
    HasCupIn p Finset.univ n ∨ HasCapIn p Finset.univ n := by
  apply cup_or_cap_of_card hgp hn hn
  have h : n + n - 4 = 2 * n - 4 := by omega
  rw [h]
  omega

/-! ## From local turns to global convex position

A cup/cap is defined by its *consecutive* triples.  For `x`-sorted points this
local condition already forces *every* triple to turn the same way, so the points
of a cup (resp. cap) are the vertices of a strictly convex chain — they are in
convex position.  This is where `XSorted` becomes essential. -/

/-- Right extension of a left turn: for `x`-sorted points, `abc` and `bcd` left
turns force `abd` to be a left turn. -/
theorem orient_cup_extend_right {a b c d : ℝ × ℝ}
    (h_abc : orient a b c > 0) (h_bcd : orient b c d > 0)
    (hx_ab : a.1 < b.1) (hx_bc : b.1 < c.1) (hx_cd : c.1 < d.1) :
    orient a b d > 0 := by
  unfold orient at *
  nlinarith [mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_bc),
             mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_cd),
             mul_pos (sub_pos.mpr hx_bc) (sub_pos.mpr hx_cd)]

/-- Left extension of a left turn: for `x`-sorted points, `abc` and `acd` left
turns force `abd` to be a left turn. -/
theorem orient_cup_extend_left {a b c d : ℝ × ℝ}
    (h_abc : orient a b c > 0) (h_acd : orient a c d > 0)
    (hx_ab : a.1 < b.1) (hx_bc : b.1 < c.1) (hx_cd : c.1 < d.1) :
    orient a b d > 0 := by
  unfold orient at *
  nlinarith [mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_bc),
             mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_cd),
             mul_pos (sub_pos.mpr hx_bc) (sub_pos.mpr hx_cd),
             mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr (hx_bc.trans hx_cd))]

/-- Right extension of a right turn (cap analogue of `orient_cup_extend_right`). -/
theorem orient_cap_extend_right {a b c d : ℝ × ℝ}
    (h_abc : orient a b c < 0) (h_bcd : orient b c d < 0)
    (hx_ab : a.1 < b.1) (hx_bc : b.1 < c.1) (hx_cd : c.1 < d.1) :
    orient a b d < 0 := by
  unfold orient at *
  nlinarith [mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_bc),
             mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_cd),
             mul_pos (sub_pos.mpr hx_bc) (sub_pos.mpr hx_cd)]

/-- Left extension of a right turn (cap analogue of `orient_cup_extend_left`). -/
theorem orient_cap_extend_left {a b c d : ℝ × ℝ}
    (h_abc : orient a b c < 0) (h_acd : orient a c d < 0)
    (hx_ab : a.1 < b.1) (hx_bc : b.1 < c.1) (hx_cd : c.1 < d.1) :
    orient a b d < 0 := by
  unfold orient at *
  nlinarith [mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_bc),
             mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_cd),
             mul_pos (sub_pos.mpr hx_bc) (sub_pos.mpr hx_cd),
             mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr (hx_bc.trans hx_cd))]

/-- Collapse of the middle point of two adjacent left turns: for `x`-sorted
points, `abc` and `bcd` left turns force `acd` to be a left turn. -/
theorem orient_cup_collapse {a b c d : ℝ × ℝ}
    (h_abc : orient a b c > 0) (h_bcd : orient b c d > 0)
    (hx_ab : a.1 < b.1) (hx_bc : b.1 < c.1) (hx_cd : c.1 < d.1) :
    orient a c d > 0 := by
  unfold orient at *
  nlinarith [mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_bc),
             mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_cd),
             mul_pos (sub_pos.mpr hx_bc) (sub_pos.mpr hx_cd),
             mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr (hx_bc.trans hx_cd)),
             mul_pos (sub_pos.mpr (hx_ab.trans hx_bc)) (sub_pos.mpr hx_cd)]

/-- Cap analogue of `orient_cup_collapse`. -/
theorem orient_cap_collapse {a b c d : ℝ × ℝ}
    (h_abc : orient a b c < 0) (h_bcd : orient b c d < 0)
    (hx_ab : a.1 < b.1) (hx_bc : b.1 < c.1) (hx_cd : c.1 < d.1) :
    orient a c d < 0 := by
  unfold orient at *
  nlinarith [mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_bc),
             mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_cd),
             mul_pos (sub_pos.mpr hx_bc) (sub_pos.mpr hx_cd),
             mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr (hx_bc.trans hx_cd)),
             mul_pos (sub_pos.mpr (hx_ab.trans hx_bc)) (sub_pos.mpr hx_cd)]

/-- A finite set is in *convex cup position*: every triple, in index order, makes
a left turn.  Such points are the vertices of a strictly convex (concave-up)
chain, hence in convex position. -/
def ConvexCupSet (p : Fin m → ℝ × ℝ) (s : Finset (Fin m)) : Prop :=
  ∀ a ∈ s, ∀ b ∈ s, ∀ c ∈ s, a < b → b < c → orient (p a) (p b) (p c) > 0

/-- A finite set is in *convex cap position*: every triple, in index order, makes
a right turn. -/
def ConvexCapSet (p : Fin m → ℝ × ℝ) (s : Finset (Fin m)) : Prop :=
  ∀ a ∈ s, ∀ b ∈ s, ∀ c ∈ s, a < b → b < c → orient (p a) (p b) (p c) < 0

/-- Points in convex position: a convex cup-chain or a convex cap-chain. -/
def InConvexPosition (p : Fin m → ℝ × ℝ) (s : Finset (Fin m)) : Prop :=
  ConvexCupSet p s ∨ ConvexCapSet p s

/-- Dropping the head of a cup leaves a cup. -/
theorem cupTurns_tail {p : Fin m → ℝ × ℝ} {x : Fin m} {t : List (Fin m)}
    (h : CupTurns p (x :: t)) : CupTurns p t := by
  match t, h with
  | [], _ => trivial
  | [_], _ => trivial
  | _ :: _ :: _, h => exact h.2

/-- Dropping the head of a cap leaves a cap. -/
theorem capTurns_tail {p : Fin m → ℝ × ℝ} {x : Fin m} {t : List (Fin m)}
    (h : CapTurns p (x :: t)) : CapTurns p t := by
  match t, h with
  | [], _ => trivial
  | [_], _ => trivial
  | _ :: _ :: _, h => exact h.2

/-- **Local-to-global for cups (list form).**  For `x`-sorted points, the
consecutive-triple cup condition forces *every* triple (in index order) to turn
left.  The proof is an induction on the list: for `L = x :: t`, a triple avoiding
the head is handled by the induction hypothesis on the cup `t`; a triple starting
at the head `x` is handled by the "fan" fact `orient (p x) (p (head t)) (p c) > 0`
(via `orient_cup_extend_right`) combined with `orient_cup_collapse`. -/
theorem cup_all {p : Fin m → ℝ × ℝ} (hx : XSorted p) : ∀ {L : List (Fin m)}, IsCup p L →
    ∀ a ∈ L, ∀ b ∈ L, ∀ c ∈ L, a < b → b < c → orient (p a) (p b) (p c) > 0 := by
  intro L
  induction L with
  | nil => intro _ a ha; simp at ha
  | cons x t IH =>
    intro hL a ha b hb c hc hab hbc
    obtain ⟨hpair, hturn⟩ := hL
    have hxmin : ∀ w ∈ t, x < w := (List.pairwise_cons.mp hpair).1
    have hpt : t.Pairwise (· < ·) := (List.pairwise_cons.mp hpair).2
    have hIsCupT : IsCup p t := ⟨hpt, cupTurns_tail hturn⟩
    have mem_tail : ∀ w, w ∈ x :: t → x < w → w ∈ t := by
      intro w hw hxw
      rcases List.mem_cons.mp hw with rfl | h
      · exact absurd hxw (lt_irrefl _)
      · exact h
    rcases List.mem_cons.mp ha with haeq | hat
    · have hxb : x < b := haeq ▸ hab
      have hxc : x < c := haeq ▸ (hab.trans hbc)
      have hbt : b ∈ t := mem_tail b hb hxb
      have hct : c ∈ t := mem_tail c hc hxc
      rw [haeq]
      cases t with
      | nil => exact absurd hbt (by simp)
      | cons y t' =>
        have hxy : x < y := hxmin y (by simp)
        have hpt' : t'.Pairwise (· < ·) := (List.pairwise_cons.mp hpt).2
        have hymin : ∀ w ∈ t', y < w := (List.pairwise_cons.mp hpt).1
        have memtail' : ∀ w, w ∈ y :: t' → y < w → w ∈ t' := by
          intro w hw hyw
          rcases List.mem_cons.mp hw with rfl | h
          · exact absurd hyw (lt_irrefl _)
          · exact h
        have stepA : ∀ w ∈ t', orient (p x) (p y) (p w) > 0 := by
          intro w hw
          cases t' with
          | nil => exact absurd hw (by simp)
          | cons z t'' =>
            have hxyz : orient (p x) (p y) (p z) > 0 := hturn.1
            have hyz : y < z := hymin z (by simp)
            rcases List.mem_cons.mp hw with rfl | hw''
            · exact hxyz
            · have hzw : z < w := (List.pairwise_cons.mp hpt').1 w hw''
              have hyzw : orient (p y) (p z) (p w) > 0 :=
                IH hIsCupT y (by simp) z (by simp) w
                  (List.mem_cons_of_mem _ (List.mem_cons_of_mem _ hw'')) hyz hzw
              exact orient_cup_extend_right hxyz hyzw (hx x y hxy) (hx y z hyz) (hx z w hzw)
        rcases List.mem_cons.mp hbt with hbeq | hbt'
        · have hyc : y < c := hbeq ▸ hbc
          have hct' : c ∈ t' := memtail' c hct hyc
          rw [hbeq]; exact stepA c hct'
        · have hyb : y < b := hymin b hbt'
          have hyc : y < c := hyb.trans hbc
          have hct' : c ∈ t' := memtail' c hct hyc
          have hxyb : orient (p x) (p y) (p b) > 0 := stepA b hbt'
          have hybc : orient (p y) (p b) (p c) > 0 :=
            IH hIsCupT y (by simp) b (List.mem_cons_of_mem _ hbt')
              c (List.mem_cons_of_mem _ hct') hyb hbc
          exact orient_cup_collapse hxyb hybc (hx x y hxy) (hx y b hyb) (hx b c hbc)
    · have hbt : b ∈ t := mem_tail b hb (lt_trans (hxmin a hat) hab)
      have hct : c ∈ t := mem_tail c hc (lt_trans (hxmin a hat) (hab.trans hbc))
      exact IH hIsCupT a hat b hbt c hct hab hbc

/-- **Local-to-global for caps (list form).**  Cap analogue of `cup_all`. -/
theorem cap_all {p : Fin m → ℝ × ℝ} (hx : XSorted p) : ∀ {L : List (Fin m)}, IsCap p L →
    ∀ a ∈ L, ∀ b ∈ L, ∀ c ∈ L, a < b → b < c → orient (p a) (p b) (p c) < 0 := by
  intro L
  induction L with
  | nil => intro _ a ha; simp at ha
  | cons x t IH =>
    intro hL a ha b hb c hc hab hbc
    obtain ⟨hpair, hturn⟩ := hL
    have hxmin : ∀ w ∈ t, x < w := (List.pairwise_cons.mp hpair).1
    have hpt : t.Pairwise (· < ·) := (List.pairwise_cons.mp hpair).2
    have hIsCapT : IsCap p t := ⟨hpt, capTurns_tail hturn⟩
    have mem_tail : ∀ w, w ∈ x :: t → x < w → w ∈ t := by
      intro w hw hxw
      rcases List.mem_cons.mp hw with rfl | h
      · exact absurd hxw (lt_irrefl _)
      · exact h
    rcases List.mem_cons.mp ha with haeq | hat
    · have hxb : x < b := haeq ▸ hab
      have hxc : x < c := haeq ▸ (hab.trans hbc)
      have hbt : b ∈ t := mem_tail b hb hxb
      have hct : c ∈ t := mem_tail c hc hxc
      rw [haeq]
      cases t with
      | nil => exact absurd hbt (by simp)
      | cons y t' =>
        have hxy : x < y := hxmin y (by simp)
        have hpt' : t'.Pairwise (· < ·) := (List.pairwise_cons.mp hpt).2
        have hymin : ∀ w ∈ t', y < w := (List.pairwise_cons.mp hpt).1
        have memtail' : ∀ w, w ∈ y :: t' → y < w → w ∈ t' := by
          intro w hw hyw
          rcases List.mem_cons.mp hw with rfl | h
          · exact absurd hyw (lt_irrefl _)
          · exact h
        have stepA : ∀ w ∈ t', orient (p x) (p y) (p w) < 0 := by
          intro w hw
          cases t' with
          | nil => exact absurd hw (by simp)
          | cons z t'' =>
            have hxyz : orient (p x) (p y) (p z) < 0 := hturn.1
            have hyz : y < z := hymin z (by simp)
            rcases List.mem_cons.mp hw with rfl | hw''
            · exact hxyz
            · have hzw : z < w := (List.pairwise_cons.mp hpt').1 w hw''
              have hyzw : orient (p y) (p z) (p w) < 0 :=
                IH hIsCapT y (by simp) z (by simp) w
                  (List.mem_cons_of_mem _ (List.mem_cons_of_mem _ hw'')) hyz hzw
              exact orient_cap_extend_right hxyz hyzw (hx x y hxy) (hx y z hyz) (hx z w hzw)
        rcases List.mem_cons.mp hbt with hbeq | hbt'
        · have hyc : y < c := hbeq ▸ hbc
          have hct' : c ∈ t' := memtail' c hct hyc
          rw [hbeq]; exact stepA c hct'
        · have hyb : y < b := hymin b hbt'
          have hyc : y < c := hyb.trans hbc
          have hct' : c ∈ t' := memtail' c hct hyc
          have hxyb : orient (p x) (p y) (p b) < 0 := stepA b hbt'
          have hybc : orient (p y) (p b) (p c) < 0 :=
            IH hIsCapT y (by simp) b (List.mem_cons_of_mem _ hbt')
              c (List.mem_cons_of_mem _ hct') hyb hbc
          exact orient_cap_collapse hxyb hybc (hx x y hxy) (hx y b hyb) (hx b c hbc)
    · have hbt : b ∈ t := mem_tail b hb (lt_trans (hxmin a hat) hab)
      have hct : c ∈ t := mem_tail c hc (lt_trans (hxmin a hat) (hab.trans hbc))
      exact IH hIsCapT a hat b hbt c hct hab hbc

/-- **Local-to-global for cups.**  For `x`-sorted points, the consecutive-triple
cup condition forces every triple to turn left, so a cup's points are in convex
cup position. -/
theorem cup_convexCupSet {p : Fin m → ℝ × ℝ} (hx : XSorted p) {L : List (Fin m)}
    (hL : IsCup p L) : ConvexCupSet p L.toFinset := by
  intro a ha b hb c hc hab hbc
  exact cup_all hx hL a (List.mem_toFinset.mp ha) b (List.mem_toFinset.mp hb)
    c (List.mem_toFinset.mp hc) hab hbc

/-- **Local-to-global for caps.** -/
theorem cap_convexCapSet {p : Fin m → ℝ × ℝ} (hx : XSorted p) {L : List (Fin m)}
    (hL : IsCap p L) : ConvexCapSet p L.toFinset := by
  intro a ha b hb c hc hab hbc
  exact cap_all hx hL a (List.mem_toFinset.mp ha) b (List.mem_toFinset.mp hb)
    c (List.mem_toFinset.mp hc) hab hbc

open scoped Classical in
/-- **The Happy-End theorem (upper bound).**  For `n ≥ 2`, any family of at least
`C(2n-4, n-2) + 1` points in general position with distinct `x`-coordinates
contains `n` points in convex position.  This is the Erdős–Szekeres solution of the
Happy-End problem's existence half. -/
theorem happy_end {p : Fin m → ℝ × ℝ}
    (hx : XSorted p) (hgp : GeneralPosition p) {n : ℕ}
    (hn : 2 ≤ n) (hcard : Nat.choose (2 * n - 4) (n - 2) + 1 ≤ m) :
    ∃ s : Finset (Fin m), s.card = n ∧ InConvexPosition p s := by
  rcases erdos_szekeres_diagonal hgp hn hcard with
    ⟨L, _, hLcup, hLlen⟩ | ⟨L, _, hLcap, hLlen⟩
  · refine ⟨L.toFinset, ?_, Or.inl (cup_convexCupSet hx hLcup)⟩
    rw [List.toFinset_card_of_nodup (hLcup.1.imp (fun h => ne_of_lt h)), hLlen]
  · refine ⟨L.toFinset, ?_, Or.inr (cap_convexCapSet hx hLcap)⟩
    rw [List.toFinset_card_of_nodup (hLcap.1.imp (fun h => ne_of_lt h)), hLlen]

end ESCupCap