import MachineLearning.BerggrenBoxDensity
import MachineLearning.BerggrenBranchGrowth

/-!
# Cycle 2: the Berggren address is unique, and counting forces exponential growth

`MachineLearning.BerggrenEuclidParam` shows that *every* positive primitive Pythagorean
triple with odd first leg has **at least one** Barning–Hall address.  This file proves the
complementary rigidity statement: it has **exactly one**.

The mechanism is the trichotomy that already drove the descent.  In Euclid coordinates the
three generators are `A(m,n) = (2m-n, m)`, `B(m,n) = (2m+n, m)`, `C(m,n) = (m+2n, n)`, and
their images are cut out by three *disjoint* inequalities on the new parameters `(M, N)`:

```
A : N < M < 2N,        B : 2N < M < 3N,        C : 3N < M.
```

Hence the last letter of an address can be read off from the node, and induction gives
uniqueness (`applyGens_root_injective`): the Berggren monoid acts *freely* on the tree, so
the tree really is a free ternary tree.

Combining freeness with the linear upper bound `#(boxNode H) ≤ H` of
`MachineLearning.BerggrenBoxDensity` yields a purely counting-theoretic growth theorem
(`depth_forces_hypotenuse`): if every node at depth `d` has hypotenuse at most `H`, then
`3^d ≤ H`.  Exponentially many addresses cannot fit in a linearly small box — the
arithmetic scarcity of primitive triples forces the geometric branches of the tree to run
away exponentially fast.
-/

namespace BerggrenStars

open Finset

/-! ### Reading the last letter off a node -/

/-- Every node of the tree, addressed by a word in the three-letter alphabet, has
admissible Euclid parameters. -/
theorem params_of_applyGens (g : List Gen) :
    ∃ m n : ℤ, IsParam m n ∧ applyGens g root = euclidTriple m n := by
  refine isNode_param ⟨g.map Gen.act, isBerggrenWord_map_act g, ?_⟩
  rw [← applyGens_eq_applyWord]

/-- The root is not in the image of any generator: it is the unique node of depth `0`. -/
theorem root_ne_act {x : Gen} {m n : ℤ} (hp : IsParam m n) :
    Gen.act x (euclidTriple m n) ≠ root := by
  intro h
  rw [← euclid_root] at h
  have hn := hp.npos
  have hnm := hp.lt
  have hm := hp.mpos
  cases x
  · rw [Gen.act, mA_euclid] at h
    obtain ⟨e1, e2⟩ := euclidTriple_injective (param_A hp).mpos (param_A hp).npos
      (by norm_num) (by norm_num) h
    omega
  · rw [Gen.act, mB_euclid] at h
    obtain ⟨e1, e2⟩ := euclidTriple_injective (param_B hp).mpos (param_B hp).npos
      (by norm_num) (by norm_num) h
    omega
  · rw [Gen.act, mC_euclid] at h
    obtain ⟨e1, e2⟩ := euclidTriple_injective (param_C hp).mpos (param_C hp).npos
      (by norm_num) (by norm_num) h
    omega

/-- **The last letter and the parent are determined by the node.**  This is the disjointness
of the three Barning–Hall branches, in Euclid coordinates. -/
theorem act_injective {x y : Gen} {m n m' n' : ℤ} (hp : IsParam m n) (hp' : IsParam m' n')
    (h : Gen.act x (euclidTriple m n) = Gen.act y (euclidTriple m' n')) :
    x = y ∧ m = m' ∧ n = n' := by
  have hn := hp.npos
  have hnm := hp.lt
  have hm := hp.mpos
  have hn' := hp'.npos
  have hnm' := hp'.lt
  have hm' := hp'.mpos
  cases x <;> cases y <;>
    simp only [Gen.act, mA_euclid, mB_euclid, mC_euclid] at h
  · obtain ⟨e1, e2⟩ := euclidTriple_injective (param_A hp).mpos (param_A hp).npos
      (param_A hp').mpos (param_A hp').npos h
    exact ⟨rfl, by omega, by omega⟩
  · obtain ⟨e1, e2⟩ := euclidTriple_injective (param_A hp).mpos (param_A hp).npos
      (param_B hp').mpos (param_B hp').npos h
    omega
  · obtain ⟨e1, e2⟩ := euclidTriple_injective (param_A hp).mpos (param_A hp).npos
      (param_C hp').mpos (param_C hp').npos h
    omega
  · obtain ⟨e1, e2⟩ := euclidTriple_injective (param_B hp).mpos (param_B hp).npos
      (param_A hp').mpos (param_A hp').npos h
    omega
  · obtain ⟨e1, e2⟩ := euclidTriple_injective (param_B hp).mpos (param_B hp).npos
      (param_B hp').mpos (param_B hp').npos h
    exact ⟨rfl, by omega, by omega⟩
  · obtain ⟨e1, e2⟩ := euclidTriple_injective (param_B hp).mpos (param_B hp).npos
      (param_C hp').mpos (param_C hp').npos h
    omega
  · obtain ⟨e1, e2⟩ := euclidTriple_injective (param_C hp).mpos (param_C hp).npos
      (param_A hp').mpos (param_A hp').npos h
    omega
  · obtain ⟨e1, e2⟩ := euclidTriple_injective (param_C hp).mpos (param_C hp).npos
      (param_B hp').mpos (param_B hp').npos h
    omega
  · obtain ⟨e1, e2⟩ := euclidTriple_injective (param_C hp).mpos (param_C hp).npos
      (param_C hp').mpos (param_C hp').npos h
    exact ⟨rfl, by omega, by omega⟩

/-- **Freeness of the Berggren monoid.**  Distinct addresses give distinct nodes: the
Barning–Hall tree is a genuine free ternary tree. -/
theorem applyGens_root_injective : ∀ g g' : List Gen,
    applyGens g root = applyGens g' root → g = g' := by
  intro g
  induction g with
  | nil =>
      intro g' h
      cases g' with
      | nil => rfl
      | cons y t' =>
          exfalso
          obtain ⟨m', n', hp', he'⟩ := params_of_applyGens t'
          rw [applyGens_nil, applyGens_cons, he'] at h
          exact root_ne_act hp' h.symm
  | cons x t ih =>
      intro g' h
      cases g' with
      | nil =>
          exfalso
          obtain ⟨m, n, hp, he⟩ := params_of_applyGens t
          rw [applyGens_nil, applyGens_cons, he] at h
          exact root_ne_act hp h
      | cons y t' =>
          obtain ⟨m, n, hp, he⟩ := params_of_applyGens t
          obtain ⟨m', n', hp', he'⟩ := params_of_applyGens t'
          rw [applyGens_cons, applyGens_cons, he, he'] at h
          obtain ⟨hxy, hmm, hnn⟩ := act_injective hp hp' h
          subst hxy
          have : applyGens t root = applyGens t' root := by
            rw [he, he', hmm, hnn]
          rw [ih t' this]

/-! ### Counting forces exponential growth -/

instance : Fintype Gen := ⟨{Gen.A, Gen.B, Gen.C}, fun x => by cases x <;> decide⟩

theorem card_Gen : Fintype.card Gen = 3 := rfl

/-- **Exponentially many addresses cannot fit in a linearly small box.**  If every node at
depth `d` of the Berggren tree has hypotenuse at most `H`, then `3 ^ d ≤ H`.

This is a genuine interaction between the two halves of the project: the *combinatorial*
freeness of the tree (`applyGens_root_injective`) and the *arithmetic* scarcity of
primitive Pythagorean triples (`boxNode_card_le`). -/
theorem depth_forces_hypotenuse (d H : ℕ)
    (h : ∀ g : List Gen, g.length = d → (applyGens g root).2.2 ≤ (H : ℤ)) : 3 ^ d ≤ H := by
  have hmem : ∀ u : Fin d → Gen, applyGens (List.ofFn u) root ∈ boxNode H := by
    intro u
    have hlen : (List.ofFn u).length = d := List.length_ofFn
    have hnode : IsNode (applyGens (List.ofFn u) root) :=
      ⟨(List.ofFn u).map Gen.act, isBerggrenWord_map_act _, by rw [← applyGens_eq_applyWord]⟩
    set v := applyGens (List.ofFn u) root with hv
    obtain ⟨ha, hb, hc, hpy, -, -⟩ := (isNode_iff v.1 v.2.1 v.2.2).mp (by simpa using hnode)
    have hcH : v.2.2 ≤ (H : ℤ) := h (List.ofFn u) hlen
    rw [mem_boxNode]
    refine ⟨?_, hnode⟩
    rw [mem_box]
    refine ⟨⟨ha, ?_⟩, ⟨hb, ?_⟩, ⟨hc, hcH⟩⟩
    · nlinarith
    · nlinarith
  have hinj : Set.InjOn (fun u : Fin d → Gen => applyGens (List.ofFn u) root)
      (Finset.univ : Finset (Fin d → Gen)) := by
    intro u _ w _ huw
    have : List.ofFn u = List.ofFn w := applyGens_root_injective _ _ huw
    exact List.ofFn_injective this
  have hcard : (Finset.univ : Finset (Fin d → Gen)).card ≤ (boxNode H).card :=
    Finset.card_le_card_of_injOn _ (fun u _ => hmem u) hinj
  have huniv : (Finset.univ : Finset (Fin d → Gen)).card = 3 ^ d := by
    simp [Finset.card_univ, card_Gen]
  rw [huniv] at hcard
  exact le_trans hcard (boxNode_card_le H)

/-- The contrapositive, in the form "some node of depth `d` is exponentially far out". -/
theorem exists_deep_node_large (d : ℕ) :
    ∃ g : List Gen, g.length = d ∧ (3 ^ d : ℤ) ≤ (applyGens g root).2.2 := by
  by_contra hcon
  push_neg at hcon
  have hH : ∀ g : List Gen, g.length = d → (applyGens g root).2.2 ≤ ((3 ^ d - 1 : ℕ) : ℤ) := by
    intro g hg
    have := hcon g hg
    have h3 : ((3 ^ d - 1 : ℕ) : ℤ) = (3 : ℤ) ^ d - 1 := by
      have : (1 : ℕ) ≤ 3 ^ d := Nat.one_le_pow _ _ (by norm_num)
      push_cast [this]
      ring
    omega
  have := depth_forces_hypotenuse d (3 ^ d - 1) hH
  have h1 : (1 : ℕ) ≤ 3 ^ d := Nat.one_le_pow _ _ (by norm_num)
  omega

end BerggrenStars