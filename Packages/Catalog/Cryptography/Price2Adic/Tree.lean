import Mathlib

/-!
# The Price tree of primitive Pythagorean triples: uniqueness and completeness

Price's ternary tree of primitive Pythagorean triples is usually presented by three
`3 × 3` matrices acting on triples `(a,b,c)`.  On the *parameter* side (Euclid's
`(m,n) ↦ (m²-n², 2mn, m²+n²)`) the three moves become the strikingly simple pair maps

* `A : (m,n) ↦ (m+n, 2n)`,
* `B : (m,n) ↦ (2m, m-n)`,
* `C : (m,n) ↦ (2m, m+n)`,

each of which *doubles* one of the two parameters.  This is the "halving alphabet":
every Price move is visible 2-adically, in contrast with the Berggren tree whose
moves are 3-adic in nature (`Catalog/Cryptography/BerggrenTrees`).

This file proves, for these maps, the two facts a brute-force enumeration can only
sample:

* **Well-definedness** (`Valid_step`): each move sends a valid Euclid parameter pair to
  a valid Euclid parameter pair.
* **Uniqueness** (`address_eval`, `eval_injective`): distinct words give distinct nodes —
  the tree has no duplicates.
* **Completeness** (`eval_address`): every valid parameter pair is reached.
* Together: `existsUnique_word` — every primitive Pythagorean triple has exactly one
  Price address; `evalEquiv` packages this as a bijection between Price words and
  valid parameter pairs.

We also prove two-sided *depth* bounds (`sum_le_of_length`, `sum_ge_of_length`)
quantifying that the Price tree grows at most geometrically with ratio `3` and at least
arithmetically with step `2`.  These are the rigorous form of the empirical
"`dP` grows like `log₂(m+n)`" law: the depth of the node `(m,n)` is squeezed
between `log₃(m+n) - 1` and `(m+n-3)/2`.

## Lab notes (round 70, exp 548)

BFS over the parameter tree from the root `(2,1)` to depth `8` produced
`(3^9-1)/2 = 9841` nodes, all distinct (`0` duplicates).  BFS pruned at `c ≤ 5000`
(maximal depth reached: `9`) produced exactly `792` nodes, matching a brute-force
enumeration of the primitive triples with `c ≤ 5000` with `0` missing and `0` extra.
The theorems below replace both finite checks by proofs.  The child triples of
`(3,4,5)` are `(5,12,13)`, `(15,8,17)`, `(7,24,25)` (`triple_children_root`), i.e. this
is the Price tree and not Berggren's, whose root children include `(21,20,29)`.
-/

namespace Price2Adic

/-! ## Arithmetic helpers -/

lemma odd_dvd_of_dvd_two_mul {d m : ℕ} (hd : d % 2 = 1) (h : d ∣ 2 * m) : d ∣ m := by
  have hc : Nat.Coprime 2 d := (Nat.prime_two.coprime_iff_not_dvd).mpr (by omega)
  exact hc.symm.dvd_of_dvd_mul_left (by simpa [Nat.mul_comm] using h)

lemma eq_one_of_dvd_gcd_eq_one {d x y : ℕ} (hg : Nat.gcd x y = 1) (h1 : d ∣ x) (h2 : d ∣ y) :
    d = 1 := Nat.dvd_one.mp (hg ▸ Nat.dvd_gcd h1 h2)

lemma odd_of_dvd_odd {d x : ℕ} (h : d ∣ x) (hx : x % 2 = 1) : d % 2 = 1 := by
  rcases Nat.even_or_odd d with he | ho
  · have : (2 : ℕ) ∣ x := dvd_trans he.two_dvd h
    omega
  · exact Nat.odd_iff.mp ho

/-! ## The alphabet, the moves, and the nodes -/

/-- The three letters of the Price alphabet. -/
inductive PriceLetter : Type
  | A | B | C
  deriving DecidableEq, Repr

/-- A Price word: a path from the root, read left to right. -/
abbrev PriceWord := List PriceLetter

/-- Euclid parameter pairs generating *primitive* Pythagorean triples:
`0 < n < m`, `gcd m n = 1`, and `m + n` odd. -/
def Valid : ℕ × ℕ → Prop
  | (m, n) => 0 < n ∧ n < m ∧ Nat.gcd m n = 1 ∧ (m + n) % 2 = 1

instance : DecidablePred Valid := fun p => by
  obtain ⟨m, n⟩ := p; unfold Valid; infer_instance

/-- The three Price moves on parameter pairs. -/
def step : PriceLetter → ℕ × ℕ → ℕ × ℕ
  | .A, (m, n) => (m + n, 2 * n)
  | .B, (m, n) => (2 * m, m - n)
  | .C, (m, n) => (2 * m, m + n)

/-- The root of the Price tree: `(2,1)`, i.e. the triple `(3,4,5)`. -/
def root : ℕ × ℕ := (2, 1)

/-- The node addressed by a Price word. -/
def eval (w : PriceWord) : ℕ × ℕ := w.foldl (fun p l => step l p) root

/-- The Euclid triple attached to a parameter pair. -/
def triple : ℕ × ℕ → ℕ × ℕ × ℕ
  | (m, n) => (m ^ 2 - n ^ 2, 2 * m * n, m ^ 2 + n ^ 2)

/-- The odd leg of the triple attached to a parameter pair. -/
def oddLeg : ℕ × ℕ → ℕ
  | (m, n) => m ^ 2 - n ^ 2

@[simp] theorem eval_nil : eval [] = root := rfl

theorem eval_append_one (w : PriceWord) (l : PriceLetter) :
    eval (w ++ [l]) = step l (eval w) := by
  simp [eval]

theorem root_valid : Valid root := by
  refine ⟨by norm_num, by norm_num, ?_, by norm_num⟩
  norm_num

/-- Root triple: `(3,4,5)`. -/
theorem triple_root : triple root = (3, 4, 5) := by norm_num [triple, root]

/-- The three children of the root are `(5,12,13)`, `(15,8,17)`, `(7,24,25)`: this is the
Price tree.  (Berggren's tree instead produces `(21,20,29)` among the root's children.) -/
theorem triple_children_root :
    triple (step .A root) = (5, 12, 13) ∧ triple (step .B root) = (15, 8, 17) ∧
      triple (step .C root) = (7, 24, 25) := by
  refine ⟨?_, ?_, ?_⟩ <;> norm_num [triple, step, root]

/-- Every valid parameter pair does give a Pythagorean triple. -/
theorem triple_isPythagorean (p : ℕ × ℕ) (hp : Valid p) :
    (triple p).1 ^ 2 + (triple p).2.1 ^ 2 = (triple p).2.2 ^ 2 := by
  obtain ⟨m, n⟩ := p
  obtain ⟨-, hlt, -, -⟩ := hp
  have h : n ^ 2 ≤ m ^ 2 := Nat.pow_le_pow_left (le_of_lt hlt) 2
  simp only [triple]
  zify [h]
  ring

/-! ## Well-definedness -/

theorem Valid_step (l : PriceLetter) (p : ℕ × ℕ) (hp : Valid p) : Valid (step l p) := by
  obtain ⟨m, n⟩ := p
  obtain ⟨hn, hlt, hg, hpar⟩ := hp
  cases l
  · refine ⟨by omega, by omega, ?_, by omega⟩
    show Nat.gcd (m + n) (2 * n) = 1
    set d := Nat.gcd (m + n) (2 * n) with hdef
    have h1 : d ∣ m + n := Nat.gcd_dvd_left _ _
    have h2 : d ∣ 2 * n := Nat.gcd_dvd_right _ _
    have h3 : d ∣ n := odd_dvd_of_dvd_two_mul (odd_of_dvd_odd h1 hpar) h2
    have h4 : d ∣ m := (Nat.dvd_add_right h3).mp (by simpa [Nat.add_comm] using h1)
    exact eq_one_of_dvd_gcd_eq_one hg h4 h3
  · refine ⟨by omega, by omega, ?_, by omega⟩
    show Nat.gcd (2 * m) (m - n) = 1
    set d := Nat.gcd (2 * m) (m - n) with hdef
    have h1 : d ∣ 2 * m := Nat.gcd_dvd_left _ _
    have h2 : d ∣ m - n := Nat.gcd_dvd_right _ _
    have hodd : (m - n) % 2 = 1 := by omega
    have h4 : d ∣ m := odd_dvd_of_dvd_two_mul (odd_of_dvd_odd h2 hodd) h1
    have h3 : d ∣ n := by
      have h := Nat.dvd_sub h4 h2
      have he : m - (m - n) = n := by omega
      rwa [he] at h
    exact eq_one_of_dvd_gcd_eq_one hg h4 h3
  · refine ⟨by omega, by omega, ?_, by omega⟩
    show Nat.gcd (2 * m) (m + n) = 1
    set d := Nat.gcd (2 * m) (m + n) with hdef
    have h1 : d ∣ 2 * m := Nat.gcd_dvd_left _ _
    have h2 : d ∣ m + n := Nat.gcd_dvd_right _ _
    have h4 : d ∣ m := odd_dvd_of_dvd_two_mul (odd_of_dvd_odd h2 hpar) h1
    have h3 : d ∣ n := (Nat.dvd_add_right h4).mp h2
    exact eq_one_of_dvd_gcd_eq_one hg h4 h3

theorem Valid_eval (w : PriceWord) : Valid (eval w) := by
  have key : ∀ (w : PriceWord) (p : ℕ × ℕ), Valid p →
      Valid (w.foldl (fun p l => step l p) p) := by
    intro w
    induction w with
    | nil => intro p hp; simpa using hp
    | cons l t ih => intro p hp; exact ih _ (Valid_step l p hp)
  exact key w root root_valid

/-! ## The letter and the parent of a node -/

/-- The last letter of the address of a node: `A` iff the parameter `n` is even
(the 2-adic reading), and `B`/`C` according to whether `2n < m`. -/
def letterOf : ℕ × ℕ → PriceLetter
  | (m, n) => if n % 2 = 0 then .A else if 2 * n < m then .B else .C

/-- The parent of a node in the Price tree. -/
def parent : ℕ × ℕ → ℕ × ℕ
  | (m, n) =>
      if n % 2 = 0 then (m - n / 2, n / 2)
      else if 2 * n < m then (m / 2, m / 2 - n) else (m / 2, n - m / 2)

theorem letterOf_step (l : PriceLetter) (p : ℕ × ℕ) (hp : Valid p) :
    letterOf (step l p) = l := by
  obtain ⟨m, n⟩ := p
  obtain ⟨hn, hlt, hg, hpar⟩ := hp
  cases l <;> simp only [step, letterOf] <;> split_ifs <;> first | rfl | omega

theorem parent_step (l : PriceLetter) (p : ℕ × ℕ) (hp : Valid p) :
    parent (step l p) = p := by
  obtain ⟨m, n⟩ := p
  obtain ⟨hn, hlt, hg, hpar⟩ := hp
  cases l <;> simp only [step, parent] <;> split_ifs <;>
    simp only [Prod.mk.injEq] <;> omega

/-- The parameter `n` of a valid non-root node is never `m/2`: the `B`/`C` split is
genuine. -/
theorem two_mul_ne (p : ℕ × ℕ) (hp : Valid p) (hroot : p ≠ root) : 2 * p.2 ≠ p.1 := by
  obtain ⟨m, n⟩ := p
  obtain ⟨hn, hlt, hg, hpar⟩ := hp
  intro h
  have hd : n ∣ Nat.gcd m n := Nat.dvd_gcd ⟨2, by omega⟩ dvd_rfl
  rw [hg] at hd
  have hn1 : n = 1 := Nat.dvd_one.mp hd
  exact hroot (by simp [root, Prod.ext_iff, hn1]; omega)

/-- Every valid node other than the root is the `letterOf`-child of its parent. -/
theorem step_letterOf_parent (p : ℕ × ℕ) (hp : Valid p) (hroot : p ≠ root) :
    step (letterOf p) (parent p) = p := by
  have hnm := two_mul_ne p hp hroot
  obtain ⟨m, n⟩ := p
  obtain ⟨hn, hlt, hg, hpar⟩ := hp
  simp only at hnm
  simp only [letterOf, parent]
  split_ifs with h1 h2 <;> simp only [step, Prod.mk.injEq] <;> omega

theorem parent_valid (p : ℕ × ℕ) (hp : Valid p) (hroot : p ≠ root) : Valid (parent p) := by
  have hnm := two_mul_ne p hp hroot
  obtain ⟨m, n⟩ := p
  obtain ⟨hn, hlt, hg, hpar⟩ := hp
  simp only at hnm
  simp only [parent]
  split_ifs with h1 h2
  · refine ⟨by omega, by omega, ?_, by omega⟩
    show Nat.gcd (m - n / 2) (n / 2) = 1
    set d := Nat.gcd (m - n / 2) (n / 2) with hdef
    have h3 : d ∣ n / 2 := Nat.gcd_dvd_right _ _
    have h3' : d ∣ n := dvd_trans h3 ⟨2, by omega⟩
    have h2' : d ∣ m - n / 2 := Nat.gcd_dvd_left _ _
    have h4 : d ∣ m := by
      have h := Nat.dvd_add h2' h3
      have he : m - n / 2 + n / 2 = m := by omega
      rwa [he] at h
    exact eq_one_of_dvd_gcd_eq_one hg h4 h3'
  · refine ⟨by omega, by omega, ?_, by omega⟩
    show Nat.gcd (m / 2) (m / 2 - n) = 1
    set d := Nat.gcd (m / 2) (m / 2 - n) with hdef
    have h4 : d ∣ m / 2 := Nat.gcd_dvd_left _ _
    have h2' : d ∣ m / 2 - n := Nat.gcd_dvd_right _ _
    have h4' : d ∣ m := dvd_trans h4 ⟨2, by omega⟩
    have h3 : d ∣ n := by
      have h := Nat.dvd_sub h4 h2'
      have he : m / 2 - (m / 2 - n) = n := by omega
      rwa [he] at h
    exact eq_one_of_dvd_gcd_eq_one hg h4' h3
  · refine ⟨by omega, by omega, ?_, by omega⟩
    show Nat.gcd (m / 2) (n - m / 2) = 1
    set d := Nat.gcd (m / 2) (n - m / 2) with hdef
    have h4 : d ∣ m / 2 := Nat.gcd_dvd_left _ _
    have h2' : d ∣ n - m / 2 := Nat.gcd_dvd_right _ _
    have h4' : d ∣ m := dvd_trans h4 ⟨2, by omega⟩
    have h3 : d ∣ n := by
      have h := Nat.dvd_add h2' h4
      have he : n - m / 2 + m / 2 = n := by omega
      rwa [he] at h
    exact eq_one_of_dvd_gcd_eq_one hg h4' h3

theorem parent_sum_lt (p : ℕ × ℕ) (hp : Valid p) (hroot : p ≠ root) :
    (parent p).1 + (parent p).2 < p.1 + p.2 := by
  obtain ⟨m, n⟩ := p
  obtain ⟨hn, hlt, hg, hpar⟩ := hp
  simp only [parent]
  split_ifs <;> simp only <;> omega

/-! ## Addresses: uniqueness and completeness -/

/-- The Price address of a node, computed by iterated `parent`. -/
def address (p : ℕ × ℕ) : PriceWord :=
  if h : Valid p ∧ p ≠ root then
    have : (parent p).1 + (parent p).2 < p.1 + p.2 := parent_sum_lt p h.1 h.2
    address (parent p) ++ [letterOf p]
  else []
termination_by p.1 + p.2

@[simp] theorem address_root : address root = [] := by
  rw [address]; simp

/-- **Completeness**: every valid parameter pair is a node of the Price tree. -/
theorem eval_address (p : ℕ × ℕ) (hp : Valid p) : eval (address p) = p := by
  induction hs : p.1 + p.2 using Nat.strong_induction_on generalizing p with
  | _ s ih =>
    subst hs
    by_cases hroot : p = root
    · subst hroot; simp
    · rw [address, dif_pos ⟨hp, hroot⟩, eval_append_one,
        ih _ (parent_sum_lt p hp hroot) (parent p) (parent_valid p hp hroot) rfl]
      exact step_letterOf_parent p hp hroot

theorem sum_step_ge (l : PriceLetter) (p : ℕ × ℕ) (hp : Valid p) :
    p.1 + p.2 + 2 ≤ (step l p).1 + (step l p).2 := by
  obtain ⟨m, n⟩ := p
  obtain ⟨hn, hlt, -, -⟩ := hp
  cases l <;> simp only [step] <;> omega

theorem sum_step_le (l : PriceLetter) (p : ℕ × ℕ) (hp : Valid p) :
    (step l p).1 + (step l p).2 ≤ 3 * (p.1 + p.2) := by
  obtain ⟨m, n⟩ := p
  obtain ⟨hn, hlt, -, -⟩ := hp
  cases l <;> simp only [step] <;> omega

theorem Valid.three_le {p : ℕ × ℕ} (hp : Valid p) : 3 ≤ p.1 + p.2 := by
  obtain ⟨m, n⟩ := p
  obtain ⟨hn, hlt, -, -⟩ := hp
  omega

theorem sum_root_le (w : PriceWord) : 3 ≤ (eval w).1 + (eval w).2 := (Valid_eval w).three_le

theorem step_ne_root (l : PriceLetter) (p : ℕ × ℕ) (hp : Valid p) : step l p ≠ root := by
  intro h
  have h2 := sum_step_ge l p hp
  have h3 := hp.three_le
  rw [h] at h2
  simp only [root] at h2
  omega

theorem eval_append_one_ne_root (w : PriceWord) (l : PriceLetter) : eval (w ++ [l]) ≠ root := by
  rw [eval_append_one]
  exact step_ne_root l (eval w) (Valid_eval w)

/-- Unfolding lemma for `address` at a non-root node. -/
theorem address_of_ne_root (p : ℕ × ℕ) (hp : Valid p) (h : p ≠ root) :
    address p = address (parent p) ++ [letterOf p] := by
  rw [address, dif_pos ⟨hp, h⟩]

/-- **Uniqueness**: the address of the node addressed by `w` is `w` itself; no two Price
words collide. -/
theorem address_eval (w : PriceWord) : address (eval w) = w := by
  induction w using List.reverseRecOn with
  | nil => simp
  | append_singleton t l ih =>
    have hvt : Valid (eval t) := Valid_eval t
    have hv : Valid (step l (eval t)) := Valid_step l _ hvt
    have hne : step l (eval t) ≠ root := step_ne_root l _ hvt
    rw [eval_append_one, address_of_ne_root _ hv hne, parent_step l (eval t) hvt,
      letterOf_step l (eval t) hvt, ih]

theorem eval_injective : Function.Injective eval := by
  intro w w' h
  have h2 := congrArg address h
  rwa [address_eval, address_eval] at h2

/-- Every primitive parameter pair has **exactly one** Price address: the Price tree is a
tree (no duplicates) and it exhausts the primitive Pythagorean triples (no gaps). -/
theorem existsUnique_word (p : ℕ × ℕ) (hp : Valid p) : ∃! w : PriceWord, eval w = p :=
  ⟨address p, eval_address p hp, fun w hw => by rw [← hw, address_eval]⟩

/-- The Price tree as an explicit bijection: Price words ↔ primitive Euclid parameters. -/
def evalEquiv : PriceWord ≃ {p : ℕ × ℕ // Valid p} where
  toFun w := ⟨eval w, Valid_eval w⟩
  invFun p := address p.1
  left_inv w := address_eval w
  right_inv p := Subtype.ext (eval_address p.1 p.2)

/-! ## Depth bounds (the rigorous `dP` law) -/

/-- Geometric upper bound: a node at depth `d` has parameter sum at most `3^(d+1)`;
equivalently the depth is at least `log₃(m+n) - 1`. -/
theorem sum_le_of_length (w : PriceWord) : (eval w).1 + (eval w).2 ≤ 3 ^ (w.length + 1) := by
  induction w using List.reverseRecOn with
  | nil => norm_num [eval, root]
  | append_singleton t l ih =>
    rw [eval_append_one]
    calc (step l (eval t)).1 + (step l (eval t)).2 ≤ 3 * ((eval t).1 + (eval t).2) :=
          sum_step_le l _ (Valid_eval t)
      _ ≤ 3 * 3 ^ (t.length + 1) := by omega
      _ = 3 ^ ((t ++ [l]).length + 1) := by
          simp only [List.length_append, List.length_cons, List.length_nil]
          ring

/-- Arithmetic lower bound: a node at depth `d` has parameter sum at least `2d + 3`;
equivalently the depth is at most `(m+n-3)/2`. -/
theorem sum_ge_of_length (w : PriceWord) : 2 * w.length + 3 ≤ (eval w).1 + (eval w).2 := by
  induction w using List.reverseRecOn with
  | nil => norm_num [eval, root]
  | append_singleton t l ih =>
    rw [eval_append_one]
    have h := sum_step_ge l (eval t) (Valid_eval t)
    simp only [List.length_append, List.length_cons, List.length_nil]
    omega

/-- The Price depth of a node is squeezed logarithmically: with `s = m + n`,
`log₃ s - 1 ≤ depth ≤ (s - 3)/2`.  This is the proved form of the empirical `dP` law. -/
theorem depth_squeeze (p : ℕ × ℕ) (hp : Valid p) :
    p.1 + p.2 ≤ 3 ^ ((address p).length + 1) ∧
      2 * (address p).length + 3 ≤ p.1 + p.2 := by
  constructor
  · have h := sum_le_of_length (address p)
    rwa [eval_address p hp] at h
  · have h := sum_ge_of_length (address p)
    rwa [eval_address p hp] at h

end Price2Adic