/-
# The Heisenberg group `H_{p^3}` of exponent `p`, and product-one-free sequences

This file sets up the objects needed to study the *small Davenport constant*
`d(G)` (the maximal length of a product-one-free sequence over a finite group
`G`) for the exponent-`p` Heisenberg group

  `H_{p^3} = { (a,b,c) : a,b,c ∈ ZMod p }`,  `(a,b,c)(a',b',c') = (a+a', b+b', c+c'+a b')`,

which is the group of upper unitriangular `3 × 3` matrices over `ZMod p`.

Main contents:

* `Heis p` with its group structure, cardinality `p ^ 3`, commutator formula and
  (for odd `p`) exponent `p`.
* `Heis.crossSum` and the **product formula** `Heis.prod_eq`: the product of a
  list is `(Σ a, Σ b, Σ c + Σ_{i<j} a_i b_j)`.  This is the bridge that turns the
  non-commutative product-one problem into additive combinatorics over
  `(ZMod p)^2`.
* `IsProductOne`, `ProductOneFree`, `smallDavenport` for an arbitrary group, and
  the general pigeonhole bound `d(G) ≤ |G| - 1`.
-/
import Mathlib

namespace Heisenberg125

/-! ## The Heisenberg group -/

/-- The Heisenberg group over `ZMod p`: triples `(a,b,c)` with the unitriangular
matrix multiplication. -/
@[ext]
structure Heis (p : ℕ) where
  a : ZMod p
  b : ZMod p
  c : ZMod p
  deriving DecidableEq

namespace Heis

variable {p : ℕ}

instance : Mul (Heis p) := ⟨fun g h => ⟨g.a + h.a, g.b + h.b, g.c + h.c + g.a * h.b⟩⟩
instance : One (Heis p) := ⟨⟨0, 0, 0⟩⟩
instance : Inv (Heis p) := ⟨fun g => ⟨-g.a, -g.b, -g.c + g.a * g.b⟩⟩

@[simp] lemma mul_a (g h : Heis p) : (g * h).a = g.a + h.a := rfl
@[simp] lemma mul_b (g h : Heis p) : (g * h).b = g.b + h.b := rfl
@[simp] lemma mul_c (g h : Heis p) : (g * h).c = g.c + h.c + g.a * h.b := rfl
@[simp] lemma one_a : (1 : Heis p).a = 0 := rfl
@[simp] lemma one_b : (1 : Heis p).b = 0 := rfl
@[simp] lemma one_c : (1 : Heis p).c = 0 := rfl
@[simp] lemma inv_a (g : Heis p) : g⁻¹.a = -g.a := rfl
@[simp] lemma inv_b (g : Heis p) : g⁻¹.b = -g.b := rfl
@[simp] lemma inv_c (g : Heis p) : g⁻¹.c = -g.c + g.a * g.b := rfl

lemma eq_one_iff {g : Heis p} : g = 1 ↔ g.a = 0 ∧ g.b = 0 ∧ g.c = 0 := by
  constructor
  · rintro rfl; exact ⟨rfl, rfl, rfl⟩
  · rintro ⟨h1, h2, h3⟩; ext <;> simp [h1, h2, h3]

instance : Group (Heis p) :=
  Group.ofLeftAxioms
    (fun g h k => by ext <;> simp <;> ring)
    (fun g => by ext <;> simp)
    (fun g => by ext <;> simp)

/-- The generator `x = (1,0,0)`. -/
def x (p : ℕ) : Heis p := ⟨1, 0, 0⟩
/-- The generator `y = (0,1,0)`. -/
def y (p : ℕ) : Heis p := ⟨0, 1, 0⟩
/-- The central generator `v = [x,y] = (0,0,1)`. -/
def v (p : ℕ) : Heis p := ⟨0, 0, 1⟩

/-- `v` is central. -/
lemma v_central (g : Heis p) : v p * g = g * v p := by
  ext <;> simp [v, add_comm]

/-- The commutator of two elements is the central element determined by the
determinant of their images in `(ZMod p)^2`. -/
lemma commutator_eq (g h : Heis p) :
    g * h * g⁻¹ * h⁻¹ = ⟨0, 0, g.a * h.b - h.a * g.b⟩ := by
  ext
  · simp
  · simp
  · simp; ring

/-- `[x, y] = v`. -/
lemma commutator_x_y : x p * y p * (x p)⁻¹ * (y p)⁻¹ = v p := by
  rw [commutator_eq]; ext <;> simp [x, y, v]

/-- Two elements commute iff their images in `(ZMod p)^2` are proportional. -/
lemma commute_iff {g h : Heis p} : Commute g h ↔ g.a * h.b = h.a * g.b := by
  constructor
  · intro hc
    have h' : g.c + h.c + g.a * h.b = h.c + g.c + h.a * g.b := congrArg Heis.c hc
    linear_combination h'
  · intro h'
    show g * h = h * g
    ext
    · simp [add_comm]
    · simp [add_comm]
    · simp only [mul_c]; linear_combination h' + congrArg (fun _ => (0 : ZMod p)) h'

/-! ### Cardinality -/

/-- `Heis p` is in bijection with `(ZMod p)^3`. -/
def equivProd : Heis p ≃ ZMod p × ZMod p × ZMod p where
  toFun g := (g.a, g.b, g.c)
  invFun t := ⟨t.1, t.2.1, t.2.2⟩
  left_inv g := by ext <;> rfl
  right_inv t := rfl

instance [NeZero p] : Fintype (Heis p) := Fintype.ofEquiv _ (equivProd (p := p)).symm

@[simp] lemma card_heis [NeZero p] : Fintype.card (Heis p) = p ^ 3 := by
  rw [Fintype.card_congr (equivProd (p := p))]
  simp [ZMod.card]
  ring

/-! ## Products of lists -/

/-- Sum of the first coordinates. -/
def asum (L : List (Heis p)) : ZMod p := (L.map Heis.a).sum
/-- Sum of the second coordinates. -/
def bsum (L : List (Heis p)) : ZMod p := (L.map Heis.b).sum
/-- Sum of the third coordinates. -/
def csum (L : List (Heis p)) : ZMod p := (L.map Heis.c).sum

@[simp] lemma asum_nil : asum ([] : List (Heis p)) = 0 := rfl
@[simp] lemma bsum_nil : bsum ([] : List (Heis p)) = 0 := rfl
@[simp] lemma csum_nil : csum ([] : List (Heis p)) = 0 := rfl
@[simp] lemma asum_cons (g : Heis p) (L) : asum (g :: L) = g.a + asum L := rfl
@[simp] lemma bsum_cons (g : Heis p) (L) : bsum (g :: L) = g.b + bsum L := rfl
@[simp] lemma csum_cons (g : Heis p) (L) : csum (g :: L) = g.c + csum L := rfl

/-- The "cross sum" `Σ_{i < j} a_i b_j` of a list. -/
def crossSum : List (Heis p) → ZMod p
  | [] => 0
  | g :: L => g.a * bsum L + crossSum L

@[simp] lemma crossSum_nil : crossSum ([] : List (Heis p)) = 0 := rfl
@[simp] lemma crossSum_cons (g : Heis p) (L) :
    crossSum (g :: L) = g.a * bsum L + crossSum L := rfl

/-- **Product formula.**  The product of a list of Heisenberg elements has
first two coordinates the (order independent) coordinate sums, and third
coordinate the sum of third coordinates plus the order-dependent cross sum
`Σ_{i<j} a_i b_j`. -/
theorem prod_eq (L : List (Heis p)) :
    L.prod = ⟨asum L, bsum L, csum L + crossSum L⟩ := by
  induction L with
  | nil => ext <;> simp
  | cons g L ih =>
      rw [List.prod_cons, ih]
      ext
      · simp
      · simp
      · simp; ring

/-- A list has product `1` iff the coordinate sums vanish and the third
coordinate sum cancels the cross sum. -/
theorem prod_eq_one_iff (L : List (Heis p)) :
    L.prod = 1 ↔ asum L = 0 ∧ bsum L = 0 ∧ csum L + crossSum L = 0 := by
  rw [prod_eq, eq_one_iff]

lemma asum_perm {L M : List (Heis p)} (h : L.Perm M) : asum L = asum M :=
  (h.map Heis.a).sum_eq
lemma bsum_perm {L M : List (Heis p)} (h : L.Perm M) : bsum L = bsum M :=
  (h.map Heis.b).sum_eq
lemma csum_perm {L M : List (Heis p)} (h : L.Perm M) : csum L = csum M :=
  (h.map Heis.c).sum_eq

/-- If every entry has vanishing first coordinate, the cross sum vanishes, so
the product is order independent. -/
lemma crossSum_eq_zero_of_a_eq_zero {L : List (Heis p)} (h : ∀ g ∈ L, g.a = 0) :
    crossSum L = 0 := by
  induction L with
  | nil => rfl
  | cons g L ih =>
      simp [h g (by simp), ih fun t ht => h t (by simp [ht])]

private lemma choose_two_succ (n : ℕ) : (n + 1).choose 2 = n.choose 2 + n := by
  simp [Nat.choose_succ_succ, Nat.choose_one_right, Nat.add_comm]

/-- The `b`-sum of a list all of whose entries have second coordinate `β`. -/
lemma bsum_of_const {L : List (Heis p)} {β : ZMod p} (h : ∀ g ∈ L, g.b = β) :
    bsum L = β * (L.length : ℕ) := by
  induction L with
  | nil => simp
  | cons g L ih =>
      rw [bsum_cons, h g (by simp), ih fun t ht => h t (by simp [ht])]
      simp only [List.length_cons]
      push_cast
      ring

/-- Cross sum of a list all of whose entries have the same image `(α, β)`:
it equals `α β * (n choose 2)`. -/
lemma crossSum_of_const {L : List (Heis p)} {α β : ZMod p}
    (h : ∀ g ∈ L, g.a = α ∧ g.b = β) :
    crossSum L = α * β * (L.length.choose 2 : ℕ) := by
  induction L with
  | nil => simp
  | cons g L ih =>
      have hg := h g (by simp)
      have hL : ∀ t ∈ L, t.a = α ∧ t.b = β := fun t ht => h t (by simp [ht])
      rw [crossSum_cons, hg.1, bsum_of_const (fun t ht => (hL t ht).2), ih hL,
        List.length_cons, choose_two_succ]
      push_cast
      ring

/-- Power formula: `(a,b,c)^n = (n a, n b, n c + (n choose 2) a b)`. -/
lemma pow_eq (g : Heis p) (n : ℕ) :
    g ^ n = ⟨(n : ZMod p) * g.a, (n : ZMod p) * g.b,
      (n : ZMod p) * g.c + (n.choose 2 : ℕ) * (g.a * g.b)⟩ := by
  induction n with
  | zero => ext <;> simp
  | succ n ih =>
      rw [pow_succ, ih]
      ext
      · simp; ring
      · simp; ring
      · simp only [mul_c, choose_two_succ]; push_cast; ring

/-- For odd `p`, `p` divides `p choose 2`. -/
lemma cast_choose_two_eq_zero (hp : Odd p) : ((p.choose 2 : ℕ) : ZMod p) = 0 := by
  have hdvd : p ∣ p.choose 2 := by
    obtain ⟨k, hk⟩ := hp
    refine ⟨k, ?_⟩
    rw [Nat.choose_two_right, hk]
    have h2 : (2 * k + 1) * (2 * k + 1 - 1) = 2 * ((2 * k + 1) * k) := by
      simp only [Nat.add_sub_cancel]
      ring
    rw [h2, Nat.mul_div_cancel_left _ (by norm_num : 0 < 2)]
  exact (ZMod.natCast_eq_zero_iff _ _).2 hdvd

/-- For odd `p`, the Heisenberg group `Heis p` has exponent dividing `p`:
it is the *exponent-`p`* Heisenberg group. -/
theorem pow_p_eq_one (hp : Odd p) (g : Heis p) : g ^ p = 1 := by
  rw [pow_eq]
  ext <;> simp [cast_choose_two_eq_zero hp]

end Heis

/-! ## Product-one-free sequences and the small Davenport constant -/

variable {G : Type*} [Group G]

/-- A sequence (list) over a group *has product one* if some ordering of it
multiplies to `1`. -/
def IsProductOne (L : List G) : Prop := ∃ M : List G, M.Perm L ∧ M.prod = 1

/-- A sequence is *product-one-free* if no nonempty subsequence has product one
in any ordering. -/
def ProductOneFree (L : List G) : Prop :=
  ∀ T : List G, T.Sublist L → T ≠ [] → ¬ IsProductOne T

lemma ProductOneFree.sublist {L T : List G} (h : ProductOneFree L) (hT : T.Sublist L) :
    ProductOneFree T := fun U hU hne => h U (hU.trans hT) hne

/-- The set of lengths of product-one-free sequences. -/
def productOneFreeLengths (G : Type*) [Group G] : Set ℕ :=
  {n | ∃ L : List G, L.length = n ∧ ProductOneFree L}

/-- The **small Davenport constant** `d(G)`: the maximal length of a
product-one-free sequence over `G`. -/
noncomputable def smallDavenport (G : Type*) [Group G] : ℕ :=
  sSup (productOneFreeLengths G)

/-- Equal prefix products produce a nonempty consecutive block with product one. -/
lemma exists_block_prod_one {L : List G} {i j : ℕ} (hij : i < j) (hj : j ≤ L.length)
    (h : (L.take i).prod = (L.take j).prod) :
    ∃ T : List G, T.Sublist L ∧ T ≠ [] ∧ T.prod = 1 := by
  refine ⟨(L.take j).drop i, (List.drop_sublist _ _).trans (List.take_sublist _ _), ?_, ?_⟩
  · intro hc
    have hlen : ((L.take j).drop i).length = j - i := by
      simp [List.length_drop, List.length_take, Nat.min_eq_left hj]
    rw [hc] at hlen
    simp only [List.length_nil] at hlen
    omega
  · have htake : (L.take j).take i = L.take i := by
      rw [List.take_take, Nat.min_eq_left hij.le]
    have hprod : (L.take i).prod * ((L.take j).drop i).prod = (L.take j).prod := by
      rw [← htake, ← List.prod_append, List.take_append_drop]
    exact mul_left_cancel (a := (L.take i).prod) (by rw [hprod, ← h, mul_one])

/-- **General upper bound (pigeonhole on prefix products).**  A product-one-free
sequence over a finite group is shorter than `|G|`. -/
theorem ProductOneFree.length_lt_card [Fintype G] {L : List G} (h : ProductOneFree L) :
    L.length < Fintype.card G := by
  classical
  have hinj : Function.Injective (fun i : Fin (L.length + 1) => (L.take (i : ℕ)).prod) := by
    intro i j hij
    by_contra hne
    have hne' : (i : ℕ) ≠ (j : ℕ) := fun hc => hne (Fin.ext hc)
    have key : ∀ k l : Fin (L.length + 1), (k : ℕ) < l →
        (L.take (k : ℕ)).prod = (L.take (l : ℕ)).prod → False := by
      intro k l hlt heq
      obtain ⟨T, hsub, hTne, hTprod⟩ :=
        exists_block_prod_one hlt (Nat.lt_succ_iff.mp l.isLt) heq
      exact h T hsub hTne ⟨T, List.Perm.refl _, hTprod⟩
    rcases lt_or_gt_of_ne hne' with hlt | hlt
    · exact key i j hlt hij
    · exact key j i hlt hij.symm
  have := Fintype.card_le_of_injective _ hinj
  simpa using this

lemma bddAbove_productOneFreeLengths [Fintype G] :
    BddAbove (productOneFreeLengths G) := by
  refine ⟨Fintype.card G, ?_⟩
  rintro n ⟨L, rfl, hL⟩
  exact hL.length_lt_card.le

lemma productOneFree_nil : ProductOneFree ([] : List G) := by
  rintro T hT hne
  exact absurd (List.eq_nil_of_sublist_nil hT) hne

/-- Any product-one-free sequence has length at most `d(G)`. -/
theorem ProductOneFree.length_le_smallDavenport [Fintype G] {L : List G}
    (h : ProductOneFree L) : L.length ≤ smallDavenport G :=
  le_csSup bddAbove_productOneFreeLengths ⟨L, rfl, h⟩

/-- `d(G) ≤ |G| - 1` for every finite group. -/
theorem smallDavenport_le_card_sub_one [Fintype G] :
    smallDavenport G ≤ Fintype.card G - 1 := by
  refine csSup_le ⟨0, ⟨[], rfl, productOneFree_nil⟩⟩ ?_
  rintro n ⟨L, rfl, hL⟩
  have := hL.length_lt_card (G := G)
  omega

/-- If some product-one-free sequence has length `n` and every product-one-free
sequence has length at most `n`, then `d(G) = n`. -/
theorem smallDavenport_eq_of_isGreatest {n : ℕ} (hn : IsGreatest (productOneFreeLengths G) n) :
    smallDavenport G = n := hn.csSup_eq

end Heisenberg125